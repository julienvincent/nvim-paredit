local paredit = require("nvim-paredit")
local ts = require("nvim-treesitter.ts_utils")
local prepare_buffer = require("tests.nvim-paredit.utils").prepare_buffer

describe("cursor pos api tests", function()
  vim.api.nvim_set_option_value("filetype", "clojure", {
    buf = 0,
  })

  it("should place cursor inside form at the beginning", function()
    prepare_buffer({
      "|(a (b))",
    })

    local cursor_pos = paredit.cursor.get_cursor_pos({ 0, 0, 0, 6 }, { placement = "inner_start" })

    assert.are.same({ 1, 1 }, cursor_pos)

    local node = ts.get_node_at_cursor()
    cursor_pos = paredit.cursor.get_cursor_pos(node, { placement = "inner_start" })

    assert.are.same({ 1, 1 }, cursor_pos)
  end)

  it("should place cursor outside form at the beginning", function()
    prepare_buffer({
      "|(a (b))",
    })

    local cursor_pos = paredit.cursor.get_cursor_pos({ 0, 0, 0, 6 }, { placement = "left_edge" })

    assert.are.same({ 1, 0 }, cursor_pos)

    local node = ts.get_node_at_cursor()
    cursor_pos = paredit.cursor.get_cursor_pos(node, { placement = "left_edge" })

    assert.are.same({ 1, 0 }, cursor_pos)
  end)

  it("should place cursor inside form at the end", function()
    prepare_buffer({
      "|(a ",
      " (b))",
    })

    local cursor_pos = paredit.cursor.get_cursor_pos({ 0, 0, 1, 4 }, { placement = "inner_end" })

    assert.are.same({ 2, 4 }, cursor_pos)

    local node = ts.get_node_at_cursor()
    cursor_pos = paredit.cursor.get_cursor_pos(node, { placement = "inner_end" })

    assert.are.same({ 2, 4 }, cursor_pos)
  end)

  it("should place cursor outside form at the end", function()
    prepare_buffer({
      "|(a ",
      " (b))",
    })

    local cursor_pos = paredit.cursor.get_cursor_pos({ 0, 0, 1, 4 }, { placement = "right_edge" })

    assert.are.same({ 2, 5 }, cursor_pos)

    local node = ts.get_node_at_cursor()
    cursor_pos = paredit.cursor.get_cursor_pos(node, { placement = "right_edge" })

    assert.are.same({ 2, 5 }, cursor_pos)
  end)
end)
