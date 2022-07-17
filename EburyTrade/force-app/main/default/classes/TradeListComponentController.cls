public class TradeListComponentController {

    @AuraEnabled
    public static List<Trade_Object__c> getTrades()
    {
        system.debug('Sorgu çekiyorum'); 
        return [SELECT Id, Name, Buy_Amount__c, Buy_Currency__c, Sell_Amount__c, Sell_Currency__c, 
                       Rate__c, Date_Booked__c FROM Trade_Object__c ORDER BY Date_Booked__c DESC];
    }
    
}