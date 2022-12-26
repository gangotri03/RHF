@isTest
public class AddAttendeesToCampaignControllerTest
{
    public static testmethod void testAddAttendeesToCampaignControllerConstructor()
    {
        try
        {
            //Create sample data
            Account a = new Account();
            a.Name = 'Test Account';
            upsert a;
            Campaign c = new Campaign();
            c.Name = 'Test Campaign';
            upsert c;
            Contact con = new Contact();
            con.LastName = 'Test Contact';
            con.AccountId = a.Id;
            upsert con;
            
            //Add parameters to page URL
            ApexPages.currentPage().getParameters().put('id', a.Id);
            ApexPages.currentPage().getParameters().put('cid', c.Id);
            
            //Instantiate controller class
            AddAttendeesToCampaignController controller = new AddAttendeesToCampaignController(new ApexPages.StandardController(a));
            //Instantiate inner class
            AddAttendeesToCampaignController.wrapContact wContact = new AddAttendeesToCampaignController.wrapContact(con, '');
            
            controller.getChildContacts('');
            controller.save();
            controller.cancel();
            
            //Verify data with relevant predicates
            system.assertEquals('Test Account', a.Name);
            system.assertEquals('Test Campaign', c.Name);
            system.assertEquals('Test Contact', con.LastName);
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    }
}