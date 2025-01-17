# Break, Continue, and Return
We saw in the previous section, [Loops](../3.%20Loops/loops.md#while-loops), we were introduced to the `break` statement and its implementations. Here we will look at it again as well as the `continue` and `return` keywords.

### Break:
The function of a `break` is to exit the most recent loop. Look at [break.c](./break.c). Here we have two uses of a `break`, the first is in the scope of the loop, the other is in a conditional child scope of the loop.

Lookin at [break.ll](./break.ll) we have the following branch structure:
- branch `3`: Contains condition logic for the first loop.
- branch `6`: Contains the logic inside the first loop scope.
- branch `7`: Contains logic for iterator incrementing logic.
- branch `10`: Contains the logic after the first loop.
- branch `11`: Contains condition logic for the second loop.
- branch `14`: Contains logic inside second loop scope.
- branch `17`: Contains logic inside second loops condition scope.
- branch `18`: Contains logic after the condition scope in second loop.
- branch `19`: Contains logic for iterator incrementing lgiv.
- branch `22`: Contains logic after the second loop.

By this point recognising this structure and the function of each branch is pretty easy. But we should note that the `break` statements are in branches `6` and `17`.

```ll
6:                                                ; preds = %3
  br label %10
```
and:
```ll
17:                                               ; preds = %14
  br label %22
```

As we have said in the above branch structure, branches `10` and `22` contains the logic after the first loop and after the second loop respetively. This shws the implementation of the `break` statement is simply a jump to the branch containing the logic after the loop. Pretty simple.


### Continue:
The function of the `continue` statement is to skip straight to the next iteration of the loop. Look at [continue.c](./continue.c). In this code we have all the loop structures outputting every number but the number 3.

I am not going to outline the entire branch structure. Look at it yourself, and notice the `continue` statement implementations in the following branches:
- branch `9` for the `for` loop.
- branch `24` for the `while` loop.
- branch `35` for the `do-while` loop.

This is also implemented as a branch command. And as you probably already expected, the command branches to the block that contains the...
- `for` loops: iterator incrementing logic.
- `while` loops: loop condition logic.
- `do-while` loops: loop condition logic.

You can see that the `continue` statement jumps to the same block that is jumped to after the loop body logic is completed.

Simple ay?

### Return:
`return` statements are implemented through the `ret` command. `ret` commands are used to return control flow back to the parent process. In the documentations it says:

    "The ‘ret’ instruction is used to return control flow (and optionally a value) from a function back to the caller."

The ret instruction in LLVM IR returns control flow (and optionally a value) from a function back to the caller. When a function is called, control flow shifts to the called function, pausing the current process. Once the function completes, control returns to the original process.

If the `ret` returns a value then the `call` function is assigned to a register, otherwise there is no assignment. Notice the difference between the two calls here:
```ll
%5 = call i32 @intFunc()
...
call void @voidFunc()
```

The `ret` works very similarly to `return` in C. I have either gone to insufficient depth in this keyword or there is very little to talk about.
