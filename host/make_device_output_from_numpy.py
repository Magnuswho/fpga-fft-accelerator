import numpy as np
from pathlib import Path

SCALE = (2**15 - 1)

def float_to_q15(x):
    x = np.clip(x, -0.999969, 0.999969)
    return np.round(x * SCALE).astype(np.int16)

golden_X = Path("golden_X_complex64.npy")
if not golden_X.exists():
    raise SystemExit("golden_X_complex64.npy not found. Run: python host/generate_golden.py")

X = np.load(golden_X).astype(np.complex64)
re = float_to_q15(np.real(X))
im = float_to_q15(np.imag(X))

np.savetxt("fft_out_q15_re.txt", re, fmt="%d")
np.savetxt("fft_out_q15_im.txt", im, fmt="%d")
print("Wrote: fft_out_q15_re.txt, fft_out_q15_im.txt")
