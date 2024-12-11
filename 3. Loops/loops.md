# Loops:
This section discovers how loops are implemented in IR.

So my initial guess this section should be fairly familiar and similar to conditions and would follow a similar flow to the following....
1. Steps before the loop.
2. Statement testing condition.
3. Jump to branch that contains the logic within the loops scope.
4. Execute logic.
5. Test condition again and if condition is true jump to the start of the branch again, if condition breaks jump to branch containing teh rest of the code.

Let's see how wrong I am...

### For Loops:
Look at [for.c](./for.c) and look at the corresponding IR in [for.ll](./for.ll). Ignoring the preamble of calling the initial variables we see that there is a jump straight to block `%3` on line 15.

Block `%3` is as follows:
```ll
3:                                                ; preds = %10, %0
  %4 = load i32, ptr %2, align 4
  %5 = icmp slt i32 %4, 10
  br i1 %5, label %6, label %13
```

This loads the value of `%2` (variable `i`) into register `%4`. Compares the value in register `%4` to the value 10 under the signed less than condition, storing the value in register `%5`. If the condition holds, branch to block `%6`, if the condition is broken, branch to block `%13`.

Conclusions made from understanding this block:
- Block `%3` holds the logic for the comparison.
- Block `%6` holds the logic inside the for loop.
- Block `%13` holds the logic after the for loop.

Block `%6` is quite similar to what we have already seen - a standard function call, but the branch to block `%10` is worth noting...

Block `%10` is as follows:
```ll
10:                                               ; preds = %6
  %11 = load i32, ptr %2, align 4
  %12 = add nsw i32 %11, 1
  store i32 %12, ptr %2, align 4
  br label %3
```

This loads the value of register `%2` (variable `i`) into register `%11`, increments that value, stores the result into register `%12` to then store it back into the memory of register `%2`. So in a long winded static single-assignment machine way, this branch just increments the value of `i` by one, and branches back to block `%3`.

Block `%13` is where the logic continues after the loop but in this example just contains a return statement.


Concluding `for` loop section:
- The condition variable is assigned before the loop is branched to.
- A individual block is designated for the condition variable to be tested under the condition, and to update the variable.
- The logic within the `for` loop is placed inside a branch.
- The logic after the loop is in a separate block and is branched to in the condition branch when the condition is broken.

### While Loops:
Look at [while.c](./while.c) adn look at the corresponding IR in [while.ll](./while.ll).

`main` block:
Standard stuff. Initialise variables `i` and `j` in registers `%2` and `%3` respectively, and assign them values 1 and 0 respectively. Branch to block `%4`.

Block `%4` is the condition block, and loads the variable `i` and branches to block `%7` if the condition holds, and branches to block `%17` otherwise. The only thing of note here is that in conditions where the comparison operator is specified the comparison is an inequality comparison to 0. I know this is fairly intuitive but its cool to finally see it explicitely written.

Block `%7` is what we are interested in and is as follows:
```ll
7:                                                ; preds = %4
  %8 = load ptr, ptr @stdout, align 8
  %9 = load i32, ptr %3, align 4
  %10 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %8, ptr noundef @.str, i32 noundef %9)
  %11 = load i32, ptr %3, align 4
  %12 = icmp sgt i32 %11, 10
  br i1 %12, label %13, label %14
```

This block starts off (first 3 lines) with a function call to `fprintf` (nothing new). Then the value of j is loaded and compared to the value of 10 using the greater than comparator. If the condition is true, the program branches to block `%13`, otherwise flow is branched to block `%14`.

Block `%13` is as follows:
```ll
13:                                               ; preds = %7
  br label %17
```

Block `%13` is where the logic of the `break` keyword is used, and in IR the break keyword just branches to the block continuing the logic after the loop.

Block `%14` is simple as this block just comtains the logic of the loop after the `if` statement, which in this case just contains the incrementing of `j`. Once the logic is completed, the program branches to the block `%4`; The condition block.

And of course the last block (block `%17`) contains the logic after the loop, which is the return statement.

After understanding the structure of the [for loop](#for-loops), the while loop is pretty easy to understand. The only thing learned (that isn't even related to the while loop) is the implementation of the `break` keyword.
