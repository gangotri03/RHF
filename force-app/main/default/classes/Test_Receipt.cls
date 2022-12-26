@isTest
public class Test_Receipt {

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
    static EventApi__Ticket_Type__c tt = new EventApi__Ticket_Type__c();
    
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
    }
    
    
    @isTest
    static void test_EventNameOnReceipt() {
        install();
        createTestData();
        
        System.assertNotEquals(null, cat.Id);
        System.assertNotEquals(null, ev.Id);
        System.assertNotEquals(null, tt.Id);
        
        
        OrderApi__Item__c item =
            (OrderApi__Item__c) new Framework.Selector(OrderApi__Item__c.SObjectType).
                selectById(tt.Id,
                    SObjectType.OrderApi__Item__c.fields.EventApi__Ticket_Type__c.getName());
        
        //The Item created automatically for TT 
        System.assert(item.Id != null);
        System.assertEquals(tt.Name,item.Name);
        
                    
        OrderApi__Sales_Order__c so = new OrderApi__Sales_Order__c();
        insert so;
        
        OrderApi__Sales_Order_Line__c sol = new OrderApi__Sales_Order_Line__c();
        sol.OrderApi__Sales_Order__c =  so.Id;
        sol.OrderApi__Item__c = item.Id;
        insert sol;
        
        
        sol = [SELECT Id, OrderApi__Item__c, EventApi__Event__c, EventApi__Ticket_Type__c
                FROM OrderApi__Sales_Order_Line__c
                WHERE Id =: sol.Id];
        
        
        Test.startTest();
        
        System.assertEquals(ev.Id, sol.EventApi__Event__c);
        System.assertEquals(tt.Id, sol.EventApi__Ticket_Type__c);
        
        so.OrderApi__Is_Closed__c = true;
        update SO;
        
        OrderApi__EPayment__c ePay = new OrderApi__EPayment__c();
        ePay.OrderApi__Succeeded__c = false;
        ePay.OrderApi__Sales_Order__c = so.Id;
        epay.OrderApi__Transaction_Token__c = '123';
        insert ePay;
        
        OrderApi__EPayment_Line__c ePayLine = new OrderApi__EPayment_Line__c();
        ePayLine.OrderApi__EPayment__c = ePay.Id;
        ePayLine.OrderApi__Item__c = item.Id;
        ePayLine.OrderApi__Quantity__c = 1;
        ePayLine.OrderApi__Sale_Price__c = 10;
        insert ePayLine;
        
        ePay.OrderApi__Succeeded__c = true;
        update ePay;
        
        Test.stopTest();
        
        
        ePay = [SELECT Id, OrderApi__Succeeded__c FROM OrderApi__EPayment__c WHERE Id =: ePay.Id];
        
        System.assertEquals(true, ePay.OrderApi__Succeeded__c);
        
        OrderApi__Receipt__c r = [SELECT Id, Event__c
                                    FROM OrderApi__Receipt__c 
                                    WHERE OrderApi__EPayment__c =: ePay.Id];
        
        System.assertNotEquals(null, r.Id);
        
        System.assertEquals(ev.Id, r.Event__c);
        
        
        
    }
}