trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before delete) {
    if(trigger.isBefore){
        if(trigger.isDelete){    
            ContentDocumentLinkTriggerHelper.beforeDelete(trigger.old);
        }
    }
    if(trigger.isAfter){
        ContentDocumentLinkTriggerHelper.afterInsert(trigger.new);
    }
}