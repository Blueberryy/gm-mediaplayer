MediaPlayer.Services = {}

function MediaPlayer.RegisterService( service )

	local base

	if service.Base then
		base = MediaPlayer.Services[service.Base]
	elseif MediaPlayer.Services.base then
		base = MediaPlayer.Services.base
	end

	-- Inherit base service
	setmetatable( service, { __index = base } )

	-- Create base class for service
	baseclass.Set( "mp_service_" .. service.Id, service )

	-- Store service
	MediaPlayer.Services[ service.Id ] = service

	if MediaPlayer.DEBUG then
		print( "MediaPlayer.RegisterService", service.Name )
	end

end

function MediaPlayer.GetValidServiceNames( whitelist )
	local tbl = {}

	for _, service in pairs(MediaPlayer.Services) do
		if not rawget(service, "Abstract") then
			if whitelist then
				if table.HasValue( whitelist, service.Id ) then
					table.insert( tbl, service.Name )
				end
			else
				table.insert( tbl, service.Name )
			end
		end
	end

	return tbl
end

function MediaPlayer.ValidUrl( url )

	for id, service in pairs(MediaPlayer.Services) do
		if service:Match( url ) then
			return true
		end
	end

	return false

end

function MediaPlayer.GetMediaForUrl( url )

	local service

	for id, s in pairs(MediaPlayer.Services) do
		if s:Match( url ) then
			service = s
			break
		end
	end

	if not service then
		service = MediaPlayer.Services.base
	end

	return service:New( url )

end

-- Load services
do
	local path = "services/"

	local fullpath = "autorun/mediaplayer/" .. path

	local services = {
		"base", -- MUST LOAD FIRST!

		-- Browser
		"browser", -- base
		"youtube",
		"googledrive",
		"twitch",
		"twitchstream",
		"vimeo",

		-- HTML Resources
		"resource", -- base
		"image",
		"html5_video",

		-- IGModAudioChannel
		"audiofile",
		"shoutcast",
		"soundcloud"
	}

	for _, name in ipairs(services) do
		local clfile = path .. name .. "/cl_init.lua"
		local svfile = path .. name .. "/init.lua"
		local shfile = fullpath .. name .. ".lua"

		if file.Exists(shfile, "LUA") then
			clfile = shfile
			svfile = shfile
		end

		SERVICE = {}

		if SERVER then
			AddCSLuaFile(clfile)
			include(svfile)
		else
			include(clfile)
		end

		MediaPlayer.RegisterService( SERVICE )
		SERVICE = nil
	end
end