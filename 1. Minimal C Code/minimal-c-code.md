# Understanding IR of Minimal C Code:

# The Most Basic C Code:
Take a look at the following code:
```minimal.c
int main(void) {
    return 0;
}
```

This is the most basic C code possible:
    - No command line arguments.
    - No imported files.
    - Only a return value in the function body.
    - (you could argue that you could make it more basic by changing the return type to `void`, but that does not conform to c89 standards.

Lets generate the IR:
```
$ clang -std=c89 -S -emit-llvm minimal.c
```

And lets peak at its contents:
```minimal.ll
; ModuleID = 'minimal.c'
source_filename = "minimal.c"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  ret i32 0
}

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Debian clang version 16.0.6 (27)"}
```

To start lets have a look and see what sensible guesses we can make from this:
    - Line 1-4 seems to contain some form of metadata about the system?
    - `%` seems to be the symbol for referencing a register.
    - Line 7-11 describes the operations of the `main()` function and seems to work in the following way (semi-colons are comments btw):
    ```
    %1 = alloca i32, align 4        ; Allocate 32 bits to register 1.
    store i32 0, ptr %1, align 4    ; Store the value '0' to register 1.
    ret i32 0                       ; Return with the value '0'.
    ```
    If you change minimal.c to `return 1;` instead, the only change that occurs is the `ret` line, which becomes:
    ```
    ret i32 1
    ```
    So the `store` operation in line 9 doesn't seem to have any relevance to the return value. So what does it do? no idea... yet.
    - The format for the instruction set seems to be `[operation] [source value], [destination address], align [number]`. I have a suspicion that `align` is something to do with shifting a pointer x number of bytes, but we shall see.
