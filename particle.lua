-- Particle Class
Particle = {}
Particle.__index = Particle

function Particle:new(x, y, speedX, speedY, lifetime)
    local self = setmetatable({}, Particle)
    self.x = x or 0
    self.y = y or 0
    self.speedX = speedX or 0
    self.speedY = speedY or 0
    self.lifetime = lifetime or 3  -- particles will last for 3 seconds by default
    return self
end

function Particle:draw()
    love.graphics.setColor(white)
    love.graphics.circle("fill", self.x, self.y, 2)  -- small size for particles
end

return Particle
