/**
 * @description       : The RelatedList class is used for building the Column JSON for a data table.
 *                      It provides methods for constructing the column JSON based on various parameters.
 * @author            : kalpesh.chande@skinternational.com
 * @group             : 
 * @last modified on  : 05-19-2023
 * @last modified by  :  kalpesh.chande@skinternational.com
**/
public with sharing class RelatedList {
     /**
     * Mapping of field types to LWC data types.
     */
    private static Map<String, String> mapFieldToLwcDataType = new Map<String, String>{
        'datetime' => 'date',
        'date' => 'date-local',
        'percent' => 'percent-fixed'
    };
     /**
     * Inner class representing a column in the JSON format.
     */
    public class ColumnJson {
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean editable;
        @AuraEnabled
        public Boolean sortable;
        @AuraEnabled
        public Boolean wrapText = false;
        @AuraEnabled
        public String iconName;
        @AuraEnabled
        public Boolean displayReadOnlyIcon;
        @AuraEnabled
        public TypeAttributes typeAttributes = null;
    }

     /**
     * Virtual class serving as a base class for TypeAttributes.
     */
    public virtual class TypeAttributes {}

    /**
     * TypeAttributes subclass for columns with picklist values.
     */
    public class TypeAttributeColumnJsonWithPicklist extends TypeAttributes {
        @AuraEnabled
        public List<PicklistColumnUtils.PicklistValue> options = new List<PicklistColumnUtils.PicklistValue>();
        @AuraEnabled
        public TypeAttributeContext context = new TypeAttributeContext();
        @AuraEnabled
        public String fieldName;

        public TypeAttributeColumnJsonWithPicklist(List<PicklistColumnUtils.PicklistValue> options, String fieldName) {
            this.options = options;
            this.fieldName = fieldName;
        }
    }

    public class TypeAttributeContext {
        @AuraEnabled
        public string fieldName = 'Id';
    }
 
    /**
     * TypeAttributes subclass for lookup columns.
     */
    public class TypeAttributeColumnLookup extends TypeAttributes {
        public String placeholder;
        public String objectApiName;
        public String fieldName;
        public String label;
        public TypeAttributeColumnLookupValue value = new TypeAttributeColumnLookupValue();
        public TypeAttributeContext context = new TypeAttributeContext();
        public String variant = 'label-hidden';
        public String name;
        public List<String> fields;
        public String target = '_self';
        
    }

    public class TypeAttributeColumnLookupValue {
        public String fieldName;
    }

    /**
     * TypeAttributes subclass for textarea columns.
     */
    public class TypeAttributeColumnTextarea extends TypeAttributes {
        @AuraEnabled
        public TypeAttributeContext context = new TypeAttributeContext();
        @AuraEnabled
        public String fieldName;

        public TypeAttributeColumnTextarea(String fieldName) {
            this.fieldName = fieldName;
        }
        
    }

     /**
     * Inner class representing the results of the list.
     */
    public class ListResults {
        @AuraEnabled
        public List<SObject> records;
        @AuraEnabled
        public Map<String, ColumnJson> cols;
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public String iconName;
         @AuraEnabled
        public boolean isCreatable;
        public ListResults(
            List<SObject> records,
            Map<String, ColumnJson> cols,
            Integer count,
            String iconName,
            boolean isCreatable
        ) {
            this.records = records;
            this.cols = cols;
            this.count = count;
            this.iconName = iconName;
            This.isCreatable = isCreatable;
        }
    }

   
    /**
     * @description: Builds the Column JSON for a data table.
     * 
     * @param soql: The SOQL query to fetch the records.
     * @param objectName: The API name of the object.
     * @param whereClause: The WHERE clause for filtering the records.
     * @param colsJson: The JSON representation of columns.
     * @param isEditable: Specifies if the columns are editable.
     * @return The ListResults object containing the records, columns, count, iconName, and isCreatable values.
     * @throws AuraHandledException if an error occurs during the execution.
     */
    @AuraEnabled
    public static ListResults buildFieldJSON(String soql,String objectName,String whereClause,String colsJson,boolean isEditable) {
        try {
            Map<String, ColumnJson> mapPreCols = (Map<String, ColumnJson>) Json.deserialize(
                colsJson,
                Map<String, ColumnJson>.class
            );
            SObjectType objType = Schema.getGlobalDescribe().get(objectName);
            Map<String, Schema.SObjectField> mfields = objType.getDescribe()
                .fields.getMap();
            List<ColumnJson> lstOfColumns = new List<ColumnJson>();
            system.debug('mapPreCols.keySet()'+mapPreCols.keySet());
             system.debug('mapPreCols.keySet()'+mapPreCols.values());
            for (String fieldName : mapPreCols.keySet()) {
                if(isEditable==true){
                //continue;
                if (fieldName.contains('.')) {
                    continue;
                }
                //Check if values predefined in LWC
                if (mapPreCols.containsKey(fieldName)) {
                    switch on mapPreCols.get(fieldName).type {
                        when 'lookup' {
                                system.debug('inside inline');
                            mapPreCols.get(fieldName).typeAttributes = new TypeAttributeColumnLookup();
                            
                        }
                        when 'picklist' {
                            //check if the field is of type picklist in custom json => if so allow edit
                            RelatedList.initPicklistColumn(
                                mapPreCols,
                                objectName,
                                fieldName,
                                isEditable
                            );
                        }
                        when 'textarea' {
                            mapPreCols.get(fieldName).typeAttributes = new TypeAttributeColumnTextarea(fieldName);
                        }
                    }

                    String type = mapPreCols.get(fieldName).type;
                    system.debug('mapPreCols===>'+mapPreCols);
                    system.debug('isEditable===>'+isEditable);
                    mapPreCols = checkOverride(mapPreCols, fieldName, mfields,isEditable);
                    //picklist list are set to editable by default, non editable picklist field are defined in the readme
                    if(String.isBlank(type) && mapPreCols.get(fieldName).type == 'picklist') {
                        RelatedList.initPicklistColumn(
                            mapPreCols,
                            objectName,
                            fieldName,
                            isEditable
                        );
                    }
                  }
                }else{
                    Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
                    Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
                    if(fieldName!=null && objectDescribe.fields.getMap().containsKey(fieldName)&&fieldName!=''){
                        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldName).getDescribe();
                        if(fieldDescribe!=null){
                            String fieldLabel = fieldDescribe.getLabel();
                            mapPreCols.get(fieldName).label=fieldLabel;
                             mapPreCols.get(fieldName).sortable=true;
                           // mapPreCols = checkOverride(mapPreCols, fieldName, mfields,isEditable);
                        }
                    }
                }
            }
            system.debug('mapPreCols@@@'+mapPreCols);
            return new ListResults(
                getRecords(soql),
                mapPreCols,
                countRecords(objectName, whereClause),
                IconUtils.getIconName(objectName),
                RelatedList.getObjectAccess(objectName)
            );  
        } catch (Exception e) {
            system.debug('e.getline'+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
 
    /**
    * @description :Checks if the current user has access to the object.
    * @param sObjectName : The API name of the object.
    * @return boolean :true if the user has access, false otherwise.
    **/
    public static boolean getObjectAccess(String sObjectName) {
        Id userId = UserInfo.getUserId();
        system.debug('userId'+userId);
        // Check if the user has create access to the object
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(sObjectName);
        system.debug('objectType'+objectType);
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        system.debug('objectDescribe'+objectDescribe);
        Boolean hasCreateAccess = objectDescribe.isCreateable();
        system.debug('hasCreateAccess'+hasCreateAccess);
        return hasCreateAccess;
    }

    /**
    * @description :Initializes the picklist column attributes.
    * @param mapPreCols :The map of field names to ColumnJson.
    * @param objectName :The API name of the object.
    * @param fieldName : The field name to initialize.
    * @param isEditable :Specifies if the columns are editable.
    **/
    public static void initPicklistColumn(Map<String, ColumnJson> mapPreCols,String objectName, String fieldName,boolean isEditable) {
        List<PicklistColumnUtils.PicklistValue> picklistValues = PicklistColumnUtils.getPicklistValues(
            objectName,
            fieldName
        );
        mapPreCols.get(fieldName).wrapText = true;
         mapPreCols.get(fieldName).editable = isEditable;
         mapPreCols.get(fieldName).displayReadOnlyIcon=isEditable;
        mapPreCols.get(fieldName).typeAttributes = new TypeAttributeColumnJsonWithPicklist(picklistValues, fieldName);
    }

    /**
    * @description :Retrieves the records based on the SOQL query.
    * @param soql : The SOQL query to fetch the records.
    * @return List<SObject> 
    **/
    @AuraEnabled
    public static List<SObject> getRecords(String soql) {
        try {
             system.debug('soql@@@'+soql);
            system.debug('soql@@@'+Database.query(soql));
            return Database.query(soql);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description :Searches for records based on the search term and other parameters.
    * @param searchTerm :The search term to search for.
    * @param objectApiName :The API name of the object to search in.
    * @param searchFields :The fields to search in.
    * @param whereClause :The WHERE clause for filtering the records.
    * @return List<SObject> 
    **/
    @AuraEnabled
    public static List<SObject> onSearch(String searchTerm,String objectApiName,String searchFields,String whereClause) {
        List<SObject> records = new List<SObject>();
        String sosl = 'FIND :searchTerm IN ALL FIELDS RETURNING {0}( {1} {2} ) ';
        List<String> condition = new List<String>{
            objectApiName,
            searchFields,
            String.isNotEmpty(whereClause) ? (' WHERE ' + whereClause) : ''
        };
        sosl = String.format(sosl, condition);
        List<List<SObject>> results = search.query(sosl);
        for (List<SObject> s : results) {
            records.addAll(s);
        }
        return records;
    }

    /**
    * @description :Counts the number of records based on the object API name and WHERE clause.
    * @param objectName :The API name of the object.
    * @param whereClause : The WHERE clause for filtering the records.
    * @return Integer : The count of records.
    **/
    @AuraEnabled(cacheable=true)
    public static Integer countRecords(String objectName, String whereClause) {
        String formattedWhere = (String.isBlank(whereClause))
            ? ''
            : ' ' + whereClause;

        if (String.isNotEmpty(objectName)) {
            return database.countQuery(
                'SELECT count() FROM ' +
                objectName +
                formattedWhere +
                ' WITH SECURITY_ENFORCED'
            );
        }
        return 0;
    } 

    /**
    * @description :Checks if the field should be overridden and updates the ColumnJson accordingly.
    * @param mapPreCols :The map of field names to ColumnJson.
    * @param fieldName :The field name to check.
    * @param mfields :The map of field names to SObjectField.
    * @param isEditable :Specifies if the columns are editable.
    * @return Map<String, ColumnJson> 
    **/
    private static Map<String, ColumnJson> checkOverride( Map<String, ColumnJson> mapPreCols,String fieldName,Map<String, Schema.SObjectField> mfields,boolean isEditable) {
        String label = mapPreCols.get(fieldName).label != null
                ? mapPreCols.get(fieldName).label
                : mfields.get(fieldName).getDescribe().getLabel(),
            type = mapPreCols.get(fieldName).type != null
                ? mapPreCols.get(fieldName).type.toLowercase()
                : String.valueOf(mfields.get(fieldName).getDescribe().getType())
                      .toLowercase();
        Boolean editable = mapPreCols.get(fieldName).editable != null
               ? mapPreCols.get(fieldName).editable
               : mfields.get(fieldName).getDescribe().isUpdateable(),
      	   // Boolean editable =isEditable,
            sortable = true,
            displayReadOnlyIcon=isEditable;
        //Update Map Json
        mapPreCols.get(fieldName).label = label;
        system.debug(' mapPreCols.get(fieldName).label@@'+ mapPreCols.get(fieldName).label);
        mapPreCols.get(fieldName).type = mapFieldToLwcDataType.containskey(type)
            ? mapFieldToLwcDataType.get(type)
            : type;
        mapPreCols.get(fieldName).editable = editable;
        mapPreCols.get(fieldName).sortable = sortable;
        return mapPreCols;
    }
}