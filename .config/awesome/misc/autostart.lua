local awful = require "awful"

-- autostart
-- ~~~~~~~~~

-- Autostart application list
local applications = {
    "xset r rate 200 40",
    "picom --config $HOME/.config/awesome/misc/picom/panthom.conf &",
    "touchegg &",
    "/usr/bin/polkit-dumb-agent &",
}

-- startup apps runner
local function run(command, pidof)
    -- emended from manilarome
    local findme = command
    local firstspace = command:find(' ')
    if firstspace then
        findme = command:sub(0, firstspace - 1)
    end

    awful.spawn.easy_async_with_shell(string.format('pgrep -u $USER -x %s > /dev/null || (%s)', pidof or findme, command))
end

-- Run autostart
for _, prc in ipairs(applications) do
    run(prc)
end