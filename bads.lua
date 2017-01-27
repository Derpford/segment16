local anim8 = require "anim8"
local hc = require "HC"
local shape = require "HC.shapes"

-- Table of Bads.
badsDB = {}
-- Require new Bads after the table.
require "bads.spinner"
require "bads.chaser"
require "bads.shooter"
margin = 32
spread = 0.2
createBadTimerMax = 0.5
createBadTimer = createBadTimerMax
badCycleNumber=0
wallCycleNumber=0
chaserStart=0
shooterStart=0

--Misc Functions.
function getAngleToPlayer(bad,player)
	targx,targy=player.box:center()
	startx, starty=bad.box:center()
	return math.atan2(targy-starty,targx-startx)
end

--Load the bads.
function badsLoad(args)
	badsDB.spinner:load()
	badsDB.chaser:load()
	badsDB.shooter:load()
end

function makeBad(x,y)
	--if badCycleNumber%8 == 0 and segment >= shooterStart then
	--	bad = badsDB.shooter:new(x,y)
	--else
		if badCycleNumber%4 == 0 and segment >= chaserStart then
			bad = badsDB.chaser:new(x,y)
		else
			bad = badsDB.spinner:new(x,y)
		end
	end
	return bad
end


function badsUpdate(dt)
	badsDB.chaser.anim:update(dt)
	if segment > 1 then
		createBadTimer = createBadTimer - (dt*segment)
	else
		createBadTimer = createBadTimer - dt
	end
	--Creating new bads.
	if createBadTimer < 0 then
		createBadTimer = createBadTimerMax
		wallCycleNumber = wallCycleNumber+1
		for i, wall in ipairs(walls) do
			--for j=0, segment do
				result = bit.band(round, wall)
				if result > 0 then
					badCycleNumber = badCycleNumber+1
					spreadNew = spread * (math.random() - math.random())
					if wallRanges[i] == "up" then
						--Make a bad on the top.
						-- Add randomness with this:
						--+(math.random()-math.random()*spread))
						posx = math.random(margin, love.graphics.getWidth() - margin)
						posy = -10
						newBad = makeBad(posx,posy)
						newBad.box:setRotation(rotList.down+spreadNew)
						table.insert(bads, newBad)
					end
					if wallRanges[i] == "down" then
						--Make a bad on the bottom.
						posx = math.random(margin, love.graphics.getWidth() - margin)
						posy = love.graphics.getHeight()+10
						newBad = makeBad(posx,posy)
						newBad.box:setRotation(rotList.up+spreadNew)
						table.insert(bads, newBad)
					end
					if wallRanges[i] == "left" then
						--Make a bad on the left.
						posy = math.random(margin, love.graphics.getHeight() - margin)
						posx = -10
						newBad = makeBad(posx,posy)
						newBad.box:setRotation(rotList.right+spreadNew)
						table.insert(bads, newBad)
					end
					if wallRanges[i] == "right" then
						--Make a bad on the right.
						posy = math.random(margin, love.graphics.getHeight() - margin)
						posx = love.graphics.getWidth()+10
						newBad = makeBad(posx,posy)
						newBad.box:setRotation(rotList.left+spreadNew)
						table.insert(bads, newBad)
					end
				--end
			end
		end
	end
	--Updating old bads.
	for i, bad in ipairs(bads) do
		if bad.update ~= nil then
			bad:update(dt)
		end
		xpos, ypos = bad.box:center()
		if xpos < -margin*2 or ypos < -margin*2 or xpos > love.graphics.getWidth()+margin*2 or ypos > love.graphics.getHeight()+margin*2 then
				hc.remove(bad.box)
				table.remove(bads, i)
		end
	end
end

function badsDraw(dt)
	for i, bad in ipairs(bads) do
		bad:draw(dt)
	end
end