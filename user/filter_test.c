#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/syscall.h" // Nạp các định nghĩa mã số SYS_fork, SYS_write...

int
main(void)
{
  printf("--- KHOI CHAY TIEN TRINH THU NGHIEM BO LOC ---\n");

  // Thiết lập bitmask: Chỉ cho phép gọi lệnh SYS_exit (2), SYS_write (16) và SYS_set_filter (23)
  // Tất cả các lệnh hệ thống khác bao gồm lệnh nhân bản tiến trình SYS_fork (mã 1) sẽ bị khóa vĩnh viễn!
  uint64 safe_mask = (1L << SYS_exit) | (1L << SYS_write) | (1L << SYS_set_filter);
  
  printf("[INFO] Dang kich hoat mang loc an ninh, khoa toan bo he thong...\n");
  set_filter(safe_mask);

  printf("[INFO] Thu nghiem goi lenh hop phap (Ghi chuoi ra man hinh)... OK!\n");

  printf("[ATTACK] Co tinh goi lenh cam (SYS_fork) de kiem tra bo loc...\n");
  fork(); // Lệnh fork() có mã số là 1. Bit số 1 trong safe_mask bằng 0 -> Sẽ bị trạm gác tóm gọn!

  // Dòng chữ này sẽ không bao giờ được in ra vì tiến trình đã bị nhân xử tử hình
  printf("[WARNING] THAT BAI: Bo loc he thong da bi qua mat!\n");
  exit(0);
}
