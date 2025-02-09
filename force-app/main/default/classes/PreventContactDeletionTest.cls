@isTest
public class PreventContactDeletionTest {
    
    @testSetup
    static void setupTestData() {
        // Create an Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Contacts
        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc.Id),
            new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = acc.Id)
        };
        insert contacts;

        // Fetch inserted contacts
        Contact contact1 = [SELECT Id FROM Contact WHERE FirstName = 'John' LIMIT 1];
        Contact contact2 = [SELECT Id FROM Contact WHERE FirstName = 'Jane' LIMIT 1];

        // Create Opportunities
        Opportunity openOpp = new Opportunity(
            Name = 'Open Opp',
            StageName = 'Prospecting', 
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert openOpp;

        Opportunity closedOpp = new Opportunity(
            Name = 'Closed Opp',
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(-10),
            AccountId = acc.Id
        );
        insert closedOpp;

        // Assign Contact Roles
        List<OpportunityContactRole> contactRoles = new List<OpportunityContactRole>{
            // Primary Contact on an Open Opportunity (should prevent deletion)
            new OpportunityContactRole(OpportunityId = openOpp.Id, ContactId = contact1.Id, IsPrimary = true),

            // Primary Contact on a Closed Opportunity (should allow deletion)
            new OpportunityContactRole(OpportunityId = closedOpp.Id, ContactId = contact2.Id, IsPrimary = true)
        };

        insert contactRoles;

        System.debug('### Test Setup Complete: Contact 1 (Primary on Open Opp) ID = ' + contact1.Id);
        System.debug('### Test Setup Complete: Contact 2 (Primary on Closed Opp) ID = ' + contact2.Id);
    }

    @isTest
    static void testPreventContactDeletion() {
        // Retrieve test Contacts
        List<Contact> contacts = [SELECT Id FROM Contact];

        System.debug('### Attempting to delete contacts: ' + contacts);

        Test.startTest();
        Database.DeleteResult[] deleteResults = Database.delete(contacts, false);
        Test.stopTest();

        // Track number of failures
        Integer failedDeletes = 0;
        for (Database.DeleteResult dr : deleteResults) {
            if (!dr.isSuccess()) {
                failedDeletes++;
                System.assert(dr.getErrors()[0].getMessage().contains('This Contact is marked as Primary Contact against an Open Opportunity'), 
                    'Expected error message not found.');
            }
        }

        System.debug('### Number of failed deletions: ' + failedDeletes);

        // Only the contact associated with the Open Opportunity should fail deletion
        System.assertEquals(1, failedDeletes, 
            'Only one contact should fail deletion due to Open Opportunity Primary Contact role.');
    }
}