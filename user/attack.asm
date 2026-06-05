
user/_attack:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_read_test>:
#include "kernel/types.h"
#include "user/user.h"

// Hàm thực hiện Test 1: Đọc bộ nhớ Kernel
void do_read_test(volatile unsigned long *addr) {
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
    printf("[TEST 1] Read kernel memory...\n");
   c:	00001517          	auipc	a0,0x1
  10:	9a450513          	addi	a0,a0,-1628 # 9b0 <malloc+0x100>
  14:	7e8000ef          	jal	7fc <printf>
    int pid = fork();
  18:	374000ef          	jal	38c <fork>
    
    if(pid < 0) {
  1c:	02054263          	bltz	a0,40 <do_read_test+0x40>
        printf("Fork failed\n");
        exit(1);
    }
    
    if(pid == 0) {
  20:	c90d                	beqz	a0,52 <do_read_test+0x52>
        printf("[FAIL] Read succeeded: 0x%p ❌\n", (void*)val);
        exit(0);
    } else {
        // Tiến trình cha chờ xem con có bị sập do Page Fault không
        int status;
        wait(&status);
  22:	fdc40513          	addi	a0,s0,-36
  26:	376000ef          	jal	39c <wait>
        printf("[OK] Read blocked (Process terminated by Kernel) ✅\n");
  2a:	00001517          	auipc	a0,0x1
  2e:	9e650513          	addi	a0,a0,-1562 # a10 <malloc+0x160>
  32:	7ca000ef          	jal	7fc <printf>
    }
}
  36:	70a2                	ld	ra,40(sp)
  38:	7402                	ld	s0,32(sp)
  3a:	64e2                	ld	s1,24(sp)
  3c:	6145                	addi	sp,sp,48
  3e:	8082                	ret
        printf("Fork failed\n");
  40:	00001517          	auipc	a0,0x1
  44:	99050513          	addi	a0,a0,-1648 # 9d0 <malloc+0x120>
  48:	7b4000ef          	jal	7fc <printf>
        exit(1);
  4c:	4505                	li	a0,1
  4e:	346000ef          	jal	394 <exit>
        unsigned long val = *addr;
  52:	608c                	ld	a1,0(s1)
        printf("[FAIL] Read succeeded: 0x%p ❌\n", (void*)val);
  54:	00001517          	auipc	a0,0x1
  58:	99450513          	addi	a0,a0,-1644 # 9e8 <malloc+0x138>
  5c:	7a0000ef          	jal	7fc <printf>
        exit(0);
  60:	4501                	li	a0,0
  62:	332000ef          	jal	394 <exit>

0000000000000066 <do_write_test>:

// Hàm thực hiện Test 2: Ghi bộ nhớ Kernel
void do_write_test(volatile unsigned long *addr) {
  66:	7179                	addi	sp,sp,-48
  68:	f406                	sd	ra,40(sp)
  6a:	f022                	sd	s0,32(sp)
  6c:	ec26                	sd	s1,24(sp)
  6e:	1800                	addi	s0,sp,48
  70:	84aa                	mv	s1,a0
    printf("\n[TEST 2] Write kernel memory...\n");
  72:	00001517          	auipc	a0,0x1
  76:	9d650513          	addi	a0,a0,-1578 # a48 <malloc+0x198>
  7a:	782000ef          	jal	7fc <printf>
    int pid = fork();
  7e:	30e000ef          	jal	38c <fork>
    
    if(pid < 0) {
  82:	02054263          	bltz	a0,a6 <do_write_test+0x40>
        printf("Fork failed\n");
        exit(1);
    }
    
    if(pid == 0) {
  86:	c90d                	beqz	a0,b8 <do_write_test+0x52>
        printf("[FAIL] Write succeeded ❌\n");
        exit(0);
    } else {
        // Tiến trình cha chờ xem con có bị sập không
        int status;
        wait(&status);
  88:	fdc40513          	addi	a0,s0,-36
  8c:	310000ef          	jal	39c <wait>
        printf("[OK] Write blocked (Process terminated by Kernel) ✅\n");
  90:	00001517          	auipc	a0,0x1
  94:	a0050513          	addi	a0,a0,-1536 # a90 <malloc+0x1e0>
  98:	764000ef          	jal	7fc <printf>
    }
}
  9c:	70a2                	ld	ra,40(sp)
  9e:	7402                	ld	s0,32(sp)
  a0:	64e2                	ld	s1,24(sp)
  a2:	6145                	addi	sp,sp,48
  a4:	8082                	ret
        printf("Fork failed\n");
  a6:	00001517          	auipc	a0,0x1
  aa:	92a50513          	addi	a0,a0,-1750 # 9d0 <malloc+0x120>
  ae:	74e000ef          	jal	7fc <printf>
        exit(1);
  b2:	4505                	li	a0,1
  b4:	2e0000ef          	jal	394 <exit>
        *addr = 0xDEADBEEF;
  b8:	37ab77b7          	lui	a5,0x37ab7
  bc:	078a                	slli	a5,a5,0x2
  be:	eef78793          	addi	a5,a5,-273 # 37ab6eef <base+0x37ab5edf>
  c2:	e09c                	sd	a5,0(s1)
        printf("[FAIL] Write succeeded ❌\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	9ac50513          	addi	a0,a0,-1620 # a70 <malloc+0x1c0>
  cc:	730000ef          	jal	7fc <printf>
        exit(0);
  d0:	4501                	li	a0,0
  d2:	2c2000ef          	jal	394 <exit>

00000000000000d6 <main>:

int main() {
  d6:	1141                	addi	sp,sp,-16
  d8:	e406                	sd	ra,8(sp)
  da:	e022                	sd	s0,0(sp)
  dc:	0800                	addi	s0,sp,16
    printf("=== User Space Attack Simulation (Fork-based) ===\n");
  de:	00001517          	auipc	a0,0x1
  e2:	9ea50513          	addi	a0,a0,-1558 # ac8 <malloc+0x218>
  e6:	716000ef          	jal	7fc <printf>
    
    // Địa chỉ Kernel Base trong xv6 RISC-V
    volatile unsigned long *kernel_addr = (unsigned long *)0x80000000;

    do_read_test(kernel_addr);
  ea:	4505                	li	a0,1
  ec:	057e                	slli	a0,a0,0x1f
  ee:	f13ff0ef          	jal	0 <do_read_test>
    do_write_test(kernel_addr);
  f2:	4505                	li	a0,1
  f4:	057e                	slli	a0,a0,0x1f
  f6:	f71ff0ef          	jal	66 <do_write_test>

    exit(0);
  fa:	4501                	li	a0,0
  fc:	298000ef          	jal	394 <exit>

0000000000000100 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 100:	1141                	addi	sp,sp,-16
 102:	e406                	sd	ra,8(sp)
 104:	e022                	sd	s0,0(sp)
 106:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 108:	fcfff0ef          	jal	d6 <main>
  exit(r);
 10c:	288000ef          	jal	394 <exit>

0000000000000110 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 116:	87aa                	mv	a5,a0
 118:	0585                	addi	a1,a1,1
 11a:	0785                	addi	a5,a5,1
 11c:	fff5c703          	lbu	a4,-1(a1)
 120:	fee78fa3          	sb	a4,-1(a5)
 124:	fb75                	bnez	a4,118 <strcpy+0x8>
    ;
  return os;
}
 126:	6422                	ld	s0,8(sp)
 128:	0141                	addi	sp,sp,16
 12a:	8082                	ret

000000000000012c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 132:	00054783          	lbu	a5,0(a0)
 136:	cb91                	beqz	a5,14a <strcmp+0x1e>
 138:	0005c703          	lbu	a4,0(a1)
 13c:	00f71763          	bne	a4,a5,14a <strcmp+0x1e>
    p++, q++;
 140:	0505                	addi	a0,a0,1
 142:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 144:	00054783          	lbu	a5,0(a0)
 148:	fbe5                	bnez	a5,138 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 14a:	0005c503          	lbu	a0,0(a1)
}
 14e:	40a7853b          	subw	a0,a5,a0
 152:	6422                	ld	s0,8(sp)
 154:	0141                	addi	sp,sp,16
 156:	8082                	ret

0000000000000158 <strlen>:

uint
strlen(const char *s)
{
 158:	1141                	addi	sp,sp,-16
 15a:	e422                	sd	s0,8(sp)
 15c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 15e:	00054783          	lbu	a5,0(a0)
 162:	cf91                	beqz	a5,17e <strlen+0x26>
 164:	0505                	addi	a0,a0,1
 166:	87aa                	mv	a5,a0
 168:	86be                	mv	a3,a5
 16a:	0785                	addi	a5,a5,1
 16c:	fff7c703          	lbu	a4,-1(a5)
 170:	ff65                	bnez	a4,168 <strlen+0x10>
 172:	40a6853b          	subw	a0,a3,a0
 176:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 178:	6422                	ld	s0,8(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret
  for(n = 0; s[n]; n++)
 17e:	4501                	li	a0,0
 180:	bfe5                	j	178 <strlen+0x20>

0000000000000182 <memset>:

void*
memset(void *dst, int c, uint n)
{
 182:	1141                	addi	sp,sp,-16
 184:	e422                	sd	s0,8(sp)
 186:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 188:	ca19                	beqz	a2,19e <memset+0x1c>
 18a:	87aa                	mv	a5,a0
 18c:	1602                	slli	a2,a2,0x20
 18e:	9201                	srli	a2,a2,0x20
 190:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 194:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 198:	0785                	addi	a5,a5,1
 19a:	fee79de3          	bne	a5,a4,194 <memset+0x12>
  }
  return dst;
}
 19e:	6422                	ld	s0,8(sp)
 1a0:	0141                	addi	sp,sp,16
 1a2:	8082                	ret

00000000000001a4 <strchr>:

char*
strchr(const char *s, char c)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1aa:	00054783          	lbu	a5,0(a0)
 1ae:	cb99                	beqz	a5,1c4 <strchr+0x20>
    if(*s == c)
 1b0:	00f58763          	beq	a1,a5,1be <strchr+0x1a>
  for(; *s; s++)
 1b4:	0505                	addi	a0,a0,1
 1b6:	00054783          	lbu	a5,0(a0)
 1ba:	fbfd                	bnez	a5,1b0 <strchr+0xc>
      return (char*)s;
  return 0;
 1bc:	4501                	li	a0,0
}
 1be:	6422                	ld	s0,8(sp)
 1c0:	0141                	addi	sp,sp,16
 1c2:	8082                	ret
  return 0;
 1c4:	4501                	li	a0,0
 1c6:	bfe5                	j	1be <strchr+0x1a>

00000000000001c8 <gets>:

char*
gets(char *buf, int max)
{
 1c8:	711d                	addi	sp,sp,-96
 1ca:	ec86                	sd	ra,88(sp)
 1cc:	e8a2                	sd	s0,80(sp)
 1ce:	e4a6                	sd	s1,72(sp)
 1d0:	e0ca                	sd	s2,64(sp)
 1d2:	fc4e                	sd	s3,56(sp)
 1d4:	f852                	sd	s4,48(sp)
 1d6:	f456                	sd	s5,40(sp)
 1d8:	f05a                	sd	s6,32(sp)
 1da:	ec5e                	sd	s7,24(sp)
 1dc:	1080                	addi	s0,sp,96
 1de:	8baa                	mv	s7,a0
 1e0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1e2:	892a                	mv	s2,a0
 1e4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1e6:	4aa9                	li	s5,10
 1e8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ea:	89a6                	mv	s3,s1
 1ec:	2485                	addiw	s1,s1,1
 1ee:	0344d663          	bge	s1,s4,21a <gets+0x52>
    cc = read(0, &c, 1);
 1f2:	4605                	li	a2,1
 1f4:	faf40593          	addi	a1,s0,-81
 1f8:	4501                	li	a0,0
 1fa:	1b2000ef          	jal	3ac <read>
    if(cc < 1)
 1fe:	00a05e63          	blez	a0,21a <gets+0x52>
    buf[i++] = c;
 202:	faf44783          	lbu	a5,-81(s0)
 206:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 20a:	01578763          	beq	a5,s5,218 <gets+0x50>
 20e:	0905                	addi	s2,s2,1
 210:	fd679de3          	bne	a5,s6,1ea <gets+0x22>
    buf[i++] = c;
 214:	89a6                	mv	s3,s1
 216:	a011                	j	21a <gets+0x52>
 218:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 21a:	99de                	add	s3,s3,s7
 21c:	00098023          	sb	zero,0(s3)
  return buf;
}
 220:	855e                	mv	a0,s7
 222:	60e6                	ld	ra,88(sp)
 224:	6446                	ld	s0,80(sp)
 226:	64a6                	ld	s1,72(sp)
 228:	6906                	ld	s2,64(sp)
 22a:	79e2                	ld	s3,56(sp)
 22c:	7a42                	ld	s4,48(sp)
 22e:	7aa2                	ld	s5,40(sp)
 230:	7b02                	ld	s6,32(sp)
 232:	6be2                	ld	s7,24(sp)
 234:	6125                	addi	sp,sp,96
 236:	8082                	ret

0000000000000238 <stat>:

int
stat(const char *n, struct stat *st)
{
 238:	1101                	addi	sp,sp,-32
 23a:	ec06                	sd	ra,24(sp)
 23c:	e822                	sd	s0,16(sp)
 23e:	e04a                	sd	s2,0(sp)
 240:	1000                	addi	s0,sp,32
 242:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 244:	4581                	li	a1,0
 246:	18e000ef          	jal	3d4 <open>
  if(fd < 0)
 24a:	02054263          	bltz	a0,26e <stat+0x36>
 24e:	e426                	sd	s1,8(sp)
 250:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 252:	85ca                	mv	a1,s2
 254:	198000ef          	jal	3ec <fstat>
 258:	892a                	mv	s2,a0
  close(fd);
 25a:	8526                	mv	a0,s1
 25c:	160000ef          	jal	3bc <close>
  return r;
 260:	64a2                	ld	s1,8(sp)
}
 262:	854a                	mv	a0,s2
 264:	60e2                	ld	ra,24(sp)
 266:	6442                	ld	s0,16(sp)
 268:	6902                	ld	s2,0(sp)
 26a:	6105                	addi	sp,sp,32
 26c:	8082                	ret
    return -1;
 26e:	597d                	li	s2,-1
 270:	bfcd                	j	262 <stat+0x2a>

0000000000000272 <atoi>:

int
atoi(const char *s)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 278:	00054683          	lbu	a3,0(a0)
 27c:	fd06879b          	addiw	a5,a3,-48
 280:	0ff7f793          	zext.b	a5,a5
 284:	4625                	li	a2,9
 286:	02f66863          	bltu	a2,a5,2b6 <atoi+0x44>
 28a:	872a                	mv	a4,a0
  n = 0;
 28c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28e:	0705                	addi	a4,a4,1
 290:	0025179b          	slliw	a5,a0,0x2
 294:	9fa9                	addw	a5,a5,a0
 296:	0017979b          	slliw	a5,a5,0x1
 29a:	9fb5                	addw	a5,a5,a3
 29c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a0:	00074683          	lbu	a3,0(a4)
 2a4:	fd06879b          	addiw	a5,a3,-48
 2a8:	0ff7f793          	zext.b	a5,a5
 2ac:	fef671e3          	bgeu	a2,a5,28e <atoi+0x1c>
  return n;
}
 2b0:	6422                	ld	s0,8(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret
  n = 0;
 2b6:	4501                	li	a0,0
 2b8:	bfe5                	j	2b0 <atoi+0x3e>

00000000000002ba <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c0:	02b57463          	bgeu	a0,a1,2e8 <memmove+0x2e>
    while(n-- > 0)
 2c4:	00c05f63          	blez	a2,2e2 <memmove+0x28>
 2c8:	1602                	slli	a2,a2,0x20
 2ca:	9201                	srli	a2,a2,0x20
 2cc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d2:	0585                	addi	a1,a1,1
 2d4:	0705                	addi	a4,a4,1
 2d6:	fff5c683          	lbu	a3,-1(a1)
 2da:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2de:	fef71ae3          	bne	a4,a5,2d2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e2:	6422                	ld	s0,8(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret
    dst += n;
 2e8:	00c50733          	add	a4,a0,a2
    src += n;
 2ec:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ee:	fec05ae3          	blez	a2,2e2 <memmove+0x28>
 2f2:	fff6079b          	addiw	a5,a2,-1
 2f6:	1782                	slli	a5,a5,0x20
 2f8:	9381                	srli	a5,a5,0x20
 2fa:	fff7c793          	not	a5,a5
 2fe:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 300:	15fd                	addi	a1,a1,-1
 302:	177d                	addi	a4,a4,-1
 304:	0005c683          	lbu	a3,0(a1)
 308:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30c:	fee79ae3          	bne	a5,a4,300 <memmove+0x46>
 310:	bfc9                	j	2e2 <memmove+0x28>

0000000000000312 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 318:	ca05                	beqz	a2,348 <memcmp+0x36>
 31a:	fff6069b          	addiw	a3,a2,-1
 31e:	1682                	slli	a3,a3,0x20
 320:	9281                	srli	a3,a3,0x20
 322:	0685                	addi	a3,a3,1
 324:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 326:	00054783          	lbu	a5,0(a0)
 32a:	0005c703          	lbu	a4,0(a1)
 32e:	00e79863          	bne	a5,a4,33e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 332:	0505                	addi	a0,a0,1
    p2++;
 334:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 336:	fed518e3          	bne	a0,a3,326 <memcmp+0x14>
  }
  return 0;
 33a:	4501                	li	a0,0
 33c:	a019                	j	342 <memcmp+0x30>
      return *p1 - *p2;
 33e:	40e7853b          	subw	a0,a5,a4
}
 342:	6422                	ld	s0,8(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
  return 0;
 348:	4501                	li	a0,0
 34a:	bfe5                	j	342 <memcmp+0x30>

000000000000034c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e406                	sd	ra,8(sp)
 350:	e022                	sd	s0,0(sp)
 352:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 354:	f67ff0ef          	jal	2ba <memmove>
}
 358:	60a2                	ld	ra,8(sp)
 35a:	6402                	ld	s0,0(sp)
 35c:	0141                	addi	sp,sp,16
 35e:	8082                	ret

0000000000000360 <sbrk>:

char *
sbrk(int n) {
 360:	1141                	addi	sp,sp,-16
 362:	e406                	sd	ra,8(sp)
 364:	e022                	sd	s0,0(sp)
 366:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 368:	4585                	li	a1,1
 36a:	0b2000ef          	jal	41c <sys_sbrk>
}
 36e:	60a2                	ld	ra,8(sp)
 370:	6402                	ld	s0,0(sp)
 372:	0141                	addi	sp,sp,16
 374:	8082                	ret

0000000000000376 <sbrklazy>:

char *
sbrklazy(int n) {
 376:	1141                	addi	sp,sp,-16
 378:	e406                	sd	ra,8(sp)
 37a:	e022                	sd	s0,0(sp)
 37c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 37e:	4589                	li	a1,2
 380:	09c000ef          	jal	41c <sys_sbrk>
}
 384:	60a2                	ld	ra,8(sp)
 386:	6402                	ld	s0,0(sp)
 388:	0141                	addi	sp,sp,16
 38a:	8082                	ret

000000000000038c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 38c:	4885                	li	a7,1
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <exit>:
.global exit
exit:
 li a7, SYS_exit
 394:	4889                	li	a7,2
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <wait>:
.global wait
wait:
 li a7, SYS_wait
 39c:	488d                	li	a7,3
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3a4:	4891                	li	a7,4
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <read>:
.global read
read:
 li a7, SYS_read
 3ac:	4895                	li	a7,5
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <write>:
.global write
write:
 li a7, SYS_write
 3b4:	48c1                	li	a7,16
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <close>:
.global close
close:
 li a7, SYS_close
 3bc:	48d5                	li	a7,21
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3c4:	4899                	li	a7,6
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <exec>:
.global exec
exec:
 li a7, SYS_exec
 3cc:	489d                	li	a7,7
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <open>:
.global open
open:
 li a7, SYS_open
 3d4:	48bd                	li	a7,15
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3dc:	48c5                	li	a7,17
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3e4:	48c9                	li	a7,18
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ec:	48a1                	li	a7,8
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <link>:
.global link
link:
 li a7, SYS_link
 3f4:	48cd                	li	a7,19
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3fc:	48d1                	li	a7,20
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 404:	48a5                	li	a7,9
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <dup>:
.global dup
dup:
 li a7, SYS_dup
 40c:	48a9                	li	a7,10
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 414:	48ad                	li	a7,11
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 41c:	48b1                	li	a7,12
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <pause>:
.global pause
pause:
 li a7, SYS_pause
 424:	48b5                	li	a7,13
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 42c:	48b9                	li	a7,14
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <hello>:
.global hello
hello:
 li a7, SYS_hello
 434:	48d9                	li	a7,22
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <ps>:
.global ps
ps:
 li a7, SYS_ps
 43c:	48dd                	li	a7,23
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <memtest>:
.global memtest
memtest:
 li a7, SYS_memtest
 444:	48e1                	li	a7,24
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <testnolock>:
.global testnolock
testnolock:
 li a7, SYS_testnolock
 44c:	48e5                	li	a7,25
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 454:	48e9                	li	a7,26
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <nullcall>:
.global nullcall
nullcall:
 li a7, SYS_nullcall
 45c:	48ed                	li	a7,27
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <getcycles>:
.global getcycles
getcycles:
 li a7, SYS_getcycles
 464:	48f1                	li	a7,28
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <set_filter>:
.global set_filter
set_filter:
 li a7, SYS_set_filter
 46c:	48f5                	li	a7,29
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 474:	1101                	addi	sp,sp,-32
 476:	ec06                	sd	ra,24(sp)
 478:	e822                	sd	s0,16(sp)
 47a:	1000                	addi	s0,sp,32
 47c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 480:	4605                	li	a2,1
 482:	fef40593          	addi	a1,s0,-17
 486:	f2fff0ef          	jal	3b4 <write>
}
 48a:	60e2                	ld	ra,24(sp)
 48c:	6442                	ld	s0,16(sp)
 48e:	6105                	addi	sp,sp,32
 490:	8082                	ret

0000000000000492 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 492:	715d                	addi	sp,sp,-80
 494:	e486                	sd	ra,72(sp)
 496:	e0a2                	sd	s0,64(sp)
 498:	f84a                	sd	s2,48(sp)
 49a:	0880                	addi	s0,sp,80
 49c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 49e:	c299                	beqz	a3,4a4 <printint+0x12>
 4a0:	0805c363          	bltz	a1,526 <printint+0x94>
  neg = 0;
 4a4:	4881                	li	a7,0
 4a6:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4aa:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4ac:	00000517          	auipc	a0,0x0
 4b0:	65c50513          	addi	a0,a0,1628 # b08 <digits>
 4b4:	883e                	mv	a6,a5
 4b6:	2785                	addiw	a5,a5,1
 4b8:	02c5f733          	remu	a4,a1,a2
 4bc:	972a                	add	a4,a4,a0
 4be:	00074703          	lbu	a4,0(a4)
 4c2:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4c6:	872e                	mv	a4,a1
 4c8:	02c5d5b3          	divu	a1,a1,a2
 4cc:	0685                	addi	a3,a3,1
 4ce:	fec773e3          	bgeu	a4,a2,4b4 <printint+0x22>
  if(neg)
 4d2:	00088b63          	beqz	a7,4e8 <printint+0x56>
    buf[i++] = '-';
 4d6:	fd078793          	addi	a5,a5,-48
 4da:	97a2                	add	a5,a5,s0
 4dc:	02d00713          	li	a4,45
 4e0:	fee78423          	sb	a4,-24(a5)
 4e4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4e8:	02f05a63          	blez	a5,51c <printint+0x8a>
 4ec:	fc26                	sd	s1,56(sp)
 4ee:	f44e                	sd	s3,40(sp)
 4f0:	fb840713          	addi	a4,s0,-72
 4f4:	00f704b3          	add	s1,a4,a5
 4f8:	fff70993          	addi	s3,a4,-1
 4fc:	99be                	add	s3,s3,a5
 4fe:	37fd                	addiw	a5,a5,-1
 500:	1782                	slli	a5,a5,0x20
 502:	9381                	srli	a5,a5,0x20
 504:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 508:	fff4c583          	lbu	a1,-1(s1)
 50c:	854a                	mv	a0,s2
 50e:	f67ff0ef          	jal	474 <putc>
  while(--i >= 0)
 512:	14fd                	addi	s1,s1,-1
 514:	ff349ae3          	bne	s1,s3,508 <printint+0x76>
 518:	74e2                	ld	s1,56(sp)
 51a:	79a2                	ld	s3,40(sp)
}
 51c:	60a6                	ld	ra,72(sp)
 51e:	6406                	ld	s0,64(sp)
 520:	7942                	ld	s2,48(sp)
 522:	6161                	addi	sp,sp,80
 524:	8082                	ret
    x = -xx;
 526:	40b005b3          	neg	a1,a1
    neg = 1;
 52a:	4885                	li	a7,1
    x = -xx;
 52c:	bfad                	j	4a6 <printint+0x14>

000000000000052e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 52e:	711d                	addi	sp,sp,-96
 530:	ec86                	sd	ra,88(sp)
 532:	e8a2                	sd	s0,80(sp)
 534:	e0ca                	sd	s2,64(sp)
 536:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 538:	0005c903          	lbu	s2,0(a1)
 53c:	28090663          	beqz	s2,7c8 <vprintf+0x29a>
 540:	e4a6                	sd	s1,72(sp)
 542:	fc4e                	sd	s3,56(sp)
 544:	f852                	sd	s4,48(sp)
 546:	f456                	sd	s5,40(sp)
 548:	f05a                	sd	s6,32(sp)
 54a:	ec5e                	sd	s7,24(sp)
 54c:	e862                	sd	s8,16(sp)
 54e:	e466                	sd	s9,8(sp)
 550:	8b2a                	mv	s6,a0
 552:	8a2e                	mv	s4,a1
 554:	8bb2                	mv	s7,a2
  state = 0;
 556:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 558:	4481                	li	s1,0
 55a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 55c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 560:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 564:	06c00c93          	li	s9,108
 568:	a005                	j	588 <vprintf+0x5a>
        putc(fd, c0);
 56a:	85ca                	mv	a1,s2
 56c:	855a                	mv	a0,s6
 56e:	f07ff0ef          	jal	474 <putc>
 572:	a019                	j	578 <vprintf+0x4a>
    } else if(state == '%'){
 574:	03598263          	beq	s3,s5,598 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 578:	2485                	addiw	s1,s1,1
 57a:	8726                	mv	a4,s1
 57c:	009a07b3          	add	a5,s4,s1
 580:	0007c903          	lbu	s2,0(a5)
 584:	22090a63          	beqz	s2,7b8 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 588:	0009079b          	sext.w	a5,s2
    if(state == 0){
 58c:	fe0994e3          	bnez	s3,574 <vprintf+0x46>
      if(c0 == '%'){
 590:	fd579de3          	bne	a5,s5,56a <vprintf+0x3c>
        state = '%';
 594:	89be                	mv	s3,a5
 596:	b7cd                	j	578 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 598:	00ea06b3          	add	a3,s4,a4
 59c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5a0:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5a2:	c681                	beqz	a3,5aa <vprintf+0x7c>
 5a4:	9752                	add	a4,a4,s4
 5a6:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5aa:	05878363          	beq	a5,s8,5f0 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5ae:	05978d63          	beq	a5,s9,608 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5b2:	07500713          	li	a4,117
 5b6:	0ee78763          	beq	a5,a4,6a4 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5ba:	07800713          	li	a4,120
 5be:	12e78963          	beq	a5,a4,6f0 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5c2:	07000713          	li	a4,112
 5c6:	14e78e63          	beq	a5,a4,722 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5ca:	06300713          	li	a4,99
 5ce:	18e78e63          	beq	a5,a4,76a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5d2:	07300713          	li	a4,115
 5d6:	1ae78463          	beq	a5,a4,77e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5da:	02500713          	li	a4,37
 5de:	04e79563          	bne	a5,a4,628 <vprintf+0xfa>
        putc(fd, '%');
 5e2:	02500593          	li	a1,37
 5e6:	855a                	mv	a0,s6
 5e8:	e8dff0ef          	jal	474 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5ec:	4981                	li	s3,0
 5ee:	b769                	j	578 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5f0:	008b8913          	addi	s2,s7,8
 5f4:	4685                	li	a3,1
 5f6:	4629                	li	a2,10
 5f8:	000ba583          	lw	a1,0(s7)
 5fc:	855a                	mv	a0,s6
 5fe:	e95ff0ef          	jal	492 <printint>
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
 606:	bf8d                	j	578 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 608:	06400793          	li	a5,100
 60c:	02f68963          	beq	a3,a5,63e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 610:	06c00793          	li	a5,108
 614:	04f68263          	beq	a3,a5,658 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 618:	07500793          	li	a5,117
 61c:	0af68063          	beq	a3,a5,6bc <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 620:	07800793          	li	a5,120
 624:	0ef68263          	beq	a3,a5,708 <vprintf+0x1da>
        putc(fd, '%');
 628:	02500593          	li	a1,37
 62c:	855a                	mv	a0,s6
 62e:	e47ff0ef          	jal	474 <putc>
        putc(fd, c0);
 632:	85ca                	mv	a1,s2
 634:	855a                	mv	a0,s6
 636:	e3fff0ef          	jal	474 <putc>
      state = 0;
 63a:	4981                	li	s3,0
 63c:	bf35                	j	578 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 63e:	008b8913          	addi	s2,s7,8
 642:	4685                	li	a3,1
 644:	4629                	li	a2,10
 646:	000bb583          	ld	a1,0(s7)
 64a:	855a                	mv	a0,s6
 64c:	e47ff0ef          	jal	492 <printint>
        i += 1;
 650:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
        i += 1;
 656:	b70d                	j	578 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 658:	06400793          	li	a5,100
 65c:	02f60763          	beq	a2,a5,68a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 660:	07500793          	li	a5,117
 664:	06f60963          	beq	a2,a5,6d6 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 668:	07800793          	li	a5,120
 66c:	faf61ee3          	bne	a2,a5,628 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 670:	008b8913          	addi	s2,s7,8
 674:	4681                	li	a3,0
 676:	4641                	li	a2,16
 678:	000bb583          	ld	a1,0(s7)
 67c:	855a                	mv	a0,s6
 67e:	e15ff0ef          	jal	492 <printint>
        i += 2;
 682:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 684:	8bca                	mv	s7,s2
      state = 0;
 686:	4981                	li	s3,0
        i += 2;
 688:	bdc5                	j	578 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 68a:	008b8913          	addi	s2,s7,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000bb583          	ld	a1,0(s7)
 696:	855a                	mv	a0,s6
 698:	dfbff0ef          	jal	492 <printint>
        i += 2;
 69c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 69e:	8bca                	mv	s7,s2
      state = 0;
 6a0:	4981                	li	s3,0
        i += 2;
 6a2:	bdd9                	j	578 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6a4:	008b8913          	addi	s2,s7,8
 6a8:	4681                	li	a3,0
 6aa:	4629                	li	a2,10
 6ac:	000be583          	lwu	a1,0(s7)
 6b0:	855a                	mv	a0,s6
 6b2:	de1ff0ef          	jal	492 <printint>
 6b6:	8bca                	mv	s7,s2
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	bd7d                	j	578 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6bc:	008b8913          	addi	s2,s7,8
 6c0:	4681                	li	a3,0
 6c2:	4629                	li	a2,10
 6c4:	000bb583          	ld	a1,0(s7)
 6c8:	855a                	mv	a0,s6
 6ca:	dc9ff0ef          	jal	492 <printint>
        i += 1;
 6ce:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
        i += 1;
 6d4:	b555                	j	578 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d6:	008b8913          	addi	s2,s7,8
 6da:	4681                	li	a3,0
 6dc:	4629                	li	a2,10
 6de:	000bb583          	ld	a1,0(s7)
 6e2:	855a                	mv	a0,s6
 6e4:	dafff0ef          	jal	492 <printint>
        i += 2;
 6e8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
        i += 2;
 6ee:	b569                	j	578 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6f0:	008b8913          	addi	s2,s7,8
 6f4:	4681                	li	a3,0
 6f6:	4641                	li	a2,16
 6f8:	000be583          	lwu	a1,0(s7)
 6fc:	855a                	mv	a0,s6
 6fe:	d95ff0ef          	jal	492 <printint>
 702:	8bca                	mv	s7,s2
      state = 0;
 704:	4981                	li	s3,0
 706:	bd8d                	j	578 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 708:	008b8913          	addi	s2,s7,8
 70c:	4681                	li	a3,0
 70e:	4641                	li	a2,16
 710:	000bb583          	ld	a1,0(s7)
 714:	855a                	mv	a0,s6
 716:	d7dff0ef          	jal	492 <printint>
        i += 1;
 71a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 71c:	8bca                	mv	s7,s2
      state = 0;
 71e:	4981                	li	s3,0
        i += 1;
 720:	bda1                	j	578 <vprintf+0x4a>
 722:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 724:	008b8d13          	addi	s10,s7,8
 728:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 72c:	03000593          	li	a1,48
 730:	855a                	mv	a0,s6
 732:	d43ff0ef          	jal	474 <putc>
  putc(fd, 'x');
 736:	07800593          	li	a1,120
 73a:	855a                	mv	a0,s6
 73c:	d39ff0ef          	jal	474 <putc>
 740:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 742:	00000b97          	auipc	s7,0x0
 746:	3c6b8b93          	addi	s7,s7,966 # b08 <digits>
 74a:	03c9d793          	srli	a5,s3,0x3c
 74e:	97de                	add	a5,a5,s7
 750:	0007c583          	lbu	a1,0(a5)
 754:	855a                	mv	a0,s6
 756:	d1fff0ef          	jal	474 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 75a:	0992                	slli	s3,s3,0x4
 75c:	397d                	addiw	s2,s2,-1
 75e:	fe0916e3          	bnez	s2,74a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 762:	8bea                	mv	s7,s10
      state = 0;
 764:	4981                	li	s3,0
 766:	6d02                	ld	s10,0(sp)
 768:	bd01                	j	578 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 76a:	008b8913          	addi	s2,s7,8
 76e:	000bc583          	lbu	a1,0(s7)
 772:	855a                	mv	a0,s6
 774:	d01ff0ef          	jal	474 <putc>
 778:	8bca                	mv	s7,s2
      state = 0;
 77a:	4981                	li	s3,0
 77c:	bbf5                	j	578 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 77e:	008b8993          	addi	s3,s7,8
 782:	000bb903          	ld	s2,0(s7)
 786:	00090f63          	beqz	s2,7a4 <vprintf+0x276>
        for(; *s; s++)
 78a:	00094583          	lbu	a1,0(s2)
 78e:	c195                	beqz	a1,7b2 <vprintf+0x284>
          putc(fd, *s);
 790:	855a                	mv	a0,s6
 792:	ce3ff0ef          	jal	474 <putc>
        for(; *s; s++)
 796:	0905                	addi	s2,s2,1
 798:	00094583          	lbu	a1,0(s2)
 79c:	f9f5                	bnez	a1,790 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 79e:	8bce                	mv	s7,s3
      state = 0;
 7a0:	4981                	li	s3,0
 7a2:	bbd9                	j	578 <vprintf+0x4a>
          s = "(null)";
 7a4:	00000917          	auipc	s2,0x0
 7a8:	35c90913          	addi	s2,s2,860 # b00 <malloc+0x250>
        for(; *s; s++)
 7ac:	02800593          	li	a1,40
 7b0:	b7c5                	j	790 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7b2:	8bce                	mv	s7,s3
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b3c9                	j	578 <vprintf+0x4a>
 7b8:	64a6                	ld	s1,72(sp)
 7ba:	79e2                	ld	s3,56(sp)
 7bc:	7a42                	ld	s4,48(sp)
 7be:	7aa2                	ld	s5,40(sp)
 7c0:	7b02                	ld	s6,32(sp)
 7c2:	6be2                	ld	s7,24(sp)
 7c4:	6c42                	ld	s8,16(sp)
 7c6:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7c8:	60e6                	ld	ra,88(sp)
 7ca:	6446                	ld	s0,80(sp)
 7cc:	6906                	ld	s2,64(sp)
 7ce:	6125                	addi	sp,sp,96
 7d0:	8082                	ret

00000000000007d2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d2:	715d                	addi	sp,sp,-80
 7d4:	ec06                	sd	ra,24(sp)
 7d6:	e822                	sd	s0,16(sp)
 7d8:	1000                	addi	s0,sp,32
 7da:	e010                	sd	a2,0(s0)
 7dc:	e414                	sd	a3,8(s0)
 7de:	e818                	sd	a4,16(s0)
 7e0:	ec1c                	sd	a5,24(s0)
 7e2:	03043023          	sd	a6,32(s0)
 7e6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ea:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7ee:	8622                	mv	a2,s0
 7f0:	d3fff0ef          	jal	52e <vprintf>
}
 7f4:	60e2                	ld	ra,24(sp)
 7f6:	6442                	ld	s0,16(sp)
 7f8:	6161                	addi	sp,sp,80
 7fa:	8082                	ret

00000000000007fc <printf>:

void
printf(const char *fmt, ...)
{
 7fc:	711d                	addi	sp,sp,-96
 7fe:	ec06                	sd	ra,24(sp)
 800:	e822                	sd	s0,16(sp)
 802:	1000                	addi	s0,sp,32
 804:	e40c                	sd	a1,8(s0)
 806:	e810                	sd	a2,16(s0)
 808:	ec14                	sd	a3,24(s0)
 80a:	f018                	sd	a4,32(s0)
 80c:	f41c                	sd	a5,40(s0)
 80e:	03043823          	sd	a6,48(s0)
 812:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 816:	00840613          	addi	a2,s0,8
 81a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81e:	85aa                	mv	a1,a0
 820:	4505                	li	a0,1
 822:	d0dff0ef          	jal	52e <vprintf>
}
 826:	60e2                	ld	ra,24(sp)
 828:	6442                	ld	s0,16(sp)
 82a:	6125                	addi	sp,sp,96
 82c:	8082                	ret

000000000000082e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82e:	1141                	addi	sp,sp,-16
 830:	e422                	sd	s0,8(sp)
 832:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 834:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 838:	00000797          	auipc	a5,0x0
 83c:	7c87b783          	ld	a5,1992(a5) # 1000 <freep>
 840:	a02d                	j	86a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 842:	4618                	lw	a4,8(a2)
 844:	9f2d                	addw	a4,a4,a1
 846:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	6398                	ld	a4,0(a5)
 84c:	6310                	ld	a2,0(a4)
 84e:	a83d                	j	88c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 850:	ff852703          	lw	a4,-8(a0)
 854:	9f31                	addw	a4,a4,a2
 856:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 858:	ff053683          	ld	a3,-16(a0)
 85c:	a091                	j	8a0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85e:	6398                	ld	a4,0(a5)
 860:	00e7e463          	bltu	a5,a4,868 <free+0x3a>
 864:	00e6ea63          	bltu	a3,a4,878 <free+0x4a>
{
 868:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86a:	fed7fae3          	bgeu	a5,a3,85e <free+0x30>
 86e:	6398                	ld	a4,0(a5)
 870:	00e6e463          	bltu	a3,a4,878 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 874:	fee7eae3          	bltu	a5,a4,868 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 878:	ff852583          	lw	a1,-8(a0)
 87c:	6390                	ld	a2,0(a5)
 87e:	02059813          	slli	a6,a1,0x20
 882:	01c85713          	srli	a4,a6,0x1c
 886:	9736                	add	a4,a4,a3
 888:	fae60de3          	beq	a2,a4,842 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 88c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 890:	4790                	lw	a2,8(a5)
 892:	02061593          	slli	a1,a2,0x20
 896:	01c5d713          	srli	a4,a1,0x1c
 89a:	973e                	add	a4,a4,a5
 89c:	fae68ae3          	beq	a3,a4,850 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	74f73f23          	sd	a5,1886(a4) # 1000 <freep>
}
 8aa:	6422                	ld	s0,8(sp)
 8ac:	0141                	addi	sp,sp,16
 8ae:	8082                	ret

00000000000008b0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b0:	7139                	addi	sp,sp,-64
 8b2:	fc06                	sd	ra,56(sp)
 8b4:	f822                	sd	s0,48(sp)
 8b6:	f426                	sd	s1,40(sp)
 8b8:	ec4e                	sd	s3,24(sp)
 8ba:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8bc:	02051493          	slli	s1,a0,0x20
 8c0:	9081                	srli	s1,s1,0x20
 8c2:	04bd                	addi	s1,s1,15
 8c4:	8091                	srli	s1,s1,0x4
 8c6:	0014899b          	addiw	s3,s1,1
 8ca:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8cc:	00000517          	auipc	a0,0x0
 8d0:	73453503          	ld	a0,1844(a0) # 1000 <freep>
 8d4:	c915                	beqz	a0,908 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d8:	4798                	lw	a4,8(a5)
 8da:	08977a63          	bgeu	a4,s1,96e <malloc+0xbe>
 8de:	f04a                	sd	s2,32(sp)
 8e0:	e852                	sd	s4,16(sp)
 8e2:	e456                	sd	s5,8(sp)
 8e4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8e6:	8a4e                	mv	s4,s3
 8e8:	0009871b          	sext.w	a4,s3
 8ec:	6685                	lui	a3,0x1
 8ee:	00d77363          	bgeu	a4,a3,8f4 <malloc+0x44>
 8f2:	6a05                	lui	s4,0x1
 8f4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fc:	00000917          	auipc	s2,0x0
 900:	70490913          	addi	s2,s2,1796 # 1000 <freep>
  if(p == SBRK_ERROR)
 904:	5afd                	li	s5,-1
 906:	a081                	j	946 <malloc+0x96>
 908:	f04a                	sd	s2,32(sp)
 90a:	e852                	sd	s4,16(sp)
 90c:	e456                	sd	s5,8(sp)
 90e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 910:	00000797          	auipc	a5,0x0
 914:	70078793          	addi	a5,a5,1792 # 1010 <base>
 918:	00000717          	auipc	a4,0x0
 91c:	6ef73423          	sd	a5,1768(a4) # 1000 <freep>
 920:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 922:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 926:	b7c1                	j	8e6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 928:	6398                	ld	a4,0(a5)
 92a:	e118                	sd	a4,0(a0)
 92c:	a8a9                	j	986 <malloc+0xd6>
  hp->s.size = nu;
 92e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 932:	0541                	addi	a0,a0,16
 934:	efbff0ef          	jal	82e <free>
  return freep;
 938:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 93c:	c12d                	beqz	a0,99e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 93e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 940:	4798                	lw	a4,8(a5)
 942:	02977263          	bgeu	a4,s1,966 <malloc+0xb6>
    if(p == freep)
 946:	00093703          	ld	a4,0(s2)
 94a:	853e                	mv	a0,a5
 94c:	fef719e3          	bne	a4,a5,93e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 950:	8552                	mv	a0,s4
 952:	a0fff0ef          	jal	360 <sbrk>
  if(p == SBRK_ERROR)
 956:	fd551ce3          	bne	a0,s5,92e <malloc+0x7e>
        return 0;
 95a:	4501                	li	a0,0
 95c:	7902                	ld	s2,32(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
 964:	a03d                	j	992 <malloc+0xe2>
 966:	7902                	ld	s2,32(sp)
 968:	6a42                	ld	s4,16(sp)
 96a:	6aa2                	ld	s5,8(sp)
 96c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 96e:	fae48de3          	beq	s1,a4,928 <malloc+0x78>
        p->s.size -= nunits;
 972:	4137073b          	subw	a4,a4,s3
 976:	c798                	sw	a4,8(a5)
        p += p->s.size;
 978:	02071693          	slli	a3,a4,0x20
 97c:	01c6d713          	srli	a4,a3,0x1c
 980:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 982:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 986:	00000717          	auipc	a4,0x0
 98a:	66a73d23          	sd	a0,1658(a4) # 1000 <freep>
      return (void*)(p + 1);
 98e:	01078513          	addi	a0,a5,16
  }
}
 992:	70e2                	ld	ra,56(sp)
 994:	7442                	ld	s0,48(sp)
 996:	74a2                	ld	s1,40(sp)
 998:	69e2                	ld	s3,24(sp)
 99a:	6121                	addi	sp,sp,64
 99c:	8082                	ret
 99e:	7902                	ld	s2,32(sp)
 9a0:	6a42                	ld	s4,16(sp)
 9a2:	6aa2                	ld	s5,8(sp)
 9a4:	6b02                	ld	s6,0(sp)
 9a6:	b7f5                	j	992 <malloc+0xe2>
