local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expect = require("tests.nvim-paredit.utils").expect

describe('barfing', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
  local parser = vim.treesitter.get_parser(0)

  it('should raise the element', function()
    prepareBuffer({
      content = "(a (b))",
      cursor = { 1, 4 }
    })

    paredit.raiseElement()
    expect({
      content = '(a b)',
      cursor = { 1, 4 }
    })
  end)

  it('should raise form elements when cursor is placed on edge', function()
    prepareBuffer({
      content = "(a (b))",
      cursor = { 1, 3 }
    })

    paredit.raiseElement()
    expect({
      content = '(b)',
      cursor = { 1, 3 }
    })
  end)
end)
