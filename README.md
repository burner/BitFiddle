BitFiddle
=========

![alt text](https://travis-ci.org/burner/BitFiddle.svg?branch=master)

Bit fiddle functions set set and test bits in integer


Functions
=========


Bit Testing Functions
---------------------
```d
bool testBit(T)(const T bitfield, const ulong idx) if(isIntegral!T);

bool testAnyBit(T)(const T bitfield) if(isIntegral!T);

bool testNoBit(T)(const T bitfield) if(isIntegral!T);

bool testAllBit(T)(const T bitfield) if(isIntegral!T);
```


Bit Setting Functions
---------------------
```d
T setBit(T)(const T bitfield, const ulong idx) if(isIntegral!T);

T setBit(T)(const T bitfield, const ulong idx, bool value) if(isIntegral!T);

T flipBit(T)(const T bitfield, const ulong idx) if(isIntegral!T);

T resetBit(T)(const T bitfield, const ulong idx) if(isIntegral!T);
```
