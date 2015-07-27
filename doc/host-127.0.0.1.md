# host 127.0.0.1


## BPF

```
000: A = P[12:2]
001: if (A == 2048) goto 2 else goto 6
002: A = P[26:4]
003: if (A == 2130706433) goto 12 else goto 4
004: A = P[30:4]
005: if (A == 2130706433) goto 12 else goto 13
006: if (A == 2054) goto 8 else goto 7
007: if (A == 32821) goto 8 else goto 13
008: A = P[28:4]
009: if (A == 2130706433) goto 12 else goto 10
010: A = P[38:4]
011: if (A == 2130706433) goto 12 else goto 13
012: return 65535
013: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==2048) then goto L5 end
   if 30 > length then return false end
   A = bit.bor(bit.lshift(P[26], 24),bit.lshift(P[26+1], 16), bit.lshift(P[26+2], 8), P[26+3])
   if (A==2130706433) then goto L11 end
   if 34 > length then return false end
   A = bit.bor(bit.lshift(P[30], 24),bit.lshift(P[30+1], 16), bit.lshift(P[30+2], 8), P[30+3])
   if (A==2130706433) then goto L11 end
   goto L12
   ::L5::
   if (A==2054) then goto L7 end
   if not (A==32821) then goto L12 end
   ::L7::
   if 32 > length then return false end
   A = bit.bor(bit.lshift(P[28], 24),bit.lshift(P[28+1], 16), bit.lshift(P[28+2], 8), P[28+3])
   if (A==2130706433) then goto L11 end
   if 42 > length then return false end
   A = bit.bor(bit.lshift(P[38], 24),bit.lshift(P[38+1], 16), bit.lshift(P[38+2], 8), P[38+3])
   if not (A==2130706433) then goto L12 end
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
      if cast("uint32_t*", P+26)[0] == 16777343 then return true end
      return cast("uint32_t*", P+30)[0] == 16777343
   else
      if length < 42 then return false end
      if v1 == 1544 then goto L12 end
      do
         if v1 == 13696 then goto L12 end
         return false
      end
::L12::
      if cast("uint32_t*", P+28)[0] == 16777343 then return true end
      return cast("uint32_t*", P+38)[0] == 16777343
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

then:                                             ; preds = %L12, %else3, %then2, %entry
  %merge22 = phi i1 [ false, %entry ], [ true, %then2 ], [ false, %else3 ], [ true, %L12 ]
  ret i1 %merge22

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
  %10 = icmp eq i32 %9, 16777343
  br i1 %10, label %then, label %merge4

merge4:                                           ; preds = %then2
  %11 = getelementptr inbounds i8* %0, i64 30
  %12 = bitcast i8* %11 to i32*
  %13 = load i32* %12, align 4, !tbaa !5
  %14 = icmp eq i32 %13, 16777343
  ret i1 %14

else3:                                            ; preds = %merge
  %15 = icmp ult i32 %1, 42
  br i1 %15, label %then, label %L12

L12:                                              ; preds = %else3
  %16 = getelementptr inbounds i8* %0, i64 28
  %17 = bitcast i8* %16 to i32*
  %18 = load i32* %17, align 4, !tbaa !5
  %19 = icmp eq i32 %18, 16777343
  br i1 %19, label %then, label %merge17

merge17:                                          ; preds = %L12
  %20 = getelementptr inbounds i8* %0, i64 38
  %21 = bitcast i8* %20 to i32*
  %22 = load i32* %21, align 4, !tbaa !5
  %23 = icmp eq i32 %22, 16777343
  ret i1 %23
}


```
