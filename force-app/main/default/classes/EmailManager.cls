public with sharing class EmailManager {
    public static boolean sendMail(String email, String subject, String body, String id) {

        String SUCCESS_LABEL = System.Label.success;
        String ERROR_LABEL = System.Label.error;

        Log__c log = new Log__c();
        log.Associated_Id__c = id;

        Boolean emailSent = true;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.toAddresses = new String[] {email};
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage> {mail};

        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);

        if(!results[0].isSuccess()){
            log.Status__c = ERROR_LABEL;
            log.Message__c = 'Ocorreram os seguintes erros: ' + results[0].errors[0].message;
            emailSent = false;
        }else {
            log.Status__c = SUCCESS_LABEL;
            log.Message__c = 'Email Sent';
        }
        
        insert log;
        return emailSent;
    }



}