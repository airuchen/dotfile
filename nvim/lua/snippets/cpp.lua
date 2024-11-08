local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local e = require("luasnip.extras")
local line_begin = require("luasnip.extras.conditions.expand").line_begin

local year_input = require("snippets.utils").year_input

local nsp_pattern = { t("namespace "), i(1), t({ "", "{", "" }), i(0), t({ "", "}  // namespace " }), e.rep(1) }

-- Note: the condition stuff doesn't work.
ls.add_snippets("cpp", {
  s({ trig = "isc", condition = line_begin }, {
    t({ "/*", "" }),
    t(" * Copyright (c) "), d(1, year_input, {}), t(" "), i(2, "NODE Robotics GmbH"), t({ "", "" }), -- A newline
    t({ " *",
      " * Permission to use, copy, modify, and distribute this software for any",
      " * purpose with or without fee is hereby granted, provided that the above",
      " * copyright notice and this permission notice appear in all copies.",
      " *",
      " * THE SOFTWARE IS PROVIDED \"AS IS\" AND THE AUTHOR DISCLAIMS ALL WARRANTIES",
      " * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF",
      " * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR",
      " * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES",
      " * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN",
      " * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF",
      " * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.",
      " */",
      "",
      "" }),
  }),
  s({ trig = "copyright", condition = line_begin }, {
    t({ "/*", "" }),
    t(" * Copyright (c) "), d(1, year_input, {}), t(" "), i(2, "NODE Robotics GmbH"),
    t({ "",
      " * All rights reserved.",
      " * Unauthorized copying of this file, via any medium is strictly prohibited.",
      " * Proprietary and confidential.",
      " */",
      "",
      "" }),
  }),
  s({ trig = "nsp", condition = line_begin }, nsp_pattern),
  s({ trig = "fm"}, { t("fmt::format(FMT_COMPILE(\""), i(1), t("\"), "), i(2), t(")") }),
  s({ trig = "sfmt", condition = line_begin }, {
    t({ "template <>", "struct fmt::formatter<" }), i(1), t({ "> : fmt::formatter<std::string_view> {",
    "  // format parsing is inherited", "  auto format(" }),
    e.rep(1), t(" const& "), i(2, "t"), t(", format_context& ctx) const -> format_context::iterator {"),
    t({ "", "    " }),
    i(3),
    t({ "", "  }", "};" })
  }),
})
