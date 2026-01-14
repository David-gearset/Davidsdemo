// CaseTriggerHandler.apxc
public class CaseTriggerHandler {

    /**
     * Bulkified method to send a single notification email for all new Cases.
     * @param newCases A list of Case records from Trigger.new
     */
    public static void sendNotificationEmail(List<Case> newCases) {
        // 1. Create a list to hold all email messages
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        // 2. Loop through all new records to construct email messages
        for (Case c : newCases) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // Set the recipient, subject, and body for the email
            mail.setToAddresses(new String[] { 'admin@example.com' });
            mail.setSubject('New Case Created: ' + c.CaseNumber);
            mail.setPlainTextBody('A new case was created with ID: ' + c.Id + '.');

            // Add the constructed email message to the list
            emailsToSend.add(mail);
        }

        // 3. Perform the DML operation (sendEmail) once, outside the loop (Bulkification)
        if (!emailsToSend.isEmpty()) {
            Messaging.sendEmail(emailsToSend, false); // The optional second parameter (allOrNone) is set to false
        }
    }
}