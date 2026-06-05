#include "kernel/types.h"
#include "user/user.h"

// Thêm tham số hoặc điều kiện để đánh lừa trình biên dịch
void 
overflow(int n) {
    char buffer[512]; 
    buffer[0] = (char)n;
    
    if(n % 10 == 0) {
        printf("Stack depth: %d\n", n);
    }
    
    // Thêm một điều kiện không bao giờ xảy ra nhưng trình biên dịch không biết
    if(n > 0) {
        overflow(n + 1);
    }
    
    // Ngăn chặn việc tối ưu hóa (unused result)
    if(buffer[0] == 0) return;
}

int main(int argc, char *argv[]) {
    printf("--- BAT DAU TEST TRAN STACK  ---\n");
    overflow(1);
    exit(0);
}
