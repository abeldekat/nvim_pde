.DEFAULT_GOAL = test_files_clued
GROUP_DEPTH ?= 1
NVIM_EXEC ?= nvim

# Download 'mini.nvim' to use its 'mini.test' testing module
deps/mini.nvim:
	@mkdir -p deps
	git clone --filter=blob:none https://github.com/nvim-mini/mini.nvim $@

test_files_clued: deps/mini.nvim
	for nvim_exec in $(NVIM_EXEC); do \
		printf "\n======\n\n" ; \
		$$nvim_exec --version | head -n 1 && echo '' ; \
		$$nvim_exec --headless --noplugin -u ./lua/akextra/minimal_init.lua \
			-c "lua require('mini.test').setup()" \
			-c "lua MiniTest.run_file('lua/akextra/test_files_clued.lua', { execute = { reporter = MiniTest.gen_reporter.stdout({ group_depth = $(GROUP_DEPTH) }) } })" ; \
	done

to_gh:
	@cp README.md LSP.md init.lua filetype.lua nvim-pack-lock.json .stylua.toml colors.txt .markdownlint.yml .prettierrc .gitignore Makefile ../nvimak
	@rm -rf ../nvimak/colors
	@rsync -av colors ../nvimak
	@rm -rf ../nvimak/tests
	@rsync -av tests ../nvimak
	@rm -rf ../nvimak/after
	@rsync -av after ../nvimak
	@rm -rf ../nvimak/lua
	@rsync -av lua ../nvimak
	@rm -rf ../nvimak/queries
	@rsync -av queries ../nvimak
	@rm -rf ../nvimak/plugin
	@rsync -av plugin ../nvimak
	@rm -rf ../nvimak/snippets
	@rsync -av snippets ../nvimak
