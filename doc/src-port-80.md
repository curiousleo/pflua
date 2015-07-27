# src port 80


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 8
002: A = P[20:1]
003: if (A == 132) goto 6 else goto 4
004: if (A == 6) goto 6 else goto 5
005: if (A == 17) goto 6 else goto 19
006: A = P[54:2]
007: if (A == 80) goto 18 else goto 19
008: if (A == 2048) goto 9 else goto 19
009: A = P[23:1]
010: if (A == 132) goto 13 else goto 11
011: if (A == 6) goto 13 else goto 12
012: if (A == 17) goto 13 else goto 19
013: A = P[20:2]
014: if (A & 8191 != 0) goto 19 else goto 15
015: X = (P[14:1] & 0xF) << 2
016: A = P[X+14:2]
017: if (A == 80) goto 18 else goto 19
018: return 65535
019: return 0
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
   if not (A==17) then goto L18 end
   ::L5::
   if 56 > length then return false end
   A = bit.bor(bit.lshift(P[54], 8), P[54+1])
   if (A==80) then goto L17 end
   goto L18
   ::L7::
   if not (A==2048) then goto L18 end
   if 24 > length then return false end
   A = P[23]
   if (A==132) then goto L12 end
   if (A==6) then goto L12 end
   if not (A==17) then goto L18 end
   ::L12::
   if 22 > length then return false end
   A = bit.bor(bit.lshift(P[20], 8), P[20+1])
   if not (bit.band(A, 8191)==0) then goto L18 end
   if 14 >= length then return false end
   X = bit.lshift(bit.band(P[14], 15), 2)
   T = bit.tobit((X+14))
   if T < 0 or T + 2 > length then return false end
   A = bit.bor(bit.lshift(P[T], 8), P[T+1])
   if not (A==80) then goto L18 end
   ::L17::
   do return true end
   ::L18::
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
      if (v3 + 16) > length then return false end
      return cast("uint16_t*", P+(v3 + 14))[0] == 20480
   else
      if length < 56 then return false end
      if v1 ~= 56710 then return false end
      local v4 = P[20]
      if v4 == 6 then goto L22 end
      do
         if v4 ~= 44 then goto L25 end
         do
            if P[54] == 6 then goto L22 end
            goto L25
         end
::L25::
         if v4 == 17 then goto L22 end
         if v4 ~= 44 then goto L31 end
         do
            if P[54] == 17 then goto L22 end
            goto L31
         end
::L31::
         if v4 == 132 then goto L22 end
         if v4 ~= 44 then return false end
         if P[54] == 132 then goto L22 end
         return false
      end
::L22::
      return cast("uint16_t*", P+54)[0] == 20480
   end
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 33
  br i1 %2, label %L4, label %L17

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %L6, label %L7

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 23
  %8 = load i8* %7, align 1, !tbaa !5
  switch i8 %8, label %L17 [
    i8 6, label %L8
    i8 17, label %L8
  ]

L8:                                               ; preds = %L6, %L6
  %9 = getelementptr inbounds i8* %0, i64 20
  %10 = bitcast i8* %9 to i16*
  %11 = load i16* %10, align 2, !tbaa !1
  %12 = and i16 %11, -225
  %13 = icmp eq i16 %12, 0
  br i1 %13, label %L14, label %L17

L14:                                              ; preds = %L8
  %14 = getelementptr inbounds i8* %0, i64 14
  %15 = load i8* %14, align 1, !tbaa !5
  %16 = zext i8 %15 to i32
  %17 = shl nuw nsw i32 %16, 2
  %18 = and i32 %17, 60
  %19 = add nuw nsw i32 %18, 16
  %20 = icmp ugt i32 %19, %1
  br i1 %20, label %L17, label %L16

L16:                                              ; preds = %L14
  %21 = add nuw nsw i32 %18, 14
  %22 = zext i32 %21 to i64
  %23 = getelementptr inbounds i8* %0, i64 %22
  %24 = bitcast i8* %23 to i16*
  %25 = load i16* %24, align 2, !tbaa !1
  %26 = icmp eq i16 %25, 20480
  ret i1 %26

L17:                                              ; preds = %L20, %L6, %L34, %L14, %L1, %L7, %L8
  ret i1 false

L7:                                               ; preds = %L4
  %27 = icmp ugt i32 %1, 55
  %28 = icmp eq i16 %5, -8826
  %or.cond = and i1 %27, %28
  br i1 %or.cond, label %L20, label %L17

L20:                                              ; preds = %L7
  %29 = getelementptr inbounds i8* %0, i64 20
  %30 = load i8* %29, align 1, !tbaa !5
  switch i8 %30, label %L17 [
    i8 6, label %L22
    i8 44, label %L28
    i8 17, label %L22
  ]

L28:                                              ; preds = %L20
  %31 = getelementptr inbounds i8* %0, i64 54
  %32 = load i8* %31, align 1, !tbaa !5
  %33 = icmp eq i8 %32, 6
  br i1 %33, label %L22, label %L34

L34:                                              ; preds = %L28
  %34 = getelementptr inbounds i8* %0, i64 54
  %35 = load i8* %34, align 1, !tbaa !5
  %36 = icmp eq i8 %35, 17
  br i1 %36, label %L22, label %L17

L22:                                              ; preds = %L20, %L20, %L34, %L28
  %37 = getelementptr inbounds i8* %0, i64 54
  %38 = bitcast i8* %37 to i16*
  %39 = load i16* %38, align 2, !tbaa !1
  %40 = icmp eq i16 %39, 20480
  ret i1 %40
}


```
