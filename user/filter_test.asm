
user/_filter_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "user/user.h"
#include "kernel/syscall.h" // Nạp các định nghĩa mã số SYS_fork, SYS_write...

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  printf("--- KHOI CHAY TIEN TRINH THU NGHIEM BO LOC ---\n");
   8:	00001517          	auipc	a0,0x1
   c:	8f850513          	addi	a0,a0,-1800 # 900 <malloc+0xf8>
  10:	744000ef          	jal	754 <printf>

  // Thiết lập bitmask: Chỉ cho phép gọi lệnh SYS_exit (2), SYS_write (16) và SYS_set_filter (23)
  // Tất cả các lệnh hệ thống khác bao gồm lệnh nhân bản tiến trình SYS_fork (mã 1) sẽ bị khóa vĩnh viễn!
  uint64 safe_mask = (1L << SYS_exit) | (1L << SYS_write) | (1L << SYS_set_filter);
  
  printf("[INFO] Dang kich hoat mang loc an ninh, khoa toan bo he thong...\n");
  14:	00001517          	auipc	a0,0x1
  18:	91c50513          	addi	a0,a0,-1764 # 930 <malloc+0x128>
  1c:	738000ef          	jal	754 <printf>
  set_filter(safe_mask);
  20:	20010537          	lui	a0,0x20010
  24:	0511                	addi	a0,a0,4 # 20010004 <base+0x2000eff4>
  26:	39e000ef          	jal	3c4 <set_filter>

  printf("[INFO] Thu nghiem goi lenh hop phap (Ghi chuoi ra man hinh)... OK!\n");
  2a:	00001517          	auipc	a0,0x1
  2e:	94e50513          	addi	a0,a0,-1714 # 978 <malloc+0x170>
  32:	722000ef          	jal	754 <printf>

  printf("[ATTACK] Co tinh goi lenh cam (SYS_fork) de kiem tra bo loc...\n");
  36:	00001517          	auipc	a0,0x1
  3a:	98a50513          	addi	a0,a0,-1654 # 9c0 <malloc+0x1b8>
  3e:	716000ef          	jal	754 <printf>
  fork(); // Lệnh fork() có mã số là 1. Bit số 1 trong safe_mask bằng 0 -> Sẽ bị trạm gác tóm gọn!
  42:	2a2000ef          	jal	2e4 <fork>

  // Dòng chữ này sẽ không bao giờ được in ra vì tiến trình đã bị nhân xử tử hình
  printf("[WARNING] THAT BAI: Bo loc he thong da bi qua mat!\n");
  46:	00001517          	auipc	a0,0x1
  4a:	9ba50513          	addi	a0,a0,-1606 # a00 <malloc+0x1f8>
  4e:	706000ef          	jal	754 <printf>
  exit(0);
  52:	4501                	li	a0,0
  54:	298000ef          	jal	2ec <exit>

0000000000000058 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  58:	1141                	addi	sp,sp,-16
  5a:	e406                	sd	ra,8(sp)
  5c:	e022                	sd	s0,0(sp)
  5e:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  60:	fa1ff0ef          	jal	0 <main>
  exit(r);
  64:	288000ef          	jal	2ec <exit>

0000000000000068 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  68:	1141                	addi	sp,sp,-16
  6a:	e422                	sd	s0,8(sp)
  6c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  6e:	87aa                	mv	a5,a0
  70:	0585                	addi	a1,a1,1
  72:	0785                	addi	a5,a5,1
  74:	fff5c703          	lbu	a4,-1(a1)
  78:	fee78fa3          	sb	a4,-1(a5)
  7c:	fb75                	bnez	a4,70 <strcpy+0x8>
    ;
  return os;
}
  7e:	6422                	ld	s0,8(sp)
  80:	0141                	addi	sp,sp,16
  82:	8082                	ret

0000000000000084 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  84:	1141                	addi	sp,sp,-16
  86:	e422                	sd	s0,8(sp)
  88:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  8a:	00054783          	lbu	a5,0(a0)
  8e:	cb91                	beqz	a5,a2 <strcmp+0x1e>
  90:	0005c703          	lbu	a4,0(a1)
  94:	00f71763          	bne	a4,a5,a2 <strcmp+0x1e>
    p++, q++;
  98:	0505                	addi	a0,a0,1
  9a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  9c:	00054783          	lbu	a5,0(a0)
  a0:	fbe5                	bnez	a5,90 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  a2:	0005c503          	lbu	a0,0(a1)
}
  a6:	40a7853b          	subw	a0,a5,a0
  aa:	6422                	ld	s0,8(sp)
  ac:	0141                	addi	sp,sp,16
  ae:	8082                	ret

00000000000000b0 <strlen>:

uint
strlen(const char *s)
{
  b0:	1141                	addi	sp,sp,-16
  b2:	e422                	sd	s0,8(sp)
  b4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  b6:	00054783          	lbu	a5,0(a0)
  ba:	cf91                	beqz	a5,d6 <strlen+0x26>
  bc:	0505                	addi	a0,a0,1
  be:	87aa                	mv	a5,a0
  c0:	86be                	mv	a3,a5
  c2:	0785                	addi	a5,a5,1
  c4:	fff7c703          	lbu	a4,-1(a5)
  c8:	ff65                	bnez	a4,c0 <strlen+0x10>
  ca:	40a6853b          	subw	a0,a3,a0
  ce:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret
  for(n = 0; s[n]; n++)
  d6:	4501                	li	a0,0
  d8:	bfe5                	j	d0 <strlen+0x20>

00000000000000da <memset>:

void*
memset(void *dst, int c, uint n)
{
  da:	1141                	addi	sp,sp,-16
  dc:	e422                	sd	s0,8(sp)
  de:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  e0:	ca19                	beqz	a2,f6 <memset+0x1c>
  e2:	87aa                	mv	a5,a0
  e4:	1602                	slli	a2,a2,0x20
  e6:	9201                	srli	a2,a2,0x20
  e8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  ec:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  f0:	0785                	addi	a5,a5,1
  f2:	fee79de3          	bne	a5,a4,ec <memset+0x12>
  }
  return dst;
}
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret

00000000000000fc <strchr>:

char*
strchr(const char *s, char c)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  for(; *s; s++)
 102:	00054783          	lbu	a5,0(a0)
 106:	cb99                	beqz	a5,11c <strchr+0x20>
    if(*s == c)
 108:	00f58763          	beq	a1,a5,116 <strchr+0x1a>
  for(; *s; s++)
 10c:	0505                	addi	a0,a0,1
 10e:	00054783          	lbu	a5,0(a0)
 112:	fbfd                	bnez	a5,108 <strchr+0xc>
      return (char*)s;
  return 0;
 114:	4501                	li	a0,0
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret
  return 0;
 11c:	4501                	li	a0,0
 11e:	bfe5                	j	116 <strchr+0x1a>

0000000000000120 <gets>:

char*
gets(char *buf, int max)
{
 120:	711d                	addi	sp,sp,-96
 122:	ec86                	sd	ra,88(sp)
 124:	e8a2                	sd	s0,80(sp)
 126:	e4a6                	sd	s1,72(sp)
 128:	e0ca                	sd	s2,64(sp)
 12a:	fc4e                	sd	s3,56(sp)
 12c:	f852                	sd	s4,48(sp)
 12e:	f456                	sd	s5,40(sp)
 130:	f05a                	sd	s6,32(sp)
 132:	ec5e                	sd	s7,24(sp)
 134:	1080                	addi	s0,sp,96
 136:	8baa                	mv	s7,a0
 138:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13a:	892a                	mv	s2,a0
 13c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 13e:	4aa9                	li	s5,10
 140:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 142:	89a6                	mv	s3,s1
 144:	2485                	addiw	s1,s1,1
 146:	0344d663          	bge	s1,s4,172 <gets+0x52>
    cc = read(0, &c, 1);
 14a:	4605                	li	a2,1
 14c:	faf40593          	addi	a1,s0,-81
 150:	4501                	li	a0,0
 152:	1b2000ef          	jal	304 <read>
    if(cc < 1)
 156:	00a05e63          	blez	a0,172 <gets+0x52>
    buf[i++] = c;
 15a:	faf44783          	lbu	a5,-81(s0)
 15e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 162:	01578763          	beq	a5,s5,170 <gets+0x50>
 166:	0905                	addi	s2,s2,1
 168:	fd679de3          	bne	a5,s6,142 <gets+0x22>
    buf[i++] = c;
 16c:	89a6                	mv	s3,s1
 16e:	a011                	j	172 <gets+0x52>
 170:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 172:	99de                	add	s3,s3,s7
 174:	00098023          	sb	zero,0(s3)
  return buf;
}
 178:	855e                	mv	a0,s7
 17a:	60e6                	ld	ra,88(sp)
 17c:	6446                	ld	s0,80(sp)
 17e:	64a6                	ld	s1,72(sp)
 180:	6906                	ld	s2,64(sp)
 182:	79e2                	ld	s3,56(sp)
 184:	7a42                	ld	s4,48(sp)
 186:	7aa2                	ld	s5,40(sp)
 188:	7b02                	ld	s6,32(sp)
 18a:	6be2                	ld	s7,24(sp)
 18c:	6125                	addi	sp,sp,96
 18e:	8082                	ret

0000000000000190 <stat>:

int
stat(const char *n, struct stat *st)
{
 190:	1101                	addi	sp,sp,-32
 192:	ec06                	sd	ra,24(sp)
 194:	e822                	sd	s0,16(sp)
 196:	e04a                	sd	s2,0(sp)
 198:	1000                	addi	s0,sp,32
 19a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 19c:	4581                	li	a1,0
 19e:	18e000ef          	jal	32c <open>
  if(fd < 0)
 1a2:	02054263          	bltz	a0,1c6 <stat+0x36>
 1a6:	e426                	sd	s1,8(sp)
 1a8:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1aa:	85ca                	mv	a1,s2
 1ac:	198000ef          	jal	344 <fstat>
 1b0:	892a                	mv	s2,a0
  close(fd);
 1b2:	8526                	mv	a0,s1
 1b4:	160000ef          	jal	314 <close>
  return r;
 1b8:	64a2                	ld	s1,8(sp)
}
 1ba:	854a                	mv	a0,s2
 1bc:	60e2                	ld	ra,24(sp)
 1be:	6442                	ld	s0,16(sp)
 1c0:	6902                	ld	s2,0(sp)
 1c2:	6105                	addi	sp,sp,32
 1c4:	8082                	ret
    return -1;
 1c6:	597d                	li	s2,-1
 1c8:	bfcd                	j	1ba <stat+0x2a>

00000000000001ca <atoi>:

int
atoi(const char *s)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d0:	00054683          	lbu	a3,0(a0)
 1d4:	fd06879b          	addiw	a5,a3,-48
 1d8:	0ff7f793          	zext.b	a5,a5
 1dc:	4625                	li	a2,9
 1de:	02f66863          	bltu	a2,a5,20e <atoi+0x44>
 1e2:	872a                	mv	a4,a0
  n = 0;
 1e4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1e6:	0705                	addi	a4,a4,1
 1e8:	0025179b          	slliw	a5,a0,0x2
 1ec:	9fa9                	addw	a5,a5,a0
 1ee:	0017979b          	slliw	a5,a5,0x1
 1f2:	9fb5                	addw	a5,a5,a3
 1f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f8:	00074683          	lbu	a3,0(a4)
 1fc:	fd06879b          	addiw	a5,a3,-48
 200:	0ff7f793          	zext.b	a5,a5
 204:	fef671e3          	bgeu	a2,a5,1e6 <atoi+0x1c>
  return n;
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  n = 0;
 20e:	4501                	li	a0,0
 210:	bfe5                	j	208 <atoi+0x3e>

0000000000000212 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 218:	02b57463          	bgeu	a0,a1,240 <memmove+0x2e>
    while(n-- > 0)
 21c:	00c05f63          	blez	a2,23a <memmove+0x28>
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 228:	872a                	mv	a4,a0
      *dst++ = *src++;
 22a:	0585                	addi	a1,a1,1
 22c:	0705                	addi	a4,a4,1
 22e:	fff5c683          	lbu	a3,-1(a1)
 232:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 236:	fef71ae3          	bne	a4,a5,22a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
    dst += n;
 240:	00c50733          	add	a4,a0,a2
    src += n;
 244:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 246:	fec05ae3          	blez	a2,23a <memmove+0x28>
 24a:	fff6079b          	addiw	a5,a2,-1
 24e:	1782                	slli	a5,a5,0x20
 250:	9381                	srli	a5,a5,0x20
 252:	fff7c793          	not	a5,a5
 256:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 258:	15fd                	addi	a1,a1,-1
 25a:	177d                	addi	a4,a4,-1
 25c:	0005c683          	lbu	a3,0(a1)
 260:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 264:	fee79ae3          	bne	a5,a4,258 <memmove+0x46>
 268:	bfc9                	j	23a <memmove+0x28>

000000000000026a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 270:	ca05                	beqz	a2,2a0 <memcmp+0x36>
 272:	fff6069b          	addiw	a3,a2,-1
 276:	1682                	slli	a3,a3,0x20
 278:	9281                	srli	a3,a3,0x20
 27a:	0685                	addi	a3,a3,1
 27c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 27e:	00054783          	lbu	a5,0(a0)
 282:	0005c703          	lbu	a4,0(a1)
 286:	00e79863          	bne	a5,a4,296 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 28a:	0505                	addi	a0,a0,1
    p2++;
 28c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 28e:	fed518e3          	bne	a0,a3,27e <memcmp+0x14>
  }
  return 0;
 292:	4501                	li	a0,0
 294:	a019                	j	29a <memcmp+0x30>
      return *p1 - *p2;
 296:	40e7853b          	subw	a0,a5,a4
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret
  return 0;
 2a0:	4501                	li	a0,0
 2a2:	bfe5                	j	29a <memcmp+0x30>

00000000000002a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e406                	sd	ra,8(sp)
 2a8:	e022                	sd	s0,0(sp)
 2aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ac:	f67ff0ef          	jal	212 <memmove>
}
 2b0:	60a2                	ld	ra,8(sp)
 2b2:	6402                	ld	s0,0(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret

00000000000002b8 <sbrk>:

char *
sbrk(int n) {
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2c0:	4585                	li	a1,1
 2c2:	0b2000ef          	jal	374 <sys_sbrk>
}
 2c6:	60a2                	ld	ra,8(sp)
 2c8:	6402                	ld	s0,0(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret

00000000000002ce <sbrklazy>:

char *
sbrklazy(int n) {
 2ce:	1141                	addi	sp,sp,-16
 2d0:	e406                	sd	ra,8(sp)
 2d2:	e022                	sd	s0,0(sp)
 2d4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2d6:	4589                	li	a1,2
 2d8:	09c000ef          	jal	374 <sys_sbrk>
}
 2dc:	60a2                	ld	ra,8(sp)
 2de:	6402                	ld	s0,0(sp)
 2e0:	0141                	addi	sp,sp,16
 2e2:	8082                	ret

00000000000002e4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2e4:	4885                	li	a7,1
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <exit>:
.global exit
exit:
 li a7, SYS_exit
 2ec:	4889                	li	a7,2
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2f4:	488d                	li	a7,3
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2fc:	4891                	li	a7,4
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <read>:
.global read
read:
 li a7, SYS_read
 304:	4895                	li	a7,5
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <write>:
.global write
write:
 li a7, SYS_write
 30c:	48c1                	li	a7,16
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <close>:
.global close
close:
 li a7, SYS_close
 314:	48d5                	li	a7,21
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <kill>:
.global kill
kill:
 li a7, SYS_kill
 31c:	4899                	li	a7,6
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <exec>:
.global exec
exec:
 li a7, SYS_exec
 324:	489d                	li	a7,7
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <open>:
.global open
open:
 li a7, SYS_open
 32c:	48bd                	li	a7,15
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 334:	48c5                	li	a7,17
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 33c:	48c9                	li	a7,18
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 344:	48a1                	li	a7,8
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <link>:
.global link
link:
 li a7, SYS_link
 34c:	48cd                	li	a7,19
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 354:	48d1                	li	a7,20
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 35c:	48a5                	li	a7,9
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <dup>:
.global dup
dup:
 li a7, SYS_dup
 364:	48a9                	li	a7,10
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 36c:	48ad                	li	a7,11
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 374:	48b1                	li	a7,12
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <pause>:
.global pause
pause:
 li a7, SYS_pause
 37c:	48b5                	li	a7,13
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 384:	48b9                	li	a7,14
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <hello>:
.global hello
hello:
 li a7, SYS_hello
 38c:	48d9                	li	a7,22
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <ps>:
.global ps
ps:
 li a7, SYS_ps
 394:	48dd                	li	a7,23
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <memtest>:
.global memtest
memtest:
 li a7, SYS_memtest
 39c:	48e1                	li	a7,24
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <testnolock>:
.global testnolock
testnolock:
 li a7, SYS_testnolock
 3a4:	48e5                	li	a7,25
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 3ac:	48e9                	li	a7,26
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <nullcall>:
.global nullcall
nullcall:
 li a7, SYS_nullcall
 3b4:	48ed                	li	a7,27
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <getcycles>:
.global getcycles
getcycles:
 li a7, SYS_getcycles
 3bc:	48f1                	li	a7,28
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <set_filter>:
.global set_filter
set_filter:
 li a7, SYS_set_filter
 3c4:	48f5                	li	a7,29
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3cc:	1101                	addi	sp,sp,-32
 3ce:	ec06                	sd	ra,24(sp)
 3d0:	e822                	sd	s0,16(sp)
 3d2:	1000                	addi	s0,sp,32
 3d4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3d8:	4605                	li	a2,1
 3da:	fef40593          	addi	a1,s0,-17
 3de:	f2fff0ef          	jal	30c <write>
}
 3e2:	60e2                	ld	ra,24(sp)
 3e4:	6442                	ld	s0,16(sp)
 3e6:	6105                	addi	sp,sp,32
 3e8:	8082                	ret

00000000000003ea <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3ea:	715d                	addi	sp,sp,-80
 3ec:	e486                	sd	ra,72(sp)
 3ee:	e0a2                	sd	s0,64(sp)
 3f0:	f84a                	sd	s2,48(sp)
 3f2:	0880                	addi	s0,sp,80
 3f4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3f6:	c299                	beqz	a3,3fc <printint+0x12>
 3f8:	0805c363          	bltz	a1,47e <printint+0x94>
  neg = 0;
 3fc:	4881                	li	a7,0
 3fe:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 402:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 404:	00000517          	auipc	a0,0x0
 408:	63c50513          	addi	a0,a0,1596 # a40 <digits>
 40c:	883e                	mv	a6,a5
 40e:	2785                	addiw	a5,a5,1
 410:	02c5f733          	remu	a4,a1,a2
 414:	972a                	add	a4,a4,a0
 416:	00074703          	lbu	a4,0(a4)
 41a:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 41e:	872e                	mv	a4,a1
 420:	02c5d5b3          	divu	a1,a1,a2
 424:	0685                	addi	a3,a3,1
 426:	fec773e3          	bgeu	a4,a2,40c <printint+0x22>
  if(neg)
 42a:	00088b63          	beqz	a7,440 <printint+0x56>
    buf[i++] = '-';
 42e:	fd078793          	addi	a5,a5,-48
 432:	97a2                	add	a5,a5,s0
 434:	02d00713          	li	a4,45
 438:	fee78423          	sb	a4,-24(a5)
 43c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 440:	02f05a63          	blez	a5,474 <printint+0x8a>
 444:	fc26                	sd	s1,56(sp)
 446:	f44e                	sd	s3,40(sp)
 448:	fb840713          	addi	a4,s0,-72
 44c:	00f704b3          	add	s1,a4,a5
 450:	fff70993          	addi	s3,a4,-1
 454:	99be                	add	s3,s3,a5
 456:	37fd                	addiw	a5,a5,-1
 458:	1782                	slli	a5,a5,0x20
 45a:	9381                	srli	a5,a5,0x20
 45c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 460:	fff4c583          	lbu	a1,-1(s1)
 464:	854a                	mv	a0,s2
 466:	f67ff0ef          	jal	3cc <putc>
  while(--i >= 0)
 46a:	14fd                	addi	s1,s1,-1
 46c:	ff349ae3          	bne	s1,s3,460 <printint+0x76>
 470:	74e2                	ld	s1,56(sp)
 472:	79a2                	ld	s3,40(sp)
}
 474:	60a6                	ld	ra,72(sp)
 476:	6406                	ld	s0,64(sp)
 478:	7942                	ld	s2,48(sp)
 47a:	6161                	addi	sp,sp,80
 47c:	8082                	ret
    x = -xx;
 47e:	40b005b3          	neg	a1,a1
    neg = 1;
 482:	4885                	li	a7,1
    x = -xx;
 484:	bfad                	j	3fe <printint+0x14>

0000000000000486 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 486:	711d                	addi	sp,sp,-96
 488:	ec86                	sd	ra,88(sp)
 48a:	e8a2                	sd	s0,80(sp)
 48c:	e0ca                	sd	s2,64(sp)
 48e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 490:	0005c903          	lbu	s2,0(a1)
 494:	28090663          	beqz	s2,720 <vprintf+0x29a>
 498:	e4a6                	sd	s1,72(sp)
 49a:	fc4e                	sd	s3,56(sp)
 49c:	f852                	sd	s4,48(sp)
 49e:	f456                	sd	s5,40(sp)
 4a0:	f05a                	sd	s6,32(sp)
 4a2:	ec5e                	sd	s7,24(sp)
 4a4:	e862                	sd	s8,16(sp)
 4a6:	e466                	sd	s9,8(sp)
 4a8:	8b2a                	mv	s6,a0
 4aa:	8a2e                	mv	s4,a1
 4ac:	8bb2                	mv	s7,a2
  state = 0;
 4ae:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4b0:	4481                	li	s1,0
 4b2:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4b4:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4b8:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4bc:	06c00c93          	li	s9,108
 4c0:	a005                	j	4e0 <vprintf+0x5a>
        putc(fd, c0);
 4c2:	85ca                	mv	a1,s2
 4c4:	855a                	mv	a0,s6
 4c6:	f07ff0ef          	jal	3cc <putc>
 4ca:	a019                	j	4d0 <vprintf+0x4a>
    } else if(state == '%'){
 4cc:	03598263          	beq	s3,s5,4f0 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4d0:	2485                	addiw	s1,s1,1
 4d2:	8726                	mv	a4,s1
 4d4:	009a07b3          	add	a5,s4,s1
 4d8:	0007c903          	lbu	s2,0(a5)
 4dc:	22090a63          	beqz	s2,710 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4e0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4e4:	fe0994e3          	bnez	s3,4cc <vprintf+0x46>
      if(c0 == '%'){
 4e8:	fd579de3          	bne	a5,s5,4c2 <vprintf+0x3c>
        state = '%';
 4ec:	89be                	mv	s3,a5
 4ee:	b7cd                	j	4d0 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4f0:	00ea06b3          	add	a3,s4,a4
 4f4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4f8:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4fa:	c681                	beqz	a3,502 <vprintf+0x7c>
 4fc:	9752                	add	a4,a4,s4
 4fe:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 502:	05878363          	beq	a5,s8,548 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 506:	05978d63          	beq	a5,s9,560 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 50a:	07500713          	li	a4,117
 50e:	0ee78763          	beq	a5,a4,5fc <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 512:	07800713          	li	a4,120
 516:	12e78963          	beq	a5,a4,648 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 51a:	07000713          	li	a4,112
 51e:	14e78e63          	beq	a5,a4,67a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 522:	06300713          	li	a4,99
 526:	18e78e63          	beq	a5,a4,6c2 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 52a:	07300713          	li	a4,115
 52e:	1ae78463          	beq	a5,a4,6d6 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 532:	02500713          	li	a4,37
 536:	04e79563          	bne	a5,a4,580 <vprintf+0xfa>
        putc(fd, '%');
 53a:	02500593          	li	a1,37
 53e:	855a                	mv	a0,s6
 540:	e8dff0ef          	jal	3cc <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 544:	4981                	li	s3,0
 546:	b769                	j	4d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 548:	008b8913          	addi	s2,s7,8
 54c:	4685                	li	a3,1
 54e:	4629                	li	a2,10
 550:	000ba583          	lw	a1,0(s7)
 554:	855a                	mv	a0,s6
 556:	e95ff0ef          	jal	3ea <printint>
 55a:	8bca                	mv	s7,s2
      state = 0;
 55c:	4981                	li	s3,0
 55e:	bf8d                	j	4d0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 560:	06400793          	li	a5,100
 564:	02f68963          	beq	a3,a5,596 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 568:	06c00793          	li	a5,108
 56c:	04f68263          	beq	a3,a5,5b0 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 570:	07500793          	li	a5,117
 574:	0af68063          	beq	a3,a5,614 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 578:	07800793          	li	a5,120
 57c:	0ef68263          	beq	a3,a5,660 <vprintf+0x1da>
        putc(fd, '%');
 580:	02500593          	li	a1,37
 584:	855a                	mv	a0,s6
 586:	e47ff0ef          	jal	3cc <putc>
        putc(fd, c0);
 58a:	85ca                	mv	a1,s2
 58c:	855a                	mv	a0,s6
 58e:	e3fff0ef          	jal	3cc <putc>
      state = 0;
 592:	4981                	li	s3,0
 594:	bf35                	j	4d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 596:	008b8913          	addi	s2,s7,8
 59a:	4685                	li	a3,1
 59c:	4629                	li	a2,10
 59e:	000bb583          	ld	a1,0(s7)
 5a2:	855a                	mv	a0,s6
 5a4:	e47ff0ef          	jal	3ea <printint>
        i += 1;
 5a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5aa:	8bca                	mv	s7,s2
      state = 0;
 5ac:	4981                	li	s3,0
        i += 1;
 5ae:	b70d                	j	4d0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5b0:	06400793          	li	a5,100
 5b4:	02f60763          	beq	a2,a5,5e2 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5b8:	07500793          	li	a5,117
 5bc:	06f60963          	beq	a2,a5,62e <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5c0:	07800793          	li	a5,120
 5c4:	faf61ee3          	bne	a2,a5,580 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c8:	008b8913          	addi	s2,s7,8
 5cc:	4681                	li	a3,0
 5ce:	4641                	li	a2,16
 5d0:	000bb583          	ld	a1,0(s7)
 5d4:	855a                	mv	a0,s6
 5d6:	e15ff0ef          	jal	3ea <printint>
        i += 2;
 5da:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
        i += 2;
 5e0:	bdc5                	j	4d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4685                	li	a3,1
 5e8:	4629                	li	a2,10
 5ea:	000bb583          	ld	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	dfbff0ef          	jal	3ea <printint>
        i += 2;
 5f4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
        i += 2;
 5fa:	bdd9                	j	4d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4681                	li	a3,0
 602:	4629                	li	a2,10
 604:	000be583          	lwu	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	de1ff0ef          	jal	3ea <printint>
 60e:	8bca                	mv	s7,s2
      state = 0;
 610:	4981                	li	s3,0
 612:	bd7d                	j	4d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 614:	008b8913          	addi	s2,s7,8
 618:	4681                	li	a3,0
 61a:	4629                	li	a2,10
 61c:	000bb583          	ld	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	dc9ff0ef          	jal	3ea <printint>
        i += 1;
 626:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 628:	8bca                	mv	s7,s2
      state = 0;
 62a:	4981                	li	s3,0
        i += 1;
 62c:	b555                	j	4d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 62e:	008b8913          	addi	s2,s7,8
 632:	4681                	li	a3,0
 634:	4629                	li	a2,10
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	dafff0ef          	jal	3ea <printint>
        i += 2;
 640:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 2;
 646:	b569                	j	4d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4641                	li	a2,16
 650:	000be583          	lwu	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	d95ff0ef          	jal	3ea <printint>
 65a:	8bca                	mv	s7,s2
      state = 0;
 65c:	4981                	li	s3,0
 65e:	bd8d                	j	4d0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 660:	008b8913          	addi	s2,s7,8
 664:	4681                	li	a3,0
 666:	4641                	li	a2,16
 668:	000bb583          	ld	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	d7dff0ef          	jal	3ea <printint>
        i += 1;
 672:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
        i += 1;
 678:	bda1                	j	4d0 <vprintf+0x4a>
 67a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 67c:	008b8d13          	addi	s10,s7,8
 680:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 684:	03000593          	li	a1,48
 688:	855a                	mv	a0,s6
 68a:	d43ff0ef          	jal	3cc <putc>
  putc(fd, 'x');
 68e:	07800593          	li	a1,120
 692:	855a                	mv	a0,s6
 694:	d39ff0ef          	jal	3cc <putc>
 698:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 69a:	00000b97          	auipc	s7,0x0
 69e:	3a6b8b93          	addi	s7,s7,934 # a40 <digits>
 6a2:	03c9d793          	srli	a5,s3,0x3c
 6a6:	97de                	add	a5,a5,s7
 6a8:	0007c583          	lbu	a1,0(a5)
 6ac:	855a                	mv	a0,s6
 6ae:	d1fff0ef          	jal	3cc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6b2:	0992                	slli	s3,s3,0x4
 6b4:	397d                	addiw	s2,s2,-1
 6b6:	fe0916e3          	bnez	s2,6a2 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6ba:	8bea                	mv	s7,s10
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	6d02                	ld	s10,0(sp)
 6c0:	bd01                	j	4d0 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6c2:	008b8913          	addi	s2,s7,8
 6c6:	000bc583          	lbu	a1,0(s7)
 6ca:	855a                	mv	a0,s6
 6cc:	d01ff0ef          	jal	3cc <putc>
 6d0:	8bca                	mv	s7,s2
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	bbf5                	j	4d0 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6d6:	008b8993          	addi	s3,s7,8
 6da:	000bb903          	ld	s2,0(s7)
 6de:	00090f63          	beqz	s2,6fc <vprintf+0x276>
        for(; *s; s++)
 6e2:	00094583          	lbu	a1,0(s2)
 6e6:	c195                	beqz	a1,70a <vprintf+0x284>
          putc(fd, *s);
 6e8:	855a                	mv	a0,s6
 6ea:	ce3ff0ef          	jal	3cc <putc>
        for(; *s; s++)
 6ee:	0905                	addi	s2,s2,1
 6f0:	00094583          	lbu	a1,0(s2)
 6f4:	f9f5                	bnez	a1,6e8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6f6:	8bce                	mv	s7,s3
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bbd9                	j	4d0 <vprintf+0x4a>
          s = "(null)";
 6fc:	00000917          	auipc	s2,0x0
 700:	33c90913          	addi	s2,s2,828 # a38 <malloc+0x230>
        for(; *s; s++)
 704:	02800593          	li	a1,40
 708:	b7c5                	j	6e8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 70a:	8bce                	mv	s7,s3
      state = 0;
 70c:	4981                	li	s3,0
 70e:	b3c9                	j	4d0 <vprintf+0x4a>
 710:	64a6                	ld	s1,72(sp)
 712:	79e2                	ld	s3,56(sp)
 714:	7a42                	ld	s4,48(sp)
 716:	7aa2                	ld	s5,40(sp)
 718:	7b02                	ld	s6,32(sp)
 71a:	6be2                	ld	s7,24(sp)
 71c:	6c42                	ld	s8,16(sp)
 71e:	6ca2                	ld	s9,8(sp)
    }
  }
}
 720:	60e6                	ld	ra,88(sp)
 722:	6446                	ld	s0,80(sp)
 724:	6906                	ld	s2,64(sp)
 726:	6125                	addi	sp,sp,96
 728:	8082                	ret

000000000000072a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 72a:	715d                	addi	sp,sp,-80
 72c:	ec06                	sd	ra,24(sp)
 72e:	e822                	sd	s0,16(sp)
 730:	1000                	addi	s0,sp,32
 732:	e010                	sd	a2,0(s0)
 734:	e414                	sd	a3,8(s0)
 736:	e818                	sd	a4,16(s0)
 738:	ec1c                	sd	a5,24(s0)
 73a:	03043023          	sd	a6,32(s0)
 73e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 742:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 746:	8622                	mv	a2,s0
 748:	d3fff0ef          	jal	486 <vprintf>
}
 74c:	60e2                	ld	ra,24(sp)
 74e:	6442                	ld	s0,16(sp)
 750:	6161                	addi	sp,sp,80
 752:	8082                	ret

0000000000000754 <printf>:

void
printf(const char *fmt, ...)
{
 754:	711d                	addi	sp,sp,-96
 756:	ec06                	sd	ra,24(sp)
 758:	e822                	sd	s0,16(sp)
 75a:	1000                	addi	s0,sp,32
 75c:	e40c                	sd	a1,8(s0)
 75e:	e810                	sd	a2,16(s0)
 760:	ec14                	sd	a3,24(s0)
 762:	f018                	sd	a4,32(s0)
 764:	f41c                	sd	a5,40(s0)
 766:	03043823          	sd	a6,48(s0)
 76a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 76e:	00840613          	addi	a2,s0,8
 772:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 776:	85aa                	mv	a1,a0
 778:	4505                	li	a0,1
 77a:	d0dff0ef          	jal	486 <vprintf>
}
 77e:	60e2                	ld	ra,24(sp)
 780:	6442                	ld	s0,16(sp)
 782:	6125                	addi	sp,sp,96
 784:	8082                	ret

0000000000000786 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 786:	1141                	addi	sp,sp,-16
 788:	e422                	sd	s0,8(sp)
 78a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 78c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 790:	00001797          	auipc	a5,0x1
 794:	8707b783          	ld	a5,-1936(a5) # 1000 <freep>
 798:	a02d                	j	7c2 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 79a:	4618                	lw	a4,8(a2)
 79c:	9f2d                	addw	a4,a4,a1
 79e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7a2:	6398                	ld	a4,0(a5)
 7a4:	6310                	ld	a2,0(a4)
 7a6:	a83d                	j	7e4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a8:	ff852703          	lw	a4,-8(a0)
 7ac:	9f31                	addw	a4,a4,a2
 7ae:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7b0:	ff053683          	ld	a3,-16(a0)
 7b4:	a091                	j	7f8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b6:	6398                	ld	a4,0(a5)
 7b8:	00e7e463          	bltu	a5,a4,7c0 <free+0x3a>
 7bc:	00e6ea63          	bltu	a3,a4,7d0 <free+0x4a>
{
 7c0:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7c2:	fed7fae3          	bgeu	a5,a3,7b6 <free+0x30>
 7c6:	6398                	ld	a4,0(a5)
 7c8:	00e6e463          	bltu	a3,a4,7d0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7cc:	fee7eae3          	bltu	a5,a4,7c0 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7d0:	ff852583          	lw	a1,-8(a0)
 7d4:	6390                	ld	a2,0(a5)
 7d6:	02059813          	slli	a6,a1,0x20
 7da:	01c85713          	srli	a4,a6,0x1c
 7de:	9736                	add	a4,a4,a3
 7e0:	fae60de3          	beq	a2,a4,79a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7e4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e8:	4790                	lw	a2,8(a5)
 7ea:	02061593          	slli	a1,a2,0x20
 7ee:	01c5d713          	srli	a4,a1,0x1c
 7f2:	973e                	add	a4,a4,a5
 7f4:	fae68ae3          	beq	a3,a4,7a8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7f8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7fa:	00001717          	auipc	a4,0x1
 7fe:	80f73323          	sd	a5,-2042(a4) # 1000 <freep>
}
 802:	6422                	ld	s0,8(sp)
 804:	0141                	addi	sp,sp,16
 806:	8082                	ret

0000000000000808 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 808:	7139                	addi	sp,sp,-64
 80a:	fc06                	sd	ra,56(sp)
 80c:	f822                	sd	s0,48(sp)
 80e:	f426                	sd	s1,40(sp)
 810:	ec4e                	sd	s3,24(sp)
 812:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 814:	02051493          	slli	s1,a0,0x20
 818:	9081                	srli	s1,s1,0x20
 81a:	04bd                	addi	s1,s1,15
 81c:	8091                	srli	s1,s1,0x4
 81e:	0014899b          	addiw	s3,s1,1
 822:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 824:	00000517          	auipc	a0,0x0
 828:	7dc53503          	ld	a0,2012(a0) # 1000 <freep>
 82c:	c915                	beqz	a0,860 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 830:	4798                	lw	a4,8(a5)
 832:	08977a63          	bgeu	a4,s1,8c6 <malloc+0xbe>
 836:	f04a                	sd	s2,32(sp)
 838:	e852                	sd	s4,16(sp)
 83a:	e456                	sd	s5,8(sp)
 83c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 83e:	8a4e                	mv	s4,s3
 840:	0009871b          	sext.w	a4,s3
 844:	6685                	lui	a3,0x1
 846:	00d77363          	bgeu	a4,a3,84c <malloc+0x44>
 84a:	6a05                	lui	s4,0x1
 84c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 850:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 854:	00000917          	auipc	s2,0x0
 858:	7ac90913          	addi	s2,s2,1964 # 1000 <freep>
  if(p == SBRK_ERROR)
 85c:	5afd                	li	s5,-1
 85e:	a081                	j	89e <malloc+0x96>
 860:	f04a                	sd	s2,32(sp)
 862:	e852                	sd	s4,16(sp)
 864:	e456                	sd	s5,8(sp)
 866:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 868:	00000797          	auipc	a5,0x0
 86c:	7a878793          	addi	a5,a5,1960 # 1010 <base>
 870:	00000717          	auipc	a4,0x0
 874:	78f73823          	sd	a5,1936(a4) # 1000 <freep>
 878:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 87a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 87e:	b7c1                	j	83e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 880:	6398                	ld	a4,0(a5)
 882:	e118                	sd	a4,0(a0)
 884:	a8a9                	j	8de <malloc+0xd6>
  hp->s.size = nu;
 886:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 88a:	0541                	addi	a0,a0,16
 88c:	efbff0ef          	jal	786 <free>
  return freep;
 890:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 894:	c12d                	beqz	a0,8f6 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 896:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 898:	4798                	lw	a4,8(a5)
 89a:	02977263          	bgeu	a4,s1,8be <malloc+0xb6>
    if(p == freep)
 89e:	00093703          	ld	a4,0(s2)
 8a2:	853e                	mv	a0,a5
 8a4:	fef719e3          	bne	a4,a5,896 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8a8:	8552                	mv	a0,s4
 8aa:	a0fff0ef          	jal	2b8 <sbrk>
  if(p == SBRK_ERROR)
 8ae:	fd551ce3          	bne	a0,s5,886 <malloc+0x7e>
        return 0;
 8b2:	4501                	li	a0,0
 8b4:	7902                	ld	s2,32(sp)
 8b6:	6a42                	ld	s4,16(sp)
 8b8:	6aa2                	ld	s5,8(sp)
 8ba:	6b02                	ld	s6,0(sp)
 8bc:	a03d                	j	8ea <malloc+0xe2>
 8be:	7902                	ld	s2,32(sp)
 8c0:	6a42                	ld	s4,16(sp)
 8c2:	6aa2                	ld	s5,8(sp)
 8c4:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8c6:	fae48de3          	beq	s1,a4,880 <malloc+0x78>
        p->s.size -= nunits;
 8ca:	4137073b          	subw	a4,a4,s3
 8ce:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d0:	02071693          	slli	a3,a4,0x20
 8d4:	01c6d713          	srli	a4,a3,0x1c
 8d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8de:	00000717          	auipc	a4,0x0
 8e2:	72a73123          	sd	a0,1826(a4) # 1000 <freep>
      return (void*)(p + 1);
 8e6:	01078513          	addi	a0,a5,16
  }
}
 8ea:	70e2                	ld	ra,56(sp)
 8ec:	7442                	ld	s0,48(sp)
 8ee:	74a2                	ld	s1,40(sp)
 8f0:	69e2                	ld	s3,24(sp)
 8f2:	6121                	addi	sp,sp,64
 8f4:	8082                	ret
 8f6:	7902                	ld	s2,32(sp)
 8f8:	6a42                	ld	s4,16(sp)
 8fa:	6aa2                	ld	s5,8(sp)
 8fc:	6b02                	ld	s6,0(sp)
 8fe:	b7f5                	j	8ea <malloc+0xe2>
