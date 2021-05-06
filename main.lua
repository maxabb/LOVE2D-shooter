function love.load()
    love.window.setTitle("Shooter")
    love.window.setMode(600, 900., {vsync=false})
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- controller
    joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]

    playing = true
    score = 0
    player = {sprite = love.graphics.newImage("images/tank.png"), x=275, y=840, w=7, h=7, s=300, d=0.1}
    bullets = {}
    enemies = {}
    velocity = 1000;
    enemySpeed = 100

    font = love.graphics.newFont("fonts/font.ttf", 30)

    math.randomseed(os.time())
end

function read_input_left()
    if joystick then
        return love.keyboard.isDown('d') or joystick:getGamepadAxis("leftx") > 0.1 or joystick:isGamepadDown("dpright")
    end
    return love.keyboard.isDown('d')
end

function read_input_right()
    if joystick then
        return love.keyboard.isDown('a') or joystick:getGamepadAxis("leftx") < -0.1 or joystick:isGamepadDown("dpleft")
    end
    return love.keyboard.isDown('a')
end

function read_input_fire()
    if joystick then
        return love.keyboard.isDown('space') or joystick:getGamepadAxis("triggerright") > 0.1
    end
    return love.keyboard.isDown('space')
end

function love.keypressed(key)
    if (key == 'escape') then
        love.event.quit()
    end
end

enemyDelay = 2
count = enemyDelay
function love.update(dt)
    if playing then
        if read_input_left() and player.x < 550 then
            player.x = player.x + player.s * dt
        end
        if read_input_right() and player.x > 0 then
            player.x = player.x - player.s * dt
        end

        if read_input_fire() and player.d < 0 then
            table.insert(bullets, create_bullet())
            player.d = 0.1
            score = score - 1
        else
            player.d = player.d - (1 * dt)
        end

        for index, bullet in pairs(bullets) do
            bullet.y = bullet.y - velocity * dt;

            if (bullet.y < 0) then
                bullets[index] = nil;
            end
        end

        for index, enemy in pairs(enemies) do
            enemy.y = enemy.y + (enemySpeed * dt);

            if enemy.y > 900 then
                enemies[index] = nil;
                playing = false
            end

            if (enemy.health < 1) then
                enemies[index] = nil;
                score = score + 2
                if (enemyDelay > 5) then
                    enemyDelay = enemyDelay - 0.1
                end
            end

            for index, bullet in pairs(bullets) do
                if bullet.x > enemy.x and bullet.x < enemy.x + 70 and bullet.y < enemy.y + 100 and bullet.y > enemy.y - 56 then
                    enemy.health = enemy.health - 1
                    bullets[index] = nil;
                end
            end
        end

        if count < 1 then
            table.insert(enemies, create_enemy())
            count = enemyDelay
        else
            count = count - (1 * dt)
        end
    end
end

function love.draw()
    if playing then
        -- player
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(player.sprite, math.floor(player.x), math.floor(player.y), 0, player.w, player.h)

        -- score
        love.graphics.printf(score, font, 0, 20, 600, 'center')

        --[[ fps (uncomment to show fps in left corner)
        love.graphics.setColor(0,1,0)
        love.graphics.printf("fps: " .. love.timer.getFPS(), 10, 10, 600, 'left')
        -- ]]

        -- bullets
        love.graphics.setColor(1, 0, 0)
        for index, bullet in pairs(bullets) do
            love.graphics.circle('fill', math.floor(bullet.x), math.floor(bullet.y), bullet.r)
        end

        -- enemies
        for index, enemy in pairs(enemies) do
            love.graphics.draw(enemy.sprite, math.floor(enemy.x), math.floor(enemy.y), 0, enemy.w, enemy.h)
        end
    else
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Final Score: " .. score, font, 0, 450, 600, 'center')
    end
end

function create_bullet()
    bullet = {x=player.x+25, y=player.y+15, r=3}
    return bullet;
end

function create_enemy()
    enemy = {sprite=love.graphics.newImage("images/enemy.png"), x=math.random(80, 520), y=10, w=7, h=7, health=1}
    return enemy
end
