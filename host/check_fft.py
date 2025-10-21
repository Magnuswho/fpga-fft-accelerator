import argparse, sys
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

# ---------- Fixed-point helpers ----------
SCALE_Q15 = (2**15 - 1)

def q15_to_float(xi: np.ndarray) -> np.ndarray:
    return xi.astype(np.float32) / SCALE_Q15

def float_to_q15(xf: np.ndarray) -> np.ndarray:
    x = np.clip(xf, -0.999969, 0.999969)
    return np.round(x * SCALE_Q15).astype(np.int16)

# ---------- Metrics ----------
def metrics(y_ref: np.ndarray, y_hat: np.ndarray) -> dict:
    """y_ref, y_hat: complex64 arrays same length."""
    assert y_ref.shape == y_hat.shape
    err = y_hat - y_ref
    pow_signal = np.sum(np.abs(y_ref)**2) + 1e-12
    mse = np.mean(np.abs(err)**2)
    rmse = np.sqrt(mse)
    snr_db = 10.0 * np.log10(pow_signal / (mse * len(y_ref)))
    max_abs_err = np.max(np.abs(err))
    mre = np.mean(np.abs(err) / (np.abs(y_ref) + 1e-12))
    return {
        "N": y_ref.size,
        "SNR_dB": float(snr_db),
        "RMSE": float(rmse),
        "MaxAbsErr": float(max_abs_err),
        "MeanRelErr": float(mre),
    }

# ---------- I/O ----------
def load_q15_pair(re_path: Path, im_path: Path) -> np.ndarray:
    re = np.loadtxt(re_path, dtype=np.int16)
    im = np.loadtxt(im_path, dtype=np.int16)
    xf = q15_to_float(re) + 1j * q15_to_float(im)
    return xf.astype(np.complex64)

def save_plots(x_time, X_ref, X_hat, outdir: Path, tag: str):
    outdir.mkdir(parents=True, exist_ok=True)

    # 1) Magnitude spectra overlay
    plt.figure()
    plt.title(f"FFT magnitude (|X|) — {tag}")
    plt.plot(np.abs(X_ref), label="ref (NumPy)")
    plt.plot(np.abs(X_hat), label="device")
    plt.xlabel("Bin")
    plt.ylabel("|X|")
    plt.legend()
    plt.tight_layout()
    plt.savefig(outdir / f"mag_overlay_{tag}.png")
    plt.close()

    # 2) Error histogram
    err = X_hat - X_ref
    plt.figure()
    plt.title(f"Real-part error histogram — {tag}")
    plt.hist(np.real(err), bins=64)
    plt.xlabel("Error (real)")
    plt.ylabel("Count")
    plt.tight_layout()
    plt.savefig(outdir / f"err_hist_real_{tag}.png")
    plt.close()

    plt.figure()
    plt.title(f"Imag-part error histogram — {tag}")
    plt.hist(np.imag(err), bins=64)
    plt.xlabel("Error (imag)")
    plt.ylabel("Count")
    plt.tight_layout()
    plt.savefig(outdir / f"err_hist_imag_{tag}.png")
    plt.close()

def main():
    p = argparse.ArgumentParser(description="FFT result checker")
    p.add_argument("--in-re", type=Path, default=Path("fft_out_q15_re.txt"),
                   help="Q15 int16 real-part output file from your FFT")
    p.add_argument("--in-im", type=Path, default=Path("fft_out_q15_im.txt"),
                   help="Q15 int16 imag-part output file from your FFT")
    p.add_argument("--golden-x", type=Path, default=Path("golden_x_complex64.npy"),
                   help="Original input used to compute NumPy FFT")
    p.add_argument("--golden-X", type=Path, default=Path("golden_X_complex64.npy"),
                   help="NumPy FFT(reference). If missing, will compute from golden-x.")
    p.add_argument("--tag", type=str, default="run1", help="Label for saved plots")
    p.add_argument("--demo", action="store_true",
                   help="No hardware output? Emulate device by quantizing NumPy FFT to Q15 & back.")
    args = p.parse_args()

    # Load golden input
    if not args.golden_x.exists():
        print("Golden input not found. Generate it first: python host/generate_golden.py", file=sys.stderr)
        sys.exit(1)
    x = np.load(args.golden_x).astype(np.complex64)

    # Load or compute golden FFT
    if args.golden_X.exists():
        X_ref = np.load(args.golden_X).astype(np.complex64)
    else:
        X_ref = np.fft.fft(x).astype(np.complex64)

    # Load device result
    if args.demo:
        # Emulate an on-device Q1.15 round-trip to validate checker
        # (Quantize complex FFT result to Q15 per component, then de-quantize)
        Xq = q15_to_float(float_to_q15(np.real(X_ref))) + 1j * q15_to_float(float_to_q15(np.imag(X_ref)))
        X_hat = Xq.astype(np.complex64)
    else:
        if not args.in_re.exists() or not args.in_im.exists():
            print("Device output not found. Provide --in-re and --in-im or use --demo.", file=sys.stderr)
            sys.exit(2)
        X_hat = load_q15_pair(args.in_re, args.in_im)

    # Metrics
    m = metrics(X_ref, X_hat)
    print("=== FFT Checker ===")
    for k, v in m.items():
        print(f"{k}: {v}")

    # Save a few plots
    save_plots(np.arange(x.size), X_ref, X_hat, Path("results"), args.tag)
    print("Saved plots to results/. Files:")
    print(f" - results/mag_overlay_{args.tag}.png")
    print(f" - results/err_hist_real_{args.tag}.png")
    print(f" - results/err_hist_imag_{args.tag}.png")

if __name__ == "__main__":
    main()
