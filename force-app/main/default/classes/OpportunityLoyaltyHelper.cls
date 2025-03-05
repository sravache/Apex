public with sharing class OpportunityLoyaltyHelper {
    
    public static void calculateLoyaltyPoints(List<Opportunity> newOpps, Map<Id, Opportunity> oldOppsMap){

        //Accounts To be updated
        Set<Id> accountIds = new Set<Id>();

        //Loop through Changed Opportunities
        for(Opportunity opp : newOpps){
            Opportunity oldOpp = oldOppsMap.get(opp.Id);
            if(opp.StageName == 'Closed Won' && oldOpp.StageName != 'Closed Won' && opp.AccountId != null){
                accountIds.add(opp.AccountId);
            }
    }

    system.debug('Account Id::::: '+accountIds);

    //Check if the Set of Accounts are null and 
    if(!accountIds.isEmpty()){
        updateLoyaltyPoints(accountIds);
    }
}

private static void updateLoyaltyPoints(Set<Id> accIds){

    List<Account> accountsToBeUpdated = new List<Account>();

    for(AggregateResult agg : [SELECT AccountId, SUM(Amount) sumAmount FROM 
                                Opportunity WHERE StageName = 'Closed Won' AND AccountId IN :accIds GROUP BY AccountId]){
                                    system.debug('Aggregate Result:::: '+agg);
                                    Account acc = new Account();
                                    acc.Id = (Id) agg.get('AccountId');
                                    acc.Loyalty_Points__c = (Integer)(((Decimal) agg.get('sumAmount'))/10);
                                    system.debug('Loyalty Points and Amount:::: '+acc);
                                    accountsToBeUpdated.add(acc);
    }

    if(!accountsToBeUpdated.isEmpty()){
        update accountsToBeUpdated;
    }
}

/*Whenever an Account is updated, check all related Opportunities. 
If an Opportunity was created more than 30 days ago, meets the following conditions, 
and is still not Closed, update its Stage to 'Closed Lost'.
Check Last Activity Date: 
Only update the Opportunity if there has been no activity (Tasks or Events) in the last 15 days.
Exclude High-Value Deals: 
If the Opportunity Amount exceeds $100,000, do not update the Stage. Instead, 
assign a follow-up task to the Opportunity Owner.
Notify Sales Leadership: 
If more than 5 Opportunities under the Account are marked Closed Lost, 
send an email notification to the Sales Manager with a summary.*/

public static void updateOppStage(List<Account> newAccts, Map<Id, Account> oldAccMap){

    List<Opportunity> opps = [SELECT Id, Name, AccountId, Amount, OwnerId 
                                FROM Opportunity 
                                WHERE AccountId IN :oldAccMap.keySet() 
                                AND IsClosed = false 
                                AND CreatedDate < LAST_N_DAYS:30
                                AND LastActivityDate < LAST_N_DAYS:15];

    Set<Opportunity> taskOpps = new Set<Opportunity>();

    //Counting Opps related to an Account to send Email if there are more than 5 opps to same acc
    Map<Id, Integer> accountToOppCount = new Map<Id, Integer>();

    List<Opportunity> oppsToBeUpdated = new List<Opportunity>();

    for(Opportunity opp : opps){

        accountToOppCount.put(opp.AccountId, accountToOppCount.get(opp.AccountId) == null ? 1 : accountToOppCount.get(opp.AccountId) + 1);

        if(opp.Amount > 100000){
            taskOpps.add(opp);
        }
        else {
            oppsToBeUpdated.add(opp);
        }
    }

    //Updates the StageName to 'Closed Lost' for those Opps whose Amount < 100K
    if(!oppsToBeUpdated.isEmpty()){
        for(Opportunity opp : oppsToBeUpdated){
            opp.StageName = 'Closed Lost';
        }
        update oppsToBeUpdated;
    }

    //Creates follow-up task for those Opps whose Amount > 100K
    if(!taskOpps.isEmpty()){
        List<Task> followUpTasks = new List<Task>();

        for(Opportunity opp : taskOpps){
            Task task = new Task();
            task.Subject = 'Follow Up Task -- No Activity & Created 30 Days back';
            task.ActivityDate = Date.today()+1;
            task.OwnerId = opp.OwnerId;
            task.WhatId = opp.Id;
            task.Status = 'Not Started';

            followUpTasks.add(task);
        }

        if(!followUpTasks.isEmpty()){
            insert followUpTasks;
        }
    }

    //Sending Email Alerts to Account Owner
    List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();
    
    for(Account acc : [SELECT Id, Name, OwnerId, Owner.Name, Owner.Email FROM Account WHERE Id IN : accountToOppCount.keySet()]){

        if(accountToOppCount.get(acc.Id) >= 5 ){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            email.setToAddresses(new List<String>{acc.Owner.Email});
            email.setSubject('Alert : Multiple Opps without any Activity');
            email.setPlainTextBody('Hello '+acc.Owner.Name +'\n \n Account : ' + acc.Name +' has more than 5 Opportunities without any Activity from the last 15 days. Please take some action.');

            emailsToBeSent.add(email);
        }
    }

    if(!emailsToBeSent.isEmpty()){
        Messaging.sendEmail(emailsToBeSent);
    }
    
}

public static void updateOppDetailsOnAccount(List<Opportunity> oppsList, Map<Id, Opportunity> oldOppMap){


    Set<Id> accountIds = new Set<Id>();
    
    String highestAmountOpp = ' No Opportunity found';
    String secondHighestAmountOpp = ' No Opportunity found';
    String lowestAmountOpp = ' No Opportunity found';
    String secondLowestAmountOpp = ' No Opportunity found';

    //Collect all the AccountIds covering all the possibilities
    for(Opportunity opp : oppsList){
        if((Trigger.isInsert || Trigger.isUndelete || Trigger.isDelete) && opp.AccountId != null && !opp.IsClosed){
            accountIds.add(opp.AccountId);
        }
        
        else if(Trigger.isUpdate && opp.AccountId != null && !opp.IsClosed 
                && ((opp.AccountId != oldOppMap.get(opp.Id).AccountId) || (opp.Amount != oldOppMap.get(opp.Id).Amount) || 
                (opp.StageName != oldOppMap.get(opp.Id).StageName))){
                    accountIds.add(opp.AccountId);
                    accountIds.add(oldOppMap.get(opp.Id).AccountId);
        }
    }

    List<Opportunity> relatedOpps = [SELECT Id, AccountId, Amount, Name
                                        FROM Opportunity
                                        WHERE AccountId IN :accountIds
                                        AND IsClosed = false
                                        ORDER BY Amount DESC, CreatedDate DESC];
                                        
    Map<Id, List<Opportunity>> acccountIdToOppsMap = new Map<Id, List<Opportunity>>();

    for(Opportunity opp : relatedOpps){
        if(!acccountIdToOppsMap.containsKey(opp.AccountId)){
            acccountIdToOppsMap.put(opp.AccountId, new List<Opportunity>{opp});
        }
        else {
            acccountIdToOppsMap.get(opp.AccountId).add(opp);
        }
    }

    List<Account> accountsToBeUpdated = new List<Account>();


    for(Id accId : acccountIdToOppsMap.keySet()){

        List<Opportunity> sortedOpps = acccountIdToOppsMap.get(accId);

        Integer sizeOfSortedOpps = sortedOpps.size();
        Integer lastIndex = sizeOfSortedOpps - 1;
        //Highest Amount Opp
        if(!sortedOpps.isEmpty()){
            if(sizeOfSortedOpps > 0){
                highestAmountOpp = 'Name :: ' +sortedOpps[0].Name + ' :: Amount : $'+sortedOpps[0].Amount;
            }

            if(sizeOfSortedOpps > 1){
                if(sizeOfSortedOpps == 2){
                    lowestAmountOpp = 'Name :: '+ sortedOpps[lastIndex].Name + ' :: Amount : $'+sortedOpps[lastIndex].Amount;
                }
                else {
                    secondHighestAmountOpp = 'Name :: '+ sortedOpps[1].Name + ' :: Amount : $'+sortedOpps[1].Amount;
                }
                
            }

            if(sizeOfSortedOpps > 2){
                lowestAmountOpp = 'Name :: '+ sortedOpps[sizeOfSortedOpps - 1].Name + ' :: Amount : $'+sortedOpps[sizeOfSortedOpps - 1].Amount;
            }

            if(sizeOfSortedOpps > 3){
                secondLowestAmountOpp = 'Name :: '+ sortedOpps[sizeOfSortedOpps - 2].Name + ' :: Amount : $'+sortedOpps[sizeOfSortedOpps - 2].Amount;
            }

        }
        else{
            return;
        }

        String oppDetails = 'Highest Opp Amount Info :: ' +highestAmountOpp + '\n' +
                            'Second Highest Opp Amount Info :: ' + secondHighestAmountOpp +'\n'+
                            'Second Lowest Opp Amount Info :: ' +secondLowestAmountOpp + '\n'+
                            'Lowest Amount Opp Info :: ' +lowestAmountOpp;

        Account acc = new Account(Id = accId, Opportunity_Details__c = oppDetails); 
        accountsToBeUpdated.add(acc);            
    }

    if(!accountsToBeUpdated.isEmpty()){
        update accountsToBeUpdated;
    }

}

}