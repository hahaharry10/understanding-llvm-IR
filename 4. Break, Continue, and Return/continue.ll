; ModuleID = 'continue.c'
source_filename = "continue.c"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

@stdout = external global ptr, align 8
@.str = private unnamed_addr constant [4 x i8] c"%i\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  store i32 0, ptr %2, align 4
  br label %3

3:                                                ; preds = %14, %0
  %4 = load i32, ptr %2, align 4
  %5 = icmp slt i32 %4, 10
  br i1 %5, label %6, label %17

6:                                                ; preds = %3
  %7 = load i32, ptr %2, align 4
  %8 = icmp eq i32 %7, 3
  br i1 %8, label %9, label %10

9:                                                ; preds = %6
  br label %14

10:                                               ; preds = %6
  %11 = load ptr, ptr @stdout, align 8
  %12 = load i32, ptr %2, align 4
  %13 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %11, ptr noundef @.str, i32 noundef %12)
  br label %14

14:                                               ; preds = %10, %9
  %15 = load i32, ptr %2, align 4
  %16 = add nsw i32 %15, 1
  store i32 %16, ptr %2, align 4
  br label %3

17:                                               ; preds = %3
  store i32 0, ptr %2, align 4
  br label %18

18:                                               ; preds = %25, %24, %17
  %19 = load i32, ptr %2, align 4
  %20 = icmp slt i32 %19, 10
  br i1 %20, label %21, label %31

21:                                               ; preds = %18
  %22 = load i32, ptr %2, align 4
  %23 = icmp eq i32 %22, 3
  br i1 %23, label %24, label %25

24:                                               ; preds = %21
  br label %18

25:                                               ; preds = %21
  %26 = load ptr, ptr @stdout, align 8
  %27 = load i32, ptr %2, align 4
  %28 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %26, ptr noundef @.str, i32 noundef %27)
  %29 = load i32, ptr %2, align 4
  %30 = add nsw i32 %29, 1
  store i32 %30, ptr %2, align 4
  br label %18

31:                                               ; preds = %18
  store i32 0, ptr %2, align 4
  br label %32

32:                                               ; preds = %42, %31
  %33 = load i32, ptr %2, align 4
  %34 = icmp eq i32 %33, 3
  br i1 %34, label %35, label %36

35:                                               ; preds = %32
  br label %42

36:                                               ; preds = %32
  %37 = load ptr, ptr @stdout, align 8
  %38 = load i32, ptr %2, align 4
  %39 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %37, ptr noundef @.str, i32 noundef %38)
  %40 = load i32, ptr %2, align 4
  %41 = add nsw i32 %40, 1
  store i32 %41, ptr %2, align 4
  br label %42

42:                                               ; preds = %36, %35
  %43 = load i32, ptr %2, align 4
  %44 = icmp slt i32 %43, 10
  br i1 %44, label %32, label %45

45:                                               ; preds = %42
  ret i32 0
}

declare i32 @fprintf(ptr noundef, ptr noundef, ...) #1

attributes #0 = { noinline nounwind optnone uwtable "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }
attributes #1 = { "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+outline-atomics,+v8a,-fmv" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 1}
!5 = !{!"Debian clang version 16.0.6 (27+b1)"}
