local function renderText(self)
  local font = love.graphics.getFont()
  love.graphics.printf(self.text, font, self.x * winxm, self.y * winym, self.limit or (1/0), self.align, self.r or 0, (self.sx or 1) * winxm, (self.sy or 1) * winym)
end

--- @param text any
--- @param x number
--- @param y number
--- @param limit number|nil
--- @param align number|nil
--- @param rot number|nil
--- @param sx number|nil
--- @param sy number|nil
--- @return table
local function Text(text, x, y, limit, align, rot, sx, sy)
  local t = MoreUI.Base(x, y, 0, 0, rot, renderText)

  t.text = text
  t.limit = limit
  t.align = align
  t.sx = sx
  t.sy = sy
  local font = love.graphics.getFont()
  t.w = math.min(font:getWidth(text) * (sx or 1), ((limit or (1/0)) * (sx or 1)))
  if type(limit) == "number" then
    t.h = round(font:getWidth(text) / limit) * (font:getHeight() * (sy or 1))
  else
    t.h = font:getHeight() * (sy or 1)
  end

  return t
end

return Text