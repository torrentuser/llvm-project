; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S -passes=jump-threading < %s | FileCheck %s



define void @f() {
; CHECK-LABEL: define void @f() {
; CHECK-NEXT:  [[ENTRY:.*:]]
; CHECK-NEXT:    br label %[[LOR_RHS:.*]]
; CHECK:       [[LOR_RHS]]:
; CHECK-NEXT:    br label %[[LOR_RHS]]
;
entry:
  br label %for.cond1

if.end16:
  %phi1 = phi i32 [ undef, %for.cond1 ]
  %g.3 = phi i32 [ %g.1, %for.cond1 ]
  %sext = shl i32 %g.3, 16
  %conv20 = ashr exact i32 %sext, 16
  %tobool21 = icmp eq i32 %phi1, 0
  br i1 %tobool21, label %lor.rhs, label %for.cond1

for.cond1:
  %g.1 = phi i32 [ 0, %entry ], [ 0, %lor.rhs ], [ %g.3, %if.end16 ]
  br i1 undef, label %lor.rhs, label %if.end16

lor.rhs:
  br label %for.cond1
}
