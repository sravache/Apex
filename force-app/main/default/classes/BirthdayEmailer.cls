public with sharing class BirthdayEmailer {
    @InvocableMethod(label='Send Birthday Emails') //method callable from Salesforce Flows
    public static void sendBirthdayEmail(){
        Date todaysDate=Date.today();
        list<Contact> conList=[SELECT Id, Name, Email, BirthDate
                          FROM Contact
                          WHERE CALENDAR_MONTH(BirthDate) = :Date.today().month()
                          AND DAY_IN_MONTH(BirthDate) = :Date.today().day()
                          AND Email != null]; // VERY important: don't try to email contacts without emails!

        Set<String> sentEmailAddresses = new Set<String>();  // To track sent emails and prevent duplicates
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for(Contact con:conList){
            if (con.Email != null && !sentEmailAddresses.contains(con.Email)) { // Check for null and duplicates
                string[] toAddress=new string[]{con.Email};
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddress);
                mail.setSubject('Happy Birthday  '+con.Name );
                mail.setPlainTextBody('Wish you a happy birthday and may you live a very long life, ' + con.Name + '!'); // Corrected the concatenation
                emails.add(mail);
                sentEmailAddresses.add(con.Email); // Add the email to the set of sent addresses
            }
        }
        if(emails.size()>0){
            try {
                Messaging.sendEmail(emails);
            } catch (Exception e) {
                System.debug('Error sending emails: ' + e.getMessage());
                // Add more robust error handling here (e.g., logging to a custom object)
            }
        }
    }
}
