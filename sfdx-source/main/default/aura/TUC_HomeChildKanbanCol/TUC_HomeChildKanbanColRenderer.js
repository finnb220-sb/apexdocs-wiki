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
        component.set("v.firstTimeRendered", true);
    }
});
