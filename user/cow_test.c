#include "kernel/types.h"
#include "user/user.h"

#define PAGE_SIZE 4096

// Tạo một vùng đệm tĩnh lớn hơn 1 trang để kiểm tra CoW
char global_buf[PAGE_SIZE * 2];

int main() {
    printf("=== xv6 Copy-on-Write (CoW) Verification ===\n");

    // Khởi tạo dữ liệu ban đầu cho vùng nhớ (Tương đương FIX #4)
    global_buf[0] = 'A';
    global_buf[PAGE_SIZE] = 'B';

    printf("[Parent] PID: %d\n", getpid());
    printf("[Parent] Buffer Address: 0x%p\n", global_buf);
    printf("[Parent] Page 0 init: '%c' | Page 1 init: '%c'\n", global_buf[0], global_buf[PAGE_SIZE]);
    printf("[Parent] Forking now... (Kernel will map page tables as Read-only)\n\n");

    int pid = fork();

    if (pid < 0) {
        printf("Fork failed\n");
        exit(1);
    } 
    else if (pid == 0) {
        /* ===== TIÊN TRÌNH CON (CHILD) ===== */
        printf("[Child]  PID: %d\n", getpid());
        printf("[Child]  Buffer Address: 0x%p (Virtual address matches Parent)\n", global_buf);
        
        // Đọc dữ liệu: Vẫn đang dùng chung trang vật lý với cha
        printf("[Child]  Read Page 0 (Shared Physical Page): '%c'\n", global_buf[0]);

        printf("[Child]  Writing to Page 0... (This triggers Kernel Page Fault -> CoW Allocation)\n");
        /* * Hành vi ghi này kích hoạt Store Page Fault (Trap 15) trong xv6.
         * Kernel sẽ âm thầm cấp phát 1 trang vật lý mới, sao chép nội dung 'A' sang,
         * đổi quyền thành Read/Write, rồi mới cho phép ghi chữ 'Z' vào.
         */
        global_buf[0] = 'Z'; 

        printf("[Child]  Page 0 after write: '%c' (Child's private copy)\n", global_buf[0]);
        printf("[Child]  Page 1 (Still shared/unmodified): '%c'\n\n", global_buf[PAGE_SIZE]);
        
        exit(0);
    } 
    else {
        /* ===== TIÊN TRÌNH CHA (PARENT) ===== */
        // Chờ tiến trình con kết thúc hoàn toàn
        int status;
        wait(&status);

        printf("[Parent] Child process finished.\n");
        // Kiểm tra xem dữ liệu của cha có bị ảnh hưởng bởi hành vi ghi của con không
        printf("[Parent] Page 0 after fork: '%c' (Should remain 'A' - isolated by CoW)\n", global_buf[0]);
        printf("[Parent] Page 1: '%c'\n", global_buf[PAGE_SIZE]);
    }

    exit(0);
}
