local keybindings = require("nvim-paredit.utils.keybindings")
local defaults = require("nvim-paredit.defaults")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local feedkeys = require("tests.nvim-paredit.utils").feedkeys
local expect = require("tests.nvim-paredit.utils").expect
local utils = require("tests.nvim-paredit.utils")

describe("form deletions", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")

  before_each(function()
    keybindings.setup_keybindings({
      keys = defaults.default_keys,
    })
  end)

  it("should delete the form", function()
    prepare_buffer({
      content = "(a a)",
      cursor = { 1, 1 },
    })
    feedkeys("daf")
    expect({
      content = "",
      cursor = { 1, 0 },
    })
  end)

  it("should delete a multi line form", function()
    prepare_buffer({
      content = { "(a", "b", "c)" },
      cursor = { 1, 1 },
    })
    feedkeys("daf")
    expect({
      content = "",
      cursor = { 1, 0 },
    })
  end)

  it("should delete a nested form", function()
    prepare_buffer({
      content = "(a (b c))",
      cursor = { 1, 5 },
    })
    feedkeys("daf")
    expect({
      content = "(a )",
      cursor = { 1, 3 },
    })
  end)

  it("should delete everything in the form", function()
    prepare_buffer({
      content = "(a b)",
      cursor = { 1, 2 },
    })
    feedkeys("dif")
    expect({
      content = "()",
      cursor = { 1, 1 },
    })
  end)

  it("should delete everything within a multi line form", function()
    prepare_buffer({
      content = { "(a", "b", "c)" },
      cursor = { 2, 0 },
    })
    feedkeys("dif")
    expect({
      content = "()",
      cursor = { 1, 1 },
    })
  end)
end)

describe("form selections", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")

  before_each(function()
    keybindings.setup_keybindings({
      keys = defaults.default_keys,
    })
  end)

  it("should select the form", function()
    prepare_buffer({
      content = "(a a)",
      cursor = { 1, 1 },
    })
    feedkeys("vaf")
    assert.are.same("(a a)", utils.get_selected_text())
  end)

  it("should select within the form", function()
    prepare_buffer({
      content = "(a a)",
      cursor = { 1, 1 },
    })
    feedkeys("vif")
    assert.are.same("a a", utils.get_selected_text())
  end)
end)
