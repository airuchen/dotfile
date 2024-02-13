local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

ls.add_snippets("xml", {
  s("scheme",
    { t(
      [[<?xml-model href="http://download.ros.org/schema/package_format3.xsd" schematypens="http://www.w3.org/2001/XMLSchema"?>]]) }),
  s("fez", { t("felix.zeltner@node-robotics.com") }),

  s("dep", { t("<depend>"), i(1, "pkg"), t("</depend>") }),
  s("bdep", { t("<build_depend>"), i(1, "pkg"), t("</build_depend>") }),
  s("tdep", { t("<test_depend>"), i(1, "pkg"), t("</test_depend>") }),
  s("edep", { t("<exec_depend>"), i(1, "pkg"), t("</exec_depend>") }),
})
