local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("motions", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")

  it("should jump to next element in form", function()
    prepare_buffer({
      content = "(aa (bb) @(cc) #{1})",
      cursor = { 1, 2 },
    })

    paredit.move_to_next_element()
    expect({
      cursor = { 1, 7 },
    })
    paredit.move_to_next_element()
    expect({
      cursor = { 1, 13 },
    })
    paredit.move_to_next_element()
    expect({
      cursor = { 1, 18 },
    })
    paredit.move_to_next_element()
    expect({
      cursor = { 1, 18 },
    })
  end)

  it("should jump to previous element in form", function()
    prepare_buffer({
      content = "(aa (bb) '(cc))",
      cursor = { 1, 9 },
    })

    paredit.move_to_prev_element()
    expect({
      cursor = { 1, 4 },
    })
    paredit.move_to_prev_element()
    expect({
      cursor = { 1, 1 },
    })
    paredit.move_to_prev_element()
    expect({
      cursor = { 1, 1 },
    })
  end)

  it("should skip comments", function()
    prepare_buffer({
      content = { "(aa", ";; comment", "bb)" },
      cursor = { 1, 2 },
    })
    paredit.move_to_next_element()
    expect({
      cursor = { 3, 1 },
    })
    paredit.move_to_prev_element()
    expect({
      cursor = { 3, 0 },
    })
    paredit.move_to_prev_element()
    expect({
      cursor = { 1, 1 },
    })
  end)

  it("should stay on the same form is cursor is in the middle before jumping to next form", function()
    prepare_buffer({
      content = { "(12345", "789)" },
      cursor = { 1, 3 },
    })
    paredit.move_to_next_element()
    expect({
      cursor = { 1, 5 },
    })
    paredit.move_to_next_element()
    expect({
      cursor = { 2, 2 },
    })
    paredit.move_to_next_element()
    expect({
      cursor = { 2, 2 },
    })
  end)

  it("should stay on the same form is cursor is in the middle before jumping to prev form", function()
    prepare_buffer({
      content = { "(12345", "789)" },
      cursor = { 2, 1 },
    })
    paredit.move_to_prev_element()
    expect({
      cursor = { 2, 0 },
    })
    paredit.move_to_prev_element()
    expect({
      cursor = { 1, 1 },
    })
    paredit.move_to_prev_element()
    expect({
      cursor = { 1, 1 },
    })
  end)
end)
