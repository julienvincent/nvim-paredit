local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expectAll = require("tests.nvim-paredit.utils").expectAll
local expect = require("tests.nvim-paredit.utils").expect

describe('slurping', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
  local parser = vim.treesitter.get_parser(0)

  it("should slurp different form types", function()
    expectAll(paredit.slurpForwards, {
      {
        "list",
        before_content = "() a",
        before_cursor = { 1, 1 },
        after_content = '( a)',
        after_cursor = { 1, 1 }
      },
      {
        "vector",
        before_content = "[] a",
        before_cursor = { 1, 1 },
        after_content = '[ a]',
        after_cursor = { 1, 1 }
      },
      {
        "quoted list",
        before_content = "`() a",
        before_cursor = { 1, 2 },
        after_content = '`( a)',
        after_cursor = { 1, 2 }
      },
      {
        "quoted list",
        before_content = "'() a",
        before_cursor = { 1, 2 },
        after_content = "'( a)",
        after_cursor = { 1, 2 }
      },
      {
        "anon fn",
        before_content = "#() a",
        before_cursor = { 1, 2 },
        after_content = "#( a)",
        after_cursor = { 1, 2 }
      },
      {
        "set",
        before_content = "#{} a",
        before_cursor = { 1, 2 },
        after_content = "#{ a}",
        after_cursor = { 1, 2 }
      },
    })
  end)

  it('should skip comments', function()
    prepareBuffer({
      content = { "()", ";; comment", "a" },
      cursor = { 1, 1 }
    })
    paredit.slurpForwards()
    expect({
      content = { '(', ";; comment", "a)" },
      cursor = { 1, 0 }
    })
  end)

  it('should recursively slurp the next sibling', function()
    prepareBuffer({
      content = "(()) 1 2",
      cursor = { 1, 2 }
    })

    paredit.slurpForwards()
    expect({
      content = '(() 1) 2',
      cursor = { 1, 2 }
    })

    parser:parse()

    paredit.slurpForwards()
    expect({
      content = '(( 1)) 2',
      cursor = { 1, 2 }
    })

    parser:parse()

    paredit.slurpForwards()
    expect({
      content = '(( 1) 2)',
      cursor = { 1, 2 }
    })

    parser:parse()

    paredit.slurpForwards()
    expect({
      content = '(( 1 2))',
      cursor = { 1, 2 }
    })
  end)
end)
