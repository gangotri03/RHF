@isTest
public class Test_Venue {

    static Boolean isInstalled = false;
 
    private static void install() {  
        if (!isInstalled) {
            Framework.Installer.install();
            PagesApi.PackageScripts.install();
            OrderApi.PackageScripts.install();
            EventApi.PackageScripts.install();
            new PackageScripts.install().run();
            isInstalled = true; 
        }
    }
    
    private static String timezone = 'America/Adak';
    static EventApi__Event_Category__c cat = new EventApi__Event_Category__c(); 
    static EventApi__Event__c ev = new EventApi__Event__c();
    static EventApi__Venue__c vn = new EventApi__Venue__c();
    
    private static void createTestData() {
        
        cat.Name = 'Test Event Category';
        cat.EventApi__Description__c = 'Test Desc';
        insert cat;

        ev.EventApi__Event_Category__c = cat.Id;
        ev.Name = 'Test Event';
        ev.EventApi__Event_Key__c = 'ABCD';
        ev.EventApi__Attendees__c = 10;
        ev.EventApi__Capacity__c = 100;
        ev.EventApi__Enable_Access_Permissions__c = false;
        ev.EventApi__Enable_Registration_Groups__c = true;
        ev.EventApi__Enable_Sponsors__c = true;
        ev.EventApi__Enable_Waitlist__c = true;
        ev.EventApi__Enable_Schedule_Items__c = true;
        ev.EventApi__Is_Active__c = true;
        ev.EventApi__Is_Published__c = true;
        ev.EventApi__Registration_Instructions__c = 'Test Instructions';
        ev.EventApi__Registration_Style__c = 'Conference';
        ev.EventApi__Status__c = 'Planned';
        ev.EventApi__Ticket_Sales_Start_Date__c = Date.today();
        ev.EventApi__Time_Zone__c = '(GMT-10:00) '+timezone;
        ev.EventApi__Waitlist_Entries__c = 10;
        ev.EventApi__Start_Date_Time__c = Datetime.now().addDays(3);
        ev.EventApi__Start_Date__c = Date.today().addDays(3);
        ev.EventApi__Start_Time__c = '09:00 AM';
        ev.EventApi__End_Date__c = Date.today().addDays(7);
        ev.EventApi__End_Date_Time__c = Datetime.now().addDays(7);
        ev.EventApi__End_Time__c = '09:00 AM';
        insert ev;
        
        vn.EventApi__Event__c = ev.Id;
        vn.Name = 'Test Venue';
        vn.EventApi__Description__c = 'test Description';
        vn.EventApi__Street__c = 'test street';
        vn.EventApi__State__c = 'test state';
        vn.EventApi__Postal_Code__c = '73624';
        vn.EventApi__city__c = 'test city';
        vn.EventApi__Phone__c = '9238490238';
        vn.EventApi__Website__c = 'test.salesforce.com';
        vn.EventApi__Is_Primary_Venue__c = true;
        insert vn;
        
    }
    
    @isTest
    static void test_EventNameOnReceipt() {
        install();
        createTestData();
        
        update vn;
        ev = [SELECt Primary_Venue__c FROM EventApi__Event__c WHERe Id=: ev.Id];
        System.assertNotEquals(null, ev.Primary_Venue__c);
    }
}