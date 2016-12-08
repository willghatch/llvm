; RUN: opt -S -instcombine < %s | FileCheck %s

;; todo - How do I say it needs X analysis before running?  Or do I depend on the instcombine pass requiring analyses?

declare void @throwAnExceptionOrWhatever()

; Function Attrs: nounwind readnone
declare { i32, i1 } @llvm.sadd.with.overflow.i32(i32, i32) #1

; Function Attrs: noreturn nounwind
declare void @llvm.trap() #2

; CHECK-LABEL: @bar(
define i32 @bar(i32) local_unnamed_addr #0 {
  %2 = icmp slt i32 %0, 10
  br i1 %2, label %3, label %19

; <label>:3:                                      ; preds = %1
  br label %4

; <label>:4:                                      ; preds = %3, %14
  %5 = phi i32 [ %16, %14 ], [ %0, %3 ]
  %6 = icmp slt i32 %5, 1
  br i1 %6, label %7, label %11

; <label>:7:                                      ; preds = %4
; CHECK-NOT: llvm.sadd
  %8 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %5, i32 1)
  %9 = extractvalue { i32, i1 } %8, 1
  br i1 %9, label %10, label %14

; <label>:10:                                     ; preds = %7, %11
  tail call void @llvm.trap() #2
  unreachable

; <label>:11:                                     ; preds = %4
  %12 = tail call { i32, i1 } @llvm.sadd.with.overflow.i32(i32 %5, i32 %5)
  %13 = extractvalue { i32, i1 } %12, 1
  br i1 %13, label %10, label %14

; <label>:14:                                     ; preds = %7, %11
  %15 = phi { i32, i1 } [ %12, %11 ], [ %8, %7 ]
  %16 = extractvalue { i32, i1 } %15, 0
  %17 = icmp slt i32 %16, 10
  br i1 %17, label %4, label %18

; <label>:18:                                     ; preds = %14
  br label %19

; <label>:19:                                     ; preds = %18, %1
  %20 = phi i32 [ %0, %1 ], [ %16, %18 ]
  ret i32 %20
}

