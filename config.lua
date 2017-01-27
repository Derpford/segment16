saveDir = love.filesystem.getSaveDirectory()
confLocation = "conf.ini"
defaultConfig = [[fonts true
theme 1
segment 0
glitchfx 3
bloomfx true]]

configOptions = {
	["fonts"] = function(arg) options.fonts = arg end,
	["theme"] = function(arg) options.theme = arg end,
	["segment"] = function(arg) options.startseg = arg end,
	["glitchfx"] = function(arg) options.glitch = arg end,
	["bloomfx"] = function(arg) options.bloom = arg end
}

function configLoad()
	configFile = love.filesystem.newFile(confLocation)
	print(confLocation)
	if love.filesystem.exists(confLocation) and love.filesystem.isFile(confLocation) then
		print("Found config!")
		configFile:open("r")
		for line in love.filesystem.lines("conf.ini") do
			configArgs = {}
			for word in string.gmatch(line, "[^%s]+") do
				table.insert(configArgs, word)
			end
			if configArgs[2] == "true" then
				configArgs[2] = true
			else
				if configArgs[2] == "false" then
					configArgs[2] = false
				else
					configArgs[2] = tonumber(configArgs[2])
				end
			end
			print(tostring(configArgs[1])..":"..tostring(configArgs[2]))
			if configOptions[configArgs[1]] ~= nil then
				configOptions[configArgs[1]](configArgs[2])
			end
		end
		configFile:close()
	else
		configFile:close()
		print("Making config!")
		configCreate()
	end
end

function configCreate()
	configFile = love.filesystem.newFile(confLocation)
	print("File loading...")
	fileOpened, errOpen = configFile:open("w")
	print("File load: "..tostring(fileOpened)..", "..tostring(errOpen))
	result, errWrite = configFile:write(defaultConfig)
	print(defaultConfig.."\r\n--finished: "..tostring(result)..", "..tostring(errWrite))
	configFile:close()
end

function configWrite()
	configFile = love.filesystem.newFile(confLocation)
	configFile:open("w")
	optionsString = "fonts "..tostring(options.fonts).."\r\ntheme "..tostring(options.theme).."\r\nsegment "..tostring(options.startseg).."\r\nglitchfx "..tostring(options.glitch).."\r\nbloomfx "..tostring(options.bloom)
	print(optionsString)
	configFile:write(optionsString)
	configFile:close()
end


