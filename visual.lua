yes_no_prompt = function(prompt)
  local responce = vim.fn.input(prompt .. [[ [yes/no]: ]])
  local ret
  while not (ret == true or ret == false) do
    if responce == 'yes' or responce == 'y' then
      ret = true
    elseif responce == 'no' or responce == 'n' then
      ret = false
    else
      responce = vim.fn.input(prompt .. [[ [yes/no]: ]])
    end
  end
  return ret
end

popup_menu_create = function(list)
  popup_buf = vim.api.nvim_create_buf(true, true)
  local win_parameters = {
    relative = 'win',
    row = 3,
    col = 3,
    width = 74,
    height = 40,
    style = 'minimal',
    border = 'rounded',
    noautocmd = true,
  }
  popup_win = vim.api.nvim_open_win(popup_buf, true, win_parameters)
  vim.api.nvim_buf_set_lines(popup_buf, 0, -1, false, list)
  window_type = "popup_menu"
end

create_virtual_text = function(text, line, col, hl_type)
  local lines = {}
  for i = 1, #text, 1 do
    table.insert(lines, {{text[i], hl_type}})
  end
  local opts = {
    id = 1,
    virt_lines = lines,
    virt_lines_above = true,
  }
  ns[1][line] = vim.api.nvim_create_namespace(tostring(line))
  ns[2][line] = vim.api.nvim_buf_set_extmark(0, ns[1][line], line, col, opts)
end

expand_note = function()
  local lines = {}
  for line in io.lines(vim.fn.expand([[<cword>]]) .. "/_") do
    lines[#lines + 1] = line
  end
  create_virtual_text(lines, vim.fn.getcurpos()[2], vim.fn.getcurpos()[1], '')
end

collapse_note = function()
  vim.api.nvim_buf_del_extmark(0, ns[1][vim.fn.getcurpos()[2]], ns[2][vim.fn.getcurpos()[2]])
end

expand_all_notes = function()
  --vim.fn.search('*\\([a-z]\\|_\\)\\**', 'cn')
  --vim.cmd.normal([[/*\\([a-z]\\|_\\)\\**]])
  --local count = vim.fn.searchcount({recompute = 1})
  for i = 1, 99, 1 do
    vim.fn.search('*\\([a-z]\\|_\\)\\**')
    expand_note()
  end
end

collapse_all_notes = function()
  --vim.fn.search('*\\([a-z]\\|_\\)\\**', 'cn')
  --vim.cmd.normal([[/*\\([a-z]\\|_\\)\\**]])
  --local count = vim.fn.searchcount({recompute = 1})
  for i = 1, 99, 1 do
    vim.fn.search('*\\([a-z]\\|_\\)\\**')
    collapse_note()
  end
end

add_header = function()
  local path = vim.fn.expand('%:p:h')
  local file = vim.fn.expand('%')
  local lines = {}
  for line in io.lines(file) do
    table.insert(lines, line)
  end
  local is_first_line_empty = #lines[1] == 0
  if not is_first_line_empty then
    local pos = vim.fn.getcurpos()
    vim.cmd.normal('ggO')
    vim.fn.setpos('.', pos)
    vim.cmd.normal('j')
  end
  local text = {
    path,
    '',
    vim.fn.expand("%:p:h:t"),
    '',
  }
  create_virtual_text(text, 1, 0, 'Comment')
end

remove_virtual_text = function()
  --vim.api.nvim_buf_del_extmark(0, ns[1][1], ns[2][1])
  if ns[1][1] and ns[2][1] then
    vim.api.nvim_buf_del_extmark(0, ns[1][1], ns[2][1])
  end
  print(ns[2][1])
end

add_extras = function()
  add_header()
end

remove_extras = function()
  remove_virtual_text()
end
