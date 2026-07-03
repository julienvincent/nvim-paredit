local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("element raising", function()
  vim.api.nvim_set_option_value("filetype", "fennel", {
    buf = 0,
  })

  it("should raise the element", function()
    prepare_buffer({
      content = "(a (b))",
      cursor = { 1, 4 },
    })
    paredit.raise_element()
    expect({
      content = "(a b)",
      cursor = { 1, 3 },
    })
  end)

  it("should raise form elements when cursor is placed on edge", function()
    prepare_buffer({
      content = "(a (b))",
      cursor = { 1, 3 },
    })

    paredit.raise_element()
    expect({
      content = "(b)",
      cursor = { 1, 0 },
    })

    prepare_buffer({
      content = "(a #(b))",
      cursor = { 1, 3 },
    })

    paredit.raise_element()
    expect({
      content = "#(b)",
      cursor = { 1, 0 },
    })
  end)

  it("should raise a multi-line element", function()
    prepare_buffer({
      content = { "(a (b", " c))" },
      cursor = { 1, 3 },
    })

    paredit.raise_element()
    expect({
      content = { "(b", " c)" },
      cursor = { 1, 0 },
    })
  end)

  it("should raise the condition of an if pair", function()
    prepare_buffer({
      content = "(if a (b))",
      cursor = { 1, 4 },
    })

    paredit.raise_element()
    expect({
      content = "a",
      cursor = { 1, 0 },
    })
  end)

  it("should raise the expression of an if pair when on its edge", function()
    prepare_buffer({
      content = "(if a (b))",
      cursor = { 1, 6 },
    })

    paredit.raise_element()
    expect({
      content = "(b)",
      cursor = { 1, 0 },
    })
  end)

  it("should raise an inner symbol of an if pair expression", function()
    prepare_buffer({
      content = "(if a (b))",
      cursor = { 1, 7 },
    })

    paredit.raise_element()
    expect({
      content = "(if a b)",
      cursor = { 1, 6 },
    })
  end)

  it("should raise a nested form from an if pair expression", function()
    prepare_buffer({
      content = "(if a (b (+ 1 1)))",
      cursor = { 1, 9 },
    })

    paredit.raise_element()
    expect({
      content = "(if a (+ 1 1))",
      cursor = { 1, 6 },
    })
  end)

  it("should raise the expression of a later if pair", function()
    prepare_buffer({
      content = "(if a (b) c (d))",
      cursor = { 1, 12 },
    })

    paredit.raise_element()
    expect({
      content = "(d)",
      cursor = { 1, 0 },
    })
  end)

  it("should raise an inner symbol of a later if pair expression", function()
    prepare_buffer({
      content = "(if a (b) c (d))",
      cursor = { 1, 13 },
    })

    paredit.raise_element()
    expect({
      content = "(if a (b) c d)",
      cursor = { 1, 12 },
    })
  end)

  it("should raise the else branch of an if", function()
    prepare_buffer({
      content = "(if a (b) (c))",
      cursor = { 1, 10 },
    })

    paredit.raise_element()
    expect({
      content = "(c)",
      cursor = { 1, 0 },
    })
  end)

  it("should raise an element out of a multi-line if form", function()
    prepare_buffer({
      content = { "(if a (b)", "c (d e)", "f)" },
      cursor = { 2, 3 },
    })

    paredit.raise_element()
    expect({
      content = { "(if a (b)", "c d", "f)" },
      cursor = { 2, 2 },
    })
  end)

  it("should do nothing if it is a direct child of the document root", function()
    prepare_buffer({
      content = { "a", "b" },
      cursor = { 1, 0 },
    })
    paredit.raise_element()
    expect({
      content = { "a", "b" },
      cursor = { 1, 0 },
    })
  end)
end)
