public class API_RHIDCall {

  //Future annotation to mark the method as async.
  @future (callout=true)
  public static void APICall_Secure(String apiRoute, List<String> jsonStrList) {
  for (String jsonStr : jsonStrList) {
    Http http = new Http();
    HttpRequest tokenreq = new HttpRequest();
    tokenreq.setEndpoint('https://rhid.rickhansen.com/identity/connect/token');
    tokenreq.setMethod('POST');
    //Set the HTTPRequest body
    string body = 'grant_type=client_credentials&scope=api_access&client_id=apiclient&client_secret=secret';
    tokenreq.setBody(body);
    string access_token = '';
    try {

    //Execute web service call here
if (UserInfo.getOrganizationId().substring(0, 15) == '00DF00000007SQt') {
    HttpResponse tokenres = http.send(tokenreq);
    //Helpful debug messages
    //System.debug(tokenres.toString());
    //System.debug('STATUS:'+tokenres.getStatus());
    //System.debug('STATUS_CODE:'+tokenres.getStatusCode());
    //System.debug(tokenres.getBody());
    // Parse JSON response to get the access token.
    JSONParser parser = JSON.createParser(tokenres.getBody());
    while (parser.nextToken() != null) {
        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
            (parser.getText() == 'access_token')) {
            // Get the value.
            parser.nextToken();
            access_token = parser.getText();
        }
    }
}
    } catch(System.CalloutException e) {
    //Exception handling goes here....
    }

    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://rhid.rickhansen.com/rhfidapi/SF/'+apiRoute);
    req.setMethod('POST');
    req.setHeader('Authorization','Bearer '+access_token);
    req.setHeader('Content-Type', 'application/json');
    req.setBody(jsonStr);
    System.debug(jsonStr);
    try {

      //Execute web service call here
if (UserInfo.getOrganizationId().substring(0, 15) == '00DF00000007SQt') {
      HttpResponse res = http.send(req);
      //Helpful debug messages
      //System.debug(res.toString());
      //System.debug('STATUS:'+res.getStatus());
      //System.debug('STATUS_CODE:'+res.getStatusCode());
      //System.debug(res.getBody());
}
    } catch(System.CalloutException e) {
    //Exception handling goes here....
    }
  }
  }
}