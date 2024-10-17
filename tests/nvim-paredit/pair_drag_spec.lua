local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("pair dragging ::", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  describe("paired-element-auto-dragging", function()
    vim.api.nvim_set_option_value("filetype", "clojure", {
      buf = 0,
    })
    it("should drag map pairs forward", function()
      prepare_buffer({
        content = "{:a 1 :b 2}",
        cursor = { 1, 1 },
      })

      paredit.drag_element_forwards({
        dragging = {
          auto_drag_pairs = true,
        },
      })
      expect({
        content = "{:b 2 :a 1}",
        cursor = { 1, 6 },
      })
    end)

    it("should drag map pairs backwards", function()
      prepare_buffer({
        content = "{:a 1 :b 2}",
        cursor = { 1, 9 },
      })

      paredit.drag_element_backwards({
        dragging = {
          auto_drag_pairs = true,
        },
      })
      expect({
        content = "{:b 2 :a 1}",
        cursor = { 1, 1 },
      })
    end)

    it("should stop dragging at pair boundaries", function()
      prepare_buffer({
        "{:entity {|:a 1 :b 2}}",
      })
      paredit.drag_element_backwards({
        dragging = {
          auto_drag_pairs = true,
        },
      })
      expect({
        "{:entity {|:a 1 :b 2}}",
      })
    end)

    it("should detect various types", function()
      expect_all(function()
        paredit.drag_element_forwards({ dragging = { auto_drag_pairs = true } })
      end, {
        {
          "let binding",
          before_content = "(let [a b c d])",
          before_cursor = { 1, 6 },
          after_content = "(let [c d a b])",
          after_cursor = { 1, 10 },
        },
        {
          "loop binding",
          before_content = "(loop [a b c d])",
          before_cursor = { 1, 7 },
          after_content = "(loop [c d a b])",
          after_cursor = { 1, 11 },
        },
        {
          "case",
          before_content = "(case a :a 1 :b 2)",
          before_cursor = { 1, 8 },
          after_content = "(case a :b 2 :a 1)",
          after_cursor = { 1, 13 },
        },
      })
    end)
  end)

  describe("paired-element-dragging", function()
    vim.api.nvim_set_option_value("filetype", "clojure", {
      buf = 0,
    })
    it("should drag vector elements forwards", function()
      prepare_buffer({
        content = "'[a b c d]",
        cursor = { 1, 2 },
      })

      paredit.drag_pair_forwards()
      expect({
        content = "'[c d a b]",
        cursor = { 1, 6 },
      })
    end)
  end)
end)
