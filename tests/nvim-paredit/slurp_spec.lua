local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expect = require("tests.nvim-paredit.utils").expect

describe('slurping', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
  local parser = vim.treesitter.get_parser(0)

  it('should slurp the next sibling', function()
    prepareBuffer({
      content = "() a",
      cursor = { 1, 1 }
    })

    paredit.slurpForwards()
    expect({
      content = '( a)',
      cursor = { 1, 1 }
    })
  end)

  it('should skip comments', function()
    prepareBuffer({
      content = {"()", ";; comment", "a"},
      cursor = { 1, 1 }
    })

    paredit.slurpForwards()
    expect({
      content = {'(', ";; comment", "a)"},
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
