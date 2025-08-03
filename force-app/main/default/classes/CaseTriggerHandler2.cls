/*
* @description      : This class is a placeholder for handling after update logic for Case records.
* @author           : Sai Vardhan Marupalla
* @last modified on : 08-03-2025
* @last modified by : Sai Vardhan Marupalla
*/

public with sharing class CaseTriggerHandler2 {
    public static void handleAfterUpdate(List<Case> newCases, Map<Id, Case> oldMap){   
        Set<Id> accountIds = new Set<Id>();
        List<Case> closedCases = new List<Case>();
        List<Task> tasksToInsert = new List<Task>();
        List<Case_Closure_Log__c> closureLogsToInsert = new List<Case_Closure_Log__c>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        if(!newCases.isEmpty()){
            for(Case newCase : newCases){
                if(newCase.Status == 'Closed' && oldMap.get(newCase.Id).Status != 'Closed'){
                    closedCases.add(newCase);
                    if(newCase.AccountId != null){
                        accountIds.add(newCase.AccountId);
                    }
                }
            }
        }

        if(closedCases.isEmpty()){
            return;
        }

        Map<Id, Integer> accOpenCaseCountMap = getOpenCaseCountByAccount(accountIds);
        Map<Id, Account> accountMap = [SELECT Id, OwnerId, Name FROM Account WHERE Id IN: accountIds];

        for(Case closedCase : closedCases){
            Integer openCaseCount = accOpenCaseCountMap.get(closedCase.AccountId);
            if(openCaseCount != null && openCaseCount > 3){

                Case_Closure_Log__c closureLog = new Case_Closure_Log__c();
                closureLog.Case__c = closedCase.Id;
                closureLog.Closed_Date__c = System.TODAY();
                closureLog.Account__c = closedCase.AccountId;
                closureLog.Owner__c = accountMap.get(closedCase.AccountId).OwnerId;
                closureLog.Reason__c = 'More than 3 open cases';
                closureLogsToInsert.add(closureLog);

                Task task = new Task();
                task.Subject = 'Follow up on closed case';
                task.WhatId = closedCase.AccountId;
                task.OwnerId = accountMap.get(closedCase.AccountId).OwnerId;
                task.Description = 'The account has more than 3 open cases. Please follow up.';
                task.Priority = 'High';
                task.ActivityDate = System.TODAY().addDays(1);
                task.Status = 'Not Started';
                tasksToInsert.add(task);

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(accountMap.get(closedCase.AccountId).OwnerId);
                email.setSubject('Follow up required for account with multiple open cases');
                email.setPlainTextBody('The account ' + accountMap.get(closedCase.AccountId).Name + ' has more than 3 open cases. Please follow up with the account owner.');   
                email.setSaveAsActivity(false);
                emailsToSend.add(email);
            }
        }

        if(!closureLogsToInsert.isEmpty()){
            insert closureLogsToInsert;
        }

        if(!tasksToInsert.isEmpty()){
            insert tasksToInsert;
        }   

        if(!emailsToSend.isEmpty()){
            Messaging.sendEmail(emailsToSend);
        }
    }

    public static Map<Id, Integer> getOpenCaseCountByAccount(Set<Id> accountIds){

        Map<Id, Integer> accOpenCaseCountMap = new Map<Id, Integer>();
        if(accountIds.isEmpty()){
            return accOpenCaseCountMap;
        }

        List<AggregateResult> results = [SELECT AccountId, COUNT(Id) count FROM Case WHERE AccountId IN: accountIds AND Status != 'Closed' GROUP BY AccountId];
        for(AggregateResult ar : results){
            Id accountId = (Id)ar.get('AccountId');
            Integer count = (Integer)ar.get('count');
            accOpenCaseCountMap.put(accountId, count);
        }
        return accOpenCaseCountMap;
    }
}