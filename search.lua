go_search_result = function()
  local res = choose_string()
  vim.api.nvim_win_close(0, true)
  vim.api.nvim_buf_delete(0, {force = true})
  window_type = 'regular_window'
  write_log([[go_search_result: listtogo[res] = ]] .. listtogo[res])
  local path = vim.fn.split(listtogo[res], ":\\t")[1]
  write_log([[go_search_result: path = ]] .. path)
  if string.sub(path, 1, 1) == '/' then
    write_log('go_search_result: wgo_to_note(' .. root .. path .. ')')
    wgo_to_note(root .. path)
  else
    write_log('go_search_result: wgo_to_note(' .. root .. ')')
    wgo_to_note(root)
  end
  vim.fn.setpos(".", {0, vim.fn.search(pattern), 0, true})
  if vim.fn.line(".") < vim.fn.line("$") then
    vim.cmd.normal("k")
  end
end

go_file_search_result = function(res)
  write_log([[listtogo[res] = ]] .. listtogo[res])
  local path = listtogo[res]
  write_log([[path = ]] .. path)
  if string.sub(path, 1, 1) == '/' then
    wgo_to_note(root .. path)
  else
    wgo_to_note(root)
  end
end

search_note = function(search_root)
  vim.fn.inputsave()
  pattern = vim.fn.input("Search: ")
  vim.fn.inputrestore()
  list = vim.fn.systemlist("grep -R --exclude='.*' \'" .. pattern .. "\' " .. search_root .. " 2>&1 | grep -v 'grep:' | grep -v '/_:x-> ' | sed 's/\\/_:/:\\t\\t/'")
  write_log('search_note: list[1] = ' .. list[1])
  if #list == 0 then
    return
  end
  listtogo = list
  local listtoshow = list
  for item=1,#listtoshow,1 do
    listtoshow[item] = vim.fn.split(list[item], root)[1]
  end
  popup_menu_create(listtoshow)
  window_type = "popup_menu_text_search"
end

search_file = function()
  vim.fn.inputsave()
  pattern = vim.fn.input("Search file: ")
  vim.fn.inputrestore()
  pattern = pattern:gsub(' ', '_')
  list = vim.fn.systemlist("find " .. root .. " -name '*" .. pattern .. "*'")
  if #list == 0 then
    return
  end
  listtogo = list
  local listtoshow = list
  for item=1, #listtoshow, 1 do
    listtoshow[item] = vim.fn.split(list[item], root)[1]
  end
  popup_menu_create(listtoshow)
  window_type = "popup_menu_file_search"
end
