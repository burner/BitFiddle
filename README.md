BitFiddle
=========

![alt text](https://travis-ci.org/burner/BitFiddle.svg?branch=master)

Bit fiddle functions set set and test bits in integer


Functions
=========


Bit Testing Functions
---------------------
```d
bool testBit(T)(T bitfield, const ulong idx) if(isIntegral!T);

bool testAnyBit(T)(T bitfield) if(isIntegral!T);

bool testNoBit(T)(T bitfield) if(isIntegral!T);

bool testAllBit(T)(T bitfield) if(isIntegral!T);
```


Bit Setting Functions
---------------------
```d
T setBit(T)(T bitfield, const ulong idx) if(isIntegral!T);

T setBit(T)(T bitfield, const ulong idx, bool value) if(isIntegral!T);

T flipBit(T)(T bitfield, const ulong idx) if(isIntegral!T);

T resetBit(T)(T bitfield, const ulong idx) if(isIntegral!T);
```
