public without sharing class MatrixTriggerHelper {

    // make sure duplicate matrix records so not get created
    public static void setExternalId(List<StandardProductInventoryMatrix__c> mList) {
        
        Set<String> matrixNameSet = new Set<String>(); 
        List<StandardProductInventoryMatrix__c> currentList = [Select Name from StandardProductInventoryMatrix__c];
        
        for (StandardProductInventoryMatrix__c c: currentList) {
            matrixNameSet.add(c.Name);
        }

        for (StandardProductInventoryMatrix__c m: mList) {
            m.externalId__c = m.glassComposition__c+'; '+m.thickness__c+'mm; '+m.customwidth__c+'mm x '+m.customlength__c+'mm; '+m.productLine__c;            
            
            if (!matrixNameSet.contains(m.externalId__c)) {
                matrixNameSet.add(m.externalId__c);
            } else {
                m.addError('Matrix entry already exists.');
            }                       
        }

    }

    // make sure Glass Composition, Thickness, Width, Length are immutable
    public static void checkForChanges(List<StandardProductInventoryMatrix__c> mList, Map<Id, StandardProductInventoryMatrix__c> oldMap) {

         for (StandardProductInventoryMatrix__c m: mList) {
             
            if (((oldMap.get(m.ID).customWidth__c != m.customWidth__c) && oldMap.get(m.ID).customWidth__c != Null) ||
             ((oldMap.get(m.ID).customLength__c != m.customLength__c) && oldMap.get(m.ID).customLength__c != Null) ||
             (oldMap.get(m.ID).thickness__c != m.thickness__c) ||
             (oldMap.get(m.ID).glassComposition__c != m.glassComposition__c)) {          
                m.addError('Glass Composition, Thickness, Width and Length cannot be changed.');
            }                       
        }       
        
    }    
    
    // make sure the Product2 active status is set
    public static void productActivation(List<StandardProductInventoryMatrix__c> mList, Map<Id, StandardProductInventoryMatrix__c> oldMap) {
        
        Map<String, Boolean> changeMap = new Map<String, Boolean>();
        List<String> productNameList = new List<String>();
        List<Product2> prodUpdateList = new List<Product2>();
        
        for (StandardProductInventoryMatrix__c m: mList) {
             
            if (oldMap.get(m.ID).isActive__c != m.isActive__c) {
                changeMap.put(m.name,m.isActive__c);
                productNameList.add(m.name);
            }                       
        }   
        
        List<Product2> prod2List = [SELECT id, name, isActive FROM Product2 WHERE name IN :productNameList];
        
        for (Product2 p: prod2List) {
        
            if( changeMap.ContainsKey(p.name) ){
                p.IsActive = changeMap.get(p.name);
                prodUpdateList.add(p);
            }
                                     
        }
        
        if (prodUpdateList.size() > 0) {
            update prodUpdateList;
        }
        
    }    
    
}