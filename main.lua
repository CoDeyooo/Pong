push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle("Pong")

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('font.ttf', 8)
    largeFont = love.graphics.newFont('font.ttf', 16)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    love.graphics.setFont(smallFont)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = true,
        resizable = true,
        vsync = true,
    })

    -- Either 1 as in first(left) player or 2 as in second(right) player
    servingPlayer = 1
    winningPlayer = 1

    player1Score = 0
    player2Score = 0

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static')
    }

    player1 = Paddle(10, VIRTUAL_HEIGHT/2, 5, 20, PADDLE_SPEED, 'w', 's')
    player2 = Paddle(VIRTUAL_WIDTH-15, VIRTUAL_HEIGHT/2, 5, 20, PADDLE_SPEED, 'up', 'down')
    ball = Ball(VIRTUAL_WIDTH/2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = "start"
end


function love.update(dt)
    if gameState == 'serve' then
        if servingPlayer == 1 then
            ball.dx = -math.random(140, 200)
        else
            ball.dx = math.random(140, 200)
        end

    elseif gameState == "play" then
        -- Check player collision. The ball goes the opposite direction when it collides with a player
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.10
            ball.x = player1.x + 5

            randomizeBallVelocityButKeepDirection()
            sounds['paddle_hit']:play()
            
        elseif ball:collides(player2) then
            ball.dx = -ball.dx * 1.10
            ball.x = player2.x - 4

            randomizeBallVelocityButKeepDirection()
            sounds['paddle_hit']:play()
        end

        -- Increment the player's score when the ball reaches the VIRTUAL_WIDTH boundaries and reset the ball's positions
        if ball.x < 0 then
            player2Score = player2Score + 1
            servingPlayer = 2
            sounds['score']:play()

            if isVictorious(player2Score) then
                declareWinner(servingPlayer)
            else
                gameState = "serve"
                ball:reset()
            end
        elseif ball.x > VIRTUAL_WIDTH - 4 then
            player1Score = player1Score + 1
            servingPlayer = 1
            sounds['score']:play()

            if isVictorious(player1Score) then
                declareWinner(servingPlayer)
            else
                gameState = "serve"
                ball:reset()
            end
        end

        -- Define height boundaries. Goes the opposite direction when at a VIRTUAL_HEIGHT boundary
        changeBallDirectionIfBallHitsAnEdge()
    end

    if (gameState == "play") then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end


function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == '`' then -- cheat for player1 
        player1.height = 160
    elseif (key == 'enter' or key == 'return') then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'end' then
            ball:reset()
            player1Score = 0
            player2Score = 0
            gameState = 'serve'
        end
    end
end


function love.draw()
    push:apply('start')

    love.graphics.clear(40/255, 45/255, 52/255, 255/255)
    love.graphics.setFont(smallFont)

    displayGameStateMessage()
    displayPlayersScore()
    
    player1:render()
    player2:render()
    ball:render()

    displayFPS()

    push:apply('end')
end


function love.resize(w, h)
    push:resize(w, h)
end


function randomizeBallVelocityButKeepDirection()
    if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
    else
        ball.dy = math.random(10, 150)
    end
end


function changeBallDirectionIfBallHitsAnEdge()
    if ball.y <= 0 then
        ball.dy = -ball.dy
        ball.y = 0
        sounds['wall_hit']:play()

    elseif ball.y >= VIRTUAL_HEIGHT - 4 then
        ball.dy = -ball.dy
        ball.y = VIRTUAL_HEIGHT - 4
        sounds['wall_hit']:play()
    end
end


function isVictorious(playerScore)
    return playerScore == 10
end


function declareWinner(winner)
    winningPlayer = winner
    gameState = 'end'
end


function displayGameStateMessage()
    if gameState == 'start' then
        love.graphics.printf('Welcome To Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin...', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to serve...', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'end' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player ' .. tostring(winningPlayer) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')

        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart...', 0, 30, VIRTUAL_WIDTH, 'center')
    end
end


function displayPlayersScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH/2 + 30, VIRTUAL_HEIGHT/3)
end


function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255/255, 0, 255/255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end


