
user/_latency_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
  const int ITER = 5000;
  uint64 start, end;
  uint64 total = 0;

  printf("=== Starting System Call Latency Measurement (%d iterations) ===\n", ITER);
   c:	6585                	lui	a1,0x1
   e:	38858593          	addi	a1,a1,904 # 1388 <base+0x378>
  12:	00001517          	auipc	a0,0x1
  16:	91e50513          	addi	a0,a0,-1762 # 930 <malloc+0x104>
  1a:	75e000ef          	jal	778 <printf>

  start = getcycles(); // Mốc thời gian bắt đầu toàn cục
  1e:	3c2000ef          	jal	3e0 <getcycles>
  22:	892a                	mv	s2,a0
  24:	6485                	lui	s1,0x1
  26:	38848493          	addi	s1,s1,904 # 1388 <base+0x378>
  
  for(int i = 0; i < ITER; i++) {
    nullcall(); // Thực hiện liên tục để đo áp lực chuyển đổi ngữ cảnh
  2a:	3ae000ef          	jal	3d8 <nullcall>
    nullcall();
  2e:	3aa000ef          	jal	3d8 <nullcall>
    nullcall();
  32:	3a6000ef          	jal	3d8 <nullcall>
    nullcall();
  36:	3a2000ef          	jal	3d8 <nullcall>
  for(int i = 0; i < ITER; i++) {
  3a:	34fd                	addiw	s1,s1,-1
  3c:	f4fd                	bnez	s1,2a <main+0x2a>
  }
  
  end = getcycles(); // Mốc thời gian kết thúc
  3e:	3a2000ef          	jal	3e0 <getcycles>

  if(end >= start) {
  42:	01256463          	bltu	a0,s2,4a <main+0x4a>
    total = end - start;
  46:	412504b3          	sub	s1,a0,s2
  }

  // Hiển thị kết quả tính toán độ trễ theo đơn vị Ticks hệ thống
  printf("Total elapsed time for test: %ld clock ticks\n", total);
  4a:	85a6                	mv	a1,s1
  4c:	00001517          	auipc	a0,0x1
  50:	92c50513          	addi	a0,a0,-1748 # 978 <malloc+0x14c>
  54:	724000ef          	jal	778 <printf>
  printf("Average overhead per call sequence: %ld ticks/thousand-calls\n", (total * 1000) / ITER);
  58:	3e800793          	li	a5,1000
  5c:	02f484b3          	mul	s1,s1,a5
  60:	6585                	lui	a1,0x1
  62:	38858593          	addi	a1,a1,904 # 1388 <base+0x378>
  66:	02b4d5b3          	divu	a1,s1,a1
  6a:	00001517          	auipc	a0,0x1
  6e:	93e50513          	addi	a0,a0,-1730 # 9a8 <malloc+0x17c>
  72:	706000ef          	jal	778 <printf>

  exit(0);
  76:	4501                	li	a0,0
  78:	298000ef          	jal	310 <exit>

000000000000007c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  7c:	1141                	addi	sp,sp,-16
  7e:	e406                	sd	ra,8(sp)
  80:	e022                	sd	s0,0(sp)
  82:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  84:	f7dff0ef          	jal	0 <main>
  exit(r);
  88:	288000ef          	jal	310 <exit>

000000000000008c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  8c:	1141                	addi	sp,sp,-16
  8e:	e422                	sd	s0,8(sp)
  90:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  92:	87aa                	mv	a5,a0
  94:	0585                	addi	a1,a1,1
  96:	0785                	addi	a5,a5,1
  98:	fff5c703          	lbu	a4,-1(a1)
  9c:	fee78fa3          	sb	a4,-1(a5)
  a0:	fb75                	bnez	a4,94 <strcpy+0x8>
    ;
  return os;
}
  a2:	6422                	ld	s0,8(sp)
  a4:	0141                	addi	sp,sp,16
  a6:	8082                	ret

00000000000000a8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a8:	1141                	addi	sp,sp,-16
  aa:	e422                	sd	s0,8(sp)
  ac:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  ae:	00054783          	lbu	a5,0(a0)
  b2:	cb91                	beqz	a5,c6 <strcmp+0x1e>
  b4:	0005c703          	lbu	a4,0(a1)
  b8:	00f71763          	bne	a4,a5,c6 <strcmp+0x1e>
    p++, q++;
  bc:	0505                	addi	a0,a0,1
  be:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  c0:	00054783          	lbu	a5,0(a0)
  c4:	fbe5                	bnez	a5,b4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  c6:	0005c503          	lbu	a0,0(a1)
}
  ca:	40a7853b          	subw	a0,a5,a0
  ce:	6422                	ld	s0,8(sp)
  d0:	0141                	addi	sp,sp,16
  d2:	8082                	ret

00000000000000d4 <strlen>:

uint
strlen(const char *s)
{
  d4:	1141                	addi	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  da:	00054783          	lbu	a5,0(a0)
  de:	cf91                	beqz	a5,fa <strlen+0x26>
  e0:	0505                	addi	a0,a0,1
  e2:	87aa                	mv	a5,a0
  e4:	86be                	mv	a3,a5
  e6:	0785                	addi	a5,a5,1
  e8:	fff7c703          	lbu	a4,-1(a5)
  ec:	ff65                	bnez	a4,e4 <strlen+0x10>
  ee:	40a6853b          	subw	a0,a3,a0
  f2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  f4:	6422                	ld	s0,8(sp)
  f6:	0141                	addi	sp,sp,16
  f8:	8082                	ret
  for(n = 0; s[n]; n++)
  fa:	4501                	li	a0,0
  fc:	bfe5                	j	f4 <strlen+0x20>

00000000000000fe <memset>:

void*
memset(void *dst, int c, uint n)
{
  fe:	1141                	addi	sp,sp,-16
 100:	e422                	sd	s0,8(sp)
 102:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 104:	ca19                	beqz	a2,11a <memset+0x1c>
 106:	87aa                	mv	a5,a0
 108:	1602                	slli	a2,a2,0x20
 10a:	9201                	srli	a2,a2,0x20
 10c:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 110:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 114:	0785                	addi	a5,a5,1
 116:	fee79de3          	bne	a5,a4,110 <memset+0x12>
  }
  return dst;
}
 11a:	6422                	ld	s0,8(sp)
 11c:	0141                	addi	sp,sp,16
 11e:	8082                	ret

0000000000000120 <strchr>:

char*
strchr(const char *s, char c)
{
 120:	1141                	addi	sp,sp,-16
 122:	e422                	sd	s0,8(sp)
 124:	0800                	addi	s0,sp,16
  for(; *s; s++)
 126:	00054783          	lbu	a5,0(a0)
 12a:	cb99                	beqz	a5,140 <strchr+0x20>
    if(*s == c)
 12c:	00f58763          	beq	a1,a5,13a <strchr+0x1a>
  for(; *s; s++)
 130:	0505                	addi	a0,a0,1
 132:	00054783          	lbu	a5,0(a0)
 136:	fbfd                	bnez	a5,12c <strchr+0xc>
      return (char*)s;
  return 0;
 138:	4501                	li	a0,0
}
 13a:	6422                	ld	s0,8(sp)
 13c:	0141                	addi	sp,sp,16
 13e:	8082                	ret
  return 0;
 140:	4501                	li	a0,0
 142:	bfe5                	j	13a <strchr+0x1a>

0000000000000144 <gets>:

char*
gets(char *buf, int max)
{
 144:	711d                	addi	sp,sp,-96
 146:	ec86                	sd	ra,88(sp)
 148:	e8a2                	sd	s0,80(sp)
 14a:	e4a6                	sd	s1,72(sp)
 14c:	e0ca                	sd	s2,64(sp)
 14e:	fc4e                	sd	s3,56(sp)
 150:	f852                	sd	s4,48(sp)
 152:	f456                	sd	s5,40(sp)
 154:	f05a                	sd	s6,32(sp)
 156:	ec5e                	sd	s7,24(sp)
 158:	1080                	addi	s0,sp,96
 15a:	8baa                	mv	s7,a0
 15c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 15e:	892a                	mv	s2,a0
 160:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 162:	4aa9                	li	s5,10
 164:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 166:	89a6                	mv	s3,s1
 168:	2485                	addiw	s1,s1,1
 16a:	0344d663          	bge	s1,s4,196 <gets+0x52>
    cc = read(0, &c, 1);
 16e:	4605                	li	a2,1
 170:	faf40593          	addi	a1,s0,-81
 174:	4501                	li	a0,0
 176:	1b2000ef          	jal	328 <read>
    if(cc < 1)
 17a:	00a05e63          	blez	a0,196 <gets+0x52>
    buf[i++] = c;
 17e:	faf44783          	lbu	a5,-81(s0)
 182:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 186:	01578763          	beq	a5,s5,194 <gets+0x50>
 18a:	0905                	addi	s2,s2,1
 18c:	fd679de3          	bne	a5,s6,166 <gets+0x22>
    buf[i++] = c;
 190:	89a6                	mv	s3,s1
 192:	a011                	j	196 <gets+0x52>
 194:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 196:	99de                	add	s3,s3,s7
 198:	00098023          	sb	zero,0(s3)
  return buf;
}
 19c:	855e                	mv	a0,s7
 19e:	60e6                	ld	ra,88(sp)
 1a0:	6446                	ld	s0,80(sp)
 1a2:	64a6                	ld	s1,72(sp)
 1a4:	6906                	ld	s2,64(sp)
 1a6:	79e2                	ld	s3,56(sp)
 1a8:	7a42                	ld	s4,48(sp)
 1aa:	7aa2                	ld	s5,40(sp)
 1ac:	7b02                	ld	s6,32(sp)
 1ae:	6be2                	ld	s7,24(sp)
 1b0:	6125                	addi	sp,sp,96
 1b2:	8082                	ret

00000000000001b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b4:	1101                	addi	sp,sp,-32
 1b6:	ec06                	sd	ra,24(sp)
 1b8:	e822                	sd	s0,16(sp)
 1ba:	e04a                	sd	s2,0(sp)
 1bc:	1000                	addi	s0,sp,32
 1be:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c0:	4581                	li	a1,0
 1c2:	18e000ef          	jal	350 <open>
  if(fd < 0)
 1c6:	02054263          	bltz	a0,1ea <stat+0x36>
 1ca:	e426                	sd	s1,8(sp)
 1cc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1ce:	85ca                	mv	a1,s2
 1d0:	198000ef          	jal	368 <fstat>
 1d4:	892a                	mv	s2,a0
  close(fd);
 1d6:	8526                	mv	a0,s1
 1d8:	160000ef          	jal	338 <close>
  return r;
 1dc:	64a2                	ld	s1,8(sp)
}
 1de:	854a                	mv	a0,s2
 1e0:	60e2                	ld	ra,24(sp)
 1e2:	6442                	ld	s0,16(sp)
 1e4:	6902                	ld	s2,0(sp)
 1e6:	6105                	addi	sp,sp,32
 1e8:	8082                	ret
    return -1;
 1ea:	597d                	li	s2,-1
 1ec:	bfcd                	j	1de <stat+0x2a>

00000000000001ee <atoi>:

int
atoi(const char *s)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1f4:	00054683          	lbu	a3,0(a0)
 1f8:	fd06879b          	addiw	a5,a3,-48
 1fc:	0ff7f793          	zext.b	a5,a5
 200:	4625                	li	a2,9
 202:	02f66863          	bltu	a2,a5,232 <atoi+0x44>
 206:	872a                	mv	a4,a0
  n = 0;
 208:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 20a:	0705                	addi	a4,a4,1
 20c:	0025179b          	slliw	a5,a0,0x2
 210:	9fa9                	addw	a5,a5,a0
 212:	0017979b          	slliw	a5,a5,0x1
 216:	9fb5                	addw	a5,a5,a3
 218:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 21c:	00074683          	lbu	a3,0(a4)
 220:	fd06879b          	addiw	a5,a3,-48
 224:	0ff7f793          	zext.b	a5,a5
 228:	fef671e3          	bgeu	a2,a5,20a <atoi+0x1c>
  return n;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret
  n = 0;
 232:	4501                	li	a0,0
 234:	bfe5                	j	22c <atoi+0x3e>

0000000000000236 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 236:	1141                	addi	sp,sp,-16
 238:	e422                	sd	s0,8(sp)
 23a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 23c:	02b57463          	bgeu	a0,a1,264 <memmove+0x2e>
    while(n-- > 0)
 240:	00c05f63          	blez	a2,25e <memmove+0x28>
 244:	1602                	slli	a2,a2,0x20
 246:	9201                	srli	a2,a2,0x20
 248:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 24c:	872a                	mv	a4,a0
      *dst++ = *src++;
 24e:	0585                	addi	a1,a1,1
 250:	0705                	addi	a4,a4,1
 252:	fff5c683          	lbu	a3,-1(a1)
 256:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 25a:	fef71ae3          	bne	a4,a5,24e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 25e:	6422                	ld	s0,8(sp)
 260:	0141                	addi	sp,sp,16
 262:	8082                	ret
    dst += n;
 264:	00c50733          	add	a4,a0,a2
    src += n;
 268:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 26a:	fec05ae3          	blez	a2,25e <memmove+0x28>
 26e:	fff6079b          	addiw	a5,a2,-1
 272:	1782                	slli	a5,a5,0x20
 274:	9381                	srli	a5,a5,0x20
 276:	fff7c793          	not	a5,a5
 27a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 27c:	15fd                	addi	a1,a1,-1
 27e:	177d                	addi	a4,a4,-1
 280:	0005c683          	lbu	a3,0(a1)
 284:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 288:	fee79ae3          	bne	a5,a4,27c <memmove+0x46>
 28c:	bfc9                	j	25e <memmove+0x28>

000000000000028e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 294:	ca05                	beqz	a2,2c4 <memcmp+0x36>
 296:	fff6069b          	addiw	a3,a2,-1
 29a:	1682                	slli	a3,a3,0x20
 29c:	9281                	srli	a3,a3,0x20
 29e:	0685                	addi	a3,a3,1
 2a0:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2a2:	00054783          	lbu	a5,0(a0)
 2a6:	0005c703          	lbu	a4,0(a1)
 2aa:	00e79863          	bne	a5,a4,2ba <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2ae:	0505                	addi	a0,a0,1
    p2++;
 2b0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2b2:	fed518e3          	bne	a0,a3,2a2 <memcmp+0x14>
  }
  return 0;
 2b6:	4501                	li	a0,0
 2b8:	a019                	j	2be <memcmp+0x30>
      return *p1 - *p2;
 2ba:	40e7853b          	subw	a0,a5,a4
}
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret
  return 0;
 2c4:	4501                	li	a0,0
 2c6:	bfe5                	j	2be <memcmp+0x30>

00000000000002c8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e406                	sd	ra,8(sp)
 2cc:	e022                	sd	s0,0(sp)
 2ce:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2d0:	f67ff0ef          	jal	236 <memmove>
}
 2d4:	60a2                	ld	ra,8(sp)
 2d6:	6402                	ld	s0,0(sp)
 2d8:	0141                	addi	sp,sp,16
 2da:	8082                	ret

00000000000002dc <sbrk>:

char *
sbrk(int n) {
 2dc:	1141                	addi	sp,sp,-16
 2de:	e406                	sd	ra,8(sp)
 2e0:	e022                	sd	s0,0(sp)
 2e2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2e4:	4585                	li	a1,1
 2e6:	0b2000ef          	jal	398 <sys_sbrk>
}
 2ea:	60a2                	ld	ra,8(sp)
 2ec:	6402                	ld	s0,0(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret

00000000000002f2 <sbrklazy>:

char *
sbrklazy(int n) {
 2f2:	1141                	addi	sp,sp,-16
 2f4:	e406                	sd	ra,8(sp)
 2f6:	e022                	sd	s0,0(sp)
 2f8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2fa:	4589                	li	a1,2
 2fc:	09c000ef          	jal	398 <sys_sbrk>
}
 300:	60a2                	ld	ra,8(sp)
 302:	6402                	ld	s0,0(sp)
 304:	0141                	addi	sp,sp,16
 306:	8082                	ret

0000000000000308 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 308:	4885                	li	a7,1
 ecall
 30a:	00000073          	ecall
 ret
 30e:	8082                	ret

0000000000000310 <exit>:
.global exit
exit:
 li a7, SYS_exit
 310:	4889                	li	a7,2
 ecall
 312:	00000073          	ecall
 ret
 316:	8082                	ret

0000000000000318 <wait>:
.global wait
wait:
 li a7, SYS_wait
 318:	488d                	li	a7,3
 ecall
 31a:	00000073          	ecall
 ret
 31e:	8082                	ret

0000000000000320 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 320:	4891                	li	a7,4
 ecall
 322:	00000073          	ecall
 ret
 326:	8082                	ret

0000000000000328 <read>:
.global read
read:
 li a7, SYS_read
 328:	4895                	li	a7,5
 ecall
 32a:	00000073          	ecall
 ret
 32e:	8082                	ret

0000000000000330 <write>:
.global write
write:
 li a7, SYS_write
 330:	48c1                	li	a7,16
 ecall
 332:	00000073          	ecall
 ret
 336:	8082                	ret

0000000000000338 <close>:
.global close
close:
 li a7, SYS_close
 338:	48d5                	li	a7,21
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <kill>:
.global kill
kill:
 li a7, SYS_kill
 340:	4899                	li	a7,6
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <exec>:
.global exec
exec:
 li a7, SYS_exec
 348:	489d                	li	a7,7
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <open>:
.global open
open:
 li a7, SYS_open
 350:	48bd                	li	a7,15
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 358:	48c5                	li	a7,17
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 360:	48c9                	li	a7,18
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 368:	48a1                	li	a7,8
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <link>:
.global link
link:
 li a7, SYS_link
 370:	48cd                	li	a7,19
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 378:	48d1                	li	a7,20
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 380:	48a5                	li	a7,9
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <dup>:
.global dup
dup:
 li a7, SYS_dup
 388:	48a9                	li	a7,10
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 390:	48ad                	li	a7,11
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 398:	48b1                	li	a7,12
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3a0:	48b5                	li	a7,13
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3a8:	48b9                	li	a7,14
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <hello>:
.global hello
hello:
 li a7, SYS_hello
 3b0:	48d9                	li	a7,22
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <ps>:
.global ps
ps:
 li a7, SYS_ps
 3b8:	48dd                	li	a7,23
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <memtest>:
.global memtest
memtest:
 li a7, SYS_memtest
 3c0:	48e1                	li	a7,24
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <testnolock>:
.global testnolock
testnolock:
 li a7, SYS_testnolock
 3c8:	48e5                	li	a7,25
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 3d0:	48e9                	li	a7,26
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <nullcall>:
.global nullcall
nullcall:
 li a7, SYS_nullcall
 3d8:	48ed                	li	a7,27
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <getcycles>:
.global getcycles
getcycles:
 li a7, SYS_getcycles
 3e0:	48f1                	li	a7,28
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <set_filter>:
.global set_filter
set_filter:
 li a7, SYS_set_filter
 3e8:	48f5                	li	a7,29
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f0:	1101                	addi	sp,sp,-32
 3f2:	ec06                	sd	ra,24(sp)
 3f4:	e822                	sd	s0,16(sp)
 3f6:	1000                	addi	s0,sp,32
 3f8:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3fc:	4605                	li	a2,1
 3fe:	fef40593          	addi	a1,s0,-17
 402:	f2fff0ef          	jal	330 <write>
}
 406:	60e2                	ld	ra,24(sp)
 408:	6442                	ld	s0,16(sp)
 40a:	6105                	addi	sp,sp,32
 40c:	8082                	ret

000000000000040e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 40e:	715d                	addi	sp,sp,-80
 410:	e486                	sd	ra,72(sp)
 412:	e0a2                	sd	s0,64(sp)
 414:	f84a                	sd	s2,48(sp)
 416:	0880                	addi	s0,sp,80
 418:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 41a:	c299                	beqz	a3,420 <printint+0x12>
 41c:	0805c363          	bltz	a1,4a2 <printint+0x94>
  neg = 0;
 420:	4881                	li	a7,0
 422:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 426:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 428:	00000517          	auipc	a0,0x0
 42c:	5c850513          	addi	a0,a0,1480 # 9f0 <digits>
 430:	883e                	mv	a6,a5
 432:	2785                	addiw	a5,a5,1
 434:	02c5f733          	remu	a4,a1,a2
 438:	972a                	add	a4,a4,a0
 43a:	00074703          	lbu	a4,0(a4)
 43e:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 442:	872e                	mv	a4,a1
 444:	02c5d5b3          	divu	a1,a1,a2
 448:	0685                	addi	a3,a3,1
 44a:	fec773e3          	bgeu	a4,a2,430 <printint+0x22>
  if(neg)
 44e:	00088b63          	beqz	a7,464 <printint+0x56>
    buf[i++] = '-';
 452:	fd078793          	addi	a5,a5,-48
 456:	97a2                	add	a5,a5,s0
 458:	02d00713          	li	a4,45
 45c:	fee78423          	sb	a4,-24(a5)
 460:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 464:	02f05a63          	blez	a5,498 <printint+0x8a>
 468:	fc26                	sd	s1,56(sp)
 46a:	f44e                	sd	s3,40(sp)
 46c:	fb840713          	addi	a4,s0,-72
 470:	00f704b3          	add	s1,a4,a5
 474:	fff70993          	addi	s3,a4,-1
 478:	99be                	add	s3,s3,a5
 47a:	37fd                	addiw	a5,a5,-1
 47c:	1782                	slli	a5,a5,0x20
 47e:	9381                	srli	a5,a5,0x20
 480:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 484:	fff4c583          	lbu	a1,-1(s1)
 488:	854a                	mv	a0,s2
 48a:	f67ff0ef          	jal	3f0 <putc>
  while(--i >= 0)
 48e:	14fd                	addi	s1,s1,-1
 490:	ff349ae3          	bne	s1,s3,484 <printint+0x76>
 494:	74e2                	ld	s1,56(sp)
 496:	79a2                	ld	s3,40(sp)
}
 498:	60a6                	ld	ra,72(sp)
 49a:	6406                	ld	s0,64(sp)
 49c:	7942                	ld	s2,48(sp)
 49e:	6161                	addi	sp,sp,80
 4a0:	8082                	ret
    x = -xx;
 4a2:	40b005b3          	neg	a1,a1
    neg = 1;
 4a6:	4885                	li	a7,1
    x = -xx;
 4a8:	bfad                	j	422 <printint+0x14>

00000000000004aa <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4aa:	711d                	addi	sp,sp,-96
 4ac:	ec86                	sd	ra,88(sp)
 4ae:	e8a2                	sd	s0,80(sp)
 4b0:	e0ca                	sd	s2,64(sp)
 4b2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4b4:	0005c903          	lbu	s2,0(a1)
 4b8:	28090663          	beqz	s2,744 <vprintf+0x29a>
 4bc:	e4a6                	sd	s1,72(sp)
 4be:	fc4e                	sd	s3,56(sp)
 4c0:	f852                	sd	s4,48(sp)
 4c2:	f456                	sd	s5,40(sp)
 4c4:	f05a                	sd	s6,32(sp)
 4c6:	ec5e                	sd	s7,24(sp)
 4c8:	e862                	sd	s8,16(sp)
 4ca:	e466                	sd	s9,8(sp)
 4cc:	8b2a                	mv	s6,a0
 4ce:	8a2e                	mv	s4,a1
 4d0:	8bb2                	mv	s7,a2
  state = 0;
 4d2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4d4:	4481                	li	s1,0
 4d6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4d8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4dc:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4e0:	06c00c93          	li	s9,108
 4e4:	a005                	j	504 <vprintf+0x5a>
        putc(fd, c0);
 4e6:	85ca                	mv	a1,s2
 4e8:	855a                	mv	a0,s6
 4ea:	f07ff0ef          	jal	3f0 <putc>
 4ee:	a019                	j	4f4 <vprintf+0x4a>
    } else if(state == '%'){
 4f0:	03598263          	beq	s3,s5,514 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4f4:	2485                	addiw	s1,s1,1
 4f6:	8726                	mv	a4,s1
 4f8:	009a07b3          	add	a5,s4,s1
 4fc:	0007c903          	lbu	s2,0(a5)
 500:	22090a63          	beqz	s2,734 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 504:	0009079b          	sext.w	a5,s2
    if(state == 0){
 508:	fe0994e3          	bnez	s3,4f0 <vprintf+0x46>
      if(c0 == '%'){
 50c:	fd579de3          	bne	a5,s5,4e6 <vprintf+0x3c>
        state = '%';
 510:	89be                	mv	s3,a5
 512:	b7cd                	j	4f4 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 514:	00ea06b3          	add	a3,s4,a4
 518:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 51c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 51e:	c681                	beqz	a3,526 <vprintf+0x7c>
 520:	9752                	add	a4,a4,s4
 522:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 526:	05878363          	beq	a5,s8,56c <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 52a:	05978d63          	beq	a5,s9,584 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 52e:	07500713          	li	a4,117
 532:	0ee78763          	beq	a5,a4,620 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 536:	07800713          	li	a4,120
 53a:	12e78963          	beq	a5,a4,66c <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 53e:	07000713          	li	a4,112
 542:	14e78e63          	beq	a5,a4,69e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 546:	06300713          	li	a4,99
 54a:	18e78e63          	beq	a5,a4,6e6 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 54e:	07300713          	li	a4,115
 552:	1ae78463          	beq	a5,a4,6fa <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 556:	02500713          	li	a4,37
 55a:	04e79563          	bne	a5,a4,5a4 <vprintf+0xfa>
        putc(fd, '%');
 55e:	02500593          	li	a1,37
 562:	855a                	mv	a0,s6
 564:	e8dff0ef          	jal	3f0 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 568:	4981                	li	s3,0
 56a:	b769                	j	4f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 56c:	008b8913          	addi	s2,s7,8
 570:	4685                	li	a3,1
 572:	4629                	li	a2,10
 574:	000ba583          	lw	a1,0(s7)
 578:	855a                	mv	a0,s6
 57a:	e95ff0ef          	jal	40e <printint>
 57e:	8bca                	mv	s7,s2
      state = 0;
 580:	4981                	li	s3,0
 582:	bf8d                	j	4f4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 584:	06400793          	li	a5,100
 588:	02f68963          	beq	a3,a5,5ba <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 58c:	06c00793          	li	a5,108
 590:	04f68263          	beq	a3,a5,5d4 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 594:	07500793          	li	a5,117
 598:	0af68063          	beq	a3,a5,638 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 59c:	07800793          	li	a5,120
 5a0:	0ef68263          	beq	a3,a5,684 <vprintf+0x1da>
        putc(fd, '%');
 5a4:	02500593          	li	a1,37
 5a8:	855a                	mv	a0,s6
 5aa:	e47ff0ef          	jal	3f0 <putc>
        putc(fd, c0);
 5ae:	85ca                	mv	a1,s2
 5b0:	855a                	mv	a0,s6
 5b2:	e3fff0ef          	jal	3f0 <putc>
      state = 0;
 5b6:	4981                	li	s3,0
 5b8:	bf35                	j	4f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ba:	008b8913          	addi	s2,s7,8
 5be:	4685                	li	a3,1
 5c0:	4629                	li	a2,10
 5c2:	000bb583          	ld	a1,0(s7)
 5c6:	855a                	mv	a0,s6
 5c8:	e47ff0ef          	jal	40e <printint>
        i += 1;
 5cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5ce:	8bca                	mv	s7,s2
      state = 0;
 5d0:	4981                	li	s3,0
        i += 1;
 5d2:	b70d                	j	4f4 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5d4:	06400793          	li	a5,100
 5d8:	02f60763          	beq	a2,a5,606 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5dc:	07500793          	li	a5,117
 5e0:	06f60963          	beq	a2,a5,652 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5e4:	07800793          	li	a5,120
 5e8:	faf61ee3          	bne	a2,a5,5a4 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ec:	008b8913          	addi	s2,s7,8
 5f0:	4681                	li	a3,0
 5f2:	4641                	li	a2,16
 5f4:	000bb583          	ld	a1,0(s7)
 5f8:	855a                	mv	a0,s6
 5fa:	e15ff0ef          	jal	40e <printint>
        i += 2;
 5fe:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
        i += 2;
 604:	bdc5                	j	4f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 606:	008b8913          	addi	s2,s7,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000bb583          	ld	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	dfbff0ef          	jal	40e <printint>
        i += 2;
 618:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 61a:	8bca                	mv	s7,s2
      state = 0;
 61c:	4981                	li	s3,0
        i += 2;
 61e:	bdd9                	j	4f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 620:	008b8913          	addi	s2,s7,8
 624:	4681                	li	a3,0
 626:	4629                	li	a2,10
 628:	000be583          	lwu	a1,0(s7)
 62c:	855a                	mv	a0,s6
 62e:	de1ff0ef          	jal	40e <printint>
 632:	8bca                	mv	s7,s2
      state = 0;
 634:	4981                	li	s3,0
 636:	bd7d                	j	4f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 638:	008b8913          	addi	s2,s7,8
 63c:	4681                	li	a3,0
 63e:	4629                	li	a2,10
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	dc9ff0ef          	jal	40e <printint>
        i += 1;
 64a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
        i += 1;
 650:	b555                	j	4f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 652:	008b8913          	addi	s2,s7,8
 656:	4681                	li	a3,0
 658:	4629                	li	a2,10
 65a:	000bb583          	ld	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	dafff0ef          	jal	40e <printint>
        i += 2;
 664:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 666:	8bca                	mv	s7,s2
      state = 0;
 668:	4981                	li	s3,0
        i += 2;
 66a:	b569                	j	4f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 66c:	008b8913          	addi	s2,s7,8
 670:	4681                	li	a3,0
 672:	4641                	li	a2,16
 674:	000be583          	lwu	a1,0(s7)
 678:	855a                	mv	a0,s6
 67a:	d95ff0ef          	jal	40e <printint>
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
 682:	bd8d                	j	4f4 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 684:	008b8913          	addi	s2,s7,8
 688:	4681                	li	a3,0
 68a:	4641                	li	a2,16
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	d7dff0ef          	jal	40e <printint>
        i += 1;
 696:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
        i += 1;
 69c:	bda1                	j	4f4 <vprintf+0x4a>
 69e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6a0:	008b8d13          	addi	s10,s7,8
 6a4:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6a8:	03000593          	li	a1,48
 6ac:	855a                	mv	a0,s6
 6ae:	d43ff0ef          	jal	3f0 <putc>
  putc(fd, 'x');
 6b2:	07800593          	li	a1,120
 6b6:	855a                	mv	a0,s6
 6b8:	d39ff0ef          	jal	3f0 <putc>
 6bc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6be:	00000b97          	auipc	s7,0x0
 6c2:	332b8b93          	addi	s7,s7,818 # 9f0 <digits>
 6c6:	03c9d793          	srli	a5,s3,0x3c
 6ca:	97de                	add	a5,a5,s7
 6cc:	0007c583          	lbu	a1,0(a5)
 6d0:	855a                	mv	a0,s6
 6d2:	d1fff0ef          	jal	3f0 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6d6:	0992                	slli	s3,s3,0x4
 6d8:	397d                	addiw	s2,s2,-1
 6da:	fe0916e3          	bnez	s2,6c6 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6de:	8bea                	mv	s7,s10
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	6d02                	ld	s10,0(sp)
 6e4:	bd01                	j	4f4 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6e6:	008b8913          	addi	s2,s7,8
 6ea:	000bc583          	lbu	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	d01ff0ef          	jal	3f0 <putc>
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	bbf5                	j	4f4 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6fa:	008b8993          	addi	s3,s7,8
 6fe:	000bb903          	ld	s2,0(s7)
 702:	00090f63          	beqz	s2,720 <vprintf+0x276>
        for(; *s; s++)
 706:	00094583          	lbu	a1,0(s2)
 70a:	c195                	beqz	a1,72e <vprintf+0x284>
          putc(fd, *s);
 70c:	855a                	mv	a0,s6
 70e:	ce3ff0ef          	jal	3f0 <putc>
        for(; *s; s++)
 712:	0905                	addi	s2,s2,1
 714:	00094583          	lbu	a1,0(s2)
 718:	f9f5                	bnez	a1,70c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 71a:	8bce                	mv	s7,s3
      state = 0;
 71c:	4981                	li	s3,0
 71e:	bbd9                	j	4f4 <vprintf+0x4a>
          s = "(null)";
 720:	00000917          	auipc	s2,0x0
 724:	2c890913          	addi	s2,s2,712 # 9e8 <malloc+0x1bc>
        for(; *s; s++)
 728:	02800593          	li	a1,40
 72c:	b7c5                	j	70c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 72e:	8bce                	mv	s7,s3
      state = 0;
 730:	4981                	li	s3,0
 732:	b3c9                	j	4f4 <vprintf+0x4a>
 734:	64a6                	ld	s1,72(sp)
 736:	79e2                	ld	s3,56(sp)
 738:	7a42                	ld	s4,48(sp)
 73a:	7aa2                	ld	s5,40(sp)
 73c:	7b02                	ld	s6,32(sp)
 73e:	6be2                	ld	s7,24(sp)
 740:	6c42                	ld	s8,16(sp)
 742:	6ca2                	ld	s9,8(sp)
    }
  }
}
 744:	60e6                	ld	ra,88(sp)
 746:	6446                	ld	s0,80(sp)
 748:	6906                	ld	s2,64(sp)
 74a:	6125                	addi	sp,sp,96
 74c:	8082                	ret

000000000000074e <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 74e:	715d                	addi	sp,sp,-80
 750:	ec06                	sd	ra,24(sp)
 752:	e822                	sd	s0,16(sp)
 754:	1000                	addi	s0,sp,32
 756:	e010                	sd	a2,0(s0)
 758:	e414                	sd	a3,8(s0)
 75a:	e818                	sd	a4,16(s0)
 75c:	ec1c                	sd	a5,24(s0)
 75e:	03043023          	sd	a6,32(s0)
 762:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 766:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 76a:	8622                	mv	a2,s0
 76c:	d3fff0ef          	jal	4aa <vprintf>
}
 770:	60e2                	ld	ra,24(sp)
 772:	6442                	ld	s0,16(sp)
 774:	6161                	addi	sp,sp,80
 776:	8082                	ret

0000000000000778 <printf>:

void
printf(const char *fmt, ...)
{
 778:	711d                	addi	sp,sp,-96
 77a:	ec06                	sd	ra,24(sp)
 77c:	e822                	sd	s0,16(sp)
 77e:	1000                	addi	s0,sp,32
 780:	e40c                	sd	a1,8(s0)
 782:	e810                	sd	a2,16(s0)
 784:	ec14                	sd	a3,24(s0)
 786:	f018                	sd	a4,32(s0)
 788:	f41c                	sd	a5,40(s0)
 78a:	03043823          	sd	a6,48(s0)
 78e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 792:	00840613          	addi	a2,s0,8
 796:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 79a:	85aa                	mv	a1,a0
 79c:	4505                	li	a0,1
 79e:	d0dff0ef          	jal	4aa <vprintf>
}
 7a2:	60e2                	ld	ra,24(sp)
 7a4:	6442                	ld	s0,16(sp)
 7a6:	6125                	addi	sp,sp,96
 7a8:	8082                	ret

00000000000007aa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7aa:	1141                	addi	sp,sp,-16
 7ac:	e422                	sd	s0,8(sp)
 7ae:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b4:	00001797          	auipc	a5,0x1
 7b8:	84c7b783          	ld	a5,-1972(a5) # 1000 <freep>
 7bc:	a02d                	j	7e6 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7be:	4618                	lw	a4,8(a2)
 7c0:	9f2d                	addw	a4,a4,a1
 7c2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c6:	6398                	ld	a4,0(a5)
 7c8:	6310                	ld	a2,0(a4)
 7ca:	a83d                	j	808 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7cc:	ff852703          	lw	a4,-8(a0)
 7d0:	9f31                	addw	a4,a4,a2
 7d2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7d4:	ff053683          	ld	a3,-16(a0)
 7d8:	a091                	j	81c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7da:	6398                	ld	a4,0(a5)
 7dc:	00e7e463          	bltu	a5,a4,7e4 <free+0x3a>
 7e0:	00e6ea63          	bltu	a3,a4,7f4 <free+0x4a>
{
 7e4:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e6:	fed7fae3          	bgeu	a5,a3,7da <free+0x30>
 7ea:	6398                	ld	a4,0(a5)
 7ec:	00e6e463          	bltu	a3,a4,7f4 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f0:	fee7eae3          	bltu	a5,a4,7e4 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7f4:	ff852583          	lw	a1,-8(a0)
 7f8:	6390                	ld	a2,0(a5)
 7fa:	02059813          	slli	a6,a1,0x20
 7fe:	01c85713          	srli	a4,a6,0x1c
 802:	9736                	add	a4,a4,a3
 804:	fae60de3          	beq	a2,a4,7be <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 808:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80c:	4790                	lw	a2,8(a5)
 80e:	02061593          	slli	a1,a2,0x20
 812:	01c5d713          	srli	a4,a1,0x1c
 816:	973e                	add	a4,a4,a5
 818:	fae68ae3          	beq	a3,a4,7cc <free+0x22>
    p->s.ptr = bp->s.ptr;
 81c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 81e:	00000717          	auipc	a4,0x0
 822:	7ef73123          	sd	a5,2018(a4) # 1000 <freep>
}
 826:	6422                	ld	s0,8(sp)
 828:	0141                	addi	sp,sp,16
 82a:	8082                	ret

000000000000082c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82c:	7139                	addi	sp,sp,-64
 82e:	fc06                	sd	ra,56(sp)
 830:	f822                	sd	s0,48(sp)
 832:	f426                	sd	s1,40(sp)
 834:	ec4e                	sd	s3,24(sp)
 836:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 838:	02051493          	slli	s1,a0,0x20
 83c:	9081                	srli	s1,s1,0x20
 83e:	04bd                	addi	s1,s1,15
 840:	8091                	srli	s1,s1,0x4
 842:	0014899b          	addiw	s3,s1,1
 846:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 848:	00000517          	auipc	a0,0x0
 84c:	7b853503          	ld	a0,1976(a0) # 1000 <freep>
 850:	c915                	beqz	a0,884 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 852:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 854:	4798                	lw	a4,8(a5)
 856:	08977a63          	bgeu	a4,s1,8ea <malloc+0xbe>
 85a:	f04a                	sd	s2,32(sp)
 85c:	e852                	sd	s4,16(sp)
 85e:	e456                	sd	s5,8(sp)
 860:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 862:	8a4e                	mv	s4,s3
 864:	0009871b          	sext.w	a4,s3
 868:	6685                	lui	a3,0x1
 86a:	00d77363          	bgeu	a4,a3,870 <malloc+0x44>
 86e:	6a05                	lui	s4,0x1
 870:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 874:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 878:	00000917          	auipc	s2,0x0
 87c:	78890913          	addi	s2,s2,1928 # 1000 <freep>
  if(p == SBRK_ERROR)
 880:	5afd                	li	s5,-1
 882:	a081                	j	8c2 <malloc+0x96>
 884:	f04a                	sd	s2,32(sp)
 886:	e852                	sd	s4,16(sp)
 888:	e456                	sd	s5,8(sp)
 88a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 88c:	00000797          	auipc	a5,0x0
 890:	78478793          	addi	a5,a5,1924 # 1010 <base>
 894:	00000717          	auipc	a4,0x0
 898:	76f73623          	sd	a5,1900(a4) # 1000 <freep>
 89c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 89e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8a2:	b7c1                	j	862 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8a4:	6398                	ld	a4,0(a5)
 8a6:	e118                	sd	a4,0(a0)
 8a8:	a8a9                	j	902 <malloc+0xd6>
  hp->s.size = nu;
 8aa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ae:	0541                	addi	a0,a0,16
 8b0:	efbff0ef          	jal	7aa <free>
  return freep;
 8b4:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8b8:	c12d                	beqz	a0,91a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ba:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8bc:	4798                	lw	a4,8(a5)
 8be:	02977263          	bgeu	a4,s1,8e2 <malloc+0xb6>
    if(p == freep)
 8c2:	00093703          	ld	a4,0(s2)
 8c6:	853e                	mv	a0,a5
 8c8:	fef719e3          	bne	a4,a5,8ba <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8cc:	8552                	mv	a0,s4
 8ce:	a0fff0ef          	jal	2dc <sbrk>
  if(p == SBRK_ERROR)
 8d2:	fd551ce3          	bne	a0,s5,8aa <malloc+0x7e>
        return 0;
 8d6:	4501                	li	a0,0
 8d8:	7902                	ld	s2,32(sp)
 8da:	6a42                	ld	s4,16(sp)
 8dc:	6aa2                	ld	s5,8(sp)
 8de:	6b02                	ld	s6,0(sp)
 8e0:	a03d                	j	90e <malloc+0xe2>
 8e2:	7902                	ld	s2,32(sp)
 8e4:	6a42                	ld	s4,16(sp)
 8e6:	6aa2                	ld	s5,8(sp)
 8e8:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8ea:	fae48de3          	beq	s1,a4,8a4 <malloc+0x78>
        p->s.size -= nunits;
 8ee:	4137073b          	subw	a4,a4,s3
 8f2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8f4:	02071693          	slli	a3,a4,0x20
 8f8:	01c6d713          	srli	a4,a3,0x1c
 8fc:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8fe:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 902:	00000717          	auipc	a4,0x0
 906:	6ea73f23          	sd	a0,1790(a4) # 1000 <freep>
      return (void*)(p + 1);
 90a:	01078513          	addi	a0,a5,16
  }
}
 90e:	70e2                	ld	ra,56(sp)
 910:	7442                	ld	s0,48(sp)
 912:	74a2                	ld	s1,40(sp)
 914:	69e2                	ld	s3,24(sp)
 916:	6121                	addi	sp,sp,64
 918:	8082                	ret
 91a:	7902                	ld	s2,32(sp)
 91c:	6a42                	ld	s4,16(sp)
 91e:	6aa2                	ld	s5,8(sp)
 920:	6b02                	ld	s6,0(sp)
 922:	b7f5                	j	90e <malloc+0xe2>
