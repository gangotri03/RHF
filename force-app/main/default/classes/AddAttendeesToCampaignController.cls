public class AddAttendeesToCampaignController
{
    public List<AccContacts> contactList{get;set;}
    public List<SelectOption> cmStatusOpts{get;set;}
    public string campaignName{get;set;}
    
    public class wrapContact
    {
        public Contact con{get;set;}
        public string cmStatus{get;set;}
        public Boolean selected{get;set;}
        
        //This is the contructor method. When we create a new wrapContact object we pass a Contact that is set to the con property. We also set the selected value to false
        public wrapContact(Contact c, string status)
        {
            con = c;
            cmStatus = status;
            selected = false;
        }
    }
    public class AccContacts
    {
        public string Acc{get;set;}
        public List<wrapContact> contacts{get;set;}
    }
    public AddAttendeesToCampaignController(ApexPages.StandardController stdController)
    {
        string cid = System.currentPagereference().getParameters().get('cid');
        string cmStatusDefault;
        cmStatusOpts = new List<SelectOption>();
        for(CampaignMemberStatus c : [SELECT Label, CampaignId, IsDefault FROM CampaignMemberStatus WHERE CampaignId = :cid])
        {
            cmStatusOpts.add(new SelectOption(c.Label, c.Label));
            if(c.IsDefault)
               cmStatusDefault = c.Label;
        }
        for(Campaign c : [select name from Campaign where id = :cid Limit 1])
        {
            campaignName = c.Name;
        }
        Set<string> existingMembers = new Set<string>();
        for(CampaignMember c : [select ContactId from CampaignMember where CampaignId = :cid])
        {
            existingMembers.add(c.ContactId);
        }
        contactList = new List<AccContacts>();
        for(Account a : [select name,Id from account where id = :System.currentPageReference().getParameters().get('id') Limit 1])
        {
            AccContacts ac = new AccContacts();
            ac.Acc = a.Name;
            List<wrapContact> wrapContactList = new List<wrapContact>();
            for(Contact c : getChildContacts(a.Id))
            {
                //If Contact not yet in CampaignMember we create a new wrapContact object and add it to the wrapContactList
                if (!existingMembers.contains(c.Id))
                    wrapContactList.add(new wrapContact(c, cmStatusDefault));
            }
            ac.contacts = wrapContactList;
            contactList.add(ac);
        }
    }
    public List<Contact> getChildContacts(string id)
    {
        return [Select name,phone,email from Contact where accountid = :id order by name Limit 1000];
    }
    public PageReference save()
    {
        string cid = System.currentPagereference().getParameters().get('cid');
        List <CampaignMember> cmList = new list<CampaignMember>();
        for(AccContacts ac : contactList)
        {
            for(wrapContact wc : ac.contacts)
            {
                if (wc.selected)
                {
                    CampaignMember cm = new CampaignMember();
                    cm.CampaignId = cid;
                    cm.ContactId = wc.con.Id;
                    cm.Status = wc.cmStatus;
                    cmList.add(cm);
                }
            }
        }
        if(!cmList.isEmpty())
        {
            Insert cmList;
        }
        return new PageReference('/' + cid);
    }
    public PageReference cancel()
    {
        string cid = System.currentPagereference().getParameters().get('cid');
        return new PageReference('/' + cid);
    }
}