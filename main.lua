debug = true

player = { x = 200, y = 710, speed = 250, img = nil}
isAlive = true
score = 0

-- Timers
-- declare these here so no need to edit them in multiple places
canShoot = true
canShootTimerMax = 0.2
canShootTimer = canShootTimerMax

createEnenmyTimerMax = 0.4
createEnenmyTimer = createEnenmyTimerMax


-- Image Storage
bulletImg = nil
enemyImg = nil

-- bullet entity storage
bullets =  {}  -- array of current bullets being drawn and updated
enemies = {}


-- collision detection function taken from http://love2d.org/wiki/BoundingBox.lua
-- return true if 2 boxes overlap, false otherwise
-- x1, y1 are the left top coords of the first box, w1 and h1 its width & height
-- similar for x2, y2, w2, h2
function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
         x2 < x1 + w1 and
         y1 < y2 + h2 and
         y2 < y1 + h1
end


function love.load(arg)
  player.img = love.graphics.newImage('assets/plane.png')
  bulletImg = love.graphics.newImage('assets/bullet.png')
  enemyImg = love.graphics.newImage('assets/enemy.png')
end


function love.update(dt)
  -- start with an easy way to exti the game
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('left', 'a') then
    if player.x > 0 then  -- binds the player to the map
      player.x = player.x - (player.speed * dt)
    end
  elseif love.keyboard.isDown('right', 'd') then
    if player.x < (love.graphics.getWidth() - player.img:getWidth()) then
      player.x = player.x + (player.speed * dt)
    end
  end

  if love.keyboard.isDown('space', 'rctrl', 'lctrl') and canShoot then
    -- create some bullets
    newBullet = { x = player.x + (player.img:getWidth() / 2),
                  y = player.y, img = bulletImg }
    table.insert(bullets, newBullet)
    canShoot = false
    canShootTimer = canShootTimerMax
  end

  if not isAlive and love.keyboard.isDown('r') then
    -- remove all the bullets and enemies from screen
    bullets = {}
    enemies = {}

    -- reset Timers
    canShootTimer = canShootTimerMax
    createEnenmyTimer = createEnenmyTimerMax

    -- move player back to default pos
    player.x = 50
    player.y = 710

    -- reset game state
    score = 0
    isAlive = true
  end

  -- update the positions of the bullets
  for i, bullet in ipairs(bullets) do
    bullet.y = bullet.y - (250 * dt)

    if bullet.y < 0 then  -- remove a bullet if it would leave the top of screen
      table.remove(bullets, i)
    end
  end

  -- time how far apart the shots can be fired
  canShootTimer = canShootTimer - (1 * dt)
  if canShootTimer < 0 then
    canShoot = true
  end

  -- time out enemy creation
  createEnenmyTimer = createEnenmyTimer - (1 * dt)
  if createEnenmyTimer < 0 then
    createEnenmyTimer = createEnenmyTimerMax

    -- create an enemy
    randNum = math.random(10, love.graphics.getWidth() - 10)
    newEnemy = {x = randNum, y = -10, img = enemyImg}
    table.insert(enemies, newEnemy)
  end

  for i, enemy in ipairs(enemies) do
    enemy.y = enemy.y + (200 * dt)

    if enemy.y > 850 then  -- if an enemy leaves the screen delete it
      table.remove(enemies, i)
    end
  end

  -- run collision detection
  -- since there will be fewer enemies on screen than bullets we'll loop them first
  -- also we need to check if the player is hit by an enemy
  for i, enemy in ipairs(enemies) do
    for j, bullet in ipairs(bullets) do
      if checkCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
                        bullet.x, bullet.y, bullet.img:getWidth(), bullet.img:getHeight()) then
                          table.remove(bullets, j)
                          table.remove(enemies, i)
                          score = score + 1
      end
    end

    if checkCollision(enemy.x, enemy.y, enemy.img:getWidth(), enemy.img:getHeight(),
                      player.x, player.y, player.img:getWidth(), player.img:getHeight()) and isAlive then
                        table.remove(enemies, i)
                        isAlive = false
    end
  end

end


function love.draw(dt)
  if isAlive then
    love.graphics.draw(player.img, player.x, player.y)
  else
    love.graphics.print("Press 'R' to restart.", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 - 10)
  end 

  for i, bullet in ipairs(bullets) do
    love.graphics.draw(bullet.img, bullet.x, bullet.y)
  end

  for i, enemy in ipairs(enemies) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end
end
