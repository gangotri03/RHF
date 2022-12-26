trigger FluidReview_UpsertTrigger on RHF_FluidReview__c (before insert, before update) {
  Database.DMLOptions dml = new Database.DMLOptions(); 
  dml.DuplicateRuleHeader.allowSave = true;
  dml.DuplicateRuleHeader.runAsCurrentUser = true;
  Account[] updatedAccounts = new Account[0];
  Contact[] updatedContacts = new Contact[0];
  npe5__Affiliation__c[] updatedAffiliations = new npe5__Affiliation__c[0];
  Campaign[] updatedCampaigns = new Campaign[0];
  Event[] updatedEvents = new Event[0];
  for (RHF_FluidReview__c obj : Trigger.new)
  {
  if (obj.Group__c == 'Barrier Buster Grants' && !String.isEmpty(obj.FullName__c) && !String.isEmpty(obj.ContactEmail__c))
  {
    String accountId = '';
    String contactId = '';
    String campaignId = '';
    Account[] matchedAccounts = new Account[0];
    if (!String.isEmpty(obj.AccountId__c)) {
      matchedAccounts = [Select Id, RHF_Unit_Association__c from Account Where Id = :obj.AccountId__c];
    }
  //Check if Organization Name matches any SF Account record
    if (!String.isEmpty(obj.OrganizationName__c))
    {
      if (matchedAccounts.size() == 0) {
        matchedAccounts = [Select Id, RHF_Unit_Association__c from Account Where Name = :obj.OrganizationName__c];
      }
      if (matchedAccounts.size() > 0)
      {
        Account acc = matchedAccounts[0];
        if (!String.isEmpty(acc.RHF_Unit_Association__c)) {
          if (!acc.RHF_Unit_Association__c.contains('BBGrant')) {
            acc.RHF_Unit_Association__c = acc.RHF_Unit_Association__c + ';BBGrant';
          }
        }
        else {
          acc.RHF_Unit_Association__c = 'BBGrant';
        }
        acc.BillingStreet = obj.StreetAddress__c;
        acc.BillingCity = obj.City__c;
        acc.BillingState = obj.ProvinceTerritory__c;
        acc.BillingPostalCode = obj.PostalCode__c;
        acc.BillingCountry = obj.Country__c;
        acc.CRABusinessNumber__c = obj.CRABusinessNumber__c;
        acc.Website = obj.OrganizationWebsite__c;
        Database.SaveResult sr = Database.update(acc, false);
        if (!sr.isSuccess())
        {
          obj.Error__c = sr.getErrors().get(0).getMessage();
          Database.SaveResult sr2 = Database.update(acc, dml);
        }
        accountId = acc.Id;
      }
      else
      {
        Account a = new Account();
        a.RecordTypeId = '012F0000000zhwp';
        a.Name = obj.OrganizationName__c;
        a.BillingStreet = obj.StreetAddress__c;
        a.BillingCity = obj.City__c;
        a.BillingState = obj.ProvinceTerritory__c;
        a.BillingPostalCode = obj.PostalCode__c;
        a.BillingCountry = obj.Country__c;
        a.CRABusinessNumber__c = obj.CRABusinessNumber__c;
        a.Website = obj.OrganizationWebsite__c;
        a.RHF_Unit_Association__c = 'BBGrant';
        a.OwnerId = '005F0000007jG1G';
        Database.SaveResult sr3 = Database.insert(a, false);
        if (!sr3.isSuccess())
        {
          obj.Error__c = sr3.getErrors().get(0).getMessage();
          Database.SaveResult sr4 = Database.insert(a, dml);
        }
        accountId = a.Id;
      }
    }
    Boolean hasPrimaryAffiliation = false;
    String applicantLastName = '';
    String applicantFirstName = '';
    String ownerFullName = obj.FirstName__c + ' ' + obj.LastName__c;
    if (ownerFullName == obj.FullName__c || obj.FirstName__c == obj.FullName__c) {
      applicantLastName = obj.LastName__c;
      applicantFirstName = obj.FirstName__c;
    }
    else if (obj.FullName__c.contains(' ')) {
      applicantLastName = obj.FullName__c.substringAfterLast(' ');
      applicantFirstName = obj.FullName__c.substringBeforeLast(' ');
    }
    else {
      applicantLastName = obj.FullName__c;
    }
  //Check if Contact Email matches any SF Contact record
    Contact[] matchedContacts = [Select Id, AccountId, npe01__Type_of_Account__c, RHF_Unit_Association__c, npsp__Primary_Affiliation__c from Contact Where Email = :obj.ContactEmail__c];
    if (matchedContacts.size() > 0)
    {
      Contact con = matchedContacts[0];
      if (!String.isEmpty(con.npsp__Primary_Affiliation__c))
        hasPrimaryAffiliation = true;
      if (!String.isEmpty(con.RHF_Unit_Association__c)) {
        if (!con.RHF_Unit_Association__c.contains('BBGrant')) {
          con.RHF_Unit_Association__c = con.RHF_Unit_Association__c + ';BBGrant';
        }
      }
      else {
        con.RHF_Unit_Association__c = 'BBGrant';
      }
      //con.LastName = applicantLastName;
      //con.FirstName = applicantFirstName;
      con.npe01__PreferredPhone__c = 'Work';
      con.npe01__WorkPhone__c = obj.Phone__c;
      con.OtherPhone = obj.AlternativePhone__c;
      con.Preferred_Language_of_Communication__c = obj.PreferredLanguage__c;
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
      c.Email = obj.ContactEmail__c;
      c.LastName = applicantLastName;
      c.FirstName = applicantFirstName;
      c.npe01__PreferredPhone__c = 'Work';
      c.npe01__WorkPhone__c = obj.Phone__c;
      c.OtherPhone = obj.AlternativePhone__c;
      c.Preferred_Language_of_Communication__c = obj.PreferredLanguage__c;
      c.RHF_Unit_Association__c = 'BBGrant';
      //if (accountId == '')
      //  c.npe01__Private__c = true;
      //else
      //  c.AccountId = accountId;
      c.OwnerId = '005F0000007jG1G';
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
        if (aff.npe5__Status__c != 'Current') {
          aff.npe5__Status__c = 'Current';
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
        af.npe5__Primary__c = true;
        insert af;
      }
    }
    
  //Check if ReferenceId matches any SF Campaign record
    if (!String.isEmpty(obj.ProjectName__c) && !String.isEmpty(obj.ReferenceID__c))
    {
      Campaign[] matchedCampaigns = [Select Id, Name from Campaign Where ReferenceID__c = :obj.ReferenceID__c];
      if (matchedCampaigns.size() > 0)
      {
        Campaign cam = matchedCampaigns[0];
        cam.Name = obj.ProjectName__c;
        cam.IsActive = true;
        if (!String.isEmpty(cam.RHF_Unit_Association__c)) {
          if (!cam.RHF_Unit_Association__c.contains('BBGrant')) {
            cam.RHF_Unit_Association__c = cam.RHF_Unit_Association__c + ';BBGrant';
          }
        }
        else {
          cam.RHF_Unit_Association__c = 'BBGrant';
        }
        if (!String.isEmpty(obj.ProjectDescription__c)) cam.Description = obj.ProjectDescription__c;
        if (!String.isEmpty(obj.Campaign_Subtypes__c)) cam.Venue_Type__c = obj.Campaign_Subtypes__c.replace('Site d’art et de culture', 'Arts & Cultural Venue').replace('Centre communautaire', 'Community Centre').replace('Parc / terrain de jeu', 'Park / Playground').replace('Lieu de culte', 'Place of Worship').replace('Centre de loisirs', 'Recreation Centre').replace('École', 'School').replace('Autre (veuillez préciser)', 'Other (please specify):');
        if (!String.isEmpty(obj.Campaign_Subtypes_Other__c)) cam.Venue_Type_Other__c = obj.Campaign_Subtypes_Other__c;
        if (!String.isEmpty(obj.Status__c)) cam.Status = obj.Status__c;
        if (obj.StartDate__c != null) cam.StartDate = obj.StartDate__c;
        if (obj.EndDate__c != null && obj.StartDate__c <= obj.EndDate__c) cam.EndDate = obj.EndDate__c;
        cam.BBCreatedDate__c = obj.BBCreatedDate__c;
        if (obj.BBSubmissionDate__c != null) cam.BBSubmissionDate__c = obj.BBSubmissionDate__c;
        cam.OwnerId = '005F0000007jG1G';
        cam.RHF_Campaign_Type__c = 'Grant';
        cam.Type = 'Grant';
        updatedCampaigns.add(cam);
        campaignId = cam.Id;
        CampaignMemberStatus[] cmStatuses = [Select Id from CampaignMemberStatus Where CampaignId = :campaignId AND Label='N/A'];
        if (cmStatuses.size() == 0)
        {
          CampaignMemberStatus naStatus = new CampaignMemberStatus(
            CampaignId=campaignId,
            Label='N/A',
            IsDefault=false,
            HasResponded=false,
            SortOrder=3
          );
          insert naStatus;
        }
      }
      else
      {
        Campaign ca = new Campaign();
        ca.ReferenceID__c = obj.ReferenceID__c;
        ca.Name = obj.ProjectName__c;
        ca.IsActive = true;
        if (!String.isEmpty(obj.ProjectDescription__c)) ca.Description = obj.ProjectDescription__c;
        if (!String.isEmpty(obj.Campaign_Subtypes__c)) ca.Venue_Type__c = obj.Campaign_Subtypes__c.replace('Site d’art et de culture', 'Arts & Cultural Venue').replace('Centre communautaire', 'Community Centre').replace('Parc / terrain de jeu', 'Park / Playground').replace('Lieu de culte', 'Place of Worship').replace('Centre de loisirs', 'Recreation Centre').replace('École', 'School').replace('Autre (veuillez préciser)', 'Other (please specify):');
        if (!String.isEmpty(obj.Campaign_Subtypes_Other__c)) ca.Venue_Type_Other__c = obj.Campaign_Subtypes_Other__c;
        if (!String.isEmpty(obj.Status__c)) ca.Status = obj.Status__c;
        if (obj.StartDate__c != null) ca.StartDate = obj.StartDate__c;
        if (obj.EndDate__c != null && obj.StartDate__c <= obj.EndDate__c) ca.EndDate = obj.EndDate__c;
        ca.BBCreatedDate__c = obj.BBCreatedDate__c;
        if (obj.BBSubmissionDate__c != null) ca.BBSubmissionDate__c = obj.BBSubmissionDate__c;
        ca.RHF_Unit_Association__c = 'BBGrant';
        ca.OwnerId = '005F0000007jG1G';
        ca.RHF_Campaign_Type__c = 'Grant';
        ca.Type = 'Grant';
        insert ca;
        campaignId = ca.Id;
        CampaignMemberStatus newStatus = new CampaignMemberStatus(
          CampaignId=campaignId,
          Label='N/A',
          IsDefault=false,
          HasResponded=false,
          SortOrder=3
        );
        insert newStatus;
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
      CampaignMember[] matchedCampaignMembers = [Select Id from CampaignMember Where CampaignId = :campaignId AND ContactId = :contactId];
      if (matchedCampaignMembers.size() == 0)
      {
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = campaignId;
        cm.ContactId = contactId;
        cm.Status = 'N/A';
        insert cm;
      }
    }
  //Check if an Awareness Event already exists
    if (!String.isEmpty(obj.AwarenessEventDescription__c) && obj.AwarenessEventProposedDate__c != null && campaignId != '' && (obj.Status__c == 'Approved and 90% Payment' || obj.Status__c == 'Interim Reports' || obj.Status__c == 'Final Report and 10% payment' || obj.Status__c == 'Complete'))
    {
      Event[] events = [Select Id from Event Where WhatId = :campaignId AND Subject = 'Awareness Event'];
      if (events.size() > 0)
      {
        Event e = events[0];
        //e.StartDateTime = obj.AwarenessEventProposedDate__c;
        //e.EndDateTime = obj.AwarenessEventProposedDate__c;
        //e.ActivityDateTime = obj.AwarenessEventProposedDate__c;
        e.Description = obj.AwarenessEventDescription__c;
        updatedEvents.add(e);
      }
      else
      {
        Event event = new Event(
          OwnerId = '0230G000007AqfW',
          WhatId = campaignId,
          StartDateTime = obj.AwarenessEventProposedDate__c,
          EndDateTime = obj.AwarenessEventProposedDate__c,
          ActivityDateTime = obj.AwarenessEventProposedDate__c,
          IsAllDayEvent = true,
          Subject = 'Awareness Event',
          Description = obj.AwarenessEventDescription__c
        );
        insert event;
        Campaign[] campaigns = [Select Name from Campaign Where Id = :campaignId];
        Campaign campaign = campaigns[0];
        campaign.AwarenessEventURL__c = URL.getSalesforceBaseUrl().toExternalForm() + '/' + event.Id;
        update campaign;
      }
    }
  }
  if (obj.Group__c == 'Youth Summit' && !String.isEmpty(obj.YLSFullName__c) && !String.isEmpty(obj.YLSContactEmail__c))
  {
    String accountId = '';
    String contactId = '';
    String campaignId = '7010G000000zIAq';
    Account[] matchedAccounts = new Account[0];
    if (!String.isEmpty(obj.AccountId__c)) {
      matchedAccounts = [Select Id, RHF_Unit_Association__c from Account Where Id = :obj.AccountId__c];
    }
  //Check if School (Name, City, Province) matches any SF Account record
    if (!String.isEmpty(obj.YLSSchoolName__c) && !String.isEmpty(obj.YLSBillingCity__c) && !String.isEmpty(obj.YLSBillingState__c) && obj.YLSSchoolName__c != obj.YLSFullName__c)
    {
      if (matchedAccounts.size() == 0) {
        matchedAccounts = [Select Id, RHF_Unit_Association__c from Account Where Name = :obj.YLSSchoolName__c AND BillingCity = :obj.YLSBillingCity__c AND BillingState = :obj.YLSBillingState__c];
      }
      if (matchedAccounts.size() > 0)
      {
        Account acc = matchedAccounts[0];
        if (!String.isEmpty(acc.RHF_Unit_Association__c)) {
          if (!acc.RHF_Unit_Association__c.contains('YLS')) {
            acc.RHF_Unit_Association__c = acc.RHF_Unit_Association__c + ';YLS';
            updatedAccounts.add(acc);
          }
        }
        else {
          acc.RHF_Unit_Association__c = 'YLS';
          updatedAccounts.add(acc);
        }
        //update acc;
        accountId = acc.Id;
      }
      else
      {
        Account a = new Account();
        a.RecordTypeId = '012F0000000za8m';
        a.Name = obj.YLSSchoolName__c;
        a.BillingCity = obj.YLSBillingCity__c;
        a.BillingState = obj.YLSBillingState__c;
        a.RHF_Unit_Association__c = 'YLS';
        a.OwnerId = '005F0000007jG1G';
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
    if (ownerFullName == obj.YLSFullName__c || obj.FirstName__c == obj.YLSFullName__c) {
      applicantLastName = obj.LastName__c;
      applicantFirstName = obj.FirstName__c;
    }
    else if (obj.YLSFullName__c.contains(' ')) {
      applicantLastName = obj.YLSFullName__c.substringAfterLast(' ');
      applicantFirstName = obj.YLSFullName__c.substringBeforeLast(' ');
    }
    else {
      applicantLastName = obj.YLSFullName__c;
    }
    //Check if Contact Email matches any SF Contact record
    Contact[] matchedContacts = [Select Id, AccountId, npe01__Type_of_Account__c, RHF_Unit_Association__c, Key_Information__c, Position__c, Position_Other__c, npsp__Primary_Affiliation__c from Contact Where Email = :obj.YLSContactEmail__c];
    if (matchedContacts.size() > 0)
    {
      Contact con = matchedContacts[0];
      if (!String.isEmpty(con.npsp__Primary_Affiliation__c))
        hasPrimaryAffiliation = true;
      if (!String.isEmpty(con.RHF_Unit_Association__c)) {
        if (!con.RHF_Unit_Association__c.contains('YLS')) {
          con.RHF_Unit_Association__c = con.RHF_Unit_Association__c + ';YLS';
        }
      }
      else {
        con.RHF_Unit_Association__c = 'YLS';
      }
      //con.LastName = applicantLastName;
      //con.FirstName = applicantFirstName;
      con.npe01__PreferredPhone__c = 'Mobile';
      con.HomePhone = obj.YLSHomePhone__c;
      con.MobilePhone = obj.YLSMobilePhone__c;
      con.Preferred_Language_of_Communication__c = obj.YLSPreferredLanguage__c;
      con.MailingStreet = obj.YLSMailingStreet__c;
      con.MailingCity = obj.YLSMailingCity__c;
      con.MailingState = obj.YLSMailingState__c;
      con.MailingPostalCode = obj.YLSMailingPostalCode__c;
      con.MailingCountry = 'Canada';
      con.TwitterHandle__c = obj.TwitterHandle__c;
      con.FacebookPage__c = obj.FacebookPage__c;
      con.InstagramProfile__c = obj.InstagramProfile__c;
      con.YouTubeChannel__c = obj.YouTubeChannel__c;
      con.LinkedInPage__c = obj.LinkedInPage__c;
      con.SocialMediaOther__c = obj.SocialMediaOther__c;
      if (String.isEmpty(con.Key_Information__c)) {
        con.Key_Information__c = 'RHF Youth Leadership Summit 2017 applicant';
      }
      if (String.isEmpty(con.Position__c)) {
        con.Position__c = 'Other';
        if (String.isEmpty(con.Position_Other__c)) {
          con.Position_Other__c = 'Student';
        }
      }
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
      //c.Email = obj.YLSContactEmail__c;
      c.npe01__HomeEmail__c = obj.YLSContactEmail__c;
      c.npe01__Preferred_Email__c = 'Personal';
      c.LastName = applicantLastName;
      c.FirstName = applicantFirstName;
      c.npe01__PreferredPhone__c = 'Mobile';
      c.HomePhone = obj.YLSHomePhone__c;
      c.MobilePhone = obj.YLSMobilePhone__c;
      c.Preferred_Language_of_Communication__c = obj.YLSPreferredLanguage__c;
      c.MailingStreet = obj.YLSMailingStreet__c;
      c.MailingCity = obj.YLSMailingCity__c;
      c.MailingState = obj.YLSMailingState__c;
      c.MailingPostalCode = obj.YLSMailingPostalCode__c;
      c.MailingCountry = 'Canada';
      c.TwitterHandle__c = obj.TwitterHandle__c;
      c.FacebookPage__c = obj.FacebookPage__c;
      c.InstagramProfile__c = obj.InstagramProfile__c;
      c.YouTubeChannel__c = obj.YouTubeChannel__c;
      c.LinkedInPage__c = obj.LinkedInPage__c;
      c.SocialMediaOther__c = obj.SocialMediaOther__c;
      c.Key_Information__c = 'RHF Youth Leadership Summit 2017 applicant';
      c.Position__c = 'Other';
      c.Position_Other__c = 'Student';
      c.RHF_Unit_Association__c = 'YLS';
      //if (accountId == '')
      //  c.npe01__Private__c = true;
      //else
      //  c.AccountId = accountId;
      c.OwnerId = '005F0000007jG1G';
      insert c;
      contactId = c.Id;
    }
    if (contactId != '')
    {
      Note[] matchedNotes = [Select Id from Note Where ParentId = :contactId AND Title LIKE 'Youth Leadership Summit 2017 applicant%'];
      if (matchedNotes.size() == 0) {
        if (!String.isEmpty(obj.YLSAge__c)) {
          Note note = new Note(
            OwnerId = '005F0000007jG1G',
            ParentId = contactId,
            Title = 'Youth Leadership Summit 2017 applicant age: ' + obj.YLSAge__c,
            Body = obj.YLSAge__c + ' is the age of applicant at the time of Summit.'
          );
          insert note;
        }
        if (!String.isEmpty(obj.YLSDisability__c) && !String.isEmpty(obj.YLSDisabilityDescribe__c) && obj.YLSDisability__c == 'Yes') {
          Note note = new Note(
            OwnerId = '005F0000007jG1G',
            ParentId = contactId,
            Title = 'Youth Leadership Summit 2017 applicant with disability',
            Body = 'Do you have a mobility, vision or hearing impairment? Yes\n' + obj.YLSDisabilityDescribe__c
          );
          insert note;
        }
      }
    }
  //Check if an affiliation already exists between this Account and this Contact
    if (accountId != '' && contactId != '')
    {
      npe5__Affiliation__c[] matchedAffiliations = [Select Id, npe5__Status__c from npe5__Affiliation__c Where npe5__Contact__c = :contactId AND npe5__Organization__c = :accountId];
      if (matchedAffiliations.size() > 0)
      {
        npe5__Affiliation__c aff = matchedAffiliations[0];
        if (aff.npe5__Status__c != 'Current') {
          aff.npe5__Status__c = 'Current';
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
        if (!String.isEmpty(obj.Status__c)) cm.Status = obj.Status__c;
        insert cm;
      }
      else
      {
        CampaignMember mcm = matchedCampaignMembers[0];
        if (!String.isEmpty(obj.Status__c) && mcm.Status != obj.Status__c) {
          mcm.Status = obj.Status__c;
          update mcm;
        }
      }
    }
  }
  if (obj.Group__c == 'Accessible Cities Award' && !String.isEmpty(obj.ACAContactFullName__c) && !String.isEmpty(obj.ACAContactEmail__c))
  {
    String accountId = '';
    String contactId = '';
    String campaignId = '7010G000000zIAv';
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
        a.OwnerId = '005F0000007jG1G';
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
      c.OwnerId = '005F0000007jG1G';
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
          aff.npe5__Role__c = 'Accessible Cities Award 2017 applicant';
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
        af.npe5__Role__c = 'Accessible Cities Award 2017 applicant';
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
        if (!String.isEmpty(obj.ACACircleofExcellenceNomination1__c)) {
          nom += obj.ACACircleofExcellenceNomination1__c + '\n';
          nomList.add(obj.ACACircleofExcellenceNomination1__c);
        }
        else if (!String.isEmpty(obj.ACACircleofExcellenceName1__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress1__c)) {
          nom += obj.ACACircleofExcellenceName1__c + ' ' + obj.ACACircleofExcellenceAddress1__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName1__c + ' ' + obj.ACACircleofExcellenceAddress1__c);
        }
      }
      if ((!String.isEmpty(obj.ACACircleofExcellence2__c) && obj.ACACircleofExcellence2__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceNomination2__c)) {
          nom += obj.ACACircleofExcellenceNomination2__c + '\n';
          nomList.add(obj.ACACircleofExcellenceNomination2__c);
        }
        else if (!String.isEmpty(obj.ACACircleofExcellenceName2__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress2__c)) {
          nom += obj.ACACircleofExcellenceName2__c + ' ' + obj.ACACircleofExcellenceAddress2__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName2__c + ' ' + obj.ACACircleofExcellenceAddress2__c);
        }
      }
      if ((!String.isEmpty(obj.ACACircleofExcellence3__c) && obj.ACACircleofExcellence3__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceNomination3__c)) {
          nom += obj.ACACircleofExcellenceNomination3__c + '\n';
          nomList.add(obj.ACACircleofExcellenceNomination3__c);
        }
        else if (!String.isEmpty(obj.ACACircleofExcellenceName3__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress3__c)) {
          nom += obj.ACACircleofExcellenceName3__c + ' ' + obj.ACACircleofExcellenceAddress3__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName3__c + ' ' + obj.ACACircleofExcellenceAddress3__c);
        }
      }
      if ((!String.isEmpty(obj.ACACircleofExcellence4__c) && obj.ACACircleofExcellence4__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceNomination4__c)) {
          nom += obj.ACACircleofExcellenceNomination4__c + '\n';
          nomList.add(obj.ACACircleofExcellenceNomination4__c);
        }
        else if (!String.isEmpty(obj.ACACircleofExcellenceName4__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress4__c)) {
          nom += obj.ACACircleofExcellenceName4__c + ' ' + obj.ACACircleofExcellenceAddress4__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName4__c + ' ' + obj.ACACircleofExcellenceAddress4__c);
        }
      }
      if ((!String.isEmpty(obj.ACACircleofExcellence5__c) && obj.ACACircleofExcellence5__c == 'Yes') || (!String.isEmpty(obj.Status__c) && obj.Status__c != 'Application Round')) {
        if (!String.isEmpty(obj.ACACircleofExcellenceNomination5__c)) {
          nom += obj.ACACircleofExcellenceNomination5__c + '\n';
          nomList.add(obj.ACACircleofExcellenceNomination5__c);
        }
        else if (!String.isEmpty(obj.ACACircleofExcellenceName5__c) || !String.isEmpty(obj.ACACircleofExcellenceAddress5__c)) {
          nom += obj.ACACircleofExcellenceName5__c + ' ' + obj.ACACircleofExcellenceAddress5__c + '\n';
          nomList.add(obj.ACACircleofExcellenceName5__c + ' ' + obj.ACACircleofExcellenceAddress5__c);
        }
      }
      if (nom != '')
      {
        Note[] matchedNotes = [Select Id from Note Where ParentId = :accountId AND Title LIKE 'Accessible Cities Award 2017 Circle of Excellence Nominations%'];
        if (matchedNotes.size() == 0) {
          Note note = new Note(
            OwnerId = '005F0000007jG1G',
            ParentId = accountId,
            Title = 'Accessible Cities Award 2017 Circle of Excellence Nominations',
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
  update updatedCampaigns;
  update updatedEvents;
}