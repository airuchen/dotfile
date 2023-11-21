local ls = require("luasnip")
local sn = ls.snippet_node
local i = ls.insert_node

local M = {}

-- Returns a snippet_node wrapped around an insert_node whose initial
-- text value is set to the current date in the desired format.
M.year_input = function(args, state)
  return sn(nil, i(1, os.date("%Y")))
end

return M
