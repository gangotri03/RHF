trigger API_RHIDTrackback_RHSPOrder on RHSP_Order__c (after update) {
if (!System.isBatch())
{
  List<String> jsonStrList = new List<String>();
  for (RHSP_Order__c obj : Trigger.new) {
    if (obj.LastModifiedById != '0050G000008VFnc') {
      RHSP_Order__c oldObj = Trigger.oldMap.get(obj.Id);
      String jsonBeforeChangeObj = '"Before":'+JSON.serialize(oldObj);
      String jsonChangedObj = ',"After":'+JSON.serialize(obj);
      //API_RHIDCall.APICall_Secure('LogRHSPOrderUpdatedEvent','{'+jsonBeforeChangeObj+jsonChangedObj+'}');
      jsonStrList.add('{'+jsonBeforeChangeObj+jsonChangedObj+'}');
    }
  }
  API_RHIDCall.APICall_Secure('LogRHSPOrderUpdatedEvent',jsonStrList);
}
}