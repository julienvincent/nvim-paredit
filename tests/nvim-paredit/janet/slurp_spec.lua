local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("slurping backwards", function()
  vim.api.nvim_set_option_value("filetype", "janet", {
    buf = 0,
  })

  it("should slurp different form types", function()
    expect_all(paredit.slurp_backwards, {
      {
        "tuple",
        before_content = "a ()",
        before_cursor = { 1, 3 },
        after_content = "(a )",
        after_cursor = { 1, 3 },
      },
      {
        "square tuple",
        before_content = "a []",
        before_cursor = { 1, 3 },
        after_content = "[a ]",
        after_cursor = { 1, 3 },
      },
      {
        "array",
        before_content = "a @[]",
        before_cursor = { 1, 2 },
        after_content = "@[a ]",
        after_cursor = { 1, 2 },
      },
      {
        "byte vector",
        before_content = "a @[]",
        before_cursor = { 1, 4 },
        after_content = "@[a ]",
        after_cursor = { 1, 4 },
      },
    })
  end)

  it("should skip comments", function()
    prepare_buffer({
      content = { "a", "# comment", "()" },
      cursor = { 3, 0 },
    })
    paredit.slurp_backwards()
    expect({
      content = { "(a", "# comment", ")" },
      cursor = { 3, 0 },
    })
  end)
end)

describe("slurping forward", function()
  vim.api.nvim_set_option_value("filetype", "janet", {
    buf = 0,
  })

  it("should slurp forward different form types", function()
    expect_all(paredit.slurp_forwards, {
      {
        "tuple",
        before_content = "() a",
        before_cursor = { 1, 1 },
        after_content = "( a)",
        after_cursor = { 1, 1 },
      },
      {
        "square tuple",
        before_content = "[] a",
        before_cursor = { 1, 1 },
        after_content = "[ a]",
        after_cursor = { 1, 1 },
      },
      {
        "array",
        before_content = "@[] a",
        before_cursor = { 1, 1 },
        after_content = "@[ a]",
        after_cursor = { 1, 1 },
      },
      {
        "struct",
        before_content = "{} a",
        before_cursor = { 1, 1 },
        after_content = "{ a}",
        after_cursor = { 1, 1 },
      },
      {
        "table",
        before_content = "@{} a",
        before_cursor = { 1, 2 },
        after_content = "@{ a}",
        after_cursor = { 1, 2 },
      },
    })
  end)

  it("should skip comments", function()
    prepare_buffer({
      content = { "()", "# comment", "a" },
      cursor = { 1, 1 },
    })
    paredit.slurp_forwards()
    expect({
      content = { "(", "# comment", "a)" },
      cursor = { 1, 0 },
    })
  end)
end)
