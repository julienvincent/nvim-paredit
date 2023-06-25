local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local feedkeys = require("tests.nvim-paredit.utils").feedkeys
local expect = require("tests.nvim-paredit.utils").expect
local keybindings = require("nvim-paredit.utils.keybindings")
local motions = require("nvim-paredit.api.motions")

local next_element = keybindings.visualize(motions.move_to_next_element)
local prev_element = keybindings.visualize(motions.move_to_prev_element)

describe("motions with operator pending", function()
  before_each(function()
    vim.keymap.set("o", "E", next_element, { buffer = true })
    vim.keymap.set("o", "B", prev_element, { buffer = true })
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
  after_each(function()
    vim.keymap.del("o", "E")
    vim.keymap.del("o", "B")
  end)
end)
