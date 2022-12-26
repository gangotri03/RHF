trigger API_RHIDTrackback_Contact on Contact (after update) {
if (!System.isBatch())
{
  List<String> jsonStrList = new List<String>();
  List<String> batch = new List<String>();
  Integer count = 0;
  for (Contact con : Trigger.new) {
    if (con.LastModifiedById != '0050G000008VFnc') {
      Contact oldCon = Trigger.oldMap.get(con.Id);
      String jsonBeforeChangeCon = '"Before":'+JSON.serialize(oldCon);
      String jsonChangedCon = ',"After":'+JSON.serialize(con);
      String jsonAcc = '';
      if (con.npsp__Primary_Affiliation__c != null && (oldCon.npsp__Primary_Affiliation__c == null || con.npsp__Primary_Affiliation__c != oldCon.npsp__Primary_Affiliation__c)) {
        String aid = con.npsp__Primary_Affiliation__c;
        List<String> fieldNames = new List<String>( Schema.SObjectType.Account.fields.getMap().keySet() );
        String query = 'SELECT ' + String.join( fieldNames, ',' ) + ' FROM Account WHERE id = :aid LIMIT 1';
        for (Account a : Database.query( query )){
          jsonAcc = ',"Account":'+JSON.serialize(a);
        }
      }
      //API_RHIDCall.APICall_Secure('LogContactUpdatedEvent','{'+jsonBeforeChangeCon+jsonChangedCon+jsonAcc+'}');
      //jsonStrList.add('{'+jsonBeforeChangeCon+jsonChangedCon+jsonAcc+'}');
      batch.add('{'+jsonBeforeChangeCon+jsonChangedCon+jsonAcc+'}');
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
  API_RHIDCall.APICall_Secure('LogContactUpdatedEventBatch',jsonStrList);
}
}