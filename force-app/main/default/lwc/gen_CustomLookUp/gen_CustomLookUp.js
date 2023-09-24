import { LightningElement,api,track } from 'lwc';
import getResults from '@salesforce/apex/LTN001_CustomLookUP.getResults'; 

export default class LwcCustomLookup extends LightningElement {
    @api objectName;
    @api numberOfRecords;
    @api fieldName;
    @api rtName;
    @api underWriter;
    @api disabledField = false;
    @api selectRecordId = '';
    @api selectRecordName;
    @api Label;
    @api typedTxt;
    @api searchRecords = [];
    @api required = false;
    @api iconName = 'action:new_account'
    @api LoadingText = false;
    @track txtclassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @track iconFlag =  true;
    @track clearIconFlag = false;
    @track inputReadOnly = false;
   

    searchField(event) {
        var currentText = event.target.value;
        this.LoadingText = true;
        this.typedTxt = currentText;
        // Creates the event with the data.
        const typeEvt = new CustomEvent('typevaluechanged', {detail: {currentText}, });
        // Dispatches the event.
        this.dispatchEvent(typeEvt);

        
        getResults({ ObjectName: this.objectName, fieldName: this.fieldName, value: currentText, recordtype: this.rtName, underWriterCode: this.underWriter, totalRecords: this.numberOfRecords  })
        .then(result => {
            this.searchRecords= result;
            this.LoadingText = false;
            
            this.txtclassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length == 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.log('-------error-------------'+error);
            console.log(error);
        });
        
    }
    
   setSelectedRecord(event) {
        var currentRecId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;

        var currentUnderWriter;
        if( event.currentTarget.dataset.under != null){
            currentUnderWriter = event.currentTarget.dataset.under;
        }

        this.txtclassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        this.iconFlag = false;
        this.clearIconFlag = true;
        this.selectRecordName = event.currentTarget.dataset.name;
        this.selectRecordId = currentRecId;
        this.inputReadOnly = true;

        const selectedEvent = new CustomEvent('selected', { detail: {selectName, currentRecId, currentUnderWriter}, });
        this.dispatchEvent(selectedEvent);
    }
    
    @api
    resetData() {
        this.template.querySelector('lightning-input[data-id="userinput"]').value = '';

        this.selectRecordName = "";
        this.selectRecordId = "";
        this.inputReadOnly = false;
        this.iconFlag = true;
        this.clearIconFlag = false;

        this.dispatchEvent(new CustomEvent(
            'reset'
        ));
    }

}