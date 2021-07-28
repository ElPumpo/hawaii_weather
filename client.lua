local isBlackoutEnabled, weatherChangeDuration, isChristmasParticlesEnabled, currentWeather, currentHour, currentMinute, isTimeFrozen = false, 30, false, 'CLEAR', 12, 0, false

Citizen.CreateThread(function()
	isBlackoutEnabled = GetConvar('weather_blackoutenabled', 'false') == 'true'
	isTimeFrozen = GetConvar('time_frozen', 'false') == 'true'
	currentHour = GetConvarInt('time_hour', 12)
	currentMinute = GetConvarInt('time_minute', 0)
	currentWeather = GetConvar('weather_currentweather', 'CLEAR')

	NetworkOverrideClockTime(currentHour, currentMinute, 0)
	SetMillisecondsPerGameMinute(isTimeFrozen and 999999999 or 1000)

	while true do
		Citizen.Wait(1000)
		SetArtificialLightsState(isBlackoutEnabled)
		UpdateWeatherParticles()

		if GetNextWeatherTypeHashName() ~= GetHashKey(currentWeather) then
			SetWeatherTypeOvertimePersist(currentWeather, weatherChangeDuration)
			Citizen.Wait(weatherChangeDuration * 1000 + 2000)
		end
	end
end)

-- override times every 10 minutes since it seems to desync if using /timefreeze
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10 * 60000)
		currentHour = GetConvarInt('time_hour', 12)
		currentMinute = GetConvarInt('time_minute', 0)

		NetworkOverrideClockTime(currentHour, currentMinute, 0)
		SetMillisecondsPerGameMinute(isTimeFrozen and 999999999 or 1000)
	end
end)

-- loads/unloads the snow fx particles if needed
function UpdateWeatherParticles()
	if currentWeather == 'XMAS' and not isChristmasParticlesEnabled then
		isChristmasParticlesEnabled = true
		SetForceVehicleTrails(true)
		SetForcePedFootstepsTracks(true)
		RequestScriptAudioBank('ICE_FOOTSTEPS', false) -- Icey footsteps
		RequestScriptAudioBank('SNOW_FOOTSTEPS', false) -- Snowy footsteps
		RequestNamedPtfxAsset('core_snow') -- Last part here is the blowing snow PTFX
		while not HasNamedPtfxAssetLoaded('core_snow') do Citizen.Wait(100) end
		UseParticleFxAssetNextCall('core_snow')
	elseif not currentWeather == 'XMAS' and isChristmasParticlesEnabled then
		isChristmasParticlesEnabled = false
		SetForceVehicleTrails(false)
		SetForcePedFootstepsTracks(false)
		ReleaseScriptAudioBank('ICE_FOOTSTEPS')
		ReleaseScriptAudioBank('SNOW_FOOTSTEPS')
		if HasNamedPtfxAssetLoaded('core_snow') then RemoveNamedPtfxAsset('core_snow') end
	end
end

RegisterNetEvent('hawaii_weather:setWeather')
AddEventHandler('hawaii_weather:setWeather', function(_currentWeather) currentWeather = _currentWeather end)

RegisterNetEvent('hawaii_weather:setTimeFrozen')
AddEventHandler('hawaii_weather:setTimeFrozen', function(_isTimeFrozen)
	isTimeFrozen = _isTimeFrozen
	SetMillisecondsPerGameMinute(isTimeFrozen and 999999999 or 1000)
end)

RegisterNetEvent('hawaii_weather:setBlackout')
AddEventHandler('hawaii_weather:setBlackout', function(_isBlackoutEnabled)
	isBlackoutEnabled = _isBlackoutEnabled
	SetArtificialLightsState(isBlackoutEnabled)
end)

RegisterNetEvent('hawaii_weather:setTime')
AddEventHandler('hawaii_weather:setTime', function(_currentHour, _currentMinute)
	currentHour, currentMinute = _currentHour, _currentMinute
	NetworkOverrideClockTime(currentHour, currentMinute, 0)
	SetMillisecondsPerGameMinute(isTimeFrozen and 999999999 or 1000)
end)