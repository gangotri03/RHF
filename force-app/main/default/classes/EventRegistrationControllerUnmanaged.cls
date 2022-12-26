/*
 * -----------------------------------------------------------------------------
 * COPYRIGHT (C) 2018, FONTEVA, INC.
 * ALL RIGHTS RESERVED.
 *
 * ALL INFORMATION CONTAINED HEREIN IS, AND REMAINS THE PROPERTY OF FONTEVA
 * INCORPORATED AND ITS SUPPLIERS, IF ANY. THE INTELLECTUAL AND TECHNICAL
 * CONCEPTS CONTAINED HEREIN ARE PROPRIETARY TO FONTEVA INCORPORATED AND
 * ITS SUPPLIERS AND MAY BE COVERED BY U.S. AND FOREIGN PATENTS, PATENTS IN
 * PROCESS, AND ARE PROTECTED BY TRADE SECRET OR COPYRIGHT LAW. DISSEMINATION
 * OF THIS INFORMATION OR REPRODUCTION OF THIS MATERIAL IS STRICTLY FORBIDDEN
 * UNLESS PRIOR WRITTEN PERMISSION IS OBTAINED FROM FONTEVA, INC.
 * -----------------------------------------------------------------------------
 */

/**
 * Controller for Event Registration Confirmation Workflow
 * @author Ulas Kutuk
 **/
public class EventRegistrationControllerUnmanaged {
    
    public Id attr_attendeeId {get; set;}

    public PagesApi__Form_Response__c[] responses;
    private EventApi__Schedule_Item__c[] sessions;

    //Constructor
    public EventRegistrationControllerUnmanaged() { }



    public EventApi__Schedule_Item__c[] getSessions() {

        sessions = new List<EventApi__Schedule_Item__c>();

        EventApi__Registration_Item__c[] regs = [SELECT Id, EventApi__Schedule_Item__c, EventApi__Is_Primary__c FROM EventApi__Registration_Item__c
        WHERE EventApi__Attendee__c =: attr_attendeeId];

        Set<Id> sessionIds = new Set<Id>();
        for (EventApi__Registration_Item__c r : regs) {
            if (r.EventApi__Schedule_Item__c != null) {
                sessionIds.add(r.EventApi__Schedule_Item__c);
            }
        }

        if (sessionIds.size() > 0) {
            sessions = (EventApi__Schedule_Item__c[]) new Framework.Selector(EventApi__Schedule_Item__c.SObjectType).selectById(sessionIds);
        }

        return sessions;
    }

    public PagesApi__Form_Response__c[] getResponses() {
        responses = new List<PagesApi__Form_Response__c>();
//
//        responses = (PagesApi__Form_Response__c[]) new Framework.Selector
//                (PagesApi__Form_Response__c.SObjectType,PagesApi__Field_Response__c.PagesApi__Form_Response__c).
//                selectById(new Set<Id>{attr_attendeeId},
//                        Framework.SchemaService.getDescribe(PagesApi__Form_Response__c.EventApi__Attendee__c).getName());

        PagesApi__Form_Response__c[] res = [SELECT Id, EventApi__Attendee__c,
                                    (SELECT Id, PagesApi__Field_Label__c, PagesApi__Response__c,PagesApi__Response_Group__c
                                    FROM PagesApi__Field_Responses__r
                                    ORDER BY PagesApi__Response_Group__c,PagesApi__Field_Order__c ASC)
                                    FROM PagesApi__Form_Response__c
                                    WHERE EventApi__Attendee__c =:attr_attendeeId];

        return res;
    }
}