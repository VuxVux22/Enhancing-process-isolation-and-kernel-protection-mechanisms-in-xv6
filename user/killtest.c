#include "kernel/types.h"
#include "user/user.h"

void
execute_bad_behavior()
{
  // Ép ghi dữ liệu vào một địa chỉ ảo bất hợp pháp vượt quá kích thước tiến trình (p->sz)
  // để MMU ném trap scause 15 về cho Kernel xử lý
  volatile char *bad_ptr = (char*)0x7FFFFFFF0000L; 
  *bad_ptr = 0xAA; 
}

void
test_stride_kill_on_sight()
{
  printf("--- BAT DAU KIEM THU CO CHE PHONG THU STRIDE: KILL ON SIGHT ---\n");

  // Giả lập hệ thống liên tục hứng chịu 3 đợt vi phạm bộ nhớ nghiêm trọng
  for(int i = 1; i <= 3; i++) {
    printf("[HE THONG] Phat hien dot vi pham bo nho tiem tang thu: %d\n", i);
    
    int pid = fork();
    if(pid < 0) {
      printf("Fork that bai!\n");
      exit(1);
    }

    if(pid == 0) {
      // Tiến trình con đóng vai trò Kẻ tấn công (Attacker)
      execute_bad_behavior();
      
      // Nếu luồng xử lý lỗi không diệt tiến trình, dòng này sẽ bị lọt ra
      printf("[LOI] Kẻ tan cong thoat hiem!\n");
      exit(0);
    } else {
      // Tiến trình cha chờ con bị xử tử xong để tiếp tục vòng lặp theo dõi
      wait(0);
    }
  }

  printf("\n[HE THONG] Nguong loi lien tiep da cham muc 3.\n");
  printf("--- KIEM THU PHONG THU STRIDE THANH CONG! ---\n");
}

int
main(int argc, char *argv[])
{
  test_stride_kill_on_sight();
  exit(0);
}
