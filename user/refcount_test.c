#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

// Cấu trúc dữ liệu mô phỏng một trang nhớ vật lý
typedef struct Page {
    int ref_count;
    int page_id;
} Page;

// Tăng reference count khi có tiến trình tham chiếu tới
void get_page(Page *p) {
    p->ref_count++;
    printf("Process uses Page %d -> ref_count = %d\n", p->page_id, p->ref_count);
}

// Giảm reference count khi tiến trình giải phóng tham chiếu
void put_page(Page *p) {
    p->ref_count--;
    printf("Process releases Page %d -> ref_count = %d\n", p->page_id, p->ref_count);

    // Chỉ khi không còn ai sử dụng (ref_count == 0), Kernel mới giải phóng thực tế
    if (p->ref_count == 0) {
        printf("[KERNEL] ref_count = 0 -> Freeing Page %d memory physically!\n", p->page_id);
        free(p);
    }
}

int main() {
    printf("=== xv6 Reference Counting Simulation ===\n");

    // Giả lập Kernel cấp phát một vùng nhớ Shared Page thông qua heap (sbrk/malloc)
    Page *shared_page = (Page*) malloc(sizeof(Page));
    if (shared_page == 0) {
        printf("Memory allocation failed\n");
        exit(1);
    }

    shared_page->page_id = 101;
    shared_page->ref_count = 0;

    printf("[INITIAL] Shared Page created at address: 0x%p\n\n", shared_page);

    // Giả lập tình huống: Các tiến trình lần lượt ánh xạ (map) vào trang này
    printf("--- Processes Attaching ---\n");
    printf("[Process A] "); get_page(shared_page);
    printf("[Process B] "); get_page(shared_page);
    printf("[Process C] "); get_page(shared_page);

    // Giả lập tình huống: Các tiến trình lần lượt thoát hoặc hủy ánh xạ (unmap)
    printf("\n--- Processes Exiting ---\n");
    printf("[Process A] "); put_page(shared_page);
    printf("[Process B] "); put_page(shared_page);
    
    // Tại điểm này ref_count = 1, vùng nhớ vẫn phải được giữ nguyên vẹn
    printf("[STATUS] Page %d is still alive in Kernel because ref_count > 0\n", shared_page->page_id);
    
    printf("[Process C] "); put_page(shared_page);

    exit(0);
}
