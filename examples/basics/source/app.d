import std.stdio;

import oanda.client;

void main()
{
	PracticeClient client = PracticeClient("cff57fc861c1fd2806e0f7bcced7cd06-f04dcd36e8ac231fac74990fc1c8e8c0");

	auto accounts = client.listAccounts;
	auto accountDetail = client.accountDetails(accounts[0].id);

	writeln("Accounts: ", accounts);
	//writeln("User accounts: ", client.getUserAccounts("xxx"));
	writeln("Account detail: ", accountDetail);
	writeln("Account summary: ", client.accountSummary(accounts[0].id));
	writeln("Account instruments: ", client.accountInstruments(accounts[0].id));
	writeln("Account changes: ", client.pollAccountUpdates(accounts[0].id, accountDetail.lastTransactionID));
	writeln("EUR/USD pricing: ", client.currentPrices(accounts[0].id, ["EUR_USD"]));
}
