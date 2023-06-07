local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expect = require("tests.nvim-paredit.utils").expect

describe('form-dragging', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
  local parser = vim.treesitter.get_parser(0)

  it('should drag the form forwards', function()
    prepareBuffer({
      content = "((a) (b))",
      cursor = { 1, 2 }
    })

    paredit.dragFormForwards()
    expect({
      content = '((b) (a))',
      cursor = { 1, 5 }
    })

    parser:parse()

    paredit.dragFormForwards()
    expect({
      content = '((b) (a))',
      cursor = { 1, 5 }
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
