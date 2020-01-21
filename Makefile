# Requires `love`, love2d.org. Developed on LÖVE 11.3.
game: love-command
	@love .

MAKEFILE := $(lastword $(MAKEFILE_LIST))

include .Makefile.d-init.mk
include .Makefile.d/command.mk

# Note: LÖVE ships with its own LuaJIT implementation.
include .Makefile.d/luajit.mk

lua: lua-command
	@$(LUA)
