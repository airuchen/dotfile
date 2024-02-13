local ls = require("luasnip")
local year_input = require("snippets.utils").year_input

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local line_begin = require("luasnip.extras.conditions.expand").line_begin

ls.add_snippets("python", {
  s({ trig = "isc", condition = line_begin }, {
    t("# Copyright (c) "), d(1, year_input, {}), t(" "), i(2, "NODE Robotics GmbH"), t({ "", "" }), -- A newline
    t({ "#",
      "# Permission to use, copy, modify, and distribute this software for any",
      "# purpose with or without fee is hereby granted, provided that the above",
      "# copyright notice and this permission notice appear in all copies.",
      "#",
      "# THE SOFTWARE IS PROVIDED \"AS IS\" AND THE AUTHOR DISCLAIMS ALL WARRANTIES",
      "# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF",
      "# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR",
      "# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES",
      "# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN",
      "# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF",
      "# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.",
      "",
      "" }),
  }),
  s({ trig = "copyright", condition = line_begin }, {
    t("# Copyright (c) "), d(1, year_input, {}), t(" "), i(2, "NODE Robotics GmbH"), t({ "",
    "# All rights reserved.",
    "# Unauthorized copying of this file, via any medium is strictly prohibited.",
    "# Proprietary and confidential.",
    "",
    "" }),
  }),
})
