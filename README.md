# Heroku buildpack: Lua

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack)
for Lua apps.

It comes bundled with [Lua 5.1][1] and [LuaRocks 2.0.7.1][2].

Read a tutorial at <http://leafo.net/posts/lua_on_heroku.html>.

## Usage

Create an app with the buildpack:

    $ heroku create --stack cedar --buildpack http://github.com/leafo/heroku-buildpack-lua.git

## Describing Dependencies

In order to describe the dependencies of you application you must create a
[rockspec][4] for it.

The first file found that matches `*.rockpsec` in the root directory will be
used. Don't put multiple ones in the root directory otherwise it might get
confused.

The buildpack *only* looks at the dependency information. Meaning you don't
have to follow the entire rockspec specification. Minimally, your rockspec
could look something like this:

	-- my_app.rockspec
	dependencies = {
		"xavante >= 2.2.1",
		"http://moonscript.org/rocks/moonscript-dev-1.src.rock",
		"cosmo"
	}

This file must exist, even if you have no dependencies. The rockspec is parsed
in [prepare.moon][3].

As shown above, if you want to include rockspec or rock files by url you can
place them in the dependencies table. (This is not supported by LuaRocks, only
by this buildpack).

## Using Dependencies

The buildpack installs the dependencies to `packages/` and Lua is installed to
`bin/lua`.

Before you can require any of your dependencies, you must update your
`package.path` by requiring `packages.init`.

	-- web.lua
	require "packages.init"
	require "xavante"

	xavante.HTTP {
		...
	}

	xavante.run()

If you're running testing locally as well, and `package.init` doesn't exist, do
something like this:

    pcall(require, "packages.init")

## Running a Process

To spawn your server create a `Procfile` similar to:

    web:     bin/lua web.lua $PORT

Where `web.lua` is the entry point to your Lua application.

 [1]: http://www.lua.org
 [2]: http://luarocks.org/
 [3]: https://github.com/leafo/heroku-buildpack-lua/blob/master/opt/prepare.moon
 [4]: http://luarocks.org/en/Rockspec_format

