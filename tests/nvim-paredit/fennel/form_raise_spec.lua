local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("form raising", function()
  vim.api.nvim_set_option_value("filetype", "fennel", {
    buf = 0,
  })

  it("should raise the form", function()
    expect_all(paredit.raise_form, {
      {
        "list",
        before_content = "(a (b c))",
        before_cursor = { 1, 6 },
        after_content = "(b c)",
        after_cursor = { 1, 0 },
      },
      {
        "list with reader",
        before_content = "(a #(b c))",
        before_cursor = { 1, 5 },
        after_content = "#(b c)",
        after_cursor = { 1, 0 },
      },
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
