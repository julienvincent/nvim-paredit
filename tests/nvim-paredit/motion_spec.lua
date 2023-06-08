local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expect = require("tests.nvim-paredit.utils").expect

describe('motions', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')

  it('should jump to next element in form', function()
    prepareBuffer({
      content = "(aa bb)",
      cursor = { 1, 1 }
    })
    paredit.moveToNextElement()
    expect({
      content = '(aa bb)',
      cursor = { 1, 5 }
    })
    paredit.moveToNextElement()
    expect({
      content = '(aa bb)',
      cursor = { 1, 5 }
    })
  end)

  it('should jump to previous element in form', function()
    prepareBuffer({
      content = "(aa bb)",
      cursor = { 1, 5 }
    })
    paredit.moveToPrevElement()
    expect({
      content = '(aa bb)',
      cursor = { 1, 1 }
    })
    paredit.moveToPrevElement()
    expect({
      content = '(aa bb)',
      cursor = { 1, 1 }
    })
  end)
end)
