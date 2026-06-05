// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

// --- PHẦN BỔ SUNG CHO ĐỒ ÁN COPY-ON-WRITE (NHÓM 15) ---
// Định nghĩa cấu trúc quản lý bộ đếm tham chiếu cho toàn bộ trang RAM vật lý
struct {
  struct spinlock lock;
  int count[PHYSTOP / PGSIZE];
} kref;

// Hàm hỗ trợ lấy chỉ số (index) của trang vật lý trong mảng count
static inline uint64
pa_idx(void *pa)
{
  return (uint64)pa / PGSIZE;
}
// ------------------------------------------------------

void
kinit()
{
  initlock(&kmem.lock, "kmem");
  
  // Khởi tạo khóa spinlock cho bộ đếm tham chiếu COW
  initlock(&kref.lock, "kref");
  
  // Ban đầu đặt toàn bộ bộ đếm về 0 trước khi giải phóng dải RAM
  acquire(&kref.lock);
  for(int i = 0; i < PHYSTOP / PGSIZE; i++){
    kref.count[i] = 0;
  }
  release(&kref.lock);

  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    // Ép số lượng tham chiếu của trang RAM ban đầu bằng 1 
    // để hàm kfree() bên dưới có thể giảm về 0 và đẩy vào freelist hợp lệ
    kref.count[pa_idx(p)] = 1;
    kfree(p);
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  // ---- ĐOẠN ĐỒNG BỘ BỘ ĐẾM THAM CHIẾU COW ----
  acquire(&kref.lock);
  uint64 idx = (uint64)pa / PGSIZE;
  
  // Bảo vệ hệ thống: Nếu trang chưa từng được đếm (hoặc trang bảng trang không quản lý ref)
  // thì đặt mặc định bằng 1 để giảm xuống 0 hợp lệ.
  if(kref.count[idx] <= 0){
    kref.count[idx] = 1;
  }

  kref.count[idx]--;
  
  if(kref.count[idx] > 0){
    // Nếu vẫn còn tiến trình khác dùng chung trang này -> Giữ lại RAM
    release(&kref.lock);
    return;
  }
  release(&kref.lock);
  // ---------------------------------------------

  // Khi count thực sự về 0, tiến hành xóa sạch dữ liệu và trả về kmem.freelist
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  // SỬA TẠI ĐÂY: Sử dụng đúng tên cấu trúc gốc `kmem` của xv6
  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r){
    memset((char*)r, 5, PGSIZE); // fill with junk
    
    // Khi một trang RAM được cấp phát mới thành công,
    // khởi tạo số lượng tham chiếu (Reference count) của nó bằng 1
    acquire(&kref.lock);
    kref.count[pa_idx(r)] = 1;
    release(&kref.lock);
  }
  return (void*)r;
}

// --- HAI HÀM TIỆN ÍCH QUẢN LÝ THAM CHIẾU DÙNG CHO VM.C ---

// Hàm tăng bộ đếm tham chiếu (gọi khi thực hiện uvmcopy() nhân bản tiến trình)
void
kref_incr(uint64 pa)
{
  if(pa >= PHYSTOP || pa < (uint64)end) return;
  
  acquire(&kref.lock);
  kref.count[pa / PGSIZE]++;
  release(&kref.lock);
}

// Hàm kiểm tra xem trang RAM vật lý này hiện tại có đang bị dùng chung hay không
int
kref_get(uint64 pa)
{
  if(pa >= PHYSTOP || pa < (uint64)end) return 0;
  
  int cnt;
  acquire(&kref.lock);
  cnt = kref.count[pa / PGSIZE];
  release(&kref.lock);
  return cnt;
}
