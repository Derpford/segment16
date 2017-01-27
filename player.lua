local anim8 = require "anim8"
local hc = require "HC"
local shape = require "HC.shapes"

blinkRate = 0.1

function bulletLoad(arg)
	bulletSheet = themeLoad('/shot/shot.png')
	bulletGrid = anim8.newGrid(16, 16, bulletSheet:getWidth(), bulletSheet:getHeight())
	bulletAnim = anim8.newAnimation(bulletGrid('1-2',1),0.1)
	bulletSound = love.audio.newSource('assets/audio/shot/shot.ogg','static')
end

function playerLoad(arg)
	do
		sheet = themeLoad('/player/player.png')
		grid = anim8.newGrid(16, 16, sheet:getWidth(), sheet:getHeight())
		anim = anim8.newAnimation(grid('1-'..sheet:getWidth()/16,1),0.1)
		boom = love.audio.newSource('assets/audio/boomscream.ogg')
		playerBase = {vx=0,vy=0,sheet=sheet,grid=grid,anim=anim,speed=250,accel=8,boom=boom}
		function playerBase:draw(dt)
			love.graphics.setColor(255,255,255,255)
			-- Friggin' huge draw function for the player.
			if isAlive then
				if not isInvuln or t%blinkRate < blinkRate/2 then
					cx, cy = player.box:center()
					if not options.bloom then
						love.graphics.setShader(fadeEffect)
						fadeEffect:send("factor",halfSec)
						love.graphics.setColor(255,255,255,255)
						fadeEffect:send("startAlpha", 0.75)
					end
					player.anim:draw(player.img,cx,cy,player.box:rotation(),1.5-halfSec,1.5-halfSec,8,8)
					love.graphics.setShader()
					if not options.bloom then
						player.anim:draw(player.img,cx,cy,player.box:rotation(),1,1,8,8)
					end
				end
			end
		end

		function playerBase:update(dt)
			if isAlive then
				invulnTimer = invulnTimer - dt
				if invulnTimer < 0 and isInvuln then
					isInvuln = false
				end
				--self input!
				-- Movement bits.
				xvel = 0
				yvel = 0
				xpos, ypos = self.box:center()
				if love.keyboard.isDown('left','a') then
					xvel = xvel -dt*self.accel
				end
				if love.keyboard.isDown('right','d') then
					xvel = xvel +dt*self.accel
				end
				if love.keyboard.isDown('up','w') then
					yvel = yvel -dt*self.accel
				end
				if love.keyboard.isDown('down','s') then
					yvel = yvel +dt*self.accel
				end
				self.vx = self.vx + xvel
				self.vy = self.vy + yvel
				--Clamp speed.
				if self.vx > 1 then
					self.vx = 1
					else if self.vx < -1 then
						self.vx = -1
					end
				end
				if self.vy > 1 then
					self.vy = 1
					else if self.vy < -1 then
						self.vy = -1
					end
				end
				--Decel.
				if xvel == 0 then
					if self.vx > 0 then
						self.vx = self.vx - dt*self.accel/3
					else if self.vx < 0 then
							self.vx = self.vx + dt*self.accel/3
						end
					end
				end
				if yvel == 0 then
					if self.vy > 0 then
						self.vy = self.vy - dt*self.accel/3
					else if self.vy < 0 then
							self.vy = self.vy + dt*self.accel/3
						end
					end
				end
				--Fix borders.
				if self.vx < 0 and xpos < 8 then
					self.vx = 0
				end
				if self.vx > 0 and xpos > love.graphics.getWidth() - 8 then
					self.vx = 0
				end
				if self.vy < 0 and ypos < 8 then
					self.vy = 0
				end
				if self.vy > 0 and ypos > love.graphics.getHeight() - 8 then
					self.vy = 0
				end
				self.box:move(self.vx*self.speed*dt,self.vy*self.speed*dt)
				self.anim:update(dt)
				-- Shooty bits.
				if love.keyboard.isDown(' ','lctrl','rctrl','ctrl') and canShoot then
					--Make da boolit.
					offset = 8
					xpos, ypos = self.box:center()
					ypos = ypos - offset*math.cos(self.box:rotation())
					xpos = xpos + offset*math.sin(self.box:rotation())
					newBullet1 = { box = hc.point(xpos + offset*math.sin(self.box:rotation()+(0.5*math.pi)), ypos +offset*math.cos(self.box:rotation()+(0.5*math.pi))), img = bulletSheet, anim = bulletAnim:clone(), speed = 500}
					newBullet1.box:setRotation(self.box:rotation())
					newBullet2 = { box = hc.point(xpos + offset*math.sin(self.box:rotation()+(1.5*math.pi)), ypos +offset*math.cos(self.box:rotation()+(1.5*math.pi))), img = bulletSheet, anim = bulletAnim:clone(), speed = 500}
					newBullet2.box:setRotation(self.box:rotation())
					table.insert(bullets, newBullet1)
					table.insert(bullets, newBullet2)
					love.audio.play(bulletSound)
					canShoot = false
					canShootTimer = canShootTimerMax
				end
			end
			-- Shot logic
			canShootTimer = canShootTimer - (1*dt)
			if canShootTimer < 0 then
				canShoot = true
			end
			--Now for collision.
			if isAlive and not isInvuln then
				for i, bad in ipairs(bads) do
					if self.box:collidesWith(bad.box) then
						damage = damage - 50 - 50*segment
						isInvuln = true
						invulnTimer = invulnTimerMax
						hc.remove(bad.box)
						love.audio.play(self.boom)
						table.remove(bads, i)
						if damage <= 0 then
							isAlive = false
							hc.remove(self.box)
						end
					end
				end
			end
		end
	end
end

function resetPlayer()
	newplayer = {vx=0,vy=0,box = hc.rectangle(love.graphics.getWidth()/2-8,love.graphics.getHeight()/2+24,8,8),
		speed = playerBase.speed,
		accel = playerBase.accel,
		img = playerBase.sheet,
		anim = playerBase.anim:clone(),
		update = playerBase.update,
		draw = playerBase.draw,
		boom = playerBase.boom
		}
	newplayer.box:setRotation(rotList.up)
	isAlive = true
	damage = 50
	score = 0
	isInvuln = false
	invulnTimerMax = 1
	invulnTimer = invulnTimerMax
	canShoot = true
	canShootTimerMax = 0.2
	canShootTimer = canShootTimerMax
	
	return newplayer
end

function reloadPlayerImg(player)
	player.img = playerBase.sheet	
	player.anim = playerBase.anim:clone()
end

function bulletUpdate(dt)
	-- Bullet movement
	for i, bullet in ipairs(bullets) do
		xvel = math.sin(bullet.box:rotation())
		yvel = math.cos(bullet.box:rotation())
		bullet.box:move(xvel*bullet.speed*dt, -yvel*bullet.speed*dt)
		xpos, ypos = bullet.box:center()
		if ypos < 0 or ypos > love.graphics.getHeight() or xpos < 0 or xpos > love.graphics.getWidth() then
			hc.remove(bullet.box)
			table.remove(bullets, i)
		end
		bullet.anim:update(dt)
	end
end

function bulletDraw(dt)
	for i, bullet in ipairs(bullets) do
		cx, cy = bullet.box:center()
		if not options.bloom then
			love.graphics.setShader(fadeEffect)
		end
		bullet.anim:draw(bullet.img, cx, cy, bullet.box:rotation(), 1.5-halfSec, 1.5-halfSec, 8, 0)
		love.graphics.setShader()
		if not options.bloom then
			bullet.anim:draw(bullet.img, cx, cy, bullet.box:rotation(), 1, 1, 8, 0)
		end
	end
end