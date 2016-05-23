module oanda.pricing;

//auto currentPrices(AccountID accountId, InstrumentName[] instruments, Nullable!SysTime since = Nullable!SysTime.init)
//{
//	//TODO: since
//	import std.algorithm, std.conv;
//	
//	auto url = URL(accountsURL ~ "/" ~ accountId ~ "/pricing");
//	url.queryString = "instruments=" ~ instruments.joiner(";").text;
//	auto res = request(url);
//	return deserializeJson!(Price[])(res["prices"]);
//}
