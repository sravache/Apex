- 👋 Hi, I’m Sravanthi Cheerladinne
- 👀 I’m passionate about exploring technology and solving real-world problems.  
- 🌱 Currently diving deep into Salesforce Administration and Development.  
- 💞️ I’m eager to collaborate on Salesforce projects and innovative tech ideas.  
- 📫 Reach me at [sravanti.ch28@gmail.com]
- ⚡ Fun fact: I believe every challenge is just a puzzle waiting to be solved!  

# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

Day	Apex Challenge 	Prerequisites if any	Solution	Difficulty Level
1	Calculate the sum of Amount values from related Contacts and update the Sum of Amount field on the corresponding Account.	"Contact.Amount__c
Account.Sum_Of_Amount__c"	"ContactTriggerHandler; ContactHelperTest; 
ContactHelper.sumOfContactsAmount(); 

"	Medium
2	Prevent the deletion of a contact if it is a Primary Contact on an Open Opportunity		ContactHelper.preventContactDeletion();	Medium
3	"Scenario: Automated Customer Loyalty Program

You're working for a retail company that wants to implement an automated customer loyalty program in Salesforce. The program should track customer purchases, calculate loyalty points, and automatically upgrade customer tiers based on their total spend.

Requirements:
When a new opportunity is closed as ""Won"", calculate and add loyalty points to the associated account.
Loyalty points are calculated as 1 point per $10 spent.

Update the account's loyalty tier based on total points:
Bronze: 0-29999 points
Silver: 29999-59999 points
Gold: 60000+ points

Send an email notification to the customer when their tier changes."	"Account.Loyalty_Tier__c (Formula)
Account.Loyalty_Points__c"	"OpportunityHelper.calculateLoyaltyPoints();
OpportunityTriggerHandler
AccountHelper.sendNewTierAccountEmails();"	Medium
4	"Automatically Apply Discounts on OpportunityLineItems Based on Opportunity Amount.

If the Opportunity Amount is greater than $200,000, apply a 10% discount to all Opportunity Line Items.
If the Opportunity Amount is between $50,000 and $200,000, apply a 5% discount.
No discount is applied if the Opportunity Amount is less than $50,000."	Opportunity.Original_Amount__c	"OppLineItemTriggerHandler;
OppLineItemHelper.updateOriginalAmount();
OppLineItemHelper.calculateDiscount();"	Medium
5	"(i) Automatically Update the Account Description with the Current Timestamp and User who updated the Account record When an Account record is updated. So Account Description should look like this. User Name + Timestamp

(ii) When an account record is created, create 3 contacts with the Contact Name = Account Name + Contact i"		"AccountHelper.updateAccountDescription();
AccountHelper.createContacts();"	Easy
6	Count the total number of Active Contacts related to an Account and update them on the custom field - 'Active_Contacts_Count__c'	Account.Active_Contacts_Count__c	ContactHelper.countOfActiveContacts();	Medium
7	"A custom field on Account, ""Total_Opportunity_Products__c"", should always store the count of related Opportunities' OpportunityLineItem records

Whenever a user creates or deletes an OpportunityLineItem, the field should update accordingly"	Account.Total_Opportunity_Products__c	OppLineItemHelper.updateOppProdOnAccount();	Difficult
8	Whenever an Account's Billing Address is updated, update the Mailing Address of all related Contacts to match the updated Account Billing Address.		"AccountHelper.updateContactAddress();
ContactHelper.updateContactAddress();"	Medium
9	"A company provides support for various product categories. Each Case has a Product Category field (Product_Category__c - Picklist) with values:
Software; Hardware; Services
Business Rules:
If a Case is Open (Status ≠ 'Closed' and Product_Category__c = 'Software', assign it to the Software Support Team (Queue: Software_Support_Queue).
If a Case is Open and Product_Category__c = 'Hardware', assign it to the Hardware Support Team (Queue: Hardware_Support_Queue).
If a Case is Open and the Product_Category__c = 'Services', assign it to the Services Support Team (Queue: Services_Support_Queue)."	"Case.Product_Category__c
Queues
Software_Support_Queue
Hardware_Support_Queue
Services_Support_Queue
Custom MetadataType 
Case_Queue_Assignment__mdt
"	CaseHelper.assignCasesToQueues();	Medium
10	"Whenever an Account is updated, check all related Opportunities. If an Opportunity was created more than 30 days ago, meets the following conditions, and is still not Closed, update its Stage to 'Closed Lost'.
Check Last Activity Date: Only update the Opportunity if there has been no activity (Tasks or Events) in the last 15 days.
Exclude High-Value Deals: If the Opportunity Amount exceeds $100,000, do not update the Stage. Instead, assign a follow-up task to the Opportunity Owner.
Notify Sales Leadership: If more than 5 Opportunities under the Account are marked Closed Lost, send an email notification to the Sales Manager with a summary."		OpportunityHelper.updateOppStage()	Medium
11	"Whenever a Case is inserted on an Account, update the Latest_Case_Number__c field on the Account with the most recent Case Number based on the Created Date.
Prioritize High-Priority Cases: If multiple cases are created at the same time, prefer cases where Priority = ‘High’ when updating the Account.

"	Account.Latest_Case_Number__c	CaseHelper.updateLatestCaseNumberOnAccount();	Medium
12	Show minimum and maximum salary among all employees on Parent Employer record.	"Employer__c(Custom Object)
Employer__c.Name
Employer__c.Least_Salary__c
Employer__c.Highest_Salary__c

============================

Employee__c (Custom Object)
Employee__c.Salary__c
Employee__c.Employee_Name__c
Employee__c.Employer__c(Lookup)"	EmployeeHelper.updateMinAndMaxSalary()	Medium
13	"Whenever an Opportunity is created, updated, or deleted, update the Parent Account field (Opportunity_Details__c) on the Account with the Opportunity that has the highest Amount among all related Opportunities that are not closed.
Exclude Closed-Lost Opportunities: Only consider Opportunities that are Open or in a Closed-Won stage.
Handle Ties: If multiple Opportunities have the same highest Amount, pick the most recently created one.

Opportunity Details field should look like this : 
Highest Opp Amount Info :: Name :: ${Name} :: Amount : ${Amount}
Second Highest Opp Amount Info :: Name :: Express Logistics Portable Truck Generators :: Amount : $${Amount}
Second Lowest Opp Amount Info :: No Opportunity found
Lowest Amount Opp Info :: Name :: ${Name} :: Amount : $${Amount}

Also, make sure your code will be able to handle the scenarios when for any account there are fewer opps less than 4.
"	Account.Opportunity_Details__c	OpportunityHelper.updateOppDetailsOnAccount();	Difficult