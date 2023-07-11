/**
 * @description       : The IconUtils class provides utility methods for retrieving the icon name for a given SObject.
 * @author            : kalpesh.chande@skinternational.com
 * @group             : 
 * @last modified on  : 05-19-2023
 * @last modified by  : kalpesh.chande@skinternational.com
**/
public class IconUtils {
    /**
    * @description :Retrieves the icon name for a given SObject.
    * @param sObjectName :sObjectName The name of the SObject.
    * @return String : The icon name for the SObject.
    **/
    public static String getIconName(String sObjectName) {
        String iconName = '';
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        system.debug('tabSetDesc'+tabSetDesc);
        
        for (Schema.DescribeTabSetResult tsr : tabSetDesc) {
            tabDesc.addAll(tsr.getTabs());
        }
		system.debug('tabDesc'+tabDesc);
        for (Schema.DescribeTabResult tr : tabDesc) {
            if (sObjectName == tr.getSobjectName()) {
                if (tr.isCustom() == true) {
                    iconDesc.addAll(tr.getIcons());
                    system.debug('tabSetDesc'+iconDesc);
                } else {
                    iconName = 'standard:' + sObjectName.toLowerCase();
                    break;
                }
            }
        }

        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml') {
                iconName =
                    'custom:' +
                    ir.getUrl()
                        .substringBetween('custom/', '.svg')
                        .substringBefore('_');
                break;
            }
        }
 		system.debug('iconName'+iconName);
        return iconName;
    }
}