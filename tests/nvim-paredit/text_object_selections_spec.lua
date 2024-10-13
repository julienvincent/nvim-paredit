local keybindings = require("nvim-paredit.utils.keybindings")
local defaults = require("nvim-paredit.defaults")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local feedkeys = require("tests.nvim-paredit.utils").feedkeys
local expect = require("tests.nvim-paredit.utils").expect
local utils = require("tests.nvim-paredit.utils")

describe("form deletions", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

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

  it("should delete the reader conditional form", function()
    prepare_buffer({
      content = "#?(:clj a :cljs a)",
      cursor = { 1, 5 },
    })
    feedkeys("daf")
    expect({
      content = "",
      cursor = { 1, 0 },
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

  it("should delete everything in the reader conditional form", function()
    prepare_buffer({
      content = "#?(:clj a b)",
      cursor = { 1, 4 },
    })
    feedkeys("dif")
    expect({
      content = "#?()",
      cursor = { 1, 3 },
    })
  end)
end)

describe("top level form deletions", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  before_each(function()
    keybindings.setup_keybindings({
      keys = defaults.default_keys,
    })
  end)

  it("should delete the top level form, leaving other forms intact", function()
    prepare_buffer({
      content = { "(+ 1 2)", "(foo (a", "b", "c)) (comment thing)", "(x y)" },
      cursor = { 2, 7 },
    })
    feedkeys("daF")
    expect({
      content = { "(+ 1 2)", " (comment thing)", "(x y)" },
      cursor = { 2, 0 },
    })
  end)

  it("should delete inside the top level form, leaving other forms and the outer parenthesis pair intact", function()
    prepare_buffer({
      content = { "(+ 1 2)", "(foo (a", "b", "c)) (comment thing)", "(x y)" },
      cursor = { 2, 7 },
    })
    feedkeys("diF")
    expect({
      content = { "(+ 1 2)", "() (comment thing)", "(x y)" },
      cursor = { 2, 1 },
    })
  end)
end)

describe("form selections", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

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

describe("top form selections", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  before_each(function()
    keybindings.setup_keybindings({
      keys = defaults.default_keys,
    })
  end)

  it("should select the root form and not the siblings", function()
    prepare_buffer({
      content = { "(+ 1 2)", "(foo (a", "a)) (/ 6 2)" },
      cursor = { 2, 6 },
    })
    feedkeys("vaF")
    assert.are.same("(foo (a\na))", utils.get_selected_text())
  end)

  it("should select within the form", function()
    prepare_buffer({
      content = { "(+ 1 2)", "(foo (a", "a)) (/ 6 2)" },
      cursor = { 2, 6 },
    })
    feedkeys("viF")
    assert.are.same("foo (a\na)", utils.get_selected_text())
  end)
end)

describe("element deletions", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  before_each(function()
    keybindings.setup_keybindings({
      keys = defaults.default_keys,
    })
  end)

  it("should delete the element", function()
    prepare_buffer({
      content = "(a :a/b)",
      cursor = { 1, 5 },
    })
    feedkeys("die")
    expect({
      content = "(a )",
      cursor = { 1, 3 },
    })
  end)
end)

describe("element selections", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  before_each(function()
    keybindings.setup_keybindings({
      keys = defaults.default_keys,
    })
  end)

  it("should select the element", function()
    prepare_buffer({
      content = "(a :a/b)",
      cursor = { 1, 5 },
    })
    feedkeys("vie")
    assert.are.same(":a/b", utils.get_selected_text())
  end)
end)
