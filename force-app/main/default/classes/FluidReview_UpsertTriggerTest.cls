@isTest
private class FluidReview_UpsertTriggerTest {

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
    RHF_FluidReview__c flu = new RHF_FluidReview__c();
    flu.ReferenceID__c = 'BB-0000';
    flu.Group__c = 'Barrier Buster Grants';
    flu.OrganizationName__c = 'testorg';
    flu.ContactEmail__c = 'bob@tester.com';
    flu.FullName__c = 'bob tester';
    flu.FirstName__c = 'bob';
    flu.LastName__c = 'tester';
    flu.ProjectName__c = 'Accessible Door';
    upsert flu;
    upsert flu;
    RHF_FluidReview__c flu1 = new RHF_FluidReview__c();
    flu1.ReferenceID__c = 'BB-0001';
    flu1.Group__c = 'Barrier Buster Grants';
    flu1.OrganizationName__c = 'testschool';
    flu1.ContactEmail__c = 'rob@tester.com';
    flu1.FullName__c = 'rob tester';
    flu1.FirstName__c = 'rob';
    flu1.LastName__c = 'tester';
    flu1.ProjectName__c = 'Accessible Washroom';
    flu1.Status__c = 'Approved and 90% Payment';
    flu1.AwarenessEventDescription__c = 'Promote Awareness';
    flu1.AwarenessEventProposedDate__c = Date.newInstance(2017, 9, 1);
    upsert flu1;
    Account acc1 = new Account();
    acc1.Name = 'testSchool';
    acc1.BillingCity = 'Vancouver';
    acc1.BillingState = 'British Columbia';
    upsert acc1;
  }
  public static testmethod void testmethod2() {
    // Set mock callout class
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    RHF_FluidReview__c flu2 = new RHF_FluidReview__c();
    flu2.ReferenceID__c = 'BB-0002';
    flu2.Group__c = 'Youth Summit';
    flu2.YLSContactEmail__c = 'fob@tester.com';
    flu2.YLSFullName__c = 'fob tester';
    flu2.FirstName__c = 'fob';
    flu2.LastName__c = 'tester';
    flu2.YLSSchoolName__c = 'testSchool';
    flu2.YLSBillingCity__c = 'Vancouver';
    flu2.YLSBillingState__c = 'British Columbia';
    upsert flu2;
    RHF_FluidReview__c flu3 = new RHF_FluidReview__c();
    flu3.ReferenceID__c = 'BB-0003';
    flu3.Group__c = 'Youth Summit';
    flu3.YLSContactEmail__c = 'yob@tester.com';
    flu3.YLSFullName__c = 'yob tester';
    flu3.FirstName__c = 'yob';
    flu3.LastName__c = 'tester';
    flu3.YLSSchoolName__c = 'ABC School';
    flu3.YLSBillingCity__c = 'Vancouver';
    flu3.YLSBillingState__c = 'British Columbia';
    upsert flu3;
    flu3.YLSAge__c = '18';
    flu3.YLSDisability__c = 'Yes';
    flu3.YLSDisabilityDescribe__c = 'hearing';
    upsert flu3;
    RHF_FluidReview__c flu4 = new RHF_FluidReview__c();
    flu4.ReferenceID__c = 'BB-0004';
    flu4.Group__c = 'Accessible Cities Award';
    flu4.ACAContactEmail__c = 'aob@tester.com';
    flu4.ACAContactFullName__c = 'aob tester';
    flu4.FirstName__c = 'aob';
    flu4.LastName__c = 'tester';
    flu4.ACAMunicipalityName__c = 'Vancouver';
    flu4.Status__c = 'Review';
    flu4.ACACircleofExcellenceNomination1__c = '1';
    flu4.ACACircleofExcellenceNomination2__c = '2';
    flu4.ACACircleofExcellenceNomination3__c = '3';
    flu4.ACACircleofExcellenceNomination4__c = '4';
    flu4.ACACircleofExcellenceNomination5__c = '5';
    upsert flu4;
    upsert flu4;
  }
}