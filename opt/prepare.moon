
rockspec_path, opt_dir = ...

strip = (str) -> str\match "^%s*(.-)%s*$"

read_cmd = (cmd) ->
  f = io.popen cmd, "r"
  with strip f\read"*a"
    f\close!

-- where packages are installed
tree = read_cmd("dirname " .. rockspec_path) .. "/packages"
tree = read_cmd "cd " .. tree .. " && pwd"

-- keep error messages simple
error = (msg) ->
  print msg
  os.exit 1

error "Missing opt_dir" if not opt_dir
error "Missing rockspec_path" if not rockspec_path

fn = loadfile rockspec_path
error "Failed to open rockspec:", rockspec_path if not fn

rockspec = {
  name: "anonymous_app"
  dependencies: {}
}
setfenv(fn, rockspec)!

path = require"luarocks.path"
deps = require"luarocks.deps"
install = require"luarocks.install"

extras = {}
rockspec.dependencies = for dep in *rockspec.dependencies
  parsed = deps.parse_dep dep
  if not parsed
    table.insert extras, dep
  parsed

path.use_tree tree
success, msg = deps.fulfill_dependencies rockspec
error msg if not success

import p from require "moon"

for extra in *extras
  install.run extra
