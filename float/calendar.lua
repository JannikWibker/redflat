-- Calendar widget

local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")


local calendar_widget = {}

local function worker(args)
  local calendar_themes = {
    dark = {
      bg = '#000000',
      fg = '#ffffff',
      focus_date_bg = '#ff00aa',
      focus_date_fg = '#ffffff',
      weekend_day_bg = '#111111',
      weekday_fg = '#ffffff',
      header_fg = '#ffffff',
      border = '#333333',
      border_radius = 0,
      font = 'Menlo 10'
    }
  }

  local args = args or {}

  if args.theme ~= nil and calendar_themes[args.theme] == nil then
    awful.spawn.with_shell('notify-send --urgency=normal "calendar widget no theme" "The calendar widget wasn\'t supplied a theme, using default"')
    args.theme = 'dark'
  end

  local theme = args.theme or 'dark'
  local placement = args.placement or 'top'

  local styles = {}

  local function rounded_shape(size)
    return function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, size)
    end
  end

  styles.month = {
    padding = 4,
    bg_color = calendar_themes[theme].bg,
    border_width = 0,
  }

  styles.normal = {
    markup = function(t) return t end,
    shape = rounded_shape(calendar_themes[theme].border_radius)
  }

  styles.focus = {
    fg_color = calendar_themes[theme].focus_date_fg,
    bg_color = calendar_themes[theme].focus_date_bg,
    markup = function(t) return '<b>' .. t .. '</b>' end,
    shape = rounded_shape(calendar_themes[theme].border_radius)
  }

  styles.header = {
    fg_color = calendar_themes[theme].header_fg,
    bg_color = calendar_themes[theme].bg,
    markup = function(t) return '<b>' .. t .. '</b>' end
  }

  styles.weekday = {
    fg_color = calendar_themes[theme].weekday_fg,
    bg_color = calendar_themes[theme].bg,
    markup = function(t) return '<b>' .. t .. '</b>' end,
  }

  local function decorate_cell(widget, flag, date)
    if flag == 'monthheader' and not styles.monthheader then
      flag = 'header'
    end
  
    -- highlight only today's day
    if flag == 'focus' then
      local today = os.date('*t')
      if today.month ~= date.month then
        flag = 'normal'
      end
    end
  
    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
      widget:set_markup(props.markup(widget:get_text()))
    end
    -- Change bg color for weekends
    local d = { year = date.year, month = (date.month or 1), day = (date.day or 1) }
    local weekday = tonumber(os.date('%w', os.time(d)))
    local default_bg = (weekday == 0 or weekday == 6) and calendar_themes[theme].weekend_day_bg or calendar_themes[theme].bg
    local ret = wibox.widget {
      {
        {
          widget,
          halign = 'center',
          widget = wibox.container.place
        },
        margins = (props.padding or 2) + (props.border_width or 0),
        widget = wibox.container.margin
      },
      shape = props.shape,
      shape_border_color = props.border_color or '#000000',
      shape_border_width = props.border_width or 0,
      fg = props.fg_color or calendar_themes[theme].fg,
      bg = props.bg_color or default_bg,
      widget = wibox.container.background
    }
  
    return ret
  end

  local cal = wibox.widget {
    date = os.date('*t'),
    font = calendar_themes[theme].font,
    fn_embed = decorate_cell,
    long_weekdays = true,
    widget = wibox.widget.calendar.month
  }

  local popup = awful.popup {
    ontop = true,
    visible = false,
    shape = rounded_shape(calendar_themes[theme].border_radius),
    offset = { y = 8 }, -- possibly replace this
    border_width = 2, -- possibly replace this
    border_color = calendar_themes[theme].border,
    widget = cal
  }

  local next_month = function()
    local a = cal:get_date()
    a.month = a.month + 1
    cal:set_date(nil)
    cal:set_date(a)
    popup:set_widget(cal)
  end

  local prev_month = function()
    local a = cal:get_date()
    a.month = a.month - 1
    cal:set_date(nil)
    cal:set_date(a)
    popup:set_widget(cal)
  end

  popup:buttons(
    awful.util.table.join(
      awful.button({}, 4, prev_month),
      awful.button({}, 5, next_month)
    )
  )

  function calendar_widget.toggle()

    if popup.visible then
      -- to faster render the calendar refresh it and just hide
      cal:set_date(nil) -- the new date is not set without removing the old one
      cal:set_date(os.date('*t'))
      popup:set_widget(nil) -- just in case
      popup:set_widget(cal)
      popup.visible = not popup.visible
    else
      if placement == 'top' then
        awful.placement.top(popup, { margins = { top = 32 }, parent = awful.screen.focused() })
      elseif placement == 'top_right' then
        awful.placement.top_right(popup, { margins = { top = 32, right = 10}, parent = awful.screen.focused() })
      elseif placement == 'bottom_right' then
        awful.placement.bottom_right(popup, { margins = { bottom = 32, right = 10}, parent = awful.screen.focused() })
      else
        awful.placement.top(popup, { margins = { top = 32 }, parent = awful.screen.focused() })
      end
  
      popup.visible = true
  
    end
  end
  
  return calendar_widget

end

return setmetatable(calendar_widget, { __call = function(_, ...)
  return worker(...)
end })