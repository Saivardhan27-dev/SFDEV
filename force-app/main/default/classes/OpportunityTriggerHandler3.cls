/*
* @description      : 
* @author           : Sai Vardhan Marupalla
* @last modified on : 07-27-2025
* @last modified by : Sai Vardhan Marupalla
*/

public with sharing class OpportunityTriggerHandler3 {

    public static void handleCloseWon(List<Opportunity> oppRecords, Map<Id, Opportunity> oldMap){

        List<Project__c> projectListToInsert = new List<Project__c>();
        List<Quote> quoteListToUpdate = new List<Quote>();
        List<Task> taskListToInsert = new List<Task>();

        Set<Id> oppIds = new Set<Id>();

        for(Opportunity opp : oppRecords){
            if((oldMap == null && opp.StageName == 'Closed Won') || (oldMap != null && oldMap.get(opp.Id).StageName != 'Closed Won')){

                Project__c project = new Project__c();
                project.Opportunity__c = opp.Id;
                project.Name = opp.Name + ' - Project';
                project.Closed_Date__c = opp.CloseDate;
                project.Amount__c = opp.Amount;
                projectListToInsert.add(project);

                oppIds.add(opp.Id);

                if(opp.Amount > 100000){
                    Task task = new Task();
                    task.Subject = 'High Value Opportunity Follow-up';
                    task.WhatId = opp.Id;
                    task.Priority = 'High';
                    task.Status = 'Not Started';
                    task.OwnerId = opp.OwnerId;
                    taskListToInsert.add(task);
                }
            }
        }

        if(!oppIds.isEmpty()){
            List<Quote> quotes = [SELECT Id,Status,OpportunityId FROM Quote WHERE OpportunityId IN :oppIds];
            for(Quote quote : quotes){
                quote.Status = 'Accepted';
                quoteListToUpdate.add(quote);
            }
        }

        if(!projectListToInsert.isEmpty()){
            insert projectListToInsert;
        }

        if(!quoteListToUpdate.isEmpty()){
            update quoteListToUpdate;
        }

        

    }    
}