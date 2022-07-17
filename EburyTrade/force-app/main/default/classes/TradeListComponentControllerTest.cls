@isTest
public class TradeListComponentControllerTest {

    static testMethod void testTradeListController()
    {
        Trade_Object__c tradeObj = new Trade_Object__c();
        tradeObj.Sell_Currency__c = 'CAD';
        tradeObj.Sell_Amount__c = 500;
        tradeObj.Buy_Currency__c = 'EUR';
        tradeObj.Buy_Amount__c = 633.13;
        tradeObj.Rate__c = 1.2756;
        tradeObj.Date_Booked__c = system.today();
        
        insert tradeObj;
        
        TradeListComponentController.getTrades();
    }
}