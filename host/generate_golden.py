import numpy as np
from pathlib import Path

N = 1024
out = Path(".")

k = np.arange(N//2)
wr = np.cos(2*np.pi*k/N)
wi = np.sin(2*np.pi*k/N)

def float_to_q15(x):
    x = np.clip(x, -0.999969, 0.999969)
    return np.round(x * (2**15 - 1)).astype(np.int16)

wr_q15 = float_to_q15(wr)
wi_q15 = float_to_q15(wi)

def to_hex_lines(arr):
    # two's complement hex, width=16
    return [f"{(int(x) & 0xFFFF):04x}" for x in arr]

(out / "twiddle_wr_q15.hex").write_text("\n".join(to_hex_lines(wr_q15)))
(out / "twiddle_wi_q15.hex").write_text("\n".join(to_hex_lines(wi_q15)))

np.random.seed(0)
x = (np.random.randn(N) + 1j*np.random.randn(N)).astype(np.complex64)
X = np.fft.fft(x)

np.save("golden_x_complex64.npy", x)
np.save("golden_X_complex64.npy", X)

def c64_to_q15_pairs(z):
    re = float_to_q15(np.real(z))
    im = float_to_q15(np.imag(z))
    return re, im

re, im = c64_to_q15_pairs(x/np.max(np.abs(x)) * 0.9)
np.savetxt("input_q15_re.txt", re, fmt="%d")
np.savetxt("input_q15_im.txt", im, fmt="%d")

print("OK: wrote twiddle_wr_q15.hex, twiddle_wi_q15.hex, and golden vectors.")
