-- Particle Class
Particle = {}
Particle.__index = Particle

function Particle:new(x, y, speedX, speedY, lifetime, mass)
    local self = setmetatable({}, Particle)
    self.x = x or 0
    self.y = y or 0
    self.speedX = speedX or 0
    self.speedY = speedY or 0
    self.lifetime = lifetime or 3  -- particles will last for 3 seconds by default
    self.mass = mass or 1 -- default mass of 1
    return self
end

function Particle:draw()
    love.graphics.setColor(white)
    love.graphics.circle("fill", self.x, self.y, 0.5)  -- Change size here
end


return Particle
