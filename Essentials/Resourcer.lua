local json = require("libs.json")

Resourcer = {}

local overlays = {}
local overlaySize = {}

local settings = {}

local mouse

local animations = {}
local animCounter = 0

local originalTex = {}
local originalSize = {}

local originalOverlays = {}
local originalOverlaySize = {}

--- @class Resourcer.Animation
--- @field imgs table
--- @field current number
--- @field interval number
local function Animation()
  return {
    imgs = {},
    current = 1,
    interval = 0,
    type = "override",
  }
end

--- @class Resourcer.Texture
--- @field image love.Image
--- @field size table
local function Texture()
  return {
    image = {},
    size = {},
  }
end

function Resourcer.Settings(newSettings)
  if type(newSettings) == "table" then
    for k, v in pairs(newSettings) do
      settings[k] = v
    end
  end
end

function Resourcer.FromSmartIdentifier(id)
  local canRun = true

  if string.sub(id, -#"-running") == "-running" then
    id = string.sub(id, 1, #id-#"-running")
    canRun = not (paused or inmenu)
  end

  return canRun, Resourcer.FromIdentifier(id)
end

function Resourcer.FromIdentifier(id)
  local num = tonumber(id)
  if type(num) == "number" then return num end

  return getCellIDByLabel(id) or id
end

function Resourcer.GetIdentifier(id)
  if id == "*" then return id end
  if type(id) == "string" then return id end
  if id > initialCellCount then
    return getCellLabelById(id)
  else
    return tostring(id)
  end
end

local function loadResource(path)
  path = path or "Essentials/Resources"
  local code = json.decode(love.filesystem.read(path), 0, 'null')

  local vars = code["vars"] or {}

  local varParse = function(v)
    for var, val in pairs(vars) do
      if string.find(v, "$" .. var, nil, true) then
        return string.gsub(v, "$" .. var, val)
      end
    end
    return v
  end

  if code["images"] then
    if code["images"]["overrides"] then
      for key, image in pairs(code["images"]["overrides"]) do
        key = varParse(key)
        image = varParse(image)
        local img = love.graphics.newImage(image)
        key = Resourcer.FromIdentifier(key)
        tex[key] = img
        texsize[key] = {
          w = img:getWidth(),
          h = img:getHeight(),
          w2 = img:getWidth()/2,
          h2 = img:getHeight()/2,
        }
      end
    end
    if code["images"]["overlays"] then
      for key, image in pairs(code["images"]["overlays"]) do
        key = varParse(key)
        image = varParse(image)
        local img = love.graphics.newImage(image)
        overlays[key] = img
        overlaySize[key] = {
          w = img:getWidth(),
          h = img:getHeight(),
          w2 = img:getWidth()/2,
          h2 = img:getHeight()/2,
        }
      end
    end
    if code["images"]["animations"] then
      for key, image in pairs(code["images"]["animations"]) do
        key = varParse(key)
        local interval = image["interval"]
        local textures = {}
        for _, img in ipairs(image["textures"]) do
          img = varParse(img)
          local t = love.graphics.newImage(img)
          local s = {
            w = t:getWidth(),
            h = t:getHeight(),
            w2 = t:getWidth()/2,
            h2 = t:getHeight()/2,
          }
          local texture = Texture()
          texture.image = t
          texture.size = s
          table.insert(textures, texture)
        end
        local anim = Animation()
        anim.interval = interval
        anim.imgs = textures
        anim.type = image["type"] or "override"
        animations[Resourcer.FromIdentifier(key)] = anim
      end
    end
  end
  if code["mouse"] then
    local img = love.graphics.newImage(code["mouse"])
    mouse = {
      img = img,
      w = img:getWidth(),
      h = img:getHeight(),
      w2 = img:getWidth()/2,
      h2 = img:getHeight()/2,
    }
    love.mouse.setVisible(false)
  end
  if code["sounds"] then
    for key, sound in pairs(code["sounds"]) do
      local s = love.audio.newSource(sound)
      if key == "game" then
        music:stop()
        music = s
        music:setLooping(true)
        love.audio.play(music)
      elseif key == "destroy" then
        destroysound = s
      elseif key == "beep" then
        beep = s
      else
        audiocache[key] = s
      end
    end
  end
end

---@param image string Path of the file containing the image
---@return Resourcer.Texture
function Resourcer.createTexture(image)
  local t = love.graphics.newImage(image)
  local s = {
    w = t:getWidth(),
    h = t:getHeight(),
    w2 = t:getWidth()/2,
    h2 = t:getHeight()/2,
  }
  local texture = Texture()
  texture.image = t
  texture.size = s
  return texture
end

---@param id number|string The id or label of the cell to animate
---@param textures table The table of frames (aka textures) to animate with
---@param interval number How long (in ticks) does the frame in the animation last
---@param type "\"override\""|"\"overlay\"" Optional - The type of animation.
---@return Resourcer.Animation
function Resourcer.createAnimation(id, textures, interval, type)
  local anim = Animation()
  anim.interval = interval
  anim.imgs = textures
  anim.type = type or "override"
  animations[Resourcer.FromIdentifier(id)] = anim

  return anim
end

function Resourcer.RenderMouse()
  if mouse == nil then return end

  local x = love.mouse.getX()
  local y = love.mouse.getY()
  x = x - mouse.w2
  y = y - mouse.h2

  love.graphics.draw(mouse.img, x, y)
end

function Resourcer.LoadResources(path)
  originalTex = CopyTable(tex)
  originalSize = CopyTable(texsize)
  local resources = love.filesystem.getDirectoryItems(path)

  for _, name in ipairs(resources) do
    local fileSplit = split(name, '.')
		if fileSplit[#fileSplit] == 'json' then
			loadResource(path .. '/' .. name)
		end
  end

  originalOverlays = CopyTable(overlays)
  originalOverlaySize = CopyTable(overlaySize)
end

function Resourcer.UpdateAnimations()
  animCounter = animCounter + 1
  for rawid, animation in pairs(animations) do
    local canRun, id = Resourcer.FromSmartIdentifier(rawid)
    if canRun then
      local texture = animation.imgs[animation.current]
      if animation.type == "overlay" then
        id = tostring(id)
        overlays[id] = texture.image
        overlaySize[id] = texture.size
      else
        tex[id] = texture.image
        texsize[id] = texture.size
      end

      if animCounter % (animation.interval) == 0 then
        animation.current = animation.current + 1
        if animation.current > #(animation.imgs) then
          animation.current = 1
        end
      end
    else
      if animation.type == "overlay" then
        id = tostring(id)
        overlays[id] = originalOverlays[id]
        overlaySize[id] = originalOverlaySize[id]
      else
        tex[id] = originalTex[id]
        texsize[id] = originalSize[id]
      end
    end
  end
end

function Resourcer.RenderOverlay(id, x, y, rot)
  local lastvars = {}
  local orot = rot
  if type(rot) ~= "number" then
    rot = cells[y][x].rot
    lastvars = cells[y][x].lastvars
  else
    lastvars = {x, y, rot}
  end
  id = Resourcer.GetIdentifier(id)
  if overlays[id] then
    love.graphics.draw((overlays[id]),math.floor(lerp(lastvars[1],x,itime/delay)*zoom-offx+zoom/2),math.floor(lerp(lastvars[2],y,itime/delay)*zoom-offy+zoom/2),lerp(lastvars[3],lastvars[3]+((rot-lastvars[3]+2)%4-2),itime/delay)*math.pi/2,zoom/(overlaySize[id]).w,zoom/(overlaySize[id]).h,(overlaySize[id]).w2,(overlaySize[id]).h2)
  elseif overlays[id .. "-running"] and (not (paused or inmenu)) then
    Resourcer.RenderOverlay(id .. "-running", x, y, orot)
  elseif id ~= "*" then
    Resourcer.RenderOverlay("*", x, y, orot)
  end
end

function Resourcer.RenderListOverlays()
  for i=0,15 do
		if type(listorder[i+16*(page-1)+1]) == "number" then
			if currentstate == listorder[i+16*(page-1)+1] or settings['trans_overlay'] == false then love.graphics.setColor(1,1,1,1) else love.graphics.setColor(1,1,1,0.5) end
			local e = Resourcer.GetIdentifier(listorder[i+16*(page-1)+1])
      if not overlays[e] and not overlaySize[e] then
        e = "*"
      end
      if overlays[e] and overlaySize[e] then
        love.graphics.draw(overlays[tostring(e)],(25+(775-25)*i/15)*winxm,575*winym,currentrot*math.pi/2,40*winxm/overlaySize[tostring(e)].w,40*winxm/overlaySize[tostring(e)].h,overlaySize[tostring(e)].w2,overlaySize[tostring(e)].h2)
      end
    end
	end
  love.graphics.setColor(1, 1, 1, 1)
end

function Resourcer.RenderMiniGridOverlay(grid, sx, sy)
  sx = sx or math.floor((love.mouse.getX()+offx)/zoom)
  sy = sy or math.floor((love.mouse.getY()+offy)/zoom)
  for y=0,#grid do
    for x=0,#(grid[0]) do
      Resourcer.RenderOverlay(grid[y][x].ctype, sx+x, sy+y, grid[y][x].rot)
    end
  end
end