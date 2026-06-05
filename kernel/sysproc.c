#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0;  // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if(t == SBRK_EAGER || n < 0) {
    if(growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
      return -1;
    if(addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if(n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

uint64
sys_hello(void)
{
  printf("kernel: hello() dang chay trong kernel!\n");
  return 0;
}

uint64
sys_ps(void)
{
  struct proc *p;
  extern struct proc proc[]; // Tham chiếu mảng tiến trình toàn cục của Kernel

  printf("\nPID\tSTATE\t\tNAME\n");
  for(p = proc; p < &proc[NPROC]; p++){
    if(p->state == UNUSED) continue;
    
    char *state;
    if(p->state == SLEEPING) state = "sleep";
    else if(p->state == RUNNABLE) state = "runble";
    else if(p->state == RUNNING)  state = "run";
    else if(p->state == ZOMBIE)   state = "zombie";
    else state = "???";

    printf("%d\t%s\t%s\n", p->pid, state, p->name);
  }
  return 0;
}

uint64
sys_memtest(void)
{
  char *mem = kalloc(); // Cấp phát 1 trang bộ nhớ (4096 bytes)
  
  if(mem == 0){
    printf("Kernel: Cap phat bo nho THAT BAI!\n");
    return -1;
  }

  printf("Kernel: Da cap phat 4KB tai dia chi vat ly: %p\n", mem);
  
  // Điền dữ liệu thử vào bộ nhớ
  mem[0] = 'X';
  printf("Kernel: Ghi thu du lieu vao o nho dau tien: %c\n", mem[0]);

  kfree(mem); // Giải phóng bộ nhớ sau khi dùng xong
  printf("Kernel: Da giai phong bo nho.\n");
  
  return 0;
}

// --- KHAI BÁO BIẾN TOÀN CỤC VÀ SPINLOCK CHO BÀI TEST RACE CONDITION ---
struct spinlock ptlock;
int shared_pte = 0;

// Phiên bản KHÔNG dùng spinlock (Dễ xảy ra Race Condition)
void
pte_update_nolock(void)
{
  int temp;
  temp = shared_pte;
  // Tạo delay để ép các CPU xen kẽ thao tác vào nhau
  for(volatile int i = 0; i < 10000; i++);
  temp = temp + 1;
  shared_pte = temp;
}

// Phiên bản CÓ dùng spinlock bảo vệ Critical Section
void
pte_update_lock(void)
{
  acquire(&ptlock);
  int temp;
  temp = shared_pte;
  for(volatile int i = 0; i < 10000; i++);
  temp = temp + 1;
  shared_pte = temp;
  release(&ptlock);
}

// Syscall wrapper cho phiên bản không khóa
uint64
sys_testnolock(void)
{
  pte_update_nolock();
  return shared_pte;
}

// Syscall wrapper cho phiên bản có khóa
uint64
sys_testlock(void)
{
  pte_update_lock();
  return shared_pte;
}

// --- ĐO LƯỜNG LATENCY SYSTEM CALL (FIXED FOR RISC-V USER TRAP) ---

// Đọc thanh ghi chu kỳ máy an toàn từ tầng Kernel (Supervisor Mode)
uint64
kernel_rdcycle(void)
{
  uint64 x;
  asm volatile("rdcycle %0" : "=r"(x));
  return x;
}

// Baseline syscall rỗng
uint64
sys_getcycles(void)
{
  uint xticks;
  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return (uint64)xticks;
}

// Giữ nguyên hàm nullcall cơ sở của bạn
uint64
sys_nullcall(void)
{
  return 0; 
}

uint64
sys_set_filter(void)
{
  uint64 mask;
  argaddr(0, &mask); 
  
  struct proc *p = myproc();
  
  // CẬP NHẬT TÊN BIẾN TẠI ĐÂY:
  p->sc_filter = mask; 
  
  return 0;
}
