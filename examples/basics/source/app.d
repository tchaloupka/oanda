import std.stdio;

import oanda;

void main()
{
	auto client = OandaClient(Environment.fxpractice, "<your api key>");

	auto accounts = client.listAccounts;
	auto accountDetail = client.accountDetails(accounts[0].id);

	writeln("Accounts: ", accounts);
	writeln("Account detail: ", accountDetail);
	writeln("Account summary: ", client.accountSummary(accounts[0].id));
//	writeln("Account instruments: ", client.accountInstruments(accounts[0].id));
//	writeln("Account changes: ", client.pollAccountUpdates(accounts[0].id, accountDetail.lastTransactionID));
//	writeln("EUR/USD pricing: ", client.currentPrices(accounts[0].id, ["EUR_USD"]));
}
