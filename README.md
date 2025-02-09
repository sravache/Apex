- 👋 Hi, I’m Sravanthi Cheerladinne
- 👀 I’m passionate about exploring technology and solving real-world problems.  
- 🌱 Currently diving deep into Salesforce Administration and Development.  
- 💞️ I’m eager to collaborate on Salesforce projects and innovative tech ideas.  
- 📫 Reach me at [sravanti.ch28@gmail.com]
- 😄 Pronouns: She/Her  
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

1. Calculate the sum of Amount values from related Contacts and update the Sum of Amount field on the corresponding Account. |Contact.Amount__c ;Account.Sum_Of_Amount__c
2. Prevent the deletion of a contact if it is a Primary Contact on an Open Opportunity.
3. When a new opportunity is closed as "Won", calculate and add loyalty points to the associated account. Loyalty points are calculated as 1 point per $10 spent. Update the account's loyalty tier based on total points: Bronze: 0-29999 points; Silver: 30000-59999 points; Gold: 60000+ points. Send an email notification to the customer when their tier changes. |Account.Loyalty_Points__c; Account.Loyalty_Tier__c
