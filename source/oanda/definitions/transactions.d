module oanda.definitions.transactions;

import oanda.definitions.primitives;
import oanda.definitions.account : AccountID, AccountUnits, FundingReason, AccountFinancingMode;
import oanda.definitions.pricing : PriceValue;
import oanda.definitions.orders : TimeInForce, OrderPositionFill, OrderID;
import oanda.definitions.trades : TradeID;

import std.variant : Algebraic;
import vibe.data.serialization;

/// A Transaction identifier. Used by clients to refer to their Transactions.
alias string TransactionID;

/// The request identifier. Used by administrators to refer to a client’s request.
alias string RequestID;

/// The class of a Transaction. A TransactionClass groups together related Transactions.
enum TransactionClass
{
	/// Order-related Transactions. These are the Transactions that create, cancel, fill or trigger Orders.
	order,
	/// Funding-related Transactions.
	funding,
	/// Administrative Transactions.
	admin
}

/// The type of a Transaction
enum TransactionType
{
	create,
	close,
	reopen,
	clientConfigure,
	clientConfigureReject,
	transferFunds,
	transferFundsReject,
	marketOrder,
}

alias Algebraic!(
		CreateTransaction, CloseTransaction, ReopenTransaction, ClientConfigureTransaction,
		ClientConfigureRejectTransaction, TransferFundsTransaction, TransferFundsRejectTransaction,
		MarketOrderTransaction, MarketOrderRejectTransaction, LimitOrderTransaction, LimitOrderRejectTransaction,
		StopOrderTransaction, StopOrderRejectTransaction, MarketIfTouchedOrderTransaction,
		MarketIfTouchedOrderRejectTransaction, TakeProfitOrderTransaction, TakeProfitOrderRejectTransaction,
		StopLossOrderTransaction, StopLossOrderRejectTransaction, TrailingStopLossOrderTransaction,
		TrailingStopLossOrderRejectTransaction, OrderFillTransaction, OrderCancelTransaction,
		OrderCancelRejectTransaction, OrderClientExtensionsModifyTransaction, OrderClientExtensionsModifyRejectTransaction,
		TradeClientExtensionsModifyTransaction, TradeClientExtensionsModifyRejectTransaction, MarginCallEnterTransaction,
		MarginCallExtendTransaction, MarginCallExitTransaction, DailyFinancingTransaction, ResetResettablePLTransaction
	) TransactionPayload;

/**
 * The base Transaction definition containing properties common to all Transaction.
 * 
 * See_Also:
 * 		CreateTransaction, CloseTransaction, ReopenTransaction, ClientConfigureTransaction,
 * 		ClientConfigureRejectTransaction, TransferFundsTransaction, TransferFundsRejectTransaction,
 * 		MarketOrderTransaction, MarketOrderRejectTransaction, LimitOrderTransaction, LimitOrderRejectTransaction,
 * 		StopOrderTransaction, StopOrderRejectTransaction, MarketIfTouchedOrderTransaction,
 * 		MarketIfTouchedOrderRejectTransaction, TakeProfitOrderTransaction, TakeProfitOrderRejectTransaction,
 * 		StopLossOrderTransaction, StopLossOrderRejectTransaction, TrailingStopLossOrderTransaction,
 * 		TrailingStopLossOrderRejectTransaction, OrderFillTransaction, OrderCancelTransaction,
 * 		OrderCancelRejectTransaction, OrderClientExtensionsModifyTransaction, OrderClientExtensionsModifyRejectTransaction,
 * 		TradeClientExtensionsModifyTransaction, TradeClientExtensionsModifyRejectTransaction, MarginCallEnterTransaction,
 * 		MarginCallExtendTransaction, MarginCallExitTransaction, DailyFinancingTransaction, ResetResettablePLTransaction
 */
struct Transaction
{
	/// The Transaction’s Identifier.
	TransactionID id;
	/// The date/time when the Transaction was created.
	SysTime time;
	/// The ID of the user that initiated the creation of the Transaction.
	int userID;
	/// The ID of the Account the Transaction was created for.
	AccountID accountID;
	/// The ID of the “batch” that the Transaction belongs to. Transactions in the same batch are applied to the Account simultaneously.
	TransactionID batchID;
	/// The Type of the Transaction.
	TransactionType type;

	/// Transaction payload accoording the type
	TransactionPayload payload;
}

/// A CreateTransaction represents the creation of an Account.
struct CreateTransaction
{
	/// The ID of the Division that the Account is in
	int divisionID;
	/// The ID of the Site that the Account was created at
	int siteID;
	/// The ID of the user that the Account was created for
	int accountUserID;
	/// The number of the Account within the site/division/user
	int accountNumber;
	/// The home currency of the Account
	Currency homeCurrency;
}

/// A CloseTransaction represents the closing of an Account.
struct CloseTransaction
{
}

/// A ReopenTransaction represents the re-opening of a closed Account.
struct ReopenTransaction
{
}

/// A ClientConfigureTransaction represents the configuration of an Account by a client.
struct ClientConfigureTransaction
{
	/// The client-provided alias for the Account.
	@name("alias") string alias_;
	/// The margin rate override for the Account.
	DecimalNumber marginRate;
}

/// A ClientConfigureRejectTransaction represents the reject of configuration of an Account by a client.
struct ClientConfigureRejectTransaction
{
	/// The client-provided alias for the Account.
	@name("alias") string alias_;
	/// The margin rate override for the Account.
	DecimalNumber marginRate;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// A TransferFundsTransaction represents the transfer of funds in/out of an Account.
struct TransferFundsTransaction
{
	/// The amount to deposit/withdraw from the Account in the Account’s home currency. A positive value indicates a deposit, a negative value indicates a withdrawal.
	AccountUnits amount;
	/// The reason that an Account is being funded.
	FundingReason fundingReason;
	/// The Account’s balance after funds are transferred.
	AccountUnits accountBalance;
}

/// A TransferFundsRejectTransaction represents the rejection of the transfer of funds in/out of an Account.
struct TransferFundsRejectTransaction
{
	/// The amount to deposit/withdraw from the Account in the Account’s home currency. A positive value indicates a deposit, a negative value indicates a withdrawal.
	AccountUnits amount;
	/// The reason that an Account is being funded.
	FundingReason fundingReason;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// The reason that the Market Order was initiated
enum MarketOrderReason
{
	/// The Market Order was initiated at the request of a client
	clientOrder,
	/// The Market Order was initiated as a Trade Close at the request of a client
	tradeClose,
	/// The Market Order was initiated as a Position Closeout at the request of a client
	positionCloseout,
	/// The Market Order was initiated as part of a Margin Closeout
	marginCloseout
}

/**
 * A MarketOrderTransaction represents the creation of a Market Order in the user’s account.
 * A Market Order is an Order that is filled immediately at the current market price.
 * Market Orders can be specialized when they are created to accomplish a specific task: to close a Trade,
 * to closeout a Position or to particiate in in a Margin closeout.
 */
struct MarketOrderTransaction
{
	/// The Market Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the Market Order.
	DecimalNumber units;
	/// he time-in-force requested for the Market Order. Restricted to FOK or IOC for a MarketOrder. [default=FOK]
	TimeInForce timeInForce;
	/// The worst price that the client is willing to have the Market Order filled at.
	PriceValue priceBound;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// Details of the Trade requested to be closed, only provided when the Market Order is being used to explicitly close a Trade.
	MarketOrderTradeClose tradeClose;
	/// Details of the long Position requested to be closed out, only provided when a Market Order is being used to explicitly closeout a long Position.
	MarketOrderPositionCloseout longPositionCloseout;
	/// Details of the short Position requested to be closed out, only provided when a Market Order is being used to explicitly closeout a short Position.
	MarketOrderPositionCloseout shortPositionCloseout;
	/// The reason that the Market Order was initiated
	MarketOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The specification of the Take Profit Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	TakeProfitDetails takeProfitOnFill;
	/// The specification of the Stop Loss Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	StopLossDetails stopLossOnFill;
	/// The specification of the Trailing Stop Loss Order that should be created for a Trade that is opened when the Order is filled (if such a Trade is created).
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
}

/// A MarketOrderRejectTransaction represents the rejection of the creation of a Market Order.
struct MarketOrderRejectTransaction
{
	/// The Market Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the Market Order.
	DecimalNumber units;
	/// he time-in-force requested for the Market Order. Restricted to FOK or IOC for a MarketOrder. [default=FOK]
	TimeInForce timeInForce;
	/// The worst price that the client is willing to have the Market Order filled at.
	PriceValue priceBound;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// Details of the Trade requested to be closed, only provided when the Market Order is being used to explicitly close a Trade.
	MarketOrderTradeClose tradeClose;
	/// Details of the long Position requested to be closed out, only provided when a Market Order is being used to explicitly closeout a long Position.
	MarketOrderPositionCloseout longPositionCloseout;
	/// Details of the short Position requested to be closed out, only provided when a Market Order is being used to explicitly closeout a short Position.
	MarketOrderPositionCloseout shortPositionCloseout;
	/// The reason that the Market Order was initiated
	MarketOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The specification of the Take Profit Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	TakeProfitDetails takeProfitOnFill;
	/// The specification of the Stop Loss Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	StopLossDetails stopLossOnFill;
	/// The specification of the Trailing Stop Loss Order that should be created for a Trade that is opened when the Order is filled (if such a Trade is created).
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// The reason that the Limit Order was initiated
enum LimitOrderReason
{
	/// The Limit Order was initiated at the request of a client
	clientOrder,
	/// The Limit Order was initiated as a replacement for an existing Order
	replacement
}

struct LimitOrderTransaction
{
	// The Limit Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the Limit Order.
	DecimalNumber units;
	/// The price threshold specified for the Limit Order. The Limit Order will only be filled by a market price that is equal to or better than this price.
	PriceValue price;
	/// The time-in-force requested for the Limit Order. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the Limit Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// The reason that the Limit Order was initiated
	LimitOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The specification of the Take Profit Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	TakeProfitDetails takeProfitOnFill;
	/// The specification of the Stop Loss Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	StopLossDetails stopLossOnFill;
	/// The specification of the Trailing Stop Loss Order that should be created for a Trade that is opened when the Order is filled (if such a Trade is created).
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// The ID of the Order that this Order replaces (only provided if this Order replaces an existing Order).
	OrderID replacesOrderID;
	/// The ID of the Transaction that cancels the replaced Order (only provided if this Order replaces an existing Order).
	TransactionID replacedOrderCancelTransactionID;
}

struct LimitOrderRejectTransaction
{
	// The Limit Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the Limit Order.
	DecimalNumber units;
	/// The price threshold specified for the Limit Order. The Limit Order will only be filled by a market price that is equal to or better than this price.
	PriceValue price;
	/// The time-in-force requested for the Limit Order. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the Limit Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// The reason that the Limit Order was initiated
	LimitOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The specification of the Take Profit Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	TakeProfitDetails takeProfitOnFill;
	/// The specification of the Stop Loss Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	StopLossDetails stopLossOnFill;
	/// The specification of the Trailing Stop Loss Order that should be created for a Trade that is opened when the Order is filled (if such a Trade is created).
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// The ID of the Order that this Order was intended to replace (only provided if this Order was intended to replace an existing Order).
	OrderID intendedReplacesOrderID;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// The reason that the Stop Order was initiated
enum StopOrderReason
{
	/// The Stop Order was initiated at the request of a client
	clientOrder,
	/// The Stop Order was initiated as a replacement for an existing Order
	replacement
}

/// A StopOrderTransaction represents the creation of a Stop Order in the user’s Account.
struct StopOrderTransaction
{
	/// The Stop Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the Stop Order.
	DecimalNumber units;
	/// The price threshold specified for the Stop Order. The Stop Order will only be filled by a market price that is equal to or worse than this price.
	PriceValue price;
	/// The worst market price that may be used to fill this Stop Order. If the market gaps and crosses through both the price and the priceBound, the Stop Order will be cancelled instead of being filled.
	PriceValue priceBound;
	/// The time-in-force requested for the Stop Order. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the Stop Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// The reason that the Stop Order was initiated
	StopOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The specification of the Take Profit Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	TakeProfitDetails takeProfitOnFill;
	/// The specification of the Stop Loss Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	StopLossDetails stopLossOnFill;
	/// The specification of the Trailing Stop Loss Order that should be created for a Trade that is opened when the Order is filled (if such a Trade is created).
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// The ID of the Order that this Order replaces (only provided if this Order replaces an existing Order).
	OrderID replacesOrderID;
	/// The ID of the Transaction that cancels the replaced Order (only provided if this Order replaces an existing Order).
	TransactionID replacedOrderCancelTransactionID;
}

/// A StopOrderRejectTransaction represents the rejection of the creation of a Stop Order.
struct StopOrderRejectTransaction
{
	/// The Stop Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the Stop Order.
	DecimalNumber units;
	/// The price threshold specified for the Stop Order. The Stop Order will only be filled by a market price that is equal to or worse than this price.
	PriceValue price;
	/// The worst market price that may be used to fill this Stop Order. If the market gaps and crosses through both the price and the priceBound, the Stop Order will be cancelled instead of being filled.
	PriceValue priceBound;
	/// The time-in-force requested for the Stop Order. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the Stop Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// The reason that the Stop Order was initiated
	StopOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The specification of the Take Profit Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	TakeProfitDetails takeProfitOnFill;
	/// The specification of the Stop Loss Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	StopLossDetails stopLossOnFill;
	/// The specification of the Trailing Stop Loss Order that should be created for a Trade that is opened when the Order is filled (if such a Trade is created).
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// The ID of the Order that this Order replaces (only provided if this Order replaces an existing Order).
	OrderID intendedReplacesOrderID;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// The reason that the Market-if-touched Order was initiated
enum MarketIfTouchedOrderReason
{
	/// The Market-if-touched Order was initiated at the request of a client
	clientOrder,
	/// The Market-if-touched Order was initiated as a replacement for an existing Order
	replacement
}

/// A MarketIfTouchedOrderTransaction represents the creation of a MarketIfTouched Order in the user’s Account.
struct MarketIfTouchedOrderTransaction
{
	/// The MarketIfTouched Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the MarketIfTouched Order.
	DecimalNumber units;
	/**
	 * The price threshold specified for the MarketIfTouched Order.
	 * The MarketIfTouched Order will only be filled by a market price that crosses this price from the direction
	 * of the market price at the time when the Order was created (the initialMarketPrice).
	 * Depending on the value of the Order’s price and initialMarketPrice, the MarketIfTouchedOrder will behave like a Limit or a Stop Order.
	 */
	PriceValue price;
	/// The Market price at the time when the MarketIfTouched Order was created.
	PriceValue initialMarketPrice;
	/// The worst market price that may be used to fill this MarketIfTouched Order.
	PriceValue priceBound;
	/// The time-in-force requested for the MarketIfTouched Order. Restricted to “GTC”, “GFD” and “GTD” for MarketIfTouched Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the MarketIfTouched Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// The reason that the Market-if-touched Order was initiated
	MarketIfTouchedOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The specification of the Take Profit Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	TakeProfitDetails takeProfitOnFill;
	/// The specification of the Stop Loss Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	StopLossDetails stopLossOnFill;
	/// The specification of the Trailing Stop Loss Order that should be created for a Trade that is opened when the Order is filled (if such a Trade is created).
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// The ID of the Order that this Order replaces (only provided if this Order replaces an existing Order).
	OrderID replacesOrderID;
	/// The ID of the Transaction that cancels the replaced Order (only provided if this Order replaces an existing Order).
	TransactionID replacedOrderCancelTransactionID;
}

/// A MarketIfTouchedOrderRejectTransaction represents the rejection of the creation of a MarketIfTouched Order.
struct MarketIfTouchedOrderRejectTransaction
{
	/// The MarketIfTouched Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the MarketIfTouched Order.
	DecimalNumber units;
	/**
	 * The price threshold specified for the MarketIfTouched Order.
	 * The MarketIfTouched Order will only be filled by a market price that crosses this price from the direction
	 * of the market price at the time when the Order was created (the initialMarketPrice).
	 * Depending on the value of the Order’s price and initialMarketPrice, the MarketIfTouchedOrder will behave like a Limit or a Stop Order.
	 */
	PriceValue price;
	/// The Market price at the time when the MarketIfTouched Order was created.
	PriceValue initialMarketPrice;
	/// The worst market price that may be used to fill this MarketIfTouched Order.
	PriceValue priceBound;
	/// The time-in-force requested for the MarketIfTouched Order. Restricted to “GTC”, “GFD” and “GTD” for MarketIfTouched Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the MarketIfTouched Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// The reason that the Market-if-touched Order was initiated
	MarketIfTouchedOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The specification of the Take Profit Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	TakeProfitDetails takeProfitOnFill;
	/// The specification of the Stop Loss Order that should be created for a Trade opened when the Order is filled (if such a Trade is created).
	StopLossDetails stopLossOnFill;
	/// The specification of the Trailing Stop Loss Order that should be created for a Trade that is opened when the Order is filled (if such a Trade is created).
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// The ID of the Order that this Order was intended to replace (only provided if this Order was intended to replace an existing Order).
	OrderID intendedReplacesOrderID;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// The reason that the Take Profit Order was initiated
enum TakeProfitOrderReason
{
	/// The Take Profit Order was initiated at the request of a client
	clientOrder,
	/// The Take Profit Order was initiated as a replacement for an existing Order
	replacement,
	/// The Take Profit Order was initiated automatically when an Order was filled that opened a new Trade requiring a Take Profit Order.
	onFill
}

/// A TakeProfitOrderTransaction represents the creation of a TakeProfit Order in the user’s Account.
struct TakeProfitOrderTransaction
{
	/// The ID of the Trade to close when the price threshold is breached.
	TradeID tradeID;
	/// The client ID of the Trade to be closed when the price threshold is breached.
	ClientID clientTradeID;
	/// The price threshold specified for the TakeProfit Order. The associated Trade will be closed by a market price that is equal to or better than this threshold.
	PriceValue price;
	/// The time-in-force requested for the TakeProfit Order. Restricted to “GTC”, “GFD” and “GTD” for TakeProfit Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the TakeProfit Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// The reason that the Take Profit Order was initiated
	TakeProfitOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The ID of the OrderFill Transaction that caused this Order to be created (only provided if this Order was created automatically when another Order was filled).
	TransactionID orderFillTransactionID;
	/// The ID of the Order that this Order replaces (only provided if this Order replaces an existing Order).
	OrderID replacesOrderID;
	/// The ID of the Transaction that cancels the replaced Order (only provided if this Order replaces an existing Order).
	TransactionID replacedOrderCancelTransactionID;
}

/// A TakeProfitOrderRejectTransaction represents the rejection of the creation of a TakeProfit Order.
struct TakeProfitOrderRejectTransaction
{
	/// The ID of the Trade to close when the price threshold is breached.
	TradeID tradeID;
	/// The client ID of the Trade to be closed when the price threshold is breached.
	ClientID clientTradeID;
	/// The price threshold specified for the TakeProfit Order. The associated Trade will be closed by a market price that is equal to or better than this threshold.
	PriceValue price;
	/// The time-in-force requested for the TakeProfit Order. Restricted to “GTC”, “GFD” and “GTD” for TakeProfit Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the TakeProfit Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// The reason that the Take Profit Order was initiated
	TakeProfitOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The ID of the OrderFill Transaction that caused this Order to be created (only provided if this Order was created automatically when another Order was filled).
	TransactionID orderFillTransactionID;
	/// The ID of the Order that this Order was intended to replace (only provided if this Order was intended to replace an existing Order).
	OrderID intendedReplacesOrderID;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// The reason that the Stop Loss Order was initiated
enum StopLossOrderReason
{
	/// The Stop Loss Order was initiated at the request of a client
	clientOrder,
	/// The Stop Loss Order was initiated as a replacement for an existing Order
	replacement,
	/// The Stop Loss Order was initiated automatically when an Order was filled that opened a new Trade requiring a Stop Loss Order.
	onFill
}

/// A StopLossOrderTransaction represents the creation of a StopLoss Order in the user’s Account.
struct StopLossOrderTransaction
{
	/// The ID of the Trade to close when the price threshold is breached.
	TradeID tradeID;
	/// The client ID of the Trade to be closed when the price threshold is breached.
	ClientID clientTradeID;
	/// The price threshold specified for the StopLoss Order. The associated Trade will be closed by a market price that is equal to or worse than this threshold.
	PriceValue price;
	/// The time-in-force requested for the StopLoss Order. Restricted to “GTC”, “GFD” and “GTD” for StopLoss Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the StopLoss Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// The reason that the Stop Loss Order was initiated
	StopLossOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The ID of the OrderFill Transaction that caused this Order to be created (only provided if this Order was created automatically when another Order was filled).
	TransactionID orderFillTransactionID;
	/// The ID of the Order that this Order replaces (only provided if this Order replaces an existing Order).
	OrderID replacesOrderID;
	/// The ID of the Transaction that cancels the replaced Order (only provided if this Order replaces an existing Order).
	TransactionID replacedOrderCancelTransactionID;
}

/// A StopLossOrderRejectTransaction represents the rejection of the creation of a StopLoss Order.
struct StopLossOrderRejectTransaction
{
	/// The ID of the Trade to close when the price threshold is breached.
	TradeID tradeID;
	/// The client ID of the Trade to be closed when the price threshold is breached.
	ClientID clientTradeID;
	/// The price threshold specified for the StopLoss Order. The associated Trade will be closed by a market price that is equal to or worse than this threshold.
	PriceValue price;
	/// The time-in-force requested for the StopLoss Order. Restricted to “GTC”, “GFD” and “GTD” for StopLoss Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the StopLoss Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// The reason that the Stop Loss Order was initiated
	StopLossOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The ID of the OrderFill Transaction that caused this Order to be created (only provided if this Order was created automatically when another Order was filled).
	TransactionID orderFillTransactionID;
	/// The ID of the Order that this Order was intended to replace (only provided if this Order was intended to replace an existing Order).
	OrderID intendedReplacesOrderID;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// The reason that the Trailing Stop Loss Order was initiated
enum TrailingStopLossOrderReason
{
	/// The Trailing Stop Loss Order was initiated at the request of a client
	clientOrder,
	/// The Trailing Stop Loss Order was initiated as a replacement for an existing Order
	replacement,
	/// The Trailing Stop Loss Order was initiated automatically when an Order was filled that opened a new Trade requiring a Trailing Stop Loss Order.
	onFill
}

/// A TrailingStopLossOrderTransaction represents the creation of a TrailingStopLoss Order in the user’s Account.
struct TrailingStopLossOrderTransaction
{
	/// The ID of the Trade to close when the price threshold is breached.
	TradeID tradeID;
	/// The client ID of the Trade to be closed when the price threshold is breached.
	ClientID clientTradeID;
	/// The price distance specified for the TrailingStopLoss Order.
	PriceValue distance;
	/// The time-in-force requested for the TrailingStopLoss Order. Restricted to “GTC”, “GFD” and “GTD” for TrailingStopLoss Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the StopLoss Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// The reason that the Trailing Stop Loss Order was initiated
	TrailingStopLossOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The ID of the OrderFill Transaction that caused this Order to be created (only provided if this Order was created automatically when another Order was filled).
	TransactionID orderFillTransactionID;
	/// The ID of the Order that this Order replaces (only provided if this Order replaces an existing Order).
	OrderID replacesOrderID;
	/// The ID of the Transaction that cancels the replaced Order (only provided if this Order replaces an existing Order).
	TransactionID replacedOrderCancelTransactionID;
}

/// A TrailingStopLossOrderRejectTransaction represents the rejection of the creation of a TrailingStopLoss Order.
struct TrailingStopLossOrderRejectTransaction
{
	/// The ID of the Trade to close when the price threshold is breached.
	TradeID tradeID;
	/// The client ID of the Trade to be closed when the price threshold is breached.
	ClientID clientTradeID;
	/// The price distance specified for the TrailingStopLoss Order.
	PriceValue distance;
	/// The time-in-force requested for the TrailingStopLoss Order. Restricted to “GTC”, “GFD” and “GTD” for TrailingStopLoss Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the StopLoss Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// The reason that the Trailing Stop Loss Order was initiated
	TrailingStopLossOrderReason reason;
	/// Client Extensions to add to the Order (only provided if the Order is being created with client extensions).
	ClientExtensions clientExtensions;
	/// The ID of the OrderFill Transaction that caused this Order to be created (only provided if this Order was created automatically when another Order was filled).
	TransactionID orderFillTransactionID;
	/// The ID of the Order that this Order was intended to replace (only provided if this Order was intended to replace an existing Order).
	OrderID intendedReplacesOrderID;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// The reason that an Order was filled
enum OrderFillReason
{
	/// The Order filled was a Limit Order
	limitOrder,
	/// The Order filled was a Stop Order
	stopOrder,
	/// The Order filled was a Market-if-touched Order
	marketIfTouchedOrder,
	/// The Order filled was a Take Profit Order
	takeProfitOrder,
	/// The Order filled was a Stop Loss Order
	stopLossOrder,
	/// The Order filled was a Trailing Stop Loss Order
	trailingStopLossOrder,
	/// The Order filled was a Market Order
	marketOrder,
	/// The Order filled was a Market Order used to explicitly close a Trade
	marketOrderTradeClose,
	/// The Order filled was a Market Order used to explicitly close a Position
	marketOrderPositionCLoseout,
	/// The Order filled was a Market Order used for a Margin Closeout
	marketOrderMarginCloseout
}

/// An OrderFillTransaction represents the filling of an Order in the client’s Account.
struct OrderFillTransaction
{
	/// The ID of the Order filled.
	OrderID orderID;
	/// The client Order ID of the Order filled (only provided if the client has assigned one).
	ClientID clientOrderID;
	/// The name of the filled Order’s instrument.
	InstrumentName instrument;
	/// The number of units filled by the Order.
	DecimalNumber units;
	/// The average market price that the Order was filled at.
	PriceValue price;
	/// The reason that an Order was filled
	OrderFillReason reason;
	/// The profit or loss incurred when the Order was filled.
	AccountUnits pl;
	/// The financing paid or collected when the Order was filled.
	AccountUnits financing;
	/// The Account’s balance after the Order was filled.
	AccountUnits accountBalance;
	/// The Trade that was opened when the Order was filled (only provided if filling the Order resulted in a new Trade).
	TradeOpen tradeOpened;
	/// The Trades that were closed when the Order was filled (only provided if filling the Order resulted in a closing open Trades).
	TradeReduce[] tradesClosed;
	/// The Trade that was reduced when the Order was filled (only provided if filling the Order resulted in reducing an open Trade).
	TradeReduce tradeReduced;
	/// The receipts of filled units with their prices that contributed to the volume-weighted average price that the entire Order was filled at.
	VWAPReceipt[] vwapReceipt;
	/// The account financing mode at the time of the Order fill.
	AccountFinancingMode accountFinancingMode;
	/// The liquidity regeneration schedule to in effect for this Account and instrument immediately following the OrderFill
	LiquidityRegenerationSchedule liquidityRegenerationSchedule;
}

/// The reason that an Order was cancelled.
enum OrderCancelReason
{
	/// The Order was cancelled because at the time of filling, an unexpected internal server error occured.
	internalServerError,
	/// The Order was cancelled because at the time of filling the account was locked.
	accountLocked,
	/// The order was to be filled, however the account is configured to not allow new positions to be created.
	accountNewPositionsLocked,
	/// Filling the Order wasn’t possible because it required the creation of a dependent Order and the Account is locked for Order creation.
	accountOrderCreationLocked,
	/// Filling the Order was not possible because the Account is locked for filling Orders.
	accountOrderFillLocked,
	/// The Order was cancelled explicitly at the request of the client.
	clientRequest,
	/// The Order cancelled because it is being migrated to another account.
	migration,
	/// Filling the Order wasn’t possible because the Order’s instrument was halted.
	marketHalted,
	/// The Order is linked to an open Trade that was closed.
	linkedTradeClosed,
	/// The time in force specified for this order has passed.
	timeInForceExpired,
	/// Filling the Order wasn’t possible because the Account had insufficient margin.
	insufficientMargin,
	/// Filling the Order would have resulted in a a FIFO violation.
	fifoViolation,
	/// Filling the Order would have violated the Order’s price bound.
	boundsViolation,
	/// The Order was cancelled for replacement.
	replaced,
	/// Filling the Order wasn’t possible because enough liquidity available.
	insufficientLiquidity,
	/// Filling the Order would have resulted in the creation of a Take Profit Order with a GTD time in the past.
	takeProfitOnFillGtdTimestampInPast,
	/// Filling the Order would result in the creation of a Take Profit Order that would have been filled immediately, closing the new Trade at a loss.
	takeProfitOnFillLoss,
	/// Filling the Order would result in the creation of a Take Profit Loss Order that would close the new Trade at a loss when filled.
	losingTakeProfit,
	/// Filling the Order would have resulted in the creation of a Stop Loss Order with a GTD time in the past.
	stopLossOnFillGtdTimestampInPast,
	/// Filling the Order would result in the creation of a Stop Loss Order that would have been filled immediately, closing the new Trade at a loss.
	stopLossOnFillLoss,
	/// Filling the Order would have resulted in the creation of a Trailing Stop Loss Order with a GTD time in the past.
	trailingStopLossOnFillGtdTimestampInPast,
	/// Filling the Order would result in the creation of a new Open Trade with a client Trade ID already in use.
	clientTradeIdAlreadyExists,
	/// Closing out a position wasn’t fully possible.
	positionCloseoutFailed,
	/// Filling the Order would cause the maximum open trades allowed for the Account to be exceeded.
	openTradesAllowedExceeded,
	/// Filling the Order would have resulted in exceeding the number of pending Orders allowed for the Account.
	pendingOrdersAllowedExceeded,
	/// Filling the Order would have resulted in the creation of a Take Profit Order with a client Order ID that is already in use.
	takeProfitOnFillClientOrderIdAlreadyExists,
	/// Filling the Order would have resulted in the creation of a Stop Loss Order with a client Order ID that is already in use.
	stopLossOnFillClientOrderIdAlreadyExists,
	/// Filling the Order would have resulted in the creation of a Trailing Stop Loss Order with a client Order ID that is already in use.
	trailingStopLossOnFillClientOrderIdAlreadyExists,
	/// Filling the Order would have resulted in the Account’s maximum position size limit being exceeded for the Order’s instrument.
	positionSizeExceeded
}

/// An OrderCancelTransaction represents the cancellation of an Order in the client’s Account.
struct OrderCancelTransaction
{
	/// The ID of the Order cancelled
	OrderID orderID;
	/// The client ID of the Order cancelled (only provided if the Order has a client Order ID).
	@optional ClientID clientOrderID;
	/// The reason that the Order was cancelled.
	OrderCancelReason reason;
	/// The ID of the Order that replaced this Order (only provided if this Order was cancelled for replacement).
	OrderID replacedByOrderID;
}

/// An OrderCancelRejectTransaction represents the rejection of the cancellation of an Order in the client’s Account.
struct OrderCancelRejectTransaction
{
	/// The ID of the Order intended to be cancelled
	OrderID orderID;
	/// The client ID of the Order intended to be cancelled (only provided if the Order has a client Order ID).
	@optional ClientID clientOrderID;
	/// The reason that the Order was to be cancelled.
	OrderCancelReason reason;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// A OrderClientExtensionsModifyTransaction represents the modification of an Order’s Client Extensions.
struct OrderClientExtensionsModifyTransaction
{
	/// The ID of the Order who’s client extensions are to be modified.
	OrderID orderID;
	/// The original Client ID of the Order who’s client extensions are to be modified.
	ClientID clientOrderID;
	/// The new Client Extensions for the Order.
	ClientExtensions orderClientExtensionsModify;
	/// The new Client Extensions for the Order’s Trade on fill.
	ClientExtensions tradeClientExtensionsModify;
}

/// A OrderClientExtensionsModifyRejectTransaction represents the rejection of the modification of an Order’s Client Extensions.
struct OrderClientExtensionsModifyRejectTransaction
{
	/// The ID of the Order who’s client extensions are to be modified.
	OrderID orderID;
	/// The original Client ID of the Order who’s client extensions are to be modified.
	ClientID clientOrderID;
	/// The new Client Extensions for the Order.
	ClientExtensions orderClientExtensionsModify;
	/// The new Client Extensions for the Order’s Trade on fill.
	ClientExtensions tradeClientExtensionsModify;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// A TradeClientExtensionsModifyTransaction represents the modification of a Trade’s Client Extensions.
struct TradeClientExtensionsModifyTransaction
{
	/// The ID of the Trade who’s client extensions are to be modified.
	TradeID tradeID;
	/// The original Client ID of the Trade who’s client extensions are to be modified.
	ClientID clientTradeID;
	/// The new Client Extensions for the Trade.
	ClientExtensions tradeClientExtensionsModify;
}

/// A TradeClientExtensionsModifyRejectTransaction represents the rejection of the modification of a Trade’s Client Extensions.
struct TradeClientExtensionsModifyRejectTransaction
{
	/// The ID of the Trade who’s client extensions are to be modified.
	TradeID tradeID;
	/// The original Client ID of the Trade who’s client extensions are to be modified.
	ClientID clientTradeID;
	/// The new Client Extensions for the Trade.
	ClientExtensions tradeClientExtensionsModify;
	/// The reason that the Reject Transaction was created
	string rejectReason;
}

/// A MarginCallEnterTransaction is created when an Account enters the margin call state.
struct MarginCallEnterTransaction
{
}

/// A MarginCallEnterTransaction is created when an Account enters the margin call state.
struct MarginCallExtendTransaction
{
	/// The number of the extensions to the Account’s current margin call that have been applied. This value will be set to 1 for the first MarginCallExtend Transaction
	int extensionNumber;
}

/// A MarginCallExitnterTransaction is created when an Account leaves the margin call state.
struct MarginCallExitTransaction
{
}

/// A DailyFinancingTransaction represents the daily payment/collection of financing for an Account.
struct DailyFinancingTransaction
{
	/// The amount of financing paid/collected for the Account.
	AccountUnits financing;
	/// The Account’s balance after daily financing.
	AccountUnits accountBalance;
	/// The account financing mode at the time of the daily financing.
	AccountFinancingMode accountFinancingMode;
	/// The financing paid/collected for each Position in the Account.
	PositionFinancing[] positionFinancings;
}

/// A ResetResettablePLTransaction represents the resetting of the Account’s resettable PL counters.
struct ResetResettablePLTransaction
{
}

/// A client-provided identifier, used by clients to refer to their Orders or Trades with an identifier that they have provided.
alias string ClientID;

/// A client-provided tag that can contain any data and may be assigned to their Orders or Trades. Tags are typically used to associate groups of Trades and/or Orders together.
alias string ClientTag;

/// A client-provided comment that can contain any data and may be assigned to their Orders or Trades. Comments are typically used to provide extra context or meaning to an Order or Trade.
alias string ClientComment;

/// A ClientExtensions object allows a client to attach a clientID, tag and comment to Orders and Trades in their Account.
struct ClientExtensions
{
	/// The Client ID of the Order/Trade
	ClientID id;
	/// A tag associated with the Order/Trade
	ClientTag tag;
	/// A comment associated with the Order/Trade
	ClientComment comment;
}

/**
 * TakeProfitDetails specifies the details of a Take Profit Order to be created on behalf of a client.
 * This may happen when an Order is filled that opens a Trade requiring a Take Profit,
 * or when a Trade’s dependent Take Profit Order is modified directly through the Trade.
 */
struct TakeProfitDetails
{
	/// The price that the Take Profit Order will be triggered at.
	PriceValue price;
	/// The time in force for the created Take Profit Order. This may only be GTC, GTD or GFD. [default=GTC]
	TimeInForce timeInForce;
	/// The date when the Take Profit Order will be cancelled on if timeInForce is GTD.
	SysTime gtdTime;
	/// The Client Extensions to add to the Take Profit Order when created.
	ClientExtensions clientExtensions;
}

/**
 * StopLossDetails specifies the details of a Stop Loss Order to be created on behalf of a client.
 * This may happen when an Order is filled that opens a Trade requiring a Stop Loss,
 * or when a Trade’s dependent Stop Loss Order is modified directly through the Trade.
 */
struct StopLossDetails
{
	/// The price that the Stop Loss Order will be triggered at.
	PriceValue price;
	/// The time in force for the created Stop Loss Order. This may only be GTC, GTD or GFD. [default=GTC]
	TimeInForce timeInForce;
	/// The date when the Stop Loss Order will be cancelled on if timeInForce is GTD.
	SysTime gtdTime;
	/// The Client Extensions to add to the Stop Loss Order when created.
	ClientExtensions clientExtensions;
}

/**
 * TrailingStopLossDetails specifies the details of a Trailing Stop Loss Order to be created on behalf of a client.
 * This may happen when an Order is filled that opens a Trade requiring a Trailing Stop Loss,
 * or when a Trade’s dependent Trailing Stop Loss Order is modified directly through the Trade.
 */
struct TrailingStopLossDetails
{
	/// The distance (in price units) from the Trade’s fill price that the Trailing Stop Loss Order will be triggered at.
	PriceValue distance;
	/// The time in force for the created Trailing Stop Loss Order. This may only be GTC, GTD or GFD. [default=GTC]
	TimeInForce timeInForce;
	/// The date when the Trailing Stop Loss Order will be cancelled on if timeInForce is GTD.
	SysTime gtdTime;
	/// The Client Extensions to add to the Trailing Stop Loss Order when created.
	ClientExtensions clientExtensions;
}

/**
 * A TradeOpen object represents a Trade for an instrument that was opened in an Account.
 * It is found embedded in Transactions that affect the position of an instrument in the Account, specifically the OrderFill Transaction.
 */
struct TradeOpen
{
	/// The ID of the Trade that was opened
	TradeID tradeID;
	/// The number of units opened by the Trade
	DecimalNumber units;
	/// The client extensions for the newly opened Trade
	ClientExtensions clientExtensions;
}

/**
 * A TradeReduce object represents a Trade for an instrument that was reduced (either partially or fully) in an Account.
 * It is found embedded in Transactions that affect the position of an instrument in the account, specifically the OrderFill Transaction.
 */
struct TradeReduce
{
	/// The ID of the Trade that was reduced or closed
	TradeID tradeID;
	/// The number of units that the Trade was reduced by
	DecimalNumber units;
	/// The PL realized when reducing the Trade
	AccountUnits realizedPL;
	/// The financing paid/collected when reducing the Trade
	AccountUnits financing;
}

/**
 * A MarketOrderTradeClose specifies the extensions to a Market Order that has been created specifically to close a Trade.
 */
struct MarketOrderTradeClose
{
	/// The ID of the Trade requested to be closed
	TradeID tradeID;
	/// The client ID of the Trade requested to be closed
	string clientTradeID;
	/// Indication of how much of the Trade to close. Either “ALL”, or a DecimalNumber reflection a partial close of the Trade.
	string units;
}

/**
 * A MarketOrderPositionCloseout specifies the extensions to a Market Order when it has been created to closeout a specific Position.
 */
struct MarketOrderPositionCloseout
{
	/// The instrument of the Position being closed out.
	InstrumentName instrument;
	/**
	 * Indication of how much of the Position to close. Either “ALL”, or a DecimalNumber reflection a partial
	 * close of the Trade. The DecimalNumber must always be positive, and represent a number that doesn’t exceed
	 * the absolute size of the Position.
	 */
	string units;
}

/**
 * A VWAP Receipt provides a record of how the price for an Order fill is constructed.
 * If the Order is filled with multiple buckets in a depth of market, each bucket will be represented with a VWAP Receipt.
 */
struct VWAPReceipt
{
	/// The number of units filled
	DecimalNumber units;
	/// The price at which the units were filled
	PriceValue price;
}

/**
 * A LiquidityRegenerationSchedule indicates how liquidity that is used when filling an Order
 * for an instrument is regenerated following the fill. A liquidity regeneration schedule will be in effect
 * until the timestamp of its final step, but may be replaced by a schedule created for an Order of the same
 * instrument that is filled while it is still in effect.
 */
struct LiquidityRegenerationSchedule
{
	/// The steps in the Liquidity Regeneration Schedule
	LiquidityRegenerationScheduleStep[] steps;
}

/**
 * A liquidity regeneration schedule Step indicates the amount of bid and ask liquidity that is used
 * by the Account at a certain time. These amounts will only change at the timestamp of the following step.
 */
struct LiquidityRegenerationScheduleStep
{
	/// The timestamp of the schedule step.
	SysTime timestamp;
	/// The amount of bid liquidity used at this step in the schedule.
	DecimalNumber bidLiquidityUsed;
	/// The amount of ask liquidity used at this step in the schedule.
	DecimalNumber askLiquidityUsed;
}

/**
 * OpenTradeFinancing is used to pay/collect daily financing charge for an open Trade within an Account
 */
struct OpenTradeFinancing
{
	/// The ID of the Trade that financing is being paid/collected for.
	TradeID tradeID;
	/// The amount of financing paid/collected for the Trade.
	AccountUnits financing;
}

/**
 * OpenTradeFinancing is used to pay/collect daily financing charge for a Position within an Account
 */
struct PositionFinancing
{
	/// The instrument of the Position that financing is being paid/collected for.
	InstrumentName instrumentID;
	/// The amount of financing paid/collected for the Position.
	AccountUnits financing;
	/// The financing paid/collecte for each open Trade within the Position.
	OpenTradeFinancing[] openTradeFinancings;
}

/**
 * A TransactionStream object is a message found in the Transaction stream.
 */
struct TransactionStream
{
	/// An Account Transaction in the Transaction stream
	Transaction transaction;
	/// A Heartbeat message in the Transaction stream
	Heartbeat heartbeat;
}

/**
 * A Heartbeat object that is injected in the Transaction stream to ensure that the HTTP connection remains active.
 */
struct Heartbeat
{
	/// The date/time when the Heartbeat was created.
	SysTime time;
}
