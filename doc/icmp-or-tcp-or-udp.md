# icmp or tcp or udp


## BPF

```
000: A = P[12:2]
001: if (A == 2048) goto 2 else goto 5
002: A = P[23:1]
003: if (A == 1) goto 12 else goto 4
004: if (A == 6) goto 12 else goto 11
005: if (A == 34525) goto 6 else goto 13
006: A = P[20:1]
007: if (A == 6) goto 12 else goto 8
008: if (A == 44) goto 9 else goto 11
009: A = P[54:1]
010: if (A == 6) goto 12 else goto 11
011: if (A == 17) goto 12 else goto 13
012: return 65535
013: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==2048) then goto L4 end
   if 24 > length then return false end
   A = P[23]
   if (A==1) then goto L11 end
   if (A==6) then goto L11 end
   goto L10
   ::L4::
   if not (A==34525) then goto L12 end
   if 21 > length then return false end
   A = P[20]
   if (A==6) then goto L11 end
   if not (A==44) then goto L10 end
   if 55 > length then return false end
   A = P[54]
   if (A==6) then goto L11 end
   ::L10::
   if not (A==17) then goto L12 end
   ::L11::
   do return true end
   ::L12::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local cast = require("ffi").cast
return function(P,length)
   if length < 34 then return false end
   local v1 = cast("uint16_t*", P+12)[0]
   if v1 == 8 then
      local v2 = P[23]
      if v2 == 1 then return true end
      if v2 == 6 then return true end
      return v2 == 17
   else
      if length < 54 then return false end
      if v1 ~= 56710 then return false end
      local v3 = P[20]
      if v3 == 1 then return true end
      if length < 55 then goto L19 end
      do
         if v3 ~= 44 then goto L19 end
         if P[54] == 1 then return true end
         goto L19
      end
::L19::
      if v3 == 6 then return true end
      if length < 55 then goto L17 end
      do
         if v3 ~= 44 then goto L17 end
         if P[54] == 6 then return true end
         goto L17
      end
::L17::
      if v3 == 17 then return true end
      if length < 55 then return false end
      if v3 ~= 44 then return false end
      return P[54] == 17
   end
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 33
  br i1 %2, label %L4, label %L10

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %L6, label %L7

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 23
  %8 = load i8* %7, align 1, !tbaa !5
  switch i8 %8, label %L9 [
    i8 1, label %L10
    i8 6, label %L10
  ]

L10:                                              ; preds = %L17, %L6, %L6, %L1, %L7, %L30, %L19, %L24, %L14
  %merge = phi i1 [ %23, %L17 ], [ true, %L30 ], [ true, %L19 ], [ true, %L24 ], [ true, %L14 ], [ true, %L6 ], [ false, %L7 ], [ false, %L1 ], [ true, %L6 ]
  ret i1 %merge

L9:                                               ; preds = %L6
  %9 = icmp eq i8 %8, 17
  ret i1 %9

L7:                                               ; preds = %L4
  %10 = icmp ugt i32 %1, 53
  %11 = icmp eq i16 %5, -8826
  %or.cond = and i1 %10, %11
  br i1 %or.cond, label %L14, label %L10

L14:                                              ; preds = %L7
  %12 = getelementptr inbounds i8* %0, i64 20
  %13 = load i8* %12, align 1, !tbaa !5
  %14 = icmp eq i8 %13, 1
  br i1 %14, label %L10, label %L21

L21:                                              ; preds = %L14
  %15 = icmp ugt i32 %1, 54
  %16 = icmp eq i8 %13, 44
  %or.cond96 = and i1 %15, %16
  br i1 %or.cond96, label %L24, label %L19

L24:                                              ; preds = %L21
  %17 = getelementptr inbounds i8* %0, i64 54
  %18 = load i8* %17, align 1, !tbaa !5
  %19 = icmp eq i8 %18, 1
  br i1 %19, label %L10, label %L30

L19:                                              ; preds = %L21
  %.old = icmp eq i8 %13, 6
  br i1 %.old, label %L10, label %L17

L30:                                              ; preds = %L24
  %20 = getelementptr inbounds i8* %0, i64 54
  %21 = load i8* %20, align 1, !tbaa !5
  %22 = icmp eq i8 %21, 6
  br i1 %22, label %L10, label %L17

L17:                                              ; preds = %L19, %L30
  %23 = icmp eq i8 %13, 17
  %.not = xor i1 %15, true
  %brmerge = or i1 %23, %.not
  %.not101 = xor i1 %16, true
  %brmerge102 = or i1 %brmerge, %.not101
  br i1 %brmerge102, label %L10, label %L36

L36:                                              ; preds = %L17
  %24 = getelementptr inbounds i8* %0, i64 54
  %25 = load i8* %24, align 1, !tbaa !5
  %26 = icmp eq i8 %25, 17
  ret i1 %26
}


```
