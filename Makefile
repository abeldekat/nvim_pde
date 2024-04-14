.DEFAULT_GOAL = has

#------------------ internal

#-- if not set, default to nvim
NVIM_APPNAME?=nvim

CACHE=~/.cache/${NVIM_APPNAME}
DATA=~/.local/share/${NVIM_APPNAME}
STATE=~/.local/state/${NVIM_APPNAME}
DEPS_DATA=~/.local/share/${NVIM_APPNAME}/site/pack/deps
DEPS_BACKUP=~/.local/share/${NVIM_APPNAME}/deps_bak
LAZY_DATA=~/.local/share/${NVIM_APPNAME}/lazy
LAZY_BACKUP=~/.local/share/${NVIM_APPNAME}/lazy_bak

clean_cache:
	@if [ -d ${CACHE} ]; then \
		rm -rf ${CACHE}; \
		echo "clean cache done"; \
	fi


backup_lazy:
	@if [ -d ${LAZY_DATA} ]; then \
		mv ${LAZY_DATA} ${LAZY_BACKUP}; \
		echo "backup lazy done"; \
	fi

restore_lazy:
	@if [ -d ${LAZY_BACKUP} ]; then \
		mv ${LAZY_BACKUP} ${LAZY_DATA}; \
		echo "restore lazy done"; \
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

#------------------  public

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
	@if [ -d ${LAZY_DATA} ]; then \
		echo "--> lazy installed <--"; \
		echo "--> #plugins"; \
		ls ${LAZY_DATA} | wc -l; \
	fi

deps_only: clean_cache backup_lazy restore_deps has

lazy_only: clean_cache backup_deps restore_lazy has

use_both: clean_cache restore_deps restore_lazy has

to_gh:
	@cp lazy-lock.json mini-deps-snap stylua.toml colors.txt .luarc.jsonc .gitignore init.lua Makefile ../nvimak
	@rm -rf ../nvimak/after
	@rsync -av after ../nvimak
	@rm -rf ../nvimak/lua
	@rsync -av lua ../nvimak
