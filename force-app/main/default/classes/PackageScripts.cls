/**
 * -----------------------------------------------------------------------------
 * COPYRIGHT (C) 2018, FONTEVA, INC.
 * ALL RIGHTS RESERVED.
 *
 * ALL SOURCE CODE CONTAINED HEREIN IS, AND REMAINS THE PROPERTY OF FONTEVA
 * INCORPORATED AND ITS SUPPLIERS, IF ANY. THE INTELLECTUAL AND TECHNICAL
 * CONCEPTS CONTAINED HEREIN ARE PROPRIETARY TO FONTEVA INCORPORATED AND
 * ITS SUPPLIERS AND MAY BE COVERED BY U.S. AND FOREIGN PATENTS, PATENTS IN
 * PROCESS, AND ARE PROTECTED BY TRADE SECRET OR COPYRIGHT LAW. DISSEMINATION
 * OF THIS SOURCE CODE OR REPRODUCTION OF THIS MATERIAL IS STRICTLY FORBIDDEN
 * UNLESS PRIOR WRITTEN PERMISSION IS OBTAINED FROM FONTEVA, INC.
 * -----------------------------------------------------------------------------
 *
 * Ad-hoc scripts to support master data manipulation for the Event Workflow Package
 * @author Ulas Kutuk
 **/
global without sharing class PackageScripts implements InstallHandler, UninstallHandler{
    
    /**
     * Required for UninstallHandler interface implementation
     * ID organizationId();
     * ID uninstallerId();
     * @param  {InstallContext} context Object providing methods to retrieve
     *                                  organization Id and uninstalling user Id.
     */
    global void onInstall(InstallContext context) {
        PackageScripts.install();
    }

    /**
     * Required for UninstallHandler interface implementation
     * ID organizationId();
     * ID uninstallerId();
     * @param  {UninstallContext} context Object providing methods to retrieve
     *                                    organization Id and uninstalling user Id.
     */
    global void onUninstall(UninstallContext context) {

    }

    /**
     * Execute the installation scripts for the OrderApi managed package
     */
    global static void install() {
        new Install().run();
    }
    
     /**
     * Runs all default installation scripts for the Event Workflow
     * Managed Package
     *
     * @implements Framework.Scriptable
     * @author Ulas Kutuk
     */
    global class Install implements Framework.Scriptable {
        global void run () {
            Framework.Log.push(PackageScripts.Install.class.getName(), 'run');
            try {

                Framework.RegisteredApp evwk = new Framework.RegisteredApp();
                evwk.namespace = PackageUtils.namespace;
                evwk.name = 'Fonteva Event Workflows';
                evwk.description = 'Fonteva Event Workflows';
                evwk.isManaged = true;
                evwk.isEnabled = true;
                evwk.installClass = PackageScripts.Install.class.getName();
                Framework.Config.push(evwk);

                Framework.CustomScript[] customScripts = new List<Framework.CustomScript>();

                Framework.CustomScript cs1 = new Framework.CustomScript();
                cs1.apexClass = PackageScripts.Install.class.getName();
                cs1.namespace = PackageUtils.namespace;
                cs1.name = 'Run Install Scripts (EVWK)';
                cs1.description = 'Runs all installation scripts for Fonteva Event Workflow Package.';
                customScripts.add(cs1);

                Framework.Config.push(customScripts);
                
                
                //------------- Begin: Routing Rules creation (Alphabetical Order)--------------------//
                Framework.RoutingRule[] rules = new List<Framework.RoutingRule>();

                // EventApi__Attendee__c ** Routing Rule Extension **
                // ---------------------------------------------------------------------
                Framework.RoutingRule a = new Framework.RoutingRule();
                a.apexClass = Attendees.class.getName();
                a.namespace = PackageUtils.namespace;
                a.isEnabled = true;
                a.sObjectName = SObjectType.EventApi__Attendee__c.getName();
                a.executionOrder = 0;
                rules.add(a);

                // EventApi__Event__c ** Routing Rule Extension **
                // ---------------------------------------------------------------------
                Framework.RoutingRule e = new Framework.RoutingRule();
                e.apexClass = Events.class.getName();
                e.namespace = PackageUtils.namespace;
                e.isEnabled = true;
                e.sObjectName = SObjectType.EventApi__Event__c.getName();
                e.executionOrder = 0;
                rules.add(e);
    
                // EventApi__Venue__c ** Routing Rule Extension **
                // ---------------------------------------------------------------------
                Framework.RoutingRule v = new Framework.RoutingRule();
                v.apexClass = Venues.class.getName();
                v.namespace = PackageUtils.namespace;
                v.isEnabled = true;
                v.sObjectName = SObjectType.EventApi__Venue__c.getName();
                v.executionOrder = 0;
                rules.add(v);
    
                // OrderApi__Receipt__c ** Routing Rule Extension **
                // ---------------------------------------------------------------------
                Framework.RoutingRule r = new Framework.RoutingRule();
                r.apexClass = Receipts.class.getName();
                r.namespace = PackageUtils.namespace;
                r.isEnabled = true;
                r.sObjectName = SObjectType.OrderApi__Receipt__c.getName();
                r.executionOrder = 0;
                rules.add(r);
                
                Framework.Config.push(rules);

            } 
            catch ( Exception ex ) {
                Framework.Log.debugException(ex);
            }
            Framework.Log.pop();
        }
    }
    
    
}