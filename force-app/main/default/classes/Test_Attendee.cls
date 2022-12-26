@isTest
public class Test_Attendee {

    static Boolean isInstalled = false;
 
    private static void install() {  
        if (!isInstalled) {
            Framework.Installer.install();
            PagesApi.PackageScripts.install();
            OrderApi.PackageScripts.install();
            EventApi.PackageScripts.install();
            new PackageScripts.install().run();
            isInstalled = true; 
        }
    }
    
}