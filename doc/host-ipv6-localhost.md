# host ::1


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 19
002: A = P[22:4]
003: if (A == 0) goto 4 else goto 10
004: A = P[26:4]
005: if (A == 0) goto 6 else goto 10
006: A = P[30:4]
007: if (A == 0) goto 8 else goto 10
008: A = P[34:4]
009: if (A == 1) goto 18 else goto 10
010: A = P[38:4]
011: if (A == 0) goto 12 else goto 19
012: A = P[42:4]
013: if (A == 0) goto 14 else goto 19
014: A = P[46:4]
015: if (A == 0) goto 16 else goto 19
016: A = P[50:4]
017: if (A == 1) goto 18 else goto 19
018: return 65535
019: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==34525) then goto L18 end
   if 26 > length then return false end
   A = bit.bor(bit.lshift(P[22], 24),bit.lshift(P[22+1], 16), bit.lshift(P[22+2], 8), P[22+3])
   if not (A==0) then goto L9 end
   if 30 > length then return false end
   A = bit.bor(bit.lshift(P[26], 24),bit.lshift(P[26+1], 16), bit.lshift(P[26+2], 8), P[26+3])
   if not (A==0) then goto L9 end
   if 34 > length then return false end
   A = bit.bor(bit.lshift(P[30], 24),bit.lshift(P[30+1], 16), bit.lshift(P[30+2], 8), P[30+3])
   if not (A==0) then goto L9 end
   if 38 > length then return false end
   A = bit.bor(bit.lshift(P[34], 24),bit.lshift(P[34+1], 16), bit.lshift(P[34+2], 8), P[34+3])
   if (A==1) then goto L17 end
   ::L9::
   if 42 > length then return false end
   A = bit.bor(bit.lshift(P[38], 24),bit.lshift(P[38+1], 16), bit.lshift(P[38+2], 8), P[38+3])
   if not (A==0) then goto L18 end
   if 46 > length then return false end
   A = bit.bor(bit.lshift(P[42], 24),bit.lshift(P[42+1], 16), bit.lshift(P[42+2], 8), P[42+3])
   if not (A==0) then goto L18 end
   if 50 > length then return false end
   A = bit.bor(bit.lshift(P[46], 24),bit.lshift(P[46+1], 16), bit.lshift(P[46+2], 8), P[46+3])
   if not (A==0) then goto L18 end
   if 54 > length then return false end
   A = bit.bor(bit.lshift(P[50], 24),bit.lshift(P[50+1], 16), bit.lshift(P[50+2], 8), P[50+3])
   if not (A==1) then goto L18 end
   ::L17::
   do return true end
   ::L18::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local cast = require("ffi").cast
return function(P,length)
   if length < 54 then return false end
   if cast("uint16_t*", P+12)[0] ~= 56710 then return false end
   if cast("uint32_t*", P+22)[0] ~= 0 then goto L9 end
   do
      if cast("uint32_t*", P+26)[0] ~= 0 then goto L9 end
      if cast("uint32_t*", P+30)[0] ~= 0 then goto L9 end
      if cast("uint32_t*", P+34)[0] == 16777216 then return true end
      goto L9
   end
::L9::
   if cast("uint32_t*", P+38)[0] ~= 0 then return false end
   if cast("uint32_t*", P+42)[0] ~= 0 then return false end
   if cast("uint32_t*", P+46)[0] ~= 0 then return false end
   return cast("uint32_t*", P+50)[0] == 16777216
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
  %10 = icmp eq i32 %9, 0
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
  %22 = icmp eq i32 %21, 16777216
  br i1 %22, label %L8, label %L9

L8:                                               ; preds = %L1, %L4, %L9, %L16, %L18, %L14
  %merge = phi i1 [ true, %L14 ], [ false, %L18 ], [ false, %L16 ], [ false, %L9 ], [ false, %L4 ], [ false, %L1 ]
  ret i1 %merge

L9:                                               ; preds = %L14, %L12, %L10, %L6
  %23 = getelementptr inbounds i8* %0, i64 38
  %24 = bitcast i8* %23 to i32*
  %25 = load i32* %24, align 4, !tbaa !5
  %26 = icmp eq i32 %25, 0
  br i1 %26, label %L16, label %L8

L16:                                              ; preds = %L9
  %27 = getelementptr inbounds i8* %0, i64 42
  %28 = bitcast i8* %27 to i32*
  %29 = load i32* %28, align 4, !tbaa !5
  %30 = icmp eq i32 %29, 0
  br i1 %30, label %L18, label %L8

L18:                                              ; preds = %L16
  %31 = getelementptr inbounds i8* %0, i64 46
  %32 = bitcast i8* %31 to i32*
  %33 = load i32* %32, align 4, !tbaa !5
  %34 = icmp eq i32 %33, 0
  br i1 %34, label %L20, label %L8

L20:                                              ; preds = %L18
  %35 = getelementptr inbounds i8* %0, i64 50
  %36 = bitcast i8* %35 to i32*
  %37 = load i32* %36, align 4, !tbaa !5
  %38 = icmp eq i32 %37, 16777216
  ret i1 %38
}


```
