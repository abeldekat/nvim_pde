.DEFAULT_GOAL = has

#------------------ internal

#-- if not set, default to nvim
NVIM_APPNAME?=nvim

CACHE=~/.cache/${NVIM_APPNAME}
DATA=~/.local/share/${NVIM_APPNAME}
STATE=~/.local/state/${NVIM_APPNAME}
DEPS_DATA=~/.local/share/${NVIM_APPNAME}/site/pack/deps
DEPS_BACKUP=~/.local/share/${NVIM_APPNAME}/deps_bak

clean_cache:
	@if [ -d ${CACHE} ]; then \
		rm -rf ${CACHE}; \
		echo "clean cache done"; \
	fi

backup_deps:
	@if [ -d ${DEPS_DATA} ]; then \
		mv ${DEPS_DATA} ${DEPS_BACKUP}; \
		echo "backup deps done"; \
	fi

restore_deps:
	@if [ -d ${DEPS_BACKUP} ]; then \
		mv ${DEPS_BACKUP} ${DEPS_DATA}; \
		echo "restore deps done"; \
	fi

clean: clean_cache
	@rm -rf ${DATA} ${STATE}
	echo "clean done";

#----------------- Backup/restore
has:
	@echo "--> List data dir:"
	@ls ${DATA}
	@echo ""
	@echo "--> List pack dir:"
	@ls ${DATA}/site/pack
	@echo ""
	@if [ -d ${DEPS_DATA} ]; then \
		echo "--> deps installed <--"; \
		echo "--> # opt plugins"; \
		ls ${DEPS_DATA}/opt | wc -l; \
		echo "--> # start plugins"; \
		ls ${DEPS_DATA}/start | wc -l; \
	  echo ""; \
	fi

to_gh:
	@cp README.md init.lua filetype.lua mini-deps-snap stylua.toml colors.txt .luarc.*.jsonc .prettierrc .gitignore Makefile ../nvimak
	@rm -rf ../nvimak/after
	@rsync -av after ../nvimak
	@rm -rf ../nvimak/lua
	@rsync -av lua ../nvimak
