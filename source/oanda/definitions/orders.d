module oanda.definitions.orders;

import oanda.definitions.primitives;
import oanda.definitions.pricing : PriceValue;
import oanda.definitions.transactions;
import oanda.definitions.trades : TradeID;

import std.variant : Algebraic;
import vibe.data.serialization;

/**
 * The Order’s identifier, unique within the Order’s Account.
 * 
 * The string representation of the OANDA-assigned OrderID. OANDA-assigned OrderIDs are positive integers,
 * and are derived from the TransactionID of the Transaction that created the Order.
 */
alias string OrderID;

/**
 * The specification of an Order as referred to by clients
 * 
 * Either the Order’s OANDA-assigned OrderID or the Order’s client-provided ClientID prefixed by he “@” symbol
 */
alias string OrderSpecifier;

/**
 * The base Order definition specifies the properties that are common to all Orders.
 * 
 * See_Also:
 * 		MarketOrder, LimitOrder, StopOrder, MarketIfTouchedOrder, TakeProfitOrder, StopLossOrder, TrailingStopLossOrder
 */
struct Order
{
	/// The Order’s identifier, unique within the Order’s Account.
	OrderID id;
	/// The time when the Order was created.
	SysTime createTime;
	/// The current state of the Order.
	OrderState state;
	/// The client extensions of the Order.
	ClientExtensions clientExtensions;
	/// The type of the Order.
	OrderType type;

	Algebraic!(
		MarketOrder, LimitOrder, StopOrder, MarketIfTouchedOrder,
		TakeProfitOrder, StopLossOrder, TrailingStopLossOrder) payload;
}

/// A MarketOrder is an order that is filled immediately upon creation using the current market price.
struct MarketOrder
{
	/// The Market Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the Market Order.
	DecimalNumber units;
	/// The time-in-force requested for the Market Order. Restricted to FOK or IOC for a MarketOrder. [default=FOK]
	TimeInForce timeInForce;
	/// The worst price that the client is willing to have the Market Order filled at.
	PriceValue priceBound;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/// Details of the Trade requested to be closed, only provided when the Market Order is being used to explicitly close a Trade.
	@optional MarketOrderTradeClose tradeClose;
	/// Details of the long Position requested to be closed out, only provided when a Market Order is being used to explicitly closeout a long Position.
	@optional MarketOrderPositionCloseout longPositionCloseout;
	/// Details of the short Position requested to be closed out, only provided when a Market Order is being used to explicitly closeout a short Position.
	@optional MarketOrderPositionCloseout shortPositionCloseout;
	/**
	 * TakeProfitDetails specifies the details of a Take Profit Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Take Profit,
	 * or when a Trade’s dependent Take Profit Order is modified directly through the Trade.
	 */
	TakeProfitDetails takeProfitOnFill;
	/**
	 * StopLossDetails specifies the details of a Stop Loss Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Stop Loss,
	 * or when a Trade’s dependent Stop Loss Order is modified directly through the Trade.
	 */
	StopLossDetails stopLossOnFill;
	/**
	 * TrailingStopLossDetails specifies the details of a Trailing Stop Loss Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Trailing Stop Loss,
	 * or when a Trade’s dependent Trailing Stop Loss Order is modified directly through the Trade.
	 */
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// ID of the Transaction that filled this Order (only provided when the Order’s state is FILLED)
	@optional TransactionID fillingTransactionID;
	/// Date/time when the Order was filled (only provided when the Order’s state is FILLED)
	@optional SysTime filledTime;
	/// ID of the Transaction that cancelled the Order (only provided when the Order’s state is CANCELLED)
	@optional TransactionID cancellingTransactionID;
	/// Date/time when the Order was cancelled (only provided when the state of the Order is CANCELLED)
	@optional SysTime cancelledTime;
}

/// A LimitOrder is an order that is created with a price threshold, and will only be filled by a price that is equal to or better than the threshold.
struct LimitOrder
{
	/// The Limit Order’s Instrument.
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
	/**
	 * TakeProfitDetails specifies the details of a Take Profit Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Take Profit,
	 * or when a Trade’s dependent Take Profit Order is modified directly through the Trade.
	 */
	TakeProfitDetails takeProfitOnFill;
	/**
	 * StopLossDetails specifies the details of a Stop Loss Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Stop Loss,
	 * or when a Trade’s dependent Stop Loss Order is modified directly through the Trade.
	 */
	StopLossDetails stopLossOnFill;
	/**
	 * TrailingStopLossDetails specifies the details of a Trailing Stop Loss Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Trailing Stop Loss,
	 * or when a Trade’s dependent Trailing Stop Loss Order is modified directly through the Trade.
	 */
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// ID of the Transaction that filled this Order (only provided when the Order’s state is FILLED)
	@optional TransactionID fillingTransactionID;
	/// Date/time when the Order was filled (only provided when the Order’s state is FILLED)
	@optional SysTime filledTime;
	/// ID of the Transaction that cancelled the Order (only provided when the Order’s state is CANCELLED)
	@optional TransactionID cancellingTransactionID;
	/// Date/time when the Order was cancelled (only provided when the state of the Order is CANCELLED)
	@optional SysTime cancelledTime;
	/// The ID of the Order that was replaced by this Order (only provided if this Order was created as part of a cancel/replace).
	@optional OrderID replacesOrderID;
	/// The ID of the Order that replaced this Order (only provided if this Order was cancelled as part of a cancel/replace).
	@optional OrderID replacedByOrderID;
}

/// A StopOrder is an order that is created with a price threshold, and will only be filled by a price that is equal to or worse than the threshold.
struct StopOrder
{
	/// The Stop Order’s Instrument.
	InstrumentName instrument;
	/// The quantity requested to be filled by the Stop Order.
	DecimalNumber units;
	/// The price threshold specified for the Stop Order. The Stop Order will only be filled by a market price that is equal to or worse than this price.
	PriceValue price;
	/**
	 * The worst market price that may be used to fill this Stop Order.
	 * If the market gaps and crosses through both the price and the priceBound, the Stop Order will be cancelled instead of being filled.
	 */
	PriceValue priceBound;
	/// The time-in-force requested for the Limit Order. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the Limit Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/**
	 * TakeProfitDetails specifies the details of a Take Profit Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Take Profit,
	 * or when a Trade’s dependent Take Profit Order is modified directly through the Trade.
	 */
	TakeProfitDetails takeProfitOnFill;
	/**
	 * StopLossDetails specifies the details of a Stop Loss Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Stop Loss,
	 * or when a Trade’s dependent Stop Loss Order is modified directly through the Trade.
	 */
	StopLossDetails stopLossOnFill;
	/**
	 * TrailingStopLossDetails specifies the details of a Trailing Stop Loss Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Trailing Stop Loss,
	 * or when a Trade’s dependent Trailing Stop Loss Order is modified directly through the Trade.
	 */
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// ID of the Transaction that filled this Order (only provided when the Order’s state is FILLED)
	@optional TransactionID fillingTransactionID;
	/// Date/time when the Order was filled (only provided when the Order’s state is FILLED)
	@optional SysTime filledTime;
	/// ID of the Transaction that cancelled the Order (only provided when the Order’s state is CANCELLED)
	@optional TransactionID cancellingTransactionID;
	/// Date/time when the Order was cancelled (only provided when the state of the Order is CANCELLED)
	@optional SysTime cancelledTime;
	/// The ID of the Order that was replaced by this Order (only provided if this Order was created as part of a cancel/replace).
	@optional OrderID replacesOrderID;
	/// The ID of the Order that replaced this Order (only provided if this Order was cancelled as part of a cancel/replace).
	@optional OrderID replacedByOrderID;
}

/// A MarketIfTouchedOrder is an order that is created with a price threshold, and will only be filled by a market price that is touches or crosses the threshold.
struct MarketIfTouchedOrder
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
	/// The time-in-force requested for the Limit Order. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the Limit Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// Specification of how Positions in the Account are modified when the Order is filled. [default=DEFAULT]
	OrderPositionFill positionFill;
	/**
	 * TakeProfitDetails specifies the details of a Take Profit Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Take Profit,
	 * or when a Trade’s dependent Take Profit Order is modified directly through the Trade.
	 */
	TakeProfitDetails takeProfitOnFill;
	/**
	 * StopLossDetails specifies the details of a Stop Loss Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Stop Loss,
	 * or when a Trade’s dependent Stop Loss Order is modified directly through the Trade.
	 */
	StopLossDetails stopLossOnFill;
	/**
	 * TrailingStopLossDetails specifies the details of a Trailing Stop Loss Order to be created on behalf of a client.
	 * This may happen when an Order is filled that opens a Trade requiring a Trailing Stop Loss,
	 * or when a Trade’s dependent Trailing Stop Loss Order is modified directly through the Trade.
	 */
	TrailingStopLossDetails trailingStopLossOnFill;
	/// Client Extensions to add to the Trade created when the Order is filled (if such a Trade is created).
	ClientExtensions tradeClientExtensions;
	/// ID of the Transaction that filled this Order (only provided when the Order’s state is FILLED)
	@optional TransactionID fillingTransactionID;
	/// Date/time when the Order was filled (only provided when the Order’s state is FILLED)
	@optional SysTime filledTime;
	/// ID of the Transaction that cancelled the Order (only provided when the Order’s state is CANCELLED)
	@optional TransactionID cancellingTransactionID;
	/// Date/time when the Order was cancelled (only provided when the state of the Order is CANCELLED)
	@optional SysTime cancelledTime;
	/// The ID of the Order that was replaced by this Order (only provided if this Order was created as part of a cancel/replace).
	@optional OrderID replacesOrderID;
	/// The ID of the Order that replaced this Order (only provided if this Order was cancelled as part of a cancel/replace).
	@optional OrderID replacedByOrderID;
}

/**
 * A TakeProfitOrder is an order that is linked to an open Trade and created with a price threshold.
 * The Order will be filled (closing the Trade) by the first price that is equal to or better than the threshold.
 * A TakeProfitOrder cannot be used to open a new Position.
 */
struct TakeProfitOrder
{
	/// The ID of the Trade to close when the price threshold is breached.
	TradeID tradeID;
	/// The client ID of the Trade to be closed when the price threshold is breached.
	ClientID clientTradeID;
	/**
	 * The price threshold specified for the TakeProfit Order.
	 * The associated Trade will be closed by a market price that is equal to or better than this threshold.
	 */
	PriceValue price;
	/// The time-in-force requested for the TakeProfit Order. Restricted to “GTC”, “GFD” and “GTD” for TakeProfit Orders. [default=GTC]
	TimeInForce timeInForce;
	/// The date/time when the TakeProfit Order will be cancelled if its timeInForce is “GTD”.
	SysTime gtdTime;
	/// ID of the Transaction that filled this Order (only provided when the Order’s state is FILLED)
	@optional TransactionID fillingTransactionID;
	/// Date/time when the Order was filled (only provided when the Order’s state is FILLED)
	@optional SysTime filledTime;
	/// ID of the Transaction that cancelled the Order (only provided when the Order’s state is CANCELLED)
	@optional TransactionID cancellingTransactionID;
	/// Date/time when the Order was cancelled (only provided when the state of the Order is CANCELLED)
	@optional SysTime cancelledTime;
	/// The ID of the Order that was replaced by this Order (only provided if this Order was created as part of a cancel/replace).
	@optional OrderID replacesOrderID;
	/// The ID of the Order that replaced this Order (only provided if this Order was cancelled as part of a cancel/replace).
	@optional OrderID replacedByOrderID;
}

/**
 * A StopLossOrder is an order that is linked to an open Trade and created with a price threshold.
 * The Order will be filled (closing the Trade) by the first price that is equal to or worse than the threshold.
 * A StopLossOrder cannot be used to open a new Position.
 */
struct StopLossOrder
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
	/// ID of the Transaction that filled this Order (only provided when the Order’s state is FILLED)
	@optional TransactionID fillingTransactionID;
	/// Date/time when the Order was filled (only provided when the Order’s state is FILLED)
	@optional SysTime filledTime;
	/// ID of the Transaction that cancelled the Order (only provided when the Order’s state is CANCELLED)
	@optional TransactionID cancellingTransactionID;
	/// Date/time when the Order was cancelled (only provided when the state of the Order is CANCELLED)
	@optional SysTime cancelledTime;
	/// The ID of the Order that was replaced by this Order (only provided if this Order was created as part of a cancel/replace).
	@optional OrderID replacesOrderID;
	/// The ID of the Order that replaced this Order (only provided if this Order was cancelled as part of a cancel/replace).
	@optional OrderID replacedByOrderID;
}

/**
 * A TrailingStopLossOrder is an order that is linked to an open Trade and created with a price distance.
 * The price distance is used to calculate a trailing stop value for the order that is in the losing direction
 * from the market price at the time of the order’s creation. The trailing stop value will follow the market price
 * as it moves in the winning direction, and the order will filled (closing the Trade) by the first price that
 * is equal to or worse than the trailing stop value. A TrailingStopLossOrder cannot be used to open a new Position.
 */
struct TrailingStopLossOrder
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
	/**
	 * The current trailing stop value for the Trailing Stop Loss Order.
	 * The trailingStopValue at the time of the Order’s creation is created by combining the Order’s
	 * distance with its initialTriggerComparePrice.
	 */
	PriceValue trailingStopValue;
	/// ID of the Transaction that filled this Order (only provided when the Order’s state is FILLED)
	@optional TransactionID fillingTransactionID;
	/// Date/time when the Order was filled (only provided when the Order’s state is FILLED)
	@optional SysTime filledTime;
	/// ID of the Transaction that cancelled the Order (only provided when the Order’s state is CANCELLED)
	@optional TransactionID cancellingTransactionID;
	/// Date/time when the Order was cancelled (only provided when the state of the Order is CANCELLED)
	@optional SysTime cancelledTime;
	/// The ID of the Order that was replaced by this Order (only provided if this Order was created as part of a cancel/replace).
	@optional OrderID replacesOrderID;
	/// The ID of the Order that replaced this Order (only provided if this Order was cancelled as part of a cancel/replace).
	@optional OrderID replacedByOrderID;	
}

/// The dynamic state of an Order. This is only relevant to TrailingStopLoss Orders, as no other Order type has dynamic state.
struct DynamicOrderState
{
	/// The Order’s ID.
	OrderID id;
	/// The Order’s calculated trailing stop value.
	PriceValue trailingStopValue;
	/**
	 * The distance between the Trailing Stop Loss Order’s trailingStopValue and the current Market Price.
	 * This represents the distance (in price units) of the Order from a triggering price.
	 * If the distance could not be determined, this value will not be set.
	 */
	PriceValue triggerDistance;
	/**
	 * True if an exact trigger distance could be calculated. If false, it means the provided trigger
	 * distance is a best estimate. If the distance could not be determined, this value will not be set.
	 */
	bool isTriggerDistanceExact;
}

/// The type of the Order.
enum OrderType
{
	/// A Market Order
	market,
	/// A Limit Order
	limit,
	/// A Stop Order
	stop,
	/// A Market-if-touched Order
	marketIfTouched,
	/// A Take Profit Order
	takeProfit,
	/// A Stop Loss Order
	stopLoss,
	/// A Trailing Stop Loss Order
	trailingStopLoss
}

/// The current state of the Order.
enum OrderState
{
	/// The Order is currently pending execution
	pending,
	/// The Order has been filled
	filled,
	/// The Order has been triggered
	triggered,
	/// The Order has been cancelled
	cancelled
}

/**
 * The time-in-force of an Order. TimeInForce describes how long an Order should remain pending before being
 * automatically cancelled by the execution system.
 */
enum TimeInForce
{
	gtc, /// The Order is “Good unTil Cancelled
	gtd, /// The Order is “Good unTil Date” and will be cancelled at the provided time
	gfd, /// The Order is “Good For Day” and will be cancelled at 5pm New York time
	fok, /// The Order must be immediately “Filled Or Killed”
	ioc  /// The Order must be “Immediatedly paritally filled Or Cancelled
}

/// Specification of how Positions in the Account are modified when the Order is filled.
enum OrderPositionFill
{
	/// When the Order is filled, only allow Positions to be opened or extended.
	openOnly,
	/// When the Order is filled, always fully reduce an existing Position before opening a new Position.
	reduceFirst,
	/// When the Order is filled, only reduce an existing Position.
	reduceOnly,
	/// When the Order is filled, use REDUCE_FIRST behaviour for non-client hedging Accounts, and OPEN_ONLY behaviour for client hedging Accounts.
	default_
}

/**
 * A TrailingStopLossState object represents the current state of a pending TrailingStopLossOrder.
 * It is a subset of the full TrailingStopLossOrder object, and is used by clients wanting to poll the current
 * dynamic state of their TrailingStopLossOrders (as opposed to the static, unchanging state found in the full represents).
 */
struct TrailingStopLossState
{
	/// The Identifier of the TrailingStopLossOrder
	OrderID id;
	/// The current trailing stop value for the TrailingStopLossOrder
	PriceValue trailingStopValue;
}

/// An OrderIdentifier is used to refer to an Order, and contains both the OrderID and the ClientOrderID.
struct OrderIdentifier
{
	/// The OANDA-assigned Order ID
	OrderID orderID;
	/// The client-provided client Order ID
	ClientID clientOrderID;
}
