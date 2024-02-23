management = {
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
  ,

  rename = function()
    local new_name = vim.fn.expand([[%:p:h]]) .. "/" .. vim.fn.expand([[<cword>]])
    if vim.fn.isdirectory(new_name) > 0  then
      if visual.yes_no_prompt(new_name .. " already exists. Replace it?") == true then
        io.popen("rm -rf " .. new_name)
      else
        return
      end
    end
    io.popen("mv " .. old_filename .. " " .. new_name)
    print("Renamed " .. vim.fn.fnamemodify(old_filename, ":.:t") .. " -> " .. vim.fn.fnamemodify(new_name, ":.:t"))
  end
  ,

  link = function()
    local link_name = vim.fn.expand([[%:p:h]]) .. "/" .. vim.fn.expand([[<cword>]])
    io.popen("ln -s " .. old_filename .. " " .. link_name)
    print(old_filename .. " -> " .. link_name)
  end
  ,

  choose = function()
    old_filename = vim.fn.expand([[%:p:h"]]) .. "/" .. vim.fn.expand([[<cword>]])
    print(old_filename)
  end
  ,

  complete_task = function()
    local pos = vim.fn.getcurpos()
    vim.fn.search('- \\[ \\] ', 'bcW')
    vim.cmd.normal('3lciwx')
    vim.fn.setpos('.', pos)
  end
  ,

  uncomplete_task = function()
    local pos = vim.fn.getcurpos()
    vim.fn.search('- \\[x\\] ', 'bcW')
    vim.cmd.normal('3lciw ')
    vim.fn.setpos('.', pos)
  end
}
