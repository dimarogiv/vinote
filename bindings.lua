vim.keymap.set('n', vinote_leader_key .. remove_note_key, function() management.remove() end)
vim.keymap.set('n', vinote_leader_key .. go_to_note_key, function() navigation.wgo_to_note(vim.fn.expand([[<cword>]])) end)
vim.keymap.set('n', vinote_leader_key .. level_up_key, function() navigation.wgo_to_note(vim.fn.expand([[%:p:h:h]])) end)
vim.keymap.set('n', vinote_leader_key .. choose_note_key, function() management.choose() end)
vim.keymap.set('n', vinote_leader_key .. rename_note_key, function() management.rename() end)
vim.keymap.set('n', vinote_leader_key .. search_note_by_text_key, function() search.search_note(root) end)
vim.keymap.set('n', vinote_leader_key .. go_home_key, function() navigation.wgo_to_note(root) end)
vim.keymap.set('n', vinote_leader_key .. go_back_key, function() navigation.go_back() end)
vim.keymap.set('n', vinote_leader_key .. link_choosen_note_key, function() management.link() end)
vim.keymap.set('n', vinote_leader_key .. search_note_by_text_locally_key, function() search.search_note(vim.fn.expand([[%:p:h]])) end)
vim.keymap.set('n', vinote_leader_key .. expand_note_key, function() visual.expand_note() end)
vim.keymap.set('n', vinote_leader_key .. collapse_note_key, function() visual.collapse_note() end)
vim.keymap.set('n', vinote_leader_key .. expand_all_notes_in_buffer_key, function() visual.expand_all_notes() end)
vim.keymap.set('n', vinote_leader_key .. collapse_all_notes_in_buffer_key, function() visual.collapse_all_notes() end)
vim.keymap.set('n', vinote_leader_key .. complete_task_key, function() management.complete_task() end)
vim.keymap.set('n', vinote_leader_key .. uncomplete_task_key, function() management.uncomplete_task() end)
vim.keymap.set('n', vinote_leader_key .. search_note_by_file_key, function() search.search_file() end)
vim.keymap.set('n', vinote_leader_key .. go_to_next_neighbour_note_key, function() navigation.horizontal_navigation(1) end)
vim.keymap.set('n', vinote_leader_key .. go_to_prev_neighbour_note_key, function() navigation.horizontal_navigation(-1) end)
vim.keymap.set('n', '<ESC>', function()
  if vim.fn.match(window_type, 'popup_menu') >= 0 then
    vim.api.nvim_win_close(popup_win, true)
    vim.api.nvim_buf_delete(popup_buf, {force = true})
    window_type = 'regular_window'
  else
    navigation.wgo_to_note(vim.fn.expand([[%:p:h:h]]))
  end
end)

vim.keymap.set('n', "<CR>", function()
  if window_type == 'popup_menu_text_search' then
    search.go_search_result()
  elseif window_type == 'popup_menu_file_search' then
    local res = helpers.choose_string()
    search.go_file_search_result(res)
  elseif window_type == 'regular_window' then
    navigation.wgo_to_note(vim.fn.expand([[<cword>]]))
  else
    print(window_type)
  end
end)

vim.api.nvim_create_autocmd("BufRead", {command = "set syntax=markdown"})
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedT", "ModeChanged"}, {callback = init.update_file})
vim.api.nvim_clear_autocmds({event = "TextChangedI"})
vim.api.nvim_create_autocmd({"ExitPre", "QuitPre"}, {callback = init.quit})
