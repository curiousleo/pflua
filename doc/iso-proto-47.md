# iso proto 47


## BPF

```
000: A = P[12:2]
001: if (A > 1500) goto 7 else goto 2
002: A = P[14:2]
003: if (A == 65278) goto 4 else goto 7
004: A = P[17:1]
005: if (A == 47) goto 6 else goto 7
006: return 65535
007: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if (runtime_u32(A)>1500) then goto L6 end
   if 16 > length then return false end
   A = bit.bor(bit.lshift(P[14], 8), P[14+1])
   if not (A==65278) then goto L6 end
   if 18 > length then return false end
   A = P[17]
   if not (A==47) then goto L6 end
   do return true end
   ::L6::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local rshift = require("bit").rshift
local bswap = require("bit").bswap
local cast = require("ffi").cast
return function(P,length)
   if length < 18 then return false end
   if rshift(bswap(cast("uint16_t*", P+12)[0]), 16) > 1500 then return false end
   if cast("uint16_t*", P+14)[0] ~= 65278 then return false end
   return P[17] == 47
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 17
  br i1 %2, label %L4, label %L9

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = tail call zeroext i16 @ntohs(i16 zeroext %5)
  %7 = icmp ult i16 %6, 1501
  br i1 %7, label %L6, label %L9

L6:                                               ; preds = %L4
  %8 = getelementptr inbounds i8* %0, i64 14
  %9 = bitcast i8* %8 to i16*
  %10 = load i16* %9, align 2, !tbaa !1
  %11 = icmp eq i16 %10, -258
  br i1 %11, label %L8, label %L9

L8:                                               ; preds = %L6
  %12 = getelementptr inbounds i8* %0, i64 17
  %13 = load i8* %12, align 1, !tbaa !5
  %14 = icmp eq i8 %13, 47
  ret i1 %14

L9:                                               ; preds = %L1, %L4, %L6
  ret i1 false
}


```
