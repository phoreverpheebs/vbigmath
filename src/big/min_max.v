module big

[inline]
fn max[T](a T, b T) T {
	return if a > b { a } else { b }
}

[inline]
fn min[T](a T, b T) T {
	return if a < b { a } else { b }
}

[inline]
fn iabs[T](v T) usize {
	$if T in [u8, u16, u32, u64, usize] {
		return usize(v)
	} $else {
		return if v > 0 { usize(v) } else { usize(-v) }
	}
}

// Returns integer signum with 0 check
//
// This is done using a signed right shift to fill the entire integer with the
// sign bit, meaning that if the sign bit is negative (1) the entire integer will be -1
// in two's complement. The conversion of boolean to parameter type ensures that the
// least significant bit gets set if the input is positive, therefore allowing for a 0 check.
[inline]
fn isignum[T](v T) int {
	$if v in [u8, u16, u32, u64, usize] {
		return 1
	} $else {
		return int((v >> ((sizeof(T) * 8) - 1)) | T(v > 0))
	}
}

[inline]
fn flip_endian[T](v T) T {
	$if v is u64 {
		$if amd64 {
			mut r := u64(v)
			asm amd64 {
				bswap a
				; =r (r) as a
			}
			return r
		} $else {
			return ((v & 0xff00000000000000) >> 56)
					| ((v & 0xff000000000000) >> 40)
					| ((v & 0xff0000000000) >> 24)
					| ((v & 0xff00000000) >> 8)
					| ((v & 0xff000000) << 8)
					| ((v & 0xff0000) << 24)
					| ((v & 0xff00) << 40)
					| (v << 56)
		}
		// compiler complains
		return 0
	} $else $if v is u32 {
		$if amd64 {
			mut r := u32(v)
			asm amd64 {
				bswap a
				; =r (r) as a
			}
			return r
		} $else {
			return ((v & 0xff000000) >> 24)
					| ((v & 0xff0000) >> 8)
					| ((v & 0xff00) << 8)
					| (v << 24)
		}
		return 0
	} $else $if v is u16 {
		return (v >> 8) | (v << 8)
	} $else {
		$compile_error('math.big: flip_endian not implemented for the given type')
	}
}
