# hawaii_weather

Best FiveM weather script, period. It wont work without my ESX fork out of the box.

## Features

- My script slows down the game time instead of constantly setting the game time. Constantly setting the game time causes a lot of issues:
  - all shadows and the sun teleport
  - water waves resets all the time makes it look flat and boring
  - dusk and dawn brightness changes are terrible
- Supports hot-restart of script. Time, weather and everything else are saved convars that are read on script start
- As it uses convars and reads them on script start you can override the weather and time as you like (see below)
- Weather sync is better. In many scripts if you drive too fast then the weather might change around, it shouldn’t happen with this code
- Short, clean and easy source code, no fast loops and performance is great

## How to have a fixed weather / time (useful for christmas season)

Add it to your server start configuration file before this script is started. The example shown below is what I use on my dev server.

```cfg
setr time_hour 12
setr time_minute 0
setr time_frozen "true"

setr weather_currentweather "EXTRASUNNY"
setr weather_dynamic "false"
```

## Credits

Credits goes to the developer of vMenu for the weather change code, it's mostly a copy of his.
