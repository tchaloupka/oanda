module oanda.account;

import vibe.data.serialization;
import vibe.data.json;

import oanda.definitions.account;
import oanda.definitions.transactions : TransactionID, ClientConfigureTransaction;
import oanda.client;

/// Response of Poll account updates function
struct AccountChangesResponse
{
	/**
	 * The changes to the Account’s Orders, Trades and Positions since the specified Transaction ID.
	 * Only provided if the sinceTransactionID is supplied to the poll request.
	 */
	AccountChanges changes;
	/// The Account’s current price-dependent state.
	AccountState state;
	/**
	 * The ID of the last Transaction created for the Account.
	 * This Transaction ID should be used for future poll requests,
	 * as the client has already observed all changes up to and including it.
	 */
	TransactionID lastTransactionID;
}

/// Response of Account details function
struct AccountDetailsResponse
{
	/// The full details of the requested Account.
	Account account;
	/// The ID of the most recent Transaction created for the Account.
	TransactionID lastTransactionID;
}

/// Response of Account summary function
struct AccountSummaryResponse
{
	/// The summary of the requested Account.
	AccountSummary account;
	/// The ID of the most recent Transaction created for the Account.
	TransactionID lastTransactionID;
}

/// Response of Configure account function
struct ConfigureAccountResponse
{
	ClientConfigureTransaction configureTransaction;
	TransactionID lastTransactionID;
}

/**
 * Get a list of all Accounts authorized for the provided token.
 * 
 * Params:
 * 		client = oanda client
 * 
 * Returns:
 * 		The list of Accounts the client is authorized to access and their associated properties.
 */
auto listAccounts(ref in OandaClient client)
{
	auto res = client.requestJson("/v3/accounts");
	return deserializeJson!(AccountProperties[])(res["accounts"]);
}

/**
 * Get the full details for a single Account that a client has access to.
 * Full pending Order, open Trade and open Position representations are provided.
 * 
 * Params:
 * 		client    = oanda client
 * 		accountId = ID of the Account to fetch
 * 
 * Returns:
 * 		The full details of the requested Account.
 */
auto accountDetails(ref in OandaClient client, AccountID accountId)
{
	auto res = client.requestJson(["/v3/accounts/", accountId]);
	return deserializeJson!(AccountDetailsResponse)(res);
}

///**
// * Get a summary for a single Account that a client has access to.
// * 
// * Params:
// * 		accountId = ID of the Account to fetch
// * 
// * Returns:
// * 		The summary of the requested Account.
// */
//auto accountSummary(AccountID accountId)
//{
//	auto res = request(accountsURL ~ "/" ~ accountId ~ "/summary");
//	return deserializeJson!(AccountSummaryResponse)(res);
//}
//
///**
// * Get the list of tradeable instruments for the given Account.
// * 
// * Params:
// * 		accountId   = ID of the Account to fetch
// * 		instruments = List of instruments to query specifically.
// * 
// * Returns:
// * 		The requested list of instruments.
// */
//auto accountInstruments(AccountID accountId, InstrumentName[] instruments ...)
//{
//	//TODO: Query specific instruments
//	auto res = request(accountsURL ~ "/" ~ accountId ~ "/instruments");
//	return res["instruments"].toString.deserializeWithPolicy!(JsonStringSerializer, UpperCasePolicy, Instrument[]);
//	//return res["instruments"].deserializeWithPolicy!(JsonSerializer, UpperCasePolicy, Instrument[]);
//}
//
///**
// * Set the client-configurable portions of an Account.
// * 
// * Params:
// * 		accountID  = ID of the Account to configure
// * 		alias      = account alias
// * 		marginRate = The string representation of a decimal number.
// * 
// * Returns:
// * 		The transaction that configures the Account.
// */
//auto configureAccount(AccountID accountId, string alias_, DecimalNumber marginRate)
//{
//	//TODO: Not implemented
//}
//
//auto pollAccountUpdates(AccountID accountId, TransactionID sinceTransactionId)
//{
//	auto url = URL(accountsURL ~ "/" ~ accountId ~ "/changes");
//	url.queryString = "sinceTransactionID=" ~ sinceTransactionId;
//	auto res = request(url);
//	return deserializeJson!(AccountChangesResponse)(res);
//}
