local paredit = require("nvim-paredit.api")
local internal_api = require("nvim-paredit.api.motions")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("motions", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")

  it("should jump to next element in form (tail)", function()
    prepare_buffer({
      content = "(aa (bb) @(cc) #{1})",
      cursor = { 1, 2 },
    })

    paredit.move_to_next_element_tail()
    expect({
      cursor = { 1, 7 },
    })

    paredit.move_to_next_element_tail()
    expect({
      cursor = { 1, 13 },
    })

    paredit.move_to_next_element_tail()
    expect({
      cursor = { 1, 18 },
    })

    paredit.move_to_next_element_tail()
    expect({
      cursor = { 1, 18 },
    })
  end)

  it("should jump to next element in form (head)", function()
    prepare_buffer({
      content = "(aa (bb) @(cc) #{1})",
      cursor = { 1, 2 },
    })

    paredit.move_to_next_element_head()
    expect({
      cursor = { 1, 4 },
    })

    paredit.move_to_next_element_head()
    expect({
      cursor = { 1, 9 },
    })

    paredit.move_to_next_element_head()
    expect({
      cursor = { 1, 15 },
    })

    paredit.move_to_next_element_head()
    expect({
      cursor = { 1, 15 },
    })
  end)

  it("should jump to previous element in form (head)", function()
    prepare_buffer({
      content = "(aa (bb) '(cc))",
      cursor = { 1, 9 },
    })

    paredit.move_to_prev_element_head()
    expect({
      cursor = { 1, 4 },
    })
    paredit.move_to_prev_element_head()
    expect({
      cursor = { 1, 1 },
    })
    paredit.move_to_prev_element_head()
    expect({
      cursor = { 1, 1 },
    })
  end)

  it("should jump to previous element in form (tail)", function()
    prepare_buffer({
      content = "(aa (bb) '(cc))",
      cursor = { 1, 9 },
    })

    paredit.move_to_prev_element_tail()
    expect({
      cursor = { 1, 7 },
    })
    paredit.move_to_prev_element_tail()
    expect({
      cursor = { 1, 2 },
    })
    paredit.move_to_prev_element_tail()
    expect({
      cursor = { 1, 2 },
    })
  end)

  it("should skip comments", function()
    prepare_buffer({
      content = { "(aa", ";; comment", "bb)" },
      cursor = { 1, 2 },
    })
    paredit.move_to_next_element_tail()
    expect({
      cursor = { 3, 1 },
    })
    paredit.move_to_prev_element_head()
    expect({
      cursor = { 3, 0 },
    })
    paredit.move_to_prev_element_head()
    expect({
      cursor = { 1, 1 },
    })
  end)

  it("make an extra motion if cursor is in comment", function()
    prepare_buffer({
      content = { "(aa", ";; comment", "bb)" },
      cursor = { 2, 3 },
    })
    paredit.move_to_next_element_tail()
    expect({
      cursor = { 3, 1 },
    })
    paredit.move_to_prev_element_head()
    expect({
      cursor = { 3, 0 },
    })
    paredit.move_to_prev_element_head()
    expect({
      cursor = { 1, 1 },
    })
    prepare_buffer({
      content = { "(aa", ";; comment", "bb)" },
      cursor = { 2, 3 },
    })
    paredit.move_to_prev_element_head()
    expect({
      cursor = { 1, 1 },
    })
  end)

  it("should move to the end of the current form before jumping to next", function()
    expect_all(paredit.move_to_next_element_tail, {
      {
        "same line",
        before_content = "(aaa bbb)",
        before_cursor = { 1, 2 },
        after_cursor = { 1, 3 },
      },
      {
        "multi line",
        before_content = { "((a", ") (b))" },
        before_cursor = { 1, 1 },
        after_cursor = { 2, 0 },
      },
    })
  end)

  it("should move to the start of the current form before jumping to previous", function()
    expect_all(paredit.move_to_prev_element_head, {
      {
        "same line",
        before_content = "(aaa bbb)",
        before_cursor = { 1, 7 },
        after_cursor = { 1, 5 },
      },
      {
        "multi line",
        before_content = { "((a) (", "b))" },
        before_cursor = { 2, 1 },
        after_cursor = { 1, 5 },
      },
    })
  end)

  it("should move to the next element even when on whitespace", function()
    expect_all(function() end, {
      {
        "forwards",
        before_content = "( bb)",
        before_cursor = { 1, 1 },
        after_cursor = { 1, 3 },
        action = paredit.move_to_next_element_tail,
      },
      {
        "forwards skipping comments",
        before_content = { "( ;; comment", "bb)" },
        before_cursor = { 1, 1 },
        after_cursor = { 2, 1 },
        action = paredit.move_to_next_element_tail,
      },
      {
        "forwards from no char",
        before_content = { "(bb", "", "cc)" },
        before_cursor = { 2, 0 },
        after_cursor = { 3, 1 },
        action = paredit.move_to_next_element_tail,
      },
      {
        "backwards",
        before_content = "(aa) (bb) ",
        before_cursor = { 1, 9 },
        after_cursor = { 1, 5 },
        action = paredit.move_to_prev_element_head,
      },
      {
        "backwards skipping comments",
        before_content = { "(aa ;; comment", " )" },
        before_cursor = { 2, 0 },
        after_cursor = { 1, 1 },
        action = paredit.move_to_prev_element_head,
      },
      {
        "backwards from no char",
        before_content = { "(bb", "", "cc)" },
        before_cursor = { 2, 0 },
        after_cursor = { 1, 1 },
        action = paredit.move_to_prev_element_head,
      },
    })
  end)

  it("should support v:count", function()
    prepare_buffer({
      content = "(aa (bb) @(cc) #{1})",
      cursor = { 1, 2 },
    })

    internal_api._move_to_element(2, false, false)
    expect({
      cursor = { 1, 13 },
    })

    internal_api.move_to_next_element_tail()
    expect({
      cursor = { 1, 18 },
    })

    internal_api.move_to_next_element_tail()
    expect({
      cursor = { 1, 18 },
    })

    internal_api._move_to_element(3, true, true)
    expect({
      cursor = { 1, 4 },
    })
  end)

  it("should move to parent form start", function()
    -- (aa (bb) @(|cc) #{1})
    prepare_buffer({
      content = "(aa (bb) @(cc) #{1})",
      cursor = { 1, 11 },
    })

    -- (aa (bb) @|(cc) #{1})
    internal_api.move_to_parent_form_start()
    expect({
      cursor = { 1, 10 },
    })

    -- (aa (bb) |@(cc) #{1})
    internal_api.move_to_parent_form_start()
    expect({
      cursor = { 1, 9 },
    })

    -- |(aa (bb) @(cc) #{1})
    internal_api.move_to_parent_form_start()
    expect({
      cursor = { 1, 0 },
    })

    -- |(aa (bb) @(cc) #{1})
    internal_api.move_to_parent_form_start()
    expect({
      cursor = { 1, 0 },
    })

  end)


  it("should move to parent form end", function()
    -- (aa (bb) |@(cc) #{1})
    prepare_buffer({
      content = "(aa (bb) @(cc) #{1})",
      cursor = { 1, 9 },
    })

    -- (aa (bb) @(cc|) #{1})
    internal_api.move_to_parent_form_end()
    expect({
      cursor = { 1, 13 },
    })

    -- (aa (bb) @(cc) #{1}|)
    internal_api.move_to_parent_form_end()
    expect({
      cursor = { 1, 19 },
    })

    -- (aa (bb) @(cc) #{1}|)
    internal_api.move_to_parent_form_end()
    expect({
      cursor = { 1, 19 },
    })

  end)
end)
