local paredit = require("nvim-paredit")
local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("form and element wrap ::", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  it("should not wrap if cursor is whitespace", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 4 },
    })

    local range = paredit.wrap.wrap_element_under_cursor("(", ")")
    assert.falsy(range)
    expect({
      content = { "(+ 2 :foo/bar)" },
    })
  end)

  it("should wrap namespaced keyword", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 7 },
    })

    local range = paredit.wrap.wrap_element_under_cursor("(", ")")
    assert.are.same({ 0, 5, 0, 14 }, range)
    expect({
      content = { "(+ 2 (:foo/bar))" },
    })
  end)

  it("should wrap top level form", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 0 },
    })

    local range = paredit.wrap.wrap_element_under_cursor("(", ")")
    assert.are.same({ 0, 0, 0, 15 }, range)
    expect({
      content = { "((+ 2 :foo/bar))" },
    })
  end)

  it("should wrap namespaced keyword", function()
    prepare_buffer({
      content = { "(+ 2 :foo/lol)" },
      cursor = { 1, 7 },
    })

    local range = paredit.wrap.wrap_element_under_cursor("(", ")")
    assert.are.same({ 0, 5, 0, 14 }, range)
    expect({
      content = { "(+ 2 (:foo/lol))" },
    })
  end)

  it("should wrap enclosing form", function()
    prepare_buffer({
      content = {
        "(+ 2",
        " :foo/bar)",
      },
      cursor = { 2, 4 },
    })

    local range = paredit.wrap.wrap_enclosing_form_under_cursor("(", ")")
    assert.are.same({ 0, 0, 1, 10 }, range)
    expect({
      content = {
        "((+ 2",
        " :foo/bar))",
      },
    })
  end)

  it("should fallback to current form if parent is source", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 0 },
    })

    local range = paredit.wrap.wrap_enclosing_form_under_cursor("(", ")")
    assert.are.same({ 0, 0, 0, 15 }, range)
    expect({
      content = { "((+ 2 :foo/bar))" },
    })
  end)

  it("should wrap enclosing form if cursor is whitespace/comment", function()
    prepare_buffer({
      content = {
        "(+ 2",
        ";; foo",
        " :foo/bar)",
      },
      cursor = { 2, 4 },
    })

    local range = paredit.wrap.wrap_enclosing_form_under_cursor("(", ")")
    assert.are.same({ 0, 0, 2, 10 }, range)
    expect({
      content = {
        "((+ 2",
        ";; foo",
        " :foo/bar))",
      },
    })
  end)
end)
