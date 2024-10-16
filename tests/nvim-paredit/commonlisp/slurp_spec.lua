local paredit = require("nvim-paredit.api")

local expect_all = require("tests.nvim-paredit.utils").expect_all
local expect = require("tests.nvim-paredit.utils").expect

describe("commonlisp slurping ::", function()
  vim.api.nvim_set_option_value("filetype", "lisp", {
    buf = 0,
  })

  describe("slurping backwards", function()
    it("should slurp different form types", function()
      expect_all(paredit.slurp_backwards, {
        {
          "list",
          { "a (|)" },
          { "(a |)" },
        },
        {
          "vector",
          { "a |#()" },
          { "#(|a )" },
        },
      })
    end)

    it("should skip comments", function()
      expect(
        {
          "a",
          ";; comment",
          "|()",
        },
        paredit.slurp_backwards,
        {
          "(a",
          ";; comment",
          "|)",
        }
      )
    end)
  end)

  describe("slurping forward", function()
    it("should slurp forward different form types", function()
      expect_all(paredit.slurp_forwards, {
        {
          "list",
          { "(|) a" },
          { "(| a)" },
        },
        {
          "vector",
          { "#|() a" },
          { "#|( a)" },
        },
        {
          "lambda",
          { "(l|ambda (a b)) a" },
          { "(l|ambda (a b) a)" },
        },
        {
          "lambda params inner",
          { "(lambda (a b|) a)" },
          { "(lambda (a b| a))" },
        },
        {
          "lambda params outer",
          { "(lambda (a b|)) a" },
          { "(lambda (a b|) a)" },
        },
        {
          "loop",
          { "(loop for i from 1 to 10 do", "  (print |i)) a" },
          { "(loop for i from 1 to 10 do", "  (print |i) a)" },
        },
      })
    end)

    it("should skip comments", function()
      expect(
        {
          "(|)",
          ";; comment",
          "a",
        },
        paredit.slurp_forwards,
        {
          "|(",
          ";; comment",
          "a)",
        }
      )
    end)
  end)
end)
