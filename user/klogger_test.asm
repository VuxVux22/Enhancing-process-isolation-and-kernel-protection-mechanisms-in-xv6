
user/_klogger_test:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:

#include "kernel/memlayout.h" 

 

int main(int argc, char *argv[]) { 
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16

    printf("--- Kich hoat chuong trinh tan cong gia lap tu User Space ---\n"); 
   8:	00001517          	auipc	a0,0x1
   c:	8e850513          	addi	a0,a0,-1816 # 8f0 <malloc+0xfe>
  10:	72e000ef          	jal	73e <printf>

    uint64 *kernel_text_ptr = (uint64 *) KERNBASE;  

     

    printf("[ATTACK] Dang co tinh ghi de du lieu vao vi tri KERNBASE (0x80000000)...\n"); 
  14:	00001517          	auipc	a0,0x1
  18:	92450513          	addi	a0,a0,-1756 # 938 <malloc+0x146>
  1c:	722000ef          	jal	73e <printf>

 

    // Hành vi tấn công: Ép CPU thực hiện lệnh ghi vào vùng chỉ cho phép Đọc/Thực thi 

    *kernel_text_ptr = 0x99999999; 
  20:	4705                	li	a4,1
  22:	077e                	slli	a4,a4,0x1f
  24:	4cccd7b7          	lui	a5,0x4cccd
  28:	0786                	slli	a5,a5,0x1
  2a:	99978793          	addi	a5,a5,-1639 # 4cccc999 <base+0x4cccb989>
  2e:	e31c                	sd	a5,0(a4)

 

    // Nếu klogger và bảo vệ bảng trang chạy đúng, dòng này sẽ KHÔNG BAO GIỜ được in ra 

    printf("[LOI NGHIEM TRONG] GIA CỐ THẤT BẠI! Tien trinh User van sua doi duoc Kernel.\n"); 
  30:	00001517          	auipc	a0,0x1
  34:	95850513          	addi	a0,a0,-1704 # 988 <malloc+0x196>
  38:	706000ef          	jal	73e <printf>

     

    exit(1); 
  3c:	4505                	li	a0,1
  3e:	298000ef          	jal	2d6 <exit>

0000000000000042 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  42:	1141                	addi	sp,sp,-16
  44:	e406                	sd	ra,8(sp)
  46:	e022                	sd	s0,0(sp)
  48:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  4a:	fb7ff0ef          	jal	0 <main>
  exit(r);
  4e:	288000ef          	jal	2d6 <exit>

0000000000000052 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  52:	1141                	addi	sp,sp,-16
  54:	e422                	sd	s0,8(sp)
  56:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  58:	87aa                	mv	a5,a0
  5a:	0585                	addi	a1,a1,1
  5c:	0785                	addi	a5,a5,1
  5e:	fff5c703          	lbu	a4,-1(a1)
  62:	fee78fa3          	sb	a4,-1(a5)
  66:	fb75                	bnez	a4,5a <strcpy+0x8>
    ;
  return os;
}
  68:	6422                	ld	s0,8(sp)
  6a:	0141                	addi	sp,sp,16
  6c:	8082                	ret

000000000000006e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  6e:	1141                	addi	sp,sp,-16
  70:	e422                	sd	s0,8(sp)
  72:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  74:	00054783          	lbu	a5,0(a0)
  78:	cb91                	beqz	a5,8c <strcmp+0x1e>
  7a:	0005c703          	lbu	a4,0(a1)
  7e:	00f71763          	bne	a4,a5,8c <strcmp+0x1e>
    p++, q++;
  82:	0505                	addi	a0,a0,1
  84:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  86:	00054783          	lbu	a5,0(a0)
  8a:	fbe5                	bnez	a5,7a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  8c:	0005c503          	lbu	a0,0(a1)
}
  90:	40a7853b          	subw	a0,a5,a0
  94:	6422                	ld	s0,8(sp)
  96:	0141                	addi	sp,sp,16
  98:	8082                	ret

000000000000009a <strlen>:

uint
strlen(const char *s)
{
  9a:	1141                	addi	sp,sp,-16
  9c:	e422                	sd	s0,8(sp)
  9e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a0:	00054783          	lbu	a5,0(a0)
  a4:	cf91                	beqz	a5,c0 <strlen+0x26>
  a6:	0505                	addi	a0,a0,1
  a8:	87aa                	mv	a5,a0
  aa:	86be                	mv	a3,a5
  ac:	0785                	addi	a5,a5,1
  ae:	fff7c703          	lbu	a4,-1(a5)
  b2:	ff65                	bnez	a4,aa <strlen+0x10>
  b4:	40a6853b          	subw	a0,a3,a0
  b8:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  ba:	6422                	ld	s0,8(sp)
  bc:	0141                	addi	sp,sp,16
  be:	8082                	ret
  for(n = 0; s[n]; n++)
  c0:	4501                	li	a0,0
  c2:	bfe5                	j	ba <strlen+0x20>

00000000000000c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  c4:	1141                	addi	sp,sp,-16
  c6:	e422                	sd	s0,8(sp)
  c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  ca:	ca19                	beqz	a2,e0 <memset+0x1c>
  cc:	87aa                	mv	a5,a0
  ce:	1602                	slli	a2,a2,0x20
  d0:	9201                	srli	a2,a2,0x20
  d2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  d6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  da:	0785                	addi	a5,a5,1
  dc:	fee79de3          	bne	a5,a4,d6 <memset+0x12>
  }
  return dst;
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret

00000000000000e6 <strchr>:

char*
strchr(const char *s, char c)
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e422                	sd	s0,8(sp)
  ea:	0800                	addi	s0,sp,16
  for(; *s; s++)
  ec:	00054783          	lbu	a5,0(a0)
  f0:	cb99                	beqz	a5,106 <strchr+0x20>
    if(*s == c)
  f2:	00f58763          	beq	a1,a5,100 <strchr+0x1a>
  for(; *s; s++)
  f6:	0505                	addi	a0,a0,1
  f8:	00054783          	lbu	a5,0(a0)
  fc:	fbfd                	bnez	a5,f2 <strchr+0xc>
      return (char*)s;
  return 0;
  fe:	4501                	li	a0,0
}
 100:	6422                	ld	s0,8(sp)
 102:	0141                	addi	sp,sp,16
 104:	8082                	ret
  return 0;
 106:	4501                	li	a0,0
 108:	bfe5                	j	100 <strchr+0x1a>

000000000000010a <gets>:

char*
gets(char *buf, int max)
{
 10a:	711d                	addi	sp,sp,-96
 10c:	ec86                	sd	ra,88(sp)
 10e:	e8a2                	sd	s0,80(sp)
 110:	e4a6                	sd	s1,72(sp)
 112:	e0ca                	sd	s2,64(sp)
 114:	fc4e                	sd	s3,56(sp)
 116:	f852                	sd	s4,48(sp)
 118:	f456                	sd	s5,40(sp)
 11a:	f05a                	sd	s6,32(sp)
 11c:	ec5e                	sd	s7,24(sp)
 11e:	1080                	addi	s0,sp,96
 120:	8baa                	mv	s7,a0
 122:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 124:	892a                	mv	s2,a0
 126:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 128:	4aa9                	li	s5,10
 12a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 12c:	89a6                	mv	s3,s1
 12e:	2485                	addiw	s1,s1,1
 130:	0344d663          	bge	s1,s4,15c <gets+0x52>
    cc = read(0, &c, 1);
 134:	4605                	li	a2,1
 136:	faf40593          	addi	a1,s0,-81
 13a:	4501                	li	a0,0
 13c:	1b2000ef          	jal	2ee <read>
    if(cc < 1)
 140:	00a05e63          	blez	a0,15c <gets+0x52>
    buf[i++] = c;
 144:	faf44783          	lbu	a5,-81(s0)
 148:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 14c:	01578763          	beq	a5,s5,15a <gets+0x50>
 150:	0905                	addi	s2,s2,1
 152:	fd679de3          	bne	a5,s6,12c <gets+0x22>
    buf[i++] = c;
 156:	89a6                	mv	s3,s1
 158:	a011                	j	15c <gets+0x52>
 15a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 15c:	99de                	add	s3,s3,s7
 15e:	00098023          	sb	zero,0(s3)
  return buf;
}
 162:	855e                	mv	a0,s7
 164:	60e6                	ld	ra,88(sp)
 166:	6446                	ld	s0,80(sp)
 168:	64a6                	ld	s1,72(sp)
 16a:	6906                	ld	s2,64(sp)
 16c:	79e2                	ld	s3,56(sp)
 16e:	7a42                	ld	s4,48(sp)
 170:	7aa2                	ld	s5,40(sp)
 172:	7b02                	ld	s6,32(sp)
 174:	6be2                	ld	s7,24(sp)
 176:	6125                	addi	sp,sp,96
 178:	8082                	ret

000000000000017a <stat>:

int
stat(const char *n, struct stat *st)
{
 17a:	1101                	addi	sp,sp,-32
 17c:	ec06                	sd	ra,24(sp)
 17e:	e822                	sd	s0,16(sp)
 180:	e04a                	sd	s2,0(sp)
 182:	1000                	addi	s0,sp,32
 184:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 186:	4581                	li	a1,0
 188:	18e000ef          	jal	316 <open>
  if(fd < 0)
 18c:	02054263          	bltz	a0,1b0 <stat+0x36>
 190:	e426                	sd	s1,8(sp)
 192:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 194:	85ca                	mv	a1,s2
 196:	198000ef          	jal	32e <fstat>
 19a:	892a                	mv	s2,a0
  close(fd);
 19c:	8526                	mv	a0,s1
 19e:	160000ef          	jal	2fe <close>
  return r;
 1a2:	64a2                	ld	s1,8(sp)
}
 1a4:	854a                	mv	a0,s2
 1a6:	60e2                	ld	ra,24(sp)
 1a8:	6442                	ld	s0,16(sp)
 1aa:	6902                	ld	s2,0(sp)
 1ac:	6105                	addi	sp,sp,32
 1ae:	8082                	ret
    return -1;
 1b0:	597d                	li	s2,-1
 1b2:	bfcd                	j	1a4 <stat+0x2a>

00000000000001b4 <atoi>:

int
atoi(const char *s)
{
 1b4:	1141                	addi	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1ba:	00054683          	lbu	a3,0(a0)
 1be:	fd06879b          	addiw	a5,a3,-48
 1c2:	0ff7f793          	zext.b	a5,a5
 1c6:	4625                	li	a2,9
 1c8:	02f66863          	bltu	a2,a5,1f8 <atoi+0x44>
 1cc:	872a                	mv	a4,a0
  n = 0;
 1ce:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1d0:	0705                	addi	a4,a4,1
 1d2:	0025179b          	slliw	a5,a0,0x2
 1d6:	9fa9                	addw	a5,a5,a0
 1d8:	0017979b          	slliw	a5,a5,0x1
 1dc:	9fb5                	addw	a5,a5,a3
 1de:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1e2:	00074683          	lbu	a3,0(a4)
 1e6:	fd06879b          	addiw	a5,a3,-48
 1ea:	0ff7f793          	zext.b	a5,a5
 1ee:	fef671e3          	bgeu	a2,a5,1d0 <atoi+0x1c>
  return n;
}
 1f2:	6422                	ld	s0,8(sp)
 1f4:	0141                	addi	sp,sp,16
 1f6:	8082                	ret
  n = 0;
 1f8:	4501                	li	a0,0
 1fa:	bfe5                	j	1f2 <atoi+0x3e>

00000000000001fc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1fc:	1141                	addi	sp,sp,-16
 1fe:	e422                	sd	s0,8(sp)
 200:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 202:	02b57463          	bgeu	a0,a1,22a <memmove+0x2e>
    while(n-- > 0)
 206:	00c05f63          	blez	a2,224 <memmove+0x28>
 20a:	1602                	slli	a2,a2,0x20
 20c:	9201                	srli	a2,a2,0x20
 20e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 212:	872a                	mv	a4,a0
      *dst++ = *src++;
 214:	0585                	addi	a1,a1,1
 216:	0705                	addi	a4,a4,1
 218:	fff5c683          	lbu	a3,-1(a1)
 21c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 220:	fef71ae3          	bne	a4,a5,214 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 224:	6422                	ld	s0,8(sp)
 226:	0141                	addi	sp,sp,16
 228:	8082                	ret
    dst += n;
 22a:	00c50733          	add	a4,a0,a2
    src += n;
 22e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 230:	fec05ae3          	blez	a2,224 <memmove+0x28>
 234:	fff6079b          	addiw	a5,a2,-1
 238:	1782                	slli	a5,a5,0x20
 23a:	9381                	srli	a5,a5,0x20
 23c:	fff7c793          	not	a5,a5
 240:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 242:	15fd                	addi	a1,a1,-1
 244:	177d                	addi	a4,a4,-1
 246:	0005c683          	lbu	a3,0(a1)
 24a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 24e:	fee79ae3          	bne	a5,a4,242 <memmove+0x46>
 252:	bfc9                	j	224 <memmove+0x28>

0000000000000254 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 254:	1141                	addi	sp,sp,-16
 256:	e422                	sd	s0,8(sp)
 258:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 25a:	ca05                	beqz	a2,28a <memcmp+0x36>
 25c:	fff6069b          	addiw	a3,a2,-1
 260:	1682                	slli	a3,a3,0x20
 262:	9281                	srli	a3,a3,0x20
 264:	0685                	addi	a3,a3,1
 266:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 268:	00054783          	lbu	a5,0(a0)
 26c:	0005c703          	lbu	a4,0(a1)
 270:	00e79863          	bne	a5,a4,280 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 274:	0505                	addi	a0,a0,1
    p2++;
 276:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 278:	fed518e3          	bne	a0,a3,268 <memcmp+0x14>
  }
  return 0;
 27c:	4501                	li	a0,0
 27e:	a019                	j	284 <memcmp+0x30>
      return *p1 - *p2;
 280:	40e7853b          	subw	a0,a5,a4
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	addi	sp,sp,16
 288:	8082                	ret
  return 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <memcmp+0x30>

000000000000028e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e406                	sd	ra,8(sp)
 292:	e022                	sd	s0,0(sp)
 294:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 296:	f67ff0ef          	jal	1fc <memmove>
}
 29a:	60a2                	ld	ra,8(sp)
 29c:	6402                	ld	s0,0(sp)
 29e:	0141                	addi	sp,sp,16
 2a0:	8082                	ret

00000000000002a2 <sbrk>:

char *
sbrk(int n) {
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e406                	sd	ra,8(sp)
 2a6:	e022                	sd	s0,0(sp)
 2a8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 2aa:	4585                	li	a1,1
 2ac:	0b2000ef          	jal	35e <sys_sbrk>
}
 2b0:	60a2                	ld	ra,8(sp)
 2b2:	6402                	ld	s0,0(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret

00000000000002b8 <sbrklazy>:

char *
sbrklazy(int n) {
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e406                	sd	ra,8(sp)
 2bc:	e022                	sd	s0,0(sp)
 2be:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 2c0:	4589                	li	a1,2
 2c2:	09c000ef          	jal	35e <sys_sbrk>
}
 2c6:	60a2                	ld	ra,8(sp)
 2c8:	6402                	ld	s0,0(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret

00000000000002ce <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2ce:	4885                	li	a7,1
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2d6:	4889                	li	a7,2
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <wait>:
.global wait
wait:
 li a7, SYS_wait
 2de:	488d                	li	a7,3
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2e6:	4891                	li	a7,4
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <read>:
.global read
read:
 li a7, SYS_read
 2ee:	4895                	li	a7,5
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <write>:
.global write
write:
 li a7, SYS_write
 2f6:	48c1                	li	a7,16
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <close>:
.global close
close:
 li a7, SYS_close
 2fe:	48d5                	li	a7,21
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <kill>:
.global kill
kill:
 li a7, SYS_kill
 306:	4899                	li	a7,6
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <exec>:
.global exec
exec:
 li a7, SYS_exec
 30e:	489d                	li	a7,7
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <open>:
.global open
open:
 li a7, SYS_open
 316:	48bd                	li	a7,15
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 31e:	48c5                	li	a7,17
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 326:	48c9                	li	a7,18
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 32e:	48a1                	li	a7,8
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <link>:
.global link
link:
 li a7, SYS_link
 336:	48cd                	li	a7,19
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 33e:	48d1                	li	a7,20
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 346:	48a5                	li	a7,9
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <dup>:
.global dup
dup:
 li a7, SYS_dup
 34e:	48a9                	li	a7,10
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 356:	48ad                	li	a7,11
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 35e:	48b1                	li	a7,12
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <pause>:
.global pause
pause:
 li a7, SYS_pause
 366:	48b5                	li	a7,13
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 36e:	48b9                	li	a7,14
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <hello>:
.global hello
hello:
 li a7, SYS_hello
 376:	48d9                	li	a7,22
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <ps>:
.global ps
ps:
 li a7, SYS_ps
 37e:	48dd                	li	a7,23
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <memtest>:
.global memtest
memtest:
 li a7, SYS_memtest
 386:	48e1                	li	a7,24
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <testnolock>:
.global testnolock
testnolock:
 li a7, SYS_testnolock
 38e:	48e5                	li	a7,25
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 396:	48e9                	li	a7,26
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <nullcall>:
.global nullcall
nullcall:
 li a7, SYS_nullcall
 39e:	48ed                	li	a7,27
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <getcycles>:
.global getcycles
getcycles:
 li a7, SYS_getcycles
 3a6:	48f1                	li	a7,28
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <set_filter>:
.global set_filter
set_filter:
 li a7, SYS_set_filter
 3ae:	48f5                	li	a7,29
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3b6:	1101                	addi	sp,sp,-32
 3b8:	ec06                	sd	ra,24(sp)
 3ba:	e822                	sd	s0,16(sp)
 3bc:	1000                	addi	s0,sp,32
 3be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c2:	4605                	li	a2,1
 3c4:	fef40593          	addi	a1,s0,-17
 3c8:	f2fff0ef          	jal	2f6 <write>
}
 3cc:	60e2                	ld	ra,24(sp)
 3ce:	6442                	ld	s0,16(sp)
 3d0:	6105                	addi	sp,sp,32
 3d2:	8082                	ret

00000000000003d4 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 3d4:	715d                	addi	sp,sp,-80
 3d6:	e486                	sd	ra,72(sp)
 3d8:	e0a2                	sd	s0,64(sp)
 3da:	f84a                	sd	s2,48(sp)
 3dc:	0880                	addi	s0,sp,80
 3de:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 3e0:	c299                	beqz	a3,3e6 <printint+0x12>
 3e2:	0805c363          	bltz	a1,468 <printint+0x94>
  neg = 0;
 3e6:	4881                	li	a7,0
 3e8:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 3ec:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 3ee:	00000517          	auipc	a0,0x0
 3f2:	5fa50513          	addi	a0,a0,1530 # 9e8 <digits>
 3f6:	883e                	mv	a6,a5
 3f8:	2785                	addiw	a5,a5,1
 3fa:	02c5f733          	remu	a4,a1,a2
 3fe:	972a                	add	a4,a4,a0
 400:	00074703          	lbu	a4,0(a4)
 404:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 408:	872e                	mv	a4,a1
 40a:	02c5d5b3          	divu	a1,a1,a2
 40e:	0685                	addi	a3,a3,1
 410:	fec773e3          	bgeu	a4,a2,3f6 <printint+0x22>
  if(neg)
 414:	00088b63          	beqz	a7,42a <printint+0x56>
    buf[i++] = '-';
 418:	fd078793          	addi	a5,a5,-48
 41c:	97a2                	add	a5,a5,s0
 41e:	02d00713          	li	a4,45
 422:	fee78423          	sb	a4,-24(a5)
 426:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 42a:	02f05a63          	blez	a5,45e <printint+0x8a>
 42e:	fc26                	sd	s1,56(sp)
 430:	f44e                	sd	s3,40(sp)
 432:	fb840713          	addi	a4,s0,-72
 436:	00f704b3          	add	s1,a4,a5
 43a:	fff70993          	addi	s3,a4,-1
 43e:	99be                	add	s3,s3,a5
 440:	37fd                	addiw	a5,a5,-1
 442:	1782                	slli	a5,a5,0x20
 444:	9381                	srli	a5,a5,0x20
 446:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 44a:	fff4c583          	lbu	a1,-1(s1)
 44e:	854a                	mv	a0,s2
 450:	f67ff0ef          	jal	3b6 <putc>
  while(--i >= 0)
 454:	14fd                	addi	s1,s1,-1
 456:	ff349ae3          	bne	s1,s3,44a <printint+0x76>
 45a:	74e2                	ld	s1,56(sp)
 45c:	79a2                	ld	s3,40(sp)
}
 45e:	60a6                	ld	ra,72(sp)
 460:	6406                	ld	s0,64(sp)
 462:	7942                	ld	s2,48(sp)
 464:	6161                	addi	sp,sp,80
 466:	8082                	ret
    x = -xx;
 468:	40b005b3          	neg	a1,a1
    neg = 1;
 46c:	4885                	li	a7,1
    x = -xx;
 46e:	bfad                	j	3e8 <printint+0x14>

0000000000000470 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 470:	711d                	addi	sp,sp,-96
 472:	ec86                	sd	ra,88(sp)
 474:	e8a2                	sd	s0,80(sp)
 476:	e0ca                	sd	s2,64(sp)
 478:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 47a:	0005c903          	lbu	s2,0(a1)
 47e:	28090663          	beqz	s2,70a <vprintf+0x29a>
 482:	e4a6                	sd	s1,72(sp)
 484:	fc4e                	sd	s3,56(sp)
 486:	f852                	sd	s4,48(sp)
 488:	f456                	sd	s5,40(sp)
 48a:	f05a                	sd	s6,32(sp)
 48c:	ec5e                	sd	s7,24(sp)
 48e:	e862                	sd	s8,16(sp)
 490:	e466                	sd	s9,8(sp)
 492:	8b2a                	mv	s6,a0
 494:	8a2e                	mv	s4,a1
 496:	8bb2                	mv	s7,a2
  state = 0;
 498:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 49a:	4481                	li	s1,0
 49c:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 49e:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4a2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4a6:	06c00c93          	li	s9,108
 4aa:	a005                	j	4ca <vprintf+0x5a>
        putc(fd, c0);
 4ac:	85ca                	mv	a1,s2
 4ae:	855a                	mv	a0,s6
 4b0:	f07ff0ef          	jal	3b6 <putc>
 4b4:	a019                	j	4ba <vprintf+0x4a>
    } else if(state == '%'){
 4b6:	03598263          	beq	s3,s5,4da <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4ba:	2485                	addiw	s1,s1,1
 4bc:	8726                	mv	a4,s1
 4be:	009a07b3          	add	a5,s4,s1
 4c2:	0007c903          	lbu	s2,0(a5)
 4c6:	22090a63          	beqz	s2,6fa <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4ca:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4ce:	fe0994e3          	bnez	s3,4b6 <vprintf+0x46>
      if(c0 == '%'){
 4d2:	fd579de3          	bne	a5,s5,4ac <vprintf+0x3c>
        state = '%';
 4d6:	89be                	mv	s3,a5
 4d8:	b7cd                	j	4ba <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4da:	00ea06b3          	add	a3,s4,a4
 4de:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4e2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4e4:	c681                	beqz	a3,4ec <vprintf+0x7c>
 4e6:	9752                	add	a4,a4,s4
 4e8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4ec:	05878363          	beq	a5,s8,532 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 4f0:	05978d63          	beq	a5,s9,54a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 4f4:	07500713          	li	a4,117
 4f8:	0ee78763          	beq	a5,a4,5e6 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 4fc:	07800713          	li	a4,120
 500:	12e78963          	beq	a5,a4,632 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 504:	07000713          	li	a4,112
 508:	14e78e63          	beq	a5,a4,664 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 50c:	06300713          	li	a4,99
 510:	18e78e63          	beq	a5,a4,6ac <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 514:	07300713          	li	a4,115
 518:	1ae78463          	beq	a5,a4,6c0 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 51c:	02500713          	li	a4,37
 520:	04e79563          	bne	a5,a4,56a <vprintf+0xfa>
        putc(fd, '%');
 524:	02500593          	li	a1,37
 528:	855a                	mv	a0,s6
 52a:	e8dff0ef          	jal	3b6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 52e:	4981                	li	s3,0
 530:	b769                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 532:	008b8913          	addi	s2,s7,8
 536:	4685                	li	a3,1
 538:	4629                	li	a2,10
 53a:	000ba583          	lw	a1,0(s7)
 53e:	855a                	mv	a0,s6
 540:	e95ff0ef          	jal	3d4 <printint>
 544:	8bca                	mv	s7,s2
      state = 0;
 546:	4981                	li	s3,0
 548:	bf8d                	j	4ba <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 54a:	06400793          	li	a5,100
 54e:	02f68963          	beq	a3,a5,580 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 552:	06c00793          	li	a5,108
 556:	04f68263          	beq	a3,a5,59a <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 55a:	07500793          	li	a5,117
 55e:	0af68063          	beq	a3,a5,5fe <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 562:	07800793          	li	a5,120
 566:	0ef68263          	beq	a3,a5,64a <vprintf+0x1da>
        putc(fd, '%');
 56a:	02500593          	li	a1,37
 56e:	855a                	mv	a0,s6
 570:	e47ff0ef          	jal	3b6 <putc>
        putc(fd, c0);
 574:	85ca                	mv	a1,s2
 576:	855a                	mv	a0,s6
 578:	e3fff0ef          	jal	3b6 <putc>
      state = 0;
 57c:	4981                	li	s3,0
 57e:	bf35                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 580:	008b8913          	addi	s2,s7,8
 584:	4685                	li	a3,1
 586:	4629                	li	a2,10
 588:	000bb583          	ld	a1,0(s7)
 58c:	855a                	mv	a0,s6
 58e:	e47ff0ef          	jal	3d4 <printint>
        i += 1;
 592:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 594:	8bca                	mv	s7,s2
      state = 0;
 596:	4981                	li	s3,0
        i += 1;
 598:	b70d                	j	4ba <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 59a:	06400793          	li	a5,100
 59e:	02f60763          	beq	a2,a5,5cc <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5a2:	07500793          	li	a5,117
 5a6:	06f60963          	beq	a2,a5,618 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5aa:	07800793          	li	a5,120
 5ae:	faf61ee3          	bne	a2,a5,56a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5b2:	008b8913          	addi	s2,s7,8
 5b6:	4681                	li	a3,0
 5b8:	4641                	li	a2,16
 5ba:	000bb583          	ld	a1,0(s7)
 5be:	855a                	mv	a0,s6
 5c0:	e15ff0ef          	jal	3d4 <printint>
        i += 2;
 5c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5c6:	8bca                	mv	s7,s2
      state = 0;
 5c8:	4981                	li	s3,0
        i += 2;
 5ca:	bdc5                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5cc:	008b8913          	addi	s2,s7,8
 5d0:	4685                	li	a3,1
 5d2:	4629                	li	a2,10
 5d4:	000bb583          	ld	a1,0(s7)
 5d8:	855a                	mv	a0,s6
 5da:	dfbff0ef          	jal	3d4 <printint>
        i += 2;
 5de:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e0:	8bca                	mv	s7,s2
      state = 0;
 5e2:	4981                	li	s3,0
        i += 2;
 5e4:	bdd9                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 5e6:	008b8913          	addi	s2,s7,8
 5ea:	4681                	li	a3,0
 5ec:	4629                	li	a2,10
 5ee:	000be583          	lwu	a1,0(s7)
 5f2:	855a                	mv	a0,s6
 5f4:	de1ff0ef          	jal	3d4 <printint>
 5f8:	8bca                	mv	s7,s2
      state = 0;
 5fa:	4981                	li	s3,0
 5fc:	bd7d                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5fe:	008b8913          	addi	s2,s7,8
 602:	4681                	li	a3,0
 604:	4629                	li	a2,10
 606:	000bb583          	ld	a1,0(s7)
 60a:	855a                	mv	a0,s6
 60c:	dc9ff0ef          	jal	3d4 <printint>
        i += 1;
 610:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 612:	8bca                	mv	s7,s2
      state = 0;
 614:	4981                	li	s3,0
        i += 1;
 616:	b555                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 618:	008b8913          	addi	s2,s7,8
 61c:	4681                	li	a3,0
 61e:	4629                	li	a2,10
 620:	000bb583          	ld	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	dafff0ef          	jal	3d4 <printint>
        i += 2;
 62a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 62c:	8bca                	mv	s7,s2
      state = 0;
 62e:	4981                	li	s3,0
        i += 2;
 630:	b569                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 632:	008b8913          	addi	s2,s7,8
 636:	4681                	li	a3,0
 638:	4641                	li	a2,16
 63a:	000be583          	lwu	a1,0(s7)
 63e:	855a                	mv	a0,s6
 640:	d95ff0ef          	jal	3d4 <printint>
 644:	8bca                	mv	s7,s2
      state = 0;
 646:	4981                	li	s3,0
 648:	bd8d                	j	4ba <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4681                	li	a3,0
 650:	4641                	li	a2,16
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	d7dff0ef          	jal	3d4 <printint>
        i += 1;
 65c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 1;
 662:	bda1                	j	4ba <vprintf+0x4a>
 664:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 666:	008b8d13          	addi	s10,s7,8
 66a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 66e:	03000593          	li	a1,48
 672:	855a                	mv	a0,s6
 674:	d43ff0ef          	jal	3b6 <putc>
  putc(fd, 'x');
 678:	07800593          	li	a1,120
 67c:	855a                	mv	a0,s6
 67e:	d39ff0ef          	jal	3b6 <putc>
 682:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 684:	00000b97          	auipc	s7,0x0
 688:	364b8b93          	addi	s7,s7,868 # 9e8 <digits>
 68c:	03c9d793          	srli	a5,s3,0x3c
 690:	97de                	add	a5,a5,s7
 692:	0007c583          	lbu	a1,0(a5)
 696:	855a                	mv	a0,s6
 698:	d1fff0ef          	jal	3b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69c:	0992                	slli	s3,s3,0x4
 69e:	397d                	addiw	s2,s2,-1
 6a0:	fe0916e3          	bnez	s2,68c <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6a4:	8bea                	mv	s7,s10
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	6d02                	ld	s10,0(sp)
 6aa:	bd01                	j	4ba <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6ac:	008b8913          	addi	s2,s7,8
 6b0:	000bc583          	lbu	a1,0(s7)
 6b4:	855a                	mv	a0,s6
 6b6:	d01ff0ef          	jal	3b6 <putc>
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
 6be:	bbf5                	j	4ba <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6c0:	008b8993          	addi	s3,s7,8
 6c4:	000bb903          	ld	s2,0(s7)
 6c8:	00090f63          	beqz	s2,6e6 <vprintf+0x276>
        for(; *s; s++)
 6cc:	00094583          	lbu	a1,0(s2)
 6d0:	c195                	beqz	a1,6f4 <vprintf+0x284>
          putc(fd, *s);
 6d2:	855a                	mv	a0,s6
 6d4:	ce3ff0ef          	jal	3b6 <putc>
        for(; *s; s++)
 6d8:	0905                	addi	s2,s2,1
 6da:	00094583          	lbu	a1,0(s2)
 6de:	f9f5                	bnez	a1,6d2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6e0:	8bce                	mv	s7,s3
      state = 0;
 6e2:	4981                	li	s3,0
 6e4:	bbd9                	j	4ba <vprintf+0x4a>
          s = "(null)";
 6e6:	00000917          	auipc	s2,0x0
 6ea:	2fa90913          	addi	s2,s2,762 # 9e0 <malloc+0x1ee>
        for(; *s; s++)
 6ee:	02800593          	li	a1,40
 6f2:	b7c5                	j	6d2 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 6f4:	8bce                	mv	s7,s3
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b3c9                	j	4ba <vprintf+0x4a>
 6fa:	64a6                	ld	s1,72(sp)
 6fc:	79e2                	ld	s3,56(sp)
 6fe:	7a42                	ld	s4,48(sp)
 700:	7aa2                	ld	s5,40(sp)
 702:	7b02                	ld	s6,32(sp)
 704:	6be2                	ld	s7,24(sp)
 706:	6c42                	ld	s8,16(sp)
 708:	6ca2                	ld	s9,8(sp)
    }
  }
}
 70a:	60e6                	ld	ra,88(sp)
 70c:	6446                	ld	s0,80(sp)
 70e:	6906                	ld	s2,64(sp)
 710:	6125                	addi	sp,sp,96
 712:	8082                	ret

0000000000000714 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 714:	715d                	addi	sp,sp,-80
 716:	ec06                	sd	ra,24(sp)
 718:	e822                	sd	s0,16(sp)
 71a:	1000                	addi	s0,sp,32
 71c:	e010                	sd	a2,0(s0)
 71e:	e414                	sd	a3,8(s0)
 720:	e818                	sd	a4,16(s0)
 722:	ec1c                	sd	a5,24(s0)
 724:	03043023          	sd	a6,32(s0)
 728:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 730:	8622                	mv	a2,s0
 732:	d3fff0ef          	jal	470 <vprintf>
}
 736:	60e2                	ld	ra,24(sp)
 738:	6442                	ld	s0,16(sp)
 73a:	6161                	addi	sp,sp,80
 73c:	8082                	ret

000000000000073e <printf>:

void
printf(const char *fmt, ...)
{
 73e:	711d                	addi	sp,sp,-96
 740:	ec06                	sd	ra,24(sp)
 742:	e822                	sd	s0,16(sp)
 744:	1000                	addi	s0,sp,32
 746:	e40c                	sd	a1,8(s0)
 748:	e810                	sd	a2,16(s0)
 74a:	ec14                	sd	a3,24(s0)
 74c:	f018                	sd	a4,32(s0)
 74e:	f41c                	sd	a5,40(s0)
 750:	03043823          	sd	a6,48(s0)
 754:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 758:	00840613          	addi	a2,s0,8
 75c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 760:	85aa                	mv	a1,a0
 762:	4505                	li	a0,1
 764:	d0dff0ef          	jal	470 <vprintf>
}
 768:	60e2                	ld	ra,24(sp)
 76a:	6442                	ld	s0,16(sp)
 76c:	6125                	addi	sp,sp,96
 76e:	8082                	ret

0000000000000770 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 770:	1141                	addi	sp,sp,-16
 772:	e422                	sd	s0,8(sp)
 774:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 776:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 77a:	00001797          	auipc	a5,0x1
 77e:	8867b783          	ld	a5,-1914(a5) # 1000 <freep>
 782:	a02d                	j	7ac <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 784:	4618                	lw	a4,8(a2)
 786:	9f2d                	addw	a4,a4,a1
 788:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 78c:	6398                	ld	a4,0(a5)
 78e:	6310                	ld	a2,0(a4)
 790:	a83d                	j	7ce <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 792:	ff852703          	lw	a4,-8(a0)
 796:	9f31                	addw	a4,a4,a2
 798:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 79a:	ff053683          	ld	a3,-16(a0)
 79e:	a091                	j	7e2 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7a0:	6398                	ld	a4,0(a5)
 7a2:	00e7e463          	bltu	a5,a4,7aa <free+0x3a>
 7a6:	00e6ea63          	bltu	a3,a4,7ba <free+0x4a>
{
 7aa:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ac:	fed7fae3          	bgeu	a5,a3,7a0 <free+0x30>
 7b0:	6398                	ld	a4,0(a5)
 7b2:	00e6e463          	bltu	a3,a4,7ba <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b6:	fee7eae3          	bltu	a5,a4,7aa <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7ba:	ff852583          	lw	a1,-8(a0)
 7be:	6390                	ld	a2,0(a5)
 7c0:	02059813          	slli	a6,a1,0x20
 7c4:	01c85713          	srli	a4,a6,0x1c
 7c8:	9736                	add	a4,a4,a3
 7ca:	fae60de3          	beq	a2,a4,784 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7ce:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7d2:	4790                	lw	a2,8(a5)
 7d4:	02061593          	slli	a1,a2,0x20
 7d8:	01c5d713          	srli	a4,a1,0x1c
 7dc:	973e                	add	a4,a4,a5
 7de:	fae68ae3          	beq	a3,a4,792 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7e2:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7e4:	00001717          	auipc	a4,0x1
 7e8:	80f73e23          	sd	a5,-2020(a4) # 1000 <freep>
}
 7ec:	6422                	ld	s0,8(sp)
 7ee:	0141                	addi	sp,sp,16
 7f0:	8082                	ret

00000000000007f2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7f2:	7139                	addi	sp,sp,-64
 7f4:	fc06                	sd	ra,56(sp)
 7f6:	f822                	sd	s0,48(sp)
 7f8:	f426                	sd	s1,40(sp)
 7fa:	ec4e                	sd	s3,24(sp)
 7fc:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7fe:	02051493          	slli	s1,a0,0x20
 802:	9081                	srli	s1,s1,0x20
 804:	04bd                	addi	s1,s1,15
 806:	8091                	srli	s1,s1,0x4
 808:	0014899b          	addiw	s3,s1,1
 80c:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 80e:	00000517          	auipc	a0,0x0
 812:	7f253503          	ld	a0,2034(a0) # 1000 <freep>
 816:	c915                	beqz	a0,84a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 818:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 81a:	4798                	lw	a4,8(a5)
 81c:	08977a63          	bgeu	a4,s1,8b0 <malloc+0xbe>
 820:	f04a                	sd	s2,32(sp)
 822:	e852                	sd	s4,16(sp)
 824:	e456                	sd	s5,8(sp)
 826:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 828:	8a4e                	mv	s4,s3
 82a:	0009871b          	sext.w	a4,s3
 82e:	6685                	lui	a3,0x1
 830:	00d77363          	bgeu	a4,a3,836 <malloc+0x44>
 834:	6a05                	lui	s4,0x1
 836:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 83a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 83e:	00000917          	auipc	s2,0x0
 842:	7c290913          	addi	s2,s2,1986 # 1000 <freep>
  if(p == SBRK_ERROR)
 846:	5afd                	li	s5,-1
 848:	a081                	j	888 <malloc+0x96>
 84a:	f04a                	sd	s2,32(sp)
 84c:	e852                	sd	s4,16(sp)
 84e:	e456                	sd	s5,8(sp)
 850:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 852:	00000797          	auipc	a5,0x0
 856:	7be78793          	addi	a5,a5,1982 # 1010 <base>
 85a:	00000717          	auipc	a4,0x0
 85e:	7af73323          	sd	a5,1958(a4) # 1000 <freep>
 862:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 864:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 868:	b7c1                	j	828 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 86a:	6398                	ld	a4,0(a5)
 86c:	e118                	sd	a4,0(a0)
 86e:	a8a9                	j	8c8 <malloc+0xd6>
  hp->s.size = nu;
 870:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 874:	0541                	addi	a0,a0,16
 876:	efbff0ef          	jal	770 <free>
  return freep;
 87a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 87e:	c12d                	beqz	a0,8e0 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 880:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 882:	4798                	lw	a4,8(a5)
 884:	02977263          	bgeu	a4,s1,8a8 <malloc+0xb6>
    if(p == freep)
 888:	00093703          	ld	a4,0(s2)
 88c:	853e                	mv	a0,a5
 88e:	fef719e3          	bne	a4,a5,880 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 892:	8552                	mv	a0,s4
 894:	a0fff0ef          	jal	2a2 <sbrk>
  if(p == SBRK_ERROR)
 898:	fd551ce3          	bne	a0,s5,870 <malloc+0x7e>
        return 0;
 89c:	4501                	li	a0,0
 89e:	7902                	ld	s2,32(sp)
 8a0:	6a42                	ld	s4,16(sp)
 8a2:	6aa2                	ld	s5,8(sp)
 8a4:	6b02                	ld	s6,0(sp)
 8a6:	a03d                	j	8d4 <malloc+0xe2>
 8a8:	7902                	ld	s2,32(sp)
 8aa:	6a42                	ld	s4,16(sp)
 8ac:	6aa2                	ld	s5,8(sp)
 8ae:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8b0:	fae48de3          	beq	s1,a4,86a <malloc+0x78>
        p->s.size -= nunits;
 8b4:	4137073b          	subw	a4,a4,s3
 8b8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ba:	02071693          	slli	a3,a4,0x20
 8be:	01c6d713          	srli	a4,a3,0x1c
 8c2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8c4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8c8:	00000717          	auipc	a4,0x0
 8cc:	72a73c23          	sd	a0,1848(a4) # 1000 <freep>
      return (void*)(p + 1);
 8d0:	01078513          	addi	a0,a5,16
  }
}
 8d4:	70e2                	ld	ra,56(sp)
 8d6:	7442                	ld	s0,48(sp)
 8d8:	74a2                	ld	s1,40(sp)
 8da:	69e2                	ld	s3,24(sp)
 8dc:	6121                	addi	sp,sp,64
 8de:	8082                	ret
 8e0:	7902                	ld	s2,32(sp)
 8e2:	6a42                	ld	s4,16(sp)
 8e4:	6aa2                	ld	s5,8(sp)
 8e6:	6b02                	ld	s6,0(sp)
 8e8:	b7f5                	j	8d4 <malloc+0xe2>
