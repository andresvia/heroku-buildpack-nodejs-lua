local package_fname, opt_dir = ...
local concat = table.concat
if not package_fname then
  error("missing package file")
end
if not opt_dir then
  error("missing opt dir")
end
local fn = loadfile(package_fname)
if not fn then
  print("Failed to open package file:", package_fname)
  os.exit(1)
end
local strip
strip = function(str)
  return str:match("^%s*(.-)%s*$")
end
local read_cmd
read_cmd = function(cmd)
  local f = io.popen(cmd, "r")
  do
    local _with_0 = strip(f:read("*a"))
    f:close()
    return _with_0
  end
end
local tree = read_cmd("dirname " .. package_fname) .. "/packages"
local lua_bin = opt_dir .. "/lua"
if os.getenv("ENV") == "local" then
  lua_bin = "lua"
end
local luarocks_dir = opt_dir .. "/luarocks"
local lua_path = concat({
  luarocks_dir .. "/?.lua"
}, ";")
local install
install = function(pkg_name)
  local cmd = concat({
    "LUA_PATH='",
    lua_path,
    ";;' ",
    lua_bin,
    " ",
    opt_dir,
    "/luarocks/bin/luarocks",
    " --tree=",
    tree,
    " install ",
    pkg_name
  })
  return os.execute(cmd)
end
local actions = {
  depends = function(tbl)
    return (function()
      local _accum_0 = { }
      local _len_0 = 0
      local _list_0 = tbl
      for _index_0 = 1, #_list_0 do
        local dep = _list_0[_index_0]
        _len_0 = _len_0 + 1
        _accum_0[_len_0] = install(dep)
      end
      return _accum_0
    end)()
  end
}
setfenv(fn, setmetatable({ }, {
  __index = function(self, name)
    local orig = _G[name]
    if orig ~= nil then
      return orig
    end
    return actions[name] or function() end
  end
}))
os.execute("mkdir -p " .. tree)
fn()
