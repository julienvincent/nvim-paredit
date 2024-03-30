local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("barfing ::", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")

  describe("barfing forwards", function()
    it("should barf different form types -", function()
      expect_all(paredit.barf_forwards, {
        {
          "list",
          before_content = "(a)",
          before_cursor = { 1, 1 },
          after_content = "()a",
          after_cursor = { 1, 1 },
        },
        {
          "vector",
          before_content = "[a]",
          before_cursor = { 1, 1 },
          after_content = "[]a",
          after_cursor = { 1, 1 },
        },
        {
          "quoted list",
          before_content = "`(a)",
          before_cursor = { 1, 2 },
          after_content = "`()a",
          after_cursor = { 1, 2 },
        },
        {
          "quoted list",
          before_content = "'(a)",
          before_cursor = { 1, 2 },
          after_content = "'()a",
          after_cursor = { 1, 2 },
        },
        {
          "anon fn",
          before_content = "#(a)",
          before_cursor = { 1, 2 },
          after_content = "#()a",
          after_cursor = { 1, 2 },
        },
        {
          "set",
          before_content = "#{a}",
          before_cursor = { 1, 2 },
          after_content = "#{}a",
          after_cursor = { 1, 2 },
        },
        {
          "reader conditional",
          before_content = "#?{:cljs a :clj b}",
          before_cursor = { 1, 3 },
          after_content = "#?{:cljs a :clj} b",
          after_cursor = { 1, 3 },
        }
      })
    end)

    it("should skip comments", function()
      prepare_buffer({
        content = { "(", ";; comment", "a)" },
        cursor = { 1, 1 },
      })
      paredit.barf_forwards()
      expect({
        content = { "()", ";; comment", "a" },
        cursor = { 1, 0 },
      })

      prepare_buffer({
        content = { "(a ;; comment", ")" },
        cursor = { 1, 1 },
      })
      paredit.barf_forwards()
      expect({
        content = "()a ;; comment",
        cursor = { 1, 1 },
      })
    end)

    it("should do nothing in an empty form", function()
      prepare_buffer({
        content = "()",
        cursor = { 1, 1 },
      })
      paredit.barf_forwards()
      expect({
        content = "()",
        cursor = { 1, 1 },
      })
    end)

    it("should do nothing in the document root", function()
      expect_all(paredit.barf_forwards, {
        {
          "from root",
          before_content = { "(a)", "" },
          before_cursor = { 2, 0 },
          after_content = { "(a)", "" },
          after_cursor = { 2, 0 },
        },
        {
          "from another list",
          before_content = { "(a)", "()" },
          before_cursor = { 2, 1 },
          after_content = { "(a)", "()" },
          after_cursor = { 2, 1 },
        },
      })
    end)

    it("should recursively barf the next sibling", function()
      expect_all(paredit.barf_forwards, {
        {
          "double nested list",
          before_content = "(() a)",
          before_cursor = { 1, 2 },
          after_content = "(()) a",
          after_cursor = { 1, 2 },
        },
        {
          "list with quoted list",
          before_content = "('())",
          before_cursor = { 1, 3 },
          after_content = "()'()",
          after_cursor = { 1, 1 },
        },
      })
    end)

    it("should move the cursor if out of bounds", function()
      local function barf_with_behaviour()
        paredit.barf_forwards({ cursor_behaviour = "auto" })
      end

      expect_all(barf_with_behaviour, {
        {
          "single line",
          before_content = "(aa bb)",
          before_cursor = { 1, 5 },
          after_content = "(aa) bb",
          after_cursor = { 1, 3 }
        },
        {
          "multi line",
          before_content = { "(aa", "bb)" },
          before_cursor = { 2, 1 },
          after_content = { "(aa)", "bb" },
          after_cursor = { 1, 3 }
        }
      })
    end)

    it("should always move the cursor", function()
      local function barf_with_behaviour()
        paredit.barf_forwards({ cursor_behaviour = "follow" })
      end

      expect_all(barf_with_behaviour, {
        {
          "single line",
          before_content = "(aa bb cc)",
          before_cursor = { 1, 4 },
          after_content = "(aa bb) cc",
          after_cursor = { 1, 6 }
        },
        {
          "multi line",
          before_content = { "(aa", "bb", "cc)" },
          before_cursor = { 1, 1 },
          after_content = { "(aa", "bb)", "cc" },
          after_cursor = { 2, 2 }
        }
      })
    end)
  end)

  describe("barfing backwards", function()
    it("should barf different form types -", function()
      expect_all(paredit.barf_backwards, {
        {
          "list",
          before_content = "(a)",
          before_cursor = { 1, 1 },
          after_content = "a()",
          after_cursor = { 1, 2 },
        },
        {
          "vector",
          before_content = "[a]",
          before_cursor = { 1, 1 },
          after_content = "a[]",
          after_cursor = { 1, 2 },
        },
        {
          "quoted list",
          before_content = "`(a)",
          before_cursor = { 1, 2 },
          after_content = "a`()",
          after_cursor = { 1, 3 },
        },
        {
          "quoted list",
          before_content = "'(a)",
          before_cursor = { 1, 2 },
          after_content = "a'()",
          after_cursor = { 1, 3 },
        },
        {
          "anon fn",
          before_content = "#(a)",
          before_cursor = { 1, 2 },
          after_content = "a#()",
          after_cursor = { 1, 3 },
        },
        {
          "set",
          before_content = "#{a}",
          before_cursor = { 1, 2 },
          after_content = "a#{}",
          after_cursor = { 1, 3 },
        },
      })
    end)

    it("should skip comments", function()
      prepare_buffer({
        content = { "(", ";; comment", "a)" },
        cursor = { 1, 1 },
      })
      paredit.barf_backwards()
      expect({
        content = { "", ";; comment", "a()" },
        cursor = { 3, 1 },
      })

      prepare_buffer({
        content = { "(a ;; comment", ")" },
        cursor = { 1, 1 },
      })
      paredit.barf_backwards()
      expect({
        content = {"a ;; comment", "()"},
        cursor = { 2, 0 },
      })
    end)

    it("should do nothing in an empty form", function()
      prepare_buffer({
        content = "()",
        cursor = { 1, 1 },
      })
      paredit.barf_backwards()
      expect({
        content = "()",
        cursor = { 1, 1 },
      })
    end)

    it("should do nothing in the document root", function()
      expect_all(paredit.barf_backwards, {
        {
          "from root",
          before_content = { "(a)", "" },
          before_cursor = { 2, 0 },
          after_content = { "(a)", "" },
          after_cursor = { 2, 0 },
        },
        {
          "from another list",
          before_content = { "(a)", "()" },
          before_cursor = { 2, 1 },
          after_content = { "(a)", "()" },
          after_cursor = { 2, 1 },
        },
      })
    end)

    it("should recursively barf the next sibling in a", function()
      expect_all(paredit.barf_backwards, {
        {
          "double nested list",
          before_content = "(a ())",
          before_cursor = { 1, 4 },
          after_content = "a (())",
          after_cursor = { 1, 4 },
        },
        {
          "list with quoted list",
          before_content = "('())",
          before_cursor = { 1, 3 },
          after_content = "'()()",
          after_cursor = { 1, 4 },
        },
      })
    end)

    it("should move the cursor if out of bounds", function()
      local function barf_with_behaviour()
        paredit.barf_backwards({ cursor_behaviour = "auto" })
      end

      expect_all(barf_with_behaviour, {
        {
          "single line",
          before_content = "(aa bb)",
          before_cursor = { 1, 1 },
          after_content = "aa (bb)",
          after_cursor = { 1, 4 }
        },
        {
          "multi line",
          before_content = { "(aa", "bb)" },
          before_cursor = { 1, 1 },
          after_content = { "aa", "(bb)" },
          after_cursor = { 2, 0 }
        }
      })
    end)

    it("should always move the cursor", function()
      local function barf_with_behaviour()
        paredit.barf_backwards({ cursor_behaviour = "follow" })
      end

      expect_all(barf_with_behaviour, {
        {
          "single line",
          before_content = "(aa bb cc)",
          before_cursor = { 1, 1 },
          after_content = "aa (bb cc)",
          after_cursor = { 1, 4 }
        },
        {
          "multi line",
          before_content = { "(aa", "bb", "cc)" },
          before_cursor = { 1, 1 },
          after_content = { "aa", "(bb", "cc)" },
          after_cursor = { 2, 0 }
        }
      })
    end)
  end)
end)
