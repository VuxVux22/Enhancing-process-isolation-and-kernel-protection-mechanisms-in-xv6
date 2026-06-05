#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
  const int ITER = 5000;
  uint64 start, end;
  uint64 total = 0;

  printf("=== Starting System Call Latency Measurement (%d iterations) ===\n", ITER);

  start = getcycles(); // Mốc thời gian bắt đầu toàn cục
  
  for(int i = 0; i < ITER; i++) {
    nullcall(); // Thực hiện liên tục để đo áp lực chuyển đổi ngữ cảnh
    nullcall();
    nullcall();
    nullcall();
  }
  
  end = getcycles(); // Mốc thời gian kết thúc

  if(end >= start) {
    total = end - start;
  }

  // Hiển thị kết quả tính toán độ trễ theo đơn vị Ticks hệ thống
  printf("Total elapsed time for test: %ld clock ticks\n", total);
  printf("Average overhead per call sequence: %ld ticks/thousand-calls\n", (total * 1000) / ITER);

  exit(0);
}
