-- Drone program for letting drones farm using waypoints
-- Reuse of some code from and inspired by the sortingdrone program by Sangar(OC developer)
-- Sadly had to keep the code shorter than I would've liked because of the 4KiB EEPROM limit; use minify.
-- Put "Farm", or "DropOff", in waypoint name, and give farms redstone power for random plots.
-- Farm 9x9, divided in 3x3 plots, with the middle empty, 1 product per plot for optimal use: 

local range = 128
local port = 162

-----------------

local function proxyFor(name, required)
  local address = component and component.list(name)()
  if not address and required then
    error("missing component '" .. name .. "'")
  end
  return address and component.proxy(address) or nil
end

local drone = proxyFor("drone", true)
local nav = proxyFor("navigation", true)
local invctrl = proxyFor("inventory_controller", false)
local modem = proxyFor("modem", false)

local colCharge = 0xFFCC33
local colFarm = 0x66CC66
local colDeliver = 0x6699FF
local farms = {}

function handleMessage(msg, data)
  if msg == 'Farming' then
    for k, f in ipairs(farms) do
      if string.find(string.format(f.label),string.format(data)) then
        farms[k].time = os.time()
      end
    end
  end
end

function sleep(t)
  local t = t or 0.05
  if modem == nil then
    computer.pullSignal(t)
    return nil
  end
  local evt,_,sender,port,dist,msg,data = computer.pullSignal(t)
  if evt == "modem_message" then
    handleMessage(msg, data)
  end
end

function calcMove(w,o)
  local vec = {}
  local s = {}
  for _, tempw in ipairs(nav.findWaypoints(range)) do
    if string.find(tempw.label,w.label) then
      s = tempw
    end
  end
  vec[1] = s.position[1] + o[1]
  vec[2] = s.position[2] + o[2]
  vec[3] = s.position[3] + o[3]
  return vec
end

function moveTo(w, o)
  local vec = {}
  while true do
    vec = calcMove(w,o)
    drone.move(vec[1],vec[2],vec[3])
   sleep(0.5)
    while drone.getVelocity() > 0.5 do
     sleep(0.2)
    end
    vec = calcMove(w,o)
    if vec[1] == 0 and vec[2] == 0 and vec[3] == 0 then
      break
    else
      drone.move(math.random(-1,1),math.random(-1,1),math.random(-1,1))
    end
    while drone.getVelocity() > 0.5 do
     sleep(0.2)
    end
  end
end

function findClose(label)
  local wps = {}
  wps.dist = math.huge
  wps.w = nil
  for _, w in ipairs(nav.findWaypoints(range)) do
    if string.find(w.label,label) then
      local dist = math.abs(w.position[1]) + math.abs(w.position[2]) + math.abs(w.position[3])
      if dist < wps.dist then
        wps['dist'] = dist
        wps['w'] = w
      end
    end
  end
  if wps.w then
    return wps['w']
  else
    drone.setStatusText(label .. "\nnot found")
  end
end
    
function energyCheck()
  if computer.energy() < computer.maxEnergy() * 0.2 then
    drone.setLightColor(colCharge)
    local o = {}
    o = {0,1,0}
    moveTo(findClose('Charging'),o)
    while computer.energy() < computer.maxEnergy() * 0.9 do
     sleep(1)
    end
  end
end

function emptyInv()
  local offset = {0,1,0}
  drone.setLightColor(colDeliver)
  drone.setStatusText('Emptying\nStorage')
  moveTo(findClose('DropOff'),offset)
  for s = 1, 4 do
    drone.select(s)
    drone.drop(0)
  end
  drone.select(1)
end

function invCheck()
  if drone.count(3) > 0 then
    emptyInv()
  end
end

function initFarms()
  local waypoints = nav.findWaypoints(range)
  for _, w in ipairs(waypoints) do
    if string.find(w.label,'Farm') then
      w.time = os.time() + math.random(-5,5)
      table.insert(farms, w)
    end
  end
end

function initPlots(farm)
  local p = {}
  for i = 1, 8 do
    p[i] = {}
  end
  p[1] = {-4, 1,  4}
  p[2] = {-4, 1,  1}
  p[3] = {-4, 1, -2}
  p[4] = {-1, 1, -2}
  p[5] = { 2, 1, -2}
  p[6] = { 2, 1,  1}
  p[7] = { 2, 1,  4}
  p[8] = {-1, 1,  4}
  
  if farm.redstone > 0 then
    local q = {}
    for i = 1, 8 do
      local a = nil
      repeat 
        a = math.random(8)
      until(p[a])
      q[i] = p[a]
    end
    p = q
  end
  return p
end

function farmPlot(farm, plot, num)
  energyCheck()
  invCheck()
  drone.setLightColor(colFarm)
  drone.setStatusText(farm.label .. '\nPlot: '.. num)
  moveTo(farm,plot)
  local d = -1
  local c = 0
  drone.setAcceleration(0.45)
  for x = 1, 3 do
    drone.use(0)
    for z = 1, 2 do
      drone.move(0,0,d)
      while drone.getOffset() > 0.5 or drone.getVelocity() > 0.5 do
       sleep(0.05)
      end
      drone.use(0)
    end
    d = d * -1
    if c < 2 then
      drone.move(1,0,0)
      while drone.getOffset() > 0.5 or drone.getVelocity() > 0.5 do
       sleep(0.05)
      end
      c = c+1
    end
  end
  drone.setAcceleration(2)
end

function farmField(farm)
  local plots = initPlots(farm)
  for k, f in ipairs(farms) do
    if string.find(string.format(f.label),string.format(farm.label)) then
      farms[k].time = os.time()
    end
  end
  modem.broadcast(port,'Farming',farm.label)
  for num, plot in pairs(plots) do
    farmPlot(farm, plot, num)
  end
end

function farm()
  local d = -1
  local keys = {}
  while true do
    local time = math.huge
    local farm = {}
    for _, f in ipairs(farms) do
      if f.time < time then
        time = f.time
        farm = f
      end
    end
    farmField(farm)
  end
end

-------
math.randomseed(os.time())
math.random()math.random()math.random()
modem.open(port)
energyCheck()
invCheck()
initFarms()
farm()