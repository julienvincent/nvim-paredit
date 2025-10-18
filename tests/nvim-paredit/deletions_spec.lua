local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("form deletions ::", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  it("should delete the form", function()
    prepare_buffer({
      content = "(a)",
      cursor = { 1, 1 },
    })
    paredit.delete_form()
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
    paredit.delete_form()
    expect({
      content = "",
      cursor = { 1, 0 },
    })
  end)

  it("should delete a nested form", function()
    prepare_buffer({
      content = "(a (a b c))",
      cursor = { 1, 5 },
    })
    paredit.delete_form()
    expect({
      content = "(a)",
      cursor = { 1, 2 },
    })
  end)

  it("should delete different form types", function()
    expect_all(paredit.delete_form, {
      {
        "list",
        before_content = "(a)",
        before_cursor = { 1, 1 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "vector",
        before_content = "[a]",
        before_cursor = { 1, 1 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "quoted list",
        before_content = "`(a)",
        before_cursor = { 1, 2 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "quoted list",
        before_content = "'(a)",
        before_cursor = { 1, 2 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "anon fn",
        before_content = "#(a)",
        before_cursor = { 1, 2 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "set",
        before_content = "#{a}",
        before_cursor = { 1, 2 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
    })
  end)
end)

describe("form inner deletions ::", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  it("should delete everything in the form", function()
    prepare_buffer({
      content = "(a b)",
      cursor = { 1, 2 },
    })
    paredit.delete_in_form()
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
    paredit.delete_in_form()
    expect({
      content = "()",
      cursor = { 1, 1 },
    })
  end)

  it("should delete everyting within a nested form", function()
    prepare_buffer({
      content = "(a (a b c))",
      cursor = { 1, 5 },
    })
    paredit.delete_in_form()
    expect({
      content = "(a ())",
      cursor = { 1, 4 },
    })
  end)

  it("should delete within different form types", function()
    expect_all(paredit.delete_in_form, {
      {
        "list",
        before_content = "(a)",
        before_cursor = { 1, 1 },
        after_content = "()",
        after_cursor = { 1, 1 },
      },
      {
        "vector",
        before_content = "[a]",
        before_cursor = { 1, 1 },
        after_content = "[]",
        after_cursor = { 1, 1 },
      },
      {
        "quoted list",
        before_content = "`(a)",
        before_cursor = { 1, 2 },
        after_content = "`()",
        after_cursor = { 1, 2 },
      },
      {
        "quoted list",
        before_content = "'(a)",
        before_cursor = { 1, 2 },
        after_content = "'()",
        after_cursor = { 1, 2 },
      },
      {
        "anon fn",
        before_content = "#(a)",
        before_cursor = { 1, 2 },
        after_content = "#()",
        after_cursor = { 1, 2 },
      },
      {
        "set",
        before_content = "#{a}",
        before_cursor = { 1, 2 },
        after_content = "#{}",
        after_cursor = { 1, 2 },
      },
    })
  end)
end)

describe("element deletions ::", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  it("should delete the element under cursor", function()
    prepare_buffer({
      content = "(ab cd)",
      cursor = { 1, 4 },
    })
    paredit.delete_element()
    expect({
      content = "(ab )",
      cursor = { 1, 4 },
    })
  end)

  it("should delete different element types", function()
    expect_all(paredit.delete_element, {
      {
        "list",
        before_content = "(a)",
        before_cursor = { 1, 0 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "vector",
        before_content = "[a]",
        before_cursor = { 1, 0 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "quoted list",
        before_content = "`(a)",
        before_cursor = { 1, 0 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "quoted list",
        before_content = "'(a)",
        before_cursor = { 1, 0 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "anon fn",
        before_content = "#(a)",
        before_cursor = { 1, 0 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
      {
        "set",
        before_content = "#{a}",
        before_cursor = { 1, 0 },
        after_content = "",
        after_cursor = { 1, 0 },
      },
    })
  end)
end)
