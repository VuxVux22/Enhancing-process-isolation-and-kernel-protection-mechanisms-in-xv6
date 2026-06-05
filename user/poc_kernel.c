#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

/**
 * PoC - Proof of Concept
 * Muc tieu: Truy cap vao dia chi 0x80000000 (bat dau cua Kernel)
 * tu User-mode de kich hoat loi phan quyen.
 */
int main(int argc, char *argv[]) {
    // Trong xv6 RISC-V, 0x80000000 la KERNBASE
    uint64 kernel_address = 0x80000000;

    printf("--- Bat dau PoC ---\n");
    printf("Dang thu doc du lieu tai dia chi Kernel: %p...\n", kernel_address);

    // Dong lenh nay se gay ra loi Trap
    uint64 data = *(uint64 *)kernel_address;

    // Neu code chay den day, nghia la he thong dang gap loi bao mat nghiem trong
    printf("Ket qua (nguy hiem): %p\n", data);

    exit(0);
}
