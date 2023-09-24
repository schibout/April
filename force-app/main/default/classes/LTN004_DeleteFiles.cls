public without sharing class LTN004_DeleteFiles {
    
	@AuraEnabled(cacheable=false)
    public static List<ContentDocument> retreiveCaseFilesInformation(Id caseId) {

        final Map<Id, EmailMessage> listEmail = new Map<Id, EmailMessage>([
            SELECT Id 
            FROM EmailMessage 
            WHERE ParentId =: caseId
        ]);
        
        final List<ContentDocument> result = new List<ContentDocument>();
        for(ContentDocumentLink cdl : [
            SELECT ContentDocument.Id, ContentDocument.Title, ContentDocument.CreatedDate, ContentDocument.ContentSize, ContentDocument.LastReferencedDate, ContentDocument.Owner.Name,  ContentDocument.OwnerId, ContentDocument.CREATEDBY.name
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN: listEmail.keyset() 
            	OR LinkedEntityId =: caseId 
           	ORDER BY  ContentDocument.CreatedDate desc, ContentDocument.ContentSize desc 
        ]){
            result.add(cdl.ContentDocument);
        }
        
        return result;
    }
    
	@AuraEnabled
    public static String deleteContentDocument(Id contentDocumentId) {
        String error = null;
        try {
            delete new ContentDocument(
                Id = contentDocumentId
            );
        } catch(Exception e) {
            error = Label.ErrorWhileDeletingFile;
        }


        
        return error;
    }
}