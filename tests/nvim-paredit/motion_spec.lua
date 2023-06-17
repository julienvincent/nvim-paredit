local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
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

  it("should move to the end of the current form before jumping to next", function()
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

  it("should move to the start of the current form before jumping to previous", function()
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

  it("should move to the next element even when on whitespace", function()
    expect_all(function() end, {
      {
        "forwards",
        before_content = "( bb)",
        before_cursor = { 1, 1 },
        after_cursor = { 1, 3 },
        action = paredit.move_to_next_element
      },
      {
        "backwards",
        before_content = "(aa  )",
        before_cursor = { 1, 4 },
        after_cursor = { 1, 1 },
        action = paredit.move_to_prev_element
      }
    })
  end)
end)
