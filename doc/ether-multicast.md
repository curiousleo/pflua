# ether multicast


## BPF

```
000: A = P[0:1]
001: if (A & 1 != 0) goto 2 else goto 3
002: return 65535
003: return 0
```


## BPF cross-compiled to Lua

```
return function (P, length)
   local A = 0
   if 1 > length then return false end
   A = P[0]
   if (bit.band(A, 1)==0) then goto L2 end
   do return true end
   ::L2::
   do return false end
   error("end of bpf")
end
```


## Direct pflang compilation

```
local band = require("bit").band
return function(P,length)
   if length < 1 then return false end
   return band(P[0],1) ~= 0
end

```

## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp eq i32 %1, 0
  br i1 %2, label %L5, label %L4

L4:                                               ; preds = %L1
  %3 = load i8* %0, align 1, !tbaa !1
  %4 = and i8 %3, 1
  %5 = icmp ne i8 %4, 0
  ret i1 %5

L5:                                               ; preds = %L1
  ret i1 false
}


```
