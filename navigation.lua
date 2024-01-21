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
  init_ns()
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
