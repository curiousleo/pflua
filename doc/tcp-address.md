# ether[&tcp[0]] = tcp[0]


## BPF

```
Filter failed to compile: ../src/pf/libpcap.lua:66: pcap_compile failed```


## BPF cross-compiled to Lua

```
Filter failed to compile: ../src/pf/libpcap.lua:66: pcap_compile failed
```


## Direct pflang compilation

```
local lshift = require("bit").lshift
local band = require("bit").band
local cast = require("ffi").cast
return function(P,length)
   if length < 54 then return false end
   if cast("uint16_t*", P+12)[0] ~= 8 then return false end
   if P[23] ~= 6 then return false end
   if band(cast("uint16_t*", P+20)[0],65311) ~= 0 then return false end
   local v1 = lshift(band(P[14],15),2)
   if (v1 + 15) > length then return false end
   local v2 = P[(v1 + 14)]
   return v2 == v2
end

```

pcap_compile failed!: syntax error
pcap_compile failed!: syntax error
## Direct pflang compilation with terra

```

; Function Attrs: nounwind
define zeroext i1 @"$anon (../src/pf/terra.t:128)"(i8*, i32) #0 {
L1:
  %2 = icmp ugt i32 %1, 53
  br i1 %2, label %L4, label %L13

L4:                                               ; preds = %L1
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %L6, label %L13

L6:                                               ; preds = %L4
  %7 = getelementptr inbounds i8* %0, i64 23
  %8 = load i8* %7, align 1, !tbaa !5
  %9 = icmp eq i8 %8, 6
  br i1 %9, label %L8, label %L13

L8:                                               ; preds = %L6
  %10 = getelementptr inbounds i8* %0, i64 20
  %11 = bitcast i8* %10 to i16*
  %12 = load i16* %11, align 2, !tbaa !1
  %13 = and i16 %12, -225
  %14 = icmp eq i16 %13, 0
  br i1 %14, label %L10, label %L13

L10:                                              ; preds = %L8
  %15 = getelementptr inbounds i8* %0, i64 14
  %16 = load i8* %15, align 1, !tbaa !5
  %17 = zext i8 %16 to i32
  %18 = shl nuw nsw i32 %17, 2
  %19 = and i32 %18, 60
  %20 = add nuw nsw i32 %19, 15
  %21 = icmp ugt i32 %20, %1
  br i1 %21, label %L13, label %L12

L12:                                              ; preds = %L13, %L10
  %merge = phi i1 [ true, %L10 ], [ false, %L13 ]
  ret i1 %merge

L13:                                              ; preds = %L10, %L1, %L4, %L6, %L8
  br label %L12
}


```
