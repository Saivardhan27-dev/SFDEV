/*
* @description      : Trigger to handle Opportunity close won events
* @author           : Sai Vardhan Marupalla
* @last modified on : 07-27-2025
* @last modified by : Sai Vardhan Marupalla
*/

/*
* Problem Statement:
* - When an Opportunity is marked as Closed Won:
  - Create a related Custom Object: Project__c record with details from the Opportunity.
  - Update all related Quote records’ Status__c to "Approved".
  - If the Amount on Opportunity > 1,000,000, create a Task assigned to the Account Owner for a follow-up.
*/

trigger OpportunityTrigger3 on Opportunity (after insert,after update) {
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        OpportunityTriggerHandler3.handleCloseWon(Trigger.new, Trigger.oldMap);
    }
}