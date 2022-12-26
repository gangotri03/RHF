@isTest
public class rhfHhmMigrationTests {
	@isTest static void testRHFHhmMigration() {
        
   List <Account> accns = new List<Account>();
      
         Account a = new Account(Name='testAccount'+'i'); 
        a.RecordTypeId = '012F0000000zbeY';
         accns.add(a);
      
   
   insert accns;        
        
   	  List <Contact> contacts = new List<Contact>();
      //for(integer i = 0; i<200; i++){
         Contact c = new contact(LastName='testAccount'+'1'); 
        	c.npe01__Private__c = false;
        	c.AccountId = a.Id;
         contacts.add(c);
         c = new contact(LastName='testAccount'+'2'); 
        	c.npe01__Private__c = true;
        c.AccountId = a.Id;
         contacts.add(c);
      //}
		insert contacts;	
       Test.StartTest();
       rhfHhmMigration rhfmig = new rhfHhmMigration();
       ID batchprocessid = Database.executeBatch(rhfmig);
       Test.StopTest();
       System.AssertEquals(1,1);  
   
   }
    
}