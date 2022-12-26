@istest
public class Job_PostingsTest{
    @TestSetup
    private static void install() {
        Framework.Installer.install();
        PagesApi.PackageScripts.install();
        OrderApi.PackageScripts.install();
        EventApi.PackageScripts.install();
        
        Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();
        Framework.RoutingRule Job_PostingRule = new Framework.RoutingRule();
        Job_PostingRule.apexClass = Job_Postings.class.getName();
        Job_PostingRule.namespace = '';
        Job_PostingRule.isEnabled = true;
        Job_PostingRule.sObjectName = 'Job_Posting__c';
        Job_PostingRule.executionOrder = 50;
        rules.add(Job_PostingRule);
        Framework.Config.push(rules);        
    }
    
    @istest
    static void jobPostingInsert(){
        Job_Posting__c jobPosting=new Job_Posting__c();
        insert jobPosting;
        List<Job_Posting__c> jobPostings=[select id from Job_Posting__c where id=:jobPosting.id];
        Job_Postings FSSubscriptionRoutingRule = new Job_Postings(jobPostings);
        Job_Postings.Constructor cons=new Job_Postings.Constructor();
        cons.construct(jobPostings); 
        Framework.Dispatcher.dispatchTrigger();
    }
}