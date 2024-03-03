visual = {
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
  ,

  popup_menu_create = function(list)
    if type(list) == 'table' and #list > 0 then
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
    else
      print('Error: the result list is empty')
    end
  end
  ,

  create_virtual_text = function(text, line, col, hl_type)
    local lines = {}
    for i = 1, #text, 1 do
      table.insert(lines, {{text[i], hl_type}})
    end
    local opts = {
      id = 1,
      virt_lines = lines,
      virt_lines_above = true,
    }
    ns[1][line] = vim.api.nvim_create_namespace(tostring(line))
    ns[2][line] = vim.api.nvim_buf_set_extmark(0, ns[1][line], line, col, opts)
  end
  ,

  expand_note = function()
    local lines = {}
    for line in io.lines(vim.fn.expand([[<cword>]]) .. "/_") do
      lines[#lines + 1] = line
    end
    visual.create_virtual_text(lines, vim.fn.getcurpos()[2], vim.fn.getcurpos()[1], '')
  end
  ,

  collapse_note = function()
    vim.api.nvim_buf_del_extmark(0, ns[1][vim.fn.getcurpos()[2]], ns[2][vim.fn.getcurpos()[2]])
  end
  ,

  expand_all_notes = function()
    --vim.fn.search('*\\([a-z]\\|_\\)\\**', 'cn')
    --vim.cmd.normal([[/*\\([a-z]\\|_\\)\\**]])
    --local count = vim.fn.searchcount({recompute = 1})
    for i = 1, 99, 1 do
      vim.fn.search('*\\([a-z]\\|_\\)\\**')
      visual.expand_note()
    end
  end
  ,

  collapse_all_notes = function()
    --vim.fn.search('*\\([a-z]\\|_\\)\\**', 'cn')
    --vim.cmd.normal([[/*\\([a-z]\\|_\\)\\**]])
    --local count = vim.fn.searchcount({recompute = 1})
    for i = 1, 99, 1 do
      vim.fn.search('*\\([a-z]\\|_\\)\\**')
      visual.collapse_note()
    end
  end
  ,

  add_header = function()
    local path = vim.fn.expand('%:p:h')
    local file = vim.fn.expand('%')
    local file_content = {}
    local f = io.open(file)
    if f~=nil then
      io.close(f)
      for line in io.lines(file) do
        table.insert(file_content, line)
      end
    end
    local is_header
    if #file_content > 0 and string.find(file_content[1], "x%-%>") == 1 then
      helpers.write_log("is_header = 1")
      is_header = 1
    else
      helpers.write_log("is_header = nil")
      is_header = nil
    end
    path = path:sub(#root+2)
    path = "x-> " .. path:gsub("/", " -> ")
    local handle = io.popen([[echo ']] .. path .. [[' | sed 's/-> [a-z]/\U&/g']])
    local path_header = handle:read('*l')
    path_header = path_header:gsub("_", " ")
    handle:close()
    if not is_header then
      local pos = vim.fn.getcurpos()
      vim.cmd.normal('ggO')
      vim.cmd.normal('cc')
      vim.cmd.normal('i' .. path_header)
      vim.fn.setpos('.', pos)
      vim.cmd.normal('j')
    end
    local text = {
      path_header,
      '',
      vim.fn.expand("%:p:h:t"),
      '',
    }

    local lines = {}
    for i = 2, #text, 1 do
      table.insert(lines, {{text[i], 'Comment'}})
    end
    local opts = {
      id = 1,
      virt_lines = {lines[1]},
      virt_lines_above = false,
      virt_text_pos = 'overlay',
      virt_text = {{text[1], 'Comment'}},
    }
    ns[1][1] = vim.api.nvim_create_namespace(tostring(1))
    ns[2][1] = vim.api.nvim_buf_set_extmark(0, ns[1][1], 0, 0, opts)
  end
  ,

  remove_virtual_text = function()
    --vim.api.nvim_buf_del_extmark(0, ns[1][1], ns[2][1])
    if ns[1][1] and ns[2][1] then
      vim.api.nvim_buf_del_extmark(0, ns[1][1], ns[2][1])
    end
  end
  ,

  add_extras = function()
    visual.add_header()
  end
  ,

  remove_extras = function()
    visual.remove_virtual_text()
  end
  ,

  get_site_title = function(link)
    local handle = io.popen([[wget -qO- ']] ..
    link ..
    [[' | perl -l -0777 -ne 'print $1 if /<title.*?>\s*(.*?)\s*<\/title/si']])
    local title = handle:read('*l')
    visual.create_virtual_text({title}, vim.fn.getcurpos()[2], vim.fn.getcurpos()[1], '')
  end
  ,
  create_table = function()
    local ncols = 3
    local lines = vim.api.nvim_buf_get_lines(0,
      vim.api.nvim_buf_get_mark(0, '<')[1] - 1,
      vim.api.nvim_buf_get_mark(0, '>')[1], true)
    _, ncols = string.gsub(lines[1], table_separator, table_separator)
    local formatting = 'c'
    for _ = 1,ncols,1 do
      formatting = formatting .. ' c'
    end
    vim.cmd.execute([["normal :'<,'>s/]] .. table_separator .. [[/\\t/g\<CR>"]])
    vim.cmd.normal([['<]])
    vim.cmd.normal([[O.TS]])
    vim.cmd.normal([[oallbox ;]])
    vim.cmd.normal('o' .. formatting .. '.')
    vim.cmd.normal([['>]])
    vim.cmd.normal([[o]])
    vim.cmd.normal([[i.TE]])
    vim.cmd.execute([["normal :?^\.TS?,.!tbl|]] ..
      [[groff -ms -Tascii 2>/dev/null|]] ..
      [[awk '{if($NF){print $0}}'\<CR>"]])
  end
  ,
  update_table = function()
    vim.cmd.execute([["normal :'<,'>!]] ..
      [[awk '{if(match($0, /+-/)){}else{print $0}}' |]] ..
      [[sed 's/|/]] .. table_separator .. [[/g'\<CR>"]])
    vim.cmd.execute([["/^\\n/-1"]])
    vim.api.nvim_buf_set_mark(0, '>', vim.fn.getcurpos()[2], 1, {})
    vim.cmd.execute([["normal :'<,'>s/^]] .. table_separator .. [[//\<CR>"]])
    vim.cmd.execute([["normal :'<,'>s/]] .. table_separator .. [[$//\<CR>"]])
    vim.cmd.execute([["normal :'<,'>s/  / /g\<CR>"]])
    visual.create_table()
  end
}
