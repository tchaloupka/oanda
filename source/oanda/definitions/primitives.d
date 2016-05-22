module oanda.definitions.primitives;

import vibe.data.serialization;

/**
 * The string representation of a decimal number
 * A decimal number encoded as a string. The amount of precision provided depends on what the number represents.
 */
alias string DecimalNumber;

/**
 * Currency name identifier. Used by clients to refer to currencies.
 * A string containing an ISO 4217 currency (http://en.wikipedia.org/wiki/ISO_4217)
 */
alias string Currency;

/**
 * Instrument name identifier. Used by clients to refer to an Instrument.
 * A string containing the base currency and quote currency delimited by a “_”.
 */
alias string InstrumentName;

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

/// Full specification of an Instrument.
struct Instrument
{
	/// The name of the Instrument
	InstrumentName name;
	/// The type of the Instrument
	@byName InstrumentType type;
	/// The display name of the Instrument
	string displayName;
	/**
	 * The location of the “pip” for this instrument.
	 * The decimal position of the pip in this Instrument’s price can be found at 10 ^ pipLocation
	 * (e.g. -4 pipLocation results in a decimal pip position of 10 ^ -4 = 0.0001).
	 */
	int pipLocation;
	/**
	 * The number of decimal places that should be used to display prices for this instrument.
	 * (e.g. a displayPrecision of 5 would result in a price of “1” being displayed as “1.00000”)
	 */
	int displayPrecision;
	/// The amount of decimal places that may be provided when specifying the number of units traded for this instrument.
	int tradeUnitsPrecision;
	/// The smallest number of units allowed to be traded for this instrument.
	DecimalNumber minimumTradeSize;
	/// The maximum trailing stop distance allowed for a trailing stop loss created for this instrument. Specified in price units.
	DecimalNumber maximumTrailingStopDistance;
	/// The minimum trailing stop distance allowed for a trailing stop loss created for this instrument. Specified in price units.
	DecimalNumber minimumTrailingStopDistance;
	/// The maximum position size allowed for this instrument. Specified in units.
	DecimalNumber maximumPositionSize;
	/// The maximum units allowed for an Order placed for this instrument. Specified in units.
	DecimalNumber maximumOrderUnits;
	/// The margin rate for this instrument.
	DecimalNumber marginRate;
}

alias string SysTime; // TODO: Use SysTime from std.datetime - https://issues.dlang.org/show_bug.cgi?id=16053
