#include "kernel/types.h"
#include "user/user.h"

#define MULTI_PAGES 4096 * 5 // Tạo một mảng dữ liệu chiếm 5 trang RAM (20KB)
char global_buffer[MULTI_PAGES];

int main(int argc, char *argv[]) {
  printf("--- BAT DAU KIEM THU HIEU QUA BO NHO COW ---\n");

  // Khởi tạo dữ liệu ban đầu cho mảng
  for(int i = 0; i < MULTI_PAGES; i++) {
    global_buffer[i] = 'A';
  }

  printf("[1] Truoc khi fork: Buffer da duoc nap du lieu.\n");

  int pid = fork();
  if(pid < 0) {
    printf("Fork that bai!\n");
    exit(1);
  }

  if(pid == 0) {
    // --- TIẾN TRÌNH CON ---
    printf("[2] Tien trinh CON: Vua duoc tao (Chua ghi du lieu, dang dung chung RAM voi CHA).\n");
    
    // Đọc thử (Read) -> Không được sinh ra Page Fault, vẫn dùng chung RAM
    char check = global_buffer[0];
    if(check == 'A') {
      printf("[3] Tien trinh CON: Doc thu hop le, van chua ton them RAM vat ly.\n");
    }

    // Ghi thử (Write) -> MMU se kich hoat Page Fault, goi cow_handler cap RAM moi on-demand
    printf("[4] Tien trinh CON: Bat dau GHI du lieu de ep xuyen thung co che COW...\n");
    for(int i = 0; i < MULTI_PAGES; i += 4096) {
      global_buffer[i] = 'B'; // Ghi vao dau moi trang de kich hoat copy 
    }
    
    printf("[5] Tien trinh CON: Ghi thanh cong! Da tu tach ra o RAM doc lap moi.\n");
    exit(0);
  } else {
    // --- TIẾN TRÌNH CHA ---
    wait(0);
    printf("[6] Tien trinh CHA: Con da chay xong, kiem tra lai du lieu goc: %c (Phai la 'A').\n", global_buffer[0]);
    printf("--- KIEM THU HOAN THANH ---\n");
    exit(0);
  }
}
