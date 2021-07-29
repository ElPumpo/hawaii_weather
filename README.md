# hawaii_weather

Best fivem weather sync code, period. It wont work without my ESX fork, unless you modify it yourself to include ESX imports the old way.

## Features

- My script uses a native that overrides how fast time pasts instead of overriding the current time which is causing the following issues:
  - shadows move in a fixed way
  - sun moves in a fixed way
  - water waves reset all the time
  - brightness to move in a fixed way between dusk and dawn
- Supports hot-restart of script without losing anything
- As it uses convars and reads them on script start you can override the weather and time as you like (see below)
- Weather sync is better. In many scripts if you drive too fast then the weather might change around, it shouldn’t happen with this code
- Clean and short source code, and performance is great

## How to have a fixed weather / time (useful for christmas season)

Add it to your server start configuration file before this script is started. The example shown below is what I use on my dev server.

```cfg
setr time_hour 12
setr time_minute 0
setr time_frozen "true"

setr weather_currentweather "EXTRASUNNY"
setr weather_dynamic "false"
```
