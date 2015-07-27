# dst portrange 80-90


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 8
002: A = P[20:1]
003: if (A == 132) goto 6 else goto 4
004: if (A == 6) goto 6 else goto 5
005: if (A == 17) goto 6 else goto 20
006: A = P[56:2]
007: if (A >= 80) goto 18 else goto 20
008: if (A == 2048) goto 9 else goto 20
009: A = P[23:1]
010: if (A == 132) goto 13 else goto 11
011: if (A == 6) goto 13 else goto 12
012: if (A == 17) goto 13 else goto 20
013: A = P[20:2]
014: if (A & 8191 != 0) goto 20 else goto 15
015: X = (P[14:1] & 0xF) << 2
016: A = P[X+16:2]
017: if (A >= 80) goto 18 else goto 20
018: if (A > 90) goto 20 else goto 19
019: return 65535
020: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   local X = 0
   local T = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==34525) then goto L7 end
   if 21 > length then return false end
   A = P[20]
   if (A==132) then goto L5 end
   if (A==6) then goto L5 end
   if not (A==17) then goto L19 end
   ::L5::
   if 58 > length then return false end
   A = bit.bor(bit.lshift(P[56], 8), P[56+1])
   if (runtime_u32(A)>=80) then goto L17 end
   goto L19
   ::L7::
   if not (A==2048) then goto L19 end
   if 24 > length then return false end
   A = P[23]
   if (A==132) then goto L12 end
   if (A==6) then goto L12 end
   if not (A==17) then goto L19 end
   ::L12::
   if 22 > length then return false end
   A = bit.bor(bit.lshift(P[20], 8), P[20+1])
   if not (bit.band(A, 8191)==0) then goto L19 end
   if 14 >= length then return false end
   X = bit.lshift(bit.band(P[14], 15), 2)
   T = bit.tobit((X+16))
   if T < 0 or T + 2 > length then return false end
   A = bit.bor(bit.lshift(P[T], 8), P[T+1])
   if not (runtime_u32(A)>=80) then goto L19 end
   ::L17::
   if (runtime_u32(A)>90) then goto L19 end
   do return true end
   ::L19::
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
      if (v3 + 18) > length then return false end
      local v4 = rshift(bswap(cast("uint16_t*", P+(v3 + 16))[0]), 16)
      if v4 < 80 then return false end
      return v4 <= 90
   else
      if length < 58 then return false end
      if v1 ~= 56710 then return false end
      local v5 = P[20]
      if v5 == 6 then goto L24 end
      do
         if v5 ~= 44 then goto L27 end
         do
            if P[54] == 6 then goto L24 end
            goto L27
         end
::L27::
         if v5 == 17 then goto L24 end
         if v5 ~= 44 then goto L33 end
         do
            if P[54] == 17 then goto L24 end
            goto L33
         end
::L33::
         if v5 == 132 then goto L24 end
         if v5 ~= 44 then return false end
         if P[54] == 132 then goto L24 end
         return false
      end
::L24::
      local v6 = rshift(bswap(cast("uint16_t*", P+56)[0]), 16)
      if v6 < 80 then return false end
      return v6 <= 90
   end
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 33
  br i1 %2, label %L4, label %L19

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %L6, label %L7

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 23
  %8 = load i8* %7, align 1, !tbaa !5
  switch i8 %8, label %L19 [
    i8 6, label %L8
    i8 17, label %L8
  ]

L8:                                               ; preds = %L6, %L6
  %9 = getelementptr inbounds i8* %0, i64 20
  %10 = bitcast i8* %9 to i16*
  %11 = load i16* %10, align 2, !tbaa !1
  %12 = and i16 %11, -225
  %13 = icmp eq i16 %12, 0
  br i1 %13, label %L14, label %L19

L14:                                              ; preds = %L8
  %14 = getelementptr inbounds i8* %0, i64 14
  %15 = load i8* %14, align 1, !tbaa !5
  %16 = zext i8 %15 to i32
  %17 = shl nuw nsw i32 %16, 2
  %18 = and i32 %17, 60
  %19 = add nuw nsw i32 %18, 18
  %20 = icmp ugt i32 %19, %1
  br i1 %20, label %L19, label %L16

L16:                                              ; preds = %L14
  %21 = add nuw nsw i32 %18, 16
  %22 = zext i32 %21 to i64
  %23 = getelementptr inbounds i8* %0, i64 %22
  %24 = bitcast i8* %23 to i16*
  %25 = load i16* %24, align 2, !tbaa !1
  %26 = tail call zeroext i16 @ntohs(i16 zeroext %25)
  %27 = icmp ugt i16 %26, 79
  br i1 %27, label %L18, label %L19

L18:                                              ; preds = %L16
  %28 = icmp ult i16 %26, 91
  ret i1 %28

L19:                                              ; preds = %L22, %L6, %L36, %L14, %L1, %L7, %L24, %L8, %L16
  ret i1 false

L7:                                               ; preds = %L4
  %29 = icmp ugt i32 %1, 57
  %30 = icmp eq i16 %5, -8826
  %or.cond = and i1 %29, %30
  br i1 %or.cond, label %L22, label %L19

L22:                                              ; preds = %L7
  %31 = getelementptr inbounds i8* %0, i64 20
  %32 = load i8* %31, align 1, !tbaa !5
  switch i8 %32, label %L19 [
    i8 6, label %L24
    i8 44, label %L30
    i8 17, label %L24
  ]

L30:                                              ; preds = %L22
  %33 = getelementptr inbounds i8* %0, i64 54
  %34 = load i8* %33, align 1, !tbaa !5
  %35 = icmp eq i8 %34, 6
  br i1 %35, label %L24, label %L36

L36:                                              ; preds = %L30
  %36 = getelementptr inbounds i8* %0, i64 54
  %37 = load i8* %36, align 1, !tbaa !5
  %38 = icmp eq i8 %37, 17
  br i1 %38, label %L24, label %L19

L24:                                              ; preds = %L22, %L22, %L36, %L30
  %39 = getelementptr inbounds i8* %0, i64 56
  %40 = bitcast i8* %39 to i16*
  %41 = load i16* %40, align 2, !tbaa !1
  %42 = tail call zeroext i16 @ntohs(i16 zeroext %41)
  %43 = icmp ugt i16 %42, 79
  br i1 %43, label %L42, label %L19

L42:                                              ; preds = %L24
  %44 = icmp ult i16 %42, 91
  ret i1 %44
}


```
