local paredit = require("nvim-paredit")
local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("form uwrap (e.g. splice)", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })
  local unwrap = paredit.unwrap

  it("should uwrap list under cursor", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 0 },
    })

    unwrap.unwrap_form_under_cursor()
    expect({
      content = { "+ 2 :foo/bar" },
    })
  end)

  it("should uwrap list under cursor", function()
    prepare_buffer({
      content = { "(+ 2 :foo/bar)" },
      cursor = { 1, 13 },
    })

    unwrap.unwrap_form_under_cursor()
    expect({
      content = { "+ 2 :foo/bar" },
    })
  end)

  it("should uwrap set under cursor", function()
    prepare_buffer({
      content = { "#{1 2 3}" },
      cursor = { 1, 4 },
    })

    unwrap.unwrap_form_under_cursor()
    expect({
      content = { "1 2 3" },
    })
  end)

  it("should uwrap fn under cursor", function()
    prepare_buffer({
      content = { "#(+ % 2 3)" },
      cursor = { 1, 4 },
    })

    unwrap.unwrap_form_under_cursor()
    expect({
      content = { "+ % 2 3" },
    })
  end)

  it("should uwrap reader conditionsl under cursor", function()
    prepare_buffer({
      content = { "#?(:clj :foo/bar)" },
      cursor = { 1, 10 },
    })

    unwrap.unwrap_form_under_cursor()
    expect({
      content = { ":clj :foo/bar" },
    })
  end)
end)
