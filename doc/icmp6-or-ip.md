# icmp6 or ip


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 7
002: A = P[20:1]
003: if (A == 58) goto 8 else goto 4
004: if (A == 44) goto 5 else goto 9
005: A = P[54:1]
006: if (A == 58) goto 8 else goto 9
007: if (A == 2048) goto 8 else goto 9
008: return 65535
009: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==34525) then goto L6 end
   if 21 > length then return false end
   A = P[20]
   if (A==58) then goto L7 end
   if not (A==44) then goto L8 end
   if 55 > length then return false end
   A = P[54]
   if (A==58) then goto L7 end
   goto L8
   ::L6::
   if not (A==2048) then goto L8 end
   ::L7::
   do return true end
   ::L8::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local cast = require("ffi").cast
return function(P,length)
   if length < 14 then return false end
   if length < 54 then goto L7 end
   do
      if cast("uint16_t*", P+12)[0] ~= 56710 then goto L7 end
      local v1 = P[20]
      if v1 == 58 then return true end
      if length < 55 then goto L7 end
      if v1 ~= 44 then goto L7 end
      if P[54] == 58 then return true end
      goto L7
   end
::L7::
   return cast("uint16_t*", P+12)[0] == 8
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 13
  br i1 %2, label %L4, label %L12

L4:                                               ; preds = %L1
  %3 = icmp ugt i32 %1, 53
  %4 = getelementptr inbounds i8* %0, i64 12
  %5 = bitcast i8* %4 to i16*
  %6 = load i16* %5, align 2, !tbaa !1
  %7 = icmp eq i16 %6, -8826
  %or.cond37 = and i1 %3, %7
  br i1 %or.cond37, label %L10, label %L7

L10:                                              ; preds = %L4
  %8 = getelementptr inbounds i8* %0, i64 20
  %9 = load i8* %8, align 1, !tbaa !5
  %10 = icmp eq i8 %9, 58
  br i1 %10, label %L12, label %L13

L12:                                              ; preds = %L1, %L16, %L10
  %merge = phi i1 [ true, %L16 ], [ true, %L10 ], [ false, %L1 ]
  ret i1 %merge

L13:                                              ; preds = %L10
  %11 = icmp ugt i32 %1, 54
  %12 = icmp eq i8 %9, 44
  %or.cond = and i1 %11, %12
  br i1 %or.cond, label %L16, label %L7

L16:                                              ; preds = %L13
  %13 = getelementptr inbounds i8* %0, i64 54
  %14 = load i8* %13, align 1, !tbaa !5
  %15 = icmp eq i8 %14, 58
  br i1 %15, label %L12, label %L7

L7:                                               ; preds = %L4, %L16, %L13
  %16 = phi i16 [ -8826, %L16 ], [ -8826, %L13 ], [ %6, %L4 ]
  %17 = icmp eq i16 %16, 8
  ret i1 %17
}


```
