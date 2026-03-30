@IsTest
public class SalesBookingInstallmentHandlerTest {
 @IsTest
     static void testGenerateInstallments() {
        
        Payment_Plan__c plan = new Payment_Plan__c(
            Name = 'Standard Payment Plan – 0% Discount',
            Number_of_Installment__c = 30,
            Discount_Percent__c = 0,
            Down_Payment__c = 10,
            Installment_Days_Range__c = '1 Month'
        );
        insert plan;
        
         Property__c prop = new Property__c();
         prop.Name = 'Test 0123';
         insert prop;
         
        Property_Unit__c unit = new Property_Unit__c(
            Name = 'Test Unit',
            Original_Price__c = 100000,
            Property__c = prop.id
        );
        insert unit;
        
        Opportunity opp = new Opportunity(
            Name = 'Test Sales Booking',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            Payment_Plan__c = plan.Id,
            Customer_Unit_Name__c = unit.Id,
            Mode_of_Payment__c = 'cash',
            Project_Name__c = prop.Id
        );
        insert opp;
        
        Test.startTest();
        
        SalesBookingInstallmentHandler.generateInstallments(
            new List<Opportunity>{opp}
        );
        
        Test.stopTest();
        
        List<Installment__c> instList = [
            SELECT Id, Name, Date__c, of_Payment__c, Amounts__c, Sales_Booking__c
            FROM Installment__c
            WHERE Sales_Booking__c = :opp.Id
        ];
        
        System.assertEquals(30, instList.size(), '30 Installments should be created');
        
        Installment__c firstInst = instList[0];
        System.assertEquals('Down Payment - Installment 1', firstInst.Name);
        
        Installment__c lastInst = instList[29];
        System.assertEquals('Installment 30 (Handover)', lastInst.Name);
        
        System.assertNotEquals(null, firstInst.Date__c);
        System.assertNotEquals(null, firstInst.Amounts__c);
    }
    
    @IsTest
    static void testNoInstallmentsWhenPaymentPlanMissing() {
        
         Property__c prop1 = new Property__c();
         prop1.Name = 'Test 0123';
         insert prop1;
        
        Property_Unit__c unit = new Property_Unit__c(
            Name = 'Unit Without Plan',
            Original_Price__c = 50000,
            Property__c = prop1.id
        );
        insert unit;
        
       Opportunity opp = new Opportunity(
    Name = 'Opportunity No Plan',
    StageName = 'Prospecting',
    CloseDate = Date.today(),
    Customer_Unit_Name__c = unit.Id,
    Mode_of_Payment__c = 'cash',
    Project_Name__c = prop1.Id
);
        insert opp;
        
        Test.startTest();
        SalesBookingInstallmentHandler.generateInstallments(
            new List<Opportunity>{opp}
        );
        Test.stopTest();
        
        List<Installment__c> instList = [
            SELECT Id FROM Installment__c
            WHERE Sales_Booking__c = :opp.Id
        ];
        
        System.assertEquals(0, instList.size(), 'No installments should be created');
    }
}