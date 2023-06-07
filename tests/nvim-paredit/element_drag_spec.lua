local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
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
    prepareBuffer({
      content = "(a 'b)",
      cursor = { 1, 4 }
    })
    paredit.dragElementBackwards()
    expect({
      content = "('b a)",
      cursor = { 1, 1 }
    })

    prepareBuffer({
      content = '(a "string")',
      cursor = { 1, 4 }
    })
    paredit.dragElementBackwards()
    expect({
      content = '("string" a)',
      cursor = { 1, 1 }
    })

    prepareBuffer({
      content = "(a 1)",
      cursor = { 1, 3 }
    })
    paredit.dragElementBackwards()
    expect({
      content = "(1 a)",
      cursor = { 1, 1 }
    })

    prepareBuffer({
      content = "(a true)",
      cursor = { 1, 3 }
    })
    paredit.dragElementBackwards()
    expect({
      content = "(true a)",
      cursor = { 1, 1 }
    })

    prepareBuffer({
      content = "(a #{})",
      cursor = { 1, 3 }
    })
    paredit.dragElementBackwards()
    expect({
      content = "(#{} a)",
      cursor = { 1, 1 }
    })

    prepareBuffer({
      content = "(a {})",
      cursor = { 1, 3 }
    })
    paredit.dragElementBackwards()
    expect({
      content = "({} a)",
      cursor = { 1, 1 }
    })

    prepareBuffer({
      content = "(a '())",
      cursor = { 1, 3 }
    })
    paredit.dragElementBackwards()
    expect({
      content = "('() a)",
      cursor = { 1, 1 }
    })
  end)
end)
