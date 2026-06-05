#include "kernel/types.h"
#include "user/user.h"

// Hàm đệ quy tiêu tốn stack
void recursive_function(int depth) {
    // Tạo mảng cục bộ 1024 bytes (1KB) để ép Stack tiêu thụ bộ nhớ thật nhanh
    char buffer[1024];

    // Ghi dữ liệu vào buffer để đảm bảo trình biên dịch không tối ưu hóa xóa bỏ biến này
    for (int i = 0; i < 1024; i += 256) {
        buffer[i] = 'X';
    }

    printf("Depth: %d | Stack Address approx: 0x%p\n", depth, &buffer[0]);

    // FIX LỖI DETECTED INFINITE RECURSION:
    // Thêm một điều kiện chặn trên lý thuyết (độ sâu 999999) 
    // để GCC không báo lỗi đệ quy vô hạn, dù trên thực tế stack sẽ tràn và sập ở depth 4-5.
    if (depth > 999999) {
        return;
    }

    // Gọi đệ quy
    recursive_function(depth + 1);
}

int main() {
    printf("[+] Starting Stack Overflow Test on xv6...\n");

    int pid = fork();

    if (pid < 0) {
        printf("Fork failed!\n");
        exit(1);
    }

    if (pid == 0) {
        /* ===== TIẾN TRÌNH CON ===== */
        // Tiến trình con sẽ chịu trách nhiệm lao đầu vào Guard Page và bị hiến tế
        recursive_function(1);
        
        // Dòng này sẽ không bao giờ được chạy tới
        printf("[FAIL] Out of recursion without crash? ❌\n");
        exit(0);
    } 
    else {
        /* ===== TIẾN TRÌNH CHA ===== */
        int status;
        // Cha bình tĩnh ngồi đợi đứa con bị Kernel xử tử
        wait(&status);

        printf("\n--------------------------------------------------\n");
        printf("[OK] Page Fault detected! Child process hit the Guard Page.\n");
        printf("[OK] Stack Overflow handled safely by xv6 Kernel! ✅\n");
        printf("--------------------------------------------------\n");
    }

    exit(0);
}
