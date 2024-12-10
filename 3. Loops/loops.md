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
Look at [for.c](./for.c) and look at the corresponding IR in [for.ll](./for.ll). Ignoring the preface of calling the initial variables we see that there is a jump straight to branch `%3` on line 15.

Branch `%3` is as follows:
```
3:                                                ; preds = %10, %0
  %4 = load i32, ptr %2, align 4
  %5 = icmp slt i32 %4, 10
  br i1 %5, label %6, label %13
```

This loads the value of `%2` (variable `i`) into register `%4`. Compares the value in register `%4` to the value 10 under the signed less than condition, storing the value in register `%5`. If the condition holds, jump to branch `%6`, if the condition is broken, jump to branch `%13`.

Conclusions made from understanding this branch:
- Branch `%3` holds the logic for the comparison.
- Branch `%6` holds the logic inside the for loop.
- Branch `%13` holds the logic after the for loop.

Branch `%6` is quite similar to what we have already seen - a standard function call, but there the jump to branch `%10` is new...

Branch `%10` is as follows:
```
10:                                               ; preds = %6
  %11 = load i32, ptr %2, align 4
  %12 = add nsw i32 %11, 1
  store i32 %12, ptr %2, align 4
  br label %3
```

This loads the value of register `%2` (variable `i`) into register `%11`, increments that value, stores the result into register `%12` to then store it back into the memory of register `%2`. So in a long winded static single-assignment machine way, this branch just increments the value of `i` by one, and jumps back to branch `%3`.

Branch `%13` is where the logic continues after the loop but in this example just contains a return statement.


Concluding `for` loop section:
- The condition variable is assigned before the loop is branched to.
- A individual branch is designated for the condition variable to be tested under the condition, and to update the variable.
- The logic within the `for` loop is placed inside a branch.
- The logic after the loop is in a separate branch and is called in the condition branch and is called when the condition is broken.
