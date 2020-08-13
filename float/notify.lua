-----------------------------------------------------------------------------------------------------------------------
--                                                RedFlat notify widget                                              --
-----------------------------------------------------------------------------------------------------------------------
-- Floating widget with icon, text, and progress bar
-- special for volume and brightness indication
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local beautiful = require("beautiful")

local awful = require("awful")

local redutil = require("redflat.util")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local notify = { last = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_args()
	local args = {
		timeout         = 5,
		icon            = nil,
		urgency					= nil,
		appname				  = "awesomewm",
		hint						= nil,
		id							= nil,
	}
	return redutil.table.merge(args, redutil.table.check(beautiful, "float.notify") or {})
end

-- Initialize notify widget
-----------------------------------------------------------------------------------------------------------------------
function notify:init()
	self.args = default_args()
end

-- Show notify widget
-----------------------------------------------------------------------------------------------------------------------
function notify:show(args)
	if not self.args then self:init() end

	local all_args = redutil.table.merge(self.args, args)

	local cmd = "dunstify "
	if all_args.appname then
		cmd = cmd .. "--appname='" .. all_args.appname .. "' "
	end
	if all_args.urgency then
		cmd = cmd .. "--urgency='" .. all_args.urgency .. "' "
	end
	if all_args.icon then
		cmd = cmd .. " --icon='" .. all_args.icon .."' "
	end
	if all_args.timeout then
		cmd = cmd .. "--timeout=" .. (all_args.timeout * 1000) .. " "
	end
	if  all_args.id then
		cmd = cmd .. "-r \"" .. all_args.id .. "\" "
	end
	if all_args.hint then
		-- TODO: use an array instead?
		--h, --hint=TYPE:NAME:VALUE        Specifies basic extra data to pass. Valid types are int, double, string and byte.
		cmd = cmd .. "--hint='" .. all_args.hint .. "'"
	end

	-- FOR DEBUGGING
	-- awful.spawn("notify-send \"" .. cmd .. "' " .. all_args.text .. "'\"")
	awful.spawn(cmd .. "' " .. all_args.text .. "'")
end

-- End
-----------------------------------------------------------------------------------------------------------------------
return notify