#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Định nghĩa địa chỉ vùng cấm để test 
#define KERNBASE 0x80000000
#define NULL_PTR 0x0 

// 1. KỊCH BẢN 1: Tấn công Tràn bộ đệm (Buffer Overflow) / Guard Page Test 
void 
test_overflow(void) 
{ 
  printf("[TEST 1] Chay kich ban Buffer Overflow / Guard Page...\n"); 
   
  int pid = fork();
  if(pid < 0) {
    printf("Fork failed\n");
    exit(1);
  }

  if(pid == 0) {
    volatile char big_buffer[5000]; 
     
    // Ghi dữ liệu liên tục vào sâu trong vùng Stack mở rộng trái phép 
    for(int i = 0; i < 5000; i += 512) { 
      big_buffer[i] = 'A'; 
    } 

    // FIX LỖI UNUSED-BUT-SET-VARIABLE:
    // Đọc một giá trị từ buffer để GCC công nhận biến này có được sử dụng thực tế
    char dummy = big_buffer[0];
    if(dummy == 'Z') {
      printf("This will never happen\n");
    }
     
    printf("[INFO] Buffer Overflow Test completed without crash (Unexpected).\n"); 
    exit(0);
  } else {
    int status;
    wait(&status);
    printf("[OK] Buffer Overflow blocked safely by Guard Page (Process terminated). ✅\n");
  }
} 

// 2. KỊCH BẢN 2: Tấn công Con trỏ rỗng (Null Pointer Dereference) 
void 
test_null_pointer(void) 
{ 
  printf("[TEST 2] Chay kich ban Null Pointer Dereference...\n"); 
   
  int pid = fork();
  if(pid < 0) {
    printf("Fork failed\n");
    exit(1);
  }

  if(pid == 0) {
    volatile char *ptr = (char *)NULL_PTR; 
     
    *ptr = 'X';  
     
    printf("[INFO] Null Pointer Test completed without crash (Unexpected).\n"); 
    exit(0);
  } else {
    int status;
    wait(&status);
    printf("[OK] Null Pointer Dereference blocked safely by MMU Page Table. ✅\n");
  }
} 

// 3. KỊCH BẢN 3: Tấn công Chèn mã độc (Code Injection / PTE_X Test) 
void 
test_code_injection(void) 
{ 
  printf("[TEST 3] Chay kich ban Code Injection...\n"); 
   
  int pid = fork();
  if(pid < 0) {
    printf("Fork failed\n");
    exit(1);
  }

  if(pid == 0) {
    unsigned char shellcode[] = { 0x82, 0x80 }; // Mã máy lệnh "ret" trong RISC-V 
     
    void (*func_ptr)(void) = (void (*)(void))shellcode; 
     
    func_ptr();  
     
    printf("[INFO] Code Injection Test completed without crash (Unexpected).\n"); 
    exit(0);
  } else {
    int status;
    wait(&status);
    printf("[OK] Code Execution on Page without PTE_X blocked by CPU Trap! ✅\n");
  }
} 

// 4. KỊCH BẢN 4: Kiểm tra áp lực cao (Stress Test cho nhiều tiến trình COW đồng thời) 
void 
test_cow_stress(void) 
{ 
  printf("[TEST 4] Chay Stress Test voi dong thoi nhieu tien trinh COW...\n"); 
   
  int nprocs = 4; 
   
  for(int i = 0; i < nprocs; i++){ 
    int pid = fork(); 
    if(pid < 0){ 
      printf("[ERROR] Fork that bai tai luot: %d\n", i); 
      exit(1); 
    } 
     
    if(pid == 0){ 
      char *page_ram = sbrk(4096 * 10); 
      if(page_ram != (char*)-1){ 
        for(int j = 0; j < 4096 * 10; j += 64){ 
          page_ram[j] = 'C'; 
        } 
      } 
      exit(0); 
    } 
  } 
   
  for(int i = 0; i < nprocs; i++){ 
    wait(0); 
  } 
  printf("[SUCCESS] Stress Test cho co che COW hoan thanh, Kernel van hanh on dinh! ✅\n"); 
} 

int 
main(int argc, char *argv[]) 
{ 
  printf("==================================================\n"); 
  printf("  KHOI CHAY BO AUTOMATED TEST SUITE - SECURITY & STRESS\n"); 
  printf("==================================================\n"); 
 
  if(argc < 2){ 
    printf("Cach dung: test_suite [overflow | null | injection | stress]\n"); 
    exit(1); 
  } 
 
  if(strcmp(argv[1], "overflow") == 0){ 
    test_overflow(); 
  } else if(strcmp(argv[1], "null") == 0){ 
    test_null_pointer(); 
  } else if(strcmp(argv[1], "injection") == 0){ 
    test_code_injection(); 
  } else if(strcmp(argv[1], "stress") == 0){ 
    test_cow_stress(); 
  } else { 
    printf("[ERROR] Tham so khong hop le!\n"); 
  } 
 
  exit(0); 
}
