debug = false
-- Other files.
require "player"
require "bads"
require "audio"
require "config"
--require "glowshade"
require "bloom"
require "fade"
require "glitch"
require "scenes.gamescene"
require "scenes.menuscene"
local anim8 = require "anim8"
local hc = require "HC"
local shape = require "HC.shapes"
-- Timers
segment = 0
round = 1
roundTimerMax = 15
roundTimer = roundTimerMax
-- Images

--Options
	options = {
		fonts = true,
		theme = 1,
		themeList = {"default","red","sol","old"},
		startseg = 0,
		glitch = 3,
		glitchList = {"off","low","high"},
		bloom = true
	}
-- Entity Lists
bullets = {}
bads = {} 
player = {}
fonts = {}
-- Other Lists
rotList = { up = 0, right = 0.5 * math.pi, down = math.pi, left = 1.5 * math.pi}
walls = { 1, 2, 4, 8}
wallRanges = { "up", "right", "down", "left" }
scenes = { game = gameScene, menu = menuScene }
-- Game status things
currentScene = nil
sceneIsNew=true
t = 0
rt = 0
f = 0
pause = false

-- Misc functions
function shuffle2(table)
	j,k = math.random(1, #table), math.random(1, #table)
	table[j], table[k] = table[k], table[j]
end

function shuffle(table)
	for i,thing in ipairs(table) do
		j = math.random(1,#table)
		if j > i then
			table[i],table[j] = table[j],table[i]
		end
	end
end

function sceneChange(scene)
	if currentScene ~= nil then
		currentScene:unload()
	end
	currentScene = scene
	sceneIsNew = true
end

function themeLoad(path)
	themeDir = 'assets/sprites/'..options.themeList[options.theme]
	if love.filesystem.isFile(themeDir..path) then
		sheet = love.graphics.newImage(themeDir..path)
	else
		sheet = love.graphics.newImage('assets/sprites/default'..path)
	end
	return sheet
end

function loadFonts()
	if options.fonts then 
		fonts.status = love.graphics.newFont('assets/Phoenix.ttf', 8)
		fonts.time = love.graphics.newFont('assets/Phoenix.ttf', 64)
	else 
		fonts.status = love.graphics.newFont(16)
		fonts.time = love.graphics.newFont(64)
	end
end

--Callbacks
function love.load(arg)
	configLoad()
	love.graphics.setDefaultFilter('nearest', 'nearest')
	love.graphics.setBackgroundColor(7, 54, 66)
  for i, opt in ipairs(arg) do
  	if opt == "-debug" then
  		debug = true
  	end
  	if opt == "-nofonts" then
  		options.fonts = false
  	end
  	if opt == "-seg" or opt == "-segment" then
  		segment = tonumber(arg[i+1])
  	end
  	if opt == "-rnd" or opt == "-round" then
  		round = tonumber(arg[i+1])
  	end
  	if opt == "-theme" then
  		options.theme = tonumber(arg[i+1])
  	end
  end
  loadFonts()
	--world = hc.new(64)
	scale = 1
	sceneChange(scenes.menu)
end

function love.keypressed(key, scan)
	if currentScene.keypressed ~= nil then
		currentScene:keypressed(key, scan)
	end
end

function love.update(dt)
	rt = rt + dt
	halfSecReal = rt%0.5
	if pause == false then
		t = t + dt
		halfSec = t%0.5
	end
	if sceneIsNew then
		currentScene:load()
		sceneIsNew = false
	end
	currentScene:update(dt)
end

function love.draw()
	f = f + 1
	currentScene:draw()
	--Now reset the color.
	love.graphics.setColor(255, 255, 255, 255)
end
