# igmp[8] < 8


## BPF

```
000: A = P[12:2]
001: if (A == 2048) goto 2 else goto 10
002: A = P[23:1]
003: if (A == 2) goto 4 else goto 10
004: A = P[20:2]
005: if (A & 8191 != 0) goto 10 else goto 6
006: X = (P[14:1] & 0xF) << 2
007: A = P[X+22:1]
008: if (A >= 8) goto 10 else goto 9
009: return 65535
010: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   local X = 0
   local T = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==2048) then goto L9 end
   if 24 > length then return false end
   A = P[23]
   if not (A==2) then goto L9 end
   if 22 > length then return false end
   A = bit.bor(bit.lshift(P[20], 8), P[20+1])
   if not (bit.band(A, 8191)==0) then goto L9 end
   if 14 >= length then return false end
   X = bit.lshift(bit.band(P[14], 15), 2)
   T = bit.tobit((X+22))
   if T < 0 or T + 1 > length then return false end
   A = P[T]
   if (runtime_u32(A)>=8) then goto L9 end
   do return true end
   ::L9::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local lshift = require("bit").lshift
local band = require("bit").band
local cast = require("ffi").cast
return function(P,length)
   if length < 42 then return false end
   if cast("uint16_t*", P+12)[0] ~= 8 then return false end
   if P[23] ~= 2 then return false end
   if band(cast("uint16_t*", P+20)[0],65311) ~= 0 then return false end
   local v1 = lshift(band(P[14],15),2)
   if (v1 + 23) > length then return false end
   return P[(v1 + 22)] < 8
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 41
  br i1 %2, label %L4, label %L13

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %L6, label %L13

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 23
  %8 = load i8* %7, align 1, !tbaa !5
  %9 = icmp eq i8 %8, 2
  br i1 %9, label %L8, label %L13

L8:                                               ; preds = %L6
  %10 = getelementptr inbounds i8* %0, i64 20
  %11 = bitcast i8* %10 to i16*
  %12 = load i16* %11, align 2, !tbaa !1
  %13 = and i16 %12, -225
  %14 = icmp eq i16 %13, 0
  br i1 %14, label %L10, label %L13

L10:                                              ; preds = %L8
  %15 = getelementptr inbounds i8* %0, i64 14
  %16 = load i8* %15, align 1, !tbaa !5
  %17 = zext i8 %16 to i32
  %18 = shl nuw nsw i32 %17, 2
  %19 = and i32 %18, 60
  %20 = add nuw nsw i32 %19, 23
  %21 = icmp ugt i32 %20, %1
  br i1 %21, label %L13, label %L12

L12:                                              ; preds = %L10
  %22 = add nuw nsw i32 %19, 22
  %23 = zext i32 %22 to i64
  %24 = getelementptr inbounds i8* %0, i64 %23
  %25 = load i8* %24, align 1, !tbaa !5
  %26 = icmp ult i8 %25, 8
  ret i1 %26

L13:                                              ; preds = %L10, %L1, %L4, %L6, %L8
  ret i1 false
}


```
