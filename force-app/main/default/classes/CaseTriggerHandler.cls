public class CaseTriggerHandler {
	public static void handleBeforeDelete(List<Case> oldRecords)
    {
        Id currentUserProfileId = UserInfo.getProfileId();
        Id sysAdminProfileId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        
        for(Case casRec : oldRecords)
        {
            if(currentUserProfileId != sysAdminProfileId)
            {
                casRec.addError('You dont have permission to delete Case. Contact your System Administrator');
            }
        }
    }
    
    public static void CaseInsertHandler(List<Case> caseRecords){
        
    }
    
    public static void CaseUpdateHandler(List<Case> caseRecords, Map<Id,Case> caseOldMap){
        
    }
    
    public static void CaseDeleteHandler(List<Case> oldCaseRecords){
        
    }
    
    public static void CaseUndeleteHandler(List<Case> caseRecords){
        
    }
}