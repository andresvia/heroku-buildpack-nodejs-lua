# Heroku Buildpack for Node.js

![heroku-buildpack-featuerd](https://cloud.githubusercontent.com/assets/51578/6953435/52e1af5c-d897-11e4-8712-35fbd4d471b1.png)

This is the official [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks) for Node.js apps. If you fork this repository, please **update this README** to explain what your fork does and why it's special.


## How it Works

Apps are built via one of four paths:

1. A regular `npm install` (first build; default scenario)
2. Copy existing `node_modules` from cache, then `npm prune`, then `npm install` (subsequent builds)
3. Skip dependencies (if package.json doesn't exist but server.js does)
4. Skip cache, run `npm rebuild` before `npm install` (`node_modules` are checked into source control)

You should only use #3 (omitting package.json) for quick tests or experiments.

You should never use #4 - it's included for backwards-compatibility and will generate warnings.
**Checking in `node_modules` is an antipattern.**
For more information, see [the npm docs](https://docs.npmjs.com/misc/faq#should-i-check-my-node_modules-folder-into-git-)

For technical details, check out the [heavily-commented compile script](https://github.com/heroku/heroku-buildpack-nodejs/blob/master/bin/compile).

## Documentation

For more information about using Node.js and buildpacks on Heroku, see these Dev Center articles:

- [Heroku Node.js Support](https://devcenter.heroku.com/articles/nodejs-support)
- [Getting Started with Node.js on Heroku](https://devcenter.heroku.com/articles/nodejs)
- [10 Habits of a Happy Node Hacker](https://blog.heroku.com/archives/2014/3/11/node-habits)
- [Buildpacks](https://devcenter.heroku.com/articles/buildpacks)
- [Buildpack API](https://devcenter.heroku.com/articles/buildpack-api)


## Legacy Compatibility

For most Node.js apps this buildpack should work just fine.
If, however, you're unable to deploy using this new version of the buildpack, you can get your app working again by locking it to the previous version:

```
heroku buildpack:set BUILDPACK_URL=https://github.com/heroku/heroku-buildpack-nodejs#v63 -a my-app
git commit -am "empty" --allow-empty
git push heroku master
```

Then please open a support ticket at [help.heroku.com](https://help.heroku.com/) so we can diagnose and get your app running on the default buildpack.

## Options

### Specify a node version

Set engines.node in package.json to the semver range
(or specific version) of node you'd like to use.
(It's a good idea to make this the same version you use during development)

```json
"engines": {
  "node": "0.11.x"
}
```

```json
"engines": {
  "node": "0.10.33"
}
```

Default: the
[latest stable version.](http://semver.io/node)

### Specify an npm version

Set engines.npm in package.json to the semver range
(or specific version) of npm you'd like to use.
(It's a good idea to make this the same version you use during development)

Since 'npm 2' shipped several major bugfixes, you might try:

```json
"engines": {
  "npm": "2.x"
}
```

```json
"engines": {
  "npm": "^2.1.0"
}
```

Default: the version of npm bundled with your node install (varies).

### Enable or disable node_modules caching

For a 'clean' build without using any cached node modules:

```shell
heroku config:set NODE_MODULES_CACHE=false
git commit -am 'rebuild' --allow-empty
git push heroku master
heroku config:unset NODE_MODULES_CACHE
```

Caching node_modules between builds dramatically speeds up build times.
However, `npm install` doesn't automatically update already-installed modules
as long as they fall within acceptable semver ranges,
which can lead to outdated modules.

Default: `NODE_MODULES_CACHE` defaults to true

### Enable or disable devDependencies installation

During local development, `npm install` installs all dependencies
and all devDependencies (test frameworks, build tools, etc).
This is usually something you want to avoid in production, so
npm has a 'production' config that can be set through the environment:

To install *dependencies only:*

```shell
heroku config:set NPM_CONFIG_PRODUCTION=true
```

To install *dependencies and devDependencies:*

```shell
heroku config:set NPM_CONFIG_PRODUCTION=false
```

Default: `NPM_CONFIG_PRODUCTION` defaults to true on Heroku

### Configure npm with .npmrc

Sometimes, a project needs custom npm behavior to set up proxies,
use a different registry, etc. For such behavior,
just include an `.npmrc` file in the root of your project:

```
# .npmrc
registry = 'https://custom-registry.com/'
```

### Reasonable defaults for concurrency

This buildpack adds two environment variables: `WEB_MEMORY` and `WEB_CONCURRENCY`.
You can set either of them, but if unset the buildpack will fill them with reasonable defaults.

- `WEB_MEMORY`: expected memory use by each node process (in MB, default: 512)
- `WEB_CONCURRENCY`: recommended number of processes to Cluster based on the current environment

Clustering is not done automatically; concurrency should be part of the app,
usually via a library like [throng](https://github.com/hunterloftis/throng).
Apps without any clustering mechanism will remain unaffected by these variables.

This behavior allows your app to automatically take advantage of larger containers.
The default settings will cluster
1 process on a 1X dyno, 2 processes on a 2X dyno, and 12 processes on a PX dyno.

For example, when your app starts:

```
app[web.1]: Detected 1024 MB available memory, 512 MB limit per process (WEB_MEMORY)
app[web.1]: Recommending WEB_CONCURRENCY=2
app[web.1]:
app[web.1]: > example-concurrency@1.0.0 start /app
app[web.1]: > node server.js
app[web.1]: Listening on 51118
app[web.1]: Listening on 51118
```

Notice that on a 2X dyno, the
[example concurrency app](https://github.com/heroku-examples/node-concurrency)
listens on two processes concurrently.

### Chain Node with multiple buildpacks

This buildpack automatically exports node, npm, and any node_modules binaries
into the `$PATH` for easy use in subsequent buildpacks.

## Feedback

Having trouble? Dig it? Feature request?

- [help.heroku.com](https://help.heroku.com/)
- [@hunterloftis](http://twitter.com/hunterloftis)
- [github issues](https://github.com/heroku/heroku-buildpack-nodejs/issues)

## Hacking

To make changes to this buildpack, fork it on Github. Push up changes to your fork, then create a new Heroku app to test it, or configure an existing app to use your buildpack:

```
# Create a new Heroku app that uses your buildpack
heroku create --buildpack <your-github-url>

# Configure an existing Heroku app to use your buildpack
heroku buildpacks:set <your-github-url>

# You can also use a git branch!
heroku buildpacks:set <your-github-url>#your-branch
```

## Testing

The buildpack tests use [Docker](https://www.docker.com/) to simulate
Heroku's Cedar and Cedar-14 containers.

To run the test suite:

```
make test
```

Or to just test in cedar or cedar-14:

```
make test-cedar-10
make test-cedar-14
```

The tests are run via the vendored [shunit2](http://shunit2.googlecode.com/svn/trunk/source/2.1/doc/shunit2.html)
test framework.
# Heroku buildpack: Lua

This is a [Heroku buildpack](http://devcenter.heroku.com/articles/buildpack)
for Lua apps.

It comes bundled with [Lua 5.1][1] and [LuaRocks 2.2.0][2].

Read a tutorial at <http://leafo.net/posts/lua_on_heroku.html>.

## Usage

Create an app with the buildpack:

```bash
$ heroku create --buildpack http://github.com/leafo/heroku-buildpack-lua.git
```

### Dependencies

In order to describe the dependencies of you application you must create a
[rockspec][4] for it.

The first file found that matches `*.rockpsec` in the root directory will be
used. Don't put multiple ones in the root directory otherwise it might get
confused.

The buildpack *only* looks at the dependency information. Meaning you don't
have to follow the entire rockspec specification. Minimally, your rockspec
could look something like this:

```lua
-- my_app.rockspec
dependencies = {
  "xavante >= 2.2.1",
  "https://rocks.moonscript.org/manifests/leafo/moonscript-0.2.6-1.src.rock",
  "cosmo"
}
```

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

```lua
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

xavante.start()
```

Tell Heroku to spawn your web server by creating a file called `Procfile`:

    web:     lua web.lua $PORT

After pushing, if the web server doesn't start automatically, tell Heroku to
start it:

```bash
$ heroku scale web=1
```


 [1]: http://www.lua.org
 [2]: http://luarocks.org/
 [3]: https://github.com/leafo/heroku-buildpack-lua/blob/master/opt/prepare.moon
 [4]: http://luarocks.org/en/Rockspec_format
 [5]: http://keplerproject.github.com/xavante/

