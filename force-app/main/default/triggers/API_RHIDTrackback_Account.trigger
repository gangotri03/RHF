trigger API_RHIDTrackback_Account on Account (after update) {
if (!System.isBatch())
{
  List<Contact> listAccContacts = [Select FirstName,LastName,Email,RHID__c,RHF_Unit_Association__c,AccountId,npsp__Primary_Affiliation__c,Id from Contact where npsp__Primary_Affiliation__c IN :Trigger.newMap.keySet()];
  List<String> jsonStrList = new List<String>();
  List<String> batch = new List<String>();
  Integer count = 0;
  for (Account acc : Trigger.new) {
    if (acc.LastModifiedById != '0050G000008VFnc' && acc.RecordTypeId != '0120G0000013bcT' && acc.RecordTypeId != '0120G0000013bcTQAQ') {
      Account oldAcc = Trigger.oldMap.get(acc.Id);
      String jsonBeforeChangeAcc = '"Before":'+JSON.serialize(oldAcc);
      String jsonChangedAcc = ',"After":'+JSON.serialize(acc);
      String jsonContacts = ',"Contacts":[';
      String aid = acc.Id;
      Integer i = 1;
      for (Contact c : listAccContacts){
      if (c.npsp__Primary_Affiliation__c == aid){
      if (i==1){
        jsonContacts = jsonContacts+JSON.serialize(c);
        }
        else{
        jsonContacts = jsonContacts+','+JSON.serialize(c);
        }
        i++;
      }
      }
      jsonContacts = jsonContacts+']';
      //API_RHIDCall.APICall_Secure('LogAccountUpdatedEvent','{'+jsonBeforeChangeAcc+jsonChangedAcc+jsonContacts+'}');
      //jsonStrList.add('{'+jsonBeforeChangeAcc+jsonChangedAcc+jsonContacts+'}');
      batch.add('{'+jsonBeforeChangeAcc+jsonChangedAcc+jsonContacts+'}');
      if (count++>200){
        jsonStrList.add('{"batch":'+JSON.serialize(batch)+'}');
        batch = new List<String>();
        count = 0;
      }
    }
  }
      if (count>0){
        jsonStrList.add('{"batch":'+JSON.serialize(batch)+'}');
        batch = new List<String>();
        count = 0;
      }
if (jsonStrList.size()>0)
  API_RHIDCall.APICall_Secure('LogAccountUpdatedEventBatch',jsonStrList);
}
}