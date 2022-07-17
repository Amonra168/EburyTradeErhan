({
	getTrades : function(component, event, helper) {
        //Call Apex Class method which returns SOQL for trades
		var action = component.get("c.getTrades");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.data", response.getReturnValue());
                }
                else if (state === "INCOMPLETE") {
                    alert("From server: " + response.getReturnValue());
                }
                    else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                            }
                        } else {
                            console.log("Unknown error");
                        }
                    }
            });
            $A.enqueueAction(action);
	}
})