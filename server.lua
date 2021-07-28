local isDynamicWeatherEnabled, isBlackoutEnabled, dynamicWeatherDuration, currentWeather, lastWeatherChange, currentHour, currentMinute, isTimeFrozen = true, false, 7 * 60000, 'CLEAR', 0, 12, 0, false

local validWeatherTypes = {
	'EXTRASUNNY',     'CLEAR',     'NEUTRAL',     'SMOG',     'FOGGY',     'OVERCAST',     'CLOUDS',     'CLEARING',
	'RAIN',     'THUNDER',     'SNOW',     'BLIZZARD',     'SNOWLIGHT',     'XMAS',     'HALLOWEEN',
}

-- loop used for syncing and changing weather dynamically
Citizen.CreateThread(function()
	isBlackoutEnabled = GetConvar('weather_blackoutenabled', 'false') == 'true'
	isTimeFrozen = GetConvar('time_frozen', 'false') == 'true'
	currentHour = GetConvarInt('time_hour', 12)
	currentMinute = GetConvarInt('time_minute', 0)
	currentWeather = GetConvar('weather_currentweather', 'CLEAR')
	isDynamicWeatherEnabled = GetConvar('weather_dynamic', 'true') == 'true'

	while true do
		if isDynamicWeatherEnabled then
			Citizen.Wait(dynamicWeatherDuration)

			-- disable dynamic weather because these weather types shouldn't randomly change
			if currentWeather == 'XMAS' or currentWeather == 'HALLOWEEN' or currentWeather == 'NEUTRAL' then
				isDynamicWeatherEnabled = false
				SetConvarReplicated('weather_dynamic', isDynamicWeatherEnabled)
			else
				-- is it time to generate a new weather typeand
				if GetGameTimer() - lastWeatherChange > dynamicWeatherDuration then
					RefreshWeather()
				end
			end
		else
			Citizen.Wait(5000)
		end
	end
end)

-- loop used for syncing and keeping track of the time in-game
-- it is not being sent to the clients, only to new connected clients. then all clients can count themselves
Citizen.CreateThread(function()
	while true do
		if not isTimeFrozen then
			if currentMinute + 1 > 59 then
				currentMinute = 0

				if currentHour + 1 > 23 then
					currentHour = 0
				else
					currentHour = currentHour + 1
				end
			else
				currentMinute = currentMinute + 1
			end
		end

		SetConvarReplicated('time_hour', tostring(currentHour))
		SetConvarReplicated('time_minute', tostring(currentMinute))
		Citizen.Wait(1000) -- one ingame minute take two real seconds
	end
end)

--select a new random weather type, based on the current weather and some patterns
function RefreshWeather()
	lastWeatherChange = GetGameTimer()
	local random = math.random(0, 20)

	if currentWeather == 'RAIN' or currentWeather == 'THUNDER' then
		currentWeather = 'CLEARING'
	elseif currentWeather == 'CLEARING'then
		currentWeather = 'CLOUDS'
	else
		if random == 5 then
			currentWeather = (currentWeather == 'EXTRASUNNY' and 'CLEAR' or 'EXTRASUNNY')
		elseif random == 8 then
			currentWeather = (currentWeather == 'SMOG' and 'FOGGY' or 'SMOG')
		elseif random == 11 then
			currentWeather = (currentWeather == 'CLOUDS' and 'OVERCAST' or 'CLOUDS')
		elseif random == 14 then
			currentWeather = (currentWeather == 'CLOUDS' and 'OVERCAST' or 'CLOUDS')
		elseif random == 15 then
			currentWeather = (currentWeather == 'OVERCAST' and 'THUNDER' or 'OVERCAST')
		elseif random == 16 then
			currentWeather = (currentWeather == 'CLOUDS' and 'EXTRASUNNY' or 'RAIN')
		end
	end

	TriggerClientEvent('hawaii_weather:setWeather', -1, currentWeather)
	SetConvarReplicated('weather_currentweather', currentWeather)
end

ESX.RegisterCommand('weather', {'staff_level_5', 'dev_level_1'}, function(xPlayer, args, showError)
	local validWeatherType = false

	for k,v in ipairs(validWeatherTypes) do
		if v == string.upper(args.weatherType) then
			validWeatherType = true
			break
		end
	end

	if validWeatherType then
		showError('Weather will change to ' .. string.lower(args.weatherType))
		currentWeather = string.upper(args.weatherType)
		lastWeatherChange = GetGameTimer()
		TriggerClientEvent('hawaii_weather:setWeather', -1, currentWeather)
		SetConvarReplicated('weather_currentweather', currentWeather)
	else
		showError('Invalid weather type')
	end
end, true, {help = 'Change the weather', validate = true, arguments = {
	{name = 'weatherType', help = 'extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, snow, blizzard, snowlight, xmas, halloween', type = 'string'}
}})

ESX.RegisterCommand('weatherfreeze', {'staff_level_5', 'dev_level_1'}, function(xPlayer, args, showError)
	isDynamicWeatherEnabled = not isDynamicWeatherEnabled
	showError(isDynamicWeatherEnabled and 'Dynamic weather changes are now enabled' or 'Dynamic weather changes are now disabled')
	SetConvarReplicated('weather_dynamic', isDynamicWeatherEnabled)
end, true, {help = 'Toggle freezing time'})

ESX.RegisterCommand('timefreeze', {'staff_level_5', 'dev_level_1'}, function(xPlayer, args, showError)
	isTimeFrozen = not isTimeFrozen
	showError(isTimeFrozen and 'Time is now frozen' or 'Time is no longer frozen')
	TriggerClientEvent('hawaii_weather:setTimeFrozen', -1, isTimeFrozen)
	SetConvarReplicated('time_frozen', tostring(isTimeFrozen))

	Citizen.Wait(2000)
	TriggerClientEvent('hawaii_weather:setTime', -1, currentHour, currentMinute)
end, true, {help = 'Toggle freezing time'})

ESX.RegisterCommand('blackout', {'staff_level_5', 'dev_level_1'}, function(xPlayer, args, showError)
	isBlackoutEnabled = not isBlackoutEnabled
	showError(isBlackoutEnabled and 'Power blackout is now on' or 'Power blackout is now off')
	TriggerClientEvent('hawaii_weather:setBlackout', -1, isBlackoutEnabled)
	SetConvarReplicated('weather_blackoutenabled', tostring(isBlackoutEnabled))
end, true, {help = 'Toggle power blackout'})

ESX.RegisterCommand('time', 'staff_level_5', function(xPlayer, args, showError)
	currentHour = args.hour
	currentMinute = args.minute
	showError('Time was altered')
	TriggerClientEvent('hawaii_weather:setTime', -1, currentHour, currentMinute)
	SetConvarReplicated('time_hour', tostring(currentHour))
	SetConvarReplicated('time_minute', tostring(currentMinute))
end, true, {help = 'Set time', validate = true, arguments = {
	{name = 'hour', help = 'Hour', type = 'number', min = 0, max = 23},
	{name = 'minute', help = 'Minute', type = 'number', min = 0, max = 59}
}})