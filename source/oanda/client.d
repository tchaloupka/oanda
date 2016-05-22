debug import std.stdio;
import vibe.http.client;
import vibe.data.json;
import vibe.data.serialization;
import std.typecons;

import oanda.definitions;

/// Environment the client comunicate with
enum Environment
{
	/// Practice account
	fxpractice,
	/// Trade account
	fxtrade
}

struct AccountChangesResponse
{
	AccountChanges changes;
	AccountState state;
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

struct OandaClient(Environment env)
{
	static if (env == Environment.fxpractice)
	{
		enum apiURL = "https://api-fxpractice.oanda.com/v3/";
		enum streamURL = "https://stream-fxpractice.oanda.com/";
	}
	else
	{
		enum apiURL = "https://api-fxtrade.oanda.com/v3/";
		enum streamURL = "https://stream-fxtrade.oanda.com/";
	}

	this(string accessToken)
	{
		this.accessToken = accessToken;
	}

	@property void accessToken(string token)
	{
		_auth = "Bearer " ~ token;
	}

	enum accountsURL = apiURL ~ "accounts";
	enum usersURL = apiURL ~ "users";

	/* ---------- ACOUNTS ------------*/

	/**
	 * Get a list of all Accounts authorized for the provided token.
	 * 
	 * Returns:
	 * 		The list of Accounts the client is authorized to access and their associated properties.
	 */
	auto listAccounts()
	{
		return deserializeJson!(AccountProperties[])(request(accountsURL)["accounts"]);
	}

	/**
	 * Get the full details for a single Account that a client has access to.
	 * Full pending Order, open Trade and open Position representations are provided.
	 * 
	 * Params:
	 * 		accountId - ID of the Account to fetch
	 * 
	 * Returns:
	 * 		The full details of the requested Account.
	 */
	auto accountDetails(AccountID accountId)
	{
		auto res = request(accountsURL ~ "/" ~ accountId);
		return deserializeJson!(AccountDetailsResponse)(res);
	}

	/**
	 * Get a summary for a single Account that a client has access to.
	 * 
	 * Params:
	 * 		accountId - ID of the Account to fetch
	 * 
	 * Returns:
	 * 		The summary of the requested Account.
	 */
	auto accountSummary(AccountID accountId)
	{
		auto res = request(accountsURL ~ "/" ~ accountId ~ "/summary");
		return deserializeJson!(AccountSummaryResponse)(res);
	}

	/**
	 * Get the list of tradeable instruments for the given Account.
	 * 
	 * Params:
	 * 		accountId - ID of the Account to fetch
	 * 		instruments - List of instruments to query specifically.
	 * 
	 * Returns:
	 * 		The requested list of instruments.
	 */
	auto accountInstruments(AccountID accountId, InstrumentName[] instruments ...)
	{
		//TODO: Query specific instruments
		auto res = request(accountsURL ~ "/" ~ accountId ~ "/instruments");
		return res["instruments"].toString.deserializeWithPolicy!(JsonStringSerializer, UpperCasePolicy, Instrument[]);
		//return res["instruments"].deserializeWithPolicy!(JsonSerializer, UpperCasePolicy, Instrument[]);
	}

	/**
	 * Set the client-configurable portions of an Account.
	 * 
	 * Params:
	 * 		accountID - ID of the Account to configure
	 * 		alias - account alias
	 * 		marginRate - The string representation of a decimal number.
	 * 
	 * Returns:
	 * 		The transaction that configures the Account.
	 */
	auto configureAccount(AccountID accountId, string alias_, DecimalNumber marginRate)
	{
		//TODO: Not implemented
	}

	auto pollAccountUpdates(AccountID accountId, TransactionID sinceTransactionId)
	{
		auto url = URL(accountsURL ~ "/" ~ accountId ~ "/changes");
		url.queryString = "sinceTransactionID=" ~ sinceTransactionId;
		auto res = request(url);
		return deserializeJson!(AccountChangesResponse)(res);
	}

	/* ---------- TRANSACTIONS ------------*/

	auto listTransactions()
	{
		//TODO: Not implemented
	}

	auto transactionDetails()
	{
		//TODO: Not implemented
	}

	auto transactionIdRange()
	{
		//TODO: Not implemented
	}

	auto transactionsSinceId()
	{
		//TODO: Not implemented
	}

	/* ---------- TRADES ------------*/

	auto listTrades()
	{
		//TODO: Not implemented
	}

	auto listOpenTrades()
	{
		//TODO: Not implemented
	}

	auto tradeDetails()
	{
		//TODO: Not implemented
	}

	auto closeTrade()
	{
		//TODO: Not implemented
	}

	auto setTradeClientExtensions()
	{
		//TODO: Not implemented
	}

	auto setDependentOrders()
	{
		//TODO: Not implemented
	}

	/* ---------- PRICING ------------*/

	auto currentPrices(AccountID accountId, InstrumentName[] instruments, Nullable!SysTime since = Nullable!SysTime.init)
	{
		//TODO: since
		import std.algorithm, std.conv;
		
		auto url = URL(accountsURL ~ "/" ~ accountId ~ "/pricing");
		url.queryString = "instruments=" ~ instruments.joiner(";").text;
		auto res = request(url);
		return deserializeJson!(Price[])(res["prices"]);
	}

	/* ---------- POSITIONS ------------*/

	auto openPositions()
	{
		//TODO: Not implemented
	}

	auto listPositions()
	{
		//TODO: Not implemented
	}

	auto instrumentPositions()
	{
		//TODO: Not implemented
	}

	auto closePosition()
	{
		//TODO: Not implemented
	}

	/* ---------- LOGIN ------------*/

	auto login()
	{
		//TODO: Not implemented
	}

	auto logout()
	{
		//TODO: Not implemented
	}

	/* ---------- ORDERS ------------*/

	auto listOrders()
	{
		//TODO: Not implemented
	}

	auto createOrder()
	{
		//TODO: Not implemented
	}

	auto fetchOrder()
	{
		//TODO: Not implemented
	}

	auto replaceOrder()
	{
		//TODO: Not implemented
	}

	auto cancelOrder()
	{
		//TODO: Not implemented
	}

	auto setOrderClientExtensions()
	{
		//TODO: Not implemented
	}

	auto pendingOrders()
	{
		//TODO: Not implemented
	}

	/* ---------- USER ------------*/

	auto userAccountList(UserSpecifier userId)
	{
		auto res = request(usersURL ~ "/" ~ userId ~ "/accounts");
		writeln(res);
		return deserializeJson!(AccountProperties[])(res["accounts"]);
	}

	/* ---------- STREAMING ------------*/

	//TODO: Not yet available (use V1)

	/* ---------- PRICING HISTORY ------------*/

	//TODO: Not yet available (use V1)

	/* ---------- FOREX LABS ------------*/

	//TODO: Not yet available


private:
	string _auth;

	auto request(T)(T url, scope void delegate(scope HTTPClientRequest) requester = cast(void delegate(scope HTTPClientRequest req))null)
	{
		Json data;
		int status;
		
		requestHTTP(url, 
			(scope req)
			{
				req.method = HTTPMethod.GET;
				req.headers["Authorization"] = _auth;

				if (requester) requester(req);
			},
			(scope res)
			{
				status = res.statusCode;
				try data = res.readJson;
				catch (JSONException) {}
			});

		if (status != HTTPStatus.ok)
		{
			import std.format;
			throw new HTTPStatusException(status, data !is Json.undefined ? format("%s: %s", data["errorCode"], data["errorMessage"]) : null);
		}

		return data;
	}
}

alias OandaClient!(Environment.fxpractice) PracticeClient;
alias OandaClient!(Environment.fxtrade) TradeClient;
