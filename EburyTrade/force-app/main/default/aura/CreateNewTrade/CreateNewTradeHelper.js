({
	showToast : function(title, message, type) {
        //Showing success Message with the given parameters 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type,
        });
        toastEvent.fire();
    }
})