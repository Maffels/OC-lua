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
    
    gpu.setBackground(0xFF0000)
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
  
    local amountstr = item.amount.."/"..item.limit
    
    for i=1, string.len(item.name) do
        b1[10-math.floor(string.len(item.name)/2)+i] = string.sub(item.name,i,i)
    end
  
    for i=1, string.len(amountstr) do
        b2[10-math.floor(string.len(amountstr)/2)+i] = string.sub(amountstr,i,i)
    end
    
    local perc = item.amount/item.limit
    if perc >= 1 then
        gpu.setBackground(col.g)
    elseif perc < 1 and perc > 0.2 then
        gpu.setBackground(col.y)
    else 
        gpu.setBackground(col.r)
    end  
    perc = math.floor(perc*20)
    if perc == 0 and item.amount ~= 0 then
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
        if ItemList[k].changed then
            UI:itemBar(ItemList[k],k*3-1)
            ItemList[k]:isDrawn()
        end
      end

end
--------------------------------------------------------------------------------

-- Button Functions
--------------------------------------------------------------------------------
local button = {}

function button:new(name, type, xPos,yPos,xSize,ySize)
    setmetatable({},self)
    self.__index = self
    self.name = name or "noname"
    self.type = type
    self.xPos = xPos
    self.yPos = yPos
    self.xSize = xSize or 1
    self.ySize = ySize or 1

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
Item.__index = Item

setmetatable(Item, { 
    __call = function (cls, ...)
    return cls.new(...)
    end,
})



function Item:new (name,amount,limit)
    local o = {}
    local self = setmetatable(Item,o)
    self.name = name or "noname"
    self.amount = amount or 0
    self.limit = limit or 0
    self.changed = true -- used to check whether this should be redrawn
    --table.insert(ItemList,self)
    
    --UI:addItem(self.name)

    return self
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

function Item:isDrawn()
    self.changed = false
end
--------------------------------------------------------------------------------

--Main Program
--------------------------------------------------------------------------------

local ItemList = {}

sand = Item:new("Sand", 10, 16)
cobble = Item:new("Cobblestone", 123, 256)
obsidian = Item:new("Obsidian", 34,128)



table.insert(ItemList, sand)
table.insert(ItemList, cobble)
table.insert(ItemList, obsidian)

print(sand)
print(cobble)
print(obsidian)




UI:init()
for k,v in pairs(ItemList) do
    print(ItemList[k])
    for i,j in pairs(ItemList[k]) do
        print(ItemList[k][j])
    end

    
end

--UI:refresh()
p = term.read()

UI:clear()