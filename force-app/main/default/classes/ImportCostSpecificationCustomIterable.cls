/*******************************************************************************************************
Class Name       : ImportCostSpecificationCustomIterable
Purpose          : This is the pagination class which have next and previous methods
Author           : 
Revision History : 
 * *****************************************************************************************************/
global class ImportCostSpecificationCustomIterable implements Iterator <list <ImportCostSpecificationDataWrapper>> {
    list <ImportCostSpecificationDataWrapper> InnerList { get; set; } // Holds all the values
    list <ImportCostSpecificationDataWrapper> ListRequested { get; set; } // Holds the value to be displayed on the Page
    public Integer i { get; set; }
    public Integer setPageSize { get; set; }
    public Integer rowNum { get; set; }
    
    public ImportCostSpecificationCustomIterable(){}

    //Constructor
    public ImportCostSpecificationCustomIterable(List <ImportCostSpecificationDataWrapper> lstSidWr) {
        // Global_Variable__c myCS2 = Global_Variable__c.getInstance('Training_Data_Pagesize');
        InnerList = new list <ImportCostSpecificationDataWrapper> ();
        ListRequested = new list <ImportCostSpecificationDataWrapper> ();
        InnerList = lstSidWr;
        setPageSize = 10; // integer.valueOf(myCS2.Value__c);
        i = 0;
    }

    global boolean hasNext() {
        if (i >= InnerList.size()) {
            return false;
        } else {
            return true;
        }
    }

    global boolean hasPrevious() {
        if (i <= setPageSize) {
            return false;
        } else {
            return true;
        }
    }

    //Method to get next page records
    global list <ImportCostSpecificationDataWrapper> next() {
        ListRequested = new list <ImportCostSpecificationDataWrapper>();
        integer startNumber;
        integer size = InnerList.size();
        if (hasNext()) {
            if (size <= (i + setPageSize)) {
                startNumber = i;
                i = size;
            } else {
                i = (i + setPageSize);
                startNumber = (i-setPageSize);
            }
            for (integer start = startNumber; start < i; start++) {
                ListRequested.add(InnerList[start]);
            }
        }
        rowNum = startNumber;
        return ListRequested;
    }
    
    //Method to get previous page records
    global list <ImportCostSpecificationDataWrapper> previous() {
        ListRequested = new list <ImportCostSpecificationDataWrapper> ();
        integer size = InnerList.size();
        if (i == size) {
            if (math.mod(size,setPageSize) > 0) {
                i = size-math.mod(size,setPageSize);
            } else {
                i = (size-setPageSize);
            }
        } else {
            i = (i-setPageSize);
        }

        for (integer start = (i-setPageSize); start < i; ++start) {
            ListRequested.add(InnerList[start]);
        }
        rowNum = (i-setPageSize);
        return ListRequested;
    }
}