/*
* @description      : Trigger to handle Case creation and updates with specific conditions.
* @author           : Sai Vardhan Marupalla
* @last modified on : 08-03-2025
* @last modified by : Sai Vardhan Marupalla
*/

/*
* Problem Statement:
* - When a Case is created or updated with Priority = High and its related Account's Type = "Key Customer", the system must:
    1: Auto-create a Task assigned to the Account Owner with a due date = 2 business days.
    2: Prevent Priority downgrade from High to Medium/Low by any user except System Admin.
    3: Log the change in a custom object Case_Change_Log__c if the Status or Priority changes.
*/

trigger CaseTrigger3 on Case (before update,after insert, after update) {
    if(Trigger.isBefore && Trigger.isUpdate){
        CaseTriggerHandler3.preventPriorityDowngrade(Trigger.new, Trigger.oldMap);        
    }

    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        CaseTriggerHandler3.handleHighPriorityCases(Trigger.new, Trigger.oldMap);
    }
}