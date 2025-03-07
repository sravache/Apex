public with sharing class EmployeeHelperClass {
    public static void updateMinAndMaxSalary(List<Employee__c> newEmployees, Map<Id, Employee__c> oldEmployeesMap){

        Set<Id> employerIds = new Set<Id>();

        //Loop to get the EmployerId of all the new employee records or the updated employee records where there is a change in the Employer or Salary
        for(Employee__c emp : newEmployees){
            if(oldEmployeesMap == null && emp.Employer__c != null){
                employerIds.add(emp.Employer__c);
            }
            else if(oldEmployeesMap != null && emp.Employer__c != null &&( (emp.Employer__c != oldEmployeesMap.get(emp.Id).Employer__c) 
            || (emp.Salary__c != oldEmployeesMap.get(emp.Id).Salary__c))){
                employerIds.add(emp.Employer__c);
                employerIds.add(oldEmployeesMap.get(emp.Id).Employer__c);
            }
        }

        Map<Id, Decimal> employerToMaxSalaryMap = new Map<Id, Decimal>(); // AmazonId => 1000K
        Map<Id, Decimal> employerToMinSalaryMap = new Map<Id, Decimal>(); // AmazonId => 10K
      //  Map<Id, List<Decimal>> employerSalaryMap = new Map<Id, List<Decimal>>(); //AmazonId => {10K, 1000K}



        List<Employer__c> employersToBeUpdated = new List<Employer__c>();
        //Aggregate result to get the Min, Max Salary for each employer
        if(!employerIds.isEmpty()){
            for(AggregateResult empAgg : [SELECT Employer__c employerId, MIN(Salary__c) minSal, MAX(Salary__c) maxSal
                                        FROM Employee__c 
                                        WHERE Employer__c IN :employerIds
                                        GROUP BY Employer__c]){
                employerToMaxSalaryMap.put((Id)empAgg.get('employerId'), (Decimal)empAgg.get('maxSal'));

                
                  //  employerSalaryMap.put((Id) empAgg.get('employerId'), new List<Decimal>{(Decimal)empAgg.get('maxSal'), 
                                                                                            (Decimal)empAgg.get('minSal')});

                                                                           // AmazonId => {1000K, 10K}
                

                employerToMinSalaryMap.put((Id)empAgg.get('employerId'), (Decimal)empAgg.get('minSal'));                           
            }

            for(Id employerId : employerIds){
                Employer__c employer = new Employer__c (Id = employerId, 
                                                    Highest_Salary__c = employerToMaxSalaryMap.get(employerId),
                                                    Least_Salary__c = employerToMinSalaryMap.get(employerId));

                                                  //  Highest_Salary__c = emplopyerSalaryMap.get(employerId)[0];
                                                  //  Least_Salary__c = employerSalaryMap.get(employerId)[1];
                                                    
                employersToBeUpdated.add(employer);                                                                       
            }
        }

        if(!employersToBeUpdated.isEmpty()){
            update employersToBeUpdated;
        }
    }
    public static void updateOppProdOnAccount(List<OpportunityLineItem> newOppLineItems){

        Set<Id> oppIds = new Set<Id>();
        //Collecting all the Parent Opportunities for the Opportunity Line Items
        for(OpportunityLineItem oppProd : newOppLineItems){
            if(oppProd.OpportunityId != null){
                oppIds.add(oppProd.OpportunityId);
            }
        }

        Set<Id> accIds = new Set<Id>();
        //Collecting all the Parent AccountIds for the Opps collected above.
        if(!oppIds.isEmpty()){
            for(Opportunity opp : [SELECT Id, AccountId FROM Opportunity WHERE Id IN:oppIds]){
                accIds.add(opp.AccountId);
            }
        }

        Map<Id, Integer> oppToTotalOppProducts = new Map<Id, Integer>();

        for(Opportunity opp : [SELECT Id, AccountId, (SELECT Id FROM OpportunityLineItems) FROM Opportunity WHERE AccountId IN :accIds]){
                oppToTotalOppProducts.put(opp.Id, opp.OpportunityLineItems.size() != null ? opp.OpportunityLineItems.size() : 0);
        }

        List<Account> accountsToBeUpdated = new List<Account>();

        for(Account acc : [SELECT Id, Total_Opportunity_Products__c, (SELECT Id FROM Opportunities) FROM Account WHERE Id IN : accIds]){
            Integer count = 0;
            for(Opportunity opp : acc.Opportunities){
                count += oppToTotalOppProducts.get(opp.Id);
            }
            acc.Total_Opportunity_Products__c = count;
            accountsToBeUpdated.add(acc);
        }

        if(!accountsToBeUpdated.isEmpty()){
            update accountsToBeUpdated;
        }
    }
}