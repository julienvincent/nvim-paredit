local paredit = require("nvim-paredit.api")

local prepareBuffer = require("tests.nvim-paredit.utils").prepareBuffer
local expectAll = require("tests.nvim-paredit.utils").expectAll
local expect = require("tests.nvim-paredit.utils").expect

describe('barfing', function()
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')

  it("should barf different form types", function()
    expectAll(paredit.barfForwards, {
      {
        "list",
        before_content = "(a)",
        before_cursor = { 1, 1 },
        after_content = '()a',
        after_cursor = { 1, 1 }
      },
      {
        "vector",
        before_content = "[a]",
        before_cursor = { 1, 1 },
        after_content = '[]a',
        after_cursor = { 1, 1 }
      },
      {
        "quoted list",
        before_content = "`(a)",
        before_cursor = { 1, 2 },
        after_content = '`()a',
        after_cursor = { 1, 2 }
      },
      {
        "quoted list",
        before_content = "'(a)",
        before_cursor = { 1, 2 },
        after_content = "'()a",
        after_cursor = { 1, 2 }
      },
      {
        "anon fn",
        before_content = "#(a)",
        before_cursor = { 1, 2 },
        after_content = "#()a",
        after_cursor = { 1, 2 }
      },
      {
        "set",
        before_content = "#{a}",
        before_cursor = { 1, 2 },
        after_content = "#{}a",
        after_cursor = { 1, 2 }
      },
    })
  end)

  it('should skip comments', function()
    prepareBuffer({
      content = { "(", ";; comment", "a)" },
      cursor = { 1, 1 }
    })
    paredit.barfForwards()
    expect({
      content = { '()', ";; comment", "a" },
      cursor = { 1, 0 }
    })

    prepareBuffer({
      content = { "(a ;; comment", ")" },
      cursor = { 1, 1 }
    })
    paredit.barfForwards()
    expect({
      content = '()a ;; comment',
      cursor = { 1, 1 }
    })
  end)

  it('should do nothing in an empty form', function()
    prepareBuffer({
      content = "()",
      cursor = { 1, 1 }
    })
    paredit.barfForwards()
    expect({
      content = '()',
      cursor = { 1, 1 }
    })
  end)

  it('should do nothing in the document root', function()
    expectAll(paredit.barfForwards, {
      {
        "from root",
        before_content = {"(a)", ""},
        before_cursor = { 2, 0 },
        after_content = {"(a)", ""},
        after_cursor = { 2, 0 },
      },
      {
        "from another list",
        before_content = {"(a)", "()"},
        before_cursor = { 2, 1 },
        after_content = {"(a)", "()"},
        after_cursor = { 2, 1 },
      },
    })
  end)

  it('should recursively barf the next sibling', function()
    expectAll(paredit.barfForwards, {
      {
        "double nested list",
        before_content = "(() a)",
        before_cursor = { 1, 2 },
        after_content = "(()) a",
        after_cursor = { 1, 2 },
      },
      {
        "list with quoted list",
        before_content = "('())",
        before_cursor = { 1, 3 },
        after_content = "()'()",
        after_cursor = { 1, 4 },
      },
    })
  end)
end)
