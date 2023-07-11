# Dynamic Data Table

## Description

This component is designed to display a dynamic datatable for a specific object, allowing users to view, edit, and delete records.

## How to use
```
<sfdc-lwc-lightning-datatable 
  title="Data Table" objectName="Account" fields="FirstName LastName,AccountId ,
  CreatedDate,Account.Name" predefinedCol="{"Account.Name":{"label":"Account Name","type":"url","typeAttributes":{"label": { "fieldName": "Account.Name","recId":"AccountId"}}},"AccountId":{"label":"Ac Id","type":"Id"}}" 
  relatedFieldAPI="AccountId"  whereClause="FirstName!=null" isCounterDisplayed=true actionButtons="[{"name": "New","label": "New","variant": "neutral"}]" 
  hasSearchBar=true showCheckboxes=true showRowNumber=true isEditEnabled=true hasPagination=true maxRecordCount=2000 navigatecmpbtn="Navigate To Cmp"
  showCheckboxes=true componentname="chatGPT">
 </sfdc-lwc-lightning-datatable>
```

## Properties And Events
```
Data Table : Name of the table.
Account :The data table is retrieving and displaying records from the Account object in Salesforce.
FirstName LastName,AccountId,CreatedDate,Account.Name : Fields of object
predefinedCol :Lookup column in the data table.
AccountId :"AccountId" field is used for relating or linking records in the data table.
FirstName!=null :Filter of SOQL query.
```
