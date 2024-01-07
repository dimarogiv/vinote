local root = os.getenv("NOTION_DIR_LUA")
local history_len = 100
local logfile = "/dev/pts/1"
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
  if vim.fn.filereadable(root .. "/.motion_history") > 0 and #vim.fn.readfile(root .. "/.motion_history") > 0 then
    pathlist = vim.fn.readfile(root .. "/.motion_history")
    write_log("len(/.motion_history) = " .. #pathlist)
    table.remove(pathlist, #pathlist)
  else
    write_log("pathlist = [/]")
    pathlist = {"/"}
  end
  vim.fn.writefile(pathlist, root .. "/.motion_history")
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
  write_log("Written to /.motion_history: " .. path)
  local pathlist
  if vim.fn.filereadable(root .. "/.motion_history") > 0 then
    pathlist = vim.fn.readfile(root .. "/.motion_history")
    pathlist = vim.fn.add(pathlist, path)
  else
    pathlist = {}
  end
  if #pathlist > history_len then
    table.move(pathlist, #pathlist-100, #pathlist, 1, pathlist)
  end
  vim.fn.writefile(pathlist, root .. "/.motion_history")
end

restore_path = function()
  local pathlist
  local path
  local file_exists = vim.fn.filereadable(root .. "/.motion_history")
  local file_empty
  if file_exists > 0 then
    write_log("file_exists > 0")
    file_empty = #vim.fn.readfile(root .. "/.motion_history") == 0
  end
  if file_exists > 0 and not file_empty then
    write_log("file_exists = true, file_empty == 0")
    pathlist = vim.fn.readfile(root .. "/.motion_history")
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
  vim.cmd.execute("normal :!mv " .. old_filename .. " " .. new_name .. "<CR>")
end

choose = function()
  old_filename = vim.fn.expand([[%:p:h"]]) .. "/" .. vim.fn.expand([[<cword]])
  vim.fn.echo(old_filename)
end

go_search_result = function(id, result)
  local path = vim.fn.split(listtogo[result-1], ":\t")[1]
  wgo_to_note(path)
  vim.fn.search(pattern)
end

search_note = function()
  vim.fn.inputsave()
  pattern = vim.fn.input("Search: ")
  vim.fn.inputrestore()
  list = vim.fn.systemlist("grep -R \'" .. pattern .. "\' " .. root .. " 2>&1 | grep -v 'grep:' | sed 's/\\/_:/:\\t\\t/'")
  if #list == 0 then
    return
  end
  listtogo = list
  local listtoshow = list
  for item=1,#listtoshow,1 do
    listtoshow[item] = vim.fn.split(list[item], root)[1]
  end
  vim.cmd([[call popup_menu(listtoshow, #{callback: "GoSearchResult"})]])
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
  vim.cmd.execute("normal :!ln -s " .. old_filename .. " " .. link_name .. "<CR>")
end

vim.keymap.set('n', 'er', function() remove() end)
vim.keymap.set('n', 'ef', function() wgo_to_note(vim.fn.expand([[<cword>]])) end)
vim.keymap.set('n', 'eu', function() wgo_to_note(vim.fn.expand([[%:p:h:h]])) end)
vim.keymap.set('n', 'ec', function() choose() end)
vim.keymap.set('n', 'en', function() rename() end)
vim.keymap.set('n', 'es', function() search_note() end)
vim.keymap.set('n', 'ea', function() add_extras() end)
vim.keymap.set('n', 'eo', function() remove_extras() end)
vim.keymap.set('n', 'eh', function() wgo_to_note() end)
vim.keymap.set('n', 'eb', function() go_back() end)
vim.keymap.set('n', 'el', function() link() end)

vim.api.nvim_create_autocmd("BufRead", {command = "set syntax=markdown"})
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedT", "ModeChanged"}, {callback = update_file})
vim.api.nvim_clear_autocmds({event = "TextChangedI"})
vim.api.nvim_create_autocmd({"ExitPre", "QuitPre"}, {callback = quit})

write_log("root: " .. root)
restore_path()
vim.opt.syntax = "markdown"
vim.opt.iskeyword:append({ "/", "."})
