-- Essentials mod

local json = require("libs.json")

IsEssentials = true

HALF_PI = math.pi / 2

function LerpRotation(old, new)
  return lerp(old,old+((new-old+2)%4-2),itime/delay)
end

local econfig = json.decode(love.filesystem.read("Essentials/config.json") or "{}", 0, 'null')

function GetEssentialsConfig()
  return CopyTable(econfig)
end

local Ereturns = {}

local essentialsMenu = false

local ver = "dededadsadawedas"
local v2 = "dededadsadawedas"

local loadedResourcer = false

function MakeTexture(texture, display)
  local img = love.graphics.newImage(texture)
  return {
    tex = img,
    size = {
      w = img:getWidth(),
      h = img:getHeight(),
      w2 = img:getWidth()/2,
      h2 = img:getHeight()/2,
    },
    display = display or "No display",
  }
end

local deleteTex = MakeTexture("textures/menu.png")

local componentPics = {}

function HasSecretKey(skey)
  for _, key in ipairs(econfig['secret_keys'] or {}) do
    if key == skey then
      return true
    end
  end
  return false
end

for _, component in ipairs(econfig['components']) do
  Ereturns[component] = require("Essentials/" .. component)
  local icon = MakeTexture("Essentials/Component Icons/" .. component .. ".png", component)
  if icon then
    table.insert(componentPics, icon)
  end
end

local customComponents = {}

local function runCustomComponentCallback(callbackName, ...)
  for _, cc in ipairs(customComponents) do
    if type(cc[callbackName]) == "function" then
      cc[callbackName](...)
    end
  end
end

local atime = 0
local frames = 0

local function init()
  if ver ~= v2 then
    error("Stop being dumbass")
  end

  if econfig['disable_music'] == true then
    music:stop()
  end

  showinstructions = false
  if Ereturns.MoreCells then
    table.insert(modcache, Ereturns.MoreCells)
  end
  for _, custom in ipairs(econfig['customComponents']) do
    local cc = require(custom)
  
    table.insert(customComponents, cc)
  end
  runCustomComponentCallback('load', CopyTable(econfig))
  DirFromOff = function(ox, oy)
    if ox > 0 then return 0 elseif ox < 0 then return 2 end
	  if oy > 0 then return 1 elseif oy < 0 then return 3 end
  end
end

local firstLoad = true

local function customupdate(dt)
  --if Keybind then Keybind.CancelNormal(true) end
  if firstLoad then
    firstLoad = false

    -- Do stuff on first load
    if HasSecretKey("flip-screen") then
      -- Apply flipping effect
      local d = love.draw
      love.draw = function()
        local w = love.graphics.getWidth()
        local h = love.graphics.getHeight()
        love.graphics.translate(w/2, h/2)
        love.graphics.rotate(HALF_PI*2)
        love.graphics.translate(-w/2, -h/2)
        d()
      end

      -- local m = love.mousepressed

      -- love.mousepressed = function(x, y, button, presses, tap)
      --   local w = love.graphics.getWidth()
      --   local h = love.graphics.getHeight()
      --   local ox = w/2
      --   local oy = h/2
      --   local dir = math.atan2(oy - y, ox - x) + math.pi
      --   local mag = math.sqrt((ox - x) ^ 2 + (oy - y) ^ 2)
      --   x = math.cos(dir) * mag + ox
      --   y = math.sin(dir) * mag + oy
      --   m(x, y, button, presses, tap)
      -- end

      -- local orgetx = love.mouse.getX
      -- local orgety = love.mouse.getY

      -- love.mouse.getX = function()
      --   local x, y = orgetx(), orgety()
      --   local w = love.graphics.getWidth()
      --   local h = love.graphics.getHeight()
      --   local ox = w/2
      --   local oy = h/2
      --   local dir = math.atan2(y - oy, x - ox) + math.pi
      --   local mag = math.sqrt((x - ox) ^ 2 + (y - oy) ^ 2)
      --   x = math.cos(dir) * mag
      --   return x + ox
      -- end

      -- love.mouse.getY = function()
      --   local x, y = orgetx(), orgety()
      --   local w = love.graphics.getWidth()
      --   local h = love.graphics.getHeight()
      --   local ox = w/2
      --   local oy = h/2
      --   local dir = math.atan2(oy - y, ox - x) + math.pi
      --   local mag = math.sqrt((ox - x) ^ 2 + (oy - y) ^ 2)
      --   y = math.sin(dir) * mag
      --   return y + oy
      -- end
    end
  end
  if Toolbar then DoToolbarUpdate() end
  if Resourcer then
    if not loadedResourcer then
      Resourcer.Settings({
        trans_overlay = econfig['resourcer_overlay_transparency']
      })
      Resourcer.LoadResources(econfig['resourcer_path'])
      loadedResourcer = true
    end
    atime = atime + dt
    if atime > delay then
      atime = 0
      Resourcer.UpdateAnimations('tick', 1)
    end
  end
  runCustomComponentCallback('update', dt)
end

local function customdraw()
  frames = frames + 1
  -- if essentialsMenu then
  --   paused = true
  --   inmenu = false
  --   placcells = false

  --   love.graphics.setColor(1, 1, 1, 0.3)
  --   love.graphics.rectangle("fill", 150 * winxm, 120 * winym, 500 * winxm, 390 * winym)
  --   love.graphics.setColor(1, 1, 1, 1)
  --   love.graphics.print("Essentials", 325 * winxm, 150 * winym, 0, winxm * 2, winym * 2)

  --   local spacing = 180 / #(componentPics)
  --   local size = 30

  --   for i=1,#componentPics do
  --     local pic = componentPics[i]
  --     love.graphics.draw(pic.tex, (180 + i * spacing) * winxm, 240 * winym, 0, size/pic.size.w * winxm, size/pic.size.h * winym)
  --   end

  --   love.graphics.setColor(1, 1, 1, 1)
  -- end
  if Toolbar then DoToolbarRender() end
  if Resourcer then
    Resourcer.RenderMouse()
    Resourcer.UpdateAnimations('ms', love.timer.getDelta() * 1000)
    Resourcer.UpdateAnimations('frame', 1)
    Resourcer.RenderListOverlays()
  end
  runCustomComponentCallback('draw', love.timer.getDelta())
  if inmenu then
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1, 0.8, 0, 1)
    local s = math.sin(frames / 25) * 0.25
    local w = love.graphics.getFont():getWidth("Essentials")
    local h = love.graphics.getFont():getHeight()
    love.graphics.print("Essentials", 155*winxm, 105*winym, -math.pi*0.125, winxm + s, winym + s, w /2 * (winxm + s), h / 2 * (winym + s))
    love.graphics.setColor(r, g, b, a)
  end
  local red, green, blue, alpha = love.graphics.getColor()
  
  love.graphics.setColor(1, 1, 1, 0.5)
  -- if selecting then
  --   love.graphics.draw(deleteTex.tex,250*winxm,25*winym+75*winxm,0,60*winxm/deleteTex.size.w,60*winxm/deleteTex.size.h)
  -- end
  love.graphics.setColor(red, green, blue, alpha)
end

local function onCellDraw(id, x, y, rot)
  if id ~= 0 and Resourcer then
    Resourcer.RenderOverlay(id, x, y)
  end
end

local function onMousePressed(x, y)
  if Toolbar then
    ToolbarClickTools("press", x, y)
  end
  runCustomComponentCallback("click", "press", x, y)
  -- local px, py = x * winxm, y * winym
  -- if selecting and ((x > 250) and (x < 310) and (py > (25*winym + 75*winxm)) and (py < (25*winym + 135*winxm))) then
  --   for ox=0, selx do
  --     for oy = 0, sely do
  --       local cx, cy = selx + ox - 1, sely + oy - 1
  --       if cx > 0 and cx < width-1 and cy > 0 and cy < height-1 then
  --         undocells[cy][cx] = CopyTable(cells[cy][cx])
  --         undocells[cy][cx].place = placeables[cy][cx]
  --         cells[cy][cx] = {
  --           ctype = 0,
  --           rot = 0,
  --           lastvars = {cx, cy, 0},
  --           testvar = "",
  --         }
  --       end
  --     end
  --   end
  --   placecells = false
  --   selecting = false
  -- end 
end

local function onMouseReleased(x, y)
  if Toolbar then
    ToolbarClickTools("release", x, y)
  end
  runCustomComponentCallback("click", "release", x, y)
end

local function onPlace(id, x, y, rot, original)
  if Toolbar then
    ToolbarPlaceTools(id, x, y, rot, original)
  end
end

local function onKeyPressed(key, code, continuous)
  -- if not continuous then
  --   if key == 'e' and love.keyboard.isDown('lalt') then
  --     currentrot = (currentrot - 1) % 4
  --     essentialsMenu = not essentialsMenu
  --   end
  -- end
  if not continuous then
    if key == 'x' and not love.keyboard.isDown('lctrl') then
      local full = love.window.getFullscreen()
      love.window.setFullscreen(not full)
    end
  end
  runCustomComponentCallback("key", key, code, continuous)
end

local function onGridRender()
  if copied and pasting and Resourcer then
    Resourcer.RenderMiniGridOverlay(copied)
  end
end

return {
  init = init,
  customupdate = customupdate,
  customdraw = customdraw,
  onCellDraw = onCellDraw,
  update = update,
  onPlace = onPlace,
  onMousePressed = onMousePressed,
  onMouseReleased = onMouseReleased,
  version = ver,
  onKeyPressed = onKeyPressed,
  onGridRender = onGridRender,
  dependencies = {
    "Essentials"
  }
}