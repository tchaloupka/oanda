module oanda.definitions.common;

/// Policy to UPPERCASE enum names conversion
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