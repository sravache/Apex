@isTest
private class ContactHelperTest {
    
    @isTest
    static void testAfterInsert() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        system.debug('Account ID:::: ' +acc.Id);
        Contact newContact = new Contact(FirstName = 'New', LastName = 'Contact', AccountId = acc.Id, Amount__c = 200);

        Test.startTest();
        insert newContact;
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Sum_of_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(200, updatedAcc.Sum_of_Amount__c, 'Sum_of_Amount__c should update correctly after insert.');
    }

    @isTest
    static void testAfterUpdate() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact existingContact = new Contact(FirstName = 'Existing', LastName = 'Contact', AccountId = acc.Id, Amount__c = 100);
        insert existingContact;

        existingContact.Amount__c = 500;

        Test.startTest();
        update existingContact;
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Sum_of_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(500, updatedAcc.Sum_of_Amount__c, 'Sum_of_Amount__c should update correctly after update.');
    }

    @isTest
    static void testAfterDelete() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact existingContact = new Contact(FirstName = 'Existing', LastName = 'Contact', AccountId = acc.Id, Amount__c = 100);
        insert existingContact;

        Test.startTest();
        delete existingContact;
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Sum_of_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, updatedAcc.Sum_of_Amount__c, 'Sum_of_Amount__c should update correctly after delete.');
    }


    
    @isTest
    static void testAfterUndelete() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact existingContact = new Contact(FirstName = 'Existing', LastName = 'Contact', AccountId = acc.Id, Amount__c = 100);
        insert existingContact;

        delete existingContact;

        Test.startTest();
        undelete existingContact;
        Test.stopTest();

        Account updatedAcc = [SELECT Id, Sum_of_Amount__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(100, updatedAcc.Sum_of_Amount__c, 'Sum_of_Amount__c should update correctly after undelete.');
    }
}