# src net ffff:ffff:eeee:eeee:0:0:0:0/72


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 9
002: A = P[22:4]
003: if (A == 4294967295) goto 4 else goto 9
004: A = P[26:4]
005: if (A == 4008636142) goto 6 else goto 9
006: A = P[30:4]
007: if (A & 4278190080 != 0) goto 9 else goto 8
008: return 65535
009: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==34525) then goto L8 end
   if 26 > length then return false end
   A = bit.bor(bit.lshift(P[22], 24),bit.lshift(P[22+1], 16), bit.lshift(P[22+2], 8), P[22+3])
   if not (A==-1) then goto L8 end
   if 30 > length then return false end
   A = bit.bor(bit.lshift(P[26], 24),bit.lshift(P[26+1], 16), bit.lshift(P[26+2], 8), P[26+3])
   if not (A==-286331154) then goto L8 end
   if 34 > length then return false end
   A = bit.bor(bit.lshift(P[30], 24),bit.lshift(P[30+1], 16), bit.lshift(P[30+2], 8), P[30+3])
   if not (bit.band(A, -16777216)==0) then goto L8 end
   do return true end
   ::L8::
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
   if cast("uint32_t*", P+22)[0] ~= 4294967295 then return false end
   if cast("uint32_t*", P+26)[0] ~= 4008636142 then return false end
   return band(cast("uint32_t*", P+30)[0],255) == 0
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 53
  br i1 %2, label %L4, label %L11

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, -8826
  br i1 %6, label %L6, label %L11

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 22
  %8 = bitcast i8* %7 to i32*
  %9 = load i32* %8, align 4, !tbaa !5
  %10 = icmp eq i32 %9, -1
  br i1 %10, label %L8, label %L11

L8:                                               ; preds = %L6
  %11 = getelementptr inbounds i8* %0, i64 26
  %12 = bitcast i8* %11 to i32*
  %13 = load i32* %12, align 4, !tbaa !5
  %14 = icmp eq i32 %13, -286331154
  br i1 %14, label %L10, label %L11

L10:                                              ; preds = %L8
  %15 = getelementptr inbounds i8* %0, i64 30
  %16 = bitcast i8* %15 to i32*
  %17 = load i32* %16, align 4, !tbaa !5
  %18 = and i32 %17, 255
  %19 = icmp eq i32 %18, 0
  ret i1 %19

L11:                                              ; preds = %L1, %L4, %L6, %L8
  ret i1 false
}


```
