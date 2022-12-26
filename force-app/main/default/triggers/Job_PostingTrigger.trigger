trigger Job_PostingTrigger on Job_Posting__c (before insert, before update, before delete,
                                   after insert, after update, after delete) {
    Framework.Dispatcher.dispatchTrigger();
}