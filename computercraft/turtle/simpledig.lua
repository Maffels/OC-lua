-- Will dig out a specified cube form, given at the start by putting in x, y and z behind the program name


global facings = {'forward','right','backward','left'}
global digcube = {x=0, y=0, z=0}

t = {x=0, y=0, z=0, facing=facings[1] -- table for all customised turtle methods

function t:checkfuel()
	turtle.select(16)
	if turtle.getFuelLevel() < 80 then
		turtle.refuel(1) 
		if turtle.getFuelLevel() < 80 then
			print("Add fuel pl0x!(in 1st slot)")
			while	turtle.getFuelLevel() < ((h*2)+5) do
				sleep(1)
				turtle.refuel(1)
			end
			print("Fueled and ready to go!")
		end
			
	end	
	turtle.select(1)
end

function t:checkinventory()
	
    while turtle.getItemCount(13) > 0 do
        print("Inventory close to full!")
        print("Empty and press y to continue")
        io.read()
    end
end

function t:forward(x)
    if x == nil then
        x = 1
    end
    moved = 0
    repeat
        if turtle.move() == false then
            return false
        else
            if t.facing == 'forward' then 
                t.z = t.z + 1
            elseif t.facing == 'backward' then
                t.z = t.z - 1
            elseif t.facing == 'right' then
                t.x = t.x + 1
            else
                t.x = t.x - 1
            end
        moved = moved + 1

    until moved == x
    return true
end

function t:left()
    turtle.turnLeft()
    t.facing = 'left'
end

function t:right()
    turtle.turnRight()
    t.facing = 'right'
end

function t:up(x)
    if x == nil then
        x = 1
    end
    moved = 0
    repeat
        
        if turtle.up() == false then
            return false
        else
            t.y = t.y + 1
            moved = moved + 1
        end
    until moved == x
    return true
end

function t:down(x)
    if x == nil then
        x = 1
    end
    moved = 0
    repeat
        if turtle.down() == false then
            return false
        else
            t.y = t.y - 1
            moved = moved + 1
        end
    until moved == x
    return true
end


function digleft(y)

end

function digright()

end

function digupwards(y)

end

function digdownwards(y)

end

function returntostart()

end

function gotopos(pos)

end


function digrow(n,y)
    moved = 0
    if y > 2 then
        if t.up() == false then
            turtle.digUp()
            if t.up() == false then
                print('way up blocked! clear the way and type go')
                io.read()
                t.up()
            end
        end
        repeat
            turtle.dig()
            t.forward()
            turtle.digUp()
            turtle.digDown()
            checkfuel()
            checkinventory()
            moved = moved + 1
        until moved == n
    elseif y > 1 then
        repeat
            turtle.dig()
            t.forward()
            turtle.digUp()
            until moved == n
    else
        repeat
            turtle.dig()
            t.forward()
        until moved = n
    end
end




----------------------------
-- Main program starts here
----------------------------


reverse = false

repeat 
    repeat
        if digcube.y -t.y >3 then
            y = 3
        else
            y = digcube.y
        end

        if t.facing == 'forward' then
            z = digcube.z - t.z
        else
            z = t.z
        end
        t.digrow(z,y)
        if 
            
            




