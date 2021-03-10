print("Diggedy Dig!")  --By Maffels
print("To use enderchest mode:")
print("Put enderchest in the last inv slot")
print("Dig up or down? (type up or down)")
repeat
start = io.read() -- read vertical starting direction
until start == "up" or start == "down"
print("Give height(or depth)")
h = io.read() --read height of area
h = tonumber(h)
print("Give length")
l = io.read() --read lenght(depth)
l = tonumber(l)
print("Give width")
w = io.read() -- read width
w = tonumber(w)
itemsMined = 0





-- checks whether an enderchest is present 
if turtle.getItemCount(16) > 0 then
	print("Using enderchest mode!") 
	chestmode = true
end


--checks the fuellevel refuels when needed and prompts when in need of more fuel
function checkfuel()
	turtle.select(1)
	if turtle.getFuelLevel() < ((h*2)+5) then
		turtle.refuel(1) 
		if turtle.getFuelLevel() < ((h*2)+5) then
			print("Add fuel pl0x!(in 1st slot)")
			while	turtle.getFuelLevel() < ((h*2)+5) do
				sleep(1)
				turtle.refuel(1)
			end
			print("Fueled and ready to go!")
		end
			
	end	
	turtle.select(2)
end

-- checks for inventory space and prompts user to empty if full
function checkinventory()
	
while turtle.getItemCount(15) > 0 do
	print("Inventory close to full!")
	print("Empty and press y to continue")
	io.read()
end
end

-- checks for inventory space and empties in enderchest if full
function enderinventory()

if turtle.getItemCount(12) > 0 then
	iMined = 0
	turtle.select(16)
	if up == false then
		repeat turtle.digUp()
		until turtle.detectUp() == false
		turtle.placeUp()
		for ni = 2, 15 do
			turtle.select(ni)
			if turtle.getItemCount(ni) > 0 then
				iMined = iMined + turtle.getItemCount(ni)
				repeat
				until turtle.dropUp() == true
			end
		end
		turtle.select(16)
		turtle.digUp()
		turtle.select(2)
	else
		repeat turtle.digDown()
		until turtle.detectDown() == false
		turtle.placeDown()
		for ni = 2, 15 do
			turtle.select(ni)
			if turtle.getItemCount(ni) > 0 then
				iMined = iMined + turtle.getItemCount(ni)
				repeat
				until turtle.dropDown() == true
			end
		end
		turtle.select(16)
		turtle.digDown()
		turtle.select(2)
	end
print("Dumped ", iMined, " items in the enderchest!")
itemsMined = itemsMined + iMined
end
end	

-- digs a certain amount of rows up
function digUp(nrows)

hf = h-1
if nrows > 1 then
	
	repeat
		repeat
			turtle.dig()
		until turtle.detect() == false
		repeat turtle.digUp()
		until turtle.up() == true
		hf = hf - 1
	until hf  == 0
	repeat turtle.dig()
	until turtle.forward() == true
	if nrows-2 > 0 then
		repeat turtle.dig()
		until turtle.forward() == true
	end

	else
		repeat
			repeat turtle.digUp()
			until turtle.up() == true
			hf = hf-1
		until hf == 0
	end
up = false
end

function digDown(nrows)

hf = h-1
if nrows > 1 then
	
	repeat
		repeat
			turtle.dig()
		until turtle.detect() == false
		repeat turtle.digDown()
		until turtle.down() == true
		hf = hf - 1
	until hf  == 0
	repeat turtle.dig()
	until turtle.forward() == true
	if nrows-2 > 0 then
		repeat turtle.dig()
		until turtle.forward() == true
	end

	else
		repeat
			repeat turtle.digDown()
			until turtle.down() == true
			hf = hf-1
		until hf == 0
	end
up = true
end
	
-- function that repeats the digrow function for the number of rows
function reprow(rep)

if h > 1 then
	repeat
		if chestmode == true then
			enderinventory()
		else
		checkinventory()
		end
		checkfuel()
		if up == true then
			digUp(rep)
		else
			digDown(rep)
		end
			
			
		rep = rep-2
	until rep < 1
else
	repeat
		repeat
			turtle.dig()
		until turtle.forward() == true
		rep = rep-1
	until rep == 0 
end
end

----------------------------
-- Main program starts here
----------------------------
checkfuel()
if chestmode == true then
	enderinventory()
else
	checkinventory()
end
if start == "up" then
	up = true
else
	up = false
end


ww = w

repeat
	turtle.dig()
until turtle.forward() == true

repeat
ww = ww-1
	reprow(l)

if ww > 0 then
	if ((w-ww) % 2) == 0 then -- if the number of rows dug is even, turn left
		turtle.turnLeft()
		repeat turtle.dig()
		until turtle.forward() == true
		turtle.turnLeft()
	else	-- else turn right, to keep diggin in the same area
	   turtle.turnRight()
		repeat turtle.dig()
		until turtle.forward() == true
	   turtle.turnRight()
	end	
end

until ww == 0

hb= h-1
if up == false and start == "up" then
	repeat 
		repeat turtle.digDown()
		until turtle.down() == true
		hb = hb-1
	until hb == 0
end	
if up == true and start == "down" then
	repeat
		repeat turtle.digUp()
		until turtle.up() == true
		hb = hb-1
	until hb == 0
end


for ni = 2, 15 do
	iMined = 0
	turtle.select(ni)
	iMined = iMined + turtle.getItemCount(ni)
itemsMined = itemsMined + iMined
end

print("Finished!")
print("Mined ", itemsMined, " items!")