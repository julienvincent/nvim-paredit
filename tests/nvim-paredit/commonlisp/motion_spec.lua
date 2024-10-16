local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("motions", function()
  vim.api.nvim_set_option_value("filetype", "lisp", {
    buf = 0,
  })

  it("should jump to next element in form (tail)", function()
    prepare_buffer({
      "(a|a (bb) #(cc))",
    })

    paredit.move_to_next_element_tail()
    expect({
      "(aa (bb|) #(cc))",
    })

    paredit.move_to_next_element_tail()
    expect({
      "(aa (bb) #(cc|))",
    })

    paredit.move_to_next_element_tail()
    expect({
      "(aa (bb) #(cc|))",
    })
  end)

  it("should jump to next element in form (head)", function()
    prepare_buffer({
      "(a|a (bb) #(cc))",
    })

    paredit.move_to_next_element_head()
    expect({
      "(aa |(bb) #(cc))",
    })

    paredit.move_to_next_element_head()
    expect({
      "(aa (bb) |#(cc))",
    })
  end)
end)
