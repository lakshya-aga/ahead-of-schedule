
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	80813103          	ld	sp,-2040(sp) # 80009808 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000016:	03e000ef          	jal	80000054 <start>

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
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    80000022:	30a027f3          	csrr	a5,0x30a
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | MENVCFG_STCE);
    80000026:	577d                	li	a4,-1
    80000028:	177e                	slli	a4,a4,0x3f
    8000002a:	8fd9                	or	a5,a5,a4

static inline void
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    8000002c:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r"(x));
    80000030:	306027f3          	csrr	a5,mcounteren

  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000034:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r"(x));
    80000038:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r"(x));
    8000003c:	c01027f3          	rdtime	a5

  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    80000040:	000f4737          	lui	a4,0xf4
    80000044:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000048:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    8000004a:	14d79073          	csrw	stimecmp,a5
}
    8000004e:	6422                	ld	s0,8(sp)
    80000050:	0141                	addi	sp,sp,16
    80000052:	8082                	ret

0000000080000054 <start>:
{
    80000054:	1141                	addi	sp,sp,-16
    80000056:	e406                	sd	ra,8(sp)
    80000058:	e022                	sd	s0,0(sp)
    8000005a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r"(x));
    8000005c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000060:	7779                	lui	a4,0xffffe
    80000062:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdbc8f>
    80000066:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000068:	6705                	lui	a4,0x1
    8000006a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000006e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r"(x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r"(x));
    80000074:	00001797          	auipc	a5,0x1
    80000078:	d7a78793          	addi	a5,a5,-646 # 80000dee <main>
    8000007c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r"(x));
    80000080:	4781                	li	a5,0
    80000082:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r"(x));
    80000086:	67c1                	lui	a5,0x10
    80000088:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000008a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r"(x));
    8000008e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r"(x));
    80000092:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    80000096:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r"(x));
    8000009a:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r"(x));
    8000009e:	57fd                	li	a5,-1
    800000a0:	83a9                	srli	a5,a5,0xa
    800000a2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r"(x));
    800000a6:	47bd                	li	a5,15
    800000a8:	3a079073          	csrw	pmpcfg0,a5
  asm volatile("csrr %0, 0x30a" : "=r"(x));
    800000ac:	30a027f3          	csrr	a5,0x30a
  w_menvcfg(r_menvcfg() | MENVCFG_ADUE);
    800000b0:	4705                	li	a4,1
    800000b2:	1776                	slli	a4,a4,0x3d
    800000b4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw 0x30a, %0" : : "r"(x));
    800000b6:	30a79073          	csrw	0x30a,a5
  timerinit();
    800000ba:	f63ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r"(x));
    800000be:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c2:	2781                	sext.w	a5,a5
}

static inline void
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r"(x));
    800000c4:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c6:	30200073          	mret
}
    800000ca:	60a2                	ld	ra,8(sp)
    800000cc:	6402                	ld	s0,0(sp)
    800000ce:	0141                	addi	sp,sp,16
    800000d0:	8082                	ret

00000000800000d2 <consolewrite>:
// user write() system calls to the console go here.
// uses sleep() and UART interrupts.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d2:	7119                	addi	sp,sp,-128
    800000d4:	fc86                	sd	ra,120(sp)
    800000d6:	f8a2                	sd	s0,112(sp)
    800000d8:	f4a6                	sd	s1,104(sp)
    800000da:	0100                	addi	s0,sp,128
  char buf[32]; // move batches from user space to uart.
  int i = 0;

  while (i < n) {
    800000dc:	06c05a63          	blez	a2,80000150 <consolewrite+0x7e>
    800000e0:	f0ca                	sd	s2,96(sp)
    800000e2:	ecce                	sd	s3,88(sp)
    800000e4:	e8d2                	sd	s4,80(sp)
    800000e6:	e4d6                	sd	s5,72(sp)
    800000e8:	e0da                	sd	s6,64(sp)
    800000ea:	fc5e                	sd	s7,56(sp)
    800000ec:	f862                	sd	s8,48(sp)
    800000ee:	f466                	sd	s9,40(sp)
    800000f0:	8aaa                	mv	s5,a0
    800000f2:	8b2e                	mv	s6,a1
    800000f4:	8a32                	mv	s4,a2
  int i = 0;
    800000f6:	4481                	li	s1,0
    int nn = sizeof(buf);
    if (nn > n - i)
    800000f8:	02000c13          	li	s8,32
    800000fc:	02000c93          	li	s9,32
      nn = n - i;
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000100:	5bfd                	li	s7,-1
    80000102:	a035                	j	8000012e <consolewrite+0x5c>
    if (nn > n - i)
    80000104:	0009099b          	sext.w	s3,s2
    if (either_copyin(buf, user_src, src + i, nn) == -1)
    80000108:	86ce                	mv	a3,s3
    8000010a:	01648633          	add	a2,s1,s6
    8000010e:	85d6                	mv	a1,s5
    80000110:	f8040513          	addi	a0,s0,-128
    80000114:	17c020ef          	jal	80002290 <either_copyin>
    80000118:	03750e63          	beq	a0,s7,80000154 <consolewrite+0x82>
      break;
    uartwrite(buf, nn);
    8000011c:	85ce                	mv	a1,s3
    8000011e:	f8040513          	addi	a0,s0,-128
    80000122:	786000ef          	jal	800008a8 <uartwrite>
    i += nn;
    80000126:	009904bb          	addw	s1,s2,s1
  while (i < n) {
    8000012a:	0144da63          	bge	s1,s4,8000013e <consolewrite+0x6c>
    if (nn > n - i)
    8000012e:	409a093b          	subw	s2,s4,s1
    80000132:	0009079b          	sext.w	a5,s2
    80000136:	fcfc57e3          	bge	s8,a5,80000104 <consolewrite+0x32>
    8000013a:	8966                	mv	s2,s9
    8000013c:	b7e1                	j	80000104 <consolewrite+0x32>
    8000013e:	7906                	ld	s2,96(sp)
    80000140:	69e6                	ld	s3,88(sp)
    80000142:	6a46                	ld	s4,80(sp)
    80000144:	6aa6                	ld	s5,72(sp)
    80000146:	6b06                	ld	s6,64(sp)
    80000148:	7be2                	ld	s7,56(sp)
    8000014a:	7c42                	ld	s8,48(sp)
    8000014c:	7ca2                	ld	s9,40(sp)
    8000014e:	a819                	j	80000164 <consolewrite+0x92>
  int i = 0;
    80000150:	4481                	li	s1,0
    80000152:	a809                	j	80000164 <consolewrite+0x92>
    80000154:	7906                	ld	s2,96(sp)
    80000156:	69e6                	ld	s3,88(sp)
    80000158:	6a46                	ld	s4,80(sp)
    8000015a:	6aa6                	ld	s5,72(sp)
    8000015c:	6b06                	ld	s6,64(sp)
    8000015e:	7be2                	ld	s7,56(sp)
    80000160:	7c42                	ld	s8,48(sp)
    80000162:	7ca2                	ld	s9,40(sp)
  }

  return i;
}
    80000164:	8526                	mv	a0,s1
    80000166:	70e6                	ld	ra,120(sp)
    80000168:	7446                	ld	s0,112(sp)
    8000016a:	74a6                	ld	s1,104(sp)
    8000016c:	6109                	addi	sp,sp,128
    8000016e:	8082                	ret

0000000080000170 <consoleread>:
// user_dst indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	711d                	addi	sp,sp,-96
    80000172:	ec86                	sd	ra,88(sp)
    80000174:	e8a2                	sd	s0,80(sp)
    80000176:	e4a6                	sd	s1,72(sp)
    80000178:	e0ca                	sd	s2,64(sp)
    8000017a:	fc4e                	sd	s3,56(sp)
    8000017c:	f852                	sd	s4,48(sp)
    8000017e:	f456                	sd	s5,40(sp)
    80000180:	f05a                	sd	s6,32(sp)
    80000182:	1080                	addi	s0,sp,96
    80000184:	8aaa                	mv	s5,a0
    80000186:	8a2e                	mv	s4,a1
    80000188:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000018a:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018e:	00011517          	auipc	a0,0x11
    80000192:	6c250513          	addi	a0,a0,1730 # 80011850 <cons>
    80000196:	1fb000ef          	jal	80000b90 <acquire>
  while (n > 0) {
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while (cons.r == cons.w) {
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	6b648493          	addi	s1,s1,1718 # 80011850 <cons>
      if (killed(myproc())) {
        release(&cons.lock);
        return -1;
      }
      sleep_prepare(&cons.r);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	74690913          	addi	s2,s2,1862 # 800118e8 <cons+0x98>
  while (n > 0) {
    800001aa:	0d305463          	blez	s3,80000272 <consoleread+0x102>
    while (cons.r == cons.w) {
    800001ae:	0984a783          	lw	a5,152(s1)
    800001b2:	09c4a703          	lw	a4,156(s1)
    800001b6:	0af71963          	bne	a4,a5,80000268 <consoleread+0xf8>
      if (killed(myproc())) {
    800001ba:	6e8010ef          	jal	800018a2 <myproc>
    800001be:	74d010ef          	jal	8000210a <killed>
    800001c2:	e925                	bnez	a0,80000232 <consoleread+0xc2>
      sleep_prepare(&cons.r);
    800001c4:	854a                	mv	a0,s2
    800001c6:	4f1010ef          	jal	80001eb6 <sleep_prepare>
      release(&cons.lock);
    800001ca:	8526                	mv	a0,s1
    800001cc:	251000ef          	jal	80000c1c <release>
      sleep();
    800001d0:	523010ef          	jal	80001ef2 <sleep>
      acquire(&cons.lock);
    800001d4:	8526                	mv	a0,s1
    800001d6:	1bb000ef          	jal	80000b90 <acquire>
    while (cons.r == cons.w) {
    800001da:	0984a783          	lw	a5,152(s1)
    800001de:	09c4a703          	lw	a4,156(s1)
    800001e2:	fcf70ce3          	beq	a4,a5,800001ba <consoleread+0x4a>
    800001e6:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001e8:	00011717          	auipc	a4,0x11
    800001ec:	66870713          	addi	a4,a4,1640 # 80011850 <cons>
    800001f0:	0017869b          	addiw	a3,a5,1
    800001f4:	08d72c23          	sw	a3,152(a4)
    800001f8:	07f7f693          	andi	a3,a5,127
    800001fc:	9736                	add	a4,a4,a3
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070b9b          	sext.w	s7,a4

    if (c == C('D')) { // end-of-file
    80000206:	4691                	li	a3,4
    80000208:	04db8663          	beq	s7,a3,80000254 <consoleread+0xe4>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    8000020c:	fae407a3          	sb	a4,-81(s0)
    if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000210:	4685                	li	a3,1
    80000212:	faf40613          	addi	a2,s0,-81
    80000216:	85d2                	mv	a1,s4
    80000218:	8556                	mv	a0,s5
    8000021a:	02a020ef          	jal	80002244 <either_copyout>
    8000021e:	57fd                	li	a5,-1
    80000220:	04f50863          	beq	a0,a5,80000270 <consoleread+0x100>
      break;

    dst++;
    80000224:	0a05                	addi	s4,s4,1
    --n;
    80000226:	39fd                	addiw	s3,s3,-1

    if (c == '\n') {
    80000228:	47a9                	li	a5,10
    8000022a:	04fb8d63          	beq	s7,a5,80000284 <consoleread+0x114>
    8000022e:	6be2                	ld	s7,24(sp)
    80000230:	bfad                	j	800001aa <consoleread+0x3a>
        release(&cons.lock);
    80000232:	00011517          	auipc	a0,0x11
    80000236:	61e50513          	addi	a0,a0,1566 # 80011850 <cons>
    8000023a:	1e3000ef          	jal	80000c1c <release>
        return -1;
    8000023e:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    80000240:	60e6                	ld	ra,88(sp)
    80000242:	6446                	ld	s0,80(sp)
    80000244:	64a6                	ld	s1,72(sp)
    80000246:	6906                	ld	s2,64(sp)
    80000248:	79e2                	ld	s3,56(sp)
    8000024a:	7a42                	ld	s4,48(sp)
    8000024c:	7aa2                	ld	s5,40(sp)
    8000024e:	7b02                	ld	s6,32(sp)
    80000250:	6125                	addi	sp,sp,96
    80000252:	8082                	ret
      if (n < target) {
    80000254:	0009871b          	sext.w	a4,s3
    80000258:	01677a63          	bgeu	a4,s6,8000026c <consoleread+0xfc>
        cons.r--;
    8000025c:	00011717          	auipc	a4,0x11
    80000260:	68f72623          	sw	a5,1676(a4) # 800118e8 <cons+0x98>
    80000264:	6be2                	ld	s7,24(sp)
    80000266:	a031                	j	80000272 <consoleread+0x102>
    80000268:	ec5e                	sd	s7,24(sp)
    8000026a:	bfbd                	j	800001e8 <consoleread+0x78>
    8000026c:	6be2                	ld	s7,24(sp)
    8000026e:	a011                	j	80000272 <consoleread+0x102>
    80000270:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    80000272:	00011517          	auipc	a0,0x11
    80000276:	5de50513          	addi	a0,a0,1502 # 80011850 <cons>
    8000027a:	1a3000ef          	jal	80000c1c <release>
  return target - n;
    8000027e:	413b053b          	subw	a0,s6,s3
    80000282:	bf7d                	j	80000240 <consoleread+0xd0>
    80000284:	6be2                	ld	s7,24(sp)
    80000286:	b7f5                	j	80000272 <consoleread+0x102>

0000000080000288 <consputc>:
{
    80000288:	1141                	addi	sp,sp,-16
    8000028a:	e406                	sd	ra,8(sp)
    8000028c:	e022                	sd	s0,0(sp)
    8000028e:	0800                	addi	s0,sp,16
  if (c == BACKSPACE) {
    80000290:	10000793          	li	a5,256
    80000294:	00f50863          	beq	a0,a5,800002a4 <consputc+0x1c>
    uartputc_sync(c);
    80000298:	696000ef          	jal	8000092e <uartputc_sync>
}
    8000029c:	60a2                	ld	ra,8(sp)
    8000029e:	6402                	ld	s0,0(sp)
    800002a0:	0141                	addi	sp,sp,16
    800002a2:	8082                	ret
    uartputc_sync('\b');
    800002a4:	4521                	li	a0,8
    800002a6:	688000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync(' ');
    800002aa:	02000513          	li	a0,32
    800002ae:	680000ef          	jal	8000092e <uartputc_sync>
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	67a000ef          	jal	8000092e <uartputc_sync>
    800002b8:	b7d5                	j	8000029c <consputc+0x14>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	1000                	addi	s0,sp,32
    800002c4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c6:	00011517          	auipc	a0,0x11
    800002ca:	58a50513          	addi	a0,a0,1418 # 80011850 <cons>
    800002ce:	0c3000ef          	jal	80000b90 <acquire>

  switch (c) {
    800002d2:	47d5                	li	a5,21
    800002d4:	08f48f63          	beq	s1,a5,80000372 <consoleintr+0xb8>
    800002d8:	0297c563          	blt	a5,s1,80000302 <consoleintr+0x48>
    800002dc:	47a1                	li	a5,8
    800002de:	0ef48463          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    800002e2:	47c1                	li	a5,16
    800002e4:	10f49563          	bne	s1,a5,800003ee <consoleintr+0x134>
  case C('P'): // Print process list.
    procdump();
    800002e8:	7f5010ef          	jal	800022dc <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002ec:	00011517          	auipc	a0,0x11
    800002f0:	56450513          	addi	a0,a0,1380 # 80011850 <cons>
    800002f4:	129000ef          	jal	80000c1c <release>
}
    800002f8:	60e2                	ld	ra,24(sp)
    800002fa:	6442                	ld	s0,16(sp)
    800002fc:	64a2                	ld	s1,8(sp)
    800002fe:	6105                	addi	sp,sp,32
    80000300:	8082                	ret
  switch (c) {
    80000302:	07f00793          	li	a5,127
    80000306:	0cf48063          	beq	s1,a5,800003c6 <consoleintr+0x10c>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    8000030a:	00011717          	auipc	a4,0x11
    8000030e:	54670713          	addi	a4,a4,1350 # 80011850 <cons>
    80000312:	0a072783          	lw	a5,160(a4)
    80000316:	09872703          	lw	a4,152(a4)
    8000031a:	9f99                	subw	a5,a5,a4
    8000031c:	07f00713          	li	a4,127
    80000320:	fcf766e3          	bltu	a4,a5,800002ec <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000324:	47b5                	li	a5,13
    80000326:	0cf48763          	beq	s1,a5,800003f4 <consoleintr+0x13a>
      consputc(c);
    8000032a:	8526                	mv	a0,s1
    8000032c:	f5dff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000330:	00011797          	auipc	a5,0x11
    80000334:	52078793          	addi	a5,a5,1312 # 80011850 <cons>
    80000338:	0a07a683          	lw	a3,160(a5)
    8000033c:	0016871b          	addiw	a4,a3,1
    80000340:	0007061b          	sext.w	a2,a4
    80000344:	0ae7a023          	sw	a4,160(a5)
    80000348:	07f6f693          	andi	a3,a3,127
    8000034c:	97b6                	add	a5,a5,a3
    8000034e:	00978c23          	sb	s1,24(a5)
      if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE) {
    80000352:	47a9                	li	a5,10
    80000354:	0cf48563          	beq	s1,a5,8000041e <consoleintr+0x164>
    80000358:	4791                	li	a5,4
    8000035a:	0cf48263          	beq	s1,a5,8000041e <consoleintr+0x164>
    8000035e:	00011797          	auipc	a5,0x11
    80000362:	58a7a783          	lw	a5,1418(a5) # 800118e8 <cons+0x98>
    80000366:	9f1d                	subw	a4,a4,a5
    80000368:	08000793          	li	a5,128
    8000036c:	f8f710e3          	bne	a4,a5,800002ec <consoleintr+0x32>
    80000370:	a07d                	j	8000041e <consoleintr+0x164>
    80000372:	e04a                	sd	s2,0(sp)
    while (cons.e != cons.w &&
    80000374:	00011717          	auipc	a4,0x11
    80000378:	4dc70713          	addi	a4,a4,1244 # 80011850 <cons>
    8000037c:	0a072783          	lw	a5,160(a4)
    80000380:	09c72703          	lw	a4,156(a4)
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000384:	00011497          	auipc	s1,0x11
    80000388:	4cc48493          	addi	s1,s1,1228 # 80011850 <cons>
    while (cons.e != cons.w &&
    8000038c:	4929                	li	s2,10
    8000038e:	02f70863          	beq	a4,a5,800003be <consoleintr+0x104>
           cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n') {
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	07f7f713          	andi	a4,a5,127
    80000398:	9726                	add	a4,a4,s1
    while (cons.e != cons.w &&
    8000039a:	01874703          	lbu	a4,24(a4)
    8000039e:	03270263          	beq	a4,s2,800003c2 <consoleintr+0x108>
      cons.e--;
    800003a2:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003a6:	10000513          	li	a0,256
    800003aa:	edfff0ef          	jal	80000288 <consputc>
    while (cons.e != cons.w &&
    800003ae:	0a04a783          	lw	a5,160(s1)
    800003b2:	09c4a703          	lw	a4,156(s1)
    800003b6:	fcf71ee3          	bne	a4,a5,80000392 <consoleintr+0xd8>
    800003ba:	6902                	ld	s2,0(sp)
    800003bc:	bf05                	j	800002ec <consoleintr+0x32>
    800003be:	6902                	ld	s2,0(sp)
    800003c0:	b735                	j	800002ec <consoleintr+0x32>
    800003c2:	6902                	ld	s2,0(sp)
    800003c4:	b725                	j	800002ec <consoleintr+0x32>
    if (cons.e != cons.w) {
    800003c6:	00011717          	auipc	a4,0x11
    800003ca:	48a70713          	addi	a4,a4,1162 # 80011850 <cons>
    800003ce:	0a072783          	lw	a5,160(a4)
    800003d2:	09c72703          	lw	a4,156(a4)
    800003d6:	f0f70be3          	beq	a4,a5,800002ec <consoleintr+0x32>
      cons.e--;
    800003da:	37fd                	addiw	a5,a5,-1
    800003dc:	00011717          	auipc	a4,0x11
    800003e0:	50f72a23          	sw	a5,1300(a4) # 800118f0 <cons+0xa0>
      consputc(BACKSPACE);
    800003e4:	10000513          	li	a0,256
    800003e8:	ea1ff0ef          	jal	80000288 <consputc>
    800003ec:	b701                	j	800002ec <consoleintr+0x32>
    if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE) {
    800003ee:	ee048fe3          	beqz	s1,800002ec <consoleintr+0x32>
    800003f2:	bf21                	j	8000030a <consoleintr+0x50>
      consputc(c);
    800003f4:	4529                	li	a0,10
    800003f6:	e93ff0ef          	jal	80000288 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003fa:	00011797          	auipc	a5,0x11
    800003fe:	45678793          	addi	a5,a5,1110 # 80011850 <cons>
    80000402:	0a07a703          	lw	a4,160(a5)
    80000406:	0017069b          	addiw	a3,a4,1
    8000040a:	0006861b          	sext.w	a2,a3
    8000040e:	0ad7a023          	sw	a3,160(a5)
    80000412:	07f77713          	andi	a4,a4,127
    80000416:	97ba                	add	a5,a5,a4
    80000418:	4729                	li	a4,10
    8000041a:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000041e:	00011797          	auipc	a5,0x11
    80000422:	4cc7a723          	sw	a2,1230(a5) # 800118ec <cons+0x9c>
        wakeup(&cons.r);
    80000426:	00011517          	auipc	a0,0x11
    8000042a:	4c250513          	addi	a0,a0,1218 # 800118e8 <cons+0x98>
    8000042e:	2f5010ef          	jal	80001f22 <wakeup>
    80000432:	bd6d                	j	800002ec <consoleintr+0x32>

0000000080000434 <consoleinit>:

void
consoleinit(void)
{
    80000434:	1141                	addi	sp,sp,-16
    80000436:	e406                	sd	ra,8(sp)
    80000438:	e022                	sd	s0,0(sp)
    8000043a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000043c:	00007597          	auipc	a1,0x7
    80000440:	bc458593          	addi	a1,a1,-1084 # 80007000 <etext>
    80000444:	00011517          	auipc	a0,0x11
    80000448:	40c50513          	addi	a0,a0,1036 # 80011850 <cons>
    8000044c:	6ce000ef          	jal	80000b1a <initlock>

  uartinit();
    80000450:	400000ef          	jal	80000850 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000454:	00021797          	auipc	a5,0x21
    80000458:	58478793          	addi	a5,a5,1412 # 800219d8 <devsw>
    8000045c:	00000717          	auipc	a4,0x0
    80000460:	d1470713          	addi	a4,a4,-748 # 80000170 <consoleread>
    80000464:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000466:	00000717          	auipc	a4,0x0
    8000046a:	c6c70713          	addi	a4,a4,-916 # 800000d2 <consolewrite>
    8000046e:	ef98                	sd	a4,24(a5)
}
    80000470:	60a2                	ld	ra,8(sp)
    80000472:	6402                	ld	s0,0(sp)
    80000474:	0141                	addi	sp,sp,16
    80000476:	8082                	ret

0000000080000478 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000478:	7139                	addi	sp,sp,-64
    8000047a:	fc06                	sd	ra,56(sp)
    8000047c:	f822                	sd	s0,48(sp)
    8000047e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if (sign && (sign = (xx < 0)))
    80000480:	c219                	beqz	a2,80000486 <printint+0xe>
    80000482:	08054063          	bltz	a0,80000502 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    80000486:	4881                	li	a7,0
    80000488:	fc840693          	addi	a3,s0,-56

  i = 0;
    8000048c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    8000048e:	00007617          	auipc	a2,0x7
    80000492:	2a260613          	addi	a2,a2,674 # 80007730 <digits>
    80000496:	883e                	mv	a6,a5
    80000498:	2785                	addiw	a5,a5,1
    8000049a:	02b57733          	remu	a4,a0,a1
    8000049e:	9732                	add	a4,a4,a2
    800004a0:	00074703          	lbu	a4,0(a4)
    800004a4:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
    800004a8:	872a                	mv	a4,a0
    800004aa:	02b55533          	divu	a0,a0,a1
    800004ae:	0685                	addi	a3,a3,1
    800004b0:	feb773e3          	bgeu	a4,a1,80000496 <printint+0x1e>

  if (sign)
    800004b4:	00088a63          	beqz	a7,800004c8 <printint+0x50>
    buf[i++] = '-';
    800004b8:	1781                	addi	a5,a5,-32
    800004ba:	97a2                	add	a5,a5,s0
    800004bc:	02d00713          	li	a4,45
    800004c0:	fee78423          	sb	a4,-24(a5)
    800004c4:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
    800004c8:	02f05963          	blez	a5,800004fa <printint+0x82>
    800004cc:	f426                	sd	s1,40(sp)
    800004ce:	f04a                	sd	s2,32(sp)
    800004d0:	fc840713          	addi	a4,s0,-56
    800004d4:	00f704b3          	add	s1,a4,a5
    800004d8:	fff70913          	addi	s2,a4,-1
    800004dc:	993e                	add	s2,s2,a5
    800004de:	37fd                	addiw	a5,a5,-1
    800004e0:	1782                	slli	a5,a5,0x20
    800004e2:	9381                	srli	a5,a5,0x20
    800004e4:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004e8:	fff4c503          	lbu	a0,-1(s1)
    800004ec:	d9dff0ef          	jal	80000288 <consputc>
  while (--i >= 0)
    800004f0:	14fd                	addi	s1,s1,-1
    800004f2:	ff249be3          	bne	s1,s2,800004e8 <printint+0x70>
    800004f6:	74a2                	ld	s1,40(sp)
    800004f8:	7902                	ld	s2,32(sp)
}
    800004fa:	70e2                	ld	ra,56(sp)
    800004fc:	7442                	ld	s0,48(sp)
    800004fe:	6121                	addi	sp,sp,64
    80000500:	8082                	ret
    x = -xx;
    80000502:	40a00533          	neg	a0,a0
  if (sign && (sign = (xx < 0)))
    80000506:	4885                	li	a7,1
    x = -xx;
    80000508:	b741                	j	80000488 <printint+0x10>

000000008000050a <printk>:
}

// Print to the console.
int
printk(char *fmt, ...)
{
    8000050a:	7131                	addi	sp,sp,-192
    8000050c:	fc86                	sd	ra,120(sp)
    8000050e:	f8a2                	sd	s0,112(sp)
    80000510:	e8d2                	sd	s4,80(sp)
    80000512:	0100                	addi	s0,sp,128
    80000514:	8a2a                	mv	s4,a0
    80000516:	e40c                	sd	a1,8(s0)
    80000518:	e810                	sd	a2,16(s0)
    8000051a:	ec14                	sd	a3,24(s0)
    8000051c:	f018                	sd	a4,32(s0)
    8000051e:	f41c                	sd	a5,40(s0)
    80000520:	03043823          	sd	a6,48(s0)
    80000524:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if (panicking == 0)
    80000528:	00009797          	auipc	a5,0x9
    8000052c:	2fc7a783          	lw	a5,764(a5) # 80009824 <panicking>
    80000530:	c3a1                	beqz	a5,80000570 <printk+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000532:	00840793          	addi	a5,s0,8
    80000536:	f8f43423          	sd	a5,-120(s0)
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    8000053a:	000a4503          	lbu	a0,0(s4)
    8000053e:	28050763          	beqz	a0,800007cc <printk+0x2c2>
    80000542:	f4a6                	sd	s1,104(sp)
    80000544:	f0ca                	sd	s2,96(sp)
    80000546:	ecce                	sd	s3,88(sp)
    80000548:	e4d6                	sd	s5,72(sp)
    8000054a:	e0da                	sd	s6,64(sp)
    8000054c:	f862                	sd	s8,48(sp)
    8000054e:	f466                	sd	s9,40(sp)
    80000550:	f06a                	sd	s10,32(sp)
    80000552:	ec6e                	sd	s11,24(sp)
    80000554:	4981                	li	s3,0
    if (cx != '%') {
    80000556:	02500a93          	li	s5,37
    c1 = c2 = 0;
    if (c0)
      c1 = fmt[i + 1] & 0xff;
    if (c1)
      c2 = fmt[i + 2] & 0xff;
    if (c0 == 'd') {
    8000055a:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if (c0 == 'l' && c1 == 'd') {
    8000055e:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if (c0 == 'u') {
    80000562:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if (c0 == 'x') {
    80000566:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if (c0 == 'p') {
    8000056a:	07000d93          	li	s11,112
    8000056e:	a01d                	j	80000594 <printk+0x8a>
    acquire(&pr.lock);
    80000570:	00011517          	auipc	a0,0x11
    80000574:	38850513          	addi	a0,a0,904 # 800118f8 <pr>
    80000578:	618000ef          	jal	80000b90 <acquire>
    8000057c:	bf5d                	j	80000532 <printk+0x28>
      consputc(cx);
    8000057e:	d0bff0ef          	jal	80000288 <consputc>
      continue;
    80000582:	84ce                	mv	s1,s3
  for (i = 0; (cx = fmt[i] & 0xff) != 0; i++) {
    80000584:	0014899b          	addiw	s3,s1,1
    80000588:	013a07b3          	add	a5,s4,s3
    8000058c:	0007c503          	lbu	a0,0(a5)
    80000590:	20050b63          	beqz	a0,800007a6 <printk+0x29c>
    if (cx != '%') {
    80000594:	ff5515e3          	bne	a0,s5,8000057e <printk+0x74>
    i++;
    80000598:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i + 0] & 0xff;
    8000059c:	009a07b3          	add	a5,s4,s1
    800005a0:	0007c903          	lbu	s2,0(a5)
    if (c0)
    800005a4:	20090b63          	beqz	s2,800007ba <printk+0x2b0>
      c1 = fmt[i + 1] & 0xff;
    800005a8:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800005ac:	86be                	mv	a3,a5
    if (c1)
    800005ae:	c789                	beqz	a5,800005b8 <printk+0xae>
      c2 = fmt[i + 2] & 0xff;
    800005b0:	009a0733          	add	a4,s4,s1
    800005b4:	00274683          	lbu	a3,2(a4)
    if (c0 == 'd') {
    800005b8:	03690963          	beq	s2,s6,800005ea <printk+0xe0>
    } else if (c0 == 'l' && c1 == 'd') {
    800005bc:	05890363          	beq	s2,s8,80000602 <printk+0xf8>
    } else if (c0 == 'u') {
    800005c0:	0d990663          	beq	s2,s9,8000068c <printk+0x182>
    } else if (c0 == 'x') {
    800005c4:	11a90d63          	beq	s2,s10,800006de <printk+0x1d4>
    } else if (c0 == 'p') {
    800005c8:	15b90663          	beq	s2,s11,80000714 <printk+0x20a>
      printptr(va_arg(ap, uint64));
    } else if (c0 == 'c') {
    800005cc:	06300793          	li	a5,99
    800005d0:	18f90563          	beq	s2,a5,8000075a <printk+0x250>
      consputc(va_arg(ap, uint));
    } else if (c0 == 's') {
    800005d4:	07300793          	li	a5,115
    800005d8:	18f90b63          	beq	s2,a5,8000076e <printk+0x264>
      if ((s = va_arg(ap, char *)) == 0)
        s = "(null)";
      for (; *s; s++)
        consputc(*s);
    } else if (c0 == '%') {
    800005dc:	03591b63          	bne	s2,s5,80000612 <printk+0x108>
      consputc('%');
    800005e0:	02500513          	li	a0,37
    800005e4:	ca5ff0ef          	jal	80000288 <consputc>
    800005e8:	bf71                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, int), 10, 1);
    800005ea:	f8843783          	ld	a5,-120(s0)
    800005ee:	00878713          	addi	a4,a5,8
    800005f2:	f8e43423          	sd	a4,-120(s0)
    800005f6:	4605                	li	a2,1
    800005f8:	45a9                	li	a1,10
    800005fa:	4388                	lw	a0,0(a5)
    800005fc:	e7dff0ef          	jal	80000478 <printint>
    80000600:	b751                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'd') {
    80000602:	01678f63          	beq	a5,s6,80000620 <printk+0x116>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    80000606:	03878b63          	beq	a5,s8,8000063c <printk+0x132>
    } else if (c0 == 'l' && c1 == 'u') {
    8000060a:	09978e63          	beq	a5,s9,800006a6 <printk+0x19c>
    } else if (c0 == 'l' && c1 == 'x') {
    8000060e:	0fa78563          	beq	a5,s10,800006f8 <printk+0x1ee>
    } else if (c0 == 0) {
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000612:	8556                	mv	a0,s5
    80000614:	c75ff0ef          	jal	80000288 <consputc>
      consputc(c0);
    80000618:	854a                	mv	a0,s2
    8000061a:	c6fff0ef          	jal	80000288 <consputc>
    8000061e:	b79d                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000620:	f8843783          	ld	a5,-120(s0)
    80000624:	00878713          	addi	a4,a5,8
    80000628:	f8e43423          	sd	a4,-120(s0)
    8000062c:	4605                	li	a2,1
    8000062e:	45a9                	li	a1,10
    80000630:	6388                	ld	a0,0(a5)
    80000632:	e47ff0ef          	jal	80000478 <printint>
      i += 1;
    80000636:	0029849b          	addiw	s1,s3,2
    8000063a:	b7a9                	j	80000584 <printk+0x7a>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
    8000063c:	06400793          	li	a5,100
    80000640:	02f68863          	beq	a3,a5,80000670 <printk+0x166>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
    80000644:	07500793          	li	a5,117
    80000648:	06f68d63          	beq	a3,a5,800006c2 <printk+0x1b8>
    } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
    8000064c:	07800793          	li	a5,120
    80000650:	fcf691e3          	bne	a3,a5,80000612 <printk+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000654:	f8843783          	ld	a5,-120(s0)
    80000658:	00878713          	addi	a4,a5,8
    8000065c:	f8e43423          	sd	a4,-120(s0)
    80000660:	4601                	li	a2,0
    80000662:	45c1                	li	a1,16
    80000664:	6388                	ld	a0,0(a5)
    80000666:	e13ff0ef          	jal	80000478 <printint>
      i += 2;
    8000066a:	0039849b          	addiw	s1,s3,3
    8000066e:	bf19                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000670:	f8843783          	ld	a5,-120(s0)
    80000674:	00878713          	addi	a4,a5,8
    80000678:	f8e43423          	sd	a4,-120(s0)
    8000067c:	4605                	li	a2,1
    8000067e:	45a9                	li	a1,10
    80000680:	6388                	ld	a0,0(a5)
    80000682:	df7ff0ef          	jal	80000478 <printint>
      i += 2;
    80000686:	0039849b          	addiw	s1,s3,3
    8000068a:	bded                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    8000068c:	f8843783          	ld	a5,-120(s0)
    80000690:	00878713          	addi	a4,a5,8
    80000694:	f8e43423          	sd	a4,-120(s0)
    80000698:	4601                	li	a2,0
    8000069a:	45a9                	li	a1,10
    8000069c:	0007e503          	lwu	a0,0(a5)
    800006a0:	dd9ff0ef          	jal	80000478 <printint>
    800006a4:	b5c5                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006a6:	f8843783          	ld	a5,-120(s0)
    800006aa:	00878713          	addi	a4,a5,8
    800006ae:	f8e43423          	sd	a4,-120(s0)
    800006b2:	4601                	li	a2,0
    800006b4:	45a9                	li	a1,10
    800006b6:	6388                	ld	a0,0(a5)
    800006b8:	dc1ff0ef          	jal	80000478 <printint>
      i += 1;
    800006bc:	0029849b          	addiw	s1,s3,2
    800006c0:	b5d1                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006c2:	f8843783          	ld	a5,-120(s0)
    800006c6:	00878713          	addi	a4,a5,8
    800006ca:	f8e43423          	sd	a4,-120(s0)
    800006ce:	4601                	li	a2,0
    800006d0:	45a9                	li	a1,10
    800006d2:	6388                	ld	a0,0(a5)
    800006d4:	da5ff0ef          	jal	80000478 <printint>
      i += 2;
    800006d8:	0039849b          	addiw	s1,s3,3
    800006dc:	b565                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	4601                	li	a2,0
    800006ec:	45c1                	li	a1,16
    800006ee:	0007e503          	lwu	a0,0(a5)
    800006f2:	d87ff0ef          	jal	80000478 <printint>
    800006f6:	b579                	j	80000584 <printk+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    800006f8:	f8843783          	ld	a5,-120(s0)
    800006fc:	00878713          	addi	a4,a5,8
    80000700:	f8e43423          	sd	a4,-120(s0)
    80000704:	4601                	li	a2,0
    80000706:	45c1                	li	a1,16
    80000708:	6388                	ld	a0,0(a5)
    8000070a:	d6fff0ef          	jal	80000478 <printint>
      i += 1;
    8000070e:	0029849b          	addiw	s1,s3,2
    80000712:	bd8d                	j	80000584 <printk+0x7a>
    80000714:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000716:	f8843783          	ld	a5,-120(s0)
    8000071a:	00878713          	addi	a4,a5,8
    8000071e:	f8e43423          	sd	a4,-120(s0)
    80000722:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000726:	03000513          	li	a0,48
    8000072a:	b5fff0ef          	jal	80000288 <consputc>
  consputc('x');
    8000072e:	07800513          	li	a0,120
    80000732:	b57ff0ef          	jal	80000288 <consputc>
    80000736:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000738:	00007b97          	auipc	s7,0x7
    8000073c:	ff8b8b93          	addi	s7,s7,-8 # 80007730 <digits>
    80000740:	03c9d793          	srli	a5,s3,0x3c
    80000744:	97de                	add	a5,a5,s7
    80000746:	0007c503          	lbu	a0,0(a5)
    8000074a:	b3fff0ef          	jal	80000288 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000074e:	0992                	slli	s3,s3,0x4
    80000750:	397d                	addiw	s2,s2,-1
    80000752:	fe0917e3          	bnez	s2,80000740 <printk+0x236>
    80000756:	7be2                	ld	s7,56(sp)
    80000758:	b535                	j	80000584 <printk+0x7a>
      consputc(va_arg(ap, uint));
    8000075a:	f8843783          	ld	a5,-120(s0)
    8000075e:	00878713          	addi	a4,a5,8
    80000762:	f8e43423          	sd	a4,-120(s0)
    80000766:	4388                	lw	a0,0(a5)
    80000768:	b21ff0ef          	jal	80000288 <consputc>
    8000076c:	bd21                	j	80000584 <printk+0x7a>
      if ((s = va_arg(ap, char *)) == 0)
    8000076e:	f8843783          	ld	a5,-120(s0)
    80000772:	00878713          	addi	a4,a5,8
    80000776:	f8e43423          	sd	a4,-120(s0)
    8000077a:	0007b903          	ld	s2,0(a5)
    8000077e:	00090d63          	beqz	s2,80000798 <printk+0x28e>
      for (; *s; s++)
    80000782:	00094503          	lbu	a0,0(s2)
    80000786:	de050fe3          	beqz	a0,80000584 <printk+0x7a>
        consputc(*s);
    8000078a:	affff0ef          	jal	80000288 <consputc>
      for (; *s; s++)
    8000078e:	0905                	addi	s2,s2,1
    80000790:	00094503          	lbu	a0,0(s2)
    80000794:	f97d                	bnez	a0,8000078a <printk+0x280>
    80000796:	b3fd                	j	80000584 <printk+0x7a>
        s = "(null)";
    80000798:	00007917          	auipc	s2,0x7
    8000079c:	87090913          	addi	s2,s2,-1936 # 80007008 <etext+0x8>
      for (; *s; s++)
    800007a0:	02800513          	li	a0,40
    800007a4:	b7dd                	j	8000078a <printk+0x280>
    800007a6:	74a6                	ld	s1,104(sp)
    800007a8:	7906                	ld	s2,96(sp)
    800007aa:	69e6                	ld	s3,88(sp)
    800007ac:	6aa6                	ld	s5,72(sp)
    800007ae:	6b06                	ld	s6,64(sp)
    800007b0:	7c42                	ld	s8,48(sp)
    800007b2:	7ca2                	ld	s9,40(sp)
    800007b4:	7d02                	ld	s10,32(sp)
    800007b6:	6de2                	ld	s11,24(sp)
    800007b8:	a811                	j	800007cc <printk+0x2c2>
    800007ba:	74a6                	ld	s1,104(sp)
    800007bc:	7906                	ld	s2,96(sp)
    800007be:	69e6                	ld	s3,88(sp)
    800007c0:	6aa6                	ld	s5,72(sp)
    800007c2:	6b06                	ld	s6,64(sp)
    800007c4:	7c42                	ld	s8,48(sp)
    800007c6:	7ca2                	ld	s9,40(sp)
    800007c8:	7d02                	ld	s10,32(sp)
    800007ca:	6de2                	ld	s11,24(sp)
    }
  }
  va_end(ap);

  if (panicking == 0)
    800007cc:	00009797          	auipc	a5,0x9
    800007d0:	0587a783          	lw	a5,88(a5) # 80009824 <panicking>
    800007d4:	c799                	beqz	a5,800007e2 <printk+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007d6:	4501                	li	a0,0
    800007d8:	70e6                	ld	ra,120(sp)
    800007da:	7446                	ld	s0,112(sp)
    800007dc:	6a46                	ld	s4,80(sp)
    800007de:	6129                	addi	sp,sp,192
    800007e0:	8082                	ret
    release(&pr.lock);
    800007e2:	00011517          	auipc	a0,0x11
    800007e6:	11650513          	addi	a0,a0,278 # 800118f8 <pr>
    800007ea:	432000ef          	jal	80000c1c <release>
  return 0;
    800007ee:	b7e5                	j	800007d6 <printk+0x2cc>

00000000800007f0 <panic>:

void
panic(char *s)
{
    800007f0:	1101                	addi	sp,sp,-32
    800007f2:	ec06                	sd	ra,24(sp)
    800007f4:	e822                	sd	s0,16(sp)
    800007f6:	e426                	sd	s1,8(sp)
    800007f8:	e04a                	sd	s2,0(sp)
    800007fa:	1000                	addi	s0,sp,32
    800007fc:	84aa                	mv	s1,a0
  panicking = 1;
    800007fe:	4905                	li	s2,1
    80000800:	00009797          	auipc	a5,0x9
    80000804:	0327a223          	sw	s2,36(a5) # 80009824 <panicking>
  printk("panic: ");
    80000808:	00007517          	auipc	a0,0x7
    8000080c:	81050513          	addi	a0,a0,-2032 # 80007018 <etext+0x18>
    80000810:	cfbff0ef          	jal	8000050a <printk>
  printk("%s\n", s);
    80000814:	85a6                	mv	a1,s1
    80000816:	00007517          	auipc	a0,0x7
    8000081a:	80a50513          	addi	a0,a0,-2038 # 80007020 <etext+0x20>
    8000081e:	cedff0ef          	jal	8000050a <printk>
  panicked = 1; // freeze uart output from other CPUs
    80000822:	00009797          	auipc	a5,0x9
    80000826:	ff27af23          	sw	s2,-2(a5) # 80009820 <panicked>
  for (;;)
    8000082a:	a001                	j	8000082a <panic+0x3a>

000000008000082c <printkinit>:
    ;
}

void
printkinit(void)
{
    8000082c:	1141                	addi	sp,sp,-16
    8000082e:	e406                	sd	ra,8(sp)
    80000830:	e022                	sd	s0,0(sp)
    80000832:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000834:	00006597          	auipc	a1,0x6
    80000838:	7f458593          	addi	a1,a1,2036 # 80007028 <etext+0x28>
    8000083c:	00011517          	auipc	a0,0x11
    80000840:	0bc50513          	addi	a0,a0,188 # 800118f8 <pr>
    80000844:	2d6000ef          	jal	80000b1a <initlock>
}
    80000848:	60a2                	ld	ra,8(sp)
    8000084a:	6402                	ld	s0,0(sp)
    8000084c:	0141                	addi	sp,sp,16
    8000084e:	8082                	ret

0000000080000850 <uartinit>:
extern volatile int panicking; // from printk.c
extern volatile int panicked;  // from printk.c

void
uartinit(void)
{
    80000850:	1141                	addi	sp,sp,-16
    80000852:	e406                	sd	ra,8(sp)
    80000854:	e022                	sd	s0,0(sp)
    80000856:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000858:	100007b7          	lui	a5,0x10000
    8000085c:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000860:	10000737          	lui	a4,0x10000
    80000864:	f8000693          	li	a3,-128
    80000868:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000086c:	468d                	li	a3,3
    8000086e:	10000637          	lui	a2,0x10000
    80000872:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000876:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000087a:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000087e:	10000737          	lui	a4,0x10000
    80000882:	461d                	li	a2,7
    80000884:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000888:	00d780a3          	sb	a3,1(a5)

  initsleeplock(&tx_lock, "uart");
    8000088c:	00006597          	auipc	a1,0x6
    80000890:	7a458593          	addi	a1,a1,1956 # 80007030 <etext+0x30>
    80000894:	00011517          	auipc	a0,0x11
    80000898:	07c50513          	addi	a0,a0,124 # 80011910 <tx_lock>
    8000089c:	680030ef          	jal	80003f1c <initsleeplock>
}
    800008a0:	60a2                	ld	ra,8(sp)
    800008a2:	6402                	ld	s0,0(sp)
    800008a4:	0141                	addi	sp,sp,16
    800008a6:	8082                	ret

00000000800008a8 <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008a8:	7139                	addi	sp,sp,-64
    800008aa:	fc06                	sd	ra,56(sp)
    800008ac:	f822                	sd	s0,48(sp)
    800008ae:	f04a                	sd	s2,32(sp)
    800008b0:	e456                	sd	s5,8(sp)
    800008b2:	0080                	addi	s0,sp,64
    800008b4:	8aaa                	mv	s5,a0
    800008b6:	892e                	mv	s2,a1
  acquiresleep(&tx_lock);
    800008b8:	00011517          	auipc	a0,0x11
    800008bc:	05850513          	addi	a0,a0,88 # 80011910 <tx_lock>
    800008c0:	692030ef          	jal	80003f52 <acquiresleep>

  int i = 0;
  while (i < n) {
    800008c4:	05205963          	blez	s2,80000916 <uartwrite+0x6e>
    800008c8:	f426                	sd	s1,40(sp)
    800008ca:	ec4e                	sd	s3,24(sp)
    800008cc:	e852                	sd	s4,16(sp)
    800008ce:	e05a                	sd	s6,0(sp)
  int i = 0;
    800008d0:	4481                	li	s1,0
    sleep_prepare(&tx_chan);
    800008d2:	00009a17          	auipc	s4,0x9
    800008d6:	f56a0a13          	addi	s4,s4,-170 # 80009828 <tx_chan>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008da:	100009b7          	lui	s3,0x10000
    800008de:	0995                	addi	s3,s3,5 # 10000005 <_entry-0x6ffffffb>
      WriteReg(THR, buf[i]);
    800008e0:	10000b37          	lui	s6,0x10000
    800008e4:	a811                	j	800008f8 <uartwrite+0x50>
    800008e6:	009a87b3          	add	a5,s5,s1
    800008ea:	0007c783          	lbu	a5,0(a5)
    800008ee:	00fb0023          	sb	a5,0(s6) # 10000000 <_entry-0x70000000>
      i += 1;
    800008f2:	2485                	addiw	s1,s1,1
  while (i < n) {
    800008f4:	0124dd63          	bge	s1,s2,8000090e <uartwrite+0x66>
    sleep_prepare(&tx_chan);
    800008f8:	8552                	mv	a0,s4
    800008fa:	5bc010ef          	jal	80001eb6 <sleep_prepare>
    if (ReadReg(LSR) & LSR_TX_IDLE) {
    800008fe:	0009c783          	lbu	a5,0(s3)
    80000902:	0207f793          	andi	a5,a5,32
    80000906:	f3e5                	bnez	a5,800008e6 <uartwrite+0x3e>
    } else {
      sleep();
    80000908:	5ea010ef          	jal	80001ef2 <sleep>
    8000090c:	b7e5                	j	800008f4 <uartwrite+0x4c>
    8000090e:	74a2                	ld	s1,40(sp)
    80000910:	69e2                	ld	s3,24(sp)
    80000912:	6a42                	ld	s4,16(sp)
    80000914:	6b02                	ld	s6,0(sp)
    }
  }

  releasesleep(&tx_lock);
    80000916:	00011517          	auipc	a0,0x11
    8000091a:	ffa50513          	addi	a0,a0,-6 # 80011910 <tx_lock>
    8000091e:	688030ef          	jal	80003fa6 <releasesleep>
}
    80000922:	70e2                	ld	ra,56(sp)
    80000924:	7442                	ld	s0,48(sp)
    80000926:	7902                	ld	s2,32(sp)
    80000928:	6aa2                	ld	s5,8(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret

000000008000092e <uartputc_sync>:
// interrupts, for use by kernel printk() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000092e:	1101                	addi	sp,sp,-32
    80000930:	ec06                	sd	ra,24(sp)
    80000932:	e822                	sd	s0,16(sp)
    80000934:	e426                	sd	s1,8(sp)
    80000936:	1000                	addi	s0,sp,32
    80000938:	84aa                	mv	s1,a0
  if (panicking == 0)
    8000093a:	00009797          	auipc	a5,0x9
    8000093e:	eea7a783          	lw	a5,-278(a5) # 80009824 <panicking>
    80000942:	cf95                	beqz	a5,8000097e <uartputc_sync+0x50>
    push_off();

  if (panicked) {
    80000944:	00009797          	auipc	a5,0x9
    80000948:	edc7a783          	lw	a5,-292(a5) # 80009820 <panicked>
    8000094c:	ef85                	bnez	a5,80000984 <uartputc_sync+0x56>
    for (;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while ((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000094e:	10000737          	lui	a4,0x10000
    80000952:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000954:	00074783          	lbu	a5,0(a4)
    80000958:	0207f793          	andi	a5,a5,32
    8000095c:	dfe5                	beqz	a5,80000954 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000095e:	0ff4f513          	zext.b	a0,s1
    80000962:	100007b7          	lui	a5,0x10000
    80000966:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if (panicking == 0)
    8000096a:	00009797          	auipc	a5,0x9
    8000096e:	eba7a783          	lw	a5,-326(a5) # 80009824 <panicking>
    80000972:	cb91                	beqz	a5,80000986 <uartputc_sync+0x58>
    pop_off();
}
    80000974:	60e2                	ld	ra,24(sp)
    80000976:	6442                	ld	s0,16(sp)
    80000978:	64a2                	ld	s1,8(sp)
    8000097a:	6105                	addi	sp,sp,32
    8000097c:	8082                	ret
    push_off();
    8000097e:	1dc000ef          	jal	80000b5a <push_off>
    80000982:	b7c9                	j	80000944 <uartputc_sync+0x16>
    for (;;)
    80000984:	a001                	j	80000984 <uartputc_sync+0x56>
    pop_off();
    80000986:	24a000ef          	jal	80000bd0 <pop_off>
}
    8000098a:	b7ed                	j	80000974 <uartputc_sync+0x46>

000000008000098c <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    8000098c:	1101                	addi	sp,sp,-32
    8000098e:	ec06                	sd	ra,24(sp)
    80000990:	e822                	sd	s0,16(sp)
    80000992:	e426                	sd	s1,8(sp)
    80000994:	e04a                	sd	s2,0(sp)
    80000996:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    8000099e:	0007c783          	lbu	a5,0(a5)

  if (ReadReg(LSR) & LSR_TX_IDLE) {
    800009a2:	100007b7          	lui	a5,0x10000
    800009a6:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009a8:	0007c783          	lbu	a5,0(a5)
    800009ac:	0207f793          	andi	a5,a5,32
    800009b0:	ef99                	bnez	a5,800009ce <uartintr+0x42>
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009b2:	100004b7          	lui	s1,0x10000
    800009b6:	0495                	addi	s1,s1,5 # 10000005 <_entry-0x6ffffffb>
    return ReadReg(RHR);
    800009b8:	10000937          	lui	s2,0x10000
  if (ReadReg(LSR) & LSR_RX_READY) {
    800009bc:	0004c783          	lbu	a5,0(s1)
    800009c0:	8b85                	andi	a5,a5,1
    800009c2:	cf89                	beqz	a5,800009dc <uartintr+0x50>
    return ReadReg(RHR);
    800009c4:	00094503          	lbu	a0,0(s2) # 10000000 <_entry-0x70000000>
  // read and process incoming characters, if any.
  while (1) {
    int c = uartgetc();
    if (c == -1)
      break;
    consoleintr(c);
    800009c8:	8f3ff0ef          	jal	800002ba <consoleintr>
  while (1) {
    800009cc:	bfc5                	j	800009bc <uartintr+0x30>
    wakeup(&tx_chan);
    800009ce:	00009517          	auipc	a0,0x9
    800009d2:	e5a50513          	addi	a0,a0,-422 # 80009828 <tx_chan>
    800009d6:	54c010ef          	jal	80001f22 <wakeup>
    800009da:	bfe1                	j	800009b2 <uartintr+0x26>
  }
}
    800009dc:	60e2                	ld	ra,24(sp)
    800009de:	6442                	ld	s0,16(sp)
    800009e0:	64a2                	ld	s1,8(sp)
    800009e2:	6902                	ld	s2,0(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	e7a9                	bnez	a5,80000a42 <kfree+0x5a>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00022797          	auipc	a5,0x22
    80000a00:	17478793          	addi	a5,a5,372 # 80022b70 <end>
    80000a04:	02f56f63          	bltu	a0,a5,80000a42 <kfree+0x5a>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	02f57b63          	bgeu	a0,a5,80000a42 <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	240000ef          	jal	80000c54 <memset>

  r = (struct run *)pa;

  acquire(&kmem.lock);
    80000a18:	00011917          	auipc	s2,0x11
    80000a1c:	f2890913          	addi	s2,s2,-216 # 80011940 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	16e000ef          	jal	80000b90 <acquire>
  r->next = kmem.freelist;
    80000a26:	01893783          	ld	a5,24(s2)
    80000a2a:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a2c:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a30:	854a                	mv	a0,s2
    80000a32:	1ea000ef          	jal	80000c1c <release>
}
    80000a36:	60e2                	ld	ra,24(sp)
    80000a38:	6442                	ld	s0,16(sp)
    80000a3a:	64a2                	ld	s1,8(sp)
    80000a3c:	6902                	ld	s2,0(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret
    panic("kfree");
    80000a42:	00006517          	auipc	a0,0x6
    80000a46:	5f650513          	addi	a0,a0,1526 # 80007038 <etext+0x38>
    80000a4a:	da7ff0ef          	jal	800007f0 <panic>

0000000080000a4e <freerange>:
{
    80000a4e:	7179                	addi	sp,sp,-48
    80000a50:	f406                	sd	ra,40(sp)
    80000a52:	f022                	sd	s0,32(sp)
    80000a54:	ec26                	sd	s1,24(sp)
    80000a56:	1800                	addi	s0,sp,48
  p = (char *)PGROUNDUP((uint64)pa_start);
    80000a58:	6785                	lui	a5,0x1
    80000a5a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a5e:	00e504b3          	add	s1,a0,a4
    80000a62:	777d                	lui	a4,0xfffff
    80000a64:	8cf9                	and	s1,s1,a4
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a66:	94be                	add	s1,s1,a5
    80000a68:	0295e263          	bltu	a1,s1,80000a8c <freerange+0x3e>
    80000a6c:	e84a                	sd	s2,16(sp)
    80000a6e:	e44e                	sd	s3,8(sp)
    80000a70:	e052                	sd	s4,0(sp)
    80000a72:	892e                	mv	s2,a1
    kfree(p);
    80000a74:	7a7d                	lui	s4,0xfffff
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a76:	6985                	lui	s3,0x1
    kfree(p);
    80000a78:	01448533          	add	a0,s1,s4
    80000a7c:	f6dff0ef          	jal	800009e8 <kfree>
  for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000a80:	94ce                	add	s1,s1,s3
    80000a82:	fe997be3          	bgeu	s2,s1,80000a78 <freerange+0x2a>
    80000a86:	6942                	ld	s2,16(sp)
    80000a88:	69a2                	ld	s3,8(sp)
    80000a8a:	6a02                	ld	s4,0(sp)
}
    80000a8c:	70a2                	ld	ra,40(sp)
    80000a8e:	7402                	ld	s0,32(sp)
    80000a90:	64e2                	ld	s1,24(sp)
    80000a92:	6145                	addi	sp,sp,48
    80000a94:	8082                	ret

0000000080000a96 <kinit>:
{
    80000a96:	1141                	addi	sp,sp,-16
    80000a98:	e406                	sd	ra,8(sp)
    80000a9a:	e022                	sd	s0,0(sp)
    80000a9c:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000a9e:	00006597          	auipc	a1,0x6
    80000aa2:	5a258593          	addi	a1,a1,1442 # 80007040 <etext+0x40>
    80000aa6:	00011517          	auipc	a0,0x11
    80000aaa:	e9a50513          	addi	a0,a0,-358 # 80011940 <kmem>
    80000aae:	06c000ef          	jal	80000b1a <initlock>
  freerange(end, (void *)PHYSTOP);
    80000ab2:	45c5                	li	a1,17
    80000ab4:	05ee                	slli	a1,a1,0x1b
    80000ab6:	00022517          	auipc	a0,0x22
    80000aba:	0ba50513          	addi	a0,a0,186 # 80022b70 <end>
    80000abe:	f91ff0ef          	jal	80000a4e <freerange>
}
    80000ac2:	60a2                	ld	ra,8(sp)
    80000ac4:	6402                	ld	s0,0(sp)
    80000ac6:	0141                	addi	sp,sp,16
    80000ac8:	8082                	ret

0000000080000aca <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000aca:	1101                	addi	sp,sp,-32
    80000acc:	ec06                	sd	ra,24(sp)
    80000ace:	e822                	sd	s0,16(sp)
    80000ad0:	e426                	sd	s1,8(sp)
    80000ad2:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000ad4:	00011497          	auipc	s1,0x11
    80000ad8:	e6c48493          	addi	s1,s1,-404 # 80011940 <kmem>
    80000adc:	8526                	mv	a0,s1
    80000ade:	0b2000ef          	jal	80000b90 <acquire>
  r = kmem.freelist;
    80000ae2:	6c84                	ld	s1,24(s1)
  if (r)
    80000ae4:	c485                	beqz	s1,80000b0c <kalloc+0x42>
    kmem.freelist = r->next;
    80000ae6:	609c                	ld	a5,0(s1)
    80000ae8:	00011517          	auipc	a0,0x11
    80000aec:	e5850513          	addi	a0,a0,-424 # 80011940 <kmem>
    80000af0:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000af2:	12a000ef          	jal	80000c1c <release>

  if (r)
    memset((char *)r, 5, PGSIZE); // fill with junk
    80000af6:	6605                	lui	a2,0x1
    80000af8:	4595                	li	a1,5
    80000afa:	8526                	mv	a0,s1
    80000afc:	158000ef          	jal	80000c54 <memset>
  return (void *)r;
}
    80000b00:	8526                	mv	a0,s1
    80000b02:	60e2                	ld	ra,24(sp)
    80000b04:	6442                	ld	s0,16(sp)
    80000b06:	64a2                	ld	s1,8(sp)
    80000b08:	6105                	addi	sp,sp,32
    80000b0a:	8082                	ret
  release(&kmem.lock);
    80000b0c:	00011517          	auipc	a0,0x11
    80000b10:	e3450513          	addi	a0,a0,-460 # 80011940 <kmem>
    80000b14:	108000ef          	jal	80000c1c <release>
  if (r)
    80000b18:	b7e5                	j	80000b00 <kalloc+0x36>

0000000080000b1a <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b1a:	1141                	addi	sp,sp,-16
    80000b1c:	e422                	sd	s0,8(sp)
    80000b1e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b20:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b22:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b26:	00053823          	sd	zero,16(a0)
}
    80000b2a:	6422                	ld	s0,8(sp)
    80000b2c:	0141                	addi	sp,sp,16
    80000b2e:	8082                	ret

0000000080000b30 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b30:	411c                	lw	a5,0(a0)
    80000b32:	e399                	bnez	a5,80000b38 <holding+0x8>
    80000b34:	4501                	li	a0,0
  return r;
}
    80000b36:	8082                	ret
{
    80000b38:	1101                	addi	sp,sp,-32
    80000b3a:	ec06                	sd	ra,24(sp)
    80000b3c:	e822                	sd	s0,16(sp)
    80000b3e:	e426                	sd	s1,8(sp)
    80000b40:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b42:	6904                	ld	s1,16(a0)
    80000b44:	543000ef          	jal	80001886 <mycpu>
    80000b48:	40a48533          	sub	a0,s1,a0
    80000b4c:	00153513          	seqz	a0,a0
}
    80000b50:	60e2                	ld	ra,24(sp)
    80000b52:	6442                	ld	s0,16(sp)
    80000b54:	64a2                	ld	s1,8(sp)
    80000b56:	6105                	addi	sp,sp,32
    80000b58:	8082                	ret

0000000080000b5a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b5a:	1101                	addi	sp,sp,-32
    80000b5c:	ec06                	sd	ra,24(sp)
    80000b5e:	e822                	sd	s0,16(sp)
    80000b60:	e426                	sd	s1,8(sp)
    80000b62:	1000                	addi	s0,sp,32
  __asm__ __volatile__("csrrc %0, sstatus, %1" : "=r"(x) : "rK"(x) : "memory");
    80000b64:	100174f3          	csrrci	s1,sstatus,2
  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  uint64 flags = rc_sstatus(SSTATUS_SIE);
  int old = !!(flags & SSTATUS_SIE);

  if (mycpu()->noff == 0)
    80000b68:	51f000ef          	jal	80001886 <mycpu>
    80000b6c:	5d3c                	lw	a5,120(a0)
    80000b6e:	cb99                	beqz	a5,80000b84 <push_off+0x2a>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000b70:	517000ef          	jal	80001886 <mycpu>
    80000b74:	5d3c                	lw	a5,120(a0)
    80000b76:	2785                	addiw	a5,a5,1
    80000b78:	dd3c                	sw	a5,120(a0)
}
    80000b7a:	60e2                	ld	ra,24(sp)
    80000b7c:	6442                	ld	s0,16(sp)
    80000b7e:	64a2                	ld	s1,8(sp)
    80000b80:	6105                	addi	sp,sp,32
    80000b82:	8082                	ret
    mycpu()->intena = old;
    80000b84:	503000ef          	jal	80001886 <mycpu>
  int old = !!(flags & SSTATUS_SIE);
    80000b88:	8085                	srli	s1,s1,0x1
    80000b8a:	8885                	andi	s1,s1,1
    mycpu()->intena = old;
    80000b8c:	dd64                	sw	s1,124(a0)
    80000b8e:	b7cd                	j	80000b70 <push_off+0x16>

0000000080000b90 <acquire>:
{
    80000b90:	1101                	addi	sp,sp,-32
    80000b92:	ec06                	sd	ra,24(sp)
    80000b94:	e822                	sd	s0,16(sp)
    80000b96:	e426                	sd	s1,8(sp)
    80000b98:	1000                	addi	s0,sp,32
    80000b9a:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000b9c:	fbfff0ef          	jal	80000b5a <push_off>
  if (holding(lk))
    80000ba0:	8526                	mv	a0,s1
    80000ba2:	f8fff0ef          	jal	80000b30 <holding>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000ba6:	4705                	li	a4,1
  if (holding(lk))
    80000ba8:	ed11                	bnez	a0,80000bc4 <acquire+0x34>
  while (__atomic_exchange_n(&lk->locked, 1, __ATOMIC_ACQUIRE) != 0)
    80000baa:	87ba                	mv	a5,a4
    80000bac:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bb0:	2781                	sext.w	a5,a5
    80000bb2:	ffe5                	bnez	a5,80000baa <acquire+0x1a>
  lk->cpu = mycpu();
    80000bb4:	4d3000ef          	jal	80001886 <mycpu>
    80000bb8:	e888                	sd	a0,16(s1)
}
    80000bba:	60e2                	ld	ra,24(sp)
    80000bbc:	6442                	ld	s0,16(sp)
    80000bbe:	64a2                	ld	s1,8(sp)
    80000bc0:	6105                	addi	sp,sp,32
    80000bc2:	8082                	ret
    panic("acquire");
    80000bc4:	00006517          	auipc	a0,0x6
    80000bc8:	48450513          	addi	a0,a0,1156 # 80007048 <etext+0x48>
    80000bcc:	c25ff0ef          	jal	800007f0 <panic>

0000000080000bd0 <pop_off>:

void
pop_off(void)
{
    80000bd0:	1141                	addi	sp,sp,-16
    80000bd2:	e406                	sd	ra,8(sp)
    80000bd4:	e022                	sd	s0,0(sp)
    80000bd6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000bd8:	4af000ef          	jal	80001886 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80000bdc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000be0:	8b89                	andi	a5,a5,2
  if (intr_get())
    80000be2:	e38d                	bnez	a5,80000c04 <pop_off+0x34>
    panic("pop_off - interruptible");
  if (c->noff < 1)
    80000be4:	5d3c                	lw	a5,120(a0)
    80000be6:	02f05563          	blez	a5,80000c10 <pop_off+0x40>
    panic("pop_off");
  c->noff -= 1;
    80000bea:	37fd                	addiw	a5,a5,-1
    80000bec:	0007871b          	sext.w	a4,a5
    80000bf0:	dd3c                	sw	a5,120(a0)
  if (c->noff == 0 && c->intena)
    80000bf2:	e709                	bnez	a4,80000bfc <pop_off+0x2c>
    80000bf4:	5d7c                	lw	a5,124(a0)
    80000bf6:	c399                	beqz	a5,80000bfc <pop_off+0x2c>
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80000bf8:	10016073          	csrsi	sstatus,2
    intr_on();
}
    80000bfc:	60a2                	ld	ra,8(sp)
    80000bfe:	6402                	ld	s0,0(sp)
    80000c00:	0141                	addi	sp,sp,16
    80000c02:	8082                	ret
    panic("pop_off - interruptible");
    80000c04:	00006517          	auipc	a0,0x6
    80000c08:	44c50513          	addi	a0,a0,1100 # 80007050 <etext+0x50>
    80000c0c:	be5ff0ef          	jal	800007f0 <panic>
    panic("pop_off");
    80000c10:	00006517          	auipc	a0,0x6
    80000c14:	45850513          	addi	a0,a0,1112 # 80007068 <etext+0x68>
    80000c18:	bd9ff0ef          	jal	800007f0 <panic>

0000000080000c1c <release>:
{
    80000c1c:	1101                	addi	sp,sp,-32
    80000c1e:	ec06                	sd	ra,24(sp)
    80000c20:	e822                	sd	s0,16(sp)
    80000c22:	e426                	sd	s1,8(sp)
    80000c24:	1000                	addi	s0,sp,32
    80000c26:	84aa                	mv	s1,a0
  if (!holding(lk))
    80000c28:	f09ff0ef          	jal	80000b30 <holding>
    80000c2c:	cd11                	beqz	a0,80000c48 <release+0x2c>
  lk->cpu = 0;
    80000c2e:	0004b823          	sd	zero,16(s1)
  __atomic_store_n(&lk->locked, 0, __ATOMIC_RELEASE);
    80000c32:	0310000f          	fence	rw,w
    80000c36:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000c3a:	f97ff0ef          	jal	80000bd0 <pop_off>
}
    80000c3e:	60e2                	ld	ra,24(sp)
    80000c40:	6442                	ld	s0,16(sp)
    80000c42:	64a2                	ld	s1,8(sp)
    80000c44:	6105                	addi	sp,sp,32
    80000c46:	8082                	ret
    panic("release");
    80000c48:	00006517          	auipc	a0,0x6
    80000c4c:	42850513          	addi	a0,a0,1064 # 80007070 <etext+0x70>
    80000c50:	ba1ff0ef          	jal	800007f0 <panic>

0000000080000c54 <memset>:
#include "types.h"

void *
memset(void *dst, int c, uint n)
{
    80000c54:	1141                	addi	sp,sp,-16
    80000c56:	e422                	sd	s0,8(sp)
    80000c58:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
    80000c5a:	ca19                	beqz	a2,80000c70 <memset+0x1c>
    80000c5c:	87aa                	mv	a5,a0
    80000c5e:	1602                	slli	a2,a2,0x20
    80000c60:	9201                	srli	a2,a2,0x20
    80000c62:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000c66:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
    80000c6a:	0785                	addi	a5,a5,1
    80000c6c:	fee79de3          	bne	a5,a4,80000c66 <memset+0x12>
  }
  return dst;
}
    80000c70:	6422                	ld	s0,8(sp)
    80000c72:	0141                	addi	sp,sp,16
    80000c74:	8082                	ret

0000000080000c76 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000c76:	1141                	addi	sp,sp,-16
    80000c78:	e422                	sd	s0,8(sp)
    80000c7a:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while (n-- > 0) {
    80000c7c:	ca05                	beqz	a2,80000cac <memcmp+0x36>
    80000c7e:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000c82:	1682                	slli	a3,a3,0x20
    80000c84:	9281                	srli	a3,a3,0x20
    80000c86:	0685                	addi	a3,a3,1
    80000c88:	96aa                	add	a3,a3,a0
    if (*s1 != *s2)
    80000c8a:	00054783          	lbu	a5,0(a0)
    80000c8e:	0005c703          	lbu	a4,0(a1)
    80000c92:	00e79863          	bne	a5,a4,80000ca2 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000c96:	0505                	addi	a0,a0,1
    80000c98:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    80000c9a:	fed518e3          	bne	a0,a3,80000c8a <memcmp+0x14>
  }

  return 0;
    80000c9e:	4501                	li	a0,0
    80000ca0:	a019                	j	80000ca6 <memcmp+0x30>
      return *s1 - *s2;
    80000ca2:	40e7853b          	subw	a0,a5,a4
}
    80000ca6:	6422                	ld	s0,8(sp)
    80000ca8:	0141                	addi	sp,sp,16
    80000caa:	8082                	ret
  return 0;
    80000cac:	4501                	li	a0,0
    80000cae:	bfe5                	j	80000ca6 <memcmp+0x30>

0000000080000cb0 <memmove>:

void *
memmove(void *dst, const void *src, uint n)
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e422                	sd	s0,8(sp)
    80000cb4:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if (n == 0)
    80000cb6:	c205                	beqz	a2,80000cd6 <memmove+0x26>
    return dst;

  s = src;
  d = dst;
  if (s < d && s + n > d) {
    80000cb8:	02a5e263          	bltu	a1,a0,80000cdc <memmove+0x2c>
    s += n;
    d += n;
    while (n-- > 0)
      *--d = *--s;
  } else
    while (n-- > 0)
    80000cbc:	1602                	slli	a2,a2,0x20
    80000cbe:	9201                	srli	a2,a2,0x20
    80000cc0:	00c587b3          	add	a5,a1,a2
{
    80000cc4:	872a                	mv	a4,a0
      *d++ = *s++;
    80000cc6:	0585                	addi	a1,a1,1
    80000cc8:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdc491>
    80000cca:	fff5c683          	lbu	a3,-1(a1)
    80000cce:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
    80000cd2:	feb79ae3          	bne	a5,a1,80000cc6 <memmove+0x16>

  return dst;
}
    80000cd6:	6422                	ld	s0,8(sp)
    80000cd8:	0141                	addi	sp,sp,16
    80000cda:	8082                	ret
  if (s < d && s + n > d) {
    80000cdc:	02061693          	slli	a3,a2,0x20
    80000ce0:	9281                	srli	a3,a3,0x20
    80000ce2:	00d58733          	add	a4,a1,a3
    80000ce6:	fce57be3          	bgeu	a0,a4,80000cbc <memmove+0xc>
    d += n;
    80000cea:	96aa                	add	a3,a3,a0
    while (n-- > 0)
    80000cec:	fff6079b          	addiw	a5,a2,-1
    80000cf0:	1782                	slli	a5,a5,0x20
    80000cf2:	9381                	srli	a5,a5,0x20
    80000cf4:	fff7c793          	not	a5,a5
    80000cf8:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000cfa:	177d                	addi	a4,a4,-1
    80000cfc:	16fd                	addi	a3,a3,-1
    80000cfe:	00074603          	lbu	a2,0(a4)
    80000d02:	00c68023          	sb	a2,0(a3)
    while (n-- > 0)
    80000d06:	fef71ae3          	bne	a4,a5,80000cfa <memmove+0x4a>
    80000d0a:	b7f1                	j	80000cd6 <memmove+0x26>

0000000080000d0c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void *
memcpy(void *dst, const void *src, uint n)
{
    80000d0c:	1141                	addi	sp,sp,-16
    80000d0e:	e406                	sd	ra,8(sp)
    80000d10:	e022                	sd	s0,0(sp)
    80000d12:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d14:	f9dff0ef          	jal	80000cb0 <memmove>
}
    80000d18:	60a2                	ld	ra,8(sp)
    80000d1a:	6402                	ld	s0,0(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret

0000000080000d20 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d20:	1141                	addi	sp,sp,-16
    80000d22:	e422                	sd	s0,8(sp)
    80000d24:	0800                	addi	s0,sp,16
  while (n > 0 && *p && *p == *q)
    80000d26:	ce11                	beqz	a2,80000d42 <strncmp+0x22>
    80000d28:	00054783          	lbu	a5,0(a0)
    80000d2c:	cf89                	beqz	a5,80000d46 <strncmp+0x26>
    80000d2e:	0005c703          	lbu	a4,0(a1)
    80000d32:	00f71a63          	bne	a4,a5,80000d46 <strncmp+0x26>
    n--, p++, q++;
    80000d36:	367d                	addiw	a2,a2,-1
    80000d38:	0505                	addi	a0,a0,1
    80000d3a:	0585                	addi	a1,a1,1
  while (n > 0 && *p && *p == *q)
    80000d3c:	f675                	bnez	a2,80000d28 <strncmp+0x8>
  if (n == 0)
    return 0;
    80000d3e:	4501                	li	a0,0
    80000d40:	a801                	j	80000d50 <strncmp+0x30>
    80000d42:	4501                	li	a0,0
    80000d44:	a031                	j	80000d50 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000d46:	00054503          	lbu	a0,0(a0)
    80000d4a:	0005c783          	lbu	a5,0(a1)
    80000d4e:	9d1d                	subw	a0,a0,a5
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret

0000000080000d56 <strncpy>:

char *
strncpy(char *s, const char *t, int n)
{
    80000d56:	1141                	addi	sp,sp,-16
    80000d58:	e422                	sd	s0,8(sp)
    80000d5a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while (n-- > 0 && (*s++ = *t++) != 0)
    80000d5c:	87aa                	mv	a5,a0
    80000d5e:	86b2                	mv	a3,a2
    80000d60:	367d                	addiw	a2,a2,-1
    80000d62:	02d05563          	blez	a3,80000d8c <strncpy+0x36>
    80000d66:	0785                	addi	a5,a5,1
    80000d68:	0005c703          	lbu	a4,0(a1)
    80000d6c:	fee78fa3          	sb	a4,-1(a5)
    80000d70:	0585                	addi	a1,a1,1
    80000d72:	f775                	bnez	a4,80000d5e <strncpy+0x8>
    ;
  while (n-- > 0)
    80000d74:	873e                	mv	a4,a5
    80000d76:	9fb5                	addw	a5,a5,a3
    80000d78:	37fd                	addiw	a5,a5,-1
    80000d7a:	00c05963          	blez	a2,80000d8c <strncpy+0x36>
    *s++ = 0;
    80000d7e:	0705                	addi	a4,a4,1
    80000d80:	fe070fa3          	sb	zero,-1(a4)
  while (n-- > 0)
    80000d84:	40e786bb          	subw	a3,a5,a4
    80000d88:	fed04be3          	bgtz	a3,80000d7e <strncpy+0x28>
  return os;
}
    80000d8c:	6422                	ld	s0,8(sp)
    80000d8e:	0141                	addi	sp,sp,16
    80000d90:	8082                	ret

0000000080000d92 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char *
safestrcpy(char *s, const char *t, int n)
{
    80000d92:	1141                	addi	sp,sp,-16
    80000d94:	e422                	sd	s0,8(sp)
    80000d96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if (n <= 0)
    80000d98:	02c05363          	blez	a2,80000dbe <safestrcpy+0x2c>
    80000d9c:	fff6069b          	addiw	a3,a2,-1
    80000da0:	1682                	slli	a3,a3,0x20
    80000da2:	9281                	srli	a3,a3,0x20
    80000da4:	96ae                	add	a3,a3,a1
    80000da6:	87aa                	mv	a5,a0
    return os;
  while (--n > 0 && (*s++ = *t++) != 0)
    80000da8:	00d58963          	beq	a1,a3,80000dba <safestrcpy+0x28>
    80000dac:	0585                	addi	a1,a1,1
    80000dae:	0785                	addi	a5,a5,1
    80000db0:	fff5c703          	lbu	a4,-1(a1)
    80000db4:	fee78fa3          	sb	a4,-1(a5)
    80000db8:	fb65                	bnez	a4,80000da8 <safestrcpy+0x16>
    ;
  *s = 0;
    80000dba:	00078023          	sb	zero,0(a5)
  return os;
}
    80000dbe:	6422                	ld	s0,8(sp)
    80000dc0:	0141                	addi	sp,sp,16
    80000dc2:	8082                	ret

0000000080000dc4 <strlen>:

int
strlen(const char *s)
{
    80000dc4:	1141                	addi	sp,sp,-16
    80000dc6:	e422                	sd	s0,8(sp)
    80000dc8:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
    80000dca:	00054783          	lbu	a5,0(a0)
    80000dce:	cf91                	beqz	a5,80000dea <strlen+0x26>
    80000dd0:	0505                	addi	a0,a0,1
    80000dd2:	87aa                	mv	a5,a0
    80000dd4:	86be                	mv	a3,a5
    80000dd6:	0785                	addi	a5,a5,1
    80000dd8:	fff7c703          	lbu	a4,-1(a5)
    80000ddc:	ff65                	bnez	a4,80000dd4 <strlen+0x10>
    80000dde:	40a6853b          	subw	a0,a3,a0
    80000de2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000de4:	6422                	ld	s0,8(sp)
    80000de6:	0141                	addi	sp,sp,16
    80000de8:	8082                	ret
  for (n = 0; s[n]; n++)
    80000dea:	4501                	li	a0,0
    80000dec:	bfe5                	j	80000de4 <strlen+0x20>

0000000080000dee <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000dee:	1141                	addi	sp,sp,-16
    80000df0:	e406                	sd	ra,8(sp)
    80000df2:	e022                	sd	s0,0(sp)
    80000df4:	0800                	addi	s0,sp,16
  if (cpuid() == 0) {
    80000df6:	281000ef          	jal	80001876 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();         // first user process

    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
  } else {
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000dfa:	00009717          	auipc	a4,0x9
    80000dfe:	a3270713          	addi	a4,a4,-1486 # 8000982c <started>
  if (cpuid() == 0) {
    80000e02:	c51d                	beqz	a0,80000e30 <main+0x42>
    while (__atomic_load_n(&started, __ATOMIC_ACQUIRE) == 0)
    80000e04:	431c                	lw	a5,0(a4)
    80000e06:	0230000f          	fence	r,rw
    80000e0a:	2781                	sext.w	a5,a5
    80000e0c:	dfe5                	beqz	a5,80000e04 <main+0x16>
      ;

    printk("hart %d starting\n", cpuid());
    80000e0e:	269000ef          	jal	80001876 <cpuid>
    80000e12:	85aa                	mv	a1,a0
    80000e14:	00006517          	auipc	a0,0x6
    80000e18:	28450513          	addi	a0,a0,644 # 80007098 <etext+0x98>
    80000e1c:	eeeff0ef          	jal	8000050a <printk>
    kvminithart();  // turn on paging
    80000e20:	082000ef          	jal	80000ea2 <kvminithart>
    trapinithart(); // install kernel trap vector
    80000e24:	5ea010ef          	jal	8000240e <trapinithart>
    plicinithart(); // ask PLIC for device interrupts
    80000e28:	780040ef          	jal	800055a8 <plicinithart>
  }

  scheduler();
    80000e2c:	6f1000ef          	jal	80001d1c <scheduler>
    consoleinit();
    80000e30:	e04ff0ef          	jal	80000434 <consoleinit>
    printkinit();
    80000e34:	9f9ff0ef          	jal	8000082c <printkinit>
    printk("\n");
    80000e38:	00006517          	auipc	a0,0x6
    80000e3c:	24050513          	addi	a0,a0,576 # 80007078 <etext+0x78>
    80000e40:	ecaff0ef          	jal	8000050a <printk>
    printk("xv6 kernel is booting\n");
    80000e44:	00006517          	auipc	a0,0x6
    80000e48:	23c50513          	addi	a0,a0,572 # 80007080 <etext+0x80>
    80000e4c:	ebeff0ef          	jal	8000050a <printk>
    printk("\n");
    80000e50:	00006517          	auipc	a0,0x6
    80000e54:	22850513          	addi	a0,a0,552 # 80007078 <etext+0x78>
    80000e58:	eb2ff0ef          	jal	8000050a <printk>
    kinit();            // physical page allocator
    80000e5c:	c3bff0ef          	jal	80000a96 <kinit>
    kvminit();          // create kernel page table
    80000e60:	2cc000ef          	jal	8000112c <kvminit>
    kvminithart();      // turn on paging
    80000e64:	03e000ef          	jal	80000ea2 <kvminithart>
    procinit();         // process table
    80000e68:	159000ef          	jal	800017c0 <procinit>
    trapinit();         // trap vectors
    80000e6c:	57e010ef          	jal	800023ea <trapinit>
    trapinithart();     // install kernel trap vector
    80000e70:	59e010ef          	jal	8000240e <trapinithart>
    plicinit();         // set up interrupt controller
    80000e74:	71a040ef          	jal	8000558e <plicinit>
    plicinithart();     // ask PLIC for device interrupts
    80000e78:	730040ef          	jal	800055a8 <plicinithart>
    binit();            // buffer cache
    80000e7c:	42f010ef          	jal	80002aaa <binit>
    iinit();            // inode table
    80000e80:	1b4020ef          	jal	80003034 <iinit>
    fileinit();         // file table
    80000e84:	1a4030ef          	jal	80004028 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000e88:	011040ef          	jal	80005698 <virtio_disk_init>
    userinit();         // first user process
    80000e8c:	4e5000ef          	jal	80001b70 <userinit>
    __atomic_store_n(&started, 1, __ATOMIC_RELEASE);
    80000e90:	00009797          	auipc	a5,0x9
    80000e94:	99c78793          	addi	a5,a5,-1636 # 8000982c <started>
    80000e98:	4705                	li	a4,1
    80000e9a:	0310000f          	fence	rw,w
    80000e9e:	c398                	sw	a4,0(a5)
    80000ea0:	b771                	j	80000e2c <main+0x3e>

0000000080000ea2 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000ea2:	1141                	addi	sp,sp,-16
    80000ea4:	e422                	sd	s0,8(sp)
    80000ea6:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000ea8:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000eac:	00009797          	auipc	a5,0x9
    80000eb0:	9847b783          	ld	a5,-1660(a5) # 80009830 <kernel_pagetable>
    80000eb4:	83b1                	srli	a5,a5,0xc
    80000eb6:	577d                	li	a4,-1
    80000eb8:	177e                	slli	a4,a4,0x3f
    80000eba:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r"(x));
    80000ebc:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero" ::: "memory");
    80000ec0:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000ec4:	6422                	ld	s0,8(sp)
    80000ec6:	0141                	addi	sp,sp,16
    80000ec8:	8082                	ret

0000000080000eca <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000eca:	7139                	addi	sp,sp,-64
    80000ecc:	fc06                	sd	ra,56(sp)
    80000ece:	f822                	sd	s0,48(sp)
    80000ed0:	f426                	sd	s1,40(sp)
    80000ed2:	f04a                	sd	s2,32(sp)
    80000ed4:	ec4e                	sd	s3,24(sp)
    80000ed6:	e852                	sd	s4,16(sp)
    80000ed8:	e456                	sd	s5,8(sp)
    80000eda:	e05a                	sd	s6,0(sp)
    80000edc:	0080                	addi	s0,sp,64
    80000ede:	84aa                	mv	s1,a0
    80000ee0:	89ae                	mv	s3,a1
    80000ee2:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80000ee4:	57fd                	li	a5,-1
    80000ee6:	83e9                	srli	a5,a5,0x1a
    80000ee8:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--) {
    80000eea:	4b31                	li	s6,12
  if (va >= MAXVA)
    80000eec:	02b7fc63          	bgeu	a5,a1,80000f24 <walk+0x5a>
    panic("walk");
    80000ef0:	00006517          	auipc	a0,0x6
    80000ef4:	1c050513          	addi	a0,a0,448 # 800070b0 <etext+0xb0>
    80000ef8:	8f9ff0ef          	jal	800007f0 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if (*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    80000efc:	060a8263          	beqz	s5,80000f60 <walk+0x96>
    80000f00:	bcbff0ef          	jal	80000aca <kalloc>
    80000f04:	84aa                	mv	s1,a0
    80000f06:	c139                	beqz	a0,80000f4c <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f08:	6605                	lui	a2,0x1
    80000f0a:	4581                	li	a1,0
    80000f0c:	d49ff0ef          	jal	80000c54 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f10:	00c4d793          	srli	a5,s1,0xc
    80000f14:	07aa                	slli	a5,a5,0xa
    80000f16:	0017e793          	ori	a5,a5,1
    80000f1a:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--) {
    80000f1e:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdc487>
    80000f20:	036a0063          	beq	s4,s6,80000f40 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f24:	0149d933          	srl	s2,s3,s4
    80000f28:	1ff97913          	andi	s2,s2,511
    80000f2c:	090e                	slli	s2,s2,0x3
    80000f2e:	9926                	add	s2,s2,s1
    if (*pte & PTE_V) {
    80000f30:	00093483          	ld	s1,0(s2)
    80000f34:	0014f793          	andi	a5,s1,1
    80000f38:	d3f1                	beqz	a5,80000efc <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000f3a:	80a9                	srli	s1,s1,0xa
    80000f3c:	04b2                	slli	s1,s1,0xc
    80000f3e:	b7c5                	j	80000f1e <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000f40:	00c9d513          	srli	a0,s3,0xc
    80000f44:	1ff57513          	andi	a0,a0,511
    80000f48:	050e                	slli	a0,a0,0x3
    80000f4a:	9526                	add	a0,a0,s1
}
    80000f4c:	70e2                	ld	ra,56(sp)
    80000f4e:	7442                	ld	s0,48(sp)
    80000f50:	74a2                	ld	s1,40(sp)
    80000f52:	7902                	ld	s2,32(sp)
    80000f54:	69e2                	ld	s3,24(sp)
    80000f56:	6a42                	ld	s4,16(sp)
    80000f58:	6aa2                	ld	s5,8(sp)
    80000f5a:	6b02                	ld	s6,0(sp)
    80000f5c:	6121                	addi	sp,sp,64
    80000f5e:	8082                	ret
        return 0;
    80000f60:	4501                	li	a0,0
    80000f62:	b7ed                	j	80000f4c <walk+0x82>

0000000080000f64 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80000f64:	57fd                	li	a5,-1
    80000f66:	83e9                	srli	a5,a5,0x1a
    80000f68:	00b7f463          	bgeu	a5,a1,80000f70 <walkaddr+0xc>
    return 0;
    80000f6c:	4501                	li	a0,0
    return 0;
  if ((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000f6e:	8082                	ret
{
    80000f70:	1141                	addi	sp,sp,-16
    80000f72:	e406                	sd	ra,8(sp)
    80000f74:	e022                	sd	s0,0(sp)
    80000f76:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000f78:	4601                	li	a2,0
    80000f7a:	f51ff0ef          	jal	80000eca <walk>
  if (pte == 0)
    80000f7e:	c105                	beqz	a0,80000f9e <walkaddr+0x3a>
  if ((*pte & PTE_V) == 0)
    80000f80:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80000f82:	0117f693          	andi	a3,a5,17
    80000f86:	4745                	li	a4,17
    return 0;
    80000f88:	4501                	li	a0,0
  if ((*pte & PTE_U) == 0)
    80000f8a:	00e68663          	beq	a3,a4,80000f96 <walkaddr+0x32>
}
    80000f8e:	60a2                	ld	ra,8(sp)
    80000f90:	6402                	ld	s0,0(sp)
    80000f92:	0141                	addi	sp,sp,16
    80000f94:	8082                	ret
  pa = PTE2PA(*pte);
    80000f96:	83a9                	srli	a5,a5,0xa
    80000f98:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000f9c:	bfcd                	j	80000f8e <walkaddr+0x2a>
    return 0;
    80000f9e:	4501                	li	a0,0
    80000fa0:	b7fd                	j	80000f8e <walkaddr+0x2a>

0000000080000fa2 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000fa2:	715d                	addi	sp,sp,-80
    80000fa4:	e486                	sd	ra,72(sp)
    80000fa6:	e0a2                	sd	s0,64(sp)
    80000fa8:	fc26                	sd	s1,56(sp)
    80000faa:	f84a                	sd	s2,48(sp)
    80000fac:	f44e                	sd	s3,40(sp)
    80000fae:	f052                	sd	s4,32(sp)
    80000fb0:	ec56                	sd	s5,24(sp)
    80000fb2:	e85a                	sd	s6,16(sp)
    80000fb4:	e45e                	sd	s7,8(sp)
    80000fb6:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80000fb8:	03459793          	slli	a5,a1,0x34
    80000fbc:	e7a9                	bnez	a5,80001006 <mappages+0x64>
    80000fbe:	8aaa                	mv	s5,a0
    80000fc0:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if ((size % PGSIZE) != 0)
    80000fc2:	03461793          	slli	a5,a2,0x34
    80000fc6:	e7b1                	bnez	a5,80001012 <mappages+0x70>
    panic("mappages: size not aligned");

  if (size == 0)
    80000fc8:	ca39                	beqz	a2,8000101e <mappages+0x7c>
    panic("mappages: size");

  a = va;
  last = va + size - PGSIZE;
    80000fca:	77fd                	lui	a5,0xfffff
    80000fcc:	963e                	add	a2,a2,a5
    80000fce:	00b609b3          	add	s3,a2,a1
  a = va;
    80000fd2:	892e                	mv	s2,a1
    80000fd4:	40b68a33          	sub	s4,a3,a1
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    80000fd8:	6b85                	lui	s7,0x1
    80000fda:	014904b3          	add	s1,s2,s4
    if ((pte = walk(pagetable, a, 1)) == 0)
    80000fde:	4605                	li	a2,1
    80000fe0:	85ca                	mv	a1,s2
    80000fe2:	8556                	mv	a0,s5
    80000fe4:	ee7ff0ef          	jal	80000eca <walk>
    80000fe8:	c539                	beqz	a0,80001036 <mappages+0x94>
    if (*pte & PTE_V)
    80000fea:	611c                	ld	a5,0(a0)
    80000fec:	8b85                	andi	a5,a5,1
    80000fee:	ef95                	bnez	a5,8000102a <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000ff0:	80b1                	srli	s1,s1,0xc
    80000ff2:	04aa                	slli	s1,s1,0xa
    80000ff4:	0164e4b3          	or	s1,s1,s6
    80000ff8:	0014e493          	ori	s1,s1,1
    80000ffc:	e104                	sd	s1,0(a0)
    if (a == last)
    80000ffe:	05390863          	beq	s2,s3,8000104e <mappages+0xac>
    a += PGSIZE;
    80001002:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    80001004:	bfd9                	j	80000fda <mappages+0x38>
    panic("mappages: va not aligned");
    80001006:	00006517          	auipc	a0,0x6
    8000100a:	0b250513          	addi	a0,a0,178 # 800070b8 <etext+0xb8>
    8000100e:	fe2ff0ef          	jal	800007f0 <panic>
    panic("mappages: size not aligned");
    80001012:	00006517          	auipc	a0,0x6
    80001016:	0c650513          	addi	a0,a0,198 # 800070d8 <etext+0xd8>
    8000101a:	fd6ff0ef          	jal	800007f0 <panic>
    panic("mappages: size");
    8000101e:	00006517          	auipc	a0,0x6
    80001022:	0da50513          	addi	a0,a0,218 # 800070f8 <etext+0xf8>
    80001026:	fcaff0ef          	jal	800007f0 <panic>
      panic("mappages: remap");
    8000102a:	00006517          	auipc	a0,0x6
    8000102e:	0de50513          	addi	a0,a0,222 # 80007108 <etext+0x108>
    80001032:	fbeff0ef          	jal	800007f0 <panic>
      return -1;
    80001036:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001038:	60a6                	ld	ra,72(sp)
    8000103a:	6406                	ld	s0,64(sp)
    8000103c:	74e2                	ld	s1,56(sp)
    8000103e:	7942                	ld	s2,48(sp)
    80001040:	79a2                	ld	s3,40(sp)
    80001042:	7a02                	ld	s4,32(sp)
    80001044:	6ae2                	ld	s5,24(sp)
    80001046:	6b42                	ld	s6,16(sp)
    80001048:	6ba2                	ld	s7,8(sp)
    8000104a:	6161                	addi	sp,sp,80
    8000104c:	8082                	ret
  return 0;
    8000104e:	4501                	li	a0,0
    80001050:	b7e5                	j	80001038 <mappages+0x96>

0000000080001052 <kvmmap>:
{
    80001052:	1141                	addi	sp,sp,-16
    80001054:	e406                	sd	ra,8(sp)
    80001056:	e022                	sd	s0,0(sp)
    80001058:	0800                	addi	s0,sp,16
    8000105a:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000105c:	86b2                	mv	a3,a2
    8000105e:	863e                	mv	a2,a5
    80001060:	f43ff0ef          	jal	80000fa2 <mappages>
    80001064:	e509                	bnez	a0,8000106e <kvmmap+0x1c>
}
    80001066:	60a2                	ld	ra,8(sp)
    80001068:	6402                	ld	s0,0(sp)
    8000106a:	0141                	addi	sp,sp,16
    8000106c:	8082                	ret
    panic("kvmmap");
    8000106e:	00006517          	auipc	a0,0x6
    80001072:	0aa50513          	addi	a0,a0,170 # 80007118 <etext+0x118>
    80001076:	f7aff0ef          	jal	800007f0 <panic>

000000008000107a <kvmmake>:
{
    8000107a:	1101                	addi	sp,sp,-32
    8000107c:	ec06                	sd	ra,24(sp)
    8000107e:	e822                	sd	s0,16(sp)
    80001080:	e426                	sd	s1,8(sp)
    80001082:	e04a                	sd	s2,0(sp)
    80001084:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80001086:	a45ff0ef          	jal	80000aca <kalloc>
    8000108a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000108c:	6605                	lui	a2,0x1
    8000108e:	4581                	li	a1,0
    80001090:	bc5ff0ef          	jal	80000c54 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001094:	4719                	li	a4,6
    80001096:	6685                	lui	a3,0x1
    80001098:	10000637          	lui	a2,0x10000
    8000109c:	100005b7          	lui	a1,0x10000
    800010a0:	8526                	mv	a0,s1
    800010a2:	fb1ff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800010a6:	4719                	li	a4,6
    800010a8:	6685                	lui	a3,0x1
    800010aa:	10001637          	lui	a2,0x10001
    800010ae:	100015b7          	lui	a1,0x10001
    800010b2:	8526                	mv	a0,s1
    800010b4:	f9fff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800010b8:	4719                	li	a4,6
    800010ba:	040006b7          	lui	a3,0x4000
    800010be:	0c000637          	lui	a2,0xc000
    800010c2:	0c0005b7          	lui	a1,0xc000
    800010c6:	8526                	mv	a0,s1
    800010c8:	f8bff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800010cc:	00006917          	auipc	s2,0x6
    800010d0:	f3490913          	addi	s2,s2,-204 # 80007000 <etext>
    800010d4:	4729                	li	a4,10
    800010d6:	80006697          	auipc	a3,0x80006
    800010da:	f2a68693          	addi	a3,a3,-214 # 7000 <_entry-0x7fff9000>
    800010de:	4605                	li	a2,1
    800010e0:	067e                	slli	a2,a2,0x1f
    800010e2:	85b2                	mv	a1,a2
    800010e4:	8526                	mv	a0,s1
    800010e6:	f6dff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext,
    800010ea:	46c5                	li	a3,17
    800010ec:	06ee                	slli	a3,a3,0x1b
    800010ee:	4719                	li	a4,6
    800010f0:	412686b3          	sub	a3,a3,s2
    800010f4:	864a                	mv	a2,s2
    800010f6:	85ca                	mv	a1,s2
    800010f8:	8526                	mv	a0,s1
    800010fa:	f59ff0ef          	jal	80001052 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800010fe:	4729                	li	a4,10
    80001100:	6685                	lui	a3,0x1
    80001102:	00005617          	auipc	a2,0x5
    80001106:	efe60613          	addi	a2,a2,-258 # 80006000 <_trampoline>
    8000110a:	040005b7          	lui	a1,0x4000
    8000110e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001110:	05b2                	slli	a1,a1,0xc
    80001112:	8526                	mv	a0,s1
    80001114:	f3fff0ef          	jal	80001052 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001118:	8526                	mv	a0,s1
    8000111a:	60e000ef          	jal	80001728 <proc_mapstacks>
}
    8000111e:	8526                	mv	a0,s1
    80001120:	60e2                	ld	ra,24(sp)
    80001122:	6442                	ld	s0,16(sp)
    80001124:	64a2                	ld	s1,8(sp)
    80001126:	6902                	ld	s2,0(sp)
    80001128:	6105                	addi	sp,sp,32
    8000112a:	8082                	ret

000000008000112c <kvminit>:
{
    8000112c:	1141                	addi	sp,sp,-16
    8000112e:	e406                	sd	ra,8(sp)
    80001130:	e022                	sd	s0,0(sp)
    80001132:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001134:	f47ff0ef          	jal	8000107a <kvmmake>
    80001138:	00008797          	auipc	a5,0x8
    8000113c:	6ea7bc23          	sd	a0,1784(a5) # 80009830 <kernel_pagetable>
}
    80001140:	60a2                	ld	ra,8(sp)
    80001142:	6402                	ld	s0,0(sp)
    80001144:	0141                	addi	sp,sp,16
    80001146:	8082                	ret

0000000080001148 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001148:	1101                	addi	sp,sp,-32
    8000114a:	ec06                	sd	ra,24(sp)
    8000114c:	e822                	sd	s0,16(sp)
    8000114e:	e426                	sd	s1,8(sp)
    80001150:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    80001152:	979ff0ef          	jal	80000aca <kalloc>
    80001156:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001158:	c509                	beqz	a0,80001162 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000115a:	6605                	lui	a2,0x1
    8000115c:	4581                	li	a1,0
    8000115e:	af7ff0ef          	jal	80000c54 <memset>
  return pagetable;
}
    80001162:	8526                	mv	a0,s1
    80001164:	60e2                	ld	ra,24(sp)
    80001166:	6442                	ld	s0,16(sp)
    80001168:	64a2                	ld	s1,8(sp)
    8000116a:	6105                	addi	sp,sp,32
    8000116c:	8082                	ret

000000008000116e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000116e:	7139                	addi	sp,sp,-64
    80001170:	fc06                	sd	ra,56(sp)
    80001172:	f822                	sd	s0,48(sp)
    80001174:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001176:	03459793          	slli	a5,a1,0x34
    8000117a:	e38d                	bnez	a5,8000119c <uvmunmap+0x2e>
    8000117c:	f04a                	sd	s2,32(sp)
    8000117e:	ec4e                	sd	s3,24(sp)
    80001180:	e852                	sd	s4,16(sp)
    80001182:	e456                	sd	s5,8(sp)
    80001184:	e05a                	sd	s6,0(sp)
    80001186:	8a2a                	mv	s4,a0
    80001188:	892e                	mv	s2,a1
    8000118a:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    8000118c:	0632                	slli	a2,a2,0xc
    8000118e:	00b609b3          	add	s3,a2,a1
    80001192:	6b05                	lui	s6,0x1
    80001194:	0535f963          	bgeu	a1,s3,800011e6 <uvmunmap+0x78>
    80001198:	f426                	sd	s1,40(sp)
    8000119a:	a015                	j	800011be <uvmunmap+0x50>
    8000119c:	f426                	sd	s1,40(sp)
    8000119e:	f04a                	sd	s2,32(sp)
    800011a0:	ec4e                	sd	s3,24(sp)
    800011a2:	e852                	sd	s4,16(sp)
    800011a4:	e456                	sd	s5,8(sp)
    800011a6:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800011a8:	00006517          	auipc	a0,0x6
    800011ac:	f7850513          	addi	a0,a0,-136 # 80007120 <etext+0x120>
    800011b0:	e40ff0ef          	jal	800007f0 <panic>
      continue;
    if (do_free) {
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
    800011b4:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE) {
    800011b8:	995a                	add	s2,s2,s6
    800011ba:	03397563          	bgeu	s2,s3,800011e4 <uvmunmap+0x76>
    if ((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800011be:	4601                	li	a2,0
    800011c0:	85ca                	mv	a1,s2
    800011c2:	8552                	mv	a0,s4
    800011c4:	d07ff0ef          	jal	80000eca <walk>
    800011c8:	84aa                	mv	s1,a0
    800011ca:	d57d                	beqz	a0,800011b8 <uvmunmap+0x4a>
    if ((*pte & PTE_V) == 0) // has physical page been allocated?
    800011cc:	611c                	ld	a5,0(a0)
    800011ce:	0017f713          	andi	a4,a5,1
    800011d2:	d37d                	beqz	a4,800011b8 <uvmunmap+0x4a>
    if (do_free) {
    800011d4:	fe0a80e3          	beqz	s5,800011b4 <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800011d8:	83a9                	srli	a5,a5,0xa
      kfree((void *)pa);
    800011da:	00c79513          	slli	a0,a5,0xc
    800011de:	80bff0ef          	jal	800009e8 <kfree>
    800011e2:	bfc9                	j	800011b4 <uvmunmap+0x46>
    800011e4:	74a2                	ld	s1,40(sp)
    800011e6:	7902                	ld	s2,32(sp)
    800011e8:	69e2                	ld	s3,24(sp)
    800011ea:	6a42                	ld	s4,16(sp)
    800011ec:	6aa2                	ld	s5,8(sp)
    800011ee:	6b02                	ld	s6,0(sp)
  }
}
    800011f0:	70e2                	ld	ra,56(sp)
    800011f2:	7442                	ld	s0,48(sp)
    800011f4:	6121                	addi	sp,sp,64
    800011f6:	8082                	ret

00000000800011f8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800011f8:	1101                	addi	sp,sp,-32
    800011fa:	ec06                	sd	ra,24(sp)
    800011fc:	e822                	sd	s0,16(sp)
    800011fe:	e426                	sd	s1,8(sp)
    80001200:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    80001202:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    80001204:	00b67d63          	bgeu	a2,a1,8000121e <uvmdealloc+0x26>
    80001208:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz)) {
    8000120a:	6785                	lui	a5,0x1
    8000120c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000120e:	00f60733          	add	a4,a2,a5
    80001212:	76fd                	lui	a3,0xfffff
    80001214:	8f75                	and	a4,a4,a3
    80001216:	97ae                	add	a5,a5,a1
    80001218:	8ff5                	and	a5,a5,a3
    8000121a:	00f76863          	bltu	a4,a5,8000122a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000121e:	8526                	mv	a0,s1
    80001220:	60e2                	ld	ra,24(sp)
    80001222:	6442                	ld	s0,16(sp)
    80001224:	64a2                	ld	s1,8(sp)
    80001226:	6105                	addi	sp,sp,32
    80001228:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000122a:	8f99                	sub	a5,a5,a4
    8000122c:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000122e:	4685                	li	a3,1
    80001230:	0007861b          	sext.w	a2,a5
    80001234:	85ba                	mv	a1,a4
    80001236:	f39ff0ef          	jal	8000116e <uvmunmap>
    8000123a:	b7d5                	j	8000121e <uvmdealloc+0x26>

000000008000123c <uvmalloc>:
  if (newsz < oldsz)
    8000123c:	08b66f63          	bltu	a2,a1,800012da <uvmalloc+0x9e>
{
    80001240:	7139                	addi	sp,sp,-64
    80001242:	fc06                	sd	ra,56(sp)
    80001244:	f822                	sd	s0,48(sp)
    80001246:	ec4e                	sd	s3,24(sp)
    80001248:	e852                	sd	s4,16(sp)
    8000124a:	e456                	sd	s5,8(sp)
    8000124c:	0080                	addi	s0,sp,64
    8000124e:	8aaa                	mv	s5,a0
    80001250:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001252:	6785                	lui	a5,0x1
    80001254:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001256:	95be                	add	a1,a1,a5
    80001258:	77fd                	lui	a5,0xfffff
    8000125a:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE) {
    8000125e:	08c9f063          	bgeu	s3,a2,800012de <uvmalloc+0xa2>
    80001262:	f426                	sd	s1,40(sp)
    80001264:	f04a                	sd	s2,32(sp)
    80001266:	e05a                	sd	s6,0(sp)
    80001268:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000126a:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000126e:	85dff0ef          	jal	80000aca <kalloc>
    80001272:	84aa                	mv	s1,a0
    if (mem == 0) {
    80001274:	c515                	beqz	a0,800012a0 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001276:	6605                	lui	a2,0x1
    80001278:	4581                	li	a1,0
    8000127a:	9dbff0ef          	jal	80000c54 <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) !=
    8000127e:	875a                	mv	a4,s6
    80001280:	86a6                	mv	a3,s1
    80001282:	6605                	lui	a2,0x1
    80001284:	85ca                	mv	a1,s2
    80001286:	8556                	mv	a0,s5
    80001288:	d1bff0ef          	jal	80000fa2 <mappages>
    8000128c:	e915                	bnez	a0,800012c0 <uvmalloc+0x84>
  for (a = oldsz; a < newsz; a += PGSIZE) {
    8000128e:	6785                	lui	a5,0x1
    80001290:	993e                	add	s2,s2,a5
    80001292:	fd496ee3          	bltu	s2,s4,8000126e <uvmalloc+0x32>
  return newsz;
    80001296:	8552                	mv	a0,s4
    80001298:	74a2                	ld	s1,40(sp)
    8000129a:	7902                	ld	s2,32(sp)
    8000129c:	6b02                	ld	s6,0(sp)
    8000129e:	a811                	j	800012b2 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800012a0:	864e                	mv	a2,s3
    800012a2:	85ca                	mv	a1,s2
    800012a4:	8556                	mv	a0,s5
    800012a6:	f53ff0ef          	jal	800011f8 <uvmdealloc>
      return 0;
    800012aa:	4501                	li	a0,0
    800012ac:	74a2                	ld	s1,40(sp)
    800012ae:	7902                	ld	s2,32(sp)
    800012b0:	6b02                	ld	s6,0(sp)
}
    800012b2:	70e2                	ld	ra,56(sp)
    800012b4:	7442                	ld	s0,48(sp)
    800012b6:	69e2                	ld	s3,24(sp)
    800012b8:	6a42                	ld	s4,16(sp)
    800012ba:	6aa2                	ld	s5,8(sp)
    800012bc:	6121                	addi	sp,sp,64
    800012be:	8082                	ret
      kfree(mem);
    800012c0:	8526                	mv	a0,s1
    800012c2:	f26ff0ef          	jal	800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800012c6:	864e                	mv	a2,s3
    800012c8:	85ca                	mv	a1,s2
    800012ca:	8556                	mv	a0,s5
    800012cc:	f2dff0ef          	jal	800011f8 <uvmdealloc>
      return 0;
    800012d0:	4501                	li	a0,0
    800012d2:	74a2                	ld	s1,40(sp)
    800012d4:	7902                	ld	s2,32(sp)
    800012d6:	6b02                	ld	s6,0(sp)
    800012d8:	bfe9                	j	800012b2 <uvmalloc+0x76>
    return oldsz;
    800012da:	852e                	mv	a0,a1
}
    800012dc:	8082                	ret
  return newsz;
    800012de:	8532                	mv	a0,a2
    800012e0:	bfc9                	j	800012b2 <uvmalloc+0x76>

00000000800012e2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800012e2:	7179                	addi	sp,sp,-48
    800012e4:	f406                	sd	ra,40(sp)
    800012e6:	f022                	sd	s0,32(sp)
    800012e8:	ec26                	sd	s1,24(sp)
    800012ea:	e84a                	sd	s2,16(sp)
    800012ec:	e44e                	sd	s3,8(sp)
    800012ee:	e052                	sd	s4,0(sp)
    800012f0:	1800                	addi	s0,sp,48
    800012f2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++) {
    800012f4:	84aa                	mv	s1,a0
    800012f6:	6905                	lui	s2,0x1
    800012f8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    800012fa:	4985                	li	s3,1
    800012fc:	a819                	j	80001312 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800012fe:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001300:	00c79513          	slli	a0,a5,0xc
    80001304:	fdfff0ef          	jal	800012e2 <freewalk>
      pagetable[i] = 0;
    80001308:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++) {
    8000130c:	04a1                	addi	s1,s1,8
    8000130e:	01248f63          	beq	s1,s2,8000132c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001312:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0) {
    80001314:	00f7f713          	andi	a4,a5,15
    80001318:	ff3703e3          	beq	a4,s3,800012fe <freewalk+0x1c>
    } else if (pte & PTE_V) {
    8000131c:	8b85                	andi	a5,a5,1
    8000131e:	d7fd                	beqz	a5,8000130c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001320:	00006517          	auipc	a0,0x6
    80001324:	e1850513          	addi	a0,a0,-488 # 80007138 <etext+0x138>
    80001328:	cc8ff0ef          	jal	800007f0 <panic>
    }
  }
  kfree((void *)pagetable);
    8000132c:	8552                	mv	a0,s4
    8000132e:	ebaff0ef          	jal	800009e8 <kfree>
}
    80001332:	70a2                	ld	ra,40(sp)
    80001334:	7402                	ld	s0,32(sp)
    80001336:	64e2                	ld	s1,24(sp)
    80001338:	6942                	ld	s2,16(sp)
    8000133a:	69a2                	ld	s3,8(sp)
    8000133c:	6a02                	ld	s4,0(sp)
    8000133e:	6145                	addi	sp,sp,48
    80001340:	8082                	ret

0000000080001342 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001342:	1101                	addi	sp,sp,-32
    80001344:	ec06                	sd	ra,24(sp)
    80001346:	e822                	sd	s0,16(sp)
    80001348:	e426                	sd	s1,8(sp)
    8000134a:	1000                	addi	s0,sp,32
    8000134c:	84aa                	mv	s1,a0
  if (sz > 0)
    8000134e:	e989                	bnez	a1,80001360 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001350:	8526                	mv	a0,s1
    80001352:	f91ff0ef          	jal	800012e2 <freewalk>
}
    80001356:	60e2                	ld	ra,24(sp)
    80001358:	6442                	ld	s0,16(sp)
    8000135a:	64a2                	ld	s1,8(sp)
    8000135c:	6105                	addi	sp,sp,32
    8000135e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001360:	6785                	lui	a5,0x1
    80001362:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001364:	95be                	add	a1,a1,a5
    80001366:	4685                	li	a3,1
    80001368:	00c5d613          	srli	a2,a1,0xc
    8000136c:	4581                	li	a1,0
    8000136e:	e01ff0ef          	jal	8000116e <uvmunmap>
    80001372:	bff9                	j	80001350 <uvmfree+0xe>

0000000080001374 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE) {
    80001374:	ce49                	beqz	a2,8000140e <uvmcopy+0x9a>
{
    80001376:	715d                	addi	sp,sp,-80
    80001378:	e486                	sd	ra,72(sp)
    8000137a:	e0a2                	sd	s0,64(sp)
    8000137c:	fc26                	sd	s1,56(sp)
    8000137e:	f84a                	sd	s2,48(sp)
    80001380:	f44e                	sd	s3,40(sp)
    80001382:	f052                	sd	s4,32(sp)
    80001384:	ec56                	sd	s5,24(sp)
    80001386:	e85a                	sd	s6,16(sp)
    80001388:	e45e                	sd	s7,8(sp)
    8000138a:	0880                	addi	s0,sp,80
    8000138c:	8aaa                	mv	s5,a0
    8000138e:	8b2e                	mv	s6,a1
    80001390:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE) {
    80001392:	4481                	li	s1,0
    80001394:	a029                	j	8000139e <uvmcopy+0x2a>
    80001396:	6785                	lui	a5,0x1
    80001398:	94be                	add	s1,s1,a5
    8000139a:	0544fe63          	bgeu	s1,s4,800013f6 <uvmcopy+0x82>
    if ((pte = walk(old, i, 0)) == 0)
    8000139e:	4601                	li	a2,0
    800013a0:	85a6                	mv	a1,s1
    800013a2:	8556                	mv	a0,s5
    800013a4:	b27ff0ef          	jal	80000eca <walk>
    800013a8:	d57d                	beqz	a0,80001396 <uvmcopy+0x22>
      continue; // page table entry hasn't been allocated
    if ((*pte & PTE_V) == 0)
    800013aa:	6118                	ld	a4,0(a0)
    800013ac:	00177793          	andi	a5,a4,1
    800013b0:	d3fd                	beqz	a5,80001396 <uvmcopy+0x22>
      continue; // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800013b2:	00a75593          	srli	a1,a4,0xa
    800013b6:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800013ba:	3ff77913          	andi	s2,a4,1023
    if ((mem = kalloc()) == 0)
    800013be:	f0cff0ef          	jal	80000aca <kalloc>
    800013c2:	89aa                	mv	s3,a0
    800013c4:	c105                	beqz	a0,800013e4 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    800013c6:	6605                	lui	a2,0x1
    800013c8:	85de                	mv	a1,s7
    800013ca:	8e7ff0ef          	jal	80000cb0 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0) {
    800013ce:	874a                	mv	a4,s2
    800013d0:	86ce                	mv	a3,s3
    800013d2:	6605                	lui	a2,0x1
    800013d4:	85a6                	mv	a1,s1
    800013d6:	855a                	mv	a0,s6
    800013d8:	bcbff0ef          	jal	80000fa2 <mappages>
    800013dc:	dd4d                	beqz	a0,80001396 <uvmcopy+0x22>
      kfree(mem);
    800013de:	854e                	mv	a0,s3
    800013e0:	e08ff0ef          	jal	800009e8 <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800013e4:	4685                	li	a3,1
    800013e6:	00c4d613          	srli	a2,s1,0xc
    800013ea:	4581                	li	a1,0
    800013ec:	855a                	mv	a0,s6
    800013ee:	d81ff0ef          	jal	8000116e <uvmunmap>
  return -1;
    800013f2:	557d                	li	a0,-1
    800013f4:	a011                	j	800013f8 <uvmcopy+0x84>
  return 0;
    800013f6:	4501                	li	a0,0
}
    800013f8:	60a6                	ld	ra,72(sp)
    800013fa:	6406                	ld	s0,64(sp)
    800013fc:	74e2                	ld	s1,56(sp)
    800013fe:	7942                	ld	s2,48(sp)
    80001400:	79a2                	ld	s3,40(sp)
    80001402:	7a02                	ld	s4,32(sp)
    80001404:	6ae2                	ld	s5,24(sp)
    80001406:	6b42                	ld	s6,16(sp)
    80001408:	6ba2                	ld	s7,8(sp)
    8000140a:	6161                	addi	sp,sp,80
    8000140c:	8082                	ret
  return 0;
    8000140e:	4501                	li	a0,0
}
    80001410:	8082                	ret

0000000080001412 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001412:	1141                	addi	sp,sp,-16
    80001414:	e406                	sd	ra,8(sp)
    80001416:	e022                	sd	s0,0(sp)
    80001418:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    8000141a:	4601                	li	a2,0
    8000141c:	aafff0ef          	jal	80000eca <walk>
  if (pte == 0)
    80001420:	c901                	beqz	a0,80001430 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001422:	611c                	ld	a5,0(a0)
    80001424:	9bbd                	andi	a5,a5,-17
    80001426:	e11c                	sd	a5,0(a0)
}
    80001428:	60a2                	ld	ra,8(sp)
    8000142a:	6402                	ld	s0,0(sp)
    8000142c:	0141                	addi	sp,sp,16
    8000142e:	8082                	ret
    panic("uvmclear");
    80001430:	00006517          	auipc	a0,0x6
    80001434:	d1850513          	addi	a0,a0,-744 # 80007148 <etext+0x148>
    80001438:	bb8ff0ef          	jal	800007f0 <panic>

000000008000143c <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000143c:	1141                	addi	sp,sp,-16
    8000143e:	e406                	sd	ra,8(sp)
    80001440:	e022                	sd	s0,0(sp)
    80001442:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001444:	4601                	li	a2,0
    80001446:	a85ff0ef          	jal	80000eca <walk>
  if (pte == 0) {
    8000144a:	c519                	beqz	a0,80001458 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V) {
    8000144c:	6108                	ld	a0,0(a0)
    8000144e:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001450:	60a2                	ld	ra,8(sp)
    80001452:	6402                	ld	s0,0(sp)
    80001454:	0141                	addi	sp,sp,16
    80001456:	8082                	ret
    return 0;
    80001458:	4501                	li	a0,0
    8000145a:	bfdd                	j	80001450 <ismapped+0x14>

000000008000145c <vmfault>:
{
    8000145c:	7179                	addi	sp,sp,-48
    8000145e:	f406                	sd	ra,40(sp)
    80001460:	f022                	sd	s0,32(sp)
    80001462:	e44e                	sd	s3,8(sp)
    80001464:	1800                	addi	s0,sp,48
    return 0;
    80001466:	4981                	li	s3,0
  if (va >= psz)
    80001468:	00b66863          	bltu	a2,a1,80001478 <vmfault+0x1c>
}
    8000146c:	854e                	mv	a0,s3
    8000146e:	70a2                	ld	ra,40(sp)
    80001470:	7402                	ld	s0,32(sp)
    80001472:	69a2                	ld	s3,8(sp)
    80001474:	6145                	addi	sp,sp,48
    80001476:	8082                	ret
    80001478:	ec26                	sd	s1,24(sp)
    8000147a:	e84a                	sd	s2,16(sp)
    8000147c:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000147e:	77fd                	lui	a5,0xfffff
    80001480:	00f674b3          	and	s1,a2,a5
  if (ismapped(pagetable, va)) {
    80001484:	85a6                	mv	a1,s1
    80001486:	fb7ff0ef          	jal	8000143c <ismapped>
    return 0;
    8000148a:	4981                	li	s3,0
  if (ismapped(pagetable, va)) {
    8000148c:	c501                	beqz	a0,80001494 <vmfault+0x38>
    8000148e:	64e2                	ld	s1,24(sp)
    80001490:	6942                	ld	s2,16(sp)
    80001492:	bfe9                	j	8000146c <vmfault+0x10>
    80001494:	e052                	sd	s4,0(sp)
  mem = (uint64)kalloc();
    80001496:	e34ff0ef          	jal	80000aca <kalloc>
    8000149a:	8a2a                	mv	s4,a0
  if (mem == 0)
    8000149c:	c915                	beqz	a0,800014d0 <vmfault+0x74>
  mem = (uint64)kalloc();
    8000149e:	89aa                	mv	s3,a0
  memset((void *)mem, 0, PGSIZE);
    800014a0:	6605                	lui	a2,0x1
    800014a2:	4581                	li	a1,0
    800014a4:	fb0ff0ef          	jal	80000c54 <memset>
  if (mappages(pagetable, va, PGSIZE, mem, PTE_W | PTE_U | PTE_R) != 0) {
    800014a8:	4759                	li	a4,22
    800014aa:	86d2                	mv	a3,s4
    800014ac:	6605                	lui	a2,0x1
    800014ae:	85a6                	mv	a1,s1
    800014b0:	854a                	mv	a0,s2
    800014b2:	af1ff0ef          	jal	80000fa2 <mappages>
    800014b6:	e509                	bnez	a0,800014c0 <vmfault+0x64>
    800014b8:	64e2                	ld	s1,24(sp)
    800014ba:	6942                	ld	s2,16(sp)
    800014bc:	6a02                	ld	s4,0(sp)
    800014be:	b77d                	j	8000146c <vmfault+0x10>
    kfree((void *)mem);
    800014c0:	8552                	mv	a0,s4
    800014c2:	d26ff0ef          	jal	800009e8 <kfree>
    return 0;
    800014c6:	4981                	li	s3,0
    800014c8:	64e2                	ld	s1,24(sp)
    800014ca:	6942                	ld	s2,16(sp)
    800014cc:	6a02                	ld	s4,0(sp)
    800014ce:	bf79                	j	8000146c <vmfault+0x10>
    800014d0:	64e2                	ld	s1,24(sp)
    800014d2:	6942                	ld	s2,16(sp)
    800014d4:	6a02                	ld	s4,0(sp)
    800014d6:	bf59                	j	8000146c <vmfault+0x10>

00000000800014d8 <copyout>:
  while (len > 0) {
    800014d8:	c745                	beqz	a4,80001580 <copyout+0xa8>
{
    800014da:	7159                	addi	sp,sp,-112
    800014dc:	f486                	sd	ra,104(sp)
    800014de:	f0a2                	sd	s0,96(sp)
    800014e0:	eca6                	sd	s1,88(sp)
    800014e2:	e0d2                	sd	s4,64(sp)
    800014e4:	f85a                	sd	s6,48(sp)
    800014e6:	f45e                	sd	s7,40(sp)
    800014e8:	f062                	sd	s8,32(sp)
    800014ea:	e46e                	sd	s11,8(sp)
    800014ec:	1880                	addi	s0,sp,112
    800014ee:	8c2a                	mv	s8,a0
    800014f0:	8dae                	mv	s11,a1
    800014f2:	8b32                	mv	s6,a2
    800014f4:	8bb6                	mv	s7,a3
    800014f6:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(dstva);
    800014f8:	74fd                	lui	s1,0xfffff
    800014fa:	8cf1                	and	s1,s1,a2
    if (va0 >= MAXVA)
    800014fc:	57fd                	li	a5,-1
    800014fe:	83e9                	srli	a5,a5,0x1a
    80001500:	0897e263          	bltu	a5,s1,80001584 <copyout+0xac>
    80001504:	e8ca                	sd	s2,80(sp)
    80001506:	e4ce                	sd	s3,72(sp)
    80001508:	fc56                	sd	s5,56(sp)
    8000150a:	ec66                	sd	s9,24(sp)
    8000150c:	e86a                	sd	s10,16(sp)
    8000150e:	6d05                	lui	s10,0x1
    80001510:	8cbe                	mv	s9,a5
    80001512:	a015                	j	80001536 <copyout+0x5e>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001514:	409b0533          	sub	a0,s6,s1
    80001518:	0009861b          	sext.w	a2,s3
    8000151c:	85de                	mv	a1,s7
    8000151e:	954a                	add	a0,a0,s2
    80001520:	f90ff0ef          	jal	80000cb0 <memmove>
    len -= n;
    80001524:	413a0a33          	sub	s4,s4,s3
    src += n;
    80001528:	9bce                	add	s7,s7,s3
  while (len > 0) {
    8000152a:	040a0463          	beqz	s4,80001572 <copyout+0x9a>
    if (va0 >= MAXVA)
    8000152e:	055ced63          	bltu	s9,s5,80001588 <copyout+0xb0>
    80001532:	84d6                	mv	s1,s5
    80001534:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001536:	85a6                	mv	a1,s1
    80001538:	8562                	mv	a0,s8
    8000153a:	a2bff0ef          	jal	80000f64 <walkaddr>
    8000153e:	892a                	mv	s2,a0
    if (pa0 == 0) {
    80001540:	e909                	bnez	a0,80001552 <copyout+0x7a>
      if ((pa0 = vmfault(pagetable, psz, va0, 0)) == 0) {
    80001542:	4681                	li	a3,0
    80001544:	8626                	mv	a2,s1
    80001546:	85ee                	mv	a1,s11
    80001548:	8562                	mv	a0,s8
    8000154a:	f13ff0ef          	jal	8000145c <vmfault>
    8000154e:	892a                	mv	s2,a0
    80001550:	c139                	beqz	a0,80001596 <copyout+0xbe>
    pte = walk(pagetable, va0, 0);
    80001552:	4601                	li	a2,0
    80001554:	85a6                	mv	a1,s1
    80001556:	8562                	mv	a0,s8
    80001558:	973ff0ef          	jal	80000eca <walk>
    if ((*pte & PTE_W) == 0)
    8000155c:	611c                	ld	a5,0(a0)
    8000155e:	8b91                	andi	a5,a5,4
    80001560:	c3b1                	beqz	a5,800015a4 <copyout+0xcc>
    n = PGSIZE - (dstva - va0);
    80001562:	01a48ab3          	add	s5,s1,s10
    80001566:	416a89b3          	sub	s3,s5,s6
    if (n > len)
    8000156a:	fb3a75e3          	bgeu	s4,s3,80001514 <copyout+0x3c>
    8000156e:	89d2                	mv	s3,s4
    80001570:	b755                	j	80001514 <copyout+0x3c>
  return 0;
    80001572:	4501                	li	a0,0
    80001574:	6946                	ld	s2,80(sp)
    80001576:	69a6                	ld	s3,72(sp)
    80001578:	7ae2                	ld	s5,56(sp)
    8000157a:	6ce2                	ld	s9,24(sp)
    8000157c:	6d42                	ld	s10,16(sp)
    8000157e:	a80d                	j	800015b0 <copyout+0xd8>
    80001580:	4501                	li	a0,0
}
    80001582:	8082                	ret
      return -1;
    80001584:	557d                	li	a0,-1
    80001586:	a02d                	j	800015b0 <copyout+0xd8>
    80001588:	557d                	li	a0,-1
    8000158a:	6946                	ld	s2,80(sp)
    8000158c:	69a6                	ld	s3,72(sp)
    8000158e:	7ae2                	ld	s5,56(sp)
    80001590:	6ce2                	ld	s9,24(sp)
    80001592:	6d42                	ld	s10,16(sp)
    80001594:	a831                	j	800015b0 <copyout+0xd8>
        return -1;
    80001596:	557d                	li	a0,-1
    80001598:	6946                	ld	s2,80(sp)
    8000159a:	69a6                	ld	s3,72(sp)
    8000159c:	7ae2                	ld	s5,56(sp)
    8000159e:	6ce2                	ld	s9,24(sp)
    800015a0:	6d42                	ld	s10,16(sp)
    800015a2:	a039                	j	800015b0 <copyout+0xd8>
      return -1;
    800015a4:	557d                	li	a0,-1
    800015a6:	6946                	ld	s2,80(sp)
    800015a8:	69a6                	ld	s3,72(sp)
    800015aa:	7ae2                	ld	s5,56(sp)
    800015ac:	6ce2                	ld	s9,24(sp)
    800015ae:	6d42                	ld	s10,16(sp)
}
    800015b0:	70a6                	ld	ra,104(sp)
    800015b2:	7406                	ld	s0,96(sp)
    800015b4:	64e6                	ld	s1,88(sp)
    800015b6:	6a06                	ld	s4,64(sp)
    800015b8:	7b42                	ld	s6,48(sp)
    800015ba:	7ba2                	ld	s7,40(sp)
    800015bc:	7c02                	ld	s8,32(sp)
    800015be:	6da2                	ld	s11,8(sp)
    800015c0:	6165                	addi	sp,sp,112
    800015c2:	8082                	ret

00000000800015c4 <copyin>:
  while (len > 0) {
    800015c4:	cb49                	beqz	a4,80001656 <copyin+0x92>
{
    800015c6:	711d                	addi	sp,sp,-96
    800015c8:	ec86                	sd	ra,88(sp)
    800015ca:	e8a2                	sd	s0,80(sp)
    800015cc:	e4a6                	sd	s1,72(sp)
    800015ce:	e0ca                	sd	s2,64(sp)
    800015d0:	fc4e                	sd	s3,56(sp)
    800015d2:	f852                	sd	s4,48(sp)
    800015d4:	f456                	sd	s5,40(sp)
    800015d6:	f05a                	sd	s6,32(sp)
    800015d8:	ec5e                	sd	s7,24(sp)
    800015da:	e862                	sd	s8,16(sp)
    800015dc:	e466                	sd	s9,8(sp)
    800015de:	1080                	addi	s0,sp,96
    800015e0:	8baa                	mv	s7,a0
    800015e2:	8cae                	mv	s9,a1
    800015e4:	8ab2                	mv	s5,a2
    800015e6:	8936                	mv	s2,a3
    800015e8:	8a3a                	mv	s4,a4
    va0 = PGROUNDDOWN(srcva);
    800015ea:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800015ec:	6b05                	lui	s6,0x1
    800015ee:	a035                	j	8000161a <copyin+0x56>
    800015f0:	412984b3          	sub	s1,s3,s2
    800015f4:	94da                	add	s1,s1,s6
    if (n > len)
    800015f6:	009a7363          	bgeu	s4,s1,800015fc <copyin+0x38>
    800015fa:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800015fc:	413905b3          	sub	a1,s2,s3
    80001600:	0004861b          	sext.w	a2,s1
    80001604:	95aa                	add	a1,a1,a0
    80001606:	8556                	mv	a0,s5
    80001608:	ea8ff0ef          	jal	80000cb0 <memmove>
    len -= n;
    8000160c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001610:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001612:	01698933          	add	s2,s3,s6
  while (len > 0) {
    80001616:	020a0263          	beqz	s4,8000163a <copyin+0x76>
    va0 = PGROUNDDOWN(srcva);
    8000161a:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000161e:	85ce                	mv	a1,s3
    80001620:	855e                	mv	a0,s7
    80001622:	943ff0ef          	jal	80000f64 <walkaddr>
    if (pa0 == 0) {
    80001626:	f569                	bnez	a0,800015f0 <copyin+0x2c>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001628:	4685                	li	a3,1
    8000162a:	864e                	mv	a2,s3
    8000162c:	85e6                	mv	a1,s9
    8000162e:	855e                	mv	a0,s7
    80001630:	e2dff0ef          	jal	8000145c <vmfault>
    80001634:	fd55                	bnez	a0,800015f0 <copyin+0x2c>
        return -1;
    80001636:	557d                	li	a0,-1
    80001638:	a011                	j	8000163c <copyin+0x78>
  return 0;
    8000163a:	4501                	li	a0,0
}
    8000163c:	60e6                	ld	ra,88(sp)
    8000163e:	6446                	ld	s0,80(sp)
    80001640:	64a6                	ld	s1,72(sp)
    80001642:	6906                	ld	s2,64(sp)
    80001644:	79e2                	ld	s3,56(sp)
    80001646:	7a42                	ld	s4,48(sp)
    80001648:	7aa2                	ld	s5,40(sp)
    8000164a:	7b02                	ld	s6,32(sp)
    8000164c:	6be2                	ld	s7,24(sp)
    8000164e:	6c42                	ld	s8,16(sp)
    80001650:	6ca2                	ld	s9,8(sp)
    80001652:	6125                	addi	sp,sp,96
    80001654:	8082                	ret
  return 0;
    80001656:	4501                	li	a0,0
}
    80001658:	8082                	ret

000000008000165a <copyinstr>:
  while (got_null == 0 && max > 0) {
    8000165a:	c371                	beqz	a4,8000171e <copyinstr+0xc4>
{
    8000165c:	715d                	addi	sp,sp,-80
    8000165e:	e486                	sd	ra,72(sp)
    80001660:	e0a2                	sd	s0,64(sp)
    80001662:	fc26                	sd	s1,56(sp)
    80001664:	f84a                	sd	s2,48(sp)
    80001666:	f44e                	sd	s3,40(sp)
    80001668:	f052                	sd	s4,32(sp)
    8000166a:	ec56                	sd	s5,24(sp)
    8000166c:	e85a                	sd	s6,16(sp)
    8000166e:	e45e                	sd	s7,8(sp)
    80001670:	e062                	sd	s8,0(sp)
    80001672:	0880                	addi	s0,sp,80
    80001674:	8a2a                	mv	s4,a0
    80001676:	8b2e                	mv	s6,a1
    80001678:	8bb2                	mv	s7,a2
    8000167a:	8c36                	mv	s8,a3
    8000167c:	893a                	mv	s2,a4
    va0 = PGROUNDDOWN(srcva);
    8000167e:	7afd                	lui	s5,0xfffff
    n = PGSIZE - (srcva - va0);
    80001680:	6985                	lui	s3,0x1
    80001682:	a0b1                	j	800016ce <copyinstr+0x74>
      if ((pa0 = vmfault(pagetable, psz, va0, 1)) == 0) {
    80001684:	4685                	li	a3,1
    80001686:	8626                	mv	a2,s1
    80001688:	85da                	mv	a1,s6
    8000168a:	8552                	mv	a0,s4
    8000168c:	dd1ff0ef          	jal	8000145c <vmfault>
    80001690:	e531                	bnez	a0,800016dc <copyinstr+0x82>
        return -1;
    80001692:	557d                	li	a0,-1
    80001694:	a039                	j	800016a2 <copyinstr+0x48>
        *dst = '\0';
    80001696:	00078023          	sb	zero,0(a5) # fffffffffffff000 <end+0xffffffff7ffdc490>
    8000169a:	4785                	li	a5,1
  if (got_null) {
    8000169c:	37fd                	addiw	a5,a5,-1
    8000169e:	0007851b          	sext.w	a0,a5
}
    800016a2:	60a6                	ld	ra,72(sp)
    800016a4:	6406                	ld	s0,64(sp)
    800016a6:	74e2                	ld	s1,56(sp)
    800016a8:	7942                	ld	s2,48(sp)
    800016aa:	79a2                	ld	s3,40(sp)
    800016ac:	7a02                	ld	s4,32(sp)
    800016ae:	6ae2                	ld	s5,24(sp)
    800016b0:	6b42                	ld	s6,16(sp)
    800016b2:	6ba2                	ld	s7,8(sp)
    800016b4:	6c02                	ld	s8,0(sp)
    800016b6:	6161                	addi	sp,sp,80
    800016b8:	8082                	ret
    800016ba:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016be:	972a                	add	a4,a4,a0
      --max;
    800016c0:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    800016c4:	01348c33          	add	s8,s1,s3
  while (got_null == 0 && max > 0) {
    800016c8:	04e58563          	beq	a1,a4,80001712 <copyinstr+0xb8>
{
    800016cc:	8bbe                	mv	s7,a5
    va0 = PGROUNDDOWN(srcva);
    800016ce:	015c74b3          	and	s1,s8,s5
    pa0 = walkaddr(pagetable, va0);
    800016d2:	85a6                	mv	a1,s1
    800016d4:	8552                	mv	a0,s4
    800016d6:	88fff0ef          	jal	80000f64 <walkaddr>
    if (pa0 == 0) {
    800016da:	d54d                	beqz	a0,80001684 <copyinstr+0x2a>
    n = PGSIZE - (srcva - va0);
    800016dc:	41848633          	sub	a2,s1,s8
    800016e0:	964e                	add	a2,a2,s3
    if (n > max)
    800016e2:	00c97363          	bgeu	s2,a2,800016e8 <copyinstr+0x8e>
    800016e6:	864a                	mv	a2,s2
    char *p = (char *)(pa0 + (srcva - va0));
    800016e8:	409c0c33          	sub	s8,s8,s1
    800016ec:	9c2a                	add	s8,s8,a0
    while (n > 0) {
    800016ee:	c605                	beqz	a2,80001716 <copyinstr+0xbc>
    800016f0:	87de                	mv	a5,s7
    800016f2:	855e                	mv	a0,s7
      if (*p == '\0') {
    800016f4:	417c0733          	sub	a4,s8,s7
    while (n > 0) {
    800016f8:	965e                	add	a2,a2,s7
    800016fa:	85be                	mv	a1,a5
      if (*p == '\0') {
    800016fc:	00f706b3          	add	a3,a4,a5
    80001700:	0006c683          	lbu	a3,0(a3) # fffffffffffff000 <end+0xffffffff7ffdc490>
    80001704:	dac9                	beqz	a3,80001696 <copyinstr+0x3c>
        *dst = *p;
    80001706:	00d78023          	sb	a3,0(a5)
      dst++;
    8000170a:	0785                	addi	a5,a5,1
    while (n > 0) {
    8000170c:	fec797e3          	bne	a5,a2,800016fa <copyinstr+0xa0>
    80001710:	b76d                	j	800016ba <copyinstr+0x60>
    80001712:	4781                	li	a5,0
    80001714:	b761                	j	8000169c <copyinstr+0x42>
    srcva = va0 + PGSIZE;
    80001716:	6c05                	lui	s8,0x1
    80001718:	9c26                	add	s8,s8,s1
    8000171a:	87de                	mv	a5,s7
    8000171c:	bf45                	j	800016cc <copyinstr+0x72>
  int got_null = 0;
    8000171e:	4781                	li	a5,0
  if (got_null) {
    80001720:	37fd                	addiw	a5,a5,-1
    80001722:	0007851b          	sext.w	a0,a5
}
    80001726:	8082                	ret

0000000080001728 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001728:	7139                	addi	sp,sp,-64
    8000172a:	fc06                	sd	ra,56(sp)
    8000172c:	f822                	sd	s0,48(sp)
    8000172e:	f426                	sd	s1,40(sp)
    80001730:	f04a                	sd	s2,32(sp)
    80001732:	ec4e                	sd	s3,24(sp)
    80001734:	e852                	sd	s4,16(sp)
    80001736:	e456                	sd	s5,8(sp)
    80001738:	e05a                	sd	s6,0(sp)
    8000173a:	0080                	addi	s0,sp,64
    8000173c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000173e:	00010497          	auipc	s1,0x10
    80001742:	65248493          	addi	s1,s1,1618 # 80011d90 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001746:	8b26                	mv	s6,s1
    80001748:	04fa5937          	lui	s2,0x4fa5
    8000174c:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001750:	0932                	slli	s2,s2,0xc
    80001752:	fa590913          	addi	s2,s2,-91
    80001756:	0932                	slli	s2,s2,0xc
    80001758:	fa590913          	addi	s2,s2,-91
    8000175c:	0932                	slli	s2,s2,0xc
    8000175e:	fa590913          	addi	s2,s2,-91
    80001762:	040009b7          	lui	s3,0x4000
    80001766:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001768:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    8000176a:	00016a97          	auipc	s5,0x16
    8000176e:	026a8a93          	addi	s5,s5,38 # 80017790 <tickslock>
    char *pa = kalloc();
    80001772:	b58ff0ef          	jal	80000aca <kalloc>
    80001776:	862a                	mv	a2,a0
    if (pa == 0)
    80001778:	cd15                	beqz	a0,800017b4 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    8000177a:	416485b3          	sub	a1,s1,s6
    8000177e:	858d                	srai	a1,a1,0x3
    80001780:	032585b3          	mul	a1,a1,s2
    80001784:	2585                	addiw	a1,a1,1
    80001786:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000178a:	4719                	li	a4,6
    8000178c:	6685                	lui	a3,0x1
    8000178e:	40b985b3          	sub	a1,s3,a1
    80001792:	8552                	mv	a0,s4
    80001794:	8bfff0ef          	jal	80001052 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001798:	16848493          	addi	s1,s1,360
    8000179c:	fd549be3          	bne	s1,s5,80001772 <proc_mapstacks+0x4a>
  }
}
    800017a0:	70e2                	ld	ra,56(sp)
    800017a2:	7442                	ld	s0,48(sp)
    800017a4:	74a2                	ld	s1,40(sp)
    800017a6:	7902                	ld	s2,32(sp)
    800017a8:	69e2                	ld	s3,24(sp)
    800017aa:	6a42                	ld	s4,16(sp)
    800017ac:	6aa2                	ld	s5,8(sp)
    800017ae:	6b02                	ld	s6,0(sp)
    800017b0:	6121                	addi	sp,sp,64
    800017b2:	8082                	ret
      panic("kalloc");
    800017b4:	00006517          	auipc	a0,0x6
    800017b8:	9a450513          	addi	a0,a0,-1628 # 80007158 <etext+0x158>
    800017bc:	834ff0ef          	jal	800007f0 <panic>

00000000800017c0 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017c0:	7139                	addi	sp,sp,-64
    800017c2:	fc06                	sd	ra,56(sp)
    800017c4:	f822                	sd	s0,48(sp)
    800017c6:	f426                	sd	s1,40(sp)
    800017c8:	f04a                	sd	s2,32(sp)
    800017ca:	ec4e                	sd	s3,24(sp)
    800017cc:	e852                	sd	s4,16(sp)
    800017ce:	e456                	sd	s5,8(sp)
    800017d0:	e05a                	sd	s6,0(sp)
    800017d2:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    800017d4:	00006597          	auipc	a1,0x6
    800017d8:	98c58593          	addi	a1,a1,-1652 # 80007160 <etext+0x160>
    800017dc:	00010517          	auipc	a0,0x10
    800017e0:	18450513          	addi	a0,a0,388 # 80011960 <pid_lock>
    800017e4:	b36ff0ef          	jal	80000b1a <initlock>
  initlock(&wait_lock, "wait_lock");
    800017e8:	00006597          	auipc	a1,0x6
    800017ec:	98058593          	addi	a1,a1,-1664 # 80007168 <etext+0x168>
    800017f0:	00010517          	auipc	a0,0x10
    800017f4:	18850513          	addi	a0,a0,392 # 80011978 <wait_lock>
    800017f8:	b22ff0ef          	jal	80000b1a <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800017fc:	00010497          	auipc	s1,0x10
    80001800:	59448493          	addi	s1,s1,1428 # 80011d90 <proc>
    initlock(&p->lock, "proc");
    80001804:	00006b17          	auipc	s6,0x6
    80001808:	974b0b13          	addi	s6,s6,-1676 # 80007178 <etext+0x178>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    8000180c:	8aa6                	mv	s5,s1
    8000180e:	04fa5937          	lui	s2,0x4fa5
    80001812:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001816:	0932                	slli	s2,s2,0xc
    80001818:	fa590913          	addi	s2,s2,-91
    8000181c:	0932                	slli	s2,s2,0xc
    8000181e:	fa590913          	addi	s2,s2,-91
    80001822:	0932                	slli	s2,s2,0xc
    80001824:	fa590913          	addi	s2,s2,-91
    80001828:	040009b7          	lui	s3,0x4000
    8000182c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000182e:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001830:	00016a17          	auipc	s4,0x16
    80001834:	f60a0a13          	addi	s4,s4,-160 # 80017790 <tickslock>
    initlock(&p->lock, "proc");
    80001838:	85da                	mv	a1,s6
    8000183a:	8526                	mv	a0,s1
    8000183c:	adeff0ef          	jal	80000b1a <initlock>
    p->state = UNUSED;
    80001840:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001844:	415487b3          	sub	a5,s1,s5
    80001848:	878d                	srai	a5,a5,0x3
    8000184a:	032787b3          	mul	a5,a5,s2
    8000184e:	2785                	addiw	a5,a5,1
    80001850:	00d7979b          	slliw	a5,a5,0xd
    80001854:	40f987b3          	sub	a5,s3,a5
    80001858:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000185a:	16848493          	addi	s1,s1,360
    8000185e:	fd449de3          	bne	s1,s4,80001838 <procinit+0x78>
  }
}
    80001862:	70e2                	ld	ra,56(sp)
    80001864:	7442                	ld	s0,48(sp)
    80001866:	74a2                	ld	s1,40(sp)
    80001868:	7902                	ld	s2,32(sp)
    8000186a:	69e2                	ld	s3,24(sp)
    8000186c:	6a42                	ld	s4,16(sp)
    8000186e:	6aa2                	ld	s5,8(sp)
    80001870:	6b02                	ld	s6,0(sp)
    80001872:	6121                	addi	sp,sp,64
    80001874:	8082                	ret

0000000080001876 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001876:	1141                	addi	sp,sp,-16
    80001878:	e422                	sd	s0,8(sp)
    8000187a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r"(x));
    8000187c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000187e:	2501                	sext.w	a0,a0
    80001880:	6422                	ld	s0,8(sp)
    80001882:	0141                	addi	sp,sp,16
    80001884:	8082                	ret

0000000080001886 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *
mycpu(void)
{
    80001886:	1141                	addi	sp,sp,-16
    80001888:	e422                	sd	s0,8(sp)
    8000188a:	0800                	addi	s0,sp,16
    8000188c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000188e:	2781                	sext.w	a5,a5
    80001890:	079e                	slli	a5,a5,0x7
  return c;
}
    80001892:	00010517          	auipc	a0,0x10
    80001896:	0fe50513          	addi	a0,a0,254 # 80011990 <cpus>
    8000189a:	953e                	add	a0,a0,a5
    8000189c:	6422                	ld	s0,8(sp)
    8000189e:	0141                	addi	sp,sp,16
    800018a0:	8082                	ret

00000000800018a2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *
myproc(void)
{
    800018a2:	1101                	addi	sp,sp,-32
    800018a4:	ec06                	sd	ra,24(sp)
    800018a6:	e822                	sd	s0,16(sp)
    800018a8:	e426                	sd	s1,8(sp)
    800018aa:	1000                	addi	s0,sp,32
  push_off();
    800018ac:	aaeff0ef          	jal	80000b5a <push_off>
    800018b0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018b2:	2781                	sext.w	a5,a5
    800018b4:	079e                	slli	a5,a5,0x7
    800018b6:	00010717          	auipc	a4,0x10
    800018ba:	0aa70713          	addi	a4,a4,170 # 80011960 <pid_lock>
    800018be:	97ba                	add	a5,a5,a4
    800018c0:	7b84                	ld	s1,48(a5)
  pop_off();
    800018c2:	b0eff0ef          	jal	80000bd0 <pop_off>
  return p;
}
    800018c6:	8526                	mv	a0,s1
    800018c8:	60e2                	ld	ra,24(sp)
    800018ca:	6442                	ld	s0,16(sp)
    800018cc:	64a2                	ld	s1,8(sp)
    800018ce:	6105                	addi	sp,sp,32
    800018d0:	8082                	ret

00000000800018d2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800018d2:	7179                	addi	sp,sp,-48
    800018d4:	f406                	sd	ra,40(sp)
    800018d6:	f022                	sd	s0,32(sp)
    800018d8:	ec26                	sd	s1,24(sp)
    800018da:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800018dc:	fc7ff0ef          	jal	800018a2 <myproc>
    800018e0:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800018e2:	b3aff0ef          	jal	80000c1c <release>

  if (__atomic_load_n(&first, __ATOMIC_ACQUIRE)) {
    800018e6:	00008797          	auipc	a5,0x8
    800018ea:	f0a78793          	addi	a5,a5,-246 # 800097f0 <first.1>
    800018ee:	439c                	lw	a5,0(a5)
    800018f0:	0230000f          	fence	r,rw
    800018f4:	2781                	sext.w	a5,a5
    800018f6:	cf9d                	beqz	a5,80001934 <forkret+0x62>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800018f8:	4505                	li	a0,1
    800018fa:	43f010ef          	jal	80003538 <fsinit>

    // ensure other cores see first=0.
    __atomic_store_n(&first, 0, __ATOMIC_RELEASE);
    800018fe:	00008797          	auipc	a5,0x8
    80001902:	ef278793          	addi	a5,a5,-270 # 800097f0 <first.1>
    80001906:	0310000f          	fence	rw,w
    8000190a:	0007a023          	sw	zero,0(a5)

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    8000190e:	00006517          	auipc	a0,0x6
    80001912:	87250513          	addi	a0,a0,-1934 # 80007180 <etext+0x180>
    80001916:	fca43823          	sd	a0,-48(s0)
    8000191a:	fc043c23          	sd	zero,-40(s0)
    8000191e:	fd040593          	addi	a1,s0,-48
    80001922:	61f020ef          	jal	80004740 <kexec>
    80001926:	6cbc                	ld	a5,88(s1)
    80001928:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    8000192a:	6cbc                	ld	a5,88(s1)
    8000192c:	7bb8                	ld	a4,112(a5)
    8000192e:	57fd                	li	a5,-1
    80001930:	02f70d63          	beq	a4,a5,8000196a <forkret+0x98>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001934:	2f3000ef          	jal	80002426 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001938:	68a8                	ld	a0,80(s1)
    8000193a:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000193c:	04000737          	lui	a4,0x4000
    80001940:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001942:	0732                	slli	a4,a4,0xc
    80001944:	00004797          	auipc	a5,0x4
    80001948:	75878793          	addi	a5,a5,1880 # 8000609c <userret>
    8000194c:	00004697          	auipc	a3,0x4
    80001950:	6b468693          	addi	a3,a3,1716 # 80006000 <_trampoline>
    80001954:	8f95                	sub	a5,a5,a3
    80001956:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001958:	577d                	li	a4,-1
    8000195a:	177e                	slli	a4,a4,0x3f
    8000195c:	8d59                	or	a0,a0,a4
    8000195e:	9782                	jalr	a5
}
    80001960:	70a2                	ld	ra,40(sp)
    80001962:	7402                	ld	s0,32(sp)
    80001964:	64e2                	ld	s1,24(sp)
    80001966:	6145                	addi	sp,sp,48
    80001968:	8082                	ret
      panic("exec");
    8000196a:	00006517          	auipc	a0,0x6
    8000196e:	81e50513          	addi	a0,a0,-2018 # 80007188 <etext+0x188>
    80001972:	e7ffe0ef          	jal	800007f0 <panic>

0000000080001976 <allocpid>:
{
    80001976:	1101                	addi	sp,sp,-32
    80001978:	ec06                	sd	ra,24(sp)
    8000197a:	e822                	sd	s0,16(sp)
    8000197c:	e426                	sd	s1,8(sp)
    8000197e:	e04a                	sd	s2,0(sp)
    80001980:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001982:	00010917          	auipc	s2,0x10
    80001986:	fde90913          	addi	s2,s2,-34 # 80011960 <pid_lock>
    8000198a:	854a                	mv	a0,s2
    8000198c:	a04ff0ef          	jal	80000b90 <acquire>
  pid = nextpid;
    80001990:	00008797          	auipc	a5,0x8
    80001994:	e6478793          	addi	a5,a5,-412 # 800097f4 <nextpid>
    80001998:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000199a:	0014871b          	addiw	a4,s1,1
    8000199e:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800019a0:	854a                	mv	a0,s2
    800019a2:	a7aff0ef          	jal	80000c1c <release>
}
    800019a6:	8526                	mv	a0,s1
    800019a8:	60e2                	ld	ra,24(sp)
    800019aa:	6442                	ld	s0,16(sp)
    800019ac:	64a2                	ld	s1,8(sp)
    800019ae:	6902                	ld	s2,0(sp)
    800019b0:	6105                	addi	sp,sp,32
    800019b2:	8082                	ret

00000000800019b4 <proc_pagetable>:
{
    800019b4:	1101                	addi	sp,sp,-32
    800019b6:	ec06                	sd	ra,24(sp)
    800019b8:	e822                	sd	s0,16(sp)
    800019ba:	e426                	sd	s1,8(sp)
    800019bc:	e04a                	sd	s2,0(sp)
    800019be:	1000                	addi	s0,sp,32
    800019c0:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800019c2:	f86ff0ef          	jal	80001148 <uvmcreate>
    800019c6:	84aa                	mv	s1,a0
  if (pagetable == 0)
    800019c8:	cd05                	beqz	a0,80001a00 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    800019ca:	4729                	li	a4,10
    800019cc:	00004697          	auipc	a3,0x4
    800019d0:	63468693          	addi	a3,a3,1588 # 80006000 <_trampoline>
    800019d4:	6605                	lui	a2,0x1
    800019d6:	040005b7          	lui	a1,0x4000
    800019da:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019dc:	05b2                	slli	a1,a1,0xc
    800019de:	dc4ff0ef          	jal	80000fa2 <mappages>
    800019e2:	02054663          	bltz	a0,80001a0e <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    800019e6:	4719                	li	a4,6
    800019e8:	05893683          	ld	a3,88(s2)
    800019ec:	6605                	lui	a2,0x1
    800019ee:	020005b7          	lui	a1,0x2000
    800019f2:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019f4:	05b6                	slli	a1,a1,0xd
    800019f6:	8526                	mv	a0,s1
    800019f8:	daaff0ef          	jal	80000fa2 <mappages>
    800019fc:	00054f63          	bltz	a0,80001a1a <proc_pagetable+0x66>
}
    80001a00:	8526                	mv	a0,s1
    80001a02:	60e2                	ld	ra,24(sp)
    80001a04:	6442                	ld	s0,16(sp)
    80001a06:	64a2                	ld	s1,8(sp)
    80001a08:	6902                	ld	s2,0(sp)
    80001a0a:	6105                	addi	sp,sp,32
    80001a0c:	8082                	ret
    uvmfree(pagetable, 0);
    80001a0e:	4581                	li	a1,0
    80001a10:	8526                	mv	a0,s1
    80001a12:	931ff0ef          	jal	80001342 <uvmfree>
    return 0;
    80001a16:	4481                	li	s1,0
    80001a18:	b7e5                	j	80001a00 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1a:	4681                	li	a3,0
    80001a1c:	4605                	li	a2,1
    80001a1e:	040005b7          	lui	a1,0x4000
    80001a22:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a24:	05b2                	slli	a1,a1,0xc
    80001a26:	8526                	mv	a0,s1
    80001a28:	f46ff0ef          	jal	8000116e <uvmunmap>
    uvmfree(pagetable, 0);
    80001a2c:	4581                	li	a1,0
    80001a2e:	8526                	mv	a0,s1
    80001a30:	913ff0ef          	jal	80001342 <uvmfree>
    return 0;
    80001a34:	4481                	li	s1,0
    80001a36:	b7e9                	j	80001a00 <proc_pagetable+0x4c>

0000000080001a38 <proc_freepagetable>:
{
    80001a38:	1101                	addi	sp,sp,-32
    80001a3a:	ec06                	sd	ra,24(sp)
    80001a3c:	e822                	sd	s0,16(sp)
    80001a3e:	e426                	sd	s1,8(sp)
    80001a40:	e04a                	sd	s2,0(sp)
    80001a42:	1000                	addi	s0,sp,32
    80001a44:	84aa                	mv	s1,a0
    80001a46:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a48:	4681                	li	a3,0
    80001a4a:	4605                	li	a2,1
    80001a4c:	040005b7          	lui	a1,0x4000
    80001a50:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a52:	05b2                	slli	a1,a1,0xc
    80001a54:	f1aff0ef          	jal	8000116e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a58:	4681                	li	a3,0
    80001a5a:	4605                	li	a2,1
    80001a5c:	020005b7          	lui	a1,0x2000
    80001a60:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a62:	05b6                	slli	a1,a1,0xd
    80001a64:	8526                	mv	a0,s1
    80001a66:	f08ff0ef          	jal	8000116e <uvmunmap>
  uvmfree(pagetable, sz);
    80001a6a:	85ca                	mv	a1,s2
    80001a6c:	8526                	mv	a0,s1
    80001a6e:	8d5ff0ef          	jal	80001342 <uvmfree>
}
    80001a72:	60e2                	ld	ra,24(sp)
    80001a74:	6442                	ld	s0,16(sp)
    80001a76:	64a2                	ld	s1,8(sp)
    80001a78:	6902                	ld	s2,0(sp)
    80001a7a:	6105                	addi	sp,sp,32
    80001a7c:	8082                	ret

0000000080001a7e <freeproc>:
{
    80001a7e:	1101                	addi	sp,sp,-32
    80001a80:	ec06                	sd	ra,24(sp)
    80001a82:	e822                	sd	s0,16(sp)
    80001a84:	e426                	sd	s1,8(sp)
    80001a86:	1000                	addi	s0,sp,32
    80001a88:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001a8a:	6d28                	ld	a0,88(a0)
    80001a8c:	c119                	beqz	a0,80001a92 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001a8e:	f5bfe0ef          	jal	800009e8 <kfree>
  p->trapframe = 0;
    80001a92:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001a96:	68a8                	ld	a0,80(s1)
    80001a98:	c501                	beqz	a0,80001aa0 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a9a:	64ac                	ld	a1,72(s1)
    80001a9c:	f9dff0ef          	jal	80001a38 <proc_freepagetable>
  p->pagetable = 0;
    80001aa0:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001aa4:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001aa8:	0204a823          	sw	zero,48(s1)
  p->name[0] = 0;
    80001aac:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001ab0:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ab4:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ab8:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001abc:	0004ac23          	sw	zero,24(s1)
}
    80001ac0:	60e2                	ld	ra,24(sp)
    80001ac2:	6442                	ld	s0,16(sp)
    80001ac4:	64a2                	ld	s1,8(sp)
    80001ac6:	6105                	addi	sp,sp,32
    80001ac8:	8082                	ret

0000000080001aca <allocproc>:
{
    80001aca:	1101                	addi	sp,sp,-32
    80001acc:	ec06                	sd	ra,24(sp)
    80001ace:	e822                	sd	s0,16(sp)
    80001ad0:	e426                	sd	s1,8(sp)
    80001ad2:	e04a                	sd	s2,0(sp)
    80001ad4:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ad6:	00010497          	auipc	s1,0x10
    80001ada:	2ba48493          	addi	s1,s1,698 # 80011d90 <proc>
    80001ade:	00016917          	auipc	s2,0x16
    80001ae2:	cb290913          	addi	s2,s2,-846 # 80017790 <tickslock>
    acquire(&p->lock);
    80001ae6:	8526                	mv	a0,s1
    80001ae8:	8a8ff0ef          	jal	80000b90 <acquire>
    if (p->state == UNUSED) {
    80001aec:	4c9c                	lw	a5,24(s1)
    80001aee:	cb91                	beqz	a5,80001b02 <allocproc+0x38>
      release(&p->lock);
    80001af0:	8526                	mv	a0,s1
    80001af2:	92aff0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001af6:	16848493          	addi	s1,s1,360
    80001afa:	ff2496e3          	bne	s1,s2,80001ae6 <allocproc+0x1c>
  return 0;
    80001afe:	4481                	li	s1,0
    80001b00:	a089                	j	80001b42 <allocproc+0x78>
  p->pid = allocpid();
    80001b02:	e75ff0ef          	jal	80001976 <allocpid>
    80001b06:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001b08:	4785                	li	a5,1
    80001b0a:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001b0c:	fbffe0ef          	jal	80000aca <kalloc>
    80001b10:	892a                	mv	s2,a0
    80001b12:	eca8                	sd	a0,88(s1)
    80001b14:	cd15                	beqz	a0,80001b50 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001b16:	8526                	mv	a0,s1
    80001b18:	e9dff0ef          	jal	800019b4 <proc_pagetable>
    80001b1c:	892a                	mv	s2,a0
    80001b1e:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001b20:	c121                	beqz	a0,80001b60 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001b22:	07000613          	li	a2,112
    80001b26:	4581                	li	a1,0
    80001b28:	06048513          	addi	a0,s1,96
    80001b2c:	928ff0ef          	jal	80000c54 <memset>
  p->context.ra = (uint64)forkret;
    80001b30:	00000797          	auipc	a5,0x0
    80001b34:	da278793          	addi	a5,a5,-606 # 800018d2 <forkret>
    80001b38:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b3a:	60bc                	ld	a5,64(s1)
    80001b3c:	6705                	lui	a4,0x1
    80001b3e:	97ba                	add	a5,a5,a4
    80001b40:	f4bc                	sd	a5,104(s1)
}
    80001b42:	8526                	mv	a0,s1
    80001b44:	60e2                	ld	ra,24(sp)
    80001b46:	6442                	ld	s0,16(sp)
    80001b48:	64a2                	ld	s1,8(sp)
    80001b4a:	6902                	ld	s2,0(sp)
    80001b4c:	6105                	addi	sp,sp,32
    80001b4e:	8082                	ret
    freeproc(p);
    80001b50:	8526                	mv	a0,s1
    80001b52:	f2dff0ef          	jal	80001a7e <freeproc>
    release(&p->lock);
    80001b56:	8526                	mv	a0,s1
    80001b58:	8c4ff0ef          	jal	80000c1c <release>
    return 0;
    80001b5c:	84ca                	mv	s1,s2
    80001b5e:	b7d5                	j	80001b42 <allocproc+0x78>
    freeproc(p);
    80001b60:	8526                	mv	a0,s1
    80001b62:	f1dff0ef          	jal	80001a7e <freeproc>
    release(&p->lock);
    80001b66:	8526                	mv	a0,s1
    80001b68:	8b4ff0ef          	jal	80000c1c <release>
    return 0;
    80001b6c:	84ca                	mv	s1,s2
    80001b6e:	bfd1                	j	80001b42 <allocproc+0x78>

0000000080001b70 <userinit>:
{
    80001b70:	1101                	addi	sp,sp,-32
    80001b72:	ec06                	sd	ra,24(sp)
    80001b74:	e822                	sd	s0,16(sp)
    80001b76:	e426                	sd	s1,8(sp)
    80001b78:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b7a:	f51ff0ef          	jal	80001aca <allocproc>
    80001b7e:	84aa                	mv	s1,a0
  initproc = p;
    80001b80:	00008797          	auipc	a5,0x8
    80001b84:	caa7bc23          	sd	a0,-840(a5) # 80009838 <initproc>
  p->cwd = namei("/");
    80001b88:	00005517          	auipc	a0,0x5
    80001b8c:	60850513          	addi	a0,a0,1544 # 80007190 <etext+0x190>
    80001b90:	6e1010ef          	jal	80003a70 <namei>
    80001b94:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001b98:	478d                	li	a5,3
    80001b9a:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001b9c:	8526                	mv	a0,s1
    80001b9e:	87eff0ef          	jal	80000c1c <release>
}
    80001ba2:	60e2                	ld	ra,24(sp)
    80001ba4:	6442                	ld	s0,16(sp)
    80001ba6:	64a2                	ld	s1,8(sp)
    80001ba8:	6105                	addi	sp,sp,32
    80001baa:	8082                	ret

0000000080001bac <growproc>:
{
    80001bac:	1101                	addi	sp,sp,-32
    80001bae:	ec06                	sd	ra,24(sp)
    80001bb0:	e822                	sd	s0,16(sp)
    80001bb2:	e426                	sd	s1,8(sp)
    80001bb4:	e04a                	sd	s2,0(sp)
    80001bb6:	1000                	addi	s0,sp,32
    80001bb8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001bba:	ce9ff0ef          	jal	800018a2 <myproc>
    80001bbe:	892a                	mv	s2,a0
  sz = p->sz;
    80001bc0:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001bc2:	02905963          	blez	s1,80001bf4 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001bc6:	00b48633          	add	a2,s1,a1
    80001bca:	020007b7          	lui	a5,0x2000
    80001bce:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001bd0:	07b6                	slli	a5,a5,0xd
    80001bd2:	02c7ea63          	bltu	a5,a2,80001c06 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bd6:	4691                	li	a3,4
    80001bd8:	6928                	ld	a0,80(a0)
    80001bda:	e62ff0ef          	jal	8000123c <uvmalloc>
    80001bde:	85aa                	mv	a1,a0
    80001be0:	c50d                	beqz	a0,80001c0a <growproc+0x5e>
  p->sz = sz;
    80001be2:	04b93423          	sd	a1,72(s2)
  return 0;
    80001be6:	4501                	li	a0,0
}
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret
  } else if (n < 0) {
    80001bf4:	fe04d7e3          	bgez	s1,80001be2 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001bf8:	00b48633          	add	a2,s1,a1
    80001bfc:	6928                	ld	a0,80(a0)
    80001bfe:	dfaff0ef          	jal	800011f8 <uvmdealloc>
    80001c02:	85aa                	mv	a1,a0
    80001c04:	bff9                	j	80001be2 <growproc+0x36>
      return -1;
    80001c06:	557d                	li	a0,-1
    80001c08:	b7c5                	j	80001be8 <growproc+0x3c>
      return -1;
    80001c0a:	557d                	li	a0,-1
    80001c0c:	bff1                	j	80001be8 <growproc+0x3c>

0000000080001c0e <kfork>:
{
    80001c0e:	7139                	addi	sp,sp,-64
    80001c10:	fc06                	sd	ra,56(sp)
    80001c12:	f822                	sd	s0,48(sp)
    80001c14:	f04a                	sd	s2,32(sp)
    80001c16:	e456                	sd	s5,8(sp)
    80001c18:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c1a:	c89ff0ef          	jal	800018a2 <myproc>
    80001c1e:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001c20:	eabff0ef          	jal	80001aca <allocproc>
    80001c24:	0e050a63          	beqz	a0,80001d18 <kfork+0x10a>
    80001c28:	e852                	sd	s4,16(sp)
    80001c2a:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001c2c:	048ab603          	ld	a2,72(s5)
    80001c30:	692c                	ld	a1,80(a0)
    80001c32:	050ab503          	ld	a0,80(s5)
    80001c36:	f3eff0ef          	jal	80001374 <uvmcopy>
    80001c3a:	04054a63          	bltz	a0,80001c8e <kfork+0x80>
    80001c3e:	f426                	sd	s1,40(sp)
    80001c40:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001c42:	048ab783          	ld	a5,72(s5)
    80001c46:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001c4a:	058ab683          	ld	a3,88(s5)
    80001c4e:	87b6                	mv	a5,a3
    80001c50:	058a3703          	ld	a4,88(s4)
    80001c54:	12068693          	addi	a3,a3,288
    80001c58:	0007b803          	ld	a6,0(a5)
    80001c5c:	6788                	ld	a0,8(a5)
    80001c5e:	6b8c                	ld	a1,16(a5)
    80001c60:	6f90                	ld	a2,24(a5)
    80001c62:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001c66:	e708                	sd	a0,8(a4)
    80001c68:	eb0c                	sd	a1,16(a4)
    80001c6a:	ef10                	sd	a2,24(a4)
    80001c6c:	02078793          	addi	a5,a5,32
    80001c70:	02070713          	addi	a4,a4,32
    80001c74:	fed792e3          	bne	a5,a3,80001c58 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001c78:	058a3783          	ld	a5,88(s4)
    80001c7c:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001c80:	0d0a8493          	addi	s1,s5,208
    80001c84:	0d0a0913          	addi	s2,s4,208
    80001c88:	150a8993          	addi	s3,s5,336
    80001c8c:	a831                	j	80001ca8 <kfork+0x9a>
    freeproc(np);
    80001c8e:	8552                	mv	a0,s4
    80001c90:	defff0ef          	jal	80001a7e <freeproc>
    release(&np->lock);
    80001c94:	8552                	mv	a0,s4
    80001c96:	f87fe0ef          	jal	80000c1c <release>
    return -1;
    80001c9a:	597d                	li	s2,-1
    80001c9c:	6a42                	ld	s4,16(sp)
    80001c9e:	a0b5                	j	80001d0a <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001ca0:	04a1                	addi	s1,s1,8
    80001ca2:	0921                	addi	s2,s2,8
    80001ca4:	01348963          	beq	s1,s3,80001cb6 <kfork+0xa8>
    if (p->ofile[i])
    80001ca8:	6088                	ld	a0,0(s1)
    80001caa:	d97d                	beqz	a0,80001ca0 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80001cac:	3fe020ef          	jal	800040aa <filedup>
    80001cb0:	00a93023          	sd	a0,0(s2)
    80001cb4:	b7f5                	j	80001ca0 <kfork+0x92>
  np->cwd = idup(p->cwd);
    80001cb6:	150ab503          	ld	a0,336(s5)
    80001cba:	50c010ef          	jal	800031c6 <idup>
    80001cbe:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001cc2:	4641                	li	a2,16
    80001cc4:	158a8593          	addi	a1,s5,344
    80001cc8:	158a0513          	addi	a0,s4,344
    80001ccc:	8c6ff0ef          	jal	80000d92 <safestrcpy>
  pid = np->pid;
    80001cd0:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001cd4:	8552                	mv	a0,s4
    80001cd6:	f47fe0ef          	jal	80000c1c <release>
  acquire(&wait_lock);
    80001cda:	00010497          	auipc	s1,0x10
    80001cde:	c9e48493          	addi	s1,s1,-866 # 80011978 <wait_lock>
    80001ce2:	8526                	mv	a0,s1
    80001ce4:	eadfe0ef          	jal	80000b90 <acquire>
  np->parent = p;
    80001ce8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001cec:	8526                	mv	a0,s1
    80001cee:	f2ffe0ef          	jal	80000c1c <release>
  acquire(&np->lock);
    80001cf2:	8552                	mv	a0,s4
    80001cf4:	e9dfe0ef          	jal	80000b90 <acquire>
  np->state = RUNNABLE;
    80001cf8:	478d                	li	a5,3
    80001cfa:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001cfe:	8552                	mv	a0,s4
    80001d00:	f1dfe0ef          	jal	80000c1c <release>
  return pid;
    80001d04:	74a2                	ld	s1,40(sp)
    80001d06:	69e2                	ld	s3,24(sp)
    80001d08:	6a42                	ld	s4,16(sp)
}
    80001d0a:	854a                	mv	a0,s2
    80001d0c:	70e2                	ld	ra,56(sp)
    80001d0e:	7442                	ld	s0,48(sp)
    80001d10:	7902                	ld	s2,32(sp)
    80001d12:	6aa2                	ld	s5,8(sp)
    80001d14:	6121                	addi	sp,sp,64
    80001d16:	8082                	ret
    return -1;
    80001d18:	597d                	li	s2,-1
    80001d1a:	bfc5                	j	80001d0a <kfork+0xfc>

0000000080001d1c <scheduler>:
{
    80001d1c:	711d                	addi	sp,sp,-96
    80001d1e:	ec86                	sd	ra,88(sp)
    80001d20:	e8a2                	sd	s0,80(sp)
    80001d22:	e4a6                	sd	s1,72(sp)
    80001d24:	e0ca                	sd	s2,64(sp)
    80001d26:	fc4e                	sd	s3,56(sp)
    80001d28:	f852                	sd	s4,48(sp)
    80001d2a:	f456                	sd	s5,40(sp)
    80001d2c:	f05a                	sd	s6,32(sp)
    80001d2e:	ec5e                	sd	s7,24(sp)
    80001d30:	e862                	sd	s8,16(sp)
    80001d32:	e466                	sd	s9,8(sp)
    80001d34:	1080                	addi	s0,sp,96
    80001d36:	8792                	mv	a5,tp
  int id = r_tp();
    80001d38:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d3a:	00779a93          	slli	s5,a5,0x7
    80001d3e:	00010717          	auipc	a4,0x10
    80001d42:	c2270713          	addi	a4,a4,-990 # 80011960 <pid_lock>
    80001d46:	9756                	add	a4,a4,s5
    80001d48:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001d4c:	00010717          	auipc	a4,0x10
    80001d50:	c4c70713          	addi	a4,a4,-948 # 80011998 <cpus+0x8>
    80001d54:	9aba                	add	s5,s5,a4
        p->state = RUNNING;
    80001d56:	4c11                	li	s8,4
        c->proc = p;
    80001d58:	00010b17          	auipc	s6,0x10
    80001d5c:	c08b0b13          	addi	s6,s6,-1016 # 80011960 <pid_lock>
    80001d60:	079e                	slli	a5,a5,0x7
    80001d62:	00fb0a33          	add	s4,s6,a5
        found = 1;
    80001d66:	4b85                	li	s7,1
    for (p = proc; p < &proc[NPROC]; p++) {
    80001d68:	00016997          	auipc	s3,0x16
    80001d6c:	a2898993          	addi	s3,s3,-1496 # 80017790 <tickslock>
    80001d70:	a0a9                	j	80001dba <scheduler+0x9e>
      release(&p->lock);
    80001d72:	8526                	mv	a0,s1
    80001d74:	ea9fe0ef          	jal	80000c1c <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001d78:	16848493          	addi	s1,s1,360
    80001d7c:	03348b63          	beq	s1,s3,80001db2 <scheduler+0x96>
      acquire(&p->lock);
    80001d80:	8526                	mv	a0,s1
    80001d82:	e0ffe0ef          	jal	80000b90 <acquire>
      if (p->state == RUNNABLE) {
    80001d86:	4c9c                	lw	a5,24(s1)
    80001d88:	ff2795e3          	bne	a5,s2,80001d72 <scheduler+0x56>
        p->state = RUNNING;
    80001d8c:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001d90:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001d94:	06048593          	addi	a1,s1,96
    80001d98:	8556                	mv	a0,s5
    80001d9a:	5e6000ef          	jal	80002380 <swtch>
    80001d9e:	8792                	mv	a5,tp
        mycpu()->intena = 0;
    80001da0:	2781                	sext.w	a5,a5
    80001da2:	079e                	slli	a5,a5,0x7
    80001da4:	97da                	add	a5,a5,s6
    80001da6:	0a07a623          	sw	zero,172(a5)
        c->proc = 0;
    80001daa:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001dae:	8cde                	mv	s9,s7
    80001db0:	b7c9                	j	80001d72 <scheduler+0x56>
    if (found == 0) {
    80001db2:	000c9463          	bnez	s9,80001dba <scheduler+0x9e>
      asm volatile("wfi");
    80001db6:	10500073          	wfi
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80001dba:	10016073          	csrsi	sstatus,2
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80001dbe:	10017073          	csrci	sstatus,2
    int found = 0;
    80001dc2:	4c81                	li	s9,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001dc4:	00010497          	auipc	s1,0x10
    80001dc8:	fcc48493          	addi	s1,s1,-52 # 80011d90 <proc>
      if (p->state == RUNNABLE) {
    80001dcc:	490d                	li	s2,3
    80001dce:	bf4d                	j	80001d80 <scheduler+0x64>

0000000080001dd0 <sched>:
{
    80001dd0:	7179                	addi	sp,sp,-48
    80001dd2:	f406                	sd	ra,40(sp)
    80001dd4:	f022                	sd	s0,32(sp)
    80001dd6:	ec26                	sd	s1,24(sp)
    80001dd8:	e84a                	sd	s2,16(sp)
    80001dda:	e44e                	sd	s3,8(sp)
    80001ddc:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001dde:	ac5ff0ef          	jal	800018a2 <myproc>
    80001de2:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001de4:	d4dfe0ef          	jal	80000b30 <holding>
    80001de8:	c92d                	beqz	a0,80001e5a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r"(x));
    80001dea:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001dec:	2781                	sext.w	a5,a5
    80001dee:	079e                	slli	a5,a5,0x7
    80001df0:	00010717          	auipc	a4,0x10
    80001df4:	b7070713          	addi	a4,a4,-1168 # 80011960 <pid_lock>
    80001df8:	97ba                	add	a5,a5,a4
    80001dfa:	0a87a703          	lw	a4,168(a5)
    80001dfe:	4785                	li	a5,1
    80001e00:	06f71363          	bne	a4,a5,80001e66 <sched+0x96>
  if (p->state == RUNNING)
    80001e04:	4c98                	lw	a4,24(s1)
    80001e06:	4791                	li	a5,4
    80001e08:	06f70563          	beq	a4,a5,80001e72 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    80001e0c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e10:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001e12:	e7b5                	bnez	a5,80001e7e <sched+0xae>
  asm volatile("mv %0, tp" : "=r"(x));
    80001e14:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e16:	00010917          	auipc	s2,0x10
    80001e1a:	b4a90913          	addi	s2,s2,-1206 # 80011960 <pid_lock>
    80001e1e:	2781                	sext.w	a5,a5
    80001e20:	079e                	slli	a5,a5,0x7
    80001e22:	97ca                	add	a5,a5,s2
    80001e24:	0ac7a983          	lw	s3,172(a5)
    80001e28:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001e2a:	2781                	sext.w	a5,a5
    80001e2c:	079e                	slli	a5,a5,0x7
    80001e2e:	00010597          	auipc	a1,0x10
    80001e32:	b6a58593          	addi	a1,a1,-1174 # 80011998 <cpus+0x8>
    80001e36:	95be                	add	a1,a1,a5
    80001e38:	06048513          	addi	a0,s1,96
    80001e3c:	544000ef          	jal	80002380 <swtch>
    80001e40:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001e42:	2781                	sext.w	a5,a5
    80001e44:	079e                	slli	a5,a5,0x7
    80001e46:	993e                	add	s2,s2,a5
    80001e48:	0b392623          	sw	s3,172(s2)
}
    80001e4c:	70a2                	ld	ra,40(sp)
    80001e4e:	7402                	ld	s0,32(sp)
    80001e50:	64e2                	ld	s1,24(sp)
    80001e52:	6942                	ld	s2,16(sp)
    80001e54:	69a2                	ld	s3,8(sp)
    80001e56:	6145                	addi	sp,sp,48
    80001e58:	8082                	ret
    panic("sched p->lock");
    80001e5a:	00005517          	auipc	a0,0x5
    80001e5e:	33e50513          	addi	a0,a0,830 # 80007198 <etext+0x198>
    80001e62:	98ffe0ef          	jal	800007f0 <panic>
    panic("sched locks");
    80001e66:	00005517          	auipc	a0,0x5
    80001e6a:	34250513          	addi	a0,a0,834 # 800071a8 <etext+0x1a8>
    80001e6e:	983fe0ef          	jal	800007f0 <panic>
    panic("sched RUNNING");
    80001e72:	00005517          	auipc	a0,0x5
    80001e76:	34650513          	addi	a0,a0,838 # 800071b8 <etext+0x1b8>
    80001e7a:	977fe0ef          	jal	800007f0 <panic>
    panic("sched interruptible");
    80001e7e:	00005517          	auipc	a0,0x5
    80001e82:	34a50513          	addi	a0,a0,842 # 800071c8 <etext+0x1c8>
    80001e86:	96bfe0ef          	jal	800007f0 <panic>

0000000080001e8a <yield>:
{
    80001e8a:	1101                	addi	sp,sp,-32
    80001e8c:	ec06                	sd	ra,24(sp)
    80001e8e:	e822                	sd	s0,16(sp)
    80001e90:	e426                	sd	s1,8(sp)
    80001e92:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001e94:	a0fff0ef          	jal	800018a2 <myproc>
    80001e98:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001e9a:	cf7fe0ef          	jal	80000b90 <acquire>
  p->state = RUNNABLE;
    80001e9e:	478d                	li	a5,3
    80001ea0:	cc9c                	sw	a5,24(s1)
  sched();
    80001ea2:	f2fff0ef          	jal	80001dd0 <sched>
  release(&p->lock);
    80001ea6:	8526                	mv	a0,s1
    80001ea8:	d75fe0ef          	jal	80000c1c <release>
}
    80001eac:	60e2                	ld	ra,24(sp)
    80001eae:	6442                	ld	s0,16(sp)
    80001eb0:	64a2                	ld	s1,8(sp)
    80001eb2:	6105                	addi	sp,sp,32
    80001eb4:	8082                	ret

0000000080001eb6 <sleep_prepare>:

// Register current process as waiting for wakeups on chan.
void
sleep_prepare(void *chan)
{
    80001eb6:	1101                	addi	sp,sp,-32
    80001eb8:	ec06                	sd	ra,24(sp)
    80001eba:	e822                	sd	s0,16(sp)
    80001ebc:	e426                	sd	s1,8(sp)
    80001ebe:	e04a                	sd	s2,0(sp)
    80001ec0:	1000                	addi	s0,sp,32
    80001ec2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ec4:	9dfff0ef          	jal	800018a2 <myproc>
    80001ec8:	892a                	mv	s2,a0

  acquire(&p->lock);
    80001eca:	cc7fe0ef          	jal	80000b90 <acquire>
  if (chan == 0)
    80001ece:	cc81                	beqz	s1,80001ee6 <sleep_prepare+0x30>
    panic("sleep_prepare: zero chan");
  p->chan = chan;
    80001ed0:	02993023          	sd	s1,32(s2)
  release(&p->lock);
    80001ed4:	854a                	mv	a0,s2
    80001ed6:	d47fe0ef          	jal	80000c1c <release>
}
    80001eda:	60e2                	ld	ra,24(sp)
    80001edc:	6442                	ld	s0,16(sp)
    80001ede:	64a2                	ld	s1,8(sp)
    80001ee0:	6902                	ld	s2,0(sp)
    80001ee2:	6105                	addi	sp,sp,32
    80001ee4:	8082                	ret
    panic("sleep_prepare: zero chan");
    80001ee6:	00005517          	auipc	a0,0x5
    80001eea:	2fa50513          	addi	a0,a0,762 # 800071e0 <etext+0x1e0>
    80001eee:	903fe0ef          	jal	800007f0 <panic>

0000000080001ef2 <sleep>:
// Put the thread to sleep.  Assumes sleep_prepare() was called before.
// If the channel registered by sleep_prepare() has been woken up in
// the meantime, do not go to sleep, and instead return immediately.
void
sleep(void)
{
    80001ef2:	1101                	addi	sp,sp,-32
    80001ef4:	ec06                	sd	ra,24(sp)
    80001ef6:	e822                	sd	s0,16(sp)
    80001ef8:	e426                	sd	s1,8(sp)
    80001efa:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001efc:	9a7ff0ef          	jal	800018a2 <myproc>
    80001f00:	84aa                	mv	s1,a0

  acquire(&p->lock);
    80001f02:	c8ffe0ef          	jal	80000b90 <acquire>
  if (p->chan != 0) {
    80001f06:	709c                	ld	a5,32(s1)
    80001f08:	c789                	beqz	a5,80001f12 <sleep+0x20>
    p->state = SLEEPING;
    80001f0a:	4789                	li	a5,2
    80001f0c:	cc9c                	sw	a5,24(s1)
    sched();
    80001f0e:	ec3ff0ef          	jal	80001dd0 <sched>
  }
  release(&p->lock);
    80001f12:	8526                	mv	a0,s1
    80001f14:	d09fe0ef          	jal	80000c1c <release>
}
    80001f18:	60e2                	ld	ra,24(sp)
    80001f1a:	6442                	ld	s0,16(sp)
    80001f1c:	64a2                	ld	s1,8(sp)
    80001f1e:	6105                	addi	sp,sp,32
    80001f20:	8082                	ret

0000000080001f22 <wakeup>:

// Wake up all processes sleeping on channel chan.
void
wakeup(void *chan)
{
    80001f22:	7139                	addi	sp,sp,-64
    80001f24:	fc06                	sd	ra,56(sp)
    80001f26:	f822                	sd	s0,48(sp)
    80001f28:	f426                	sd	s1,40(sp)
    80001f2a:	f04a                	sd	s2,32(sp)
    80001f2c:	ec4e                	sd	s3,24(sp)
    80001f2e:	e852                	sd	s4,16(sp)
    80001f30:	e456                	sd	s5,8(sp)
    80001f32:	0080                	addi	s0,sp,64
    80001f34:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001f36:	00010497          	auipc	s1,0x10
    80001f3a:	e5a48493          	addi	s1,s1,-422 # 80011d90 <proc>
      // signal that the wakeup happened by clearing p->chan.
      p->chan = 0;

      // If this waiting process has gotten so far as to actually
      // go to sleep, also set it back to RUNNING.
      if (p->state == SLEEPING) {
    80001f3e:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80001f40:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f42:	00016997          	auipc	s3,0x16
    80001f46:	84e98993          	addi	s3,s3,-1970 # 80017790 <tickslock>
    80001f4a:	a801                	j	80001f5a <wakeup+0x38>
      }
    }
    release(&p->lock);
    80001f4c:	8526                	mv	a0,s1
    80001f4e:	ccffe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001f52:	16848493          	addi	s1,s1,360
    80001f56:	03348063          	beq	s1,s3,80001f76 <wakeup+0x54>
    acquire(&p->lock);
    80001f5a:	8526                	mv	a0,s1
    80001f5c:	c35fe0ef          	jal	80000b90 <acquire>
    if (p->chan == chan) {
    80001f60:	709c                	ld	a5,32(s1)
    80001f62:	ff2795e3          	bne	a5,s2,80001f4c <wakeup+0x2a>
      p->chan = 0;
    80001f66:	0204b023          	sd	zero,32(s1)
      if (p->state == SLEEPING) {
    80001f6a:	4c9c                	lw	a5,24(s1)
    80001f6c:	ff4790e3          	bne	a5,s4,80001f4c <wakeup+0x2a>
        p->state = RUNNABLE;
    80001f70:	0154ac23          	sw	s5,24(s1)
    80001f74:	bfe1                	j	80001f4c <wakeup+0x2a>
  }
}
    80001f76:	70e2                	ld	ra,56(sp)
    80001f78:	7442                	ld	s0,48(sp)
    80001f7a:	74a2                	ld	s1,40(sp)
    80001f7c:	7902                	ld	s2,32(sp)
    80001f7e:	69e2                	ld	s3,24(sp)
    80001f80:	6a42                	ld	s4,16(sp)
    80001f82:	6aa2                	ld	s5,8(sp)
    80001f84:	6121                	addi	sp,sp,64
    80001f86:	8082                	ret

0000000080001f88 <reparent>:
{
    80001f88:	7179                	addi	sp,sp,-48
    80001f8a:	f406                	sd	ra,40(sp)
    80001f8c:	f022                	sd	s0,32(sp)
    80001f8e:	ec26                	sd	s1,24(sp)
    80001f90:	e84a                	sd	s2,16(sp)
    80001f92:	e44e                	sd	s3,8(sp)
    80001f94:	e052                	sd	s4,0(sp)
    80001f96:	1800                	addi	s0,sp,48
    80001f98:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001f9a:	00010497          	auipc	s1,0x10
    80001f9e:	df648493          	addi	s1,s1,-522 # 80011d90 <proc>
      pp->parent = initproc;
    80001fa2:	00008a17          	auipc	s4,0x8
    80001fa6:	896a0a13          	addi	s4,s4,-1898 # 80009838 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80001faa:	00015997          	auipc	s3,0x15
    80001fae:	7e698993          	addi	s3,s3,2022 # 80017790 <tickslock>
    80001fb2:	a029                	j	80001fbc <reparent+0x34>
    80001fb4:	16848493          	addi	s1,s1,360
    80001fb8:	01348b63          	beq	s1,s3,80001fce <reparent+0x46>
    if (pp->parent == p) {
    80001fbc:	7c9c                	ld	a5,56(s1)
    80001fbe:	ff279be3          	bne	a5,s2,80001fb4 <reparent+0x2c>
      pp->parent = initproc;
    80001fc2:	000a3503          	ld	a0,0(s4)
    80001fc6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001fc8:	f5bff0ef          	jal	80001f22 <wakeup>
    80001fcc:	b7e5                	j	80001fb4 <reparent+0x2c>
}
    80001fce:	70a2                	ld	ra,40(sp)
    80001fd0:	7402                	ld	s0,32(sp)
    80001fd2:	64e2                	ld	s1,24(sp)
    80001fd4:	6942                	ld	s2,16(sp)
    80001fd6:	69a2                	ld	s3,8(sp)
    80001fd8:	6a02                	ld	s4,0(sp)
    80001fda:	6145                	addi	sp,sp,48
    80001fdc:	8082                	ret

0000000080001fde <kexit>:
{
    80001fde:	7179                	addi	sp,sp,-48
    80001fe0:	f406                	sd	ra,40(sp)
    80001fe2:	f022                	sd	s0,32(sp)
    80001fe4:	ec26                	sd	s1,24(sp)
    80001fe6:	e84a                	sd	s2,16(sp)
    80001fe8:	e44e                	sd	s3,8(sp)
    80001fea:	e052                	sd	s4,0(sp)
    80001fec:	1800                	addi	s0,sp,48
    80001fee:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001ff0:	8b3ff0ef          	jal	800018a2 <myproc>
    80001ff4:	89aa                	mv	s3,a0
  if (p == initproc)
    80001ff6:	00008797          	auipc	a5,0x8
    80001ffa:	8427b783          	ld	a5,-1982(a5) # 80009838 <initproc>
    80001ffe:	0d050493          	addi	s1,a0,208
    80002002:	15050913          	addi	s2,a0,336
    80002006:	00a79f63          	bne	a5,a0,80002024 <kexit+0x46>
    panic("init exiting");
    8000200a:	00005517          	auipc	a0,0x5
    8000200e:	1f650513          	addi	a0,a0,502 # 80007200 <etext+0x200>
    80002012:	fdefe0ef          	jal	800007f0 <panic>
      fileclose(f);
    80002016:	0da020ef          	jal	800040f0 <fileclose>
      p->ofile[fd] = 0;
    8000201a:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    8000201e:	04a1                	addi	s1,s1,8
    80002020:	01248563          	beq	s1,s2,8000202a <kexit+0x4c>
    if (p->ofile[fd]) {
    80002024:	6088                	ld	a0,0(s1)
    80002026:	f965                	bnez	a0,80002016 <kexit+0x38>
    80002028:	bfdd                	j	8000201e <kexit+0x40>
  begin_op();
    8000202a:	41b010ef          	jal	80003c44 <begin_op>
  iput(p->cwd);
    8000202e:	1509b503          	ld	a0,336(s3)
    80002032:	34c010ef          	jal	8000337e <iput>
  end_op();
    80002036:	495010ef          	jal	80003cca <end_op>
  p->cwd = 0;
    8000203a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000203e:	00010497          	auipc	s1,0x10
    80002042:	93a48493          	addi	s1,s1,-1734 # 80011978 <wait_lock>
    80002046:	8526                	mv	a0,s1
    80002048:	b49fe0ef          	jal	80000b90 <acquire>
  reparent(p);
    8000204c:	854e                	mv	a0,s3
    8000204e:	f3bff0ef          	jal	80001f88 <reparent>
  wakeup(p->parent);
    80002052:	0389b503          	ld	a0,56(s3)
    80002056:	ecdff0ef          	jal	80001f22 <wakeup>
  acquire(&p->lock);
    8000205a:	854e                	mv	a0,s3
    8000205c:	b35fe0ef          	jal	80000b90 <acquire>
  p->xstate = status;
    80002060:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002064:	4795                	li	a5,5
    80002066:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000206a:	8526                	mv	a0,s1
    8000206c:	bb1fe0ef          	jal	80000c1c <release>
  sched();
    80002070:	d61ff0ef          	jal	80001dd0 <sched>
  panic("zombie exit");
    80002074:	00005517          	auipc	a0,0x5
    80002078:	19c50513          	addi	a0,a0,412 # 80007210 <etext+0x210>
    8000207c:	f74fe0ef          	jal	800007f0 <panic>

0000000080002080 <kkill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kkill(int pid)
{
    80002080:	7179                	addi	sp,sp,-48
    80002082:	f406                	sd	ra,40(sp)
    80002084:	f022                	sd	s0,32(sp)
    80002086:	ec26                	sd	s1,24(sp)
    80002088:	e84a                	sd	s2,16(sp)
    8000208a:	e44e                	sd	s3,8(sp)
    8000208c:	1800                	addi	s0,sp,48
    8000208e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002090:	00010497          	auipc	s1,0x10
    80002094:	d0048493          	addi	s1,s1,-768 # 80011d90 <proc>
    80002098:	00015997          	auipc	s3,0x15
    8000209c:	6f898993          	addi	s3,s3,1784 # 80017790 <tickslock>
    acquire(&p->lock);
    800020a0:	8526                	mv	a0,s1
    800020a2:	aeffe0ef          	jal	80000b90 <acquire>
    if (p->pid == pid) {
    800020a6:	589c                	lw	a5,48(s1)
    800020a8:	01278b63          	beq	a5,s2,800020be <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800020ac:	8526                	mv	a0,s1
    800020ae:	b6ffe0ef          	jal	80000c1c <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800020b2:	16848493          	addi	s1,s1,360
    800020b6:	ff3495e3          	bne	s1,s3,800020a0 <kkill+0x20>
  }
  return -1;
    800020ba:	557d                	li	a0,-1
    800020bc:	a819                	j	800020d2 <kkill+0x52>
      p->killed = 1;
    800020be:	4785                	li	a5,1
    800020c0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800020c2:	4c98                	lw	a4,24(s1)
    800020c4:	4789                	li	a5,2
    800020c6:	00f70d63          	beq	a4,a5,800020e0 <kkill+0x60>
      release(&p->lock);
    800020ca:	8526                	mv	a0,s1
    800020cc:	b51fe0ef          	jal	80000c1c <release>
      return 0;
    800020d0:	4501                	li	a0,0
}
    800020d2:	70a2                	ld	ra,40(sp)
    800020d4:	7402                	ld	s0,32(sp)
    800020d6:	64e2                	ld	s1,24(sp)
    800020d8:	6942                	ld	s2,16(sp)
    800020da:	69a2                	ld	s3,8(sp)
    800020dc:	6145                	addi	sp,sp,48
    800020de:	8082                	ret
        p->state = RUNNABLE;
    800020e0:	478d                	li	a5,3
    800020e2:	cc9c                	sw	a5,24(s1)
    800020e4:	b7dd                	j	800020ca <kkill+0x4a>

00000000800020e6 <setkilled>:

void
setkilled(struct proc *p)
{
    800020e6:	1101                	addi	sp,sp,-32
    800020e8:	ec06                	sd	ra,24(sp)
    800020ea:	e822                	sd	s0,16(sp)
    800020ec:	e426                	sd	s1,8(sp)
    800020ee:	1000                	addi	s0,sp,32
    800020f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020f2:	a9ffe0ef          	jal	80000b90 <acquire>
  p->killed = 1;
    800020f6:	4785                	li	a5,1
    800020f8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	b21fe0ef          	jal	80000c1c <release>
}
    80002100:	60e2                	ld	ra,24(sp)
    80002102:	6442                	ld	s0,16(sp)
    80002104:	64a2                	ld	s1,8(sp)
    80002106:	6105                	addi	sp,sp,32
    80002108:	8082                	ret

000000008000210a <killed>:

int
killed(struct proc *p)
{
    8000210a:	1101                	addi	sp,sp,-32
    8000210c:	ec06                	sd	ra,24(sp)
    8000210e:	e822                	sd	s0,16(sp)
    80002110:	e426                	sd	s1,8(sp)
    80002112:	e04a                	sd	s2,0(sp)
    80002114:	1000                	addi	s0,sp,32
    80002116:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002118:	a79fe0ef          	jal	80000b90 <acquire>
  k = p->killed;
    8000211c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002120:	8526                	mv	a0,s1
    80002122:	afbfe0ef          	jal	80000c1c <release>
  return k;
}
    80002126:	854a                	mv	a0,s2
    80002128:	60e2                	ld	ra,24(sp)
    8000212a:	6442                	ld	s0,16(sp)
    8000212c:	64a2                	ld	s1,8(sp)
    8000212e:	6902                	ld	s2,0(sp)
    80002130:	6105                	addi	sp,sp,32
    80002132:	8082                	ret

0000000080002134 <kwait>:
{
    80002134:	715d                	addi	sp,sp,-80
    80002136:	e486                	sd	ra,72(sp)
    80002138:	e0a2                	sd	s0,64(sp)
    8000213a:	fc26                	sd	s1,56(sp)
    8000213c:	f84a                	sd	s2,48(sp)
    8000213e:	f44e                	sd	s3,40(sp)
    80002140:	f052                	sd	s4,32(sp)
    80002142:	ec56                	sd	s5,24(sp)
    80002144:	e85a                	sd	s6,16(sp)
    80002146:	e45e                	sd	s7,8(sp)
    80002148:	e062                	sd	s8,0(sp)
    8000214a:	0880                	addi	s0,sp,80
    8000214c:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    8000214e:	f54ff0ef          	jal	800018a2 <myproc>
    80002152:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002154:	00010517          	auipc	a0,0x10
    80002158:	82450513          	addi	a0,a0,-2012 # 80011978 <wait_lock>
    8000215c:	a35fe0ef          	jal	80000b90 <acquire>
    havekids = 0;
    80002160:	4c01                	li	s8,0
        if (pp->state == ZOMBIE) {
    80002162:	4a15                	li	s4,5
        havekids = 1;
    80002164:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002166:	00015997          	auipc	s3,0x15
    8000216a:	62a98993          	addi	s3,s3,1578 # 80017790 <tickslock>
    release(&wait_lock);
    8000216e:	00010b97          	auipc	s7,0x10
    80002172:	80ab8b93          	addi	s7,s7,-2038 # 80011978 <wait_lock>
    80002176:	a84d                	j	80002228 <kwait+0xf4>
          pid = pp->pid;
    80002178:	0304a983          	lw	s3,48(s1)
          if (addr != 0 &&
    8000217c:	000b0e63          	beqz	s6,80002198 <kwait+0x64>
              copyout(p->pagetable, p->sz, addr, (char *)&pp->xstate,
    80002180:	4711                	li	a4,4
    80002182:	02c48693          	addi	a3,s1,44
    80002186:	865a                	mv	a2,s6
    80002188:	04893583          	ld	a1,72(s2)
    8000218c:	05093503          	ld	a0,80(s2)
    80002190:	b48ff0ef          	jal	800014d8 <copyout>
          if (addr != 0 &&
    80002194:	02054d63          	bltz	a0,800021ce <kwait+0x9a>
          pp->parent = 0;
    80002198:	0204bc23          	sd	zero,56(s1)
          freeproc(pp);
    8000219c:	8526                	mv	a0,s1
    8000219e:	8e1ff0ef          	jal	80001a7e <freeproc>
          release(&pp->lock);
    800021a2:	8526                	mv	a0,s1
    800021a4:	a79fe0ef          	jal	80000c1c <release>
          release(&wait_lock);
    800021a8:	0000f517          	auipc	a0,0xf
    800021ac:	7d050513          	addi	a0,a0,2000 # 80011978 <wait_lock>
    800021b0:	a6dfe0ef          	jal	80000c1c <release>
}
    800021b4:	854e                	mv	a0,s3
    800021b6:	60a6                	ld	ra,72(sp)
    800021b8:	6406                	ld	s0,64(sp)
    800021ba:	74e2                	ld	s1,56(sp)
    800021bc:	7942                	ld	s2,48(sp)
    800021be:	79a2                	ld	s3,40(sp)
    800021c0:	7a02                	ld	s4,32(sp)
    800021c2:	6ae2                	ld	s5,24(sp)
    800021c4:	6b42                	ld	s6,16(sp)
    800021c6:	6ba2                	ld	s7,8(sp)
    800021c8:	6c02                	ld	s8,0(sp)
    800021ca:	6161                	addi	sp,sp,80
    800021cc:	8082                	ret
            release(&pp->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	a4dfe0ef          	jal	80000c1c <release>
            release(&wait_lock);
    800021d4:	0000f517          	auipc	a0,0xf
    800021d8:	7a450513          	addi	a0,a0,1956 # 80011978 <wait_lock>
    800021dc:	a41fe0ef          	jal	80000c1c <release>
            return -1;
    800021e0:	59fd                	li	s3,-1
    800021e2:	bfc9                	j	800021b4 <kwait+0x80>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800021e4:	16848493          	addi	s1,s1,360
    800021e8:	03348063          	beq	s1,s3,80002208 <kwait+0xd4>
      if (pp->parent == p) {
    800021ec:	7c9c                	ld	a5,56(s1)
    800021ee:	ff279be3          	bne	a5,s2,800021e4 <kwait+0xb0>
        acquire(&pp->lock);
    800021f2:	8526                	mv	a0,s1
    800021f4:	99dfe0ef          	jal	80000b90 <acquire>
        if (pp->state == ZOMBIE) {
    800021f8:	4c9c                	lw	a5,24(s1)
    800021fa:	f7478fe3          	beq	a5,s4,80002178 <kwait+0x44>
        release(&pp->lock);
    800021fe:	8526                	mv	a0,s1
    80002200:	a1dfe0ef          	jal	80000c1c <release>
        havekids = 1;
    80002204:	8756                	mv	a4,s5
    80002206:	bff9                	j	800021e4 <kwait+0xb0>
    if (!havekids || killed(p)) {
    80002208:	c715                	beqz	a4,80002234 <kwait+0x100>
    8000220a:	854a                	mv	a0,s2
    8000220c:	effff0ef          	jal	8000210a <killed>
    80002210:	e115                	bnez	a0,80002234 <kwait+0x100>
    sleep_prepare(p); //DOC: wait-sleep
    80002212:	854a                	mv	a0,s2
    80002214:	ca3ff0ef          	jal	80001eb6 <sleep_prepare>
    release(&wait_lock);
    80002218:	855e                	mv	a0,s7
    8000221a:	a03fe0ef          	jal	80000c1c <release>
    sleep();
    8000221e:	cd5ff0ef          	jal	80001ef2 <sleep>
    acquire(&wait_lock);
    80002222:	855e                	mv	a0,s7
    80002224:	96dfe0ef          	jal	80000b90 <acquire>
    havekids = 0;
    80002228:	8762                	mv	a4,s8
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000222a:	00010497          	auipc	s1,0x10
    8000222e:	b6648493          	addi	s1,s1,-1178 # 80011d90 <proc>
    80002232:	bf6d                	j	800021ec <kwait+0xb8>
      release(&wait_lock);
    80002234:	0000f517          	auipc	a0,0xf
    80002238:	74450513          	addi	a0,a0,1860 # 80011978 <wait_lock>
    8000223c:	9e1fe0ef          	jal	80000c1c <release>
      return -1;
    80002240:	59fd                	li	s3,-1
    80002242:	bf8d                	j	800021b4 <kwait+0x80>

0000000080002244 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002244:	7179                	addi	sp,sp,-48
    80002246:	f406                	sd	ra,40(sp)
    80002248:	f022                	sd	s0,32(sp)
    8000224a:	ec26                	sd	s1,24(sp)
    8000224c:	e84a                	sd	s2,16(sp)
    8000224e:	e44e                	sd	s3,8(sp)
    80002250:	e052                	sd	s4,0(sp)
    80002252:	1800                	addi	s0,sp,48
    80002254:	84aa                	mv	s1,a0
    80002256:	892e                	mv	s2,a1
    80002258:	89b2                	mv	s3,a2
    8000225a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000225c:	e46ff0ef          	jal	800018a2 <myproc>
  if (user_dst) {
    80002260:	c085                	beqz	s1,80002280 <either_copyout+0x3c>
    return copyout(p->pagetable, p->sz, dst, src, len);
    80002262:	8752                	mv	a4,s4
    80002264:	86ce                	mv	a3,s3
    80002266:	864a                	mv	a2,s2
    80002268:	652c                	ld	a1,72(a0)
    8000226a:	6928                	ld	a0,80(a0)
    8000226c:	a6cff0ef          	jal	800014d8 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002270:	70a2                	ld	ra,40(sp)
    80002272:	7402                	ld	s0,32(sp)
    80002274:	64e2                	ld	s1,24(sp)
    80002276:	6942                	ld	s2,16(sp)
    80002278:	69a2                	ld	s3,8(sp)
    8000227a:	6a02                	ld	s4,0(sp)
    8000227c:	6145                	addi	sp,sp,48
    8000227e:	8082                	ret
    memmove((char *)dst, src, len);
    80002280:	000a061b          	sext.w	a2,s4
    80002284:	85ce                	mv	a1,s3
    80002286:	854a                	mv	a0,s2
    80002288:	a29fe0ef          	jal	80000cb0 <memmove>
    return 0;
    8000228c:	8526                	mv	a0,s1
    8000228e:	b7cd                	j	80002270 <either_copyout+0x2c>

0000000080002290 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002290:	7179                	addi	sp,sp,-48
    80002292:	f406                	sd	ra,40(sp)
    80002294:	f022                	sd	s0,32(sp)
    80002296:	ec26                	sd	s1,24(sp)
    80002298:	e84a                	sd	s2,16(sp)
    8000229a:	e44e                	sd	s3,8(sp)
    8000229c:	e052                	sd	s4,0(sp)
    8000229e:	1800                	addi	s0,sp,48
    800022a0:	892a                	mv	s2,a0
    800022a2:	84ae                	mv	s1,a1
    800022a4:	89b2                	mv	s3,a2
    800022a6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a8:	dfaff0ef          	jal	800018a2 <myproc>
  if (user_src) {
    800022ac:	c085                	beqz	s1,800022cc <either_copyin+0x3c>
    return copyin(p->pagetable, p->sz, dst, src, len);
    800022ae:	8752                	mv	a4,s4
    800022b0:	86ce                	mv	a3,s3
    800022b2:	864a                	mv	a2,s2
    800022b4:	652c                	ld	a1,72(a0)
    800022b6:	6928                	ld	a0,80(a0)
    800022b8:	b0cff0ef          	jal	800015c4 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800022bc:	70a2                	ld	ra,40(sp)
    800022be:	7402                	ld	s0,32(sp)
    800022c0:	64e2                	ld	s1,24(sp)
    800022c2:	6942                	ld	s2,16(sp)
    800022c4:	69a2                	ld	s3,8(sp)
    800022c6:	6a02                	ld	s4,0(sp)
    800022c8:	6145                	addi	sp,sp,48
    800022ca:	8082                	ret
    memmove(dst, (char *)src, len);
    800022cc:	000a061b          	sext.w	a2,s4
    800022d0:	85ce                	mv	a1,s3
    800022d2:	854a                	mv	a0,s2
    800022d4:	9ddfe0ef          	jal	80000cb0 <memmove>
    return 0;
    800022d8:	8526                	mv	a0,s1
    800022da:	b7cd                	j	800022bc <either_copyin+0x2c>

00000000800022dc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800022dc:	715d                	addi	sp,sp,-80
    800022de:	e486                	sd	ra,72(sp)
    800022e0:	e0a2                	sd	s0,64(sp)
    800022e2:	fc26                	sd	s1,56(sp)
    800022e4:	f84a                	sd	s2,48(sp)
    800022e6:	f44e                	sd	s3,40(sp)
    800022e8:	f052                	sd	s4,32(sp)
    800022ea:	ec56                	sd	s5,24(sp)
    800022ec:	e85a                	sd	s6,16(sp)
    800022ee:	e45e                	sd	s7,8(sp)
    800022f0:	0880                	addi	s0,sp,80
    // clang-format on
  };
  struct proc *p;
  char *state;

  printk("\n");
    800022f2:	00005517          	auipc	a0,0x5
    800022f6:	d8650513          	addi	a0,a0,-634 # 80007078 <etext+0x78>
    800022fa:	a10fe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    800022fe:	00010497          	auipc	s1,0x10
    80002302:	bea48493          	addi	s1,s1,-1046 # 80011ee8 <proc+0x158>
    80002306:	00015917          	auipc	s2,0x15
    8000230a:	5e290913          	addi	s2,s2,1506 # 800178e8 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000230e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002310:	00005997          	auipc	s3,0x5
    80002314:	f1098993          	addi	s3,s3,-240 # 80007220 <etext+0x220>
    printk("%d %s %s", p->pid, state, p->name);
    80002318:	00005a97          	auipc	s5,0x5
    8000231c:	f10a8a93          	addi	s5,s5,-240 # 80007228 <etext+0x228>
    printk("\n");
    80002320:	00005a17          	auipc	s4,0x5
    80002324:	d58a0a13          	addi	s4,s4,-680 # 80007078 <etext+0x78>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002328:	00005b97          	auipc	s7,0x5
    8000232c:	420b8b93          	addi	s7,s7,1056 # 80007748 <states.0>
    80002330:	a829                	j	8000234a <procdump+0x6e>
    printk("%d %s %s", p->pid, state, p->name);
    80002332:	ed86a583          	lw	a1,-296(a3)
    80002336:	8556                	mv	a0,s5
    80002338:	9d2fe0ef          	jal	8000050a <printk>
    printk("\n");
    8000233c:	8552                	mv	a0,s4
    8000233e:	9ccfe0ef          	jal	8000050a <printk>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002342:	16848493          	addi	s1,s1,360
    80002346:	03248263          	beq	s1,s2,8000236a <procdump+0x8e>
    if (p->state == UNUSED)
    8000234a:	86a6                	mv	a3,s1
    8000234c:	ec04a783          	lw	a5,-320(s1)
    80002350:	dbed                	beqz	a5,80002342 <procdump+0x66>
      state = "???";
    80002352:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002354:	fcfb6fe3          	bltu	s6,a5,80002332 <procdump+0x56>
    80002358:	02079713          	slli	a4,a5,0x20
    8000235c:	01d75793          	srli	a5,a4,0x1d
    80002360:	97de                	add	a5,a5,s7
    80002362:	6390                	ld	a2,0(a5)
    80002364:	f679                	bnez	a2,80002332 <procdump+0x56>
      state = "???";
    80002366:	864e                	mv	a2,s3
    80002368:	b7e9                	j	80002332 <procdump+0x56>
  }
}
    8000236a:	60a6                	ld	ra,72(sp)
    8000236c:	6406                	ld	s0,64(sp)
    8000236e:	74e2                	ld	s1,56(sp)
    80002370:	7942                	ld	s2,48(sp)
    80002372:	79a2                	ld	s3,40(sp)
    80002374:	7a02                	ld	s4,32(sp)
    80002376:	6ae2                	ld	s5,24(sp)
    80002378:	6b42                	ld	s6,16(sp)
    8000237a:	6ba2                	ld	s7,8(sp)
    8000237c:	6161                	addi	sp,sp,80
    8000237e:	8082                	ret

0000000080002380 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002380:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002384:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002388:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000238a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000238c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002390:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002394:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002398:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000239c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800023a0:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800023a4:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800023a8:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800023ac:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800023b0:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800023b4:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800023b8:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800023bc:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800023be:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800023c0:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800023c4:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800023c8:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800023cc:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800023d0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800023d4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800023d8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800023dc:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800023e0:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800023e4:	0685bd83          	ld	s11,104(a1)
        
        ret
    800023e8:	8082                	ret

00000000800023ea <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800023ea:	1141                	addi	sp,sp,-16
    800023ec:	e406                	sd	ra,8(sp)
    800023ee:	e022                	sd	s0,0(sp)
    800023f0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800023f2:	00005597          	auipc	a1,0x5
    800023f6:	e7658593          	addi	a1,a1,-394 # 80007268 <etext+0x268>
    800023fa:	00015517          	auipc	a0,0x15
    800023fe:	39650513          	addi	a0,a0,918 # 80017790 <tickslock>
    80002402:	f18fe0ef          	jal	80000b1a <initlock>
}
    80002406:	60a2                	ld	ra,8(sp)
    80002408:	6402                	ld	s0,0(sp)
    8000240a:	0141                	addi	sp,sp,16
    8000240c:	8082                	ret

000000008000240e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000240e:	1141                	addi	sp,sp,-16
    80002410:	e422                	sd	s0,8(sp)
    80002412:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002414:	00003797          	auipc	a5,0x3
    80002418:	11c78793          	addi	a5,a5,284 # 80005530 <kernelvec>
    8000241c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002420:	6422                	ld	s0,8(sp)
    80002422:	0141                	addi	sp,sp,16
    80002424:	8082                	ret

0000000080002426 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002426:	1141                	addi	sp,sp,-16
    80002428:	e406                	sd	ra,8(sp)
    8000242a:	e022                	sd	s0,0(sp)
    8000242c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000242e:	c74ff0ef          	jal	800018a2 <myproc>
  __asm__ __volatile__("csrc sstatus, %0" ::"rK"(x) : "memory");
    80002432:	10017073          	csrci	sstatus,2
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002436:	04000737          	lui	a4,0x4000
    8000243a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000243c:	0732                	slli	a4,a4,0xc
    8000243e:	00004797          	auipc	a5,0x4
    80002442:	bc278793          	addi	a5,a5,-1086 # 80006000 <_trampoline>
    80002446:	00004697          	auipc	a3,0x4
    8000244a:	bba68693          	addi	a3,a3,-1094 # 80006000 <_trampoline>
    8000244e:	8f95                	sub	a5,a5,a3
    80002450:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002452:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002456:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r"(x));
    80002458:	18002773          	csrr	a4,satp
    8000245c:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000245e:	6d38                	ld	a4,88(a0)
    80002460:	613c                	ld	a5,64(a0)
    80002462:	6685                	lui	a3,0x1
    80002464:	97b6                	add	a5,a5,a3
    80002466:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002468:	6d3c                	ld	a5,88(a0)
    8000246a:	00000717          	auipc	a4,0x0
    8000246e:	0f870713          	addi	a4,a4,248 # 80002562 <usertrap>
    80002472:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002474:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r"(x));
    80002476:	8712                	mv	a4,tp
    80002478:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000247a:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000247e:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002482:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r"(x));
    80002486:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000248a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000248c:	6f9c                	ld	a5,24(a5)
    8000248e:	14179073          	csrw	sepc,a5
}
    80002492:	60a2                	ld	ra,8(sp)
    80002494:	6402                	ld	s0,0(sp)
    80002496:	0141                	addi	sp,sp,16
    80002498:	8082                	ret

000000008000249a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000249a:	1101                	addi	sp,sp,-32
    8000249c:	ec06                	sd	ra,24(sp)
    8000249e:	e822                	sd	s0,16(sp)
    800024a0:	1000                	addi	s0,sp,32
  if (cpuid() == 0) {
    800024a2:	bd4ff0ef          	jal	80001876 <cpuid>
    800024a6:	cd11                	beqz	a0,800024c2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r"(x));
    800024a8:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800024ac:	000f4737          	lui	a4,0xf4
    800024b0:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800024b4:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r"(x));
    800024b6:	14d79073          	csrw	stimecmp,a5
}
    800024ba:	60e2                	ld	ra,24(sp)
    800024bc:	6442                	ld	s0,16(sp)
    800024be:	6105                	addi	sp,sp,32
    800024c0:	8082                	ret
    800024c2:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800024c4:	00015497          	auipc	s1,0x15
    800024c8:	2cc48493          	addi	s1,s1,716 # 80017790 <tickslock>
    800024cc:	8526                	mv	a0,s1
    800024ce:	ec2fe0ef          	jal	80000b90 <acquire>
    ticks++;
    800024d2:	00007517          	auipc	a0,0x7
    800024d6:	36e50513          	addi	a0,a0,878 # 80009840 <ticks>
    800024da:	411c                	lw	a5,0(a0)
    800024dc:	2785                	addiw	a5,a5,1
    800024de:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800024e0:	a43ff0ef          	jal	80001f22 <wakeup>
    release(&tickslock);
    800024e4:	8526                	mv	a0,s1
    800024e6:	f36fe0ef          	jal	80000c1c <release>
    800024ea:	64a2                	ld	s1,8(sp)
    800024ec:	bf75                	j	800024a8 <clockintr+0xe>

00000000800024ee <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800024ee:	1101                	addi	sp,sp,-32
    800024f0:	ec06                	sd	ra,24(sp)
    800024f2:	e822                	sd	s0,16(sp)
    800024f4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r"(x));
    800024f6:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if (scause == 0x8000000000000009L) {
    800024fa:	57fd                	li	a5,-1
    800024fc:	17fe                	slli	a5,a5,0x3f
    800024fe:	07a5                	addi	a5,a5,9
    80002500:	00f70c63          	beq	a4,a5,80002518 <devintr+0x2a>
    // now allowed to interrupt again.
    if (irq)
      plic_complete(irq);

    return 1;
  } else if (scause == 0x8000000000000005L) {
    80002504:	57fd                	li	a5,-1
    80002506:	17fe                	slli	a5,a5,0x3f
    80002508:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    8000250a:	4501                	li	a0,0
  } else if (scause == 0x8000000000000005L) {
    8000250c:	04f70763          	beq	a4,a5,8000255a <devintr+0x6c>
  }
}
    80002510:	60e2                	ld	ra,24(sp)
    80002512:	6442                	ld	s0,16(sp)
    80002514:	6105                	addi	sp,sp,32
    80002516:	8082                	ret
    80002518:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    8000251a:	0c2030ef          	jal	800055dc <plic_claim>
    8000251e:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ) {
    80002520:	47a9                	li	a5,10
    80002522:	00f50963          	beq	a0,a5,80002534 <devintr+0x46>
    } else if (irq == VIRTIO0_IRQ) {
    80002526:	4785                	li	a5,1
    80002528:	00f50963          	beq	a0,a5,8000253a <devintr+0x4c>
    return 1;
    8000252c:	4505                	li	a0,1
    } else if (irq) {
    8000252e:	e889                	bnez	s1,80002540 <devintr+0x52>
    80002530:	64a2                	ld	s1,8(sp)
    80002532:	bff9                	j	80002510 <devintr+0x22>
      uartintr();
    80002534:	c58fe0ef          	jal	8000098c <uartintr>
    if (irq)
    80002538:	a819                	j	8000254e <devintr+0x60>
      virtio_disk_intr();
    8000253a:	586030ef          	jal	80005ac0 <virtio_disk_intr>
    if (irq)
    8000253e:	a801                	j	8000254e <devintr+0x60>
      printk("unexpected interrupt irq=%d\n", irq);
    80002540:	85a6                	mv	a1,s1
    80002542:	00005517          	auipc	a0,0x5
    80002546:	d2e50513          	addi	a0,a0,-722 # 80007270 <etext+0x270>
    8000254a:	fc1fd0ef          	jal	8000050a <printk>
      plic_complete(irq);
    8000254e:	8526                	mv	a0,s1
    80002550:	0ac030ef          	jal	800055fc <plic_complete>
    return 1;
    80002554:	4505                	li	a0,1
    80002556:	64a2                	ld	s1,8(sp)
    80002558:	bf65                	j	80002510 <devintr+0x22>
    clockintr();
    8000255a:	f41ff0ef          	jal	8000249a <clockintr>
    return 2;
    8000255e:	4509                	li	a0,2
    80002560:	bf45                	j	80002510 <devintr+0x22>

0000000080002562 <usertrap>:
{
    80002562:	1101                	addi	sp,sp,-32
    80002564:	ec06                	sd	ra,24(sp)
    80002566:	e822                	sd	s0,16(sp)
    80002568:	e426                	sd	s1,8(sp)
    8000256a:	e04a                	sd	s2,0(sp)
    8000256c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000256e:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002572:	1007f793          	andi	a5,a5,256
    80002576:	eba5                	bnez	a5,800025e6 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r"(x));
    80002578:	00003797          	auipc	a5,0x3
    8000257c:	fb878793          	addi	a5,a5,-72 # 80005530 <kernelvec>
    80002580:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002584:	b1eff0ef          	jal	800018a2 <myproc>
    80002588:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000258a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r"(x));
    8000258c:	14102773          	csrr	a4,sepc
    80002590:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r"(x));
    80002592:	14202773          	csrr	a4,scause
  if (r_scause() == 8) {
    80002596:	47a1                	li	a5,8
    80002598:	04f70d63          	beq	a4,a5,800025f2 <usertrap+0x90>
  } else if ((which_dev = devintr()) != 0) {
    8000259c:	f53ff0ef          	jal	800024ee <devintr>
    800025a0:	892a                	mv	s2,a0
    800025a2:	e54d                	bnez	a0,8000264c <usertrap+0xea>
    800025a4:	14202773          	csrr	a4,scause
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    800025a8:	47bd                	li	a5,15
    800025aa:	08f70463          	beq	a4,a5,80002632 <usertrap+0xd0>
    800025ae:	14202773          	csrr	a4,scause
    800025b2:	47b5                	li	a5,13
    800025b4:	06f70f63          	beq	a4,a5,80002632 <usertrap+0xd0>
    800025b8:	142025f3          	csrr	a1,scause
    printk("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    800025bc:	5890                	lw	a2,48(s1)
    800025be:	00005517          	auipc	a0,0x5
    800025c2:	cf250513          	addi	a0,a0,-782 # 800072b0 <etext+0x2b0>
    800025c6:	f45fd0ef          	jal	8000050a <printk>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800025ca:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800025ce:	14302673          	csrr	a2,stval
    printk("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    800025d2:	00005517          	auipc	a0,0x5
    800025d6:	d0e50513          	addi	a0,a0,-754 # 800072e0 <etext+0x2e0>
    800025da:	f31fd0ef          	jal	8000050a <printk>
    setkilled(p);
    800025de:	8526                	mv	a0,s1
    800025e0:	b07ff0ef          	jal	800020e6 <setkilled>
    800025e4:	a015                	j	80002608 <usertrap+0xa6>
    panic("usertrap: not from user mode");
    800025e6:	00005517          	auipc	a0,0x5
    800025ea:	caa50513          	addi	a0,a0,-854 # 80007290 <etext+0x290>
    800025ee:	a02fe0ef          	jal	800007f0 <panic>
    if (killed(p))
    800025f2:	b19ff0ef          	jal	8000210a <killed>
    800025f6:	e915                	bnez	a0,8000262a <usertrap+0xc8>
    p->trapframe->epc += 4;
    800025f8:	6cb8                	ld	a4,88(s1)
    800025fa:	6f1c                	ld	a5,24(a4)
    800025fc:	0791                	addi	a5,a5,4
    800025fe:	ef1c                	sd	a5,24(a4)
  __asm__ __volatile__("csrs sstatus, %0" ::"rK"(x) : "memory");
    80002600:	10016073          	csrsi	sstatus,2
    syscall();
    80002604:	24a000ef          	jal	8000284e <syscall>
  if (killed(p))
    80002608:	8526                	mv	a0,s1
    8000260a:	b01ff0ef          	jal	8000210a <killed>
    8000260e:	e521                	bnez	a0,80002656 <usertrap+0xf4>
  prepare_return();
    80002610:	e17ff0ef          	jal	80002426 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002614:	68a8                	ld	a0,80(s1)
    80002616:	8131                	srli	a0,a0,0xc
    80002618:	57fd                	li	a5,-1
    8000261a:	17fe                	slli	a5,a5,0x3f
    8000261c:	8d5d                	or	a0,a0,a5
}
    8000261e:	60e2                	ld	ra,24(sp)
    80002620:	6442                	ld	s0,16(sp)
    80002622:	64a2                	ld	s1,8(sp)
    80002624:	6902                	ld	s2,0(sp)
    80002626:	6105                	addi	sp,sp,32
    80002628:	8082                	ret
      kexit(-1);
    8000262a:	557d                	li	a0,-1
    8000262c:	9b3ff0ef          	jal	80001fde <kexit>
    80002630:	b7e1                	j	800025f8 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r"(x));
    80002632:	14302673          	csrr	a2,stval
  asm volatile("csrr %0, scause" : "=r"(x));
    80002636:	142026f3          	csrr	a3,scause
             vmfault(p->pagetable, p->sz, r_stval(),
    8000263a:	16cd                	addi	a3,a3,-13 # ff3 <_entry-0x7ffff00d>
    8000263c:	0016b693          	seqz	a3,a3
    80002640:	64ac                	ld	a1,72(s1)
    80002642:	68a8                	ld	a0,80(s1)
    80002644:	e19fe0ef          	jal	8000145c <vmfault>
  } else if ((r_scause() == 15 || r_scause() == 13) &&
    80002648:	f161                	bnez	a0,80002608 <usertrap+0xa6>
    8000264a:	b7bd                	j	800025b8 <usertrap+0x56>
  if (killed(p))
    8000264c:	8526                	mv	a0,s1
    8000264e:	abdff0ef          	jal	8000210a <killed>
    80002652:	c511                	beqz	a0,8000265e <usertrap+0xfc>
    80002654:	a011                	j	80002658 <usertrap+0xf6>
    80002656:	4901                	li	s2,0
    kexit(-1);
    80002658:	557d                	li	a0,-1
    8000265a:	985ff0ef          	jal	80001fde <kexit>
  if (which_dev == 2)
    8000265e:	4789                	li	a5,2
    80002660:	faf918e3          	bne	s2,a5,80002610 <usertrap+0xae>
    yield();
    80002664:	827ff0ef          	jal	80001e8a <yield>
    80002668:	b765                	j	80002610 <usertrap+0xae>

000000008000266a <kerneltrap>:
{
    8000266a:	7179                	addi	sp,sp,-48
    8000266c:	f406                	sd	ra,40(sp)
    8000266e:	f022                	sd	s0,32(sp)
    80002670:	ec26                	sd	s1,24(sp)
    80002672:	e84a                	sd	s2,16(sp)
    80002674:	e44e                	sd	s3,8(sp)
    80002676:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r"(x));
    80002678:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000267c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r"(x));
    80002680:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002684:	1004f793          	andi	a5,s1,256
    80002688:	c795                	beqz	a5,800026b4 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r"(x));
    8000268a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000268e:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80002690:	eb85                	bnez	a5,800026c0 <kerneltrap+0x56>
  if ((which_dev = devintr()) == 0) {
    80002692:	e5dff0ef          	jal	800024ee <devintr>
    80002696:	c91d                	beqz	a0,800026cc <kerneltrap+0x62>
  if (which_dev == 2 && myproc() != 0)
    80002698:	4789                	li	a5,2
    8000269a:	04f50a63          	beq	a0,a5,800026ee <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r"(x));
    8000269e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r"(x));
    800026a2:	10049073          	csrw	sstatus,s1
}
    800026a6:	70a2                	ld	ra,40(sp)
    800026a8:	7402                	ld	s0,32(sp)
    800026aa:	64e2                	ld	s1,24(sp)
    800026ac:	6942                	ld	s2,16(sp)
    800026ae:	69a2                	ld	s3,8(sp)
    800026b0:	6145                	addi	sp,sp,48
    800026b2:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026b4:	00005517          	auipc	a0,0x5
    800026b8:	c5450513          	addi	a0,a0,-940 # 80007308 <etext+0x308>
    800026bc:	934fe0ef          	jal	800007f0 <panic>
    panic("kerneltrap: interrupts enabled");
    800026c0:	00005517          	auipc	a0,0x5
    800026c4:	c7050513          	addi	a0,a0,-912 # 80007330 <etext+0x330>
    800026c8:	928fe0ef          	jal	800007f0 <panic>
  asm volatile("csrr %0, sepc" : "=r"(x));
    800026cc:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r"(x));
    800026d0:	143026f3          	csrr	a3,stval
    printk("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(),
    800026d4:	85ce                	mv	a1,s3
    800026d6:	00005517          	auipc	a0,0x5
    800026da:	c7a50513          	addi	a0,a0,-902 # 80007350 <etext+0x350>
    800026de:	e2dfd0ef          	jal	8000050a <printk>
    panic("kerneltrap");
    800026e2:	00005517          	auipc	a0,0x5
    800026e6:	c9650513          	addi	a0,a0,-874 # 80007378 <etext+0x378>
    800026ea:	906fe0ef          	jal	800007f0 <panic>
  if (which_dev == 2 && myproc() != 0)
    800026ee:	9b4ff0ef          	jal	800018a2 <myproc>
    800026f2:	d555                	beqz	a0,8000269e <kerneltrap+0x34>
    yield();
    800026f4:	f96ff0ef          	jal	80001e8a <yield>
    800026f8:	b75d                	j	8000269e <kerneltrap+0x34>

00000000800026fa <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800026fa:	1101                	addi	sp,sp,-32
    800026fc:	ec06                	sd	ra,24(sp)
    800026fe:	e822                	sd	s0,16(sp)
    80002700:	e426                	sd	s1,8(sp)
    80002702:	1000                	addi	s0,sp,32
    80002704:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002706:	99cff0ef          	jal	800018a2 <myproc>
  switch (n) {
    8000270a:	4795                	li	a5,5
    8000270c:	0497e163          	bltu	a5,s1,8000274e <argraw+0x54>
    80002710:	048a                	slli	s1,s1,0x2
    80002712:	00005717          	auipc	a4,0x5
    80002716:	06670713          	addi	a4,a4,102 # 80007778 <states.0+0x30>
    8000271a:	94ba                	add	s1,s1,a4
    8000271c:	409c                	lw	a5,0(s1)
    8000271e:	97ba                	add	a5,a5,a4
    80002720:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002722:	6d3c                	ld	a5,88(a0)
    80002724:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002726:	60e2                	ld	ra,24(sp)
    80002728:	6442                	ld	s0,16(sp)
    8000272a:	64a2                	ld	s1,8(sp)
    8000272c:	6105                	addi	sp,sp,32
    8000272e:	8082                	ret
    return p->trapframe->a1;
    80002730:	6d3c                	ld	a5,88(a0)
    80002732:	7fa8                	ld	a0,120(a5)
    80002734:	bfcd                	j	80002726 <argraw+0x2c>
    return p->trapframe->a2;
    80002736:	6d3c                	ld	a5,88(a0)
    80002738:	63c8                	ld	a0,128(a5)
    8000273a:	b7f5                	j	80002726 <argraw+0x2c>
    return p->trapframe->a3;
    8000273c:	6d3c                	ld	a5,88(a0)
    8000273e:	67c8                	ld	a0,136(a5)
    80002740:	b7dd                	j	80002726 <argraw+0x2c>
    return p->trapframe->a4;
    80002742:	6d3c                	ld	a5,88(a0)
    80002744:	6bc8                	ld	a0,144(a5)
    80002746:	b7c5                	j	80002726 <argraw+0x2c>
    return p->trapframe->a5;
    80002748:	6d3c                	ld	a5,88(a0)
    8000274a:	6fc8                	ld	a0,152(a5)
    8000274c:	bfe9                	j	80002726 <argraw+0x2c>
  panic("argraw");
    8000274e:	00005517          	auipc	a0,0x5
    80002752:	c3a50513          	addi	a0,a0,-966 # 80007388 <etext+0x388>
    80002756:	89afe0ef          	jal	800007f0 <panic>

000000008000275a <fetchaddr>:
{
    8000275a:	1101                	addi	sp,sp,-32
    8000275c:	ec06                	sd	ra,24(sp)
    8000275e:	e822                	sd	s0,16(sp)
    80002760:	e426                	sd	s1,8(sp)
    80002762:	e04a                	sd	s2,0(sp)
    80002764:	1000                	addi	s0,sp,32
    80002766:	84aa                	mv	s1,a0
    80002768:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000276a:	938ff0ef          	jal	800018a2 <myproc>
  if (addr >= p->sz ||
    8000276e:	652c                	ld	a1,72(a0)
    80002770:	02b4f663          	bgeu	s1,a1,8000279c <fetchaddr+0x42>
      addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002774:	00848793          	addi	a5,s1,8
  if (addr >= p->sz ||
    80002778:	02f5e463          	bltu	a1,a5,800027a0 <fetchaddr+0x46>
  if (copyin(p->pagetable, p->sz, (char *)ip, addr, sizeof(*ip)) != 0)
    8000277c:	4721                	li	a4,8
    8000277e:	86a6                	mv	a3,s1
    80002780:	864a                	mv	a2,s2
    80002782:	6928                	ld	a0,80(a0)
    80002784:	e41fe0ef          	jal	800015c4 <copyin>
    80002788:	00a03533          	snez	a0,a0
    8000278c:	40a00533          	neg	a0,a0
}
    80002790:	60e2                	ld	ra,24(sp)
    80002792:	6442                	ld	s0,16(sp)
    80002794:	64a2                	ld	s1,8(sp)
    80002796:	6902                	ld	s2,0(sp)
    80002798:	6105                	addi	sp,sp,32
    8000279a:	8082                	ret
    return -1;
    8000279c:	557d                	li	a0,-1
    8000279e:	bfcd                	j	80002790 <fetchaddr+0x36>
    800027a0:	557d                	li	a0,-1
    800027a2:	b7fd                	j	80002790 <fetchaddr+0x36>

00000000800027a4 <fetchstr>:
{
    800027a4:	7179                	addi	sp,sp,-48
    800027a6:	f406                	sd	ra,40(sp)
    800027a8:	f022                	sd	s0,32(sp)
    800027aa:	ec26                	sd	s1,24(sp)
    800027ac:	e84a                	sd	s2,16(sp)
    800027ae:	e44e                	sd	s3,8(sp)
    800027b0:	1800                	addi	s0,sp,48
    800027b2:	892a                	mv	s2,a0
    800027b4:	84ae                	mv	s1,a1
    800027b6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027b8:	8eaff0ef          	jal	800018a2 <myproc>
  if (copyinstr(p->pagetable, p->sz, buf, addr, max) < 0)
    800027bc:	874e                	mv	a4,s3
    800027be:	86ca                	mv	a3,s2
    800027c0:	8626                	mv	a2,s1
    800027c2:	652c                	ld	a1,72(a0)
    800027c4:	6928                	ld	a0,80(a0)
    800027c6:	e95fe0ef          	jal	8000165a <copyinstr>
    800027ca:	00054c63          	bltz	a0,800027e2 <fetchstr+0x3e>
  return strlen(buf);
    800027ce:	8526                	mv	a0,s1
    800027d0:	df4fe0ef          	jal	80000dc4 <strlen>
}
    800027d4:	70a2                	ld	ra,40(sp)
    800027d6:	7402                	ld	s0,32(sp)
    800027d8:	64e2                	ld	s1,24(sp)
    800027da:	6942                	ld	s2,16(sp)
    800027dc:	69a2                	ld	s3,8(sp)
    800027de:	6145                	addi	sp,sp,48
    800027e0:	8082                	ret
    return -1;
    800027e2:	557d                	li	a0,-1
    800027e4:	bfc5                	j	800027d4 <fetchstr+0x30>

00000000800027e6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800027e6:	1101                	addi	sp,sp,-32
    800027e8:	ec06                	sd	ra,24(sp)
    800027ea:	e822                	sd	s0,16(sp)
    800027ec:	e426                	sd	s1,8(sp)
    800027ee:	1000                	addi	s0,sp,32
    800027f0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800027f2:	f09ff0ef          	jal	800026fa <argraw>
    800027f6:	c088                	sw	a0,0(s1)
}
    800027f8:	60e2                	ld	ra,24(sp)
    800027fa:	6442                	ld	s0,16(sp)
    800027fc:	64a2                	ld	s1,8(sp)
    800027fe:	6105                	addi	sp,sp,32
    80002800:	8082                	ret

0000000080002802 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002802:	1101                	addi	sp,sp,-32
    80002804:	ec06                	sd	ra,24(sp)
    80002806:	e822                	sd	s0,16(sp)
    80002808:	e426                	sd	s1,8(sp)
    8000280a:	1000                	addi	s0,sp,32
    8000280c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000280e:	eedff0ef          	jal	800026fa <argraw>
    80002812:	e088                	sd	a0,0(s1)
}
    80002814:	60e2                	ld	ra,24(sp)
    80002816:	6442                	ld	s0,16(sp)
    80002818:	64a2                	ld	s1,8(sp)
    8000281a:	6105                	addi	sp,sp,32
    8000281c:	8082                	ret

000000008000281e <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (not including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000281e:	7179                	addi	sp,sp,-48
    80002820:	f406                	sd	ra,40(sp)
    80002822:	f022                	sd	s0,32(sp)
    80002824:	ec26                	sd	s1,24(sp)
    80002826:	e84a                	sd	s2,16(sp)
    80002828:	1800                	addi	s0,sp,48
    8000282a:	84ae                	mv	s1,a1
    8000282c:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000282e:	fd840593          	addi	a1,s0,-40
    80002832:	fd1ff0ef          	jal	80002802 <argaddr>
  return fetchstr(addr, buf, max);
    80002836:	864a                	mv	a2,s2
    80002838:	85a6                	mv	a1,s1
    8000283a:	fd843503          	ld	a0,-40(s0)
    8000283e:	f67ff0ef          	jal	800027a4 <fetchstr>
}
    80002842:	70a2                	ld	ra,40(sp)
    80002844:	7402                	ld	s0,32(sp)
    80002846:	64e2                	ld	s1,24(sp)
    80002848:	6942                	ld	s2,16(sp)
    8000284a:	6145                	addi	sp,sp,48
    8000284c:	8082                	ret

000000008000284e <syscall>:
  // clang-format on
};

void
syscall(void)
{
    8000284e:	1101                	addi	sp,sp,-32
    80002850:	ec06                	sd	ra,24(sp)
    80002852:	e822                	sd	s0,16(sp)
    80002854:	e426                	sd	s1,8(sp)
    80002856:	e04a                	sd	s2,0(sp)
    80002858:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000285a:	848ff0ef          	jal	800018a2 <myproc>
    8000285e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002860:	05853903          	ld	s2,88(a0)
    80002864:	0a893783          	ld	a5,168(s2)
    80002868:	0007869b          	sext.w	a3,a5
  if (num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000286c:	37fd                	addiw	a5,a5,-1
    8000286e:	4755                	li	a4,21
    80002870:	00f76f63          	bltu	a4,a5,8000288e <syscall+0x40>
    80002874:	00369713          	slli	a4,a3,0x3
    80002878:	00005797          	auipc	a5,0x5
    8000287c:	f1878793          	addi	a5,a5,-232 # 80007790 <syscalls>
    80002880:	97ba                	add	a5,a5,a4
    80002882:	639c                	ld	a5,0(a5)
    80002884:	c789                	beqz	a5,8000288e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002886:	9782                	jalr	a5
    80002888:	06a93823          	sd	a0,112(s2)
    8000288c:	a829                	j	800028a6 <syscall+0x58>
  } else {
    printk("%d %s: unknown sys call %d\n", p->pid, p->name, num);
    8000288e:	15848613          	addi	a2,s1,344
    80002892:	588c                	lw	a1,48(s1)
    80002894:	00005517          	auipc	a0,0x5
    80002898:	afc50513          	addi	a0,a0,-1284 # 80007390 <etext+0x390>
    8000289c:	c6ffd0ef          	jal	8000050a <printk>
    p->trapframe->a0 = -1;
    800028a0:	6cbc                	ld	a5,88(s1)
    800028a2:	577d                	li	a4,-1
    800028a4:	fbb8                	sd	a4,112(a5)
  }
}
    800028a6:	60e2                	ld	ra,24(sp)
    800028a8:	6442                	ld	s0,16(sp)
    800028aa:	64a2                	ld	s1,8(sp)
    800028ac:	6902                	ld	s2,0(sp)
    800028ae:	6105                	addi	sp,sp,32
    800028b0:	8082                	ret

00000000800028b2 <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    800028b2:	1101                	addi	sp,sp,-32
    800028b4:	ec06                	sd	ra,24(sp)
    800028b6:	e822                	sd	s0,16(sp)
    800028b8:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028ba:	fec40593          	addi	a1,s0,-20
    800028be:	4501                	li	a0,0
    800028c0:	f27ff0ef          	jal	800027e6 <argint>
  kexit(n);
    800028c4:	fec42503          	lw	a0,-20(s0)
    800028c8:	f16ff0ef          	jal	80001fde <kexit>
  return 0; // not reached
}
    800028cc:	4501                	li	a0,0
    800028ce:	60e2                	ld	ra,24(sp)
    800028d0:	6442                	ld	s0,16(sp)
    800028d2:	6105                	addi	sp,sp,32
    800028d4:	8082                	ret

00000000800028d6 <sys_getpid>:

uint64
sys_getpid(void)
{
    800028d6:	1141                	addi	sp,sp,-16
    800028d8:	e406                	sd	ra,8(sp)
    800028da:	e022                	sd	s0,0(sp)
    800028dc:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800028de:	fc5fe0ef          	jal	800018a2 <myproc>
}
    800028e2:	5908                	lw	a0,48(a0)
    800028e4:	60a2                	ld	ra,8(sp)
    800028e6:	6402                	ld	s0,0(sp)
    800028e8:	0141                	addi	sp,sp,16
    800028ea:	8082                	ret

00000000800028ec <sys_fork>:

uint64
sys_fork(void)
{
    800028ec:	1141                	addi	sp,sp,-16
    800028ee:	e406                	sd	ra,8(sp)
    800028f0:	e022                	sd	s0,0(sp)
    800028f2:	0800                	addi	s0,sp,16
  return kfork();
    800028f4:	b1aff0ef          	jal	80001c0e <kfork>
}
    800028f8:	60a2                	ld	ra,8(sp)
    800028fa:	6402                	ld	s0,0(sp)
    800028fc:	0141                	addi	sp,sp,16
    800028fe:	8082                	ret

0000000080002900 <sys_wait>:

uint64
sys_wait(void)
{
    80002900:	1101                	addi	sp,sp,-32
    80002902:	ec06                	sd	ra,24(sp)
    80002904:	e822                	sd	s0,16(sp)
    80002906:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002908:	fe840593          	addi	a1,s0,-24
    8000290c:	4501                	li	a0,0
    8000290e:	ef5ff0ef          	jal	80002802 <argaddr>
  return kwait(p);
    80002912:	fe843503          	ld	a0,-24(s0)
    80002916:	81fff0ef          	jal	80002134 <kwait>
}
    8000291a:	60e2                	ld	ra,24(sp)
    8000291c:	6442                	ld	s0,16(sp)
    8000291e:	6105                	addi	sp,sp,32
    80002920:	8082                	ret

0000000080002922 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002922:	7179                	addi	sp,sp,-48
    80002924:	f406                	sd	ra,40(sp)
    80002926:	f022                	sd	s0,32(sp)
    80002928:	ec26                	sd	s1,24(sp)
    8000292a:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    8000292c:	fd840593          	addi	a1,s0,-40
    80002930:	4501                	li	a0,0
    80002932:	eb5ff0ef          	jal	800027e6 <argint>
  argint(1, &t);
    80002936:	fdc40593          	addi	a1,s0,-36
    8000293a:	4505                	li	a0,1
    8000293c:	eabff0ef          	jal	800027e6 <argint>
  addr = myproc()->sz;
    80002940:	f63fe0ef          	jal	800018a2 <myproc>
    80002944:	6524                	ld	s1,72(a0)

  if (t == SBRK_EAGER || n < 0) {
    80002946:	fdc42703          	lw	a4,-36(s0)
    8000294a:	4785                	li	a5,1
    8000294c:	02f70763          	beq	a4,a5,8000297a <sys_sbrk+0x58>
    80002950:	fd842783          	lw	a5,-40(s0)
    80002954:	0207c363          	bltz	a5,8000297a <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
    80002958:	97a6                	add	a5,a5,s1
    8000295a:	0297ee63          	bltu	a5,s1,80002996 <sys_sbrk+0x74>
      return -1;
    if (addr + n > TRAPFRAME)
    8000295e:	02000737          	lui	a4,0x2000
    80002962:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002964:	0736                	slli	a4,a4,0xd
    80002966:	02f76a63          	bltu	a4,a5,8000299a <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    8000296a:	f39fe0ef          	jal	800018a2 <myproc>
    8000296e:	fd842703          	lw	a4,-40(s0)
    80002972:	653c                	ld	a5,72(a0)
    80002974:	97ba                	add	a5,a5,a4
    80002976:	e53c                	sd	a5,72(a0)
    80002978:	a039                	j	80002986 <sys_sbrk+0x64>
    if (growproc(n) < 0) {
    8000297a:	fd842503          	lw	a0,-40(s0)
    8000297e:	a2eff0ef          	jal	80001bac <growproc>
    80002982:	00054863          	bltz	a0,80002992 <sys_sbrk+0x70>
  }
  return addr;
}
    80002986:	8526                	mv	a0,s1
    80002988:	70a2                	ld	ra,40(sp)
    8000298a:	7402                	ld	s0,32(sp)
    8000298c:	64e2                	ld	s1,24(sp)
    8000298e:	6145                	addi	sp,sp,48
    80002990:	8082                	ret
      return -1;
    80002992:	54fd                	li	s1,-1
    80002994:	bfcd                	j	80002986 <sys_sbrk+0x64>
      return -1;
    80002996:	54fd                	li	s1,-1
    80002998:	b7fd                	j	80002986 <sys_sbrk+0x64>
      return -1;
    8000299a:	54fd                	li	s1,-1
    8000299c:	b7ed                	j	80002986 <sys_sbrk+0x64>

000000008000299e <sys_pause>:

uint64
sys_pause(void)
{
    8000299e:	7139                	addi	sp,sp,-64
    800029a0:	fc06                	sd	ra,56(sp)
    800029a2:	f822                	sd	s0,48(sp)
    800029a4:	ec4e                	sd	s3,24(sp)
    800029a6:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800029a8:	fcc40593          	addi	a1,s0,-52
    800029ac:	4501                	li	a0,0
    800029ae:	e39ff0ef          	jal	800027e6 <argint>
  if (n < 0)
    800029b2:	fcc42783          	lw	a5,-52(s0)
    800029b6:	0607cf63          	bltz	a5,80002a34 <sys_pause+0x96>
    n = 0;
  acquire(&tickslock);
    800029ba:	00015517          	auipc	a0,0x15
    800029be:	dd650513          	addi	a0,a0,-554 # 80017790 <tickslock>
    800029c2:	9cefe0ef          	jal	80000b90 <acquire>
  ticks0 = ticks;
    800029c6:	00007997          	auipc	s3,0x7
    800029ca:	e7a9a983          	lw	s3,-390(s3) # 80009840 <ticks>
  while (ticks - ticks0 < n) {
    800029ce:	fcc42783          	lw	a5,-52(s0)
    800029d2:	c7a9                	beqz	a5,80002a1c <sys_pause+0x7e>
    800029d4:	f426                	sd	s1,40(sp)
    800029d6:	f04a                	sd	s2,32(sp)
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    800029d8:	00007917          	auipc	s2,0x7
    800029dc:	e6890913          	addi	s2,s2,-408 # 80009840 <ticks>
    release(&tickslock);
    800029e0:	00015497          	auipc	s1,0x15
    800029e4:	db048493          	addi	s1,s1,-592 # 80017790 <tickslock>
    if (killed(myproc())) {
    800029e8:	ebbfe0ef          	jal	800018a2 <myproc>
    800029ec:	f1eff0ef          	jal	8000210a <killed>
    800029f0:	e529                	bnez	a0,80002a3a <sys_pause+0x9c>
    sleep_prepare(&ticks);
    800029f2:	854a                	mv	a0,s2
    800029f4:	cc2ff0ef          	jal	80001eb6 <sleep_prepare>
    release(&tickslock);
    800029f8:	8526                	mv	a0,s1
    800029fa:	a22fe0ef          	jal	80000c1c <release>
    sleep();
    800029fe:	cf4ff0ef          	jal	80001ef2 <sleep>
    acquire(&tickslock);
    80002a02:	8526                	mv	a0,s1
    80002a04:	98cfe0ef          	jal	80000b90 <acquire>
  while (ticks - ticks0 < n) {
    80002a08:	00092783          	lw	a5,0(s2)
    80002a0c:	413787bb          	subw	a5,a5,s3
    80002a10:	fcc42703          	lw	a4,-52(s0)
    80002a14:	fce7eae3          	bltu	a5,a4,800029e8 <sys_pause+0x4a>
    80002a18:	74a2                	ld	s1,40(sp)
    80002a1a:	7902                	ld	s2,32(sp)
  }
  release(&tickslock);
    80002a1c:	00015517          	auipc	a0,0x15
    80002a20:	d7450513          	addi	a0,a0,-652 # 80017790 <tickslock>
    80002a24:	9f8fe0ef          	jal	80000c1c <release>
  return 0;
    80002a28:	4501                	li	a0,0
}
    80002a2a:	70e2                	ld	ra,56(sp)
    80002a2c:	7442                	ld	s0,48(sp)
    80002a2e:	69e2                	ld	s3,24(sp)
    80002a30:	6121                	addi	sp,sp,64
    80002a32:	8082                	ret
    n = 0;
    80002a34:	fc042623          	sw	zero,-52(s0)
    80002a38:	b749                	j	800029ba <sys_pause+0x1c>
      release(&tickslock);
    80002a3a:	00015517          	auipc	a0,0x15
    80002a3e:	d5650513          	addi	a0,a0,-682 # 80017790 <tickslock>
    80002a42:	9dafe0ef          	jal	80000c1c <release>
      return -1;
    80002a46:	557d                	li	a0,-1
    80002a48:	74a2                	ld	s1,40(sp)
    80002a4a:	7902                	ld	s2,32(sp)
    80002a4c:	bff9                	j	80002a2a <sys_pause+0x8c>

0000000080002a4e <sys_kill>:

uint64
sys_kill(void)
{
    80002a4e:	1101                	addi	sp,sp,-32
    80002a50:	ec06                	sd	ra,24(sp)
    80002a52:	e822                	sd	s0,16(sp)
    80002a54:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a56:	fec40593          	addi	a1,s0,-20
    80002a5a:	4501                	li	a0,0
    80002a5c:	d8bff0ef          	jal	800027e6 <argint>
  return kkill(pid);
    80002a60:	fec42503          	lw	a0,-20(s0)
    80002a64:	e1cff0ef          	jal	80002080 <kkill>
}
    80002a68:	60e2                	ld	ra,24(sp)
    80002a6a:	6442                	ld	s0,16(sp)
    80002a6c:	6105                	addi	sp,sp,32
    80002a6e:	8082                	ret

0000000080002a70 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a70:	1101                	addi	sp,sp,-32
    80002a72:	ec06                	sd	ra,24(sp)
    80002a74:	e822                	sd	s0,16(sp)
    80002a76:	e426                	sd	s1,8(sp)
    80002a78:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a7a:	00015517          	auipc	a0,0x15
    80002a7e:	d1650513          	addi	a0,a0,-746 # 80017790 <tickslock>
    80002a82:	90efe0ef          	jal	80000b90 <acquire>
  xticks = ticks;
    80002a86:	00007497          	auipc	s1,0x7
    80002a8a:	dba4a483          	lw	s1,-582(s1) # 80009840 <ticks>
  release(&tickslock);
    80002a8e:	00015517          	auipc	a0,0x15
    80002a92:	d0250513          	addi	a0,a0,-766 # 80017790 <tickslock>
    80002a96:	986fe0ef          	jal	80000c1c <release>
  return xticks;
}
    80002a9a:	02049513          	slli	a0,s1,0x20
    80002a9e:	9101                	srli	a0,a0,0x20
    80002aa0:	60e2                	ld	ra,24(sp)
    80002aa2:	6442                	ld	s0,16(sp)
    80002aa4:	64a2                	ld	s1,8(sp)
    80002aa6:	6105                	addi	sp,sp,32
    80002aa8:	8082                	ret

0000000080002aaa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002aaa:	7179                	addi	sp,sp,-48
    80002aac:	f406                	sd	ra,40(sp)
    80002aae:	f022                	sd	s0,32(sp)
    80002ab0:	ec26                	sd	s1,24(sp)
    80002ab2:	e84a                	sd	s2,16(sp)
    80002ab4:	e44e                	sd	s3,8(sp)
    80002ab6:	e052                	sd	s4,0(sp)
    80002ab8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002aba:	00005597          	auipc	a1,0x5
    80002abe:	8f658593          	addi	a1,a1,-1802 # 800073b0 <etext+0x3b0>
    80002ac2:	00015517          	auipc	a0,0x15
    80002ac6:	ce650513          	addi	a0,a0,-794 # 800177a8 <bcache>
    80002aca:	850fe0ef          	jal	80000b1a <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ace:	0001d797          	auipc	a5,0x1d
    80002ad2:	cda78793          	addi	a5,a5,-806 # 8001f7a8 <bcache+0x8000>
    80002ad6:	0001d717          	auipc	a4,0x1d
    80002ada:	f3a70713          	addi	a4,a4,-198 # 8001fa10 <bcache+0x8268>
    80002ade:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ae2:	2ae7bc23          	sd	a4,696(a5)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002ae6:	00015497          	auipc	s1,0x15
    80002aea:	cda48493          	addi	s1,s1,-806 # 800177c0 <bcache+0x18>
    b->next = bcache.head.next;
    80002aee:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002af0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002af2:	00005a17          	auipc	s4,0x5
    80002af6:	8c6a0a13          	addi	s4,s4,-1850 # 800073b8 <etext+0x3b8>
    b->next = bcache.head.next;
    80002afa:	2b893783          	ld	a5,696(s2)
    80002afe:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b00:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b04:	85d2                	mv	a1,s4
    80002b06:	01048513          	addi	a0,s1,16
    80002b0a:	412010ef          	jal	80003f1c <initsleeplock>
    bcache.head.next->prev = b;
    80002b0e:	2b893783          	ld	a5,696(s2)
    80002b12:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b14:	2a993c23          	sd	s1,696(s2)
  for (b = bcache.buf; b < bcache.buf + NBUF; b++) {
    80002b18:	45848493          	addi	s1,s1,1112
    80002b1c:	fd349fe3          	bne	s1,s3,80002afa <binit+0x50>
  }
}
    80002b20:	70a2                	ld	ra,40(sp)
    80002b22:	7402                	ld	s0,32(sp)
    80002b24:	64e2                	ld	s1,24(sp)
    80002b26:	6942                	ld	s2,16(sp)
    80002b28:	69a2                	ld	s3,8(sp)
    80002b2a:	6a02                	ld	s4,0(sp)
    80002b2c:	6145                	addi	sp,sp,48
    80002b2e:	8082                	ret

0000000080002b30 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf *
bread(uint dev, uint blockno)
{
    80002b30:	7179                	addi	sp,sp,-48
    80002b32:	f406                	sd	ra,40(sp)
    80002b34:	f022                	sd	s0,32(sp)
    80002b36:	ec26                	sd	s1,24(sp)
    80002b38:	e84a                	sd	s2,16(sp)
    80002b3a:	e44e                	sd	s3,8(sp)
    80002b3c:	1800                	addi	s0,sp,48
    80002b3e:	892a                	mv	s2,a0
    80002b40:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b42:	00015517          	auipc	a0,0x15
    80002b46:	c6650513          	addi	a0,a0,-922 # 800177a8 <bcache>
    80002b4a:	846fe0ef          	jal	80000b90 <acquire>
  for (b = bcache.head.next; b != &bcache.head; b = b->next) {
    80002b4e:	0001d497          	auipc	s1,0x1d
    80002b52:	f124b483          	ld	s1,-238(s1) # 8001fa60 <bcache+0x82b8>
    80002b56:	0001d797          	auipc	a5,0x1d
    80002b5a:	eba78793          	addi	a5,a5,-326 # 8001fa10 <bcache+0x8268>
    80002b5e:	02f48b63          	beq	s1,a5,80002b94 <bread+0x64>
    80002b62:	873e                	mv	a4,a5
    80002b64:	a021                	j	80002b6c <bread+0x3c>
    80002b66:	68a4                	ld	s1,80(s1)
    80002b68:	02e48663          	beq	s1,a4,80002b94 <bread+0x64>
    if (b->dev == dev && b->blockno == blockno) {
    80002b6c:	449c                	lw	a5,8(s1)
    80002b6e:	ff279ce3          	bne	a5,s2,80002b66 <bread+0x36>
    80002b72:	44dc                	lw	a5,12(s1)
    80002b74:	ff3799e3          	bne	a5,s3,80002b66 <bread+0x36>
      b->refcnt++;
    80002b78:	40bc                	lw	a5,64(s1)
    80002b7a:	2785                	addiw	a5,a5,1
    80002b7c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002b7e:	00015517          	auipc	a0,0x15
    80002b82:	c2a50513          	addi	a0,a0,-982 # 800177a8 <bcache>
    80002b86:	896fe0ef          	jal	80000c1c <release>
      acquiresleep(&b->lock);
    80002b8a:	01048513          	addi	a0,s1,16
    80002b8e:	3c4010ef          	jal	80003f52 <acquiresleep>
      return b;
    80002b92:	a889                	j	80002be4 <bread+0xb4>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002b94:	0001d497          	auipc	s1,0x1d
    80002b98:	ec44b483          	ld	s1,-316(s1) # 8001fa58 <bcache+0x82b0>
    80002b9c:	0001d797          	auipc	a5,0x1d
    80002ba0:	e7478793          	addi	a5,a5,-396 # 8001fa10 <bcache+0x8268>
    80002ba4:	00f48863          	beq	s1,a5,80002bb4 <bread+0x84>
    80002ba8:	873e                	mv	a4,a5
    if (b->refcnt == 0) {
    80002baa:	40bc                	lw	a5,64(s1)
    80002bac:	cb91                	beqz	a5,80002bc0 <bread+0x90>
  for (b = bcache.head.prev; b != &bcache.head; b = b->prev) {
    80002bae:	64a4                	ld	s1,72(s1)
    80002bb0:	fee49de3          	bne	s1,a4,80002baa <bread+0x7a>
  panic("bget: no buffers");
    80002bb4:	00005517          	auipc	a0,0x5
    80002bb8:	80c50513          	addi	a0,a0,-2036 # 800073c0 <etext+0x3c0>
    80002bbc:	c35fd0ef          	jal	800007f0 <panic>
      b->dev = dev;
    80002bc0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002bc4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bc8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bcc:	4785                	li	a5,1
    80002bce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bd0:	00015517          	auipc	a0,0x15
    80002bd4:	bd850513          	addi	a0,a0,-1064 # 800177a8 <bcache>
    80002bd8:	844fe0ef          	jal	80000c1c <release>
      acquiresleep(&b->lock);
    80002bdc:	01048513          	addi	a0,s1,16
    80002be0:	372010ef          	jal	80003f52 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if (!b->valid) {
    80002be4:	409c                	lw	a5,0(s1)
    80002be6:	cb89                	beqz	a5,80002bf8 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002be8:	8526                	mv	a0,s1
    80002bea:	70a2                	ld	ra,40(sp)
    80002bec:	7402                	ld	s0,32(sp)
    80002bee:	64e2                	ld	s1,24(sp)
    80002bf0:	6942                	ld	s2,16(sp)
    80002bf2:	69a2                	ld	s3,8(sp)
    80002bf4:	6145                	addi	sp,sp,48
    80002bf6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002bf8:	4581                	li	a1,0
    80002bfa:	8526                	mv	a0,s1
    80002bfc:	495020ef          	jal	80005890 <virtio_disk_rw>
    b->valid = 1;
    80002c00:	4785                	li	a5,1
    80002c02:	c09c                	sw	a5,0(s1)
  return b;
    80002c04:	b7d5                	j	80002be8 <bread+0xb8>

0000000080002c06 <bwrite>:

// Write b's contents to disk.  Must be locked.
// Only the log calls bwrite.
void
bwrite(struct buf *b)
{
    80002c06:	1101                	addi	sp,sp,-32
    80002c08:	ec06                	sd	ra,24(sp)
    80002c0a:	e822                	sd	s0,16(sp)
    80002c0c:	e426                	sd	s1,8(sp)
    80002c0e:	1000                	addi	s0,sp,32
    80002c10:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002c12:	0541                	addi	a0,a0,16
    80002c14:	3ca010ef          	jal	80003fde <holdingsleep>
    80002c18:	c911                	beqz	a0,80002c2c <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c1a:	4585                	li	a1,1
    80002c1c:	8526                	mv	a0,s1
    80002c1e:	473020ef          	jal	80005890 <virtio_disk_rw>
}
    80002c22:	60e2                	ld	ra,24(sp)
    80002c24:	6442                	ld	s0,16(sp)
    80002c26:	64a2                	ld	s1,8(sp)
    80002c28:	6105                	addi	sp,sp,32
    80002c2a:	8082                	ret
    panic("bwrite");
    80002c2c:	00004517          	auipc	a0,0x4
    80002c30:	7ac50513          	addi	a0,a0,1964 # 800073d8 <etext+0x3d8>
    80002c34:	bbdfd0ef          	jal	800007f0 <panic>

0000000080002c38 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c38:	1101                	addi	sp,sp,-32
    80002c3a:	ec06                	sd	ra,24(sp)
    80002c3c:	e822                	sd	s0,16(sp)
    80002c3e:	e426                	sd	s1,8(sp)
    80002c40:	e04a                	sd	s2,0(sp)
    80002c42:	1000                	addi	s0,sp,32
    80002c44:	84aa                	mv	s1,a0
  if (!holdingsleep(&b->lock))
    80002c46:	01050913          	addi	s2,a0,16
    80002c4a:	854a                	mv	a0,s2
    80002c4c:	392010ef          	jal	80003fde <holdingsleep>
    80002c50:	c135                	beqz	a0,80002cb4 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c52:	854a                	mv	a0,s2
    80002c54:	352010ef          	jal	80003fa6 <releasesleep>

  acquire(&bcache.lock);
    80002c58:	00015517          	auipc	a0,0x15
    80002c5c:	b5050513          	addi	a0,a0,-1200 # 800177a8 <bcache>
    80002c60:	f31fd0ef          	jal	80000b90 <acquire>
  b->refcnt--;
    80002c64:	40bc                	lw	a5,64(s1)
    80002c66:	37fd                	addiw	a5,a5,-1
    80002c68:	0007871b          	sext.w	a4,a5
    80002c6c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c6e:	e71d                	bnez	a4,80002c9c <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c70:	68b8                	ld	a4,80(s1)
    80002c72:	64bc                	ld	a5,72(s1)
    80002c74:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002c76:	68b8                	ld	a4,80(s1)
    80002c78:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002c7a:	0001d797          	auipc	a5,0x1d
    80002c7e:	b2e78793          	addi	a5,a5,-1234 # 8001f7a8 <bcache+0x8000>
    80002c82:	2b87b703          	ld	a4,696(a5)
    80002c86:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002c88:	0001d717          	auipc	a4,0x1d
    80002c8c:	d8870713          	addi	a4,a4,-632 # 8001fa10 <bcache+0x8268>
    80002c90:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002c92:	2b87b703          	ld	a4,696(a5)
    80002c96:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002c98:	2a97bc23          	sd	s1,696(a5)
  }

  release(&bcache.lock);
    80002c9c:	00015517          	auipc	a0,0x15
    80002ca0:	b0c50513          	addi	a0,a0,-1268 # 800177a8 <bcache>
    80002ca4:	f79fd0ef          	jal	80000c1c <release>
}
    80002ca8:	60e2                	ld	ra,24(sp)
    80002caa:	6442                	ld	s0,16(sp)
    80002cac:	64a2                	ld	s1,8(sp)
    80002cae:	6902                	ld	s2,0(sp)
    80002cb0:	6105                	addi	sp,sp,32
    80002cb2:	8082                	ret
    panic("brelse");
    80002cb4:	00004517          	auipc	a0,0x4
    80002cb8:	72c50513          	addi	a0,a0,1836 # 800073e0 <etext+0x3e0>
    80002cbc:	b35fd0ef          	jal	800007f0 <panic>

0000000080002cc0 <bpin>:

void
bpin(struct buf *b)
{
    80002cc0:	1101                	addi	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	e426                	sd	s1,8(sp)
    80002cc8:	1000                	addi	s0,sp,32
    80002cca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002ccc:	00015517          	auipc	a0,0x15
    80002cd0:	adc50513          	addi	a0,a0,-1316 # 800177a8 <bcache>
    80002cd4:	ebdfd0ef          	jal	80000b90 <acquire>
  b->refcnt++;
    80002cd8:	40bc                	lw	a5,64(s1)
    80002cda:	2785                	addiw	a5,a5,1
    80002cdc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002cde:	00015517          	auipc	a0,0x15
    80002ce2:	aca50513          	addi	a0,a0,-1334 # 800177a8 <bcache>
    80002ce6:	f37fd0ef          	jal	80000c1c <release>
}
    80002cea:	60e2                	ld	ra,24(sp)
    80002cec:	6442                	ld	s0,16(sp)
    80002cee:	64a2                	ld	s1,8(sp)
    80002cf0:	6105                	addi	sp,sp,32
    80002cf2:	8082                	ret

0000000080002cf4 <bunpin>:

void
bunpin(struct buf *b)
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	e426                	sd	s1,8(sp)
    80002cfc:	1000                	addi	s0,sp,32
    80002cfe:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d00:	00015517          	auipc	a0,0x15
    80002d04:	aa850513          	addi	a0,a0,-1368 # 800177a8 <bcache>
    80002d08:	e89fd0ef          	jal	80000b90 <acquire>
  b->refcnt--;
    80002d0c:	40bc                	lw	a5,64(s1)
    80002d0e:	37fd                	addiw	a5,a5,-1
    80002d10:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d12:	00015517          	auipc	a0,0x15
    80002d16:	a9650513          	addi	a0,a0,-1386 # 800177a8 <bcache>
    80002d1a:	f03fd0ef          	jal	80000c1c <release>
}
    80002d1e:	60e2                	ld	ra,24(sp)
    80002d20:	6442                	ld	s0,16(sp)
    80002d22:	64a2                	ld	s1,8(sp)
    80002d24:	6105                	addi	sp,sp,32
    80002d26:	8082                	ret

0000000080002d28 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d28:	1101                	addi	sp,sp,-32
    80002d2a:	ec06                	sd	ra,24(sp)
    80002d2c:	e822                	sd	s0,16(sp)
    80002d2e:	e426                	sd	s1,8(sp)
    80002d30:	e04a                	sd	s2,0(sp)
    80002d32:	1000                	addi	s0,sp,32
    80002d34:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d36:	00d5d59b          	srliw	a1,a1,0xd
    80002d3a:	0001d797          	auipc	a5,0x1d
    80002d3e:	14a7a783          	lw	a5,330(a5) # 8001fe84 <sb+0x1c>
    80002d42:	9dbd                	addw	a1,a1,a5
    80002d44:	dedff0ef          	jal	80002b30 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d48:	0074f713          	andi	a4,s1,7
    80002d4c:	4785                	li	a5,1
    80002d4e:	00e797bb          	sllw	a5,a5,a4
  if ((bp->data[bi / 8] & m) == 0)
    80002d52:	14ce                	slli	s1,s1,0x33
    80002d54:	90d9                	srli	s1,s1,0x36
    80002d56:	00950733          	add	a4,a0,s1
    80002d5a:	05874703          	lbu	a4,88(a4)
    80002d5e:	00e7f6b3          	and	a3,a5,a4
    80002d62:	c29d                	beqz	a3,80002d88 <bfree+0x60>
    80002d64:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi / 8] &= ~m;
    80002d66:	94aa                	add	s1,s1,a0
    80002d68:	fff7c793          	not	a5,a5
    80002d6c:	8f7d                	and	a4,a4,a5
    80002d6e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d72:	078010ef          	jal	80003dea <log_write>
  brelse(bp);
    80002d76:	854a                	mv	a0,s2
    80002d78:	ec1ff0ef          	jal	80002c38 <brelse>
}
    80002d7c:	60e2                	ld	ra,24(sp)
    80002d7e:	6442                	ld	s0,16(sp)
    80002d80:	64a2                	ld	s1,8(sp)
    80002d82:	6902                	ld	s2,0(sp)
    80002d84:	6105                	addi	sp,sp,32
    80002d86:	8082                	ret
    panic("freeing free block");
    80002d88:	00004517          	auipc	a0,0x4
    80002d8c:	66050513          	addi	a0,a0,1632 # 800073e8 <etext+0x3e8>
    80002d90:	a61fd0ef          	jal	800007f0 <panic>

0000000080002d94 <balloc>:
{
    80002d94:	711d                	addi	sp,sp,-96
    80002d96:	ec86                	sd	ra,88(sp)
    80002d98:	e8a2                	sd	s0,80(sp)
    80002d9a:	e4a6                	sd	s1,72(sp)
    80002d9c:	1080                	addi	s0,sp,96
  for (b = 0; b < sb.size; b += BPB) {
    80002d9e:	0001d797          	auipc	a5,0x1d
    80002da2:	0ce7a783          	lw	a5,206(a5) # 8001fe6c <sb+0x4>
    80002da6:	0e078f63          	beqz	a5,80002ea4 <balloc+0x110>
    80002daa:	e0ca                	sd	s2,64(sp)
    80002dac:	fc4e                	sd	s3,56(sp)
    80002dae:	f852                	sd	s4,48(sp)
    80002db0:	f456                	sd	s5,40(sp)
    80002db2:	f05a                	sd	s6,32(sp)
    80002db4:	ec5e                	sd	s7,24(sp)
    80002db6:	e862                	sd	s8,16(sp)
    80002db8:	e466                	sd	s9,8(sp)
    80002dba:	8baa                	mv	s7,a0
    80002dbc:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002dbe:	0001db17          	auipc	s6,0x1d
    80002dc2:	0aab0b13          	addi	s6,s6,170 # 8001fe68 <sb>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002dc6:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002dc8:	4985                	li	s3,1
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002dca:	6a09                	lui	s4,0x2
  for (b = 0; b < sb.size; b += BPB) {
    80002dcc:	6c89                	lui	s9,0x2
    80002dce:	a0b5                	j	80002e3a <balloc+0xa6>
        bp->data[bi / 8] |= m;           // Mark block in use.
    80002dd0:	97ca                	add	a5,a5,s2
    80002dd2:	8e55                	or	a2,a2,a3
    80002dd4:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002dd8:	854a                	mv	a0,s2
    80002dda:	010010ef          	jal	80003dea <log_write>
        brelse(bp);
    80002dde:	854a                	mv	a0,s2
    80002de0:	e59ff0ef          	jal	80002c38 <brelse>
  bp = bread(dev, bno);
    80002de4:	85a6                	mv	a1,s1
    80002de6:	855e                	mv	a0,s7
    80002de8:	d49ff0ef          	jal	80002b30 <bread>
    80002dec:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002dee:	40000613          	li	a2,1024
    80002df2:	4581                	li	a1,0
    80002df4:	05850513          	addi	a0,a0,88
    80002df8:	e5dfd0ef          	jal	80000c54 <memset>
  log_write(bp);
    80002dfc:	854a                	mv	a0,s2
    80002dfe:	7ed000ef          	jal	80003dea <log_write>
  brelse(bp);
    80002e02:	854a                	mv	a0,s2
    80002e04:	e35ff0ef          	jal	80002c38 <brelse>
}
    80002e08:	6906                	ld	s2,64(sp)
    80002e0a:	79e2                	ld	s3,56(sp)
    80002e0c:	7a42                	ld	s4,48(sp)
    80002e0e:	7aa2                	ld	s5,40(sp)
    80002e10:	7b02                	ld	s6,32(sp)
    80002e12:	6be2                	ld	s7,24(sp)
    80002e14:	6c42                	ld	s8,16(sp)
    80002e16:	6ca2                	ld	s9,8(sp)
}
    80002e18:	8526                	mv	a0,s1
    80002e1a:	60e6                	ld	ra,88(sp)
    80002e1c:	6446                	ld	s0,80(sp)
    80002e1e:	64a6                	ld	s1,72(sp)
    80002e20:	6125                	addi	sp,sp,96
    80002e22:	8082                	ret
    brelse(bp);
    80002e24:	854a                	mv	a0,s2
    80002e26:	e13ff0ef          	jal	80002c38 <brelse>
  for (b = 0; b < sb.size; b += BPB) {
    80002e2a:	015c87bb          	addw	a5,s9,s5
    80002e2e:	00078a9b          	sext.w	s5,a5
    80002e32:	004b2703          	lw	a4,4(s6)
    80002e36:	04eaff63          	bgeu	s5,a4,80002e94 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e3a:	41fad79b          	sraiw	a5,s5,0x1f
    80002e3e:	0137d79b          	srliw	a5,a5,0x13
    80002e42:	015787bb          	addw	a5,a5,s5
    80002e46:	40d7d79b          	sraiw	a5,a5,0xd
    80002e4a:	01cb2583          	lw	a1,28(s6)
    80002e4e:	9dbd                	addw	a1,a1,a5
    80002e50:	855e                	mv	a0,s7
    80002e52:	cdfff0ef          	jal	80002b30 <bread>
    80002e56:	892a                	mv	s2,a0
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e58:	004b2503          	lw	a0,4(s6)
    80002e5c:	000a849b          	sext.w	s1,s5
    80002e60:	8762                	mv	a4,s8
    80002e62:	fca4f1e3          	bgeu	s1,a0,80002e24 <balloc+0x90>
      m = 1 << (bi % 8);
    80002e66:	00777693          	andi	a3,a4,7
    80002e6a:	00d996bb          	sllw	a3,s3,a3
      if ((bp->data[bi / 8] & m) == 0) { // Is block free?
    80002e6e:	41f7579b          	sraiw	a5,a4,0x1f
    80002e72:	01d7d79b          	srliw	a5,a5,0x1d
    80002e76:	9fb9                	addw	a5,a5,a4
    80002e78:	4037d79b          	sraiw	a5,a5,0x3
    80002e7c:	00f90633          	add	a2,s2,a5
    80002e80:	05864603          	lbu	a2,88(a2) # 1058 <_entry-0x7fffefa8>
    80002e84:	00c6f5b3          	and	a1,a3,a2
    80002e88:	d5a1                	beqz	a1,80002dd0 <balloc+0x3c>
    for (bi = 0; bi < BPB && b + bi < sb.size; bi++) {
    80002e8a:	2705                	addiw	a4,a4,1
    80002e8c:	2485                	addiw	s1,s1,1
    80002e8e:	fd471ae3          	bne	a4,s4,80002e62 <balloc+0xce>
    80002e92:	bf49                	j	80002e24 <balloc+0x90>
    80002e94:	6906                	ld	s2,64(sp)
    80002e96:	79e2                	ld	s3,56(sp)
    80002e98:	7a42                	ld	s4,48(sp)
    80002e9a:	7aa2                	ld	s5,40(sp)
    80002e9c:	7b02                	ld	s6,32(sp)
    80002e9e:	6be2                	ld	s7,24(sp)
    80002ea0:	6c42                	ld	s8,16(sp)
    80002ea2:	6ca2                	ld	s9,8(sp)
  printk("balloc: out of blocks\n");
    80002ea4:	00004517          	auipc	a0,0x4
    80002ea8:	55c50513          	addi	a0,a0,1372 # 80007400 <etext+0x400>
    80002eac:	e5efd0ef          	jal	8000050a <printk>
  return 0;
    80002eb0:	4481                	li	s1,0
    80002eb2:	b79d                	j	80002e18 <balloc+0x84>

0000000080002eb4 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002eb4:	7179                	addi	sp,sp,-48
    80002eb6:	f406                	sd	ra,40(sp)
    80002eb8:	f022                	sd	s0,32(sp)
    80002eba:	ec26                	sd	s1,24(sp)
    80002ebc:	e84a                	sd	s2,16(sp)
    80002ebe:	e44e                	sd	s3,8(sp)
    80002ec0:	1800                	addi	s0,sp,48
    80002ec2:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if (bn < NDIRECT) {
    80002ec4:	47ad                	li	a5,11
    80002ec6:	02b7e663          	bltu	a5,a1,80002ef2 <bmap+0x3e>
    if ((addr = ip->addrs[bn]) == 0) {
    80002eca:	02059793          	slli	a5,a1,0x20
    80002ece:	01e7d593          	srli	a1,a5,0x1e
    80002ed2:	00b504b3          	add	s1,a0,a1
    80002ed6:	0504a903          	lw	s2,80(s1)
    80002eda:	06091a63          	bnez	s2,80002f4e <bmap+0x9a>
      addr = balloc(ip->dev);
    80002ede:	4108                	lw	a0,0(a0)
    80002ee0:	eb5ff0ef          	jal	80002d94 <balloc>
    80002ee4:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80002ee8:	06090363          	beqz	s2,80002f4e <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002eec:	0524a823          	sw	s2,80(s1)
    80002ef0:	a8b9                	j	80002f4e <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002ef2:	ff45849b          	addiw	s1,a1,-12
    80002ef6:	0004871b          	sext.w	a4,s1

  if (bn < NINDIRECT) {
    80002efa:	0ff00793          	li	a5,255
    80002efe:	06e7ee63          	bltu	a5,a4,80002f7a <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if ((addr = ip->addrs[NDIRECT]) == 0) {
    80002f02:	08052903          	lw	s2,128(a0)
    80002f06:	00091d63          	bnez	s2,80002f20 <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f0a:	4108                	lw	a0,0(a0)
    80002f0c:	e89ff0ef          	jal	80002d94 <balloc>
    80002f10:	0005091b          	sext.w	s2,a0
      if (addr == 0)
    80002f14:	02090d63          	beqz	s2,80002f4e <bmap+0x9a>
    80002f18:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f1a:	0929a023          	sw	s2,128(s3)
    80002f1e:	a011                	j	80002f22 <bmap+0x6e>
    80002f20:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f22:	85ca                	mv	a1,s2
    80002f24:	0009a503          	lw	a0,0(s3)
    80002f28:	c09ff0ef          	jal	80002b30 <bread>
    80002f2c:	8a2a                	mv	s4,a0
    a = (uint *)bp->data;
    80002f2e:	05850793          	addi	a5,a0,88
    if ((addr = a[bn]) == 0) {
    80002f32:	02049713          	slli	a4,s1,0x20
    80002f36:	01e75593          	srli	a1,a4,0x1e
    80002f3a:	00b784b3          	add	s1,a5,a1
    80002f3e:	0004a903          	lw	s2,0(s1)
    80002f42:	00090e63          	beqz	s2,80002f5e <bmap+0xaa>
      if (addr) {
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f46:	8552                	mv	a0,s4
    80002f48:	cf1ff0ef          	jal	80002c38 <brelse>
    return addr;
    80002f4c:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f4e:	854a                	mv	a0,s2
    80002f50:	70a2                	ld	ra,40(sp)
    80002f52:	7402                	ld	s0,32(sp)
    80002f54:	64e2                	ld	s1,24(sp)
    80002f56:	6942                	ld	s2,16(sp)
    80002f58:	69a2                	ld	s3,8(sp)
    80002f5a:	6145                	addi	sp,sp,48
    80002f5c:	8082                	ret
      addr = balloc(ip->dev);
    80002f5e:	0009a503          	lw	a0,0(s3)
    80002f62:	e33ff0ef          	jal	80002d94 <balloc>
    80002f66:	0005091b          	sext.w	s2,a0
      if (addr) {
    80002f6a:	fc090ee3          	beqz	s2,80002f46 <bmap+0x92>
        a[bn] = addr;
    80002f6e:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f72:	8552                	mv	a0,s4
    80002f74:	677000ef          	jal	80003dea <log_write>
    80002f78:	b7f9                	j	80002f46 <bmap+0x92>
    80002f7a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002f7c:	00004517          	auipc	a0,0x4
    80002f80:	49c50513          	addi	a0,a0,1180 # 80007418 <etext+0x418>
    80002f84:	86dfd0ef          	jal	800007f0 <panic>

0000000080002f88 <iget>:
{
    80002f88:	7179                	addi	sp,sp,-48
    80002f8a:	f406                	sd	ra,40(sp)
    80002f8c:	f022                	sd	s0,32(sp)
    80002f8e:	ec26                	sd	s1,24(sp)
    80002f90:	e84a                	sd	s2,16(sp)
    80002f92:	e44e                	sd	s3,8(sp)
    80002f94:	e052                	sd	s4,0(sp)
    80002f96:	1800                	addi	s0,sp,48
    80002f98:	89aa                	mv	s3,a0
    80002f9a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002f9c:	0001d517          	auipc	a0,0x1d
    80002fa0:	eec50513          	addi	a0,a0,-276 # 8001fe88 <itable>
    80002fa4:	bedfd0ef          	jal	80000b90 <acquire>
  empty = 0;
    80002fa8:	4901                	li	s2,0
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002faa:	0001d497          	auipc	s1,0x1d
    80002fae:	ef648493          	addi	s1,s1,-266 # 8001fea0 <itable+0x18>
    80002fb2:	0001f697          	auipc	a3,0x1f
    80002fb6:	97e68693          	addi	a3,a3,-1666 # 80021930 <log>
    80002fba:	a039                	j	80002fc8 <iget+0x40>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80002fbc:	02090963          	beqz	s2,80002fee <iget+0x66>
  for (ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++) {
    80002fc0:	08848493          	addi	s1,s1,136
    80002fc4:	02d48863          	beq	s1,a3,80002ff4 <iget+0x6c>
    if (ip->ref > 0 && ip->dev == dev && ip->inum == inum) {
    80002fc8:	449c                	lw	a5,8(s1)
    80002fca:	fef059e3          	blez	a5,80002fbc <iget+0x34>
    80002fce:	4098                	lw	a4,0(s1)
    80002fd0:	ff3716e3          	bne	a4,s3,80002fbc <iget+0x34>
    80002fd4:	40d8                	lw	a4,4(s1)
    80002fd6:	ff4713e3          	bne	a4,s4,80002fbc <iget+0x34>
      ip->ref++;
    80002fda:	2785                	addiw	a5,a5,1
    80002fdc:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002fde:	0001d517          	auipc	a0,0x1d
    80002fe2:	eaa50513          	addi	a0,a0,-342 # 8001fe88 <itable>
    80002fe6:	c37fd0ef          	jal	80000c1c <release>
      return ip;
    80002fea:	8926                	mv	s2,s1
    80002fec:	a02d                	j	80003016 <iget+0x8e>
    if (empty == 0 && ip->ref == 0) // Remember empty slot.
    80002fee:	fbe9                	bnez	a5,80002fc0 <iget+0x38>
      empty = ip;
    80002ff0:	8926                	mv	s2,s1
    80002ff2:	b7f9                	j	80002fc0 <iget+0x38>
  if (empty == 0)
    80002ff4:	02090a63          	beqz	s2,80003028 <iget+0xa0>
  ip->dev = dev;
    80002ff8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002ffc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003000:	4785                	li	a5,1
    80003002:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003006:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000300a:	0001d517          	auipc	a0,0x1d
    8000300e:	e7e50513          	addi	a0,a0,-386 # 8001fe88 <itable>
    80003012:	c0bfd0ef          	jal	80000c1c <release>
}
    80003016:	854a                	mv	a0,s2
    80003018:	70a2                	ld	ra,40(sp)
    8000301a:	7402                	ld	s0,32(sp)
    8000301c:	64e2                	ld	s1,24(sp)
    8000301e:	6942                	ld	s2,16(sp)
    80003020:	69a2                	ld	s3,8(sp)
    80003022:	6a02                	ld	s4,0(sp)
    80003024:	6145                	addi	sp,sp,48
    80003026:	8082                	ret
    panic("iget: no inodes");
    80003028:	00004517          	auipc	a0,0x4
    8000302c:	40850513          	addi	a0,a0,1032 # 80007430 <etext+0x430>
    80003030:	fc0fd0ef          	jal	800007f0 <panic>

0000000080003034 <iinit>:
{
    80003034:	7179                	addi	sp,sp,-48
    80003036:	f406                	sd	ra,40(sp)
    80003038:	f022                	sd	s0,32(sp)
    8000303a:	ec26                	sd	s1,24(sp)
    8000303c:	e84a                	sd	s2,16(sp)
    8000303e:	e44e                	sd	s3,8(sp)
    80003040:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003042:	00004597          	auipc	a1,0x4
    80003046:	3fe58593          	addi	a1,a1,1022 # 80007440 <etext+0x440>
    8000304a:	0001d517          	auipc	a0,0x1d
    8000304e:	e3e50513          	addi	a0,a0,-450 # 8001fe88 <itable>
    80003052:	ac9fd0ef          	jal	80000b1a <initlock>
  for (i = 0; i < NINODE; i++) {
    80003056:	0001d497          	auipc	s1,0x1d
    8000305a:	e5a48493          	addi	s1,s1,-422 # 8001feb0 <itable+0x28>
    8000305e:	0001f997          	auipc	s3,0x1f
    80003062:	8e298993          	addi	s3,s3,-1822 # 80021940 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003066:	00004917          	auipc	s2,0x4
    8000306a:	3e290913          	addi	s2,s2,994 # 80007448 <etext+0x448>
    8000306e:	85ca                	mv	a1,s2
    80003070:	8526                	mv	a0,s1
    80003072:	6ab000ef          	jal	80003f1c <initsleeplock>
  for (i = 0; i < NINODE; i++) {
    80003076:	08848493          	addi	s1,s1,136
    8000307a:	ff349ae3          	bne	s1,s3,8000306e <iinit+0x3a>
}
    8000307e:	70a2                	ld	ra,40(sp)
    80003080:	7402                	ld	s0,32(sp)
    80003082:	64e2                	ld	s1,24(sp)
    80003084:	6942                	ld	s2,16(sp)
    80003086:	69a2                	ld	s3,8(sp)
    80003088:	6145                	addi	sp,sp,48
    8000308a:	8082                	ret

000000008000308c <ialloc>:
{
    8000308c:	7139                	addi	sp,sp,-64
    8000308e:	fc06                	sd	ra,56(sp)
    80003090:	f822                	sd	s0,48(sp)
    80003092:	0080                	addi	s0,sp,64
  for (inum = 1; inum < sb.ninodes; inum++) {
    80003094:	0001d717          	auipc	a4,0x1d
    80003098:	de072703          	lw	a4,-544(a4) # 8001fe74 <sb+0xc>
    8000309c:	4785                	li	a5,1
    8000309e:	06e7f063          	bgeu	a5,a4,800030fe <ialloc+0x72>
    800030a2:	f426                	sd	s1,40(sp)
    800030a4:	f04a                	sd	s2,32(sp)
    800030a6:	ec4e                	sd	s3,24(sp)
    800030a8:	e852                	sd	s4,16(sp)
    800030aa:	e456                	sd	s5,8(sp)
    800030ac:	e05a                	sd	s6,0(sp)
    800030ae:	8aaa                	mv	s5,a0
    800030b0:	8b2e                	mv	s6,a1
    800030b2:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800030b4:	0001da17          	auipc	s4,0x1d
    800030b8:	db4a0a13          	addi	s4,s4,-588 # 8001fe68 <sb>
    800030bc:	00495593          	srli	a1,s2,0x4
    800030c0:	018a2783          	lw	a5,24(s4)
    800030c4:	9dbd                	addw	a1,a1,a5
    800030c6:	8556                	mv	a0,s5
    800030c8:	a69ff0ef          	jal	80002b30 <bread>
    800030cc:	84aa                	mv	s1,a0
    dip = (struct dinode *)bp->data + inum % IPB;
    800030ce:	05850993          	addi	s3,a0,88
    800030d2:	00f97793          	andi	a5,s2,15
    800030d6:	079a                	slli	a5,a5,0x6
    800030d8:	99be                	add	s3,s3,a5
    if (dip->type == 0) { // a free inode
    800030da:	00099783          	lh	a5,0(s3)
    800030de:	cb9d                	beqz	a5,80003114 <ialloc+0x88>
    brelse(bp);
    800030e0:	b59ff0ef          	jal	80002c38 <brelse>
  for (inum = 1; inum < sb.ninodes; inum++) {
    800030e4:	0905                	addi	s2,s2,1
    800030e6:	00ca2703          	lw	a4,12(s4)
    800030ea:	0009079b          	sext.w	a5,s2
    800030ee:	fce7e7e3          	bltu	a5,a4,800030bc <ialloc+0x30>
    800030f2:	74a2                	ld	s1,40(sp)
    800030f4:	7902                	ld	s2,32(sp)
    800030f6:	69e2                	ld	s3,24(sp)
    800030f8:	6a42                	ld	s4,16(sp)
    800030fa:	6aa2                	ld	s5,8(sp)
    800030fc:	6b02                	ld	s6,0(sp)
  printk("ialloc: no inodes\n");
    800030fe:	00004517          	auipc	a0,0x4
    80003102:	35250513          	addi	a0,a0,850 # 80007450 <etext+0x450>
    80003106:	c04fd0ef          	jal	8000050a <printk>
  return 0;
    8000310a:	4501                	li	a0,0
}
    8000310c:	70e2                	ld	ra,56(sp)
    8000310e:	7442                	ld	s0,48(sp)
    80003110:	6121                	addi	sp,sp,64
    80003112:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003114:	04000613          	li	a2,64
    80003118:	4581                	li	a1,0
    8000311a:	854e                	mv	a0,s3
    8000311c:	b39fd0ef          	jal	80000c54 <memset>
      dip->type = type;
    80003120:	01699023          	sh	s6,0(s3)
      log_write(bp); // mark it allocated on the disk
    80003124:	8526                	mv	a0,s1
    80003126:	4c5000ef          	jal	80003dea <log_write>
      brelse(bp);
    8000312a:	8526                	mv	a0,s1
    8000312c:	b0dff0ef          	jal	80002c38 <brelse>
      return iget(dev, inum);
    80003130:	0009059b          	sext.w	a1,s2
    80003134:	8556                	mv	a0,s5
    80003136:	e53ff0ef          	jal	80002f88 <iget>
    8000313a:	74a2                	ld	s1,40(sp)
    8000313c:	7902                	ld	s2,32(sp)
    8000313e:	69e2                	ld	s3,24(sp)
    80003140:	6a42                	ld	s4,16(sp)
    80003142:	6aa2                	ld	s5,8(sp)
    80003144:	6b02                	ld	s6,0(sp)
    80003146:	b7d9                	j	8000310c <ialloc+0x80>

0000000080003148 <iupdate>:
{
    80003148:	1101                	addi	sp,sp,-32
    8000314a:	ec06                	sd	ra,24(sp)
    8000314c:	e822                	sd	s0,16(sp)
    8000314e:	e426                	sd	s1,8(sp)
    80003150:	e04a                	sd	s2,0(sp)
    80003152:	1000                	addi	s0,sp,32
    80003154:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003156:	415c                	lw	a5,4(a0)
    80003158:	0047d79b          	srliw	a5,a5,0x4
    8000315c:	0001d597          	auipc	a1,0x1d
    80003160:	d245a583          	lw	a1,-732(a1) # 8001fe80 <sb+0x18>
    80003164:	9dbd                	addw	a1,a1,a5
    80003166:	4108                	lw	a0,0(a0)
    80003168:	9c9ff0ef          	jal	80002b30 <bread>
    8000316c:	892a                	mv	s2,a0
  dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000316e:	05850793          	addi	a5,a0,88
    80003172:	40d8                	lw	a4,4(s1)
    80003174:	8b3d                	andi	a4,a4,15
    80003176:	071a                	slli	a4,a4,0x6
    80003178:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000317a:	04449703          	lh	a4,68(s1)
    8000317e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003182:	04649703          	lh	a4,70(s1)
    80003186:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000318a:	04849703          	lh	a4,72(s1)
    8000318e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003192:	04a49703          	lh	a4,74(s1)
    80003196:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000319a:	44f8                	lw	a4,76(s1)
    8000319c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000319e:	03400613          	li	a2,52
    800031a2:	05048593          	addi	a1,s1,80
    800031a6:	00c78513          	addi	a0,a5,12
    800031aa:	b07fd0ef          	jal	80000cb0 <memmove>
  log_write(bp);
    800031ae:	854a                	mv	a0,s2
    800031b0:	43b000ef          	jal	80003dea <log_write>
  brelse(bp);
    800031b4:	854a                	mv	a0,s2
    800031b6:	a83ff0ef          	jal	80002c38 <brelse>
}
    800031ba:	60e2                	ld	ra,24(sp)
    800031bc:	6442                	ld	s0,16(sp)
    800031be:	64a2                	ld	s1,8(sp)
    800031c0:	6902                	ld	s2,0(sp)
    800031c2:	6105                	addi	sp,sp,32
    800031c4:	8082                	ret

00000000800031c6 <idup>:
{
    800031c6:	1101                	addi	sp,sp,-32
    800031c8:	ec06                	sd	ra,24(sp)
    800031ca:	e822                	sd	s0,16(sp)
    800031cc:	e426                	sd	s1,8(sp)
    800031ce:	1000                	addi	s0,sp,32
    800031d0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800031d2:	0001d517          	auipc	a0,0x1d
    800031d6:	cb650513          	addi	a0,a0,-842 # 8001fe88 <itable>
    800031da:	9b7fd0ef          	jal	80000b90 <acquire>
  ip->ref++;
    800031de:	449c                	lw	a5,8(s1)
    800031e0:	2785                	addiw	a5,a5,1
    800031e2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800031e4:	0001d517          	auipc	a0,0x1d
    800031e8:	ca450513          	addi	a0,a0,-860 # 8001fe88 <itable>
    800031ec:	a31fd0ef          	jal	80000c1c <release>
}
    800031f0:	8526                	mv	a0,s1
    800031f2:	60e2                	ld	ra,24(sp)
    800031f4:	6442                	ld	s0,16(sp)
    800031f6:	64a2                	ld	s1,8(sp)
    800031f8:	6105                	addi	sp,sp,32
    800031fa:	8082                	ret

00000000800031fc <ilock>:
{
    800031fc:	1101                	addi	sp,sp,-32
    800031fe:	ec06                	sd	ra,24(sp)
    80003200:	e822                	sd	s0,16(sp)
    80003202:	e426                	sd	s1,8(sp)
    80003204:	1000                	addi	s0,sp,32
  if (ip == 0 || ip->ref < 1)
    80003206:	cd19                	beqz	a0,80003224 <ilock+0x28>
    80003208:	84aa                	mv	s1,a0
    8000320a:	451c                	lw	a5,8(a0)
    8000320c:	00f05c63          	blez	a5,80003224 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003210:	0541                	addi	a0,a0,16
    80003212:	541000ef          	jal	80003f52 <acquiresleep>
  if (ip->valid == 0) {
    80003216:	40bc                	lw	a5,64(s1)
    80003218:	cf89                	beqz	a5,80003232 <ilock+0x36>
}
    8000321a:	60e2                	ld	ra,24(sp)
    8000321c:	6442                	ld	s0,16(sp)
    8000321e:	64a2                	ld	s1,8(sp)
    80003220:	6105                	addi	sp,sp,32
    80003222:	8082                	ret
    80003224:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003226:	00004517          	auipc	a0,0x4
    8000322a:	24250513          	addi	a0,a0,578 # 80007468 <etext+0x468>
    8000322e:	dc2fd0ef          	jal	800007f0 <panic>
    80003232:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003234:	40dc                	lw	a5,4(s1)
    80003236:	0047d79b          	srliw	a5,a5,0x4
    8000323a:	0001d597          	auipc	a1,0x1d
    8000323e:	c465a583          	lw	a1,-954(a1) # 8001fe80 <sb+0x18>
    80003242:	9dbd                	addw	a1,a1,a5
    80003244:	4088                	lw	a0,0(s1)
    80003246:	8ebff0ef          	jal	80002b30 <bread>
    8000324a:	892a                	mv	s2,a0
    dip = (struct dinode *)bp->data + ip->inum % IPB;
    8000324c:	05850593          	addi	a1,a0,88
    80003250:	40dc                	lw	a5,4(s1)
    80003252:	8bbd                	andi	a5,a5,15
    80003254:	079a                	slli	a5,a5,0x6
    80003256:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003258:	00059783          	lh	a5,0(a1)
    8000325c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003260:	00259783          	lh	a5,2(a1)
    80003264:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003268:	00459783          	lh	a5,4(a1)
    8000326c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003270:	00659783          	lh	a5,6(a1)
    80003274:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003278:	459c                	lw	a5,8(a1)
    8000327a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000327c:	03400613          	li	a2,52
    80003280:	05b1                	addi	a1,a1,12
    80003282:	05048513          	addi	a0,s1,80
    80003286:	a2bfd0ef          	jal	80000cb0 <memmove>
    brelse(bp);
    8000328a:	854a                	mv	a0,s2
    8000328c:	9adff0ef          	jal	80002c38 <brelse>
    ip->valid = 1;
    80003290:	4785                	li	a5,1
    80003292:	c0bc                	sw	a5,64(s1)
    if (ip->type == 0)
    80003294:	04449783          	lh	a5,68(s1)
    80003298:	c399                	beqz	a5,8000329e <ilock+0xa2>
    8000329a:	6902                	ld	s2,0(sp)
    8000329c:	bfbd                	j	8000321a <ilock+0x1e>
      panic("ilock: no type");
    8000329e:	00004517          	auipc	a0,0x4
    800032a2:	1d250513          	addi	a0,a0,466 # 80007470 <etext+0x470>
    800032a6:	d4afd0ef          	jal	800007f0 <panic>

00000000800032aa <iunlock>:
{
    800032aa:	1101                	addi	sp,sp,-32
    800032ac:	ec06                	sd	ra,24(sp)
    800032ae:	e822                	sd	s0,16(sp)
    800032b0:	e426                	sd	s1,8(sp)
    800032b2:	e04a                	sd	s2,0(sp)
    800032b4:	1000                	addi	s0,sp,32
  if (ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800032b6:	c505                	beqz	a0,800032de <iunlock+0x34>
    800032b8:	84aa                	mv	s1,a0
    800032ba:	01050913          	addi	s2,a0,16
    800032be:	854a                	mv	a0,s2
    800032c0:	51f000ef          	jal	80003fde <holdingsleep>
    800032c4:	cd09                	beqz	a0,800032de <iunlock+0x34>
    800032c6:	449c                	lw	a5,8(s1)
    800032c8:	00f05b63          	blez	a5,800032de <iunlock+0x34>
  releasesleep(&ip->lock);
    800032cc:	854a                	mv	a0,s2
    800032ce:	4d9000ef          	jal	80003fa6 <releasesleep>
}
    800032d2:	60e2                	ld	ra,24(sp)
    800032d4:	6442                	ld	s0,16(sp)
    800032d6:	64a2                	ld	s1,8(sp)
    800032d8:	6902                	ld	s2,0(sp)
    800032da:	6105                	addi	sp,sp,32
    800032dc:	8082                	ret
    panic("iunlock");
    800032de:	00004517          	auipc	a0,0x4
    800032e2:	1a250513          	addi	a0,a0,418 # 80007480 <etext+0x480>
    800032e6:	d0afd0ef          	jal	800007f0 <panic>

00000000800032ea <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800032ea:	7179                	addi	sp,sp,-48
    800032ec:	f406                	sd	ra,40(sp)
    800032ee:	f022                	sd	s0,32(sp)
    800032f0:	ec26                	sd	s1,24(sp)
    800032f2:	e84a                	sd	s2,16(sp)
    800032f4:	e44e                	sd	s3,8(sp)
    800032f6:	1800                	addi	s0,sp,48
    800032f8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for (i = 0; i < NDIRECT; i++) {
    800032fa:	05050493          	addi	s1,a0,80
    800032fe:	08050913          	addi	s2,a0,128
    80003302:	a021                	j	8000330a <itrunc+0x20>
    80003304:	0491                	addi	s1,s1,4
    80003306:	01248b63          	beq	s1,s2,8000331c <itrunc+0x32>
    if (ip->addrs[i]) {
    8000330a:	408c                	lw	a1,0(s1)
    8000330c:	dde5                	beqz	a1,80003304 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000330e:	0009a503          	lw	a0,0(s3)
    80003312:	a17ff0ef          	jal	80002d28 <bfree>
      ip->addrs[i] = 0;
    80003316:	0004a023          	sw	zero,0(s1)
    8000331a:	b7ed                	j	80003304 <itrunc+0x1a>
    }
  }

  if (ip->addrs[NDIRECT]) {
    8000331c:	0809a583          	lw	a1,128(s3)
    80003320:	ed89                	bnez	a1,8000333a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003322:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003326:	854e                	mv	a0,s3
    80003328:	e21ff0ef          	jal	80003148 <iupdate>
}
    8000332c:	70a2                	ld	ra,40(sp)
    8000332e:	7402                	ld	s0,32(sp)
    80003330:	64e2                	ld	s1,24(sp)
    80003332:	6942                	ld	s2,16(sp)
    80003334:	69a2                	ld	s3,8(sp)
    80003336:	6145                	addi	sp,sp,48
    80003338:	8082                	ret
    8000333a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000333c:	0009a503          	lw	a0,0(s3)
    80003340:	ff0ff0ef          	jal	80002b30 <bread>
    80003344:	8a2a                	mv	s4,a0
    for (j = 0; j < NINDIRECT; j++) {
    80003346:	05850493          	addi	s1,a0,88
    8000334a:	45850913          	addi	s2,a0,1112
    8000334e:	a021                	j	80003356 <itrunc+0x6c>
    80003350:	0491                	addi	s1,s1,4
    80003352:	01248963          	beq	s1,s2,80003364 <itrunc+0x7a>
      if (a[j])
    80003356:	408c                	lw	a1,0(s1)
    80003358:	dde5                	beqz	a1,80003350 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000335a:	0009a503          	lw	a0,0(s3)
    8000335e:	9cbff0ef          	jal	80002d28 <bfree>
    80003362:	b7fd                	j	80003350 <itrunc+0x66>
    brelse(bp);
    80003364:	8552                	mv	a0,s4
    80003366:	8d3ff0ef          	jal	80002c38 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000336a:	0809a583          	lw	a1,128(s3)
    8000336e:	0009a503          	lw	a0,0(s3)
    80003372:	9b7ff0ef          	jal	80002d28 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003376:	0809a023          	sw	zero,128(s3)
    8000337a:	6a02                	ld	s4,0(sp)
    8000337c:	b75d                	j	80003322 <itrunc+0x38>

000000008000337e <iput>:
{
    8000337e:	7179                	addi	sp,sp,-48
    80003380:	f406                	sd	ra,40(sp)
    80003382:	f022                	sd	s0,32(sp)
    80003384:	ec26                	sd	s1,24(sp)
    80003386:	1800                	addi	s0,sp,48
    80003388:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000338a:	0001d517          	auipc	a0,0x1d
    8000338e:	afe50513          	addi	a0,a0,-1282 # 8001fe88 <itable>
    80003392:	ffefd0ef          	jal	80000b90 <acquire>
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    80003396:	449c                	lw	a5,8(s1)
    80003398:	4705                	li	a4,1
    8000339a:	00e78f63          	beq	a5,a4,800033b8 <iput+0x3a>
  ip->ref--;
    8000339e:	37fd                	addiw	a5,a5,-1
    800033a0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800033a2:	0001d517          	auipc	a0,0x1d
    800033a6:	ae650513          	addi	a0,a0,-1306 # 8001fe88 <itable>
    800033aa:	873fd0ef          	jal	80000c1c <release>
}
    800033ae:	70a2                	ld	ra,40(sp)
    800033b0:	7402                	ld	s0,32(sp)
    800033b2:	64e2                	ld	s1,24(sp)
    800033b4:	6145                	addi	sp,sp,48
    800033b6:	8082                	ret
  int last = (ip->ref == 1 && ip->valid && ip->nlink == 0);
    800033b8:	40b8                	lw	a4,64(s1)
    800033ba:	d375                	beqz	a4,8000339e <iput+0x20>
    800033bc:	e84a                	sd	s2,16(sp)
    800033be:	e052                	sd	s4,0(sp)
  uint dev = ip->dev, inum = ip->inum;
    800033c0:	0004aa03          	lw	s4,0(s1)
    800033c4:	0044a903          	lw	s2,4(s1)
  if (last) {
    800033c8:	04a49703          	lh	a4,74(s1)
    800033cc:	ef35                	bnez	a4,80003448 <iput+0xca>
    800033ce:	e44e                	sd	s3,8(sp)
    acquiresleep(&ip->lock);
    800033d0:	01048993          	addi	s3,s1,16
    800033d4:	854e                	mv	a0,s3
    800033d6:	37d000ef          	jal	80003f52 <acquiresleep>
    release(&itable.lock);
    800033da:	0001d517          	auipc	a0,0x1d
    800033de:	aae50513          	addi	a0,a0,-1362 # 8001fe88 <itable>
    800033e2:	83bfd0ef          	jal	80000c1c <release>
    itrunc(ip); // free the data blocks (type stays nonzero on disk)
    800033e6:	8526                	mv	a0,s1
    800033e8:	f03ff0ef          	jal	800032ea <itrunc>
    ip->valid = 0;
    800033ec:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800033f0:	854e                	mv	a0,s3
    800033f2:	3b5000ef          	jal	80003fa6 <releasesleep>
    acquire(&itable.lock);
    800033f6:	0001d517          	auipc	a0,0x1d
    800033fa:	a9250513          	addi	a0,a0,-1390 # 8001fe88 <itable>
    800033fe:	f92fd0ef          	jal	80000b90 <acquire>
  ip->ref--;
    80003402:	449c                	lw	a5,8(s1)
    80003404:	37fd                	addiw	a5,a5,-1
    80003406:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003408:	0001d517          	auipc	a0,0x1d
    8000340c:	a8050513          	addi	a0,a0,-1408 # 8001fe88 <itable>
    80003410:	80dfd0ef          	jal	80000c1c <release>
  struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003414:	0049559b          	srliw	a1,s2,0x4
    80003418:	0001d797          	auipc	a5,0x1d
    8000341c:	a687a783          	lw	a5,-1432(a5) # 8001fe80 <sb+0x18>
    80003420:	9dbd                	addw	a1,a1,a5
    80003422:	8552                	mv	a0,s4
    80003424:	f0cff0ef          	jal	80002b30 <bread>
    80003428:	84aa                	mv	s1,a0
  struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000342a:	00f97913          	andi	s2,s2,15
  dip->type = 0;
    8000342e:	091a                	slli	s2,s2,0x6
    80003430:	992a                	add	s2,s2,a0
    80003432:	04091c23          	sh	zero,88(s2)
  log_write(bp);
    80003436:	1b5000ef          	jal	80003dea <log_write>
  brelse(bp);
    8000343a:	8526                	mv	a0,s1
    8000343c:	ffcff0ef          	jal	80002c38 <brelse>
}
    80003440:	6942                	ld	s2,16(sp)
    80003442:	69a2                	ld	s3,8(sp)
    80003444:	6a02                	ld	s4,0(sp)
    80003446:	b7a5                	j	800033ae <iput+0x30>
    80003448:	6942                	ld	s2,16(sp)
    8000344a:	6a02                	ld	s4,0(sp)
    8000344c:	bf89                	j	8000339e <iput+0x20>

000000008000344e <iunlockput>:
{
    8000344e:	1101                	addi	sp,sp,-32
    80003450:	ec06                	sd	ra,24(sp)
    80003452:	e822                	sd	s0,16(sp)
    80003454:	e426                	sd	s1,8(sp)
    80003456:	1000                	addi	s0,sp,32
    80003458:	84aa                	mv	s1,a0
  iunlock(ip);
    8000345a:	e51ff0ef          	jal	800032aa <iunlock>
  iput(ip);
    8000345e:	8526                	mv	a0,s1
    80003460:	f1fff0ef          	jal	8000337e <iput>
}
    80003464:	60e2                	ld	ra,24(sp)
    80003466:	6442                	ld	s0,16(sp)
    80003468:	64a2                	ld	s1,8(sp)
    8000346a:	6105                	addi	sp,sp,32
    8000346c:	8082                	ret

000000008000346e <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000346e:	0001d717          	auipc	a4,0x1d
    80003472:	a0672703          	lw	a4,-1530(a4) # 8001fe74 <sb+0xc>
    80003476:	4785                	li	a5,1
    80003478:	0ae7ff63          	bgeu	a5,a4,80003536 <ireclaim+0xc8>
{
    8000347c:	7139                	addi	sp,sp,-64
    8000347e:	fc06                	sd	ra,56(sp)
    80003480:	f822                	sd	s0,48(sp)
    80003482:	f426                	sd	s1,40(sp)
    80003484:	f04a                	sd	s2,32(sp)
    80003486:	ec4e                	sd	s3,24(sp)
    80003488:	e852                	sd	s4,16(sp)
    8000348a:	e456                	sd	s5,8(sp)
    8000348c:	e05a                	sd	s6,0(sp)
    8000348e:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003490:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003492:	00050a1b          	sext.w	s4,a0
    80003496:	0001da97          	auipc	s5,0x1d
    8000349a:	9d2a8a93          	addi	s5,s5,-1582 # 8001fe68 <sb>
      printk("ireclaim: orphaned inode %d\n", inum);
    8000349e:	00004b17          	auipc	s6,0x4
    800034a2:	feab0b13          	addi	s6,s6,-22 # 80007488 <etext+0x488>
    800034a6:	a099                	j	800034ec <ireclaim+0x7e>
    800034a8:	85ce                	mv	a1,s3
    800034aa:	855a                	mv	a0,s6
    800034ac:	85efd0ef          	jal	8000050a <printk>
      ip = iget(dev, inum);
    800034b0:	85ce                	mv	a1,s3
    800034b2:	8552                	mv	a0,s4
    800034b4:	ad5ff0ef          	jal	80002f88 <iget>
    800034b8:	89aa                	mv	s3,a0
    brelse(bp);
    800034ba:	854a                	mv	a0,s2
    800034bc:	f7cff0ef          	jal	80002c38 <brelse>
    if (ip) {
    800034c0:	00098f63          	beqz	s3,800034de <ireclaim+0x70>
      begin_op();
    800034c4:	780000ef          	jal	80003c44 <begin_op>
      ilock(ip);
    800034c8:	854e                	mv	a0,s3
    800034ca:	d33ff0ef          	jal	800031fc <ilock>
      iunlock(ip);
    800034ce:	854e                	mv	a0,s3
    800034d0:	ddbff0ef          	jal	800032aa <iunlock>
      iput(ip);
    800034d4:	854e                	mv	a0,s3
    800034d6:	ea9ff0ef          	jal	8000337e <iput>
      end_op();
    800034da:	7f0000ef          	jal	80003cca <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034de:	0485                	addi	s1,s1,1
    800034e0:	00caa703          	lw	a4,12(s5)
    800034e4:	0004879b          	sext.w	a5,s1
    800034e8:	02e7fd63          	bgeu	a5,a4,80003522 <ireclaim+0xb4>
    800034ec:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034f0:	0044d593          	srli	a1,s1,0x4
    800034f4:	018aa783          	lw	a5,24(s5)
    800034f8:	9dbd                	addw	a1,a1,a5
    800034fa:	8552                	mv	a0,s4
    800034fc:	e34ff0ef          	jal	80002b30 <bread>
    80003500:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003502:	05850793          	addi	a5,a0,88
    80003506:	00f9f713          	andi	a4,s3,15
    8000350a:	071a                	slli	a4,a4,0x6
    8000350c:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) { // is an orphaned inode
    8000350e:	00079703          	lh	a4,0(a5)
    80003512:	c701                	beqz	a4,8000351a <ireclaim+0xac>
    80003514:	00679783          	lh	a5,6(a5)
    80003518:	dbc1                	beqz	a5,800034a8 <ireclaim+0x3a>
    brelse(bp);
    8000351a:	854a                	mv	a0,s2
    8000351c:	f1cff0ef          	jal	80002c38 <brelse>
    if (ip) {
    80003520:	bf7d                	j	800034de <ireclaim+0x70>
}
    80003522:	70e2                	ld	ra,56(sp)
    80003524:	7442                	ld	s0,48(sp)
    80003526:	74a2                	ld	s1,40(sp)
    80003528:	7902                	ld	s2,32(sp)
    8000352a:	69e2                	ld	s3,24(sp)
    8000352c:	6a42                	ld	s4,16(sp)
    8000352e:	6aa2                	ld	s5,8(sp)
    80003530:	6b02                	ld	s6,0(sp)
    80003532:	6121                	addi	sp,sp,64
    80003534:	8082                	ret
    80003536:	8082                	ret

0000000080003538 <fsinit>:
{
    80003538:	7179                	addi	sp,sp,-48
    8000353a:	f406                	sd	ra,40(sp)
    8000353c:	f022                	sd	s0,32(sp)
    8000353e:	ec26                	sd	s1,24(sp)
    80003540:	e84a                	sd	s2,16(sp)
    80003542:	e44e                	sd	s3,8(sp)
    80003544:	1800                	addi	s0,sp,48
    80003546:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003548:	4585                	li	a1,1
    8000354a:	de6ff0ef          	jal	80002b30 <bread>
    8000354e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003550:	0001d997          	auipc	s3,0x1d
    80003554:	91898993          	addi	s3,s3,-1768 # 8001fe68 <sb>
    80003558:	02000613          	li	a2,32
    8000355c:	05850593          	addi	a1,a0,88
    80003560:	854e                	mv	a0,s3
    80003562:	f4efd0ef          	jal	80000cb0 <memmove>
  brelse(bp);
    80003566:	854a                	mv	a0,s2
    80003568:	ed0ff0ef          	jal	80002c38 <brelse>
  if (sb.magic != FSMAGIC)
    8000356c:	0009a703          	lw	a4,0(s3)
    80003570:	102037b7          	lui	a5,0x10203
    80003574:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003578:	02f71363          	bne	a4,a5,8000359e <fsinit+0x66>
  initlog(dev, &sb);
    8000357c:	0001d597          	auipc	a1,0x1d
    80003580:	8ec58593          	addi	a1,a1,-1812 # 8001fe68 <sb>
    80003584:	8526                	mv	a0,s1
    80003586:	640000ef          	jal	80003bc6 <initlog>
  ireclaim(dev);
    8000358a:	8526                	mv	a0,s1
    8000358c:	ee3ff0ef          	jal	8000346e <ireclaim>
}
    80003590:	70a2                	ld	ra,40(sp)
    80003592:	7402                	ld	s0,32(sp)
    80003594:	64e2                	ld	s1,24(sp)
    80003596:	6942                	ld	s2,16(sp)
    80003598:	69a2                	ld	s3,8(sp)
    8000359a:	6145                	addi	sp,sp,48
    8000359c:	8082                	ret
    panic("invalid file system");
    8000359e:	00004517          	auipc	a0,0x4
    800035a2:	f0a50513          	addi	a0,a0,-246 # 800074a8 <etext+0x4a8>
    800035a6:	a4afd0ef          	jal	800007f0 <panic>

00000000800035aa <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035aa:	1141                	addi	sp,sp,-16
    800035ac:	e422                	sd	s0,8(sp)
    800035ae:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035b0:	411c                	lw	a5,0(a0)
    800035b2:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035b4:	415c                	lw	a5,4(a0)
    800035b6:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800035b8:	04451783          	lh	a5,68(a0)
    800035bc:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800035c0:	04a51783          	lh	a5,74(a0)
    800035c4:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800035c8:	04c56783          	lwu	a5,76(a0)
    800035cc:	e99c                	sd	a5,16(a1)
}
    800035ce:	6422                	ld	s0,8(sp)
    800035d0:	0141                	addi	sp,sp,16
    800035d2:	8082                	ret

00000000800035d4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800035d4:	457c                	lw	a5,76(a0)
    800035d6:	0ed7eb63          	bltu	a5,a3,800036cc <readi+0xf8>
{
    800035da:	7159                	addi	sp,sp,-112
    800035dc:	f486                	sd	ra,104(sp)
    800035de:	f0a2                	sd	s0,96(sp)
    800035e0:	eca6                	sd	s1,88(sp)
    800035e2:	e0d2                	sd	s4,64(sp)
    800035e4:	fc56                	sd	s5,56(sp)
    800035e6:	f85a                	sd	s6,48(sp)
    800035e8:	f45e                	sd	s7,40(sp)
    800035ea:	1880                	addi	s0,sp,112
    800035ec:	8b2a                	mv	s6,a0
    800035ee:	8bae                	mv	s7,a1
    800035f0:	8a32                	mv	s4,a2
    800035f2:	84b6                	mv	s1,a3
    800035f4:	8aba                	mv	s5,a4
  if (off > ip->size || off + n < off)
    800035f6:	9f35                	addw	a4,a4,a3
    return 0;
    800035f8:	4501                	li	a0,0
  if (off > ip->size || off + n < off)
    800035fa:	0cd76063          	bltu	a4,a3,800036ba <readi+0xe6>
    800035fe:	e4ce                	sd	s3,72(sp)
  if (off + n > ip->size)
    80003600:	00e7f463          	bgeu	a5,a4,80003608 <readi+0x34>
    n = ip->size - off;
    80003604:	40d78abb          	subw	s5,a5,a3

  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003608:	080a8f63          	beqz	s5,800036a6 <readi+0xd2>
    8000360c:	e8ca                	sd	s2,80(sp)
    8000360e:	f062                	sd	s8,32(sp)
    80003610:	ec66                	sd	s9,24(sp)
    80003612:	e86a                	sd	s10,16(sp)
    80003614:	e46e                	sd	s11,8(sp)
    80003616:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003618:	40000c93          	li	s9,1024
    if (either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000361c:	5c7d                	li	s8,-1
    8000361e:	a80d                	j	80003650 <readi+0x7c>
    80003620:	020d1d93          	slli	s11,s10,0x20
    80003624:	020ddd93          	srli	s11,s11,0x20
    80003628:	05890613          	addi	a2,s2,88
    8000362c:	86ee                	mv	a3,s11
    8000362e:	963a                	add	a2,a2,a4
    80003630:	85d2                	mv	a1,s4
    80003632:	855e                	mv	a0,s7
    80003634:	c11fe0ef          	jal	80002244 <either_copyout>
    80003638:	05850763          	beq	a0,s8,80003686 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    8000363c:	854a                	mv	a0,s2
    8000363e:	dfaff0ef          	jal	80002c38 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    80003642:	013d09bb          	addw	s3,s10,s3
    80003646:	009d04bb          	addw	s1,s10,s1
    8000364a:	9a6e                	add	s4,s4,s11
    8000364c:	0559f763          	bgeu	s3,s5,8000369a <readi+0xc6>
    uint addr = bmap(ip, off / BSIZE);
    80003650:	00a4d59b          	srliw	a1,s1,0xa
    80003654:	855a                	mv	a0,s6
    80003656:	85fff0ef          	jal	80002eb4 <bmap>
    8000365a:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    8000365e:	c5b1                	beqz	a1,800036aa <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003660:	000b2503          	lw	a0,0(s6)
    80003664:	cccff0ef          	jal	80002b30 <bread>
    80003668:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000366a:	3ff4f713          	andi	a4,s1,1023
    8000366e:	40ec87bb          	subw	a5,s9,a4
    80003672:	413a86bb          	subw	a3,s5,s3
    80003676:	8d3e                	mv	s10,a5
    80003678:	2781                	sext.w	a5,a5
    8000367a:	0006861b          	sext.w	a2,a3
    8000367e:	faf671e3          	bgeu	a2,a5,80003620 <readi+0x4c>
    80003682:	8d36                	mv	s10,a3
    80003684:	bf71                	j	80003620 <readi+0x4c>
      brelse(bp);
    80003686:	854a                	mv	a0,s2
    80003688:	db0ff0ef          	jal	80002c38 <brelse>
      tot = -1;
    8000368c:	59fd                	li	s3,-1
      break;
    8000368e:	6946                	ld	s2,80(sp)
    80003690:	7c02                	ld	s8,32(sp)
    80003692:	6ce2                	ld	s9,24(sp)
    80003694:	6d42                	ld	s10,16(sp)
    80003696:	6da2                	ld	s11,8(sp)
    80003698:	a831                	j	800036b4 <readi+0xe0>
    8000369a:	6946                	ld	s2,80(sp)
    8000369c:	7c02                	ld	s8,32(sp)
    8000369e:	6ce2                	ld	s9,24(sp)
    800036a0:	6d42                	ld	s10,16(sp)
    800036a2:	6da2                	ld	s11,8(sp)
    800036a4:	a801                	j	800036b4 <readi+0xe0>
  for (tot = 0; tot < n; tot += m, off += m, dst += m) {
    800036a6:	89d6                	mv	s3,s5
    800036a8:	a031                	j	800036b4 <readi+0xe0>
    800036aa:	6946                	ld	s2,80(sp)
    800036ac:	7c02                	ld	s8,32(sp)
    800036ae:	6ce2                	ld	s9,24(sp)
    800036b0:	6d42                	ld	s10,16(sp)
    800036b2:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800036b4:	0009851b          	sext.w	a0,s3
    800036b8:	69a6                	ld	s3,72(sp)
}
    800036ba:	70a6                	ld	ra,104(sp)
    800036bc:	7406                	ld	s0,96(sp)
    800036be:	64e6                	ld	s1,88(sp)
    800036c0:	6a06                	ld	s4,64(sp)
    800036c2:	7ae2                	ld	s5,56(sp)
    800036c4:	7b42                	ld	s6,48(sp)
    800036c6:	7ba2                	ld	s7,40(sp)
    800036c8:	6165                	addi	sp,sp,112
    800036ca:	8082                	ret
    return 0;
    800036cc:	4501                	li	a0,0
}
    800036ce:	8082                	ret

00000000800036d0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if (off > ip->size || off + n < off)
    800036d0:	457c                	lw	a5,76(a0)
    800036d2:	10d7e363          	bltu	a5,a3,800037d8 <writei+0x108>
{
    800036d6:	7159                	addi	sp,sp,-112
    800036d8:	f486                	sd	ra,104(sp)
    800036da:	f0a2                	sd	s0,96(sp)
    800036dc:	e8ca                	sd	s2,80(sp)
    800036de:	e0d2                	sd	s4,64(sp)
    800036e0:	fc56                	sd	s5,56(sp)
    800036e2:	f85a                	sd	s6,48(sp)
    800036e4:	f45e                	sd	s7,40(sp)
    800036e6:	1880                	addi	s0,sp,112
    800036e8:	8aaa                	mv	s5,a0
    800036ea:	8bae                	mv	s7,a1
    800036ec:	8a32                	mv	s4,a2
    800036ee:	8936                	mv	s2,a3
    800036f0:	8b3a                	mv	s6,a4
  if (off > ip->size || off + n < off)
    800036f2:	00e687bb          	addw	a5,a3,a4
    800036f6:	0ed7e363          	bltu	a5,a3,800037dc <writei+0x10c>
    return -1;
  if (off + n > MAXFILE * BSIZE)
    800036fa:	00043737          	lui	a4,0x43
    800036fe:	0ef76163          	bltu	a4,a5,800037e0 <writei+0x110>
    80003702:	e4ce                	sd	s3,72(sp)
    return -1;

  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003704:	0c0b0263          	beqz	s6,800037c8 <writei+0xf8>
    80003708:	eca6                	sd	s1,88(sp)
    8000370a:	f062                	sd	s8,32(sp)
    8000370c:	ec66                	sd	s9,24(sp)
    8000370e:	e86a                	sd	s10,16(sp)
    80003710:	e46e                	sd	s11,8(sp)
    80003712:	4981                	li	s3,0
    uint addr = bmap(ip, off / BSIZE);
    if (addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off % BSIZE);
    80003714:	40000c93          	li	s9,1024
    if (either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003718:	5c7d                	li	s8,-1
    8000371a:	a825                	j	80003752 <writei+0x82>
    8000371c:	020d1d93          	slli	s11,s10,0x20
    80003720:	020ddd93          	srli	s11,s11,0x20
    80003724:	05848513          	addi	a0,s1,88
    80003728:	86ee                	mv	a3,s11
    8000372a:	8652                	mv	a2,s4
    8000372c:	85de                	mv	a1,s7
    8000372e:	953a                	add	a0,a0,a4
    80003730:	b61fe0ef          	jal	80002290 <either_copyin>
    80003734:	05850a63          	beq	a0,s8,80003788 <writei+0xb8>
      // Might have partially updated the block, so we need to log it.
      log_write(bp);
      brelse(bp);
      break;
    }
    log_write(bp);
    80003738:	8526                	mv	a0,s1
    8000373a:	6b0000ef          	jal	80003dea <log_write>
    brelse(bp);
    8000373e:	8526                	mv	a0,s1
    80003740:	cf8ff0ef          	jal	80002c38 <brelse>
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    80003744:	013d09bb          	addw	s3,s10,s3
    80003748:	012d093b          	addw	s2,s10,s2
    8000374c:	9a6e                	add	s4,s4,s11
    8000374e:	0569f363          	bgeu	s3,s6,80003794 <writei+0xc4>
    uint addr = bmap(ip, off / BSIZE);
    80003752:	00a9559b          	srliw	a1,s2,0xa
    80003756:	8556                	mv	a0,s5
    80003758:	f5cff0ef          	jal	80002eb4 <bmap>
    8000375c:	0005059b          	sext.w	a1,a0
    if (addr == 0)
    80003760:	c995                	beqz	a1,80003794 <writei+0xc4>
    bp = bread(ip->dev, addr);
    80003762:	000aa503          	lw	a0,0(s5)
    80003766:	bcaff0ef          	jal	80002b30 <bread>
    8000376a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off % BSIZE);
    8000376c:	3ff97713          	andi	a4,s2,1023
    80003770:	40ec87bb          	subw	a5,s9,a4
    80003774:	413b06bb          	subw	a3,s6,s3
    80003778:	8d3e                	mv	s10,a5
    8000377a:	2781                	sext.w	a5,a5
    8000377c:	0006861b          	sext.w	a2,a3
    80003780:	f8f67ee3          	bgeu	a2,a5,8000371c <writei+0x4c>
    80003784:	8d36                	mv	s10,a3
    80003786:	bf59                	j	8000371c <writei+0x4c>
      log_write(bp);
    80003788:	8526                	mv	a0,s1
    8000378a:	660000ef          	jal	80003dea <log_write>
      brelse(bp);
    8000378e:	8526                	mv	a0,s1
    80003790:	ca8ff0ef          	jal	80002c38 <brelse>
  }

  if (off > ip->size)
    80003794:	04caa783          	lw	a5,76(s5)
    80003798:	0327fa63          	bgeu	a5,s2,800037cc <writei+0xfc>
    ip->size = off;
    8000379c:	052aa623          	sw	s2,76(s5)
    800037a0:	64e6                	ld	s1,88(sp)
    800037a2:	7c02                	ld	s8,32(sp)
    800037a4:	6ce2                	ld	s9,24(sp)
    800037a6:	6d42                	ld	s10,16(sp)
    800037a8:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037aa:	8556                	mv	a0,s5
    800037ac:	99dff0ef          	jal	80003148 <iupdate>

  return tot;
    800037b0:	0009851b          	sext.w	a0,s3
    800037b4:	69a6                	ld	s3,72(sp)
}
    800037b6:	70a6                	ld	ra,104(sp)
    800037b8:	7406                	ld	s0,96(sp)
    800037ba:	6946                	ld	s2,80(sp)
    800037bc:	6a06                	ld	s4,64(sp)
    800037be:	7ae2                	ld	s5,56(sp)
    800037c0:	7b42                	ld	s6,48(sp)
    800037c2:	7ba2                	ld	s7,40(sp)
    800037c4:	6165                	addi	sp,sp,112
    800037c6:	8082                	ret
  for (tot = 0; tot < n; tot += m, off += m, src += m) {
    800037c8:	89da                	mv	s3,s6
    800037ca:	b7c5                	j	800037aa <writei+0xda>
    800037cc:	64e6                	ld	s1,88(sp)
    800037ce:	7c02                	ld	s8,32(sp)
    800037d0:	6ce2                	ld	s9,24(sp)
    800037d2:	6d42                	ld	s10,16(sp)
    800037d4:	6da2                	ld	s11,8(sp)
    800037d6:	bfd1                	j	800037aa <writei+0xda>
    return -1;
    800037d8:	557d                	li	a0,-1
}
    800037da:	8082                	ret
    return -1;
    800037dc:	557d                	li	a0,-1
    800037de:	bfe1                	j	800037b6 <writei+0xe6>
    return -1;
    800037e0:	557d                	li	a0,-1
    800037e2:	bfd1                	j	800037b6 <writei+0xe6>

00000000800037e4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800037e4:	1141                	addi	sp,sp,-16
    800037e6:	e406                	sd	ra,8(sp)
    800037e8:	e022                	sd	s0,0(sp)
    800037ea:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800037ec:	4639                	li	a2,14
    800037ee:	d32fd0ef          	jal	80000d20 <strncmp>
}
    800037f2:	60a2                	ld	ra,8(sp)
    800037f4:	6402                	ld	s0,0(sp)
    800037f6:	0141                	addi	sp,sp,16
    800037f8:	8082                	ret

00000000800037fa <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode *
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800037fa:	7139                	addi	sp,sp,-64
    800037fc:	fc06                	sd	ra,56(sp)
    800037fe:	f822                	sd	s0,48(sp)
    80003800:	f426                	sd	s1,40(sp)
    80003802:	f04a                	sd	s2,32(sp)
    80003804:	ec4e                	sd	s3,24(sp)
    80003806:	e852                	sd	s4,16(sp)
    80003808:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if (dp->type != T_DIR)
    8000380a:	04451703          	lh	a4,68(a0)
    8000380e:	4785                	li	a5,1
    80003810:	00f71a63          	bne	a4,a5,80003824 <dirlookup+0x2a>
    80003814:	892a                	mv	s2,a0
    80003816:	89ae                	mv	s3,a1
    80003818:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000381a:	457c                	lw	a5,76(a0)
    8000381c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000381e:	4501                	li	a0,0
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003820:	e39d                	bnez	a5,80003846 <dirlookup+0x4c>
    80003822:	a095                	j	80003886 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003824:	00004517          	auipc	a0,0x4
    80003828:	c9c50513          	addi	a0,a0,-868 # 800074c0 <etext+0x4c0>
    8000382c:	fc5fc0ef          	jal	800007f0 <panic>
      panic("dirlookup read");
    80003830:	00004517          	auipc	a0,0x4
    80003834:	ca850513          	addi	a0,a0,-856 # 800074d8 <etext+0x4d8>
    80003838:	fb9fc0ef          	jal	800007f0 <panic>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    8000383c:	24c1                	addiw	s1,s1,16
    8000383e:	04c92783          	lw	a5,76(s2)
    80003842:	04f4f163          	bgeu	s1,a5,80003884 <dirlookup+0x8a>
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003846:	4741                	li	a4,16
    80003848:	86a6                	mv	a3,s1
    8000384a:	fc040613          	addi	a2,s0,-64
    8000384e:	4581                	li	a1,0
    80003850:	854a                	mv	a0,s2
    80003852:	d83ff0ef          	jal	800035d4 <readi>
    80003856:	47c1                	li	a5,16
    80003858:	fcf51ce3          	bne	a0,a5,80003830 <dirlookup+0x36>
    if (de.inum == 0)
    8000385c:	fc045783          	lhu	a5,-64(s0)
    80003860:	dff1                	beqz	a5,8000383c <dirlookup+0x42>
    if (namecmp(name, de.name) == 0) {
    80003862:	fc240593          	addi	a1,s0,-62
    80003866:	854e                	mv	a0,s3
    80003868:	f7dff0ef          	jal	800037e4 <namecmp>
    8000386c:	f961                	bnez	a0,8000383c <dirlookup+0x42>
      if (poff)
    8000386e:	000a0463          	beqz	s4,80003876 <dirlookup+0x7c>
        *poff = off;
    80003872:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003876:	fc045583          	lhu	a1,-64(s0)
    8000387a:	00092503          	lw	a0,0(s2)
    8000387e:	f0aff0ef          	jal	80002f88 <iget>
    80003882:	a011                	j	80003886 <dirlookup+0x8c>
  return 0;
    80003884:	4501                	li	a0,0
}
    80003886:	70e2                	ld	ra,56(sp)
    80003888:	7442                	ld	s0,48(sp)
    8000388a:	74a2                	ld	s1,40(sp)
    8000388c:	7902                	ld	s2,32(sp)
    8000388e:	69e2                	ld	s3,24(sp)
    80003890:	6a42                	ld	s4,16(sp)
    80003892:	6121                	addi	sp,sp,64
    80003894:	8082                	ret

0000000080003896 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode *
namex(char *path, int nameiparent, char *name)
{
    80003896:	711d                	addi	sp,sp,-96
    80003898:	ec86                	sd	ra,88(sp)
    8000389a:	e8a2                	sd	s0,80(sp)
    8000389c:	e4a6                	sd	s1,72(sp)
    8000389e:	e0ca                	sd	s2,64(sp)
    800038a0:	fc4e                	sd	s3,56(sp)
    800038a2:	f852                	sd	s4,48(sp)
    800038a4:	f456                	sd	s5,40(sp)
    800038a6:	f05a                	sd	s6,32(sp)
    800038a8:	ec5e                	sd	s7,24(sp)
    800038aa:	e862                	sd	s8,16(sp)
    800038ac:	e466                	sd	s9,8(sp)
    800038ae:	1080                	addi	s0,sp,96
    800038b0:	84aa                	mv	s1,a0
    800038b2:	8b2e                	mv	s6,a1
    800038b4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if (*path == '/')
    800038b6:	00054703          	lbu	a4,0(a0)
    800038ba:	02f00793          	li	a5,47
    800038be:	00f70e63          	beq	a4,a5,800038da <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800038c2:	fe1fd0ef          	jal	800018a2 <myproc>
    800038c6:	15053503          	ld	a0,336(a0)
    800038ca:	8fdff0ef          	jal	800031c6 <idup>
    800038ce:	8a2a                	mv	s4,a0
  while (*path == '/')
    800038d0:	02f00913          	li	s2,47
  if (len >= DIRSIZ)
    800038d4:	4c35                	li	s8,13

  while ((path = skipelem(path, name)) != 0) {
    ilock(ip);
    if (ip->type != T_DIR) {
    800038d6:	4b85                	li	s7,1
    800038d8:	a075                	j	80003984 <namex+0xee>
    ip = iget(ROOTDEV, ROOTINO);
    800038da:	4585                	li	a1,1
    800038dc:	4505                	li	a0,1
    800038de:	eaaff0ef          	jal	80002f88 <iget>
    800038e2:	8a2a                	mv	s4,a0
    800038e4:	b7f5                	j	800038d0 <namex+0x3a>
      iunlockput(ip);
    800038e6:	8552                	mv	a0,s4
    800038e8:	b67ff0ef          	jal	8000344e <iunlockput>
      return 0;
    800038ec:	4a01                	li	s4,0
  if (nameiparent) {
    iput(ip);
    return 0;
  }
  return ip;
}
    800038ee:	8552                	mv	a0,s4
    800038f0:	60e6                	ld	ra,88(sp)
    800038f2:	6446                	ld	s0,80(sp)
    800038f4:	64a6                	ld	s1,72(sp)
    800038f6:	6906                	ld	s2,64(sp)
    800038f8:	79e2                	ld	s3,56(sp)
    800038fa:	7a42                	ld	s4,48(sp)
    800038fc:	7aa2                	ld	s5,40(sp)
    800038fe:	7b02                	ld	s6,32(sp)
    80003900:	6be2                	ld	s7,24(sp)
    80003902:	6c42                	ld	s8,16(sp)
    80003904:	6ca2                	ld	s9,8(sp)
    80003906:	6125                	addi	sp,sp,96
    80003908:	8082                	ret
      iunlockput(ip);
    8000390a:	8552                	mv	a0,s4
    8000390c:	b43ff0ef          	jal	8000344e <iunlockput>
      return 0;
    80003910:	4a01                	li	s4,0
    80003912:	bff1                	j	800038ee <namex+0x58>
      iunlock(ip);
    80003914:	8552                	mv	a0,s4
    80003916:	995ff0ef          	jal	800032aa <iunlock>
      return ip;
    8000391a:	bfd1                	j	800038ee <namex+0x58>
      iunlockput(ip);
    8000391c:	8552                	mv	a0,s4
    8000391e:	b31ff0ef          	jal	8000344e <iunlockput>
      return 0;
    80003922:	8a4e                	mv	s4,s3
    80003924:	b7e9                	j	800038ee <namex+0x58>
  len = path - s;
    80003926:	40998633          	sub	a2,s3,s1
    8000392a:	00060c9b          	sext.w	s9,a2
  if (len >= DIRSIZ)
    8000392e:	099c5363          	bge	s8,s9,800039b4 <namex+0x11e>
    memmove(name, s, DIRSIZ);
    80003932:	4639                	li	a2,14
    80003934:	85a6                	mv	a1,s1
    80003936:	8556                	mv	a0,s5
    80003938:	b78fd0ef          	jal	80000cb0 <memmove>
    8000393c:	84ce                	mv	s1,s3
  while (*path == '/')
    8000393e:	0004c783          	lbu	a5,0(s1)
    80003942:	01279763          	bne	a5,s2,80003950 <namex+0xba>
    path++;
    80003946:	0485                	addi	s1,s1,1
  while (*path == '/')
    80003948:	0004c783          	lbu	a5,0(s1)
    8000394c:	ff278de3          	beq	a5,s2,80003946 <namex+0xb0>
    ilock(ip);
    80003950:	8552                	mv	a0,s4
    80003952:	8abff0ef          	jal	800031fc <ilock>
    if (ip->type != T_DIR) {
    80003956:	044a1783          	lh	a5,68(s4)
    8000395a:	f97796e3          	bne	a5,s7,800038e6 <namex+0x50>
    if (ip->nlink == 0) {
    8000395e:	04aa1783          	lh	a5,74(s4)
    80003962:	d7c5                	beqz	a5,8000390a <namex+0x74>
    if (nameiparent && *path == '\0') {
    80003964:	000b0563          	beqz	s6,8000396e <namex+0xd8>
    80003968:	0004c783          	lbu	a5,0(s1)
    8000396c:	d7c5                	beqz	a5,80003914 <namex+0x7e>
    if ((next = dirlookup(ip, name, 0)) == 0) {
    8000396e:	4601                	li	a2,0
    80003970:	85d6                	mv	a1,s5
    80003972:	8552                	mv	a0,s4
    80003974:	e87ff0ef          	jal	800037fa <dirlookup>
    80003978:	89aa                	mv	s3,a0
    8000397a:	d14d                	beqz	a0,8000391c <namex+0x86>
    iunlockput(ip);
    8000397c:	8552                	mv	a0,s4
    8000397e:	ad1ff0ef          	jal	8000344e <iunlockput>
    ip = next;
    80003982:	8a4e                	mv	s4,s3
  while (*path == '/')
    80003984:	0004c783          	lbu	a5,0(s1)
    80003988:	01279763          	bne	a5,s2,80003996 <namex+0x100>
    path++;
    8000398c:	0485                	addi	s1,s1,1
  while (*path == '/')
    8000398e:	0004c783          	lbu	a5,0(s1)
    80003992:	ff278de3          	beq	a5,s2,8000398c <namex+0xf6>
  if (*path == 0)
    80003996:	cb8d                	beqz	a5,800039c8 <namex+0x132>
  while (*path != '/' && *path != 0)
    80003998:	0004c783          	lbu	a5,0(s1)
    8000399c:	89a6                	mv	s3,s1
  len = path - s;
    8000399e:	4c81                	li	s9,0
    800039a0:	4601                	li	a2,0
  while (*path != '/' && *path != 0)
    800039a2:	01278963          	beq	a5,s2,800039b4 <namex+0x11e>
    800039a6:	d3c1                	beqz	a5,80003926 <namex+0x90>
    path++;
    800039a8:	0985                	addi	s3,s3,1
  while (*path != '/' && *path != 0)
    800039aa:	0009c783          	lbu	a5,0(s3)
    800039ae:	ff279ce3          	bne	a5,s2,800039a6 <namex+0x110>
    800039b2:	bf95                	j	80003926 <namex+0x90>
    memmove(name, s, len);
    800039b4:	2601                	sext.w	a2,a2
    800039b6:	85a6                	mv	a1,s1
    800039b8:	8556                	mv	a0,s5
    800039ba:	af6fd0ef          	jal	80000cb0 <memmove>
    name[len] = 0;
    800039be:	9cd6                	add	s9,s9,s5
    800039c0:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800039c4:	84ce                	mv	s1,s3
    800039c6:	bfa5                	j	8000393e <namex+0xa8>
  if (nameiparent) {
    800039c8:	f20b03e3          	beqz	s6,800038ee <namex+0x58>
    iput(ip);
    800039cc:	8552                	mv	a0,s4
    800039ce:	9b1ff0ef          	jal	8000337e <iput>
    return 0;
    800039d2:	4a01                	li	s4,0
    800039d4:	bf29                	j	800038ee <namex+0x58>

00000000800039d6 <dirlink>:
{
    800039d6:	7139                	addi	sp,sp,-64
    800039d8:	fc06                	sd	ra,56(sp)
    800039da:	f822                	sd	s0,48(sp)
    800039dc:	f04a                	sd	s2,32(sp)
    800039de:	ec4e                	sd	s3,24(sp)
    800039e0:	e852                	sd	s4,16(sp)
    800039e2:	0080                	addi	s0,sp,64
    800039e4:	892a                	mv	s2,a0
    800039e6:	8a2e                	mv	s4,a1
    800039e8:	89b2                	mv	s3,a2
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    800039ea:	4601                	li	a2,0
    800039ec:	e0fff0ef          	jal	800037fa <dirlookup>
    800039f0:	e535                	bnez	a0,80003a5c <dirlink+0x86>
    800039f2:	f426                	sd	s1,40(sp)
  for (off = 0; off < dp->size; off += sizeof(de)) {
    800039f4:	04c92483          	lw	s1,76(s2)
    800039f8:	c48d                	beqz	s1,80003a22 <dirlink+0x4c>
    800039fa:	4481                	li	s1,0
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800039fc:	4741                	li	a4,16
    800039fe:	86a6                	mv	a3,s1
    80003a00:	fc040613          	addi	a2,s0,-64
    80003a04:	4581                	li	a1,0
    80003a06:	854a                	mv	a0,s2
    80003a08:	bcdff0ef          	jal	800035d4 <readi>
    80003a0c:	47c1                	li	a5,16
    80003a0e:	04f51b63          	bne	a0,a5,80003a64 <dirlink+0x8e>
    if (de.inum == 0)
    80003a12:	fc045783          	lhu	a5,-64(s0)
    80003a16:	c791                	beqz	a5,80003a22 <dirlink+0x4c>
  for (off = 0; off < dp->size; off += sizeof(de)) {
    80003a18:	24c1                	addiw	s1,s1,16
    80003a1a:	04c92783          	lw	a5,76(s2)
    80003a1e:	fcf4efe3          	bltu	s1,a5,800039fc <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003a22:	4639                	li	a2,14
    80003a24:	85d2                	mv	a1,s4
    80003a26:	fc240513          	addi	a0,s0,-62
    80003a2a:	b2cfd0ef          	jal	80000d56 <strncpy>
  de.inum = inum;
    80003a2e:	fd341023          	sh	s3,-64(s0)
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a32:	4741                	li	a4,16
    80003a34:	86a6                	mv	a3,s1
    80003a36:	fc040613          	addi	a2,s0,-64
    80003a3a:	4581                	li	a1,0
    80003a3c:	854a                	mv	a0,s2
    80003a3e:	c93ff0ef          	jal	800036d0 <writei>
    80003a42:	1541                	addi	a0,a0,-16
    80003a44:	00a03533          	snez	a0,a0
    80003a48:	40a00533          	neg	a0,a0
    80003a4c:	74a2                	ld	s1,40(sp)
}
    80003a4e:	70e2                	ld	ra,56(sp)
    80003a50:	7442                	ld	s0,48(sp)
    80003a52:	7902                	ld	s2,32(sp)
    80003a54:	69e2                	ld	s3,24(sp)
    80003a56:	6a42                	ld	s4,16(sp)
    80003a58:	6121                	addi	sp,sp,64
    80003a5a:	8082                	ret
    iput(ip);
    80003a5c:	923ff0ef          	jal	8000337e <iput>
    return -1;
    80003a60:	557d                	li	a0,-1
    80003a62:	b7f5                	j	80003a4e <dirlink+0x78>
      panic("dirlink read");
    80003a64:	00004517          	auipc	a0,0x4
    80003a68:	a8450513          	addi	a0,a0,-1404 # 800074e8 <etext+0x4e8>
    80003a6c:	d85fc0ef          	jal	800007f0 <panic>

0000000080003a70 <namei>:

struct inode *
namei(char *path)
{
    80003a70:	1101                	addi	sp,sp,-32
    80003a72:	ec06                	sd	ra,24(sp)
    80003a74:	e822                	sd	s0,16(sp)
    80003a76:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003a78:	fe040613          	addi	a2,s0,-32
    80003a7c:	4581                	li	a1,0
    80003a7e:	e19ff0ef          	jal	80003896 <namex>
}
    80003a82:	60e2                	ld	ra,24(sp)
    80003a84:	6442                	ld	s0,16(sp)
    80003a86:	6105                	addi	sp,sp,32
    80003a88:	8082                	ret

0000000080003a8a <nameiparent>:

struct inode *
nameiparent(char *path, char *name)
{
    80003a8a:	1141                	addi	sp,sp,-16
    80003a8c:	e406                	sd	ra,8(sp)
    80003a8e:	e022                	sd	s0,0(sp)
    80003a90:	0800                	addi	s0,sp,16
    80003a92:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003a94:	4585                	li	a1,1
    80003a96:	e01ff0ef          	jal	80003896 <namex>
}
    80003a9a:	60a2                	ld	ra,8(sp)
    80003a9c:	6402                	ld	s0,0(sp)
    80003a9e:	0141                	addi	sp,sp,16
    80003aa0:	8082                	ret

0000000080003aa2 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003aa2:	1101                	addi	sp,sp,-32
    80003aa4:	ec06                	sd	ra,24(sp)
    80003aa6:	e822                	sd	s0,16(sp)
    80003aa8:	e426                	sd	s1,8(sp)
    80003aaa:	e04a                	sd	s2,0(sp)
    80003aac:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003aae:	0001e917          	auipc	s2,0x1e
    80003ab2:	e8290913          	addi	s2,s2,-382 # 80021930 <log>
    80003ab6:	01892583          	lw	a1,24(s2)
    80003aba:	02492503          	lw	a0,36(s2)
    80003abe:	872ff0ef          	jal	80002b30 <bread>
    80003ac2:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *)(buf->data);
  int i;
  hb->n = log.lh.n;
    80003ac4:	02c92603          	lw	a2,44(s2)
    80003ac8:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003aca:	00c05f63          	blez	a2,80003ae8 <write_head+0x46>
    80003ace:	0001e717          	auipc	a4,0x1e
    80003ad2:	e9270713          	addi	a4,a4,-366 # 80021960 <log+0x30>
    80003ad6:	87aa                	mv	a5,a0
    80003ad8:	060a                	slli	a2,a2,0x2
    80003ada:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003adc:	4314                	lw	a3,0(a4)
    80003ade:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003ae0:	0711                	addi	a4,a4,4
    80003ae2:	0791                	addi	a5,a5,4
    80003ae4:	fec79ce3          	bne	a5,a2,80003adc <write_head+0x3a>
  }
  bwrite(buf);
    80003ae8:	8526                	mv	a0,s1
    80003aea:	91cff0ef          	jal	80002c06 <bwrite>
  brelse(buf);
    80003aee:	8526                	mv	a0,s1
    80003af0:	948ff0ef          	jal	80002c38 <brelse>
}
    80003af4:	60e2                	ld	ra,24(sp)
    80003af6:	6442                	ld	s0,16(sp)
    80003af8:	64a2                	ld	s1,8(sp)
    80003afa:	6902                	ld	s2,0(sp)
    80003afc:	6105                	addi	sp,sp,32
    80003afe:	8082                	ret

0000000080003b00 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b00:	0001e797          	auipc	a5,0x1e
    80003b04:	e5c7a783          	lw	a5,-420(a5) # 8002195c <log+0x2c>
    80003b08:	0af05e63          	blez	a5,80003bc4 <install_trans+0xc4>
{
    80003b0c:	715d                	addi	sp,sp,-80
    80003b0e:	e486                	sd	ra,72(sp)
    80003b10:	e0a2                	sd	s0,64(sp)
    80003b12:	fc26                	sd	s1,56(sp)
    80003b14:	f84a                	sd	s2,48(sp)
    80003b16:	f44e                	sd	s3,40(sp)
    80003b18:	f052                	sd	s4,32(sp)
    80003b1a:	ec56                	sd	s5,24(sp)
    80003b1c:	e85a                	sd	s6,16(sp)
    80003b1e:	e45e                	sd	s7,8(sp)
    80003b20:	0880                	addi	s0,sp,80
    80003b22:	8b2a                	mv	s6,a0
    80003b24:	0001ea97          	auipc	s5,0x1e
    80003b28:	e3ca8a93          	addi	s5,s5,-452 # 80021960 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b2c:	4981                	li	s3,0
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b2e:	00004b97          	auipc	s7,0x4
    80003b32:	9cab8b93          	addi	s7,s7,-1590 # 800074f8 <etext+0x4f8>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003b36:	0001ea17          	auipc	s4,0x1e
    80003b3a:	dfaa0a13          	addi	s4,s4,-518 # 80021930 <log>
    80003b3e:	a025                	j	80003b66 <install_trans+0x66>
      printk("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b40:	000aa603          	lw	a2,0(s5)
    80003b44:	85ce                	mv	a1,s3
    80003b46:	855e                	mv	a0,s7
    80003b48:	9c3fc0ef          	jal	8000050a <printk>
    80003b4c:	a839                	j	80003b6a <install_trans+0x6a>
    brelse(lbuf);
    80003b4e:	854a                	mv	a0,s2
    80003b50:	8e8ff0ef          	jal	80002c38 <brelse>
    brelse(dbuf);
    80003b54:	8526                	mv	a0,s1
    80003b56:	8e2ff0ef          	jal	80002c38 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b5a:	2985                	addiw	s3,s3,1
    80003b5c:	0a91                	addi	s5,s5,4
    80003b5e:	02ca2783          	lw	a5,44(s4)
    80003b62:	04f9d663          	bge	s3,a5,80003bae <install_trans+0xae>
    if (recovering) {
    80003b66:	fc0b1de3          	bnez	s6,80003b40 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start + tail + 1); // read log block
    80003b6a:	018a2583          	lw	a1,24(s4)
    80003b6e:	013585bb          	addw	a1,a1,s3
    80003b72:	2585                	addiw	a1,a1,1
    80003b74:	024a2503          	lw	a0,36(s4)
    80003b78:	fb9fe0ef          	jal	80002b30 <bread>
    80003b7c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);   // read dst
    80003b7e:	000aa583          	lw	a1,0(s5)
    80003b82:	024a2503          	lw	a0,36(s4)
    80003b86:	fabfe0ef          	jal	80002b30 <bread>
    80003b8a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE); // copy block to dst
    80003b8c:	40000613          	li	a2,1024
    80003b90:	05890593          	addi	a1,s2,88
    80003b94:	05850513          	addi	a0,a0,88
    80003b98:	918fd0ef          	jal	80000cb0 <memmove>
    bwrite(dbuf);                           // write dst to disk
    80003b9c:	8526                	mv	a0,s1
    80003b9e:	868ff0ef          	jal	80002c06 <bwrite>
    if (recovering == 0)
    80003ba2:	fa0b16e3          	bnez	s6,80003b4e <install_trans+0x4e>
      bunpin(dbuf);
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	94cff0ef          	jal	80002cf4 <bunpin>
    80003bac:	b74d                	j	80003b4e <install_trans+0x4e>
}
    80003bae:	60a6                	ld	ra,72(sp)
    80003bb0:	6406                	ld	s0,64(sp)
    80003bb2:	74e2                	ld	s1,56(sp)
    80003bb4:	7942                	ld	s2,48(sp)
    80003bb6:	79a2                	ld	s3,40(sp)
    80003bb8:	7a02                	ld	s4,32(sp)
    80003bba:	6ae2                	ld	s5,24(sp)
    80003bbc:	6b42                	ld	s6,16(sp)
    80003bbe:	6ba2                	ld	s7,8(sp)
    80003bc0:	6161                	addi	sp,sp,80
    80003bc2:	8082                	ret
    80003bc4:	8082                	ret

0000000080003bc6 <initlog>:
{
    80003bc6:	7179                	addi	sp,sp,-48
    80003bc8:	f406                	sd	ra,40(sp)
    80003bca:	f022                	sd	s0,32(sp)
    80003bcc:	ec26                	sd	s1,24(sp)
    80003bce:	e84a                	sd	s2,16(sp)
    80003bd0:	e44e                	sd	s3,8(sp)
    80003bd2:	1800                	addi	s0,sp,48
    80003bd4:	892a                	mv	s2,a0
    80003bd6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003bd8:	0001e497          	auipc	s1,0x1e
    80003bdc:	d5848493          	addi	s1,s1,-680 # 80021930 <log>
    80003be0:	00004597          	auipc	a1,0x4
    80003be4:	93858593          	addi	a1,a1,-1736 # 80007518 <etext+0x518>
    80003be8:	8526                	mv	a0,s1
    80003bea:	f31fc0ef          	jal	80000b1a <initlock>
  log.start = sb->logstart;
    80003bee:	0149a583          	lw	a1,20(s3)
    80003bf2:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    80003bf4:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003bf8:	854a                	mv	a0,s2
    80003bfa:	f37fe0ef          	jal	80002b30 <bread>
  log.lh.n = lh->n;
    80003bfe:	4d30                	lw	a2,88(a0)
    80003c00:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003c02:	00c05f63          	blez	a2,80003c20 <initlog+0x5a>
    80003c06:	87aa                	mv	a5,a0
    80003c08:	0001e717          	auipc	a4,0x1e
    80003c0c:	d5870713          	addi	a4,a4,-680 # 80021960 <log+0x30>
    80003c10:	060a                	slli	a2,a2,0x2
    80003c12:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c14:	4ff4                	lw	a3,92(a5)
    80003c16:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c18:	0791                	addi	a5,a5,4
    80003c1a:	0711                	addi	a4,a4,4
    80003c1c:	fec79ce3          	bne	a5,a2,80003c14 <initlog+0x4e>
  brelse(buf);
    80003c20:	818ff0ef          	jal	80002c38 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c24:	4505                	li	a0,1
    80003c26:	edbff0ef          	jal	80003b00 <install_trans>
  log.lh.n = 0;
    80003c2a:	0001e797          	auipc	a5,0x1e
    80003c2e:	d207a923          	sw	zero,-718(a5) # 8002195c <log+0x2c>
  write_head(); // clear the log
    80003c32:	e71ff0ef          	jal	80003aa2 <write_head>
}
    80003c36:	70a2                	ld	ra,40(sp)
    80003c38:	7402                	ld	s0,32(sp)
    80003c3a:	64e2                	ld	s1,24(sp)
    80003c3c:	6942                	ld	s2,16(sp)
    80003c3e:	69a2                	ld	s3,8(sp)
    80003c40:	6145                	addi	sp,sp,48
    80003c42:	8082                	ret

0000000080003c44 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c44:	1101                	addi	sp,sp,-32
    80003c46:	ec06                	sd	ra,24(sp)
    80003c48:	e822                	sd	s0,16(sp)
    80003c4a:	e426                	sd	s1,8(sp)
    80003c4c:	e04a                	sd	s2,0(sp)
    80003c4e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003c50:	0001e517          	auipc	a0,0x1e
    80003c54:	ce050513          	addi	a0,a0,-800 # 80021930 <log>
    80003c58:	f39fc0ef          	jal	80000b90 <acquire>
  while (1) {
    if (log.committing) {
    80003c5c:	0001e497          	auipc	s1,0x1e
    80003c60:	cd448493          	addi	s1,s1,-812 # 80021930 <log>
      sleep_prepare(&log);
      release(&log.lock);
      sleep();
      acquire(&log.lock);
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003c64:	4979                	li	s2,30
    80003c66:	a821                	j	80003c7e <begin_op+0x3a>
      sleep_prepare(&log);
    80003c68:	8526                	mv	a0,s1
    80003c6a:	a4cfe0ef          	jal	80001eb6 <sleep_prepare>
      release(&log.lock);
    80003c6e:	8526                	mv	a0,s1
    80003c70:	fadfc0ef          	jal	80000c1c <release>
      sleep();
    80003c74:	a7efe0ef          	jal	80001ef2 <sleep>
      acquire(&log.lock);
    80003c78:	8526                	mv	a0,s1
    80003c7a:	f17fc0ef          	jal	80000b90 <acquire>
    if (log.committing) {
    80003c7e:	509c                	lw	a5,32(s1)
    80003c80:	f7e5                	bnez	a5,80003c68 <begin_op+0x24>
    } else if (log.lh.n + (log.outstanding + 1) * MAXOPBLOCKS > LOGBLOCKS) {
    80003c82:	4cd8                	lw	a4,28(s1)
    80003c84:	2705                	addiw	a4,a4,1
    80003c86:	0027179b          	slliw	a5,a4,0x2
    80003c8a:	9fb9                	addw	a5,a5,a4
    80003c8c:	0017979b          	slliw	a5,a5,0x1
    80003c90:	54d4                	lw	a3,44(s1)
    80003c92:	9fb5                	addw	a5,a5,a3
    80003c94:	00f95e63          	bge	s2,a5,80003cb0 <begin_op+0x6c>
      // this op might exhaust log space; wait for commit.
      sleep_prepare(&log);
    80003c98:	8526                	mv	a0,s1
    80003c9a:	a1cfe0ef          	jal	80001eb6 <sleep_prepare>
      release(&log.lock);
    80003c9e:	8526                	mv	a0,s1
    80003ca0:	f7dfc0ef          	jal	80000c1c <release>
      sleep();
    80003ca4:	a4efe0ef          	jal	80001ef2 <sleep>
      acquire(&log.lock);
    80003ca8:	8526                	mv	a0,s1
    80003caa:	ee7fc0ef          	jal	80000b90 <acquire>
    80003cae:	bfc1                	j	80003c7e <begin_op+0x3a>
    } else {
      log.outstanding += 1;
    80003cb0:	0001e517          	auipc	a0,0x1e
    80003cb4:	c8050513          	addi	a0,a0,-896 # 80021930 <log>
    80003cb8:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80003cba:	f63fc0ef          	jal	80000c1c <release>
      break;
    }
  }
}
    80003cbe:	60e2                	ld	ra,24(sp)
    80003cc0:	6442                	ld	s0,16(sp)
    80003cc2:	64a2                	ld	s1,8(sp)
    80003cc4:	6902                	ld	s2,0(sp)
    80003cc6:	6105                	addi	sp,sp,32
    80003cc8:	8082                	ret

0000000080003cca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003cca:	7139                	addi	sp,sp,-64
    80003ccc:	fc06                	sd	ra,56(sp)
    80003cce:	f822                	sd	s0,48(sp)
    80003cd0:	f426                	sd	s1,40(sp)
    80003cd2:	f04a                	sd	s2,32(sp)
    80003cd4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003cd6:	0001e497          	auipc	s1,0x1e
    80003cda:	c5a48493          	addi	s1,s1,-934 # 80021930 <log>
    80003cde:	8526                	mv	a0,s1
    80003ce0:	eb1fc0ef          	jal	80000b90 <acquire>
  log.outstanding -= 1;
    80003ce4:	4cdc                	lw	a5,28(s1)
    80003ce6:	37fd                	addiw	a5,a5,-1
    80003ce8:	0007891b          	sext.w	s2,a5
    80003cec:	ccdc                	sw	a5,28(s1)
  if (log.committing)
    80003cee:	509c                	lw	a5,32(s1)
    80003cf0:	e3b1                	bnez	a5,80003d34 <end_op+0x6a>
    panic("log.committing");
  if (log.outstanding == 0) {
    80003cf2:	04091a63          	bnez	s2,80003d46 <end_op+0x7c>
    do_commit = 1;
    log.committing = 1;
    80003cf6:	0001e497          	auipc	s1,0x1e
    80003cfa:	c3a48493          	addi	s1,s1,-966 # 80021930 <log>
    80003cfe:	4785                	li	a5,1
    80003d00:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d02:	8526                	mv	a0,s1
    80003d04:	f19fc0ef          	jal	80000c1c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d08:	54dc                	lw	a5,44(s1)
    80003d0a:	04f04e63          	bgtz	a5,80003d66 <end_op+0x9c>
    acquire(&log.lock);
    80003d0e:	0001e497          	auipc	s1,0x1e
    80003d12:	c2248493          	addi	s1,s1,-990 # 80021930 <log>
    80003d16:	8526                	mv	a0,s1
    80003d18:	e79fc0ef          	jal	80000b90 <acquire>
    log.committing = 0;
    80003d1c:	0204a023          	sw	zero,32(s1)
    log.ncommit += 1;
    80003d20:	549c                	lw	a5,40(s1)
    80003d22:	2785                	addiw	a5,a5,1
    80003d24:	d49c                	sw	a5,40(s1)
    wakeup(&log);
    80003d26:	8526                	mv	a0,s1
    80003d28:	9fafe0ef          	jal	80001f22 <wakeup>
    release(&log.lock);
    80003d2c:	8526                	mv	a0,s1
    80003d2e:	eeffc0ef          	jal	80000c1c <release>
}
    80003d32:	a025                	j	80003d5a <end_op+0x90>
    80003d34:	ec4e                	sd	s3,24(sp)
    80003d36:	e852                	sd	s4,16(sp)
    80003d38:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d3a:	00003517          	auipc	a0,0x3
    80003d3e:	7e650513          	addi	a0,a0,2022 # 80007520 <etext+0x520>
    80003d42:	aaffc0ef          	jal	800007f0 <panic>
    wakeup(&log);
    80003d46:	0001e497          	auipc	s1,0x1e
    80003d4a:	bea48493          	addi	s1,s1,-1046 # 80021930 <log>
    80003d4e:	8526                	mv	a0,s1
    80003d50:	9d2fe0ef          	jal	80001f22 <wakeup>
  release(&log.lock);
    80003d54:	8526                	mv	a0,s1
    80003d56:	ec7fc0ef          	jal	80000c1c <release>
}
    80003d5a:	70e2                	ld	ra,56(sp)
    80003d5c:	7442                	ld	s0,48(sp)
    80003d5e:	74a2                	ld	s1,40(sp)
    80003d60:	7902                	ld	s2,32(sp)
    80003d62:	6121                	addi	sp,sp,64
    80003d64:	8082                	ret
    80003d66:	ec4e                	sd	s3,24(sp)
    80003d68:	e852                	sd	s4,16(sp)
    80003d6a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003d6c:	0001ea97          	auipc	s5,0x1e
    80003d70:	bf4a8a93          	addi	s5,s5,-1036 # 80021960 <log+0x30>
    struct buf *to = bread(log.dev, log.start + tail + 1); // log block
    80003d74:	0001ea17          	auipc	s4,0x1e
    80003d78:	bbca0a13          	addi	s4,s4,-1092 # 80021930 <log>
    80003d7c:	018a2583          	lw	a1,24(s4)
    80003d80:	012585bb          	addw	a1,a1,s2
    80003d84:	2585                	addiw	a1,a1,1
    80003d86:	024a2503          	lw	a0,36(s4)
    80003d8a:	da7fe0ef          	jal	80002b30 <bread>
    80003d8e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003d90:	000aa583          	lw	a1,0(s5)
    80003d94:	024a2503          	lw	a0,36(s4)
    80003d98:	d99fe0ef          	jal	80002b30 <bread>
    80003d9c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003d9e:	40000613          	li	a2,1024
    80003da2:	05850593          	addi	a1,a0,88
    80003da6:	05848513          	addi	a0,s1,88
    80003daa:	f07fc0ef          	jal	80000cb0 <memmove>
    bwrite(to); // write the log
    80003dae:	8526                	mv	a0,s1
    80003db0:	e57fe0ef          	jal	80002c06 <bwrite>
    brelse(from);
    80003db4:	854e                	mv	a0,s3
    80003db6:	e83fe0ef          	jal	80002c38 <brelse>
    brelse(to);
    80003dba:	8526                	mv	a0,s1
    80003dbc:	e7dfe0ef          	jal	80002c38 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dc0:	2905                	addiw	s2,s2,1
    80003dc2:	0a91                	addi	s5,s5,4
    80003dc4:	02ca2783          	lw	a5,44(s4)
    80003dc8:	faf94ae3          	blt	s2,a5,80003d7c <end_op+0xb2>
    write_log();      // Write modified blocks from cache to log
    write_head();     // Write header to disk -- the real commit
    80003dcc:	cd7ff0ef          	jal	80003aa2 <write_head>
    install_trans(0); // Now install writes to home locations
    80003dd0:	4501                	li	a0,0
    80003dd2:	d2fff0ef          	jal	80003b00 <install_trans>
    log.lh.n = 0;
    80003dd6:	0001e797          	auipc	a5,0x1e
    80003dda:	b807a323          	sw	zero,-1146(a5) # 8002195c <log+0x2c>
    write_head(); // Erase the transaction from the log
    80003dde:	cc5ff0ef          	jal	80003aa2 <write_head>
    80003de2:	69e2                	ld	s3,24(sp)
    80003de4:	6a42                	ld	s4,16(sp)
    80003de6:	6aa2                	ld	s5,8(sp)
    80003de8:	b71d                	j	80003d0e <end_op+0x44>

0000000080003dea <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003dea:	1101                	addi	sp,sp,-32
    80003dec:	ec06                	sd	ra,24(sp)
    80003dee:	e822                	sd	s0,16(sp)
    80003df0:	e426                	sd	s1,8(sp)
    80003df2:	e04a                	sd	s2,0(sp)
    80003df4:	1000                	addi	s0,sp,32
    80003df6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003df8:	0001e917          	auipc	s2,0x1e
    80003dfc:	b3890913          	addi	s2,s2,-1224 # 80021930 <log>
    80003e00:	854a                	mv	a0,s2
    80003e02:	d8ffc0ef          	jal	80000b90 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e06:	02c92603          	lw	a2,44(s2)
    80003e0a:	47f5                	li	a5,29
    80003e0c:	04c7cc63          	blt	a5,a2,80003e64 <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e10:	0001e797          	auipc	a5,0x1e
    80003e14:	b3c7a783          	lw	a5,-1220(a5) # 8002194c <log+0x1c>
    80003e18:	04f05c63          	blez	a5,80003e70 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e1c:	4781                	li	a5,0
    80003e1e:	04c05f63          	blez	a2,80003e7c <log_write+0x92>
    if (log.lh.block[i] == b->blockno) // log absorption
    80003e22:	44cc                	lw	a1,12(s1)
    80003e24:	0001e717          	auipc	a4,0x1e
    80003e28:	b3c70713          	addi	a4,a4,-1220 # 80021960 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003e2c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno) // log absorption
    80003e2e:	4314                	lw	a3,0(a4)
    80003e30:	04b68663          	beq	a3,a1,80003e7c <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    80003e34:	2785                	addiw	a5,a5,1
    80003e36:	0711                	addi	a4,a4,4
    80003e38:	fef61be3          	bne	a2,a5,80003e2e <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e3c:	0621                	addi	a2,a2,8
    80003e3e:	060a                	slli	a2,a2,0x2
    80003e40:	0001e797          	auipc	a5,0x1e
    80003e44:	af078793          	addi	a5,a5,-1296 # 80021930 <log>
    80003e48:	97b2                	add	a5,a5,a2
    80003e4a:	44d8                	lw	a4,12(s1)
    80003e4c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) { // Add new block to log?
    bpin(b);
    80003e4e:	8526                	mv	a0,s1
    80003e50:	e71fe0ef          	jal	80002cc0 <bpin>
    log.lh.n++;
    80003e54:	0001e717          	auipc	a4,0x1e
    80003e58:	adc70713          	addi	a4,a4,-1316 # 80021930 <log>
    80003e5c:	575c                	lw	a5,44(a4)
    80003e5e:	2785                	addiw	a5,a5,1
    80003e60:	d75c                	sw	a5,44(a4)
    80003e62:	a80d                	j	80003e94 <log_write+0xaa>
    panic("too big a transaction");
    80003e64:	00003517          	auipc	a0,0x3
    80003e68:	6cc50513          	addi	a0,a0,1740 # 80007530 <etext+0x530>
    80003e6c:	985fc0ef          	jal	800007f0 <panic>
    panic("log_write outside of trans");
    80003e70:	00003517          	auipc	a0,0x3
    80003e74:	6d850513          	addi	a0,a0,1752 # 80007548 <etext+0x548>
    80003e78:	979fc0ef          	jal	800007f0 <panic>
  log.lh.block[i] = b->blockno;
    80003e7c:	00878693          	addi	a3,a5,8
    80003e80:	068a                	slli	a3,a3,0x2
    80003e82:	0001e717          	auipc	a4,0x1e
    80003e86:	aae70713          	addi	a4,a4,-1362 # 80021930 <log>
    80003e8a:	9736                	add	a4,a4,a3
    80003e8c:	44d4                	lw	a3,12(s1)
    80003e8e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) { // Add new block to log?
    80003e90:	faf60fe3          	beq	a2,a5,80003e4e <log_write+0x64>
  }
  release(&log.lock);
    80003e94:	0001e517          	auipc	a0,0x1e
    80003e98:	a9c50513          	addi	a0,a0,-1380 # 80021930 <log>
    80003e9c:	d81fc0ef          	jal	80000c1c <release>
}
    80003ea0:	60e2                	ld	ra,24(sp)
    80003ea2:	6442                	ld	s0,16(sp)
    80003ea4:	64a2                	ld	s1,8(sp)
    80003ea6:	6902                	ld	s2,0(sp)
    80003ea8:	6105                	addi	sp,sp,32
    80003eaa:	8082                	ret

0000000080003eac <sys_sync>:

uint64
sys_sync(void)
{
    80003eac:	1101                	addi	sp,sp,-32
    80003eae:	ec06                	sd	ra,24(sp)
    80003eb0:	e822                	sd	s0,16(sp)
    80003eb2:	e426                	sd	s1,8(sp)
    80003eb4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003eb6:	0001e497          	auipc	s1,0x1e
    80003eba:	a7a48493          	addi	s1,s1,-1414 # 80021930 <log>
    80003ebe:	8526                	mv	a0,s1
    80003ec0:	cd1fc0ef          	jal	80000b90 <acquire>
  if (log.committing || log.outstanding > 0) {
    80003ec4:	509c                	lw	a5,32(s1)
    80003ec6:	e799                	bnez	a5,80003ed4 <sys_sync+0x28>
    80003ec8:	0001e797          	auipc	a5,0x1e
    80003ecc:	a847a783          	lw	a5,-1404(a5) # 8002194c <log+0x1c>
    80003ed0:	02f05a63          	blez	a5,80003f04 <sys_sync+0x58>
    80003ed4:	e04a                	sd	s2,0(sp)
    int n = log.ncommit + 1;
    80003ed6:	0001e917          	auipc	s2,0x1e
    80003eda:	a8292903          	lw	s2,-1406(s2) # 80021958 <log+0x28>
    while (log.ncommit < n) {
      sleep_prepare(&log);
    80003ede:	0001e497          	auipc	s1,0x1e
    80003ee2:	a5248493          	addi	s1,s1,-1454 # 80021930 <log>
    80003ee6:	8526                	mv	a0,s1
    80003ee8:	fcffd0ef          	jal	80001eb6 <sleep_prepare>
      release(&log.lock);
    80003eec:	8526                	mv	a0,s1
    80003eee:	d2ffc0ef          	jal	80000c1c <release>
      sleep();
    80003ef2:	800fe0ef          	jal	80001ef2 <sleep>
      acquire(&log.lock);
    80003ef6:	8526                	mv	a0,s1
    80003ef8:	c99fc0ef          	jal	80000b90 <acquire>
    while (log.ncommit < n) {
    80003efc:	549c                	lw	a5,40(s1)
    80003efe:	fef954e3          	bge	s2,a5,80003ee6 <sys_sync+0x3a>
    80003f02:	6902                	ld	s2,0(sp)
    }
  }
  release(&log.lock);
    80003f04:	0001e517          	auipc	a0,0x1e
    80003f08:	a2c50513          	addi	a0,a0,-1492 # 80021930 <log>
    80003f0c:	d11fc0ef          	jal	80000c1c <release>
  return 0;
}
    80003f10:	4501                	li	a0,0
    80003f12:	60e2                	ld	ra,24(sp)
    80003f14:	6442                	ld	s0,16(sp)
    80003f16:	64a2                	ld	s1,8(sp)
    80003f18:	6105                	addi	sp,sp,32
    80003f1a:	8082                	ret

0000000080003f1c <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003f1c:	1101                	addi	sp,sp,-32
    80003f1e:	ec06                	sd	ra,24(sp)
    80003f20:	e822                	sd	s0,16(sp)
    80003f22:	e426                	sd	s1,8(sp)
    80003f24:	e04a                	sd	s2,0(sp)
    80003f26:	1000                	addi	s0,sp,32
    80003f28:	84aa                	mv	s1,a0
    80003f2a:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f2c:	00003597          	auipc	a1,0x3
    80003f30:	63c58593          	addi	a1,a1,1596 # 80007568 <etext+0x568>
    80003f34:	0521                	addi	a0,a0,8
    80003f36:	be5fc0ef          	jal	80000b1a <initlock>
  lk->name = name;
    80003f3a:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f3e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f42:	0204a423          	sw	zero,40(s1)
}
    80003f46:	60e2                	ld	ra,24(sp)
    80003f48:	6442                	ld	s0,16(sp)
    80003f4a:	64a2                	ld	s1,8(sp)
    80003f4c:	6902                	ld	s2,0(sp)
    80003f4e:	6105                	addi	sp,sp,32
    80003f50:	8082                	ret

0000000080003f52 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f52:	1101                	addi	sp,sp,-32
    80003f54:	ec06                	sd	ra,24(sp)
    80003f56:	e822                	sd	s0,16(sp)
    80003f58:	e426                	sd	s1,8(sp)
    80003f5a:	e04a                	sd	s2,0(sp)
    80003f5c:	1000                	addi	s0,sp,32
    80003f5e:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f60:	00850913          	addi	s2,a0,8
    80003f64:	854a                	mv	a0,s2
    80003f66:	c2bfc0ef          	jal	80000b90 <acquire>
  while (lk->locked) {
    80003f6a:	409c                	lw	a5,0(s1)
    80003f6c:	cf91                	beqz	a5,80003f88 <acquiresleep+0x36>
    sleep_prepare(lk);
    80003f6e:	8526                	mv	a0,s1
    80003f70:	f47fd0ef          	jal	80001eb6 <sleep_prepare>
    release(&lk->lk);
    80003f74:	854a                	mv	a0,s2
    80003f76:	ca7fc0ef          	jal	80000c1c <release>
    sleep();
    80003f7a:	f79fd0ef          	jal	80001ef2 <sleep>
    acquire(&lk->lk);
    80003f7e:	854a                	mv	a0,s2
    80003f80:	c11fc0ef          	jal	80000b90 <acquire>
  while (lk->locked) {
    80003f84:	409c                	lw	a5,0(s1)
    80003f86:	f7e5                	bnez	a5,80003f6e <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f88:	4785                	li	a5,1
    80003f8a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f8c:	917fd0ef          	jal	800018a2 <myproc>
    80003f90:	591c                	lw	a5,48(a0)
    80003f92:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f94:	854a                	mv	a0,s2
    80003f96:	c87fc0ef          	jal	80000c1c <release>
}
    80003f9a:	60e2                	ld	ra,24(sp)
    80003f9c:	6442                	ld	s0,16(sp)
    80003f9e:	64a2                	ld	s1,8(sp)
    80003fa0:	6902                	ld	s2,0(sp)
    80003fa2:	6105                	addi	sp,sp,32
    80003fa4:	8082                	ret

0000000080003fa6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003fa6:	1101                	addi	sp,sp,-32
    80003fa8:	ec06                	sd	ra,24(sp)
    80003faa:	e822                	sd	s0,16(sp)
    80003fac:	e426                	sd	s1,8(sp)
    80003fae:	e04a                	sd	s2,0(sp)
    80003fb0:	1000                	addi	s0,sp,32
    80003fb2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003fb4:	00850913          	addi	s2,a0,8
    80003fb8:	854a                	mv	a0,s2
    80003fba:	bd7fc0ef          	jal	80000b90 <acquire>
  lk->locked = 0;
    80003fbe:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003fc2:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003fc6:	8526                	mv	a0,s1
    80003fc8:	f5bfd0ef          	jal	80001f22 <wakeup>
  release(&lk->lk);
    80003fcc:	854a                	mv	a0,s2
    80003fce:	c4ffc0ef          	jal	80000c1c <release>
}
    80003fd2:	60e2                	ld	ra,24(sp)
    80003fd4:	6442                	ld	s0,16(sp)
    80003fd6:	64a2                	ld	s1,8(sp)
    80003fd8:	6902                	ld	s2,0(sp)
    80003fda:	6105                	addi	sp,sp,32
    80003fdc:	8082                	ret

0000000080003fde <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003fde:	7179                	addi	sp,sp,-48
    80003fe0:	f406                	sd	ra,40(sp)
    80003fe2:	f022                	sd	s0,32(sp)
    80003fe4:	ec26                	sd	s1,24(sp)
    80003fe6:	e84a                	sd	s2,16(sp)
    80003fe8:	1800                	addi	s0,sp,48
    80003fea:	84aa                	mv	s1,a0
  int r;

  acquire(&lk->lk);
    80003fec:	00850913          	addi	s2,a0,8
    80003ff0:	854a                	mv	a0,s2
    80003ff2:	b9ffc0ef          	jal	80000b90 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003ff6:	409c                	lw	a5,0(s1)
    80003ff8:	ef81                	bnez	a5,80004010 <holdingsleep+0x32>
    80003ffa:	4481                	li	s1,0
  release(&lk->lk);
    80003ffc:	854a                	mv	a0,s2
    80003ffe:	c1ffc0ef          	jal	80000c1c <release>
  return r;
}
    80004002:	8526                	mv	a0,s1
    80004004:	70a2                	ld	ra,40(sp)
    80004006:	7402                	ld	s0,32(sp)
    80004008:	64e2                	ld	s1,24(sp)
    8000400a:	6942                	ld	s2,16(sp)
    8000400c:	6145                	addi	sp,sp,48
    8000400e:	8082                	ret
    80004010:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004012:	0284a983          	lw	s3,40(s1)
    80004016:	88dfd0ef          	jal	800018a2 <myproc>
    8000401a:	5904                	lw	s1,48(a0)
    8000401c:	413484b3          	sub	s1,s1,s3
    80004020:	0014b493          	seqz	s1,s1
    80004024:	69a2                	ld	s3,8(sp)
    80004026:	bfd9                	j	80003ffc <holdingsleep+0x1e>

0000000080004028 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004028:	1141                	addi	sp,sp,-16
    8000402a:	e406                	sd	ra,8(sp)
    8000402c:	e022                	sd	s0,0(sp)
    8000402e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004030:	00003597          	auipc	a1,0x3
    80004034:	54858593          	addi	a1,a1,1352 # 80007578 <etext+0x578>
    80004038:	0001e517          	auipc	a0,0x1e
    8000403c:	a4050513          	addi	a0,a0,-1472 # 80021a78 <ftable>
    80004040:	adbfc0ef          	jal	80000b1a <initlock>
}
    80004044:	60a2                	ld	ra,8(sp)
    80004046:	6402                	ld	s0,0(sp)
    80004048:	0141                	addi	sp,sp,16
    8000404a:	8082                	ret

000000008000404c <filealloc>:

// Allocate a file structure.
struct file *
filealloc(void)
{
    8000404c:	1101                	addi	sp,sp,-32
    8000404e:	ec06                	sd	ra,24(sp)
    80004050:	e822                	sd	s0,16(sp)
    80004052:	e426                	sd	s1,8(sp)
    80004054:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004056:	0001e517          	auipc	a0,0x1e
    8000405a:	a2250513          	addi	a0,a0,-1502 # 80021a78 <ftable>
    8000405e:	b33fc0ef          	jal	80000b90 <acquire>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004062:	0001e497          	auipc	s1,0x1e
    80004066:	a2e48493          	addi	s1,s1,-1490 # 80021a90 <ftable+0x18>
    8000406a:	0001f717          	auipc	a4,0x1f
    8000406e:	9c670713          	addi	a4,a4,-1594 # 80022a30 <disk>
    if (f->ref == 0) {
    80004072:	40dc                	lw	a5,4(s1)
    80004074:	cf89                	beqz	a5,8000408e <filealloc+0x42>
  for (f = ftable.file; f < ftable.file + NFILE; f++) {
    80004076:	02848493          	addi	s1,s1,40
    8000407a:	fee49ce3          	bne	s1,a4,80004072 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000407e:	0001e517          	auipc	a0,0x1e
    80004082:	9fa50513          	addi	a0,a0,-1542 # 80021a78 <ftable>
    80004086:	b97fc0ef          	jal	80000c1c <release>
  return 0;
    8000408a:	4481                	li	s1,0
    8000408c:	a809                	j	8000409e <filealloc+0x52>
      f->ref = 1;
    8000408e:	4785                	li	a5,1
    80004090:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004092:	0001e517          	auipc	a0,0x1e
    80004096:	9e650513          	addi	a0,a0,-1562 # 80021a78 <ftable>
    8000409a:	b83fc0ef          	jal	80000c1c <release>
}
    8000409e:	8526                	mv	a0,s1
    800040a0:	60e2                	ld	ra,24(sp)
    800040a2:	6442                	ld	s0,16(sp)
    800040a4:	64a2                	ld	s1,8(sp)
    800040a6:	6105                	addi	sp,sp,32
    800040a8:	8082                	ret

00000000800040aa <filedup>:

// Increment ref count for file f.
struct file *
filedup(struct file *f)
{
    800040aa:	1101                	addi	sp,sp,-32
    800040ac:	ec06                	sd	ra,24(sp)
    800040ae:	e822                	sd	s0,16(sp)
    800040b0:	e426                	sd	s1,8(sp)
    800040b2:	1000                	addi	s0,sp,32
    800040b4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800040b6:	0001e517          	auipc	a0,0x1e
    800040ba:	9c250513          	addi	a0,a0,-1598 # 80021a78 <ftable>
    800040be:	ad3fc0ef          	jal	80000b90 <acquire>
  if (f->ref < 1)
    800040c2:	40dc                	lw	a5,4(s1)
    800040c4:	02f05063          	blez	a5,800040e4 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800040c8:	2785                	addiw	a5,a5,1
    800040ca:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800040cc:	0001e517          	auipc	a0,0x1e
    800040d0:	9ac50513          	addi	a0,a0,-1620 # 80021a78 <ftable>
    800040d4:	b49fc0ef          	jal	80000c1c <release>
  return f;
}
    800040d8:	8526                	mv	a0,s1
    800040da:	60e2                	ld	ra,24(sp)
    800040dc:	6442                	ld	s0,16(sp)
    800040de:	64a2                	ld	s1,8(sp)
    800040e0:	6105                	addi	sp,sp,32
    800040e2:	8082                	ret
    panic("filedup");
    800040e4:	00003517          	auipc	a0,0x3
    800040e8:	49c50513          	addi	a0,a0,1180 # 80007580 <etext+0x580>
    800040ec:	f04fc0ef          	jal	800007f0 <panic>

00000000800040f0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800040f0:	7139                	addi	sp,sp,-64
    800040f2:	fc06                	sd	ra,56(sp)
    800040f4:	f822                	sd	s0,48(sp)
    800040f6:	f426                	sd	s1,40(sp)
    800040f8:	0080                	addi	s0,sp,64
    800040fa:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040fc:	0001e517          	auipc	a0,0x1e
    80004100:	97c50513          	addi	a0,a0,-1668 # 80021a78 <ftable>
    80004104:	a8dfc0ef          	jal	80000b90 <acquire>
  if (f->ref < 1)
    80004108:	40dc                	lw	a5,4(s1)
    8000410a:	04f05a63          	blez	a5,8000415e <fileclose+0x6e>
    panic("fileclose");
  if (--f->ref > 0) {
    8000410e:	37fd                	addiw	a5,a5,-1
    80004110:	0007871b          	sext.w	a4,a5
    80004114:	c0dc                	sw	a5,4(s1)
    80004116:	04e04e63          	bgtz	a4,80004172 <fileclose+0x82>
    8000411a:	f04a                	sd	s2,32(sp)
    8000411c:	ec4e                	sd	s3,24(sp)
    8000411e:	e852                	sd	s4,16(sp)
    80004120:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004122:	0004a903          	lw	s2,0(s1)
    80004126:	0094ca83          	lbu	s5,9(s1)
    8000412a:	0104ba03          	ld	s4,16(s1)
    8000412e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004132:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004136:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000413a:	0001e517          	auipc	a0,0x1e
    8000413e:	93e50513          	addi	a0,a0,-1730 # 80021a78 <ftable>
    80004142:	adbfc0ef          	jal	80000c1c <release>

  if (ff.type == FD_PIPE) {
    80004146:	4785                	li	a5,1
    80004148:	04f90063          	beq	s2,a5,80004188 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if (ff.type == FD_INODE || ff.type == FD_DEVICE) {
    8000414c:	3979                	addiw	s2,s2,-2
    8000414e:	4785                	li	a5,1
    80004150:	0527f563          	bgeu	a5,s2,8000419a <fileclose+0xaa>
    80004154:	7902                	ld	s2,32(sp)
    80004156:	69e2                	ld	s3,24(sp)
    80004158:	6a42                	ld	s4,16(sp)
    8000415a:	6aa2                	ld	s5,8(sp)
    8000415c:	a00d                	j	8000417e <fileclose+0x8e>
    8000415e:	f04a                	sd	s2,32(sp)
    80004160:	ec4e                	sd	s3,24(sp)
    80004162:	e852                	sd	s4,16(sp)
    80004164:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004166:	00003517          	auipc	a0,0x3
    8000416a:	42250513          	addi	a0,a0,1058 # 80007588 <etext+0x588>
    8000416e:	e82fc0ef          	jal	800007f0 <panic>
    release(&ftable.lock);
    80004172:	0001e517          	auipc	a0,0x1e
    80004176:	90650513          	addi	a0,a0,-1786 # 80021a78 <ftable>
    8000417a:	aa3fc0ef          	jal	80000c1c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000417e:	70e2                	ld	ra,56(sp)
    80004180:	7442                	ld	s0,48(sp)
    80004182:	74a2                	ld	s1,40(sp)
    80004184:	6121                	addi	sp,sp,64
    80004186:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004188:	85d6                	mv	a1,s5
    8000418a:	8552                	mv	a0,s4
    8000418c:	34c000ef          	jal	800044d8 <pipeclose>
    80004190:	7902                	ld	s2,32(sp)
    80004192:	69e2                	ld	s3,24(sp)
    80004194:	6a42                	ld	s4,16(sp)
    80004196:	6aa2                	ld	s5,8(sp)
    80004198:	b7dd                	j	8000417e <fileclose+0x8e>
    begin_op();
    8000419a:	aabff0ef          	jal	80003c44 <begin_op>
    iput(ff.ip);
    8000419e:	854e                	mv	a0,s3
    800041a0:	9deff0ef          	jal	8000337e <iput>
    end_op();
    800041a4:	b27ff0ef          	jal	80003cca <end_op>
    800041a8:	7902                	ld	s2,32(sp)
    800041aa:	69e2                	ld	s3,24(sp)
    800041ac:	6a42                	ld	s4,16(sp)
    800041ae:	6aa2                	ld	s5,8(sp)
    800041b0:	b7f9                	j	8000417e <fileclose+0x8e>

00000000800041b2 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800041b2:	715d                	addi	sp,sp,-80
    800041b4:	e486                	sd	ra,72(sp)
    800041b6:	e0a2                	sd	s0,64(sp)
    800041b8:	fc26                	sd	s1,56(sp)
    800041ba:	f44e                	sd	s3,40(sp)
    800041bc:	0880                	addi	s0,sp,80
    800041be:	84aa                	mv	s1,a0
    800041c0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800041c2:	ee0fd0ef          	jal	800018a2 <myproc>
  struct stat st;

  if (f->type == FD_INODE || f->type == FD_DEVICE) {
    800041c6:	409c                	lw	a5,0(s1)
    800041c8:	37f9                	addiw	a5,a5,-2
    800041ca:	4705                	li	a4,1
    800041cc:	04f76263          	bltu	a4,a5,80004210 <filestat+0x5e>
    800041d0:	f84a                	sd	s2,48(sp)
    800041d2:	892a                	mv	s2,a0
    ilock(f->ip);
    800041d4:	6c88                	ld	a0,24(s1)
    800041d6:	826ff0ef          	jal	800031fc <ilock>
    stati(f->ip, &st);
    800041da:	fb840593          	addi	a1,s0,-72
    800041de:	6c88                	ld	a0,24(s1)
    800041e0:	bcaff0ef          	jal	800035aa <stati>
    iunlock(f->ip);
    800041e4:	6c88                	ld	a0,24(s1)
    800041e6:	8c4ff0ef          	jal	800032aa <iunlock>
    if (copyout(p->pagetable, p->sz, addr, (char *)&st, sizeof(st)) < 0)
    800041ea:	4761                	li	a4,24
    800041ec:	fb840693          	addi	a3,s0,-72
    800041f0:	864e                	mv	a2,s3
    800041f2:	04893583          	ld	a1,72(s2)
    800041f6:	05093503          	ld	a0,80(s2)
    800041fa:	adefd0ef          	jal	800014d8 <copyout>
    800041fe:	41f5551b          	sraiw	a0,a0,0x1f
    80004202:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004204:	60a6                	ld	ra,72(sp)
    80004206:	6406                	ld	s0,64(sp)
    80004208:	74e2                	ld	s1,56(sp)
    8000420a:	79a2                	ld	s3,40(sp)
    8000420c:	6161                	addi	sp,sp,80
    8000420e:	8082                	ret
  return -1;
    80004210:	557d                	li	a0,-1
    80004212:	bfcd                	j	80004204 <filestat+0x52>

0000000080004214 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004214:	7179                	addi	sp,sp,-48
    80004216:	f406                	sd	ra,40(sp)
    80004218:	f022                	sd	s0,32(sp)
    8000421a:	e84a                	sd	s2,16(sp)
    8000421c:	1800                	addi	s0,sp,48
  int r = 0;

  if (f->readable == 0 || n < 0)
    8000421e:	00854783          	lbu	a5,8(a0)
    80004222:	c3c5                	beqz	a5,800042c2 <fileread+0xae>
    80004224:	ec26                	sd	s1,24(sp)
    80004226:	e44e                	sd	s3,8(sp)
    80004228:	84aa                	mv	s1,a0
    8000422a:	89ae                	mv	s3,a1
    8000422c:	8932                	mv	s2,a2
    8000422e:	08064c63          	bltz	a2,800042c6 <fileread+0xb2>
    return -1;

  if (f->type == FD_PIPE) {
    80004232:	411c                	lw	a5,0(a0)
    80004234:	4705                	li	a4,1
    80004236:	04e78363          	beq	a5,a4,8000427c <fileread+0x68>
    r = piperead(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    8000423a:	470d                	li	a4,3
    8000423c:	04e78763          	beq	a5,a4,8000428a <fileread+0x76>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if (f->type == FD_INODE) {
    80004240:	4709                	li	a4,2
    80004242:	06e79a63          	bne	a5,a4,800042b6 <fileread+0xa2>
    ilock(f->ip);
    80004246:	6d08                	ld	a0,24(a0)
    80004248:	fb5fe0ef          	jal	800031fc <ilock>
    if ((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000424c:	874a                	mv	a4,s2
    8000424e:	5094                	lw	a3,32(s1)
    80004250:	864e                	mv	a2,s3
    80004252:	4585                	li	a1,1
    80004254:	6c88                	ld	a0,24(s1)
    80004256:	b7eff0ef          	jal	800035d4 <readi>
    8000425a:	892a                	mv	s2,a0
    8000425c:	00a05563          	blez	a0,80004266 <fileread+0x52>
      f->off += r;
    80004260:	509c                	lw	a5,32(s1)
    80004262:	9fa9                	addw	a5,a5,a0
    80004264:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004266:	6c88                	ld	a0,24(s1)
    80004268:	842ff0ef          	jal	800032aa <iunlock>
    8000426c:	64e2                	ld	s1,24(sp)
    8000426e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004270:	854a                	mv	a0,s2
    80004272:	70a2                	ld	ra,40(sp)
    80004274:	7402                	ld	s0,32(sp)
    80004276:	6942                	ld	s2,16(sp)
    80004278:	6145                	addi	sp,sp,48
    8000427a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000427c:	6908                	ld	a0,16(a0)
    8000427e:	3b6000ef          	jal	80004634 <piperead>
    80004282:	892a                	mv	s2,a0
    80004284:	64e2                	ld	s1,24(sp)
    80004286:	69a2                	ld	s3,8(sp)
    80004288:	b7e5                	j	80004270 <fileread+0x5c>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000428a:	02451783          	lh	a5,36(a0)
    8000428e:	03079693          	slli	a3,a5,0x30
    80004292:	92c1                	srli	a3,a3,0x30
    80004294:	4725                	li	a4,9
    80004296:	02d76c63          	bltu	a4,a3,800042ce <fileread+0xba>
    8000429a:	0792                	slli	a5,a5,0x4
    8000429c:	0001d717          	auipc	a4,0x1d
    800042a0:	73c70713          	addi	a4,a4,1852 # 800219d8 <devsw>
    800042a4:	97ba                	add	a5,a5,a4
    800042a6:	639c                	ld	a5,0(a5)
    800042a8:	c79d                	beqz	a5,800042d6 <fileread+0xc2>
    r = devsw[f->major].read(1, addr, n);
    800042aa:	4505                	li	a0,1
    800042ac:	9782                	jalr	a5
    800042ae:	892a                	mv	s2,a0
    800042b0:	64e2                	ld	s1,24(sp)
    800042b2:	69a2                	ld	s3,8(sp)
    800042b4:	bf75                	j	80004270 <fileread+0x5c>
    panic("fileread");
    800042b6:	00003517          	auipc	a0,0x3
    800042ba:	2e250513          	addi	a0,a0,738 # 80007598 <etext+0x598>
    800042be:	d32fc0ef          	jal	800007f0 <panic>
    return -1;
    800042c2:	597d                	li	s2,-1
    800042c4:	b775                	j	80004270 <fileread+0x5c>
    800042c6:	597d                	li	s2,-1
    800042c8:	64e2                	ld	s1,24(sp)
    800042ca:	69a2                	ld	s3,8(sp)
    800042cc:	b755                	j	80004270 <fileread+0x5c>
      return -1;
    800042ce:	597d                	li	s2,-1
    800042d0:	64e2                	ld	s1,24(sp)
    800042d2:	69a2                	ld	s3,8(sp)
    800042d4:	bf71                	j	80004270 <fileread+0x5c>
    800042d6:	597d                	li	s2,-1
    800042d8:	64e2                	ld	s1,24(sp)
    800042da:	69a2                	ld	s3,8(sp)
    800042dc:	bf51                	j	80004270 <fileread+0x5c>

00000000800042de <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if (f->writable == 0 || n < 0)
    800042de:	00954783          	lbu	a5,9(a0)
    800042e2:	10078663          	beqz	a5,800043ee <filewrite+0x110>
{
    800042e6:	715d                	addi	sp,sp,-80
    800042e8:	e486                	sd	ra,72(sp)
    800042ea:	e0a2                	sd	s0,64(sp)
    800042ec:	f84a                	sd	s2,48(sp)
    800042ee:	f052                	sd	s4,32(sp)
    800042f0:	e85a                	sd	s6,16(sp)
    800042f2:	0880                	addi	s0,sp,80
    800042f4:	892a                	mv	s2,a0
    800042f6:	8b2e                	mv	s6,a1
    800042f8:	8a32                	mv	s4,a2
  if (f->writable == 0 || n < 0)
    800042fa:	0e064c63          	bltz	a2,800043f2 <filewrite+0x114>
    return -1;

  if (f->type == FD_PIPE) {
    800042fe:	411c                	lw	a5,0(a0)
    80004300:	4705                	li	a4,1
    80004302:	02e78763          	beq	a5,a4,80004330 <filewrite+0x52>
    ret = pipewrite(f->pipe, addr, n);
  } else if (f->type == FD_DEVICE) {
    80004306:	470d                	li	a4,3
    80004308:	02e78863          	beq	a5,a4,80004338 <filewrite+0x5a>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if (f->type == FD_INODE) {
    8000430c:	4709                	li	a4,2
    8000430e:	0ce79563          	bne	a5,a4,800043d8 <filewrite+0xfa>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS - 1 - 1 - 2) / 2) * BSIZE;
    int i = 0;
    while (i < n) {
    80004312:	0ec05663          	blez	a2,800043fe <filewrite+0x120>
    80004316:	fc26                	sd	s1,56(sp)
    80004318:	f44e                	sd	s3,40(sp)
    8000431a:	ec56                	sd	s5,24(sp)
    8000431c:	e45e                	sd	s7,8(sp)
    8000431e:	e062                	sd	s8,0(sp)
    int i = 0;
    80004320:	4981                	li	s3,0
      int n1 = n - i;
      if (n1 > max)
    80004322:	6b85                	lui	s7,0x1
    80004324:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004328:	6c05                	lui	s8,0x1
    8000432a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000432e:	a8b5                	j	800043aa <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004330:	6908                	ld	a0,16(a0)
    80004332:	1fe000ef          	jal	80004530 <pipewrite>
    80004336:	a851                	j	800043ca <filewrite+0xec>
    if (f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004338:	02451783          	lh	a5,36(a0)
    8000433c:	03079693          	slli	a3,a5,0x30
    80004340:	92c1                	srli	a3,a3,0x30
    80004342:	4725                	li	a4,9
    80004344:	0ad76963          	bltu	a4,a3,800043f6 <filewrite+0x118>
    80004348:	0792                	slli	a5,a5,0x4
    8000434a:	0001d717          	auipc	a4,0x1d
    8000434e:	68e70713          	addi	a4,a4,1678 # 800219d8 <devsw>
    80004352:	97ba                	add	a5,a5,a4
    80004354:	679c                	ld	a5,8(a5)
    80004356:	c3d5                	beqz	a5,800043fa <filewrite+0x11c>
    ret = devsw[f->major].write(1, addr, n);
    80004358:	4505                	li	a0,1
    8000435a:	9782                	jalr	a5
    8000435c:	a0bd                	j	800043ca <filewrite+0xec>
      if (n1 > max)
    8000435e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004362:	8e3ff0ef          	jal	80003c44 <begin_op>
      ilock(f->ip);
    80004366:	01893503          	ld	a0,24(s2)
    8000436a:	e93fe0ef          	jal	800031fc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000436e:	8756                	mv	a4,s5
    80004370:	02092683          	lw	a3,32(s2)
    80004374:	01698633          	add	a2,s3,s6
    80004378:	4585                	li	a1,1
    8000437a:	01893503          	ld	a0,24(s2)
    8000437e:	b52ff0ef          	jal	800036d0 <writei>
    80004382:	84aa                	mv	s1,a0
    80004384:	00a05763          	blez	a0,80004392 <filewrite+0xb4>
        f->off += r;
    80004388:	02092783          	lw	a5,32(s2)
    8000438c:	9fa9                	addw	a5,a5,a0
    8000438e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004392:	01893503          	ld	a0,24(s2)
    80004396:	f15fe0ef          	jal	800032aa <iunlock>
      end_op();
    8000439a:	931ff0ef          	jal	80003cca <end_op>

      if (r != n1) {
    8000439e:	009a9e63          	bne	s5,s1,800043ba <filewrite+0xdc>
        // error from writei
        break;
      }
      i += r;
    800043a2:	013489bb          	addw	s3,s1,s3
    while (i < n) {
    800043a6:	0149da63          	bge	s3,s4,800043ba <filewrite+0xdc>
      int n1 = n - i;
    800043aa:	413a04bb          	subw	s1,s4,s3
      if (n1 > max)
    800043ae:	0004879b          	sext.w	a5,s1
    800043b2:	fafbd6e3          	bge	s7,a5,8000435e <filewrite+0x80>
    800043b6:	84e2                	mv	s1,s8
    800043b8:	b75d                	j	8000435e <filewrite+0x80>
    }
    ret = (i == n ? n : -1);
    800043ba:	053a1463          	bne	s4,s3,80004402 <filewrite+0x124>
    800043be:	8552                	mv	a0,s4
    800043c0:	74e2                	ld	s1,56(sp)
    800043c2:	79a2                	ld	s3,40(sp)
    800043c4:	6ae2                	ld	s5,24(sp)
    800043c6:	6ba2                	ld	s7,8(sp)
    800043c8:	6c02                	ld	s8,0(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800043ca:	60a6                	ld	ra,72(sp)
    800043cc:	6406                	ld	s0,64(sp)
    800043ce:	7942                	ld	s2,48(sp)
    800043d0:	7a02                	ld	s4,32(sp)
    800043d2:	6b42                	ld	s6,16(sp)
    800043d4:	6161                	addi	sp,sp,80
    800043d6:	8082                	ret
    800043d8:	fc26                	sd	s1,56(sp)
    800043da:	f44e                	sd	s3,40(sp)
    800043dc:	ec56                	sd	s5,24(sp)
    800043de:	e45e                	sd	s7,8(sp)
    800043e0:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800043e2:	00003517          	auipc	a0,0x3
    800043e6:	1c650513          	addi	a0,a0,454 # 800075a8 <etext+0x5a8>
    800043ea:	c06fc0ef          	jal	800007f0 <panic>
    return -1;
    800043ee:	557d                	li	a0,-1
}
    800043f0:	8082                	ret
    return -1;
    800043f2:	557d                	li	a0,-1
    800043f4:	bfd9                	j	800043ca <filewrite+0xec>
      return -1;
    800043f6:	557d                	li	a0,-1
    800043f8:	bfc9                	j	800043ca <filewrite+0xec>
    800043fa:	557d                	li	a0,-1
    800043fc:	b7f9                	j	800043ca <filewrite+0xec>
    ret = (i == n ? n : -1);
    800043fe:	8532                	mv	a0,a2
    80004400:	b7e9                	j	800043ca <filewrite+0xec>
    80004402:	557d                	li	a0,-1
    80004404:	74e2                	ld	s1,56(sp)
    80004406:	79a2                	ld	s3,40(sp)
    80004408:	6ae2                	ld	s5,24(sp)
    8000440a:	6ba2                	ld	s7,8(sp)
    8000440c:	6c02                	ld	s8,0(sp)
    8000440e:	bf75                	j	800043ca <filewrite+0xec>

0000000080004410 <pipealloc>:
  int writeopen; // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004410:	7179                	addi	sp,sp,-48
    80004412:	f406                	sd	ra,40(sp)
    80004414:	f022                	sd	s0,32(sp)
    80004416:	ec26                	sd	s1,24(sp)
    80004418:	e052                	sd	s4,0(sp)
    8000441a:	1800                	addi	s0,sp,48
    8000441c:	84aa                	mv	s1,a0
    8000441e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004420:	0005b023          	sd	zero,0(a1)
    80004424:	00053023          	sd	zero,0(a0)
  if ((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004428:	c25ff0ef          	jal	8000404c <filealloc>
    8000442c:	e088                	sd	a0,0(s1)
    8000442e:	c549                	beqz	a0,800044b8 <pipealloc+0xa8>
    80004430:	c1dff0ef          	jal	8000404c <filealloc>
    80004434:	00aa3023          	sd	a0,0(s4)
    80004438:	cd25                	beqz	a0,800044b0 <pipealloc+0xa0>
    8000443a:	e84a                	sd	s2,16(sp)
    goto bad;
  if ((pi = (struct pipe *)kalloc()) == 0)
    8000443c:	e8efc0ef          	jal	80000aca <kalloc>
    80004440:	892a                	mv	s2,a0
    80004442:	c12d                	beqz	a0,800044a4 <pipealloc+0x94>
    80004444:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004446:	4985                	li	s3,1
    80004448:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000444c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004450:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004454:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004458:	00003597          	auipc	a1,0x3
    8000445c:	16058593          	addi	a1,a1,352 # 800075b8 <etext+0x5b8>
    80004460:	ebafc0ef          	jal	80000b1a <initlock>
  (*f0)->type = FD_PIPE;
    80004464:	609c                	ld	a5,0(s1)
    80004466:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000446a:	609c                	ld	a5,0(s1)
    8000446c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004470:	609c                	ld	a5,0(s1)
    80004472:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004476:	609c                	ld	a5,0(s1)
    80004478:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000447c:	000a3783          	ld	a5,0(s4)
    80004480:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004484:	000a3783          	ld	a5,0(s4)
    80004488:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000448c:	000a3783          	ld	a5,0(s4)
    80004490:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004494:	000a3783          	ld	a5,0(s4)
    80004498:	0127b823          	sd	s2,16(a5)
  return 0;
    8000449c:	4501                	li	a0,0
    8000449e:	6942                	ld	s2,16(sp)
    800044a0:	69a2                	ld	s3,8(sp)
    800044a2:	a01d                	j	800044c8 <pipealloc+0xb8>

bad:
  if (pi)
    kfree((char *)pi);
  if (*f0)
    800044a4:	6088                	ld	a0,0(s1)
    800044a6:	c119                	beqz	a0,800044ac <pipealloc+0x9c>
    800044a8:	6942                	ld	s2,16(sp)
    800044aa:	a029                	j	800044b4 <pipealloc+0xa4>
    800044ac:	6942                	ld	s2,16(sp)
    800044ae:	a029                	j	800044b8 <pipealloc+0xa8>
    800044b0:	6088                	ld	a0,0(s1)
    800044b2:	c10d                	beqz	a0,800044d4 <pipealloc+0xc4>
    fileclose(*f0);
    800044b4:	c3dff0ef          	jal	800040f0 <fileclose>
  if (*f1)
    800044b8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800044bc:	557d                	li	a0,-1
  if (*f1)
    800044be:	c789                	beqz	a5,800044c8 <pipealloc+0xb8>
    fileclose(*f1);
    800044c0:	853e                	mv	a0,a5
    800044c2:	c2fff0ef          	jal	800040f0 <fileclose>
  return -1;
    800044c6:	557d                	li	a0,-1
}
    800044c8:	70a2                	ld	ra,40(sp)
    800044ca:	7402                	ld	s0,32(sp)
    800044cc:	64e2                	ld	s1,24(sp)
    800044ce:	6a02                	ld	s4,0(sp)
    800044d0:	6145                	addi	sp,sp,48
    800044d2:	8082                	ret
  return -1;
    800044d4:	557d                	li	a0,-1
    800044d6:	bfcd                	j	800044c8 <pipealloc+0xb8>

00000000800044d8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800044d8:	1101                	addi	sp,sp,-32
    800044da:	ec06                	sd	ra,24(sp)
    800044dc:	e822                	sd	s0,16(sp)
    800044de:	e426                	sd	s1,8(sp)
    800044e0:	e04a                	sd	s2,0(sp)
    800044e2:	1000                	addi	s0,sp,32
    800044e4:	84aa                	mv	s1,a0
    800044e6:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044e8:	ea8fc0ef          	jal	80000b90 <acquire>
  if (writable) {
    800044ec:	02090763          	beqz	s2,8000451a <pipeclose+0x42>
    pi->writeopen = 0;
    800044f0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044f4:	21848513          	addi	a0,s1,536
    800044f8:	a2bfd0ef          	jal	80001f22 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if (pi->readopen == 0 && pi->writeopen == 0) {
    800044fc:	2204b783          	ld	a5,544(s1)
    80004500:	e785                	bnez	a5,80004528 <pipeclose+0x50>
    release(&pi->lock);
    80004502:	8526                	mv	a0,s1
    80004504:	f18fc0ef          	jal	80000c1c <release>
    kfree((char *)pi);
    80004508:	8526                	mv	a0,s1
    8000450a:	cdefc0ef          	jal	800009e8 <kfree>
  } else
    release(&pi->lock);
}
    8000450e:	60e2                	ld	ra,24(sp)
    80004510:	6442                	ld	s0,16(sp)
    80004512:	64a2                	ld	s1,8(sp)
    80004514:	6902                	ld	s2,0(sp)
    80004516:	6105                	addi	sp,sp,32
    80004518:	8082                	ret
    pi->readopen = 0;
    8000451a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000451e:	21c48513          	addi	a0,s1,540
    80004522:	a01fd0ef          	jal	80001f22 <wakeup>
    80004526:	bfd9                	j	800044fc <pipeclose+0x24>
    release(&pi->lock);
    80004528:	8526                	mv	a0,s1
    8000452a:	ef2fc0ef          	jal	80000c1c <release>
}
    8000452e:	b7c5                	j	8000450e <pipeclose+0x36>

0000000080004530 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004530:	711d                	addi	sp,sp,-96
    80004532:	ec86                	sd	ra,88(sp)
    80004534:	e8a2                	sd	s0,80(sp)
    80004536:	e4a6                	sd	s1,72(sp)
    80004538:	e0ca                	sd	s2,64(sp)
    8000453a:	fc4e                	sd	s3,56(sp)
    8000453c:	f852                	sd	s4,48(sp)
    8000453e:	f456                	sd	s5,40(sp)
    80004540:	1080                	addi	s0,sp,96
    80004542:	84aa                	mv	s1,a0
    80004544:	8aae                	mv	s5,a1
    80004546:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004548:	b5afd0ef          	jal	800018a2 <myproc>
    8000454c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000454e:	8526                	mv	a0,s1
    80004550:	e40fc0ef          	jal	80000b90 <acquire>
  while (i < n) {
    80004554:	0d405e63          	blez	s4,80004630 <pipewrite+0x100>
    80004558:	f05a                	sd	s6,32(sp)
    8000455a:	ec5e                	sd	s7,24(sp)
    8000455c:	e862                	sd	s8,16(sp)
  int i = 0;
    8000455e:	4901                	li	s2,0
      release(&pi->lock);
      sleep();
      acquire(&pi->lock);
    } else {
      char ch;
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    80004560:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004562:	21848c13          	addi	s8,s1,536
      sleep_prepare(&pi->nwrite);
    80004566:	21c48b93          	addi	s7,s1,540
    8000456a:	a091                	j	800045ae <pipewrite+0x7e>
      release(&pi->lock);
    8000456c:	8526                	mv	a0,s1
    8000456e:	eaefc0ef          	jal	80000c1c <release>
      return -1;
    80004572:	597d                	li	s2,-1
    80004574:	7b02                	ld	s6,32(sp)
    80004576:	6be2                	ld	s7,24(sp)
    80004578:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    8000457a:	854a                	mv	a0,s2
    8000457c:	60e6                	ld	ra,88(sp)
    8000457e:	6446                	ld	s0,80(sp)
    80004580:	64a6                	ld	s1,72(sp)
    80004582:	6906                	ld	s2,64(sp)
    80004584:	79e2                	ld	s3,56(sp)
    80004586:	7a42                	ld	s4,48(sp)
    80004588:	7aa2                	ld	s5,40(sp)
    8000458a:	6125                	addi	sp,sp,96
    8000458c:	8082                	ret
      wakeup(&pi->nread);
    8000458e:	8562                	mv	a0,s8
    80004590:	993fd0ef          	jal	80001f22 <wakeup>
      sleep_prepare(&pi->nwrite);
    80004594:	855e                	mv	a0,s7
    80004596:	921fd0ef          	jal	80001eb6 <sleep_prepare>
      release(&pi->lock);
    8000459a:	8526                	mv	a0,s1
    8000459c:	e80fc0ef          	jal	80000c1c <release>
      sleep();
    800045a0:	953fd0ef          	jal	80001ef2 <sleep>
      acquire(&pi->lock);
    800045a4:	8526                	mv	a0,s1
    800045a6:	deafc0ef          	jal	80000b90 <acquire>
  while (i < n) {
    800045aa:	07495863          	bge	s2,s4,8000461a <pipewrite+0xea>
    if (pi->readopen == 0 || killed(pr)) {
    800045ae:	2204a783          	lw	a5,544(s1)
    800045b2:	dfcd                	beqz	a5,8000456c <pipewrite+0x3c>
    800045b4:	854e                	mv	a0,s3
    800045b6:	b55fd0ef          	jal	8000210a <killed>
    800045ba:	f94d                	bnez	a0,8000456c <pipewrite+0x3c>
    if (pi->nwrite == pi->nread + PIPESIZE) { //DOC: pipewrite-full
    800045bc:	2184a783          	lw	a5,536(s1)
    800045c0:	21c4a703          	lw	a4,540(s1)
    800045c4:	2007879b          	addiw	a5,a5,512
    800045c8:	fcf703e3          	beq	a4,a5,8000458e <pipewrite+0x5e>
      if (copyin(pr->pagetable, pr->sz, &ch, addr + i, 1) == -1) {
    800045cc:	4705                	li	a4,1
    800045ce:	015906b3          	add	a3,s2,s5
    800045d2:	faf40613          	addi	a2,s0,-81
    800045d6:	0489b583          	ld	a1,72(s3)
    800045da:	0509b503          	ld	a0,80(s3)
    800045de:	fe7fc0ef          	jal	800015c4 <copyin>
    800045e2:	03650163          	beq	a0,s6,80004604 <pipewrite+0xd4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045e6:	21c4a783          	lw	a5,540(s1)
    800045ea:	0017871b          	addiw	a4,a5,1
    800045ee:	20e4ae23          	sw	a4,540(s1)
    800045f2:	1ff7f793          	andi	a5,a5,511
    800045f6:	97a6                	add	a5,a5,s1
    800045f8:	faf44703          	lbu	a4,-81(s0)
    800045fc:	00e78c23          	sb	a4,24(a5)
      i++;
    80004600:	2905                	addiw	s2,s2,1
    80004602:	b765                	j	800045aa <pipewrite+0x7a>
        if (i == 0)
    80004604:	00090663          	beqz	s2,80004610 <pipewrite+0xe0>
    80004608:	7b02                	ld	s6,32(sp)
    8000460a:	6be2                	ld	s7,24(sp)
    8000460c:	6c42                	ld	s8,16(sp)
    8000460e:	a809                	j	80004620 <pipewrite+0xf0>
          i = -1;
    80004610:	892a                	mv	s2,a0
        break;
    80004612:	7b02                	ld	s6,32(sp)
    80004614:	6be2                	ld	s7,24(sp)
    80004616:	6c42                	ld	s8,16(sp)
    80004618:	a021                	j	80004620 <pipewrite+0xf0>
    8000461a:	7b02                	ld	s6,32(sp)
    8000461c:	6be2                	ld	s7,24(sp)
    8000461e:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004620:	21848513          	addi	a0,s1,536
    80004624:	8fffd0ef          	jal	80001f22 <wakeup>
  release(&pi->lock);
    80004628:	8526                	mv	a0,s1
    8000462a:	df2fc0ef          	jal	80000c1c <release>
  return i;
    8000462e:	b7b1                	j	8000457a <pipewrite+0x4a>
  int i = 0;
    80004630:	4901                	li	s2,0
    80004632:	b7fd                	j	80004620 <pipewrite+0xf0>

0000000080004634 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004634:	715d                	addi	sp,sp,-80
    80004636:	e486                	sd	ra,72(sp)
    80004638:	e0a2                	sd	s0,64(sp)
    8000463a:	fc26                	sd	s1,56(sp)
    8000463c:	f84a                	sd	s2,48(sp)
    8000463e:	f44e                	sd	s3,40(sp)
    80004640:	f052                	sd	s4,32(sp)
    80004642:	ec56                	sd	s5,24(sp)
    80004644:	0880                	addi	s0,sp,80
    80004646:	84aa                	mv	s1,a0
    80004648:	89ae                	mv	s3,a1
    8000464a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000464c:	a56fd0ef          	jal	800018a2 <myproc>
    80004650:	892a                	mv	s2,a0
  char ch;

  acquire(&pi->lock);
    80004652:	8526                	mv	a0,s1
    80004654:	d3cfc0ef          	jal	80000b90 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004658:	2184a703          	lw	a4,536(s1)
    8000465c:	21c4a783          	lw	a5,540(s1)
    if (killed(pr)) {
      release(&pi->lock);
      return -1;
    }
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004660:	21848a13          	addi	s4,s1,536
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    80004664:	02f71c63          	bne	a4,a5,8000469c <piperead+0x68>
    80004668:	2244a783          	lw	a5,548(s1)
    8000466c:	cf9d                	beqz	a5,800046aa <piperead+0x76>
    if (killed(pr)) {
    8000466e:	854a                	mv	a0,s2
    80004670:	a9bfd0ef          	jal	8000210a <killed>
    80004674:	e515                	bnez	a0,800046a0 <piperead+0x6c>
    sleep_prepare(&pi->nread); //DOC: piperead-sleep
    80004676:	8552                	mv	a0,s4
    80004678:	83ffd0ef          	jal	80001eb6 <sleep_prepare>
    release(&pi->lock);
    8000467c:	8526                	mv	a0,s1
    8000467e:	d9efc0ef          	jal	80000c1c <release>
    sleep();
    80004682:	871fd0ef          	jal	80001ef2 <sleep>
    acquire(&pi->lock);
    80004686:	8526                	mv	a0,s1
    80004688:	d08fc0ef          	jal	80000b90 <acquire>
  while (pi->nread == pi->nwrite && pi->writeopen) { //DOC: pipe-empty
    8000468c:	2184a703          	lw	a4,536(s1)
    80004690:	21c4a783          	lw	a5,540(s1)
    80004694:	fcf70ae3          	beq	a4,a5,80004668 <piperead+0x34>
    80004698:	e85a                	sd	s6,16(sp)
    8000469a:	a809                	j	800046ac <piperead+0x78>
    8000469c:	e85a                	sd	s6,16(sp)
    8000469e:	a039                	j	800046ac <piperead+0x78>
      release(&pi->lock);
    800046a0:	8526                	mv	a0,s1
    800046a2:	d7afc0ef          	jal	80000c1c <release>
      return -1;
    800046a6:	5a7d                	li	s4,-1
    800046a8:	a08d                	j	8000470a <piperead+0xd6>
    800046aa:	e85a                	sd	s6,16(sp)
  }
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800046ac:	4a01                	li	s4,0
    if (pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800046ae:	5b7d                	li	s6,-1
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800046b0:	05505563          	blez	s5,800046fa <piperead+0xc6>
    if (pi->nread == pi->nwrite)
    800046b4:	2184a783          	lw	a5,536(s1)
    800046b8:	21c4a703          	lw	a4,540(s1)
    800046bc:	02f70f63          	beq	a4,a5,800046fa <piperead+0xc6>
    ch = pi->data[pi->nread % PIPESIZE];
    800046c0:	1ff7f793          	andi	a5,a5,511
    800046c4:	97a6                	add	a5,a5,s1
    800046c6:	0187c783          	lbu	a5,24(a5)
    800046ca:	faf40fa3          	sb	a5,-65(s0)
    if (copyout(pr->pagetable, pr->sz, addr + i, &ch, 1) == -1) {
    800046ce:	4705                	li	a4,1
    800046d0:	fbf40693          	addi	a3,s0,-65
    800046d4:	864e                	mv	a2,s3
    800046d6:	04893583          	ld	a1,72(s2)
    800046da:	05093503          	ld	a0,80(s2)
    800046de:	dfbfc0ef          	jal	800014d8 <copyout>
    800046e2:	03650e63          	beq	a0,s6,8000471e <piperead+0xea>
      if (i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800046e6:	2184a783          	lw	a5,536(s1)
    800046ea:	2785                	addiw	a5,a5,1
    800046ec:	20f4ac23          	sw	a5,536(s1)
  for (i = 0; i < n; i++) { //DOC: piperead-copy
    800046f0:	2a05                	addiw	s4,s4,1
    800046f2:	0985                	addi	s3,s3,1
    800046f4:	fd4a90e3          	bne	s5,s4,800046b4 <piperead+0x80>
    800046f8:	8a56                	mv	s4,s5
  }
  wakeup(&pi->nwrite); //DOC: piperead-wakeup
    800046fa:	21c48513          	addi	a0,s1,540
    800046fe:	825fd0ef          	jal	80001f22 <wakeup>
  release(&pi->lock);
    80004702:	8526                	mv	a0,s1
    80004704:	d18fc0ef          	jal	80000c1c <release>
    80004708:	6b42                	ld	s6,16(sp)
  return i;
}
    8000470a:	8552                	mv	a0,s4
    8000470c:	60a6                	ld	ra,72(sp)
    8000470e:	6406                	ld	s0,64(sp)
    80004710:	74e2                	ld	s1,56(sp)
    80004712:	7942                	ld	s2,48(sp)
    80004714:	79a2                	ld	s3,40(sp)
    80004716:	7a02                	ld	s4,32(sp)
    80004718:	6ae2                	ld	s5,24(sp)
    8000471a:	6161                	addi	sp,sp,80
    8000471c:	8082                	ret
      if (i == 0)
    8000471e:	fc0a1ee3          	bnez	s4,800046fa <piperead+0xc6>
        i = -1;
    80004722:	8a2a                	mv	s4,a0
    80004724:	bfd9                	j	800046fa <piperead+0xc6>

0000000080004726 <flags2perm>:
static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int
flags2perm(int flags)
{
    80004726:	1141                	addi	sp,sp,-16
    80004728:	e422                	sd	s0,8(sp)
    8000472a:	0800                	addi	s0,sp,16
    8000472c:	87aa                	mv	a5,a0
  int perm = 0;
  if (flags & 0x1)
    8000472e:	8905                	andi	a0,a0,1
    80004730:	050e                	slli	a0,a0,0x3
    perm = PTE_X;
  if (flags & 0x2)
    80004732:	8b89                	andi	a5,a5,2
    80004734:	c399                	beqz	a5,8000473a <flags2perm+0x14>
    perm |= PTE_W;
    80004736:	00456513          	ori	a0,a0,4
  return perm;
}
    8000473a:	6422                	ld	s0,8(sp)
    8000473c:	0141                	addi	sp,sp,16
    8000473e:	8082                	ret

0000000080004740 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004740:	df010113          	addi	sp,sp,-528
    80004744:	20113423          	sd	ra,520(sp)
    80004748:	20813023          	sd	s0,512(sp)
    8000474c:	ffa6                	sd	s1,504(sp)
    8000474e:	fbca                	sd	s2,496(sp)
    80004750:	0c00                	addi	s0,sp,528
    80004752:	892a                	mv	s2,a0
    80004754:	dea43c23          	sd	a0,-520(s0)
    80004758:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000475c:	946fd0ef          	jal	800018a2 <myproc>
    80004760:	84aa                	mv	s1,a0

  begin_op();
    80004762:	ce2ff0ef          	jal	80003c44 <begin_op>

  // Open the executable file.
  if ((ip = namei(path)) == 0) {
    80004766:	854a                	mv	a0,s2
    80004768:	b08ff0ef          	jal	80003a70 <namei>
    8000476c:	c931                	beqz	a0,800047c0 <kexec+0x80>
    8000476e:	f3d2                	sd	s4,480(sp)
    80004770:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004772:	a8bfe0ef          	jal	800031fc <ilock>

  // Read the ELF header.
  if (readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004776:	04000713          	li	a4,64
    8000477a:	4681                	li	a3,0
    8000477c:	e5040613          	addi	a2,s0,-432
    80004780:	4581                	li	a1,0
    80004782:	8552                	mv	a0,s4
    80004784:	e51fe0ef          	jal	800035d4 <readi>
    80004788:	04000793          	li	a5,64
    8000478c:	00f51a63          	bne	a0,a5,800047a0 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if (elf.magic != ELF_MAGIC)
    80004790:	e5042703          	lw	a4,-432(s0)
    80004794:	464c47b7          	lui	a5,0x464c4
    80004798:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000479c:	02f70663          	beq	a4,a5,800047c8 <kexec+0x88>

bad:
  if (pagetable)
    proc_freepagetable(pagetable, sz);
  if (ip) {
    iunlockput(ip);
    800047a0:	8552                	mv	a0,s4
    800047a2:	cadfe0ef          	jal	8000344e <iunlockput>
    end_op();
    800047a6:	d24ff0ef          	jal	80003cca <end_op>
  }
  return -1;
    800047aa:	557d                	li	a0,-1
    800047ac:	7a1e                	ld	s4,480(sp)
}
    800047ae:	20813083          	ld	ra,520(sp)
    800047b2:	20013403          	ld	s0,512(sp)
    800047b6:	74fe                	ld	s1,504(sp)
    800047b8:	795e                	ld	s2,496(sp)
    800047ba:	21010113          	addi	sp,sp,528
    800047be:	8082                	ret
    end_op();
    800047c0:	d0aff0ef          	jal	80003cca <end_op>
    return -1;
    800047c4:	557d                	li	a0,-1
    800047c6:	b7e5                	j	800047ae <kexec+0x6e>
    800047c8:	ebda                	sd	s6,464(sp)
  if ((pagetable = proc_pagetable(p)) == 0)
    800047ca:	8526                	mv	a0,s1
    800047cc:	9e8fd0ef          	jal	800019b4 <proc_pagetable>
    800047d0:	8b2a                	mv	s6,a0
    800047d2:	2c050963          	beqz	a0,80004aa4 <kexec+0x364>
    800047d6:	f7ce                	sd	s3,488(sp)
    800047d8:	efd6                	sd	s5,472(sp)
    800047da:	e7de                	sd	s7,456(sp)
    800047dc:	e3e2                	sd	s8,448(sp)
    800047de:	ff66                	sd	s9,440(sp)
    800047e0:	fb6a                	sd	s10,432(sp)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800047e2:	e7042d03          	lw	s10,-400(s0)
    800047e6:	e8845783          	lhu	a5,-376(s0)
    800047ea:	12078863          	beqz	a5,8000491a <kexec+0x1da>
    800047ee:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047f0:	4901                	li	s2,0
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    800047f2:	4d81                	li	s11,0
    if (ph.vaddr % PGSIZE != 0)
    800047f4:	6c85                	lui	s9,0x1
    800047f6:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047fa:	def43823          	sd	a5,-528(s0)

  for (i = 0; i < sz; i += PGSIZE) {
    pa = walkaddr(pagetable, va + i);
    if (pa == 0)
      panic("loadseg: address should exist");
    if (sz - i < PGSIZE)
    800047fe:	6a85                	lui	s5,0x1
    80004800:	a085                	j	80004860 <kexec+0x120>
      panic("loadseg: address should exist");
    80004802:	00003517          	auipc	a0,0x3
    80004806:	dbe50513          	addi	a0,a0,-578 # 800075c0 <etext+0x5c0>
    8000480a:	fe7fb0ef          	jal	800007f0 <panic>
    if (sz - i < PGSIZE)
    8000480e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if (readi(ip, 0, (uint64)pa, offset + i, n) != n)
    80004810:	8726                	mv	a4,s1
    80004812:	012c06bb          	addw	a3,s8,s2
    80004816:	4581                	li	a1,0
    80004818:	8552                	mv	a0,s4
    8000481a:	dbbfe0ef          	jal	800035d4 <readi>
    8000481e:	2501                	sext.w	a0,a0
    80004820:	24a49863          	bne	s1,a0,80004a70 <kexec+0x330>
  for (i = 0; i < sz; i += PGSIZE) {
    80004824:	012a893b          	addw	s2,s5,s2
    80004828:	03397363          	bgeu	s2,s3,8000484e <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000482c:	02091593          	slli	a1,s2,0x20
    80004830:	9181                	srli	a1,a1,0x20
    80004832:	95de                	add	a1,a1,s7
    80004834:	855a                	mv	a0,s6
    80004836:	f2efc0ef          	jal	80000f64 <walkaddr>
    8000483a:	862a                	mv	a2,a0
    if (pa == 0)
    8000483c:	d179                	beqz	a0,80004802 <kexec+0xc2>
    if (sz - i < PGSIZE)
    8000483e:	412984bb          	subw	s1,s3,s2
    80004842:	0004879b          	sext.w	a5,s1
    80004846:	fcfcf4e3          	bgeu	s9,a5,8000480e <kexec+0xce>
    8000484a:	84d6                	mv	s1,s5
    8000484c:	b7c9                	j	8000480e <kexec+0xce>
    sz = sz1;
    8000484e:	e0843903          	ld	s2,-504(s0)
  for (i = 0, off = elf.phoff; i < elf.phnum; i++, off += sizeof(ph)) {
    80004852:	2d85                	addiw	s11,s11,1
    80004854:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004858:	e8845783          	lhu	a5,-376(s0)
    8000485c:	08fdd063          	bge	s11,a5,800048dc <kexec+0x19c>
    if (readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004860:	2d01                	sext.w	s10,s10
    80004862:	03800713          	li	a4,56
    80004866:	86ea                	mv	a3,s10
    80004868:	e1840613          	addi	a2,s0,-488
    8000486c:	4581                	li	a1,0
    8000486e:	8552                	mv	a0,s4
    80004870:	d65fe0ef          	jal	800035d4 <readi>
    80004874:	03800793          	li	a5,56
    80004878:	1cf51463          	bne	a0,a5,80004a40 <kexec+0x300>
    if (ph.type != ELF_PROG_LOAD)
    8000487c:	e1842783          	lw	a5,-488(s0)
    80004880:	4705                	li	a4,1
    80004882:	fce798e3          	bne	a5,a4,80004852 <kexec+0x112>
    if (ph.memsz < ph.filesz)
    80004886:	e4043483          	ld	s1,-448(s0)
    8000488a:	e3843783          	ld	a5,-456(s0)
    8000488e:	1af4ed63          	bltu	s1,a5,80004a48 <kexec+0x308>
    if (ph.vaddr + ph.memsz < ph.vaddr)
    80004892:	e2843783          	ld	a5,-472(s0)
    80004896:	94be                	add	s1,s1,a5
    80004898:	1af4ec63          	bltu	s1,a5,80004a50 <kexec+0x310>
    if (ph.vaddr % PGSIZE != 0)
    8000489c:	df043703          	ld	a4,-528(s0)
    800048a0:	8ff9                	and	a5,a5,a4
    800048a2:	1a079b63          	bnez	a5,80004a58 <kexec+0x318>
    if ((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz,
    800048a6:	e1c42503          	lw	a0,-484(s0)
    800048aa:	e7dff0ef          	jal	80004726 <flags2perm>
    800048ae:	86aa                	mv	a3,a0
    800048b0:	8626                	mv	a2,s1
    800048b2:	85ca                	mv	a1,s2
    800048b4:	855a                	mv	a0,s6
    800048b6:	987fc0ef          	jal	8000123c <uvmalloc>
    800048ba:	e0a43423          	sd	a0,-504(s0)
    800048be:	1a050163          	beqz	a0,80004a60 <kexec+0x320>
    if (loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800048c2:	e2843b83          	ld	s7,-472(s0)
    800048c6:	e2042c03          	lw	s8,-480(s0)
    800048ca:	e3842983          	lw	s3,-456(s0)
  for (i = 0; i < sz; i += PGSIZE) {
    800048ce:	00098463          	beqz	s3,800048d6 <kexec+0x196>
    800048d2:	4901                	li	s2,0
    800048d4:	bfa1                	j	8000482c <kexec+0xec>
    sz = sz1;
    800048d6:	e0843903          	ld	s2,-504(s0)
    800048da:	bfa5                	j	80004852 <kexec+0x112>
    800048dc:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800048de:	8552                	mv	a0,s4
    800048e0:	b6ffe0ef          	jal	8000344e <iunlockput>
  end_op();
    800048e4:	be6ff0ef          	jal	80003cca <end_op>
  p = myproc();
    800048e8:	fbbfc0ef          	jal	800018a2 <myproc>
    800048ec:	89aa                	mv	s3,a0
  uint64 oldsz = p->sz;
    800048ee:	04853a03          	ld	s4,72(a0)
  sz = PGROUNDUP(sz);
    800048f2:	6b85                	lui	s7,0x1
    800048f4:	1bfd                	addi	s7,s7,-1 # fff <_entry-0x7ffff001>
    800048f6:	9bca                	add	s7,s7,s2
    800048f8:	77fd                	lui	a5,0xfffff
    800048fa:	00fbfbb3          	and	s7,s7,a5
  if ((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK + 1) * PGSIZE, PTE_W)) ==
    800048fe:	4691                	li	a3,4
    80004900:	6609                	lui	a2,0x2
    80004902:	965e                	add	a2,a2,s7
    80004904:	85de                	mv	a1,s7
    80004906:	855a                	mv	a0,s6
    80004908:	935fc0ef          	jal	8000123c <uvmalloc>
    8000490c:	e0a43423          	sd	a0,-504(s0)
    80004910:	e519                	bnez	a0,8000491e <kexec+0x1de>
  if (pagetable)
    80004912:	e1743423          	sd	s7,-504(s0)
    80004916:	4a01                	li	s4,0
    80004918:	aaa9                	j	80004a72 <kexec+0x332>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000491a:	4901                	li	s2,0
    8000491c:	b7c9                	j	800048de <kexec+0x19e>
  uvmclear(pagetable, sz - (USERSTACK + 1) * PGSIZE);
    8000491e:	75f9                	lui	a1,0xffffe
    80004920:	8baa                	mv	s7,a0
    80004922:	95aa                	add	a1,a1,a0
    80004924:	855a                	mv	a0,s6
    80004926:	aedfc0ef          	jal	80001412 <uvmclear>
  stackbase = sp - USERSTACK * PGSIZE;
    8000492a:	7afd                	lui	s5,0xfffff
    8000492c:	9ade                	add	s5,s5,s7
  for (argc = 0; argv[argc]; argc++) {
    8000492e:	e0043783          	ld	a5,-512(s0)
    80004932:	6388                	ld	a0,0(a5)
    80004934:	c15d                	beqz	a0,800049da <kexec+0x29a>
    80004936:	e9040913          	addi	s2,s0,-368
    8000493a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000493c:	c88fc0ef          	jal	80000dc4 <strlen>
    80004940:	0015079b          	addiw	a5,a0,1
    80004944:	40fb87b3          	sub	a5,s7,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004948:	ff07fb93          	andi	s7,a5,-16
    if (sp < stackbase)
    8000494c:	115bee63          	bltu	s7,s5,80004a68 <kexec+0x328>
    if (copyout(pagetable, sz, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004950:	e0043c83          	ld	s9,-512(s0)
    80004954:	000cbc03          	ld	s8,0(s9)
    80004958:	8562                	mv	a0,s8
    8000495a:	c6afc0ef          	jal	80000dc4 <strlen>
    8000495e:	0015071b          	addiw	a4,a0,1
    80004962:	86e2                	mv	a3,s8
    80004964:	865e                	mv	a2,s7
    80004966:	e0843583          	ld	a1,-504(s0)
    8000496a:	855a                	mv	a0,s6
    8000496c:	b6dfc0ef          	jal	800014d8 <copyout>
    80004970:	0e054e63          	bltz	a0,80004a6c <kexec+0x32c>
    ustack[argc] = sp;
    80004974:	01793023          	sd	s7,0(s2)
  for (argc = 0; argv[argc]; argc++) {
    80004978:	0485                	addi	s1,s1,1
    8000497a:	008c8793          	addi	a5,s9,8
    8000497e:	e0f43023          	sd	a5,-512(s0)
    80004982:	008cb503          	ld	a0,8(s9)
    80004986:	0921                	addi	s2,s2,8
    80004988:	f955                	bnez	a0,8000493c <kexec+0x1fc>
  ustack[argc] = 0;
    8000498a:	00349793          	slli	a5,s1,0x3
    8000498e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdc420>
    80004992:	97a2                	add	a5,a5,s0
    80004994:	f007b023          	sd	zero,-256(a5)
  sp -= (argc + 1) * sizeof(uint64);
    80004998:	00148713          	addi	a4,s1,1
    8000499c:	070e                	slli	a4,a4,0x3
    8000499e:	40eb8933          	sub	s2,s7,a4
  sp -= sp % 16;
    800049a2:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800049a6:	e0843583          	ld	a1,-504(s0)
    800049aa:	8bae                	mv	s7,a1
  if (sp < stackbase)
    800049ac:	f75963e3          	bltu	s2,s5,80004912 <kexec+0x1d2>
  if (copyout(pagetable, sz, sp, (char *)ustack, (argc + 1) * sizeof(uint64)) <
    800049b0:	e9040693          	addi	a3,s0,-368
    800049b4:	864a                	mv	a2,s2
    800049b6:	855a                	mv	a0,s6
    800049b8:	b21fc0ef          	jal	800014d8 <copyout>
    800049bc:	0e054663          	bltz	a0,80004aa8 <kexec+0x368>
  p->trapframe->a1 = sp;
    800049c0:	0589b783          	ld	a5,88(s3)
    800049c4:	0727bc23          	sd	s2,120(a5)
  for (last = s = path; *s; s++)
    800049c8:	df843783          	ld	a5,-520(s0)
    800049cc:	0007c703          	lbu	a4,0(a5)
    800049d0:	c315                	beqz	a4,800049f4 <kexec+0x2b4>
    800049d2:	0785                	addi	a5,a5,1
    if (*s == '/')
    800049d4:	02f00693          	li	a3,47
    800049d8:	a809                	j	800049ea <kexec+0x2aa>
  sp = sz;
    800049da:	e0843b83          	ld	s7,-504(s0)
  for (argc = 0; argv[argc]; argc++) {
    800049de:	4481                	li	s1,0
    800049e0:	b76d                	j	8000498a <kexec+0x24a>
  for (last = s = path; *s; s++)
    800049e2:	0785                	addi	a5,a5,1
    800049e4:	fff7c703          	lbu	a4,-1(a5)
    800049e8:	c711                	beqz	a4,800049f4 <kexec+0x2b4>
    if (*s == '/')
    800049ea:	fed71ce3          	bne	a4,a3,800049e2 <kexec+0x2a2>
      last = s + 1;
    800049ee:	def43c23          	sd	a5,-520(s0)
    800049f2:	bfc5                	j	800049e2 <kexec+0x2a2>
  safestrcpy(p->name, last, sizeof(p->name));
    800049f4:	4641                	li	a2,16
    800049f6:	df843583          	ld	a1,-520(s0)
    800049fa:	15898513          	addi	a0,s3,344
    800049fe:	b94fc0ef          	jal	80000d92 <safestrcpy>
  oldpagetable = p->pagetable;
    80004a02:	0509b503          	ld	a0,80(s3)
  p->pagetable = pagetable;
    80004a06:	0569b823          	sd	s6,80(s3)
  p->sz = sz;
    80004a0a:	e0843783          	ld	a5,-504(s0)
    80004a0e:	04f9b423          	sd	a5,72(s3)
  p->trapframe->epc = elf.entry; // initial program counter = ulib.c:start()
    80004a12:	0589b783          	ld	a5,88(s3)
    80004a16:	e6843703          	ld	a4,-408(s0)
    80004a1a:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp;         // initial stack pointer
    80004a1c:	0589b783          	ld	a5,88(s3)
    80004a20:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a24:	85d2                	mv	a1,s4
    80004a26:	812fd0ef          	jal	80001a38 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a2a:	0004851b          	sext.w	a0,s1
    80004a2e:	79be                	ld	s3,488(sp)
    80004a30:	7a1e                	ld	s4,480(sp)
    80004a32:	6afe                	ld	s5,472(sp)
    80004a34:	6b5e                	ld	s6,464(sp)
    80004a36:	6bbe                	ld	s7,456(sp)
    80004a38:	6c1e                	ld	s8,448(sp)
    80004a3a:	7cfa                	ld	s9,440(sp)
    80004a3c:	7d5a                	ld	s10,432(sp)
    80004a3e:	bb85                	j	800047ae <kexec+0x6e>
    80004a40:	e1243423          	sd	s2,-504(s0)
    80004a44:	7dba                	ld	s11,424(sp)
    80004a46:	a035                	j	80004a72 <kexec+0x332>
    80004a48:	e1243423          	sd	s2,-504(s0)
    80004a4c:	7dba                	ld	s11,424(sp)
    80004a4e:	a015                	j	80004a72 <kexec+0x332>
    80004a50:	e1243423          	sd	s2,-504(s0)
    80004a54:	7dba                	ld	s11,424(sp)
    80004a56:	a831                	j	80004a72 <kexec+0x332>
    80004a58:	e1243423          	sd	s2,-504(s0)
    80004a5c:	7dba                	ld	s11,424(sp)
    80004a5e:	a811                	j	80004a72 <kexec+0x332>
    80004a60:	e1243423          	sd	s2,-504(s0)
    80004a64:	7dba                	ld	s11,424(sp)
    80004a66:	a031                	j	80004a72 <kexec+0x332>
  ip = 0;
    80004a68:	4a01                	li	s4,0
    80004a6a:	a021                	j	80004a72 <kexec+0x332>
    80004a6c:	4a01                	li	s4,0
  if (pagetable)
    80004a6e:	a011                	j	80004a72 <kexec+0x332>
    80004a70:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004a72:	e0843583          	ld	a1,-504(s0)
    80004a76:	855a                	mv	a0,s6
    80004a78:	fc1fc0ef          	jal	80001a38 <proc_freepagetable>
  return -1;
    80004a7c:	557d                	li	a0,-1
  if (ip) {
    80004a7e:	000a1b63          	bnez	s4,80004a94 <kexec+0x354>
    80004a82:	79be                	ld	s3,488(sp)
    80004a84:	7a1e                	ld	s4,480(sp)
    80004a86:	6afe                	ld	s5,472(sp)
    80004a88:	6b5e                	ld	s6,464(sp)
    80004a8a:	6bbe                	ld	s7,456(sp)
    80004a8c:	6c1e                	ld	s8,448(sp)
    80004a8e:	7cfa                	ld	s9,440(sp)
    80004a90:	7d5a                	ld	s10,432(sp)
    80004a92:	bb31                	j	800047ae <kexec+0x6e>
    80004a94:	79be                	ld	s3,488(sp)
    80004a96:	6afe                	ld	s5,472(sp)
    80004a98:	6b5e                	ld	s6,464(sp)
    80004a9a:	6bbe                	ld	s7,456(sp)
    80004a9c:	6c1e                	ld	s8,448(sp)
    80004a9e:	7cfa                	ld	s9,440(sp)
    80004aa0:	7d5a                	ld	s10,432(sp)
    80004aa2:	b9fd                	j	800047a0 <kexec+0x60>
    80004aa4:	6b5e                	ld	s6,464(sp)
    80004aa6:	b9ed                	j	800047a0 <kexec+0x60>
  sz = sz1;
    80004aa8:	e0843b83          	ld	s7,-504(s0)
    80004aac:	b59d                	j	80004912 <kexec+0x1d2>

0000000080004aae <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004aae:	7179                	addi	sp,sp,-48
    80004ab0:	f406                	sd	ra,40(sp)
    80004ab2:	f022                	sd	s0,32(sp)
    80004ab4:	ec26                	sd	s1,24(sp)
    80004ab6:	e84a                	sd	s2,16(sp)
    80004ab8:	1800                	addi	s0,sp,48
    80004aba:	892e                	mv	s2,a1
    80004abc:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004abe:	fdc40593          	addi	a1,s0,-36
    80004ac2:	d25fd0ef          	jal	800027e6 <argint>
  if (fd < 0 || fd >= NOFILE || (f = myproc()->ofile[fd]) == 0)
    80004ac6:	fdc42703          	lw	a4,-36(s0)
    80004aca:	47bd                	li	a5,15
    80004acc:	02e7e963          	bltu	a5,a4,80004afe <argfd+0x50>
    80004ad0:	dd3fc0ef          	jal	800018a2 <myproc>
    80004ad4:	fdc42703          	lw	a4,-36(s0)
    80004ad8:	01a70793          	addi	a5,a4,26
    80004adc:	078e                	slli	a5,a5,0x3
    80004ade:	953e                	add	a0,a0,a5
    80004ae0:	611c                	ld	a5,0(a0)
    80004ae2:	c385                	beqz	a5,80004b02 <argfd+0x54>
    return -1;
  if (pfd)
    80004ae4:	00090463          	beqz	s2,80004aec <argfd+0x3e>
    *pfd = fd;
    80004ae8:	00e92023          	sw	a4,0(s2)
  if (pf)
    *pf = f;
  return 0;
    80004aec:	4501                	li	a0,0
  if (pf)
    80004aee:	c091                	beqz	s1,80004af2 <argfd+0x44>
    *pf = f;
    80004af0:	e09c                	sd	a5,0(s1)
}
    80004af2:	70a2                	ld	ra,40(sp)
    80004af4:	7402                	ld	s0,32(sp)
    80004af6:	64e2                	ld	s1,24(sp)
    80004af8:	6942                	ld	s2,16(sp)
    80004afa:	6145                	addi	sp,sp,48
    80004afc:	8082                	ret
    return -1;
    80004afe:	557d                	li	a0,-1
    80004b00:	bfcd                	j	80004af2 <argfd+0x44>
    80004b02:	557d                	li	a0,-1
    80004b04:	b7fd                	j	80004af2 <argfd+0x44>

0000000080004b06 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004b06:	1101                	addi	sp,sp,-32
    80004b08:	ec06                	sd	ra,24(sp)
    80004b0a:	e822                	sd	s0,16(sp)
    80004b0c:	e426                	sd	s1,8(sp)
    80004b0e:	1000                	addi	s0,sp,32
    80004b10:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004b12:	d91fc0ef          	jal	800018a2 <myproc>
    80004b16:	862a                	mv	a2,a0

  for (fd = 0; fd < NOFILE; fd++) {
    80004b18:	0d050793          	addi	a5,a0,208
    80004b1c:	4501                	li	a0,0
    80004b1e:	46c1                	li	a3,16
    if (p->ofile[fd] == 0) {
    80004b20:	6398                	ld	a4,0(a5)
    80004b22:	cb19                	beqz	a4,80004b38 <fdalloc+0x32>
  for (fd = 0; fd < NOFILE; fd++) {
    80004b24:	2505                	addiw	a0,a0,1
    80004b26:	07a1                	addi	a5,a5,8
    80004b28:	fed51ce3          	bne	a0,a3,80004b20 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004b2c:	557d                	li	a0,-1
}
    80004b2e:	60e2                	ld	ra,24(sp)
    80004b30:	6442                	ld	s0,16(sp)
    80004b32:	64a2                	ld	s1,8(sp)
    80004b34:	6105                	addi	sp,sp,32
    80004b36:	8082                	ret
      p->ofile[fd] = f;
    80004b38:	01a50793          	addi	a5,a0,26
    80004b3c:	078e                	slli	a5,a5,0x3
    80004b3e:	963e                	add	a2,a2,a5
    80004b40:	e204                	sd	s1,0(a2)
      return fd;
    80004b42:	b7f5                	j	80004b2e <fdalloc+0x28>

0000000080004b44 <create>:
  return -1;
}

static struct inode *
create(char *path, short type, short major, short minor)
{
    80004b44:	715d                	addi	sp,sp,-80
    80004b46:	e486                	sd	ra,72(sp)
    80004b48:	e0a2                	sd	s0,64(sp)
    80004b4a:	fc26                	sd	s1,56(sp)
    80004b4c:	f84a                	sd	s2,48(sp)
    80004b4e:	f44e                	sd	s3,40(sp)
    80004b50:	f052                	sd	s4,32(sp)
    80004b52:	ec56                	sd	s5,24(sp)
    80004b54:	0880                	addi	s0,sp,80
    80004b56:	892e                	mv	s2,a1
    80004b58:	89b2                	mv	s3,a2
    80004b5a:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if ((dp = nameiparent(path, name)) == 0)
    80004b5c:	fb040593          	addi	a1,s0,-80
    80004b60:	f2bfe0ef          	jal	80003a8a <nameiparent>
    80004b64:	8aaa                	mv	s5,a0
    80004b66:	cd45                	beqz	a0,80004c1e <create+0xda>
    return 0;

  ilock(dp);
    80004b68:	e94fe0ef          	jal	800031fc <ilock>

  if (dp->nlink == 0) {
    80004b6c:	04aa9783          	lh	a5,74(s5) # fffffffffffff04a <end+0xffffffff7ffdc4da>
    80004b70:	cf8d                	beqz	a5,80004baa <create+0x66>
    iunlockput(dp);
    return 0;
  }

  // a new directory's ".." would push dp->nlink past its maximum
  if (type == T_DIR && dp->nlink >= NLINK_MAX) {
    80004b72:	4705                	li	a4,1
    80004b74:	04e91563          	bne	s2,a4,80004bbe <create+0x7a>
    80004b78:	6721                	lui	a4,0x8
    80004b7a:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004b7c:	02e78c63          	beq	a5,a4,80004bb4 <create+0x70>
    iunlockput(dp);
    return 0;
  }

  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004b80:	4601                	li	a2,0
    80004b82:	fb040593          	addi	a1,s0,-80
    80004b86:	8556                	mv	a0,s5
    80004b88:	c73fe0ef          	jal	800037fa <dirlookup>
    80004b8c:	84aa                	mv	s1,a0
    80004b8e:	e951                	bnez	a0,80004c22 <create+0xde>
      return ip;
    iunlockput(ip);
    return 0;
  }

  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004b90:	85ca                	mv	a1,s2
    80004b92:	000aa503          	lw	a0,0(s5)
    80004b96:	cf6fe0ef          	jal	8000308c <ialloc>
    80004b9a:	84aa                	mv	s1,a0
    80004b9c:	0c051e63          	bnez	a0,80004c78 <create+0x134>
    iunlockput(dp);
    80004ba0:	8556                	mv	a0,s5
    80004ba2:	8adfe0ef          	jal	8000344e <iunlockput>
    return 0;
    80004ba6:	4481                	li	s1,0
    80004ba8:	a0a1                	j	80004bf0 <create+0xac>
    iunlockput(dp);
    80004baa:	8556                	mv	a0,s5
    80004bac:	8a3fe0ef          	jal	8000344e <iunlockput>
    return 0;
    80004bb0:	4481                	li	s1,0
    80004bb2:	a83d                	j	80004bf0 <create+0xac>
    iunlockput(dp);
    80004bb4:	8556                	mv	a0,s5
    80004bb6:	899fe0ef          	jal	8000344e <iunlockput>
    return 0;
    80004bba:	4481                	li	s1,0
    80004bbc:	a815                	j	80004bf0 <create+0xac>
  if ((ip = dirlookup(dp, name, 0)) != 0) {
    80004bbe:	4601                	li	a2,0
    80004bc0:	fb040593          	addi	a1,s0,-80
    80004bc4:	8556                	mv	a0,s5
    80004bc6:	c35fe0ef          	jal	800037fa <dirlookup>
    80004bca:	84aa                	mv	s1,a0
    80004bcc:	c535                	beqz	a0,80004c38 <create+0xf4>
    iunlockput(dp);
    80004bce:	8556                	mv	a0,s5
    80004bd0:	87ffe0ef          	jal	8000344e <iunlockput>
    ilock(ip);
    80004bd4:	8526                	mv	a0,s1
    80004bd6:	e26fe0ef          	jal	800031fc <ilock>
    if (type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004bda:	4789                	li	a5,2
    80004bdc:	04f91963          	bne	s2,a5,80004c2e <create+0xea>
    80004be0:	0444d783          	lhu	a5,68(s1)
    80004be4:	37f9                	addiw	a5,a5,-2
    80004be6:	17c2                	slli	a5,a5,0x30
    80004be8:	93c1                	srli	a5,a5,0x30
    80004bea:	4705                	li	a4,1
    80004bec:	04f76163          	bltu	a4,a5,80004c2e <create+0xea>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004bf0:	8526                	mv	a0,s1
    80004bf2:	60a6                	ld	ra,72(sp)
    80004bf4:	6406                	ld	s0,64(sp)
    80004bf6:	74e2                	ld	s1,56(sp)
    80004bf8:	7942                	ld	s2,48(sp)
    80004bfa:	79a2                	ld	s3,40(sp)
    80004bfc:	7a02                	ld	s4,32(sp)
    80004bfe:	6ae2                	ld	s5,24(sp)
    80004c00:	6161                	addi	sp,sp,80
    80004c02:	8082                	ret
  ip->nlink = 0;
    80004c04:	04049523          	sh	zero,74(s1)
  iupdate(ip);
    80004c08:	8526                	mv	a0,s1
    80004c0a:	d3efe0ef          	jal	80003148 <iupdate>
  iunlockput(ip);
    80004c0e:	8526                	mv	a0,s1
    80004c10:	83ffe0ef          	jal	8000344e <iunlockput>
  iunlockput(dp);
    80004c14:	8556                	mv	a0,s5
    80004c16:	839fe0ef          	jal	8000344e <iunlockput>
  return 0;
    80004c1a:	4481                	li	s1,0
    80004c1c:	bfd1                	j	80004bf0 <create+0xac>
    return 0;
    80004c1e:	84aa                	mv	s1,a0
    80004c20:	bfc1                	j	80004bf0 <create+0xac>
    iunlockput(dp);
    80004c22:	8556                	mv	a0,s5
    80004c24:	82bfe0ef          	jal	8000344e <iunlockput>
    ilock(ip);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	dd2fe0ef          	jal	800031fc <ilock>
    iunlockput(ip);
    80004c2e:	8526                	mv	a0,s1
    80004c30:	81ffe0ef          	jal	8000344e <iunlockput>
    return 0;
    80004c34:	4481                	li	s1,0
    80004c36:	bf6d                	j	80004bf0 <create+0xac>
  if ((ip = ialloc(dp->dev, type)) == 0) {
    80004c38:	85ca                	mv	a1,s2
    80004c3a:	000aa503          	lw	a0,0(s5)
    80004c3e:	c4efe0ef          	jal	8000308c <ialloc>
    80004c42:	84aa                	mv	s1,a0
    80004c44:	dd31                	beqz	a0,80004ba0 <create+0x5c>
  ilock(ip);
    80004c46:	8526                	mv	a0,s1
    80004c48:	db4fe0ef          	jal	800031fc <ilock>
  ip->major = major;
    80004c4c:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004c50:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004c54:	4785                	li	a5,1
    80004c56:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c5a:	8526                	mv	a0,s1
    80004c5c:	cecfe0ef          	jal	80003148 <iupdate>
  if (dirlink(dp, name, ip->inum) < 0)
    80004c60:	40d0                	lw	a2,4(s1)
    80004c62:	fb040593          	addi	a1,s0,-80
    80004c66:	8556                	mv	a0,s5
    80004c68:	d6ffe0ef          	jal	800039d6 <dirlink>
    80004c6c:	f8054ce3          	bltz	a0,80004c04 <create+0xc0>
  iunlockput(dp);
    80004c70:	8556                	mv	a0,s5
    80004c72:	fdcfe0ef          	jal	8000344e <iunlockput>
  return ip;
    80004c76:	bfad                	j	80004bf0 <create+0xac>
  ilock(ip);
    80004c78:	8526                	mv	a0,s1
    80004c7a:	d82fe0ef          	jal	800031fc <ilock>
  ip->major = major;
    80004c7e:	05349323          	sh	s3,70(s1)
  ip->minor = minor;
    80004c82:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80004c86:	4785                	li	a5,1
    80004c88:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c8c:	8526                	mv	a0,s1
    80004c8e:	cbafe0ef          	jal	80003148 <iupdate>
    if (dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004c92:	40d0                	lw	a2,4(s1)
    80004c94:	00003597          	auipc	a1,0x3
    80004c98:	95458593          	addi	a1,a1,-1708 # 800075e8 <etext+0x5e8>
    80004c9c:	8526                	mv	a0,s1
    80004c9e:	d39fe0ef          	jal	800039d6 <dirlink>
    80004ca2:	f60541e3          	bltz	a0,80004c04 <create+0xc0>
    80004ca6:	004aa603          	lw	a2,4(s5)
    80004caa:	00003597          	auipc	a1,0x3
    80004cae:	93658593          	addi	a1,a1,-1738 # 800075e0 <etext+0x5e0>
    80004cb2:	8526                	mv	a0,s1
    80004cb4:	d23fe0ef          	jal	800039d6 <dirlink>
    80004cb8:	f40546e3          	bltz	a0,80004c04 <create+0xc0>
  if (dirlink(dp, name, ip->inum) < 0)
    80004cbc:	40d0                	lw	a2,4(s1)
    80004cbe:	fb040593          	addi	a1,s0,-80
    80004cc2:	8556                	mv	a0,s5
    80004cc4:	d13fe0ef          	jal	800039d6 <dirlink>
    80004cc8:	f2054ee3          	bltz	a0,80004c04 <create+0xc0>
    dp->nlink++; // for ".."
    80004ccc:	04aad783          	lhu	a5,74(s5)
    80004cd0:	2785                	addiw	a5,a5,1
    80004cd2:	04fa9523          	sh	a5,74(s5)
    iupdate(dp);
    80004cd6:	8556                	mv	a0,s5
    80004cd8:	c70fe0ef          	jal	80003148 <iupdate>
    80004cdc:	bf51                	j	80004c70 <create+0x12c>

0000000080004cde <sys_dup>:
{
    80004cde:	7179                	addi	sp,sp,-48
    80004ce0:	f406                	sd	ra,40(sp)
    80004ce2:	f022                	sd	s0,32(sp)
    80004ce4:	1800                	addi	s0,sp,48
  if (argfd(0, 0, &f) < 0)
    80004ce6:	fd840613          	addi	a2,s0,-40
    80004cea:	4581                	li	a1,0
    80004cec:	4501                	li	a0,0
    80004cee:	dc1ff0ef          	jal	80004aae <argfd>
    return -1;
    80004cf2:	57fd                	li	a5,-1
  if (argfd(0, 0, &f) < 0)
    80004cf4:	02054363          	bltz	a0,80004d1a <sys_dup+0x3c>
    80004cf8:	ec26                	sd	s1,24(sp)
    80004cfa:	e84a                	sd	s2,16(sp)
  if ((fd = fdalloc(f)) < 0)
    80004cfc:	fd843903          	ld	s2,-40(s0)
    80004d00:	854a                	mv	a0,s2
    80004d02:	e05ff0ef          	jal	80004b06 <fdalloc>
    80004d06:	84aa                	mv	s1,a0
    return -1;
    80004d08:	57fd                	li	a5,-1
  if ((fd = fdalloc(f)) < 0)
    80004d0a:	00054d63          	bltz	a0,80004d24 <sys_dup+0x46>
  filedup(f);
    80004d0e:	854a                	mv	a0,s2
    80004d10:	b9aff0ef          	jal	800040aa <filedup>
  return fd;
    80004d14:	87a6                	mv	a5,s1
    80004d16:	64e2                	ld	s1,24(sp)
    80004d18:	6942                	ld	s2,16(sp)
}
    80004d1a:	853e                	mv	a0,a5
    80004d1c:	70a2                	ld	ra,40(sp)
    80004d1e:	7402                	ld	s0,32(sp)
    80004d20:	6145                	addi	sp,sp,48
    80004d22:	8082                	ret
    80004d24:	64e2                	ld	s1,24(sp)
    80004d26:	6942                	ld	s2,16(sp)
    80004d28:	bfcd                	j	80004d1a <sys_dup+0x3c>

0000000080004d2a <sys_read>:
{
    80004d2a:	7179                	addi	sp,sp,-48
    80004d2c:	f406                	sd	ra,40(sp)
    80004d2e:	f022                	sd	s0,32(sp)
    80004d30:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d32:	fd840593          	addi	a1,s0,-40
    80004d36:	4505                	li	a0,1
    80004d38:	acbfd0ef          	jal	80002802 <argaddr>
  argint(2, &n);
    80004d3c:	fe440593          	addi	a1,s0,-28
    80004d40:	4509                	li	a0,2
    80004d42:	aa5fd0ef          	jal	800027e6 <argint>
  if (argfd(0, 0, &f) < 0)
    80004d46:	fe840613          	addi	a2,s0,-24
    80004d4a:	4581                	li	a1,0
    80004d4c:	4501                	li	a0,0
    80004d4e:	d61ff0ef          	jal	80004aae <argfd>
    80004d52:	87aa                	mv	a5,a0
    return -1;
    80004d54:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004d56:	0007ca63          	bltz	a5,80004d6a <sys_read+0x40>
  return fileread(f, p, n);
    80004d5a:	fe442603          	lw	a2,-28(s0)
    80004d5e:	fd843583          	ld	a1,-40(s0)
    80004d62:	fe843503          	ld	a0,-24(s0)
    80004d66:	caeff0ef          	jal	80004214 <fileread>
}
    80004d6a:	70a2                	ld	ra,40(sp)
    80004d6c:	7402                	ld	s0,32(sp)
    80004d6e:	6145                	addi	sp,sp,48
    80004d70:	8082                	ret

0000000080004d72 <sys_write>:
{
    80004d72:	7179                	addi	sp,sp,-48
    80004d74:	f406                	sd	ra,40(sp)
    80004d76:	f022                	sd	s0,32(sp)
    80004d78:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004d7a:	fd840593          	addi	a1,s0,-40
    80004d7e:	4505                	li	a0,1
    80004d80:	a83fd0ef          	jal	80002802 <argaddr>
  argint(2, &n);
    80004d84:	fe440593          	addi	a1,s0,-28
    80004d88:	4509                	li	a0,2
    80004d8a:	a5dfd0ef          	jal	800027e6 <argint>
  if (argfd(0, 0, &f) < 0)
    80004d8e:	fe840613          	addi	a2,s0,-24
    80004d92:	4581                	li	a1,0
    80004d94:	4501                	li	a0,0
    80004d96:	d19ff0ef          	jal	80004aae <argfd>
    80004d9a:	87aa                	mv	a5,a0
    return -1;
    80004d9c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004d9e:	0007ca63          	bltz	a5,80004db2 <sys_write+0x40>
  return filewrite(f, p, n);
    80004da2:	fe442603          	lw	a2,-28(s0)
    80004da6:	fd843583          	ld	a1,-40(s0)
    80004daa:	fe843503          	ld	a0,-24(s0)
    80004dae:	d30ff0ef          	jal	800042de <filewrite>
}
    80004db2:	70a2                	ld	ra,40(sp)
    80004db4:	7402                	ld	s0,32(sp)
    80004db6:	6145                	addi	sp,sp,48
    80004db8:	8082                	ret

0000000080004dba <sys_close>:
{
    80004dba:	1101                	addi	sp,sp,-32
    80004dbc:	ec06                	sd	ra,24(sp)
    80004dbe:	e822                	sd	s0,16(sp)
    80004dc0:	1000                	addi	s0,sp,32
  if (argfd(0, &fd, &f) < 0)
    80004dc2:	fe040613          	addi	a2,s0,-32
    80004dc6:	fec40593          	addi	a1,s0,-20
    80004dca:	4501                	li	a0,0
    80004dcc:	ce3ff0ef          	jal	80004aae <argfd>
    return -1;
    80004dd0:	57fd                	li	a5,-1
  if (argfd(0, &fd, &f) < 0)
    80004dd2:	02054063          	bltz	a0,80004df2 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004dd6:	acdfc0ef          	jal	800018a2 <myproc>
    80004dda:	fec42783          	lw	a5,-20(s0)
    80004dde:	07e9                	addi	a5,a5,26
    80004de0:	078e                	slli	a5,a5,0x3
    80004de2:	953e                	add	a0,a0,a5
    80004de4:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004de8:	fe043503          	ld	a0,-32(s0)
    80004dec:	b04ff0ef          	jal	800040f0 <fileclose>
  return 0;
    80004df0:	4781                	li	a5,0
}
    80004df2:	853e                	mv	a0,a5
    80004df4:	60e2                	ld	ra,24(sp)
    80004df6:	6442                	ld	s0,16(sp)
    80004df8:	6105                	addi	sp,sp,32
    80004dfa:	8082                	ret

0000000080004dfc <sys_fstat>:
{
    80004dfc:	1101                	addi	sp,sp,-32
    80004dfe:	ec06                	sd	ra,24(sp)
    80004e00:	e822                	sd	s0,16(sp)
    80004e02:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004e04:	fe040593          	addi	a1,s0,-32
    80004e08:	4505                	li	a0,1
    80004e0a:	9f9fd0ef          	jal	80002802 <argaddr>
  if (argfd(0, 0, &f) < 0)
    80004e0e:	fe840613          	addi	a2,s0,-24
    80004e12:	4581                	li	a1,0
    80004e14:	4501                	li	a0,0
    80004e16:	c99ff0ef          	jal	80004aae <argfd>
    80004e1a:	87aa                	mv	a5,a0
    return -1;
    80004e1c:	557d                	li	a0,-1
  if (argfd(0, 0, &f) < 0)
    80004e1e:	0007c863          	bltz	a5,80004e2e <sys_fstat+0x32>
  return filestat(f, st);
    80004e22:	fe043583          	ld	a1,-32(s0)
    80004e26:	fe843503          	ld	a0,-24(s0)
    80004e2a:	b88ff0ef          	jal	800041b2 <filestat>
}
    80004e2e:	60e2                	ld	ra,24(sp)
    80004e30:	6442                	ld	s0,16(sp)
    80004e32:	6105                	addi	sp,sp,32
    80004e34:	8082                	ret

0000000080004e36 <sys_link>:
{
    80004e36:	7169                	addi	sp,sp,-304
    80004e38:	f606                	sd	ra,296(sp)
    80004e3a:	f222                	sd	s0,288(sp)
    80004e3c:	1a00                	addi	s0,sp,304
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e3e:	08000613          	li	a2,128
    80004e42:	ed040593          	addi	a1,s0,-304
    80004e46:	4501                	li	a0,0
    80004e48:	9d7fd0ef          	jal	8000281e <argstr>
    return -1;
    80004e4c:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e4e:	10054163          	bltz	a0,80004f50 <sys_link+0x11a>
    80004e52:	08000613          	li	a2,128
    80004e56:	f5040593          	addi	a1,s0,-176
    80004e5a:	4505                	li	a0,1
    80004e5c:	9c3fd0ef          	jal	8000281e <argstr>
    return -1;
    80004e60:	57fd                	li	a5,-1
  if (argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004e62:	0e054763          	bltz	a0,80004f50 <sys_link+0x11a>
    80004e66:	ee26                	sd	s1,280(sp)
  begin_op();
    80004e68:	dddfe0ef          	jal	80003c44 <begin_op>
  if ((ip = namei(old)) == 0) {
    80004e6c:	ed040513          	addi	a0,s0,-304
    80004e70:	c01fe0ef          	jal	80003a70 <namei>
    80004e74:	84aa                	mv	s1,a0
    80004e76:	cd35                	beqz	a0,80004ef2 <sys_link+0xbc>
  ilock(ip);
    80004e78:	b84fe0ef          	jal	800031fc <ilock>
  if (ip->type == T_DIR) {
    80004e7c:	04449703          	lh	a4,68(s1)
    80004e80:	4785                	li	a5,1
    80004e82:	06f70d63          	beq	a4,a5,80004efc <sys_link+0xc6>
  if (ip->nlink >= NLINK_MAX) {
    80004e86:	04a49783          	lh	a5,74(s1)
    80004e8a:	6721                	lui	a4,0x8
    80004e8c:	177d                	addi	a4,a4,-1 # 7fff <_entry-0x7fff8001>
    80004e8e:	06e78f63          	beq	a5,a4,80004f0c <sys_link+0xd6>
    80004e92:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004e94:	2785                	addiw	a5,a5,1
    80004e96:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e9a:	8526                	mv	a0,s1
    80004e9c:	aacfe0ef          	jal	80003148 <iupdate>
  iunlock(ip);
    80004ea0:	8526                	mv	a0,s1
    80004ea2:	c08fe0ef          	jal	800032aa <iunlock>
  if ((dp = nameiparent(new, name)) == 0)
    80004ea6:	fd040593          	addi	a1,s0,-48
    80004eaa:	f5040513          	addi	a0,s0,-176
    80004eae:	bddfe0ef          	jal	80003a8a <nameiparent>
    80004eb2:	892a                	mv	s2,a0
    80004eb4:	c93d                	beqz	a0,80004f2a <sys_link+0xf4>
  ilock(dp);
    80004eb6:	b46fe0ef          	jal	800031fc <ilock>
  if (dp->nlink == 0) {
    80004eba:	04a91783          	lh	a5,74(s2)
    80004ebe:	cfb9                	beqz	a5,80004f1c <sys_link+0xe6>
  if (dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0) {
    80004ec0:	00092703          	lw	a4,0(s2)
    80004ec4:	409c                	lw	a5,0(s1)
    80004ec6:	04f71f63          	bne	a4,a5,80004f24 <sys_link+0xee>
    80004eca:	40d0                	lw	a2,4(s1)
    80004ecc:	fd040593          	addi	a1,s0,-48
    80004ed0:	854a                	mv	a0,s2
    80004ed2:	b05fe0ef          	jal	800039d6 <dirlink>
    80004ed6:	04054763          	bltz	a0,80004f24 <sys_link+0xee>
  iunlockput(dp);
    80004eda:	854a                	mv	a0,s2
    80004edc:	d72fe0ef          	jal	8000344e <iunlockput>
  iput(ip);
    80004ee0:	8526                	mv	a0,s1
    80004ee2:	c9cfe0ef          	jal	8000337e <iput>
  end_op();
    80004ee6:	de5fe0ef          	jal	80003cca <end_op>
  return 0;
    80004eea:	4781                	li	a5,0
    80004eec:	64f2                	ld	s1,280(sp)
    80004eee:	6952                	ld	s2,272(sp)
    80004ef0:	a085                	j	80004f50 <sys_link+0x11a>
    end_op();
    80004ef2:	dd9fe0ef          	jal	80003cca <end_op>
    return -1;
    80004ef6:	57fd                	li	a5,-1
    80004ef8:	64f2                	ld	s1,280(sp)
    80004efa:	a899                	j	80004f50 <sys_link+0x11a>
    iunlockput(ip);
    80004efc:	8526                	mv	a0,s1
    80004efe:	d50fe0ef          	jal	8000344e <iunlockput>
    end_op();
    80004f02:	dc9fe0ef          	jal	80003cca <end_op>
    return -1;
    80004f06:	57fd                	li	a5,-1
    80004f08:	64f2                	ld	s1,280(sp)
    80004f0a:	a099                	j	80004f50 <sys_link+0x11a>
    iunlockput(ip);
    80004f0c:	8526                	mv	a0,s1
    80004f0e:	d40fe0ef          	jal	8000344e <iunlockput>
    end_op();
    80004f12:	db9fe0ef          	jal	80003cca <end_op>
    return -1;
    80004f16:	57fd                	li	a5,-1
    80004f18:	64f2                	ld	s1,280(sp)
    80004f1a:	a81d                	j	80004f50 <sys_link+0x11a>
    iunlockput(dp);
    80004f1c:	854a                	mv	a0,s2
    80004f1e:	d30fe0ef          	jal	8000344e <iunlockput>
    goto bad;
    80004f22:	a021                	j	80004f2a <sys_link+0xf4>
    iunlockput(dp);
    80004f24:	854a                	mv	a0,s2
    80004f26:	d28fe0ef          	jal	8000344e <iunlockput>
  ilock(ip);
    80004f2a:	8526                	mv	a0,s1
    80004f2c:	ad0fe0ef          	jal	800031fc <ilock>
  ip->nlink--;
    80004f30:	04a4d783          	lhu	a5,74(s1)
    80004f34:	37fd                	addiw	a5,a5,-1
    80004f36:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004f3a:	8526                	mv	a0,s1
    80004f3c:	a0cfe0ef          	jal	80003148 <iupdate>
  iunlockput(ip);
    80004f40:	8526                	mv	a0,s1
    80004f42:	d0cfe0ef          	jal	8000344e <iunlockput>
  end_op();
    80004f46:	d85fe0ef          	jal	80003cca <end_op>
  return -1;
    80004f4a:	57fd                	li	a5,-1
    80004f4c:	64f2                	ld	s1,280(sp)
    80004f4e:	6952                	ld	s2,272(sp)
}
    80004f50:	853e                	mv	a0,a5
    80004f52:	70b2                	ld	ra,296(sp)
    80004f54:	7412                	ld	s0,288(sp)
    80004f56:	6155                	addi	sp,sp,304
    80004f58:	8082                	ret

0000000080004f5a <sys_unlink>:
{
    80004f5a:	7151                	addi	sp,sp,-240
    80004f5c:	f586                	sd	ra,232(sp)
    80004f5e:	f1a2                	sd	s0,224(sp)
    80004f60:	1980                	addi	s0,sp,240
  if (argstr(0, path, MAXPATH) < 0)
    80004f62:	08000613          	li	a2,128
    80004f66:	f3040593          	addi	a1,s0,-208
    80004f6a:	4501                	li	a0,0
    80004f6c:	8b3fd0ef          	jal	8000281e <argstr>
    80004f70:	16054063          	bltz	a0,800050d0 <sys_unlink+0x176>
    80004f74:	eda6                	sd	s1,216(sp)
  begin_op();
    80004f76:	ccffe0ef          	jal	80003c44 <begin_op>
  if ((dp = nameiparent(path, name)) == 0) {
    80004f7a:	fb040593          	addi	a1,s0,-80
    80004f7e:	f3040513          	addi	a0,s0,-208
    80004f82:	b09fe0ef          	jal	80003a8a <nameiparent>
    80004f86:	84aa                	mv	s1,a0
    80004f88:	c945                	beqz	a0,80005038 <sys_unlink+0xde>
  ilock(dp);
    80004f8a:	a72fe0ef          	jal	800031fc <ilock>
  if (namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004f8e:	00002597          	auipc	a1,0x2
    80004f92:	65a58593          	addi	a1,a1,1626 # 800075e8 <etext+0x5e8>
    80004f96:	fb040513          	addi	a0,s0,-80
    80004f9a:	84bfe0ef          	jal	800037e4 <namecmp>
    80004f9e:	10050e63          	beqz	a0,800050ba <sys_unlink+0x160>
    80004fa2:	00002597          	auipc	a1,0x2
    80004fa6:	63e58593          	addi	a1,a1,1598 # 800075e0 <etext+0x5e0>
    80004faa:	fb040513          	addi	a0,s0,-80
    80004fae:	837fe0ef          	jal	800037e4 <namecmp>
    80004fb2:	10050463          	beqz	a0,800050ba <sys_unlink+0x160>
    80004fb6:	e9ca                	sd	s2,208(sp)
  if ((ip = dirlookup(dp, name, &off)) == 0)
    80004fb8:	f2c40613          	addi	a2,s0,-212
    80004fbc:	fb040593          	addi	a1,s0,-80
    80004fc0:	8526                	mv	a0,s1
    80004fc2:	839fe0ef          	jal	800037fa <dirlookup>
    80004fc6:	892a                	mv	s2,a0
    80004fc8:	0e050863          	beqz	a0,800050b8 <sys_unlink+0x15e>
  ilock(ip);
    80004fcc:	a30fe0ef          	jal	800031fc <ilock>
  if (ip->nlink < 1)
    80004fd0:	04a91783          	lh	a5,74(s2)
    80004fd4:	06f05763          	blez	a5,80005042 <sys_unlink+0xe8>
  if (ip->type == T_DIR && !isdirempty(ip)) {
    80004fd8:	04491703          	lh	a4,68(s2)
    80004fdc:	4785                	li	a5,1
    80004fde:	06f70963          	beq	a4,a5,80005050 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004fe2:	4641                	li	a2,16
    80004fe4:	4581                	li	a1,0
    80004fe6:	fc040513          	addi	a0,s0,-64
    80004fea:	c6bfb0ef          	jal	80000c54 <memset>
  if (writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004fee:	4741                	li	a4,16
    80004ff0:	f2c42683          	lw	a3,-212(s0)
    80004ff4:	fc040613          	addi	a2,s0,-64
    80004ff8:	4581                	li	a1,0
    80004ffa:	8526                	mv	a0,s1
    80004ffc:	ed4fe0ef          	jal	800036d0 <writei>
    80005000:	47c1                	li	a5,16
    80005002:	08f51b63          	bne	a0,a5,80005098 <sys_unlink+0x13e>
  if (ip->type == T_DIR) {
    80005006:	04491703          	lh	a4,68(s2)
    8000500a:	4785                	li	a5,1
    8000500c:	08f70d63          	beq	a4,a5,800050a6 <sys_unlink+0x14c>
  iunlockput(dp);
    80005010:	8526                	mv	a0,s1
    80005012:	c3cfe0ef          	jal	8000344e <iunlockput>
  ip->nlink--;
    80005016:	04a95783          	lhu	a5,74(s2)
    8000501a:	37fd                	addiw	a5,a5,-1
    8000501c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005020:	854a                	mv	a0,s2
    80005022:	926fe0ef          	jal	80003148 <iupdate>
  iunlockput(ip);
    80005026:	854a                	mv	a0,s2
    80005028:	c26fe0ef          	jal	8000344e <iunlockput>
  end_op();
    8000502c:	c9ffe0ef          	jal	80003cca <end_op>
  return 0;
    80005030:	4501                	li	a0,0
    80005032:	64ee                	ld	s1,216(sp)
    80005034:	694e                	ld	s2,208(sp)
    80005036:	a849                	j	800050c8 <sys_unlink+0x16e>
    end_op();
    80005038:	c93fe0ef          	jal	80003cca <end_op>
    return -1;
    8000503c:	557d                	li	a0,-1
    8000503e:	64ee                	ld	s1,216(sp)
    80005040:	a061                	j	800050c8 <sys_unlink+0x16e>
    80005042:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005044:	00002517          	auipc	a0,0x2
    80005048:	5ac50513          	addi	a0,a0,1452 # 800075f0 <etext+0x5f0>
    8000504c:	fa4fb0ef          	jal	800007f0 <panic>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    80005050:	04c92703          	lw	a4,76(s2)
    80005054:	02000793          	li	a5,32
    80005058:	f8e7f5e3          	bgeu	a5,a4,80004fe2 <sys_unlink+0x88>
    8000505c:	e5ce                	sd	s3,200(sp)
    8000505e:	02000993          	li	s3,32
    if (readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005062:	4741                	li	a4,16
    80005064:	86ce                	mv	a3,s3
    80005066:	f1840613          	addi	a2,s0,-232
    8000506a:	4581                	li	a1,0
    8000506c:	854a                	mv	a0,s2
    8000506e:	d66fe0ef          	jal	800035d4 <readi>
    80005072:	47c1                	li	a5,16
    80005074:	00f51c63          	bne	a0,a5,8000508c <sys_unlink+0x132>
    if (de.inum != 0)
    80005078:	f1845783          	lhu	a5,-232(s0)
    8000507c:	efa1                	bnez	a5,800050d4 <sys_unlink+0x17a>
  for (off = 2 * sizeof(de); off < dp->size; off += sizeof(de)) {
    8000507e:	29c1                	addiw	s3,s3,16
    80005080:	04c92783          	lw	a5,76(s2)
    80005084:	fcf9efe3          	bltu	s3,a5,80005062 <sys_unlink+0x108>
    80005088:	69ae                	ld	s3,200(sp)
    8000508a:	bfa1                	j	80004fe2 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000508c:	00002517          	auipc	a0,0x2
    80005090:	57c50513          	addi	a0,a0,1404 # 80007608 <etext+0x608>
    80005094:	f5cfb0ef          	jal	800007f0 <panic>
    80005098:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000509a:	00002517          	auipc	a0,0x2
    8000509e:	58650513          	addi	a0,a0,1414 # 80007620 <etext+0x620>
    800050a2:	f4efb0ef          	jal	800007f0 <panic>
    dp->nlink--;
    800050a6:	04a4d783          	lhu	a5,74(s1)
    800050aa:	37fd                	addiw	a5,a5,-1
    800050ac:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050b0:	8526                	mv	a0,s1
    800050b2:	896fe0ef          	jal	80003148 <iupdate>
    800050b6:	bfa9                	j	80005010 <sys_unlink+0xb6>
    800050b8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800050ba:	8526                	mv	a0,s1
    800050bc:	b92fe0ef          	jal	8000344e <iunlockput>
  end_op();
    800050c0:	c0bfe0ef          	jal	80003cca <end_op>
  return -1;
    800050c4:	557d                	li	a0,-1
    800050c6:	64ee                	ld	s1,216(sp)
}
    800050c8:	70ae                	ld	ra,232(sp)
    800050ca:	740e                	ld	s0,224(sp)
    800050cc:	616d                	addi	sp,sp,240
    800050ce:	8082                	ret
    return -1;
    800050d0:	557d                	li	a0,-1
    800050d2:	bfdd                	j	800050c8 <sys_unlink+0x16e>
    iunlockput(ip);
    800050d4:	854a                	mv	a0,s2
    800050d6:	b78fe0ef          	jal	8000344e <iunlockput>
    goto bad;
    800050da:	694e                	ld	s2,208(sp)
    800050dc:	69ae                	ld	s3,200(sp)
    800050de:	bff1                	j	800050ba <sys_unlink+0x160>

00000000800050e0 <sys_open>:

uint64
sys_open(void)
{
    800050e0:	7131                	addi	sp,sp,-192
    800050e2:	fd06                	sd	ra,184(sp)
    800050e4:	f922                	sd	s0,176(sp)
    800050e6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800050e8:	f4c40593          	addi	a1,s0,-180
    800050ec:	4505                	li	a0,1
    800050ee:	ef8fd0ef          	jal	800027e6 <argint>
  if ((n = argstr(0, path, MAXPATH)) < 0)
    800050f2:	08000613          	li	a2,128
    800050f6:	f5040593          	addi	a1,s0,-176
    800050fa:	4501                	li	a0,0
    800050fc:	f22fd0ef          	jal	8000281e <argstr>
    80005100:	87aa                	mv	a5,a0
    return -1;
    80005102:	557d                	li	a0,-1
  if ((n = argstr(0, path, MAXPATH)) < 0)
    80005104:	0a07c263          	bltz	a5,800051a8 <sys_open+0xc8>
    80005108:	f526                	sd	s1,168(sp)

  begin_op();
    8000510a:	b3bfe0ef          	jal	80003c44 <begin_op>

  if (omode & O_CREATE) {
    8000510e:	f4c42783          	lw	a5,-180(s0)
    80005112:	2007f793          	andi	a5,a5,512
    80005116:	c3d5                	beqz	a5,800051ba <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005118:	4681                	li	a3,0
    8000511a:	4601                	li	a2,0
    8000511c:	4589                	li	a1,2
    8000511e:	f5040513          	addi	a0,s0,-176
    80005122:	a23ff0ef          	jal	80004b44 <create>
    80005126:	84aa                	mv	s1,a0
    if (ip == 0) {
    80005128:	c541                	beqz	a0,800051b0 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if (ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)) {
    8000512a:	04449703          	lh	a4,68(s1)
    8000512e:	478d                	li	a5,3
    80005130:	00f71763          	bne	a4,a5,8000513e <sys_open+0x5e>
    80005134:	0464d703          	lhu	a4,70(s1)
    80005138:	47a5                	li	a5,9
    8000513a:	0ae7ed63          	bltu	a5,a4,800051f4 <sys_open+0x114>
    8000513e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if ((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0) {
    80005140:	f0dfe0ef          	jal	8000404c <filealloc>
    80005144:	892a                	mv	s2,a0
    80005146:	c179                	beqz	a0,8000520c <sys_open+0x12c>
    80005148:	ed4e                	sd	s3,152(sp)
    8000514a:	9bdff0ef          	jal	80004b06 <fdalloc>
    8000514e:	89aa                	mv	s3,a0
    80005150:	0a054a63          	bltz	a0,80005204 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if (ip->type == T_DEVICE) {
    80005154:	04449703          	lh	a4,68(s1)
    80005158:	478d                	li	a5,3
    8000515a:	0cf70263          	beq	a4,a5,8000521e <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000515e:	4789                	li	a5,2
    80005160:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005164:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005168:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000516c:	f4c42783          	lw	a5,-180(s0)
    80005170:	0017c713          	xori	a4,a5,1
    80005174:	8b05                	andi	a4,a4,1
    80005176:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000517a:	0037f713          	andi	a4,a5,3
    8000517e:	00e03733          	snez	a4,a4
    80005182:	00e904a3          	sb	a4,9(s2)

  if ((omode & O_TRUNC) && ip->type == T_FILE) {
    80005186:	4007f793          	andi	a5,a5,1024
    8000518a:	c791                	beqz	a5,80005196 <sys_open+0xb6>
    8000518c:	04449703          	lh	a4,68(s1)
    80005190:	4789                	li	a5,2
    80005192:	08f70d63          	beq	a4,a5,8000522c <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005196:	8526                	mv	a0,s1
    80005198:	912fe0ef          	jal	800032aa <iunlock>
  end_op();
    8000519c:	b2ffe0ef          	jal	80003cca <end_op>

  return fd;
    800051a0:	854e                	mv	a0,s3
    800051a2:	74aa                	ld	s1,168(sp)
    800051a4:	790a                	ld	s2,160(sp)
    800051a6:	69ea                	ld	s3,152(sp)
}
    800051a8:	70ea                	ld	ra,184(sp)
    800051aa:	744a                	ld	s0,176(sp)
    800051ac:	6129                	addi	sp,sp,192
    800051ae:	8082                	ret
      end_op();
    800051b0:	b1bfe0ef          	jal	80003cca <end_op>
      return -1;
    800051b4:	557d                	li	a0,-1
    800051b6:	74aa                	ld	s1,168(sp)
    800051b8:	bfc5                	j	800051a8 <sys_open+0xc8>
    if ((ip = namei(path)) == 0) {
    800051ba:	f5040513          	addi	a0,s0,-176
    800051be:	8b3fe0ef          	jal	80003a70 <namei>
    800051c2:	84aa                	mv	s1,a0
    800051c4:	c11d                	beqz	a0,800051ea <sys_open+0x10a>
    ilock(ip);
    800051c6:	836fe0ef          	jal	800031fc <ilock>
    if (ip->type == T_DIR && omode != O_RDONLY) {
    800051ca:	04449703          	lh	a4,68(s1)
    800051ce:	4785                	li	a5,1
    800051d0:	f4f71de3          	bne	a4,a5,8000512a <sys_open+0x4a>
    800051d4:	f4c42783          	lw	a5,-180(s0)
    800051d8:	d3bd                	beqz	a5,8000513e <sys_open+0x5e>
      iunlockput(ip);
    800051da:	8526                	mv	a0,s1
    800051dc:	a72fe0ef          	jal	8000344e <iunlockput>
      end_op();
    800051e0:	aebfe0ef          	jal	80003cca <end_op>
      return -1;
    800051e4:	557d                	li	a0,-1
    800051e6:	74aa                	ld	s1,168(sp)
    800051e8:	b7c1                	j	800051a8 <sys_open+0xc8>
      end_op();
    800051ea:	ae1fe0ef          	jal	80003cca <end_op>
      return -1;
    800051ee:	557d                	li	a0,-1
    800051f0:	74aa                	ld	s1,168(sp)
    800051f2:	bf5d                	j	800051a8 <sys_open+0xc8>
    iunlockput(ip);
    800051f4:	8526                	mv	a0,s1
    800051f6:	a58fe0ef          	jal	8000344e <iunlockput>
    end_op();
    800051fa:	ad1fe0ef          	jal	80003cca <end_op>
    return -1;
    800051fe:	557d                	li	a0,-1
    80005200:	74aa                	ld	s1,168(sp)
    80005202:	b75d                	j	800051a8 <sys_open+0xc8>
      fileclose(f);
    80005204:	854a                	mv	a0,s2
    80005206:	eebfe0ef          	jal	800040f0 <fileclose>
    8000520a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000520c:	8526                	mv	a0,s1
    8000520e:	a40fe0ef          	jal	8000344e <iunlockput>
    end_op();
    80005212:	ab9fe0ef          	jal	80003cca <end_op>
    return -1;
    80005216:	557d                	li	a0,-1
    80005218:	74aa                	ld	s1,168(sp)
    8000521a:	790a                	ld	s2,160(sp)
    8000521c:	b771                	j	800051a8 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000521e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005222:	04649783          	lh	a5,70(s1)
    80005226:	02f91223          	sh	a5,36(s2)
    8000522a:	bf3d                	j	80005168 <sys_open+0x88>
    itrunc(ip);
    8000522c:	8526                	mv	a0,s1
    8000522e:	8bcfe0ef          	jal	800032ea <itrunc>
    80005232:	b795                	j	80005196 <sys_open+0xb6>

0000000080005234 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005234:	7175                	addi	sp,sp,-144
    80005236:	e506                	sd	ra,136(sp)
    80005238:	e122                	sd	s0,128(sp)
    8000523a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000523c:	a09fe0ef          	jal	80003c44 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0) {
    80005240:	08000613          	li	a2,128
    80005244:	f7040593          	addi	a1,s0,-144
    80005248:	4501                	li	a0,0
    8000524a:	dd4fd0ef          	jal	8000281e <argstr>
    8000524e:	02054363          	bltz	a0,80005274 <sys_mkdir+0x40>
    80005252:	4681                	li	a3,0
    80005254:	4601                	li	a2,0
    80005256:	4585                	li	a1,1
    80005258:	f7040513          	addi	a0,s0,-144
    8000525c:	8e9ff0ef          	jal	80004b44 <create>
    80005260:	c911                	beqz	a0,80005274 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005262:	9ecfe0ef          	jal	8000344e <iunlockput>
  end_op();
    80005266:	a65fe0ef          	jal	80003cca <end_op>
  return 0;
    8000526a:	4501                	li	a0,0
}
    8000526c:	60aa                	ld	ra,136(sp)
    8000526e:	640a                	ld	s0,128(sp)
    80005270:	6149                	addi	sp,sp,144
    80005272:	8082                	ret
    end_op();
    80005274:	a57fe0ef          	jal	80003cca <end_op>
    return -1;
    80005278:	557d                	li	a0,-1
    8000527a:	bfcd                	j	8000526c <sys_mkdir+0x38>

000000008000527c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000527c:	7135                	addi	sp,sp,-160
    8000527e:	ed06                	sd	ra,152(sp)
    80005280:	e922                	sd	s0,144(sp)
    80005282:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005284:	9c1fe0ef          	jal	80003c44 <begin_op>
  argint(1, &major);
    80005288:	f6c40593          	addi	a1,s0,-148
    8000528c:	4505                	li	a0,1
    8000528e:	d58fd0ef          	jal	800027e6 <argint>
  argint(2, &minor);
    80005292:	f6840593          	addi	a1,s0,-152
    80005296:	4509                	li	a0,2
    80005298:	d4efd0ef          	jal	800027e6 <argint>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    8000529c:	08000613          	li	a2,128
    800052a0:	f7040593          	addi	a1,s0,-144
    800052a4:	4501                	li	a0,0
    800052a6:	d78fd0ef          	jal	8000281e <argstr>
    800052aa:	02054563          	bltz	a0,800052d4 <sys_mknod+0x58>
      (ip = create(path, T_DEVICE, major, minor)) == 0) {
    800052ae:	f6841683          	lh	a3,-152(s0)
    800052b2:	f6c41603          	lh	a2,-148(s0)
    800052b6:	458d                	li	a1,3
    800052b8:	f7040513          	addi	a0,s0,-144
    800052bc:	889ff0ef          	jal	80004b44 <create>
  if ((argstr(0, path, MAXPATH)) < 0 ||
    800052c0:	c911                	beqz	a0,800052d4 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800052c2:	98cfe0ef          	jal	8000344e <iunlockput>
  end_op();
    800052c6:	a05fe0ef          	jal	80003cca <end_op>
  return 0;
    800052ca:	4501                	li	a0,0
}
    800052cc:	60ea                	ld	ra,152(sp)
    800052ce:	644a                	ld	s0,144(sp)
    800052d0:	610d                	addi	sp,sp,160
    800052d2:	8082                	ret
    end_op();
    800052d4:	9f7fe0ef          	jal	80003cca <end_op>
    return -1;
    800052d8:	557d                	li	a0,-1
    800052da:	bfcd                	j	800052cc <sys_mknod+0x50>

00000000800052dc <sys_chdir>:

uint64
sys_chdir(void)
{
    800052dc:	7135                	addi	sp,sp,-160
    800052de:	ed06                	sd	ra,152(sp)
    800052e0:	e922                	sd	s0,144(sp)
    800052e2:	e14a                	sd	s2,128(sp)
    800052e4:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800052e6:	dbcfc0ef          	jal	800018a2 <myproc>
    800052ea:	892a                	mv	s2,a0

  begin_op();
    800052ec:	959fe0ef          	jal	80003c44 <begin_op>
  if (argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0) {
    800052f0:	08000613          	li	a2,128
    800052f4:	f6040593          	addi	a1,s0,-160
    800052f8:	4501                	li	a0,0
    800052fa:	d24fd0ef          	jal	8000281e <argstr>
    800052fe:	04054363          	bltz	a0,80005344 <sys_chdir+0x68>
    80005302:	e526                	sd	s1,136(sp)
    80005304:	f6040513          	addi	a0,s0,-160
    80005308:	f68fe0ef          	jal	80003a70 <namei>
    8000530c:	84aa                	mv	s1,a0
    8000530e:	c915                	beqz	a0,80005342 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005310:	eedfd0ef          	jal	800031fc <ilock>
  if (ip->type != T_DIR) {
    80005314:	04449703          	lh	a4,68(s1)
    80005318:	4785                	li	a5,1
    8000531a:	02f71963          	bne	a4,a5,8000534c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000531e:	8526                	mv	a0,s1
    80005320:	f8bfd0ef          	jal	800032aa <iunlock>
  iput(p->cwd);
    80005324:	15093503          	ld	a0,336(s2)
    80005328:	856fe0ef          	jal	8000337e <iput>
  end_op();
    8000532c:	99ffe0ef          	jal	80003cca <end_op>
  p->cwd = ip;
    80005330:	14993823          	sd	s1,336(s2)
  return 0;
    80005334:	4501                	li	a0,0
    80005336:	64aa                	ld	s1,136(sp)
}
    80005338:	60ea                	ld	ra,152(sp)
    8000533a:	644a                	ld	s0,144(sp)
    8000533c:	690a                	ld	s2,128(sp)
    8000533e:	610d                	addi	sp,sp,160
    80005340:	8082                	ret
    80005342:	64aa                	ld	s1,136(sp)
    end_op();
    80005344:	987fe0ef          	jal	80003cca <end_op>
    return -1;
    80005348:	557d                	li	a0,-1
    8000534a:	b7fd                	j	80005338 <sys_chdir+0x5c>
    iunlockput(ip);
    8000534c:	8526                	mv	a0,s1
    8000534e:	900fe0ef          	jal	8000344e <iunlockput>
    end_op();
    80005352:	979fe0ef          	jal	80003cca <end_op>
    return -1;
    80005356:	557d                	li	a0,-1
    80005358:	64aa                	ld	s1,136(sp)
    8000535a:	bff9                	j	80005338 <sys_chdir+0x5c>

000000008000535c <sys_exec>:

uint64
sys_exec(void)
{
    8000535c:	7121                	addi	sp,sp,-448
    8000535e:	ff06                	sd	ra,440(sp)
    80005360:	fb22                	sd	s0,432(sp)
    80005362:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005364:	e4840593          	addi	a1,s0,-440
    80005368:	4505                	li	a0,1
    8000536a:	c98fd0ef          	jal	80002802 <argaddr>
  if (argstr(0, path, MAXPATH) < 0) {
    8000536e:	08000613          	li	a2,128
    80005372:	f5040593          	addi	a1,s0,-176
    80005376:	4501                	li	a0,0
    80005378:	ca6fd0ef          	jal	8000281e <argstr>
    8000537c:	87aa                	mv	a5,a0
    return -1;
    8000537e:	557d                	li	a0,-1
  if (argstr(0, path, MAXPATH) < 0) {
    80005380:	0c07c463          	bltz	a5,80005448 <sys_exec+0xec>
    80005384:	f726                	sd	s1,424(sp)
    80005386:	f34a                	sd	s2,416(sp)
    80005388:	ef4e                	sd	s3,408(sp)
    8000538a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000538c:	10000613          	li	a2,256
    80005390:	4581                	li	a1,0
    80005392:	e5040513          	addi	a0,s0,-432
    80005396:	8bffb0ef          	jal	80000c54 <memset>
  for (i = 0;; i++) {
    if (i >= NELEM(argv)) {
    8000539a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000539e:	89a6                	mv	s3,s1
    800053a0:	4901                	li	s2,0
    if (i >= NELEM(argv)) {
    800053a2:	02000a13          	li	s4,32
      goto bad;
    }
    if (fetchaddr(uargv + sizeof(uint64) * i, (uint64 *)&uarg) < 0) {
    800053a6:	00391513          	slli	a0,s2,0x3
    800053aa:	e4040593          	addi	a1,s0,-448
    800053ae:	e4843783          	ld	a5,-440(s0)
    800053b2:	953e                	add	a0,a0,a5
    800053b4:	ba6fd0ef          	jal	8000275a <fetchaddr>
    800053b8:	02054663          	bltz	a0,800053e4 <sys_exec+0x88>
      goto bad;
    }
    if (uarg == 0) {
    800053bc:	e4043783          	ld	a5,-448(s0)
    800053c0:	c3a9                	beqz	a5,80005402 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800053c2:	f08fb0ef          	jal	80000aca <kalloc>
    800053c6:	85aa                	mv	a1,a0
    800053c8:	00a9b023          	sd	a0,0(s3)
    if (argv[i] == 0)
    800053cc:	cd01                	beqz	a0,800053e4 <sys_exec+0x88>
      goto bad;
    if (fetchstr(uarg, argv[i], PGSIZE) < 0)
    800053ce:	6605                	lui	a2,0x1
    800053d0:	e4043503          	ld	a0,-448(s0)
    800053d4:	bd0fd0ef          	jal	800027a4 <fetchstr>
    800053d8:	00054663          	bltz	a0,800053e4 <sys_exec+0x88>
    if (i >= NELEM(argv)) {
    800053dc:	0905                	addi	s2,s2,1
    800053de:	09a1                	addi	s3,s3,8
    800053e0:	fd4913e3          	bne	s2,s4,800053a6 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

bad:
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053e4:	f5040913          	addi	s2,s0,-176
    800053e8:	6088                	ld	a0,0(s1)
    800053ea:	c931                	beqz	a0,8000543e <sys_exec+0xe2>
    kfree(argv[i]);
    800053ec:	dfcfb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800053f0:	04a1                	addi	s1,s1,8
    800053f2:	ff249be3          	bne	s1,s2,800053e8 <sys_exec+0x8c>
  return -1;
    800053f6:	557d                	li	a0,-1
    800053f8:	74ba                	ld	s1,424(sp)
    800053fa:	791a                	ld	s2,416(sp)
    800053fc:	69fa                	ld	s3,408(sp)
    800053fe:	6a5a                	ld	s4,400(sp)
    80005400:	a0a1                	j	80005448 <sys_exec+0xec>
      argv[i] = 0;
    80005402:	0009079b          	sext.w	a5,s2
    80005406:	078e                	slli	a5,a5,0x3
    80005408:	fd078793          	addi	a5,a5,-48
    8000540c:	97a2                	add	a5,a5,s0
    8000540e:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005412:	e5040593          	addi	a1,s0,-432
    80005416:	f5040513          	addi	a0,s0,-176
    8000541a:	b26ff0ef          	jal	80004740 <kexec>
    8000541e:	892a                	mv	s2,a0
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005420:	f5040993          	addi	s3,s0,-176
    80005424:	6088                	ld	a0,0(s1)
    80005426:	c511                	beqz	a0,80005432 <sys_exec+0xd6>
    kfree(argv[i]);
    80005428:	dc0fb0ef          	jal	800009e8 <kfree>
  for (i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000542c:	04a1                	addi	s1,s1,8
    8000542e:	ff349be3          	bne	s1,s3,80005424 <sys_exec+0xc8>
  return ret;
    80005432:	854a                	mv	a0,s2
    80005434:	74ba                	ld	s1,424(sp)
    80005436:	791a                	ld	s2,416(sp)
    80005438:	69fa                	ld	s3,408(sp)
    8000543a:	6a5a                	ld	s4,400(sp)
    8000543c:	a031                	j	80005448 <sys_exec+0xec>
  return -1;
    8000543e:	557d                	li	a0,-1
    80005440:	74ba                	ld	s1,424(sp)
    80005442:	791a                	ld	s2,416(sp)
    80005444:	69fa                	ld	s3,408(sp)
    80005446:	6a5a                	ld	s4,400(sp)
}
    80005448:	70fa                	ld	ra,440(sp)
    8000544a:	745a                	ld	s0,432(sp)
    8000544c:	6139                	addi	sp,sp,448
    8000544e:	8082                	ret

0000000080005450 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005450:	7139                	addi	sp,sp,-64
    80005452:	fc06                	sd	ra,56(sp)
    80005454:	f822                	sd	s0,48(sp)
    80005456:	f426                	sd	s1,40(sp)
    80005458:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000545a:	c48fc0ef          	jal	800018a2 <myproc>
    8000545e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005460:	fd840593          	addi	a1,s0,-40
    80005464:	4501                	li	a0,0
    80005466:	b9cfd0ef          	jal	80002802 <argaddr>
  if (pipealloc(&rf, &wf) < 0)
    8000546a:	fc840593          	addi	a1,s0,-56
    8000546e:	fd040513          	addi	a0,s0,-48
    80005472:	f9ffe0ef          	jal	80004410 <pipealloc>
    return -1;
    80005476:	57fd                	li	a5,-1
  if (pipealloc(&rf, &wf) < 0)
    80005478:	0a054663          	bltz	a0,80005524 <sys_pipe+0xd4>
  fd0 = -1;
    8000547c:	fcf42223          	sw	a5,-60(s0)
  if ((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0) {
    80005480:	fd043503          	ld	a0,-48(s0)
    80005484:	e82ff0ef          	jal	80004b06 <fdalloc>
    80005488:	fca42223          	sw	a0,-60(s0)
    8000548c:	08054363          	bltz	a0,80005512 <sys_pipe+0xc2>
    80005490:	fc843503          	ld	a0,-56(s0)
    80005494:	e72ff0ef          	jal	80004b06 <fdalloc>
    80005498:	fca42023          	sw	a0,-64(s0)
    8000549c:	06054263          	bltz	a0,80005500 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800054a0:	4711                	li	a4,4
    800054a2:	fc440693          	addi	a3,s0,-60
    800054a6:	fd843603          	ld	a2,-40(s0)
    800054aa:	64ac                	ld	a1,72(s1)
    800054ac:	68a8                	ld	a0,80(s1)
    800054ae:	82afc0ef          	jal	800014d8 <copyout>
    800054b2:	00054f63          	bltz	a0,800054d0 <sys_pipe+0x80>
      copyout(p->pagetable, p->sz, fdarray + sizeof(fd0), (char *)&fd1,
    800054b6:	4711                	li	a4,4
    800054b8:	fc040693          	addi	a3,s0,-64
    800054bc:	fd843603          	ld	a2,-40(s0)
    800054c0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800054c2:	64ac                	ld	a1,72(s1)
    800054c4:	68a8                	ld	a0,80(s1)
    800054c6:	812fc0ef          	jal	800014d8 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800054ca:	4781                	li	a5,0
  if (copyout(p->pagetable, p->sz, fdarray, (char *)&fd0, sizeof(fd0)) < 0 ||
    800054cc:	04055c63          	bgez	a0,80005524 <sys_pipe+0xd4>
    p->ofile[fd0] = 0;
    800054d0:	fc442783          	lw	a5,-60(s0)
    800054d4:	07e9                	addi	a5,a5,26
    800054d6:	078e                	slli	a5,a5,0x3
    800054d8:	97a6                	add	a5,a5,s1
    800054da:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800054de:	fc042783          	lw	a5,-64(s0)
    800054e2:	07e9                	addi	a5,a5,26
    800054e4:	078e                	slli	a5,a5,0x3
    800054e6:	94be                	add	s1,s1,a5
    800054e8:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800054ec:	fd043503          	ld	a0,-48(s0)
    800054f0:	c01fe0ef          	jal	800040f0 <fileclose>
    fileclose(wf);
    800054f4:	fc843503          	ld	a0,-56(s0)
    800054f8:	bf9fe0ef          	jal	800040f0 <fileclose>
    return -1;
    800054fc:	57fd                	li	a5,-1
    800054fe:	a01d                	j	80005524 <sys_pipe+0xd4>
    if (fd0 >= 0)
    80005500:	fc442783          	lw	a5,-60(s0)
    80005504:	0007c763          	bltz	a5,80005512 <sys_pipe+0xc2>
      p->ofile[fd0] = 0;
    80005508:	07e9                	addi	a5,a5,26
    8000550a:	078e                	slli	a5,a5,0x3
    8000550c:	97a6                	add	a5,a5,s1
    8000550e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005512:	fd043503          	ld	a0,-48(s0)
    80005516:	bdbfe0ef          	jal	800040f0 <fileclose>
    fileclose(wf);
    8000551a:	fc843503          	ld	a0,-56(s0)
    8000551e:	bd3fe0ef          	jal	800040f0 <fileclose>
    return -1;
    80005522:	57fd                	li	a5,-1
}
    80005524:	853e                	mv	a0,a5
    80005526:	70e2                	ld	ra,56(sp)
    80005528:	7442                	ld	s0,48(sp)
    8000552a:	74a2                	ld	s1,40(sp)
    8000552c:	6121                	addi	sp,sp,64
    8000552e:	8082                	ret

0000000080005530 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005530:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005532:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005534:	e80e                	sd	gp,16(sp)
        # sd tp, 24(sp)
        sd t0, 32(sp)
    80005536:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005538:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000553a:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000553c:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    8000553e:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005540:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005542:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005544:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005546:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005548:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000554a:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000554c:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    8000554e:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005550:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005552:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005554:	916fd0ef          	jal	8000266a <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005558:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000555a:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000555c:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    8000555e:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005560:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005562:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005564:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005566:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005568:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000556a:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000556c:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    8000556e:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005570:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005572:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005574:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005576:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005578:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000557a:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000557c:	10200073          	sret
	...

000000008000558e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000558e:	1141                	addi	sp,sp,-16
    80005590:	e422                	sd	s0,8(sp)
    80005592:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32 *)(PLIC + UART0_IRQ * 4) = 1;
    80005594:	0c0007b7          	lui	a5,0xc000
    80005598:	4705                	li	a4,1
    8000559a:	d798                	sw	a4,40(a5)
  *(uint32 *)(PLIC + VIRTIO0_IRQ * 4) = 1;
    8000559c:	0c0007b7          	lui	a5,0xc000
    800055a0:	c3d8                	sw	a4,4(a5)
}
    800055a2:	6422                	ld	s0,8(sp)
    800055a4:	0141                	addi	sp,sp,16
    800055a6:	8082                	ret

00000000800055a8 <plicinithart>:

void
plicinithart(void)
{
    800055a8:	1141                	addi	sp,sp,-16
    800055aa:	e406                	sd	ra,8(sp)
    800055ac:	e022                	sd	s0,0(sp)
    800055ae:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800055b0:	ac6fc0ef          	jal	80001876 <cpuid>

  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32 *)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800055b4:	0085171b          	slliw	a4,a0,0x8
    800055b8:	0c0027b7          	lui	a5,0xc002
    800055bc:	97ba                	add	a5,a5,a4
    800055be:	40200713          	li	a4,1026
    800055c2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32 *)PLIC_SPRIORITY(hart) = 0;
    800055c6:	00d5151b          	slliw	a0,a0,0xd
    800055ca:	0c2017b7          	lui	a5,0xc201
    800055ce:	97aa                	add	a5,a5,a0
    800055d0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800055d4:	60a2                	ld	ra,8(sp)
    800055d6:	6402                	ld	s0,0(sp)
    800055d8:	0141                	addi	sp,sp,16
    800055da:	8082                	ret

00000000800055dc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800055dc:	1141                	addi	sp,sp,-16
    800055de:	e406                	sd	ra,8(sp)
    800055e0:	e022                	sd	s0,0(sp)
    800055e2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800055e4:	a92fc0ef          	jal	80001876 <cpuid>
  int irq = *(uint32 *)PLIC_SCLAIM(hart);
    800055e8:	00d5151b          	slliw	a0,a0,0xd
    800055ec:	0c2017b7          	lui	a5,0xc201
    800055f0:	97aa                	add	a5,a5,a0
  return irq;
}
    800055f2:	43c8                	lw	a0,4(a5)
    800055f4:	60a2                	ld	ra,8(sp)
    800055f6:	6402                	ld	s0,0(sp)
    800055f8:	0141                	addi	sp,sp,16
    800055fa:	8082                	ret

00000000800055fc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800055fc:	1101                	addi	sp,sp,-32
    800055fe:	ec06                	sd	ra,24(sp)
    80005600:	e822                	sd	s0,16(sp)
    80005602:	e426                	sd	s1,8(sp)
    80005604:	1000                	addi	s0,sp,32
    80005606:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005608:	a6efc0ef          	jal	80001876 <cpuid>
  *(uint32 *)PLIC_SCLAIM(hart) = irq;
    8000560c:	00d5151b          	slliw	a0,a0,0xd
    80005610:	0c2017b7          	lui	a5,0xc201
    80005614:	97aa                	add	a5,a5,a0
    80005616:	c3c4                	sw	s1,4(a5)
}
    80005618:	60e2                	ld	ra,24(sp)
    8000561a:	6442                	ld	s0,16(sp)
    8000561c:	64a2                	ld	s1,8(sp)
    8000561e:	6105                	addi	sp,sp,32
    80005620:	8082                	ret

0000000080005622 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005622:	1141                	addi	sp,sp,-16
    80005624:	e406                	sd	ra,8(sp)
    80005626:	e022                	sd	s0,0(sp)
    80005628:	0800                	addi	s0,sp,16
  if (i >= NUM)
    8000562a:	479d                	li	a5,7
    8000562c:	04a7ca63          	blt	a5,a0,80005680 <free_desc+0x5e>
    panic("free_desc 1");
  if (disk.free[i])
    80005630:	0001d797          	auipc	a5,0x1d
    80005634:	40078793          	addi	a5,a5,1024 # 80022a30 <disk>
    80005638:	97aa                	add	a5,a5,a0
    8000563a:	0187c783          	lbu	a5,24(a5)
    8000563e:	e7b9                	bnez	a5,8000568c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005640:	00451693          	slli	a3,a0,0x4
    80005644:	0001d797          	auipc	a5,0x1d
    80005648:	3ec78793          	addi	a5,a5,1004 # 80022a30 <disk>
    8000564c:	6398                	ld	a4,0(a5)
    8000564e:	9736                	add	a4,a4,a3
    80005650:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005654:	6398                	ld	a4,0(a5)
    80005656:	9736                	add	a4,a4,a3
    80005658:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000565c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005660:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005664:	97aa                	add	a5,a5,a0
    80005666:	4705                	li	a4,1
    80005668:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000566c:	0001d517          	auipc	a0,0x1d
    80005670:	3dc50513          	addi	a0,a0,988 # 80022a48 <disk+0x18>
    80005674:	8affc0ef          	jal	80001f22 <wakeup>
}
    80005678:	60a2                	ld	ra,8(sp)
    8000567a:	6402                	ld	s0,0(sp)
    8000567c:	0141                	addi	sp,sp,16
    8000567e:	8082                	ret
    panic("free_desc 1");
    80005680:	00002517          	auipc	a0,0x2
    80005684:	fb050513          	addi	a0,a0,-80 # 80007630 <etext+0x630>
    80005688:	968fb0ef          	jal	800007f0 <panic>
    panic("free_desc 2");
    8000568c:	00002517          	auipc	a0,0x2
    80005690:	fb450513          	addi	a0,a0,-76 # 80007640 <etext+0x640>
    80005694:	95cfb0ef          	jal	800007f0 <panic>

0000000080005698 <virtio_disk_init>:
{
    80005698:	1101                	addi	sp,sp,-32
    8000569a:	ec06                	sd	ra,24(sp)
    8000569c:	e822                	sd	s0,16(sp)
    8000569e:	e426                	sd	s1,8(sp)
    800056a0:	e04a                	sd	s2,0(sp)
    800056a2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800056a4:	00002597          	auipc	a1,0x2
    800056a8:	fac58593          	addi	a1,a1,-84 # 80007650 <etext+0x650>
    800056ac:	0001d517          	auipc	a0,0x1d
    800056b0:	4ac50513          	addi	a0,a0,1196 # 80022b58 <disk+0x128>
    800056b4:	c66fb0ef          	jal	80000b1a <initlock>
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800056b8:	100017b7          	lui	a5,0x10001
    800056bc:	4398                	lw	a4,0(a5)
    800056be:	2701                	sext.w	a4,a4
    800056c0:	747277b7          	lui	a5,0x74727
    800056c4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800056c8:	18f71063          	bne	a4,a5,80005848 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056cc:	100017b7          	lui	a5,0x10001
    800056d0:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    800056d2:	439c                	lw	a5,0(a5)
    800056d4:	2781                	sext.w	a5,a5
  if (*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800056d6:	4709                	li	a4,2
    800056d8:	16e79863          	bne	a5,a4,80005848 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056dc:	100017b7          	lui	a5,0x10001
    800056e0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    800056e2:	439c                	lw	a5,0(a5)
    800056e4:	2781                	sext.w	a5,a5
    800056e6:	16e79163          	bne	a5,a4,80005848 <virtio_disk_init+0x1b0>
      *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551) {
    800056ea:	100017b7          	lui	a5,0x10001
    800056ee:	47d8                	lw	a4,12(a5)
    800056f0:	2701                	sext.w	a4,a4
      *R(VIRTIO_MMIO_VERSION) != 2 || *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800056f2:	554d47b7          	lui	a5,0x554d4
    800056f6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800056fa:	14f71763          	bne	a4,a5,80005848 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    800056fe:	100017b7          	lui	a5,0x10001
    80005702:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005706:	4705                	li	a4,1
    80005708:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000570a:	470d                	li	a4,3
    8000570c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000570e:	10001737          	lui	a4,0x10001
    80005712:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005714:	c7ffe737          	lui	a4,0xc7ffe
    80005718:	55f70713          	addi	a4,a4,1375 # ffffffffc7ffe55f <end+0xffffffff47fdb9ef>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000571c:	8ef9                	and	a3,a3,a4
    8000571e:	10001737          	lui	a4,0x10001
    80005722:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005724:	472d                	li	a4,11
    80005726:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005728:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    8000572c:	439c                	lw	a5,0(a5)
    8000572e:	0007891b          	sext.w	s2,a5
  if (!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005732:	8ba1                	andi	a5,a5,8
    80005734:	12078063          	beqz	a5,80005854 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005738:	100017b7          	lui	a5,0x10001
    8000573c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if (*R(VIRTIO_MMIO_QUEUE_READY))
    80005740:	100017b7          	lui	a5,0x10001
    80005744:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005748:	439c                	lw	a5,0(a5)
    8000574a:	2781                	sext.w	a5,a5
    8000574c:	10079a63          	bnez	a5,80005860 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005750:	100017b7          	lui	a5,0x10001
    80005754:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005758:	439c                	lw	a5,0(a5)
    8000575a:	2781                	sext.w	a5,a5
  if (max == 0)
    8000575c:	10078863          	beqz	a5,8000586c <virtio_disk_init+0x1d4>
  if (max < NUM)
    80005760:	471d                	li	a4,7
    80005762:	10f77b63          	bgeu	a4,a5,80005878 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005766:	b64fb0ef          	jal	80000aca <kalloc>
    8000576a:	0001d497          	auipc	s1,0x1d
    8000576e:	2c648493          	addi	s1,s1,710 # 80022a30 <disk>
    80005772:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005774:	b56fb0ef          	jal	80000aca <kalloc>
    80005778:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000577a:	b50fb0ef          	jal	80000aca <kalloc>
    8000577e:	87aa                	mv	a5,a0
    80005780:	e888                	sd	a0,16(s1)
  if (!disk.desc || !disk.avail || !disk.used)
    80005782:	6088                	ld	a0,0(s1)
    80005784:	10050063          	beqz	a0,80005884 <virtio_disk_init+0x1ec>
    80005788:	0001d717          	auipc	a4,0x1d
    8000578c:	2b073703          	ld	a4,688(a4) # 80022a38 <disk+0x8>
    80005790:	0e070a63          	beqz	a4,80005884 <virtio_disk_init+0x1ec>
    80005794:	0e078863          	beqz	a5,80005884 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005798:	6605                	lui	a2,0x1
    8000579a:	4581                	li	a1,0
    8000579c:	cb8fb0ef          	jal	80000c54 <memset>
  memset(disk.avail, 0, PGSIZE);
    800057a0:	0001d497          	auipc	s1,0x1d
    800057a4:	29048493          	addi	s1,s1,656 # 80022a30 <disk>
    800057a8:	6605                	lui	a2,0x1
    800057aa:	4581                	li	a1,0
    800057ac:	6488                	ld	a0,8(s1)
    800057ae:	ca6fb0ef          	jal	80000c54 <memset>
  memset(disk.used, 0, PGSIZE);
    800057b2:	6605                	lui	a2,0x1
    800057b4:	4581                	li	a1,0
    800057b6:	6888                	ld	a0,16(s1)
    800057b8:	c9cfb0ef          	jal	80000c54 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800057bc:	100017b7          	lui	a5,0x10001
    800057c0:	4721                	li	a4,8
    800057c2:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800057c4:	4098                	lw	a4,0(s1)
    800057c6:	100017b7          	lui	a5,0x10001
    800057ca:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    800057ce:	40d8                	lw	a4,4(s1)
    800057d0:	100017b7          	lui	a5,0x10001
    800057d4:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    800057d8:	649c                	ld	a5,8(s1)
    800057da:	0007869b          	sext.w	a3,a5
    800057de:	10001737          	lui	a4,0x10001
    800057e2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800057e6:	9781                	srai	a5,a5,0x20
    800057e8:	10001737          	lui	a4,0x10001
    800057ec:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800057f0:	689c                	ld	a5,16(s1)
    800057f2:	0007869b          	sext.w	a3,a5
    800057f6:	10001737          	lui	a4,0x10001
    800057fa:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800057fe:	9781                	srai	a5,a5,0x20
    80005800:	10001737          	lui	a4,0x10001
    80005804:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005808:	10001737          	lui	a4,0x10001
    8000580c:	4785                	li	a5,1
    8000580e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005810:	00f48c23          	sb	a5,24(s1)
    80005814:	00f48ca3          	sb	a5,25(s1)
    80005818:	00f48d23          	sb	a5,26(s1)
    8000581c:	00f48da3          	sb	a5,27(s1)
    80005820:	00f48e23          	sb	a5,28(s1)
    80005824:	00f48ea3          	sb	a5,29(s1)
    80005828:	00f48f23          	sb	a5,30(s1)
    8000582c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005830:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005834:	100017b7          	lui	a5,0x10001
    80005838:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    8000583c:	60e2                	ld	ra,24(sp)
    8000583e:	6442                	ld	s0,16(sp)
    80005840:	64a2                	ld	s1,8(sp)
    80005842:	6902                	ld	s2,0(sp)
    80005844:	6105                	addi	sp,sp,32
    80005846:	8082                	ret
    panic("could not find virtio disk");
    80005848:	00002517          	auipc	a0,0x2
    8000584c:	e1850513          	addi	a0,a0,-488 # 80007660 <etext+0x660>
    80005850:	fa1fa0ef          	jal	800007f0 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005854:	00002517          	auipc	a0,0x2
    80005858:	e2c50513          	addi	a0,a0,-468 # 80007680 <etext+0x680>
    8000585c:	f95fa0ef          	jal	800007f0 <panic>
    panic("virtio disk should not be ready");
    80005860:	00002517          	auipc	a0,0x2
    80005864:	e4050513          	addi	a0,a0,-448 # 800076a0 <etext+0x6a0>
    80005868:	f89fa0ef          	jal	800007f0 <panic>
    panic("virtio disk has no queue 0");
    8000586c:	00002517          	auipc	a0,0x2
    80005870:	e5450513          	addi	a0,a0,-428 # 800076c0 <etext+0x6c0>
    80005874:	f7dfa0ef          	jal	800007f0 <panic>
    panic("virtio disk max queue too short");
    80005878:	00002517          	auipc	a0,0x2
    8000587c:	e6850513          	addi	a0,a0,-408 # 800076e0 <etext+0x6e0>
    80005880:	f71fa0ef          	jal	800007f0 <panic>
    panic("virtio disk kalloc");
    80005884:	00002517          	auipc	a0,0x2
    80005888:	e7c50513          	addi	a0,a0,-388 # 80007700 <etext+0x700>
    8000588c:	f65fa0ef          	jal	800007f0 <panic>

0000000080005890 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005890:	7159                	addi	sp,sp,-112
    80005892:	f486                	sd	ra,104(sp)
    80005894:	f0a2                	sd	s0,96(sp)
    80005896:	eca6                	sd	s1,88(sp)
    80005898:	e8ca                	sd	s2,80(sp)
    8000589a:	e4ce                	sd	s3,72(sp)
    8000589c:	e0d2                	sd	s4,64(sp)
    8000589e:	fc56                	sd	s5,56(sp)
    800058a0:	f85a                	sd	s6,48(sp)
    800058a2:	f45e                	sd	s7,40(sp)
    800058a4:	f062                	sd	s8,32(sp)
    800058a6:	ec66                	sd	s9,24(sp)
    800058a8:	1880                	addi	s0,sp,112
    800058aa:	8a2a                	mv	s4,a0
    800058ac:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800058ae:	00c52c83          	lw	s9,12(a0)
    800058b2:	001c9c9b          	slliw	s9,s9,0x1
    800058b6:	1c82                	slli	s9,s9,0x20
    800058b8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800058bc:	0001d517          	auipc	a0,0x1d
    800058c0:	29c50513          	addi	a0,a0,668 # 80022b58 <disk+0x128>
    800058c4:	accfb0ef          	jal	80000b90 <acquire>
  for (int i = 0; i < 3; i++) {
    800058c8:	4981                	li	s3,0
  for (int i = 0; i < NUM; i++) {
    800058ca:	44a1                	li	s1,8
      disk.free[i] = 0;
    800058cc:	0001db17          	auipc	s6,0x1d
    800058d0:	164b0b13          	addi	s6,s6,356 # 80022a30 <disk>
  for (int i = 0; i < 3; i++) {
    800058d4:	4a8d                	li	s5,3
  int idx[3];
  while (1) {
    if (alloc3_desc(idx) == 0) {
      break;
    }
    sleep_prepare(&disk.free[0]);
    800058d6:	0001dc17          	auipc	s8,0x1d
    800058da:	172c0c13          	addi	s8,s8,370 # 80022a48 <disk+0x18>
    800058de:	a0bd                	j	8000594c <virtio_disk_rw+0xbc>
      disk.free[i] = 0;
    800058e0:	00fb0733          	add	a4,s6,a5
    800058e4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800058e8:	c19c                	sw	a5,0(a1)
    if (idx[i] < 0) {
    800058ea:	0207c563          	bltz	a5,80005914 <virtio_disk_rw+0x84>
  for (int i = 0; i < 3; i++) {
    800058ee:	2905                	addiw	s2,s2,1
    800058f0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800058f2:	07590163          	beq	s2,s5,80005954 <virtio_disk_rw+0xc4>
    idx[i] = alloc_desc();
    800058f6:	85b2                	mv	a1,a2
  for (int i = 0; i < NUM; i++) {
    800058f8:	0001d717          	auipc	a4,0x1d
    800058fc:	13870713          	addi	a4,a4,312 # 80022a30 <disk>
    80005900:	87ce                	mv	a5,s3
    if (disk.free[i]) {
    80005902:	01874683          	lbu	a3,24(a4)
    80005906:	fee9                	bnez	a3,800058e0 <virtio_disk_rw+0x50>
  for (int i = 0; i < NUM; i++) {
    80005908:	2785                	addiw	a5,a5,1
    8000590a:	0705                	addi	a4,a4,1
    8000590c:	fe979be3          	bne	a5,s1,80005902 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005910:	57fd                	li	a5,-1
    80005912:	c19c                	sw	a5,0(a1)
      for (int j = 0; j < i; j++)
    80005914:	01205d63          	blez	s2,8000592e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005918:	f9042503          	lw	a0,-112(s0)
    8000591c:	d07ff0ef          	jal	80005622 <free_desc>
      for (int j = 0; j < i; j++)
    80005920:	4785                	li	a5,1
    80005922:	0127d663          	bge	a5,s2,8000592e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005926:	f9442503          	lw	a0,-108(s0)
    8000592a:	cf9ff0ef          	jal	80005622 <free_desc>
    sleep_prepare(&disk.free[0]);
    8000592e:	8562                	mv	a0,s8
    80005930:	d86fc0ef          	jal	80001eb6 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005934:	0001d917          	auipc	s2,0x1d
    80005938:	22490913          	addi	s2,s2,548 # 80022b58 <disk+0x128>
    8000593c:	854a                	mv	a0,s2
    8000593e:	adefb0ef          	jal	80000c1c <release>
    sleep();
    80005942:	db0fc0ef          	jal	80001ef2 <sleep>
    acquire(&disk.vdisk_lock);
    80005946:	854a                	mv	a0,s2
    80005948:	a48fb0ef          	jal	80000b90 <acquire>
  for (int i = 0; i < 3; i++) {
    8000594c:	f9040613          	addi	a2,s0,-112
    80005950:	894e                	mv	s2,s3
    80005952:	b755                	j	800058f6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005954:	f9042503          	lw	a0,-112(s0)
    80005958:	00451693          	slli	a3,a0,0x4

  if (write)
    8000595c:	0001d797          	auipc	a5,0x1d
    80005960:	0d478793          	addi	a5,a5,212 # 80022a30 <disk>
    80005964:	00a50713          	addi	a4,a0,10
    80005968:	0712                	slli	a4,a4,0x4
    8000596a:	973e                	add	a4,a4,a5
    8000596c:	01703633          	snez	a2,s7
    80005970:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005972:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005976:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64)buf0;
    8000597a:	6398                	ld	a4,0(a5)
    8000597c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000597e:	0a868613          	addi	a2,a3,168
    80005982:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64)buf0;
    80005984:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005986:	6390                	ld	a2,0(a5)
    80005988:	00d605b3          	add	a1,a2,a3
    8000598c:	4741                	li	a4,16
    8000598e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005990:	4805                	li	a6,1
    80005992:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005996:	f9442703          	lw	a4,-108(s0)
    8000599a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64)b->data;
    8000599e:	0712                	slli	a4,a4,0x4
    800059a0:	963a                	add	a2,a2,a4
    800059a2:	058a0593          	addi	a1,s4,88
    800059a6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800059a8:	0007b883          	ld	a7,0(a5)
    800059ac:	9746                	add	a4,a4,a7
    800059ae:	40000613          	li	a2,1024
    800059b2:	c710                	sw	a2,8(a4)
  if (write)
    800059b4:	001bb613          	seqz	a2,s7
    800059b8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800059bc:	00166613          	ori	a2,a2,1
    800059c0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800059c4:	f9842583          	lw	a1,-104(s0)
    800059c8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800059cc:	00250613          	addi	a2,a0,2
    800059d0:	0612                	slli	a2,a2,0x4
    800059d2:	963e                	add	a2,a2,a5
    800059d4:	577d                	li	a4,-1
    800059d6:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64)&disk.info[idx[0]].status;
    800059da:	0592                	slli	a1,a1,0x4
    800059dc:	98ae                	add	a7,a7,a1
    800059de:	03068713          	addi	a4,a3,48
    800059e2:	973e                	add	a4,a4,a5
    800059e4:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800059e8:	6398                	ld	a4,0(a5)
    800059ea:	972e                	add	a4,a4,a1
    800059ec:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800059f0:	4689                	li	a3,2
    800059f2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800059f6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800059fa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800059fe:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005a02:	6794                	ld	a3,8(a5)
    80005a04:	0026d703          	lhu	a4,2(a3)
    80005a08:	8b1d                	andi	a4,a4,7
    80005a0a:	0706                	slli	a4,a4,0x1
    80005a0c:	96ba                	add	a3,a3,a4
    80005a0e:	00a69223          	sh	a0,4(a3)

// fence for memory-mapped IO
static inline void
io_fence()
{
  asm volatile("fence iorw, iorw" ::: "memory");
    80005a12:	0ff0000f          	fence

  io_fence();

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005a16:	6798                	ld	a4,8(a5)
    80005a18:	00275783          	lhu	a5,2(a4)
    80005a1c:	2785                	addiw	a5,a5,1
    80005a1e:	00f71123          	sh	a5,2(a4)
    80005a22:	0ff0000f          	fence

  io_fence();

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005a26:	100017b7          	lui	a5,0x10001
    80005a2a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while (b->disk == 1) {
    80005a2e:	004a2783          	lw	a5,4(s4)
    sleep_prepare(b);
    release(&disk.vdisk_lock);
    80005a32:	0001d497          	auipc	s1,0x1d
    80005a36:	12648493          	addi	s1,s1,294 # 80022b58 <disk+0x128>
  while (b->disk == 1) {
    80005a3a:	4905                	li	s2,1
    80005a3c:	03079163          	bne	a5,a6,80005a5e <virtio_disk_rw+0x1ce>
    sleep_prepare(b);
    80005a40:	8552                	mv	a0,s4
    80005a42:	c74fc0ef          	jal	80001eb6 <sleep_prepare>
    release(&disk.vdisk_lock);
    80005a46:	8526                	mv	a0,s1
    80005a48:	9d4fb0ef          	jal	80000c1c <release>
    sleep();
    80005a4c:	ca6fc0ef          	jal	80001ef2 <sleep>
    acquire(&disk.vdisk_lock);
    80005a50:	8526                	mv	a0,s1
    80005a52:	93efb0ef          	jal	80000b90 <acquire>
  while (b->disk == 1) {
    80005a56:	004a2783          	lw	a5,4(s4)
    80005a5a:	ff2783e3          	beq	a5,s2,80005a40 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80005a5e:	f9042903          	lw	s2,-112(s0)
    80005a62:	00290713          	addi	a4,s2,2
    80005a66:	0712                	slli	a4,a4,0x4
    80005a68:	0001d797          	auipc	a5,0x1d
    80005a6c:	fc878793          	addi	a5,a5,-56 # 80022a30 <disk>
    80005a70:	97ba                	add	a5,a5,a4
    80005a72:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005a76:	0001d997          	auipc	s3,0x1d
    80005a7a:	fba98993          	addi	s3,s3,-70 # 80022a30 <disk>
    80005a7e:	00491713          	slli	a4,s2,0x4
    80005a82:	0009b783          	ld	a5,0(s3)
    80005a86:	97ba                	add	a5,a5,a4
    80005a88:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005a8c:	854a                	mv	a0,s2
    80005a8e:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005a92:	b91ff0ef          	jal	80005622 <free_desc>
    if (flag & VRING_DESC_F_NEXT)
    80005a96:	8885                	andi	s1,s1,1
    80005a98:	f0fd                	bnez	s1,80005a7e <virtio_disk_rw+0x1ee>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005a9a:	0001d517          	auipc	a0,0x1d
    80005a9e:	0be50513          	addi	a0,a0,190 # 80022b58 <disk+0x128>
    80005aa2:	97afb0ef          	jal	80000c1c <release>
}
    80005aa6:	70a6                	ld	ra,104(sp)
    80005aa8:	7406                	ld	s0,96(sp)
    80005aaa:	64e6                	ld	s1,88(sp)
    80005aac:	6946                	ld	s2,80(sp)
    80005aae:	69a6                	ld	s3,72(sp)
    80005ab0:	6a06                	ld	s4,64(sp)
    80005ab2:	7ae2                	ld	s5,56(sp)
    80005ab4:	7b42                	ld	s6,48(sp)
    80005ab6:	7ba2                	ld	s7,40(sp)
    80005ab8:	7c02                	ld	s8,32(sp)
    80005aba:	6ce2                	ld	s9,24(sp)
    80005abc:	6165                	addi	sp,sp,112
    80005abe:	8082                	ret

0000000080005ac0 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ac0:	1101                	addi	sp,sp,-32
    80005ac2:	ec06                	sd	ra,24(sp)
    80005ac4:	e822                	sd	s0,16(sp)
    80005ac6:	e426                	sd	s1,8(sp)
    80005ac8:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005aca:	0001d497          	auipc	s1,0x1d
    80005ace:	f6648493          	addi	s1,s1,-154 # 80022a30 <disk>
    80005ad2:	0001d517          	auipc	a0,0x1d
    80005ad6:	08650513          	addi	a0,a0,134 # 80022b58 <disk+0x128>
    80005ada:	8b6fb0ef          	jal	80000b90 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ade:	100017b7          	lui	a5,0x10001
    80005ae2:	53b8                	lw	a4,96(a5)
    80005ae4:	8b0d                	andi	a4,a4,3
    80005ae6:	100017b7          	lui	a5,0x10001
    80005aea:	d3f8                	sw	a4,100(a5)
    80005aec:	0ff0000f          	fence
  io_fence();

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while (disk.used_idx != disk.used->idx) {
    80005af0:	689c                	ld	a5,16(s1)
    80005af2:	0204d703          	lhu	a4,32(s1)
    80005af6:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005afa:	04f70663          	beq	a4,a5,80005b46 <virtio_disk_intr+0x86>
    80005afe:	0ff0000f          	fence
    io_fence();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005b02:	6898                	ld	a4,16(s1)
    80005b04:	0204d783          	lhu	a5,32(s1)
    80005b08:	8b9d                	andi	a5,a5,7
    80005b0a:	078e                	slli	a5,a5,0x3
    80005b0c:	97ba                	add	a5,a5,a4
    80005b0e:	43dc                	lw	a5,4(a5)

    if (disk.info[id].status != 0)
    80005b10:	00278713          	addi	a4,a5,2
    80005b14:	0712                	slli	a4,a4,0x4
    80005b16:	9726                	add	a4,a4,s1
    80005b18:	01074703          	lbu	a4,16(a4)
    80005b1c:	e321                	bnez	a4,80005b5c <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005b1e:	0789                	addi	a5,a5,2
    80005b20:	0792                	slli	a5,a5,0x4
    80005b22:	97a6                	add	a5,a5,s1
    80005b24:	6788                	ld	a0,8(a5)
    b->disk = 0; // disk is done with buf
    80005b26:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005b2a:	bf8fc0ef          	jal	80001f22 <wakeup>

    disk.used_idx += 1;
    80005b2e:	0204d783          	lhu	a5,32(s1)
    80005b32:	2785                	addiw	a5,a5,1
    80005b34:	17c2                	slli	a5,a5,0x30
    80005b36:	93c1                	srli	a5,a5,0x30
    80005b38:	02f49023          	sh	a5,32(s1)
  while (disk.used_idx != disk.used->idx) {
    80005b3c:	6898                	ld	a4,16(s1)
    80005b3e:	00275703          	lhu	a4,2(a4)
    80005b42:	faf71ee3          	bne	a4,a5,80005afe <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005b46:	0001d517          	auipc	a0,0x1d
    80005b4a:	01250513          	addi	a0,a0,18 # 80022b58 <disk+0x128>
    80005b4e:	8cefb0ef          	jal	80000c1c <release>
}
    80005b52:	60e2                	ld	ra,24(sp)
    80005b54:	6442                	ld	s0,16(sp)
    80005b56:	64a2                	ld	s1,8(sp)
    80005b58:	6105                	addi	sp,sp,32
    80005b5a:	8082                	ret
      panic("virtio_disk_intr status");
    80005b5c:	00002517          	auipc	a0,0x2
    80005b60:	bbc50513          	addi	a0,a0,-1092 # 80007718 <etext+0x718>
    80005b64:	c8dfa0ef          	jal	800007f0 <panic>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	0000100f          	fence.i
    800060a0:	12000073          	sfence.vma
    800060a4:	18051073          	csrw	satp,a0
    800060a8:	12000073          	sfence.vma
    800060ac:	02000537          	lui	a0,0x2000
    800060b0:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060b2:	0536                	slli	a0,a0,0xd
    800060b4:	02853083          	ld	ra,40(a0)
    800060b8:	03053103          	ld	sp,48(a0)
    800060bc:	03853183          	ld	gp,56(a0)
    800060c0:	04053203          	ld	tp,64(a0)
    800060c4:	04853283          	ld	t0,72(a0)
    800060c8:	05053303          	ld	t1,80(a0)
    800060cc:	05853383          	ld	t2,88(a0)
    800060d0:	7120                	ld	s0,96(a0)
    800060d2:	7524                	ld	s1,104(a0)
    800060d4:	7d2c                	ld	a1,120(a0)
    800060d6:	6150                	ld	a2,128(a0)
    800060d8:	6554                	ld	a3,136(a0)
    800060da:	6958                	ld	a4,144(a0)
    800060dc:	6d5c                	ld	a5,152(a0)
    800060de:	0a053803          	ld	a6,160(a0)
    800060e2:	0a853883          	ld	a7,168(a0)
    800060e6:	0b053903          	ld	s2,176(a0)
    800060ea:	0b853983          	ld	s3,184(a0)
    800060ee:	0c053a03          	ld	s4,192(a0)
    800060f2:	0c853a83          	ld	s5,200(a0)
    800060f6:	0d053b03          	ld	s6,208(a0)
    800060fa:	0d853b83          	ld	s7,216(a0)
    800060fe:	0e053c03          	ld	s8,224(a0)
    80006102:	0e853c83          	ld	s9,232(a0)
    80006106:	0f053d03          	ld	s10,240(a0)
    8000610a:	0f853d83          	ld	s11,248(a0)
    8000610e:	10053e03          	ld	t3,256(a0)
    80006112:	10853e83          	ld	t4,264(a0)
    80006116:	11053f03          	ld	t5,272(a0)
    8000611a:	11853f83          	ld	t6,280(a0)
    8000611e:	7928                	ld	a0,112(a0)
    80006120:	10200073          	sret
	...
