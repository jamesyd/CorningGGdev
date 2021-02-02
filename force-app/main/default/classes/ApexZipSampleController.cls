/**
 * A controller class that zip all attachments of object (Id=0011000000uzA9u),
 * and redirect to download url.
 */
public with sharing class ApexZipSampleController {

  public ApexZipSampleController() {
  }
  
  /**
   * Zip files and redirect to download url of zip ducument
   * @return [description]
   */
  public PageReference downloadAttachments(){
    System.debug('>>> heapsize1=' + limits.getHeapSize() +'/' + limits.getLimitHeapSize());
    String objectId = '0010n00001AX9wTAAT'; // your object's Id
    String docName = 'apex-zip-sample.zip'; // Document's name
    System.debug('JDJD: downloadAttachments ....');

    //List<ContentDocument> attachments = [SELECT Name, Title, Id FROM ContentDocument WHERE ParentId = :objectId];
    //List<Attachment> attachments = [SELECT Name, Body FROM Attachment WHERE ParentId = :objectId];
    List<ContentVersion> attachments = [SELECT Id,Title,ownerId,FileType,FileExtension,VersionData,ContentSize,ContentDocumentId from contentVersion];
    System.debug('>>> attachments count=' + attachments.size());
    Zippex sampleZip = new Zippex();
    Integer count=0;
    System.debug('>>> heapsize3=' + limits.getHeapSize() +'/' + limits.getLimitHeapSize());
    //for(Attachment file : attachments) {
    for (ContentVersion file : attachments) {
      System.debug('>>> file=' + file.Title + ' type='+file.FileType +' size=' + file.ContentSize +' docId='+ file.ContentDocumentId);
      //sampleZip.addFile('folder/' + file.Name, file.Body, null);      // original for versions ...
      System.debug('>>> zipped file name='+ 'folder/' + file.Title+'.'+file.FileExtension);
      if (++count < 4) {
          System.debug('>>> added to zip ..');
          sampleZip.addFile('folder/' + file.Title+'.'+file.FileExtension, file.VersionData, null);
          System.debug('>>> heapsize5=' + limits.getHeapSize() +'/' + limits.getLimitHeapSize());
      }

      //break;
    }
    System.debug('>>> heapsize7=' + limits.getHeapSize() +'/' + limits.getLimitHeapSize());
    attachments.clear();
    System.debug('>>> heapsize9=' + limits.getHeapSize() +'/' + limits.getLimitHeapSize());
    try{
      Document doc = new Document();
      doc.FolderId = UserInfo.getUserId();
      doc.Name = docName;
      System.debug('>>> getZipArchive');
      doc.Body = sampleZip.getZipArchive();
      System.debug('>>> insert doc');
      insert doc;
      System.debug('>>> docId=' + doc.Id);
      System.debug('>>> docName=' + doc.Name);
      return new PageReference('/servlet/servlet.FileDownload?file=' + doc.Id);
    } catch ( Exception ex ) {
      System.debug('>>> ERROR ' + ex);
    }

    return null;
  }
}