local paredit = require("nvim-paredit.api")

local parser

local function prepareBuffer(params)
  vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.fn.split(params.content, '\n'))
  vim.api.nvim_win_set_cursor(0, params.cursor)
  parser:parse()
end

local function expect(value)
  assert.are.same(value, vim.api.nvim_buf_get_lines(0, 0, -1, false)[1])
end

describe('slurpage', function()
  before_each(function ()
    vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
    parser = vim.treesitter.get_parser(0)
  end)

  it('should slurp the next sibling', function()
    prepareBuffer({
      content = "() a",
      cursor = { 1, 1 }
    })

    paredit.slurpForwards()
    expect('( a)')
  end)

  it('should recursively slurp the next sibling', function()
    prepareBuffer({
      content = "(()) 1 2",
      cursor = { 1, 2 }
    })

    paredit.slurpForwards()
    expect('(() 1) 2')

    parser:parse()

    paredit.slurpForwards()
    expect('(( 1)) 2')

    parser:parse()

    paredit.slurpForwards()
    expect('(( 1) 2)')

    parser:parse()

    paredit.slurpForwards()
    expect('(( 1 2))')
  end)
end)
