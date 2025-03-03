/* eslint-disable no-undef */
/**
 * Modified From Salesforce Labs - Open Source Project - https://github.com/SalesforceLabs/Home-Child-Kanban/
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 * @description       : Class used as a helper for Columns in the Kanban Board (Used for Case Types)
 * @author            : Edwin Schaeffer
 * @group             : Booz Allen
 * @last modified on  : 03-29-2023
 * @last modified by  : Edwin Schaeffer
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   03-29-2023   Edwin Schaeffer                      Initial Version
 **/

({
    countUpHelper: function (component) {
        var smap = component.get("v.summaryMap");
        var psumval = component.get("v.psumval");
        if (smap) {
            var options = {
                useEasing: true,
                useGrouping: true,
                separator: ",",
                decimal: "."
            };
            //console.log(component.get('v.isCurrency'));
            var ftyp = component.get("v.rsFld");
            var deci = 0;
            if (ftyp == "CURRENCY") {
                options.prefix = $A.get("$Locale.currency");
            } else if (ftyp == "DOUBLE") {
                deci = 2;
            }
            if (!isNaN(smap[component.get("v.pickvalue")])) {
                var demo = new CountUp(component.find("cup").getElement(), psumval, smap[component.get("v.pickvalue")], deci, 1, options);
                demo.start();
                component.set("v.psumval", smap[component.get("v.pickvalue")]);
            }
        }
    }
});
