public with sharing class ContactTriggerHandler extends TriggerHandler {
    
    private List<Contact> newContacts;
    private List<Contact> oldContacts;
    private Map<Id, Contact> oldContMap;
    private Map<Id, Contact> newContMap;

    public ContactTriggerHandler() {

        this.newContacts = (List<Contact>) Trigger.new;
        this.oldContacts = (List<Contact>) Trigger.old;
        this.newContMap = (Map<Id, Contact>) Trigger.newMap;
        this.oldContMap = (Map<Id, Contact>) Trigger.oldMap;

    }

    public override void beforeInsert() {
        
    }

    public override void afterInsert() {
        ContactHelper.sumOfContactsAmount(newContacts, null);
    }

    public override void beforeUpdate() {
        
    }

    public override void afterUpdate() {
        ContactHelper.sumOfContactsAmount(newContacts, oldContMap);
    }

    public override void beforeDelete() {
        ContactHelper.preventContactDeletion(oldContacts);
    }

    public override void afterDelete() {
        ContactHelper.sumOfContactsAmount(oldContacts, null);
    }

    public override void afterUndelete() {
        ContactHelper.sumOfContactsAmount(newContacts, null);
    }
}