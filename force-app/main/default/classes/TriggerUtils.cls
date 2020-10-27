/**
 * @File Name          : TriggerUtils.cls
 * @Description        : Helps to avoid trigger recurtion within triggers
 * @Author             : Arquimidez Mora
 * @Group              : 
 * @Last Modified By   : Arquimidez Mora
 * @Last Modified On   : 28/6/2020 18:59:13
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    28/6/2020   Arquimidez Mora     Initial Version
**/
public without sharing class TriggerUtils {

    /*******************************************************************
    Purpose: Checks if it's the first time the trigger run in after insert to avoid recurtion
    Parameters: [runStatus] Object with trigger current status
    ********************************************************************/
    /*public static Boolean isFirstRunInsert(TriggerRunStatus runStatus){
        if(runStatus.isFirstRunInsert){
            runStatus.isFirstRunInsert = false;
            return true;
        }else{
            return runStatus.isFirstRunInsert;
        }
    }*/

    /*******************************************************************
    Purpose: Checks if it's the first time the trigger run in after update to avoid recurtion
    Parameters: [runStatus] Object with trigger current status
    ********************************************************************/
    public static Boolean isFirstRunUpdate(TriggerRunStatus runStatus){
        if(runStatus.isFirstRunUpdate){
            runStatus.isFirstRunUpdate = false;
            return true;
        }else{
            return runStatus.isFirstRunUpdate;
        }
    }

    /*******************************************************************
    Purpose: Checks if it's the first time the trigger run in after delete to avoid recurtion
    Parameters: [runStatus] Object with trigger current status
    ********************************************************************/
    /*public static Boolean isFirstRunDelete(TriggerRunStatus runStatus){
        if(runStatus.isFirstRunDelete){
            runStatus.isFirstRunDelete = false;
            return true;
        }else{
            return runStatus.isFirstRunDelete;
        }
    }*/

    /*******************************************************************
    Purpose: Checks if it's the first time the trigger run in after undelete to avoid recurtion
    Parameters: [runStatus] Object with trigger current status
    ********************************************************************/
    /*public static Boolean isFirstRunUndelete(TriggerRunStatus runStatus){
        if(runStatus.isFirstRunUndelete){
            runStatus.isFirstRunUndelete = false;
            return true;
        }else{
            return runStatus.isFirstRunUndelete;
        }
    }*/

    public class TriggerRunStatus{
        public Boolean isFirstRunInsert;
        public Boolean isFirstRunUpdate;
        public Boolean isFirstRunDelete;
        public Boolean isFirstRunUndelete;

        public TriggerRunStatus(){
            this.isFirstRunInsert = true;
            this.isFirstRunUpdate = true;
            this.isFirstRunDelete = true;
            this.isFirstRunUndelete = true;
        }
    }
}