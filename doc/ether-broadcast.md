# ether broadcast


## BPF

```
000: A = P[2:4]
001: if (A == 4294967295) goto 2 else goto 5
002: A = P[0:2]
003: if (A == 65535) goto 4 else goto 5
004: return 65535
005: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 6 > length then return false end
   A = bit.bor(bit.lshift(P[2], 24),bit.lshift(P[2+1], 16), bit.lshift(P[2+2], 8), P[2+3])
   if not (A==-1) then goto L4 end
   if 2 > length then return false end
   A = bit.bor(bit.lshift(P[0], 8), P[0+1])
   if not (A==65535) then goto L4 end
   do return true end
   ::L4::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local cast = require("ffi").cast
return function(P,length)
   if length < 6 then return false end
   if cast("uint16_t*", P+0)[0] ~= 65535 then return false end
   return cast("uint32_t*", P+2)[0] == 4294967295
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 5
  br i1 %2, label %L4, label %L7

L4:                                               ; preds = %L1
  %3 = bitcast i8* %0 to i16*
  %4 = load i16* %3, align 2, !tbaa !1
  %5 = icmp eq i16 %4, -1
  br i1 %5, label %L6, label %L7

L6:                                               ; preds = %L4
  %6 = getelementptr inbounds i8* %0, i64 2
  %7 = bitcast i8* %6 to i32*
  %8 = load i32* %7, align 4, !tbaa !5
  %9 = icmp eq i32 %8, -1
  ret i1 %9

L7:                                               ; preds = %L1, %L4
  ret i1 false
}


```
