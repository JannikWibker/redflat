-----------------------------------------------------------------------------------------------------------------------
--                                        RedFlat volume indicator widget                                            --
-----------------------------------------------------------------------------------------------------------------------
-- Indicator with audio icon
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local unpack = unpack or table.unpack

local wibox = require("wibox")
local beautiful = require("beautiful")

local redutil = require("redflat.util")
local svgbox = require("redflat.gauge.svgbox")
local reddash = require("redflat.gauge.graph.dash")

-- Initialize tables for module
-----------------------------------------------------------------------------------------------------------------------
local audio = { mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		width   = 100,
		icon    = {
			low  = redutil.base.placeholder(),
			high = redutil.base.placeholder(),
			off  = redutil.base.placeholder(),
			mute = redutil.base.placeholder()
		},
		gauge   = reddash.new,
		dash    = {},
		dmargin = { 10, 0, 0, 0 },
		color   = { icon = "#a0a0a0", mute = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.audio.blue") or {})
end

-- Create a new audio widget
-- @param style Table containing colors and geometry parameters for all elemets
-----------------------------------------------------------------------------------------------------------------------
function audio.new(style)

	-- Initialize vars
	--------------------------------------------------------------------------------
	style = redutil.table.merge(default_style(), style or {})

	-- Icon widget
	--------------------------------------------------------------------------------
	local icon = {
		placeholder = svgbox(style.icon.high),
		low  = svgbox(style.icon.low),
		high = svgbox(style.icon.high),
		off  = svgbox(style.icon.off),
		mute = svgbox(style.icon.mute)
	}

	icon.placeholder:set_color(style.color.icon)

	icon.low:set_color(style.color.icon)
	icon.high:set_color(style.color.icon)
	icon.off:set_color(style.color.mute)
	icon.mute:set_color(style.color.mute)

	-- Create widget
	local layout = wibox.layout.fixed.horizontal()

	local muted = nil
	local last_icon = icon.placeholder

	layout:add(last_icon)

	local dash
	if style.gauge then
		dash = style.gauge(style.dash)
		layout:add(wibox.container.margin(dash, unpack(style.dmargin)))
	end

	local widg = wibox.container.constraint(layout, "exact", style.width)

	-- User functions
	------------------------------------------------------------
	function widg:set_value(x)
		if muted == nil or not muted then
			if x < 0.1 then
				layout:set(1, icon.off)
			elseif x < 0.3 then
				layout:set(1, icon.low)
			else
				layout:set(1, icon.high)
			end
		end
		if dash then dash:set_value(x) end
	end

	function widg:set_mute(mute)
		if muted == nil or muted ~= mute then
			if mute then
				last_icon = layout.children[1]
				layout:set(1, icon.mute)
			else
				layout:set(1, last_icon)
				last_icon = icon.mute
			end
			muted = mute
			layout:emit_signal("widget::redraw_needed")
		end

	end

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call audio module as function
-----------------------------------------------------------------------------------------------------------------------
function audio.mt:__call(...)
	return audio.new(...)
end

return setmetatable(audio, audio.mt)