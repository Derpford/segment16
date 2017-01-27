local anim8 = require "anim8"
local hc = require "HC"
local shape = require "HC.shapes"
badsDB.shooter = {}


function badsDB.shooter:load()
	self.sheet = themeLoad('/shooter/shooter.png')
	self.grid = anim8.newGrid(16,16,self.sheet:getWidth(),self.sheet:getHeight())
	self.anim = anim8.newAnimation(self.grid('1-'..self.sheet:getWidth()/16,1),0.1)
	self.boom = love.sound.newSoundData('assets/audio/boom.ogg')
	shooterBulletSheet = themeLoad('/shooter/shot.png')
	shooterBulletGrid = anim8.newGrid(16,16,shooterBulletSheet:getWidth(),shooterBulletSheet:getHeight())
	shooterBulletAnim = anim8.newAnimation(shooterBulletGrid('1-'..shooterBulletSheet:getWidth()/16,1),0.1)
	shooterBulletBoom = love.sound.newSoundData('assets/audio/boom.ogg')
	self.speed = 200
	self.bulletTimerMax = 0.5
	self.bulletTimer = 0.5
	self.type = "shooter"
end

function badsDB.shooter:draw(dt)
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
	self.anim:draw(self.img, cx, cy, -rot, 1.5-halfSec, 1.5-halfSec, 8, 8)
	love.graphics.setShader()
	if options.themeList[options.theme] == "red" then
		love.graphics.setColor(255,0,0,255)
	else
		love.graphics.setColor(255,255,255,255)
	end
	if not options.bloom then
		self.anim:draw(self.img, cx, cy, -rot, 1, 1, 8, 8)
	end
end

function badsDB.shooter:update(dt)
	cx,cy = self.box:center()
	ox,oy = player.box:center()
	tx,ty = ox-cx,oy-cy
	rot = math.atan2(tx,ty)
	self.box:setRotation(rot)
	if math.sqrt(tx^2+ty^2) > self.goalDistance then
		rotFinal = rot + 0.6*math.pi
	else
		rotFinal = rot + 0.4*math.pi
	end
	xvel, yvel = math.sin(rotFinal), math.cos(rotFinal)
	self.box:move(-xvel*self.speed*dt, -yvel*self.speed*dt)
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

	if self.bulletTimer < 0 then
		local xpos, ypos = self.box:center()
		if ypos > 0 and ypos < love.graphics.getHeight() and xpos > 0 and xpos < love.graphics.getWidth() then
			bulletTimer = bulletTimerMax
			offset = 8
			ypos = ypos - offset*math.cos(self.box:rotation())
			xpos = xpos + offset*math.sin(self.box:rotation())
			newBullet = {
										box = hc.point(xpos + offset*math.sin(self.box:rotation()+(0.5*math.pi)), ypos + offset*math.cos(self.box:rotation()+(0.5*math.pi))),
										img = shooterBulletSheet,
										anim = shooterBulletAnim:clone(),
										speed = 500
									}
			newBullet.box:setRotation(self.box:rotation())
			function newBullet:draw()
				cx, cy = self.box:center()
				if not options.bloom then
					love.graphics.setShader(fadeEffect)
				end
				shooterBulletAnim:draw(shooterBulletSheet, cx, cy, self.box:rotation(), 1.5-halfSec, 1.5-halfSec, 8, 0)
				love.graphics.setShader()
				if not options.bloom then
					shooterBulletAnim:draw(shooterBulletSheet, cx, cy, self.box:rotation(), 1, 1, 8, 0)
				end
			end
			function newBullet:update(dt)
				print(tostring(dt))
				local xvel = math.sin(self.box:rotation())
				local yvel = math.cos(self.box:rotation())
				self.box:move(xvel*self.speed*dt, -yvel*self.speed*dt)
				xpos, ypos = self.box:center()
				if ypos < 0 or ypos > love.graphics.getHeight() or xpos < 0 or xpos > love.graphics.getWidth() then
					hc.remove(self.box)
					table.remove(bads, i)
				end
			end
		end

		table.insert(bads, newBullet)
		love.audio.play(bulletSound)
	else
		self.bulletTimer = self.bulletTimer - dt
	end
	shooterBulletAnim:update(dt)
end

function badsDB.shooter:reload()
	self.img = badsDB.shooter.sheet
	self.anim = badsDB.shooter.anim:clone()
	self.boom = love.audio.newSource(badsDB.shooter.boom)
	self.type = badsDB.shooter.type
	self.speed = badsDB.shooter.speed
	self.update = badsDB.shooter.update
	self.draw = badsDB.shooter.draw
	self.reload = badsDB.shooter.reload
end

function badsDB.shooter:new(x,y)
	newBad = {
		goalAngle = 0,
		goalDistance = 200,
		bulletTimerMax = self.bulletTimerMax,
		bulletTimer = self.bulletTimer,
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
	newBad.goalAngle = -newBad.box:rotation()
	return newBad
end
