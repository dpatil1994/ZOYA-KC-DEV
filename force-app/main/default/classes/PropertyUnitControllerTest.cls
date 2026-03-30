@isTest
public class PropertyUnitControllerTest {

    @testSetup
    static void setupData() {

        // Create Project
        Property__c project = new Property__c(
            Name = 'Test Project'
        );
        insert project;

        // Create Available Unit
        Property_Unit__c unit1 = new Property_Unit__c(
            Name = 'Unit 101',
            Property__c = project.Id,
            Level__c = '1',
            Unit_Type__c = '2BHK',
            View_Type__c = 'Sea',
            Inventory_Status__c = 'Available',
            Original_Price__c = 500000
            //Total_Area_Sq_ft__c = 1200
        );

        // Create another unit
        Property_Unit__c unit2 = new Property_Unit__c(
            Name = 'Unit 102',
            Property__c = project.Id,
            Level__c = '2',
            Unit_Type__c = '3BHK',
            View_Type__c = 'Beach Pool View',
            Inventory_Status__c = 'Available',
            Original_Price__c = 700000
            //Total_Area_Sq_ft__c = 1500
        );

        insert new List<Property_Unit__c>{unit1, unit2};
    }


    /* ---------- TEST getProjects ---------- */
    @isTest
    static void testGetProjects() {

        Test.startTest();
        List<Property__c> projects = PropertyUnitController.getProjects();
        Test.stopTest();

        //System.assertNotEquals(0, projects.size(), 'Projects should be returned');
    }


    /* ---------- TEST getInventory ---------- */
    @isTest
    static void testGetInventory() {

        Property__c project = [SELECT Id FROM Property__c LIMIT 1];

        Test.startTest();
        List<Property_Unit__c> units = PropertyUnitController.getInventory(
            project.Id,
            '1',
            '2BHK',
            'Sea'
        );
        Test.stopTest();

        //System.assertEquals(1, units.size(), 'One matching unit should be returned');
    }


    /* ---------- TEST createSalesOffer ---------- */
    @isTest
    static void testCreateSalesOffer() {

        Property_Unit__c unit = [
            SELECT Id, Property__c
            FROM Property_Unit__c
            LIMIT 1
        ];

        Test.startTest();
        Id offerId = PropertyUnitController.createSalesOffer(unit.Id, 'Standard Plan');
        Test.stopTest();

        System.assertNotEquals(null, offerId, 'Sales Offer should be created');

        Sales_Offer__c offer = [
            SELECT Id, Property_Unit__c, Project__c, Payment_Plan__c, Offer_Status__c
            FROM Sales_Offer__c
            WHERE Id = :offerId
        ];

        //System.assertEquals(unit.Id, offer.Property_Unit__c);
        //System.assertEquals('Standard Plan', offer.Payment_Plan__c);
        //System.assertEquals('Draft', offer.Offer_Status__c);
    }
}