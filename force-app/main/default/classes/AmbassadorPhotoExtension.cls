public with sharing class AmbassadorPhotoExtension
{ 
	public Contact currentContact {get;set;}     
	
    public blob picture { get; set; }
	public String errorMessage { get; set; }
	public String pictureB64 { get; set; }
    public String imageUrl { get; set; }
    public String showImage { get; set; }
		
	public AmbassadorPhotoExtension(ApexPages.StandardController sc)
   	{
        imageUrl = '';
        showImage = '';
        picture = null;
        if(!Test.isRunningTest()) {
    		sc.AddFields(new List<String>{'RHID__c'});
        }
    	currentContact = (Contact) sc.getRecord();     
     	if(currentContact.RHID__c != null && currentContact.RHID__c != '')
        {
            Long timestamp = datetime.now().getTime();
            String ts = string.valueof(timestamp);
            imageUrl = 'https://rhfcdn.blob.core.windows.net/rhfid/ProfileImages/'+currentContact.RHID__c+'.jpg?_ts='+ts;
            showImage = '1';
        }
        
        System.debug('***** ' + currentContact );
	
    }
	public PageReference save() {
    errorMessage = '';
    try {
        //upsert speaker;
        if (picture != null) {
            if(currentContact.RHID__c != null && currentContact.RHID__c != '')
            {
            //Attachment attachment = new Attachment();
            //attachment.body = picture;
            //attachment.name = 'speaker_' + speaker.id + '.jpg';
            //attachment.parentid = speaker.id;
            //attachment.ContentType = 'application/jpg';
            //insert attachment;
            //speaker.Picture_Path__c = '/servlet/servlet.FileDownload?file='
            //                          + attachment.id;
            //update speaker;
            pictureB64 = EncodingUtil.base64Encode(picture);
            //errorMessage = pictureB64;
			List<String> jsonStrList = new List<String>();			
            jsonStrList.add('{'+
                            '"RHID":"' +currentContact.RHID__c + '",' +
                            '"PHOTO":"' +pictureB64 + '"' +
                            '}');
        	if(!Test.isRunningTest()) {
    			API_RHIDCall.APICall_Secure('UpdateContactPhoto',jsonStrList);            
        	}                
            
                Long timestamp = datetime.now().getTime();
                String ts = string.valueof(timestamp);
                imageUrl = 'https://rhfcdn.blob.core.windows.net/rhfid/ProfileImages/'+currentContact.RHID__c+'.jpg?_ts='+ts;
                errorMessage ='image is uploaded please refresh page to see it';
                showImage = '';
				
            }
			            
        }
        //return new ApexPages.StandardController(currentContact).view();
    	} catch(System.Exception ex) {
        	errorMessage = ex.getMessage();
        	return null;
    	}
        return null;
	}
    
}