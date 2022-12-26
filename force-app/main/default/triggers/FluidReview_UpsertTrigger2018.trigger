trigger FluidReview_UpsertTrigger2018 on RHF_FluidReview__c (before insert, before update) {
  Database.DMLOptions dml = new Database.DMLOptions(); 
  dml.DuplicateRuleHeader.allowSave = true;
  dml.DuplicateRuleHeader.runAsCurrentUser = true;
  Account[] updatedAccounts = new Account[0];
  Contact[] updatedContacts = new Contact[0];
  npe5__Affiliation__c[] updatedAffiliations = new npe5__Affiliation__c[0];
  for (RHF_FluidReview__c obj : Trigger.new)
  {
  if (obj.Group__c == 'Accessible Cities Award' && !String.isEmpty(obj.ACAContactFullName__c) && !String.isEmpty(obj.ACAContactEmail__c))
  {
    String accountId = '';
    String contactId = '';
    String campaignId = '7010G000000CSOF';
    Account[] matchedAccounts = new Account[0];
    if (!String.isEmpty(obj.AccountId__c)) {
      matchedAccounts = [Select Id, RHF_Unit_Association__c from Account Where Id = :obj.AccountId__c];
    }
  //Check if Municipality Name matches any SF Account record
    if (!String.isEmpty(obj.ACAMunicipalityName__c))
    {
      if (matchedAccounts.size() == 0) {
        matchedAccounts = [Select Id, RHF_Unit_Association__c from Account Where Name = :obj.ACAMunicipalityName__c];
      }
      if (matchedAccounts.size() > 0)
      {
        Account acc = matchedAccounts[0];
        if (!String.isEmpty(acc.RHF_Unit_Association__c)) {
          if (!acc.RHF_Unit_Association__c.contains('ACA')) {
            acc.RHF_Unit_Association__c = acc.RHF_Unit_Association__c + ';ACA';
            acc.RecordTypeId = '012F0000000zhwo';
            updatedAccounts.add(acc);
          }
        }
        else {
          acc.RHF_Unit_Association__c = 'ACA';
          acc.RecordTypeId = '012F0000000zhwo';
          updatedAccounts.add(acc);
        }
        //update acc;
        accountId = acc.Id;
      }
      else
      {
        Account a = new Account();
        a.RecordTypeId = '012F0000000zhwo';
        a.Name = obj.ACAMunicipalityName__c;
        a.RHF_Unit_Association__c = 'ACA';
        a.OwnerId = '0050G000008VFnc';
        Database.SaveResult sr = Database.insert(a, false);
        if (!sr.isSuccess())
        {
          obj.Error__c = sr.getErrors().get(0).getMessage();
          Database.SaveResult sr2 = Database.insert(a, dml);
        }
        accountId = a.Id; 
      }
      obj.AccountId__c = accountId;
    }
    Boolean hasPrimaryAffiliation = false;
    String applicantLastName = '';
    String applicantFirstName = '';
    String ownerFullName = obj.FirstName__c + ' ' + obj.LastName__c;
    if (ownerFullName == obj.ACAContactFullName__c || obj.FirstName__c == obj.ACAContactFullName__c) {
      applicantLastName = obj.LastName__c;
      applicantFirstName = obj.FirstName__c;
    }
    else if (obj.ACAContactFullName__c.contains(' ')) {
      applicantLastName = obj.ACAContactFullName__c.substringAfterLast(' ');
      applicantFirstName = obj.ACAContactFullName__c.substringBeforeLast(' ');
    }
    else {
      applicantLastName = obj.ACAContactFullName__c;
    }
    //Check if Contact Email matches any SF Contact record
    Contact[] matchedContacts = [Select Id, AccountId, npe01__Type_of_Account__c, RHF_Unit_Association__c, Key_Information__c, Position__c, Position_Other__c, npsp__Primary_Affiliation__c from Contact Where Email = :obj.ACAContactEmail__c];
    if (matchedContacts.size() > 0)
    {
      Contact con = matchedContacts[0];
      if (!String.isEmpty(con.npsp__Primary_Affiliation__c))
        hasPrimaryAffiliation = true;
      if (!String.isEmpty(con.RHF_Unit_Association__c)) {
        if (!con.RHF_Unit_Association__c.contains('ACA')) {
          con.RHF_Unit_Association__c = con.RHF_Unit_Association__c + ';ACA';
        }
      }
      else {
        con.RHF_Unit_Association__c = 'ACA';
      }
      //con.LastName = applicantLastName;
      //con.FirstName = applicantFirstName;
      con.npe01__PreferredPhone__c = 'Work';
      con.npe01__WorkPhone__c = obj.ACAContactPhone__c;
      //if (accountId != '' && (String.isEmpty(con.AccountId) || con.npe01__Type_of_Account__c == 'Individual')) {
      //  con.AccountId = accountId;
      //  con.npe01__Private__c = false;
      //}
      updatedContacts.add(con);
      contactId = con.Id;
    }
    else
    {
      Contact c = new Contact();
      c.Email = obj.ACAContactEmail__c;
      c.LastName = applicantLastName;
      c.FirstName = applicantFirstName;
      c.npe01__PreferredPhone__c = 'Work';
      c.npe01__WorkPhone__c = obj.ACAContactPhone__c;
      c.RHF_Unit_Association__c = 'ACA';
      //if (accountId == '')
      //  c.npe01__Private__c = true;
      //else
      //  c.AccountId = accountId;
      c.OwnerId = '0050G000008VFnc';
      insert c;
      contactId = c.Id;
    }
  //Check if an affiliation already exists between this Account and this Contact
    if (accountId != '' && contactId != '')
    {
      npe5__Affiliation__c[] matchedAffiliations = [Select Id, npe5__Status__c from npe5__Affiliation__c Where npe5__Contact__c = :contactId AND npe5__Organization__c = :accountId];
      if (matchedAffiliations.size() > 0)
      {
        npe5__Affiliation__c aff = matchedAffiliations[0];
        //if (aff.npe5__Status__c != 'Current') {
          aff.npe5__Status__c = 'Current';
          aff.npe5__Role__c = 'Accessible Cities Award 2018 applicant';
          if (!hasPrimaryAffiliation)
            aff.npe5__Primary__c = true;
          updatedAffiliations.add(aff);
        //}
      }
      else
      {
        npe5__Affiliation__c af = new npe5__Affiliation__c();
        af.npe5__Organization__c = accountId;
        af.npe5__Contact__c = contactId;
        af.npe5__Role__c = 'Accessible Cities Award 2018 applicant';
        af.npe5__StartDate__c = Date.today();
        af.npe5__Primary__c = true;
        insert af;
      }
    }
  //Check if an Account Campaign Association already exists between this Account and this Campaign
    if (accountId != '' && campaignId != '')
    {
      Account_Campaign_Association__c[] matchedAssociations = [Select Id from Account_Campaign_Association__c Where Campaign__c = :campaignId AND Account__c = :accountId];
      if (matchedAssociations.size() == 0)
      {
        Account_Campaign_Association__c aca = new Account_Campaign_Association__c();
        aca.Account__c = accountId;
        aca.Campaign__c =campaignId;
        insert aca;
      }
    }
  //Check if a CampaignMember Association already exists between this Contact and this Campaign
    if (contactId != '' && campaignId != '')
    {
      CampaignMember[] matchedCampaignMembers = [Select Id, Status from CampaignMember Where CampaignId = :campaignId AND ContactId = :contactId];
      if (matchedCampaignMembers.size() == 0)
      {
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaignId;
        cm.ContactId = contactId;
        //if (!String.isEmpty(obj.Status__c)) cm.Status = obj.Status__c;
        insert cm;
      }
    }
    if (accountId != '')
    {
      String nom = '';
      List<String> nomList = new List<String>();
      if ((!String.isEmpty(obj.ACACircleofExcellence1__c) && obj.ACACircleofExcellence1__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceName1__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress1__c)) {
          nom += obj.ACACircleofExcellenceName1__c + ' ' + obj.ACACircleofExcellenceAddress1__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName1__c + ' ' + obj.ACACircleofExcellenceAddress1__c);
        }
      }
      if ((!String.isEmpty(obj.ACACircleofExcellence2__c) && obj.ACACircleofExcellence2__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceName2__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress2__c)) {
          nom += obj.ACACircleofExcellenceName2__c + ' ' + obj.ACACircleofExcellenceAddress2__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName2__c + ' ' + obj.ACACircleofExcellenceAddress2__c);
        }
      }
      if ((!String.isEmpty(obj.ACACircleofExcellence3__c) && obj.ACACircleofExcellence3__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceName3__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress3__c)) {
          nom += obj.ACACircleofExcellenceName3__c + ' ' + obj.ACACircleofExcellenceAddress3__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName3__c + ' ' + obj.ACACircleofExcellenceAddress3__c);
        }
      }
      if ((!String.isEmpty(obj.ACACircleofExcellence4__c) && obj.ACACircleofExcellence4__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceName4__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress4__c)) {
          nom += obj.ACACircleofExcellenceName4__c + ' ' + obj.ACACircleofExcellenceAddress4__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName4__c + ' ' + obj.ACACircleofExcellenceAddress4__c);
        }
      }
      if ((!String.isEmpty(obj.ACACircleofExcellence5__c) && obj.ACACircleofExcellence5__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceName5__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress5__c)) {
          nom += obj.ACACircleofExcellenceName5__c + ' ' + obj.ACACircleofExcellenceAddress5__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName5__c + ' ' + obj.ACACircleofExcellenceAddress5__c);
        }
      }
      if (nom != '')
      {
        Note[] matchedNotes = [Select Id from Note Where ParentId = :accountId AND Title LIKE 'Accessible Cities Award 2018 Circle of Excellence Nominations%'];
        if (matchedNotes.size() == 0) {
          Note note = new Note(
            OwnerId = '0050G000008VFnc',
            ParentId = accountId,
            Title = 'Accessible Cities Award 2018 Circle of Excellence Nominations',
            Body = nom
          );
          insert note;
        }
        else
        {
          Note mn = matchedNotes[0];
          mn.Body = nom;
          update mn;
        }
        Campaign[] campaigns = [Select Name, Description from Campaign Where Id = :campaignId];
        if (campaigns.size() > 0) {
        Campaign campaign = campaigns[0];
        String[] lines = new String[0];
        if (!String.isEmpty(campaign.Description)) lines = campaign.Description.split('\\n');
        Integer i = 0;
        while (i < lines.size())
        {
          if (lines.get(i).contains(obj.ACAMunicipalityName__c + ': ')) lines.remove(i);
          else i++;
        }
        for (String s : nomList)
        {
          lines.add(obj.ACAMunicipalityName__c + ': ' + s);
        }
        campaign.Description = String.join(lines, '\n');
        update campaign;
        }
      }
    }
  }
  }
  update updatedAccounts;
  update updatedContacts;
  update updatedAffiliations;
}