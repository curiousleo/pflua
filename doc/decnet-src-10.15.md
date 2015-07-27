# decnet src 10.15


## BPF

```
000: A = P[12:2]
001: if (A == 24579) goto 2 else goto 23
002: A = P[16:1]
003: A &= 7
004: if (A == 2) goto 5 else goto 7
005: A = P[19:2]
006: if (A == 3880) goto 22 else goto 7
007: A = P[16:2]
008: A &= 65287
009: if (A == 33026) goto 10 else goto 12
010: A = P[20:2]
011: if (A == 3880) goto 22 else goto 12
012: A = P[16:1]
013: A &= 7
014: if (A == 6) goto 15 else goto 17
015: A = P[31:2]
016: if (A == 3880) goto 22 else goto 17
017: A = P[16:2]
018: A &= 65287
019: if (A == 33030) goto 20 else goto 23
020: A = P[32:2]
021: if (A == 3880) goto 22 else goto 23
022: return 65535
023: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==24579) then goto L22 end
   if 17 > length then return false end
   A = P[16]
   A = bit.band(A, 7)
   if not (A==2) then goto L6 end
   if 21 > length then return false end
   A = bit.bor(bit.lshift(P[19], 8), P[19+1])
   if (A==3880) then goto L21 end
   ::L6::
   if 18 > length then return false end
   A = bit.bor(bit.lshift(P[16], 8), P[16+1])
   A = bit.band(A, 65287)
   if not (A==33026) then goto L11 end
   if 22 > length then return false end
   A = bit.bor(bit.lshift(P[20], 8), P[20+1])
   if (A==3880) then goto L21 end
   ::L11::
   if 17 > length then return false end
   A = P[16]
   A = bit.band(A, 7)
   if not (A==6) then goto L16 end
   if 33 > length then return false end
   A = bit.bor(bit.lshift(P[31], 8), P[31+1])
   if (A==3880) then goto L21 end
   ::L16::
   if 18 > length then return false end
   A = bit.bor(bit.lshift(P[16], 8), P[16+1])
   A = bit.band(A, 65287)
   if not (A==33030) then goto L22 end
   if 34 > length then return false end
   A = bit.bor(bit.lshift(P[32], 8), P[32+1])
   if not (A==3880) then goto L22 end
   ::L21::
   do return true end
   ::L22::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local band = require("bit").band
local cast = require("ffi").cast
return function(P,length)
   if length < 21 then return false end
   local v1 = band(P[16],7)
   if v1 == 2 then
      return cast("uint16_t*", P+19)[0] == 3850
   end
   if length < 22 then return false end
   local v2 = band(cast("uint16_t*", P+16)[0],2047)
   if v2 == 641 then
      return cast("uint16_t*", P+20)[0] == 3850
   end
   if length < 33 then return false end
   if v1 == 6 then
      return cast("uint16_t*", P+31)[0] == 3850
   end
   if length < 34 then return false end
   if v2 ~= 1665 then return false end
   return cast("uint16_t*", P+32)[0] == 3850
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 21
  br i1 %2, label %then, label %merge

then:                                             ; preds = %merge17, %merge9, %merge1, %entry
  ret i1 false

merge:                                            ; preds = %entry
  %3 = getelementptr inbounds i8* %0, i64 16
  %4 = load i8* %3, align 1, !tbaa !1
  %5 = zext i8 %4 to i32
  %6 = and i32 %5, 7
  %7 = icmp eq i32 %6, 2
  br i1 %7, label %then2, label %merge1

then2:                                            ; preds = %merge
  %8 = getelementptr inbounds i8* %0, i64 19
  %9 = bitcast i8* %8 to i16*
  %10 = load i16* %9, align 2, !tbaa !4
  %11 = icmp eq i16 %10, 3850
  ret i1 %11

merge1:                                           ; preds = %merge
  %12 = icmp ult i32 %1, 22
  br i1 %12, label %then, label %merge5

merge5:                                           ; preds = %merge1
  %13 = bitcast i8* %3 to i16*
  %14 = load i16* %13, align 2, !tbaa !4
  %15 = zext i16 %14 to i32
  %16 = and i32 %15, 2047
  %17 = icmp eq i32 %16, 641
  br i1 %17, label %then10, label %merge9

then10:                                           ; preds = %merge5
  %18 = getelementptr inbounds i8* %0, i64 20
  %19 = bitcast i8* %18 to i16*
  %20 = load i16* %19, align 2, !tbaa !4
  %21 = icmp eq i16 %20, 3850
  ret i1 %21

merge9:                                           ; preds = %merge5
  %22 = icmp ult i32 %1, 33
  br i1 %22, label %then, label %merge13

merge13:                                          ; preds = %merge9
  %23 = icmp eq i32 %6, 6
  br i1 %23, label %then18, label %merge17

then18:                                           ; preds = %merge13
  %24 = getelementptr inbounds i8* %0, i64 31
  %25 = bitcast i8* %24 to i16*
  %26 = load i16* %25, align 2, !tbaa !4
  %27 = icmp eq i16 %26, 3850
  ret i1 %27

merge17:                                          ; preds = %merge13
  %28 = icmp ugt i32 %1, 33
  %29 = icmp eq i32 %16, 1665
  %or.cond = and i1 %28, %29
  br i1 %or.cond, label %merge25, label %then

merge25:                                          ; preds = %merge17
  %30 = getelementptr inbounds i8* %0, i64 32
  %31 = bitcast i8* %30 to i16*
  %32 = load i16* %31, align 2, !tbaa !4
  %33 = icmp eq i16 %32, 3850
  ret i1 %33
}


```
