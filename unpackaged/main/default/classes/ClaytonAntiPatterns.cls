/**
 * @description This class is designed to intentionally contain anti-patterns
 * that are highly likely to trigger auto-fix suggestions in static analysis tools like Clayton.
 * DO NOT use this code in a production environment as-is.
 */
public class ClaytonAntiPatterns { // Issue 1: Missing 'with sharing' or 'without sharing' keyword.
                                   // Expected Auto-fix: Add 'with sharing' (or 'without sharing' if contextually appropriate).

    /**
     * @description Processes a list of Account IDs, demonstrating SOQL and DML in loops,
     * which are prime candidates for auto-bulkification.
     * @param accountIds A list of Account IDs to process.
     */
    public static void processAccountsForAutoFix(List<Id> accountIds) {
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }

        for (Id accId : accountIds) {
            // Issue 2: SOQL query inside a loop.
            // Expected Auto-fix: Bulkify this query (e.g., query all at once using IN clause and store in a Map).
            Account acc = [SELECT Id, Name, Description FROM Account WHERE Id = :accId LIMIT 1];

            if (acc != null) {
                acc.Description = 'Processed by AutoFix Test';
                // Issue 3: DML operation inside a loop.
                // Expected Auto-fix: Collect accounts into a list and perform DML outside the loop.
                update acc;

                // Issue 4: System.debug inside a loop.
                // Expected Auto-fix: Remove or aggregate debug statements outside the loop.
                System.debug('Account ' + acc.Id + ' processed.');
            }
        }
    }

    /**
     * @description Demonstrates an empty catch block and an unused variable/parameter.
     * @param inputString A string parameter.
     */
    public static void demonstrateSimpleFixes(String inputString) { // Issue 5: Unused parameter.
                                                                    // Expected Auto-fix: Remove unused parameter.
        String tempVariable = 'Some value'; // Issue 6: Unused local variable.
                                             // Expected Auto-fix: Remove unused variable.

        try {
            Integer result = Integer.valueOf('abc'); // This will cause a System.TypeException
            System.debug('Parsing result: ' + result);
        } catch (Exception e) {
            // Issue 7: Empty catch block.
            // Expected Auto-fix: Add logging for the exception (e.g., System.debug(e.getMessage());).
        }
    }

    /**
     * @description A method that could potentially be static if it doesn't use instance variables.
     * Issue 8: Non-static method that could be static.
     * Expected Auto-fix: Add 'static' keyword.
     * @return A simple string.
     */
    public String getNonStaticString() {
        return 'This method is not static.';
    }
}