#include "param.h"
#include "types.h"
#include "memlayout.h"
#include "elf.h"
#include "riscv.h"
#include "defs.h"
#include "spinlock.h"
#include "proc.h"
#include "fs.h"

/*
 * the kernel's page table.
 */
pagetable_t kernel_pagetable;

extern char etext[];  // kernel.ld sets this to end of kernel code.

extern char trampoline[]; // trampoline.S

// Make a direct-map page table for the kernel.
pagetable_t
kvmmake(void)
{
  pagetable_t kpgtbl;

  kpgtbl = (pagetable_t) kalloc();
  memset(kpgtbl, 0, PGSIZE);

  // uart registers
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);

  // virtio mmio disk interface
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);

  // PLIC - SỬA LỖI: Đảm bảo kích thước là 0x4000000
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);

  // map kernel text executable and read-only.
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);

  // map kernel data and the physical RAM we'll make use of.
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);

  // map the trampoline for trap entry/exit to
  // the highest virtual address in the kernel.
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  // QUAN TRỌNG: Comment dòng này vì chúng ta ánh xạ stack riêng trong allocproc
  // proc_mapstacks(kpgtbl); 
  
  return kpgtbl;
}

// add a mapping to the kernel page table.
void
kvmmap(pagetable_t kpgtbl, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    panic("kvmmap");
}

// Initialize the kernel_pagetable, shared by all CPUs.
void
kvminit(void)
{
  kernel_pagetable = kvmmake();
}

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
// Cải tiến hàm để nạp bất kỳ bảng trang nào (linh hoạt hơn)
void
kvm_switch(pagetable_t kpt)
{
  if(kpt == 0) panic("kvm_switch: null kpt"); // Kiểm tra an toàn
  
  w_satp(MAKE_SATP(kpt)); // Nạp bảng trang vào thanh ghi satp
  sfence_vma();           // Xóa TLB để áp dụng quyền PTE mới
}

// Giữ lại tên hàm cũ nhưng gọi qua hàm cải tiến để tránh lỗi biên dịch
void
kvminithart()
{
  kvm_switch(kernel_pagetable); // Nạp bảng trang nhân mặc định
}
// Return the address of the PTE in page table pagetable
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
  if(va >= MAXVA)
    panic("walk");

  for(int level = 2; level > 0; level--) {
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
}

// Look up a virtual address, return the physical address
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    return 0;

  pte = walk(pagetable, va, 0);
  if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}

// Create PTEs for virtual addresses
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0) panic("mappages: va not aligned");
  if((size % PGSIZE) != 0) panic("mappages: size not aligned");
  if(size == 0) panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
      return -1;
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}

pagetable_t
uvmcreate()
{
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
  if(pagetable == 0)
    return 0;
  memset(pagetable, 0, PGSIZE);
  return pagetable;
}

void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages * PGSIZE; a += PGSIZE){
    // Nếu không tìm thấy cây bảng trang, trang này chưa từng được sờ tới -> Bỏ qua an toàn
    if((pte = walk(pagetable, a, 0)) == 0)
      continue;
      
    // Nếu trang không hợp lệ (PTE_V == 0), bỏ qua không free RAM nhưng xóa pte
    if((*pte & PTE_V) == 0){
      *pte = 0;
      continue;
    }
      
    if(PTE_FLAGS(*pte) == PTE_V)
      panic("uvmunmap: not a leaf");
    
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa); 
    }
    *pte = 0;
  }
}

uint64
uvmalloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz, int xperm)
{
  char *mem;
  uint64 a;

  if(newsz < oldsz)
    return oldsz;

  oldsz = PGROUNDUP(oldsz);
  for(a = oldsz; a < newsz; a += PGSIZE){
    mem = kalloc();
    if(mem == 0){
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
      kfree(mem);
      uvmdealloc(pagetable, a, oldsz);
      return 0;
    }
  }
  return newsz;
}

uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
  if(newsz >= oldsz)
    return oldsz;

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}

void
freewalk(pagetable_t pagetable)
{
  for(int i = 0; i < 512; i++){
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    }
  }
  kfree((void*)pagetable);
}

void
uvmfree(pagetable_t pagetable, uint64 sz)
{
  if(sz > 0)
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
}

int
uvmcopy(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walk(old, i, 0)) == 0)
      continue;
    if((*pte & PTE_V) == 0)
      continue;
    
    pa = PTE2PA(*pte);
    
    // Chỉ áp dụng cơ chế COW đối với các trang có quyền GHI (PTE_W) 
    // hoặc trang đã được đánh dấu là PTE_COW từ trước.
    // Trang mã nguồn (chỉ đọc, có bit PTE_X) thì giữ nguyên, không tắt PTE_W bừa bãi.
    if((*pte & PTE_W) || (*pte & PTE_COW)) {
      *pte &= ~PTE_W;   // Khóa quyền ghi của cha
      *pte |= PTE_COW;  // Bật cờ đánh dấu COW
    }
    
    flags = PTE_FLAGS(*pte);
    
    // Ánh xạ thẳng địa chỉ vật lý pa sang tiến trình con
    if(mappages(new, i, PGSIZE, pa, flags) != 0)
      goto err;
      
    // Tăng bộ đếm tham chiếu lên an toàn
    kref_incr(pa);
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
  return -1;
}
void
uvmclear(pagetable_t pagetable, uint64 va)
{
  pte_t *pte = walk(pagetable, va, 0);
  if(pte == 0) panic("uvmclear");
  *pte &= ~PTE_U;
}

int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    va0 = PGROUNDDOWN(dstva);
    if(va0 >= MAXVA) return -1;
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) return -1;
    }
    pte = walk(pagetable, va0, 0);
    if((*pte & PTE_W) == 0) return -1;
    n = PGSIZE - (dstva - va0);
    if(n > len) n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    len -= n; src += n; dstva = va0 + PGSIZE;
  }
  return 0;
}

int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;
  while(len > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) {
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) return -1;
    }
    n = PGSIZE - (srcva - va0);
    if(n > len) n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    len -= n; dst += n; srcva = va0 + PGSIZE;
  }
  return 0;
}

int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;
  while(got_null == 0 && max > 0){
    va0 = PGROUNDDOWN(srcva);
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) return -1;
    n = PGSIZE - (srcva - va0);
    if(n > max) n = max;
    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){ *dst = '\0'; got_null = 1; break; }
      else { *dst = *p; }
      --n; --max; p++; dst++;
    }
    srcva = va0 + PGSIZE;
  }
  return got_null ? 0 : -1;
}

uint64
vmfault(pagetable_t pagetable, uint64 va, int read)
{
  uint64 mem;
  struct proc *p = myproc();
  if (va >= p->sz) return 0;
  va = PGROUNDDOWN(va);
  if(ismapped(pagetable, va)) return 0;
  mem = (uint64) kalloc();
  if(mem == 0) return 0;
  memset((void *) mem, 0, PGSIZE);
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    kfree((void *)mem);
    return 0;
  }
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
  pte_t *pte = walk(pagetable, va, 0);
  return (pte != 0 && (*pte & PTE_V));
}

// --- PHẦN HÀM MỚI CHO ĐỒ ÁN ---

void
uvmmap(pagetable_t pagetable, uint64 va, uint64 pa, uint64 sz, int perm)
{
  if(mappages(pagetable, va, sz, pa, perm) != 0)
    panic("uvmmap");
}

pagetable_t
proc_kpagetable(struct proc *p)
{
  pagetable_t kpt = uvmcreate();
  if(kpt == 0) return 0;

  // Ánh xạ thiết bị ngoại vi
  uvmmap(kpt, UART0, UART0, PGSIZE, PTE_R | PTE_W);
  uvmmap(kpt, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
  
  // SỬA LỖI: Kích thước PLIC phải là 0x4000000[cite: 2]
  uvmmap(kpt, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);

  // Ánh xạ Kernel Code và RAM vật lý[cite: 2]
  uvmmap(kpt, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
  uvmmap(kpt, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
  
  // Ánh xạ Trampoline[cite: 2]
  uvmmap(kpt, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);

  return kpt;
}

void
proc_free_kpagetable(pagetable_t kpt, uint64 kstack)
{
  // 1. Huỷ ánh xạ Stack và giải phóng RAM vật lý của stack[cite: 2]
  uvmunmap(kpt, kstack, 1, 1); 
  
  // 2. Huỷ ánh xạ các vùng khác nhưng KHÔNG giải phóng RAM vật lý (vì dùng chung)[cite: 2]
  uvmunmap(kpt, UART0, 1, 0);
  uvmunmap(kpt, VIRTIO0, 1, 0);
  uvmunmap(kpt, PLIC, 0x4000000/PGSIZE, 0);
  uvmunmap(kpt, KERNBASE, ((uint64)etext-KERNBASE)/PGSIZE, 0);
  uvmunmap(kpt, (uint64)etext, (PHYSTOP-(uint64)etext)/PGSIZE, 0);
  uvmunmap(kpt, TRAMPOLINE, 1, 0);

  // 3. Giải phóng các trang PTE[cite: 2]
  uvmfree(kpt, 0);
}
// Hàm xử lý Copy-on-Write khi xảy ra Store Page Fault
int
cow_handler(pagetable_t pagetable, uint64 va)
{
  va = PGROUNDDOWN(va);
  if(va >= MAXVA) return -1;

  pte_t *pte = walk(pagetable, va, 0);
  if(pte == 0) return -1;
  
  // Kiểm tra tính hợp lệ: trang phải tồn tại (PTE_V) và phải được đánh dấu là trang chia sẻ (PTE_COW)
  if((*pte & PTE_V) == 0 || (*pte & PTE_COW) == 0)
    return -1;

  uint64 pa_old = PTE2PA(*pte);
  
  // Cấp phát trang nhớ vật lý mới On-demand
  char *mem = kalloc();
  if(mem == 0) return -1; // Trả về lỗi nếu hết bộ nhớ RAM

  // Sao chép nguyên vẹn dữ liệu từ trang cũ sang trang mới
  memmove(mem, (char*)pa_old, PGSIZE);

  // Thiết lập lại thuộc tính cờ: Thêm lại quyền ghi (PTE_W), gỡ bỏ cờ chia sẻ (PTE_COW)
  uint flags = PTE_FLAGS(*pte);
  flags |= PTE_W;
  flags &= ~PTE_COW;

  // Cập nhật lại ánh xạ của bảng trang sang ô nhớ vật lý mới
  *pte = PA2PTE((uint64)mem) | flags;

  // Giải phóng trang cũ (Hàm này cần bổ sung bộ đếm liên kết tham chiếu ở bước hoàn thiện nâng cao)
  kfree((void*)pa_old);

  return 0;
}
