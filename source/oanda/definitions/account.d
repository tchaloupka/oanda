module oanda.definitions.account;

import oanda.definitions.primitives;
import oanda.definitions.transactions : TransactionID, Transaction;
import oanda.definitions.trades : TradeSummary, Trade, CalculatedTradeState;
import oanda.definitions.positions : Position, CalculatedPositionState;
import oanda.definitions.orders : Order, DynamicOrderState;

import vibe.data.serialization;

alias string AccountID;    /// The string representation of an Account Identifier.
alias string AccountUnits; /// The string representation of a quantity of an Account’s home currency.

mixin template AccountSummaryTemplate()
{
	/// The Account’s identifier
	AccountID id;
	/// Client-assigned alias for the Account. Only provided if the Account has an alias set
	@optional @name("alias") string alias_;
	/// The home currency of the Account
	Currency currency;
	/// The current balance of the Account. Represented in the Account’s home currency.
	AccountUnits balance;
	/// ID of the user that created the Account.
	int createdByUserID;
	/// The date/time when the Account was created.
	SysTime createdTime;
	/// The total profit/loss realized over the lifetime of the Account. Represented in the Account’s home currency.
	AccountUnits pl;
	/// The total realized profit/loss for the Account since it was last reset by the client. Represented in the Account’s home currency.
	@optional AccountUnits resettabledPL;
	/// The date/time that the Account’s resettablePL was last reset.
	@optional SysTime resettabledPLTime;
	/**
	 * Client-provided margin rate override for the Account.
	 * The effective margin rate of the Account is the lesser of this value and the OANDA margin rate for the Account’s division.
	 * This value is only provided if a margin rate override exists for the Account.
	 */
	@optional DecimalNumber marginRate;
	/// The date/time when the Account entered a margin call state. Only provided if the Account is in a margin call.
	@optional SysTime marginCallEnterTime;
	/// The number of times that the Account’s current margin call was extended.
	@optional int marginCallExtensionCount;
	/// The date/time of the Account’s last margin call extension.
	@optional SysTime lastMarginCallExtensionTime;
	/// The number of Trades currently open in the Account.
	int openTradeCount;
	/// The number of Positions currently open in the Account.
	int openPositionCount;
	/// The number of Orders currently pending in the Account.
	int pendingOrderCount;
	/// Flag indicating that the Account has hedging enabled.
	bool hedgingEnabled;
	/// The total unrealized profit/loss for all Trades currently open in the Account. Represented in the Account’s home currency.
	AccountUnits unrealizedPL;
	/// The net asset value of the Account. Equal to Account balance + unrealizedPL. Represented in the Account’s home currency.
	@name("NAV") AccountUnits nav;
	/// Margin currently used for the Account. Represented in the Account’s home currency.
	AccountUnits marginUsed;
	/// Margin available for Account. Represented in the Account’s home currency.
	AccountUnits marginAvailable;
	/// The value of the Account’s open positions represented in the Account’s home currency.
	AccountUnits positionValue;
	/// The Account’s margin closeout unrealized PL.
	AccountUnits marginCloseoutUnrealizedPL;
	/// The Account’s margin closeout NAV.
	AccountUnits marginCloseoutNAV;
	/// The Account’s margin closeout margin used.
	AccountUnits marginCloseoutMarginUsed;
	/// The Account’s margin closeout closeout percentage. The range of this value is 0.0 to 1.0.
	DecimalNumber marginCloseoutPercent;
	/// The current WithdrawalLimit for the account which will be zero or a positive value indicating how much can be withdrawn from the account.
	AccountUnits withdrawalLimit;
	/// The ID of the last Transaction created for the Account.
	TransactionID lastTransactionID;
}

/// The full details of a client’s Account. This includes full open Trade, open Position and pending Order representation.
struct Account
{
	mixin AccountSummaryTemplate;
	
	/// The details of the Trades currently open in the Account.
	TradeSummary[] trades;
	/// The details of all Positions currently open in the Account.
	Position[] positions;
	/// The details of the Orders currently pending in the Account.
	Order[] orders;
}

/// Properties related to an Account.
struct AccountProperties
{
	/// The Account’s identifier
	AccountID id;
	/// The Account’s associated MT4 Account ID. This field will not be present if the Account is not an MT4 account.
	@optional int mt4AccountID;
	/// The Account’s tags
	string[] tags;
}

/// A summary representation of a client’s Account. The AccountSummary does not provide to full specification of pending Orders, open Trades and Positions.
struct AccountSummary
{
	mixin AccountSummaryTemplate;
}

/// An AccountChanges Object is used to represent the changes to an Account’s Orders, Trades and Positions since a specified Account TransactionID in the past.
struct AccountChanges
{
	/// The Orders created. These Orders may have been filled, cancelled or triggered in the same period.
	Order[] ordersCreated;
	/// The Orders cancelled.
	Order[] ordersCancelled;
	/// The Orders filled.
	Order[] ordersFilled;
	/// The Orders triggered.
	Order[] ordersTriggered;
	/// The Trades opened.
	Trade[] tradesOpened;
	/// The Trades reduced.
	Trade[] tradesReduced;
	/// The Trades closed.
	Trade[] tradesClosed;
	/// The Positions changed.
	Position[] positions;
	/// The Transactions that have been generated.
	Transaction[] transactions;
}

/**
 * An AccountState Object is used to represent an Account’s current price-dependent state.
 * Price-dependent Account state is dependent on OANDA’s current Prices, and includes things like unrealized PL,
 * NAV and Trailing Stop Loss Order state.
 */
struct AccountState
{
	/// The total unrealized profit/loss for all Trades currently open in the Account. Represented in the Account’s home currency.
	AccountUnits unrealizedPL;
	/// The net asset value of the Account. Equal to Account balance + unrealizedPL. Represented in the Account’s home currency.
	@name("NAV") AccountUnits nav;
	/// Margin currently used for the Account. Represented in the Account’s home currency.
	AccountUnits marginUsed;
	/// Margin available for Account. Represented in the Account’s home currency.
	AccountUnits marginAvailable;
	/// The value of the Account’s open positions represented in the Account’s home currency.
	AccountUnits positionValue;
	/// The Account’s margin closeout unrealized PL.
	AccountUnits marginCloseoutUnrealizedPL;
	/// The Account’s margin closeout NAV.
	AccountUnits marginCloseoutNAV;
	/// The Account’s margin closeout margin used.
	AccountUnits marginCloseoutMarginUsed;
	/// The Account’s margin closeout closeout percentage. The range of this value is 0.0 to 1.0.
	DecimalNumber marginCloseoutPercent;
	/// The current WithdrawalLimit for the account which will be zero or a positive value indicating how much can be withdrawn from the account.
	AccountUnits withdrawalLimit;
	/// The price-dependent state of each pending Order in the Account.
	DynamicOrderState[] orders;
	/// The price-dependent state for each open Trade in the Account.
	CalculatedTradeState[] trades;
	/// The price-dependent state for each open Position in the Account.	
	CalculatedPositionState[] positions;
}

/// The financing mode of an Account
enum AccountFinancingMode
{
	/// No financing is paid/charged for open Trades in the Account
	noFinancing,
	/// Second-by-second financing is paid/charged for open Trades in the Account, both daily and when the the Trade is closed
	secondBySecond,
	/// A full day’s worth of financing is paid/charged for open Trades in the Account daily at 5pm New York time
	daily
}

/// The financing mode of an Account
enum PositionAggregationMode
{
	/// The Position value or margin for each side (long and short) of the Position are computed independently and added together.
	absoluteSum,
	/**
	 * The Position value or margin for each side (long and short) of the Position are computed independently.
	 * The Position value or margin chosen is the maximal absolute value of the two.
	 */
	maximalSide,
	/**
	 * The units for each side (long and short) of the Position are netted together and the resulting
	 * value (long or short) is used to compute the Position value or margin.
	 */
	netSum,
}

/// The reason that an Account is being funded.
enum FundingReason
{
	/// The client has initiated a funds transfer
	clientFunding,
	/// Funds are being transfered between two Accounts.
	accountTransfer,
	/// Funds are being transfered as part of a Division migration
	divisionMigration,
	/// Funds are being transfered as part of a Site migration
	siteMigration,
	/// Funds are being transfered as part of an Account adjustment
	adjustment
}