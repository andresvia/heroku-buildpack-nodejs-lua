Heroku buildpack: Lua
=====================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack)
for Lua apps.

It comes bundled with [Lua 5.1][1] and [LuaRocks 2.0.7.1][2].

Read a tutorial at <http://leafo.net/posts/lua_on_heroku.html>.

Usage
-----

Create an app with the buildpack:

    $ heroku create --stack cedar --buildpack http://github.com/leafo/heroku-buildpack-lua.git

You application must have a special file called `package.lua` to declare your
dependencies. For example:

	-- package.lua
	depends {
		"xavante",
		"cosmo"
	}

Each dependency listed is passed onto LuaRocks' `install` command. This means
you can also use urls to your own rockspecs.

This file must exist, even if you have no dependencies. It can be empty. The
execution of `package.lua` is done in [prepare.moon][3].

The buildpack installs dependencies to `packages/` and Lua is installed to
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

To spawn your server create a `Procfile` similar to:

    web:     bin/lua web.lua $PORT

Where `web.lua` is the entry point to your Lua application.

 [1]: http://www.lua.org
 [2]: http://luarocks.org/
 [3]: https://github.com/leafo/heroku-buildpack-lua/blob/master/opt/prepare.moon

