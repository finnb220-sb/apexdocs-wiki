/**
 * @description This is an Invocable class that acts as an Email Notification Service.
 */
public without sharing class VCC_EmailNotificationService {
    /**
     * @description This class is used to gather email information for sending.
     */
    public class EmailInfo {
        /**
         * @description Email Template id
         */
        @InvocableVariable(Label='Template Id' Description='Email Template id')
        public String templateId;

        /**
         * @description Object id which we want to send email
         */
        @InvocableVariable(Label='Object Id' Description='Object id which we want to send email')
        public String objectId;

        /**
         * @description Subject of the email
         */
        @InvocableVariable(Label='Subject' Description='subject of the email')
        public String subject;

        /**
         * @description Org Wide Address id
         */
        @InvocableVariable(Label='Orgwide Address Id' Description='org wide address')
        public String orgWideAddressId;

        /**
         * @description Email Addresses
         */
        @InvocableVariable(Label='Emails' Description='Email Address')
        public List<String> emails;

        /**
         * @description Email Template Body
         */
        @InvocableVariable(Label='Template Body' Description='Email Template Body')
        public String templateBody;
    }

    /**
     * @description This class is used to return the status of the email sent.
     */
    public class EmailResponse {
        /**
         * @description Email send status
         */
        @InvocableVariable(Label='Status' Description='email send status')
        public Boolean status;

        /**
         * @description Error message if any on email send.
         */
        @InvocableVariable(Label='Error Message' Description='error message if any')
        public String error;
    }

    /**
     * @description This method is used to send an email(s) and return the status of the send.
     * @param emailInfoList  The list of email(s) to be sent.
     * @return List of EmailResponse with status and error if any.
     */
    @InvocableMethod
    public static List<EmailResponse> sendEmail(List<EmailInfo> emailInfoList) {
        List<EmailResponse> emailResponses = new List<EmailResponse>();
        for (EmailInfo emailInfoObj : emailInfoList) {
            EmailResponse emailResponseObj = new EmailResponse();
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.optOutPolicy = 'FILTER';
            message.subject = emailInfoObj.subject;

            message.setHtmlBody(emailInfoObj.templateBody);

            if (String.isNotBlank(emailInfoObj.orgWideAddressId)) {
                message.setOrgWideEmailAddressId(emailInfoObj.orgWideAddressId);
            }
            message.toAddresses = emailInfoObj.emails;
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{ message };
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            if (results[0].success) {
                emailResponseObj.status = true;
            } else {
                emailResponseObj.status = false;
                emailResponseObj.error = results[0].errors[0].message;
            }
            emailResponses.add(emailResponseObj);
        }
        return emailResponses;
    }
}
