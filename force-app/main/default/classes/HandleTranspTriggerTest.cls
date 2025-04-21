@isTest
private class HandleTranspTriggerTest {
    @TestSetup
    static void makeData(){
        Transportadora__c transpTest = new Transportadora__c();
        transpTest.Name = 'Test Name';
        transpTest.Email__c = 'email.testing@email.com';
        transpTest.Status__c = 'Ativa';
        transpTest.CNPJ__c ='11.345.678/3456-12';

        insert transpTest;
    }

    @isTest
    static void AfterUpdateSucessTest() {

        Test.startTest();
        List<Transportadora__c> transpList = [SELECT Id, Status__c, Email__c, Name, LastModifiedDate FROM Transportadora__c WHERE Name ='Test Name' LIMIT 1];
        Transportadora__c transp =  transpList[0];
        transp.Status__c = 'Inativa';
        update transp;

        String email = transp.Email__c;
        String subject = 'Alteração de Status da Transpotadora: '+transp.Name;
        String body = 'Transportadora: '+transp.Name+' foi marcada como inativa em: '+transp.LastModifiedDate;

        List<Log__c> testLog = [SELECT Id FROM Log__c WHERE 	Associated_Id__c = :transp.Id LIMIT 1];

        System.assert(testLog.size()==1,'There should be an email log');
        System.assertEquals(true, EmailManager.sendMail(email, subject, body, transp.Id),'Email should be sent');

        Test.stopTest();
    }

    @isTest
    static void AfterUpdateFailTest() {
        Test.startTest();

        List<Transportadora__c> transpList = [SELECT Id, Status__c, Email__c, Name, LastModifiedDate FROM Transportadora__c WHERE Name ='Test Name' LIMIT 1];
        Transportadora__c transp =  transpList[0];

        transp.Status__c = 'Inativa';
        transp.Email__c = '';
        update transp;

        String email = transp.Email__c;
        String subject = 'Alteração de Status da Transpotadora: '+transp.Name;
        String body = 'Transportadora: '+transp.Name+' foi marcada como inativa em: '+transp.LastModifiedDate;

        List<Log__c> testLog = [SELECT Id FROM Log__c WHERE Associated_Id__c = :transp.Id];

        System.assert(testLog.size()<1,'There is no email associated with the transportadora');
        
        Test.stopTest();
    }

    @isTest
    static void AfterInsertSuccessTest() {
        Test.startTest();

        Transportadora__c tr = new Transportadora__c();
        tr.Name = 'Test Name2';
        tr.Email__c = 'email.test2@email.com';
        tr.Status__c = 'Inativa';
        tr.CNPJ__c ='00.999.888/7777-00';
        insert tr;

        String email = tr.Email__c;
        String subject = 'Alteração de Status da Transpotadora: '+tr.Name;
        String body = 'Transportadora: '+tr.Name+' foi marcada como inativa em: '+tr.LastModifiedDate;
        List<Log__c> testLog = [SELECT Id FROM Log__c WHERE Associated_Id__c = :tr.Id];

        System.assertEquals(true,testLog.size()==1,'There should be an email log');
        System.assertEquals(true, EmailManager.sendMail(email, subject, body,tr.Id),'Email should be sent');
        
        Test.stopTest();
    }

    @isTest
    static void AfterInsertFailTest() {
        Test.startTest();

        Transportadora__c tr = new Transportadora__c();
        tr.Name = 'Test Name2';
        tr.Email__c = '';
        tr.Status__c = 'Inativa';
        tr.CNPJ__c ='00.999.888/7777-66';
        insert tr;

        String email = tr.Email__c;
        String subject = 'Alteração de Status da Transpotadora: '+tr.Name;
        String body = 'Transportadora: '+tr.Name+' foi marcada como inativa em: '+tr.LastModifiedDate;

        List<Log__c> testLog = [SELECT Id FROM Log__c WHERE Associated_Id__c = :tr.Id];

        System.assert(testLog.size()<1,'There is no email associated with the transportadora');
        
        Test.stopTest();
    }
}