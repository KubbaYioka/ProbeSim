-- Import the Particle class
local Particle = require("Particle")

math.randomseed(os.time())

-- Colors
white = {1, 1, 1}
black = {0, 0, 0}
gray = {0.5, 0.5, 0.5}

-- Simulation Speed
simulationSpeed = 1

-- Panning
panX = 0
panY = 0
isPanning = false
initialPanX = 0
initialPanY = 0

-- Zoom
scaleFactor = 1

-- Slider for simulation speed
slider = {
    x = 10,
    y = 10,
    width = 200,
    height = 20,
    min = 0,
    max = 10,
    value = 1,
    handleWidth = 10,
    handlePosition = 0
}

slider.handlePosition = (slider.value - slider.min) / (slider.max - slider.min) * slider.width

-- Planet Class
Planet = {}
Planet.__index = Planet

function Planet:new(x, y, radius, mass)
    local self = setmetatable({}, Planet)
    self.x = x or love.graphics.getWidth() / 2
    self.y = y or love.graphics.getHeight() / 2
    self.radius = radius or 50
    self.mass = mass or 1000
    return self
end

function Planet:draw()
    love.graphics.setColor(white)
    love.graphics.circle("fill", self.x, self.y, self.radius)
end

-- Probe Class
Probe = {}
Probe.__index = Probe

function Probe:new(x, y, speedX, speedY, mass)
    local self = setmetatable({}, Probe)
    self.x = x or 0
    self.y = y or 0
    self.speedX = speedX or 0
    self.speedY = speedY or 2
    self.mass = mass or 1
    return self
end

function Probe:draw()
    love.graphics.setColor(white)
    love.graphics.circle("fill", self.x, self.y, 5)
end

-- List to hold particles
particles = {}

-- Create instances of Planet and Probe
earth = Planet:new()
mars = Planet:new(400, 300, 40, 800)
probe1 = Probe:new(earth.x + 100, earth.y)
probe2 = Probe:new(mars.x - 100, mars.y, 0, -2)

function love.update(dt)
    dt = dt * simulationSpeed

    -- Updated collision detection in love.update
    for _, planet in ipairs({earth, mars}) do
        for _, probe in ipairs({probe1, probe2}) do
            local dx = planet.x - probe.x
            local dy = planet.y - probe.y
            local distance = math.sqrt(dx * dx + dy * dy)
            -- Collision detection and explosion
            if distance < planet.radius then
                -- Generate 5-8 particles
                local particleCount = math.random(5, 12) -- Later, this number should scale to the mass of the probe that crashed
                for i = 1, particleCount do
                    local probeAngle = math.atan2(probe.speedY, probe.speedX)
                    local dispersionAngle = math.random() * math.pi/3 - math.pi/6  -- Random angle between -90 and 90 degrees
                    local angle = probeAngle + dispersionAngle
                    local speed = math.random(10, 20)  -- random speed between 50 and 100
                    local particle = Particle:new(probe.x, probe.y, math.cos(angle) * speed, math.sin(angle) * speed, nil, probe.mass)
                    table.insert(particles, particle)
                end
                -- Remove the probe
                probe.x, probe.y = -1000, -1000  -- move it off-screen
            end
        end
    end

    for i, particle in ipairs(particles) do
        particle.lifetime = particle.lifetime - dt
        if particle.lifetime <= 0 then
            table.remove(particles, i)
        end
    end

    for _, planet in ipairs({earth, mars}) do
        for i, particle in ipairs(particles) do
            local dx = planet.x - particle.x
            local dy = planet.y - particle.y
            local distance = math.sqrt(dx * dx + dy * dy)
            if distance < planet.radius then
                table.remove(particles, i)
            end
        end
    end

    -- Gravitational force calculations and probe movement
    for _, planet in ipairs({earth, mars}) do
        for _, probe in ipairs({probe1, probe2}) do
            local dx = planet.x - probe.x
            local dy = planet.y - probe.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            local force = (planet.mass * probe.mass) / (distance * distance)
            local fx = force * (dx / distance)
            local fy = force * (dy / distance)
            
            probe.speedX = probe.speedX + fx / probe.mass * dt
            probe.speedY = probe.speedY + fy / probe.mass * dt

            probe.x = probe.x + probe.speedX * dt
            probe.y = probe.y + probe.speedY * dt
        end
    end

    for _, planet in ipairs({earth, mars}) do
        for _, particle in ipairs(particles) do
            local dx = planet.x - particle.x
            local dy = planet.y - particle.y
            local distance = math.sqrt(dx * dx + dy * dy)
            
            local force = (planet.mass * particle.mass) / (distance * distance)
            local fx = force * (dx / distance)
            local fy = force * (dy / distance)
            
            particle.speedX = particle.speedX + fx / particle.mass * dt
            particle.speedY = particle.speedY + fy / particle.mass * dt
    
            particle.x = particle.x + particle.speedX * dt
            particle.y = particle.y + particle.speedY * dt
        end
    end
  
    -- Update particle positions
    for _, particle in ipairs(particles) do
        particle.x = particle.x + particle.speedX * dt
        particle.y = particle.y + particle.speedY * dt
    end

    -- Slider update
    local mouseX, mouseY = love.mouse.getPosition()
    if love.mouse.isDown(1) and mouseX > slider.x and mouseX < slider.x + slider.width and mouseY > slider.y and mouseY < slider.y + slider.height then
        slider.handlePosition = mouseX - slider.x
        slider.value = slider.handlePosition / slider.width * (slider.max - slider.min) + slider.min
        simulationSpeed = slider.value
    else
        -- Panning
        if isPanning then
            panX = mouseX - initialPanX
            panY = mouseY - initialPanY
        end
    end
end

function love.draw()
    -- Apply transformations for zoom and pan
    love.graphics.push()
    love.graphics.scale(scaleFactor, scaleFactor)
    love.graphics.translate(panX, panY)

    -- Draw all objects
    earth:draw()
    mars:draw()
    probe1:draw()
    probe2:draw()

    -- Drawing the particles
    for _, particle in ipairs(particles) do
        particle:draw()
    end

    love.graphics.pop()  -- Reset transformations

    -- Draw UI elements
    -- Slider background
    love.graphics.setColor(gray)
    love.graphics.rectangle("fill", slider.x, slider.y, slider.width, slider.height)
    -- Slider handle
    love.graphics.setColor(black)
    love.graphics.rectangle("fill", slider.x + slider.handlePosition, slider.y, slider.handleWidth, slider.height)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        initialPanX, initialPanY = x - panX, y - panY
        isPanning = true
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        isPanning = false
    end
end

function love.wheelmoved(x, y)
    if y > 0 then
        scaleFactor = scaleFactor * 1.1
    else
        scaleFactor = scaleFactor * 0.9
    end
end
