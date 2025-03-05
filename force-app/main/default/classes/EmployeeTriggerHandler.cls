public with sharing class EmployeeTriggerHandler extends TriggerHandler {

    private List<Employee__c> newEmployees;
    private List<Employee__c> oldEmployees;
    private Map<Id, Employee__c> newEmployeesMap;
    private Map<Id, Employee__c> oldEmployeesMap;

    public EmployeeTriggerHandler() {
        this.newEmployees = (List<Employee__c>) Trigger.new;
        this.oldEmployees = (List<Employee__c>) Trigger.old;
        this.newEmployeesMap = (Map<Id, Employee__c>) Trigger.newMap;
        this.oldEmployeesMap = (Map<Id, Employee__c>) Trigger.oldMap;
    }

    /* public override void beforeInsert() {
        
    } */

    public override void afterinsert() {
        EmployeeHelper.updateMinAndMaxSalary(newEmployees, oldEmployeesMap); //Challenge 12
    }

    /* public override void beforeUpdate() {
    } */

    public override void afterUpdate() {
        EmployeeHelper.updateMinAndMaxSalary(newEmployees, oldEmployeesMap); //Challenge 12
    } 

    /* public override void beforeDelete() {
        
    } */

    /* public override void afterDelete() {
        
    } */

    /* public override void afterUndelete() {
        
    } */
}