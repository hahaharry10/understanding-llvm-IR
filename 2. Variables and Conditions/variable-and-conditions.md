# Variables:
This descovers how variables are stored and operated on in IR. Now that we are getting the hang of how IR is formed, we are going to start picking up the pace.

My first thought is that this is going to be an easy section. My guess is a variable lifecyle is as follows:
- Allocate storage in stack and assign pointer to a new register: ` %[REGISTER ID] = alloca [DTYPE], align [ALIGNMENT] `
- Store a value into the memory space:
    - Direct Addressing: ` store [DTYPE] %[SOURCE REGISTER ID], ptr %[DESTINATION REGISTER ID], align [ALIGNMENT] `
    - Immediate Addressing: ` store [DTYPE] [VALUE], ptr %[DESTINATION REGISTER ID], align [ALIGNMENT] `
- Operate on the value: ` [OPERATION] [DTYPE] [OPERAND 1], [OPERAND 2] `

### Registers:
Before we delve into variables lets understand a little more about intermediate representation and their use of registers. The following information is taken from sources:
- Chisnall, D. 2017. LLVM IR and Transform Pipeline [Online]. [12 October 2024]. Available from: https://llvm.org/devmtg/2017-06/1-Davis-Chisnall-LLVM-2017.pdf
- Gao, X. Unavailable. Unlimited Register Machine [Online]. [13 October 2024]. Available from: https://www.cs.sjtu.edu.cn/~gao-xf/computability/Document/Slide03-URM.pdf

Intermediate Representation is an Unlimited Single-Assignment Register Machine instruction set. This means that it follows the following properties:
- Unlimited Register Machine:
    - IR acts as if there are unlimited registers.
    - Programmer does not need to worry about register efficiency.
    - This abstraction allows for easier code generation and optimisation.
- Static Single Assignment:
    - Each register can only be assigned to once.
    - New registers are created to hold the result of an operation.
    - Variables can be simulated by storing a pointer to stack memory, and modifying the stack.


### Single Variable:
Have a look at `singleVariable.c` and its generated IR in `singleVariable.ll`. The only addition to the C file is the introduction of an integer, and its assignment to the value 3. The IR that represents these operations are:
```
%6 = alloca i32, align 4
store i32 3, ptr %6, align 4
```
So in short, variable declaration and assignment is easy. You assign to a register, then you use the register.


### Variable Operations:
Look at `variableOperations.c` and `variableOperations.ll`. Below is the function body of `@main` with comments outlining each line's purpose:
```variableOperations.ll
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
    %3 = alloca i32, align 4            ; Allocate 32 btis (integer) of memory to stack and store pointer in register 3.
    %4 = alloca i32, align 4            ; Allocate 32 bits (integer) of memory to stack and store pointer in register 4.
    %5 = alloca ptr, align 8            ; Allocate 8 bytes (pointer) of memory to stack and store pointer in register 5.
    %6 = alloca i32, align 4            ; Allocate 32 bits (integer) of memory to stack and store pointer in register 6 (represents variable i).
    %7 = alloca i32, align 4            ; Allocate 32 bits (integer) of memory to stack and store pointer in register 7 (represents variable j).
    %8 = alloca i8, align 1             ; Allocate 8 bits (char) of memory to stack and store pointer in register 8 (represents variable k).
    store i32 0, ptr %3, align 4        ; write the value of 0 to register 3.
    store i32 %0, ptr %4, align 4       ; Write the contents of register 0 (argc) to register 4.
    store ptr %1, ptr %5, align 8       ; Write the contents of register 1 (argv) to register 5.
    store i32 50, ptr %6, align 4       ; Write the value of 50 to register 6 (i).
    store i32 20, ptr %7, align 4       ; Write the value of 20 to register 7 (j).
    %9 = load i32, ptr %6, align 4      ; Assign the contents of register 6 (i) into register 6.
    %10 = load i32, ptr %7, align 4     ; Assign the contents of register 7 (j) into register 7.
    %11 = add nsw i32 %9, %10           ; Add the contents of register 6 (i) and register 7 (j), assigning the result into register 11.
    store i32 %11, ptr %6, align 4      ; Store the result that is stored into register 11, back into the heap memory pointed to by register 6 (i).
    store i8 65, ptr %8, align 1        ; Write the value of 65 ('A') into register 8 (k).
    %12 = load i8, ptr %8, align 1      ; Read the contents of register 8 and store the value into register 12.
    %13 = add i8 %12, 1                 ; Increment register 12 by one and store result into register 13.
    store i8 %13, ptr %8, align 1       ; Store the result of the incrementation, which is stores in register 13, into register 8 (k).
    %14 = load i8, ptr %8, align 1      ; Load the data in register 8 and store into register 14.
    %15 = add i8 %14, 1                 ; Increment register 14 by 1 and store result in register 15.
    store i8 %15, ptr %8, align 1       ; Store the result, stored in register 15, into register 8.
    ret i32 0
}
```

The code starts by allocating registers 3 to 8 (with register 0 and 1 used for command line arguments). Let's ignore registers 3-5 as they are irrelevant to the variables' operations. Regiset 6 and 7 are allocated 32 bits of memory in the stack, and register 8 is allocated 8 bits of memory in the stack. (skipping to line 17) The value of 50 is written into the address pointed to by register 6, and 20 is written to the address pointed to by register 7. Now the memory represented by registers 6 and 7 represent the value assigned to values `i` and `j` respectively.

The value of `i` (pointed to by register 6) is laoded into register 9, and the value of `j` (pointed to by register 7) is loaded into register 10. Register 11 is assigned to the result of the result of the proceeding `add` operation (`nsw` (No Signed Wrap) means poison value is returned if signed overflow occurs). As the C code assigns the result back to variable `i`, the resulting value (now stored in register 11) is stored into the memory pointed to by register 6 (line 11).

Then the value of 'A' (65) is written into the memory pointed to by register 8, so now the memory pointed to by register 8 stores the value assigned to variable `k`. The value of `k` is loaded into register 12, and the `add` operation is used to increment the value by 1. The result is assigned to register 13 and the value of register 13 is written into the memory pointed to by register 8.

Here we see that to simulate a variable while conforming to SSA principles, registers are assigned a pointer to memory in the stack, and that memory can be updated and rewritten as many times as needed without reassigning to the same register. Furthermore, to operate on a value, you must `load` the operants into a register, and store the result into another regester, and then use `store` to write the value in the register into memory.

Pretty easy right? It just gets quite lengthy.

### Conditions:
Let's start with `simpleCondition.c` that contains a simple condition statement:
```simpleCondition.c
int main( int argc, char** argv ) {
    int cond;
    int result;
    if( cond > 0 ) {
        result = 1;
    } else {
        result = 0;
    }
    return 0;
}
```

This is the body of the `@main` function in the generated IR in `simpleCondition.ll`:
```simpleCondition.ll
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  store i32 0, ptr %6, align 4
  %8 = load i32, ptr %6, align 4
  %9 = icmp sgt i32 %8, 0
  br i1 %9, label %10, label %11

10:                                               ; preds = %2
  store i32 1, ptr %7, align 4
  br label %12

11:                                               ; preds = %2
  store i32 0, ptr %7, align 4
  br label %12

12:                                               ; preds = %11, %10
  ret i32 0
}
```

Straight away there are a few new features:
- `br` - Line 18
- `label` datatype - Lines 18, 21, 25.
- Branches in lines 20, 24, 28.

The implementation looks similar to assembly where everything is handles with a jump/ go-to.

Let's experiment by seeing the corresponding IR to different conditions:
- C: ` cond > 0 `
- IR: 
    ```
    %9 = icmp sgt i32 %8, 0
    br i1 %9, label %10, label %11
    ```
- C: ` cond == 0 `
- IR:
    ```
    %9 = icmp eq i32 %8, 0
    br i1 %9, label %10, label %11
    ```
- C: ` cond < 0 `
- IR:
    ```
    %9 = icmp slt i32 %8, 0
    br i1 %9, label %10, label %11
    ```
- C: ` cond <= 0 `
- IR:
    ```
    %9 = icmp sle i32 %8, 0
    br i1 %9, label %10, label %11
    ```

All these conditionals vary in comparitor, whos return value is assigned to a register, and the contents of that register is used in a `br` statement to decide on the right branch to take.

Seems easy enough. Let's look at the documentation to gain clarity on some of the new syntax here:
- `i1`: Single bit integer, to represent either `true` or `false` (or `1` or `0`).
- `label`: Datatype representing code labels.
- `br`:
    - Usage: `br i1 <cond>, label <branch 1>, label <branch 2>`
    - Takes in an `i1` value and 2 `label` values.
    - Evaluates the `i1` argument and if true (1), control flows to `<branch 1>`. If false, control flows to `<branch 2>`.
    - An unconditional branches are represented with `br label <branch>`.
- `icmp`:
    `<result> = icmp <cond> <type> <opt1>, <opt2>`
    - Returns either boolean value (`i1`) or vector of boolean values (`N x i1`).
    - Compares two operands, `opt1` and `opt2`, according to the condition keyword, `cond`.
    - Valid condition keywords (see [documentation](https://llvm.org/docs/LangRef.html#label-type) for exhaustive list):
        - `eq`: equal
        - `sgt`: Signed greater than
        - `slt`: Signed less than
        - `sle`: Signed less than or equal

Labels? Labels are identifiers given to basic blocks. Labels are part of the local register numbering, meaning that if a label is marked `10:`, then `%10` represents that label and cannot be reassigned.

Now we can understand (or at least) recognise the operations of a conditional statement lets look at a multi-conditional algorithm. Look at `ifelse.c`:
```ifelse.c
int main( int argc, char** argv ) {
    int cond;
    int result;
    
    cond = 0;
    if( cond == 0 ) {
        result = 0;
    } else if ( cond < 0 ) {
        result = -1;
    } else {
        result = 1;
    }

    return 0;
}
```

And the corresponding body of `@main` in `ifelse.ll`:
```ifelse.ll
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  store i32 0, ptr %6, align 4
  %8 = load i32, ptr %6, align 4
  %9 = icmp eq i32 %8, 0
  br i1 %9, label %10, label %11

10:                                               ; preds = %2
  store i32 0, ptr %7, align 4
  br label %17

11:                                               ; preds = %2
  %12 = load i32, ptr %6, align 4
  %13 = icmp slt i32 %12, 0
  br i1 %13, label %14, label %15

14:                                               ; preds = %11
  store i32 -1, ptr %7, align 4
  br label %16

15:                                               ; preds = %11
  store i32 1, ptr %7, align 4
  br label %16

16:                                               ; preds = %15, %14
  br label %17

17:                                               ; preds = %16, %10
  ret i32 0
}
```

Looks scary, but it is actually everything we have learned from single conditions, but now its all nested. Think of the IR as working in the following manner:
```c
if( cond == 0 ) {
    result = 0;
}
else {
    if( cond < 0 ) {
        result = -1;
    }
    else {
        result = 1;
    }
}
```

If we see it as multiple `if` conditions nested inside the parent conditions `else`, it is fairly simple to understand.


### Switch Statements:
Apparently there are switch statements in IR. Look at `switch.c`:
```switch.c
int main( int argc, char** argv ) {
    int cond;
    int result;

    cond = 0;
    switch( cond ) {
        case 0:
            result = 0;
            break;
        case 1:
            result = 1;
            break;
        case 2:
            result = 2;
            break;
        default:
            result = 3;
            break;
    }

    return result;
}
```

and the corresponding `@main` body in `switch.ll`:
```switch.ll
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  store i32 0, ptr %6, align 4
  %8 = load i32, ptr %6, align 4
  switch i32 %8, label %12 [
    i32 0, label %9
    i32 1, label %10
    i32 2, label %11
  ]

9:                                                ; preds = %2
  store i32 0, ptr %7, align 4
  br label %13

10:                                               ; preds = %2
  store i32 1, ptr %7, align 4
  br label %13

11:                                               ; preds = %2
  store i32 2, ptr %7, align 4
  br label %13

12:                                               ; preds = %2
  store i32 3, ptr %7, align 4
  br label %13

13:                                               ; preds = %12, %11, %10, %9
  %14 = load i32, ptr %7, align 4
  ret i32 %14
}
```

The switch usage is `switch <INT-TYPE> <COMP-VALUE>, label <DEFAULT-BRANCH> [ <INT-TYPE> <COND-VALUE> , label <DESTINATION> ... ]`:
- Arguments:
    - 3 arguments: Integer comparison value, default branch, and array of pairs of comparison value constants and labels.
    - `<INT-TYPE>`: Integer data type.
    - `<COMP-VALUE>`: Value being compared.
    - `<DEFAULT-BRANCH>`: Default branch.
    - `<COND-VALUE>`: A case value. Must be a constant.
    - `<DESTINATION>`: The branch that control flows to if previous case value is matched.

Very little can be said about this, Once you know the usage, the above code is quite simple to understand.


### Ternary Operator:
Look at `ternaryOp.c`:
```ternaryOp.c
int main( int argc, char** argv ) {
    int cond;
    int result;

    result = cond ? 0 : 1;
    return 0;
}
```

The body of the `@main` in the gemerated IR, `ternaryOp.ll`:
```ternaryOp.c
define dso_local i32 @main(i32 noundef %0, ptr noundef %1) #0 {
  %3 = alloca i32, align 4
  %4 = alloca i32, align 4
  %5 = alloca ptr, align 8
  %6 = alloca i32, align 4
  %7 = alloca i32, align 4
  store i32 0, ptr %3, align 4
  store i32 %0, ptr %4, align 4
  store ptr %1, ptr %5, align 8
  %8 = load i32, ptr %6, align 4
  %9 = icmp ne i32 %8, 0
  %10 = zext i1 %9 to i64
  %11 = select i1 %9, i32 0, i32 1
  store i32 %11, ptr %7, align 4
  ret i32 0
}
```

Lets use the [documentation](https://llvm.org/docs/LangRef.html#label-type) to understand the two new functions (we are ignoring flags):
- `zext .. to`:
    - Usage: ` <RESULT> = zext <ORIG-INT-TYPE> <VALUE> to <DEST-INT-TYPE> `
    - Takes in a value and casts it to another integer datatype. Both the original and desired datatype must be integer data types.
    - Arguments:
        - `<ORIG-INT-TYPE>`: Original integer datatype of value.
        - `<VALUE>`: The value being cast.
        - `<DEST-INT-TYPE>`: The desired integer data type.
        - The bit size of `<VALUE>` must be smaller than the bit size of `<DEST-INT-TYPE>`.
    - Extends the number of bits used to represent the value by padding with zeros. 
- `select`:
    - Usage: ` <RESULT> = select i1 <COND>, <TYPE> <VALUE1>, <TYPE> <VALUE2> `
    - Takes in a boolean condition and two values of the same type.
    - Arguments are self explanatory, asks very similar to the ternary operator in C.
    - If the condition is `true`, the result is `<VALUE1>`, otherwise the result is `<VALUE2>`.

Even though we have understood the `zext .. to` instruction, its involvement in the codes function appears irrelevant. I removed it and ran the code and the output was identical, therefore when explaining the implemetation of a ternary operator I will be ignoring it.

The ternary operator starts off by getting the value of `cond` which is pointed to by register (line 17). The value is then compared under equality to 0 (line 18). The `select` instruction is then used under the value in register 9 (which is the result of the comparison), with `true` outputting 0, and `false` outputting 1 (line 20). Finally the result is stored in `result` which is pointed to by register 7.

It seems like the majority of things learned in this section is quite easy to learn. Apart from syntax, the architecture of IR seems simple and very logical. Good job.
