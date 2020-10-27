({
    init: function (cmp, event, helper) {
        // Get the empApi component
        const empApi = cmp.find('empApi');

        empApi.onError($A.getCallback(error => {
            console.error('EMP API error: ', JSON.stringify(error));
        }));
        helper.subscribe(cmp, event);
            
        cmp.set('v.columns', [
            {label: 'Title', 
             fieldName: 'documentViewLink', 
             type: 'url', 
             typeAttributes: { 
                 target: '_blank', 
                 label: {
                     fieldName: 'title'
                 }
             }
            },
            {label: 'Owner', 
             fieldName: 'ownerLink', 
             type: 'url',
             typeAttributes: { 
                 target: '_blank',
                 label: {
                         fieldName: 'ownername'
                     }
             }
            },
            {
                label: 'Last Modified',
                fieldName: 'lastModifiedDate',
                type: 'date',
                typeAttributes: {
                    weekday: 'short',
                    year: 'numeric',
                    month: 'short',
                    day: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                }
            },
            {label: 'Size', 
             fieldName: 'size', 
             type: 'text'
            }
        ]);
        
        helper.fetchFilesDetailsHelper(cmp);
        
    },

    updateSelectedText: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows', selectedRows);
        cmp.set('v.selectedRowsCount', selectedRows.length);
        var documentIds = new Array();
        for(var i=0; i<selectedRows.length; i++){
            documentIds.push(selectedRows[i].recordId);
        }
        console.log('documentIds', documentIds);
        cmp.set("v.selectedDocumentIds", documentIds);
        
        if(documentIds.length > 0){
            cmp.set("v.disableButton", false);
        }
    },
    
    deleteFiles: function(cmp, event, helper){
        helper.deleteFilesDetailsHelper(cmp);
    },
    
    downloadFiles: function(cmp, event, helper){
        helper.downloadFilesHelper(cmp);
    },
});