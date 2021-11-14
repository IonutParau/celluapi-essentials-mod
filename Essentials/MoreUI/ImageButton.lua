--- @param image love.Image
local function ButtonRender(image)
  return function(self)
    local sx = self.w / image:getWidth()
    local sy = self.h / image:getHeight()

    love.graphics.draw(image, self.x * winxm, self.y * winym, self.r, sx * winxm, sy * winym)
  end
end

local function buttonCheckClick(callback)
  return function(self)
    local mx = love.mouse.getX() / winxm
    local my = love.mouse.getY() / winym

    if mx >= self.x and mx <= self.x + self.w and my >= self.y and my <= self.y + self.h then
      placecells = false
      callback()
    end
  end
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param texture string
--- @param clickCallback function
--- @return table
local function ImageButton(x, y, w, h, texture, clickCallback)
  if type(x) ~= "number" or type(y) ~= "number" or type(w) ~= "number" or type(h) ~= "number" or type(clickCallback) ~= "function" then
    error("Incorrect argument types")
  end

  local image = love.graphics.newImage(texture)

  return MoreUI.Base(x, y, w, h, 0, ButtonRender(image), buttonCheckClick(clickCallback))
end

return ImageButton