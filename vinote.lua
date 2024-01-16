local root = os.getenv("VINOTE_ROOT_DIR")
local cache_dir = os.getenv("HOME") .. "/.cache/vinote"
local history_len = 100
local logfile = "/dev/pts/1"
--local logfile = "/dev/null"
vim = vim

write_log = function(text)
  local logstr = vim.fn.strftime("%X") .. ": " .. text
  vim.fn.writefile({logstr}, logfile)
end

go_to_note = function(path)
  write_log("go_to_note(" .. path .. ")")
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path)
  end
  path = vim.fn.fnamemodify(path, ":p:h")
  write_log("go_to_note(" .. path .. ")")
  if vim.fn.match(path, root) >= 0 then
    if vim.fn.isdirectory(path) > 0 then
      vim.fn.chdir(path)
      vim.cmd.edit("_")
    elseif vim.fn.filereadable(path) > 0 then
      vim.cmd.edit(path)
    else
      vim.fn.mkdir(path)
      vim.fn.chdir(path)
      vim.cmd.edit("_")
    end
  else
    write_log("error: " .. path .. ": the path is unaccessible!" .. ": match() returns: " .. vim.fn.match(path, root))
  end
end

wgo_to_note = function(path)
  go_to_note(path)
  write_motion_history()
end

remove = function(path)
  local handle = io.popen("stat " .. vim.fn.expand([[<cword>]]) .. " | grep 'symbolic link'")
  local output = handle:read("*a")
  handle:close()
  local is_symbolic_link = #output
  if is_symbolic_link > 0 then
    io.popen("rm " .. vim.fn.expand([[<cword>]]))
    print("Link removed")
  else
    io.popen("rm -rf " .. vim.fn.expand([[<cword>]]))
    print("Note removed")
  end
end

go_back = function()
  local pathlist = {}
  if vim.fn.filereadable(cache_dir .. '/motion_history') > 0 and #vim.fn.readfile(cache_dir .. '/motion_history') > 0 then
    pathlist = vim.fn.readfile(cache_dir .. '/motion_history')
    write_log("len(motion_history) = " .. #pathlist)
    table.remove(pathlist, #pathlist)
  else
    write_log("pathlist = [/]")
    pathlist = {"/"}
  end
  vim.fn.writefile(pathlist, cache_dir .. '/motion_history')
  local path = pathlist[#pathlist]
  if path == "/" then
    path = root
  else
    path = root .. path
  end
  write_log("go_back: " .. path)
  go_to_note(path)
end

write_motion_history = function()
  local path = vim.fn.expand([[%:p:h"]])
  if #vim.fn.split(path, root) > 0 then
    path = vim.fn.split(path, root)[1]
  else
    path = "/"
  end
  write_log('Written to ' .. cache_dir .. '/motion_history: ' .. path)
  local pathlist
  if vim.fn.filereadable(cache_dir .. '/motion_history') > 0 then
    pathlist = vim.fn.readfile(cache_dir .. '/motion_history')
    pathlist = vim.fn.add(pathlist, path)
  else
    pathlist = {}
  end
  if #pathlist > history_len then
    table.move(pathlist, #pathlist-100, #pathlist, 1, pathlist)
  end
  vim.fn.writefile(pathlist, cache_dir .. '/motion_history')
end

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

rename = function()
  local new_name = vim.fn.expand([[%:p:h]]) .. "/" .. vim.fn.expand([[<cword>]])
  if vim.fn.isdirectory(new_name) > 0  then
    if yes_no_prompt(new_name .. " already exists. Replace it?") == true then
      io.popen("rm -rf " .. new_name)
    else
      return
    end
  end
  io.popen("mv " .. old_filename .. " " .. new_name)
  print("Renamed " .. vim.fn.fnamemodify(old_filename, ":.:t") .. " -> " .. vim.fn.fnamemodify(new_name, ":.:t"))
end

choose = function()
  old_filename = vim.fn.expand([[%:p:h"]]) .. "/" .. vim.fn.expand([[<cword>]])
  print(old_filename)
end

go_search_result = function(res)
  write_log([[listtogo[res] = ]] .. listtogo[res])
  local path = vim.fn.split(listtogo[res], ":\\t")[1]
  write_log([[path = ]] .. path)
  if string.sub(path, 1, 1) == '/' then
    wgo_to_note(root .. path)
  else
    wgo_to_note(root)
  end
  vim.fn.setpos(".", {0, vim.fn.search(pattern), 0, true})
  if vim.fn.line(".") < vim.fn.line("$") then
    vim.cmd.normal("k")
  end
end

choose_string = function()
  local pos = vim.fn.getcurpos()
  return pos[2]
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

init_keypress_handler = function()
  local ns = vim.api.nvim_create_namespace("Chooser_ns")
  window_type="regular_note"
  vim.on_key(function(key)
    if key == '\r' and window_type == 'popup_menu' then
      local res = choose_string()
      vim.api.nvim_win_close(0, true)
      vim.api.nvim_buf_delete(0, {force = true})
      window_type = 'regular_window'
      go_search_result(res)
    end
    if key == '\x1B' and window_type == 'popup_menu' then
      vim.api.nvim_win_close(popup_win, true)
      vim.api.nvim_buf_delete(popup_buf, {force = true})
      window_type = 'regular_window'
    end
  end, ns)
end

search_note = function(search_root)
  vim.fn.inputsave()
  pattern = vim.fn.input("Search: ")
  vim.fn.inputrestore()
  list = vim.fn.systemlist("grep -R --exclude='.*' \'" .. pattern .. "\' " .. search_root .. " 2>&1 | grep -v 'grep:' | sed 's/\\/_:/:\\t\\t/'")
  if #list == 0 then
    return
  end
  listtogo = list
  local listtoshow = list
  for item=1,#listtoshow,1 do
    listtoshow[item] = vim.fn.split(list[item], root)[1]
  end
  popup_menu_create(listtoshow)
end

add_extras = function()
end

remove_extras = function()
end

update_file = function()
  vim.cmd.update()
end

quit = function()
  io.popen("rmdir /tmp/vinote_running")
  vim.cmd.execute([[normal :q!<CR>]])
end

link = function()
  local link_name = vim.fn.expand([[%:p:h]]) .. "/" .. vim.fn.expand([[<cword>]])
  io.popen("ln -s " .. old_filename .. " " .. link_name)
  print(old_filename .. " -> " .. link_name)
end

prepare_cache_dir = function()
  local err = os.execute('ls -d ' .. cache_dir)
  write_log('ls -d ' .. cache_dir .. 'returns ' .. err)
  if err == 512 then
    os.execute('mkdir -p ' .. cache_dir)
  end
end

initialization = function()
  if vim.fn.isdirectory("/tmp/vinote_running") > 0 then
    write_log("another instance of vinote is opened! Aborted.")
    vim.cmd("q!")
  else
    vim.fn.mkdir("/tmp/vinote_running")
  end
  write_log("root: " .. root)
  prepare_cache_dir()
  init_keypress_handler()
  restore_path()
  vim.opt.syntax = "markdown"
  vim.opt.iskeyword:append({ "/", "."})
end



initialization()

vim.keymap.set('n', 'er', function() remove() end)
vim.keymap.set('n', 'ef', function() wgo_to_note(vim.fn.expand([[<cword>]])) end)
vim.keymap.set('n', 'eu', function() wgo_to_note(vim.fn.expand([[%:p:h:h]])) end)
vim.keymap.set('n', 'ec', function() choose() end)
vim.keymap.set('n', 'en', function() rename() end)
vim.keymap.set('n', 'es', function() search_note(root) end)
vim.keymap.set('n', 'ea', function() add_extras() end)
vim.keymap.set('n', 'eo', function() remove_extras() end)
vim.keymap.set('n', 'eh', function() wgo_to_note(root) end)
vim.keymap.set('n', 'eb', function() go_back() end)
vim.keymap.set('n', 'el', function() link() end)
vim.keymap.set('n', 'et', function() search_note(vim.fn.expand([[%:p:h]])) end)

vim.api.nvim_create_autocmd("BufRead", {command = "set syntax=markdown"})
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedT", "ModeChanged"}, {callback = update_file})
vim.api.nvim_clear_autocmds({event = "TextChangedI"})
vim.api.nvim_create_autocmd({"ExitPre", "QuitPre"}, {callback = quit})
