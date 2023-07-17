module big

import arrays
import math.bits

[direct_array_access]
fn integer_from_primitive_int[T](value T) Integer {
	$if value in [usize, isize] {
		value_size := sizeof(value)
		if value_size == sizeof(u32) {
			$if value is usize {
				return integer_from_primitive_int(u32(value))
			} $else $if value is isize {
				return integer_from_primitive_int(i32(value))
			} $else {
				return zero_int
			}
		} else {
			$if value is usize {
				return integer_from_primitive_int(u64(value))
			} $else $if value is isize {
				return integer_from_primitive_int(i64(value))
			} $else {
				return zero_int
			}
		}
	} $else $if value in [u64, i64] {
		// some explicit generic calls are needed here for inferrence
		absolute := $if value is i64 {
			u64(iabs[i64](i64(value)))
		} $else {
			u64(value)
		}

		lower := u32(absolute)
		upper := u32(absolute >> 32)

		return Integer {
			digits: if upper == 0 { [lower] } else { [lower, upper] },
			signum: isignum(value),
		}
	} $else $if value in [u8, i8, u16, i16, u32, i32, int] {
		absolute := $if value in [i8, i16, i32, int] {
			u32(iabs[i32](int(value)))
		} $else {
			u32(value)
		}
		return Integer {
			digits: [absolute],
			signum: isignum(value),
		}
	} $else {
		// unreachable - uncomment the line below once comptime conditionals are more stabilized
		// $compile_error('Unexpected integer type in call to integer_from_primitive_int. If you did not call this function directly, please report this as a bug.')
	}
	return zero_int
}

fn integer_from_array[T](value []T, cfg IntegerConfig) Integer {
	$if T is $array {
		integer_from_array[T](arrays.flatten(value), cfg)
	}

	$if T !is $int {
		$compile_error('math.big: Cannot convert from this array type')
	}

	$if T in [u8, u16, u32, u64, usize] {
		return match cfg.endianness {
			.little {
				integer_from_int_array_little_endian(value)
			}
			.big {
				integer_from_int_array_big_endian(value)
			}
		}
	} $else {
		panic('math.big: Signed integer array types are not allowed for Integer.from. If you did not pass a signed integer array type, this may be a bug.')
		// uncomment the line below and remove panic once comptime conditionals are more stabilized
		// $compile_error('math.big: Signed integer array types are not allowed for Integer.from. If you did not pass a signed integer array type, this may be a bug.')
	}
}

[direct_array_access]
fn integer_from_string_cfg(value string, cfg IntegerConfig) !Integer {
	$if debug {
		assert value.len > 0
	}

	lowerstr_sign := value.to_lower().trim_space()

	sign_present := lowerstr_sign[0] == `+` || lowerstr_sign[0] == `-`
	negative := if sign_present {
		lowerstr_sign[0] == `-`
	} else {
		false
	}

	lowerstr := lowerstr_sign[int(sign_present)..]

	// note: even if this function is only called from Integer.from which does a check for
	// value.len == 0, this check shouldn't be removed as it checks the trimmed string without
	// a sign indicator
	if lowerstr.len == 0 {
		return zero_int
	}

	if radix := cfg.radix {
		if 36 >= radix || radix >= 2 {
			validate_string(lowerstr, radix)!
			return if radix & (radix - 1) == 0 {
				integer_from_pow2_string(lowerstr, negative, bits.trailing_zeros_32(radix))
			} else {
				integer_from_regular_string(lowerstr, negative, radix)
			}
		} else {
			return error('radix must be between 2 and 36 (inclusive)')
		}
	}

	if cfg.infer_radix {
		// the first character may be a sign and not the prefix
		if lowerstr.len > 2 {
			match lowerstr[..2] {
				'0x', '0o', '0b' {
					chunks := match lowerstr[1] {
						`x` { 4 }
						`o` { 3 }
						`b` { 1 }
						else { 0 }
					}
					validate_string(lowerstr[2 ..], 1 << chunks)!
					return integer_from_pow2_string(lowerstr[2..], negative, chunks)
				}
				else {}
			}
		}
	}

	// default to base 10
	validate_string(lowerstr, 10)!
	return integer_from_regular_string(lowerstr, negative, 10)
}

[direct_array_access]
fn integer_from_int_array_big_endian[T](value []T) Integer {
	$if debug {
		assert value.len > 0
	}

	mut storage := []u32{}

	$if T is u32 {
		storage = value.reverse()
	} $else $if T in [u8, u16] {
		$if debug {
			assert digit_size > sizeof(T)
		}

		byteratio := int(digit_size / sizeof(T))

		$if debug {
			// due to how bit sizes differ we assert that byteratio is a power of 2
			assert byteratio & (byteratio - 1) == 0
		}

		storage = []u32{len: (value.len >> bits.trailing_zeros_32(u32(byteratio))) +
			int(value.len & (byteratio - 1) > 0)}

		unsafe {
			mut digit_ptr := &T(storage.data)
			for i := value.len - 1; i >= 0; i-- {
				*digit_ptr = value[i]
				digit_ptr++
			}
		}
	} $else {
		$if debug {
			assert sizeof(T) > digit_size
		}

		byteratio := int(sizeof(T) / digit_size)

		$if debug {
			assert byteratio > 0 && (byteratio & (byteratio - 1) == 0)
		}

		mut offset := 0
		for tmp := usize(value.last() >> (digit_size << 3)); tmp > 0; offset++ {
			tmp >>>= (digit_size << 3)
		}
		storage = []u32{len: (value.len * byteratio) - offset}

		// we multiply the index by the byteratio later, so to speed that up we can
		// get the amount of trailing zeros first, since byteratio is a power of 2
		shiftamount := bits.trailing_zeros_32(u32(byteratio))

		for i := 0; i < value.len; i++ {
			idx := int(u32(i) << shiftamount)
			// tmp is scoped to the inner for loop
			for tmp, j := usize(value[i]), 0; j < byteratio; j++ {
				storage[storage.len - (idx - j) - (~storage.len & 1) - 1] = u32(tmp)
				tmp >>>= (digit_size << 3)
			}
		}
	}

	return Integer {
		digits: storage
		signum: 1
	}
}

[direct_array_access]
fn integer_from_int_array_little_endian[T](value []T) Integer {
	$if debug {
		assert value.len > 0
	}

	mut storage := []u32{}

	$if T is u32 {
		storage = value.clone()
	} $else $if T in [u8, u16] {
		$if debug {
			assert digit_size > sizeof(T)
		}

		byteratio := int(digit_size / sizeof(T))

		$if debug {
			assert byteratio & (byteratio - 1) == 0
		}

		storage = []u32{len: (value.len >> bits.trailing_zeros_32(u32(byteratio))) +
			int(value.len & (byteratio - 1) > 0)}

		unsafe {
			mut digit_ptr := &T(storage.data)
			for i := 0; i < value.len; i++ {
				*digit_ptr = value[i]
				digit_ptr++
			}
		}
	} $else {
		$if debug {
			assert sizeof(T) > digit_size
		}

		byteratio := int(sizeof(T) / digit_size)

		$if debug {
			assert byteratio > 0 && (byteratio & (byteratio - 1) == 0)
		}

		mut offset := 0
		for tmp := usize(value.first() >> (digit_size << 3)); tmp > 0; offset++ {
			tmp >>>= (digit_size << 3)
		}
		storage = []u32{len: (value.len * byteratio) - offset}

		shiftamount := bits.trailing_zeros_32(u32(byteratio))

		for i := 0; i < value.len; i++ {
			idx := int(u32(i) << shiftamount)
			for tmp, j := usize(value[i]), 0; j < byteratio; j++ {
				storage[idx + j] = u32(tmp)
				tmp >>>= (digit_size << 3)
			}
		}
	}

	return Integer {
		digits: storage
		signum: 1
	}
}
