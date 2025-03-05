public with sharing class ContactHelper {

    public static void sumOfContactsAmount(List<Contact> contactsList, Map<Id, Contact> oldContactMap) {
        Set<Id> accountIds = new Set<Id>();

        // Add accountIds for Insert and Undelete scenarios
        if ((Trigger.isInsert || Trigger.isUndelete) && contactsList != null) {
            for (Contact con : contactsList) {
                if (con.AccountId != null) {
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

        // Add accountids for the update scenario
        if (Trigger.isUpdate && contactsList != null) {
            for (Contact con : contactsList) {
                // Amount on Account changes when the Account is changed or amount is changed
                if (con.AccountId != null &&
                    (oldContactMap.get(con.Id).AccountId != con.AccountId || oldContactMap.get(con.Id).Amount__c != con.Amount__c)) {
                    accountIds.add(con.AccountId);
                    accountIds.add(oldContactMap.get(con.Id).AccountId);
                }
            }
        }

        // Return from this process if there are no AccountIds related to the Contacts
        if (accountIds.isEmpty()) {
            return;
        }

        // Map that stores the accountid and its sum of Amount for the related Contacts
        Map<Id, Decimal> accountToSumOfContactAmount = new Map<Id, Decimal>();

        // Aggregate query for the AccountId and sum of Amount to be stored in the Map
        for (AggregateResult aggResult : [SELECT AccountId, SUM(Amount__c) sumAmount
                                          FROM Contact WHERE AccountId IN :accountIds
                                          GROUP BY AccountId]) {
            accountToSumOfContactAmount.put((Id) aggResult.get('AccountId'), (Decimal) aggResult.get('sumAmount'));
        }

        // List of accounts to be updated
        List<Account> listOfAccountsToBeUpdated = new List<Account>();

        for (Id accId : accountIds) {
            Decimal newAmount = accountToSumOfContactAmount.containsKey(accId) ? accountToSumOfContactAmount.get(accId) : 0;
            listOfAccountsToBeUpdated.add(new Account(Id = accId, Sum_of_Amount__c = newAmount));
        }

        if (!listOfAccountsToBeUpdated.isEmpty()) {
            update listOfAccountsToBeUpdated;
        }
    }

    public static void preventContactDeletion(List<Contact> contactsList) {
        Set<Id> contactIds = new Set<Id>();
        for (Contact con : contactsList) {
            contactIds.add(con.Id);
        }

        Map<Id, OpportunityContactRole> contactRoleMap = new Map<Id, OpportunityContactRole>();
        List<OpportunityContactRole> contactRoles = [SELECT ContactId 
                                                     FROM OpportunityContactRole 
                                                     WHERE ContactId IN :contactIds 
                                                     AND IsPrimary = TRUE 
                                                     AND Opportunity.StageName NOT IN ('Closed Won', 'Closed Lost')];

        if (!contactRoles.isEmpty()) {
            for (OpportunityContactRole ocr : contactRoles) {
                contactRoleMap.put(ocr.ContactId, ocr);
            }
        }

        for (Contact con : contactsList) {
            if (contactRoleMap.containsKey(con.Id)) {
                con.addError('This Contact is marked as Primary Contact against an Open Opportunity. You cannot delete this boss');
            }
        }
    }

    public static void defaultPhone(List<Contact> newContacts) {
        for (Contact con : newContacts) {
            if (con.Phone == null) {
                con.Phone = '123-456-7890';
            }
        }
    }

    public static void updateContactAddress(List<Contact> newContacts, Map<Id, Contact> oldContactMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Contact con : newContacts) {
            if (con.AccountId != null && (oldContactMap.get(con.Id) == null || con.AccountId != oldContactMap.get(con.Id).AccountId)) {
                accountIds.add(con.AccountId);
            }
        }

        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode 
                                                            FROM Account WHERE Id IN :accountIds]);
        List<Contact> contactsToBeUpdated = new List<Contact>();

        for (Contact con : newContacts) {
            if (con.AccountId != null && accountMap.containsKey(con.AccountId)) {
                Account acc = accountMap.get(con.AccountId);

                con.MailingStreet = acc.BillingStreet;
                con.MailingCity = acc.BillingCity;
                con.MailingState = acc.BillingState;
                con.MailingCountry = acc.BillingCountry;
                con.MailingPostalCode = acc.BillingPostalCode;

                contactsToBeUpdated.add(con);
            }
        }
    }

    public static void countOfActiveContacts(List<Contact> contactList, Map<Id, Contact> oldContactMap) {
        Set<Id> accIds = new Set<Id>();
        Map<Id, Integer> accIdToCountMap = new Map<Id, Integer>();

        if (Trigger.isInsert || Trigger.isUndelete || Trigger.isDelete) {
            for (Contact con : contactList) {
                if (con.AccountId != null && con.Active__c) {
                    accIds.add(con.AccountId);
                }
            }
        }

        if (Trigger.isUpdate) {
            for (Contact con : contactList) {
                if (con.AccountId != null &&
                    (oldContactMap.get(con.Id).Active__c != con.Active__c || con.AccountId != oldContactMap.get(con.Id).AccountId)) {
                    accIds.add(con.AccountId);
                    accIds.add(oldContactMap.get(con.Id).AccountId);
                }
            }
        }

        if (!accIds.isEmpty()) {
            for (AggregateResult agg : [SELECT AccountId, COUNT(Id) cnt
                                        FROM Contact
                                        WHERE AccountId IN :accIds
                                        AND Active__c = true
                                        GROUP BY AccountId]) {
                accIdToCountMap.put((Id) agg.get('AccountId'), (Integer) agg.get('cnt'));
            }
        }

        List<Account> accountsToBeUpdated = new List<Account>();

        if (!accIdToCountMap.isEmpty()) {
            for (Id accId : accIds) {
                Account acc = new Account();
                acc.Id = accId;
                acc.Active_Contacts_Count__c = accIdToCountMap.get(accId) != null ? accIdToCountMap.get(accId) : 0;
                accountsToBeUpdated.add(acc);
            }

            if (!accountsToBeUpdated.isEmpty()) {
                update accountsToBeUpdated;
            }
        }
    }
}
