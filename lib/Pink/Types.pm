use Pink::Dict;

my enum PrimitiveType is export <
    i8 i16 i32 i64
    u8 u16 u32 u64
    f32 f64
    int uint ptr
>;

my class StructMember is export {
    has $.name;
    has $.type;
}

my class StructType is export {
    has $.name;
    has $.members = dict;
}

proto ctype($) is export {*}

multi ctype(i8)  { 'int8_t' }
multi ctype(i16) { 'int16_t' }
multi ctype(i32) { 'int32_t' }
multi ctype(i64) { 'int64_t' }

multi ctype(u8)  { 'uint8_t' }
multi ctype(u16) { 'uint16_t' }
multi ctype(u32) { 'uint32_t' }
multi ctype(u64) { 'uint64_t' }

multi ctype(f32) { 'float' }
multi ctype(f64) { 'double' }

multi ctype(int)  { 'intptr_t' }
multi ctype(uint) { 'uintptr_t' }
multi ctype(ptr)  { 'void*' }
