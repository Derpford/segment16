local hc = require "HC"

gameScene = {}
localdt = nil

function gameScene:load()
	math.randomseed(os.time())
	randx = 0
	ymin = 0
	ysize = 0
	randx2 = 0
	ymin2 = 0
	ysize2 = 0
	screenBase = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
	screen1 = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
	screen2 = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
	screen3 = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
	segment = options.startseg
	round = 0
	roundTimer=0
	love.timer.sleep(0.1)
	badsLoad(arg)
	audioLoad(arg)
	playerLoad(arg)
	bulletLoad(arg)
	if segment > 1 then
		shuffle(wallRanges)
	end
	player = resetPlayer()
	resetMusic()
end

function gameScene:keypressed(key, scan)
	--Roundskip, debug only!
	if key == 'n' and debug then
		roundTimer = 0
	end
	--Pause button!
	if key == 'p' then
		if pause then
			pause = false
		else
			pause = true
		end
	end
	if key == 'escape' then
		if pause or not isAlive then
			sceneChange(scenes.menu)
		else
			pause = true
		end
	end
	--Switch themes while paused.
	if key == 't' and pause then
		options.theme = options.theme+1
		if options.theme > #options.themeList then
			options.theme = 1
		end
		playerLoad(arg)
		bulletLoad(arg)
		badsLoad(arg)
		reloadPlayerImg(player)
		for i, bad in ipairs(bads) do
			bad:reload()
		end
	end
	--Shader toggles.
	if key == 'g' and pause then
		options.glitch = options.glitch + 1
		if options.glitch > #options.glitchList then
			options.glitch = 1
		end
	end
	if key == 'b' and pause then
		if options.bloom then
			options.bloom = false
		else
			options.bloom = true
		end
	end
	--Reset button!
	if key == 'r' and isAlive == false then
		bads = {}
		bullets = {}
		hc.resetHash()
		round = 0
		segment = options.startseg
		player = resetPlayer()
		resetMusic()
	end
end

function gameScene:update(dt)
	localdt = dt
	if pause == false then
		roundTimer = roundTimer - dt
		if isAlive == false then
			roundTimer = 0
		end
		if roundTimer < 0 and isAlive then
			resetMusic()
			if isAlive and round > 0 then
				player.box:rotate(0.5*math.pi)
			end
			roundTimer = roundTimerMax
			if segment < 1 then -- Training round!
				if round > 0 then
					round = round * 2
					print("Training round normal")
				end
				if round < 1 then
					round = 1
					print("Reset at 0!")
				end
				if round > 8 then
					segment = segment + 1
					round = 1
				end
			else if segment < 4 then -- Main round!
				round = round + 1
				if round > 15 then
					shuffle(wallRanges)
					if round > 15 then
						segment = segment + 1
						round = 1
					end
				end
			else -- Scrambled Round!
				round = round + 1
				shuffle(wallRanges)
				if round > 15 then
					segment = segment + 1
					round = 1
				end
			end
		end
		end
		--Do player and bullet
		bulletUpdate(dt)
		player:update(dt)
		--Do baddies
		badsUpdate(dt)
		--Do music
		audioUpdate(dt)	
		--Shaders!
		if options.glitch then
		if t%1 < 0.02 then
			randx = (math.random()-math.random())/round
			ysize = math.random(16*round,64*round)
			ymin = math.random(0,love.graphics.getHeight()-ysize)
			randx2 = (math.random()-math.random())/round
			ysize2 = math.random(16*round,64*round)
			ymin2 = math.random(0,love.graphics.getHeight()-ysize2)
		else
			if randx > 0 then
				randx = randx - dt*(math.abs(randx))
			end
			if randx < 0 then
				randx = randx + dt*(math.abs(randx))
			end
			if randx2 > 0 then
				randx2 = randx2 - dt*(math.abs(randx))
			end
			if randx2 < 0 then
				randx2 = randx2 + dt*(math.abs(randx))
			end
		end
	end
	end
end

function gameScene:draw(dt)
	love.graphics.setCanvas(screen2)
	love.graphics.clear(7, 54, 66)
	love.graphics.setCanvas(screen1)
	love.graphics.clear(7, 54, 66)
	love.graphics.setCanvas(screenBase)
	love.graphics.clear(7, 54, 66)
	love.graphics.setBlendMode("alpha")
	--HUD elements.
	--Start with the quadrant lines.
	love.graphics.setColor( 88, 110, 117, 255)
	love.graphics.setLineStyle('rough')
	love.graphics.setLineWidth(2)
	love.graphics.line(0,0,love.graphics.getWidth(),love.graphics.getHeight())
	love.graphics.line(0,love.graphics.getHeight(),love.graphics.getWidth(),0)
	--Let's draw something over the quadrants that are spawning enemies right now.
	love.graphics.setColor(255, 0, 0, 64-(halfSec*128))
	roomCenter = {x=love.graphics.getWidth()/2,y=love.graphics.getHeight()/2}
	for i, wall in ipairs(walls) do
		result = bit.band(round, wall)
		if result > 0 then
			if wallRanges[i] == "up" then
			--Top.
				love.graphics.polygon('fill',roomCenter.x, roomCenter.y,0,0,love.graphics.getWidth(),0)
			end
			if wallRanges[i] == "down" then
				--Bottom.
				love.graphics.polygon('fill',roomCenter.x, roomCenter.y,0,love.graphics.getHeight(),love.graphics.getWidth(),love.graphics.getHeight())
			end
			if wallRanges[i] == "left" then
				--Left.
				love.graphics.polygon('fill',roomCenter.x, roomCenter.y,0,0,0,love.graphics.getHeight())
			end
			if wallRanges[i] == "right" then
				--Right
				love.graphics.polygon('fill',roomCenter.x, roomCenter.y,love.graphics.getWidth(),0,love.graphics.getWidth(),love.graphics.getHeight())
			end
		end
	end
	love.graphics.setColor(255,255,255,255)
	-- Friggin' huge draw function for the player.
	player:draw(dt)
	-- Another huge draw function for the boolits.
	bulletDraw(dt)
	-- And one for baddies.
	badsDraw(dt)

	--Now for canvas rendering
	love.graphics.setColor(255,255,255,255)
	--first, render the screenBase to the bloomScreen w/bloom
	love.graphics.setBlendMode("alpha","premultiplied")
	love.graphics.setCanvas(screen2)
	if options.bloom then
		love.graphics.setShader(bloomEffect)
	else
		love.graphics.setShader()
	end
	love.graphics.draw(screenBase,0,0)
	--then, render the screenBase to the glitchScreen w/glitch
	glitchEffect:send("randx",randx)
	glitchEffect:send("ymin",ymin)
	glitchEffect:send("ysize",ysize)
	love.graphics.setCanvas(screen1)
	if options.glitch > 1 then
		love.graphics.setShader(glitchEffect)
	else
		love.graphics.setShader()
	end
	love.graphics.draw(screenBase,0,0)
	--Do it again for a second screen.
	glitchEffect:send("randx",randx2)
	glitchEffect:send("ymin",ymin2)
	glitchEffect:send("ysize",ysize2)
	love.graphics.setCanvas(screen3)
	if options.glitch > 2 then
		love.graphics.setShader(glitchEffect)
	else
		love.graphics.setShader()
	end
	love.graphics.draw(screen1,0,0)
	--then, render the final screen to the real screen.
	love.graphics.setShader()
	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha","premultiplied")
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(screen2, love.graphics.getWidth()/2-300, 0)
	love.graphics.setColor(255,255,255,64)
	love.graphics.draw(screen3, love.graphics.getWidth()/2-300, 0)
	love.graphics.setBlendMode("alpha")
	--Now the score, segment, round, and time.
	love.graphics.setColor(255,255,255,255)
	love.graphics.setColor(255, 255, 255, 64)
	love.graphics.setFont(fonts.status)
	love.graphics.print("pts.hp+: "..score.."."..damage, 16,(love.graphics.getHeight()/2)-40)
	love.graphics.print("seg.rnd:"..segment.."."..round,16,(love.graphics.getHeight()/2)-32)
	if pause and halfSecReal > 0.25 then
		love.graphics.setColor(220, 50, 47, 255)
		love.graphics.print("paused",32,16)
		love.graphics.setColor(255, 255, 255, 64)
	end
	love.graphics.setFont(fonts.time)
	if roundTimer > 9 then
		love.graphics.print(math.ceil(roundTimer),16,love.graphics.getHeight()/2)
	else
		love.graphics.print("0"..math.ceil(roundTimer),16,love.graphics.getHeight()/2)
	end
	if isAlive == false then
		love.graphics.printf("GAME OVER",0,(love.graphics.getHeight()/2)-128,600,"center")
		love.graphics.setFont(fonts.status)
		love.graphics.printf("Press R to Restart or ESC to quit",0,(love.graphics.getHeight()/2)-64,600,"center")
	end
end

function gameScene:unload()
	love.graphics.setShader()
	glitchEffect:send("randx",0)
	glitchEffect:send("ymin",0)
	glitchEffect:send("ysize",0)
	hc.resetHash()
	bads = {}
	bullets = {}
	player = {}
	stopMusic()
end