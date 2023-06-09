local M = {}

function M.prepareBuffer(params)
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')

  local content = params.content
  if type(content) == "string" then
    content = { content }
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, true, content)
  vim.api.nvim_win_set_cursor(0, params.cursor)
  vim.treesitter.get_parser(0):parse()
end

function M.expect(params)
  if params.content then
    if type(params.content) == "table" then
      assert.are.same(params.content, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    else
      assert.are.same(params.content, vim.api.nvim_buf_get_lines(0, 0, -1, false)[1])
    end
  end

  if params.cursor then
    assert.are.same(params.cursor, vim.api.nvim_win_get_cursor(0))
  end
end

return M
