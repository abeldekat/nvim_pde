.DEFAULT_GOAL = to_gh

#------------------ internal

#-- if not set, default to nvim
NVIM_APPNAME?=nvim

CACHE=~/.cache/${NVIM_APPNAME}
DATA=~/.local/share/${NVIM_APPNAME}
STATE=~/.local/state/${NVIM_APPNAME}

clean_cache:
	@if [ -d ${CACHE} ]; then \
		rm -rf ${CACHE}; \
		echo "clean cache done"; \
	fi

clean: clean_cache
	@rm -rf ${DATA} ${STATE}
	echo "clean done";

to_gh:
	@cp README.md LSP.md init.lua filetype.lua nvim-pack-lock.json .stylua.toml colors.txt .luarc.jsonc .markdownlint.yml .prettierrc .gitignore Makefile ../nvimak
	@rm -rf ../nvimak/after
	@rsync -av after ../nvimak
	@rm -rf ../nvimak/colors
	@rsync -av colors ../nvimak
	@rm -rf ../nvimak/lua
	@rsync -av lua ../nvimak
	@rm -rf ../nvimak/queries
	@rsync -av queries ../nvimak
	@rm -rf ../nvimak/plugin
	@rsync -av plugin ../nvimak
	@rm -rf ../nvimak/snippets
	@rsync -av snippets ../nvimak
