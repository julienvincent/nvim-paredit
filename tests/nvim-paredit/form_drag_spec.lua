local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expectAll = require("tests.nvim-paredit.utils").expectAll
local expect = require("tests.nvim-paredit.utils").expect

describe('form-dragging', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
  local parser = vim.treesitter.get_parser(0)

  it('should drag the form forwards', function()
    expectAll(paredit.dragFormForwards, {
      {
        "list",
        before_content = "((a) (b))",
        before_cursor = { 1, 2 },
        after_content = '((b) (a))',
        after_cursor = { 1, 5 }
      },
      {
        "quoted list",
        before_content = "('(a) '(b))",
        before_cursor = { 1, 3 },
        after_content = "('(b) '(a))",
        after_cursor = { 1, 6 }
      },
      {
        "syn quoted list",
        before_content = "(`(a) `(b))",
        before_cursor = { 1, 3 },
        after_content = "(`(b) `(a))",
        after_cursor = { 1, 6 }
      },
      {
        "anon fn",
        before_content = "(#(a) #(b))",
        before_cursor = { 1, 3 },
        after_content = "(#(b) #(a))",
        after_cursor = { 1, 6 }
      },
      {
        "within quoted set",
        before_content = "'(`(a) `(b))",
        before_cursor = { 1, 3 },
        after_content = "'(`(b) `(a))",
        after_cursor = { 1, 7 }
      },
    })
  end)

  it('should do nothing if at the end of the parent form', function()
    prepareBuffer({
      content = "((a) (b))",
      cursor = { 1, 6 }
    })
    paredit.dragFormForwards()
    expect({
      content = '((a) (b))',
      cursor = { 1, 6 }
    })
  end)

  it('should drag the form backwards', function()
    prepareBuffer({
      content = "((a) (b))",
      cursor = { 1, 5 }
    })

    paredit.dragFormBackwards()
    expect({
      content = '((b) (a))',
      cursor = { 1, 1 }
    })

    parser:parse()

    paredit.dragFormBackwards()
    expect({
      content = '((b) (a))',
      cursor = { 1, 1 }
    })
  end)

  it('should drag the form in the root document', function()
    prepareBuffer({
      content = "(a) (b)",
      cursor = { 1, 4 }
    })

    paredit.dragFormBackwards()
    expect({
      content = '(b) (a)',
      cursor = { 1, 0 }
    })
  end)
end)
