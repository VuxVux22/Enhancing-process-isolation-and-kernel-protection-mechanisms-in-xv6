
user/_poc_attack:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  // Trong RISC-V Xv6, địa chỉ Kernel thường bắt đầu từ vùng cao.
  // Ví dụ: 0x80000000 là nơi chứa code của Kernel.
  uint64 kernel_addr = 0x80000000; 

  // Thêm (void *) trước kernel_addr
printf("PoC: Dang co gang truy cap vao vung nho Kernel tai: %p...\n", (void *)kernel_addr);
   8:	4585                	li	a1,1
   a:	05fe                	slli	a1,a1,0x1f
   c:	00001517          	auipc	a0,0x1
  10:	8d450513          	addi	a0,a0,-1836 # 8e0 <malloc+0xfe>
  14:	71a000ef          	jal	72e <printf>

  // Coi địa chỉ đó là một con trỏ kiểu char và thử đọc giá trị tại đó
  char *p = (char *)kernel_addr;
  char value = *p; 
  18:	4785                	li	a5,1
  1a:	07fe                	slli	a5,a5,0x1f

  // Nếu dòng này được in ra, nghia la he thong da bi "hack" thanh cong (rat kho xay ra)
  printf("PoC: Doc duoc gia tri: %x (Neu thay dong nay, Kernel dang bi ho!)\n", value);
  1c:	0007c583          	lbu	a1,0(a5)
  20:	00001517          	auipc	a0,0x1
  24:	90050513          	addi	a0,a0,-1792 # 920 <malloc+0x13e>
  28:	706000ef          	jal	72e <printf>

  exit(0);
  2c:	4501                	li	a0,0
  2e:	298000ef          	jal	2c6 <exit>

0000000000000032 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  32:	1141                	addi	sp,sp,-16
  34:	e406                	sd	ra,8(sp)
  36:	e022                	sd	s0,0(sp)
  38:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  3a:	fc7ff0ef          	jal	0 <main>
  exit(r);
  3e:	288000ef          	jal	2c6 <exit>

0000000000000042 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  42:	1141                	addi	sp,sp,-16
  44:	e422                	sd	s0,8(sp)
  46:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  48:	87aa                	mv	a5,a0
  4a:	0585                	addi	a1,a1,1
  4c:	0785                	addi	a5,a5,1
  4e:	fff5c703          	lbu	a4,-1(a1)
  52:	fee78fa3          	sb	a4,-1(a5)
  56:	fb75                	bnez	a4,4a <strcpy+0x8>
    ;
  return os;
}
  58:	6422                	ld	s0,8(sp)
  5a:	0141                	addi	sp,sp,16
  5c:	8082                	ret

000000000000005e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  5e:	1141                	addi	sp,sp,-16
  60:	e422                	sd	s0,8(sp)
  62:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  64:	00054783          	lbu	a5,0(a0)
  68:	cb91                	beqz	a5,7c <strcmp+0x1e>
  6a:	0005c703          	lbu	a4,0(a1)
  6e:	00f71763          	bne	a4,a5,7c <strcmp+0x1e>
    p++, q++;
  72:	0505                	addi	a0,a0,1
  74:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  76:	00054783          	lbu	a5,0(a0)
  7a:	fbe5                	bnez	a5,6a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  7c:	0005c503          	lbu	a0,0(a1)
}
  80:	40a7853b          	subw	a0,a5,a0
  84:	6422                	ld	s0,8(sp)
  86:	0141                	addi	sp,sp,16
  88:	8082                	ret

000000000000008a <strlen>:

uint
strlen(const char *s)
{
  8a:	1141                	addi	sp,sp,-16
  8c:	e422                	sd	s0,8(sp)
  8e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  90:	00054783          	lbu	a5,0(a0)
  94:	cf91                	beqz	a5,b0 <strlen+0x26>
  96:	0505                	addi	a0,a0,1
  98:	87aa                	mv	a5,a0
  9a:	86be                	mv	a3,a5
  9c:	0785                	addi	a5,a5,1
  9e:	fff7c703          	lbu	a4,-1(a5)
  a2:	ff65                	bnez	a4,9a <strlen+0x10>
  a4:	40a6853b          	subw	a0,a3,a0
  a8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  aa:	6422                	ld	s0,8(sp)
  ac:	0141                	addi	sp,sp,16
  ae:	8082                	ret
  for(n = 0; s[n]; n++)
  b0:	4501                	li	a0,0
  b2:	bfe5                	j	aa <strlen+0x20>

00000000000000b4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  b4:	1141                	addi	sp,sp,-16
  b6:	e422                	sd	s0,8(sp)
  b8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ba:	ca19                	beqz	a2,d0 <memset+0x1c>
  bc:	87aa                	mv	a5,a0
  be:	1602                	slli	a2,a2,0x20
  c0:	9201                	srli	a2,a2,0x20
  c2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  c6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ca:	0785                	addi	a5,a5,1
  cc:	fee79de3          	bne	a5,a4,c6 <memset+0x12>
  }
  return dst;
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret

00000000000000d6 <strchr>:

char*
strchr(const char *s, char c)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  for(; *s; s++)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cb99                	beqz	a5,f6 <strchr+0x20>
    if(*s == c)
  e2:	00f58763          	beq	a1,a5,f0 <strchr+0x1a>
  for(; *s; s++)
  e6:	0505                	addi	a0,a0,1
  e8:	00054783          	lbu	a5,0(a0)
  ec:	fbfd                	bnez	a5,e2 <strchr+0xc>
      return (char*)s;
  return 0;
  ee:	4501                	li	a0,0
}
  f0:	6422                	ld	s0,8(sp)
  f2:	0141                	addi	sp,sp,16
  f4:	8082                	ret
  return 0;
  f6:	4501                	li	a0,0
  f8:	bfe5                	j	f0 <strchr+0x1a>

00000000000000fa <gets>:

char*
gets(char *buf, int max)
{
  fa:	711d                	addi	sp,sp,-96
  fc:	ec86                	sd	ra,88(sp)
  fe:	e8a2                	sd	s0,80(sp)
 100:	e4a6                	sd	s1,72(sp)
 102:	e0ca                	sd	s2,64(sp)
 104:	fc4e                	sd	s3,56(sp)
 106:	f852                	sd	s4,48(sp)
 108:	f456                	sd	s5,40(sp)
 10a:	f05a                	sd	s6,32(sp)
 10c:	ec5e                	sd	s7,24(sp)
 10e:	1080                	addi	s0,sp,96
 110:	8baa                	mv	s7,a0
 112:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 114:	892a                	mv	s2,a0
 116:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 118:	4aa9                	li	s5,10
 11a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 11c:	89a6                	mv	s3,s1
 11e:	2485                	addiw	s1,s1,1
 120:	0344d663          	bge	s1,s4,14c <gets+0x52>
    cc = read(0, &c, 1);
 124:	4605                	li	a2,1
 126:	faf40593          	addi	a1,s0,-81
 12a:	4501                	li	a0,0
 12c:	1b2000ef          	jal	2de <read>
    if(cc < 1)
 130:	00a05e63          	blez	a0,14c <gets+0x52>
    buf[i++] = c;
 134:	faf44783          	lbu	a5,-81(s0)
 138:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 13c:	01578763          	beq	a5,s5,14a <gets+0x50>
 140:	0905                	addi	s2,s2,1
 142:	fd679de3          	bne	a5,s6,11c <gets+0x22>
    buf[i++] = c;
 146:	89a6                	mv	s3,s1
 148:	a011                	j	14c <gets+0x52>
 14a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 14c:	99de                	add	s3,s3,s7
 14e:	00098023          	sb	zero,0(s3)
  return buf;
}
 152:	855e                	mv	a0,s7
 154:	60e6                	ld	ra,88(sp)
 156:	6446                	ld	s0,80(sp)
 158:	64a6                	ld	s1,72(sp)
 15a:	6906                	ld	s2,64(sp)
 15c:	79e2                	ld	s3,56(sp)
 15e:	7a42                	ld	s4,48(sp)
 160:	7aa2                	ld	s5,40(sp)
 162:	7b02                	ld	s6,32(sp)
 164:	6be2                	ld	s7,24(sp)
 166:	6125                	addi	sp,sp,96
 168:	8082                	ret

000000000000016a <stat>:

int
stat(const char *n, struct stat *st)
{
 16a:	1101                	addi	sp,sp,-32
 16c:	ec06                	sd	ra,24(sp)
 16e:	e822                	sd	s0,16(sp)
 170:	e04a                	sd	s2,0(sp)
 172:	1000                	addi	s0,sp,32
 174:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 176:	4581                	li	a1,0
 178:	18e000ef          	jal	306 <open>
  if(fd < 0)
 17c:	02054263          	bltz	a0,1a0 <stat+0x36>
 180:	e426                	sd	s1,8(sp)
 182:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 184:	85ca                	mv	a1,s2
 186:	198000ef          	jal	31e <fstat>
 18a:	892a                	mv	s2,a0
  close(fd);
 18c:	8526                	mv	a0,s1
 18e:	160000ef          	jal	2ee <close>
  return r;
 192:	64a2                	ld	s1,8(sp)
}
 194:	854a                	mv	a0,s2
 196:	60e2                	ld	ra,24(sp)
 198:	6442                	ld	s0,16(sp)
 19a:	6902                	ld	s2,0(sp)
 19c:	6105                	addi	sp,sp,32
 19e:	8082                	ret
    return -1;
 1a0:	597d                	li	s2,-1
 1a2:	bfcd                	j	194 <stat+0x2a>

00000000000001a4 <atoi>:

int
atoi(const char *s)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1aa:	00054683          	lbu	a3,0(a0)
 1ae:	fd06879b          	addiw	a5,a3,-48
 1b2:	0ff7f793          	zext.b	a5,a5
 1b6:	4625                	li	a2,9
 1b8:	02f66863          	bltu	a2,a5,1e8 <atoi+0x44>
 1bc:	872a                	mv	a4,a0
  n = 0;
 1be:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1c0:	0705                	addi	a4,a4,1
 1c2:	0025179b          	slliw	a5,a0,0x2
 1c6:	9fa9                	addw	a5,a5,a0
 1c8:	0017979b          	slliw	a5,a5,0x1
 1cc:	9fb5                	addw	a5,a5,a3
 1ce:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d2:	00074683          	lbu	a3,0(a4)
 1d6:	fd06879b          	addiw	a5,a3,-48
 1da:	0ff7f793          	zext.b	a5,a5
 1de:	fef671e3          	bgeu	a2,a5,1c0 <atoi+0x1c>
  return n;
}
 1e2:	6422                	ld	s0,8(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret
  n = 0;
 1e8:	4501                	li	a0,0
 1ea:	bfe5                	j	1e2 <atoi+0x3e>

00000000000001ec <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f2:	02b57463          	bgeu	a0,a1,21a <memmove+0x2e>
    while(n-- > 0)
 1f6:	00c05f63          	blez	a2,214 <memmove+0x28>
 1fa:	1602                	slli	a2,a2,0x20
 1fc:	9201                	srli	a2,a2,0x20
 1fe:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 202:	872a                	mv	a4,a0
      *dst++ = *src++;
 204:	0585                	addi	a1,a1,1
 206:	0705                	addi	a4,a4,1
 208:	fff5c683          	lbu	a3,-1(a1)
 20c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 210:	fef71ae3          	bne	a4,a5,204 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret
    dst += n;
 21a:	00c50733          	add	a4,a0,a2
    src += n;
 21e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 220:	fec05ae3          	blez	a2,214 <memmove+0x28>
 224:	fff6079b          	addiw	a5,a2,-1
 228:	1782                	slli	a5,a5,0x20
 22a:	9381                	srli	a5,a5,0x20
 22c:	fff7c793          	not	a5,a5
 230:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 232:	15fd                	addi	a1,a1,-1
 234:	177d                	addi	a4,a4,-1
 236:	0005c683          	lbu	a3,0(a1)
 23a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 23e:	fee79ae3          	bne	a5,a4,232 <memmove+0x46>
 242:	bfc9                	j	214 <memmove+0x28>

0000000000000244 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24a:	ca05                	beqz	a2,27a <memcmp+0x36>
 24c:	fff6069b          	addiw	a3,a2,-1
 250:	1682                	slli	a3,a3,0x20
 252:	9281                	srli	a3,a3,0x20
 254:	0685                	addi	a3,a3,1
 256:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 258:	00054783          	lbu	a5,0(a0)
 25c:	0005c703          	lbu	a4,0(a1)
 260:	00e79863          	bne	a5,a4,270 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 264:	0505                	addi	a0,a0,1
    p2++;
 266:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 268:	fed518e3          	bne	a0,a3,258 <memcmp+0x14>
  }
  return 0;
 26c:	4501                	li	a0,0
 26e:	a019                	j	274 <memcmp+0x30>
      return *p1 - *p2;
 270:	40e7853b          	subw	a0,a5,a4
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  return 0;
 27a:	4501                	li	a0,0
 27c:	bfe5                	j	274 <memcmp+0x30>

000000000000027e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e406                	sd	ra,8(sp)
 282:	e022                	sd	s0,0(sp)
 284:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 286:	f67ff0ef          	jal	1ec <memmove>
}
 28a:	60a2                	ld	ra,8(sp)
 28c:	6402                	ld	s0,0(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret

0000000000000292 <sbrk>:

char *
sbrk(int n) {
 292:	1141                	addi	sp,sp,-16
 294:	e406                	sd	ra,8(sp)
 296:	e022                	sd	s0,0(sp)
 298:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 29a:	4585                	li	a1,1
 29c:	0b2000ef          	jal	34e <sys_sbrk>
}
 2a0:	60a2                	ld	ra,8(sp)
 2a2:	6402                	ld	s0,0(sp)
 2a4:	0141                	addi	sp,sp,16
 2a6:	8082                	ret

00000000000002a8 <sbrklazy>:

char *
sbrklazy(int n) {
 2a8:	1141                	addi	sp,sp,-16
 2aa:	e406                	sd	ra,8(sp)
 2ac:	e022                	sd	s0,0(sp)
 2ae:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2b0:	4589                	li	a1,2
 2b2:	09c000ef          	jal	34e <sys_sbrk>
}
 2b6:	60a2                	ld	ra,8(sp)
 2b8:	6402                	ld	s0,0(sp)
 2ba:	0141                	addi	sp,sp,16
 2bc:	8082                	ret

00000000000002be <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2be:	4885                	li	a7,1
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c6:	4889                	li	a7,2
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ce:	488d                	li	a7,3
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d6:	4891                	li	a7,4
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <read>:
.global read
read:
 li a7, SYS_read
 2de:	4895                	li	a7,5
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <write>:
.global write
write:
 li a7, SYS_write
 2e6:	48c1                	li	a7,16
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <close>:
.global close
close:
 li a7, SYS_close
 2ee:	48d5                	li	a7,21
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f6:	4899                	li	a7,6
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <exec>:
.global exec
exec:
 li a7, SYS_exec
 2fe:	489d                	li	a7,7
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <open>:
.global open
open:
 li a7, SYS_open
 306:	48bd                	li	a7,15
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 30e:	48c5                	li	a7,17
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 316:	48c9                	li	a7,18
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 31e:	48a1                	li	a7,8
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <link>:
.global link
link:
 li a7, SYS_link
 326:	48cd                	li	a7,19
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 32e:	48d1                	li	a7,20
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 336:	48a5                	li	a7,9
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <dup>:
.global dup
dup:
 li a7, SYS_dup
 33e:	48a9                	li	a7,10
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 346:	48ad                	li	a7,11
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 34e:	48b1                	li	a7,12
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <pause>:
.global pause
pause:
 li a7, SYS_pause
 356:	48b5                	li	a7,13
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 35e:	48b9                	li	a7,14
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <hello>:
.global hello
hello:
 li a7, SYS_hello
 366:	48d9                	li	a7,22
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <ps>:
.global ps
ps:
 li a7, SYS_ps
 36e:	48dd                	li	a7,23
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <memtest>:
.global memtest
memtest:
 li a7, SYS_memtest
 376:	48e1                	li	a7,24
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <testnolock>:
.global testnolock
testnolock:
 li a7, SYS_testnolock
 37e:	48e5                	li	a7,25
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 386:	48e9                	li	a7,26
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <nullcall>:
.global nullcall
nullcall:
 li a7, SYS_nullcall
 38e:	48ed                	li	a7,27
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <getcycles>:
.global getcycles
getcycles:
 li a7, SYS_getcycles
 396:	48f1                	li	a7,28
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <set_filter>:
.global set_filter
set_filter:
 li a7, SYS_set_filter
 39e:	48f5                	li	a7,29
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3a6:	1101                	addi	sp,sp,-32
 3a8:	ec06                	sd	ra,24(sp)
 3aa:	e822                	sd	s0,16(sp)
 3ac:	1000                	addi	s0,sp,32
 3ae:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3b2:	4605                	li	a2,1
 3b4:	fef40593          	addi	a1,s0,-17
 3b8:	f2fff0ef          	jal	2e6 <write>
}
 3bc:	60e2                	ld	ra,24(sp)
 3be:	6442                	ld	s0,16(sp)
 3c0:	6105                	addi	sp,sp,32
 3c2:	8082                	ret

00000000000003c4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3c4:	715d                	addi	sp,sp,-80
 3c6:	e486                	sd	ra,72(sp)
 3c8:	e0a2                	sd	s0,64(sp)
 3ca:	f84a                	sd	s2,48(sp)
 3cc:	0880                	addi	s0,sp,80
 3ce:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3d0:	c299                	beqz	a3,3d6 <printint+0x12>
 3d2:	0805c363          	bltz	a1,458 <printint+0x94>
  neg = 0;
 3d6:	4881                	li	a7,0
 3d8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3dc:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3de:	00000517          	auipc	a0,0x0
 3e2:	59250513          	addi	a0,a0,1426 # 970 <digits>
 3e6:	883e                	mv	a6,a5
 3e8:	2785                	addiw	a5,a5,1
 3ea:	02c5f733          	remu	a4,a1,a2
 3ee:	972a                	add	a4,a4,a0
 3f0:	00074703          	lbu	a4,0(a4)
 3f4:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 3f8:	872e                	mv	a4,a1
 3fa:	02c5d5b3          	divu	a1,a1,a2
 3fe:	0685                	addi	a3,a3,1
 400:	fec773e3          	bgeu	a4,a2,3e6 <printint+0x22>
  if(neg)
 404:	00088b63          	beqz	a7,41a <printint+0x56>
    buf[i++] = '-';
 408:	fd078793          	addi	a5,a5,-48
 40c:	97a2                	add	a5,a5,s0
 40e:	02d00713          	li	a4,45
 412:	fee78423          	sb	a4,-24(a5)
 416:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 41a:	02f05a63          	blez	a5,44e <printint+0x8a>
 41e:	fc26                	sd	s1,56(sp)
 420:	f44e                	sd	s3,40(sp)
 422:	fb840713          	addi	a4,s0,-72
 426:	00f704b3          	add	s1,a4,a5
 42a:	fff70993          	addi	s3,a4,-1
 42e:	99be                	add	s3,s3,a5
 430:	37fd                	addiw	a5,a5,-1
 432:	1782                	slli	a5,a5,0x20
 434:	9381                	srli	a5,a5,0x20
 436:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 43a:	fff4c583          	lbu	a1,-1(s1)
 43e:	854a                	mv	a0,s2
 440:	f67ff0ef          	jal	3a6 <putc>
  while(--i >= 0)
 444:	14fd                	addi	s1,s1,-1
 446:	ff349ae3          	bne	s1,s3,43a <printint+0x76>
 44a:	74e2                	ld	s1,56(sp)
 44c:	79a2                	ld	s3,40(sp)
}
 44e:	60a6                	ld	ra,72(sp)
 450:	6406                	ld	s0,64(sp)
 452:	7942                	ld	s2,48(sp)
 454:	6161                	addi	sp,sp,80
 456:	8082                	ret
    x = -xx;
 458:	40b005b3          	neg	a1,a1
    neg = 1;
 45c:	4885                	li	a7,1
    x = -xx;
 45e:	bfad                	j	3d8 <printint+0x14>

0000000000000460 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 460:	711d                	addi	sp,sp,-96
 462:	ec86                	sd	ra,88(sp)
 464:	e8a2                	sd	s0,80(sp)
 466:	e0ca                	sd	s2,64(sp)
 468:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 46a:	0005c903          	lbu	s2,0(a1)
 46e:	28090663          	beqz	s2,6fa <vprintf+0x29a>
 472:	e4a6                	sd	s1,72(sp)
 474:	fc4e                	sd	s3,56(sp)
 476:	f852                	sd	s4,48(sp)
 478:	f456                	sd	s5,40(sp)
 47a:	f05a                	sd	s6,32(sp)
 47c:	ec5e                	sd	s7,24(sp)
 47e:	e862                	sd	s8,16(sp)
 480:	e466                	sd	s9,8(sp)
 482:	8b2a                	mv	s6,a0
 484:	8a2e                	mv	s4,a1
 486:	8bb2                	mv	s7,a2
  state = 0;
 488:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 48a:	4481                	li	s1,0
 48c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 48e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 492:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 496:	06c00c93          	li	s9,108
 49a:	a005                	j	4ba <vprintf+0x5a>
        putc(fd, c0);
 49c:	85ca                	mv	a1,s2
 49e:	855a                	mv	a0,s6
 4a0:	f07ff0ef          	jal	3a6 <putc>
 4a4:	a019                	j	4aa <vprintf+0x4a>
    } else if(state == '%'){
 4a6:	03598263          	beq	s3,s5,4ca <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4aa:	2485                	addiw	s1,s1,1
 4ac:	8726                	mv	a4,s1
 4ae:	009a07b3          	add	a5,s4,s1
 4b2:	0007c903          	lbu	s2,0(a5)
 4b6:	22090a63          	beqz	s2,6ea <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4ba:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4be:	fe0994e3          	bnez	s3,4a6 <vprintf+0x46>
      if(c0 == '%'){
 4c2:	fd579de3          	bne	a5,s5,49c <vprintf+0x3c>
        state = '%';
 4c6:	89be                	mv	s3,a5
 4c8:	b7cd                	j	4aa <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4ca:	00ea06b3          	add	a3,s4,a4
 4ce:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4d2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4d4:	c681                	beqz	a3,4dc <vprintf+0x7c>
 4d6:	9752                	add	a4,a4,s4
 4d8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4dc:	05878363          	beq	a5,s8,522 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4e0:	05978d63          	beq	a5,s9,53a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4e4:	07500713          	li	a4,117
 4e8:	0ee78763          	beq	a5,a4,5d6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4ec:	07800713          	li	a4,120
 4f0:	12e78963          	beq	a5,a4,622 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 4f4:	07000713          	li	a4,112
 4f8:	14e78e63          	beq	a5,a4,654 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 4fc:	06300713          	li	a4,99
 500:	18e78e63          	beq	a5,a4,69c <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 504:	07300713          	li	a4,115
 508:	1ae78463          	beq	a5,a4,6b0 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 50c:	02500713          	li	a4,37
 510:	04e79563          	bne	a5,a4,55a <vprintf+0xfa>
        putc(fd, '%');
 514:	02500593          	li	a1,37
 518:	855a                	mv	a0,s6
 51a:	e8dff0ef          	jal	3a6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 51e:	4981                	li	s3,0
 520:	b769                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 522:	008b8913          	addi	s2,s7,8
 526:	4685                	li	a3,1
 528:	4629                	li	a2,10
 52a:	000ba583          	lw	a1,0(s7)
 52e:	855a                	mv	a0,s6
 530:	e95ff0ef          	jal	3c4 <printint>
 534:	8bca                	mv	s7,s2
      state = 0;
 536:	4981                	li	s3,0
 538:	bf8d                	j	4aa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 53a:	06400793          	li	a5,100
 53e:	02f68963          	beq	a3,a5,570 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 542:	06c00793          	li	a5,108
 546:	04f68263          	beq	a3,a5,58a <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 54a:	07500793          	li	a5,117
 54e:	0af68063          	beq	a3,a5,5ee <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 552:	07800793          	li	a5,120
 556:	0ef68263          	beq	a3,a5,63a <vprintf+0x1da>
        putc(fd, '%');
 55a:	02500593          	li	a1,37
 55e:	855a                	mv	a0,s6
 560:	e47ff0ef          	jal	3a6 <putc>
        putc(fd, c0);
 564:	85ca                	mv	a1,s2
 566:	855a                	mv	a0,s6
 568:	e3fff0ef          	jal	3a6 <putc>
      state = 0;
 56c:	4981                	li	s3,0
 56e:	bf35                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 570:	008b8913          	addi	s2,s7,8
 574:	4685                	li	a3,1
 576:	4629                	li	a2,10
 578:	000bb583          	ld	a1,0(s7)
 57c:	855a                	mv	a0,s6
 57e:	e47ff0ef          	jal	3c4 <printint>
        i += 1;
 582:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 584:	8bca                	mv	s7,s2
      state = 0;
 586:	4981                	li	s3,0
        i += 1;
 588:	b70d                	j	4aa <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 58a:	06400793          	li	a5,100
 58e:	02f60763          	beq	a2,a5,5bc <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 592:	07500793          	li	a5,117
 596:	06f60963          	beq	a2,a5,608 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 59a:	07800793          	li	a5,120
 59e:	faf61ee3          	bne	a2,a5,55a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5a2:	008b8913          	addi	s2,s7,8
 5a6:	4681                	li	a3,0
 5a8:	4641                	li	a2,16
 5aa:	000bb583          	ld	a1,0(s7)
 5ae:	855a                	mv	a0,s6
 5b0:	e15ff0ef          	jal	3c4 <printint>
        i += 2;
 5b4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b6:	8bca                	mv	s7,s2
      state = 0;
 5b8:	4981                	li	s3,0
        i += 2;
 5ba:	bdc5                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5bc:	008b8913          	addi	s2,s7,8
 5c0:	4685                	li	a3,1
 5c2:	4629                	li	a2,10
 5c4:	000bb583          	ld	a1,0(s7)
 5c8:	855a                	mv	a0,s6
 5ca:	dfbff0ef          	jal	3c4 <printint>
        i += 2;
 5ce:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d0:	8bca                	mv	s7,s2
      state = 0;
 5d2:	4981                	li	s3,0
        i += 2;
 5d4:	bdd9                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5d6:	008b8913          	addi	s2,s7,8
 5da:	4681                	li	a3,0
 5dc:	4629                	li	a2,10
 5de:	000be583          	lwu	a1,0(s7)
 5e2:	855a                	mv	a0,s6
 5e4:	de1ff0ef          	jal	3c4 <printint>
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	bd7d                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4629                	li	a2,10
 5f6:	000bb583          	ld	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	dc9ff0ef          	jal	3c4 <printint>
        i += 1;
 600:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 602:	8bca                	mv	s7,s2
      state = 0;
 604:	4981                	li	s3,0
        i += 1;
 606:	b555                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 608:	008b8913          	addi	s2,s7,8
 60c:	4681                	li	a3,0
 60e:	4629                	li	a2,10
 610:	000bb583          	ld	a1,0(s7)
 614:	855a                	mv	a0,s6
 616:	dafff0ef          	jal	3c4 <printint>
        i += 2;
 61a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 61c:	8bca                	mv	s7,s2
      state = 0;
 61e:	4981                	li	s3,0
        i += 2;
 620:	b569                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 622:	008b8913          	addi	s2,s7,8
 626:	4681                	li	a3,0
 628:	4641                	li	a2,16
 62a:	000be583          	lwu	a1,0(s7)
 62e:	855a                	mv	a0,s6
 630:	d95ff0ef          	jal	3c4 <printint>
 634:	8bca                	mv	s7,s2
      state = 0;
 636:	4981                	li	s3,0
 638:	bd8d                	j	4aa <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4681                	li	a3,0
 640:	4641                	li	a2,16
 642:	000bb583          	ld	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	d7dff0ef          	jal	3c4 <printint>
        i += 1;
 64c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 64e:	8bca                	mv	s7,s2
      state = 0;
 650:	4981                	li	s3,0
        i += 1;
 652:	bda1                	j	4aa <vprintf+0x4a>
 654:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 656:	008b8d13          	addi	s10,s7,8
 65a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 65e:	03000593          	li	a1,48
 662:	855a                	mv	a0,s6
 664:	d43ff0ef          	jal	3a6 <putc>
  putc(fd, 'x');
 668:	07800593          	li	a1,120
 66c:	855a                	mv	a0,s6
 66e:	d39ff0ef          	jal	3a6 <putc>
 672:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 674:	00000b97          	auipc	s7,0x0
 678:	2fcb8b93          	addi	s7,s7,764 # 970 <digits>
 67c:	03c9d793          	srli	a5,s3,0x3c
 680:	97de                	add	a5,a5,s7
 682:	0007c583          	lbu	a1,0(a5)
 686:	855a                	mv	a0,s6
 688:	d1fff0ef          	jal	3a6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 68c:	0992                	slli	s3,s3,0x4
 68e:	397d                	addiw	s2,s2,-1
 690:	fe0916e3          	bnez	s2,67c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 694:	8bea                	mv	s7,s10
      state = 0;
 696:	4981                	li	s3,0
 698:	6d02                	ld	s10,0(sp)
 69a:	bd01                	j	4aa <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 69c:	008b8913          	addi	s2,s7,8
 6a0:	000bc583          	lbu	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	d01ff0ef          	jal	3a6 <putc>
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
 6ae:	bbf5                	j	4aa <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6b0:	008b8993          	addi	s3,s7,8
 6b4:	000bb903          	ld	s2,0(s7)
 6b8:	00090f63          	beqz	s2,6d6 <vprintf+0x276>
        for(; *s; s++)
 6bc:	00094583          	lbu	a1,0(s2)
 6c0:	c195                	beqz	a1,6e4 <vprintf+0x284>
          putc(fd, *s);
 6c2:	855a                	mv	a0,s6
 6c4:	ce3ff0ef          	jal	3a6 <putc>
        for(; *s; s++)
 6c8:	0905                	addi	s2,s2,1
 6ca:	00094583          	lbu	a1,0(s2)
 6ce:	f9f5                	bnez	a1,6c2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6d0:	8bce                	mv	s7,s3
      state = 0;
 6d2:	4981                	li	s3,0
 6d4:	bbd9                	j	4aa <vprintf+0x4a>
          s = "(null)";
 6d6:	00000917          	auipc	s2,0x0
 6da:	29290913          	addi	s2,s2,658 # 968 <malloc+0x186>
        for(; *s; s++)
 6de:	02800593          	li	a1,40
 6e2:	b7c5                	j	6c2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6e4:	8bce                	mv	s7,s3
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	b3c9                	j	4aa <vprintf+0x4a>
 6ea:	64a6                	ld	s1,72(sp)
 6ec:	79e2                	ld	s3,56(sp)
 6ee:	7a42                	ld	s4,48(sp)
 6f0:	7aa2                	ld	s5,40(sp)
 6f2:	7b02                	ld	s6,32(sp)
 6f4:	6be2                	ld	s7,24(sp)
 6f6:	6c42                	ld	s8,16(sp)
 6f8:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6fa:	60e6                	ld	ra,88(sp)
 6fc:	6446                	ld	s0,80(sp)
 6fe:	6906                	ld	s2,64(sp)
 700:	6125                	addi	sp,sp,96
 702:	8082                	ret

0000000000000704 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 704:	715d                	addi	sp,sp,-80
 706:	ec06                	sd	ra,24(sp)
 708:	e822                	sd	s0,16(sp)
 70a:	1000                	addi	s0,sp,32
 70c:	e010                	sd	a2,0(s0)
 70e:	e414                	sd	a3,8(s0)
 710:	e818                	sd	a4,16(s0)
 712:	ec1c                	sd	a5,24(s0)
 714:	03043023          	sd	a6,32(s0)
 718:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 71c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 720:	8622                	mv	a2,s0
 722:	d3fff0ef          	jal	460 <vprintf>
}
 726:	60e2                	ld	ra,24(sp)
 728:	6442                	ld	s0,16(sp)
 72a:	6161                	addi	sp,sp,80
 72c:	8082                	ret

000000000000072e <printf>:

void
printf(const char *fmt, ...)
{
 72e:	711d                	addi	sp,sp,-96
 730:	ec06                	sd	ra,24(sp)
 732:	e822                	sd	s0,16(sp)
 734:	1000                	addi	s0,sp,32
 736:	e40c                	sd	a1,8(s0)
 738:	e810                	sd	a2,16(s0)
 73a:	ec14                	sd	a3,24(s0)
 73c:	f018                	sd	a4,32(s0)
 73e:	f41c                	sd	a5,40(s0)
 740:	03043823          	sd	a6,48(s0)
 744:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 748:	00840613          	addi	a2,s0,8
 74c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 750:	85aa                	mv	a1,a0
 752:	4505                	li	a0,1
 754:	d0dff0ef          	jal	460 <vprintf>
}
 758:	60e2                	ld	ra,24(sp)
 75a:	6442                	ld	s0,16(sp)
 75c:	6125                	addi	sp,sp,96
 75e:	8082                	ret

0000000000000760 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 760:	1141                	addi	sp,sp,-16
 762:	e422                	sd	s0,8(sp)
 764:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 766:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76a:	00001797          	auipc	a5,0x1
 76e:	8967b783          	ld	a5,-1898(a5) # 1000 <freep>
 772:	a02d                	j	79c <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 774:	4618                	lw	a4,8(a2)
 776:	9f2d                	addw	a4,a4,a1
 778:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 77c:	6398                	ld	a4,0(a5)
 77e:	6310                	ld	a2,0(a4)
 780:	a83d                	j	7be <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 782:	ff852703          	lw	a4,-8(a0)
 786:	9f31                	addw	a4,a4,a2
 788:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 78a:	ff053683          	ld	a3,-16(a0)
 78e:	a091                	j	7d2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 790:	6398                	ld	a4,0(a5)
 792:	00e7e463          	bltu	a5,a4,79a <free+0x3a>
 796:	00e6ea63          	bltu	a3,a4,7aa <free+0x4a>
{
 79a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 79c:	fed7fae3          	bgeu	a5,a3,790 <free+0x30>
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e6e463          	bltu	a3,a4,7aa <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a6:	fee7eae3          	bltu	a5,a4,79a <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7aa:	ff852583          	lw	a1,-8(a0)
 7ae:	6390                	ld	a2,0(a5)
 7b0:	02059813          	slli	a6,a1,0x20
 7b4:	01c85713          	srli	a4,a6,0x1c
 7b8:	9736                	add	a4,a4,a3
 7ba:	fae60de3          	beq	a2,a4,774 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7be:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c2:	4790                	lw	a2,8(a5)
 7c4:	02061593          	slli	a1,a2,0x20
 7c8:	01c5d713          	srli	a4,a1,0x1c
 7cc:	973e                	add	a4,a4,a5
 7ce:	fae68ae3          	beq	a3,a4,782 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7d2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d4:	00001717          	auipc	a4,0x1
 7d8:	82f73623          	sd	a5,-2004(a4) # 1000 <freep>
}
 7dc:	6422                	ld	s0,8(sp)
 7de:	0141                	addi	sp,sp,16
 7e0:	8082                	ret

00000000000007e2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e2:	7139                	addi	sp,sp,-64
 7e4:	fc06                	sd	ra,56(sp)
 7e6:	f822                	sd	s0,48(sp)
 7e8:	f426                	sd	s1,40(sp)
 7ea:	ec4e                	sd	s3,24(sp)
 7ec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7ee:	02051493          	slli	s1,a0,0x20
 7f2:	9081                	srli	s1,s1,0x20
 7f4:	04bd                	addi	s1,s1,15
 7f6:	8091                	srli	s1,s1,0x4
 7f8:	0014899b          	addiw	s3,s1,1
 7fc:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7fe:	00001517          	auipc	a0,0x1
 802:	80253503          	ld	a0,-2046(a0) # 1000 <freep>
 806:	c915                	beqz	a0,83a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 808:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80a:	4798                	lw	a4,8(a5)
 80c:	08977a63          	bgeu	a4,s1,8a0 <malloc+0xbe>
 810:	f04a                	sd	s2,32(sp)
 812:	e852                	sd	s4,16(sp)
 814:	e456                	sd	s5,8(sp)
 816:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 818:	8a4e                	mv	s4,s3
 81a:	0009871b          	sext.w	a4,s3
 81e:	6685                	lui	a3,0x1
 820:	00d77363          	bgeu	a4,a3,826 <malloc+0x44>
 824:	6a05                	lui	s4,0x1
 826:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 82a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 82e:	00000917          	auipc	s2,0x0
 832:	7d290913          	addi	s2,s2,2002 # 1000 <freep>
  if(p == SBRK_ERROR)
 836:	5afd                	li	s5,-1
 838:	a081                	j	878 <malloc+0x96>
 83a:	f04a                	sd	s2,32(sp)
 83c:	e852                	sd	s4,16(sp)
 83e:	e456                	sd	s5,8(sp)
 840:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 842:	00000797          	auipc	a5,0x0
 846:	7ce78793          	addi	a5,a5,1998 # 1010 <base>
 84a:	00000717          	auipc	a4,0x0
 84e:	7af73b23          	sd	a5,1974(a4) # 1000 <freep>
 852:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 854:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 858:	b7c1                	j	818 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 85a:	6398                	ld	a4,0(a5)
 85c:	e118                	sd	a4,0(a0)
 85e:	a8a9                	j	8b8 <malloc+0xd6>
  hp->s.size = nu;
 860:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 864:	0541                	addi	a0,a0,16
 866:	efbff0ef          	jal	760 <free>
  return freep;
 86a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 86e:	c12d                	beqz	a0,8d0 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 872:	4798                	lw	a4,8(a5)
 874:	02977263          	bgeu	a4,s1,898 <malloc+0xb6>
    if(p == freep)
 878:	00093703          	ld	a4,0(s2)
 87c:	853e                	mv	a0,a5
 87e:	fef719e3          	bne	a4,a5,870 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 882:	8552                	mv	a0,s4
 884:	a0fff0ef          	jal	292 <sbrk>
  if(p == SBRK_ERROR)
 888:	fd551ce3          	bne	a0,s5,860 <malloc+0x7e>
        return 0;
 88c:	4501                	li	a0,0
 88e:	7902                	ld	s2,32(sp)
 890:	6a42                	ld	s4,16(sp)
 892:	6aa2                	ld	s5,8(sp)
 894:	6b02                	ld	s6,0(sp)
 896:	a03d                	j	8c4 <malloc+0xe2>
 898:	7902                	ld	s2,32(sp)
 89a:	6a42                	ld	s4,16(sp)
 89c:	6aa2                	ld	s5,8(sp)
 89e:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8a0:	fae48de3          	beq	s1,a4,85a <malloc+0x78>
        p->s.size -= nunits;
 8a4:	4137073b          	subw	a4,a4,s3
 8a8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8aa:	02071693          	slli	a3,a4,0x20
 8ae:	01c6d713          	srli	a4,a3,0x1c
 8b2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b8:	00000717          	auipc	a4,0x0
 8bc:	74a73423          	sd	a0,1864(a4) # 1000 <freep>
      return (void*)(p + 1);
 8c0:	01078513          	addi	a0,a5,16
  }
}
 8c4:	70e2                	ld	ra,56(sp)
 8c6:	7442                	ld	s0,48(sp)
 8c8:	74a2                	ld	s1,40(sp)
 8ca:	69e2                	ld	s3,24(sp)
 8cc:	6121                	addi	sp,sp,64
 8ce:	8082                	ret
 8d0:	7902                	ld	s2,32(sp)
 8d2:	6a42                	ld	s4,16(sp)
 8d4:	6aa2                	ld	s5,8(sp)
 8d6:	6b02                	ld	s6,0(sp)
 8d8:	b7f5                	j	8c4 <malloc+0xe2>
