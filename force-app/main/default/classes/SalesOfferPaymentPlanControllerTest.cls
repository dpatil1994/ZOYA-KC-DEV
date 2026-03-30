@IsTest 
public class SalesOfferPaymentPlanControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create and activate a standard pricebook for tests
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook; // This activates the standard pricebook in test context
    }
    
    @IsTest 
    public static void createSalesOfferWithAllData() {
        // Get the standard pricebook ID using Test.getStandardPricebookId()
        // This works because we activated it in setupTestData()
        Id stdPricebookId = Test.getStandardPricebookId();
        
        // Create a custom pricebook for testing
        Pricebook2 customPricebook = new Pricebook2(
            Name = 'Test Pricebook ' + DateTime.now().getTime(),
            IsActive = true
        );
        insert customPricebook;
        
        // Create product
        Product2 prod = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        insert prod;
        
        // Create pricebook entry for standard pricebook
        PricebookEntry stdPbe = new PricebookEntry(
            Pricebook2Id = stdPricebookId,
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true,
            UseStandardPrice = false
        );
        insert stdPbe;
        
        // Create pricebook entry for custom pricebook
        PricebookEntry customPbe = new PricebookEntry(
            Pricebook2Id = customPricebook.Id,
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert customPbe;
        
        // Create property
        Property__c prop = new Property__c(Name = 'Test Property');
        insert prop;
        
        // Create property unit
        Property_Unit__c unit = new Property_Unit__c(
            Name = '0101',
            Property__c = prop.Id,
            Original_Price__c = 1000000,
            Unit_Type__c = '1BED'
        );
        insert unit;
        
        // Create sales offer
        Sales_Offer__c offer = new Sales_Offer__c(
            Payment_Plan__c = '30% Down Payment – 4% Discount',
            Project__c = prop.Id,
            Property_Unit__c = unit.Id
        );
        insert offer;
        
                
        Test.startTest();
        
        // Set the current page parameters for controller
        PageReference pageRef = new PageReference('/apex/Sales_Offer_PaymentPlan');
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', offer.Id);
        
        // Initialize controller
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);
        SalesOfferPaymentPlanController controller = new SalesOfferPaymentPlanController(sc);
        Decimal downPayment = controller.getDownPaymentAmount();
        Decimal remaining = controller.getRemainingAmount();
         Integer remainingCount = controller.getRemainingInstallmentCount();
         Decimal discountDecimal = controller.getDiscountPercentDecimal();
        String discountStr = controller.getPaymentPlanDiscountPercent();
        Decimal totalPayment = controller.getTotalPaymentAmount();
        controller.setPdfFileName();
        Sales_Offer__c offer100 = new Sales_Offer__c(
            Payment_Plan__c = '100% Down Payment (No ROI) – 20% Discount',
            Project__c = prop.Id,
            Property_Unit__c = unit.Id
        );
        insert offer100;
        ApexPages.currentPage().getParameters().put('id', offer100.Id);
        SalesOfferPaymentPlanController controller100 = new SalesOfferPaymentPlanController(new ApexPages.StandardController(offer100));
        Test.stopTest();
    }
}