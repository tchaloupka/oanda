module oanda.definitions.trades;

import oanda.definitions.primitives;
import oanda.definitions.pricing : PriceValue;
import oanda.definitions.account : AccountUnits;
import oanda.definitions.orders : OrderID;
import oanda.definitions.transactions : ClientExtensions, TransactionID;

/**
 * The Trade’s identifier, unique within the Trade’s Account.
 * 
 * The string representation of the OANDA-assigned TradeID.
 * OANDA-assigned TradeIDs are positive integers, and are derived from the TransactionID of the Transaction that opened the Trade.
 */
alias string TradeID;

/**
 * The specification of a Trade as referred to by clients
 * 
 * Either the Trade’s OANDA-assigned TradeID or the Trade’s client-provided ClientID prefixed by he “@” symbol
 */
alias string TradeSpecifier;

struct Trade
{
	//TODO
}

/// The summary of a Trade within an Account. This representation does not provide the full details of the Trade’s dependent Orders.
struct TradeSummary
{
	/// The Trade’s identifier, unique within the Trade’s Account.
	TradeID id;
	/// The Trade’s Instrument.
	InstrumentName instrument;
	/// The execution price of the Trade.
	PriceValue price;
	/// The date/time when the Trade was opened.
	SysTime openTime;
	/// The current state of the Trade.
	TradeState state;
	/// The initial size of the Trade. Negative values indicate a short Trade, and positive values indicate a long Trade.
	DecimalNumber initialUnits;
	/// The number of units currently open for the Trade. This value is reduced to 0.0 as the Trade is closed.
	DecimalNumber currentUnits;
	/// The total profit/loss realized on the closed portion of the Trade.
	AccountUnits realizedPL;
	/// The unrealized profit/loss on the open portion of the Trade.
	AccountUnits unrealizedPL;
	/// The IDs of the Transactions that have closed portions of this Trade.
	TransactionID[] closingTransactionIDs;
	/// The financing paid/collected for this Trade.
	AccountUnits financing;
	/// The date/time when the Trade was fully closed. Only provided for Trades whose state is CLOSED.
	SysTime closeTime;
	/// The client extensions of the Trade.
	ClientExtensions clientExtensions;
	/// ID of the Trade’s Take Profit Order, only provided if such an Order exists.
	OrderID takeProfitOrderID;
	/// ID of the Trade’s Stop Loss Order, only provided if such an Order exists.
	OrderID stopLossOrderID;
	/// ID of the Trade’s Trailing Stop Loss Order, only provided if such an Order exists.
	OrderID trailingStopLossOrderID;
}

/// The dynamic (calculated) state of an open Trade
struct CalculatedTradeState
{
	/// The Trade’s ID.
	TradeID id;
	/// The Trade’s unrealized profit/loss.
	AccountUnits unrealizedPL;
}

/// The current state of the Trade.
enum TradeState
{
	/// The Trade is currently open
	open,
	/// The Trade has been fully closed
	closed
}
