local ls = require("luasnip")

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local e = require("luasnip.extras")
local line_begin = require("luasnip.extras.conditions.expand").line_begin


-- Returns a snippet_node wrapped around an insert_node whose initial
-- text value is set to the current date in the desired format.
local year_input = function(args, state)
  return sn(nil, i(1, os.date("%Y")))
end

local nsp_pattern = {t("namespace "), i(1), t({"", "{", ""}), i(0), t({"", "}  // namespace "}), e.rep(1)}

-- Note: the condition stuff doesn't work.
ls.add_snippets("cpp", {
  s({trig = "isc", condition = line_begin}, {
    t({"/*", ""}),
    t( " * Copyright (c) "), d(1, year_input, {}), t(" "), i(2,"NODE Robotics GmbH"), t({"",""}), -- A newline
    t({" *",
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
    ""}),
  }),
  s({trig = "copyright", condition = line_begin}, {
    t({"/*", ""}),
    t( " * Copyright (c) "), d(1, year_input, {}), t(" "), i(2, "NODE Robotics GmbH"),
    t({"",
    " * All rights reserved.",
    " * Unauthorized copying of this file, via any medium is strictly prohibited.",
    " * Proprietary and confidential.",
    " */",
    "",
    ""}),
  }),
  s({trig = "nsp", condition = line_begin}, nsp_pattern)
})

ls.add_snippets("python", {
  s({trig = "isc", condition = line_begin}, {
    t( "# Copyright (c) "), d(1, year_input, {}), t(" "), i(2,"NODE Robotics GmbH"), t({"",""}), -- A newline
    t({"#",
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
    ""}),
  }, {condition = line_begin}),
  s({trig = "copyright", condition = line_begin}, {
    t("# Copyright (c) "), d(1, year_input, {}), t(" "), i(2, "NODE Robotics GmbH"), t({"",
    "# All rights reserved.",
    "# Unauthorized copying of this file, via any medium is strictly prohibited.",
    "# Proprietary and confidential.",
    "",
    ""}),
  }, {condition = line_begin})
})

ls.add_snippets("xml", {
  s("fez", {t("felix.zeltner@node-robotics.com")}),
  s("dep", {t("<depend>"), i(1, "pkg"), t("</depend>")}),
  s("bdep", {t("<build_depend>"), i(1, "pkg"), t("</build_depend>")}),
})

ls.add_snippets("org", {
  s("src", {t({"#+begin_src "}), i(1, "<lang>"), t({"", ""}), i(2, "<code>"), t({"","#+end_src", ""})}),
  s("exp", {t({"#+begin_example", ""}), i(1, "<example>"), t({"","#+end_example", ""})})
})

ls.add_snippets("cmake", {
  s({trig = "fp", condition = line_begin}, {t("find_package("), i(1, "<package>"), t({" REQUIRED)", ""})}),
  s({trig = "naw", name = "ncm_add_warnings", descr = "Add ncm_add_warnings call", condition = line_begin},
    {t("ncm_add_default_warnings_and_sanitizers(TARGETS "), i(1, "${PROJECT_NAME}"), t({")", ""})}),
  s({trig="catkin_package", condition = line_begin}, 
    {t({"catkin_package(", "  INCLUDE_DIRS ", "    "}), i(1, "include"), t({"", "  LIBRARIES ", "    "}), i(2, "${PROJECT_NAME}"), t({"", "  CATKIN_DEPENDS", "    "}), i(3, "${dependencies}"), t({"", ")", ""})}),
  s({trig = "adt", condition = line_begin}, {t("ament_target_dependencies("), i(1, "${PROJECT_NAME}"), t(" "), i(2, "${dependencies}"), t(" "), i(3, "${${PROJECT_NAME}_EXPORTED_TARGETS}"), t({")", ""}) }),
  s({trig = "aae", condition = line_begin}, {
    t("add_executable("), i(1, "${name}"), t(" "), e.rep(1),  t(".cpp"), t({")", ""}),
    t("ament_target_dependencies("), e.rep(1), t(" "),  i(2, "${dependencies}"), t({")", ""}),
    t("target_link_libraries("), e.rep(1), t(" "), i(3, "${PROJECT_NAME}"), t({")", ""})
  }),
})
