Name
====

lua-resty-Logger - A local logger for ngx_lua

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Description](#description)
* [Synopsis](#synopsis)
* [Methods](#methods)
    * [open](#open)
    * [close](#close)
    * [get_level](#get_level)
    * [set_level](#set_level)
    * [debug](#debug)
    * [info](#info)
    * [error](#error)
* [Installation](#installation)
* [TODO](#todo)
* [Authors](#authors)
* [Copyrightand License](#copyright-and-license)

Status
======

This library is still experimental and under early development

Description
===========

This lua library is a local logging module for ngx_lua,

http://wiki.nginx.org/HttpLuaModule

This is aimed to enhance nginx log. As known to all, ngx.log which supported by ngx_lua prints logs in nginx error_log, however, many users of [openresty](http://openresty.org) as me have a demand for recording bussiness log into a specified file while recording system log into nginx error_log. This module can meed this demand.

This Lua library does NOT take advantage of ngx_lua's coroutine, which is not 100% nonblocking, BUT still effect, for reason that appending-write of os is very fast. 

Synopsis
========

```lua
    
    lua_package_path "/path/to/lua-resty-Logger/lib/?.lua;;";
    
    server {
        location /entry1 {
            content_by_lua '
                local logger = require "resty.logger"
                local buss1 = logger:open("buss1", "/var/log/business1.log")
                buss1:set_level(logger.INFO)
                buss1:info("hello world")
            ';
        }
        
        location /entry2 {
            log_by_lua '
                local logger = require "resty.logger"
                local buss2 = logger:open("buss2", "/var/log/business2.log")
                buss2:set_level(logger.ERROR)
                buss2:debug("every thing is ok")
            ';
        }
    }
```

[Back to TOC](#table-of-contents)

Methods
=======

open
----

close
-----

get_level
---------

set_level
---------

debug
-----

info
----

error
-----


