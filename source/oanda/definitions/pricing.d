module oanda.definitions.pricing;

import oanda.definitions.primitives;
import vibe.data.serialization;

/// The specification of an Account-specific Price.
struct Price
{
	/// The Price’s Instrument.
	InstrumentName instrument;
	/// The date/time when the Price was created
	SysTime time;
	/// The status of the Price.
	@byName PriceStatus status;
	/// The list of prices and liquidity available on the Instrument’s bid side. It is possible for this list to be empty if there is no bid liquidity currently available for the Instrument in the Account.
	PriceBucket[] bids;
	/// The list of prices and liquidity available on the Instrument’s ask side. It is possible for this list to be empty if there is no ask liquidity currently available for the Instrument in the Account.
	PriceBucket[] asks;
	/// The closeout bid Price. This Price is used when a bid is required to closeout a Position (margin closeout or manual) yet there is no bid liquidity. The closeout bid is never used to open a new position.
	PriceValue closeoutBid;
	/// The closeout ask Price. This Price is used when a ask is required to closeout a Position (margin closeout or manual) yet there is no ask liquidity. The closeout ask is never used to open a new position.
	PriceValue closeoutAsk;
	/// The factors used to convert quantities of this price’s Instrument’s quote currency into a quantity of the Account’s home currency.
	QuoteHomeConversionFactors quoteHomeConversionFactors;
	/// Representation of many units of an Instrument are available to be traded for both long and short Orders.
	UnitsAvailableDetails unitsAvailable;
}

/**
 * The string representation of a Price for an Instrument.
 * 
 * A decimal number encodes as a string. The amount of precision provided depends on the Price’s Instrument.
 */
alias string PriceValue;

/// Price Bucket
struct PriceBucket
{
	/// The Price offered by the PriceBucket
	PriceValue price;
	/// The amount of liquidity offered by the PriceBucket
	int liquidity;
}

/// The status of the Price.
enum PriceStatus
{
	/// The Instrument’s price is tradeable.
	tradeable,
	/// The Instrument’s price is not tradeable.
	nonTradeable,
	/// The Instrument of the price is invalid or there is no valid Price for the Instrument.)
	invalid
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

/// Representation of many units of an Instrument are available to be traded for both long and short Orders.
struct UnitsAvailable
{
	/// The units available breakdown for long Orders.
	@name("long") DecimalNumber long_;
	/// The units available breakdown for short Orders.
	@name("short") DecimalNumber short_;
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
