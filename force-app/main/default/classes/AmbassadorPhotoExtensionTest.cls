@isTest
private class AmbassadorPhotoExtensionTest {
     @isTest static void testCallout() {

        Contact currentContact = new Contact();
        currentContact.LastName = 'Test Contact'; 
        currentContact.RHID__c = 'testrhid';
        AmbassadorPhotoExtension ext = new AmbassadorPhotoExtension(new ApexPages.StandardController(currentContact));
        ext.picture = EncodingUtil.base64Decode('c2Rm');
        PageReference pr = ext.save();

    }
}