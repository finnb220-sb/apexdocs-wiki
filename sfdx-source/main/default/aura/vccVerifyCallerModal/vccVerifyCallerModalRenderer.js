({
    afterRender: function (helper) {
        this.superAfterRender();

        //? set focus after first render to begin focus trapping
        helper.focusOnFirstElement();
    },
    rerender: function () {
        this.superRerender();
    },
    unrender: function () {
        this.superUnrender();
    }
});
