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
 * Service Class for EventApi__Attendee__c
 * @author Ulas Kutuk
 **/
public class AttendeeService {

  
     /**
     * Updates the checkbox on the attendee to send reg worfklow emails 
     * @param oldMap {Map<Id,EventApi__Attendee__c>}
     * @param records {EventApi__Attendee__c[]
     */
    public static void updateSendWorkflowCheckbox(EventApi__Attendee__c[] records) {
        Framework.Log.push(AttendeeService.class.getName(),'setDefaults');
        
        Set<Id> attendeeIds = new Set<Id>();
        for (EventApi__Attendee__c a: records) {
            attendeeIds.add(a.Id);
        }
        
        
        AttendeeService.updateAttendee(attendeeIds);
        
        Framework.Log.pop();
    }
    
    public static void updateAttendee(Set<id> setId) {
      
      EventApi__Attendee__c[] attendees = [SELECT Id,Send_Registration_Emails__c FROM EventApi__Attendee__c WHERE Id IN: setId];
      
        for (EventApi__Attendee__c a: attendees) {
            a.Send_Registration_Emails__c = true;
        }
      
      try {
          String name = 'EVWRK AttendeeBatchable' + String.valueOf(DateTime.now());
          EVWRK_AttendeeBatchable nextBatchJob = new EVWRK_AttendeeBatchable(setId);
          System.scheduleBatch(nextBatchJob,name,1,100); //1 minute after active ones finished, scope 100
          
      }
      catch (DmlException ex) {
          Framework.Log.debugException(ex); 
      }
      
    }
 
}