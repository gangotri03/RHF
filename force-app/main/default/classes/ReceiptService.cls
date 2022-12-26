/*
 * -----------------------------------------------------------------------------
 * COPYRIGHT (C) 2018, FONTEVA, INC.
 * ALL RIGHTS RESERVED.
 *
 * ALL INFORMATION CONTAINED HEREIN IS, AND REMAINS THE PROPERTY OF FONTEVA
 * INCORPORATED AND ITS SUPPLIERS, IF ANY. THE INTELLECTUAL AND TECHNICAL
 * CONCEPTS CONTAINED HEREIN ARE PROPRIETARY TO FONTEVA INCORPORATED AND
 * ITS SUPPLIERS AND MAY BE COVERED BY U.S. AND FOREIGN PATENTS, PATENTS IN
 * PROCESS, AND ARE PROTECTED BY TRADE SECRET OR COPYRIGHT LAW. DISSEMINATION
 * OF THIS INFORMATION OR REPRODUCTION OF THIS MATERIAL IS STRICTLY FORBIDDEN
 * UNLESS PRIOR WRITTEN PERMISSION IS OBTAINED FROM FONTEVA, INC.
 * -----------------------------------------------------------------------------
 */

/**
 * Service Class for OrderApi__Receipt__c
 * @author Ulas Kutuk
 **/
public class ReceiptService {

    public static void setDefaults(OrderApi__Receipt__c[] records) {
        Framework.Log.push(ReceiptService.class.getName(),'setDefaults');
        
        Set<Id> orderIds = new Set<Id>();
        
        for (OrderApi__Receipt__c r : records) {
            
            if (r.OrderApi__Sales_Order__c != null && r.Event__c == null) {
                orderIds.add(r.OrderApi__Sales_Order__c);
            }
            
        }
        
        if (orderIds.size() > 0) {
            Map <Id,OrderApi__Sales_Order__c> soMap
             = new Map<Id,OrderApi__Sales_Order__c> ((OrderApi__Sales_Order__c[])
                  new Framework.Selector(OrderApi__Sales_Order__c.SObjectType,OrderApi__Sales_Order_Line__c.OrderApi__Sales_Order__c).
                       selectById(orderIds));
                       
           
           Map<Id,Id> soToEventMap = new Map <Id,Id>();
           Set<Id> eventIds = new Set<Id>();
           
           for (OrderApi__Sales_Order__c so : soMap.values()) {
               
               if (so.OrderApi__Sales_Order_Lines__r != null && so.OrderApi__Sales_Order_Lines__r.size() > 0) {
                   
                   for (OrderApi__Sales_Order_Line__c sol : so.OrderApi__Sales_Order_Lines__r ) {
                       
                       if (sol.EventApi__Event__c != null) {
                           
                           soToEventMap.put(so.Id, sol.EventApi__Event__c);
                           eventIds.add(sol.EventApi__Event__c);
                       }
                   }
               }
           }
           
           if (eventIds.size() > 0) { 
               
               Map<Id,EventApi__Event__c> eventMap = new Map<Id,EventApi__Event__c> ((EventApi__Event__c[]) new Framework.Selector(EventApi__Event__c.SObjectType).
                   selectById(eventIds));
                   
               
               for (OrderApi__Receipt__c r : records) {
            
                    if (r.OrderApi__Sales_Order__c != null && r.Event__c == null) {
                        
                        if (soToEventMap != null && soToEventMap.keySet().size() > 0 ) {
                            
                            
                            if (soToEventMap.get(r.OrderApi__Sales_Order__c) != null) {
                                Id eventId = soToEventMap.get(r.OrderApi__Sales_Order__c);
                                
                                if (eventId != null) {
                                    r.Event__c  = eventMap.get(eventId).Id;
                                }
                            }
                        }
                    }
                    
                }
                   
           }
           
        }
        
        Framework.Log.pop();
    }
}