local ids = {}

local texp = "MoreCells/"
local econfig = {}
if IsEssentials then
  texp = "Essentials/" .. texp
  econfig = GetEssentialsConfig()
end

local half_pi = math.pi / 2

local MAX_MECH = 2

function UpdateCell(id, x, y, dir, isPlayer)
  if id == 1 then
    DoMover(x, y, dir)
  elseif id == 2 or id == 39 or id == 22 then
    DoGenerator(x,y,dir,dir,id == 39)
    if id == 22 then
      dir = (dir-1)%4
      DoGenerator(x,y,dir,dir,dir%2 == 0)
    end
    cells[y][x].is_hidden_player = isPlayer
  elseif id == 25 then
    DoGenerator(x, y, (dir-1)%4, dir)
    cells[y][x].is_hidden_player = isPlayer
  elseif id == 26 then
    DoGenerator(x, y, (dir+1)%4, dir)
    cells[y][x].is_hidden_player = isPlayer
  elseif id == 44 or id == 45 then
    DoReplicator(x,y,dir,id ~= 45)
    if id == 45 then
      dir = (dir-1)%4
      DoReplicator(x,y,dir,false)
    end
    cells[y][x].is_hidden_player = isPlayer
  elseif id == 29 then
    for i=-1,1,2 do	--when lazy
      if cells[y][x+i].ctype == 8 then cells[y][x+i].ctype = 9 
      elseif cells[y][x+i].ctype == 9 then cells[y][x+i].ctype = 8 
      elseif cells[y][x+i].ctype == 17 then cells[y][x+i].ctype = 18
      elseif cells[y][x+i].ctype == 18 then cells[y][x+i].ctype = 17 
      elseif cells[y][x+i].ctype == 25 then cells[y][x+i].ctype = 26 cells[y][x+i].rot = (-cells[y][x+i].rot + 2)%4
      elseif cells[y][x+i].ctype == 26 then cells[y][x+i].ctype = 25 cells[y][x+i].rot = (-cells[y][x+i].rot + 2)%4
      elseif (cells[y][x+i].ctype == 6 or cells[y][x+i].ctype == 22 or cells[y][x+i].ctype == 30 or cells[y][x+i].ctype == 45 or cells[y][x+i].ctype == 52) and cells[y][x+i].rot%2 == 0 then cells[y][x+i].rot = (cells[y][x+i].rot - 1)%4
      elseif (cells[y][x+i].ctype == 6 or cells[y][x+i].ctype == 22 or cells[y][x+i].ctype == 30 or cells[y][x+i].ctype == 45 or cells[y][x+i].ctype == 52) then cells[y][x+i].rot = (cells[y][x+i].rot + 1)%4
      elseif (cells[y][x+i].ctype == 15 or cells[y][x+i].ctype == 56) and cells[y][x+i].rot%2 == 0 then cells[y][x+i].rot = (cells[y][x+i].rot + 1)%4
      elseif (cells[y][x+i].ctype == 15 or cells[y][x+i].ctype == 56) and cells[y][x+i].rot%2 == 1 then cells[y][x+i].rot = (cells[y][x+i].rot - 1)%4
      elseif hasFlipperTranslation(cells[y][x+i].ctype) then cells[y][x+i].ctype = makeFlipperTranslation(cells[y][x+i].ctype) SetChunk(x+i, y, cells[y][x+i].ctype)
      else cells[y][x+i].rot = (-cells[y][x+i].rot + 2)%4 end
    end
    for i=-1,1,2 do
      if cells[y+i][x].ctype == 8 then cells[y+i][x].ctype = 9 
      elseif cells[y+i][x].ctype == 9 then cells[y+i][x].ctype = 8 
      elseif cells[y+i][x].ctype == 17 then cells[y+i][x].ctype = 18
      elseif cells[y+i][x].ctype == 18 then cells[y+i][x].ctype = 17 
      elseif cells[y+i][x].ctype == 25 then cells[y+i][x].ctype = 26 cells[y+i][x].rot = (-cells[y+i][x].rot + 2)%4
      elseif cells[y+i][x].ctype == 26 then cells[y+i][x].ctype = 25 cells[y+i][x].rot = (-cells[y+i][x].rot + 2)%4
      elseif (cells[y+i][x].ctype == 6 or cells[y+i][x].ctype == 22 or cells[y+i][x].ctype == 30 or cells[y+i][x].ctype == 45 or cells[y+i][x].ctype == 52) and cells[y+i][x].rot%2 == 0 then cells[y+i][x].rot = (cells[y+i][x].rot - 1)%4
      elseif (cells[y+i][x].ctype == 6 or cells[y+i][x].ctype == 22 or cells[y+i][x].ctype == 30 or cells[y+i][x].ctype == 45 or cells[y+i][x].ctype == 52) then cells[y+i][x].rot = (cells[y+i][x].rot + 1)%4
      elseif (cells[y+i][x].ctype == 15 or cells[y+i][x].ctype == 56) and cells[y+i][x].rot%2 == 0 then cells[y+i][x].rot = (cells[y+i][x].rot + 1)%4
      elseif (cells[y+i][x].ctype == 15 or cells[y+i][x].ctype == 56) then cells[y+i][x].rot = (cells[y+i][x].rot - 1)%4
      elseif hasFlipperTranslation(cells[y+i][x].ctype) then cells[y+i][x].ctype = makeFlipperTranslation(cells[y+i][x].ctype) SetChunk(x, y+i, cells[y+i][x].ctype)
      else cells[y+i][x].rot = (-cells[y+i][x].rot + 2)%4 end
    end
  elseif id == 56 then
    if cells[y][x].rot == 0 then
      cells[y][x+1].rot = (cells[y][x+1].rot + 1)%4
      cells[y+1][x].rot = (cells[y+1][x].rot + 1)%4
      cells[y][x-1].rot = (cells[y][x-1].rot - 1)%4
      cells[y-1][x].rot = (cells[y-1][x].rot - 1)%4
    elseif cells[y][x].rot == 1 then
      cells[y][x+1].rot = (cells[y][x+1].rot - 1)%4
      cells[y+1][x].rot = (cells[y+1][x].rot + 1)%4
      cells[y][x-1].rot = (cells[y][x-1].rot + 1)%4
      cells[y-1][x].rot = (cells[y-1][x].rot - 1)%4
    elseif cells[y][x].rot == 2 then
      cells[y][x+1].rot = (cells[y][x+1].rot - 1)%4
      cells[y+1][x].rot = (cells[y+1][x].rot - 1)%4
      cells[y][x-1].rot = (cells[y][x-1].rot + 1)%4
      cells[y-1][x].rot = (cells[y-1][x].rot + 1)%4
    else
      cells[y][x+1].rot = (cells[y][x+1].rot + 1)%4
      cells[y+1][x].rot = (cells[y+1][x].rot - 1)%4
      cells[y][x-1].rot = (cells[y][x-1].rot - 1)%4
      cells[y-1][x].rot = (cells[y-1][x].rot + 1)%4
    end
  elseif id == 8 then
    cells[y][x-1].rot = (cells[y][x-1].rot + 1)%4
    cells[y][x+1].rot = (cells[y][x+1].rot + 1)%4
    cells[y-1][x].rot = (cells[y-1][x].rot + 1)%4
    cells[y+1][x].rot = (cells[y+1][x].rot + 1)%4
  elseif id == 9 then
    cells[y][x-1].rot = (cells[y][x-1].rot - 1)%4
    cells[y][x+1].rot = (cells[y][x+1].rot - 1)%4
    cells[y-1][x].rot = (cells[y-1][x].rot - 1)%4
    cells[y+1][x].rot = (cells[y+1][x].rot - 1)%4
  elseif id == 10 then
    cells[y][x-1].rot = (cells[y][x-1].rot - 2)%4
    cells[y][x+1].rot = (cells[y][x+1].rot - 2)%4
    cells[y-1][x].rot = (cells[y-1][x].rot - 2)%4
    cells[y+1][x].rot = (cells[y+1][x].rot - 2)%4
  elseif id == 17 then
    local jammed = false
    for i=0,8 do
      if i ~= 4 then
        cx = i%3-1
        cy = math.floor(i/3)-1
        local direction = DirFromOff(cx, cy)
        if cells[y+cy][x+cx].ctype == -1 or cells[y+cy][x+cx].ctype == 40 or cells[y+cy][x+cx].ctype == 17 or cells[y+cy][x+cx].ctype == 18 or cells[y+cy][x+cx].ctype == 11 or cells[y+cy][x+cx].ctype == 50 then
          jammed = true
        end
        if cells[y+cy][x+cx].ctype > initialCellCount then
          if isModdedTrash(cells[y+cy][x+cx].ctype) or (GetSidedTrash(cells[y+cy][x+cx].ctype) ~= nil and GetSidedTrash(cells[y+cy][x+cx].ctype)(x+cx, y+cy, direction) == false) then
            jammed = true
          else
            jammed = not canPushCell(x+cx, y+cy, x, y, "gear")
          end
        end
        if config['gears_restrictions'] ~= 'true' then
          jammed = false
        end
      end
    end
    if not jammed then
      local oldcell
      local storedcell = CopyCell(x-1,y)
      for i=-1,1 do
        oldcell = CopyCell(x+i,y-1)	
        cells[y-1][x+i] = storedcell
        if i == 0 then
          cells[y-1][x+i].rot = (storedcell.rot+1)%4
        end
        storedcell = oldcell
      end
      oldcell = CopyCell(x+1,y)	
      cells[y][x+1] = storedcell
      cells[y][x+1].rot = (storedcell.rot+1)%4
      storedcell = oldcell
      for i=1,-1,-1 do
        oldcell = CopyCell(x+i,y+1)	
        cells[y+1][x+i] = storedcell
        if i == 0 then
          cells[y+1][x+i].rot = (storedcell.rot+1)%4
        end
        storedcell = oldcell
      end
      cells[y][x-1] = storedcell
      cells[y][x-1].rot = (storedcell.rot+1)%4
      SetChunk(x+1,y+1,cells[y+1][x+1].ctype)
      SetChunk(x,y+1,cells[y+1][x].ctype)
      SetChunk(x-1,y+1,cells[y+1][x-1].ctype)
      SetChunk(x+1,y,cells[y][x+1].ctype)
      SetChunk(x+1,y-1,cells[y-1][x+1].ctype)
      SetChunk(x,y-1,cells[y-1][x].ctype)
      SetChunk(x-1,y-1,cells[y-1][x-1].ctype)
      SetChunk(x-1,y,cells[y][x-1].ctype)
    end
  elseif id == 18 then
    local jammed = false
    for i=0,8 do
      if i ~= 4 then
        cx = i%3-1
        cy = math.floor(i/3)-1
        local direction = DirFromOff(cx, cy)
        if cells[y+cy][x+cx].ctype == -1 or cells[y+cy][x+cx].ctype == 40 or cells[y+cy][x+cx].ctype == 17 or cells[y+cy][x+cx].ctype == 18 or cells[y+cy][x+cx].ctype == 11 or cells[y+cy][x+cx].ctype == 50 then
          jammed = true
        end
        if cells[y+cy][x+cx].ctype > initialCellCount then
          if isModdedTrash(cells[y+cy][x+cx].ctype) or (GetSidedTrash(cells[y+cy][x+cx].ctype) ~= nil and GetSidedTrash(cells[y+cy][x+cy].ctype)(x+cx, y+cy, direction) == false) then
            jammed = true
          else
            jammed = not canPushCell(x+cx, y+cy, x, y, "gear")
          end
        end
        if config['gears_restrictions'] ~= 'true' then
          jammed = false
        end
      end
    end
    if not jammed then
      local oldcell
      local storedcell = CopyCell(x+1,y)
      for i=1,-1,-1 do
        oldcell = CopyCell(x+i,y-1)	
        cells[y-1][x+i] = storedcell
        if i == 0 then
          cells[y-1][x+i].rot = (storedcell.rot-1)%4
        end
        storedcell = oldcell
      end
      oldcell = CopyCell(x-1,y)	
      cells[y][x-1] = storedcell
      cells[y][x-1].rot = (storedcell.rot-1)%4
      storedcell = oldcell
      for i=-1,1 do
        oldcell = CopyCell(x+i,y+1)	
        cells[y+1][x+i] = storedcell
        if i == 0 then
          cells[y+1][x+i].rot = (storedcell.rot-1)%4
        end
        storedcell = oldcell
      end
      cells[y][x+1] = storedcell
      cells[y][x+1].rot = (storedcell.rot-1)%4
      SetChunk(x+1,y+1,cells[y+1][x+1].ctype)
      SetChunk(x,y+1,cells[y+1][x].ctype)
      SetChunk(x-1,y+1,cells[y+1][x-1].ctype)
      SetChunk(x+1,y,cells[y][x+1].ctype)
      SetChunk(x+1,y-1,cells[y-1][x+1].ctype)
      SetChunk(x,y-1,cells[y-1][x].ctype)
      SetChunk(x-1,y-1,cells[y-1][x-1].ctype)
      SetChunk(x-1,y,cells[y][x-1].ctype)
    end
  elseif id == 16 then
    if cells[y][x-1].ctype ~= 16 then cells[y][x-1].rot = cells[y][x].rot end
    if cells[y][x+1].ctype ~= 16 then cells[y][x+1].rot = cells[y][x].rot end
    if cells[y-1][x].ctype ~= 16 then cells[y-1][x].rot = cells[y][x].rot end
    if cells[y+1][x].ctype ~= 16 then cells[y+1][x].rot = cells[y][x].rot end
  elseif id == 28 then
    if x > 1 then PullCell(x-2,y,0,false,1) end
    if x < width-2 then PullCell(x+2,y,2,false,1) end
    if y > 1 then PullCell(x,y-2,3,false,1) end
    if y < height-2 then PullCell(x,y+2,1,false,1) end
  elseif id == 20 then
    PushCell(x,y,0)
    PushCell(x,y,2)
    PushCell(x,y,3)
    PushCell(x,y,1)
  elseif id == 49 then
    DoSuperRepulser(x,y,0)
    supdatekey = supdatekey + 1
    DoSuperRepulser(x,y,2)
    supdatekey = supdatekey + 1
    DoSuperRepulser(x,y,3)
    supdatekey = supdatekey + 1
    DoSuperRepulser(x,y,1)
    supdatekey = supdatekey + 1
  elseif id == 57 then
    DoDriller(x,y,dir)
  elseif id == 27 then
    DoAdvancer(x, y, dir)
  elseif id == 13 then
    cells[y][x].updated = false
		PullCell(x,y,dir)
    --UpdatePullers()
  elseif id > 30 and id < 37 then
    DoGate(x, y, dir, id-30)
  elseif id == 24 then
    cells[y+1][x].updated = (cells[y+1][x].ctype ~= 19 and not isUnfreezable(cells[y+1][x].ctype))	--mold disappears if .updated is true
    cells[y-1][x].updated = (cells[y-1][x].ctype ~= 19 and not isUnfreezable(cells[y-1][x].ctype))
    cells[y][x+1].updated = (cells[y][x+1].ctype ~= 19 and not isUnfreezable(cells[y][x+1].ctype))
    cells[y][x-1].updated = (cells[y][x-1].ctype ~= 19 and not isUnfreezable(cells[y][x-1].ctype))
  elseif id == 42 then
    for cx=x-1,x+1 do
      for cy=y-1,y+1 do
        cells[cy][cx].protected = true
      end
    end
  elseif id == 14 or id == 55 then
    local rotSide = (dir%2 == 0) or (id == 55)
    local rotUp = (dir%2 == 1) or (id == 55)
    if (dir%2 == 0) or (id == 55) then
      local canPushLeft = true
      local canPushRight = true
      if cells[y][x-1] ~= nil then
        if cells[y][x-1].ctype > initialCellCount then
          canPushLeft = canPushCell(x-1, y, x, y, "mirror")
        end
      end
      if cells[y][x+1] ~= nil then
        if cells[y][x+1].ctype > initialCellCount then
          canPushRight = canPushCell(x+1, y, x, y, "mirror")
        end
      end
      if isModdedTrash(cells[y][x-1].ctype) or ((GetSidedTrash(cells[y][x-1].ctype) ~= nil and GetSidedTrash(cells[y][x-1].ctype)(x-1, y, 2) == false)) then
        canPushLeft = false
      end
      if isModdedTrash(cells[y][x+1].ctype) or (GetSidedTrash(cells[y][x+1].ctype) ~= nil and GetSidedTrash(cells[y][x+1].ctype)(x+1, y, 2) == false) then
        canPushRight = false
      end
      if (cells[y][x-1].ctype ~= 11 and cells[y][x-1].ctype ~= 50 and cells[y][x-1].ctype ~= 55 and cells[y][x-1].ctype ~= -1 and cells[y][x-1].ctype ~= 40 and (cells[y][x-1].ctype ~= 14 or cells[y][x-1].rot%2 == 1) and canPushLeft
      and cells[y][x+1].ctype ~= 11 and cells[y][x+1].ctype ~= 50 and cells[y][x+1].ctype ~= 55 and cells[y][x+1].ctype ~= -1 and cells[y][x+1].ctype ~= 40 and (cells[y][x+1].ctype ~= 14 or cells[y][x+1].rot%2 == 1) and canPushRight) or config['mirror_restrictions'] ~= 'true' then
        local oldcell = CopyCell(x-1,y)
        cells[y][x-1] = CopyCell(x+1,y)
        cells[y][x+1] = oldcell
        SetChunk(x-1,y,cells[y][x-1].ctype)
        SetChunk(x+1,y,cells[y][x+1].ctype)
      end
    end
    if (dir%2 == 1) or (id == 55) then
      local canPushUp = true
      local canPushDown = true
      if cells[y-1] ~= nil then
        if cells[y-1][x].ctype > initialCellCount then
          canPushUp = canPushCell(x, y-1, x, y, "mirror")
        end
      end
      if cells[y+1] ~= nil then
        if cells[y+1][x].ctype > initialCellCount then
          canPushDown = canPushCell(x, y+1, x, y, "mirror")
        end
      end
      if cells[y-1] ~= nil then
        if isModdedTrash(cells[y-1][x].ctype) or ((GetSidedTrash(cells[y-1][x].ctype) ~= nil and GetSidedTrash(cells[y-1][x].ctype)(x, y-1, 3) == false)) then
          canPushUp = false
        end
      end
      if cells[y+1] ~= nil then
        if isModdedTrash(cells[y+1][x].ctype) or ((GetSidedTrash(cells[y+1][x].ctype) ~= nil and GetSidedTrash(cells[y+1][x].ctype)(x, y+1, 3) == false)) then
          canPushDown = false
        end
      end
      if not cells[y][x].updated and (cells[y][x].ctype == 14 and (cells[y][x].rot == 1 or cells[y][x].rot == 3) or cells[y][x].ctype == 55) then
        if cells[y-1][x].ctype ~= 11 and cells[y-1][x].ctype ~= 55 and cells[y-1][x].ctype ~= 50 and cells[y-1][x].ctype ~= -1 and cells[y-1][x].ctype ~= 40 and (cells[y-1][x].ctype ~= 14 or cells[y-1][x].rot%2 == 0)
        and cells[y+1][x].ctype ~= 11 and cells[y+1][x].ctype ~= 55 and cells[y+1][x].ctype ~= -1 and cells[y+1][x].ctype ~= 40 and (cells[y+1][x].ctype ~= 14 or cells[y+1][x].rot%2 == 0) and canPushUp and canPushDown or config['mirror_restrictions'] ~= 'true' then
          local oldcell = CopyCell(x,y-1)
          cells[y-1][x] = CopyCell(x,y+1)
          cells[y+1][x] = oldcell
          SetChunk(x,y-1,cells[y-1][x].ctype)
          SetChunk(x,y+1,cells[y+1][x].ctype)
        end
      end
    end
  elseif id == 43 then
    DoIntaker(x, y, dir)
  elseif id == 54 then
    DoSuperGenerator(x,y,dir)
		supdatekey = supdatekey + 1
  elseif id > initialCellCount then
    DoModded(x, y, dir)
  end
end

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
local crossArm = makeTex(texp .. "wire/cross_arm.png")
local crossPower1 = makeTex(texp .. "wire/cross/cross3.png")
local crossPower2 = makeTex(texp .. "wire/cross/cross2.png")
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

    if (id == ids.motionSensor) or (id == ids.piston) or (id == ids.stickyPiston) or (id == ids.movementSensor) then
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
      local o = walkDivergedPath(x, y, ox, oy)
      ox = o.x
      oy = o.y
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

      if id ~= ids.wire and id ~= ids.motionSensor and id ~= ids.mech_gen and not isUnfreezable(id) then
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
    local bx, by = GetFullForward(x, y, dir, -1)
    local b = walkDivergedPath(x, y, bx, by)
    bx = b.x
    by = b.y
    local back = backWorks[dir]
    local canGen = true
    if back.ctype > initialCellCount then
      canGen = CanGenCell(cells[y][x].ctype, x, y, back.ctype, bx, by, dir)
    end
    if back.ctype ~= 0 and back.ctype ~= 40 and canGen then
      local bdir = (back.rot + f.dir - dir) % 4
      if PushCell(x, y, dir, true, 1, back.ctype, bdir, nil, {x, y, bdir}) then
        if cells[fy][fx].ctype == 19 then cells[fy][fx].ctype = 0 end
        if cells[fy][fx].ctype == ids.gen4 then cells[fy][fx].updated = true end
      end
    end
  end
end

local function Do4Rep(x, y)
  for dir=0,3 do
    local fx, fy = GetFullForward(x, y, dir)

    local f = walkDivergedPath(x, y, fx, fy)
    fx = f.x
    fy = f.y

    local front = cells[fy][fx]

    local fdir = (front.rot - f.dir + dir) % 4

    local canGen = true
    if front.ctype > initialCellCount then
      canGen = CanGenCell(cells[y][x].ctype, x, y, front.ctype, fx, fy, dir)
    end

    if front.ctype ~= 0 and front.ctype ~= 40 and canGen then
      PushCell(x, y, dir, true, 1, front.ctype, fdir, nil, {x, y, fdir})
      if front.ctype == 19 then
        cells[fy][fx].ctype = 0
      elseif front.ctype == ids.rep4 then
        cells[fy][fx].updated = true
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

local function DoEnemyMover(x, y, dir)
  local fx, fy = GetFullForward(x, y, dir)

  if not inGrid(fx, fy) then
    return
  end

  if canPush(fx, fy, dir) then
    local front = cells[fy][fx]
    local id = front.ctype
    if id ~= 0 then
      if id == 11 or isModdedTrash(id) then
        if id ~= 11 then
          modsOnTrashEat(id, fx, fy, cells[y][x], x, y)
        end
      else
        destroysound:play()
        enemyparticles:setPosition(fx*20,fy*20)
        enemyparticles:emit(50)
        if id == 23 then
          cells[fy][fx].ctype = 12
        else
          cells[fy][fx].ctype = 0
        end
        if isModdedBomb(id) then
          modsOnModEnemyDed(id, fx, fy, cells[y][x], x, y)
        end
        cells[y][x] = {
          ctype = 0,
          rot = 0,
          lastvars = {
            x, y, 0
          }
        }
      end
    end
    -- If we haven't exploded, we go
    if cells[y][x].ctype ~= 0 then
      FakeMoveForward(x, y, dir)
    end
  end
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

local function backOnlySided(x, y, dir)
  return (dir == (cells[y][x].rot))
end

local function DoPortal(id, x, y, food, fx, fy)
  local seeking = ids.portal_b

  if id == seeking then seeking = ids.portal_a end

  local fdir = food.rot

  local closestDist = 1/0
  local seeker = {x, y, cells[y][x].rot}
  -- Ah yes, PERFORMANCE
  for sy=1,height-1 do
    for sx=1,width-1 do
      if cells[sy][sx].ctype == seeking then
        local dist = math.pow(sx - x, 2) + math.pow(sy - y, 2)
        if closestDist > dist then
          closestDist = dist
          seeker = {sx, sy, cells[sy][sx].rot}
        end
      end
    end
  end

  -- Now we get to the portal-ing
  if seeker then
    -- Portal tiem
    local relativeDir = (DirFromOff(fx - x, fy - y)+2)%4
    local sx, sy, sdir = seeker[1], seeker[2], seeker[3]
    fdir = (fdir + sdir - cells[y][x].rot) % 4
    relativeDir = (relativeDir + sdir - cells[y][x].rot) % 4
    if PushCell(sx, sy, relativeDir, true, 999999999, food.ctype, fdir, nil, {sx, sy, fdir}) then
      local sfx, sfy = GetFullForward(sx, sy, relativeDir)
      local sf = walkDivergedPath(sx, sy, sfx, sfy)
      sfx, sfy = sf.x, sf.y
      for k, v in pairs(food) do
        if k ~= "lastvars" and k ~= "rot" and k ~= "ctype" and k ~= "updated" then
          cells[sfy][sfx][k] = v
        end
      end
    end
  end
end

local playerPosCache

local function getPlayerPos()
  if playerPosCache then
    return playerPosCache[1], playerPosCache[2]
  end

  for y=1,height-1 do
    for x=1,width-1 do
      if cells[y][x].ctype == ids.player or cells[y][x].is_hidden_player then
        playerPosCache = {x, y}
        return x, y
      end
    end
  end
  
  return nil, nil
end

-- This wil lcome in handy later :)
local function DoSeeker(x, y, dir)
  local px, py = getPlayerPos()

  if px == nil then return end

  local dx, dy = px - x, py - y

  local ox, oy = dx, dy

  if math.abs(ox) <= 1 and math.abs(oy) <= 1 then
    cells[py][px] = {
      ctype = 0,
      rot = 0,
      lastvars = {
        px, py, 0
      }
    }
  else
    local mdir = nil

    if dx > 0 then
      mdir = 0
    elseif dx < 0 then
      mdir = 2
    elseif dy > 0 then
      mdir = 1
    elseif dy < 0 then
      mdir = 3
    end

    if type(mdir) == "number" then
      cells[y][x].rot = mdir
      local bx, by = GetFullForward(x, y, mdir, -1)
      PushCell(bx, by, mdir, true, 0)
    end
  end
end

local function dontpull(x, y, rot, px, py, prot, ptype)
  return ptype ~= "pull"
end

local function dontpullSide(x, y, rot, px, py, prot, ptype)
  local dx, dy = px - x, py - y
  local dir = DirFromOff(dx, dy)

  if dir % 2 ~= rot % 2 then
    return true
  else
    return ptype ~= "pull"
  end
end

local function init()
  local placeholder = "textures/push.png"

  -- Gens
  ids.motionSensor = addCell("EMC mech motion-sensor", texp .. "motionSensor.png", {updateindex = 1})
  ids.delayer = addCell("EMC mech motion-sensor", texp .. "delayer.png", {updateindex = 2})
  ids.wire = addCell("EMC mech wire", texp .. "wire/off.png", {updateindex = 3})
  ids.mech_gen = addCell("EMC mech mech_gen", texp .. "mech_gen.png", {updateindex = 4})
  --ids.movementSensor = addCell("EMC mech move-sensor", placeholder, {updateindex = 5})
  -- Users
  ids.activator = addCell("EMC mech activator", texp .. "activator.png", Options.neverupdate)
  ids.piston = addCell("EMC mech piston", texp .. "piston/off.png", Options.neverupdate)
  ids.stickyPiston = addCell("EMC mech piston-sticky", texp .. "piston/sticky-off.png", Options.neverupdate)
  ids.lightBulb = addCell("EMC mech light-bulb", texp .. "lightbulbs/normal.png", Options.static)
  ids.brightLightBulb = addCell("EMC mech light-bulb-bright", texp .. "lightbulbs/bright.png", Options.static)
  ids.brighterLightBulb = addCell("EMC mech light-bulb-brighter", texp .. "lightbulbs/brighter.png", Options.static)
  ids.brightestLightBulb = addCell("EMC mech light-bulb-brightest", texp .. "lightbulbs/brightest.png", Options.static)
  ids.slideopener = addCell("EMC mech slideopener", texp .. "slideopener.png", Options.mover)
  ids.switch = addCell("EMC mech flip-flop", texp .. "mech/tflipflop.png")
  ids.clockgen_mech = addCell("EMC mech crosswire", texp .. "mech/clockgen.png")

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

  local nopullID = addCell("EMC no-pull", texp .. "push/nopull.png", {dontupdate=true, push = dontpull})
  local nopullsideID = addCell("EMC no-pull-side", texp .. "push/nopullside.png", {dontupdate=true, push = dontpullSide})
  ids.crossintaker = addCell("EMC cross-intaker", texp .. "exotic/intakross.png")
  ids.strongerenemy = addCell("EMC stronger-enemy", texp .. "enemies/stronger_enemy.png", {type="enemy",dontupdate=true})
  ids.cross_supgen = addCell("EMC cross-supgen", texp .. "generators/cross_supgen.png")

  ids.fan = addCell("EMC fan", texp .. "fans/fan.png")
  ids.strongfan = addCell("EMC strong-fan", texp .. "fans/strongfan.png")
  ids.hyperfan = addCell("EMC hyper-fan", texp .. "fans/hyperfan.png")
  ids.conveyor = addCell("EMC conveyor", texp .. "conveyor.png")
  ids.monitor = addCell("EMC monitor", texp .. "monitor.png", Options.neverupdate)
  ids.musical = addCell("EMC musical", texp .. "musical.png", {type = "trash", silent = true, dontupdate = true})
  ids.player = addCell("EMC player", texp .. "player.png", Options.combine(Options.mover, Options.ungenable))
  ids.seeker = addCell("EMC seeker", texp .. "seeker.png", {type="mover"})
  ids.matterBlob = addCell("EMC matter blob", texp .. "matter/blob.png", Options.combine(Options.mover, Options.invisible))
  ids.matterConverter = addCell("EMC matter converter", texp .. "matter/converter.png")
  ids.nuclearBomb = addCell("EMC nuclear bomb", texp .. "nuclear_bomb.png", {type="enemy", dontupdate = true})
  ids.blackhole = addCell("EMC blackhole", texp .. "blackhole.png", Options.combine(Options.unpushable, Options.ungenable, {updateindex = 1}))
  ids.superimpulser = addCell("EMC super-impulser", texp .. "superimpulser.png")
  ToggleFreezability(ids.player)

  addFlipperTranslation(ids.monitor, ids.musical, false)
  addFlipperTranslation(1, 13)

  -- Portals
  local portalOptions = {type = "trash", dontupdate = true, silent = true}
  ids.portal_a = addCell("EMC portal-a", texp .. "portals/a.png", portalOptions)
  ids.portal_b = addCell("EMC portal-b", texp .. "portals/b.png", portalOptions)

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

  -- ids.enemyMover = addCell("EMC enemy-mover", texp .. "enemyMove.png", {type = "sideenemy"})

  -- SetSidedEnemy(ids.enemyMover, function(x, y, dir)
  --   if dir == nil then return false end
  --   return ((dir+2)%4 == cells[y][x].rot)
  -- end)

  ids.ghostTrash = addCell("EMC ghost_trash", texp .. "ghost_trash.png", Options.combine(Options.ungenable, Options.trash))

  ids.forward_right_forker = addCell("EMC forward-right-forker", texp .. "forkers/sided_forker.png", {type="sidetrash", dontupdate = true, silent = true})
  ids.forward_left_forker = addCell("EMC forward-left-forker", texp .. "forkers/opposite_sided_forward.png", {type="sidetrash", dontupdate = true, silent = true})

  SetSidedTrash(ids.forward_right_forker, backOnlySided)
  SetSidedTrash(ids.forward_right_forker, backOnlySided)

  ids.gen4 = addCell("EMC gen4", texp .. "4waygen.png")
  ids.rep4 = addCell("EMC rep4", texp .. "4wayrep.png")
  ids.magnet = addCell("EMC magnet", texp .. "magnet.png")

  ids.silentTrash = addCell("EMC silent-trash", texp .. "silentTrash.png", Options.combine(Options.trash, Options.neverupdate, {silent = true}))

  if Toolbar then
    local mechCat = Toolbar:AddCategory("Mechanical Cells", "Cells that use mechanical systems", texp .. "wire/on.png")

    mechCat:AddItem("Motion Sensor", "Senses motion. If it detects motion, it outputs a mechanical signal", ids.motionSensor)
    --mechCat:AddItem("Movement Sensor", "If moved, it outputs a mechanical signal", ids.movementSensor)
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
    local mechGateCat = mechCat:AddCategory("Mechanical Gates", "Cells that combine 2 inputs from sides to get a processed output out front", texp .. "gates/and.png")

    mechGateCat:AddItem("AND", "Performs AND operation", ids.g_and)
    mechGateCat:AddItem("OR", "Performs OR operation", ids.g_or)
    mechGateCat:AddItem("XOR", "Performs XOR operation", ids.g_xor)
    mechGateCat:AddItem("NAND", "Performs NAND operation", ids.g_nand)
    mechGateCat:AddItem("NOR", "Performs NOR operation", ids.g_nor)
    mechGateCat:AddItem("XNOR", "Performs XNOR operation", ids.g_xnor)
    mechGateCat:AddItem("NOT", "Performs NOT operation. Input on back", ids.g_not)

    local destCat = Toolbar:GetCategory("Destroyers")
    destCat:AddItem("Stronger Enemy", "When it dies it turns into a strong enemy. Basically a enemy with 3 hp", ids.strongerenemy)
    destCat:AddItem("Enemy Slider", "Acts as an enemy cell but cells can only fall in from 2 sides. Acts as a push cell on other 2 sides", slideEnemy)
    destCat:AddItem("Trash Slider", "Acts as a trash cell but cells can only fall in from 2 sides. Acts as a push cell on other 2 sides", slideTrash)
    destCat:AddItem("Enemy-Mover", "Enemy cell moving on the grid. Complete total meme", ids.enemyMover)
    destCat:AddItem("Trash-Mover", "Trash cell moving on the grid. Complete total meme", ids.trashMover)
    destCat:AddItem("Silent Trash", "Trash cell that plays no sound", ids.silentTrash)
    destCat:AddItem("Ghost Trash", "Trash cell that can't be generated", ids.ghostTrash)
    destCat:AddItem("Nuclear Bomb", "One of, if not THE most powerful bomb in modded CelLua history", ids.nuclearBomb)
    destCat:AddItem("Black hole", "Nobody knows what's inside.", ids.blackhole)

    local movCat = Toolbar:GetCategory("Movers")
    movCat:AddItem("Super Impulser", "Impulser up to 11", ids.superimpulser)
    movCat:AddItem("Trash-Mover", "Trash cell moving on the grid. Complete total meme", ids.trashMover)
    movCat:AddItem("Slide Opener", "A mover that, when pushing sliders, can only push them on the wrong sides.", ids.slideopener)
    
    local fanCat = movCat:AddCategory("Fans", "They create a constant force pushing cells in front.", texp .. "fans/fan.png")
    fanCat:AddItem("Fan", "Only pushes cells directly in front of it", ids.fan)
    fanCat:AddItem("Super Fan", "Has a range of 2 cell units", ids.strongfan)
    fanCat:AddItem("Hyper Fan", "Has a range of 4 cell units", ids.hyperfan)
    
    movCat:AddItem("Conveyor Cell", "Pushes the cells on its sides forward", ids.conveyor)
    movCat:AddItem("Magnet", "Pushes on one side and pulls on the other.", ids.magnet)

    local genCat = Toolbar:GetCategory("Generators")
    genCat:AddItem("4-way Generator", "Generates stuff from the opposite sides just because.", ids.gen4)
    genCat:AddItem("4-way Replicator", "Replicates stuff on all 4 sides.", ids.rep4)

    local forkerCat = Toolbar:GetCategory("Forkers")
    forkerCat:AddItem("Forward-Right Forker", "Name says it all", ids.forward_right_forker)
    forkerCat:AddItem("Forward-Left Forker", "Name says it all", ids.forward_left_forker)

    local uniqueCat = Toolbar:GetCategory("Unique cells")
    uniqueCat:AddItem("Cross Intaker", "Acts like 2 intakers stacked on top of eachother facing perpendicular directions", ids.crossintaker)
    uniqueCat:AddItem("Monitor", "GuyWithAMonitor#1595\nWhen placing a cell on a monitor, the monitor will display that cell", ids.monitor)
    uniqueCat:AddItem("The Musical Cell", "\"At last, it has come.\" \nIs a trash cell but plays a special sound based off of where the cell came from.", ids.musical)
    uniqueCat:AddItem("Player Cell", "Cell that can be controlled by the I, J and L keys. You can even control multiple at once!", ids.player)
    uniqueCat:AddItem("Seeker Cell", "Hunts down players. Just make sure it doesn't get too close", ids.seeker)
    uniqueCat:AddItem("Portal A", "When something falls in, it gets sent to the nearest portal B", ids.portal_a)
    uniqueCat:AddItem("Portal B", "When something falls in, it gets sent to the nearest portal A", ids.portal_b)
    uniqueCat:AddItem("Matter Converter", "Converts the cell behind it to a matter blob", ids.matterConverter)
    --uniqueCat:AddItem("Matter Blob", "", ids.matterBlob)

    local pushCat = Toolbar:GetCategory("Pushes")
    pushCat:AddItem("Unpullable", "It can only be moved. Never pulled", nopullID)
    pushCat:AddItem("Unpullable on sides", "Like a flipped slide cell that only applies to pullers", nopullsideID)

    local genCat = Toolbar:GetCategory("Generators")
    genCat:AddItem("Cross Super Generator", "Acts like 2 super generators stacked on top of eachother facing perpendicular directions", ids.cross_supgen)
  end
end

local function DoPiston(x, y, dir)
  if isMechOn(x, y) then
    PushCell(x, y, dir)
  end
end

local function DoLightbulb(x, y)
  if isMechOn(x, y) then
    local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)
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

local function restoreRotations(rotations, x, y, dir, id, ar, applyrot)
  local fx, fy = x, y

  for i=0,#rotations do
    if type(rotations[i]) == "number" then
      local lx, ly = fx, fy
      fx, fy = GetFullForward(fx, fy, dir)

      local f = walkDivergedPath(lx, ly, fx, fy)
      fx = f.x
      fy = f.y
      local odir = dir
      dir = f.dir
      local appliedRot = dir - odir

      if cells[fy][fx].ctype == id then
        if not applyrot then appliedRot = 0 end
        cells[fy][fx].rot = rotations[i] + appliedRot + ar
      end
    end
  end
end

function DoSlideOpener(x, y, dir)
  local fx, fy = GetFullForward(x, y, dir)
  local f = walkDivergedPath(x, y, fx, fy)
  fx = f.x
  fy = f.y
  local appliedRot = f.dir - dir

  local originalRots = {}
  -- Get rots
  local cx, cy = GetFullForward(x, y, dir)
  local c = walkDivergedPath(x, y, cx, cy)
  cx = c.x
  cy = c.y
  local cdir = c.dir
  repeat
    if inGrid(cx, cy) and cells[cy][cx].ctype ~= 0 then
      table.insert(originalRots, cells[cy][cx].rot)
      if cells[cy][cx].ctype == 4 then
        cells[cy][cx].rot = (cells[cy][cx].rot + 1) % 4
      end
      local lx, ly = cx, cy
      cx, cy = GetFullForward(cx, cy, cdir)

      local nc = walkDivergedPath(lx, ly, cx, cy)
      cx = nc.x
      cy = nc.y
      cdir = nc.dir
    end
  until cells[cy][cx].ctype == 0 or not inGrid(cx, cy)

  local bx, by = GetFullForward(x, y, dir, -1)
  if PushCell(bx, by, dir, true, 0) then
    restoreRotations(originalRots, fx, fy, f.dir, 4, 0, true)
  else
    restoreRotations(originalRots, x, y, f.dir, 4, 0, false)
  end
end

local function DoConveyor(x, y, dir)
  local lx, ly = GetFullForward(x, y, dir-1)
  local rx, ry = GetFullForward(x, y, dir+1)

  local off = GetForward(dir, -1)
  local ox, oy = off.x, off.y
  local strength = 1

  if cells[ly][lx].ctype ~= 0 then
    PushCell(lx+ox, ly+oy, dir, true, strength)
  elseif cells[ry][rx].ctype ~= 0 then
    PushCell(rx+ox, ry+oy, dir, true, strength)
  end
end

local function DoMagnet(x, y, dir)
  local pullX, pullY = GetFullForward(x, y, dir, -2)

  PushCell(x, y, dir, true, 1)
  PullCell(pullX, pullY, dir, false, 1)
end

local function DoFan(x, y, dir)
  local id = cells[y][x].ctype
  local fx, fy = x, y
  local px, py = x, y

  local range = 1
  if id == ids.strongfan then range = 2 end
  if id == ids.hyperfan then range = 4 end

  for i=1,range do
    px, py = fx, fy
    fx, fy = GetFullForward(fx, fy, dir)
    local f = walkDivergedPath(px, py, fx, fy)
    dir = f.dir
    fx = f.x
    fy = f.y

    local front = CopyTable(cells[fy][fx])
    if not PushCell(px, py, dir, true, 1) then return end
  end
end

local function DoPlayer(x, y, dir, recursive)
  cells[y][x].updated = true
  if love.keyboard.isDown('up') and not recursive then
    if love.keyboard.isDown('lshift') then
      local id = cells[y][x].ctype
      if id == 11 or id == 12 or id == 23 or id == 50 or isModdedBomb(id) or isModdedTrash(id) or GetSidedTrash(id) ~= nil or GetSidedEnemy(id) ~= nil then
        local fx, fy = GetFullForward(x, y, dir)
        local fid = cells[fy][fx].ctype
        if (fid == 0) or (fid ~= 11 and fid ~= 12 and fid ~= 23 and fid ~= 50 and (not isModdedBomb(fid)) and (not isModdedTrash(fid))) and (not (GetSidedTrash(fid) ~= nil and GetSidedTrash(fid)(fx, fy, dir) == true)) and (not (GetSidedEnemy(fid) ~= nil and GetSidedEnemy(fid)(fx, fy, dir) == true) and fid ~= 47 and fid ~= 48) then
          if PushCell(x, y, dir, true, 1) then
            FakeMoveForward(x, y, dir)
          end
        else
          if fid == 11 or fid == 50 or isModdedTrash(fid) or (GetSidedTrash(fid) ~= nil) or fid == 47 or fid == 48 then
            cells[y][x].is_hidden_player = true
            if isModdedTrash(fid) or (GetSidedTrash(fid) ~= nil) then
              modsOnTrashEat(fid, fx, fy, cells[y][x], x, y)
            elseif fid == 50 then
              for odir=0,3 do
                local ox, oy = GetFullForward(x, y, odir)
                if inGrid(ox, oy) then
                  cells[oy][ox] = {
                    ctype = 0, rot = 0, lastvars = {ox, oy, 0}
                  }
                end
              end
            elseif fid == 47 or fid == 48 then
              local frot = cells[fy][fx].rot
              if fid == 48 then
                PushCell(fx, fy, frot, true, 1, id, dir)
              end
              PushCell(fx, fy, (frot-1)%4, true, 1, id, (dir-1)%4)
              PushCell(fx, fy, (frot+1)%4, true, 1, id, (dir+1)%4)
            end
            if (not IsSilent(fid)) and fid ~= 47 and fid ~= 48 then
              destroysound:play()
            end
            cells[y][x].ctype = 0
          elseif fid == 12 or fid == 23 or isModdedBomb(fid) or (GetSidedEnemy(fid) ~= nil) then
            if fid == 12 then
              cells[fy][fx].ctype = 0
            elseif fid == 23 then
              cells[fy][fx].ctype = 12
            elseif fid > initialCellCount then
              cells[fy][fx].ctype = 0
              modsOnModEnemyDed(fid, fx, fy, cells[y][x], x, y)
            end
            cells[y][x].ctype = 0
            if not IsSilent(fid) then
              destroysound:play()
            end
            enemyparticles:setPosition(fx*20,fy*20)
						enemyparticles:emit(50)
          end
        end
      else
        local bx, by = GetFullForward(x, y, dir, -1)
        local force = 1

        if id == 1 or id == 13 or id == 27 or moddedMovers[id] ~= nil then
          force = force - 1
        end

        if id == 21 or type(cellWeights[id]) == "number" then
          force = force + (cellWeights[id] or 1)
        end

        if PushCell(bx, by, dir, true, force, nil, nil, id == 46) then
          -- Forcibly update
          if id == 46 then
            local fx, fy = GetFullForward(x, y, dir)
            cells[fy][fx].updated = true
          end
        end
      end
    elseif cells[y][x].ctype == ids.player then
      DoMover(x, y, dir)
    else
      local fx, fy = GetFullForward(x, y, dir)
      UpdateCell(cells[y][x].ctype, x, y, dir, true)
      if cells[fy][fx].is_hidden_player and cells[y][x].is_hidden_player then
        cells[y][x] = {
          ctype = 0,
          rot = 0,
          lastvars = {
            x, y, 0,
          }
        }
      end
    end
  elseif love.keyboard.isDown('down') then
    -- Kopy ability
    local fx, fy = GetFullForward(x, y, dir)
    if cells[fy][fx].ctype ~= 0 and cells[fy][fx].ctype ~= 40 and cells[fy][fx].ctype ~= -1 then
      cells[y][x].ctype = cells[fy][fx].ctype
      cells[y][x].is_hidden_player = true
      SetChunk(x, y, cells[fy][fx].ctype)
      --cells[y][x].ctype = cells[fy][fx].ctype
    else
      cells[y][x].ctype = ids.player
      cells[y][x].is_hidden_player = false
      SetChunk(x, y, ids.player)
    end
  end
end

local function fixPlayerHidedness()
  for y=1,height-1 do
    for x=1,width-1 do
      if cells[y][x].is_hidden_player and not cells[y][x].updated then
        cells[y][x].updated = true
        DoPlayer(x, y, cells[y][x].rot)
      end
    end
  end
end

local function DoMusicalCell(sound)
  local sounds = {
    texp .. "sounds/piano1.wav",
    texp .. "sounds/piano2.wav",
    texp .. "sounds/piano3.wav",
    texp .. "sounds/piano4.wav",
  }
  if audiocache[sounds[sound]] then
    if audiocache[sounds[sound]]:isPlaying() then
      audiocache[sounds[sound]]:stop()
    end
  end
  playSound(sounds[sound])
end

local function DoMatterBlob(x, y, dir)
  local fx, fy = GetFullForward(x, y, dir)

  if cells[fy][fx].ctype == 0 or cells[fy][fx].ctype == ids.matterBlob then
    local bx, by = GetFullForward(x, y, dir, -1)
    PushCell(bx, by, dir, true, 0)
  else
    cells[y][x] = (cells[y][x].matter_stored_cell or {ctype = 0, rot = 0, lastvars = {x, y, 0}})
    cells[y][x].lastvars = {
      x, y, cells[y][x].rot
    }
    SetChunk(x, y, cells[y][x].ctype)
  end
end

local function DoMatterConverter(x, y, dir)
  local bx, by = GetFullForward(x, y, dir, -1)

  if cells[by][bx].ctype ~= 0 then
    if PushCell(x, y, dir, true, 1, ids.matterBlob, dir) then
      local fx, fy = GetFullForward(x, y, dir)
      cells[fy][fx].matter_stored_cell = CopyTable(cells[by][bx])
      cells[by][bx] = {
        ctype = 0, rot = 0, lastvars = {x, y, 0}
      }
    end
  end
end

local lights = {}

local function DoNuclearBomb(x, y, range)
  local us = CopyTable(cells[y][x])
  cells[y][x].ctype = 0
  range = range or 200

  table.insert(lights, {
    lifetime = 10,
    lifespan = 10,
    x = x,
    y = y,
    radius = range*1.2
  })

  local enemiesToPop = {}

  for oy=-range, range, 1 do
    for ox=-range, range, 1 do
      local dist = math.sqrt(ox * ox + oy * oy)

      if dist <= range then
        local cx = x + ox
        local cy = y + oy
        if inGrid(cx, cy) then
          if dist <= range/5 then
            -- Instant death zone
            local bombID = cells[cy][cx].ctype
            cells[cy][cx] = {
              ctype = 0,
              rot = 0,
              lastvars = {cx, cy, 0}
            }
            if bombID == 23 then
              cells[cy][cx].ctype = 12
            elseif isModdedBomb(bombID) then
              table.insert(enemiesToPop, {bombID, cx, cy})
            elseif bombID == 50 then
              for dir=0,3 do
                local ocx, ocy = GetFullForward(cx, cy, dir)
                if inGrid(ocx, ocy) then
                  cells[ocy][ocx] = {
                    ctype = 0,
                    rot = 0,
                    lastvars = {ocx, ocy, 0}
                  }
                end
              end
            elseif isModdedTrash(bombID) then
              modsOnTrashEat(bombID, cx, cy, us, x, y)
            end
          elseif dist <= range/2 then
            -- Radioactivity zone
            if cells[cy][cx].ctype == 12 or cells[cy][cx].ctype == 23 or isModdedBomb(cells[cy][cx].ctype) then
              destroysound:play()
              enemyparticles:setPosition(cx * 20, cy * 20)
              enemyparticles:emit(50)
              if cells[cy][cx].ctype == 23 then
                cells[cy][cx].ctype = 12
                cells[cy][cx].radioactive = true
              else
                local bombID = cells[cy][cx].ctype
                cells[cy][cx].ctype = 0
                if bombID > initialCellCount then
                  table.insert(enemiesToPop, {bombID, cx, cy})
                end
              end
            elseif cells[cy][cx].ctype ~= 0 then
              cells[cy][cx].radioactive = true
            end
          elseif dist <= range then
            -- Radiation damage
            if cells[cy][cx].ctype ~= 0 then
              cells[cy][cx].radiation = (cells[cy][cx].radiation or 0) + 50
            end
          end
        end
      end
    end
  end

  for _, bomb in ipairs(enemiesToPop) do
    if bomb[1] > initialCellCount then
      modsOnModEnemyDed(bomb[1], bomb[2], bomb[3], us, x, y)
    end
  end
end

local function DoBlackhole(x, y)
  local range = 3
  for oy=-range, range do
    for ox=-range, range do
      if math.sqrt(ox * ox + oy * oy) <= range and not (ox == 0 and oy == 0) then
        local cx, cy = math.floor(x + ox), math.floor(y + oy)

        cells[cy][cx] = {
          ctype = 0,
          rot = 0,
          lastvars = {cx, cy, 0}
        }
      end
    end
  end
end

local function DoSuperImpulserSide(x, y, dir)
  local ox, oy, odir = x, y, dir

  local cx, cy = GetFullForward(x, y, dir)
  local px, py = ox, oy
  -- What are we impulsing?
  while true do
    if inGrid(cx, cy) and cells[cy][cx].ctype ~= 0 then
      break
    end
    if inGrid(cx, cy) then
      local w = walkDivergedPath(px, py, cx, cy)
      px = cx
      py = cy
    
      cx = w.x
      cy = w.y
      dir = w.dir
      cx, cy = GetFullForward(cx, cy, dir)
    else
      break
    end
  end

  -- Pulling time
  dir = (dir+2)%4
  local reps = 0
  while true do
    if reps == 999999 then break end
    if cx == ox and cy == oy then break end
    local fx, fy = GetFullForward(cx, cy, dir)

    PullCell(cx, cy, dir, false, 1)
    
    local w = walkDivergedPath(cx, cy, fx, fy)
    cx = w.x
    cy = w.y
    dir = w.dir
    reps = reps + 1
  end
end

local function DoSuperImpulser(x, y)
  for dir=0,3 do
    DoSuperImpulserSide(x, y, dir)
  end
end

local function DoFakeIntaker(x, y, dir)
  local fx, fy = GetFullForward(x, y, dir)
  if cells[fy][fx].ctype == 0 then return end
  cells[fy][fx].ctype = 0
  destroysound:play()
  local ffx, ffy = GetFullForward(fx, fy, dir)
  PullCell(ffx, ffy, (dir+2)%4, false, 1)
end

local function update(id, x, y, dir)
  -- Some for fun stuff for player :)

  if id == ids.monitor then
    cells[y][x].monitor_torender = nil
  elseif id == ids.musical then
    DoMusicalCell(dir+1)
  elseif id == ids.nuclearBomb then
    DoNuclearBomb(x, y)
  end

  -- Actual updates
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
  elseif id == ids.enemyMover then
    DoEnemyMover(x, y, dir)
  elseif id == ids.wire and isMechOn(x, y) then
    cells[y][x].testvar = cells[y][x].mech_signal
  elseif id == ids.gen4 then
    Do4Gen(x, y)
  elseif id == ids.rep4 then
    Do4Rep(x, y)
  elseif id == ids.slideopener then
    DoSlideOpener(x, y, dir)
  elseif id == ids.fan or id == ids.strongfan or id == ids.hyperfan then
    DoFan(x, y, dir)
  elseif id == ids.conveyor then
    DoConveyor(x, y, dir)
  elseif id == ids.magnet then
    DoMagnet(x, y, dir)
  elseif id == ids.player then
    DoPlayer(x, y, dir)
  elseif id == ids.seeker then
    DoSeeker(x, y, dir)
  elseif id == ids.matterBlob then
    DoMatterBlob(x, y, dir)
  elseif id == ids.matterConverter then
    DoMatterConverter(x, y, dir)
  elseif id == ids.blackhole then
    DoBlackhole(x, y)
  elseif id == ids.superimpulser then
    DoSuperImpulser(x, y)
  elseif id == ids.crossintaker then
    DoFakeIntaker(x, y, dir)
    DoFakeIntaker(x, y, (dir-1)%4)
  elseif id == ids.cross_supgen then
    DoSuperGenerator(x, y, dir)
    DoSuperGenerator(x, y, (dir-1)%4)
  end

  cells[y][x].prev_mech_signal = cells[y][x].mech_signal -- Useful for later ;)
  if isMechOn(x, y) then
    cells[y][x].mech_signal = cells[y][x].mech_signal - 1
  end
end

local function onCellDraw(id, x, y, rot)
  local rrot = LerpRotation((cells[y][x].lastvars or {x, y, rot})[3], rot)

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
      love.graphics.draw(wireActive.tex, spos.x, spos.y, rrot*half_pi, zoom/wireActive.size.w, zoom/wireActive.size.h, wireActive.size.w2, wireActive.size.h2)
    end
  elseif id == ids.crosswire then
    local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)
    local renderArm = function(r)
      love.graphics.draw(crossArm.tex, spos.x, spos.y, r*half_pi, zoom/crossArm.size.w, zoom/crossArm.size.h, crossArm.size.w2, crossArm.size.h2)
    end
    local renderPower1 = function(r)
      r = LerpRotation(cells[y][x].lastvars[3], r)
      love.graphics.draw(crossPower1.tex, spos.x, spos.y, r*half_pi, zoom/crossPower1.size.w, zoom/crossPower1.size.h, crossPower1.size.w2, crossPower1.size.h2)
    end

    local renderPower2 = function(r)
      r = LerpRotation(cells[y][x].lastvars[3], r)
      love.graphics.draw(crossPower2.tex, spos.x, spos.y, r*half_pi, zoom/crossPower2.size.w, zoom/crossPower2.size.h, crossPower2.size.w2, crossPower2.size.h2)
    end

    for dir=0, 3 do
      dir = (cells[y][x].rot + dir) % 4
      local ox, oy = GetFullForward(x, y, dir)
      if isConnectable(cells[oy][ox], dir) then
        renderArm(dir)
      end

      if isMechOn(ox, oy) then
        if rot % 2 == dir % 2 then
          renderPower2(rot)
        else
          renderPower1(rot)
        end
      end
    end

    -- if isMechOn(x, y) then
    --   love.graphics.draw(wireActive.tex, spos.x, spos.y, rrot*half_pi, zoom/wireActive.size.w, zoom/wireActive.size.h, wireActive.size.w2, wireActive.size.h2)
    -- end
  elseif id == ids.piston and isMechOn(x, y) then
    local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)

    love.graphics.draw(pistonOn.tex, spos.x, spos.y, rrot*half_pi, zoom/pistonOn.size.w, zoom/pistonOn.size.h, pistonOn.size.w2, pistonOn.size.h2)
  elseif id == ids.stickyPiston and isMechOn(x, y) then
    local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)

    love.graphics.draw(stickyPistonOn.tex, spos.x, spos.y, rrot*half_pi, zoom/stickyPistonOn.size.w, zoom/stickyPistonOn.size.h, stickyPistonOn.size.w2, stickyPistonOn.size.h2)
  elseif id == ids.monitor then
    local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)
    local srot = LerpRotation(cells[y][x].lastvars[3], rot)

    if cells[y][x].monitor_torender ~= nil then
      local mid = cells[y][x].monitor_torender
      love.graphics.draw(tex[mid], spos.x, spos.y, srot * math.pi/2, zoom/texsize[mid].w/3, zoom/texsize[mid].h/3, texsize[mid].w2, texsize[mid].h)
    end
  end
end

local function tick()
  playerPosCache = nil
  for y=1,height-1 do
    for x=1,width-1 do
      if cells[y][x].radioactive then
        for oy=-3,3 do
          for ox=-3,3 do
            if math.sqrt(ox * ox + oy * oy) <= 3 then
              local cx, cy = x + ox, y + oy
              if inGrid(cx, cy) then
                cells[cy][cx].radiation = (cells[cy][cx].radiation or 0) + 1
              end
            end
          end
        end
        cells[y][x].radiation = (cells[y][x].radiation or 0) + 0.1
      end
      if (cells[y][x].radiation or 0) > 75 then
        cells[y][x] = {
          ctype = 0, rot = 0, lastvars = {x, y, 0}
        }
      end
      if cells[y][x].radioactive and cells[y][x].ctype == 0 then
        cells[y][x].radioactive = false
      end
      if cells[y][x].player_hidden_type then
        cells[y][x].ctype = cells[y][x].player_hidden_type
        cells[y][x].player_hidden_type = nil
      end
      if cells[y][x].sticky_moved then
        cells[y][x].sticky_moved = false
      -- elseif cells[y][x].is_hidden_player then
      --   cells[y][x].ctype = ids.player
      --   SetChunk(x, y, ids.player)
      elseif cells[y][x].ctype == 0 then
        cells[y][x].mech_signal = 0
        cells[y][x].is_hidden_player = false
      end
    end
  end

  -- repeat
  --   local q = stickyQueue[1]
  --   if type(q) == "table" then
  --     PushCell(q[1], q[2], q[3], true, 1)
  --     table.remove(stickyQueue, 1)
  --   end
  -- until #stickyQueue == 0
end

local function onPlace(id, x, y, rot, original, originalInitial)
  cells[y][x].mech_signal = 0
  cells[y][x].is_hidden_player = false

  if original.ctype == ids.monitor and id ~= ids.monitor and id ~= 0 then
    cells[y][x] = original
    initial[y][x] = originalInitial

    cells[y][x].monitor_torender = id
  elseif original.ctype == ids.musical and id ~= ids.musical and id ~= 0 then
    cells[y][x] = original
    initial[y][x] = originalInitial
    if id ~= original.musical_last_played then
      cells[y][x].musical_last_played = id
      DoMusicalCell((currentrot + cells[y][x].rot) % 4 + 1)
    end
  elseif id == ids.player and econfig['player_lock'] == true then
    for cy=1,height-1 do
      for cx=1,width-1 do
        if (cells[cy][cx].ctype == ids.player or cells[cy][cx].is_hidden_player) and (cx ~= x or cy ~= y) then
          cells[y][x] = original
          initial[y][x] = originalInitial
          return
        end
      end
    end
  end
end

local gridRotation = 0

local function properlyChangeZoom(oldzoom, newzoom)
  local w2 = 400 * winxm
  local h2 = 300 * winym

  offx = offx + w2
  offy = offy + h2

  local scale = (newzoom / oldzoom)

  offx = offx * scale
  offy = offy * scale

  offx = offx - w2
  offy = offy - h2
end

local function onGridRender()
  for x=1,width-1 do
    for y=1,height-1 do
      local id = cells[y][x].ctype
      if id == ids.blackhole then
        local spos = calculateScreenPosition(x, y)

        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.circle("fill", spos.x, spos.y, 3.3 * zoom)
        love.graphics.setColor(r, g, b, a)
      end
    end
  end
  if not (paused) then
    for x=1,width-1 do
      for y=1,height-1 do
        local id = cells[y][x].ctype
        if cells[y][x].radioactive then
          local r, g, b, a = love.graphics.getColor()
          love.graphics.setColor(0, 0.2, 0, 0.3)
          local spos = calculateScreenPosition(x, y)
          love.graphics.circle("fill", spos.x, spos.y, zoom*3)
          love.graphics.setColor(r, g, b, a)
        end
        if cells[y][x].ctype == ids.lightBulb or id == ids.brightLightBulb or id == ids.brighterLightBulb or id == ids.brightestLightBulb then
          DoLightbulb(x, y)
        elseif (id == ids.player or (cells[y][x].is_hidden_player and cells[y][x].ctype ~= 0)) and not inmenu then
          if econfig['player_lock'] == true then
            local fov = econfig['player_zoom'] or 100
            local spos = calculateScreenPosition(x, y, cells[y][x].lastvars)
        
            local center = {
              x = love.graphics.getWidth() * 0.5,
              y = love.graphics.getHeight() * 0.5,
            }
        
            -- Translate
            spos.x = spos.x - center.x
            spos.y = spos.y - center.y
        
            -- Smooth
            local i = 0.15
            spos.x = spos.x * i
            spos.y = spos.y * i
            fov = (fov - zoom) * i + zoom

            offx = lerp(offx, offx + spos.x, itime/delay)
            offy = lerp(offy, offy + spos.y, itime/delay)
            local oldzoom = zoom
            zoom = lerp(zoom, fov, itime/delay)
            properlyChangeZoom(oldzoom, zoom)
          end
        end
      end
    end
  end
  local lightsRemoval = {}
  for index, light in ipairs(lights) do
    if light.lifetime <= 0 then
      table.insert(lightsRemoval, index)
    end
    local r, g, b, a = love.graphics.getColor()
    
    local radius = light.radius * (light.lifetime / light.lifespan)
    local spos = calculateScreenPosition(light.x, light.y)
    love.graphics.setColor(1, 1, 1, 0.05)
    for rad=1,radius, 0.2 do
      local vrad = zoom * rad
      if spos.x > -vrad or spos.y > -vrad or spos.x < love.graphics.getWidth()-vrad or spos.y < love.graphics.getHeight()-vrad then
        love.graphics.circle("fill", spos.x, spos.y, zoom * rad)
      end
    end

    love.graphics.setColor(r, g, b, a)
  end
  for _, i in ipairs(lightsRemoval) do
    table.remove(lights, i)
  end
end

-- local function playStreamSound(sound)
--   if not audiocache[sound] then
--     audiocache[sound] = love.audio.newSource(sound, "stream")
--   end
--   love.audio.play(audiocache[sound])
-- end

local function DoDeathGen(x, y)
  local range = 50

  for ox = -range, range do
    for oy = -range, range do
      local dist2 = (ox * ox + oy * oy)
      if dist2 < (range * range) then -- Fast distance calculation boiii
        if inGrid(x+ox, y+oy) and cells[y+oy][x+ox].ctype == ids.deathSensor then
          SignalMechanical(x+ox, y+oy, nil, true)
        end
      end
    end
  end
end

local function onTrashEats(id, x, y, food, fx, fy)
  DoDeathGen(x, y)

  if id == ids.forward_right_forker then
    PushCell(x, y, cells[y][x].rot, true, 1, food.ctype, food.rot)
    PushCell(x, y, (cells[y][x].rot-1)%4, true, 1, food.ctype, (food.rot-1)%4)
  elseif id == ids.forward_left_forker then
    PushCell(x, y, cells[y][x].rot, true, 1, food.ctype, food.rot)
    PushCell(x, y, (cells[y][x].rot+1)%4, true, 1, food.ctype, (food.rot+1)%4)
  elseif id == ids.musical then
    local cdir
    if fx > x then cdir = 0 elseif fx < x then cdir = 2 end
    if fy > y then cdir = 1 elseif fy < y then cdir = 3 end

    local dir = (cells[y][x].rot - cdir) % 4

    DoMusicalCell(dir+1)
  elseif id == ids.portal_a or id == ids.portal_b then
    DoPortal(id, x, y, food, fx, fy)
  end
end

local function onEnemyDies(id, x, y, killer, kx, ky)
  DoDeathGen(x, y)
  if id == ids.nuclearBomb then
    DoNuclearBomb(x, y)
  elseif id == ids.strongerenemy then
    cells[y][x].ctype = 23
  end
end

-- local function onMove(id, x, y, rot)
--   if id == ids.movementSensor and not cells[y][x].updated then
--     cells[y][x].updated = true
--     SignalMechanical(x, y, rot, true)
--   end
-- end

local playTime = 0
local loadedPlayerFix = false

local function customupdate(dt)
  if not (paused or inmenu) then
    for _, light in ipairs(lights) do
      light.lifetime = light.lifetime - (dt / (math.max(delay, 1 / light.lifespan))) * tpu
    end
  end
  if not loadedPlayerFix then
    loadedPlayerFix = true
    table.insert(subticks, 1, fixPlayerHidedness)
  end
end

local function onKeyPressed(key, code, continous)
  -- Do rotation for player
  if not continous then
    if not (inmenu or paused) then
      if key == 'left' then
        for y=1,height-1 do
          for x=1,width-1 do
            if cells[y][x].ctype == ids.player or cells[y][x].is_hidden_player then
              rotateCell(x, y, -1)
            end
          end
        end
      elseif key == 'right' then
        for y=1,height-1 do
          for x=1,width-1 do
            if cells[y][x].ctype == ids.player or cells[y][x].is_hidden_player then
              rotateCell(x, y, 1)
            end
          end
        end
      elseif key == 'up' or key == 'down' then
        local px, py = getPlayerPos()
        if type(px) == "number" and type(py) == "number" then
          zoom = econfig['player_zoom'] or 100
          if key == 'up' then
            offx = (offx-400*winxm)*0.5
            offy = (offy-300*winym)*0.5
          elseif key == 'down' then
            offx = offx*2 + 400*winxm
            offy = offy*2 + 300*winym
          end
        end
      end
    end
  end
end

local function onCellGenerated(id, x, y)
  if cells[y][x].is_hidden_player then
    cells[y][x].is_hidden_player = false
  end
end

local function onMouseReleased()
  for cy=1, height-1 do
    for cx=1, width-1 do
      cells[cy][cx].musical_last_played = nil
    end
  end
end

-- local function onMouseScroll(x, y)
--   if y < 0 then
-- 		for i=1,y do
-- 			if zoom < 160 then
-- 				zoom = zoom*2
-- 				offx = offx*2 + 400*winxm
-- 				offy = offy*2 + 300*winym
-- 			end
-- 		end
-- 	elseif y > 0 then
-- 		for i=-1,y,-1 do
-- 			if zoom > 2 then
-- 				offx = (offx-400*winxm)*0.5
-- 				offy = (offy-300*winym)*0.5
-- 				zoom = zoom*0.5
-- 			end
-- 		end
-- 	end
-- end

return {
  init = init,
  update = update,
  tick = tick,
  onCellDraw = onCellDraw,
  onPlace = onPlace,
  onTrashEats = onTrashEats,
  onEnemyDies = onEnemyDies,
  onMove = onMove,
  onKeyPressed = onKeyPressed,
  onGridRender = onGridRender,
  customupdate = customupdate,
  onCellGenerated = onCellGenerated,
  onMouseReleased = onMouseReleased,
  onMouseScroll = onMouseScroll,
}
