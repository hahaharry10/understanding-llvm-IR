; ModuleID = 'return.c'
source_filename = "return.c"
target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"
target triple = "aarch64-unknown-linux-gnu"

@stdout = external global ptr, align 8
@.str = private unnamed_addr constant [18 x i8] c"intFunc started.\0A\00", align 1
@.str.1 = private unnamed_addr constant [19 x i8] c"voidFunc started.\0A\00", align 1
@.str.2 = private unnamed_addr constant [14 x i8] c"Some code...\0A\00", align 1
@.str.3 = private unnamed_addr constant [14 x i8] c"More code...\0A\00", align 1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @intFunc() #0 {
  %1 = load ptr, ptr @stdout, align 8
  %2 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %1, ptr noundef @.str)
  ret i32 0
}

declare i32 @fprintf(ptr noundef, ptr noundef, ...) #1

; Function Attrs: noinline nounwind optnone uwtable
define dso_local void @voidFunc() #0 {
  %1 = load ptr, ptr @stdout, align 8
  %2 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %1, ptr noundef @.str.1)
  ret void
}

; Function Attrs: noinline nounwind optnone uwtable
define dso_local i32 @main() #0 {
  %1 = alloca i32, align 4
  %2 = alloca i32, align 4
  store i32 0, ptr %1, align 4
  %3 = load ptr, ptr @stdout, align 8
  %4 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %3, ptr noundef @.str.2)
  %5 = call i32 @intFunc()
  store i32 %5, ptr %2, align 4
  call void @voidFunc()
  %6 = load ptr, ptr @stdout, align 8
  %7 = call i32 (ptr, ptr, ...) @fprintf(ptr noundef %6, ptr noundef @.str.3)
  ret i32 0
}

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
