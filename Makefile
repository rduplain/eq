# Requires `love`, love2d.org. Developed on LÖVE 11.3.
game: love-command lint
	@love .

test: lint
	lua -e 'require("dft").test()'

MAKEFILE := $(lastword $(MAKEFILE_LIST))

include .Makefile.d-init.mk
include .Makefile.d/command.mk

# Note: LÖVE ships with its own LuaJIT implementation.
include .Makefile.d/luajit.mk

lua: lua-command
	@$(LUA)

lint: luarocks-install
	@$(LUA_PREFIX)/bin/luacheck --no-color \
		--allow-defined-top \
		--globals love \
		--ignore _ \
		-- *.lua >&2

LUAROCKS_COMMANDS := \
	$(LUAROCKS) install luacheck 0.23.0

$(LUAROCKS_INSTALL): $(MAKEFILE)
