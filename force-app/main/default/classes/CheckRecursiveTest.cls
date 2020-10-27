@isTest
public class CheckRecursiveTest {

    private static testmethod void testIt() {
        Boolean ok;
        if(checkRecursive.runOnce()) {
            ok = true;
        } 
        
        if(!checkRecursive.runOnce()) {
            ok = false;
        }      
    }    
}