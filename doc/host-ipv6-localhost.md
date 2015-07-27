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
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 54
  br i1 %2, label %then, label %merge

then:                                             ; preds = %merge13, %merge9, %L9, %merge, %entry
  ret i1 false

merge:                                            ; preds = %entry
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, -8826
  br i1 %6, label %L9, label %then

L9:                                               ; preds = %merge
  %7 = getelementptr inbounds i8* %0, i64 38
  %8 = bitcast i8* %7 to i32*
  %9 = load i32* %8, align 4, !tbaa !5
  %10 = icmp eq i32 %9, 0
  br i1 %10, label %merge9, label %then

merge9:                                           ; preds = %L9
  %11 = getelementptr inbounds i8* %0, i64 42
  %12 = bitcast i8* %11 to i32*
  %13 = load i32* %12, align 4, !tbaa !5
  %14 = icmp eq i32 %13, 0
  br i1 %14, label %merge13, label %then

merge13:                                          ; preds = %merge9
  %15 = getelementptr inbounds i8* %0, i64 46
  %16 = bitcast i8* %15 to i32*
  %17 = load i32* %16, align 4, !tbaa !5
  %18 = icmp eq i32 %17, 0
  br i1 %18, label %merge17, label %then

merge17:                                          ; preds = %merge13
  %19 = getelementptr inbounds i8* %0, i64 50
  %20 = bitcast i8* %19 to i32*
  %21 = load i32* %20, align 4, !tbaa !5
  %22 = icmp eq i32 %21, 16777216
  ret i1 %22
}


```
