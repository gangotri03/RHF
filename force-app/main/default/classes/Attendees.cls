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
 * Domain Class for EventApi__Attendee__c
 * @author Ulas Kutuk
 **/
global class Attendees extends Framework.Domain {

    public Attendees(List<EventApi__Attendee__c> sObjectList) {
        super(sObjectList);
    }

    global class Constructor implements Framework.Domain.DomainConstructor  {
        global Framework.Domain construct(List<SObject> sObjectList) {
            return new Attendees(sObjectList);
        }
    }

    /*
    public override void afterUpdate(Map<Id,SObject> oldMap) {
        Framework.Log.push(Attendees.class.getName(),'afterUpdate');
        Framework.Log.pop();
    }
    */
    
    public override void afterInsert() {
        Framework.Log.push(Attendees.class.getName(),'afterInsert');
        AttendeeService.updateSendWorkflowCheckbox((EventApi__Attendee__c[]) records);
        Framework.Log.pop();
    }


}