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
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 34
  br i1 %2, label %then, label %merge

then:                                             ; preds = %else3, %L8, %merge8, %entry
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
  %17 = add nuw nsw i32 %16, 16
  %18 = icmp ugt i32 %17, %1
  br i1 %18, label %then, label %merge12

merge12:                                          ; preds = %merge8
  %19 = add nuw nsw i32 %16, 14
  %20 = zext i32 %19 to i64
  %21 = getelementptr inbounds i8* %0, i64 %20
  %22 = bitcast i8* %21 to i16*
  %23 = load i16* %22, align 2, !tbaa !1
  %24 = icmp eq i16 %23, 20480
  ret i1 %24

else3:                                            ; preds = %merge
  %25 = icmp ugt i32 %1, 55
  %26 = icmp eq i16 %5, -8826
  %or.cond = and i1 %25, %26
  br i1 %or.cond, label %L22, label %then

L22:                                              ; preds = %else3
  %27 = getelementptr inbounds i8* %0, i64 54
  %28 = bitcast i8* %27 to i16*
  %29 = load i16* %28, align 2, !tbaa !1
  %30 = icmp eq i16 %29, 20480
  ret i1 %30
}


```
