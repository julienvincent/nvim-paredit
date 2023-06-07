local M = {}

function M.prepareBuffer(params)
  vim.api.nvim_buf_set_option(0, 'filetype', 'clojure')
  vim.api.nvim_buf_set_lines(0, 0, -1, true, vim.fn.split(params.content, '\n'))
  vim.api.nvim_win_set_cursor(0, params.cursor)
  vim.treesitter.get_parser(0):parse()
end

function M.expect(params)
  assert.are.same(params.content, vim.api.nvim_buf_get_lines(0, 0, -1, false)[1])
  assert.are.same(params.cursor, vim.api.nvim_win_get_cursor(0))
end

return M
