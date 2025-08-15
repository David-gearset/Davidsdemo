/**
 * @description Manages operations related to Opportunities, including creation, updates, and deletions.
 * Also includes methods to interact with related Account and Contact records.
 */
public with sharing class OpportunityManager {

    /**
     * @description Creates a new Opportunity and links it to a specified Account and Contact.
     * @param oppName The name of the new Opportunity.
     * @param accountId The ID of the Account to link the Opportunity to.
     * @param contactId The ID of the Contact to link the Opportunity to.
     * @param amount The amount of the Opportunity.
     * @return The ID of the newly created Opportunity.
     * @throws AuraHandledException If required parameters are null or blank.
     */
    public static Id createOpportunityWithContact(String oppName, Id accountId, Id contactId, Decimal amount) {
        // Input validation for required fields
        if (String.isBlank(oppName) || accountId == null || contactId == null || amount == null) {
            throw new AuraHandledException('Opportunity Name, Account, Contact, and Amount are required.');
        }

        // Create a new Opportunity record
        Opportunity newOpp = new Opportunity(
            Name = oppName,
            AccountId = accountId,
            // Assuming ContactId can be populated on Opportunity or a custom lookup exists
            ContactId = contactId,
            StageName = 'Prospecting', // Default stage
            CloseDate = Date.today().addMonths(1), // Default close date
            Amount = amount
        );

        // Perform DML operation to insert the new Opportunity
        insert newOpp;
        return newOpp.Id;
    }

    /**
     * @description Updates an existing Opportunity's StageName and Amount.
     * @param oppId The ID of the Opportunity to update.
     * @param newStage The new StageName for the Opportunity.
     * @param newAmount The new Amount for the Opportunity.
     * @throws AuraHandledException If required parameters are null or blank, or if the Opportunity is not found.
     */
    public static void updateOpportunityStageAndAmount(Id oppId, String newStage, Decimal newAmount) {
        // Input validation for required parameters
        if (oppId == null || String.isBlank(newStage) || newAmount == null) {
            throw new AuraHandledException('Opportunity ID, new Stage, and new Amount are required.');
        }

        // Query the Opportunity to ensure it exists and retrieve current values
        Opportunity oppToUpdate = [SELECT Id, StageName, Amount FROM Opportunity WHERE Id = :oppId LIMIT 1];
        if (oppToUpdate == null) {
            throw new AuraHandledException('Opportunity not found with ID: ' + oppId);
        }

        // Update the fields
        oppToUpdate.StageName = newStage;
        oppToUpdate.Amount = newAmount;

        // Perform DML operation to update the Opportunity
        update oppToUpdate;
    }

    /**
     * @description Deletes a list of Opportunities by their IDs.
     * @param oppIds A list of Opportunity IDs to delete.
     * @throws AuraHandledException If the list of IDs is null or empty.
     */
    public static void deleteOpportunities(List<Id> oppIds) {
        // Input validation for the list of IDs
        if (oppIds == null || oppIds.isEmpty()) {
            throw new AuraHandledException('List of Opportunity IDs cannot be empty.');
        }

        // Query the Opportunities to be deleted
        List<Opportunity> oppsToDelete = [SELECT Id FROM Opportunity WHERE Id IN :oppIds];

        // Perform DML operation only if there are opportunities to delete
        if (!oppsToDelete.isEmpty()) {
            delete oppsToDelete;
        }
    }

    /**
     * @description Calculates the total amount of all Opportunities associated with a given Account.
     * @param accountId The ID of the Account.
     * @return The sum of the amounts of all Opportunities for the specified Account.
     * @throws AuraHandledException If Account ID is null.
     */
    public static Decimal getTotalOpportunityAmount(Id accountId) {
        // Input validation
        if (accountId == null) {
            throw new AuraHandledException('Account ID is required.');
        }

        Decimal totalAmount = 0;
        // Aggregate query to sum the amounts
        AggregateResult[] results = [SELECT SUM(Amount) total FROM Opportunity WHERE AccountId = :accountId];

        if (results != null && !results.isEmpty() && results[0].get('total') != null) {
            totalAmount = (Decimal)results[0].get('total');
        }
        return totalAmount;
    }

    /**
     * @description Updates a related Contact's Description field when an Opportunity reaches 'Closed Won' stage.
     * This method demonstrates interaction with a related object.
     * @param oppId The ID of the Opportunity that was closed.
     * @throws AuraHandledException If Opportunity ID is null or Opportunity not found.
     */
    public static void updateContactOnOppClose(Id oppId) {
        // Input validation
        if (oppId == null) {
            throw new AuraHandledException('Opportunity ID is required.');
        }

        // Query the Opportunity, including its ContactId
        Opportunity opp = [SELECT Id, StageName, ContactId FROM Opportunity WHERE Id = :oppId LIMIT 1];

        if (opp == null) {
            throw new AuraHandledException('Opportunity not found with ID: ' + oppId);
        }

        // Check if the opportunity is 'Closed Won' and has a related contact
        if (opp.StageName == 'Closed Won' && opp.ContactId != null) {
            // Query the related Contact
            Contact relatedContact = [SELECT Id, Description FROM Contact WHERE Id = :opp.ContactId LIMIT 1];
            if (relatedContact != null) {
                // Update the Contact's Description
                relatedContact.Description = 'Contact associated with Closed Won Opportunity: ' + opp.Id + ' on ' + Date.today();
                // Perform DML operation to update the Contact
                update relatedContact;
            }
        }
    }
}