vinote_ld_key = 'e'
cache_dir = os.getenv("HOME") .. "/.cache/vinote"
history_len = 100
logfile = "/tmp/vinote/vinote.log"


if root == nil then
  root = os.getenv("HOME") .. "/.notes"
end
