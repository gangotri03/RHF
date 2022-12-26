global class Job_Postings extends Framework.Domain {
 
    public Job_Postings(List<Job_Posting__c> sObjectList) {
        super(sObjectList);
    }
 
    global class Constructor implements Framework.Domain.DomainConstructor {
        public Framework.Domain construct(List<SObject> sObjectList) {
            return new Job_Postings(sObjectList);
        }
    }
}