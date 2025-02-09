public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    private List<Opportunity> newOpportunities;
    private List<Opportunity> oldOpportunities;
    private Map<Id, Opportunity> newOpportunitiesMap;
    private Map<Id, Opportunity> oldOpportunitiesMap;

    public OpportunityTriggerHandler() {
        this.newOpportunities = (List<Opportunity>) Trigger.new;
        this.oldOpportunities = (List<Opportunity>) Trigger.old;
        this.newOpportunitiesMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOpportunitiesMap = (Map<Id, Opportunity>) Trigger.oldMap;
    }

    /* public override void beforeInsert() {
        
    } */

    /* public override void afterinsert() {
        
    } */

    /* public override void beforeUpdate() {
        
    } */

    public override void afterUpdate() {
        OpportunityLoyaltyHelper.calculateLoyaltyPoints(newOpportunities, oldOpportunitiesMap);
    }

    /* public override void beforeDelete() {
        
    } */

    /* public override void afterDelete() {
        
    } */

    /* public override void afterUndelete() {
        
    } */
}