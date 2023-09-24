({
    getValueFromLwc : function(component, event, helper) {
        console.log('parents');
        component.set("v.inputValue",event.getParam('value'));
        if(component.get("v.inputValue")){
            console.log('parents');
            $A.get("e.force:closeQuickAction").fire();
        }
    }
})