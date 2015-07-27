# portrange 0-6000


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 11
002: A = P[20:1]
003: if (A == 132) goto 6 else goto 4
004: if (A == 6) goto 6 else goto 5
005: if (A == 17) goto 6 else goto 26
006: A = P[54:2]
007: if (A >= 0) goto 8 else goto 9
008: if (A > 6000) goto 9 else goto 25
009: A = P[56:2]
010: if (A >= 0) goto 24 else goto 26
011: if (A == 2048) goto 12 else goto 26
012: A = P[23:1]
013: if (A == 132) goto 16 else goto 14
014: if (A == 6) goto 16 else goto 15
015: if (A == 17) goto 16 else goto 26
016: A = P[20:2]
017: if (A & 8191 != 0) goto 26 else goto 18
018: X = (P[14:1] & 0xF) << 2
019: A = P[X+14:2]
020: if (A >= 0) goto 21 else goto 22
021: if (A > 6000) goto 22 else goto 25
022: A = P[X+16:2]
023: if (A >= 0) goto 24 else goto 26
024: if (A > 6000) goto 26 else goto 25
025: return 65535
026: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   local X = 0
   local T = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==34525) then goto L10 end
   if 21 > length then return false end
   A = P[20]
   if (A==132) then goto L5 end
   if (A==6) then goto L5 end
   if not (A==17) then goto L25 end
   ::L5::
   if 56 > length then return false end
   A = bit.bor(bit.lshift(P[54], 8), P[54+1])
   if not (runtime_u32(A)>=0) then goto L8 end
   if not (runtime_u32(A)>6000) then goto L24 end
   ::L8::
   if 58 > length then return false end
   A = bit.bor(bit.lshift(P[56], 8), P[56+1])
   if (runtime_u32(A)>=0) then goto L23 end
   goto L25
   ::L10::
   if not (A==2048) then goto L25 end
   if 24 > length then return false end
   A = P[23]
   if (A==132) then goto L15 end
   if (A==6) then goto L15 end
   if not (A==17) then goto L25 end
   ::L15::
   if 22 > length then return false end
   A = bit.bor(bit.lshift(P[20], 8), P[20+1])
   if not (bit.band(A, 8191)==0) then goto L25 end
   if 14 >= length then return false end
   X = bit.lshift(bit.band(P[14], 15), 2)
   T = bit.tobit((X+14))
   if T < 0 or T + 2 > length then return false end
   A = bit.bor(bit.lshift(P[T], 8), P[T+1])
   if not (runtime_u32(A)>=0) then goto L21 end
   if not (runtime_u32(A)>6000) then goto L24 end
   ::L21::
   T = bit.tobit((X+16))
   if T < 0 or T + 2 > length then return false end
   A = bit.bor(bit.lshift(P[T], 8), P[T+1])
   if not (runtime_u32(A)>=0) then goto L25 end
   ::L23::
   if (runtime_u32(A)>6000) then goto L25 end
   ::L24::
   do return true end
   ::L25::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local rshift = require("bit").rshift
local bswap = require("bit").bswap
local cast = require("ffi").cast
local lshift = require("bit").lshift
local band = require("bit").band
return function(P,length)
   if length < 34 then return false end
   local v1 = cast("uint16_t*", P+12)[0]
   if v1 == 8 then
      local v2 = P[23]
      if v2 == 6 then goto L8 end
      do
         if v2 == 17 then goto L8 end
         if v2 == 132 then goto L8 end
         return false
      end
::L8::
      if band(cast("uint16_t*", P+20)[0],65311) ~= 0 then return false end
      local v3 = lshift(band(P[14],15),2)
      local v4 = (v3 + 16)
      if v4 > length then return false end
      if rshift(bswap(cast("uint16_t*", P+(v3 + 14))[0]), 16) <= 6000 then return true end
      if (v3 + 18) > length then return false end
      return rshift(bswap(cast("uint16_t*", P+v4)[0]), 16) <= 6000
   else
      if length < 56 then return false end
      if v1 ~= 56710 then return false end
      local v5 = P[20]
      if v5 == 6 then goto L26 end
      do
         if v5 ~= 44 then goto L29 end
         do
            if P[54] == 6 then goto L26 end
            goto L29
         end
::L29::
         if v5 == 17 then goto L26 end
         if v5 ~= 44 then goto L35 end
         do
            if P[54] == 17 then goto L26 end
            goto L35
         end
::L35::
         if v5 == 132 then goto L26 end
         if v5 ~= 44 then return false end
         if P[54] == 132 then goto L26 end
         return false
      end
::L26::
      if rshift(bswap(cast("uint16_t*", P+54)[0]), 16) <= 6000 then return true end
      if length < 58 then return false end
      return rshift(bswap(cast("uint16_t*", P+56)[0]), 16) <= 6000
   end
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 33
  br i1 %2, label %L4, label %L18

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %L6, label %L7

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 23
  %8 = load i8* %7, align 1, !tbaa !5
  switch i8 %8, label %L18 [
    i8 6, label %L8
    i8 17, label %L8
  ]

L8:                                               ; preds = %L6, %L6
  %9 = getelementptr inbounds i8* %0, i64 20
  %10 = bitcast i8* %9 to i16*
  %11 = load i16* %10, align 2, !tbaa !1
  %12 = and i16 %11, -225
  %13 = icmp eq i16 %12, 0
  br i1 %13, label %L14, label %L18

L14:                                              ; preds = %L8
  %14 = getelementptr inbounds i8* %0, i64 14
  %15 = load i8* %14, align 1, !tbaa !5
  %16 = zext i8 %15 to i32
  %17 = shl nuw nsw i32 %16, 2
  %18 = and i32 %17, 60
  %19 = add nuw nsw i32 %18, 16
  %20 = icmp ugt i32 %19, %1
  br i1 %20, label %L18, label %L16

L16:                                              ; preds = %L14
  %21 = add nuw nsw i32 %18, 14
  %22 = zext i32 %21 to i64
  %23 = getelementptr inbounds i8* %0, i64 %22
  %24 = bitcast i8* %23 to i16*
  %25 = load i16* %24, align 2, !tbaa !1
  %26 = tail call zeroext i16 @ntohs(i16 zeroext %25)
  %27 = icmp ult i16 %26, 6001
  br i1 %27, label %L18, label %L19

L18:                                              ; preds = %L24, %L38, %L6, %L19, %L14, %L1, %L7, %L45, %L26, %L8, %L16
  %merge = phi i1 [ true, %L16 ], [ false, %L19 ], [ false, %L14 ], [ false, %L8 ], [ true, %L26 ], [ false, %L45 ], [ false, %L7 ], [ false, %L1 ], [ false, %L6 ], [ false, %L38 ], [ false, %L24 ]
  ret i1 %merge

L19:                                              ; preds = %L16
  %28 = add nuw nsw i32 %18, 18
  %29 = icmp ugt i32 %28, %1
  br i1 %29, label %L18, label %L20

L20:                                              ; preds = %L19
  %30 = zext i32 %19 to i64
  %31 = getelementptr inbounds i8* %0, i64 %30
  %32 = bitcast i8* %31 to i16*
  %33 = load i16* %32, align 2, !tbaa !1
  %34 = tail call zeroext i16 @ntohs(i16 zeroext %33)
  %35 = icmp ult i16 %34, 6001
  ret i1 %35

L7:                                               ; preds = %L4
  %36 = icmp ugt i32 %1, 55
  %37 = icmp eq i16 %5, -8826
  %or.cond = and i1 %36, %37
  br i1 %or.cond, label %L24, label %L18

L24:                                              ; preds = %L7
  %38 = getelementptr inbounds i8* %0, i64 20
  %39 = load i8* %38, align 1, !tbaa !5
  switch i8 %39, label %L18 [
    i8 6, label %L26
    i8 44, label %L32
    i8 17, label %L26
  ]

L32:                                              ; preds = %L24
  %40 = getelementptr inbounds i8* %0, i64 54
  %41 = load i8* %40, align 1, !tbaa !5
  %42 = icmp eq i8 %41, 6
  br i1 %42, label %L26, label %L38

L38:                                              ; preds = %L32
  %43 = getelementptr inbounds i8* %0, i64 54
  %44 = load i8* %43, align 1, !tbaa !5
  %45 = icmp eq i8 %44, 17
  br i1 %45, label %L26, label %L18

L26:                                              ; preds = %L24, %L24, %L38, %L32
  %46 = getelementptr inbounds i8* %0, i64 54
  %47 = bitcast i8* %46 to i16*
  %48 = load i16* %47, align 2, !tbaa !1
  %49 = tail call zeroext i16 @ntohs(i16 zeroext %48)
  %50 = icmp ult i16 %49, 6001
  br i1 %50, label %L18, label %L45

L45:                                              ; preds = %L26
  %51 = icmp ugt i32 %1, 57
  br i1 %51, label %L46, label %L18

L46:                                              ; preds = %L45
  %52 = getelementptr inbounds i8* %0, i64 56
  %53 = bitcast i8* %52 to i16*
  %54 = load i16* %53, align 2, !tbaa !1
  %55 = tail call zeroext i16 @ntohs(i16 zeroext %54)
  %56 = icmp ult i16 %55, 6001
  ret i1 %56
}


```
