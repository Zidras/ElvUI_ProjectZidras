local parent, ns = ...
local Private = ns.Compat.Private

local type = type
local pcall = pcall
local print = print
local format = string.format
local UnitExists = UnitExists

function Private.Noop()
end

function Private.Print(...)
	print("|cff33ff99Compat:|r", ...)
end

function Private.Printf(...)
	print("|cff33ff99Compat:|r", format(...))
end

function Private.Error(...)
	print("|cffff0000Compat Error:|r", format(...))
end

function Private.UnitExists(unit)
	return unit and UnitExists(unit)
end

function Private.QuickDispatch(func, ...)
	if type(func) ~= "function" then
		return
	end
	local ok, err = pcall(func, ...)
	if not ok then
		Private.Error(err)
		return
	end
	return true
end