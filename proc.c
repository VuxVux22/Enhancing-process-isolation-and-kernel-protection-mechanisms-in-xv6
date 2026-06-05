pagetable_t
proc_pagetable(struct proc *p)
{
  pagetable_t pt;

  // 1. Tạo bảng trang trống (cấp phát 1 trang vật lý)
  pt = uvmcreate();
  if(pt == 0)
    return 0;

  // 2. Ánh xạ Trampoline (quyền: Read, Execute - KHÔNG có User bit)
  // trampoline là biến toàn cục chứa địa chỉ vật lý của mã trampoline
  if(mappages(pt, TRAMPOLINE, PGSIZE,
              (uint64)trampoline, PTE_R | PTE_X) < 0){
    uvmfree(pt, 0);
    return 0;
  }

  // 3. Ánh xạ Trapframe (quyền: Read, Write - KHÔNG có User bit)
  // p->trapframe là địa chỉ vật lý đã được cấp phát trong hàm allocproc()
  if(mappages(pt, TRAPFRAME, PGSIZE,
              (uint64)(p->trapframe), PTE_R | PTE_W) < 0){
    // Nếu lỗi, phải gỡ bỏ ánh xạ trampoline trước khi giải phóng bảng trang
    uvmunmap(pt, TRAMPOLINE, 1, 0);
    uvmfree(pt, 0);
    return 0;
  }

  return pt;
}
