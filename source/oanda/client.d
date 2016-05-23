module oanda.client;

debug import std.stdio;
import std.typecons;
import std.range;
import vibe.http.client;
import vibe.data.json;
import vibe.data.serialization;

import oanda.definitions;

/// Environment the client comunicate with
enum Environment
{
	/// Practice account
	fxpractice,
	/// Trade account
	fxtrade
}

struct OandaClient
{
	this(Environment env, string accessToken)
	{
		_auth = "Bearer " ~ accessToken;

		if (env == Environment.fxpractice)
		{
			_apiUrl = "https://api-fxpractice.oanda.com";
			_streamUrl = "https://stream-fxpractice.oanda.com";
		}
		else
		{
			_apiUrl = "https://api-fxtrade.oanda.com";
			_streamUrl = "https://stream-fxtrade.oanda.com";
		}
	}

package:
	auto requestJson(T)(T path, scope void delegate(scope HTTPClientRequest) requester = cast(void delegate(scope HTTPClientRequest req))null) const
	{
		import std.algorithm : joiner;
		import std.conv : text;

		Json data;
		int status;

		static if (is(T == string))
		{
			string url = joiner([_apiUrl, path]).text;
		}
		else static if (isInputRange!T && isInputRange!(ElementType!T))
		{
			string url = joiner(chain([_apiUrl], path)).text;
		}

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

private:
	immutable string _auth;
	immutable string _apiUrl;
	immutable string _streamUrl;
}
