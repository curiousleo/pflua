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
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 34
  br i1 %2, label %then, label %merge

then:                                             ; preds = %else3, %L8, %merge37, %L26, %merge16, %merge12, %merge8, %entry
  %merge46 = phi i1 [ false, %merge8 ], [ false, %L8 ], [ false, %entry ], [ true, %merge12 ], [ false, %merge16 ], [ false, %else3 ], [ true, %L26 ], [ false, %merge37 ]
  ret i1 %merge46

merge:                                            ; preds = %entry
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %L8, label %else3

L8:                                               ; preds = %merge
  %7 = getelementptr inbounds i8* %0, i64 20
  %8 = bitcast i8* %7 to i16*
  %9 = load i16* %8, align 2, !tbaa !1
  %10 = and i16 %9, -225
  %11 = icmp eq i16 %10, 0
  br i1 %11, label %merge8, label %then

merge8:                                           ; preds = %L8
  %12 = getelementptr inbounds i8* %0, i64 14
  %13 = load i8* %12, align 1, !tbaa !5
  %14 = zext i8 %13 to i32
  %15 = shl nuw nsw i32 %14, 2
  %16 = and i32 %15, 60
  %17 = add nuw nsw i32 %16, 16
  %18 = icmp ugt i32 %17, %1
  br i1 %18, label %then, label %merge12

merge12:                                          ; preds = %merge8
  %19 = add nuw nsw i32 %16, 14
  %20 = zext i32 %19 to i64
  %21 = getelementptr inbounds i8* %0, i64 %20
  %22 = bitcast i8* %21 to i16*
  %23 = load i16* %22, align 2, !tbaa !1
  %24 = tail call zeroext i16 @ntohs(i16 zeroext %23)
  %25 = icmp ult i16 %24, 6001
  br i1 %25, label %then, label %merge16

merge16:                                          ; preds = %merge12
  %26 = add nuw nsw i32 %16, 18
  %27 = icmp ugt i32 %26, %1
  br i1 %27, label %then, label %merge20

merge20:                                          ; preds = %merge16
  %28 = zext i32 %17 to i64
  %29 = getelementptr inbounds i8* %0, i64 %28
  %30 = bitcast i8* %29 to i16*
  %31 = load i16* %30, align 2, !tbaa !1
  %32 = tail call zeroext i16 @ntohs(i16 zeroext %31)
  %33 = icmp ult i16 %32, 6001
  ret i1 %33

else3:                                            ; preds = %merge
  %34 = icmp ugt i32 %1, 55
  %35 = icmp eq i16 %5, -8826
  %or.cond = and i1 %34, %35
  br i1 %or.cond, label %L26, label %then

L26:                                              ; preds = %else3
  %36 = getelementptr inbounds i8* %0, i64 54
  %37 = bitcast i8* %36 to i16*
  %38 = load i16* %37, align 2, !tbaa !1
  %39 = tail call zeroext i16 @ntohs(i16 zeroext %38)
  %40 = icmp ult i16 %39, 6001
  br i1 %40, label %then, label %merge37

merge37:                                          ; preds = %L26
  %41 = icmp ult i32 %1, 58
  br i1 %41, label %then, label %merge41

merge41:                                          ; preds = %merge37
  %42 = getelementptr inbounds i8* %0, i64 56
  %43 = bitcast i8* %42 to i16*
  %44 = load i16* %43, align 2, !tbaa !1
  %45 = tail call zeroext i16 @ntohs(i16 zeroext %44)
  %46 = icmp ult i16 %45, 6001
  ret i1 %46
}


```
