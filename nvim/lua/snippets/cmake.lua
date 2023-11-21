local ls = require("luasnip")

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local d = ls.dynamic_node
local e = require("luasnip.extras")
local line_begin = require("luasnip.extras.conditions.expand").line_begin

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
  s({trig = "tid", condition = line_begin}, {
    t("target_include_directories("), i(1, "${PROJECT_NAME}"),
    t({"", "  PUBLIC",
    [[    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"]],
    [[    "$<INSTALL_INTERFACE:include/${PROJECT_NAME}>")]]})
  }),
  s({trig="id", condition = line_begin}, {
    t("target_include_directories("), i(1, "${PROJECT_NAME}"), t(" "), i(2, "PUBLIC"),
    t({"", "  ${"}), i(3, "lib"), t("_INCLUDE_DIRS}"),
    t({"", ")"})
  }),
  s({trig="it", condition = line_begin}, {
    t("install(TARGETS "), i(1, "${PROJECT_NAME}"),
    t({"", "  EXPORT export_"}), e.rep(1),
    t({"",
       "  ARCHIVE DESTINATION lib",
       "  LIBRARY DESTINATION lib",
       "  RUNTIME DESTINATION bin",
       ")"})
  }),
  s({trig="aet", condition = line_begin}, {
    t("ament_export_targets(export_"), i(1, "${PROJECT_NAME}"), i(2, " HAS_LIBRARY_TARGET"), t(")")
  }),
  s({trig="tll", condition = line_begin}, {
    t("target_link_libraries("), i(1, "${PROJECT_NAME}"), t(" "), i(2, "PUBLIC"),
    t({"", "  "}), i(3, "lib"),
    t({"", ")"})
  }),
})
