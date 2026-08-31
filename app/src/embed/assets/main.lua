io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")
if arg[#arg] == "-debug" then require("mobdebug").start() end

require "collision"
require "settings"

alphaClignotant = 1

function love.load()
  screen_with = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()
  
  feu = {}
  feu.frames = {}
  feu.frames[1] = love.graphics.newImage("images/feu1.png")
  feu.frames[2] = love.graphics.newImage("images/feu2.png")
  feu.frames[3] = love.graphics.newImage("images/feu4.png")
  feu.currentFrame = 1
  
  obstacle = {}
  obstacle[1] = love.graphics.newImage("images/barril.png")
  obstacle[2] = love.graphics.newImage("images/box.png")
  obstacle[3] = love.graphics.newImage("images/tuyau1.png")
  --obstacle[4] = a été mis dans l'update a cause de l'animation
  currentObstacle = love.math.random(1,4)
  obstacle.x = 1200
  obstacle.y = 400
  obstacle.scaleY = 2.5
  obstacle.hitBoxX = obstacle.x + 5
  obstacle.hitBoxY = obstacle.y + 5
  obstacle.hitBoxW = 20
  obstacle.hitBoxH = 68
  
  obstacle2 = {}
  obstacle2[1] = love.graphics.newImage("images/barril.png")
  obstacle2[2] = love.graphics.newImage("images/box.png")
  obstacle2[3] = love.graphics.newImage("images/tuyau1.png")
  --obstacle2[4] = a été mis dans l'update a cause de l'animation
  currentObstacle2 = love.math.random(1,4)
  obstacle2.x = 2000
  obstacle2.y = 400
  obstacle2.scaleY = 2.5
  obstacle2.hitBoxX = obstacle2.x + 5
  obstacle2.hitBoxY = obstacle2.y + 5
  obstacle2.hitBoxW = 20
  obstacle2.hitBoxH = 68
  
  font = love.graphics.newFont("font.ttf", 20)
  font2 = love.graphics.newFont("font.ttf", 70)
  
  fond = love.graphics.newImage("images/fond.png")
  fondY = 0
  
  joueur = {}
  joueur.x = 350
  joueur.y = 387
  joueur.speed = 100
  joueur.gravity = 800
  joueur.hitBoxX = joueur.x + 10
  joueur.hitBoxY = joueur.y
  joueur.hitBoxW = 34
  joueur.hitBoxH = 68
  joueur.scale = 0.14
  joueur.img = love.graphics.newImage("images/idle.png")
  
  -- chargement du perso ---------------------
  
  joueurRun = {}
  joueurRun.frames = {}
  joueurRun.frames[1]  = love.graphics.newImage("images/Run__000.png")
  joueurRun.frames[2]  = love.graphics.newImage("images/Run__001.png")
  joueurRun.frames[3]  = love.graphics.newImage("images/Run__002.png")
  joueurRun.frames[4]  = love.graphics.newImage("images/Run__003.png")
  joueurRun.frames[5]  = love.graphics.newImage("images/Run__004.png")
  joueurRun.frames[6]  = love.graphics.newImage("images/Run__005.png")
  joueurRun.frames[7]  = love.graphics.newImage("images/Run__006.png")
  joueurRun.frames[8]  = love.graphics.newImage("images/Run__007.png")
  joueurRun.frames[9]  = love.graphics.newImage("images/Run__008.png")
  joueurRun.frames[10] = love.graphics.newImage("images/Run__009.png")
  joueurRun.currentFrame = 1
  
  joueurSlide = {}
  joueurSlide.frames = {}
  joueurSlide.frames[1]  = love.graphics.newImage("images/Slide__000.png")
  joueurSlide.frames[2]  = love.graphics.newImage("images/Slide__001.png")
  joueurSlide.frames[3]  = love.graphics.newImage("images/Slide__002.png")
  joueurSlide.frames[4]  = love.graphics.newImage("images/Slide__003.png")
  joueurSlide.frames[5]  = love.graphics.newImage("images/Slide__004.png")
  joueurSlide.frames[6]  = love.graphics.newImage("images/Slide__005.png")
  joueurSlide.frames[7]  = love.graphics.newImage("images/Slide__006.png")
  joueurSlide.frames[8]  = love.graphics.newImage("images/Slide__007.png")
  joueurSlide.frames[9]  = love.graphics.newImage("images/Slide__008.png")
  joueurSlide.frames[10] = love.graphics.newImage("images/Slide__009.png")
  joueurSlide.currentFrame = 1
  
  joueurJump = {}
  joueurJump.frames = {}
  joueurJump.frames[1]  = love.graphics.newImage("images/Jump__000.png")
  joueurJump.frames[2]  = love.graphics.newImage("images/Jump__001.png")
  joueurJump.frames[3]  = love.graphics.newImage("images/Jump__002.png")
  joueurJump.frames[4]  = love.graphics.newImage("images/Jump__003.png")
  joueurJump.frames[5]  = love.graphics.newImage("images/Jump__004.png")
  joueurJump.frames[6]  = love.graphics.newImage("images/Jump__005.png")
  joueurJump.frames[7]  = love.graphics.newImage("images/Jump__006.png")
  joueurJump.frames[8]  = love.graphics.newImage("images/Jump__007.png")
  joueurJump.frames[9]  = love.graphics.newImage("images/Jump__008.png")
  joueurJump.frames[10] = love.graphics.newImage("images/Jump__009.png")
  joueurJump.currentFrame = 1
  --------------------------------------------------------------------
  
  isJumping = false
  isDowning = false
  scrolling = 0
  speed = 400
  distance = 0
  meilleurScore = 0
  love.graphics.setFont(font)
  state = "menu"
  collision = false
  compteurStart = 6
  compteurAffichageGo = 1
  
  checkPointX = -1
  checkPointYHaut = -10
  checkPointYBas = 570
  
  offsetSlide = -18
  
  --son = love.audio.newSource("son.ogg", "stream")
  --son:setLooping(true)
  
  animation = "idle"
  
  charger()
  chargerCheckPoint()
  
end

function updateGame(dt)
  
  compteurStart = compteurStart - dt
  if compteurStart <= 0 then compteurStart = 0 end
  
  if collision == false and compteurStart <= 1 then
    compteurAffichageGo = compteurAffichageGo - dt
    if compteurAffichageGo <= 0 then compteurAffichageGo = 0 end
     -- scroll du fond
    scrolling = scrolling + (speed * dt)
    if scrolling >= fond:getWidth() then
      scrolling = 0
    end
    
    distance = distance + speed * dt / 100
    checkPointX = checkPointX - speed * dt
    
    -- animations du joueur et du barril de feu --------------------------
  joueurRun.currentFrame = joueurRun.currentFrame + dt * 20
  if joueurRun.currentFrame >= #joueurRun.frames + 1 then
    joueurRun.currentFrame = 1
  end
  joueurJump.currentFrame = joueurJump.currentFrame + dt * 15
  if joueurJump.currentFrame >= #joueurJump.frames + 1 then
    joueurJump.currentFrame = 1
  end
  joueurSlide.currentFrame = joueurSlide.currentFrame + dt * 15
  if joueurSlide.currentFrame >= #joueurSlide.frames + 1 then
    joueurSlide.currentFrame = 1
  end
  
  obstacle[4] = feu.frames[math.floor(feu.currentFrame)]
  obstacle2[4] = feu.frames[math.floor(feu.currentFrame)]
  feu.currentFrame = feu.currentFrame + dt * 15
  if feu.currentFrame >= #feu.frames + 1 then
    feu.currentFrame = 1
  end
    ----------------------------------------------
    
    if love.keyboard.isDown("down") and not joueur.isJumping and joueur.y >= 387 then
      animation = "slide"
      joueur.hitBoxY = 421
      joueur.y = joueur.y - offsetSlide
    else
      animation = "run"
      joueur.hitBoxY = joueur.y
    end
    
    if joueur.y < 387 then
      animation = "jump"
    end
    if animation == "slide" then
      joueur.y = joueur.y + offsetSlide
    elseif animation == "run" and joueur.y ~= 387 then
      joueur.y = 387
    end
    
    --augmentation de la vitesse
    if distance >= 50 and distance < 100 then
      speed = 500
    elseif distance >= 100 and distance < 180 then
      speed = 600
    elseif distance >= 180 and distance < 250 then
      speed = 800
    elseif distance >= 250 then
      speed = 1000
    end
    
    --scroll des obstacles
    obstacle.x = obstacle.x - speed * dt
    obstacle.hitBoxX = obstacle.hitBoxX - speed * dt
    if obstacle.x <= -50 then
      obstacle.x = 1200
      obstacle.hitBoxX = 1205
      currentObstacle = love.math.random(1,4)
    end
    if currentObstacle == 3 then
      obstacle.y = 2
      obstacle.hitBoxY = 335
      obstacle.scaleY = 2.7
    elseif currentObstacle == 4 then
      obstacle.y = 350
      obstacle.hitBoxY = 395
      obstacle.scaleY = 2.5
    else 
      obstacle.y = 400
      obstacle.hitBoxY = 405
      obstacle.scaleY = 2.5
    end
    
    obstacle2.x = obstacle2.x - speed * dt
    obstacle2.hitBoxX = obstacle2.hitBoxX - speed * dt
    if obstacle2.x <= -50 and obstacle.x > 450 then
      obstacle2.x = obstacle.x + 500
      obstacle2.hitBoxX = obstacle.x + 505
      currentObstacle2 = love.math.random(1,4)
    end
    if currentObstacle2 == 3 then
      obstacle2.y = 2
      obstacle2.hitBoxY = 335
      obstacle2.scaleY = 2.7
    elseif currentObstacle2 == 4 then
      obstacle2.y = 350
      obstacle2.hitBoxY = 395
      obstacle2.scaleY = 2.5
    else 
      obstacle2.y = 400
      obstacle2.hitBoxY = 405
      obstacle2.scaleY = 2.5
    end
    
    -- gestion du saut du joueur
    if isJumping then
      joueur.hitBoxY = joueur.hitBoxY - joueur.speed * dt * 3
      joueur.y = joueur.y - joueur.speed * dt * 3
      joueur.speed = joueur.speed - joueur.gravity * dt
      if joueur.y >= 387 then -- Sol
        joueur.y = 387
        joueur.speed = 0
        joueur.isJumping = false
      end
    end
    
  end
    --test collisions joueur avec obstacle et obstacle 2
    if checkCollision(joueur.hitBoxX,joueur.hitBoxY,joueur.hitBoxW,joueur.hitBoxH,obstacle.hitBoxX,obstacle.hitBoxY,obstacle.hitBoxW,obstacle.hitBoxH) or
    checkCollision(joueur.hitBoxX,joueur.hitBoxY,joueur.hitBoxW,joueur.hitBoxH,obstacle2.hitBoxX,obstacle2.hitBoxY,obstacle2.hitBoxW,obstacle2.hitBoxH) then
      collision = true
    end
    
    --condition de sauvegarde
    if meilleurScore < distance and collision == true then
      meilleurScore = distance
      sauvegarder()
    end
    --condition de sauvegarde checkpoint
    if collision == true then
      checkPointX = meilleurScore * 100 + joueur.x
      sauvegarderCheckPoint()
    end
end

function updateMenu(dt)
  
  alphaClignotant = alphaClignotant - dt * 2
  if alphaClignotant <= 0 then alphaClignotant = 1 end
  
end

--systeme de sauvegarde------------------------------------
function sauvegarder()
    fichier = io.open("sauvegarde.txt", "w")
    heure_sauvegarde = os.time()
    fichier:write(math.floor(meilleurScore))
    fichier:close()
    return heure_sauvegarde
end

function sauvegarderCheckPoint()
  fichier = io.open("sauvegardeCheckPoint.txt", "w")
    heure_sauvegarde = os.time()
    fichier:write(math.floor(checkPointX))
    fichier:close()
    return heure_sauvegarde
end

function charger()
  fichier = io.open("sauvegarde.txt", "r")
  if fichier then
      meilleurScore = fichier:read("*number")
      fichier:close()
  end
end

function chargerCheckPoint()
  fichier = io.open("sauvegardeCheckPoint.txt", "r")
  if fichier then
      checkPointX = fichier:read("*number")
      fichier:close()
  end
end
-----------------------------------------------------------

function drawGame()
  
    if collision == true then
      love.graphics.setColor(0.4,0.4,0.4,1)
      love.graphics.rectangle("fill", 0, 0, screen_with, screen_height)
    end
  
    for n = 1, 2 do
      love.graphics.draw(fond, ((n - 1) * fond:getWidth() - scrolling), fondY)
    end
    if compteurStart > 1 then 
      love.graphics.print(math.floor(compteurStart), 450, 280) 
      love.graphics.print("ESPACE : Sauter", 410, 390)
      love.graphics.print("Fleche du bas : Glisser", 410, 410)
      love.graphics.print("Echap : retour au menu", 410, 430)
    else
      if compteurAffichageGo > 0 and collision == false then 
        love.graphics.print("GO !", 440, 280) 
        --love.audio.play(son)
      end
    end
    if compteurStart <= 1 then
      love.graphics.draw(obstacle[currentObstacle], obstacle.x, obstacle.y, 0, 2.5, 2.5)
      love.graphics.draw(obstacle2[currentObstacle2], obstacle2.x, obstacle2.y, 0, 2.5, 2.5)
    end
    if animation == "idle" then
      love.graphics.draw(joueur.img, joueur.x, joueur.y, 0, joueur.scale, joueur.scale)
    end
    if animation == "run" then
      love.graphics.draw(joueurRun.frames[math.floor(joueurRun.currentFrame)], joueur.x, joueur.y, 0, joueur.scale, joueur.scale)
    end
    if animation == "jump" then
      love.graphics.draw(joueurJump.frames[math.floor(joueurJump.currentFrame)], joueur.x, joueur.y, 0, joueur.scale, joueur.scale)
    end
    if animation == "slide" then
      love.graphics.draw(joueurSlide.frames[math.floor(joueurSlide.currentFrame)], joueur.x, joueur.y - offsetSlide, 0, joueur.scale, joueur.scale)
    end
    --love.graphics.rectangle("line", joueur.hitBoxX, joueur.hitBoxY, joueur.hitBoxW, joueur.hitBoxH)--hitbox joueur
    --love.graphics.rectangle("line", obstacle.hitBoxX, obstacle.hitBoxY, obstacle.hitBoxW, obstacle.hitBoxH)--hitbox obstacle
    --love.graphics.rectangle("line", obstacle2.hitBoxX, obstacle2.hitBoxY, obstacle2.hitBoxW, obstacle2.hitBoxH)--hitbox obstacle 2
    love.graphics.setColor(0,0,0)
    love.graphics.print("Distance parcourue : "..math.floor(distance), 15, 15)
    love.graphics.print("Meilleur score : "..math.floor(meilleurScore), 760, 15)
    love.graphics.setColor(1,0,0)
    love.graphics.line(checkPointX, checkPointYBas, checkPointX, checkPointYHaut)
    love.graphics.setColor(1,1,1)
    if collision == true then
      love.graphics.setFont(font2)
      love.graphics.print("GAME OVER", 270, 200)
      love.graphics.setFont(font)
      love.graphics.print('"ENTREE" pour rejouer', 370, 300)
      --love.audio.stop(son)
    end
    
end

function drawMenu()
  
  love.graphics.draw(fond, 0, fondY)
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(font2)
  love.graphics.print("INDY RUN", 315, 30)
  love.graphics.setFont(font)
  love.graphics.setColor(1,1,1,alphaClignotant)
  love.graphics.print('"ENTREE" pour jouer', 380, 260)
  love.graphics.setColor(1,1,1)
end

function love.update(dt)
 if state == "game" then
    updateGame(dt)
  end
  if state == "menu" then
    love.load()
    updateMenu(dt)
  end
end

function love.draw()
  -- dessin du scroll du fond
  if state == "game" then
    drawGame()
  end
  if state == "menu" then
    love.load()
    drawMenu()
  end
end

function love.keypressed(key)
  if key == "space" and not joueur.isJumping and joueur.y == 387 and state == "game" and compteurStart <= 1 then
    isJumping = true
    joueur.speed = 200
  end
  if key == "return" and collision == true then
    love.load()
  end
  if key == "return" and state == "menu" then
    state = "game"
  end
  if key == "escape" then
    love.load()
  end
end