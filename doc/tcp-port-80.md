# tcp port 80


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 8
002: A = P[20:1]
003: if (A == 6) goto 4 else goto 19
004: A = P[54:2]
005: if (A == 80) goto 18 else goto 6
006: A = P[56:2]
007: if (A == 80) goto 18 else goto 19
008: if (A == 2048) goto 9 else goto 19
009: A = P[23:1]
010: if (A == 6) goto 11 else goto 19
011: A = P[20:2]
012: if (A & 8191 != 0) goto 19 else goto 13
013: X = (P[14:1] & 0xF) << 2
014: A = P[X+14:2]
015: if (A == 80) goto 18 else goto 16
016: A = P[X+16:2]
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
   if not (A==6) then goto L18 end
   if 56 > length then return false end
   A = bit.bor(bit.lshift(P[54], 8), P[54+1])
   if (A==80) then goto L17 end
   if 58 > length then return false end
   A = bit.bor(bit.lshift(P[56], 8), P[56+1])
   if (A==80) then goto L17 end
   goto L18
   ::L7::
   if not (A==2048) then goto L18 end
   if 24 > length then return false end
   A = P[23]
   if not (A==6) then goto L18 end
   if 22 > length then return false end
   A = bit.bor(bit.lshift(P[20], 8), P[20+1])
   if not (bit.band(A, 8191)==0) then goto L18 end
   if 14 >= length then return false end
   X = bit.lshift(bit.band(P[14], 15), 2)
   T = bit.tobit((X+14))
   if T < 0 or T + 2 > length then return false end
   A = bit.bor(bit.lshift(P[T], 8), P[T+1])
   if (A==80) then goto L17 end
   T = bit.tobit((X+16))
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
      if P[23] ~= 6 then return false end
      if band(cast("uint16_t*", P+20)[0],65311) ~= 0 then return false end
      local v2 = lshift(band(P[14],15),2)
      local v3 = (v2 + 16)
      if v3 > length then return false end
      if cast("uint16_t*", P+(v2 + 14))[0] == 20480 then return true end
      if (v2 + 18) > length then return false end
      return cast("uint16_t*", P+v3)[0] == 20480
   else
      if length < 56 then return false end
      if v1 ~= 56710 then return false end
      local v4 = P[20]
      if v4 == 6 then goto L22 end
      do
         if v4 ~= 44 then return false end
         if P[54] == 6 then goto L22 end
         return false
      end
::L22::
      if cast("uint16_t*", P+54)[0] == 20480 then return true end
      if length < 58 then return false end
      return cast("uint16_t*", P+56)[0] == 20480
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

then:                                             ; preds = %else3, %merge4, %then2, %merge37, %L22, %merge16, %merge12, %merge8, %entry
  %merge46 = phi i1 [ false, %merge8 ], [ false, %merge4 ], [ false, %then2 ], [ false, %entry ], [ true, %merge12 ], [ false, %merge16 ], [ false, %else3 ], [ true, %L22 ], [ false, %merge37 ]
  ret i1 %merge46

merge:                                            ; preds = %entry
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %then2, label %else3

then2:                                            ; preds = %merge
  %7 = getelementptr inbounds i8* %0, i64 23
  %8 = load i8* %7, align 1, !tbaa !5
  %9 = icmp eq i8 %8, 6
  br i1 %9, label %merge4, label %then

merge4:                                           ; preds = %then2
  %10 = getelementptr inbounds i8* %0, i64 20
  %11 = bitcast i8* %10 to i16*
  %12 = load i16* %11, align 2, !tbaa !1
  %13 = and i16 %12, -225
  %14 = icmp eq i16 %13, 0
  br i1 %14, label %merge8, label %then

merge8:                                           ; preds = %merge4
  %15 = getelementptr inbounds i8* %0, i64 14
  %16 = load i8* %15, align 1, !tbaa !5
  %17 = zext i8 %16 to i32
  %18 = shl nuw nsw i32 %17, 2
  %19 = and i32 %18, 60
  %20 = add nuw nsw i32 %19, 16
  %21 = icmp ugt i32 %20, %1
  br i1 %21, label %then, label %merge12

merge12:                                          ; preds = %merge8
  %22 = add nuw nsw i32 %19, 14
  %23 = zext i32 %22 to i64
  %24 = getelementptr inbounds i8* %0, i64 %23
  %25 = bitcast i8* %24 to i16*
  %26 = load i16* %25, align 2, !tbaa !1
  %27 = icmp eq i16 %26, 20480
  br i1 %27, label %then, label %merge16

merge16:                                          ; preds = %merge12
  %28 = add nuw nsw i32 %19, 18
  %29 = icmp ugt i32 %28, %1
  br i1 %29, label %then, label %merge20

merge20:                                          ; preds = %merge16
  %30 = zext i32 %20 to i64
  %31 = getelementptr inbounds i8* %0, i64 %30
  %32 = bitcast i8* %31 to i16*
  %33 = load i16* %32, align 2, !tbaa !1
  %34 = icmp eq i16 %33, 20480
  ret i1 %34

else3:                                            ; preds = %merge
  %35 = icmp ugt i32 %1, 55
  %36 = icmp eq i16 %5, -8826
  %or.cond = and i1 %35, %36
  br i1 %or.cond, label %L22, label %then

L22:                                              ; preds = %else3
  %37 = getelementptr inbounds i8* %0, i64 54
  %38 = bitcast i8* %37 to i16*
  %39 = load i16* %38, align 2, !tbaa !1
  %40 = icmp eq i16 %39, 20480
  br i1 %40, label %then, label %merge37

merge37:                                          ; preds = %L22
  %41 = icmp ult i32 %1, 58
  br i1 %41, label %then, label %merge41

merge41:                                          ; preds = %merge37
  %42 = getelementptr inbounds i8* %0, i64 56
  %43 = bitcast i8* %42 to i16*
  %44 = load i16* %43, align 2, !tbaa !1
  %45 = icmp eq i16 %44, 20480
  ret i1 %45
}


```
