
user/_bench_vvadd:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
    c[i] = a[i] + b[i];
}

int
main(void)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  int *results = malloc(DATA_SIZE * sizeof(int));
   8:	4b000513          	li	a0,1200
   c:	017000ef          	jal	822 <malloc>
  if (results == 0) {
  10:	c52d                	beqz	a0,7a <main+0x7a>
  12:	e426                	sd	s1,8(sp)
  14:	84aa                	mv	s1,a0
  16:	00001717          	auipc	a4,0x1
  1a:	fea70713          	addi	a4,a4,-22 # 1000 <input1_data>
  1e:	00001617          	auipc	a2,0x1
  22:	49260613          	addi	a2,a2,1170 # 14b0 <input2_data>
  26:	87aa                	mv	a5,a0
  28:	8832                	mv	a6,a2
  2a:	85aa                	mv	a1,a0
    c[i] = a[i] + b[i];
  2c:	4308                	lw	a0,0(a4)
  2e:	4214                	lw	a3,0(a2)
  30:	9ea9                	addw	a3,a3,a0
  32:	c194                	sw	a3,0(a1)
  for (int i = 0; i < n; i++)
  34:	0711                	addi	a4,a4,4
  36:	0611                	addi	a2,a2,4
  38:	0591                	addi	a1,a1,4
  3a:	ff0719e3          	bne	a4,a6,2c <main+0x2c>
  3e:	00002717          	auipc	a4,0x2
  42:	92270713          	addi	a4,a4,-1758 # 1960 <verify_data>
    exit(1);
  }

  vvadd(DATA_SIZE, input1_data, input2_data, results);

  for (int i = 0; i < DATA_SIZE; i++) {
  46:	4601                	li	a2,0
  48:	12c00513          	li	a0,300
    if (results[i] != verify_data[i]) {
  4c:	438c                	lw	a1,0(a5)
  4e:	4314                	lw	a3,0(a4)
  50:	04d59063          	bne	a1,a3,90 <main+0x90>
  for (int i = 0; i < DATA_SIZE; i++) {
  54:	2605                	addiw	a2,a2,1
  56:	0791                	addi	a5,a5,4
  58:	0711                	addi	a4,a4,4
  5a:	fea619e3          	bne	a2,a0,4c <main+0x4c>
      free(results);
      exit(1);
    }
  }

  printf("vvadd: PASS (%d elements)\n", DATA_SIZE);
  5e:	12c00593          	li	a1,300
  62:	00001517          	auipc	a0,0x1
  66:	8fe50513          	addi	a0,a0,-1794 # 960 <malloc+0x13e>
  6a:	704000ef          	jal	76e <printf>
  free(results);
  6e:	8526                	mv	a0,s1
  70:	730000ef          	jal	7a0 <free>
  exit(0);
  74:	4501                	li	a0,0
  76:	2c8000ef          	jal	33e <exit>
  7a:	e426                	sd	s1,8(sp)
    fprintf(2, "vvadd: allocation failed\n");
  7c:	00001597          	auipc	a1,0x1
  80:	8a458593          	addi	a1,a1,-1884 # 920 <malloc+0xfe>
  84:	4509                	li	a0,2
  86:	6be000ef          	jal	744 <fprintf>
    exit(1);
  8a:	4505                	li	a0,1
  8c:	2b2000ef          	jal	33e <exit>
      fprintf(2, "vvadd: FAIL at element %d\n", i);
  90:	00001597          	auipc	a1,0x1
  94:	8b058593          	addi	a1,a1,-1872 # 940 <malloc+0x11e>
  98:	4509                	li	a0,2
  9a:	6aa000ef          	jal	744 <fprintf>
      free(results);
  9e:	8526                	mv	a0,s1
  a0:	700000ef          	jal	7a0 <free>
      exit(1);
  a4:	4505                	li	a0,1
  a6:	298000ef          	jal	33e <exit>

00000000000000aa <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
  aa:	1141                	addi	sp,sp,-16
  ac:	e406                	sd	ra,8(sp)
  ae:	e022                	sd	s0,0(sp)
  b0:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
  b2:	f4fff0ef          	jal	0 <main>
  exit(r);
  b6:	288000ef          	jal	33e <exit>

00000000000000ba <strcpy>:
}

char *
strcpy(char *s, const char *t)
{
  ba:	1141                	addi	sp,sp,-16
  bc:	e422                	sd	s0,8(sp)
  be:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while ((*s++ = *t++) != 0)
  c0:	87aa                	mv	a5,a0
  c2:	0585                	addi	a1,a1,1
  c4:	0785                	addi	a5,a5,1
  c6:	fff5c703          	lbu	a4,-1(a1)
  ca:	fee78fa3          	sb	a4,-1(a5)
  ce:	fb75                	bnez	a4,c2 <strcpy+0x8>
    ;
  return os;
}
  d0:	6422                	ld	s0,8(sp)
  d2:	0141                	addi	sp,sp,16
  d4:	8082                	ret

00000000000000d6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  d6:	1141                	addi	sp,sp,-16
  d8:	e422                	sd	s0,8(sp)
  da:	0800                	addi	s0,sp,16
  while (*p && *p == *q)
  dc:	00054783          	lbu	a5,0(a0)
  e0:	cb91                	beqz	a5,f4 <strcmp+0x1e>
  e2:	0005c703          	lbu	a4,0(a1)
  e6:	00f71763          	bne	a4,a5,f4 <strcmp+0x1e>
    p++, q++;
  ea:	0505                	addi	a0,a0,1
  ec:	0585                	addi	a1,a1,1
  while (*p && *p == *q)
  ee:	00054783          	lbu	a5,0(a0)
  f2:	fbe5                	bnez	a5,e2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  f4:	0005c503          	lbu	a0,0(a1)
}
  f8:	40a7853b          	subw	a0,a5,a0
  fc:	6422                	ld	s0,8(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret

0000000000000102 <strlen>:

uint
strlen(const char *s)
{
 102:	1141                	addi	sp,sp,-16
 104:	e422                	sd	s0,8(sp)
 106:	0800                	addi	s0,sp,16
  int n;

  for (n = 0; s[n]; n++)
 108:	00054783          	lbu	a5,0(a0)
 10c:	cf91                	beqz	a5,128 <strlen+0x26>
 10e:	0505                	addi	a0,a0,1
 110:	87aa                	mv	a5,a0
 112:	86be                	mv	a3,a5
 114:	0785                	addi	a5,a5,1
 116:	fff7c703          	lbu	a4,-1(a5)
 11a:	ff65                	bnez	a4,112 <strlen+0x10>
 11c:	40a6853b          	subw	a0,a3,a0
 120:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 122:	6422                	ld	s0,8(sp)
 124:	0141                	addi	sp,sp,16
 126:	8082                	ret
  for (n = 0; s[n]; n++)
 128:	4501                	li	a0,0
 12a:	bfe5                	j	122 <strlen+0x20>

000000000000012c <memset>:

void *
memset(void *dst, int c, uint n)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	addi	s0,sp,16
  char *cdst = (char *)dst;
  int i;
  for (i = 0; i < n; i++) {
 132:	ca19                	beqz	a2,148 <memset+0x1c>
 134:	87aa                	mv	a5,a0
 136:	1602                	slli	a2,a2,0x20
 138:	9201                	srli	a2,a2,0x20
 13a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 13e:	00b78023          	sb	a1,0(a5)
  for (i = 0; i < n; i++) {
 142:	0785                	addi	a5,a5,1
 144:	fee79de3          	bne	a5,a4,13e <memset+0x12>
  }
  return dst;
}
 148:	6422                	ld	s0,8(sp)
 14a:	0141                	addi	sp,sp,16
 14c:	8082                	ret

000000000000014e <strchr>:

char *
strchr(const char *s, char c)
{
 14e:	1141                	addi	sp,sp,-16
 150:	e422                	sd	s0,8(sp)
 152:	0800                	addi	s0,sp,16
  for (; *s; s++)
 154:	00054783          	lbu	a5,0(a0)
 158:	cb99                	beqz	a5,16e <strchr+0x20>
    if (*s == c)
 15a:	00f58763          	beq	a1,a5,168 <strchr+0x1a>
  for (; *s; s++)
 15e:	0505                	addi	a0,a0,1
 160:	00054783          	lbu	a5,0(a0)
 164:	fbfd                	bnez	a5,15a <strchr+0xc>
      return (char *)s;
  return 0;
 166:	4501                	li	a0,0
}
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret
  return 0;
 16e:	4501                	li	a0,0
 170:	bfe5                	j	168 <strchr+0x1a>

0000000000000172 <gets>:

char *
gets(char *buf, int max)
{
 172:	711d                	addi	sp,sp,-96
 174:	ec86                	sd	ra,88(sp)
 176:	e8a2                	sd	s0,80(sp)
 178:	e4a6                	sd	s1,72(sp)
 17a:	e0ca                	sd	s2,64(sp)
 17c:	fc4e                	sd	s3,56(sp)
 17e:	f852                	sd	s4,48(sp)
 180:	f456                	sd	s5,40(sp)
 182:	f05a                	sd	s6,32(sp)
 184:	ec5e                	sd	s7,24(sp)
 186:	1080                	addi	s0,sp,96
 188:	8baa                	mv	s7,a0
 18a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for (i = 0; i + 1 < max;) {
 18c:	892a                	mv	s2,a0
 18e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if (cc < 1)
      break;
    buf[i++] = c;
    if (c == '\n' || c == '\r')
 190:	4aa9                	li	s5,10
 192:	4b35                	li	s6,13
  for (i = 0; i + 1 < max;) {
 194:	89a6                	mv	s3,s1
 196:	2485                	addiw	s1,s1,1
 198:	0344d663          	bge	s1,s4,1c4 <gets+0x52>
    cc = read(0, &c, 1);
 19c:	4605                	li	a2,1
 19e:	faf40593          	addi	a1,s0,-81
 1a2:	4501                	li	a0,0
 1a4:	1b2000ef          	jal	356 <read>
    if (cc < 1)
 1a8:	00a05e63          	blez	a0,1c4 <gets+0x52>
    buf[i++] = c;
 1ac:	faf44783          	lbu	a5,-81(s0)
 1b0:	00f90023          	sb	a5,0(s2)
    if (c == '\n' || c == '\r')
 1b4:	01578763          	beq	a5,s5,1c2 <gets+0x50>
 1b8:	0905                	addi	s2,s2,1
 1ba:	fd679de3          	bne	a5,s6,194 <gets+0x22>
    buf[i++] = c;
 1be:	89a6                	mv	s3,s1
 1c0:	a011                	j	1c4 <gets+0x52>
 1c2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1c4:	99de                	add	s3,s3,s7
 1c6:	00098023          	sb	zero,0(s3)
  return buf;
}
 1ca:	855e                	mv	a0,s7
 1cc:	60e6                	ld	ra,88(sp)
 1ce:	6446                	ld	s0,80(sp)
 1d0:	64a6                	ld	s1,72(sp)
 1d2:	6906                	ld	s2,64(sp)
 1d4:	79e2                	ld	s3,56(sp)
 1d6:	7a42                	ld	s4,48(sp)
 1d8:	7aa2                	ld	s5,40(sp)
 1da:	7b02                	ld	s6,32(sp)
 1dc:	6be2                	ld	s7,24(sp)
 1de:	6125                	addi	sp,sp,96
 1e0:	8082                	ret

00000000000001e2 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e2:	1101                	addi	sp,sp,-32
 1e4:	ec06                	sd	ra,24(sp)
 1e6:	e822                	sd	s0,16(sp)
 1e8:	e04a                	sd	s2,0(sp)
 1ea:	1000                	addi	s0,sp,32
 1ec:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ee:	4581                	li	a1,0
 1f0:	18e000ef          	jal	37e <open>
  if (fd < 0)
 1f4:	02054263          	bltz	a0,218 <stat+0x36>
 1f8:	e426                	sd	s1,8(sp)
 1fa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1fc:	85ca                	mv	a1,s2
 1fe:	198000ef          	jal	396 <fstat>
 202:	892a                	mv	s2,a0
  close(fd);
 204:	8526                	mv	a0,s1
 206:	160000ef          	jal	366 <close>
  return r;
 20a:	64a2                	ld	s1,8(sp)
}
 20c:	854a                	mv	a0,s2
 20e:	60e2                	ld	ra,24(sp)
 210:	6442                	ld	s0,16(sp)
 212:	6902                	ld	s2,0(sp)
 214:	6105                	addi	sp,sp,32
 216:	8082                	ret
    return -1;
 218:	597d                	li	s2,-1
 21a:	bfcd                	j	20c <stat+0x2a>

000000000000021c <atoi>:

int
atoi(const char *s)
{
 21c:	1141                	addi	sp,sp,-16
 21e:	e422                	sd	s0,8(sp)
 220:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while ('0' <= *s && *s <= '9')
 222:	00054683          	lbu	a3,0(a0)
 226:	fd06879b          	addiw	a5,a3,-48
 22a:	0ff7f793          	zext.b	a5,a5
 22e:	4625                	li	a2,9
 230:	02f66863          	bltu	a2,a5,260 <atoi+0x44>
 234:	872a                	mv	a4,a0
  n = 0;
 236:	4501                	li	a0,0
    n = n * 10 + *s++ - '0';
 238:	0705                	addi	a4,a4,1
 23a:	0025179b          	slliw	a5,a0,0x2
 23e:	9fa9                	addw	a5,a5,a0
 240:	0017979b          	slliw	a5,a5,0x1
 244:	9fb5                	addw	a5,a5,a3
 246:	fd07851b          	addiw	a0,a5,-48
  while ('0' <= *s && *s <= '9')
 24a:	00074683          	lbu	a3,0(a4)
 24e:	fd06879b          	addiw	a5,a3,-48
 252:	0ff7f793          	zext.b	a5,a5
 256:	fef671e3          	bgeu	a2,a5,238 <atoi+0x1c>
  return n;
}
 25a:	6422                	ld	s0,8(sp)
 25c:	0141                	addi	sp,sp,16
 25e:	8082                	ret
  n = 0;
 260:	4501                	li	a0,0
 262:	bfe5                	j	25a <atoi+0x3e>

0000000000000264 <memmove>:

void *
memmove(void *vdst, const void *vsrc, int n)
{
 264:	1141                	addi	sp,sp,-16
 266:	e422                	sd	s0,8(sp)
 268:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 26a:	02b57463          	bgeu	a0,a1,292 <memmove+0x2e>
    while (n-- > 0)
 26e:	00c05f63          	blez	a2,28c <memmove+0x28>
 272:	1602                	slli	a2,a2,0x20
 274:	9201                	srli	a2,a2,0x20
 276:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 27a:	872a                	mv	a4,a0
      *dst++ = *src++;
 27c:	0585                	addi	a1,a1,1
 27e:	0705                	addi	a4,a4,1
 280:	fff5c683          	lbu	a3,-1(a1)
 284:	fed70fa3          	sb	a3,-1(a4)
    while (n-- > 0)
 288:	fef71ae3          	bne	a4,a5,27c <memmove+0x18>
    src += n;
    while (n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 28c:	6422                	ld	s0,8(sp)
 28e:	0141                	addi	sp,sp,16
 290:	8082                	ret
    dst += n;
 292:	00c50733          	add	a4,a0,a2
    src += n;
 296:	95b2                	add	a1,a1,a2
    while (n-- > 0)
 298:	fec05ae3          	blez	a2,28c <memmove+0x28>
 29c:	fff6079b          	addiw	a5,a2,-1
 2a0:	1782                	slli	a5,a5,0x20
 2a2:	9381                	srli	a5,a5,0x20
 2a4:	fff7c793          	not	a5,a5
 2a8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2aa:	15fd                	addi	a1,a1,-1
 2ac:	177d                	addi	a4,a4,-1
 2ae:	0005c683          	lbu	a3,0(a1)
 2b2:	00d70023          	sb	a3,0(a4)
    while (n-- > 0)
 2b6:	fee79ae3          	bne	a5,a4,2aa <memmove+0x46>
 2ba:	bfc9                	j	28c <memmove+0x28>

00000000000002bc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2bc:	1141                	addi	sp,sp,-16
 2be:	e422                	sd	s0,8(sp)
 2c0:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2c2:	ca05                	beqz	a2,2f2 <memcmp+0x36>
 2c4:	fff6069b          	addiw	a3,a2,-1
 2c8:	1682                	slli	a3,a3,0x20
 2ca:	9281                	srli	a3,a3,0x20
 2cc:	0685                	addi	a3,a3,1
 2ce:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d0:	00054783          	lbu	a5,0(a0)
 2d4:	0005c703          	lbu	a4,0(a1)
 2d8:	00e79863          	bne	a5,a4,2e8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2dc:	0505                	addi	a0,a0,1
    p2++;
 2de:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e0:	fed518e3          	bne	a0,a3,2d0 <memcmp+0x14>
  }
  return 0;
 2e4:	4501                	li	a0,0
 2e6:	a019                	j	2ec <memcmp+0x30>
      return *p1 - *p2;
 2e8:	40e7853b          	subw	a0,a5,a4
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
  return 0;
 2f2:	4501                	li	a0,0
 2f4:	bfe5                	j	2ec <memcmp+0x30>

00000000000002f6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e406                	sd	ra,8(sp)
 2fa:	e022                	sd	s0,0(sp)
 2fc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2fe:	f67ff0ef          	jal	264 <memmove>
}
 302:	60a2                	ld	ra,8(sp)
 304:	6402                	ld	s0,0(sp)
 306:	0141                	addi	sp,sp,16
 308:	8082                	ret

000000000000030a <sbrk>:

char *
sbrk(int n)
{
 30a:	1141                	addi	sp,sp,-16
 30c:	e406                	sd	ra,8(sp)
 30e:	e022                	sd	s0,0(sp)
 310:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 312:	4585                	li	a1,1
 314:	0b2000ef          	jal	3c6 <sys_sbrk>
}
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret

0000000000000320 <sbrklazy>:

char *
sbrklazy(int n)
{
 320:	1141                	addi	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 328:	4589                	li	a1,2
 32a:	09c000ef          	jal	3c6 <sys_sbrk>
}
 32e:	60a2                	ld	ra,8(sp)
 330:	6402                	ld	s0,0(sp)
 332:	0141                	addi	sp,sp,16
 334:	8082                	ret

0000000000000336 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 336:	4885                	li	a7,1
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <exit>:
.global exit
exit:
 li a7, SYS_exit
 33e:	4889                	li	a7,2
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <wait>:
.global wait
wait:
 li a7, SYS_wait
 346:	488d                	li	a7,3
 ecall
 348:	00000073          	ecall
 ret
 34c:	8082                	ret

000000000000034e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 34e:	4891                	li	a7,4
 ecall
 350:	00000073          	ecall
 ret
 354:	8082                	ret

0000000000000356 <read>:
.global read
read:
 li a7, SYS_read
 356:	4895                	li	a7,5
 ecall
 358:	00000073          	ecall
 ret
 35c:	8082                	ret

000000000000035e <write>:
.global write
write:
 li a7, SYS_write
 35e:	48c1                	li	a7,16
 ecall
 360:	00000073          	ecall
 ret
 364:	8082                	ret

0000000000000366 <close>:
.global close
close:
 li a7, SYS_close
 366:	48d5                	li	a7,21
 ecall
 368:	00000073          	ecall
 ret
 36c:	8082                	ret

000000000000036e <kill>:
.global kill
kill:
 li a7, SYS_kill
 36e:	4899                	li	a7,6
 ecall
 370:	00000073          	ecall
 ret
 374:	8082                	ret

0000000000000376 <exec>:
.global exec
exec:
 li a7, SYS_exec
 376:	489d                	li	a7,7
 ecall
 378:	00000073          	ecall
 ret
 37c:	8082                	ret

000000000000037e <open>:
.global open
open:
 li a7, SYS_open
 37e:	48bd                	li	a7,15
 ecall
 380:	00000073          	ecall
 ret
 384:	8082                	ret

0000000000000386 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 386:	48c5                	li	a7,17
 ecall
 388:	00000073          	ecall
 ret
 38c:	8082                	ret

000000000000038e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 38e:	48c9                	li	a7,18
 ecall
 390:	00000073          	ecall
 ret
 394:	8082                	ret

0000000000000396 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 396:	48a1                	li	a7,8
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <link>:
.global link
link:
 li a7, SYS_link
 39e:	48cd                	li	a7,19
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a6:	48d1                	li	a7,20
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3ae:	48a5                	li	a7,9
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b6:	48a9                	li	a7,10
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3be:	48ad                	li	a7,11
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 3c6:	48b1                	li	a7,12
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <pause>:
.global pause
pause:
 li a7, SYS_pause
 3ce:	48b5                	li	a7,13
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d6:	48b9                	li	a7,14
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <sync>:
.global sync
sync:
 li a7, SYS_sync
 3de:	48d9                	li	a7,22
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e6:	1101                	addi	sp,sp,-32
 3e8:	ec06                	sd	ra,24(sp)
 3ea:	e822                	sd	s0,16(sp)
 3ec:	1000                	addi	s0,sp,32
 3ee:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f2:	4605                	li	a2,1
 3f4:	fef40593          	addi	a1,s0,-17
 3f8:	f67ff0ef          	jal	35e <write>
}
 3fc:	60e2                	ld	ra,24(sp)
 3fe:	6442                	ld	s0,16(sp)
 400:	6105                	addi	sp,sp,32
 402:	8082                	ret

0000000000000404 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 404:	715d                	addi	sp,sp,-80
 406:	e486                	sd	ra,72(sp)
 408:	e0a2                	sd	s0,64(sp)
 40a:	f84a                	sd	s2,48(sp)
 40c:	0880                	addi	s0,sp,80
 40e:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if (sgn && xx < 0) {
 410:	c299                	beqz	a3,416 <printint+0x12>
 412:	0805c363          	bltz	a1,498 <printint+0x94>
  neg = 0;
 416:	4881                	li	a7,0
 418:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 41c:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
 41e:	00000517          	auipc	a0,0x0
 422:	56a50513          	addi	a0,a0,1386 # 988 <digits>
 426:	883e                	mv	a6,a5
 428:	2785                	addiw	a5,a5,1
 42a:	02c5f733          	remu	a4,a1,a2
 42e:	972a                	add	a4,a4,a0
 430:	00074703          	lbu	a4,0(a4)
 434:	00e68023          	sb	a4,0(a3)
  } while ((x /= base) != 0);
 438:	872e                	mv	a4,a1
 43a:	02c5d5b3          	divu	a1,a1,a2
 43e:	0685                	addi	a3,a3,1
 440:	fec773e3          	bgeu	a4,a2,426 <printint+0x22>
  if (neg)
 444:	00088b63          	beqz	a7,45a <printint+0x56>
    buf[i++] = '-';
 448:	fd078793          	addi	a5,a5,-48
 44c:	97a2                	add	a5,a5,s0
 44e:	02d00713          	li	a4,45
 452:	fee78423          	sb	a4,-24(a5)
 456:	0028079b          	addiw	a5,a6,2

  while (--i >= 0)
 45a:	02f05a63          	blez	a5,48e <printint+0x8a>
 45e:	fc26                	sd	s1,56(sp)
 460:	f44e                	sd	s3,40(sp)
 462:	fb840713          	addi	a4,s0,-72
 466:	00f704b3          	add	s1,a4,a5
 46a:	fff70993          	addi	s3,a4,-1
 46e:	99be                	add	s3,s3,a5
 470:	37fd                	addiw	a5,a5,-1
 472:	1782                	slli	a5,a5,0x20
 474:	9381                	srli	a5,a5,0x20
 476:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 47a:	fff4c583          	lbu	a1,-1(s1)
 47e:	854a                	mv	a0,s2
 480:	f67ff0ef          	jal	3e6 <putc>
  while (--i >= 0)
 484:	14fd                	addi	s1,s1,-1
 486:	ff349ae3          	bne	s1,s3,47a <printint+0x76>
 48a:	74e2                	ld	s1,56(sp)
 48c:	79a2                	ld	s3,40(sp)
}
 48e:	60a6                	ld	ra,72(sp)
 490:	6406                	ld	s0,64(sp)
 492:	7942                	ld	s2,48(sp)
 494:	6161                	addi	sp,sp,80
 496:	8082                	ret
    x = -xx;
 498:	40b005b3          	neg	a1,a1
    neg = 1;
 49c:	4885                	li	a7,1
    x = -xx;
 49e:	bfad                	j	418 <printint+0x14>

00000000000004a0 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4a0:	711d                	addi	sp,sp,-96
 4a2:	ec86                	sd	ra,88(sp)
 4a4:	e8a2                	sd	s0,80(sp)
 4a6:	e0ca                	sd	s2,64(sp)
 4a8:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for (i = 0; fmt[i]; i++) {
 4aa:	0005c903          	lbu	s2,0(a1)
 4ae:	28090663          	beqz	s2,73a <vprintf+0x29a>
 4b2:	e4a6                	sd	s1,72(sp)
 4b4:	fc4e                	sd	s3,56(sp)
 4b6:	f852                	sd	s4,48(sp)
 4b8:	f456                	sd	s5,40(sp)
 4ba:	f05a                	sd	s6,32(sp)
 4bc:	ec5e                	sd	s7,24(sp)
 4be:	e862                	sd	s8,16(sp)
 4c0:	e466                	sd	s9,8(sp)
 4c2:	8b2a                	mv	s6,a0
 4c4:	8a2e                	mv	s4,a1
 4c6:	8bb2                	mv	s7,a2
  state = 0;
 4c8:	4981                	li	s3,0
  for (i = 0; fmt[i]; i++) {
 4ca:	4481                	li	s1,0
 4cc:	4701                	li	a4,0
      if (c0 == '%') {
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if (state == '%') {
 4ce:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if (c0)
        c1 = fmt[i + 1] & 0xff;
      if (c1)
        c2 = fmt[i + 2] & 0xff;
      if (c0 == 'd') {
 4d2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if (c0 == 'l' && c1 == 'd') {
 4d6:	06c00c93          	li	s9,108
 4da:	a005                	j	4fa <vprintf+0x5a>
        putc(fd, c0);
 4dc:	85ca                	mv	a1,s2
 4de:	855a                	mv	a0,s6
 4e0:	f07ff0ef          	jal	3e6 <putc>
 4e4:	a019                	j	4ea <vprintf+0x4a>
    } else if (state == '%') {
 4e6:	03598263          	beq	s3,s5,50a <vprintf+0x6a>
  for (i = 0; fmt[i]; i++) {
 4ea:	2485                	addiw	s1,s1,1
 4ec:	8726                	mv	a4,s1
 4ee:	009a07b3          	add	a5,s4,s1
 4f2:	0007c903          	lbu	s2,0(a5)
 4f6:	22090a63          	beqz	s2,72a <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 4fa:	0009079b          	sext.w	a5,s2
    if (state == 0) {
 4fe:	fe0994e3          	bnez	s3,4e6 <vprintf+0x46>
      if (c0 == '%') {
 502:	fd579de3          	bne	a5,s5,4dc <vprintf+0x3c>
        state = '%';
 506:	89be                	mv	s3,a5
 508:	b7cd                	j	4ea <vprintf+0x4a>
        c1 = fmt[i + 1] & 0xff;
 50a:	00ea06b3          	add	a3,s4,a4
 50e:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 512:	8636                	mv	a2,a3
      if (c1)
 514:	c681                	beqz	a3,51c <vprintf+0x7c>
        c2 = fmt[i + 2] & 0xff;
 516:	9752                	add	a4,a4,s4
 518:	00274603          	lbu	a2,2(a4)
      if (c0 == 'd') {
 51c:	05878363          	beq	a5,s8,562 <vprintf+0xc2>
      } else if (c0 == 'l' && c1 == 'd') {
 520:	05978d63          	beq	a5,s9,57a <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if (c0 == 'u') {
 524:	07500713          	li	a4,117
 528:	0ee78763          	beq	a5,a4,616 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if (c0 == 'x') {
 52c:	07800713          	li	a4,120
 530:	12e78963          	beq	a5,a4,662 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if (c0 == 'p') {
 534:	07000713          	li	a4,112
 538:	14e78e63          	beq	a5,a4,694 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if (c0 == 'c') {
 53c:	06300713          	li	a4,99
 540:	18e78e63          	beq	a5,a4,6dc <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if (c0 == 's') {
 544:	07300713          	li	a4,115
 548:	1ae78463          	beq	a5,a4,6f0 <vprintf+0x250>
        if ((s = va_arg(ap, char *)) == 0)
          s = "(null)";
        for (; *s; s++)
          putc(fd, *s);
      } else if (c0 == '%') {
 54c:	02500713          	li	a4,37
 550:	04e79563          	bne	a5,a4,59a <vprintf+0xfa>
        putc(fd, '%');
 554:	02500593          	li	a1,37
 558:	855a                	mv	a0,s6
 55a:	e8dff0ef          	jal	3e6 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 55e:	4981                	li	s3,0
 560:	b769                	j	4ea <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 562:	008b8913          	addi	s2,s7,8
 566:	4685                	li	a3,1
 568:	4629                	li	a2,10
 56a:	000ba583          	lw	a1,0(s7)
 56e:	855a                	mv	a0,s6
 570:	e95ff0ef          	jal	404 <printint>
 574:	8bca                	mv	s7,s2
      state = 0;
 576:	4981                	li	s3,0
 578:	bf8d                	j	4ea <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'd') {
 57a:	06400793          	li	a5,100
 57e:	02f68963          	beq	a3,a5,5b0 <vprintf+0x110>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 582:	06c00793          	li	a5,108
 586:	04f68263          	beq	a3,a5,5ca <vprintf+0x12a>
      } else if (c0 == 'l' && c1 == 'u') {
 58a:	07500793          	li	a5,117
 58e:	0af68063          	beq	a3,a5,62e <vprintf+0x18e>
      } else if (c0 == 'l' && c1 == 'x') {
 592:	07800793          	li	a5,120
 596:	0ef68263          	beq	a3,a5,67a <vprintf+0x1da>
        putc(fd, '%');
 59a:	02500593          	li	a1,37
 59e:	855a                	mv	a0,s6
 5a0:	e47ff0ef          	jal	3e6 <putc>
        putc(fd, c0);
 5a4:	85ca                	mv	a1,s2
 5a6:	855a                	mv	a0,s6
 5a8:	e3fff0ef          	jal	3e6 <putc>
      state = 0;
 5ac:	4981                	li	s3,0
 5ae:	bf35                	j	4ea <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5b0:	008b8913          	addi	s2,s7,8
 5b4:	4685                	li	a3,1
 5b6:	4629                	li	a2,10
 5b8:	000bb583          	ld	a1,0(s7)
 5bc:	855a                	mv	a0,s6
 5be:	e47ff0ef          	jal	404 <printint>
        i += 1;
 5c2:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c4:	8bca                	mv	s7,s2
      state = 0;
 5c6:	4981                	li	s3,0
        i += 1;
 5c8:	b70d                	j	4ea <vprintf+0x4a>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'd') {
 5ca:	06400793          	li	a5,100
 5ce:	02f60763          	beq	a2,a5,5fc <vprintf+0x15c>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'u') {
 5d2:	07500793          	li	a5,117
 5d6:	06f60963          	beq	a2,a5,648 <vprintf+0x1a8>
      } else if (c0 == 'l' && c1 == 'l' && c2 == 'x') {
 5da:	07800793          	li	a5,120
 5de:	faf61ee3          	bne	a2,a5,59a <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5e2:	008b8913          	addi	s2,s7,8
 5e6:	4681                	li	a3,0
 5e8:	4641                	li	a2,16
 5ea:	000bb583          	ld	a1,0(s7)
 5ee:	855a                	mv	a0,s6
 5f0:	e15ff0ef          	jal	404 <printint>
        i += 2;
 5f4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f6:	8bca                	mv	s7,s2
      state = 0;
 5f8:	4981                	li	s3,0
        i += 2;
 5fa:	bdc5                	j	4ea <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4685                	li	a3,1
 602:	4629                	li	a2,10
 604:	000bb583          	ld	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	dfbff0ef          	jal	404 <printint>
        i += 2;
 60e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 610:	8bca                	mv	s7,s2
      state = 0;
 612:	4981                	li	s3,0
        i += 2;
 614:	bdd9                	j	4ea <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 616:	008b8913          	addi	s2,s7,8
 61a:	4681                	li	a3,0
 61c:	4629                	li	a2,10
 61e:	000be583          	lwu	a1,0(s7)
 622:	855a                	mv	a0,s6
 624:	de1ff0ef          	jal	404 <printint>
 628:	8bca                	mv	s7,s2
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bd7d                	j	4ea <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 62e:	008b8913          	addi	s2,s7,8
 632:	4681                	li	a3,0
 634:	4629                	li	a2,10
 636:	000bb583          	ld	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	dc9ff0ef          	jal	404 <printint>
        i += 1;
 640:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
        i += 1;
 646:	b555                	j	4ea <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 648:	008b8913          	addi	s2,s7,8
 64c:	4681                	li	a3,0
 64e:	4629                	li	a2,10
 650:	000bb583          	ld	a1,0(s7)
 654:	855a                	mv	a0,s6
 656:	dafff0ef          	jal	404 <printint>
        i += 2;
 65a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 65c:	8bca                	mv	s7,s2
      state = 0;
 65e:	4981                	li	s3,0
        i += 2;
 660:	b569                	j	4ea <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 662:	008b8913          	addi	s2,s7,8
 666:	4681                	li	a3,0
 668:	4641                	li	a2,16
 66a:	000be583          	lwu	a1,0(s7)
 66e:	855a                	mv	a0,s6
 670:	d95ff0ef          	jal	404 <printint>
 674:	8bca                	mv	s7,s2
      state = 0;
 676:	4981                	li	s3,0
 678:	bd8d                	j	4ea <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67a:	008b8913          	addi	s2,s7,8
 67e:	4681                	li	a3,0
 680:	4641                	li	a2,16
 682:	000bb583          	ld	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	d7dff0ef          	jal	404 <printint>
        i += 1;
 68c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 68e:	8bca                	mv	s7,s2
      state = 0;
 690:	4981                	li	s3,0
        i += 1;
 692:	bda1                	j	4ea <vprintf+0x4a>
 694:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 696:	008b8d13          	addi	s10,s7,8
 69a:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 69e:	03000593          	li	a1,48
 6a2:	855a                	mv	a0,s6
 6a4:	d43ff0ef          	jal	3e6 <putc>
  putc(fd, 'x');
 6a8:	07800593          	li	a1,120
 6ac:	855a                	mv	a0,s6
 6ae:	d39ff0ef          	jal	3e6 <putc>
 6b2:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b4:	00000b97          	auipc	s7,0x0
 6b8:	2d4b8b93          	addi	s7,s7,724 # 988 <digits>
 6bc:	03c9d793          	srli	a5,s3,0x3c
 6c0:	97de                	add	a5,a5,s7
 6c2:	0007c583          	lbu	a1,0(a5)
 6c6:	855a                	mv	a0,s6
 6c8:	d1fff0ef          	jal	3e6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6cc:	0992                	slli	s3,s3,0x4
 6ce:	397d                	addiw	s2,s2,-1
 6d0:	fe0916e3          	bnez	s2,6bc <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 6d4:	8bea                	mv	s7,s10
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	6d02                	ld	s10,0(sp)
 6da:	bd01                	j	4ea <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 6dc:	008b8913          	addi	s2,s7,8
 6e0:	000bc583          	lbu	a1,0(s7)
 6e4:	855a                	mv	a0,s6
 6e6:	d01ff0ef          	jal	3e6 <putc>
 6ea:	8bca                	mv	s7,s2
      state = 0;
 6ec:	4981                	li	s3,0
 6ee:	bbf5                	j	4ea <vprintf+0x4a>
        if ((s = va_arg(ap, char *)) == 0)
 6f0:	008b8993          	addi	s3,s7,8
 6f4:	000bb903          	ld	s2,0(s7)
 6f8:	00090f63          	beqz	s2,716 <vprintf+0x276>
        for (; *s; s++)
 6fc:	00094583          	lbu	a1,0(s2)
 700:	c195                	beqz	a1,724 <vprintf+0x284>
          putc(fd, *s);
 702:	855a                	mv	a0,s6
 704:	ce3ff0ef          	jal	3e6 <putc>
        for (; *s; s++)
 708:	0905                	addi	s2,s2,1
 70a:	00094583          	lbu	a1,0(s2)
 70e:	f9f5                	bnez	a1,702 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 710:	8bce                	mv	s7,s3
      state = 0;
 712:	4981                	li	s3,0
 714:	bbd9                	j	4ea <vprintf+0x4a>
          s = "(null)";
 716:	00000917          	auipc	s2,0x0
 71a:	26a90913          	addi	s2,s2,618 # 980 <malloc+0x15e>
        for (; *s; s++)
 71e:	02800593          	li	a1,40
 722:	b7c5                	j	702 <vprintf+0x262>
        if ((s = va_arg(ap, char *)) == 0)
 724:	8bce                	mv	s7,s3
      state = 0;
 726:	4981                	li	s3,0
 728:	b3c9                	j	4ea <vprintf+0x4a>
 72a:	64a6                	ld	s1,72(sp)
 72c:	79e2                	ld	s3,56(sp)
 72e:	7a42                	ld	s4,48(sp)
 730:	7aa2                	ld	s5,40(sp)
 732:	7b02                	ld	s6,32(sp)
 734:	6be2                	ld	s7,24(sp)
 736:	6c42                	ld	s8,16(sp)
 738:	6ca2                	ld	s9,8(sp)
    }
  }
}
 73a:	60e6                	ld	ra,88(sp)
 73c:	6446                	ld	s0,80(sp)
 73e:	6906                	ld	s2,64(sp)
 740:	6125                	addi	sp,sp,96
 742:	8082                	ret

0000000000000744 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 744:	715d                	addi	sp,sp,-80
 746:	ec06                	sd	ra,24(sp)
 748:	e822                	sd	s0,16(sp)
 74a:	1000                	addi	s0,sp,32
 74c:	e010                	sd	a2,0(s0)
 74e:	e414                	sd	a3,8(s0)
 750:	e818                	sd	a4,16(s0)
 752:	ec1c                	sd	a5,24(s0)
 754:	03043023          	sd	a6,32(s0)
 758:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 75c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 760:	8622                	mv	a2,s0
 762:	d3fff0ef          	jal	4a0 <vprintf>
}
 766:	60e2                	ld	ra,24(sp)
 768:	6442                	ld	s0,16(sp)
 76a:	6161                	addi	sp,sp,80
 76c:	8082                	ret

000000000000076e <printf>:

void
printf(const char *fmt, ...)
{
 76e:	711d                	addi	sp,sp,-96
 770:	ec06                	sd	ra,24(sp)
 772:	e822                	sd	s0,16(sp)
 774:	1000                	addi	s0,sp,32
 776:	e40c                	sd	a1,8(s0)
 778:	e810                	sd	a2,16(s0)
 77a:	ec14                	sd	a3,24(s0)
 77c:	f018                	sd	a4,32(s0)
 77e:	f41c                	sd	a5,40(s0)
 780:	03043823          	sd	a6,48(s0)
 784:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 788:	00840613          	addi	a2,s0,8
 78c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 790:	85aa                	mv	a1,a0
 792:	4505                	li	a0,1
 794:	d0dff0ef          	jal	4a0 <vprintf>
}
 798:	60e2                	ld	ra,24(sp)
 79a:	6442                	ld	s0,16(sp)
 79c:	6125                	addi	sp,sp,96
 79e:	8082                	ret

00000000000007a0 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7a0:	1141                	addi	sp,sp,-16
 7a2:	e422                	sd	s0,8(sp)
 7a4:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header *)ap - 1;
 7a6:	ff050693          	addi	a3,a0,-16
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7aa:	00001797          	auipc	a5,0x1
 7ae:	6667b783          	ld	a5,1638(a5) # 1e10 <freep>
 7b2:	a02d                	j	7dc <free+0x3c>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if (bp + bp->s.size == p->s.ptr) {
    bp->s.size += p->s.ptr->s.size;
 7b4:	4618                	lw	a4,8(a2)
 7b6:	9f2d                	addw	a4,a4,a1
 7b8:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7bc:	6398                	ld	a4,0(a5)
 7be:	6310                	ld	a2,0(a4)
 7c0:	a83d                	j	7fe <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if (p + p->s.size == bp) {
    p->s.size += bp->s.size;
 7c2:	ff852703          	lw	a4,-8(a0)
 7c6:	9f31                	addw	a4,a4,a2
 7c8:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7ca:	ff053683          	ld	a3,-16(a0)
 7ce:	a091                	j	812 <free+0x72>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7d0:	6398                	ld	a4,0(a5)
 7d2:	00e7e463          	bltu	a5,a4,7da <free+0x3a>
 7d6:	00e6ea63          	bltu	a3,a4,7ea <free+0x4a>
{
 7da:	87ba                	mv	a5,a4
  for (p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7dc:	fed7fae3          	bgeu	a5,a3,7d0 <free+0x30>
 7e0:	6398                	ld	a4,0(a5)
 7e2:	00e6e463          	bltu	a3,a4,7ea <free+0x4a>
    if (p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e6:	fee7eae3          	bltu	a5,a4,7da <free+0x3a>
  if (bp + bp->s.size == p->s.ptr) {
 7ea:	ff852583          	lw	a1,-8(a0)
 7ee:	6390                	ld	a2,0(a5)
 7f0:	02059813          	slli	a6,a1,0x20
 7f4:	01c85713          	srli	a4,a6,0x1c
 7f8:	9736                	add	a4,a4,a3
 7fa:	fae60de3          	beq	a2,a4,7b4 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7fe:	fec53823          	sd	a2,-16(a0)
  if (p + p->s.size == bp) {
 802:	4790                	lw	a2,8(a5)
 804:	02061593          	slli	a1,a2,0x20
 808:	01c5d713          	srli	a4,a1,0x1c
 80c:	973e                	add	a4,a4,a5
 80e:	fae68ae3          	beq	a3,a4,7c2 <free+0x22>
    p->s.ptr = bp->s.ptr;
 812:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 814:	00001717          	auipc	a4,0x1
 818:	5ef73e23          	sd	a5,1532(a4) # 1e10 <freep>
}
 81c:	6422                	ld	s0,8(sp)
 81e:	0141                	addi	sp,sp,16
 820:	8082                	ret

0000000000000822 <malloc>:
  return freep;
}

void *
malloc(uint nbytes)
{
 822:	7139                	addi	sp,sp,-64
 824:	fc06                	sd	ra,56(sp)
 826:	f822                	sd	s0,48(sp)
 828:	f426                	sd	s1,40(sp)
 82a:	ec4e                	sd	s3,24(sp)
 82c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1) / sizeof(Header) + 1;
 82e:	02051493          	slli	s1,a0,0x20
 832:	9081                	srli	s1,s1,0x20
 834:	04bd                	addi	s1,s1,15
 836:	8091                	srli	s1,s1,0x4
 838:	0014899b          	addiw	s3,s1,1
 83c:	0485                	addi	s1,s1,1
  if ((prevp = freep) == 0) {
 83e:	00001517          	auipc	a0,0x1
 842:	5d253503          	ld	a0,1490(a0) # 1e10 <freep>
 846:	c915                	beqz	a0,87a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 848:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 84a:	4798                	lw	a4,8(a5)
 84c:	08977a63          	bgeu	a4,s1,8e0 <malloc+0xbe>
 850:	f04a                	sd	s2,32(sp)
 852:	e852                	sd	s4,16(sp)
 854:	e456                	sd	s5,8(sp)
 856:	e05a                	sd	s6,0(sp)
  if (nu < 4096)
 858:	8a4e                	mv	s4,s3
 85a:	0009871b          	sext.w	a4,s3
 85e:	6685                	lui	a3,0x1
 860:	00d77363          	bgeu	a4,a3,866 <malloc+0x44>
 864:	6a05                	lui	s4,0x1
 866:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 86a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void *)(p + 1);
    }
    if (p == freep)
 86e:	00001917          	auipc	s2,0x1
 872:	5a290913          	addi	s2,s2,1442 # 1e10 <freep>
  if (p == SBRK_ERROR)
 876:	5afd                	li	s5,-1
 878:	a081                	j	8b8 <malloc+0x96>
 87a:	f04a                	sd	s2,32(sp)
 87c:	e852                	sd	s4,16(sp)
 87e:	e456                	sd	s5,8(sp)
 880:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 882:	00001797          	auipc	a5,0x1
 886:	59e78793          	addi	a5,a5,1438 # 1e20 <base>
 88a:	00001717          	auipc	a4,0x1
 88e:	58f73323          	sd	a5,1414(a4) # 1e10 <freep>
 892:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 894:	0007a423          	sw	zero,8(a5)
    if (p->s.size >= nunits) {
 898:	b7c1                	j	858 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 89a:	6398                	ld	a4,0(a5)
 89c:	e118                	sd	a4,0(a0)
 89e:	a8a9                	j	8f8 <malloc+0xd6>
  hp->s.size = nu;
 8a0:	01652423          	sw	s6,8(a0)
  free((void *)(hp + 1));
 8a4:	0541                	addi	a0,a0,16
 8a6:	efbff0ef          	jal	7a0 <free>
  return freep;
 8aa:	00093503          	ld	a0,0(s2)
      if ((p = morecore(nunits)) == 0)
 8ae:	c12d                	beqz	a0,910 <malloc+0xee>
  for (p = prevp->s.ptr;; prevp = p, p = p->s.ptr) {
 8b0:	611c                	ld	a5,0(a0)
    if (p->s.size >= nunits) {
 8b2:	4798                	lw	a4,8(a5)
 8b4:	02977263          	bgeu	a4,s1,8d8 <malloc+0xb6>
    if (p == freep)
 8b8:	00093703          	ld	a4,0(s2)
 8bc:	853e                	mv	a0,a5
 8be:	fef719e3          	bne	a4,a5,8b0 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8c2:	8552                	mv	a0,s4
 8c4:	a47ff0ef          	jal	30a <sbrk>
  if (p == SBRK_ERROR)
 8c8:	fd551ce3          	bne	a0,s5,8a0 <malloc+0x7e>
        return 0;
 8cc:	4501                	li	a0,0
 8ce:	7902                	ld	s2,32(sp)
 8d0:	6a42                	ld	s4,16(sp)
 8d2:	6aa2                	ld	s5,8(sp)
 8d4:	6b02                	ld	s6,0(sp)
 8d6:	a03d                	j	904 <malloc+0xe2>
 8d8:	7902                	ld	s2,32(sp)
 8da:	6a42                	ld	s4,16(sp)
 8dc:	6aa2                	ld	s5,8(sp)
 8de:	6b02                	ld	s6,0(sp)
      if (p->s.size == nunits)
 8e0:	fae48de3          	beq	s1,a4,89a <malloc+0x78>
        p->s.size -= nunits;
 8e4:	4137073b          	subw	a4,a4,s3
 8e8:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ea:	02071693          	slli	a3,a4,0x20
 8ee:	01c6d713          	srli	a4,a3,0x1c
 8f2:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f4:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f8:	00001717          	auipc	a4,0x1
 8fc:	50a73c23          	sd	a0,1304(a4) # 1e10 <freep>
      return (void *)(p + 1);
 900:	01078513          	addi	a0,a5,16
  }
}
 904:	70e2                	ld	ra,56(sp)
 906:	7442                	ld	s0,48(sp)
 908:	74a2                	ld	s1,40(sp)
 90a:	69e2                	ld	s3,24(sp)
 90c:	6121                	addi	sp,sp,64
 90e:	8082                	ret
 910:	7902                	ld	s2,32(sp)
 912:	6a42                	ld	s4,16(sp)
 914:	6aa2                	ld	s5,8(sp)
 916:	6b02                	ld	s6,0(sp)
 918:	b7f5                	j	904 <malloc+0xe2>
