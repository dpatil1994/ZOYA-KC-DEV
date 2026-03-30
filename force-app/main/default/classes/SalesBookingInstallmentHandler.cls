public class SalesBookingInstallmentHandler {
    
    public static void generateInstallments(List<Opportunity> newOpps) {
        
        if (newOpps == null || newOpps.isEmpty()) {
            return;
        }
        
        Set<Id> oppIds = new Set<Id>();
        Set<Id> unitIds = new Set<Id>();
        
        for (Opportunity opp : newOpps) {
            oppIds.add(opp.Id);
            if (opp.Customer_Unit_Name__c != null) {
                unitIds.add(opp.Customer_Unit_Name__c);
            }
        }
        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>([
            SELECT Id,
            CloseDate,
            Customer_Unit_Name__c,
            Payment_Plan__c,
           	Payment_Plan__r.Name,
			Payment_Plan__r.Number_of_Installment__c,
            Payment_Plan__r.Discount_Percent__c,
            Payment_Plan__r.Down_Payment__c,
            Payment_Plan__r.Installment_Days_Range__c
            FROM Opportunity
            WHERE Id IN :oppIds
        ]);
        
        Map<Id, Property_Unit__c> unitMap = new Map<Id, Property_Unit__c>([
            SELECT Id, Original_Price__c
            FROM Property_Unit__c
            WHERE Id IN :unitIds
        ]);
        
        Map<Id, Integer> existingMap = new Map<Id, Integer>();
        
        for (AggregateResult ar : [
            SELECT Sales_Booking__c oppId, COUNT(Id) cnt
            FROM Installment__c
            WHERE Sales_Booking__c IN :oppIds
            GROUP BY Sales_Booking__c
        ]) {
            existingMap.put((Id) ar.get('oppId'), (Integer) ar.get('cnt'));
        }
        
        List<Installment__c> installmentsToInsert = new List<Installment__c>();
        
        for (Opportunity opp : oppMap.values()) {
            
            if (existingMap.containsKey(opp.Id)) {
                continue;
            }
            
            if (opp.Payment_Plan__c == null || opp.Payment_Plan__r == null) {
                continue;
            }
            
            Integer totalInstallments = (Integer) opp.Payment_Plan__r.Number_of_Installment__c;
            Decimal discountPercent   = opp.Payment_Plan__r.Discount_Percent__c != null 
                ? opp.Payment_Plan__r.Discount_Percent__c : 0;
            Decimal downPayment       = opp.Payment_Plan__r.Down_Payment__c != null 
                ? opp.Payment_Plan__r.Down_Payment__c : 0;
            
            // ✅ FIXED HERE
            Integer dayGap = extractDays(opp.Payment_Plan__r.Installment_Days_Range__c);
            
            if (totalInstallments == null || totalInstallments <= 0) {
                continue;
            }
            
            Property_Unit__c unit = unitMap.get(opp.Customer_Unit_Name__c);
            if (unit == null || unit.Original_Price__c == null) {
                continue;
            }
            
            Decimal sellingPrice = unit.Original_Price__c;
            
            Decimal discountedPrice = sellingPrice * (1 - (discountPercent / 100));
            
            List<Decimal> percentages = new List<Decimal>();
            
            Decimal totalAssigned = 0;
            
            for (Integer i = 1; i <= totalInstallments; i++) {
                
                Decimal percent;
                
                if (i == 1) {
                    // ✅ Down Payment (as defined in Payment Plan)
                    percent = downPayment;
                }
                else if (i == 30 && totalInstallments >= 30) {
                    // ✅ 30th Installment Fixed
                    percent = 10;
                }
                else if (i == totalInstallments) {
                    // ✅ Last Installment Fixed
                    percent = 5;
                }
                else {
                    // ✅ All Remaining Installments
                    percent = 1;
                }
                
                percentages.add(percent);
                totalAssigned += percent;
            }
            
            List<Date> dates = new List<Date>();
            
            Date baseDate = opp.CloseDate != null ? opp.CloseDate : Date.today();
            Date currentDate = baseDate;
            
            // Identify if this is the special payment plan
            Boolean isStandardPlan = opp.Payment_Plan__r.Name == 'Standard Payment Plan – 0% Discount';
            
            for (Integer i = 1; i <= totalInstallments; i++) {
                
                if (i == 1) {
                    // Down Payment → Today / CloseDate
                    dates.add(currentDate);
                }
                else if (i == 2 && isStandardPlan) {
                    // Special Rule → 45 Days after Down Payment
                    currentDate = baseDate.addDays(45);
                    dates.add(currentDate);
                }
                else {
                    // All remaining installments → Monthly Increase
                    currentDate = currentDate.addMonths(1);
                    dates.add(currentDate);
                }
            }
            
            for (Integer i = 0; i < totalInstallments; i++) {
                
                Installment__c inst = new Installment__c();
                inst.Sales_Booking__c = opp.Id;
                
                Integer installmentNumber = i + 1;
                
                // 🔥 UPDATED NAMING LOGIC
                if (installmentNumber == 1) {
                    inst.Name = 'Down Payment - Installment 1';
                }
                else if (installmentNumber == 30) {
                    inst.Name = 'Installment 30 (Handover)';
                }
                else {
                    inst.Name = 'Installment ' + installmentNumber;
                }
                
                inst.Date__c = dates[i];
                inst.of_Payment__c = percentages[i];
                inst.Amounts__c = (percentages[i] / 100) * discountedPrice;
                
                installmentsToInsert.add(inst);
            }
        }
        
        if (!installmentsToInsert.isEmpty()) {
            insert installmentsToInsert;
        }
    }
    
    private static Integer extractDays(String value) {
        
        if (String.isBlank(value)) {
            return 30;
        }
        
        // Extract numeric part only
        String numeric = value.replaceAll('[^0-9]', '');
        
        if (String.isBlank(numeric)) {
            return 30;
        }
        
        Integer parsedValue = Integer.valueOf(numeric);
        
        // Convert years → days if text contains 'Year'
        if (value.toLowerCase().contains('year')) {
            return parsedValue * 365;
        }
        
        return parsedValue;
    }
}