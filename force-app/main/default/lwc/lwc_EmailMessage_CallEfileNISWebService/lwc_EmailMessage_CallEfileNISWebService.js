//import { api, LightningElement, track , wire} from 'lwc';
import { api, LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import callEfilingApi from '@salesforce/apex/LTN005_EmailMsg_CallEfileNISWebService.callEfilingApi';
//import searchAccountsByEmailMessageId from '@salesforce/apex/LTN001Bis_AccountSearchController.searchAccountsByEmailMessageId';

/**
 * @author MTK (based on Keshav code)
 * @date 06/12/2021
 * - MTK 23/12/2021 : 
 *      Major modification : removal of the search field "Underwriter", and all the mechanics that goes with it.
 *      The code is fully commented and kept, for rollback see the bottom of this file, 
 *      everything is explained in a comment. (ctrl+f #underwritter)
 * 
 */
export default class Lwc_EmailMessage_CallEfileNISWebService extends LightningElement {
    @api recordId;
    // @track accounts;
    // @track error;
    @track selectedObject = {
        // isClaimObject: false, // #underwritter
        recordType: '',
        type: '',
        name: ''
    };
    @track typeValue='';
    /*
    @wire(searchAccountsByEmailMessageId, {
        recId: '$recId'
        })
        accs({error, data}){
            if (data) {
                this.accounts = data;
                this.error = undefined;
            } else if (error) {
                this.error = error;
                this.accounts = undefined;
            } 
        
    }*/
    objectLookupDisabled = true;
    cannotSendRequest = true;

    isLoading = false;

    objectTypes = [
        {value: 'nothing', label: '--Choose--', isNothing: true},
        {value: 'Quote', label: 'Quote', recordType: 'PolicyAsiaRT'},
        {value: 'Policy', label: 'Policy', recordType: 'PolicyAsiaRT'},
        {value: 'Claim', label: 'Claim', recordType: 'ClaimAsiaRT'},
        {value: 'Corpclient', label: 'Corpclient', recordType: 'PolicyHolder'}

        /* ??
                {value: 'nothing', label: '--Choose--', isNothing: true},
        {value: 'Policy', label: 'Quote', recordType: 'PolicyAsiaRT'},
        {value: 'Policy', label: 'Policy', recordType: 'PolicyAsiaRT'},
        {value: 'Claim', label: 'Claim', recordType: 'ClaimAsiaRT'},
        {value: 'Policy', label: 'CorpClient', recordType: 'PolicyHolder'}
        */
    ];
    //D HHAR
    handleObjectTyped(event){
        //const picklistValue = event.target.value;
        const picklistValueTyping = event.detail.currentText;//La bonne valeur
        
        //alert('picklistValue2 currentText='+picklistValueTyping);
        if(picklistValueTyping!='' && picklistValueTyping!=undefined){
            this.cannotSendRequest = false;
        }
        else{
            this.cannotSendRequest = true;
        }
        this.typeValue=picklistValueTyping;
    }
    //F HHAR
    handleObjectTypeSelectionChange(event) {
        const picklistValue = event.target.value;
        const selectedObjectType = this.objectTypes.find(ot => ot.value == picklistValue);

        if (!selectedObjectType || selectedObjectType.isNothing) {
            this.objectLookupDisabled = true;
            this.selectedObject.type = '';
            this.selectedObject.recordType = '';
        } else {
            this.selectedObject.type = selectedObjectType.value;
            this.selectedObject.recordType = selectedObjectType.recordType;
            this.objectLookupDisabled = false;
            this.selectedObject.isCorpclientObject = selectedObjectType.value == 'Corpclient'; // #underwritter
            this.selectedObject.isQuote = selectedObjectType.value == 'Quote'; // HHA20221012
            console.log('this.selectedObject.isCorpclientObject',this.selectedObject.isCorpclientObject);
            console.log('this.selectedObject.isQuote',this.selectedObject.isQuote);//HHA20221012
        }

        this.resetObjectLookup();
    }

    resetObjectLookup() {
        this.template.querySelector('c-gen_-custom-look-up[data-id="object-lookup"]').resetData();
    }

    handleObjectSelected(event) {
        const recordValue = event.detail;

        this.selectedObject.name = recordValue.selectName;
        // this.typedObjectReference = ''; // #underwritter
        this.cannotSendRequest = recordValue.selectName == null;
    }

    handleObjectLookupReset() {
        this.handleObjectUnselected();
    }

    handleObjectUnselected() {
        // this.typedObjectReference = ''; // #underwritter
        this.selectedObject.name = '';
        this.cannotSendRequest = true;
    }

    async handleSendToWebService(){
        this.isLoading = true;
        //console.log("this.typedObjectReference="+this.typedObjectReference);
        //console.log("this.selectedObject name="+this.selectedObject.name);
        console.log("this.selectedObject type="+this.selectedObject.type);
        try {
            //D HHAR
            var valueToget='';
            //if the value is not selected from the picklist but typed
            if(this.selectedObject.name==undefined || this.selectedObject.name==''){
                //get the typed value
                this.valueToget=this.typeValue;
                console.log('typed');
            }
            else{
                this.valueToget=this.selectedObject.name;
                console.log('selected');
            }
            console.log('valueToget='+this.valueToget);
            //F HHAR
            const result = await callEfilingApi({
                type: this.selectedObject.type, 
                refNumber: this.valueToget, //|| this.typedObjectReference, // #underwritter //HHA this.selectedObject.name change to valueToget
                recordId : this.recordId
            });

            this.dispatchEvent(new ShowToastEvent({
                title: result.code,
                message: result.message,
                variant:(result.code == '200') ? "success" : "error"
            }));

            if(result.code == '200') {
                this.closeModal();
            }
        } catch(error) {
            console.error('error', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Technical error',
                message: error,
                variant: "error"
            }));
        } finally {
            this.isLoading = false;
        }
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    /* MTK 23/12/2021
     * IMPORTANT: The commented code below concerns the "Underwritter" field which was dropped on 23/12/2021,
     * in case of rollback uncomment this block, and the commented lines  in the handleObjectSelected, handleObjectUnselected
     *  and handleSendToWebService methods  where the typedObjectReference variable is used.
     *  Then in the HTML uncomment the "Underwritter" lookup field and add the commented attributes in the lookup field of the object.
     * 
     *  To easily find blocks to uncomment ctrl+f #underwritter
     *
     
    @track selectedAccount = {
        underWriter:  ''
    };

    typedObjectReference = '';

    handleAccountSelected(event) {
        const recordValue = event.detail;

        this.selectedAccount.underWriter = recordValue.currentUnderWriter || '';
    }

    handleAccountLookupReset() {
        this.selectedAccount.underWriter = '';

        this.resetObjectLookup();
    }
    
    handleObjectReferenceChange(event) {
        const eventVal = event.detail;        
        this.typedObjectReference = eventVal.value;

        const underWriterLength = this.selectedAccount.underWriter.length;

        let regexStr = null;

        if (this.selectedObject.type == 'Claim') {
            regexStr = '^([A-Za-z0-9]{' + underWriterLength + '}-[0-9]{6})$';
        }

        if (regexStr != null) {
            const regexBuild = new RegExp(regexStr);

            if (this.typedObjectReference.startsWith(this.selectedAccount.underWriter) && this.typedObjectReference.match(regexBuild)) {
                this.cannotSendRequest = false;
            } else {
                this.cannotSendRequest = true;
            }
        }
    }
     */
}