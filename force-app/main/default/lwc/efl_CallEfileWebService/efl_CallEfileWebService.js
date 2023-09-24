import {
    LightningElement,
    wire,
    api,
    track
} from 'lwc'; 
import doInIt from '@salesforce/apex/LTN002_CallEfileWebService.onInit';
import sendResultsApex from '@salesforce/apex/LTN002_CallEfileWebService.sendResults';
import getAuthentication from '@salesforce/apex/LTN002_CallEfileWebService.getAuthToken';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    getRecord
} from 'lightning/uiRecordApi';
 
import USER_ID from '@salesforce/user/Id';
 
import NAME_FIELD from '@salesforce/schema/User.Name';
import EMAIL_FIELD from '@salesforce/schema/User.Email';
import MEGA_TOKEN from '@salesforce/schema/User.MegaToken__c';
import TOKEN_TIME from '@salesforce/schema/User.TECH_MegaTokenTime__c';

export default class Userinfoexample extends LightningElement {
    screenDisplay = false;// Decide which screen to display
    pwdRequired = true;
    verifyStart = true;
    @api recordId;
    @api isLoaded = false;
    @track setLookupFilter;
    @track selectAccRecordId;//store the record id of the selected 
    @track selectAccRecordName;//store the record Name of the selected 
    @track selectRefRecordId;//store the record id of the selected 
    @track selectRefRecordName;//store the record Name of the selected 
    @track selectRefRecordUnderWriter;//store the record Name of the selected
    @track disableRef = true;//store the record Name of the selected
    @track typedWord ;//store the typed word from lookup
    @track error;
    @track email; 
    @track name;
    @track pwdVal;
    @track typedTxt;
    @track megaUserName;
    @track authToken;
    @track isValid = false;
    @track flag = true;
    @track applicationFormat = false;
    @track claimFormat = false;
    @track quoteFormat = false;
    @track corpclientFormat = false;
    @track numOfRecords = 100;



    
    currentUserId = USER_ID;
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD, EMAIL_FIELD,MEGA_TOKEN,TOKEN_TIME]
    }) wireuser({
        error,
        data
    }) {
        if (error) {
           this.error = error ; 
        } else if (data && this.flag) {
            doInIt({
                
            })
            .then(result => {
            this.isLoaded = false;
                var _results = result;
                this.isValid = result;
                console.log('this.isValid' , this.isValid);
                console.log('this.isValid' , _results);
                //Check if there is already a token associated with this user
                this.authToken = (data.fields.MegaToken__c.value)!=null?data.fields.MegaToken__c.value:null;
                //if there is a token skip first screen
                this.screenDisplay = (this.authToken)!=null&(this.isValid)?true:false;
                this.email = data.fields.Email.value;
                this.name = data.fields.Name.value;
            })
            .catch(error => {
                this.isLoaded = false;
               // console.log('-------error-------------'+JSON.stringify(error));
            });
            
        }
    }

    handleSubmit(event){
        this.isLoaded = true;
        //console.log('handleSubmit');
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        //console.log('fields : ' , fields.MegaUserName__c);
        this.megaUserName = fields.MegaUserName__c;
        //this.template.querySelector('lightning-record-edit-form').submit(fields);

        getAuthentication({
            username : this.megaUserName,
            password : this.pwdVal
        })
        .then(result => {
        this.isLoaded = false;
            var _results = result;
            fields.MegaToken__c = _results.token;
            this.authToken = _results.token;
            const evt = new ShowToastEvent({
                title: _results.code,
                message: _results.message,
                variant:(_results.code == '200')?"success":"error"
            });
            this.dispatchEvent(evt);
            if(_results.code == '200'){
                this.screenDisplay = true;
                this.isValid =true;
                this.flag = false;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
         
        })
        .catch(error => {
            this.isLoaded = false;
           // console.log('-------error-------------'+JSON.stringify(error));
        });
     }

     handleSuccess(event){
        /*console.log('event' + event.detail);
        const evt = new ShowToastEvent({
            title: "Account created",
            message: "Record ID: " + event.detail.id,
            variant: "success"
        });
        this.dispatchEvent(evt);*/
        //render screen 2
        //this.screenDisplay = true;        
     }


     handlePrevious(event){
        //this.screenDisplay = false;   
        const value = true;
        const valueChangeEvent = new CustomEvent("valuechange", {
        detail: { value }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);     
     }

     handleNext(event){
        this.screenDisplay = true;        
     }

     //Handle Underwriter Lookup click event
     selectedRecords(event) {

        const recordValue = event.detail;
        //console.log('Name', recordValue.selectName);
        this.selectAccRecordName = recordValue.selectName;
        this.selectAccRecordId = recordValue.currentRecId;
        this.selectRefRecordUnderWriter = recordValue.currentUnderWriter;
    }
    //HHAR typing manually
    /*typeRecords(event){
        const recordValue = event.detail;
    }*/

    //Handle Ref Number Lookup 
    selectedRecordRefNumber(event) {

        const recordValue = event.detail;
        this.selectRefRecordName = recordValue.selectName;
        if(this.selectRefRecordName != null) {
            this.verifyStart = false;
        }else{
            this.verifyStart = true;
        }
        this.selectRefRecordId = recordValue.currentRecId;
        this.typedWord = recordValue.currentText;
       
    }

    //Picklist values
    selectionChangeHandler(event){
        const picklistValue = event.target.value;
        this.setLookupFilter = picklistValue;

        if(picklistValue != ''){
            this.disableRef = false;
        }else{
            this.disableRef = true;
        }

        if(picklistValue == 'Application'){
            this.applicationFormat = true;
            this.claimFormat = false;
            this.quoteFormat = false;
            this.corpclientFormat = false;
        }else if(picklistValue == 'Claim'){
            this.applicationFormat = false;
            this.claimFormat = true;
            this.quoteFormat = false;
            this.corpclientFormat = false;
        }else if(picklistValue == 'Quote'){
            this.applicationFormat = false;
            this.claimFormat = false;
            this.quoteFormat = true;
            this.corpclientFormat = false;
        }else{
            this.applicationFormat = false;
            this.claimFormat = false;
            this.quoteFormat = false;
            this.corpclientFormat = true;
        }
    }

    //Picklist values
    typevaluechanged(event){
        console.log('handleChange');
        const eventVal = event.detail;
        console.log('eventVals' , JSON.stringify(eventVal));
        this.typedTxt = eventVal.value;
        console.log('this.typedTxt',this.typedTxt);
        var picklistVal = this.setLookupFilter;
        console.log('selectRefRecordUnderWriter' ,   this.selectRefRecordUnderWriter.length);
        console.log('selectRefRecordUnderWriter value' ,   this.selectRefRecordUnderWriter);
        //console.log('typedTxt' , this.typedTxt);
        //console.log('selectRefRecordUnderWriter' , this.selectRefRecordUnderWriter);
        //console.log('check ' , this.typedTxt.startsWith(this.selectRefRecordUnderWriter));

        var underWriterLength = this.selectRefRecordUnderWriter.length;

        //var regex = '';
        var regexStr = '';
        

        if(picklistVal =='Application'){
            //regex = /^([A-Z]{3}-[A-Z]{1}[0-9]{5})$/g;
            regexStr = '^([A-Za-z0-9]{'+underWriterLength+'}-[A-Z]{1}[0-9]{5})$';
            
        }else if(picklistVal =='Quote'){
            //regex = /^([A-Z]{3}-[A-Z]{1}[0-9]{5})$/g;
            regexStr = '^([A-Za-z0-9]{'+underWriterLength+'}-[A-Z]{1}[0-9]{5})$';
            
        }else if(picklistVal =='CorpClient'){
            //regex = /^([A-Z]{3}-[A-Z]{1}[0-9]{5})$/g;
            regexStr = '^([A-Za-z0-9]{'+underWriterLength+'}-[A-Z]{1}[0-9]{5})$';
            
        }else if(picklistVal =='Claim'){
            //regex = /^([A-Z]{3}-[0-9]{6})$/g;
            regexStr = '^([A-Za-z0-9]{'+underWriterLength+'}-[0-9]{6})$';
        }
        //convert String to a regular expression to be used for Validation
        var regexBuild = new RegExp(regexStr);

        console.log('regexBuild : ' , regexBuild);
        if( this.typedTxt.startsWith(this.selectRefRecordUnderWriter) && this.typedTxt.match(regexBuild)){
            console.log('true HHA');
            this.verifyStart = false;
        }else{
            console.log('false HHA');
            this.verifyStart = true;
        }
    }

    savePWD(event){
        var currentPWD = event.target.value; 
        this.pwdVal = currentPWD;
        if(currentPWD != ''){
            this.pwdRequired = false;
        }else{
            this.pwdRequired = true;
        }
        
    }

    handleSendToWebService(event){
        this.isLoaded = true;
        //console.log('token' ,this.authToken);
        var checkRefNumber = '';
        if(this.selectRefRecordName != null){
            checkRefNumber = this.selectRefRecordName;
        }else{
            checkRefNumber = this.typedTxt;
        }

        sendResultsApex({ underWriter: this.selectAccRecordName, 
                          type: this.setLookupFilter, 
                          refNumber: checkRefNumber,
                          token : this.authToken,
                          recId : this.recordId
                        })
        .then(result => {
            //console.log('------success---' + result);
            this.isLoaded = false;
            var _results = result;
            const evt = new ShowToastEvent({
                title: _results.code,
                message: _results.message,
                variant:(_results.code == '200')?"success":"error"
            });
            this.dispatchEvent(evt);
             //event to close QuickAction
            if(_results.code == '200'){
                const value = true;
                const valueChangeEvent = new CustomEvent("valuechange", {
                detail: { value }
                });
                // Fire the custom event
                this.dispatchEvent(valueChangeEvent);
            }
            
        })
        .catch(error => {
            this.isLoaded = false;
            //console.log('-------error-------------'+error);
        });
    }
 
}