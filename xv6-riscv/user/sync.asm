
user/_sync:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
  sync();
   8:	33e000ef          	jal	346 <sync>
  exit(0);
   c:	4501                	li	a0,0
   e:	298000ef          	jal	2a6 <exit>

0000000000000012 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  12:	1141                	addi	sp,sp,-16
  14:	e406                	sd	ra,8(sp)
  16:	e022                	sd	s0,0(sp)
  18:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  1a:	fe7ff0ef          	jal	0 <main>
  exit(r);
  1e:	288000ef          	jal	2a6 <exit>

0000000000000022 <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  22:	1141                	addi	sp,sp,-16
  24:	e422                	sd	s0,8(sp)
  26:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  28:	87aa                	mv	a5,a0
  2a:	0585                	addi	a1,a1,1
  2c:	0785                	addi	a5,a5,1
  2e:	fff5c703          	lbu	a4,-1(a1)
  32:	fee78fa3          	sb	a4,-1(a5)
  36:	fb75                	bnez	a4,2a <strcpy+0x8>
    ;
  return os;
}
  38:	6422                	ld	s0,8(sp)
  3a:	0141                	addi	sp,sp,16
  3c:	8082                	ret

000000000000003e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  3e:	1141                	addi	sp,sp,-16
  40:	e422                	sd	s0,8(sp)
  42:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  44:	00054783          	lbu	a5,0(a0)
  48:	cb91                	beqz	a5,5c <strcmp+0x1e>
  4a:	0005c703          	lbu	a4,0(a1)
  4e:	00f71763          	bne	a4,a5,5c <strcmp+0x1e>
    p++, q++;
  52:	0505                	addi	a0,a0,1
  54:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  56:	00054783          	lbu	a5,0(a0)
  5a:	fbe5                	bnez	a5,4a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  5c:	0005c503          	lbu	a0,0(a1)
}
  60:	40a7853b          	subw	a0,a5,a0
  64:	6422                	ld	s0,8(sp)
  66:	0141                	addi	sp,sp,16
  68:	8082                	ret

000000000000006a <strlen>:

uint
strlen(const char *s)
{
  6a:	1141                	addi	sp,sp,-16
  6c:	e422                	sd	s0,8(sp)
  6e:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
  70:	00054783          	lbu	a5,0(a0)
  74:	cf91                	beqz	a5,90 <strlen+0x26>
  76:	0505                	addi	a0,a0,1
  78:	87aa                	mv	a5,a0
  7a:	86be                	mv	a3,a5
  7c:	0785                	addi	a5,a5,1
  7e:	fff7c703          	lbu	a4,-1(a5)
  82:	ff65                	bnez	a4,7a <strlen+0x10>
  84:	40a6853b          	subw	a0,a3,a0
  88:	2505                	addiw	a0,a0,1
    ;
  return n;
}
  8a:	6422                	ld	s0,8(sp)
  8c:	0141                	addi	sp,sp,16
  8e:	8082                	ret
  for (n = 0; s[n]; n++)
  90:	4501                	li	a0,0
  92:	bfe5                	j	8a <strlen+0x20>

0000000000000094 <memset>:

void *
memset(void *dst, int c, uint n)
{
  94:	1141                	addi	sp,sp,-16
  96:	e422                	sd	s0,8(sp)
  98:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
  9a:	ca19                	beqz	a2,b0 <memset+0x1c>
  9c:	87aa                	mv	a5,a0
  9e:	1602                	slli	a2,a2,0x20
  a0:	9201                	srli	a2,a2,0x20
  a2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  a6:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
  aa:	0785                	addi	a5,a5,1
  ac:	fee79de3          	bne	a5,a4,a6 <memset+0x12>
  }
  return dst;
}
  b0:	6422                	ld	s0,8(sp)
  b2:	0141                	addi	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <strchr>:

char *
strchr(const char *s, char c)
{
  b6:	1141                	addi	sp,sp,-16
  b8:	e422                	sd	s0,8(sp)
  ba:	0800                	addi	s0,sp,16
  for (; *s; s++)
  bc:	00054783          	lbu	a5,0(a0)
  c0:	cb99                	beqz	a5,d6 <strchr+0x20>
    if (*s == c)
  c2:	00f58763          	beq	a1,a5,d0 <strchr+0x1a>
  for (; *s; s++)
  c6:	0505                	addi	a0,a0,1
  c8:	00054783          	lbu	a5,0(a0)
  cc:	fbfd                	bnez	a5,c2 <strchr+0xc>
      return (char *)s;
  return 0;
  ce:	4501                	li	a0,0
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret
  return 0;
  d6:	4501                	li	a0,0
  d8:	bfe5                	j	d0 <strchr+0x1a>

00000000000000da <gets>:

char *
gets(char *buf, int max)
{
  da:	711d                	addi	sp,sp,-96
  dc:	ec86                	sd	ra,88(sp)
  de:	e8a2                	sd	s0,80(sp)
  e0:	e4a6                	sd	s1,72(sp)
  e2:	e0ca                	sd	s2,64(sp)
  e4:	fc4e                	sd	s3,56(sp)
  e6:	f852                	sd	s4,48(sp)
  e8:	f456                	sd	s5,40(sp)
  ea:	f05a                	sd	s6,32(sp)
  ec:	ec5e                	sd	s7,24(sp)
  ee:	1080                	addi	s0,sp,96
  f0:	8baa                	mv	s7,a0
  f2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
  f4:	892a                	mv	s2,a0
  f6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
  f8:	4aa9                	li	s5,10
  fa:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
  fc:	89a6                	mv	s3,s1
  fe:	2485                	addiw	s1,s1,1
 100:	0344d663          	bge	s1,s4,12c <gets+0x52>
    cc = read(0, &c, 1);
 104:	4605                	li	a2,1
 106:	faf40593          	addi	a1,s0,-81
 10a:	4501                	li	a0,0
 10c:	1b2000ef          	jal	2be <read>
    if (cc < 1)
 110:	00a05e63          	blez	a0,12c <gets+0x52>
    buf[i++] = c;
 114:	faf44783          	lbu	a5,-81(s0)
 118:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 11c:	01578763          	beq	a5,s5,12a <gets+0x50>
 120:	0905                	addi	s2,s2,1
 122:	fd679de3          	bne	a5,s6,fc <gets+0x22>
    buf[i++] = c;
 126:	89a6                	mv	s3,s1
 128:	a011                	j	12c <gets+0x52>
 12a:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 12c:	99de                	add	s3,s3,s7
 12e:	00098023          	sb	zero,0(s3)
  return buf;
}
 132:	855e                	mv	a0,s7
 134:	60e6                	ld	ra,88(sp)
 136:	6446                	ld	s0,80(sp)
 138:	64a6                	ld	s1,72(sp)
 13a:	6906                	ld	s2,64(sp)
 13c:	79e2                	ld	s3,56(sp)
 13e:	7a42                	ld	s4,48(sp)
 140:	7aa2                	ld	s5,40(sp)
 142:	7b02                	ld	s6,32(sp)
 144:	6be2                	ld	s7,24(sp)
 146:	6125                	addi	sp,sp,96
 148:	8082                	ret

000000000000014a <stat>:

int
stat(const char *n, struct stat *st)
{
 14a:	1101                	addi	sp,sp,-32
 14c:	ec06                	sd	ra,24(sp)
 14e:	e822                	sd	s0,16(sp)
 150:	e04a                	sd	s2,0(sp)
 152:	1000                	addi	s0,sp,32
 154:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 156:	4581                	li	a1,0
 158:	18e000ef          	jal	2e6 <open>
  if (fd < 0)
 15c:	02054263          	bltz	a0,180 <stat+0x36>
 160:	e426                	sd	s1,8(sp)
 162:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 164:	85ca                	mv	a1,s2
 166:	198000ef          	jal	2fe <fstat>
 16a:	892a                	mv	s2,a0
  close(fd);
 16c:	8526                	mv	a0,s1
 16e:	160000ef          	jal	2ce <close>
  return r;
 172:	64a2                	ld	s1,8(sp)
}
 174:	854a                	mv	a0,s2
 176:	60e2                	ld	ra,24(sp)
 178:	6442                	ld	s0,16(sp)
 17a:	6902                	ld	s2,0(sp)
 17c:	6105                	addi	sp,sp,32
 17e:	8082                	ret
    return -1;
 180:	597d                	li	s2,-1
 182:	bfcd                	j	174 <stat+0x2a>

0000000000000184 <atoi>:

int
atoi(const char *s)
{
 184:	1141                	addi	sp,sp,-16
 186:	e422                	sd	s0,8(sp)
 188:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 18a:	00054683          	lbu	a3,0(a0)
 18e:	fd06879b          	addiw	a5,a3,-48
 192:	0ff7f793          	zext.b	a5,a5
 196:	4625                	li	a2,9
 198:	02f66863          	bltu	a2,a5,1c8 <atoi+0x44>
 19c:	872a                	mv	a4,a0
  n = 0;
 19e:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 1a0:	0705                	addi	a4,a4,1
 1a2:	0025179b          	slliw	a5,a0,0x2
 1a6:	9fa9                	addw	a5,a5,a0
 1a8:	0017979b          	slliw	a5,a5,0x1
 1ac:	9fb5                	addw	a5,a5,a3
 1ae:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 1b2:	00074683          	lbu	a3,0(a4)
 1b6:	fd06879b          	addiw	a5,a3,-48
 1ba:	0ff7f793          	zext.b	a5,a5
 1be:	fef671e3          	bgeu	a2,a5,1a0 <atoi+0x1c>
  return n;
}
 1c2:	6422                	ld	s0,8(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret
  n = 0;
 1c8:	4501                	li	a0,0
 1ca:	bfe5                	j	1c2 <atoi+0x3e>

00000000000001cc <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 1cc:	1141                	addi	sp,sp,-16
 1ce:	e422                	sd	s0,8(sp)
 1d0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1d2:	02b57463          	bgeu	a0,a1,1fa <memmove+0x2e>
    while (n-- > 0)
 1d6:	00c05f63          	blez	a2,1f4 <memmove+0x28>
 1da:	1602                	slli	a2,a2,0x20
 1dc:	9201                	srli	a2,a2,0x20
 1de:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 1e2:	872a                	mv	a4,a0
      *dst++ = *src++;
 1e4:	0585                	addi	a1,a1,1
 1e6:	0705                	addi	a4,a4,1
 1e8:	fff5c683          	lbu	a3,-1(a1)
 1ec:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 1f0:	fef71ae3          	bne	a4,a5,1e4 <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 1f4:	6422                	ld	s0,8(sp)
 1f6:	0141                	addi	sp,sp,16
 1f8:	8082                	ret
    dst += n;
 1fa:	00c50733          	add	a4,a0,a2
    src += n;
 1fe:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 200:	fec05ae3          	blez	a2,1f4 <memmove+0x28>
 204:	fff6079b          	addiw	a5,a2,-1
 208:	1782                	slli	a5,a5,0x20
 20a:	9381                	srli	a5,a5,0x20
 20c:	fff7c793          	not	a5,a5
 210:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 212:	15fd                	addi	a1,a1,-1
 214:	177d                	addi	a4,a4,-1
 216:	0005c683          	lbu	a3,0(a1)
 21a:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 21e:	fee79ae3          	bne	a5,a4,212 <memmove+0x46>
 222:	bfc9                	j	1f4 <memmove+0x28>

0000000000000224 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 224:	1141                	addi	sp,sp,-16
 226:	e422                	sd	s0,8(sp)
 228:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 22a:	ca05                	beqz	a2,25a <memcmp+0x36>
 22c:	fff6069b          	addiw	a3,a2,-1
 230:	1682                	slli	a3,a3,0x20
 232:	9281                	srli	a3,a3,0x20
 234:	0685                	addi	a3,a3,1
 236:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 238:	00054783          	lbu	a5,0(a0)
 23c:	0005c703          	lbu	a4,0(a1)
 240:	00e79863          	bne	a5,a4,250 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 244:	0505                	addi	a0,a0,1
    p2++;
 246:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 248:	fed518e3          	bne	a0,a3,238 <memcmp+0x14>
  }
  return 0;
 24c:	4501                	li	a0,0
 24e:	a019                	j	254 <memcmp+0x30>
      return *p1 - *p2;
 250:	40e7853b          	subw	a0,a5,a4
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
  return 0;
 25a:	4501                	li	a0,0
 25c:	bfe5                	j	254 <memcmp+0x30>

000000000000025e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e406                	sd	ra,8(sp)
 262:	e022                	sd	s0,0(sp)
 264:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 266:	f67ff0ef          	jal	1cc <memmove>
}
 26a:	60a2                	ld	ra,8(sp)
 26c:	6402                	ld	s0,0(sp)
 26e:	0141                	addi	sp,sp,16
 270:	8082                	ret

0000000000000272 <sbrk>:

char *
sbrk(int n)
{
 272:	1141                	addi	sp,sp,-16
 274:	e406                	sd	ra,8(sp)
 276:	e022                	sd	s0,0(sp)
 278:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 27a:	4585                	li	a1,1
 27c:	0b2000ef          	jal	32e <sys_sbrk>
}
 280:	60a2                	ld	ra,8(sp)
 282:	6402                	ld	s0,0(sp)
 284:	0141                	addi	sp,sp,16
 286:	8082                	ret

0000000000000288 <sbrklazy>:

char *
sbrklazy(int n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e406                	sd	ra,8(sp)
 28c:	e022                	sd	s0,0(sp)
 28e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 290:	4589                	li	a1,2
 292:	09c000ef          	jal	32e <sys_sbrk>
}
 296:	60a2                	ld	ra,8(sp)
 298:	6402                	ld	s0,0(sp)
 29a:	0141                	addi	sp,sp,16
 29c:	8082                	ret

000000000000029e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 29e:	4885                	li	a7,1
 ecall
 2a0:	00000073          	ecall
 ret
 2a4:	8082                	ret

00000000000002a6 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2a6:	4889                	li	a7,2
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <wait>:
.global wait
wait:
 li a7, SYS_wait
 2ae:	488d                	li	a7,3
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2b6:	4891                	li	a7,4
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <read>:
.global read
read:
 li a7, SYS_read
 2be:	4895                	li	a7,5
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <write>:
.global write
write:
 li a7, SYS_write
 2c6:	48c1                	li	a7,16
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <close>:
.global close
close:
 li a7, SYS_close
 2ce:	48d5                	li	a7,21
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2d6:	4899                	li	a7,6
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <exec>:
.global exec
exec:
 li a7, SYS_exec
 2de:	489d                	li	a7,7
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <open>:
.global open
open:
 li a7, SYS_open
 2e6:	48bd                	li	a7,15
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2ee:	48c5                	li	a7,17
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2f6:	48c9                	li	a7,18
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2fe:	48a1                	li	a7,8
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <link>:
.global link
link:
 li a7, SYS_link
 306:	48cd                	li	a7,19
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 30e:	48d1                	li	a7,20
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 316:	48a5                	li	a7,9
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <dup>:
.global dup
dup:
 li a7, SYS_dup
 31e:	48a9                	li	a7,10
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 326:	48ad                	li	a7,11
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 32e:	48b1                	li	a7,12
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <pause>:
.global pause
pause:
 li a7, SYS_pause
 336:	48b5                	li	a7,13
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 33e:	48b9                	li	a7,14
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <sync>:
.global sync
sync:
 li a7, SYS_sync
 346:	48d9                	li	a7,22
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 34e:	1101                	addi	sp,sp,-32
 350:	ec06                	sd	ra,24(sp)
 352:	e822                	sd	s0,16(sp)
 354:	1000                	addi	s0,sp,32
 356:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 35a:	4605                	li	a2,1
 35c:	fef40593          	addi	a1,s0,-17
 360:	f67ff0ef          	jal	2c6 <write>
}
 364:	60e2                	ld	ra,24(sp)
 366:	6442                	ld	s0,16(sp)
 368:	6105                	addi	sp,sp,32
 36a:	8082                	ret

000000000000036c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 36c:	715d                	addi	sp,sp,-80
 36e:	e486                	sd	ra,72(sp)
 370:	e0a2                	sd	s0,64(sp)
 372:	f84a                	sd	s2,48(sp)
 374:	0880                	addi	s0,sp,80
 376:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 378:	c299                	beqz	a3,37e <printint+0x12>
 37a:	0805c363          	bltz	a1,400 <printint+0x94>
  neg = 0;
 37e:	4881                	li	a7,0
 380:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 384:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 386:	00000517          	auipc	a0,0x0
 38a:	51250513          	addi	a0,a0,1298 # 898 <digits>
 38e:	883e                	mv	a6,a5
 390:	2785                	addiw	a5,a5,1
 392:	02c5f733          	remu	a4,a1,a2
 396:	972a                	add	a4,a4,a0
 398:	00074703          	lbu	a4,0(a4)
 39c:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 3a0:	872e                	mv	a4,a1
 3a2:	02c5d5b3          	divu	a1,a1,a2
 3a6:	0685                	addi	a3,a3,1
 3a8:	fec773e3          	bgeu	a4,a2,38e <printint+0x22>
  if (neg)
 3ac:	00088b63          	beqz	a7,3c2 <printint+0x56>
    buf[i++] = '-';
 3b0:	fd078793          	addi	a5,a5,-48
 3b4:	97a2                	add	a5,a5,s0
 3b6:	02d00713          	li	a4,45
 3ba:	fee78423          	sb	a4,-24(a5)
 3be:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 3c2:	02f05a63          	blez	a5,3f6 <printint+0x8a>
 3c6:	fc26                	sd	s1,56(sp)
 3c8:	f44e                	sd	s3,40(sp)
 3ca:	fb840713          	addi	a4,s0,-72
 3ce:	00f704b3          	add	s1,a4,a5
 3d2:	fff70993          	addi	s3,a4,-1
 3d6:	99be                	add	s3,s3,a5
 3d8:	37fd                	addiw	a5,a5,-1
 3da:	1782                	slli	a5,a5,0x20
 3dc:	9381                	srli	a5,a5,0x20
 3de:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 3e2:	fff4c583          	lbu	a1,-1(s1)
 3e6:	854a                	mv	a0,s2
 3e8:	f67ff0ef          	jal	34e <putc>
  while (--i >= 0)
 3ec:	14fd                	addi	s1,s1,-1
 3ee:	ff349ae3          	bne	s1,s3,3e2 <printint+0x76>
 3f2:	74e2                	ld	s1,56(sp)
 3f4:	79a2                	ld	s3,40(sp)
}
 3f6:	60a6                	ld	ra,72(sp)
 3f8:	6406                	ld	s0,64(sp)
 3fa:	7942                	ld	s2,48(sp)
 3fc:	6161                	addi	sp,sp,80
 3fe:	8082                	ret
    x = -xx;
 400:	40b005b3          	neg	a1,a1
    neg = 1;
 404:	4885                	li	a7,1
    x = -xx;
 406:	bfad                	j	380 <printint+0x14>

0000000000000408 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 408:	711d                	addi	sp,sp,-96
 40a:	ec86                	sd	ra,88(sp)
 40c:	e8a2                	sd	s0,80(sp)
 40e:	e0ca                	sd	s2,64(sp)
 410:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 412:	0005c903          	lbu	s2,0(a1)
 416:	28090663          	beqz	s2,6a2 <vprintf+0x29a>
 41a:	e4a6                	sd	s1,72(sp)
 41c:	fc4e                	sd	s3,56(sp)
 41e:	f852                	sd	s4,48(sp)
 420:	f456                	sd	s5,40(sp)
 422:	f05a                	sd	s6,32(sp)
 424:	ec5e                	sd	s7,24(sp)
 426:	e862                	sd	s8,16(sp)
 428:	e466                	sd	s9,8(sp)
 42a:	8b2a                	mv	s6,a0
 42c:	8a2e                	mv	s4,a1
 42e:	8bb2                	mv	s7,a2
  state = 0;
 430:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 432:	4481                	li	s1,0
 434:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 436:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 43a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 43e:	06c00c93          	li	s9,108
 442:	a005                	j	462 <vprintf+0x5a>
        putc(fd, c0);
 444:	85ca                	mv	a1,s2
 446:	855a                	mv	a0,s6
 448:	f07ff0ef          	jal	34e <putc>
 44c:	a019                	j	452 <vprintf+0x4a>
    } else if (state == '%') {
 44e:	03598263          	beq	s3,s5,472 <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 452:	2485                	addiw	s1,s1,1
 454:	8726                	mv	a4,s1
 456:	009a07b3          	add	a5,s4,s1
 45a:	0007c903          	lbu	s2,0(a5)
 45e:	22090a63          	beqz	s2,692 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 462:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 466:	fe0994e3          	bnez	s3,44e <vprintf+0x46>
      if (c0 == '%') {
 46a:	fd579de3          	bne	a5,s5,444 <vprintf+0x3c>
        state = '%';
 46e:	89be                	mv	s3,a5
 470:	b7cd                	j	452 <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 472:	00ea06b3          	add	a3,s4,a4
 476:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 47a:	8636                	mv	a2,a3
      if (c1)
 47c:	c681                	beqz	a3,484 <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 47e:	9752                	add	a4,a4,s4
 480:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 484:	05878363          	beq	a5,s8,4ca <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 488:	05978d63          	beq	a5,s9,4e2 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 48c:	07500713          	li	a4,117
 490:	0ee78763          	beq	a5,a4,57e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 494:	07800713          	li	a4,120
 498:	12e78963          	beq	a5,a4,5ca <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 49c:	07000713          	li	a4,112
 4a0:	14e78e63          	beq	a5,a4,5fc <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 4a4:	06300713          	li	a4,99
 4a8:	18e78e63          	beq	a5,a4,644 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 4ac:	07300713          	li	a4,115
 4b0:	1ae78463          	beq	a5,a4,658 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 4b4:	02500713          	li	a4,37
 4b8:	04e79563          	bne	a5,a4,502 <vprintf+0xfa>
        putc(fd, '%');
 4bc:	02500593          	li	a1,37
 4c0:	855a                	mv	a0,s6
 4c2:	e8dff0ef          	jal	34e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 4c6:	4981                	li	s3,0
 4c8:	b769                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 4ca:	008b8913          	addi	s2,s7,8
 4ce:	4685                	li	a3,1
 4d0:	4629                	li	a2,10
 4d2:	000ba583          	lw	a1,0(s7)
 4d6:	855a                	mv	a0,s6
 4d8:	e95ff0ef          	jal	36c <printint>
 4dc:	8bca                	mv	s7,s2
      state = 0;
 4de:	4981                	li	s3,0
 4e0:	bf8d                	j	452 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 4e2:	06400793          	li	a5,100
 4e6:	02f68963          	beq	a3,a5,518 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 4ea:	06c00793          	li	a5,108
 4ee:	04f68263          	beq	a3,a5,532 <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 4f2:	07500793          	li	a5,117
 4f6:	0af68063          	beq	a3,a5,596 <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 4fa:	07800793          	li	a5,120
 4fe:	0ef68263          	beq	a3,a5,5e2 <vprintf+0x1da>
        putc(fd, '%');
 502:	02500593          	li	a1,37
 506:	855a                	mv	a0,s6
 508:	e47ff0ef          	jal	34e <putc>
        putc(fd, c0);
 50c:	85ca                	mv	a1,s2
 50e:	855a                	mv	a0,s6
 510:	e3fff0ef          	jal	34e <putc>
      state = 0;
 514:	4981                	li	s3,0
 516:	bf35                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 518:	008b8913          	addi	s2,s7,8
 51c:	4685                	li	a3,1
 51e:	4629                	li	a2,10
 520:	000bb583          	ld	a1,0(s7)
 524:	855a                	mv	a0,s6
 526:	e47ff0ef          	jal	36c <printint>
        i += 1;
 52a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 52c:	8bca                	mv	s7,s2
      state = 0;
 52e:	4981                	li	s3,0
        i += 1;
 530:	b70d                	j	452 <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 532:	06400793          	li	a5,100
 536:	02f60763          	beq	a2,a5,564 <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 53a:	07500793          	li	a5,117
 53e:	06f60963          	beq	a2,a5,5b0 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 542:	07800793          	li	a5,120
 546:	faf61ee3          	bne	a2,a5,502 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 54a:	008b8913          	addi	s2,s7,8
 54e:	4681                	li	a3,0
 550:	4641                	li	a2,16
 552:	000bb583          	ld	a1,0(s7)
 556:	855a                	mv	a0,s6
 558:	e15ff0ef          	jal	36c <printint>
        i += 2;
 55c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 55e:	8bca                	mv	s7,s2
      state = 0;
 560:	4981                	li	s3,0
        i += 2;
 562:	bdc5                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 564:	008b8913          	addi	s2,s7,8
 568:	4685                	li	a3,1
 56a:	4629                	li	a2,10
 56c:	000bb583          	ld	a1,0(s7)
 570:	855a                	mv	a0,s6
 572:	dfbff0ef          	jal	36c <printint>
        i += 2;
 576:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 578:	8bca                	mv	s7,s2
      state = 0;
 57a:	4981                	li	s3,0
        i += 2;
 57c:	bdd9                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 57e:	008b8913          	addi	s2,s7,8
 582:	4681                	li	a3,0
 584:	4629                	li	a2,10
 586:	000be583          	lwu	a1,0(s7)
 58a:	855a                	mv	a0,s6
 58c:	de1ff0ef          	jal	36c <printint>
 590:	8bca                	mv	s7,s2
      state = 0;
 592:	4981                	li	s3,0
 594:	bd7d                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 596:	008b8913          	addi	s2,s7,8
 59a:	4681                	li	a3,0
 59c:	4629                	li	a2,10
 59e:	000bb583          	ld	a1,0(s7)
 5a2:	855a                	mv	a0,s6
 5a4:	dc9ff0ef          	jal	36c <printint>
        i += 1;
 5a8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 5aa:	8bca                	mv	s7,s2
      state = 0;
 5ac:	4981                	li	s3,0
        i += 1;
 5ae:	b555                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5b0:	008b8913          	addi	s2,s7,8
 5b4:	4681                	li	a3,0
 5b6:	4629                	li	a2,10
 5b8:	000bb583          	ld	a1,0(s7)
 5bc:	855a                	mv	a0,s6
 5be:	dafff0ef          	jal	36c <printint>
        i += 2;
 5c2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
        i += 2;
 5c8:	b569                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 5ca:	008b8913          	addi	s2,s7,8
 5ce:	4681                	li	a3,0
 5d0:	4641                	li	a2,16
 5d2:	000be583          	lwu	a1,0(s7)
 5d6:	855a                	mv	a0,s6
 5d8:	d95ff0ef          	jal	36c <printint>
 5dc:	8bca                	mv	s7,s2
      state = 0;
 5de:	4981                	li	s3,0
 5e0:	bd8d                	j	452 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000bb583          	ld	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	d7dff0ef          	jal	36c <printint>
        i += 1;
 5f4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
        i += 1;
 5fa:	bda1                	j	452 <vprintf+0x4a>
 5fc:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 5fe:	008b8d13          	addi	s10,s7,8
 602:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 606:	03000593          	li	a1,48
 60a:	855a                	mv	a0,s6
 60c:	d43ff0ef          	jal	34e <putc>
  putc(fd, 'x');
 610:	07800593          	li	a1,120
 614:	855a                	mv	a0,s6
 616:	d39ff0ef          	jal	34e <putc>
 61a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 61c:	00000b97          	auipc	s7,0x0
 620:	27cb8b93          	addi	s7,s7,636 # 898 <digits>
 624:	03c9d793          	srli	a5,s3,0x3c
 628:	97de                	add	a5,a5,s7
 62a:	0007c583          	lbu	a1,0(a5)
 62e:	855a                	mv	a0,s6
 630:	d1fff0ef          	jal	34e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 634:	0992                	slli	s3,s3,0x4
 636:	397d                	addiw	s2,s2,-1
 638:	fe0916e3          	bnez	s2,624 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 63c:	8bea                	mv	s7,s10
      state = 0;
 63e:	4981                	li	s3,0
 640:	6d02                	ld	s10,0(sp)
 642:	bd01                	j	452 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 644:	008b8913          	addi	s2,s7,8
 648:	000bc583          	lbu	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	d01ff0ef          	jal	34e <putc>
 652:	8bca                	mv	s7,s2
      state = 0;
 654:	4981                	li	s3,0
 656:	bbf5                	j	452 <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 658:	008b8993          	addi	s3,s7,8
 65c:	000bb903          	ld	s2,0(s7)
 660:	00090f63          	beqz	s2,67e <vprintf+0x276>
        for (; *s; s++)
 664:	00094583          	lbu	a1,0(s2)
 668:	c195                	beqz	a1,68c <vprintf+0x284>
          putc(fd, *s);
 66a:	855a                	mv	a0,s6
 66c:	ce3ff0ef          	jal	34e <putc>
        for (; *s; s++)
 670:	0905                	addi	s2,s2,1
 672:	00094583          	lbu	a1,0(s2)
 676:	f9f5                	bnez	a1,66a <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 678:	8bce                	mv	s7,s3
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bbd9                	j	452 <vprintf+0x4a>
          s = "(null)";
 67e:	00000917          	auipc	s2,0x0
 682:	21290913          	addi	s2,s2,530 # 890 <malloc+0x106>
        for (; *s; s++)
 686:	02800593          	li	a1,40
 68a:	b7c5                	j	66a <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 68c:	8bce                	mv	s7,s3
      state = 0;
 68e:	4981                	li	s3,0
 690:	b3c9                	j	452 <vprintf+0x4a>
 692:	64a6                	ld	s1,72(sp)
 694:	79e2                	ld	s3,56(sp)
 696:	7a42                	ld	s4,48(sp)
 698:	7aa2                	ld	s5,40(sp)
 69a:	7b02                	ld	s6,32(sp)
 69c:	6be2                	ld	s7,24(sp)
 69e:	6c42                	ld	s8,16(sp)
 6a0:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6a2:	60e6                	ld	ra,88(sp)
 6a4:	6446                	ld	s0,80(sp)
 6a6:	6906                	ld	s2,64(sp)
 6a8:	6125                	addi	sp,sp,96
 6aa:	8082                	ret

00000000000006ac <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6ac:	715d                	addi	sp,sp,-80
 6ae:	ec06                	sd	ra,24(sp)
 6b0:	e822                	sd	s0,16(sp)
 6b2:	1000                	addi	s0,sp,32
 6b4:	e010                	sd	a2,0(s0)
 6b6:	e414                	sd	a3,8(s0)
 6b8:	e818                	sd	a4,16(s0)
 6ba:	ec1c                	sd	a5,24(s0)
 6bc:	03043023          	sd	a6,32(s0)
 6c0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6c4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6c8:	8622                	mv	a2,s0
 6ca:	d3fff0ef          	jal	408 <vprintf>
}
 6ce:	60e2                	ld	ra,24(sp)
 6d0:	6442                	ld	s0,16(sp)
 6d2:	6161                	addi	sp,sp,80
 6d4:	8082                	ret

00000000000006d6 <printf>:

void
printf(const char *fmt, ...)
{
 6d6:	711d                	addi	sp,sp,-96
 6d8:	ec06                	sd	ra,24(sp)
 6da:	e822                	sd	s0,16(sp)
 6dc:	1000                	addi	s0,sp,32
 6de:	e40c                	sd	a1,8(s0)
 6e0:	e810                	sd	a2,16(s0)
 6e2:	ec14                	sd	a3,24(s0)
 6e4:	f018                	sd	a4,32(s0)
 6e6:	f41c                	sd	a5,40(s0)
 6e8:	03043823          	sd	a6,48(s0)
 6ec:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6f0:	00840613          	addi	a2,s0,8
 6f4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6f8:	85aa                	mv	a1,a0
 6fa:	4505                	li	a0,1
 6fc:	d0dff0ef          	jal	408 <vprintf>
}
 700:	60e2                	ld	ra,24(sp)
 702:	6442                	ld	s0,16(sp)
 704:	6125                	addi	sp,sp,96
 706:	8082                	ret

0000000000000708 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 708:	1141                	addi	sp,sp,-16
 70a:	e422                	sd	s0,8(sp)
 70c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 70e:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 712:	00001797          	auipc	a5,0x1
 716:	8ee7b783          	ld	a5,-1810(a5) # 1000 <freep>
 71a:	a02d                	j	744 <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 71c:	4618                	lw	a4,8(a2)
 71e:	9f2d                	addw	a4,a4,a1
 720:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 724:	6398                	ld	a4,0(a5)
 726:	6310                	ld	a2,0(a4)
 728:	a83d                	j	766 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 72a:	ff852703          	lw	a4,-8(a0)
 72e:	9f31                	addw	a4,a4,a2
 730:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 732:	ff053683          	ld	a3,-16(a0)
 736:	a091                	j	77a <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 738:	6398                	ld	a4,0(a5)
 73a:	00e7e463          	bltu	a5,a4,742 <free+0x3a>
 73e:	00e6ea63          	bltu	a3,a4,752 <free+0x4a>
{
 742:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 744:	fed7fae3          	bgeu	a5,a3,738 <free+0x30>
 748:	6398                	ld	a4,0(a5)
 74a:	00e6e463          	bltu	a3,a4,752 <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 74e:	fee7eae3          	bltu	a5,a4,742 <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 752:	ff852583          	lw	a1,-8(a0)
 756:	6390                	ld	a2,0(a5)
 758:	02059813          	slli	a6,a1,0x20
 75c:	01c85713          	srli	a4,a6,0x1c
 760:	9736                	add	a4,a4,a3
 762:	fae60de3          	beq	a2,a4,71c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 766:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 76a:	4790                	lw	a2,8(a5)
 76c:	02061593          	slli	a1,a2,0x20
 770:	01c5d713          	srli	a4,a1,0x1c
 774:	973e                	add	a4,a4,a5
 776:	fae68ae3          	beq	a3,a4,72a <free+0x22>
    p->s.ptr = bp->s.ptr;
 77a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 77c:	00001717          	auipc	a4,0x1
 780:	88f73223          	sd	a5,-1916(a4) # 1000 <freep>
}
 784:	6422                	ld	s0,8(sp)
 786:	0141                	addi	sp,sp,16
 788:	8082                	ret

000000000000078a <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 78a:	7139                	addi	sp,sp,-64
 78c:	fc06                	sd	ra,56(sp)
 78e:	f822                	sd	s0,48(sp)
 790:	f426                	sd	s1,40(sp)
 792:	ec4e                	sd	s3,24(sp)
 794:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 796:	02051493          	slli	s1,a0,0x20
 79a:	9081                	srli	s1,s1,0x20
 79c:	04bd                	addi	s1,s1,15
 79e:	8091                	srli	s1,s1,0x4
 7a0:	0014899b          	addiw	s3,s1,1
 7a4:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 7a6:	00001517          	auipc	a0,0x1
 7aa:	85a53503          	ld	a0,-1958(a0) # 1000 <freep>
 7ae:	c915                	beqz	a0,7e2 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 7b0:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 7b2:	4798                	lw	a4,8(a5)
 7b4:	08977a63          	bgeu	a4,s1,848 <malloc+0xbe>
 7b8:	f04a                	sd	s2,32(sp)
 7ba:	e852                	sd	s4,16(sp)
 7bc:	e456                	sd	s5,8(sp)
 7be:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 7c0:	8a4e                	mv	s4,s3
 7c2:	0009871b          	sext.w	a4,s3
 7c6:	6685                	lui	a3,0x1
 7c8:	00d77363          	bgeu	a4,a3,7ce <malloc+0x44>
 7cc:	6a05                	lui	s4,0x1
 7ce:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7d2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 7d6:	00001917          	auipc	s2,0x1
 7da:	82a90913          	addi	s2,s2,-2006 # 1000 <freep>
  if (p == SBRK_ERROR)
 7de:	5afd                	li	s5,-1
 7e0:	a081                	j	820 <malloc+0x96>
 7e2:	f04a                	sd	s2,32(sp)
 7e4:	e852                	sd	s4,16(sp)
 7e6:	e456                	sd	s5,8(sp)
 7e8:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 7ea:	00001797          	auipc	a5,0x1
 7ee:	82678793          	addi	a5,a5,-2010 # 1010 <base>
 7f2:	00001717          	auipc	a4,0x1
 7f6:	80f73723          	sd	a5,-2034(a4) # 1000 <freep>
 7fa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7fc:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 800:	b7c1                	j	7c0 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 802:	6398                	ld	a4,0(a5)
 804:	e118                	sd	a4,0(a0)
 806:	a8a9                	j	860 <malloc+0xd6>
  hp->s.size = nu;
 808:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 80c:	0541                	addi	a0,a0,16
 80e:	efbff0ef          	jal	708 <free>
  return freep;
 812:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 816:	c12d                	beqz	a0,878 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 818:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 81a:	4798                	lw	a4,8(a5)
 81c:	02977263          	bgeu	a4,s1,840 <malloc+0xb6>
    if (p == freep)
 820:	00093703          	ld	a4,0(s2)
 824:	853e                	mv	a0,a5
 826:	fef719e3          	bne	a4,a5,818 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 82a:	8552                	mv	a0,s4
 82c:	a47ff0ef          	jal	272 <sbrk>
  if (p == SBRK_ERROR)
 830:	fd551ce3          	bne	a0,s5,808 <malloc+0x7e>
        return 0;
 834:	4501                	li	a0,0
 836:	7902                	ld	s2,32(sp)
 838:	6a42                	ld	s4,16(sp)
 83a:	6aa2                	ld	s5,8(sp)
 83c:	6b02                	ld	s6,0(sp)
 83e:	a03d                	j	86c <malloc+0xe2>
 840:	7902                	ld	s2,32(sp)
 842:	6a42                	ld	s4,16(sp)
 844:	6aa2                	ld	s5,8(sp)
 846:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 848:	fae48de3          	beq	s1,a4,802 <malloc+0x78>
        p->s.size -= nunits;
 84c:	4137073b          	subw	a4,a4,s3
 850:	c798                	sw	a4,8(a5)
        p += p->s.size;
 852:	02071693          	slli	a3,a4,0x20
 856:	01c6d713          	srli	a4,a3,0x1c
 85a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 85c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 860:	00000717          	auipc	a4,0x0
 864:	7aa73023          	sd	a0,1952(a4) # 1000 <freep>
      return (void *)(p + 1);
 868:	01078513          	addi	a0,a5,16
  }
}
 86c:	70e2                	ld	ra,56(sp)
 86e:	7442                	ld	s0,48(sp)
 870:	74a2                	ld	s1,40(sp)
 872:	69e2                	ld	s3,24(sp)
 874:	6121                	addi	sp,sp,64
 876:	8082                	ret
 878:	7902                	ld	s2,32(sp)
 87a:	6a42                	ld	s4,16(sp)
 87c:	6aa2                	ld	s5,8(sp)
 87e:	6b02                	ld	s6,0(sp)
 880:	b7f5                	j	86c <malloc+0xe2>
