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
 * Service Class for EventApi__Event__c
 * @author Ulas Kutuk
 **/
public class EventService {

    public static void setDefaults(EventApi__Event__c[] records) {
        Framework.Log.push(EventService.class.getName(),'setDefaults');

        Set<Id> categoryIds = new Set<Id>();
        Set<Id> tempIds = new Set<Id>();
        
        User usr = [SELECT Id,Profile.UserLicense.Name FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
        Boolean isAdminUser = false;
        if (usr.Profile.UserLicense.Name == 'Salesforce' || usr.Profile.UserLicense.Name == 'Salesforce Platform') {
            isAdminUser = true;
        }
        
        
        for (EventApi__Event__c e : records) {

            if (e.Send_Reminder_Emails__c) {
                tempIds.add(e.Id);
            }

            if (e.EventApi__Event_Category__c != null) {
                categoryIds.add(e.EventApi__Event_Category__c);
            }
            if (isAdminUser && e.EventApi__Time_Zone__c != null && e.EventApi__Time_Zone__c != null) {
                
                String s = e.EventApi__Time_Zone__c;
                String t = s.substringAfter(' ');
                e.Calendar_Attachment_Timezone__c = t;
            }
            
            if (isAdminUser && e.EventApi__Start_Date_Time__c != null && e.EventApi__End_Date_Time__c != null) { 
                
                e.Calendar_Attachment_Start_Date__c = e.EventApi__Start_Date_Time__c.format('yyyyMMdd HHmmss');
                e.Calendar_Attachment_Start_Date__c = e.Calendar_Attachment_Start_Date__c.replace(' ','T');
               
                e.Calendar_Attachment_End_Date__c = e.EventApi__End_Date_Time__c.format('yyyyMMdd HHmmss');
                e.Calendar_Attachment_End_Date__c = e.Calendar_Attachment_End_Date__c.replace(' ','T');
            }

        }


        if (categoryIds.size() > 0 ) {

            List<EventApi__Event_Category__c> categories =
                            [SELECT Id, (SELECT Id,EventApi__Is_Default__c,EventApi__Site__c
                                        FROM EventApi__Site_Event_Categories__r)
                                FROM EventApi__Event_Category__c
                                WHERE Id IN:categoryIds];

            Map<Id,Id> catToSiteId = new Map<Id,Id>();
            Set<Id> siteIds = new Set<Id>();


            for (EventApi__Event_Category__c c : categories) {
                if (c.EventApi__Site_Event_Categories__r != null && c.EventApi__Site_Event_Categories__r.size() >0) {
                    for (EventApi__Site_Event_Category__c s: c.EventApi__Site_Event_Categories__r) {
                        if (s.EventApi__Is_Default__c) {
                            siteIds.add(s.EventApi__Site__c);
                            catToSiteId.put(c.Id,s.EventApi__Site__c);
                        }
                    }
                }
            }

            if (siteIds.size() > 0) {
                Map<Id, PagesApi__Site__c> siteMap =
                    new Map<Id,PagesApi__Site__c> ((PagesApi__Site__c[]) new Framework.Selector(PagesApi__Site__c.SObjectType).
                        selectById(siteIds));

                for (EventApi__Event__c e : records) {
                    if (e.EventApi__Event_Category__c != null) {
                        Id siteId;

                        if (catToSiteId.get(e.EventApi__Event_Category__c) != null) {
                            siteId = catToSiteId.get(e.EventApi__Event_Category__c);
                            PagesApi__Site__c site = siteMap.get(siteId);

                            e.Site__c = site.Id;
                        }
                    }
                }

            }
        }

        if (tempIds.size() > 0 && !System.isFuture() && !System.isBatch()) {
            EventService.checkAttendee(tempIds);
        }

        Framework.Log.pop();
    }

    public static void checkAttendee(Set<id> eventIds) {
        EventApi__Attendee__c[] attendees = [SELECT Id,Send_Reminder_Emails__c FROM EventApi__Attendee__c
                                        WHERE EventApi__Attendee_Event__c IN: eventIds];

        for (EventApi__Attendee__c a: attendees) {
            a.Send_Reminder_Emails__c = true;
        }
        update attendees;
        
        EventService.unCheckEvent(eventIds);
        EventService.unCheckAttendee(eventIds);
    }

    //Un-checks the email checkboxes
    @future
    public static void unCheckAttendee(Set<id> eventIds) {

        EventApi__Attendee__c[] attendees = [SELECT Id,Send_Reminder_Emails__c FROM EventApi__Attendee__c
        WHERE EventApi__Attendee_Event__c IN: eventIds];

        for (EventApi__Attendee__c a: attendees) {
            a.Send_Reminder_Emails__c = false;
        }
        update attendees;
    }

    //Un-checks the email checkboxes
    @future
    public static void unCheckEvent(Set<id> eventIds) {

        EventApi__Event__c[] events = [SELECT Id,Send_Reminder_Emails__c FROM EventApi__Event__c WHERE Id IN: eventIds];

        for (EventApi__Event__c e: events) {
            e.Send_Reminder_Emails__c = false;
        }
        update events;
    }


}