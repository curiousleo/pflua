# net ::0/16


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 7
002: A = P[22:4]
003: if (A & 4294901760 != 0) goto 4 else goto 6
004: A = P[38:4]
005: if (A & 4294901760 != 0) goto 7 else goto 6
006: return 65535
007: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==34525) then goto L6 end
   if 26 > length then return false end
   A = bit.bor(bit.lshift(P[22], 24),bit.lshift(P[22+1], 16), bit.lshift(P[22+2], 8), P[22+3])
   if (bit.band(A, -65536)==0) then goto L5 end
   if 42 > length then return false end
   A = bit.bor(bit.lshift(P[38], 24),bit.lshift(P[38+1], 16), bit.lshift(P[38+2], 8), P[38+3])
   if not (bit.band(A, -65536)==0) then goto L6 end
   ::L5::
   do return true end
   ::L6::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local band = require("bit").band
local cast = require("ffi").cast
return function(P,length)
   if length < 54 then return false end
   if cast("uint16_t*", P+12)[0] ~= 56710 then return false end
   if band(cast("uint32_t*", P+22)[0],65535) == 0 then return true end
   return band(cast("uint32_t*", P+38)[0],65535) == 0
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 53
  br i1 %2, label %L4, label %L8

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, -8826
  br i1 %6, label %L6, label %L8

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 22
  %8 = bitcast i8* %7 to i32*
  %9 = load i32* %8, align 4, !tbaa !5
  %10 = and i32 %9, 65535
  %11 = icmp eq i32 %10, 0
  br i1 %11, label %L8, label %L9

L8:                                               ; preds = %L1, %L4, %L6
  %merge = phi i1 [ true, %L6 ], [ false, %L4 ], [ false, %L1 ]
  ret i1 %merge

L9:                                               ; preds = %L6
  %12 = getelementptr inbounds i8* %0, i64 38
  %13 = bitcast i8* %12 to i32*
  %14 = load i32* %13, align 4, !tbaa !5
  %15 = and i32 %14, 65535
  %16 = icmp eq i32 %15, 0
  ret i1 %16
}


```
