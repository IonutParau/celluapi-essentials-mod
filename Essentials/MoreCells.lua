local ids = {}

local texp = "MoreCells/"
if IsEssentials then
  texp = "Essentials/" .. texp
end

local half_pi = math.pi / 2

local MAX_MECH = 2

local function equals(a, b)
  if type(a) ~= type(b) then return false end

  if type(a) == "table" then
    for k, v in pairs(a) do
      if not equals(b[k], v) then
        return false
      end
    end

    for k, v in pairs(b) do
      if not equals(a[k], v) then
        return false
      end
    end

    return true
  else
    return a == b
  end
end

local function makeTex(pic)
  local t = love.graphics.newImage(pic)
  return {
    tex = t,
    size = {
      w = t:getWidth(),
      h = t:getHeight(),
      w2 = t:getWidth()/2,
      h2 = t:getHeight()/2,
    }
  }
end

local wireArm = makeTex(texp .. "wire/arm.png")
local wireActive = makeTex(texp .. "wire/on.png")
local pistonOn = makeTex(texp .. "piston/on.png")
local stickyPistonOn = makeTex(texp .. "piston/sticky-on.png")

---@param dir number
---@param amount number
local function GetForward(dir, amount)
  amount = amount or 1
  dir = (dir % 4)
  if dir == 0 then
    return {
      x = amount,
      y = 0
    }
  elseif dir == 1 then
    return {
      x = 0,
      y = amount
    }
  elseif dir == 2 then
    return {
      x = -amount,
      y = 0
    }
  elseif dir == 3 then
    return {
      x = 0,
      y = -amount
    }
  end
end

local function GetFullForward(x, y, dir, amount)
  local off = GetForward(dir, amount)

  return x + off.x, y + off.y
end

local function isMech(id)
  local l = getCellLabelById(id) or id

  local suffix = "EMC mech "

  return (l:sub(1, #suffix) == suffix)
end

local function isGate(id)
  local l = getCellLabelById(id) or id

  local suffix = "EMC gate "

  return (l:sub(1, #suffix) == suffix)
end

local function isConnectable(cell, dir)
  local id = cell.ctype

  local rdir = (dir - cell.rot) % 4

  if isMech(id) then
    if id == ids.wire or id == ids.activator or id == ids.mech_gen then
      return true
    end

    if (id == ids.motionSensor) or (id == ids.piston) or (id == ids.stickyPiston) then
      return rdir ~= 2
    end

    if id == ids.delayer then
      return rdir % 2 == 0
    end

    return true
  elseif isGate(id) then
    if id == ids.g_not then
      return rdir % 2 == 0
    else
      return (rdir ~= 0)
    end
  end

  return false
end

local function isMechOn(x, y)
  --if not isMech(cells[y][x].ctype) then return false end
  local s = cells[y][x].mech_signal
  if s == nil then s = 0 end

  return s > 0
end

local function wasMechOn(x, y)
  --if not isMech(cells[y][x].ctype) then return false end
  local s = cells[y][x].prev_mech_signal
  if s == nil then s = 0 end

  return s > 0
end

function SignalMechanical(x, y, blockdir, forced)
  if not isMech(cells[y][x].ctype) then return end

  if forced == nil then
    forced = true
  end

  cells[y][x].mech_signal = MAX_MECH -- OMG he powered

  for i=0,3 do
    if i ~= blockdir then
      local off = GetForward(i)
      local ox, oy = x + off.x, y + off.y
      local canSpread = true
      if not forced then
        canSpread = (cells[y][x].ctype == ids.wire)
      end
      if isMech(cells[oy][ox].ctype) and isConnectable(cells[oy][ox], i) and canSpread and ((cells[oy][ox].mech_signal or 0) < MAX_MECH) then
        if cells[oy][ox].ctype == ids.crosswire then
          local fx, fy = GetFullForward(ox, oy, i)
          SignalMechanical(fx, fy, (i+2)%4, true)
        else
          SignalMechanical(ox, oy, nil, false)
        end
      end
    end
  end
end

local function DoMotionSensor(x, y, dir)
  local off = GetForward(dir)

  local ox, oy = x + off.x, y + off.y
  
  if not cells[y][x].motion_past_cell then
    cells[y][x].motion_past_cell = CopyTable(cells[oy][ox])
    return
  end
  local past = cells[y][x].motion_past_cell
  local now = cells[oy][ox]

  if not equals(past, now) and not equals(now.lastvars, past.lastvars) then
    cells[y][x].motion_past_cell = CopyTable(cells[oy][ox])
    SignalMechanical(x, y)
  end
end

local function DoActivator(x, y)
  if not isMechOn(x, y) then
    for dir=0,3 do
      local off = GetForward(dir)
      local ox, oy = x + off.x, y + off.y
      local id = cells[oy][ox].ctype

      if id ~= ids.wire and id ~= ids.motionSensor and id ~= ids.mech_gen then
        cells[oy][ox].updated = true
      end
    end
  end

  cells[y][x].prev_mech_signal = cells[y][x].mech_signal -- Useful for later ;)
  if isMechOn(x, y) then
    cells[y][x].mech_signal = cells[y][x].mech_signal - 1
  end
end

local function DoDelayer(x, y)
  if isMechOn(x, y) then
    local front = GetForward(cells[y][x].rot)
    local fx, fy = x + front.x, y + front.y
    SignalMechanical(fx, fy, (cells[y][x].rot+2)%4, false)
    cells[y][x].mech_signal = 0
  end
end

---@param type "\"and\""|"\"or\""|"\"xor\""|"\"nand\""|"\"nor\""|"\"xnor\""|"\"not\""
local function DoLogicGate(x, y, dir, type)
  if type == "not" then
    local frontOff = GetForward(dir)
    local backOff = GetForward(dir+2)

    if isMech(cells[y+frontOff.y][x+frontOff.x].ctype) then
      if not isMechOn(x+backOff.x, y+backOff.y) then
        SignalMechanical(x+frontOff.x, y+frontOff.y)
      end
    end
  else
    local loff = GetForward(dir-1)
    local roff = GetForward(dir+1)
    local ooff = GetForward(dir)

    local lx, ly, rx, ry, ox, oy = loff.x + x, loff.y + y, roff.x + x, roff.y + y, ooff.x + x, ooff.y + y

    -- cells[ry][rx].ctype = 40
    -- cells[ly][lx].ctype = 40
    -- cells[oy][ox].ctype = 40

    local d1, d2 = isMechOn(lx, ly) == true, isMechOn(rx, ry) == true

    local p = function()
      SignalMechanical(ox, oy, (dir+2)%4)
    end

    if type == "and" and (d1 and d2) then
      p()
    elseif type == "or" and (d1 or d2) then
      p()
    elseif type == "xor" and (d1 ~= d2) then
      p()
    elseif type == "nand" and not (d1 and d2) then
      p()
    elseif type == "nor" and not (d1 or d2) then
      p()
    elseif type == "xnor" and (d1 == d2) then
      p()
    end
  end
end

local function slideCallback(x, y, dir)
  return dir % 2 ~= cells[y][x].rot % 2
end

local function giveSubtick(id, updateFunc, static)
  table.insert(subticks, GenerateSubtick(id, updateFunc, not (static or false)))
end

local function Do4Gen(x, y)
  local workingOffs = {}
  local backWorks = {}

  for dir=0,3 do
    local fx, fy = GetFullForward(x, y, dir)

    if cells[fy][fx].ctype ~= 0 and cells[fy][fx].ctype ~= 40 then
      table.insert(workingOffs, dir)
      local bx, by = GetFullForward(x, y, dir, 1)
      local b = walkDivergedPath(x, y, bx, by)
      bx = b.x
      by = b.y

      backWorks[(dir+2)%4] = CopyTable(cells[by][bx])
    end
  end

  for _, dir in ipairs(workingOffs) do
    dir = (dir+2)%4
    local fx, fy = GetFullForward(x, y, dir)
    local f = walkDivergedPath(x, y, fx, fy)
    fx = f.x
    fy = f.y
    local back = backWorks[dir]
    if back.ctype ~= 0 and back.ctype ~= 40 then
      local bdir = (back.rot + f.dir - dir) % 4
      if PushCell(x, y, dir, true, 1, back.ctype, bdir, nil, {x, y, bdir}) then
        if cells[fy][fx].ctype == 19 then cells[fy][fx].ctype = 0 end
        if cells[fy][fx].ctype == ids.gen4 then cells[fy][fx].updated = true end
      end
    end
  end
end

local function canPush(fx, fy, dir)
  -- Straight up immovable
  if cells[fy][fx].ctype == 40 or cells[fy][fx].ctype == -1 then
    return false
  elseif cells[fy][fx].ctype == 4 then -- Slider
    return (cells[fy][fx].rot % 2 == dir % 2)
  elseif cells[fy][fx].ctype == 5 or cells[fy][fx].ctype == 51 then -- 1 directional or opposition
    return (cells[fy][fx].rot == dir)
  elseif cells[fy][fx].ctype == 6 or cells[fy][fx].ctype == 52 then -- 2 directional or cross opposition
    return (cells[fy][fx].rot == dir or cells[fy][fx].rot == (dir+1)%4)
  elseif cells[fy][fx].ctype == 7 then -- 3 directional
    return (cells[fy][fx].rot == dir or cells[fy][fx].rot == (dir-1)%4 or cells[fy][fx].rot == (dir+1)%4)
  elseif cells[fy][fx].ctype == 53 then -- Slide opposition
    return (cells[fy][fx].rot ~= (dir+2)%4)
  elseif cells[fy][fx].ctype == ids.trashMover then
    return (cells[fy][fx].rot ~= dir)
  end

  return true
end

local function inGrid(x, y)
  return x > 0 and x < width-1 and y > 0 and y < height-1
end

local function FakeMoveForward(x, y, dir, replacetype, replacerot)
  replacetype = replacetype or 0
  replacerot = replacerot or 0
  local front = GetForward(dir)

  local us = CopyTable(cells[y][x])

  cells[y][x] = {
    ctype = replacetype,
    rot = replacerot
  }

  cells[y+front.y][x+front.x] = us
  SetChunk(x+front.x, y+front.y, us.ctype)
end

local function DoTrashMover(x, y, dir)
  local frontOff = GetForward(dir)

  local fx, fy = x + frontOff.x, y + frontOff.y

  if not inGrid(fx, fy) then
    return
  end

  local frontPos = walkDivergedPath(x, y, fx, fy)

  fx = frontPos.x
  fy = frontPos.y

  local front = cells[fy][fx]

  if canPush(fx, fy, dir) then
    local id = front.ctype
    if id == ids.trashMover and front.rot == (dir + 2) % 4 and not subtick then
      cells[y][x] = {
        ctype = 0,
        rot = 0,
        lastvars = {x, y, 0}
      }
    end
    if id ~= 0 then
      cells[fy][fx] = {
        ctype = 0,
        rot = 0,
        lastvars = {fx, fy, 0}
      }
      destroysound:play()
    end
    FakeMoveForward(x, y, dir)
  end
end

local function DoStickyPiston(x, y, dir)
  if isMechOn(x, y) then
    PushCell(x, y, dir)
  elseif wasMechOn(x, y) then
    local fx, fy = GetFullForward(x, y, dir, 2)

    PullCell(fx, fy, (dir+2)%4, false, 1)
  end
end

local function init()
  -- Gens
  ids.motionSensor = addCell("EMC mech motion-sensor", texp .. "motionSensor.png", {updateindex = 1})
  ids.delayer = addCell("EMC mech motion-sensor", texp .. "delayer.png", {updateindex = 2})
  ids.wire = addCell("EMC mech wire", texp .. "wire/off.png", {updateindex = 3})
  ids.mech_gen = addCell("EMC mech mech_gen", texp .. "mech_gen.png", {updateindex = 4})
  -- Users
  ids.activator = addCell("EMC mech activator", texp .. "activator.png", Options.neverupdate)
  ids.piston = addCell("EMC mech piston", texp .. "piston/off.png", Options.neverupdate)
  ids.stickyPiston = addCell("EMC mech piston-sticky", texp .. "piston/sticky-off.png", Options.neverupdate)
  ids.lightBulb = addCell("EMC mech light-bulb", texp .. "lightbulbs/normal.png", Options.static)
  ids.brightLightBulb = addCell("EMC mech light-bulb-bright", texp .. "lightbulbs/bright.png", Options.static)
  ids.brighterLightBulb = addCell("EMC mech light-bulb-brighter", texp .. "lightbulbs/brighter.png", Options.static)
  ids.brightestLightBulb = addCell("EMC mech light-bulb-brightest", texp .. "lightbulbs/brightest.png", Options.static)
  ids.slideopener = addCell("EMC mech slideopener", texp .. "slideopener.png", Options.mover)
  ids.crosswire = addCell("EMC mech crosswire", "textures/push.png", Options.neverupdate)

  -- Add gates
  ids.g_and = addCell("EMC gate and", texp .. "gates/and.png", Options.neverupdate)
  ids.g_or = addCell("EMC gate or", texp .. "gates/or.png", Options.neverupdate)
  ids.g_xor = addCell("EMC gate xor", texp .. "gates/xor.png", Options.neverupdate)
  ids.g_nand = addCell("EMC gate nand", texp .. "gates/nand.png", Options.neverupdate)
  ids.g_nor = addCell("EMC gate nor", texp .. "gates/nor.png", Options.neverupdate)
  ids.g_xnor = addCell("EMC gate xnor", texp .. "gates/xnor.png", Options.neverupdate)
  ids.g_not = addCell("EMC gate not", texp .. "gates/not.png", Options.neverupdate)

  table.insert(subticks, GenerateSubtick({ ids.g_and, ids.g_or, ids.g_xor, ids.g_nand, ids.g_nor, ids.g_xnor, ids.g_not }, DoModded, true))
  table.insert(subticks, 1, GenerateSubtick(ids.activator, DoActivator, true))
  giveSubtick(ids.piston, DoModded)
  giveSubtick(ids.stickyPiston, DoModded)

  -- Add useful stuff
  local slideTrash = addCell("EMC slide-trash", texp .. "trash_side.png", {type="sidetrash", dontupdate = true})
  SetSidedTrash(slideTrash, slideCallback)

  local slideEnemy = addCell("EMC slide-enemy", texp .. "enemy_side.png", {type="sideenemy", dontupdate = true})
  SetSidedEnemy(slideEnemy, slideCallback)

  ids.trashMover = addCell("EMC trash-mover", texp .. "trashMove.png", Options.sidetrash)

  SetSidedTrash(ids.trashMover, function(x, y, dir)
    if dir == nil then return false end
    return ((dir+2)%4 == cells[y][x].rot)
  end)

  ids.gen4 = addCell("EMC gen4", texp .. "4waygen.png")

  ids.silentTrash = addCell("EMC silent-trash", texp .. "silentTrash.png", Options.combine(Options.trash, Options.neverupdate))

  if Toolbar then
    local mechCat = Toolbar:AddCategory("Mechanical Cells", "Cells that use mechanical systems", texp .. "wire/on.png")

    mechCat:AddItem("Motion Sensor", "Senses motion. If it detects motion, it outputs a mechanical signal", ids.motionSensor)
    mechCat:AddItem("Wire", "Extends mechanical signals further", ids.wire)
    mechCat:AddItem("CrossWire", "Acts as a wire while keeping 2 signals seperated", ids.crosswire)
    mechCat:AddItem("Activator", "Acts like a freezer while not recieving a mechanical signal", ids.activator)
    mechCat:AddItem("Delayer", "It's like a slow wire, delaying a mechanical signal 1 tick", ids.delayer)
    mechCat:AddItem("Piston", "When it recieves a mechanical signal, it pushes the cell in front of the piston", ids.piston)
    mechCat:AddItem("Sticky Piston", "When it recieves a mechanical signal, it pushes a cell. When that signal stops, the piston pulls that cell back", ids.stickyPiston)
    mechCat:AddItem("Mechanical Generator", "Constantly generaters mechanical signals in all directions", ids.mech_gen)

    local lightBulbCat = mechCat:AddCategory("Light Bulbs", "Turn them on and they light up all cells around them!", texp .. "lightbulbs/brightest.png")

    lightBulbCat:AddItem("Light Bulb", "Average light bulb. 5x5", ids.lightBulb)
    lightBulbCat:AddItem("Bright Light Bulb", "Bright light bulb. 7x7", ids.brightLightBulb)
    lightBulbCat:AddItem("Brighter Light Bulb", "Brighter light bulb. 11x11", ids.brighterLightBulb)
    lightBulbCat:AddItem("Brightest Light Bulb", "The brightest light bulb. 19x19", ids.brightestLightBulb)

    -- Add gates o no
    local mechGateCat = mechCat:AddCategory("Mechanical Gates", "Cells that combine inputs to get a processed output", texp .. "gates/and.png")

    mechGateCat:AddItem("AND", "Performs AND operation", ids.g_and)
    mechGateCat:AddItem("OR", "Performs OR operation", ids.g_or)
    mechGateCat:AddItem("XOR", "Performs XOR operation", ids.g_xor)
    mechGateCat:AddItem("NAND", "Performs NAND operation", ids.g_nand)
    mechGateCat:AddItem("NOR", "Performs NOR operation", ids.g_nor)
    mechGateCat:AddItem("XNOR", "Performs XNOR operation", ids.g_xnor)
    mechGateCat:AddItem("NOT", "Performs NOT operation", ids.g_not)

    local destCat = Toolbar:GetCategory("Destroyers")
    destCat:AddItem("Enemy Slider", "Enemy but cells can only fall in from 2 sides", slideEnemy)
    destCat:AddItem("Trash Slider", "Trash but cells can only fall in from 2 sides", slideTrash)
    destCat:AddItem("Trash-Mover", "Trash cell moving on the grid. Complete total meme", ids.trashMover)
    destCat:AddItem("Silent Trash", "Trash cell that plays no sound", ids.silentTrash)

    local movCat = Toolbar:GetCategory("Movers")
    movCat:AddItem("Trash-Mover", "Trash cell moving on the grid. Complete total meme", ids.trashMover)
    movCat:AddItem("Slide Opener", "Can only open slide cells from the immovable sides. Doesn't move slide cells on other sides", ids.slideopener)

    local genCat = Toolbar:GetCategory("Generators")
    genCat:AddItem("4-way Generator", "Generates stuff from the opposite sides because... because.", ids.gen4)

  end
end

local function DoPiston(x, y, dir)
  if isMechOn(x, y) then
    PushCell(x, y, dir)
  end
end

local function DoLightbulb(x, y)
  if isMechOn(x, y) then
    local spos = calculateScreenPosition(x, y)
    local radius = 5

    local id = cells[y][x].ctype

    if id == ids.brightLightBulb then
      radius = 7
    elseif id == ids.brighterLightBulb then
      radius = 13
    elseif id == ids.brightestLightBulb then
      radius = 19
    end

    if spos.x > -radius*zoom or spos.y > -radius*zoom or spos.x < love.graphics.getWidth()-radius*zoom or spos.y < love.graphics.getHeight()-radius*zoom then

      local r, g, b, a = love.graphics.getColor()

      love.graphics.setColor(1, 1, 1, 0.01)
      for rds=1, radius, 0.2 do
        -- local dx = spos.x - love.graphics.getWidth()/2
        -- local dy = spos.y - love.graphics.getHeight()/2
        -- local dist2 = math.abs(dx * dx + dy * dy)
        if spos.x > -rds*zoom or spos.y > -rds*zoom or spos.x < love.graphics.getWidth()-rds*zoom or spos.y < love.graphics.getHeight()-rds*zoom then
          love.graphics.circle("fill", spos.x, spos.y, zoom*rds)
        end
      end
      love.graphics.setColor(r, g, b, a)
    end
  end
end

function DoSlideOpener(x, y, dir)
  local fx, fy = GetFullForward(x, y, dir)
  local nfx, nfy = GetFullForward(fx, fy, dir)
  local bx, by = GetFullForward(x, y, dir, -1)

  if cells[fy][fx].ctype == 4 then
    cells[fy][fx].rot = (cells[fy][fx].rot + 1) % 4
    if PushCell(bx, by, dir, true, 0) then
      cells[nfy][nfx].rot = (cells[nfy][nfx].rot - 1) % 4
    else
      cells[fy][fx].rot = (cells[fy][fx].rot - 1) % 4
    end
  else
    DoMover(x, y, dir)
  end
end

local function update(id, x, y, dir)
  if id == ids.motionSensor then
    DoMotionSensor(x, y, dir)
  elseif id == ids.delayer then
    DoDelayer(x, y)
  elseif id == ids.g_and then
    DoLogicGate(x, y, dir, "and")
  elseif id == ids.g_or then
    DoLogicGate(x, y, dir, "or")
  elseif id == ids.g_xor then
    DoLogicGate(x, y, dir, "xor")
  elseif id == ids.g_nand then
    DoLogicGate(x, y, dir, "nand")
  elseif id == ids.g_nor then
    DoLogicGate(x, y, dir, "nor")
  elseif id == ids.g_xnor then
    DoLogicGate(x, y, dir, "xnor")
  elseif id == ids.g_not then
    DoLogicGate(x, y, dir, "not")
  elseif id == ids.mech_gen then
    SignalMechanical(x, y)
  elseif id == ids.piston then
    DoPiston(x, y, dir)
  elseif id == ids.stickyPiston then
    DoStickyPiston(x, y, dir)
  elseif id == ids.trashMover then
    DoTrashMover(x, y, dir)
  elseif id == ids.wire and isMechOn(x, y) then
    cells[y][x].testvar = cells[y][x].mech_signal
  elseif id == ids.gen4 then
    Do4Gen(x, y)
  elseif id == ids.slideopener then
    DoSlideOpener(x, y, dir)
  end

  cells[y][x].prev_mech_signal = cells[y][x].mech_signal -- Useful for later ;)
  if isMechOn(x, y) then
    cells[y][x].mech_signal = cells[y][x].mech_signal - 1
  end
end

local function onCellDraw(id, x, y, rot)
  if id == ids.wire then
    local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)
    local renderArm = function(r)
      love.graphics.draw(wireArm.tex, spos.x, spos.y, r*half_pi, zoom/wireArm.size.w, zoom/wireArm.size.h, wireArm.size.w2, wireArm.size.h2)
    end

    if isConnectable(cells[y][x+1], 0) then
      renderArm(0)
    end
    if isConnectable(cells[y][x-1], 2) then
      renderArm(2)
    end
    if isConnectable(cells[y+1][x], 1) then
      renderArm(1)
    end
    if isConnectable(cells[y-1][x], 3) then
      renderArm(3)
    end

    if isMechOn(x, y) then
      love.graphics.draw(wireActive.tex, spos.x, spos.y, rot*half_pi, zoom/wireActive.size.w, zoom/wireActive.size.h, wireActive.size.w2, wireActive.size.h2)
    end
  elseif id == ids.piston and isMechOn(x, y) then
    local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)

    love.graphics.draw(pistonOn.tex, spos.x, spos.y, rot*half_pi, zoom/pistonOn.size.w, zoom/pistonOn.size.h, pistonOn.size.w2, pistonOn.size.h2)
  elseif id == ids.stickyPiston and isMechOn(x, y) then
    local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)

    love.graphics.draw(stickyPistonOn.tex, spos.x, spos.y, rot*half_pi, zoom/stickyPistonOn.size.w, zoom/stickyPistonOn.size.h, stickyPistonOn.size.w2, stickyPistonOn.size.h2)
  end
end

local function tick()
  -- No tick plz
end

local function onPlace(id, x, y, rot)
  cells[y][x].mech_signal = 0
end

local function customdraw()
  if not inmenu then
    for x=1,width-1 do
      for y=1,height-1 do
        local id = cells[y][x].ctype
        if cells[y][x].ctype == ids.lightBulb or id == ids.brightLightBulb or id == ids.brighterLightBulb or id == ids.brightestLightBulb then
          DoLightbulb(x, y)
        end
      end
    end
  end
end

local function onTrashEats(id, x, y, food, fx, fy)
  if id == ids.silentTrash then
    destroysound:stop()
  end
end

return {
  init = init,
  update = update,
  tick = tick,
  onCellDraw = onCellDraw,
  onPlace = onPlace,
  customdraw = customdraw,
  onTrashEats = onTrashEats,
}