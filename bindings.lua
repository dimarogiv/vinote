vim.keymap.set('n', vinote_leader_key .. remove_note_key, function() remove() end)
vim.keymap.set('n', vinote_leader_key .. go_to_note_key, function() wgo_to_note(vim.fn.expand([[<cword>]])) end)
vim.keymap.set('n', vinote_leader_key .. level_up_key, function() wgo_to_note(vim.fn.expand([[%:p:h:h]])) end)
vim.keymap.set('n', vinote_leader_key .. choose_note_key, function() choose() end)
vim.keymap.set('n', vinote_leader_key .. rename_note_key, function() rename() end)
vim.keymap.set('n', vinote_leader_key .. search_note_by_text_key, function() search_note(root) end)
vim.keymap.set('n', vinote_leader_key .. go_home_key, function() wgo_to_note(root) end)
vim.keymap.set('n', vinote_leader_key .. go_back_key, function() go_back() end)
vim.keymap.set('n', vinote_leader_key .. link_choosen_note_key, function() link() end)
vim.keymap.set('n', vinote_leader_key .. search_note_by_text_locally_key, function() search_note(vim.fn.expand([[%:p:h]])) end)
vim.keymap.set('n', vinote_leader_key .. expand_note_key, function() expand_note() end)
vim.keymap.set('n', vinote_leader_key .. collapse_note_key, function() collapse_note() end)
vim.keymap.set('n', vinote_leader_key .. expand_all_notes_in_buffer_key, function() expand_all_notes() end)
vim.keymap.set('n', vinote_leader_key .. collapse_all_notes_in_buffer_key, function() collapse_all_notes() end)
vim.keymap.set('n', vinote_leader_key .. complete_task_key, function() complete_task() end)
vim.keymap.set('n', vinote_leader_key .. uncomplete_task_key, function() uncomplete_task() end)
vim.keymap.set('n', vinote_leader_key .. search_note_by_file_key, function() search_file() end)
vim.keymap.set('n', vinote_leader_key .. go_to_next_neighbour_note_key, function() horizontal_navigation(1) end)
vim.keymap.set('n', vinote_leader_key .. go_to_prev_neighbour_note_key, function() horizontal_navigation(-1) end)
vim.keymap.set('n', '<ESC>', function()
  if vim.fn.match(window_type, 'popup_menu') >= 0 then
    vim.api.nvim_win_close(popup_win, true)
    vim.api.nvim_buf_delete(popup_buf, {force = true})
    window_type = 'regular_window'
  else
    wgo_to_note(vim.fn.expand([[%:p:h:h]]))
  end
end)

vim.keymap.set('n', "<CR>", function()
  if window_type == 'popup_menu_text_search' then
    go_search_result()
  else
    wgo_to_note(vim.fn.expand([[<cword>]]))
  end
end)

vim.api.nvim_create_autocmd("BufRead", {command = "set syntax=markdown"})
vim.api.nvim_create_autocmd({"TextChanged", "TextChangedT", "ModeChanged"}, {callback = update_file})
vim.api.nvim_clear_autocmds({event = "TextChangedI"})
vim.api.nvim_create_autocmd({"ExitPre", "QuitPre"}, {callback = quit})
