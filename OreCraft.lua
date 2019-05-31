local comp = require("component")
local gpu = comp.gpu
local screen = comp.screen
local term = require("term")
local sides = require("sides")
local os = require("os")
local event = require("event")
local run = true




-- UI Functions
--------------------------------------------------------------------------------
local UI = {}

local col = {r = 0xFF0000, g = 0x00FF00, b = 0x0000FF, y = 0xFFFF00} 

function UI:init()
    term.clear()
    screen.setTouchModeInverted(true)

    gpu.setResolution(32,25)
    gpu.setBackground(0xC3C3E1)
    gpu.setForeground(0x000000)
    gpu.fill(1,2,32,14," ")
    
    gpu.setBackground(0xC3C3C3)
    gpu.set(1,1,"            LVLCRAFT           ")
    
    gpu.setBackground(0xFF0000) -- render close button
    gpu.setForeground(0x00FF00)
    gpu.set(32,1,"X")

    
    gpu.setBackground(0x101010)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1,2,32,24," ")

end

function UI:itemBar(item,sx)
    local sx = sx
    local b1, b2 = {},{} 
  
    for i=1, 20  do
        b1[i] = " "
        b2[i] = " "
    end
  
    local amountstr = item:getAmount().."/"..item:getLimit()
    local namestr = item:getName()
    
    for i=1, string.len(namestr) do
        b1[10-math.floor(string.len(namestr)/2)+i] = string.sub(namestr,i,i)
    end
  
    for i=1, string.len(amountstr) do
        b2[10-math.floor(string.len(amountstr)/2)+i] = string.sub(amountstr,i,i)
    end
    
    local perc = item:getAmount()/item:getLimit()
    if perc >= 1 then
        gpu.setBackground(col.g)
    elseif perc < 1 and perc > 0.2 then
        gpu.setBackground(col.y)
    else 
        gpu.setBackground(col.r)
    end  
    perc = math.floor(perc*20)
    if perc == 0 and item:getAmount() ~= 0 then
        perc = 1
    end
  
    gpu.setForeground(col.b)
    for i=1, 20 do 
        if i > perc then
        gpu.setBackground(0x000000)
        end
        gpu.set(i+1,sx+1,b1[i])
        gpu.set(i+1,sx+2,b2[i])
    end
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
  
  
end


function UI:clear()
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.setResolution(gpu.maxResolution())
    screen.setTouchModeInverted(false)
    term.clear()
end

function UI:refresh()
    for k,v in pairs(ItemList) do
        if ItemList[k]:isChanged() then
            UI:itemBar(ItemList[k],k*3-1)
            --ItemList[k]:isDrawn()
        end
      end

end
--------------------------------------------------------------------------------

-- Button Functions
--------------------------------------------------------------------------------
local button = {}

local ButtonList = {}


function button:new(name, type, xPos,yPos,xSize,ySize)
    local o = {
        name = name or "noname",
        type = type,
        xPos = xPos,
        yPos = yPos,
        xSize = xSize or 1,
        ySize = ySize or 1
    }
    setmetatable(o, {__index = button}
    )
end

local btnClose = button:new("Close", 0, 32,1)
-------------------------------------------------------------------------------

-- Touchscreen Functions
--------------------------------------------------------------------------------
local touch = {}

function touch:handle(ename,eadr,ex,ey,ebtn,epname)
    

end

function touch:init()
    event.listen("touch", touch:handle())
end
--------------------------------------------------------------------------------

-- Item backbone
--------------------------------------------------------------------------------

local Item = {}
local Ingot = {}
local Ore = {}

function Item:new(name, type, amount,limit, item )
    local o = {
        name = name,
        type = type or 1,
        amount = amount,
        limit = limit,
        changed = true,
        precursor = item or nil

    }
    setmetatable(o, {__index = Item})
    return o
    
end

function Item:getName()
    return self.name
end

function Item:getAmount()
    return self.amount
end

function Item:getLimit()
    return self.limit
end

function Item:setAmount(amount)
    self.amount = amount
    self.changed = true
end

function Item:setLimit(limit)
    self.limit = limit
    self.changed = true
end

function Item:isChanged()
    return self.changed
end

function Item:isDrawn()
    self.changed = false
end
--------------------------------------------------------------------------------

--Main Program
--------------------------------------------------------------------------------

ItemList = {}

ironOre = Item:new("Iron Ore",0, 12)
copperOre = Item:new("Copper Ore",0, 25)
tinOre = Item:new("Tin Ore", 0, 151)


ironIngot = Item:new("Iron Ingot", 1, 10, 128, ironOre)
copperIngot = Item:new("Copper Ingot", 1, 54, 128, copperOre)
tinIngot = Item:new("Tin Ingot", 1, 26, 128, tinOre)


--sand = Item:new("Sand", 10, 16)
--cobble = Item:new("Cobblestone", 123, 256)
--obsidian = Item:new("Obsidian", 34,128)



--table.insert(ItemList, sand)
--table.insert(ItemList, cobble)
--table.insert(ItemList, obsidian)

table.insert(ItemList, ironIngot)
table.insert(ItemList, copperIngot)
table.insert(ItemList, tinIngot)




UI:init()





UI:refresh()
p = term.read()

UI:clear()