import { LightningElement, api, track, wire} from 'lwc';
import retreiveCaseFilesInformation from '@salesforce/apex/LTN004_DeleteFiles.retreiveCaseFilesInformation';
import deleteContentDocument from '@salesforce/apex/LTN004_DeleteFiles.deleteContentDocument';

import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';

import { NavigationMixin } from 'lightning/navigation';
const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' },
    { label: 'view', name: 'view' },
    
];



const columns = [
    { label: 'Title', fieldName: 'Title' },
    { label: 'Owner', fieldName: 'OwnerName'},
    { label: 'Date de création', fieldName: 'CreatedDate', type: 'date' },
    { label: 'Size', fieldName: 'ContentSize' },

    



    {
        type: "button",
        fixedWidth: 100,
        typeAttributes: {
            label: 'Delete ',
            title: 'View Details',
            name: 'delete',
            value: 'delete',
            variant: 'brand',
            class: 'scaled-down'
        }
    },

];






 /* It should be outside the callback and before the enqueue method call, and no need to do this if there is no parameter to pass. */










export default class ForTestNeverDeploy extends LightningElement {



    files = [];
    columns = columns;
    record = {};



    @api recordid;
    @api files;



   


    connectedCallback(){
      console.log('connectedCallback');
      //this.loadFiles();
    }
      
    test(event) {
       this.deleteFirstFile();
    }

   async loadFiles() {
        try {
            const result = await retreiveCaseFilesInformation({caseId: this.recordid});
            // ajouter l'owner name dans une prop. de l'objet           
            this.files = result.map(elem => (
                {
                    ...elem, 
                    OwnerName: elem.Owner.Name
                }
            ));
            console.log('result', result); 
        } catch (error) {
            console.log('-------error-------------'+error);
            console.log(error);
        }
    }

    async deleteFirstFile(fileToDelete) {
        //spinner = true
        console.log('show result');
        console.log('result', this.files);  
        console.log('fileToDelete', fileToDelete);  
        try {
            const messageError = await deleteContentDocument({contentDocumentId: fileToDelete.Id});
            if (messageError != null) {
                console.error(messageError);
                // 1
            } else {
                console.log('bingo ', fileToDelete.title, 'was deleted' );
                this.files = this.files.filter(file => file.Id != fileToDelete.Id); // or loadFiles() ? 
                console.log('files new ', this.files);  
               // 2
            }
        } catch(error) {
            console.log('unexpected error', error);
            //3
        } finally {
            // spinner = false
        }
    }


    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteFirstFile(row);
                break;
            case 'show_details':
               this.showRowDetails(row);
               break;
             case 'view':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                      attributes: {
                           recordId: row.Id,
                        actionName: 'view'
                       }
                   });
        
                break;
            default:
        }
    }

   
    showRowDetails(row) {
        this.record = row;
    }



 
    async handler() {
      // Update the record via Apex.
      await retreiveCaseFilesInformation(this.recordid);
      
      // Notify LDS that you've changed the record outside its mechanisms.
      getRecordNotifyChange([{recordId: this.recordid}]);
    }




     //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
     @track isModalOpen = false;
     async openModal() {
        await this.loadFiles();
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

     async refresh(){
         console.log([{recordId: this.recordid}]);
        await getRecordNotifyChange([{recordId: this.recordid}]);
        this.closeModal();
        location.reload();
     }
}