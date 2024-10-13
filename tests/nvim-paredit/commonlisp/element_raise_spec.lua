local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("element raising", function()
  vim.api.nvim_set_option_value("filetype", "lisp", {
    buf = 0,
  })

  it("should raise the element", function()
    prepare_buffer({
      "(a (|b))",
    })
    paredit.raise_element()
    expect({
      "(a |b)",
    })
  end)

  it("should raise form elements when cursor is placed on edge", function()
    prepare_buffer({
      "(a |(b))",
    })

    paredit.raise_element()
    expect({
      "|(b)",
    })

    prepare_buffer({
      "(a |#(b))",
    })

    paredit.raise_element()
    expect({
      "|#(b)",
    })
  end)

  it("should do nothing if it is a direct child of the document root", function()
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
