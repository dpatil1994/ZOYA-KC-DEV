public with sharing class PaymentScheduleService {

    @AuraEnabled
    public static void generateSchedule(Id salesOfferId) {
        System.debug('salesOfferId --> ' + salesOfferId);

        // Null check
        if (salesOfferId == null) {
            throw new AuraHandledException('Invalid record. Please refresh the page.');
        }

        // Fetch Sales Offer record including Net Price
        Sales_Offer__c so = [
            SELECT Id, Payment_Plan__c, Net_Price__c
            FROM Sales_Offer__c
            WHERE Id = :salesOfferId
            LIMIT 1
        ];

        if (so == null) {
            throw new AuraHandledException('Sales Offer not found.');
        }

        if (String.isBlank(so.Payment_Plan__c)) {
            throw new AuraHandledException('Payment Plan is not selected.');
        }

        // ----------------------------------------------------------
        // Check installments only for THIS Payment Plan
        // ----------------------------------------------------------
        Integer existingCount = [
            SELECT COUNT()
            FROM Installment__c
            WHERE Sales_Offer__c = :salesOfferId
            AND Payment_Plan__c = :so.Payment_Plan__c
        ];

        if (existingCount > 0) {
            throw new AuraHandledException(
                'Installments already exist for Payment Plan: ' + so.Payment_Plan__c
            );
        }

        // ----------------------------------------------------------
        // Determine number of Installments and first % based on Payment Plan
        // ----------------------------------------------------------
        Integer totalCount;
        Decimal firstPercent;

        if (so.Payment_Plan__c == 'Standard Payment Plan – 0% Discount') {
            totalCount = 69;
            firstPercent = 10;
        }
        else if (so.Payment_Plan__c == '30% Down Payment – 4% Discount') {
            totalCount = 58;
            firstPercent = 30;
        }
        else if (so.Payment_Plan__c == '50% Down Payment – 8% Discount') {
            totalCount = 38;
            firstPercent = 50;
        }
        else if (so.Payment_Plan__c == '100% Down Payment (No ROI) – 20% Discount') {
            totalCount = 1;
            firstPercent = 100;
        }
        else {
            throw new AuraHandledException('Unsupported Payment Plan selected.');
        }

        // ----------------------------------------------------------
        // Generate Installment records
        // ----------------------------------------------------------
        List<Installment__c> lstInstall = new List<Installment__c>();

        for (Integer i = 1; i <= totalCount; i++) {

            Installment__c inst = new Installment__c();
            inst.Sales_Offer__c = so.Id;
            inst.Payment_Plan__c = so.Payment_Plan__c;
            inst.Name = 'Down Payment - Installment ' + i;

            // -----------------------------------------
            // PERCENT LOGIC
            // -----------------------------------------
            if (totalCount == 1) {
                inst.of_Payment__c = 100;
            }
            else if (i == 1) {
                inst.of_Payment__c = firstPercent;
            }
            else if ((so.Payment_Plan__c == 'Standard Payment Plan – 0% Discount' && i == 30) ||
                     (so.Payment_Plan__c == '30% Down Payment – 4% Discount' && i == 30) ||
                     (so.Payment_Plan__c == '50% Down Payment – 8% Discount' && i == 30)) {
                inst.of_Payment__c = 10;
            }
            else if ((so.Payment_Plan__c == 'Standard Payment Plan – 0% Discount' && i == totalCount) ||
                     (so.Payment_Plan__c == '30% Down Payment – 4% Discount' && i == totalCount) ||
                     (so.Payment_Plan__c == '50% Down Payment – 8% Discount' && i == totalCount)) {
                inst.of_Payment__c = (so.Payment_Plan__c == '50% Down Payment – 8% Discount') ? 5 : 5;
            }
            else {
                inst.of_Payment__c = 1;
            }

            // -----------------------------------------
            // AMOUNT CALCULATION
            // -----------------------------------------
            inst.Amounts__c = (inst.of_Payment__c / 100) * so.Net_Price__c;

            // -----------------------------------------
            // DATE LOGIC — for all plans
            // -----------------------------------------
            if (so.Payment_Plan__c == 'Standard Payment Plan – 0% Discount') {

                if (i == 1) {
                    inst.Date__c = Date.newInstance(2025, 12, 1);
                }
                else if (i == 2) {
                    inst.Date__c = Date.newInstance(2026, 2, 15);
                }
                else {
                    inst.Date__c = Date.newInstance(2026, 2, 15).addMonths(i - 2);
                }
            }
            else if (so.Payment_Plan__c == '30% Down Payment – 4% Discount') {

                if (i == 1) {
                    inst.Date__c = Date.newInstance(2025, 12, 1);
                }
                else {
                    inst.Date__c = Date.newInstance(2026, 1, 1).addMonths(i - 2);
                }
            }
            else if (so.Payment_Plan__c == '50% Down Payment – 8% Discount') {

                if (i == 1) {
                    inst.Date__c = Date.newInstance(2025, 12, 1);
                }
                else {
                    inst.Date__c = Date.newInstance(2026, 1, 1).addMonths(i - 2);
                }
            }
            else if (so.Payment_Plan__c == '100% Down Payment (No ROI) – 20% Discount') {
                // Only one installment
                inst.Date__c = Date.newInstance(2025, 12, 1);
            }

            lstInstall.add(inst);
        }

        insert lstInstall;
    }
}