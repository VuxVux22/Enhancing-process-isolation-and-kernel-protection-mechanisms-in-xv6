#include "kernel/types.h" 

#include "kernel/stat.h" 

#include "user/user.h" 

#include "kernel/memlayout.h" 

 

int main(int argc, char *argv[]) { 

    printf("--- Kich hoat chuong trinh tan cong gia lap tu User Space ---\n"); 

     

    // Con trỏ trỏ thẳng vào địa chỉ bắt đầu vùng nhớ Kernel Text (0x80000000) 

    uint64 *kernel_text_ptr = (uint64 *) KERNBASE;  

     

    printf("[ATTACK] Dang co tinh ghi de du lieu vao vi tri KERNBASE (0x80000000)...\n"); 

 

    // Hành vi tấn công: Ép CPU thực hiện lệnh ghi vào vùng chỉ cho phép Đọc/Thực thi 

    *kernel_text_ptr = 0x99999999; 

 

    // Nếu klogger và bảo vệ bảng trang chạy đúng, dòng này sẽ KHÔNG BAO GIỜ được in ra 

    printf("[LOI NGHIEM TRONG] GIA CỐ THẤT BẠI! Tien trinh User van sua doi duoc Kernel.\n"); 

     

    exit(1); 

} 
