
user/_stack_guard:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

#define PAGE_SIZE 4096

int main() {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
    printf("=== xv6 Stack Overflow & Guard Page Simulation ===\n");
   a:	00001517          	auipc	a0,0x1
   e:	98650513          	addi	a0,a0,-1658 # 990 <malloc+0xfa>
  12:	7d0000ef          	jal	7e2 <printf>

    // Lấy đỉnh của Stack hiện tại (chính là kích thước hiện tại của tiến trình)
    // sbrk(0) trả về địa chỉ kết thúc vùng nhớ hiện tại của User Space
    char *stack_top = (char *)sbrk(0);
  16:	4501                	li	a0,0
  18:	32e000ef          	jal	346 <sbrk>
  1c:	84aa                	mv	s1,a0
    
    // Tính toán vị trí theo kiến trúc phân bổ của xv6
    char *stack_bottom = stack_top - PAGE_SIZE;
    char *guard_page = stack_bottom - PAGE_SIZE;

    printf("STACK_TOP    : 0x%p\n", stack_top);
  1e:	85aa                	mv	a1,a0
  20:	00001517          	auipc	a0,0x1
  24:	9a850513          	addi	a0,a0,-1624 # 9c8 <malloc+0x132>
  28:	7ba000ef          	jal	7e2 <printf>
    printf("STACK_BOTTOM : 0x%p\n", stack_bottom);
  2c:	75fd                	lui	a1,0xfffff
  2e:	95a6                	add	a1,a1,s1
  30:	00001517          	auipc	a0,0x1
  34:	9b050513          	addi	a0,a0,-1616 # 9e0 <malloc+0x14a>
  38:	7aa000ef          	jal	7e2 <printf>
    printf("GUARD_PAGE   : 0x%p (Protected by Kernel)\n", guard_page);
  3c:	75f9                	lui	a1,0xffffe
  3e:	95a6                	add	a1,a1,s1
  40:	00001517          	auipc	a0,0x1
  44:	9b850513          	addi	a0,a0,-1608 # 9f8 <malloc+0x162>
  48:	79a000ef          	jal	7e2 <printf>

    // =========================================================
    // TEST 1: Ghi dữ liệu hợp lệ vào vùng Stack
    // =========================================================
    printf("\n[TEST 1] Writing into valid Stack memory...\n");
  4c:	00001517          	auipc	a0,0x1
  50:	9dc50513          	addi	a0,a0,-1572 # a28 <malloc+0x192>
  54:	78e000ef          	jal	7e2 <printf>
    
    // Ghi vào một địa chỉ nằm bên trong trang Stack (cách đỉnh 512 bytes)
    char *valid_addr = stack_top - 512;
    *valid_addr = 'A';
  58:	04100793          	li	a5,65
  5c:	e0f48023          	sb	a5,-512(s1)
    
    printf("[+] OK! Successfully wrote '%c' at 0x%p\n", *valid_addr, valid_addr);
  60:	e0048613          	addi	a2,s1,-512
  64:	04100593          	li	a1,65
  68:	00001517          	auipc	a0,0x1
  6c:	9f050513          	addi	a0,a0,-1552 # a58 <malloc+0x1c2>
  70:	772000ef          	jal	7e2 <printf>

    // =========================================================
    // TEST 2: Gây ra hiện tượng Stack Overflow chạm vào Guard Page
    // =========================================================
    printf("\n[TEST 2] Triggering Stack Overflow (Accessing Guard Page)...\n");
  74:	00001517          	auipc	a0,0x1
  78:	a1450513          	addi	a0,a0,-1516 # a88 <malloc+0x1f2>
  7c:	766000ef          	jal	7e2 <printf>
    
    int pid = fork();
  80:	2f2000ef          	jal	372 <fork>
    if(pid < 0) {
  84:	02054b63          	bltz	a0,ba <main+0xba>
        printf("Fork failed!\n");
        exit(1);
    }

    if(pid == 0) {
  88:	e131                	bnez	a0,cc <main+0xcc>
        // Tiến trình con cố tình ghi đè vượt biên xuống vùng Guard Page
        // Thử ghi vào byte cuối cùng thuộc Guard Page
        char *overflow_addr = guard_page + PAGE_SIZE - 1; 
  8a:	75fd                	lui	a1,0xfffff
  8c:	15fd                	addi	a1,a1,-1 # ffffffffffffefff <base+0xffffffffffffdfef>
        
        printf("Child attempting to write at Guard Page address: 0x%p\n", overflow_addr);
  8e:	95a6                	add	a1,a1,s1
  90:	00001517          	auipc	a0,0x1
  94:	a4850513          	addi	a0,a0,-1464 # ad8 <malloc+0x242>
  98:	74a000ef          	jal	7e2 <printf>
        
        *overflow_addr = 'X'; // <-- Dòng này sẽ kích hoạt Page Fault (Trap 15)
  9c:	77fd                	lui	a5,0xfffff
  9e:	94be                	add	s1,s1,a5
  a0:	05800793          	li	a5,88
  a4:	fef48fa3          	sb	a5,-1(s1)
        
        // Nếu chạy được đến đây tức là Guard Page thất bại
        printf("[FAIL] Guard Page did not block access! ❌\n");
  a8:	00001517          	auipc	a0,0x1
  ac:	a6850513          	addi	a0,a0,-1432 # b10 <malloc+0x27a>
  b0:	732000ef          	jal	7e2 <printf>
        exit(0);
  b4:	4501                	li	a0,0
  b6:	2c4000ef          	jal	37a <exit>
        printf("Fork failed!\n");
  ba:	00001517          	auipc	a0,0x1
  be:	a0e50513          	addi	a0,a0,-1522 # ac8 <malloc+0x232>
  c2:	720000ef          	jal	7e2 <printf>
        exit(1);
  c6:	4505                	li	a0,1
  c8:	2b2000ef          	jal	37a <exit>
    } else {
        int status;
        wait(&status);
  cc:	fdc40513          	addi	a0,s0,-36
  d0:	2b2000ef          	jal	382 <wait>
        
        // Tiến trình con bị sập và bị kernel kill, tiến trình cha nhận biết và thông báo thành công
        printf("[OK] Stack Overflow detected! Process terminated by Kernel Guard Page. ✅\n");
  d4:	00001517          	auipc	a0,0x1
  d8:	a6c50513          	addi	a0,a0,-1428 # b40 <malloc+0x2aa>
  dc:	706000ef          	jal	7e2 <printf>
    }

    exit(0);
  e0:	4501                	li	a0,0
  e2:	298000ef          	jal	37a <exit>

00000000000000e6 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  ee:	f13ff0ef          	jal	0 <main>
  exit(r);
  f2:	288000ef          	jal	37a <exit>

00000000000000f6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f6:	1141                	addi	sp,sp,-16
  f8:	e422                	sd	s0,8(sp)
  fa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fc:	87aa                	mv	a5,a0
  fe:	0585                	addi	a1,a1,1
 100:	0785                	addi	a5,a5,1 # fffffffffffff001 <base+0xffffffffffffdff1>
 102:	fff5c703          	lbu	a4,-1(a1)
 106:	fee78fa3          	sb	a4,-1(a5)
 10a:	fb75                	bnez	a4,fe <strcpy+0x8>
    ;
  return os;
}
 10c:	6422                	ld	s0,8(sp)
 10e:	0141                	addi	sp,sp,16
 110:	8082                	ret

0000000000000112 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 112:	1141                	addi	sp,sp,-16
 114:	e422                	sd	s0,8(sp)
 116:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 118:	00054783          	lbu	a5,0(a0)
 11c:	cb91                	beqz	a5,130 <strcmp+0x1e>
 11e:	0005c703          	lbu	a4,0(a1)
 122:	00f71763          	bne	a4,a5,130 <strcmp+0x1e>
    p++, q++;
 126:	0505                	addi	a0,a0,1
 128:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 12a:	00054783          	lbu	a5,0(a0)
 12e:	fbe5                	bnez	a5,11e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 130:	0005c503          	lbu	a0,0(a1)
}
 134:	40a7853b          	subw	a0,a5,a0
 138:	6422                	ld	s0,8(sp)
 13a:	0141                	addi	sp,sp,16
 13c:	8082                	ret

000000000000013e <strlen>:

uint
strlen(const char *s)
{
 13e:	1141                	addi	sp,sp,-16
 140:	e422                	sd	s0,8(sp)
 142:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 144:	00054783          	lbu	a5,0(a0)
 148:	cf91                	beqz	a5,164 <strlen+0x26>
 14a:	0505                	addi	a0,a0,1
 14c:	87aa                	mv	a5,a0
 14e:	86be                	mv	a3,a5
 150:	0785                	addi	a5,a5,1
 152:	fff7c703          	lbu	a4,-1(a5)
 156:	ff65                	bnez	a4,14e <strlen+0x10>
 158:	40a6853b          	subw	a0,a3,a0
 15c:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 15e:	6422                	ld	s0,8(sp)
 160:	0141                	addi	sp,sp,16
 162:	8082                	ret
  for(n = 0; s[n]; n++)
 164:	4501                	li	a0,0
 166:	bfe5                	j	15e <strlen+0x20>

0000000000000168 <memset>:

void*
memset(void *dst, int c, uint n)
{
 168:	1141                	addi	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 16e:	ca19                	beqz	a2,184 <memset+0x1c>
 170:	87aa                	mv	a5,a0
 172:	1602                	slli	a2,a2,0x20
 174:	9201                	srli	a2,a2,0x20
 176:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 17a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 17e:	0785                	addi	a5,a5,1
 180:	fee79de3          	bne	a5,a4,17a <memset+0x12>
  }
  return dst;
}
 184:	6422                	ld	s0,8(sp)
 186:	0141                	addi	sp,sp,16
 188:	8082                	ret

000000000000018a <strchr>:

char*
strchr(const char *s, char c)
{
 18a:	1141                	addi	sp,sp,-16
 18c:	e422                	sd	s0,8(sp)
 18e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 190:	00054783          	lbu	a5,0(a0)
 194:	cb99                	beqz	a5,1aa <strchr+0x20>
    if(*s == c)
 196:	00f58763          	beq	a1,a5,1a4 <strchr+0x1a>
  for(; *s; s++)
 19a:	0505                	addi	a0,a0,1
 19c:	00054783          	lbu	a5,0(a0)
 1a0:	fbfd                	bnez	a5,196 <strchr+0xc>
      return (char*)s;
  return 0;
 1a2:	4501                	li	a0,0
}
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret
  return 0;
 1aa:	4501                	li	a0,0
 1ac:	bfe5                	j	1a4 <strchr+0x1a>

00000000000001ae <gets>:

char*
gets(char *buf, int max)
{
 1ae:	711d                	addi	sp,sp,-96
 1b0:	ec86                	sd	ra,88(sp)
 1b2:	e8a2                	sd	s0,80(sp)
 1b4:	e4a6                	sd	s1,72(sp)
 1b6:	e0ca                	sd	s2,64(sp)
 1b8:	fc4e                	sd	s3,56(sp)
 1ba:	f852                	sd	s4,48(sp)
 1bc:	f456                	sd	s5,40(sp)
 1be:	f05a                	sd	s6,32(sp)
 1c0:	ec5e                	sd	s7,24(sp)
 1c2:	1080                	addi	s0,sp,96
 1c4:	8baa                	mv	s7,a0
 1c6:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c8:	892a                	mv	s2,a0
 1ca:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1cc:	4aa9                	li	s5,10
 1ce:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1d0:	89a6                	mv	s3,s1
 1d2:	2485                	addiw	s1,s1,1
 1d4:	0344d663          	bge	s1,s4,200 <gets+0x52>
    cc = read(0, &c, 1);
 1d8:	4605                	li	a2,1
 1da:	faf40593          	addi	a1,s0,-81
 1de:	4501                	li	a0,0
 1e0:	1b2000ef          	jal	392 <read>
    if(cc < 1)
 1e4:	00a05e63          	blez	a0,200 <gets+0x52>
    buf[i++] = c;
 1e8:	faf44783          	lbu	a5,-81(s0)
 1ec:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1f0:	01578763          	beq	a5,s5,1fe <gets+0x50>
 1f4:	0905                	addi	s2,s2,1
 1f6:	fd679de3          	bne	a5,s6,1d0 <gets+0x22>
    buf[i++] = c;
 1fa:	89a6                	mv	s3,s1
 1fc:	a011                	j	200 <gets+0x52>
 1fe:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 200:	99de                	add	s3,s3,s7
 202:	00098023          	sb	zero,0(s3)
  return buf;
}
 206:	855e                	mv	a0,s7
 208:	60e6                	ld	ra,88(sp)
 20a:	6446                	ld	s0,80(sp)
 20c:	64a6                	ld	s1,72(sp)
 20e:	6906                	ld	s2,64(sp)
 210:	79e2                	ld	s3,56(sp)
 212:	7a42                	ld	s4,48(sp)
 214:	7aa2                	ld	s5,40(sp)
 216:	7b02                	ld	s6,32(sp)
 218:	6be2                	ld	s7,24(sp)
 21a:	6125                	addi	sp,sp,96
 21c:	8082                	ret

000000000000021e <stat>:

int
stat(const char *n, struct stat *st)
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	e04a                	sd	s2,0(sp)
 226:	1000                	addi	s0,sp,32
 228:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 22a:	4581                	li	a1,0
 22c:	18e000ef          	jal	3ba <open>
  if(fd < 0)
 230:	02054263          	bltz	a0,254 <stat+0x36>
 234:	e426                	sd	s1,8(sp)
 236:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 238:	85ca                	mv	a1,s2
 23a:	198000ef          	jal	3d2 <fstat>
 23e:	892a                	mv	s2,a0
  close(fd);
 240:	8526                	mv	a0,s1
 242:	160000ef          	jal	3a2 <close>
  return r;
 246:	64a2                	ld	s1,8(sp)
}
 248:	854a                	mv	a0,s2
 24a:	60e2                	ld	ra,24(sp)
 24c:	6442                	ld	s0,16(sp)
 24e:	6902                	ld	s2,0(sp)
 250:	6105                	addi	sp,sp,32
 252:	8082                	ret
    return -1;
 254:	597d                	li	s2,-1
 256:	bfcd                	j	248 <stat+0x2a>

0000000000000258 <atoi>:

int
atoi(const char *s)
{
 258:	1141                	addi	sp,sp,-16
 25a:	e422                	sd	s0,8(sp)
 25c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25e:	00054683          	lbu	a3,0(a0)
 262:	fd06879b          	addiw	a5,a3,-48
 266:	0ff7f793          	zext.b	a5,a5
 26a:	4625                	li	a2,9
 26c:	02f66863          	bltu	a2,a5,29c <atoi+0x44>
 270:	872a                	mv	a4,a0
  n = 0;
 272:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 274:	0705                	addi	a4,a4,1
 276:	0025179b          	slliw	a5,a0,0x2
 27a:	9fa9                	addw	a5,a5,a0
 27c:	0017979b          	slliw	a5,a5,0x1
 280:	9fb5                	addw	a5,a5,a3
 282:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 286:	00074683          	lbu	a3,0(a4)
 28a:	fd06879b          	addiw	a5,a3,-48
 28e:	0ff7f793          	zext.b	a5,a5
 292:	fef671e3          	bgeu	a2,a5,274 <atoi+0x1c>
  return n;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  n = 0;
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <atoi+0x3e>

00000000000002a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a6:	02b57463          	bgeu	a0,a1,2ce <memmove+0x2e>
    while(n-- > 0)
 2aa:	00c05f63          	blez	a2,2c8 <memmove+0x28>
 2ae:	1602                	slli	a2,a2,0x20
 2b0:	9201                	srli	a2,a2,0x20
 2b2:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b6:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b8:	0585                	addi	a1,a1,1
 2ba:	0705                	addi	a4,a4,1
 2bc:	fff5c683          	lbu	a3,-1(a1)
 2c0:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c4:	fef71ae3          	bne	a4,a5,2b8 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
    dst += n;
 2ce:	00c50733          	add	a4,a0,a2
    src += n;
 2d2:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d4:	fec05ae3          	blez	a2,2c8 <memmove+0x28>
 2d8:	fff6079b          	addiw	a5,a2,-1
 2dc:	1782                	slli	a5,a5,0x20
 2de:	9381                	srli	a5,a5,0x20
 2e0:	fff7c793          	not	a5,a5
 2e4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e6:	15fd                	addi	a1,a1,-1
 2e8:	177d                	addi	a4,a4,-1
 2ea:	0005c683          	lbu	a3,0(a1)
 2ee:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f2:	fee79ae3          	bne	a5,a4,2e6 <memmove+0x46>
 2f6:	bfc9                	j	2c8 <memmove+0x28>

00000000000002f8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f8:	1141                	addi	sp,sp,-16
 2fa:	e422                	sd	s0,8(sp)
 2fc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2fe:	ca05                	beqz	a2,32e <memcmp+0x36>
 300:	fff6069b          	addiw	a3,a2,-1
 304:	1682                	slli	a3,a3,0x20
 306:	9281                	srli	a3,a3,0x20
 308:	0685                	addi	a3,a3,1
 30a:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30c:	00054783          	lbu	a5,0(a0)
 310:	0005c703          	lbu	a4,0(a1)
 314:	00e79863          	bne	a5,a4,324 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 318:	0505                	addi	a0,a0,1
    p2++;
 31a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 31c:	fed518e3          	bne	a0,a3,30c <memcmp+0x14>
  }
  return 0;
 320:	4501                	li	a0,0
 322:	a019                	j	328 <memcmp+0x30>
      return *p1 - *p2;
 324:	40e7853b          	subw	a0,a5,a4
}
 328:	6422                	ld	s0,8(sp)
 32a:	0141                	addi	sp,sp,16
 32c:	8082                	ret
  return 0;
 32e:	4501                	li	a0,0
 330:	bfe5                	j	328 <memcmp+0x30>

0000000000000332 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 332:	1141                	addi	sp,sp,-16
 334:	e406                	sd	ra,8(sp)
 336:	e022                	sd	s0,0(sp)
 338:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 33a:	f67ff0ef          	jal	2a0 <memmove>
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret

0000000000000346 <sbrk>:

char *
sbrk(int n) {
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 34e:	4585                	li	a1,1
 350:	0b2000ef          	jal	402 <sys_sbrk>
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <sbrklazy>:

char *
sbrklazy(int n) {
 35c:	1141                	addi	sp,sp,-16
 35e:	e406                	sd	ra,8(sp)
 360:	e022                	sd	s0,0(sp)
 362:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 364:	4589                	li	a1,2
 366:	09c000ef          	jal	402 <sys_sbrk>
}
 36a:	60a2                	ld	ra,8(sp)
 36c:	6402                	ld	s0,0(sp)
 36e:	0141                	addi	sp,sp,16
 370:	8082                	ret

0000000000000372 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 372:	4885                	li	a7,1
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <exit>:
.global exit
exit:
 li a7, SYS_exit
 37a:	4889                	li	a7,2
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <wait>:
.global wait
wait:
 li a7, SYS_wait
 382:	488d                	li	a7,3
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 38a:	4891                	li	a7,4
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <read>:
.global read
read:
 li a7, SYS_read
 392:	4895                	li	a7,5
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <write>:
.global write
write:
 li a7, SYS_write
 39a:	48c1                	li	a7,16
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <close>:
.global close
close:
 li a7, SYS_close
 3a2:	48d5                	li	a7,21
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <kill>:
.global kill
kill:
 li a7, SYS_kill
 3aa:	4899                	li	a7,6
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3b2:	489d                	li	a7,7
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <open>:
.global open
open:
 li a7, SYS_open
 3ba:	48bd                	li	a7,15
 ecall
 3bc:	00000073          	ecall
 ret
 3c0:	8082                	ret

00000000000003c2 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3c2:	48c5                	li	a7,17
 ecall
 3c4:	00000073          	ecall
 ret
 3c8:	8082                	ret

00000000000003ca <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ca:	48c9                	li	a7,18
 ecall
 3cc:	00000073          	ecall
 ret
 3d0:	8082                	ret

00000000000003d2 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3d2:	48a1                	li	a7,8
 ecall
 3d4:	00000073          	ecall
 ret
 3d8:	8082                	ret

00000000000003da <link>:
.global link
link:
 li a7, SYS_link
 3da:	48cd                	li	a7,19
 ecall
 3dc:	00000073          	ecall
 ret
 3e0:	8082                	ret

00000000000003e2 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3e2:	48d1                	li	a7,20
 ecall
 3e4:	00000073          	ecall
 ret
 3e8:	8082                	ret

00000000000003ea <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ea:	48a5                	li	a7,9
 ecall
 3ec:	00000073          	ecall
 ret
 3f0:	8082                	ret

00000000000003f2 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3f2:	48a9                	li	a7,10
 ecall
 3f4:	00000073          	ecall
 ret
 3f8:	8082                	ret

00000000000003fa <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3fa:	48ad                	li	a7,11
 ecall
 3fc:	00000073          	ecall
 ret
 400:	8082                	ret

0000000000000402 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 402:	48b1                	li	a7,12
 ecall
 404:	00000073          	ecall
 ret
 408:	8082                	ret

000000000000040a <pause>:
.global pause
pause:
 li a7, SYS_pause
 40a:	48b5                	li	a7,13
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 412:	48b9                	li	a7,14
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <hello>:
.global hello
hello:
 li a7, SYS_hello
 41a:	48d9                	li	a7,22
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <ps>:
.global ps
ps:
 li a7, SYS_ps
 422:	48dd                	li	a7,23
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <memtest>:
.global memtest
memtest:
 li a7, SYS_memtest
 42a:	48e1                	li	a7,24
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <testnolock>:
.global testnolock
testnolock:
 li a7, SYS_testnolock
 432:	48e5                	li	a7,25
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 43a:	48e9                	li	a7,26
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <nullcall>:
.global nullcall
nullcall:
 li a7, SYS_nullcall
 442:	48ed                	li	a7,27
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <getcycles>:
.global getcycles
getcycles:
 li a7, SYS_getcycles
 44a:	48f1                	li	a7,28
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <set_filter>:
.global set_filter
set_filter:
 li a7, SYS_set_filter
 452:	48f5                	li	a7,29
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 45a:	1101                	addi	sp,sp,-32
 45c:	ec06                	sd	ra,24(sp)
 45e:	e822                	sd	s0,16(sp)
 460:	1000                	addi	s0,sp,32
 462:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 466:	4605                	li	a2,1
 468:	fef40593          	addi	a1,s0,-17
 46c:	f2fff0ef          	jal	39a <write>
}
 470:	60e2                	ld	ra,24(sp)
 472:	6442                	ld	s0,16(sp)
 474:	6105                	addi	sp,sp,32
 476:	8082                	ret

0000000000000478 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 478:	715d                	addi	sp,sp,-80
 47a:	e486                	sd	ra,72(sp)
 47c:	e0a2                	sd	s0,64(sp)
 47e:	f84a                	sd	s2,48(sp)
 480:	0880                	addi	s0,sp,80
 482:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 484:	c299                	beqz	a3,48a <printint+0x12>
 486:	0805c363          	bltz	a1,50c <printint+0x94>
  neg = 0;
 48a:	4881                	li	a7,0
 48c:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 490:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 492:	00000517          	auipc	a0,0x0
 496:	70650513          	addi	a0,a0,1798 # b98 <digits>
 49a:	883e                	mv	a6,a5
 49c:	2785                	addiw	a5,a5,1
 49e:	02c5f733          	remu	a4,a1,a2
 4a2:	972a                	add	a4,a4,a0
 4a4:	00074703          	lbu	a4,0(a4)
 4a8:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ac:	872e                	mv	a4,a1
 4ae:	02c5d5b3          	divu	a1,a1,a2
 4b2:	0685                	addi	a3,a3,1
 4b4:	fec773e3          	bgeu	a4,a2,49a <printint+0x22>
  if(neg)
 4b8:	00088b63          	beqz	a7,4ce <printint+0x56>
    buf[i++] = '-';
 4bc:	fd078793          	addi	a5,a5,-48
 4c0:	97a2                	add	a5,a5,s0
 4c2:	02d00713          	li	a4,45
 4c6:	fee78423          	sb	a4,-24(a5)
 4ca:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4ce:	02f05a63          	blez	a5,502 <printint+0x8a>
 4d2:	fc26                	sd	s1,56(sp)
 4d4:	f44e                	sd	s3,40(sp)
 4d6:	fb840713          	addi	a4,s0,-72
 4da:	00f704b3          	add	s1,a4,a5
 4de:	fff70993          	addi	s3,a4,-1
 4e2:	99be                	add	s3,s3,a5
 4e4:	37fd                	addiw	a5,a5,-1
 4e6:	1782                	slli	a5,a5,0x20
 4e8:	9381                	srli	a5,a5,0x20
 4ea:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4ee:	fff4c583          	lbu	a1,-1(s1)
 4f2:	854a                	mv	a0,s2
 4f4:	f67ff0ef          	jal	45a <putc>
  while(--i >= 0)
 4f8:	14fd                	addi	s1,s1,-1
 4fa:	ff349ae3          	bne	s1,s3,4ee <printint+0x76>
 4fe:	74e2                	ld	s1,56(sp)
 500:	79a2                	ld	s3,40(sp)
}
 502:	60a6                	ld	ra,72(sp)
 504:	6406                	ld	s0,64(sp)
 506:	7942                	ld	s2,48(sp)
 508:	6161                	addi	sp,sp,80
 50a:	8082                	ret
    x = -xx;
 50c:	40b005b3          	neg	a1,a1
    neg = 1;
 510:	4885                	li	a7,1
    x = -xx;
 512:	bfad                	j	48c <printint+0x14>

0000000000000514 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 514:	711d                	addi	sp,sp,-96
 516:	ec86                	sd	ra,88(sp)
 518:	e8a2                	sd	s0,80(sp)
 51a:	e0ca                	sd	s2,64(sp)
 51c:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 51e:	0005c903          	lbu	s2,0(a1)
 522:	28090663          	beqz	s2,7ae <vprintf+0x29a>
 526:	e4a6                	sd	s1,72(sp)
 528:	fc4e                	sd	s3,56(sp)
 52a:	f852                	sd	s4,48(sp)
 52c:	f456                	sd	s5,40(sp)
 52e:	f05a                	sd	s6,32(sp)
 530:	ec5e                	sd	s7,24(sp)
 532:	e862                	sd	s8,16(sp)
 534:	e466                	sd	s9,8(sp)
 536:	8b2a                	mv	s6,a0
 538:	8a2e                	mv	s4,a1
 53a:	8bb2                	mv	s7,a2
  state = 0;
 53c:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 53e:	4481                	li	s1,0
 540:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 542:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 546:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 54a:	06c00c93          	li	s9,108
 54e:	a005                	j	56e <vprintf+0x5a>
        putc(fd, c0);
 550:	85ca                	mv	a1,s2
 552:	855a                	mv	a0,s6
 554:	f07ff0ef          	jal	45a <putc>
 558:	a019                	j	55e <vprintf+0x4a>
    } else if(state == '%'){
 55a:	03598263          	beq	s3,s5,57e <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 55e:	2485                	addiw	s1,s1,1
 560:	8726                	mv	a4,s1
 562:	009a07b3          	add	a5,s4,s1
 566:	0007c903          	lbu	s2,0(a5)
 56a:	22090a63          	beqz	s2,79e <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 56e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 572:	fe0994e3          	bnez	s3,55a <vprintf+0x46>
      if(c0 == '%'){
 576:	fd579de3          	bne	a5,s5,550 <vprintf+0x3c>
        state = '%';
 57a:	89be                	mv	s3,a5
 57c:	b7cd                	j	55e <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 57e:	00ea06b3          	add	a3,s4,a4
 582:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 586:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 588:	c681                	beqz	a3,590 <vprintf+0x7c>
 58a:	9752                	add	a4,a4,s4
 58c:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 590:	05878363          	beq	a5,s8,5d6 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 594:	05978d63          	beq	a5,s9,5ee <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 598:	07500713          	li	a4,117
 59c:	0ee78763          	beq	a5,a4,68a <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5a0:	07800713          	li	a4,120
 5a4:	12e78963          	beq	a5,a4,6d6 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5a8:	07000713          	li	a4,112
 5ac:	14e78e63          	beq	a5,a4,708 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5b0:	06300713          	li	a4,99
 5b4:	18e78e63          	beq	a5,a4,750 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5b8:	07300713          	li	a4,115
 5bc:	1ae78463          	beq	a5,a4,764 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5c0:	02500713          	li	a4,37
 5c4:	04e79563          	bne	a5,a4,60e <vprintf+0xfa>
        putc(fd, '%');
 5c8:	02500593          	li	a1,37
 5cc:	855a                	mv	a0,s6
 5ce:	e8dff0ef          	jal	45a <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5d2:	4981                	li	s3,0
 5d4:	b769                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4685                	li	a3,1
 5dc:	4629                	li	a2,10
 5de:	000ba583          	lw	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	e95ff0ef          	jal	478 <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bf8d                	j	55e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5ee:	06400793          	li	a5,100
 5f2:	02f68963          	beq	a3,a5,624 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5f6:	06c00793          	li	a5,108
 5fa:	04f68263          	beq	a3,a5,63e <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5fe:	07500793          	li	a5,117
 602:	0af68063          	beq	a3,a5,6a2 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 606:	07800793          	li	a5,120
 60a:	0ef68263          	beq	a3,a5,6ee <vprintf+0x1da>
        putc(fd, '%');
 60e:	02500593          	li	a1,37
 612:	855a                	mv	a0,s6
 614:	e47ff0ef          	jal	45a <putc>
        putc(fd, c0);
 618:	85ca                	mv	a1,s2
 61a:	855a                	mv	a0,s6
 61c:	e3fff0ef          	jal	45a <putc>
      state = 0;
 620:	4981                	li	s3,0
 622:	bf35                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 624:	008b8913          	addi	s2,s7,8
 628:	4685                	li	a3,1
 62a:	4629                	li	a2,10
 62c:	000bb583          	ld	a1,0(s7)
 630:	855a                	mv	a0,s6
 632:	e47ff0ef          	jal	478 <printint>
        i += 1;
 636:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
        i += 1;
 63c:	b70d                	j	55e <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 63e:	06400793          	li	a5,100
 642:	02f60763          	beq	a2,a5,670 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 646:	07500793          	li	a5,117
 64a:	06f60963          	beq	a2,a5,6bc <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 64e:	07800793          	li	a5,120
 652:	faf61ee3          	bne	a2,a5,60e <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 656:	008b8913          	addi	s2,s7,8
 65a:	4681                	li	a3,0
 65c:	4641                	li	a2,16
 65e:	000bb583          	ld	a1,0(s7)
 662:	855a                	mv	a0,s6
 664:	e15ff0ef          	jal	478 <printint>
        i += 2;
 668:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	8bca                	mv	s7,s2
      state = 0;
 66c:	4981                	li	s3,0
        i += 2;
 66e:	bdc5                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 670:	008b8913          	addi	s2,s7,8
 674:	4685                	li	a3,1
 676:	4629                	li	a2,10
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	dfbff0ef          	jal	478 <printint>
        i += 2;
 682:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 2;
 688:	bdd9                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4681                	li	a3,0
 690:	4629                	li	a2,10
 692:	000be583          	lwu	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	de1ff0ef          	jal	478 <printint>
 69c:	8bca                	mv	s7,s2
      state = 0;
 69e:	4981                	li	s3,0
 6a0:	bd7d                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a2:	008b8913          	addi	s2,s7,8
 6a6:	4681                	li	a3,0
 6a8:	4629                	li	a2,10
 6aa:	000bb583          	ld	a1,0(s7)
 6ae:	855a                	mv	a0,s6
 6b0:	dc9ff0ef          	jal	478 <printint>
        i += 1;
 6b4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
        i += 1;
 6ba:	b555                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4629                	li	a2,10
 6c4:	000bb583          	ld	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	dafff0ef          	jal	478 <printint>
        i += 2;
 6ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
        i += 2;
 6d4:	b569                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6d6:	008b8913          	addi	s2,s7,8
 6da:	4681                	li	a3,0
 6dc:	4641                	li	a2,16
 6de:	000be583          	lwu	a1,0(s7)
 6e2:	855a                	mv	a0,s6
 6e4:	d95ff0ef          	jal	478 <printint>
 6e8:	8bca                	mv	s7,s2
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bd8d                	j	55e <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ee:	008b8913          	addi	s2,s7,8
 6f2:	4681                	li	a3,0
 6f4:	4641                	li	a2,16
 6f6:	000bb583          	ld	a1,0(s7)
 6fa:	855a                	mv	a0,s6
 6fc:	d7dff0ef          	jal	478 <printint>
        i += 1;
 700:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 702:	8bca                	mv	s7,s2
      state = 0;
 704:	4981                	li	s3,0
        i += 1;
 706:	bda1                	j	55e <vprintf+0x4a>
 708:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 70a:	008b8d13          	addi	s10,s7,8
 70e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 712:	03000593          	li	a1,48
 716:	855a                	mv	a0,s6
 718:	d43ff0ef          	jal	45a <putc>
  putc(fd, 'x');
 71c:	07800593          	li	a1,120
 720:	855a                	mv	a0,s6
 722:	d39ff0ef          	jal	45a <putc>
 726:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 728:	00000b97          	auipc	s7,0x0
 72c:	470b8b93          	addi	s7,s7,1136 # b98 <digits>
 730:	03c9d793          	srli	a5,s3,0x3c
 734:	97de                	add	a5,a5,s7
 736:	0007c583          	lbu	a1,0(a5)
 73a:	855a                	mv	a0,s6
 73c:	d1fff0ef          	jal	45a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 740:	0992                	slli	s3,s3,0x4
 742:	397d                	addiw	s2,s2,-1
 744:	fe0916e3          	bnez	s2,730 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 748:	8bea                	mv	s7,s10
      state = 0;
 74a:	4981                	li	s3,0
 74c:	6d02                	ld	s10,0(sp)
 74e:	bd01                	j	55e <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 750:	008b8913          	addi	s2,s7,8
 754:	000bc583          	lbu	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	d01ff0ef          	jal	45a <putc>
 75e:	8bca                	mv	s7,s2
      state = 0;
 760:	4981                	li	s3,0
 762:	bbf5                	j	55e <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 764:	008b8993          	addi	s3,s7,8
 768:	000bb903          	ld	s2,0(s7)
 76c:	00090f63          	beqz	s2,78a <vprintf+0x276>
        for(; *s; s++)
 770:	00094583          	lbu	a1,0(s2)
 774:	c195                	beqz	a1,798 <vprintf+0x284>
          putc(fd, *s);
 776:	855a                	mv	a0,s6
 778:	ce3ff0ef          	jal	45a <putc>
        for(; *s; s++)
 77c:	0905                	addi	s2,s2,1
 77e:	00094583          	lbu	a1,0(s2)
 782:	f9f5                	bnez	a1,776 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 784:	8bce                	mv	s7,s3
      state = 0;
 786:	4981                	li	s3,0
 788:	bbd9                	j	55e <vprintf+0x4a>
          s = "(null)";
 78a:	00000917          	auipc	s2,0x0
 78e:	40690913          	addi	s2,s2,1030 # b90 <malloc+0x2fa>
        for(; *s; s++)
 792:	02800593          	li	a1,40
 796:	b7c5                	j	776 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 798:	8bce                	mv	s7,s3
      state = 0;
 79a:	4981                	li	s3,0
 79c:	b3c9                	j	55e <vprintf+0x4a>
 79e:	64a6                	ld	s1,72(sp)
 7a0:	79e2                	ld	s3,56(sp)
 7a2:	7a42                	ld	s4,48(sp)
 7a4:	7aa2                	ld	s5,40(sp)
 7a6:	7b02                	ld	s6,32(sp)
 7a8:	6be2                	ld	s7,24(sp)
 7aa:	6c42                	ld	s8,16(sp)
 7ac:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7ae:	60e6                	ld	ra,88(sp)
 7b0:	6446                	ld	s0,80(sp)
 7b2:	6906                	ld	s2,64(sp)
 7b4:	6125                	addi	sp,sp,96
 7b6:	8082                	ret

00000000000007b8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b8:	715d                	addi	sp,sp,-80
 7ba:	ec06                	sd	ra,24(sp)
 7bc:	e822                	sd	s0,16(sp)
 7be:	1000                	addi	s0,sp,32
 7c0:	e010                	sd	a2,0(s0)
 7c2:	e414                	sd	a3,8(s0)
 7c4:	e818                	sd	a4,16(s0)
 7c6:	ec1c                	sd	a5,24(s0)
 7c8:	03043023          	sd	a6,32(s0)
 7cc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7d0:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7d4:	8622                	mv	a2,s0
 7d6:	d3fff0ef          	jal	514 <vprintf>
}
 7da:	60e2                	ld	ra,24(sp)
 7dc:	6442                	ld	s0,16(sp)
 7de:	6161                	addi	sp,sp,80
 7e0:	8082                	ret

00000000000007e2 <printf>:

void
printf(const char *fmt, ...)
{
 7e2:	711d                	addi	sp,sp,-96
 7e4:	ec06                	sd	ra,24(sp)
 7e6:	e822                	sd	s0,16(sp)
 7e8:	1000                	addi	s0,sp,32
 7ea:	e40c                	sd	a1,8(s0)
 7ec:	e810                	sd	a2,16(s0)
 7ee:	ec14                	sd	a3,24(s0)
 7f0:	f018                	sd	a4,32(s0)
 7f2:	f41c                	sd	a5,40(s0)
 7f4:	03043823          	sd	a6,48(s0)
 7f8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7fc:	00840613          	addi	a2,s0,8
 800:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 804:	85aa                	mv	a1,a0
 806:	4505                	li	a0,1
 808:	d0dff0ef          	jal	514 <vprintf>
}
 80c:	60e2                	ld	ra,24(sp)
 80e:	6442                	ld	s0,16(sp)
 810:	6125                	addi	sp,sp,96
 812:	8082                	ret

0000000000000814 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 814:	1141                	addi	sp,sp,-16
 816:	e422                	sd	s0,8(sp)
 818:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81e:	00000797          	auipc	a5,0x0
 822:	7e27b783          	ld	a5,2018(a5) # 1000 <freep>
 826:	a02d                	j	850 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 828:	4618                	lw	a4,8(a2)
 82a:	9f2d                	addw	a4,a4,a1
 82c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	6398                	ld	a4,0(a5)
 832:	6310                	ld	a2,0(a4)
 834:	a83d                	j	872 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 836:	ff852703          	lw	a4,-8(a0)
 83a:	9f31                	addw	a4,a4,a2
 83c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 83e:	ff053683          	ld	a3,-16(a0)
 842:	a091                	j	886 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	6398                	ld	a4,0(a5)
 846:	00e7e463          	bltu	a5,a4,84e <free+0x3a>
 84a:	00e6ea63          	bltu	a3,a4,85e <free+0x4a>
{
 84e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 850:	fed7fae3          	bgeu	a5,a3,844 <free+0x30>
 854:	6398                	ld	a4,0(a5)
 856:	00e6e463          	bltu	a3,a4,85e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85a:	fee7eae3          	bltu	a5,a4,84e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 85e:	ff852583          	lw	a1,-8(a0)
 862:	6390                	ld	a2,0(a5)
 864:	02059813          	slli	a6,a1,0x20
 868:	01c85713          	srli	a4,a6,0x1c
 86c:	9736                	add	a4,a4,a3
 86e:	fae60de3          	beq	a2,a4,828 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 876:	4790                	lw	a2,8(a5)
 878:	02061593          	slli	a1,a2,0x20
 87c:	01c5d713          	srli	a4,a1,0x1c
 880:	973e                	add	a4,a4,a5
 882:	fae68ae3          	beq	a3,a4,836 <free+0x22>
    p->s.ptr = bp->s.ptr;
 886:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 888:	00000717          	auipc	a4,0x0
 88c:	76f73c23          	sd	a5,1912(a4) # 1000 <freep>
}
 890:	6422                	ld	s0,8(sp)
 892:	0141                	addi	sp,sp,16
 894:	8082                	ret

0000000000000896 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 896:	7139                	addi	sp,sp,-64
 898:	fc06                	sd	ra,56(sp)
 89a:	f822                	sd	s0,48(sp)
 89c:	f426                	sd	s1,40(sp)
 89e:	ec4e                	sd	s3,24(sp)
 8a0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8a2:	02051493          	slli	s1,a0,0x20
 8a6:	9081                	srli	s1,s1,0x20
 8a8:	04bd                	addi	s1,s1,15
 8aa:	8091                	srli	s1,s1,0x4
 8ac:	0014899b          	addiw	s3,s1,1
 8b0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8b2:	00000517          	auipc	a0,0x0
 8b6:	74e53503          	ld	a0,1870(a0) # 1000 <freep>
 8ba:	c915                	beqz	a0,8ee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8bc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8be:	4798                	lw	a4,8(a5)
 8c0:	08977a63          	bgeu	a4,s1,954 <malloc+0xbe>
 8c4:	f04a                	sd	s2,32(sp)
 8c6:	e852                	sd	s4,16(sp)
 8c8:	e456                	sd	s5,8(sp)
 8ca:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8cc:	8a4e                	mv	s4,s3
 8ce:	0009871b          	sext.w	a4,s3
 8d2:	6685                	lui	a3,0x1
 8d4:	00d77363          	bgeu	a4,a3,8da <malloc+0x44>
 8d8:	6a05                	lui	s4,0x1
 8da:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8de:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e2:	00000917          	auipc	s2,0x0
 8e6:	71e90913          	addi	s2,s2,1822 # 1000 <freep>
  if(p == SBRK_ERROR)
 8ea:	5afd                	li	s5,-1
 8ec:	a081                	j	92c <malloc+0x96>
 8ee:	f04a                	sd	s2,32(sp)
 8f0:	e852                	sd	s4,16(sp)
 8f2:	e456                	sd	s5,8(sp)
 8f4:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8f6:	00000797          	auipc	a5,0x0
 8fa:	71a78793          	addi	a5,a5,1818 # 1010 <base>
 8fe:	00000717          	auipc	a4,0x0
 902:	70f73123          	sd	a5,1794(a4) # 1000 <freep>
 906:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 908:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 90c:	b7c1                	j	8cc <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 90e:	6398                	ld	a4,0(a5)
 910:	e118                	sd	a4,0(a0)
 912:	a8a9                	j	96c <malloc+0xd6>
  hp->s.size = nu;
 914:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 918:	0541                	addi	a0,a0,16
 91a:	efbff0ef          	jal	814 <free>
  return freep;
 91e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 922:	c12d                	beqz	a0,984 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 924:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 926:	4798                	lw	a4,8(a5)
 928:	02977263          	bgeu	a4,s1,94c <malloc+0xb6>
    if(p == freep)
 92c:	00093703          	ld	a4,0(s2)
 930:	853e                	mv	a0,a5
 932:	fef719e3          	bne	a4,a5,924 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 936:	8552                	mv	a0,s4
 938:	a0fff0ef          	jal	346 <sbrk>
  if(p == SBRK_ERROR)
 93c:	fd551ce3          	bne	a0,s5,914 <malloc+0x7e>
        return 0;
 940:	4501                	li	a0,0
 942:	7902                	ld	s2,32(sp)
 944:	6a42                	ld	s4,16(sp)
 946:	6aa2                	ld	s5,8(sp)
 948:	6b02                	ld	s6,0(sp)
 94a:	a03d                	j	978 <malloc+0xe2>
 94c:	7902                	ld	s2,32(sp)
 94e:	6a42                	ld	s4,16(sp)
 950:	6aa2                	ld	s5,8(sp)
 952:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 954:	fae48de3          	beq	s1,a4,90e <malloc+0x78>
        p->s.size -= nunits;
 958:	4137073b          	subw	a4,a4,s3
 95c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 95e:	02071693          	slli	a3,a4,0x20
 962:	01c6d713          	srli	a4,a3,0x1c
 966:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 968:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 96c:	00000717          	auipc	a4,0x0
 970:	68a73a23          	sd	a0,1684(a4) # 1000 <freep>
      return (void*)(p + 1);
 974:	01078513          	addi	a0,a5,16
  }
}
 978:	70e2                	ld	ra,56(sp)
 97a:	7442                	ld	s0,48(sp)
 97c:	74a2                	ld	s1,40(sp)
 97e:	69e2                	ld	s3,24(sp)
 980:	6121                	addi	sp,sp,64
 982:	8082                	ret
 984:	7902                	ld	s2,32(sp)
 986:	6a42                	ld	s4,16(sp)
 988:	6aa2                	ld	s5,8(sp)
 98a:	6b02                	ld	s6,0(sp)
 98c:	b7f5                	j	978 <malloc+0xe2>
