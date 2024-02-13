local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("org", {
  s("src", { t({ "#+begin_src " }), i(1, "<lang>"), t({ "", "" }), i(2, "<code>"), t({ "", "#+end_src", "" }) }),
  s("exp", { t({ "#+begin_example", "" }), i(1, "<example>"), t({ "", "#+end_example", "" }) })
})
