local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("barfing ::", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  describe("barfing forwards", function()
    it("should barf different form types -", function()
      expect_all(paredit.barf_forwards, {
        {
          "list",
          { "(|a)" },
          { "(|)a" },
        },
        {
          "vector",
          { "[|a]" },
          { "[|]a" },
        },
        {
          "quoted list",
          "`(|a)",
          { "`(|)a" },
        },
        {
          "quoted list",
          "'(|a)",
          "'(|)a",
        },
        {
          "anon fn",
          { "#(|a)" },
          { "#(|)a" },
        },
        {
          "set",
          "#{|a}",
          "#{|}a",
        },
        {
          "reader conditional",
          { "#?(|:cljs a :clj b)" },
          "#?(|:cljs a :clj) b",
        },
      })
    end)

    it("should skip comments", function()
      prepare_buffer({
        "(|",
        ";; comment",
        "a)",
      })
      paredit.barf_forwards()
      expect({
        "|()",
        ";; comment",
        "a",
      })

      prepare_buffer({
        "(|a ;; comment",
        ")",
      })
      paredit.barf_forwards()
      expect({
        "(|)a ;; comment",
        "",
      })
    end)

    it("should do nothing in an empty form", function()
      prepare_buffer({
        "(|)",
      })
      paredit.barf_forwards()
      expect({
        "(|)",
      })
    end)

    it("should do nothing in the document root", function()
      expect_all(paredit.barf_forwards, {
        {
          "from root",
          { "(a)", "|" },
          { "(a)", "|" },
        },
        {
          "from another list",
          { "(a)", "(|)" },
          { "(a)", "(|)" },
        },
      })
    end)

    it("should recursively barf the next sibling", function()
      expect_all(paredit.barf_forwards, {
        {
          "double nested list",
          "((|) a)",
          "((|)) a",
        },
        {
          "list with quoted list",
          { "('(|))" },
          { "(|)'()" },
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
          { "(aa b|b)" },
          "(aa|) bb",
        },
        {
          "multi line",
          { "(aa", "b|b)" },
          { "(aa|)", "bb" },
        },
      })
    end)

    it("should always move the cursor", function()
      local function barf_with_behaviour()
        paredit.barf_forwards({ cursor_behaviour = "follow" })
      end

      expect_all(barf_with_behaviour, {
        {
          "single line",
          { "(aa |bb cc)" },
          "(aa bb|) cc",
        },
        {
          "multi line",
          { "(|aa", "bb", "cc)" },
          { "(aa", "bb|)", "cc" },
        },
      })
    end)
  end)

  describe("barfing backwards", function()
    it("should barf different form types -", function()
      expect_all(paredit.barf_backwards, {
        {
          "list",
          { "(|a)" },
          { "a(|)" },
        },
        {
          "vector",
          { "[|a]" },
          { "a[|]" },
        },
        {
          "quoted list",
          { "`(|a)" },
          { "a`(|)" },
        },
        {
          "quoted list",
          { "'(|a)" },
          { "a'(|)" },
        },
        {
          "anon fn",
          { "#(|a)" },
          { "a#(|)" },
        },
        {
          "set",
          { "#{|a}" },
          { "a#{|}" },
        },
      })
    end)

    it("should skip comments", function()
      prepare_buffer({
        "(|",
        ";; comment",
        "a)",
      })
      paredit.barf_backwards()
      expect({
        "",
        ";; comment",
        "a|()",
      })

      prepare_buffer({
        "(|a ;; comment",
        ")",
      })
      paredit.barf_backwards()
      expect({
        "a ;; comment",
        "|()",
      })
    end)

    it("should do nothing in an empty form", function()
      prepare_buffer({
        "(|)",
      })
      paredit.barf_backwards()
      expect({
        "(|)",
      })
    end)

    it("should do nothing in the document root", function()
      expect_all(paredit.barf_backwards, {
        {
          "from root",
          { "(a)", "|" },
          { "(a)", "|" },
        },
        {
          "from another list",
          { "(a)", "(|)" },
          { "(a)", "(|)" },
        },
      })
    end)

    it("should recursively barf the next sibling in a", function()
      expect_all(paredit.barf_backwards, {
        {
          "double nested list",
          { "(a (|))" },
          { "a ((|))" },
        },
        {
          "list with quoted list",
          { "('(|))" },
          "'()(|)",
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
          { "(|aa bb)" },
          { "aa (|bb)" },
        },
        {
          "multi line",
          { "(|aa", "bb)" },
          { "aa", "|(bb)" },
        },
      })
    end)

    it("should always move the cursor", function()
      local function barf_with_behaviour()
        paredit.barf_backwards({ cursor_behaviour = "follow" })
      end

      expect_all(barf_with_behaviour, {
        {
          "single line",
          { "(|aa bb cc)" },
          { "aa (|bb cc)" },
        },
        {
          "multi line",
          { "(|aa", "bb", "cc)" },
          { "aa", "|(bb", "cc)" },
        },
      })
    end)
  end)
end)
