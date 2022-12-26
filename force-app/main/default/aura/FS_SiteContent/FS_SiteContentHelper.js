({
	getContactInfo: function(cmp,event,helper) {
		var action = cmp.get("c.fetchContactInfo");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				cmp.set("v.contactInfo", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                console.log("server call status: INCOMPLETE");
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	}
})