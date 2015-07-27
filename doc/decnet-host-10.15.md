# decnet host 10.15


## BPF

```
000: A = P[12:2]
001: if (A == 24579) goto 2 else goto 43
002: A = P[16:1]
003: A &= 7
004: if (A == 2) goto 5 else goto 7
005: A = P[19:2]
006: if (A == 3880) goto 42 else goto 7
007: A = P[16:2]
008: A &= 65287
009: if (A == 33026) goto 10 else goto 12
010: A = P[20:2]
011: if (A == 3880) goto 42 else goto 12
012: A = P[16:1]
013: A &= 7
014: if (A == 6) goto 15 else goto 17
015: A = P[31:2]
016: if (A == 3880) goto 42 else goto 17
017: A = P[16:2]
018: A &= 65287
019: if (A == 33030) goto 20 else goto 22
020: A = P[32:2]
021: if (A == 3880) goto 42 else goto 22
022: A = P[16:1]
023: A &= 7
024: if (A == 2) goto 25 else goto 27
025: A = P[17:2]
026: if (A == 3880) goto 42 else goto 27
027: A = P[16:2]
028: A &= 65287
029: if (A == 33026) goto 30 else goto 32
030: A = P[18:2]
031: if (A == 3880) goto 42 else goto 32
032: A = P[16:1]
033: A &= 7
034: if (A == 6) goto 35 else goto 37
035: A = P[23:2]
036: if (A == 3880) goto 42 else goto 37
037: A = P[16:2]
038: A &= 65287
039: if (A == 33030) goto 40 else goto 43
040: A = P[24:2]
041: if (A == 3880) goto 42 else goto 43
042: return 65535
043: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==24579) then goto L42 end
   if 17 > length then return false end
   A = P[16]
   A = bit.band(A, 7)
   if not (A==2) then goto L6 end
   if 21 > length then return false end
   A = bit.bor(bit.lshift(P[19], 8), P[19+1])
   if (A==3880) then goto L41 end
   ::L6::
   if 18 > length then return false end
   A = bit.bor(bit.lshift(P[16], 8), P[16+1])
   A = bit.band(A, 65287)
   if not (A==33026) then goto L11 end
   if 22 > length then return false end
   A = bit.bor(bit.lshift(P[20], 8), P[20+1])
   if (A==3880) then goto L41 end
   ::L11::
   if 17 > length then return false end
   A = P[16]
   A = bit.band(A, 7)
   if not (A==6) then goto L16 end
   if 33 > length then return false end
   A = bit.bor(bit.lshift(P[31], 8), P[31+1])
   if (A==3880) then goto L41 end
   ::L16::
   if 18 > length then return false end
   A = bit.bor(bit.lshift(P[16], 8), P[16+1])
   A = bit.band(A, 65287)
   if not (A==33030) then goto L21 end
   if 34 > length then return false end
   A = bit.bor(bit.lshift(P[32], 8), P[32+1])
   if (A==3880) then goto L41 end
   ::L21::
   if 17 > length then return false end
   A = P[16]
   A = bit.band(A, 7)
   if not (A==2) then goto L26 end
   if 19 > length then return false end
   A = bit.bor(bit.lshift(P[17], 8), P[17+1])
   if (A==3880) then goto L41 end
   ::L26::
   if 18 > length then return false end
   A = bit.bor(bit.lshift(P[16], 8), P[16+1])
   A = bit.band(A, 65287)
   if not (A==33026) then goto L31 end
   if 20 > length then return false end
   A = bit.bor(bit.lshift(P[18], 8), P[18+1])
   if (A==3880) then goto L41 end
   ::L31::
   if 17 > length then return false end
   A = P[16]
   A = bit.band(A, 7)
   if not (A==6) then goto L36 end
   if 25 > length then return false end
   A = bit.bor(bit.lshift(P[23], 8), P[23+1])
   if (A==3880) then goto L41 end
   ::L36::
   if 18 > length then return false end
   A = bit.bor(bit.lshift(P[16], 8), P[16+1])
   A = bit.band(A, 65287)
   if not (A==33030) then goto L42 end
   if 26 > length then return false end
   A = bit.bor(bit.lshift(P[24], 8), P[24+1])
   if not (A==3880) then goto L42 end
   ::L41::
   do return true end
   ::L42::
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
      if cast("uint16_t*", P+19)[0] == 3850 then return true end
      return cast("uint16_t*", P+17)[0] == 3850
   else
      if length < 22 then return false end
      local v2 = band(cast("uint16_t*", P+16)[0],2047)
      if v2 == 641 then
         if cast("uint16_t*", P+20)[0] == 3850 then return true end
         return cast("uint16_t*", P+18)[0] == 3850
      else
         if length < 33 then return false end
         if v1 == 6 then
            if cast("uint16_t*", P+31)[0] == 3850 then return true end
            return cast("uint16_t*", P+23)[0] == 3850
         else
            if length < 34 then return false end
            if v2 ~= 1665 then return false end
            if cast("uint16_t*", P+32)[0] == 3850 then return true end
            return cast("uint16_t*", P+24)[0] == 3850
         end
      end
   end
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 20
  br i1 %2, label %L4, label %L8

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 16
  %4 = load i8* %3, align 1, !tbaa !1
  %5 = zext i8 %4 to i32
  %6 = and i32 %5, 7
  %7 = icmp eq i32 %6, 2
  br i1 %7, label %L6, label %L7

L6:                                               ; preds = %L4
  %8 = getelementptr inbounds i8* %0, i64 19
  %9 = bitcast i8* %8 to i16*
  %10 = load i16* %9, align 2, !tbaa !4
  %11 = icmp eq i16 %10, 3850
  br i1 %11, label %L8, label %L9

L8:                                               ; preds = %L1, %L7, %L13, %L19, %L24, %L18, %L12, %L6
  %merge = phi i1 [ true, %L24 ], [ true, %L18 ], [ true, %L12 ], [ true, %L6 ], [ false, %L19 ], [ false, %L13 ], [ false, %L7 ], [ false, %L1 ]
  ret i1 %merge

L9:                                               ; preds = %L6
  %12 = getelementptr inbounds i8* %0, i64 17
  %13 = bitcast i8* %12 to i16*
  %14 = load i16* %13, align 2, !tbaa !4
  %15 = icmp eq i16 %14, 3850
  ret i1 %15

L7:                                               ; preds = %L4
  %16 = icmp ugt i32 %1, 21
  br i1 %16, label %L10, label %L8

L10:                                              ; preds = %L7
  %17 = bitcast i8* %3 to i16*
  %18 = load i16* %17, align 2, !tbaa !4
  %19 = zext i16 %18 to i32
  %20 = and i32 %19, 2047
  %21 = icmp eq i32 %20, 641
  br i1 %21, label %L12, label %L13

L12:                                              ; preds = %L10
  %22 = getelementptr inbounds i8* %0, i64 20
  %23 = bitcast i8* %22 to i16*
  %24 = load i16* %23, align 2, !tbaa !4
  %25 = icmp eq i16 %24, 3850
  br i1 %25, label %L8, label %L15

L15:                                              ; preds = %L12
  %26 = getelementptr inbounds i8* %0, i64 18
  %27 = bitcast i8* %26 to i16*
  %28 = load i16* %27, align 2, !tbaa !4
  %29 = icmp eq i16 %28, 3850
  ret i1 %29

L13:                                              ; preds = %L10
  %30 = icmp ugt i32 %1, 32
  br i1 %30, label %L16, label %L8

L16:                                              ; preds = %L13
  %31 = icmp eq i32 %6, 6
  br i1 %31, label %L18, label %L19

L18:                                              ; preds = %L16
  %32 = getelementptr inbounds i8* %0, i64 31
  %33 = bitcast i8* %32 to i16*
  %34 = load i16* %33, align 2, !tbaa !4
  %35 = icmp eq i16 %34, 3850
  br i1 %35, label %L8, label %L21

L21:                                              ; preds = %L18
  %36 = getelementptr inbounds i8* %0, i64 23
  %37 = bitcast i8* %36 to i16*
  %38 = load i16* %37, align 2, !tbaa !4
  %39 = icmp eq i16 %38, 3850
  ret i1 %39

L19:                                              ; preds = %L16
  %40 = icmp ugt i32 %1, 33
  %41 = icmp eq i32 %20, 1665
  %or.cond = and i1 %40, %41
  br i1 %or.cond, label %L24, label %L8

L24:                                              ; preds = %L19
  %42 = getelementptr inbounds i8* %0, i64 32
  %43 = bitcast i8* %42 to i16*
  %44 = load i16* %43, align 2, !tbaa !4
  %45 = icmp eq i16 %44, 3850
  br i1 %45, label %L8, label %L27

L27:                                              ; preds = %L24
  %46 = getelementptr inbounds i8* %0, i64 24
  %47 = bitcast i8* %46 to i16*
  %48 = load i16* %47, align 2, !tbaa !4
  %49 = icmp eq i16 %48, 3850
  ret i1 %49
}


```
