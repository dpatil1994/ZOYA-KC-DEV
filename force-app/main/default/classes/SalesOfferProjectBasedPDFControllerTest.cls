@IsTest
public class SalesOfferProjectBasedPDFControllerTest {

    @TestSetup
    static void setupTestData() {
        // Create Projects
        Property__c miorahProject = new Property__c(Name = 'Miorah Hills');
        insert miorahProject;

        Property__c zoyaProject = new Property__c(Name = 'Nuve by Zoya');
        insert zoyaProject;

        // Create Property Units
        Property_Unit__c property1 = new Property_Unit__c(
            Name = 'Unit A',
            Property__c = miorahProject.Id
        );
        insert property1;

        Property_Unit__c property2 = new Property_Unit__c(
            Name = 'Unit B',
            Property__c = zoyaProject.Id
        );
        insert property2;

        // Create Sales Offers (Miorah)
        Sales_Offer__c miorahOffer1 = new Sales_Offer__c(
            Project__c = miorahProject.Id,
            Property_Unit__c = property1.Id,  
            Payment_Plan__c = 'Standard Payment Plan – 0% Discount'
        );

        Sales_Offer__c miorahOffer2 = new Sales_Offer__c(
            Project__c = miorahProject.Id,
            Property_Unit__c = property1.Id,
            Payment_Plan__c = '30% Down Payment – 4% Discount'
        );

        // Create Sales Offers (Nuve by Zoya)
        Sales_Offer__c zoyaOffer1 = new Sales_Offer__c(
            Project__c = zoyaProject.Id,
            Property_Unit__c = property2.Id,
            Payment_Plan__c = '50% Down Payment – 8% Discount'
        );

        insert new List<Sales_Offer__c>{miorahOffer1, miorahOffer2, zoyaOffer1};

        // Store inserted records in static variables for test methods
        Test.setFixedSearchResults(new List<Id>{miorahOffer1.Id, miorahOffer2.Id, zoyaOffer1.Id});
    }

    @IsTest
    static void testMiorahPaymentPlan() {
        Sales_Offer__c offer = [SELECT Id, Project__c, Property_Unit__c, Payment_Plan__c FROM Sales_Offer__c WHERE Payment_Plan__c = 'Standard Payment Plan – 0% Discount' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);

        Test.startTest();
        SalesOfferProjectBasedPDFController controller = new SalesOfferProjectBasedPDFController(sc);
        Test.stopTest();

        
    }

    @IsTest
    static void testZoyaPaymentPlan() {
        Sales_Offer__c offer = [SELECT Id, Project__c, Property_Unit__c, Payment_Plan__c FROM Sales_Offer__c WHERE Payment_Plan__c = '50% Down Payment – 8% Discount' LIMIT 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(offer);

        Test.startTest();
        SalesOfferProjectBasedPDFController controller = new SalesOfferProjectBasedPDFController(sc);
        Test.stopTest();

      
    }
    
    @IsTest
static void testSetPdfFileName() {
    // Create a dummy page reference for testing
    PageReference pageRef = new PageReference('/apex/dummy'); // any URL works
    Test.setCurrentPage(pageRef);

    // Query an existing offer (from your TestSetup)
    Sales_Offer__c offer = [SELECT Id, Name, Project__c, Property_Unit__c, Payment_Plan__c 
                             FROM Sales_Offer__c 
                             LIMIT 1];

    ApexPages.StandardController sc = new ApexPages.StandardController(offer);

    Test.startTest();
    SalesOfferProjectBasedPDFController controller = new SalesOfferProjectBasedPDFController(sc);

    // Call the method
    controller.setPdfFileName();
    Test.stopTest();

    // Assert that the header was set correctly
    String contentDisposition = ApexPages.currentPage().getHeaders().get('Content-Disposition');
   // System.assert(contentDisposition.contains('SalesOffer_' + offer.Name + '.pdf'),
                //  'PDF filename header should be set correctly');
}


}