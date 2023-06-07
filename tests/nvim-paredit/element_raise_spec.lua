local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expect = require("tests.nvim-paredit.utils").expect

describe('element raising', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')

  it('should raise the element', function()
    prepareBuffer({
      content = "(a (b))",
      cursor = { 1, 4 }
    })
    paredit.raiseElement()
    expect({
      content = '(a b)',
      cursor = { 1, 3 }
    })

    prepareBuffer({
      content = "(:keyword)",
      cursor = { 1, 1 }
    })
    paredit.raiseElement()
    expect({
      content = ':keyword',
      cursor = { 1, 0 }
    })

    prepareBuffer({
      content = "(::keyword)",
      cursor = { 1, 1 }
    })
    paredit.raiseElement()
    expect({
      content = '::keyword',
      cursor = { 1, 0 }
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
      cursor = { 1, 0 }
    })

    prepareBuffer({
      content = "(a '(b))",
      cursor = { 1, 3 }
    })

    paredit.raiseElement()
    expect({
      content = '\'(b)',
      cursor = { 1, 0 }
    })

    prepareBuffer({
      content = "(a #{b})",
      cursor = { 1, 4 }
    })

    paredit.raiseElement()
    expect({
      content = '#{b}',
      cursor = { 1, 0 }
    })
  end)

  it('should raise a multi-line element', function()
    prepareBuffer({
      content = "(a (b\n c))",
      cursor = { 1, 3 }
    })

    paredit.raiseElement()
    expect({
      content = {'(b', ' c)'},
      cursor = { 1, 0 }
    })
  end)
end)
