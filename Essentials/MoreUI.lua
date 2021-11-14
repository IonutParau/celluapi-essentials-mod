MoreUI = {}

---@class MoreUI.ColorData
---@field r number
---@field g number
---@field b number
---@field a number
---@field apply function
local function color()
  return {
    r = 0,
    g = 0,
    b = 0,
    a = 0,
    apply = function(self)
      love.graphics.setColor(self.r, self.g, self.b, self.a)
    end,
  }
end

---@param r number
---@param g number
---@param b number
---@param a number
---@return MoreUI.ColorData
local function makeColor(r, g, b, a)
  local c = color()

  c.r = r or 0
  c.g = g or 0
  c.b = b or 0
  c.a = a or 1
  
  return c
end

MoreUI.Color = makeColor

local function renderBounds(self)
  local r, g, b, a = love.graphics.getColor()

  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle("line", self.x * winxm, self.y * winym, self.w * winxm, self.h * winym)

  love.graphics.setColor(r, g, b, a)
end

MoreUI.Base = function(x, y, w, h, r, render, click, update)
  return {
    x = x or 0,
    y = y or 0,
    w = w or 0,
    h = h or 0,
    r = r or 0,
    render = render or function() end,
    click = click or function() end,
    update = update or function() end,
    bounds = renderBounds,
  }
end

-- Components

MoreUI.ImageButton = require("Essentials.MoreUI.ImageButton")
MoreUI.Text = require("Essentials.MoreUI.Text")
MoreUI.Slider = require("Essentials.MoreUI.Slider")
MoreUI.TextButton = require("Essentials.MoreUI.TextButton")

-- Menu system

--- @param element table
local function AddElement(self, element)
  table.insert(self.ui, element)
end

--- @param element table
--- @param index number
local function InsertElement(self, element, index)
  table.insert(self.ui, index, element)
end

local function menuClick(self)
  for _, element in ipairs(self.ui) do
    element:click()
  end
end

local function menuRender(self)
  for _, element in ipairs(self.ui) do
    element:render()
  end
end

--- @class Menu
--- @field title string
--- @field ui table
--- @field x number
--- @field y number
--- @field w number
--- @field h number
--- @field click function
--- @field render function
local function Menu()
  return {
    title = "",
    ui = {},
    x = 0,
    y = 0,
    w = 0,
    h = 0,
    z = 0, -- To store the depth totally useful
    AddElement = AddElement,
    AddItem = AddElement,
    InsertElement = InsertElement,
    click = menuClick,
    render = function(self) end,
  }
end

--- @param title string
--- @param offx number
--- @param offy number
--- @param width number
--- @param height number
--- @param render function
--- @param startingElements table Optional
--- @return Menu
function MoreUI.createMenu(title, offx, offy, width, height, render, startingElements)
  local m = Menu()
  m.title = title
  m.x = offx
  m.y = offy
  m.w = width
  m.h = height
  m.render = function(self)
    render(self)
    menuRender(self)
  end
  m.ui = startingElements or {}
  return m
end

