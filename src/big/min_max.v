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

