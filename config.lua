cache_dir = os.getenv("HOME") .. "/.cache/vinote"
history_len = 100
logfile = "/tmp/vinote/vinote.log"

-- bindings
vinote_leader_key = 'e'

remove_note_key = 'rm'
go_to_note_key = 'f'
level_up_key = 'u'
choose_note_key = 'c'
rename_note_key = 'rn'
search_note_by_text_key = 'sn'
go_home_key = 'h'
go_back_key = 'b'
link_choosen_note_key = 'l'
search_note_by_text_locally_key = 'sln'
expand_note_key = 'vx'
collapse_note_key = 'vc'
expand_all_notes_in_buffer_key = 'vax'
collapse_all_notes_in_buffer_key = 'vac'
complete_task_key = 'tc'
uncomplete_task_key = 'tu'
search_note_by_file_key = 'sf'
go_to_next_neighbour_note_key = 'nn'
go_to_prev_neighbour_note_key = 'np'


if root == nil then
  root = os.getenv("HOME") .. "/.notes"
end
