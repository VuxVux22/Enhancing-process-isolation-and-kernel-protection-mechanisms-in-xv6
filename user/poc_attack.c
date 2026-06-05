#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  // Trong RISC-V Xv6, địa chỉ Kernel thường bắt đầu từ vùng cao.
  // Ví dụ: 0x80000000 là nơi chứa code của Kernel.
  uint64 kernel_addr = 0x80000000; 

  // Thêm (void *) trước kernel_addr
printf("PoC: Dang co gang truy cap vao vung nho Kernel tai: %p...\n", (void *)kernel_addr);

  // Coi địa chỉ đó là một con trỏ kiểu char và thử đọc giá trị tại đó
  char *p = (char *)kernel_addr;
  char value = *p; 

  // Nếu dòng này được in ra, nghia la he thong da bi "hack" thanh cong (rat kho xay ra)
  printf("PoC: Doc duoc gia tri: %x (Neu thay dong nay, Kernel dang bi ho!)\n", value);

  exit(0);
}
