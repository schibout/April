import { LightningElement, track , api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import retrieveContentDocumentsIdsFromCase from '@salesforce/apex/LTN003_PreviewFiles.retrieveContentDocumentsIdsFromCase';

export default class OpenFileSample extends NavigationMixin(LightningElement) {

  
  @api recordid;
  @api files;
  @api aFile;

     connectedCallback(){
      retrieveContentDocumentsIdsFromCase({caseId: this.recordid})
       .then(result => {
          this.files = result.recordIds;
          this.aFile = result.selectedRecordId;     
        }
        ).catch(error => {
          console.log('-------error-------------'+error);
          console.log(error);
        })
    } 
        
    navigateToFiles(event) { 
     if(this.files  ==  null){
        alert('No files attached to the case !');
        return;
      }
      if(this.files  !==  null){
        this[NavigationMixin.Navigate]({
          type: 'standard__namedPage',
          attributes: {
              pageName: 'filePreview',
              actionName: 'list'
            },
           
          state : {
            recordIds: this.files,
            selectedRecordId: this.aFile
          }
        
        })
      } 
    }


   

     //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
     @track isModalOpen = false;
     openModal() {
         // to open modal set isModalOpen tarck value as true
         this.isModalOpen = true;
     }
     closeModal() {
         // to close modal set isModalOpen tarck value as false
         this.isModalOpen = false;
     }
     submitDetails() {
         // to close modal set isModalOpen tarck value as false
         //Add your code to call apex method or do some processing
         this.isModalOpen = false;
     }


    
}