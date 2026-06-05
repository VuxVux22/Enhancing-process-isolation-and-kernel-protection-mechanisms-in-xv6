#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
  ps(); // Gọi syscall ps mà bạn đã định nghĩa trong kernel
  exit(0);
}
