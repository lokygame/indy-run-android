-- Build Android RG Vita
io.stdout:setvbuf('no')
love.graphics.setDefaultFilter("nearest")

if arg[#arg] == "-debug" then
  require("mobdebug").start()
end

require "collision"
require "settings"


gamepad = nil

-----------------------------------------------------------
-- RESOLUTION LOGIQUE DU JEU
-----------------------------------------------------------

VIRTUAL_WIDTH = 980
VIRTUAL_HEIGHT = 560

scale = 1
offsetX = 0
offsetY = 0

alphaClignotant = 1


-----------------------------------------------------------
-- REINITIALISATION D'UNE PARTIE
-----------------------------------------------------------

function reinitialiserPartie()

  obstacle.x = 1200
  obstacle.y = 400
  obstacle.scaleY = 2.5
  obstacle.hitBoxX = obstacle.x + 5
  obstacle.hitBoxY = obstacle.y + 5
  obstacle.hitBoxW = 20
  obstacle.hitBoxH = 68
  currentObstacle = love.math.random(1, 4)

  obstacle2.x = 2000
  obstacle2.y = 400
  obstacle2.scaleY = 2.5
  obstacle2.hitBoxX = obstacle2.x + 5
  obstacle2.hitBoxY = obstacle2.y + 5
  obstacle2.hitBoxW = 20
  obstacle2.hitBoxH = 68
  currentObstacle2 = love.math.random(1, 4)

  joueur.x = 350
  joueur.y = 387
  joueur.speed = 100

  joueur.hitBoxX = joueur.x + 10
  joueur.hitBoxY = joueur.y
  joueur.hitBoxW = 34
  joueur.hitBoxH = 68

  joueurRun.currentFrame = 1
  joueurJump.currentFrame = 1
  joueurSlide.currentFrame = 1
  feu.currentFrame = 1

  isJumping = false
  isDowning = false

  scrolling = 0
  speed = 400
  distance = 0

  collision = false

  compteurStart = 6
  compteurAffichageGo = 1

  checkPointX = -1

  animation = "idle"

  alphaClignotant = 1

  sauvegardeFaite = false
end


-----------------------------------------------------------
-- CHARGEMENT DU JEU
-----------------------------------------------------------

function love.load()
  
  local joysticks = love.joystick.getJoysticks()

  if #joysticks > 0 then
    gamepad = joysticks[1]
  end

  ---------------------------------------------------------
  -- TAILLE REELLE DE L'ECRAN
  ---------------------------------------------------------

  screen_width = love.graphics.getWidth()
  screen_height = love.graphics.getHeight()

  ---------------------------------------------------------
  -- CALCUL DE L'ECHELLE
  -- On garde le ratio du jeu sans deformation
  ---------------------------------------------------------

  scale = math.min(
    screen_width / VIRTUAL_WIDTH,
    screen_height / VIRTUAL_HEIGHT
  )

  offsetX = (screen_width - VIRTUAL_WIDTH * scale) / 2
  offsetY = (screen_height - VIRTUAL_HEIGHT * scale) / 2


  ---------------------------------------------------------
  -- FEU
  ---------------------------------------------------------

  feu = {}
  feu.frames = {}

  feu.frames[1] = love.graphics.newImage("images/feu1.png")
  feu.frames[2] = love.graphics.newImage("images/feu2.png")
  feu.frames[3] = love.graphics.newImage("images/feu4.png")

  feu.currentFrame = 1


  ---------------------------------------------------------
  -- OBSTACLE 1
  ---------------------------------------------------------

  obstacle = {}

  obstacle[1] = love.graphics.newImage("images/barril.png")
  obstacle[2] = love.graphics.newImage("images/box.png")
  obstacle[3] = love.graphics.newImage("images/tuyau1.png")


  ---------------------------------------------------------
  -- OBSTACLE 2
  ---------------------------------------------------------

  obstacle2 = {}

  obstacle2[1] = love.graphics.newImage("images/barril.png")
  obstacle2[2] = love.graphics.newImage("images/box.png")
  obstacle2[3] = love.graphics.newImage("images/tuyau1.png")


  ---------------------------------------------------------
  -- POLICES
  ---------------------------------------------------------

  font = love.graphics.newFont("font.ttf", 20)
  font2 = love.graphics.newFont("font.ttf", 70)


  ---------------------------------------------------------
  -- FOND
  ---------------------------------------------------------

  fond = love.graphics.newImage("images/fond.png")
  fondY = 0


  ---------------------------------------------------------
  -- JOUEUR
  ---------------------------------------------------------

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


  ---------------------------------------------------------
  -- ANIMATION COURSE
  ---------------------------------------------------------

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


  ---------------------------------------------------------
  -- ANIMATION GLISSADE
  ---------------------------------------------------------

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


  ---------------------------------------------------------
  -- ANIMATION SAUT
  ---------------------------------------------------------

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


  ---------------------------------------------------------
  -- AUTRES VARIABLES
  ---------------------------------------------------------

  checkPointYHaut = -10
  checkPointYBas = 570

  offsetSlide = -18

  love.graphics.setFont(font)


  ---------------------------------------------------------
  -- CHARGEMENT DES SAUVEGARDES
  ---------------------------------------------------------

  meilleurScore = 0
  checkPointX = -1

  charger()
  chargerCheckPoint()


  ---------------------------------------------------------
  -- INITIALISATION
  ---------------------------------------------------------

  reinitialiserPartie()

  chargerCheckPoint()

  state = "menu"
end


-----------------------------------------------------------
-- UPDATE DU JEU
-----------------------------------------------------------

function updateGame(dt)

  compteurStart = compteurStart - dt

  if compteurStart <= 0 then
    compteurStart = 0
  end


  if collision == false and compteurStart <= 1 then

    compteurAffichageGo = compteurAffichageGo - dt

    if compteurAffichageGo <= 0 then
      compteurAffichageGo = 0
    end


    -------------------------------------------------------
    -- SCROLL DU FOND
    -------------------------------------------------------

    scrolling = scrolling + (speed * dt)

    if scrolling >= fond:getWidth() then
      scrolling = 0
    end


    -------------------------------------------------------
    -- DISTANCE
    -------------------------------------------------------

    distance = distance + speed * dt / 100

    checkPointX = checkPointX - speed * dt


    -------------------------------------------------------
    -- ANIMATIONS
    -------------------------------------------------------

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


    -------------------------------------------------------
    -- GLISSADE
    -------------------------------------------------------

    local glisse = love.keyboard.isDown("down")

    if gamepad and gamepad:isGamepad() then
      if gamepad:isGamepadDown("b") then
        glisse = true
      end
    end

    if glisse
      and not isJumping
      and joueur.y >= 387 then

        animation = "slide"

        joueur.hitBoxY = 421
        joueur.y = joueur.y - offsetSlide

    else

      animation = "run"
      joueur.hitBoxY = joueur.y

    end


    -------------------------------------------------------
    -- SAUT
    -------------------------------------------------------

    if joueur.y < 387 then
      animation = "jump"
    end


    if animation == "slide" then

      joueur.y = joueur.y + offsetSlide

    elseif animation == "run" and joueur.y ~= 387 then

      joueur.y = 387

    end


    -------------------------------------------------------
    -- VITESSE
    -------------------------------------------------------

    if distance >= 50 and distance < 100 then

      speed = 500

    elseif distance >= 100 and distance < 180 then

      speed = 600

    elseif distance >= 180 and distance < 250 then

      speed = 800

    elseif distance >= 250 then

      speed = 1000

    end


    -------------------------------------------------------
    -- OBSTACLE 1
    -------------------------------------------------------

    obstacle.x = obstacle.x - speed * dt
    obstacle.hitBoxX = obstacle.hitBoxX - speed * dt

    if obstacle.x <= -50 then

      obstacle.x = 1200
      obstacle.hitBoxX = 1205

      currentObstacle = love.math.random(1, 4)

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


    -------------------------------------------------------
    -- OBSTACLE 2
    -------------------------------------------------------

    obstacle2.x = obstacle2.x - speed * dt
    obstacle2.hitBoxX = obstacle2.hitBoxX - speed * dt

    if obstacle2.x <= -50 and obstacle.x > 450 then

      obstacle2.x = obstacle.x + 500
      obstacle2.hitBoxX = obstacle.x + 505

      currentObstacle2 = love.math.random(1, 4)

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


    -------------------------------------------------------
    -- PHYSIQUE DU SAUT
    -------------------------------------------------------

    if isJumping then

      joueur.hitBoxY = joueur.hitBoxY - joueur.speed * dt * 3
      joueur.y = joueur.y - joueur.speed * dt * 3

      joueur.speed = joueur.speed - joueur.gravity * dt


      if joueur.y >= 387 then

        joueur.y = 387
        joueur.hitBoxY = joueur.y

        joueur.speed = 0
        isJumping = false

      end

    end

  end


  ---------------------------------------------------------
  -- COLLISIONS
  ---------------------------------------------------------

  if
    checkCollision(
      joueur.hitBoxX,
      joueur.hitBoxY,
      joueur.hitBoxW,
      joueur.hitBoxH,
      obstacle.hitBoxX,
      obstacle.hitBoxY,
      obstacle.hitBoxW,
      obstacle.hitBoxH
    )
    or
    checkCollision(
      joueur.hitBoxX,
      joueur.hitBoxY,
      joueur.hitBoxW,
      joueur.hitBoxH,
      obstacle2.hitBoxX,
      obstacle2.hitBoxY,
      obstacle2.hitBoxW,
      obstacle2.hitBoxH
    )
  then

    collision = true

  end


  ---------------------------------------------------------
  -- SAUVEGARDE APRES GAME OVER
  ---------------------------------------------------------

  if collision == true and sauvegardeFaite == false then

    if meilleurScore < distance then

      meilleurScore = distance
      sauvegarder()

    end


    checkPointX = meilleurScore * 100 + joueur.x

    sauvegarderCheckPoint()

    sauvegardeFaite = true

  end
end


-----------------------------------------------------------
-- UPDATE MENU
-----------------------------------------------------------

function updateMenu(dt)

  alphaClignotant = alphaClignotant - dt * 2

  if alphaClignotant <= 0 then
    alphaClignotant = 1
  end

end


-----------------------------------------------------------
-- SAUVEGARDE
-----------------------------------------------------------

function sauvegarder()

  local heure_sauvegarde = os.time()

  love.filesystem.write(
    "sauvegarde.txt",
    tostring(math.floor(meilleurScore))
  )

  return heure_sauvegarde
end


function sauvegarderCheckPoint()

  local heure_sauvegarde = os.time()

  love.filesystem.write(
    "sauvegardeCheckPoint.txt",
    tostring(math.floor(checkPointX))
  )

  return heure_sauvegarde
end


-----------------------------------------------------------
-- CHARGEMENT
-----------------------------------------------------------

function charger()

  if love.filesystem.getInfo("sauvegarde.txt") then

    local contenu = love.filesystem.read("sauvegarde.txt")

    meilleurScore = tonumber(contenu) or 0

  end
end


function chargerCheckPoint()

  if love.filesystem.getInfo("sauvegardeCheckPoint.txt") then

    local contenu = love.filesystem.read("sauvegardeCheckPoint.txt")

    checkPointX = tonumber(contenu) or -1

  end
end


-----------------------------------------------------------
-- DESSIN DU JEU
-----------------------------------------------------------

function drawGame()

  if collision == true then

    love.graphics.setColor(0.4, 0.4, 0.4, 1)

    love.graphics.rectangle(
      "fill",
      0,
      0,
      VIRTUAL_WIDTH,
      VIRTUAL_HEIGHT
    )

  end


  for n = 1, 2 do

    love.graphics.draw(
      fond,
      ((n - 1) * fond:getWidth() - scrolling),
      fondY
    )

  end


  if compteurStart > 1 then

    love.graphics.print(
      math.floor(compteurStart),
      450,
      280
    )

    love.graphics.print(
      "A : Sauter",
      410,
      390
    )

    love.graphics.print(
      "B : Glisser",
      410,
      410
    )

    love.graphics.print(
      "SELECT : retour au menu",
      410,
      430
    )

  else

    if compteurAffichageGo > 0 and collision == false then

      love.graphics.print(
        "GO !",
        440,
        280
      )

    end

  end


  if compteurStart <= 1 then

    love.graphics.draw(
      obstacle[currentObstacle],
      obstacle.x,
      obstacle.y,
      0,
      2.5,
      2.5
    )

    love.graphics.draw(
      obstacle2[currentObstacle2],
      obstacle2.x,
      obstacle2.y,
      0,
      2.5,
      2.5
    )

  end


  ---------------------------------------------------------
  -- JOUEUR
  ---------------------------------------------------------

  if animation == "idle" then

    love.graphics.draw(
      joueur.img,
      joueur.x,
      joueur.y,
      0,
      joueur.scale,
      joueur.scale
    )

  end


  if animation == "run" then

    love.graphics.draw(
      joueurRun.frames[math.floor(joueurRun.currentFrame)],
      joueur.x,
      joueur.y,
      0,
      joueur.scale,
      joueur.scale
    )

  end


  if animation == "jump" then

    love.graphics.draw(
      joueurJump.frames[math.floor(joueurJump.currentFrame)],
      joueur.x,
      joueur.y,
      0,
      joueur.scale,
      joueur.scale
    )

  end


  if animation == "slide" then

    love.graphics.draw(
      joueurSlide.frames[math.floor(joueurSlide.currentFrame)],
      joueur.x,
      joueur.y - offsetSlide,
      0,
      joueur.scale,
      joueur.scale
    )

  end


  ---------------------------------------------------------
  -- INTERFACE
  ---------------------------------------------------------

  love.graphics.setColor(0, 0, 0)

  love.graphics.print(
    "Distance parcourue : " .. math.floor(distance),
    15,
    15
  )

  love.graphics.print(
    "Meilleur score : " .. math.floor(meilleurScore),
    760,
    15
  )


  love.graphics.setColor(1, 0, 0)

  love.graphics.line(
    checkPointX,
    checkPointYBas,
    checkPointX,
    checkPointYHaut
  )


  love.graphics.setColor(1, 1, 1)


  ---------------------------------------------------------
  -- GAME OVER
  ---------------------------------------------------------

  if collision == true then

    love.graphics.setFont(font2)

    love.graphics.print(
      "GAME OVER",
      270,
      200
    )

    love.graphics.setFont(font)

    love.graphics.print(
      '"START" pour rejouer',
      370,
      300
    )

  end

end


-----------------------------------------------------------
-- DESSIN MENU
-----------------------------------------------------------

function drawMenu()

  love.graphics.draw(
    fond,
    0,
    fondY
  )


  love.graphics.setColor(0, 0, 0)

  love.graphics.setFont(font2)

  love.graphics.print(
    "INDY RUN",
    315,
    30
  )


  love.graphics.setFont(font)

  love.graphics.setColor(
    1,
    1,
    1,
    alphaClignotant
  )

  love.graphics.print(
    '"START" pour jouer',
    380,
    260
  )


  love.graphics.setColor(1, 1, 1)

end


-----------------------------------------------------------
-- UPDATE GENERAL
-----------------------------------------------------------

function love.update(dt)

  if state == "game" then

    updateGame(dt)

  elseif state == "menu" then

    updateMenu(dt)

  end

end


-----------------------------------------------------------
-- AFFICHAGE GENERAL
-- ADAPTATION A L'ECRAN DE LA RG VITA
-----------------------------------------------------------

function love.draw()

  -- Fond noir si l'écran a quelques pixels libres
  love.graphics.clear(0, 0, 0, 1)

  love.graphics.push()

  -- Centre l'image
  love.graphics.translate(offsetX, offsetY)

  -- Agrandit le jeu 980x560 vers l'écran réel
  love.graphics.scale(scale, scale)


  if state == "game" then

    drawGame()

  elseif state == "menu" then

    drawMenu()

  end


  love.graphics.pop()

end


-----------------------------------------------------------
-- CLAVIER
-----------------------------------------------------------

function love.keypressed(key)

  ---------------------------------------------------------
  -- SAUTER
  ---------------------------------------------------------

  if
    key == "space"
    and not isJumping
    and joueur.y == 387
    and state == "game"
    and compteurStart <= 1
  then

    isJumping = true
    joueur.speed = 200

  end


  ---------------------------------------------------------
  -- REJOUER APRES GAME OVER
  ---------------------------------------------------------

  if
    key == "return"
    and state == "game"
    and collision == true
  then

    reinitialiserPartie()

    state = "game"

    return

  end


  ---------------------------------------------------------
  -- COMMENCER DEPUIS LE MENU
  ---------------------------------------------------------

  if
    key == "return"
    and state == "menu"
  then

    reinitialiserPartie()

    chargerCheckPoint()

    state = "game"

    return

  end


  ---------------------------------------------------------
  -- RETOUR AU MENU
  ---------------------------------------------------------

  if key == "escape" then

    reinitialiserPartie()

    chargerCheckPoint()

    state = "menu"

  end

end

function love.gamepadpressed(joystick, button)

  gamepad = joystick

  ---------------------------------------------------------
  -- SAUT
  ---------------------------------------------------------

  if button == "a"
    and not isJumping
    and joueur.y == 387
    and state == "game"
    and compteurStart <= 1
  then

    isJumping = true
    joueur.speed = 200

    return
  end


  ---------------------------------------------------------
  -- JOUER DEPUIS LE MENU
  ---------------------------------------------------------

  if button == "start"
    and state == "menu"
  then

    reinitialiserPartie()
    chargerCheckPoint()

    state = "game"

    return
  end


  ---------------------------------------------------------
  -- REJOUER
  ---------------------------------------------------------

  if button == "start"
    and state == "game"
    and collision == true
  then

    reinitialiserPartie()

    state = "game"

    return
  end


  ---------------------------------------------------------
  -- RETOUR MENU
  ---------------------------------------------------------

  if button == "back" then

    reinitialiserPartie()
    chargerCheckPoint()

    state = "menu"

    return
  end

end
