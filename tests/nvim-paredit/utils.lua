local M = {}

local function escape_keys(keys)
  return vim.api.nvim_replace_termcodes(keys, true, false, true)
end

function M.feedkeys(keys)
  vim.api.nvim_feedkeys(escape_keys(keys), "xmt", true)
end

local function extract_cursor_from_content(content)
  for i, line in ipairs(content) do
    local cursor_index = line:find("|")
    if cursor_index then
      local modified_content = vim.deepcopy(content)
      modified_content[i] = line:sub(1, cursor_index - 1) .. line:sub(cursor_index + 1)
      local cursor = { i, cursor_index - 1 }
      return cursor, modified_content
    end
  end
  return nil, content
end

function M.prepare_buffer(params)
  local content = params.content or params
  if type(content) == "string" then
    content = vim.split(content, "\n")
  end

  local cursor
  cursor, content = extract_cursor_from_content(content)

  cursor = params.cursor or cursor

  vim.api.nvim_buf_set_lines(0, 0, -1, true, content)
  if cursor then
    vim.api.nvim_win_set_cursor(0, cursor)
  end
  vim.treesitter.get_parser(0):parse()
end

function M.expect(before, action, after)
  if not action and not after then
    after = before
    before = nil
  end

  if before then
    M.prepare_buffer(before)
  end

  if action then
    action()
  end

  local content = after.content or after
  if type(content) == "string" then
    content = { content }
  end

  local cursor
  cursor, content = extract_cursor_from_content(content)

  cursor = after.cursor or cursor

  if #content > 0 then
    assert.are.same(content, vim.api.nvim_buf_get_lines(0, 0, -1, false))
  end

  if cursor then
    assert.are.same(cursor, vim.api.nvim_win_get_cursor(0))
  end
end

function M.expect_all(action, expectations)
  for _, fixture in pairs(expectations) do
    it(fixture[1], function()
      if fixture[2] then
        M.prepare_buffer(fixture[2])
      else
        M.prepare_buffer({
          content = fixture.before_content,
          cursor = fixture.before_cursor,
        })
      end
      if fixture.action then
        fixture.action()
      else
        action()
      end

      if fixture[3] then
        M.expect(fixture[3])
      else
        M.expect({
          content = fixture.after_content,
          cursor = fixture.after_cursor,
        })
      end

      vim.treesitter.get_parser(0):parse()
    end)
  end
end

function M.get_selected_text()
  vim.cmd('noau normal! "vy"')
  return vim.fn.getreg("v")
end

return M
