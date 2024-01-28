go_to_note = function(path)
  write_log("go_to_note(" .. path .. ")")
  remove_extras()
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
  init_ns()
  add_extras()
end

wgo_to_note = function(path)
  go_to_note(path)
  write_motion_history()
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

horizontal_navigation = function(direction)
  local handle = io.popen("find \"..\" -not -path \"../.*\" -mindepth 1 -maxdepth 1 -type d 2>/dev/null")
  local list = {}
  --for item in handle:read("*l") do
  while true do
    local item = handle:read("*l")
    if item == nil then break end
    table.insert(list, item)
  end
  local current_file = vim.fn.expand("%:p:h")
  local itemn = 0
  current_file_t = vim.fn.split(current_file, "/")
  for n = 1, #list, 1 do
    local list_t = vim.fn.split(list[n], "/")
    if list_t[#list_t] == current_file_t[#current_file_t] then
      itemn = n
      break
    end
  end
  --print(list[itemn])
  --print(list[itemn % #list])
  --print((itemn % (#list + 1)))
  if direction == 1 then
    wgo_to_note(list[(itemn % #list) + 1])
  elseif direction == -1 then
    wgo_to_note(list[((itemn -2) % #list) + 1])
  end
end
