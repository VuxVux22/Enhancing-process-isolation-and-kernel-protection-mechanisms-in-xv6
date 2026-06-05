#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void
test_read_badptr()
{
  printf("1. Testing read() with bad pointer...\n");
  
  // Một địa chỉ rất cao, không được ánh xạ cho User
  char *bad_buf = (char *)0x9000000000000000L; 
  int fd = open("README", 0);
  
  if(fd < 0){
    printf("Test failed: Could not open README\n");
    return;
  }

  int n = read(fd, bad_buf, 10);
  
  if(n == -1){
    printf("Result: SUCCESS (Kernel safely returned -1)\n");
  } else {
    printf("Result: FAILED (Kernel returned %d instead of -1)\n", n);
  }
  close(fd);
}

void
test_write_badptr()
{
  printf("\n2. Testing write() with kernel pointer...\n");
  
  // Địa chỉ vùng nhớ Kernel
  char *kernel_buf = (char *)0x80000000; 
  int fd = open("test_out", 0x200 | 0x002); // O_CREATE | O_RDWR
  
  if(fd < 0){
    printf("Test failed: Could not create file\n");
    return;
  }

  int n = write(fd, kernel_buf, 10);
  
  if(n == -1){
    printf("Result: SUCCESS (Kernel safely returned -1)\n");
  } else {
    printf("Result: FAILED (Kernel allowed writing from kernel memory!)\n");
  }
  close(fd);
}

int
main(void)
{
  printf("--- STARTING UNIT TEST: MEMORY PROTECTION ---\n");
  test_read_badptr();
  test_write_badptr();
  printf("--- UNIT TEST FINISHED ---\n");
  exit(0);
}
