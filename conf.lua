-- conf.lua
function love.conf(t)
    t.window.title = "Unmanned Gravity Simulator"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop" -- Use "desktop" for borderless fullscreen
end
