local paredit = require("nvim-paredit.api")

local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer
local expect = require("tests.nvim-paredit.utils").expect

describe("motions", function()
  vim.api.nvim_set_option_value("filetype", "scheme", {
    buf = 0,
  })

  it("should jump to next element in form (tail)", function()
    prepare_buffer({
      content = "(aa (bb) #(cc))",
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
      cursor = { 1, 13 },
    })
  end)

  it("should jump to next element in form (head)", function()
    prepare_buffer({
      content = "(aa (bb) #(cc))",
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
  end)
end)
