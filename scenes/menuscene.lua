menuScene = {}

function menuScene:load()
	--Can't pause in the menu. Also wait a moment for everything to be set up.
	pause = false
	love.timer.sleep(0.1)
	--set a fancy shader
	screen = love.graphics.newCanvas(love.graphics.getWidth(),love.graphics.getHeight())
	--Menus.
	-- First the main one.
	mainMenu = {
		name = "main",
		"play",
		"options",
		"quit"
	}
	function mainMenu:select(key)
		if menu ~= nil then
			if key=="lctrl" or key=="rctrl" or key=="ctrl" then
				if menu[menuPos] == "play" then
					sceneChange(scenes.game)
				end
				if menu[menuPos] == "quit" then
					love.event.push("quit")
				end
				if menu[menuPos] == "options" then
					menu = optionsMenu
					menuPos = 1
				end
			end
		end
	end
	-- Now the options menu.
	optionsMenu = {
		name = "options",
		"theme",
		"[theme]",
		"segment",
		"[segment]",
		"glitch_fx",
		"[glitch]",
		"bloom_fx",
		"[bloom]",
		"restore",
		"back"
	}
	function optionsMenu:select(key)
		if menu ~= nil then
			if menu[menuPos] == "theme" then
				if key == "left" then
					options.theme = options.theme-1
					if options.theme < 1 then
						options.theme = #options.themeList
					end
				else
					options.theme = options.theme+1
					if options.theme > #options.themeList then
						options.theme = 1
					end
				end
			end
			if menu[menuPos] == "segment" then
				if key == "left" and segment > 0 then
					options.startseg = options.startseg - 1
				end
				if key == "right" then
					options.startseg = options.startseg + 1
				end
			end
			if menu[menuPos] == "restore" then
				configLoad()
			end
			if menu[menuPos] == "back" then
				configWrite()
				menu = mainMenu
				menuPos = 1
			end
			if menu[menuPos] == "glitch_fx" then
				if key == "left" then
					options.glitch = options.glitch-1
					if options.glitch < 1 then
						options.glitch = #options.glitchList
					end
				else
					options.glitch = options.glitch+1
					if options.glitch > #options.glitchList then
						options.glitch = 1
					end
				end
			end
			if menu[menuPos] == "bloom_fx" then
				if options.bloom then
					options.bloom = false
				else
					options.bloom = true
				end
			end
		end
	end
	--An array of special keywords.
	keywords = {
		["[theme]"] = function() return options.themeList[options.theme] end,
		["[segment]"] = function() return options.startseg end,
		["[glitch]"] = function() return options.glitchList[options.glitch] end,
		["[bloom]"] = function() return options.bloom end
}

	menu = mainMenu
	menuPos = 1
end

function menuScene:keypressed(key, scan)
	if menu ~= nil then
		if key=="lctrl" or key=="rctrl" or key=="ctrl" or key=="left" or key=="right" then
			menu:select(key)
		end
		if key=="down" or key=="s" then
			menuPos = menuPos + 1
			if menuPos > #menu then
				menuPos = 1
			end
		end
		if key=="up" or key=="w" then
			menuPos = menuPos - 1
			if menuPos < 1 then
				menuPos = #menu
			end
		end
		if key=="escape" then
			if menu == mainMenu then
				love.event.push("quit")
			else
				menu = mainMenu
			end
		end
	end
end

function menuScene:update()

end

function menuScene:draw()
	love.graphics.setCanvas(screen)
	love.graphics.clear()
	love.graphics.setShader()
	love.graphics.setFont(fonts.time)
	love.graphics.printf("SEGMENT16",0,love.graphics.getHeight()/2-128,love.graphics.getWidth(),"center")
	love.graphics.setFont(fonts.status)
	love.graphics.printf(menu.name,0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")
	for i, item in ipairs(menu) do
		if i == menuPos then 
			if halfSec > 0.25 then
				love.graphics.printf(">",-48,love.graphics.getHeight()/2+16*i,love.graphics.getWidth(),"center")
			else
				love.graphics.printf("-",-48,love.graphics.getHeight()/2+16*i,love.graphics.getWidth(),"center")
			end
		end
		if keywords[menu[i]] ~= nil then
			love.graphics.printf("["..tostring(keywords[menu[i]]()).."]",0,love.graphics.getHeight()/2+16*i,love.graphics.getWidth(),"center")
		else
			love.graphics.printf(menu[i],0,love.graphics.getHeight()/2+16*i,love.graphics.getWidth(),"center")
		end
	end
	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha","premultiplied")
	if options.bloom then
		love.graphics.setShader(bloomEffect)
	end
	love.graphics.draw(screen,love.graphics.getWidth()/2-300,0)
	love.graphics.setBlendMode("alpha")
end

function menuScene:unload()

end