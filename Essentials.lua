-- Essentials mod

local json = require("libs.json")

IsEssentials = true

HALF_PI = math.pi / 2

local econfig = json.decode(love.filesystem.read("Essentials/config.json") or "{}", 0, 'null')

local Ereturns = {}

local ver = "dededadsadawedas"
local v2 = "dededadsadawedas"

local loadedResourcer = false

for _, component in ipairs(econfig['components']) do
  Ereturns[component] = require("Essentials/" .. component)
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

local function init()
  if ver ~= v2 then

  end

  showinstructions = false
  if Ereturns.MoreCells then
    Ereturns.MoreCells.init()
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

local function customupdate(dt)
  if Toolbar then DoToolbarUpdate() end
  if Resourcer then
    atime = atime + dt
    if atime > delay then
      atime = 0
      Resourcer.UpdateAnimations('tick', 1)
    end
  end
  runCustomComponentCallback('update', dt)
end

local function customdraw()
  if Toolbar then DoToolbarRender() end
  if Resourcer then
    if not loadedResourcer then
      Resourcer.Settings({
        trans_overlay = econfig['resourcer_overlay_transparency']
      })
      Resourcer.LoadResources(econfig['resourcer_path'])
      loadedResourcer = true
    end
    Resourcer.RenderListOverlays()
    Resourcer.RenderMouse()
    Resourcer.UpdateAnimations('ms', love.timer.getDelta() * 1000)
    Resourcer.UpdateAnimations('frame', 1)
    if copied and pasting then
      Resourcer.RenderMiniGridOverlay(copied)
    end
  end
  if Ereturns.MoreCells then
    Ereturns.MoreCells.customdraw()
  end
  runCustomComponentCallback('draw', love.timer.getDelta())
end

local function onCellDraw(id, x, y, rot)
  if id ~= 0 and Resourcer then
    Resourcer.RenderOverlay(id, x, y)
  end
  if Ereturns.MoreCells then
    Ereturns.MoreCells.onCellDraw(id, x, y, rot)
  end
end

local function update(id, x, y, dir)
  if Ereturns.MoreCells then
    Ereturns.MoreCells.update(id, x, y, dir)
  end
end

local function onMousePressed(x, y)
  if Toolbar then
    ToolbarClickTools("press", x, y)
  end
  runCustomComponentCallback("click", "press", x, y)
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
  if Ereturns.MoreCells then
    Ereturns.MoreCells.onPlace(id, x, y, rot, original, originalInitial)
  end
end

local function tick()
  if Ereturns.MoreCells then
    Ereturns.MoreCells.tick()
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
  tick = tick,
  version = ver,
  dependencies = {
    "Essentials"
  }
}