@isTest
private class FluidReview_BCGrantTriggerTest {
    public static testmethod void testmethod1() {
    
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account();
        acc.Name = 'testorg';
        upsert acc;
        Contact con = new Contact();
        con.LastName = 'tester';
        upsert con;
        Building__c blu = new Building__c();
        blu.Site_Name__c = 'Test Building';
        blu.Site_Street_Address__c = 'Test St';
        blu.Site_City__c = 'Test City';
        blu.Site_Province__c = 'BC';
        blu.Site_Postal_Code__c = 'V0T 0T0';
        blu.Account__c = acc.Id;
        blu.Contact_to_Sign_Service_Agreement__c = con.Id;
        blu.On_Site_Contact__c = con.Id;
        blu.Scorecard_Reference_Number__c = 'RHF-123-test0';
        upsert blu;
        
        BCGrant__c flu = new BCGrant__c();
        flu.ReferenceID__c = 'BAG-test824002';
        flu.Name = 'Test Outbound Grant';
        flu.CRA_Business_Number__c = 'test51234RT0002';
        flu.CRA_Business_Type__c = 'Non-profit';
        flu.Requested_Amount__c = 5000;
        flu.First_Name__c = 'TestF';
        flu.Last_Name__c = 'TestL';
        flu.Work_Email__c = 'test@test.com';
        flu.Scorecard_Reference_Number__c = 'RHF-123-test0';
        flu.Facebook_Page__c = 'Testfacebookpage';
        flu.LinkedIn_Page__c = 'Testlinkedpage';
        flu.Twitter_Handle__c = 'Testtwitterpage';
        
        upsert flu;
        upsert flu;
    }
}