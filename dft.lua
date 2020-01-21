-- Discrete Fourier Transform (DFT) for simple spectrum visualization.

local dft = {}

-- Transform real-valued time-domain samples to complex-valued frequency.
--
-- Use 0-index for array.
-- Only support transform from time to frequency, no inverse.
-- Only support real-valued input.
--
-- DFT:
-- https://en.wikipedia.org/wiki/Discrete_Fourier_transform
--
-- Visualize each step:
-- https://jackschaedler.github.io/circles-sines-signals/dft_walkthrough.html
function dft.transform(samples)
  local n = #samples
  local real = {}
  local imag = {}

  if n == 0 then
    return real, imag
  else
    for k = 0, n-1 do -- output
      local sum_real = 0
      local sum_imag = 0
      for t = 0, n-1 do -- input
        local angle = 2 * math.pi * t * k / n
        sum_real = sum_real + samples[t] * math.cos(angle)
        sum_imag = sum_imag - samples[t] * math.sin(angle)
      end
      real[k] = sum_real
      imag[k] = sum_imag
    end
    return real, imag
  end
end

-- Calculate signal magnitude in relevant bins: 1 to n/2.
--
-- Use 0-index for input array.
-- In effect, 1 to n/2 makes the output array 1-indexed.
-- Ignore 0th bin, the DC bin, as it has no frequency content.
-- Ignore bins n/2+1 to n, as these are past the Nyquist limit.
--
-- Determining frequencies of bins:
-- https://jackschaedler.github.io/circles-sines-signals/dft_frequency.html
function dft.bins(real, imag)
  assert(#real == #imag)
  assert(#real > 0)

  local n = #real
  local magnitude = {}

  for k = 1, n/2 do
    magnitude[k] = math.sqrt(real[k] * real[k] + imag[k] * imag[k])
  end

  return magnitude
end

-- Apply generalized Hann/Hamming window to sampled signal.
--
-- Use 0-index for input array.
-- Modify array in place.
--
-- https://en.wikipedia.org/wiki/Window_function#Hann_and_Hamming_windows
function dft.window(samples, a)
  local n = #samples

  for t = 0, n-1 do
    local coef = a - (1 - a) * math.cos(2 * math.pi * t / (n-1))
    samples[t] = coef * samples[t]
  end

  return samples
end

-- Apply Hann window to sampled signal.
function dft.hann(samples)
  return dft.window(samples, 0.5)
end

-- Apply Hamming window to sampled signal.
function dft.hamming(samples)
  return dft.window(samples, 25/46)
end

-- Generate test tone with n samples and given period.
--
-- Period indicates number of periods within the sample length.
function dft.test_tone(period, n)
  local samples = {}

  for i = 0, n-1 do
    samples[i] = math.sin(period * 2 * math.pi * i / n)
  end

  return samples
end

-- Dump sampled signal.
function dft.dump_samples(samples, title)
  print(title)
  for t, value in ipairs(samples) do
    print(t.."\t"..value)
  end
end

-- Dump transform of given sampled signal.
function dft.dump_transform(samples, title)
  print(title)
  local bins = dft.bins(dft.transform(samples))
  for k, magnitude in ipairs(bins) do
    print(k.."\t"..magnitude)
  end
end

-- Test tones of various periods and windows.
function dft.test()
  local n = 22

  local function tone(period)
    return dft.test_tone(period, n)
  end

  for _, p in ipairs({3, 2.7}) do
    dft.dump_samples(tone(p),           "## tone w/period: "..p.." ##")
    dft.dump_samples(dft.hann(tone(p)), "## tone w/period: "..p..", Hann ##")

    dft.dump_transform(tone(p),              "## period: "..p.." ##")
    dft.dump_transform(dft.hann(tone(p)),    "## period: "..p..", Hann ##")
    dft.dump_transform(dft.hamming(tone(p)), "## period: "..p..", Hamming ##")
  end
end

return dft
