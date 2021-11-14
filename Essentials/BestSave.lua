-- BestSave gets the best save

local function findBest()
  encodeAP2()
  local code = love.system.getClipboardText()
  local bestLength = #(love.system.getClipboardText())
  for sig, encode in pairs(modsEncoding) do
    if sig ~= "BestSave" then
      encode()
      local text = love.system.getClipboardText()
      if #text < bestLength then
        code = text
      end
    end
  end
  love.system.setClipboardText(code)
end

CreateFormat("BestSave", findBest, function() end)