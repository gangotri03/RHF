@isTest
public class Test_EventRegistrationControllerUnmgd {
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
    static EventApi__Site_Event_Category__c er=new EventApi__Site_Event_Category__c();
    static EventApi__Event__c ev = new EventApi__Event__c();
    static EventApi__Ticket_Type__c tt = new EventApi__Ticket_Type__c();
    static EventApi__Attendee__c at = new EventApi__Attendee__c();
    static PagesApi__Form__c testForm = new PagesApi__Form__c();
    static PagesApi__Field_Group__c fg = new PagesApi__Field_Group__c();
    static PagesApi__Form_Response__c formResponse = new PagesApi__Form_Response__c();
  	static PagesApi__Site__c ps = new PagesApi__Site__c();
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
        ev.Send_Reminder_Emails__c=True;
        insert ev;
        ps.Name='Test';
        insert ps;
  	  	er.EventApi__Event_Category__c=cat.Id;
        er.EventApi__Site__c=ps.Id;
       	insert er;
        tt.EventApi__Event__c = ev.Id;
        tt.Name = 'Test Item Name';
        tt.EventApi__UOM__c = 'Ticket';
        tt.EventApi__Price__c = 100.00;
        tt.EventApi__Cost__c = 100.00;
        tt.EventApi__Description__c = 'Test Description';
        tt.EventApi__Display_Available_Inventory__c = true;
        tt.EventApi__Early_Bird_End_Date__c = Date.today();
        tt.EventApi__Early_Bird_Price__c = 100.00;
        tt.EventApi__Enable_Access_Permissions__c = true;
        tt.EventApi__Enable_Early_Bird_Price__c = true;
        tt.EventApi__Enable_Onsite_Price__c = true;
        tt.EventApi__Inventory_Status__c = 'In-Stock';
        tt.EventApi__Is_Active__c = true;
        tt.EventApi__Is_Published__c = true;
        tt.EventApi__Is_Tax_Deductible__c = true;
        tt.EventApi__Onsite_Price__c = 100.00;
        tt.EventApi__Price__c = 100.00;
        tt.EventApi__Quantity_Available__c = 100;
        tt.EventApi__Quantity_Sold__c = 100;
        insert tt;
        //at.EventApi__Contact__c = c.Id;
  		/*at.EventApi__Ticket_Type__c = tt.Id;
        at.EventApi__Attendee_Event__c = ev.Id;
        at.EventApi__status__c = 'Registered';
        at.EventApi__Registration_Date__c = Date.today();
        at.EventApi__Full_Name__c = 'Test Full Name';
        insert at; */
        testForm.Name = 'TEST FORM';
        testForm.PagesApi__User_Instructions__c = 'TEST INSTRUCTIONS';
        insert testForm;
        fg.PagesApi__DML_Operation__c = 'insert';
        fg.PagesApi__Form__c = testForm.Id;
        fg.PagesApi__Mapped_Object__c = 'account';
        fg.PagesApi__Order__c = 0;
        fg.PagesApi__Is_Multiple__c = false;
        fg.PagesApi__Instructions__c = 'Please fill in all required fields.';
        insert fg;
        formResponse = new PagesApi__Form_Response__c();
        formResponse .PagesApi__Entity__c = 'Contact';
        formResponse .PagesApi__Form__c = testform.Id;
        formResponse.EventApi__Attendee__c = at.Id;
        insert formResponse;
    }
    @isTest
    static void test_EventNameOnReceipt() {
        install();
        createTestData();
        EventRegistrationControllerUnmanaged controller = new EventRegistrationControllerUnmanaged();
        controller.attr_attendeeId = at.Id;
        controller.getSessions();
        controller.getResponses();
    }
}