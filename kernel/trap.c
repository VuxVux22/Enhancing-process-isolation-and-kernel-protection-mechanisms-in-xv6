#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "riscv.h"
#include "spinlock.h"
#include "proc.h"
#include "defs.h"

struct spinlock tickslock;
uint ticks;

extern char trampoline[], uservec[];

// in kernelvec.S, calls kerneltrap().
void kernelvec();

extern int devintr();

void
trapinit(void)
{
  initlock(&tickslock, "time");
}

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
  w_stvec((uint64)kernelvec);
}

//
// handle an interrupt, exception, or system call from user space.
// called from, and returns to, trampoline.S
// return value is user satp for trampoline.S to switch to.
//
uint64
usertrap(void)
{
  int which_dev = 0;

  if((r_sstatus() & SSTATUS_SPP) != 0)
    panic("usertrap: not from user mode");

  // send interrupts and exceptions to kerneltrap(),
  // since we're now in the kernel.
  w_stvec((uint64)kernelvec);  //DOC: kernelvec

  struct proc *p = myproc();
  
  // save user program counter.
  p->trapframe->epc = r_sepc();
  
  if(r_scause() == 8){
    // system call

    if(killed(p))
      kexit(-1);

    // sepc points to the ecall instruction,
    // but we want to return to the next instruction.
    p->trapframe->epc += 4;

    // an interrupt will change sepc, scause, and sstatus,
    // so enable only now that we're done with those registers.
    intr_on();

    syscall();
} else if((which_dev = devintr()) != 0){
    // ok
} 
  // =========================================================================
  // KHỐI CODE KLOGGER CHỈ THÊM MỚI - GIỮ NGUYÊN 100% TOÀN BỘ CODE CŨ PHÍA DƯỚI
  // =========================================================================
  else if((r_scause() == 15 || r_scause() == 13) && r_stval() >= 0x80000000) {
    uint64 va = r_stval();
    struct proc *p = myproc();

    printf("\n[KLOGGER ALERT] !!! PHAT HIEN HANH VI TAN CONG HE THONG !!!\n");
    printf("[KLOGGER LOG] Tien trinh vi pham: '%s' (PID: %d)\n", p->name, p->pid);
    printf("[KLOGGER LOG] Dia chi Kernel bi nham toi: 0x%lx\n", va);
    // SỬA LỖI FORMAT: Đổi %d thành %ld để khớp với kiểu dữ liệu uint64 của r_scause()
    printf("[KLOGGER LOG] Ma loi phan cung (scause): %ld (%s)\n", 
           r_scause(), (r_scause() == 15) ? "Store Page Fault" : "Load Page Fault");
    printf("[KLOGGER ACTION] Kich hoat co che bao ve bang trang, HANH QUYET TIEN TRINH LAP TUC!\n\n");
    
    setkilled(p); // Đánh dấu tiêu diệt tiến trình vi phạm
} else if(r_scause() == 15 || r_scause() == 13) {
    // --- XỬ LÝ PAGE FAULT CHỐNG TẤN CÔNG STRIDE (NHÓM 15) ---
    uint64 va = r_stval();
    static int global_stride_faults = 0; // Biến tĩnh toàn cục lưu vết đợt tấn công

    // 1. Kiểm tra tính hợp lệ của địa chỉ ảo (vượt biên hoặc vùng cấm)
    if(va >= p->sz || PGROUNDDOWN(va) == 0) {
      global_stride_faults++; // CHỈ TĂNG Ở ĐÂY KHI CÓ HÀNH VI PHÁ HOẠI CỐ Ý
      
      printf("\n[CANH BAO STRIDE] Tien trinh '%s' (PID: %d) vi pham truy cap bo nho! (VA: 0x%lx)\n", p->name, p->pid, va);
      printf("[STRIDE LOG] He thong ghi nhan dot vi pham lien tiep thu: %d/3\n", global_stride_faults);
      
      if(global_stride_faults >= 3) {
        printf("[KILL ON SIGHT] Kich hoat co che hanh quyet tu dong de bao ve toan ven he thong!\n");
        global_stride_faults = 0; // Reset ngay sau khi xử lý mối đe dọa
      }
      setkilled(p);
    } 
    // 2. Thử xử lý theo cơ chế Copy-on-Write hợp lệ
    else if(r_scause() == 15 && cow_handler(p->pagetable, va) == 0) {
      // Xử lý hoàn tất thành công -> Hành vi hợp lệ
    } 
    // 3. Thử kiểm tra cơ chế phân bổ lười (Lazy Allocation) nếu có sẵn
    else if(vmfault(p->pagetable, va, (r_scause() == 13) ? 1 : 0) != 0) {
      // Xử lý lazy allocation thành công -> Hành vi hợp lệ
    } 
    // 4. Tất cả các giải pháp cứu vãn thất bại (Hết RAM vật lý)
    else {
      // Tách biệt hoàn toàn: Không tăng biến global_stride_faults ở đây để tránh giết nhầm lệnh exec()
      printf("\n[HE THONG] Page Fault khong the cuu van tren '%s' (PID: %d)\n", p->name, p->pid);
      setkilled(p);
    }
  } else {
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    setkilled(p);
  }

  if(killed(p))
    kexit(-1);

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2)
    yield();

  prepare_return();

  // the user page table to switch to, for trampoline.S
  uint64 satp = MAKE_SATP(p->pagetable);

  // return to trampoline.S; satp value in a0.
  return satp;
}

//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
  struct proc *p = myproc();

  // we're about to switch the destination of traps from
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
  p->trapframe->kernel_trap = (uint64)usertrap;
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()

  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
  x |= SSTATUS_SPIE; // enable interrupts in user mode
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
}

// interrupts and exceptions from kernel code go here via kernelvec,
// on whatever the current kernel stack is.
void 
kerneltrap()
{
  int which_dev = 0;
  uint64 sepc = r_sepc();
  uint64 sstatus = r_sstatus();
  uint64 scause = r_scause();
  
  if((sstatus & SSTATUS_SPP) == 0)
    panic("kerneltrap: not from supervisor mode");
  if(intr_get() != 0)
    panic("kerneltrap: interrupts enabled");

  if((which_dev = devintr()) == 0){
    // interrupt or trap from an unknown source
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    panic("kerneltrap");
  }

  // give up the CPU if this is a timer interrupt.
  if(which_dev == 2 && myproc() != 0)
    yield();

  // the yield() may have caused some traps to occur,
  // so restore trap registers for use by kernelvec.S's sepc instruction.
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void
clockintr()
{
  if(cpuid() == 0){
    acquire(&tickslock);
    ticks++;
    wakeup(&ticks);
    release(&tickslock);
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
}

// check if it's an external interrupt or software interrupt,
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    // this is a supervisor external interrupt, via PLIC.

    // irq indicates which device interrupted.
    int irq = plic_claim();

    if(irq == UART0_IRQ){
      uartintr();
    } else if(irq == VIRTIO0_IRQ){
      virtio_disk_intr();
    } else if(irq){
      printf("unexpected interrupt irq=%d\n", irq);
    }

    // the PLIC allows each device to raise at most one
    // interrupt at a time; tell the PLIC the device is
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
  }
}

