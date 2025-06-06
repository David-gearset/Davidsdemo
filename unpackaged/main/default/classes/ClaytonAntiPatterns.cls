/**
 * @description This class intentionally contains several anti-patterns
 * to demonstrate Clayton's static analysis and auto-fix capabilities.
 * DO NOT use this code in a production environment as-is.
 */
public inherited sharing class ClaytonAntiPatterns { // Issue 1: Missing 'with sharing' or 'without sharing' keyword.
                                   // For simplicity, we omit it here to trigger a flag,
                                   // though 'with sharing' is often the default assumption for data operations.

    // Issue 2: Hardcoded ID - This is generally a bad practice as IDs are environment specific.
    private static final Id HARDCODED_PROFILE_ID = '00e000000000000AAA'; // Placeholder ID. Use a real one if you test with profiles.

    /**
     * @description Processes a list of Account records, demonstrating SOQL and DML in loops.
     * @param accountNames A list of account names to search for.
     */
    public static void processAccountsWithIssues(List<String> accountNames) {
        if (accountNames == null || accountNames.isEmpty()) {
            return;
        }

        for (String accName : accountNames) {
            // Issue 3: SOQL query inside a loop - Major performance anti-pattern.
            // Clayton would suggest moving this query outside and using a Map.
            List<Account> accounts = [SELECT Id, Name, AnnualRevenue FROM Account WHERE Name = :accName LIMIT 1];

            if (!accounts.isEmpty()) {
                Account singleAccount = accounts[0];
                singleAccount.AnnualRevenue = 1000000; // Hypothetical update

                // Issue 4: DML operation inside a loop - Another major performance anti-pattern.
                // Clayton would suggest collecting records into a list and performing a single DML operation.
                update singleAccount;

                // Issue 5: System.debug inside a loop - Can cause performance issues, especially in large loops.
                System.debug('Processed Account: ' + singleAccount.Name);
            }
        }
    }

    /**
     * @description Demonstrates an empty catch block and unnecessary variable.
     */
    public static void demonstrateBadExceptionHandling() {
        String unusedVariable = 'This variable is not used.'; // Issue 6: Unused variable.

        try {
            Integer result = 10 / 0; // This will cause a DML exception
            System.debug('Result: ' + result);
        } catch (Exception e) {
            // Issue 7: Empty catch block - Hides exceptions, making debugging difficult.
            // Clayton would flag this, suggesting at least logging the exception.
        }
    }

    /**
     * @description An example of a method that could be called without bulkification.
     * While the method itself might not have a direct anti-pattern for Clayton,
     * how it's used elsewhere (e.g., in a trigger not calling a handler) could.
     * This is more for conceptual demonstration.
     * @param recordId The ID of the record to process.
     */
    public static void processSingleRecord(Id recordId) {
        // Issue 8: Consider this a simplified method often used non-bulkified.
        // If this were in a trigger context and called for each record, it's an anti-pattern.
        // For Clayton to flag this here, it would typically need more context like a trigger handler.
        // However, the "Single Record" processing can often lead to un-bulkified DML/SOQL in triggers.
        if (recordId != null) {
            Account acc = [SELECT Id, Name FROM Account WHERE Id = :recordId LIMIT 1];
            if (acc != null) {
                acc.Name = acc.Name + ' - Processed';
                update acc;
            }
        }
    }

    /**
     * @description A method demonstrating a complex conditional which might indicate
     * room for refactoring or simpler logic.
     * @param value A string value.
     * @return A string based on the input value.
     */
    public static String getComplexString(String value) {
        if (value != null && value.length() > 5) {
            if (value.startsWith('A') || value.contains('X')) {
                return 'Complex A or X';
            } else {
                return 'Complex No A or X';
            }
        } else if (value != null && value.length() == 0) { // Fix: Changed value.isEmpty() to value.length() == 0
            return 'Empty Value';
        } else {
            // Issue 9: This 'else' block could potentially lead to missed return paths
            // or unhandled conditions in more complex scenarios. Not a direct Clayton auto-fix,
            // but an indicator of complexity.
            return 'Default';
        }
    }
}