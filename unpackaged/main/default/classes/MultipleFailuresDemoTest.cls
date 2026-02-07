@IsTest
private class MultipleFailuresDemoTest {
    /*
     * Apex stops a single test method at the first failed System.assert*.
     * So to get “multiple failures” in a test run, you typically:
     *   (A) create multiple failing test methods (each fails independently), and/or
     *   (B) use a “soft assert” collector and fail once at the end with all issues.
     *
     * This class demonstrates BOTH.
     */

    // ---------------------------
    // A) Multiple failing methods
    // ---------------------------

    @IsTest
    static void fails_on_assert_1() {
        // Intentionally wrong
        System.assertEquals(1, 2, 'Failure #1: 1 != 2');
    }

    @IsTest
    static void fails_on_assert_2() {
        // Intentionally wrong
        System.assertEquals('foo', 'bar', 'Failure #2: foo != bar');
    }

    @IsTest
    static void fails_on_assert_3() {
        // Intentionally wrong
        System.assertNotEquals(null, null, 'Failure #3: expected not-null');
    }

    // -----------------------------------------
    // B) “Soft assert” in ONE method (aggregated)
    // -----------------------------------------

    @IsTest
    static void fails_with_aggregated_failures() {
        SoftAssert sa = new SoftAssert();

        // These all get evaluated; failures are collected instead of stopping immediately.
        sa.equals(10, 20, 'Expected 10');
        sa.isTrue(false, 'Expected true');
        sa.notEquals('A', 'A', 'Expected values to differ');

        // Fail once with a message that includes all the problems.
        sa.assertNoFailures();
    }

    // Minimal soft-assert helper
    private class SoftAssert {
        private List<String> failures = new List<String>();

        void isTrue(Boolean condition, String message) {
            if (condition != true) failures.add(message);
        }

        void equals(Object expected, Object actual, String message) {
            if (expected == null && actual == null) return;
            if (expected == null || actual == null || expected != actual) {
                failures.add(message + ' (expected=' + expected + ', actual=' + actual + ')');
            }
        }

        void notEquals(Object left, Object right, String message) {
            if (left == null && right == null) {
                failures.add(message + ' (both null)');
                return;
            }
            if (left != null && left == right) {
                failures.add(message + ' (both=' + left + ')');
            }
        }

        void assertNoFailures() {
            if (!failures.isEmpty()) {
                String msg = 'Multiple assertion failures (' + failures.size() + '):\n- '
                    + String.join(failures, '\n- ');
                System.assert(false, msg);
            }
        }
    }
}