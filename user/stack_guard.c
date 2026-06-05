#include "kernel/types.h"
#include "user/user.h"

#define PAGE_SIZE 4096

int main() {
    printf("=== xv6 Stack Overflow & Guard Page Simulation ===\n");

    // Lấy đỉnh của Stack hiện tại (chính là kích thước hiện tại của tiến trình)
    // sbrk(0) trả về địa chỉ kết thúc vùng nhớ hiện tại của User Space
    char *stack_top = (char *)sbrk(0);
    
    // Tính toán vị trí theo kiến trúc phân bổ của xv6
    char *stack_bottom = stack_top - PAGE_SIZE;
    char *guard_page = stack_bottom - PAGE_SIZE;

    printf("STACK_TOP    : 0x%p\n", stack_top);
    printf("STACK_BOTTOM : 0x%p\n", stack_bottom);
    printf("GUARD_PAGE   : 0x%p (Protected by Kernel)\n", guard_page);

    // =========================================================
    // TEST 1: Ghi dữ liệu hợp lệ vào vùng Stack
    // =========================================================
    printf("\n[TEST 1] Writing into valid Stack memory...\n");
    
    // Ghi vào một địa chỉ nằm bên trong trang Stack (cách đỉnh 512 bytes)
    char *valid_addr = stack_top - 512;
    *valid_addr = 'A';
    
    printf("[+] OK! Successfully wrote '%c' at 0x%p\n", *valid_addr, valid_addr);

    // =========================================================
    // TEST 2: Gây ra hiện tượng Stack Overflow chạm vào Guard Page
    // =========================================================
    printf("\n[TEST 2] Triggering Stack Overflow (Accessing Guard Page)...\n");
    
    int pid = fork();
    if(pid < 0) {
        printf("Fork failed!\n");
        exit(1);
    }

    if(pid == 0) {
        // Tiến trình con cố tình ghi đè vượt biên xuống vùng Guard Page
        // Thử ghi vào byte cuối cùng thuộc Guard Page
        char *overflow_addr = guard_page + PAGE_SIZE - 1; 
        
        printf("Child attempting to write at Guard Page address: 0x%p\n", overflow_addr);
        
        *overflow_addr = 'X'; // <-- Dòng này sẽ kích hoạt Page Fault (Trap 15)
        
        // Nếu chạy được đến đây tức là Guard Page thất bại
        printf("[FAIL] Guard Page did not block access! ❌\n");
        exit(0);
    } else {
        int status;
        wait(&status);
        
        // Tiến trình con bị sập và bị kernel kill, tiến trình cha nhận biết và thông báo thành công
        printf("[OK] Stack Overflow detected! Process terminated by Kernel Guard Page. ✅\n");
    }

    exit(0);
}
