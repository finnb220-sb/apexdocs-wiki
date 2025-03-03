/* eslint-disable no-undef */
/* eslint-disable no-unused-vars */
/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
({
    afterRender: function (component, helper) {
        this.superAfterRender();
        if (component.get("v.firstTimeRendered")) {
            var elem = component.find("newCard");
            $A.util.addClass(elem, "newCardColor");
            window.setTimeout(
                $A.getCallback(function () {
                    try {
                        $A.util.removeClass(elem, "newCardColor");
                    } catch (error) {
                        console.log("catching error crd renderer - likely card update kickback");
                        console.error(error);
                    }
                }),
                300
            );
        }
    }
});
