# src host 192.68.1.1 and less 100


## BPF

```
000: A = P[12:2]
001: if (A == 2048) goto 2 else goto 4
002: A = P[26:4]
003: if (A == 3225682177) goto 8 else goto 11
004: if (A == 2054) goto 6 else goto 5
005: if (A == 32821) goto 6 else goto 11
006: A = P[28:4]
007: if (A == 3225682177) goto 8 else goto 11
008: A = length
009: if (A > 100) goto 11 else goto 10
010: return 65535
011: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==2048) then goto L3 end
   if 30 > length then return false end
   A = bit.bor(bit.lshift(P[26], 24),bit.lshift(P[26+1], 16), bit.lshift(P[26+2], 8), P[26+3])
   if (A==-1069285119) then goto L7 end
   goto L10
   ::L3::
   if (A==2054) then goto L5 end
   if not (A==32821) then goto L10 end
   ::L5::
   if 32 > length then return false end
   A = bit.bor(bit.lshift(P[28], 24),bit.lshift(P[28+1], 16), bit.lshift(P[28+2], 8), P[28+3])
   if not (A==-1069285119) then goto L10 end
   ::L7::
   A = bit.tobit(length)
   if (runtime_u32(A)>100) then goto L10 end
   do return true end
   ::L10::
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
      if cast("uint32_t*", P+26)[0] == 16860352 then goto L6 end
      goto L7
   else
      if length < 42 then return false end
      if v1 == 1544 then goto L12 end
      do
         if v1 == 13696 then goto L12 end
         return false
      end
::L12::
      if cast("uint32_t*", P+28)[0] == 16860352 then goto L6 end
      goto L7
   end
::L6::
   do
      return length <= 100
   end
::L7::
   return false
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 34
  br i1 %2, label %then, label %merge

then:                                             ; preds = %then2, %L12, %else3, %entry
  ret i1 false

merge:                                            ; preds = %entry
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %then2, label %else3

then2:                                            ; preds = %merge
  %7 = getelementptr inbounds i8* %0, i64 26
  %8 = bitcast i8* %7 to i32*
  %9 = load i32* %8, align 4, !tbaa !5
  %10 = icmp eq i32 %9, 16860352
  br i1 %10, label %L6, label %then

else3:                                            ; preds = %merge
  %11 = icmp ult i32 %1, 42
  br i1 %11, label %then, label %L12

L12:                                              ; preds = %else3
  %12 = getelementptr inbounds i8* %0, i64 28
  %13 = bitcast i8* %12 to i32*
  %14 = load i32* %13, align 4, !tbaa !5
  %15 = icmp eq i32 %14, 16860352
  br i1 %15, label %L6, label %then

L6:                                               ; preds = %L12, %then2
  %16 = icmp ult i32 %1, 101
  ret i1 %16
}


```
