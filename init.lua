restore_path = function()
  local pathlist
  local path
  local file_exists = vim.fn.filereadable(cache_dir .. '/motion_history')
  local file_empty
  if file_exists > 0 then
    write_log("file_exists > 0")
    file_empty = #vim.fn.readfile(cache_dir .. '/motion_history') == 0
  end
  if file_exists > 0 and not file_empty then
    write_log("file_exists = true, file_empty == 0")
    pathlist = vim.fn.readfile(cache_dir .. '/motion_history')
    path = pathlist[#pathlist]
  else
    write_log("path = '/'")
    path = "/"
  end
  if path == "/" then
    path = root
  else
    path = root .. path
  end
  write_log("restore_path: " .. path)
  go_to_note(path)
end

init_keypress_handler = function()
  ns[3] = vim.api.nvim_create_namespace("Chooser_ns")
  window_type="regular_note"
  vim.on_key(function(key)
    if key == '\r' and window_type == 'popup_menu_text_search' then
      local res = choose_string()
      vim.api.nvim_win_close(0, true)
      vim.api.nvim_buf_delete(0, {force = true})
      window_type = 'regular_window'
      go_search_result(res)
    end
    if key == '\r' and window_type == 'popup_menu_file_search' then
      local res = choose_string()
      vim.api.nvim_win_close(0, true)
      vim.api.nvim_buf_delete(0, {force = true})
      window_type = 'regular_window'
      go_file_search_result(res)
    end
    if key == '\x1B' and vim.fn.match(window_type, 'popup_menu') >= 0 then
      vim.api.nvim_win_close(popup_win, true)
      vim.api.nvim_buf_delete(popup_buf, {force = true})
      window_type = 'regular_window'
    end
  end, ns[3])
end

prepare_cache_dir = function()
  local err = os.execute('ls -d ' .. cache_dir)
  write_log('ls -d ' .. cache_dir .. 'returns ' .. err)
  if err == 512 then
    os.execute('mkdir -p ' .. cache_dir)
  end
end

init_ns = function()
  ns = {}
  table.insert(ns, {})
  table.insert(ns, {})
  table.insert(ns, 0)
end

initialize = function()
  if vim.fn.isdirectory("/tmp/vinote") > 0 then
    write_log("another instance of vinote is opened! Aborted.")
    vim.cmd("q!")
  else
    vim.fn.mkdir("/tmp/vinote")
  end
  write_log("root: " .. root)
  prepare_cache_dir()
  init_ns()
  init_keypress_handler()
  restore_path()
  vim.opt.syntax = "markdown"
  vim.opt.iskeyword:append({ "/", "."})
end

update_file = function()
  vim.cmd.update()
end

quit = function()
  io.popen("rm -rf /tmp/vinote")
  vim.cmd.execute([[normal :q!<CR>]])
end

initialize()
