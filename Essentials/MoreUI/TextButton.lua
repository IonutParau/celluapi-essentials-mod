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

--- @param text table A text element to use
--- @param clickCallback function
--- @return table
local function TextButton(text, clickCallback)
  local tb = CopyTable(text)

  tb.click = buttonCheckClick(clickCallback)

  return tb
end

return TextButton