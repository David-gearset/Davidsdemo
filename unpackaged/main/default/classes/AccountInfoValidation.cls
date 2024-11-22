public class AccountInfoValidation {
    static final Integer MINIMUM_LENGTH = 3;
    static final Integer MAXIMUM_LENGTH = 20;

    public Boolean IsValidAccountName(String name) {
        return (name.length() >= MINIMUM_LENGTH && name.length() <= MAXIMUM_LENGTH);
    }
}