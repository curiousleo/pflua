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
define zeroext i1 @"$anon (../src/pf/terra.t:173)"(i8*, i32) #0 {
entry:
  %2 = icmp ult i32 %1, 54
  br i1 %2, label %then, label %merge

then:                                             ; preds = %merge5, %merge1, %merge, %entry
  ret i1 false

merge:                                            ; preds = %entry
  %3 = getelementptr inbounds i8* %0, i64 12
  %4 = bitcast i8* %3 to i16*
  %5 = load i16* %4, align 2, !tbaa !1
  %6 = icmp eq i16 %5, 8
  br i1 %6, label %merge1, label %then

merge1:                                           ; preds = %merge
  %7 = getelementptr inbounds i8* %0, i64 23
  %8 = load i8* %7, align 1, !tbaa !5
  %9 = icmp eq i8 %8, 6
  br i1 %9, label %merge5, label %then

merge5:                                           ; preds = %merge1
  %10 = getelementptr inbounds i8* %0, i64 20
  %11 = bitcast i8* %10 to i16*
  %12 = load i16* %11, align 2, !tbaa !1
  %13 = and i16 %12, -225
  %14 = icmp eq i16 %13, 0
  br i1 %14, label %merge9, label %then

merge9:                                           ; preds = %merge5
  %15 = getelementptr inbounds i8* %0, i64 14
  %16 = load i8* %15, align 1, !tbaa !5
  %17 = zext i8 %16 to i32
  %18 = shl nuw nsw i32 %17, 2
  %19 = and i32 %18, 60
  %20 = add nuw nsw i32 %19, 15
  %not. = icmp ule i32 %20, %1
  ret i1 %not.
}


```
