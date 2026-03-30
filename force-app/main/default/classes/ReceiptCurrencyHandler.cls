public class ReceiptCurrencyHandler {
    public static void handleCurrency(List<Receipt__c> receipts) {
        for (Receipt__c rec : receipts) {
            if (rec.Amount_in_Currency__c != null && rec.Currency__c != null) {

                // Remove existing currency prefix if any
                String amountOnly = rec.Amount_in_Currency__c.replaceAll('^[A-Z]{3}\\s', '');

                // Add currency prefix
                rec.Amount_in_Currency__c = rec.Currency__c + ' ' + amountOnly;
            }
        }
    }
}