public with sharing class AccountEmailHelper {

    public static void sendNewTierAccountEmails(List<Account> AccountsList, Map<Id, Account> accountsMap){

        List<String> targetEmails = new List<String> {'y.raghavendra008@gmail.com', 'sravanti.ch28@gmail.com'};

        //Method to hold single email messages
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for(Account acc : AccountsList){

            if(acc.Loyalty_Tier__c != null && acc.Loyalty_Tier__c != accountsMap.get(acc.Id).Loyalty_Tier__c){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(targetEmails);
                email.setSubject('Your Account Tier has changed from - ' + accountsMap.get(acc.Id).Loyalty_Tier__c + ' to ' + acc.Loyalty_Tier__c);
                email.setPlainTextBody('Dear Customer,\n \n' + 
                'This is a notification to let you know that your account has been updated from - ' + accountsMap.get(acc.Id).Loyalty_Tier__c + ' to ' + acc.Loyalty_Tier__c + '\n \n' +
                'Account Name: ' + acc.Name + '\n' +
                'Account Loyalty Tier: ' + acc.Loyalty_Tier__c + '\n' +
                'Latest Loyalty Points: ' + acc.Loyalty_Points__c );

                emailsToSend.add(email);
            }
            
            
        }

        if(!emailsToSend.isEmpty()){
            Messaging.sendEmail(emailsToSend);
        }

    }
    public static void accDescriptionUpdate(List<Account> accountsList, Map<Id, Account> accountsMap){
        for(Account acc : accountsList){
            if(acc.Industry!= null && acc.Industry!= accountsMap.get(acc.Id).Industry){
            acc.Description = userinfo.getName() +' '+ datetime.now() +' '+ accountsMap.get(acc.Id).Industry +' '+ acc.Industry;
            }
        }
    }
    public static void contactCreation(List<Account> accountList){
        List<Contact> contactsToBeCreated = new List<Contact>();
        for(Account acc: accountList){
            for(integer i=1;i<=3;i++){
                Contact con = new Contact();
                con.LastName = acc.Name + ' Contact '+i;
                con.AccountId=acc.Id;
                contactsToBeCreated.add(con);
            }
        }
        insert contactsToBeCreated;
    }


//Account Address Update(after update, after insert, after undelete)
//Account Helper method

//whenver there is a change in the Account Billing Address
   public static void updateContactAddress(Map<Id, Account> newAccountsMap, Map<Id, Account> oldAccountsMap){
       Set<Id> accountIds = new Set<Id>();
       
       for(Account acc : newAccountsMap.values()){
           if((acc.BillingStreet != oldAccountsMap.get(acc.Id).BillingStreet) ||  
               (acc.BillingCity != oldAccountsMap.get(acc.Id).BillingCity) ||
               (acc.BillingState != oldAccountsMap.get(acc.Id).BillingState) || 
               (acc.BillingPostalCode != oldAccountsMap.get(acc.Id).BillingPostalCode) || 
               (acc.BillingCountry != oldAccountsMap.get(acc.Id).BillingCountry)){
                   accountIds.add(acc.Id);
           }
       }

       List<Contact> contactsToBeUpdated = new List<Contact>();

       for(Contact con : [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds ]){
           Account acc = newAccountsMap.get(con.AccountId);
           con.MailingStreet =  acc.BillingStreet;
           con.MailingCity = acc.BillingCity;
           con.MailingState = acc.BillingState;
           con.MailingCountry = acc.BillingCountry;
           con.MailingPostalCode = acc.BillingPostalCode;

           contactsToBeUpdated.add(con);
       }

       if(!contactsToBeUpdated.isEmpty()){
           update contactsToBeUpdated;
       }
   }
   public static void preventActiveAccountDeletion(List<Account> accountsToDelete) {
    for (Account acc : accountsToDelete) {
        if (acc.Active__c == 'Yes') {
            acc.addError('You cannot delete an active account.');
        }
    }
}
}



    



