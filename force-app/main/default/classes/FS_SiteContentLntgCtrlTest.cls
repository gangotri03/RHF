@isTest
private class FS_SiteContentLntgCtrlTest {
    
    @isTest static void validateController(){
        Test.startTest();
        Set<String> customerUserTypes = new Set<String> {'CspLitePortal'};
            Account acc = new Account (
                Name = 'newAcc1'
            );  
        insert acc;
        Contact con = new Contact (
            AccountId = acc.id,
            LastName = 'portalTestUser'
        );
        insert con;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        User newUser;
        System.runAs ( thisUser ) {
            //UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType ='CustomerPortal' limit 1];
            Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
            
             newUser = new User(
              
                profileId = p.id,
                username = 'newUser@yahoo.com',
                email = 'pb@ff.com',
                emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',
                languagelocalekey = 'en_US',
                timezonesidkey = 'America/Los_Angeles',
                alias='nuser',
                lastname='lastname',
                contactId = con.id
            );
            insert newUser;  
        }
        System.runAs(newUser){ 
        	FS_SiteContentLntgCtrl.fetchContactInfo();
        }
        Test.stopTest();
    }
}