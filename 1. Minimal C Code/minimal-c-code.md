# Understanding IR of Minimal C Code:

### The Most Basic C Code:
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
- First 4 lines seems to contain some form of metadata about the system?
- `%` seems to be the symbol for referencing a register.
- Line 7-11 describes the operations of the `main()` function and seems to work in the following way (semi-colons are comments btw):
    ```
    %1 = alloca i32, align 4        ; Allocate 32 bits to memory and stores address in register 1.
    store i32 0, ptr %1, align 4    ; Store the value '0' to the memory address specified by register 1.
    ret i32 0                       ; Return with the value '0'.
    ```
    If you change minimal.c to `return 1;` instead, the only change that occurs is the `ret` line, which becomes:
    ```
    ret i32 1
    ```
    So the `store` operation in line 9 doesn't seem to have any relevance to the return value. So what does it do? no idea... yet.
- The format for the instruction set seems to be `[operation] [source value], [destination address], align [number]`.

### Some Notes on Syntax:
Thought to read the [llvm documentation](https://llvm.org/docs/LangRef.html#syntax) to learn a few things:
- `@` = prefix global identifiers.
- `%` = prefix local identifiers.
<a name="noundef">
- `noundef` = Assigned to return types and parameters. Tells the compiler to make optimisations assuming the data will not contain undefined behaviour.
</a>
- `dso_local` = means the symbol can be referenced within the same linkage unit.
- `#` defines an attribute group.

### Command Line Arguments:
Now lets add the next bit of complexity, command line arguments. Look at `cla.c`:
```cla.c
int main( int argc, char** argv ) {
    return 0;
}
```

and its corresponding IR:
```cla.ll
; ModuleID = 'cla.c'
source_filename = "cla.c"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
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
Obviously `ModuleID` and `source_filename` have changed. The other changes have only occurred in the main() function definition and body.

Let's try depict each line:
- ` define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 { `
    - `define`: function deifnition keyword.
    - `i32`; number of bits allocated to return type? or i32 means a 32 bit integer.
    - `@main`: 
    - `i32 noundef %0`: 32 bit integer parameter assigned to local register `0` with [noundef](#noundef) optimisation.
    - `ptr noundef %1`: ptr assigned to register `1` with [noundef](#noundef) optimisation.
    - `#0`: gives the function attributes outlines in line 17.
- ` %3 = alloca i32, align 4 `: allocate memory space for a 32 bit integer and store address in register 3. Align on 4-byte boundary.
- ` %4 = alloca i32, align 4 `: another operation as above but stores this address in register 4.
- ` %5 = alloca ptr, align 8 `: allocate memory space for a pointer and store address in register 5. Align on 8-byte boundary.
- ` store i32 0, ptr %3, align 4 `:
    - Store 32 bit integer to pointer 3.
    - `align 4` specifies that the memory address stored in destination register `%3` lies on a 4 byte boundary.
- ` store i32 %0, ptr %4, align 4 `:
    - Store the 32 bit integer stored in the memory address specified by register `%0` into the memory address specified by register `%4`.
    - Again, `align 4` specifies that the memory address stored in destination register `%4` lies on a 4 byte boundary.
- ` store ptr %1, ptr %5, align 8 `:
    - Store pointer (8 bytes) stored in the memory address specified by register `%1` into the memory address specified by register `%5`.
    - `align 8` specifies that the memory address stored in destination register `%5` lies on an 8 byte boundary.
- ` ret i32 0 `: Return a 32 bit integer of value `0`.
  
