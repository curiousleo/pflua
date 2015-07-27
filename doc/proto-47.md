# proto 47


## BPF

```
000: A = P[12:2]
001: if (A == 2048) goto 2 else goto 4
002: A = P[23:1]
003: if (A == 47) goto 10 else goto 11
004: if (A == 34525) goto 5 else goto 11
005: A = P[20:1]
006: if (A == 47) goto 10 else goto 7
007: if (A == 44) goto 8 else goto 11
008: A = P[54:1]
009: if (A == 47) goto 10 else goto 11
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
   if 24 > length then return false end
   A = P[23]
   if (A==47) then goto L9 end
   goto L10
   ::L3::
   if not (A==34525) then goto L10 end
   if 21 > length then return false end
   A = P[20]
   if (A==47) then goto L9 end
   if not (A==44) then goto L10 end
   if 55 > length then return false end
   A = P[54]
   if not (A==47) then goto L10 end
   ::L9::
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
   if v1 ~= 8 then goto L7 end
   do
      if P[23] == 47 then return true end
      goto L7
   end
::L7::
   if length < 54 then return false end
   if v1 ~= 56710 then return false end
   local v2 = P[20]
   if v2 == 47 then return true end
   if length < 55 then return false end
   if v2 ~= 44 then return false end
   return P[54] == 47
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 54
  br i1 %2, label %then, label %merge5

then:                                             ; preds = %merge13, %merge5, %merge9, %entry
  %merge26 = phi i1 [ false, %merge5 ], [ false, %entry ], [ true, %merge9 ], [ false, %merge13 ]
  ret i1 %merge26

merge5:                                           ; preds = %entry
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, -8826
  br i1 %6, label %merge9, label %then

merge9:                                           ; preds = %merge5
  %7 = getelementptr inbounds i8* %0, i64 20
  %8 = load i8* %7, align 1, !tbaa !5
  %9 = icmp eq i8 %8, 47
  br i1 %9, label %then, label %merge13

merge13:                                          ; preds = %merge9
  %10 = icmp ugt i32 %1, 54
  %11 = icmp eq i8 %8, 44
  %or.cond27 = and i1 %10, %11
  br i1 %or.cond27, label %merge21, label %then

merge21:                                          ; preds = %merge13
  %12 = getelementptr inbounds i8* %0, i64 54
  %13 = load i8* %12, align 1, !tbaa !5
  %14 = icmp eq i8 %13, 47
  ret i1 %14
}


```
