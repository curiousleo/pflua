# net ee:cc::9954:0/111


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 21
002: A = P[22:4]
003: if (A == 15597772) goto 4 else goto 11
004: A = P[26:4]
005: if (A == 0) goto 6 else goto 11
006: A = P[30:4]
007: if (A == 0) goto 8 else goto 11
008: A = P[34:4]
009: A &= 4294836224
010: if (A == 2572419072) goto 20 else goto 11
011: A = P[38:4]
012: if (A == 15597772) goto 13 else goto 21
013: A = P[42:4]
014: if (A == 0) goto 15 else goto 21
015: A = P[46:4]
016: if (A == 0) goto 17 else goto 21
017: A = P[50:4]
018: A &= 4294836224
019: if (A == 2572419072) goto 20 else goto 21
020: return 65535
021: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==34525) then goto L20 end
   if 26 > length then return false end
   A = bit.bor(bit.lshift(P[22], 24),bit.lshift(P[22+1], 16), bit.lshift(P[22+2], 8), P[22+3])
   if not (A==15597772) then goto L10 end
   if 30 > length then return false end
   A = bit.bor(bit.lshift(P[26], 24),bit.lshift(P[26+1], 16), bit.lshift(P[26+2], 8), P[26+3])
   if not (A==0) then goto L10 end
   if 34 > length then return false end
   A = bit.bor(bit.lshift(P[30], 24),bit.lshift(P[30+1], 16), bit.lshift(P[30+2], 8), P[30+3])
   if not (A==0) then goto L10 end
   if 38 > length then return false end
   A = bit.bor(bit.lshift(P[34], 24),bit.lshift(P[34+1], 16), bit.lshift(P[34+2], 8), P[34+3])
   A = bit.band(A, -131072)
   if (A==-1722548224) then goto L19 end
   ::L10::
   if 42 > length then return false end
   A = bit.bor(bit.lshift(P[38], 24),bit.lshift(P[38+1], 16), bit.lshift(P[38+2], 8), P[38+3])
   if not (A==15597772) then goto L20 end
   if 46 > length then return false end
   A = bit.bor(bit.lshift(P[42], 24),bit.lshift(P[42+1], 16), bit.lshift(P[42+2], 8), P[42+3])
   if not (A==0) then goto L20 end
   if 50 > length then return false end
   A = bit.bor(bit.lshift(P[46], 24),bit.lshift(P[46+1], 16), bit.lshift(P[46+2], 8), P[46+3])
   if not (A==0) then goto L20 end
   if 54 > length then return false end
   A = bit.bor(bit.lshift(P[50], 24),bit.lshift(P[50+1], 16), bit.lshift(P[50+2], 8), P[50+3])
   A = bit.band(A, -131072)
   if not (A==-1722548224) then goto L20 end
   ::L19::
   do return true end
   ::L20::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local band = require("bit").band
local cast = require("ffi").cast
return function(P,length)
   if length < 54 then return false end
   if cast("uint16_t*", P+12)[0] ~= 56710 then return false end
   if cast("uint32_t*", P+22)[0] ~= 3422612992 then goto L9 end
   do
      if cast("uint32_t*", P+26)[0] ~= 0 then goto L9 end
      if cast("uint32_t*", P+30)[0] ~= 0 then goto L9 end
      if band(cast("uint32_t*", P+34)[0],65279) == 21657 then return true end
      goto L9
   end
::L9::
   if cast("uint32_t*", P+38)[0] ~= 3422612992 then return false end
   if cast("uint32_t*", P+42)[0] ~= 0 then return false end
   if cast("uint32_t*", P+46)[0] ~= 0 then return false end
   return band(cast("uint32_t*", P+50)[0],65279) == 21657
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 53
  br i1 %2, label %L4, label %L8

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, -8826
  br i1 %6, label %L6, label %L8

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 22
  %8 = bitcast i8* %7 to i32*
  %9 = load i32* %8, align 4, !tbaa !5
  %10 = icmp eq i32 %9, -872354304
  br i1 %10, label %L10, label %L9

L10:                                              ; preds = %L6
  %11 = getelementptr inbounds i8* %0, i64 26
  %12 = bitcast i8* %11 to i32*
  %13 = load i32* %12, align 4, !tbaa !5
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %L12, label %L9

L12:                                              ; preds = %L10
  %15 = getelementptr inbounds i8* %0, i64 30
  %16 = bitcast i8* %15 to i32*
  %17 = load i32* %16, align 4, !tbaa !5
  %18 = icmp eq i32 %17, 0
  br i1 %18, label %L14, label %L9

L14:                                              ; preds = %L12
  %19 = getelementptr inbounds i8* %0, i64 34
  %20 = bitcast i8* %19 to i32*
  %21 = load i32* %20, align 4, !tbaa !5
  %22 = and i32 %21, 65279
  %23 = icmp eq i32 %22, 21657
  br i1 %23, label %L8, label %L9

L8:                                               ; preds = %L1, %L4, %L9, %L16, %L18, %L14
  %merge = phi i1 [ true, %L14 ], [ false, %L18 ], [ false, %L16 ], [ false, %L9 ], [ false, %L4 ], [ false, %L1 ]
  ret i1 %merge

L9:                                               ; preds = %L14, %L12, %L10, %L6
  %24 = getelementptr inbounds i8* %0, i64 38
  %25 = bitcast i8* %24 to i32*
  %26 = load i32* %25, align 4, !tbaa !5
  %27 = icmp eq i32 %26, -872354304
  br i1 %27, label %L16, label %L8

L16:                                              ; preds = %L9
  %28 = getelementptr inbounds i8* %0, i64 42
  %29 = bitcast i8* %28 to i32*
  %30 = load i32* %29, align 4, !tbaa !5
  %31 = icmp eq i32 %30, 0
  br i1 %31, label %L18, label %L8

L18:                                              ; preds = %L16
  %32 = getelementptr inbounds i8* %0, i64 46
  %33 = bitcast i8* %32 to i32*
  %34 = load i32* %33, align 4, !tbaa !5
  %35 = icmp eq i32 %34, 0
  br i1 %35, label %L20, label %L8

L20:                                              ; preds = %L18
  %36 = getelementptr inbounds i8* %0, i64 50
  %37 = bitcast i8* %36 to i32*
  %38 = load i32* %37, align 4, !tbaa !5
  %39 = and i32 %38, 65279
  %40 = icmp eq i32 %39, 21657
  ret i1 %40
}


```
