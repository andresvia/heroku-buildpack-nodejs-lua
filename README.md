Heroku buildpack: Lua
=====================

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack) for Lua apps.

It comes bundled with Lua 5.1 and luarocks 2.0.7.1.

Usage
-----

Example usage:

    $ heroku create --stack cedar --buildpack http://github.com/leafo/heroku-buildpack-lua.git
