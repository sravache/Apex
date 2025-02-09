public with sharing class AccountEmailHelper {

    public static void sendNewTierAccountEmails(List<Account> newAccounts, Map<Id, Account> oldAccountsMap){

        List<String> targetEmails = new List<String> {'y.raghavendra008@gmail.com', 'sravanti.ch28@gmail.com'};

        //Method to hold single email messages
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for(Account acc : newAccounts){

            if(acc.Loyalty_Tier__c != null && acc.Loyalty_Tier__c != oldAccountsMap.get(acc.Id).Loyalty_Tier__c){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(targetEmails);
                email.setSubject('Your Account Tier has changed from - ' + oldAccountsMap.get(acc.Id).Loyalty_Tier__c + ' to ' + acc.Loyalty_Tier__c);
                email.setPlainTextBody('Dear Customer,\n \n' + 
                'This is a notification to let you know that your account has been updated from - ' + oldAccountsMap.get(acc.Id).Loyalty_Tier__c + ' to ' + acc.Loyalty_Tier__c + '\n \n' +
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
}