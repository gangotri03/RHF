//######################################################################


global class rhfHhmMigration implements Database.Batchable<sObject>,Database.Stateful{
	String Query;
	global integer countContact;
	global integer countPrivate;
	global integer countHHM;
	global integer countIndividual;
	global integer countOther;
	global integer countNewAffiliation;
	global integer countExistingAffiliation;
    global integer countInactiveOwners;
    global integer countActiveOwners;
	global String HouseHoldAccount = '0120G0000013bcT';//'0124B0000004VL6';
    global boolean individual = true;
    global Map<Id,User> userMap;
	global Database.querylocator start(Database.BatchableContext BC){
		Query = 'Select id,name,npe01__Private__c,OwnerId, Account.Id, Account.RecordTypeid, Account.npe01__SYSTEMIsIndividual__c from contact';
		
		countContact = 0;
		countPrivate = 0;
		countHHM = 0;
		countIndividual = 0;
		countOther = 0;
		countNewAffiliation = 0;
		countExistingAffiliation = 0;
        countInactiveOwners = 0;
        countActiveOwners = 0;
		userMap = new Map<Id, User>([Select Id, Name,isActive From User]);
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext BC, List<Contact> scope){
		List<Contact> contactList = new List<Contact>();
		List<sObject> affList = new List<sObject>();
		for(Contact s : scope){ 															//for each contact
            //User u = [select id,isActive from user where id=:s.OwnerId];
            boolean changed = false;
			countContact++;	
     		if(!(userMap.get(s.OwnerId)).isActive){
          		s.OwnerId = userinfo.getuserid();
                countInactiveOwners++;
                changed = true;
            }
            else{
                countActiveOwners++;
            }
			

			if(s.npe01__Private__c == false){												//	contact has an account
				if(s.Account.RecordTypeid == HouseHoldAccount){								//	YES - account is a household
					countHHM++;																//	|   |
				}                                                                           //	|   |
				else if(s.Account.npe01__SYSTEMIsIndividual__c == individual){              //	|	|->account is an individual
					s.AccountId = null;                                                     //	|	|	|
					changed = true;                                                         //	|   |   |
					countIndividual++;                                                      //	|   |   |
				}	                                                                        //	|   | <-|
				else{                                                                       //	|	|->other account type
					countOther++;                                                           //	|	|	|
                    npe5__Affiliation__c[] matchedAffiliations =                            //	|	|   |
                        [Select Id, npe5__Status__c from npe5__Affiliation__c               //	|	|   |
						Where npe5__Contact__c = : s.Id AND                                 //	|	|   |
						npe5__Organization__c = :s.accountId                                //	|	|   |
						AND npe5__Status__c =: 'Current'];                                  //	|	|   |
                    if (matchedAffiliations.size() > 0)                                     //	|	|	|->affiliation between contact and account exists
                    {                                                                       //	|	|   |	|-YES
                        countExistingAffiliation++;                                         //	|	|   |   |
                    }                                                                       //	|	|   |   |
                    else                                                                    //	|	|   |   |-NO
                    {                                                                       //	|	|   |   |
                        npe5__Affiliation__c af = new npe5__Affiliation__c();               //	|	|   |   |
                        af.npe5__Organization__c = s.AccountId;                             //	|	|   |   |
                        af.npe5__Contact__c = s.Id;                                         //	|	|   |   |
                        af.npe5__StartDate__c = Date.today();                               //	|	|   |   |
                        //insert af;                                                        //	|	|   |   |
                        affList.add(af);                                                    //	|	|   |   |-Create new Affiliation
                        countNewAffiliation++;                                              //	|	|   |	| between contact and account
                    }                                                                       //	|	|   | <-|
                    s.npsp__Primary_Affiliation__c = s.accountId;                           //	|	|   |-set contact primary affiliation
					s.accountId = null;                                                     //	|	|   |-remove contact account reference
					changed = true;                                                         //	|	| <-|
				}                                                                           //	| <-|
			}                                                                               //	|
			else{                                                                           //	NO
				s.npe01__Private__c = false;												//	|-set contact Private to false
				changed = true;                                                             //  |
				countPrivate++;                                                             //  |
			}                                                                               //
			if(changed){                                                                    //
				contactList.add(s);                                                         //
			}			                                                                    //
		}                                                                                   //
		insert affList;                                                                   //
		update contactList;                                                               //
	}
	global void finish(Database.BatchableContext BC){
		system.debug('countContact				: '+countContact			  );
		system.debug('countPrivate              : '+countPrivate              );
		system.debug('countHHM                  : '+countHHM                  );
		system.debug('countIndividual           : '+countIndividual           );
		system.debug('countOther                : '+countOther                );
		system.debug('countNewAffiliation       : '+countNewAffiliation       );
		system.debug('countExistingAffiliation  : '+countExistingAffiliation  );	
        system.debug('countInactiveOwners       : '+countInactiveOwners       );
		system.debug('countActiveOwners         : '+countActiveOwners         );
	}
}


//######################################################################