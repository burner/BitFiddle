import std.traits : isIntegral;
import std.stdio;

private template upTo(T) {
	enum upTo = T.sizeof * 8UL;
}

private template minUnsignedIntegral(T) {
	static if(is(T == byte)) {
		alias minUnsignedIntegral = ubyte;
	} else static if(is(T == short)) {
		alias minUnsignedIntegral = ushort;
	} else static if(is(T == int)) {
		alias minUnsignedIntegral = uint;
	} else static if(is(T == long)) {
		alias minUnsignedIntegral = ulong;
	} else {
		alias minUnsignedIntegral = T;
	}
}

bool testBit(T)(T bitfield, const ulong idx) if(isIntegral!T) {
	return (cast(ulong)(bitfield) & (1UL << idx)) > 0UL;
}

bool testAnyBit(T)(T bitfield) if(isIntegral!T) {
	return bitfield != T.init;
}

bool testNoBit(T)(T bitfield) if(isIntegral!T) {
	return bitfield == T.init;
}

bool testAllBit(T)(T bitfield) if(isIntegral!T) {
	import std.traits : isUnsigned;
	return cast(minUnsignedIntegral!T)(bitfield) == minUnsignedIntegral!T.max;
}

unittest {
	import std.meta : AliasSeq;

	foreach(T; AliasSeq!(ubyte,ushort,uint,ulong)) {
		T min = T.min;
		T max = T.max;

		for(size_t i = 0; i < T.sizeof * 8; ++i) {
			assert(!testBit(min, i));
			assert(testBit(max, i));
		}
	}

	foreach(T; AliasSeq!(byte,short,int,long)) {
		T min = T.min;
		T max = T.max;

		for(size_t i = 0; i < (T.sizeof * 8) - 1; ++i) {
			assert(!testBit(min, i));
			assert(testBit(max, i));
		}
		assert(testBit(min, T.sizeof * 8 - 1));
		assert(!testBit(max, T.sizeof * 8 - 1));
	}
}

T setBit(T)(T bitfield, const ulong idx) if(isIntegral!T) {
	ulong value = cast(ulong)bitfield;
	ulong mask = 1UL << idx;
	value |= mask;
	return cast(T)value;
}

unittest {
	import std.meta : AliasSeq;

	foreach(T; AliasSeq!(ubyte,ushort,uint,ulong,byte,short,int,long)) {
		T v;
		assert(!testAnyBit(v));
		for(size_t i = 0; i < upTo!T; ++i) {
			assert(!testBit(v, i));
			v = setBit(v, i);
			assert(testAnyBit(v));
			for(size_t j = 0; j <= i; ++j) {
				assert(testBit(v, j));
			}
			for(size_t j = i + 1; j < upTo!T; ++j) {
				assert(!testBit(v, j));
			}
		}
	}
}

T setBit(T)(T bitfield, const ulong idx, bool value) if(isIntegral!T) {
	return cast(T)(cast(ulong)(bitfield) 
		^ (-cast(ulong)(value) ^ cast(ulong)(bitfield)) 
		& (1UL << idx));
}

unittest {
	import std.meta : AliasSeq;

	foreach(T; AliasSeq!(ubyte,ushort,uint,ulong,byte,short,int,long)) {
		T v;
		assert(!testAnyBit(v));
		for(size_t i = 0; i < upTo!T; ++i) {
			assert(!testBit(v, i));
			assert(!testAllBit(v));
			v = setBit(v, i, true);
			assert(!testNoBit(v));
			assert(testAnyBit(v));
			for(size_t j = 0; j <= i; ++j) {
				assert(testBit(v, j));
			}
			for(size_t j = i + 1; j < upTo!T; ++j) {
				assert(!testBit(v, j));
			}
		}
		assert(testAllBit(v));

		for(size_t i = 0; i < upTo!T; ++i) {
			assert(!testNoBit(v));
			assert(testBit(v, i));
			assert(testAnyBit(v));
			v = setBit(v, i, false);
			assert(!testAllBit(v));
			for(size_t j = 0; j <= i; ++j) {
				assert(!testBit(v, j));
			}
			for(size_t j = i + 1; j < upTo!T; ++j) {
				assert(testBit(v, j));
			}
		}
		assert(!testAnyBit(v));
		assert(testNoBit(v));
		assert(!testAllBit(v));
	}
}
