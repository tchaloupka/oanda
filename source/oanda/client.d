debug import std.stdio;
import vibe.http.client;
import vibe.data.json;
import vibe.data.serialization;
import std.typecons;

alias string AccountID;
alias string TransactionID;
alias string Currency;
alias string AccountUnits;
alias string DecimalNumber;
alias string SysTime; // TODO: Use SysTime from std.datetime - https://issues.dlang.org/show_bug.cgi?id=16053
alias string TradeID;
alias string InstrumentName;
alias string PriceValue;
alias string ClientID;
alias string ClientTag;
alias string ClientComment;
alias string OrderID;
alias string UserSpecifier;

enum Environment
{
	fxpractice,
	fxtrade
}

enum TradeState
{
	open,
	closed
}

enum OrderState
{
	pending,
	filled,
	triggered,
	cancelled
}

/// The type of an Instrument.
enum InstrumentType
{
	unknown, /// Unknown
	currency, /// Currency
	index, /// Index
	bond, /// Bond
	commodity, /// Commodity
	test, /// Test
	basket, /// Basket
	cfd, /// Contract For Difference
	metal /// Metal
}

//TODO - solve the naming problem with non-tradeable
///// The status of the Price.
//enum PriceStatus
//{
//	tradeable, /// The Instrument’s price is tradeable.
//	nontradeable, /// The Instrument’s price is not tradeable.
//	invalid /// The Instrument of the price is invalid or there is no valid Price for the Instrument.)
//}
alias string PriceStatus;

template UpperCasePolicy(S)
{
	import std.conv, std.string : toLower, toUpper;

	S fromRepresentation(string value)
	{
		return value.toLower.to!S;
	}

	string toRepresentation(S value)
	{
		return to!string(value).toUpper;
	}
}

struct AccountProperties
{
	AccountID id;
	@optional int mt4AccountID;
	string[] tags;
}

struct ClientExtensions
{
	ClientID id;
	ClientTag tag;
	ClientComment comment;
}

struct TradeSummary
{
	TradeID id;
	InstrumentName instrument;
	PriceValue price;
	SysTime openTime;
	TradeState state;
	DecimalNumber initialUnits;
	DecimalNumber currentUnits;
	AccountUnits realizedPL;
	AccountUnits unrealizedPL;
	TransactionID[] closingTransactionIDs;
	AccountUnits financing;
	SysTime closeTime;
	ClientExtensions clientExtensions;
	OrderID takeProfitOrderID;
	OrderID stopLossOrderID;
	OrderID trailingStopLossOrderID;
}

struct PositionSide
{
	DecimalNumber units;
	PriceValue averagePrice;
	TradeID[] tradeIDs;
	AccountUnits pl;
	AccountUnits unrealizedPL;
	AccountUnits resettablePL;
}

struct Position
{
	InstrumentName instrument;
	AccountUnits pl;
	AccountUnits unrealizedPL;
	AccountUnits resettablePL;
	@name("long") PositionSide long_;
	@name("short") PositionSide short_;
}

//TODO: Implement Order specializations http://developer.oanda.com/rest-live-v20/orders-df/#Order
struct Order
{
	OrderID id;
	SysTime createTime;
	OrderState state;
	ClientExtensions clientExtensions;
}

mixin template AccountSummaryTemplate()
{
	AccountID id;
	@optional @name("alias") string alias_;
	Currency currency;
	AccountUnits balance;
	int createdByUserID;
	SysTime createdTime;
	AccountUnits pl;
	@optional AccountUnits resettabledPL;
	@optional SysTime resettabledPLTime;
	DecimalNumber marginRate;
	@optional SysTime marginCallEnterTime;
	@optional int marginCallExtensionCount;
	@optional SysTime lastMarginCallExtensionTime;
	int openTradeCount;
	int openPositionCount;
	int pendingOrderCount;
	bool hedgingEnabled;
	AccountUnits unrealizedPL;
	@name("NAV") AccountUnits nav;
	AccountUnits marginUsed;
	AccountUnits marginAvailable;
	AccountUnits positionValue;
	AccountUnits marginCloseoutUnrealizedPL;
	AccountUnits marginCloseoutNAV;
	AccountUnits marginCloseoutMarginUsed;
	DecimalNumber marginCloseoutPercent;
	AccountUnits withdrawalLimit;
	TransactionID lastTransactionID;
}

struct AccountSummary
{
	mixin AccountSummaryTemplate;
}

struct Account
{
	mixin AccountSummaryTemplate;

	TradeSummary[] trades;
	Position[] positions;
	Order[] orders;
}

/// Full specification of an Instrument.
struct Instrument
{
	InstrumentName name;
	@byName!UpperCasePolicy InstrumentType type;
	string displayName;
	int pipLocation;
	int displayPrecision;
	int tradeUnitsPrecision;
	DecimalNumber minimumTradeSize;
	DecimalNumber maximumTrailingStopDistance;
	DecimalNumber minimumTrailingStopDistance;
	DecimalNumber maximumPositionSize;
	DecimalNumber maximumOrderUnits;
	DecimalNumber marginRate;
}

struct AccountChanges
{
	//TODO
}

struct AccountState
{
	//TODO
}

struct AccountChangesResponse
{
	AccountChanges changes;
	AccountState state;
	TransactionID lastTransactionID;
}

/// Price Bucket
struct PriceBucket
{
	PriceValue price; /// The Price offered by the PriceBucket
	int liquidity; /// The amount of liquidity offered by the PriceBucket
}

/**
 * QuoteHomeConversionFactors represents the factors that can be used used to convert quantities
 * of a Price’s Instrument’s quote currency into the Account’s home currency.
 */
struct QuoteHomeConversionFactors
{
	/**
	 * The factor used to convert a positive amount of the Price’s Instrument’s quote currency into a positive
	 * amount of the Account’s home currency. Conversion is performed by multiplying the quote units by the conversion factor.
	 */
	DecimalNumber positiveUnits;
	/**
	 * The factor used to convert a negative amount of the Price’s Instrument’s quote currency into a negative
	 * amount of the Account’s home currency. Conversion is performed by multiplying the quote units by the conversion factor.
	 */
	DecimalNumber negativeUnits;
}

/// Representation of how many units of an Instrument are available to be traded by an Order depending on its postionFill option.
struct UnitsAvailableDetails
{
	/**
	 * The number of units that are available to be traded using an Order with a positionFill option
	 * of “DEFAULT”. For an Account with hedging enabled, this value will be the same as the “OPEN_ONLY” value.
	 * For an Account without hedging enabled, this value will be the same as the “REDUCE_FIRST” value.
	 */
	@name("default") UnitsAvailable default_;
	/**
	 * The number of units that may are available to be traded with an Order with a positionFill option of “REDUCE_FIRST”.
	 */
	UnitsAvailable reduceFirst;
	/**
	 * The number of units that may are available to be traded with an Order with a positionFill option of “REDUCE_ONLY”.
	 */
	UnitsAvailable reduceOnly;
	/**
	 * The number of units that may are available to be traded with an Order with a positionFill option of “OPEN_ONLY”.
	 */
	UnitsAvailable openOnly;
}

/// Representation of many units of an Instrument are available to be traded for both long and short Orders.
struct UnitsAvailable
{
	@name("long") DecimalNumber long_; /// The units available breakdown for long Orders.
	@name("short") DecimalNumber short_; /// The units available breakdown for short Orders.
}

struct Price
{
	InstrumentName instrument;
	SysTime time;
	@byName PriceStatus status;
	PriceBucket[] bids;
	PriceBucket[] asks;
	PriceValue closeoutBid;
	PriceValue closeoutAsk;
	QuoteHomeConversionFactors quoteHomeConversionFactors;
	UnitsAvailableDetails unitsAvailable;
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
		struct Test {
			InstrumentType color;
		}
		
		Test test = {InstrumentType.currency};
		
		assert(test.serializeWithPolicy!(JsonStringSerializer, UpperCasePolicy)
			== `{"color":"CURRENCY"}`);
		assert(`{"color": "INDEX"}`
			.deserializeWithPolicy!(JsonStringSerializer, UpperCasePolicy, Test)
			== Test(InstrumentType.index));

		this.accessToken = accessToken;
	}

	@property void accessToken(string token)
	{
		_auth = "Bearer " ~ token;
	}

	enum accountsURL = apiURL ~ "accounts";
	enum usersURL = apiURL ~ "users";

	/* ---------- ACOUNTS ------------*/

	auto listAccounts()
	{
		return deserializeJson!(AccountProperties[])(request(accountsURL)["accounts"]);
	}

	auto accountDetails(AccountID accountId)
	{
		auto res = request(accountsURL ~ "/" ~ accountId);
		return deserializeJson!(Account)(res["account"]);
	}

	auto accountSummary(AccountID accountId)
	{
		auto res = request(accountsURL ~ "/" ~ accountId ~ "/summary");
		return deserializeJson!(AccountSummary)(res["account"]);
	}

	auto accountInstruments(AccountID accountId, InstrumentName[] instruments ...)
	{
		//TODO: Query specific instruments
		auto res = request(accountsURL ~ "/" ~ accountId ~ "/instruments");
		return res["instruments"].toString.deserializeWithPolicy!(JsonStringSerializer, UpperCasePolicy, Instrument[]);
		//return res["instruments"].deserializeWithPolicy!(JsonSerializer, UpperCasePolicy, Instrument[]);
	}

	auto configureAccount(string alias_, DecimalNumber marginRate)
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
