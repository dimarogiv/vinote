install:
	mkdir -p ~/.config/nvim/lua/vinote
	cp vinote.lua ~/.config/nvim/lua/vinote
	cp bindings.lua ~/.config/nvim/lua/vinote
	cp config.lua ~/.config/nvim/lua/vinote
	cp helpers.lua ~/.config/nvim/lua/vinote
	cp init.lua ~/.config/nvim/lua/vinote
	cp management.lua ~/.config/nvim/lua/vinote
	cp navigation.lua ~/.config/nvim/lua/vinote
	cp search.lua ~/.config/nvim/lua/vinote
	cp visual.lua ~/.config/nvim/lua/vinote
	sudo cp note /usr/local/bin
