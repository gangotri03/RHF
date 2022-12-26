@isTest
private class API_RHIDCallTest {
     @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Account acc = new Account();
        acc.Name = 'Test Account';
        upsert acc;
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        upsert con;
        RHSP_Order__c obj = new RHSP_Order__c();
        obj.Name = 'Test Order';
        upsert obj;
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User usr = new User(Alias = 'standt', Email='standarduser@testrhf.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testrhf.com');
        insert usr;
        System.runAs(usr)
        {
        con.AccountId = acc.Id;
        con.npsp__Primary_Affiliation__c = acc.Id;
        con.Ambassador__c = true;
        con.AmbassadorPublic__c = true;
        upsert con;
        obj.Status__c = 'Completed';
        upsert obj;
        }
        upsert acc;
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        List<String> jsonStrList = new List<String>();
        jsonStrList.add(''); 
        API_RHIDCall.APICall_Secure('',jsonStrList);
        
        // Verify response received contains fake values
        //String contentType = res.getHeader('Content-Type');
        //System.assert(contentType == 'application/json');
        //String actualValue = res.getBody();
        //String expectedValue = '{"foo":"bar"}';
        //System.assertEquals(actualValue, expectedValue);
        //System.assertEquals(200, res.getStatusCode());
    }
}