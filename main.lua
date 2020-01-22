-- Visualize a stereo graphic equalizer.

dft = require('dft')

------------------------
-- Globals: constants --
------------------------
BANDS = 10           -- Number of audio bands.
BLOCKS = 10          -- Number of blocks to stack in representing a band.

BINS = BANDS         -- Number of frequency bins in data visualization.
BINS = BINS + 1      -- Add bin to Fourier output in order to drop DC 0Hz bin.
BINS = BINS + 1      -- Add bin to drop highest frequency bin from visual.
BINS = BINS * 2      -- Double to allow dropping the half above Nyquist limit.

SAMPLE_RATE = 22050  -- Mic sample rate, Hz; determines bin values.
BIT_DEPTH = 16       -- Number of bits of information in each mic sample.
CHANNELS = 1         -- Mono: 1 channel.

BIN_CUTOFF = 2       -- Frequency power considered "max"; tunes sensitivity.

SPACER = 1           -- Number of units of space between blocks.
SIZE_X = 10          -- Number of units for width of blocks.
SIZE_Y = 10          -- Number of units for height of blocks.

-- Thresholds and colors for blocks.
MILD_COLOR = {0, .9, 0}
MEDIUM_COUNT = 3
MEDIUM_COLOR = {1, .647, 0}
HOT_COUNT = 2
HOT_COLOR = {.9, 0, 0}

--------------------------------
-- Globals: I/O               --
--------------------------------
mic = nil            -- Handle to mic recording device.

--------------------------------
-- Globals: love.update(dt)   --
--------------------------------
samples = {}         -- Samples from mic recording device.
spectrum = {}        -- Spectrum data of length BANDS with values 0 to 10.

--------------------------------
-- Globals: love.resize(w, h) --
--------------------------------
window_h = nil       -- Height of window.

unit_x = nil         -- Unit size in x dimension.
unit_y = nil         -- Unit size in y dimension.
side_padding = nil   -- Pixel padding on each side of window.

-- Initialize.
function love.load()
  stderr('EQ: Visualize a stereo graphic equalizer.\n')

  -- Initialize LÖVE window and graphics.
  love.window.setTitle('EQ')
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setColor(1, 1, 1)
  love.resize(love.window.getMode())

  -- Initialize spectrum data.
  spectrum = {}
  for i = 1, BANDS do
    spectrum[i] = 0
  end

  -- Find mic and set its recording buffer size to number of bins.
  -- Note: Sound card may have a recording device to monitor its own output.
  --       This may be preferred, and is especially useful for testing.
  --       Set `mic = devices[x]` to a higher index as available.
  local devices = love.audio.getRecordingDevices()
  assert(#devices > 0)
  mic = devices[1]
  mic:start(BINS, SAMPLE_RATE, BIT_DEPTH, CHANNELS)

  -- Report I/O detail and fundamental frequency (interval of bins).
  stderr('Microphone:            '..mic:getName())
  stderr('Channels:              '..mic:getChannelCount())
  stderr('Bit-Depth:             '..mic:getBitDepth())
  stderr('Sample Rate:           '..mic:getSampleRate())
  stderr('Fundamental Frequency: '..string.format('%.2f', SAMPLE_RATE/BINS))
end

-- Update, on loop.
function love.update()
  if mic:getSampleCount() >= BINS then
    -- Sound device has enough samples for visualization.
    local data = mic:getData()

    for i = 0, BINS-1 do
      samples[i] = data:getSample(i)
    end

    local real, imag = dft.transform(dft.hann(samples), 1, BANDS)
    local bins = dft.bins(real, imag, 1, BANDS)

    for i = 1, BANDS do
      local bin = bins[i]
      if bin >= BIN_CUTOFF then
        bin = 10
      else
        bin = 10 * bin / BIN_CUTOFF
      end
      spectrum[i] = bin
    end
  end
end

-- Draw, on loop.
function love.draw()
  assert(#spectrum == BANDS)

  local block_w = SIZE_X * unit_x
  local block_h = SIZE_Y * unit_y

  for index, magnitude in ipairs(spectrum) do
    local item_x = index - 1
    local x = side_padding + (SPACER + item_x * (SIZE_X + SPACER)) * unit_x

    local blocks = round(magnitude)

    for item_y = 1, blocks do
      local color
      if item_y > (BLOCKS - HOT_COUNT) then
        color = HOT_COLOR
      elseif item_y > (BLOCKS - HOT_COUNT - MEDIUM_COUNT) then
        color = MEDIUM_COLOR
      else
        color = MILD_COLOR
      end
      love.graphics.setColor(unpack(color))

      local y = window_h - (SPACER + item_y * (SIZE_Y + SPACER)) * unit_y

      love.graphics.rectangle('fill', x, y, block_w, block_h)
    end
  end
end

-- Callback, on window resize.
function love.resize(w, h)
  _ = w
  window_h = h

  unit_x, unit_y, side_padding, _ = measure_window(w, h)
end

-- Scale size of unit in two dimensions, with padding on top and side.
function measure_window(w, h)
  local units_x = SPACER + BANDS * (SIZE_X + SPACER)
  local units_y = SPACER + BLOCKS * (SIZE_Y + SPACER)

  local unit_x = math.floor(w / units_x)
  local unit_y = math.floor(h / units_y)

  local side_padding = math.floor((w - (units_x * unit_x)) / 2)
  local top_padding = h - (units_y * unit_y)

  return unit_x, unit_y, side_padding, top_padding
end

-- Round to the nearest integer.
function round(x)
  local offset, integer
  if x < 0 then offset = -0.5 else offset = 0.5 end
  integer, _ = math.modf(x + offset)
  return integer
end

-- Print to standard error.
function stderr(x)
  if x == nil then x = '' end
  io.stderr:write(x, '\n')
end
