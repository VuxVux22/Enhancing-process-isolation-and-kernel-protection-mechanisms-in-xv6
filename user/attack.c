#include "kernel/types.h"
#include "user/user.h"

// Hàm thực hiện Test 1: Đọc bộ nhớ Kernel
void do_read_test(volatile unsigned long *addr) {
    printf("[TEST 1] Read kernel memory...\n");
    int pid = fork();
    
    if(pid < 0) {
        printf("Fork failed\n");
        exit(1);
    }
    
    if(pid == 0) {
        // Tiến trình con thực hiện hành vi tấn công đọc vùng nhớ kernel
        unsigned long val = *addr;
        
        // Sửa lỗi format bằng cách ép kiểu qua (void*) và dùng %p
        printf("[FAIL] Read succeeded: 0x%p ❌\n", (void*)val);
        exit(0);
    } else {
        // Tiến trình cha chờ xem con có bị sập do Page Fault không
        int status;
        wait(&status);
        printf("[OK] Read blocked (Process terminated by Kernel) ✅\n");
    }
}

// Hàm thực hiện Test 2: Ghi bộ nhớ Kernel
void do_write_test(volatile unsigned long *addr) {
    printf("\n[TEST 2] Write kernel memory...\n");
    int pid = fork();
    
    if(pid < 0) {
        printf("Fork failed\n");
        exit(1);
    }
    
    if(pid == 0) {
        // Tiến trình con thực hiện hành vi ghi đè
        *addr = 0xDEADBEEF;
        printf("[FAIL] Write succeeded ❌\n");
        exit(0);
    } else {
        // Tiến trình cha chờ xem con có bị sập không
        int status;
        wait(&status);
        printf("[OK] Write blocked (Process terminated by Kernel) ✅\n");
    }
}

int main() {
    printf("=== User Space Attack Simulation (Fork-based) ===\n");
    
    // Địa chỉ Kernel Base trong xv6 RISC-V
    volatile unsigned long *kernel_addr = (unsigned long *)0x80000000;

    do_read_test(kernel_addr);
    do_write_test(kernel_addr);

    exit(0);
}
