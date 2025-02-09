public with sharing class AccountTriggerHandler extends TriggerHandler {

    private List<Account> newAccounts;
    private List<Account> oldAccounts;
    private Map<Id, Account> newAccountMap;
    private Map<Id, Account> oldAccountMap;

    public AccountTriggerHandler() {
        this.newAccounts = (List<Account>) Trigger.new;
        this.oldAccounts = (List<Account>) Trigger.old;
        this.newAccountMap = (Map<Id, Account>) Trigger.newMap;
        this.oldAccountMap = (Map<Id, Account>) Trigger.oldMap;
    }

    /* public override void beforeInsert() {
        
    } */

    /* public override void afterinsert() {
        
    } */

    /* public override void beforeUpdate() {
        
    } */

    public override void afterUpdate() {
        AccountEmailHelper.sendNewTierAccountEmails(newAccounts, oldAccountMap);
    }

    /* public override void beforeDelete() {
        
    } */

    /* public override void afterDelete() {
        
    } */

    /* public override void afterUndelete() {
        
    } */
}