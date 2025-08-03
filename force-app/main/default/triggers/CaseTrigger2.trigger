/*
* @description      : Trigger to handle Case closure events
* @author           : Sai Vardhan Marupalla
* @last modified on : 08-03-2025
* @last modified by : Sai Vardhan Marupalla
*/

/*
* Problem Statement:
* - When a Case is closed (Status = 'Closed'), if the related Account has more than 3 open cases, then:
   1. Send an email alert to the Account Owner.
   2. Create a follow-up Task for the Account Owner.
   3. Log a custom object record called Case_Closure_Log__c with Case Id, Account Id, Owner Name, and Date.
*/

trigger CaseTrigger2 on Case (after update) {
    CaseTriggerHandler2.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}