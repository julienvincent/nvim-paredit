local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local feedkeys = require("tests.nvim-paredit.utils").feedkeys
local expect = require("tests.nvim-paredit.utils").expect
local keybindings = require("nvim-paredit.utils.keybindings")

local defaults = require("nvim-paredit.defaults")

describe("motions with operator pending", function()
  before_each(function()
    keybindings.setup_keybindings({
      keys = defaults.default_keys,
    })
  end)

  it("should delete next form", function()
    prepare_buffer({
      content = "(a a) (b b)",
      cursor = { 1, 0 },
    })
    feedkeys("d<S-e>")
    expect({
      content = " (b b)",
      cursor = { 1, 0 },
    })
    feedkeys("d<S-e>")
    expect({
      content = "",
      cursor = { 1, 0 },
    })
  end)

  it("should delete until the next element head", function()
    prepare_buffer({
      content = { "(a a)", "(b b)" },
      cursor = { 1, 0 },
    })
    feedkeys("d<S-w>")
    expect({
      content = {"(b b)"},
      cursor = { 1, 0 },
    })
  end)

  it("should delete until the previous element tail", function()
    prepare_buffer({
      content = { "(a a)", "(b b)" },
      cursor = { 2, 5 },
    })
    feedkeys("dg<S-e>")
    expect({
      content = {"(a a)"},
      cursor = { 1, 4 },
    })
  end)

  it("should delete til next", function()
    prepare_buffer({
      content = "(a a) (b b)",
      cursor = { 1, 0 },
    })
    feedkeys("d<S-w>")
    expect({
      content = "(b b)",
      cursor = { 1, 0 },
    })
  end)

  it("should delete form if there is no next", function()
    prepare_buffer({
      content = "(b b)",
      cursor = { 1, 0 },
    })
    feedkeys("d<S-w>")
    expect({
      content = "",
      cursor = { 1, 0 },
    })
  end)

  it("should delete 2 forms within parent form and join up", function()
    prepare_buffer({
      content = {"[(a a) (b b) (c c)]"},
      cursor = { 1, 1 },
    })
    feedkeys("2d<S-w>")
    expect({
      content = "[(c c)]",
      cursor = { 1, 1 },
    })
  end)

  it("should delete next form (multiline)", function()
    prepare_buffer({
      content = { "(a a)", ";; comment", "(b b)" },
      cursor = { 1, 0 },
    })
    feedkeys("d<S-e>")
    expect({
      content = { "", ";; comment", "(b b)" },
      cursor = { 1, 0 },
    })
    feedkeys("d<S-e>")
    expect({
      content = "",
      cursor = { 1, 0 },
    })
  end)

  it("should change next form", function()
    prepare_buffer({
      content = "(a a) (b b)",
      cursor = { 1, 0 },
    })
    feedkeys("c<S-e>[a b]")
    expect({
      content = "[a b] (b b)",
      cursor = { 1, 4 },
    })
  end)

  it("should delete prev form", function()
    prepare_buffer({
      content = "(a a) (b b)",
      cursor = { 1, 10 },
    })
    feedkeys("d<S-b>")
    expect({
      content = "(a a) ",
      cursor = { 1, 5 },
    })
    feedkeys("d<S-b>")
    expect({
      content = "",
      cursor = { 1, 0 },
    })
  end)

  it("should change prev form", function()
    prepare_buffer({
      content = "(a a) (b b)",
      cursor = { 1, 4 },
    })
    feedkeys("c<S-b>[a b]")
    expect({
      content = "[a b] (b b)",
      cursor = { 1, 4 },
    })
  end)
end)

describe("motions with operator pending and v:count", function()
  before_each(function()
    keybindings.setup_keybindings({
      keys = defaults.default_keys,
    })
  end)

  it("should delete the next 2 elements", function()
    prepare_buffer({
      content = "(aa bb cc)",
      cursor = { 1, 4 },
    })
    feedkeys("d2<S-e>")
    expect({
      content = "(aa )",
      cursor = { 1, 4 },
    })
  end)

  it("should delete the previous 2 elements", function()
    prepare_buffer({
      content = "(aa bb cc)",
      cursor = { 1, 8 },
    })
    feedkeys("d2<S-b>")
    expect({
      content = "(aa )",
      cursor = { 1, 4 },
    })
  end)
end)
