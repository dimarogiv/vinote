helpers = {
  write_motion_history = function()
    local path = vim.fn.expand([[%:p:h"]])
    if #vim.fn.split(path, root) > 0 then
      path = vim.fn.split(path, root)[1]
    else
      path = "/"
    end
    helpers.write_log('Written to ' .. cache_dir .. '/motion_history: ' .. path)
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
  ,

  write_log = function(text)
    local logstr = vim.fn.strftime("%X") .. ": " .. text
    vim.fn.writefile({logstr}, logfile, 'a')
  end
  ,

  choose_string = function()
    local pos = vim.fn.getcurpos()
    return pos[2]
  end
  ,
}
