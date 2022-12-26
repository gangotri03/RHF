/*
@desc	controller class for the site homPage- sitecontent component controller
*/
public class FS_SiteContentLntgCtrl {
    @auraEnabled
    public static Contact fetchContactInfo(){
        User u = [select id, contactId from User where id = : UserInfo.getUserId()];
        system.debug('contactId' + u.ContactId);
        Contact oContact = [SELECT Id,Name, firstName, lastName, Email From Contact WHERE Id =:u.contactId];
        return oContact;
    }
}