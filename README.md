Heroku buildpack: Lua
=====================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for Lua apps.

It comes bundled with [Lua 5.1][1] and [LuaRocks 2.0.7.1][2].

Read a tutorial at <http://leafo.net/posts/lua_on_heroku.html>.

Usage
-----

Example usage:

    $ heroku create --stack cedar --buildpack http://github.com/leafo/heroku-buildpack-lua.git


Declare your dependencies in `package.lua`

	-- package.lua
	depends {
		"xavante"
	}

Dependencies are installed to `packages/` and Lua is installed to `bin/lua`.

Set your package path correctly by requiring `packages.init` before requiring
dependences.


	-- web.lua
	require "packages.init"
	require "xavante"

	xavante.HTTP {
		...
	}

	xavante.run()


 [1]: http://www.lua.org
 [2]: http://luarocks.org/

