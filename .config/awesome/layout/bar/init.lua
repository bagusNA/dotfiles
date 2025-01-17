-- a minimal bar
-- ~~~~~~~~~~~~~

-- requirements
-- ~~~~~~~~~~~~
local awful         = require("awful")
local gears         = require("gears")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local helpers       = require("helpers")
local dpi           = beautiful.xresources.apply_dpi



-- misc/vars
-- ~~~~~~~~~

-- screen width
local screen_width = awful.screen.focused().geometry.width




-- connect to screen
-- ~~~~~~~~~~~~~~~~~
awful.screen.connect_for_each_screen(function(s)



    -- widgets
    -- ~~~~~~~

    -- taglist
    local taglist = require("layout.bar.taglist")(s)

    -- wifi
    local wifi = wibox.widget{
        markup = "",
        font = beautiful.icon_var .. "14",
        valign = "center",
        widget = wibox.widget.textbox
    }


    --------------------
    -- battery widget
    local bat_icon = wibox.widget{
        markup = "<span foreground='" .. beautiful.green_color .. "'></span>",
        font = beautiful.icon_var .. "11",
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local battery_progress = wibox.widget{
    	color				= beautiful.fg_color,
    	background_color	= "#00000000",
        forced_width        = dpi(28),
        border_width        = dpi(1),
        border_color        = beautiful.fg_color .. "A6",
        paddings             = dpi(3),
        bar_shape           = helpers.rrect(dpi(2)),
    	shape				= helpers.rrect(dpi(5)),
        value               = 70,
    	max_value 			= 100,
        widget              = wibox.widget.progressbar,
    }

    local battery_border = wibox.widget {
        wibox.widget.textbox,
        widget = wibox.container.background,
        bg = beautiful.fg_color .. "A6",
        forced_width = dpi(7.2),
        forced_height = dpi(7.2),
        shape = function(cr, width, height)
            gears.shape.pie(cr,width, height, 0, math.pi)
        end
    }

    local battery_border_container = wibox.widget{
        battery_border,
        direction = "east",
        widget = wibox.container.rotate()
    }
    
    local battery_text = wibox.widget {
        widget = wibox.widget.textbox,
    }

    local battery = wibox.widget{
        {
            battery_text,
            bat_icon,
            {
                battery_progress,
                battery_border_container,
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(-1.6)
            },
            layout = wibox.layout.fixed.horizontal,
            spacing = dpi(1)
        },
        widget = wibox.container.margin,
        margins = {top = dpi(9),bottom = dpi(9)}
    }


    -- clock
    local clock = wibox.widget{
        widget = wibox.widget.textclock,
        format = "%k:%M   %a %d",
        font = beautiful.font_var .. "Bold 13",
        valign = "center",
        align = "center"
    }

    -- System Tray
    local systray = wibox.widget {
        widget = wibox.widget.systray,
        base_size = dpi(20),
    }

    -- Window Title
    local window_title = wibox.widget {
        widget = wibox.widget.textbox,
    }

    -- Create a layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)

    -- layoutbox
    local layoutbox = wibox.widget{
        s.mylayoutbox,
        margins = {top = dpi(15), bottom = dpi(13)},
        widget = wibox.container.margin
    }



    -- update widgets accordingly
    -- ~~~~~~~~~~~~~~~~~~~~~~~~~~
    awesome.connect_signal("signal::battery", function(value) 
        battery_progress.value = value
        battery_text.markup = value .. "% "
    end)

    awesome.connect_signal("signal::charger", function(state)
        if state then
            bat_icon.visible = true
            battery_progress.color = beautiful.green_color
            battery_border.bg = beautiful.green_color
        else
            bat_icon.visible = false
            battery_progress.color = beautiful.fg_color
            battery_border.bg = beautiful.fg_color
        end
    end)

    awesome.connect_signal("signal::wifi", function (value)
        if value then
            wifi.markup = ""
        else
            wifi.markup = helpers.colorize_text("", beautiful.fg_color .. "99")
        end
    end)

    client.connect_signal("request::activate", function (client)
        window_title.markup = client.name
    end)

    client.connect_signal("property::name", function (client)
        window_title.markup = client.name
    end)

    tag.connect_signal("request::selected", function (tag)
        local clients = tag:clients()

        if not clients then
            window_title.markup = clients
        end
    end)

    client.connect_signal("request::unmanage", function (client)
        if (client.name == window_title.markup) then
            window_title.markup = ''
        end
    end)

    -- wibar
    s.wibar_wid = awful.wibar({
        screen      = s,
        visible     = true,
        ontop       = false,
        type        = "dock",
        height      = dpi(32),
        bg          = beautiful.bg_color,
        width       = screen_width
    })


    -- wibar placement
    awful.placement.top(s.wibar_wid)
    s.wibar_wid:struts{top = s.wibar_wid.height }

    -- bar setup
    s.wibar_wid:setup {
        {
            {
                clock,
                window_title,
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(12),
            },
            {
                {
                    nil,
                    {
                        taglist,
                        layout  = wibox.layout.fixed.vertical
                    },
                    expand = "none",
                    layout = wibox.layout.align.vertical
                },
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(20)
            },
            {
                {
                    systray,
                    widget = wibox.container.place,
                    valign = "center",
                },
                battery,
                wifi,
                -- layoutbox,
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(16)
            },
            layout = wibox.layout.align.horizontal,
            expand = "none"
        },
        layout = wibox.container.margin,
        margins = {left = dpi(14), right = dpi(14)}
    }

end)