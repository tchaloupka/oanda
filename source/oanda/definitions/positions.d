module oanda.definitions.positions;

import oanda.definitions.primitives;
import oanda.definitions.account : AccountUnits;
import oanda.definitions.pricing : PriceValue;
import oanda.definitions.trades : TradeID;

import vibe.data.serialization;

/// The specification of a Position within an Account.
struct Position
{
	/// The Position’s Instrument.
	InstrumentName instrument;
	/// Profit/loss realized by the Position over the lifetime of the Account.
	AccountUnits pl;
	/// The unrealized profit/loss of all open Trades that contribute to this Position.
	AccountUnits unrealizedPL;
	/// Profit/loss realized by the Position since the Account’s resettablePL was last reset by the client.
	AccountUnits resettablePL;
	/// The details of the long side of the Position.
	@name("long") PositionSide long_;
	/// The details of the short side of the Position.
	@name("short") PositionSide short_;
}

/// The representation of a Position for a single direction (long or short).
struct PositionSide
{
	/// Number of units in the position (negative value indicates short position, positive indicates long position).
	DecimalNumber units;
	/// Volume-weighted average of the underlying Trade open prices for the Position.
	PriceValue averagePrice;
	/// List of the open Trade IDs which contribute to the open Position.
	TradeID[] tradeIDs;
	/// Profit/loss realized by the PositionSide over the lifetime of the Account.
	AccountUnits pl;
	/// The unrealized profit/loss of all open Trades that contribute to this PositionSide.
	AccountUnits unrealizedPL;
	/// Profit/loss realized by the PositionSide since the Account’s resettablePL was last reset by the client.
	AccountUnits resettablePL;
}

/// The dynamic (calculated) state of a Position
struct CalculatedPositionState
{
	/// The Position’s Instrument.
	InstrumentName instrument;
	/// The Position’s net unrealized profit/loss
	AccountUnits netUnrealizedPL;
	/// The unrealized profit/loss of the Position’s long open Trades
	AccountUnits longUnrealizedPL;
	/// The unrealized profit/loss of the Position’s short open Trades
	AccountUnits shortUnrealizedPL;
}
