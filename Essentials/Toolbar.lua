local json = require("libs.json")

local texp = "Toolbar/"
if IsEssentials == true then
  texp = "Essentials/" .. texp
end

local backp = texp .. "back.png"
local structures = {}

local fontp = texp .. "arial.ttf"

local tools = {}

local toolPlaceData = {
  x = 0,
  y = 0,
  w = 0,
  h = 0,
  enabled = false,
  destroy = false,
}

local toolOnTex = love.graphics.newImage(texp .. "tool-on.png")
local toolOnSize = {
  w = toolOnTex:getWidth(),
  h = toolOnTex:getHeight(),
  w2 = toolOnTex:getWidth()/2,
  h2 = toolOnTex:getHeight()/2
}

local structureTex = love.graphics.newImage(texp .. "structure.png")
local structureTexsize = {
  w = structureTex:getWidth(),
  h = structureTex:getHeight(),
  w2 = structureTex:getWidth()/2,
  h2 = structureTex:getHeight()/2,
}

tex[backp] = love.graphics.newImage(backp)
texsize[backp] = {
  w = tex[backp]:getWidth(),
  h = tex[backp]:getHeight(),
  w2 = tex[backp]:getWidth()/2,
  h2 = tex[backp]:getHeight()/2,
}

ToolbarSystem = {}

--- @class ToolbarSystem.Structure
--- @field title string
--- @field description string
--- @field width number
--- @field height number
--- @field cells table
function ToolbarSystem.Structure()
  return {
    title = "",
    description = "",
    width = 0,
    height = 0,
    cells = {},
  }
end

--- @class ToolbarSystem.Item
--- @field display string
--- @field description string
--- @field image number
function ToolbarSystem.Item()
  return {
    display = "",
    description = "",
    image = 0,
  }
end

--- @param self ToolbarSystem.Category
--- @param name string
--- @param description string
--- @param image string
--- @return ToolbarSystem.Category
local function AddCategory(self, name, description, image)
  local c = ToolbarSystem.Category()
  c.display = name
  c.description = description
  c.image = image
  tex[image] = love.graphics.newImage(image)
  texsize[image] = {
    w = tex[image]:getWidth(),
    h = tex[image]:getHeight(),
    w2 = tex[image]:getWidth()/2,
    h2 = tex[image]:getHeight()/2,
  }
  c:AddItem("Back", "Takes you back", backp)
  c.hypercat = self
  table.insert(self.items, c)
  return c
end

--- @param self ToolbarSystem.Category
--- @param cellID number|string
--- @param name string
--- @param description string
--- @return ToolbarSystem.Item
local function AddItem(self, name, description, cellID)
  local i = ToolbarSystem.Item()
  i.display = name
  i.description = description
  i.image = getRealID(cellID) or cellID
  table.insert(self.items, i)
  return i
end

--- @param self ToolbarSystem.Category
--- @param data any
--- @param field string
--- @return ToolbarSystem.Category|ToolbarSystem.Item
local function GetChild(self, data, field)
  for _, child in ipairs(self.items) do
    if child[field] == data then
      return child
    end
  end
end

--- @param self ToolbarSystem.Category
--- @param name string
--- @return ToolbarSystem.Category
local function GetCategory(self, name)
  return self:GetChild(name, "display")
end

--- @param self ToolbarSystem.Category
--- @param name string
--- @return ToolbarSystem.Item
local function GetItem(self, name)
  return self:GetChild(name, "display")
end

--- @class ToolbarSystem.Category
--- @field display string
--- @field description string
--- @field image string
--- @field items table<number, ToolbarSystem.Item>
--- @field AddCategory function()
--- @field AddItem function()
--- @field GetCategory function()
--- @field GetItem function()
--- @field GetChild function()
--- @field hypercat ToolbarSystem.Category
function ToolbarSystem.Category()
  return {
    display = "",
    description = "",
    image = "",
    items = {},
    AddCategory = AddCategory,
    AddItem = AddItem,
    GetCategory = GetCategory,
    GetItem = GetItem,
    GetChild = GetChild,
    hypercat = {}
  }
end

Toolbar = ToolbarSystem.Category()
local current = Toolbar
Toolbar.display = "Toolbar"
Toolbar.description = "The root bar"

local function applyRendering()
  listorder = {}

  if current == nil then current = Toolbar end

  for index, child in ipairs(current.items) do
    table.insert(listorder, child.image)
  end
end

---@param structure ToolbarSystem.Structure
function ToolbarSystem.ActivateStructure(structure)
  pasting = true
  selecting = false
  placecells = false

  local s = {}
  for y=0,structure.height-1 do
    s[y] = {}
    for x=0,structure.width-1 do
      s[y][x] = {
        ctype = 0,
        rot = 0,
        place = false,
      }
    end
  end

  for _, cell in ipairs(structure.cells) do
    local id = cell.id
    if type(id) == "string" then id = getCellIDByLabel(id) end
    s[cell.y-1][cell.x-1] = {
      ctype = id,
      rot = (cell.rot or 0),
      place = false,
    }
  end

  copied = s
end

---@return ToolbarSystem.Structure
function ToolbarSystem.FromCopyToStructure()
  local swidth = #copied[0]
  local sheight = #(copied)

  local items = {}

  for y=0,sheight do
    for x=0,swidth do
      if copied[y][x].ctype ~= 0 then
        table.insert(
          items,
          {
            id = copied[y][x].ctype,
            rot = copied[y][x].rot,
            x = x + 1,
            y = y + 1,
          }
        )
      end
    end
  end

  local s = ToolbarSystem.Structure()
  s.title = os.date('%Y-%m-%d %H:%M:%S')
  s.description = "Automatically generated structure"
  s.width = swidth+1
  s.height = sheight+1
  s.cells = items

  return s
end

local function inGrid(x, y)
  return (x > 0 and x < width-1 and y > 0 and y < height-1)
end

local function dofill(id, x, y, rot, original, ox, oy)
  ox = ox or x
  oy = oy or y

  local dist = (ox - x) ^ 2 + (oy - y) ^ 2

  if dist > 35 ^ 2 then return end -- No stackoverflow for u, also 35 is weak limit

  if not inGrid(ox, oy) then
    return
  end

  if cells[oy][ox].ctype ~= original.ctype or cells[oy][ox].rot ~= original.rot then
    return
  end

  cells[oy][ox].ctype = id
  cells[oy][ox].rot = rot

  for fx=ox-1,ox+1 do
    for fy=oy-1,oy+1 do
      dofill(id, x, y, rot, original, fx, fy)
    end
  end
end

function ToolbarPlaceTools(id, x, y, rot, original)
  if tools["tool-fill"] then
    if cells[y][x].ctype == original.ctype and cells[y][x].rot == original.rot then return end
    cells[y][x].ctype = original.ctype
    dofill(id, x, y, rot, original)
  elseif tools["tool-square"] and not toolPlaceData.enabled then
    toolPlaceData.x = x
    toolPlaceData.y = y
    toolPlaceData.enabled = true
    toolPlaceData.destroy = (id == 0)
    cells[y][x] = original
  end
end

function ToolbarClickTools(clickType, x, y)
  x = x / winxm
  y = y / winym

  if clickType == "release" and toolPlaceData.enabled == true then
    local cx = toolPlaceData.x
    local cy = toolPlaceData.y
    
    toolPlaceData.x = 0
    toolPlaceData.y = 0
    
    local ex, ey = toolPlaceData.w-1, toolPlaceData.h-1
    
    toolPlaceData.w = 0
    toolPlaceData.h = 0
    
    for oy=0,ey do
      for ox=0,ex do
        local px, py = cx + ox, cy + oy
        if inGrid(px, py) then
          local original = CopyTable(cells[py][px])
          local id = currentstate
          if toolPlaceData.destroy then
            id = 0
          end
          cells[py][px].ctype = id
          cells[py][px].rot = currentrot
          local originalInitial = CopyTable(initial[py][px])
          if isinitial then
            initial[py][px].ctype = id
            initial[py][px].rot = currentrot
          end
          modsOnPlace(id, px, py, currentrot, original, originalInitial)
        end
      end
    end
    toolPlaceData.enabled = false
  end
end

function DoToolbarUpdate()
  if type(currentstate) == "string" then
    placecells = false
  end

  if toolPlaceData.enabled == true then
    placecells = false

    local pos = calculateCellPosition(love.mouse.getX(), love.mouse.getY())
    toolPlaceData.w = math.abs(math.floor(pos.x - toolPlaceData.x))
    toolPlaceData.h = math.abs(math.floor(pos.y - toolPlaceData.y))
  end

  if currentstate == backp and current ~= Toolbar then
    current = current.hypercat
    currentstate = 0
  elseif type(currentstate) == "string" and string.sub(currentstate, 1, 10) == "structure-" then
    ToolbarSystem.ActivateStructure(structures[currentstate])
    currentstate = 0
  elseif currentstate == "save-struct" and copied then
    local s = ToolbarSystem.FromCopyToStructure()
    local text = json.encode(s)
    love.system.setClipboardText(text)
    currentstate = 0
  elseif type(tools[currentstate]) == "boolean" then
    tools[currentstate] = not tools[currentstate]
    currentstate = 0
  elseif currentstate == "load-struct" then
    local text = love.system.getClipboardText()
    local s = json.decode(text, 0, "null")
    ToolbarSystem.ActivateStructure(s)
    currentstate = 0
  else
    local cat = current:GetChild(currentstate, "image")
    if cat ~= nil and type(cat) == "table" and type(cat.items) == "table" then
      current = cat
      currentstate = 0
      pages = 1 
    end
  end
  applyRendering()
end

local function renderCell(id, x, y, rot)
  local spos = calculateScreenPosition(x, y)
  love.graphics.draw(tex[id], spos.x, spos.y, rot*HALF_PI, zoom/texsize[id].w, zoom/texsize[id].h, texsize[id].w2, texsize[id].h2)
end

function DoToolbarRender()
  if inmenu then return end
  local x = love.mouse.getX()/winxm
  local y = love.mouse.getY()/winym

  if toolPlaceData.enabled == true then
    local grid = {}
    local id = currentstate
    if toolPlaceData.destroy then
      id = 0
    end
    for oy=0,toolPlaceData.h-1 do
      grid[oy] = {}
      for ox=0,toolPlaceData.w-1 do
        local cx, cy = toolPlaceData.x + ox, toolPlaceData.y + oy
        if inGrid(cx, cy) then
          renderCell(id, cx, cy, currentrot)
        end
        grid[oy][ox] = {
          ctype = currentstate,
          rot = currentrot
        }
      end
    end
    if id == 0 then
      local r, g, b, a = love.graphics.getColor()
      love.graphics.setColor(0, 0, 0, 255)

      local spos = calculateScreenPosition(toolPlaceData.x, toolPlaceData.y)

      love.graphics.rectangle("line", spos.x, spos.y, texsize[0].w*(toolPlaceData.w-1)*zoom/20, texsize[0].h*(toolPlaceData.h-1)*zoom/20)

      love.graphics.setColor(r, g, b, a)
    end
    if Resourcer and (#grid > 0 and #(grid[0]) > 0) then
      Resourcer.RenderMiniGridOverlay(grid, toolPlaceData.x, toolPlaceData.y)
    end
  end

  for i=0,15 do
    local li = listorder[i+16*(page-1)+1]
    if tools[li] == true then
      love.graphics.draw(toolOnTex,(25+(775-25)*i/15)*winxm,575*winym,currentrot*math.pi/2,40*winxm/toolOnSize.w,40*winxm/toolOnSize.h,toolOnSize.w2,toolOnSize.h2)
    end
  end

  if y > 575-20*(winxm/winym) and y < 575+20*(winxm/winym) then
    for i=0,15 do
      if x > 5+(775-25)*i/15 and x < 45+(775-25)*i/15 and listorder[i+16*(page-1)+1] then
        local li = listorder[i+16*(page-1)+1]
        local item = current:GetChild(li, "image")
        if type(item) == "table" then
          -- Calculate box size
          local font = love.graphics.getFont()
          local desc = item.description
          local title = item.display
          local charWidth = font:getWidth("a")
          local charHeight = 20
          local boxOff = 7

          local maxCharCount = math.max(math.min(50, #desc), math.max(#title * 2, 20))

          local maxDescWidth = maxCharCount * charWidth

          local descHeight = math.floor(font:getWidth(desc) / maxDescWidth) * charHeight

          local boxX = math.min((boxOff + 750 * i / 15) * winxm, love.graphics.getWidth() - maxDescWidth * winxm)

          -- Draw box
          love.graphics.setColor(0.7, 0.7, 0.7, 0.7)
          love.graphics.rectangle("fill", boxX, (480 - descHeight) * winym, maxDescWidth * winxm, charHeight * winym)
          love.graphics.setColor(0.5, 0.5, 0.5, 0.7)
          love.graphics.rectangle("fill", boxX, (500 - descHeight) * winym, maxDescWidth * winxm, (descHeight + 50) * winym)

          -- Render text
          love.graphics.setColor(1, 1, 1, 1)
          love.graphics.print(item.display, boxX, (480 - descHeight) * winym, 0, winxm, winym)
          love.graphics.printf(desc, font, boxX, (500 - descHeight) * winym, maxDescWidth, nil, 0, winxm, winym)

        end
      end
    end
  end
end

-- Add default stuff
local baseCat = Toolbar:AddCategory("Bases", "Basic cells", "textures/wall.png")
baseCat:AddItem("Erase", "Overrides the cell with air", 0)
baseCat:AddItem("Wall", "Just a wall", -1)
baseCat:AddItem("Placeable", "Marks a tile as placeable", -2)
baseCat:AddItem("Ghost", "A wall that can't be generated by generators", 40)

local movCat = Toolbar:AddCategory("Movers", "Cells that move on the grid or move other cells", "textures/mover.png")
movCat:AddItem("Mover", "Moves in the direction it is facing", 1)
movCat:AddItem("Puller", "Pulls everything behind it forwards. Can't push", 13)
movCat:AddItem("Advancer", "It is a Mover and a Puller combined as one", 27)
movCat:AddItem("Driller", "Moves on the grid but drills through it's obstacles instead of pushing them. There are things it can't drill thru tho", 57)
movCat:AddItem("Mirror", "Moves everything from one side of it's arrows to the opposite sides", 14)
movCat:AddItem("Cross-Mirror", "It's like 2 mirrors combined!", 55)
movCat:AddItem("Gear CW", "Moves its neighbors around itself in a clockwise direction", 17)
movCat:AddItem("Gear CCW", "Moves its neighbors around itself in a counter-clockwise direction", 18)
movCat:AddItem("Repulser", "Pushes everything touching it away from it", 20)
movCat:AddItem("Super Repulser", "Repulser but up to 11", 49)
movCat:AddItem("Impulser", "Pulls everything near it into it", 28)

local pushCat = Toolbar:AddCategory("Pushes", "Cells that are special in how they are pushed", "textures/push.png")
pushCat:AddItem("Push", "Nothing special, can be pushed from every side", 3)
pushCat:AddItem("Slider", "Can only be pushed from it's sides", 4)
pushCat:AddItem("One Directional", "Can only be pushed from one side", 5)
pushCat:AddItem("Two Directional", "Can only be pushed from two sides", 6)
pushCat:AddItem("Three Directional", "Can only be pushed from three sides", 7)
pushCat:AddItem("Opposition", "Can be moved from one side, and pulled from the other. Acts like a push cell on the green sides.", 51)
pushCat:AddItem("Cross Opposition", "Can be moved from two sides, and pulled from the other ones.", 52)
pushCat:AddItem("Slide Opposition", "Can be moved from one side, and pulled from the other. Rest of the sides make it like a slider", 53)

local genCat = Toolbar:AddCategory("Generators", "Cells that generate other cells", "textures/generator.png")
genCat:AddItem("Generator", "Generates in front of it the cell behind it", 2)
genCat:AddItem("Cross Generator", "Two generators combined as one!", 22)
genCat:AddItem("CW Generator", "Generates on it's right what is behind it", 25)
genCat:AddItem("CCW Generator", "Generators on it's left what is behind it", 26)
genCat:AddItem("Replicator", "Generates the cell in front of it... in front of it", 44)
genCat:AddItem("Cross Replicator", "It's like 2 replicators put together!", 45)
genCat:AddItem("Twist Generator", "Generates in front of it the opposite of the cell behind it", 39)
genCat:AddItem("Super Generator", "Generates everything generatable from behind it in front of it", 54)

local rotCat = Toolbar:AddCategory("Rotators", "Cells that rotate other cells", "textures/rotator_cw.png")
rotCat:AddItem("Rotator CW", "Rotates it's neighboring cells 90 degrees clockwise", 8)
rotCat:AddItem("Rotator CCW", "Rotates it's neighboring cells 90 degrees counter-clockwise", 9)
rotCat:AddItem("Double Rotator", "Two rotators combined", 56)
rotCat:AddItem("Rotator 180", "Rotates it's neighboring cells 180 degrees", 10)
rotCat:AddItem("Redirector", "Forces the cell behind it to face it's direction", 16)

local divergerCat = Toolbar:AddCategory("Divergers", "Cells that diverge the patths of what falls in", "textures/diverger.png")
divergerCat:AddItem("Diverger", "Curves the path", 15)
divergerCat:AddItem("Double Diverger", "Like two divergers as one!", 30)
divergerCat:AddItem("Straight Diverger", "Does not curve the path, but it does allow the cells to skip the poisition", 37)
divergerCat:AddItem("Cross Diverger", "2 straight divergers perpendicular to eachother combined", 38)

local weightCat = Toolbar:AddCategory("Weight", "Heavy objects that need more force to be pushed", "textures/weight.png")
weightCat:AddItem("Weight", "It can stop 1 mover", 21)

local destroyCat = Toolbar:AddCategory("Destroyers", "Cells that destroy other cells", "textures/enemy.png")
destroyCat:AddItem("Enemy", "When something goes into it, they both die", 12)
destroyCat:AddItem("Strong Enemy", "Just like an enemy, but instead of dying, it turns itself into a normal enemy", 23)
destroyCat:AddItem("Trash", "When something goes into it, it dies. The trash cell remains", 11)
destroyCat:AddItem("Demolisher", "Trash cell, except instead of just killing what fell into it, it kills everything except itself in a 3x3 area with in in the center.", 50)

local procCat = Toolbar:AddCategory("Processors", "Cells that can be used to process data", "textures/gate_and.png")
procCat:AddItem("OR gate", "Performs OR operation on it's data.", 31)
procCat:AddItem("AND gate", "Performs AND operation on it's data.", 32)
procCat:AddItem("XOR gate", "Performs XOR operation on it's data.", 33)
procCat:AddItem("NOR gate", "Performs NOR operation on it's data.", 34)
procCat:AddItem("NAND gate", "Performs NAND operation on it's data.", 35)
procCat:AddItem("XNOR gate", "Performs XNOR operation on it's data.", 36)

local forkCat = Toolbar:AddCategory("Forkers", "When a cell falls into their back, they replicate it", "textures/tripleforker.png")
forkCat:AddItem("Forker", "A forker that replicates in 2 directions (left, right)", 47)
forkCat:AddItem("Triple Forker", "A forker that replicates in 3 directions (left, right, forwards)", 48)

local uniqueCat = Toolbar:AddCategory("Unique cells", "Cells that are very unique", "textures/freezer.png")
uniqueCat:AddItem("Mold", "When generated it destroys itself, but it still pushes.", 19)
uniqueCat:AddItem("Freezer", "Freezes all cells touching it", 24)
uniqueCat:AddItem("Bias", "Messes with the movers' biases", 41)
uniqueCat:AddItem("Shield", "Prevents all enemies touching it from dying", 42)
uniqueCat:AddItem("Intaker", "Destroyes the cell in front of it", 43)
uniqueCat:AddItem("Fungal", "It turns every cell pushing it into itself", 46)
uniqueCat:AddItem("Flipper", "Turns certain cells around it into their opposites. If they have no opposites, it rotates them instead!", 29)

local tooltex = love.graphics.newImage(texp .. "tool.png")
local toolsize = {
  w = tooltex:getWidth(),
  h = tooltex:getHeight(),
  w2 = tooltex:getWidth()/2,
  h2 = tooltex:getHeight()/2,
}

local toolsCat = Toolbar:AddCategory("Tools", "Kind of like settings", texp .. "tool.png")


local structCat = toolsCat:AddCategory("Structures", "When you click on these cells you will suddenly have a structure you can place on the grid", texp .. "structure.png")

tex["save-struct"] = structureTex
texsize["save-struct"] = structureTexsize

tex["load-struct"] = structureTex
texsize["load-struct"] = structureTexsize

structCat:AddItem("Save structure", "Saves the JSON of your currently saved structure (part of the grid you copied) in your clipboard", "save-struct")
structCat:AddItem("Load structure", "Loads the structure in your clipboard", "load-struct")

local structuresFiles = love.filesystem.getDirectoryItems(texp .. "Structures")

for _, fileName in ipairs(structuresFiles) do
  local code = love.filesystem.read(texp .. "Structures/" .. fileName)
  local structure = json.decode(code) or {}
  local structID = "structure-" .. (structure.title or "Untitled")
  structures[structID] = structure
  tex[structID] = structureTex
  texsize[structID] = structureTexsize
  structCat:AddItem(structure.title or "Untitled", structure.description or "No discription available", structID)
end

local toolData = {
  {
    title = "Fill",
    description = "When placing a cell it fills all the empty space around it with that cell",
    id = "tool-fill"
  },
  {
    title = "Square Drag Placement",
    description = "Instead of placing cells you drag",
    id = "tool-square"
  },
}

for _, data in ipairs(toolData) do
  toolsCat:AddItem(data.title, data.description, data.id)

  tools[data.id] = false
  tex[data.id] = tooltex
  texsize[data.id] = toolsize
end

local arial = love.graphics.newFont(fontp, 16)
love.graphics.setFont(arial)