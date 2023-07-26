module main

import big

struct IntegerRadix {
	digit_string string
	radix        u32
}

type TestInteger = IntegerRadix | []u8 | []u16 | []u32 | []u64 | big.Integer | i64 | int | string | u32 | u64

struct IntegerFromTest {
	value    TestInteger
	expected string // prefix with 0x for hex
}

fn (a TestInteger) parse(cfg big.IntegerConfig) big.Integer {
	return match a {
		big.Integer {
			a
		}
		string {
			big.Integer.from[string](a, cfg) or { panic(err) }
		}
		int {
			big.Integer.from[int](a, cfg) or { panic(err) }
		}
		u32 {
			big.Integer.from[u32](a, cfg) or { panic(err) }
		}
		u64 {
			big.Integer.from[u64](a, cfg) or { panic(err) }
		}
		i64 {
			big.Integer.from[i64](a, cfg) or { panic(err) }
		}
		[]u8 {
			big.Integer.from[[]u8](a, cfg) or { panic(err) }
		}
		[]u16 {
			big.Integer.from[[]u16](a, cfg) or { panic(err) }
		}
		[]u32 {
			big.Integer.from[[]u32](a, cfg) or { panic(err) }
		}
		[]u64 {
			big.Integer.from[[]u64](a, cfg) or { panic(err) }
		}
		IntegerRadix {
			big.Integer.from[string](a.digit_string, radix: a.radix) or { panic(err) }
		}
	}
}

const integer_from_int_test_data = [
	// use int
	IntegerFromTest{ 0, '0' },
	IntegerFromTest{ 1, '1' },
	IntegerFromTest{ 255, '255' },
	IntegerFromTest{ 127, '127' },
	IntegerFromTest{ 1024, '1024' },
	IntegerFromTest{ 2147483647, '0x7fffffff' },
]

const integer_from_u64_test_data = [
	// use u64
	IntegerFromTest{ u64(0), '0' },
	IntegerFromTest{ u64(1), '1' },
	IntegerFromTest{ u64(255), '255' },
	IntegerFromTest{ u64(127), '127' },
	IntegerFromTest{ u64(1024), '1024' },
	IntegerFromTest{ u64(4294967295), '0xffffffff' },
	IntegerFromTest{ u64(4398046511104), '0x40000000000' },
	IntegerFromTest{ u64(-1), '0xffffffffffffffff' },
]

const integer_from_array_u8_big_test_data = [
	// use []u8
	IntegerFromTest{ []u8{}, '0' },
	IntegerFromTest{ [u8(0)], '0' },
	IntegerFromTest{ [u8(0x13)], '0x13' },
	IntegerFromTest{ [u8(0x13), 0x37], '0x1337' },
	IntegerFromTest{ [u8(0x13), 0x37, 0xca], '0x1337ca' },
	IntegerFromTest{ [u8(0x13), 0x37, 0xca, 0xfe], '0x1337cafe' },
	IntegerFromTest{ [u8(0x13), 0x37, 0xca, 0xfe, 0xba], '0x1337cafeba' },
	IntegerFromTest{ [u8(0x13), 0x37, 0xca, 0xfe, 0xba, 0xbe], '0x1337cafebabe' },
	IntegerFromTest{ [u8(0x13), 0x37, 0xca, 0xfe, 0xba, 0xbe, 0xde], '0x1337cafebabede' },
	IntegerFromTest{ [u8(0x13), 0x37, 0xca, 0xfe, 0xba, 0xbe, 0xde, 0xad], '0x1337cafebabedead' },
	IntegerFromTest{ [u8(0x13), 0x37, 0xca, 0xfe, 0xba, 0xbe, 0xde, 0xad, 0xbe], '0x1337cafebabedeadbe' },
	IntegerFromTest{ [u8(0x13), 0x37, 0xca, 0xfe, 0xba, 0xbe, 0xde, 0xad, 0xbe, 0xef], '0x1337cafebabedeadbeef' },
]

const integer_from_array_u16_big_test_data = [
	// use []u16
	IntegerFromTest{ []u16{}, '0' },
	IntegerFromTest{ [u16(0)], '0' },
	IntegerFromTest{ [u16(0x13)], '0x13' },
	IntegerFromTest{ [u16(0x1337)], '0x1337' },
	IntegerFromTest{ [u16(0x1337), 0xca], '0x133700ca' },
	IntegerFromTest{ [u16(0x1337), 0xcafe], '0x1337cafe' },
	IntegerFromTest{ [u16(0x1337), 0xcafe, 0xba], '0x1337cafe00ba' },
	IntegerFromTest{ [u16(0x13), 0x37ca, 0xfeba], '0x1337cafeba' },
	IntegerFromTest{ [u16(0x1337), 0xcafe, 0xbabe], '0x1337cafebabe' },
]

const integer_from_array_u32_big_test_data = [
	// use []u32
	IntegerFromTest{ []u32{}, '0' },
	IntegerFromTest{ [u32(0)], '0' }
	IntegerFromTest{ [u32(0x13)], '0x13' }
	IntegerFromTest{ [u32(0x1337)], '0x1337' }
	IntegerFromTest{ [u32(0x1337ca)], '0x1337ca' }
	IntegerFromTest{ [u32(0x1337cafe)], '0x1337cafe' }
	IntegerFromTest{ [u32(0x1337cafe), 0xba], '0x1337cafe000000ba' }
	IntegerFromTest{ [u32(0x1337cafe), 0xbabe], '0x1337cafe0000babe' }
	IntegerFromTest{ [u32(0x1337cafe), 0xbabe00], '0x1337cafe00babe00' }
	IntegerFromTest{ [u32(0x1337cafe), 0xbabe0000], '0x1337cafebabe0000' }
	IntegerFromTest{ [u32(0x1337cafe), 0xbabede00], '0x1337cafebabede00' }
	IntegerFromTest{ [u32(0x1337cafe), 0xbabedead], '0x1337cafebabedead' }
	IntegerFromTest{ [u32(0x1337cafe), 0xbabedead, 0xbe], '0x1337cafebabedead000000be' }
	IntegerFromTest{ [u32(0x1337cafe), 0xbabedead, 0xbeeeeeef], '0x1337cafebabedeadbeeeeeef' }
]

const integer_from_array_u64_big_test_data = [
	// use []u64
	IntegerFromTest{ []u64{}, '0' },
	IntegerFromTest{ [u64(0)], '0' }
	IntegerFromTest{ [u64(0x13)], '0x13' }
	IntegerFromTest{ [u64(0x1337)], '0x1337' }
	IntegerFromTest{ [u64(0x1337ca)], '0x1337ca' }
	IntegerFromTest{ [u64(0x1337cafe)], '0x1337cafe' }
	IntegerFromTest{ [u64(0x1337cafeba)], '0x1337cafeba' }
	IntegerFromTest{ [u64(0x1337cafebabe)], '0x1337cafebabe' }
	IntegerFromTest{ [u64(0x1337cafebabede)], '0x1337cafebabede' }
	IntegerFromTest{ [u64(0x1337cafebabedead)], '0x1337cafebabedead' }
	IntegerFromTest{ [u64(0x1337cafebabedead), 0xbe], '0x1337cafebabedead00000000000000be' }
	IntegerFromTest{ [u64(0x1337cafebabedead), 0xbeef], '0x1337cafebabedead000000000000beef' }
	IntegerFromTest{ [u64(0x13), 0x37cafebabedeadbe], '0x1337cafebabedeadbe' }
	IntegerFromTest{ [u64(0x1337), 0xcafebabedeadbeef], '0x1337cafebabedeadbeef' }
]

const integer_from_array_u8_little_test_data = [
	// use []u8
	IntegerFromTest{ []u8{}, '0' },
	IntegerFromTest{ [u8(0)], '0' },
	IntegerFromTest{ [u8(0x13)], '0x13' },
	IntegerFromTest{ [u8(0x37), 0x13], '0x1337' },
	IntegerFromTest{ [u8(0xca), 0x37, 0x13], '0x1337ca' },
	IntegerFromTest{ [u8(0xfe), 0xca, 0x37, 0x13], '0x1337cafe' },
	IntegerFromTest{ [u8(0xba), 0xfe, 0xca, 0x37, 0x13], '0x1337cafeba' },
	IntegerFromTest{ [u8(0xbe), 0xba, 0xfe, 0xca, 0x37, 0x13], '0x1337cafebabe' },
	IntegerFromTest{ [u8(0xde), 0xbe, 0xba, 0xfe, 0xca, 0x37, 0x13], '0x1337cafebabede' },
	IntegerFromTest{ [u8(0xad), 0xde, 0xbe, 0xba, 0xfe, 0xca, 0x37, 0x13], '0x1337cafebabedead' },
	IntegerFromTest{ [u8(0xbe), 0xad, 0xde, 0xbe, 0xba, 0xfe, 0xca, 0x37, 0x13], '0x1337cafebabedeadbe' },
	IntegerFromTest{ [u8(0xef), 0xbe, 0xad, 0xde, 0xbe, 0xba, 0xfe, 0xca, 0x37, 0x13], '0x1337cafebabedeadbeef' },
]

const integer_from_array_u16_little_test_data = [
	// use []u16
	IntegerFromTest{ []u16{}, '0' },
	IntegerFromTest{ [u16(0)], '0' },
	IntegerFromTest{ [u16(0x13)], '0x13' },
	IntegerFromTest{ [u16(0x1337)], '0x1337' },
	IntegerFromTest{ [u16(0x37ca), 0x13], '0x1337ca' },
	IntegerFromTest{ [u16(0xcafe), 0x1337], '0x1337cafe' },
	IntegerFromTest{ [u16(0xfeba), 0x37ca, 0x13], '0x1337cafeba' },
	IntegerFromTest{ [u16(0xbabe), 0xcafe, 0x1337], '0x1337cafebabe' },
]

const integer_from_array_u32_little_test_data = [
	// use []u32
	IntegerFromTest{ []u32{}, '0' },
	IntegerFromTest{ [u32(0)], '0' }
	IntegerFromTest{ [u32(0x13)], '0x13' }
	IntegerFromTest{ [u32(0x1337)], '0x1337' }
	IntegerFromTest{ [u32(0x1337ca)], '0x1337ca' }
	IntegerFromTest{ [u32(0x1337cafe)], '0x1337cafe' }
	IntegerFromTest{ [u32(0x37cafeba), 0x13], '0x1337cafeba' }
	IntegerFromTest{ [u32(0xcafebabe), 0x1337], '0x1337cafebabe' }
	IntegerFromTest{ [u32(0xfebabede), 0x1337ca], '0x1337cafebabede' }
]

const integer_from_array_u64_little_test_data = [
	// use []u64
	IntegerFromTest{ []u64{}, '0' },
	IntegerFromTest{ [u64(0)], '0' }
	IntegerFromTest{ [u64(0x13)], '0x13' }
	IntegerFromTest{ [u64(0x1337)], '0x1337' }
	IntegerFromTest{ [u64(0x1337ca)], '0x1337ca' }
	IntegerFromTest{ [u64(0x1337cafe)], '0x1337cafe' }
	IntegerFromTest{ [u64(0x1337cafeba)], '0x1337cafeba' }
	IntegerFromTest{ [u64(0x1337cafebabe)], '0x1337cafebabe' }
	IntegerFromTest{ [u64(0x1337cafebabede)], '0x1337cafebabede' }
	IntegerFromTest{ [u64(0x1337cafebabedead)], '0x1337cafebabedead' }
	IntegerFromTest{ [u64(0x37cafebabedeadbe), 0x13], '0x1337cafebabedeadbe' }
	IntegerFromTest{ [u64(0xcafebabedeadbeef), 0x1337], '0x1337cafebabedeadbeef' }
]

const integer_from_string_test_data = [
	// use string
	IntegerFromTest{ '00000000', '0' },
	IntegerFromTest{ '00', '0' },
	IntegerFromTest{ '0', '0' },
	IntegerFromTest{ '1', '1' },
	IntegerFromTest{ '0012', '12' },
	IntegerFromTest{ '1349173614', '1349173614' },
	IntegerFromTest{ '+24', '24' },
	IntegerFromTest{ '-325', '-325' },
	IntegerFromTest{ '-2147483648', '-2147483648' },
	IntegerFromTest{ '2147483647', '2147483647' },
	IntegerFromTest{ '0x7fffffff', '2147483647' },
	IntegerFromTest{ '0xffffffff', '4294967295' },
	IntegerFromTest{ '0xffffffffffffffff', '18446744073709551615' }
	IntegerFromTest{ '0b'+'1'.repeat(64), '18446744073709551615' }
	IntegerFromTest{ '0b'+'1'.repeat(32), '4294967295'  }
	IntegerFromTest{ '0b'+'01'.repeat(32), '6148914691236517205' }
	IntegerFromTest{ '0o76543210', '16434824' }
	IntegerFromTest{ '0o77', '63' }
]

const integer_from_radix_test_data = [
	// use IntegerRadix
	IntegerFromTest{ IntegerRadix{ '101010', 2 }, '42' },
	IntegerFromTest{ IntegerRadix{ '1010', 2 }, '10' },
	IntegerFromTest{ IntegerRadix{ '-0000101', 2 }, '-5' },
	IntegerFromTest{ IntegerRadix{ 'CAFE', 16 }, '0xcafe' },
	IntegerFromTest{ IntegerRadix{ 'DED', 16 }, '0xded' },
	IntegerFromTest{ IntegerRadix{ '-abcd', 16 }, '-43981' },
]

struct Implementor {
	value []u8
}

pub fn (a Implementor) to_bytes() []u8 {
	return a.value
}

fn test_method() {
	a := Implementor { value: [u8(0xfe), 0xca] }
	assert big.Integer.from[Implementor](a) or { panic(err) }.hex() == 'cafe'
}

[assert_continues]
fn main() {
	for test_data in [
		integer_from_int_test_data,
		integer_from_u64_test_data,
		integer_from_string_test_data,
		integer_from_radix_test_data,
	] {
		for t in test_data {
			result := t.value.parse()
			assert t.expected.trim_string_left('0x') == if t.expected.starts_with('0x') {
				result.hex()
			} else {
				result.str()
			}
		}
	}

	// big endian tests
	for test_data in [
		integer_from_array_u8_big_test_data,
		integer_from_array_u16_big_test_data,
		integer_from_array_u32_big_test_data,
		integer_from_array_u64_big_test_data,
	] {
		for t in test_data {
			result := t.value.parse(endianness: .big)
			assert t.expected.trim_string_left('0x') == if t.expected.starts_with('0x') {
				result.hex()
			} else {
				result.str()
			}
		}
	}

	// little endian tests
	for test_data in [
		integer_from_array_u8_little_test_data,
		integer_from_array_u16_little_test_data,
		integer_from_array_u32_little_test_data,
		integer_from_array_u64_little_test_data,
	] {
		for t in test_data {
			result := t.value.parse(endianness: .little)
			assert t.expected.trim_string_left('0x') == if t.expected.starts_with('0x') {
				result.hex()
			} else {
				result.str()
			}
		}
	}

	assert big.Integer.from(u64(-1)) or { panic(err) }.hex() == 'ffffffffffffffff'
	assert big.Integer.from(i64(u64(1) << 63)) or { panic(err) }.hex() == '-8000000000000000'
	assert big.Integer.from(u64(0)) or { panic(err) }.str() == '0'
	assert big.Integer.from(i64(-1)) or { panic(err) }.str() == '-1'

	assert big.Integer.from(i64(-420), big.IntegerConfig{ signum: -1 }) or { panic(err) }.str() == '420'

	assert big.Integer.from([u32(1)]) or { panic(err) }.str() == '1'

	test_method()
}
