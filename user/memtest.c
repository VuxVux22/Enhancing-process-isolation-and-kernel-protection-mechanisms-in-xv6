#include "kernel/types.h"
#include "user/user.h"

int main() {
  printf("User: Dang yeu cau kernel cap phat bo nho...\n");
  if(memtest() == 0){
    printf("User: Syscall memtest thanh cong!\n");
  } else {
    printf("User: Syscall memtest gap loi.\n");
  }
  exit(0);
}
