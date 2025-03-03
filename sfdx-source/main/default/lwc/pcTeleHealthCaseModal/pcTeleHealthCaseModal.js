import { api } from "lwc";
import LightningModal from "lightning/modal";

export default class PcTeleHealthCaseModal extends LightningModal {
    @api currentClosedCase;
    @api isTeams;
    @api countDownInt;
    @api isPhone;
    @api callback;
    @api callbackExt;
    @api agent;
    @api caseObj;
    @api chatId;
    @api initiationMsg;

    showConfirmModal = false;

    handleLaunchNow() {
        window.open("https://teams.microsoft.com/l/call/0/0?users=" + this.agent.Email, "_blank");
    }

    navigateToCase(event) {
        let result = { value: "NAVIGATE", event: event };
        this.close(result);
    }

    handleCloseModal() {
        this.close("CLOSED");
    }

    openConfirmCancel() {
        this.showConfirmModal = true;
    }

    closeConfirmCancel() {
        this.showConfirmModal = false;
    }

    handleCancelCaseModal() {
        this.close("CANCEL_CASE");
    }
}
