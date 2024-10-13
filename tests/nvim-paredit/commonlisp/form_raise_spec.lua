local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("form raising", function()
  vim.api.nvim_set_option_value("filetype", "lisp", {
    buf = 0,
  })

  it("should raise the form", function()
    expect_all(paredit.raise_form, {
      {
        "list",
        { "(a (b |c))" },
        { "|(b c)" },
      },
      {
        "list with reader",
        { "(a #(|b c))" },
        { "|#(b c)" },
      },
    })
  end)

  it("should do nothing if it is a direct child of the document root", function()
    prepare_buffer({
      "(|a)",
      "b",
    })
    paredit.raise_form()
    expect({
      "(|a)",
      "b",
    })
  end)

  it("should do nothing if it is outside of a form", function()
    prepare_buffer({
      "|a",
      "b",
    })
    paredit.raise_form()
    expect({
      "|a",
      "b",
    })
  end)
end)
