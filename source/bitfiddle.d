import std.traits : isIntegral;
import std.range.primitives : isOutputRange;
import std.stdio;

pure @safe @nogc nothrow {

private template upTo(T)
{
    enum upTo = T.sizeof * 8UL;
}

private template minUnsignedIntegral(T)
{
    static if (is(T == byte))
    {
        alias minUnsignedIntegral = ubyte;
    }
    else static if (is(T == short))
    {
        alias minUnsignedIntegral = ushort;
    }
    else static if (is(T == int))
    {
        alias minUnsignedIntegral = uint;
    }
    else static if (is(T == long))
    {
        alias minUnsignedIntegral = ulong;
    }
    else
    {
        alias minUnsignedIntegral = T;
    }
}

/** Tests if the bit `idx` is set in integer `bitfield`.
If `idx >= T.sizeof * 8` the bahaviour is undefined.

Params:
   bitfield = the integer containing bit to test
   idx = the index of the bit to test

Returns: `true` if the bit is set, `false` otherwise.
*/
bool testBit(T)(const T bitfield, const ulong idx) if (isIntegral!T)
{
    return (cast(ulong)(bitfield) & (1UL << idx)) > 0UL;
}

///
unittest
{
    int a = 0b0000_0000_0010_0001;
    assert(testBit(a, 0));
    assert(!testBit(a, 1));
    assert(testBit(a, 5));
    assert(!testBit(a, 6));
}

/** Tests if any bit is set in the integer `bitfield`.

Params:
   bitfield = the integer to test

Returns: `true` if any bit is set, `false otherwise.
*/
bool testAnyBit(T)(const T bitfield) if (isIntegral!T)
{
    return bitfield != T.init;
}

///
unittest
{
    int a = 0b0000_0000_0010_0001;
    int b = 0b0000_0000_0000_0000;
    assert(testAnyBit(a));
    assert(!testAnyBit(b));
}

/** Tests if no bit is set in the integer `bitfield`.

Params:
   bitfield = the integer to test

Returns: `true` if no bits are set, `false otherwise.
*/
bool testNoBit(T)(const T bitfield) if (isIntegral!T)
{
    return bitfield == T.init;
}

///
unittest
{
    int a = 0b0000_0000_0010_0001;
    int b = 0b0000_0000_0000_0000;
    assert(testAnyBit(a));
    assert(!testAnyBit(b));
}

/** Tests if all bits are set in the integer `bitfield`.

Params:
   bitfield = the integer to test

Returns: `true` if all bits are set, `false otherwise.
*/
bool testAllBit(T)(const T bitfield) if (isIntegral!T)
{
    return cast(minUnsignedIntegral!T)(bitfield) == minUnsignedIntegral!T.max;
}

///
unittest
{
    int a = 0b1111_1111_0010_1111;
    int b = 0b1111_1111_1111_1111;
    assert(!testAllBit(a));
    assert(testAnyBit(b));
}

unittest
{
    import std.meta : AliasSeq;

    foreach (T; AliasSeq!(ubyte, ushort, uint, ulong))
    {
        T min = T.min;
        T max = T.max;

        for (size_t i = 0; i < T.sizeof * 8; ++i)
        {
            assert(!testBit(min, i));
            assert(testBit(max, i));
        }
    }

    foreach (T; AliasSeq!(byte, short, int, long))
    {
        T min = T.min;
        T max = T.max;

        for (size_t i = 0; i < (T.sizeof * 8) - 1; ++i)
        {
            assert(!testBit(min, i));
            assert(testBit(max, i));
        }
        assert(testBit(min, T.sizeof * 8 - 1));
        assert(!testBit(max, T.sizeof * 8 - 1));
    }
}

/** Creates a copy of the integer `bitfield` and sets the bit `idx` in the
returned copy.  If `idx >= T.sizeof * 8` the bahaviour is undefined.

Params:
   bitfield = the integer to modify
   idx = the index of the bit to set

Returns: a copy of `bitfield` with bit `idx` set
*/
T setBit(T)(const T bitfield, const ulong idx) if (isIntegral!T)
{
    ulong value = cast(ulong) bitfield;
    ulong mask = 1UL << idx;
    value |= mask;
    return cast(T) value;
}

///
unittest
{
    int a = 0b0000_0000_0000_0000;
    int b = 0b0000_0000_0000_1000;
    a = setBit(a, 3);
    assert(a == b);
}

unittest
{
    import std.meta : AliasSeq;

    foreach (T; AliasSeq!(ubyte, ushort, uint, ulong, byte, short, int, long))
    {
        T v;
        assert(!testAnyBit(v));
        for (size_t i = 0; i < upTo!T; ++i)
        {
            assert(!testBit(v, i));
            v = setBit(v, i);
            assert(testAnyBit(v));
            for (size_t j = 0; j <= i; ++j)
            {
                assert(testBit(v, j));
            }
            for (size_t j = i + 1; j < upTo!T; ++j)
            {
                assert(!testBit(v, j));
            }
        }
    }
}

/** Creates a copy of the integer `bitfield` and sets the bit `idx` in the
returned copy to the passed `value`.  If `idx >= T.sizeof * 8` the bahaviour
is undefined.

Params:
   bitfield = the integer to modify
   idx = the index of the bit to set
   value = the value the `bit` `idx` should be set to. 
      `true == 1`, `false == 0`

Returns: a copy of `bitfield` with bit `idx` set to `value`
*/
T setBit(T)(const T bitfield, const ulong idx, bool value) if (isIntegral!T)
{
    return cast(T)(cast(ulong)(bitfield) ^ (-cast(ulong)(value) ^ cast(ulong)(bitfield)) & (
            1UL << idx));
}

///
unittest
{
    int a = 0b0000_0000_0000_0000;
    int b = 0b0000_0000_0000_1000;
    int c = setBit(a, 3, true);
    assert(c == b);

    c = setBit(a, 3, false);
    assert(c == a);
}

unittest
{
    import std.meta : AliasSeq;

    foreach (T; AliasSeq!(ubyte, ushort, uint, ulong, byte, short, int, long))
    {
        T v;
        assert(!testAnyBit(v));
        for (size_t i = 0; i < upTo!T; ++i)
        {
            assert(!testBit(v, i));
            assert(!testAllBit(v));
            v = setBit(v, i, true);
            assert(!testNoBit(v));
            assert(testAnyBit(v));
            for (size_t j = 0; j <= i; ++j)
            {
                assert(testBit(v, j));
            }
            for (size_t j = i + 1; j < upTo!T; ++j)
            {
                assert(!testBit(v, j));
            }
        }
        assert(testAllBit(v));

        for (size_t i = 0; i < upTo!T; ++i)
        {
            assert(!testNoBit(v));
            assert(testBit(v, i));
            assert(testAnyBit(v));
            v = setBit(v, i, false);
            assert(!testAllBit(v));
            assert(!testAllBit(v));
            for (size_t j = 0; j <= i; ++j)
            {
                assert(!testBit(v, j));
            }
            for (size_t j = i + 1; j < upTo!T; ++j)
            {
                assert(testBit(v, j));
            }
        }
        assert(!testAnyBit(v));
        assert(testNoBit(v));
        assert(!testAllBit(v));
    }
}

/** Creates a copy of the integer `bitfield` and flips the bit `idx` in the
returned copy.  If `idx >= T.sizeof * 8` the bahaviour is undefined.

Params:
   bitfield = the integer to modify
   idx = the index of the bit to flip

Returns: a copy of `bitfield` with bit `idx` flipped
*/
T flipBit(T)(const T bitfield, const ulong idx) if (isIntegral!T)
{
    return cast(T)(cast(ulong)(bitfield) ^ (1UL << idx));
}

///
unittest
{
    int a = 0b0000_0000_0000_0000;
    int b = 0b0000_0000_0000_1000;
    int c = flipBit(a, 3);
    assert(c == b);

    c = flipBit(c, 3);
    assert(c == a);
}

unittest
{
    import std.meta : AliasSeq;

    foreach (T; AliasSeq!(ubyte, ushort, uint, ulong, byte, short, int, long))
    {
        T v;
        assert(!testAnyBit(v));
        assert(testNoBit(v));
        for (size_t i = 0; i < upTo!T; ++i)
        {
            v = flipBit(v, i);
            assert(testBit(v, i));
            for (size_t j = 0; j < i; ++j)
            {
                assert(!testBit(v, j));
            }
            for (size_t j = i + 1; j < upTo!T; ++j)
            {
                assert(!testBit(v, j));
            }
            v = flipBit(v, i);
            assert(!testBit(v, i));
        }
    }
}

/** Creates a copy of the integer `bitfield` and set the bit `idx` in the
returned copy to `0`.  If `idx >= T.sizeof * 8` the bahaviour is undefined.

Params:
   bitfield = the integer to modify
   idx = the index of the bit to reset

Returns: a copy of `bitfield` with bit `idx` reset
*/
T resetBit(T)(const T bitfield, const ulong idx) if (isIntegral!T)
{
    return cast(T)(cast(ulong)(bitfield) & ~(1UL << idx));
}

///
unittest
{
    int a = 0b0000_0000_0000_1000;
    int b = 0b0000_0000_0000_0000;
    int c = resetBit(a, 3);
    assert(c == b);
}

unittest
{
    import std.meta : AliasSeq;

    foreach (T; AliasSeq!(ubyte, ushort, uint, ulong, byte, short, int, long))
    {
        T v;
        assert(!testAnyBit(v));
        assert(testNoBit(v));
        for (size_t i = 0; i < upTo!T; ++i)
        {
            v = setBit(v, i);
            assert(testBit(v, i));
            for (size_t j = 0; j < i; ++j)
            {
                assert(!testBit(v, j));
            }
            for (size_t j = i + 1; j < upTo!T; ++j)
            {
                assert(!testBit(v, j));
            }
            v = resetBit(v, i);
            assert(!testBit(v, i));
            assert(testNoBit(v));
            assert(!testAnyBit(v));
        }
    }
}

}

/** Converts a integer bitfield into a four bit at a time representation,
where every four bits are seperated by an underscore.
*/
void bitsPrettyPrint(T,Out)(const T value, ref Out output) 
	if (isIntegral!T && isOutputRange!(Out,string))
{
	import std.format : formattedWrite;	
	formattedWrite(output, "0b");
	
	const ulong mask = 0b0000_0000_0000_0000_0000_0000_0000_1111;
	const ulong sets  = T.sizeof * 2;

	ulong bitfield = cast(ulong)value;

	for (size_t i = 0; i < sets; ++i) 
	{
		if (i > 0)
		{
			formattedWrite(output, "_");
		}

		ulong shift = (sets - i - 1) * 4UL;
		
		formattedWrite(output, "%04b", (bitfield >> shift) & mask);
	}
}

/// ditto
string bitsPrettyPrint(T)(const T value) if (isIntegral!T)
{
	import std.array : appender;

	auto app = appender!string();
	app.reserve(2 + T.sizeof * 8 + (T.sizeof / 2));

	bitsPrettyPrint(value, app);

	return app.data;
}

///
unittest
{
	import std.conv : to;
	ubyte b = cast(ubyte)0b1000_0001;

	string s = bitsPrettyPrint(b);
	assert(s == "0b1000_0001");

	ushort shrt = cast(ushort)0b0000_0100_1000_0001;

	s = bitsPrettyPrint(shrt);
	assert(s == "0b0000_0100_1000_0001");
}
