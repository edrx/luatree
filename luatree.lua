#!/usr/bin/env lua5.1
-- This file:
--   http://angg.twu.net/luatree/luatree.lua.html
--   http://angg.twu.net/luatree/luatree.lua
--           (find-angg "luatree/luatree.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
--
-- (defun m  () (interactive) (find-angg "luatree/luatree.mac"))
-- (defun li () (interactive) (find-angg "luatree/luatree.lisp"))
-- (defun lu () (interactive) (find-angg "luatree/luatree.lua"))
-- (find-es "maxima" "luatree")


--   ____ _               
--  / ___| | __ _ ___ ___ 
-- | |   | |/ _` / __/ __|
-- | |___| | (_| \__ \__ \
--  \____|_|\__,_|___/___/
--                        
-- From:   (find-angg "LUA/lua50init.lua" "Class")
-- http://angg.twu.net/LUA/lua50init.lua.html#Class
--
Class = {
    type   = "Class",
    __call = function (class, o) return setmetatable(o, class) end,
  }
setmetatable(Class, Class)

otype = function (o)  -- works like type, except on my "objects"
    local  mt = getmetatable(o)
    return mt and mt.type or type(o)
  end


--  ____           _   
-- |  _ \ ___  ___| |_ 
-- | |_) / _ \/ __| __|
-- |  _ <  __/ (__| |_ 
-- |_| \_\___|\___|\__|
--                     
-- From:   (find-angg "LUA/lua50init.lua" "Rect")
-- http://angg.twu.net/LUA/lua50init.lua.html#Rect
--
torect = function (o)
    if otype(o) == "Rect" then return o end
    if type(o) == "string" then return Rect.new(o) end
    error()
  end
--
Rect = Class {
  type = "Rect",
  new  = function (str) return Rect(splitlines(str)) end,
  rep  = function (str, n) local r=Rect{}; for i=1,n do r[i]=str end; return r end,
  from = function (o)
      if type(o) == "string" then return Rect.new(o) end
      if type(o) == "number" then return Rect.new(tostring(o)) end
      return o -- missing: test otypeness
    end,
  --
  -- A hack to let us build syntax trees very quickly:
  syntree = function (op, a1, ...)
      if not a1 then return Rect.from(op) end
      local r = Rect.from(a1):syn1(op)
      for _,an in ipairs({...}) do r = r:synconcat(Rect.from(an)) end
      return r
    end,
  --
  __tostring = function (rect) return rect:tostring() end,
  __concat = function (r1, r2) return torect(r1):concat(torect(r2)) end,
  __index = {
    tostring = function (rect) return table.concat(rect, "\n") end,
    copy = function (rect) return copy(rect) end,
    width = function (rect)
        return rect.w or foldl(max, 0, map(string.len, rect))
      end,
    push1 = function (rect, str) table.insert(rect, 1, str); return rect end,
    push2 = function (rect, str1, str2) return rect:push1(str2):push1(str1) end,
    pad0  = function (rect, y, w, c, rstr)
        rect[y] = ((rect[y] or "")..(c or " "):rep(w)):sub(1, w)..(rstr or "")
        return rect
      end,
    lower = function (rect, n, str)
        for i=1,n do rect:push1(str or "") end
        return rect
      end,
    concat = function (r1, r2, w, dy)
        r1 = r1:copy()
        w = w or r1:width()
        dy = dy or 0
        for y=#r1+1,#r2+dy do r1[y] = "" end
        for y=1,#r2 do r1:pad0(y+dy, w, nil, r2[y]) end
        return r1
      end,
    prepend = function (rect, str) return Rect.rep(str, #rect)..rect end,
    --
    -- Low-level methods for building syntax trees:
    --   syn1 draws a "|" above a rect and draws the opname above it,
    --   synconcat draws two syntax trees side by side and joins them with "_"s.
    syn1 = function (r1, opname) return r1:copy():push2(opname or ".", "|") end,
    synconcat = function (r1, r2)
        return r1:copy():pad0(1, r1:width()+2, "_")..r2:copy():push2(".", "|")
      end,
    --
    -- Low-level methods for building deduction trees:
    --   dedconcat draws two deduction trees side by side,
    --   dedsetbar draws or redraws the bar above the conclusion,
    --   dedaddroot adds a bar and a conclusion below some trees drawn
    --   side by side.
    dedconcat = function (r1, r2)
        local w = r1:width() + 2
        if #r1 <  #r2 then return r1:copy():lower(#r2-#r1):concat(r2, w) end
        if #r1 == #r2 then return r1:copy():concat(r2, w) end
        if #r1  > #r2 then return r1:copy():concat(r2, w, #r1-#r2) end
      end,
    dedsetbar = function (r, barchar, barname)
        if #r == 1 then table.insert(r, 1, "") end
        local trim = function (str) return (str:match("^(.-) *$")) end
        local strover  = trim(r[#r-2] or "")  -- the hypotheses above the bar
        local strunder = trim(r[#r])          -- the conclusion below the bar
        local len = max(#strover, #strunder)
	local bar = (barchar or "-"):rep(len)
        r[#r-1] = bar..(barname or "")
        return r
      end,
    dedaddroot = function (r, rootstr, barchar, barname)
        table.insert(r, "")                  -- The bar will be here.
        table.insert(r, rootstr)             -- Draw the conclusion,
        return r:dedsetbar(barchar, barname) -- and then set the bar.
      end,
  },
}


--  ____            _____              
-- / ___| _   _ _ _|_   _| __ ___  ___ 
-- \___ \| | | | '_ \| || '__/ _ \/ _ \
--  ___) | |_| | | | | || | |  __/  __/
-- |____/ \__, |_| |_|_||_|  \___|\___|
--        |___/                        
--
-- From:   (find-angg "LUA/lua50init.lua" "SynTree")
-- http://angg.twu.net/LUA/lua50init.lua.html#SynTree
--
SynTree = Class {
  type = "SynTree",
  from = function (A) return deepcopymt(A, SynTree) end,
  torect = function (o)
      if type(o) == "number" then return Rect.new(tostring(o)) end
      if type(o) == "string" then return Rect.new(o) end
      if type(o) == "table" then
	local op = o[0]
	if type(op) == "number" then op = tostring(op) end
        if #o == 0 then return Rect.new(op or ".") end
        local r = SynTree.torect(o[1]):syn1(op)
        for i=2,#o do r = r:synconcat(SynTree.torect(o[i])) end
        return r
      end
    end,
  __tostring = function (o) return o:torect():tostring() end,
  __index = {
    torect = function (o)
        return SynTree.torect(o)
      end,
  },
}


-- Process stdin:
bigstr = io.read("*a")
print(SynTree.from(expr(bigstr)))


--[[
 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
echo '{[0]="[", {[0]="/", "x", "y"}, "33"}' \
  | ./luatree.lua

--]]
