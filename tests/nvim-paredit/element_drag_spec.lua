local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expectAll = require("tests.nvim-paredit.utils").expectAll
local expect = require("tests.nvim-paredit.utils").expect

describe('element-dragging', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
  local parser = vim.treesitter.get_parser(0)

  it('should drag the element forwards', function()
    prepareBuffer({
      content = "(a b)",
      cursor = { 1, 1 }
    })

    paredit.dragElementForwards()
    expect({
      content = '(b a)',
      cursor = { 1, 3 }
    })

    parser:parse()

    paredit.dragElementForwards()
    expect({
      content = '(b a)',
      cursor = { 1, 3 }
    })
  end)

  it('should drag the element backwards', function()
    prepareBuffer({
      content = "(a b)",
      cursor = { 1, 3 }
    })

    paredit.dragElementBackwards()
    expect({
      content = '(b a)',
      cursor = { 1, 1 }
    })

    parser:parse()

    paredit.dragElementBackwards()
    expect({
      content = '(b a)',
      cursor = { 1, 1 }
    })
  end)

  it('should drag the element in the root document', function()
    prepareBuffer({
      content = "a b",
      cursor = { 1, 0 }
    })

    paredit.dragElementForwards()
    expect({
      content = 'b a',
      cursor = { 1, 2 }
    })
  end)

  it('should drag any element type', function()
    expectAll(paredit.dragElementBackwards, {
      {
        "symbol",
        before_content = "(a b)",
        before_cursor = { 1, 3 },
        after_content = "(b a)",
        after_cursor = { 1, 1 }
      },
      {
        "quoted symbol",
        before_content = "(a 'b)",
        before_cursor = { 1, 4 },
        after_content = "('b a)",
        after_cursor = { 1, 1 }
      },
      {
        "string",
        before_content = '(a "string")',
        before_cursor = { 1, 4 },
        after_content = '("string" a)',
        after_cursor = { 1, 1 }
      },
      {
        "number",
        before_content = '(a 1)',
        before_cursor = { 1, 3 },
        after_content = '(1 a)',
        after_cursor = { 1, 1 }
      },
      {
        "keyword",
        before_content = '(a :keyword)',
        before_cursor = { 1, 3 },
        after_content = '(:keyword a)',
        after_cursor = { 1, 1 }
      },
      {
        "namespaced keyword",
        before_content = '(a ::keyword)',
        before_cursor = { 1, 3 },
        after_content = '(::keyword a)',
        after_cursor = { 1, 1 }
      },
      {
        "namespaced keyword different cursor",
        before_content = '(a ::keyword)',
        before_cursor = { 1, 5 },
        after_content = '(::keyword a)',
        after_cursor = { 1, 1 }
      },
      {
        "set",
        before_content = '(a #{1})',
        before_cursor = { 1, 3 },
        after_content = '(#{1} a)',
        after_cursor = { 1, 1 }
      },
      {
        "map",
        before_content = '(a {:a 1})',
        before_cursor = { 1, 3 },
        after_content = '({:a 1} a)',
        after_cursor = { 1, 1 }
      },
      {
        "map",
        before_content = "(a '(a))",
        before_cursor = { 1, 3 },
        after_content = "('(a) a)",
        after_cursor = { 1, 1 }
      },
    })
  end)
end)
