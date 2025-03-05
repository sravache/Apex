/* A company stores large amounts of Opportunity records and wants to recalculate discounts based on new pricing policies. Your task is to write a Batch Apex class that:
Fetches all Closed Won Opportunities from the last 12 months.
Updates a custom field New_Discount__c based on:
If Amount > 50000, set New_Discount__c = 10%
If Amount between 20000 and 50000, set New_Discount__c = 5%
Otherwise, set New_Discount__c = 2%
After processing, send an email notification to the admin with a count of how many records were updated.*/

/* A company stores large amounts of Opportunity records and wants to recalculate discounts based on new pricing policies. Your task is to write a Batch Apex class that:
Fetches all Closed Won Opportunities from the last 12 months.
Updates a custom field New_Discount__c based on:
If Amount > 50000, set New_Discount__c = 10%
If Amount between 20000 and 50000, set New_Discount__c = 5%
Otherwise, set New_Discount__c = 2%
After processing, send an email notification to the admin with a count of how many records were updated.*/

public with sharing class OpportunityBatchClass implements Database.Batchable<sObject>, Database.Stateful {

    public Integer recordsProcessed = 0;

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator('SELECT Id, Name FROM Opportunity WHERE StageName = \'Closed Won\' AND CreatedDate = LAST_N_MONTHS:12');
    }

    public void execute(Database.BatchableContext bc, List<sObject> scope){
        batchesProcessed++;
        List<Opportunity> oppsToBeUpdated = new List<Opportunity>();

        for(sObject obj : scope){
            Opportunity opp = (Opportunity)obj;
            if(opp.Amount > 50000){
                opp.New_Discount__c = 10;
            }
            else if(opp.Amount > 20000 && opp.Amount < 50000){
                opp.New_Discount__c = 5;
            }
            else{
                opp.New_Discount__c = 2;
            }
            oppsToBeUpdated.add(opp);
            recordsProcessed++;
        }

        if(!oppsToBeUpdated.isEmpty()){
            update oppsToBeUpdated;
        }
        // Check if the maximum number of batches has been reached
        if (batchesProcessed >= MAX_BATCHES) {
            System.abortJob(bc.getJobId()); // Abort the job after 2 batches
    }

    public void finish(Database.BatchableContext bc){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new List<String>{UserInfo.getUserId()});
        email.setSubject('Opportunity Discount Update Batch Process Completed');
        email.setPlainTextBody('The Opportunity discount update batch has completed.\n\n + Total records Processed ::: '+recordsProcessed);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
    }

}