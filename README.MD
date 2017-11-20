# Pick Your Pic
### An application created for skills-demonstration for possible employer
___

## introduction

This application is a simple feed of photographs, grabbed from API of the one popular web-service. If one whants to deploy and try this app, he (or she) needs to get credentials from "Unsplash" for dev. access.

## Installation

Everything you need is `node.js`, `npm`, globally installed `gulp` and `bower`. To install all dependencies, you need to fire a very famous commands:

```bash
$ npm install
```
```bash
$ bower install
```

## Configuring

Inside a root (`/`) directory you can find a sample of configurations [`build.config.sample.json`](./build.config.sample.json) with following content:

```json
{
	"API": {
		"id": "",
		"secret": ""
	},
	"LS": {
		"cache": true,
		"term": 3e+5
	}
}
```

### Clarification

| Property object| Content                        | Description  |
| -------------  |:-------------:|-----------------------------------------------------------------:|
| **API** *API settings*   * **REQUIRED**    | **id**        | `string` Id of the "[Unsplash](https://unsplash.com/developers)" API user |
|                | **secret**    | `string` API user's secret key                                            |
| **LS** *LocalStorage cache settings*     | **cache**        | `boolean` Results of requests to API endpoints are caching to the LocalStorage if this flag is `true` |
|                | **term**    | `integer` Time of cache life in milliseconds (*5 minutes by default*) |

You need to save this file as `build.config.json`. Without this file, application building process is impossible.

Settings for LocalStorage Cache are needen in case of using `dev` mode of API service, because this kind of access to the API has a restricted number of allowed requests per hour.

## Deploy (*build*)

For **developing mode** just ran command:

```bush
gulp
```

For **production mode** (with minification and obfuscation, but without watchers):

```bush
gulp prod
```

That is it.

