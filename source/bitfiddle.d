import std.traits : isIntegral;
import std.stdio;

private template upTo(T) {
	enum upTo = T.sizeof * 8UL;
}

bool testBit(T)(T bitfield, const ulong idx) if(isIntegral!T) {
	return (cast(ulong)(bitfield) & (1UL << idx)) > 0UL;
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
		for(size_t i = 0; i < upTo!T; ++i) {
			assert(!testBit(v, i));
			v = setBit(v, i);
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
		for(size_t i = 0; i < upTo!T; ++i) {
			assert(!testBit(v, i));
			v = setBit(v, i, true);
			for(size_t j = 0; j <= i; ++j) {
				assert(testBit(v, j));
			}
			for(size_t j = i + 1; j < upTo!T; ++j) {
				assert(!testBit(v, j));
			}
		}

		for(size_t i = 0; i < upTo!T; ++i) {
			assert(testBit(v, i));
			v = setBit(v, i, false);
			for(size_t j = 0; j <= i; ++j) {
				assert(!testBit(v, j));
			}
			for(size_t j = i + 1; j < upTo!T; ++j) {
				assert(testBit(v, j));
			}
		}
	}
}
