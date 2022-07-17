public class CreateNewTradeController {
	
    @AuraEnabled
    public static List<String> getCurrenciesFromPicklist(){
        //Get picklist values from Object Picklist Fields
        SObjectField picklistUsingGlobal = SObjectType.Trade_Object__c.fields.Sell_Currency__c.getSObjectField();
        List<PicklistEntry> entries = picklistUsingGlobal.getDescribe().getPicklistValues();
        List<String> currencyCodes = new List<String>();
        for(integer i = 0; i < entries.size(); i++)
        {
            currencyCodes.add(entries[i].getValue());
        }
        return currencyCodes; 
    }
    
    @AuraEnabled
    public static Decimal calculateTrade(String sellCurrency, String buyCurrency)
    {
        //Getting the currencies from the picklist
        List<String> currencyCodes = getCurrenciesFromPicklist();        
        String urlEndPoint = sellCurrency+','+buyCurrency;
        system.debug('urlEndPoint : '+urlEndPoint);
        
        //Creating a new request to fixer.io and sending it
        Http h = new Http();
		HttpRequest req = new HttpRequest();
        req.setEndpoint('http://data.fixer.io/api/latest?access_key=1773e6d62bfda239e0d3e3fc96a3b737&symbols=' + urlEndPoint);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        String jsonBodyWrap = res.getBody();
        system.debug('res.getBody() : '+res.getBody());
        system.debug('json.deserializeUnTyped(res.getBody() : '+json.deserializeUnTyped(res.getBody()));
        
        // We can use wrapper class for parsing the JSON
        //Wrapper Class
        CurrencyResponseMain currMain = parse(jsonBodyWrap) ;
        Map<String,String> currRateMap = new Map<String,String>();
        
        system.debug('currMain : '+currMain);
        system.debug('currMain.rates : '+currMain.rates);
        for(String curr : currencyCodes)
        {
            if(curr == 'CAD')
            {
                currRateMap.put(curr,currMain.rates.CAD);    
            }
            if(curr == 'CHF')
            {
                currRateMap.put(curr,currMain.rates.CHF);    
            }
            if(curr == 'EUR')
            {
                currRateMap.put(curr,currMain.rates.EUR);    
            }
            if(curr == 'GBP')
            {
                currRateMap.put(curr,currMain.rates.GBP);    
            }
                               
        }
        system.debug('currRateMap : '+currRateMap);
        system.debug('CAD Map Value :'+currRateMap.get('CAD'));
        system.debug('CHF Map Value :'+currRateMap.get('CHF'));
        system.debug('EUR Map Value :'+currRateMap.get('EUR'));
        system.debug('GBP Map Value :'+currRateMap.get('GBP'));
        
        //Calculate the rate of currencies
        system.debug('buyCurrency : '+buyCurrency);
        system.debug('sellCurrency : '+sellCurrency);
		system.debug('(Decimal) rates.get(buyCurrency) : '+currRateMap.get(buyCurrency));
        system.debug('(Decimal) rates.get(sellCurrency) : '+currRateMap.get(sellCurrency));
        Decimal rate = Decimal.ValueOf(currRateMap.get(buyCurrency)) / Decimal.ValueOf(currRateMap.get(sellCurrency));
            
        
        
        //As an another solution we can also use <String, Object> Mapping for parsing the json
       /* Map<String,Object> JsonBody = (Map<String,Object>)json.deserializeUnTyped(res.getBody());
		Map<String,Object> rates = (Map<String,Object>)JsonBody.get('rates');
        
        system.debug('rates : '+rates);
        
		//Calculate the rate of currencies
		system.debug('buyCurrency : '+buyCurrency);
        system.debug('sellCurrency : '+sellCurrency);
		system.debug('(Decimal) rates.get(buyCurrency) : '+(Decimal) rates.get(buyCurrency));
        system.debug('(Decimal) rates.get(sellCurrency) : '+(Decimal) rates.get(sellCurrency));
        Decimal rate = (Decimal) rates.get(buyCurrency) / (Decimal) rates.get(sellCurrency);*/
        
        
        return rate;
    }
        
    @AuraEnabled
    public static Trade_Object__c createNewTrade(String sellCurr, String buyCurr, Decimal sellAmount, Decimal rate){
        
		//Create a new trade record with the values
        Trade_Object__c newTrade = new Trade_Object__c();        
        newTrade.Sell_Amount__c = sellAmount;
        newTrade.Buy_Currency__c = buyCurr;
        newTrade.Sell_Currency__c = sellCurr;
        newTrade.Date_Booked__c = DateTime.now();
        newTrade.Buy_Amount__c = rate*sellAmount;
        newTrade.Rate__c = rate;
        
        insert newTrade;
        
        //Create Chatter Post for Related Trade Record
        FeedItem post = new FeedItem();
        post.ParentId = newTrade.Id;
        post.Body = 'New Trade has been Created ! ';
        insert post;
        
        return newTrade;
    }
    
    //parse for Incoming Currencies
    public static CurrencyResponseMain parse(String json)
    {
        return (CurrencyResponseMain) system.JSON.deserialize(json,CurrencyResponseMain.class);
    }
    
    //Warpper 1 for incoming Json Parse
    public class CurrencyResponseMain 
    {  
        public Rates rates{get;set;}        
    }
    
    //Warpper 2 for incoming Json Parse
    public class Rates 
    {
        public String CAD{get;set;}  
        public String CHF{get;set;} 
        public String EUR{get;set;} 
        public String GBP{get;set;}         
    }
}