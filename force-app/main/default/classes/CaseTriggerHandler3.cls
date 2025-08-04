/*
* @description      : This class handles case trigger logic, including preventing priority downgrades and managing high priority cases.
* @author           : Sai Vardhan Marupalla
* @last modified on : 08-03-2025
* @last modified by : Sai Vardhan Marupalla
*/

public with sharing class CaseTriggerHandler3 {

    // This method prevents the downgrade of case priority from High to any other level unless the user is a System Administrator.
    public static void preventPriorityDowngrade(List<Case> newCases, Map<Id, Case> oldMap) {
        Profile systemAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        for(Case c : newCases){
            if(c.Priority != 'High' && oldMap.get(c.Id).Priority == 'High' && UserInfo.getProfileId() != systemAdminProfile.Id) {
                c.Priority = 'High';
                c.addError('You cannot downgrade the priority of a case from High to another level.');
            }
        }
    }

    // This method handles high priority cases for key customers, creating tasks and change logs as necessary.
    public static void handleHighPriorityCases(List<Case> newCases, Map<Id, Case> oldMap){
        Set<Id> accountIds = new Set<Id>();
        List<Task> tasksToInsert = new List<Task>();
        List<Case_Change_Log__c> changeLogsToInsert = new List<Case_Change_Log__c>();

        if(!newCases.isEmpty()){
            for(Case newCase : newCases){
                if(newCase.AccountId != null){
                    accountIds.add(newCase.AccountId);
                }
            }
        }

        Map<Id, Account> accountMap = [SELECT Id, Type, OwnerId, Name FROM Account WHERE Id IN: accountIds];
        for(Case c : newCases){
            if(c.Priority == 'High' && accountMap.get(c.AccountId) != null && accountMap.get(c.AccountId).Type == 'Key Customer'){

                Task task = new Task();
                task.Subject = 'Follow up on high priority case';
                task.WhatId = c.AccountId;
                task.OwnerId = accountMap.get(c.AccountId).OwnerId;
                task.Description = 'A high priority case has been created for a key customer. Please follow up.';
                task.Priority = 'High';
                task.ActivityDate = System.TODAY().addDays(1);
                task.Status = 'Not Started';
                tasksToInsert.add(task);

                if(oldMap != null && (c.Priority != oldMap.get(c.Id).priority || c.Status != oldMap.get(c.Id).Status)){
                    Case_Change_Log__c changeLog = new Case_Change_Log__c();
                    changeLog.Case__c = c.Id;
                    changeLog.Old_Priority__c = oldMap.get(c.Id).Priority;
                    changeLog.New_Priority__c = c.Priority;
                    changeLog.Old_Status__c = oldMap.get(c.Id).Status;
                    changeLog.New_Status__c = c.Status;
                    changeLog.changedBy__c = UserInfo.getUserId();
                    changeLog.Changed_Date__c = System.now();
                    changeLogsToInsert.add(changeLog);
                }
            }            
        }

        if(!tasksToInsert.isEmpty()){
            insert tasksToInsert;
        }

        if(!changeLogsToInsert.isEmpty()){
            insert changeLogsToInsert;
        }
    }
}