local string = require "string"
local io = require "io"
local ffi = require "ffi"
local C = ffi.C
local bit = require "bit"
local bor = bit.bor
local ngx_localtime = ngx.localtime
local setmetatable = setmetatable
local _error = error

-- table.new(narr, nrec)
local succ, new_tab = pcall(require, "table.new")
if not succ then
    new_tab = function() return {} end
end

local _M = new_tab(0, 5)

_M._VERSION = '0.02'

ffi.cdef[[
    int write(int fd, const char *buf, int nbyte);
    int open(const char *path, int access, int mode);
    int close(int fd);
]]

_M.O_RDONLY = 0
_M.O_WRONLY = 0
_M.O_RDWR = 0
_M.O_CREAT = 0
_M.O_APPEND = 0

_M.S_IRWXU = 0x01c0
_M.S_IRGRP = 0x0020
_M.S_IROTH = 0x0004

local system = string.match(io.popen("uname -a", "r"):read(), "%w+")
if system == "Darwin" then
    _M.O_RDONLY = 0x0000
    _M.O_WRONLY = 0x0001
    _M.O_RDWR   = 0x0002
    _M.O_CREAT  = 0x0200
    _M.O_APPEND = 0x0008
else -- Linux or other
    _M.O_RDONLY = 0x0000
    _M.O_WRONLY = 0x0001
    _M.O_RDWR   = 0x0002 
    _M.O_CREAT  = 0x0040
    _M.O_APPEND = 0x0400
end

-- log level
_M.LVL_DEBUG = 1
_M.LVL_INFO  = 2
_M.LVL_ERROR = 3
_M.LVL_NONE  = 999

_M.logger_level = _M.LVL_INFO
_M.logger_file = "/tmp/some.log"
_M.logger_fd = C.open(_M.logger_file,
    bor(_M.O_WRONLY, _M.O_CREAT, _M.O_APPEND),
    bor(_M.S_IRWXU, _M.S_IRGRP, _M.S_IROTH))

if _M.logger_fd == -1 then
    error("open log file " .. _M.logger_file .. " failed, errno: " .. tostring(ffi.errno()))
end

function _M.debug(self, msg)
		if self.logger_level > self.LVL_DEBUG then return end

		local c = ngx_localtime() .. " [DEBUG] " .. msg .. "\n"
		C.write(self.logger_fd, c, #c)
end

function _M.info(self, msg)
		if self.logger_level > self.LVL_INFO then return end
		
		local c = ngx_localtime() .. " [INFO] " .. msg .. "\n"
		C.write(self.logger_fd, c, #c)
end

function _M.error(self, msg)
		if self.logger_level > self.LVL_ERROR then return end

		local c = ngx_localtime() .. " [ERROR] " .. msg .. "\n"
		C.write(self.logger_fd, c, #c)
end

local class_mt = {
	-- to prevent use of casual module global variables
	__newindex = function (table, key, val)
		_error('attempt to write to undeclared variable "' .. key .. '"')
	end
}

setmetatable(_M, class_mt)

return _M
