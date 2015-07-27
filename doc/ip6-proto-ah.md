# ip6 proto \ah


## BPF

```
000: A = P[12:2]
001: if (A == 34525) goto 2 else goto 8
002: A = P[20:1]
003: if (A == 51) goto 7 else goto 4
004: if (A == 44) goto 5 else goto 8
005: A = P[54:1]
006: if (A == 51) goto 7 else goto 8
007: return 65535
008: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 14 > length then return false end
   A = bit.bor(bit.lshift(P[12], 8), P[12+1])
   if not (A==34525) then goto L7 end
   if 21 > length then return false end
   A = P[20]
   if (A==51) then goto L6 end
   if not (A==44) then goto L7 end
   if 55 > length then return false end
   A = P[54]
   if not (A==51) then goto L7 end
   ::L6::
   do return true end
   ::L7::
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
   local v1 = P[20]
   if v1 == 51 then return true end
   if length < 55 then return false end
   if v1 ~= 44 then return false end
   return P[54] == 51
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 54
  br i1 %2, label %then, label %merge

then:                                             ; preds = %merge5, %merge, %merge1, %entry
  %merge18 = phi i1 [ false, %merge ], [ false, %entry ], [ true, %merge1 ], [ false, %merge5 ]
  ret i1 %merge18

merge:                                            ; preds = %entry
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, -8826
  br i1 %6, label %merge1, label %then

merge1:                                           ; preds = %merge
  %7 = getelementptr inbounds i8* %0, i64 20
  %8 = load i8* %7, align 1, !tbaa !5
  %9 = icmp eq i8 %8, 51
  br i1 %9, label %then, label %merge5

merge5:                                           ; preds = %merge1
  %10 = icmp ugt i32 %1, 54
  %11 = icmp eq i8 %8, 44
  %or.cond = and i1 %10, %11
  br i1 %or.cond, label %merge13, label %then

merge13:                                          ; preds = %merge5
  %12 = getelementptr inbounds i8* %0, i64 54
  %13 = load i8* %12, align 1, !tbaa !5
  %14 = icmp eq i8 %13, 51
  ret i1 %14
}


```
