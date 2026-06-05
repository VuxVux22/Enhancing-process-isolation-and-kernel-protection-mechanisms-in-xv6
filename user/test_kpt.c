#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/memlayout.h"

void
test_read_kernel() {
    printf("1. Testing: Read from kernel memory (KERNBASE)...\n");
    char *kernel_addr = (char *)0x80000000; // Địa chỉ bắt đầu của nhân[cite: 2]
    
    int pid = fork();
    if(pid < 0) {
        printf("Fork failed\n");
        exit(1);
    }

    if(pid == 0) {
        // Cố gắng đọc dữ liệu từ vùng nhớ nhân
        char val = *kernel_addr;
        printf("Lỗi: Có thể đọc được bộ nhớ nhân! Giá trị: %x\n", val);
        exit(0);
    } else {
        int status;
        wait(&status);
        if(status != 0) {
            printf("Thành công: Tiến trình bị tiêu diệt khi cố truy cập nhân (Segmentation Fault).\n");
        }
    }
}

void
test_write_kernel_code() {
    printf("\n2. Testing: Write to kernel code (Read-only section)...\n");
    // Giả sử địa chỉ này thuộc vùng text của nhân đã được nạp qua kvminithart[cite: 2]
    uint64 *kernel_code = (uint64 *)0x80001000; 

    int pid = fork();
    if(pid == 0) {
        // Cố gắng ghi đè lên mã nguồn nhân
        *kernel_code = 0x12345678;
        printf("Lỗi: Có thể ghi đè lên mã nguồn nhân!\n");
        exit(0);
    } else {
        int status;
        wait(&status);
        if(status != 0) {
            printf("Thành công: Hệ thống đã chặn hành vi ghi đè mã nguồn nhân.\n");
        }
    }
}

int
main(int argc, char *argv[]) {
    printf("--- BẮT ĐẦU KIỂM TRA QUYỀN TRUY CẬP NGHIÊM NGẶT  ---\n");
    
    test_read_kernel();
    test_write_kernel_code();

    printf("\n--- KIỂM TRA HOÀN TẤT ---\n");
    exit(0);
}
