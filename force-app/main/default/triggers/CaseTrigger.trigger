trigger CaseTrigger on Case (after insert,after update,after delete,after undelete) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        CaseTriggerHandler.CaseInsertHandler(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        CaseTriggerHandler.CaseUpdateHandler(Trigger.new,Trigger.oldMap);
    }
    
    if(Trigger.isAfter && Trigger.isDelete){
        CaseTriggerHandler.CaseDeleteHandler(Trigger.old);
    }
    
    if(Trigger.isAfter && Trigger.isUndelete){
        CaseTriggerHandler.CaseUndeleteHandler(Trigger.new);
    }
}