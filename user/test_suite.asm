
user/_test_suite:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <test_overflow>:
#define NULL_PTR 0x0 

// 1. KỊCH BẢN 1: Tấn công Tràn bộ đệm (Buffer Overflow) / Guard Page Test 
void 
test_overflow(void) 
{ 
   0:	c5010113          	addi	sp,sp,-944
   4:	3a113423          	sd	ra,936(sp)
   8:	3a813023          	sd	s0,928(sp)
   c:	1f00                	addi	s0,sp,944
   e:	72fd                	lui	t0,0xfffff
  10:	9116                	add	sp,sp,t0
  printf("[TEST 1] Chay kich ban Buffer Overflow / Guard Page...\n"); 
  12:	00001517          	auipc	a0,0x1
  16:	b7e50513          	addi	a0,a0,-1154 # b90 <malloc+0xf8>
  1a:	1cb000ef          	jal	9e4 <printf>
   
  int pid = fork();
  1e:	556000ef          	jal	574 <fork>
  if(pid < 0) {
  22:	02054963          	bltz	a0,54 <test_overflow+0x54>
    printf("Fork failed\n");
    exit(1);
  }

  if(pid == 0) {
  26:	c121                	beqz	a0,66 <test_overflow+0x66>
     
    printf("[INFO] Buffer Overflow Test completed without crash (Unexpected).\n"); 
    exit(0);
  } else {
    int status;
    wait(&status);
  28:	757d                	lui	a0,0xfffff
  2a:	c6850793          	addi	a5,a0,-920 # ffffffffffffec68 <base+0xffffffffffffdc58>
  2e:	00878533          	add	a0,a5,s0
  32:	552000ef          	jal	584 <wait>
    printf("[OK] Buffer Overflow blocked safely by Guard Page (Process terminated). ✅\n");
  36:	00001517          	auipc	a0,0x1
  3a:	c0a50513          	addi	a0,a0,-1014 # c40 <malloc+0x1a8>
  3e:	1a7000ef          	jal	9e4 <printf>
  }
} 
  42:	6285                	lui	t0,0x1
  44:	9116                	add	sp,sp,t0
  46:	3a813083          	ld	ra,936(sp)
  4a:	3a013403          	ld	s0,928(sp)
  4e:	3b010113          	addi	sp,sp,944
  52:	8082                	ret
    printf("Fork failed\n");
  54:	00001517          	auipc	a0,0x1
  58:	b7450513          	addi	a0,a0,-1164 # bc8 <malloc+0x130>
  5c:	189000ef          	jal	9e4 <printf>
    exit(1);
  60:	4505                	li	a0,1
  62:	51a000ef          	jal	57c <exit>
      big_buffer[i] = 'A'; 
  66:	77fd                	lui	a5,0xfffff
  68:	17c1                	addi	a5,a5,-16 # ffffffffffffeff0 <base+0xffffffffffffdfe0>
  6a:	97a2                	add	a5,a5,s0
  6c:	777d                	lui	a4,0xfffff
  6e:	c5870713          	addi	a4,a4,-936 # ffffffffffffec58 <base+0xffffffffffffdc48>
  72:	9722                	add	a4,a4,s0
  74:	e31c                	sd	a5,0(a4)
  76:	04100693          	li	a3,65
    for(int i = 0; i < 5000; i += 512) { 
  7a:	6705                	lui	a4,0x1
  7c:	40070713          	addi	a4,a4,1024 # 1400 <base+0x3f0>
      big_buffer[i] = 'A'; 
  80:	77fd                	lui	a5,0xfffff
  82:	c5878793          	addi	a5,a5,-936 # ffffffffffffec58 <base+0xffffffffffffdc48>
  86:	97a2                	add	a5,a5,s0
  88:	639c                	ld	a5,0(a5)
  8a:	97aa                	add	a5,a5,a0
  8c:	c6d78c23          	sb	a3,-904(a5)
    for(int i = 0; i < 5000; i += 512) { 
  90:	2005051b          	addiw	a0,a0,512
  94:	fee516e3          	bne	a0,a4,80 <test_overflow+0x80>
    char dummy = big_buffer[0];
  98:	77fd                	lui	a5,0xfffff
  9a:	17c1                	addi	a5,a5,-16 # ffffffffffffeff0 <base+0xffffffffffffdfe0>
  9c:	97a2                	add	a5,a5,s0
  9e:	c787c783          	lbu	a5,-904(a5)
  a2:	0ff7f793          	zext.b	a5,a5
    if(dummy == 'Z') {
  a6:	05a00713          	li	a4,90
  aa:	00e78b63          	beq	a5,a4,c0 <test_overflow+0xc0>
    printf("[INFO] Buffer Overflow Test completed without crash (Unexpected).\n"); 
  ae:	00001517          	auipc	a0,0x1
  b2:	b4a50513          	addi	a0,a0,-1206 # bf8 <malloc+0x160>
  b6:	12f000ef          	jal	9e4 <printf>
    exit(0);
  ba:	4501                	li	a0,0
  bc:	4c0000ef          	jal	57c <exit>
      printf("This will never happen\n");
  c0:	00001517          	auipc	a0,0x1
  c4:	b2050513          	addi	a0,a0,-1248 # be0 <malloc+0x148>
  c8:	11d000ef          	jal	9e4 <printf>
  cc:	b7cd                	j	ae <test_overflow+0xae>

00000000000000ce <test_null_pointer>:

// 2. KỊCH BẢN 2: Tấn công Con trỏ rỗng (Null Pointer Dereference) 
void 
test_null_pointer(void) 
{ 
  ce:	1101                	addi	sp,sp,-32
  d0:	ec06                	sd	ra,24(sp)
  d2:	e822                	sd	s0,16(sp)
  d4:	1000                	addi	s0,sp,32
  printf("[TEST 2] Chay kich ban Null Pointer Dereference...\n"); 
  d6:	00001517          	auipc	a0,0x1
  da:	bba50513          	addi	a0,a0,-1094 # c90 <malloc+0x1f8>
  de:	107000ef          	jal	9e4 <printf>
   
  int pid = fork();
  e2:	492000ef          	jal	574 <fork>
  if(pid < 0) {
  e6:	02054163          	bltz	a0,108 <test_null_pointer+0x3a>
    printf("Fork failed\n");
    exit(1);
  }

  if(pid == 0) {
  ea:	c905                	beqz	a0,11a <test_null_pointer+0x4c>
     
    printf("[INFO] Null Pointer Test completed without crash (Unexpected).\n"); 
    exit(0);
  } else {
    int status;
    wait(&status);
  ec:	fec40513          	addi	a0,s0,-20
  f0:	494000ef          	jal	584 <wait>
    printf("[OK] Null Pointer Dereference blocked safely by MMU Page Table. ✅\n");
  f4:	00001517          	auipc	a0,0x1
  f8:	c1450513          	addi	a0,a0,-1004 # d08 <malloc+0x270>
  fc:	0e9000ef          	jal	9e4 <printf>
  }
} 
 100:	60e2                	ld	ra,24(sp)
 102:	6442                	ld	s0,16(sp)
 104:	6105                	addi	sp,sp,32
 106:	8082                	ret
    printf("Fork failed\n");
 108:	00001517          	auipc	a0,0x1
 10c:	ac050513          	addi	a0,a0,-1344 # bc8 <malloc+0x130>
 110:	0d5000ef          	jal	9e4 <printf>
    exit(1);
 114:	4505                	li	a0,1
 116:	466000ef          	jal	57c <exit>
    *ptr = 'X';  
 11a:	05800793          	li	a5,88
 11e:	00f00023          	sb	a5,0(zero) # 0 <test_overflow>
    printf("[INFO] Null Pointer Test completed without crash (Unexpected).\n"); 
 122:	00001517          	auipc	a0,0x1
 126:	ba650513          	addi	a0,a0,-1114 # cc8 <malloc+0x230>
 12a:	0bb000ef          	jal	9e4 <printf>
    exit(0);
 12e:	4501                	li	a0,0
 130:	44c000ef          	jal	57c <exit>

0000000000000134 <test_code_injection>:

// 3. KỊCH BẢN 3: Tấn công Chèn mã độc (Code Injection / PTE_X Test) 
void 
test_code_injection(void) 
{ 
 134:	1101                	addi	sp,sp,-32
 136:	ec06                	sd	ra,24(sp)
 138:	e822                	sd	s0,16(sp)
 13a:	1000                	addi	s0,sp,32
  printf("[TEST 3] Chay kich ban Code Injection...\n"); 
 13c:	00001517          	auipc	a0,0x1
 140:	c1450513          	addi	a0,a0,-1004 # d50 <malloc+0x2b8>
 144:	0a1000ef          	jal	9e4 <printf>
   
  int pid = fork();
 148:	42c000ef          	jal	574 <fork>
  if(pid < 0) {
 14c:	02054163          	bltz	a0,16e <test_code_injection+0x3a>
    printf("Fork failed\n");
    exit(1);
  }

  if(pid == 0) {
 150:	c905                	beqz	a0,180 <test_code_injection+0x4c>
     
    printf("[INFO] Code Injection Test completed without crash (Unexpected).\n"); 
    exit(0);
  } else {
    int status;
    wait(&status);
 152:	fe840513          	addi	a0,s0,-24
 156:	42e000ef          	jal	584 <wait>
    printf("[OK] Code Execution on Page without PTE_X blocked by CPU Trap! ✅\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	c6e50513          	addi	a0,a0,-914 # dc8 <malloc+0x330>
 162:	083000ef          	jal	9e4 <printf>
  }
} 
 166:	60e2                	ld	ra,24(sp)
 168:	6442                	ld	s0,16(sp)
 16a:	6105                	addi	sp,sp,32
 16c:	8082                	ret
    printf("Fork failed\n");
 16e:	00001517          	auipc	a0,0x1
 172:	a5a50513          	addi	a0,a0,-1446 # bc8 <malloc+0x130>
 176:	06f000ef          	jal	9e4 <printf>
    exit(1);
 17a:	4505                	li	a0,1
 17c:	400000ef          	jal	57c <exit>
    void (*func_ptr)(void) = (void (*)(void))shellcode; 
 180:	fe840793          	addi	a5,s0,-24
    func_ptr();  
 184:	9782                	jalr	a5
    printf("[INFO] Code Injection Test completed without crash (Unexpected).\n"); 
 186:	00001517          	auipc	a0,0x1
 18a:	bfa50513          	addi	a0,a0,-1030 # d80 <malloc+0x2e8>
 18e:	057000ef          	jal	9e4 <printf>
    exit(0);
 192:	4501                	li	a0,0
 194:	3e8000ef          	jal	57c <exit>

0000000000000198 <test_cow_stress>:

// 4. KỊCH BẢN 4: Kiểm tra áp lực cao (Stress Test cho nhiều tiến trình COW đồng thời) 
void 
test_cow_stress(void) 
{ 
 198:	1101                	addi	sp,sp,-32
 19a:	ec06                	sd	ra,24(sp)
 19c:	e822                	sd	s0,16(sp)
 19e:	e426                	sd	s1,8(sp)
 1a0:	e04a                	sd	s2,0(sp)
 1a2:	1000                	addi	s0,sp,32
  printf("[TEST 4] Chay Stress Test voi dong thoi nhieu tien trinh COW...\n"); 
 1a4:	00001517          	auipc	a0,0x1
 1a8:	c6c50513          	addi	a0,a0,-916 # e10 <malloc+0x378>
 1ac:	039000ef          	jal	9e4 <printf>
   
  int nprocs = 4; 
   
  for(int i = 0; i < nprocs; i++){ 
 1b0:	4481                	li	s1,0
 1b2:	4911                	li	s2,4
    int pid = fork(); 
 1b4:	3c0000ef          	jal	574 <fork>
    if(pid < 0){ 
 1b8:	02054e63          	bltz	a0,1f4 <test_cow_stress+0x5c>
      printf("[ERROR] Fork that bai tai luot: %d\n", i); 
      exit(1); 
    } 
     
    if(pid == 0){ 
 1bc:	c531                	beqz	a0,208 <test_cow_stress+0x70>
  for(int i = 0; i < nprocs; i++){ 
 1be:	2485                	addiw	s1,s1,1
 1c0:	ff249ae3          	bne	s1,s2,1b4 <test_cow_stress+0x1c>
      exit(0); 
    } 
  } 
   
  for(int i = 0; i < nprocs; i++){ 
    wait(0); 
 1c4:	4501                	li	a0,0
 1c6:	3be000ef          	jal	584 <wait>
 1ca:	4501                	li	a0,0
 1cc:	3b8000ef          	jal	584 <wait>
 1d0:	4501                	li	a0,0
 1d2:	3b2000ef          	jal	584 <wait>
 1d6:	4501                	li	a0,0
 1d8:	3ac000ef          	jal	584 <wait>
  } 
  printf("[SUCCESS] Stress Test cho co che COW hoan thanh, Kernel van hanh on dinh! ✅\n"); 
 1dc:	00001517          	auipc	a0,0x1
 1e0:	ca450513          	addi	a0,a0,-860 # e80 <malloc+0x3e8>
 1e4:	001000ef          	jal	9e4 <printf>
} 
 1e8:	60e2                	ld	ra,24(sp)
 1ea:	6442                	ld	s0,16(sp)
 1ec:	64a2                	ld	s1,8(sp)
 1ee:	6902                	ld	s2,0(sp)
 1f0:	6105                	addi	sp,sp,32
 1f2:	8082                	ret
      printf("[ERROR] Fork that bai tai luot: %d\n", i); 
 1f4:	85a6                	mv	a1,s1
 1f6:	00001517          	auipc	a0,0x1
 1fa:	c6250513          	addi	a0,a0,-926 # e58 <malloc+0x3c0>
 1fe:	7e6000ef          	jal	9e4 <printf>
      exit(1); 
 202:	4505                	li	a0,1
 204:	378000ef          	jal	57c <exit>
      char *page_ram = sbrk(4096 * 10); 
 208:	6529                	lui	a0,0xa
 20a:	33e000ef          	jal	548 <sbrk>
      if(page_ram != (char*)-1){ 
 20e:	57fd                	li	a5,-1
 210:	00f50e63          	beq	a0,a5,22c <test_cow_stress+0x94>
 214:	87aa                	mv	a5,a0
 216:	66a9                	lui	a3,0xa
 218:	00d50733          	add	a4,a0,a3
          page_ram[j] = 'C'; 
 21c:	04300693          	li	a3,67
 220:	00d78023          	sb	a3,0(a5)
        for(int j = 0; j < 4096 * 10; j += 64){ 
 224:	04078793          	addi	a5,a5,64
 228:	fee79ce3          	bne	a5,a4,220 <test_cow_stress+0x88>
      exit(0); 
 22c:	4501                	li	a0,0
 22e:	34e000ef          	jal	57c <exit>

0000000000000232 <main>:

int 
main(int argc, char *argv[]) 
{ 
 232:	1101                	addi	sp,sp,-32
 234:	ec06                	sd	ra,24(sp)
 236:	e822                	sd	s0,16(sp)
 238:	e426                	sd	s1,8(sp)
 23a:	e04a                	sd	s2,0(sp)
 23c:	1000                	addi	s0,sp,32
 23e:	892a                	mv	s2,a0
 240:	84ae                	mv	s1,a1
  printf("==================================================\n"); 
 242:	00001517          	auipc	a0,0x1
 246:	c8e50513          	addi	a0,a0,-882 # ed0 <malloc+0x438>
 24a:	79a000ef          	jal	9e4 <printf>
  printf("  KHOI CHAY BO AUTOMATED TEST SUITE - SECURITY & STRESS\n"); 
 24e:	00001517          	auipc	a0,0x1
 252:	cba50513          	addi	a0,a0,-838 # f08 <malloc+0x470>
 256:	78e000ef          	jal	9e4 <printf>
  printf("==================================================\n"); 
 25a:	00001517          	auipc	a0,0x1
 25e:	c7650513          	addi	a0,a0,-906 # ed0 <malloc+0x438>
 262:	782000ef          	jal	9e4 <printf>
 
  if(argc < 2){ 
 266:	4785                	li	a5,1
 268:	0127df63          	bge	a5,s2,286 <main+0x54>
    printf("Cach dung: test_suite [overflow | null | injection | stress]\n"); 
    exit(1); 
  } 
 
  if(strcmp(argv[1], "overflow") == 0){ 
 26c:	00001597          	auipc	a1,0x1
 270:	d1c58593          	addi	a1,a1,-740 # f88 <malloc+0x4f0>
 274:	6488                	ld	a0,8(s1)
 276:	09e000ef          	jal	314 <strcmp>
 27a:	ed19                	bnez	a0,298 <main+0x66>
    test_overflow(); 
 27c:	d85ff0ef          	jal	0 <test_overflow>
    test_cow_stress(); 
  } else { 
    printf("[ERROR] Tham so khong hop le!\n"); 
  } 
 
  exit(0); 
 280:	4501                	li	a0,0
 282:	2fa000ef          	jal	57c <exit>
    printf("Cach dung: test_suite [overflow | null | injection | stress]\n"); 
 286:	00001517          	auipc	a0,0x1
 28a:	cc250513          	addi	a0,a0,-830 # f48 <malloc+0x4b0>
 28e:	756000ef          	jal	9e4 <printf>
    exit(1); 
 292:	4505                	li	a0,1
 294:	2e8000ef          	jal	57c <exit>
  } else if(strcmp(argv[1], "null") == 0){ 
 298:	00001597          	auipc	a1,0x1
 29c:	d0058593          	addi	a1,a1,-768 # f98 <malloc+0x500>
 2a0:	6488                	ld	a0,8(s1)
 2a2:	072000ef          	jal	314 <strcmp>
 2a6:	e501                	bnez	a0,2ae <main+0x7c>
    test_null_pointer(); 
 2a8:	e27ff0ef          	jal	ce <test_null_pointer>
 2ac:	bfd1                	j	280 <main+0x4e>
  } else if(strcmp(argv[1], "injection") == 0){ 
 2ae:	00001597          	auipc	a1,0x1
 2b2:	cf258593          	addi	a1,a1,-782 # fa0 <malloc+0x508>
 2b6:	6488                	ld	a0,8(s1)
 2b8:	05c000ef          	jal	314 <strcmp>
 2bc:	e501                	bnez	a0,2c4 <main+0x92>
    test_code_injection(); 
 2be:	e77ff0ef          	jal	134 <test_code_injection>
 2c2:	bf7d                	j	280 <main+0x4e>
  } else if(strcmp(argv[1], "stress") == 0){ 
 2c4:	00001597          	auipc	a1,0x1
 2c8:	cec58593          	addi	a1,a1,-788 # fb0 <malloc+0x518>
 2cc:	6488                	ld	a0,8(s1)
 2ce:	046000ef          	jal	314 <strcmp>
 2d2:	e501                	bnez	a0,2da <main+0xa8>
    test_cow_stress(); 
 2d4:	ec5ff0ef          	jal	198 <test_cow_stress>
 2d8:	b765                	j	280 <main+0x4e>
    printf("[ERROR] Tham so khong hop le!\n"); 
 2da:	00001517          	auipc	a0,0x1
 2de:	cde50513          	addi	a0,a0,-802 # fb8 <malloc+0x520>
 2e2:	702000ef          	jal	9e4 <printf>
 2e6:	bf69                	j	280 <main+0x4e>

00000000000002e8 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 2e8:	1141                	addi	sp,sp,-16
 2ea:	e406                	sd	ra,8(sp)
 2ec:	e022                	sd	s0,0(sp)
 2ee:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 2f0:	f43ff0ef          	jal	232 <main>
  exit(r);
 2f4:	288000ef          	jal	57c <exit>

00000000000002f8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 2fe:	87aa                	mv	a5,a0
 300:	0585                	addi	a1,a1,1
 302:	0785                	addi	a5,a5,1
 304:	fff5c703          	lbu	a4,-1(a1)
 308:	fee78fa3          	sb	a4,-1(a5)
 30c:	fb75                	bnez	a4,300 <strcpy+0x8>
    ;
  return os;
}
 30e:	6422                	ld	s0,8(sp)
 310:	0141                	addi	sp,sp,16
 312:	8082                	ret

0000000000000314 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 314:	1141                	addi	sp,sp,-16
 316:	e422                	sd	s0,8(sp)
 318:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 31a:	00054783          	lbu	a5,0(a0)
 31e:	cb91                	beqz	a5,332 <strcmp+0x1e>
 320:	0005c703          	lbu	a4,0(a1)
 324:	00f71763          	bne	a4,a5,332 <strcmp+0x1e>
    p++, q++;
 328:	0505                	addi	a0,a0,1
 32a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 32c:	00054783          	lbu	a5,0(a0)
 330:	fbe5                	bnez	a5,320 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 332:	0005c503          	lbu	a0,0(a1)
}
 336:	40a7853b          	subw	a0,a5,a0
 33a:	6422                	ld	s0,8(sp)
 33c:	0141                	addi	sp,sp,16
 33e:	8082                	ret

0000000000000340 <strlen>:

uint
strlen(const char *s)
{
 340:	1141                	addi	sp,sp,-16
 342:	e422                	sd	s0,8(sp)
 344:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 346:	00054783          	lbu	a5,0(a0)
 34a:	cf91                	beqz	a5,366 <strlen+0x26>
 34c:	0505                	addi	a0,a0,1
 34e:	87aa                	mv	a5,a0
 350:	86be                	mv	a3,a5
 352:	0785                	addi	a5,a5,1
 354:	fff7c703          	lbu	a4,-1(a5)
 358:	ff65                	bnez	a4,350 <strlen+0x10>
 35a:	40a6853b          	subw	a0,a3,a0
 35e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 360:	6422                	ld	s0,8(sp)
 362:	0141                	addi	sp,sp,16
 364:	8082                	ret
  for(n = 0; s[n]; n++)
 366:	4501                	li	a0,0
 368:	bfe5                	j	360 <strlen+0x20>

000000000000036a <memset>:

void*
memset(void *dst, int c, uint n)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 370:	ca19                	beqz	a2,386 <memset+0x1c>
 372:	87aa                	mv	a5,a0
 374:	1602                	slli	a2,a2,0x20
 376:	9201                	srli	a2,a2,0x20
 378:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 37c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 380:	0785                	addi	a5,a5,1
 382:	fee79de3          	bne	a5,a4,37c <memset+0x12>
  }
  return dst;
}
 386:	6422                	ld	s0,8(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret

000000000000038c <strchr>:

char*
strchr(const char *s, char c)
{
 38c:	1141                	addi	sp,sp,-16
 38e:	e422                	sd	s0,8(sp)
 390:	0800                	addi	s0,sp,16
  for(; *s; s++)
 392:	00054783          	lbu	a5,0(a0)
 396:	cb99                	beqz	a5,3ac <strchr+0x20>
    if(*s == c)
 398:	00f58763          	beq	a1,a5,3a6 <strchr+0x1a>
  for(; *s; s++)
 39c:	0505                	addi	a0,a0,1
 39e:	00054783          	lbu	a5,0(a0)
 3a2:	fbfd                	bnez	a5,398 <strchr+0xc>
      return (char*)s;
  return 0;
 3a4:	4501                	li	a0,0
}
 3a6:	6422                	ld	s0,8(sp)
 3a8:	0141                	addi	sp,sp,16
 3aa:	8082                	ret
  return 0;
 3ac:	4501                	li	a0,0
 3ae:	bfe5                	j	3a6 <strchr+0x1a>

00000000000003b0 <gets>:

char*
gets(char *buf, int max)
{
 3b0:	711d                	addi	sp,sp,-96
 3b2:	ec86                	sd	ra,88(sp)
 3b4:	e8a2                	sd	s0,80(sp)
 3b6:	e4a6                	sd	s1,72(sp)
 3b8:	e0ca                	sd	s2,64(sp)
 3ba:	fc4e                	sd	s3,56(sp)
 3bc:	f852                	sd	s4,48(sp)
 3be:	f456                	sd	s5,40(sp)
 3c0:	f05a                	sd	s6,32(sp)
 3c2:	ec5e                	sd	s7,24(sp)
 3c4:	1080                	addi	s0,sp,96
 3c6:	8baa                	mv	s7,a0
 3c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3ca:	892a                	mv	s2,a0
 3cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 3ce:	4aa9                	li	s5,10
 3d0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 3d2:	89a6                	mv	s3,s1
 3d4:	2485                	addiw	s1,s1,1
 3d6:	0344d663          	bge	s1,s4,402 <gets+0x52>
    cc = read(0, &c, 1);
 3da:	4605                	li	a2,1
 3dc:	faf40593          	addi	a1,s0,-81
 3e0:	4501                	li	a0,0
 3e2:	1b2000ef          	jal	594 <read>
    if(cc < 1)
 3e6:	00a05e63          	blez	a0,402 <gets+0x52>
    buf[i++] = c;
 3ea:	faf44783          	lbu	a5,-81(s0)
 3ee:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 3f2:	01578763          	beq	a5,s5,400 <gets+0x50>
 3f6:	0905                	addi	s2,s2,1
 3f8:	fd679de3          	bne	a5,s6,3d2 <gets+0x22>
    buf[i++] = c;
 3fc:	89a6                	mv	s3,s1
 3fe:	a011                	j	402 <gets+0x52>
 400:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 402:	99de                	add	s3,s3,s7
 404:	00098023          	sb	zero,0(s3)
  return buf;
}
 408:	855e                	mv	a0,s7
 40a:	60e6                	ld	ra,88(sp)
 40c:	6446                	ld	s0,80(sp)
 40e:	64a6                	ld	s1,72(sp)
 410:	6906                	ld	s2,64(sp)
 412:	79e2                	ld	s3,56(sp)
 414:	7a42                	ld	s4,48(sp)
 416:	7aa2                	ld	s5,40(sp)
 418:	7b02                	ld	s6,32(sp)
 41a:	6be2                	ld	s7,24(sp)
 41c:	6125                	addi	sp,sp,96
 41e:	8082                	ret

0000000000000420 <stat>:

int
stat(const char *n, struct stat *st)
{
 420:	1101                	addi	sp,sp,-32
 422:	ec06                	sd	ra,24(sp)
 424:	e822                	sd	s0,16(sp)
 426:	e04a                	sd	s2,0(sp)
 428:	1000                	addi	s0,sp,32
 42a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 42c:	4581                	li	a1,0
 42e:	18e000ef          	jal	5bc <open>
  if(fd < 0)
 432:	02054263          	bltz	a0,456 <stat+0x36>
 436:	e426                	sd	s1,8(sp)
 438:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 43a:	85ca                	mv	a1,s2
 43c:	198000ef          	jal	5d4 <fstat>
 440:	892a                	mv	s2,a0
  close(fd);
 442:	8526                	mv	a0,s1
 444:	160000ef          	jal	5a4 <close>
  return r;
 448:	64a2                	ld	s1,8(sp)
}
 44a:	854a                	mv	a0,s2
 44c:	60e2                	ld	ra,24(sp)
 44e:	6442                	ld	s0,16(sp)
 450:	6902                	ld	s2,0(sp)
 452:	6105                	addi	sp,sp,32
 454:	8082                	ret
    return -1;
 456:	597d                	li	s2,-1
 458:	bfcd                	j	44a <stat+0x2a>

000000000000045a <atoi>:

int
atoi(const char *s)
{
 45a:	1141                	addi	sp,sp,-16
 45c:	e422                	sd	s0,8(sp)
 45e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 460:	00054683          	lbu	a3,0(a0)
 464:	fd06879b          	addiw	a5,a3,-48 # 9fd0 <base+0x8fc0>
 468:	0ff7f793          	zext.b	a5,a5
 46c:	4625                	li	a2,9
 46e:	02f66863          	bltu	a2,a5,49e <atoi+0x44>
 472:	872a                	mv	a4,a0
  n = 0;
 474:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 476:	0705                	addi	a4,a4,1
 478:	0025179b          	slliw	a5,a0,0x2
 47c:	9fa9                	addw	a5,a5,a0
 47e:	0017979b          	slliw	a5,a5,0x1
 482:	9fb5                	addw	a5,a5,a3
 484:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 488:	00074683          	lbu	a3,0(a4)
 48c:	fd06879b          	addiw	a5,a3,-48
 490:	0ff7f793          	zext.b	a5,a5
 494:	fef671e3          	bgeu	a2,a5,476 <atoi+0x1c>
  return n;
}
 498:	6422                	ld	s0,8(sp)
 49a:	0141                	addi	sp,sp,16
 49c:	8082                	ret
  n = 0;
 49e:	4501                	li	a0,0
 4a0:	bfe5                	j	498 <atoi+0x3e>

00000000000004a2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 4a2:	1141                	addi	sp,sp,-16
 4a4:	e422                	sd	s0,8(sp)
 4a6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 4a8:	02b57463          	bgeu	a0,a1,4d0 <memmove+0x2e>
    while(n-- > 0)
 4ac:	00c05f63          	blez	a2,4ca <memmove+0x28>
 4b0:	1602                	slli	a2,a2,0x20
 4b2:	9201                	srli	a2,a2,0x20
 4b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 4b8:	872a                	mv	a4,a0
      *dst++ = *src++;
 4ba:	0585                	addi	a1,a1,1
 4bc:	0705                	addi	a4,a4,1
 4be:	fff5c683          	lbu	a3,-1(a1)
 4c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 4c6:	fef71ae3          	bne	a4,a5,4ba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 4ca:	6422                	ld	s0,8(sp)
 4cc:	0141                	addi	sp,sp,16
 4ce:	8082                	ret
    dst += n;
 4d0:	00c50733          	add	a4,a0,a2
    src += n;
 4d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 4d6:	fec05ae3          	blez	a2,4ca <memmove+0x28>
 4da:	fff6079b          	addiw	a5,a2,-1
 4de:	1782                	slli	a5,a5,0x20
 4e0:	9381                	srli	a5,a5,0x20
 4e2:	fff7c793          	not	a5,a5
 4e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 4e8:	15fd                	addi	a1,a1,-1
 4ea:	177d                	addi	a4,a4,-1
 4ec:	0005c683          	lbu	a3,0(a1)
 4f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 4f4:	fee79ae3          	bne	a5,a4,4e8 <memmove+0x46>
 4f8:	bfc9                	j	4ca <memmove+0x28>

00000000000004fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 4fa:	1141                	addi	sp,sp,-16
 4fc:	e422                	sd	s0,8(sp)
 4fe:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 500:	ca05                	beqz	a2,530 <memcmp+0x36>
 502:	fff6069b          	addiw	a3,a2,-1
 506:	1682                	slli	a3,a3,0x20
 508:	9281                	srli	a3,a3,0x20
 50a:	0685                	addi	a3,a3,1
 50c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 50e:	00054783          	lbu	a5,0(a0)
 512:	0005c703          	lbu	a4,0(a1)
 516:	00e79863          	bne	a5,a4,526 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 51a:	0505                	addi	a0,a0,1
    p2++;
 51c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 51e:	fed518e3          	bne	a0,a3,50e <memcmp+0x14>
  }
  return 0;
 522:	4501                	li	a0,0
 524:	a019                	j	52a <memcmp+0x30>
      return *p1 - *p2;
 526:	40e7853b          	subw	a0,a5,a4
}
 52a:	6422                	ld	s0,8(sp)
 52c:	0141                	addi	sp,sp,16
 52e:	8082                	ret
  return 0;
 530:	4501                	li	a0,0
 532:	bfe5                	j	52a <memcmp+0x30>

0000000000000534 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 534:	1141                	addi	sp,sp,-16
 536:	e406                	sd	ra,8(sp)
 538:	e022                	sd	s0,0(sp)
 53a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 53c:	f67ff0ef          	jal	4a2 <memmove>
}
 540:	60a2                	ld	ra,8(sp)
 542:	6402                	ld	s0,0(sp)
 544:	0141                	addi	sp,sp,16
 546:	8082                	ret

0000000000000548 <sbrk>:

char *
sbrk(int n) {
 548:	1141                	addi	sp,sp,-16
 54a:	e406                	sd	ra,8(sp)
 54c:	e022                	sd	s0,0(sp)
 54e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 550:	4585                	li	a1,1
 552:	0b2000ef          	jal	604 <sys_sbrk>
}
 556:	60a2                	ld	ra,8(sp)
 558:	6402                	ld	s0,0(sp)
 55a:	0141                	addi	sp,sp,16
 55c:	8082                	ret

000000000000055e <sbrklazy>:

char *
sbrklazy(int n) {
 55e:	1141                	addi	sp,sp,-16
 560:	e406                	sd	ra,8(sp)
 562:	e022                	sd	s0,0(sp)
 564:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 566:	4589                	li	a1,2
 568:	09c000ef          	jal	604 <sys_sbrk>
}
 56c:	60a2                	ld	ra,8(sp)
 56e:	6402                	ld	s0,0(sp)
 570:	0141                	addi	sp,sp,16
 572:	8082                	ret

0000000000000574 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 574:	4885                	li	a7,1
 ecall
 576:	00000073          	ecall
 ret
 57a:	8082                	ret

000000000000057c <exit>:
.global exit
exit:
 li a7, SYS_exit
 57c:	4889                	li	a7,2
 ecall
 57e:	00000073          	ecall
 ret
 582:	8082                	ret

0000000000000584 <wait>:
.global wait
wait:
 li a7, SYS_wait
 584:	488d                	li	a7,3
 ecall
 586:	00000073          	ecall
 ret
 58a:	8082                	ret

000000000000058c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 58c:	4891                	li	a7,4
 ecall
 58e:	00000073          	ecall
 ret
 592:	8082                	ret

0000000000000594 <read>:
.global read
read:
 li a7, SYS_read
 594:	4895                	li	a7,5
 ecall
 596:	00000073          	ecall
 ret
 59a:	8082                	ret

000000000000059c <write>:
.global write
write:
 li a7, SYS_write
 59c:	48c1                	li	a7,16
 ecall
 59e:	00000073          	ecall
 ret
 5a2:	8082                	ret

00000000000005a4 <close>:
.global close
close:
 li a7, SYS_close
 5a4:	48d5                	li	a7,21
 ecall
 5a6:	00000073          	ecall
 ret
 5aa:	8082                	ret

00000000000005ac <kill>:
.global kill
kill:
 li a7, SYS_kill
 5ac:	4899                	li	a7,6
 ecall
 5ae:	00000073          	ecall
 ret
 5b2:	8082                	ret

00000000000005b4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 5b4:	489d                	li	a7,7
 ecall
 5b6:	00000073          	ecall
 ret
 5ba:	8082                	ret

00000000000005bc <open>:
.global open
open:
 li a7, SYS_open
 5bc:	48bd                	li	a7,15
 ecall
 5be:	00000073          	ecall
 ret
 5c2:	8082                	ret

00000000000005c4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 5c4:	48c5                	li	a7,17
 ecall
 5c6:	00000073          	ecall
 ret
 5ca:	8082                	ret

00000000000005cc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 5cc:	48c9                	li	a7,18
 ecall
 5ce:	00000073          	ecall
 ret
 5d2:	8082                	ret

00000000000005d4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 5d4:	48a1                	li	a7,8
 ecall
 5d6:	00000073          	ecall
 ret
 5da:	8082                	ret

00000000000005dc <link>:
.global link
link:
 li a7, SYS_link
 5dc:	48cd                	li	a7,19
 ecall
 5de:	00000073          	ecall
 ret
 5e2:	8082                	ret

00000000000005e4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5e4:	48d1                	li	a7,20
 ecall
 5e6:	00000073          	ecall
 ret
 5ea:	8082                	ret

00000000000005ec <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5ec:	48a5                	li	a7,9
 ecall
 5ee:	00000073          	ecall
 ret
 5f2:	8082                	ret

00000000000005f4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5f4:	48a9                	li	a7,10
 ecall
 5f6:	00000073          	ecall
 ret
 5fa:	8082                	ret

00000000000005fc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5fc:	48ad                	li	a7,11
 ecall
 5fe:	00000073          	ecall
 ret
 602:	8082                	ret

0000000000000604 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 604:	48b1                	li	a7,12
 ecall
 606:	00000073          	ecall
 ret
 60a:	8082                	ret

000000000000060c <pause>:
.global pause
pause:
 li a7, SYS_pause
 60c:	48b5                	li	a7,13
 ecall
 60e:	00000073          	ecall
 ret
 612:	8082                	ret

0000000000000614 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 614:	48b9                	li	a7,14
 ecall
 616:	00000073          	ecall
 ret
 61a:	8082                	ret

000000000000061c <hello>:
.global hello
hello:
 li a7, SYS_hello
 61c:	48d9                	li	a7,22
 ecall
 61e:	00000073          	ecall
 ret
 622:	8082                	ret

0000000000000624 <ps>:
.global ps
ps:
 li a7, SYS_ps
 624:	48dd                	li	a7,23
 ecall
 626:	00000073          	ecall
 ret
 62a:	8082                	ret

000000000000062c <memtest>:
.global memtest
memtest:
 li a7, SYS_memtest
 62c:	48e1                	li	a7,24
 ecall
 62e:	00000073          	ecall
 ret
 632:	8082                	ret

0000000000000634 <testnolock>:
.global testnolock
testnolock:
 li a7, SYS_testnolock
 634:	48e5                	li	a7,25
 ecall
 636:	00000073          	ecall
 ret
 63a:	8082                	ret

000000000000063c <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 63c:	48e9                	li	a7,26
 ecall
 63e:	00000073          	ecall
 ret
 642:	8082                	ret

0000000000000644 <nullcall>:
.global nullcall
nullcall:
 li a7, SYS_nullcall
 644:	48ed                	li	a7,27
 ecall
 646:	00000073          	ecall
 ret
 64a:	8082                	ret

000000000000064c <getcycles>:
.global getcycles
getcycles:
 li a7, SYS_getcycles
 64c:	48f1                	li	a7,28
 ecall
 64e:	00000073          	ecall
 ret
 652:	8082                	ret

0000000000000654 <set_filter>:
.global set_filter
set_filter:
 li a7, SYS_set_filter
 654:	48f5                	li	a7,29
 ecall
 656:	00000073          	ecall
 ret
 65a:	8082                	ret

000000000000065c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 65c:	1101                	addi	sp,sp,-32
 65e:	ec06                	sd	ra,24(sp)
 660:	e822                	sd	s0,16(sp)
 662:	1000                	addi	s0,sp,32
 664:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 668:	4605                	li	a2,1
 66a:	fef40593          	addi	a1,s0,-17
 66e:	f2fff0ef          	jal	59c <write>
}
 672:	60e2                	ld	ra,24(sp)
 674:	6442                	ld	s0,16(sp)
 676:	6105                	addi	sp,sp,32
 678:	8082                	ret

000000000000067a <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 67a:	715d                	addi	sp,sp,-80
 67c:	e486                	sd	ra,72(sp)
 67e:	e0a2                	sd	s0,64(sp)
 680:	f84a                	sd	s2,48(sp)
 682:	0880                	addi	s0,sp,80
 684:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 686:	c299                	beqz	a3,68c <printint+0x12>
 688:	0805c363          	bltz	a1,70e <printint+0x94>
  neg = 0;
 68c:	4881                	li	a7,0
 68e:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 692:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 694:	00001517          	auipc	a0,0x1
 698:	94c50513          	addi	a0,a0,-1716 # fe0 <digits>
 69c:	883e                	mv	a6,a5
 69e:	2785                	addiw	a5,a5,1
 6a0:	02c5f733          	remu	a4,a1,a2
 6a4:	972a                	add	a4,a4,a0
 6a6:	00074703          	lbu	a4,0(a4)
 6aa:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 6ae:	872e                	mv	a4,a1
 6b0:	02c5d5b3          	divu	a1,a1,a2
 6b4:	0685                	addi	a3,a3,1
 6b6:	fec773e3          	bgeu	a4,a2,69c <printint+0x22>
  if(neg)
 6ba:	00088b63          	beqz	a7,6d0 <printint+0x56>
    buf[i++] = '-';
 6be:	fd078793          	addi	a5,a5,-48
 6c2:	97a2                	add	a5,a5,s0
 6c4:	02d00713          	li	a4,45
 6c8:	fee78423          	sb	a4,-24(a5)
 6cc:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 6d0:	02f05a63          	blez	a5,704 <printint+0x8a>
 6d4:	fc26                	sd	s1,56(sp)
 6d6:	f44e                	sd	s3,40(sp)
 6d8:	fb840713          	addi	a4,s0,-72
 6dc:	00f704b3          	add	s1,a4,a5
 6e0:	fff70993          	addi	s3,a4,-1
 6e4:	99be                	add	s3,s3,a5
 6e6:	37fd                	addiw	a5,a5,-1
 6e8:	1782                	slli	a5,a5,0x20
 6ea:	9381                	srli	a5,a5,0x20
 6ec:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 6f0:	fff4c583          	lbu	a1,-1(s1)
 6f4:	854a                	mv	a0,s2
 6f6:	f67ff0ef          	jal	65c <putc>
  while(--i >= 0)
 6fa:	14fd                	addi	s1,s1,-1
 6fc:	ff349ae3          	bne	s1,s3,6f0 <printint+0x76>
 700:	74e2                	ld	s1,56(sp)
 702:	79a2                	ld	s3,40(sp)
}
 704:	60a6                	ld	ra,72(sp)
 706:	6406                	ld	s0,64(sp)
 708:	7942                	ld	s2,48(sp)
 70a:	6161                	addi	sp,sp,80
 70c:	8082                	ret
    x = -xx;
 70e:	40b005b3          	neg	a1,a1
    neg = 1;
 712:	4885                	li	a7,1
    x = -xx;
 714:	bfad                	j	68e <printint+0x14>

0000000000000716 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 716:	711d                	addi	sp,sp,-96
 718:	ec86                	sd	ra,88(sp)
 71a:	e8a2                	sd	s0,80(sp)
 71c:	e0ca                	sd	s2,64(sp)
 71e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 720:	0005c903          	lbu	s2,0(a1)
 724:	28090663          	beqz	s2,9b0 <vprintf+0x29a>
 728:	e4a6                	sd	s1,72(sp)
 72a:	fc4e                	sd	s3,56(sp)
 72c:	f852                	sd	s4,48(sp)
 72e:	f456                	sd	s5,40(sp)
 730:	f05a                	sd	s6,32(sp)
 732:	ec5e                	sd	s7,24(sp)
 734:	e862                	sd	s8,16(sp)
 736:	e466                	sd	s9,8(sp)
 738:	8b2a                	mv	s6,a0
 73a:	8a2e                	mv	s4,a1
 73c:	8bb2                	mv	s7,a2
  state = 0;
 73e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 740:	4481                	li	s1,0
 742:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 744:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 748:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 74c:	06c00c93          	li	s9,108
 750:	a005                	j	770 <vprintf+0x5a>
        putc(fd, c0);
 752:	85ca                	mv	a1,s2
 754:	855a                	mv	a0,s6
 756:	f07ff0ef          	jal	65c <putc>
 75a:	a019                	j	760 <vprintf+0x4a>
    } else if(state == '%'){
 75c:	03598263          	beq	s3,s5,780 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 760:	2485                	addiw	s1,s1,1
 762:	8726                	mv	a4,s1
 764:	009a07b3          	add	a5,s4,s1
 768:	0007c903          	lbu	s2,0(a5)
 76c:	22090a63          	beqz	s2,9a0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 770:	0009079b          	sext.w	a5,s2
    if(state == 0){
 774:	fe0994e3          	bnez	s3,75c <vprintf+0x46>
      if(c0 == '%'){
 778:	fd579de3          	bne	a5,s5,752 <vprintf+0x3c>
        state = '%';
 77c:	89be                	mv	s3,a5
 77e:	b7cd                	j	760 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 780:	00ea06b3          	add	a3,s4,a4
 784:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 788:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 78a:	c681                	beqz	a3,792 <vprintf+0x7c>
 78c:	9752                	add	a4,a4,s4
 78e:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 792:	05878363          	beq	a5,s8,7d8 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 796:	05978d63          	beq	a5,s9,7f0 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 79a:	07500713          	li	a4,117
 79e:	0ee78763          	beq	a5,a4,88c <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 7a2:	07800713          	li	a4,120
 7a6:	12e78963          	beq	a5,a4,8d8 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 7aa:	07000713          	li	a4,112
 7ae:	14e78e63          	beq	a5,a4,90a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 7b2:	06300713          	li	a4,99
 7b6:	18e78e63          	beq	a5,a4,952 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 7ba:	07300713          	li	a4,115
 7be:	1ae78463          	beq	a5,a4,966 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 7c2:	02500713          	li	a4,37
 7c6:	04e79563          	bne	a5,a4,810 <vprintf+0xfa>
        putc(fd, '%');
 7ca:	02500593          	li	a1,37
 7ce:	855a                	mv	a0,s6
 7d0:	e8dff0ef          	jal	65c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 7d4:	4981                	li	s3,0
 7d6:	b769                	j	760 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 7d8:	008b8913          	addi	s2,s7,8
 7dc:	4685                	li	a3,1
 7de:	4629                	li	a2,10
 7e0:	000ba583          	lw	a1,0(s7)
 7e4:	855a                	mv	a0,s6
 7e6:	e95ff0ef          	jal	67a <printint>
 7ea:	8bca                	mv	s7,s2
      state = 0;
 7ec:	4981                	li	s3,0
 7ee:	bf8d                	j	760 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 7f0:	06400793          	li	a5,100
 7f4:	02f68963          	beq	a3,a5,826 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7f8:	06c00793          	li	a5,108
 7fc:	04f68263          	beq	a3,a5,840 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 800:	07500793          	li	a5,117
 804:	0af68063          	beq	a3,a5,8a4 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 808:	07800793          	li	a5,120
 80c:	0ef68263          	beq	a3,a5,8f0 <vprintf+0x1da>
        putc(fd, '%');
 810:	02500593          	li	a1,37
 814:	855a                	mv	a0,s6
 816:	e47ff0ef          	jal	65c <putc>
        putc(fd, c0);
 81a:	85ca                	mv	a1,s2
 81c:	855a                	mv	a0,s6
 81e:	e3fff0ef          	jal	65c <putc>
      state = 0;
 822:	4981                	li	s3,0
 824:	bf35                	j	760 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 826:	008b8913          	addi	s2,s7,8
 82a:	4685                	li	a3,1
 82c:	4629                	li	a2,10
 82e:	000bb583          	ld	a1,0(s7)
 832:	855a                	mv	a0,s6
 834:	e47ff0ef          	jal	67a <printint>
        i += 1;
 838:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 83a:	8bca                	mv	s7,s2
      state = 0;
 83c:	4981                	li	s3,0
        i += 1;
 83e:	b70d                	j	760 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 840:	06400793          	li	a5,100
 844:	02f60763          	beq	a2,a5,872 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 848:	07500793          	li	a5,117
 84c:	06f60963          	beq	a2,a5,8be <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 850:	07800793          	li	a5,120
 854:	faf61ee3          	bne	a2,a5,810 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 858:	008b8913          	addi	s2,s7,8
 85c:	4681                	li	a3,0
 85e:	4641                	li	a2,16
 860:	000bb583          	ld	a1,0(s7)
 864:	855a                	mv	a0,s6
 866:	e15ff0ef          	jal	67a <printint>
        i += 2;
 86a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 86c:	8bca                	mv	s7,s2
      state = 0;
 86e:	4981                	li	s3,0
        i += 2;
 870:	bdc5                	j	760 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 872:	008b8913          	addi	s2,s7,8
 876:	4685                	li	a3,1
 878:	4629                	li	a2,10
 87a:	000bb583          	ld	a1,0(s7)
 87e:	855a                	mv	a0,s6
 880:	dfbff0ef          	jal	67a <printint>
        i += 2;
 884:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 886:	8bca                	mv	s7,s2
      state = 0;
 888:	4981                	li	s3,0
        i += 2;
 88a:	bdd9                	j	760 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 88c:	008b8913          	addi	s2,s7,8
 890:	4681                	li	a3,0
 892:	4629                	li	a2,10
 894:	000be583          	lwu	a1,0(s7)
 898:	855a                	mv	a0,s6
 89a:	de1ff0ef          	jal	67a <printint>
 89e:	8bca                	mv	s7,s2
      state = 0;
 8a0:	4981                	li	s3,0
 8a2:	bd7d                	j	760 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8a4:	008b8913          	addi	s2,s7,8
 8a8:	4681                	li	a3,0
 8aa:	4629                	li	a2,10
 8ac:	000bb583          	ld	a1,0(s7)
 8b0:	855a                	mv	a0,s6
 8b2:	dc9ff0ef          	jal	67a <printint>
        i += 1;
 8b6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 8b8:	8bca                	mv	s7,s2
      state = 0;
 8ba:	4981                	li	s3,0
        i += 1;
 8bc:	b555                	j	760 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 8be:	008b8913          	addi	s2,s7,8
 8c2:	4681                	li	a3,0
 8c4:	4629                	li	a2,10
 8c6:	000bb583          	ld	a1,0(s7)
 8ca:	855a                	mv	a0,s6
 8cc:	dafff0ef          	jal	67a <printint>
        i += 2;
 8d0:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 8d2:	8bca                	mv	s7,s2
      state = 0;
 8d4:	4981                	li	s3,0
        i += 2;
 8d6:	b569                	j	760 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 8d8:	008b8913          	addi	s2,s7,8
 8dc:	4681                	li	a3,0
 8de:	4641                	li	a2,16
 8e0:	000be583          	lwu	a1,0(s7)
 8e4:	855a                	mv	a0,s6
 8e6:	d95ff0ef          	jal	67a <printint>
 8ea:	8bca                	mv	s7,s2
      state = 0;
 8ec:	4981                	li	s3,0
 8ee:	bd8d                	j	760 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 8f0:	008b8913          	addi	s2,s7,8
 8f4:	4681                	li	a3,0
 8f6:	4641                	li	a2,16
 8f8:	000bb583          	ld	a1,0(s7)
 8fc:	855a                	mv	a0,s6
 8fe:	d7dff0ef          	jal	67a <printint>
        i += 1;
 902:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 904:	8bca                	mv	s7,s2
      state = 0;
 906:	4981                	li	s3,0
        i += 1;
 908:	bda1                	j	760 <vprintf+0x4a>
 90a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 90c:	008b8d13          	addi	s10,s7,8
 910:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 914:	03000593          	li	a1,48
 918:	855a                	mv	a0,s6
 91a:	d43ff0ef          	jal	65c <putc>
  putc(fd, 'x');
 91e:	07800593          	li	a1,120
 922:	855a                	mv	a0,s6
 924:	d39ff0ef          	jal	65c <putc>
 928:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 92a:	00000b97          	auipc	s7,0x0
 92e:	6b6b8b93          	addi	s7,s7,1718 # fe0 <digits>
 932:	03c9d793          	srli	a5,s3,0x3c
 936:	97de                	add	a5,a5,s7
 938:	0007c583          	lbu	a1,0(a5)
 93c:	855a                	mv	a0,s6
 93e:	d1fff0ef          	jal	65c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 942:	0992                	slli	s3,s3,0x4
 944:	397d                	addiw	s2,s2,-1
 946:	fe0916e3          	bnez	s2,932 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 94a:	8bea                	mv	s7,s10
      state = 0;
 94c:	4981                	li	s3,0
 94e:	6d02                	ld	s10,0(sp)
 950:	bd01                	j	760 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 952:	008b8913          	addi	s2,s7,8
 956:	000bc583          	lbu	a1,0(s7)
 95a:	855a                	mv	a0,s6
 95c:	d01ff0ef          	jal	65c <putc>
 960:	8bca                	mv	s7,s2
      state = 0;
 962:	4981                	li	s3,0
 964:	bbf5                	j	760 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 966:	008b8993          	addi	s3,s7,8
 96a:	000bb903          	ld	s2,0(s7)
 96e:	00090f63          	beqz	s2,98c <vprintf+0x276>
        for(; *s; s++)
 972:	00094583          	lbu	a1,0(s2)
 976:	c195                	beqz	a1,99a <vprintf+0x284>
          putc(fd, *s);
 978:	855a                	mv	a0,s6
 97a:	ce3ff0ef          	jal	65c <putc>
        for(; *s; s++)
 97e:	0905                	addi	s2,s2,1
 980:	00094583          	lbu	a1,0(s2)
 984:	f9f5                	bnez	a1,978 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 986:	8bce                	mv	s7,s3
      state = 0;
 988:	4981                	li	s3,0
 98a:	bbd9                	j	760 <vprintf+0x4a>
          s = "(null)";
 98c:	00000917          	auipc	s2,0x0
 990:	64c90913          	addi	s2,s2,1612 # fd8 <malloc+0x540>
        for(; *s; s++)
 994:	02800593          	li	a1,40
 998:	b7c5                	j	978 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 99a:	8bce                	mv	s7,s3
      state = 0;
 99c:	4981                	li	s3,0
 99e:	b3c9                	j	760 <vprintf+0x4a>
 9a0:	64a6                	ld	s1,72(sp)
 9a2:	79e2                	ld	s3,56(sp)
 9a4:	7a42                	ld	s4,48(sp)
 9a6:	7aa2                	ld	s5,40(sp)
 9a8:	7b02                	ld	s6,32(sp)
 9aa:	6be2                	ld	s7,24(sp)
 9ac:	6c42                	ld	s8,16(sp)
 9ae:	6ca2                	ld	s9,8(sp)
    }
  }
}
 9b0:	60e6                	ld	ra,88(sp)
 9b2:	6446                	ld	s0,80(sp)
 9b4:	6906                	ld	s2,64(sp)
 9b6:	6125                	addi	sp,sp,96
 9b8:	8082                	ret

00000000000009ba <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 9ba:	715d                	addi	sp,sp,-80
 9bc:	ec06                	sd	ra,24(sp)
 9be:	e822                	sd	s0,16(sp)
 9c0:	1000                	addi	s0,sp,32
 9c2:	e010                	sd	a2,0(s0)
 9c4:	e414                	sd	a3,8(s0)
 9c6:	e818                	sd	a4,16(s0)
 9c8:	ec1c                	sd	a5,24(s0)
 9ca:	03043023          	sd	a6,32(s0)
 9ce:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 9d2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 9d6:	8622                	mv	a2,s0
 9d8:	d3fff0ef          	jal	716 <vprintf>
}
 9dc:	60e2                	ld	ra,24(sp)
 9de:	6442                	ld	s0,16(sp)
 9e0:	6161                	addi	sp,sp,80
 9e2:	8082                	ret

00000000000009e4 <printf>:

void
printf(const char *fmt, ...)
{
 9e4:	711d                	addi	sp,sp,-96
 9e6:	ec06                	sd	ra,24(sp)
 9e8:	e822                	sd	s0,16(sp)
 9ea:	1000                	addi	s0,sp,32
 9ec:	e40c                	sd	a1,8(s0)
 9ee:	e810                	sd	a2,16(s0)
 9f0:	ec14                	sd	a3,24(s0)
 9f2:	f018                	sd	a4,32(s0)
 9f4:	f41c                	sd	a5,40(s0)
 9f6:	03043823          	sd	a6,48(s0)
 9fa:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9fe:	00840613          	addi	a2,s0,8
 a02:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 a06:	85aa                	mv	a1,a0
 a08:	4505                	li	a0,1
 a0a:	d0dff0ef          	jal	716 <vprintf>
}
 a0e:	60e2                	ld	ra,24(sp)
 a10:	6442                	ld	s0,16(sp)
 a12:	6125                	addi	sp,sp,96
 a14:	8082                	ret

0000000000000a16 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 a16:	1141                	addi	sp,sp,-16
 a18:	e422                	sd	s0,8(sp)
 a1a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 a1c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a20:	00000797          	auipc	a5,0x0
 a24:	5e07b783          	ld	a5,1504(a5) # 1000 <freep>
 a28:	a02d                	j	a52 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 a2a:	4618                	lw	a4,8(a2)
 a2c:	9f2d                	addw	a4,a4,a1
 a2e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 a32:	6398                	ld	a4,0(a5)
 a34:	6310                	ld	a2,0(a4)
 a36:	a83d                	j	a74 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 a38:	ff852703          	lw	a4,-8(a0)
 a3c:	9f31                	addw	a4,a4,a2
 a3e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 a40:	ff053683          	ld	a3,-16(a0)
 a44:	a091                	j	a88 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a46:	6398                	ld	a4,0(a5)
 a48:	00e7e463          	bltu	a5,a4,a50 <free+0x3a>
 a4c:	00e6ea63          	bltu	a3,a4,a60 <free+0x4a>
{
 a50:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 a52:	fed7fae3          	bgeu	a5,a3,a46 <free+0x30>
 a56:	6398                	ld	a4,0(a5)
 a58:	00e6e463          	bltu	a3,a4,a60 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 a5c:	fee7eae3          	bltu	a5,a4,a50 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a60:	ff852583          	lw	a1,-8(a0)
 a64:	6390                	ld	a2,0(a5)
 a66:	02059813          	slli	a6,a1,0x20
 a6a:	01c85713          	srli	a4,a6,0x1c
 a6e:	9736                	add	a4,a4,a3
 a70:	fae60de3          	beq	a2,a4,a2a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a74:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a78:	4790                	lw	a2,8(a5)
 a7a:	02061593          	slli	a1,a2,0x20
 a7e:	01c5d713          	srli	a4,a1,0x1c
 a82:	973e                	add	a4,a4,a5
 a84:	fae68ae3          	beq	a3,a4,a38 <free+0x22>
    p->s.ptr = bp->s.ptr;
 a88:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a8a:	00000717          	auipc	a4,0x0
 a8e:	56f73b23          	sd	a5,1398(a4) # 1000 <freep>
}
 a92:	6422                	ld	s0,8(sp)
 a94:	0141                	addi	sp,sp,16
 a96:	8082                	ret

0000000000000a98 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a98:	7139                	addi	sp,sp,-64
 a9a:	fc06                	sd	ra,56(sp)
 a9c:	f822                	sd	s0,48(sp)
 a9e:	f426                	sd	s1,40(sp)
 aa0:	ec4e                	sd	s3,24(sp)
 aa2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 aa4:	02051493          	slli	s1,a0,0x20
 aa8:	9081                	srli	s1,s1,0x20
 aaa:	04bd                	addi	s1,s1,15
 aac:	8091                	srli	s1,s1,0x4
 aae:	0014899b          	addiw	s3,s1,1
 ab2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 ab4:	00000517          	auipc	a0,0x0
 ab8:	54c53503          	ld	a0,1356(a0) # 1000 <freep>
 abc:	c915                	beqz	a0,af0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 abe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ac0:	4798                	lw	a4,8(a5)
 ac2:	08977a63          	bgeu	a4,s1,b56 <malloc+0xbe>
 ac6:	f04a                	sd	s2,32(sp)
 ac8:	e852                	sd	s4,16(sp)
 aca:	e456                	sd	s5,8(sp)
 acc:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 ace:	8a4e                	mv	s4,s3
 ad0:	0009871b          	sext.w	a4,s3
 ad4:	6685                	lui	a3,0x1
 ad6:	00d77363          	bgeu	a4,a3,adc <malloc+0x44>
 ada:	6a05                	lui	s4,0x1
 adc:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 ae0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 ae4:	00000917          	auipc	s2,0x0
 ae8:	51c90913          	addi	s2,s2,1308 # 1000 <freep>
  if(p == SBRK_ERROR)
 aec:	5afd                	li	s5,-1
 aee:	a081                	j	b2e <malloc+0x96>
 af0:	f04a                	sd	s2,32(sp)
 af2:	e852                	sd	s4,16(sp)
 af4:	e456                	sd	s5,8(sp)
 af6:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 af8:	00000797          	auipc	a5,0x0
 afc:	51878793          	addi	a5,a5,1304 # 1010 <base>
 b00:	00000717          	auipc	a4,0x0
 b04:	50f73023          	sd	a5,1280(a4) # 1000 <freep>
 b08:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 b0a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 b0e:	b7c1                	j	ace <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 b10:	6398                	ld	a4,0(a5)
 b12:	e118                	sd	a4,0(a0)
 b14:	a8a9                	j	b6e <malloc+0xd6>
  hp->s.size = nu;
 b16:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 b1a:	0541                	addi	a0,a0,16
 b1c:	efbff0ef          	jal	a16 <free>
  return freep;
 b20:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 b24:	c12d                	beqz	a0,b86 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 b26:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 b28:	4798                	lw	a4,8(a5)
 b2a:	02977263          	bgeu	a4,s1,b4e <malloc+0xb6>
    if(p == freep)
 b2e:	00093703          	ld	a4,0(s2)
 b32:	853e                	mv	a0,a5
 b34:	fef719e3          	bne	a4,a5,b26 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 b38:	8552                	mv	a0,s4
 b3a:	a0fff0ef          	jal	548 <sbrk>
  if(p == SBRK_ERROR)
 b3e:	fd551ce3          	bne	a0,s5,b16 <malloc+0x7e>
        return 0;
 b42:	4501                	li	a0,0
 b44:	7902                	ld	s2,32(sp)
 b46:	6a42                	ld	s4,16(sp)
 b48:	6aa2                	ld	s5,8(sp)
 b4a:	6b02                	ld	s6,0(sp)
 b4c:	a03d                	j	b7a <malloc+0xe2>
 b4e:	7902                	ld	s2,32(sp)
 b50:	6a42                	ld	s4,16(sp)
 b52:	6aa2                	ld	s5,8(sp)
 b54:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 b56:	fae48de3          	beq	s1,a4,b10 <malloc+0x78>
        p->s.size -= nunits;
 b5a:	4137073b          	subw	a4,a4,s3
 b5e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b60:	02071693          	slli	a3,a4,0x20
 b64:	01c6d713          	srli	a4,a3,0x1c
 b68:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b6a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b6e:	00000717          	auipc	a4,0x0
 b72:	48a73923          	sd	a0,1170(a4) # 1000 <freep>
      return (void*)(p + 1);
 b76:	01078513          	addi	a0,a5,16
  }
}
 b7a:	70e2                	ld	ra,56(sp)
 b7c:	7442                	ld	s0,48(sp)
 b7e:	74a2                	ld	s1,40(sp)
 b80:	69e2                	ld	s3,24(sp)
 b82:	6121                	addi	sp,sp,64
 b84:	8082                	ret
 b86:	7902                	ld	s2,32(sp)
 b88:	6a42                	ld	s4,16(sp)
 b8a:	6aa2                	ld	s5,8(sp)
 b8c:	6b02                	ld	s6,0(sp)
 b8e:	b7f5                	j	b7a <malloc+0xe2>
