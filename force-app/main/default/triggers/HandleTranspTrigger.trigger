trigger HandleTranspTrigger on Transportadora__c (after insert, after update) {
    for(Transportadora__c newTransp : Trigger.new){

        if(newTransp.Status__c == 'Inativa' && String.isNotBlank(newTransp.Email__c) && (Trigger.isInsert || Trigger.isUpdate)){
            if(Trigger.isUpdate){
                Transportadora__c oldTransp = Trigger.oldMap.get(newTransp.Id);
                if(oldTransp != null && oldTransp.Status__c != 'Inativa'){
                    String email = newTransp.Email__c;
                    String subject = 'Alteração de Status da Transpotadora: '+newTransp.Name;
                    String body = 'Transportadora: '+newTransp.Name+' foi marcada como inativa em: '+newTransp.LastModifiedDate;
                    String id = newTransp.Id;
                    EmailManager.sendMail(email,subject,body, id);
                }
            } else if(Trigger.isInsert){
                String email = newTransp.Email__c;
                String subject = 'Alteração de Status da Transpotadora: '+newTransp.Name;
                String body = 'Transportadora: '+newTransp.Name+' foi marcada como inativa em: '+newTransp.LastModifiedDate;
                String id = newTransp.Id;
                EmailManager.sendMail(email,subject,body, id);
            }
        }
    }
}