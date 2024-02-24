init = {
  restore_path = function()
    local pathlist
    local path
    local file_exists = vim.fn.filereadable(cache_dir .. '/motion_history')
    local file_empty
    if file_exists > 0 then
      helpers.write_log("file_exists > 0")
      file_empty = #vim.fn.readfile(cache_dir .. '/motion_history') == 0
    end
    if file_exists > 0 and not file_empty then
      helpers.write_log("file_exists = true, file_empty == 0")
      pathlist = vim.fn.readfile(cache_dir .. '/motion_history')
      path = pathlist[#pathlist]
    else
      helpers.write_log("path = '/'")
      path = "/"
    end
    if path == "/" then
      path = root
    else
      path = root .. path
    end
    helpers.write_log("restore_path: " .. path)
    navigation.go_to_note(path)
  end
  ,

  init_keypress_handler = function()
  end
  ,

  prepare_cache_dir = function()
    local err = os.execute('ls -d ' .. cache_dir)
    helpers.write_log('ls -d ' .. cache_dir .. 'returns ' .. err)
    if err == 512 then
      os.execute('mkdir -p ' .. cache_dir)
    end
  end
  ,

  init_ns = function()
    ns = {}
    table.insert(ns, {})
    table.insert(ns, {})
    table.insert(ns, 0)
  end
  ,

  initialize = function()
    helpers.write_log("root: " .. root)
    init.prepare_cache_dir()
    init.init_ns()
    init.init_keypress_handler()
    init.restore_path()
    vim.opt.syntax = "markdown"
    vim.opt.iskeyword:append({ "/", "."})
    window_type = 'regular_window'
  end
  ,

  update_file = function()
    vim.cmd.update()
  end
  ,

  quit = function()
    vim.cmd.execute([[normal :q!<CR>]])
  end
}

init.initialize()
