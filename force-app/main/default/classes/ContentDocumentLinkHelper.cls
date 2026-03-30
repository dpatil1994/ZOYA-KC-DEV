/**
* @File Name         : ContentDocumentLinkHelper .cls
* @Description       : The ContentDocumentLinkHelper Apex class is designed 
					   to link one or more uploaded files (Content Documents) 
					   to an Account record. It is built for use with Salesforce 
					   Flow using an @InvocableMethod. The class accepts an Account 
					   Id and a list of Content Document Ids, then creates ContentDocumentLink 
					   records to associate each file with the specified Account. 
					   All linked files are shared with Viewer access and are visible to All Users.
*
* @Author            : KC0117
* @Last Modified By  : Awantika
* @Last Modified On  : December 19, 2025
* @Modification Log  :
*==============================================================================
* Ver | Date         | Author              | Modification
*==============================================================================
* 1.0 | December 19, 2025 | Awantika | Initial Version
**/

public with sharing class ContentDocumentLinkHelper {

    // Inner class for Flow input
    public class LinkInput {
        @InvocableVariable(required=true)
        public Id agencyId;   

        @InvocableVariable(required=true)
        public List<Id> contentDocumentIds;
    }

    @InvocableMethod(label='Link Multiple Files to Agency')
    public static void linkFilesToAgency(List<LinkInput> inputs) {
        List<ContentDocumentLink> linksToInsert = new List<ContentDocumentLink>();

        for(LinkInput input : inputs) {
            if(input.agencyId != null && input.contentDocumentIds != null) {
                for(Id docId : input.contentDocumentIds) {
                    if(docId != null) {
                        linksToInsert.add(new ContentDocumentLink(
                            ContentDocumentId = docId,
                            LinkedEntityId = input.agencyId,  
                            ShareType = 'V',
                            Visibility = 'AllUsers'
                        ));
                    }
                }
            }
        }

        if(!linksToInsert.isEmpty()) {
            insert linksToInsert;
        }
    }
}