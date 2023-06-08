local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expect = require("tests.nvim-paredit.utils").expect

describe('barfing', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
  local parser = vim.treesitter.get_parser(0)

  it('should barf the next sibling', function()
    prepareBuffer({
      content = "(a)",
      cursor = { 1, 1 }
    })

    paredit.barfForwards()
    expect({
      content = '()a',
      cursor = { 1, 1 }
    })
  end)

  it('should skip comments', function()
    prepareBuffer({
      content = {"(", ";; comment", "a)"},
      cursor = { 1, 1 }
    })
    paredit.barfForwards()
    expect({
      content = {'()', ";; comment", "a"},
      cursor = { 1, 0 }
    })

    prepareBuffer({
      content = {"(a ;; comment", ")"},
      cursor = { 1, 1 }
    })
    paredit.barfForwards()
    expect({
      content = '()a ;; comment',
      cursor = { 1, 1 }
    })
  end)

  it('should recursively barf the next sibling', function()
    prepareBuffer({
      content = "((a b))",
      cursor = { 1, 2 }
    })

    paredit.barfForwards()
    expect({
      content = '((a) b)',
      cursor = { 1, 2 }
    })

    parser:parse()

    paredit.barfForwards()
    expect({
      content = '(()a b)',
      cursor = { 1, 2 }
    })

    parser:parse()

    paredit.barfForwards()
    expect({
      content = '(()a) b',
      cursor = { 1, 2 }
    })

    parser:parse()

    paredit.barfForwards()
    expect({
      content = '(())a b',
      cursor = { 1, 2 }
    })
  end)
end)
