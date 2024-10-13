local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("form-dragging", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })
  local parser = vim.treesitter.get_parser(0)
  if not parser then
    return error("Failed to get parser for language")
  end

  it("should drag the form forwards", function()
    expect_all(paredit.drag_form_forwards, {
      {
        "list",
        before_content = "((a) (b))",
        before_cursor = { 1, 2 },
        after_content = "((b) (a))",
        after_cursor = { 1, 5 },
      },
      {
        "quoted list",
        before_content = "('(a) '(b))",
        before_cursor = { 1, 3 },
        after_content = "('(b) '(a))",
        after_cursor = { 1, 6 },
      },
      {
        "syn quoted list",
        before_content = "(`(a) `(b))",
        before_cursor = { 1, 3 },
        after_content = "(`(b) `(a))",
        after_cursor = { 1, 6 },
      },
      {
        "anon fn",
        before_content = "(#(a) #(b))",
        before_cursor = { 1, 3 },
        after_content = "(#(b) #(a))",
        after_cursor = { 1, 6 },
      },
      {
        "within quoted set",
        before_content = "'(`(a) `(b))",
        before_cursor = { 1, 3 },
        after_content = "'(`(b) `(a))",
        after_cursor = { 1, 7 },
      },
      {
        "within elide",
        before_content = "'(#_`(a) `(b))",
        before_cursor = { 1, 6 },
        after_content = "'(`(b) #_`(a))",
        after_cursor = { 1, 7 },
      },
    })
  end)

  it("should do nothing if at the end of the parent form", function()
    prepare_buffer({
      content = "((a) (b))",
      cursor = { 1, 6 },
    })
    paredit.drag_form_forwards()
    expect({
      content = "((a) (b))",
      cursor = { 1, 6 },
    })
  end)

  it("should drag the form backwards", function()
    prepare_buffer({
      content = "((a) (b))",
      cursor = { 1, 5 },
    })

    paredit.drag_form_backwards()
    expect({
      content = "((b) (a))",
      cursor = { 1, 1 },
    })

    parser:parse()

    paredit.drag_form_backwards()
    expect({
      content = "((b) (a))",
      cursor = { 1, 1 },
    })
  end)

  it("should drag the form in the root document", function()
    prepare_buffer({
      content = "(a) (b)",
      cursor = { 1, 4 },
    })

    paredit.drag_form_backwards()
    expect({
      content = "(b) (a)",
      cursor = { 1, 0 },
    })
  end)
end)
