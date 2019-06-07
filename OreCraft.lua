local comp = require("component")
local gpu = comp.gpu
local screen = comp.screen
local term = require("term")
local sides = require("sides")
local os = require("os")
local event = require("event")
local run = true
local Item = require("itemClass")
local Product = require("productClass")



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

    for k,v in pairs(productList) do
        if productList[k]:isChanged() then
            UI:itemBar(productList[k],k*3-1)
            --ItemList[k]:isDrawn()
        end
    end

end
--------------------------------------------------------------------------------

-- Button Functions
--------------------------------------------------------------------------------
local button = {}

ButtonList = {}


function button:new(name, type, xPos,yPos,xSize,ySize)
    local o = {
        name = name or "noname",
        type = type,
        xPos = xPos,
        yPos = yPos,
        xSize = xSize or 1,
        ySize = ySize or 1
    }
    setmetatable(o, {__index = button})
    table.insert(ButtonList,o)
    return o
end


local btnClose = button:new("Close", 0, 32,1)

-------------------------------------------------------------------------------

-- Touchscreen Functions
--------------------------------------------------------------------------------
local Touch = {}

function Touch.handle(ename,eadr,ex,ey,ebtn,epname)
    for k,v in pairs(ButtonList) do
        if ex >= ButtonList[k].xPos and ex <= (ButtonList[k].xPos + ButtonList[k].xSize-1) then
            if ey >= ButtonList[k].yPos and ey <= (ButtonList[k].yPos + ButtonList[k].ySize-1) then
                if ButtonList[k].type == 0 then
                    run = false
                end
                
            end
        end
    end
end

function Touch.init()
    event.listen("touch", Touch.handle)
end

function Touch.stop()
    event.ignore("touch", Touch.handle)
end

--------------------------------------------------------------------------------

-- Item backbone
--------------------------------------------------------------------------------




--------------------------------------------------------------------------------

--Main Program
--------------------------------------------------------------------------------
itemList = {}

productList = {}

table.insert(productList, Product:new("Iron Ingot", 0, 256, "Iron Ore" ))
table.insert(productList, Product:new("Copper Ingot", 0, 128, "Copper Ore"))
table.insert(productList, Product:new("Tin Ingot", 0, 128, "Tin Ore"))


UI:init()
Touch.init()


while run do 

    UI:refresh()
    os.sleep(0.2)

end

Touch.stop()
UI:clear()