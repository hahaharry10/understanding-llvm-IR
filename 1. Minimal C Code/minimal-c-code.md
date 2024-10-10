# Understanding IR of Minimal C Code:
This section slowly develops C code from the most basic main function, to outputting `Hello World!`. Incremently understanding the IR.

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
<a id="noundef-expl"></a>
- `noundef` = Assigned to return types and parameters. Tells the compiler to make optimisations assuming the data will not contain undefined behaviour.
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
    - `i32`; number of bits allocated to return type. or i32 means a 32 bit integer.
    - `@main`: 
    - `i32 noundef %0`: memory where 32 bit integer parameter is store, is assigned to local register `0` with [noundef](#noundef-expl) optimisation.
    - `ptr noundef %1`: memory where ptr parameter is stored, is assigned to register `1` with [noundef](#noundef-expl) optimisation.
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
  
 
### Hello World:
Now it is the moment we all have been waiting for. Take a look at `helloWorld.c`:
```helloWorld.c
#include <stdio.h>

int main( int argc, char** argv ) {
    printf("Hello World!\n");
    return 0;
}
```
Which has the following additions:
- Imported Library.
- `printf` function call.
- String constant.

Look at `helloWorld.ll`:
```
; ModuleID = 'helloWorld.c'
source_filename = "helloWorld.c"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

@.str = private unnamed_addr constant [14 x i8] c"Hello World!\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  %6 = call i32 (ptr, ...) @printf(ptr noundef @.str)
  ret i32 0
}

declare i32 @printf(ptr noundef, ...) #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Debian clang version 16.0.6 (27)"}
```
Other than the file name changes at the top, `helloWorld.ll` is similar to `cla.ll` but has these lines extra:
- Line 6: The definition of a global string constant.
- Line 16: `printf` function call.
- Line 23: global function declaration for `printf`.
- Line 23: New attribute group.

Let's get understanding:
```ll
@.str = private unnamed_addr constant [14 x i8] c"Hello World!\0A\00", align 1
```
- All string constants are stored in global variables.
- `private`: String is only accessible within current module.
- `unnamed_addr`: Marks address as insignificant (allows optimisations such as identical strings being combined into one global constant).
- `constant`: Means contents will not be modified (allows for optimisations such as storing constants in read only memory).
- `[14 x i8]`: Array of 14 8bit integer (char) elements.
- `c"..."`: C-Style string.
- Escape characters must be in hex.
    - `\0A` = Line feed (hex for `\n`).
    - `\00` = Null character.
- `align`: Set alignment for the starting address. Address of each character in the string is contiuously stored after the starting address. Alignment does not cause padding between address of each char.

```ll
%6 = call i32 (ptr, ...) @printf(ptr noundef @.str)
```
- `call`: Transfer control flow to specified function.
- `i32`: Function return type.
- `(ptr, ...)`: Specifies argument signature (in this case, first argument is a pointer, and there can be various proceeding arguments). This signature is added to help type checking and improve readability of the call.
- `@printf`: Function being called is global variable `printf`.
- `(ptr noundef @.str)`: Only argument is the non-udefined global string constant `@.str`.

```ll
declare i32 @printf(ptr noundef, ...) #1
```
- Function declaration.
- `declare`: Signifies function declaration.
- `i32`: Return type of 32bit integer.
- `@printf`: Global function name.
- `(ptr noundef, ...)`: variable argument declaration, with first argument being a non-undefined pointer.
- `#1`: Function attribute group.


### Recap:
So what can we learn from these two examples:
- Registers are used to access memory in the stack. Accessing memory in the stack requires a register holding the memory address.
- `alloca` allocates memory in the stack.
- "The alignment is only optional when parsing textual IR; for in-memory IR, it is always present." - [llvm documentation](https://llvm.org/docs/LangRef.html#syntax), so best practice is to always use the alignment property when writing IR.
- To store a value, you have to:
    1. Allocate memory in the stack. Using the `alloca` command:
    ```
    %[REGISTER ID] = alloca [DTYPE], align [ALIGNMENT]
    ```
    2. Assign the value to memory using the `store` command:
    ```
    store [dtype] [REGISTER|VALUE], ptr [DESTINATION REGISTER], align [ALIGNMENT]
    ```
- Functions are defined in the following format:
    ```
    define [PROPERTIES] [RETURN TYPE] @[FUNCTION NAME]( [DTYPE] %[REGISTER ID], ... ) #[ATTRIBUTE GROUP] { ... }
    ```
    - `int argc` is stored into register `%0` as datatype `i32`.
    - `char** argv` is stored into register `%1` as datatype `ptr`.
- `@` denotes a global identifier.
- `;` prepends single-line comments.
