local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expect = require("tests.nvim-paredit.utils").expect

describe('form raising', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')

  it('should raise the form', function()
    prepareBuffer({
      content = "(a (b c))",
      cursor = { 1, 6 }
    })

    paredit.raiseForm()
    expect({
      content = '(b c)',
      cursor = { 1, 0 }
    })
  end)

  it('should raise a multi-line form', function()
    prepareBuffer({
      content = "(a (b \nc))",
      cursor = { 1, 4 }
    })

    paredit.raiseForm()
    expect({
      content = {'(b ', 'c)'},
      cursor = { 1, 0 }
    })
  end)
end)
