
package_fname, opt_dir = ...

import concat from table

error "missing package file" if not package_fname
error "missing opt dir" if not opt_dir

fn = loadfile package_fname
if not fn
	print "Failed to open package file:", package_fname
	os.exit 1

strip = (str) -> str\match "^%s*(.-)%s*$"

read_cmd = (cmd) ->
  f = io.popen cmd, "r"
  with strip f\read"*a"
    f\close!

-- where packages are installed
tree = read_cmd("dirname " .. package_fname) .. "/packages"

lua_bin = opt_dir .. "/lua"
lua_bin = "lua" if os.getenv("ENV") == "local"

luarocks_dir = opt_dir .. "/luarocks"

lua_path = concat {
  luarocks_dir .. "/?.lua"
}, ";"

install = (pkg_name) ->
  cmd = concat {
    "LUA_PATH='", lua_path, ";;' "
    lua_bin, " ", opt_dir, "/luarocks/bin/luarocks"
    " --tree=", tree
    " install ", pkg_name
  }
  os.execute cmd

actions = {
  depends: (tbl) ->
    install dep for dep in *tbl
}

setfenv fn, setmetatable {}, {
  __index: (name) =>
    orig = _G[name]
    return orig if orig != nil
    actions[name] or ->
}

os.execute "mkdir -p " .. tree
fn!
