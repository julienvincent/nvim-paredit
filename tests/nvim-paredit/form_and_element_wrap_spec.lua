local paredit = require("nvim-paredit")
local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("element and form wrap", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")

  it("should not wrap if cursor is whitespace", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 4 },
    })

    paredit.form.wrap_element_under_cursor("(", ")")
    expect({
      content = { "(+ 2 :foo/bar)" },
    })
  end)

  it("should wrap namespaced keyword", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 7 },
    })

    paredit.form.wrap_element_under_cursor("(", ")")
    expect({
      content = { "(+ 2 (:foo/bar))" },
    })
  end)

  it("should wrap top level form", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 0 },
    })

    paredit.form.wrap_element_under_cursor("(", ")")
    expect({
      content = { "((+ 2 :foo/bar))" },
    })
  end)

  it("should wrap namespaced keyword", function()
    prepare_buffer({
      content = { '(+ 2 "lol")' },
      cursor = { 1, 7 },
    })

    paredit.form.wrap_element_under_cursor("(", ")")
    expect({
      content = { '(+ 2 ("lol"))' },
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

    paredit.form.wrap_enclosing_form_under_cursor("(", ")")
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

    paredit.form.wrap_enclosing_form_under_cursor("(", ")")
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

    paredit.form.wrap_enclosing_form_under_cursor("(", ")")
    expect({
      content = {
        "((+ 2",
        ";; foo",
        " :foo/bar))",
      },
    })
  end)
end)
