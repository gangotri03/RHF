@isTest
private class FluidReview_UpsertTriggerTest2018 {

  public static testmethod void testmethod1() {
    // Set mock callout class
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    Account acc = new Account();
    acc.Name = 'testorg';
    upsert acc;
    Contact con = new Contact();
    con.Email = 'bob@tester.com';
    con.LastName = 'tester';
    upsert con;
  }
  public static testmethod void testmethod2() {
    // Set mock callout class
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    RHF_FluidReview__c flu4 = new RHF_FluidReview__c();
    flu4.ReferenceID__c = 'BB-0004';
    flu4.Group__c = 'Accessible Cities Award';
    flu4.ACAContactEmail__c = 'aob@tester.com';
    flu4.ACAContactFullName__c = 'aob tester';
    flu4.FirstName__c = 'aob';
    flu4.LastName__c = 'tester';
    flu4.ACAMunicipalityName__c = 'Vancouver';
    flu4.Status__c = 'Review';
    flu4.ACACircleofExcellenceName1__c = '1';
    flu4.ACACircleofExcellenceName2__c = '2';
    flu4.ACACircleofExcellenceName3__c = '3';
    flu4.ACACircleofExcellenceName4__c = '4';
    flu4.ACACircleofExcellenceName5__c = '5';
    flu4.ACACircleofExcellenceAddress1__c = '1';
    flu4.ACACircleofExcellenceAddress2__c = '2';
    flu4.ACACircleofExcellenceAddress3__c = '3';
    flu4.ACACircleofExcellenceAddress4__c = '4';
    flu4.ACACircleofExcellenceAddress5__c = '5';
    upsert flu4;
    upsert flu4;
  }
}