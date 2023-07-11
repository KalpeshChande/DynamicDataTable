/**
 * @description       : A utility class for working with picklist fields in Salesforce.
 * @author            : kalpesh.chande@skinternational.com
 * @group             : 
 * @last modified on  : 05-19-2023
 * @last modified by  : kalpesh.chande@skinternational.com
**/
public with sharing class PicklistColumnUtils {
     /**
     * Represents a picklist value with its label and value.
     */
    public class PicklistValue {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;

        /**
         * Constructs a new PicklistValue instance.
         *
         * @param label The label of the picklist value.
         * @param value The value of the picklist value.
         */
        public PicklistValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /**
    * @description :Retrieves the active picklist values for a given object and field.
    * @param objectName :The name of the object.
    * @param fieldName :The name of the field.
    * @return List<PicklistValue> :The list of active picklist values.
    **/
    public static List<PicklistValue> getPicklistValues(String objectName,String fieldName) {
        List<Schema.PicklistEntry> entries = new List<Schema.PicklistEntry>();
        Schema.DescribeSobjectResult objDescription = Schema.describeSObjects(
            new List<String>{ objectName }
        )[0];
        Schema.SObjectField field = objDescription.fields.getMap()
            .get(fieldName);

        entries = field.getDescribe().getPickListValues();
        entries = getActivePicklistEntries(entries);

        List<PicklistValue> picklistValues = new List<PicklistValue>();

        for (Schema.PicklistEntry pvalue : entries) {
            picklistValues.add(
                new PicklistValue(pvalue.getLabel(), pvalue.getValue())
            );
        }

        return picklistValues;
    }

    /**
    * @description :Filters and retrieves the active picklist entries from a list of picklist entries.
    * @param entries :The list of picklist entries.
    * @return List<Schema.PicklistEntry> :The list of active picklist entries.
    **/
    private static List<Schema.PicklistEntry> getActivePicklistEntries(
        List<Schema.PicklistEntry> entries
    ) {
        List<Schema.PicklistEntry> activeEntries = new List<Schema.PicklistEntry>();
        for (Schema.PicklistEntry entry : entries) {
            if (entry.isActive()) {
                activeEntries.add(entry);
            }
        }
        return activeEntries;
    }
}