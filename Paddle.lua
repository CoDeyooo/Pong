Paddle = Class{}

function Paddle:init(x, y, width, height, speed, keyUp, keyDown)
    self.x = x
    self.y = y
    self.height = height
    self.width = width
    self.speed = speed
    self.keyUp = keyUp
    self.keyDown = keyDown
end

function Paddle:update(dt)
    if love.keyboard.isDown(self.keyUp) then
        self.y = math.max(0, self.y - self.speed * dt)
    elseif love.keyboard.isDown(self.keyDown) then
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.speed * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end