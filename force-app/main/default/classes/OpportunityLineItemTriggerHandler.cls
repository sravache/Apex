public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {
    List<OpportunityLineItem> newOppLineItems;
    List<OpportunityLineItem> oldOppLineItems;
    Map<Id, OpportunityLineItem> oldOppLineItemsMap;
    Map<Id, OpportunityLineItem> newOppLineItemsMap;

    public OpportunityLineItemTriggerHandler() {
        this.newOppLineItems = (List<OpportunityLineItem>) Trigger.new;
        this.oldOppLineItems = (List<OpportunityLineItem>) Trigger.old;
        this.oldOppLineItemsMap = (Map<Id, OpportunityLineItem>) Trigger.oldMap;
        this.newOppLineItemsMap = (Map<Id, OpportunityLineItem>) Trigger.newMap;
    }
    /*
    public override void beforeInsert() {
        
    }
    */
    public override void afterinsert() {
        DiscountCalculatorHelper.updateOriginalAmount(newOppLineItems);//Challenge 4
        DiscountCalculatorHelper.calculateDiscount(newOppLineItems);  //Challenge 4 
        DiscountCalculatorHelper.updateOppProdOnAccount(newOppLineItems);//Challenge 7    
    }
/*
    public override void beforeUpdate() {
        
    }
*/
    public override void afterUpdate() {
        DiscountCalculatorHelper.updateOriginalAmount(newOppLineItems);//Challenge 4
        DiscountCalculatorHelper.calculateDiscount(newOppLineItems);  //Challenge 4   
    }

   /* public override void beforeDelete() {
        
    }
   */
    public override void afterDelete() {
        DiscountCalculatorHelper.updateOriginalAmount(newOppLineItems);//Challenge 4
        DiscountCalculatorHelper.calculateDiscount(newOppLineItems);  //Challenge 4  
        DiscountCalculatorHelper.updateOppProdOnAccount(oldOppLineItems);//Challenge 7  
    }

    public override void afterUndelete() {
        DiscountCalculatorHelper.updateOriginalAmount(newOppLineItems);//Challenge 4
        DiscountCalculatorHelper.calculateDiscount(newOppLineItems); //Challenge 4     
    }
}