@isTest
private class TranspControllerTest {

    @TestSetup
    static void makeData(){
        Transportadora__c transpTest = new Transportadora__c();
        transpTest.Name = 'Test Json1';
        transpTest.CNPJ__c = '12.345.678/3456-12';
        transpTest.Email__c = 'email.test@email.com';
        transpTest.Status__c = 'Ativa';

        insert transpTest;
    }

    @isTest
    static void parseFailTest() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/transportadoras/';
        request.httpMethod = 'POST';
        String requestBody = '{"transportadoras":{"nome":"Teste Json1","cnpj": "00.000.000/0000-00","telefone":"12345-6789","email":"email.test@gmail.com","endereco":"Rua Teste, número X","status":"Ativa"}}';
        request.requestBody = Blob.valueOf(requestBody);

        RestContext.request = request;

        Test.startTest();
        String responseBody = TranspController.upsertTransp();
        JsonResponse jsonResp = (JsonResponse) JSON.deserialize(responseBody, JsonResponse.class);
        String status = jsonResp.status;
        System.assertEquals('Erro', status, 'Response should be error');
        Test.stopTest(); 
    }

    @isTest
    static void noExtIdFailTest() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/transportadoras/';
        request.httpMethod = 'POST';
        String requestBody = '{"transportadoras":[{"nome":"Teste Json1","cnpj": "","telefone":"12345-6789","email":"email.test@gmail.com","endereco":"Rua Teste, número X","status":"Ativa"}]}';
        request.requestBody = Blob.valueOf(requestBody);

        RestContext.request = request;

        Test.startTest();
        String responseBody = TranspController.upsertTransp();
        JsonResponse jsonResp = (JsonResponse) JSON.deserialize(responseBody, JsonResponse.class);
        String status = jsonResp.status;
        System.assertEquals('Erro', status, 'Response should be error');
        Test.stopTest(); 
    }

    @isTest
    static void getTransSuccessTest() {
        RestRequest request = new RestRequest();
        String cnpjExist = '12.345.678/3456-12';
        request.requestURI = '/services/apexrest/transportadoras/'+cnpjExist;
        request.httpMethod = 'GET';

        RestContext.request = request;

        Test.startTest();
        String responseBody = TranspController.getTranspByCnpj();
        JsonResponse jsonResp = (JsonResponse) JSON.deserialize(responseBody, JsonResponse.class);
        String cnpj = jsonResp.transportadoras[0];
        System.assertEquals(cnpjExist, cnpj, 'Should find same CNPJ');
        Test.stopTest();     
    }

    @isTest
    static void getTransFailTest() {
        RestRequest request = new RestRequest();
        String cnpjExist = '00.000.000/0000-00';
        request.requestURI = '/services/apexrest/transportadoras/'+cnpjExist;
        request.httpMethod = 'GET';

        RestContext.request = request;

        Test.startTest();
        String responseBody = TranspController.getTranspByCnpj();
        JsonResponse jsonResp = (JsonResponse) JSON.deserialize(responseBody, JsonResponse.class);
        String status = jsonResp.status;
        System.assertEquals('Erro', status, 'Response should be error');
        Test.stopTest();
    }

    @isTest
    static void upsertTransSuccessTest() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/transportadoras/';
        request.httpMethod = 'POST';
        String requestBody = '{"transportadoras":[{"nome":"Teste Json1","cnpj": "00.000.000/0000-00","telefone":"12345-6789","email":"email.test@gmail.com","endereco":"Rua Teste, número X","status":"Ativa"},{"nome":"Teste Json2","cnpj": "12.345.678/3456-12","telefone":"54321-9876","email":"email.test2@gmail.com","endereco":"Rua Teste, número Y","status":"Ativa"}]}';
        request.requestBody = Blob.valueOf(requestBody);

        RestContext.request = request;

        Test.startTest();
        String responseBody = TranspController.upsertTransp();
        JsonResponse jsonResp = (JsonResponse) JSON.deserialize(responseBody, JsonResponse.class);
        List<String> cnpjList = jsonResp.transportadoras;
        System.assertEquals(2, cnpjList.size(), 'Should insert first Obj and update the second');
        Test.stopTest();
    }

    @isTest
    static void deleteTransSuccessTest() {
        RestRequest request = new RestRequest();
        String cnpjExist = '12.345.678/3456-12';
        request.requestURI = '/services/apexrest/transportadoras/'+cnpjExist;
        request.httpMethod = 'DELETE';

        RestContext.request = request;

        Test.startTest();
        String responseBody = TranspController.deleteTransp();
        JsonResponse jsonResp = (JsonResponse) JSON.deserialize(responseBody, JsonResponse.class);
        String cnpjDeleted = jsonResp.transportadoras[0];
        System.assertEquals(cnpjExist, cnpjDeleted, 'Should find same CNPJ');
        Test.stopTest();
        
    }
    @isTest
    static void deleteTransFailTest() {
        RestRequest request = new RestRequest();
        String cnpjExist = '00.000.000/0000-00';
        request.requestURI = '/services/apexrest/transportadoras/'+cnpjExist;
        request.httpMethod = 'GET';

        RestContext.request = request;

        Test.startTest();
        String responseBody = TranspController.deleteTransp();
        JsonResponse jsonResp = (JsonResponse) JSON.deserialize(responseBody, JsonResponse.class);
        String status = jsonResp.status;
        System.assertEquals('Erro', status, 'Response should be error');
        Test.stopTest();  
    }

    public class JsonResponse{
        public String status;
        public String message;
        public String method;
        public List<String> transportadoras;
    }

}