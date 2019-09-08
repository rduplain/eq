-- Visualize a stereo graphic equalizer.

------------------------
-- Globals: constants --
------------------------
BANDS = 10           -- Number of audio bands; must match FFT implementation.
BLOCKS = 10          -- Number of blocks to stack in representing a band.

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
-- Globals: love.update(dt)   --
--------------------------------
spectrum = {}        -- Spectrum data.

--------------------------------
-- Globals: love.resize(w, h) --
--------------------------------
window_w = nil       -- Width of window.
window_h = nil       -- Height of window.

unit_x = nil         -- Unit size in x dimension.
unit_y = nil         -- Unit size in y dimension.
side_padding = nil   -- Pixel padding on each side of window.
top_padding = nil    -- Pixel padding on top of window.

-- Initialize.
function love.load()
  love.window.setTitle('EQ')
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setColor(1, 1, 1)
  love.resize(love.window.getMode())
end

-- Update, on loop.
function love.update()
  -- TODO: Acquire data, 0 to 1 for each band.
  spectrum = {math.random(),
              math.random(),
              math.random(),
              math.random(),
              math.random(),
              math.random(),
              math.random(),
              math.random(),
              math.random(),
              math.random()}
end

-- Draw, on loop.
function love.draw()
  assert(#spectrum == BANDS)

  local block_w = SIZE_X * unit_x
  local block_h = SIZE_Y * unit_y

  for index, magnitude in ipairs(spectrum) do
    local item_x = index - 1
    local x = side_padding + (SPACER + item_x * (SIZE_X + SPACER)) * unit_x

    local blocks = round(magnitude * 10)

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
  window_w = w
  window_h = h

  unit_x, unit_y, side_padding, top_padding = measure_window(w, h)
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
