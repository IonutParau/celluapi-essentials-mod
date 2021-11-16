-- Essentials mod

local json = require("libs.json")

IsEssentials = true

HALF_PI = math.pi / 2

local econfig = json.decode(love.filesystem.read("Essentials/config.json") or "{}", 0, 'null')

local Ereturns = {}

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
  showinstructions = false
  if Ereturns.MoreCells then
    Ereturns.MoreCells.init()
  end
  for _, custom in ipairs(econfig['customComponents']) do
    local cc = require(custom)
  
    table.insert(customComponents, cc)
  end
  runCustomComponentCallback('load', CopyTable(econfig))
end

local function customupdate(dt)
  if Toolbar then DoToolbarUpdate() end
  if Resourcer then
    atime = atime + dt
    if atime > delay then
      atime = 0
      Resourcer.UpdateAnimations()
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
    if copied and pasting then
      Resourcer.RenderMiniGridOverlay(copied)
    end
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
}