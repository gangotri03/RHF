public class EVWRK_AttendeeBatchable implements Database.Batchable<sObject>, Database.stateFul {
    
    public Set<Id> attendeeIds;
    String query;
    
    public EVWRK_AttendeeBatchable(Set<Id> paramAttendeeIds) {
        this.attendeeIds = paramAttendeeIds;
        this.query = 'SELECT Id FROM EventApi__Attendee__c WHERE Id IN: attendeeIds';
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<EventApi__Attendee__c> scope) {
        Framework.Log.push(EVWRK_AttendeeBatchable.class.getName(),'execute');
        try {
            for (EventApi__Attendee__c a : scope) {
                a.Send_Registration_Emails__c = true;
            }
            update scope;
        }
        catch (Exception ex) {
            Framework.Log.debugException(ex);
        }
        Framework.Log.pop();
    }

    public void finish(Database.BatchableContext BC) {

    }

}