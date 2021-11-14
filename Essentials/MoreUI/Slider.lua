local function slideRender(self)
  local size = self.slideSize
  local init = self.initialValue
  local val = self.value
  local max = self.maxValue

  local lineColor = self.lineColor
  local slideColor = self.slideColor
  local thicc = self.lineThickness

  local x, y, w, h = self.x, self.y, self.w, self.h

  local off = (h/2 - thicc/2)
  local coff = h/2

  local lx = x * winxm
  local ly = (y + off) * winxm
  local lw = w * winxm
  local lh = thicc * winym

  if self.vertical then
    lx = (x + off) * winxm
    ly = y * winym
    lw = thicc * winxm
    lh = w * winym
  end

  lineColor:apply()
  love.graphics.rectangle("fill", lx, ly, lw, lh)

  local p = ((val - init) / (max - init))
  slideColor:apply()

  local cx = x * winxm + (w * p) * winxm
  local cy = y + coff * winym

  if self.vertical then
    cx = x + coff * winxm
    cy = y * winym + (w * p) * winym
  end

  love.graphics.circle("fill", cx, cy, size * winxm)

  -- MoreUI.Color(0,0, 0.2):apply()
  -- love.graphics.rectangle("line", x * winxm, y * winym, w * winxm, h * winym)

  love.graphics.setColor(1, 1, 1, 1)
end

local function slideClick(self)
  local x = love.mouse.getX() / winxm
  local y = love.mouse.getY() / winym
  
  -- Exit case
  if (x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h and not self.vertical) or (self.vertical and x >= self.x and x <= self.x + self.h and y >= self.y and y <= self.y + self.w) then
    placecells = false
    if self.vertical then
      local d = y - self.y
      local p = (d / self.w)
      local v = self.initialValue + ((self.maxValue - self.initialValue) * p)

      self.value = v
    else
      local d = x - self.x
      local p = (d / self.w)
      local v = self.initialValue + ((self.maxValue - self.initialValue) * p)

      self.value = v
    end
  end
end

local function slideUpdate(self)
  if love.mouse.isDown(1) then
    self:click()
  end
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param slideSize number
---@param initial number
---@param max number
---@param lineColor MoreUI.ColorData Optional
---@param slideColor MoreUI.ColorData Optional
---@param lineThickness number Optional
---@param mode "\"circle\""|"\"rectangle\""
---@param vertical boolean
---@return table
local function Slider(x, y, width, height, slideSize, initial, max, lineColor, slideColor, lineThickness, mode, vertical)
  local s = MoreUI.Base(x, y, width, height, 0, slideRender, slideClick, slideUpdate)
  -- Custom data
  s.slideSize = slideSize or (height)
  s.initialValue = initial
  s.value = initial
  s.maxValue = max
  s.lineColor = lineColor or MoreUI.Color(0, 0, 0)
  s.slideColor = slideColor or MoreUI.Color(1, 1, 1)
  s.lineThickness = lineThickness or (height)
  s.mode = mode
  s.vertical = vertical

  return s
end

return Slider