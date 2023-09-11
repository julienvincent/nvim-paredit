local defaults = require("nvim-paredit.defaults")
local paredit = require("nvim-paredit.api")

local expect_all = require("tests.nvim-paredit.utils").expect_all

local opts = vim.tbl_deep_extend("force", defaults.defaults, {
  indent = {
    enabled = true,
  },
})

describe("forward slurping indentation", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")
  local function slurp_forwards()
    paredit.slurp_forwards(opts)
  end

  expect_all(slurp_forwards, {
    {
      "should indent a nested child",
      before_content = { "()", "a" },
      before_cursor = { 1, 1 },
      after_content = { "(", " a)" },
      after_cursor = { 1, 0 },
    },
    {
      "should indent a nested child from a wrapped parent",
      before_content = { "@()", "a" },
      before_cursor = { 1, 2 },
      after_content = { "@(", "  a)" },
      after_cursor = { 1, 1 },
    },
    {
      "should indent a multi-line child",
      before_content = { "()", "(a", " b c)" },
      before_cursor = { 1, 1 },
      after_content = { "(", " (a", "  b c))" },
      after_cursor = { 1, 0 },
    },
    {
      "should indent a multi-line child that pushes other nodes",
      before_content = { "()", "(a", " b) (c", "d) (e", "f)" },
      before_cursor = { 1, 1 },
      after_content = { "(", " (a", "  b)) (c", " d) (e", " f)" },
      after_cursor = { 1, 0 },
    },
    {
      "should not indent if node is not first on line",
      before_content = { "(", "a) (a", "b)" },
      before_cursor = { 1, 1 },
      after_content = { "(", "a (a", "b))" },
      after_cursor = { 1, 0 },
    },
    {
      "should not indent when on same line",
      before_content = "() 1",
      before_cursor = { 1, 1 },
      after_content = "( 1)",
      after_cursor = { 1, 1 },
    },
    {
      "should dedent when node is too far indented",
      before_content = { "()", "  a" },
      before_cursor = { 1, 1 },
      after_content = { "(", " a)" },
      after_cursor = { 1, 0 },
    },
    {
      "should dedent without deleting characters",
      before_content = { "()", "   (a", " b)" },
      before_cursor = { 1, 1 },
      after_content = { "(", "  (a", "b))" },
      after_cursor = { 1, 0 },
    },
    {
      "should indent the correct node ignoring comments",
      before_content = { "()", ";; comment", "a" },
      before_cursor = { 1, 1 },
      after_content = { "(", ";; comment", " a)" },
      after_cursor = { 1, 0 },
    },

    {
      "should indent to the first relevant siblings indentation",
      before_content = { "(def a []", "  target sibling)", "child" },
      before_cursor = { 1, 1 },
      after_content = { "(def a []", "  target sibling", "  child)" },
      after_cursor = { 1, 1 },
    },
  })
end)

describe("backward slurping indentation", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")
  local function slurp_backwards()
    paredit.slurp_backwards(opts)
  end

  expect_all(slurp_backwards, {
    {
      "should indent a nested child",
      before_content = { "a", "(b)" },
      before_cursor = { 2, 1 },
      after_content = { "(a", " b)" },
      after_cursor = { 2, 2 },
    },
    {
      "should not indent when on same line",
      before_content = { "a (b)" },
      before_cursor = { 1, 3 },
      after_content = { "(a b)" },
      after_cursor = { 1, 3 },
    },
  })
end)

describe("forward barfing indentation", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")
  local function barf_forwards()
    paredit.barf_forwards(opts)
  end

  expect_all(barf_forwards, {
    {
      "should dedent the barfed child",
      before_content = { "(", " a)" },
      before_cursor = { 1, 0 },
      after_content = { "()", "a" },
      after_cursor = { 1, 0 },
    },
    {
      "should dedent the barfed child from a wrapped parent",
      before_content = { "@(", "  a)" },
      before_cursor = { 1, 1 },
      after_content = { "@()", "a" },
      after_cursor = { 1, 1 },
    },
    {
      "should dedent a multi-line child and affected siblings",
      before_content = { "(", " (a", "  b c)) (a", " d)" },
      before_cursor = { 1, 0 },
      after_content = { "()", "(a", " b c) (a", "d)" },
      after_cursor = { 1, 0 },
    },
    {
      "should not dedent if node is on the same line",
      before_content = { "(a", "b c)" },
      before_cursor = { 1, 1 },
      after_content = { "(a", "b) c" },
      after_cursor = { 1, 1 },
    },
    {
      "should not dedent when there is no indentation",
      before_content = { "(", "a)" },
      before_cursor = { 1, 0 },
      after_content = { "()", "a" },
      after_cursor = { 1, 0 },
    },
    {
      "should dedent the minimum amount without deleting chars",
      before_content = { "(", "  a) (b", " c)" },
      before_cursor = { 1, 0 },
      after_content = { "()", " a (b", "c)" },
      after_cursor = { 1, 0 },
    },
    {
      "should dedent the correct node ignoring comments",
      before_content = { "(", ";; comment", " a)" },
      before_cursor = { 1, 1 },
      after_content = { "()", ";; comment", "a" },
      after_cursor = { 1, 0 },
    },

    {
      "should indent to the first relevant siblings indentation",
      before_content = { "(def a []", "  target (sibling", "          child))" },
      before_cursor = { 2, 10 },
      after_content = { "(def a []", "  target (sibling)", "  child)" },
      after_cursor = { 2, 10 },
    },
  })
end)

describe("backward barfing indentation", function()
  vim.api.nvim_buf_set_option(0, "filetype", "clojure")
  local function barf_backwards()
    paredit.barf_backwards(opts)
  end

  expect_all(barf_backwards, {
    {
      "should dedent a nested child",
      before_content = { "(a", " b)" },
      before_cursor = { 1, 0 },
      after_content = { "a", "(b)" },
      after_cursor = { 2, 0 },
    },
    {
      "should keep the cursor in the same place",
      before_content = { "((a", "  bc", "  de))" },
      before_cursor = { 2, 3 },
      after_content = { "(a", " (bc", " de))" },
      after_cursor = { 2, 3 },
    },

    {
      "should indent to the first relevant siblings indentation",
      before_content = { "(def a []", "  target (sibling", "          child))" },
      before_cursor = { 3, 1 },
      after_content = { "(def a []", "  target sibling", "  (child))" },
      after_cursor = { 3, 2 },
    },
  })
end)
