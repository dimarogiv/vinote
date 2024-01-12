local root = os.getenv("VINOTE_ROOT_DIR")
local cache_dir = os.getenv("HOME") .. "/.cache/vinote"
local history_len = 100
--local logfile = "/dev/pts/1"
local logfile = "/dev/null"
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

rename = function()
  local new_name = vim.fn.expand([[%:p:h]]) .. "/" .. vim.fn.expand([[<cword>]])
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
  vim.fn.search(pattern)
end

choose_string = function()
  local pos = vim.fn.getcurpos()
  return pos[2]
end

popup_menu_create = function(list, fun_before, fun_after, activation_key)
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
  print(popup_buf)

  local ns = vim.api.nvim_create_namespace("Chooser_ns")
  vim.on_key(function(key)
    if key == activation_key and vim.api.nvim_win_get_config(0).relative ~= '' then
      local res = fun_before()
      vim.api.nvim_win_close(0, true)
      vim.api.nvim_buf_delete(0, {force = true})
      print(res)
      fun_after(res)
    end
  end, ns)

end

search_note = function()
  vim.fn.inputsave()
  pattern = vim.fn.input("Search: ")
  vim.fn.inputrestore()
  list = vim.fn.systemlist("grep -R --exclude='.*' \'" .. pattern .. "\' " .. root .. " 2>&1 | grep -v 'grep:' | sed 's/\\/_:/:\\t\\t/'")
  if #list == 0 then
    return
  end
  listtogo = list
  local listtoshow = list
  for item=1,#listtoshow,1 do
    listtoshow[item] = vim.fn.split(list[item], root)[1]
  end
  popup_menu_create(listtoshow, choose_string, go_search_result, '\r')
end

add_extras = function()
end

remove_extras = function()
end

update_file = function()
  vim.cmd.update()
end

quit = function()
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

vim.keymap.set('n', 'er', function() remove() end)
vim.keymap.set('n', 'ef', function() wgo_to_note(vim.fn.expand([[<cword>]])) end)
vim.keymap.set('n', 'eu', function() wgo_to_note(vim.fn.expand([[%:p:h:h]])) end)
vim.keymap.set('n', 'ec', function() choose() end)
vim.keymap.set('n', 'en', function() rename() end)
vim.keymap.set('n', 'es', function() search_note() end)
vim.keymap.set('n', 'ea', function() add_extras() end)
vim.keymap.set('n', 'eo', function() remove_extras() end)
vim.keymap.set('n', 'eh', function() wgo_to_note(root) end)
vim.keymap.set('n', 'eb', function() go_back() end)
vim.keymap.set('n', 'el', function() link() end)

vim.api.nvim_create_autocmd("BufRead", {command = "set syntax=markdown"})
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedT", "ModeChanged"}, {callback = update_file})
vim.api.nvim_clear_autocmds({event = "TextChangedI"})
vim.api.nvim_create_autocmd({"ExitPre", "QuitPre"}, {callback = quit})

write_log("root: " .. root)
prepare_cache_dir()
restore_path()
vim.opt.syntax = "markdown"
vim.opt.iskeyword:append({ "/", "."})
