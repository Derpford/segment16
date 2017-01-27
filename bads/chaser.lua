local anim8 = require "anim8"
local hc = require "HC"
local shape = require "HC.shapes"
moveTimerMax = 0.5
moveTimer = moveTimerMax
badsDB.chaser = {}

function badsDB.chaser:load()
	self.sheet = themeLoad('/chaser/chaser.png')
	self.grid = anim8.newGrid(16,16,self.sheet:getWidth(),self.sheet:getHeight())
	self.anim = anim8.newAnimation(self.grid('1-'..self.sheet:getWidth()/16,1),0.1)
	self.boom = love.sound.newSoundData('assets/audio/boom.ogg')
	self.vx=0
	self.vy=0
	self.speed = 200
	self.type = "chaser"
end

function badsDB.chaser:update(dt)
	moveTimer = moveTimer - dt
	xvel = self.vx
	yvel = self.vy
	cx,cy=self.box:center()
	ox,oy=player.box:center()
	targx,targy=ox-cx,oy-cy
	if moveTimer < 0 then
		rot=math.atan2(targx,targy)
		xvel = math.sin(rot)
		yvel = math.cos(rot)
		self.vx = xvel
		self.vy = yvel
		self.box:setRotation(math.atan2(self.vx,-self.vy))
		moveTimer = moveTimerMax
	end
	self.box:move(self.vx*self.speed*dt*(1-halfSec), self.vy*self.speed*dt*(1-halfSec))
	
	for j, bad in ipairs(bads) do
		if bad == self then
			for i, bullet in ipairs(bullets) do
				if self.box:collidesWith(bullet.box) then
					hc.remove(bullet.box)
					table.remove(bullets,i)
					hc.remove(self.box)
					table.remove(bads,j)
					love.audio.play(self.boom)
					score = score + 10 + 10*segment
					damage = damage + 20
				end
			end
		end
	end
end

function badsDB.chaser:reload()
	self.img = badsDB.chaser.sheet
	self.anim = badsDB.chaser.anim
	self.boom = love.audio.newSource(badsDB.chaser.boom)
	self.type = badsDB.chaser.type
	self.speed = badsDB.chaser.speed
	self.update = badsDB.chaser.update
	self.draw = badsDB.chaser.draw
	self.reload = badsDB.chaser.reload
end

function badsDB.chaser:draw(dt)
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

function badsDB.chaser:new(x,y)
	newBad = {
		box = hc.rectangle(x,y,16,16),
		vx=0,vy=0,
		img = self.sheet,
		anim = self.anim,
		boom = love.audio.newSource(self.boom),
		type = self.type,
		speed = self.speed,
		update = self.update,
		draw = self.draw,
		reload = self.reload
	}
	return newBad
end