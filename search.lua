search = {
  go_search_result = function()
    local res = helpers.choose_string()
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_buf_delete(0, {force = true})
    window_type = 'regular_window'
    helpers.write_log([[go_search_result: listtogo[res] = ]] .. listtogo[res])
    local path = vim.fn.split(listtogo[res], ":\\t")[1]
    helpers.write_log([[go_search_result: path = ]] .. path)
    if string.sub(path, 1, 1) == '/' then
      helpers.write_log('go_search_result: wgo_to_note(' .. root .. path .. ')')
      navigation.wgo_to_note(root .. path)
    else
      helpers.write_log('go_search_result: wgo_to_note(' .. root .. ')')
      navigation.wgo_to_note(root)
    end
    vim.fn.setpos(".", {0, vim.fn.search(pattern), 0, true})
    if vim.fn.line(".") < vim.fn.line("$") then
      vim.cmd.normal("k")
    end
  end
  ,

  go_file_search_result = function(res)
    vim.api.nvim_win_close(0, true)
    vim.api.nvim_buf_delete(0, {force = true})
    window_type = 'regular_window'
    helpers.write_log([[listtogo[res] = ]] .. listtogo[res])
    local path = listtogo[res]
    helpers.write_log([[path = ]] .. path)
    if string.sub(path, 1, 1) == '/' then
      navigation.wgo_to_note(root .. path)
    else
      navigation.wgo_to_note(root)
    end
  end
  ,

  search_note = function(search_root)
    vim.fn.inputsave()
    pattern = vim.fn.input("Search: ")
    vim.fn.inputrestore()
    list = vim.fn.systemlist("grep -R --exclude='.*' \'" .. pattern .. "\' " .. search_root .. " 2>&1 | grep -v 'grep:' | grep -v '/_:x-> ' | sed 's/\\/_:/:\\t\\t/'")
    if not list[1] == nil then
      helpers.write_log('search_note: list[1] = ' .. list[1])
    else
      helpers.write_log('search_note: list[1] = nil')
    end
    if #list == 0 then
      return
    end
    listtogo = list
    local listtoshow = list
    for item=1,#listtoshow,1 do
      listtoshow[item] = vim.fn.split(list[item], root)[1]
    end
    visual.popup_menu_create(listtoshow)
    window_type = "popup_menu_text_search"
  end
  ,

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
    visual.popup_menu_create(listtoshow)
    window_type = "popup_menu_file_search"
  end
}
