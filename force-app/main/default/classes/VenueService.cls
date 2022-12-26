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
 * Service Class for EventApi__Venue__c
 * @author Ulas Kutuk
 **/
public class VenueService {

    public static void setDefaults(EventApi__Venue__c[] records) {
        Framework.Log.push(VenueService.class.getName(),'setDefaults');

        Set<Id> eventIds = new Set<Id>();
        EventApi__Event__c[] eventsToUpdate = new List<EventApi__Event__c>();

        for (EventApi__Venue__c v : (EventApi__Venue__c []) records) {
            if (v.EventApi__Is_Primary_Venue__c) {
                eventIds.add(v.EventApi__Event__c);
            }
        }

        if (eventIds.size() > 0){
            Map <Id,EventApi__Event__c> eventMap
                    = new Map<Id,EventApi__Event__c> ((EventApi__Event__c[])
                            new Framework.Selector(EventApi__Event__c.SObjectType).
                                    selectById(eventIds));

            if (eventMap != null && eventMap.keySet().size() > 0 ) {
                for (EventApi__Venue__c v : (EventApi__Venue__c []) records) {
                    if (v.EventApi__Event__c != null && v.EventApi__Is_Primary_Venue__c) {
                        if (eventMap.get(v.EventApi__Event__c) != null) {
                            EventApi__Event__c e = eventMap.get(v.EventApi__Event__c);
                            e.Primary_Venue__c = v.Name
                                    + '\n' + v.EventApi__Street__c
                                    + '\n' + v.EventApi__City__c + ', '
                                    + v.EventApi__State__c + ' '
                                    + v.EventApi__Postal_Code__c
                                    + '\n' + v.EventApi__Country__c;

                            eventsToUpdate.add(e);
                        }
                    }
                }
            }
        }

        if (eventsToUpdate.size() > 0) {
            update eventsToUpdate;
        }

        Framework.Log.pop();
    }
}