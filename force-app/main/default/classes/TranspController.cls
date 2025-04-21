@RestResource(urlMapping='/transportadoras/*')
global with sharing class TranspController {

    public static final String SUCCESS_LABEL = System.Label.success;
    public static final String ERROR_LABEL = System.Label.error;
    public static final String TRANSP_NOT_FOUND_LABEL = System.Label.transp_not_found;
    public static final String TRANSP_FOUND_LABEL = System.Label.transp_found;
    public static final String TRANSP_DELETED_LABEL = System.Label.transp_deleted;
    public static final String UPSERT_SUCCESS_LABEL = System.Label.upsert_success;
    public static final String DELETE_ERROR_LABEL = System.Label.delete_error;

    @HttpGet
    global static String getTranspByCnpj() {
        RestRequest req = RestContext.request;
        String cnpj = req.requestURI.substring(req.requestURI.lastIndexOf('/') - 10);
        List<String> cnpjOnReq = new List<String>();
        JsonResponse jsonResp = new JsonResponse();
        cnpjOnReq.add(cnpj);

        List<Transportadora__c> transp =[SELECT Id, Name, Email__c, Status__c FROM Transportadora__c WHERE CNPJ__c = :cnpj LIMIT 1];

        if (transp == null || transp.isEmpty()) {
            jsonResp.status = ERROR_LABEL;
            jsonResp.msg = TRANSP_NOT_FOUND_LABEL;
            jsonResp.method = 'GET';
        } else {
            jsonResp.status = SUCCESS_LABEL;
            jsonResp.msg = TRANSP_FOUND_LABEL;
            jsonResp.method = 'GET';
            jsonResp.transportadoras = cnpjOnReq;
        }
        return JSON.serialize(jsonResp);
    }

    @HttpPost
    global static String upsertTransp() {
        String reqBody = RestContext.request.requestBody.toString();
        String result;
        TranspList transp;
        JsonResponse jsonResp = new JsonResponse();
        
        try{
            transp = parseBody(reqBody);
        } catch (Exception e){
            jsonResp.status = ERROR_LABEL;
            jsonResp.msg = e.getMessage();
            jsonResp.method = 'UPSERT';
            return JSON.serialize(jsonResp);
        }
        if(transp != null){
            try{
                result = handleTransp(transp);
            } catch(Exception e){
                jsonResp.status = ERROR_LABEL;
                jsonResp.msg = e.getMessage();
                jsonResp.method = 'UPSERT';
                return JSON.serialize(jsonResp);
            }
        }

        return result;
    }

    @HttpDelete
    global static String deleteTransp() {
        RestRequest req = RestContext.request;
        JsonResponse jsonResp = new JsonResponse();
        String cnpj = req.requestURI.substring(req.requestURI.lastIndexOf('/') - 10);
        List<String> cnpjOnReq = new List<String>();

        List<Transportadora__c> transp =[SELECT Id FROM Transportadora__c WHERE CNPJ__c = :cnpj LIMIT 1];
        cnpjOnReq.add(cnpj);

        if (transp == null || transp.isEmpty()) {
            jsonResp.status = ERROR_LABEL;
            jsonResp.msg = TRANSP_NOT_FOUND_LABEL;
            jsonResp.method = 'DELETE';
            jsonResp.transportadoras = cnpjOnReq;
            return JSON.serialize(jsonResp);
        }
        try {
            delete transp[0];
            jsonResp.status = SUCCESS_LABEL;
            jsonResp.msg = TRANSP_DELETED_LABEL;
            jsonResp.method = 'DELETE';
            jsonResp.transportadoras = cnpjOnReq;
        } catch (DmlException e) {
            jsonResp.status = ERROR_LABEL;
            jsonResp.msg = DELETE_ERROR_LABEL + e.getMessage();
            jsonResp.method = 'DELETE';
            jsonResp.transportadoras = cnpjOnReq;
        }

        return JSON.serialize(jsonResp);
    }

    public static String handleTransp(TranspList transpList){
        List<Transportadora__c> transpToUpsert = new List<Transportadora__c>();
        Map<String, TransportadoraWrapper> transpByCnpj = new Map<String, TransportadoraWrapper>();
        List<String> cnpjOnReq = new List<String>();
        JsonResponse jsonResp = new JsonResponse();

        for (TransportadoraWrapper transp : transpList.transportadoras) {
            transpByCnpj.put(transp.cnpj, transp);
            cnpjOnReq.add(transp.cnpj);
        }

        for(Transportadora__c tr : [SELECT Id, Name, Telefone__c, Email__c, Endereco__c, Status__c, CNPJ__c FROM Transportadora__c WHERE CNPJ__c IN: transpByCnpj.keyset()]){
            TransportadoraWrapper t = transpByCnpj.get(tr.CNPJ__c);
            tr.Name =  t.nome;
            tr.Telefone__c = t.telefone;
            tr.Email__c = t.email;
            tr.Endereco__c = t.endereco;
            tr.Status__c = t.status;

            transpToUpsert.add(tr);
            transpByCnpj.remove(tr.CNPJ__c);
        }

        for(String cnpjNotFound : transpByCnpj.keyset()){
            TransportadoraWrapper t = transpByCnpj.get(cnpjNotFound);
            Transportadora__c tr = new Transportadora__c();
            tr.Name = t.nome;
            tr.CNPJ__c = cnpjNotFound;
            tr.Telefone__c = t.telefone;
            tr.Email__c = t.email;
            tr.Endereco__c = t.endereco;
            tr.Status__c = t.status;

            transpToUpsert.add(tr);
            transpByCnpj.remove(cnpjNotFound);
        }

        try {
            upsert transpToUpsert;

            jsonResp.status = SUCCESS_LABEL;
            jsonResp.msg = UPSERT_SUCCESS_LABEL;
            jsonResp.method = 'UPSERT';
            jsonResp.transportadoras = cnpjOnReq;

            return JSON.serialize(jsonResp);
            
        } catch (DmlException e) {
            jsonResp.status = ERROR_LABEL;
            jsonResp.msg = e.getMessage();
            jsonResp.method = 'UPSERT';
            jsonResp.transportadoras = cnpjOnReq;
            return JSON.serialize(jsonResp);
        }
    }

    public static TranspList parseBody(String reqBody){
        return (TranspList) JSON.deserialize(reqBody, TranspList.class);
    }

    public class TranspList{
        public List<TransportadoraWrapper> transportadoras;
    }

    public class TransportadoraWrapper{
        public String nome;
        public String cnpj;
        public String telefone;
        public String email;
        public String endereco;
        public String status;
    }

    public class JsonResponse{
        public String status;
        public String msg;
        public String method;
        public List<String> transportadoras;
    }
}