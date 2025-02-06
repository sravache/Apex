public with sharing class ContactHelper {
   

    public static void sumOfContactsAmount(List<Contact> contactsList, Map<Id, Contact> oldContactMap){

        //Account Ids to aggregate the Amount of the Contact
        Set<Id> accountIds = new Set<Id>();

        //Add accountIds for Insert and Undelete scenarios
        if((Trigger.isInsert || Trigger.isUndelete) && contactsList != null ){
                for(Contact con : contactsList){
                    if(con.AccountId != null){
                        accountIds.add(con.AccountId);
                    }
                }
        }

        // Explicitly add AccountIds for delete scenario
        if (Trigger.isDelete) {  
            for (Contact con : contactsList) {
                if (con.AccountId != null) {
                    accountIds.add(con.AccountId);
                }
            }
        }

        //add accountids for the update scenario
        if(Trigger.isUpdate && contactsList != null){
            for(Contact con : contactsList){
                //Amount on Account changes when the Account is changed or amount is changed
                if(con.AccountId != null && 
                ((oldContactMap.get(con.Id).AccountId != con.AccountId) || oldContactMap.get(con.Id).Amount__c != con.Amount__c )){ 
                    accountIds.add(con.AccountId);
                    accountIds.add(oldContactMap.get(con.Id).AccountId);
                }
            }
        }

        //Return from this process if there are no AccountIds related to the Contacts
        if(accountIds.isEmpty()){
            return;
        }

        //Map that stores the accountid and its sum of Amount for the related Contacts
        Map<Id, Decimal> accountToSumOfContactAmount = new Map<Id, Decimal>();

        //Aggregate query for the AccountId and sum of Amount to be stored in the Map
        for(AggregateResult aggResult: [SELECT AccountId, SUM(Amount__c) sumAmount 
                                        FROM Contact WHERE AccountId IN :accountIds 
                                        GROUP BY AccountId]){

            accountToSumOfContactAmount.put(
                (Id) aggResult.get('AccountId'), (Decimal) aggResult.get('sumAmount')
            );

            }

            //List of accounts to be updated
            List<Account> listOfAccountsToBeUpdated = new List<Account>();

            
            for(Id accId : accountIds){
                //the aggregate query doesn't add the row of the account that doesn't have any contacts related. So to handle the scenario when all the contacts are deleted, 
                //then amount should be 0
                Decimal newAmount = accountToSumOfContactAmount.containsKey(accId) ? accountToSumOfContactAmount.get(accId) : 0;
                listOfAccountsToBeUpdated.add(new Account(Id = accId, Sum_of_Amount__c =  newAmount));
            }
        

        if(!listOfAccountsToBeUpdated.isEmpty()){
            update listOfAccountsToBeUpdated;
        }
    }



    public static void preventContactDeletion(List<Contact> contactsList){

        //Collect the Contact Ids
        Set<Id> contactIds = new Set<Id>();

        for(Contact con : contactsList){
            contactIds.add(con.Id);
        }

        Map<Id, OpportunityContactRole> contactRoleMap = new Map<Id, OpportunityContactRole>();

        //Query those OppContactRoles where the ContactId is present, it is marked as Primary and also at the same time the Opp is Open.
        List<OpportunityContactRole> contactRoles = [SELECT ContactId FROM OpportunityContactRole WHERE ContactId IN : contactIds AND      IsPrimary = TRUE AND Opportunity.StageName NOT IN ('Closed Won', 'Closed Lost')];

        if(!contactRoles.isEmpty()){
            //Query the Opp Contact Roles to find that the Contact is not a Primary Contact on an Open Opp
            for(OpportunityContactRole ocr : contactRoles){
                contactRoleMap.put(ocr.contactId, ocr);
                }
        }

        //Prevent the deletion of the Contacts
        for(Contact con : contactsList){
            if(contactRoleMap.containsKey(con.Id)){
                con.addError('This Contact is marked as Primary Contact against an Open Opportunity. You cannot delete this boss');
            }
        }

    }
}