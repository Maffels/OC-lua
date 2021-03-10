-- Drone program for letting drones transfer items using waypoints
range = 128

local function proxyFor(name, required)
local address = component and component.list(name)()
if not address and required then
error("missing component '" .. name .. "'")
end
return address and component.proxy(address) or nil
end

local drone = proxyFor("drone", true)
local nav = proxyFor("navigation", true)
local invctrl = proxyFor("inventory_controller")

colCharge = 0xFFCC33
colGetInv = 0x33FF33
colDeliver = 0x6699FF
colSleep = 0xFFFFFF

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
    computer.pullSignal(0.5)
    while drone.getVelocity() > 0.2 do
      computer.pullSignal(0.2)
    end
    vec = calcMove(w,o)
    if vec[1] == 0 and vec[2] == 0 and vec[3] == 0 then
      break
    else
      drone.move(math.random(-1,1),math.random(-1,1),math.random(-1,1))
    end
    while drone.getVelocity() > 0.2 do
        computer.pullSignal(0.2)
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
    drone.setStatusText('Charging')
    local o = {0,1,0}
    moveTo(findClose('Charging'),o)
    while computer.energy() < computer.maxEnergy() * 0.9 do
      computer.pullSignal(1)
    end
  end
end

function emptyInv()
  local offset = {0,1,0}
  drone.setLightColor(colDeliver)
  drone.setStatusText('Emptying\nInventory')
  moveTo(findClose('Storage'),offset)
  for s = 1, 4 do
    drone.select(s)
    drone.drop(0)
  end
  drone.select(1)
end

function invCheck()
  if drone.count(3) > 0 then
    drone.setLightColor(colDeliver)
    emptyInv()
  end
end

function getDropOffs()
  local waypoints = nav.findWaypoints(range)
  local dropoffs = {}
  for _, w in ipairs(waypoints) do
    if string.find(w.label,'DropOff') then
      table.insert(dropoffs, w)
    end
  end
  return dropoffs
end

function transferItems(dropoff)
  energyCheck()
  invCheck()
  drone.setLightColor(colGetInv)
  drone.setStatusText('Handling:\n' .. dropoff.label)
  local offset = {0,1,0}
  moveTo(dropoff,offset)
  local invSize = invctrl.getInventorySize(0)
  local invslot = 1
  for s=invSize, 1, -1 do
    if invctrl.getSlotStackSize(0,s) > 0 then
        drone.select(invslot)
        invctrl.suckFromSlot(0,s)
        invslot = invslot + 1
    end
    if invslot > 4 then
        break
    end
  end
  drone.select(1)
  emptyInv()
  if invslot < 4 then
    drone.setLightColor(colSleep)
    drone.setStatusText('Sleeping\n30 Seconds')
    computer.pullSignal(30)
  end
end

function handleDropOffs()
  local dropoffs = getDropOffs()
  invCheck()
  while true do
    dropoffs = getDropOffs()
    for _, dropoff in ipairs(dropoffs) do
      transferItems(dropoff)
    end
  end
end

--------
energyCheck()
invCheck()
handleDropOffs()