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
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 34
  br i1 %2, label %then, label %merge

then:                                             ; preds = %else3, %L8, %L24, %merge12, %merge8, %entry
  ret i1 false

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
  %17 = add nuw nsw i32 %16, 18
  %18 = icmp ugt i32 %17, %1
  br i1 %18, label %then, label %merge12

merge12:                                          ; preds = %merge8
  %19 = add nuw nsw i32 %16, 16
  %20 = zext i32 %19 to i64
  %21 = getelementptr inbounds i8* %0, i64 %20
  %22 = bitcast i8* %21 to i16*
  %23 = load i16* %22, align 2, !tbaa !1
  %24 = tail call zeroext i16 @ntohs(i16 zeroext %23)
  %25 = icmp ult i16 %24, 80
  br i1 %25, label %then, label %merge16

merge16:                                          ; preds = %merge12
  %26 = icmp ult i16 %24, 91
  ret i1 %26

else3:                                            ; preds = %merge
  %27 = icmp ugt i32 %1, 57
  %28 = icmp eq i16 %5, -8826
  %or.cond = and i1 %27, %28
  br i1 %or.cond, label %L24, label %then

L24:                                              ; preds = %else3
  %29 = getelementptr inbounds i8* %0, i64 56
  %30 = bitcast i8* %29 to i16*
  %31 = load i16* %30, align 2, !tbaa !1
  %32 = tail call zeroext i16 @ntohs(i16 zeroext %31)
  %33 = icmp ult i16 %32, 80
  br i1 %33, label %then, label %merge33

merge33:                                          ; preds = %L24
  %34 = icmp ult i16 %32, 91
  ret i1 %34
}


```
