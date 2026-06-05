
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00009117          	auipc	sp,0x9
    80000004:	d1010113          	addi	sp,sp,-752 # 80008d10 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdbbfb7>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	f6678793          	addi	a5,a5,-154 # 80000fe6 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7119                	addi	sp,sp,-128
    800000d2:	fc86                	sd	ra,120(sp)
    800000d4:	f8a2                	sd	s0,112(sp)
    800000d6:	f4a6                	sd	s1,104(sp)
    800000d8:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while(i < n){
    800000da:	06c05a63          	blez	a2,8000014e <consolewrite+0x7e>
    800000de:	f0ca                	sd	s2,96(sp)
    800000e0:	ecce                	sd	s3,88(sp)
    800000e2:	e8d2                	sd	s4,80(sp)
    800000e4:	e4d6                	sd	s5,72(sp)
    800000e6:	e0da                	sd	s6,64(sp)
    800000e8:	fc5e                	sd	s7,56(sp)
    800000ea:	f862                	sd	s8,48(sp)
    800000ec:	f466                	sd	s9,40(sp)
    800000ee:	8aaa                	mv	s5,a0
    800000f0:	8b2e                	mv	s6,a1
    800000f2:	8a32                	mv	s4,a2
  int i = 0;
    800000f4:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    800000f6:	02000c13          	li	s8,32
    800000fa:	02000c93          	li	s9,32
      nn = n - i;
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    800000fe:	5bfd                	li	s7,-1
    80000100:	a035                	j	8000012c <consolewrite+0x5c>
    if(nn > n - i)
    80000102:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src+i, nn) == -1)
    80000106:	86ce                	mv	a3,s3
    80000108:	01648633          	add	a2,s1,s6
    8000010c:	85d6                	mv	a1,s5
    8000010e:	f8040513          	addi	a0,s0,-128
    80000112:	5a6020ef          	jal	800026b8 <either_copyin>
    80000116:	03750e63          	beq	a0,s7,80000152 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011a:	85ce                	mv	a1,s3
    8000011c:	f8040513          	addi	a0,s0,-128
    80000120:	778000ef          	jal	80000898 <uartwrite>
    i += nn;
    80000124:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000128:	0144da63          	bge	s1,s4,8000013c <consolewrite+0x6c>
    if(nn > n - i)
    8000012c:	409a093b          	subw	s2,s4,s1
    80000130:	0009079b          	sext.w	a5,s2
    80000134:	fcfc57e3          	bge	s8,a5,80000102 <consolewrite+0x32>
    80000138:	8966                	mv	s2,s9
    8000013a:	b7e1                	j	80000102 <consolewrite+0x32>
    8000013c:	7906                	ld	s2,96(sp)
    8000013e:	69e6                	ld	s3,88(sp)
    80000140:	6a46                	ld	s4,80(sp)
    80000142:	6aa6                	ld	s5,72(sp)
    80000144:	6b06                	ld	s6,64(sp)
    80000146:	7be2                	ld	s7,56(sp)
    80000148:	7c42                	ld	s8,48(sp)
    8000014a:	7ca2                	ld	s9,40(sp)
    8000014c:	a819                	j	80000162 <consolewrite+0x92>
  int i = 0;
    8000014e:	4481                	li	s1,0
    80000150:	a809                	j	80000162 <consolewrite+0x92>
    80000152:	7906                	ld	s2,96(sp)
    80000154:	69e6                	ld	s3,88(sp)
    80000156:	6a46                	ld	s4,80(sp)
    80000158:	6aa6                	ld	s5,72(sp)
    8000015a:	6b06                	ld	s6,64(sp)
    8000015c:	7be2                	ld	s7,56(sp)
    8000015e:	7c42                	ld	s8,48(sp)
    80000160:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000162:	8526                	mv	a0,s1
    80000164:	70e6                	ld	ra,120(sp)
    80000166:	7446                	ld	s0,112(sp)
    80000168:	74a6                	ld	s1,104(sp)
    8000016a:	6109                	addi	sp,sp,128
    8000016c:	8082                	ret

000000008000016e <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    8000016e:	711d                	addi	sp,sp,-96
    80000170:	ec86                	sd	ra,88(sp)
    80000172:	e8a2                	sd	s0,80(sp)
    80000174:	e4a6                	sd	s1,72(sp)
    80000176:	e0ca                	sd	s2,64(sp)
    80000178:	fc4e                	sd	s3,56(sp)
    8000017a:	f852                	sd	s4,48(sp)
    8000017c:	f456                	sd	s5,40(sp)
    8000017e:	f05a                	sd	s6,32(sp)
    80000180:	1080                	addi	s0,sp,96
    80000182:	8aaa                	mv	s5,a0
    80000184:	8a2e                	mv	s4,a1
    80000186:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000188:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018c:	00011517          	auipc	a0,0x11
    80000190:	b8450513          	addi	a0,a0,-1148 # 80010d10 <cons>
    80000194:	3e5000ef          	jal	80000d78 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000198:	00011497          	auipc	s1,0x11
    8000019c:	b7848493          	addi	s1,s1,-1160 # 80010d10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a0:	00011917          	auipc	s2,0x11
    800001a4:	c0890913          	addi	s2,s2,-1016 # 80010da8 <cons+0x98>
  while(n > 0){
    800001a8:	0b305d63          	blez	s3,80000262 <consoleread+0xf4>
    while(cons.r == cons.w){
    800001ac:	0984a783          	lw	a5,152(s1)
    800001b0:	09c4a703          	lw	a4,156(s1)
    800001b4:	0af71263          	bne	a4,a5,80000258 <consoleread+0xea>
      if(killed(myproc())){
    800001b8:	2a5010ef          	jal	80001c5c <myproc>
    800001bc:	38e020ef          	jal	8000254a <killed>
    800001c0:	e12d                	bnez	a0,80000222 <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    800001c2:	85a6                	mv	a1,s1
    800001c4:	854a                	mv	a0,s2
    800001c6:	14c020ef          	jal	80002312 <sleep>
    while(cons.r == cons.w){
    800001ca:	0984a783          	lw	a5,152(s1)
    800001ce:	09c4a703          	lw	a4,156(s1)
    800001d2:	fef703e3          	beq	a4,a5,800001b8 <consoleread+0x4a>
    800001d6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001d8:	00011717          	auipc	a4,0x11
    800001dc:	b3870713          	addi	a4,a4,-1224 # 80010d10 <cons>
    800001e0:	0017869b          	addiw	a3,a5,1
    800001e4:	08d72c23          	sw	a3,152(a4)
    800001e8:	07f7f693          	andi	a3,a5,127
    800001ec:	9736                	add	a4,a4,a3
    800001ee:	01874703          	lbu	a4,24(a4)
    800001f2:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001f6:	4691                	li	a3,4
    800001f8:	04db8663          	beq	s7,a3,80000244 <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001fc:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000200:	4685                	li	a3,1
    80000202:	faf40613          	addi	a2,s0,-81
    80000206:	85d2                	mv	a1,s4
    80000208:	8556                	mv	a0,s5
    8000020a:	464020ef          	jal	8000266e <either_copyout>
    8000020e:	57fd                	li	a5,-1
    80000210:	04f50863          	beq	a0,a5,80000260 <consoleread+0xf2>
      break;

    dst++;
    80000214:	0a05                	addi	s4,s4,1
    --n;
    80000216:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000218:	47a9                	li	a5,10
    8000021a:	04fb8d63          	beq	s7,a5,80000274 <consoleread+0x106>
    8000021e:	6be2                	ld	s7,24(sp)
    80000220:	b761                	j	800001a8 <consoleread+0x3a>
        release(&cons.lock);
    80000222:	00011517          	auipc	a0,0x11
    80000226:	aee50513          	addi	a0,a0,-1298 # 80010d10 <cons>
    8000022a:	3e7000ef          	jal	80000e10 <release>
        return -1;
    8000022e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000230:	60e6                	ld	ra,88(sp)
    80000232:	6446                	ld	s0,80(sp)
    80000234:	64a6                	ld	s1,72(sp)
    80000236:	6906                	ld	s2,64(sp)
    80000238:	79e2                	ld	s3,56(sp)
    8000023a:	7a42                	ld	s4,48(sp)
    8000023c:	7aa2                	ld	s5,40(sp)
    8000023e:	7b02                	ld	s6,32(sp)
    80000240:	6125                	addi	sp,sp,96
    80000242:	8082                	ret
      if(n < target){
    80000244:	0009871b          	sext.w	a4,s3
    80000248:	01677a63          	bgeu	a4,s6,8000025c <consoleread+0xee>
        cons.r--;
    8000024c:	00011717          	auipc	a4,0x11
    80000250:	b4f72e23          	sw	a5,-1188(a4) # 80010da8 <cons+0x98>
    80000254:	6be2                	ld	s7,24(sp)
    80000256:	a031                	j	80000262 <consoleread+0xf4>
    80000258:	ec5e                	sd	s7,24(sp)
    8000025a:	bfbd                	j	800001d8 <consoleread+0x6a>
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	a011                	j	80000262 <consoleread+0xf4>
    80000260:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000262:	00011517          	auipc	a0,0x11
    80000266:	aae50513          	addi	a0,a0,-1362 # 80010d10 <cons>
    8000026a:	3a7000ef          	jal	80000e10 <release>
  return target - n;
    8000026e:	413b053b          	subw	a0,s6,s3
    80000272:	bf7d                	j	80000230 <consoleread+0xc2>
    80000274:	6be2                	ld	s7,24(sp)
    80000276:	b7f5                	j	80000262 <consoleread+0xf4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50863          	beq	a0,a5,80000294 <consputc+0x1c>
    uartputc_sync(c);
    80000288:	6a4000ef          	jal	8000092c <uartputc_sync>
}
    8000028c:	60a2                	ld	ra,8(sp)
    8000028e:	6402                	ld	s0,0(sp)
    80000290:	0141                	addi	sp,sp,16
    80000292:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000294:	4521                	li	a0,8
    80000296:	696000ef          	jal	8000092c <uartputc_sync>
    8000029a:	02000513          	li	a0,32
    8000029e:	68e000ef          	jal	8000092c <uartputc_sync>
    800002a2:	4521                	li	a0,8
    800002a4:	688000ef          	jal	8000092c <uartputc_sync>
    800002a8:	b7d5                	j	8000028c <consputc+0x14>

00000000800002aa <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002aa:	1101                	addi	sp,sp,-32
    800002ac:	ec06                	sd	ra,24(sp)
    800002ae:	e822                	sd	s0,16(sp)
    800002b0:	e426                	sd	s1,8(sp)
    800002b2:	1000                	addi	s0,sp,32
    800002b4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002b6:	00011517          	auipc	a0,0x11
    800002ba:	a5a50513          	addi	a0,a0,-1446 # 80010d10 <cons>
    800002be:	2bb000ef          	jal	80000d78 <acquire>

  switch(c){
    800002c2:	47d5                	li	a5,21
    800002c4:	08f48f63          	beq	s1,a5,80000362 <consoleintr+0xb8>
    800002c8:	0297c563          	blt	a5,s1,800002f2 <consoleintr+0x48>
    800002cc:	47a1                	li	a5,8
    800002ce:	0ef48463          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    800002d2:	47c1                	li	a5,16
    800002d4:	10f49563          	bne	s1,a5,800003de <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002d8:	42a020ef          	jal	80002702 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002dc:	00011517          	auipc	a0,0x11
    800002e0:	a3450513          	addi	a0,a0,-1484 # 80010d10 <cons>
    800002e4:	32d000ef          	jal	80000e10 <release>
}
    800002e8:	60e2                	ld	ra,24(sp)
    800002ea:	6442                	ld	s0,16(sp)
    800002ec:	64a2                	ld	s1,8(sp)
    800002ee:	6105                	addi	sp,sp,32
    800002f0:	8082                	ret
  switch(c){
    800002f2:	07f00793          	li	a5,127
    800002f6:	0cf48063          	beq	s1,a5,800003b6 <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002fa:	00011717          	auipc	a4,0x11
    800002fe:	a1670713          	addi	a4,a4,-1514 # 80010d10 <cons>
    80000302:	0a072783          	lw	a5,160(a4)
    80000306:	09872703          	lw	a4,152(a4)
    8000030a:	9f99                	subw	a5,a5,a4
    8000030c:	07f00713          	li	a4,127
    80000310:	fcf766e3          	bltu	a4,a5,800002dc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000314:	47b5                	li	a5,13
    80000316:	0cf48763          	beq	s1,a5,800003e4 <consoleintr+0x13a>
      consputc(c);
    8000031a:	8526                	mv	a0,s1
    8000031c:	f5dff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000320:	00011797          	auipc	a5,0x11
    80000324:	9f078793          	addi	a5,a5,-1552 # 80010d10 <cons>
    80000328:	0a07a683          	lw	a3,160(a5)
    8000032c:	0016871b          	addiw	a4,a3,1
    80000330:	0007061b          	sext.w	a2,a4
    80000334:	0ae7a023          	sw	a4,160(a5)
    80000338:	07f6f693          	andi	a3,a3,127
    8000033c:	97b6                	add	a5,a5,a3
    8000033e:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000342:	47a9                	li	a5,10
    80000344:	0cf48563          	beq	s1,a5,8000040e <consoleintr+0x164>
    80000348:	4791                	li	a5,4
    8000034a:	0cf48263          	beq	s1,a5,8000040e <consoleintr+0x164>
    8000034e:	00011797          	auipc	a5,0x11
    80000352:	a5a7a783          	lw	a5,-1446(a5) # 80010da8 <cons+0x98>
    80000356:	9f1d                	subw	a4,a4,a5
    80000358:	08000793          	li	a5,128
    8000035c:	f8f710e3          	bne	a4,a5,800002dc <consoleintr+0x32>
    80000360:	a07d                	j	8000040e <consoleintr+0x164>
    80000362:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000364:	00011717          	auipc	a4,0x11
    80000368:	9ac70713          	addi	a4,a4,-1620 # 80010d10 <cons>
    8000036c:	0a072783          	lw	a5,160(a4)
    80000370:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000374:	00011497          	auipc	s1,0x11
    80000378:	99c48493          	addi	s1,s1,-1636 # 80010d10 <cons>
    while(cons.e != cons.w &&
    8000037c:	4929                	li	s2,10
    8000037e:	02f70863          	beq	a4,a5,800003ae <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000382:	37fd                	addiw	a5,a5,-1
    80000384:	07f7f713          	andi	a4,a5,127
    80000388:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    8000038a:	01874703          	lbu	a4,24(a4)
    8000038e:	03270263          	beq	a4,s2,800003b2 <consoleintr+0x108>
      cons.e--;
    80000392:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80000396:	10000513          	li	a0,256
    8000039a:	edfff0ef          	jal	80000278 <consputc>
    while(cons.e != cons.w &&
    8000039e:	0a04a783          	lw	a5,160(s1)
    800003a2:	09c4a703          	lw	a4,156(s1)
    800003a6:	fcf71ee3          	bne	a4,a5,80000382 <consoleintr+0xd8>
    800003aa:	6902                	ld	s2,0(sp)
    800003ac:	bf05                	j	800002dc <consoleintr+0x32>
    800003ae:	6902                	ld	s2,0(sp)
    800003b0:	b735                	j	800002dc <consoleintr+0x32>
    800003b2:	6902                	ld	s2,0(sp)
    800003b4:	b725                	j	800002dc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003b6:	00011717          	auipc	a4,0x11
    800003ba:	95a70713          	addi	a4,a4,-1702 # 80010d10 <cons>
    800003be:	0a072783          	lw	a5,160(a4)
    800003c2:	09c72703          	lw	a4,156(a4)
    800003c6:	f0f70be3          	beq	a4,a5,800002dc <consoleintr+0x32>
      cons.e--;
    800003ca:	37fd                	addiw	a5,a5,-1
    800003cc:	00011717          	auipc	a4,0x11
    800003d0:	9ef72223          	sw	a5,-1564(a4) # 80010db0 <cons+0xa0>
      consputc(BACKSPACE);
    800003d4:	10000513          	li	a0,256
    800003d8:	ea1ff0ef          	jal	80000278 <consputc>
    800003dc:	b701                	j	800002dc <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003de:	ee048fe3          	beqz	s1,800002dc <consoleintr+0x32>
    800003e2:	bf21                	j	800002fa <consoleintr+0x50>
      consputc(c);
    800003e4:	4529                	li	a0,10
    800003e6:	e93ff0ef          	jal	80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003ea:	00011797          	auipc	a5,0x11
    800003ee:	92678793          	addi	a5,a5,-1754 # 80010d10 <cons>
    800003f2:	0a07a703          	lw	a4,160(a5)
    800003f6:	0017069b          	addiw	a3,a4,1
    800003fa:	0006861b          	sext.w	a2,a3
    800003fe:	0ad7a023          	sw	a3,160(a5)
    80000402:	07f77713          	andi	a4,a4,127
    80000406:	97ba                	add	a5,a5,a4
    80000408:	4729                	li	a4,10
    8000040a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000040e:	00011797          	auipc	a5,0x11
    80000412:	98c7af23          	sw	a2,-1634(a5) # 80010dac <cons+0x9c>
        wakeup(&cons.r);
    80000416:	00011517          	auipc	a0,0x11
    8000041a:	99250513          	addi	a0,a0,-1646 # 80010da8 <cons+0x98>
    8000041e:	741010ef          	jal	8000235e <wakeup>
    80000422:	bd6d                	j	800002dc <consoleintr+0x32>

0000000080000424 <consoleinit>:

void
consoleinit(void)
{
    80000424:	1141                	addi	sp,sp,-16
    80000426:	e406                	sd	ra,8(sp)
    80000428:	e022                	sd	s0,0(sp)
    8000042a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000042c:	00008597          	auipc	a1,0x8
    80000430:	bd458593          	addi	a1,a1,-1068 # 80008000 <etext>
    80000434:	00011517          	auipc	a0,0x11
    80000438:	8dc50513          	addi	a0,a0,-1828 # 80010d10 <cons>
    8000043c:	0bd000ef          	jal	80000cf8 <initlock>

  uartinit();
    80000440:	400000ef          	jal	80000840 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000444:	00241797          	auipc	a5,0x241
    80000448:	26c78793          	addi	a5,a5,620 # 802416b0 <devsw>
    8000044c:	00000717          	auipc	a4,0x0
    80000450:	d2270713          	addi	a4,a4,-734 # 8000016e <consoleread>
    80000454:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000456:	00000717          	auipc	a4,0x0
    8000045a:	c7a70713          	addi	a4,a4,-902 # 800000d0 <consolewrite>
    8000045e:	ef98                	sd	a4,24(a5)
}
    80000460:	60a2                	ld	ra,8(sp)
    80000462:	6402                	ld	s0,0(sp)
    80000464:	0141                	addi	sp,sp,16
    80000466:	8082                	ret

0000000080000468 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000468:	7139                	addi	sp,sp,-64
    8000046a:	fc06                	sd	ra,56(sp)
    8000046c:	f822                	sd	s0,48(sp)
    8000046e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000470:	c219                	beqz	a2,80000476 <printint+0xe>
    80000472:	08054063          	bltz	a0,800004f2 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000476:	4881                	li	a7,0
    80000478:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000047c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000047e:	00008617          	auipc	a2,0x8
    80000482:	6da60613          	addi	a2,a2,1754 # 80008b58 <digits>
    80000486:	883e                	mv	a6,a5
    80000488:	2785                	addiw	a5,a5,1
    8000048a:	02b57733          	remu	a4,a0,a1
    8000048e:	9732                	add	a4,a4,a2
    80000490:	00074703          	lbu	a4,0(a4)
    80000494:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000498:	872a                	mv	a4,a0
    8000049a:	02b55533          	divu	a0,a0,a1
    8000049e:	0685                	addi	a3,a3,1
    800004a0:	feb773e3          	bgeu	a4,a1,80000486 <printint+0x1e>

  if(sign)
    800004a4:	00088a63          	beqz	a7,800004b8 <printint+0x50>
    buf[i++] = '-';
    800004a8:	1781                	addi	a5,a5,-32
    800004aa:	97a2                	add	a5,a5,s0
    800004ac:	02d00713          	li	a4,45
    800004b0:	fee78423          	sb	a4,-24(a5)
    800004b4:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004b8:	02f05963          	blez	a5,800004ea <printint+0x82>
    800004bc:	f426                	sd	s1,40(sp)
    800004be:	f04a                	sd	s2,32(sp)
    800004c0:	fc840713          	addi	a4,s0,-56
    800004c4:	00f704b3          	add	s1,a4,a5
    800004c8:	fff70913          	addi	s2,a4,-1
    800004cc:	993e                	add	s2,s2,a5
    800004ce:	37fd                	addiw	a5,a5,-1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004d8:	fff4c503          	lbu	a0,-1(s1)
    800004dc:	d9dff0ef          	jal	80000278 <consputc>
  while(--i >= 0)
    800004e0:	14fd                	addi	s1,s1,-1
    800004e2:	ff249be3          	bne	s1,s2,800004d8 <printint+0x70>
    800004e6:	74a2                	ld	s1,40(sp)
    800004e8:	7902                	ld	s2,32(sp)
}
    800004ea:	70e2                	ld	ra,56(sp)
    800004ec:	7442                	ld	s0,48(sp)
    800004ee:	6121                	addi	sp,sp,64
    800004f0:	8082                	ret
    x = -xx;
    800004f2:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004f6:	4885                	li	a7,1
    x = -xx;
    800004f8:	b741                	j	80000478 <printint+0x10>

00000000800004fa <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004fa:	7131                	addi	sp,sp,-192
    800004fc:	fc86                	sd	ra,120(sp)
    800004fe:	f8a2                	sd	s0,112(sp)
    80000500:	e8d2                	sd	s4,80(sp)
    80000502:	0100                	addi	s0,sp,128
    80000504:	8a2a                	mv	s4,a0
    80000506:	e40c                	sd	a1,8(s0)
    80000508:	e810                	sd	a2,16(s0)
    8000050a:	ec14                	sd	a3,24(s0)
    8000050c:	f018                	sd	a4,32(s0)
    8000050e:	f41c                	sd	a5,40(s0)
    80000510:	03043823          	sd	a6,48(s0)
    80000514:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    80000518:	00008797          	auipc	a5,0x8
    8000051c:	7bc7a783          	lw	a5,1980(a5) # 80008cd4 <panicking>
    80000520:	c3a1                	beqz	a5,80000560 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000522:	00840793          	addi	a5,s0,8
    80000526:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000052a:	000a4503          	lbu	a0,0(s4)
    8000052e:	28050763          	beqz	a0,800007bc <printf+0x2c2>
    80000532:	f4a6                	sd	s1,104(sp)
    80000534:	f0ca                	sd	s2,96(sp)
    80000536:	ecce                	sd	s3,88(sp)
    80000538:	e4d6                	sd	s5,72(sp)
    8000053a:	e0da                	sd	s6,64(sp)
    8000053c:	f862                	sd	s8,48(sp)
    8000053e:	f466                	sd	s9,40(sp)
    80000540:	f06a                	sd	s10,32(sp)
    80000542:	ec6e                	sd	s11,24(sp)
    80000544:	4981                	li	s3,0
    if(cx != '%'){
    80000546:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000054a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000054e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000552:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000556:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000055a:	07000d93          	li	s11,112
    8000055e:	a01d                	j	80000584 <printf+0x8a>
    acquire(&pr.lock);
    80000560:	00011517          	auipc	a0,0x11
    80000564:	85850513          	addi	a0,a0,-1960 # 80010db8 <pr>
    80000568:	011000ef          	jal	80000d78 <acquire>
    8000056c:	bf5d                	j	80000522 <printf+0x28>
      consputc(cx);
    8000056e:	d0bff0ef          	jal	80000278 <consputc>
      continue;
    80000572:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000574:	0014899b          	addiw	s3,s1,1
    80000578:	013a07b3          	add	a5,s4,s3
    8000057c:	0007c503          	lbu	a0,0(a5)
    80000580:	20050b63          	beqz	a0,80000796 <printf+0x29c>
    if(cx != '%'){
    80000584:	ff5515e3          	bne	a0,s5,8000056e <printf+0x74>
    i++;
    80000588:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    8000058c:	009a07b3          	add	a5,s4,s1
    80000590:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    80000594:	20090b63          	beqz	s2,800007aa <printf+0x2b0>
    80000598:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    8000059c:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    8000059e:	c789                	beqz	a5,800005a8 <printf+0xae>
    800005a0:	009a0733          	add	a4,s4,s1
    800005a4:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005a8:	03690963          	beq	s2,s6,800005da <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005ac:	05890363          	beq	s2,s8,800005f2 <printf+0xf8>
    } else if(c0 == 'u'){
    800005b0:	0d990663          	beq	s2,s9,8000067c <printf+0x182>
    } else if(c0 == 'x'){
    800005b4:	11a90d63          	beq	s2,s10,800006ce <printf+0x1d4>
    } else if(c0 == 'p'){
    800005b8:	15b90663          	beq	s2,s11,80000704 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005bc:	06300793          	li	a5,99
    800005c0:	18f90563          	beq	s2,a5,8000074a <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005c4:	07300793          	li	a5,115
    800005c8:	18f90b63          	beq	s2,a5,8000075e <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005cc:	03591b63          	bne	s2,s5,80000602 <printf+0x108>
      consputc('%');
    800005d0:	02500513          	li	a0,37
    800005d4:	ca5ff0ef          	jal	80000278 <consputc>
    800005d8:	bf71                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005da:	f8843783          	ld	a5,-120(s0)
    800005de:	00878713          	addi	a4,a5,8
    800005e2:	f8e43423          	sd	a4,-120(s0)
    800005e6:	4605                	li	a2,1
    800005e8:	45a9                	li	a1,10
    800005ea:	4388                	lw	a0,0(a5)
    800005ec:	e7dff0ef          	jal	80000468 <printint>
    800005f0:	b751                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    800005f2:	01678f63          	beq	a5,s6,80000610 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005f6:	03878b63          	beq	a5,s8,8000062c <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    800005fa:	09978e63          	beq	a5,s9,80000696 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    800005fe:	0fa78563          	beq	a5,s10,800006e8 <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000602:	8556                	mv	a0,s5
    80000604:	c75ff0ef          	jal	80000278 <consputc>
      consputc(c0);
    80000608:	854a                	mv	a0,s2
    8000060a:	c6fff0ef          	jal	80000278 <consputc>
    8000060e:	b79d                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000610:	f8843783          	ld	a5,-120(s0)
    80000614:	00878713          	addi	a4,a5,8
    80000618:	f8e43423          	sd	a4,-120(s0)
    8000061c:	4605                	li	a2,1
    8000061e:	45a9                	li	a1,10
    80000620:	6388                	ld	a0,0(a5)
    80000622:	e47ff0ef          	jal	80000468 <printint>
      i += 1;
    80000626:	0029849b          	addiw	s1,s3,2
    8000062a:	b7a9                	j	80000574 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000062c:	06400793          	li	a5,100
    80000630:	02f68863          	beq	a3,a5,80000660 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000634:	07500793          	li	a5,117
    80000638:	06f68d63          	beq	a3,a5,800006b2 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000063c:	07800793          	li	a5,120
    80000640:	fcf691e3          	bne	a3,a5,80000602 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4601                	li	a2,0
    80000652:	45c1                	li	a1,16
    80000654:	6388                	ld	a0,0(a5)
    80000656:	e13ff0ef          	jal	80000468 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bf19                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	45a9                	li	a1,10
    80000670:	6388                	ld	a0,0(a5)
    80000672:	df7ff0ef          	jal	80000468 <printint>
      i += 2;
    80000676:	0039849b          	addiw	s1,s3,3
    8000067a:	bded                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000067c:	f8843783          	ld	a5,-120(s0)
    80000680:	00878713          	addi	a4,a5,8
    80000684:	f8e43423          	sd	a4,-120(s0)
    80000688:	4601                	li	a2,0
    8000068a:	45a9                	li	a1,10
    8000068c:	0007e503          	lwu	a0,0(a5)
    80000690:	dd9ff0ef          	jal	80000468 <printint>
    80000694:	b5c5                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	4601                	li	a2,0
    800006a4:	45a9                	li	a1,10
    800006a6:	6388                	ld	a0,0(a5)
    800006a8:	dc1ff0ef          	jal	80000468 <printint>
      i += 1;
    800006ac:	0029849b          	addiw	s1,s3,2
    800006b0:	b5d1                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006b2:	f8843783          	ld	a5,-120(s0)
    800006b6:	00878713          	addi	a4,a5,8
    800006ba:	f8e43423          	sd	a4,-120(s0)
    800006be:	4601                	li	a2,0
    800006c0:	45a9                	li	a1,10
    800006c2:	6388                	ld	a0,0(a5)
    800006c4:	da5ff0ef          	jal	80000468 <printint>
      i += 2;
    800006c8:	0039849b          	addiw	s1,s3,3
    800006cc:	b565                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006ce:	f8843783          	ld	a5,-120(s0)
    800006d2:	00878713          	addi	a4,a5,8
    800006d6:	f8e43423          	sd	a4,-120(s0)
    800006da:	4601                	li	a2,0
    800006dc:	45c1                	li	a1,16
    800006de:	0007e503          	lwu	a0,0(a5)
    800006e2:	d87ff0ef          	jal	80000468 <printint>
    800006e6:	b579                	j	80000574 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006e8:	f8843783          	ld	a5,-120(s0)
    800006ec:	00878713          	addi	a4,a5,8
    800006f0:	f8e43423          	sd	a4,-120(s0)
    800006f4:	4601                	li	a2,0
    800006f6:	45c1                	li	a1,16
    800006f8:	6388                	ld	a0,0(a5)
    800006fa:	d6fff0ef          	jal	80000468 <printint>
      i += 1;
    800006fe:	0029849b          	addiw	s1,s3,2
    80000702:	bd8d                	j	80000574 <printf+0x7a>
    80000704:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000706:	f8843783          	ld	a5,-120(s0)
    8000070a:	00878713          	addi	a4,a5,8
    8000070e:	f8e43423          	sd	a4,-120(s0)
    80000712:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000716:	03000513          	li	a0,48
    8000071a:	b5fff0ef          	jal	80000278 <consputc>
  consputc('x');
    8000071e:	07800513          	li	a0,120
    80000722:	b57ff0ef          	jal	80000278 <consputc>
    80000726:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000728:	00008b97          	auipc	s7,0x8
    8000072c:	430b8b93          	addi	s7,s7,1072 # 80008b58 <digits>
    80000730:	03c9d793          	srli	a5,s3,0x3c
    80000734:	97de                	add	a5,a5,s7
    80000736:	0007c503          	lbu	a0,0(a5)
    8000073a:	b3fff0ef          	jal	80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000073e:	0992                	slli	s3,s3,0x4
    80000740:	397d                	addiw	s2,s2,-1
    80000742:	fe0917e3          	bnez	s2,80000730 <printf+0x236>
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	b535                	j	80000574 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000074a:	f8843783          	ld	a5,-120(s0)
    8000074e:	00878713          	addi	a4,a5,8
    80000752:	f8e43423          	sd	a4,-120(s0)
    80000756:	4388                	lw	a0,0(a5)
    80000758:	b21ff0ef          	jal	80000278 <consputc>
    8000075c:	bd21                	j	80000574 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    8000075e:	f8843783          	ld	a5,-120(s0)
    80000762:	00878713          	addi	a4,a5,8
    80000766:	f8e43423          	sd	a4,-120(s0)
    8000076a:	0007b903          	ld	s2,0(a5)
    8000076e:	00090d63          	beqz	s2,80000788 <printf+0x28e>
      for(; *s; s++)
    80000772:	00094503          	lbu	a0,0(s2)
    80000776:	de050fe3          	beqz	a0,80000574 <printf+0x7a>
        consputc(*s);
    8000077a:	affff0ef          	jal	80000278 <consputc>
      for(; *s; s++)
    8000077e:	0905                	addi	s2,s2,1
    80000780:	00094503          	lbu	a0,0(s2)
    80000784:	f97d                	bnez	a0,8000077a <printf+0x280>
    80000786:	b3fd                	j	80000574 <printf+0x7a>
        s = "(null)";
    80000788:	00008917          	auipc	s2,0x8
    8000078c:	88090913          	addi	s2,s2,-1920 # 80008008 <etext+0x8>
      for(; *s; s++)
    80000790:	02800513          	li	a0,40
    80000794:	b7dd                	j	8000077a <printf+0x280>
    80000796:	74a6                	ld	s1,104(sp)
    80000798:	7906                	ld	s2,96(sp)
    8000079a:	69e6                	ld	s3,88(sp)
    8000079c:	6aa6                	ld	s5,72(sp)
    8000079e:	6b06                	ld	s6,64(sp)
    800007a0:	7c42                	ld	s8,48(sp)
    800007a2:	7ca2                	ld	s9,40(sp)
    800007a4:	7d02                	ld	s10,32(sp)
    800007a6:	6de2                	ld	s11,24(sp)
    800007a8:	a811                	j	800007bc <printf+0x2c2>
    800007aa:	74a6                	ld	s1,104(sp)
    800007ac:	7906                	ld	s2,96(sp)
    800007ae:	69e6                	ld	s3,88(sp)
    800007b0:	6aa6                	ld	s5,72(sp)
    800007b2:	6b06                	ld	s6,64(sp)
    800007b4:	7c42                	ld	s8,48(sp)
    800007b6:	7ca2                	ld	s9,40(sp)
    800007b8:	7d02                	ld	s10,32(sp)
    800007ba:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007bc:	00008797          	auipc	a5,0x8
    800007c0:	5187a783          	lw	a5,1304(a5) # 80008cd4 <panicking>
    800007c4:	c799                	beqz	a5,800007d2 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007c6:	4501                	li	a0,0
    800007c8:	70e6                	ld	ra,120(sp)
    800007ca:	7446                	ld	s0,112(sp)
    800007cc:	6a46                	ld	s4,80(sp)
    800007ce:	6129                	addi	sp,sp,192
    800007d0:	8082                	ret
    release(&pr.lock);
    800007d2:	00010517          	auipc	a0,0x10
    800007d6:	5e650513          	addi	a0,a0,1510 # 80010db8 <pr>
    800007da:	636000ef          	jal	80000e10 <release>
  return 0;
    800007de:	b7e5                	j	800007c6 <printf+0x2cc>

00000000800007e0 <panic>:

void
panic(char *s)
{
    800007e0:	1101                	addi	sp,sp,-32
    800007e2:	ec06                	sd	ra,24(sp)
    800007e4:	e822                	sd	s0,16(sp)
    800007e6:	e426                	sd	s1,8(sp)
    800007e8:	e04a                	sd	s2,0(sp)
    800007ea:	1000                	addi	s0,sp,32
    800007ec:	84aa                	mv	s1,a0
  panicking = 1;
    800007ee:	4905                	li	s2,1
    800007f0:	00008797          	auipc	a5,0x8
    800007f4:	4f27a223          	sw	s2,1252(a5) # 80008cd4 <panicking>
  printf("panic: ");
    800007f8:	00008517          	auipc	a0,0x8
    800007fc:	82050513          	addi	a0,a0,-2016 # 80008018 <etext+0x18>
    80000800:	cfbff0ef          	jal	800004fa <printf>
  printf("%s\n", s);
    80000804:	85a6                	mv	a1,s1
    80000806:	00008517          	auipc	a0,0x8
    8000080a:	81a50513          	addi	a0,a0,-2022 # 80008020 <etext+0x20>
    8000080e:	cedff0ef          	jal	800004fa <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000812:	00008797          	auipc	a5,0x8
    80000816:	4b27af23          	sw	s2,1214(a5) # 80008cd0 <panicked>
  for(;;)
    8000081a:	a001                	j	8000081a <panic+0x3a>

000000008000081c <printfinit>:
    ;
}

void
printfinit(void)
{
    8000081c:	1141                	addi	sp,sp,-16
    8000081e:	e406                	sd	ra,8(sp)
    80000820:	e022                	sd	s0,0(sp)
    80000822:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000824:	00008597          	auipc	a1,0x8
    80000828:	80458593          	addi	a1,a1,-2044 # 80008028 <etext+0x28>
    8000082c:	00010517          	auipc	a0,0x10
    80000830:	58c50513          	addi	a0,a0,1420 # 80010db8 <pr>
    80000834:	4c4000ef          	jal	80000cf8 <initlock>
}
    80000838:	60a2                	ld	ra,8(sp)
    8000083a:	6402                	ld	s0,0(sp)
    8000083c:	0141                	addi	sp,sp,16
    8000083e:	8082                	ret

0000000080000840 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000840:	1141                	addi	sp,sp,-16
    80000842:	e406                	sd	ra,8(sp)
    80000844:	e022                	sd	s0,0(sp)
    80000846:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000848:	100007b7          	lui	a5,0x10000
    8000084c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000850:	10000737          	lui	a4,0x10000
    80000854:	f8000693          	li	a3,-128
    80000858:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000085c:	468d                	li	a3,3
    8000085e:	10000637          	lui	a2,0x10000
    80000862:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000866:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000086a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	461d                	li	a2,7
    80000874:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000878:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    8000087c:	00007597          	auipc	a1,0x7
    80000880:	7b458593          	addi	a1,a1,1972 # 80008030 <etext+0x30>
    80000884:	00010517          	auipc	a0,0x10
    80000888:	54c50513          	addi	a0,a0,1356 # 80010dd0 <tx_lock>
    8000088c:	46c000ef          	jal	80000cf8 <initlock>
}
    80000890:	60a2                	ld	ra,8(sp)
    80000892:	6402                	ld	s0,0(sp)
    80000894:	0141                	addi	sp,sp,16
    80000896:	8082                	ret

0000000080000898 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    80000898:	715d                	addi	sp,sp,-80
    8000089a:	e486                	sd	ra,72(sp)
    8000089c:	e0a2                	sd	s0,64(sp)
    8000089e:	fc26                	sd	s1,56(sp)
    800008a0:	ec56                	sd	s5,24(sp)
    800008a2:	0880                	addi	s0,sp,80
    800008a4:	8aaa                	mv	s5,a0
    800008a6:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008a8:	00010517          	auipc	a0,0x10
    800008ac:	52850513          	addi	a0,a0,1320 # 80010dd0 <tx_lock>
    800008b0:	4c8000ef          	jal	80000d78 <acquire>

  int i = 0;
  while(i < n){ 
    800008b4:	06905063          	blez	s1,80000914 <uartwrite+0x7c>
    800008b8:	f84a                	sd	s2,48(sp)
    800008ba:	f44e                	sd	s3,40(sp)
    800008bc:	f052                	sd	s4,32(sp)
    800008be:	e85a                	sd	s6,16(sp)
    800008c0:	e45e                	sd	s7,8(sp)
    800008c2:	8a56                	mv	s4,s5
    800008c4:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008c6:	00008497          	auipc	s1,0x8
    800008ca:	41648493          	addi	s1,s1,1046 # 80008cdc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    800008ce:	00010997          	auipc	s3,0x10
    800008d2:	50298993          	addi	s3,s3,1282 # 80010dd0 <tx_lock>
    800008d6:	00008917          	auipc	s2,0x8
    800008da:	40290913          	addi	s2,s2,1026 # 80008cd8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    800008de:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    800008e2:	4b05                	li	s6,1
    800008e4:	a005                	j	80000904 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    800008e6:	85ce                	mv	a1,s3
    800008e8:	854a                	mv	a0,s2
    800008ea:	229010ef          	jal	80002312 <sleep>
    while(tx_busy != 0){
    800008ee:	409c                	lw	a5,0(s1)
    800008f0:	fbfd                	bnez	a5,800008e6 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    800008f2:	000a4783          	lbu	a5,0(s4)
    800008f6:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    800008fa:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    800008fe:	0a05                	addi	s4,s4,1
    80000900:	015a0563          	beq	s4,s5,8000090a <uartwrite+0x72>
    while(tx_busy != 0){
    80000904:	409c                	lw	a5,0(s1)
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x4e>
    80000908:	b7ed                	j	800008f2 <uartwrite+0x5a>
    8000090a:	7942                	ld	s2,48(sp)
    8000090c:	79a2                	ld	s3,40(sp)
    8000090e:	7a02                	ld	s4,32(sp)
    80000910:	6b42                	ld	s6,16(sp)
    80000912:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000914:	00010517          	auipc	a0,0x10
    80000918:	4bc50513          	addi	a0,a0,1212 # 80010dd0 <tx_lock>
    8000091c:	4f4000ef          	jal	80000e10 <release>
}
    80000920:	60a6                	ld	ra,72(sp)
    80000922:	6406                	ld	s0,64(sp)
    80000924:	74e2                	ld	s1,56(sp)
    80000926:	6ae2                	ld	s5,24(sp)
    80000928:	6161                	addi	sp,sp,80
    8000092a:	8082                	ret

000000008000092c <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092c:	1101                	addi	sp,sp,-32
    8000092e:	ec06                	sd	ra,24(sp)
    80000930:	e822                	sd	s0,16(sp)
    80000932:	e426                	sd	s1,8(sp)
    80000934:	1000                	addi	s0,sp,32
    80000936:	84aa                	mv	s1,a0
  if(panicking == 0)
    80000938:	00008797          	auipc	a5,0x8
    8000093c:	39c7a783          	lw	a5,924(a5) # 80008cd4 <panicking>
    80000940:	cf95                	beqz	a5,8000097c <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000942:	00008797          	auipc	a5,0x8
    80000946:	38e7a783          	lw	a5,910(a5) # 80008cd0 <panicked>
    8000094a:	ef85                	bnez	a5,80000982 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094c:	10000737          	lui	a4,0x10000
    80000950:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000952:	00074783          	lbu	a5,0(a4)
    80000956:	0207f793          	andi	a5,a5,32
    8000095a:	dfe5                	beqz	a5,80000952 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095c:	0ff4f513          	zext.b	a0,s1
    80000960:	100007b7          	lui	a5,0x10000
    80000964:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    80000968:	00008797          	auipc	a5,0x8
    8000096c:	36c7a783          	lw	a5,876(a5) # 80008cd4 <panicking>
    80000970:	cb91                	beqz	a5,80000984 <uartputc_sync+0x58>
    pop_off();
}
    80000972:	60e2                	ld	ra,24(sp)
    80000974:	6442                	ld	s0,16(sp)
    80000976:	64a2                	ld	s1,8(sp)
    80000978:	6105                	addi	sp,sp,32
    8000097a:	8082                	ret
    push_off();
    8000097c:	3bc000ef          	jal	80000d38 <push_off>
    80000980:	b7c9                	j	80000942 <uartputc_sync+0x16>
    for(;;)
    80000982:	a001                	j	80000982 <uartputc_sync+0x56>
    pop_off();
    80000984:	438000ef          	jal	80000dbc <pop_off>
}
    80000988:	b7ed                	j	80000972 <uartputc_sync+0x46>

000000008000098a <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    8000098a:	1141                	addi	sp,sp,-16
    8000098c:	e422                	sd	s0,8(sp)
    8000098e:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000990:	100007b7          	lui	a5,0x10000
    80000994:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000996:	0007c783          	lbu	a5,0(a5)
    8000099a:	8b85                	andi	a5,a5,1
    8000099c:	cb81                	beqz	a5,800009ac <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    8000099e:	100007b7          	lui	a5,0x10000
    800009a2:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a6:	6422                	ld	s0,8(sp)
    800009a8:	0141                	addi	sp,sp,16
    800009aa:	8082                	ret
    return -1;
    800009ac:	557d                	li	a0,-1
    800009ae:	bfe5                	j	800009a6 <uartgetc+0x1c>

00000000800009b0 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009b0:	1101                	addi	sp,sp,-32
    800009b2:	ec06                	sd	ra,24(sp)
    800009b4:	e822                	sd	s0,16(sp)
    800009b6:	e426                	sd	s1,8(sp)
    800009b8:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ba:	100007b7          	lui	a5,0x10000
    800009be:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009c0:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009c4:	00010517          	auipc	a0,0x10
    800009c8:	40c50513          	addi	a0,a0,1036 # 80010dd0 <tx_lock>
    800009cc:	3ac000ef          	jal	80000d78 <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009d6:	0007c783          	lbu	a5,0(a5)
    800009da:	0207f793          	andi	a5,a5,32
    800009de:	eb89                	bnez	a5,800009f0 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    800009e0:	00010517          	auipc	a0,0x10
    800009e4:	3f050513          	addi	a0,a0,1008 # 80010dd0 <tx_lock>
    800009e8:	428000ef          	jal	80000e10 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009ec:	54fd                	li	s1,-1
    800009ee:	a831                	j	80000a0a <uartintr+0x5a>
    tx_busy = 0;
    800009f0:	00008797          	auipc	a5,0x8
    800009f4:	2e07a623          	sw	zero,748(a5) # 80008cdc <tx_busy>
    wakeup(&tx_chan);
    800009f8:	00008517          	auipc	a0,0x8
    800009fc:	2e050513          	addi	a0,a0,736 # 80008cd8 <tx_chan>
    80000a00:	15f010ef          	jal	8000235e <wakeup>
    80000a04:	bff1                	j	800009e0 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a06:	8a5ff0ef          	jal	800002aa <consoleintr>
    int c = uartgetc();
    80000a0a:	f81ff0ef          	jal	8000098a <uartgetc>
    if(c == -1)
    80000a0e:	fe951ce3          	bne	a0,s1,80000a06 <uartintr+0x56>
  }
}
    80000a12:	60e2                	ld	ra,24(sp)
    80000a14:	6442                	ld	s0,16(sp)
    80000a16:	64a2                	ld	s1,8(sp)
    80000a18:	6105                	addi	sp,sp,32
    80000a1a:	8082                	ret

0000000080000a1c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a1c:	1101                	addi	sp,sp,-32
    80000a1e:	ec06                	sd	ra,24(sp)
    80000a20:	e822                	sd	s0,16(sp)
    80000a22:	e426                	sd	s1,8(sp)
    80000a24:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a26:	03451793          	slli	a5,a0,0x34
    80000a2a:	e3a5                	bnez	a5,80000a8a <kfree+0x6e>
    80000a2c:	84aa                	mv	s1,a0
    80000a2e:	00242797          	auipc	a5,0x242
    80000a32:	e1a78793          	addi	a5,a5,-486 # 80242848 <end>
    80000a36:	04f56a63          	bltu	a0,a5,80000a8a <kfree+0x6e>
    80000a3a:	47c5                	li	a5,17
    80000a3c:	07ee                	slli	a5,a5,0x1b
    80000a3e:	04f57663          	bgeu	a0,a5,80000a8a <kfree+0x6e>
    panic("kfree");

  // ---- ĐOẠN ĐỒNG BỘ BỘ ĐẾM THAM CHIẾU COW ----
  acquire(&kref.lock);
    80000a42:	00010517          	auipc	a0,0x10
    80000a46:	3c650513          	addi	a0,a0,966 # 80010e08 <kref>
    80000a4a:	32e000ef          	jal	80000d78 <acquire>
  uint64 idx = (uint64)pa / PGSIZE;
    80000a4e:	00c4d793          	srli	a5,s1,0xc
  
  // Bảo vệ hệ thống: Nếu trang chưa từng được đếm (hoặc trang bảng trang không quản lý ref)
  // thì đặt mặc định bằng 1 để giảm xuống 0 hợp lệ.
  if(kref.count[idx] <= 0){
    80000a52:	00478693          	addi	a3,a5,4
    80000a56:	068a                	slli	a3,a3,0x2
    80000a58:	00010717          	auipc	a4,0x10
    80000a5c:	3b070713          	addi	a4,a4,944 # 80010e08 <kref>
    80000a60:	9736                	add	a4,a4,a3
    80000a62:	4718                	lw	a4,8(a4)
    80000a64:	02e05a63          	blez	a4,80000a98 <kfree+0x7c>
    kref.count[idx] = 1;
  }

  kref.count[idx]--;
    80000a68:	377d                	addiw	a4,a4,-1
    80000a6a:	0007061b          	sext.w	a2,a4
    80000a6e:	0791                	addi	a5,a5,4
    80000a70:	078a                	slli	a5,a5,0x2
    80000a72:	00010697          	auipc	a3,0x10
    80000a76:	39668693          	addi	a3,a3,918 # 80010e08 <kref>
    80000a7a:	97b6                	add	a5,a5,a3
    80000a7c:	c798                	sw	a4,8(a5)
  
  if(kref.count[idx] > 0){
    80000a7e:	06c05663          	blez	a2,80000aea <kfree+0xce>
    // Nếu vẫn còn tiến trình khác dùng chung trang này -> Giữ lại RAM
    release(&kref.lock);
    80000a82:	8536                	mv	a0,a3
    80000a84:	38c000ef          	jal	80000e10 <release>
    return;
    80000a88:	a8a1                	j	80000ae0 <kfree+0xc4>
    80000a8a:	e04a                	sd	s2,0(sp)
    panic("kfree");
    80000a8c:	00007517          	auipc	a0,0x7
    80000a90:	5ac50513          	addi	a0,a0,1452 # 80008038 <etext+0x38>
    80000a94:	d4dff0ef          	jal	800007e0 <panic>
    80000a98:	e04a                	sd	s2,0(sp)
  kref.count[idx]--;
    80000a9a:	00010717          	auipc	a4,0x10
    80000a9e:	36e70713          	addi	a4,a4,878 # 80010e08 <kref>
    80000aa2:	00d707b3          	add	a5,a4,a3
    80000aa6:	0007a423          	sw	zero,8(a5)
  }
  release(&kref.lock);
    80000aaa:	00010517          	auipc	a0,0x10
    80000aae:	35e50513          	addi	a0,a0,862 # 80010e08 <kref>
    80000ab2:	35e000ef          	jal	80000e10 <release>
  // ---------------------------------------------

  // Khi count thực sự về 0, tiến hành xóa sạch dữ liệu và trả về kmem.freelist
  memset(pa, 1, PGSIZE);
    80000ab6:	6605                	lui	a2,0x1
    80000ab8:	4585                	li	a1,1
    80000aba:	8526                	mv	a0,s1
    80000abc:	390000ef          	jal	80000e4c <memset>

  r = (struct run*)pa;

  // SỬA TẠI ĐÂY: Sử dụng đúng tên cấu trúc gốc `kmem` của xv6
  acquire(&kmem.lock);
    80000ac0:	00010917          	auipc	s2,0x10
    80000ac4:	32890913          	addi	s2,s2,808 # 80010de8 <kmem>
    80000ac8:	854a                	mv	a0,s2
    80000aca:	2ae000ef          	jal	80000d78 <acquire>
  r->next = kmem.freelist;
    80000ace:	01893783          	ld	a5,24(s2)
    80000ad2:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ad4:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000ad8:	854a                	mv	a0,s2
    80000ada:	336000ef          	jal	80000e10 <release>
    80000ade:	6902                	ld	s2,0(sp)
}
    80000ae0:	60e2                	ld	ra,24(sp)
    80000ae2:	6442                	ld	s0,16(sp)
    80000ae4:	64a2                	ld	s1,8(sp)
    80000ae6:	6105                	addi	sp,sp,32
    80000ae8:	8082                	ret
    80000aea:	e04a                	sd	s2,0(sp)
    80000aec:	bf7d                	j	80000aaa <kfree+0x8e>

0000000080000aee <freerange>:
{
    80000aee:	7139                	addi	sp,sp,-64
    80000af0:	fc06                	sd	ra,56(sp)
    80000af2:	f822                	sd	s0,48(sp)
    80000af4:	f426                	sd	s1,40(sp)
    80000af6:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000af8:	6785                	lui	a5,0x1
    80000afa:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000afe:	953a                	add	a0,a0,a4
    80000b00:	777d                	lui	a4,0xfffff
    80000b02:	00e574b3          	and	s1,a0,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b06:	97a6                	add	a5,a5,s1
    80000b08:	04f5e363          	bltu	a1,a5,80000b4e <freerange+0x60>
    80000b0c:	f04a                	sd	s2,32(sp)
    80000b0e:	ec4e                	sd	s3,24(sp)
    80000b10:	e852                	sd	s4,16(sp)
    80000b12:	e456                	sd	s5,8(sp)
    80000b14:	e05a                	sd	s6,0(sp)
    80000b16:	892e                	mv	s2,a1
    kref.count[pa_idx(p)] = 1;
    80000b18:	00010b17          	auipc	s6,0x10
    80000b1c:	2f0b0b13          	addi	s6,s6,752 # 80010e08 <kref>
    80000b20:	4a85                	li	s5,1
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b22:	6a05                	lui	s4,0x1
    80000b24:	6989                	lui	s3,0x2
  return (uint64)pa / PGSIZE;
    80000b26:	00c4d793          	srli	a5,s1,0xc
    kref.count[pa_idx(p)] = 1;
    80000b2a:	0791                	addi	a5,a5,4
    80000b2c:	078a                	slli	a5,a5,0x2
    80000b2e:	97da                	add	a5,a5,s6
    80000b30:	0157a423          	sw	s5,8(a5)
    kfree(p);
    80000b34:	8526                	mv	a0,s1
    80000b36:	ee7ff0ef          	jal	80000a1c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    80000b3a:	87a6                	mv	a5,s1
    80000b3c:	94d2                	add	s1,s1,s4
    80000b3e:	97ce                	add	a5,a5,s3
    80000b40:	fef973e3          	bgeu	s2,a5,80000b26 <freerange+0x38>
    80000b44:	7902                	ld	s2,32(sp)
    80000b46:	69e2                	ld	s3,24(sp)
    80000b48:	6a42                	ld	s4,16(sp)
    80000b4a:	6aa2                	ld	s5,8(sp)
    80000b4c:	6b02                	ld	s6,0(sp)
}
    80000b4e:	70e2                	ld	ra,56(sp)
    80000b50:	7442                	ld	s0,48(sp)
    80000b52:	74a2                	ld	s1,40(sp)
    80000b54:	6121                	addi	sp,sp,64
    80000b56:	8082                	ret

0000000080000b58 <kinit>:
{
    80000b58:	1141                	addi	sp,sp,-16
    80000b5a:	e406                	sd	ra,8(sp)
    80000b5c:	e022                	sd	s0,0(sp)
    80000b5e:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b60:	00007597          	auipc	a1,0x7
    80000b64:	4e058593          	addi	a1,a1,1248 # 80008040 <etext+0x40>
    80000b68:	00010517          	auipc	a0,0x10
    80000b6c:	28050513          	addi	a0,a0,640 # 80010de8 <kmem>
    80000b70:	188000ef          	jal	80000cf8 <initlock>
  initlock(&kref.lock, "kref");
    80000b74:	00007597          	auipc	a1,0x7
    80000b78:	4d458593          	addi	a1,a1,1236 # 80008048 <etext+0x48>
    80000b7c:	00010517          	auipc	a0,0x10
    80000b80:	28c50513          	addi	a0,a0,652 # 80010e08 <kref>
    80000b84:	174000ef          	jal	80000cf8 <initlock>
  acquire(&kref.lock);
    80000b88:	00010517          	auipc	a0,0x10
    80000b8c:	28050513          	addi	a0,a0,640 # 80010e08 <kref>
    80000b90:	1e8000ef          	jal	80000d78 <acquire>
  for(int i = 0; i < PHYSTOP / PGSIZE; i++){
    80000b94:	00010797          	auipc	a5,0x10
    80000b98:	28c78793          	addi	a5,a5,652 # 80010e20 <kref+0x18>
    80000b9c:	00230717          	auipc	a4,0x230
    80000ba0:	28470713          	addi	a4,a4,644 # 80230e20 <pid_lock>
    kref.count[i] = 0;
    80000ba4:	0007a023          	sw	zero,0(a5)
  for(int i = 0; i < PHYSTOP / PGSIZE; i++){
    80000ba8:	0791                	addi	a5,a5,4
    80000baa:	fee79de3          	bne	a5,a4,80000ba4 <kinit+0x4c>
  release(&kref.lock);
    80000bae:	00010517          	auipc	a0,0x10
    80000bb2:	25a50513          	addi	a0,a0,602 # 80010e08 <kref>
    80000bb6:	25a000ef          	jal	80000e10 <release>
  freerange(end, (void*)PHYSTOP);
    80000bba:	45c5                	li	a1,17
    80000bbc:	05ee                	slli	a1,a1,0x1b
    80000bbe:	00242517          	auipc	a0,0x242
    80000bc2:	c8a50513          	addi	a0,a0,-886 # 80242848 <end>
    80000bc6:	f29ff0ef          	jal	80000aee <freerange>
}
    80000bca:	60a2                	ld	ra,8(sp)
    80000bcc:	6402                	ld	s0,0(sp)
    80000bce:	0141                	addi	sp,sp,16
    80000bd0:	8082                	ret

0000000080000bd2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000bdc:	00010497          	auipc	s1,0x10
    80000be0:	20c48493          	addi	s1,s1,524 # 80010de8 <kmem>
    80000be4:	8526                	mv	a0,s1
    80000be6:	192000ef          	jal	80000d78 <acquire>
  r = kmem.freelist;
    80000bea:	6c84                	ld	s1,24(s1)
  if(r)
    80000bec:	c4b9                	beqz	s1,80000c3a <kalloc+0x68>
    kmem.freelist = r->next;
    80000bee:	609c                	ld	a5,0(s1)
    80000bf0:	00010517          	auipc	a0,0x10
    80000bf4:	1f850513          	addi	a0,a0,504 # 80010de8 <kmem>
    80000bf8:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000bfa:	216000ef          	jal	80000e10 <release>

  if(r){
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bfe:	6605                	lui	a2,0x1
    80000c00:	4595                	li	a1,5
    80000c02:	8526                	mv	a0,s1
    80000c04:	248000ef          	jal	80000e4c <memset>
    
    // Khi một trang RAM được cấp phát mới thành công,
    // khởi tạo số lượng tham chiếu (Reference count) của nó bằng 1
    acquire(&kref.lock);
    80000c08:	00010517          	auipc	a0,0x10
    80000c0c:	20050513          	addi	a0,a0,512 # 80010e08 <kref>
    80000c10:	168000ef          	jal	80000d78 <acquire>
    kref.count[pa_idx(r)] = 1;
    80000c14:	00010517          	auipc	a0,0x10
    80000c18:	1f450513          	addi	a0,a0,500 # 80010e08 <kref>
  return (uint64)pa / PGSIZE;
    80000c1c:	00c4d793          	srli	a5,s1,0xc
    kref.count[pa_idx(r)] = 1;
    80000c20:	0791                	addi	a5,a5,4
    80000c22:	078a                	slli	a5,a5,0x2
    80000c24:	97aa                	add	a5,a5,a0
    80000c26:	4705                	li	a4,1
    80000c28:	c798                	sw	a4,8(a5)
    release(&kref.lock);
    80000c2a:	1e6000ef          	jal	80000e10 <release>
  }
  return (void*)r;
}
    80000c2e:	8526                	mv	a0,s1
    80000c30:	60e2                	ld	ra,24(sp)
    80000c32:	6442                	ld	s0,16(sp)
    80000c34:	64a2                	ld	s1,8(sp)
    80000c36:	6105                	addi	sp,sp,32
    80000c38:	8082                	ret
  release(&kmem.lock);
    80000c3a:	00010517          	auipc	a0,0x10
    80000c3e:	1ae50513          	addi	a0,a0,430 # 80010de8 <kmem>
    80000c42:	1ce000ef          	jal	80000e10 <release>
  if(r){
    80000c46:	b7e5                	j	80000c2e <kalloc+0x5c>

0000000080000c48 <kref_incr>:

// Hàm tăng bộ đếm tham chiếu (gọi khi thực hiện uvmcopy() nhân bản tiến trình)
void
kref_incr(uint64 pa)
{
  if(pa >= PHYSTOP || pa < (uint64)end) return;
    80000c48:	47c5                	li	a5,17
    80000c4a:	07ee                	slli	a5,a5,0x1b
    80000c4c:	04f57763          	bgeu	a0,a5,80000c9a <kref_incr+0x52>
{
    80000c50:	1101                	addi	sp,sp,-32
    80000c52:	ec06                	sd	ra,24(sp)
    80000c54:	e822                	sd	s0,16(sp)
    80000c56:	e426                	sd	s1,8(sp)
    80000c58:	1000                	addi	s0,sp,32
    80000c5a:	84aa                	mv	s1,a0
  if(pa >= PHYSTOP || pa < (uint64)end) return;
    80000c5c:	00242797          	auipc	a5,0x242
    80000c60:	bec78793          	addi	a5,a5,-1044 # 80242848 <end>
    80000c64:	00f57763          	bgeu	a0,a5,80000c72 <kref_incr+0x2a>
  
  acquire(&kref.lock);
  kref.count[pa / PGSIZE]++;
  release(&kref.lock);
}
    80000c68:	60e2                	ld	ra,24(sp)
    80000c6a:	6442                	ld	s0,16(sp)
    80000c6c:	64a2                	ld	s1,8(sp)
    80000c6e:	6105                	addi	sp,sp,32
    80000c70:	8082                	ret
  acquire(&kref.lock);
    80000c72:	00010517          	auipc	a0,0x10
    80000c76:	19650513          	addi	a0,a0,406 # 80010e08 <kref>
    80000c7a:	0fe000ef          	jal	80000d78 <acquire>
  kref.count[pa / PGSIZE]++;
    80000c7e:	80b1                	srli	s1,s1,0xc
    80000c80:	00010517          	auipc	a0,0x10
    80000c84:	18850513          	addi	a0,a0,392 # 80010e08 <kref>
    80000c88:	0491                	addi	s1,s1,4
    80000c8a:	048a                	slli	s1,s1,0x2
    80000c8c:	94aa                	add	s1,s1,a0
    80000c8e:	449c                	lw	a5,8(s1)
    80000c90:	2785                	addiw	a5,a5,1
    80000c92:	c49c                	sw	a5,8(s1)
  release(&kref.lock);
    80000c94:	17c000ef          	jal	80000e10 <release>
    80000c98:	bfc1                	j	80000c68 <kref_incr+0x20>
    80000c9a:	8082                	ret

0000000080000c9c <kref_get>:

// Hàm kiểm tra xem trang RAM vật lý này hiện tại có đang bị dùng chung hay không
int
kref_get(uint64 pa)
{
    80000c9c:	1101                	addi	sp,sp,-32
    80000c9e:	ec06                	sd	ra,24(sp)
    80000ca0:	e822                	sd	s0,16(sp)
    80000ca2:	e04a                	sd	s2,0(sp)
    80000ca4:	1000                	addi	s0,sp,32
  if(pa >= PHYSTOP || pa < (uint64)end) return 0;
    80000ca6:	47c5                	li	a5,17
    80000ca8:	07ee                	slli	a5,a5,0x1b
    80000caa:	4901                	li	s2,0
    80000cac:	00f57c63          	bgeu	a0,a5,80000cc4 <kref_get+0x28>
    80000cb0:	e426                	sd	s1,8(sp)
    80000cb2:	84aa                	mv	s1,a0
    80000cb4:	00242797          	auipc	a5,0x242
    80000cb8:	b9478793          	addi	a5,a5,-1132 # 80242848 <end>
    80000cbc:	4901                	li	s2,0
    80000cbe:	00f57963          	bgeu	a0,a5,80000cd0 <kref_get+0x34>
    80000cc2:	64a2                	ld	s1,8(sp)
  int cnt;
  acquire(&kref.lock);
  cnt = kref.count[pa / PGSIZE];
  release(&kref.lock);
  return cnt;
}
    80000cc4:	854a                	mv	a0,s2
    80000cc6:	60e2                	ld	ra,24(sp)
    80000cc8:	6442                	ld	s0,16(sp)
    80000cca:	6902                	ld	s2,0(sp)
    80000ccc:	6105                	addi	sp,sp,32
    80000cce:	8082                	ret
  acquire(&kref.lock);
    80000cd0:	00010517          	auipc	a0,0x10
    80000cd4:	13850513          	addi	a0,a0,312 # 80010e08 <kref>
    80000cd8:	0a0000ef          	jal	80000d78 <acquire>
  cnt = kref.count[pa / PGSIZE];
    80000cdc:	00010517          	auipc	a0,0x10
    80000ce0:	12c50513          	addi	a0,a0,300 # 80010e08 <kref>
    80000ce4:	80b1                	srli	s1,s1,0xc
    80000ce6:	0491                	addi	s1,s1,4
    80000ce8:	048a                	slli	s1,s1,0x2
    80000cea:	94aa                	add	s1,s1,a0
    80000cec:	0084a903          	lw	s2,8(s1)
  release(&kref.lock);
    80000cf0:	120000ef          	jal	80000e10 <release>
  return cnt;
    80000cf4:	64a2                	ld	s1,8(sp)
    80000cf6:	b7f9                	j	80000cc4 <kref_get+0x28>

0000000080000cf8 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000cf8:	1141                	addi	sp,sp,-16
    80000cfa:	e422                	sd	s0,8(sp)
    80000cfc:	0800                	addi	s0,sp,16
  lk->name = name;
    80000cfe:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000d00:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000d04:	00053823          	sd	zero,16(a0)
}
    80000d08:	6422                	ld	s0,8(sp)
    80000d0a:	0141                	addi	sp,sp,16
    80000d0c:	8082                	ret

0000000080000d0e <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000d0e:	411c                	lw	a5,0(a0)
    80000d10:	e399                	bnez	a5,80000d16 <holding+0x8>
    80000d12:	4501                	li	a0,0
  return r;
}
    80000d14:	8082                	ret
{
    80000d16:	1101                	addi	sp,sp,-32
    80000d18:	ec06                	sd	ra,24(sp)
    80000d1a:	e822                	sd	s0,16(sp)
    80000d1c:	e426                	sd	s1,8(sp)
    80000d1e:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000d20:	6904                	ld	s1,16(a0)
    80000d22:	71f000ef          	jal	80001c40 <mycpu>
    80000d26:	40a48533          	sub	a0,s1,a0
    80000d2a:	00153513          	seqz	a0,a0
}
    80000d2e:	60e2                	ld	ra,24(sp)
    80000d30:	6442                	ld	s0,16(sp)
    80000d32:	64a2                	ld	s1,8(sp)
    80000d34:	6105                	addi	sp,sp,32
    80000d36:	8082                	ret

0000000080000d38 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000d38:	1101                	addi	sp,sp,-32
    80000d3a:	ec06                	sd	ra,24(sp)
    80000d3c:	e822                	sd	s0,16(sp)
    80000d3e:	e426                	sd	s1,8(sp)
    80000d40:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d42:	100024f3          	csrr	s1,sstatus
    80000d46:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000d4a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d4c:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000d50:	6f1000ef          	jal	80001c40 <mycpu>
    80000d54:	5d3c                	lw	a5,120(a0)
    80000d56:	cb99                	beqz	a5,80000d6c <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d58:	6e9000ef          	jal	80001c40 <mycpu>
    80000d5c:	5d3c                	lw	a5,120(a0)
    80000d5e:	2785                	addiw	a5,a5,1
    80000d60:	dd3c                	sw	a5,120(a0)
}
    80000d62:	60e2                	ld	ra,24(sp)
    80000d64:	6442                	ld	s0,16(sp)
    80000d66:	64a2                	ld	s1,8(sp)
    80000d68:	6105                	addi	sp,sp,32
    80000d6a:	8082                	ret
    mycpu()->intena = old;
    80000d6c:	6d5000ef          	jal	80001c40 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d70:	8085                	srli	s1,s1,0x1
    80000d72:	8885                	andi	s1,s1,1
    80000d74:	dd64                	sw	s1,124(a0)
    80000d76:	b7cd                	j	80000d58 <push_off+0x20>

0000000080000d78 <acquire>:
{
    80000d78:	1101                	addi	sp,sp,-32
    80000d7a:	ec06                	sd	ra,24(sp)
    80000d7c:	e822                	sd	s0,16(sp)
    80000d7e:	e426                	sd	s1,8(sp)
    80000d80:	1000                	addi	s0,sp,32
    80000d82:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d84:	fb5ff0ef          	jal	80000d38 <push_off>
  if(holding(lk))
    80000d88:	8526                	mv	a0,s1
    80000d8a:	f85ff0ef          	jal	80000d0e <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d8e:	4705                	li	a4,1
  if(holding(lk))
    80000d90:	e105                	bnez	a0,80000db0 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d92:	87ba                	mv	a5,a4
    80000d94:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d98:	2781                	sext.w	a5,a5
    80000d9a:	ffe5                	bnez	a5,80000d92 <acquire+0x1a>
  __sync_synchronize();
    80000d9c:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000da0:	6a1000ef          	jal	80001c40 <mycpu>
    80000da4:	e888                	sd	a0,16(s1)
}
    80000da6:	60e2                	ld	ra,24(sp)
    80000da8:	6442                	ld	s0,16(sp)
    80000daa:	64a2                	ld	s1,8(sp)
    80000dac:	6105                	addi	sp,sp,32
    80000dae:	8082                	ret
    panic("acquire");
    80000db0:	00007517          	auipc	a0,0x7
    80000db4:	2a050513          	addi	a0,a0,672 # 80008050 <etext+0x50>
    80000db8:	a29ff0ef          	jal	800007e0 <panic>

0000000080000dbc <pop_off>:

void
pop_off(void)
{
    80000dbc:	1141                	addi	sp,sp,-16
    80000dbe:	e406                	sd	ra,8(sp)
    80000dc0:	e022                	sd	s0,0(sp)
    80000dc2:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000dc4:	67d000ef          	jal	80001c40 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000dc8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000dcc:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000dce:	e78d                	bnez	a5,80000df8 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000dd0:	5d3c                	lw	a5,120(a0)
    80000dd2:	02f05963          	blez	a5,80000e04 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000dd6:	37fd                	addiw	a5,a5,-1
    80000dd8:	0007871b          	sext.w	a4,a5
    80000ddc:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000dde:	eb09                	bnez	a4,80000df0 <pop_off+0x34>
    80000de0:	5d7c                	lw	a5,124(a0)
    80000de2:	c799                	beqz	a5,80000df0 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000de4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000de8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000dec:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000df0:	60a2                	ld	ra,8(sp)
    80000df2:	6402                	ld	s0,0(sp)
    80000df4:	0141                	addi	sp,sp,16
    80000df6:	8082                	ret
    panic("pop_off - interruptible");
    80000df8:	00007517          	auipc	a0,0x7
    80000dfc:	26050513          	addi	a0,a0,608 # 80008058 <etext+0x58>
    80000e00:	9e1ff0ef          	jal	800007e0 <panic>
    panic("pop_off");
    80000e04:	00007517          	auipc	a0,0x7
    80000e08:	26c50513          	addi	a0,a0,620 # 80008070 <etext+0x70>
    80000e0c:	9d5ff0ef          	jal	800007e0 <panic>

0000000080000e10 <release>:
{
    80000e10:	1101                	addi	sp,sp,-32
    80000e12:	ec06                	sd	ra,24(sp)
    80000e14:	e822                	sd	s0,16(sp)
    80000e16:	e426                	sd	s1,8(sp)
    80000e18:	1000                	addi	s0,sp,32
    80000e1a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000e1c:	ef3ff0ef          	jal	80000d0e <holding>
    80000e20:	c105                	beqz	a0,80000e40 <release+0x30>
  lk->cpu = 0;
    80000e22:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000e26:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000e2a:	0f50000f          	fence	iorw,ow
    80000e2e:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000e32:	f8bff0ef          	jal	80000dbc <pop_off>
}
    80000e36:	60e2                	ld	ra,24(sp)
    80000e38:	6442                	ld	s0,16(sp)
    80000e3a:	64a2                	ld	s1,8(sp)
    80000e3c:	6105                	addi	sp,sp,32
    80000e3e:	8082                	ret
    panic("release");
    80000e40:	00007517          	auipc	a0,0x7
    80000e44:	23850513          	addi	a0,a0,568 # 80008078 <etext+0x78>
    80000e48:	999ff0ef          	jal	800007e0 <panic>

0000000080000e4c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000e4c:	1141                	addi	sp,sp,-16
    80000e4e:	e422                	sd	s0,8(sp)
    80000e50:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000e52:	ca19                	beqz	a2,80000e68 <memset+0x1c>
    80000e54:	87aa                	mv	a5,a0
    80000e56:	1602                	slli	a2,a2,0x20
    80000e58:	9201                	srli	a2,a2,0x20
    80000e5a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e5e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e62:	0785                	addi	a5,a5,1
    80000e64:	fee79de3          	bne	a5,a4,80000e5e <memset+0x12>
  }
  return dst;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret

0000000080000e6e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e6e:	1141                	addi	sp,sp,-16
    80000e70:	e422                	sd	s0,8(sp)
    80000e72:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e74:	ca05                	beqz	a2,80000ea4 <memcmp+0x36>
    80000e76:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000e7a:	1682                	slli	a3,a3,0x20
    80000e7c:	9281                	srli	a3,a3,0x20
    80000e7e:	0685                	addi	a3,a3,1
    80000e80:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000e82:	00054783          	lbu	a5,0(a0)
    80000e86:	0005c703          	lbu	a4,0(a1)
    80000e8a:	00e79863          	bne	a5,a4,80000e9a <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000e8e:	0505                	addi	a0,a0,1
    80000e90:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e92:	fed518e3          	bne	a0,a3,80000e82 <memcmp+0x14>
  }

  return 0;
    80000e96:	4501                	li	a0,0
    80000e98:	a019                	j	80000e9e <memcmp+0x30>
      return *s1 - *s2;
    80000e9a:	40e7853b          	subw	a0,a5,a4
}
    80000e9e:	6422                	ld	s0,8(sp)
    80000ea0:	0141                	addi	sp,sp,16
    80000ea2:	8082                	ret
  return 0;
    80000ea4:	4501                	li	a0,0
    80000ea6:	bfe5                	j	80000e9e <memcmp+0x30>

0000000080000ea8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000ea8:	1141                	addi	sp,sp,-16
    80000eaa:	e422                	sd	s0,8(sp)
    80000eac:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000eae:	c205                	beqz	a2,80000ece <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000eb0:	02a5e263          	bltu	a1,a0,80000ed4 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000eb4:	1602                	slli	a2,a2,0x20
    80000eb6:	9201                	srli	a2,a2,0x20
    80000eb8:	00c587b3          	add	a5,a1,a2
{
    80000ebc:	872a                	mv	a4,a0
      *d++ = *s++;
    80000ebe:	0585                	addi	a1,a1,1
    80000ec0:	0705                	addi	a4,a4,1
    80000ec2:	fff5c683          	lbu	a3,-1(a1)
    80000ec6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000eca:	feb79ae3          	bne	a5,a1,80000ebe <memmove+0x16>

  return dst;
}
    80000ece:	6422                	ld	s0,8(sp)
    80000ed0:	0141                	addi	sp,sp,16
    80000ed2:	8082                	ret
  if(s < d && s + n > d){
    80000ed4:	02061693          	slli	a3,a2,0x20
    80000ed8:	9281                	srli	a3,a3,0x20
    80000eda:	00d58733          	add	a4,a1,a3
    80000ede:	fce57be3          	bgeu	a0,a4,80000eb4 <memmove+0xc>
    d += n;
    80000ee2:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000ee4:	fff6079b          	addiw	a5,a2,-1
    80000ee8:	1782                	slli	a5,a5,0x20
    80000eea:	9381                	srli	a5,a5,0x20
    80000eec:	fff7c793          	not	a5,a5
    80000ef0:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ef2:	177d                	addi	a4,a4,-1
    80000ef4:	16fd                	addi	a3,a3,-1
    80000ef6:	00074603          	lbu	a2,0(a4)
    80000efa:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000efe:	fef71ae3          	bne	a4,a5,80000ef2 <memmove+0x4a>
    80000f02:	b7f1                	j	80000ece <memmove+0x26>

0000000080000f04 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000f04:	1141                	addi	sp,sp,-16
    80000f06:	e406                	sd	ra,8(sp)
    80000f08:	e022                	sd	s0,0(sp)
    80000f0a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000f0c:	f9dff0ef          	jal	80000ea8 <memmove>
}
    80000f10:	60a2                	ld	ra,8(sp)
    80000f12:	6402                	ld	s0,0(sp)
    80000f14:	0141                	addi	sp,sp,16
    80000f16:	8082                	ret

0000000080000f18 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000f18:	1141                	addi	sp,sp,-16
    80000f1a:	e422                	sd	s0,8(sp)
    80000f1c:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000f1e:	ce11                	beqz	a2,80000f3a <strncmp+0x22>
    80000f20:	00054783          	lbu	a5,0(a0)
    80000f24:	cf89                	beqz	a5,80000f3e <strncmp+0x26>
    80000f26:	0005c703          	lbu	a4,0(a1)
    80000f2a:	00f71a63          	bne	a4,a5,80000f3e <strncmp+0x26>
    n--, p++, q++;
    80000f2e:	367d                	addiw	a2,a2,-1
    80000f30:	0505                	addi	a0,a0,1
    80000f32:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000f34:	f675                	bnez	a2,80000f20 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000f36:	4501                	li	a0,0
    80000f38:	a801                	j	80000f48 <strncmp+0x30>
    80000f3a:	4501                	li	a0,0
    80000f3c:	a031                	j	80000f48 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000f3e:	00054503          	lbu	a0,0(a0)
    80000f42:	0005c783          	lbu	a5,0(a1)
    80000f46:	9d1d                	subw	a0,a0,a5
}
    80000f48:	6422                	ld	s0,8(sp)
    80000f4a:	0141                	addi	sp,sp,16
    80000f4c:	8082                	ret

0000000080000f4e <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f4e:	1141                	addi	sp,sp,-16
    80000f50:	e422                	sd	s0,8(sp)
    80000f52:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f54:	87aa                	mv	a5,a0
    80000f56:	86b2                	mv	a3,a2
    80000f58:	367d                	addiw	a2,a2,-1
    80000f5a:	02d05563          	blez	a3,80000f84 <strncpy+0x36>
    80000f5e:	0785                	addi	a5,a5,1
    80000f60:	0005c703          	lbu	a4,0(a1)
    80000f64:	fee78fa3          	sb	a4,-1(a5)
    80000f68:	0585                	addi	a1,a1,1
    80000f6a:	f775                	bnez	a4,80000f56 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000f6c:	873e                	mv	a4,a5
    80000f6e:	9fb5                	addw	a5,a5,a3
    80000f70:	37fd                	addiw	a5,a5,-1
    80000f72:	00c05963          	blez	a2,80000f84 <strncpy+0x36>
    *s++ = 0;
    80000f76:	0705                	addi	a4,a4,1
    80000f78:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000f7c:	40e786bb          	subw	a3,a5,a4
    80000f80:	fed04be3          	bgtz	a3,80000f76 <strncpy+0x28>
  return os;
}
    80000f84:	6422                	ld	s0,8(sp)
    80000f86:	0141                	addi	sp,sp,16
    80000f88:	8082                	ret

0000000080000f8a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f8a:	1141                	addi	sp,sp,-16
    80000f8c:	e422                	sd	s0,8(sp)
    80000f8e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f90:	02c05363          	blez	a2,80000fb6 <safestrcpy+0x2c>
    80000f94:	fff6069b          	addiw	a3,a2,-1
    80000f98:	1682                	slli	a3,a3,0x20
    80000f9a:	9281                	srli	a3,a3,0x20
    80000f9c:	96ae                	add	a3,a3,a1
    80000f9e:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000fa0:	00d58963          	beq	a1,a3,80000fb2 <safestrcpy+0x28>
    80000fa4:	0585                	addi	a1,a1,1
    80000fa6:	0785                	addi	a5,a5,1
    80000fa8:	fff5c703          	lbu	a4,-1(a1)
    80000fac:	fee78fa3          	sb	a4,-1(a5)
    80000fb0:	fb65                	bnez	a4,80000fa0 <safestrcpy+0x16>
    ;
  *s = 0;
    80000fb2:	00078023          	sb	zero,0(a5)
  return os;
}
    80000fb6:	6422                	ld	s0,8(sp)
    80000fb8:	0141                	addi	sp,sp,16
    80000fba:	8082                	ret

0000000080000fbc <strlen>:

int
strlen(const char *s)
{
    80000fbc:	1141                	addi	sp,sp,-16
    80000fbe:	e422                	sd	s0,8(sp)
    80000fc0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000fc2:	00054783          	lbu	a5,0(a0)
    80000fc6:	cf91                	beqz	a5,80000fe2 <strlen+0x26>
    80000fc8:	0505                	addi	a0,a0,1
    80000fca:	87aa                	mv	a5,a0
    80000fcc:	86be                	mv	a3,a5
    80000fce:	0785                	addi	a5,a5,1
    80000fd0:	fff7c703          	lbu	a4,-1(a5)
    80000fd4:	ff65                	bnez	a4,80000fcc <strlen+0x10>
    80000fd6:	40a6853b          	subw	a0,a3,a0
    80000fda:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000fdc:	6422                	ld	s0,8(sp)
    80000fde:	0141                	addi	sp,sp,16
    80000fe0:	8082                	ret
  for(n = 0; s[n]; n++)
    80000fe2:	4501                	li	a0,0
    80000fe4:	bfe5                	j	80000fdc <strlen+0x20>

0000000080000fe6 <main>:
volatile static int started = 0;
extern struct spinlock ptlock; // Khai báo extern từ sysproc.c
// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000fe6:	1141                	addi	sp,sp,-16
    80000fe8:	e406                	sd	ra,8(sp)
    80000fea:	e022                	sd	s0,0(sp)
    80000fec:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fee:	443000ef          	jal	80001c30 <cpuid>
    initlock(&ptlock, "ptlock");
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000ff2:	00008717          	auipc	a4,0x8
    80000ff6:	cee70713          	addi	a4,a4,-786 # 80008ce0 <started>
  if(cpuid() == 0){
    80000ffa:	c51d                	beqz	a0,80001028 <main+0x42>
    while(started == 0)
    80000ffc:	431c                	lw	a5,0(a4)
    80000ffe:	2781                	sext.w	a5,a5
    80001000:	dff5                	beqz	a5,80000ffc <main+0x16>
      ;
    __sync_synchronize();
    80001002:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80001006:	42b000ef          	jal	80001c30 <cpuid>
    8000100a:	85aa                	mv	a1,a0
    8000100c:	00007517          	auipc	a0,0x7
    80001010:	09c50513          	addi	a0,a0,156 # 800080a8 <etext+0xa8>
    80001014:	ce6ff0ef          	jal	800004fa <printf>
    kvminithart();    // turn on paging
    80001018:	0bc000ef          	jal	800010d4 <kvminithart>
    trapinithart();   // install kernel trap vector
    8000101c:	019010ef          	jal	80002834 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80001020:	419040ef          	jal	80005c38 <plicinithart>
  }

  scheduler();        
    80001024:	14c010ef          	jal	80002170 <scheduler>
    consoleinit();
    80001028:	bfcff0ef          	jal	80000424 <consoleinit>
    printfinit();
    8000102c:	ff0ff0ef          	jal	8000081c <printfinit>
    printf("\n");
    80001030:	00007517          	auipc	a0,0x7
    80001034:	05050513          	addi	a0,a0,80 # 80008080 <etext+0x80>
    80001038:	cc2ff0ef          	jal	800004fa <printf>
    printf("xv6 kernel is booting\n");
    8000103c:	00007517          	auipc	a0,0x7
    80001040:	04c50513          	addi	a0,a0,76 # 80008088 <etext+0x88>
    80001044:	cb6ff0ef          	jal	800004fa <printf>
    printf("\n");
    80001048:	00007517          	auipc	a0,0x7
    8000104c:	03850513          	addi	a0,a0,56 # 80008080 <etext+0x80>
    80001050:	caaff0ef          	jal	800004fa <printf>
    kinit();         // physical page allocator
    80001054:	b05ff0ef          	jal	80000b58 <kinit>
    kvminit();       // create kernel page table
    80001058:	2f2000ef          	jal	8000134a <kvminit>
    kvminithart();   // turn on paging
    8000105c:	078000ef          	jal	800010d4 <kvminithart>
    procinit();      // process table
    80001060:	361000ef          	jal	80001bc0 <procinit>
    trapinit();      // trap vectors
    80001064:	7ac010ef          	jal	80002810 <trapinit>
    trapinithart();  // install kernel trap vector
    80001068:	7cc010ef          	jal	80002834 <trapinithart>
    plicinit();      // set up interrupt controller
    8000106c:	3b3040ef          	jal	80005c1e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001070:	3c9040ef          	jal	80005c38 <plicinithart>
    binit();         // buffer cache
    80001074:	28a020ef          	jal	800032fe <binit>
    iinit();         // inode table
    80001078:	011020ef          	jal	80003888 <iinit>
    fileinit();      // file table
    8000107c:	702030ef          	jal	8000477e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001080:	4a9040ef          	jal	80005d28 <virtio_disk_init>
    initlock(&ptlock, "ptlock");
    80001084:	00007597          	auipc	a1,0x7
    80001088:	01c58593          	addi	a1,a1,28 # 800080a0 <etext+0xa0>
    8000108c:	00236517          	auipc	a0,0x236
    80001090:	3dc50513          	addi	a0,a0,988 # 80237468 <ptlock>
    80001094:	c65ff0ef          	jal	80000cf8 <initlock>
    userinit();      // first user process
    80001098:	72d000ef          	jal	80001fc4 <userinit>
    __sync_synchronize();
    8000109c:	0ff0000f          	fence
    started = 1;
    800010a0:	4785                	li	a5,1
    800010a2:	00008717          	auipc	a4,0x8
    800010a6:	c2f72f23          	sw	a5,-962(a4) # 80008ce0 <started>
    800010aa:	bfad                	j	80001024 <main+0x3e>

00000000800010ac <kvm_switch>:
// the kernel's page table, and enable paging.
// Cải tiến hàm để nạp bất kỳ bảng trang nào (linh hoạt hơn)
void
kvm_switch(pagetable_t kpt)
{
  if(kpt == 0) panic("kvm_switch: null kpt"); // Kiểm tra an toàn
    800010ac:	c911                	beqz	a0,800010c0 <kvm_switch+0x14>
  
  w_satp(MAKE_SATP(kpt)); // Nạp bảng trang vào thanh ghi satp
    800010ae:	8131                	srli	a0,a0,0xc
    800010b0:	57fd                	li	a5,-1
    800010b2:	17fe                	slli	a5,a5,0x3f
    800010b4:	8d5d                	or	a0,a0,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800010b6:	18051073          	csrw	satp,a0
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    800010ba:	12000073          	sfence.vma
    800010be:	8082                	ret
{
    800010c0:	1141                	addi	sp,sp,-16
    800010c2:	e406                	sd	ra,8(sp)
    800010c4:	e022                	sd	s0,0(sp)
    800010c6:	0800                	addi	s0,sp,16
  if(kpt == 0) panic("kvm_switch: null kpt"); // Kiểm tra an toàn
    800010c8:	00007517          	auipc	a0,0x7
    800010cc:	ff850513          	addi	a0,a0,-8 # 800080c0 <etext+0xc0>
    800010d0:	f10ff0ef          	jal	800007e0 <panic>

00000000800010d4 <kvminithart>:
}

// Giữ lại tên hàm cũ nhưng gọi qua hàm cải tiến để tránh lỗi biên dịch
void
kvminithart()
{
    800010d4:	1141                	addi	sp,sp,-16
    800010d6:	e406                	sd	ra,8(sp)
    800010d8:	e022                	sd	s0,0(sp)
    800010da:	0800                	addi	s0,sp,16
  kvm_switch(kernel_pagetable); // Nạp bảng trang nhân mặc định
    800010dc:	00008517          	auipc	a0,0x8
    800010e0:	c0c53503          	ld	a0,-1012(a0) # 80008ce8 <kernel_pagetable>
    800010e4:	fc9ff0ef          	jal	800010ac <kvm_switch>
}
    800010e8:	60a2                	ld	ra,8(sp)
    800010ea:	6402                	ld	s0,0(sp)
    800010ec:	0141                	addi	sp,sp,16
    800010ee:	8082                	ret

00000000800010f0 <walk>:
// Return the address of the PTE in page table pagetable
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010f0:	7139                	addi	sp,sp,-64
    800010f2:	fc06                	sd	ra,56(sp)
    800010f4:	f822                	sd	s0,48(sp)
    800010f6:	f426                	sd	s1,40(sp)
    800010f8:	f04a                	sd	s2,32(sp)
    800010fa:	ec4e                	sd	s3,24(sp)
    800010fc:	e852                	sd	s4,16(sp)
    800010fe:	e456                	sd	s5,8(sp)
    80001100:	e05a                	sd	s6,0(sp)
    80001102:	0080                	addi	s0,sp,64
    80001104:	84aa                	mv	s1,a0
    80001106:	89ae                	mv	s3,a1
    80001108:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000110a:	57fd                	li	a5,-1
    8000110c:	83e9                	srli	a5,a5,0x1a
    8000110e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001110:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001112:	02b7fc63          	bgeu	a5,a1,8000114a <walk+0x5a>
    panic("walk");
    80001116:	00007517          	auipc	a0,0x7
    8000111a:	fc250513          	addi	a0,a0,-62 # 800080d8 <etext+0xd8>
    8000111e:	ec2ff0ef          	jal	800007e0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001122:	060a8263          	beqz	s5,80001186 <walk+0x96>
    80001126:	aadff0ef          	jal	80000bd2 <kalloc>
    8000112a:	84aa                	mv	s1,a0
    8000112c:	c139                	beqz	a0,80001172 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000112e:	6605                	lui	a2,0x1
    80001130:	4581                	li	a1,0
    80001132:	d1bff0ef          	jal	80000e4c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001136:	00c4d793          	srli	a5,s1,0xc
    8000113a:	07aa                	slli	a5,a5,0xa
    8000113c:	0017e793          	ori	a5,a5,1
    80001140:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001144:	3a5d                	addiw	s4,s4,-9 # ff7 <_entry-0x7ffff009>
    80001146:	036a0063          	beq	s4,s6,80001166 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000114a:	0149d933          	srl	s2,s3,s4
    8000114e:	1ff97913          	andi	s2,s2,511
    80001152:	090e                	slli	s2,s2,0x3
    80001154:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001156:	00093483          	ld	s1,0(s2)
    8000115a:	0014f793          	andi	a5,s1,1
    8000115e:	d3f1                	beqz	a5,80001122 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001160:	80a9                	srli	s1,s1,0xa
    80001162:	04b2                	slli	s1,s1,0xc
    80001164:	b7c5                	j	80001144 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001166:	00c9d513          	srli	a0,s3,0xc
    8000116a:	1ff57513          	andi	a0,a0,511
    8000116e:	050e                	slli	a0,a0,0x3
    80001170:	9526                	add	a0,a0,s1
}
    80001172:	70e2                	ld	ra,56(sp)
    80001174:	7442                	ld	s0,48(sp)
    80001176:	74a2                	ld	s1,40(sp)
    80001178:	7902                	ld	s2,32(sp)
    8000117a:	69e2                	ld	s3,24(sp)
    8000117c:	6a42                	ld	s4,16(sp)
    8000117e:	6aa2                	ld	s5,8(sp)
    80001180:	6b02                	ld	s6,0(sp)
    80001182:	6121                	addi	sp,sp,64
    80001184:	8082                	ret
        return 0;
    80001186:	4501                	li	a0,0
    80001188:	b7ed                	j	80001172 <walk+0x82>

000000008000118a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000118a:	57fd                	li	a5,-1
    8000118c:	83e9                	srli	a5,a5,0x1a
    8000118e:	00b7f463          	bgeu	a5,a1,80001196 <walkaddr+0xc>
    return 0;
    80001192:	4501                	li	a0,0
  pte = walk(pagetable, va, 0);
  if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001194:	8082                	ret
{
    80001196:	1141                	addi	sp,sp,-16
    80001198:	e406                	sd	ra,8(sp)
    8000119a:	e022                	sd	s0,0(sp)
    8000119c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000119e:	4601                	li	a2,0
    800011a0:	f51ff0ef          	jal	800010f0 <walk>
  if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    800011a4:	cd19                	beqz	a0,800011c2 <walkaddr+0x38>
    800011a6:	611c                	ld	a5,0(a0)
    800011a8:	0117f693          	andi	a3,a5,17
    800011ac:	4745                	li	a4,17
    return 0;
    800011ae:	4501                	li	a0,0
  if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0)
    800011b0:	00e69563          	bne	a3,a4,800011ba <walkaddr+0x30>
  pa = PTE2PA(*pte);
    800011b4:	83a9                	srli	a5,a5,0xa
    800011b6:	00c79513          	slli	a0,a5,0xc
}
    800011ba:	60a2                	ld	ra,8(sp)
    800011bc:	6402                	ld	s0,0(sp)
    800011be:	0141                	addi	sp,sp,16
    800011c0:	8082                	ret
    return 0;
    800011c2:	4501                	li	a0,0
    800011c4:	bfdd                	j	800011ba <walkaddr+0x30>

00000000800011c6 <mappages>:

// Create PTEs for virtual addresses
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011c6:	715d                	addi	sp,sp,-80
    800011c8:	e486                	sd	ra,72(sp)
    800011ca:	e0a2                	sd	s0,64(sp)
    800011cc:	fc26                	sd	s1,56(sp)
    800011ce:	f84a                	sd	s2,48(sp)
    800011d0:	f44e                	sd	s3,40(sp)
    800011d2:	f052                	sd	s4,32(sp)
    800011d4:	ec56                	sd	s5,24(sp)
    800011d6:	e85a                	sd	s6,16(sp)
    800011d8:	e45e                	sd	s7,8(sp)
    800011da:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0) panic("mappages: va not aligned");
    800011dc:	03459793          	slli	a5,a1,0x34
    800011e0:	e7a9                	bnez	a5,8000122a <mappages+0x64>
    800011e2:	8aaa                	mv	s5,a0
    800011e4:	8b3a                	mv	s6,a4
  if((size % PGSIZE) != 0) panic("mappages: size not aligned");
    800011e6:	03461793          	slli	a5,a2,0x34
    800011ea:	e7b1                	bnez	a5,80001236 <mappages+0x70>
  if(size == 0) panic("mappages: size");
    800011ec:	ca39                	beqz	a2,80001242 <mappages+0x7c>
  
  a = va;
  last = va + size - PGSIZE;
    800011ee:	77fd                	lui	a5,0xfffff
    800011f0:	963e                	add	a2,a2,a5
    800011f2:	00b609b3          	add	s3,a2,a1
  a = va;
    800011f6:	892e                	mv	s2,a1
    800011f8:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011fc:	6b85                	lui	s7,0x1
    800011fe:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001202:	4605                	li	a2,1
    80001204:	85ca                	mv	a1,s2
    80001206:	8556                	mv	a0,s5
    80001208:	ee9ff0ef          	jal	800010f0 <walk>
    8000120c:	c539                	beqz	a0,8000125a <mappages+0x94>
    if(*pte & PTE_V)
    8000120e:	611c                	ld	a5,0(a0)
    80001210:	8b85                	andi	a5,a5,1
    80001212:	ef95                	bnez	a5,8000124e <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001214:	80b1                	srli	s1,s1,0xc
    80001216:	04aa                	slli	s1,s1,0xa
    80001218:	0164e4b3          	or	s1,s1,s6
    8000121c:	0014e493          	ori	s1,s1,1
    80001220:	e104                	sd	s1,0(a0)
    if(a == last)
    80001222:	05390863          	beq	s2,s3,80001272 <mappages+0xac>
    a += PGSIZE;
    80001226:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001228:	bfd9                	j	800011fe <mappages+0x38>
  if((va % PGSIZE) != 0) panic("mappages: va not aligned");
    8000122a:	00007517          	auipc	a0,0x7
    8000122e:	eb650513          	addi	a0,a0,-330 # 800080e0 <etext+0xe0>
    80001232:	daeff0ef          	jal	800007e0 <panic>
  if((size % PGSIZE) != 0) panic("mappages: size not aligned");
    80001236:	00007517          	auipc	a0,0x7
    8000123a:	eca50513          	addi	a0,a0,-310 # 80008100 <etext+0x100>
    8000123e:	da2ff0ef          	jal	800007e0 <panic>
  if(size == 0) panic("mappages: size");
    80001242:	00007517          	auipc	a0,0x7
    80001246:	ede50513          	addi	a0,a0,-290 # 80008120 <etext+0x120>
    8000124a:	d96ff0ef          	jal	800007e0 <panic>
      panic("mappages: remap");
    8000124e:	00007517          	auipc	a0,0x7
    80001252:	ee250513          	addi	a0,a0,-286 # 80008130 <etext+0x130>
    80001256:	d8aff0ef          	jal	800007e0 <panic>
      return -1;
    8000125a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000125c:	60a6                	ld	ra,72(sp)
    8000125e:	6406                	ld	s0,64(sp)
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
    8000126e:	6161                	addi	sp,sp,80
    80001270:	8082                	ret
  return 0;
    80001272:	4501                	li	a0,0
    80001274:	b7e5                	j	8000125c <mappages+0x96>

0000000080001276 <kvmmap>:
{
    80001276:	1141                	addi	sp,sp,-16
    80001278:	e406                	sd	ra,8(sp)
    8000127a:	e022                	sd	s0,0(sp)
    8000127c:	0800                	addi	s0,sp,16
    8000127e:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001280:	86b2                	mv	a3,a2
    80001282:	863e                	mv	a2,a5
    80001284:	f43ff0ef          	jal	800011c6 <mappages>
    80001288:	e509                	bnez	a0,80001292 <kvmmap+0x1c>
}
    8000128a:	60a2                	ld	ra,8(sp)
    8000128c:	6402                	ld	s0,0(sp)
    8000128e:	0141                	addi	sp,sp,16
    80001290:	8082                	ret
    panic("kvmmap");
    80001292:	00007517          	auipc	a0,0x7
    80001296:	eae50513          	addi	a0,a0,-338 # 80008140 <etext+0x140>
    8000129a:	d46ff0ef          	jal	800007e0 <panic>

000000008000129e <kvmmake>:
{
    8000129e:	1101                	addi	sp,sp,-32
    800012a0:	ec06                	sd	ra,24(sp)
    800012a2:	e822                	sd	s0,16(sp)
    800012a4:	e426                	sd	s1,8(sp)
    800012a6:	e04a                	sd	s2,0(sp)
    800012a8:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800012aa:	929ff0ef          	jal	80000bd2 <kalloc>
    800012ae:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012b0:	6605                	lui	a2,0x1
    800012b2:	4581                	li	a1,0
    800012b4:	b99ff0ef          	jal	80000e4c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012b8:	4719                	li	a4,6
    800012ba:	6685                	lui	a3,0x1
    800012bc:	10000637          	lui	a2,0x10000
    800012c0:	100005b7          	lui	a1,0x10000
    800012c4:	8526                	mv	a0,s1
    800012c6:	fb1ff0ef          	jal	80001276 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012ca:	4719                	li	a4,6
    800012cc:	6685                	lui	a3,0x1
    800012ce:	10001637          	lui	a2,0x10001
    800012d2:	100015b7          	lui	a1,0x10001
    800012d6:	8526                	mv	a0,s1
    800012d8:	f9fff0ef          	jal	80001276 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800012dc:	4719                	li	a4,6
    800012de:	040006b7          	lui	a3,0x4000
    800012e2:	0c000637          	lui	a2,0xc000
    800012e6:	0c0005b7          	lui	a1,0xc000
    800012ea:	8526                	mv	a0,s1
    800012ec:	f8bff0ef          	jal	80001276 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012f0:	00007917          	auipc	s2,0x7
    800012f4:	d1090913          	addi	s2,s2,-752 # 80008000 <etext>
    800012f8:	4729                	li	a4,10
    800012fa:	80007697          	auipc	a3,0x80007
    800012fe:	d0668693          	addi	a3,a3,-762 # 8000 <_entry-0x7fff8000>
    80001302:	4605                	li	a2,1
    80001304:	067e                	slli	a2,a2,0x1f
    80001306:	85b2                	mv	a1,a2
    80001308:	8526                	mv	a0,s1
    8000130a:	f6dff0ef          	jal	80001276 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000130e:	46c5                	li	a3,17
    80001310:	06ee                	slli	a3,a3,0x1b
    80001312:	4719                	li	a4,6
    80001314:	412686b3          	sub	a3,a3,s2
    80001318:	864a                	mv	a2,s2
    8000131a:	85ca                	mv	a1,s2
    8000131c:	8526                	mv	a0,s1
    8000131e:	f59ff0ef          	jal	80001276 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001322:	4729                	li	a4,10
    80001324:	6685                	lui	a3,0x1
    80001326:	00006617          	auipc	a2,0x6
    8000132a:	cda60613          	addi	a2,a2,-806 # 80007000 <_trampoline>
    8000132e:	040005b7          	lui	a1,0x4000
    80001332:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001334:	05b2                	slli	a1,a1,0xc
    80001336:	8526                	mv	a0,s1
    80001338:	f3fff0ef          	jal	80001276 <kvmmap>
}
    8000133c:	8526                	mv	a0,s1
    8000133e:	60e2                	ld	ra,24(sp)
    80001340:	6442                	ld	s0,16(sp)
    80001342:	64a2                	ld	s1,8(sp)
    80001344:	6902                	ld	s2,0(sp)
    80001346:	6105                	addi	sp,sp,32
    80001348:	8082                	ret

000000008000134a <kvminit>:
{
    8000134a:	1141                	addi	sp,sp,-16
    8000134c:	e406                	sd	ra,8(sp)
    8000134e:	e022                	sd	s0,0(sp)
    80001350:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001352:	f4dff0ef          	jal	8000129e <kvmmake>
    80001356:	00008797          	auipc	a5,0x8
    8000135a:	98a7b923          	sd	a0,-1646(a5) # 80008ce8 <kernel_pagetable>
}
    8000135e:	60a2                	ld	ra,8(sp)
    80001360:	6402                	ld	s0,0(sp)
    80001362:	0141                	addi	sp,sp,16
    80001364:	8082                	ret

0000000080001366 <uvmcreate>:

pagetable_t
uvmcreate()
{
    80001366:	1101                	addi	sp,sp,-32
    80001368:	ec06                	sd	ra,24(sp)
    8000136a:	e822                	sd	s0,16(sp)
    8000136c:	e426                	sd	s1,8(sp)
    8000136e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001370:	863ff0ef          	jal	80000bd2 <kalloc>
    80001374:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001376:	c509                	beqz	a0,80001380 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	ad1ff0ef          	jal	80000e4c <memset>
  return pagetable;
}
    80001380:	8526                	mv	a0,s1
    80001382:	60e2                	ld	ra,24(sp)
    80001384:	6442                	ld	s0,16(sp)
    80001386:	64a2                	ld	s1,8(sp)
    80001388:	6105                	addi	sp,sp,32
    8000138a:	8082                	ret

000000008000138c <uvmunmap>:

void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000138c:	715d                	addi	sp,sp,-80
    8000138e:	e486                	sd	ra,72(sp)
    80001390:	e0a2                	sd	s0,64(sp)
    80001392:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001394:	03459793          	slli	a5,a1,0x34
    80001398:	e39d                	bnez	a5,800013be <uvmunmap+0x32>
    8000139a:	f84a                	sd	s2,48(sp)
    8000139c:	f44e                	sd	s3,40(sp)
    8000139e:	f052                	sd	s4,32(sp)
    800013a0:	ec56                	sd	s5,24(sp)
    800013a2:	e85a                	sd	s6,16(sp)
    800013a4:	e45e                	sd	s7,8(sp)
    800013a6:	8a2a                	mv	s4,a0
    800013a8:	892e                	mv	s2,a1
    800013aa:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages * PGSIZE; a += PGSIZE){
    800013ac:	0632                	slli	a2,a2,0xc
    800013ae:	00b609b3          	add	s3,a2,a1
    if((*pte & PTE_V) == 0){
      *pte = 0;
      continue;
    }
      
    if(PTE_FLAGS(*pte) == PTE_V)
    800013b2:	4b85                	li	s7,1
  for(a = va; a < va + npages * PGSIZE; a += PGSIZE){
    800013b4:	6a85                	lui	s5,0x1
    800013b6:	0735f763          	bgeu	a1,s3,80001424 <uvmunmap+0x98>
    800013ba:	fc26                	sd	s1,56(sp)
    800013bc:	a825                	j	800013f4 <uvmunmap+0x68>
    800013be:	fc26                	sd	s1,56(sp)
    800013c0:	f84a                	sd	s2,48(sp)
    800013c2:	f44e                	sd	s3,40(sp)
    800013c4:	f052                	sd	s4,32(sp)
    800013c6:	ec56                	sd	s5,24(sp)
    800013c8:	e85a                	sd	s6,16(sp)
    800013ca:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800013cc:	00007517          	auipc	a0,0x7
    800013d0:	d7c50513          	addi	a0,a0,-644 # 80008148 <etext+0x148>
    800013d4:	c0cff0ef          	jal	800007e0 <panic>
      *pte = 0;
    800013d8:	00053023          	sd	zero,0(a0)
      continue;
    800013dc:	a809                	j	800013ee <uvmunmap+0x62>
      panic("uvmunmap: not a leaf");
    800013de:	00007517          	auipc	a0,0x7
    800013e2:	d8250513          	addi	a0,a0,-638 # 80008160 <etext+0x160>
    800013e6:	bfaff0ef          	jal	800007e0 <panic>
    
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa); 
    }
    *pte = 0;
    800013ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages * PGSIZE; a += PGSIZE){
    800013ee:	9956                	add	s2,s2,s5
    800013f0:	03397963          	bgeu	s2,s3,80001422 <uvmunmap+0x96>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013f4:	4601                	li	a2,0
    800013f6:	85ca                	mv	a1,s2
    800013f8:	8552                	mv	a0,s4
    800013fa:	cf7ff0ef          	jal	800010f0 <walk>
    800013fe:	84aa                	mv	s1,a0
    80001400:	d57d                	beqz	a0,800013ee <uvmunmap+0x62>
    if((*pte & PTE_V) == 0){
    80001402:	611c                	ld	a5,0(a0)
    80001404:	0017f713          	andi	a4,a5,1
    80001408:	db61                	beqz	a4,800013d8 <uvmunmap+0x4c>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000140a:	3ff7f713          	andi	a4,a5,1023
    8000140e:	fd7708e3          	beq	a4,s7,800013de <uvmunmap+0x52>
    if(do_free){
    80001412:	fc0b0ce3          	beqz	s6,800013ea <uvmunmap+0x5e>
      uint64 pa = PTE2PA(*pte);
    80001416:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa); 
    80001418:	00c79513          	slli	a0,a5,0xc
    8000141c:	e00ff0ef          	jal	80000a1c <kfree>
    80001420:	b7e9                	j	800013ea <uvmunmap+0x5e>
    80001422:	74e2                	ld	s1,56(sp)
    80001424:	7942                	ld	s2,48(sp)
    80001426:	79a2                	ld	s3,40(sp)
    80001428:	7a02                	ld	s4,32(sp)
    8000142a:	6ae2                	ld	s5,24(sp)
    8000142c:	6b42                	ld	s6,16(sp)
    8000142e:	6ba2                	ld	s7,8(sp)
  }
}
    80001430:	60a6                	ld	ra,72(sp)
    80001432:	6406                	ld	s0,64(sp)
    80001434:	6161                	addi	sp,sp,80
    80001436:	8082                	ret

0000000080001438 <uvmdealloc>:
  return newsz;
}

uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001438:	1101                	addi	sp,sp,-32
    8000143a:	ec06                	sd	ra,24(sp)
    8000143c:	e822                	sd	s0,16(sp)
    8000143e:	e426                	sd	s1,8(sp)
    80001440:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001442:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001444:	00b67d63          	bgeu	a2,a1,8000145e <uvmdealloc+0x26>
    80001448:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000144a:	6785                	lui	a5,0x1
    8000144c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000144e:	00f60733          	add	a4,a2,a5
    80001452:	76fd                	lui	a3,0xfffff
    80001454:	8f75                	and	a4,a4,a3
    80001456:	97ae                	add	a5,a5,a1
    80001458:	8ff5                	and	a5,a5,a3
    8000145a:	00f76863          	bltu	a4,a5,8000146a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000145e:	8526                	mv	a0,s1
    80001460:	60e2                	ld	ra,24(sp)
    80001462:	6442                	ld	s0,16(sp)
    80001464:	64a2                	ld	s1,8(sp)
    80001466:	6105                	addi	sp,sp,32
    80001468:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000146a:	8f99                	sub	a5,a5,a4
    8000146c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000146e:	4685                	li	a3,1
    80001470:	0007861b          	sext.w	a2,a5
    80001474:	85ba                	mv	a1,a4
    80001476:	f17ff0ef          	jal	8000138c <uvmunmap>
    8000147a:	b7d5                	j	8000145e <uvmdealloc+0x26>

000000008000147c <uvmalloc>:
  if(newsz < oldsz)
    8000147c:	08b66f63          	bltu	a2,a1,8000151a <uvmalloc+0x9e>
{
    80001480:	7139                	addi	sp,sp,-64
    80001482:	fc06                	sd	ra,56(sp)
    80001484:	f822                	sd	s0,48(sp)
    80001486:	ec4e                	sd	s3,24(sp)
    80001488:	e852                	sd	s4,16(sp)
    8000148a:	e456                	sd	s5,8(sp)
    8000148c:	0080                	addi	s0,sp,64
    8000148e:	8aaa                	mv	s5,a0
    80001490:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001492:	6785                	lui	a5,0x1
    80001494:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001496:	95be                	add	a1,a1,a5
    80001498:	77fd                	lui	a5,0xfffff
    8000149a:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000149e:	08c9f063          	bgeu	s3,a2,8000151e <uvmalloc+0xa2>
    800014a2:	f426                	sd	s1,40(sp)
    800014a4:	f04a                	sd	s2,32(sp)
    800014a6:	e05a                	sd	s6,0(sp)
    800014a8:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014aa:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800014ae:	f24ff0ef          	jal	80000bd2 <kalloc>
    800014b2:	84aa                	mv	s1,a0
    if(mem == 0){
    800014b4:	c515                	beqz	a0,800014e0 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    800014b6:	6605                	lui	a2,0x1
    800014b8:	4581                	li	a1,0
    800014ba:	993ff0ef          	jal	80000e4c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014be:	875a                	mv	a4,s6
    800014c0:	86a6                	mv	a3,s1
    800014c2:	6605                	lui	a2,0x1
    800014c4:	85ca                	mv	a1,s2
    800014c6:	8556                	mv	a0,s5
    800014c8:	cffff0ef          	jal	800011c6 <mappages>
    800014cc:	e915                	bnez	a0,80001500 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014ce:	6785                	lui	a5,0x1
    800014d0:	993e                	add	s2,s2,a5
    800014d2:	fd496ee3          	bltu	s2,s4,800014ae <uvmalloc+0x32>
  return newsz;
    800014d6:	8552                	mv	a0,s4
    800014d8:	74a2                	ld	s1,40(sp)
    800014da:	7902                	ld	s2,32(sp)
    800014dc:	6b02                	ld	s6,0(sp)
    800014de:	a811                	j	800014f2 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800014e0:	864e                	mv	a2,s3
    800014e2:	85ca                	mv	a1,s2
    800014e4:	8556                	mv	a0,s5
    800014e6:	f53ff0ef          	jal	80001438 <uvmdealloc>
      return 0;
    800014ea:	4501                	li	a0,0
    800014ec:	74a2                	ld	s1,40(sp)
    800014ee:	7902                	ld	s2,32(sp)
    800014f0:	6b02                	ld	s6,0(sp)
}
    800014f2:	70e2                	ld	ra,56(sp)
    800014f4:	7442                	ld	s0,48(sp)
    800014f6:	69e2                	ld	s3,24(sp)
    800014f8:	6a42                	ld	s4,16(sp)
    800014fa:	6aa2                	ld	s5,8(sp)
    800014fc:	6121                	addi	sp,sp,64
    800014fe:	8082                	ret
      kfree(mem);
    80001500:	8526                	mv	a0,s1
    80001502:	d1aff0ef          	jal	80000a1c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001506:	864e                	mv	a2,s3
    80001508:	85ca                	mv	a1,s2
    8000150a:	8556                	mv	a0,s5
    8000150c:	f2dff0ef          	jal	80001438 <uvmdealloc>
      return 0;
    80001510:	4501                	li	a0,0
    80001512:	74a2                	ld	s1,40(sp)
    80001514:	7902                	ld	s2,32(sp)
    80001516:	6b02                	ld	s6,0(sp)
    80001518:	bfe9                	j	800014f2 <uvmalloc+0x76>
    return oldsz;
    8000151a:	852e                	mv	a0,a1
}
    8000151c:	8082                	ret
  return newsz;
    8000151e:	8532                	mv	a0,a2
    80001520:	bfc9                	j	800014f2 <uvmalloc+0x76>

0000000080001522 <freewalk>:

void
freewalk(pagetable_t pagetable)
{
    80001522:	7179                	addi	sp,sp,-48
    80001524:	f406                	sd	ra,40(sp)
    80001526:	f022                	sd	s0,32(sp)
    80001528:	ec26                	sd	s1,24(sp)
    8000152a:	e84a                	sd	s2,16(sp)
    8000152c:	e44e                	sd	s3,8(sp)
    8000152e:	e052                	sd	s4,0(sp)
    80001530:	1800                	addi	s0,sp,48
    80001532:	8a2a                	mv	s4,a0
  for(int i = 0; i < 512; i++){
    80001534:	84aa                	mv	s1,a0
    80001536:	6905                	lui	s2,0x1
    80001538:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000153a:	4985                	li	s3,1
    8000153c:	a819                	j	80001552 <freewalk+0x30>
      uint64 child = PTE2PA(pte);
    8000153e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001540:	00c79513          	slli	a0,a5,0xc
    80001544:	fdfff0ef          	jal	80001522 <freewalk>
      pagetable[i] = 0;
    80001548:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000154c:	04a1                	addi	s1,s1,8
    8000154e:	01248f63          	beq	s1,s2,8000156c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001552:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001554:	00f7f713          	andi	a4,a5,15
    80001558:	ff3703e3          	beq	a4,s3,8000153e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000155c:	8b85                	andi	a5,a5,1
    8000155e:	d7fd                	beqz	a5,8000154c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001560:	00007517          	auipc	a0,0x7
    80001564:	c1850513          	addi	a0,a0,-1000 # 80008178 <etext+0x178>
    80001568:	a78ff0ef          	jal	800007e0 <panic>
    }
  }
  kfree((void*)pagetable);
    8000156c:	8552                	mv	a0,s4
    8000156e:	caeff0ef          	jal	80000a1c <kfree>
}
    80001572:	70a2                	ld	ra,40(sp)
    80001574:	7402                	ld	s0,32(sp)
    80001576:	64e2                	ld	s1,24(sp)
    80001578:	6942                	ld	s2,16(sp)
    8000157a:	69a2                	ld	s3,8(sp)
    8000157c:	6a02                	ld	s4,0(sp)
    8000157e:	6145                	addi	sp,sp,48
    80001580:	8082                	ret

0000000080001582 <uvmfree>:

void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001582:	1101                	addi	sp,sp,-32
    80001584:	ec06                	sd	ra,24(sp)
    80001586:	e822                	sd	s0,16(sp)
    80001588:	e426                	sd	s1,8(sp)
    8000158a:	1000                	addi	s0,sp,32
    8000158c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000158e:	e989                	bnez	a1,800015a0 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001590:	8526                	mv	a0,s1
    80001592:	f91ff0ef          	jal	80001522 <freewalk>
}
    80001596:	60e2                	ld	ra,24(sp)
    80001598:	6442                	ld	s0,16(sp)
    8000159a:	64a2                	ld	s1,8(sp)
    8000159c:	6105                	addi	sp,sp,32
    8000159e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800015a0:	6785                	lui	a5,0x1
    800015a2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015a4:	95be                	add	a1,a1,a5
    800015a6:	4685                	li	a3,1
    800015a8:	00c5d613          	srli	a2,a1,0xc
    800015ac:	4581                	li	a1,0
    800015ae:	ddfff0ef          	jal	8000138c <uvmunmap>
    800015b2:	bff9                	j	80001590 <uvmfree+0xe>

00000000800015b4 <uvmcopy>:
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;

  for(i = 0; i < sz; i += PGSIZE){
    800015b4:	ca41                	beqz	a2,80001644 <uvmcopy+0x90>
{
    800015b6:	7139                	addi	sp,sp,-64
    800015b8:	fc06                	sd	ra,56(sp)
    800015ba:	f822                	sd	s0,48(sp)
    800015bc:	f426                	sd	s1,40(sp)
    800015be:	f04a                	sd	s2,32(sp)
    800015c0:	ec4e                	sd	s3,24(sp)
    800015c2:	e852                	sd	s4,16(sp)
    800015c4:	e456                	sd	s5,8(sp)
    800015c6:	0080                	addi	s0,sp,64
    800015c8:	8a2a                	mv	s4,a0
    800015ca:	8aae                	mv	s5,a1
    800015cc:	89b2                	mv	s3,a2
  for(i = 0; i < sz; i += PGSIZE){
    800015ce:	4481                	li	s1,0
    800015d0:	a015                	j	800015f4 <uvmcopy+0x40>
    if((*pte & PTE_W) || (*pte & PTE_COW)) {
      *pte &= ~PTE_W;   // Khóa quyền ghi của cha
      *pte |= PTE_COW;  // Bật cờ đánh dấu COW
    }
    
    flags = PTE_FLAGS(*pte);
    800015d2:	6118                	ld	a4,0(a0)
    
    // Ánh xạ thẳng địa chỉ vật lý pa sang tiến trình con
    if(mappages(new, i, PGSIZE, pa, flags) != 0)
    800015d4:	3ff77713          	andi	a4,a4,1023
    800015d8:	86ca                	mv	a3,s2
    800015da:	6605                	lui	a2,0x1
    800015dc:	85a6                	mv	a1,s1
    800015de:	8556                	mv	a0,s5
    800015e0:	be7ff0ef          	jal	800011c6 <mappages>
    800015e4:	ed0d                	bnez	a0,8000161e <uvmcopy+0x6a>
      goto err;
      
    // Tăng bộ đếm tham chiếu lên an toàn
    kref_incr(pa);
    800015e6:	854a                	mv	a0,s2
    800015e8:	e60ff0ef          	jal	80000c48 <kref_incr>
  for(i = 0; i < sz; i += PGSIZE){
    800015ec:	6785                	lui	a5,0x1
    800015ee:	94be                	add	s1,s1,a5
    800015f0:	0534f063          	bgeu	s1,s3,80001630 <uvmcopy+0x7c>
    if((pte = walk(old, i, 0)) == 0)
    800015f4:	4601                	li	a2,0
    800015f6:	85a6                	mv	a1,s1
    800015f8:	8552                	mv	a0,s4
    800015fa:	af7ff0ef          	jal	800010f0 <walk>
    800015fe:	d57d                	beqz	a0,800015ec <uvmcopy+0x38>
    if((*pte & PTE_V) == 0)
    80001600:	611c                	ld	a5,0(a0)
    80001602:	0017f713          	andi	a4,a5,1
    80001606:	d37d                	beqz	a4,800015ec <uvmcopy+0x38>
    pa = PTE2PA(*pte);
    80001608:	00a7d913          	srli	s2,a5,0xa
    8000160c:	0932                	slli	s2,s2,0xc
    if((*pte & PTE_W) || (*pte & PTE_COW)) {
    8000160e:	1047f713          	andi	a4,a5,260
    80001612:	d361                	beqz	a4,800015d2 <uvmcopy+0x1e>
      *pte &= ~PTE_W;   // Khóa quyền ghi của cha
    80001614:	9bed                	andi	a5,a5,-5
      *pte |= PTE_COW;  // Bật cờ đánh dấu COW
    80001616:	1007e793          	ori	a5,a5,256
    8000161a:	e11c                	sd	a5,0(a0)
    8000161c:	bf5d                	j	800015d2 <uvmcopy+0x1e>
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000161e:	4685                	li	a3,1
    80001620:	00c4d613          	srli	a2,s1,0xc
    80001624:	4581                	li	a1,0
    80001626:	8556                	mv	a0,s5
    80001628:	d65ff0ef          	jal	8000138c <uvmunmap>
  return -1;
    8000162c:	557d                	li	a0,-1
    8000162e:	a011                	j	80001632 <uvmcopy+0x7e>
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	70e2                	ld	ra,56(sp)
    80001634:	7442                	ld	s0,48(sp)
    80001636:	74a2                	ld	s1,40(sp)
    80001638:	7902                	ld	s2,32(sp)
    8000163a:	69e2                	ld	s3,24(sp)
    8000163c:	6a42                	ld	s4,16(sp)
    8000163e:	6aa2                	ld	s5,8(sp)
    80001640:	6121                	addi	sp,sp,64
    80001642:	8082                	ret
  return 0;
    80001644:	4501                	li	a0,0
}
    80001646:	8082                	ret

0000000080001648 <uvmclear>:
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001648:	1141                	addi	sp,sp,-16
    8000164a:	e406                	sd	ra,8(sp)
    8000164c:	e022                	sd	s0,0(sp)
    8000164e:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001650:	4601                	li	a2,0
    80001652:	a9fff0ef          	jal	800010f0 <walk>
  if(pte == 0) panic("uvmclear");
    80001656:	c901                	beqz	a0,80001666 <uvmclear+0x1e>
  *pte &= ~PTE_U;
    80001658:	611c                	ld	a5,0(a0)
    8000165a:	9bbd                	andi	a5,a5,-17
    8000165c:	e11c                	sd	a5,0(a0)
}
    8000165e:	60a2                	ld	ra,8(sp)
    80001660:	6402                	ld	s0,0(sp)
    80001662:	0141                	addi	sp,sp,16
    80001664:	8082                	ret
  if(pte == 0) panic("uvmclear");
    80001666:	00007517          	auipc	a0,0x7
    8000166a:	b2250513          	addi	a0,a0,-1246 # 80008188 <etext+0x188>
    8000166e:	972ff0ef          	jal	800007e0 <panic>

0000000080001672 <copyinstr>:
int
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;
  while(got_null == 0 && max > 0){
    80001672:	c6dd                	beqz	a3,80001720 <copyinstr+0xae>
{
    80001674:	715d                	addi	sp,sp,-80
    80001676:	e486                	sd	ra,72(sp)
    80001678:	e0a2                	sd	s0,64(sp)
    8000167a:	fc26                	sd	s1,56(sp)
    8000167c:	f84a                	sd	s2,48(sp)
    8000167e:	f44e                	sd	s3,40(sp)
    80001680:	f052                	sd	s4,32(sp)
    80001682:	ec56                	sd	s5,24(sp)
    80001684:	e85a                	sd	s6,16(sp)
    80001686:	e45e                	sd	s7,8(sp)
    80001688:	0880                	addi	s0,sp,80
    8000168a:	8a2a                	mv	s4,a0
    8000168c:	8b2e                	mv	s6,a1
    8000168e:	8bb2                	mv	s7,a2
    80001690:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001692:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0) return -1;
    n = PGSIZE - (srcva - va0);
    80001694:	6985                	lui	s3,0x1
    80001696:	a825                	j	800016ce <copyinstr+0x5c>
    if(n > max) n = max;
    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){ *dst = '\0'; got_null = 1; break; }
    80001698:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    8000169c:	4785                	li	a5,1
      else { *dst = *p; }
      --n; --max; p++; dst++;
    }
    srcva = va0 + PGSIZE;
  }
  return got_null ? 0 : -1;
    8000169e:	37fd                	addiw	a5,a5,-1
    800016a0:	0007851b          	sext.w	a0,a5
}
    800016a4:	60a6                	ld	ra,72(sp)
    800016a6:	6406                	ld	s0,64(sp)
    800016a8:	74e2                	ld	s1,56(sp)
    800016aa:	7942                	ld	s2,48(sp)
    800016ac:	79a2                	ld	s3,40(sp)
    800016ae:	7a02                	ld	s4,32(sp)
    800016b0:	6ae2                	ld	s5,24(sp)
    800016b2:	6b42                	ld	s6,16(sp)
    800016b4:	6ba2                	ld	s7,8(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret
    800016ba:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016be:	9742                	add	a4,a4,a6
      --n; --max; p++; dst++;
    800016c0:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800016c4:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800016c8:	04e58463          	beq	a1,a4,80001710 <copyinstr+0x9e>
{
    800016cc:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800016ce:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800016d2:	85a6                	mv	a1,s1
    800016d4:	8552                	mv	a0,s4
    800016d6:	ab5ff0ef          	jal	8000118a <walkaddr>
    if(pa0 == 0) return -1;
    800016da:	cd0d                	beqz	a0,80001714 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800016dc:	417486b3          	sub	a3,s1,s7
    800016e0:	96ce                	add	a3,a3,s3
    if(n > max) n = max;
    800016e2:	00d97363          	bgeu	s2,a3,800016e8 <copyinstr+0x76>
    800016e6:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800016e8:	955e                	add	a0,a0,s7
    800016ea:	8d05                	sub	a0,a0,s1
    while(n > 0){
    800016ec:	c695                	beqz	a3,80001718 <copyinstr+0xa6>
    800016ee:	87da                	mv	a5,s6
    800016f0:	885a                	mv	a6,s6
      if(*p == '\0'){ *dst = '\0'; got_null = 1; break; }
    800016f2:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800016f6:	96da                	add	a3,a3,s6
    800016f8:	85be                	mv	a1,a5
      if(*p == '\0'){ *dst = '\0'; got_null = 1; break; }
    800016fa:	00f60733          	add	a4,a2,a5
    800016fe:	00074703          	lbu	a4,0(a4)
    80001702:	db59                	beqz	a4,80001698 <copyinstr+0x26>
      else { *dst = *p; }
    80001704:	00e78023          	sb	a4,0(a5)
      --n; --max; p++; dst++;
    80001708:	0785                	addi	a5,a5,1
    while(n > 0){
    8000170a:	fed797e3          	bne	a5,a3,800016f8 <copyinstr+0x86>
    8000170e:	b775                	j	800016ba <copyinstr+0x48>
    80001710:	4781                	li	a5,0
    80001712:	b771                	j	8000169e <copyinstr+0x2c>
    if(pa0 == 0) return -1;
    80001714:	557d                	li	a0,-1
    80001716:	b779                	j	800016a4 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001718:	6b85                	lui	s7,0x1
    8000171a:	9ba6                	add	s7,s7,s1
    8000171c:	87da                	mv	a5,s6
    8000171e:	b77d                	j	800016cc <copyinstr+0x5a>
  int got_null = 0;
    80001720:	4781                	li	a5,0
  return got_null ? 0 : -1;
    80001722:	37fd                	addiw	a5,a5,-1
    80001724:	0007851b          	sext.w	a0,a5
}
    80001728:	8082                	ret

000000008000172a <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000172a:	1141                	addi	sp,sp,-16
    8000172c:	e406                	sd	ra,8(sp)
    8000172e:	e022                	sd	s0,0(sp)
    80001730:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001732:	4601                	li	a2,0
    80001734:	9bdff0ef          	jal	800010f0 <walk>
  return (pte != 0 && (*pte & PTE_V));
    80001738:	c519                	beqz	a0,80001746 <ismapped+0x1c>
    8000173a:	6108                	ld	a0,0(a0)
    8000173c:	8905                	andi	a0,a0,1
}
    8000173e:	60a2                	ld	ra,8(sp)
    80001740:	6402                	ld	s0,0(sp)
    80001742:	0141                	addi	sp,sp,16
    80001744:	8082                	ret
  return (pte != 0 && (*pte & PTE_V));
    80001746:	4501                	li	a0,0
    80001748:	bfdd                	j	8000173e <ismapped+0x14>

000000008000174a <vmfault>:
{
    8000174a:	7179                	addi	sp,sp,-48
    8000174c:	f406                	sd	ra,40(sp)
    8000174e:	f022                	sd	s0,32(sp)
    80001750:	ec26                	sd	s1,24(sp)
    80001752:	e44e                	sd	s3,8(sp)
    80001754:	1800                	addi	s0,sp,48
    80001756:	89aa                	mv	s3,a0
    80001758:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000175a:	502000ef          	jal	80001c5c <myproc>
  if (va >= p->sz) return 0;
    8000175e:	693c                	ld	a5,80(a0)
    80001760:	00f4ea63          	bltu	s1,a5,80001774 <vmfault+0x2a>
    80001764:	4981                	li	s3,0
}
    80001766:	854e                	mv	a0,s3
    80001768:	70a2                	ld	ra,40(sp)
    8000176a:	7402                	ld	s0,32(sp)
    8000176c:	64e2                	ld	s1,24(sp)
    8000176e:	69a2                	ld	s3,8(sp)
    80001770:	6145                	addi	sp,sp,48
    80001772:	8082                	ret
    80001774:	e84a                	sd	s2,16(sp)
    80001776:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001778:	77fd                	lui	a5,0xfffff
    8000177a:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) return 0;
    8000177c:	85a6                	mv	a1,s1
    8000177e:	854e                	mv	a0,s3
    80001780:	fabff0ef          	jal	8000172a <ismapped>
    80001784:	4981                	li	s3,0
    80001786:	c119                	beqz	a0,8000178c <vmfault+0x42>
    80001788:	6942                	ld	s2,16(sp)
    8000178a:	bff1                	j	80001766 <vmfault+0x1c>
    8000178c:	e052                	sd	s4,0(sp)
  mem = (uint64) kalloc();
    8000178e:	c44ff0ef          	jal	80000bd2 <kalloc>
    80001792:	8a2a                	mv	s4,a0
  if(mem == 0) return 0;
    80001794:	c90d                	beqz	a0,800017c6 <vmfault+0x7c>
  mem = (uint64) kalloc();
    80001796:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001798:	6605                	lui	a2,0x1
    8000179a:	4581                	li	a1,0
    8000179c:	eb0ff0ef          	jal	80000e4c <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800017a0:	4759                	li	a4,22
    800017a2:	86d2                	mv	a3,s4
    800017a4:	6605                	lui	a2,0x1
    800017a6:	85a6                	mv	a1,s1
    800017a8:	05893503          	ld	a0,88(s2)
    800017ac:	a1bff0ef          	jal	800011c6 <mappages>
    800017b0:	e501                	bnez	a0,800017b8 <vmfault+0x6e>
    800017b2:	6942                	ld	s2,16(sp)
    800017b4:	6a02                	ld	s4,0(sp)
    800017b6:	bf45                	j	80001766 <vmfault+0x1c>
    kfree((void *)mem);
    800017b8:	8552                	mv	a0,s4
    800017ba:	a62ff0ef          	jal	80000a1c <kfree>
    return 0;
    800017be:	4981                	li	s3,0
    800017c0:	6942                	ld	s2,16(sp)
    800017c2:	6a02                	ld	s4,0(sp)
    800017c4:	b74d                	j	80001766 <vmfault+0x1c>
    800017c6:	6942                	ld	s2,16(sp)
    800017c8:	6a02                	ld	s4,0(sp)
    800017ca:	bf71                	j	80001766 <vmfault+0x1c>

00000000800017cc <copyout>:
  while(len > 0){
    800017cc:	c2cd                	beqz	a3,8000186e <copyout+0xa2>
{
    800017ce:	711d                	addi	sp,sp,-96
    800017d0:	ec86                	sd	ra,88(sp)
    800017d2:	e8a2                	sd	s0,80(sp)
    800017d4:	e4a6                	sd	s1,72(sp)
    800017d6:	f852                	sd	s4,48(sp)
    800017d8:	f05a                	sd	s6,32(sp)
    800017da:	ec5e                	sd	s7,24(sp)
    800017dc:	e862                	sd	s8,16(sp)
    800017de:	1080                	addi	s0,sp,96
    800017e0:	8c2a                	mv	s8,a0
    800017e2:	8b2e                	mv	s6,a1
    800017e4:	8bb2                	mv	s7,a2
    800017e6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800017e8:	74fd                	lui	s1,0xfffff
    800017ea:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA) return -1;
    800017ec:	57fd                	li	a5,-1
    800017ee:	83e9                	srli	a5,a5,0x1a
    800017f0:	0897e163          	bltu	a5,s1,80001872 <copyout+0xa6>
    800017f4:	e0ca                	sd	s2,64(sp)
    800017f6:	fc4e                	sd	s3,56(sp)
    800017f8:	f456                	sd	s5,40(sp)
    800017fa:	e466                	sd	s9,8(sp)
    800017fc:	e06a                	sd	s10,0(sp)
    800017fe:	6d05                	lui	s10,0x1
    80001800:	8cbe                	mv	s9,a5
    80001802:	a015                	j	80001826 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001804:	409b0533          	sub	a0,s6,s1
    80001808:	0009861b          	sext.w	a2,s3
    8000180c:	85de                	mv	a1,s7
    8000180e:	954a                	add	a0,a0,s2
    80001810:	e98ff0ef          	jal	80000ea8 <memmove>
    len -= n; src += n; dstva = va0 + PGSIZE;
    80001814:	413a0a33          	sub	s4,s4,s3
    80001818:	9bce                	add	s7,s7,s3
  while(len > 0){
    8000181a:	040a0363          	beqz	s4,80001860 <copyout+0x94>
    if(va0 >= MAXVA) return -1;
    8000181e:	055cec63          	bltu	s9,s5,80001876 <copyout+0xaa>
    80001822:	84d6                	mv	s1,s5
    80001824:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001826:	85a6                	mv	a1,s1
    80001828:	8562                	mv	a0,s8
    8000182a:	961ff0ef          	jal	8000118a <walkaddr>
    8000182e:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001830:	e901                	bnez	a0,80001840 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) return -1;
    80001832:	4601                	li	a2,0
    80001834:	85a6                	mv	a1,s1
    80001836:	8562                	mv	a0,s8
    80001838:	f13ff0ef          	jal	8000174a <vmfault>
    8000183c:	892a                	mv	s2,a0
    8000183e:	c139                	beqz	a0,80001884 <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001840:	4601                	li	a2,0
    80001842:	85a6                	mv	a1,s1
    80001844:	8562                	mv	a0,s8
    80001846:	8abff0ef          	jal	800010f0 <walk>
    if((*pte & PTE_W) == 0) return -1;
    8000184a:	611c                	ld	a5,0(a0)
    8000184c:	8b91                	andi	a5,a5,4
    8000184e:	c3b1                	beqz	a5,80001892 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001850:	01a48ab3          	add	s5,s1,s10
    80001854:	416a89b3          	sub	s3,s5,s6
    if(n > len) n = len;
    80001858:	fb3a76e3          	bgeu	s4,s3,80001804 <copyout+0x38>
    8000185c:	89d2                	mv	s3,s4
    8000185e:	b75d                	j	80001804 <copyout+0x38>
  return 0;
    80001860:	4501                	li	a0,0
    80001862:	6906                	ld	s2,64(sp)
    80001864:	79e2                	ld	s3,56(sp)
    80001866:	7aa2                	ld	s5,40(sp)
    80001868:	6ca2                	ld	s9,8(sp)
    8000186a:	6d02                	ld	s10,0(sp)
    8000186c:	a80d                	j	8000189e <copyout+0xd2>
    8000186e:	4501                	li	a0,0
}
    80001870:	8082                	ret
    if(va0 >= MAXVA) return -1;
    80001872:	557d                	li	a0,-1
    80001874:	a02d                	j	8000189e <copyout+0xd2>
    80001876:	557d                	li	a0,-1
    80001878:	6906                	ld	s2,64(sp)
    8000187a:	79e2                	ld	s3,56(sp)
    8000187c:	7aa2                	ld	s5,40(sp)
    8000187e:	6ca2                	ld	s9,8(sp)
    80001880:	6d02                	ld	s10,0(sp)
    80001882:	a831                	j	8000189e <copyout+0xd2>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) return -1;
    80001884:	557d                	li	a0,-1
    80001886:	6906                	ld	s2,64(sp)
    80001888:	79e2                	ld	s3,56(sp)
    8000188a:	7aa2                	ld	s5,40(sp)
    8000188c:	6ca2                	ld	s9,8(sp)
    8000188e:	6d02                	ld	s10,0(sp)
    80001890:	a039                	j	8000189e <copyout+0xd2>
    if((*pte & PTE_W) == 0) return -1;
    80001892:	557d                	li	a0,-1
    80001894:	6906                	ld	s2,64(sp)
    80001896:	79e2                	ld	s3,56(sp)
    80001898:	7aa2                	ld	s5,40(sp)
    8000189a:	6ca2                	ld	s9,8(sp)
    8000189c:	6d02                	ld	s10,0(sp)
}
    8000189e:	60e6                	ld	ra,88(sp)
    800018a0:	6446                	ld	s0,80(sp)
    800018a2:	64a6                	ld	s1,72(sp)
    800018a4:	7a42                	ld	s4,48(sp)
    800018a6:	7b02                	ld	s6,32(sp)
    800018a8:	6be2                	ld	s7,24(sp)
    800018aa:	6c42                	ld	s8,16(sp)
    800018ac:	6125                	addi	sp,sp,96
    800018ae:	8082                	ret

00000000800018b0 <copyin>:
  while(len > 0){
    800018b0:	c6c9                	beqz	a3,8000193a <copyin+0x8a>
{
    800018b2:	715d                	addi	sp,sp,-80
    800018b4:	e486                	sd	ra,72(sp)
    800018b6:	e0a2                	sd	s0,64(sp)
    800018b8:	fc26                	sd	s1,56(sp)
    800018ba:	f84a                	sd	s2,48(sp)
    800018bc:	f44e                	sd	s3,40(sp)
    800018be:	f052                	sd	s4,32(sp)
    800018c0:	ec56                	sd	s5,24(sp)
    800018c2:	e85a                	sd	s6,16(sp)
    800018c4:	e45e                	sd	s7,8(sp)
    800018c6:	e062                	sd	s8,0(sp)
    800018c8:	0880                	addi	s0,sp,80
    800018ca:	8baa                	mv	s7,a0
    800018cc:	8aae                	mv	s5,a1
    800018ce:	8932                	mv	s2,a2
    800018d0:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800018d2:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800018d4:	6b05                	lui	s6,0x1
    800018d6:	a035                	j	80001902 <copyin+0x52>
    800018d8:	412984b3          	sub	s1,s3,s2
    800018dc:	94da                	add	s1,s1,s6
    if(n > len) n = len;
    800018de:	009a7363          	bgeu	s4,s1,800018e4 <copyin+0x34>
    800018e2:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018e4:	413905b3          	sub	a1,s2,s3
    800018e8:	0004861b          	sext.w	a2,s1
    800018ec:	95aa                	add	a1,a1,a0
    800018ee:	8556                	mv	a0,s5
    800018f0:	db8ff0ef          	jal	80000ea8 <memmove>
    len -= n; dst += n; srcva = va0 + PGSIZE;
    800018f4:	409a0a33          	sub	s4,s4,s1
    800018f8:	9aa6                	add	s5,s5,s1
    800018fa:	01698933          	add	s2,s3,s6
  while(len > 0){
    800018fe:	020a0163          	beqz	s4,80001920 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001902:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001906:	85ce                	mv	a1,s3
    80001908:	855e                	mv	a0,s7
    8000190a:	881ff0ef          	jal	8000118a <walkaddr>
    if(pa0 == 0) {
    8000190e:	f569                	bnez	a0,800018d8 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) return -1;
    80001910:	4601                	li	a2,0
    80001912:	85ce                	mv	a1,s3
    80001914:	855e                	mv	a0,s7
    80001916:	e35ff0ef          	jal	8000174a <vmfault>
    8000191a:	fd5d                	bnez	a0,800018d8 <copyin+0x28>
    8000191c:	557d                	li	a0,-1
    8000191e:	a011                	j	80001922 <copyin+0x72>
  return 0;
    80001920:	4501                	li	a0,0
}
    80001922:	60a6                	ld	ra,72(sp)
    80001924:	6406                	ld	s0,64(sp)
    80001926:	74e2                	ld	s1,56(sp)
    80001928:	7942                	ld	s2,48(sp)
    8000192a:	79a2                	ld	s3,40(sp)
    8000192c:	7a02                	ld	s4,32(sp)
    8000192e:	6ae2                	ld	s5,24(sp)
    80001930:	6b42                	ld	s6,16(sp)
    80001932:	6ba2                	ld	s7,8(sp)
    80001934:	6c02                	ld	s8,0(sp)
    80001936:	6161                	addi	sp,sp,80
    80001938:	8082                	ret
  return 0;
    8000193a:	4501                	li	a0,0
}
    8000193c:	8082                	ret

000000008000193e <uvmmap>:

// --- PHẦN HÀM MỚI CHO ĐỒ ÁN ---

void
uvmmap(pagetable_t pagetable, uint64 va, uint64 pa, uint64 sz, int perm)
{
    8000193e:	1141                	addi	sp,sp,-16
    80001940:	e406                	sd	ra,8(sp)
    80001942:	e022                	sd	s0,0(sp)
    80001944:	0800                	addi	s0,sp,16
    80001946:	87b6                	mv	a5,a3
  if(mappages(pagetable, va, sz, pa, perm) != 0)
    80001948:	86b2                	mv	a3,a2
    8000194a:	863e                	mv	a2,a5
    8000194c:	87bff0ef          	jal	800011c6 <mappages>
    80001950:	e509                	bnez	a0,8000195a <uvmmap+0x1c>
    panic("uvmmap");
}
    80001952:	60a2                	ld	ra,8(sp)
    80001954:	6402                	ld	s0,0(sp)
    80001956:	0141                	addi	sp,sp,16
    80001958:	8082                	ret
    panic("uvmmap");
    8000195a:	00007517          	auipc	a0,0x7
    8000195e:	83e50513          	addi	a0,a0,-1986 # 80008198 <etext+0x198>
    80001962:	e7ffe0ef          	jal	800007e0 <panic>

0000000080001966 <proc_kpagetable>:

pagetable_t
proc_kpagetable(struct proc *p)
{
    80001966:	1101                	addi	sp,sp,-32
    80001968:	ec06                	sd	ra,24(sp)
    8000196a:	e822                	sd	s0,16(sp)
    8000196c:	e426                	sd	s1,8(sp)
    8000196e:	1000                	addi	s0,sp,32
  pagetable_t kpt = uvmcreate();
    80001970:	9f7ff0ef          	jal	80001366 <uvmcreate>
    80001974:	84aa                	mv	s1,a0
  if(kpt == 0) return 0;
    80001976:	c541                	beqz	a0,800019fe <proc_kpagetable+0x98>
    80001978:	e04a                	sd	s2,0(sp)

  // Ánh xạ thiết bị ngoại vi
  uvmmap(kpt, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000197a:	4719                	li	a4,6
    8000197c:	6685                	lui	a3,0x1
    8000197e:	10000637          	lui	a2,0x10000
    80001982:	100005b7          	lui	a1,0x10000
    80001986:	fb9ff0ef          	jal	8000193e <uvmmap>
  uvmmap(kpt, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000198a:	4719                	li	a4,6
    8000198c:	6685                	lui	a3,0x1
    8000198e:	10001637          	lui	a2,0x10001
    80001992:	100015b7          	lui	a1,0x10001
    80001996:	8526                	mv	a0,s1
    80001998:	fa7ff0ef          	jal	8000193e <uvmmap>
  
  // SỬA LỖI: Kích thước PLIC phải là 0x4000000[cite: 2]
  uvmmap(kpt, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000199c:	4719                	li	a4,6
    8000199e:	040006b7          	lui	a3,0x4000
    800019a2:	0c000637          	lui	a2,0xc000
    800019a6:	0c0005b7          	lui	a1,0xc000
    800019aa:	8526                	mv	a0,s1
    800019ac:	f93ff0ef          	jal	8000193e <uvmmap>

  // Ánh xạ Kernel Code và RAM vật lý[cite: 2]
  uvmmap(kpt, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800019b0:	00006917          	auipc	s2,0x6
    800019b4:	65090913          	addi	s2,s2,1616 # 80008000 <etext>
    800019b8:	4729                	li	a4,10
    800019ba:	80006697          	auipc	a3,0x80006
    800019be:	64668693          	addi	a3,a3,1606 # 8000 <_entry-0x7fff8000>
    800019c2:	4605                	li	a2,1
    800019c4:	067e                	slli	a2,a2,0x1f
    800019c6:	85b2                	mv	a1,a2
    800019c8:	8526                	mv	a0,s1
    800019ca:	f75ff0ef          	jal	8000193e <uvmmap>
  uvmmap(kpt, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800019ce:	46c5                	li	a3,17
    800019d0:	06ee                	slli	a3,a3,0x1b
    800019d2:	4719                	li	a4,6
    800019d4:	412686b3          	sub	a3,a3,s2
    800019d8:	864a                	mv	a2,s2
    800019da:	85ca                	mv	a1,s2
    800019dc:	8526                	mv	a0,s1
    800019de:	f61ff0ef          	jal	8000193e <uvmmap>
  
  // Ánh xạ Trampoline[cite: 2]
  uvmmap(kpt, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800019e2:	4729                	li	a4,10
    800019e4:	6685                	lui	a3,0x1
    800019e6:	00005617          	auipc	a2,0x5
    800019ea:	61a60613          	addi	a2,a2,1562 # 80007000 <_trampoline>
    800019ee:	040005b7          	lui	a1,0x4000
    800019f2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f4:	05b2                	slli	a1,a1,0xc
    800019f6:	8526                	mv	a0,s1
    800019f8:	f47ff0ef          	jal	8000193e <uvmmap>
    800019fc:	6902                	ld	s2,0(sp)

  return kpt;
}
    800019fe:	8526                	mv	a0,s1
    80001a00:	60e2                	ld	ra,24(sp)
    80001a02:	6442                	ld	s0,16(sp)
    80001a04:	64a2                	ld	s1,8(sp)
    80001a06:	6105                	addi	sp,sp,32
    80001a08:	8082                	ret

0000000080001a0a <proc_free_kpagetable>:

void
proc_free_kpagetable(pagetable_t kpt, uint64 kstack)
{
    80001a0a:	1101                	addi	sp,sp,-32
    80001a0c:	ec06                	sd	ra,24(sp)
    80001a0e:	e822                	sd	s0,16(sp)
    80001a10:	e426                	sd	s1,8(sp)
    80001a12:	e04a                	sd	s2,0(sp)
    80001a14:	1000                	addi	s0,sp,32
    80001a16:	84aa                	mv	s1,a0
  // 1. Huỷ ánh xạ Stack và giải phóng RAM vật lý của stack[cite: 2]
  uvmunmap(kpt, kstack, 1, 1); 
    80001a18:	4685                	li	a3,1
    80001a1a:	4605                	li	a2,1
    80001a1c:	971ff0ef          	jal	8000138c <uvmunmap>
  
  // 2. Huỷ ánh xạ các vùng khác nhưng KHÔNG giải phóng RAM vật lý (vì dùng chung)[cite: 2]
  uvmunmap(kpt, UART0, 1, 0);
    80001a20:	4681                	li	a3,0
    80001a22:	4605                	li	a2,1
    80001a24:	100005b7          	lui	a1,0x10000
    80001a28:	8526                	mv	a0,s1
    80001a2a:	963ff0ef          	jal	8000138c <uvmunmap>
  uvmunmap(kpt, VIRTIO0, 1, 0);
    80001a2e:	4681                	li	a3,0
    80001a30:	4605                	li	a2,1
    80001a32:	100015b7          	lui	a1,0x10001
    80001a36:	8526                	mv	a0,s1
    80001a38:	955ff0ef          	jal	8000138c <uvmunmap>
  uvmunmap(kpt, PLIC, 0x4000000/PGSIZE, 0);
    80001a3c:	4681                	li	a3,0
    80001a3e:	6611                	lui	a2,0x4
    80001a40:	0c0005b7          	lui	a1,0xc000
    80001a44:	8526                	mv	a0,s1
    80001a46:	947ff0ef          	jal	8000138c <uvmunmap>
  uvmunmap(kpt, KERNBASE, ((uint64)etext-KERNBASE)/PGSIZE, 0);
    80001a4a:	00006917          	auipc	s2,0x6
    80001a4e:	5b690913          	addi	s2,s2,1462 # 80008000 <etext>
    80001a52:	4681                	li	a3,0
    80001a54:	80006617          	auipc	a2,0x80006
    80001a58:	5ac60613          	addi	a2,a2,1452 # 8000 <_entry-0x7fff8000>
    80001a5c:	8231                	srli	a2,a2,0xc
    80001a5e:	4585                	li	a1,1
    80001a60:	05fe                	slli	a1,a1,0x1f
    80001a62:	8526                	mv	a0,s1
    80001a64:	929ff0ef          	jal	8000138c <uvmunmap>
  uvmunmap(kpt, (uint64)etext, (PHYSTOP-(uint64)etext)/PGSIZE, 0);
    80001a68:	4645                	li	a2,17
    80001a6a:	066e                	slli	a2,a2,0x1b
    80001a6c:	41260633          	sub	a2,a2,s2
    80001a70:	4681                	li	a3,0
    80001a72:	8231                	srli	a2,a2,0xc
    80001a74:	85ca                	mv	a1,s2
    80001a76:	8526                	mv	a0,s1
    80001a78:	915ff0ef          	jal	8000138c <uvmunmap>
  uvmunmap(kpt, TRAMPOLINE, 1, 0);
    80001a7c:	4681                	li	a3,0
    80001a7e:	4605                	li	a2,1
    80001a80:	040005b7          	lui	a1,0x4000
    80001a84:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a86:	05b2                	slli	a1,a1,0xc
    80001a88:	8526                	mv	a0,s1
    80001a8a:	903ff0ef          	jal	8000138c <uvmunmap>
  freewalk(pagetable);
    80001a8e:	8526                	mv	a0,s1
    80001a90:	a93ff0ef          	jal	80001522 <freewalk>

  // 3. Giải phóng các trang PTE[cite: 2]
  uvmfree(kpt, 0);
}
    80001a94:	60e2                	ld	ra,24(sp)
    80001a96:	6442                	ld	s0,16(sp)
    80001a98:	64a2                	ld	s1,8(sp)
    80001a9a:	6902                	ld	s2,0(sp)
    80001a9c:	6105                	addi	sp,sp,32
    80001a9e:	8082                	ret

0000000080001aa0 <cow_handler>:
// Hàm xử lý Copy-on-Write khi xảy ra Store Page Fault
int
cow_handler(pagetable_t pagetable, uint64 va)
{
  va = PGROUNDDOWN(va);
    80001aa0:	77fd                	lui	a5,0xfffff
    80001aa2:	8dfd                	and	a1,a1,a5
  if(va >= MAXVA) return -1;
    80001aa4:	57fd                	li	a5,-1
    80001aa6:	83e9                	srli	a5,a5,0x1a
    80001aa8:	06b7e663          	bltu	a5,a1,80001b14 <cow_handler+0x74>
{
    80001aac:	7179                	addi	sp,sp,-48
    80001aae:	f406                	sd	ra,40(sp)
    80001ab0:	f022                	sd	s0,32(sp)
    80001ab2:	e44e                	sd	s3,8(sp)
    80001ab4:	1800                	addi	s0,sp,48

  pte_t *pte = walk(pagetable, va, 0);
    80001ab6:	4601                	li	a2,0
    80001ab8:	e38ff0ef          	jal	800010f0 <walk>
    80001abc:	89aa                	mv	s3,a0
  if(pte == 0) return -1;
    80001abe:	cd29                	beqz	a0,80001b18 <cow_handler+0x78>
  
  // Kiểm tra tính hợp lệ: trang phải tồn tại (PTE_V) và phải được đánh dấu là trang chia sẻ (PTE_COW)
  if((*pte & PTE_V) == 0 || (*pte & PTE_COW) == 0)
    80001ac0:	610c                	ld	a1,0(a0)
    80001ac2:	1015f713          	andi	a4,a1,257
    80001ac6:	10100793          	li	a5,257
    80001aca:	04f71963          	bne	a4,a5,80001b1c <cow_handler+0x7c>
    80001ace:	ec26                	sd	s1,24(sp)
    80001ad0:	e84a                	sd	s2,16(sp)
    return -1;

  uint64 pa_old = PTE2PA(*pte);
    80001ad2:	81a9                	srli	a1,a1,0xa
    80001ad4:	00c59913          	slli	s2,a1,0xc
  
  // Cấp phát trang nhớ vật lý mới On-demand
  char *mem = kalloc();
    80001ad8:	8faff0ef          	jal	80000bd2 <kalloc>
    80001adc:	84aa                	mv	s1,a0
  if(mem == 0) return -1; // Trả về lỗi nếu hết bộ nhớ RAM
    80001ade:	c129                	beqz	a0,80001b20 <cow_handler+0x80>

  // Sao chép nguyên vẹn dữ liệu từ trang cũ sang trang mới
  memmove(mem, (char*)pa_old, PGSIZE);
    80001ae0:	6605                	lui	a2,0x1
    80001ae2:	85ca                	mv	a1,s2
    80001ae4:	bc4ff0ef          	jal	80000ea8 <memmove>

  // Thiết lập lại thuộc tính cờ: Thêm lại quyền ghi (PTE_W), gỡ bỏ cờ chia sẻ (PTE_COW)
  uint flags = PTE_FLAGS(*pte);
    80001ae8:	0009b783          	ld	a5,0(s3) # 1000 <_entry-0x7ffff000>
  flags |= PTE_W;
  flags &= ~PTE_COW;
    80001aec:	2ff7f793          	andi	a5,a5,767

  // Cập nhật lại ánh xạ của bảng trang sang ô nhớ vật lý mới
  *pte = PA2PTE((uint64)mem) | flags;
    80001af0:	0047e793          	ori	a5,a5,4
    80001af4:	80b1                	srli	s1,s1,0xc
    80001af6:	04aa                	slli	s1,s1,0xa
    80001af8:	8fc5                	or	a5,a5,s1
    80001afa:	00f9b023          	sd	a5,0(s3)

  // Giải phóng trang cũ (Hàm này cần bổ sung bộ đếm liên kết tham chiếu ở bước hoàn thiện nâng cao)
  kfree((void*)pa_old);
    80001afe:	854a                	mv	a0,s2
    80001b00:	f1dfe0ef          	jal	80000a1c <kfree>

  return 0;
    80001b04:	4501                	li	a0,0
    80001b06:	64e2                	ld	s1,24(sp)
    80001b08:	6942                	ld	s2,16(sp)
}
    80001b0a:	70a2                	ld	ra,40(sp)
    80001b0c:	7402                	ld	s0,32(sp)
    80001b0e:	69a2                	ld	s3,8(sp)
    80001b10:	6145                	addi	sp,sp,48
    80001b12:	8082                	ret
  if(va >= MAXVA) return -1;
    80001b14:	557d                	li	a0,-1
}
    80001b16:	8082                	ret
  if(pte == 0) return -1;
    80001b18:	557d                	li	a0,-1
    80001b1a:	bfc5                	j	80001b0a <cow_handler+0x6a>
    return -1;
    80001b1c:	557d                	li	a0,-1
    80001b1e:	b7f5                	j	80001b0a <cow_handler+0x6a>
  if(mem == 0) return -1; // Trả về lỗi nếu hết bộ nhớ RAM
    80001b20:	557d                	li	a0,-1
    80001b22:	64e2                	ld	s1,24(sp)
    80001b24:	6942                	ld	s2,16(sp)
    80001b26:	b7d5                	j	80001b0a <cow_handler+0x6a>

0000000080001b28 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001b28:	7139                	addi	sp,sp,-64
    80001b2a:	fc06                	sd	ra,56(sp)
    80001b2c:	f822                	sd	s0,48(sp)
    80001b2e:	f426                	sd	s1,40(sp)
    80001b30:	f04a                	sd	s2,32(sp)
    80001b32:	ec4e                	sd	s3,24(sp)
    80001b34:	e852                	sd	s4,16(sp)
    80001b36:	e456                	sd	s5,8(sp)
    80001b38:	e05a                	sd	s6,0(sp)
    80001b3a:	0080                	addi	s0,sp,64
    80001b3c:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b3e:	0022f497          	auipc	s1,0x22f
    80001b42:	71248493          	addi	s1,s1,1810 # 80231250 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001b46:	8b26                	mv	s6,s1
    80001b48:	03eb2937          	lui	s2,0x3eb2
    80001b4c:	a1f90913          	addi	s2,s2,-1505 # 3eb1a1f <_entry-0x7c14e5e1>
    80001b50:	0932                	slli	s2,s2,0xc
    80001b52:	58d90913          	addi	s2,s2,1421
    80001b56:	0932                	slli	s2,s2,0xc
    80001b58:	0fb90913          	addi	s2,s2,251
    80001b5c:	0936                	slli	s2,s2,0xd
    80001b5e:	8d190913          	addi	s2,s2,-1839
    80001b62:	040009b7          	lui	s3,0x4000
    80001b66:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b68:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b6a:	00236a97          	auipc	s5,0x236
    80001b6e:	8e6a8a93          	addi	s5,s5,-1818 # 80237450 <tickslock>
    char *pa = kalloc();
    80001b72:	860ff0ef          	jal	80000bd2 <kalloc>
    80001b76:	862a                	mv	a2,a0
    if(pa == 0)
    80001b78:	cd15                	beqz	a0,80001bb4 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    80001b7a:	416485b3          	sub	a1,s1,s6
    80001b7e:	858d                	srai	a1,a1,0x3
    80001b80:	032585b3          	mul	a1,a1,s2
    80001b84:	2585                	addiw	a1,a1,1
    80001b86:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b8a:	4719                	li	a4,6
    80001b8c:	6685                	lui	a3,0x1
    80001b8e:	40b985b3          	sub	a1,s3,a1
    80001b92:	8552                	mv	a0,s4
    80001b94:	ee2ff0ef          	jal	80001276 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001b98:	18848493          	addi	s1,s1,392
    80001b9c:	fd549be3          	bne	s1,s5,80001b72 <proc_mapstacks+0x4a>
  }
}
    80001ba0:	70e2                	ld	ra,56(sp)
    80001ba2:	7442                	ld	s0,48(sp)
    80001ba4:	74a2                	ld	s1,40(sp)
    80001ba6:	7902                	ld	s2,32(sp)
    80001ba8:	69e2                	ld	s3,24(sp)
    80001baa:	6a42                	ld	s4,16(sp)
    80001bac:	6aa2                	ld	s5,8(sp)
    80001bae:	6b02                	ld	s6,0(sp)
    80001bb0:	6121                	addi	sp,sp,64
    80001bb2:	8082                	ret
      panic("kalloc");
    80001bb4:	00006517          	auipc	a0,0x6
    80001bb8:	5ec50513          	addi	a0,a0,1516 # 800081a0 <etext+0x1a0>
    80001bbc:	c25fe0ef          	jal	800007e0 <panic>

0000000080001bc0 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80001bc0:	7179                	addi	sp,sp,-48
    80001bc2:	f406                	sd	ra,40(sp)
    80001bc4:	f022                	sd	s0,32(sp)
    80001bc6:	ec26                	sd	s1,24(sp)
    80001bc8:	e84a                	sd	s2,16(sp)
    80001bca:	e44e                	sd	s3,8(sp)
    80001bcc:	1800                	addi	s0,sp,48
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001bce:	00006597          	auipc	a1,0x6
    80001bd2:	5da58593          	addi	a1,a1,1498 # 800081a8 <etext+0x1a8>
    80001bd6:	0022f517          	auipc	a0,0x22f
    80001bda:	24a50513          	addi	a0,a0,586 # 80230e20 <pid_lock>
    80001bde:	91aff0ef          	jal	80000cf8 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001be2:	00006597          	auipc	a1,0x6
    80001be6:	5ce58593          	addi	a1,a1,1486 # 800081b0 <etext+0x1b0>
    80001bea:	0022f517          	auipc	a0,0x22f
    80001bee:	24e50513          	addi	a0,a0,590 # 80230e38 <wait_lock>
    80001bf2:	906ff0ef          	jal	80000cf8 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bf6:	0022f497          	auipc	s1,0x22f
    80001bfa:	65a48493          	addi	s1,s1,1626 # 80231250 <proc>
      initlock(&p->lock, "proc");
    80001bfe:	00006997          	auipc	s3,0x6
    80001c02:	5c298993          	addi	s3,s3,1474 # 800081c0 <etext+0x1c0>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c06:	00236917          	auipc	s2,0x236
    80001c0a:	84a90913          	addi	s2,s2,-1974 # 80237450 <tickslock>
      initlock(&p->lock, "proc");
    80001c0e:	85ce                	mv	a1,s3
    80001c10:	8526                	mv	a0,s1
    80001c12:	8e6ff0ef          	jal	80000cf8 <initlock>
      p->state = UNUSED;
    80001c16:	0204a023          	sw	zero,32(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c1a:	18848493          	addi	s1,s1,392
    80001c1e:	ff2498e3          	bne	s1,s2,80001c0e <procinit+0x4e>
     // p->kstack = KSTACK((int) (p - proc));
  }
}
    80001c22:	70a2                	ld	ra,40(sp)
    80001c24:	7402                	ld	s0,32(sp)
    80001c26:	64e2                	ld	s1,24(sp)
    80001c28:	6942                	ld	s2,16(sp)
    80001c2a:	69a2                	ld	s3,8(sp)
    80001c2c:	6145                	addi	sp,sp,48
    80001c2e:	8082                	ret

0000000080001c30 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001c30:	1141                	addi	sp,sp,-16
    80001c32:	e422                	sd	s0,8(sp)
    80001c34:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c36:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001c38:	2501                	sext.w	a0,a0
    80001c3a:	6422                	ld	s0,8(sp)
    80001c3c:	0141                	addi	sp,sp,16
    80001c3e:	8082                	ret

0000000080001c40 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001c40:	1141                	addi	sp,sp,-16
    80001c42:	e422                	sd	s0,8(sp)
    80001c44:	0800                	addi	s0,sp,16
    80001c46:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001c48:	2781                	sext.w	a5,a5
    80001c4a:	079e                	slli	a5,a5,0x7
  return c;
}
    80001c4c:	0022f517          	auipc	a0,0x22f
    80001c50:	20450513          	addi	a0,a0,516 # 80230e50 <cpus>
    80001c54:	953e                	add	a0,a0,a5
    80001c56:	6422                	ld	s0,8(sp)
    80001c58:	0141                	addi	sp,sp,16
    80001c5a:	8082                	ret

0000000080001c5c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001c5c:	1101                	addi	sp,sp,-32
    80001c5e:	ec06                	sd	ra,24(sp)
    80001c60:	e822                	sd	s0,16(sp)
    80001c62:	e426                	sd	s1,8(sp)
    80001c64:	1000                	addi	s0,sp,32
  push_off();
    80001c66:	8d2ff0ef          	jal	80000d38 <push_off>
    80001c6a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c6c:	2781                	sext.w	a5,a5
    80001c6e:	079e                	slli	a5,a5,0x7
    80001c70:	0022f717          	auipc	a4,0x22f
    80001c74:	1b070713          	addi	a4,a4,432 # 80230e20 <pid_lock>
    80001c78:	97ba                	add	a5,a5,a4
    80001c7a:	7b84                	ld	s1,48(a5)
  pop_off();
    80001c7c:	940ff0ef          	jal	80000dbc <pop_off>
  return p;
}
    80001c80:	8526                	mv	a0,s1
    80001c82:	60e2                	ld	ra,24(sp)
    80001c84:	6442                	ld	s0,16(sp)
    80001c86:	64a2                	ld	s1,8(sp)
    80001c88:	6105                	addi	sp,sp,32
    80001c8a:	8082                	ret

0000000080001c8c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001c8c:	7179                	addi	sp,sp,-48
    80001c8e:	f406                	sd	ra,40(sp)
    80001c90:	f022                	sd	s0,32(sp)
    80001c92:	ec26                	sd	s1,24(sp)
    80001c94:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001c96:	fc7ff0ef          	jal	80001c5c <myproc>
    80001c9a:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001c9c:	974ff0ef          	jal	80000e10 <release>

  if (first) {
    80001ca0:	00007797          	auipc	a5,0x7
    80001ca4:	0207a783          	lw	a5,32(a5) # 80008cc0 <first.1>
    80001ca8:	cf8d                	beqz	a5,80001ce2 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001caa:	4505                	li	a0,1
    80001cac:	098020ef          	jal	80003d44 <fsinit>

    first = 0;
    80001cb0:	00007797          	auipc	a5,0x7
    80001cb4:	0007a823          	sw	zero,16(a5) # 80008cc0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001cb8:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){ "/init", 0 });
    80001cbc:	00006517          	auipc	a0,0x6
    80001cc0:	50c50513          	addi	a0,a0,1292 # 800081c8 <etext+0x1c8>
    80001cc4:	fca43823          	sd	a0,-48(s0)
    80001cc8:	fc043c23          	sd	zero,-40(s0)
    80001ccc:	fd040593          	addi	a1,s0,-48
    80001cd0:	17e030ef          	jal	80004e4e <kexec>
    80001cd4:	70bc                	ld	a5,96(s1)
    80001cd6:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001cd8:	70bc                	ld	a5,96(s1)
    80001cda:	7bb8                	ld	a4,112(a5)
    80001cdc:	57fd                	li	a5,-1
    80001cde:	02f70d63          	beq	a4,a5,80001d18 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001ce2:	36b000ef          	jal	8000284c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001ce6:	6ca8                	ld	a0,88(s1)
    80001ce8:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001cea:	04000737          	lui	a4,0x4000
    80001cee:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001cf0:	0732                	slli	a4,a4,0xc
    80001cf2:	00005797          	auipc	a5,0x5
    80001cf6:	3aa78793          	addi	a5,a5,938 # 8000709c <userret>
    80001cfa:	00005697          	auipc	a3,0x5
    80001cfe:	30668693          	addi	a3,a3,774 # 80007000 <_trampoline>
    80001d02:	8f95                	sub	a5,a5,a3
    80001d04:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001d06:	577d                	li	a4,-1
    80001d08:	177e                	slli	a4,a4,0x3f
    80001d0a:	8d59                	or	a0,a0,a4
    80001d0c:	9782                	jalr	a5
}
    80001d0e:	70a2                	ld	ra,40(sp)
    80001d10:	7402                	ld	s0,32(sp)
    80001d12:	64e2                	ld	s1,24(sp)
    80001d14:	6145                	addi	sp,sp,48
    80001d16:	8082                	ret
      panic("exec");
    80001d18:	00006517          	auipc	a0,0x6
    80001d1c:	4b850513          	addi	a0,a0,1208 # 800081d0 <etext+0x1d0>
    80001d20:	ac1fe0ef          	jal	800007e0 <panic>

0000000080001d24 <allocpid>:
{
    80001d24:	1101                	addi	sp,sp,-32
    80001d26:	ec06                	sd	ra,24(sp)
    80001d28:	e822                	sd	s0,16(sp)
    80001d2a:	e426                	sd	s1,8(sp)
    80001d2c:	e04a                	sd	s2,0(sp)
    80001d2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d30:	0022f917          	auipc	s2,0x22f
    80001d34:	0f090913          	addi	s2,s2,240 # 80230e20 <pid_lock>
    80001d38:	854a                	mv	a0,s2
    80001d3a:	83eff0ef          	jal	80000d78 <acquire>
  pid = nextpid;
    80001d3e:	00007797          	auipc	a5,0x7
    80001d42:	f8678793          	addi	a5,a5,-122 # 80008cc4 <nextpid>
    80001d46:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d48:	0014871b          	addiw	a4,s1,1
    80001d4c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d4e:	854a                	mv	a0,s2
    80001d50:	8c0ff0ef          	jal	80000e10 <release>
}
    80001d54:	8526                	mv	a0,s1
    80001d56:	60e2                	ld	ra,24(sp)
    80001d58:	6442                	ld	s0,16(sp)
    80001d5a:	64a2                	ld	s1,8(sp)
    80001d5c:	6902                	ld	s2,0(sp)
    80001d5e:	6105                	addi	sp,sp,32
    80001d60:	8082                	ret

0000000080001d62 <proc_pagetable>:
{
    80001d62:	1101                	addi	sp,sp,-32
    80001d64:	ec06                	sd	ra,24(sp)
    80001d66:	e822                	sd	s0,16(sp)
    80001d68:	e426                	sd	s1,8(sp)
    80001d6a:	e04a                	sd	s2,0(sp)
    80001d6c:	1000                	addi	s0,sp,32
    80001d6e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d70:	df6ff0ef          	jal	80001366 <uvmcreate>
    80001d74:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001d76:	cd05                	beqz	a0,80001dae <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d78:	4729                	li	a4,10
    80001d7a:	00005697          	auipc	a3,0x5
    80001d7e:	28668693          	addi	a3,a3,646 # 80007000 <_trampoline>
    80001d82:	6605                	lui	a2,0x1
    80001d84:	040005b7          	lui	a1,0x4000
    80001d88:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d8a:	05b2                	slli	a1,a1,0xc
    80001d8c:	c3aff0ef          	jal	800011c6 <mappages>
    80001d90:	02054663          	bltz	a0,80001dbc <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d94:	4719                	li	a4,6
    80001d96:	06093683          	ld	a3,96(s2)
    80001d9a:	6605                	lui	a2,0x1
    80001d9c:	020005b7          	lui	a1,0x2000
    80001da0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001da2:	05b6                	slli	a1,a1,0xd
    80001da4:	8526                	mv	a0,s1
    80001da6:	c20ff0ef          	jal	800011c6 <mappages>
    80001daa:	00054f63          	bltz	a0,80001dc8 <proc_pagetable+0x66>
}
    80001dae:	8526                	mv	a0,s1
    80001db0:	60e2                	ld	ra,24(sp)
    80001db2:	6442                	ld	s0,16(sp)
    80001db4:	64a2                	ld	s1,8(sp)
    80001db6:	6902                	ld	s2,0(sp)
    80001db8:	6105                	addi	sp,sp,32
    80001dba:	8082                	ret
    uvmfree(pagetable, 0);
    80001dbc:	4581                	li	a1,0
    80001dbe:	8526                	mv	a0,s1
    80001dc0:	fc2ff0ef          	jal	80001582 <uvmfree>
    return 0;
    80001dc4:	4481                	li	s1,0
    80001dc6:	b7e5                	j	80001dae <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dc8:	4681                	li	a3,0
    80001dca:	4605                	li	a2,1
    80001dcc:	040005b7          	lui	a1,0x4000
    80001dd0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dd2:	05b2                	slli	a1,a1,0xc
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	db6ff0ef          	jal	8000138c <uvmunmap>
    uvmfree(pagetable, 0);
    80001dda:	4581                	li	a1,0
    80001ddc:	8526                	mv	a0,s1
    80001dde:	fa4ff0ef          	jal	80001582 <uvmfree>
    return 0;
    80001de2:	4481                	li	s1,0
    80001de4:	b7e9                	j	80001dae <proc_pagetable+0x4c>

0000000080001de6 <proc_freepagetable>:
{
    80001de6:	1101                	addi	sp,sp,-32
    80001de8:	ec06                	sd	ra,24(sp)
    80001dea:	e822                	sd	s0,16(sp)
    80001dec:	e426                	sd	s1,8(sp)
    80001dee:	e04a                	sd	s2,0(sp)
    80001df0:	1000                	addi	s0,sp,32
    80001df2:	84aa                	mv	s1,a0
    80001df4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001df6:	4681                	li	a3,0
    80001df8:	4605                	li	a2,1
    80001dfa:	040005b7          	lui	a1,0x4000
    80001dfe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e00:	05b2                	slli	a1,a1,0xc
    80001e02:	d8aff0ef          	jal	8000138c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e06:	4681                	li	a3,0
    80001e08:	4605                	li	a2,1
    80001e0a:	020005b7          	lui	a1,0x2000
    80001e0e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e10:	05b6                	slli	a1,a1,0xd
    80001e12:	8526                	mv	a0,s1
    80001e14:	d78ff0ef          	jal	8000138c <uvmunmap>
  uvmfree(pagetable, sz);
    80001e18:	85ca                	mv	a1,s2
    80001e1a:	8526                	mv	a0,s1
    80001e1c:	f66ff0ef          	jal	80001582 <uvmfree>
}
    80001e20:	60e2                	ld	ra,24(sp)
    80001e22:	6442                	ld	s0,16(sp)
    80001e24:	64a2                	ld	s1,8(sp)
    80001e26:	6902                	ld	s2,0(sp)
    80001e28:	6105                	addi	sp,sp,32
    80001e2a:	8082                	ret

0000000080001e2c <freeproc>:
{
    80001e2c:	1101                	addi	sp,sp,-32
    80001e2e:	ec06                	sd	ra,24(sp)
    80001e30:	e822                	sd	s0,16(sp)
    80001e32:	e426                	sd	s1,8(sp)
    80001e34:	1000                	addi	s0,sp,32
    80001e36:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001e38:	7128                	ld	a0,96(a0)
    80001e3a:	c119                	beqz	a0,80001e40 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001e3c:	be1fe0ef          	jal	80000a1c <kfree>
  p->trapframe = 0;
    80001e40:	0604b023          	sd	zero,96(s1)
  if(p->kpagetable){
    80001e44:	6c88                	ld	a0,24(s1)
    80001e46:	c501                	beqz	a0,80001e4e <freeproc+0x22>
    proc_free_kpagetable(p->kpagetable, p->kstack);
    80001e48:	64ac                	ld	a1,72(s1)
    80001e4a:	bc1ff0ef          	jal	80001a0a <proc_free_kpagetable>
  p->kpagetable = 0;
    80001e4e:	0004bc23          	sd	zero,24(s1)
  if(p->pagetable)
    80001e52:	6ca8                	ld	a0,88(s1)
    80001e54:	c501                	beqz	a0,80001e5c <freeproc+0x30>
    proc_freepagetable(p->pagetable, p->sz);
    80001e56:	68ac                	ld	a1,80(s1)
    80001e58:	f8fff0ef          	jal	80001de6 <proc_freepagetable>
  p->pagetable = 0;
    80001e5c:	0404bc23          	sd	zero,88(s1)
  p->sz = 0;
    80001e60:	0404b823          	sd	zero,80(s1)
  p->pid = 0;
    80001e64:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001e68:	0404b023          	sd	zero,64(s1)
  p->name[0] = 0;
    80001e6c:	16048023          	sb	zero,352(s1)
  p->chan = 0;
    80001e70:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001e74:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001e78:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001e7c:	0204a023          	sw	zero,32(s1)
  p->kstack = 0; // Đặt về 0 sau khi giải phóng
    80001e80:	0404b423          	sd	zero,72(s1)
}
    80001e84:	60e2                	ld	ra,24(sp)
    80001e86:	6442                	ld	s0,16(sp)
    80001e88:	64a2                	ld	s1,8(sp)
    80001e8a:	6105                	addi	sp,sp,32
    80001e8c:	8082                	ret

0000000080001e8e <allocproc>:
{
    80001e8e:	7179                	addi	sp,sp,-48
    80001e90:	f406                	sd	ra,40(sp)
    80001e92:	f022                	sd	s0,32(sp)
    80001e94:	ec26                	sd	s1,24(sp)
    80001e96:	e84a                	sd	s2,16(sp)
    80001e98:	1800                	addi	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001e9a:	0022f497          	auipc	s1,0x22f
    80001e9e:	3b648493          	addi	s1,s1,950 # 80231250 <proc>
    80001ea2:	00235917          	auipc	s2,0x235
    80001ea6:	5ae90913          	addi	s2,s2,1454 # 80237450 <tickslock>
    acquire(&p->lock);
    80001eaa:	8526                	mv	a0,s1
    80001eac:	ecdfe0ef          	jal	80000d78 <acquire>
    if(p->state == UNUSED) {
    80001eb0:	509c                	lw	a5,32(s1)
    80001eb2:	cb91                	beqz	a5,80001ec6 <allocproc+0x38>
      release(&p->lock);
    80001eb4:	8526                	mv	a0,s1
    80001eb6:	f5bfe0ef          	jal	80000e10 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001eba:	18848493          	addi	s1,s1,392
    80001ebe:	ff2496e3          	bne	s1,s2,80001eaa <allocproc+0x1c>
  return 0;
    80001ec2:	4481                	li	s1,0
    80001ec4:	a845                	j	80001f74 <allocproc+0xe6>
  p->pid = allocpid();
    80001ec6:	e5fff0ef          	jal	80001d24 <allocpid>
    80001eca:	dc88                	sw	a0,56(s1)
  p->state = USED;
    80001ecc:	4785                	li	a5,1
    80001ece:	d09c                	sw	a5,32(s1)
  p->fault_count = 0;// KHỞI TẠO BỘ ĐẾM VẾT ĐEN KHI TIẾN TRÌNH ĐƯỢC TẠO
    80001ed0:	1604a823          	sw	zero,368(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001ed4:	cfffe0ef          	jal	80000bd2 <kalloc>
    80001ed8:	892a                	mv	s2,a0
    80001eda:	f0a8                	sd	a0,96(s1)
    80001edc:	c15d                	beqz	a0,80001f82 <allocproc+0xf4>
  p->pagetable = proc_pagetable(p);
    80001ede:	8526                	mv	a0,s1
    80001ee0:	e83ff0ef          	jal	80001d62 <proc_pagetable>
    80001ee4:	892a                	mv	s2,a0
    80001ee6:	eca8                	sd	a0,88(s1)
  if(p->pagetable == 0){
    80001ee8:	c54d                	beqz	a0,80001f92 <allocproc+0x104>
  p->kpagetable = proc_kpagetable(p);
    80001eea:	8526                	mv	a0,s1
    80001eec:	a7bff0ef          	jal	80001966 <proc_kpagetable>
    80001ef0:	892a                	mv	s2,a0
    80001ef2:	ec88                	sd	a0,24(s1)
  if(p->kpagetable == 0){
    80001ef4:	c55d                	beqz	a0,80001fa2 <allocproc+0x114>
    80001ef6:	e44e                	sd	s3,8(sp)
  char *pa = kalloc();
    80001ef8:	cdbfe0ef          	jal	80000bd2 <kalloc>
    80001efc:	89aa                	mv	s3,a0
  if(pa == 0) {
    80001efe:	c955                	beqz	a0,80001fb2 <allocproc+0x124>
  uint64 va = KSTACK((int)(p - proc));
    80001f00:	0022f797          	auipc	a5,0x22f
    80001f04:	35078793          	addi	a5,a5,848 # 80231250 <proc>
    80001f08:	40f487b3          	sub	a5,s1,a5
    80001f0c:	4037d713          	srai	a4,a5,0x3
    80001f10:	03eb27b7          	lui	a5,0x3eb2
    80001f14:	a1f78793          	addi	a5,a5,-1505 # 3eb1a1f <_entry-0x7c14e5e1>
    80001f18:	07b2                	slli	a5,a5,0xc
    80001f1a:	58d78793          	addi	a5,a5,1421
    80001f1e:	07b2                	slli	a5,a5,0xc
    80001f20:	0fb78793          	addi	a5,a5,251
    80001f24:	07b6                	slli	a5,a5,0xd
    80001f26:	8d178793          	addi	a5,a5,-1839
    80001f2a:	02f707b3          	mul	a5,a4,a5
    80001f2e:	2785                	addiw	a5,a5,1
    80001f30:	00d7979b          	slliw	a5,a5,0xd
    80001f34:	04000737          	lui	a4,0x4000
    80001f38:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001f3a:	0732                	slli	a4,a4,0xc
    80001f3c:	40f70933          	sub	s2,a4,a5
  uvmmap(p->kpagetable, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001f40:	4719                	li	a4,6
    80001f42:	6685                	lui	a3,0x1
    80001f44:	862a                	mv	a2,a0
    80001f46:	85ca                	mv	a1,s2
    80001f48:	6c88                	ld	a0,24(s1)
    80001f4a:	9f5ff0ef          	jal	8000193e <uvmmap>
  p->kstack = va;
    80001f4e:	0524b423          	sd	s2,72(s1)
  memset(&p->context, 0, sizeof(p->context));
    80001f52:	07000613          	li	a2,112
    80001f56:	4581                	li	a1,0
    80001f58:	06848513          	addi	a0,s1,104
    80001f5c:	ef1fe0ef          	jal	80000e4c <memset>
  p->context.ra = (uint64)forkret;
    80001f60:	00000797          	auipc	a5,0x0
    80001f64:	d2c78793          	addi	a5,a5,-724 # 80001c8c <forkret>
    80001f68:	f4bc                	sd	a5,104(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f6a:	64bc                	ld	a5,72(s1)
    80001f6c:	6705                	lui	a4,0x1
    80001f6e:	97ba                	add	a5,a5,a4
    80001f70:	f8bc                	sd	a5,112(s1)
    80001f72:	69a2                	ld	s3,8(sp)
}
    80001f74:	8526                	mv	a0,s1
    80001f76:	70a2                	ld	ra,40(sp)
    80001f78:	7402                	ld	s0,32(sp)
    80001f7a:	64e2                	ld	s1,24(sp)
    80001f7c:	6942                	ld	s2,16(sp)
    80001f7e:	6145                	addi	sp,sp,48
    80001f80:	8082                	ret
    freeproc(p);
    80001f82:	8526                	mv	a0,s1
    80001f84:	ea9ff0ef          	jal	80001e2c <freeproc>
    release(&p->lock);
    80001f88:	8526                	mv	a0,s1
    80001f8a:	e87fe0ef          	jal	80000e10 <release>
    return 0;
    80001f8e:	84ca                	mv	s1,s2
    80001f90:	b7d5                	j	80001f74 <allocproc+0xe6>
    freeproc(p);
    80001f92:	8526                	mv	a0,s1
    80001f94:	e99ff0ef          	jal	80001e2c <freeproc>
    release(&p->lock);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	e77fe0ef          	jal	80000e10 <release>
    return 0;
    80001f9e:	84ca                	mv	s1,s2
    80001fa0:	bfd1                	j	80001f74 <allocproc+0xe6>
    freeproc(p);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	e89ff0ef          	jal	80001e2c <freeproc>
    release(&p->lock);
    80001fa8:	8526                	mv	a0,s1
    80001faa:	e67fe0ef          	jal	80000e10 <release>
    return 0;
    80001fae:	84ca                	mv	s1,s2
    80001fb0:	b7d1                	j	80001f74 <allocproc+0xe6>
    freeproc(p);
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	e79ff0ef          	jal	80001e2c <freeproc>
    release(&p->lock);
    80001fb8:	8526                	mv	a0,s1
    80001fba:	e57fe0ef          	jal	80000e10 <release>
    return 0;
    80001fbe:	84ce                	mv	s1,s3
    80001fc0:	69a2                	ld	s3,8(sp)
    80001fc2:	bf4d                	j	80001f74 <allocproc+0xe6>

0000000080001fc4 <userinit>:
{
    80001fc4:	1101                	addi	sp,sp,-32
    80001fc6:	ec06                	sd	ra,24(sp)
    80001fc8:	e822                	sd	s0,16(sp)
    80001fca:	e426                	sd	s1,8(sp)
    80001fcc:	1000                	addi	s0,sp,32
  p = allocproc();
    80001fce:	ec1ff0ef          	jal	80001e8e <allocproc>
    80001fd2:	84aa                	mv	s1,a0
  initproc = p;
    80001fd4:	00007797          	auipc	a5,0x7
    80001fd8:	d0a7be23          	sd	a0,-740(a5) # 80008cf0 <initproc>
  p->cwd = namei("/");
    80001fdc:	00006517          	auipc	a0,0x6
    80001fe0:	1fc50513          	addi	a0,a0,508 # 800081d8 <etext+0x1d8>
    80001fe4:	282020ef          	jal	80004266 <namei>
    80001fe8:	14a4bc23          	sd	a0,344(s1)
  p->state = RUNNABLE;
    80001fec:	478d                	li	a5,3
    80001fee:	d09c                	sw	a5,32(s1)
  release(&p->lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	e1ffe0ef          	jal	80000e10 <release>
}
    80001ff6:	60e2                	ld	ra,24(sp)
    80001ff8:	6442                	ld	s0,16(sp)
    80001ffa:	64a2                	ld	s1,8(sp)
    80001ffc:	6105                	addi	sp,sp,32
    80001ffe:	8082                	ret

0000000080002000 <growproc>:
{
    80002000:	1101                	addi	sp,sp,-32
    80002002:	ec06                	sd	ra,24(sp)
    80002004:	e822                	sd	s0,16(sp)
    80002006:	e426                	sd	s1,8(sp)
    80002008:	e04a                	sd	s2,0(sp)
    8000200a:	1000                	addi	s0,sp,32
    8000200c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000200e:	c4fff0ef          	jal	80001c5c <myproc>
    80002012:	892a                	mv	s2,a0
  sz = p->sz;
    80002014:	692c                	ld	a1,80(a0)
  if(n > 0){
    80002016:	02905963          	blez	s1,80002048 <growproc+0x48>
    if(sz + n > TRAPFRAME) {
    8000201a:	00b48633          	add	a2,s1,a1
    8000201e:	020007b7          	lui	a5,0x2000
    80002022:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80002024:	07b6                	slli	a5,a5,0xd
    80002026:	02c7ea63          	bltu	a5,a2,8000205a <growproc+0x5a>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    8000202a:	4691                	li	a3,4
    8000202c:	6d28                	ld	a0,88(a0)
    8000202e:	c4eff0ef          	jal	8000147c <uvmalloc>
    80002032:	85aa                	mv	a1,a0
    80002034:	c50d                	beqz	a0,8000205e <growproc+0x5e>
  p->sz = sz;
    80002036:	04b93823          	sd	a1,80(s2)
  return 0;
    8000203a:	4501                	li	a0,0
}
    8000203c:	60e2                	ld	ra,24(sp)
    8000203e:	6442                	ld	s0,16(sp)
    80002040:	64a2                	ld	s1,8(sp)
    80002042:	6902                	ld	s2,0(sp)
    80002044:	6105                	addi	sp,sp,32
    80002046:	8082                	ret
  } else if(n < 0){
    80002048:	fe04d7e3          	bgez	s1,80002036 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000204c:	00b48633          	add	a2,s1,a1
    80002050:	6d28                	ld	a0,88(a0)
    80002052:	be6ff0ef          	jal	80001438 <uvmdealloc>
    80002056:	85aa                	mv	a1,a0
    80002058:	bff9                	j	80002036 <growproc+0x36>
      return -1;
    8000205a:	557d                	li	a0,-1
    8000205c:	b7c5                	j	8000203c <growproc+0x3c>
      return -1;
    8000205e:	557d                	li	a0,-1
    80002060:	bff1                	j	8000203c <growproc+0x3c>

0000000080002062 <kfork>:
{
    80002062:	7139                	addi	sp,sp,-64
    80002064:	fc06                	sd	ra,56(sp)
    80002066:	f822                	sd	s0,48(sp)
    80002068:	f04a                	sd	s2,32(sp)
    8000206a:	e456                	sd	s5,8(sp)
    8000206c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    8000206e:	befff0ef          	jal	80001c5c <myproc>
    80002072:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80002074:	e1bff0ef          	jal	80001e8e <allocproc>
    80002078:	0e050a63          	beqz	a0,8000216c <kfork+0x10a>
    8000207c:	e852                	sd	s4,16(sp)
    8000207e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80002080:	050ab603          	ld	a2,80(s5)
    80002084:	6d2c                	ld	a1,88(a0)
    80002086:	058ab503          	ld	a0,88(s5)
    8000208a:	d2aff0ef          	jal	800015b4 <uvmcopy>
    8000208e:	04054a63          	bltz	a0,800020e2 <kfork+0x80>
    80002092:	f426                	sd	s1,40(sp)
    80002094:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80002096:	050ab783          	ld	a5,80(s5)
    8000209a:	04fa3823          	sd	a5,80(s4)
  *(np->trapframe) = *(p->trapframe);
    8000209e:	060ab683          	ld	a3,96(s5)
    800020a2:	87b6                	mv	a5,a3
    800020a4:	060a3703          	ld	a4,96(s4)
    800020a8:	12068693          	addi	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    800020ac:	0007b803          	ld	a6,0(a5)
    800020b0:	6788                	ld	a0,8(a5)
    800020b2:	6b8c                	ld	a1,16(a5)
    800020b4:	6f90                	ld	a2,24(a5)
    800020b6:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    800020ba:	e708                	sd	a0,8(a4)
    800020bc:	eb0c                	sd	a1,16(a4)
    800020be:	ef10                	sd	a2,24(a4)
    800020c0:	02078793          	addi	a5,a5,32
    800020c4:	02070713          	addi	a4,a4,32
    800020c8:	fed792e3          	bne	a5,a3,800020ac <kfork+0x4a>
  np->trapframe->a0 = 0;
    800020cc:	060a3783          	ld	a5,96(s4)
    800020d0:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800020d4:	0d8a8493          	addi	s1,s5,216
    800020d8:	0d8a0913          	addi	s2,s4,216
    800020dc:	158a8993          	addi	s3,s5,344
    800020e0:	a831                	j	800020fc <kfork+0x9a>
    freeproc(np);
    800020e2:	8552                	mv	a0,s4
    800020e4:	d49ff0ef          	jal	80001e2c <freeproc>
    release(&np->lock);
    800020e8:	8552                	mv	a0,s4
    800020ea:	d27fe0ef          	jal	80000e10 <release>
    return -1;
    800020ee:	597d                	li	s2,-1
    800020f0:	6a42                	ld	s4,16(sp)
    800020f2:	a0b5                	j	8000215e <kfork+0xfc>
  for(i = 0; i < NOFILE; i++)
    800020f4:	04a1                	addi	s1,s1,8
    800020f6:	0921                	addi	s2,s2,8
    800020f8:	01348963          	beq	s1,s3,8000210a <kfork+0xa8>
    if(p->ofile[i])
    800020fc:	6088                	ld	a0,0(s1)
    800020fe:	d97d                	beqz	a0,800020f4 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80002100:	700020ef          	jal	80004800 <filedup>
    80002104:	00a93023          	sd	a0,0(s2)
    80002108:	b7f5                	j	800020f4 <kfork+0x92>
  np->cwd = idup(p->cwd);
    8000210a:	158ab503          	ld	a0,344(s5)
    8000210e:	10d010ef          	jal	80003a1a <idup>
    80002112:	14aa3c23          	sd	a0,344(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002116:	4641                	li	a2,16
    80002118:	160a8593          	addi	a1,s5,352
    8000211c:	160a0513          	addi	a0,s4,352
    80002120:	e6bfe0ef          	jal	80000f8a <safestrcpy>
  pid = np->pid;
    80002124:	038a2903          	lw	s2,56(s4)
  release(&np->lock);
    80002128:	8552                	mv	a0,s4
    8000212a:	ce7fe0ef          	jal	80000e10 <release>
  acquire(&wait_lock);
    8000212e:	0022f497          	auipc	s1,0x22f
    80002132:	d0a48493          	addi	s1,s1,-758 # 80230e38 <wait_lock>
    80002136:	8526                	mv	a0,s1
    80002138:	c41fe0ef          	jal	80000d78 <acquire>
  np->parent = p;
    8000213c:	055a3023          	sd	s5,64(s4)
  release(&wait_lock);
    80002140:	8526                	mv	a0,s1
    80002142:	ccffe0ef          	jal	80000e10 <release>
  acquire(&np->lock);
    80002146:	8552                	mv	a0,s4
    80002148:	c31fe0ef          	jal	80000d78 <acquire>
  np->state = RUNNABLE;
    8000214c:	478d                	li	a5,3
    8000214e:	02fa2023          	sw	a5,32(s4)
  release(&np->lock);
    80002152:	8552                	mv	a0,s4
    80002154:	cbdfe0ef          	jal	80000e10 <release>
  return pid;
    80002158:	74a2                	ld	s1,40(sp)
    8000215a:	69e2                	ld	s3,24(sp)
    8000215c:	6a42                	ld	s4,16(sp)
}
    8000215e:	854a                	mv	a0,s2
    80002160:	70e2                	ld	ra,56(sp)
    80002162:	7442                	ld	s0,48(sp)
    80002164:	7902                	ld	s2,32(sp)
    80002166:	6aa2                	ld	s5,8(sp)
    80002168:	6121                	addi	sp,sp,64
    8000216a:	8082                	ret
    return -1;
    8000216c:	597d                	li	s2,-1
    8000216e:	bfc5                	j	8000215e <kfork+0xfc>

0000000080002170 <scheduler>:
{
    80002170:	715d                	addi	sp,sp,-80
    80002172:	e486                	sd	ra,72(sp)
    80002174:	e0a2                	sd	s0,64(sp)
    80002176:	fc26                	sd	s1,56(sp)
    80002178:	f84a                	sd	s2,48(sp)
    8000217a:	f44e                	sd	s3,40(sp)
    8000217c:	f052                	sd	s4,32(sp)
    8000217e:	ec56                	sd	s5,24(sp)
    80002180:	e85a                	sd	s6,16(sp)
    80002182:	e45e                	sd	s7,8(sp)
    80002184:	e062                	sd	s8,0(sp)
    80002186:	0880                	addi	s0,sp,80
    80002188:	8792                	mv	a5,tp
  int id = r_tp();
    8000218a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000218c:	00779b13          	slli	s6,a5,0x7
    80002190:	0022f717          	auipc	a4,0x22f
    80002194:	c9070713          	addi	a4,a4,-880 # 80230e20 <pid_lock>
    80002198:	975a                	add	a4,a4,s6
    8000219a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000219e:	0022f717          	auipc	a4,0x22f
    800021a2:	cba70713          	addi	a4,a4,-838 # 80230e58 <cpus+0x8>
    800021a6:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    800021a8:	4c11                	li	s8,4
        c->proc = p;
    800021aa:	079e                	slli	a5,a5,0x7
    800021ac:	0022fa17          	auipc	s4,0x22f
    800021b0:	c74a0a13          	addi	s4,s4,-908 # 80230e20 <pid_lock>
    800021b4:	9a3e                	add	s4,s4,a5
        found = 1;
    800021b6:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    800021b8:	00235997          	auipc	s3,0x235
    800021bc:	29898993          	addi	s3,s3,664 # 80237450 <tickslock>
    800021c0:	a0a1                	j	80002208 <scheduler+0x98>
      release(&p->lock);
    800021c2:	8526                	mv	a0,s1
    800021c4:	c4dfe0ef          	jal	80000e10 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800021c8:	18848493          	addi	s1,s1,392
    800021cc:	03348a63          	beq	s1,s3,80002200 <scheduler+0x90>
      acquire(&p->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	ba7fe0ef          	jal	80000d78 <acquire>
      if(p->state == RUNNABLE) {
    800021d6:	509c                	lw	a5,32(s1)
    800021d8:	ff2795e3          	bne	a5,s2,800021c2 <scheduler+0x52>
        p->state = RUNNING;
    800021dc:	0384a023          	sw	s8,32(s1)
        c->proc = p;
    800021e0:	029a3823          	sd	s1,48(s4)
        kvm_switch(p->kpagetable);
    800021e4:	6c88                	ld	a0,24(s1)
    800021e6:	ec7fe0ef          	jal	800010ac <kvm_switch>
        swtch(&c->context, &p->context);
    800021ea:	06848593          	addi	a1,s1,104
    800021ee:	855a                	mv	a0,s6
    800021f0:	5b6000ef          	jal	800027a6 <swtch>
        kvminithart();
    800021f4:	ee1fe0ef          	jal	800010d4 <kvminithart>
        c->proc = 0;
    800021f8:	020a3823          	sd	zero,48(s4)
        found = 1;
    800021fc:	8ade                	mv	s5,s7
    800021fe:	b7d1                	j	800021c2 <scheduler+0x52>
    if(found == 0) {
    80002200:	000a9463          	bnez	s5,80002208 <scheduler+0x98>
      asm volatile("wfi");
    80002204:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002208:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000220c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002210:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002214:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002218:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000221a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000221e:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002220:	0022f497          	auipc	s1,0x22f
    80002224:	03048493          	addi	s1,s1,48 # 80231250 <proc>
      if(p->state == RUNNABLE) {
    80002228:	490d                	li	s2,3
    8000222a:	b75d                	j	800021d0 <scheduler+0x60>

000000008000222c <sched>:
{
    8000222c:	7179                	addi	sp,sp,-48
    8000222e:	f406                	sd	ra,40(sp)
    80002230:	f022                	sd	s0,32(sp)
    80002232:	ec26                	sd	s1,24(sp)
    80002234:	e84a                	sd	s2,16(sp)
    80002236:	e44e                	sd	s3,8(sp)
    80002238:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000223a:	a23ff0ef          	jal	80001c5c <myproc>
    8000223e:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002240:	acffe0ef          	jal	80000d0e <holding>
    80002244:	c92d                	beqz	a0,800022b6 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002246:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002248:	2781                	sext.w	a5,a5
    8000224a:	079e                	slli	a5,a5,0x7
    8000224c:	0022f717          	auipc	a4,0x22f
    80002250:	bd470713          	addi	a4,a4,-1068 # 80230e20 <pid_lock>
    80002254:	97ba                	add	a5,a5,a4
    80002256:	0a87a703          	lw	a4,168(a5)
    8000225a:	4785                	li	a5,1
    8000225c:	06f71363          	bne	a4,a5,800022c2 <sched+0x96>
  if(p->state == RUNNING)
    80002260:	5098                	lw	a4,32(s1)
    80002262:	4791                	li	a5,4
    80002264:	06f70563          	beq	a4,a5,800022ce <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002268:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000226c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000226e:	e7b5                	bnez	a5,800022da <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002270:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002272:	0022f917          	auipc	s2,0x22f
    80002276:	bae90913          	addi	s2,s2,-1106 # 80230e20 <pid_lock>
    8000227a:	2781                	sext.w	a5,a5
    8000227c:	079e                	slli	a5,a5,0x7
    8000227e:	97ca                	add	a5,a5,s2
    80002280:	0ac7a983          	lw	s3,172(a5)
    80002284:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002286:	2781                	sext.w	a5,a5
    80002288:	079e                	slli	a5,a5,0x7
    8000228a:	0022f597          	auipc	a1,0x22f
    8000228e:	bce58593          	addi	a1,a1,-1074 # 80230e58 <cpus+0x8>
    80002292:	95be                	add	a1,a1,a5
    80002294:	06848513          	addi	a0,s1,104
    80002298:	50e000ef          	jal	800027a6 <swtch>
    8000229c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000229e:	2781                	sext.w	a5,a5
    800022a0:	079e                	slli	a5,a5,0x7
    800022a2:	993e                	add	s2,s2,a5
    800022a4:	0b392623          	sw	s3,172(s2)
}
    800022a8:	70a2                	ld	ra,40(sp)
    800022aa:	7402                	ld	s0,32(sp)
    800022ac:	64e2                	ld	s1,24(sp)
    800022ae:	6942                	ld	s2,16(sp)
    800022b0:	69a2                	ld	s3,8(sp)
    800022b2:	6145                	addi	sp,sp,48
    800022b4:	8082                	ret
    panic("sched p->lock");
    800022b6:	00006517          	auipc	a0,0x6
    800022ba:	f2a50513          	addi	a0,a0,-214 # 800081e0 <etext+0x1e0>
    800022be:	d22fe0ef          	jal	800007e0 <panic>
    panic("sched locks");
    800022c2:	00006517          	auipc	a0,0x6
    800022c6:	f2e50513          	addi	a0,a0,-210 # 800081f0 <etext+0x1f0>
    800022ca:	d16fe0ef          	jal	800007e0 <panic>
    panic("sched RUNNING");
    800022ce:	00006517          	auipc	a0,0x6
    800022d2:	f3250513          	addi	a0,a0,-206 # 80008200 <etext+0x200>
    800022d6:	d0afe0ef          	jal	800007e0 <panic>
    panic("sched interruptible");
    800022da:	00006517          	auipc	a0,0x6
    800022de:	f3650513          	addi	a0,a0,-202 # 80008210 <etext+0x210>
    800022e2:	cfefe0ef          	jal	800007e0 <panic>

00000000800022e6 <yield>:
{
    800022e6:	1101                	addi	sp,sp,-32
    800022e8:	ec06                	sd	ra,24(sp)
    800022ea:	e822                	sd	s0,16(sp)
    800022ec:	e426                	sd	s1,8(sp)
    800022ee:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800022f0:	96dff0ef          	jal	80001c5c <myproc>
    800022f4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022f6:	a83fe0ef          	jal	80000d78 <acquire>
  p->state = RUNNABLE;
    800022fa:	478d                	li	a5,3
    800022fc:	d09c                	sw	a5,32(s1)
  sched();
    800022fe:	f2fff0ef          	jal	8000222c <sched>
  release(&p->lock);
    80002302:	8526                	mv	a0,s1
    80002304:	b0dfe0ef          	jal	80000e10 <release>
}
    80002308:	60e2                	ld	ra,24(sp)
    8000230a:	6442                	ld	s0,16(sp)
    8000230c:	64a2                	ld	s1,8(sp)
    8000230e:	6105                	addi	sp,sp,32
    80002310:	8082                	ret

0000000080002312 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002312:	7179                	addi	sp,sp,-48
    80002314:	f406                	sd	ra,40(sp)
    80002316:	f022                	sd	s0,32(sp)
    80002318:	ec26                	sd	s1,24(sp)
    8000231a:	e84a                	sd	s2,16(sp)
    8000231c:	e44e                	sd	s3,8(sp)
    8000231e:	1800                	addi	s0,sp,48
    80002320:	89aa                	mv	s3,a0
    80002322:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002324:	939ff0ef          	jal	80001c5c <myproc>
    80002328:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000232a:	a4ffe0ef          	jal	80000d78 <acquire>
  release(lk);
    8000232e:	854a                	mv	a0,s2
    80002330:	ae1fe0ef          	jal	80000e10 <release>

  // Go to sleep.
  p->chan = chan;
    80002334:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80002338:	4789                	li	a5,2
    8000233a:	d09c                	sw	a5,32(s1)

  sched();
    8000233c:	ef1ff0ef          	jal	8000222c <sched>

  // Tidy up.
  p->chan = 0;
    80002340:	0204b423          	sd	zero,40(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	acbfe0ef          	jal	80000e10 <release>
  acquire(lk);
    8000234a:	854a                	mv	a0,s2
    8000234c:	a2dfe0ef          	jal	80000d78 <acquire>
}
    80002350:	70a2                	ld	ra,40(sp)
    80002352:	7402                	ld	s0,32(sp)
    80002354:	64e2                	ld	s1,24(sp)
    80002356:	6942                	ld	s2,16(sp)
    80002358:	69a2                	ld	s3,8(sp)
    8000235a:	6145                	addi	sp,sp,48
    8000235c:	8082                	ret

000000008000235e <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void
wakeup(void *chan)
{
    8000235e:	7139                	addi	sp,sp,-64
    80002360:	fc06                	sd	ra,56(sp)
    80002362:	f822                	sd	s0,48(sp)
    80002364:	f426                	sd	s1,40(sp)
    80002366:	f04a                	sd	s2,32(sp)
    80002368:	ec4e                	sd	s3,24(sp)
    8000236a:	e852                	sd	s4,16(sp)
    8000236c:	e456                	sd	s5,8(sp)
    8000236e:	0080                	addi	s0,sp,64
    80002370:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002372:	0022f497          	auipc	s1,0x22f
    80002376:	ede48493          	addi	s1,s1,-290 # 80231250 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000237a:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000237c:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000237e:	00235917          	auipc	s2,0x235
    80002382:	0d290913          	addi	s2,s2,210 # 80237450 <tickslock>
    80002386:	a801                	j	80002396 <wakeup+0x38>
      }
      release(&p->lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	a87fe0ef          	jal	80000e10 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000238e:	18848493          	addi	s1,s1,392
    80002392:	03248263          	beq	s1,s2,800023b6 <wakeup+0x58>
    if(p != myproc()){
    80002396:	8c7ff0ef          	jal	80001c5c <myproc>
    8000239a:	fea48ae3          	beq	s1,a0,8000238e <wakeup+0x30>
      acquire(&p->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	9d9fe0ef          	jal	80000d78 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800023a4:	509c                	lw	a5,32(s1)
    800023a6:	ff3791e3          	bne	a5,s3,80002388 <wakeup+0x2a>
    800023aa:	749c                	ld	a5,40(s1)
    800023ac:	fd479ee3          	bne	a5,s4,80002388 <wakeup+0x2a>
        p->state = RUNNABLE;
    800023b0:	0354a023          	sw	s5,32(s1)
    800023b4:	bfd1                	j	80002388 <wakeup+0x2a>
    }
  }
}
    800023b6:	70e2                	ld	ra,56(sp)
    800023b8:	7442                	ld	s0,48(sp)
    800023ba:	74a2                	ld	s1,40(sp)
    800023bc:	7902                	ld	s2,32(sp)
    800023be:	69e2                	ld	s3,24(sp)
    800023c0:	6a42                	ld	s4,16(sp)
    800023c2:	6aa2                	ld	s5,8(sp)
    800023c4:	6121                	addi	sp,sp,64
    800023c6:	8082                	ret

00000000800023c8 <reparent>:
{
    800023c8:	7179                	addi	sp,sp,-48
    800023ca:	f406                	sd	ra,40(sp)
    800023cc:	f022                	sd	s0,32(sp)
    800023ce:	ec26                	sd	s1,24(sp)
    800023d0:	e84a                	sd	s2,16(sp)
    800023d2:	e44e                	sd	s3,8(sp)
    800023d4:	e052                	sd	s4,0(sp)
    800023d6:	1800                	addi	s0,sp,48
    800023d8:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023da:	0022f497          	auipc	s1,0x22f
    800023de:	e7648493          	addi	s1,s1,-394 # 80231250 <proc>
      pp->parent = initproc;
    800023e2:	00007a17          	auipc	s4,0x7
    800023e6:	90ea0a13          	addi	s4,s4,-1778 # 80008cf0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800023ea:	00235997          	auipc	s3,0x235
    800023ee:	06698993          	addi	s3,s3,102 # 80237450 <tickslock>
    800023f2:	a029                	j	800023fc <reparent+0x34>
    800023f4:	18848493          	addi	s1,s1,392
    800023f8:	01348b63          	beq	s1,s3,8000240e <reparent+0x46>
    if(pp->parent == p){
    800023fc:	60bc                	ld	a5,64(s1)
    800023fe:	ff279be3          	bne	a5,s2,800023f4 <reparent+0x2c>
      pp->parent = initproc;
    80002402:	000a3503          	ld	a0,0(s4)
    80002406:	e0a8                	sd	a0,64(s1)
      wakeup(initproc);
    80002408:	f57ff0ef          	jal	8000235e <wakeup>
    8000240c:	b7e5                	j	800023f4 <reparent+0x2c>
}
    8000240e:	70a2                	ld	ra,40(sp)
    80002410:	7402                	ld	s0,32(sp)
    80002412:	64e2                	ld	s1,24(sp)
    80002414:	6942                	ld	s2,16(sp)
    80002416:	69a2                	ld	s3,8(sp)
    80002418:	6a02                	ld	s4,0(sp)
    8000241a:	6145                	addi	sp,sp,48
    8000241c:	8082                	ret

000000008000241e <kexit>:
{
    8000241e:	7179                	addi	sp,sp,-48
    80002420:	f406                	sd	ra,40(sp)
    80002422:	f022                	sd	s0,32(sp)
    80002424:	ec26                	sd	s1,24(sp)
    80002426:	e84a                	sd	s2,16(sp)
    80002428:	e44e                	sd	s3,8(sp)
    8000242a:	e052                	sd	s4,0(sp)
    8000242c:	1800                	addi	s0,sp,48
    8000242e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002430:	82dff0ef          	jal	80001c5c <myproc>
    80002434:	89aa                	mv	s3,a0
  if(p == initproc)
    80002436:	00007797          	auipc	a5,0x7
    8000243a:	8ba7b783          	ld	a5,-1862(a5) # 80008cf0 <initproc>
    8000243e:	0d850493          	addi	s1,a0,216
    80002442:	15850913          	addi	s2,a0,344
    80002446:	00a79f63          	bne	a5,a0,80002464 <kexit+0x46>
    panic("init exiting");
    8000244a:	00006517          	auipc	a0,0x6
    8000244e:	dde50513          	addi	a0,a0,-546 # 80008228 <etext+0x228>
    80002452:	b8efe0ef          	jal	800007e0 <panic>
      fileclose(f);
    80002456:	3f0020ef          	jal	80004846 <fileclose>
      p->ofile[fd] = 0;
    8000245a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000245e:	04a1                	addi	s1,s1,8
    80002460:	01248563          	beq	s1,s2,8000246a <kexit+0x4c>
    if(p->ofile[fd]){
    80002464:	6088                	ld	a0,0(s1)
    80002466:	f965                	bnez	a0,80002456 <kexit+0x38>
    80002468:	bfdd                	j	8000245e <kexit+0x40>
  begin_op();
    8000246a:	7d1010ef          	jal	8000443a <begin_op>
  iput(p->cwd);
    8000246e:	1589b503          	ld	a0,344(s3)
    80002472:	760010ef          	jal	80003bd2 <iput>
  end_op();
    80002476:	02e020ef          	jal	800044a4 <end_op>
  p->cwd = 0;
    8000247a:	1409bc23          	sd	zero,344(s3)
  acquire(&wait_lock);
    8000247e:	0022f497          	auipc	s1,0x22f
    80002482:	9ba48493          	addi	s1,s1,-1606 # 80230e38 <wait_lock>
    80002486:	8526                	mv	a0,s1
    80002488:	8f1fe0ef          	jal	80000d78 <acquire>
  reparent(p);
    8000248c:	854e                	mv	a0,s3
    8000248e:	f3bff0ef          	jal	800023c8 <reparent>
  wakeup(p->parent);
    80002492:	0409b503          	ld	a0,64(s3)
    80002496:	ec9ff0ef          	jal	8000235e <wakeup>
  acquire(&p->lock);
    8000249a:	854e                	mv	a0,s3
    8000249c:	8ddfe0ef          	jal	80000d78 <acquire>
  p->xstate = status;
    800024a0:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800024a4:	4795                	li	a5,5
    800024a6:	02f9a023          	sw	a5,32(s3)
  release(&wait_lock);
    800024aa:	8526                	mv	a0,s1
    800024ac:	965fe0ef          	jal	80000e10 <release>
  sched();
    800024b0:	d7dff0ef          	jal	8000222c <sched>
  panic("zombie exit");
    800024b4:	00006517          	auipc	a0,0x6
    800024b8:	d8450513          	addi	a0,a0,-636 # 80008238 <etext+0x238>
    800024bc:	b24fe0ef          	jal	800007e0 <panic>

00000000800024c0 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    800024c0:	7179                	addi	sp,sp,-48
    800024c2:	f406                	sd	ra,40(sp)
    800024c4:	f022                	sd	s0,32(sp)
    800024c6:	ec26                	sd	s1,24(sp)
    800024c8:	e84a                	sd	s2,16(sp)
    800024ca:	e44e                	sd	s3,8(sp)
    800024cc:	1800                	addi	s0,sp,48
    800024ce:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800024d0:	0022f497          	auipc	s1,0x22f
    800024d4:	d8048493          	addi	s1,s1,-640 # 80231250 <proc>
    800024d8:	00235997          	auipc	s3,0x235
    800024dc:	f7898993          	addi	s3,s3,-136 # 80237450 <tickslock>
    acquire(&p->lock);
    800024e0:	8526                	mv	a0,s1
    800024e2:	897fe0ef          	jal	80000d78 <acquire>
    if(p->pid == pid){
    800024e6:	5c9c                	lw	a5,56(s1)
    800024e8:	01278b63          	beq	a5,s2,800024fe <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024ec:	8526                	mv	a0,s1
    800024ee:	923fe0ef          	jal	80000e10 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024f2:	18848493          	addi	s1,s1,392
    800024f6:	ff3495e3          	bne	s1,s3,800024e0 <kkill+0x20>
  }
  return -1;
    800024fa:	557d                	li	a0,-1
    800024fc:	a819                	j	80002512 <kkill+0x52>
      p->killed = 1;
    800024fe:	4785                	li	a5,1
    80002500:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80002502:	5098                	lw	a4,32(s1)
    80002504:	4789                	li	a5,2
    80002506:	00f70d63          	beq	a4,a5,80002520 <kkill+0x60>
      release(&p->lock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	905fe0ef          	jal	80000e10 <release>
      return 0;
    80002510:	4501                	li	a0,0
}
    80002512:	70a2                	ld	ra,40(sp)
    80002514:	7402                	ld	s0,32(sp)
    80002516:	64e2                	ld	s1,24(sp)
    80002518:	6942                	ld	s2,16(sp)
    8000251a:	69a2                	ld	s3,8(sp)
    8000251c:	6145                	addi	sp,sp,48
    8000251e:	8082                	ret
        p->state = RUNNABLE;
    80002520:	478d                	li	a5,3
    80002522:	d09c                	sw	a5,32(s1)
    80002524:	b7dd                	j	8000250a <kkill+0x4a>

0000000080002526 <setkilled>:

void
setkilled(struct proc *p)
{
    80002526:	1101                	addi	sp,sp,-32
    80002528:	ec06                	sd	ra,24(sp)
    8000252a:	e822                	sd	s0,16(sp)
    8000252c:	e426                	sd	s1,8(sp)
    8000252e:	1000                	addi	s0,sp,32
    80002530:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002532:	847fe0ef          	jal	80000d78 <acquire>
  p->killed = 1;
    80002536:	4785                	li	a5,1
    80002538:	d89c                	sw	a5,48(s1)
  release(&p->lock);
    8000253a:	8526                	mv	a0,s1
    8000253c:	8d5fe0ef          	jal	80000e10 <release>
}
    80002540:	60e2                	ld	ra,24(sp)
    80002542:	6442                	ld	s0,16(sp)
    80002544:	64a2                	ld	s1,8(sp)
    80002546:	6105                	addi	sp,sp,32
    80002548:	8082                	ret

000000008000254a <killed>:

int
killed(struct proc *p)
{
    8000254a:	1101                	addi	sp,sp,-32
    8000254c:	ec06                	sd	ra,24(sp)
    8000254e:	e822                	sd	s0,16(sp)
    80002550:	e426                	sd	s1,8(sp)
    80002552:	e04a                	sd	s2,0(sp)
    80002554:	1000                	addi	s0,sp,32
    80002556:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002558:	821fe0ef          	jal	80000d78 <acquire>
  k = p->killed;
    8000255c:	0304a903          	lw	s2,48(s1)
  release(&p->lock);
    80002560:	8526                	mv	a0,s1
    80002562:	8affe0ef          	jal	80000e10 <release>
  return k;
}
    80002566:	854a                	mv	a0,s2
    80002568:	60e2                	ld	ra,24(sp)
    8000256a:	6442                	ld	s0,16(sp)
    8000256c:	64a2                	ld	s1,8(sp)
    8000256e:	6902                	ld	s2,0(sp)
    80002570:	6105                	addi	sp,sp,32
    80002572:	8082                	ret

0000000080002574 <kwait>:
{
    80002574:	715d                	addi	sp,sp,-80
    80002576:	e486                	sd	ra,72(sp)
    80002578:	e0a2                	sd	s0,64(sp)
    8000257a:	fc26                	sd	s1,56(sp)
    8000257c:	f84a                	sd	s2,48(sp)
    8000257e:	f44e                	sd	s3,40(sp)
    80002580:	f052                	sd	s4,32(sp)
    80002582:	ec56                	sd	s5,24(sp)
    80002584:	e85a                	sd	s6,16(sp)
    80002586:	e45e                	sd	s7,8(sp)
    80002588:	e062                	sd	s8,0(sp)
    8000258a:	0880                	addi	s0,sp,80
    8000258c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000258e:	eceff0ef          	jal	80001c5c <myproc>
    80002592:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002594:	0022f517          	auipc	a0,0x22f
    80002598:	8a450513          	addi	a0,a0,-1884 # 80230e38 <wait_lock>
    8000259c:	fdcfe0ef          	jal	80000d78 <acquire>
    havekids = 0;
    800025a0:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800025a2:	4a15                	li	s4,5
        havekids = 1;
    800025a4:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800025a6:	00235997          	auipc	s3,0x235
    800025aa:	eaa98993          	addi	s3,s3,-342 # 80237450 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800025ae:	0022fc17          	auipc	s8,0x22f
    800025b2:	88ac0c13          	addi	s8,s8,-1910 # 80230e38 <wait_lock>
    800025b6:	a871                	j	80002652 <kwait+0xde>
          pid = pp->pid;
    800025b8:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800025bc:	000b0c63          	beqz	s6,800025d4 <kwait+0x60>
    800025c0:	4691                	li	a3,4
    800025c2:	03448613          	addi	a2,s1,52
    800025c6:	85da                	mv	a1,s6
    800025c8:	05893503          	ld	a0,88(s2)
    800025cc:	a00ff0ef          	jal	800017cc <copyout>
    800025d0:	02054b63          	bltz	a0,80002606 <kwait+0x92>
          freeproc(pp);
    800025d4:	8526                	mv	a0,s1
    800025d6:	857ff0ef          	jal	80001e2c <freeproc>
          release(&pp->lock);
    800025da:	8526                	mv	a0,s1
    800025dc:	835fe0ef          	jal	80000e10 <release>
          release(&wait_lock);
    800025e0:	0022f517          	auipc	a0,0x22f
    800025e4:	85850513          	addi	a0,a0,-1960 # 80230e38 <wait_lock>
    800025e8:	829fe0ef          	jal	80000e10 <release>
}
    800025ec:	854e                	mv	a0,s3
    800025ee:	60a6                	ld	ra,72(sp)
    800025f0:	6406                	ld	s0,64(sp)
    800025f2:	74e2                	ld	s1,56(sp)
    800025f4:	7942                	ld	s2,48(sp)
    800025f6:	79a2                	ld	s3,40(sp)
    800025f8:	7a02                	ld	s4,32(sp)
    800025fa:	6ae2                	ld	s5,24(sp)
    800025fc:	6b42                	ld	s6,16(sp)
    800025fe:	6ba2                	ld	s7,8(sp)
    80002600:	6c02                	ld	s8,0(sp)
    80002602:	6161                	addi	sp,sp,80
    80002604:	8082                	ret
            release(&pp->lock);
    80002606:	8526                	mv	a0,s1
    80002608:	809fe0ef          	jal	80000e10 <release>
            release(&wait_lock);
    8000260c:	0022f517          	auipc	a0,0x22f
    80002610:	82c50513          	addi	a0,a0,-2004 # 80230e38 <wait_lock>
    80002614:	ffcfe0ef          	jal	80000e10 <release>
            return -1;
    80002618:	59fd                	li	s3,-1
    8000261a:	bfc9                	j	800025ec <kwait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000261c:	18848493          	addi	s1,s1,392
    80002620:	03348063          	beq	s1,s3,80002640 <kwait+0xcc>
      if(pp->parent == p){
    80002624:	60bc                	ld	a5,64(s1)
    80002626:	ff279be3          	bne	a5,s2,8000261c <kwait+0xa8>
        acquire(&pp->lock);
    8000262a:	8526                	mv	a0,s1
    8000262c:	f4cfe0ef          	jal	80000d78 <acquire>
        if(pp->state == ZOMBIE){
    80002630:	509c                	lw	a5,32(s1)
    80002632:	f94783e3          	beq	a5,s4,800025b8 <kwait+0x44>
        release(&pp->lock);
    80002636:	8526                	mv	a0,s1
    80002638:	fd8fe0ef          	jal	80000e10 <release>
        havekids = 1;
    8000263c:	8756                	mv	a4,s5
    8000263e:	bff9                	j	8000261c <kwait+0xa8>
    if(!havekids || killed(p)){
    80002640:	cf19                	beqz	a4,8000265e <kwait+0xea>
    80002642:	854a                	mv	a0,s2
    80002644:	f07ff0ef          	jal	8000254a <killed>
    80002648:	e919                	bnez	a0,8000265e <kwait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000264a:	85e2                	mv	a1,s8
    8000264c:	854a                	mv	a0,s2
    8000264e:	cc5ff0ef          	jal	80002312 <sleep>
    havekids = 0;
    80002652:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002654:	0022f497          	auipc	s1,0x22f
    80002658:	bfc48493          	addi	s1,s1,-1028 # 80231250 <proc>
    8000265c:	b7e1                	j	80002624 <kwait+0xb0>
      release(&wait_lock);
    8000265e:	0022e517          	auipc	a0,0x22e
    80002662:	7da50513          	addi	a0,a0,2010 # 80230e38 <wait_lock>
    80002666:	faafe0ef          	jal	80000e10 <release>
      return -1;
    8000266a:	59fd                	li	s3,-1
    8000266c:	b741                	j	800025ec <kwait+0x78>

000000008000266e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000266e:	7179                	addi	sp,sp,-48
    80002670:	f406                	sd	ra,40(sp)
    80002672:	f022                	sd	s0,32(sp)
    80002674:	ec26                	sd	s1,24(sp)
    80002676:	e84a                	sd	s2,16(sp)
    80002678:	e44e                	sd	s3,8(sp)
    8000267a:	e052                	sd	s4,0(sp)
    8000267c:	1800                	addi	s0,sp,48
    8000267e:	84aa                	mv	s1,a0
    80002680:	892e                	mv	s2,a1
    80002682:	89b2                	mv	s3,a2
    80002684:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002686:	dd6ff0ef          	jal	80001c5c <myproc>
  if(user_dst){
    8000268a:	cc99                	beqz	s1,800026a8 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    8000268c:	86d2                	mv	a3,s4
    8000268e:	864e                	mv	a2,s3
    80002690:	85ca                	mv	a1,s2
    80002692:	6d28                	ld	a0,88(a0)
    80002694:	938ff0ef          	jal	800017cc <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002698:	70a2                	ld	ra,40(sp)
    8000269a:	7402                	ld	s0,32(sp)
    8000269c:	64e2                	ld	s1,24(sp)
    8000269e:	6942                	ld	s2,16(sp)
    800026a0:	69a2                	ld	s3,8(sp)
    800026a2:	6a02                	ld	s4,0(sp)
    800026a4:	6145                	addi	sp,sp,48
    800026a6:	8082                	ret
    memmove((char *)dst, src, len);
    800026a8:	000a061b          	sext.w	a2,s4
    800026ac:	85ce                	mv	a1,s3
    800026ae:	854a                	mv	a0,s2
    800026b0:	ff8fe0ef          	jal	80000ea8 <memmove>
    return 0;
    800026b4:	8526                	mv	a0,s1
    800026b6:	b7cd                	j	80002698 <either_copyout+0x2a>

00000000800026b8 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800026b8:	7179                	addi	sp,sp,-48
    800026ba:	f406                	sd	ra,40(sp)
    800026bc:	f022                	sd	s0,32(sp)
    800026be:	ec26                	sd	s1,24(sp)
    800026c0:	e84a                	sd	s2,16(sp)
    800026c2:	e44e                	sd	s3,8(sp)
    800026c4:	e052                	sd	s4,0(sp)
    800026c6:	1800                	addi	s0,sp,48
    800026c8:	892a                	mv	s2,a0
    800026ca:	84ae                	mv	s1,a1
    800026cc:	89b2                	mv	s3,a2
    800026ce:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800026d0:	d8cff0ef          	jal	80001c5c <myproc>
  if(user_src){
    800026d4:	cc99                	beqz	s1,800026f2 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800026d6:	86d2                	mv	a3,s4
    800026d8:	864e                	mv	a2,s3
    800026da:	85ca                	mv	a1,s2
    800026dc:	6d28                	ld	a0,88(a0)
    800026de:	9d2ff0ef          	jal	800018b0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800026e2:	70a2                	ld	ra,40(sp)
    800026e4:	7402                	ld	s0,32(sp)
    800026e6:	64e2                	ld	s1,24(sp)
    800026e8:	6942                	ld	s2,16(sp)
    800026ea:	69a2                	ld	s3,8(sp)
    800026ec:	6a02                	ld	s4,0(sp)
    800026ee:	6145                	addi	sp,sp,48
    800026f0:	8082                	ret
    memmove(dst, (char*)src, len);
    800026f2:	000a061b          	sext.w	a2,s4
    800026f6:	85ce                	mv	a1,s3
    800026f8:	854a                	mv	a0,s2
    800026fa:	faefe0ef          	jal	80000ea8 <memmove>
    return 0;
    800026fe:	8526                	mv	a0,s1
    80002700:	b7cd                	j	800026e2 <either_copyin+0x2a>

0000000080002702 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002702:	715d                	addi	sp,sp,-80
    80002704:	e486                	sd	ra,72(sp)
    80002706:	e0a2                	sd	s0,64(sp)
    80002708:	fc26                	sd	s1,56(sp)
    8000270a:	f84a                	sd	s2,48(sp)
    8000270c:	f44e                	sd	s3,40(sp)
    8000270e:	f052                	sd	s4,32(sp)
    80002710:	ec56                	sd	s5,24(sp)
    80002712:	e85a                	sd	s6,16(sp)
    80002714:	e45e                	sd	s7,8(sp)
    80002716:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002718:	00006517          	auipc	a0,0x6
    8000271c:	96850513          	addi	a0,a0,-1688 # 80008080 <etext+0x80>
    80002720:	ddbfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002724:	0022f497          	auipc	s1,0x22f
    80002728:	c8c48493          	addi	s1,s1,-884 # 802313b0 <proc+0x160>
    8000272c:	00235917          	auipc	s2,0x235
    80002730:	e8490913          	addi	s2,s2,-380 # 802375b0 <bcache+0x130>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002734:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002736:	00006997          	auipc	s3,0x6
    8000273a:	b1298993          	addi	s3,s3,-1262 # 80008248 <etext+0x248>
    printf("%d %s %s", p->pid, state, p->name);
    8000273e:	00006a97          	auipc	s5,0x6
    80002742:	b12a8a93          	addi	s5,s5,-1262 # 80008250 <etext+0x250>
    printf("\n");
    80002746:	00006a17          	auipc	s4,0x6
    8000274a:	93aa0a13          	addi	s4,s4,-1734 # 80008080 <etext+0x80>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000274e:	00006b97          	auipc	s7,0x6
    80002752:	422b8b93          	addi	s7,s7,1058 # 80008b70 <states.0>
    80002756:	a829                	j	80002770 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002758:	ed86a583          	lw	a1,-296(a3)
    8000275c:	8556                	mv	a0,s5
    8000275e:	d9dfd0ef          	jal	800004fa <printf>
    printf("\n");
    80002762:	8552                	mv	a0,s4
    80002764:	d97fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002768:	18848493          	addi	s1,s1,392
    8000276c:	03248263          	beq	s1,s2,80002790 <procdump+0x8e>
    if(p->state == UNUSED)
    80002770:	86a6                	mv	a3,s1
    80002772:	ec04a783          	lw	a5,-320(s1)
    80002776:	dbed                	beqz	a5,80002768 <procdump+0x66>
      state = "???";
    80002778:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000277a:	fcfb6fe3          	bltu	s6,a5,80002758 <procdump+0x56>
    8000277e:	02079713          	slli	a4,a5,0x20
    80002782:	01d75793          	srli	a5,a4,0x1d
    80002786:	97de                	add	a5,a5,s7
    80002788:	6390                	ld	a2,0(a5)
    8000278a:	f679                	bnez	a2,80002758 <procdump+0x56>
      state = "???";
    8000278c:	864e                	mv	a2,s3
    8000278e:	b7e9                	j	80002758 <procdump+0x56>
  }
}
    80002790:	60a6                	ld	ra,72(sp)
    80002792:	6406                	ld	s0,64(sp)
    80002794:	74e2                	ld	s1,56(sp)
    80002796:	7942                	ld	s2,48(sp)
    80002798:	79a2                	ld	s3,40(sp)
    8000279a:	7a02                	ld	s4,32(sp)
    8000279c:	6ae2                	ld	s5,24(sp)
    8000279e:	6b42                	ld	s6,16(sp)
    800027a0:	6ba2                	ld	s7,8(sp)
    800027a2:	6161                	addi	sp,sp,80
    800027a4:	8082                	ret

00000000800027a6 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800027a6:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800027aa:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800027ae:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800027b0:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800027b2:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800027b6:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800027ba:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800027be:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800027c2:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800027c6:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800027ca:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800027ce:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800027d2:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800027d6:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800027da:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800027de:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800027e2:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800027e4:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800027e6:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800027ea:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800027ee:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800027f2:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800027f6:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800027fa:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800027fe:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002802:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002806:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000280a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000280e:	8082                	ret

0000000080002810 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002810:	1141                	addi	sp,sp,-16
    80002812:	e406                	sd	ra,8(sp)
    80002814:	e022                	sd	s0,0(sp)
    80002816:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002818:	00006597          	auipc	a1,0x6
    8000281c:	a7858593          	addi	a1,a1,-1416 # 80008290 <etext+0x290>
    80002820:	00235517          	auipc	a0,0x235
    80002824:	c3050513          	addi	a0,a0,-976 # 80237450 <tickslock>
    80002828:	cd0fe0ef          	jal	80000cf8 <initlock>
}
    8000282c:	60a2                	ld	ra,8(sp)
    8000282e:	6402                	ld	s0,0(sp)
    80002830:	0141                	addi	sp,sp,16
    80002832:	8082                	ret

0000000080002834 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002834:	1141                	addi	sp,sp,-16
    80002836:	e422                	sd	s0,8(sp)
    80002838:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000283a:	00003797          	auipc	a5,0x3
    8000283e:	38678793          	addi	a5,a5,902 # 80005bc0 <kernelvec>
    80002842:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002846:	6422                	ld	s0,8(sp)
    80002848:	0141                	addi	sp,sp,16
    8000284a:	8082                	ret

000000008000284c <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    8000284c:	1141                	addi	sp,sp,-16
    8000284e:	e406                	sd	ra,8(sp)
    80002850:	e022                	sd	s0,0(sp)
    80002852:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002854:	c08ff0ef          	jal	80001c5c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002858:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000285c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000285e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002862:	04000737          	lui	a4,0x4000
    80002866:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002868:	0732                	slli	a4,a4,0xc
    8000286a:	00004797          	auipc	a5,0x4
    8000286e:	79678793          	addi	a5,a5,1942 # 80007000 <_trampoline>
    80002872:	00004697          	auipc	a3,0x4
    80002876:	78e68693          	addi	a3,a3,1934 # 80007000 <_trampoline>
    8000287a:	8f95                	sub	a5,a5,a3
    8000287c:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000287e:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002882:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002884:	18002773          	csrr	a4,satp
    80002888:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000288a:	7138                	ld	a4,96(a0)
    8000288c:	653c                	ld	a5,72(a0)
    8000288e:	6685                	lui	a3,0x1
    80002890:	97b6                	add	a5,a5,a3
    80002892:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002894:	713c                	ld	a5,96(a0)
    80002896:	00000717          	auipc	a4,0x0
    8000289a:	0f870713          	addi	a4,a4,248 # 8000298e <usertrap>
    8000289e:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800028a0:	713c                	ld	a5,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800028a2:	8712                	mv	a4,tp
    800028a4:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a6:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800028aa:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800028ae:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028b2:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800028b6:	713c                	ld	a5,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800028b8:	6f9c                	ld	a5,24(a5)
    800028ba:	14179073          	csrw	sepc,a5
}
    800028be:	60a2                	ld	ra,8(sp)
    800028c0:	6402                	ld	s0,0(sp)
    800028c2:	0141                	addi	sp,sp,16
    800028c4:	8082                	ret

00000000800028c6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800028c6:	1101                	addi	sp,sp,-32
    800028c8:	ec06                	sd	ra,24(sp)
    800028ca:	e822                	sd	s0,16(sp)
    800028cc:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800028ce:	b62ff0ef          	jal	80001c30 <cpuid>
    800028d2:	cd11                	beqz	a0,800028ee <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800028d4:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800028d8:	000f4737          	lui	a4,0xf4
    800028dc:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800028e0:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800028e2:	14d79073          	csrw	stimecmp,a5
}
    800028e6:	60e2                	ld	ra,24(sp)
    800028e8:	6442                	ld	s0,16(sp)
    800028ea:	6105                	addi	sp,sp,32
    800028ec:	8082                	ret
    800028ee:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800028f0:	00235497          	auipc	s1,0x235
    800028f4:	b6048493          	addi	s1,s1,-1184 # 80237450 <tickslock>
    800028f8:	8526                	mv	a0,s1
    800028fa:	c7efe0ef          	jal	80000d78 <acquire>
    ticks++;
    800028fe:	00006517          	auipc	a0,0x6
    80002902:	3fe50513          	addi	a0,a0,1022 # 80008cfc <ticks>
    80002906:	411c                	lw	a5,0(a0)
    80002908:	2785                	addiw	a5,a5,1
    8000290a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000290c:	a53ff0ef          	jal	8000235e <wakeup>
    release(&tickslock);
    80002910:	8526                	mv	a0,s1
    80002912:	cfefe0ef          	jal	80000e10 <release>
    80002916:	64a2                	ld	s1,8(sp)
    80002918:	bf75                	j	800028d4 <clockintr+0xe>

000000008000291a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000291a:	1101                	addi	sp,sp,-32
    8000291c:	ec06                	sd	ra,24(sp)
    8000291e:	e822                	sd	s0,16(sp)
    80002920:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002922:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002926:	57fd                	li	a5,-1
    80002928:	17fe                	slli	a5,a5,0x3f
    8000292a:	07a5                	addi	a5,a5,9
    8000292c:	00f70c63          	beq	a4,a5,80002944 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002930:	57fd                	li	a5,-1
    80002932:	17fe                	slli	a5,a5,0x3f
    80002934:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002936:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002938:	04f70763          	beq	a4,a5,80002986 <devintr+0x6c>
  }
}
    8000293c:	60e2                	ld	ra,24(sp)
    8000293e:	6442                	ld	s0,16(sp)
    80002940:	6105                	addi	sp,sp,32
    80002942:	8082                	ret
    80002944:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002946:	326030ef          	jal	80005c6c <plic_claim>
    8000294a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000294c:	47a9                	li	a5,10
    8000294e:	00f50963          	beq	a0,a5,80002960 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002952:	4785                	li	a5,1
    80002954:	00f50963          	beq	a0,a5,80002966 <devintr+0x4c>
    return 1;
    80002958:	4505                	li	a0,1
    } else if(irq){
    8000295a:	e889                	bnez	s1,8000296c <devintr+0x52>
    8000295c:	64a2                	ld	s1,8(sp)
    8000295e:	bff9                	j	8000293c <devintr+0x22>
      uartintr();
    80002960:	850fe0ef          	jal	800009b0 <uartintr>
    if(irq)
    80002964:	a819                	j	8000297a <devintr+0x60>
      virtio_disk_intr();
    80002966:	7cc030ef          	jal	80006132 <virtio_disk_intr>
    if(irq)
    8000296a:	a801                	j	8000297a <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000296c:	85a6                	mv	a1,s1
    8000296e:	00006517          	auipc	a0,0x6
    80002972:	92a50513          	addi	a0,a0,-1750 # 80008298 <etext+0x298>
    80002976:	b85fd0ef          	jal	800004fa <printf>
      plic_complete(irq);
    8000297a:	8526                	mv	a0,s1
    8000297c:	310030ef          	jal	80005c8c <plic_complete>
    return 1;
    80002980:	4505                	li	a0,1
    80002982:	64a2                	ld	s1,8(sp)
    80002984:	bf65                	j	8000293c <devintr+0x22>
    clockintr();
    80002986:	f41ff0ef          	jal	800028c6 <clockintr>
    return 2;
    8000298a:	4509                	li	a0,2
    8000298c:	bf45                	j	8000293c <devintr+0x22>

000000008000298e <usertrap>:
{
    8000298e:	7179                	addi	sp,sp,-48
    80002990:	f406                	sd	ra,40(sp)
    80002992:	f022                	sd	s0,32(sp)
    80002994:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002996:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000299a:	1007f793          	andi	a5,a5,256
    8000299e:	efc5                	bnez	a5,80002a56 <usertrap+0xc8>
    800029a0:	ec26                	sd	s1,24(sp)
    800029a2:	e84a                	sd	s2,16(sp)
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029a4:	00003797          	auipc	a5,0x3
    800029a8:	21c78793          	addi	a5,a5,540 # 80005bc0 <kernelvec>
    800029ac:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800029b0:	aacff0ef          	jal	80001c5c <myproc>
    800029b4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800029b6:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029b8:	14102773          	csrr	a4,sepc
    800029bc:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029be:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800029c2:	47a1                	li	a5,8
    800029c4:	0af70263          	beq	a4,a5,80002a68 <usertrap+0xda>
} else if((which_dev = devintr()) != 0){
    800029c8:	f53ff0ef          	jal	8000291a <devintr>
    800029cc:	892a                	mv	s2,a0
    800029ce:	1e051e63          	bnez	a0,80002bca <usertrap+0x23c>
    800029d2:	14202773          	csrr	a4,scause
  else if((r_scause() == 15 || r_scause() == 13) && r_stval() >= 0x80000000) {
    800029d6:	47bd                	li	a5,15
    800029d8:	0cf70d63          	beq	a4,a5,80002ab2 <usertrap+0x124>
    800029dc:	14202773          	csrr	a4,scause
    800029e0:	47b5                	li	a5,13
    800029e2:	0cf70863          	beq	a4,a5,80002ab2 <usertrap+0x124>
    800029e6:	14202773          	csrr	a4,scause
} else if(r_scause() == 15 || r_scause() == 13) {
    800029ea:	47bd                	li	a5,15
    800029ec:	00f70763          	beq	a4,a5,800029fa <usertrap+0x6c>
    800029f0:	14202773          	csrr	a4,scause
    800029f4:	47b5                	li	a5,13
    800029f6:	1af71363          	bne	a4,a5,80002b9c <usertrap+0x20e>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029fa:	14302973          	csrr	s2,stval
    if(va >= p->sz || PGROUNDDOWN(va) == 0) {
    800029fe:	68bc                	ld	a5,80(s1)
    80002a00:	00f97563          	bgeu	s2,a5,80002a0a <usertrap+0x7c>
    80002a04:	6785                	lui	a5,0x1
    80002a06:	14f97763          	bgeu	s2,a5,80002b54 <usertrap+0x1c6>
    80002a0a:	e44e                	sd	s3,8(sp)
      global_stride_faults++; // CHỈ TĂNG Ở ĐÂY KHI CÓ HÀNH VI PHÁ HOẠI CỐ Ý
    80002a0c:	00006997          	auipc	s3,0x6
    80002a10:	2ec98993          	addi	s3,s3,748 # 80008cf8 <global_stride_faults.0>
    80002a14:	0009a783          	lw	a5,0(s3)
    80002a18:	2785                	addiw	a5,a5,1 # 1001 <_entry-0x7fffefff>
    80002a1a:	00f9a023          	sw	a5,0(s3)
      printf("\n[CANH BAO STRIDE] Tien trinh '%s' (PID: %d) vi pham truy cap bo nho! (VA: 0x%lx)\n", p->name, p->pid, va);
    80002a1e:	86ca                	mv	a3,s2
    80002a20:	5c90                	lw	a2,56(s1)
    80002a22:	16048593          	addi	a1,s1,352
    80002a26:	00006517          	auipc	a0,0x6
    80002a2a:	a1a50513          	addi	a0,a0,-1510 # 80008440 <etext+0x440>
    80002a2e:	acdfd0ef          	jal	800004fa <printf>
      printf("[STRIDE LOG] He thong ghi nhan dot vi pham lien tiep thu: %d/3\n", global_stride_faults);
    80002a32:	0009a583          	lw	a1,0(s3)
    80002a36:	00006517          	auipc	a0,0x6
    80002a3a:	a6250513          	addi	a0,a0,-1438 # 80008498 <etext+0x498>
    80002a3e:	abdfd0ef          	jal	800004fa <printf>
      if(global_stride_faults >= 3) {
    80002a42:	0009a703          	lw	a4,0(s3)
    80002a46:	4789                	li	a5,2
    80002a48:	0ee7cb63          	blt	a5,a4,80002b3e <usertrap+0x1b0>
      setkilled(p);
    80002a4c:	8526                	mv	a0,s1
    80002a4e:	ad9ff0ef          	jal	80002526 <setkilled>
    80002a52:	69a2                	ld	s3,8(sp)
    80002a54:	a80d                	j	80002a86 <usertrap+0xf8>
    80002a56:	ec26                	sd	s1,24(sp)
    80002a58:	e84a                	sd	s2,16(sp)
    80002a5a:	e44e                	sd	s3,8(sp)
    panic("usertrap: not from user mode");
    80002a5c:	00006517          	auipc	a0,0x6
    80002a60:	88450513          	addi	a0,a0,-1916 # 800082e0 <etext+0x2e0>
    80002a64:	d7dfd0ef          	jal	800007e0 <panic>
    if(killed(p))
    80002a68:	ae3ff0ef          	jal	8000254a <killed>
    80002a6c:	ed1d                	bnez	a0,80002aaa <usertrap+0x11c>
    p->trapframe->epc += 4;
    80002a6e:	70b8                	ld	a4,96(s1)
    80002a70:	6f1c                	ld	a5,24(a4)
    80002a72:	0791                	addi	a5,a5,4
    80002a74:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a76:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002a7a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a7e:	10079073          	csrw	sstatus,a5
    syscall();
    80002a82:	348000ef          	jal	80002dca <syscall>
  if(killed(p))
    80002a86:	8526                	mv	a0,s1
    80002a88:	ac3ff0ef          	jal	8000254a <killed>
    80002a8c:	14051463          	bnez	a0,80002bd4 <usertrap+0x246>
  prepare_return();
    80002a90:	dbdff0ef          	jal	8000284c <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002a94:	6ca8                	ld	a0,88(s1)
    80002a96:	8131                	srli	a0,a0,0xc
    80002a98:	57fd                	li	a5,-1
    80002a9a:	17fe                	slli	a5,a5,0x3f
    80002a9c:	8d5d                	or	a0,a0,a5
}
    80002a9e:	64e2                	ld	s1,24(sp)
    80002aa0:	6942                	ld	s2,16(sp)
    80002aa2:	70a2                	ld	ra,40(sp)
    80002aa4:	7402                	ld	s0,32(sp)
    80002aa6:	6145                	addi	sp,sp,48
    80002aa8:	8082                	ret
      kexit(-1);
    80002aaa:	557d                	li	a0,-1
    80002aac:	973ff0ef          	jal	8000241e <kexit>
    80002ab0:	bf7d                	j	80002a6e <usertrap+0xe0>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ab2:	14302773          	csrr	a4,stval
  else if((r_scause() == 15 || r_scause() == 13) && r_stval() >= 0x80000000) {
    80002ab6:	800007b7          	lui	a5,0x80000
    80002aba:	fff7c793          	not	a5,a5
    80002abe:	f2e7f4e3          	bgeu	a5,a4,800029e6 <usertrap+0x58>
    80002ac2:	e44e                	sd	s3,8(sp)
    80002ac4:	143029f3          	csrr	s3,stval
    struct proc *p = myproc();
    80002ac8:	994ff0ef          	jal	80001c5c <myproc>
    80002acc:	892a                	mv	s2,a0
    printf("\n[KLOGGER ALERT] !!! PHAT HIEN HANH VI TAN CONG HE THONG !!!\n");
    80002ace:	00006517          	auipc	a0,0x6
    80002ad2:	83250513          	addi	a0,a0,-1998 # 80008300 <etext+0x300>
    80002ad6:	a25fd0ef          	jal	800004fa <printf>
    printf("[KLOGGER LOG] Tien trinh vi pham: '%s' (PID: %d)\n", p->name, p->pid);
    80002ada:	03892603          	lw	a2,56(s2)
    80002ade:	16090593          	addi	a1,s2,352
    80002ae2:	00006517          	auipc	a0,0x6
    80002ae6:	85e50513          	addi	a0,a0,-1954 # 80008340 <etext+0x340>
    80002aea:	a11fd0ef          	jal	800004fa <printf>
    printf("[KLOGGER LOG] Dia chi Kernel bi nham toi: 0x%lx\n", va);
    80002aee:	85ce                	mv	a1,s3
    80002af0:	00006517          	auipc	a0,0x6
    80002af4:	88850513          	addi	a0,a0,-1912 # 80008378 <etext+0x378>
    80002af8:	a03fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002afc:	142025f3          	csrr	a1,scause
    80002b00:	14202773          	csrr	a4,scause
    printf("[KLOGGER LOG] Ma loi phan cung (scause): %ld (%s)\n", 
    80002b04:	47bd                	li	a5,15
    80002b06:	00005617          	auipc	a2,0x5
    80002b0a:	7ca60613          	addi	a2,a2,1994 # 800082d0 <etext+0x2d0>
    80002b0e:	02f70363          	beq	a4,a5,80002b34 <usertrap+0x1a6>
    80002b12:	00006517          	auipc	a0,0x6
    80002b16:	89e50513          	addi	a0,a0,-1890 # 800083b0 <etext+0x3b0>
    80002b1a:	9e1fd0ef          	jal	800004fa <printf>
    printf("[KLOGGER ACTION] Kich hoat co che bao ve bang trang, HANH QUYET TIEN TRINH LAP TUC!\n\n");
    80002b1e:	00006517          	auipc	a0,0x6
    80002b22:	8ca50513          	addi	a0,a0,-1846 # 800083e8 <etext+0x3e8>
    80002b26:	9d5fd0ef          	jal	800004fa <printf>
    setkilled(p); // Đánh dấu tiêu diệt tiến trình vi phạm
    80002b2a:	854a                	mv	a0,s2
    80002b2c:	9fbff0ef          	jal	80002526 <setkilled>
  else if((r_scause() == 15 || r_scause() == 13) && r_stval() >= 0x80000000) {
    80002b30:	69a2                	ld	s3,8(sp)
    80002b32:	bf91                	j	80002a86 <usertrap+0xf8>
    printf("[KLOGGER LOG] Ma loi phan cung (scause): %ld (%s)\n", 
    80002b34:	00005617          	auipc	a2,0x5
    80002b38:	78460613          	addi	a2,a2,1924 # 800082b8 <etext+0x2b8>
    80002b3c:	bfd9                	j	80002b12 <usertrap+0x184>
        printf("[KILL ON SIGHT] Kich hoat co che hanh quyet tu dong de bao ve toan ven he thong!\n");
    80002b3e:	00006517          	auipc	a0,0x6
    80002b42:	99a50513          	addi	a0,a0,-1638 # 800084d8 <etext+0x4d8>
    80002b46:	9b5fd0ef          	jal	800004fa <printf>
        global_stride_faults = 0; // Reset ngay sau khi xử lý mối đe dọa
    80002b4a:	00006797          	auipc	a5,0x6
    80002b4e:	1a07a723          	sw	zero,430(a5) # 80008cf8 <global_stride_faults.0>
    80002b52:	bded                	j	80002a4c <usertrap+0xbe>
    80002b54:	14202773          	csrr	a4,scause
    else if(r_scause() == 15 && cow_handler(p->pagetable, va) == 0) {
    80002b58:	47bd                	li	a5,15
    80002b5a:	02f70a63          	beq	a4,a5,80002b8e <usertrap+0x200>
    80002b5e:	14202673          	csrr	a2,scause
    else if(vmfault(p->pagetable, va, (r_scause() == 13) ? 1 : 0) != 0) {
    80002b62:	164d                	addi	a2,a2,-13
    80002b64:	00163613          	seqz	a2,a2
    80002b68:	85ca                	mv	a1,s2
    80002b6a:	6ca8                	ld	a0,88(s1)
    80002b6c:	bdffe0ef          	jal	8000174a <vmfault>
    80002b70:	f0051be3          	bnez	a0,80002a86 <usertrap+0xf8>
      printf("\n[HE THONG] Page Fault khong the cuu van tren '%s' (PID: %d)\n", p->name, p->pid);
    80002b74:	5c90                	lw	a2,56(s1)
    80002b76:	16048593          	addi	a1,s1,352
    80002b7a:	00006517          	auipc	a0,0x6
    80002b7e:	9b650513          	addi	a0,a0,-1610 # 80008530 <etext+0x530>
    80002b82:	979fd0ef          	jal	800004fa <printf>
      setkilled(p);
    80002b86:	8526                	mv	a0,s1
    80002b88:	99fff0ef          	jal	80002526 <setkilled>
    80002b8c:	bded                	j	80002a86 <usertrap+0xf8>
    else if(r_scause() == 15 && cow_handler(p->pagetable, va) == 0) {
    80002b8e:	85ca                	mv	a1,s2
    80002b90:	6ca8                	ld	a0,88(s1)
    80002b92:	f0ffe0ef          	jal	80001aa0 <cow_handler>
    80002b96:	ee0508e3          	beqz	a0,80002a86 <usertrap+0xf8>
    80002b9a:	b7d1                	j	80002b5e <usertrap+0x1d0>
    80002b9c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002ba0:	5c90                	lw	a2,56(s1)
    80002ba2:	00006517          	auipc	a0,0x6
    80002ba6:	9ce50513          	addi	a0,a0,-1586 # 80008570 <etext+0x570>
    80002baa:	951fd0ef          	jal	800004fa <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bae:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bb2:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002bb6:	00006517          	auipc	a0,0x6
    80002bba:	9ea50513          	addi	a0,a0,-1558 # 800085a0 <etext+0x5a0>
    80002bbe:	93dfd0ef          	jal	800004fa <printf>
    setkilled(p);
    80002bc2:	8526                	mv	a0,s1
    80002bc4:	963ff0ef          	jal	80002526 <setkilled>
    80002bc8:	bd7d                	j	80002a86 <usertrap+0xf8>
  if(killed(p))
    80002bca:	8526                	mv	a0,s1
    80002bcc:	97fff0ef          	jal	8000254a <killed>
    80002bd0:	c511                	beqz	a0,80002bdc <usertrap+0x24e>
    80002bd2:	a011                	j	80002bd6 <usertrap+0x248>
    80002bd4:	4901                	li	s2,0
    kexit(-1);
    80002bd6:	557d                	li	a0,-1
    80002bd8:	847ff0ef          	jal	8000241e <kexit>
  if(which_dev == 2)
    80002bdc:	4789                	li	a5,2
    80002bde:	eaf919e3          	bne	s2,a5,80002a90 <usertrap+0x102>
    yield();
    80002be2:	f04ff0ef          	jal	800022e6 <yield>
    80002be6:	b56d                	j	80002a90 <usertrap+0x102>

0000000080002be8 <kerneltrap>:
{
    80002be8:	7179                	addi	sp,sp,-48
    80002bea:	f406                	sd	ra,40(sp)
    80002bec:	f022                	sd	s0,32(sp)
    80002bee:	ec26                	sd	s1,24(sp)
    80002bf0:	e84a                	sd	s2,16(sp)
    80002bf2:	e44e                	sd	s3,8(sp)
    80002bf4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bf6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bfa:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bfe:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002c02:	1004f793          	andi	a5,s1,256
    80002c06:	c795                	beqz	a5,80002c32 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c08:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c0c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c0e:	eb85                	bnez	a5,80002c3e <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002c10:	d0bff0ef          	jal	8000291a <devintr>
    80002c14:	c91d                	beqz	a0,80002c4a <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002c16:	4789                	li	a5,2
    80002c18:	04f50a63          	beq	a0,a5,80002c6c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c1c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c20:	10049073          	csrw	sstatus,s1
}
    80002c24:	70a2                	ld	ra,40(sp)
    80002c26:	7402                	ld	s0,32(sp)
    80002c28:	64e2                	ld	s1,24(sp)
    80002c2a:	6942                	ld	s2,16(sp)
    80002c2c:	69a2                	ld	s3,8(sp)
    80002c2e:	6145                	addi	sp,sp,48
    80002c30:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c32:	00006517          	auipc	a0,0x6
    80002c36:	99650513          	addi	a0,a0,-1642 # 800085c8 <etext+0x5c8>
    80002c3a:	ba7fd0ef          	jal	800007e0 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c3e:	00006517          	auipc	a0,0x6
    80002c42:	9b250513          	addi	a0,a0,-1614 # 800085f0 <etext+0x5f0>
    80002c46:	b9bfd0ef          	jal	800007e0 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c4a:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c4e:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c52:	85ce                	mv	a1,s3
    80002c54:	00006517          	auipc	a0,0x6
    80002c58:	9bc50513          	addi	a0,a0,-1604 # 80008610 <etext+0x610>
    80002c5c:	89ffd0ef          	jal	800004fa <printf>
    panic("kerneltrap");
    80002c60:	00006517          	auipc	a0,0x6
    80002c64:	9d850513          	addi	a0,a0,-1576 # 80008638 <etext+0x638>
    80002c68:	b79fd0ef          	jal	800007e0 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c6c:	ff1fe0ef          	jal	80001c5c <myproc>
    80002c70:	d555                	beqz	a0,80002c1c <kerneltrap+0x34>
    yield();
    80002c72:	e74ff0ef          	jal	800022e6 <yield>
    80002c76:	b75d                	j	80002c1c <kerneltrap+0x34>

0000000080002c78 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c78:	1101                	addi	sp,sp,-32
    80002c7a:	ec06                	sd	ra,24(sp)
    80002c7c:	e822                	sd	s0,16(sp)
    80002c7e:	e426                	sd	s1,8(sp)
    80002c80:	1000                	addi	s0,sp,32
    80002c82:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c84:	fd9fe0ef          	jal	80001c5c <myproc>
  switch (n) {
    80002c88:	4795                	li	a5,5
    80002c8a:	0497e163          	bltu	a5,s1,80002ccc <argraw+0x54>
    80002c8e:	048a                	slli	s1,s1,0x2
    80002c90:	00006717          	auipc	a4,0x6
    80002c94:	f1070713          	addi	a4,a4,-240 # 80008ba0 <states.0+0x30>
    80002c98:	94ba                	add	s1,s1,a4
    80002c9a:	409c                	lw	a5,0(s1)
    80002c9c:	97ba                	add	a5,a5,a4
    80002c9e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ca0:	713c                	ld	a5,96(a0)
    80002ca2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ca4:	60e2                	ld	ra,24(sp)
    80002ca6:	6442                	ld	s0,16(sp)
    80002ca8:	64a2                	ld	s1,8(sp)
    80002caa:	6105                	addi	sp,sp,32
    80002cac:	8082                	ret
    return p->trapframe->a1;
    80002cae:	713c                	ld	a5,96(a0)
    80002cb0:	7fa8                	ld	a0,120(a5)
    80002cb2:	bfcd                	j	80002ca4 <argraw+0x2c>
    return p->trapframe->a2;
    80002cb4:	713c                	ld	a5,96(a0)
    80002cb6:	63c8                	ld	a0,128(a5)
    80002cb8:	b7f5                	j	80002ca4 <argraw+0x2c>
    return p->trapframe->a3;
    80002cba:	713c                	ld	a5,96(a0)
    80002cbc:	67c8                	ld	a0,136(a5)
    80002cbe:	b7dd                	j	80002ca4 <argraw+0x2c>
    return p->trapframe->a4;
    80002cc0:	713c                	ld	a5,96(a0)
    80002cc2:	6bc8                	ld	a0,144(a5)
    80002cc4:	b7c5                	j	80002ca4 <argraw+0x2c>
    return p->trapframe->a5;
    80002cc6:	713c                	ld	a5,96(a0)
    80002cc8:	6fc8                	ld	a0,152(a5)
    80002cca:	bfe9                	j	80002ca4 <argraw+0x2c>
  panic("argraw");
    80002ccc:	00006517          	auipc	a0,0x6
    80002cd0:	97c50513          	addi	a0,a0,-1668 # 80008648 <etext+0x648>
    80002cd4:	b0dfd0ef          	jal	800007e0 <panic>

0000000080002cd8 <fetchaddr>:
{
    80002cd8:	1101                	addi	sp,sp,-32
    80002cda:	ec06                	sd	ra,24(sp)
    80002cdc:	e822                	sd	s0,16(sp)
    80002cde:	e426                	sd	s1,8(sp)
    80002ce0:	e04a                	sd	s2,0(sp)
    80002ce2:	1000                	addi	s0,sp,32
    80002ce4:	84aa                	mv	s1,a0
    80002ce6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ce8:	f75fe0ef          	jal	80001c5c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cec:	693c                	ld	a5,80(a0)
    80002cee:	02f4f663          	bgeu	s1,a5,80002d1a <fetchaddr+0x42>
    80002cf2:	00848713          	addi	a4,s1,8
    80002cf6:	02e7e463          	bltu	a5,a4,80002d1e <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cfa:	46a1                	li	a3,8
    80002cfc:	8626                	mv	a2,s1
    80002cfe:	85ca                	mv	a1,s2
    80002d00:	6d28                	ld	a0,88(a0)
    80002d02:	baffe0ef          	jal	800018b0 <copyin>
    80002d06:	00a03533          	snez	a0,a0
    80002d0a:	40a00533          	neg	a0,a0
}
    80002d0e:	60e2                	ld	ra,24(sp)
    80002d10:	6442                	ld	s0,16(sp)
    80002d12:	64a2                	ld	s1,8(sp)
    80002d14:	6902                	ld	s2,0(sp)
    80002d16:	6105                	addi	sp,sp,32
    80002d18:	8082                	ret
    return -1;
    80002d1a:	557d                	li	a0,-1
    80002d1c:	bfcd                	j	80002d0e <fetchaddr+0x36>
    80002d1e:	557d                	li	a0,-1
    80002d20:	b7fd                	j	80002d0e <fetchaddr+0x36>

0000000080002d22 <fetchstr>:
{
    80002d22:	7179                	addi	sp,sp,-48
    80002d24:	f406                	sd	ra,40(sp)
    80002d26:	f022                	sd	s0,32(sp)
    80002d28:	ec26                	sd	s1,24(sp)
    80002d2a:	e84a                	sd	s2,16(sp)
    80002d2c:	e44e                	sd	s3,8(sp)
    80002d2e:	1800                	addi	s0,sp,48
    80002d30:	892a                	mv	s2,a0
    80002d32:	84ae                	mv	s1,a1
    80002d34:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002d36:	f27fe0ef          	jal	80001c5c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d3a:	86ce                	mv	a3,s3
    80002d3c:	864a                	mv	a2,s2
    80002d3e:	85a6                	mv	a1,s1
    80002d40:	6d28                	ld	a0,88(a0)
    80002d42:	931fe0ef          	jal	80001672 <copyinstr>
    80002d46:	00054c63          	bltz	a0,80002d5e <fetchstr+0x3c>
  return strlen(buf);
    80002d4a:	8526                	mv	a0,s1
    80002d4c:	a70fe0ef          	jal	80000fbc <strlen>
}
    80002d50:	70a2                	ld	ra,40(sp)
    80002d52:	7402                	ld	s0,32(sp)
    80002d54:	64e2                	ld	s1,24(sp)
    80002d56:	6942                	ld	s2,16(sp)
    80002d58:	69a2                	ld	s3,8(sp)
    80002d5a:	6145                	addi	sp,sp,48
    80002d5c:	8082                	ret
    return -1;
    80002d5e:	557d                	li	a0,-1
    80002d60:	bfc5                	j	80002d50 <fetchstr+0x2e>

0000000080002d62 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	1000                	addi	s0,sp,32
    80002d6c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d6e:	f0bff0ef          	jal	80002c78 <argraw>
    80002d72:	c088                	sw	a0,0(s1)
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	64a2                	ld	s1,8(sp)
    80002d7a:	6105                	addi	sp,sp,32
    80002d7c:	8082                	ret

0000000080002d7e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	1000                	addi	s0,sp,32
    80002d88:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d8a:	eefff0ef          	jal	80002c78 <argraw>
    80002d8e:	e088                	sd	a0,0(s1)
}
    80002d90:	60e2                	ld	ra,24(sp)
    80002d92:	6442                	ld	s0,16(sp)
    80002d94:	64a2                	ld	s1,8(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret

0000000080002d9a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d9a:	7179                	addi	sp,sp,-48
    80002d9c:	f406                	sd	ra,40(sp)
    80002d9e:	f022                	sd	s0,32(sp)
    80002da0:	ec26                	sd	s1,24(sp)
    80002da2:	e84a                	sd	s2,16(sp)
    80002da4:	1800                	addi	s0,sp,48
    80002da6:	84ae                	mv	s1,a1
    80002da8:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002daa:	fd840593          	addi	a1,s0,-40
    80002dae:	fd1ff0ef          	jal	80002d7e <argaddr>
  return fetchstr(addr, buf, max);
    80002db2:	864a                	mv	a2,s2
    80002db4:	85a6                	mv	a1,s1
    80002db6:	fd843503          	ld	a0,-40(s0)
    80002dba:	f69ff0ef          	jal	80002d22 <fetchstr>
}
    80002dbe:	70a2                	ld	ra,40(sp)
    80002dc0:	7402                	ld	s0,32(sp)
    80002dc2:	64e2                	ld	s1,24(sp)
    80002dc4:	6942                	ld	s2,16(sp)
    80002dc6:	6145                	addi	sp,sp,48
    80002dc8:	8082                	ret

0000000080002dca <syscall>:
[SYS_set_filter]    sys_set_filter,
};

void 
syscall(void) 
{ 
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	e04a                	sd	s2,0(sp)
    80002dd4:	1000                	addi	s0,sp,32
  int num; 
  struct proc *p = myproc(); 
    80002dd6:	e87fe0ef          	jal	80001c5c <myproc>
    80002dda:	84aa                	mv	s1,a0
 
  num = p->trapframe->a7; // Lấy mã số System Call từ thanh ghi a7 của CPU RISC-V 
    80002ddc:	06053903          	ld	s2,96(a0)
    80002de0:	0a893783          	ld	a5,168(s2)
    80002de4:	0007869b          	sext.w	a3,a5
   
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) { 
    80002de8:	37fd                	addiw	a5,a5,-1
    80002dea:	4771                	li	a4,28
    80002dec:	04f76663          	bltu	a4,a5,80002e38 <syscall+0x6e>
    80002df0:	00369713          	slli	a4,a3,0x3
    80002df4:	00006797          	auipc	a5,0x6
    80002df8:	dc478793          	addi	a5,a5,-572 # 80008bb8 <syscalls>
    80002dfc:	97ba                	add	a5,a5,a4
    80002dfe:	6398                	ld	a4,0(a5)
    80002e00:	cf05                	beqz	a4,80002e38 <syscall+0x6e>
     
    // ================================================================= 
    // CƠ CHẾ ĐÁNH CHẶN BẢO MẬT (SYSTEMCALL FILTER) 
    // Đã sửa: Chỉ lọc khi sc_filter khác 0 (đã kích hoạt)
    // ================================================================= 
    if (p->sc_filter != 0 && (((p->sc_filter >> num) & 1) == 0)) { 
    80002e02:	18053783          	ld	a5,384(a0)
    80002e06:	c789                	beqz	a5,80002e10 <syscall+0x46>
    80002e08:	00d7d7b3          	srl	a5,a5,a3
    80002e0c:	8b85                	andi	a5,a5,1
    80002e0e:	c789                	beqz	a5,80002e18 <syscall+0x4e>
      p->trapframe->a0 = -1; // Trả về mã lỗi -1 cho không gian ứng dụng 
      return; 
    } 
 
    // Nếu kiểm tra bit bằng 1 (Hợp pháp) hoặc chưa bật lọc -> Cho phép thực thi
    p->trapframe->a0 = syscalls[num](); 
    80002e10:	9702                	jalr	a4
    80002e12:	06a93823          	sd	a0,112(s2)
    80002e16:	a82d                	j	80002e50 <syscall+0x86>
      printf("[FILTER KLOGGER] DETECTED VIOLATION! pid=%d (%s) tried to call illegal syscall num=%d\n",  
    80002e18:	16050613          	addi	a2,a0,352
    80002e1c:	5d0c                	lw	a1,56(a0)
    80002e1e:	00006517          	auipc	a0,0x6
    80002e22:	83250513          	addi	a0,a0,-1998 # 80008650 <etext+0x650>
    80002e26:	ed4fd0ef          	jal	800004fa <printf>
      setkilled(p);         // Ra lệnh xử tử hình tiến trình vi phạm phân quyền 
    80002e2a:	8526                	mv	a0,s1
    80002e2c:	efaff0ef          	jal	80002526 <setkilled>
      p->trapframe->a0 = -1; // Trả về mã lỗi -1 cho không gian ứng dụng 
    80002e30:	70bc                	ld	a5,96(s1)
    80002e32:	577d                	li	a4,-1
    80002e34:	fbb8                	sd	a4,112(a5)
      return; 
    80002e36:	a829                	j	80002e50 <syscall+0x86>
     
  } else { 
    printf("%d %s: unknown sys call %d\n", p->pid, p->name, num); 
    80002e38:	16048613          	addi	a2,s1,352
    80002e3c:	5c8c                	lw	a1,56(s1)
    80002e3e:	00006517          	auipc	a0,0x6
    80002e42:	86a50513          	addi	a0,a0,-1942 # 800086a8 <etext+0x6a8>
    80002e46:	eb4fd0ef          	jal	800004fa <printf>
    p->trapframe->a0 = -1; 
    80002e4a:	70bc                	ld	a5,96(s1)
    80002e4c:	577d                	li	a4,-1
    80002e4e:	fbb8                	sd	a4,112(a5)
  } 
}
    80002e50:	60e2                	ld	ra,24(sp)
    80002e52:	6442                	ld	s0,16(sp)
    80002e54:	64a2                	ld	s1,8(sp)
    80002e56:	6902                	ld	s2,0(sp)
    80002e58:	6105                	addi	sp,sp,32
    80002e5a:	8082                	ret

0000000080002e5c <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    80002e5c:	1101                	addi	sp,sp,-32
    80002e5e:	ec06                	sd	ra,24(sp)
    80002e60:	e822                	sd	s0,16(sp)
    80002e62:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e64:	fec40593          	addi	a1,s0,-20
    80002e68:	4501                	li	a0,0
    80002e6a:	ef9ff0ef          	jal	80002d62 <argint>
  kexit(n);
    80002e6e:	fec42503          	lw	a0,-20(s0)
    80002e72:	dacff0ef          	jal	8000241e <kexit>
  return 0;  // not reached
}
    80002e76:	4501                	li	a0,0
    80002e78:	60e2                	ld	ra,24(sp)
    80002e7a:	6442                	ld	s0,16(sp)
    80002e7c:	6105                	addi	sp,sp,32
    80002e7e:	8082                	ret

0000000080002e80 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e80:	1141                	addi	sp,sp,-16
    80002e82:	e406                	sd	ra,8(sp)
    80002e84:	e022                	sd	s0,0(sp)
    80002e86:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e88:	dd5fe0ef          	jal	80001c5c <myproc>
}
    80002e8c:	5d08                	lw	a0,56(a0)
    80002e8e:	60a2                	ld	ra,8(sp)
    80002e90:	6402                	ld	s0,0(sp)
    80002e92:	0141                	addi	sp,sp,16
    80002e94:	8082                	ret

0000000080002e96 <sys_fork>:

uint64
sys_fork(void)
{
    80002e96:	1141                	addi	sp,sp,-16
    80002e98:	e406                	sd	ra,8(sp)
    80002e9a:	e022                	sd	s0,0(sp)
    80002e9c:	0800                	addi	s0,sp,16
  return kfork();
    80002e9e:	9c4ff0ef          	jal	80002062 <kfork>
}
    80002ea2:	60a2                	ld	ra,8(sp)
    80002ea4:	6402                	ld	s0,0(sp)
    80002ea6:	0141                	addi	sp,sp,16
    80002ea8:	8082                	ret

0000000080002eaa <sys_wait>:

uint64
sys_wait(void)
{
    80002eaa:	1101                	addi	sp,sp,-32
    80002eac:	ec06                	sd	ra,24(sp)
    80002eae:	e822                	sd	s0,16(sp)
    80002eb0:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002eb2:	fe840593          	addi	a1,s0,-24
    80002eb6:	4501                	li	a0,0
    80002eb8:	ec7ff0ef          	jal	80002d7e <argaddr>
  return kwait(p);
    80002ebc:	fe843503          	ld	a0,-24(s0)
    80002ec0:	eb4ff0ef          	jal	80002574 <kwait>
}
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	6105                	addi	sp,sp,32
    80002eca:	8082                	ret

0000000080002ecc <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002ecc:	7179                	addi	sp,sp,-48
    80002ece:	f406                	sd	ra,40(sp)
    80002ed0:	f022                	sd	s0,32(sp)
    80002ed2:	ec26                	sd	s1,24(sp)
    80002ed4:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002ed6:	fd840593          	addi	a1,s0,-40
    80002eda:	4501                	li	a0,0
    80002edc:	e87ff0ef          	jal	80002d62 <argint>
  argint(1, &t);
    80002ee0:	fdc40593          	addi	a1,s0,-36
    80002ee4:	4505                	li	a0,1
    80002ee6:	e7dff0ef          	jal	80002d62 <argint>
  addr = myproc()->sz;
    80002eea:	d73fe0ef          	jal	80001c5c <myproc>
    80002eee:	6924                	ld	s1,80(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002ef0:	fdc42703          	lw	a4,-36(s0)
    80002ef4:	4785                	li	a5,1
    80002ef6:	02f70763          	beq	a4,a5,80002f24 <sys_sbrk+0x58>
    80002efa:	fd842783          	lw	a5,-40(s0)
    80002efe:	0207c363          	bltz	a5,80002f24 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002f02:	97a6                	add	a5,a5,s1
    80002f04:	0297ee63          	bltu	a5,s1,80002f40 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002f08:	02000737          	lui	a4,0x2000
    80002f0c:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002f0e:	0736                	slli	a4,a4,0xd
    80002f10:	02f76a63          	bltu	a4,a5,80002f44 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002f14:	d49fe0ef          	jal	80001c5c <myproc>
    80002f18:	fd842703          	lw	a4,-40(s0)
    80002f1c:	693c                	ld	a5,80(a0)
    80002f1e:	97ba                	add	a5,a5,a4
    80002f20:	e93c                	sd	a5,80(a0)
    80002f22:	a039                	j	80002f30 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002f24:	fd842503          	lw	a0,-40(s0)
    80002f28:	8d8ff0ef          	jal	80002000 <growproc>
    80002f2c:	00054863          	bltz	a0,80002f3c <sys_sbrk+0x70>
  }
  return addr;
}
    80002f30:	8526                	mv	a0,s1
    80002f32:	70a2                	ld	ra,40(sp)
    80002f34:	7402                	ld	s0,32(sp)
    80002f36:	64e2                	ld	s1,24(sp)
    80002f38:	6145                	addi	sp,sp,48
    80002f3a:	8082                	ret
      return -1;
    80002f3c:	54fd                	li	s1,-1
    80002f3e:	bfcd                	j	80002f30 <sys_sbrk+0x64>
      return -1;
    80002f40:	54fd                	li	s1,-1
    80002f42:	b7fd                	j	80002f30 <sys_sbrk+0x64>
      return -1;
    80002f44:	54fd                	li	s1,-1
    80002f46:	b7ed                	j	80002f30 <sys_sbrk+0x64>

0000000080002f48 <sys_pause>:

uint64
sys_pause(void)
{
    80002f48:	7139                	addi	sp,sp,-64
    80002f4a:	fc06                	sd	ra,56(sp)
    80002f4c:	f822                	sd	s0,48(sp)
    80002f4e:	f04a                	sd	s2,32(sp)
    80002f50:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f52:	fcc40593          	addi	a1,s0,-52
    80002f56:	4501                	li	a0,0
    80002f58:	e0bff0ef          	jal	80002d62 <argint>
  if(n < 0)
    80002f5c:	fcc42783          	lw	a5,-52(s0)
    80002f60:	0607c763          	bltz	a5,80002fce <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002f64:	00234517          	auipc	a0,0x234
    80002f68:	4ec50513          	addi	a0,a0,1260 # 80237450 <tickslock>
    80002f6c:	e0dfd0ef          	jal	80000d78 <acquire>
  ticks0 = ticks;
    80002f70:	00006917          	auipc	s2,0x6
    80002f74:	d8c92903          	lw	s2,-628(s2) # 80008cfc <ticks>
  while(ticks - ticks0 < n){
    80002f78:	fcc42783          	lw	a5,-52(s0)
    80002f7c:	cf8d                	beqz	a5,80002fb6 <sys_pause+0x6e>
    80002f7e:	f426                	sd	s1,40(sp)
    80002f80:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f82:	00234997          	auipc	s3,0x234
    80002f86:	4ce98993          	addi	s3,s3,1230 # 80237450 <tickslock>
    80002f8a:	00006497          	auipc	s1,0x6
    80002f8e:	d7248493          	addi	s1,s1,-654 # 80008cfc <ticks>
    if(killed(myproc())){
    80002f92:	ccbfe0ef          	jal	80001c5c <myproc>
    80002f96:	db4ff0ef          	jal	8000254a <killed>
    80002f9a:	ed0d                	bnez	a0,80002fd4 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f9c:	85ce                	mv	a1,s3
    80002f9e:	8526                	mv	a0,s1
    80002fa0:	b72ff0ef          	jal	80002312 <sleep>
  while(ticks - ticks0 < n){
    80002fa4:	409c                	lw	a5,0(s1)
    80002fa6:	412787bb          	subw	a5,a5,s2
    80002faa:	fcc42703          	lw	a4,-52(s0)
    80002fae:	fee7e2e3          	bltu	a5,a4,80002f92 <sys_pause+0x4a>
    80002fb2:	74a2                	ld	s1,40(sp)
    80002fb4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002fb6:	00234517          	auipc	a0,0x234
    80002fba:	49a50513          	addi	a0,a0,1178 # 80237450 <tickslock>
    80002fbe:	e53fd0ef          	jal	80000e10 <release>
  return 0;
    80002fc2:	4501                	li	a0,0
}
    80002fc4:	70e2                	ld	ra,56(sp)
    80002fc6:	7442                	ld	s0,48(sp)
    80002fc8:	7902                	ld	s2,32(sp)
    80002fca:	6121                	addi	sp,sp,64
    80002fcc:	8082                	ret
    n = 0;
    80002fce:	fc042623          	sw	zero,-52(s0)
    80002fd2:	bf49                	j	80002f64 <sys_pause+0x1c>
      release(&tickslock);
    80002fd4:	00234517          	auipc	a0,0x234
    80002fd8:	47c50513          	addi	a0,a0,1148 # 80237450 <tickslock>
    80002fdc:	e35fd0ef          	jal	80000e10 <release>
      return -1;
    80002fe0:	557d                	li	a0,-1
    80002fe2:	74a2                	ld	s1,40(sp)
    80002fe4:	69e2                	ld	s3,24(sp)
    80002fe6:	bff9                	j	80002fc4 <sys_pause+0x7c>

0000000080002fe8 <sys_kill>:

uint64
sys_kill(void)
{
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ff0:	fec40593          	addi	a1,s0,-20
    80002ff4:	4501                	li	a0,0
    80002ff6:	d6dff0ef          	jal	80002d62 <argint>
  return kkill(pid);
    80002ffa:	fec42503          	lw	a0,-20(s0)
    80002ffe:	cc2ff0ef          	jal	800024c0 <kkill>
}
    80003002:	60e2                	ld	ra,24(sp)
    80003004:	6442                	ld	s0,16(sp)
    80003006:	6105                	addi	sp,sp,32
    80003008:	8082                	ret

000000008000300a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000300a:	1101                	addi	sp,sp,-32
    8000300c:	ec06                	sd	ra,24(sp)
    8000300e:	e822                	sd	s0,16(sp)
    80003010:	e426                	sd	s1,8(sp)
    80003012:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003014:	00234517          	auipc	a0,0x234
    80003018:	43c50513          	addi	a0,a0,1084 # 80237450 <tickslock>
    8000301c:	d5dfd0ef          	jal	80000d78 <acquire>
  xticks = ticks;
    80003020:	00006497          	auipc	s1,0x6
    80003024:	cdc4a483          	lw	s1,-804(s1) # 80008cfc <ticks>
  release(&tickslock);
    80003028:	00234517          	auipc	a0,0x234
    8000302c:	42850513          	addi	a0,a0,1064 # 80237450 <tickslock>
    80003030:	de1fd0ef          	jal	80000e10 <release>
  return xticks;
}
    80003034:	02049513          	slli	a0,s1,0x20
    80003038:	9101                	srli	a0,a0,0x20
    8000303a:	60e2                	ld	ra,24(sp)
    8000303c:	6442                	ld	s0,16(sp)
    8000303e:	64a2                	ld	s1,8(sp)
    80003040:	6105                	addi	sp,sp,32
    80003042:	8082                	ret

0000000080003044 <sys_hello>:

uint64
sys_hello(void)
{
    80003044:	1141                	addi	sp,sp,-16
    80003046:	e406                	sd	ra,8(sp)
    80003048:	e022                	sd	s0,0(sp)
    8000304a:	0800                	addi	s0,sp,16
  printf("kernel: hello() dang chay trong kernel!\n");
    8000304c:	00005517          	auipc	a0,0x5
    80003050:	67c50513          	addi	a0,a0,1660 # 800086c8 <etext+0x6c8>
    80003054:	ca6fd0ef          	jal	800004fa <printf>
  return 0;
}
    80003058:	4501                	li	a0,0
    8000305a:	60a2                	ld	ra,8(sp)
    8000305c:	6402                	ld	s0,0(sp)
    8000305e:	0141                	addi	sp,sp,16
    80003060:	8082                	ret

0000000080003062 <sys_ps>:

uint64
sys_ps(void)
{
    80003062:	711d                	addi	sp,sp,-96
    80003064:	ec86                	sd	ra,88(sp)
    80003066:	e8a2                	sd	s0,80(sp)
    80003068:	e4a6                	sd	s1,72(sp)
    8000306a:	e0ca                	sd	s2,64(sp)
    8000306c:	fc4e                	sd	s3,56(sp)
    8000306e:	f852                	sd	s4,48(sp)
    80003070:	f456                	sd	s5,40(sp)
    80003072:	f05a                	sd	s6,32(sp)
    80003074:	ec5e                	sd	s7,24(sp)
    80003076:	e862                	sd	s8,16(sp)
    80003078:	e466                	sd	s9,8(sp)
    8000307a:	e06a                	sd	s10,0(sp)
    8000307c:	1080                	addi	s0,sp,96
  struct proc *p;
  extern struct proc proc[]; // Tham chiếu mảng tiến trình toàn cục của Kernel

  printf("\nPID\tSTATE\t\tNAME\n");
    8000307e:	00005517          	auipc	a0,0x5
    80003082:	68a50513          	addi	a0,a0,1674 # 80008708 <etext+0x708>
    80003086:	c74fd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000308a:	0022e497          	auipc	s1,0x22e
    8000308e:	32648493          	addi	s1,s1,806 # 802313b0 <proc+0x160>
    80003092:	00234a17          	auipc	s4,0x234
    80003096:	51ea0a13          	addi	s4,s4,1310 # 802375b0 <bcache+0x130>
    8000309a:	4995                	li	s3,5
    else if(p->state == RUNNABLE) state = "runble";
    else if(p->state == RUNNING)  state = "run";
    else if(p->state == ZOMBIE)   state = "zombie";
    else state = "???";

    printf("%d\t%s\t%s\n", p->pid, state, p->name);
    8000309c:	00005a97          	auipc	s5,0x5
    800030a0:	684a8a93          	addi	s5,s5,1668 # 80008720 <etext+0x720>
    else state = "???";
    800030a4:	00005d17          	auipc	s10,0x5
    800030a8:	1a4d0d13          	addi	s10,s10,420 # 80008248 <etext+0x248>
    800030ac:	00006917          	auipc	s2,0x6
    800030b0:	bfc90913          	addi	s2,s2,-1028 # 80008ca8 <syscalls+0xf0>
    if(p->state == UNUSED) continue;
    800030b4:	00005b17          	auipc	s6,0x5
    800030b8:	644b0b13          	addi	s6,s6,1604 # 800086f8 <etext+0x6f8>
    800030bc:	00005c97          	auipc	s9,0x5
    800030c0:	1ccc8c93          	addi	s9,s9,460 # 80008288 <etext+0x288>
    800030c4:	00005c17          	auipc	s8,0x5
    800030c8:	63cc0c13          	addi	s8,s8,1596 # 80008700 <etext+0x700>
    800030cc:	00005b97          	auipc	s7,0x5
    800030d0:	1acb8b93          	addi	s7,s7,428 # 80008278 <etext+0x278>
    800030d4:	a01d                	j	800030fa <sys_ps+0x98>
    else state = "???";
    800030d6:	866a                	mv	a2,s10
    800030d8:	a801                	j	800030e8 <sys_ps+0x86>
    if(p->state == UNUSED) continue;
    800030da:	865e                	mv	a2,s7
    800030dc:	a031                	j	800030e8 <sys_ps+0x86>
    800030de:	8662                	mv	a2,s8
    800030e0:	a021                	j	800030e8 <sys_ps+0x86>
    800030e2:	8666                	mv	a2,s9
    800030e4:	a011                	j	800030e8 <sys_ps+0x86>
    800030e6:	865a                	mv	a2,s6
    printf("%d\t%s\t%s\n", p->pid, state, p->name);
    800030e8:	ed86a583          	lw	a1,-296(a3) # ed8 <_entry-0x7ffff128>
    800030ec:	8556                	mv	a0,s5
    800030ee:	c0cfd0ef          	jal	800004fa <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800030f2:	18848493          	addi	s1,s1,392
    800030f6:	01448e63          	beq	s1,s4,80003112 <sys_ps+0xb0>
    if(p->state == UNUSED) continue;
    800030fa:	86a6                	mv	a3,s1
    800030fc:	ec04a783          	lw	a5,-320(s1)
    80003100:	fcf9ebe3          	bltu	s3,a5,800030d6 <sys_ps+0x74>
    80003104:	ec04e783          	lwu	a5,-320(s1)
    80003108:	078a                	slli	a5,a5,0x2
    8000310a:	97ca                	add	a5,a5,s2
    8000310c:	439c                	lw	a5,0(a5)
    8000310e:	97ca                	add	a5,a5,s2
    80003110:	8782                	jr	a5
  }
  return 0;
}
    80003112:	4501                	li	a0,0
    80003114:	60e6                	ld	ra,88(sp)
    80003116:	6446                	ld	s0,80(sp)
    80003118:	64a6                	ld	s1,72(sp)
    8000311a:	6906                	ld	s2,64(sp)
    8000311c:	79e2                	ld	s3,56(sp)
    8000311e:	7a42                	ld	s4,48(sp)
    80003120:	7aa2                	ld	s5,40(sp)
    80003122:	7b02                	ld	s6,32(sp)
    80003124:	6be2                	ld	s7,24(sp)
    80003126:	6c42                	ld	s8,16(sp)
    80003128:	6ca2                	ld	s9,8(sp)
    8000312a:	6d02                	ld	s10,0(sp)
    8000312c:	6125                	addi	sp,sp,96
    8000312e:	8082                	ret

0000000080003130 <sys_memtest>:

uint64
sys_memtest(void)
{
    80003130:	1101                	addi	sp,sp,-32
    80003132:	ec06                	sd	ra,24(sp)
    80003134:	e822                	sd	s0,16(sp)
    80003136:	1000                	addi	s0,sp,32
  char *mem = kalloc(); // Cấp phát 1 trang bộ nhớ (4096 bytes)
    80003138:	a9bfd0ef          	jal	80000bd2 <kalloc>
  
  if(mem == 0){
    8000313c:	c529                	beqz	a0,80003186 <sys_memtest+0x56>
    8000313e:	e426                	sd	s1,8(sp)
    80003140:	84aa                	mv	s1,a0
    printf("Kernel: Cap phat bo nho THAT BAI!\n");
    return -1;
  }

  printf("Kernel: Da cap phat 4KB tai dia chi vat ly: %p\n", mem);
    80003142:	85aa                	mv	a1,a0
    80003144:	00005517          	auipc	a0,0x5
    80003148:	61450513          	addi	a0,a0,1556 # 80008758 <etext+0x758>
    8000314c:	baefd0ef          	jal	800004fa <printf>
  
  // Điền dữ liệu thử vào bộ nhớ
  mem[0] = 'X';
    80003150:	05800793          	li	a5,88
    80003154:	00f48023          	sb	a5,0(s1)
  printf("Kernel: Ghi thu du lieu vao o nho dau tien: %c\n", mem[0]);
    80003158:	05800593          	li	a1,88
    8000315c:	00005517          	auipc	a0,0x5
    80003160:	62c50513          	addi	a0,a0,1580 # 80008788 <etext+0x788>
    80003164:	b96fd0ef          	jal	800004fa <printf>

  kfree(mem); // Giải phóng bộ nhớ sau khi dùng xong
    80003168:	8526                	mv	a0,s1
    8000316a:	8b3fd0ef          	jal	80000a1c <kfree>
  printf("Kernel: Da giai phong bo nho.\n");
    8000316e:	00005517          	auipc	a0,0x5
    80003172:	64a50513          	addi	a0,a0,1610 # 800087b8 <etext+0x7b8>
    80003176:	b84fd0ef          	jal	800004fa <printf>
  
  return 0;
    8000317a:	4501                	li	a0,0
    8000317c:	64a2                	ld	s1,8(sp)
}
    8000317e:	60e2                	ld	ra,24(sp)
    80003180:	6442                	ld	s0,16(sp)
    80003182:	6105                	addi	sp,sp,32
    80003184:	8082                	ret
    printf("Kernel: Cap phat bo nho THAT BAI!\n");
    80003186:	00005517          	auipc	a0,0x5
    8000318a:	5aa50513          	addi	a0,a0,1450 # 80008730 <etext+0x730>
    8000318e:	b6cfd0ef          	jal	800004fa <printf>
    return -1;
    80003192:	557d                	li	a0,-1
    80003194:	b7ed                	j	8000317e <sys_memtest+0x4e>

0000000080003196 <pte_update_nolock>:
int shared_pte = 0;

// Phiên bản KHÔNG dùng spinlock (Dễ xảy ra Race Condition)
void
pte_update_nolock(void)
{
    80003196:	1101                	addi	sp,sp,-32
    80003198:	ec22                	sd	s0,24(sp)
    8000319a:	1000                	addi	s0,sp,32
  int temp;
  temp = shared_pte;
    8000319c:	00006697          	auipc	a3,0x6
    800031a0:	b646a683          	lw	a3,-1180(a3) # 80008d00 <shared_pte>
  // Tạo delay để ép các CPU xen kẽ thao tác vào nhau
  for(volatile int i = 0; i < 10000; i++);
    800031a4:	fe042623          	sw	zero,-20(s0)
    800031a8:	fec42703          	lw	a4,-20(s0)
    800031ac:	2701                	sext.w	a4,a4
    800031ae:	6789                	lui	a5,0x2
    800031b0:	70f78793          	addi	a5,a5,1807 # 270f <_entry-0x7fffd8f1>
    800031b4:	00e7cd63          	blt	a5,a4,800031ce <pte_update_nolock+0x38>
    800031b8:	873e                	mv	a4,a5
    800031ba:	fec42783          	lw	a5,-20(s0)
    800031be:	2785                	addiw	a5,a5,1
    800031c0:	fef42623          	sw	a5,-20(s0)
    800031c4:	fec42783          	lw	a5,-20(s0)
    800031c8:	2781                	sext.w	a5,a5
    800031ca:	fef758e3          	bge	a4,a5,800031ba <pte_update_nolock+0x24>
  temp = temp + 1;
    800031ce:	0016879b          	addiw	a5,a3,1
  shared_pte = temp;
    800031d2:	00006717          	auipc	a4,0x6
    800031d6:	b2f72723          	sw	a5,-1234(a4) # 80008d00 <shared_pte>
}
    800031da:	6462                	ld	s0,24(sp)
    800031dc:	6105                	addi	sp,sp,32
    800031de:	8082                	ret

00000000800031e0 <pte_update_lock>:

// Phiên bản CÓ dùng spinlock bảo vệ Critical Section
void
pte_update_lock(void)
{
    800031e0:	1101                	addi	sp,sp,-32
    800031e2:	ec06                	sd	ra,24(sp)
    800031e4:	e822                	sd	s0,16(sp)
    800031e6:	1000                	addi	s0,sp,32
  acquire(&ptlock);
    800031e8:	00234517          	auipc	a0,0x234
    800031ec:	28050513          	addi	a0,a0,640 # 80237468 <ptlock>
    800031f0:	b89fd0ef          	jal	80000d78 <acquire>
  int temp;
  temp = shared_pte;
    800031f4:	00006697          	auipc	a3,0x6
    800031f8:	b0c6a683          	lw	a3,-1268(a3) # 80008d00 <shared_pte>
  for(volatile int i = 0; i < 10000; i++);
    800031fc:	fe042623          	sw	zero,-20(s0)
    80003200:	fec42703          	lw	a4,-20(s0)
    80003204:	2701                	sext.w	a4,a4
    80003206:	6789                	lui	a5,0x2
    80003208:	70f78793          	addi	a5,a5,1807 # 270f <_entry-0x7fffd8f1>
    8000320c:	00e7cd63          	blt	a5,a4,80003226 <pte_update_lock+0x46>
    80003210:	873e                	mv	a4,a5
    80003212:	fec42783          	lw	a5,-20(s0)
    80003216:	2785                	addiw	a5,a5,1
    80003218:	fef42623          	sw	a5,-20(s0)
    8000321c:	fec42783          	lw	a5,-20(s0)
    80003220:	2781                	sext.w	a5,a5
    80003222:	fef758e3          	bge	a4,a5,80003212 <pte_update_lock+0x32>
  temp = temp + 1;
    80003226:	0016879b          	addiw	a5,a3,1
  shared_pte = temp;
    8000322a:	00006717          	auipc	a4,0x6
    8000322e:	acf72b23          	sw	a5,-1322(a4) # 80008d00 <shared_pte>
  release(&ptlock);
    80003232:	00234517          	auipc	a0,0x234
    80003236:	23650513          	addi	a0,a0,566 # 80237468 <ptlock>
    8000323a:	bd7fd0ef          	jal	80000e10 <release>
}
    8000323e:	60e2                	ld	ra,24(sp)
    80003240:	6442                	ld	s0,16(sp)
    80003242:	6105                	addi	sp,sp,32
    80003244:	8082                	ret

0000000080003246 <sys_testnolock>:

// Syscall wrapper cho phiên bản không khóa
uint64
sys_testnolock(void)
{
    80003246:	1141                	addi	sp,sp,-16
    80003248:	e406                	sd	ra,8(sp)
    8000324a:	e022                	sd	s0,0(sp)
    8000324c:	0800                	addi	s0,sp,16
  pte_update_nolock();
    8000324e:	f49ff0ef          	jal	80003196 <pte_update_nolock>
  return shared_pte;
}
    80003252:	00006517          	auipc	a0,0x6
    80003256:	aae52503          	lw	a0,-1362(a0) # 80008d00 <shared_pte>
    8000325a:	60a2                	ld	ra,8(sp)
    8000325c:	6402                	ld	s0,0(sp)
    8000325e:	0141                	addi	sp,sp,16
    80003260:	8082                	ret

0000000080003262 <sys_testlock>:

// Syscall wrapper cho phiên bản có khóa
uint64
sys_testlock(void)
{
    80003262:	1141                	addi	sp,sp,-16
    80003264:	e406                	sd	ra,8(sp)
    80003266:	e022                	sd	s0,0(sp)
    80003268:	0800                	addi	s0,sp,16
  pte_update_lock();
    8000326a:	f77ff0ef          	jal	800031e0 <pte_update_lock>
  return shared_pte;
}
    8000326e:	00006517          	auipc	a0,0x6
    80003272:	a9252503          	lw	a0,-1390(a0) # 80008d00 <shared_pte>
    80003276:	60a2                	ld	ra,8(sp)
    80003278:	6402                	ld	s0,0(sp)
    8000327a:	0141                	addi	sp,sp,16
    8000327c:	8082                	ret

000000008000327e <kernel_rdcycle>:
// --- ĐO LƯỜNG LATENCY SYSTEM CALL (FIXED FOR RISC-V USER TRAP) ---

// Đọc thanh ghi chu kỳ máy an toàn từ tầng Kernel (Supervisor Mode)
uint64
kernel_rdcycle(void)
{
    8000327e:	1141                	addi	sp,sp,-16
    80003280:	e422                	sd	s0,8(sp)
    80003282:	0800                	addi	s0,sp,16
  uint64 x;
  asm volatile("rdcycle %0" : "=r"(x));
    80003284:	c0002573          	rdcycle	a0
  return x;
}
    80003288:	6422                	ld	s0,8(sp)
    8000328a:	0141                	addi	sp,sp,16
    8000328c:	8082                	ret

000000008000328e <sys_getcycles>:

// Baseline syscall rỗng
uint64
sys_getcycles(void)
{
    8000328e:	1101                	addi	sp,sp,-32
    80003290:	ec06                	sd	ra,24(sp)
    80003292:	e822                	sd	s0,16(sp)
    80003294:	e426                	sd	s1,8(sp)
    80003296:	1000                	addi	s0,sp,32
  uint xticks;
  acquire(&tickslock);
    80003298:	00234517          	auipc	a0,0x234
    8000329c:	1b850513          	addi	a0,a0,440 # 80237450 <tickslock>
    800032a0:	ad9fd0ef          	jal	80000d78 <acquire>
  xticks = ticks;
    800032a4:	00006497          	auipc	s1,0x6
    800032a8:	a584a483          	lw	s1,-1448(s1) # 80008cfc <ticks>
  release(&tickslock);
    800032ac:	00234517          	auipc	a0,0x234
    800032b0:	1a450513          	addi	a0,a0,420 # 80237450 <tickslock>
    800032b4:	b5dfd0ef          	jal	80000e10 <release>
  return (uint64)xticks;
}
    800032b8:	02049513          	slli	a0,s1,0x20
    800032bc:	9101                	srli	a0,a0,0x20
    800032be:	60e2                	ld	ra,24(sp)
    800032c0:	6442                	ld	s0,16(sp)
    800032c2:	64a2                	ld	s1,8(sp)
    800032c4:	6105                	addi	sp,sp,32
    800032c6:	8082                	ret

00000000800032c8 <sys_nullcall>:

// Giữ nguyên hàm nullcall cơ sở của bạn
uint64
sys_nullcall(void)
{
    800032c8:	1141                	addi	sp,sp,-16
    800032ca:	e422                	sd	s0,8(sp)
    800032cc:	0800                	addi	s0,sp,16
  return 0; 
}
    800032ce:	4501                	li	a0,0
    800032d0:	6422                	ld	s0,8(sp)
    800032d2:	0141                	addi	sp,sp,16
    800032d4:	8082                	ret

00000000800032d6 <sys_set_filter>:

uint64
sys_set_filter(void)
{
    800032d6:	1101                	addi	sp,sp,-32
    800032d8:	ec06                	sd	ra,24(sp)
    800032da:	e822                	sd	s0,16(sp)
    800032dc:	1000                	addi	s0,sp,32
  uint64 mask;
  argaddr(0, &mask); 
    800032de:	fe840593          	addi	a1,s0,-24
    800032e2:	4501                	li	a0,0
    800032e4:	a9bff0ef          	jal	80002d7e <argaddr>
  
  struct proc *p = myproc();
    800032e8:	975fe0ef          	jal	80001c5c <myproc>
  
  // CẬP NHẬT TÊN BIẾN TẠI ĐÂY:
  p->sc_filter = mask; 
    800032ec:	fe843783          	ld	a5,-24(s0)
    800032f0:	18f53023          	sd	a5,384(a0)
  
  return 0;
}
    800032f4:	4501                	li	a0,0
    800032f6:	60e2                	ld	ra,24(sp)
    800032f8:	6442                	ld	s0,16(sp)
    800032fa:	6105                	addi	sp,sp,32
    800032fc:	8082                	ret

00000000800032fe <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032fe:	7179                	addi	sp,sp,-48
    80003300:	f406                	sd	ra,40(sp)
    80003302:	f022                	sd	s0,32(sp)
    80003304:	ec26                	sd	s1,24(sp)
    80003306:	e84a                	sd	s2,16(sp)
    80003308:	e44e                	sd	s3,8(sp)
    8000330a:	e052                	sd	s4,0(sp)
    8000330c:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000330e:	00005597          	auipc	a1,0x5
    80003312:	4ca58593          	addi	a1,a1,1226 # 800087d8 <etext+0x7d8>
    80003316:	00234517          	auipc	a0,0x234
    8000331a:	16a50513          	addi	a0,a0,362 # 80237480 <bcache>
    8000331e:	9dbfd0ef          	jal	80000cf8 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003322:	0023c797          	auipc	a5,0x23c
    80003326:	15e78793          	addi	a5,a5,350 # 8023f480 <bcache+0x8000>
    8000332a:	0023c717          	auipc	a4,0x23c
    8000332e:	3be70713          	addi	a4,a4,958 # 8023f6e8 <bcache+0x8268>
    80003332:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003336:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000333a:	00234497          	auipc	s1,0x234
    8000333e:	15e48493          	addi	s1,s1,350 # 80237498 <bcache+0x18>
    b->next = bcache.head.next;
    80003342:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003344:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003346:	00005a17          	auipc	s4,0x5
    8000334a:	49aa0a13          	addi	s4,s4,1178 # 800087e0 <etext+0x7e0>
    b->next = bcache.head.next;
    8000334e:	2b893783          	ld	a5,696(s2)
    80003352:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003354:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003358:	85d2                	mv	a1,s4
    8000335a:	01048513          	addi	a0,s1,16
    8000335e:	322010ef          	jal	80004680 <initsleeplock>
    bcache.head.next->prev = b;
    80003362:	2b893783          	ld	a5,696(s2)
    80003366:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003368:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000336c:	45848493          	addi	s1,s1,1112
    80003370:	fd349fe3          	bne	s1,s3,8000334e <binit+0x50>
  }
}
    80003374:	70a2                	ld	ra,40(sp)
    80003376:	7402                	ld	s0,32(sp)
    80003378:	64e2                	ld	s1,24(sp)
    8000337a:	6942                	ld	s2,16(sp)
    8000337c:	69a2                	ld	s3,8(sp)
    8000337e:	6a02                	ld	s4,0(sp)
    80003380:	6145                	addi	sp,sp,48
    80003382:	8082                	ret

0000000080003384 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003384:	7179                	addi	sp,sp,-48
    80003386:	f406                	sd	ra,40(sp)
    80003388:	f022                	sd	s0,32(sp)
    8000338a:	ec26                	sd	s1,24(sp)
    8000338c:	e84a                	sd	s2,16(sp)
    8000338e:	e44e                	sd	s3,8(sp)
    80003390:	1800                	addi	s0,sp,48
    80003392:	892a                	mv	s2,a0
    80003394:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003396:	00234517          	auipc	a0,0x234
    8000339a:	0ea50513          	addi	a0,a0,234 # 80237480 <bcache>
    8000339e:	9dbfd0ef          	jal	80000d78 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033a2:	0023c497          	auipc	s1,0x23c
    800033a6:	3964b483          	ld	s1,918(s1) # 8023f738 <bcache+0x82b8>
    800033aa:	0023c797          	auipc	a5,0x23c
    800033ae:	33e78793          	addi	a5,a5,830 # 8023f6e8 <bcache+0x8268>
    800033b2:	02f48b63          	beq	s1,a5,800033e8 <bread+0x64>
    800033b6:	873e                	mv	a4,a5
    800033b8:	a021                	j	800033c0 <bread+0x3c>
    800033ba:	68a4                	ld	s1,80(s1)
    800033bc:	02e48663          	beq	s1,a4,800033e8 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    800033c0:	449c                	lw	a5,8(s1)
    800033c2:	ff279ce3          	bne	a5,s2,800033ba <bread+0x36>
    800033c6:	44dc                	lw	a5,12(s1)
    800033c8:	ff3799e3          	bne	a5,s3,800033ba <bread+0x36>
      b->refcnt++;
    800033cc:	40bc                	lw	a5,64(s1)
    800033ce:	2785                	addiw	a5,a5,1
    800033d0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033d2:	00234517          	auipc	a0,0x234
    800033d6:	0ae50513          	addi	a0,a0,174 # 80237480 <bcache>
    800033da:	a37fd0ef          	jal	80000e10 <release>
      acquiresleep(&b->lock);
    800033de:	01048513          	addi	a0,s1,16
    800033e2:	2d4010ef          	jal	800046b6 <acquiresleep>
      return b;
    800033e6:	a889                	j	80003438 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033e8:	0023c497          	auipc	s1,0x23c
    800033ec:	3484b483          	ld	s1,840(s1) # 8023f730 <bcache+0x82b0>
    800033f0:	0023c797          	auipc	a5,0x23c
    800033f4:	2f878793          	addi	a5,a5,760 # 8023f6e8 <bcache+0x8268>
    800033f8:	00f48863          	beq	s1,a5,80003408 <bread+0x84>
    800033fc:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800033fe:	40bc                	lw	a5,64(s1)
    80003400:	cb91                	beqz	a5,80003414 <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003402:	64a4                	ld	s1,72(s1)
    80003404:	fee49de3          	bne	s1,a4,800033fe <bread+0x7a>
  panic("bget: no buffers");
    80003408:	00005517          	auipc	a0,0x5
    8000340c:	3e050513          	addi	a0,a0,992 # 800087e8 <etext+0x7e8>
    80003410:	bd0fd0ef          	jal	800007e0 <panic>
      b->dev = dev;
    80003414:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003418:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000341c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003420:	4785                	li	a5,1
    80003422:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003424:	00234517          	auipc	a0,0x234
    80003428:	05c50513          	addi	a0,a0,92 # 80237480 <bcache>
    8000342c:	9e5fd0ef          	jal	80000e10 <release>
      acquiresleep(&b->lock);
    80003430:	01048513          	addi	a0,s1,16
    80003434:	282010ef          	jal	800046b6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003438:	409c                	lw	a5,0(s1)
    8000343a:	cb89                	beqz	a5,8000344c <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000343c:	8526                	mv	a0,s1
    8000343e:	70a2                	ld	ra,40(sp)
    80003440:	7402                	ld	s0,32(sp)
    80003442:	64e2                	ld	s1,24(sp)
    80003444:	6942                	ld	s2,16(sp)
    80003446:	69a2                	ld	s3,8(sp)
    80003448:	6145                	addi	sp,sp,48
    8000344a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000344c:	4581                	li	a1,0
    8000344e:	8526                	mv	a0,s1
    80003450:	2d1020ef          	jal	80005f20 <virtio_disk_rw>
    b->valid = 1;
    80003454:	4785                	li	a5,1
    80003456:	c09c                	sw	a5,0(s1)
  return b;
    80003458:	b7d5                	j	8000343c <bread+0xb8>

000000008000345a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000345a:	1101                	addi	sp,sp,-32
    8000345c:	ec06                	sd	ra,24(sp)
    8000345e:	e822                	sd	s0,16(sp)
    80003460:	e426                	sd	s1,8(sp)
    80003462:	1000                	addi	s0,sp,32
    80003464:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003466:	0541                	addi	a0,a0,16
    80003468:	2cc010ef          	jal	80004734 <holdingsleep>
    8000346c:	c911                	beqz	a0,80003480 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000346e:	4585                	li	a1,1
    80003470:	8526                	mv	a0,s1
    80003472:	2af020ef          	jal	80005f20 <virtio_disk_rw>
}
    80003476:	60e2                	ld	ra,24(sp)
    80003478:	6442                	ld	s0,16(sp)
    8000347a:	64a2                	ld	s1,8(sp)
    8000347c:	6105                	addi	sp,sp,32
    8000347e:	8082                	ret
    panic("bwrite");
    80003480:	00005517          	auipc	a0,0x5
    80003484:	38050513          	addi	a0,a0,896 # 80008800 <etext+0x800>
    80003488:	b58fd0ef          	jal	800007e0 <panic>

000000008000348c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000348c:	1101                	addi	sp,sp,-32
    8000348e:	ec06                	sd	ra,24(sp)
    80003490:	e822                	sd	s0,16(sp)
    80003492:	e426                	sd	s1,8(sp)
    80003494:	e04a                	sd	s2,0(sp)
    80003496:	1000                	addi	s0,sp,32
    80003498:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000349a:	01050913          	addi	s2,a0,16
    8000349e:	854a                	mv	a0,s2
    800034a0:	294010ef          	jal	80004734 <holdingsleep>
    800034a4:	c135                	beqz	a0,80003508 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    800034a6:	854a                	mv	a0,s2
    800034a8:	254010ef          	jal	800046fc <releasesleep>

  acquire(&bcache.lock);
    800034ac:	00234517          	auipc	a0,0x234
    800034b0:	fd450513          	addi	a0,a0,-44 # 80237480 <bcache>
    800034b4:	8c5fd0ef          	jal	80000d78 <acquire>
  b->refcnt--;
    800034b8:	40bc                	lw	a5,64(s1)
    800034ba:	37fd                	addiw	a5,a5,-1
    800034bc:	0007871b          	sext.w	a4,a5
    800034c0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034c2:	e71d                	bnez	a4,800034f0 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034c4:	68b8                	ld	a4,80(s1)
    800034c6:	64bc                	ld	a5,72(s1)
    800034c8:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800034ca:	68b8                	ld	a4,80(s1)
    800034cc:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034ce:	0023c797          	auipc	a5,0x23c
    800034d2:	fb278793          	addi	a5,a5,-78 # 8023f480 <bcache+0x8000>
    800034d6:	2b87b703          	ld	a4,696(a5)
    800034da:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034dc:	0023c717          	auipc	a4,0x23c
    800034e0:	20c70713          	addi	a4,a4,524 # 8023f6e8 <bcache+0x8268>
    800034e4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034e6:	2b87b703          	ld	a4,696(a5)
    800034ea:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034ec:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800034f0:	00234517          	auipc	a0,0x234
    800034f4:	f9050513          	addi	a0,a0,-112 # 80237480 <bcache>
    800034f8:	919fd0ef          	jal	80000e10 <release>
}
    800034fc:	60e2                	ld	ra,24(sp)
    800034fe:	6442                	ld	s0,16(sp)
    80003500:	64a2                	ld	s1,8(sp)
    80003502:	6902                	ld	s2,0(sp)
    80003504:	6105                	addi	sp,sp,32
    80003506:	8082                	ret
    panic("brelse");
    80003508:	00005517          	auipc	a0,0x5
    8000350c:	30050513          	addi	a0,a0,768 # 80008808 <etext+0x808>
    80003510:	ad0fd0ef          	jal	800007e0 <panic>

0000000080003514 <bpin>:

void
bpin(struct buf *b) {
    80003514:	1101                	addi	sp,sp,-32
    80003516:	ec06                	sd	ra,24(sp)
    80003518:	e822                	sd	s0,16(sp)
    8000351a:	e426                	sd	s1,8(sp)
    8000351c:	1000                	addi	s0,sp,32
    8000351e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003520:	00234517          	auipc	a0,0x234
    80003524:	f6050513          	addi	a0,a0,-160 # 80237480 <bcache>
    80003528:	851fd0ef          	jal	80000d78 <acquire>
  b->refcnt++;
    8000352c:	40bc                	lw	a5,64(s1)
    8000352e:	2785                	addiw	a5,a5,1
    80003530:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003532:	00234517          	auipc	a0,0x234
    80003536:	f4e50513          	addi	a0,a0,-178 # 80237480 <bcache>
    8000353a:	8d7fd0ef          	jal	80000e10 <release>
}
    8000353e:	60e2                	ld	ra,24(sp)
    80003540:	6442                	ld	s0,16(sp)
    80003542:	64a2                	ld	s1,8(sp)
    80003544:	6105                	addi	sp,sp,32
    80003546:	8082                	ret

0000000080003548 <bunpin>:

void
bunpin(struct buf *b) {
    80003548:	1101                	addi	sp,sp,-32
    8000354a:	ec06                	sd	ra,24(sp)
    8000354c:	e822                	sd	s0,16(sp)
    8000354e:	e426                	sd	s1,8(sp)
    80003550:	1000                	addi	s0,sp,32
    80003552:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003554:	00234517          	auipc	a0,0x234
    80003558:	f2c50513          	addi	a0,a0,-212 # 80237480 <bcache>
    8000355c:	81dfd0ef          	jal	80000d78 <acquire>
  b->refcnt--;
    80003560:	40bc                	lw	a5,64(s1)
    80003562:	37fd                	addiw	a5,a5,-1
    80003564:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003566:	00234517          	auipc	a0,0x234
    8000356a:	f1a50513          	addi	a0,a0,-230 # 80237480 <bcache>
    8000356e:	8a3fd0ef          	jal	80000e10 <release>
}
    80003572:	60e2                	ld	ra,24(sp)
    80003574:	6442                	ld	s0,16(sp)
    80003576:	64a2                	ld	s1,8(sp)
    80003578:	6105                	addi	sp,sp,32
    8000357a:	8082                	ret

000000008000357c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000357c:	1101                	addi	sp,sp,-32
    8000357e:	ec06                	sd	ra,24(sp)
    80003580:	e822                	sd	s0,16(sp)
    80003582:	e426                	sd	s1,8(sp)
    80003584:	e04a                	sd	s2,0(sp)
    80003586:	1000                	addi	s0,sp,32
    80003588:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000358a:	00d5d59b          	srliw	a1,a1,0xd
    8000358e:	0023c797          	auipc	a5,0x23c
    80003592:	5ce7a783          	lw	a5,1486(a5) # 8023fb5c <sb+0x1c>
    80003596:	9dbd                	addw	a1,a1,a5
    80003598:	dedff0ef          	jal	80003384 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000359c:	0074f713          	andi	a4,s1,7
    800035a0:	4785                	li	a5,1
    800035a2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035a6:	14ce                	slli	s1,s1,0x33
    800035a8:	90d9                	srli	s1,s1,0x36
    800035aa:	00950733          	add	a4,a0,s1
    800035ae:	05874703          	lbu	a4,88(a4)
    800035b2:	00e7f6b3          	and	a3,a5,a4
    800035b6:	c29d                	beqz	a3,800035dc <bfree+0x60>
    800035b8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035ba:	94aa                	add	s1,s1,a0
    800035bc:	fff7c793          	not	a5,a5
    800035c0:	8f7d                	and	a4,a4,a5
    800035c2:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800035c6:	7f9000ef          	jal	800045be <log_write>
  brelse(bp);
    800035ca:	854a                	mv	a0,s2
    800035cc:	ec1ff0ef          	jal	8000348c <brelse>
}
    800035d0:	60e2                	ld	ra,24(sp)
    800035d2:	6442                	ld	s0,16(sp)
    800035d4:	64a2                	ld	s1,8(sp)
    800035d6:	6902                	ld	s2,0(sp)
    800035d8:	6105                	addi	sp,sp,32
    800035da:	8082                	ret
    panic("freeing free block");
    800035dc:	00005517          	auipc	a0,0x5
    800035e0:	23450513          	addi	a0,a0,564 # 80008810 <etext+0x810>
    800035e4:	9fcfd0ef          	jal	800007e0 <panic>

00000000800035e8 <balloc>:
{
    800035e8:	711d                	addi	sp,sp,-96
    800035ea:	ec86                	sd	ra,88(sp)
    800035ec:	e8a2                	sd	s0,80(sp)
    800035ee:	e4a6                	sd	s1,72(sp)
    800035f0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800035f2:	0023c797          	auipc	a5,0x23c
    800035f6:	5527a783          	lw	a5,1362(a5) # 8023fb44 <sb+0x4>
    800035fa:	0e078f63          	beqz	a5,800036f8 <balloc+0x110>
    800035fe:	e0ca                	sd	s2,64(sp)
    80003600:	fc4e                	sd	s3,56(sp)
    80003602:	f852                	sd	s4,48(sp)
    80003604:	f456                	sd	s5,40(sp)
    80003606:	f05a                	sd	s6,32(sp)
    80003608:	ec5e                	sd	s7,24(sp)
    8000360a:	e862                	sd	s8,16(sp)
    8000360c:	e466                	sd	s9,8(sp)
    8000360e:	8baa                	mv	s7,a0
    80003610:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003612:	0023cb17          	auipc	s6,0x23c
    80003616:	52eb0b13          	addi	s6,s6,1326 # 8023fb40 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000361a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000361c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000361e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003620:	6c89                	lui	s9,0x2
    80003622:	a0b5                	j	8000368e <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003624:	97ca                	add	a5,a5,s2
    80003626:	8e55                	or	a2,a2,a3
    80003628:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000362c:	854a                	mv	a0,s2
    8000362e:	791000ef          	jal	800045be <log_write>
        brelse(bp);
    80003632:	854a                	mv	a0,s2
    80003634:	e59ff0ef          	jal	8000348c <brelse>
  bp = bread(dev, bno);
    80003638:	85a6                	mv	a1,s1
    8000363a:	855e                	mv	a0,s7
    8000363c:	d49ff0ef          	jal	80003384 <bread>
    80003640:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003642:	40000613          	li	a2,1024
    80003646:	4581                	li	a1,0
    80003648:	05850513          	addi	a0,a0,88
    8000364c:	801fd0ef          	jal	80000e4c <memset>
  log_write(bp);
    80003650:	854a                	mv	a0,s2
    80003652:	76d000ef          	jal	800045be <log_write>
  brelse(bp);
    80003656:	854a                	mv	a0,s2
    80003658:	e35ff0ef          	jal	8000348c <brelse>
}
    8000365c:	6906                	ld	s2,64(sp)
    8000365e:	79e2                	ld	s3,56(sp)
    80003660:	7a42                	ld	s4,48(sp)
    80003662:	7aa2                	ld	s5,40(sp)
    80003664:	7b02                	ld	s6,32(sp)
    80003666:	6be2                	ld	s7,24(sp)
    80003668:	6c42                	ld	s8,16(sp)
    8000366a:	6ca2                	ld	s9,8(sp)
}
    8000366c:	8526                	mv	a0,s1
    8000366e:	60e6                	ld	ra,88(sp)
    80003670:	6446                	ld	s0,80(sp)
    80003672:	64a6                	ld	s1,72(sp)
    80003674:	6125                	addi	sp,sp,96
    80003676:	8082                	ret
    brelse(bp);
    80003678:	854a                	mv	a0,s2
    8000367a:	e13ff0ef          	jal	8000348c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000367e:	015c87bb          	addw	a5,s9,s5
    80003682:	00078a9b          	sext.w	s5,a5
    80003686:	004b2703          	lw	a4,4(s6)
    8000368a:	04eaff63          	bgeu	s5,a4,800036e8 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    8000368e:	41fad79b          	sraiw	a5,s5,0x1f
    80003692:	0137d79b          	srliw	a5,a5,0x13
    80003696:	015787bb          	addw	a5,a5,s5
    8000369a:	40d7d79b          	sraiw	a5,a5,0xd
    8000369e:	01cb2583          	lw	a1,28(s6)
    800036a2:	9dbd                	addw	a1,a1,a5
    800036a4:	855e                	mv	a0,s7
    800036a6:	cdfff0ef          	jal	80003384 <bread>
    800036aa:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036ac:	004b2503          	lw	a0,4(s6)
    800036b0:	000a849b          	sext.w	s1,s5
    800036b4:	8762                	mv	a4,s8
    800036b6:	fca4f1e3          	bgeu	s1,a0,80003678 <balloc+0x90>
      m = 1 << (bi % 8);
    800036ba:	00777693          	andi	a3,a4,7
    800036be:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800036c2:	41f7579b          	sraiw	a5,a4,0x1f
    800036c6:	01d7d79b          	srliw	a5,a5,0x1d
    800036ca:	9fb9                	addw	a5,a5,a4
    800036cc:	4037d79b          	sraiw	a5,a5,0x3
    800036d0:	00f90633          	add	a2,s2,a5
    800036d4:	05864603          	lbu	a2,88(a2)
    800036d8:	00c6f5b3          	and	a1,a3,a2
    800036dc:	d5a1                	beqz	a1,80003624 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036de:	2705                	addiw	a4,a4,1
    800036e0:	2485                	addiw	s1,s1,1
    800036e2:	fd471ae3          	bne	a4,s4,800036b6 <balloc+0xce>
    800036e6:	bf49                	j	80003678 <balloc+0x90>
    800036e8:	6906                	ld	s2,64(sp)
    800036ea:	79e2                	ld	s3,56(sp)
    800036ec:	7a42                	ld	s4,48(sp)
    800036ee:	7aa2                	ld	s5,40(sp)
    800036f0:	7b02                	ld	s6,32(sp)
    800036f2:	6be2                	ld	s7,24(sp)
    800036f4:	6c42                	ld	s8,16(sp)
    800036f6:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800036f8:	00005517          	auipc	a0,0x5
    800036fc:	13050513          	addi	a0,a0,304 # 80008828 <etext+0x828>
    80003700:	dfbfc0ef          	jal	800004fa <printf>
  return 0;
    80003704:	4481                	li	s1,0
    80003706:	b79d                	j	8000366c <balloc+0x84>

0000000080003708 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003708:	7179                	addi	sp,sp,-48
    8000370a:	f406                	sd	ra,40(sp)
    8000370c:	f022                	sd	s0,32(sp)
    8000370e:	ec26                	sd	s1,24(sp)
    80003710:	e84a                	sd	s2,16(sp)
    80003712:	e44e                	sd	s3,8(sp)
    80003714:	1800                	addi	s0,sp,48
    80003716:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003718:	47ad                	li	a5,11
    8000371a:	02b7e663          	bltu	a5,a1,80003746 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    8000371e:	02059793          	slli	a5,a1,0x20
    80003722:	01e7d593          	srli	a1,a5,0x1e
    80003726:	00b504b3          	add	s1,a0,a1
    8000372a:	0504a903          	lw	s2,80(s1)
    8000372e:	06091a63          	bnez	s2,800037a2 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003732:	4108                	lw	a0,0(a0)
    80003734:	eb5ff0ef          	jal	800035e8 <balloc>
    80003738:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000373c:	06090363          	beqz	s2,800037a2 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003740:	0524a823          	sw	s2,80(s1)
    80003744:	a8b9                	j	800037a2 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003746:	ff45849b          	addiw	s1,a1,-12
    8000374a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000374e:	0ff00793          	li	a5,255
    80003752:	06e7ee63          	bltu	a5,a4,800037ce <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003756:	08052903          	lw	s2,128(a0)
    8000375a:	00091d63          	bnez	s2,80003774 <bmap+0x6c>
      addr = balloc(ip->dev);
    8000375e:	4108                	lw	a0,0(a0)
    80003760:	e89ff0ef          	jal	800035e8 <balloc>
    80003764:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003768:	02090d63          	beqz	s2,800037a2 <bmap+0x9a>
    8000376c:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000376e:	0929a023          	sw	s2,128(s3)
    80003772:	a011                	j	80003776 <bmap+0x6e>
    80003774:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003776:	85ca                	mv	a1,s2
    80003778:	0009a503          	lw	a0,0(s3)
    8000377c:	c09ff0ef          	jal	80003384 <bread>
    80003780:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003782:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003786:	02049713          	slli	a4,s1,0x20
    8000378a:	01e75593          	srli	a1,a4,0x1e
    8000378e:	00b784b3          	add	s1,a5,a1
    80003792:	0004a903          	lw	s2,0(s1)
    80003796:	00090e63          	beqz	s2,800037b2 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000379a:	8552                	mv	a0,s4
    8000379c:	cf1ff0ef          	jal	8000348c <brelse>
    return addr;
    800037a0:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800037a2:	854a                	mv	a0,s2
    800037a4:	70a2                	ld	ra,40(sp)
    800037a6:	7402                	ld	s0,32(sp)
    800037a8:	64e2                	ld	s1,24(sp)
    800037aa:	6942                	ld	s2,16(sp)
    800037ac:	69a2                	ld	s3,8(sp)
    800037ae:	6145                	addi	sp,sp,48
    800037b0:	8082                	ret
      addr = balloc(ip->dev);
    800037b2:	0009a503          	lw	a0,0(s3)
    800037b6:	e33ff0ef          	jal	800035e8 <balloc>
    800037ba:	0005091b          	sext.w	s2,a0
      if(addr){
    800037be:	fc090ee3          	beqz	s2,8000379a <bmap+0x92>
        a[bn] = addr;
    800037c2:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800037c6:	8552                	mv	a0,s4
    800037c8:	5f7000ef          	jal	800045be <log_write>
    800037cc:	b7f9                	j	8000379a <bmap+0x92>
    800037ce:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800037d0:	00005517          	auipc	a0,0x5
    800037d4:	07050513          	addi	a0,a0,112 # 80008840 <etext+0x840>
    800037d8:	808fd0ef          	jal	800007e0 <panic>

00000000800037dc <iget>:
{
    800037dc:	7179                	addi	sp,sp,-48
    800037de:	f406                	sd	ra,40(sp)
    800037e0:	f022                	sd	s0,32(sp)
    800037e2:	ec26                	sd	s1,24(sp)
    800037e4:	e84a                	sd	s2,16(sp)
    800037e6:	e44e                	sd	s3,8(sp)
    800037e8:	e052                	sd	s4,0(sp)
    800037ea:	1800                	addi	s0,sp,48
    800037ec:	89aa                	mv	s3,a0
    800037ee:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800037f0:	0023c517          	auipc	a0,0x23c
    800037f4:	37050513          	addi	a0,a0,880 # 8023fb60 <itable>
    800037f8:	d80fd0ef          	jal	80000d78 <acquire>
  empty = 0;
    800037fc:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800037fe:	0023c497          	auipc	s1,0x23c
    80003802:	37a48493          	addi	s1,s1,890 # 8023fb78 <itable+0x18>
    80003806:	0023e697          	auipc	a3,0x23e
    8000380a:	e0268693          	addi	a3,a3,-510 # 80241608 <log>
    8000380e:	a039                	j	8000381c <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003810:	02090963          	beqz	s2,80003842 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003814:	08848493          	addi	s1,s1,136
    80003818:	02d48863          	beq	s1,a3,80003848 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000381c:	449c                	lw	a5,8(s1)
    8000381e:	fef059e3          	blez	a5,80003810 <iget+0x34>
    80003822:	4098                	lw	a4,0(s1)
    80003824:	ff3716e3          	bne	a4,s3,80003810 <iget+0x34>
    80003828:	40d8                	lw	a4,4(s1)
    8000382a:	ff4713e3          	bne	a4,s4,80003810 <iget+0x34>
      ip->ref++;
    8000382e:	2785                	addiw	a5,a5,1
    80003830:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003832:	0023c517          	auipc	a0,0x23c
    80003836:	32e50513          	addi	a0,a0,814 # 8023fb60 <itable>
    8000383a:	dd6fd0ef          	jal	80000e10 <release>
      return ip;
    8000383e:	8926                	mv	s2,s1
    80003840:	a02d                	j	8000386a <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003842:	fbe9                	bnez	a5,80003814 <iget+0x38>
      empty = ip;
    80003844:	8926                	mv	s2,s1
    80003846:	b7f9                	j	80003814 <iget+0x38>
  if(empty == 0)
    80003848:	02090a63          	beqz	s2,8000387c <iget+0xa0>
  ip->dev = dev;
    8000384c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003850:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003854:	4785                	li	a5,1
    80003856:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000385a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000385e:	0023c517          	auipc	a0,0x23c
    80003862:	30250513          	addi	a0,a0,770 # 8023fb60 <itable>
    80003866:	daafd0ef          	jal	80000e10 <release>
}
    8000386a:	854a                	mv	a0,s2
    8000386c:	70a2                	ld	ra,40(sp)
    8000386e:	7402                	ld	s0,32(sp)
    80003870:	64e2                	ld	s1,24(sp)
    80003872:	6942                	ld	s2,16(sp)
    80003874:	69a2                	ld	s3,8(sp)
    80003876:	6a02                	ld	s4,0(sp)
    80003878:	6145                	addi	sp,sp,48
    8000387a:	8082                	ret
    panic("iget: no inodes");
    8000387c:	00005517          	auipc	a0,0x5
    80003880:	fdc50513          	addi	a0,a0,-36 # 80008858 <etext+0x858>
    80003884:	f5dfc0ef          	jal	800007e0 <panic>

0000000080003888 <iinit>:
{
    80003888:	7179                	addi	sp,sp,-48
    8000388a:	f406                	sd	ra,40(sp)
    8000388c:	f022                	sd	s0,32(sp)
    8000388e:	ec26                	sd	s1,24(sp)
    80003890:	e84a                	sd	s2,16(sp)
    80003892:	e44e                	sd	s3,8(sp)
    80003894:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003896:	00005597          	auipc	a1,0x5
    8000389a:	fd258593          	addi	a1,a1,-46 # 80008868 <etext+0x868>
    8000389e:	0023c517          	auipc	a0,0x23c
    800038a2:	2c250513          	addi	a0,a0,706 # 8023fb60 <itable>
    800038a6:	c52fd0ef          	jal	80000cf8 <initlock>
  for(i = 0; i < NINODE; i++) {
    800038aa:	0023c497          	auipc	s1,0x23c
    800038ae:	2de48493          	addi	s1,s1,734 # 8023fb88 <itable+0x28>
    800038b2:	0023e997          	auipc	s3,0x23e
    800038b6:	d6698993          	addi	s3,s3,-666 # 80241618 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800038ba:	00005917          	auipc	s2,0x5
    800038be:	fb690913          	addi	s2,s2,-74 # 80008870 <etext+0x870>
    800038c2:	85ca                	mv	a1,s2
    800038c4:	8526                	mv	a0,s1
    800038c6:	5bb000ef          	jal	80004680 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800038ca:	08848493          	addi	s1,s1,136
    800038ce:	ff349ae3          	bne	s1,s3,800038c2 <iinit+0x3a>
}
    800038d2:	70a2                	ld	ra,40(sp)
    800038d4:	7402                	ld	s0,32(sp)
    800038d6:	64e2                	ld	s1,24(sp)
    800038d8:	6942                	ld	s2,16(sp)
    800038da:	69a2                	ld	s3,8(sp)
    800038dc:	6145                	addi	sp,sp,48
    800038de:	8082                	ret

00000000800038e0 <ialloc>:
{
    800038e0:	7139                	addi	sp,sp,-64
    800038e2:	fc06                	sd	ra,56(sp)
    800038e4:	f822                	sd	s0,48(sp)
    800038e6:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800038e8:	0023c717          	auipc	a4,0x23c
    800038ec:	26472703          	lw	a4,612(a4) # 8023fb4c <sb+0xc>
    800038f0:	4785                	li	a5,1
    800038f2:	06e7f063          	bgeu	a5,a4,80003952 <ialloc+0x72>
    800038f6:	f426                	sd	s1,40(sp)
    800038f8:	f04a                	sd	s2,32(sp)
    800038fa:	ec4e                	sd	s3,24(sp)
    800038fc:	e852                	sd	s4,16(sp)
    800038fe:	e456                	sd	s5,8(sp)
    80003900:	e05a                	sd	s6,0(sp)
    80003902:	8aaa                	mv	s5,a0
    80003904:	8b2e                	mv	s6,a1
    80003906:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003908:	0023ca17          	auipc	s4,0x23c
    8000390c:	238a0a13          	addi	s4,s4,568 # 8023fb40 <sb>
    80003910:	00495593          	srli	a1,s2,0x4
    80003914:	018a2783          	lw	a5,24(s4)
    80003918:	9dbd                	addw	a1,a1,a5
    8000391a:	8556                	mv	a0,s5
    8000391c:	a69ff0ef          	jal	80003384 <bread>
    80003920:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003922:	05850993          	addi	s3,a0,88
    80003926:	00f97793          	andi	a5,s2,15
    8000392a:	079a                	slli	a5,a5,0x6
    8000392c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000392e:	00099783          	lh	a5,0(s3)
    80003932:	cb9d                	beqz	a5,80003968 <ialloc+0x88>
    brelse(bp);
    80003934:	b59ff0ef          	jal	8000348c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003938:	0905                	addi	s2,s2,1
    8000393a:	00ca2703          	lw	a4,12(s4)
    8000393e:	0009079b          	sext.w	a5,s2
    80003942:	fce7e7e3          	bltu	a5,a4,80003910 <ialloc+0x30>
    80003946:	74a2                	ld	s1,40(sp)
    80003948:	7902                	ld	s2,32(sp)
    8000394a:	69e2                	ld	s3,24(sp)
    8000394c:	6a42                	ld	s4,16(sp)
    8000394e:	6aa2                	ld	s5,8(sp)
    80003950:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003952:	00005517          	auipc	a0,0x5
    80003956:	f2650513          	addi	a0,a0,-218 # 80008878 <etext+0x878>
    8000395a:	ba1fc0ef          	jal	800004fa <printf>
  return 0;
    8000395e:	4501                	li	a0,0
}
    80003960:	70e2                	ld	ra,56(sp)
    80003962:	7442                	ld	s0,48(sp)
    80003964:	6121                	addi	sp,sp,64
    80003966:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003968:	04000613          	li	a2,64
    8000396c:	4581                	li	a1,0
    8000396e:	854e                	mv	a0,s3
    80003970:	cdcfd0ef          	jal	80000e4c <memset>
      dip->type = type;
    80003974:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003978:	8526                	mv	a0,s1
    8000397a:	445000ef          	jal	800045be <log_write>
      brelse(bp);
    8000397e:	8526                	mv	a0,s1
    80003980:	b0dff0ef          	jal	8000348c <brelse>
      return iget(dev, inum);
    80003984:	0009059b          	sext.w	a1,s2
    80003988:	8556                	mv	a0,s5
    8000398a:	e53ff0ef          	jal	800037dc <iget>
    8000398e:	74a2                	ld	s1,40(sp)
    80003990:	7902                	ld	s2,32(sp)
    80003992:	69e2                	ld	s3,24(sp)
    80003994:	6a42                	ld	s4,16(sp)
    80003996:	6aa2                	ld	s5,8(sp)
    80003998:	6b02                	ld	s6,0(sp)
    8000399a:	b7d9                	j	80003960 <ialloc+0x80>

000000008000399c <iupdate>:
{
    8000399c:	1101                	addi	sp,sp,-32
    8000399e:	ec06                	sd	ra,24(sp)
    800039a0:	e822                	sd	s0,16(sp)
    800039a2:	e426                	sd	s1,8(sp)
    800039a4:	e04a                	sd	s2,0(sp)
    800039a6:	1000                	addi	s0,sp,32
    800039a8:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800039aa:	415c                	lw	a5,4(a0)
    800039ac:	0047d79b          	srliw	a5,a5,0x4
    800039b0:	0023c597          	auipc	a1,0x23c
    800039b4:	1a85a583          	lw	a1,424(a1) # 8023fb58 <sb+0x18>
    800039b8:	9dbd                	addw	a1,a1,a5
    800039ba:	4108                	lw	a0,0(a0)
    800039bc:	9c9ff0ef          	jal	80003384 <bread>
    800039c0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039c2:	05850793          	addi	a5,a0,88
    800039c6:	40d8                	lw	a4,4(s1)
    800039c8:	8b3d                	andi	a4,a4,15
    800039ca:	071a                	slli	a4,a4,0x6
    800039cc:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800039ce:	04449703          	lh	a4,68(s1)
    800039d2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800039d6:	04649703          	lh	a4,70(s1)
    800039da:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800039de:	04849703          	lh	a4,72(s1)
    800039e2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800039e6:	04a49703          	lh	a4,74(s1)
    800039ea:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800039ee:	44f8                	lw	a4,76(s1)
    800039f0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800039f2:	03400613          	li	a2,52
    800039f6:	05048593          	addi	a1,s1,80
    800039fa:	00c78513          	addi	a0,a5,12
    800039fe:	caafd0ef          	jal	80000ea8 <memmove>
  log_write(bp);
    80003a02:	854a                	mv	a0,s2
    80003a04:	3bb000ef          	jal	800045be <log_write>
  brelse(bp);
    80003a08:	854a                	mv	a0,s2
    80003a0a:	a83ff0ef          	jal	8000348c <brelse>
}
    80003a0e:	60e2                	ld	ra,24(sp)
    80003a10:	6442                	ld	s0,16(sp)
    80003a12:	64a2                	ld	s1,8(sp)
    80003a14:	6902                	ld	s2,0(sp)
    80003a16:	6105                	addi	sp,sp,32
    80003a18:	8082                	ret

0000000080003a1a <idup>:
{
    80003a1a:	1101                	addi	sp,sp,-32
    80003a1c:	ec06                	sd	ra,24(sp)
    80003a1e:	e822                	sd	s0,16(sp)
    80003a20:	e426                	sd	s1,8(sp)
    80003a22:	1000                	addi	s0,sp,32
    80003a24:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003a26:	0023c517          	auipc	a0,0x23c
    80003a2a:	13a50513          	addi	a0,a0,314 # 8023fb60 <itable>
    80003a2e:	b4afd0ef          	jal	80000d78 <acquire>
  ip->ref++;
    80003a32:	449c                	lw	a5,8(s1)
    80003a34:	2785                	addiw	a5,a5,1
    80003a36:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a38:	0023c517          	auipc	a0,0x23c
    80003a3c:	12850513          	addi	a0,a0,296 # 8023fb60 <itable>
    80003a40:	bd0fd0ef          	jal	80000e10 <release>
}
    80003a44:	8526                	mv	a0,s1
    80003a46:	60e2                	ld	ra,24(sp)
    80003a48:	6442                	ld	s0,16(sp)
    80003a4a:	64a2                	ld	s1,8(sp)
    80003a4c:	6105                	addi	sp,sp,32
    80003a4e:	8082                	ret

0000000080003a50 <ilock>:
{
    80003a50:	1101                	addi	sp,sp,-32
    80003a52:	ec06                	sd	ra,24(sp)
    80003a54:	e822                	sd	s0,16(sp)
    80003a56:	e426                	sd	s1,8(sp)
    80003a58:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003a5a:	cd19                	beqz	a0,80003a78 <ilock+0x28>
    80003a5c:	84aa                	mv	s1,a0
    80003a5e:	451c                	lw	a5,8(a0)
    80003a60:	00f05c63          	blez	a5,80003a78 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003a64:	0541                	addi	a0,a0,16
    80003a66:	451000ef          	jal	800046b6 <acquiresleep>
  if(ip->valid == 0){
    80003a6a:	40bc                	lw	a5,64(s1)
    80003a6c:	cf89                	beqz	a5,80003a86 <ilock+0x36>
}
    80003a6e:	60e2                	ld	ra,24(sp)
    80003a70:	6442                	ld	s0,16(sp)
    80003a72:	64a2                	ld	s1,8(sp)
    80003a74:	6105                	addi	sp,sp,32
    80003a76:	8082                	ret
    80003a78:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003a7a:	00005517          	auipc	a0,0x5
    80003a7e:	e1650513          	addi	a0,a0,-490 # 80008890 <etext+0x890>
    80003a82:	d5ffc0ef          	jal	800007e0 <panic>
    80003a86:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a88:	40dc                	lw	a5,4(s1)
    80003a8a:	0047d79b          	srliw	a5,a5,0x4
    80003a8e:	0023c597          	auipc	a1,0x23c
    80003a92:	0ca5a583          	lw	a1,202(a1) # 8023fb58 <sb+0x18>
    80003a96:	9dbd                	addw	a1,a1,a5
    80003a98:	4088                	lw	a0,0(s1)
    80003a9a:	8ebff0ef          	jal	80003384 <bread>
    80003a9e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003aa0:	05850593          	addi	a1,a0,88
    80003aa4:	40dc                	lw	a5,4(s1)
    80003aa6:	8bbd                	andi	a5,a5,15
    80003aa8:	079a                	slli	a5,a5,0x6
    80003aaa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003aac:	00059783          	lh	a5,0(a1)
    80003ab0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ab4:	00259783          	lh	a5,2(a1)
    80003ab8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003abc:	00459783          	lh	a5,4(a1)
    80003ac0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003ac4:	00659783          	lh	a5,6(a1)
    80003ac8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003acc:	459c                	lw	a5,8(a1)
    80003ace:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ad0:	03400613          	li	a2,52
    80003ad4:	05b1                	addi	a1,a1,12
    80003ad6:	05048513          	addi	a0,s1,80
    80003ada:	bcefd0ef          	jal	80000ea8 <memmove>
    brelse(bp);
    80003ade:	854a                	mv	a0,s2
    80003ae0:	9adff0ef          	jal	8000348c <brelse>
    ip->valid = 1;
    80003ae4:	4785                	li	a5,1
    80003ae6:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ae8:	04449783          	lh	a5,68(s1)
    80003aec:	c399                	beqz	a5,80003af2 <ilock+0xa2>
    80003aee:	6902                	ld	s2,0(sp)
    80003af0:	bfbd                	j	80003a6e <ilock+0x1e>
      panic("ilock: no type");
    80003af2:	00005517          	auipc	a0,0x5
    80003af6:	da650513          	addi	a0,a0,-602 # 80008898 <etext+0x898>
    80003afa:	ce7fc0ef          	jal	800007e0 <panic>

0000000080003afe <iunlock>:
{
    80003afe:	1101                	addi	sp,sp,-32
    80003b00:	ec06                	sd	ra,24(sp)
    80003b02:	e822                	sd	s0,16(sp)
    80003b04:	e426                	sd	s1,8(sp)
    80003b06:	e04a                	sd	s2,0(sp)
    80003b08:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003b0a:	c505                	beqz	a0,80003b32 <iunlock+0x34>
    80003b0c:	84aa                	mv	s1,a0
    80003b0e:	01050913          	addi	s2,a0,16
    80003b12:	854a                	mv	a0,s2
    80003b14:	421000ef          	jal	80004734 <holdingsleep>
    80003b18:	cd09                	beqz	a0,80003b32 <iunlock+0x34>
    80003b1a:	449c                	lw	a5,8(s1)
    80003b1c:	00f05b63          	blez	a5,80003b32 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003b20:	854a                	mv	a0,s2
    80003b22:	3db000ef          	jal	800046fc <releasesleep>
}
    80003b26:	60e2                	ld	ra,24(sp)
    80003b28:	6442                	ld	s0,16(sp)
    80003b2a:	64a2                	ld	s1,8(sp)
    80003b2c:	6902                	ld	s2,0(sp)
    80003b2e:	6105                	addi	sp,sp,32
    80003b30:	8082                	ret
    panic("iunlock");
    80003b32:	00005517          	auipc	a0,0x5
    80003b36:	d7650513          	addi	a0,a0,-650 # 800088a8 <etext+0x8a8>
    80003b3a:	ca7fc0ef          	jal	800007e0 <panic>

0000000080003b3e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003b3e:	7179                	addi	sp,sp,-48
    80003b40:	f406                	sd	ra,40(sp)
    80003b42:	f022                	sd	s0,32(sp)
    80003b44:	ec26                	sd	s1,24(sp)
    80003b46:	e84a                	sd	s2,16(sp)
    80003b48:	e44e                	sd	s3,8(sp)
    80003b4a:	1800                	addi	s0,sp,48
    80003b4c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003b4e:	05050493          	addi	s1,a0,80
    80003b52:	08050913          	addi	s2,a0,128
    80003b56:	a021                	j	80003b5e <itrunc+0x20>
    80003b58:	0491                	addi	s1,s1,4
    80003b5a:	01248b63          	beq	s1,s2,80003b70 <itrunc+0x32>
    if(ip->addrs[i]){
    80003b5e:	408c                	lw	a1,0(s1)
    80003b60:	dde5                	beqz	a1,80003b58 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003b62:	0009a503          	lw	a0,0(s3)
    80003b66:	a17ff0ef          	jal	8000357c <bfree>
      ip->addrs[i] = 0;
    80003b6a:	0004a023          	sw	zero,0(s1)
    80003b6e:	b7ed                	j	80003b58 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003b70:	0809a583          	lw	a1,128(s3)
    80003b74:	ed89                	bnez	a1,80003b8e <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003b76:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003b7a:	854e                	mv	a0,s3
    80003b7c:	e21ff0ef          	jal	8000399c <iupdate>
}
    80003b80:	70a2                	ld	ra,40(sp)
    80003b82:	7402                	ld	s0,32(sp)
    80003b84:	64e2                	ld	s1,24(sp)
    80003b86:	6942                	ld	s2,16(sp)
    80003b88:	69a2                	ld	s3,8(sp)
    80003b8a:	6145                	addi	sp,sp,48
    80003b8c:	8082                	ret
    80003b8e:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b90:	0009a503          	lw	a0,0(s3)
    80003b94:	ff0ff0ef          	jal	80003384 <bread>
    80003b98:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b9a:	05850493          	addi	s1,a0,88
    80003b9e:	45850913          	addi	s2,a0,1112
    80003ba2:	a021                	j	80003baa <itrunc+0x6c>
    80003ba4:	0491                	addi	s1,s1,4
    80003ba6:	01248963          	beq	s1,s2,80003bb8 <itrunc+0x7a>
      if(a[j])
    80003baa:	408c                	lw	a1,0(s1)
    80003bac:	dde5                	beqz	a1,80003ba4 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003bae:	0009a503          	lw	a0,0(s3)
    80003bb2:	9cbff0ef          	jal	8000357c <bfree>
    80003bb6:	b7fd                	j	80003ba4 <itrunc+0x66>
    brelse(bp);
    80003bb8:	8552                	mv	a0,s4
    80003bba:	8d3ff0ef          	jal	8000348c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003bbe:	0809a583          	lw	a1,128(s3)
    80003bc2:	0009a503          	lw	a0,0(s3)
    80003bc6:	9b7ff0ef          	jal	8000357c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003bca:	0809a023          	sw	zero,128(s3)
    80003bce:	6a02                	ld	s4,0(sp)
    80003bd0:	b75d                	j	80003b76 <itrunc+0x38>

0000000080003bd2 <iput>:
{
    80003bd2:	1101                	addi	sp,sp,-32
    80003bd4:	ec06                	sd	ra,24(sp)
    80003bd6:	e822                	sd	s0,16(sp)
    80003bd8:	e426                	sd	s1,8(sp)
    80003bda:	1000                	addi	s0,sp,32
    80003bdc:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003bde:	0023c517          	auipc	a0,0x23c
    80003be2:	f8250513          	addi	a0,a0,-126 # 8023fb60 <itable>
    80003be6:	992fd0ef          	jal	80000d78 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003bea:	4498                	lw	a4,8(s1)
    80003bec:	4785                	li	a5,1
    80003bee:	02f70063          	beq	a4,a5,80003c0e <iput+0x3c>
  ip->ref--;
    80003bf2:	449c                	lw	a5,8(s1)
    80003bf4:	37fd                	addiw	a5,a5,-1
    80003bf6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003bf8:	0023c517          	auipc	a0,0x23c
    80003bfc:	f6850513          	addi	a0,a0,-152 # 8023fb60 <itable>
    80003c00:	a10fd0ef          	jal	80000e10 <release>
}
    80003c04:	60e2                	ld	ra,24(sp)
    80003c06:	6442                	ld	s0,16(sp)
    80003c08:	64a2                	ld	s1,8(sp)
    80003c0a:	6105                	addi	sp,sp,32
    80003c0c:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003c0e:	40bc                	lw	a5,64(s1)
    80003c10:	d3ed                	beqz	a5,80003bf2 <iput+0x20>
    80003c12:	04a49783          	lh	a5,74(s1)
    80003c16:	fff1                	bnez	a5,80003bf2 <iput+0x20>
    80003c18:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003c1a:	01048913          	addi	s2,s1,16
    80003c1e:	854a                	mv	a0,s2
    80003c20:	297000ef          	jal	800046b6 <acquiresleep>
    release(&itable.lock);
    80003c24:	0023c517          	auipc	a0,0x23c
    80003c28:	f3c50513          	addi	a0,a0,-196 # 8023fb60 <itable>
    80003c2c:	9e4fd0ef          	jal	80000e10 <release>
    itrunc(ip);
    80003c30:	8526                	mv	a0,s1
    80003c32:	f0dff0ef          	jal	80003b3e <itrunc>
    ip->type = 0;
    80003c36:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003c3a:	8526                	mv	a0,s1
    80003c3c:	d61ff0ef          	jal	8000399c <iupdate>
    ip->valid = 0;
    80003c40:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003c44:	854a                	mv	a0,s2
    80003c46:	2b7000ef          	jal	800046fc <releasesleep>
    acquire(&itable.lock);
    80003c4a:	0023c517          	auipc	a0,0x23c
    80003c4e:	f1650513          	addi	a0,a0,-234 # 8023fb60 <itable>
    80003c52:	926fd0ef          	jal	80000d78 <acquire>
    80003c56:	6902                	ld	s2,0(sp)
    80003c58:	bf69                	j	80003bf2 <iput+0x20>

0000000080003c5a <iunlockput>:
{
    80003c5a:	1101                	addi	sp,sp,-32
    80003c5c:	ec06                	sd	ra,24(sp)
    80003c5e:	e822                	sd	s0,16(sp)
    80003c60:	e426                	sd	s1,8(sp)
    80003c62:	1000                	addi	s0,sp,32
    80003c64:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c66:	e99ff0ef          	jal	80003afe <iunlock>
  iput(ip);
    80003c6a:	8526                	mv	a0,s1
    80003c6c:	f67ff0ef          	jal	80003bd2 <iput>
}
    80003c70:	60e2                	ld	ra,24(sp)
    80003c72:	6442                	ld	s0,16(sp)
    80003c74:	64a2                	ld	s1,8(sp)
    80003c76:	6105                	addi	sp,sp,32
    80003c78:	8082                	ret

0000000080003c7a <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c7a:	0023c717          	auipc	a4,0x23c
    80003c7e:	ed272703          	lw	a4,-302(a4) # 8023fb4c <sb+0xc>
    80003c82:	4785                	li	a5,1
    80003c84:	0ae7ff63          	bgeu	a5,a4,80003d42 <ireclaim+0xc8>
{
    80003c88:	7139                	addi	sp,sp,-64
    80003c8a:	fc06                	sd	ra,56(sp)
    80003c8c:	f822                	sd	s0,48(sp)
    80003c8e:	f426                	sd	s1,40(sp)
    80003c90:	f04a                	sd	s2,32(sp)
    80003c92:	ec4e                	sd	s3,24(sp)
    80003c94:	e852                	sd	s4,16(sp)
    80003c96:	e456                	sd	s5,8(sp)
    80003c98:	e05a                	sd	s6,0(sp)
    80003c9a:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c9c:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003c9e:	00050a1b          	sext.w	s4,a0
    80003ca2:	0023ca97          	auipc	s5,0x23c
    80003ca6:	e9ea8a93          	addi	s5,s5,-354 # 8023fb40 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003caa:	00005b17          	auipc	s6,0x5
    80003cae:	c06b0b13          	addi	s6,s6,-1018 # 800088b0 <etext+0x8b0>
    80003cb2:	a099                	j	80003cf8 <ireclaim+0x7e>
    80003cb4:	85ce                	mv	a1,s3
    80003cb6:	855a                	mv	a0,s6
    80003cb8:	843fc0ef          	jal	800004fa <printf>
      ip = iget(dev, inum);
    80003cbc:	85ce                	mv	a1,s3
    80003cbe:	8552                	mv	a0,s4
    80003cc0:	b1dff0ef          	jal	800037dc <iget>
    80003cc4:	89aa                	mv	s3,a0
    brelse(bp);
    80003cc6:	854a                	mv	a0,s2
    80003cc8:	fc4ff0ef          	jal	8000348c <brelse>
    if (ip) {
    80003ccc:	00098f63          	beqz	s3,80003cea <ireclaim+0x70>
      begin_op();
    80003cd0:	76a000ef          	jal	8000443a <begin_op>
      ilock(ip);
    80003cd4:	854e                	mv	a0,s3
    80003cd6:	d7bff0ef          	jal	80003a50 <ilock>
      iunlock(ip);
    80003cda:	854e                	mv	a0,s3
    80003cdc:	e23ff0ef          	jal	80003afe <iunlock>
      iput(ip);
    80003ce0:	854e                	mv	a0,s3
    80003ce2:	ef1ff0ef          	jal	80003bd2 <iput>
      end_op();
    80003ce6:	7be000ef          	jal	800044a4 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003cea:	0485                	addi	s1,s1,1
    80003cec:	00caa703          	lw	a4,12(s5)
    80003cf0:	0004879b          	sext.w	a5,s1
    80003cf4:	02e7fd63          	bgeu	a5,a4,80003d2e <ireclaim+0xb4>
    80003cf8:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003cfc:	0044d593          	srli	a1,s1,0x4
    80003d00:	018aa783          	lw	a5,24(s5)
    80003d04:	9dbd                	addw	a1,a1,a5
    80003d06:	8552                	mv	a0,s4
    80003d08:	e7cff0ef          	jal	80003384 <bread>
    80003d0c:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003d0e:	05850793          	addi	a5,a0,88
    80003d12:	00f9f713          	andi	a4,s3,15
    80003d16:	071a                	slli	a4,a4,0x6
    80003d18:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003d1a:	00079703          	lh	a4,0(a5)
    80003d1e:	c701                	beqz	a4,80003d26 <ireclaim+0xac>
    80003d20:	00679783          	lh	a5,6(a5)
    80003d24:	dbc1                	beqz	a5,80003cb4 <ireclaim+0x3a>
    brelse(bp);
    80003d26:	854a                	mv	a0,s2
    80003d28:	f64ff0ef          	jal	8000348c <brelse>
    if (ip) {
    80003d2c:	bf7d                	j	80003cea <ireclaim+0x70>
}
    80003d2e:	70e2                	ld	ra,56(sp)
    80003d30:	7442                	ld	s0,48(sp)
    80003d32:	74a2                	ld	s1,40(sp)
    80003d34:	7902                	ld	s2,32(sp)
    80003d36:	69e2                	ld	s3,24(sp)
    80003d38:	6a42                	ld	s4,16(sp)
    80003d3a:	6aa2                	ld	s5,8(sp)
    80003d3c:	6b02                	ld	s6,0(sp)
    80003d3e:	6121                	addi	sp,sp,64
    80003d40:	8082                	ret
    80003d42:	8082                	ret

0000000080003d44 <fsinit>:
fsinit(int dev) {
    80003d44:	7179                	addi	sp,sp,-48
    80003d46:	f406                	sd	ra,40(sp)
    80003d48:	f022                	sd	s0,32(sp)
    80003d4a:	ec26                	sd	s1,24(sp)
    80003d4c:	e84a                	sd	s2,16(sp)
    80003d4e:	e44e                	sd	s3,8(sp)
    80003d50:	1800                	addi	s0,sp,48
    80003d52:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003d54:	4585                	li	a1,1
    80003d56:	e2eff0ef          	jal	80003384 <bread>
    80003d5a:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d5c:	0023c997          	auipc	s3,0x23c
    80003d60:	de498993          	addi	s3,s3,-540 # 8023fb40 <sb>
    80003d64:	02000613          	li	a2,32
    80003d68:	05850593          	addi	a1,a0,88
    80003d6c:	854e                	mv	a0,s3
    80003d6e:	93afd0ef          	jal	80000ea8 <memmove>
  brelse(bp);
    80003d72:	854a                	mv	a0,s2
    80003d74:	f18ff0ef          	jal	8000348c <brelse>
  if(sb.magic != FSMAGIC)
    80003d78:	0009a703          	lw	a4,0(s3)
    80003d7c:	102037b7          	lui	a5,0x10203
    80003d80:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d84:	02f71363          	bne	a4,a5,80003daa <fsinit+0x66>
  initlog(dev, &sb);
    80003d88:	0023c597          	auipc	a1,0x23c
    80003d8c:	db858593          	addi	a1,a1,-584 # 8023fb40 <sb>
    80003d90:	8526                	mv	a0,s1
    80003d92:	62a000ef          	jal	800043bc <initlog>
  ireclaim(dev);
    80003d96:	8526                	mv	a0,s1
    80003d98:	ee3ff0ef          	jal	80003c7a <ireclaim>
}
    80003d9c:	70a2                	ld	ra,40(sp)
    80003d9e:	7402                	ld	s0,32(sp)
    80003da0:	64e2                	ld	s1,24(sp)
    80003da2:	6942                	ld	s2,16(sp)
    80003da4:	69a2                	ld	s3,8(sp)
    80003da6:	6145                	addi	sp,sp,48
    80003da8:	8082                	ret
    panic("invalid file system");
    80003daa:	00005517          	auipc	a0,0x5
    80003dae:	b2650513          	addi	a0,a0,-1242 # 800088d0 <etext+0x8d0>
    80003db2:	a2ffc0ef          	jal	800007e0 <panic>

0000000080003db6 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003db6:	1141                	addi	sp,sp,-16
    80003db8:	e422                	sd	s0,8(sp)
    80003dba:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003dbc:	411c                	lw	a5,0(a0)
    80003dbe:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003dc0:	415c                	lw	a5,4(a0)
    80003dc2:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003dc4:	04451783          	lh	a5,68(a0)
    80003dc8:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003dcc:	04a51783          	lh	a5,74(a0)
    80003dd0:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003dd4:	04c56783          	lwu	a5,76(a0)
    80003dd8:	e99c                	sd	a5,16(a1)
}
    80003dda:	6422                	ld	s0,8(sp)
    80003ddc:	0141                	addi	sp,sp,16
    80003dde:	8082                	ret

0000000080003de0 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003de0:	457c                	lw	a5,76(a0)
    80003de2:	0ed7eb63          	bltu	a5,a3,80003ed8 <readi+0xf8>
{
    80003de6:	7159                	addi	sp,sp,-112
    80003de8:	f486                	sd	ra,104(sp)
    80003dea:	f0a2                	sd	s0,96(sp)
    80003dec:	eca6                	sd	s1,88(sp)
    80003dee:	e0d2                	sd	s4,64(sp)
    80003df0:	fc56                	sd	s5,56(sp)
    80003df2:	f85a                	sd	s6,48(sp)
    80003df4:	f45e                	sd	s7,40(sp)
    80003df6:	1880                	addi	s0,sp,112
    80003df8:	8b2a                	mv	s6,a0
    80003dfa:	8bae                	mv	s7,a1
    80003dfc:	8a32                	mv	s4,a2
    80003dfe:	84b6                	mv	s1,a3
    80003e00:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e02:	9f35                	addw	a4,a4,a3
    return 0;
    80003e04:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e06:	0cd76063          	bltu	a4,a3,80003ec6 <readi+0xe6>
    80003e0a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003e0c:	00e7f463          	bgeu	a5,a4,80003e14 <readi+0x34>
    n = ip->size - off;
    80003e10:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e14:	080a8f63          	beqz	s5,80003eb2 <readi+0xd2>
    80003e18:	e8ca                	sd	s2,80(sp)
    80003e1a:	f062                	sd	s8,32(sp)
    80003e1c:	ec66                	sd	s9,24(sp)
    80003e1e:	e86a                	sd	s10,16(sp)
    80003e20:	e46e                	sd	s11,8(sp)
    80003e22:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e24:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e28:	5c7d                	li	s8,-1
    80003e2a:	a80d                	j	80003e5c <readi+0x7c>
    80003e2c:	020d1d93          	slli	s11,s10,0x20
    80003e30:	020ddd93          	srli	s11,s11,0x20
    80003e34:	05890613          	addi	a2,s2,88
    80003e38:	86ee                	mv	a3,s11
    80003e3a:	963a                	add	a2,a2,a4
    80003e3c:	85d2                	mv	a1,s4
    80003e3e:	855e                	mv	a0,s7
    80003e40:	82ffe0ef          	jal	8000266e <either_copyout>
    80003e44:	05850763          	beq	a0,s8,80003e92 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e48:	854a                	mv	a0,s2
    80003e4a:	e42ff0ef          	jal	8000348c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e4e:	013d09bb          	addw	s3,s10,s3
    80003e52:	009d04bb          	addw	s1,s10,s1
    80003e56:	9a6e                	add	s4,s4,s11
    80003e58:	0559f763          	bgeu	s3,s5,80003ea6 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003e5c:	00a4d59b          	srliw	a1,s1,0xa
    80003e60:	855a                	mv	a0,s6
    80003e62:	8a7ff0ef          	jal	80003708 <bmap>
    80003e66:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003e6a:	c5b1                	beqz	a1,80003eb6 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003e6c:	000b2503          	lw	a0,0(s6)
    80003e70:	d14ff0ef          	jal	80003384 <bread>
    80003e74:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e76:	3ff4f713          	andi	a4,s1,1023
    80003e7a:	40ec87bb          	subw	a5,s9,a4
    80003e7e:	413a86bb          	subw	a3,s5,s3
    80003e82:	8d3e                	mv	s10,a5
    80003e84:	2781                	sext.w	a5,a5
    80003e86:	0006861b          	sext.w	a2,a3
    80003e8a:	faf671e3          	bgeu	a2,a5,80003e2c <readi+0x4c>
    80003e8e:	8d36                	mv	s10,a3
    80003e90:	bf71                	j	80003e2c <readi+0x4c>
      brelse(bp);
    80003e92:	854a                	mv	a0,s2
    80003e94:	df8ff0ef          	jal	8000348c <brelse>
      tot = -1;
    80003e98:	59fd                	li	s3,-1
      break;
    80003e9a:	6946                	ld	s2,80(sp)
    80003e9c:	7c02                	ld	s8,32(sp)
    80003e9e:	6ce2                	ld	s9,24(sp)
    80003ea0:	6d42                	ld	s10,16(sp)
    80003ea2:	6da2                	ld	s11,8(sp)
    80003ea4:	a831                	j	80003ec0 <readi+0xe0>
    80003ea6:	6946                	ld	s2,80(sp)
    80003ea8:	7c02                	ld	s8,32(sp)
    80003eaa:	6ce2                	ld	s9,24(sp)
    80003eac:	6d42                	ld	s10,16(sp)
    80003eae:	6da2                	ld	s11,8(sp)
    80003eb0:	a801                	j	80003ec0 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eb2:	89d6                	mv	s3,s5
    80003eb4:	a031                	j	80003ec0 <readi+0xe0>
    80003eb6:	6946                	ld	s2,80(sp)
    80003eb8:	7c02                	ld	s8,32(sp)
    80003eba:	6ce2                	ld	s9,24(sp)
    80003ebc:	6d42                	ld	s10,16(sp)
    80003ebe:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003ec0:	0009851b          	sext.w	a0,s3
    80003ec4:	69a6                	ld	s3,72(sp)
}
    80003ec6:	70a6                	ld	ra,104(sp)
    80003ec8:	7406                	ld	s0,96(sp)
    80003eca:	64e6                	ld	s1,88(sp)
    80003ecc:	6a06                	ld	s4,64(sp)
    80003ece:	7ae2                	ld	s5,56(sp)
    80003ed0:	7b42                	ld	s6,48(sp)
    80003ed2:	7ba2                	ld	s7,40(sp)
    80003ed4:	6165                	addi	sp,sp,112
    80003ed6:	8082                	ret
    return 0;
    80003ed8:	4501                	li	a0,0
}
    80003eda:	8082                	ret

0000000080003edc <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003edc:	457c                	lw	a5,76(a0)
    80003ede:	10d7e063          	bltu	a5,a3,80003fde <writei+0x102>
{
    80003ee2:	7159                	addi	sp,sp,-112
    80003ee4:	f486                	sd	ra,104(sp)
    80003ee6:	f0a2                	sd	s0,96(sp)
    80003ee8:	e8ca                	sd	s2,80(sp)
    80003eea:	e0d2                	sd	s4,64(sp)
    80003eec:	fc56                	sd	s5,56(sp)
    80003eee:	f85a                	sd	s6,48(sp)
    80003ef0:	f45e                	sd	s7,40(sp)
    80003ef2:	1880                	addi	s0,sp,112
    80003ef4:	8aaa                	mv	s5,a0
    80003ef6:	8bae                	mv	s7,a1
    80003ef8:	8a32                	mv	s4,a2
    80003efa:	8936                	mv	s2,a3
    80003efc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003efe:	00e687bb          	addw	a5,a3,a4
    80003f02:	0ed7e063          	bltu	a5,a3,80003fe2 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f06:	00043737          	lui	a4,0x43
    80003f0a:	0cf76e63          	bltu	a4,a5,80003fe6 <writei+0x10a>
    80003f0e:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f10:	0a0b0f63          	beqz	s6,80003fce <writei+0xf2>
    80003f14:	eca6                	sd	s1,88(sp)
    80003f16:	f062                	sd	s8,32(sp)
    80003f18:	ec66                	sd	s9,24(sp)
    80003f1a:	e86a                	sd	s10,16(sp)
    80003f1c:	e46e                	sd	s11,8(sp)
    80003f1e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f20:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f24:	5c7d                	li	s8,-1
    80003f26:	a825                	j	80003f5e <writei+0x82>
    80003f28:	020d1d93          	slli	s11,s10,0x20
    80003f2c:	020ddd93          	srli	s11,s11,0x20
    80003f30:	05848513          	addi	a0,s1,88
    80003f34:	86ee                	mv	a3,s11
    80003f36:	8652                	mv	a2,s4
    80003f38:	85de                	mv	a1,s7
    80003f3a:	953a                	add	a0,a0,a4
    80003f3c:	f7cfe0ef          	jal	800026b8 <either_copyin>
    80003f40:	05850a63          	beq	a0,s8,80003f94 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f44:	8526                	mv	a0,s1
    80003f46:	678000ef          	jal	800045be <log_write>
    brelse(bp);
    80003f4a:	8526                	mv	a0,s1
    80003f4c:	d40ff0ef          	jal	8000348c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f50:	013d09bb          	addw	s3,s10,s3
    80003f54:	012d093b          	addw	s2,s10,s2
    80003f58:	9a6e                	add	s4,s4,s11
    80003f5a:	0569f063          	bgeu	s3,s6,80003f9a <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003f5e:	00a9559b          	srliw	a1,s2,0xa
    80003f62:	8556                	mv	a0,s5
    80003f64:	fa4ff0ef          	jal	80003708 <bmap>
    80003f68:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f6c:	c59d                	beqz	a1,80003f9a <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003f6e:	000aa503          	lw	a0,0(s5)
    80003f72:	c12ff0ef          	jal	80003384 <bread>
    80003f76:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f78:	3ff97713          	andi	a4,s2,1023
    80003f7c:	40ec87bb          	subw	a5,s9,a4
    80003f80:	413b06bb          	subw	a3,s6,s3
    80003f84:	8d3e                	mv	s10,a5
    80003f86:	2781                	sext.w	a5,a5
    80003f88:	0006861b          	sext.w	a2,a3
    80003f8c:	f8f67ee3          	bgeu	a2,a5,80003f28 <writei+0x4c>
    80003f90:	8d36                	mv	s10,a3
    80003f92:	bf59                	j	80003f28 <writei+0x4c>
      brelse(bp);
    80003f94:	8526                	mv	a0,s1
    80003f96:	cf6ff0ef          	jal	8000348c <brelse>
  }

  if(off > ip->size)
    80003f9a:	04caa783          	lw	a5,76(s5)
    80003f9e:	0327fa63          	bgeu	a5,s2,80003fd2 <writei+0xf6>
    ip->size = off;
    80003fa2:	052aa623          	sw	s2,76(s5)
    80003fa6:	64e6                	ld	s1,88(sp)
    80003fa8:	7c02                	ld	s8,32(sp)
    80003faa:	6ce2                	ld	s9,24(sp)
    80003fac:	6d42                	ld	s10,16(sp)
    80003fae:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003fb0:	8556                	mv	a0,s5
    80003fb2:	9ebff0ef          	jal	8000399c <iupdate>

  return tot;
    80003fb6:	0009851b          	sext.w	a0,s3
    80003fba:	69a6                	ld	s3,72(sp)
}
    80003fbc:	70a6                	ld	ra,104(sp)
    80003fbe:	7406                	ld	s0,96(sp)
    80003fc0:	6946                	ld	s2,80(sp)
    80003fc2:	6a06                	ld	s4,64(sp)
    80003fc4:	7ae2                	ld	s5,56(sp)
    80003fc6:	7b42                	ld	s6,48(sp)
    80003fc8:	7ba2                	ld	s7,40(sp)
    80003fca:	6165                	addi	sp,sp,112
    80003fcc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fce:	89da                	mv	s3,s6
    80003fd0:	b7c5                	j	80003fb0 <writei+0xd4>
    80003fd2:	64e6                	ld	s1,88(sp)
    80003fd4:	7c02                	ld	s8,32(sp)
    80003fd6:	6ce2                	ld	s9,24(sp)
    80003fd8:	6d42                	ld	s10,16(sp)
    80003fda:	6da2                	ld	s11,8(sp)
    80003fdc:	bfd1                	j	80003fb0 <writei+0xd4>
    return -1;
    80003fde:	557d                	li	a0,-1
}
    80003fe0:	8082                	ret
    return -1;
    80003fe2:	557d                	li	a0,-1
    80003fe4:	bfe1                	j	80003fbc <writei+0xe0>
    return -1;
    80003fe6:	557d                	li	a0,-1
    80003fe8:	bfd1                	j	80003fbc <writei+0xe0>

0000000080003fea <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003fea:	1141                	addi	sp,sp,-16
    80003fec:	e406                	sd	ra,8(sp)
    80003fee:	e022                	sd	s0,0(sp)
    80003ff0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003ff2:	4639                	li	a2,14
    80003ff4:	f25fc0ef          	jal	80000f18 <strncmp>
}
    80003ff8:	60a2                	ld	ra,8(sp)
    80003ffa:	6402                	ld	s0,0(sp)
    80003ffc:	0141                	addi	sp,sp,16
    80003ffe:	8082                	ret

0000000080004000 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004000:	7139                	addi	sp,sp,-64
    80004002:	fc06                	sd	ra,56(sp)
    80004004:	f822                	sd	s0,48(sp)
    80004006:	f426                	sd	s1,40(sp)
    80004008:	f04a                	sd	s2,32(sp)
    8000400a:	ec4e                	sd	s3,24(sp)
    8000400c:	e852                	sd	s4,16(sp)
    8000400e:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004010:	04451703          	lh	a4,68(a0)
    80004014:	4785                	li	a5,1
    80004016:	00f71a63          	bne	a4,a5,8000402a <dirlookup+0x2a>
    8000401a:	892a                	mv	s2,a0
    8000401c:	89ae                	mv	s3,a1
    8000401e:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004020:	457c                	lw	a5,76(a0)
    80004022:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004024:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004026:	e39d                	bnez	a5,8000404c <dirlookup+0x4c>
    80004028:	a095                	j	8000408c <dirlookup+0x8c>
    panic("dirlookup not DIR");
    8000402a:	00005517          	auipc	a0,0x5
    8000402e:	8be50513          	addi	a0,a0,-1858 # 800088e8 <etext+0x8e8>
    80004032:	faefc0ef          	jal	800007e0 <panic>
      panic("dirlookup read");
    80004036:	00005517          	auipc	a0,0x5
    8000403a:	8ca50513          	addi	a0,a0,-1846 # 80008900 <etext+0x900>
    8000403e:	fa2fc0ef          	jal	800007e0 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004042:	24c1                	addiw	s1,s1,16
    80004044:	04c92783          	lw	a5,76(s2)
    80004048:	04f4f163          	bgeu	s1,a5,8000408a <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000404c:	4741                	li	a4,16
    8000404e:	86a6                	mv	a3,s1
    80004050:	fc040613          	addi	a2,s0,-64
    80004054:	4581                	li	a1,0
    80004056:	854a                	mv	a0,s2
    80004058:	d89ff0ef          	jal	80003de0 <readi>
    8000405c:	47c1                	li	a5,16
    8000405e:	fcf51ce3          	bne	a0,a5,80004036 <dirlookup+0x36>
    if(de.inum == 0)
    80004062:	fc045783          	lhu	a5,-64(s0)
    80004066:	dff1                	beqz	a5,80004042 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80004068:	fc240593          	addi	a1,s0,-62
    8000406c:	854e                	mv	a0,s3
    8000406e:	f7dff0ef          	jal	80003fea <namecmp>
    80004072:	f961                	bnez	a0,80004042 <dirlookup+0x42>
      if(poff)
    80004074:	000a0463          	beqz	s4,8000407c <dirlookup+0x7c>
        *poff = off;
    80004078:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    8000407c:	fc045583          	lhu	a1,-64(s0)
    80004080:	00092503          	lw	a0,0(s2)
    80004084:	f58ff0ef          	jal	800037dc <iget>
    80004088:	a011                	j	8000408c <dirlookup+0x8c>
  return 0;
    8000408a:	4501                	li	a0,0
}
    8000408c:	70e2                	ld	ra,56(sp)
    8000408e:	7442                	ld	s0,48(sp)
    80004090:	74a2                	ld	s1,40(sp)
    80004092:	7902                	ld	s2,32(sp)
    80004094:	69e2                	ld	s3,24(sp)
    80004096:	6a42                	ld	s4,16(sp)
    80004098:	6121                	addi	sp,sp,64
    8000409a:	8082                	ret

000000008000409c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    8000409c:	711d                	addi	sp,sp,-96
    8000409e:	ec86                	sd	ra,88(sp)
    800040a0:	e8a2                	sd	s0,80(sp)
    800040a2:	e4a6                	sd	s1,72(sp)
    800040a4:	e0ca                	sd	s2,64(sp)
    800040a6:	fc4e                	sd	s3,56(sp)
    800040a8:	f852                	sd	s4,48(sp)
    800040aa:	f456                	sd	s5,40(sp)
    800040ac:	f05a                	sd	s6,32(sp)
    800040ae:	ec5e                	sd	s7,24(sp)
    800040b0:	e862                	sd	s8,16(sp)
    800040b2:	e466                	sd	s9,8(sp)
    800040b4:	1080                	addi	s0,sp,96
    800040b6:	84aa                	mv	s1,a0
    800040b8:	8b2e                	mv	s6,a1
    800040ba:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800040bc:	00054703          	lbu	a4,0(a0)
    800040c0:	02f00793          	li	a5,47
    800040c4:	00f70e63          	beq	a4,a5,800040e0 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800040c8:	b95fd0ef          	jal	80001c5c <myproc>
    800040cc:	15853503          	ld	a0,344(a0)
    800040d0:	94bff0ef          	jal	80003a1a <idup>
    800040d4:	8a2a                	mv	s4,a0
  while(*path == '/')
    800040d6:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800040da:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800040dc:	4b85                	li	s7,1
    800040de:	a871                	j	8000417a <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800040e0:	4585                	li	a1,1
    800040e2:	4505                	li	a0,1
    800040e4:	ef8ff0ef          	jal	800037dc <iget>
    800040e8:	8a2a                	mv	s4,a0
    800040ea:	b7f5                	j	800040d6 <namex+0x3a>
      iunlockput(ip);
    800040ec:	8552                	mv	a0,s4
    800040ee:	b6dff0ef          	jal	80003c5a <iunlockput>
      return 0;
    800040f2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800040f4:	8552                	mv	a0,s4
    800040f6:	60e6                	ld	ra,88(sp)
    800040f8:	6446                	ld	s0,80(sp)
    800040fa:	64a6                	ld	s1,72(sp)
    800040fc:	6906                	ld	s2,64(sp)
    800040fe:	79e2                	ld	s3,56(sp)
    80004100:	7a42                	ld	s4,48(sp)
    80004102:	7aa2                	ld	s5,40(sp)
    80004104:	7b02                	ld	s6,32(sp)
    80004106:	6be2                	ld	s7,24(sp)
    80004108:	6c42                	ld	s8,16(sp)
    8000410a:	6ca2                	ld	s9,8(sp)
    8000410c:	6125                	addi	sp,sp,96
    8000410e:	8082                	ret
      iunlock(ip);
    80004110:	8552                	mv	a0,s4
    80004112:	9edff0ef          	jal	80003afe <iunlock>
      return ip;
    80004116:	bff9                	j	800040f4 <namex+0x58>
      iunlockput(ip);
    80004118:	8552                	mv	a0,s4
    8000411a:	b41ff0ef          	jal	80003c5a <iunlockput>
      return 0;
    8000411e:	8a4e                	mv	s4,s3
    80004120:	bfd1                	j	800040f4 <namex+0x58>
  len = path - s;
    80004122:	40998633          	sub	a2,s3,s1
    80004126:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    8000412a:	099c5063          	bge	s8,s9,800041aa <namex+0x10e>
    memmove(name, s, DIRSIZ);
    8000412e:	4639                	li	a2,14
    80004130:	85a6                	mv	a1,s1
    80004132:	8556                	mv	a0,s5
    80004134:	d75fc0ef          	jal	80000ea8 <memmove>
    80004138:	84ce                	mv	s1,s3
  while(*path == '/')
    8000413a:	0004c783          	lbu	a5,0(s1)
    8000413e:	01279763          	bne	a5,s2,8000414c <namex+0xb0>
    path++;
    80004142:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004144:	0004c783          	lbu	a5,0(s1)
    80004148:	ff278de3          	beq	a5,s2,80004142 <namex+0xa6>
    ilock(ip);
    8000414c:	8552                	mv	a0,s4
    8000414e:	903ff0ef          	jal	80003a50 <ilock>
    if(ip->type != T_DIR){
    80004152:	044a1783          	lh	a5,68(s4)
    80004156:	f9779be3          	bne	a5,s7,800040ec <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000415a:	000b0563          	beqz	s6,80004164 <namex+0xc8>
    8000415e:	0004c783          	lbu	a5,0(s1)
    80004162:	d7dd                	beqz	a5,80004110 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004164:	4601                	li	a2,0
    80004166:	85d6                	mv	a1,s5
    80004168:	8552                	mv	a0,s4
    8000416a:	e97ff0ef          	jal	80004000 <dirlookup>
    8000416e:	89aa                	mv	s3,a0
    80004170:	d545                	beqz	a0,80004118 <namex+0x7c>
    iunlockput(ip);
    80004172:	8552                	mv	a0,s4
    80004174:	ae7ff0ef          	jal	80003c5a <iunlockput>
    ip = next;
    80004178:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000417a:	0004c783          	lbu	a5,0(s1)
    8000417e:	01279763          	bne	a5,s2,8000418c <namex+0xf0>
    path++;
    80004182:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004184:	0004c783          	lbu	a5,0(s1)
    80004188:	ff278de3          	beq	a5,s2,80004182 <namex+0xe6>
  if(*path == 0)
    8000418c:	cb8d                	beqz	a5,800041be <namex+0x122>
  while(*path != '/' && *path != 0)
    8000418e:	0004c783          	lbu	a5,0(s1)
    80004192:	89a6                	mv	s3,s1
  len = path - s;
    80004194:	4c81                	li	s9,0
    80004196:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004198:	01278963          	beq	a5,s2,800041aa <namex+0x10e>
    8000419c:	d3d9                	beqz	a5,80004122 <namex+0x86>
    path++;
    8000419e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800041a0:	0009c783          	lbu	a5,0(s3)
    800041a4:	ff279ce3          	bne	a5,s2,8000419c <namex+0x100>
    800041a8:	bfad                	j	80004122 <namex+0x86>
    memmove(name, s, len);
    800041aa:	2601                	sext.w	a2,a2
    800041ac:	85a6                	mv	a1,s1
    800041ae:	8556                	mv	a0,s5
    800041b0:	cf9fc0ef          	jal	80000ea8 <memmove>
    name[len] = 0;
    800041b4:	9cd6                	add	s9,s9,s5
    800041b6:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800041ba:	84ce                	mv	s1,s3
    800041bc:	bfbd                	j	8000413a <namex+0x9e>
  if(nameiparent){
    800041be:	f20b0be3          	beqz	s6,800040f4 <namex+0x58>
    iput(ip);
    800041c2:	8552                	mv	a0,s4
    800041c4:	a0fff0ef          	jal	80003bd2 <iput>
    return 0;
    800041c8:	4a01                	li	s4,0
    800041ca:	b72d                	j	800040f4 <namex+0x58>

00000000800041cc <dirlink>:
{
    800041cc:	7139                	addi	sp,sp,-64
    800041ce:	fc06                	sd	ra,56(sp)
    800041d0:	f822                	sd	s0,48(sp)
    800041d2:	f04a                	sd	s2,32(sp)
    800041d4:	ec4e                	sd	s3,24(sp)
    800041d6:	e852                	sd	s4,16(sp)
    800041d8:	0080                	addi	s0,sp,64
    800041da:	892a                	mv	s2,a0
    800041dc:	8a2e                	mv	s4,a1
    800041de:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800041e0:	4601                	li	a2,0
    800041e2:	e1fff0ef          	jal	80004000 <dirlookup>
    800041e6:	e535                	bnez	a0,80004252 <dirlink+0x86>
    800041e8:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800041ea:	04c92483          	lw	s1,76(s2)
    800041ee:	c48d                	beqz	s1,80004218 <dirlink+0x4c>
    800041f0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800041f2:	4741                	li	a4,16
    800041f4:	86a6                	mv	a3,s1
    800041f6:	fc040613          	addi	a2,s0,-64
    800041fa:	4581                	li	a1,0
    800041fc:	854a                	mv	a0,s2
    800041fe:	be3ff0ef          	jal	80003de0 <readi>
    80004202:	47c1                	li	a5,16
    80004204:	04f51b63          	bne	a0,a5,8000425a <dirlink+0x8e>
    if(de.inum == 0)
    80004208:	fc045783          	lhu	a5,-64(s0)
    8000420c:	c791                	beqz	a5,80004218 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000420e:	24c1                	addiw	s1,s1,16
    80004210:	04c92783          	lw	a5,76(s2)
    80004214:	fcf4efe3          	bltu	s1,a5,800041f2 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80004218:	4639                	li	a2,14
    8000421a:	85d2                	mv	a1,s4
    8000421c:	fc240513          	addi	a0,s0,-62
    80004220:	d2ffc0ef          	jal	80000f4e <strncpy>
  de.inum = inum;
    80004224:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004228:	4741                	li	a4,16
    8000422a:	86a6                	mv	a3,s1
    8000422c:	fc040613          	addi	a2,s0,-64
    80004230:	4581                	li	a1,0
    80004232:	854a                	mv	a0,s2
    80004234:	ca9ff0ef          	jal	80003edc <writei>
    80004238:	1541                	addi	a0,a0,-16
    8000423a:	00a03533          	snez	a0,a0
    8000423e:	40a00533          	neg	a0,a0
    80004242:	74a2                	ld	s1,40(sp)
}
    80004244:	70e2                	ld	ra,56(sp)
    80004246:	7442                	ld	s0,48(sp)
    80004248:	7902                	ld	s2,32(sp)
    8000424a:	69e2                	ld	s3,24(sp)
    8000424c:	6a42                	ld	s4,16(sp)
    8000424e:	6121                	addi	sp,sp,64
    80004250:	8082                	ret
    iput(ip);
    80004252:	981ff0ef          	jal	80003bd2 <iput>
    return -1;
    80004256:	557d                	li	a0,-1
    80004258:	b7f5                	j	80004244 <dirlink+0x78>
      panic("dirlink read");
    8000425a:	00004517          	auipc	a0,0x4
    8000425e:	6b650513          	addi	a0,a0,1718 # 80008910 <etext+0x910>
    80004262:	d7efc0ef          	jal	800007e0 <panic>

0000000080004266 <namei>:

struct inode*
namei(char *path)
{
    80004266:	1101                	addi	sp,sp,-32
    80004268:	ec06                	sd	ra,24(sp)
    8000426a:	e822                	sd	s0,16(sp)
    8000426c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000426e:	fe040613          	addi	a2,s0,-32
    80004272:	4581                	li	a1,0
    80004274:	e29ff0ef          	jal	8000409c <namex>
}
    80004278:	60e2                	ld	ra,24(sp)
    8000427a:	6442                	ld	s0,16(sp)
    8000427c:	6105                	addi	sp,sp,32
    8000427e:	8082                	ret

0000000080004280 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004280:	1141                	addi	sp,sp,-16
    80004282:	e406                	sd	ra,8(sp)
    80004284:	e022                	sd	s0,0(sp)
    80004286:	0800                	addi	s0,sp,16
    80004288:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000428a:	4585                	li	a1,1
    8000428c:	e11ff0ef          	jal	8000409c <namex>
}
    80004290:	60a2                	ld	ra,8(sp)
    80004292:	6402                	ld	s0,0(sp)
    80004294:	0141                	addi	sp,sp,16
    80004296:	8082                	ret

0000000080004298 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004298:	1101                	addi	sp,sp,-32
    8000429a:	ec06                	sd	ra,24(sp)
    8000429c:	e822                	sd	s0,16(sp)
    8000429e:	e426                	sd	s1,8(sp)
    800042a0:	e04a                	sd	s2,0(sp)
    800042a2:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800042a4:	0023d917          	auipc	s2,0x23d
    800042a8:	36490913          	addi	s2,s2,868 # 80241608 <log>
    800042ac:	01892583          	lw	a1,24(s2)
    800042b0:	02492503          	lw	a0,36(s2)
    800042b4:	8d0ff0ef          	jal	80003384 <bread>
    800042b8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800042ba:	02892603          	lw	a2,40(s2)
    800042be:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800042c0:	00c05f63          	blez	a2,800042de <write_head+0x46>
    800042c4:	0023d717          	auipc	a4,0x23d
    800042c8:	37070713          	addi	a4,a4,880 # 80241634 <log+0x2c>
    800042cc:	87aa                	mv	a5,a0
    800042ce:	060a                	slli	a2,a2,0x2
    800042d0:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800042d2:	4314                	lw	a3,0(a4)
    800042d4:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800042d6:	0711                	addi	a4,a4,4
    800042d8:	0791                	addi	a5,a5,4
    800042da:	fec79ce3          	bne	a5,a2,800042d2 <write_head+0x3a>
  }
  bwrite(buf);
    800042de:	8526                	mv	a0,s1
    800042e0:	97aff0ef          	jal	8000345a <bwrite>
  brelse(buf);
    800042e4:	8526                	mv	a0,s1
    800042e6:	9a6ff0ef          	jal	8000348c <brelse>
}
    800042ea:	60e2                	ld	ra,24(sp)
    800042ec:	6442                	ld	s0,16(sp)
    800042ee:	64a2                	ld	s1,8(sp)
    800042f0:	6902                	ld	s2,0(sp)
    800042f2:	6105                	addi	sp,sp,32
    800042f4:	8082                	ret

00000000800042f6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800042f6:	0023d797          	auipc	a5,0x23d
    800042fa:	33a7a783          	lw	a5,826(a5) # 80241630 <log+0x28>
    800042fe:	0af05e63          	blez	a5,800043ba <install_trans+0xc4>
{
    80004302:	715d                	addi	sp,sp,-80
    80004304:	e486                	sd	ra,72(sp)
    80004306:	e0a2                	sd	s0,64(sp)
    80004308:	fc26                	sd	s1,56(sp)
    8000430a:	f84a                	sd	s2,48(sp)
    8000430c:	f44e                	sd	s3,40(sp)
    8000430e:	f052                	sd	s4,32(sp)
    80004310:	ec56                	sd	s5,24(sp)
    80004312:	e85a                	sd	s6,16(sp)
    80004314:	e45e                	sd	s7,8(sp)
    80004316:	0880                	addi	s0,sp,80
    80004318:	8b2a                	mv	s6,a0
    8000431a:	0023da97          	auipc	s5,0x23d
    8000431e:	31aa8a93          	addi	s5,s5,794 # 80241634 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004322:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004324:	00004b97          	auipc	s7,0x4
    80004328:	5fcb8b93          	addi	s7,s7,1532 # 80008920 <etext+0x920>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000432c:	0023da17          	auipc	s4,0x23d
    80004330:	2dca0a13          	addi	s4,s4,732 # 80241608 <log>
    80004334:	a025                	j	8000435c <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004336:	000aa603          	lw	a2,0(s5)
    8000433a:	85ce                	mv	a1,s3
    8000433c:	855e                	mv	a0,s7
    8000433e:	9bcfc0ef          	jal	800004fa <printf>
    80004342:	a839                	j	80004360 <install_trans+0x6a>
    brelse(lbuf);
    80004344:	854a                	mv	a0,s2
    80004346:	946ff0ef          	jal	8000348c <brelse>
    brelse(dbuf);
    8000434a:	8526                	mv	a0,s1
    8000434c:	940ff0ef          	jal	8000348c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004350:	2985                	addiw	s3,s3,1
    80004352:	0a91                	addi	s5,s5,4
    80004354:	028a2783          	lw	a5,40(s4)
    80004358:	04f9d663          	bge	s3,a5,800043a4 <install_trans+0xae>
    if(recovering) {
    8000435c:	fc0b1de3          	bnez	s6,80004336 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004360:	018a2583          	lw	a1,24(s4)
    80004364:	013585bb          	addw	a1,a1,s3
    80004368:	2585                	addiw	a1,a1,1
    8000436a:	024a2503          	lw	a0,36(s4)
    8000436e:	816ff0ef          	jal	80003384 <bread>
    80004372:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004374:	000aa583          	lw	a1,0(s5)
    80004378:	024a2503          	lw	a0,36(s4)
    8000437c:	808ff0ef          	jal	80003384 <bread>
    80004380:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004382:	40000613          	li	a2,1024
    80004386:	05890593          	addi	a1,s2,88
    8000438a:	05850513          	addi	a0,a0,88
    8000438e:	b1bfc0ef          	jal	80000ea8 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004392:	8526                	mv	a0,s1
    80004394:	8c6ff0ef          	jal	8000345a <bwrite>
    if(recovering == 0)
    80004398:	fa0b16e3          	bnez	s6,80004344 <install_trans+0x4e>
      bunpin(dbuf);
    8000439c:	8526                	mv	a0,s1
    8000439e:	9aaff0ef          	jal	80003548 <bunpin>
    800043a2:	b74d                	j	80004344 <install_trans+0x4e>
}
    800043a4:	60a6                	ld	ra,72(sp)
    800043a6:	6406                	ld	s0,64(sp)
    800043a8:	74e2                	ld	s1,56(sp)
    800043aa:	7942                	ld	s2,48(sp)
    800043ac:	79a2                	ld	s3,40(sp)
    800043ae:	7a02                	ld	s4,32(sp)
    800043b0:	6ae2                	ld	s5,24(sp)
    800043b2:	6b42                	ld	s6,16(sp)
    800043b4:	6ba2                	ld	s7,8(sp)
    800043b6:	6161                	addi	sp,sp,80
    800043b8:	8082                	ret
    800043ba:	8082                	ret

00000000800043bc <initlog>:
{
    800043bc:	7179                	addi	sp,sp,-48
    800043be:	f406                	sd	ra,40(sp)
    800043c0:	f022                	sd	s0,32(sp)
    800043c2:	ec26                	sd	s1,24(sp)
    800043c4:	e84a                	sd	s2,16(sp)
    800043c6:	e44e                	sd	s3,8(sp)
    800043c8:	1800                	addi	s0,sp,48
    800043ca:	892a                	mv	s2,a0
    800043cc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800043ce:	0023d497          	auipc	s1,0x23d
    800043d2:	23a48493          	addi	s1,s1,570 # 80241608 <log>
    800043d6:	00004597          	auipc	a1,0x4
    800043da:	56a58593          	addi	a1,a1,1386 # 80008940 <etext+0x940>
    800043de:	8526                	mv	a0,s1
    800043e0:	919fc0ef          	jal	80000cf8 <initlock>
  log.start = sb->logstart;
    800043e4:	0149a583          	lw	a1,20(s3)
    800043e8:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    800043ea:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    800043ee:	854a                	mv	a0,s2
    800043f0:	f95fe0ef          	jal	80003384 <bread>
  log.lh.n = lh->n;
    800043f4:	4d30                	lw	a2,88(a0)
    800043f6:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    800043f8:	00c05f63          	blez	a2,80004416 <initlog+0x5a>
    800043fc:	87aa                	mv	a5,a0
    800043fe:	0023d717          	auipc	a4,0x23d
    80004402:	23670713          	addi	a4,a4,566 # 80241634 <log+0x2c>
    80004406:	060a                	slli	a2,a2,0x2
    80004408:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000440a:	4ff4                	lw	a3,92(a5)
    8000440c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000440e:	0791                	addi	a5,a5,4
    80004410:	0711                	addi	a4,a4,4
    80004412:	fec79ce3          	bne	a5,a2,8000440a <initlog+0x4e>
  brelse(buf);
    80004416:	876ff0ef          	jal	8000348c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000441a:	4505                	li	a0,1
    8000441c:	edbff0ef          	jal	800042f6 <install_trans>
  log.lh.n = 0;
    80004420:	0023d797          	auipc	a5,0x23d
    80004424:	2007a823          	sw	zero,528(a5) # 80241630 <log+0x28>
  write_head(); // clear the log
    80004428:	e71ff0ef          	jal	80004298 <write_head>
}
    8000442c:	70a2                	ld	ra,40(sp)
    8000442e:	7402                	ld	s0,32(sp)
    80004430:	64e2                	ld	s1,24(sp)
    80004432:	6942                	ld	s2,16(sp)
    80004434:	69a2                	ld	s3,8(sp)
    80004436:	6145                	addi	sp,sp,48
    80004438:	8082                	ret

000000008000443a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000443a:	1101                	addi	sp,sp,-32
    8000443c:	ec06                	sd	ra,24(sp)
    8000443e:	e822                	sd	s0,16(sp)
    80004440:	e426                	sd	s1,8(sp)
    80004442:	e04a                	sd	s2,0(sp)
    80004444:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004446:	0023d517          	auipc	a0,0x23d
    8000444a:	1c250513          	addi	a0,a0,450 # 80241608 <log>
    8000444e:	92bfc0ef          	jal	80000d78 <acquire>
  while(1){
    if(log.committing){
    80004452:	0023d497          	auipc	s1,0x23d
    80004456:	1b648493          	addi	s1,s1,438 # 80241608 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000445a:	4979                	li	s2,30
    8000445c:	a029                	j	80004466 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000445e:	85a6                	mv	a1,s1
    80004460:	8526                	mv	a0,s1
    80004462:	eb1fd0ef          	jal	80002312 <sleep>
    if(log.committing){
    80004466:	509c                	lw	a5,32(s1)
    80004468:	fbfd                	bnez	a5,8000445e <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000446a:	4cd8                	lw	a4,28(s1)
    8000446c:	2705                	addiw	a4,a4,1
    8000446e:	0027179b          	slliw	a5,a4,0x2
    80004472:	9fb9                	addw	a5,a5,a4
    80004474:	0017979b          	slliw	a5,a5,0x1
    80004478:	5494                	lw	a3,40(s1)
    8000447a:	9fb5                	addw	a5,a5,a3
    8000447c:	00f95763          	bge	s2,a5,8000448a <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004480:	85a6                	mv	a1,s1
    80004482:	8526                	mv	a0,s1
    80004484:	e8ffd0ef          	jal	80002312 <sleep>
    80004488:	bff9                	j	80004466 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000448a:	0023d517          	auipc	a0,0x23d
    8000448e:	17e50513          	addi	a0,a0,382 # 80241608 <log>
    80004492:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004494:	97dfc0ef          	jal	80000e10 <release>
      break;
    }
  }
}
    80004498:	60e2                	ld	ra,24(sp)
    8000449a:	6442                	ld	s0,16(sp)
    8000449c:	64a2                	ld	s1,8(sp)
    8000449e:	6902                	ld	s2,0(sp)
    800044a0:	6105                	addi	sp,sp,32
    800044a2:	8082                	ret

00000000800044a4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800044a4:	7139                	addi	sp,sp,-64
    800044a6:	fc06                	sd	ra,56(sp)
    800044a8:	f822                	sd	s0,48(sp)
    800044aa:	f426                	sd	s1,40(sp)
    800044ac:	f04a                	sd	s2,32(sp)
    800044ae:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800044b0:	0023d497          	auipc	s1,0x23d
    800044b4:	15848493          	addi	s1,s1,344 # 80241608 <log>
    800044b8:	8526                	mv	a0,s1
    800044ba:	8bffc0ef          	jal	80000d78 <acquire>
  log.outstanding -= 1;
    800044be:	4cdc                	lw	a5,28(s1)
    800044c0:	37fd                	addiw	a5,a5,-1
    800044c2:	0007891b          	sext.w	s2,a5
    800044c6:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800044c8:	509c                	lw	a5,32(s1)
    800044ca:	ef9d                	bnez	a5,80004508 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800044cc:	04091763          	bnez	s2,8000451a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800044d0:	0023d497          	auipc	s1,0x23d
    800044d4:	13848493          	addi	s1,s1,312 # 80241608 <log>
    800044d8:	4785                	li	a5,1
    800044da:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800044dc:	8526                	mv	a0,s1
    800044de:	933fc0ef          	jal	80000e10 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800044e2:	549c                	lw	a5,40(s1)
    800044e4:	04f04b63          	bgtz	a5,8000453a <end_op+0x96>
    acquire(&log.lock);
    800044e8:	0023d497          	auipc	s1,0x23d
    800044ec:	12048493          	addi	s1,s1,288 # 80241608 <log>
    800044f0:	8526                	mv	a0,s1
    800044f2:	887fc0ef          	jal	80000d78 <acquire>
    log.committing = 0;
    800044f6:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    800044fa:	8526                	mv	a0,s1
    800044fc:	e63fd0ef          	jal	8000235e <wakeup>
    release(&log.lock);
    80004500:	8526                	mv	a0,s1
    80004502:	90ffc0ef          	jal	80000e10 <release>
}
    80004506:	a025                	j	8000452e <end_op+0x8a>
    80004508:	ec4e                	sd	s3,24(sp)
    8000450a:	e852                	sd	s4,16(sp)
    8000450c:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000450e:	00004517          	auipc	a0,0x4
    80004512:	43a50513          	addi	a0,a0,1082 # 80008948 <etext+0x948>
    80004516:	acafc0ef          	jal	800007e0 <panic>
    wakeup(&log);
    8000451a:	0023d497          	auipc	s1,0x23d
    8000451e:	0ee48493          	addi	s1,s1,238 # 80241608 <log>
    80004522:	8526                	mv	a0,s1
    80004524:	e3bfd0ef          	jal	8000235e <wakeup>
  release(&log.lock);
    80004528:	8526                	mv	a0,s1
    8000452a:	8e7fc0ef          	jal	80000e10 <release>
}
    8000452e:	70e2                	ld	ra,56(sp)
    80004530:	7442                	ld	s0,48(sp)
    80004532:	74a2                	ld	s1,40(sp)
    80004534:	7902                	ld	s2,32(sp)
    80004536:	6121                	addi	sp,sp,64
    80004538:	8082                	ret
    8000453a:	ec4e                	sd	s3,24(sp)
    8000453c:	e852                	sd	s4,16(sp)
    8000453e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004540:	0023da97          	auipc	s5,0x23d
    80004544:	0f4a8a93          	addi	s5,s5,244 # 80241634 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004548:	0023da17          	auipc	s4,0x23d
    8000454c:	0c0a0a13          	addi	s4,s4,192 # 80241608 <log>
    80004550:	018a2583          	lw	a1,24(s4)
    80004554:	012585bb          	addw	a1,a1,s2
    80004558:	2585                	addiw	a1,a1,1
    8000455a:	024a2503          	lw	a0,36(s4)
    8000455e:	e27fe0ef          	jal	80003384 <bread>
    80004562:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004564:	000aa583          	lw	a1,0(s5)
    80004568:	024a2503          	lw	a0,36(s4)
    8000456c:	e19fe0ef          	jal	80003384 <bread>
    80004570:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004572:	40000613          	li	a2,1024
    80004576:	05850593          	addi	a1,a0,88
    8000457a:	05848513          	addi	a0,s1,88
    8000457e:	92bfc0ef          	jal	80000ea8 <memmove>
    bwrite(to);  // write the log
    80004582:	8526                	mv	a0,s1
    80004584:	ed7fe0ef          	jal	8000345a <bwrite>
    brelse(from);
    80004588:	854e                	mv	a0,s3
    8000458a:	f03fe0ef          	jal	8000348c <brelse>
    brelse(to);
    8000458e:	8526                	mv	a0,s1
    80004590:	efdfe0ef          	jal	8000348c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004594:	2905                	addiw	s2,s2,1
    80004596:	0a91                	addi	s5,s5,4
    80004598:	028a2783          	lw	a5,40(s4)
    8000459c:	faf94ae3          	blt	s2,a5,80004550 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800045a0:	cf9ff0ef          	jal	80004298 <write_head>
    install_trans(0); // Now install writes to home locations
    800045a4:	4501                	li	a0,0
    800045a6:	d51ff0ef          	jal	800042f6 <install_trans>
    log.lh.n = 0;
    800045aa:	0023d797          	auipc	a5,0x23d
    800045ae:	0807a323          	sw	zero,134(a5) # 80241630 <log+0x28>
    write_head();    // Erase the transaction from the log
    800045b2:	ce7ff0ef          	jal	80004298 <write_head>
    800045b6:	69e2                	ld	s3,24(sp)
    800045b8:	6a42                	ld	s4,16(sp)
    800045ba:	6aa2                	ld	s5,8(sp)
    800045bc:	b735                	j	800044e8 <end_op+0x44>

00000000800045be <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800045be:	1101                	addi	sp,sp,-32
    800045c0:	ec06                	sd	ra,24(sp)
    800045c2:	e822                	sd	s0,16(sp)
    800045c4:	e426                	sd	s1,8(sp)
    800045c6:	e04a                	sd	s2,0(sp)
    800045c8:	1000                	addi	s0,sp,32
    800045ca:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800045cc:	0023d917          	auipc	s2,0x23d
    800045d0:	03c90913          	addi	s2,s2,60 # 80241608 <log>
    800045d4:	854a                	mv	a0,s2
    800045d6:	fa2fc0ef          	jal	80000d78 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800045da:	02892603          	lw	a2,40(s2)
    800045de:	47f5                	li	a5,29
    800045e0:	04c7cc63          	blt	a5,a2,80004638 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800045e4:	0023d797          	auipc	a5,0x23d
    800045e8:	0407a783          	lw	a5,64(a5) # 80241624 <log+0x1c>
    800045ec:	04f05c63          	blez	a5,80004644 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800045f0:	4781                	li	a5,0
    800045f2:	04c05f63          	blez	a2,80004650 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800045f6:	44cc                	lw	a1,12(s1)
    800045f8:	0023d717          	auipc	a4,0x23d
    800045fc:	03c70713          	addi	a4,a4,60 # 80241634 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004600:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004602:	4314                	lw	a3,0(a4)
    80004604:	04b68663          	beq	a3,a1,80004650 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80004608:	2785                	addiw	a5,a5,1
    8000460a:	0711                	addi	a4,a4,4
    8000460c:	fef61be3          	bne	a2,a5,80004602 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004610:	0621                	addi	a2,a2,8
    80004612:	060a                	slli	a2,a2,0x2
    80004614:	0023d797          	auipc	a5,0x23d
    80004618:	ff478793          	addi	a5,a5,-12 # 80241608 <log>
    8000461c:	97b2                	add	a5,a5,a2
    8000461e:	44d8                	lw	a4,12(s1)
    80004620:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004622:	8526                	mv	a0,s1
    80004624:	ef1fe0ef          	jal	80003514 <bpin>
    log.lh.n++;
    80004628:	0023d717          	auipc	a4,0x23d
    8000462c:	fe070713          	addi	a4,a4,-32 # 80241608 <log>
    80004630:	571c                	lw	a5,40(a4)
    80004632:	2785                	addiw	a5,a5,1
    80004634:	d71c                	sw	a5,40(a4)
    80004636:	a80d                	j	80004668 <log_write+0xaa>
    panic("too big a transaction");
    80004638:	00004517          	auipc	a0,0x4
    8000463c:	32050513          	addi	a0,a0,800 # 80008958 <etext+0x958>
    80004640:	9a0fc0ef          	jal	800007e0 <panic>
    panic("log_write outside of trans");
    80004644:	00004517          	auipc	a0,0x4
    80004648:	32c50513          	addi	a0,a0,812 # 80008970 <etext+0x970>
    8000464c:	994fc0ef          	jal	800007e0 <panic>
  log.lh.block[i] = b->blockno;
    80004650:	00878693          	addi	a3,a5,8
    80004654:	068a                	slli	a3,a3,0x2
    80004656:	0023d717          	auipc	a4,0x23d
    8000465a:	fb270713          	addi	a4,a4,-78 # 80241608 <log>
    8000465e:	9736                	add	a4,a4,a3
    80004660:	44d4                	lw	a3,12(s1)
    80004662:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004664:	faf60fe3          	beq	a2,a5,80004622 <log_write+0x64>
  }
  release(&log.lock);
    80004668:	0023d517          	auipc	a0,0x23d
    8000466c:	fa050513          	addi	a0,a0,-96 # 80241608 <log>
    80004670:	fa0fc0ef          	jal	80000e10 <release>
}
    80004674:	60e2                	ld	ra,24(sp)
    80004676:	6442                	ld	s0,16(sp)
    80004678:	64a2                	ld	s1,8(sp)
    8000467a:	6902                	ld	s2,0(sp)
    8000467c:	6105                	addi	sp,sp,32
    8000467e:	8082                	ret

0000000080004680 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004680:	1101                	addi	sp,sp,-32
    80004682:	ec06                	sd	ra,24(sp)
    80004684:	e822                	sd	s0,16(sp)
    80004686:	e426                	sd	s1,8(sp)
    80004688:	e04a                	sd	s2,0(sp)
    8000468a:	1000                	addi	s0,sp,32
    8000468c:	84aa                	mv	s1,a0
    8000468e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004690:	00004597          	auipc	a1,0x4
    80004694:	30058593          	addi	a1,a1,768 # 80008990 <etext+0x990>
    80004698:	0521                	addi	a0,a0,8
    8000469a:	e5efc0ef          	jal	80000cf8 <initlock>
  lk->name = name;
    8000469e:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800046a2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800046a6:	0204a423          	sw	zero,40(s1)
}
    800046aa:	60e2                	ld	ra,24(sp)
    800046ac:	6442                	ld	s0,16(sp)
    800046ae:	64a2                	ld	s1,8(sp)
    800046b0:	6902                	ld	s2,0(sp)
    800046b2:	6105                	addi	sp,sp,32
    800046b4:	8082                	ret

00000000800046b6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800046b6:	1101                	addi	sp,sp,-32
    800046b8:	ec06                	sd	ra,24(sp)
    800046ba:	e822                	sd	s0,16(sp)
    800046bc:	e426                	sd	s1,8(sp)
    800046be:	e04a                	sd	s2,0(sp)
    800046c0:	1000                	addi	s0,sp,32
    800046c2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800046c4:	00850913          	addi	s2,a0,8
    800046c8:	854a                	mv	a0,s2
    800046ca:	eaefc0ef          	jal	80000d78 <acquire>
  while (lk->locked) {
    800046ce:	409c                	lw	a5,0(s1)
    800046d0:	c799                	beqz	a5,800046de <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800046d2:	85ca                	mv	a1,s2
    800046d4:	8526                	mv	a0,s1
    800046d6:	c3dfd0ef          	jal	80002312 <sleep>
  while (lk->locked) {
    800046da:	409c                	lw	a5,0(s1)
    800046dc:	fbfd                	bnez	a5,800046d2 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800046de:	4785                	li	a5,1
    800046e0:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800046e2:	d7afd0ef          	jal	80001c5c <myproc>
    800046e6:	5d1c                	lw	a5,56(a0)
    800046e8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800046ea:	854a                	mv	a0,s2
    800046ec:	f24fc0ef          	jal	80000e10 <release>
}
    800046f0:	60e2                	ld	ra,24(sp)
    800046f2:	6442                	ld	s0,16(sp)
    800046f4:	64a2                	ld	s1,8(sp)
    800046f6:	6902                	ld	s2,0(sp)
    800046f8:	6105                	addi	sp,sp,32
    800046fa:	8082                	ret

00000000800046fc <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800046fc:	1101                	addi	sp,sp,-32
    800046fe:	ec06                	sd	ra,24(sp)
    80004700:	e822                	sd	s0,16(sp)
    80004702:	e426                	sd	s1,8(sp)
    80004704:	e04a                	sd	s2,0(sp)
    80004706:	1000                	addi	s0,sp,32
    80004708:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000470a:	00850913          	addi	s2,a0,8
    8000470e:	854a                	mv	a0,s2
    80004710:	e68fc0ef          	jal	80000d78 <acquire>
  lk->locked = 0;
    80004714:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004718:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000471c:	8526                	mv	a0,s1
    8000471e:	c41fd0ef          	jal	8000235e <wakeup>
  release(&lk->lk);
    80004722:	854a                	mv	a0,s2
    80004724:	eecfc0ef          	jal	80000e10 <release>
}
    80004728:	60e2                	ld	ra,24(sp)
    8000472a:	6442                	ld	s0,16(sp)
    8000472c:	64a2                	ld	s1,8(sp)
    8000472e:	6902                	ld	s2,0(sp)
    80004730:	6105                	addi	sp,sp,32
    80004732:	8082                	ret

0000000080004734 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004734:	7179                	addi	sp,sp,-48
    80004736:	f406                	sd	ra,40(sp)
    80004738:	f022                	sd	s0,32(sp)
    8000473a:	ec26                	sd	s1,24(sp)
    8000473c:	e84a                	sd	s2,16(sp)
    8000473e:	1800                	addi	s0,sp,48
    80004740:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004742:	00850913          	addi	s2,a0,8
    80004746:	854a                	mv	a0,s2
    80004748:	e30fc0ef          	jal	80000d78 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000474c:	409c                	lw	a5,0(s1)
    8000474e:	ef81                	bnez	a5,80004766 <holdingsleep+0x32>
    80004750:	4481                	li	s1,0
  release(&lk->lk);
    80004752:	854a                	mv	a0,s2
    80004754:	ebcfc0ef          	jal	80000e10 <release>
  return r;
}
    80004758:	8526                	mv	a0,s1
    8000475a:	70a2                	ld	ra,40(sp)
    8000475c:	7402                	ld	s0,32(sp)
    8000475e:	64e2                	ld	s1,24(sp)
    80004760:	6942                	ld	s2,16(sp)
    80004762:	6145                	addi	sp,sp,48
    80004764:	8082                	ret
    80004766:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004768:	0284a983          	lw	s3,40(s1)
    8000476c:	cf0fd0ef          	jal	80001c5c <myproc>
    80004770:	5d04                	lw	s1,56(a0)
    80004772:	413484b3          	sub	s1,s1,s3
    80004776:	0014b493          	seqz	s1,s1
    8000477a:	69a2                	ld	s3,8(sp)
    8000477c:	bfd9                	j	80004752 <holdingsleep+0x1e>

000000008000477e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000477e:	1141                	addi	sp,sp,-16
    80004780:	e406                	sd	ra,8(sp)
    80004782:	e022                	sd	s0,0(sp)
    80004784:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004786:	00004597          	auipc	a1,0x4
    8000478a:	21a58593          	addi	a1,a1,538 # 800089a0 <etext+0x9a0>
    8000478e:	0023d517          	auipc	a0,0x23d
    80004792:	fc250513          	addi	a0,a0,-62 # 80241750 <ftable>
    80004796:	d62fc0ef          	jal	80000cf8 <initlock>
}
    8000479a:	60a2                	ld	ra,8(sp)
    8000479c:	6402                	ld	s0,0(sp)
    8000479e:	0141                	addi	sp,sp,16
    800047a0:	8082                	ret

00000000800047a2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800047a2:	1101                	addi	sp,sp,-32
    800047a4:	ec06                	sd	ra,24(sp)
    800047a6:	e822                	sd	s0,16(sp)
    800047a8:	e426                	sd	s1,8(sp)
    800047aa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800047ac:	0023d517          	auipc	a0,0x23d
    800047b0:	fa450513          	addi	a0,a0,-92 # 80241750 <ftable>
    800047b4:	dc4fc0ef          	jal	80000d78 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047b8:	0023d497          	auipc	s1,0x23d
    800047bc:	fb048493          	addi	s1,s1,-80 # 80241768 <ftable+0x18>
    800047c0:	0023e717          	auipc	a4,0x23e
    800047c4:	f4870713          	addi	a4,a4,-184 # 80242708 <disk>
    if(f->ref == 0){
    800047c8:	40dc                	lw	a5,4(s1)
    800047ca:	cf89                	beqz	a5,800047e4 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800047cc:	02848493          	addi	s1,s1,40
    800047d0:	fee49ce3          	bne	s1,a4,800047c8 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800047d4:	0023d517          	auipc	a0,0x23d
    800047d8:	f7c50513          	addi	a0,a0,-132 # 80241750 <ftable>
    800047dc:	e34fc0ef          	jal	80000e10 <release>
  return 0;
    800047e0:	4481                	li	s1,0
    800047e2:	a809                	j	800047f4 <filealloc+0x52>
      f->ref = 1;
    800047e4:	4785                	li	a5,1
    800047e6:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800047e8:	0023d517          	auipc	a0,0x23d
    800047ec:	f6850513          	addi	a0,a0,-152 # 80241750 <ftable>
    800047f0:	e20fc0ef          	jal	80000e10 <release>
}
    800047f4:	8526                	mv	a0,s1
    800047f6:	60e2                	ld	ra,24(sp)
    800047f8:	6442                	ld	s0,16(sp)
    800047fa:	64a2                	ld	s1,8(sp)
    800047fc:	6105                	addi	sp,sp,32
    800047fe:	8082                	ret

0000000080004800 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004800:	1101                	addi	sp,sp,-32
    80004802:	ec06                	sd	ra,24(sp)
    80004804:	e822                	sd	s0,16(sp)
    80004806:	e426                	sd	s1,8(sp)
    80004808:	1000                	addi	s0,sp,32
    8000480a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000480c:	0023d517          	auipc	a0,0x23d
    80004810:	f4450513          	addi	a0,a0,-188 # 80241750 <ftable>
    80004814:	d64fc0ef          	jal	80000d78 <acquire>
  if(f->ref < 1)
    80004818:	40dc                	lw	a5,4(s1)
    8000481a:	02f05063          	blez	a5,8000483a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000481e:	2785                	addiw	a5,a5,1
    80004820:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004822:	0023d517          	auipc	a0,0x23d
    80004826:	f2e50513          	addi	a0,a0,-210 # 80241750 <ftable>
    8000482a:	de6fc0ef          	jal	80000e10 <release>
  return f;
}
    8000482e:	8526                	mv	a0,s1
    80004830:	60e2                	ld	ra,24(sp)
    80004832:	6442                	ld	s0,16(sp)
    80004834:	64a2                	ld	s1,8(sp)
    80004836:	6105                	addi	sp,sp,32
    80004838:	8082                	ret
    panic("filedup");
    8000483a:	00004517          	auipc	a0,0x4
    8000483e:	16e50513          	addi	a0,a0,366 # 800089a8 <etext+0x9a8>
    80004842:	f9ffb0ef          	jal	800007e0 <panic>

0000000080004846 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004846:	7139                	addi	sp,sp,-64
    80004848:	fc06                	sd	ra,56(sp)
    8000484a:	f822                	sd	s0,48(sp)
    8000484c:	f426                	sd	s1,40(sp)
    8000484e:	0080                	addi	s0,sp,64
    80004850:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004852:	0023d517          	auipc	a0,0x23d
    80004856:	efe50513          	addi	a0,a0,-258 # 80241750 <ftable>
    8000485a:	d1efc0ef          	jal	80000d78 <acquire>
  if(f->ref < 1)
    8000485e:	40dc                	lw	a5,4(s1)
    80004860:	04f05a63          	blez	a5,800048b4 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004864:	37fd                	addiw	a5,a5,-1
    80004866:	0007871b          	sext.w	a4,a5
    8000486a:	c0dc                	sw	a5,4(s1)
    8000486c:	04e04e63          	bgtz	a4,800048c8 <fileclose+0x82>
    80004870:	f04a                	sd	s2,32(sp)
    80004872:	ec4e                	sd	s3,24(sp)
    80004874:	e852                	sd	s4,16(sp)
    80004876:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004878:	0004a903          	lw	s2,0(s1)
    8000487c:	0094ca83          	lbu	s5,9(s1)
    80004880:	0104ba03          	ld	s4,16(s1)
    80004884:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004888:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000488c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004890:	0023d517          	auipc	a0,0x23d
    80004894:	ec050513          	addi	a0,a0,-320 # 80241750 <ftable>
    80004898:	d78fc0ef          	jal	80000e10 <release>

  if(ff.type == FD_PIPE){
    8000489c:	4785                	li	a5,1
    8000489e:	04f90063          	beq	s2,a5,800048de <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800048a2:	3979                	addiw	s2,s2,-2
    800048a4:	4785                	li	a5,1
    800048a6:	0527f563          	bgeu	a5,s2,800048f0 <fileclose+0xaa>
    800048aa:	7902                	ld	s2,32(sp)
    800048ac:	69e2                	ld	s3,24(sp)
    800048ae:	6a42                	ld	s4,16(sp)
    800048b0:	6aa2                	ld	s5,8(sp)
    800048b2:	a00d                	j	800048d4 <fileclose+0x8e>
    800048b4:	f04a                	sd	s2,32(sp)
    800048b6:	ec4e                	sd	s3,24(sp)
    800048b8:	e852                	sd	s4,16(sp)
    800048ba:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800048bc:	00004517          	auipc	a0,0x4
    800048c0:	0f450513          	addi	a0,a0,244 # 800089b0 <etext+0x9b0>
    800048c4:	f1dfb0ef          	jal	800007e0 <panic>
    release(&ftable.lock);
    800048c8:	0023d517          	auipc	a0,0x23d
    800048cc:	e8850513          	addi	a0,a0,-376 # 80241750 <ftable>
    800048d0:	d40fc0ef          	jal	80000e10 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800048d4:	70e2                	ld	ra,56(sp)
    800048d6:	7442                	ld	s0,48(sp)
    800048d8:	74a2                	ld	s1,40(sp)
    800048da:	6121                	addi	sp,sp,64
    800048dc:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800048de:	85d6                	mv	a1,s5
    800048e0:	8552                	mv	a0,s4
    800048e2:	336000ef          	jal	80004c18 <pipeclose>
    800048e6:	7902                	ld	s2,32(sp)
    800048e8:	69e2                	ld	s3,24(sp)
    800048ea:	6a42                	ld	s4,16(sp)
    800048ec:	6aa2                	ld	s5,8(sp)
    800048ee:	b7dd                	j	800048d4 <fileclose+0x8e>
    begin_op();
    800048f0:	b4bff0ef          	jal	8000443a <begin_op>
    iput(ff.ip);
    800048f4:	854e                	mv	a0,s3
    800048f6:	adcff0ef          	jal	80003bd2 <iput>
    end_op();
    800048fa:	babff0ef          	jal	800044a4 <end_op>
    800048fe:	7902                	ld	s2,32(sp)
    80004900:	69e2                	ld	s3,24(sp)
    80004902:	6a42                	ld	s4,16(sp)
    80004904:	6aa2                	ld	s5,8(sp)
    80004906:	b7f9                	j	800048d4 <fileclose+0x8e>

0000000080004908 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004908:	715d                	addi	sp,sp,-80
    8000490a:	e486                	sd	ra,72(sp)
    8000490c:	e0a2                	sd	s0,64(sp)
    8000490e:	fc26                	sd	s1,56(sp)
    80004910:	f44e                	sd	s3,40(sp)
    80004912:	0880                	addi	s0,sp,80
    80004914:	84aa                	mv	s1,a0
    80004916:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004918:	b44fd0ef          	jal	80001c5c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000491c:	409c                	lw	a5,0(s1)
    8000491e:	37f9                	addiw	a5,a5,-2
    80004920:	4705                	li	a4,1
    80004922:	04f76063          	bltu	a4,a5,80004962 <filestat+0x5a>
    80004926:	f84a                	sd	s2,48(sp)
    80004928:	892a                	mv	s2,a0
    ilock(f->ip);
    8000492a:	6c88                	ld	a0,24(s1)
    8000492c:	924ff0ef          	jal	80003a50 <ilock>
    stati(f->ip, &st);
    80004930:	fb840593          	addi	a1,s0,-72
    80004934:	6c88                	ld	a0,24(s1)
    80004936:	c80ff0ef          	jal	80003db6 <stati>
    iunlock(f->ip);
    8000493a:	6c88                	ld	a0,24(s1)
    8000493c:	9c2ff0ef          	jal	80003afe <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004940:	46e1                	li	a3,24
    80004942:	fb840613          	addi	a2,s0,-72
    80004946:	85ce                	mv	a1,s3
    80004948:	05893503          	ld	a0,88(s2)
    8000494c:	e81fc0ef          	jal	800017cc <copyout>
    80004950:	41f5551b          	sraiw	a0,a0,0x1f
    80004954:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004956:	60a6                	ld	ra,72(sp)
    80004958:	6406                	ld	s0,64(sp)
    8000495a:	74e2                	ld	s1,56(sp)
    8000495c:	79a2                	ld	s3,40(sp)
    8000495e:	6161                	addi	sp,sp,80
    80004960:	8082                	ret
  return -1;
    80004962:	557d                	li	a0,-1
    80004964:	bfcd                	j	80004956 <filestat+0x4e>

0000000080004966 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004966:	7179                	addi	sp,sp,-48
    80004968:	f406                	sd	ra,40(sp)
    8000496a:	f022                	sd	s0,32(sp)
    8000496c:	e84a                	sd	s2,16(sp)
    8000496e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004970:	00854783          	lbu	a5,8(a0)
    80004974:	cfd1                	beqz	a5,80004a10 <fileread+0xaa>
    80004976:	ec26                	sd	s1,24(sp)
    80004978:	e44e                	sd	s3,8(sp)
    8000497a:	84aa                	mv	s1,a0
    8000497c:	89ae                	mv	s3,a1
    8000497e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004980:	411c                	lw	a5,0(a0)
    80004982:	4705                	li	a4,1
    80004984:	04e78363          	beq	a5,a4,800049ca <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004988:	470d                	li	a4,3
    8000498a:	04e78763          	beq	a5,a4,800049d8 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000498e:	4709                	li	a4,2
    80004990:	06e79a63          	bne	a5,a4,80004a04 <fileread+0x9e>
    ilock(f->ip);
    80004994:	6d08                	ld	a0,24(a0)
    80004996:	8baff0ef          	jal	80003a50 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000499a:	874a                	mv	a4,s2
    8000499c:	5094                	lw	a3,32(s1)
    8000499e:	864e                	mv	a2,s3
    800049a0:	4585                	li	a1,1
    800049a2:	6c88                	ld	a0,24(s1)
    800049a4:	c3cff0ef          	jal	80003de0 <readi>
    800049a8:	892a                	mv	s2,a0
    800049aa:	00a05563          	blez	a0,800049b4 <fileread+0x4e>
      f->off += r;
    800049ae:	509c                	lw	a5,32(s1)
    800049b0:	9fa9                	addw	a5,a5,a0
    800049b2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800049b4:	6c88                	ld	a0,24(s1)
    800049b6:	948ff0ef          	jal	80003afe <iunlock>
    800049ba:	64e2                	ld	s1,24(sp)
    800049bc:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800049be:	854a                	mv	a0,s2
    800049c0:	70a2                	ld	ra,40(sp)
    800049c2:	7402                	ld	s0,32(sp)
    800049c4:	6942                	ld	s2,16(sp)
    800049c6:	6145                	addi	sp,sp,48
    800049c8:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800049ca:	6908                	ld	a0,16(a0)
    800049cc:	388000ef          	jal	80004d54 <piperead>
    800049d0:	892a                	mv	s2,a0
    800049d2:	64e2                	ld	s1,24(sp)
    800049d4:	69a2                	ld	s3,8(sp)
    800049d6:	b7e5                	j	800049be <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800049d8:	02451783          	lh	a5,36(a0)
    800049dc:	03079693          	slli	a3,a5,0x30
    800049e0:	92c1                	srli	a3,a3,0x30
    800049e2:	4725                	li	a4,9
    800049e4:	02d76863          	bltu	a4,a3,80004a14 <fileread+0xae>
    800049e8:	0792                	slli	a5,a5,0x4
    800049ea:	0023d717          	auipc	a4,0x23d
    800049ee:	cc670713          	addi	a4,a4,-826 # 802416b0 <devsw>
    800049f2:	97ba                	add	a5,a5,a4
    800049f4:	639c                	ld	a5,0(a5)
    800049f6:	c39d                	beqz	a5,80004a1c <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800049f8:	4505                	li	a0,1
    800049fa:	9782                	jalr	a5
    800049fc:	892a                	mv	s2,a0
    800049fe:	64e2                	ld	s1,24(sp)
    80004a00:	69a2                	ld	s3,8(sp)
    80004a02:	bf75                	j	800049be <fileread+0x58>
    panic("fileread");
    80004a04:	00004517          	auipc	a0,0x4
    80004a08:	fbc50513          	addi	a0,a0,-68 # 800089c0 <etext+0x9c0>
    80004a0c:	dd5fb0ef          	jal	800007e0 <panic>
    return -1;
    80004a10:	597d                	li	s2,-1
    80004a12:	b775                	j	800049be <fileread+0x58>
      return -1;
    80004a14:	597d                	li	s2,-1
    80004a16:	64e2                	ld	s1,24(sp)
    80004a18:	69a2                	ld	s3,8(sp)
    80004a1a:	b755                	j	800049be <fileread+0x58>
    80004a1c:	597d                	li	s2,-1
    80004a1e:	64e2                	ld	s1,24(sp)
    80004a20:	69a2                	ld	s3,8(sp)
    80004a22:	bf71                	j	800049be <fileread+0x58>

0000000080004a24 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004a24:	00954783          	lbu	a5,9(a0)
    80004a28:	10078b63          	beqz	a5,80004b3e <filewrite+0x11a>
{
    80004a2c:	715d                	addi	sp,sp,-80
    80004a2e:	e486                	sd	ra,72(sp)
    80004a30:	e0a2                	sd	s0,64(sp)
    80004a32:	f84a                	sd	s2,48(sp)
    80004a34:	f052                	sd	s4,32(sp)
    80004a36:	e85a                	sd	s6,16(sp)
    80004a38:	0880                	addi	s0,sp,80
    80004a3a:	892a                	mv	s2,a0
    80004a3c:	8b2e                	mv	s6,a1
    80004a3e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a40:	411c                	lw	a5,0(a0)
    80004a42:	4705                	li	a4,1
    80004a44:	02e78763          	beq	a5,a4,80004a72 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a48:	470d                	li	a4,3
    80004a4a:	02e78863          	beq	a5,a4,80004a7a <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a4e:	4709                	li	a4,2
    80004a50:	0ce79c63          	bne	a5,a4,80004b28 <filewrite+0x104>
    80004a54:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004a56:	0ac05863          	blez	a2,80004b06 <filewrite+0xe2>
    80004a5a:	fc26                	sd	s1,56(sp)
    80004a5c:	ec56                	sd	s5,24(sp)
    80004a5e:	e45e                	sd	s7,8(sp)
    80004a60:	e062                	sd	s8,0(sp)
    int i = 0;
    80004a62:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004a64:	6b85                	lui	s7,0x1
    80004a66:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004a6a:	6c05                	lui	s8,0x1
    80004a6c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004a70:	a8b5                	j	80004aec <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004a72:	6908                	ld	a0,16(a0)
    80004a74:	1fc000ef          	jal	80004c70 <pipewrite>
    80004a78:	a04d                	j	80004b1a <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a7a:	02451783          	lh	a5,36(a0)
    80004a7e:	03079693          	slli	a3,a5,0x30
    80004a82:	92c1                	srli	a3,a3,0x30
    80004a84:	4725                	li	a4,9
    80004a86:	0ad76e63          	bltu	a4,a3,80004b42 <filewrite+0x11e>
    80004a8a:	0792                	slli	a5,a5,0x4
    80004a8c:	0023d717          	auipc	a4,0x23d
    80004a90:	c2470713          	addi	a4,a4,-988 # 802416b0 <devsw>
    80004a94:	97ba                	add	a5,a5,a4
    80004a96:	679c                	ld	a5,8(a5)
    80004a98:	c7dd                	beqz	a5,80004b46 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004a9a:	4505                	li	a0,1
    80004a9c:	9782                	jalr	a5
    80004a9e:	a8b5                	j	80004b1a <filewrite+0xf6>
      if(n1 > max)
    80004aa0:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004aa4:	997ff0ef          	jal	8000443a <begin_op>
      ilock(f->ip);
    80004aa8:	01893503          	ld	a0,24(s2)
    80004aac:	fa5fe0ef          	jal	80003a50 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004ab0:	8756                	mv	a4,s5
    80004ab2:	02092683          	lw	a3,32(s2)
    80004ab6:	01698633          	add	a2,s3,s6
    80004aba:	4585                	li	a1,1
    80004abc:	01893503          	ld	a0,24(s2)
    80004ac0:	c1cff0ef          	jal	80003edc <writei>
    80004ac4:	84aa                	mv	s1,a0
    80004ac6:	00a05763          	blez	a0,80004ad4 <filewrite+0xb0>
        f->off += r;
    80004aca:	02092783          	lw	a5,32(s2)
    80004ace:	9fa9                	addw	a5,a5,a0
    80004ad0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004ad4:	01893503          	ld	a0,24(s2)
    80004ad8:	826ff0ef          	jal	80003afe <iunlock>
      end_op();
    80004adc:	9c9ff0ef          	jal	800044a4 <end_op>

      if(r != n1){
    80004ae0:	029a9563          	bne	s5,s1,80004b0a <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004ae4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004ae8:	0149da63          	bge	s3,s4,80004afc <filewrite+0xd8>
      int n1 = n - i;
    80004aec:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004af0:	0004879b          	sext.w	a5,s1
    80004af4:	fafbd6e3          	bge	s7,a5,80004aa0 <filewrite+0x7c>
    80004af8:	84e2                	mv	s1,s8
    80004afa:	b75d                	j	80004aa0 <filewrite+0x7c>
    80004afc:	74e2                	ld	s1,56(sp)
    80004afe:	6ae2                	ld	s5,24(sp)
    80004b00:	6ba2                	ld	s7,8(sp)
    80004b02:	6c02                	ld	s8,0(sp)
    80004b04:	a039                	j	80004b12 <filewrite+0xee>
    int i = 0;
    80004b06:	4981                	li	s3,0
    80004b08:	a029                	j	80004b12 <filewrite+0xee>
    80004b0a:	74e2                	ld	s1,56(sp)
    80004b0c:	6ae2                	ld	s5,24(sp)
    80004b0e:	6ba2                	ld	s7,8(sp)
    80004b10:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004b12:	033a1c63          	bne	s4,s3,80004b4a <filewrite+0x126>
    80004b16:	8552                	mv	a0,s4
    80004b18:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004b1a:	60a6                	ld	ra,72(sp)
    80004b1c:	6406                	ld	s0,64(sp)
    80004b1e:	7942                	ld	s2,48(sp)
    80004b20:	7a02                	ld	s4,32(sp)
    80004b22:	6b42                	ld	s6,16(sp)
    80004b24:	6161                	addi	sp,sp,80
    80004b26:	8082                	ret
    80004b28:	fc26                	sd	s1,56(sp)
    80004b2a:	f44e                	sd	s3,40(sp)
    80004b2c:	ec56                	sd	s5,24(sp)
    80004b2e:	e45e                	sd	s7,8(sp)
    80004b30:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004b32:	00004517          	auipc	a0,0x4
    80004b36:	e9e50513          	addi	a0,a0,-354 # 800089d0 <etext+0x9d0>
    80004b3a:	ca7fb0ef          	jal	800007e0 <panic>
    return -1;
    80004b3e:	557d                	li	a0,-1
}
    80004b40:	8082                	ret
      return -1;
    80004b42:	557d                	li	a0,-1
    80004b44:	bfd9                	j	80004b1a <filewrite+0xf6>
    80004b46:	557d                	li	a0,-1
    80004b48:	bfc9                	j	80004b1a <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004b4a:	557d                	li	a0,-1
    80004b4c:	79a2                	ld	s3,40(sp)
    80004b4e:	b7f1                	j	80004b1a <filewrite+0xf6>

0000000080004b50 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004b50:	7179                	addi	sp,sp,-48
    80004b52:	f406                	sd	ra,40(sp)
    80004b54:	f022                	sd	s0,32(sp)
    80004b56:	ec26                	sd	s1,24(sp)
    80004b58:	e052                	sd	s4,0(sp)
    80004b5a:	1800                	addi	s0,sp,48
    80004b5c:	84aa                	mv	s1,a0
    80004b5e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004b60:	0005b023          	sd	zero,0(a1)
    80004b64:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004b68:	c3bff0ef          	jal	800047a2 <filealloc>
    80004b6c:	e088                	sd	a0,0(s1)
    80004b6e:	c549                	beqz	a0,80004bf8 <pipealloc+0xa8>
    80004b70:	c33ff0ef          	jal	800047a2 <filealloc>
    80004b74:	00aa3023          	sd	a0,0(s4)
    80004b78:	cd25                	beqz	a0,80004bf0 <pipealloc+0xa0>
    80004b7a:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b7c:	856fc0ef          	jal	80000bd2 <kalloc>
    80004b80:	892a                	mv	s2,a0
    80004b82:	c12d                	beqz	a0,80004be4 <pipealloc+0x94>
    80004b84:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004b86:	4985                	li	s3,1
    80004b88:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b8c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b90:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b94:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b98:	00004597          	auipc	a1,0x4
    80004b9c:	e4858593          	addi	a1,a1,-440 # 800089e0 <etext+0x9e0>
    80004ba0:	958fc0ef          	jal	80000cf8 <initlock>
  (*f0)->type = FD_PIPE;
    80004ba4:	609c                	ld	a5,0(s1)
    80004ba6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004baa:	609c                	ld	a5,0(s1)
    80004bac:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004bb0:	609c                	ld	a5,0(s1)
    80004bb2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004bb6:	609c                	ld	a5,0(s1)
    80004bb8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004bbc:	000a3783          	ld	a5,0(s4)
    80004bc0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004bc4:	000a3783          	ld	a5,0(s4)
    80004bc8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004bcc:	000a3783          	ld	a5,0(s4)
    80004bd0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004bd4:	000a3783          	ld	a5,0(s4)
    80004bd8:	0127b823          	sd	s2,16(a5)
  return 0;
    80004bdc:	4501                	li	a0,0
    80004bde:	6942                	ld	s2,16(sp)
    80004be0:	69a2                	ld	s3,8(sp)
    80004be2:	a01d                	j	80004c08 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004be4:	6088                	ld	a0,0(s1)
    80004be6:	c119                	beqz	a0,80004bec <pipealloc+0x9c>
    80004be8:	6942                	ld	s2,16(sp)
    80004bea:	a029                	j	80004bf4 <pipealloc+0xa4>
    80004bec:	6942                	ld	s2,16(sp)
    80004bee:	a029                	j	80004bf8 <pipealloc+0xa8>
    80004bf0:	6088                	ld	a0,0(s1)
    80004bf2:	c10d                	beqz	a0,80004c14 <pipealloc+0xc4>
    fileclose(*f0);
    80004bf4:	c53ff0ef          	jal	80004846 <fileclose>
  if(*f1)
    80004bf8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004bfc:	557d                	li	a0,-1
  if(*f1)
    80004bfe:	c789                	beqz	a5,80004c08 <pipealloc+0xb8>
    fileclose(*f1);
    80004c00:	853e                	mv	a0,a5
    80004c02:	c45ff0ef          	jal	80004846 <fileclose>
  return -1;
    80004c06:	557d                	li	a0,-1
}
    80004c08:	70a2                	ld	ra,40(sp)
    80004c0a:	7402                	ld	s0,32(sp)
    80004c0c:	64e2                	ld	s1,24(sp)
    80004c0e:	6a02                	ld	s4,0(sp)
    80004c10:	6145                	addi	sp,sp,48
    80004c12:	8082                	ret
  return -1;
    80004c14:	557d                	li	a0,-1
    80004c16:	bfcd                	j	80004c08 <pipealloc+0xb8>

0000000080004c18 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004c18:	1101                	addi	sp,sp,-32
    80004c1a:	ec06                	sd	ra,24(sp)
    80004c1c:	e822                	sd	s0,16(sp)
    80004c1e:	e426                	sd	s1,8(sp)
    80004c20:	e04a                	sd	s2,0(sp)
    80004c22:	1000                	addi	s0,sp,32
    80004c24:	84aa                	mv	s1,a0
    80004c26:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004c28:	950fc0ef          	jal	80000d78 <acquire>
  if(writable){
    80004c2c:	02090763          	beqz	s2,80004c5a <pipeclose+0x42>
    pi->writeopen = 0;
    80004c30:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004c34:	21848513          	addi	a0,s1,536
    80004c38:	f26fd0ef          	jal	8000235e <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004c3c:	2204b783          	ld	a5,544(s1)
    80004c40:	e785                	bnez	a5,80004c68 <pipeclose+0x50>
    release(&pi->lock);
    80004c42:	8526                	mv	a0,s1
    80004c44:	9ccfc0ef          	jal	80000e10 <release>
    kfree((char*)pi);
    80004c48:	8526                	mv	a0,s1
    80004c4a:	dd3fb0ef          	jal	80000a1c <kfree>
  } else
    release(&pi->lock);
}
    80004c4e:	60e2                	ld	ra,24(sp)
    80004c50:	6442                	ld	s0,16(sp)
    80004c52:	64a2                	ld	s1,8(sp)
    80004c54:	6902                	ld	s2,0(sp)
    80004c56:	6105                	addi	sp,sp,32
    80004c58:	8082                	ret
    pi->readopen = 0;
    80004c5a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c5e:	21c48513          	addi	a0,s1,540
    80004c62:	efcfd0ef          	jal	8000235e <wakeup>
    80004c66:	bfd9                	j	80004c3c <pipeclose+0x24>
    release(&pi->lock);
    80004c68:	8526                	mv	a0,s1
    80004c6a:	9a6fc0ef          	jal	80000e10 <release>
}
    80004c6e:	b7c5                	j	80004c4e <pipeclose+0x36>

0000000080004c70 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c70:	711d                	addi	sp,sp,-96
    80004c72:	ec86                	sd	ra,88(sp)
    80004c74:	e8a2                	sd	s0,80(sp)
    80004c76:	e4a6                	sd	s1,72(sp)
    80004c78:	e0ca                	sd	s2,64(sp)
    80004c7a:	fc4e                	sd	s3,56(sp)
    80004c7c:	f852                	sd	s4,48(sp)
    80004c7e:	f456                	sd	s5,40(sp)
    80004c80:	1080                	addi	s0,sp,96
    80004c82:	84aa                	mv	s1,a0
    80004c84:	8aae                	mv	s5,a1
    80004c86:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c88:	fd5fc0ef          	jal	80001c5c <myproc>
    80004c8c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c8e:	8526                	mv	a0,s1
    80004c90:	8e8fc0ef          	jal	80000d78 <acquire>
  while(i < n){
    80004c94:	0b405a63          	blez	s4,80004d48 <pipewrite+0xd8>
    80004c98:	f05a                	sd	s6,32(sp)
    80004c9a:	ec5e                	sd	s7,24(sp)
    80004c9c:	e862                	sd	s8,16(sp)
  int i = 0;
    80004c9e:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ca0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ca2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ca6:	21c48b93          	addi	s7,s1,540
    80004caa:	a81d                	j	80004ce0 <pipewrite+0x70>
      release(&pi->lock);
    80004cac:	8526                	mv	a0,s1
    80004cae:	962fc0ef          	jal	80000e10 <release>
      return -1;
    80004cb2:	597d                	li	s2,-1
    80004cb4:	7b02                	ld	s6,32(sp)
    80004cb6:	6be2                	ld	s7,24(sp)
    80004cb8:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004cba:	854a                	mv	a0,s2
    80004cbc:	60e6                	ld	ra,88(sp)
    80004cbe:	6446                	ld	s0,80(sp)
    80004cc0:	64a6                	ld	s1,72(sp)
    80004cc2:	6906                	ld	s2,64(sp)
    80004cc4:	79e2                	ld	s3,56(sp)
    80004cc6:	7a42                	ld	s4,48(sp)
    80004cc8:	7aa2                	ld	s5,40(sp)
    80004cca:	6125                	addi	sp,sp,96
    80004ccc:	8082                	ret
      wakeup(&pi->nread);
    80004cce:	8562                	mv	a0,s8
    80004cd0:	e8efd0ef          	jal	8000235e <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004cd4:	85a6                	mv	a1,s1
    80004cd6:	855e                	mv	a0,s7
    80004cd8:	e3afd0ef          	jal	80002312 <sleep>
  while(i < n){
    80004cdc:	05495b63          	bge	s2,s4,80004d32 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004ce0:	2204a783          	lw	a5,544(s1)
    80004ce4:	d7e1                	beqz	a5,80004cac <pipewrite+0x3c>
    80004ce6:	854e                	mv	a0,s3
    80004ce8:	863fd0ef          	jal	8000254a <killed>
    80004cec:	f161                	bnez	a0,80004cac <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cee:	2184a783          	lw	a5,536(s1)
    80004cf2:	21c4a703          	lw	a4,540(s1)
    80004cf6:	2007879b          	addiw	a5,a5,512
    80004cfa:	fcf70ae3          	beq	a4,a5,80004cce <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cfe:	4685                	li	a3,1
    80004d00:	01590633          	add	a2,s2,s5
    80004d04:	faf40593          	addi	a1,s0,-81
    80004d08:	0589b503          	ld	a0,88(s3)
    80004d0c:	ba5fc0ef          	jal	800018b0 <copyin>
    80004d10:	03650e63          	beq	a0,s6,80004d4c <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004d14:	21c4a783          	lw	a5,540(s1)
    80004d18:	0017871b          	addiw	a4,a5,1
    80004d1c:	20e4ae23          	sw	a4,540(s1)
    80004d20:	1ff7f793          	andi	a5,a5,511
    80004d24:	97a6                	add	a5,a5,s1
    80004d26:	faf44703          	lbu	a4,-81(s0)
    80004d2a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d2e:	2905                	addiw	s2,s2,1
    80004d30:	b775                	j	80004cdc <pipewrite+0x6c>
    80004d32:	7b02                	ld	s6,32(sp)
    80004d34:	6be2                	ld	s7,24(sp)
    80004d36:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004d38:	21848513          	addi	a0,s1,536
    80004d3c:	e22fd0ef          	jal	8000235e <wakeup>
  release(&pi->lock);
    80004d40:	8526                	mv	a0,s1
    80004d42:	8cefc0ef          	jal	80000e10 <release>
  return i;
    80004d46:	bf95                	j	80004cba <pipewrite+0x4a>
  int i = 0;
    80004d48:	4901                	li	s2,0
    80004d4a:	b7fd                	j	80004d38 <pipewrite+0xc8>
    80004d4c:	7b02                	ld	s6,32(sp)
    80004d4e:	6be2                	ld	s7,24(sp)
    80004d50:	6c42                	ld	s8,16(sp)
    80004d52:	b7dd                	j	80004d38 <pipewrite+0xc8>

0000000080004d54 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d54:	715d                	addi	sp,sp,-80
    80004d56:	e486                	sd	ra,72(sp)
    80004d58:	e0a2                	sd	s0,64(sp)
    80004d5a:	fc26                	sd	s1,56(sp)
    80004d5c:	f84a                	sd	s2,48(sp)
    80004d5e:	f44e                	sd	s3,40(sp)
    80004d60:	f052                	sd	s4,32(sp)
    80004d62:	ec56                	sd	s5,24(sp)
    80004d64:	0880                	addi	s0,sp,80
    80004d66:	84aa                	mv	s1,a0
    80004d68:	892e                	mv	s2,a1
    80004d6a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d6c:	ef1fc0ef          	jal	80001c5c <myproc>
    80004d70:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d72:	8526                	mv	a0,s1
    80004d74:	804fc0ef          	jal	80000d78 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d78:	2184a703          	lw	a4,536(s1)
    80004d7c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d80:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d84:	02f71563          	bne	a4,a5,80004dae <piperead+0x5a>
    80004d88:	2244a783          	lw	a5,548(s1)
    80004d8c:	cb85                	beqz	a5,80004dbc <piperead+0x68>
    if(killed(pr)){
    80004d8e:	8552                	mv	a0,s4
    80004d90:	fbafd0ef          	jal	8000254a <killed>
    80004d94:	ed19                	bnez	a0,80004db2 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d96:	85a6                	mv	a1,s1
    80004d98:	854e                	mv	a0,s3
    80004d9a:	d78fd0ef          	jal	80002312 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d9e:	2184a703          	lw	a4,536(s1)
    80004da2:	21c4a783          	lw	a5,540(s1)
    80004da6:	fef701e3          	beq	a4,a5,80004d88 <piperead+0x34>
    80004daa:	e85a                	sd	s6,16(sp)
    80004dac:	a809                	j	80004dbe <piperead+0x6a>
    80004dae:	e85a                	sd	s6,16(sp)
    80004db0:	a039                	j	80004dbe <piperead+0x6a>
      release(&pi->lock);
    80004db2:	8526                	mv	a0,s1
    80004db4:	85cfc0ef          	jal	80000e10 <release>
      return -1;
    80004db8:	59fd                	li	s3,-1
    80004dba:	a8b9                	j	80004e18 <piperead+0xc4>
    80004dbc:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dbe:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004dc0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dc2:	05505363          	blez	s5,80004e08 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004dc6:	2184a783          	lw	a5,536(s1)
    80004dca:	21c4a703          	lw	a4,540(s1)
    80004dce:	02f70d63          	beq	a4,a5,80004e08 <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004dd2:	1ff7f793          	andi	a5,a5,511
    80004dd6:	97a6                	add	a5,a5,s1
    80004dd8:	0187c783          	lbu	a5,24(a5)
    80004ddc:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004de0:	4685                	li	a3,1
    80004de2:	fbf40613          	addi	a2,s0,-65
    80004de6:	85ca                	mv	a1,s2
    80004de8:	058a3503          	ld	a0,88(s4)
    80004dec:	9e1fc0ef          	jal	800017cc <copyout>
    80004df0:	03650e63          	beq	a0,s6,80004e2c <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004df4:	2184a783          	lw	a5,536(s1)
    80004df8:	2785                	addiw	a5,a5,1
    80004dfa:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dfe:	2985                	addiw	s3,s3,1
    80004e00:	0905                	addi	s2,s2,1
    80004e02:	fd3a92e3          	bne	s5,s3,80004dc6 <piperead+0x72>
    80004e06:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004e08:	21c48513          	addi	a0,s1,540
    80004e0c:	d52fd0ef          	jal	8000235e <wakeup>
  release(&pi->lock);
    80004e10:	8526                	mv	a0,s1
    80004e12:	ffffb0ef          	jal	80000e10 <release>
    80004e16:	6b42                	ld	s6,16(sp)
  return i;
}
    80004e18:	854e                	mv	a0,s3
    80004e1a:	60a6                	ld	ra,72(sp)
    80004e1c:	6406                	ld	s0,64(sp)
    80004e1e:	74e2                	ld	s1,56(sp)
    80004e20:	7942                	ld	s2,48(sp)
    80004e22:	79a2                	ld	s3,40(sp)
    80004e24:	7a02                	ld	s4,32(sp)
    80004e26:	6ae2                	ld	s5,24(sp)
    80004e28:	6161                	addi	sp,sp,80
    80004e2a:	8082                	ret
      if(i == 0)
    80004e2c:	fc099ee3          	bnez	s3,80004e08 <piperead+0xb4>
        i = -1;
    80004e30:	89aa                	mv	s3,a0
    80004e32:	bfd9                	j	80004e08 <piperead+0xb4>

0000000080004e34 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004e34:	1141                	addi	sp,sp,-16
    80004e36:	e422                	sd	s0,8(sp)
    80004e38:	0800                	addi	s0,sp,16
    80004e3a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e3c:	8905                	andi	a0,a0,1
    80004e3e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004e40:	8b89                	andi	a5,a5,2
    80004e42:	c399                	beqz	a5,80004e48 <flags2perm+0x14>
      perm |= PTE_W;
    80004e44:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e48:	6422                	ld	s0,8(sp)
    80004e4a:	0141                	addi	sp,sp,16
    80004e4c:	8082                	ret

0000000080004e4e <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004e4e:	df010113          	addi	sp,sp,-528
    80004e52:	20113423          	sd	ra,520(sp)
    80004e56:	20813023          	sd	s0,512(sp)
    80004e5a:	ffa6                	sd	s1,504(sp)
    80004e5c:	fbca                	sd	s2,496(sp)
    80004e5e:	0c00                	addi	s0,sp,528
    80004e60:	892a                	mv	s2,a0
    80004e62:	dea43c23          	sd	a0,-520(s0)
    80004e66:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e6a:	df3fc0ef          	jal	80001c5c <myproc>
    80004e6e:	84aa                	mv	s1,a0

  begin_op();
    80004e70:	dcaff0ef          	jal	8000443a <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004e74:	854a                	mv	a0,s2
    80004e76:	bf0ff0ef          	jal	80004266 <namei>
    80004e7a:	c931                	beqz	a0,80004ece <kexec+0x80>
    80004e7c:	f3d2                	sd	s4,480(sp)
    80004e7e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e80:	bd1fe0ef          	jal	80003a50 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e84:	04000713          	li	a4,64
    80004e88:	4681                	li	a3,0
    80004e8a:	e5040613          	addi	a2,s0,-432
    80004e8e:	4581                	li	a1,0
    80004e90:	8552                	mv	a0,s4
    80004e92:	f4ffe0ef          	jal	80003de0 <readi>
    80004e96:	04000793          	li	a5,64
    80004e9a:	00f51a63          	bne	a0,a5,80004eae <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004e9e:	e5042703          	lw	a4,-432(s0)
    80004ea2:	464c47b7          	lui	a5,0x464c4
    80004ea6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004eaa:	02f70663          	beq	a4,a5,80004ed6 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004eae:	8552                	mv	a0,s4
    80004eb0:	dabfe0ef          	jal	80003c5a <iunlockput>
    end_op();
    80004eb4:	df0ff0ef          	jal	800044a4 <end_op>
  }
  return -1;
    80004eb8:	557d                	li	a0,-1
    80004eba:	7a1e                	ld	s4,480(sp)
}
    80004ebc:	20813083          	ld	ra,520(sp)
    80004ec0:	20013403          	ld	s0,512(sp)
    80004ec4:	74fe                	ld	s1,504(sp)
    80004ec6:	795e                	ld	s2,496(sp)
    80004ec8:	21010113          	addi	sp,sp,528
    80004ecc:	8082                	ret
    end_op();
    80004ece:	dd6ff0ef          	jal	800044a4 <end_op>
    return -1;
    80004ed2:	557d                	li	a0,-1
    80004ed4:	b7e5                	j	80004ebc <kexec+0x6e>
    80004ed6:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004ed8:	8526                	mv	a0,s1
    80004eda:	e89fc0ef          	jal	80001d62 <proc_pagetable>
    80004ede:	8b2a                	mv	s6,a0
    80004ee0:	2c050b63          	beqz	a0,800051b6 <kexec+0x368>
    80004ee4:	f7ce                	sd	s3,488(sp)
    80004ee6:	efd6                	sd	s5,472(sp)
    80004ee8:	e7de                	sd	s7,456(sp)
    80004eea:	e3e2                	sd	s8,448(sp)
    80004eec:	ff66                	sd	s9,440(sp)
    80004eee:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ef0:	e7042d03          	lw	s10,-400(s0)
    80004ef4:	e8845783          	lhu	a5,-376(s0)
    80004ef8:	12078a63          	beqz	a5,8000502c <kexec+0x1de>
    80004efc:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004efe:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f00:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004f02:	6c85                	lui	s9,0x1
    80004f04:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004f08:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004f0c:	6a85                	lui	s5,0x1
    80004f0e:	a085                	j	80004f6e <kexec+0x120>
      panic("loadseg: address should exist");
    80004f10:	00004517          	auipc	a0,0x4
    80004f14:	ad850513          	addi	a0,a0,-1320 # 800089e8 <etext+0x9e8>
    80004f18:	8c9fb0ef          	jal	800007e0 <panic>
    if(sz - i < PGSIZE)
    80004f1c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f1e:	8726                	mv	a4,s1
    80004f20:	012c06bb          	addw	a3,s8,s2
    80004f24:	4581                	li	a1,0
    80004f26:	8552                	mv	a0,s4
    80004f28:	eb9fe0ef          	jal	80003de0 <readi>
    80004f2c:	2501                	sext.w	a0,a0
    80004f2e:	24a49a63          	bne	s1,a0,80005182 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004f32:	012a893b          	addw	s2,s5,s2
    80004f36:	03397363          	bgeu	s2,s3,80004f5c <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004f3a:	02091593          	slli	a1,s2,0x20
    80004f3e:	9181                	srli	a1,a1,0x20
    80004f40:	95de                	add	a1,a1,s7
    80004f42:	855a                	mv	a0,s6
    80004f44:	a46fc0ef          	jal	8000118a <walkaddr>
    80004f48:	862a                	mv	a2,a0
    if(pa == 0)
    80004f4a:	d179                	beqz	a0,80004f10 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80004f4c:	412984bb          	subw	s1,s3,s2
    80004f50:	0004879b          	sext.w	a5,s1
    80004f54:	fcfcf4e3          	bgeu	s9,a5,80004f1c <kexec+0xce>
    80004f58:	84d6                	mv	s1,s5
    80004f5a:	b7c9                	j	80004f1c <kexec+0xce>
    sz = sz1;
    80004f5c:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f60:	2d85                	addiw	s11,s11,1
    80004f62:	038d0d1b          	addiw	s10,s10,56
    80004f66:	e8845783          	lhu	a5,-376(s0)
    80004f6a:	08fdd063          	bge	s11,a5,80004fea <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004f6e:	2d01                	sext.w	s10,s10
    80004f70:	03800713          	li	a4,56
    80004f74:	86ea                	mv	a3,s10
    80004f76:	e1840613          	addi	a2,s0,-488
    80004f7a:	4581                	li	a1,0
    80004f7c:	8552                	mv	a0,s4
    80004f7e:	e63fe0ef          	jal	80003de0 <readi>
    80004f82:	03800793          	li	a5,56
    80004f86:	1cf51663          	bne	a0,a5,80005152 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004f8a:	e1842783          	lw	a5,-488(s0)
    80004f8e:	4705                	li	a4,1
    80004f90:	fce798e3          	bne	a5,a4,80004f60 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004f94:	e4043483          	ld	s1,-448(s0)
    80004f98:	e3843783          	ld	a5,-456(s0)
    80004f9c:	1af4ef63          	bltu	s1,a5,8000515a <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004fa0:	e2843783          	ld	a5,-472(s0)
    80004fa4:	94be                	add	s1,s1,a5
    80004fa6:	1af4ee63          	bltu	s1,a5,80005162 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004faa:	df043703          	ld	a4,-528(s0)
    80004fae:	8ff9                	and	a5,a5,a4
    80004fb0:	1a079d63          	bnez	a5,8000516a <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004fb4:	e1c42503          	lw	a0,-484(s0)
    80004fb8:	e7dff0ef          	jal	80004e34 <flags2perm>
    80004fbc:	86aa                	mv	a3,a0
    80004fbe:	8626                	mv	a2,s1
    80004fc0:	85ca                	mv	a1,s2
    80004fc2:	855a                	mv	a0,s6
    80004fc4:	cb8fc0ef          	jal	8000147c <uvmalloc>
    80004fc8:	e0a43423          	sd	a0,-504(s0)
    80004fcc:	1a050363          	beqz	a0,80005172 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004fd0:	e2843b83          	ld	s7,-472(s0)
    80004fd4:	e2042c03          	lw	s8,-480(s0)
    80004fd8:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004fdc:	00098463          	beqz	s3,80004fe4 <kexec+0x196>
    80004fe0:	4901                	li	s2,0
    80004fe2:	bfa1                	j	80004f3a <kexec+0xec>
    sz = sz1;
    80004fe4:	e0843903          	ld	s2,-504(s0)
    80004fe8:	bfa5                	j	80004f60 <kexec+0x112>
    80004fea:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004fec:	8552                	mv	a0,s4
    80004fee:	c6dfe0ef          	jal	80003c5a <iunlockput>
  end_op();
    80004ff2:	cb2ff0ef          	jal	800044a4 <end_op>
  p = myproc();
    80004ff6:	c67fc0ef          	jal	80001c5c <myproc>
    80004ffa:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004ffc:	05053c83          	ld	s9,80(a0)
  sz = PGROUNDUP(sz);
    80005000:	6985                	lui	s3,0x1
    80005002:	fff98493          	addi	s1,s3,-1 # fff <_entry-0x7ffff001>
    80005006:	94ca                	add	s1,s1,s2
    80005008:	77fd                	lui	a5,0xfffff
    8000500a:	8cfd                	and	s1,s1,a5
  sz += PGSIZE; // Đẩy sz lên để trang tiếp theo mới là Stack
    8000500c:	99a6                	add	s3,s3,s1
  if((sz1 = uvmalloc(pagetable, sz, sz + USERSTACK*PGSIZE, PTE_W)) == 0)
    8000500e:	4691                	li	a3,4
    80005010:	6609                	lui	a2,0x2
    80005012:	9626                	add	a2,a2,s1
    80005014:	85ce                	mv	a1,s3
    80005016:	855a                	mv	a0,s6
    80005018:	c64fc0ef          	jal	8000147c <uvmalloc>
    8000501c:	892a                	mv	s2,a0
    8000501e:	e0a43423          	sd	a0,-504(s0)
    80005022:	e519                	bnez	a0,80005030 <kexec+0x1e2>
  if(pagetable)
    80005024:	e1343423          	sd	s3,-504(s0)
    80005028:	4a01                	li	s4,0
    8000502a:	aaa9                	j	80005184 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000502c:	4901                	li	s2,0
    8000502e:	bf7d                	j	80004fec <kexec+0x19e>
  uvmclear(pagetable, guard_page_va); 
    80005030:	85a6                	mv	a1,s1
    80005032:	855a                	mv	a0,s6
    80005034:	e14fc0ef          	jal	80001648 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80005038:	7bfd                	lui	s7,0xfffff
    8000503a:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    8000503c:	e0043783          	ld	a5,-512(s0)
    80005040:	6388                	ld	a0,0(a5)
    80005042:	cd39                	beqz	a0,800050a0 <kexec+0x252>
    80005044:	e9040993          	addi	s3,s0,-368
    80005048:	f9040c13          	addi	s8,s0,-112
    8000504c:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000504e:	f6ffb0ef          	jal	80000fbc <strlen>
    80005052:	0015079b          	addiw	a5,a0,1
    80005056:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000505a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000505e:	11796e63          	bltu	s2,s7,8000517a <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005062:	e0043d03          	ld	s10,-512(s0)
    80005066:	000d3a03          	ld	s4,0(s10)
    8000506a:	8552                	mv	a0,s4
    8000506c:	f51fb0ef          	jal	80000fbc <strlen>
    80005070:	0015069b          	addiw	a3,a0,1
    80005074:	8652                	mv	a2,s4
    80005076:	85ca                	mv	a1,s2
    80005078:	855a                	mv	a0,s6
    8000507a:	f52fc0ef          	jal	800017cc <copyout>
    8000507e:	10054063          	bltz	a0,8000517e <kexec+0x330>
    ustack[argc] = sp;
    80005082:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005086:	0485                	addi	s1,s1,1
    80005088:	008d0793          	addi	a5,s10,8
    8000508c:	e0f43023          	sd	a5,-512(s0)
    80005090:	008d3503          	ld	a0,8(s10)
    80005094:	c909                	beqz	a0,800050a6 <kexec+0x258>
    if(argc >= MAXARG)
    80005096:	09a1                	addi	s3,s3,8
    80005098:	fb899be3          	bne	s3,s8,8000504e <kexec+0x200>
  ip = 0;
    8000509c:	4a01                	li	s4,0
    8000509e:	a0dd                	j	80005184 <kexec+0x336>
  sp = sz;
    800050a0:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    800050a4:	4481                	li	s1,0
  ustack[argc] = 0;
    800050a6:	00349793          	slli	a5,s1,0x3
    800050aa:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fdbc748>
    800050ae:	97a2                	add	a5,a5,s0
    800050b0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800050b4:	00148693          	addi	a3,s1,1
    800050b8:	068e                	slli	a3,a3,0x3
    800050ba:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800050be:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800050c2:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800050c6:	f5796fe3          	bltu	s2,s7,80005024 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800050ca:	e9040613          	addi	a2,s0,-368
    800050ce:	85ca                	mv	a1,s2
    800050d0:	855a                	mv	a0,s6
    800050d2:	efafc0ef          	jal	800017cc <copyout>
    800050d6:	0e054263          	bltz	a0,800051ba <kexec+0x36c>
  p->trapframe->a1 = sp;
    800050da:	060ab783          	ld	a5,96(s5) # 1060 <_entry-0x7fffefa0>
    800050de:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800050e2:	df843783          	ld	a5,-520(s0)
    800050e6:	0007c703          	lbu	a4,0(a5)
    800050ea:	cf11                	beqz	a4,80005106 <kexec+0x2b8>
    800050ec:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050ee:	02f00693          	li	a3,47
    800050f2:	a039                	j	80005100 <kexec+0x2b2>
      last = s+1;
    800050f4:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800050f8:	0785                	addi	a5,a5,1
    800050fa:	fff7c703          	lbu	a4,-1(a5)
    800050fe:	c701                	beqz	a4,80005106 <kexec+0x2b8>
    if(*s == '/')
    80005100:	fed71ce3          	bne	a4,a3,800050f8 <kexec+0x2aa>
    80005104:	bfc5                	j	800050f4 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80005106:	4641                	li	a2,16
    80005108:	df843583          	ld	a1,-520(s0)
    8000510c:	160a8513          	addi	a0,s5,352
    80005110:	e7bfb0ef          	jal	80000f8a <safestrcpy>
  oldpagetable = p->pagetable;
    80005114:	058ab503          	ld	a0,88(s5)
  p->pagetable = pagetable;
    80005118:	056abc23          	sd	s6,88(s5)
  p->sz = sz;
    8000511c:	e0843783          	ld	a5,-504(s0)
    80005120:	04fab823          	sd	a5,80(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80005124:	060ab783          	ld	a5,96(s5)
    80005128:	e6843703          	ld	a4,-408(s0)
    8000512c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000512e:	060ab783          	ld	a5,96(s5)
    80005132:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005136:	85e6                	mv	a1,s9
    80005138:	caffc0ef          	jal	80001de6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000513c:	0004851b          	sext.w	a0,s1
    80005140:	79be                	ld	s3,488(sp)
    80005142:	7a1e                	ld	s4,480(sp)
    80005144:	6afe                	ld	s5,472(sp)
    80005146:	6b5e                	ld	s6,464(sp)
    80005148:	6bbe                	ld	s7,456(sp)
    8000514a:	6c1e                	ld	s8,448(sp)
    8000514c:	7cfa                	ld	s9,440(sp)
    8000514e:	7d5a                	ld	s10,432(sp)
    80005150:	b3b5                	j	80004ebc <kexec+0x6e>
    80005152:	e1243423          	sd	s2,-504(s0)
    80005156:	7dba                	ld	s11,424(sp)
    80005158:	a035                	j	80005184 <kexec+0x336>
    8000515a:	e1243423          	sd	s2,-504(s0)
    8000515e:	7dba                	ld	s11,424(sp)
    80005160:	a015                	j	80005184 <kexec+0x336>
    80005162:	e1243423          	sd	s2,-504(s0)
    80005166:	7dba                	ld	s11,424(sp)
    80005168:	a831                	j	80005184 <kexec+0x336>
    8000516a:	e1243423          	sd	s2,-504(s0)
    8000516e:	7dba                	ld	s11,424(sp)
    80005170:	a811                	j	80005184 <kexec+0x336>
    80005172:	e1243423          	sd	s2,-504(s0)
    80005176:	7dba                	ld	s11,424(sp)
    80005178:	a031                	j	80005184 <kexec+0x336>
  ip = 0;
    8000517a:	4a01                	li	s4,0
    8000517c:	a021                	j	80005184 <kexec+0x336>
    8000517e:	4a01                	li	s4,0
  if(pagetable)
    80005180:	a011                	j	80005184 <kexec+0x336>
    80005182:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005184:	e0843583          	ld	a1,-504(s0)
    80005188:	855a                	mv	a0,s6
    8000518a:	c5dfc0ef          	jal	80001de6 <proc_freepagetable>
  return -1;
    8000518e:	557d                	li	a0,-1
  if(ip){
    80005190:	000a1b63          	bnez	s4,800051a6 <kexec+0x358>
    80005194:	79be                	ld	s3,488(sp)
    80005196:	7a1e                	ld	s4,480(sp)
    80005198:	6afe                	ld	s5,472(sp)
    8000519a:	6b5e                	ld	s6,464(sp)
    8000519c:	6bbe                	ld	s7,456(sp)
    8000519e:	6c1e                	ld	s8,448(sp)
    800051a0:	7cfa                	ld	s9,440(sp)
    800051a2:	7d5a                	ld	s10,432(sp)
    800051a4:	bb21                	j	80004ebc <kexec+0x6e>
    800051a6:	79be                	ld	s3,488(sp)
    800051a8:	6afe                	ld	s5,472(sp)
    800051aa:	6b5e                	ld	s6,464(sp)
    800051ac:	6bbe                	ld	s7,456(sp)
    800051ae:	6c1e                	ld	s8,448(sp)
    800051b0:	7cfa                	ld	s9,440(sp)
    800051b2:	7d5a                	ld	s10,432(sp)
    800051b4:	b9ed                	j	80004eae <kexec+0x60>
    800051b6:	6b5e                	ld	s6,464(sp)
    800051b8:	b9dd                	j	80004eae <kexec+0x60>
  sz = sz1;
    800051ba:	e0843983          	ld	s3,-504(s0)
    800051be:	b59d                	j	80005024 <kexec+0x1d6>

00000000800051c0 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051c0:	7179                	addi	sp,sp,-48
    800051c2:	f406                	sd	ra,40(sp)
    800051c4:	f022                	sd	s0,32(sp)
    800051c6:	ec26                	sd	s1,24(sp)
    800051c8:	e84a                	sd	s2,16(sp)
    800051ca:	1800                	addi	s0,sp,48
    800051cc:	892e                	mv	s2,a1
    800051ce:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800051d0:	fdc40593          	addi	a1,s0,-36
    800051d4:	b8ffd0ef          	jal	80002d62 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800051d8:	fdc42703          	lw	a4,-36(s0)
    800051dc:	47bd                	li	a5,15
    800051de:	02e7e963          	bltu	a5,a4,80005210 <argfd+0x50>
    800051e2:	a7bfc0ef          	jal	80001c5c <myproc>
    800051e6:	fdc42703          	lw	a4,-36(s0)
    800051ea:	01a70793          	addi	a5,a4,26
    800051ee:	078e                	slli	a5,a5,0x3
    800051f0:	953e                	add	a0,a0,a5
    800051f2:	651c                	ld	a5,8(a0)
    800051f4:	c385                	beqz	a5,80005214 <argfd+0x54>
    return -1;
  if(pfd)
    800051f6:	00090463          	beqz	s2,800051fe <argfd+0x3e>
    *pfd = fd;
    800051fa:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800051fe:	4501                	li	a0,0
  if(pf)
    80005200:	c091                	beqz	s1,80005204 <argfd+0x44>
    *pf = f;
    80005202:	e09c                	sd	a5,0(s1)
}
    80005204:	70a2                	ld	ra,40(sp)
    80005206:	7402                	ld	s0,32(sp)
    80005208:	64e2                	ld	s1,24(sp)
    8000520a:	6942                	ld	s2,16(sp)
    8000520c:	6145                	addi	sp,sp,48
    8000520e:	8082                	ret
    return -1;
    80005210:	557d                	li	a0,-1
    80005212:	bfcd                	j	80005204 <argfd+0x44>
    80005214:	557d                	li	a0,-1
    80005216:	b7fd                	j	80005204 <argfd+0x44>

0000000080005218 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005218:	1101                	addi	sp,sp,-32
    8000521a:	ec06                	sd	ra,24(sp)
    8000521c:	e822                	sd	s0,16(sp)
    8000521e:	e426                	sd	s1,8(sp)
    80005220:	1000                	addi	s0,sp,32
    80005222:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005224:	a39fc0ef          	jal	80001c5c <myproc>
    80005228:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000522a:	0d850793          	addi	a5,a0,216
    8000522e:	4501                	li	a0,0
    80005230:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005232:	6398                	ld	a4,0(a5)
    80005234:	cb19                	beqz	a4,8000524a <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005236:	2505                	addiw	a0,a0,1
    80005238:	07a1                	addi	a5,a5,8
    8000523a:	fed51ce3          	bne	a0,a3,80005232 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000523e:	557d                	li	a0,-1
}
    80005240:	60e2                	ld	ra,24(sp)
    80005242:	6442                	ld	s0,16(sp)
    80005244:	64a2                	ld	s1,8(sp)
    80005246:	6105                	addi	sp,sp,32
    80005248:	8082                	ret
      p->ofile[fd] = f;
    8000524a:	01a50793          	addi	a5,a0,26
    8000524e:	078e                	slli	a5,a5,0x3
    80005250:	963e                	add	a2,a2,a5
    80005252:	e604                	sd	s1,8(a2)
      return fd;
    80005254:	b7f5                	j	80005240 <fdalloc+0x28>

0000000080005256 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005256:	715d                	addi	sp,sp,-80
    80005258:	e486                	sd	ra,72(sp)
    8000525a:	e0a2                	sd	s0,64(sp)
    8000525c:	fc26                	sd	s1,56(sp)
    8000525e:	f84a                	sd	s2,48(sp)
    80005260:	f44e                	sd	s3,40(sp)
    80005262:	ec56                	sd	s5,24(sp)
    80005264:	e85a                	sd	s6,16(sp)
    80005266:	0880                	addi	s0,sp,80
    80005268:	8b2e                	mv	s6,a1
    8000526a:	89b2                	mv	s3,a2
    8000526c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000526e:	fb040593          	addi	a1,s0,-80
    80005272:	80eff0ef          	jal	80004280 <nameiparent>
    80005276:	84aa                	mv	s1,a0
    80005278:	10050a63          	beqz	a0,8000538c <create+0x136>
    return 0;

  ilock(dp);
    8000527c:	fd4fe0ef          	jal	80003a50 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005280:	4601                	li	a2,0
    80005282:	fb040593          	addi	a1,s0,-80
    80005286:	8526                	mv	a0,s1
    80005288:	d79fe0ef          	jal	80004000 <dirlookup>
    8000528c:	8aaa                	mv	s5,a0
    8000528e:	c129                	beqz	a0,800052d0 <create+0x7a>
    iunlockput(dp);
    80005290:	8526                	mv	a0,s1
    80005292:	9c9fe0ef          	jal	80003c5a <iunlockput>
    ilock(ip);
    80005296:	8556                	mv	a0,s5
    80005298:	fb8fe0ef          	jal	80003a50 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000529c:	4789                	li	a5,2
    8000529e:	02fb1463          	bne	s6,a5,800052c6 <create+0x70>
    800052a2:	044ad783          	lhu	a5,68(s5)
    800052a6:	37f9                	addiw	a5,a5,-2
    800052a8:	17c2                	slli	a5,a5,0x30
    800052aa:	93c1                	srli	a5,a5,0x30
    800052ac:	4705                	li	a4,1
    800052ae:	00f76c63          	bltu	a4,a5,800052c6 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800052b2:	8556                	mv	a0,s5
    800052b4:	60a6                	ld	ra,72(sp)
    800052b6:	6406                	ld	s0,64(sp)
    800052b8:	74e2                	ld	s1,56(sp)
    800052ba:	7942                	ld	s2,48(sp)
    800052bc:	79a2                	ld	s3,40(sp)
    800052be:	6ae2                	ld	s5,24(sp)
    800052c0:	6b42                	ld	s6,16(sp)
    800052c2:	6161                	addi	sp,sp,80
    800052c4:	8082                	ret
    iunlockput(ip);
    800052c6:	8556                	mv	a0,s5
    800052c8:	993fe0ef          	jal	80003c5a <iunlockput>
    return 0;
    800052cc:	4a81                	li	s5,0
    800052ce:	b7d5                	j	800052b2 <create+0x5c>
    800052d0:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800052d2:	85da                	mv	a1,s6
    800052d4:	4088                	lw	a0,0(s1)
    800052d6:	e0afe0ef          	jal	800038e0 <ialloc>
    800052da:	8a2a                	mv	s4,a0
    800052dc:	cd15                	beqz	a0,80005318 <create+0xc2>
  ilock(ip);
    800052de:	f72fe0ef          	jal	80003a50 <ilock>
  ip->major = major;
    800052e2:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800052e6:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800052ea:	4905                	li	s2,1
    800052ec:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800052f0:	8552                	mv	a0,s4
    800052f2:	eaafe0ef          	jal	8000399c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800052f6:	032b0763          	beq	s6,s2,80005324 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800052fa:	004a2603          	lw	a2,4(s4)
    800052fe:	fb040593          	addi	a1,s0,-80
    80005302:	8526                	mv	a0,s1
    80005304:	ec9fe0ef          	jal	800041cc <dirlink>
    80005308:	06054563          	bltz	a0,80005372 <create+0x11c>
  iunlockput(dp);
    8000530c:	8526                	mv	a0,s1
    8000530e:	94dfe0ef          	jal	80003c5a <iunlockput>
  return ip;
    80005312:	8ad2                	mv	s5,s4
    80005314:	7a02                	ld	s4,32(sp)
    80005316:	bf71                	j	800052b2 <create+0x5c>
    iunlockput(dp);
    80005318:	8526                	mv	a0,s1
    8000531a:	941fe0ef          	jal	80003c5a <iunlockput>
    return 0;
    8000531e:	8ad2                	mv	s5,s4
    80005320:	7a02                	ld	s4,32(sp)
    80005322:	bf41                	j	800052b2 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005324:	004a2603          	lw	a2,4(s4)
    80005328:	00003597          	auipc	a1,0x3
    8000532c:	6e058593          	addi	a1,a1,1760 # 80008a08 <etext+0xa08>
    80005330:	8552                	mv	a0,s4
    80005332:	e9bfe0ef          	jal	800041cc <dirlink>
    80005336:	02054e63          	bltz	a0,80005372 <create+0x11c>
    8000533a:	40d0                	lw	a2,4(s1)
    8000533c:	00003597          	auipc	a1,0x3
    80005340:	6d458593          	addi	a1,a1,1748 # 80008a10 <etext+0xa10>
    80005344:	8552                	mv	a0,s4
    80005346:	e87fe0ef          	jal	800041cc <dirlink>
    8000534a:	02054463          	bltz	a0,80005372 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000534e:	004a2603          	lw	a2,4(s4)
    80005352:	fb040593          	addi	a1,s0,-80
    80005356:	8526                	mv	a0,s1
    80005358:	e75fe0ef          	jal	800041cc <dirlink>
    8000535c:	00054b63          	bltz	a0,80005372 <create+0x11c>
    dp->nlink++;  // for ".."
    80005360:	04a4d783          	lhu	a5,74(s1)
    80005364:	2785                	addiw	a5,a5,1
    80005366:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000536a:	8526                	mv	a0,s1
    8000536c:	e30fe0ef          	jal	8000399c <iupdate>
    80005370:	bf71                	j	8000530c <create+0xb6>
  ip->nlink = 0;
    80005372:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005376:	8552                	mv	a0,s4
    80005378:	e24fe0ef          	jal	8000399c <iupdate>
  iunlockput(ip);
    8000537c:	8552                	mv	a0,s4
    8000537e:	8ddfe0ef          	jal	80003c5a <iunlockput>
  iunlockput(dp);
    80005382:	8526                	mv	a0,s1
    80005384:	8d7fe0ef          	jal	80003c5a <iunlockput>
  return 0;
    80005388:	7a02                	ld	s4,32(sp)
    8000538a:	b725                	j	800052b2 <create+0x5c>
    return 0;
    8000538c:	8aaa                	mv	s5,a0
    8000538e:	b715                	j	800052b2 <create+0x5c>

0000000080005390 <sys_dup>:
{
    80005390:	7179                	addi	sp,sp,-48
    80005392:	f406                	sd	ra,40(sp)
    80005394:	f022                	sd	s0,32(sp)
    80005396:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005398:	fd840613          	addi	a2,s0,-40
    8000539c:	4581                	li	a1,0
    8000539e:	4501                	li	a0,0
    800053a0:	e21ff0ef          	jal	800051c0 <argfd>
    return -1;
    800053a4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800053a6:	02054363          	bltz	a0,800053cc <sys_dup+0x3c>
    800053aa:	ec26                	sd	s1,24(sp)
    800053ac:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800053ae:	fd843903          	ld	s2,-40(s0)
    800053b2:	854a                	mv	a0,s2
    800053b4:	e65ff0ef          	jal	80005218 <fdalloc>
    800053b8:	84aa                	mv	s1,a0
    return -1;
    800053ba:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800053bc:	00054d63          	bltz	a0,800053d6 <sys_dup+0x46>
  filedup(f);
    800053c0:	854a                	mv	a0,s2
    800053c2:	c3eff0ef          	jal	80004800 <filedup>
  return fd;
    800053c6:	87a6                	mv	a5,s1
    800053c8:	64e2                	ld	s1,24(sp)
    800053ca:	6942                	ld	s2,16(sp)
}
    800053cc:	853e                	mv	a0,a5
    800053ce:	70a2                	ld	ra,40(sp)
    800053d0:	7402                	ld	s0,32(sp)
    800053d2:	6145                	addi	sp,sp,48
    800053d4:	8082                	ret
    800053d6:	64e2                	ld	s1,24(sp)
    800053d8:	6942                	ld	s2,16(sp)
    800053da:	bfcd                	j	800053cc <sys_dup+0x3c>

00000000800053dc <sys_read>:
{
    800053dc:	7179                	addi	sp,sp,-48
    800053de:	f406                	sd	ra,40(sp)
    800053e0:	f022                	sd	s0,32(sp)
    800053e2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800053e4:	fd840593          	addi	a1,s0,-40
    800053e8:	4505                	li	a0,1
    800053ea:	995fd0ef          	jal	80002d7e <argaddr>
  argint(2, &n);
    800053ee:	fe440593          	addi	a1,s0,-28
    800053f2:	4509                	li	a0,2
    800053f4:	96ffd0ef          	jal	80002d62 <argint>
  if(argfd(0, 0, &f) < 0)
    800053f8:	fe840613          	addi	a2,s0,-24
    800053fc:	4581                	li	a1,0
    800053fe:	4501                	li	a0,0
    80005400:	dc1ff0ef          	jal	800051c0 <argfd>
    80005404:	87aa                	mv	a5,a0
    return -1;
    80005406:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005408:	0007ca63          	bltz	a5,8000541c <sys_read+0x40>
  return fileread(f, p, n);
    8000540c:	fe442603          	lw	a2,-28(s0)
    80005410:	fd843583          	ld	a1,-40(s0)
    80005414:	fe843503          	ld	a0,-24(s0)
    80005418:	d4eff0ef          	jal	80004966 <fileread>
}
    8000541c:	70a2                	ld	ra,40(sp)
    8000541e:	7402                	ld	s0,32(sp)
    80005420:	6145                	addi	sp,sp,48
    80005422:	8082                	ret

0000000080005424 <sys_write>:
{
    80005424:	7179                	addi	sp,sp,-48
    80005426:	f406                	sd	ra,40(sp)
    80005428:	f022                	sd	s0,32(sp)
    8000542a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000542c:	fd840593          	addi	a1,s0,-40
    80005430:	4505                	li	a0,1
    80005432:	94dfd0ef          	jal	80002d7e <argaddr>
  argint(2, &n);
    80005436:	fe440593          	addi	a1,s0,-28
    8000543a:	4509                	li	a0,2
    8000543c:	927fd0ef          	jal	80002d62 <argint>
  if(argfd(0, 0, &f) < 0)
    80005440:	fe840613          	addi	a2,s0,-24
    80005444:	4581                	li	a1,0
    80005446:	4501                	li	a0,0
    80005448:	d79ff0ef          	jal	800051c0 <argfd>
    8000544c:	87aa                	mv	a5,a0
    return -1;
    8000544e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005450:	0007ca63          	bltz	a5,80005464 <sys_write+0x40>
  return filewrite(f, p, n);
    80005454:	fe442603          	lw	a2,-28(s0)
    80005458:	fd843583          	ld	a1,-40(s0)
    8000545c:	fe843503          	ld	a0,-24(s0)
    80005460:	dc4ff0ef          	jal	80004a24 <filewrite>
}
    80005464:	70a2                	ld	ra,40(sp)
    80005466:	7402                	ld	s0,32(sp)
    80005468:	6145                	addi	sp,sp,48
    8000546a:	8082                	ret

000000008000546c <sys_close>:
{
    8000546c:	1101                	addi	sp,sp,-32
    8000546e:	ec06                	sd	ra,24(sp)
    80005470:	e822                	sd	s0,16(sp)
    80005472:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005474:	fe040613          	addi	a2,s0,-32
    80005478:	fec40593          	addi	a1,s0,-20
    8000547c:	4501                	li	a0,0
    8000547e:	d43ff0ef          	jal	800051c0 <argfd>
    return -1;
    80005482:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005484:	02054063          	bltz	a0,800054a4 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80005488:	fd4fc0ef          	jal	80001c5c <myproc>
    8000548c:	fec42783          	lw	a5,-20(s0)
    80005490:	07e9                	addi	a5,a5,26
    80005492:	078e                	slli	a5,a5,0x3
    80005494:	953e                	add	a0,a0,a5
    80005496:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000549a:	fe043503          	ld	a0,-32(s0)
    8000549e:	ba8ff0ef          	jal	80004846 <fileclose>
  return 0;
    800054a2:	4781                	li	a5,0
}
    800054a4:	853e                	mv	a0,a5
    800054a6:	60e2                	ld	ra,24(sp)
    800054a8:	6442                	ld	s0,16(sp)
    800054aa:	6105                	addi	sp,sp,32
    800054ac:	8082                	ret

00000000800054ae <sys_fstat>:
{
    800054ae:	1101                	addi	sp,sp,-32
    800054b0:	ec06                	sd	ra,24(sp)
    800054b2:	e822                	sd	s0,16(sp)
    800054b4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800054b6:	fe040593          	addi	a1,s0,-32
    800054ba:	4505                	li	a0,1
    800054bc:	8c3fd0ef          	jal	80002d7e <argaddr>
  if(argfd(0, 0, &f) < 0)
    800054c0:	fe840613          	addi	a2,s0,-24
    800054c4:	4581                	li	a1,0
    800054c6:	4501                	li	a0,0
    800054c8:	cf9ff0ef          	jal	800051c0 <argfd>
    800054cc:	87aa                	mv	a5,a0
    return -1;
    800054ce:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054d0:	0007c863          	bltz	a5,800054e0 <sys_fstat+0x32>
  return filestat(f, st);
    800054d4:	fe043583          	ld	a1,-32(s0)
    800054d8:	fe843503          	ld	a0,-24(s0)
    800054dc:	c2cff0ef          	jal	80004908 <filestat>
}
    800054e0:	60e2                	ld	ra,24(sp)
    800054e2:	6442                	ld	s0,16(sp)
    800054e4:	6105                	addi	sp,sp,32
    800054e6:	8082                	ret

00000000800054e8 <sys_link>:
{
    800054e8:	7169                	addi	sp,sp,-304
    800054ea:	f606                	sd	ra,296(sp)
    800054ec:	f222                	sd	s0,288(sp)
    800054ee:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054f0:	08000613          	li	a2,128
    800054f4:	ed040593          	addi	a1,s0,-304
    800054f8:	4501                	li	a0,0
    800054fa:	8a1fd0ef          	jal	80002d9a <argstr>
    return -1;
    800054fe:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005500:	0c054e63          	bltz	a0,800055dc <sys_link+0xf4>
    80005504:	08000613          	li	a2,128
    80005508:	f5040593          	addi	a1,s0,-176
    8000550c:	4505                	li	a0,1
    8000550e:	88dfd0ef          	jal	80002d9a <argstr>
    return -1;
    80005512:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005514:	0c054463          	bltz	a0,800055dc <sys_link+0xf4>
    80005518:	ee26                	sd	s1,280(sp)
  begin_op();
    8000551a:	f21fe0ef          	jal	8000443a <begin_op>
  if((ip = namei(old)) == 0){
    8000551e:	ed040513          	addi	a0,s0,-304
    80005522:	d45fe0ef          	jal	80004266 <namei>
    80005526:	84aa                	mv	s1,a0
    80005528:	c53d                	beqz	a0,80005596 <sys_link+0xae>
  ilock(ip);
    8000552a:	d26fe0ef          	jal	80003a50 <ilock>
  if(ip->type == T_DIR){
    8000552e:	04449703          	lh	a4,68(s1)
    80005532:	4785                	li	a5,1
    80005534:	06f70663          	beq	a4,a5,800055a0 <sys_link+0xb8>
    80005538:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000553a:	04a4d783          	lhu	a5,74(s1)
    8000553e:	2785                	addiw	a5,a5,1
    80005540:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005544:	8526                	mv	a0,s1
    80005546:	c56fe0ef          	jal	8000399c <iupdate>
  iunlock(ip);
    8000554a:	8526                	mv	a0,s1
    8000554c:	db2fe0ef          	jal	80003afe <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005550:	fd040593          	addi	a1,s0,-48
    80005554:	f5040513          	addi	a0,s0,-176
    80005558:	d29fe0ef          	jal	80004280 <nameiparent>
    8000555c:	892a                	mv	s2,a0
    8000555e:	cd21                	beqz	a0,800055b6 <sys_link+0xce>
  ilock(dp);
    80005560:	cf0fe0ef          	jal	80003a50 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005564:	00092703          	lw	a4,0(s2)
    80005568:	409c                	lw	a5,0(s1)
    8000556a:	04f71363          	bne	a4,a5,800055b0 <sys_link+0xc8>
    8000556e:	40d0                	lw	a2,4(s1)
    80005570:	fd040593          	addi	a1,s0,-48
    80005574:	854a                	mv	a0,s2
    80005576:	c57fe0ef          	jal	800041cc <dirlink>
    8000557a:	02054b63          	bltz	a0,800055b0 <sys_link+0xc8>
  iunlockput(dp);
    8000557e:	854a                	mv	a0,s2
    80005580:	edafe0ef          	jal	80003c5a <iunlockput>
  iput(ip);
    80005584:	8526                	mv	a0,s1
    80005586:	e4cfe0ef          	jal	80003bd2 <iput>
  end_op();
    8000558a:	f1bfe0ef          	jal	800044a4 <end_op>
  return 0;
    8000558e:	4781                	li	a5,0
    80005590:	64f2                	ld	s1,280(sp)
    80005592:	6952                	ld	s2,272(sp)
    80005594:	a0a1                	j	800055dc <sys_link+0xf4>
    end_op();
    80005596:	f0ffe0ef          	jal	800044a4 <end_op>
    return -1;
    8000559a:	57fd                	li	a5,-1
    8000559c:	64f2                	ld	s1,280(sp)
    8000559e:	a83d                	j	800055dc <sys_link+0xf4>
    iunlockput(ip);
    800055a0:	8526                	mv	a0,s1
    800055a2:	eb8fe0ef          	jal	80003c5a <iunlockput>
    end_op();
    800055a6:	efffe0ef          	jal	800044a4 <end_op>
    return -1;
    800055aa:	57fd                	li	a5,-1
    800055ac:	64f2                	ld	s1,280(sp)
    800055ae:	a03d                	j	800055dc <sys_link+0xf4>
    iunlockput(dp);
    800055b0:	854a                	mv	a0,s2
    800055b2:	ea8fe0ef          	jal	80003c5a <iunlockput>
  ilock(ip);
    800055b6:	8526                	mv	a0,s1
    800055b8:	c98fe0ef          	jal	80003a50 <ilock>
  ip->nlink--;
    800055bc:	04a4d783          	lhu	a5,74(s1)
    800055c0:	37fd                	addiw	a5,a5,-1
    800055c2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055c6:	8526                	mv	a0,s1
    800055c8:	bd4fe0ef          	jal	8000399c <iupdate>
  iunlockput(ip);
    800055cc:	8526                	mv	a0,s1
    800055ce:	e8cfe0ef          	jal	80003c5a <iunlockput>
  end_op();
    800055d2:	ed3fe0ef          	jal	800044a4 <end_op>
  return -1;
    800055d6:	57fd                	li	a5,-1
    800055d8:	64f2                	ld	s1,280(sp)
    800055da:	6952                	ld	s2,272(sp)
}
    800055dc:	853e                	mv	a0,a5
    800055de:	70b2                	ld	ra,296(sp)
    800055e0:	7412                	ld	s0,288(sp)
    800055e2:	6155                	addi	sp,sp,304
    800055e4:	8082                	ret

00000000800055e6 <sys_unlink>:
{
    800055e6:	7151                	addi	sp,sp,-240
    800055e8:	f586                	sd	ra,232(sp)
    800055ea:	f1a2                	sd	s0,224(sp)
    800055ec:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055ee:	08000613          	li	a2,128
    800055f2:	f3040593          	addi	a1,s0,-208
    800055f6:	4501                	li	a0,0
    800055f8:	fa2fd0ef          	jal	80002d9a <argstr>
    800055fc:	16054063          	bltz	a0,8000575c <sys_unlink+0x176>
    80005600:	eda6                	sd	s1,216(sp)
  begin_op();
    80005602:	e39fe0ef          	jal	8000443a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005606:	fb040593          	addi	a1,s0,-80
    8000560a:	f3040513          	addi	a0,s0,-208
    8000560e:	c73fe0ef          	jal	80004280 <nameiparent>
    80005612:	84aa                	mv	s1,a0
    80005614:	c945                	beqz	a0,800056c4 <sys_unlink+0xde>
  ilock(dp);
    80005616:	c3afe0ef          	jal	80003a50 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000561a:	00003597          	auipc	a1,0x3
    8000561e:	3ee58593          	addi	a1,a1,1006 # 80008a08 <etext+0xa08>
    80005622:	fb040513          	addi	a0,s0,-80
    80005626:	9c5fe0ef          	jal	80003fea <namecmp>
    8000562a:	10050e63          	beqz	a0,80005746 <sys_unlink+0x160>
    8000562e:	00003597          	auipc	a1,0x3
    80005632:	3e258593          	addi	a1,a1,994 # 80008a10 <etext+0xa10>
    80005636:	fb040513          	addi	a0,s0,-80
    8000563a:	9b1fe0ef          	jal	80003fea <namecmp>
    8000563e:	10050463          	beqz	a0,80005746 <sys_unlink+0x160>
    80005642:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005644:	f2c40613          	addi	a2,s0,-212
    80005648:	fb040593          	addi	a1,s0,-80
    8000564c:	8526                	mv	a0,s1
    8000564e:	9b3fe0ef          	jal	80004000 <dirlookup>
    80005652:	892a                	mv	s2,a0
    80005654:	0e050863          	beqz	a0,80005744 <sys_unlink+0x15e>
  ilock(ip);
    80005658:	bf8fe0ef          	jal	80003a50 <ilock>
  if(ip->nlink < 1)
    8000565c:	04a91783          	lh	a5,74(s2)
    80005660:	06f05763          	blez	a5,800056ce <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005664:	04491703          	lh	a4,68(s2)
    80005668:	4785                	li	a5,1
    8000566a:	06f70963          	beq	a4,a5,800056dc <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    8000566e:	4641                	li	a2,16
    80005670:	4581                	li	a1,0
    80005672:	fc040513          	addi	a0,s0,-64
    80005676:	fd6fb0ef          	jal	80000e4c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000567a:	4741                	li	a4,16
    8000567c:	f2c42683          	lw	a3,-212(s0)
    80005680:	fc040613          	addi	a2,s0,-64
    80005684:	4581                	li	a1,0
    80005686:	8526                	mv	a0,s1
    80005688:	855fe0ef          	jal	80003edc <writei>
    8000568c:	47c1                	li	a5,16
    8000568e:	08f51b63          	bne	a0,a5,80005724 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005692:	04491703          	lh	a4,68(s2)
    80005696:	4785                	li	a5,1
    80005698:	08f70d63          	beq	a4,a5,80005732 <sys_unlink+0x14c>
  iunlockput(dp);
    8000569c:	8526                	mv	a0,s1
    8000569e:	dbcfe0ef          	jal	80003c5a <iunlockput>
  ip->nlink--;
    800056a2:	04a95783          	lhu	a5,74(s2)
    800056a6:	37fd                	addiw	a5,a5,-1
    800056a8:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056ac:	854a                	mv	a0,s2
    800056ae:	aeefe0ef          	jal	8000399c <iupdate>
  iunlockput(ip);
    800056b2:	854a                	mv	a0,s2
    800056b4:	da6fe0ef          	jal	80003c5a <iunlockput>
  end_op();
    800056b8:	dedfe0ef          	jal	800044a4 <end_op>
  return 0;
    800056bc:	4501                	li	a0,0
    800056be:	64ee                	ld	s1,216(sp)
    800056c0:	694e                	ld	s2,208(sp)
    800056c2:	a849                	j	80005754 <sys_unlink+0x16e>
    end_op();
    800056c4:	de1fe0ef          	jal	800044a4 <end_op>
    return -1;
    800056c8:	557d                	li	a0,-1
    800056ca:	64ee                	ld	s1,216(sp)
    800056cc:	a061                	j	80005754 <sys_unlink+0x16e>
    800056ce:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800056d0:	00003517          	auipc	a0,0x3
    800056d4:	34850513          	addi	a0,a0,840 # 80008a18 <etext+0xa18>
    800056d8:	908fb0ef          	jal	800007e0 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056dc:	04c92703          	lw	a4,76(s2)
    800056e0:	02000793          	li	a5,32
    800056e4:	f8e7f5e3          	bgeu	a5,a4,8000566e <sys_unlink+0x88>
    800056e8:	e5ce                	sd	s3,200(sp)
    800056ea:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056ee:	4741                	li	a4,16
    800056f0:	86ce                	mv	a3,s3
    800056f2:	f1840613          	addi	a2,s0,-232
    800056f6:	4581                	li	a1,0
    800056f8:	854a                	mv	a0,s2
    800056fa:	ee6fe0ef          	jal	80003de0 <readi>
    800056fe:	47c1                	li	a5,16
    80005700:	00f51c63          	bne	a0,a5,80005718 <sys_unlink+0x132>
    if(de.inum != 0)
    80005704:	f1845783          	lhu	a5,-232(s0)
    80005708:	efa1                	bnez	a5,80005760 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000570a:	29c1                	addiw	s3,s3,16
    8000570c:	04c92783          	lw	a5,76(s2)
    80005710:	fcf9efe3          	bltu	s3,a5,800056ee <sys_unlink+0x108>
    80005714:	69ae                	ld	s3,200(sp)
    80005716:	bfa1                	j	8000566e <sys_unlink+0x88>
      panic("isdirempty: readi");
    80005718:	00003517          	auipc	a0,0x3
    8000571c:	31850513          	addi	a0,a0,792 # 80008a30 <etext+0xa30>
    80005720:	8c0fb0ef          	jal	800007e0 <panic>
    80005724:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80005726:	00003517          	auipc	a0,0x3
    8000572a:	32250513          	addi	a0,a0,802 # 80008a48 <etext+0xa48>
    8000572e:	8b2fb0ef          	jal	800007e0 <panic>
    dp->nlink--;
    80005732:	04a4d783          	lhu	a5,74(s1)
    80005736:	37fd                	addiw	a5,a5,-1
    80005738:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000573c:	8526                	mv	a0,s1
    8000573e:	a5efe0ef          	jal	8000399c <iupdate>
    80005742:	bfa9                	j	8000569c <sys_unlink+0xb6>
    80005744:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005746:	8526                	mv	a0,s1
    80005748:	d12fe0ef          	jal	80003c5a <iunlockput>
  end_op();
    8000574c:	d59fe0ef          	jal	800044a4 <end_op>
  return -1;
    80005750:	557d                	li	a0,-1
    80005752:	64ee                	ld	s1,216(sp)
}
    80005754:	70ae                	ld	ra,232(sp)
    80005756:	740e                	ld	s0,224(sp)
    80005758:	616d                	addi	sp,sp,240
    8000575a:	8082                	ret
    return -1;
    8000575c:	557d                	li	a0,-1
    8000575e:	bfdd                	j	80005754 <sys_unlink+0x16e>
    iunlockput(ip);
    80005760:	854a                	mv	a0,s2
    80005762:	cf8fe0ef          	jal	80003c5a <iunlockput>
    goto bad;
    80005766:	694e                	ld	s2,208(sp)
    80005768:	69ae                	ld	s3,200(sp)
    8000576a:	bff1                	j	80005746 <sys_unlink+0x160>

000000008000576c <sys_open>:

uint64
sys_open(void)
{
    8000576c:	7131                	addi	sp,sp,-192
    8000576e:	fd06                	sd	ra,184(sp)
    80005770:	f922                	sd	s0,176(sp)
    80005772:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005774:	f4c40593          	addi	a1,s0,-180
    80005778:	4505                	li	a0,1
    8000577a:	de8fd0ef          	jal	80002d62 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000577e:	08000613          	li	a2,128
    80005782:	f5040593          	addi	a1,s0,-176
    80005786:	4501                	li	a0,0
    80005788:	e12fd0ef          	jal	80002d9a <argstr>
    8000578c:	87aa                	mv	a5,a0
    return -1;
    8000578e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005790:	0a07c263          	bltz	a5,80005834 <sys_open+0xc8>
    80005794:	f526                	sd	s1,168(sp)

  begin_op();
    80005796:	ca5fe0ef          	jal	8000443a <begin_op>

  if(omode & O_CREATE){
    8000579a:	f4c42783          	lw	a5,-180(s0)
    8000579e:	2007f793          	andi	a5,a5,512
    800057a2:	c3d5                	beqz	a5,80005846 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    800057a4:	4681                	li	a3,0
    800057a6:	4601                	li	a2,0
    800057a8:	4589                	li	a1,2
    800057aa:	f5040513          	addi	a0,s0,-176
    800057ae:	aa9ff0ef          	jal	80005256 <create>
    800057b2:	84aa                	mv	s1,a0
    if(ip == 0){
    800057b4:	c541                	beqz	a0,8000583c <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057b6:	04449703          	lh	a4,68(s1)
    800057ba:	478d                	li	a5,3
    800057bc:	00f71763          	bne	a4,a5,800057ca <sys_open+0x5e>
    800057c0:	0464d703          	lhu	a4,70(s1)
    800057c4:	47a5                	li	a5,9
    800057c6:	0ae7ed63          	bltu	a5,a4,80005880 <sys_open+0x114>
    800057ca:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800057cc:	fd7fe0ef          	jal	800047a2 <filealloc>
    800057d0:	892a                	mv	s2,a0
    800057d2:	c179                	beqz	a0,80005898 <sys_open+0x12c>
    800057d4:	ed4e                	sd	s3,152(sp)
    800057d6:	a43ff0ef          	jal	80005218 <fdalloc>
    800057da:	89aa                	mv	s3,a0
    800057dc:	0a054a63          	bltz	a0,80005890 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057e0:	04449703          	lh	a4,68(s1)
    800057e4:	478d                	li	a5,3
    800057e6:	0cf70263          	beq	a4,a5,800058aa <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057ea:	4789                	li	a5,2
    800057ec:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800057f0:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800057f4:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800057f8:	f4c42783          	lw	a5,-180(s0)
    800057fc:	0017c713          	xori	a4,a5,1
    80005800:	8b05                	andi	a4,a4,1
    80005802:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005806:	0037f713          	andi	a4,a5,3
    8000580a:	00e03733          	snez	a4,a4
    8000580e:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005812:	4007f793          	andi	a5,a5,1024
    80005816:	c791                	beqz	a5,80005822 <sys_open+0xb6>
    80005818:	04449703          	lh	a4,68(s1)
    8000581c:	4789                	li	a5,2
    8000581e:	08f70d63          	beq	a4,a5,800058b8 <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005822:	8526                	mv	a0,s1
    80005824:	adafe0ef          	jal	80003afe <iunlock>
  end_op();
    80005828:	c7dfe0ef          	jal	800044a4 <end_op>

  return fd;
    8000582c:	854e                	mv	a0,s3
    8000582e:	74aa                	ld	s1,168(sp)
    80005830:	790a                	ld	s2,160(sp)
    80005832:	69ea                	ld	s3,152(sp)
}
    80005834:	70ea                	ld	ra,184(sp)
    80005836:	744a                	ld	s0,176(sp)
    80005838:	6129                	addi	sp,sp,192
    8000583a:	8082                	ret
      end_op();
    8000583c:	c69fe0ef          	jal	800044a4 <end_op>
      return -1;
    80005840:	557d                	li	a0,-1
    80005842:	74aa                	ld	s1,168(sp)
    80005844:	bfc5                	j	80005834 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80005846:	f5040513          	addi	a0,s0,-176
    8000584a:	a1dfe0ef          	jal	80004266 <namei>
    8000584e:	84aa                	mv	s1,a0
    80005850:	c11d                	beqz	a0,80005876 <sys_open+0x10a>
    ilock(ip);
    80005852:	9fefe0ef          	jal	80003a50 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005856:	04449703          	lh	a4,68(s1)
    8000585a:	4785                	li	a5,1
    8000585c:	f4f71de3          	bne	a4,a5,800057b6 <sys_open+0x4a>
    80005860:	f4c42783          	lw	a5,-180(s0)
    80005864:	d3bd                	beqz	a5,800057ca <sys_open+0x5e>
      iunlockput(ip);
    80005866:	8526                	mv	a0,s1
    80005868:	bf2fe0ef          	jal	80003c5a <iunlockput>
      end_op();
    8000586c:	c39fe0ef          	jal	800044a4 <end_op>
      return -1;
    80005870:	557d                	li	a0,-1
    80005872:	74aa                	ld	s1,168(sp)
    80005874:	b7c1                	j	80005834 <sys_open+0xc8>
      end_op();
    80005876:	c2ffe0ef          	jal	800044a4 <end_op>
      return -1;
    8000587a:	557d                	li	a0,-1
    8000587c:	74aa                	ld	s1,168(sp)
    8000587e:	bf5d                	j	80005834 <sys_open+0xc8>
    iunlockput(ip);
    80005880:	8526                	mv	a0,s1
    80005882:	bd8fe0ef          	jal	80003c5a <iunlockput>
    end_op();
    80005886:	c1ffe0ef          	jal	800044a4 <end_op>
    return -1;
    8000588a:	557d                	li	a0,-1
    8000588c:	74aa                	ld	s1,168(sp)
    8000588e:	b75d                	j	80005834 <sys_open+0xc8>
      fileclose(f);
    80005890:	854a                	mv	a0,s2
    80005892:	fb5fe0ef          	jal	80004846 <fileclose>
    80005896:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005898:	8526                	mv	a0,s1
    8000589a:	bc0fe0ef          	jal	80003c5a <iunlockput>
    end_op();
    8000589e:	c07fe0ef          	jal	800044a4 <end_op>
    return -1;
    800058a2:	557d                	li	a0,-1
    800058a4:	74aa                	ld	s1,168(sp)
    800058a6:	790a                	ld	s2,160(sp)
    800058a8:	b771                	j	80005834 <sys_open+0xc8>
    f->type = FD_DEVICE;
    800058aa:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800058ae:	04649783          	lh	a5,70(s1)
    800058b2:	02f91223          	sh	a5,36(s2)
    800058b6:	bf3d                	j	800057f4 <sys_open+0x88>
    itrunc(ip);
    800058b8:	8526                	mv	a0,s1
    800058ba:	a84fe0ef          	jal	80003b3e <itrunc>
    800058be:	b795                	j	80005822 <sys_open+0xb6>

00000000800058c0 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058c0:	7175                	addi	sp,sp,-144
    800058c2:	e506                	sd	ra,136(sp)
    800058c4:	e122                	sd	s0,128(sp)
    800058c6:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058c8:	b73fe0ef          	jal	8000443a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058cc:	08000613          	li	a2,128
    800058d0:	f7040593          	addi	a1,s0,-144
    800058d4:	4501                	li	a0,0
    800058d6:	cc4fd0ef          	jal	80002d9a <argstr>
    800058da:	02054363          	bltz	a0,80005900 <sys_mkdir+0x40>
    800058de:	4681                	li	a3,0
    800058e0:	4601                	li	a2,0
    800058e2:	4585                	li	a1,1
    800058e4:	f7040513          	addi	a0,s0,-144
    800058e8:	96fff0ef          	jal	80005256 <create>
    800058ec:	c911                	beqz	a0,80005900 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058ee:	b6cfe0ef          	jal	80003c5a <iunlockput>
  end_op();
    800058f2:	bb3fe0ef          	jal	800044a4 <end_op>
  return 0;
    800058f6:	4501                	li	a0,0
}
    800058f8:	60aa                	ld	ra,136(sp)
    800058fa:	640a                	ld	s0,128(sp)
    800058fc:	6149                	addi	sp,sp,144
    800058fe:	8082                	ret
    end_op();
    80005900:	ba5fe0ef          	jal	800044a4 <end_op>
    return -1;
    80005904:	557d                	li	a0,-1
    80005906:	bfcd                	j	800058f8 <sys_mkdir+0x38>

0000000080005908 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005908:	7135                	addi	sp,sp,-160
    8000590a:	ed06                	sd	ra,152(sp)
    8000590c:	e922                	sd	s0,144(sp)
    8000590e:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005910:	b2bfe0ef          	jal	8000443a <begin_op>
  argint(1, &major);
    80005914:	f6c40593          	addi	a1,s0,-148
    80005918:	4505                	li	a0,1
    8000591a:	c48fd0ef          	jal	80002d62 <argint>
  argint(2, &minor);
    8000591e:	f6840593          	addi	a1,s0,-152
    80005922:	4509                	li	a0,2
    80005924:	c3efd0ef          	jal	80002d62 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005928:	08000613          	li	a2,128
    8000592c:	f7040593          	addi	a1,s0,-144
    80005930:	4501                	li	a0,0
    80005932:	c68fd0ef          	jal	80002d9a <argstr>
    80005936:	02054563          	bltz	a0,80005960 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000593a:	f6841683          	lh	a3,-152(s0)
    8000593e:	f6c41603          	lh	a2,-148(s0)
    80005942:	458d                	li	a1,3
    80005944:	f7040513          	addi	a0,s0,-144
    80005948:	90fff0ef          	jal	80005256 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000594c:	c911                	beqz	a0,80005960 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000594e:	b0cfe0ef          	jal	80003c5a <iunlockput>
  end_op();
    80005952:	b53fe0ef          	jal	800044a4 <end_op>
  return 0;
    80005956:	4501                	li	a0,0
}
    80005958:	60ea                	ld	ra,152(sp)
    8000595a:	644a                	ld	s0,144(sp)
    8000595c:	610d                	addi	sp,sp,160
    8000595e:	8082                	ret
    end_op();
    80005960:	b45fe0ef          	jal	800044a4 <end_op>
    return -1;
    80005964:	557d                	li	a0,-1
    80005966:	bfcd                	j	80005958 <sys_mknod+0x50>

0000000080005968 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005968:	7135                	addi	sp,sp,-160
    8000596a:	ed06                	sd	ra,152(sp)
    8000596c:	e922                	sd	s0,144(sp)
    8000596e:	e14a                	sd	s2,128(sp)
    80005970:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005972:	aeafc0ef          	jal	80001c5c <myproc>
    80005976:	892a                	mv	s2,a0
  
  begin_op();
    80005978:	ac3fe0ef          	jal	8000443a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000597c:	08000613          	li	a2,128
    80005980:	f6040593          	addi	a1,s0,-160
    80005984:	4501                	li	a0,0
    80005986:	c14fd0ef          	jal	80002d9a <argstr>
    8000598a:	04054363          	bltz	a0,800059d0 <sys_chdir+0x68>
    8000598e:	e526                	sd	s1,136(sp)
    80005990:	f6040513          	addi	a0,s0,-160
    80005994:	8d3fe0ef          	jal	80004266 <namei>
    80005998:	84aa                	mv	s1,a0
    8000599a:	c915                	beqz	a0,800059ce <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000599c:	8b4fe0ef          	jal	80003a50 <ilock>
  if(ip->type != T_DIR){
    800059a0:	04449703          	lh	a4,68(s1)
    800059a4:	4785                	li	a5,1
    800059a6:	02f71963          	bne	a4,a5,800059d8 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059aa:	8526                	mv	a0,s1
    800059ac:	952fe0ef          	jal	80003afe <iunlock>
  iput(p->cwd);
    800059b0:	15893503          	ld	a0,344(s2)
    800059b4:	a1efe0ef          	jal	80003bd2 <iput>
  end_op();
    800059b8:	aedfe0ef          	jal	800044a4 <end_op>
  p->cwd = ip;
    800059bc:	14993c23          	sd	s1,344(s2)
  return 0;
    800059c0:	4501                	li	a0,0
    800059c2:	64aa                	ld	s1,136(sp)
}
    800059c4:	60ea                	ld	ra,152(sp)
    800059c6:	644a                	ld	s0,144(sp)
    800059c8:	690a                	ld	s2,128(sp)
    800059ca:	610d                	addi	sp,sp,160
    800059cc:	8082                	ret
    800059ce:	64aa                	ld	s1,136(sp)
    end_op();
    800059d0:	ad5fe0ef          	jal	800044a4 <end_op>
    return -1;
    800059d4:	557d                	li	a0,-1
    800059d6:	b7fd                	j	800059c4 <sys_chdir+0x5c>
    iunlockput(ip);
    800059d8:	8526                	mv	a0,s1
    800059da:	a80fe0ef          	jal	80003c5a <iunlockput>
    end_op();
    800059de:	ac7fe0ef          	jal	800044a4 <end_op>
    return -1;
    800059e2:	557d                	li	a0,-1
    800059e4:	64aa                	ld	s1,136(sp)
    800059e6:	bff9                	j	800059c4 <sys_chdir+0x5c>

00000000800059e8 <sys_exec>:

uint64
sys_exec(void)
{
    800059e8:	7121                	addi	sp,sp,-448
    800059ea:	ff06                	sd	ra,440(sp)
    800059ec:	fb22                	sd	s0,432(sp)
    800059ee:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800059f0:	e4840593          	addi	a1,s0,-440
    800059f4:	4505                	li	a0,1
    800059f6:	b88fd0ef          	jal	80002d7e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800059fa:	08000613          	li	a2,128
    800059fe:	f5040593          	addi	a1,s0,-176
    80005a02:	4501                	li	a0,0
    80005a04:	b96fd0ef          	jal	80002d9a <argstr>
    80005a08:	87aa                	mv	a5,a0
    return -1;
    80005a0a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a0c:	0c07c463          	bltz	a5,80005ad4 <sys_exec+0xec>
    80005a10:	f726                	sd	s1,424(sp)
    80005a12:	f34a                	sd	s2,416(sp)
    80005a14:	ef4e                	sd	s3,408(sp)
    80005a16:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005a18:	10000613          	li	a2,256
    80005a1c:	4581                	li	a1,0
    80005a1e:	e5040513          	addi	a0,s0,-432
    80005a22:	c2afb0ef          	jal	80000e4c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a26:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a2a:	89a6                	mv	s3,s1
    80005a2c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a2e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a32:	00391513          	slli	a0,s2,0x3
    80005a36:	e4040593          	addi	a1,s0,-448
    80005a3a:	e4843783          	ld	a5,-440(s0)
    80005a3e:	953e                	add	a0,a0,a5
    80005a40:	a98fd0ef          	jal	80002cd8 <fetchaddr>
    80005a44:	02054663          	bltz	a0,80005a70 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005a48:	e4043783          	ld	a5,-448(s0)
    80005a4c:	c3a9                	beqz	a5,80005a8e <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a4e:	984fb0ef          	jal	80000bd2 <kalloc>
    80005a52:	85aa                	mv	a1,a0
    80005a54:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a58:	cd01                	beqz	a0,80005a70 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a5a:	6605                	lui	a2,0x1
    80005a5c:	e4043503          	ld	a0,-448(s0)
    80005a60:	ac2fd0ef          	jal	80002d22 <fetchstr>
    80005a64:	00054663          	bltz	a0,80005a70 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005a68:	0905                	addi	s2,s2,1
    80005a6a:	09a1                	addi	s3,s3,8
    80005a6c:	fd4913e3          	bne	s2,s4,80005a32 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a70:	f5040913          	addi	s2,s0,-176
    80005a74:	6088                	ld	a0,0(s1)
    80005a76:	c931                	beqz	a0,80005aca <sys_exec+0xe2>
    kfree(argv[i]);
    80005a78:	fa5fa0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a7c:	04a1                	addi	s1,s1,8
    80005a7e:	ff249be3          	bne	s1,s2,80005a74 <sys_exec+0x8c>
  return -1;
    80005a82:	557d                	li	a0,-1
    80005a84:	74ba                	ld	s1,424(sp)
    80005a86:	791a                	ld	s2,416(sp)
    80005a88:	69fa                	ld	s3,408(sp)
    80005a8a:	6a5a                	ld	s4,400(sp)
    80005a8c:	a0a1                	j	80005ad4 <sys_exec+0xec>
      argv[i] = 0;
    80005a8e:	0009079b          	sext.w	a5,s2
    80005a92:	078e                	slli	a5,a5,0x3
    80005a94:	fd078793          	addi	a5,a5,-48
    80005a98:	97a2                	add	a5,a5,s0
    80005a9a:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005a9e:	e5040593          	addi	a1,s0,-432
    80005aa2:	f5040513          	addi	a0,s0,-176
    80005aa6:	ba8ff0ef          	jal	80004e4e <kexec>
    80005aaa:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aac:	f5040993          	addi	s3,s0,-176
    80005ab0:	6088                	ld	a0,0(s1)
    80005ab2:	c511                	beqz	a0,80005abe <sys_exec+0xd6>
    kfree(argv[i]);
    80005ab4:	f69fa0ef          	jal	80000a1c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ab8:	04a1                	addi	s1,s1,8
    80005aba:	ff349be3          	bne	s1,s3,80005ab0 <sys_exec+0xc8>
  return ret;
    80005abe:	854a                	mv	a0,s2
    80005ac0:	74ba                	ld	s1,424(sp)
    80005ac2:	791a                	ld	s2,416(sp)
    80005ac4:	69fa                	ld	s3,408(sp)
    80005ac6:	6a5a                	ld	s4,400(sp)
    80005ac8:	a031                	j	80005ad4 <sys_exec+0xec>
  return -1;
    80005aca:	557d                	li	a0,-1
    80005acc:	74ba                	ld	s1,424(sp)
    80005ace:	791a                	ld	s2,416(sp)
    80005ad0:	69fa                	ld	s3,408(sp)
    80005ad2:	6a5a                	ld	s4,400(sp)
}
    80005ad4:	70fa                	ld	ra,440(sp)
    80005ad6:	745a                	ld	s0,432(sp)
    80005ad8:	6139                	addi	sp,sp,448
    80005ada:	8082                	ret

0000000080005adc <sys_pipe>:

uint64
sys_pipe(void)
{
    80005adc:	7139                	addi	sp,sp,-64
    80005ade:	fc06                	sd	ra,56(sp)
    80005ae0:	f822                	sd	s0,48(sp)
    80005ae2:	f426                	sd	s1,40(sp)
    80005ae4:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005ae6:	976fc0ef          	jal	80001c5c <myproc>
    80005aea:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005aec:	fd840593          	addi	a1,s0,-40
    80005af0:	4501                	li	a0,0
    80005af2:	a8cfd0ef          	jal	80002d7e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005af6:	fc840593          	addi	a1,s0,-56
    80005afa:	fd040513          	addi	a0,s0,-48
    80005afe:	852ff0ef          	jal	80004b50 <pipealloc>
    return -1;
    80005b02:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b04:	0a054463          	bltz	a0,80005bac <sys_pipe+0xd0>
  fd0 = -1;
    80005b08:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b0c:	fd043503          	ld	a0,-48(s0)
    80005b10:	f08ff0ef          	jal	80005218 <fdalloc>
    80005b14:	fca42223          	sw	a0,-60(s0)
    80005b18:	08054163          	bltz	a0,80005b9a <sys_pipe+0xbe>
    80005b1c:	fc843503          	ld	a0,-56(s0)
    80005b20:	ef8ff0ef          	jal	80005218 <fdalloc>
    80005b24:	fca42023          	sw	a0,-64(s0)
    80005b28:	06054063          	bltz	a0,80005b88 <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b2c:	4691                	li	a3,4
    80005b2e:	fc440613          	addi	a2,s0,-60
    80005b32:	fd843583          	ld	a1,-40(s0)
    80005b36:	6ca8                	ld	a0,88(s1)
    80005b38:	c95fb0ef          	jal	800017cc <copyout>
    80005b3c:	00054e63          	bltz	a0,80005b58 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b40:	4691                	li	a3,4
    80005b42:	fc040613          	addi	a2,s0,-64
    80005b46:	fd843583          	ld	a1,-40(s0)
    80005b4a:	0591                	addi	a1,a1,4
    80005b4c:	6ca8                	ld	a0,88(s1)
    80005b4e:	c7ffb0ef          	jal	800017cc <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b52:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b54:	04055c63          	bgez	a0,80005bac <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005b58:	fc442783          	lw	a5,-60(s0)
    80005b5c:	07e9                	addi	a5,a5,26
    80005b5e:	078e                	slli	a5,a5,0x3
    80005b60:	97a6                	add	a5,a5,s1
    80005b62:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005b66:	fc042783          	lw	a5,-64(s0)
    80005b6a:	07e9                	addi	a5,a5,26
    80005b6c:	078e                	slli	a5,a5,0x3
    80005b6e:	94be                	add	s1,s1,a5
    80005b70:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005b74:	fd043503          	ld	a0,-48(s0)
    80005b78:	ccffe0ef          	jal	80004846 <fileclose>
    fileclose(wf);
    80005b7c:	fc843503          	ld	a0,-56(s0)
    80005b80:	cc7fe0ef          	jal	80004846 <fileclose>
    return -1;
    80005b84:	57fd                	li	a5,-1
    80005b86:	a01d                	j	80005bac <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005b88:	fc442783          	lw	a5,-60(s0)
    80005b8c:	0007c763          	bltz	a5,80005b9a <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005b90:	07e9                	addi	a5,a5,26
    80005b92:	078e                	slli	a5,a5,0x3
    80005b94:	97a6                	add	a5,a5,s1
    80005b96:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80005b9a:	fd043503          	ld	a0,-48(s0)
    80005b9e:	ca9fe0ef          	jal	80004846 <fileclose>
    fileclose(wf);
    80005ba2:	fc843503          	ld	a0,-56(s0)
    80005ba6:	ca1fe0ef          	jal	80004846 <fileclose>
    return -1;
    80005baa:	57fd                	li	a5,-1
}
    80005bac:	853e                	mv	a0,a5
    80005bae:	70e2                	ld	ra,56(sp)
    80005bb0:	7442                	ld	s0,48(sp)
    80005bb2:	74a2                	ld	s1,40(sp)
    80005bb4:	6121                	addi	sp,sp,64
    80005bb6:	8082                	ret
	...

0000000080005bc0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005bc0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005bc2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005bc4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005bc6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005bc8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005bca:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005bcc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005bce:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005bd0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005bd2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005bd4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005bd6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005bd8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005bda:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005bdc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005bde:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005be0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005be2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005be4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005be6:	802fd0ef          	jal	80002be8 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005bea:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005bec:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005bee:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005bf0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005bf2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005bf4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005bf6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005bf8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005bfa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005bfc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005bfe:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005c00:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005c02:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005c04:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005c06:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005c08:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005c0a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005c0c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005c0e:	10200073          	sret
	...

0000000080005c1e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005c1e:	1141                	addi	sp,sp,-16
    80005c20:	e422                	sd	s0,8(sp)
    80005c22:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005c24:	0c0007b7          	lui	a5,0xc000
    80005c28:	4705                	li	a4,1
    80005c2a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005c2c:	0c0007b7          	lui	a5,0xc000
    80005c30:	c3d8                	sw	a4,4(a5)
}
    80005c32:	6422                	ld	s0,8(sp)
    80005c34:	0141                	addi	sp,sp,16
    80005c36:	8082                	ret

0000000080005c38 <plicinithart>:

void
plicinithart(void)
{
    80005c38:	1141                	addi	sp,sp,-16
    80005c3a:	e406                	sd	ra,8(sp)
    80005c3c:	e022                	sd	s0,0(sp)
    80005c3e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c40:	ff1fb0ef          	jal	80001c30 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005c44:	0085171b          	slliw	a4,a0,0x8
    80005c48:	0c0027b7          	lui	a5,0xc002
    80005c4c:	97ba                	add	a5,a5,a4
    80005c4e:	40200713          	li	a4,1026
    80005c52:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005c56:	00d5151b          	slliw	a0,a0,0xd
    80005c5a:	0c2017b7          	lui	a5,0xc201
    80005c5e:	97aa                	add	a5,a5,a0
    80005c60:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005c64:	60a2                	ld	ra,8(sp)
    80005c66:	6402                	ld	s0,0(sp)
    80005c68:	0141                	addi	sp,sp,16
    80005c6a:	8082                	ret

0000000080005c6c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005c6c:	1141                	addi	sp,sp,-16
    80005c6e:	e406                	sd	ra,8(sp)
    80005c70:	e022                	sd	s0,0(sp)
    80005c72:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005c74:	fbdfb0ef          	jal	80001c30 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005c78:	00d5151b          	slliw	a0,a0,0xd
    80005c7c:	0c2017b7          	lui	a5,0xc201
    80005c80:	97aa                	add	a5,a5,a0
  return irq;
}
    80005c82:	43c8                	lw	a0,4(a5)
    80005c84:	60a2                	ld	ra,8(sp)
    80005c86:	6402                	ld	s0,0(sp)
    80005c88:	0141                	addi	sp,sp,16
    80005c8a:	8082                	ret

0000000080005c8c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005c8c:	1101                	addi	sp,sp,-32
    80005c8e:	ec06                	sd	ra,24(sp)
    80005c90:	e822                	sd	s0,16(sp)
    80005c92:	e426                	sd	s1,8(sp)
    80005c94:	1000                	addi	s0,sp,32
    80005c96:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005c98:	f99fb0ef          	jal	80001c30 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005c9c:	00d5151b          	slliw	a0,a0,0xd
    80005ca0:	0c2017b7          	lui	a5,0xc201
    80005ca4:	97aa                	add	a5,a5,a0
    80005ca6:	c3c4                	sw	s1,4(a5)
}
    80005ca8:	60e2                	ld	ra,24(sp)
    80005caa:	6442                	ld	s0,16(sp)
    80005cac:	64a2                	ld	s1,8(sp)
    80005cae:	6105                	addi	sp,sp,32
    80005cb0:	8082                	ret

0000000080005cb2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005cb2:	1141                	addi	sp,sp,-16
    80005cb4:	e406                	sd	ra,8(sp)
    80005cb6:	e022                	sd	s0,0(sp)
    80005cb8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005cba:	479d                	li	a5,7
    80005cbc:	04a7ca63          	blt	a5,a0,80005d10 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005cc0:	0023d797          	auipc	a5,0x23d
    80005cc4:	a4878793          	addi	a5,a5,-1464 # 80242708 <disk>
    80005cc8:	97aa                	add	a5,a5,a0
    80005cca:	0187c783          	lbu	a5,24(a5)
    80005cce:	e7b9                	bnez	a5,80005d1c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005cd0:	00451693          	slli	a3,a0,0x4
    80005cd4:	0023d797          	auipc	a5,0x23d
    80005cd8:	a3478793          	addi	a5,a5,-1484 # 80242708 <disk>
    80005cdc:	6398                	ld	a4,0(a5)
    80005cde:	9736                	add	a4,a4,a3
    80005ce0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005ce4:	6398                	ld	a4,0(a5)
    80005ce6:	9736                	add	a4,a4,a3
    80005ce8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005cec:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005cf0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005cf4:	97aa                	add	a5,a5,a0
    80005cf6:	4705                	li	a4,1
    80005cf8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005cfc:	0023d517          	auipc	a0,0x23d
    80005d00:	a2450513          	addi	a0,a0,-1500 # 80242720 <disk+0x18>
    80005d04:	e5afc0ef          	jal	8000235e <wakeup>
}
    80005d08:	60a2                	ld	ra,8(sp)
    80005d0a:	6402                	ld	s0,0(sp)
    80005d0c:	0141                	addi	sp,sp,16
    80005d0e:	8082                	ret
    panic("free_desc 1");
    80005d10:	00003517          	auipc	a0,0x3
    80005d14:	d4850513          	addi	a0,a0,-696 # 80008a58 <etext+0xa58>
    80005d18:	ac9fa0ef          	jal	800007e0 <panic>
    panic("free_desc 2");
    80005d1c:	00003517          	auipc	a0,0x3
    80005d20:	d4c50513          	addi	a0,a0,-692 # 80008a68 <etext+0xa68>
    80005d24:	abdfa0ef          	jal	800007e0 <panic>

0000000080005d28 <virtio_disk_init>:
{
    80005d28:	1101                	addi	sp,sp,-32
    80005d2a:	ec06                	sd	ra,24(sp)
    80005d2c:	e822                	sd	s0,16(sp)
    80005d2e:	e426                	sd	s1,8(sp)
    80005d30:	e04a                	sd	s2,0(sp)
    80005d32:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005d34:	00003597          	auipc	a1,0x3
    80005d38:	d4458593          	addi	a1,a1,-700 # 80008a78 <etext+0xa78>
    80005d3c:	0023d517          	auipc	a0,0x23d
    80005d40:	af450513          	addi	a0,a0,-1292 # 80242830 <disk+0x128>
    80005d44:	fb5fa0ef          	jal	80000cf8 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d48:	100017b7          	lui	a5,0x10001
    80005d4c:	4398                	lw	a4,0(a5)
    80005d4e:	2701                	sext.w	a4,a4
    80005d50:	747277b7          	lui	a5,0x74727
    80005d54:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005d58:	18f71063          	bne	a4,a5,80005ed8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d5c:	100017b7          	lui	a5,0x10001
    80005d60:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005d62:	439c                	lw	a5,0(a5)
    80005d64:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005d66:	4709                	li	a4,2
    80005d68:	16e79863          	bne	a5,a4,80005ed8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d6c:	100017b7          	lui	a5,0x10001
    80005d70:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005d72:	439c                	lw	a5,0(a5)
    80005d74:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005d76:	16e79163          	bne	a5,a4,80005ed8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005d7a:	100017b7          	lui	a5,0x10001
    80005d7e:	47d8                	lw	a4,12(a5)
    80005d80:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005d82:	554d47b7          	lui	a5,0x554d4
    80005d86:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005d8a:	14f71763          	bne	a4,a5,80005ed8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d8e:	100017b7          	lui	a5,0x10001
    80005d92:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d96:	4705                	li	a4,1
    80005d98:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d9a:	470d                	li	a4,3
    80005d9c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005d9e:	10001737          	lui	a4,0x10001
    80005da2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005da4:	c7ffe737          	lui	a4,0xc7ffe
    80005da8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47dbbf17>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005dac:	8ef9                	and	a3,a3,a4
    80005dae:	10001737          	lui	a4,0x10001
    80005db2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db4:	472d                	li	a4,11
    80005db6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005db8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005dbc:	439c                	lw	a5,0(a5)
    80005dbe:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005dc2:	8ba1                	andi	a5,a5,8
    80005dc4:	12078063          	beqz	a5,80005ee4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005dc8:	100017b7          	lui	a5,0x10001
    80005dcc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005dd0:	100017b7          	lui	a5,0x10001
    80005dd4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005dd8:	439c                	lw	a5,0(a5)
    80005dda:	2781                	sext.w	a5,a5
    80005ddc:	10079a63          	bnez	a5,80005ef0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005de0:	100017b7          	lui	a5,0x10001
    80005de4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005de8:	439c                	lw	a5,0(a5)
    80005dea:	2781                	sext.w	a5,a5
  if(max == 0)
    80005dec:	10078863          	beqz	a5,80005efc <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005df0:	471d                	li	a4,7
    80005df2:	10f77b63          	bgeu	a4,a5,80005f08 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005df6:	dddfa0ef          	jal	80000bd2 <kalloc>
    80005dfa:	0023d497          	auipc	s1,0x23d
    80005dfe:	90e48493          	addi	s1,s1,-1778 # 80242708 <disk>
    80005e02:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005e04:	dcffa0ef          	jal	80000bd2 <kalloc>
    80005e08:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005e0a:	dc9fa0ef          	jal	80000bd2 <kalloc>
    80005e0e:	87aa                	mv	a5,a0
    80005e10:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005e12:	6088                	ld	a0,0(s1)
    80005e14:	10050063          	beqz	a0,80005f14 <virtio_disk_init+0x1ec>
    80005e18:	0023d717          	auipc	a4,0x23d
    80005e1c:	8f873703          	ld	a4,-1800(a4) # 80242710 <disk+0x8>
    80005e20:	0e070a63          	beqz	a4,80005f14 <virtio_disk_init+0x1ec>
    80005e24:	0e078863          	beqz	a5,80005f14 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005e28:	6605                	lui	a2,0x1
    80005e2a:	4581                	li	a1,0
    80005e2c:	820fb0ef          	jal	80000e4c <memset>
  memset(disk.avail, 0, PGSIZE);
    80005e30:	0023d497          	auipc	s1,0x23d
    80005e34:	8d848493          	addi	s1,s1,-1832 # 80242708 <disk>
    80005e38:	6605                	lui	a2,0x1
    80005e3a:	4581                	li	a1,0
    80005e3c:	6488                	ld	a0,8(s1)
    80005e3e:	80efb0ef          	jal	80000e4c <memset>
  memset(disk.used, 0, PGSIZE);
    80005e42:	6605                	lui	a2,0x1
    80005e44:	4581                	li	a1,0
    80005e46:	6888                	ld	a0,16(s1)
    80005e48:	804fb0ef          	jal	80000e4c <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005e4c:	100017b7          	lui	a5,0x10001
    80005e50:	4721                	li	a4,8
    80005e52:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005e54:	4098                	lw	a4,0(s1)
    80005e56:	100017b7          	lui	a5,0x10001
    80005e5a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005e5e:	40d8                	lw	a4,4(s1)
    80005e60:	100017b7          	lui	a5,0x10001
    80005e64:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005e68:	649c                	ld	a5,8(s1)
    80005e6a:	0007869b          	sext.w	a3,a5
    80005e6e:	10001737          	lui	a4,0x10001
    80005e72:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005e76:	9781                	srai	a5,a5,0x20
    80005e78:	10001737          	lui	a4,0x10001
    80005e7c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005e80:	689c                	ld	a5,16(s1)
    80005e82:	0007869b          	sext.w	a3,a5
    80005e86:	10001737          	lui	a4,0x10001
    80005e8a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005e8e:	9781                	srai	a5,a5,0x20
    80005e90:	10001737          	lui	a4,0x10001
    80005e94:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005e98:	10001737          	lui	a4,0x10001
    80005e9c:	4785                	li	a5,1
    80005e9e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005ea0:	00f48c23          	sb	a5,24(s1)
    80005ea4:	00f48ca3          	sb	a5,25(s1)
    80005ea8:	00f48d23          	sb	a5,26(s1)
    80005eac:	00f48da3          	sb	a5,27(s1)
    80005eb0:	00f48e23          	sb	a5,28(s1)
    80005eb4:	00f48ea3          	sb	a5,29(s1)
    80005eb8:	00f48f23          	sb	a5,30(s1)
    80005ebc:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005ec0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ec4:	100017b7          	lui	a5,0x10001
    80005ec8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005ecc:	60e2                	ld	ra,24(sp)
    80005ece:	6442                	ld	s0,16(sp)
    80005ed0:	64a2                	ld	s1,8(sp)
    80005ed2:	6902                	ld	s2,0(sp)
    80005ed4:	6105                	addi	sp,sp,32
    80005ed6:	8082                	ret
    panic("could not find virtio disk");
    80005ed8:	00003517          	auipc	a0,0x3
    80005edc:	bb050513          	addi	a0,a0,-1104 # 80008a88 <etext+0xa88>
    80005ee0:	901fa0ef          	jal	800007e0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005ee4:	00003517          	auipc	a0,0x3
    80005ee8:	bc450513          	addi	a0,a0,-1084 # 80008aa8 <etext+0xaa8>
    80005eec:	8f5fa0ef          	jal	800007e0 <panic>
    panic("virtio disk should not be ready");
    80005ef0:	00003517          	auipc	a0,0x3
    80005ef4:	bd850513          	addi	a0,a0,-1064 # 80008ac8 <etext+0xac8>
    80005ef8:	8e9fa0ef          	jal	800007e0 <panic>
    panic("virtio disk has no queue 0");
    80005efc:	00003517          	auipc	a0,0x3
    80005f00:	bec50513          	addi	a0,a0,-1044 # 80008ae8 <etext+0xae8>
    80005f04:	8ddfa0ef          	jal	800007e0 <panic>
    panic("virtio disk max queue too short");
    80005f08:	00003517          	auipc	a0,0x3
    80005f0c:	c0050513          	addi	a0,a0,-1024 # 80008b08 <etext+0xb08>
    80005f10:	8d1fa0ef          	jal	800007e0 <panic>
    panic("virtio disk kalloc");
    80005f14:	00003517          	auipc	a0,0x3
    80005f18:	c1450513          	addi	a0,a0,-1004 # 80008b28 <etext+0xb28>
    80005f1c:	8c5fa0ef          	jal	800007e0 <panic>

0000000080005f20 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005f20:	7159                	addi	sp,sp,-112
    80005f22:	f486                	sd	ra,104(sp)
    80005f24:	f0a2                	sd	s0,96(sp)
    80005f26:	eca6                	sd	s1,88(sp)
    80005f28:	e8ca                	sd	s2,80(sp)
    80005f2a:	e4ce                	sd	s3,72(sp)
    80005f2c:	e0d2                	sd	s4,64(sp)
    80005f2e:	fc56                	sd	s5,56(sp)
    80005f30:	f85a                	sd	s6,48(sp)
    80005f32:	f45e                	sd	s7,40(sp)
    80005f34:	f062                	sd	s8,32(sp)
    80005f36:	ec66                	sd	s9,24(sp)
    80005f38:	1880                	addi	s0,sp,112
    80005f3a:	8a2a                	mv	s4,a0
    80005f3c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005f3e:	00c52c83          	lw	s9,12(a0)
    80005f42:	001c9c9b          	slliw	s9,s9,0x1
    80005f46:	1c82                	slli	s9,s9,0x20
    80005f48:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005f4c:	0023d517          	auipc	a0,0x23d
    80005f50:	8e450513          	addi	a0,a0,-1820 # 80242830 <disk+0x128>
    80005f54:	e25fa0ef          	jal	80000d78 <acquire>
  for(int i = 0; i < 3; i++){
    80005f58:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005f5a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005f5c:	0023cb17          	auipc	s6,0x23c
    80005f60:	7acb0b13          	addi	s6,s6,1964 # 80242708 <disk>
  for(int i = 0; i < 3; i++){
    80005f64:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f66:	0023dc17          	auipc	s8,0x23d
    80005f6a:	8cac0c13          	addi	s8,s8,-1846 # 80242830 <disk+0x128>
    80005f6e:	a8b9                	j	80005fcc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005f70:	00fb0733          	add	a4,s6,a5
    80005f74:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005f78:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005f7a:	0207c563          	bltz	a5,80005fa4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005f7e:	2905                	addiw	s2,s2,1
    80005f80:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005f82:	05590963          	beq	s2,s5,80005fd4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005f86:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005f88:	0023c717          	auipc	a4,0x23c
    80005f8c:	78070713          	addi	a4,a4,1920 # 80242708 <disk>
    80005f90:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005f92:	01874683          	lbu	a3,24(a4)
    80005f96:	fee9                	bnez	a3,80005f70 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005f98:	2785                	addiw	a5,a5,1
    80005f9a:	0705                	addi	a4,a4,1
    80005f9c:	fe979be3          	bne	a5,s1,80005f92 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005fa0:	57fd                	li	a5,-1
    80005fa2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005fa4:	01205d63          	blez	s2,80005fbe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005fa8:	f9042503          	lw	a0,-112(s0)
    80005fac:	d07ff0ef          	jal	80005cb2 <free_desc>
      for(int j = 0; j < i; j++)
    80005fb0:	4785                	li	a5,1
    80005fb2:	0127d663          	bge	a5,s2,80005fbe <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005fb6:	f9442503          	lw	a0,-108(s0)
    80005fba:	cf9ff0ef          	jal	80005cb2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005fbe:	85e2                	mv	a1,s8
    80005fc0:	0023c517          	auipc	a0,0x23c
    80005fc4:	76050513          	addi	a0,a0,1888 # 80242720 <disk+0x18>
    80005fc8:	b4afc0ef          	jal	80002312 <sleep>
  for(int i = 0; i < 3; i++){
    80005fcc:	f9040613          	addi	a2,s0,-112
    80005fd0:	894e                	mv	s2,s3
    80005fd2:	bf55                	j	80005f86 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005fd4:	f9042503          	lw	a0,-112(s0)
    80005fd8:	00451693          	slli	a3,a0,0x4

  if(write)
    80005fdc:	0023c797          	auipc	a5,0x23c
    80005fe0:	72c78793          	addi	a5,a5,1836 # 80242708 <disk>
    80005fe4:	00a50713          	addi	a4,a0,10
    80005fe8:	0712                	slli	a4,a4,0x4
    80005fea:	973e                	add	a4,a4,a5
    80005fec:	01703633          	snez	a2,s7
    80005ff0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005ff2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005ff6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ffa:	6398                	ld	a4,0(a5)
    80005ffc:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005ffe:	0a868613          	addi	a2,a3,168
    80006002:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006004:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006006:	6390                	ld	a2,0(a5)
    80006008:	00d605b3          	add	a1,a2,a3
    8000600c:	4741                	li	a4,16
    8000600e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006010:	4805                	li	a6,1
    80006012:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006016:	f9442703          	lw	a4,-108(s0)
    8000601a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000601e:	0712                	slli	a4,a4,0x4
    80006020:	963a                	add	a2,a2,a4
    80006022:	058a0593          	addi	a1,s4,88
    80006026:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006028:	0007b883          	ld	a7,0(a5)
    8000602c:	9746                	add	a4,a4,a7
    8000602e:	40000613          	li	a2,1024
    80006032:	c710                	sw	a2,8(a4)
  if(write)
    80006034:	001bb613          	seqz	a2,s7
    80006038:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000603c:	00166613          	ori	a2,a2,1
    80006040:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006044:	f9842583          	lw	a1,-104(s0)
    80006048:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000604c:	00250613          	addi	a2,a0,2
    80006050:	0612                	slli	a2,a2,0x4
    80006052:	963e                	add	a2,a2,a5
    80006054:	577d                	li	a4,-1
    80006056:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000605a:	0592                	slli	a1,a1,0x4
    8000605c:	98ae                	add	a7,a7,a1
    8000605e:	03068713          	addi	a4,a3,48
    80006062:	973e                	add	a4,a4,a5
    80006064:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006068:	6398                	ld	a4,0(a5)
    8000606a:	972e                	add	a4,a4,a1
    8000606c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006070:	4689                	li	a3,2
    80006072:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006076:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000607a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000607e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006082:	6794                	ld	a3,8(a5)
    80006084:	0026d703          	lhu	a4,2(a3)
    80006088:	8b1d                	andi	a4,a4,7
    8000608a:	0706                	slli	a4,a4,0x1
    8000608c:	96ba                	add	a3,a3,a4
    8000608e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006092:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006096:	6798                	ld	a4,8(a5)
    80006098:	00275783          	lhu	a5,2(a4)
    8000609c:	2785                	addiw	a5,a5,1
    8000609e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800060a2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800060a6:	100017b7          	lui	a5,0x10001
    800060aa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800060ae:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800060b2:	0023c917          	auipc	s2,0x23c
    800060b6:	77e90913          	addi	s2,s2,1918 # 80242830 <disk+0x128>
  while(b->disk == 1) {
    800060ba:	4485                	li	s1,1
    800060bc:	01079a63          	bne	a5,a6,800060d0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800060c0:	85ca                	mv	a1,s2
    800060c2:	8552                	mv	a0,s4
    800060c4:	a4efc0ef          	jal	80002312 <sleep>
  while(b->disk == 1) {
    800060c8:	004a2783          	lw	a5,4(s4)
    800060cc:	fe978ae3          	beq	a5,s1,800060c0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800060d0:	f9042903          	lw	s2,-112(s0)
    800060d4:	00290713          	addi	a4,s2,2
    800060d8:	0712                	slli	a4,a4,0x4
    800060da:	0023c797          	auipc	a5,0x23c
    800060de:	62e78793          	addi	a5,a5,1582 # 80242708 <disk>
    800060e2:	97ba                	add	a5,a5,a4
    800060e4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800060e8:	0023c997          	auipc	s3,0x23c
    800060ec:	62098993          	addi	s3,s3,1568 # 80242708 <disk>
    800060f0:	00491713          	slli	a4,s2,0x4
    800060f4:	0009b783          	ld	a5,0(s3)
    800060f8:	97ba                	add	a5,a5,a4
    800060fa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800060fe:	854a                	mv	a0,s2
    80006100:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006104:	bafff0ef          	jal	80005cb2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006108:	8885                	andi	s1,s1,1
    8000610a:	f0fd                	bnez	s1,800060f0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000610c:	0023c517          	auipc	a0,0x23c
    80006110:	72450513          	addi	a0,a0,1828 # 80242830 <disk+0x128>
    80006114:	cfdfa0ef          	jal	80000e10 <release>
}
    80006118:	70a6                	ld	ra,104(sp)
    8000611a:	7406                	ld	s0,96(sp)
    8000611c:	64e6                	ld	s1,88(sp)
    8000611e:	6946                	ld	s2,80(sp)
    80006120:	69a6                	ld	s3,72(sp)
    80006122:	6a06                	ld	s4,64(sp)
    80006124:	7ae2                	ld	s5,56(sp)
    80006126:	7b42                	ld	s6,48(sp)
    80006128:	7ba2                	ld	s7,40(sp)
    8000612a:	7c02                	ld	s8,32(sp)
    8000612c:	6ce2                	ld	s9,24(sp)
    8000612e:	6165                	addi	sp,sp,112
    80006130:	8082                	ret

0000000080006132 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006132:	1101                	addi	sp,sp,-32
    80006134:	ec06                	sd	ra,24(sp)
    80006136:	e822                	sd	s0,16(sp)
    80006138:	e426                	sd	s1,8(sp)
    8000613a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000613c:	0023c497          	auipc	s1,0x23c
    80006140:	5cc48493          	addi	s1,s1,1484 # 80242708 <disk>
    80006144:	0023c517          	auipc	a0,0x23c
    80006148:	6ec50513          	addi	a0,a0,1772 # 80242830 <disk+0x128>
    8000614c:	c2dfa0ef          	jal	80000d78 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006150:	100017b7          	lui	a5,0x10001
    80006154:	53b8                	lw	a4,96(a5)
    80006156:	8b0d                	andi	a4,a4,3
    80006158:	100017b7          	lui	a5,0x10001
    8000615c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000615e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006162:	689c                	ld	a5,16(s1)
    80006164:	0204d703          	lhu	a4,32(s1)
    80006168:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000616c:	04f70663          	beq	a4,a5,800061b8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80006170:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006174:	6898                	ld	a4,16(s1)
    80006176:	0204d783          	lhu	a5,32(s1)
    8000617a:	8b9d                	andi	a5,a5,7
    8000617c:	078e                	slli	a5,a5,0x3
    8000617e:	97ba                	add	a5,a5,a4
    80006180:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006182:	00278713          	addi	a4,a5,2
    80006186:	0712                	slli	a4,a4,0x4
    80006188:	9726                	add	a4,a4,s1
    8000618a:	01074703          	lbu	a4,16(a4)
    8000618e:	e321                	bnez	a4,800061ce <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006190:	0789                	addi	a5,a5,2
    80006192:	0792                	slli	a5,a5,0x4
    80006194:	97a6                	add	a5,a5,s1
    80006196:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006198:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000619c:	9c2fc0ef          	jal	8000235e <wakeup>

    disk.used_idx += 1;
    800061a0:	0204d783          	lhu	a5,32(s1)
    800061a4:	2785                	addiw	a5,a5,1
    800061a6:	17c2                	slli	a5,a5,0x30
    800061a8:	93c1                	srli	a5,a5,0x30
    800061aa:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800061ae:	6898                	ld	a4,16(s1)
    800061b0:	00275703          	lhu	a4,2(a4)
    800061b4:	faf71ee3          	bne	a4,a5,80006170 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800061b8:	0023c517          	auipc	a0,0x23c
    800061bc:	67850513          	addi	a0,a0,1656 # 80242830 <disk+0x128>
    800061c0:	c51fa0ef          	jal	80000e10 <release>
}
    800061c4:	60e2                	ld	ra,24(sp)
    800061c6:	6442                	ld	s0,16(sp)
    800061c8:	64a2                	ld	s1,8(sp)
    800061ca:	6105                	addi	sp,sp,32
    800061cc:	8082                	ret
      panic("virtio_disk_intr status");
    800061ce:	00003517          	auipc	a0,0x3
    800061d2:	97250513          	addi	a0,a0,-1678 # 80008b40 <etext+0xb40>
    800061d6:	e0afa0ef          	jal	800007e0 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
