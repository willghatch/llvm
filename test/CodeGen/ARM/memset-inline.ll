; RUN: llc < %s -mtriple=thumbv7-apple-ios -mcpu=cortex-a8 -pre-RA-sched=source -disable-post-ra | FileCheck %s

define void @t1(i8* nocapture %c) nounwind optsize {
entry:
; CHECK-LABEL: t1:

;; FIXME: like with arm64-memset-inline.ll, learning how to merge
;; stores made this code worse, since it now uses a vector move,
;; instead of just using an strd instruction taking two registers.

; CHECK: vmov.i32 d16, #0x0
; CHECK: vst1.32 {d16}, [r0:64]!
; CHECK: movs r1, #0
; CHECK: str r1, [r0]
  call void @llvm.memset.p0i8.i64(i8* %c, i8 0, i64 12, i32 8, i1 false)
  ret void
}

define void @t2() nounwind ssp {
entry:
; CHECK-LABEL: t2:
; CHECK: add.w r1, r0, #10
; CHECK: vmov.i32 {{q[0-9]+}}, #0x0
; CHECK: vst1.16 {d{{[0-9]+}}, d{{[0-9]+}}}, [r1]
; CHECK: vst1.64 {d{{[0-9]+}}, d{{[0-9]+}}}, [r0]
  %buf = alloca [26 x i8], align 1
  %0 = getelementptr inbounds [26 x i8], [26 x i8]* %buf, i32 0, i32 0
  call void @llvm.memset.p0i8.i32(i8* %0, i8 0, i32 26, i32 1, i1 false)
  call void @something(i8* %0) nounwind
  ret void
}

declare void @something(i8*) nounwind
declare void @llvm.memset.p0i8.i32(i8* nocapture, i8, i32, i32, i1) nounwind
declare void @llvm.memset.p0i8.i64(i8* nocapture, i8, i64, i32, i1) nounwind
