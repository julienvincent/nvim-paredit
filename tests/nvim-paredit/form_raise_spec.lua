local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("form raising ::", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  it("should raise the form", function()
    expect_all(paredit.raise_form, {
      {
        "list",
        before_content = "(a (b c))",
        before_cursor = { 1, 6 },
        after_content = "(b c)",
        after_cursor = { 1, 0 },
      },
      {
        "list with deref",
        before_content = "(a @(b c))",
        before_cursor = { 1, 5 },
        after_content = "@(b c)",
        after_cursor = { 1, 0 },
      },
      {
        "quoted list",
        before_content = "(a '(b c))",
        before_cursor = { 1, 5 },
        after_content = "'(b c)",
        after_cursor = { 1, 0 },
      },
      {
        "set",
        before_content = "(a #{b c})",
        before_cursor = { 1, 5 },
        after_content = "#{b c}",
        after_cursor = { 1, 0 },
      },
      {
        "anon fn",
        before_content = "(a #(b c))",
        before_cursor = { 1, 5 },
        after_content = "#(b c)",
        after_cursor = { 1, 0 },
      },
      {
        "reader conditional",
        before_content = "(let [z 1] #?(:clj a :cljs #{b c}))",
        before_cursor = { 1, 14 },
        after_content = "#?(:clj a :cljs #{b c})",
        after_cursor = { 1, 0 },
      },
    })
  end)

  it("should raise a multi-line form", function()
    prepare_buffer({
      content = { "(a (b ", "c))" },
      cursor = { 1, 4 },
    })

    paredit.raise_form()
    expect({
      content = { "(b ", "c)" },
      cursor = { 1, 0 },
    })
  end)

  it("should do nothing if it is a direct child of the document root", function()
    prepare_buffer({
      content = { "(a)", "b" },
      cursor = { 1, 1 },
    })
    paredit.raise_form()
    expect({
      content = { "(a)", "b" },
      cursor = { 1, 1 },
    })
  end)

  it("should do nothing if it is outside of a form", function()
    prepare_buffer({
      content = { "a", "b" },
      cursor = { 1, 0 },
    })
    paredit.raise_form()
    expect({
      content = { "a", "b" },
      cursor = { 1, 0 },
    })
  end)
end)
