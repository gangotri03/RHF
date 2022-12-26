trigger BCGrant_Trigger on BCGrant__c (before insert, before update) {
  Database.DMLOptions dml = new Database.DMLOptions(); 
  dml.DuplicateRuleHeader.allowSave = true;
  dml.DuplicateRuleHeader.runAsCurrentUser = true;
  Account[] updatedAccounts = new Account[0];
  Contact[] updatedContacts = new Contact[0];
  npe5__Affiliation__c[] updatedAffiliations = new npe5__Affiliation__c[0];
    
    for(BCGrant__c obj : Trigger.new) {
        String contactId = '';
        String accountId = '';
        String opportunityId = '';
        String siteName = '';
        
        Building__c[] matchBuildings = new Building__c[0];
        if (!String.isEmpty(obj.Scorecard_Reference_Number__c)) {
            matchBuildings = [Select Id, Account__c, Site_Name__c from Building__c where Scorecard_Reference_Number__c = :obj.Scorecard_Reference_Number__c];
            
            if (matchBuildings.size() != 0) {
                Building__c bld = matchBuildings[0];
                obj.Building__c = bld.Id;
                obj.Account__c = bld.Account__c;
                accountId = bld.Account__c;        
                sitename = bld.Site_Name__c;
                
                Boolean hasPrimaryAffiliation = false;
                //Check if Contact Email matches any SF Contact record
                Contact[] matchedContacts = [Select Id, AccountId, npe01__Type_of_Account__c, RHF_Unit_Association__c, npsp__Primary_Affiliation__c from Contact Where Email = :obj.Work_Email__c];
                if (matchedContacts.size() > 0)
                {
                  Contact con = matchedContacts[0];
                  if (!String.isEmpty(con.npsp__Primary_Affiliation__c))
                    hasPrimaryAffiliation = true;
                  if (!String.isEmpty(con.RHF_Unit_Association__c)) {
                    if (!con.RHF_Unit_Association__c.contains('Access & Inclusion')) {
                      con.RHF_Unit_Association__c = con.RHF_Unit_Association__c + ';Access & Inclusion';
                    }
                  }
                  else {
                    con.RHF_Unit_Association__c = 'Access & Inclusion';
                  }
                  con.LastName = obj.Last_Name__c;
                  con.FirstName = obj.First_Name__c;
                  updatedContacts.add(con);
                  contactId = con.Id;
                }
                else
                {
                  Contact c = new Contact();
                  c.Email = obj.Work_Email__c;
                  c.LastName = obj.Last_Name__c;
                  c.FirstName = obj.First_Name__c;
                  c.RHF_Unit_Association__c = 'Access & Inclusion';
                  insert c;
                  contactId = c.Id;
                }
                obj.Contact__c = contactId;
                
                //Check if an affiliation already exists between this Account and this Contact
                if (accountId != '' && contactId != '')
                {
                    npe5__Affiliation__c[] matchedAffiliations = [Select Id, npe5__Status__c from npe5__Affiliation__c Where npe5__Contact__c = :contactId AND npe5__Organization__c = :accountId];
                    if (matchedAffiliations.size() > 0)
                    {
                        npe5__Affiliation__c aff = matchedAffiliations[0];
                        if (aff.npe5__Status__c != 'Current') {
                        aff.npe5__Status__c = 'Current';
                        aff.npe5__Role__c = 'BCAccess submission owner';
                        if (!hasPrimaryAffiliation)
                            aff.npe5__Primary__c = true;
                        updatedAffiliations.add(aff);
                        }
                    }
                    else
                    {
                        npe5__Affiliation__c af = new npe5__Affiliation__c();
                        af.npe5__Organization__c = accountId;
                        af.npe5__Contact__c = contactId;
                        af.npe5__StartDate__c = Date.today();
                        af.npe5__Role__c = 'BCAccess submission owner';
                        af.npe5__Primary__c = true;
                        insert af;
                    }
                }     
                
                //Create opportunity - outbound grant
                //Create opportunity if there is no identical site name
                
                Opportunity[] matchedOpportunities = [Select Id from Opportunity where Opportunity_NameId__c = :sitename AND AccountId = :accountId];
                if (matchedOpportunities.size() == 0) {
                    Opportunity op = new Opportunity();
                    op.Name = sitename;
                    op.AccountId = accountId;
                    op.npsp__Primary_Contact__c = contactId;
                    op.StageName = 'Application Eligibility Screening';
                    op.RecordTypeId = '0120G000001UTUxQAO';
                    op.Building__c = bld.Id;
                    //op.npsp__Requested_Amount__c = obj.Requested_Amount__c;
                    
                    //submission date
                    if (obj.GL_Date__c != null)
                        op.CloseDate = obj.GL_Date__c;
                    else
                        op.CloseDate = Date.today();
                    //op.Type = 'BC Accessibility Grants';
                    op.Opportunity_NameId__c = sitename;
                    op.npe01__Do_Not_Automatically_Create_Payment__c = true;
                    insert op;
                    opportunityId = op.Id;
                    obj.Opportunity__c = opportunityId;
                }

            }
            else {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] {'bcgrants@rickhansen.com'};
                message.optOutPolicy = 'FILTER';
                message.subject = 'BCGrant mapping error: Building Scorecard Reference Number is not found';
                message.plainTextBody = obj.Scorecard_Reference_Number__c + ' doesn\'t exist. Outbound grant opportunity for ' + obj.First_Name__c + ' ' + obj.Last_Name__c + '\'s application can\'t be created.';
                //for(OrgWideEmailAddress owa : [select id, Address, DisplayName from OrgWideEmailAddress]) 
                //{
                //  if(owa.Address.contains('devsupport')) 
                //  message.setOrgWideEmailAddressId(owa.id); 
                //}
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if (results[0].success) {
                    System.debug('The email was sent successfully');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
            
        }
        
    }
  update updatedContacts;
  update updatedAffiliations;
}