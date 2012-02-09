# Heroku buildpack: Lua

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack)
for Lua apps.

It comes bundled with [Lua 5.1][1] and [LuaRocks 2.0.7.1][2].

Read a tutorial at <http://leafo.net/posts/lua_on_heroku.html>.

## Usage

Create an app with the buildpack:

    $ heroku create --stack cedar --buildpack http://github.com/leafo/heroku-buildpack-lua.git

### Dependencies

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

As shown above, if you want to include external rockspec or rock files by URL
you can place them in the dependencies table. (This is not supported by
LuaRocks, only by this buildpack).

This file must exist, even if you have no dependencies. The rockspec is parsed
in [prepare.moon][3].

The buildpack installs the dependencies to `packages/` and Lua to `bin/lua`.

The `bin/` directory is added to the `PATH` on initial install so you can run
Lua directly.

Additionally, `LUA_PATH` and `LUA_CPATH` environment variables are set to point
to where the dependencies are installed so you can `require` them with no extra
work.

## Example App

Use [Xavante][5] for a quick web server:

    -- web.lua
    require "xavante"

    port = ...

    xavante.HTTP {
      server = { host = "*", port = tonumber(port) },
      defaultHost = {
        rules = {
          {
            match = ".",
            with = function(req, res)
              res.headers["Content-type"] = "text/html"
              res.content = "hello world, the time is: " .. os.date()
              return res
            end
          }
        }
      }
    }

    xavante.run()

Tell Heroku to spawn your web server by creating a file called `Procfile`:

    web:     lua web.lua $PORT

After pushing, if the web server doesn't start automatically, tell Heroku to
start it:

    $ heroku scale web=1


## Note

If you were using the first incarnation of this buildpack the paths were not
set automatically. In order to upgrade your app use `heroku config` to
manually set the config vars described in the [release script][6].

 [1]: http://www.lua.org
 [2]: http://luarocks.org/
 [3]: https://github.com/leafo/heroku-buildpack-lua/blob/master/opt/prepare.moon
 [4]: http://luarocks.org/en/Rockspec_format
 [5]: http://keplerproject.github.com/xavante/
 [6]: https://github.com/leafo/heroku-buildpack-lua/blob/master/bin/release

