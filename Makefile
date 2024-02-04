.DEFAULT_GOAL = init

#------------------ internal

# Build the plugins if needed
provision:
	nvim --headless -u init_provision.lua

# Initialize submodules and clone to the versions saved in this repo
# Also expand inner submodules(ie LuaSnip)
update:
	git submodule update --jobs 8 --init --filter=blob:none --progress --recursive

# Update to the latest versions of the remotes
upgrade:
	git submodule update --remote --init --filter=blob:none --progress

#------------------  public

init: update provision

sync: upgrade update provision
