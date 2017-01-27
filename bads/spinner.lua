local anim8 = require "anim8"
local hc = require "HC"
local shape = require "HC.shapes"
badsDB.spinner = {}


function badsDB.spinner:load()
	self.sheet = themeLoad('/spinner/spinner.png')
	self.grid = anim8.newGrid(16,16,self.sheet:getWidth(),self.sheet:getHeight())
	self.anim = anim8.newAnimation(self.grid('1-'..self.sheet:getWidth()/16,1),0.1)
	self.boom = love.sound.newSoundData('assets/audio/boom.ogg')
	self.speed = 200
	self.type = "spinner"
end

function badsDB.spinner:draw(dt)
	love.graphics.setColor(255,255,255,255)
	cx, cy = self.box:center()
	if not options.bloom then
		if options.themeList[options.theme] ~= "default" then
			love.graphics.setColor(255,255,255,255)
			fadeEffect:send('isWhite',true)
		else
			love.graphics.setColor(255,0,0,255)
			fadeEffect:send('isWhite',false)
		end
		love.graphics.setShader(fadeEffect)
		fadeEffect:send("startAlpha", 0.7)
	else if options.themeList[options.theme] == "red" then
			love.graphics.setColor(255,0,0,255)
		end
	end
	self.anim:draw(self.img, cx, cy, self.box:rotation(), 1.5-halfSec, 1.5-halfSec, 8, 8)
	love.graphics.setShader()
	if options.themeList[options.theme] == "red" then
		love.graphics.setColor(255,0,0,255)
	else
		love.graphics.setColor(255,255,255,255)
	end
	if not options.bloom then
		self.anim:draw(self.img, cx, cy, self.box:rotation(), 1, 1, 8, 8)
	end
end

function badsDB.spinner:update(dt)
	xvel = math.sin(self.box:rotation())
	yvel = math.cos(self.box:rotation())
	xpos, ypos = self.box:center()
	self.box:move(xvel*self.speed*dt, -yvel*self.speed*dt)
	self.anim:update(dt)
	for j, bad in ipairs(bads) do
		if bad == self then
			for i, bullet in ipairs(bullets) do
				if self.box:collidesWith(bullet.box) then
					hc.remove(bullet.box)
					table.remove(bullets,i)
					hc.remove(self.box)
					table.remove(bads,j)
					love.audio.play(self.boom)
					score = score + 10 + 5*segment
					damage = damage + 10
				end
			end
		end
	end
end

function badsDB.spinner:reload()
	self.img = badsDB.spinner.sheet
	self.anim = badsDB.spinner.anim:clone()
	self.boom = love.audio.newSource(badsDB.spinner.boom)
	self.type = badsDB.spinner.type
	self.speed = badsDB.spinner.speed
	self.update = badsDB.spinner.update
	self.draw = badsDB.spinner.draw
	self.reload = badsDB.spinner.reload
end

function badsDB.spinner:new(x,y)
	newBad = {
		box = hc.rectangle(x,y,16,16),
		img = self.sheet,
		anim = self.anim:clone(),
		boom = love.audio.newSource(self.boom),
		type = self.type,
		speed = self.speed,
		update = self.update,
		draw = self.draw,
		reload = self.reload
	}
	return newBad
end
