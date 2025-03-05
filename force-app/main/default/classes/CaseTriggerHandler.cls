public with sharing class CaseTriggerHandler extends TriggerHandler {

    private List<Case> newCases;
    private List<Case> oldCases;
    private Map<Id, Case> newCasesMap;
    private Map<Id, Case> oldCasesMap;

    public CaseTriggerHandler() {
        this.newCases = (List<Case>) Trigger.new;
        this.oldCases = (List<Case>) Trigger.old;
        this.newCasesMap = (Map<Id, Case>) Trigger.newMap;
        this.oldCasesMap = (Map<Id, Case>) Trigger.oldMap;
    }

     public override void beforeInsert() {
        CaseHelper.assignCasesToQueues(newCases, oldCaseMap); //Challenge 9        
    } 

     public override void afterinsert() {
         CaseHelper.taskCreationOnCaseEscalation(newCases, oldCasesMap);
         CaseHelper.updateLatestCaseNumberOnAccount(newCases, oldCaseMap); //Challenge 11
    } 

    public override void beforeUpdate() {
        CaseHelper.automateCaseEscalation(newCases, oldCasesMap);
        Casehelper.assignCasesToQueues(newCases, oldCaseMap); //Challenge 9
    } 

    public override void afterUpdate() {
        CaseHelper.taskCreationOnCaseEscalation(newCases, oldCasesMap);
        CaseHelper.updateLatestCaseNumberOnAccount(newCases, oldCaseMap); //Challenge 11
    }


    /* public override void beforeDelete() {
        
    } */

    /* public override void afterDelete() {
        
    } */

    /* public override void afterUndelete() {
        
    } */
}