function audioLoad(arg)
	musicTracks = {up = love.audio.newSource('assets/audio/music/segment16loop-bass.ogg'),
	right = love.audio.newSource('assets/audio/music/segment16loop-lead.ogg'),
	down = love.audio.newSource('assets/audio/music/segment16loop-back.ogg'),
	left = love.audio.newSource('assets/audio/music/segment16loop-alt.ogg')}
	volumeMin = 0.3
	volumeMax = 1
	for i, song in pairs(musicTracks) do
		song:setVolume(volumeMin)
	end
end

function resetMusic()
	for i, song in pairs(musicTracks) do
		--song:setVolume(volumeMin)
		song:stop()
		song:play()
	end
end

function playMusic()
	for i, song in pairs(musicTracks) do
		song:play()
	end
end

function stopMusic()
	for i, song in pairs(musicTracks) do
		song:stop()
	end
end

function audioUpdate(dt)
	--resetMusic()
	playMusic()
	for i, wall in ipairs(walls) do
		result = bit.band(round, wall)
			if result > 0 then
				if wallRanges[i] == "up" then
					if musicTracks.up:getVolume() < volumeMax then 
						musicTracks.up:setVolume(musicTracks.up:getVolume() + dt)	
					end
				end
				if wallRanges[i] == "down" then
					if musicTracks.down:getVolume() < volumeMax then 
						musicTracks.down:setVolume(musicTracks.down:getVolume() + dt)	
					end
				end
				if wallRanges[i] == "left" then
					if musicTracks.left:getVolume() < volumeMax then 
						musicTracks.left:setVolume(musicTracks.left:getVolume() + dt)	
					end
				end
				if wallRanges[i] == "right" then
					if musicTracks.right:getVolume() < volumeMax then 
						musicTracks.right:setVolume(musicTracks.right:getVolume() + dt)	
					end
				end
			else if result == 0 then
				if wallRanges[i] == "up" then
					if musicTracks.up:getVolume() > volumeMin then 
						musicTracks.up:setVolume(musicTracks.up:getVolume() - dt)	
					end
				end
				if wallRanges[i] == "down" then
					if musicTracks.down:getVolume() > volumeMin then 
						musicTracks.down:setVolume(musicTracks.down:getVolume() - dt)	
					end
				end
				if wallRanges[i] == "left" then
					if musicTracks.left:getVolume() > volumeMin then 
						musicTracks.left:setVolume(musicTracks.left:getVolume() - dt)	
					end
				end
				if wallRanges[i] == "right" then
					if musicTracks.right:getVolume() > volumeMin then 
						musicTracks.right:setVolume(musicTracks.right:getVolume() - dt)	
					end
				end
			end
		end
	end
	--playMusic()
end