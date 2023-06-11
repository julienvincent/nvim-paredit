local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("form raising", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")

  it("should raise the form", function()
    prepare_buffer({
      content = "(a (b c))",
      cursor = { 1, 6 },
    })

    paredit.raise_form()
    expect({
      content = "(b c)",
      cursor = { 1, 0 },
    })
  end)

  it("should raise a multi-line form", function()
    prepare_buffer({
      content = { "(a (b ", "c))" },
      cursor = { 1, 4 },
    })

    paredit.raise_form()
    expect({
      content = { "(b ", "c)" },
      cursor = { 1, 0 },
    })
  end)

  it("should do nothing if it is a direct child of the document root", function()
    prepare_buffer({
      content = { "(a)", "b" },
      cursor = { 1, 1 },
    })
    paredit.raise_form()
    expect({
      content = { "(a)", "b" },
      cursor = { 1, 1 },
    })
  end)

  it("should do nothing if it is outside of a form", function()
    prepare_buffer({
      content = { "a", "b" },
      cursor = { 1, 0 },
    })
    paredit.raise_form()
    expect({
      content = { "a", "b" },
      cursor = { 1, 0 },
    })
  end)
end)
