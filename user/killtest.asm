
user/_killtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <execute_bad_behavior>:
#include "kernel/types.h"
#include "user/user.h"

void
execute_bad_behavior()
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  // Ép ghi dữ liệu vào một địa chỉ ảo bất hợp pháp vượt quá kích thước tiến trình (p->sz)
  // để MMU ném trap scause 15 về cho Kernel xử lý
  volatile char *bad_ptr = (char*)0x7FFFFFFF0000L; 
  *bad_ptr = 0xAA; 
   6:	800007b7          	lui	a5,0x80000
   a:	fff7c793          	not	a5,a5
   e:	07c2                	slli	a5,a5,0x10
  10:	faa00713          	li	a4,-86
  14:	00e78023          	sb	a4,0(a5) # ffffffff80000000 <base+0xffffffff7fffeff0>
}
  18:	6422                	ld	s0,8(sp)
  1a:	0141                	addi	sp,sp,16
  1c:	8082                	ret

000000000000001e <test_stride_kill_on_sight>:

void
test_stride_kill_on_sight()
{
  1e:	7179                	addi	sp,sp,-48
  20:	f406                	sd	ra,40(sp)
  22:	f022                	sd	s0,32(sp)
  24:	ec26                	sd	s1,24(sp)
  26:	e84a                	sd	s2,16(sp)
  28:	e44e                	sd	s3,8(sp)
  2a:	1800                	addi	s0,sp,48
  printf("--- BAT DAU KIEM THU CO CHE PHONG THU STRIDE: KILL ON SIGHT ---\n");
  2c:	00001517          	auipc	a0,0x1
  30:	95450513          	addi	a0,a0,-1708 # 980 <malloc+0x100>
  34:	798000ef          	jal	7cc <printf>

  // Giả lập hệ thống liên tục hứng chịu 3 đợt vi phạm bộ nhớ nghiêm trọng
  for(int i = 1; i <= 3; i++) {
  38:	4485                	li	s1,1
    printf("[HE THONG] Phat hien dot vi pham bo nho tiem tang thu: %d\n", i);
  3a:	00001917          	auipc	s2,0x1
  3e:	98e90913          	addi	s2,s2,-1650 # 9c8 <malloc+0x148>
  for(int i = 1; i <= 3; i++) {
  42:	4991                	li	s3,4
    printf("[HE THONG] Phat hien dot vi pham bo nho tiem tang thu: %d\n", i);
  44:	85a6                	mv	a1,s1
  46:	854a                	mv	a0,s2
  48:	784000ef          	jal	7cc <printf>
    
    int pid = fork();
  4c:	310000ef          	jal	35c <fork>
    if(pid < 0) {
  50:	02054c63          	bltz	a0,88 <test_stride_kill_on_sight+0x6a>
      printf("Fork that bai!\n");
      exit(1);
    }

    if(pid == 0) {
  54:	c139                	beqz	a0,9a <test_stride_kill_on_sight+0x7c>
      // Nếu luồng xử lý lỗi không diệt tiến trình, dòng này sẽ bị lọt ra
      printf("[LOI] Kẻ tan cong thoat hiem!\n");
      exit(0);
    } else {
      // Tiến trình cha chờ con bị xử tử xong để tiếp tục vòng lặp theo dõi
      wait(0);
  56:	4501                	li	a0,0
  58:	314000ef          	jal	36c <wait>
  for(int i = 1; i <= 3; i++) {
  5c:	2485                	addiw	s1,s1,1
  5e:	ff3493e3          	bne	s1,s3,44 <test_stride_kill_on_sight+0x26>
    }
  }

  printf("\n[HE THONG] Nguong loi lien tiep da cham muc 3.\n");
  62:	00001517          	auipc	a0,0x1
  66:	9de50513          	addi	a0,a0,-1570 # a40 <malloc+0x1c0>
  6a:	762000ef          	jal	7cc <printf>
  printf("--- KIEM THU PHONG THU STRIDE THANH CONG! ---\n");
  6e:	00001517          	auipc	a0,0x1
  72:	a0a50513          	addi	a0,a0,-1526 # a78 <malloc+0x1f8>
  76:	756000ef          	jal	7cc <printf>
}
  7a:	70a2                	ld	ra,40(sp)
  7c:	7402                	ld	s0,32(sp)
  7e:	64e2                	ld	s1,24(sp)
  80:	6942                	ld	s2,16(sp)
  82:	69a2                	ld	s3,8(sp)
  84:	6145                	addi	sp,sp,48
  86:	8082                	ret
      printf("Fork that bai!\n");
  88:	00001517          	auipc	a0,0x1
  8c:	98050513          	addi	a0,a0,-1664 # a08 <malloc+0x188>
  90:	73c000ef          	jal	7cc <printf>
      exit(1);
  94:	4505                	li	a0,1
  96:	2ce000ef          	jal	364 <exit>
  *bad_ptr = 0xAA; 
  9a:	800007b7          	lui	a5,0x80000
  9e:	fff7c793          	not	a5,a5
  a2:	07c2                	slli	a5,a5,0x10
  a4:	faa00713          	li	a4,-86
  a8:	00e78023          	sb	a4,0(a5) # ffffffff80000000 <base+0xffffffff7fffeff0>
      printf("[LOI] Kẻ tan cong thoat hiem!\n");
  ac:	00001517          	auipc	a0,0x1
  b0:	96c50513          	addi	a0,a0,-1684 # a18 <malloc+0x198>
  b4:	718000ef          	jal	7cc <printf>
      exit(0);
  b8:	4501                	li	a0,0
  ba:	2aa000ef          	jal	364 <exit>

00000000000000be <main>:

int
main(int argc, char *argv[])
{
  be:	1141                	addi	sp,sp,-16
  c0:	e406                	sd	ra,8(sp)
  c2:	e022                	sd	s0,0(sp)
  c4:	0800                	addi	s0,sp,16
  test_stride_kill_on_sight();
  c6:	f59ff0ef          	jal	1e <test_stride_kill_on_sight>
  exit(0);
  ca:	4501                	li	a0,0
  cc:	298000ef          	jal	364 <exit>

00000000000000d0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  d0:	1141                	addi	sp,sp,-16
  d2:	e406                	sd	ra,8(sp)
  d4:	e022                	sd	s0,0(sp)
  d6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  d8:	fe7ff0ef          	jal	be <main>
  exit(r);
  dc:	288000ef          	jal	364 <exit>

00000000000000e0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e0:	1141                	addi	sp,sp,-16
  e2:	e422                	sd	s0,8(sp)
  e4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e6:	87aa                	mv	a5,a0
  e8:	0585                	addi	a1,a1,1
  ea:	0785                	addi	a5,a5,1
  ec:	fff5c703          	lbu	a4,-1(a1)
  f0:	fee78fa3          	sb	a4,-1(a5)
  f4:	fb75                	bnez	a4,e8 <strcpy+0x8>
    ;
  return os;
}
  f6:	6422                	ld	s0,8(sp)
  f8:	0141                	addi	sp,sp,16
  fa:	8082                	ret

00000000000000fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fc:	1141                	addi	sp,sp,-16
  fe:	e422                	sd	s0,8(sp)
 100:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 102:	00054783          	lbu	a5,0(a0)
 106:	cb91                	beqz	a5,11a <strcmp+0x1e>
 108:	0005c703          	lbu	a4,0(a1)
 10c:	00f71763          	bne	a4,a5,11a <strcmp+0x1e>
    p++, q++;
 110:	0505                	addi	a0,a0,1
 112:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 114:	00054783          	lbu	a5,0(a0)
 118:	fbe5                	bnez	a5,108 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 11a:	0005c503          	lbu	a0,0(a1)
}
 11e:	40a7853b          	subw	a0,a5,a0
 122:	6422                	ld	s0,8(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret

0000000000000128 <strlen>:

uint
strlen(const char *s)
{
 128:	1141                	addi	sp,sp,-16
 12a:	e422                	sd	s0,8(sp)
 12c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 12e:	00054783          	lbu	a5,0(a0)
 132:	cf91                	beqz	a5,14e <strlen+0x26>
 134:	0505                	addi	a0,a0,1
 136:	87aa                	mv	a5,a0
 138:	86be                	mv	a3,a5
 13a:	0785                	addi	a5,a5,1
 13c:	fff7c703          	lbu	a4,-1(a5)
 140:	ff65                	bnez	a4,138 <strlen+0x10>
 142:	40a6853b          	subw	a0,a3,a0
 146:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 148:	6422                	ld	s0,8(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret
  for(n = 0; s[n]; n++)
 14e:	4501                	li	a0,0
 150:	bfe5                	j	148 <strlen+0x20>

0000000000000152 <memset>:

void*
memset(void *dst, int c, uint n)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 158:	ca19                	beqz	a2,16e <memset+0x1c>
 15a:	87aa                	mv	a5,a0
 15c:	1602                	slli	a2,a2,0x20
 15e:	9201                	srli	a2,a2,0x20
 160:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 164:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 168:	0785                	addi	a5,a5,1
 16a:	fee79de3          	bne	a5,a4,164 <memset+0x12>
  }
  return dst;
}
 16e:	6422                	ld	s0,8(sp)
 170:	0141                	addi	sp,sp,16
 172:	8082                	ret

0000000000000174 <strchr>:

char*
strchr(const char *s, char c)
{
 174:	1141                	addi	sp,sp,-16
 176:	e422                	sd	s0,8(sp)
 178:	0800                	addi	s0,sp,16
  for(; *s; s++)
 17a:	00054783          	lbu	a5,0(a0)
 17e:	cb99                	beqz	a5,194 <strchr+0x20>
    if(*s == c)
 180:	00f58763          	beq	a1,a5,18e <strchr+0x1a>
  for(; *s; s++)
 184:	0505                	addi	a0,a0,1
 186:	00054783          	lbu	a5,0(a0)
 18a:	fbfd                	bnez	a5,180 <strchr+0xc>
      return (char*)s;
  return 0;
 18c:	4501                	li	a0,0
}
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret
  return 0;
 194:	4501                	li	a0,0
 196:	bfe5                	j	18e <strchr+0x1a>

0000000000000198 <gets>:

char*
gets(char *buf, int max)
{
 198:	711d                	addi	sp,sp,-96
 19a:	ec86                	sd	ra,88(sp)
 19c:	e8a2                	sd	s0,80(sp)
 19e:	e4a6                	sd	s1,72(sp)
 1a0:	e0ca                	sd	s2,64(sp)
 1a2:	fc4e                	sd	s3,56(sp)
 1a4:	f852                	sd	s4,48(sp)
 1a6:	f456                	sd	s5,40(sp)
 1a8:	f05a                	sd	s6,32(sp)
 1aa:	ec5e                	sd	s7,24(sp)
 1ac:	1080                	addi	s0,sp,96
 1ae:	8baa                	mv	s7,a0
 1b0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1b2:	892a                	mv	s2,a0
 1b4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1b6:	4aa9                	li	s5,10
 1b8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ba:	89a6                	mv	s3,s1
 1bc:	2485                	addiw	s1,s1,1
 1be:	0344d663          	bge	s1,s4,1ea <gets+0x52>
    cc = read(0, &c, 1);
 1c2:	4605                	li	a2,1
 1c4:	faf40593          	addi	a1,s0,-81
 1c8:	4501                	li	a0,0
 1ca:	1b2000ef          	jal	37c <read>
    if(cc < 1)
 1ce:	00a05e63          	blez	a0,1ea <gets+0x52>
    buf[i++] = c;
 1d2:	faf44783          	lbu	a5,-81(s0)
 1d6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1da:	01578763          	beq	a5,s5,1e8 <gets+0x50>
 1de:	0905                	addi	s2,s2,1
 1e0:	fd679de3          	bne	a5,s6,1ba <gets+0x22>
    buf[i++] = c;
 1e4:	89a6                	mv	s3,s1
 1e6:	a011                	j	1ea <gets+0x52>
 1e8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1ea:	99de                	add	s3,s3,s7
 1ec:	00098023          	sb	zero,0(s3)
  return buf;
}
 1f0:	855e                	mv	a0,s7
 1f2:	60e6                	ld	ra,88(sp)
 1f4:	6446                	ld	s0,80(sp)
 1f6:	64a6                	ld	s1,72(sp)
 1f8:	6906                	ld	s2,64(sp)
 1fa:	79e2                	ld	s3,56(sp)
 1fc:	7a42                	ld	s4,48(sp)
 1fe:	7aa2                	ld	s5,40(sp)
 200:	7b02                	ld	s6,32(sp)
 202:	6be2                	ld	s7,24(sp)
 204:	6125                	addi	sp,sp,96
 206:	8082                	ret

0000000000000208 <stat>:

int
stat(const char *n, struct stat *st)
{
 208:	1101                	addi	sp,sp,-32
 20a:	ec06                	sd	ra,24(sp)
 20c:	e822                	sd	s0,16(sp)
 20e:	e04a                	sd	s2,0(sp)
 210:	1000                	addi	s0,sp,32
 212:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 214:	4581                	li	a1,0
 216:	18e000ef          	jal	3a4 <open>
  if(fd < 0)
 21a:	02054263          	bltz	a0,23e <stat+0x36>
 21e:	e426                	sd	s1,8(sp)
 220:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 222:	85ca                	mv	a1,s2
 224:	198000ef          	jal	3bc <fstat>
 228:	892a                	mv	s2,a0
  close(fd);
 22a:	8526                	mv	a0,s1
 22c:	160000ef          	jal	38c <close>
  return r;
 230:	64a2                	ld	s1,8(sp)
}
 232:	854a                	mv	a0,s2
 234:	60e2                	ld	ra,24(sp)
 236:	6442                	ld	s0,16(sp)
 238:	6902                	ld	s2,0(sp)
 23a:	6105                	addi	sp,sp,32
 23c:	8082                	ret
    return -1;
 23e:	597d                	li	s2,-1
 240:	bfcd                	j	232 <stat+0x2a>

0000000000000242 <atoi>:

int
atoi(const char *s)
{
 242:	1141                	addi	sp,sp,-16
 244:	e422                	sd	s0,8(sp)
 246:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 248:	00054683          	lbu	a3,0(a0)
 24c:	fd06879b          	addiw	a5,a3,-48
 250:	0ff7f793          	zext.b	a5,a5
 254:	4625                	li	a2,9
 256:	02f66863          	bltu	a2,a5,286 <atoi+0x44>
 25a:	872a                	mv	a4,a0
  n = 0;
 25c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 25e:	0705                	addi	a4,a4,1
 260:	0025179b          	slliw	a5,a0,0x2
 264:	9fa9                	addw	a5,a5,a0
 266:	0017979b          	slliw	a5,a5,0x1
 26a:	9fb5                	addw	a5,a5,a3
 26c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 270:	00074683          	lbu	a3,0(a4)
 274:	fd06879b          	addiw	a5,a3,-48
 278:	0ff7f793          	zext.b	a5,a5
 27c:	fef671e3          	bgeu	a2,a5,25e <atoi+0x1c>
  return n;
}
 280:	6422                	ld	s0,8(sp)
 282:	0141                	addi	sp,sp,16
 284:	8082                	ret
  n = 0;
 286:	4501                	li	a0,0
 288:	bfe5                	j	280 <atoi+0x3e>

000000000000028a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28a:	1141                	addi	sp,sp,-16
 28c:	e422                	sd	s0,8(sp)
 28e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 290:	02b57463          	bgeu	a0,a1,2b8 <memmove+0x2e>
    while(n-- > 0)
 294:	00c05f63          	blez	a2,2b2 <memmove+0x28>
 298:	1602                	slli	a2,a2,0x20
 29a:	9201                	srli	a2,a2,0x20
 29c:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a2:	0585                	addi	a1,a1,1
 2a4:	0705                	addi	a4,a4,1
 2a6:	fff5c683          	lbu	a3,-1(a1)
 2aa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2ae:	fef71ae3          	bne	a4,a5,2a2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret
    dst += n;
 2b8:	00c50733          	add	a4,a0,a2
    src += n;
 2bc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2be:	fec05ae3          	blez	a2,2b2 <memmove+0x28>
 2c2:	fff6079b          	addiw	a5,a2,-1
 2c6:	1782                	slli	a5,a5,0x20
 2c8:	9381                	srli	a5,a5,0x20
 2ca:	fff7c793          	not	a5,a5
 2ce:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d0:	15fd                	addi	a1,a1,-1
 2d2:	177d                	addi	a4,a4,-1
 2d4:	0005c683          	lbu	a3,0(a1)
 2d8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2dc:	fee79ae3          	bne	a5,a4,2d0 <memmove+0x46>
 2e0:	bfc9                	j	2b2 <memmove+0x28>

00000000000002e2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e2:	1141                	addi	sp,sp,-16
 2e4:	e422                	sd	s0,8(sp)
 2e6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2e8:	ca05                	beqz	a2,318 <memcmp+0x36>
 2ea:	fff6069b          	addiw	a3,a2,-1
 2ee:	1682                	slli	a3,a3,0x20
 2f0:	9281                	srli	a3,a3,0x20
 2f2:	0685                	addi	a3,a3,1
 2f4:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2f6:	00054783          	lbu	a5,0(a0)
 2fa:	0005c703          	lbu	a4,0(a1)
 2fe:	00e79863          	bne	a5,a4,30e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 302:	0505                	addi	a0,a0,1
    p2++;
 304:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 306:	fed518e3          	bne	a0,a3,2f6 <memcmp+0x14>
  }
  return 0;
 30a:	4501                	li	a0,0
 30c:	a019                	j	312 <memcmp+0x30>
      return *p1 - *p2;
 30e:	40e7853b          	subw	a0,a5,a4
}
 312:	6422                	ld	s0,8(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret
  return 0;
 318:	4501                	li	a0,0
 31a:	bfe5                	j	312 <memcmp+0x30>

000000000000031c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e406                	sd	ra,8(sp)
 320:	e022                	sd	s0,0(sp)
 322:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 324:	f67ff0ef          	jal	28a <memmove>
}
 328:	60a2                	ld	ra,8(sp)
 32a:	6402                	ld	s0,0(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret

0000000000000330 <sbrk>:

char *
sbrk(int n) {
 330:	1141                	addi	sp,sp,-16
 332:	e406                	sd	ra,8(sp)
 334:	e022                	sd	s0,0(sp)
 336:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 338:	4585                	li	a1,1
 33a:	0b2000ef          	jal	3ec <sys_sbrk>
}
 33e:	60a2                	ld	ra,8(sp)
 340:	6402                	ld	s0,0(sp)
 342:	0141                	addi	sp,sp,16
 344:	8082                	ret

0000000000000346 <sbrklazy>:

char *
sbrklazy(int n) {
 346:	1141                	addi	sp,sp,-16
 348:	e406                	sd	ra,8(sp)
 34a:	e022                	sd	s0,0(sp)
 34c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 34e:	4589                	li	a1,2
 350:	09c000ef          	jal	3ec <sys_sbrk>
}
 354:	60a2                	ld	ra,8(sp)
 356:	6402                	ld	s0,0(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret

000000000000035c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 35c:	4885                	li	a7,1
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <exit>:
.global exit
exit:
 li a7, SYS_exit
 364:	4889                	li	a7,2
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <wait>:
.global wait
wait:
 li a7, SYS_wait
 36c:	488d                	li	a7,3
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 374:	4891                	li	a7,4
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <read>:
.global read
read:
 li a7, SYS_read
 37c:	4895                	li	a7,5
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <write>:
.global write
write:
 li a7, SYS_write
 384:	48c1                	li	a7,16
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <close>:
.global close
close:
 li a7, SYS_close
 38c:	48d5                	li	a7,21
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <kill>:
.global kill
kill:
 li a7, SYS_kill
 394:	4899                	li	a7,6
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <exec>:
.global exec
exec:
 li a7, SYS_exec
 39c:	489d                	li	a7,7
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <open>:
.global open
open:
 li a7, SYS_open
 3a4:	48bd                	li	a7,15
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3ac:	48c5                	li	a7,17
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3b4:	48c9                	li	a7,18
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3bc:	48a1                	li	a7,8
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <link>:
.global link
link:
 li a7, SYS_link
 3c4:	48cd                	li	a7,19
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3cc:	48d1                	li	a7,20
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3d4:	48a5                	li	a7,9
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3dc:	48a9                	li	a7,10
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3e4:	48ad                	li	a7,11
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3ec:	48b1                	li	a7,12
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <pause>:
.global pause
pause:
 li a7, SYS_pause
 3f4:	48b5                	li	a7,13
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3fc:	48b9                	li	a7,14
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <hello>:
.global hello
hello:
 li a7, SYS_hello
 404:	48d9                	li	a7,22
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <ps>:
.global ps
ps:
 li a7, SYS_ps
 40c:	48dd                	li	a7,23
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <memtest>:
.global memtest
memtest:
 li a7, SYS_memtest
 414:	48e1                	li	a7,24
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <testnolock>:
.global testnolock
testnolock:
 li a7, SYS_testnolock
 41c:	48e5                	li	a7,25
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <testlock>:
.global testlock
testlock:
 li a7, SYS_testlock
 424:	48e9                	li	a7,26
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <nullcall>:
.global nullcall
nullcall:
 li a7, SYS_nullcall
 42c:	48ed                	li	a7,27
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <getcycles>:
.global getcycles
getcycles:
 li a7, SYS_getcycles
 434:	48f1                	li	a7,28
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <set_filter>:
.global set_filter
set_filter:
 li a7, SYS_set_filter
 43c:	48f5                	li	a7,29
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 444:	1101                	addi	sp,sp,-32
 446:	ec06                	sd	ra,24(sp)
 448:	e822                	sd	s0,16(sp)
 44a:	1000                	addi	s0,sp,32
 44c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 450:	4605                	li	a2,1
 452:	fef40593          	addi	a1,s0,-17
 456:	f2fff0ef          	jal	384 <write>
}
 45a:	60e2                	ld	ra,24(sp)
 45c:	6442                	ld	s0,16(sp)
 45e:	6105                	addi	sp,sp,32
 460:	8082                	ret

0000000000000462 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 462:	715d                	addi	sp,sp,-80
 464:	e486                	sd	ra,72(sp)
 466:	e0a2                	sd	s0,64(sp)
 468:	f84a                	sd	s2,48(sp)
 46a:	0880                	addi	s0,sp,80
 46c:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	c299                	beqz	a3,474 <printint+0x12>
 470:	0805c363          	bltz	a1,4f6 <printint+0x94>
  neg = 0;
 474:	4881                	li	a7,0
 476:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 47a:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 47c:	00000517          	auipc	a0,0x0
 480:	63450513          	addi	a0,a0,1588 # ab0 <digits>
 484:	883e                	mv	a6,a5
 486:	2785                	addiw	a5,a5,1
 488:	02c5f733          	remu	a4,a1,a2
 48c:	972a                	add	a4,a4,a0
 48e:	00074703          	lbu	a4,0(a4)
 492:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 496:	872e                	mv	a4,a1
 498:	02c5d5b3          	divu	a1,a1,a2
 49c:	0685                	addi	a3,a3,1
 49e:	fec773e3          	bgeu	a4,a2,484 <printint+0x22>
  if(neg)
 4a2:	00088b63          	beqz	a7,4b8 <printint+0x56>
    buf[i++] = '-';
 4a6:	fd078793          	addi	a5,a5,-48
 4aa:	97a2                	add	a5,a5,s0
 4ac:	02d00713          	li	a4,45
 4b0:	fee78423          	sb	a4,-24(a5)
 4b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4b8:	02f05a63          	blez	a5,4ec <printint+0x8a>
 4bc:	fc26                	sd	s1,56(sp)
 4be:	f44e                	sd	s3,40(sp)
 4c0:	fb840713          	addi	a4,s0,-72
 4c4:	00f704b3          	add	s1,a4,a5
 4c8:	fff70993          	addi	s3,a4,-1
 4cc:	99be                	add	s3,s3,a5
 4ce:	37fd                	addiw	a5,a5,-1
 4d0:	1782                	slli	a5,a5,0x20
 4d2:	9381                	srli	a5,a5,0x20
 4d4:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 4d8:	fff4c583          	lbu	a1,-1(s1)
 4dc:	854a                	mv	a0,s2
 4de:	f67ff0ef          	jal	444 <putc>
  while(--i >= 0)
 4e2:	14fd                	addi	s1,s1,-1
 4e4:	ff349ae3          	bne	s1,s3,4d8 <printint+0x76>
 4e8:	74e2                	ld	s1,56(sp)
 4ea:	79a2                	ld	s3,40(sp)
}
 4ec:	60a6                	ld	ra,72(sp)
 4ee:	6406                	ld	s0,64(sp)
 4f0:	7942                	ld	s2,48(sp)
 4f2:	6161                	addi	sp,sp,80
 4f4:	8082                	ret
    x = -xx;
 4f6:	40b005b3          	neg	a1,a1
    neg = 1;
 4fa:	4885                	li	a7,1
    x = -xx;
 4fc:	bfad                	j	476 <printint+0x14>

00000000000004fe <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4fe:	711d                	addi	sp,sp,-96
 500:	ec86                	sd	ra,88(sp)
 502:	e8a2                	sd	s0,80(sp)
 504:	e0ca                	sd	s2,64(sp)
 506:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 508:	0005c903          	lbu	s2,0(a1)
 50c:	28090663          	beqz	s2,798 <vprintf+0x29a>
 510:	e4a6                	sd	s1,72(sp)
 512:	fc4e                	sd	s3,56(sp)
 514:	f852                	sd	s4,48(sp)
 516:	f456                	sd	s5,40(sp)
 518:	f05a                	sd	s6,32(sp)
 51a:	ec5e                	sd	s7,24(sp)
 51c:	e862                	sd	s8,16(sp)
 51e:	e466                	sd	s9,8(sp)
 520:	8b2a                	mv	s6,a0
 522:	8a2e                	mv	s4,a1
 524:	8bb2                	mv	s7,a2
  state = 0;
 526:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 528:	4481                	li	s1,0
 52a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 52c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 530:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 534:	06c00c93          	li	s9,108
 538:	a005                	j	558 <vprintf+0x5a>
        putc(fd, c0);
 53a:	85ca                	mv	a1,s2
 53c:	855a                	mv	a0,s6
 53e:	f07ff0ef          	jal	444 <putc>
 542:	a019                	j	548 <vprintf+0x4a>
    } else if(state == '%'){
 544:	03598263          	beq	s3,s5,568 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 548:	2485                	addiw	s1,s1,1
 54a:	8726                	mv	a4,s1
 54c:	009a07b3          	add	a5,s4,s1
 550:	0007c903          	lbu	s2,0(a5)
 554:	22090a63          	beqz	s2,788 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 558:	0009079b          	sext.w	a5,s2
    if(state == 0){
 55c:	fe0994e3          	bnez	s3,544 <vprintf+0x46>
      if(c0 == '%'){
 560:	fd579de3          	bne	a5,s5,53a <vprintf+0x3c>
        state = '%';
 564:	89be                	mv	s3,a5
 566:	b7cd                	j	548 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 568:	00ea06b3          	add	a3,s4,a4
 56c:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 570:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 572:	c681                	beqz	a3,57a <vprintf+0x7c>
 574:	9752                	add	a4,a4,s4
 576:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 57a:	05878363          	beq	a5,s8,5c0 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 57e:	05978d63          	beq	a5,s9,5d8 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 582:	07500713          	li	a4,117
 586:	0ee78763          	beq	a5,a4,674 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 58a:	07800713          	li	a4,120
 58e:	12e78963          	beq	a5,a4,6c0 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 592:	07000713          	li	a4,112
 596:	14e78e63          	beq	a5,a4,6f2 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 59a:	06300713          	li	a4,99
 59e:	18e78e63          	beq	a5,a4,73a <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5a2:	07300713          	li	a4,115
 5a6:	1ae78463          	beq	a5,a4,74e <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5aa:	02500713          	li	a4,37
 5ae:	04e79563          	bne	a5,a4,5f8 <vprintf+0xfa>
        putc(fd, '%');
 5b2:	02500593          	li	a1,37
 5b6:	855a                	mv	a0,s6
 5b8:	e8dff0ef          	jal	444 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5bc:	4981                	li	s3,0
 5be:	b769                	j	548 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5c0:	008b8913          	addi	s2,s7,8
 5c4:	4685                	li	a3,1
 5c6:	4629                	li	a2,10
 5c8:	000ba583          	lw	a1,0(s7)
 5cc:	855a                	mv	a0,s6
 5ce:	e95ff0ef          	jal	462 <printint>
 5d2:	8bca                	mv	s7,s2
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	bf8d                	j	548 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 5d8:	06400793          	li	a5,100
 5dc:	02f68963          	beq	a3,a5,60e <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5e0:	06c00793          	li	a5,108
 5e4:	04f68263          	beq	a3,a5,628 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 5e8:	07500793          	li	a5,117
 5ec:	0af68063          	beq	a3,a5,68c <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 5f0:	07800793          	li	a5,120
 5f4:	0ef68263          	beq	a3,a5,6d8 <vprintf+0x1da>
        putc(fd, '%');
 5f8:	02500593          	li	a1,37
 5fc:	855a                	mv	a0,s6
 5fe:	e47ff0ef          	jal	444 <putc>
        putc(fd, c0);
 602:	85ca                	mv	a1,s2
 604:	855a                	mv	a0,s6
 606:	e3fff0ef          	jal	444 <putc>
      state = 0;
 60a:	4981                	li	s3,0
 60c:	bf35                	j	548 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 60e:	008b8913          	addi	s2,s7,8
 612:	4685                	li	a3,1
 614:	4629                	li	a2,10
 616:	000bb583          	ld	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	e47ff0ef          	jal	462 <printint>
        i += 1;
 620:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
        i += 1;
 626:	b70d                	j	548 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 628:	06400793          	li	a5,100
 62c:	02f60763          	beq	a2,a5,65a <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 630:	07500793          	li	a5,117
 634:	06f60963          	beq	a2,a5,6a6 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 638:	07800793          	li	a5,120
 63c:	faf61ee3          	bne	a2,a5,5f8 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 640:	008b8913          	addi	s2,s7,8
 644:	4681                	li	a3,0
 646:	4641                	li	a2,16
 648:	000bb583          	ld	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	e15ff0ef          	jal	462 <printint>
        i += 2;
 652:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
        i += 2;
 658:	bdc5                	j	548 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4685                	li	a3,1
 660:	4629                	li	a2,10
 662:	000bb583          	ld	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	dfbff0ef          	jal	462 <printint>
        i += 2;
 66c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
        i += 2;
 672:	bdd9                	j	548 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4629                	li	a2,10
 67c:	000be583          	lwu	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	de1ff0ef          	jal	462 <printint>
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bd7d                	j	548 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000bb583          	ld	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	dc9ff0ef          	jal	462 <printint>
        i += 1;
 69e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
        i += 1;
 6a4:	b555                	j	548 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b8913          	addi	s2,s7,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000bb583          	ld	a1,0(s7)
 6b2:	855a                	mv	a0,s6
 6b4:	dafff0ef          	jal	462 <printint>
        i += 2;
 6b8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ba:	8bca                	mv	s7,s2
      state = 0;
 6bc:	4981                	li	s3,0
        i += 2;
 6be:	b569                	j	548 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6c0:	008b8913          	addi	s2,s7,8
 6c4:	4681                	li	a3,0
 6c6:	4641                	li	a2,16
 6c8:	000be583          	lwu	a1,0(s7)
 6cc:	855a                	mv	a0,s6
 6ce:	d95ff0ef          	jal	462 <printint>
 6d2:	8bca                	mv	s7,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	bd8d                	j	548 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d8:	008b8913          	addi	s2,s7,8
 6dc:	4681                	li	a3,0
 6de:	4641                	li	a2,16
 6e0:	000bb583          	ld	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	d7dff0ef          	jal	462 <printint>
        i += 1;
 6ea:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ec:	8bca                	mv	s7,s2
      state = 0;
 6ee:	4981                	li	s3,0
        i += 1;
 6f0:	bda1                	j	548 <vprintf+0x4a>
 6f2:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6f4:	008b8d13          	addi	s10,s7,8
 6f8:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6fc:	03000593          	li	a1,48
 700:	855a                	mv	a0,s6
 702:	d43ff0ef          	jal	444 <putc>
  putc(fd, 'x');
 706:	07800593          	li	a1,120
 70a:	855a                	mv	a0,s6
 70c:	d39ff0ef          	jal	444 <putc>
 710:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 712:	00000b97          	auipc	s7,0x0
 716:	39eb8b93          	addi	s7,s7,926 # ab0 <digits>
 71a:	03c9d793          	srli	a5,s3,0x3c
 71e:	97de                	add	a5,a5,s7
 720:	0007c583          	lbu	a1,0(a5)
 724:	855a                	mv	a0,s6
 726:	d1fff0ef          	jal	444 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 72a:	0992                	slli	s3,s3,0x4
 72c:	397d                	addiw	s2,s2,-1
 72e:	fe0916e3          	bnez	s2,71a <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 732:	8bea                	mv	s7,s10
      state = 0;
 734:	4981                	li	s3,0
 736:	6d02                	ld	s10,0(sp)
 738:	bd01                	j	548 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 73a:	008b8913          	addi	s2,s7,8
 73e:	000bc583          	lbu	a1,0(s7)
 742:	855a                	mv	a0,s6
 744:	d01ff0ef          	jal	444 <putc>
 748:	8bca                	mv	s7,s2
      state = 0;
 74a:	4981                	li	s3,0
 74c:	bbf5                	j	548 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 74e:	008b8993          	addi	s3,s7,8
 752:	000bb903          	ld	s2,0(s7)
 756:	00090f63          	beqz	s2,774 <vprintf+0x276>
        for(; *s; s++)
 75a:	00094583          	lbu	a1,0(s2)
 75e:	c195                	beqz	a1,782 <vprintf+0x284>
          putc(fd, *s);
 760:	855a                	mv	a0,s6
 762:	ce3ff0ef          	jal	444 <putc>
        for(; *s; s++)
 766:	0905                	addi	s2,s2,1
 768:	00094583          	lbu	a1,0(s2)
 76c:	f9f5                	bnez	a1,760 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 76e:	8bce                	mv	s7,s3
      state = 0;
 770:	4981                	li	s3,0
 772:	bbd9                	j	548 <vprintf+0x4a>
          s = "(null)";
 774:	00000917          	auipc	s2,0x0
 778:	33490913          	addi	s2,s2,820 # aa8 <malloc+0x228>
        for(; *s; s++)
 77c:	02800593          	li	a1,40
 780:	b7c5                	j	760 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 782:	8bce                	mv	s7,s3
      state = 0;
 784:	4981                	li	s3,0
 786:	b3c9                	j	548 <vprintf+0x4a>
 788:	64a6                	ld	s1,72(sp)
 78a:	79e2                	ld	s3,56(sp)
 78c:	7a42                	ld	s4,48(sp)
 78e:	7aa2                	ld	s5,40(sp)
 790:	7b02                	ld	s6,32(sp)
 792:	6be2                	ld	s7,24(sp)
 794:	6c42                	ld	s8,16(sp)
 796:	6ca2                	ld	s9,8(sp)
    }
  }
}
 798:	60e6                	ld	ra,88(sp)
 79a:	6446                	ld	s0,80(sp)
 79c:	6906                	ld	s2,64(sp)
 79e:	6125                	addi	sp,sp,96
 7a0:	8082                	ret

00000000000007a2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7a2:	715d                	addi	sp,sp,-80
 7a4:	ec06                	sd	ra,24(sp)
 7a6:	e822                	sd	s0,16(sp)
 7a8:	1000                	addi	s0,sp,32
 7aa:	e010                	sd	a2,0(s0)
 7ac:	e414                	sd	a3,8(s0)
 7ae:	e818                	sd	a4,16(s0)
 7b0:	ec1c                	sd	a5,24(s0)
 7b2:	03043023          	sd	a6,32(s0)
 7b6:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ba:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7be:	8622                	mv	a2,s0
 7c0:	d3fff0ef          	jal	4fe <vprintf>
}
 7c4:	60e2                	ld	ra,24(sp)
 7c6:	6442                	ld	s0,16(sp)
 7c8:	6161                	addi	sp,sp,80
 7ca:	8082                	ret

00000000000007cc <printf>:

void
printf(const char *fmt, ...)
{
 7cc:	711d                	addi	sp,sp,-96
 7ce:	ec06                	sd	ra,24(sp)
 7d0:	e822                	sd	s0,16(sp)
 7d2:	1000                	addi	s0,sp,32
 7d4:	e40c                	sd	a1,8(s0)
 7d6:	e810                	sd	a2,16(s0)
 7d8:	ec14                	sd	a3,24(s0)
 7da:	f018                	sd	a4,32(s0)
 7dc:	f41c                	sd	a5,40(s0)
 7de:	03043823          	sd	a6,48(s0)
 7e2:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7e6:	00840613          	addi	a2,s0,8
 7ea:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7ee:	85aa                	mv	a1,a0
 7f0:	4505                	li	a0,1
 7f2:	d0dff0ef          	jal	4fe <vprintf>
}
 7f6:	60e2                	ld	ra,24(sp)
 7f8:	6442                	ld	s0,16(sp)
 7fa:	6125                	addi	sp,sp,96
 7fc:	8082                	ret

00000000000007fe <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7fe:	1141                	addi	sp,sp,-16
 800:	e422                	sd	s0,8(sp)
 802:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 804:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 808:	00000797          	auipc	a5,0x0
 80c:	7f87b783          	ld	a5,2040(a5) # 1000 <freep>
 810:	a02d                	j	83a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 812:	4618                	lw	a4,8(a2)
 814:	9f2d                	addw	a4,a4,a1
 816:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 81a:	6398                	ld	a4,0(a5)
 81c:	6310                	ld	a2,0(a4)
 81e:	a83d                	j	85c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 820:	ff852703          	lw	a4,-8(a0)
 824:	9f31                	addw	a4,a4,a2
 826:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 828:	ff053683          	ld	a3,-16(a0)
 82c:	a091                	j	870 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 82e:	6398                	ld	a4,0(a5)
 830:	00e7e463          	bltu	a5,a4,838 <free+0x3a>
 834:	00e6ea63          	bltu	a3,a4,848 <free+0x4a>
{
 838:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 83a:	fed7fae3          	bgeu	a5,a3,82e <free+0x30>
 83e:	6398                	ld	a4,0(a5)
 840:	00e6e463          	bltu	a3,a4,848 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	fee7eae3          	bltu	a5,a4,838 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 848:	ff852583          	lw	a1,-8(a0)
 84c:	6390                	ld	a2,0(a5)
 84e:	02059813          	slli	a6,a1,0x20
 852:	01c85713          	srli	a4,a6,0x1c
 856:	9736                	add	a4,a4,a3
 858:	fae60de3          	beq	a2,a4,812 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 85c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 860:	4790                	lw	a2,8(a5)
 862:	02061593          	slli	a1,a2,0x20
 866:	01c5d713          	srli	a4,a1,0x1c
 86a:	973e                	add	a4,a4,a5
 86c:	fae68ae3          	beq	a3,a4,820 <free+0x22>
    p->s.ptr = bp->s.ptr;
 870:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 872:	00000717          	auipc	a4,0x0
 876:	78f73723          	sd	a5,1934(a4) # 1000 <freep>
}
 87a:	6422                	ld	s0,8(sp)
 87c:	0141                	addi	sp,sp,16
 87e:	8082                	ret

0000000000000880 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 880:	7139                	addi	sp,sp,-64
 882:	fc06                	sd	ra,56(sp)
 884:	f822                	sd	s0,48(sp)
 886:	f426                	sd	s1,40(sp)
 888:	ec4e                	sd	s3,24(sp)
 88a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 88c:	02051493          	slli	s1,a0,0x20
 890:	9081                	srli	s1,s1,0x20
 892:	04bd                	addi	s1,s1,15
 894:	8091                	srli	s1,s1,0x4
 896:	0014899b          	addiw	s3,s1,1
 89a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 89c:	00000517          	auipc	a0,0x0
 8a0:	76453503          	ld	a0,1892(a0) # 1000 <freep>
 8a4:	c915                	beqz	a0,8d8 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8a6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8a8:	4798                	lw	a4,8(a5)
 8aa:	08977a63          	bgeu	a4,s1,93e <malloc+0xbe>
 8ae:	f04a                	sd	s2,32(sp)
 8b0:	e852                	sd	s4,16(sp)
 8b2:	e456                	sd	s5,8(sp)
 8b4:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8b6:	8a4e                	mv	s4,s3
 8b8:	0009871b          	sext.w	a4,s3
 8bc:	6685                	lui	a3,0x1
 8be:	00d77363          	bgeu	a4,a3,8c4 <malloc+0x44>
 8c2:	6a05                	lui	s4,0x1
 8c4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8c8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8cc:	00000917          	auipc	s2,0x0
 8d0:	73490913          	addi	s2,s2,1844 # 1000 <freep>
  if(p == SBRK_ERROR)
 8d4:	5afd                	li	s5,-1
 8d6:	a081                	j	916 <malloc+0x96>
 8d8:	f04a                	sd	s2,32(sp)
 8da:	e852                	sd	s4,16(sp)
 8dc:	e456                	sd	s5,8(sp)
 8de:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 8e0:	00000797          	auipc	a5,0x0
 8e4:	73078793          	addi	a5,a5,1840 # 1010 <base>
 8e8:	00000717          	auipc	a4,0x0
 8ec:	70f73c23          	sd	a5,1816(a4) # 1000 <freep>
 8f0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8f2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8f6:	b7c1                	j	8b6 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 8f8:	6398                	ld	a4,0(a5)
 8fa:	e118                	sd	a4,0(a0)
 8fc:	a8a9                	j	956 <malloc+0xd6>
  hp->s.size = nu;
 8fe:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 902:	0541                	addi	a0,a0,16
 904:	efbff0ef          	jal	7fe <free>
  return freep;
 908:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 90c:	c12d                	beqz	a0,96e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 910:	4798                	lw	a4,8(a5)
 912:	02977263          	bgeu	a4,s1,936 <malloc+0xb6>
    if(p == freep)
 916:	00093703          	ld	a4,0(s2)
 91a:	853e                	mv	a0,a5
 91c:	fef719e3          	bne	a4,a5,90e <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 920:	8552                	mv	a0,s4
 922:	a0fff0ef          	jal	330 <sbrk>
  if(p == SBRK_ERROR)
 926:	fd551ce3          	bne	a0,s5,8fe <malloc+0x7e>
        return 0;
 92a:	4501                	li	a0,0
 92c:	7902                	ld	s2,32(sp)
 92e:	6a42                	ld	s4,16(sp)
 930:	6aa2                	ld	s5,8(sp)
 932:	6b02                	ld	s6,0(sp)
 934:	a03d                	j	962 <malloc+0xe2>
 936:	7902                	ld	s2,32(sp)
 938:	6a42                	ld	s4,16(sp)
 93a:	6aa2                	ld	s5,8(sp)
 93c:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 93e:	fae48de3          	beq	s1,a4,8f8 <malloc+0x78>
        p->s.size -= nunits;
 942:	4137073b          	subw	a4,a4,s3
 946:	c798                	sw	a4,8(a5)
        p += p->s.size;
 948:	02071693          	slli	a3,a4,0x20
 94c:	01c6d713          	srli	a4,a3,0x1c
 950:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 952:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 956:	00000717          	auipc	a4,0x0
 95a:	6aa73523          	sd	a0,1706(a4) # 1000 <freep>
      return (void*)(p + 1);
 95e:	01078513          	addi	a0,a5,16
  }
}
 962:	70e2                	ld	ra,56(sp)
 964:	7442                	ld	s0,48(sp)
 966:	74a2                	ld	s1,40(sp)
 968:	69e2                	ld	s3,24(sp)
 96a:	6121                	addi	sp,sp,64
 96c:	8082                	ret
 96e:	7902                	ld	s2,32(sp)
 970:	6a42                	ld	s4,16(sp)
 972:	6aa2                	ld	s5,8(sp)
 974:	6b02                	ld	s6,0(sp)
 976:	b7f5                	j	962 <malloc+0xe2>
