; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=slp-vectorizer -S -mtriple=x86_64-unknown-linux-gnu -mcpu=skylake-avx512 | FileCheck %s

define void @test() {
; CHECK-LABEL: @test(
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr inbounds i8, ptr undef, i64 4
; CHECK-NEXT:    [[TMP2:%.*]] = load i8, ptr [[TMP1]], align 1
; CHECK-NEXT:    [[TMP3:%.*]] = zext i8 [[TMP2]] to i32
; CHECK-NEXT:    [[TMP4:%.*]] = sub nsw i32 0, [[TMP3]]
; CHECK-NEXT:    [[TMP5:%.*]] = shl nsw i32 [[TMP4]], 0
; CHECK-NEXT:    [[TMP6:%.*]] = add nsw i32 [[TMP5]], 0
; CHECK-NEXT:    [[TMP7:%.*]] = getelementptr inbounds i8, ptr undef, i64 5
; CHECK-NEXT:    [[TMP8:%.*]] = load i8, ptr [[TMP7]], align 1
; CHECK-NEXT:    [[TMP9:%.*]] = zext i8 [[TMP8]] to i32
; CHECK-NEXT:    [[TMP10:%.*]] = sub nsw i32 0, [[TMP9]]
; CHECK-NEXT:    [[TMP11:%.*]] = shl nsw i32 [[TMP10]], 0
; CHECK-NEXT:    [[TMP12:%.*]] = add nsw i32 [[TMP11]], 0
; CHECK-NEXT:    [[TMP13:%.*]] = getelementptr inbounds i8, ptr undef, i64 6
; CHECK-NEXT:    [[TMP14:%.*]] = load i8, ptr [[TMP13]], align 1
; CHECK-NEXT:    [[TMP15:%.*]] = zext i8 [[TMP14]] to i32
; CHECK-NEXT:    [[TMP16:%.*]] = sub nsw i32 0, [[TMP15]]
; CHECK-NEXT:    [[TMP17:%.*]] = shl nsw i32 [[TMP16]], 0
; CHECK-NEXT:    [[TMP18:%.*]] = add nsw i32 [[TMP17]], 0
; CHECK-NEXT:    [[TMP19:%.*]] = getelementptr inbounds i8, ptr undef, i64 7
; CHECK-NEXT:    [[TMP20:%.*]] = load i8, ptr [[TMP19]], align 1
; CHECK-NEXT:    [[TMP21:%.*]] = zext i8 [[TMP20]] to i32
; CHECK-NEXT:    [[TMP22:%.*]] = sub nsw i32 0, [[TMP21]]
; CHECK-NEXT:    [[TMP23:%.*]] = shl nsw i32 [[TMP22]], 0
; CHECK-NEXT:    [[TMP24:%.*]] = add nsw i32 [[TMP23]], 0
; CHECK-NEXT:    [[TMP25:%.*]] = add nsw i32 [[TMP12]], [[TMP6]]
; CHECK-NEXT:    [[TMP26:%.*]] = sub nsw i32 [[TMP6]], [[TMP12]]
; CHECK-NEXT:    [[TMP27:%.*]] = add nsw i32 [[TMP24]], [[TMP18]]
; CHECK-NEXT:    [[TMP28:%.*]] = sub nsw i32 [[TMP18]], [[TMP24]]
; CHECK-NEXT:    [[TMP29:%.*]] = getelementptr inbounds [4 x [4 x i32]], ptr undef, i64 0, i64 1, i64 0
; CHECK-NEXT:    [[TMP30:%.*]] = insertelement <4 x i32> <i32 poison, i32 poison, i32 0, i32 0>, i32 [[TMP25]], i32 0
; CHECK-NEXT:    [[TMP31:%.*]] = insertelement <4 x i32> [[TMP30]], i32 [[TMP26]], i32 1
; CHECK-NEXT:    [[TMP32:%.*]] = insertelement <4 x i32> <i32 0, i32 0, i32 poison, i32 poison>, i32 [[TMP27]], i32 2
; CHECK-NEXT:    [[TMP33:%.*]] = insertelement <4 x i32> [[TMP32]], i32 [[TMP28]], i32 3
; CHECK-NEXT:    [[TMP34:%.*]] = sub nsw <4 x i32> [[TMP31]], [[TMP33]]
; CHECK-NEXT:    store <4 x i32> [[TMP34]], ptr [[TMP29]], align 16
; CHECK-NEXT:    ret void
;
  %1 = getelementptr inbounds i8, ptr undef, i64 4
  %2 = load i8, ptr %1, align 1
  %3 = zext i8 %2 to i32
  %4 = sub nsw i32 0, %3
  %5 = shl nsw i32 %4, 0
  %6 = add nsw i32 %5, 0
  %7 = getelementptr inbounds i8, ptr undef, i64 5
  %8 = load i8, ptr %7, align 1
  %9 = zext i8 %8 to i32
  %10 = sub nsw i32 0, %9
  %11 = shl nsw i32 %10, 0
  %12 = add nsw i32 %11, 0
  %13 = getelementptr inbounds i8, ptr undef, i64 6
  %14 = load i8, ptr %13, align 1
  %15 = zext i8 %14 to i32
  %16 = sub nsw i32 0, %15
  %17 = shl nsw i32 %16, 0
  %18 = add nsw i32 %17, 0
  %19 = getelementptr inbounds i8, ptr undef, i64 7
  %20 = load i8, ptr %19, align 1
  %21 = zext i8 %20 to i32
  %22 = sub nsw i32 0, %21
  %23 = shl nsw i32 %22, 0
  %24 = add nsw i32 %23, 0
  %25 = add nsw i32 %12, %6
  %26 = sub nsw i32 %6, %12
  %27 = add nsw i32 %24, %18
  %28 = sub nsw i32 %18, %24
  %29 = add nsw i32 0, %25
  %30 = getelementptr inbounds [4 x [4 x i32]], ptr undef, i64 0, i64 1, i64 0
  store i32 %29, ptr %30, align 16
  %31 = sub nsw i32 0, %27
  %32 = getelementptr inbounds [4 x [4 x i32]], ptr undef, i64 0, i64 1, i64 2
  store i32 %31, ptr %32, align 8
  %33 = add nsw i32 0, %26
  %34 = getelementptr inbounds [4 x [4 x i32]], ptr undef, i64 0, i64 1, i64 1
  store i32 %33, ptr %34, align 4
  %35 = sub nsw i32 0, %28
  %36 = getelementptr inbounds [4 x [4 x i32]], ptr undef, i64 0, i64 1, i64 3
  store i32 %35, ptr %36, align 4
  ret void
}
