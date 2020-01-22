## EQ: Visualize a stereo graphic equalizer.

### Usage

With [LÖVE](https://love2d.org/) 11.3:

```sh
love .
```


### Signal Processing

This project includes its own Lua implementations of the [discrete Fourier
transform][DFT] and [signal window functions][Hann]. A custom implementation
serves both to eliminate project dependencies -- that of an external Fast
Fourier Transform (FFT) library -- and to demonstrate how these algorithms
work. The implementations in [dft.lua](./dft.lua) are faithful digital signal
processing algorithms, but the project makes some optimizations toward the goal
of a simple visualization:

* The `dft.transform` implementation assumes real-only valued input (because
  that's true for audio) and does not include an inverse transform.
* The `dft.transform` implementation supports discarding bins that would
  otherwise not get visualized, namely the 0Hz DC bin and all bins above the
  Nyquist limit.

Altogether, the project serves as one of education and demonstration, not a
professional tool for audio applications.

[DFT]: https://en.wikipedia.org/wiki/Discrete_Fourier_transform
[Hann]: https://en.wikipedia.org/wiki/Window_function#Hann_and_Hamming_windows
