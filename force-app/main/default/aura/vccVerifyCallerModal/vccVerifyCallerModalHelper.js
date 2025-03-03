({
    assignFocus: function (e) {
        this.focusOnFirstElement();
        e.preventDefault();
    },
    focusOnFirstElement: function () {
        const firstFocusableElement = document.querySelector(".first_element");
        if (!firstFocusableElement) return;
        firstFocusableElement.focus();
    },
    trapFocus: function (e) {
        const firstFocusableElement = document.querySelector(".first_element");
        const lastFocusableElement = document.querySelector(".last_element");

        //? if shift key pressed for shift + tab combination
        if (e.shiftKey) {
            //? if focused has reached the first focusable element then focus on the last focusable element after pressing tab
            if (document.activeElement === firstFocusableElement) {
                lastFocusableElement.focus();
                e.preventDefault();
            }
            //? if only tab key is pressed
        } else {
            //? if focused has reached the last focusable element then focus on the first focusable element after pressing tab
            if (document.activeElement === lastFocusableElement) {
                firstFocusableElement.focus();
                e.preventDefault();
            }
        }
    }
});
