
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	89013103          	ld	sp,-1904(sp) # 80008890 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	013050ef          	jal	ra,80005828 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	03451793          	slli	a5,a0,0x34
    8000002c:	ebb9                	bnez	a5,80000082 <kfree+0x66>
    8000002e:	84aa                	mv	s1,a0
    80000030:	00022797          	auipc	a5,0x22
    80000034:	d2078793          	addi	a5,a5,-736 # 80021d50 <end>
    80000038:	04f56563          	bltu	a0,a5,80000082 <kfree+0x66>
    8000003c:	47c5                	li	a5,17
    8000003e:	07ee                	slli	a5,a5,0x1b
    80000040:	04f57163          	bgeu	a0,a5,80000082 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000044:	6605                	lui	a2,0x1
    80000046:	4585                	li	a1,1
    80000048:	00000097          	auipc	ra,0x0
    8000004c:	132080e7          	jalr	306(ra) # 8000017a <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000050:	00009917          	auipc	s2,0x9
    80000054:	89090913          	addi	s2,s2,-1904 # 800088e0 <kmem>
    80000058:	854a                	mv	a0,s2
    8000005a:	00006097          	auipc	ra,0x6
    8000005e:	1ba080e7          	jalr	442(ra) # 80006214 <acquire>
  r->next = kmem.freelist;
    80000062:	01893783          	ld	a5,24(s2)
    80000066:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000068:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006c:	854a                	mv	a0,s2
    8000006e:	00006097          	auipc	ra,0x6
    80000072:	25a080e7          	jalr	602(ra) # 800062c8 <release>
}
    80000076:	60e2                	ld	ra,24(sp)
    80000078:	6442                	ld	s0,16(sp)
    8000007a:	64a2                	ld	s1,8(sp)
    8000007c:	6902                	ld	s2,0(sp)
    8000007e:	6105                	addi	sp,sp,32
    80000080:	8082                	ret
    panic("kfree");
    80000082:	00008517          	auipc	a0,0x8
    80000086:	f8e50513          	addi	a0,a0,-114 # 80008010 <etext+0x10>
    8000008a:	00006097          	auipc	ra,0x6
    8000008e:	c52080e7          	jalr	-942(ra) # 80005cdc <panic>

0000000080000092 <freerange>:
{
    80000092:	7179                	addi	sp,sp,-48
    80000094:	f406                	sd	ra,40(sp)
    80000096:	f022                	sd	s0,32(sp)
    80000098:	ec26                	sd	s1,24(sp)
    8000009a:	e84a                	sd	s2,16(sp)
    8000009c:	e44e                	sd	s3,8(sp)
    8000009e:	e052                	sd	s4,0(sp)
    800000a0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000a2:	6785                	lui	a5,0x1
    800000a4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    800000a8:	00e504b3          	add	s1,a0,a4
    800000ac:	777d                	lui	a4,0xfffff
    800000ae:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b0:	94be                	add	s1,s1,a5
    800000b2:	0095ee63          	bltu	a1,s1,800000ce <freerange+0x3c>
    800000b6:	892e                	mv	s2,a1
    kfree(p);
    800000b8:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000ba:	6985                	lui	s3,0x1
    kfree(p);
    800000bc:	01448533          	add	a0,s1,s4
    800000c0:	00000097          	auipc	ra,0x0
    800000c4:	f5c080e7          	jalr	-164(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000c8:	94ce                	add	s1,s1,s3
    800000ca:	fe9979e3          	bgeu	s2,s1,800000bc <freerange+0x2a>
}
    800000ce:	70a2                	ld	ra,40(sp)
    800000d0:	7402                	ld	s0,32(sp)
    800000d2:	64e2                	ld	s1,24(sp)
    800000d4:	6942                	ld	s2,16(sp)
    800000d6:	69a2                	ld	s3,8(sp)
    800000d8:	6a02                	ld	s4,0(sp)
    800000da:	6145                	addi	sp,sp,48
    800000dc:	8082                	ret

00000000800000de <kinit>:
{
    800000de:	1141                	addi	sp,sp,-16
    800000e0:	e406                	sd	ra,8(sp)
    800000e2:	e022                	sd	s0,0(sp)
    800000e4:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000e6:	00008597          	auipc	a1,0x8
    800000ea:	f3258593          	addi	a1,a1,-206 # 80008018 <etext+0x18>
    800000ee:	00008517          	auipc	a0,0x8
    800000f2:	7f250513          	addi	a0,a0,2034 # 800088e0 <kmem>
    800000f6:	00006097          	auipc	ra,0x6
    800000fa:	08e080e7          	jalr	142(ra) # 80006184 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000fe:	45c5                	li	a1,17
    80000100:	05ee                	slli	a1,a1,0x1b
    80000102:	00022517          	auipc	a0,0x22
    80000106:	c4e50513          	addi	a0,a0,-946 # 80021d50 <end>
    8000010a:	00000097          	auipc	ra,0x0
    8000010e:	f88080e7          	jalr	-120(ra) # 80000092 <freerange>
}
    80000112:	60a2                	ld	ra,8(sp)
    80000114:	6402                	ld	s0,0(sp)
    80000116:	0141                	addi	sp,sp,16
    80000118:	8082                	ret

000000008000011a <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    8000011a:	1101                	addi	sp,sp,-32
    8000011c:	ec06                	sd	ra,24(sp)
    8000011e:	e822                	sd	s0,16(sp)
    80000120:	e426                	sd	s1,8(sp)
    80000122:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000124:	00008497          	auipc	s1,0x8
    80000128:	7bc48493          	addi	s1,s1,1980 # 800088e0 <kmem>
    8000012c:	8526                	mv	a0,s1
    8000012e:	00006097          	auipc	ra,0x6
    80000132:	0e6080e7          	jalr	230(ra) # 80006214 <acquire>
  r = kmem.freelist;
    80000136:	6c84                	ld	s1,24(s1)
  if(r)
    80000138:	c885                	beqz	s1,80000168 <kalloc+0x4e>
    kmem.freelist = r->next;
    8000013a:	609c                	ld	a5,0(s1)
    8000013c:	00008517          	auipc	a0,0x8
    80000140:	7a450513          	addi	a0,a0,1956 # 800088e0 <kmem>
    80000144:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000146:	00006097          	auipc	ra,0x6
    8000014a:	182080e7          	jalr	386(ra) # 800062c8 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    8000014e:	6605                	lui	a2,0x1
    80000150:	4595                	li	a1,5
    80000152:	8526                	mv	a0,s1
    80000154:	00000097          	auipc	ra,0x0
    80000158:	026080e7          	jalr	38(ra) # 8000017a <memset>
  return (void*)r;
}
    8000015c:	8526                	mv	a0,s1
    8000015e:	60e2                	ld	ra,24(sp)
    80000160:	6442                	ld	s0,16(sp)
    80000162:	64a2                	ld	s1,8(sp)
    80000164:	6105                	addi	sp,sp,32
    80000166:	8082                	ret
  release(&kmem.lock);
    80000168:	00008517          	auipc	a0,0x8
    8000016c:	77850513          	addi	a0,a0,1912 # 800088e0 <kmem>
    80000170:	00006097          	auipc	ra,0x6
    80000174:	158080e7          	jalr	344(ra) # 800062c8 <release>
  if(r)
    80000178:	b7d5                	j	8000015c <kalloc+0x42>

000000008000017a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000017a:	1141                	addi	sp,sp,-16
    8000017c:	e422                	sd	s0,8(sp)
    8000017e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000180:	ca19                	beqz	a2,80000196 <memset+0x1c>
    80000182:	87aa                	mv	a5,a0
    80000184:	1602                	slli	a2,a2,0x20
    80000186:	9201                	srli	a2,a2,0x20
    80000188:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    8000018c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000190:	0785                	addi	a5,a5,1
    80000192:	fee79de3          	bne	a5,a4,8000018c <memset+0x12>
  }
  return dst;
}
    80000196:	6422                	ld	s0,8(sp)
    80000198:	0141                	addi	sp,sp,16
    8000019a:	8082                	ret

000000008000019c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    8000019c:	1141                	addi	sp,sp,-16
    8000019e:	e422                	sd	s0,8(sp)
    800001a0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800001a2:	ca05                	beqz	a2,800001d2 <memcmp+0x36>
    800001a4:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    800001a8:	1682                	slli	a3,a3,0x20
    800001aa:	9281                	srli	a3,a3,0x20
    800001ac:	0685                	addi	a3,a3,1
    800001ae:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800001b0:	00054783          	lbu	a5,0(a0)
    800001b4:	0005c703          	lbu	a4,0(a1)
    800001b8:	00e79863          	bne	a5,a4,800001c8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800001bc:	0505                	addi	a0,a0,1
    800001be:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800001c0:	fed518e3          	bne	a0,a3,800001b0 <memcmp+0x14>
  }

  return 0;
    800001c4:	4501                	li	a0,0
    800001c6:	a019                	j	800001cc <memcmp+0x30>
      return *s1 - *s2;
    800001c8:	40e7853b          	subw	a0,a5,a4
}
    800001cc:	6422                	ld	s0,8(sp)
    800001ce:	0141                	addi	sp,sp,16
    800001d0:	8082                	ret
  return 0;
    800001d2:	4501                	li	a0,0
    800001d4:	bfe5                	j	800001cc <memcmp+0x30>

00000000800001d6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001d6:	1141                	addi	sp,sp,-16
    800001d8:	e422                	sd	s0,8(sp)
    800001da:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    800001dc:	c205                	beqz	a2,800001fc <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001de:	02a5e263          	bltu	a1,a0,80000202 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    800001e2:	1602                	slli	a2,a2,0x20
    800001e4:	9201                	srli	a2,a2,0x20
    800001e6:	00c587b3          	add	a5,a1,a2
{
    800001ea:	872a                	mv	a4,a0
      *d++ = *s++;
    800001ec:	0585                	addi	a1,a1,1
    800001ee:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd2b1>
    800001f0:	fff5c683          	lbu	a3,-1(a1)
    800001f4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    800001f8:	fef59ae3          	bne	a1,a5,800001ec <memmove+0x16>

  return dst;
}
    800001fc:	6422                	ld	s0,8(sp)
    800001fe:	0141                	addi	sp,sp,16
    80000200:	8082                	ret
  if(s < d && s + n > d){
    80000202:	02061693          	slli	a3,a2,0x20
    80000206:	9281                	srli	a3,a3,0x20
    80000208:	00d58733          	add	a4,a1,a3
    8000020c:	fce57be3          	bgeu	a0,a4,800001e2 <memmove+0xc>
    d += n;
    80000210:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000212:	fff6079b          	addiw	a5,a2,-1
    80000216:	1782                	slli	a5,a5,0x20
    80000218:	9381                	srli	a5,a5,0x20
    8000021a:	fff7c793          	not	a5,a5
    8000021e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000220:	177d                	addi	a4,a4,-1
    80000222:	16fd                	addi	a3,a3,-1
    80000224:	00074603          	lbu	a2,0(a4)
    80000228:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    8000022c:	fee79ae3          	bne	a5,a4,80000220 <memmove+0x4a>
    80000230:	b7f1                	j	800001fc <memmove+0x26>

0000000080000232 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000232:	1141                	addi	sp,sp,-16
    80000234:	e406                	sd	ra,8(sp)
    80000236:	e022                	sd	s0,0(sp)
    80000238:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    8000023a:	00000097          	auipc	ra,0x0
    8000023e:	f9c080e7          	jalr	-100(ra) # 800001d6 <memmove>
}
    80000242:	60a2                	ld	ra,8(sp)
    80000244:	6402                	ld	s0,0(sp)
    80000246:	0141                	addi	sp,sp,16
    80000248:	8082                	ret

000000008000024a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    8000024a:	1141                	addi	sp,sp,-16
    8000024c:	e422                	sd	s0,8(sp)
    8000024e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000250:	ce11                	beqz	a2,8000026c <strncmp+0x22>
    80000252:	00054783          	lbu	a5,0(a0)
    80000256:	cf89                	beqz	a5,80000270 <strncmp+0x26>
    80000258:	0005c703          	lbu	a4,0(a1)
    8000025c:	00f71a63          	bne	a4,a5,80000270 <strncmp+0x26>
    n--, p++, q++;
    80000260:	367d                	addiw	a2,a2,-1
    80000262:	0505                	addi	a0,a0,1
    80000264:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000266:	f675                	bnez	a2,80000252 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000268:	4501                	li	a0,0
    8000026a:	a809                	j	8000027c <strncmp+0x32>
    8000026c:	4501                	li	a0,0
    8000026e:	a039                	j	8000027c <strncmp+0x32>
  if(n == 0)
    80000270:	ca09                	beqz	a2,80000282 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000272:	00054503          	lbu	a0,0(a0)
    80000276:	0005c783          	lbu	a5,0(a1)
    8000027a:	9d1d                	subw	a0,a0,a5
}
    8000027c:	6422                	ld	s0,8(sp)
    8000027e:	0141                	addi	sp,sp,16
    80000280:	8082                	ret
    return 0;
    80000282:	4501                	li	a0,0
    80000284:	bfe5                	j	8000027c <strncmp+0x32>

0000000080000286 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000286:	1141                	addi	sp,sp,-16
    80000288:	e422                	sd	s0,8(sp)
    8000028a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000028c:	872a                	mv	a4,a0
    8000028e:	8832                	mv	a6,a2
    80000290:	367d                	addiw	a2,a2,-1
    80000292:	01005963          	blez	a6,800002a4 <strncpy+0x1e>
    80000296:	0705                	addi	a4,a4,1
    80000298:	0005c783          	lbu	a5,0(a1)
    8000029c:	fef70fa3          	sb	a5,-1(a4)
    800002a0:	0585                	addi	a1,a1,1
    800002a2:	f7f5                	bnez	a5,8000028e <strncpy+0x8>
    ;
  while(n-- > 0)
    800002a4:	86ba                	mv	a3,a4
    800002a6:	00c05c63          	blez	a2,800002be <strncpy+0x38>
    *s++ = 0;
    800002aa:	0685                	addi	a3,a3,1
    800002ac:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800002b0:	40d707bb          	subw	a5,a4,a3
    800002b4:	37fd                	addiw	a5,a5,-1
    800002b6:	010787bb          	addw	a5,a5,a6
    800002ba:	fef048e3          	bgtz	a5,800002aa <strncpy+0x24>
  return os;
}
    800002be:	6422                	ld	s0,8(sp)
    800002c0:	0141                	addi	sp,sp,16
    800002c2:	8082                	ret

00000000800002c4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800002c4:	1141                	addi	sp,sp,-16
    800002c6:	e422                	sd	s0,8(sp)
    800002c8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002ca:	02c05363          	blez	a2,800002f0 <safestrcpy+0x2c>
    800002ce:	fff6069b          	addiw	a3,a2,-1
    800002d2:	1682                	slli	a3,a3,0x20
    800002d4:	9281                	srli	a3,a3,0x20
    800002d6:	96ae                	add	a3,a3,a1
    800002d8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    800002da:	00d58963          	beq	a1,a3,800002ec <safestrcpy+0x28>
    800002de:	0585                	addi	a1,a1,1
    800002e0:	0785                	addi	a5,a5,1
    800002e2:	fff5c703          	lbu	a4,-1(a1)
    800002e6:	fee78fa3          	sb	a4,-1(a5)
    800002ea:	fb65                	bnez	a4,800002da <safestrcpy+0x16>
    ;
  *s = 0;
    800002ec:	00078023          	sb	zero,0(a5)
  return os;
}
    800002f0:	6422                	ld	s0,8(sp)
    800002f2:	0141                	addi	sp,sp,16
    800002f4:	8082                	ret

00000000800002f6 <strlen>:

int
strlen(const char *s)
{
    800002f6:	1141                	addi	sp,sp,-16
    800002f8:	e422                	sd	s0,8(sp)
    800002fa:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    800002fc:	00054783          	lbu	a5,0(a0)
    80000300:	cf91                	beqz	a5,8000031c <strlen+0x26>
    80000302:	0505                	addi	a0,a0,1
    80000304:	87aa                	mv	a5,a0
    80000306:	4685                	li	a3,1
    80000308:	9e89                	subw	a3,a3,a0
    8000030a:	00f6853b          	addw	a0,a3,a5
    8000030e:	0785                	addi	a5,a5,1
    80000310:	fff7c703          	lbu	a4,-1(a5)
    80000314:	fb7d                	bnez	a4,8000030a <strlen+0x14>
    ;
  return n;
}
    80000316:	6422                	ld	s0,8(sp)
    80000318:	0141                	addi	sp,sp,16
    8000031a:	8082                	ret
  for(n = 0; s[n]; n++)
    8000031c:	4501                	li	a0,0
    8000031e:	bfe5                	j	80000316 <strlen+0x20>

0000000080000320 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000320:	1141                	addi	sp,sp,-16
    80000322:	e406                	sd	ra,8(sp)
    80000324:	e022                	sd	s0,0(sp)
    80000326:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000328:	00001097          	auipc	ra,0x1
    8000032c:	b56080e7          	jalr	-1194(ra) # 80000e7e <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000330:	00008717          	auipc	a4,0x8
    80000334:	58070713          	addi	a4,a4,1408 # 800088b0 <started>
  if(cpuid() == 0){
    80000338:	c139                	beqz	a0,8000037e <main+0x5e>
    while(started == 0)
    8000033a:	431c                	lw	a5,0(a4)
    8000033c:	2781                	sext.w	a5,a5
    8000033e:	dff5                	beqz	a5,8000033a <main+0x1a>
      ;
    __sync_synchronize();
    80000340:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000344:	00001097          	auipc	ra,0x1
    80000348:	b3a080e7          	jalr	-1222(ra) # 80000e7e <cpuid>
    8000034c:	85aa                	mv	a1,a0
    8000034e:	00008517          	auipc	a0,0x8
    80000352:	cea50513          	addi	a0,a0,-790 # 80008038 <etext+0x38>
    80000356:	00006097          	auipc	ra,0x6
    8000035a:	9d0080e7          	jalr	-1584(ra) # 80005d26 <printf>
    kvminithart();    // turn on paging
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	0d8080e7          	jalr	216(ra) # 80000436 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000366:	00002097          	auipc	ra,0x2
    8000036a:	8a2080e7          	jalr	-1886(ra) # 80001c08 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000036e:	00005097          	auipc	ra,0x5
    80000372:	e72080e7          	jalr	-398(ra) # 800051e0 <plicinithart>
  }

  scheduler();        
    80000376:	00001097          	auipc	ra,0x1
    8000037a:	02a080e7          	jalr	42(ra) # 800013a0 <scheduler>
    consoleinit();
    8000037e:	00006097          	auipc	ra,0x6
    80000382:	86e080e7          	jalr	-1938(ra) # 80005bec <consoleinit>
    printfinit();
    80000386:	00006097          	auipc	ra,0x6
    8000038a:	b80080e7          	jalr	-1152(ra) # 80005f06 <printfinit>
    printf("\n");
    8000038e:	00008517          	auipc	a0,0x8
    80000392:	cba50513          	addi	a0,a0,-838 # 80008048 <etext+0x48>
    80000396:	00006097          	auipc	ra,0x6
    8000039a:	990080e7          	jalr	-1648(ra) # 80005d26 <printf>
    printf("xv6 kernel is booting\n");
    8000039e:	00008517          	auipc	a0,0x8
    800003a2:	c8250513          	addi	a0,a0,-894 # 80008020 <etext+0x20>
    800003a6:	00006097          	auipc	ra,0x6
    800003aa:	980080e7          	jalr	-1664(ra) # 80005d26 <printf>
    printf("\n");
    800003ae:	00008517          	auipc	a0,0x8
    800003b2:	c9a50513          	addi	a0,a0,-870 # 80008048 <etext+0x48>
    800003b6:	00006097          	auipc	ra,0x6
    800003ba:	970080e7          	jalr	-1680(ra) # 80005d26 <printf>
    kinit();         // physical page allocator
    800003be:	00000097          	auipc	ra,0x0
    800003c2:	d20080e7          	jalr	-736(ra) # 800000de <kinit>
    kvminit();       // create kernel page table
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	326080e7          	jalr	806(ra) # 800006ec <kvminit>
    kvminithart();   // turn on paging
    800003ce:	00000097          	auipc	ra,0x0
    800003d2:	068080e7          	jalr	104(ra) # 80000436 <kvminithart>
    procinit();      // process table
    800003d6:	00001097          	auipc	ra,0x1
    800003da:	9f4080e7          	jalr	-1548(ra) # 80000dca <procinit>
    trapinit();      // trap vectors
    800003de:	00002097          	auipc	ra,0x2
    800003e2:	802080e7          	jalr	-2046(ra) # 80001be0 <trapinit>
    trapinithart();  // install kernel trap vector
    800003e6:	00002097          	auipc	ra,0x2
    800003ea:	822080e7          	jalr	-2014(ra) # 80001c08 <trapinithart>
    plicinit();      // set up interrupt controller
    800003ee:	00005097          	auipc	ra,0x5
    800003f2:	ddc080e7          	jalr	-548(ra) # 800051ca <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800003f6:	00005097          	auipc	ra,0x5
    800003fa:	dea080e7          	jalr	-534(ra) # 800051e0 <plicinithart>
    binit();         // buffer cache
    800003fe:	00002097          	auipc	ra,0x2
    80000402:	f82080e7          	jalr	-126(ra) # 80002380 <binit>
    iinit();         // inode table
    80000406:	00002097          	auipc	ra,0x2
    8000040a:	622080e7          	jalr	1570(ra) # 80002a28 <iinit>
    fileinit();      // file table
    8000040e:	00003097          	auipc	ra,0x3
    80000412:	5c8080e7          	jalr	1480(ra) # 800039d6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000416:	00005097          	auipc	ra,0x5
    8000041a:	ed2080e7          	jalr	-302(ra) # 800052e8 <virtio_disk_init>
    userinit();      // first user process
    8000041e:	00001097          	auipc	ra,0x1
    80000422:	d64080e7          	jalr	-668(ra) # 80001182 <userinit>
    __sync_synchronize();
    80000426:	0ff0000f          	fence
    started = 1;
    8000042a:	4785                	li	a5,1
    8000042c:	00008717          	auipc	a4,0x8
    80000430:	48f72223          	sw	a5,1156(a4) # 800088b0 <started>
    80000434:	b789                	j	80000376 <main+0x56>

0000000080000436 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000436:	1141                	addi	sp,sp,-16
    80000438:	e422                	sd	s0,8(sp)
    8000043a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000043c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000440:	00008797          	auipc	a5,0x8
    80000444:	4787b783          	ld	a5,1144(a5) # 800088b8 <kernel_pagetable>
    80000448:	83b1                	srli	a5,a5,0xc
    8000044a:	577d                	li	a4,-1
    8000044c:	177e                	slli	a4,a4,0x3f
    8000044e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000450:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000454:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000458:	6422                	ld	s0,8(sp)
    8000045a:	0141                	addi	sp,sp,16
    8000045c:	8082                	ret

000000008000045e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000045e:	7139                	addi	sp,sp,-64
    80000460:	fc06                	sd	ra,56(sp)
    80000462:	f822                	sd	s0,48(sp)
    80000464:	f426                	sd	s1,40(sp)
    80000466:	f04a                	sd	s2,32(sp)
    80000468:	ec4e                	sd	s3,24(sp)
    8000046a:	e852                	sd	s4,16(sp)
    8000046c:	e456                	sd	s5,8(sp)
    8000046e:	e05a                	sd	s6,0(sp)
    80000470:	0080                	addi	s0,sp,64
    80000472:	84aa                	mv	s1,a0
    80000474:	89ae                	mv	s3,a1
    80000476:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000478:	57fd                	li	a5,-1
    8000047a:	83e9                	srli	a5,a5,0x1a
    8000047c:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000047e:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000480:	04b7f263          	bgeu	a5,a1,800004c4 <walk+0x66>
    panic("walk");
    80000484:	00008517          	auipc	a0,0x8
    80000488:	bcc50513          	addi	a0,a0,-1076 # 80008050 <etext+0x50>
    8000048c:	00006097          	auipc	ra,0x6
    80000490:	850080e7          	jalr	-1968(ra) # 80005cdc <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000494:	060a8663          	beqz	s5,80000500 <walk+0xa2>
    80000498:	00000097          	auipc	ra,0x0
    8000049c:	c82080e7          	jalr	-894(ra) # 8000011a <kalloc>
    800004a0:	84aa                	mv	s1,a0
    800004a2:	c529                	beqz	a0,800004ec <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800004a4:	6605                	lui	a2,0x1
    800004a6:	4581                	li	a1,0
    800004a8:	00000097          	auipc	ra,0x0
    800004ac:	cd2080e7          	jalr	-814(ra) # 8000017a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004b0:	00c4d793          	srli	a5,s1,0xc
    800004b4:	07aa                	slli	a5,a5,0xa
    800004b6:	0017e793          	ori	a5,a5,1
    800004ba:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800004be:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd2a7>
    800004c0:	036a0063          	beq	s4,s6,800004e0 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800004c4:	0149d933          	srl	s2,s3,s4
    800004c8:	1ff97913          	andi	s2,s2,511
    800004cc:	090e                	slli	s2,s2,0x3
    800004ce:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800004d0:	00093483          	ld	s1,0(s2)
    800004d4:	0014f793          	andi	a5,s1,1
    800004d8:	dfd5                	beqz	a5,80000494 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800004da:	80a9                	srli	s1,s1,0xa
    800004dc:	04b2                	slli	s1,s1,0xc
    800004de:	b7c5                	j	800004be <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800004e0:	00c9d513          	srli	a0,s3,0xc
    800004e4:	1ff57513          	andi	a0,a0,511
    800004e8:	050e                	slli	a0,a0,0x3
    800004ea:	9526                	add	a0,a0,s1
}
    800004ec:	70e2                	ld	ra,56(sp)
    800004ee:	7442                	ld	s0,48(sp)
    800004f0:	74a2                	ld	s1,40(sp)
    800004f2:	7902                	ld	s2,32(sp)
    800004f4:	69e2                	ld	s3,24(sp)
    800004f6:	6a42                	ld	s4,16(sp)
    800004f8:	6aa2                	ld	s5,8(sp)
    800004fa:	6b02                	ld	s6,0(sp)
    800004fc:	6121                	addi	sp,sp,64
    800004fe:	8082                	ret
        return 0;
    80000500:	4501                	li	a0,0
    80000502:	b7ed                	j	800004ec <walk+0x8e>

0000000080000504 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000504:	57fd                	li	a5,-1
    80000506:	83e9                	srli	a5,a5,0x1a
    80000508:	00b7f463          	bgeu	a5,a1,80000510 <walkaddr+0xc>
    return 0;
    8000050c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000050e:	8082                	ret
{
    80000510:	1141                	addi	sp,sp,-16
    80000512:	e406                	sd	ra,8(sp)
    80000514:	e022                	sd	s0,0(sp)
    80000516:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000518:	4601                	li	a2,0
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	f44080e7          	jalr	-188(ra) # 8000045e <walk>
  if(pte == 0)
    80000522:	c105                	beqz	a0,80000542 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80000524:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000526:	0117f693          	andi	a3,a5,17
    8000052a:	4745                	li	a4,17
    return 0;
    8000052c:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000052e:	00e68663          	beq	a3,a4,8000053a <walkaddr+0x36>
}
    80000532:	60a2                	ld	ra,8(sp)
    80000534:	6402                	ld	s0,0(sp)
    80000536:	0141                	addi	sp,sp,16
    80000538:	8082                	ret
  pa = PTE2PA(*pte);
    8000053a:	83a9                	srli	a5,a5,0xa
    8000053c:	00c79513          	slli	a0,a5,0xc
  return pa;
    80000540:	bfcd                	j	80000532 <walkaddr+0x2e>
    return 0;
    80000542:	4501                	li	a0,0
    80000544:	b7fd                	j	80000532 <walkaddr+0x2e>

0000000080000546 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000546:	715d                	addi	sp,sp,-80
    80000548:	e486                	sd	ra,72(sp)
    8000054a:	e0a2                	sd	s0,64(sp)
    8000054c:	fc26                	sd	s1,56(sp)
    8000054e:	f84a                	sd	s2,48(sp)
    80000550:	f44e                	sd	s3,40(sp)
    80000552:	f052                	sd	s4,32(sp)
    80000554:	ec56                	sd	s5,24(sp)
    80000556:	e85a                	sd	s6,16(sp)
    80000558:	e45e                	sd	s7,8(sp)
    8000055a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    8000055c:	c639                	beqz	a2,800005aa <mappages+0x64>
    8000055e:	8aaa                	mv	s5,a0
    80000560:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    80000562:	777d                	lui	a4,0xfffff
    80000564:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    80000568:	fff58993          	addi	s3,a1,-1
    8000056c:	99b2                	add	s3,s3,a2
    8000056e:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    80000572:	893e                	mv	s2,a5
    80000574:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    80000578:	6b85                	lui	s7,0x1
    8000057a:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    8000057e:	4605                	li	a2,1
    80000580:	85ca                	mv	a1,s2
    80000582:	8556                	mv	a0,s5
    80000584:	00000097          	auipc	ra,0x0
    80000588:	eda080e7          	jalr	-294(ra) # 8000045e <walk>
    8000058c:	cd1d                	beqz	a0,800005ca <mappages+0x84>
    if(*pte & PTE_V)
    8000058e:	611c                	ld	a5,0(a0)
    80000590:	8b85                	andi	a5,a5,1
    80000592:	e785                	bnez	a5,800005ba <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80000594:	80b1                	srli	s1,s1,0xc
    80000596:	04aa                	slli	s1,s1,0xa
    80000598:	0164e4b3          	or	s1,s1,s6
    8000059c:	0014e493          	ori	s1,s1,1
    800005a0:	e104                	sd	s1,0(a0)
    if(a == last)
    800005a2:	05390063          	beq	s2,s3,800005e2 <mappages+0x9c>
    a += PGSIZE;
    800005a6:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800005a8:	bfc9                	j	8000057a <mappages+0x34>
    panic("mappages: size");
    800005aa:	00008517          	auipc	a0,0x8
    800005ae:	aae50513          	addi	a0,a0,-1362 # 80008058 <etext+0x58>
    800005b2:	00005097          	auipc	ra,0x5
    800005b6:	72a080e7          	jalr	1834(ra) # 80005cdc <panic>
      panic("mappages: remap");
    800005ba:	00008517          	auipc	a0,0x8
    800005be:	aae50513          	addi	a0,a0,-1362 # 80008068 <etext+0x68>
    800005c2:	00005097          	auipc	ra,0x5
    800005c6:	71a080e7          	jalr	1818(ra) # 80005cdc <panic>
      return -1;
    800005ca:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800005cc:	60a6                	ld	ra,72(sp)
    800005ce:	6406                	ld	s0,64(sp)
    800005d0:	74e2                	ld	s1,56(sp)
    800005d2:	7942                	ld	s2,48(sp)
    800005d4:	79a2                	ld	s3,40(sp)
    800005d6:	7a02                	ld	s4,32(sp)
    800005d8:	6ae2                	ld	s5,24(sp)
    800005da:	6b42                	ld	s6,16(sp)
    800005dc:	6ba2                	ld	s7,8(sp)
    800005de:	6161                	addi	sp,sp,80
    800005e0:	8082                	ret
  return 0;
    800005e2:	4501                	li	a0,0
    800005e4:	b7e5                	j	800005cc <mappages+0x86>

00000000800005e6 <kvmmap>:
{
    800005e6:	1141                	addi	sp,sp,-16
    800005e8:	e406                	sd	ra,8(sp)
    800005ea:	e022                	sd	s0,0(sp)
    800005ec:	0800                	addi	s0,sp,16
    800005ee:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800005f0:	86b2                	mv	a3,a2
    800005f2:	863e                	mv	a2,a5
    800005f4:	00000097          	auipc	ra,0x0
    800005f8:	f52080e7          	jalr	-174(ra) # 80000546 <mappages>
    800005fc:	e509                	bnez	a0,80000606 <kvmmap+0x20>
}
    800005fe:	60a2                	ld	ra,8(sp)
    80000600:	6402                	ld	s0,0(sp)
    80000602:	0141                	addi	sp,sp,16
    80000604:	8082                	ret
    panic("kvmmap");
    80000606:	00008517          	auipc	a0,0x8
    8000060a:	a7250513          	addi	a0,a0,-1422 # 80008078 <etext+0x78>
    8000060e:	00005097          	auipc	ra,0x5
    80000612:	6ce080e7          	jalr	1742(ra) # 80005cdc <panic>

0000000080000616 <kvmmake>:
{
    80000616:	1101                	addi	sp,sp,-32
    80000618:	ec06                	sd	ra,24(sp)
    8000061a:	e822                	sd	s0,16(sp)
    8000061c:	e426                	sd	s1,8(sp)
    8000061e:	e04a                	sd	s2,0(sp)
    80000620:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000622:	00000097          	auipc	ra,0x0
    80000626:	af8080e7          	jalr	-1288(ra) # 8000011a <kalloc>
    8000062a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000062c:	6605                	lui	a2,0x1
    8000062e:	4581                	li	a1,0
    80000630:	00000097          	auipc	ra,0x0
    80000634:	b4a080e7          	jalr	-1206(ra) # 8000017a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000638:	4719                	li	a4,6
    8000063a:	6685                	lui	a3,0x1
    8000063c:	10000637          	lui	a2,0x10000
    80000640:	100005b7          	lui	a1,0x10000
    80000644:	8526                	mv	a0,s1
    80000646:	00000097          	auipc	ra,0x0
    8000064a:	fa0080e7          	jalr	-96(ra) # 800005e6 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000064e:	4719                	li	a4,6
    80000650:	6685                	lui	a3,0x1
    80000652:	10001637          	lui	a2,0x10001
    80000656:	100015b7          	lui	a1,0x10001
    8000065a:	8526                	mv	a0,s1
    8000065c:	00000097          	auipc	ra,0x0
    80000660:	f8a080e7          	jalr	-118(ra) # 800005e6 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    80000664:	4719                	li	a4,6
    80000666:	004006b7          	lui	a3,0x400
    8000066a:	0c000637          	lui	a2,0xc000
    8000066e:	0c0005b7          	lui	a1,0xc000
    80000672:	8526                	mv	a0,s1
    80000674:	00000097          	auipc	ra,0x0
    80000678:	f72080e7          	jalr	-142(ra) # 800005e6 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000067c:	00008917          	auipc	s2,0x8
    80000680:	98490913          	addi	s2,s2,-1660 # 80008000 <etext>
    80000684:	4729                	li	a4,10
    80000686:	80008697          	auipc	a3,0x80008
    8000068a:	97a68693          	addi	a3,a3,-1670 # 8000 <_entry-0x7fff8000>
    8000068e:	4605                	li	a2,1
    80000690:	067e                	slli	a2,a2,0x1f
    80000692:	85b2                	mv	a1,a2
    80000694:	8526                	mv	a0,s1
    80000696:	00000097          	auipc	ra,0x0
    8000069a:	f50080e7          	jalr	-176(ra) # 800005e6 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000069e:	4719                	li	a4,6
    800006a0:	46c5                	li	a3,17
    800006a2:	06ee                	slli	a3,a3,0x1b
    800006a4:	412686b3          	sub	a3,a3,s2
    800006a8:	864a                	mv	a2,s2
    800006aa:	85ca                	mv	a1,s2
    800006ac:	8526                	mv	a0,s1
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	f38080e7          	jalr	-200(ra) # 800005e6 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800006b6:	4729                	li	a4,10
    800006b8:	6685                	lui	a3,0x1
    800006ba:	00007617          	auipc	a2,0x7
    800006be:	94660613          	addi	a2,a2,-1722 # 80007000 <_trampoline>
    800006c2:	040005b7          	lui	a1,0x4000
    800006c6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800006c8:	05b2                	slli	a1,a1,0xc
    800006ca:	8526                	mv	a0,s1
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	f1a080e7          	jalr	-230(ra) # 800005e6 <kvmmap>
  proc_mapstacks(kpgtbl);
    800006d4:	8526                	mv	a0,s1
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	65e080e7          	jalr	1630(ra) # 80000d34 <proc_mapstacks>
}
    800006de:	8526                	mv	a0,s1
    800006e0:	60e2                	ld	ra,24(sp)
    800006e2:	6442                	ld	s0,16(sp)
    800006e4:	64a2                	ld	s1,8(sp)
    800006e6:	6902                	ld	s2,0(sp)
    800006e8:	6105                	addi	sp,sp,32
    800006ea:	8082                	ret

00000000800006ec <kvminit>:
{
    800006ec:	1141                	addi	sp,sp,-16
    800006ee:	e406                	sd	ra,8(sp)
    800006f0:	e022                	sd	s0,0(sp)
    800006f2:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	f22080e7          	jalr	-222(ra) # 80000616 <kvmmake>
    800006fc:	00008797          	auipc	a5,0x8
    80000700:	1aa7be23          	sd	a0,444(a5) # 800088b8 <kernel_pagetable>
}
    80000704:	60a2                	ld	ra,8(sp)
    80000706:	6402                	ld	s0,0(sp)
    80000708:	0141                	addi	sp,sp,16
    8000070a:	8082                	ret

000000008000070c <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000070c:	715d                	addi	sp,sp,-80
    8000070e:	e486                	sd	ra,72(sp)
    80000710:	e0a2                	sd	s0,64(sp)
    80000712:	fc26                	sd	s1,56(sp)
    80000714:	f84a                	sd	s2,48(sp)
    80000716:	f44e                	sd	s3,40(sp)
    80000718:	f052                	sd	s4,32(sp)
    8000071a:	ec56                	sd	s5,24(sp)
    8000071c:	e85a                	sd	s6,16(sp)
    8000071e:	e45e                	sd	s7,8(sp)
    80000720:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000722:	03459793          	slli	a5,a1,0x34
    80000726:	e795                	bnez	a5,80000752 <uvmunmap+0x46>
    80000728:	8a2a                	mv	s4,a0
    8000072a:	892e                	mv	s2,a1
    8000072c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000072e:	0632                	slli	a2,a2,0xc
    80000730:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80000734:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000736:	6b05                	lui	s6,0x1
    80000738:	0735e263          	bltu	a1,s3,8000079c <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000073c:	60a6                	ld	ra,72(sp)
    8000073e:	6406                	ld	s0,64(sp)
    80000740:	74e2                	ld	s1,56(sp)
    80000742:	7942                	ld	s2,48(sp)
    80000744:	79a2                	ld	s3,40(sp)
    80000746:	7a02                	ld	s4,32(sp)
    80000748:	6ae2                	ld	s5,24(sp)
    8000074a:	6b42                	ld	s6,16(sp)
    8000074c:	6ba2                	ld	s7,8(sp)
    8000074e:	6161                	addi	sp,sp,80
    80000750:	8082                	ret
    panic("uvmunmap: not aligned");
    80000752:	00008517          	auipc	a0,0x8
    80000756:	92e50513          	addi	a0,a0,-1746 # 80008080 <etext+0x80>
    8000075a:	00005097          	auipc	ra,0x5
    8000075e:	582080e7          	jalr	1410(ra) # 80005cdc <panic>
      panic("uvmunmap: walk");
    80000762:	00008517          	auipc	a0,0x8
    80000766:	93650513          	addi	a0,a0,-1738 # 80008098 <etext+0x98>
    8000076a:	00005097          	auipc	ra,0x5
    8000076e:	572080e7          	jalr	1394(ra) # 80005cdc <panic>
      panic("uvmunmap: not mapped");
    80000772:	00008517          	auipc	a0,0x8
    80000776:	93650513          	addi	a0,a0,-1738 # 800080a8 <etext+0xa8>
    8000077a:	00005097          	auipc	ra,0x5
    8000077e:	562080e7          	jalr	1378(ra) # 80005cdc <panic>
      panic("uvmunmap: not a leaf");
    80000782:	00008517          	auipc	a0,0x8
    80000786:	93e50513          	addi	a0,a0,-1730 # 800080c0 <etext+0xc0>
    8000078a:	00005097          	auipc	ra,0x5
    8000078e:	552080e7          	jalr	1362(ra) # 80005cdc <panic>
    *pte = 0;
    80000792:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000796:	995a                	add	s2,s2,s6
    80000798:	fb3972e3          	bgeu	s2,s3,8000073c <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000079c:	4601                	li	a2,0
    8000079e:	85ca                	mv	a1,s2
    800007a0:	8552                	mv	a0,s4
    800007a2:	00000097          	auipc	ra,0x0
    800007a6:	cbc080e7          	jalr	-836(ra) # 8000045e <walk>
    800007aa:	84aa                	mv	s1,a0
    800007ac:	d95d                	beqz	a0,80000762 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800007ae:	6108                	ld	a0,0(a0)
    800007b0:	00157793          	andi	a5,a0,1
    800007b4:	dfdd                	beqz	a5,80000772 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800007b6:	3ff57793          	andi	a5,a0,1023
    800007ba:	fd7784e3          	beq	a5,s7,80000782 <uvmunmap+0x76>
    if(do_free){
    800007be:	fc0a8ae3          	beqz	s5,80000792 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800007c2:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800007c4:	0532                	slli	a0,a0,0xc
    800007c6:	00000097          	auipc	ra,0x0
    800007ca:	856080e7          	jalr	-1962(ra) # 8000001c <kfree>
    800007ce:	b7d1                	j	80000792 <uvmunmap+0x86>

00000000800007d0 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800007d0:	1101                	addi	sp,sp,-32
    800007d2:	ec06                	sd	ra,24(sp)
    800007d4:	e822                	sd	s0,16(sp)
    800007d6:	e426                	sd	s1,8(sp)
    800007d8:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800007da:	00000097          	auipc	ra,0x0
    800007de:	940080e7          	jalr	-1728(ra) # 8000011a <kalloc>
    800007e2:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800007e4:	c519                	beqz	a0,800007f2 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800007e6:	6605                	lui	a2,0x1
    800007e8:	4581                	li	a1,0
    800007ea:	00000097          	auipc	ra,0x0
    800007ee:	990080e7          	jalr	-1648(ra) # 8000017a <memset>
  return pagetable;
}
    800007f2:	8526                	mv	a0,s1
    800007f4:	60e2                	ld	ra,24(sp)
    800007f6:	6442                	ld	s0,16(sp)
    800007f8:	64a2                	ld	s1,8(sp)
    800007fa:	6105                	addi	sp,sp,32
    800007fc:	8082                	ret

00000000800007fe <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    800007fe:	7179                	addi	sp,sp,-48
    80000800:	f406                	sd	ra,40(sp)
    80000802:	f022                	sd	s0,32(sp)
    80000804:	ec26                	sd	s1,24(sp)
    80000806:	e84a                	sd	s2,16(sp)
    80000808:	e44e                	sd	s3,8(sp)
    8000080a:	e052                	sd	s4,0(sp)
    8000080c:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000080e:	6785                	lui	a5,0x1
    80000810:	04f67863          	bgeu	a2,a5,80000860 <uvmfirst+0x62>
    80000814:	8a2a                	mv	s4,a0
    80000816:	89ae                	mv	s3,a1
    80000818:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000081a:	00000097          	auipc	ra,0x0
    8000081e:	900080e7          	jalr	-1792(ra) # 8000011a <kalloc>
    80000822:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000824:	6605                	lui	a2,0x1
    80000826:	4581                	li	a1,0
    80000828:	00000097          	auipc	ra,0x0
    8000082c:	952080e7          	jalr	-1710(ra) # 8000017a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80000830:	4779                	li	a4,30
    80000832:	86ca                	mv	a3,s2
    80000834:	6605                	lui	a2,0x1
    80000836:	4581                	li	a1,0
    80000838:	8552                	mv	a0,s4
    8000083a:	00000097          	auipc	ra,0x0
    8000083e:	d0c080e7          	jalr	-756(ra) # 80000546 <mappages>
  memmove(mem, src, sz);
    80000842:	8626                	mv	a2,s1
    80000844:	85ce                	mv	a1,s3
    80000846:	854a                	mv	a0,s2
    80000848:	00000097          	auipc	ra,0x0
    8000084c:	98e080e7          	jalr	-1650(ra) # 800001d6 <memmove>
}
    80000850:	70a2                	ld	ra,40(sp)
    80000852:	7402                	ld	s0,32(sp)
    80000854:	64e2                	ld	s1,24(sp)
    80000856:	6942                	ld	s2,16(sp)
    80000858:	69a2                	ld	s3,8(sp)
    8000085a:	6a02                	ld	s4,0(sp)
    8000085c:	6145                	addi	sp,sp,48
    8000085e:	8082                	ret
    panic("uvmfirst: more than a page");
    80000860:	00008517          	auipc	a0,0x8
    80000864:	87850513          	addi	a0,a0,-1928 # 800080d8 <etext+0xd8>
    80000868:	00005097          	auipc	ra,0x5
    8000086c:	474080e7          	jalr	1140(ra) # 80005cdc <panic>

0000000080000870 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000870:	1101                	addi	sp,sp,-32
    80000872:	ec06                	sd	ra,24(sp)
    80000874:	e822                	sd	s0,16(sp)
    80000876:	e426                	sd	s1,8(sp)
    80000878:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000087a:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000087c:	00b67d63          	bgeu	a2,a1,80000896 <uvmdealloc+0x26>
    80000880:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000882:	6785                	lui	a5,0x1
    80000884:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80000886:	00f60733          	add	a4,a2,a5
    8000088a:	76fd                	lui	a3,0xfffff
    8000088c:	8f75                	and	a4,a4,a3
    8000088e:	97ae                	add	a5,a5,a1
    80000890:	8ff5                	and	a5,a5,a3
    80000892:	00f76863          	bltu	a4,a5,800008a2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80000896:	8526                	mv	a0,s1
    80000898:	60e2                	ld	ra,24(sp)
    8000089a:	6442                	ld	s0,16(sp)
    8000089c:	64a2                	ld	s1,8(sp)
    8000089e:	6105                	addi	sp,sp,32
    800008a0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800008a2:	8f99                	sub	a5,a5,a4
    800008a4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800008a6:	4685                	li	a3,1
    800008a8:	0007861b          	sext.w	a2,a5
    800008ac:	85ba                	mv	a1,a4
    800008ae:	00000097          	auipc	ra,0x0
    800008b2:	e5e080e7          	jalr	-418(ra) # 8000070c <uvmunmap>
    800008b6:	b7c5                	j	80000896 <uvmdealloc+0x26>

00000000800008b8 <uvmalloc>:
  if(newsz < oldsz)
    800008b8:	0ab66563          	bltu	a2,a1,80000962 <uvmalloc+0xaa>
{
    800008bc:	7139                	addi	sp,sp,-64
    800008be:	fc06                	sd	ra,56(sp)
    800008c0:	f822                	sd	s0,48(sp)
    800008c2:	f426                	sd	s1,40(sp)
    800008c4:	f04a                	sd	s2,32(sp)
    800008c6:	ec4e                	sd	s3,24(sp)
    800008c8:	e852                	sd	s4,16(sp)
    800008ca:	e456                	sd	s5,8(sp)
    800008cc:	e05a                	sd	s6,0(sp)
    800008ce:	0080                	addi	s0,sp,64
    800008d0:	8aaa                	mv	s5,a0
    800008d2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800008d4:	6785                	lui	a5,0x1
    800008d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800008d8:	95be                	add	a1,a1,a5
    800008da:	77fd                	lui	a5,0xfffff
    800008dc:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800008e0:	08c9f363          	bgeu	s3,a2,80000966 <uvmalloc+0xae>
    800008e4:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800008e6:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	830080e7          	jalr	-2000(ra) # 8000011a <kalloc>
    800008f2:	84aa                	mv	s1,a0
    if(mem == 0){
    800008f4:	c51d                	beqz	a0,80000922 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    800008f6:	6605                	lui	a2,0x1
    800008f8:	4581                	li	a1,0
    800008fa:	00000097          	auipc	ra,0x0
    800008fe:	880080e7          	jalr	-1920(ra) # 8000017a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000902:	875a                	mv	a4,s6
    80000904:	86a6                	mv	a3,s1
    80000906:	6605                	lui	a2,0x1
    80000908:	85ca                	mv	a1,s2
    8000090a:	8556                	mv	a0,s5
    8000090c:	00000097          	auipc	ra,0x0
    80000910:	c3a080e7          	jalr	-966(ra) # 80000546 <mappages>
    80000914:	e90d                	bnez	a0,80000946 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000916:	6785                	lui	a5,0x1
    80000918:	993e                	add	s2,s2,a5
    8000091a:	fd4968e3          	bltu	s2,s4,800008ea <uvmalloc+0x32>
  return newsz;
    8000091e:	8552                	mv	a0,s4
    80000920:	a809                	j	80000932 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80000922:	864e                	mv	a2,s3
    80000924:	85ca                	mv	a1,s2
    80000926:	8556                	mv	a0,s5
    80000928:	00000097          	auipc	ra,0x0
    8000092c:	f48080e7          	jalr	-184(ra) # 80000870 <uvmdealloc>
      return 0;
    80000930:	4501                	li	a0,0
}
    80000932:	70e2                	ld	ra,56(sp)
    80000934:	7442                	ld	s0,48(sp)
    80000936:	74a2                	ld	s1,40(sp)
    80000938:	7902                	ld	s2,32(sp)
    8000093a:	69e2                	ld	s3,24(sp)
    8000093c:	6a42                	ld	s4,16(sp)
    8000093e:	6aa2                	ld	s5,8(sp)
    80000940:	6b02                	ld	s6,0(sp)
    80000942:	6121                	addi	sp,sp,64
    80000944:	8082                	ret
      kfree(mem);
    80000946:	8526                	mv	a0,s1
    80000948:	fffff097          	auipc	ra,0xfffff
    8000094c:	6d4080e7          	jalr	1748(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000950:	864e                	mv	a2,s3
    80000952:	85ca                	mv	a1,s2
    80000954:	8556                	mv	a0,s5
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	f1a080e7          	jalr	-230(ra) # 80000870 <uvmdealloc>
      return 0;
    8000095e:	4501                	li	a0,0
    80000960:	bfc9                	j	80000932 <uvmalloc+0x7a>
    return oldsz;
    80000962:	852e                	mv	a0,a1
}
    80000964:	8082                	ret
  return newsz;
    80000966:	8532                	mv	a0,a2
    80000968:	b7e9                	j	80000932 <uvmalloc+0x7a>

000000008000096a <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    8000096a:	7179                	addi	sp,sp,-48
    8000096c:	f406                	sd	ra,40(sp)
    8000096e:	f022                	sd	s0,32(sp)
    80000970:	ec26                	sd	s1,24(sp)
    80000972:	e84a                	sd	s2,16(sp)
    80000974:	e44e                	sd	s3,8(sp)
    80000976:	e052                	sd	s4,0(sp)
    80000978:	1800                	addi	s0,sp,48
    8000097a:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    8000097c:	84aa                	mv	s1,a0
    8000097e:	6905                	lui	s2,0x1
    80000980:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000982:	4985                	li	s3,1
    80000984:	a829                	j	8000099e <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000986:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80000988:	00c79513          	slli	a0,a5,0xc
    8000098c:	00000097          	auipc	ra,0x0
    80000990:	fde080e7          	jalr	-34(ra) # 8000096a <freewalk>
      pagetable[i] = 0;
    80000994:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000998:	04a1                	addi	s1,s1,8
    8000099a:	03248163          	beq	s1,s2,800009bc <freewalk+0x52>
    pte_t pte = pagetable[i];
    8000099e:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800009a0:	00f7f713          	andi	a4,a5,15
    800009a4:	ff3701e3          	beq	a4,s3,80000986 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800009a8:	8b85                	andi	a5,a5,1
    800009aa:	d7fd                	beqz	a5,80000998 <freewalk+0x2e>
      panic("freewalk: leaf");
    800009ac:	00007517          	auipc	a0,0x7
    800009b0:	74c50513          	addi	a0,a0,1868 # 800080f8 <etext+0xf8>
    800009b4:	00005097          	auipc	ra,0x5
    800009b8:	328080e7          	jalr	808(ra) # 80005cdc <panic>
    }
  }
  kfree((void*)pagetable);
    800009bc:	8552                	mv	a0,s4
    800009be:	fffff097          	auipc	ra,0xfffff
    800009c2:	65e080e7          	jalr	1630(ra) # 8000001c <kfree>
}
    800009c6:	70a2                	ld	ra,40(sp)
    800009c8:	7402                	ld	s0,32(sp)
    800009ca:	64e2                	ld	s1,24(sp)
    800009cc:	6942                	ld	s2,16(sp)
    800009ce:	69a2                	ld	s3,8(sp)
    800009d0:	6a02                	ld	s4,0(sp)
    800009d2:	6145                	addi	sp,sp,48
    800009d4:	8082                	ret

00000000800009d6 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800009d6:	1101                	addi	sp,sp,-32
    800009d8:	ec06                	sd	ra,24(sp)
    800009da:	e822                	sd	s0,16(sp)
    800009dc:	e426                	sd	s1,8(sp)
    800009de:	1000                	addi	s0,sp,32
    800009e0:	84aa                	mv	s1,a0
  if(sz > 0)
    800009e2:	e999                	bnez	a1,800009f8 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800009e4:	8526                	mv	a0,s1
    800009e6:	00000097          	auipc	ra,0x0
    800009ea:	f84080e7          	jalr	-124(ra) # 8000096a <freewalk>
}
    800009ee:	60e2                	ld	ra,24(sp)
    800009f0:	6442                	ld	s0,16(sp)
    800009f2:	64a2                	ld	s1,8(sp)
    800009f4:	6105                	addi	sp,sp,32
    800009f6:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800009f8:	6785                	lui	a5,0x1
    800009fa:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800009fc:	95be                	add	a1,a1,a5
    800009fe:	4685                	li	a3,1
    80000a00:	00c5d613          	srli	a2,a1,0xc
    80000a04:	4581                	li	a1,0
    80000a06:	00000097          	auipc	ra,0x0
    80000a0a:	d06080e7          	jalr	-762(ra) # 8000070c <uvmunmap>
    80000a0e:	bfd9                	j	800009e4 <uvmfree+0xe>

0000000080000a10 <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;

  // iterate through each page in the old page table.
  for(i = 0; i < sz; i += PGSIZE){
    80000a10:	12060263          	beqz	a2,80000b34 <uvmcopy+0x124>
int uvmcopy(pagetable_t old, pagetable_t new, uint64 sz) {
    80000a14:	7119                	addi	sp,sp,-128
    80000a16:	fc86                	sd	ra,120(sp)
    80000a18:	f8a2                	sd	s0,112(sp)
    80000a1a:	f4a6                	sd	s1,104(sp)
    80000a1c:	f0ca                	sd	s2,96(sp)
    80000a1e:	ecce                	sd	s3,88(sp)
    80000a20:	e8d2                	sd	s4,80(sp)
    80000a22:	e4d6                	sd	s5,72(sp)
    80000a24:	e0da                	sd	s6,64(sp)
    80000a26:	fc5e                	sd	s7,56(sp)
    80000a28:	f862                	sd	s8,48(sp)
    80000a2a:	f466                	sd	s9,40(sp)
    80000a2c:	f06a                	sd	s10,32(sp)
    80000a2e:	ec6e                	sd	s11,24(sp)
    80000a30:	0100                	addi	s0,sp,128
    80000a32:	8daa                	mv	s11,a0
    80000a34:	8cae                	mv	s9,a1
    80000a36:	8d32                	mv	s10,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000a38:	4981                	li	s3,0
    }

    // if the page is writable, adjust the flags for Copy-On-Write.
    if(flags & PTE_W){
      flags = (flags & (~PTE_W)) | PTE_COW; // clear write permission, set COW flag.
      *pte = PA2PTE(pa) | flags; // update the old page table entry with new flags.
    80000a3a:	77fd                	lui	a5,0xfffff
    80000a3c:	8389                	srli	a5,a5,0x2
    80000a3e:	f8f43423          	sd	a5,-120(s0)
    80000a42:	a8ad                	j	80000abc <uvmcopy+0xac>
      panic("uvmcopy: pte should exist"); // panic if the PTE doesn't exist.
    80000a44:	00007517          	auipc	a0,0x7
    80000a48:	6c450513          	addi	a0,a0,1732 # 80008108 <etext+0x108>
    80000a4c:	00005097          	auipc	ra,0x5
    80000a50:	290080e7          	jalr	656(ra) # 80005cdc <panic>
      panic("uvmcopy: page not present"); // panic if the page is not present.
    80000a54:	00007517          	auipc	a0,0x7
    80000a58:	6d450513          	addi	a0,a0,1748 # 80008128 <etext+0x128>
    80000a5c:	00005097          	auipc	ra,0x5
    80000a60:	280080e7          	jalr	640(ra) # 80005cdc <panic>
      kfree(mem); // free the newly allocated memory if mapping fails.
    80000a64:	854a                	mv	a0,s2
    80000a66:	fffff097          	auipc	ra,0xfffff
    80000a6a:	5b6080e7          	jalr	1462(ra) # 8000001c <kfree>
  }

  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000a6e:	4685                	li	a3,1
    80000a70:	00c9d613          	srli	a2,s3,0xc
    80000a74:	4581                	li	a1,0
    80000a76:	8566                	mv	a0,s9
    80000a78:	00000097          	auipc	ra,0x0
    80000a7c:	c94080e7          	jalr	-876(ra) # 8000070c <uvmunmap>
  return -1;
    80000a80:	557d                	li	a0,-1
}
    80000a82:	70e6                	ld	ra,120(sp)
    80000a84:	7446                	ld	s0,112(sp)
    80000a86:	74a6                	ld	s1,104(sp)
    80000a88:	7906                	ld	s2,96(sp)
    80000a8a:	69e6                	ld	s3,88(sp)
    80000a8c:	6a46                	ld	s4,80(sp)
    80000a8e:	6aa6                	ld	s5,72(sp)
    80000a90:	6b06                	ld	s6,64(sp)
    80000a92:	7be2                	ld	s7,56(sp)
    80000a94:	7c42                	ld	s8,48(sp)
    80000a96:	7ca2                	ld	s9,40(sp)
    80000a98:	7d02                	ld	s10,32(sp)
    80000a9a:	6de2                	ld	s11,24(sp)
    80000a9c:	6109                	addi	sp,sp,128
    80000a9e:	8082                	ret
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80000aa0:	8762                	mv	a4,s8
    80000aa2:	86d6                	mv	a3,s5
    80000aa4:	6605                	lui	a2,0x1
    80000aa6:	85ce                	mv	a1,s3
    80000aa8:	8566                	mv	a0,s9
    80000aaa:	00000097          	auipc	ra,0x0
    80000aae:	a9c080e7          	jalr	-1380(ra) # 80000546 <mappages>
    80000ab2:	fd55                	bnez	a0,80000a6e <uvmcopy+0x5e>
  for(i = 0; i < sz; i += PGSIZE){
    80000ab4:	6785                	lui	a5,0x1
    80000ab6:	99be                	add	s3,s3,a5
    80000ab8:	fda9f5e3          	bgeu	s3,s10,80000a82 <uvmcopy+0x72>
    if((pte = walk(old, i, 0)) == 0)
    80000abc:	4601                	li	a2,0
    80000abe:	85ce                	mv	a1,s3
    80000ac0:	856e                	mv	a0,s11
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	99c080e7          	jalr	-1636(ra) # 8000045e <walk>
    80000aca:	8a2a                	mv	s4,a0
    80000acc:	dd25                	beqz	a0,80000a44 <uvmcopy+0x34>
    if((*pte & PTE_V) == 0)
    80000ace:	6104                	ld	s1,0(a0)
    80000ad0:	0014f793          	andi	a5,s1,1
    80000ad4:	d3c1                	beqz	a5,80000a54 <uvmcopy+0x44>
    pa = PTE2PA(*pte); // extract the physical address from the PTE.
    80000ad6:	00a4da93          	srli	s5,s1,0xa
    80000ada:	0ab2                	slli	s5,s5,0xc
    flags = PTE_FLAGS(*pte); // extract the flags from the PTE.
    80000adc:	00048b9b          	sext.w	s7,s1
    80000ae0:	3ff4fc13          	andi	s8,s1,1023
    if((mem = kalloc()) == 0)
    80000ae4:	fffff097          	auipc	ra,0xfffff
    80000ae8:	636080e7          	jalr	1590(ra) # 8000011a <kalloc>
    80000aec:	892a                	mv	s2,a0
    80000aee:	d141                	beqz	a0,80000a6e <uvmcopy+0x5e>
    memmove(mem, (char*)pa, PGSIZE); // copy the contents of the page.
    80000af0:	6605                	lui	a2,0x1
    80000af2:	85d6                	mv	a1,s5
    80000af4:	fffff097          	auipc	ra,0xfffff
    80000af8:	6e2080e7          	jalr	1762(ra) # 800001d6 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000afc:	000c0b1b          	sext.w	s6,s8
    80000b00:	875a                	mv	a4,s6
    80000b02:	86ca                	mv	a3,s2
    80000b04:	6605                	lui	a2,0x1
    80000b06:	85ce                	mv	a1,s3
    80000b08:	8566                	mv	a0,s9
    80000b0a:	00000097          	auipc	ra,0x0
    80000b0e:	a3c080e7          	jalr	-1476(ra) # 80000546 <mappages>
    80000b12:	f929                	bnez	a0,80000a64 <uvmcopy+0x54>
    if(flags & PTE_W){
    80000b14:	004bfb93          	andi	s7,s7,4
    80000b18:	f80b84e3          	beqz	s7,80000aa0 <uvmcopy+0x90>
      flags = (flags & (~PTE_W)) | PTE_COW; // clear write permission, set COW flag.
    80000b1c:	efbb7b13          	andi	s6,s6,-261
    80000b20:	100b6c13          	ori	s8,s6,256
      *pte = PA2PTE(pa) | flags; // update the old page table entry with new flags.
    80000b24:	f8843783          	ld	a5,-120(s0)
    80000b28:	8cfd                	and	s1,s1,a5
    80000b2a:	0184e4b3          	or	s1,s1,s8
    80000b2e:	009a3023          	sd	s1,0(s4)
    80000b32:	b7bd                	j	80000aa0 <uvmcopy+0x90>
  return 0;
    80000b34:	4501                	li	a0,0
}
    80000b36:	8082                	ret

0000000080000b38 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000b38:	1141                	addi	sp,sp,-16
    80000b3a:	e406                	sd	ra,8(sp)
    80000b3c:	e022                	sd	s0,0(sp)
    80000b3e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000b40:	4601                	li	a2,0
    80000b42:	00000097          	auipc	ra,0x0
    80000b46:	91c080e7          	jalr	-1764(ra) # 8000045e <walk>
  if(pte == 0)
    80000b4a:	c901                	beqz	a0,80000b5a <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000b4c:	611c                	ld	a5,0(a0)
    80000b4e:	9bbd                	andi	a5,a5,-17
    80000b50:	e11c                	sd	a5,0(a0)
}
    80000b52:	60a2                	ld	ra,8(sp)
    80000b54:	6402                	ld	s0,0(sp)
    80000b56:	0141                	addi	sp,sp,16
    80000b58:	8082                	ret
    panic("uvmclear");
    80000b5a:	00007517          	auipc	a0,0x7
    80000b5e:	5ee50513          	addi	a0,a0,1518 # 80008148 <etext+0x148>
    80000b62:	00005097          	auipc	ra,0x5
    80000b66:	17a080e7          	jalr	378(ra) # 80005cdc <panic>

0000000080000b6a <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000b6a:	c6bd                	beqz	a3,80000bd8 <copyout+0x6e>
{
    80000b6c:	715d                	addi	sp,sp,-80
    80000b6e:	e486                	sd	ra,72(sp)
    80000b70:	e0a2                	sd	s0,64(sp)
    80000b72:	fc26                	sd	s1,56(sp)
    80000b74:	f84a                	sd	s2,48(sp)
    80000b76:	f44e                	sd	s3,40(sp)
    80000b78:	f052                	sd	s4,32(sp)
    80000b7a:	ec56                	sd	s5,24(sp)
    80000b7c:	e85a                	sd	s6,16(sp)
    80000b7e:	e45e                	sd	s7,8(sp)
    80000b80:	e062                	sd	s8,0(sp)
    80000b82:	0880                	addi	s0,sp,80
    80000b84:	8b2a                	mv	s6,a0
    80000b86:	8c2e                	mv	s8,a1
    80000b88:	8a32                	mv	s4,a2
    80000b8a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000b8c:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80000b8e:	6a85                	lui	s5,0x1
    80000b90:	a015                	j	80000bb4 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000b92:	9562                	add	a0,a0,s8
    80000b94:	0004861b          	sext.w	a2,s1
    80000b98:	85d2                	mv	a1,s4
    80000b9a:	41250533          	sub	a0,a0,s2
    80000b9e:	fffff097          	auipc	ra,0xfffff
    80000ba2:	638080e7          	jalr	1592(ra) # 800001d6 <memmove>

    len -= n;
    80000ba6:	409989b3          	sub	s3,s3,s1
    src += n;
    80000baa:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80000bac:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000bb0:	02098263          	beqz	s3,80000bd4 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000bb4:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000bb8:	85ca                	mv	a1,s2
    80000bba:	855a                	mv	a0,s6
    80000bbc:	00000097          	auipc	ra,0x0
    80000bc0:	948080e7          	jalr	-1720(ra) # 80000504 <walkaddr>
    if(pa0 == 0)
    80000bc4:	cd01                	beqz	a0,80000bdc <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80000bc6:	418904b3          	sub	s1,s2,s8
    80000bca:	94d6                	add	s1,s1,s5
    80000bcc:	fc99f3e3          	bgeu	s3,s1,80000b92 <copyout+0x28>
    80000bd0:	84ce                	mv	s1,s3
    80000bd2:	b7c1                	j	80000b92 <copyout+0x28>
  }
  return 0;
    80000bd4:	4501                	li	a0,0
    80000bd6:	a021                	j	80000bde <copyout+0x74>
    80000bd8:	4501                	li	a0,0
}
    80000bda:	8082                	ret
      return -1;
    80000bdc:	557d                	li	a0,-1
}
    80000bde:	60a6                	ld	ra,72(sp)
    80000be0:	6406                	ld	s0,64(sp)
    80000be2:	74e2                	ld	s1,56(sp)
    80000be4:	7942                	ld	s2,48(sp)
    80000be6:	79a2                	ld	s3,40(sp)
    80000be8:	7a02                	ld	s4,32(sp)
    80000bea:	6ae2                	ld	s5,24(sp)
    80000bec:	6b42                	ld	s6,16(sp)
    80000bee:	6ba2                	ld	s7,8(sp)
    80000bf0:	6c02                	ld	s8,0(sp)
    80000bf2:	6161                	addi	sp,sp,80
    80000bf4:	8082                	ret

0000000080000bf6 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000bf6:	caa5                	beqz	a3,80000c66 <copyin+0x70>
{
    80000bf8:	715d                	addi	sp,sp,-80
    80000bfa:	e486                	sd	ra,72(sp)
    80000bfc:	e0a2                	sd	s0,64(sp)
    80000bfe:	fc26                	sd	s1,56(sp)
    80000c00:	f84a                	sd	s2,48(sp)
    80000c02:	f44e                	sd	s3,40(sp)
    80000c04:	f052                	sd	s4,32(sp)
    80000c06:	ec56                	sd	s5,24(sp)
    80000c08:	e85a                	sd	s6,16(sp)
    80000c0a:	e45e                	sd	s7,8(sp)
    80000c0c:	e062                	sd	s8,0(sp)
    80000c0e:	0880                	addi	s0,sp,80
    80000c10:	8b2a                	mv	s6,a0
    80000c12:	8a2e                	mv	s4,a1
    80000c14:	8c32                	mv	s8,a2
    80000c16:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000c18:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c1a:	6a85                	lui	s5,0x1
    80000c1c:	a01d                	j	80000c42 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000c1e:	018505b3          	add	a1,a0,s8
    80000c22:	0004861b          	sext.w	a2,s1
    80000c26:	412585b3          	sub	a1,a1,s2
    80000c2a:	8552                	mv	a0,s4
    80000c2c:	fffff097          	auipc	ra,0xfffff
    80000c30:	5aa080e7          	jalr	1450(ra) # 800001d6 <memmove>

    len -= n;
    80000c34:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000c38:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000c3a:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000c3e:	02098263          	beqz	s3,80000c62 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80000c42:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000c46:	85ca                	mv	a1,s2
    80000c48:	855a                	mv	a0,s6
    80000c4a:	00000097          	auipc	ra,0x0
    80000c4e:	8ba080e7          	jalr	-1862(ra) # 80000504 <walkaddr>
    if(pa0 == 0)
    80000c52:	cd01                	beqz	a0,80000c6a <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80000c54:	418904b3          	sub	s1,s2,s8
    80000c58:	94d6                	add	s1,s1,s5
    80000c5a:	fc99f2e3          	bgeu	s3,s1,80000c1e <copyin+0x28>
    80000c5e:	84ce                	mv	s1,s3
    80000c60:	bf7d                	j	80000c1e <copyin+0x28>
  }
  return 0;
    80000c62:	4501                	li	a0,0
    80000c64:	a021                	j	80000c6c <copyin+0x76>
    80000c66:	4501                	li	a0,0
}
    80000c68:	8082                	ret
      return -1;
    80000c6a:	557d                	li	a0,-1
}
    80000c6c:	60a6                	ld	ra,72(sp)
    80000c6e:	6406                	ld	s0,64(sp)
    80000c70:	74e2                	ld	s1,56(sp)
    80000c72:	7942                	ld	s2,48(sp)
    80000c74:	79a2                	ld	s3,40(sp)
    80000c76:	7a02                	ld	s4,32(sp)
    80000c78:	6ae2                	ld	s5,24(sp)
    80000c7a:	6b42                	ld	s6,16(sp)
    80000c7c:	6ba2                	ld	s7,8(sp)
    80000c7e:	6c02                	ld	s8,0(sp)
    80000c80:	6161                	addi	sp,sp,80
    80000c82:	8082                	ret

0000000080000c84 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000c84:	c2dd                	beqz	a3,80000d2a <copyinstr+0xa6>
{
    80000c86:	715d                	addi	sp,sp,-80
    80000c88:	e486                	sd	ra,72(sp)
    80000c8a:	e0a2                	sd	s0,64(sp)
    80000c8c:	fc26                	sd	s1,56(sp)
    80000c8e:	f84a                	sd	s2,48(sp)
    80000c90:	f44e                	sd	s3,40(sp)
    80000c92:	f052                	sd	s4,32(sp)
    80000c94:	ec56                	sd	s5,24(sp)
    80000c96:	e85a                	sd	s6,16(sp)
    80000c98:	e45e                	sd	s7,8(sp)
    80000c9a:	0880                	addi	s0,sp,80
    80000c9c:	8a2a                	mv	s4,a0
    80000c9e:	8b2e                	mv	s6,a1
    80000ca0:	8bb2                	mv	s7,a2
    80000ca2:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000ca4:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000ca6:	6985                	lui	s3,0x1
    80000ca8:	a02d                	j	80000cd2 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000caa:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000cae:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000cb0:	37fd                	addiw	a5,a5,-1
    80000cb2:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000cb6:	60a6                	ld	ra,72(sp)
    80000cb8:	6406                	ld	s0,64(sp)
    80000cba:	74e2                	ld	s1,56(sp)
    80000cbc:	7942                	ld	s2,48(sp)
    80000cbe:	79a2                	ld	s3,40(sp)
    80000cc0:	7a02                	ld	s4,32(sp)
    80000cc2:	6ae2                	ld	s5,24(sp)
    80000cc4:	6b42                	ld	s6,16(sp)
    80000cc6:	6ba2                	ld	s7,8(sp)
    80000cc8:	6161                	addi	sp,sp,80
    80000cca:	8082                	ret
    srcva = va0 + PGSIZE;
    80000ccc:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000cd0:	c8a9                	beqz	s1,80000d22 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80000cd2:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000cd6:	85ca                	mv	a1,s2
    80000cd8:	8552                	mv	a0,s4
    80000cda:	00000097          	auipc	ra,0x0
    80000cde:	82a080e7          	jalr	-2006(ra) # 80000504 <walkaddr>
    if(pa0 == 0)
    80000ce2:	c131                	beqz	a0,80000d26 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80000ce4:	417906b3          	sub	a3,s2,s7
    80000ce8:	96ce                	add	a3,a3,s3
    80000cea:	00d4f363          	bgeu	s1,a3,80000cf0 <copyinstr+0x6c>
    80000cee:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000cf0:	955e                	add	a0,a0,s7
    80000cf2:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000cf6:	daf9                	beqz	a3,80000ccc <copyinstr+0x48>
    80000cf8:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000cfa:	41650633          	sub	a2,a0,s6
    80000cfe:	fff48593          	addi	a1,s1,-1
    80000d02:	95da                	add	a1,a1,s6
    while(n > 0){
    80000d04:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80000d06:	00f60733          	add	a4,a2,a5
    80000d0a:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd2b0>
    80000d0e:	df51                	beqz	a4,80000caa <copyinstr+0x26>
        *dst = *p;
    80000d10:	00e78023          	sb	a4,0(a5)
      --max;
    80000d14:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000d18:	0785                	addi	a5,a5,1
    while(n > 0){
    80000d1a:	fed796e3          	bne	a5,a3,80000d06 <copyinstr+0x82>
      dst++;
    80000d1e:	8b3e                	mv	s6,a5
    80000d20:	b775                	j	80000ccc <copyinstr+0x48>
    80000d22:	4781                	li	a5,0
    80000d24:	b771                	j	80000cb0 <copyinstr+0x2c>
      return -1;
    80000d26:	557d                	li	a0,-1
    80000d28:	b779                	j	80000cb6 <copyinstr+0x32>
  int got_null = 0;
    80000d2a:	4781                	li	a5,0
  if(got_null){
    80000d2c:	37fd                	addiw	a5,a5,-1
    80000d2e:	0007851b          	sext.w	a0,a5
}
    80000d32:	8082                	ret

0000000080000d34 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000d34:	7139                	addi	sp,sp,-64
    80000d36:	fc06                	sd	ra,56(sp)
    80000d38:	f822                	sd	s0,48(sp)
    80000d3a:	f426                	sd	s1,40(sp)
    80000d3c:	f04a                	sd	s2,32(sp)
    80000d3e:	ec4e                	sd	s3,24(sp)
    80000d40:	e852                	sd	s4,16(sp)
    80000d42:	e456                	sd	s5,8(sp)
    80000d44:	e05a                	sd	s6,0(sp)
    80000d46:	0080                	addi	s0,sp,64
    80000d48:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d4a:	00008497          	auipc	s1,0x8
    80000d4e:	fe648493          	addi	s1,s1,-26 # 80008d30 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000d52:	8b26                	mv	s6,s1
    80000d54:	00007a97          	auipc	s5,0x7
    80000d58:	2aca8a93          	addi	s5,s5,684 # 80008000 <etext>
    80000d5c:	04000937          	lui	s2,0x4000
    80000d60:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000d62:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d64:	0000ea17          	auipc	s4,0xe
    80000d68:	9cca0a13          	addi	s4,s4,-1588 # 8000e730 <tickslock>
    char *pa = kalloc();
    80000d6c:	fffff097          	auipc	ra,0xfffff
    80000d70:	3ae080e7          	jalr	942(ra) # 8000011a <kalloc>
    80000d74:	862a                	mv	a2,a0
    if(pa == 0)
    80000d76:	c131                	beqz	a0,80000dba <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000d78:	416485b3          	sub	a1,s1,s6
    80000d7c:	858d                	srai	a1,a1,0x3
    80000d7e:	000ab783          	ld	a5,0(s5)
    80000d82:	02f585b3          	mul	a1,a1,a5
    80000d86:	2585                	addiw	a1,a1,1
    80000d88:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000d8c:	4719                	li	a4,6
    80000d8e:	6685                	lui	a3,0x1
    80000d90:	40b905b3          	sub	a1,s2,a1
    80000d94:	854e                	mv	a0,s3
    80000d96:	00000097          	auipc	ra,0x0
    80000d9a:	850080e7          	jalr	-1968(ra) # 800005e6 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d9e:	16848493          	addi	s1,s1,360
    80000da2:	fd4495e3          	bne	s1,s4,80000d6c <proc_mapstacks+0x38>
  }
}
    80000da6:	70e2                	ld	ra,56(sp)
    80000da8:	7442                	ld	s0,48(sp)
    80000daa:	74a2                	ld	s1,40(sp)
    80000dac:	7902                	ld	s2,32(sp)
    80000dae:	69e2                	ld	s3,24(sp)
    80000db0:	6a42                	ld	s4,16(sp)
    80000db2:	6aa2                	ld	s5,8(sp)
    80000db4:	6b02                	ld	s6,0(sp)
    80000db6:	6121                	addi	sp,sp,64
    80000db8:	8082                	ret
      panic("kalloc");
    80000dba:	00007517          	auipc	a0,0x7
    80000dbe:	39e50513          	addi	a0,a0,926 # 80008158 <etext+0x158>
    80000dc2:	00005097          	auipc	ra,0x5
    80000dc6:	f1a080e7          	jalr	-230(ra) # 80005cdc <panic>

0000000080000dca <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000dca:	7139                	addi	sp,sp,-64
    80000dcc:	fc06                	sd	ra,56(sp)
    80000dce:	f822                	sd	s0,48(sp)
    80000dd0:	f426                	sd	s1,40(sp)
    80000dd2:	f04a                	sd	s2,32(sp)
    80000dd4:	ec4e                	sd	s3,24(sp)
    80000dd6:	e852                	sd	s4,16(sp)
    80000dd8:	e456                	sd	s5,8(sp)
    80000dda:	e05a                	sd	s6,0(sp)
    80000ddc:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000dde:	00007597          	auipc	a1,0x7
    80000de2:	38258593          	addi	a1,a1,898 # 80008160 <etext+0x160>
    80000de6:	00008517          	auipc	a0,0x8
    80000dea:	b1a50513          	addi	a0,a0,-1254 # 80008900 <pid_lock>
    80000dee:	00005097          	auipc	ra,0x5
    80000df2:	396080e7          	jalr	918(ra) # 80006184 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000df6:	00007597          	auipc	a1,0x7
    80000dfa:	37258593          	addi	a1,a1,882 # 80008168 <etext+0x168>
    80000dfe:	00008517          	auipc	a0,0x8
    80000e02:	b1a50513          	addi	a0,a0,-1254 # 80008918 <wait_lock>
    80000e06:	00005097          	auipc	ra,0x5
    80000e0a:	37e080e7          	jalr	894(ra) # 80006184 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e0e:	00008497          	auipc	s1,0x8
    80000e12:	f2248493          	addi	s1,s1,-222 # 80008d30 <proc>
      initlock(&p->lock, "proc");
    80000e16:	00007b17          	auipc	s6,0x7
    80000e1a:	362b0b13          	addi	s6,s6,866 # 80008178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000e1e:	8aa6                	mv	s5,s1
    80000e20:	00007a17          	auipc	s4,0x7
    80000e24:	1e0a0a13          	addi	s4,s4,480 # 80008000 <etext>
    80000e28:	04000937          	lui	s2,0x4000
    80000e2c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000e2e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e30:	0000e997          	auipc	s3,0xe
    80000e34:	90098993          	addi	s3,s3,-1792 # 8000e730 <tickslock>
      initlock(&p->lock, "proc");
    80000e38:	85da                	mv	a1,s6
    80000e3a:	8526                	mv	a0,s1
    80000e3c:	00005097          	auipc	ra,0x5
    80000e40:	348080e7          	jalr	840(ra) # 80006184 <initlock>
      p->state = UNUSED;
    80000e44:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000e48:	415487b3          	sub	a5,s1,s5
    80000e4c:	878d                	srai	a5,a5,0x3
    80000e4e:	000a3703          	ld	a4,0(s4)
    80000e52:	02e787b3          	mul	a5,a5,a4
    80000e56:	2785                	addiw	a5,a5,1
    80000e58:	00d7979b          	slliw	a5,a5,0xd
    80000e5c:	40f907b3          	sub	a5,s2,a5
    80000e60:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e62:	16848493          	addi	s1,s1,360
    80000e66:	fd3499e3          	bne	s1,s3,80000e38 <procinit+0x6e>
  }
}
    80000e6a:	70e2                	ld	ra,56(sp)
    80000e6c:	7442                	ld	s0,48(sp)
    80000e6e:	74a2                	ld	s1,40(sp)
    80000e70:	7902                	ld	s2,32(sp)
    80000e72:	69e2                	ld	s3,24(sp)
    80000e74:	6a42                	ld	s4,16(sp)
    80000e76:	6aa2                	ld	s5,8(sp)
    80000e78:	6b02                	ld	s6,0(sp)
    80000e7a:	6121                	addi	sp,sp,64
    80000e7c:	8082                	ret

0000000080000e7e <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000e7e:	1141                	addi	sp,sp,-16
    80000e80:	e422                	sd	s0,8(sp)
    80000e82:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e84:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000e86:	2501                	sext.w	a0,a0
    80000e88:	6422                	ld	s0,8(sp)
    80000e8a:	0141                	addi	sp,sp,16
    80000e8c:	8082                	ret

0000000080000e8e <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000e8e:	1141                	addi	sp,sp,-16
    80000e90:	e422                	sd	s0,8(sp)
    80000e92:	0800                	addi	s0,sp,16
    80000e94:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000e96:	2781                	sext.w	a5,a5
    80000e98:	079e                	slli	a5,a5,0x7
  return c;
}
    80000e9a:	00008517          	auipc	a0,0x8
    80000e9e:	a9650513          	addi	a0,a0,-1386 # 80008930 <cpus>
    80000ea2:	953e                	add	a0,a0,a5
    80000ea4:	6422                	ld	s0,8(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret

0000000080000eaa <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000eaa:	1101                	addi	sp,sp,-32
    80000eac:	ec06                	sd	ra,24(sp)
    80000eae:	e822                	sd	s0,16(sp)
    80000eb0:	e426                	sd	s1,8(sp)
    80000eb2:	1000                	addi	s0,sp,32
  push_off();
    80000eb4:	00005097          	auipc	ra,0x5
    80000eb8:	314080e7          	jalr	788(ra) # 800061c8 <push_off>
    80000ebc:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000ebe:	2781                	sext.w	a5,a5
    80000ec0:	079e                	slli	a5,a5,0x7
    80000ec2:	00008717          	auipc	a4,0x8
    80000ec6:	a3e70713          	addi	a4,a4,-1474 # 80008900 <pid_lock>
    80000eca:	97ba                	add	a5,a5,a4
    80000ecc:	7b84                	ld	s1,48(a5)
  pop_off();
    80000ece:	00005097          	auipc	ra,0x5
    80000ed2:	39a080e7          	jalr	922(ra) # 80006268 <pop_off>
  return p;
}
    80000ed6:	8526                	mv	a0,s1
    80000ed8:	60e2                	ld	ra,24(sp)
    80000eda:	6442                	ld	s0,16(sp)
    80000edc:	64a2                	ld	s1,8(sp)
    80000ede:	6105                	addi	sp,sp,32
    80000ee0:	8082                	ret

0000000080000ee2 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000ee2:	1141                	addi	sp,sp,-16
    80000ee4:	e406                	sd	ra,8(sp)
    80000ee6:	e022                	sd	s0,0(sp)
    80000ee8:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000eea:	00000097          	auipc	ra,0x0
    80000eee:	fc0080e7          	jalr	-64(ra) # 80000eaa <myproc>
    80000ef2:	00005097          	auipc	ra,0x5
    80000ef6:	3d6080e7          	jalr	982(ra) # 800062c8 <release>

  if (first) {
    80000efa:	00008797          	auipc	a5,0x8
    80000efe:	9467a783          	lw	a5,-1722(a5) # 80008840 <first.1>
    80000f02:	eb89                	bnez	a5,80000f14 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80000f04:	00001097          	auipc	ra,0x1
    80000f08:	d1c080e7          	jalr	-740(ra) # 80001c20 <usertrapret>
}
    80000f0c:	60a2                	ld	ra,8(sp)
    80000f0e:	6402                	ld	s0,0(sp)
    80000f10:	0141                	addi	sp,sp,16
    80000f12:	8082                	ret
    first = 0;
    80000f14:	00008797          	auipc	a5,0x8
    80000f18:	9207a623          	sw	zero,-1748(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80000f1c:	4505                	li	a0,1
    80000f1e:	00002097          	auipc	ra,0x2
    80000f22:	a8a080e7          	jalr	-1398(ra) # 800029a8 <fsinit>
    80000f26:	bff9                	j	80000f04 <forkret+0x22>

0000000080000f28 <allocpid>:
{
    80000f28:	1101                	addi	sp,sp,-32
    80000f2a:	ec06                	sd	ra,24(sp)
    80000f2c:	e822                	sd	s0,16(sp)
    80000f2e:	e426                	sd	s1,8(sp)
    80000f30:	e04a                	sd	s2,0(sp)
    80000f32:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000f34:	00008917          	auipc	s2,0x8
    80000f38:	9cc90913          	addi	s2,s2,-1588 # 80008900 <pid_lock>
    80000f3c:	854a                	mv	a0,s2
    80000f3e:	00005097          	auipc	ra,0x5
    80000f42:	2d6080e7          	jalr	726(ra) # 80006214 <acquire>
  pid = nextpid;
    80000f46:	00008797          	auipc	a5,0x8
    80000f4a:	8fe78793          	addi	a5,a5,-1794 # 80008844 <nextpid>
    80000f4e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000f50:	0014871b          	addiw	a4,s1,1
    80000f54:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000f56:	854a                	mv	a0,s2
    80000f58:	00005097          	auipc	ra,0x5
    80000f5c:	370080e7          	jalr	880(ra) # 800062c8 <release>
}
    80000f60:	8526                	mv	a0,s1
    80000f62:	60e2                	ld	ra,24(sp)
    80000f64:	6442                	ld	s0,16(sp)
    80000f66:	64a2                	ld	s1,8(sp)
    80000f68:	6902                	ld	s2,0(sp)
    80000f6a:	6105                	addi	sp,sp,32
    80000f6c:	8082                	ret

0000000080000f6e <proc_pagetable>:
{
    80000f6e:	1101                	addi	sp,sp,-32
    80000f70:	ec06                	sd	ra,24(sp)
    80000f72:	e822                	sd	s0,16(sp)
    80000f74:	e426                	sd	s1,8(sp)
    80000f76:	e04a                	sd	s2,0(sp)
    80000f78:	1000                	addi	s0,sp,32
    80000f7a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000f7c:	00000097          	auipc	ra,0x0
    80000f80:	854080e7          	jalr	-1964(ra) # 800007d0 <uvmcreate>
    80000f84:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000f86:	c121                	beqz	a0,80000fc6 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000f88:	4729                	li	a4,10
    80000f8a:	00006697          	auipc	a3,0x6
    80000f8e:	07668693          	addi	a3,a3,118 # 80007000 <_trampoline>
    80000f92:	6605                	lui	a2,0x1
    80000f94:	040005b7          	lui	a1,0x4000
    80000f98:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f9a:	05b2                	slli	a1,a1,0xc
    80000f9c:	fffff097          	auipc	ra,0xfffff
    80000fa0:	5aa080e7          	jalr	1450(ra) # 80000546 <mappages>
    80000fa4:	02054863          	bltz	a0,80000fd4 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000fa8:	4719                	li	a4,6
    80000faa:	05893683          	ld	a3,88(s2)
    80000fae:	6605                	lui	a2,0x1
    80000fb0:	020005b7          	lui	a1,0x2000
    80000fb4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000fb6:	05b6                	slli	a1,a1,0xd
    80000fb8:	8526                	mv	a0,s1
    80000fba:	fffff097          	auipc	ra,0xfffff
    80000fbe:	58c080e7          	jalr	1420(ra) # 80000546 <mappages>
    80000fc2:	02054163          	bltz	a0,80000fe4 <proc_pagetable+0x76>
}
    80000fc6:	8526                	mv	a0,s1
    80000fc8:	60e2                	ld	ra,24(sp)
    80000fca:	6442                	ld	s0,16(sp)
    80000fcc:	64a2                	ld	s1,8(sp)
    80000fce:	6902                	ld	s2,0(sp)
    80000fd0:	6105                	addi	sp,sp,32
    80000fd2:	8082                	ret
    uvmfree(pagetable, 0);
    80000fd4:	4581                	li	a1,0
    80000fd6:	8526                	mv	a0,s1
    80000fd8:	00000097          	auipc	ra,0x0
    80000fdc:	9fe080e7          	jalr	-1538(ra) # 800009d6 <uvmfree>
    return 0;
    80000fe0:	4481                	li	s1,0
    80000fe2:	b7d5                	j	80000fc6 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000fe4:	4681                	li	a3,0
    80000fe6:	4605                	li	a2,1
    80000fe8:	040005b7          	lui	a1,0x4000
    80000fec:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000fee:	05b2                	slli	a1,a1,0xc
    80000ff0:	8526                	mv	a0,s1
    80000ff2:	fffff097          	auipc	ra,0xfffff
    80000ff6:	71a080e7          	jalr	1818(ra) # 8000070c <uvmunmap>
    uvmfree(pagetable, 0);
    80000ffa:	4581                	li	a1,0
    80000ffc:	8526                	mv	a0,s1
    80000ffe:	00000097          	auipc	ra,0x0
    80001002:	9d8080e7          	jalr	-1576(ra) # 800009d6 <uvmfree>
    return 0;
    80001006:	4481                	li	s1,0
    80001008:	bf7d                	j	80000fc6 <proc_pagetable+0x58>

000000008000100a <proc_freepagetable>:
{
    8000100a:	1101                	addi	sp,sp,-32
    8000100c:	ec06                	sd	ra,24(sp)
    8000100e:	e822                	sd	s0,16(sp)
    80001010:	e426                	sd	s1,8(sp)
    80001012:	e04a                	sd	s2,0(sp)
    80001014:	1000                	addi	s0,sp,32
    80001016:	84aa                	mv	s1,a0
    80001018:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000101a:	4681                	li	a3,0
    8000101c:	4605                	li	a2,1
    8000101e:	040005b7          	lui	a1,0x4000
    80001022:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001024:	05b2                	slli	a1,a1,0xc
    80001026:	fffff097          	auipc	ra,0xfffff
    8000102a:	6e6080e7          	jalr	1766(ra) # 8000070c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    8000102e:	4681                	li	a3,0
    80001030:	4605                	li	a2,1
    80001032:	020005b7          	lui	a1,0x2000
    80001036:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001038:	05b6                	slli	a1,a1,0xd
    8000103a:	8526                	mv	a0,s1
    8000103c:	fffff097          	auipc	ra,0xfffff
    80001040:	6d0080e7          	jalr	1744(ra) # 8000070c <uvmunmap>
  uvmfree(pagetable, sz);
    80001044:	85ca                	mv	a1,s2
    80001046:	8526                	mv	a0,s1
    80001048:	00000097          	auipc	ra,0x0
    8000104c:	98e080e7          	jalr	-1650(ra) # 800009d6 <uvmfree>
}
    80001050:	60e2                	ld	ra,24(sp)
    80001052:	6442                	ld	s0,16(sp)
    80001054:	64a2                	ld	s1,8(sp)
    80001056:	6902                	ld	s2,0(sp)
    80001058:	6105                	addi	sp,sp,32
    8000105a:	8082                	ret

000000008000105c <freeproc>:
{
    8000105c:	1101                	addi	sp,sp,-32
    8000105e:	ec06                	sd	ra,24(sp)
    80001060:	e822                	sd	s0,16(sp)
    80001062:	e426                	sd	s1,8(sp)
    80001064:	1000                	addi	s0,sp,32
    80001066:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001068:	6d28                	ld	a0,88(a0)
    8000106a:	c509                	beqz	a0,80001074 <freeproc+0x18>
    kfree((void*)p->trapframe);
    8000106c:	fffff097          	auipc	ra,0xfffff
    80001070:	fb0080e7          	jalr	-80(ra) # 8000001c <kfree>
  p->trapframe = 0;
    80001074:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001078:	68a8                	ld	a0,80(s1)
    8000107a:	c511                	beqz	a0,80001086 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    8000107c:	64ac                	ld	a1,72(s1)
    8000107e:	00000097          	auipc	ra,0x0
    80001082:	f8c080e7          	jalr	-116(ra) # 8000100a <proc_freepagetable>
  p->pagetable = 0;
    80001086:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    8000108a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    8000108e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001092:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001096:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    8000109a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    8000109e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    800010a2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    800010a6:	0004ac23          	sw	zero,24(s1)
}
    800010aa:	60e2                	ld	ra,24(sp)
    800010ac:	6442                	ld	s0,16(sp)
    800010ae:	64a2                	ld	s1,8(sp)
    800010b0:	6105                	addi	sp,sp,32
    800010b2:	8082                	ret

00000000800010b4 <allocproc>:
{
    800010b4:	1101                	addi	sp,sp,-32
    800010b6:	ec06                	sd	ra,24(sp)
    800010b8:	e822                	sd	s0,16(sp)
    800010ba:	e426                	sd	s1,8(sp)
    800010bc:	e04a                	sd	s2,0(sp)
    800010be:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    800010c0:	00008497          	auipc	s1,0x8
    800010c4:	c7048493          	addi	s1,s1,-912 # 80008d30 <proc>
    800010c8:	0000d917          	auipc	s2,0xd
    800010cc:	66890913          	addi	s2,s2,1640 # 8000e730 <tickslock>
    acquire(&p->lock);
    800010d0:	8526                	mv	a0,s1
    800010d2:	00005097          	auipc	ra,0x5
    800010d6:	142080e7          	jalr	322(ra) # 80006214 <acquire>
    if(p->state == UNUSED) {
    800010da:	4c9c                	lw	a5,24(s1)
    800010dc:	cf81                	beqz	a5,800010f4 <allocproc+0x40>
      release(&p->lock);
    800010de:	8526                	mv	a0,s1
    800010e0:	00005097          	auipc	ra,0x5
    800010e4:	1e8080e7          	jalr	488(ra) # 800062c8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800010e8:	16848493          	addi	s1,s1,360
    800010ec:	ff2492e3          	bne	s1,s2,800010d0 <allocproc+0x1c>
  return 0;
    800010f0:	4481                	li	s1,0
    800010f2:	a889                	j	80001144 <allocproc+0x90>
  p->pid = allocpid();
    800010f4:	00000097          	auipc	ra,0x0
    800010f8:	e34080e7          	jalr	-460(ra) # 80000f28 <allocpid>
    800010fc:	d888                	sw	a0,48(s1)
  p->state = USED;
    800010fe:	4785                	li	a5,1
    80001100:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001102:	fffff097          	auipc	ra,0xfffff
    80001106:	018080e7          	jalr	24(ra) # 8000011a <kalloc>
    8000110a:	892a                	mv	s2,a0
    8000110c:	eca8                	sd	a0,88(s1)
    8000110e:	c131                	beqz	a0,80001152 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001110:	8526                	mv	a0,s1
    80001112:	00000097          	auipc	ra,0x0
    80001116:	e5c080e7          	jalr	-420(ra) # 80000f6e <proc_pagetable>
    8000111a:	892a                	mv	s2,a0
    8000111c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    8000111e:	c531                	beqz	a0,8000116a <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001120:	07000613          	li	a2,112
    80001124:	4581                	li	a1,0
    80001126:	06048513          	addi	a0,s1,96
    8000112a:	fffff097          	auipc	ra,0xfffff
    8000112e:	050080e7          	jalr	80(ra) # 8000017a <memset>
  p->context.ra = (uint64)forkret;
    80001132:	00000797          	auipc	a5,0x0
    80001136:	db078793          	addi	a5,a5,-592 # 80000ee2 <forkret>
    8000113a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000113c:	60bc                	ld	a5,64(s1)
    8000113e:	6705                	lui	a4,0x1
    80001140:	97ba                	add	a5,a5,a4
    80001142:	f4bc                	sd	a5,104(s1)
}
    80001144:	8526                	mv	a0,s1
    80001146:	60e2                	ld	ra,24(sp)
    80001148:	6442                	ld	s0,16(sp)
    8000114a:	64a2                	ld	s1,8(sp)
    8000114c:	6902                	ld	s2,0(sp)
    8000114e:	6105                	addi	sp,sp,32
    80001150:	8082                	ret
    freeproc(p);
    80001152:	8526                	mv	a0,s1
    80001154:	00000097          	auipc	ra,0x0
    80001158:	f08080e7          	jalr	-248(ra) # 8000105c <freeproc>
    release(&p->lock);
    8000115c:	8526                	mv	a0,s1
    8000115e:	00005097          	auipc	ra,0x5
    80001162:	16a080e7          	jalr	362(ra) # 800062c8 <release>
    return 0;
    80001166:	84ca                	mv	s1,s2
    80001168:	bff1                	j	80001144 <allocproc+0x90>
    freeproc(p);
    8000116a:	8526                	mv	a0,s1
    8000116c:	00000097          	auipc	ra,0x0
    80001170:	ef0080e7          	jalr	-272(ra) # 8000105c <freeproc>
    release(&p->lock);
    80001174:	8526                	mv	a0,s1
    80001176:	00005097          	auipc	ra,0x5
    8000117a:	152080e7          	jalr	338(ra) # 800062c8 <release>
    return 0;
    8000117e:	84ca                	mv	s1,s2
    80001180:	b7d1                	j	80001144 <allocproc+0x90>

0000000080001182 <userinit>:
{
    80001182:	1101                	addi	sp,sp,-32
    80001184:	ec06                	sd	ra,24(sp)
    80001186:	e822                	sd	s0,16(sp)
    80001188:	e426                	sd	s1,8(sp)
    8000118a:	1000                	addi	s0,sp,32
  p = allocproc();
    8000118c:	00000097          	auipc	ra,0x0
    80001190:	f28080e7          	jalr	-216(ra) # 800010b4 <allocproc>
    80001194:	84aa                	mv	s1,a0
  initproc = p;
    80001196:	00007797          	auipc	a5,0x7
    8000119a:	72a7b523          	sd	a0,1834(a5) # 800088c0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    8000119e:	03400613          	li	a2,52
    800011a2:	00007597          	auipc	a1,0x7
    800011a6:	6ae58593          	addi	a1,a1,1710 # 80008850 <initcode>
    800011aa:	6928                	ld	a0,80(a0)
    800011ac:	fffff097          	auipc	ra,0xfffff
    800011b0:	652080e7          	jalr	1618(ra) # 800007fe <uvmfirst>
  p->sz = PGSIZE;
    800011b4:	6785                	lui	a5,0x1
    800011b6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    800011b8:	6cb8                	ld	a4,88(s1)
    800011ba:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    800011be:	6cb8                	ld	a4,88(s1)
    800011c0:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    800011c2:	4641                	li	a2,16
    800011c4:	00007597          	auipc	a1,0x7
    800011c8:	fbc58593          	addi	a1,a1,-68 # 80008180 <etext+0x180>
    800011cc:	15848513          	addi	a0,s1,344
    800011d0:	fffff097          	auipc	ra,0xfffff
    800011d4:	0f4080e7          	jalr	244(ra) # 800002c4 <safestrcpy>
  p->cwd = namei("/");
    800011d8:	00007517          	auipc	a0,0x7
    800011dc:	fb850513          	addi	a0,a0,-72 # 80008190 <etext+0x190>
    800011e0:	00002097          	auipc	ra,0x2
    800011e4:	1f2080e7          	jalr	498(ra) # 800033d2 <namei>
    800011e8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800011ec:	478d                	li	a5,3
    800011ee:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011f0:	8526                	mv	a0,s1
    800011f2:	00005097          	auipc	ra,0x5
    800011f6:	0d6080e7          	jalr	214(ra) # 800062c8 <release>
}
    800011fa:	60e2                	ld	ra,24(sp)
    800011fc:	6442                	ld	s0,16(sp)
    800011fe:	64a2                	ld	s1,8(sp)
    80001200:	6105                	addi	sp,sp,32
    80001202:	8082                	ret

0000000080001204 <growproc>:
{
    80001204:	1101                	addi	sp,sp,-32
    80001206:	ec06                	sd	ra,24(sp)
    80001208:	e822                	sd	s0,16(sp)
    8000120a:	e426                	sd	s1,8(sp)
    8000120c:	e04a                	sd	s2,0(sp)
    8000120e:	1000                	addi	s0,sp,32
    80001210:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001212:	00000097          	auipc	ra,0x0
    80001216:	c98080e7          	jalr	-872(ra) # 80000eaa <myproc>
    8000121a:	84aa                	mv	s1,a0
  sz = p->sz;
    8000121c:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000121e:	01204c63          	bgtz	s2,80001236 <growproc+0x32>
  } else if(n < 0){
    80001222:	02094663          	bltz	s2,8000124e <growproc+0x4a>
  p->sz = sz;
    80001226:	e4ac                	sd	a1,72(s1)
  return 0;
    80001228:	4501                	li	a0,0
}
    8000122a:	60e2                	ld	ra,24(sp)
    8000122c:	6442                	ld	s0,16(sp)
    8000122e:	64a2                	ld	s1,8(sp)
    80001230:	6902                	ld	s2,0(sp)
    80001232:	6105                	addi	sp,sp,32
    80001234:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001236:	4691                	li	a3,4
    80001238:	00b90633          	add	a2,s2,a1
    8000123c:	6928                	ld	a0,80(a0)
    8000123e:	fffff097          	auipc	ra,0xfffff
    80001242:	67a080e7          	jalr	1658(ra) # 800008b8 <uvmalloc>
    80001246:	85aa                	mv	a1,a0
    80001248:	fd79                	bnez	a0,80001226 <growproc+0x22>
      return -1;
    8000124a:	557d                	li	a0,-1
    8000124c:	bff9                	j	8000122a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000124e:	00b90633          	add	a2,s2,a1
    80001252:	6928                	ld	a0,80(a0)
    80001254:	fffff097          	auipc	ra,0xfffff
    80001258:	61c080e7          	jalr	1564(ra) # 80000870 <uvmdealloc>
    8000125c:	85aa                	mv	a1,a0
    8000125e:	b7e1                	j	80001226 <growproc+0x22>

0000000080001260 <fork>:
{
    80001260:	7139                	addi	sp,sp,-64
    80001262:	fc06                	sd	ra,56(sp)
    80001264:	f822                	sd	s0,48(sp)
    80001266:	f426                	sd	s1,40(sp)
    80001268:	f04a                	sd	s2,32(sp)
    8000126a:	ec4e                	sd	s3,24(sp)
    8000126c:	e852                	sd	s4,16(sp)
    8000126e:	e456                	sd	s5,8(sp)
    80001270:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001272:	00000097          	auipc	ra,0x0
    80001276:	c38080e7          	jalr	-968(ra) # 80000eaa <myproc>
    8000127a:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000127c:	00000097          	auipc	ra,0x0
    80001280:	e38080e7          	jalr	-456(ra) # 800010b4 <allocproc>
    80001284:	10050c63          	beqz	a0,8000139c <fork+0x13c>
    80001288:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000128a:	048ab603          	ld	a2,72(s5)
    8000128e:	692c                	ld	a1,80(a0)
    80001290:	050ab503          	ld	a0,80(s5)
    80001294:	fffff097          	auipc	ra,0xfffff
    80001298:	77c080e7          	jalr	1916(ra) # 80000a10 <uvmcopy>
    8000129c:	04054863          	bltz	a0,800012ec <fork+0x8c>
  np->sz = p->sz;
    800012a0:	048ab783          	ld	a5,72(s5)
    800012a4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800012a8:	058ab683          	ld	a3,88(s5)
    800012ac:	87b6                	mv	a5,a3
    800012ae:	058a3703          	ld	a4,88(s4)
    800012b2:	12068693          	addi	a3,a3,288
    800012b6:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    800012ba:	6788                	ld	a0,8(a5)
    800012bc:	6b8c                	ld	a1,16(a5)
    800012be:	6f90                	ld	a2,24(a5)
    800012c0:	01073023          	sd	a6,0(a4)
    800012c4:	e708                	sd	a0,8(a4)
    800012c6:	eb0c                	sd	a1,16(a4)
    800012c8:	ef10                	sd	a2,24(a4)
    800012ca:	02078793          	addi	a5,a5,32
    800012ce:	02070713          	addi	a4,a4,32
    800012d2:	fed792e3          	bne	a5,a3,800012b6 <fork+0x56>
  np->trapframe->a0 = 0;
    800012d6:	058a3783          	ld	a5,88(s4)
    800012da:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    800012de:	0d0a8493          	addi	s1,s5,208
    800012e2:	0d0a0913          	addi	s2,s4,208
    800012e6:	150a8993          	addi	s3,s5,336
    800012ea:	a00d                	j	8000130c <fork+0xac>
    freeproc(np);
    800012ec:	8552                	mv	a0,s4
    800012ee:	00000097          	auipc	ra,0x0
    800012f2:	d6e080e7          	jalr	-658(ra) # 8000105c <freeproc>
    release(&np->lock);
    800012f6:	8552                	mv	a0,s4
    800012f8:	00005097          	auipc	ra,0x5
    800012fc:	fd0080e7          	jalr	-48(ra) # 800062c8 <release>
    return -1;
    80001300:	597d                	li	s2,-1
    80001302:	a059                	j	80001388 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001304:	04a1                	addi	s1,s1,8
    80001306:	0921                	addi	s2,s2,8
    80001308:	01348b63          	beq	s1,s3,8000131e <fork+0xbe>
    if(p->ofile[i])
    8000130c:	6088                	ld	a0,0(s1)
    8000130e:	d97d                	beqz	a0,80001304 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001310:	00002097          	auipc	ra,0x2
    80001314:	758080e7          	jalr	1880(ra) # 80003a68 <filedup>
    80001318:	00a93023          	sd	a0,0(s2)
    8000131c:	b7e5                	j	80001304 <fork+0xa4>
  np->cwd = idup(p->cwd);
    8000131e:	150ab503          	ld	a0,336(s5)
    80001322:	00002097          	auipc	ra,0x2
    80001326:	8c6080e7          	jalr	-1850(ra) # 80002be8 <idup>
    8000132a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000132e:	4641                	li	a2,16
    80001330:	158a8593          	addi	a1,s5,344
    80001334:	158a0513          	addi	a0,s4,344
    80001338:	fffff097          	auipc	ra,0xfffff
    8000133c:	f8c080e7          	jalr	-116(ra) # 800002c4 <safestrcpy>
  pid = np->pid;
    80001340:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001344:	8552                	mv	a0,s4
    80001346:	00005097          	auipc	ra,0x5
    8000134a:	f82080e7          	jalr	-126(ra) # 800062c8 <release>
  acquire(&wait_lock);
    8000134e:	00007497          	auipc	s1,0x7
    80001352:	5ca48493          	addi	s1,s1,1482 # 80008918 <wait_lock>
    80001356:	8526                	mv	a0,s1
    80001358:	00005097          	auipc	ra,0x5
    8000135c:	ebc080e7          	jalr	-324(ra) # 80006214 <acquire>
  np->parent = p;
    80001360:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001364:	8526                	mv	a0,s1
    80001366:	00005097          	auipc	ra,0x5
    8000136a:	f62080e7          	jalr	-158(ra) # 800062c8 <release>
  acquire(&np->lock);
    8000136e:	8552                	mv	a0,s4
    80001370:	00005097          	auipc	ra,0x5
    80001374:	ea4080e7          	jalr	-348(ra) # 80006214 <acquire>
  np->state = RUNNABLE;
    80001378:	478d                	li	a5,3
    8000137a:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000137e:	8552                	mv	a0,s4
    80001380:	00005097          	auipc	ra,0x5
    80001384:	f48080e7          	jalr	-184(ra) # 800062c8 <release>
}
    80001388:	854a                	mv	a0,s2
    8000138a:	70e2                	ld	ra,56(sp)
    8000138c:	7442                	ld	s0,48(sp)
    8000138e:	74a2                	ld	s1,40(sp)
    80001390:	7902                	ld	s2,32(sp)
    80001392:	69e2                	ld	s3,24(sp)
    80001394:	6a42                	ld	s4,16(sp)
    80001396:	6aa2                	ld	s5,8(sp)
    80001398:	6121                	addi	sp,sp,64
    8000139a:	8082                	ret
    return -1;
    8000139c:	597d                	li	s2,-1
    8000139e:	b7ed                	j	80001388 <fork+0x128>

00000000800013a0 <scheduler>:
{
    800013a0:	7139                	addi	sp,sp,-64
    800013a2:	fc06                	sd	ra,56(sp)
    800013a4:	f822                	sd	s0,48(sp)
    800013a6:	f426                	sd	s1,40(sp)
    800013a8:	f04a                	sd	s2,32(sp)
    800013aa:	ec4e                	sd	s3,24(sp)
    800013ac:	e852                	sd	s4,16(sp)
    800013ae:	e456                	sd	s5,8(sp)
    800013b0:	e05a                	sd	s6,0(sp)
    800013b2:	0080                	addi	s0,sp,64
    800013b4:	8792                	mv	a5,tp
  int id = r_tp();
    800013b6:	2781                	sext.w	a5,a5
  c->proc = 0;
    800013b8:	00779a93          	slli	s5,a5,0x7
    800013bc:	00007717          	auipc	a4,0x7
    800013c0:	54470713          	addi	a4,a4,1348 # 80008900 <pid_lock>
    800013c4:	9756                	add	a4,a4,s5
    800013c6:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    800013ca:	00007717          	auipc	a4,0x7
    800013ce:	56e70713          	addi	a4,a4,1390 # 80008938 <cpus+0x8>
    800013d2:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    800013d4:	498d                	li	s3,3
        p->state = RUNNING;
    800013d6:	4b11                	li	s6,4
        c->proc = p;
    800013d8:	079e                	slli	a5,a5,0x7
    800013da:	00007a17          	auipc	s4,0x7
    800013de:	526a0a13          	addi	s4,s4,1318 # 80008900 <pid_lock>
    800013e2:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    800013e4:	0000d917          	auipc	s2,0xd
    800013e8:	34c90913          	addi	s2,s2,844 # 8000e730 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013ec:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013f0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013f4:	10079073          	csrw	sstatus,a5
    800013f8:	00008497          	auipc	s1,0x8
    800013fc:	93848493          	addi	s1,s1,-1736 # 80008d30 <proc>
    80001400:	a811                	j	80001414 <scheduler+0x74>
      release(&p->lock);
    80001402:	8526                	mv	a0,s1
    80001404:	00005097          	auipc	ra,0x5
    80001408:	ec4080e7          	jalr	-316(ra) # 800062c8 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000140c:	16848493          	addi	s1,s1,360
    80001410:	fd248ee3          	beq	s1,s2,800013ec <scheduler+0x4c>
      acquire(&p->lock);
    80001414:	8526                	mv	a0,s1
    80001416:	00005097          	auipc	ra,0x5
    8000141a:	dfe080e7          	jalr	-514(ra) # 80006214 <acquire>
      if(p->state == RUNNABLE) {
    8000141e:	4c9c                	lw	a5,24(s1)
    80001420:	ff3791e3          	bne	a5,s3,80001402 <scheduler+0x62>
        p->state = RUNNING;
    80001424:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001428:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000142c:	06048593          	addi	a1,s1,96
    80001430:	8556                	mv	a0,s5
    80001432:	00000097          	auipc	ra,0x0
    80001436:	684080e7          	jalr	1668(ra) # 80001ab6 <swtch>
        c->proc = 0;
    8000143a:	020a3823          	sd	zero,48(s4)
    8000143e:	b7d1                	j	80001402 <scheduler+0x62>

0000000080001440 <sched>:
{
    80001440:	7179                	addi	sp,sp,-48
    80001442:	f406                	sd	ra,40(sp)
    80001444:	f022                	sd	s0,32(sp)
    80001446:	ec26                	sd	s1,24(sp)
    80001448:	e84a                	sd	s2,16(sp)
    8000144a:	e44e                	sd	s3,8(sp)
    8000144c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000144e:	00000097          	auipc	ra,0x0
    80001452:	a5c080e7          	jalr	-1444(ra) # 80000eaa <myproc>
    80001456:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001458:	00005097          	auipc	ra,0x5
    8000145c:	d42080e7          	jalr	-702(ra) # 8000619a <holding>
    80001460:	c93d                	beqz	a0,800014d6 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001462:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001464:	2781                	sext.w	a5,a5
    80001466:	079e                	slli	a5,a5,0x7
    80001468:	00007717          	auipc	a4,0x7
    8000146c:	49870713          	addi	a4,a4,1176 # 80008900 <pid_lock>
    80001470:	97ba                	add	a5,a5,a4
    80001472:	0a87a703          	lw	a4,168(a5)
    80001476:	4785                	li	a5,1
    80001478:	06f71763          	bne	a4,a5,800014e6 <sched+0xa6>
  if(p->state == RUNNING)
    8000147c:	4c98                	lw	a4,24(s1)
    8000147e:	4791                	li	a5,4
    80001480:	06f70b63          	beq	a4,a5,800014f6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001484:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001488:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000148a:	efb5                	bnez	a5,80001506 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000148c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000148e:	00007917          	auipc	s2,0x7
    80001492:	47290913          	addi	s2,s2,1138 # 80008900 <pid_lock>
    80001496:	2781                	sext.w	a5,a5
    80001498:	079e                	slli	a5,a5,0x7
    8000149a:	97ca                	add	a5,a5,s2
    8000149c:	0ac7a983          	lw	s3,172(a5)
    800014a0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800014a2:	2781                	sext.w	a5,a5
    800014a4:	079e                	slli	a5,a5,0x7
    800014a6:	00007597          	auipc	a1,0x7
    800014aa:	49258593          	addi	a1,a1,1170 # 80008938 <cpus+0x8>
    800014ae:	95be                	add	a1,a1,a5
    800014b0:	06048513          	addi	a0,s1,96
    800014b4:	00000097          	auipc	ra,0x0
    800014b8:	602080e7          	jalr	1538(ra) # 80001ab6 <swtch>
    800014bc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800014be:	2781                	sext.w	a5,a5
    800014c0:	079e                	slli	a5,a5,0x7
    800014c2:	993e                	add	s2,s2,a5
    800014c4:	0b392623          	sw	s3,172(s2)
}
    800014c8:	70a2                	ld	ra,40(sp)
    800014ca:	7402                	ld	s0,32(sp)
    800014cc:	64e2                	ld	s1,24(sp)
    800014ce:	6942                	ld	s2,16(sp)
    800014d0:	69a2                	ld	s3,8(sp)
    800014d2:	6145                	addi	sp,sp,48
    800014d4:	8082                	ret
    panic("sched p->lock");
    800014d6:	00007517          	auipc	a0,0x7
    800014da:	cc250513          	addi	a0,a0,-830 # 80008198 <etext+0x198>
    800014de:	00004097          	auipc	ra,0x4
    800014e2:	7fe080e7          	jalr	2046(ra) # 80005cdc <panic>
    panic("sched locks");
    800014e6:	00007517          	auipc	a0,0x7
    800014ea:	cc250513          	addi	a0,a0,-830 # 800081a8 <etext+0x1a8>
    800014ee:	00004097          	auipc	ra,0x4
    800014f2:	7ee080e7          	jalr	2030(ra) # 80005cdc <panic>
    panic("sched running");
    800014f6:	00007517          	auipc	a0,0x7
    800014fa:	cc250513          	addi	a0,a0,-830 # 800081b8 <etext+0x1b8>
    800014fe:	00004097          	auipc	ra,0x4
    80001502:	7de080e7          	jalr	2014(ra) # 80005cdc <panic>
    panic("sched interruptible");
    80001506:	00007517          	auipc	a0,0x7
    8000150a:	cc250513          	addi	a0,a0,-830 # 800081c8 <etext+0x1c8>
    8000150e:	00004097          	auipc	ra,0x4
    80001512:	7ce080e7          	jalr	1998(ra) # 80005cdc <panic>

0000000080001516 <yield>:
{
    80001516:	1101                	addi	sp,sp,-32
    80001518:	ec06                	sd	ra,24(sp)
    8000151a:	e822                	sd	s0,16(sp)
    8000151c:	e426                	sd	s1,8(sp)
    8000151e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001520:	00000097          	auipc	ra,0x0
    80001524:	98a080e7          	jalr	-1654(ra) # 80000eaa <myproc>
    80001528:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000152a:	00005097          	auipc	ra,0x5
    8000152e:	cea080e7          	jalr	-790(ra) # 80006214 <acquire>
  p->state = RUNNABLE;
    80001532:	478d                	li	a5,3
    80001534:	cc9c                	sw	a5,24(s1)
  sched();
    80001536:	00000097          	auipc	ra,0x0
    8000153a:	f0a080e7          	jalr	-246(ra) # 80001440 <sched>
  release(&p->lock);
    8000153e:	8526                	mv	a0,s1
    80001540:	00005097          	auipc	ra,0x5
    80001544:	d88080e7          	jalr	-632(ra) # 800062c8 <release>
}
    80001548:	60e2                	ld	ra,24(sp)
    8000154a:	6442                	ld	s0,16(sp)
    8000154c:	64a2                	ld	s1,8(sp)
    8000154e:	6105                	addi	sp,sp,32
    80001550:	8082                	ret

0000000080001552 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001552:	7179                	addi	sp,sp,-48
    80001554:	f406                	sd	ra,40(sp)
    80001556:	f022                	sd	s0,32(sp)
    80001558:	ec26                	sd	s1,24(sp)
    8000155a:	e84a                	sd	s2,16(sp)
    8000155c:	e44e                	sd	s3,8(sp)
    8000155e:	1800                	addi	s0,sp,48
    80001560:	89aa                	mv	s3,a0
    80001562:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001564:	00000097          	auipc	ra,0x0
    80001568:	946080e7          	jalr	-1722(ra) # 80000eaa <myproc>
    8000156c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000156e:	00005097          	auipc	ra,0x5
    80001572:	ca6080e7          	jalr	-858(ra) # 80006214 <acquire>
  release(lk);
    80001576:	854a                	mv	a0,s2
    80001578:	00005097          	auipc	ra,0x5
    8000157c:	d50080e7          	jalr	-688(ra) # 800062c8 <release>

  // Go to sleep.
  p->chan = chan;
    80001580:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001584:	4789                	li	a5,2
    80001586:	cc9c                	sw	a5,24(s1)

  sched();
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	eb8080e7          	jalr	-328(ra) # 80001440 <sched>

  // Tidy up.
  p->chan = 0;
    80001590:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001594:	8526                	mv	a0,s1
    80001596:	00005097          	auipc	ra,0x5
    8000159a:	d32080e7          	jalr	-718(ra) # 800062c8 <release>
  acquire(lk);
    8000159e:	854a                	mv	a0,s2
    800015a0:	00005097          	auipc	ra,0x5
    800015a4:	c74080e7          	jalr	-908(ra) # 80006214 <acquire>
}
    800015a8:	70a2                	ld	ra,40(sp)
    800015aa:	7402                	ld	s0,32(sp)
    800015ac:	64e2                	ld	s1,24(sp)
    800015ae:	6942                	ld	s2,16(sp)
    800015b0:	69a2                	ld	s3,8(sp)
    800015b2:	6145                	addi	sp,sp,48
    800015b4:	8082                	ret

00000000800015b6 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
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
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800015ca:	00007497          	auipc	s1,0x7
    800015ce:	76648493          	addi	s1,s1,1894 # 80008d30 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800015d2:	4989                	li	s3,2
        p->state = RUNNABLE;
    800015d4:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800015d6:	0000d917          	auipc	s2,0xd
    800015da:	15a90913          	addi	s2,s2,346 # 8000e730 <tickslock>
    800015de:	a811                	j	800015f2 <wakeup+0x3c>
      }
      release(&p->lock);
    800015e0:	8526                	mv	a0,s1
    800015e2:	00005097          	auipc	ra,0x5
    800015e6:	ce6080e7          	jalr	-794(ra) # 800062c8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800015ea:	16848493          	addi	s1,s1,360
    800015ee:	03248663          	beq	s1,s2,8000161a <wakeup+0x64>
    if(p != myproc()){
    800015f2:	00000097          	auipc	ra,0x0
    800015f6:	8b8080e7          	jalr	-1864(ra) # 80000eaa <myproc>
    800015fa:	fea488e3          	beq	s1,a0,800015ea <wakeup+0x34>
      acquire(&p->lock);
    800015fe:	8526                	mv	a0,s1
    80001600:	00005097          	auipc	ra,0x5
    80001604:	c14080e7          	jalr	-1004(ra) # 80006214 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001608:	4c9c                	lw	a5,24(s1)
    8000160a:	fd379be3          	bne	a5,s3,800015e0 <wakeup+0x2a>
    8000160e:	709c                	ld	a5,32(s1)
    80001610:	fd4798e3          	bne	a5,s4,800015e0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001614:	0154ac23          	sw	s5,24(s1)
    80001618:	b7e1                	j	800015e0 <wakeup+0x2a>
    }
  }
}
    8000161a:	70e2                	ld	ra,56(sp)
    8000161c:	7442                	ld	s0,48(sp)
    8000161e:	74a2                	ld	s1,40(sp)
    80001620:	7902                	ld	s2,32(sp)
    80001622:	69e2                	ld	s3,24(sp)
    80001624:	6a42                	ld	s4,16(sp)
    80001626:	6aa2                	ld	s5,8(sp)
    80001628:	6121                	addi	sp,sp,64
    8000162a:	8082                	ret

000000008000162c <reparent>:
{
    8000162c:	7179                	addi	sp,sp,-48
    8000162e:	f406                	sd	ra,40(sp)
    80001630:	f022                	sd	s0,32(sp)
    80001632:	ec26                	sd	s1,24(sp)
    80001634:	e84a                	sd	s2,16(sp)
    80001636:	e44e                	sd	s3,8(sp)
    80001638:	e052                	sd	s4,0(sp)
    8000163a:	1800                	addi	s0,sp,48
    8000163c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000163e:	00007497          	auipc	s1,0x7
    80001642:	6f248493          	addi	s1,s1,1778 # 80008d30 <proc>
      pp->parent = initproc;
    80001646:	00007a17          	auipc	s4,0x7
    8000164a:	27aa0a13          	addi	s4,s4,634 # 800088c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000164e:	0000d997          	auipc	s3,0xd
    80001652:	0e298993          	addi	s3,s3,226 # 8000e730 <tickslock>
    80001656:	a029                	j	80001660 <reparent+0x34>
    80001658:	16848493          	addi	s1,s1,360
    8000165c:	01348d63          	beq	s1,s3,80001676 <reparent+0x4a>
    if(pp->parent == p){
    80001660:	7c9c                	ld	a5,56(s1)
    80001662:	ff279be3          	bne	a5,s2,80001658 <reparent+0x2c>
      pp->parent = initproc;
    80001666:	000a3503          	ld	a0,0(s4)
    8000166a:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000166c:	00000097          	auipc	ra,0x0
    80001670:	f4a080e7          	jalr	-182(ra) # 800015b6 <wakeup>
    80001674:	b7d5                	j	80001658 <reparent+0x2c>
}
    80001676:	70a2                	ld	ra,40(sp)
    80001678:	7402                	ld	s0,32(sp)
    8000167a:	64e2                	ld	s1,24(sp)
    8000167c:	6942                	ld	s2,16(sp)
    8000167e:	69a2                	ld	s3,8(sp)
    80001680:	6a02                	ld	s4,0(sp)
    80001682:	6145                	addi	sp,sp,48
    80001684:	8082                	ret

0000000080001686 <exit>:
{
    80001686:	7179                	addi	sp,sp,-48
    80001688:	f406                	sd	ra,40(sp)
    8000168a:	f022                	sd	s0,32(sp)
    8000168c:	ec26                	sd	s1,24(sp)
    8000168e:	e84a                	sd	s2,16(sp)
    80001690:	e44e                	sd	s3,8(sp)
    80001692:	e052                	sd	s4,0(sp)
    80001694:	1800                	addi	s0,sp,48
    80001696:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80001698:	00000097          	auipc	ra,0x0
    8000169c:	812080e7          	jalr	-2030(ra) # 80000eaa <myproc>
    800016a0:	89aa                	mv	s3,a0
  if(p == initproc)
    800016a2:	00007797          	auipc	a5,0x7
    800016a6:	21e7b783          	ld	a5,542(a5) # 800088c0 <initproc>
    800016aa:	0d050493          	addi	s1,a0,208
    800016ae:	15050913          	addi	s2,a0,336
    800016b2:	02a79363          	bne	a5,a0,800016d8 <exit+0x52>
    panic("init exiting");
    800016b6:	00007517          	auipc	a0,0x7
    800016ba:	b2a50513          	addi	a0,a0,-1238 # 800081e0 <etext+0x1e0>
    800016be:	00004097          	auipc	ra,0x4
    800016c2:	61e080e7          	jalr	1566(ra) # 80005cdc <panic>
      fileclose(f);
    800016c6:	00002097          	auipc	ra,0x2
    800016ca:	3f4080e7          	jalr	1012(ra) # 80003aba <fileclose>
      p->ofile[fd] = 0;
    800016ce:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800016d2:	04a1                	addi	s1,s1,8
    800016d4:	01248563          	beq	s1,s2,800016de <exit+0x58>
    if(p->ofile[fd]){
    800016d8:	6088                	ld	a0,0(s1)
    800016da:	f575                	bnez	a0,800016c6 <exit+0x40>
    800016dc:	bfdd                	j	800016d2 <exit+0x4c>
  begin_op();
    800016de:	00002097          	auipc	ra,0x2
    800016e2:	f14080e7          	jalr	-236(ra) # 800035f2 <begin_op>
  iput(p->cwd);
    800016e6:	1509b503          	ld	a0,336(s3)
    800016ea:	00001097          	auipc	ra,0x1
    800016ee:	6f6080e7          	jalr	1782(ra) # 80002de0 <iput>
  end_op();
    800016f2:	00002097          	auipc	ra,0x2
    800016f6:	f7e080e7          	jalr	-130(ra) # 80003670 <end_op>
  p->cwd = 0;
    800016fa:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800016fe:	00007497          	auipc	s1,0x7
    80001702:	21a48493          	addi	s1,s1,538 # 80008918 <wait_lock>
    80001706:	8526                	mv	a0,s1
    80001708:	00005097          	auipc	ra,0x5
    8000170c:	b0c080e7          	jalr	-1268(ra) # 80006214 <acquire>
  reparent(p);
    80001710:	854e                	mv	a0,s3
    80001712:	00000097          	auipc	ra,0x0
    80001716:	f1a080e7          	jalr	-230(ra) # 8000162c <reparent>
  wakeup(p->parent);
    8000171a:	0389b503          	ld	a0,56(s3)
    8000171e:	00000097          	auipc	ra,0x0
    80001722:	e98080e7          	jalr	-360(ra) # 800015b6 <wakeup>
  acquire(&p->lock);
    80001726:	854e                	mv	a0,s3
    80001728:	00005097          	auipc	ra,0x5
    8000172c:	aec080e7          	jalr	-1300(ra) # 80006214 <acquire>
  p->xstate = status;
    80001730:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001734:	4795                	li	a5,5
    80001736:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000173a:	8526                	mv	a0,s1
    8000173c:	00005097          	auipc	ra,0x5
    80001740:	b8c080e7          	jalr	-1140(ra) # 800062c8 <release>
  sched();
    80001744:	00000097          	auipc	ra,0x0
    80001748:	cfc080e7          	jalr	-772(ra) # 80001440 <sched>
  panic("zombie exit");
    8000174c:	00007517          	auipc	a0,0x7
    80001750:	aa450513          	addi	a0,a0,-1372 # 800081f0 <etext+0x1f0>
    80001754:	00004097          	auipc	ra,0x4
    80001758:	588080e7          	jalr	1416(ra) # 80005cdc <panic>

000000008000175c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000175c:	7179                	addi	sp,sp,-48
    8000175e:	f406                	sd	ra,40(sp)
    80001760:	f022                	sd	s0,32(sp)
    80001762:	ec26                	sd	s1,24(sp)
    80001764:	e84a                	sd	s2,16(sp)
    80001766:	e44e                	sd	s3,8(sp)
    80001768:	1800                	addi	s0,sp,48
    8000176a:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000176c:	00007497          	auipc	s1,0x7
    80001770:	5c448493          	addi	s1,s1,1476 # 80008d30 <proc>
    80001774:	0000d997          	auipc	s3,0xd
    80001778:	fbc98993          	addi	s3,s3,-68 # 8000e730 <tickslock>
    acquire(&p->lock);
    8000177c:	8526                	mv	a0,s1
    8000177e:	00005097          	auipc	ra,0x5
    80001782:	a96080e7          	jalr	-1386(ra) # 80006214 <acquire>
    if(p->pid == pid){
    80001786:	589c                	lw	a5,48(s1)
    80001788:	01278d63          	beq	a5,s2,800017a2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000178c:	8526                	mv	a0,s1
    8000178e:	00005097          	auipc	ra,0x5
    80001792:	b3a080e7          	jalr	-1222(ra) # 800062c8 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001796:	16848493          	addi	s1,s1,360
    8000179a:	ff3491e3          	bne	s1,s3,8000177c <kill+0x20>
  }
  return -1;
    8000179e:	557d                	li	a0,-1
    800017a0:	a829                	j	800017ba <kill+0x5e>
      p->killed = 1;
    800017a2:	4785                	li	a5,1
    800017a4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800017a6:	4c98                	lw	a4,24(s1)
    800017a8:	4789                	li	a5,2
    800017aa:	00f70f63          	beq	a4,a5,800017c8 <kill+0x6c>
      release(&p->lock);
    800017ae:	8526                	mv	a0,s1
    800017b0:	00005097          	auipc	ra,0x5
    800017b4:	b18080e7          	jalr	-1256(ra) # 800062c8 <release>
      return 0;
    800017b8:	4501                	li	a0,0
}
    800017ba:	70a2                	ld	ra,40(sp)
    800017bc:	7402                	ld	s0,32(sp)
    800017be:	64e2                	ld	s1,24(sp)
    800017c0:	6942                	ld	s2,16(sp)
    800017c2:	69a2                	ld	s3,8(sp)
    800017c4:	6145                	addi	sp,sp,48
    800017c6:	8082                	ret
        p->state = RUNNABLE;
    800017c8:	478d                	li	a5,3
    800017ca:	cc9c                	sw	a5,24(s1)
    800017cc:	b7cd                	j	800017ae <kill+0x52>

00000000800017ce <setkilled>:

void
setkilled(struct proc *p)
{
    800017ce:	1101                	addi	sp,sp,-32
    800017d0:	ec06                	sd	ra,24(sp)
    800017d2:	e822                	sd	s0,16(sp)
    800017d4:	e426                	sd	s1,8(sp)
    800017d6:	1000                	addi	s0,sp,32
    800017d8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800017da:	00005097          	auipc	ra,0x5
    800017de:	a3a080e7          	jalr	-1478(ra) # 80006214 <acquire>
  p->killed = 1;
    800017e2:	4785                	li	a5,1
    800017e4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800017e6:	8526                	mv	a0,s1
    800017e8:	00005097          	auipc	ra,0x5
    800017ec:	ae0080e7          	jalr	-1312(ra) # 800062c8 <release>
}
    800017f0:	60e2                	ld	ra,24(sp)
    800017f2:	6442                	ld	s0,16(sp)
    800017f4:	64a2                	ld	s1,8(sp)
    800017f6:	6105                	addi	sp,sp,32
    800017f8:	8082                	ret

00000000800017fa <killed>:

int
killed(struct proc *p)
{
    800017fa:	1101                	addi	sp,sp,-32
    800017fc:	ec06                	sd	ra,24(sp)
    800017fe:	e822                	sd	s0,16(sp)
    80001800:	e426                	sd	s1,8(sp)
    80001802:	e04a                	sd	s2,0(sp)
    80001804:	1000                	addi	s0,sp,32
    80001806:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001808:	00005097          	auipc	ra,0x5
    8000180c:	a0c080e7          	jalr	-1524(ra) # 80006214 <acquire>
  k = p->killed;
    80001810:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001814:	8526                	mv	a0,s1
    80001816:	00005097          	auipc	ra,0x5
    8000181a:	ab2080e7          	jalr	-1358(ra) # 800062c8 <release>
  return k;
}
    8000181e:	854a                	mv	a0,s2
    80001820:	60e2                	ld	ra,24(sp)
    80001822:	6442                	ld	s0,16(sp)
    80001824:	64a2                	ld	s1,8(sp)
    80001826:	6902                	ld	s2,0(sp)
    80001828:	6105                	addi	sp,sp,32
    8000182a:	8082                	ret

000000008000182c <wait>:
{
    8000182c:	715d                	addi	sp,sp,-80
    8000182e:	e486                	sd	ra,72(sp)
    80001830:	e0a2                	sd	s0,64(sp)
    80001832:	fc26                	sd	s1,56(sp)
    80001834:	f84a                	sd	s2,48(sp)
    80001836:	f44e                	sd	s3,40(sp)
    80001838:	f052                	sd	s4,32(sp)
    8000183a:	ec56                	sd	s5,24(sp)
    8000183c:	e85a                	sd	s6,16(sp)
    8000183e:	e45e                	sd	s7,8(sp)
    80001840:	e062                	sd	s8,0(sp)
    80001842:	0880                	addi	s0,sp,80
    80001844:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001846:	fffff097          	auipc	ra,0xfffff
    8000184a:	664080e7          	jalr	1636(ra) # 80000eaa <myproc>
    8000184e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001850:	00007517          	auipc	a0,0x7
    80001854:	0c850513          	addi	a0,a0,200 # 80008918 <wait_lock>
    80001858:	00005097          	auipc	ra,0x5
    8000185c:	9bc080e7          	jalr	-1604(ra) # 80006214 <acquire>
    havekids = 0;
    80001860:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001862:	4a15                	li	s4,5
        havekids = 1;
    80001864:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001866:	0000d997          	auipc	s3,0xd
    8000186a:	eca98993          	addi	s3,s3,-310 # 8000e730 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000186e:	00007c17          	auipc	s8,0x7
    80001872:	0aac0c13          	addi	s8,s8,170 # 80008918 <wait_lock>
    havekids = 0;
    80001876:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001878:	00007497          	auipc	s1,0x7
    8000187c:	4b848493          	addi	s1,s1,1208 # 80008d30 <proc>
    80001880:	a0bd                	j	800018ee <wait+0xc2>
          pid = pp->pid;
    80001882:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001886:	000b0e63          	beqz	s6,800018a2 <wait+0x76>
    8000188a:	4691                	li	a3,4
    8000188c:	02c48613          	addi	a2,s1,44
    80001890:	85da                	mv	a1,s6
    80001892:	05093503          	ld	a0,80(s2)
    80001896:	fffff097          	auipc	ra,0xfffff
    8000189a:	2d4080e7          	jalr	724(ra) # 80000b6a <copyout>
    8000189e:	02054563          	bltz	a0,800018c8 <wait+0x9c>
          freeproc(pp);
    800018a2:	8526                	mv	a0,s1
    800018a4:	fffff097          	auipc	ra,0xfffff
    800018a8:	7b8080e7          	jalr	1976(ra) # 8000105c <freeproc>
          release(&pp->lock);
    800018ac:	8526                	mv	a0,s1
    800018ae:	00005097          	auipc	ra,0x5
    800018b2:	a1a080e7          	jalr	-1510(ra) # 800062c8 <release>
          release(&wait_lock);
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	06250513          	addi	a0,a0,98 # 80008918 <wait_lock>
    800018be:	00005097          	auipc	ra,0x5
    800018c2:	a0a080e7          	jalr	-1526(ra) # 800062c8 <release>
          return pid;
    800018c6:	a0b5                	j	80001932 <wait+0x106>
            release(&pp->lock);
    800018c8:	8526                	mv	a0,s1
    800018ca:	00005097          	auipc	ra,0x5
    800018ce:	9fe080e7          	jalr	-1538(ra) # 800062c8 <release>
            release(&wait_lock);
    800018d2:	00007517          	auipc	a0,0x7
    800018d6:	04650513          	addi	a0,a0,70 # 80008918 <wait_lock>
    800018da:	00005097          	auipc	ra,0x5
    800018de:	9ee080e7          	jalr	-1554(ra) # 800062c8 <release>
            return -1;
    800018e2:	59fd                	li	s3,-1
    800018e4:	a0b9                	j	80001932 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800018e6:	16848493          	addi	s1,s1,360
    800018ea:	03348463          	beq	s1,s3,80001912 <wait+0xe6>
      if(pp->parent == p){
    800018ee:	7c9c                	ld	a5,56(s1)
    800018f0:	ff279be3          	bne	a5,s2,800018e6 <wait+0xba>
        acquire(&pp->lock);
    800018f4:	8526                	mv	a0,s1
    800018f6:	00005097          	auipc	ra,0x5
    800018fa:	91e080e7          	jalr	-1762(ra) # 80006214 <acquire>
        if(pp->state == ZOMBIE){
    800018fe:	4c9c                	lw	a5,24(s1)
    80001900:	f94781e3          	beq	a5,s4,80001882 <wait+0x56>
        release(&pp->lock);
    80001904:	8526                	mv	a0,s1
    80001906:	00005097          	auipc	ra,0x5
    8000190a:	9c2080e7          	jalr	-1598(ra) # 800062c8 <release>
        havekids = 1;
    8000190e:	8756                	mv	a4,s5
    80001910:	bfd9                	j	800018e6 <wait+0xba>
    if(!havekids || killed(p)){
    80001912:	c719                	beqz	a4,80001920 <wait+0xf4>
    80001914:	854a                	mv	a0,s2
    80001916:	00000097          	auipc	ra,0x0
    8000191a:	ee4080e7          	jalr	-284(ra) # 800017fa <killed>
    8000191e:	c51d                	beqz	a0,8000194c <wait+0x120>
      release(&wait_lock);
    80001920:	00007517          	auipc	a0,0x7
    80001924:	ff850513          	addi	a0,a0,-8 # 80008918 <wait_lock>
    80001928:	00005097          	auipc	ra,0x5
    8000192c:	9a0080e7          	jalr	-1632(ra) # 800062c8 <release>
      return -1;
    80001930:	59fd                	li	s3,-1
}
    80001932:	854e                	mv	a0,s3
    80001934:	60a6                	ld	ra,72(sp)
    80001936:	6406                	ld	s0,64(sp)
    80001938:	74e2                	ld	s1,56(sp)
    8000193a:	7942                	ld	s2,48(sp)
    8000193c:	79a2                	ld	s3,40(sp)
    8000193e:	7a02                	ld	s4,32(sp)
    80001940:	6ae2                	ld	s5,24(sp)
    80001942:	6b42                	ld	s6,16(sp)
    80001944:	6ba2                	ld	s7,8(sp)
    80001946:	6c02                	ld	s8,0(sp)
    80001948:	6161                	addi	sp,sp,80
    8000194a:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000194c:	85e2                	mv	a1,s8
    8000194e:	854a                	mv	a0,s2
    80001950:	00000097          	auipc	ra,0x0
    80001954:	c02080e7          	jalr	-1022(ra) # 80001552 <sleep>
    havekids = 0;
    80001958:	bf39                	j	80001876 <wait+0x4a>

000000008000195a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000195a:	7179                	addi	sp,sp,-48
    8000195c:	f406                	sd	ra,40(sp)
    8000195e:	f022                	sd	s0,32(sp)
    80001960:	ec26                	sd	s1,24(sp)
    80001962:	e84a                	sd	s2,16(sp)
    80001964:	e44e                	sd	s3,8(sp)
    80001966:	e052                	sd	s4,0(sp)
    80001968:	1800                	addi	s0,sp,48
    8000196a:	84aa                	mv	s1,a0
    8000196c:	892e                	mv	s2,a1
    8000196e:	89b2                	mv	s3,a2
    80001970:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001972:	fffff097          	auipc	ra,0xfffff
    80001976:	538080e7          	jalr	1336(ra) # 80000eaa <myproc>
  if(user_dst){
    8000197a:	c08d                	beqz	s1,8000199c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000197c:	86d2                	mv	a3,s4
    8000197e:	864e                	mv	a2,s3
    80001980:	85ca                	mv	a1,s2
    80001982:	6928                	ld	a0,80(a0)
    80001984:	fffff097          	auipc	ra,0xfffff
    80001988:	1e6080e7          	jalr	486(ra) # 80000b6a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000198c:	70a2                	ld	ra,40(sp)
    8000198e:	7402                	ld	s0,32(sp)
    80001990:	64e2                	ld	s1,24(sp)
    80001992:	6942                	ld	s2,16(sp)
    80001994:	69a2                	ld	s3,8(sp)
    80001996:	6a02                	ld	s4,0(sp)
    80001998:	6145                	addi	sp,sp,48
    8000199a:	8082                	ret
    memmove((char *)dst, src, len);
    8000199c:	000a061b          	sext.w	a2,s4
    800019a0:	85ce                	mv	a1,s3
    800019a2:	854a                	mv	a0,s2
    800019a4:	fffff097          	auipc	ra,0xfffff
    800019a8:	832080e7          	jalr	-1998(ra) # 800001d6 <memmove>
    return 0;
    800019ac:	8526                	mv	a0,s1
    800019ae:	bff9                	j	8000198c <either_copyout+0x32>

00000000800019b0 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800019b0:	7179                	addi	sp,sp,-48
    800019b2:	f406                	sd	ra,40(sp)
    800019b4:	f022                	sd	s0,32(sp)
    800019b6:	ec26                	sd	s1,24(sp)
    800019b8:	e84a                	sd	s2,16(sp)
    800019ba:	e44e                	sd	s3,8(sp)
    800019bc:	e052                	sd	s4,0(sp)
    800019be:	1800                	addi	s0,sp,48
    800019c0:	892a                	mv	s2,a0
    800019c2:	84ae                	mv	s1,a1
    800019c4:	89b2                	mv	s3,a2
    800019c6:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800019c8:	fffff097          	auipc	ra,0xfffff
    800019cc:	4e2080e7          	jalr	1250(ra) # 80000eaa <myproc>
  if(user_src){
    800019d0:	c08d                	beqz	s1,800019f2 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800019d2:	86d2                	mv	a3,s4
    800019d4:	864e                	mv	a2,s3
    800019d6:	85ca                	mv	a1,s2
    800019d8:	6928                	ld	a0,80(a0)
    800019da:	fffff097          	auipc	ra,0xfffff
    800019de:	21c080e7          	jalr	540(ra) # 80000bf6 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800019e2:	70a2                	ld	ra,40(sp)
    800019e4:	7402                	ld	s0,32(sp)
    800019e6:	64e2                	ld	s1,24(sp)
    800019e8:	6942                	ld	s2,16(sp)
    800019ea:	69a2                	ld	s3,8(sp)
    800019ec:	6a02                	ld	s4,0(sp)
    800019ee:	6145                	addi	sp,sp,48
    800019f0:	8082                	ret
    memmove(dst, (char*)src, len);
    800019f2:	000a061b          	sext.w	a2,s4
    800019f6:	85ce                	mv	a1,s3
    800019f8:	854a                	mv	a0,s2
    800019fa:	ffffe097          	auipc	ra,0xffffe
    800019fe:	7dc080e7          	jalr	2012(ra) # 800001d6 <memmove>
    return 0;
    80001a02:	8526                	mv	a0,s1
    80001a04:	bff9                	j	800019e2 <either_copyin+0x32>

0000000080001a06 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001a06:	715d                	addi	sp,sp,-80
    80001a08:	e486                	sd	ra,72(sp)
    80001a0a:	e0a2                	sd	s0,64(sp)
    80001a0c:	fc26                	sd	s1,56(sp)
    80001a0e:	f84a                	sd	s2,48(sp)
    80001a10:	f44e                	sd	s3,40(sp)
    80001a12:	f052                	sd	s4,32(sp)
    80001a14:	ec56                	sd	s5,24(sp)
    80001a16:	e85a                	sd	s6,16(sp)
    80001a18:	e45e                	sd	s7,8(sp)
    80001a1a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001a1c:	00006517          	auipc	a0,0x6
    80001a20:	62c50513          	addi	a0,a0,1580 # 80008048 <etext+0x48>
    80001a24:	00004097          	auipc	ra,0x4
    80001a28:	302080e7          	jalr	770(ra) # 80005d26 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a2c:	00007497          	auipc	s1,0x7
    80001a30:	45c48493          	addi	s1,s1,1116 # 80008e88 <proc+0x158>
    80001a34:	0000d917          	auipc	s2,0xd
    80001a38:	e5490913          	addi	s2,s2,-428 # 8000e888 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a3c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001a3e:	00006997          	auipc	s3,0x6
    80001a42:	7c298993          	addi	s3,s3,1986 # 80008200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    80001a46:	00006a97          	auipc	s5,0x6
    80001a4a:	7c2a8a93          	addi	s5,s5,1986 # 80008208 <etext+0x208>
    printf("\n");
    80001a4e:	00006a17          	auipc	s4,0x6
    80001a52:	5faa0a13          	addi	s4,s4,1530 # 80008048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a56:	00006b97          	auipc	s7,0x6
    80001a5a:	7f2b8b93          	addi	s7,s7,2034 # 80008248 <states.0>
    80001a5e:	a00d                	j	80001a80 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001a60:	ed86a583          	lw	a1,-296(a3)
    80001a64:	8556                	mv	a0,s5
    80001a66:	00004097          	auipc	ra,0x4
    80001a6a:	2c0080e7          	jalr	704(ra) # 80005d26 <printf>
    printf("\n");
    80001a6e:	8552                	mv	a0,s4
    80001a70:	00004097          	auipc	ra,0x4
    80001a74:	2b6080e7          	jalr	694(ra) # 80005d26 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a78:	16848493          	addi	s1,s1,360
    80001a7c:	03248263          	beq	s1,s2,80001aa0 <procdump+0x9a>
    if(p->state == UNUSED)
    80001a80:	86a6                	mv	a3,s1
    80001a82:	ec04a783          	lw	a5,-320(s1)
    80001a86:	dbed                	beqz	a5,80001a78 <procdump+0x72>
      state = "???";
    80001a88:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a8a:	fcfb6be3          	bltu	s6,a5,80001a60 <procdump+0x5a>
    80001a8e:	02079713          	slli	a4,a5,0x20
    80001a92:	01d75793          	srli	a5,a4,0x1d
    80001a96:	97de                	add	a5,a5,s7
    80001a98:	6390                	ld	a2,0(a5)
    80001a9a:	f279                	bnez	a2,80001a60 <procdump+0x5a>
      state = "???";
    80001a9c:	864e                	mv	a2,s3
    80001a9e:	b7c9                	j	80001a60 <procdump+0x5a>
  }
}
    80001aa0:	60a6                	ld	ra,72(sp)
    80001aa2:	6406                	ld	s0,64(sp)
    80001aa4:	74e2                	ld	s1,56(sp)
    80001aa6:	7942                	ld	s2,48(sp)
    80001aa8:	79a2                	ld	s3,40(sp)
    80001aaa:	7a02                	ld	s4,32(sp)
    80001aac:	6ae2                	ld	s5,24(sp)
    80001aae:	6b42                	ld	s6,16(sp)
    80001ab0:	6ba2                	ld	s7,8(sp)
    80001ab2:	6161                	addi	sp,sp,80
    80001ab4:	8082                	ret

0000000080001ab6 <swtch>:
    80001ab6:	00153023          	sd	ra,0(a0)
    80001aba:	00253423          	sd	sp,8(a0)
    80001abe:	e900                	sd	s0,16(a0)
    80001ac0:	ed04                	sd	s1,24(a0)
    80001ac2:	03253023          	sd	s2,32(a0)
    80001ac6:	03353423          	sd	s3,40(a0)
    80001aca:	03453823          	sd	s4,48(a0)
    80001ace:	03553c23          	sd	s5,56(a0)
    80001ad2:	05653023          	sd	s6,64(a0)
    80001ad6:	05753423          	sd	s7,72(a0)
    80001ada:	05853823          	sd	s8,80(a0)
    80001ade:	05953c23          	sd	s9,88(a0)
    80001ae2:	07a53023          	sd	s10,96(a0)
    80001ae6:	07b53423          	sd	s11,104(a0)
    80001aea:	0005b083          	ld	ra,0(a1)
    80001aee:	0085b103          	ld	sp,8(a1)
    80001af2:	6980                	ld	s0,16(a1)
    80001af4:	6d84                	ld	s1,24(a1)
    80001af6:	0205b903          	ld	s2,32(a1)
    80001afa:	0285b983          	ld	s3,40(a1)
    80001afe:	0305ba03          	ld	s4,48(a1)
    80001b02:	0385ba83          	ld	s5,56(a1)
    80001b06:	0405bb03          	ld	s6,64(a1)
    80001b0a:	0485bb83          	ld	s7,72(a1)
    80001b0e:	0505bc03          	ld	s8,80(a1)
    80001b12:	0585bc83          	ld	s9,88(a1)
    80001b16:	0605bd03          	ld	s10,96(a1)
    80001b1a:	0685bd83          	ld	s11,104(a1)
    80001b1e:	8082                	ret

0000000080001b20 <page_fault_handling>:

extern int devintr();

// function to handle page faults, takes in a virtual address and a page table.
// 
int page_fault_handling(void* va, pagetable_t pagetable){
    80001b20:	7179                	addi	sp,sp,-48
    80001b22:	f406                	sd	ra,40(sp)
    80001b24:	f022                	sd	s0,32(sp)
    80001b26:	ec26                	sd	s1,24(sp)
    80001b28:	e84a                	sd	s2,16(sp)
    80001b2a:	e44e                	sd	s3,8(sp)
    80001b2c:	e052                	sd	s4,0(sp)
    80001b2e:	1800                	addi	s0,sp,48
    80001b30:	84aa                	mv	s1,a0
    80001b32:	892e                	mv	s2,a1
  struct proc* p = myproc();
    80001b34:	fffff097          	auipc	ra,0xfffff
    80001b38:	376080e7          	jalr	886(ra) # 80000eaa <myproc>
  pte_t *pte;
  uint64 pa;
  uint flags;
  // check if the virtual address is beyond the maximum or within the guard page range
  if ((uint64)va >= MAXVA || ((uint64)va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE &&
    80001b3c:	57fd                	li	a5,-1
    80001b3e:	83e9                	srli	a5,a5,0x1a
    80001b40:	0897e663          	bltu	a5,s1,80001bcc <page_fault_handling+0xac>
    80001b44:	6d38                	ld	a4,88(a0)
    80001b46:	77fd                	lui	a5,0xfffff
    80001b48:	7b18                	ld	a4,48(a4)
    80001b4a:	8f7d                	and	a4,a4,a5
    80001b4c:	97ba                	add	a5,a5,a4
    80001b4e:	00f4e463          	bltu	s1,a5,80001b56 <page_fault_handling+0x36>
    80001b52:	06977f63          	bgeu	a4,s1,80001bd0 <page_fault_handling+0xb0>
     (uint64)va <= PGROUNDDOWN(p->trapframe->sp))) {
    return -2; //invalid
  }
  va = (void*)PGROUNDDOWN((uint64)va); // align the address to page boundary
  pte = walk(pagetable, (uint64)va, 0); // find the page table entry for the address
    80001b56:	4601                	li	a2,0
    80001b58:	75fd                	lui	a1,0xfffff
    80001b5a:	8de5                	and	a1,a1,s1
    80001b5c:	854a                	mv	a0,s2
    80001b5e:	fffff097          	auipc	ra,0xfffff
    80001b62:	900080e7          	jalr	-1792(ra) # 8000045e <walk>
    80001b66:	84aa                	mv	s1,a0
  if (pte == 0) {
    80001b68:	c535                	beqz	a0,80001bd4 <page_fault_handling+0xb4>
    return -1; //not found
  }
  pa = PTE2PA(*pte); // get physical address from the PTE
    80001b6a:	611c                	ld	a5,0(a0)
    80001b6c:	00a7d913          	srli	s2,a5,0xa
    80001b70:	0932                	slli	s2,s2,0xc
  if (pa == 0) {
    80001b72:	06090363          	beqz	s2,80001bd8 <page_fault_handling+0xb8>
    return -1; //invalid
  }
  flags = PTE_FLAGS(*pte); // extract flags from the PTE
    80001b76:	0007871b          	sext.w	a4,a5
  
  // check if the page is marked as COW
  if (flags & PTE_COW) {
    80001b7a:	1007f793          	andi	a5,a5,256
    memmove(mem, (void*)pa, PGSIZE); // copy the content of the old page to the new page
    *pte = PA2PTE((uint64)mem) | flags; // update the PTE to point to the new page
    kfree((void*)pa); // free the old page
    return 0;
  }
  return 0;
    80001b7e:	4501                	li	a0,0
  if (flags & PTE_COW) {
    80001b80:	eb89                	bnez	a5,80001b92 <page_fault_handling+0x72>
}
    80001b82:	70a2                	ld	ra,40(sp)
    80001b84:	7402                	ld	s0,32(sp)
    80001b86:	64e2                	ld	s1,24(sp)
    80001b88:	6942                	ld	s2,16(sp)
    80001b8a:	69a2                	ld	s3,8(sp)
    80001b8c:	6a02                	ld	s4,0(sp)
    80001b8e:	6145                	addi	sp,sp,48
    80001b90:	8082                	ret
    flags = (flags | PTE_W) & (~PTE_COW); // change the page to writable and clear the COW flag
    80001b92:	2ff77713          	andi	a4,a4,767
    80001b96:	00476993          	ori	s3,a4,4
    char *mem = kalloc(); // allocate a new page
    80001b9a:	ffffe097          	auipc	ra,0xffffe
    80001b9e:	580080e7          	jalr	1408(ra) # 8000011a <kalloc>
    80001ba2:	8a2a                	mv	s4,a0
    if (mem == 0) {
    80001ba4:	cd05                	beqz	a0,80001bdc <page_fault_handling+0xbc>
    memmove(mem, (void*)pa, PGSIZE); // copy the content of the old page to the new page
    80001ba6:	6605                	lui	a2,0x1
    80001ba8:	85ca                	mv	a1,s2
    80001baa:	ffffe097          	auipc	ra,0xffffe
    80001bae:	62c080e7          	jalr	1580(ra) # 800001d6 <memmove>
    *pte = PA2PTE((uint64)mem) | flags; // update the PTE to point to the new page
    80001bb2:	00ca5a13          	srli	s4,s4,0xc
    80001bb6:	0a2a                	slli	s4,s4,0xa
    80001bb8:	0149e733          	or	a4,s3,s4
    80001bbc:	e098                	sd	a4,0(s1)
    kfree((void*)pa); // free the old page
    80001bbe:	854a                	mv	a0,s2
    80001bc0:	ffffe097          	auipc	ra,0xffffe
    80001bc4:	45c080e7          	jalr	1116(ra) # 8000001c <kfree>
    return 0;
    80001bc8:	4501                	li	a0,0
    80001bca:	bf65                	j	80001b82 <page_fault_handling+0x62>
    return -2; //invalid
    80001bcc:	5579                	li	a0,-2
    80001bce:	bf55                	j	80001b82 <page_fault_handling+0x62>
    80001bd0:	5579                	li	a0,-2
    80001bd2:	bf45                	j	80001b82 <page_fault_handling+0x62>
    return -1; //not found
    80001bd4:	557d                	li	a0,-1
    80001bd6:	b775                	j	80001b82 <page_fault_handling+0x62>
    return -1; //invalid
    80001bd8:	557d                	li	a0,-1
    80001bda:	b765                	j	80001b82 <page_fault_handling+0x62>
      return -1; // memory allocation failed
    80001bdc:	557d                	li	a0,-1
    80001bde:	b755                	j	80001b82 <page_fault_handling+0x62>

0000000080001be0 <trapinit>:

void
trapinit(void)
{
    80001be0:	1141                	addi	sp,sp,-16
    80001be2:	e406                	sd	ra,8(sp)
    80001be4:	e022                	sd	s0,0(sp)
    80001be6:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001be8:	00006597          	auipc	a1,0x6
    80001bec:	69058593          	addi	a1,a1,1680 # 80008278 <states.0+0x30>
    80001bf0:	0000d517          	auipc	a0,0xd
    80001bf4:	b4050513          	addi	a0,a0,-1216 # 8000e730 <tickslock>
    80001bf8:	00004097          	auipc	ra,0x4
    80001bfc:	58c080e7          	jalr	1420(ra) # 80006184 <initlock>
}
    80001c00:	60a2                	ld	ra,8(sp)
    80001c02:	6402                	ld	s0,0(sp)
    80001c04:	0141                	addi	sp,sp,16
    80001c06:	8082                	ret

0000000080001c08 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001c08:	1141                	addi	sp,sp,-16
    80001c0a:	e422                	sd	s0,8(sp)
    80001c0c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c0e:	00003797          	auipc	a5,0x3
    80001c12:	50278793          	addi	a5,a5,1282 # 80005110 <kernelvec>
    80001c16:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001c1a:	6422                	ld	s0,8(sp)
    80001c1c:	0141                	addi	sp,sp,16
    80001c1e:	8082                	ret

0000000080001c20 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001c20:	1141                	addi	sp,sp,-16
    80001c22:	e406                	sd	ra,8(sp)
    80001c24:	e022                	sd	s0,0(sp)
    80001c26:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001c28:	fffff097          	auipc	ra,0xfffff
    80001c2c:	282080e7          	jalr	642(ra) # 80000eaa <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c30:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001c34:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c36:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001c3a:	00005697          	auipc	a3,0x5
    80001c3e:	3c668693          	addi	a3,a3,966 # 80007000 <_trampoline>
    80001c42:	00005717          	auipc	a4,0x5
    80001c46:	3be70713          	addi	a4,a4,958 # 80007000 <_trampoline>
    80001c4a:	8f15                	sub	a4,a4,a3
    80001c4c:	040007b7          	lui	a5,0x4000
    80001c50:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001c52:	07b2                	slli	a5,a5,0xc
    80001c54:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c56:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001c5a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001c5c:	18002673          	csrr	a2,satp
    80001c60:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001c62:	6d30                	ld	a2,88(a0)
    80001c64:	6138                	ld	a4,64(a0)
    80001c66:	6585                	lui	a1,0x1
    80001c68:	972e                	add	a4,a4,a1
    80001c6a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001c6c:	6d38                	ld	a4,88(a0)
    80001c6e:	00000617          	auipc	a2,0x0
    80001c72:	13060613          	addi	a2,a2,304 # 80001d9e <usertrap>
    80001c76:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001c78:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c7a:	8612                	mv	a2,tp
    80001c7c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c7e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001c82:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001c86:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c8a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001c8e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c90:	6f18                	ld	a4,24(a4)
    80001c92:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c96:	6928                	ld	a0,80(a0)
    80001c98:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c9a:	00005717          	auipc	a4,0x5
    80001c9e:	40270713          	addi	a4,a4,1026 # 8000709c <userret>
    80001ca2:	8f15                	sub	a4,a4,a3
    80001ca4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001ca6:	577d                	li	a4,-1
    80001ca8:	177e                	slli	a4,a4,0x3f
    80001caa:	8d59                	or	a0,a0,a4
    80001cac:	9782                	jalr	a5
}
    80001cae:	60a2                	ld	ra,8(sp)
    80001cb0:	6402                	ld	s0,0(sp)
    80001cb2:	0141                	addi	sp,sp,16
    80001cb4:	8082                	ret

0000000080001cb6 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001cb6:	1101                	addi	sp,sp,-32
    80001cb8:	ec06                	sd	ra,24(sp)
    80001cba:	e822                	sd	s0,16(sp)
    80001cbc:	e426                	sd	s1,8(sp)
    80001cbe:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001cc0:	0000d497          	auipc	s1,0xd
    80001cc4:	a7048493          	addi	s1,s1,-1424 # 8000e730 <tickslock>
    80001cc8:	8526                	mv	a0,s1
    80001cca:	00004097          	auipc	ra,0x4
    80001cce:	54a080e7          	jalr	1354(ra) # 80006214 <acquire>
  ticks++;
    80001cd2:	00007517          	auipc	a0,0x7
    80001cd6:	bf650513          	addi	a0,a0,-1034 # 800088c8 <ticks>
    80001cda:	411c                	lw	a5,0(a0)
    80001cdc:	2785                	addiw	a5,a5,1
    80001cde:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001ce0:	00000097          	auipc	ra,0x0
    80001ce4:	8d6080e7          	jalr	-1834(ra) # 800015b6 <wakeup>
  release(&tickslock);
    80001ce8:	8526                	mv	a0,s1
    80001cea:	00004097          	auipc	ra,0x4
    80001cee:	5de080e7          	jalr	1502(ra) # 800062c8 <release>
}
    80001cf2:	60e2                	ld	ra,24(sp)
    80001cf4:	6442                	ld	s0,16(sp)
    80001cf6:	64a2                	ld	s1,8(sp)
    80001cf8:	6105                	addi	sp,sp,32
    80001cfa:	8082                	ret

0000000080001cfc <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001cfc:	1101                	addi	sp,sp,-32
    80001cfe:	ec06                	sd	ra,24(sp)
    80001d00:	e822                	sd	s0,16(sp)
    80001d02:	e426                	sd	s1,8(sp)
    80001d04:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d06:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001d0a:	00074d63          	bltz	a4,80001d24 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001d0e:	57fd                	li	a5,-1
    80001d10:	17fe                	slli	a5,a5,0x3f
    80001d12:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001d14:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001d16:	06f70363          	beq	a4,a5,80001d7c <devintr+0x80>
  }
}
    80001d1a:	60e2                	ld	ra,24(sp)
    80001d1c:	6442                	ld	s0,16(sp)
    80001d1e:	64a2                	ld	s1,8(sp)
    80001d20:	6105                	addi	sp,sp,32
    80001d22:	8082                	ret
     (scause & 0xff) == 9){
    80001d24:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80001d28:	46a5                	li	a3,9
    80001d2a:	fed792e3          	bne	a5,a3,80001d0e <devintr+0x12>
    int irq = plic_claim();
    80001d2e:	00003097          	auipc	ra,0x3
    80001d32:	4ea080e7          	jalr	1258(ra) # 80005218 <plic_claim>
    80001d36:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001d38:	47a9                	li	a5,10
    80001d3a:	02f50763          	beq	a0,a5,80001d68 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001d3e:	4785                	li	a5,1
    80001d40:	02f50963          	beq	a0,a5,80001d72 <devintr+0x76>
    return 1;
    80001d44:	4505                	li	a0,1
    } else if(irq){
    80001d46:	d8f1                	beqz	s1,80001d1a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001d48:	85a6                	mv	a1,s1
    80001d4a:	00006517          	auipc	a0,0x6
    80001d4e:	53650513          	addi	a0,a0,1334 # 80008280 <states.0+0x38>
    80001d52:	00004097          	auipc	ra,0x4
    80001d56:	fd4080e7          	jalr	-44(ra) # 80005d26 <printf>
      plic_complete(irq);
    80001d5a:	8526                	mv	a0,s1
    80001d5c:	00003097          	auipc	ra,0x3
    80001d60:	4e0080e7          	jalr	1248(ra) # 8000523c <plic_complete>
    return 1;
    80001d64:	4505                	li	a0,1
    80001d66:	bf55                	j	80001d1a <devintr+0x1e>
      uartintr();
    80001d68:	00004097          	auipc	ra,0x4
    80001d6c:	3cc080e7          	jalr	972(ra) # 80006134 <uartintr>
    80001d70:	b7ed                	j	80001d5a <devintr+0x5e>
      virtio_disk_intr();
    80001d72:	00004097          	auipc	ra,0x4
    80001d76:	992080e7          	jalr	-1646(ra) # 80005704 <virtio_disk_intr>
    80001d7a:	b7c5                	j	80001d5a <devintr+0x5e>
    if(cpuid() == 0){
    80001d7c:	fffff097          	auipc	ra,0xfffff
    80001d80:	102080e7          	jalr	258(ra) # 80000e7e <cpuid>
    80001d84:	c901                	beqz	a0,80001d94 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001d86:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001d8a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001d8c:	14479073          	csrw	sip,a5
    return 2;
    80001d90:	4509                	li	a0,2
    80001d92:	b761                	j	80001d1a <devintr+0x1e>
      clockintr();
    80001d94:	00000097          	auipc	ra,0x0
    80001d98:	f22080e7          	jalr	-222(ra) # 80001cb6 <clockintr>
    80001d9c:	b7ed                	j	80001d86 <devintr+0x8a>

0000000080001d9e <usertrap>:
usertrap(void) {
    80001d9e:	1101                	addi	sp,sp,-32
    80001da0:	ec06                	sd	ra,24(sp)
    80001da2:	e822                	sd	s0,16(sp)
    80001da4:	e426                	sd	s1,8(sp)
    80001da6:	e04a                	sd	s2,0(sp)
    80001da8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001daa:	100027f3          	csrr	a5,sstatus
    if ((r_sstatus() & SSTATUS_SPP) != 0)
    80001dae:	1007f793          	andi	a5,a5,256
    80001db2:	e3b5                	bnez	a5,80001e16 <usertrap+0x78>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001db4:	00003797          	auipc	a5,0x3
    80001db8:	35c78793          	addi	a5,a5,860 # 80005110 <kernelvec>
    80001dbc:	10579073          	csrw	stvec,a5
    struct proc *p = myproc();
    80001dc0:	fffff097          	auipc	ra,0xfffff
    80001dc4:	0ea080e7          	jalr	234(ra) # 80000eaa <myproc>
    80001dc8:	84aa                	mv	s1,a0
    p->trapframe->epc = r_sepc();
    80001dca:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001dcc:	14102773          	csrr	a4,sepc
    80001dd0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dd2:	14202773          	csrr	a4,scause
    if (r_scause() == 8) {
    80001dd6:	47a1                	li	a5,8
    80001dd8:	04f70763          	beq	a4,a5,80001e26 <usertrap+0x88>
    } else if ((which_dev = devintr()) != 0) {
    80001ddc:	00000097          	auipc	ra,0x0
    80001de0:	f20080e7          	jalr	-224(ra) # 80001cfc <devintr>
    80001de4:	892a                	mv	s2,a0
    80001de6:	e571                	bnez	a0,80001eb2 <usertrap+0x114>
    80001de8:	14202773          	csrr	a4,scause
    } else if (r_scause() == 15 || r_scause() == 13) { // check if the cause is a page fault (load or store)
    80001dec:	47bd                	li	a5,15
    80001dee:	00f70763          	beq	a4,a5,80001dfc <usertrap+0x5e>
    80001df2:	14202773          	csrr	a4,scause
    80001df6:	47b5                	li	a5,13
    80001df8:	08f71063          	bne	a4,a5,80001e78 <usertrap+0xda>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001dfc:	14302573          	csrr	a0,stval
        int res = page_fault_handling((void*)r_stval(), p->pagetable); // handle the page fault
    80001e00:	68ac                	ld	a1,80(s1)
    80001e02:	00000097          	auipc	ra,0x0
    80001e06:	d1e080e7          	jalr	-738(ra) # 80001b20 <page_fault_handling>
        if (res == -1 || res == -2) {
    80001e0a:	2509                	addiw	a0,a0,2
    80001e0c:	4785                	li	a5,1
    80001e0e:	02a7ef63          	bltu	a5,a0,80001e4c <usertrap+0xae>
            p->killed = 1; // kill the process if the page fault was invalid or couldn't be handled
    80001e12:	d49c                	sw	a5,40(s1)
    80001e14:	a825                	j	80001e4c <usertrap+0xae>
        panic("usertrap: not from user mode");
    80001e16:	00006517          	auipc	a0,0x6
    80001e1a:	48a50513          	addi	a0,a0,1162 # 800082a0 <states.0+0x58>
    80001e1e:	00004097          	auipc	ra,0x4
    80001e22:	ebe080e7          	jalr	-322(ra) # 80005cdc <panic>
        if (killed(p))
    80001e26:	00000097          	auipc	ra,0x0
    80001e2a:	9d4080e7          	jalr	-1580(ra) # 800017fa <killed>
    80001e2e:	ed1d                	bnez	a0,80001e6c <usertrap+0xce>
        p->trapframe->epc += 4;
    80001e30:	6cb8                	ld	a4,88(s1)
    80001e32:	6f1c                	ld	a5,24(a4)
    80001e34:	0791                	addi	a5,a5,4
    80001e36:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e38:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e3c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e40:	10079073          	csrw	sstatus,a5
        syscall();
    80001e44:	00000097          	auipc	ra,0x0
    80001e48:	2e2080e7          	jalr	738(ra) # 80002126 <syscall>
    if (killed(p))
    80001e4c:	8526                	mv	a0,s1
    80001e4e:	00000097          	auipc	ra,0x0
    80001e52:	9ac080e7          	jalr	-1620(ra) # 800017fa <killed>
    80001e56:	e52d                	bnez	a0,80001ec0 <usertrap+0x122>
    usertrapret();
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	dc8080e7          	jalr	-568(ra) # 80001c20 <usertrapret>
}
    80001e60:	60e2                	ld	ra,24(sp)
    80001e62:	6442                	ld	s0,16(sp)
    80001e64:	64a2                	ld	s1,8(sp)
    80001e66:	6902                	ld	s2,0(sp)
    80001e68:	6105                	addi	sp,sp,32
    80001e6a:	8082                	ret
            exit(-1);
    80001e6c:	557d                	li	a0,-1
    80001e6e:	00000097          	auipc	ra,0x0
    80001e72:	818080e7          	jalr	-2024(ra) # 80001686 <exit>
    80001e76:	bf6d                	j	80001e30 <usertrap+0x92>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e78:	142025f3          	csrr	a1,scause
        printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001e7c:	5890                	lw	a2,48(s1)
    80001e7e:	00006517          	auipc	a0,0x6
    80001e82:	44250513          	addi	a0,a0,1090 # 800082c0 <states.0+0x78>
    80001e86:	00004097          	auipc	ra,0x4
    80001e8a:	ea0080e7          	jalr	-352(ra) # 80005d26 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e8e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e92:	14302673          	csrr	a2,stval
        printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e96:	00006517          	auipc	a0,0x6
    80001e9a:	45a50513          	addi	a0,a0,1114 # 800082f0 <states.0+0xa8>
    80001e9e:	00004097          	auipc	ra,0x4
    80001ea2:	e88080e7          	jalr	-376(ra) # 80005d26 <printf>
        setkilled(p);
    80001ea6:	8526                	mv	a0,s1
    80001ea8:	00000097          	auipc	ra,0x0
    80001eac:	926080e7          	jalr	-1754(ra) # 800017ce <setkilled>
    80001eb0:	bf71                	j	80001e4c <usertrap+0xae>
    if (killed(p))
    80001eb2:	8526                	mv	a0,s1
    80001eb4:	00000097          	auipc	ra,0x0
    80001eb8:	946080e7          	jalr	-1722(ra) # 800017fa <killed>
    80001ebc:	c901                	beqz	a0,80001ecc <usertrap+0x12e>
    80001ebe:	a011                	j	80001ec2 <usertrap+0x124>
    80001ec0:	4901                	li	s2,0
        exit(-1);
    80001ec2:	557d                	li	a0,-1
    80001ec4:	fffff097          	auipc	ra,0xfffff
    80001ec8:	7c2080e7          	jalr	1986(ra) # 80001686 <exit>
    if (which_dev == 2)
    80001ecc:	4789                	li	a5,2
    80001ece:	f8f915e3          	bne	s2,a5,80001e58 <usertrap+0xba>
        yield();
    80001ed2:	fffff097          	auipc	ra,0xfffff
    80001ed6:	644080e7          	jalr	1604(ra) # 80001516 <yield>
    80001eda:	bfbd                	j	80001e58 <usertrap+0xba>

0000000080001edc <kerneltrap>:
{
    80001edc:	7179                	addi	sp,sp,-48
    80001ede:	f406                	sd	ra,40(sp)
    80001ee0:	f022                	sd	s0,32(sp)
    80001ee2:	ec26                	sd	s1,24(sp)
    80001ee4:	e84a                	sd	s2,16(sp)
    80001ee6:	e44e                	sd	s3,8(sp)
    80001ee8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001eea:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001eee:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ef2:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001ef6:	1004f793          	andi	a5,s1,256
    80001efa:	cb85                	beqz	a5,80001f2a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001efc:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f00:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001f02:	ef85                	bnez	a5,80001f3a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001f04:	00000097          	auipc	ra,0x0
    80001f08:	df8080e7          	jalr	-520(ra) # 80001cfc <devintr>
    80001f0c:	cd1d                	beqz	a0,80001f4a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001f0e:	4789                	li	a5,2
    80001f10:	06f50a63          	beq	a0,a5,80001f84 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001f14:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f18:	10049073          	csrw	sstatus,s1
}
    80001f1c:	70a2                	ld	ra,40(sp)
    80001f1e:	7402                	ld	s0,32(sp)
    80001f20:	64e2                	ld	s1,24(sp)
    80001f22:	6942                	ld	s2,16(sp)
    80001f24:	69a2                	ld	s3,8(sp)
    80001f26:	6145                	addi	sp,sp,48
    80001f28:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001f2a:	00006517          	auipc	a0,0x6
    80001f2e:	3e650513          	addi	a0,a0,998 # 80008310 <states.0+0xc8>
    80001f32:	00004097          	auipc	ra,0x4
    80001f36:	daa080e7          	jalr	-598(ra) # 80005cdc <panic>
    panic("kerneltrap: interrupts enabled");
    80001f3a:	00006517          	auipc	a0,0x6
    80001f3e:	3fe50513          	addi	a0,a0,1022 # 80008338 <states.0+0xf0>
    80001f42:	00004097          	auipc	ra,0x4
    80001f46:	d9a080e7          	jalr	-614(ra) # 80005cdc <panic>
    printf("scause %p\n", scause);
    80001f4a:	85ce                	mv	a1,s3
    80001f4c:	00006517          	auipc	a0,0x6
    80001f50:	40c50513          	addi	a0,a0,1036 # 80008358 <states.0+0x110>
    80001f54:	00004097          	auipc	ra,0x4
    80001f58:	dd2080e7          	jalr	-558(ra) # 80005d26 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f5c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f60:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001f64:	00006517          	auipc	a0,0x6
    80001f68:	40450513          	addi	a0,a0,1028 # 80008368 <states.0+0x120>
    80001f6c:	00004097          	auipc	ra,0x4
    80001f70:	dba080e7          	jalr	-582(ra) # 80005d26 <printf>
    panic("kerneltrap");
    80001f74:	00006517          	auipc	a0,0x6
    80001f78:	40c50513          	addi	a0,a0,1036 # 80008380 <states.0+0x138>
    80001f7c:	00004097          	auipc	ra,0x4
    80001f80:	d60080e7          	jalr	-672(ra) # 80005cdc <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001f84:	fffff097          	auipc	ra,0xfffff
    80001f88:	f26080e7          	jalr	-218(ra) # 80000eaa <myproc>
    80001f8c:	d541                	beqz	a0,80001f14 <kerneltrap+0x38>
    80001f8e:	fffff097          	auipc	ra,0xfffff
    80001f92:	f1c080e7          	jalr	-228(ra) # 80000eaa <myproc>
    80001f96:	4d18                	lw	a4,24(a0)
    80001f98:	4791                	li	a5,4
    80001f9a:	f6f71de3          	bne	a4,a5,80001f14 <kerneltrap+0x38>
    yield();
    80001f9e:	fffff097          	auipc	ra,0xfffff
    80001fa2:	578080e7          	jalr	1400(ra) # 80001516 <yield>
    80001fa6:	b7bd                	j	80001f14 <kerneltrap+0x38>

0000000080001fa8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001fa8:	1101                	addi	sp,sp,-32
    80001faa:	ec06                	sd	ra,24(sp)
    80001fac:	e822                	sd	s0,16(sp)
    80001fae:	e426                	sd	s1,8(sp)
    80001fb0:	1000                	addi	s0,sp,32
    80001fb2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	ef6080e7          	jalr	-266(ra) # 80000eaa <myproc>
  switch (n) {
    80001fbc:	4795                	li	a5,5
    80001fbe:	0497e163          	bltu	a5,s1,80002000 <argraw+0x58>
    80001fc2:	048a                	slli	s1,s1,0x2
    80001fc4:	00006717          	auipc	a4,0x6
    80001fc8:	3f470713          	addi	a4,a4,1012 # 800083b8 <states.0+0x170>
    80001fcc:	94ba                	add	s1,s1,a4
    80001fce:	409c                	lw	a5,0(s1)
    80001fd0:	97ba                	add	a5,a5,a4
    80001fd2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001fd4:	6d3c                	ld	a5,88(a0)
    80001fd6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001fd8:	60e2                	ld	ra,24(sp)
    80001fda:	6442                	ld	s0,16(sp)
    80001fdc:	64a2                	ld	s1,8(sp)
    80001fde:	6105                	addi	sp,sp,32
    80001fe0:	8082                	ret
    return p->trapframe->a1;
    80001fe2:	6d3c                	ld	a5,88(a0)
    80001fe4:	7fa8                	ld	a0,120(a5)
    80001fe6:	bfcd                	j	80001fd8 <argraw+0x30>
    return p->trapframe->a2;
    80001fe8:	6d3c                	ld	a5,88(a0)
    80001fea:	63c8                	ld	a0,128(a5)
    80001fec:	b7f5                	j	80001fd8 <argraw+0x30>
    return p->trapframe->a3;
    80001fee:	6d3c                	ld	a5,88(a0)
    80001ff0:	67c8                	ld	a0,136(a5)
    80001ff2:	b7dd                	j	80001fd8 <argraw+0x30>
    return p->trapframe->a4;
    80001ff4:	6d3c                	ld	a5,88(a0)
    80001ff6:	6bc8                	ld	a0,144(a5)
    80001ff8:	b7c5                	j	80001fd8 <argraw+0x30>
    return p->trapframe->a5;
    80001ffa:	6d3c                	ld	a5,88(a0)
    80001ffc:	6fc8                	ld	a0,152(a5)
    80001ffe:	bfe9                	j	80001fd8 <argraw+0x30>
  panic("argraw");
    80002000:	00006517          	auipc	a0,0x6
    80002004:	39050513          	addi	a0,a0,912 # 80008390 <states.0+0x148>
    80002008:	00004097          	auipc	ra,0x4
    8000200c:	cd4080e7          	jalr	-812(ra) # 80005cdc <panic>

0000000080002010 <fetchaddr>:
{
    80002010:	1101                	addi	sp,sp,-32
    80002012:	ec06                	sd	ra,24(sp)
    80002014:	e822                	sd	s0,16(sp)
    80002016:	e426                	sd	s1,8(sp)
    80002018:	e04a                	sd	s2,0(sp)
    8000201a:	1000                	addi	s0,sp,32
    8000201c:	84aa                	mv	s1,a0
    8000201e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002020:	fffff097          	auipc	ra,0xfffff
    80002024:	e8a080e7          	jalr	-374(ra) # 80000eaa <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002028:	653c                	ld	a5,72(a0)
    8000202a:	02f4f863          	bgeu	s1,a5,8000205a <fetchaddr+0x4a>
    8000202e:	00848713          	addi	a4,s1,8
    80002032:	02e7e663          	bltu	a5,a4,8000205e <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002036:	46a1                	li	a3,8
    80002038:	8626                	mv	a2,s1
    8000203a:	85ca                	mv	a1,s2
    8000203c:	6928                	ld	a0,80(a0)
    8000203e:	fffff097          	auipc	ra,0xfffff
    80002042:	bb8080e7          	jalr	-1096(ra) # 80000bf6 <copyin>
    80002046:	00a03533          	snez	a0,a0
    8000204a:	40a00533          	neg	a0,a0
}
    8000204e:	60e2                	ld	ra,24(sp)
    80002050:	6442                	ld	s0,16(sp)
    80002052:	64a2                	ld	s1,8(sp)
    80002054:	6902                	ld	s2,0(sp)
    80002056:	6105                	addi	sp,sp,32
    80002058:	8082                	ret
    return -1;
    8000205a:	557d                	li	a0,-1
    8000205c:	bfcd                	j	8000204e <fetchaddr+0x3e>
    8000205e:	557d                	li	a0,-1
    80002060:	b7fd                	j	8000204e <fetchaddr+0x3e>

0000000080002062 <fetchstr>:
{
    80002062:	7179                	addi	sp,sp,-48
    80002064:	f406                	sd	ra,40(sp)
    80002066:	f022                	sd	s0,32(sp)
    80002068:	ec26                	sd	s1,24(sp)
    8000206a:	e84a                	sd	s2,16(sp)
    8000206c:	e44e                	sd	s3,8(sp)
    8000206e:	1800                	addi	s0,sp,48
    80002070:	892a                	mv	s2,a0
    80002072:	84ae                	mv	s1,a1
    80002074:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002076:	fffff097          	auipc	ra,0xfffff
    8000207a:	e34080e7          	jalr	-460(ra) # 80000eaa <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000207e:	86ce                	mv	a3,s3
    80002080:	864a                	mv	a2,s2
    80002082:	85a6                	mv	a1,s1
    80002084:	6928                	ld	a0,80(a0)
    80002086:	fffff097          	auipc	ra,0xfffff
    8000208a:	bfe080e7          	jalr	-1026(ra) # 80000c84 <copyinstr>
    8000208e:	00054e63          	bltz	a0,800020aa <fetchstr+0x48>
  return strlen(buf);
    80002092:	8526                	mv	a0,s1
    80002094:	ffffe097          	auipc	ra,0xffffe
    80002098:	262080e7          	jalr	610(ra) # 800002f6 <strlen>
}
    8000209c:	70a2                	ld	ra,40(sp)
    8000209e:	7402                	ld	s0,32(sp)
    800020a0:	64e2                	ld	s1,24(sp)
    800020a2:	6942                	ld	s2,16(sp)
    800020a4:	69a2                	ld	s3,8(sp)
    800020a6:	6145                	addi	sp,sp,48
    800020a8:	8082                	ret
    return -1;
    800020aa:	557d                	li	a0,-1
    800020ac:	bfc5                	j	8000209c <fetchstr+0x3a>

00000000800020ae <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    800020ae:	1101                	addi	sp,sp,-32
    800020b0:	ec06                	sd	ra,24(sp)
    800020b2:	e822                	sd	s0,16(sp)
    800020b4:	e426                	sd	s1,8(sp)
    800020b6:	1000                	addi	s0,sp,32
    800020b8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800020ba:	00000097          	auipc	ra,0x0
    800020be:	eee080e7          	jalr	-274(ra) # 80001fa8 <argraw>
    800020c2:	c088                	sw	a0,0(s1)
}
    800020c4:	60e2                	ld	ra,24(sp)
    800020c6:	6442                	ld	s0,16(sp)
    800020c8:	64a2                	ld	s1,8(sp)
    800020ca:	6105                	addi	sp,sp,32
    800020cc:	8082                	ret

00000000800020ce <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800020ce:	1101                	addi	sp,sp,-32
    800020d0:	ec06                	sd	ra,24(sp)
    800020d2:	e822                	sd	s0,16(sp)
    800020d4:	e426                	sd	s1,8(sp)
    800020d6:	1000                	addi	s0,sp,32
    800020d8:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800020da:	00000097          	auipc	ra,0x0
    800020de:	ece080e7          	jalr	-306(ra) # 80001fa8 <argraw>
    800020e2:	e088                	sd	a0,0(s1)
}
    800020e4:	60e2                	ld	ra,24(sp)
    800020e6:	6442                	ld	s0,16(sp)
    800020e8:	64a2                	ld	s1,8(sp)
    800020ea:	6105                	addi	sp,sp,32
    800020ec:	8082                	ret

00000000800020ee <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800020ee:	7179                	addi	sp,sp,-48
    800020f0:	f406                	sd	ra,40(sp)
    800020f2:	f022                	sd	s0,32(sp)
    800020f4:	ec26                	sd	s1,24(sp)
    800020f6:	e84a                	sd	s2,16(sp)
    800020f8:	1800                	addi	s0,sp,48
    800020fa:	84ae                	mv	s1,a1
    800020fc:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800020fe:	fd840593          	addi	a1,s0,-40
    80002102:	00000097          	auipc	ra,0x0
    80002106:	fcc080e7          	jalr	-52(ra) # 800020ce <argaddr>
  return fetchstr(addr, buf, max);
    8000210a:	864a                	mv	a2,s2
    8000210c:	85a6                	mv	a1,s1
    8000210e:	fd843503          	ld	a0,-40(s0)
    80002112:	00000097          	auipc	ra,0x0
    80002116:	f50080e7          	jalr	-176(ra) # 80002062 <fetchstr>
}
    8000211a:	70a2                	ld	ra,40(sp)
    8000211c:	7402                	ld	s0,32(sp)
    8000211e:	64e2                	ld	s1,24(sp)
    80002120:	6942                	ld	s2,16(sp)
    80002122:	6145                	addi	sp,sp,48
    80002124:	8082                	ret

0000000080002126 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002126:	1101                	addi	sp,sp,-32
    80002128:	ec06                	sd	ra,24(sp)
    8000212a:	e822                	sd	s0,16(sp)
    8000212c:	e426                	sd	s1,8(sp)
    8000212e:	e04a                	sd	s2,0(sp)
    80002130:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	d78080e7          	jalr	-648(ra) # 80000eaa <myproc>
    8000213a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000213c:	05853903          	ld	s2,88(a0)
    80002140:	0a893783          	ld	a5,168(s2)
    80002144:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002148:	37fd                	addiw	a5,a5,-1
    8000214a:	4751                	li	a4,20
    8000214c:	00f76f63          	bltu	a4,a5,8000216a <syscall+0x44>
    80002150:	00369713          	slli	a4,a3,0x3
    80002154:	00006797          	auipc	a5,0x6
    80002158:	27c78793          	addi	a5,a5,636 # 800083d0 <syscalls>
    8000215c:	97ba                	add	a5,a5,a4
    8000215e:	639c                	ld	a5,0(a5)
    80002160:	c789                	beqz	a5,8000216a <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002162:	9782                	jalr	a5
    80002164:	06a93823          	sd	a0,112(s2)
    80002168:	a839                	j	80002186 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000216a:	15848613          	addi	a2,s1,344
    8000216e:	588c                	lw	a1,48(s1)
    80002170:	00006517          	auipc	a0,0x6
    80002174:	22850513          	addi	a0,a0,552 # 80008398 <states.0+0x150>
    80002178:	00004097          	auipc	ra,0x4
    8000217c:	bae080e7          	jalr	-1106(ra) # 80005d26 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002180:	6cbc                	ld	a5,88(s1)
    80002182:	577d                	li	a4,-1
    80002184:	fbb8                	sd	a4,112(a5)
  }
}
    80002186:	60e2                	ld	ra,24(sp)
    80002188:	6442                	ld	s0,16(sp)
    8000218a:	64a2                	ld	s1,8(sp)
    8000218c:	6902                	ld	s2,0(sp)
    8000218e:	6105                	addi	sp,sp,32
    80002190:	8082                	ret

0000000080002192 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002192:	1101                	addi	sp,sp,-32
    80002194:	ec06                	sd	ra,24(sp)
    80002196:	e822                	sd	s0,16(sp)
    80002198:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000219a:	fec40593          	addi	a1,s0,-20
    8000219e:	4501                	li	a0,0
    800021a0:	00000097          	auipc	ra,0x0
    800021a4:	f0e080e7          	jalr	-242(ra) # 800020ae <argint>
  exit(n);
    800021a8:	fec42503          	lw	a0,-20(s0)
    800021ac:	fffff097          	auipc	ra,0xfffff
    800021b0:	4da080e7          	jalr	1242(ra) # 80001686 <exit>
  return 0;  // not reached
}
    800021b4:	4501                	li	a0,0
    800021b6:	60e2                	ld	ra,24(sp)
    800021b8:	6442                	ld	s0,16(sp)
    800021ba:	6105                	addi	sp,sp,32
    800021bc:	8082                	ret

00000000800021be <sys_getpid>:

uint64
sys_getpid(void)
{
    800021be:	1141                	addi	sp,sp,-16
    800021c0:	e406                	sd	ra,8(sp)
    800021c2:	e022                	sd	s0,0(sp)
    800021c4:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	ce4080e7          	jalr	-796(ra) # 80000eaa <myproc>
}
    800021ce:	5908                	lw	a0,48(a0)
    800021d0:	60a2                	ld	ra,8(sp)
    800021d2:	6402                	ld	s0,0(sp)
    800021d4:	0141                	addi	sp,sp,16
    800021d6:	8082                	ret

00000000800021d8 <sys_fork>:

uint64
sys_fork(void)
{
    800021d8:	1141                	addi	sp,sp,-16
    800021da:	e406                	sd	ra,8(sp)
    800021dc:	e022                	sd	s0,0(sp)
    800021de:	0800                	addi	s0,sp,16
  return fork();
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	080080e7          	jalr	128(ra) # 80001260 <fork>
}
    800021e8:	60a2                	ld	ra,8(sp)
    800021ea:	6402                	ld	s0,0(sp)
    800021ec:	0141                	addi	sp,sp,16
    800021ee:	8082                	ret

00000000800021f0 <sys_wait>:

uint64
sys_wait(void)
{
    800021f0:	1101                	addi	sp,sp,-32
    800021f2:	ec06                	sd	ra,24(sp)
    800021f4:	e822                	sd	s0,16(sp)
    800021f6:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800021f8:	fe840593          	addi	a1,s0,-24
    800021fc:	4501                	li	a0,0
    800021fe:	00000097          	auipc	ra,0x0
    80002202:	ed0080e7          	jalr	-304(ra) # 800020ce <argaddr>
  return wait(p);
    80002206:	fe843503          	ld	a0,-24(s0)
    8000220a:	fffff097          	auipc	ra,0xfffff
    8000220e:	622080e7          	jalr	1570(ra) # 8000182c <wait>
}
    80002212:	60e2                	ld	ra,24(sp)
    80002214:	6442                	ld	s0,16(sp)
    80002216:	6105                	addi	sp,sp,32
    80002218:	8082                	ret

000000008000221a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000221a:	7179                	addi	sp,sp,-48
    8000221c:	f406                	sd	ra,40(sp)
    8000221e:	f022                	sd	s0,32(sp)
    80002220:	ec26                	sd	s1,24(sp)
    80002222:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002224:	fdc40593          	addi	a1,s0,-36
    80002228:	4501                	li	a0,0
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	e84080e7          	jalr	-380(ra) # 800020ae <argint>
  addr = myproc()->sz;
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	c78080e7          	jalr	-904(ra) # 80000eaa <myproc>
    8000223a:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000223c:	fdc42503          	lw	a0,-36(s0)
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	fc4080e7          	jalr	-60(ra) # 80001204 <growproc>
    80002248:	00054863          	bltz	a0,80002258 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000224c:	8526                	mv	a0,s1
    8000224e:	70a2                	ld	ra,40(sp)
    80002250:	7402                	ld	s0,32(sp)
    80002252:	64e2                	ld	s1,24(sp)
    80002254:	6145                	addi	sp,sp,48
    80002256:	8082                	ret
    return -1;
    80002258:	54fd                	li	s1,-1
    8000225a:	bfcd                	j	8000224c <sys_sbrk+0x32>

000000008000225c <sys_sleep>:

uint64
sys_sleep(void)
{
    8000225c:	7139                	addi	sp,sp,-64
    8000225e:	fc06                	sd	ra,56(sp)
    80002260:	f822                	sd	s0,48(sp)
    80002262:	f426                	sd	s1,40(sp)
    80002264:	f04a                	sd	s2,32(sp)
    80002266:	ec4e                	sd	s3,24(sp)
    80002268:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000226a:	fcc40593          	addi	a1,s0,-52
    8000226e:	4501                	li	a0,0
    80002270:	00000097          	auipc	ra,0x0
    80002274:	e3e080e7          	jalr	-450(ra) # 800020ae <argint>
  if(n < 0)
    80002278:	fcc42783          	lw	a5,-52(s0)
    8000227c:	0607cf63          	bltz	a5,800022fa <sys_sleep+0x9e>
    n = 0;
  acquire(&tickslock);
    80002280:	0000c517          	auipc	a0,0xc
    80002284:	4b050513          	addi	a0,a0,1200 # 8000e730 <tickslock>
    80002288:	00004097          	auipc	ra,0x4
    8000228c:	f8c080e7          	jalr	-116(ra) # 80006214 <acquire>
  ticks0 = ticks;
    80002290:	00006917          	auipc	s2,0x6
    80002294:	63892903          	lw	s2,1592(s2) # 800088c8 <ticks>
  while(ticks - ticks0 < n){
    80002298:	fcc42783          	lw	a5,-52(s0)
    8000229c:	cf9d                	beqz	a5,800022da <sys_sleep+0x7e>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    8000229e:	0000c997          	auipc	s3,0xc
    800022a2:	49298993          	addi	s3,s3,1170 # 8000e730 <tickslock>
    800022a6:	00006497          	auipc	s1,0x6
    800022aa:	62248493          	addi	s1,s1,1570 # 800088c8 <ticks>
    if(killed(myproc())){
    800022ae:	fffff097          	auipc	ra,0xfffff
    800022b2:	bfc080e7          	jalr	-1028(ra) # 80000eaa <myproc>
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	544080e7          	jalr	1348(ra) # 800017fa <killed>
    800022be:	e129                	bnez	a0,80002300 <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    800022c0:	85ce                	mv	a1,s3
    800022c2:	8526                	mv	a0,s1
    800022c4:	fffff097          	auipc	ra,0xfffff
    800022c8:	28e080e7          	jalr	654(ra) # 80001552 <sleep>
  while(ticks - ticks0 < n){
    800022cc:	409c                	lw	a5,0(s1)
    800022ce:	412787bb          	subw	a5,a5,s2
    800022d2:	fcc42703          	lw	a4,-52(s0)
    800022d6:	fce7ece3          	bltu	a5,a4,800022ae <sys_sleep+0x52>
  }
  release(&tickslock);
    800022da:	0000c517          	auipc	a0,0xc
    800022de:	45650513          	addi	a0,a0,1110 # 8000e730 <tickslock>
    800022e2:	00004097          	auipc	ra,0x4
    800022e6:	fe6080e7          	jalr	-26(ra) # 800062c8 <release>
  return 0;
    800022ea:	4501                	li	a0,0
}
    800022ec:	70e2                	ld	ra,56(sp)
    800022ee:	7442                	ld	s0,48(sp)
    800022f0:	74a2                	ld	s1,40(sp)
    800022f2:	7902                	ld	s2,32(sp)
    800022f4:	69e2                	ld	s3,24(sp)
    800022f6:	6121                	addi	sp,sp,64
    800022f8:	8082                	ret
    n = 0;
    800022fa:	fc042623          	sw	zero,-52(s0)
    800022fe:	b749                	j	80002280 <sys_sleep+0x24>
      release(&tickslock);
    80002300:	0000c517          	auipc	a0,0xc
    80002304:	43050513          	addi	a0,a0,1072 # 8000e730 <tickslock>
    80002308:	00004097          	auipc	ra,0x4
    8000230c:	fc0080e7          	jalr	-64(ra) # 800062c8 <release>
      return -1;
    80002310:	557d                	li	a0,-1
    80002312:	bfe9                	j	800022ec <sys_sleep+0x90>

0000000080002314 <sys_kill>:

uint64
sys_kill(void)
{
    80002314:	1101                	addi	sp,sp,-32
    80002316:	ec06                	sd	ra,24(sp)
    80002318:	e822                	sd	s0,16(sp)
    8000231a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000231c:	fec40593          	addi	a1,s0,-20
    80002320:	4501                	li	a0,0
    80002322:	00000097          	auipc	ra,0x0
    80002326:	d8c080e7          	jalr	-628(ra) # 800020ae <argint>
  return kill(pid);
    8000232a:	fec42503          	lw	a0,-20(s0)
    8000232e:	fffff097          	auipc	ra,0xfffff
    80002332:	42e080e7          	jalr	1070(ra) # 8000175c <kill>
}
    80002336:	60e2                	ld	ra,24(sp)
    80002338:	6442                	ld	s0,16(sp)
    8000233a:	6105                	addi	sp,sp,32
    8000233c:	8082                	ret

000000008000233e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000233e:	1101                	addi	sp,sp,-32
    80002340:	ec06                	sd	ra,24(sp)
    80002342:	e822                	sd	s0,16(sp)
    80002344:	e426                	sd	s1,8(sp)
    80002346:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002348:	0000c517          	auipc	a0,0xc
    8000234c:	3e850513          	addi	a0,a0,1000 # 8000e730 <tickslock>
    80002350:	00004097          	auipc	ra,0x4
    80002354:	ec4080e7          	jalr	-316(ra) # 80006214 <acquire>
  xticks = ticks;
    80002358:	00006497          	auipc	s1,0x6
    8000235c:	5704a483          	lw	s1,1392(s1) # 800088c8 <ticks>
  release(&tickslock);
    80002360:	0000c517          	auipc	a0,0xc
    80002364:	3d050513          	addi	a0,a0,976 # 8000e730 <tickslock>
    80002368:	00004097          	auipc	ra,0x4
    8000236c:	f60080e7          	jalr	-160(ra) # 800062c8 <release>
  return xticks;
}
    80002370:	02049513          	slli	a0,s1,0x20
    80002374:	9101                	srli	a0,a0,0x20
    80002376:	60e2                	ld	ra,24(sp)
    80002378:	6442                	ld	s0,16(sp)
    8000237a:	64a2                	ld	s1,8(sp)
    8000237c:	6105                	addi	sp,sp,32
    8000237e:	8082                	ret

0000000080002380 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002380:	7179                	addi	sp,sp,-48
    80002382:	f406                	sd	ra,40(sp)
    80002384:	f022                	sd	s0,32(sp)
    80002386:	ec26                	sd	s1,24(sp)
    80002388:	e84a                	sd	s2,16(sp)
    8000238a:	e44e                	sd	s3,8(sp)
    8000238c:	e052                	sd	s4,0(sp)
    8000238e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002390:	00006597          	auipc	a1,0x6
    80002394:	0f058593          	addi	a1,a1,240 # 80008480 <syscalls+0xb0>
    80002398:	0000c517          	auipc	a0,0xc
    8000239c:	3b050513          	addi	a0,a0,944 # 8000e748 <bcache>
    800023a0:	00004097          	auipc	ra,0x4
    800023a4:	de4080e7          	jalr	-540(ra) # 80006184 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800023a8:	00014797          	auipc	a5,0x14
    800023ac:	3a078793          	addi	a5,a5,928 # 80016748 <bcache+0x8000>
    800023b0:	00014717          	auipc	a4,0x14
    800023b4:	60070713          	addi	a4,a4,1536 # 800169b0 <bcache+0x8268>
    800023b8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800023bc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800023c0:	0000c497          	auipc	s1,0xc
    800023c4:	3a048493          	addi	s1,s1,928 # 8000e760 <bcache+0x18>
    b->next = bcache.head.next;
    800023c8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800023ca:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800023cc:	00006a17          	auipc	s4,0x6
    800023d0:	0bca0a13          	addi	s4,s4,188 # 80008488 <syscalls+0xb8>
    b->next = bcache.head.next;
    800023d4:	2b893783          	ld	a5,696(s2)
    800023d8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800023da:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800023de:	85d2                	mv	a1,s4
    800023e0:	01048513          	addi	a0,s1,16
    800023e4:	00001097          	auipc	ra,0x1
    800023e8:	4c8080e7          	jalr	1224(ra) # 800038ac <initsleeplock>
    bcache.head.next->prev = b;
    800023ec:	2b893783          	ld	a5,696(s2)
    800023f0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800023f2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800023f6:	45848493          	addi	s1,s1,1112
    800023fa:	fd349de3          	bne	s1,s3,800023d4 <binit+0x54>
  }
}
    800023fe:	70a2                	ld	ra,40(sp)
    80002400:	7402                	ld	s0,32(sp)
    80002402:	64e2                	ld	s1,24(sp)
    80002404:	6942                	ld	s2,16(sp)
    80002406:	69a2                	ld	s3,8(sp)
    80002408:	6a02                	ld	s4,0(sp)
    8000240a:	6145                	addi	sp,sp,48
    8000240c:	8082                	ret

000000008000240e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000240e:	7179                	addi	sp,sp,-48
    80002410:	f406                	sd	ra,40(sp)
    80002412:	f022                	sd	s0,32(sp)
    80002414:	ec26                	sd	s1,24(sp)
    80002416:	e84a                	sd	s2,16(sp)
    80002418:	e44e                	sd	s3,8(sp)
    8000241a:	1800                	addi	s0,sp,48
    8000241c:	892a                	mv	s2,a0
    8000241e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002420:	0000c517          	auipc	a0,0xc
    80002424:	32850513          	addi	a0,a0,808 # 8000e748 <bcache>
    80002428:	00004097          	auipc	ra,0x4
    8000242c:	dec080e7          	jalr	-532(ra) # 80006214 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002430:	00014497          	auipc	s1,0x14
    80002434:	5d04b483          	ld	s1,1488(s1) # 80016a00 <bcache+0x82b8>
    80002438:	00014797          	auipc	a5,0x14
    8000243c:	57878793          	addi	a5,a5,1400 # 800169b0 <bcache+0x8268>
    80002440:	02f48f63          	beq	s1,a5,8000247e <bread+0x70>
    80002444:	873e                	mv	a4,a5
    80002446:	a021                	j	8000244e <bread+0x40>
    80002448:	68a4                	ld	s1,80(s1)
    8000244a:	02e48a63          	beq	s1,a4,8000247e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000244e:	449c                	lw	a5,8(s1)
    80002450:	ff279ce3          	bne	a5,s2,80002448 <bread+0x3a>
    80002454:	44dc                	lw	a5,12(s1)
    80002456:	ff3799e3          	bne	a5,s3,80002448 <bread+0x3a>
      b->refcnt++;
    8000245a:	40bc                	lw	a5,64(s1)
    8000245c:	2785                	addiw	a5,a5,1
    8000245e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002460:	0000c517          	auipc	a0,0xc
    80002464:	2e850513          	addi	a0,a0,744 # 8000e748 <bcache>
    80002468:	00004097          	auipc	ra,0x4
    8000246c:	e60080e7          	jalr	-416(ra) # 800062c8 <release>
      acquiresleep(&b->lock);
    80002470:	01048513          	addi	a0,s1,16
    80002474:	00001097          	auipc	ra,0x1
    80002478:	472080e7          	jalr	1138(ra) # 800038e6 <acquiresleep>
      return b;
    8000247c:	a8b9                	j	800024da <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000247e:	00014497          	auipc	s1,0x14
    80002482:	57a4b483          	ld	s1,1402(s1) # 800169f8 <bcache+0x82b0>
    80002486:	00014797          	auipc	a5,0x14
    8000248a:	52a78793          	addi	a5,a5,1322 # 800169b0 <bcache+0x8268>
    8000248e:	00f48863          	beq	s1,a5,8000249e <bread+0x90>
    80002492:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002494:	40bc                	lw	a5,64(s1)
    80002496:	cf81                	beqz	a5,800024ae <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002498:	64a4                	ld	s1,72(s1)
    8000249a:	fee49de3          	bne	s1,a4,80002494 <bread+0x86>
  panic("bget: no buffers");
    8000249e:	00006517          	auipc	a0,0x6
    800024a2:	ff250513          	addi	a0,a0,-14 # 80008490 <syscalls+0xc0>
    800024a6:	00004097          	auipc	ra,0x4
    800024aa:	836080e7          	jalr	-1994(ra) # 80005cdc <panic>
      b->dev = dev;
    800024ae:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800024b2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800024b6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800024ba:	4785                	li	a5,1
    800024bc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800024be:	0000c517          	auipc	a0,0xc
    800024c2:	28a50513          	addi	a0,a0,650 # 8000e748 <bcache>
    800024c6:	00004097          	auipc	ra,0x4
    800024ca:	e02080e7          	jalr	-510(ra) # 800062c8 <release>
      acquiresleep(&b->lock);
    800024ce:	01048513          	addi	a0,s1,16
    800024d2:	00001097          	auipc	ra,0x1
    800024d6:	414080e7          	jalr	1044(ra) # 800038e6 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800024da:	409c                	lw	a5,0(s1)
    800024dc:	cb89                	beqz	a5,800024ee <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800024de:	8526                	mv	a0,s1
    800024e0:	70a2                	ld	ra,40(sp)
    800024e2:	7402                	ld	s0,32(sp)
    800024e4:	64e2                	ld	s1,24(sp)
    800024e6:	6942                	ld	s2,16(sp)
    800024e8:	69a2                	ld	s3,8(sp)
    800024ea:	6145                	addi	sp,sp,48
    800024ec:	8082                	ret
    virtio_disk_rw(b, 0);
    800024ee:	4581                	li	a1,0
    800024f0:	8526                	mv	a0,s1
    800024f2:	00003097          	auipc	ra,0x3
    800024f6:	fe0080e7          	jalr	-32(ra) # 800054d2 <virtio_disk_rw>
    b->valid = 1;
    800024fa:	4785                	li	a5,1
    800024fc:	c09c                	sw	a5,0(s1)
  return b;
    800024fe:	b7c5                	j	800024de <bread+0xd0>

0000000080002500 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002500:	1101                	addi	sp,sp,-32
    80002502:	ec06                	sd	ra,24(sp)
    80002504:	e822                	sd	s0,16(sp)
    80002506:	e426                	sd	s1,8(sp)
    80002508:	1000                	addi	s0,sp,32
    8000250a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000250c:	0541                	addi	a0,a0,16
    8000250e:	00001097          	auipc	ra,0x1
    80002512:	472080e7          	jalr	1138(ra) # 80003980 <holdingsleep>
    80002516:	cd01                	beqz	a0,8000252e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002518:	4585                	li	a1,1
    8000251a:	8526                	mv	a0,s1
    8000251c:	00003097          	auipc	ra,0x3
    80002520:	fb6080e7          	jalr	-74(ra) # 800054d2 <virtio_disk_rw>
}
    80002524:	60e2                	ld	ra,24(sp)
    80002526:	6442                	ld	s0,16(sp)
    80002528:	64a2                	ld	s1,8(sp)
    8000252a:	6105                	addi	sp,sp,32
    8000252c:	8082                	ret
    panic("bwrite");
    8000252e:	00006517          	auipc	a0,0x6
    80002532:	f7a50513          	addi	a0,a0,-134 # 800084a8 <syscalls+0xd8>
    80002536:	00003097          	auipc	ra,0x3
    8000253a:	7a6080e7          	jalr	1958(ra) # 80005cdc <panic>

000000008000253e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000253e:	1101                	addi	sp,sp,-32
    80002540:	ec06                	sd	ra,24(sp)
    80002542:	e822                	sd	s0,16(sp)
    80002544:	e426                	sd	s1,8(sp)
    80002546:	e04a                	sd	s2,0(sp)
    80002548:	1000                	addi	s0,sp,32
    8000254a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000254c:	01050913          	addi	s2,a0,16
    80002550:	854a                	mv	a0,s2
    80002552:	00001097          	auipc	ra,0x1
    80002556:	42e080e7          	jalr	1070(ra) # 80003980 <holdingsleep>
    8000255a:	c92d                	beqz	a0,800025cc <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000255c:	854a                	mv	a0,s2
    8000255e:	00001097          	auipc	ra,0x1
    80002562:	3de080e7          	jalr	990(ra) # 8000393c <releasesleep>

  acquire(&bcache.lock);
    80002566:	0000c517          	auipc	a0,0xc
    8000256a:	1e250513          	addi	a0,a0,482 # 8000e748 <bcache>
    8000256e:	00004097          	auipc	ra,0x4
    80002572:	ca6080e7          	jalr	-858(ra) # 80006214 <acquire>
  b->refcnt--;
    80002576:	40bc                	lw	a5,64(s1)
    80002578:	37fd                	addiw	a5,a5,-1
    8000257a:	0007871b          	sext.w	a4,a5
    8000257e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002580:	eb05                	bnez	a4,800025b0 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002582:	68bc                	ld	a5,80(s1)
    80002584:	64b8                	ld	a4,72(s1)
    80002586:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002588:	64bc                	ld	a5,72(s1)
    8000258a:	68b8                	ld	a4,80(s1)
    8000258c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000258e:	00014797          	auipc	a5,0x14
    80002592:	1ba78793          	addi	a5,a5,442 # 80016748 <bcache+0x8000>
    80002596:	2b87b703          	ld	a4,696(a5)
    8000259a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000259c:	00014717          	auipc	a4,0x14
    800025a0:	41470713          	addi	a4,a4,1044 # 800169b0 <bcache+0x8268>
    800025a4:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800025a6:	2b87b703          	ld	a4,696(a5)
    800025aa:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800025ac:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800025b0:	0000c517          	auipc	a0,0xc
    800025b4:	19850513          	addi	a0,a0,408 # 8000e748 <bcache>
    800025b8:	00004097          	auipc	ra,0x4
    800025bc:	d10080e7          	jalr	-752(ra) # 800062c8 <release>
}
    800025c0:	60e2                	ld	ra,24(sp)
    800025c2:	6442                	ld	s0,16(sp)
    800025c4:	64a2                	ld	s1,8(sp)
    800025c6:	6902                	ld	s2,0(sp)
    800025c8:	6105                	addi	sp,sp,32
    800025ca:	8082                	ret
    panic("brelse");
    800025cc:	00006517          	auipc	a0,0x6
    800025d0:	ee450513          	addi	a0,a0,-284 # 800084b0 <syscalls+0xe0>
    800025d4:	00003097          	auipc	ra,0x3
    800025d8:	708080e7          	jalr	1800(ra) # 80005cdc <panic>

00000000800025dc <bpin>:

void
bpin(struct buf *b) {
    800025dc:	1101                	addi	sp,sp,-32
    800025de:	ec06                	sd	ra,24(sp)
    800025e0:	e822                	sd	s0,16(sp)
    800025e2:	e426                	sd	s1,8(sp)
    800025e4:	1000                	addi	s0,sp,32
    800025e6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800025e8:	0000c517          	auipc	a0,0xc
    800025ec:	16050513          	addi	a0,a0,352 # 8000e748 <bcache>
    800025f0:	00004097          	auipc	ra,0x4
    800025f4:	c24080e7          	jalr	-988(ra) # 80006214 <acquire>
  b->refcnt++;
    800025f8:	40bc                	lw	a5,64(s1)
    800025fa:	2785                	addiw	a5,a5,1
    800025fc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800025fe:	0000c517          	auipc	a0,0xc
    80002602:	14a50513          	addi	a0,a0,330 # 8000e748 <bcache>
    80002606:	00004097          	auipc	ra,0x4
    8000260a:	cc2080e7          	jalr	-830(ra) # 800062c8 <release>
}
    8000260e:	60e2                	ld	ra,24(sp)
    80002610:	6442                	ld	s0,16(sp)
    80002612:	64a2                	ld	s1,8(sp)
    80002614:	6105                	addi	sp,sp,32
    80002616:	8082                	ret

0000000080002618 <bunpin>:

void
bunpin(struct buf *b) {
    80002618:	1101                	addi	sp,sp,-32
    8000261a:	ec06                	sd	ra,24(sp)
    8000261c:	e822                	sd	s0,16(sp)
    8000261e:	e426                	sd	s1,8(sp)
    80002620:	1000                	addi	s0,sp,32
    80002622:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002624:	0000c517          	auipc	a0,0xc
    80002628:	12450513          	addi	a0,a0,292 # 8000e748 <bcache>
    8000262c:	00004097          	auipc	ra,0x4
    80002630:	be8080e7          	jalr	-1048(ra) # 80006214 <acquire>
  b->refcnt--;
    80002634:	40bc                	lw	a5,64(s1)
    80002636:	37fd                	addiw	a5,a5,-1
    80002638:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000263a:	0000c517          	auipc	a0,0xc
    8000263e:	10e50513          	addi	a0,a0,270 # 8000e748 <bcache>
    80002642:	00004097          	auipc	ra,0x4
    80002646:	c86080e7          	jalr	-890(ra) # 800062c8 <release>
}
    8000264a:	60e2                	ld	ra,24(sp)
    8000264c:	6442                	ld	s0,16(sp)
    8000264e:	64a2                	ld	s1,8(sp)
    80002650:	6105                	addi	sp,sp,32
    80002652:	8082                	ret

0000000080002654 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002654:	1101                	addi	sp,sp,-32
    80002656:	ec06                	sd	ra,24(sp)
    80002658:	e822                	sd	s0,16(sp)
    8000265a:	e426                	sd	s1,8(sp)
    8000265c:	e04a                	sd	s2,0(sp)
    8000265e:	1000                	addi	s0,sp,32
    80002660:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002662:	00d5d59b          	srliw	a1,a1,0xd
    80002666:	00014797          	auipc	a5,0x14
    8000266a:	7be7a783          	lw	a5,1982(a5) # 80016e24 <sb+0x1c>
    8000266e:	9dbd                	addw	a1,a1,a5
    80002670:	00000097          	auipc	ra,0x0
    80002674:	d9e080e7          	jalr	-610(ra) # 8000240e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002678:	0074f713          	andi	a4,s1,7
    8000267c:	4785                	li	a5,1
    8000267e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002682:	14ce                	slli	s1,s1,0x33
    80002684:	90d9                	srli	s1,s1,0x36
    80002686:	00950733          	add	a4,a0,s1
    8000268a:	05874703          	lbu	a4,88(a4)
    8000268e:	00e7f6b3          	and	a3,a5,a4
    80002692:	c69d                	beqz	a3,800026c0 <bfree+0x6c>
    80002694:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002696:	94aa                	add	s1,s1,a0
    80002698:	fff7c793          	not	a5,a5
    8000269c:	8f7d                	and	a4,a4,a5
    8000269e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800026a2:	00001097          	auipc	ra,0x1
    800026a6:	126080e7          	jalr	294(ra) # 800037c8 <log_write>
  brelse(bp);
    800026aa:	854a                	mv	a0,s2
    800026ac:	00000097          	auipc	ra,0x0
    800026b0:	e92080e7          	jalr	-366(ra) # 8000253e <brelse>
}
    800026b4:	60e2                	ld	ra,24(sp)
    800026b6:	6442                	ld	s0,16(sp)
    800026b8:	64a2                	ld	s1,8(sp)
    800026ba:	6902                	ld	s2,0(sp)
    800026bc:	6105                	addi	sp,sp,32
    800026be:	8082                	ret
    panic("freeing free block");
    800026c0:	00006517          	auipc	a0,0x6
    800026c4:	df850513          	addi	a0,a0,-520 # 800084b8 <syscalls+0xe8>
    800026c8:	00003097          	auipc	ra,0x3
    800026cc:	614080e7          	jalr	1556(ra) # 80005cdc <panic>

00000000800026d0 <balloc>:
{
    800026d0:	711d                	addi	sp,sp,-96
    800026d2:	ec86                	sd	ra,88(sp)
    800026d4:	e8a2                	sd	s0,80(sp)
    800026d6:	e4a6                	sd	s1,72(sp)
    800026d8:	e0ca                	sd	s2,64(sp)
    800026da:	fc4e                	sd	s3,56(sp)
    800026dc:	f852                	sd	s4,48(sp)
    800026de:	f456                	sd	s5,40(sp)
    800026e0:	f05a                	sd	s6,32(sp)
    800026e2:	ec5e                	sd	s7,24(sp)
    800026e4:	e862                	sd	s8,16(sp)
    800026e6:	e466                	sd	s9,8(sp)
    800026e8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800026ea:	00014797          	auipc	a5,0x14
    800026ee:	7227a783          	lw	a5,1826(a5) # 80016e0c <sb+0x4>
    800026f2:	cff5                	beqz	a5,800027ee <balloc+0x11e>
    800026f4:	8baa                	mv	s7,a0
    800026f6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800026f8:	00014b17          	auipc	s6,0x14
    800026fc:	710b0b13          	addi	s6,s6,1808 # 80016e08 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002700:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002702:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002704:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002706:	6c89                	lui	s9,0x2
    80002708:	a061                	j	80002790 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000270a:	97ca                	add	a5,a5,s2
    8000270c:	8e55                	or	a2,a2,a3
    8000270e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002712:	854a                	mv	a0,s2
    80002714:	00001097          	auipc	ra,0x1
    80002718:	0b4080e7          	jalr	180(ra) # 800037c8 <log_write>
        brelse(bp);
    8000271c:	854a                	mv	a0,s2
    8000271e:	00000097          	auipc	ra,0x0
    80002722:	e20080e7          	jalr	-480(ra) # 8000253e <brelse>
  bp = bread(dev, bno);
    80002726:	85a6                	mv	a1,s1
    80002728:	855e                	mv	a0,s7
    8000272a:	00000097          	auipc	ra,0x0
    8000272e:	ce4080e7          	jalr	-796(ra) # 8000240e <bread>
    80002732:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002734:	40000613          	li	a2,1024
    80002738:	4581                	li	a1,0
    8000273a:	05850513          	addi	a0,a0,88
    8000273e:	ffffe097          	auipc	ra,0xffffe
    80002742:	a3c080e7          	jalr	-1476(ra) # 8000017a <memset>
  log_write(bp);
    80002746:	854a                	mv	a0,s2
    80002748:	00001097          	auipc	ra,0x1
    8000274c:	080080e7          	jalr	128(ra) # 800037c8 <log_write>
  brelse(bp);
    80002750:	854a                	mv	a0,s2
    80002752:	00000097          	auipc	ra,0x0
    80002756:	dec080e7          	jalr	-532(ra) # 8000253e <brelse>
}
    8000275a:	8526                	mv	a0,s1
    8000275c:	60e6                	ld	ra,88(sp)
    8000275e:	6446                	ld	s0,80(sp)
    80002760:	64a6                	ld	s1,72(sp)
    80002762:	6906                	ld	s2,64(sp)
    80002764:	79e2                	ld	s3,56(sp)
    80002766:	7a42                	ld	s4,48(sp)
    80002768:	7aa2                	ld	s5,40(sp)
    8000276a:	7b02                	ld	s6,32(sp)
    8000276c:	6be2                	ld	s7,24(sp)
    8000276e:	6c42                	ld	s8,16(sp)
    80002770:	6ca2                	ld	s9,8(sp)
    80002772:	6125                	addi	sp,sp,96
    80002774:	8082                	ret
    brelse(bp);
    80002776:	854a                	mv	a0,s2
    80002778:	00000097          	auipc	ra,0x0
    8000277c:	dc6080e7          	jalr	-570(ra) # 8000253e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002780:	015c87bb          	addw	a5,s9,s5
    80002784:	00078a9b          	sext.w	s5,a5
    80002788:	004b2703          	lw	a4,4(s6)
    8000278c:	06eaf163          	bgeu	s5,a4,800027ee <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80002790:	41fad79b          	sraiw	a5,s5,0x1f
    80002794:	0137d79b          	srliw	a5,a5,0x13
    80002798:	015787bb          	addw	a5,a5,s5
    8000279c:	40d7d79b          	sraiw	a5,a5,0xd
    800027a0:	01cb2583          	lw	a1,28(s6)
    800027a4:	9dbd                	addw	a1,a1,a5
    800027a6:	855e                	mv	a0,s7
    800027a8:	00000097          	auipc	ra,0x0
    800027ac:	c66080e7          	jalr	-922(ra) # 8000240e <bread>
    800027b0:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027b2:	004b2503          	lw	a0,4(s6)
    800027b6:	000a849b          	sext.w	s1,s5
    800027ba:	8762                	mv	a4,s8
    800027bc:	faa4fde3          	bgeu	s1,a0,80002776 <balloc+0xa6>
      m = 1 << (bi % 8);
    800027c0:	00777693          	andi	a3,a4,7
    800027c4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800027c8:	41f7579b          	sraiw	a5,a4,0x1f
    800027cc:	01d7d79b          	srliw	a5,a5,0x1d
    800027d0:	9fb9                	addw	a5,a5,a4
    800027d2:	4037d79b          	sraiw	a5,a5,0x3
    800027d6:	00f90633          	add	a2,s2,a5
    800027da:	05864603          	lbu	a2,88(a2)
    800027de:	00c6f5b3          	and	a1,a3,a2
    800027e2:	d585                	beqz	a1,8000270a <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027e4:	2705                	addiw	a4,a4,1
    800027e6:	2485                	addiw	s1,s1,1
    800027e8:	fd471ae3          	bne	a4,s4,800027bc <balloc+0xec>
    800027ec:	b769                	j	80002776 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800027ee:	00006517          	auipc	a0,0x6
    800027f2:	ce250513          	addi	a0,a0,-798 # 800084d0 <syscalls+0x100>
    800027f6:	00003097          	auipc	ra,0x3
    800027fa:	530080e7          	jalr	1328(ra) # 80005d26 <printf>
  return 0;
    800027fe:	4481                	li	s1,0
    80002800:	bfa9                	j	8000275a <balloc+0x8a>

0000000080002802 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002802:	7179                	addi	sp,sp,-48
    80002804:	f406                	sd	ra,40(sp)
    80002806:	f022                	sd	s0,32(sp)
    80002808:	ec26                	sd	s1,24(sp)
    8000280a:	e84a                	sd	s2,16(sp)
    8000280c:	e44e                	sd	s3,8(sp)
    8000280e:	e052                	sd	s4,0(sp)
    80002810:	1800                	addi	s0,sp,48
    80002812:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002814:	47ad                	li	a5,11
    80002816:	02b7e863          	bltu	a5,a1,80002846 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    8000281a:	02059793          	slli	a5,a1,0x20
    8000281e:	01e7d593          	srli	a1,a5,0x1e
    80002822:	00b504b3          	add	s1,a0,a1
    80002826:	0504a903          	lw	s2,80(s1)
    8000282a:	06091e63          	bnez	s2,800028a6 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000282e:	4108                	lw	a0,0(a0)
    80002830:	00000097          	auipc	ra,0x0
    80002834:	ea0080e7          	jalr	-352(ra) # 800026d0 <balloc>
    80002838:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000283c:	06090563          	beqz	s2,800028a6 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80002840:	0524a823          	sw	s2,80(s1)
    80002844:	a08d                	j	800028a6 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002846:	ff45849b          	addiw	s1,a1,-12
    8000284a:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000284e:	0ff00793          	li	a5,255
    80002852:	08e7e563          	bltu	a5,a4,800028dc <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002856:	08052903          	lw	s2,128(a0)
    8000285a:	00091d63          	bnez	s2,80002874 <bmap+0x72>
      addr = balloc(ip->dev);
    8000285e:	4108                	lw	a0,0(a0)
    80002860:	00000097          	auipc	ra,0x0
    80002864:	e70080e7          	jalr	-400(ra) # 800026d0 <balloc>
    80002868:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000286c:	02090d63          	beqz	s2,800028a6 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002870:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002874:	85ca                	mv	a1,s2
    80002876:	0009a503          	lw	a0,0(s3)
    8000287a:	00000097          	auipc	ra,0x0
    8000287e:	b94080e7          	jalr	-1132(ra) # 8000240e <bread>
    80002882:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002884:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002888:	02049713          	slli	a4,s1,0x20
    8000288c:	01e75593          	srli	a1,a4,0x1e
    80002890:	00b784b3          	add	s1,a5,a1
    80002894:	0004a903          	lw	s2,0(s1)
    80002898:	02090063          	beqz	s2,800028b8 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000289c:	8552                	mv	a0,s4
    8000289e:	00000097          	auipc	ra,0x0
    800028a2:	ca0080e7          	jalr	-864(ra) # 8000253e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800028a6:	854a                	mv	a0,s2
    800028a8:	70a2                	ld	ra,40(sp)
    800028aa:	7402                	ld	s0,32(sp)
    800028ac:	64e2                	ld	s1,24(sp)
    800028ae:	6942                	ld	s2,16(sp)
    800028b0:	69a2                	ld	s3,8(sp)
    800028b2:	6a02                	ld	s4,0(sp)
    800028b4:	6145                	addi	sp,sp,48
    800028b6:	8082                	ret
      addr = balloc(ip->dev);
    800028b8:	0009a503          	lw	a0,0(s3)
    800028bc:	00000097          	auipc	ra,0x0
    800028c0:	e14080e7          	jalr	-492(ra) # 800026d0 <balloc>
    800028c4:	0005091b          	sext.w	s2,a0
      if(addr){
    800028c8:	fc090ae3          	beqz	s2,8000289c <bmap+0x9a>
        a[bn] = addr;
    800028cc:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800028d0:	8552                	mv	a0,s4
    800028d2:	00001097          	auipc	ra,0x1
    800028d6:	ef6080e7          	jalr	-266(ra) # 800037c8 <log_write>
    800028da:	b7c9                	j	8000289c <bmap+0x9a>
  panic("bmap: out of range");
    800028dc:	00006517          	auipc	a0,0x6
    800028e0:	c0c50513          	addi	a0,a0,-1012 # 800084e8 <syscalls+0x118>
    800028e4:	00003097          	auipc	ra,0x3
    800028e8:	3f8080e7          	jalr	1016(ra) # 80005cdc <panic>

00000000800028ec <iget>:
{
    800028ec:	7179                	addi	sp,sp,-48
    800028ee:	f406                	sd	ra,40(sp)
    800028f0:	f022                	sd	s0,32(sp)
    800028f2:	ec26                	sd	s1,24(sp)
    800028f4:	e84a                	sd	s2,16(sp)
    800028f6:	e44e                	sd	s3,8(sp)
    800028f8:	e052                	sd	s4,0(sp)
    800028fa:	1800                	addi	s0,sp,48
    800028fc:	89aa                	mv	s3,a0
    800028fe:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002900:	00014517          	auipc	a0,0x14
    80002904:	52850513          	addi	a0,a0,1320 # 80016e28 <itable>
    80002908:	00004097          	auipc	ra,0x4
    8000290c:	90c080e7          	jalr	-1780(ra) # 80006214 <acquire>
  empty = 0;
    80002910:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002912:	00014497          	auipc	s1,0x14
    80002916:	52e48493          	addi	s1,s1,1326 # 80016e40 <itable+0x18>
    8000291a:	00016697          	auipc	a3,0x16
    8000291e:	fb668693          	addi	a3,a3,-74 # 800188d0 <log>
    80002922:	a039                	j	80002930 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002924:	02090b63          	beqz	s2,8000295a <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002928:	08848493          	addi	s1,s1,136
    8000292c:	02d48a63          	beq	s1,a3,80002960 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002930:	449c                	lw	a5,8(s1)
    80002932:	fef059e3          	blez	a5,80002924 <iget+0x38>
    80002936:	4098                	lw	a4,0(s1)
    80002938:	ff3716e3          	bne	a4,s3,80002924 <iget+0x38>
    8000293c:	40d8                	lw	a4,4(s1)
    8000293e:	ff4713e3          	bne	a4,s4,80002924 <iget+0x38>
      ip->ref++;
    80002942:	2785                	addiw	a5,a5,1
    80002944:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002946:	00014517          	auipc	a0,0x14
    8000294a:	4e250513          	addi	a0,a0,1250 # 80016e28 <itable>
    8000294e:	00004097          	auipc	ra,0x4
    80002952:	97a080e7          	jalr	-1670(ra) # 800062c8 <release>
      return ip;
    80002956:	8926                	mv	s2,s1
    80002958:	a03d                	j	80002986 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000295a:	f7f9                	bnez	a5,80002928 <iget+0x3c>
    8000295c:	8926                	mv	s2,s1
    8000295e:	b7e9                	j	80002928 <iget+0x3c>
  if(empty == 0)
    80002960:	02090c63          	beqz	s2,80002998 <iget+0xac>
  ip->dev = dev;
    80002964:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002968:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000296c:	4785                	li	a5,1
    8000296e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002972:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002976:	00014517          	auipc	a0,0x14
    8000297a:	4b250513          	addi	a0,a0,1202 # 80016e28 <itable>
    8000297e:	00004097          	auipc	ra,0x4
    80002982:	94a080e7          	jalr	-1718(ra) # 800062c8 <release>
}
    80002986:	854a                	mv	a0,s2
    80002988:	70a2                	ld	ra,40(sp)
    8000298a:	7402                	ld	s0,32(sp)
    8000298c:	64e2                	ld	s1,24(sp)
    8000298e:	6942                	ld	s2,16(sp)
    80002990:	69a2                	ld	s3,8(sp)
    80002992:	6a02                	ld	s4,0(sp)
    80002994:	6145                	addi	sp,sp,48
    80002996:	8082                	ret
    panic("iget: no inodes");
    80002998:	00006517          	auipc	a0,0x6
    8000299c:	b6850513          	addi	a0,a0,-1176 # 80008500 <syscalls+0x130>
    800029a0:	00003097          	auipc	ra,0x3
    800029a4:	33c080e7          	jalr	828(ra) # 80005cdc <panic>

00000000800029a8 <fsinit>:
fsinit(int dev) {
    800029a8:	7179                	addi	sp,sp,-48
    800029aa:	f406                	sd	ra,40(sp)
    800029ac:	f022                	sd	s0,32(sp)
    800029ae:	ec26                	sd	s1,24(sp)
    800029b0:	e84a                	sd	s2,16(sp)
    800029b2:	e44e                	sd	s3,8(sp)
    800029b4:	1800                	addi	s0,sp,48
    800029b6:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800029b8:	4585                	li	a1,1
    800029ba:	00000097          	auipc	ra,0x0
    800029be:	a54080e7          	jalr	-1452(ra) # 8000240e <bread>
    800029c2:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800029c4:	00014997          	auipc	s3,0x14
    800029c8:	44498993          	addi	s3,s3,1092 # 80016e08 <sb>
    800029cc:	02000613          	li	a2,32
    800029d0:	05850593          	addi	a1,a0,88
    800029d4:	854e                	mv	a0,s3
    800029d6:	ffffe097          	auipc	ra,0xffffe
    800029da:	800080e7          	jalr	-2048(ra) # 800001d6 <memmove>
  brelse(bp);
    800029de:	8526                	mv	a0,s1
    800029e0:	00000097          	auipc	ra,0x0
    800029e4:	b5e080e7          	jalr	-1186(ra) # 8000253e <brelse>
  if(sb.magic != FSMAGIC)
    800029e8:	0009a703          	lw	a4,0(s3)
    800029ec:	102037b7          	lui	a5,0x10203
    800029f0:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800029f4:	02f71263          	bne	a4,a5,80002a18 <fsinit+0x70>
  initlog(dev, &sb);
    800029f8:	00014597          	auipc	a1,0x14
    800029fc:	41058593          	addi	a1,a1,1040 # 80016e08 <sb>
    80002a00:	854a                	mv	a0,s2
    80002a02:	00001097          	auipc	ra,0x1
    80002a06:	b4a080e7          	jalr	-1206(ra) # 8000354c <initlog>
}
    80002a0a:	70a2                	ld	ra,40(sp)
    80002a0c:	7402                	ld	s0,32(sp)
    80002a0e:	64e2                	ld	s1,24(sp)
    80002a10:	6942                	ld	s2,16(sp)
    80002a12:	69a2                	ld	s3,8(sp)
    80002a14:	6145                	addi	sp,sp,48
    80002a16:	8082                	ret
    panic("invalid file system");
    80002a18:	00006517          	auipc	a0,0x6
    80002a1c:	af850513          	addi	a0,a0,-1288 # 80008510 <syscalls+0x140>
    80002a20:	00003097          	auipc	ra,0x3
    80002a24:	2bc080e7          	jalr	700(ra) # 80005cdc <panic>

0000000080002a28 <iinit>:
{
    80002a28:	7179                	addi	sp,sp,-48
    80002a2a:	f406                	sd	ra,40(sp)
    80002a2c:	f022                	sd	s0,32(sp)
    80002a2e:	ec26                	sd	s1,24(sp)
    80002a30:	e84a                	sd	s2,16(sp)
    80002a32:	e44e                	sd	s3,8(sp)
    80002a34:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002a36:	00006597          	auipc	a1,0x6
    80002a3a:	af258593          	addi	a1,a1,-1294 # 80008528 <syscalls+0x158>
    80002a3e:	00014517          	auipc	a0,0x14
    80002a42:	3ea50513          	addi	a0,a0,1002 # 80016e28 <itable>
    80002a46:	00003097          	auipc	ra,0x3
    80002a4a:	73e080e7          	jalr	1854(ra) # 80006184 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002a4e:	00014497          	auipc	s1,0x14
    80002a52:	40248493          	addi	s1,s1,1026 # 80016e50 <itable+0x28>
    80002a56:	00016997          	auipc	s3,0x16
    80002a5a:	e8a98993          	addi	s3,s3,-374 # 800188e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002a5e:	00006917          	auipc	s2,0x6
    80002a62:	ad290913          	addi	s2,s2,-1326 # 80008530 <syscalls+0x160>
    80002a66:	85ca                	mv	a1,s2
    80002a68:	8526                	mv	a0,s1
    80002a6a:	00001097          	auipc	ra,0x1
    80002a6e:	e42080e7          	jalr	-446(ra) # 800038ac <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002a72:	08848493          	addi	s1,s1,136
    80002a76:	ff3498e3          	bne	s1,s3,80002a66 <iinit+0x3e>
}
    80002a7a:	70a2                	ld	ra,40(sp)
    80002a7c:	7402                	ld	s0,32(sp)
    80002a7e:	64e2                	ld	s1,24(sp)
    80002a80:	6942                	ld	s2,16(sp)
    80002a82:	69a2                	ld	s3,8(sp)
    80002a84:	6145                	addi	sp,sp,48
    80002a86:	8082                	ret

0000000080002a88 <ialloc>:
{
    80002a88:	715d                	addi	sp,sp,-80
    80002a8a:	e486                	sd	ra,72(sp)
    80002a8c:	e0a2                	sd	s0,64(sp)
    80002a8e:	fc26                	sd	s1,56(sp)
    80002a90:	f84a                	sd	s2,48(sp)
    80002a92:	f44e                	sd	s3,40(sp)
    80002a94:	f052                	sd	s4,32(sp)
    80002a96:	ec56                	sd	s5,24(sp)
    80002a98:	e85a                	sd	s6,16(sp)
    80002a9a:	e45e                	sd	s7,8(sp)
    80002a9c:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a9e:	00014717          	auipc	a4,0x14
    80002aa2:	37672703          	lw	a4,886(a4) # 80016e14 <sb+0xc>
    80002aa6:	4785                	li	a5,1
    80002aa8:	04e7fa63          	bgeu	a5,a4,80002afc <ialloc+0x74>
    80002aac:	8aaa                	mv	s5,a0
    80002aae:	8bae                	mv	s7,a1
    80002ab0:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002ab2:	00014a17          	auipc	s4,0x14
    80002ab6:	356a0a13          	addi	s4,s4,854 # 80016e08 <sb>
    80002aba:	00048b1b          	sext.w	s6,s1
    80002abe:	0044d593          	srli	a1,s1,0x4
    80002ac2:	018a2783          	lw	a5,24(s4)
    80002ac6:	9dbd                	addw	a1,a1,a5
    80002ac8:	8556                	mv	a0,s5
    80002aca:	00000097          	auipc	ra,0x0
    80002ace:	944080e7          	jalr	-1724(ra) # 8000240e <bread>
    80002ad2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002ad4:	05850993          	addi	s3,a0,88
    80002ad8:	00f4f793          	andi	a5,s1,15
    80002adc:	079a                	slli	a5,a5,0x6
    80002ade:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002ae0:	00099783          	lh	a5,0(s3)
    80002ae4:	c3a1                	beqz	a5,80002b24 <ialloc+0x9c>
    brelse(bp);
    80002ae6:	00000097          	auipc	ra,0x0
    80002aea:	a58080e7          	jalr	-1448(ra) # 8000253e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002aee:	0485                	addi	s1,s1,1
    80002af0:	00ca2703          	lw	a4,12(s4)
    80002af4:	0004879b          	sext.w	a5,s1
    80002af8:	fce7e1e3          	bltu	a5,a4,80002aba <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002afc:	00006517          	auipc	a0,0x6
    80002b00:	a3c50513          	addi	a0,a0,-1476 # 80008538 <syscalls+0x168>
    80002b04:	00003097          	auipc	ra,0x3
    80002b08:	222080e7          	jalr	546(ra) # 80005d26 <printf>
  return 0;
    80002b0c:	4501                	li	a0,0
}
    80002b0e:	60a6                	ld	ra,72(sp)
    80002b10:	6406                	ld	s0,64(sp)
    80002b12:	74e2                	ld	s1,56(sp)
    80002b14:	7942                	ld	s2,48(sp)
    80002b16:	79a2                	ld	s3,40(sp)
    80002b18:	7a02                	ld	s4,32(sp)
    80002b1a:	6ae2                	ld	s5,24(sp)
    80002b1c:	6b42                	ld	s6,16(sp)
    80002b1e:	6ba2                	ld	s7,8(sp)
    80002b20:	6161                	addi	sp,sp,80
    80002b22:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002b24:	04000613          	li	a2,64
    80002b28:	4581                	li	a1,0
    80002b2a:	854e                	mv	a0,s3
    80002b2c:	ffffd097          	auipc	ra,0xffffd
    80002b30:	64e080e7          	jalr	1614(ra) # 8000017a <memset>
      dip->type = type;
    80002b34:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002b38:	854a                	mv	a0,s2
    80002b3a:	00001097          	auipc	ra,0x1
    80002b3e:	c8e080e7          	jalr	-882(ra) # 800037c8 <log_write>
      brelse(bp);
    80002b42:	854a                	mv	a0,s2
    80002b44:	00000097          	auipc	ra,0x0
    80002b48:	9fa080e7          	jalr	-1542(ra) # 8000253e <brelse>
      return iget(dev, inum);
    80002b4c:	85da                	mv	a1,s6
    80002b4e:	8556                	mv	a0,s5
    80002b50:	00000097          	auipc	ra,0x0
    80002b54:	d9c080e7          	jalr	-612(ra) # 800028ec <iget>
    80002b58:	bf5d                	j	80002b0e <ialloc+0x86>

0000000080002b5a <iupdate>:
{
    80002b5a:	1101                	addi	sp,sp,-32
    80002b5c:	ec06                	sd	ra,24(sp)
    80002b5e:	e822                	sd	s0,16(sp)
    80002b60:	e426                	sd	s1,8(sp)
    80002b62:	e04a                	sd	s2,0(sp)
    80002b64:	1000                	addi	s0,sp,32
    80002b66:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002b68:	415c                	lw	a5,4(a0)
    80002b6a:	0047d79b          	srliw	a5,a5,0x4
    80002b6e:	00014597          	auipc	a1,0x14
    80002b72:	2b25a583          	lw	a1,690(a1) # 80016e20 <sb+0x18>
    80002b76:	9dbd                	addw	a1,a1,a5
    80002b78:	4108                	lw	a0,0(a0)
    80002b7a:	00000097          	auipc	ra,0x0
    80002b7e:	894080e7          	jalr	-1900(ra) # 8000240e <bread>
    80002b82:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002b84:	05850793          	addi	a5,a0,88
    80002b88:	40d8                	lw	a4,4(s1)
    80002b8a:	8b3d                	andi	a4,a4,15
    80002b8c:	071a                	slli	a4,a4,0x6
    80002b8e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002b90:	04449703          	lh	a4,68(s1)
    80002b94:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002b98:	04649703          	lh	a4,70(s1)
    80002b9c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002ba0:	04849703          	lh	a4,72(s1)
    80002ba4:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002ba8:	04a49703          	lh	a4,74(s1)
    80002bac:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002bb0:	44f8                	lw	a4,76(s1)
    80002bb2:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002bb4:	03400613          	li	a2,52
    80002bb8:	05048593          	addi	a1,s1,80
    80002bbc:	00c78513          	addi	a0,a5,12
    80002bc0:	ffffd097          	auipc	ra,0xffffd
    80002bc4:	616080e7          	jalr	1558(ra) # 800001d6 <memmove>
  log_write(bp);
    80002bc8:	854a                	mv	a0,s2
    80002bca:	00001097          	auipc	ra,0x1
    80002bce:	bfe080e7          	jalr	-1026(ra) # 800037c8 <log_write>
  brelse(bp);
    80002bd2:	854a                	mv	a0,s2
    80002bd4:	00000097          	auipc	ra,0x0
    80002bd8:	96a080e7          	jalr	-1686(ra) # 8000253e <brelse>
}
    80002bdc:	60e2                	ld	ra,24(sp)
    80002bde:	6442                	ld	s0,16(sp)
    80002be0:	64a2                	ld	s1,8(sp)
    80002be2:	6902                	ld	s2,0(sp)
    80002be4:	6105                	addi	sp,sp,32
    80002be6:	8082                	ret

0000000080002be8 <idup>:
{
    80002be8:	1101                	addi	sp,sp,-32
    80002bea:	ec06                	sd	ra,24(sp)
    80002bec:	e822                	sd	s0,16(sp)
    80002bee:	e426                	sd	s1,8(sp)
    80002bf0:	1000                	addi	s0,sp,32
    80002bf2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002bf4:	00014517          	auipc	a0,0x14
    80002bf8:	23450513          	addi	a0,a0,564 # 80016e28 <itable>
    80002bfc:	00003097          	auipc	ra,0x3
    80002c00:	618080e7          	jalr	1560(ra) # 80006214 <acquire>
  ip->ref++;
    80002c04:	449c                	lw	a5,8(s1)
    80002c06:	2785                	addiw	a5,a5,1
    80002c08:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002c0a:	00014517          	auipc	a0,0x14
    80002c0e:	21e50513          	addi	a0,a0,542 # 80016e28 <itable>
    80002c12:	00003097          	auipc	ra,0x3
    80002c16:	6b6080e7          	jalr	1718(ra) # 800062c8 <release>
}
    80002c1a:	8526                	mv	a0,s1
    80002c1c:	60e2                	ld	ra,24(sp)
    80002c1e:	6442                	ld	s0,16(sp)
    80002c20:	64a2                	ld	s1,8(sp)
    80002c22:	6105                	addi	sp,sp,32
    80002c24:	8082                	ret

0000000080002c26 <ilock>:
{
    80002c26:	1101                	addi	sp,sp,-32
    80002c28:	ec06                	sd	ra,24(sp)
    80002c2a:	e822                	sd	s0,16(sp)
    80002c2c:	e426                	sd	s1,8(sp)
    80002c2e:	e04a                	sd	s2,0(sp)
    80002c30:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002c32:	c115                	beqz	a0,80002c56 <ilock+0x30>
    80002c34:	84aa                	mv	s1,a0
    80002c36:	451c                	lw	a5,8(a0)
    80002c38:	00f05f63          	blez	a5,80002c56 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002c3c:	0541                	addi	a0,a0,16
    80002c3e:	00001097          	auipc	ra,0x1
    80002c42:	ca8080e7          	jalr	-856(ra) # 800038e6 <acquiresleep>
  if(ip->valid == 0){
    80002c46:	40bc                	lw	a5,64(s1)
    80002c48:	cf99                	beqz	a5,80002c66 <ilock+0x40>
}
    80002c4a:	60e2                	ld	ra,24(sp)
    80002c4c:	6442                	ld	s0,16(sp)
    80002c4e:	64a2                	ld	s1,8(sp)
    80002c50:	6902                	ld	s2,0(sp)
    80002c52:	6105                	addi	sp,sp,32
    80002c54:	8082                	ret
    panic("ilock");
    80002c56:	00006517          	auipc	a0,0x6
    80002c5a:	8fa50513          	addi	a0,a0,-1798 # 80008550 <syscalls+0x180>
    80002c5e:	00003097          	auipc	ra,0x3
    80002c62:	07e080e7          	jalr	126(ra) # 80005cdc <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002c66:	40dc                	lw	a5,4(s1)
    80002c68:	0047d79b          	srliw	a5,a5,0x4
    80002c6c:	00014597          	auipc	a1,0x14
    80002c70:	1b45a583          	lw	a1,436(a1) # 80016e20 <sb+0x18>
    80002c74:	9dbd                	addw	a1,a1,a5
    80002c76:	4088                	lw	a0,0(s1)
    80002c78:	fffff097          	auipc	ra,0xfffff
    80002c7c:	796080e7          	jalr	1942(ra) # 8000240e <bread>
    80002c80:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002c82:	05850593          	addi	a1,a0,88
    80002c86:	40dc                	lw	a5,4(s1)
    80002c88:	8bbd                	andi	a5,a5,15
    80002c8a:	079a                	slli	a5,a5,0x6
    80002c8c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002c8e:	00059783          	lh	a5,0(a1)
    80002c92:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002c96:	00259783          	lh	a5,2(a1)
    80002c9a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002c9e:	00459783          	lh	a5,4(a1)
    80002ca2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002ca6:	00659783          	lh	a5,6(a1)
    80002caa:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002cae:	459c                	lw	a5,8(a1)
    80002cb0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002cb2:	03400613          	li	a2,52
    80002cb6:	05b1                	addi	a1,a1,12
    80002cb8:	05048513          	addi	a0,s1,80
    80002cbc:	ffffd097          	auipc	ra,0xffffd
    80002cc0:	51a080e7          	jalr	1306(ra) # 800001d6 <memmove>
    brelse(bp);
    80002cc4:	854a                	mv	a0,s2
    80002cc6:	00000097          	auipc	ra,0x0
    80002cca:	878080e7          	jalr	-1928(ra) # 8000253e <brelse>
    ip->valid = 1;
    80002cce:	4785                	li	a5,1
    80002cd0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002cd2:	04449783          	lh	a5,68(s1)
    80002cd6:	fbb5                	bnez	a5,80002c4a <ilock+0x24>
      panic("ilock: no type");
    80002cd8:	00006517          	auipc	a0,0x6
    80002cdc:	88050513          	addi	a0,a0,-1920 # 80008558 <syscalls+0x188>
    80002ce0:	00003097          	auipc	ra,0x3
    80002ce4:	ffc080e7          	jalr	-4(ra) # 80005cdc <panic>

0000000080002ce8 <iunlock>:
{
    80002ce8:	1101                	addi	sp,sp,-32
    80002cea:	ec06                	sd	ra,24(sp)
    80002cec:	e822                	sd	s0,16(sp)
    80002cee:	e426                	sd	s1,8(sp)
    80002cf0:	e04a                	sd	s2,0(sp)
    80002cf2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002cf4:	c905                	beqz	a0,80002d24 <iunlock+0x3c>
    80002cf6:	84aa                	mv	s1,a0
    80002cf8:	01050913          	addi	s2,a0,16
    80002cfc:	854a                	mv	a0,s2
    80002cfe:	00001097          	auipc	ra,0x1
    80002d02:	c82080e7          	jalr	-894(ra) # 80003980 <holdingsleep>
    80002d06:	cd19                	beqz	a0,80002d24 <iunlock+0x3c>
    80002d08:	449c                	lw	a5,8(s1)
    80002d0a:	00f05d63          	blez	a5,80002d24 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002d0e:	854a                	mv	a0,s2
    80002d10:	00001097          	auipc	ra,0x1
    80002d14:	c2c080e7          	jalr	-980(ra) # 8000393c <releasesleep>
}
    80002d18:	60e2                	ld	ra,24(sp)
    80002d1a:	6442                	ld	s0,16(sp)
    80002d1c:	64a2                	ld	s1,8(sp)
    80002d1e:	6902                	ld	s2,0(sp)
    80002d20:	6105                	addi	sp,sp,32
    80002d22:	8082                	ret
    panic("iunlock");
    80002d24:	00006517          	auipc	a0,0x6
    80002d28:	84450513          	addi	a0,a0,-1980 # 80008568 <syscalls+0x198>
    80002d2c:	00003097          	auipc	ra,0x3
    80002d30:	fb0080e7          	jalr	-80(ra) # 80005cdc <panic>

0000000080002d34 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002d34:	7179                	addi	sp,sp,-48
    80002d36:	f406                	sd	ra,40(sp)
    80002d38:	f022                	sd	s0,32(sp)
    80002d3a:	ec26                	sd	s1,24(sp)
    80002d3c:	e84a                	sd	s2,16(sp)
    80002d3e:	e44e                	sd	s3,8(sp)
    80002d40:	e052                	sd	s4,0(sp)
    80002d42:	1800                	addi	s0,sp,48
    80002d44:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002d46:	05050493          	addi	s1,a0,80
    80002d4a:	08050913          	addi	s2,a0,128
    80002d4e:	a021                	j	80002d56 <itrunc+0x22>
    80002d50:	0491                	addi	s1,s1,4
    80002d52:	01248d63          	beq	s1,s2,80002d6c <itrunc+0x38>
    if(ip->addrs[i]){
    80002d56:	408c                	lw	a1,0(s1)
    80002d58:	dde5                	beqz	a1,80002d50 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002d5a:	0009a503          	lw	a0,0(s3)
    80002d5e:	00000097          	auipc	ra,0x0
    80002d62:	8f6080e7          	jalr	-1802(ra) # 80002654 <bfree>
      ip->addrs[i] = 0;
    80002d66:	0004a023          	sw	zero,0(s1)
    80002d6a:	b7dd                	j	80002d50 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002d6c:	0809a583          	lw	a1,128(s3)
    80002d70:	e185                	bnez	a1,80002d90 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002d72:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002d76:	854e                	mv	a0,s3
    80002d78:	00000097          	auipc	ra,0x0
    80002d7c:	de2080e7          	jalr	-542(ra) # 80002b5a <iupdate>
}
    80002d80:	70a2                	ld	ra,40(sp)
    80002d82:	7402                	ld	s0,32(sp)
    80002d84:	64e2                	ld	s1,24(sp)
    80002d86:	6942                	ld	s2,16(sp)
    80002d88:	69a2                	ld	s3,8(sp)
    80002d8a:	6a02                	ld	s4,0(sp)
    80002d8c:	6145                	addi	sp,sp,48
    80002d8e:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002d90:	0009a503          	lw	a0,0(s3)
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	67a080e7          	jalr	1658(ra) # 8000240e <bread>
    80002d9c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002d9e:	05850493          	addi	s1,a0,88
    80002da2:	45850913          	addi	s2,a0,1112
    80002da6:	a021                	j	80002dae <itrunc+0x7a>
    80002da8:	0491                	addi	s1,s1,4
    80002daa:	01248b63          	beq	s1,s2,80002dc0 <itrunc+0x8c>
      if(a[j])
    80002dae:	408c                	lw	a1,0(s1)
    80002db0:	dde5                	beqz	a1,80002da8 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80002db2:	0009a503          	lw	a0,0(s3)
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	89e080e7          	jalr	-1890(ra) # 80002654 <bfree>
    80002dbe:	b7ed                	j	80002da8 <itrunc+0x74>
    brelse(bp);
    80002dc0:	8552                	mv	a0,s4
    80002dc2:	fffff097          	auipc	ra,0xfffff
    80002dc6:	77c080e7          	jalr	1916(ra) # 8000253e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002dca:	0809a583          	lw	a1,128(s3)
    80002dce:	0009a503          	lw	a0,0(s3)
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	882080e7          	jalr	-1918(ra) # 80002654 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002dda:	0809a023          	sw	zero,128(s3)
    80002dde:	bf51                	j	80002d72 <itrunc+0x3e>

0000000080002de0 <iput>:
{
    80002de0:	1101                	addi	sp,sp,-32
    80002de2:	ec06                	sd	ra,24(sp)
    80002de4:	e822                	sd	s0,16(sp)
    80002de6:	e426                	sd	s1,8(sp)
    80002de8:	e04a                	sd	s2,0(sp)
    80002dea:	1000                	addi	s0,sp,32
    80002dec:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002dee:	00014517          	auipc	a0,0x14
    80002df2:	03a50513          	addi	a0,a0,58 # 80016e28 <itable>
    80002df6:	00003097          	auipc	ra,0x3
    80002dfa:	41e080e7          	jalr	1054(ra) # 80006214 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002dfe:	4498                	lw	a4,8(s1)
    80002e00:	4785                	li	a5,1
    80002e02:	02f70363          	beq	a4,a5,80002e28 <iput+0x48>
  ip->ref--;
    80002e06:	449c                	lw	a5,8(s1)
    80002e08:	37fd                	addiw	a5,a5,-1
    80002e0a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002e0c:	00014517          	auipc	a0,0x14
    80002e10:	01c50513          	addi	a0,a0,28 # 80016e28 <itable>
    80002e14:	00003097          	auipc	ra,0x3
    80002e18:	4b4080e7          	jalr	1204(ra) # 800062c8 <release>
}
    80002e1c:	60e2                	ld	ra,24(sp)
    80002e1e:	6442                	ld	s0,16(sp)
    80002e20:	64a2                	ld	s1,8(sp)
    80002e22:	6902                	ld	s2,0(sp)
    80002e24:	6105                	addi	sp,sp,32
    80002e26:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002e28:	40bc                	lw	a5,64(s1)
    80002e2a:	dff1                	beqz	a5,80002e06 <iput+0x26>
    80002e2c:	04a49783          	lh	a5,74(s1)
    80002e30:	fbf9                	bnez	a5,80002e06 <iput+0x26>
    acquiresleep(&ip->lock);
    80002e32:	01048913          	addi	s2,s1,16
    80002e36:	854a                	mv	a0,s2
    80002e38:	00001097          	auipc	ra,0x1
    80002e3c:	aae080e7          	jalr	-1362(ra) # 800038e6 <acquiresleep>
    release(&itable.lock);
    80002e40:	00014517          	auipc	a0,0x14
    80002e44:	fe850513          	addi	a0,a0,-24 # 80016e28 <itable>
    80002e48:	00003097          	auipc	ra,0x3
    80002e4c:	480080e7          	jalr	1152(ra) # 800062c8 <release>
    itrunc(ip);
    80002e50:	8526                	mv	a0,s1
    80002e52:	00000097          	auipc	ra,0x0
    80002e56:	ee2080e7          	jalr	-286(ra) # 80002d34 <itrunc>
    ip->type = 0;
    80002e5a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002e5e:	8526                	mv	a0,s1
    80002e60:	00000097          	auipc	ra,0x0
    80002e64:	cfa080e7          	jalr	-774(ra) # 80002b5a <iupdate>
    ip->valid = 0;
    80002e68:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002e6c:	854a                	mv	a0,s2
    80002e6e:	00001097          	auipc	ra,0x1
    80002e72:	ace080e7          	jalr	-1330(ra) # 8000393c <releasesleep>
    acquire(&itable.lock);
    80002e76:	00014517          	auipc	a0,0x14
    80002e7a:	fb250513          	addi	a0,a0,-78 # 80016e28 <itable>
    80002e7e:	00003097          	auipc	ra,0x3
    80002e82:	396080e7          	jalr	918(ra) # 80006214 <acquire>
    80002e86:	b741                	j	80002e06 <iput+0x26>

0000000080002e88 <iunlockput>:
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	e426                	sd	s1,8(sp)
    80002e90:	1000                	addi	s0,sp,32
    80002e92:	84aa                	mv	s1,a0
  iunlock(ip);
    80002e94:	00000097          	auipc	ra,0x0
    80002e98:	e54080e7          	jalr	-428(ra) # 80002ce8 <iunlock>
  iput(ip);
    80002e9c:	8526                	mv	a0,s1
    80002e9e:	00000097          	auipc	ra,0x0
    80002ea2:	f42080e7          	jalr	-190(ra) # 80002de0 <iput>
}
    80002ea6:	60e2                	ld	ra,24(sp)
    80002ea8:	6442                	ld	s0,16(sp)
    80002eaa:	64a2                	ld	s1,8(sp)
    80002eac:	6105                	addi	sp,sp,32
    80002eae:	8082                	ret

0000000080002eb0 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002eb0:	1141                	addi	sp,sp,-16
    80002eb2:	e422                	sd	s0,8(sp)
    80002eb4:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002eb6:	411c                	lw	a5,0(a0)
    80002eb8:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002eba:	415c                	lw	a5,4(a0)
    80002ebc:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002ebe:	04451783          	lh	a5,68(a0)
    80002ec2:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002ec6:	04a51783          	lh	a5,74(a0)
    80002eca:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002ece:	04c56783          	lwu	a5,76(a0)
    80002ed2:	e99c                	sd	a5,16(a1)
}
    80002ed4:	6422                	ld	s0,8(sp)
    80002ed6:	0141                	addi	sp,sp,16
    80002ed8:	8082                	ret

0000000080002eda <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002eda:	457c                	lw	a5,76(a0)
    80002edc:	0ed7e963          	bltu	a5,a3,80002fce <readi+0xf4>
{
    80002ee0:	7159                	addi	sp,sp,-112
    80002ee2:	f486                	sd	ra,104(sp)
    80002ee4:	f0a2                	sd	s0,96(sp)
    80002ee6:	eca6                	sd	s1,88(sp)
    80002ee8:	e8ca                	sd	s2,80(sp)
    80002eea:	e4ce                	sd	s3,72(sp)
    80002eec:	e0d2                	sd	s4,64(sp)
    80002eee:	fc56                	sd	s5,56(sp)
    80002ef0:	f85a                	sd	s6,48(sp)
    80002ef2:	f45e                	sd	s7,40(sp)
    80002ef4:	f062                	sd	s8,32(sp)
    80002ef6:	ec66                	sd	s9,24(sp)
    80002ef8:	e86a                	sd	s10,16(sp)
    80002efa:	e46e                	sd	s11,8(sp)
    80002efc:	1880                	addi	s0,sp,112
    80002efe:	8b2a                	mv	s6,a0
    80002f00:	8bae                	mv	s7,a1
    80002f02:	8a32                	mv	s4,a2
    80002f04:	84b6                	mv	s1,a3
    80002f06:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002f08:	9f35                	addw	a4,a4,a3
    return 0;
    80002f0a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002f0c:	0ad76063          	bltu	a4,a3,80002fac <readi+0xd2>
  if(off + n > ip->size)
    80002f10:	00e7f463          	bgeu	a5,a4,80002f18 <readi+0x3e>
    n = ip->size - off;
    80002f14:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f18:	0a0a8963          	beqz	s5,80002fca <readi+0xf0>
    80002f1c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f1e:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002f22:	5c7d                	li	s8,-1
    80002f24:	a82d                	j	80002f5e <readi+0x84>
    80002f26:	020d1d93          	slli	s11,s10,0x20
    80002f2a:	020ddd93          	srli	s11,s11,0x20
    80002f2e:	05890613          	addi	a2,s2,88
    80002f32:	86ee                	mv	a3,s11
    80002f34:	963a                	add	a2,a2,a4
    80002f36:	85d2                	mv	a1,s4
    80002f38:	855e                	mv	a0,s7
    80002f3a:	fffff097          	auipc	ra,0xfffff
    80002f3e:	a20080e7          	jalr	-1504(ra) # 8000195a <either_copyout>
    80002f42:	05850d63          	beq	a0,s8,80002f9c <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002f46:	854a                	mv	a0,s2
    80002f48:	fffff097          	auipc	ra,0xfffff
    80002f4c:	5f6080e7          	jalr	1526(ra) # 8000253e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f50:	013d09bb          	addw	s3,s10,s3
    80002f54:	009d04bb          	addw	s1,s10,s1
    80002f58:	9a6e                	add	s4,s4,s11
    80002f5a:	0559f763          	bgeu	s3,s5,80002fa8 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80002f5e:	00a4d59b          	srliw	a1,s1,0xa
    80002f62:	855a                	mv	a0,s6
    80002f64:	00000097          	auipc	ra,0x0
    80002f68:	89e080e7          	jalr	-1890(ra) # 80002802 <bmap>
    80002f6c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002f70:	cd85                	beqz	a1,80002fa8 <readi+0xce>
    bp = bread(ip->dev, addr);
    80002f72:	000b2503          	lw	a0,0(s6)
    80002f76:	fffff097          	auipc	ra,0xfffff
    80002f7a:	498080e7          	jalr	1176(ra) # 8000240e <bread>
    80002f7e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f80:	3ff4f713          	andi	a4,s1,1023
    80002f84:	40ec87bb          	subw	a5,s9,a4
    80002f88:	413a86bb          	subw	a3,s5,s3
    80002f8c:	8d3e                	mv	s10,a5
    80002f8e:	2781                	sext.w	a5,a5
    80002f90:	0006861b          	sext.w	a2,a3
    80002f94:	f8f679e3          	bgeu	a2,a5,80002f26 <readi+0x4c>
    80002f98:	8d36                	mv	s10,a3
    80002f9a:	b771                	j	80002f26 <readi+0x4c>
      brelse(bp);
    80002f9c:	854a                	mv	a0,s2
    80002f9e:	fffff097          	auipc	ra,0xfffff
    80002fa2:	5a0080e7          	jalr	1440(ra) # 8000253e <brelse>
      tot = -1;
    80002fa6:	59fd                	li	s3,-1
  }
  return tot;
    80002fa8:	0009851b          	sext.w	a0,s3
}
    80002fac:	70a6                	ld	ra,104(sp)
    80002fae:	7406                	ld	s0,96(sp)
    80002fb0:	64e6                	ld	s1,88(sp)
    80002fb2:	6946                	ld	s2,80(sp)
    80002fb4:	69a6                	ld	s3,72(sp)
    80002fb6:	6a06                	ld	s4,64(sp)
    80002fb8:	7ae2                	ld	s5,56(sp)
    80002fba:	7b42                	ld	s6,48(sp)
    80002fbc:	7ba2                	ld	s7,40(sp)
    80002fbe:	7c02                	ld	s8,32(sp)
    80002fc0:	6ce2                	ld	s9,24(sp)
    80002fc2:	6d42                	ld	s10,16(sp)
    80002fc4:	6da2                	ld	s11,8(sp)
    80002fc6:	6165                	addi	sp,sp,112
    80002fc8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002fca:	89d6                	mv	s3,s5
    80002fcc:	bff1                	j	80002fa8 <readi+0xce>
    return 0;
    80002fce:	4501                	li	a0,0
}
    80002fd0:	8082                	ret

0000000080002fd2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002fd2:	457c                	lw	a5,76(a0)
    80002fd4:	10d7e863          	bltu	a5,a3,800030e4 <writei+0x112>
{
    80002fd8:	7159                	addi	sp,sp,-112
    80002fda:	f486                	sd	ra,104(sp)
    80002fdc:	f0a2                	sd	s0,96(sp)
    80002fde:	eca6                	sd	s1,88(sp)
    80002fe0:	e8ca                	sd	s2,80(sp)
    80002fe2:	e4ce                	sd	s3,72(sp)
    80002fe4:	e0d2                	sd	s4,64(sp)
    80002fe6:	fc56                	sd	s5,56(sp)
    80002fe8:	f85a                	sd	s6,48(sp)
    80002fea:	f45e                	sd	s7,40(sp)
    80002fec:	f062                	sd	s8,32(sp)
    80002fee:	ec66                	sd	s9,24(sp)
    80002ff0:	e86a                	sd	s10,16(sp)
    80002ff2:	e46e                	sd	s11,8(sp)
    80002ff4:	1880                	addi	s0,sp,112
    80002ff6:	8aaa                	mv	s5,a0
    80002ff8:	8bae                	mv	s7,a1
    80002ffa:	8a32                	mv	s4,a2
    80002ffc:	8936                	mv	s2,a3
    80002ffe:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003000:	00e687bb          	addw	a5,a3,a4
    80003004:	0ed7e263          	bltu	a5,a3,800030e8 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003008:	00043737          	lui	a4,0x43
    8000300c:	0ef76063          	bltu	a4,a5,800030ec <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003010:	0c0b0863          	beqz	s6,800030e0 <writei+0x10e>
    80003014:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003016:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000301a:	5c7d                	li	s8,-1
    8000301c:	a091                	j	80003060 <writei+0x8e>
    8000301e:	020d1d93          	slli	s11,s10,0x20
    80003022:	020ddd93          	srli	s11,s11,0x20
    80003026:	05848513          	addi	a0,s1,88
    8000302a:	86ee                	mv	a3,s11
    8000302c:	8652                	mv	a2,s4
    8000302e:	85de                	mv	a1,s7
    80003030:	953a                	add	a0,a0,a4
    80003032:	fffff097          	auipc	ra,0xfffff
    80003036:	97e080e7          	jalr	-1666(ra) # 800019b0 <either_copyin>
    8000303a:	07850263          	beq	a0,s8,8000309e <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000303e:	8526                	mv	a0,s1
    80003040:	00000097          	auipc	ra,0x0
    80003044:	788080e7          	jalr	1928(ra) # 800037c8 <log_write>
    brelse(bp);
    80003048:	8526                	mv	a0,s1
    8000304a:	fffff097          	auipc	ra,0xfffff
    8000304e:	4f4080e7          	jalr	1268(ra) # 8000253e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003052:	013d09bb          	addw	s3,s10,s3
    80003056:	012d093b          	addw	s2,s10,s2
    8000305a:	9a6e                	add	s4,s4,s11
    8000305c:	0569f663          	bgeu	s3,s6,800030a8 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003060:	00a9559b          	srliw	a1,s2,0xa
    80003064:	8556                	mv	a0,s5
    80003066:	fffff097          	auipc	ra,0xfffff
    8000306a:	79c080e7          	jalr	1948(ra) # 80002802 <bmap>
    8000306e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003072:	c99d                	beqz	a1,800030a8 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003074:	000aa503          	lw	a0,0(s5)
    80003078:	fffff097          	auipc	ra,0xfffff
    8000307c:	396080e7          	jalr	918(ra) # 8000240e <bread>
    80003080:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003082:	3ff97713          	andi	a4,s2,1023
    80003086:	40ec87bb          	subw	a5,s9,a4
    8000308a:	413b06bb          	subw	a3,s6,s3
    8000308e:	8d3e                	mv	s10,a5
    80003090:	2781                	sext.w	a5,a5
    80003092:	0006861b          	sext.w	a2,a3
    80003096:	f8f674e3          	bgeu	a2,a5,8000301e <writei+0x4c>
    8000309a:	8d36                	mv	s10,a3
    8000309c:	b749                	j	8000301e <writei+0x4c>
      brelse(bp);
    8000309e:	8526                	mv	a0,s1
    800030a0:	fffff097          	auipc	ra,0xfffff
    800030a4:	49e080e7          	jalr	1182(ra) # 8000253e <brelse>
  }

  if(off > ip->size)
    800030a8:	04caa783          	lw	a5,76(s5)
    800030ac:	0127f463          	bgeu	a5,s2,800030b4 <writei+0xe2>
    ip->size = off;
    800030b0:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800030b4:	8556                	mv	a0,s5
    800030b6:	00000097          	auipc	ra,0x0
    800030ba:	aa4080e7          	jalr	-1372(ra) # 80002b5a <iupdate>

  return tot;
    800030be:	0009851b          	sext.w	a0,s3
}
    800030c2:	70a6                	ld	ra,104(sp)
    800030c4:	7406                	ld	s0,96(sp)
    800030c6:	64e6                	ld	s1,88(sp)
    800030c8:	6946                	ld	s2,80(sp)
    800030ca:	69a6                	ld	s3,72(sp)
    800030cc:	6a06                	ld	s4,64(sp)
    800030ce:	7ae2                	ld	s5,56(sp)
    800030d0:	7b42                	ld	s6,48(sp)
    800030d2:	7ba2                	ld	s7,40(sp)
    800030d4:	7c02                	ld	s8,32(sp)
    800030d6:	6ce2                	ld	s9,24(sp)
    800030d8:	6d42                	ld	s10,16(sp)
    800030da:	6da2                	ld	s11,8(sp)
    800030dc:	6165                	addi	sp,sp,112
    800030de:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800030e0:	89da                	mv	s3,s6
    800030e2:	bfc9                	j	800030b4 <writei+0xe2>
    return -1;
    800030e4:	557d                	li	a0,-1
}
    800030e6:	8082                	ret
    return -1;
    800030e8:	557d                	li	a0,-1
    800030ea:	bfe1                	j	800030c2 <writei+0xf0>
    return -1;
    800030ec:	557d                	li	a0,-1
    800030ee:	bfd1                	j	800030c2 <writei+0xf0>

00000000800030f0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800030f0:	1141                	addi	sp,sp,-16
    800030f2:	e406                	sd	ra,8(sp)
    800030f4:	e022                	sd	s0,0(sp)
    800030f6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800030f8:	4639                	li	a2,14
    800030fa:	ffffd097          	auipc	ra,0xffffd
    800030fe:	150080e7          	jalr	336(ra) # 8000024a <strncmp>
}
    80003102:	60a2                	ld	ra,8(sp)
    80003104:	6402                	ld	s0,0(sp)
    80003106:	0141                	addi	sp,sp,16
    80003108:	8082                	ret

000000008000310a <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000310a:	7139                	addi	sp,sp,-64
    8000310c:	fc06                	sd	ra,56(sp)
    8000310e:	f822                	sd	s0,48(sp)
    80003110:	f426                	sd	s1,40(sp)
    80003112:	f04a                	sd	s2,32(sp)
    80003114:	ec4e                	sd	s3,24(sp)
    80003116:	e852                	sd	s4,16(sp)
    80003118:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000311a:	04451703          	lh	a4,68(a0)
    8000311e:	4785                	li	a5,1
    80003120:	00f71a63          	bne	a4,a5,80003134 <dirlookup+0x2a>
    80003124:	892a                	mv	s2,a0
    80003126:	89ae                	mv	s3,a1
    80003128:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000312a:	457c                	lw	a5,76(a0)
    8000312c:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000312e:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003130:	e79d                	bnez	a5,8000315e <dirlookup+0x54>
    80003132:	a8a5                	j	800031aa <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003134:	00005517          	auipc	a0,0x5
    80003138:	43c50513          	addi	a0,a0,1084 # 80008570 <syscalls+0x1a0>
    8000313c:	00003097          	auipc	ra,0x3
    80003140:	ba0080e7          	jalr	-1120(ra) # 80005cdc <panic>
      panic("dirlookup read");
    80003144:	00005517          	auipc	a0,0x5
    80003148:	44450513          	addi	a0,a0,1092 # 80008588 <syscalls+0x1b8>
    8000314c:	00003097          	auipc	ra,0x3
    80003150:	b90080e7          	jalr	-1136(ra) # 80005cdc <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003154:	24c1                	addiw	s1,s1,16
    80003156:	04c92783          	lw	a5,76(s2)
    8000315a:	04f4f763          	bgeu	s1,a5,800031a8 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000315e:	4741                	li	a4,16
    80003160:	86a6                	mv	a3,s1
    80003162:	fc040613          	addi	a2,s0,-64
    80003166:	4581                	li	a1,0
    80003168:	854a                	mv	a0,s2
    8000316a:	00000097          	auipc	ra,0x0
    8000316e:	d70080e7          	jalr	-656(ra) # 80002eda <readi>
    80003172:	47c1                	li	a5,16
    80003174:	fcf518e3          	bne	a0,a5,80003144 <dirlookup+0x3a>
    if(de.inum == 0)
    80003178:	fc045783          	lhu	a5,-64(s0)
    8000317c:	dfe1                	beqz	a5,80003154 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000317e:	fc240593          	addi	a1,s0,-62
    80003182:	854e                	mv	a0,s3
    80003184:	00000097          	auipc	ra,0x0
    80003188:	f6c080e7          	jalr	-148(ra) # 800030f0 <namecmp>
    8000318c:	f561                	bnez	a0,80003154 <dirlookup+0x4a>
      if(poff)
    8000318e:	000a0463          	beqz	s4,80003196 <dirlookup+0x8c>
        *poff = off;
    80003192:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003196:	fc045583          	lhu	a1,-64(s0)
    8000319a:	00092503          	lw	a0,0(s2)
    8000319e:	fffff097          	auipc	ra,0xfffff
    800031a2:	74e080e7          	jalr	1870(ra) # 800028ec <iget>
    800031a6:	a011                	j	800031aa <dirlookup+0xa0>
  return 0;
    800031a8:	4501                	li	a0,0
}
    800031aa:	70e2                	ld	ra,56(sp)
    800031ac:	7442                	ld	s0,48(sp)
    800031ae:	74a2                	ld	s1,40(sp)
    800031b0:	7902                	ld	s2,32(sp)
    800031b2:	69e2                	ld	s3,24(sp)
    800031b4:	6a42                	ld	s4,16(sp)
    800031b6:	6121                	addi	sp,sp,64
    800031b8:	8082                	ret

00000000800031ba <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800031ba:	711d                	addi	sp,sp,-96
    800031bc:	ec86                	sd	ra,88(sp)
    800031be:	e8a2                	sd	s0,80(sp)
    800031c0:	e4a6                	sd	s1,72(sp)
    800031c2:	e0ca                	sd	s2,64(sp)
    800031c4:	fc4e                	sd	s3,56(sp)
    800031c6:	f852                	sd	s4,48(sp)
    800031c8:	f456                	sd	s5,40(sp)
    800031ca:	f05a                	sd	s6,32(sp)
    800031cc:	ec5e                	sd	s7,24(sp)
    800031ce:	e862                	sd	s8,16(sp)
    800031d0:	e466                	sd	s9,8(sp)
    800031d2:	e06a                	sd	s10,0(sp)
    800031d4:	1080                	addi	s0,sp,96
    800031d6:	84aa                	mv	s1,a0
    800031d8:	8b2e                	mv	s6,a1
    800031da:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800031dc:	00054703          	lbu	a4,0(a0)
    800031e0:	02f00793          	li	a5,47
    800031e4:	02f70363          	beq	a4,a5,8000320a <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	cc2080e7          	jalr	-830(ra) # 80000eaa <myproc>
    800031f0:	15053503          	ld	a0,336(a0)
    800031f4:	00000097          	auipc	ra,0x0
    800031f8:	9f4080e7          	jalr	-1548(ra) # 80002be8 <idup>
    800031fc:	8a2a                	mv	s4,a0
  while(*path == '/')
    800031fe:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003202:	4cb5                	li	s9,13
  len = path - s;
    80003204:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003206:	4c05                	li	s8,1
    80003208:	a87d                	j	800032c6 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000320a:	4585                	li	a1,1
    8000320c:	4505                	li	a0,1
    8000320e:	fffff097          	auipc	ra,0xfffff
    80003212:	6de080e7          	jalr	1758(ra) # 800028ec <iget>
    80003216:	8a2a                	mv	s4,a0
    80003218:	b7dd                	j	800031fe <namex+0x44>
      iunlockput(ip);
    8000321a:	8552                	mv	a0,s4
    8000321c:	00000097          	auipc	ra,0x0
    80003220:	c6c080e7          	jalr	-916(ra) # 80002e88 <iunlockput>
      return 0;
    80003224:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003226:	8552                	mv	a0,s4
    80003228:	60e6                	ld	ra,88(sp)
    8000322a:	6446                	ld	s0,80(sp)
    8000322c:	64a6                	ld	s1,72(sp)
    8000322e:	6906                	ld	s2,64(sp)
    80003230:	79e2                	ld	s3,56(sp)
    80003232:	7a42                	ld	s4,48(sp)
    80003234:	7aa2                	ld	s5,40(sp)
    80003236:	7b02                	ld	s6,32(sp)
    80003238:	6be2                	ld	s7,24(sp)
    8000323a:	6c42                	ld	s8,16(sp)
    8000323c:	6ca2                	ld	s9,8(sp)
    8000323e:	6d02                	ld	s10,0(sp)
    80003240:	6125                	addi	sp,sp,96
    80003242:	8082                	ret
      iunlock(ip);
    80003244:	8552                	mv	a0,s4
    80003246:	00000097          	auipc	ra,0x0
    8000324a:	aa2080e7          	jalr	-1374(ra) # 80002ce8 <iunlock>
      return ip;
    8000324e:	bfe1                	j	80003226 <namex+0x6c>
      iunlockput(ip);
    80003250:	8552                	mv	a0,s4
    80003252:	00000097          	auipc	ra,0x0
    80003256:	c36080e7          	jalr	-970(ra) # 80002e88 <iunlockput>
      return 0;
    8000325a:	8a4e                	mv	s4,s3
    8000325c:	b7e9                	j	80003226 <namex+0x6c>
  len = path - s;
    8000325e:	40998633          	sub	a2,s3,s1
    80003262:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003266:	09acd863          	bge	s9,s10,800032f6 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000326a:	4639                	li	a2,14
    8000326c:	85a6                	mv	a1,s1
    8000326e:	8556                	mv	a0,s5
    80003270:	ffffd097          	auipc	ra,0xffffd
    80003274:	f66080e7          	jalr	-154(ra) # 800001d6 <memmove>
    80003278:	84ce                	mv	s1,s3
  while(*path == '/')
    8000327a:	0004c783          	lbu	a5,0(s1)
    8000327e:	01279763          	bne	a5,s2,8000328c <namex+0xd2>
    path++;
    80003282:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003284:	0004c783          	lbu	a5,0(s1)
    80003288:	ff278de3          	beq	a5,s2,80003282 <namex+0xc8>
    ilock(ip);
    8000328c:	8552                	mv	a0,s4
    8000328e:	00000097          	auipc	ra,0x0
    80003292:	998080e7          	jalr	-1640(ra) # 80002c26 <ilock>
    if(ip->type != T_DIR){
    80003296:	044a1783          	lh	a5,68(s4)
    8000329a:	f98790e3          	bne	a5,s8,8000321a <namex+0x60>
    if(nameiparent && *path == '\0'){
    8000329e:	000b0563          	beqz	s6,800032a8 <namex+0xee>
    800032a2:	0004c783          	lbu	a5,0(s1)
    800032a6:	dfd9                	beqz	a5,80003244 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800032a8:	865e                	mv	a2,s7
    800032aa:	85d6                	mv	a1,s5
    800032ac:	8552                	mv	a0,s4
    800032ae:	00000097          	auipc	ra,0x0
    800032b2:	e5c080e7          	jalr	-420(ra) # 8000310a <dirlookup>
    800032b6:	89aa                	mv	s3,a0
    800032b8:	dd41                	beqz	a0,80003250 <namex+0x96>
    iunlockput(ip);
    800032ba:	8552                	mv	a0,s4
    800032bc:	00000097          	auipc	ra,0x0
    800032c0:	bcc080e7          	jalr	-1076(ra) # 80002e88 <iunlockput>
    ip = next;
    800032c4:	8a4e                	mv	s4,s3
  while(*path == '/')
    800032c6:	0004c783          	lbu	a5,0(s1)
    800032ca:	01279763          	bne	a5,s2,800032d8 <namex+0x11e>
    path++;
    800032ce:	0485                	addi	s1,s1,1
  while(*path == '/')
    800032d0:	0004c783          	lbu	a5,0(s1)
    800032d4:	ff278de3          	beq	a5,s2,800032ce <namex+0x114>
  if(*path == 0)
    800032d8:	cb9d                	beqz	a5,8000330e <namex+0x154>
  while(*path != '/' && *path != 0)
    800032da:	0004c783          	lbu	a5,0(s1)
    800032de:	89a6                	mv	s3,s1
  len = path - s;
    800032e0:	8d5e                	mv	s10,s7
    800032e2:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800032e4:	01278963          	beq	a5,s2,800032f6 <namex+0x13c>
    800032e8:	dbbd                	beqz	a5,8000325e <namex+0xa4>
    path++;
    800032ea:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800032ec:	0009c783          	lbu	a5,0(s3)
    800032f0:	ff279ce3          	bne	a5,s2,800032e8 <namex+0x12e>
    800032f4:	b7ad                	j	8000325e <namex+0xa4>
    memmove(name, s, len);
    800032f6:	2601                	sext.w	a2,a2
    800032f8:	85a6                	mv	a1,s1
    800032fa:	8556                	mv	a0,s5
    800032fc:	ffffd097          	auipc	ra,0xffffd
    80003300:	eda080e7          	jalr	-294(ra) # 800001d6 <memmove>
    name[len] = 0;
    80003304:	9d56                	add	s10,s10,s5
    80003306:	000d0023          	sb	zero,0(s10)
    8000330a:	84ce                	mv	s1,s3
    8000330c:	b7bd                	j	8000327a <namex+0xc0>
  if(nameiparent){
    8000330e:	f00b0ce3          	beqz	s6,80003226 <namex+0x6c>
    iput(ip);
    80003312:	8552                	mv	a0,s4
    80003314:	00000097          	auipc	ra,0x0
    80003318:	acc080e7          	jalr	-1332(ra) # 80002de0 <iput>
    return 0;
    8000331c:	4a01                	li	s4,0
    8000331e:	b721                	j	80003226 <namex+0x6c>

0000000080003320 <dirlink>:
{
    80003320:	7139                	addi	sp,sp,-64
    80003322:	fc06                	sd	ra,56(sp)
    80003324:	f822                	sd	s0,48(sp)
    80003326:	f426                	sd	s1,40(sp)
    80003328:	f04a                	sd	s2,32(sp)
    8000332a:	ec4e                	sd	s3,24(sp)
    8000332c:	e852                	sd	s4,16(sp)
    8000332e:	0080                	addi	s0,sp,64
    80003330:	892a                	mv	s2,a0
    80003332:	8a2e                	mv	s4,a1
    80003334:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003336:	4601                	li	a2,0
    80003338:	00000097          	auipc	ra,0x0
    8000333c:	dd2080e7          	jalr	-558(ra) # 8000310a <dirlookup>
    80003340:	e93d                	bnez	a0,800033b6 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003342:	04c92483          	lw	s1,76(s2)
    80003346:	c49d                	beqz	s1,80003374 <dirlink+0x54>
    80003348:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000334a:	4741                	li	a4,16
    8000334c:	86a6                	mv	a3,s1
    8000334e:	fc040613          	addi	a2,s0,-64
    80003352:	4581                	li	a1,0
    80003354:	854a                	mv	a0,s2
    80003356:	00000097          	auipc	ra,0x0
    8000335a:	b84080e7          	jalr	-1148(ra) # 80002eda <readi>
    8000335e:	47c1                	li	a5,16
    80003360:	06f51163          	bne	a0,a5,800033c2 <dirlink+0xa2>
    if(de.inum == 0)
    80003364:	fc045783          	lhu	a5,-64(s0)
    80003368:	c791                	beqz	a5,80003374 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000336a:	24c1                	addiw	s1,s1,16
    8000336c:	04c92783          	lw	a5,76(s2)
    80003370:	fcf4ede3          	bltu	s1,a5,8000334a <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003374:	4639                	li	a2,14
    80003376:	85d2                	mv	a1,s4
    80003378:	fc240513          	addi	a0,s0,-62
    8000337c:	ffffd097          	auipc	ra,0xffffd
    80003380:	f0a080e7          	jalr	-246(ra) # 80000286 <strncpy>
  de.inum = inum;
    80003384:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003388:	4741                	li	a4,16
    8000338a:	86a6                	mv	a3,s1
    8000338c:	fc040613          	addi	a2,s0,-64
    80003390:	4581                	li	a1,0
    80003392:	854a                	mv	a0,s2
    80003394:	00000097          	auipc	ra,0x0
    80003398:	c3e080e7          	jalr	-962(ra) # 80002fd2 <writei>
    8000339c:	1541                	addi	a0,a0,-16
    8000339e:	00a03533          	snez	a0,a0
    800033a2:	40a00533          	neg	a0,a0
}
    800033a6:	70e2                	ld	ra,56(sp)
    800033a8:	7442                	ld	s0,48(sp)
    800033aa:	74a2                	ld	s1,40(sp)
    800033ac:	7902                	ld	s2,32(sp)
    800033ae:	69e2                	ld	s3,24(sp)
    800033b0:	6a42                	ld	s4,16(sp)
    800033b2:	6121                	addi	sp,sp,64
    800033b4:	8082                	ret
    iput(ip);
    800033b6:	00000097          	auipc	ra,0x0
    800033ba:	a2a080e7          	jalr	-1494(ra) # 80002de0 <iput>
    return -1;
    800033be:	557d                	li	a0,-1
    800033c0:	b7dd                	j	800033a6 <dirlink+0x86>
      panic("dirlink read");
    800033c2:	00005517          	auipc	a0,0x5
    800033c6:	1d650513          	addi	a0,a0,470 # 80008598 <syscalls+0x1c8>
    800033ca:	00003097          	auipc	ra,0x3
    800033ce:	912080e7          	jalr	-1774(ra) # 80005cdc <panic>

00000000800033d2 <namei>:

struct inode*
namei(char *path)
{
    800033d2:	1101                	addi	sp,sp,-32
    800033d4:	ec06                	sd	ra,24(sp)
    800033d6:	e822                	sd	s0,16(sp)
    800033d8:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800033da:	fe040613          	addi	a2,s0,-32
    800033de:	4581                	li	a1,0
    800033e0:	00000097          	auipc	ra,0x0
    800033e4:	dda080e7          	jalr	-550(ra) # 800031ba <namex>
}
    800033e8:	60e2                	ld	ra,24(sp)
    800033ea:	6442                	ld	s0,16(sp)
    800033ec:	6105                	addi	sp,sp,32
    800033ee:	8082                	ret

00000000800033f0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800033f0:	1141                	addi	sp,sp,-16
    800033f2:	e406                	sd	ra,8(sp)
    800033f4:	e022                	sd	s0,0(sp)
    800033f6:	0800                	addi	s0,sp,16
    800033f8:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800033fa:	4585                	li	a1,1
    800033fc:	00000097          	auipc	ra,0x0
    80003400:	dbe080e7          	jalr	-578(ra) # 800031ba <namex>
}
    80003404:	60a2                	ld	ra,8(sp)
    80003406:	6402                	ld	s0,0(sp)
    80003408:	0141                	addi	sp,sp,16
    8000340a:	8082                	ret

000000008000340c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000340c:	1101                	addi	sp,sp,-32
    8000340e:	ec06                	sd	ra,24(sp)
    80003410:	e822                	sd	s0,16(sp)
    80003412:	e426                	sd	s1,8(sp)
    80003414:	e04a                	sd	s2,0(sp)
    80003416:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003418:	00015917          	auipc	s2,0x15
    8000341c:	4b890913          	addi	s2,s2,1208 # 800188d0 <log>
    80003420:	01892583          	lw	a1,24(s2)
    80003424:	02892503          	lw	a0,40(s2)
    80003428:	fffff097          	auipc	ra,0xfffff
    8000342c:	fe6080e7          	jalr	-26(ra) # 8000240e <bread>
    80003430:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003432:	02c92683          	lw	a3,44(s2)
    80003436:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003438:	02d05863          	blez	a3,80003468 <write_head+0x5c>
    8000343c:	00015797          	auipc	a5,0x15
    80003440:	4c478793          	addi	a5,a5,1220 # 80018900 <log+0x30>
    80003444:	05c50713          	addi	a4,a0,92
    80003448:	36fd                	addiw	a3,a3,-1
    8000344a:	02069613          	slli	a2,a3,0x20
    8000344e:	01e65693          	srli	a3,a2,0x1e
    80003452:	00015617          	auipc	a2,0x15
    80003456:	4b260613          	addi	a2,a2,1202 # 80018904 <log+0x34>
    8000345a:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000345c:	4390                	lw	a2,0(a5)
    8000345e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003460:	0791                	addi	a5,a5,4
    80003462:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003464:	fed79ce3          	bne	a5,a3,8000345c <write_head+0x50>
  }
  bwrite(buf);
    80003468:	8526                	mv	a0,s1
    8000346a:	fffff097          	auipc	ra,0xfffff
    8000346e:	096080e7          	jalr	150(ra) # 80002500 <bwrite>
  brelse(buf);
    80003472:	8526                	mv	a0,s1
    80003474:	fffff097          	auipc	ra,0xfffff
    80003478:	0ca080e7          	jalr	202(ra) # 8000253e <brelse>
}
    8000347c:	60e2                	ld	ra,24(sp)
    8000347e:	6442                	ld	s0,16(sp)
    80003480:	64a2                	ld	s1,8(sp)
    80003482:	6902                	ld	s2,0(sp)
    80003484:	6105                	addi	sp,sp,32
    80003486:	8082                	ret

0000000080003488 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003488:	00015797          	auipc	a5,0x15
    8000348c:	4747a783          	lw	a5,1140(a5) # 800188fc <log+0x2c>
    80003490:	0af05d63          	blez	a5,8000354a <install_trans+0xc2>
{
    80003494:	7139                	addi	sp,sp,-64
    80003496:	fc06                	sd	ra,56(sp)
    80003498:	f822                	sd	s0,48(sp)
    8000349a:	f426                	sd	s1,40(sp)
    8000349c:	f04a                	sd	s2,32(sp)
    8000349e:	ec4e                	sd	s3,24(sp)
    800034a0:	e852                	sd	s4,16(sp)
    800034a2:	e456                	sd	s5,8(sp)
    800034a4:	e05a                	sd	s6,0(sp)
    800034a6:	0080                	addi	s0,sp,64
    800034a8:	8b2a                	mv	s6,a0
    800034aa:	00015a97          	auipc	s5,0x15
    800034ae:	456a8a93          	addi	s5,s5,1110 # 80018900 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800034b2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800034b4:	00015997          	auipc	s3,0x15
    800034b8:	41c98993          	addi	s3,s3,1052 # 800188d0 <log>
    800034bc:	a00d                	j	800034de <install_trans+0x56>
    brelse(lbuf);
    800034be:	854a                	mv	a0,s2
    800034c0:	fffff097          	auipc	ra,0xfffff
    800034c4:	07e080e7          	jalr	126(ra) # 8000253e <brelse>
    brelse(dbuf);
    800034c8:	8526                	mv	a0,s1
    800034ca:	fffff097          	auipc	ra,0xfffff
    800034ce:	074080e7          	jalr	116(ra) # 8000253e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800034d2:	2a05                	addiw	s4,s4,1
    800034d4:	0a91                	addi	s5,s5,4
    800034d6:	02c9a783          	lw	a5,44(s3)
    800034da:	04fa5e63          	bge	s4,a5,80003536 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800034de:	0189a583          	lw	a1,24(s3)
    800034e2:	014585bb          	addw	a1,a1,s4
    800034e6:	2585                	addiw	a1,a1,1
    800034e8:	0289a503          	lw	a0,40(s3)
    800034ec:	fffff097          	auipc	ra,0xfffff
    800034f0:	f22080e7          	jalr	-222(ra) # 8000240e <bread>
    800034f4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800034f6:	000aa583          	lw	a1,0(s5)
    800034fa:	0289a503          	lw	a0,40(s3)
    800034fe:	fffff097          	auipc	ra,0xfffff
    80003502:	f10080e7          	jalr	-240(ra) # 8000240e <bread>
    80003506:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003508:	40000613          	li	a2,1024
    8000350c:	05890593          	addi	a1,s2,88
    80003510:	05850513          	addi	a0,a0,88
    80003514:	ffffd097          	auipc	ra,0xffffd
    80003518:	cc2080e7          	jalr	-830(ra) # 800001d6 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000351c:	8526                	mv	a0,s1
    8000351e:	fffff097          	auipc	ra,0xfffff
    80003522:	fe2080e7          	jalr	-30(ra) # 80002500 <bwrite>
    if(recovering == 0)
    80003526:	f80b1ce3          	bnez	s6,800034be <install_trans+0x36>
      bunpin(dbuf);
    8000352a:	8526                	mv	a0,s1
    8000352c:	fffff097          	auipc	ra,0xfffff
    80003530:	0ec080e7          	jalr	236(ra) # 80002618 <bunpin>
    80003534:	b769                	j	800034be <install_trans+0x36>
}
    80003536:	70e2                	ld	ra,56(sp)
    80003538:	7442                	ld	s0,48(sp)
    8000353a:	74a2                	ld	s1,40(sp)
    8000353c:	7902                	ld	s2,32(sp)
    8000353e:	69e2                	ld	s3,24(sp)
    80003540:	6a42                	ld	s4,16(sp)
    80003542:	6aa2                	ld	s5,8(sp)
    80003544:	6b02                	ld	s6,0(sp)
    80003546:	6121                	addi	sp,sp,64
    80003548:	8082                	ret
    8000354a:	8082                	ret

000000008000354c <initlog>:
{
    8000354c:	7179                	addi	sp,sp,-48
    8000354e:	f406                	sd	ra,40(sp)
    80003550:	f022                	sd	s0,32(sp)
    80003552:	ec26                	sd	s1,24(sp)
    80003554:	e84a                	sd	s2,16(sp)
    80003556:	e44e                	sd	s3,8(sp)
    80003558:	1800                	addi	s0,sp,48
    8000355a:	892a                	mv	s2,a0
    8000355c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000355e:	00015497          	auipc	s1,0x15
    80003562:	37248493          	addi	s1,s1,882 # 800188d0 <log>
    80003566:	00005597          	auipc	a1,0x5
    8000356a:	04258593          	addi	a1,a1,66 # 800085a8 <syscalls+0x1d8>
    8000356e:	8526                	mv	a0,s1
    80003570:	00003097          	auipc	ra,0x3
    80003574:	c14080e7          	jalr	-1004(ra) # 80006184 <initlock>
  log.start = sb->logstart;
    80003578:	0149a583          	lw	a1,20(s3)
    8000357c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000357e:	0109a783          	lw	a5,16(s3)
    80003582:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003584:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003588:	854a                	mv	a0,s2
    8000358a:	fffff097          	auipc	ra,0xfffff
    8000358e:	e84080e7          	jalr	-380(ra) # 8000240e <bread>
  log.lh.n = lh->n;
    80003592:	4d34                	lw	a3,88(a0)
    80003594:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003596:	02d05663          	blez	a3,800035c2 <initlog+0x76>
    8000359a:	05c50793          	addi	a5,a0,92
    8000359e:	00015717          	auipc	a4,0x15
    800035a2:	36270713          	addi	a4,a4,866 # 80018900 <log+0x30>
    800035a6:	36fd                	addiw	a3,a3,-1
    800035a8:	02069613          	slli	a2,a3,0x20
    800035ac:	01e65693          	srli	a3,a2,0x1e
    800035b0:	06050613          	addi	a2,a0,96
    800035b4:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800035b6:	4390                	lw	a2,0(a5)
    800035b8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800035ba:	0791                	addi	a5,a5,4
    800035bc:	0711                	addi	a4,a4,4
    800035be:	fed79ce3          	bne	a5,a3,800035b6 <initlog+0x6a>
  brelse(buf);
    800035c2:	fffff097          	auipc	ra,0xfffff
    800035c6:	f7c080e7          	jalr	-132(ra) # 8000253e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800035ca:	4505                	li	a0,1
    800035cc:	00000097          	auipc	ra,0x0
    800035d0:	ebc080e7          	jalr	-324(ra) # 80003488 <install_trans>
  log.lh.n = 0;
    800035d4:	00015797          	auipc	a5,0x15
    800035d8:	3207a423          	sw	zero,808(a5) # 800188fc <log+0x2c>
  write_head(); // clear the log
    800035dc:	00000097          	auipc	ra,0x0
    800035e0:	e30080e7          	jalr	-464(ra) # 8000340c <write_head>
}
    800035e4:	70a2                	ld	ra,40(sp)
    800035e6:	7402                	ld	s0,32(sp)
    800035e8:	64e2                	ld	s1,24(sp)
    800035ea:	6942                	ld	s2,16(sp)
    800035ec:	69a2                	ld	s3,8(sp)
    800035ee:	6145                	addi	sp,sp,48
    800035f0:	8082                	ret

00000000800035f2 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800035f2:	1101                	addi	sp,sp,-32
    800035f4:	ec06                	sd	ra,24(sp)
    800035f6:	e822                	sd	s0,16(sp)
    800035f8:	e426                	sd	s1,8(sp)
    800035fa:	e04a                	sd	s2,0(sp)
    800035fc:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800035fe:	00015517          	auipc	a0,0x15
    80003602:	2d250513          	addi	a0,a0,722 # 800188d0 <log>
    80003606:	00003097          	auipc	ra,0x3
    8000360a:	c0e080e7          	jalr	-1010(ra) # 80006214 <acquire>
  while(1){
    if(log.committing){
    8000360e:	00015497          	auipc	s1,0x15
    80003612:	2c248493          	addi	s1,s1,706 # 800188d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003616:	4979                	li	s2,30
    80003618:	a039                	j	80003626 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000361a:	85a6                	mv	a1,s1
    8000361c:	8526                	mv	a0,s1
    8000361e:	ffffe097          	auipc	ra,0xffffe
    80003622:	f34080e7          	jalr	-204(ra) # 80001552 <sleep>
    if(log.committing){
    80003626:	50dc                	lw	a5,36(s1)
    80003628:	fbed                	bnez	a5,8000361a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000362a:	5098                	lw	a4,32(s1)
    8000362c:	2705                	addiw	a4,a4,1
    8000362e:	0007069b          	sext.w	a3,a4
    80003632:	0027179b          	slliw	a5,a4,0x2
    80003636:	9fb9                	addw	a5,a5,a4
    80003638:	0017979b          	slliw	a5,a5,0x1
    8000363c:	54d8                	lw	a4,44(s1)
    8000363e:	9fb9                	addw	a5,a5,a4
    80003640:	00f95963          	bge	s2,a5,80003652 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003644:	85a6                	mv	a1,s1
    80003646:	8526                	mv	a0,s1
    80003648:	ffffe097          	auipc	ra,0xffffe
    8000364c:	f0a080e7          	jalr	-246(ra) # 80001552 <sleep>
    80003650:	bfd9                	j	80003626 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80003652:	00015517          	auipc	a0,0x15
    80003656:	27e50513          	addi	a0,a0,638 # 800188d0 <log>
    8000365a:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000365c:	00003097          	auipc	ra,0x3
    80003660:	c6c080e7          	jalr	-916(ra) # 800062c8 <release>
      break;
    }
  }
}
    80003664:	60e2                	ld	ra,24(sp)
    80003666:	6442                	ld	s0,16(sp)
    80003668:	64a2                	ld	s1,8(sp)
    8000366a:	6902                	ld	s2,0(sp)
    8000366c:	6105                	addi	sp,sp,32
    8000366e:	8082                	ret

0000000080003670 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003670:	7139                	addi	sp,sp,-64
    80003672:	fc06                	sd	ra,56(sp)
    80003674:	f822                	sd	s0,48(sp)
    80003676:	f426                	sd	s1,40(sp)
    80003678:	f04a                	sd	s2,32(sp)
    8000367a:	ec4e                	sd	s3,24(sp)
    8000367c:	e852                	sd	s4,16(sp)
    8000367e:	e456                	sd	s5,8(sp)
    80003680:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003682:	00015497          	auipc	s1,0x15
    80003686:	24e48493          	addi	s1,s1,590 # 800188d0 <log>
    8000368a:	8526                	mv	a0,s1
    8000368c:	00003097          	auipc	ra,0x3
    80003690:	b88080e7          	jalr	-1144(ra) # 80006214 <acquire>
  log.outstanding -= 1;
    80003694:	509c                	lw	a5,32(s1)
    80003696:	37fd                	addiw	a5,a5,-1
    80003698:	0007891b          	sext.w	s2,a5
    8000369c:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000369e:	50dc                	lw	a5,36(s1)
    800036a0:	e7b9                	bnez	a5,800036ee <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800036a2:	04091e63          	bnez	s2,800036fe <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800036a6:	00015497          	auipc	s1,0x15
    800036aa:	22a48493          	addi	s1,s1,554 # 800188d0 <log>
    800036ae:	4785                	li	a5,1
    800036b0:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800036b2:	8526                	mv	a0,s1
    800036b4:	00003097          	auipc	ra,0x3
    800036b8:	c14080e7          	jalr	-1004(ra) # 800062c8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800036bc:	54dc                	lw	a5,44(s1)
    800036be:	06f04763          	bgtz	a5,8000372c <end_op+0xbc>
    acquire(&log.lock);
    800036c2:	00015497          	auipc	s1,0x15
    800036c6:	20e48493          	addi	s1,s1,526 # 800188d0 <log>
    800036ca:	8526                	mv	a0,s1
    800036cc:	00003097          	auipc	ra,0x3
    800036d0:	b48080e7          	jalr	-1208(ra) # 80006214 <acquire>
    log.committing = 0;
    800036d4:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800036d8:	8526                	mv	a0,s1
    800036da:	ffffe097          	auipc	ra,0xffffe
    800036de:	edc080e7          	jalr	-292(ra) # 800015b6 <wakeup>
    release(&log.lock);
    800036e2:	8526                	mv	a0,s1
    800036e4:	00003097          	auipc	ra,0x3
    800036e8:	be4080e7          	jalr	-1052(ra) # 800062c8 <release>
}
    800036ec:	a03d                	j	8000371a <end_op+0xaa>
    panic("log.committing");
    800036ee:	00005517          	auipc	a0,0x5
    800036f2:	ec250513          	addi	a0,a0,-318 # 800085b0 <syscalls+0x1e0>
    800036f6:	00002097          	auipc	ra,0x2
    800036fa:	5e6080e7          	jalr	1510(ra) # 80005cdc <panic>
    wakeup(&log);
    800036fe:	00015497          	auipc	s1,0x15
    80003702:	1d248493          	addi	s1,s1,466 # 800188d0 <log>
    80003706:	8526                	mv	a0,s1
    80003708:	ffffe097          	auipc	ra,0xffffe
    8000370c:	eae080e7          	jalr	-338(ra) # 800015b6 <wakeup>
  release(&log.lock);
    80003710:	8526                	mv	a0,s1
    80003712:	00003097          	auipc	ra,0x3
    80003716:	bb6080e7          	jalr	-1098(ra) # 800062c8 <release>
}
    8000371a:	70e2                	ld	ra,56(sp)
    8000371c:	7442                	ld	s0,48(sp)
    8000371e:	74a2                	ld	s1,40(sp)
    80003720:	7902                	ld	s2,32(sp)
    80003722:	69e2                	ld	s3,24(sp)
    80003724:	6a42                	ld	s4,16(sp)
    80003726:	6aa2                	ld	s5,8(sp)
    80003728:	6121                	addi	sp,sp,64
    8000372a:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000372c:	00015a97          	auipc	s5,0x15
    80003730:	1d4a8a93          	addi	s5,s5,468 # 80018900 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003734:	00015a17          	auipc	s4,0x15
    80003738:	19ca0a13          	addi	s4,s4,412 # 800188d0 <log>
    8000373c:	018a2583          	lw	a1,24(s4)
    80003740:	012585bb          	addw	a1,a1,s2
    80003744:	2585                	addiw	a1,a1,1
    80003746:	028a2503          	lw	a0,40(s4)
    8000374a:	fffff097          	auipc	ra,0xfffff
    8000374e:	cc4080e7          	jalr	-828(ra) # 8000240e <bread>
    80003752:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003754:	000aa583          	lw	a1,0(s5)
    80003758:	028a2503          	lw	a0,40(s4)
    8000375c:	fffff097          	auipc	ra,0xfffff
    80003760:	cb2080e7          	jalr	-846(ra) # 8000240e <bread>
    80003764:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003766:	40000613          	li	a2,1024
    8000376a:	05850593          	addi	a1,a0,88
    8000376e:	05848513          	addi	a0,s1,88
    80003772:	ffffd097          	auipc	ra,0xffffd
    80003776:	a64080e7          	jalr	-1436(ra) # 800001d6 <memmove>
    bwrite(to);  // write the log
    8000377a:	8526                	mv	a0,s1
    8000377c:	fffff097          	auipc	ra,0xfffff
    80003780:	d84080e7          	jalr	-636(ra) # 80002500 <bwrite>
    brelse(from);
    80003784:	854e                	mv	a0,s3
    80003786:	fffff097          	auipc	ra,0xfffff
    8000378a:	db8080e7          	jalr	-584(ra) # 8000253e <brelse>
    brelse(to);
    8000378e:	8526                	mv	a0,s1
    80003790:	fffff097          	auipc	ra,0xfffff
    80003794:	dae080e7          	jalr	-594(ra) # 8000253e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003798:	2905                	addiw	s2,s2,1
    8000379a:	0a91                	addi	s5,s5,4
    8000379c:	02ca2783          	lw	a5,44(s4)
    800037a0:	f8f94ee3          	blt	s2,a5,8000373c <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800037a4:	00000097          	auipc	ra,0x0
    800037a8:	c68080e7          	jalr	-920(ra) # 8000340c <write_head>
    install_trans(0); // Now install writes to home locations
    800037ac:	4501                	li	a0,0
    800037ae:	00000097          	auipc	ra,0x0
    800037b2:	cda080e7          	jalr	-806(ra) # 80003488 <install_trans>
    log.lh.n = 0;
    800037b6:	00015797          	auipc	a5,0x15
    800037ba:	1407a323          	sw	zero,326(a5) # 800188fc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800037be:	00000097          	auipc	ra,0x0
    800037c2:	c4e080e7          	jalr	-946(ra) # 8000340c <write_head>
    800037c6:	bdf5                	j	800036c2 <end_op+0x52>

00000000800037c8 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800037c8:	1101                	addi	sp,sp,-32
    800037ca:	ec06                	sd	ra,24(sp)
    800037cc:	e822                	sd	s0,16(sp)
    800037ce:	e426                	sd	s1,8(sp)
    800037d0:	e04a                	sd	s2,0(sp)
    800037d2:	1000                	addi	s0,sp,32
    800037d4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800037d6:	00015917          	auipc	s2,0x15
    800037da:	0fa90913          	addi	s2,s2,250 # 800188d0 <log>
    800037de:	854a                	mv	a0,s2
    800037e0:	00003097          	auipc	ra,0x3
    800037e4:	a34080e7          	jalr	-1484(ra) # 80006214 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800037e8:	02c92603          	lw	a2,44(s2)
    800037ec:	47f5                	li	a5,29
    800037ee:	06c7c563          	blt	a5,a2,80003858 <log_write+0x90>
    800037f2:	00015797          	auipc	a5,0x15
    800037f6:	0fa7a783          	lw	a5,250(a5) # 800188ec <log+0x1c>
    800037fa:	37fd                	addiw	a5,a5,-1
    800037fc:	04f65e63          	bge	a2,a5,80003858 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003800:	00015797          	auipc	a5,0x15
    80003804:	0f07a783          	lw	a5,240(a5) # 800188f0 <log+0x20>
    80003808:	06f05063          	blez	a5,80003868 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000380c:	4781                	li	a5,0
    8000380e:	06c05563          	blez	a2,80003878 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003812:	44cc                	lw	a1,12(s1)
    80003814:	00015717          	auipc	a4,0x15
    80003818:	0ec70713          	addi	a4,a4,236 # 80018900 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000381c:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000381e:	4314                	lw	a3,0(a4)
    80003820:	04b68c63          	beq	a3,a1,80003878 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80003824:	2785                	addiw	a5,a5,1
    80003826:	0711                	addi	a4,a4,4
    80003828:	fef61be3          	bne	a2,a5,8000381e <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000382c:	0621                	addi	a2,a2,8
    8000382e:	060a                	slli	a2,a2,0x2
    80003830:	00015797          	auipc	a5,0x15
    80003834:	0a078793          	addi	a5,a5,160 # 800188d0 <log>
    80003838:	97b2                	add	a5,a5,a2
    8000383a:	44d8                	lw	a4,12(s1)
    8000383c:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000383e:	8526                	mv	a0,s1
    80003840:	fffff097          	auipc	ra,0xfffff
    80003844:	d9c080e7          	jalr	-612(ra) # 800025dc <bpin>
    log.lh.n++;
    80003848:	00015717          	auipc	a4,0x15
    8000384c:	08870713          	addi	a4,a4,136 # 800188d0 <log>
    80003850:	575c                	lw	a5,44(a4)
    80003852:	2785                	addiw	a5,a5,1
    80003854:	d75c                	sw	a5,44(a4)
    80003856:	a82d                	j	80003890 <log_write+0xc8>
    panic("too big a transaction");
    80003858:	00005517          	auipc	a0,0x5
    8000385c:	d6850513          	addi	a0,a0,-664 # 800085c0 <syscalls+0x1f0>
    80003860:	00002097          	auipc	ra,0x2
    80003864:	47c080e7          	jalr	1148(ra) # 80005cdc <panic>
    panic("log_write outside of trans");
    80003868:	00005517          	auipc	a0,0x5
    8000386c:	d7050513          	addi	a0,a0,-656 # 800085d8 <syscalls+0x208>
    80003870:	00002097          	auipc	ra,0x2
    80003874:	46c080e7          	jalr	1132(ra) # 80005cdc <panic>
  log.lh.block[i] = b->blockno;
    80003878:	00878693          	addi	a3,a5,8
    8000387c:	068a                	slli	a3,a3,0x2
    8000387e:	00015717          	auipc	a4,0x15
    80003882:	05270713          	addi	a4,a4,82 # 800188d0 <log>
    80003886:	9736                	add	a4,a4,a3
    80003888:	44d4                	lw	a3,12(s1)
    8000388a:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000388c:	faf609e3          	beq	a2,a5,8000383e <log_write+0x76>
  }
  release(&log.lock);
    80003890:	00015517          	auipc	a0,0x15
    80003894:	04050513          	addi	a0,a0,64 # 800188d0 <log>
    80003898:	00003097          	auipc	ra,0x3
    8000389c:	a30080e7          	jalr	-1488(ra) # 800062c8 <release>
}
    800038a0:	60e2                	ld	ra,24(sp)
    800038a2:	6442                	ld	s0,16(sp)
    800038a4:	64a2                	ld	s1,8(sp)
    800038a6:	6902                	ld	s2,0(sp)
    800038a8:	6105                	addi	sp,sp,32
    800038aa:	8082                	ret

00000000800038ac <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800038ac:	1101                	addi	sp,sp,-32
    800038ae:	ec06                	sd	ra,24(sp)
    800038b0:	e822                	sd	s0,16(sp)
    800038b2:	e426                	sd	s1,8(sp)
    800038b4:	e04a                	sd	s2,0(sp)
    800038b6:	1000                	addi	s0,sp,32
    800038b8:	84aa                	mv	s1,a0
    800038ba:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800038bc:	00005597          	auipc	a1,0x5
    800038c0:	d3c58593          	addi	a1,a1,-708 # 800085f8 <syscalls+0x228>
    800038c4:	0521                	addi	a0,a0,8
    800038c6:	00003097          	auipc	ra,0x3
    800038ca:	8be080e7          	jalr	-1858(ra) # 80006184 <initlock>
  lk->name = name;
    800038ce:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800038d2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800038d6:	0204a423          	sw	zero,40(s1)
}
    800038da:	60e2                	ld	ra,24(sp)
    800038dc:	6442                	ld	s0,16(sp)
    800038de:	64a2                	ld	s1,8(sp)
    800038e0:	6902                	ld	s2,0(sp)
    800038e2:	6105                	addi	sp,sp,32
    800038e4:	8082                	ret

00000000800038e6 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800038e6:	1101                	addi	sp,sp,-32
    800038e8:	ec06                	sd	ra,24(sp)
    800038ea:	e822                	sd	s0,16(sp)
    800038ec:	e426                	sd	s1,8(sp)
    800038ee:	e04a                	sd	s2,0(sp)
    800038f0:	1000                	addi	s0,sp,32
    800038f2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800038f4:	00850913          	addi	s2,a0,8
    800038f8:	854a                	mv	a0,s2
    800038fa:	00003097          	auipc	ra,0x3
    800038fe:	91a080e7          	jalr	-1766(ra) # 80006214 <acquire>
  while (lk->locked) {
    80003902:	409c                	lw	a5,0(s1)
    80003904:	cb89                	beqz	a5,80003916 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003906:	85ca                	mv	a1,s2
    80003908:	8526                	mv	a0,s1
    8000390a:	ffffe097          	auipc	ra,0xffffe
    8000390e:	c48080e7          	jalr	-952(ra) # 80001552 <sleep>
  while (lk->locked) {
    80003912:	409c                	lw	a5,0(s1)
    80003914:	fbed                	bnez	a5,80003906 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003916:	4785                	li	a5,1
    80003918:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	590080e7          	jalr	1424(ra) # 80000eaa <myproc>
    80003922:	591c                	lw	a5,48(a0)
    80003924:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003926:	854a                	mv	a0,s2
    80003928:	00003097          	auipc	ra,0x3
    8000392c:	9a0080e7          	jalr	-1632(ra) # 800062c8 <release>
}
    80003930:	60e2                	ld	ra,24(sp)
    80003932:	6442                	ld	s0,16(sp)
    80003934:	64a2                	ld	s1,8(sp)
    80003936:	6902                	ld	s2,0(sp)
    80003938:	6105                	addi	sp,sp,32
    8000393a:	8082                	ret

000000008000393c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000393c:	1101                	addi	sp,sp,-32
    8000393e:	ec06                	sd	ra,24(sp)
    80003940:	e822                	sd	s0,16(sp)
    80003942:	e426                	sd	s1,8(sp)
    80003944:	e04a                	sd	s2,0(sp)
    80003946:	1000                	addi	s0,sp,32
    80003948:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000394a:	00850913          	addi	s2,a0,8
    8000394e:	854a                	mv	a0,s2
    80003950:	00003097          	auipc	ra,0x3
    80003954:	8c4080e7          	jalr	-1852(ra) # 80006214 <acquire>
  lk->locked = 0;
    80003958:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000395c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003960:	8526                	mv	a0,s1
    80003962:	ffffe097          	auipc	ra,0xffffe
    80003966:	c54080e7          	jalr	-940(ra) # 800015b6 <wakeup>
  release(&lk->lk);
    8000396a:	854a                	mv	a0,s2
    8000396c:	00003097          	auipc	ra,0x3
    80003970:	95c080e7          	jalr	-1700(ra) # 800062c8 <release>
}
    80003974:	60e2                	ld	ra,24(sp)
    80003976:	6442                	ld	s0,16(sp)
    80003978:	64a2                	ld	s1,8(sp)
    8000397a:	6902                	ld	s2,0(sp)
    8000397c:	6105                	addi	sp,sp,32
    8000397e:	8082                	ret

0000000080003980 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003980:	7179                	addi	sp,sp,-48
    80003982:	f406                	sd	ra,40(sp)
    80003984:	f022                	sd	s0,32(sp)
    80003986:	ec26                	sd	s1,24(sp)
    80003988:	e84a                	sd	s2,16(sp)
    8000398a:	e44e                	sd	s3,8(sp)
    8000398c:	1800                	addi	s0,sp,48
    8000398e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003990:	00850913          	addi	s2,a0,8
    80003994:	854a                	mv	a0,s2
    80003996:	00003097          	auipc	ra,0x3
    8000399a:	87e080e7          	jalr	-1922(ra) # 80006214 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000399e:	409c                	lw	a5,0(s1)
    800039a0:	ef99                	bnez	a5,800039be <holdingsleep+0x3e>
    800039a2:	4481                	li	s1,0
  release(&lk->lk);
    800039a4:	854a                	mv	a0,s2
    800039a6:	00003097          	auipc	ra,0x3
    800039aa:	922080e7          	jalr	-1758(ra) # 800062c8 <release>
  return r;
}
    800039ae:	8526                	mv	a0,s1
    800039b0:	70a2                	ld	ra,40(sp)
    800039b2:	7402                	ld	s0,32(sp)
    800039b4:	64e2                	ld	s1,24(sp)
    800039b6:	6942                	ld	s2,16(sp)
    800039b8:	69a2                	ld	s3,8(sp)
    800039ba:	6145                	addi	sp,sp,48
    800039bc:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800039be:	0284a983          	lw	s3,40(s1)
    800039c2:	ffffd097          	auipc	ra,0xffffd
    800039c6:	4e8080e7          	jalr	1256(ra) # 80000eaa <myproc>
    800039ca:	5904                	lw	s1,48(a0)
    800039cc:	413484b3          	sub	s1,s1,s3
    800039d0:	0014b493          	seqz	s1,s1
    800039d4:	bfc1                	j	800039a4 <holdingsleep+0x24>

00000000800039d6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800039d6:	1141                	addi	sp,sp,-16
    800039d8:	e406                	sd	ra,8(sp)
    800039da:	e022                	sd	s0,0(sp)
    800039dc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800039de:	00005597          	auipc	a1,0x5
    800039e2:	c2a58593          	addi	a1,a1,-982 # 80008608 <syscalls+0x238>
    800039e6:	00015517          	auipc	a0,0x15
    800039ea:	03250513          	addi	a0,a0,50 # 80018a18 <ftable>
    800039ee:	00002097          	auipc	ra,0x2
    800039f2:	796080e7          	jalr	1942(ra) # 80006184 <initlock>
}
    800039f6:	60a2                	ld	ra,8(sp)
    800039f8:	6402                	ld	s0,0(sp)
    800039fa:	0141                	addi	sp,sp,16
    800039fc:	8082                	ret

00000000800039fe <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800039fe:	1101                	addi	sp,sp,-32
    80003a00:	ec06                	sd	ra,24(sp)
    80003a02:	e822                	sd	s0,16(sp)
    80003a04:	e426                	sd	s1,8(sp)
    80003a06:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003a08:	00015517          	auipc	a0,0x15
    80003a0c:	01050513          	addi	a0,a0,16 # 80018a18 <ftable>
    80003a10:	00003097          	auipc	ra,0x3
    80003a14:	804080e7          	jalr	-2044(ra) # 80006214 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003a18:	00015497          	auipc	s1,0x15
    80003a1c:	01848493          	addi	s1,s1,24 # 80018a30 <ftable+0x18>
    80003a20:	00016717          	auipc	a4,0x16
    80003a24:	fb070713          	addi	a4,a4,-80 # 800199d0 <disk>
    if(f->ref == 0){
    80003a28:	40dc                	lw	a5,4(s1)
    80003a2a:	cf99                	beqz	a5,80003a48 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003a2c:	02848493          	addi	s1,s1,40
    80003a30:	fee49ce3          	bne	s1,a4,80003a28 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003a34:	00015517          	auipc	a0,0x15
    80003a38:	fe450513          	addi	a0,a0,-28 # 80018a18 <ftable>
    80003a3c:	00003097          	auipc	ra,0x3
    80003a40:	88c080e7          	jalr	-1908(ra) # 800062c8 <release>
  return 0;
    80003a44:	4481                	li	s1,0
    80003a46:	a819                	j	80003a5c <filealloc+0x5e>
      f->ref = 1;
    80003a48:	4785                	li	a5,1
    80003a4a:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003a4c:	00015517          	auipc	a0,0x15
    80003a50:	fcc50513          	addi	a0,a0,-52 # 80018a18 <ftable>
    80003a54:	00003097          	auipc	ra,0x3
    80003a58:	874080e7          	jalr	-1932(ra) # 800062c8 <release>
}
    80003a5c:	8526                	mv	a0,s1
    80003a5e:	60e2                	ld	ra,24(sp)
    80003a60:	6442                	ld	s0,16(sp)
    80003a62:	64a2                	ld	s1,8(sp)
    80003a64:	6105                	addi	sp,sp,32
    80003a66:	8082                	ret

0000000080003a68 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003a68:	1101                	addi	sp,sp,-32
    80003a6a:	ec06                	sd	ra,24(sp)
    80003a6c:	e822                	sd	s0,16(sp)
    80003a6e:	e426                	sd	s1,8(sp)
    80003a70:	1000                	addi	s0,sp,32
    80003a72:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003a74:	00015517          	auipc	a0,0x15
    80003a78:	fa450513          	addi	a0,a0,-92 # 80018a18 <ftable>
    80003a7c:	00002097          	auipc	ra,0x2
    80003a80:	798080e7          	jalr	1944(ra) # 80006214 <acquire>
  if(f->ref < 1)
    80003a84:	40dc                	lw	a5,4(s1)
    80003a86:	02f05263          	blez	a5,80003aaa <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003a8a:	2785                	addiw	a5,a5,1
    80003a8c:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003a8e:	00015517          	auipc	a0,0x15
    80003a92:	f8a50513          	addi	a0,a0,-118 # 80018a18 <ftable>
    80003a96:	00003097          	auipc	ra,0x3
    80003a9a:	832080e7          	jalr	-1998(ra) # 800062c8 <release>
  return f;
}
    80003a9e:	8526                	mv	a0,s1
    80003aa0:	60e2                	ld	ra,24(sp)
    80003aa2:	6442                	ld	s0,16(sp)
    80003aa4:	64a2                	ld	s1,8(sp)
    80003aa6:	6105                	addi	sp,sp,32
    80003aa8:	8082                	ret
    panic("filedup");
    80003aaa:	00005517          	auipc	a0,0x5
    80003aae:	b6650513          	addi	a0,a0,-1178 # 80008610 <syscalls+0x240>
    80003ab2:	00002097          	auipc	ra,0x2
    80003ab6:	22a080e7          	jalr	554(ra) # 80005cdc <panic>

0000000080003aba <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003aba:	7139                	addi	sp,sp,-64
    80003abc:	fc06                	sd	ra,56(sp)
    80003abe:	f822                	sd	s0,48(sp)
    80003ac0:	f426                	sd	s1,40(sp)
    80003ac2:	f04a                	sd	s2,32(sp)
    80003ac4:	ec4e                	sd	s3,24(sp)
    80003ac6:	e852                	sd	s4,16(sp)
    80003ac8:	e456                	sd	s5,8(sp)
    80003aca:	0080                	addi	s0,sp,64
    80003acc:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003ace:	00015517          	auipc	a0,0x15
    80003ad2:	f4a50513          	addi	a0,a0,-182 # 80018a18 <ftable>
    80003ad6:	00002097          	auipc	ra,0x2
    80003ada:	73e080e7          	jalr	1854(ra) # 80006214 <acquire>
  if(f->ref < 1)
    80003ade:	40dc                	lw	a5,4(s1)
    80003ae0:	06f05163          	blez	a5,80003b42 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003ae4:	37fd                	addiw	a5,a5,-1
    80003ae6:	0007871b          	sext.w	a4,a5
    80003aea:	c0dc                	sw	a5,4(s1)
    80003aec:	06e04363          	bgtz	a4,80003b52 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003af0:	0004a903          	lw	s2,0(s1)
    80003af4:	0094ca83          	lbu	s5,9(s1)
    80003af8:	0104ba03          	ld	s4,16(s1)
    80003afc:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003b00:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003b04:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003b08:	00015517          	auipc	a0,0x15
    80003b0c:	f1050513          	addi	a0,a0,-240 # 80018a18 <ftable>
    80003b10:	00002097          	auipc	ra,0x2
    80003b14:	7b8080e7          	jalr	1976(ra) # 800062c8 <release>

  if(ff.type == FD_PIPE){
    80003b18:	4785                	li	a5,1
    80003b1a:	04f90d63          	beq	s2,a5,80003b74 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003b1e:	3979                	addiw	s2,s2,-2
    80003b20:	4785                	li	a5,1
    80003b22:	0527e063          	bltu	a5,s2,80003b62 <fileclose+0xa8>
    begin_op();
    80003b26:	00000097          	auipc	ra,0x0
    80003b2a:	acc080e7          	jalr	-1332(ra) # 800035f2 <begin_op>
    iput(ff.ip);
    80003b2e:	854e                	mv	a0,s3
    80003b30:	fffff097          	auipc	ra,0xfffff
    80003b34:	2b0080e7          	jalr	688(ra) # 80002de0 <iput>
    end_op();
    80003b38:	00000097          	auipc	ra,0x0
    80003b3c:	b38080e7          	jalr	-1224(ra) # 80003670 <end_op>
    80003b40:	a00d                	j	80003b62 <fileclose+0xa8>
    panic("fileclose");
    80003b42:	00005517          	auipc	a0,0x5
    80003b46:	ad650513          	addi	a0,a0,-1322 # 80008618 <syscalls+0x248>
    80003b4a:	00002097          	auipc	ra,0x2
    80003b4e:	192080e7          	jalr	402(ra) # 80005cdc <panic>
    release(&ftable.lock);
    80003b52:	00015517          	auipc	a0,0x15
    80003b56:	ec650513          	addi	a0,a0,-314 # 80018a18 <ftable>
    80003b5a:	00002097          	auipc	ra,0x2
    80003b5e:	76e080e7          	jalr	1902(ra) # 800062c8 <release>
  }
}
    80003b62:	70e2                	ld	ra,56(sp)
    80003b64:	7442                	ld	s0,48(sp)
    80003b66:	74a2                	ld	s1,40(sp)
    80003b68:	7902                	ld	s2,32(sp)
    80003b6a:	69e2                	ld	s3,24(sp)
    80003b6c:	6a42                	ld	s4,16(sp)
    80003b6e:	6aa2                	ld	s5,8(sp)
    80003b70:	6121                	addi	sp,sp,64
    80003b72:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003b74:	85d6                	mv	a1,s5
    80003b76:	8552                	mv	a0,s4
    80003b78:	00000097          	auipc	ra,0x0
    80003b7c:	34c080e7          	jalr	844(ra) # 80003ec4 <pipeclose>
    80003b80:	b7cd                	j	80003b62 <fileclose+0xa8>

0000000080003b82 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003b82:	715d                	addi	sp,sp,-80
    80003b84:	e486                	sd	ra,72(sp)
    80003b86:	e0a2                	sd	s0,64(sp)
    80003b88:	fc26                	sd	s1,56(sp)
    80003b8a:	f84a                	sd	s2,48(sp)
    80003b8c:	f44e                	sd	s3,40(sp)
    80003b8e:	0880                	addi	s0,sp,80
    80003b90:	84aa                	mv	s1,a0
    80003b92:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003b94:	ffffd097          	auipc	ra,0xffffd
    80003b98:	316080e7          	jalr	790(ra) # 80000eaa <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003b9c:	409c                	lw	a5,0(s1)
    80003b9e:	37f9                	addiw	a5,a5,-2
    80003ba0:	4705                	li	a4,1
    80003ba2:	04f76763          	bltu	a4,a5,80003bf0 <filestat+0x6e>
    80003ba6:	892a                	mv	s2,a0
    ilock(f->ip);
    80003ba8:	6c88                	ld	a0,24(s1)
    80003baa:	fffff097          	auipc	ra,0xfffff
    80003bae:	07c080e7          	jalr	124(ra) # 80002c26 <ilock>
    stati(f->ip, &st);
    80003bb2:	fb840593          	addi	a1,s0,-72
    80003bb6:	6c88                	ld	a0,24(s1)
    80003bb8:	fffff097          	auipc	ra,0xfffff
    80003bbc:	2f8080e7          	jalr	760(ra) # 80002eb0 <stati>
    iunlock(f->ip);
    80003bc0:	6c88                	ld	a0,24(s1)
    80003bc2:	fffff097          	auipc	ra,0xfffff
    80003bc6:	126080e7          	jalr	294(ra) # 80002ce8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003bca:	46e1                	li	a3,24
    80003bcc:	fb840613          	addi	a2,s0,-72
    80003bd0:	85ce                	mv	a1,s3
    80003bd2:	05093503          	ld	a0,80(s2)
    80003bd6:	ffffd097          	auipc	ra,0xffffd
    80003bda:	f94080e7          	jalr	-108(ra) # 80000b6a <copyout>
    80003bde:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003be2:	60a6                	ld	ra,72(sp)
    80003be4:	6406                	ld	s0,64(sp)
    80003be6:	74e2                	ld	s1,56(sp)
    80003be8:	7942                	ld	s2,48(sp)
    80003bea:	79a2                	ld	s3,40(sp)
    80003bec:	6161                	addi	sp,sp,80
    80003bee:	8082                	ret
  return -1;
    80003bf0:	557d                	li	a0,-1
    80003bf2:	bfc5                	j	80003be2 <filestat+0x60>

0000000080003bf4 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003bf4:	7179                	addi	sp,sp,-48
    80003bf6:	f406                	sd	ra,40(sp)
    80003bf8:	f022                	sd	s0,32(sp)
    80003bfa:	ec26                	sd	s1,24(sp)
    80003bfc:	e84a                	sd	s2,16(sp)
    80003bfe:	e44e                	sd	s3,8(sp)
    80003c00:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003c02:	00854783          	lbu	a5,8(a0)
    80003c06:	c3d5                	beqz	a5,80003caa <fileread+0xb6>
    80003c08:	84aa                	mv	s1,a0
    80003c0a:	89ae                	mv	s3,a1
    80003c0c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003c0e:	411c                	lw	a5,0(a0)
    80003c10:	4705                	li	a4,1
    80003c12:	04e78963          	beq	a5,a4,80003c64 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003c16:	470d                	li	a4,3
    80003c18:	04e78d63          	beq	a5,a4,80003c72 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003c1c:	4709                	li	a4,2
    80003c1e:	06e79e63          	bne	a5,a4,80003c9a <fileread+0xa6>
    ilock(f->ip);
    80003c22:	6d08                	ld	a0,24(a0)
    80003c24:	fffff097          	auipc	ra,0xfffff
    80003c28:	002080e7          	jalr	2(ra) # 80002c26 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003c2c:	874a                	mv	a4,s2
    80003c2e:	5094                	lw	a3,32(s1)
    80003c30:	864e                	mv	a2,s3
    80003c32:	4585                	li	a1,1
    80003c34:	6c88                	ld	a0,24(s1)
    80003c36:	fffff097          	auipc	ra,0xfffff
    80003c3a:	2a4080e7          	jalr	676(ra) # 80002eda <readi>
    80003c3e:	892a                	mv	s2,a0
    80003c40:	00a05563          	blez	a0,80003c4a <fileread+0x56>
      f->off += r;
    80003c44:	509c                	lw	a5,32(s1)
    80003c46:	9fa9                	addw	a5,a5,a0
    80003c48:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003c4a:	6c88                	ld	a0,24(s1)
    80003c4c:	fffff097          	auipc	ra,0xfffff
    80003c50:	09c080e7          	jalr	156(ra) # 80002ce8 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003c54:	854a                	mv	a0,s2
    80003c56:	70a2                	ld	ra,40(sp)
    80003c58:	7402                	ld	s0,32(sp)
    80003c5a:	64e2                	ld	s1,24(sp)
    80003c5c:	6942                	ld	s2,16(sp)
    80003c5e:	69a2                	ld	s3,8(sp)
    80003c60:	6145                	addi	sp,sp,48
    80003c62:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003c64:	6908                	ld	a0,16(a0)
    80003c66:	00000097          	auipc	ra,0x0
    80003c6a:	3c6080e7          	jalr	966(ra) # 8000402c <piperead>
    80003c6e:	892a                	mv	s2,a0
    80003c70:	b7d5                	j	80003c54 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003c72:	02451783          	lh	a5,36(a0)
    80003c76:	03079693          	slli	a3,a5,0x30
    80003c7a:	92c1                	srli	a3,a3,0x30
    80003c7c:	4725                	li	a4,9
    80003c7e:	02d76863          	bltu	a4,a3,80003cae <fileread+0xba>
    80003c82:	0792                	slli	a5,a5,0x4
    80003c84:	00015717          	auipc	a4,0x15
    80003c88:	cf470713          	addi	a4,a4,-780 # 80018978 <devsw>
    80003c8c:	97ba                	add	a5,a5,a4
    80003c8e:	639c                	ld	a5,0(a5)
    80003c90:	c38d                	beqz	a5,80003cb2 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003c92:	4505                	li	a0,1
    80003c94:	9782                	jalr	a5
    80003c96:	892a                	mv	s2,a0
    80003c98:	bf75                	j	80003c54 <fileread+0x60>
    panic("fileread");
    80003c9a:	00005517          	auipc	a0,0x5
    80003c9e:	98e50513          	addi	a0,a0,-1650 # 80008628 <syscalls+0x258>
    80003ca2:	00002097          	auipc	ra,0x2
    80003ca6:	03a080e7          	jalr	58(ra) # 80005cdc <panic>
    return -1;
    80003caa:	597d                	li	s2,-1
    80003cac:	b765                	j	80003c54 <fileread+0x60>
      return -1;
    80003cae:	597d                	li	s2,-1
    80003cb0:	b755                	j	80003c54 <fileread+0x60>
    80003cb2:	597d                	li	s2,-1
    80003cb4:	b745                	j	80003c54 <fileread+0x60>

0000000080003cb6 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003cb6:	715d                	addi	sp,sp,-80
    80003cb8:	e486                	sd	ra,72(sp)
    80003cba:	e0a2                	sd	s0,64(sp)
    80003cbc:	fc26                	sd	s1,56(sp)
    80003cbe:	f84a                	sd	s2,48(sp)
    80003cc0:	f44e                	sd	s3,40(sp)
    80003cc2:	f052                	sd	s4,32(sp)
    80003cc4:	ec56                	sd	s5,24(sp)
    80003cc6:	e85a                	sd	s6,16(sp)
    80003cc8:	e45e                	sd	s7,8(sp)
    80003cca:	e062                	sd	s8,0(sp)
    80003ccc:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003cce:	00954783          	lbu	a5,9(a0)
    80003cd2:	10078663          	beqz	a5,80003dde <filewrite+0x128>
    80003cd6:	892a                	mv	s2,a0
    80003cd8:	8b2e                	mv	s6,a1
    80003cda:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003cdc:	411c                	lw	a5,0(a0)
    80003cde:	4705                	li	a4,1
    80003ce0:	02e78263          	beq	a5,a4,80003d04 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003ce4:	470d                	li	a4,3
    80003ce6:	02e78663          	beq	a5,a4,80003d12 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003cea:	4709                	li	a4,2
    80003cec:	0ee79163          	bne	a5,a4,80003dce <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003cf0:	0ac05d63          	blez	a2,80003daa <filewrite+0xf4>
    int i = 0;
    80003cf4:	4981                	li	s3,0
    80003cf6:	6b85                	lui	s7,0x1
    80003cf8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003cfc:	6c05                	lui	s8,0x1
    80003cfe:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003d02:	a861                	j	80003d9a <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003d04:	6908                	ld	a0,16(a0)
    80003d06:	00000097          	auipc	ra,0x0
    80003d0a:	22e080e7          	jalr	558(ra) # 80003f34 <pipewrite>
    80003d0e:	8a2a                	mv	s4,a0
    80003d10:	a045                	j	80003db0 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003d12:	02451783          	lh	a5,36(a0)
    80003d16:	03079693          	slli	a3,a5,0x30
    80003d1a:	92c1                	srli	a3,a3,0x30
    80003d1c:	4725                	li	a4,9
    80003d1e:	0cd76263          	bltu	a4,a3,80003de2 <filewrite+0x12c>
    80003d22:	0792                	slli	a5,a5,0x4
    80003d24:	00015717          	auipc	a4,0x15
    80003d28:	c5470713          	addi	a4,a4,-940 # 80018978 <devsw>
    80003d2c:	97ba                	add	a5,a5,a4
    80003d2e:	679c                	ld	a5,8(a5)
    80003d30:	cbdd                	beqz	a5,80003de6 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003d32:	4505                	li	a0,1
    80003d34:	9782                	jalr	a5
    80003d36:	8a2a                	mv	s4,a0
    80003d38:	a8a5                	j	80003db0 <filewrite+0xfa>
    80003d3a:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003d3e:	00000097          	auipc	ra,0x0
    80003d42:	8b4080e7          	jalr	-1868(ra) # 800035f2 <begin_op>
      ilock(f->ip);
    80003d46:	01893503          	ld	a0,24(s2)
    80003d4a:	fffff097          	auipc	ra,0xfffff
    80003d4e:	edc080e7          	jalr	-292(ra) # 80002c26 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003d52:	8756                	mv	a4,s5
    80003d54:	02092683          	lw	a3,32(s2)
    80003d58:	01698633          	add	a2,s3,s6
    80003d5c:	4585                	li	a1,1
    80003d5e:	01893503          	ld	a0,24(s2)
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	270080e7          	jalr	624(ra) # 80002fd2 <writei>
    80003d6a:	84aa                	mv	s1,a0
    80003d6c:	00a05763          	blez	a0,80003d7a <filewrite+0xc4>
        f->off += r;
    80003d70:	02092783          	lw	a5,32(s2)
    80003d74:	9fa9                	addw	a5,a5,a0
    80003d76:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003d7a:	01893503          	ld	a0,24(s2)
    80003d7e:	fffff097          	auipc	ra,0xfffff
    80003d82:	f6a080e7          	jalr	-150(ra) # 80002ce8 <iunlock>
      end_op();
    80003d86:	00000097          	auipc	ra,0x0
    80003d8a:	8ea080e7          	jalr	-1814(ra) # 80003670 <end_op>

      if(r != n1){
    80003d8e:	009a9f63          	bne	s5,s1,80003dac <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003d92:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003d96:	0149db63          	bge	s3,s4,80003dac <filewrite+0xf6>
      int n1 = n - i;
    80003d9a:	413a04bb          	subw	s1,s4,s3
    80003d9e:	0004879b          	sext.w	a5,s1
    80003da2:	f8fbdce3          	bge	s7,a5,80003d3a <filewrite+0x84>
    80003da6:	84e2                	mv	s1,s8
    80003da8:	bf49                	j	80003d3a <filewrite+0x84>
    int i = 0;
    80003daa:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003dac:	013a1f63          	bne	s4,s3,80003dca <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003db0:	8552                	mv	a0,s4
    80003db2:	60a6                	ld	ra,72(sp)
    80003db4:	6406                	ld	s0,64(sp)
    80003db6:	74e2                	ld	s1,56(sp)
    80003db8:	7942                	ld	s2,48(sp)
    80003dba:	79a2                	ld	s3,40(sp)
    80003dbc:	7a02                	ld	s4,32(sp)
    80003dbe:	6ae2                	ld	s5,24(sp)
    80003dc0:	6b42                	ld	s6,16(sp)
    80003dc2:	6ba2                	ld	s7,8(sp)
    80003dc4:	6c02                	ld	s8,0(sp)
    80003dc6:	6161                	addi	sp,sp,80
    80003dc8:	8082                	ret
    ret = (i == n ? n : -1);
    80003dca:	5a7d                	li	s4,-1
    80003dcc:	b7d5                	j	80003db0 <filewrite+0xfa>
    panic("filewrite");
    80003dce:	00005517          	auipc	a0,0x5
    80003dd2:	86a50513          	addi	a0,a0,-1942 # 80008638 <syscalls+0x268>
    80003dd6:	00002097          	auipc	ra,0x2
    80003dda:	f06080e7          	jalr	-250(ra) # 80005cdc <panic>
    return -1;
    80003dde:	5a7d                	li	s4,-1
    80003de0:	bfc1                	j	80003db0 <filewrite+0xfa>
      return -1;
    80003de2:	5a7d                	li	s4,-1
    80003de4:	b7f1                	j	80003db0 <filewrite+0xfa>
    80003de6:	5a7d                	li	s4,-1
    80003de8:	b7e1                	j	80003db0 <filewrite+0xfa>

0000000080003dea <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003dea:	7179                	addi	sp,sp,-48
    80003dec:	f406                	sd	ra,40(sp)
    80003dee:	f022                	sd	s0,32(sp)
    80003df0:	ec26                	sd	s1,24(sp)
    80003df2:	e84a                	sd	s2,16(sp)
    80003df4:	e44e                	sd	s3,8(sp)
    80003df6:	e052                	sd	s4,0(sp)
    80003df8:	1800                	addi	s0,sp,48
    80003dfa:	84aa                	mv	s1,a0
    80003dfc:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003dfe:	0005b023          	sd	zero,0(a1)
    80003e02:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	bf8080e7          	jalr	-1032(ra) # 800039fe <filealloc>
    80003e0e:	e088                	sd	a0,0(s1)
    80003e10:	c551                	beqz	a0,80003e9c <pipealloc+0xb2>
    80003e12:	00000097          	auipc	ra,0x0
    80003e16:	bec080e7          	jalr	-1044(ra) # 800039fe <filealloc>
    80003e1a:	00aa3023          	sd	a0,0(s4)
    80003e1e:	c92d                	beqz	a0,80003e90 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003e20:	ffffc097          	auipc	ra,0xffffc
    80003e24:	2fa080e7          	jalr	762(ra) # 8000011a <kalloc>
    80003e28:	892a                	mv	s2,a0
    80003e2a:	c125                	beqz	a0,80003e8a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003e2c:	4985                	li	s3,1
    80003e2e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003e32:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003e36:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003e3a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003e3e:	00005597          	auipc	a1,0x5
    80003e42:	80a58593          	addi	a1,a1,-2038 # 80008648 <syscalls+0x278>
    80003e46:	00002097          	auipc	ra,0x2
    80003e4a:	33e080e7          	jalr	830(ra) # 80006184 <initlock>
  (*f0)->type = FD_PIPE;
    80003e4e:	609c                	ld	a5,0(s1)
    80003e50:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003e54:	609c                	ld	a5,0(s1)
    80003e56:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003e5a:	609c                	ld	a5,0(s1)
    80003e5c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003e60:	609c                	ld	a5,0(s1)
    80003e62:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003e66:	000a3783          	ld	a5,0(s4)
    80003e6a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003e6e:	000a3783          	ld	a5,0(s4)
    80003e72:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003e76:	000a3783          	ld	a5,0(s4)
    80003e7a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003e7e:	000a3783          	ld	a5,0(s4)
    80003e82:	0127b823          	sd	s2,16(a5)
  return 0;
    80003e86:	4501                	li	a0,0
    80003e88:	a025                	j	80003eb0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003e8a:	6088                	ld	a0,0(s1)
    80003e8c:	e501                	bnez	a0,80003e94 <pipealloc+0xaa>
    80003e8e:	a039                	j	80003e9c <pipealloc+0xb2>
    80003e90:	6088                	ld	a0,0(s1)
    80003e92:	c51d                	beqz	a0,80003ec0 <pipealloc+0xd6>
    fileclose(*f0);
    80003e94:	00000097          	auipc	ra,0x0
    80003e98:	c26080e7          	jalr	-986(ra) # 80003aba <fileclose>
  if(*f1)
    80003e9c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003ea0:	557d                	li	a0,-1
  if(*f1)
    80003ea2:	c799                	beqz	a5,80003eb0 <pipealloc+0xc6>
    fileclose(*f1);
    80003ea4:	853e                	mv	a0,a5
    80003ea6:	00000097          	auipc	ra,0x0
    80003eaa:	c14080e7          	jalr	-1004(ra) # 80003aba <fileclose>
  return -1;
    80003eae:	557d                	li	a0,-1
}
    80003eb0:	70a2                	ld	ra,40(sp)
    80003eb2:	7402                	ld	s0,32(sp)
    80003eb4:	64e2                	ld	s1,24(sp)
    80003eb6:	6942                	ld	s2,16(sp)
    80003eb8:	69a2                	ld	s3,8(sp)
    80003eba:	6a02                	ld	s4,0(sp)
    80003ebc:	6145                	addi	sp,sp,48
    80003ebe:	8082                	ret
  return -1;
    80003ec0:	557d                	li	a0,-1
    80003ec2:	b7fd                	j	80003eb0 <pipealloc+0xc6>

0000000080003ec4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003ec4:	1101                	addi	sp,sp,-32
    80003ec6:	ec06                	sd	ra,24(sp)
    80003ec8:	e822                	sd	s0,16(sp)
    80003eca:	e426                	sd	s1,8(sp)
    80003ecc:	e04a                	sd	s2,0(sp)
    80003ece:	1000                	addi	s0,sp,32
    80003ed0:	84aa                	mv	s1,a0
    80003ed2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003ed4:	00002097          	auipc	ra,0x2
    80003ed8:	340080e7          	jalr	832(ra) # 80006214 <acquire>
  if(writable){
    80003edc:	02090d63          	beqz	s2,80003f16 <pipeclose+0x52>
    pi->writeopen = 0;
    80003ee0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003ee4:	21848513          	addi	a0,s1,536
    80003ee8:	ffffd097          	auipc	ra,0xffffd
    80003eec:	6ce080e7          	jalr	1742(ra) # 800015b6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003ef0:	2204b783          	ld	a5,544(s1)
    80003ef4:	eb95                	bnez	a5,80003f28 <pipeclose+0x64>
    release(&pi->lock);
    80003ef6:	8526                	mv	a0,s1
    80003ef8:	00002097          	auipc	ra,0x2
    80003efc:	3d0080e7          	jalr	976(ra) # 800062c8 <release>
    kfree((char*)pi);
    80003f00:	8526                	mv	a0,s1
    80003f02:	ffffc097          	auipc	ra,0xffffc
    80003f06:	11a080e7          	jalr	282(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003f0a:	60e2                	ld	ra,24(sp)
    80003f0c:	6442                	ld	s0,16(sp)
    80003f0e:	64a2                	ld	s1,8(sp)
    80003f10:	6902                	ld	s2,0(sp)
    80003f12:	6105                	addi	sp,sp,32
    80003f14:	8082                	ret
    pi->readopen = 0;
    80003f16:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003f1a:	21c48513          	addi	a0,s1,540
    80003f1e:	ffffd097          	auipc	ra,0xffffd
    80003f22:	698080e7          	jalr	1688(ra) # 800015b6 <wakeup>
    80003f26:	b7e9                	j	80003ef0 <pipeclose+0x2c>
    release(&pi->lock);
    80003f28:	8526                	mv	a0,s1
    80003f2a:	00002097          	auipc	ra,0x2
    80003f2e:	39e080e7          	jalr	926(ra) # 800062c8 <release>
}
    80003f32:	bfe1                	j	80003f0a <pipeclose+0x46>

0000000080003f34 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003f34:	711d                	addi	sp,sp,-96
    80003f36:	ec86                	sd	ra,88(sp)
    80003f38:	e8a2                	sd	s0,80(sp)
    80003f3a:	e4a6                	sd	s1,72(sp)
    80003f3c:	e0ca                	sd	s2,64(sp)
    80003f3e:	fc4e                	sd	s3,56(sp)
    80003f40:	f852                	sd	s4,48(sp)
    80003f42:	f456                	sd	s5,40(sp)
    80003f44:	f05a                	sd	s6,32(sp)
    80003f46:	ec5e                	sd	s7,24(sp)
    80003f48:	e862                	sd	s8,16(sp)
    80003f4a:	1080                	addi	s0,sp,96
    80003f4c:	84aa                	mv	s1,a0
    80003f4e:	8aae                	mv	s5,a1
    80003f50:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003f52:	ffffd097          	auipc	ra,0xffffd
    80003f56:	f58080e7          	jalr	-168(ra) # 80000eaa <myproc>
    80003f5a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003f5c:	8526                	mv	a0,s1
    80003f5e:	00002097          	auipc	ra,0x2
    80003f62:	2b6080e7          	jalr	694(ra) # 80006214 <acquire>
  while(i < n){
    80003f66:	0b405663          	blez	s4,80004012 <pipewrite+0xde>
  int i = 0;
    80003f6a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f6c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003f6e:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003f72:	21c48b93          	addi	s7,s1,540
    80003f76:	a089                	j	80003fb8 <pipewrite+0x84>
      release(&pi->lock);
    80003f78:	8526                	mv	a0,s1
    80003f7a:	00002097          	auipc	ra,0x2
    80003f7e:	34e080e7          	jalr	846(ra) # 800062c8 <release>
      return -1;
    80003f82:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003f84:	854a                	mv	a0,s2
    80003f86:	60e6                	ld	ra,88(sp)
    80003f88:	6446                	ld	s0,80(sp)
    80003f8a:	64a6                	ld	s1,72(sp)
    80003f8c:	6906                	ld	s2,64(sp)
    80003f8e:	79e2                	ld	s3,56(sp)
    80003f90:	7a42                	ld	s4,48(sp)
    80003f92:	7aa2                	ld	s5,40(sp)
    80003f94:	7b02                	ld	s6,32(sp)
    80003f96:	6be2                	ld	s7,24(sp)
    80003f98:	6c42                	ld	s8,16(sp)
    80003f9a:	6125                	addi	sp,sp,96
    80003f9c:	8082                	ret
      wakeup(&pi->nread);
    80003f9e:	8562                	mv	a0,s8
    80003fa0:	ffffd097          	auipc	ra,0xffffd
    80003fa4:	616080e7          	jalr	1558(ra) # 800015b6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003fa8:	85a6                	mv	a1,s1
    80003faa:	855e                	mv	a0,s7
    80003fac:	ffffd097          	auipc	ra,0xffffd
    80003fb0:	5a6080e7          	jalr	1446(ra) # 80001552 <sleep>
  while(i < n){
    80003fb4:	07495063          	bge	s2,s4,80004014 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80003fb8:	2204a783          	lw	a5,544(s1)
    80003fbc:	dfd5                	beqz	a5,80003f78 <pipewrite+0x44>
    80003fbe:	854e                	mv	a0,s3
    80003fc0:	ffffe097          	auipc	ra,0xffffe
    80003fc4:	83a080e7          	jalr	-1990(ra) # 800017fa <killed>
    80003fc8:	f945                	bnez	a0,80003f78 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003fca:	2184a783          	lw	a5,536(s1)
    80003fce:	21c4a703          	lw	a4,540(s1)
    80003fd2:	2007879b          	addiw	a5,a5,512
    80003fd6:	fcf704e3          	beq	a4,a5,80003f9e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003fda:	4685                	li	a3,1
    80003fdc:	01590633          	add	a2,s2,s5
    80003fe0:	faf40593          	addi	a1,s0,-81
    80003fe4:	0509b503          	ld	a0,80(s3)
    80003fe8:	ffffd097          	auipc	ra,0xffffd
    80003fec:	c0e080e7          	jalr	-1010(ra) # 80000bf6 <copyin>
    80003ff0:	03650263          	beq	a0,s6,80004014 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003ff4:	21c4a783          	lw	a5,540(s1)
    80003ff8:	0017871b          	addiw	a4,a5,1
    80003ffc:	20e4ae23          	sw	a4,540(s1)
    80004000:	1ff7f793          	andi	a5,a5,511
    80004004:	97a6                	add	a5,a5,s1
    80004006:	faf44703          	lbu	a4,-81(s0)
    8000400a:	00e78c23          	sb	a4,24(a5)
      i++;
    8000400e:	2905                	addiw	s2,s2,1
    80004010:	b755                	j	80003fb4 <pipewrite+0x80>
  int i = 0;
    80004012:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004014:	21848513          	addi	a0,s1,536
    80004018:	ffffd097          	auipc	ra,0xffffd
    8000401c:	59e080e7          	jalr	1438(ra) # 800015b6 <wakeup>
  release(&pi->lock);
    80004020:	8526                	mv	a0,s1
    80004022:	00002097          	auipc	ra,0x2
    80004026:	2a6080e7          	jalr	678(ra) # 800062c8 <release>
  return i;
    8000402a:	bfa9                	j	80003f84 <pipewrite+0x50>

000000008000402c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000402c:	715d                	addi	sp,sp,-80
    8000402e:	e486                	sd	ra,72(sp)
    80004030:	e0a2                	sd	s0,64(sp)
    80004032:	fc26                	sd	s1,56(sp)
    80004034:	f84a                	sd	s2,48(sp)
    80004036:	f44e                	sd	s3,40(sp)
    80004038:	f052                	sd	s4,32(sp)
    8000403a:	ec56                	sd	s5,24(sp)
    8000403c:	e85a                	sd	s6,16(sp)
    8000403e:	0880                	addi	s0,sp,80
    80004040:	84aa                	mv	s1,a0
    80004042:	892e                	mv	s2,a1
    80004044:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004046:	ffffd097          	auipc	ra,0xffffd
    8000404a:	e64080e7          	jalr	-412(ra) # 80000eaa <myproc>
    8000404e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004050:	8526                	mv	a0,s1
    80004052:	00002097          	auipc	ra,0x2
    80004056:	1c2080e7          	jalr	450(ra) # 80006214 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000405a:	2184a703          	lw	a4,536(s1)
    8000405e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004062:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004066:	02f71763          	bne	a4,a5,80004094 <piperead+0x68>
    8000406a:	2244a783          	lw	a5,548(s1)
    8000406e:	c39d                	beqz	a5,80004094 <piperead+0x68>
    if(killed(pr)){
    80004070:	8552                	mv	a0,s4
    80004072:	ffffd097          	auipc	ra,0xffffd
    80004076:	788080e7          	jalr	1928(ra) # 800017fa <killed>
    8000407a:	e949                	bnez	a0,8000410c <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000407c:	85a6                	mv	a1,s1
    8000407e:	854e                	mv	a0,s3
    80004080:	ffffd097          	auipc	ra,0xffffd
    80004084:	4d2080e7          	jalr	1234(ra) # 80001552 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004088:	2184a703          	lw	a4,536(s1)
    8000408c:	21c4a783          	lw	a5,540(s1)
    80004090:	fcf70de3          	beq	a4,a5,8000406a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004094:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004096:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004098:	05505463          	blez	s5,800040e0 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    8000409c:	2184a783          	lw	a5,536(s1)
    800040a0:	21c4a703          	lw	a4,540(s1)
    800040a4:	02f70e63          	beq	a4,a5,800040e0 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800040a8:	0017871b          	addiw	a4,a5,1
    800040ac:	20e4ac23          	sw	a4,536(s1)
    800040b0:	1ff7f793          	andi	a5,a5,511
    800040b4:	97a6                	add	a5,a5,s1
    800040b6:	0187c783          	lbu	a5,24(a5)
    800040ba:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800040be:	4685                	li	a3,1
    800040c0:	fbf40613          	addi	a2,s0,-65
    800040c4:	85ca                	mv	a1,s2
    800040c6:	050a3503          	ld	a0,80(s4)
    800040ca:	ffffd097          	auipc	ra,0xffffd
    800040ce:	aa0080e7          	jalr	-1376(ra) # 80000b6a <copyout>
    800040d2:	01650763          	beq	a0,s6,800040e0 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800040d6:	2985                	addiw	s3,s3,1
    800040d8:	0905                	addi	s2,s2,1
    800040da:	fd3a91e3          	bne	s5,s3,8000409c <piperead+0x70>
    800040de:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800040e0:	21c48513          	addi	a0,s1,540
    800040e4:	ffffd097          	auipc	ra,0xffffd
    800040e8:	4d2080e7          	jalr	1234(ra) # 800015b6 <wakeup>
  release(&pi->lock);
    800040ec:	8526                	mv	a0,s1
    800040ee:	00002097          	auipc	ra,0x2
    800040f2:	1da080e7          	jalr	474(ra) # 800062c8 <release>
  return i;
}
    800040f6:	854e                	mv	a0,s3
    800040f8:	60a6                	ld	ra,72(sp)
    800040fa:	6406                	ld	s0,64(sp)
    800040fc:	74e2                	ld	s1,56(sp)
    800040fe:	7942                	ld	s2,48(sp)
    80004100:	79a2                	ld	s3,40(sp)
    80004102:	7a02                	ld	s4,32(sp)
    80004104:	6ae2                	ld	s5,24(sp)
    80004106:	6b42                	ld	s6,16(sp)
    80004108:	6161                	addi	sp,sp,80
    8000410a:	8082                	ret
      release(&pi->lock);
    8000410c:	8526                	mv	a0,s1
    8000410e:	00002097          	auipc	ra,0x2
    80004112:	1ba080e7          	jalr	442(ra) # 800062c8 <release>
      return -1;
    80004116:	59fd                	li	s3,-1
    80004118:	bff9                	j	800040f6 <piperead+0xca>

000000008000411a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000411a:	1141                	addi	sp,sp,-16
    8000411c:	e422                	sd	s0,8(sp)
    8000411e:	0800                	addi	s0,sp,16
    80004120:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004122:	8905                	andi	a0,a0,1
    80004124:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004126:	8b89                	andi	a5,a5,2
    80004128:	c399                	beqz	a5,8000412e <flags2perm+0x14>
      perm |= PTE_W;
    8000412a:	00456513          	ori	a0,a0,4
    return perm;
}
    8000412e:	6422                	ld	s0,8(sp)
    80004130:	0141                	addi	sp,sp,16
    80004132:	8082                	ret

0000000080004134 <exec>:

int
exec(char *path, char **argv)
{
    80004134:	de010113          	addi	sp,sp,-544
    80004138:	20113c23          	sd	ra,536(sp)
    8000413c:	20813823          	sd	s0,528(sp)
    80004140:	20913423          	sd	s1,520(sp)
    80004144:	21213023          	sd	s2,512(sp)
    80004148:	ffce                	sd	s3,504(sp)
    8000414a:	fbd2                	sd	s4,496(sp)
    8000414c:	f7d6                	sd	s5,488(sp)
    8000414e:	f3da                	sd	s6,480(sp)
    80004150:	efde                	sd	s7,472(sp)
    80004152:	ebe2                	sd	s8,464(sp)
    80004154:	e7e6                	sd	s9,456(sp)
    80004156:	e3ea                	sd	s10,448(sp)
    80004158:	ff6e                	sd	s11,440(sp)
    8000415a:	1400                	addi	s0,sp,544
    8000415c:	892a                	mv	s2,a0
    8000415e:	dea43423          	sd	a0,-536(s0)
    80004162:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004166:	ffffd097          	auipc	ra,0xffffd
    8000416a:	d44080e7          	jalr	-700(ra) # 80000eaa <myproc>
    8000416e:	84aa                	mv	s1,a0

  begin_op();
    80004170:	fffff097          	auipc	ra,0xfffff
    80004174:	482080e7          	jalr	1154(ra) # 800035f2 <begin_op>

  if((ip = namei(path)) == 0){
    80004178:	854a                	mv	a0,s2
    8000417a:	fffff097          	auipc	ra,0xfffff
    8000417e:	258080e7          	jalr	600(ra) # 800033d2 <namei>
    80004182:	c93d                	beqz	a0,800041f8 <exec+0xc4>
    80004184:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004186:	fffff097          	auipc	ra,0xfffff
    8000418a:	aa0080e7          	jalr	-1376(ra) # 80002c26 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000418e:	04000713          	li	a4,64
    80004192:	4681                	li	a3,0
    80004194:	e5040613          	addi	a2,s0,-432
    80004198:	4581                	li	a1,0
    8000419a:	8556                	mv	a0,s5
    8000419c:	fffff097          	auipc	ra,0xfffff
    800041a0:	d3e080e7          	jalr	-706(ra) # 80002eda <readi>
    800041a4:	04000793          	li	a5,64
    800041a8:	00f51a63          	bne	a0,a5,800041bc <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800041ac:	e5042703          	lw	a4,-432(s0)
    800041b0:	464c47b7          	lui	a5,0x464c4
    800041b4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800041b8:	04f70663          	beq	a4,a5,80004204 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800041bc:	8556                	mv	a0,s5
    800041be:	fffff097          	auipc	ra,0xfffff
    800041c2:	cca080e7          	jalr	-822(ra) # 80002e88 <iunlockput>
    end_op();
    800041c6:	fffff097          	auipc	ra,0xfffff
    800041ca:	4aa080e7          	jalr	1194(ra) # 80003670 <end_op>
  }
  return -1;
    800041ce:	557d                	li	a0,-1
}
    800041d0:	21813083          	ld	ra,536(sp)
    800041d4:	21013403          	ld	s0,528(sp)
    800041d8:	20813483          	ld	s1,520(sp)
    800041dc:	20013903          	ld	s2,512(sp)
    800041e0:	79fe                	ld	s3,504(sp)
    800041e2:	7a5e                	ld	s4,496(sp)
    800041e4:	7abe                	ld	s5,488(sp)
    800041e6:	7b1e                	ld	s6,480(sp)
    800041e8:	6bfe                	ld	s7,472(sp)
    800041ea:	6c5e                	ld	s8,464(sp)
    800041ec:	6cbe                	ld	s9,456(sp)
    800041ee:	6d1e                	ld	s10,448(sp)
    800041f0:	7dfa                	ld	s11,440(sp)
    800041f2:	22010113          	addi	sp,sp,544
    800041f6:	8082                	ret
    end_op();
    800041f8:	fffff097          	auipc	ra,0xfffff
    800041fc:	478080e7          	jalr	1144(ra) # 80003670 <end_op>
    return -1;
    80004200:	557d                	li	a0,-1
    80004202:	b7f9                	j	800041d0 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004204:	8526                	mv	a0,s1
    80004206:	ffffd097          	auipc	ra,0xffffd
    8000420a:	d68080e7          	jalr	-664(ra) # 80000f6e <proc_pagetable>
    8000420e:	8b2a                	mv	s6,a0
    80004210:	d555                	beqz	a0,800041bc <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004212:	e7042783          	lw	a5,-400(s0)
    80004216:	e8845703          	lhu	a4,-376(s0)
    8000421a:	c735                	beqz	a4,80004286 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000421c:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000421e:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004222:	6a05                	lui	s4,0x1
    80004224:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004228:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000422c:	6d85                	lui	s11,0x1
    8000422e:	7d7d                	lui	s10,0xfffff
    80004230:	ac3d                	j	8000446e <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004232:	00004517          	auipc	a0,0x4
    80004236:	41e50513          	addi	a0,a0,1054 # 80008650 <syscalls+0x280>
    8000423a:	00002097          	auipc	ra,0x2
    8000423e:	aa2080e7          	jalr	-1374(ra) # 80005cdc <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004242:	874a                	mv	a4,s2
    80004244:	009c86bb          	addw	a3,s9,s1
    80004248:	4581                	li	a1,0
    8000424a:	8556                	mv	a0,s5
    8000424c:	fffff097          	auipc	ra,0xfffff
    80004250:	c8e080e7          	jalr	-882(ra) # 80002eda <readi>
    80004254:	2501                	sext.w	a0,a0
    80004256:	1aa91963          	bne	s2,a0,80004408 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    8000425a:	009d84bb          	addw	s1,s11,s1
    8000425e:	013d09bb          	addw	s3,s10,s3
    80004262:	1f74f663          	bgeu	s1,s7,8000444e <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004266:	02049593          	slli	a1,s1,0x20
    8000426a:	9181                	srli	a1,a1,0x20
    8000426c:	95e2                	add	a1,a1,s8
    8000426e:	855a                	mv	a0,s6
    80004270:	ffffc097          	auipc	ra,0xffffc
    80004274:	294080e7          	jalr	660(ra) # 80000504 <walkaddr>
    80004278:	862a                	mv	a2,a0
    if(pa == 0)
    8000427a:	dd45                	beqz	a0,80004232 <exec+0xfe>
      n = PGSIZE;
    8000427c:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000427e:	fd49f2e3          	bgeu	s3,s4,80004242 <exec+0x10e>
      n = sz - i;
    80004282:	894e                	mv	s2,s3
    80004284:	bf7d                	j	80004242 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004286:	4901                	li	s2,0
  iunlockput(ip);
    80004288:	8556                	mv	a0,s5
    8000428a:	fffff097          	auipc	ra,0xfffff
    8000428e:	bfe080e7          	jalr	-1026(ra) # 80002e88 <iunlockput>
  end_op();
    80004292:	fffff097          	auipc	ra,0xfffff
    80004296:	3de080e7          	jalr	990(ra) # 80003670 <end_op>
  p = myproc();
    8000429a:	ffffd097          	auipc	ra,0xffffd
    8000429e:	c10080e7          	jalr	-1008(ra) # 80000eaa <myproc>
    800042a2:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800042a4:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800042a8:	6785                	lui	a5,0x1
    800042aa:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800042ac:	97ca                	add	a5,a5,s2
    800042ae:	777d                	lui	a4,0xfffff
    800042b0:	8ff9                	and	a5,a5,a4
    800042b2:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800042b6:	4691                	li	a3,4
    800042b8:	6609                	lui	a2,0x2
    800042ba:	963e                	add	a2,a2,a5
    800042bc:	85be                	mv	a1,a5
    800042be:	855a                	mv	a0,s6
    800042c0:	ffffc097          	auipc	ra,0xffffc
    800042c4:	5f8080e7          	jalr	1528(ra) # 800008b8 <uvmalloc>
    800042c8:	8c2a                	mv	s8,a0
  ip = 0;
    800042ca:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800042cc:	12050e63          	beqz	a0,80004408 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800042d0:	75f9                	lui	a1,0xffffe
    800042d2:	95aa                	add	a1,a1,a0
    800042d4:	855a                	mv	a0,s6
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	862080e7          	jalr	-1950(ra) # 80000b38 <uvmclear>
  stackbase = sp - PGSIZE;
    800042de:	7afd                	lui	s5,0xfffff
    800042e0:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800042e2:	df043783          	ld	a5,-528(s0)
    800042e6:	6388                	ld	a0,0(a5)
    800042e8:	c925                	beqz	a0,80004358 <exec+0x224>
    800042ea:	e9040993          	addi	s3,s0,-368
    800042ee:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800042f2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800042f4:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800042f6:	ffffc097          	auipc	ra,0xffffc
    800042fa:	000080e7          	jalr	ra # 800002f6 <strlen>
    800042fe:	0015079b          	addiw	a5,a0,1
    80004302:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004306:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000430a:	13596663          	bltu	s2,s5,80004436 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000430e:	df043d83          	ld	s11,-528(s0)
    80004312:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004316:	8552                	mv	a0,s4
    80004318:	ffffc097          	auipc	ra,0xffffc
    8000431c:	fde080e7          	jalr	-34(ra) # 800002f6 <strlen>
    80004320:	0015069b          	addiw	a3,a0,1
    80004324:	8652                	mv	a2,s4
    80004326:	85ca                	mv	a1,s2
    80004328:	855a                	mv	a0,s6
    8000432a:	ffffd097          	auipc	ra,0xffffd
    8000432e:	840080e7          	jalr	-1984(ra) # 80000b6a <copyout>
    80004332:	10054663          	bltz	a0,8000443e <exec+0x30a>
    ustack[argc] = sp;
    80004336:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000433a:	0485                	addi	s1,s1,1
    8000433c:	008d8793          	addi	a5,s11,8
    80004340:	def43823          	sd	a5,-528(s0)
    80004344:	008db503          	ld	a0,8(s11)
    80004348:	c911                	beqz	a0,8000435c <exec+0x228>
    if(argc >= MAXARG)
    8000434a:	09a1                	addi	s3,s3,8
    8000434c:	fb3c95e3          	bne	s9,s3,800042f6 <exec+0x1c2>
  sz = sz1;
    80004350:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004354:	4a81                	li	s5,0
    80004356:	a84d                	j	80004408 <exec+0x2d4>
  sp = sz;
    80004358:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000435a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000435c:	00349793          	slli	a5,s1,0x3
    80004360:	f9078793          	addi	a5,a5,-112
    80004364:	97a2                	add	a5,a5,s0
    80004366:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000436a:	00148693          	addi	a3,s1,1
    8000436e:	068e                	slli	a3,a3,0x3
    80004370:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004374:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004378:	01597663          	bgeu	s2,s5,80004384 <exec+0x250>
  sz = sz1;
    8000437c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004380:	4a81                	li	s5,0
    80004382:	a059                	j	80004408 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004384:	e9040613          	addi	a2,s0,-368
    80004388:	85ca                	mv	a1,s2
    8000438a:	855a                	mv	a0,s6
    8000438c:	ffffc097          	auipc	ra,0xffffc
    80004390:	7de080e7          	jalr	2014(ra) # 80000b6a <copyout>
    80004394:	0a054963          	bltz	a0,80004446 <exec+0x312>
  p->trapframe->a1 = sp;
    80004398:	058bb783          	ld	a5,88(s7)
    8000439c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800043a0:	de843783          	ld	a5,-536(s0)
    800043a4:	0007c703          	lbu	a4,0(a5)
    800043a8:	cf11                	beqz	a4,800043c4 <exec+0x290>
    800043aa:	0785                	addi	a5,a5,1
    if(*s == '/')
    800043ac:	02f00693          	li	a3,47
    800043b0:	a039                	j	800043be <exec+0x28a>
      last = s+1;
    800043b2:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800043b6:	0785                	addi	a5,a5,1
    800043b8:	fff7c703          	lbu	a4,-1(a5)
    800043bc:	c701                	beqz	a4,800043c4 <exec+0x290>
    if(*s == '/')
    800043be:	fed71ce3          	bne	a4,a3,800043b6 <exec+0x282>
    800043c2:	bfc5                	j	800043b2 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800043c4:	4641                	li	a2,16
    800043c6:	de843583          	ld	a1,-536(s0)
    800043ca:	158b8513          	addi	a0,s7,344
    800043ce:	ffffc097          	auipc	ra,0xffffc
    800043d2:	ef6080e7          	jalr	-266(ra) # 800002c4 <safestrcpy>
  oldpagetable = p->pagetable;
    800043d6:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800043da:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800043de:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800043e2:	058bb783          	ld	a5,88(s7)
    800043e6:	e6843703          	ld	a4,-408(s0)
    800043ea:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800043ec:	058bb783          	ld	a5,88(s7)
    800043f0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800043f4:	85ea                	mv	a1,s10
    800043f6:	ffffd097          	auipc	ra,0xffffd
    800043fa:	c14080e7          	jalr	-1004(ra) # 8000100a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800043fe:	0004851b          	sext.w	a0,s1
    80004402:	b3f9                	j	800041d0 <exec+0x9c>
    80004404:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004408:	df843583          	ld	a1,-520(s0)
    8000440c:	855a                	mv	a0,s6
    8000440e:	ffffd097          	auipc	ra,0xffffd
    80004412:	bfc080e7          	jalr	-1028(ra) # 8000100a <proc_freepagetable>
  if(ip){
    80004416:	da0a93e3          	bnez	s5,800041bc <exec+0x88>
  return -1;
    8000441a:	557d                	li	a0,-1
    8000441c:	bb55                	j	800041d0 <exec+0x9c>
    8000441e:	df243c23          	sd	s2,-520(s0)
    80004422:	b7dd                	j	80004408 <exec+0x2d4>
    80004424:	df243c23          	sd	s2,-520(s0)
    80004428:	b7c5                	j	80004408 <exec+0x2d4>
    8000442a:	df243c23          	sd	s2,-520(s0)
    8000442e:	bfe9                	j	80004408 <exec+0x2d4>
    80004430:	df243c23          	sd	s2,-520(s0)
    80004434:	bfd1                	j	80004408 <exec+0x2d4>
  sz = sz1;
    80004436:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000443a:	4a81                	li	s5,0
    8000443c:	b7f1                	j	80004408 <exec+0x2d4>
  sz = sz1;
    8000443e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004442:	4a81                	li	s5,0
    80004444:	b7d1                	j	80004408 <exec+0x2d4>
  sz = sz1;
    80004446:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000444a:	4a81                	li	s5,0
    8000444c:	bf75                	j	80004408 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000444e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004452:	e0843783          	ld	a5,-504(s0)
    80004456:	0017869b          	addiw	a3,a5,1
    8000445a:	e0d43423          	sd	a3,-504(s0)
    8000445e:	e0043783          	ld	a5,-512(s0)
    80004462:	0387879b          	addiw	a5,a5,56
    80004466:	e8845703          	lhu	a4,-376(s0)
    8000446a:	e0e6dfe3          	bge	a3,a4,80004288 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000446e:	2781                	sext.w	a5,a5
    80004470:	e0f43023          	sd	a5,-512(s0)
    80004474:	03800713          	li	a4,56
    80004478:	86be                	mv	a3,a5
    8000447a:	e1840613          	addi	a2,s0,-488
    8000447e:	4581                	li	a1,0
    80004480:	8556                	mv	a0,s5
    80004482:	fffff097          	auipc	ra,0xfffff
    80004486:	a58080e7          	jalr	-1448(ra) # 80002eda <readi>
    8000448a:	03800793          	li	a5,56
    8000448e:	f6f51be3          	bne	a0,a5,80004404 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    80004492:	e1842783          	lw	a5,-488(s0)
    80004496:	4705                	li	a4,1
    80004498:	fae79de3          	bne	a5,a4,80004452 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    8000449c:	e4043483          	ld	s1,-448(s0)
    800044a0:	e3843783          	ld	a5,-456(s0)
    800044a4:	f6f4ede3          	bltu	s1,a5,8000441e <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800044a8:	e2843783          	ld	a5,-472(s0)
    800044ac:	94be                	add	s1,s1,a5
    800044ae:	f6f4ebe3          	bltu	s1,a5,80004424 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    800044b2:	de043703          	ld	a4,-544(s0)
    800044b6:	8ff9                	and	a5,a5,a4
    800044b8:	fbad                	bnez	a5,8000442a <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800044ba:	e1c42503          	lw	a0,-484(s0)
    800044be:	00000097          	auipc	ra,0x0
    800044c2:	c5c080e7          	jalr	-932(ra) # 8000411a <flags2perm>
    800044c6:	86aa                	mv	a3,a0
    800044c8:	8626                	mv	a2,s1
    800044ca:	85ca                	mv	a1,s2
    800044cc:	855a                	mv	a0,s6
    800044ce:	ffffc097          	auipc	ra,0xffffc
    800044d2:	3ea080e7          	jalr	1002(ra) # 800008b8 <uvmalloc>
    800044d6:	dea43c23          	sd	a0,-520(s0)
    800044da:	d939                	beqz	a0,80004430 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800044dc:	e2843c03          	ld	s8,-472(s0)
    800044e0:	e2042c83          	lw	s9,-480(s0)
    800044e4:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800044e8:	f60b83e3          	beqz	s7,8000444e <exec+0x31a>
    800044ec:	89de                	mv	s3,s7
    800044ee:	4481                	li	s1,0
    800044f0:	bb9d                	j	80004266 <exec+0x132>

00000000800044f2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800044f2:	7179                	addi	sp,sp,-48
    800044f4:	f406                	sd	ra,40(sp)
    800044f6:	f022                	sd	s0,32(sp)
    800044f8:	ec26                	sd	s1,24(sp)
    800044fa:	e84a                	sd	s2,16(sp)
    800044fc:	1800                	addi	s0,sp,48
    800044fe:	892e                	mv	s2,a1
    80004500:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004502:	fdc40593          	addi	a1,s0,-36
    80004506:	ffffe097          	auipc	ra,0xffffe
    8000450a:	ba8080e7          	jalr	-1112(ra) # 800020ae <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000450e:	fdc42703          	lw	a4,-36(s0)
    80004512:	47bd                	li	a5,15
    80004514:	02e7eb63          	bltu	a5,a4,8000454a <argfd+0x58>
    80004518:	ffffd097          	auipc	ra,0xffffd
    8000451c:	992080e7          	jalr	-1646(ra) # 80000eaa <myproc>
    80004520:	fdc42703          	lw	a4,-36(s0)
    80004524:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd2ca>
    80004528:	078e                	slli	a5,a5,0x3
    8000452a:	953e                	add	a0,a0,a5
    8000452c:	611c                	ld	a5,0(a0)
    8000452e:	c385                	beqz	a5,8000454e <argfd+0x5c>
    return -1;
  if(pfd)
    80004530:	00090463          	beqz	s2,80004538 <argfd+0x46>
    *pfd = fd;
    80004534:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004538:	4501                	li	a0,0
  if(pf)
    8000453a:	c091                	beqz	s1,8000453e <argfd+0x4c>
    *pf = f;
    8000453c:	e09c                	sd	a5,0(s1)
}
    8000453e:	70a2                	ld	ra,40(sp)
    80004540:	7402                	ld	s0,32(sp)
    80004542:	64e2                	ld	s1,24(sp)
    80004544:	6942                	ld	s2,16(sp)
    80004546:	6145                	addi	sp,sp,48
    80004548:	8082                	ret
    return -1;
    8000454a:	557d                	li	a0,-1
    8000454c:	bfcd                	j	8000453e <argfd+0x4c>
    8000454e:	557d                	li	a0,-1
    80004550:	b7fd                	j	8000453e <argfd+0x4c>

0000000080004552 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004552:	1101                	addi	sp,sp,-32
    80004554:	ec06                	sd	ra,24(sp)
    80004556:	e822                	sd	s0,16(sp)
    80004558:	e426                	sd	s1,8(sp)
    8000455a:	1000                	addi	s0,sp,32
    8000455c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000455e:	ffffd097          	auipc	ra,0xffffd
    80004562:	94c080e7          	jalr	-1716(ra) # 80000eaa <myproc>
    80004566:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004568:	0d050793          	addi	a5,a0,208
    8000456c:	4501                	li	a0,0
    8000456e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004570:	6398                	ld	a4,0(a5)
    80004572:	cb19                	beqz	a4,80004588 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004574:	2505                	addiw	a0,a0,1
    80004576:	07a1                	addi	a5,a5,8
    80004578:	fed51ce3          	bne	a0,a3,80004570 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000457c:	557d                	li	a0,-1
}
    8000457e:	60e2                	ld	ra,24(sp)
    80004580:	6442                	ld	s0,16(sp)
    80004582:	64a2                	ld	s1,8(sp)
    80004584:	6105                	addi	sp,sp,32
    80004586:	8082                	ret
      p->ofile[fd] = f;
    80004588:	01a50793          	addi	a5,a0,26
    8000458c:	078e                	slli	a5,a5,0x3
    8000458e:	963e                	add	a2,a2,a5
    80004590:	e204                	sd	s1,0(a2)
      return fd;
    80004592:	b7f5                	j	8000457e <fdalloc+0x2c>

0000000080004594 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004594:	715d                	addi	sp,sp,-80
    80004596:	e486                	sd	ra,72(sp)
    80004598:	e0a2                	sd	s0,64(sp)
    8000459a:	fc26                	sd	s1,56(sp)
    8000459c:	f84a                	sd	s2,48(sp)
    8000459e:	f44e                	sd	s3,40(sp)
    800045a0:	f052                	sd	s4,32(sp)
    800045a2:	ec56                	sd	s5,24(sp)
    800045a4:	e85a                	sd	s6,16(sp)
    800045a6:	0880                	addi	s0,sp,80
    800045a8:	8b2e                	mv	s6,a1
    800045aa:	89b2                	mv	s3,a2
    800045ac:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800045ae:	fb040593          	addi	a1,s0,-80
    800045b2:	fffff097          	auipc	ra,0xfffff
    800045b6:	e3e080e7          	jalr	-450(ra) # 800033f0 <nameiparent>
    800045ba:	84aa                	mv	s1,a0
    800045bc:	14050f63          	beqz	a0,8000471a <create+0x186>
    return 0;

  ilock(dp);
    800045c0:	ffffe097          	auipc	ra,0xffffe
    800045c4:	666080e7          	jalr	1638(ra) # 80002c26 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800045c8:	4601                	li	a2,0
    800045ca:	fb040593          	addi	a1,s0,-80
    800045ce:	8526                	mv	a0,s1
    800045d0:	fffff097          	auipc	ra,0xfffff
    800045d4:	b3a080e7          	jalr	-1222(ra) # 8000310a <dirlookup>
    800045d8:	8aaa                	mv	s5,a0
    800045da:	c931                	beqz	a0,8000462e <create+0x9a>
    iunlockput(dp);
    800045dc:	8526                	mv	a0,s1
    800045de:	fffff097          	auipc	ra,0xfffff
    800045e2:	8aa080e7          	jalr	-1878(ra) # 80002e88 <iunlockput>
    ilock(ip);
    800045e6:	8556                	mv	a0,s5
    800045e8:	ffffe097          	auipc	ra,0xffffe
    800045ec:	63e080e7          	jalr	1598(ra) # 80002c26 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800045f0:	000b059b          	sext.w	a1,s6
    800045f4:	4789                	li	a5,2
    800045f6:	02f59563          	bne	a1,a5,80004620 <create+0x8c>
    800045fa:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd2f4>
    800045fe:	37f9                	addiw	a5,a5,-2
    80004600:	17c2                	slli	a5,a5,0x30
    80004602:	93c1                	srli	a5,a5,0x30
    80004604:	4705                	li	a4,1
    80004606:	00f76d63          	bltu	a4,a5,80004620 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000460a:	8556                	mv	a0,s5
    8000460c:	60a6                	ld	ra,72(sp)
    8000460e:	6406                	ld	s0,64(sp)
    80004610:	74e2                	ld	s1,56(sp)
    80004612:	7942                	ld	s2,48(sp)
    80004614:	79a2                	ld	s3,40(sp)
    80004616:	7a02                	ld	s4,32(sp)
    80004618:	6ae2                	ld	s5,24(sp)
    8000461a:	6b42                	ld	s6,16(sp)
    8000461c:	6161                	addi	sp,sp,80
    8000461e:	8082                	ret
    iunlockput(ip);
    80004620:	8556                	mv	a0,s5
    80004622:	fffff097          	auipc	ra,0xfffff
    80004626:	866080e7          	jalr	-1946(ra) # 80002e88 <iunlockput>
    return 0;
    8000462a:	4a81                	li	s5,0
    8000462c:	bff9                	j	8000460a <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000462e:	85da                	mv	a1,s6
    80004630:	4088                	lw	a0,0(s1)
    80004632:	ffffe097          	auipc	ra,0xffffe
    80004636:	456080e7          	jalr	1110(ra) # 80002a88 <ialloc>
    8000463a:	8a2a                	mv	s4,a0
    8000463c:	c539                	beqz	a0,8000468a <create+0xf6>
  ilock(ip);
    8000463e:	ffffe097          	auipc	ra,0xffffe
    80004642:	5e8080e7          	jalr	1512(ra) # 80002c26 <ilock>
  ip->major = major;
    80004646:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000464a:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000464e:	4905                	li	s2,1
    80004650:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004654:	8552                	mv	a0,s4
    80004656:	ffffe097          	auipc	ra,0xffffe
    8000465a:	504080e7          	jalr	1284(ra) # 80002b5a <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000465e:	000b059b          	sext.w	a1,s6
    80004662:	03258b63          	beq	a1,s2,80004698 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80004666:	004a2603          	lw	a2,4(s4)
    8000466a:	fb040593          	addi	a1,s0,-80
    8000466e:	8526                	mv	a0,s1
    80004670:	fffff097          	auipc	ra,0xfffff
    80004674:	cb0080e7          	jalr	-848(ra) # 80003320 <dirlink>
    80004678:	06054f63          	bltz	a0,800046f6 <create+0x162>
  iunlockput(dp);
    8000467c:	8526                	mv	a0,s1
    8000467e:	fffff097          	auipc	ra,0xfffff
    80004682:	80a080e7          	jalr	-2038(ra) # 80002e88 <iunlockput>
  return ip;
    80004686:	8ad2                	mv	s5,s4
    80004688:	b749                	j	8000460a <create+0x76>
    iunlockput(dp);
    8000468a:	8526                	mv	a0,s1
    8000468c:	ffffe097          	auipc	ra,0xffffe
    80004690:	7fc080e7          	jalr	2044(ra) # 80002e88 <iunlockput>
    return 0;
    80004694:	8ad2                	mv	s5,s4
    80004696:	bf95                	j	8000460a <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004698:	004a2603          	lw	a2,4(s4)
    8000469c:	00004597          	auipc	a1,0x4
    800046a0:	fd458593          	addi	a1,a1,-44 # 80008670 <syscalls+0x2a0>
    800046a4:	8552                	mv	a0,s4
    800046a6:	fffff097          	auipc	ra,0xfffff
    800046aa:	c7a080e7          	jalr	-902(ra) # 80003320 <dirlink>
    800046ae:	04054463          	bltz	a0,800046f6 <create+0x162>
    800046b2:	40d0                	lw	a2,4(s1)
    800046b4:	00004597          	auipc	a1,0x4
    800046b8:	fc458593          	addi	a1,a1,-60 # 80008678 <syscalls+0x2a8>
    800046bc:	8552                	mv	a0,s4
    800046be:	fffff097          	auipc	ra,0xfffff
    800046c2:	c62080e7          	jalr	-926(ra) # 80003320 <dirlink>
    800046c6:	02054863          	bltz	a0,800046f6 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800046ca:	004a2603          	lw	a2,4(s4)
    800046ce:	fb040593          	addi	a1,s0,-80
    800046d2:	8526                	mv	a0,s1
    800046d4:	fffff097          	auipc	ra,0xfffff
    800046d8:	c4c080e7          	jalr	-948(ra) # 80003320 <dirlink>
    800046dc:	00054d63          	bltz	a0,800046f6 <create+0x162>
    dp->nlink++;  // for ".."
    800046e0:	04a4d783          	lhu	a5,74(s1)
    800046e4:	2785                	addiw	a5,a5,1
    800046e6:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800046ea:	8526                	mv	a0,s1
    800046ec:	ffffe097          	auipc	ra,0xffffe
    800046f0:	46e080e7          	jalr	1134(ra) # 80002b5a <iupdate>
    800046f4:	b761                	j	8000467c <create+0xe8>
  ip->nlink = 0;
    800046f6:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800046fa:	8552                	mv	a0,s4
    800046fc:	ffffe097          	auipc	ra,0xffffe
    80004700:	45e080e7          	jalr	1118(ra) # 80002b5a <iupdate>
  iunlockput(ip);
    80004704:	8552                	mv	a0,s4
    80004706:	ffffe097          	auipc	ra,0xffffe
    8000470a:	782080e7          	jalr	1922(ra) # 80002e88 <iunlockput>
  iunlockput(dp);
    8000470e:	8526                	mv	a0,s1
    80004710:	ffffe097          	auipc	ra,0xffffe
    80004714:	778080e7          	jalr	1912(ra) # 80002e88 <iunlockput>
  return 0;
    80004718:	bdcd                	j	8000460a <create+0x76>
    return 0;
    8000471a:	8aaa                	mv	s5,a0
    8000471c:	b5fd                	j	8000460a <create+0x76>

000000008000471e <sys_dup>:
{
    8000471e:	7179                	addi	sp,sp,-48
    80004720:	f406                	sd	ra,40(sp)
    80004722:	f022                	sd	s0,32(sp)
    80004724:	ec26                	sd	s1,24(sp)
    80004726:	e84a                	sd	s2,16(sp)
    80004728:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000472a:	fd840613          	addi	a2,s0,-40
    8000472e:	4581                	li	a1,0
    80004730:	4501                	li	a0,0
    80004732:	00000097          	auipc	ra,0x0
    80004736:	dc0080e7          	jalr	-576(ra) # 800044f2 <argfd>
    return -1;
    8000473a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000473c:	02054363          	bltz	a0,80004762 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80004740:	fd843903          	ld	s2,-40(s0)
    80004744:	854a                	mv	a0,s2
    80004746:	00000097          	auipc	ra,0x0
    8000474a:	e0c080e7          	jalr	-500(ra) # 80004552 <fdalloc>
    8000474e:	84aa                	mv	s1,a0
    return -1;
    80004750:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004752:	00054863          	bltz	a0,80004762 <sys_dup+0x44>
  filedup(f);
    80004756:	854a                	mv	a0,s2
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	310080e7          	jalr	784(ra) # 80003a68 <filedup>
  return fd;
    80004760:	87a6                	mv	a5,s1
}
    80004762:	853e                	mv	a0,a5
    80004764:	70a2                	ld	ra,40(sp)
    80004766:	7402                	ld	s0,32(sp)
    80004768:	64e2                	ld	s1,24(sp)
    8000476a:	6942                	ld	s2,16(sp)
    8000476c:	6145                	addi	sp,sp,48
    8000476e:	8082                	ret

0000000080004770 <sys_read>:
{
    80004770:	7179                	addi	sp,sp,-48
    80004772:	f406                	sd	ra,40(sp)
    80004774:	f022                	sd	s0,32(sp)
    80004776:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004778:	fd840593          	addi	a1,s0,-40
    8000477c:	4505                	li	a0,1
    8000477e:	ffffe097          	auipc	ra,0xffffe
    80004782:	950080e7          	jalr	-1712(ra) # 800020ce <argaddr>
  argint(2, &n);
    80004786:	fe440593          	addi	a1,s0,-28
    8000478a:	4509                	li	a0,2
    8000478c:	ffffe097          	auipc	ra,0xffffe
    80004790:	922080e7          	jalr	-1758(ra) # 800020ae <argint>
  if(argfd(0, 0, &f) < 0)
    80004794:	fe840613          	addi	a2,s0,-24
    80004798:	4581                	li	a1,0
    8000479a:	4501                	li	a0,0
    8000479c:	00000097          	auipc	ra,0x0
    800047a0:	d56080e7          	jalr	-682(ra) # 800044f2 <argfd>
    800047a4:	87aa                	mv	a5,a0
    return -1;
    800047a6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800047a8:	0007cc63          	bltz	a5,800047c0 <sys_read+0x50>
  return fileread(f, p, n);
    800047ac:	fe442603          	lw	a2,-28(s0)
    800047b0:	fd843583          	ld	a1,-40(s0)
    800047b4:	fe843503          	ld	a0,-24(s0)
    800047b8:	fffff097          	auipc	ra,0xfffff
    800047bc:	43c080e7          	jalr	1084(ra) # 80003bf4 <fileread>
}
    800047c0:	70a2                	ld	ra,40(sp)
    800047c2:	7402                	ld	s0,32(sp)
    800047c4:	6145                	addi	sp,sp,48
    800047c6:	8082                	ret

00000000800047c8 <sys_write>:
{
    800047c8:	7179                	addi	sp,sp,-48
    800047ca:	f406                	sd	ra,40(sp)
    800047cc:	f022                	sd	s0,32(sp)
    800047ce:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800047d0:	fd840593          	addi	a1,s0,-40
    800047d4:	4505                	li	a0,1
    800047d6:	ffffe097          	auipc	ra,0xffffe
    800047da:	8f8080e7          	jalr	-1800(ra) # 800020ce <argaddr>
  argint(2, &n);
    800047de:	fe440593          	addi	a1,s0,-28
    800047e2:	4509                	li	a0,2
    800047e4:	ffffe097          	auipc	ra,0xffffe
    800047e8:	8ca080e7          	jalr	-1846(ra) # 800020ae <argint>
  if(argfd(0, 0, &f) < 0)
    800047ec:	fe840613          	addi	a2,s0,-24
    800047f0:	4581                	li	a1,0
    800047f2:	4501                	li	a0,0
    800047f4:	00000097          	auipc	ra,0x0
    800047f8:	cfe080e7          	jalr	-770(ra) # 800044f2 <argfd>
    800047fc:	87aa                	mv	a5,a0
    return -1;
    800047fe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004800:	0007cc63          	bltz	a5,80004818 <sys_write+0x50>
  return filewrite(f, p, n);
    80004804:	fe442603          	lw	a2,-28(s0)
    80004808:	fd843583          	ld	a1,-40(s0)
    8000480c:	fe843503          	ld	a0,-24(s0)
    80004810:	fffff097          	auipc	ra,0xfffff
    80004814:	4a6080e7          	jalr	1190(ra) # 80003cb6 <filewrite>
}
    80004818:	70a2                	ld	ra,40(sp)
    8000481a:	7402                	ld	s0,32(sp)
    8000481c:	6145                	addi	sp,sp,48
    8000481e:	8082                	ret

0000000080004820 <sys_close>:
{
    80004820:	1101                	addi	sp,sp,-32
    80004822:	ec06                	sd	ra,24(sp)
    80004824:	e822                	sd	s0,16(sp)
    80004826:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004828:	fe040613          	addi	a2,s0,-32
    8000482c:	fec40593          	addi	a1,s0,-20
    80004830:	4501                	li	a0,0
    80004832:	00000097          	auipc	ra,0x0
    80004836:	cc0080e7          	jalr	-832(ra) # 800044f2 <argfd>
    return -1;
    8000483a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000483c:	02054463          	bltz	a0,80004864 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80004840:	ffffc097          	auipc	ra,0xffffc
    80004844:	66a080e7          	jalr	1642(ra) # 80000eaa <myproc>
    80004848:	fec42783          	lw	a5,-20(s0)
    8000484c:	07e9                	addi	a5,a5,26
    8000484e:	078e                	slli	a5,a5,0x3
    80004850:	953e                	add	a0,a0,a5
    80004852:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004856:	fe043503          	ld	a0,-32(s0)
    8000485a:	fffff097          	auipc	ra,0xfffff
    8000485e:	260080e7          	jalr	608(ra) # 80003aba <fileclose>
  return 0;
    80004862:	4781                	li	a5,0
}
    80004864:	853e                	mv	a0,a5
    80004866:	60e2                	ld	ra,24(sp)
    80004868:	6442                	ld	s0,16(sp)
    8000486a:	6105                	addi	sp,sp,32
    8000486c:	8082                	ret

000000008000486e <sys_fstat>:
{
    8000486e:	1101                	addi	sp,sp,-32
    80004870:	ec06                	sd	ra,24(sp)
    80004872:	e822                	sd	s0,16(sp)
    80004874:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004876:	fe040593          	addi	a1,s0,-32
    8000487a:	4505                	li	a0,1
    8000487c:	ffffe097          	auipc	ra,0xffffe
    80004880:	852080e7          	jalr	-1966(ra) # 800020ce <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004884:	fe840613          	addi	a2,s0,-24
    80004888:	4581                	li	a1,0
    8000488a:	4501                	li	a0,0
    8000488c:	00000097          	auipc	ra,0x0
    80004890:	c66080e7          	jalr	-922(ra) # 800044f2 <argfd>
    80004894:	87aa                	mv	a5,a0
    return -1;
    80004896:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004898:	0007ca63          	bltz	a5,800048ac <sys_fstat+0x3e>
  return filestat(f, st);
    8000489c:	fe043583          	ld	a1,-32(s0)
    800048a0:	fe843503          	ld	a0,-24(s0)
    800048a4:	fffff097          	auipc	ra,0xfffff
    800048a8:	2de080e7          	jalr	734(ra) # 80003b82 <filestat>
}
    800048ac:	60e2                	ld	ra,24(sp)
    800048ae:	6442                	ld	s0,16(sp)
    800048b0:	6105                	addi	sp,sp,32
    800048b2:	8082                	ret

00000000800048b4 <sys_link>:
{
    800048b4:	7169                	addi	sp,sp,-304
    800048b6:	f606                	sd	ra,296(sp)
    800048b8:	f222                	sd	s0,288(sp)
    800048ba:	ee26                	sd	s1,280(sp)
    800048bc:	ea4a                	sd	s2,272(sp)
    800048be:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048c0:	08000613          	li	a2,128
    800048c4:	ed040593          	addi	a1,s0,-304
    800048c8:	4501                	li	a0,0
    800048ca:	ffffe097          	auipc	ra,0xffffe
    800048ce:	824080e7          	jalr	-2012(ra) # 800020ee <argstr>
    return -1;
    800048d2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048d4:	10054e63          	bltz	a0,800049f0 <sys_link+0x13c>
    800048d8:	08000613          	li	a2,128
    800048dc:	f5040593          	addi	a1,s0,-176
    800048e0:	4505                	li	a0,1
    800048e2:	ffffe097          	auipc	ra,0xffffe
    800048e6:	80c080e7          	jalr	-2036(ra) # 800020ee <argstr>
    return -1;
    800048ea:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048ec:	10054263          	bltz	a0,800049f0 <sys_link+0x13c>
  begin_op();
    800048f0:	fffff097          	auipc	ra,0xfffff
    800048f4:	d02080e7          	jalr	-766(ra) # 800035f2 <begin_op>
  if((ip = namei(old)) == 0){
    800048f8:	ed040513          	addi	a0,s0,-304
    800048fc:	fffff097          	auipc	ra,0xfffff
    80004900:	ad6080e7          	jalr	-1322(ra) # 800033d2 <namei>
    80004904:	84aa                	mv	s1,a0
    80004906:	c551                	beqz	a0,80004992 <sys_link+0xde>
  ilock(ip);
    80004908:	ffffe097          	auipc	ra,0xffffe
    8000490c:	31e080e7          	jalr	798(ra) # 80002c26 <ilock>
  if(ip->type == T_DIR){
    80004910:	04449703          	lh	a4,68(s1)
    80004914:	4785                	li	a5,1
    80004916:	08f70463          	beq	a4,a5,8000499e <sys_link+0xea>
  ip->nlink++;
    8000491a:	04a4d783          	lhu	a5,74(s1)
    8000491e:	2785                	addiw	a5,a5,1
    80004920:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004924:	8526                	mv	a0,s1
    80004926:	ffffe097          	auipc	ra,0xffffe
    8000492a:	234080e7          	jalr	564(ra) # 80002b5a <iupdate>
  iunlock(ip);
    8000492e:	8526                	mv	a0,s1
    80004930:	ffffe097          	auipc	ra,0xffffe
    80004934:	3b8080e7          	jalr	952(ra) # 80002ce8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004938:	fd040593          	addi	a1,s0,-48
    8000493c:	f5040513          	addi	a0,s0,-176
    80004940:	fffff097          	auipc	ra,0xfffff
    80004944:	ab0080e7          	jalr	-1360(ra) # 800033f0 <nameiparent>
    80004948:	892a                	mv	s2,a0
    8000494a:	c935                	beqz	a0,800049be <sys_link+0x10a>
  ilock(dp);
    8000494c:	ffffe097          	auipc	ra,0xffffe
    80004950:	2da080e7          	jalr	730(ra) # 80002c26 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004954:	00092703          	lw	a4,0(s2)
    80004958:	409c                	lw	a5,0(s1)
    8000495a:	04f71d63          	bne	a4,a5,800049b4 <sys_link+0x100>
    8000495e:	40d0                	lw	a2,4(s1)
    80004960:	fd040593          	addi	a1,s0,-48
    80004964:	854a                	mv	a0,s2
    80004966:	fffff097          	auipc	ra,0xfffff
    8000496a:	9ba080e7          	jalr	-1606(ra) # 80003320 <dirlink>
    8000496e:	04054363          	bltz	a0,800049b4 <sys_link+0x100>
  iunlockput(dp);
    80004972:	854a                	mv	a0,s2
    80004974:	ffffe097          	auipc	ra,0xffffe
    80004978:	514080e7          	jalr	1300(ra) # 80002e88 <iunlockput>
  iput(ip);
    8000497c:	8526                	mv	a0,s1
    8000497e:	ffffe097          	auipc	ra,0xffffe
    80004982:	462080e7          	jalr	1122(ra) # 80002de0 <iput>
  end_op();
    80004986:	fffff097          	auipc	ra,0xfffff
    8000498a:	cea080e7          	jalr	-790(ra) # 80003670 <end_op>
  return 0;
    8000498e:	4781                	li	a5,0
    80004990:	a085                	j	800049f0 <sys_link+0x13c>
    end_op();
    80004992:	fffff097          	auipc	ra,0xfffff
    80004996:	cde080e7          	jalr	-802(ra) # 80003670 <end_op>
    return -1;
    8000499a:	57fd                	li	a5,-1
    8000499c:	a891                	j	800049f0 <sys_link+0x13c>
    iunlockput(ip);
    8000499e:	8526                	mv	a0,s1
    800049a0:	ffffe097          	auipc	ra,0xffffe
    800049a4:	4e8080e7          	jalr	1256(ra) # 80002e88 <iunlockput>
    end_op();
    800049a8:	fffff097          	auipc	ra,0xfffff
    800049ac:	cc8080e7          	jalr	-824(ra) # 80003670 <end_op>
    return -1;
    800049b0:	57fd                	li	a5,-1
    800049b2:	a83d                	j	800049f0 <sys_link+0x13c>
    iunlockput(dp);
    800049b4:	854a                	mv	a0,s2
    800049b6:	ffffe097          	auipc	ra,0xffffe
    800049ba:	4d2080e7          	jalr	1234(ra) # 80002e88 <iunlockput>
  ilock(ip);
    800049be:	8526                	mv	a0,s1
    800049c0:	ffffe097          	auipc	ra,0xffffe
    800049c4:	266080e7          	jalr	614(ra) # 80002c26 <ilock>
  ip->nlink--;
    800049c8:	04a4d783          	lhu	a5,74(s1)
    800049cc:	37fd                	addiw	a5,a5,-1
    800049ce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800049d2:	8526                	mv	a0,s1
    800049d4:	ffffe097          	auipc	ra,0xffffe
    800049d8:	186080e7          	jalr	390(ra) # 80002b5a <iupdate>
  iunlockput(ip);
    800049dc:	8526                	mv	a0,s1
    800049de:	ffffe097          	auipc	ra,0xffffe
    800049e2:	4aa080e7          	jalr	1194(ra) # 80002e88 <iunlockput>
  end_op();
    800049e6:	fffff097          	auipc	ra,0xfffff
    800049ea:	c8a080e7          	jalr	-886(ra) # 80003670 <end_op>
  return -1;
    800049ee:	57fd                	li	a5,-1
}
    800049f0:	853e                	mv	a0,a5
    800049f2:	70b2                	ld	ra,296(sp)
    800049f4:	7412                	ld	s0,288(sp)
    800049f6:	64f2                	ld	s1,280(sp)
    800049f8:	6952                	ld	s2,272(sp)
    800049fa:	6155                	addi	sp,sp,304
    800049fc:	8082                	ret

00000000800049fe <sys_unlink>:
{
    800049fe:	7151                	addi	sp,sp,-240
    80004a00:	f586                	sd	ra,232(sp)
    80004a02:	f1a2                	sd	s0,224(sp)
    80004a04:	eda6                	sd	s1,216(sp)
    80004a06:	e9ca                	sd	s2,208(sp)
    80004a08:	e5ce                	sd	s3,200(sp)
    80004a0a:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004a0c:	08000613          	li	a2,128
    80004a10:	f3040593          	addi	a1,s0,-208
    80004a14:	4501                	li	a0,0
    80004a16:	ffffd097          	auipc	ra,0xffffd
    80004a1a:	6d8080e7          	jalr	1752(ra) # 800020ee <argstr>
    80004a1e:	18054163          	bltz	a0,80004ba0 <sys_unlink+0x1a2>
  begin_op();
    80004a22:	fffff097          	auipc	ra,0xfffff
    80004a26:	bd0080e7          	jalr	-1072(ra) # 800035f2 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004a2a:	fb040593          	addi	a1,s0,-80
    80004a2e:	f3040513          	addi	a0,s0,-208
    80004a32:	fffff097          	auipc	ra,0xfffff
    80004a36:	9be080e7          	jalr	-1602(ra) # 800033f0 <nameiparent>
    80004a3a:	84aa                	mv	s1,a0
    80004a3c:	c979                	beqz	a0,80004b12 <sys_unlink+0x114>
  ilock(dp);
    80004a3e:	ffffe097          	auipc	ra,0xffffe
    80004a42:	1e8080e7          	jalr	488(ra) # 80002c26 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004a46:	00004597          	auipc	a1,0x4
    80004a4a:	c2a58593          	addi	a1,a1,-982 # 80008670 <syscalls+0x2a0>
    80004a4e:	fb040513          	addi	a0,s0,-80
    80004a52:	ffffe097          	auipc	ra,0xffffe
    80004a56:	69e080e7          	jalr	1694(ra) # 800030f0 <namecmp>
    80004a5a:	14050a63          	beqz	a0,80004bae <sys_unlink+0x1b0>
    80004a5e:	00004597          	auipc	a1,0x4
    80004a62:	c1a58593          	addi	a1,a1,-998 # 80008678 <syscalls+0x2a8>
    80004a66:	fb040513          	addi	a0,s0,-80
    80004a6a:	ffffe097          	auipc	ra,0xffffe
    80004a6e:	686080e7          	jalr	1670(ra) # 800030f0 <namecmp>
    80004a72:	12050e63          	beqz	a0,80004bae <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004a76:	f2c40613          	addi	a2,s0,-212
    80004a7a:	fb040593          	addi	a1,s0,-80
    80004a7e:	8526                	mv	a0,s1
    80004a80:	ffffe097          	auipc	ra,0xffffe
    80004a84:	68a080e7          	jalr	1674(ra) # 8000310a <dirlookup>
    80004a88:	892a                	mv	s2,a0
    80004a8a:	12050263          	beqz	a0,80004bae <sys_unlink+0x1b0>
  ilock(ip);
    80004a8e:	ffffe097          	auipc	ra,0xffffe
    80004a92:	198080e7          	jalr	408(ra) # 80002c26 <ilock>
  if(ip->nlink < 1)
    80004a96:	04a91783          	lh	a5,74(s2)
    80004a9a:	08f05263          	blez	a5,80004b1e <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004a9e:	04491703          	lh	a4,68(s2)
    80004aa2:	4785                	li	a5,1
    80004aa4:	08f70563          	beq	a4,a5,80004b2e <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004aa8:	4641                	li	a2,16
    80004aaa:	4581                	li	a1,0
    80004aac:	fc040513          	addi	a0,s0,-64
    80004ab0:	ffffb097          	auipc	ra,0xffffb
    80004ab4:	6ca080e7          	jalr	1738(ra) # 8000017a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ab8:	4741                	li	a4,16
    80004aba:	f2c42683          	lw	a3,-212(s0)
    80004abe:	fc040613          	addi	a2,s0,-64
    80004ac2:	4581                	li	a1,0
    80004ac4:	8526                	mv	a0,s1
    80004ac6:	ffffe097          	auipc	ra,0xffffe
    80004aca:	50c080e7          	jalr	1292(ra) # 80002fd2 <writei>
    80004ace:	47c1                	li	a5,16
    80004ad0:	0af51563          	bne	a0,a5,80004b7a <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004ad4:	04491703          	lh	a4,68(s2)
    80004ad8:	4785                	li	a5,1
    80004ada:	0af70863          	beq	a4,a5,80004b8a <sys_unlink+0x18c>
  iunlockput(dp);
    80004ade:	8526                	mv	a0,s1
    80004ae0:	ffffe097          	auipc	ra,0xffffe
    80004ae4:	3a8080e7          	jalr	936(ra) # 80002e88 <iunlockput>
  ip->nlink--;
    80004ae8:	04a95783          	lhu	a5,74(s2)
    80004aec:	37fd                	addiw	a5,a5,-1
    80004aee:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004af2:	854a                	mv	a0,s2
    80004af4:	ffffe097          	auipc	ra,0xffffe
    80004af8:	066080e7          	jalr	102(ra) # 80002b5a <iupdate>
  iunlockput(ip);
    80004afc:	854a                	mv	a0,s2
    80004afe:	ffffe097          	auipc	ra,0xffffe
    80004b02:	38a080e7          	jalr	906(ra) # 80002e88 <iunlockput>
  end_op();
    80004b06:	fffff097          	auipc	ra,0xfffff
    80004b0a:	b6a080e7          	jalr	-1174(ra) # 80003670 <end_op>
  return 0;
    80004b0e:	4501                	li	a0,0
    80004b10:	a84d                	j	80004bc2 <sys_unlink+0x1c4>
    end_op();
    80004b12:	fffff097          	auipc	ra,0xfffff
    80004b16:	b5e080e7          	jalr	-1186(ra) # 80003670 <end_op>
    return -1;
    80004b1a:	557d                	li	a0,-1
    80004b1c:	a05d                	j	80004bc2 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004b1e:	00004517          	auipc	a0,0x4
    80004b22:	b6250513          	addi	a0,a0,-1182 # 80008680 <syscalls+0x2b0>
    80004b26:	00001097          	auipc	ra,0x1
    80004b2a:	1b6080e7          	jalr	438(ra) # 80005cdc <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b2e:	04c92703          	lw	a4,76(s2)
    80004b32:	02000793          	li	a5,32
    80004b36:	f6e7f9e3          	bgeu	a5,a4,80004aa8 <sys_unlink+0xaa>
    80004b3a:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b3e:	4741                	li	a4,16
    80004b40:	86ce                	mv	a3,s3
    80004b42:	f1840613          	addi	a2,s0,-232
    80004b46:	4581                	li	a1,0
    80004b48:	854a                	mv	a0,s2
    80004b4a:	ffffe097          	auipc	ra,0xffffe
    80004b4e:	390080e7          	jalr	912(ra) # 80002eda <readi>
    80004b52:	47c1                	li	a5,16
    80004b54:	00f51b63          	bne	a0,a5,80004b6a <sys_unlink+0x16c>
    if(de.inum != 0)
    80004b58:	f1845783          	lhu	a5,-232(s0)
    80004b5c:	e7a1                	bnez	a5,80004ba4 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b5e:	29c1                	addiw	s3,s3,16
    80004b60:	04c92783          	lw	a5,76(s2)
    80004b64:	fcf9ede3          	bltu	s3,a5,80004b3e <sys_unlink+0x140>
    80004b68:	b781                	j	80004aa8 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004b6a:	00004517          	auipc	a0,0x4
    80004b6e:	b2e50513          	addi	a0,a0,-1234 # 80008698 <syscalls+0x2c8>
    80004b72:	00001097          	auipc	ra,0x1
    80004b76:	16a080e7          	jalr	362(ra) # 80005cdc <panic>
    panic("unlink: writei");
    80004b7a:	00004517          	auipc	a0,0x4
    80004b7e:	b3650513          	addi	a0,a0,-1226 # 800086b0 <syscalls+0x2e0>
    80004b82:	00001097          	auipc	ra,0x1
    80004b86:	15a080e7          	jalr	346(ra) # 80005cdc <panic>
    dp->nlink--;
    80004b8a:	04a4d783          	lhu	a5,74(s1)
    80004b8e:	37fd                	addiw	a5,a5,-1
    80004b90:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004b94:	8526                	mv	a0,s1
    80004b96:	ffffe097          	auipc	ra,0xffffe
    80004b9a:	fc4080e7          	jalr	-60(ra) # 80002b5a <iupdate>
    80004b9e:	b781                	j	80004ade <sys_unlink+0xe0>
    return -1;
    80004ba0:	557d                	li	a0,-1
    80004ba2:	a005                	j	80004bc2 <sys_unlink+0x1c4>
    iunlockput(ip);
    80004ba4:	854a                	mv	a0,s2
    80004ba6:	ffffe097          	auipc	ra,0xffffe
    80004baa:	2e2080e7          	jalr	738(ra) # 80002e88 <iunlockput>
  iunlockput(dp);
    80004bae:	8526                	mv	a0,s1
    80004bb0:	ffffe097          	auipc	ra,0xffffe
    80004bb4:	2d8080e7          	jalr	728(ra) # 80002e88 <iunlockput>
  end_op();
    80004bb8:	fffff097          	auipc	ra,0xfffff
    80004bbc:	ab8080e7          	jalr	-1352(ra) # 80003670 <end_op>
  return -1;
    80004bc0:	557d                	li	a0,-1
}
    80004bc2:	70ae                	ld	ra,232(sp)
    80004bc4:	740e                	ld	s0,224(sp)
    80004bc6:	64ee                	ld	s1,216(sp)
    80004bc8:	694e                	ld	s2,208(sp)
    80004bca:	69ae                	ld	s3,200(sp)
    80004bcc:	616d                	addi	sp,sp,240
    80004bce:	8082                	ret

0000000080004bd0 <sys_open>:

uint64
sys_open(void)
{
    80004bd0:	7131                	addi	sp,sp,-192
    80004bd2:	fd06                	sd	ra,184(sp)
    80004bd4:	f922                	sd	s0,176(sp)
    80004bd6:	f526                	sd	s1,168(sp)
    80004bd8:	f14a                	sd	s2,160(sp)
    80004bda:	ed4e                	sd	s3,152(sp)
    80004bdc:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004bde:	f4c40593          	addi	a1,s0,-180
    80004be2:	4505                	li	a0,1
    80004be4:	ffffd097          	auipc	ra,0xffffd
    80004be8:	4ca080e7          	jalr	1226(ra) # 800020ae <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004bec:	08000613          	li	a2,128
    80004bf0:	f5040593          	addi	a1,s0,-176
    80004bf4:	4501                	li	a0,0
    80004bf6:	ffffd097          	auipc	ra,0xffffd
    80004bfa:	4f8080e7          	jalr	1272(ra) # 800020ee <argstr>
    80004bfe:	87aa                	mv	a5,a0
    return -1;
    80004c00:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004c02:	0a07c963          	bltz	a5,80004cb4 <sys_open+0xe4>

  begin_op();
    80004c06:	fffff097          	auipc	ra,0xfffff
    80004c0a:	9ec080e7          	jalr	-1556(ra) # 800035f2 <begin_op>

  if(omode & O_CREATE){
    80004c0e:	f4c42783          	lw	a5,-180(s0)
    80004c12:	2007f793          	andi	a5,a5,512
    80004c16:	cfc5                	beqz	a5,80004cce <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004c18:	4681                	li	a3,0
    80004c1a:	4601                	li	a2,0
    80004c1c:	4589                	li	a1,2
    80004c1e:	f5040513          	addi	a0,s0,-176
    80004c22:	00000097          	auipc	ra,0x0
    80004c26:	972080e7          	jalr	-1678(ra) # 80004594 <create>
    80004c2a:	84aa                	mv	s1,a0
    if(ip == 0){
    80004c2c:	c959                	beqz	a0,80004cc2 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004c2e:	04449703          	lh	a4,68(s1)
    80004c32:	478d                	li	a5,3
    80004c34:	00f71763          	bne	a4,a5,80004c42 <sys_open+0x72>
    80004c38:	0464d703          	lhu	a4,70(s1)
    80004c3c:	47a5                	li	a5,9
    80004c3e:	0ce7ed63          	bltu	a5,a4,80004d18 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004c42:	fffff097          	auipc	ra,0xfffff
    80004c46:	dbc080e7          	jalr	-580(ra) # 800039fe <filealloc>
    80004c4a:	89aa                	mv	s3,a0
    80004c4c:	10050363          	beqz	a0,80004d52 <sys_open+0x182>
    80004c50:	00000097          	auipc	ra,0x0
    80004c54:	902080e7          	jalr	-1790(ra) # 80004552 <fdalloc>
    80004c58:	892a                	mv	s2,a0
    80004c5a:	0e054763          	bltz	a0,80004d48 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004c5e:	04449703          	lh	a4,68(s1)
    80004c62:	478d                	li	a5,3
    80004c64:	0cf70563          	beq	a4,a5,80004d2e <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004c68:	4789                	li	a5,2
    80004c6a:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004c6e:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004c72:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004c76:	f4c42783          	lw	a5,-180(s0)
    80004c7a:	0017c713          	xori	a4,a5,1
    80004c7e:	8b05                	andi	a4,a4,1
    80004c80:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004c84:	0037f713          	andi	a4,a5,3
    80004c88:	00e03733          	snez	a4,a4
    80004c8c:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004c90:	4007f793          	andi	a5,a5,1024
    80004c94:	c791                	beqz	a5,80004ca0 <sys_open+0xd0>
    80004c96:	04449703          	lh	a4,68(s1)
    80004c9a:	4789                	li	a5,2
    80004c9c:	0af70063          	beq	a4,a5,80004d3c <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004ca0:	8526                	mv	a0,s1
    80004ca2:	ffffe097          	auipc	ra,0xffffe
    80004ca6:	046080e7          	jalr	70(ra) # 80002ce8 <iunlock>
  end_op();
    80004caa:	fffff097          	auipc	ra,0xfffff
    80004cae:	9c6080e7          	jalr	-1594(ra) # 80003670 <end_op>

  return fd;
    80004cb2:	854a                	mv	a0,s2
}
    80004cb4:	70ea                	ld	ra,184(sp)
    80004cb6:	744a                	ld	s0,176(sp)
    80004cb8:	74aa                	ld	s1,168(sp)
    80004cba:	790a                	ld	s2,160(sp)
    80004cbc:	69ea                	ld	s3,152(sp)
    80004cbe:	6129                	addi	sp,sp,192
    80004cc0:	8082                	ret
      end_op();
    80004cc2:	fffff097          	auipc	ra,0xfffff
    80004cc6:	9ae080e7          	jalr	-1618(ra) # 80003670 <end_op>
      return -1;
    80004cca:	557d                	li	a0,-1
    80004ccc:	b7e5                	j	80004cb4 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004cce:	f5040513          	addi	a0,s0,-176
    80004cd2:	ffffe097          	auipc	ra,0xffffe
    80004cd6:	700080e7          	jalr	1792(ra) # 800033d2 <namei>
    80004cda:	84aa                	mv	s1,a0
    80004cdc:	c905                	beqz	a0,80004d0c <sys_open+0x13c>
    ilock(ip);
    80004cde:	ffffe097          	auipc	ra,0xffffe
    80004ce2:	f48080e7          	jalr	-184(ra) # 80002c26 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004ce6:	04449703          	lh	a4,68(s1)
    80004cea:	4785                	li	a5,1
    80004cec:	f4f711e3          	bne	a4,a5,80004c2e <sys_open+0x5e>
    80004cf0:	f4c42783          	lw	a5,-180(s0)
    80004cf4:	d7b9                	beqz	a5,80004c42 <sys_open+0x72>
      iunlockput(ip);
    80004cf6:	8526                	mv	a0,s1
    80004cf8:	ffffe097          	auipc	ra,0xffffe
    80004cfc:	190080e7          	jalr	400(ra) # 80002e88 <iunlockput>
      end_op();
    80004d00:	fffff097          	auipc	ra,0xfffff
    80004d04:	970080e7          	jalr	-1680(ra) # 80003670 <end_op>
      return -1;
    80004d08:	557d                	li	a0,-1
    80004d0a:	b76d                	j	80004cb4 <sys_open+0xe4>
      end_op();
    80004d0c:	fffff097          	auipc	ra,0xfffff
    80004d10:	964080e7          	jalr	-1692(ra) # 80003670 <end_op>
      return -1;
    80004d14:	557d                	li	a0,-1
    80004d16:	bf79                	j	80004cb4 <sys_open+0xe4>
    iunlockput(ip);
    80004d18:	8526                	mv	a0,s1
    80004d1a:	ffffe097          	auipc	ra,0xffffe
    80004d1e:	16e080e7          	jalr	366(ra) # 80002e88 <iunlockput>
    end_op();
    80004d22:	fffff097          	auipc	ra,0xfffff
    80004d26:	94e080e7          	jalr	-1714(ra) # 80003670 <end_op>
    return -1;
    80004d2a:	557d                	li	a0,-1
    80004d2c:	b761                	j	80004cb4 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004d2e:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004d32:	04649783          	lh	a5,70(s1)
    80004d36:	02f99223          	sh	a5,36(s3)
    80004d3a:	bf25                	j	80004c72 <sys_open+0xa2>
    itrunc(ip);
    80004d3c:	8526                	mv	a0,s1
    80004d3e:	ffffe097          	auipc	ra,0xffffe
    80004d42:	ff6080e7          	jalr	-10(ra) # 80002d34 <itrunc>
    80004d46:	bfa9                	j	80004ca0 <sys_open+0xd0>
      fileclose(f);
    80004d48:	854e                	mv	a0,s3
    80004d4a:	fffff097          	auipc	ra,0xfffff
    80004d4e:	d70080e7          	jalr	-656(ra) # 80003aba <fileclose>
    iunlockput(ip);
    80004d52:	8526                	mv	a0,s1
    80004d54:	ffffe097          	auipc	ra,0xffffe
    80004d58:	134080e7          	jalr	308(ra) # 80002e88 <iunlockput>
    end_op();
    80004d5c:	fffff097          	auipc	ra,0xfffff
    80004d60:	914080e7          	jalr	-1772(ra) # 80003670 <end_op>
    return -1;
    80004d64:	557d                	li	a0,-1
    80004d66:	b7b9                	j	80004cb4 <sys_open+0xe4>

0000000080004d68 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004d68:	7175                	addi	sp,sp,-144
    80004d6a:	e506                	sd	ra,136(sp)
    80004d6c:	e122                	sd	s0,128(sp)
    80004d6e:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004d70:	fffff097          	auipc	ra,0xfffff
    80004d74:	882080e7          	jalr	-1918(ra) # 800035f2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004d78:	08000613          	li	a2,128
    80004d7c:	f7040593          	addi	a1,s0,-144
    80004d80:	4501                	li	a0,0
    80004d82:	ffffd097          	auipc	ra,0xffffd
    80004d86:	36c080e7          	jalr	876(ra) # 800020ee <argstr>
    80004d8a:	02054963          	bltz	a0,80004dbc <sys_mkdir+0x54>
    80004d8e:	4681                	li	a3,0
    80004d90:	4601                	li	a2,0
    80004d92:	4585                	li	a1,1
    80004d94:	f7040513          	addi	a0,s0,-144
    80004d98:	fffff097          	auipc	ra,0xfffff
    80004d9c:	7fc080e7          	jalr	2044(ra) # 80004594 <create>
    80004da0:	cd11                	beqz	a0,80004dbc <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004da2:	ffffe097          	auipc	ra,0xffffe
    80004da6:	0e6080e7          	jalr	230(ra) # 80002e88 <iunlockput>
  end_op();
    80004daa:	fffff097          	auipc	ra,0xfffff
    80004dae:	8c6080e7          	jalr	-1850(ra) # 80003670 <end_op>
  return 0;
    80004db2:	4501                	li	a0,0
}
    80004db4:	60aa                	ld	ra,136(sp)
    80004db6:	640a                	ld	s0,128(sp)
    80004db8:	6149                	addi	sp,sp,144
    80004dba:	8082                	ret
    end_op();
    80004dbc:	fffff097          	auipc	ra,0xfffff
    80004dc0:	8b4080e7          	jalr	-1868(ra) # 80003670 <end_op>
    return -1;
    80004dc4:	557d                	li	a0,-1
    80004dc6:	b7fd                	j	80004db4 <sys_mkdir+0x4c>

0000000080004dc8 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004dc8:	7135                	addi	sp,sp,-160
    80004dca:	ed06                	sd	ra,152(sp)
    80004dcc:	e922                	sd	s0,144(sp)
    80004dce:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004dd0:	fffff097          	auipc	ra,0xfffff
    80004dd4:	822080e7          	jalr	-2014(ra) # 800035f2 <begin_op>
  argint(1, &major);
    80004dd8:	f6c40593          	addi	a1,s0,-148
    80004ddc:	4505                	li	a0,1
    80004dde:	ffffd097          	auipc	ra,0xffffd
    80004de2:	2d0080e7          	jalr	720(ra) # 800020ae <argint>
  argint(2, &minor);
    80004de6:	f6840593          	addi	a1,s0,-152
    80004dea:	4509                	li	a0,2
    80004dec:	ffffd097          	auipc	ra,0xffffd
    80004df0:	2c2080e7          	jalr	706(ra) # 800020ae <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004df4:	08000613          	li	a2,128
    80004df8:	f7040593          	addi	a1,s0,-144
    80004dfc:	4501                	li	a0,0
    80004dfe:	ffffd097          	auipc	ra,0xffffd
    80004e02:	2f0080e7          	jalr	752(ra) # 800020ee <argstr>
    80004e06:	02054b63          	bltz	a0,80004e3c <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004e0a:	f6841683          	lh	a3,-152(s0)
    80004e0e:	f6c41603          	lh	a2,-148(s0)
    80004e12:	458d                	li	a1,3
    80004e14:	f7040513          	addi	a0,s0,-144
    80004e18:	fffff097          	auipc	ra,0xfffff
    80004e1c:	77c080e7          	jalr	1916(ra) # 80004594 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004e20:	cd11                	beqz	a0,80004e3c <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004e22:	ffffe097          	auipc	ra,0xffffe
    80004e26:	066080e7          	jalr	102(ra) # 80002e88 <iunlockput>
  end_op();
    80004e2a:	fffff097          	auipc	ra,0xfffff
    80004e2e:	846080e7          	jalr	-1978(ra) # 80003670 <end_op>
  return 0;
    80004e32:	4501                	li	a0,0
}
    80004e34:	60ea                	ld	ra,152(sp)
    80004e36:	644a                	ld	s0,144(sp)
    80004e38:	610d                	addi	sp,sp,160
    80004e3a:	8082                	ret
    end_op();
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	834080e7          	jalr	-1996(ra) # 80003670 <end_op>
    return -1;
    80004e44:	557d                	li	a0,-1
    80004e46:	b7fd                	j	80004e34 <sys_mknod+0x6c>

0000000080004e48 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004e48:	7135                	addi	sp,sp,-160
    80004e4a:	ed06                	sd	ra,152(sp)
    80004e4c:	e922                	sd	s0,144(sp)
    80004e4e:	e526                	sd	s1,136(sp)
    80004e50:	e14a                	sd	s2,128(sp)
    80004e52:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004e54:	ffffc097          	auipc	ra,0xffffc
    80004e58:	056080e7          	jalr	86(ra) # 80000eaa <myproc>
    80004e5c:	892a                	mv	s2,a0
  
  begin_op();
    80004e5e:	ffffe097          	auipc	ra,0xffffe
    80004e62:	794080e7          	jalr	1940(ra) # 800035f2 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004e66:	08000613          	li	a2,128
    80004e6a:	f6040593          	addi	a1,s0,-160
    80004e6e:	4501                	li	a0,0
    80004e70:	ffffd097          	auipc	ra,0xffffd
    80004e74:	27e080e7          	jalr	638(ra) # 800020ee <argstr>
    80004e78:	04054b63          	bltz	a0,80004ece <sys_chdir+0x86>
    80004e7c:	f6040513          	addi	a0,s0,-160
    80004e80:	ffffe097          	auipc	ra,0xffffe
    80004e84:	552080e7          	jalr	1362(ra) # 800033d2 <namei>
    80004e88:	84aa                	mv	s1,a0
    80004e8a:	c131                	beqz	a0,80004ece <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004e8c:	ffffe097          	auipc	ra,0xffffe
    80004e90:	d9a080e7          	jalr	-614(ra) # 80002c26 <ilock>
  if(ip->type != T_DIR){
    80004e94:	04449703          	lh	a4,68(s1)
    80004e98:	4785                	li	a5,1
    80004e9a:	04f71063          	bne	a4,a5,80004eda <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004e9e:	8526                	mv	a0,s1
    80004ea0:	ffffe097          	auipc	ra,0xffffe
    80004ea4:	e48080e7          	jalr	-440(ra) # 80002ce8 <iunlock>
  iput(p->cwd);
    80004ea8:	15093503          	ld	a0,336(s2)
    80004eac:	ffffe097          	auipc	ra,0xffffe
    80004eb0:	f34080e7          	jalr	-204(ra) # 80002de0 <iput>
  end_op();
    80004eb4:	ffffe097          	auipc	ra,0xffffe
    80004eb8:	7bc080e7          	jalr	1980(ra) # 80003670 <end_op>
  p->cwd = ip;
    80004ebc:	14993823          	sd	s1,336(s2)
  return 0;
    80004ec0:	4501                	li	a0,0
}
    80004ec2:	60ea                	ld	ra,152(sp)
    80004ec4:	644a                	ld	s0,144(sp)
    80004ec6:	64aa                	ld	s1,136(sp)
    80004ec8:	690a                	ld	s2,128(sp)
    80004eca:	610d                	addi	sp,sp,160
    80004ecc:	8082                	ret
    end_op();
    80004ece:	ffffe097          	auipc	ra,0xffffe
    80004ed2:	7a2080e7          	jalr	1954(ra) # 80003670 <end_op>
    return -1;
    80004ed6:	557d                	li	a0,-1
    80004ed8:	b7ed                	j	80004ec2 <sys_chdir+0x7a>
    iunlockput(ip);
    80004eda:	8526                	mv	a0,s1
    80004edc:	ffffe097          	auipc	ra,0xffffe
    80004ee0:	fac080e7          	jalr	-84(ra) # 80002e88 <iunlockput>
    end_op();
    80004ee4:	ffffe097          	auipc	ra,0xffffe
    80004ee8:	78c080e7          	jalr	1932(ra) # 80003670 <end_op>
    return -1;
    80004eec:	557d                	li	a0,-1
    80004eee:	bfd1                	j	80004ec2 <sys_chdir+0x7a>

0000000080004ef0 <sys_exec>:

uint64
sys_exec(void)
{
    80004ef0:	7145                	addi	sp,sp,-464
    80004ef2:	e786                	sd	ra,456(sp)
    80004ef4:	e3a2                	sd	s0,448(sp)
    80004ef6:	ff26                	sd	s1,440(sp)
    80004ef8:	fb4a                	sd	s2,432(sp)
    80004efa:	f74e                	sd	s3,424(sp)
    80004efc:	f352                	sd	s4,416(sp)
    80004efe:	ef56                	sd	s5,408(sp)
    80004f00:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004f02:	e3840593          	addi	a1,s0,-456
    80004f06:	4505                	li	a0,1
    80004f08:	ffffd097          	auipc	ra,0xffffd
    80004f0c:	1c6080e7          	jalr	454(ra) # 800020ce <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004f10:	08000613          	li	a2,128
    80004f14:	f4040593          	addi	a1,s0,-192
    80004f18:	4501                	li	a0,0
    80004f1a:	ffffd097          	auipc	ra,0xffffd
    80004f1e:	1d4080e7          	jalr	468(ra) # 800020ee <argstr>
    80004f22:	87aa                	mv	a5,a0
    return -1;
    80004f24:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004f26:	0c07c363          	bltz	a5,80004fec <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80004f2a:	10000613          	li	a2,256
    80004f2e:	4581                	li	a1,0
    80004f30:	e4040513          	addi	a0,s0,-448
    80004f34:	ffffb097          	auipc	ra,0xffffb
    80004f38:	246080e7          	jalr	582(ra) # 8000017a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004f3c:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004f40:	89a6                	mv	s3,s1
    80004f42:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004f44:	02000a13          	li	s4,32
    80004f48:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004f4c:	00391513          	slli	a0,s2,0x3
    80004f50:	e3040593          	addi	a1,s0,-464
    80004f54:	e3843783          	ld	a5,-456(s0)
    80004f58:	953e                	add	a0,a0,a5
    80004f5a:	ffffd097          	auipc	ra,0xffffd
    80004f5e:	0b6080e7          	jalr	182(ra) # 80002010 <fetchaddr>
    80004f62:	02054a63          	bltz	a0,80004f96 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80004f66:	e3043783          	ld	a5,-464(s0)
    80004f6a:	c3b9                	beqz	a5,80004fb0 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004f6c:	ffffb097          	auipc	ra,0xffffb
    80004f70:	1ae080e7          	jalr	430(ra) # 8000011a <kalloc>
    80004f74:	85aa                	mv	a1,a0
    80004f76:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004f7a:	cd11                	beqz	a0,80004f96 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004f7c:	6605                	lui	a2,0x1
    80004f7e:	e3043503          	ld	a0,-464(s0)
    80004f82:	ffffd097          	auipc	ra,0xffffd
    80004f86:	0e0080e7          	jalr	224(ra) # 80002062 <fetchstr>
    80004f8a:	00054663          	bltz	a0,80004f96 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80004f8e:	0905                	addi	s2,s2,1
    80004f90:	09a1                	addi	s3,s3,8
    80004f92:	fb491be3          	bne	s2,s4,80004f48 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f96:	f4040913          	addi	s2,s0,-192
    80004f9a:	6088                	ld	a0,0(s1)
    80004f9c:	c539                	beqz	a0,80004fea <sys_exec+0xfa>
    kfree(argv[i]);
    80004f9e:	ffffb097          	auipc	ra,0xffffb
    80004fa2:	07e080e7          	jalr	126(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fa6:	04a1                	addi	s1,s1,8
    80004fa8:	ff2499e3          	bne	s1,s2,80004f9a <sys_exec+0xaa>
  return -1;
    80004fac:	557d                	li	a0,-1
    80004fae:	a83d                	j	80004fec <sys_exec+0xfc>
      argv[i] = 0;
    80004fb0:	0a8e                	slli	s5,s5,0x3
    80004fb2:	fc0a8793          	addi	a5,s5,-64
    80004fb6:	00878ab3          	add	s5,a5,s0
    80004fba:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004fbe:	e4040593          	addi	a1,s0,-448
    80004fc2:	f4040513          	addi	a0,s0,-192
    80004fc6:	fffff097          	auipc	ra,0xfffff
    80004fca:	16e080e7          	jalr	366(ra) # 80004134 <exec>
    80004fce:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fd0:	f4040993          	addi	s3,s0,-192
    80004fd4:	6088                	ld	a0,0(s1)
    80004fd6:	c901                	beqz	a0,80004fe6 <sys_exec+0xf6>
    kfree(argv[i]);
    80004fd8:	ffffb097          	auipc	ra,0xffffb
    80004fdc:	044080e7          	jalr	68(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fe0:	04a1                	addi	s1,s1,8
    80004fe2:	ff3499e3          	bne	s1,s3,80004fd4 <sys_exec+0xe4>
  return ret;
    80004fe6:	854a                	mv	a0,s2
    80004fe8:	a011                	j	80004fec <sys_exec+0xfc>
  return -1;
    80004fea:	557d                	li	a0,-1
}
    80004fec:	60be                	ld	ra,456(sp)
    80004fee:	641e                	ld	s0,448(sp)
    80004ff0:	74fa                	ld	s1,440(sp)
    80004ff2:	795a                	ld	s2,432(sp)
    80004ff4:	79ba                	ld	s3,424(sp)
    80004ff6:	7a1a                	ld	s4,416(sp)
    80004ff8:	6afa                	ld	s5,408(sp)
    80004ffa:	6179                	addi	sp,sp,464
    80004ffc:	8082                	ret

0000000080004ffe <sys_pipe>:

uint64
sys_pipe(void)
{
    80004ffe:	7139                	addi	sp,sp,-64
    80005000:	fc06                	sd	ra,56(sp)
    80005002:	f822                	sd	s0,48(sp)
    80005004:	f426                	sd	s1,40(sp)
    80005006:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005008:	ffffc097          	auipc	ra,0xffffc
    8000500c:	ea2080e7          	jalr	-350(ra) # 80000eaa <myproc>
    80005010:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005012:	fd840593          	addi	a1,s0,-40
    80005016:	4501                	li	a0,0
    80005018:	ffffd097          	auipc	ra,0xffffd
    8000501c:	0b6080e7          	jalr	182(ra) # 800020ce <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005020:	fc840593          	addi	a1,s0,-56
    80005024:	fd040513          	addi	a0,s0,-48
    80005028:	fffff097          	auipc	ra,0xfffff
    8000502c:	dc2080e7          	jalr	-574(ra) # 80003dea <pipealloc>
    return -1;
    80005030:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005032:	0c054463          	bltz	a0,800050fa <sys_pipe+0xfc>
  fd0 = -1;
    80005036:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000503a:	fd043503          	ld	a0,-48(s0)
    8000503e:	fffff097          	auipc	ra,0xfffff
    80005042:	514080e7          	jalr	1300(ra) # 80004552 <fdalloc>
    80005046:	fca42223          	sw	a0,-60(s0)
    8000504a:	08054b63          	bltz	a0,800050e0 <sys_pipe+0xe2>
    8000504e:	fc843503          	ld	a0,-56(s0)
    80005052:	fffff097          	auipc	ra,0xfffff
    80005056:	500080e7          	jalr	1280(ra) # 80004552 <fdalloc>
    8000505a:	fca42023          	sw	a0,-64(s0)
    8000505e:	06054863          	bltz	a0,800050ce <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005062:	4691                	li	a3,4
    80005064:	fc440613          	addi	a2,s0,-60
    80005068:	fd843583          	ld	a1,-40(s0)
    8000506c:	68a8                	ld	a0,80(s1)
    8000506e:	ffffc097          	auipc	ra,0xffffc
    80005072:	afc080e7          	jalr	-1284(ra) # 80000b6a <copyout>
    80005076:	02054063          	bltz	a0,80005096 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000507a:	4691                	li	a3,4
    8000507c:	fc040613          	addi	a2,s0,-64
    80005080:	fd843583          	ld	a1,-40(s0)
    80005084:	0591                	addi	a1,a1,4
    80005086:	68a8                	ld	a0,80(s1)
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	ae2080e7          	jalr	-1310(ra) # 80000b6a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005090:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005092:	06055463          	bgez	a0,800050fa <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005096:	fc442783          	lw	a5,-60(s0)
    8000509a:	07e9                	addi	a5,a5,26
    8000509c:	078e                	slli	a5,a5,0x3
    8000509e:	97a6                	add	a5,a5,s1
    800050a0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800050a4:	fc042783          	lw	a5,-64(s0)
    800050a8:	07e9                	addi	a5,a5,26
    800050aa:	078e                	slli	a5,a5,0x3
    800050ac:	94be                	add	s1,s1,a5
    800050ae:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800050b2:	fd043503          	ld	a0,-48(s0)
    800050b6:	fffff097          	auipc	ra,0xfffff
    800050ba:	a04080e7          	jalr	-1532(ra) # 80003aba <fileclose>
    fileclose(wf);
    800050be:	fc843503          	ld	a0,-56(s0)
    800050c2:	fffff097          	auipc	ra,0xfffff
    800050c6:	9f8080e7          	jalr	-1544(ra) # 80003aba <fileclose>
    return -1;
    800050ca:	57fd                	li	a5,-1
    800050cc:	a03d                	j	800050fa <sys_pipe+0xfc>
    if(fd0 >= 0)
    800050ce:	fc442783          	lw	a5,-60(s0)
    800050d2:	0007c763          	bltz	a5,800050e0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800050d6:	07e9                	addi	a5,a5,26
    800050d8:	078e                	slli	a5,a5,0x3
    800050da:	97a6                	add	a5,a5,s1
    800050dc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800050e0:	fd043503          	ld	a0,-48(s0)
    800050e4:	fffff097          	auipc	ra,0xfffff
    800050e8:	9d6080e7          	jalr	-1578(ra) # 80003aba <fileclose>
    fileclose(wf);
    800050ec:	fc843503          	ld	a0,-56(s0)
    800050f0:	fffff097          	auipc	ra,0xfffff
    800050f4:	9ca080e7          	jalr	-1590(ra) # 80003aba <fileclose>
    return -1;
    800050f8:	57fd                	li	a5,-1
}
    800050fa:	853e                	mv	a0,a5
    800050fc:	70e2                	ld	ra,56(sp)
    800050fe:	7442                	ld	s0,48(sp)
    80005100:	74a2                	ld	s1,40(sp)
    80005102:	6121                	addi	sp,sp,64
    80005104:	8082                	ret
	...

0000000080005110 <kernelvec>:
    80005110:	7111                	addi	sp,sp,-256
    80005112:	e006                	sd	ra,0(sp)
    80005114:	e40a                	sd	sp,8(sp)
    80005116:	e80e                	sd	gp,16(sp)
    80005118:	ec12                	sd	tp,24(sp)
    8000511a:	f016                	sd	t0,32(sp)
    8000511c:	f41a                	sd	t1,40(sp)
    8000511e:	f81e                	sd	t2,48(sp)
    80005120:	fc22                	sd	s0,56(sp)
    80005122:	e0a6                	sd	s1,64(sp)
    80005124:	e4aa                	sd	a0,72(sp)
    80005126:	e8ae                	sd	a1,80(sp)
    80005128:	ecb2                	sd	a2,88(sp)
    8000512a:	f0b6                	sd	a3,96(sp)
    8000512c:	f4ba                	sd	a4,104(sp)
    8000512e:	f8be                	sd	a5,112(sp)
    80005130:	fcc2                	sd	a6,120(sp)
    80005132:	e146                	sd	a7,128(sp)
    80005134:	e54a                	sd	s2,136(sp)
    80005136:	e94e                	sd	s3,144(sp)
    80005138:	ed52                	sd	s4,152(sp)
    8000513a:	f156                	sd	s5,160(sp)
    8000513c:	f55a                	sd	s6,168(sp)
    8000513e:	f95e                	sd	s7,176(sp)
    80005140:	fd62                	sd	s8,184(sp)
    80005142:	e1e6                	sd	s9,192(sp)
    80005144:	e5ea                	sd	s10,200(sp)
    80005146:	e9ee                	sd	s11,208(sp)
    80005148:	edf2                	sd	t3,216(sp)
    8000514a:	f1f6                	sd	t4,224(sp)
    8000514c:	f5fa                	sd	t5,232(sp)
    8000514e:	f9fe                	sd	t6,240(sp)
    80005150:	d8dfc0ef          	jal	ra,80001edc <kerneltrap>
    80005154:	6082                	ld	ra,0(sp)
    80005156:	6122                	ld	sp,8(sp)
    80005158:	61c2                	ld	gp,16(sp)
    8000515a:	7282                	ld	t0,32(sp)
    8000515c:	7322                	ld	t1,40(sp)
    8000515e:	73c2                	ld	t2,48(sp)
    80005160:	7462                	ld	s0,56(sp)
    80005162:	6486                	ld	s1,64(sp)
    80005164:	6526                	ld	a0,72(sp)
    80005166:	65c6                	ld	a1,80(sp)
    80005168:	6666                	ld	a2,88(sp)
    8000516a:	7686                	ld	a3,96(sp)
    8000516c:	7726                	ld	a4,104(sp)
    8000516e:	77c6                	ld	a5,112(sp)
    80005170:	7866                	ld	a6,120(sp)
    80005172:	688a                	ld	a7,128(sp)
    80005174:	692a                	ld	s2,136(sp)
    80005176:	69ca                	ld	s3,144(sp)
    80005178:	6a6a                	ld	s4,152(sp)
    8000517a:	7a8a                	ld	s5,160(sp)
    8000517c:	7b2a                	ld	s6,168(sp)
    8000517e:	7bca                	ld	s7,176(sp)
    80005180:	7c6a                	ld	s8,184(sp)
    80005182:	6c8e                	ld	s9,192(sp)
    80005184:	6d2e                	ld	s10,200(sp)
    80005186:	6dce                	ld	s11,208(sp)
    80005188:	6e6e                	ld	t3,216(sp)
    8000518a:	7e8e                	ld	t4,224(sp)
    8000518c:	7f2e                	ld	t5,232(sp)
    8000518e:	7fce                	ld	t6,240(sp)
    80005190:	6111                	addi	sp,sp,256
    80005192:	10200073          	sret
    80005196:	00000013          	nop
    8000519a:	00000013          	nop
    8000519e:	0001                	nop

00000000800051a0 <timervec>:
    800051a0:	34051573          	csrrw	a0,mscratch,a0
    800051a4:	e10c                	sd	a1,0(a0)
    800051a6:	e510                	sd	a2,8(a0)
    800051a8:	e914                	sd	a3,16(a0)
    800051aa:	6d0c                	ld	a1,24(a0)
    800051ac:	7110                	ld	a2,32(a0)
    800051ae:	6194                	ld	a3,0(a1)
    800051b0:	96b2                	add	a3,a3,a2
    800051b2:	e194                	sd	a3,0(a1)
    800051b4:	4589                	li	a1,2
    800051b6:	14459073          	csrw	sip,a1
    800051ba:	6914                	ld	a3,16(a0)
    800051bc:	6510                	ld	a2,8(a0)
    800051be:	610c                	ld	a1,0(a0)
    800051c0:	34051573          	csrrw	a0,mscratch,a0
    800051c4:	30200073          	mret
	...

00000000800051ca <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800051ca:	1141                	addi	sp,sp,-16
    800051cc:	e422                	sd	s0,8(sp)
    800051ce:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800051d0:	0c0007b7          	lui	a5,0xc000
    800051d4:	4705                	li	a4,1
    800051d6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800051d8:	c3d8                	sw	a4,4(a5)
}
    800051da:	6422                	ld	s0,8(sp)
    800051dc:	0141                	addi	sp,sp,16
    800051de:	8082                	ret

00000000800051e0 <plicinithart>:

void
plicinithart(void)
{
    800051e0:	1141                	addi	sp,sp,-16
    800051e2:	e406                	sd	ra,8(sp)
    800051e4:	e022                	sd	s0,0(sp)
    800051e6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	c96080e7          	jalr	-874(ra) # 80000e7e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800051f0:	0085171b          	slliw	a4,a0,0x8
    800051f4:	0c0027b7          	lui	a5,0xc002
    800051f8:	97ba                	add	a5,a5,a4
    800051fa:	40200713          	li	a4,1026
    800051fe:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005202:	00d5151b          	slliw	a0,a0,0xd
    80005206:	0c2017b7          	lui	a5,0xc201
    8000520a:	97aa                	add	a5,a5,a0
    8000520c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005210:	60a2                	ld	ra,8(sp)
    80005212:	6402                	ld	s0,0(sp)
    80005214:	0141                	addi	sp,sp,16
    80005216:	8082                	ret

0000000080005218 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005218:	1141                	addi	sp,sp,-16
    8000521a:	e406                	sd	ra,8(sp)
    8000521c:	e022                	sd	s0,0(sp)
    8000521e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005220:	ffffc097          	auipc	ra,0xffffc
    80005224:	c5e080e7          	jalr	-930(ra) # 80000e7e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005228:	00d5151b          	slliw	a0,a0,0xd
    8000522c:	0c2017b7          	lui	a5,0xc201
    80005230:	97aa                	add	a5,a5,a0
  return irq;
}
    80005232:	43c8                	lw	a0,4(a5)
    80005234:	60a2                	ld	ra,8(sp)
    80005236:	6402                	ld	s0,0(sp)
    80005238:	0141                	addi	sp,sp,16
    8000523a:	8082                	ret

000000008000523c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000523c:	1101                	addi	sp,sp,-32
    8000523e:	ec06                	sd	ra,24(sp)
    80005240:	e822                	sd	s0,16(sp)
    80005242:	e426                	sd	s1,8(sp)
    80005244:	1000                	addi	s0,sp,32
    80005246:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	c36080e7          	jalr	-970(ra) # 80000e7e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005250:	00d5151b          	slliw	a0,a0,0xd
    80005254:	0c2017b7          	lui	a5,0xc201
    80005258:	97aa                	add	a5,a5,a0
    8000525a:	c3c4                	sw	s1,4(a5)
}
    8000525c:	60e2                	ld	ra,24(sp)
    8000525e:	6442                	ld	s0,16(sp)
    80005260:	64a2                	ld	s1,8(sp)
    80005262:	6105                	addi	sp,sp,32
    80005264:	8082                	ret

0000000080005266 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005266:	1141                	addi	sp,sp,-16
    80005268:	e406                	sd	ra,8(sp)
    8000526a:	e022                	sd	s0,0(sp)
    8000526c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000526e:	479d                	li	a5,7
    80005270:	04a7cc63          	blt	a5,a0,800052c8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005274:	00014797          	auipc	a5,0x14
    80005278:	75c78793          	addi	a5,a5,1884 # 800199d0 <disk>
    8000527c:	97aa                	add	a5,a5,a0
    8000527e:	0187c783          	lbu	a5,24(a5)
    80005282:	ebb9                	bnez	a5,800052d8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005284:	00451693          	slli	a3,a0,0x4
    80005288:	00014797          	auipc	a5,0x14
    8000528c:	74878793          	addi	a5,a5,1864 # 800199d0 <disk>
    80005290:	6398                	ld	a4,0(a5)
    80005292:	9736                	add	a4,a4,a3
    80005294:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005298:	6398                	ld	a4,0(a5)
    8000529a:	9736                	add	a4,a4,a3
    8000529c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800052a0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800052a4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800052a8:	97aa                	add	a5,a5,a0
    800052aa:	4705                	li	a4,1
    800052ac:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800052b0:	00014517          	auipc	a0,0x14
    800052b4:	73850513          	addi	a0,a0,1848 # 800199e8 <disk+0x18>
    800052b8:	ffffc097          	auipc	ra,0xffffc
    800052bc:	2fe080e7          	jalr	766(ra) # 800015b6 <wakeup>
}
    800052c0:	60a2                	ld	ra,8(sp)
    800052c2:	6402                	ld	s0,0(sp)
    800052c4:	0141                	addi	sp,sp,16
    800052c6:	8082                	ret
    panic("free_desc 1");
    800052c8:	00003517          	auipc	a0,0x3
    800052cc:	3f850513          	addi	a0,a0,1016 # 800086c0 <syscalls+0x2f0>
    800052d0:	00001097          	auipc	ra,0x1
    800052d4:	a0c080e7          	jalr	-1524(ra) # 80005cdc <panic>
    panic("free_desc 2");
    800052d8:	00003517          	auipc	a0,0x3
    800052dc:	3f850513          	addi	a0,a0,1016 # 800086d0 <syscalls+0x300>
    800052e0:	00001097          	auipc	ra,0x1
    800052e4:	9fc080e7          	jalr	-1540(ra) # 80005cdc <panic>

00000000800052e8 <virtio_disk_init>:
{
    800052e8:	1101                	addi	sp,sp,-32
    800052ea:	ec06                	sd	ra,24(sp)
    800052ec:	e822                	sd	s0,16(sp)
    800052ee:	e426                	sd	s1,8(sp)
    800052f0:	e04a                	sd	s2,0(sp)
    800052f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800052f4:	00003597          	auipc	a1,0x3
    800052f8:	3ec58593          	addi	a1,a1,1004 # 800086e0 <syscalls+0x310>
    800052fc:	00014517          	auipc	a0,0x14
    80005300:	7fc50513          	addi	a0,a0,2044 # 80019af8 <disk+0x128>
    80005304:	00001097          	auipc	ra,0x1
    80005308:	e80080e7          	jalr	-384(ra) # 80006184 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000530c:	100017b7          	lui	a5,0x10001
    80005310:	4398                	lw	a4,0(a5)
    80005312:	2701                	sext.w	a4,a4
    80005314:	747277b7          	lui	a5,0x74727
    80005318:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000531c:	14f71b63          	bne	a4,a5,80005472 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005320:	100017b7          	lui	a5,0x10001
    80005324:	43dc                	lw	a5,4(a5)
    80005326:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005328:	4709                	li	a4,2
    8000532a:	14e79463          	bne	a5,a4,80005472 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000532e:	100017b7          	lui	a5,0x10001
    80005332:	479c                	lw	a5,8(a5)
    80005334:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005336:	12e79e63          	bne	a5,a4,80005472 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000533a:	100017b7          	lui	a5,0x10001
    8000533e:	47d8                	lw	a4,12(a5)
    80005340:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005342:	554d47b7          	lui	a5,0x554d4
    80005346:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000534a:	12f71463          	bne	a4,a5,80005472 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000534e:	100017b7          	lui	a5,0x10001
    80005352:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005356:	4705                	li	a4,1
    80005358:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000535a:	470d                	li	a4,3
    8000535c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000535e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005360:	c7ffe6b7          	lui	a3,0xc7ffe
    80005364:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdca0f>
    80005368:	8f75                	and	a4,a4,a3
    8000536a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000536c:	472d                	li	a4,11
    8000536e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005370:	5bbc                	lw	a5,112(a5)
    80005372:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005376:	8ba1                	andi	a5,a5,8
    80005378:	10078563          	beqz	a5,80005482 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000537c:	100017b7          	lui	a5,0x10001
    80005380:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005384:	43fc                	lw	a5,68(a5)
    80005386:	2781                	sext.w	a5,a5
    80005388:	10079563          	bnez	a5,80005492 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000538c:	100017b7          	lui	a5,0x10001
    80005390:	5bdc                	lw	a5,52(a5)
    80005392:	2781                	sext.w	a5,a5
  if(max == 0)
    80005394:	10078763          	beqz	a5,800054a2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005398:	471d                	li	a4,7
    8000539a:	10f77c63          	bgeu	a4,a5,800054b2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000539e:	ffffb097          	auipc	ra,0xffffb
    800053a2:	d7c080e7          	jalr	-644(ra) # 8000011a <kalloc>
    800053a6:	00014497          	auipc	s1,0x14
    800053aa:	62a48493          	addi	s1,s1,1578 # 800199d0 <disk>
    800053ae:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800053b0:	ffffb097          	auipc	ra,0xffffb
    800053b4:	d6a080e7          	jalr	-662(ra) # 8000011a <kalloc>
    800053b8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800053ba:	ffffb097          	auipc	ra,0xffffb
    800053be:	d60080e7          	jalr	-672(ra) # 8000011a <kalloc>
    800053c2:	87aa                	mv	a5,a0
    800053c4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800053c6:	6088                	ld	a0,0(s1)
    800053c8:	cd6d                	beqz	a0,800054c2 <virtio_disk_init+0x1da>
    800053ca:	00014717          	auipc	a4,0x14
    800053ce:	60e73703          	ld	a4,1550(a4) # 800199d8 <disk+0x8>
    800053d2:	cb65                	beqz	a4,800054c2 <virtio_disk_init+0x1da>
    800053d4:	c7fd                	beqz	a5,800054c2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800053d6:	6605                	lui	a2,0x1
    800053d8:	4581                	li	a1,0
    800053da:	ffffb097          	auipc	ra,0xffffb
    800053de:	da0080e7          	jalr	-608(ra) # 8000017a <memset>
  memset(disk.avail, 0, PGSIZE);
    800053e2:	00014497          	auipc	s1,0x14
    800053e6:	5ee48493          	addi	s1,s1,1518 # 800199d0 <disk>
    800053ea:	6605                	lui	a2,0x1
    800053ec:	4581                	li	a1,0
    800053ee:	6488                	ld	a0,8(s1)
    800053f0:	ffffb097          	auipc	ra,0xffffb
    800053f4:	d8a080e7          	jalr	-630(ra) # 8000017a <memset>
  memset(disk.used, 0, PGSIZE);
    800053f8:	6605                	lui	a2,0x1
    800053fa:	4581                	li	a1,0
    800053fc:	6888                	ld	a0,16(s1)
    800053fe:	ffffb097          	auipc	ra,0xffffb
    80005402:	d7c080e7          	jalr	-644(ra) # 8000017a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005406:	100017b7          	lui	a5,0x10001
    8000540a:	4721                	li	a4,8
    8000540c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000540e:	4098                	lw	a4,0(s1)
    80005410:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005414:	40d8                	lw	a4,4(s1)
    80005416:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000541a:	6498                	ld	a4,8(s1)
    8000541c:	0007069b          	sext.w	a3,a4
    80005420:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005424:	9701                	srai	a4,a4,0x20
    80005426:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000542a:	6898                	ld	a4,16(s1)
    8000542c:	0007069b          	sext.w	a3,a4
    80005430:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005434:	9701                	srai	a4,a4,0x20
    80005436:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000543a:	4705                	li	a4,1
    8000543c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000543e:	00e48c23          	sb	a4,24(s1)
    80005442:	00e48ca3          	sb	a4,25(s1)
    80005446:	00e48d23          	sb	a4,26(s1)
    8000544a:	00e48da3          	sb	a4,27(s1)
    8000544e:	00e48e23          	sb	a4,28(s1)
    80005452:	00e48ea3          	sb	a4,29(s1)
    80005456:	00e48f23          	sb	a4,30(s1)
    8000545a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000545e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005462:	0727a823          	sw	s2,112(a5)
}
    80005466:	60e2                	ld	ra,24(sp)
    80005468:	6442                	ld	s0,16(sp)
    8000546a:	64a2                	ld	s1,8(sp)
    8000546c:	6902                	ld	s2,0(sp)
    8000546e:	6105                	addi	sp,sp,32
    80005470:	8082                	ret
    panic("could not find virtio disk");
    80005472:	00003517          	auipc	a0,0x3
    80005476:	27e50513          	addi	a0,a0,638 # 800086f0 <syscalls+0x320>
    8000547a:	00001097          	auipc	ra,0x1
    8000547e:	862080e7          	jalr	-1950(ra) # 80005cdc <panic>
    panic("virtio disk FEATURES_OK unset");
    80005482:	00003517          	auipc	a0,0x3
    80005486:	28e50513          	addi	a0,a0,654 # 80008710 <syscalls+0x340>
    8000548a:	00001097          	auipc	ra,0x1
    8000548e:	852080e7          	jalr	-1966(ra) # 80005cdc <panic>
    panic("virtio disk should not be ready");
    80005492:	00003517          	auipc	a0,0x3
    80005496:	29e50513          	addi	a0,a0,670 # 80008730 <syscalls+0x360>
    8000549a:	00001097          	auipc	ra,0x1
    8000549e:	842080e7          	jalr	-1982(ra) # 80005cdc <panic>
    panic("virtio disk has no queue 0");
    800054a2:	00003517          	auipc	a0,0x3
    800054a6:	2ae50513          	addi	a0,a0,686 # 80008750 <syscalls+0x380>
    800054aa:	00001097          	auipc	ra,0x1
    800054ae:	832080e7          	jalr	-1998(ra) # 80005cdc <panic>
    panic("virtio disk max queue too short");
    800054b2:	00003517          	auipc	a0,0x3
    800054b6:	2be50513          	addi	a0,a0,702 # 80008770 <syscalls+0x3a0>
    800054ba:	00001097          	auipc	ra,0x1
    800054be:	822080e7          	jalr	-2014(ra) # 80005cdc <panic>
    panic("virtio disk kalloc");
    800054c2:	00003517          	auipc	a0,0x3
    800054c6:	2ce50513          	addi	a0,a0,718 # 80008790 <syscalls+0x3c0>
    800054ca:	00001097          	auipc	ra,0x1
    800054ce:	812080e7          	jalr	-2030(ra) # 80005cdc <panic>

00000000800054d2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800054d2:	7119                	addi	sp,sp,-128
    800054d4:	fc86                	sd	ra,120(sp)
    800054d6:	f8a2                	sd	s0,112(sp)
    800054d8:	f4a6                	sd	s1,104(sp)
    800054da:	f0ca                	sd	s2,96(sp)
    800054dc:	ecce                	sd	s3,88(sp)
    800054de:	e8d2                	sd	s4,80(sp)
    800054e0:	e4d6                	sd	s5,72(sp)
    800054e2:	e0da                	sd	s6,64(sp)
    800054e4:	fc5e                	sd	s7,56(sp)
    800054e6:	f862                	sd	s8,48(sp)
    800054e8:	f466                	sd	s9,40(sp)
    800054ea:	f06a                	sd	s10,32(sp)
    800054ec:	ec6e                	sd	s11,24(sp)
    800054ee:	0100                	addi	s0,sp,128
    800054f0:	8aaa                	mv	s5,a0
    800054f2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800054f4:	00c52d03          	lw	s10,12(a0)
    800054f8:	001d1d1b          	slliw	s10,s10,0x1
    800054fc:	1d02                	slli	s10,s10,0x20
    800054fe:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005502:	00014517          	auipc	a0,0x14
    80005506:	5f650513          	addi	a0,a0,1526 # 80019af8 <disk+0x128>
    8000550a:	00001097          	auipc	ra,0x1
    8000550e:	d0a080e7          	jalr	-758(ra) # 80006214 <acquire>
  for(int i = 0; i < 3; i++){
    80005512:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005514:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005516:	00014b97          	auipc	s7,0x14
    8000551a:	4bab8b93          	addi	s7,s7,1210 # 800199d0 <disk>
  for(int i = 0; i < 3; i++){
    8000551e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005520:	00014c97          	auipc	s9,0x14
    80005524:	5d8c8c93          	addi	s9,s9,1496 # 80019af8 <disk+0x128>
    80005528:	a08d                	j	8000558a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000552a:	00fb8733          	add	a4,s7,a5
    8000552e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005532:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005534:	0207c563          	bltz	a5,8000555e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005538:	2905                	addiw	s2,s2,1
    8000553a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000553c:	05690c63          	beq	s2,s6,80005594 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005540:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005542:	00014717          	auipc	a4,0x14
    80005546:	48e70713          	addi	a4,a4,1166 # 800199d0 <disk>
    8000554a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000554c:	01874683          	lbu	a3,24(a4)
    80005550:	fee9                	bnez	a3,8000552a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005552:	2785                	addiw	a5,a5,1
    80005554:	0705                	addi	a4,a4,1
    80005556:	fe979be3          	bne	a5,s1,8000554c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000555a:	57fd                	li	a5,-1
    8000555c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000555e:	01205d63          	blez	s2,80005578 <virtio_disk_rw+0xa6>
    80005562:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005564:	000a2503          	lw	a0,0(s4)
    80005568:	00000097          	auipc	ra,0x0
    8000556c:	cfe080e7          	jalr	-770(ra) # 80005266 <free_desc>
      for(int j = 0; j < i; j++)
    80005570:	2d85                	addiw	s11,s11,1
    80005572:	0a11                	addi	s4,s4,4
    80005574:	ff2d98e3          	bne	s11,s2,80005564 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005578:	85e6                	mv	a1,s9
    8000557a:	00014517          	auipc	a0,0x14
    8000557e:	46e50513          	addi	a0,a0,1134 # 800199e8 <disk+0x18>
    80005582:	ffffc097          	auipc	ra,0xffffc
    80005586:	fd0080e7          	jalr	-48(ra) # 80001552 <sleep>
  for(int i = 0; i < 3; i++){
    8000558a:	f8040a13          	addi	s4,s0,-128
{
    8000558e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005590:	894e                	mv	s2,s3
    80005592:	b77d                	j	80005540 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005594:	f8042503          	lw	a0,-128(s0)
    80005598:	00a50713          	addi	a4,a0,10
    8000559c:	0712                	slli	a4,a4,0x4

  if(write)
    8000559e:	00014797          	auipc	a5,0x14
    800055a2:	43278793          	addi	a5,a5,1074 # 800199d0 <disk>
    800055a6:	00e786b3          	add	a3,a5,a4
    800055aa:	01803633          	snez	a2,s8
    800055ae:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800055b0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800055b4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800055b8:	f6070613          	addi	a2,a4,-160
    800055bc:	6394                	ld	a3,0(a5)
    800055be:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800055c0:	00870593          	addi	a1,a4,8
    800055c4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800055c6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800055c8:	0007b803          	ld	a6,0(a5)
    800055cc:	9642                	add	a2,a2,a6
    800055ce:	46c1                	li	a3,16
    800055d0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800055d2:	4585                	li	a1,1
    800055d4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800055d8:	f8442683          	lw	a3,-124(s0)
    800055dc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800055e0:	0692                	slli	a3,a3,0x4
    800055e2:	9836                	add	a6,a6,a3
    800055e4:	058a8613          	addi	a2,s5,88
    800055e8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800055ec:	0007b803          	ld	a6,0(a5)
    800055f0:	96c2                	add	a3,a3,a6
    800055f2:	40000613          	li	a2,1024
    800055f6:	c690                	sw	a2,8(a3)
  if(write)
    800055f8:	001c3613          	seqz	a2,s8
    800055fc:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005600:	00166613          	ori	a2,a2,1
    80005604:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005608:	f8842603          	lw	a2,-120(s0)
    8000560c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005610:	00250693          	addi	a3,a0,2
    80005614:	0692                	slli	a3,a3,0x4
    80005616:	96be                	add	a3,a3,a5
    80005618:	58fd                	li	a7,-1
    8000561a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000561e:	0612                	slli	a2,a2,0x4
    80005620:	9832                	add	a6,a6,a2
    80005622:	f9070713          	addi	a4,a4,-112
    80005626:	973e                	add	a4,a4,a5
    80005628:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000562c:	6398                	ld	a4,0(a5)
    8000562e:	9732                	add	a4,a4,a2
    80005630:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005632:	4609                	li	a2,2
    80005634:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005638:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000563c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005640:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005644:	6794                	ld	a3,8(a5)
    80005646:	0026d703          	lhu	a4,2(a3)
    8000564a:	8b1d                	andi	a4,a4,7
    8000564c:	0706                	slli	a4,a4,0x1
    8000564e:	96ba                	add	a3,a3,a4
    80005650:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005654:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005658:	6798                	ld	a4,8(a5)
    8000565a:	00275783          	lhu	a5,2(a4)
    8000565e:	2785                	addiw	a5,a5,1
    80005660:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005664:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005668:	100017b7          	lui	a5,0x10001
    8000566c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005670:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80005674:	00014917          	auipc	s2,0x14
    80005678:	48490913          	addi	s2,s2,1156 # 80019af8 <disk+0x128>
  while(b->disk == 1) {
    8000567c:	4485                	li	s1,1
    8000567e:	00b79c63          	bne	a5,a1,80005696 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80005682:	85ca                	mv	a1,s2
    80005684:	8556                	mv	a0,s5
    80005686:	ffffc097          	auipc	ra,0xffffc
    8000568a:	ecc080e7          	jalr	-308(ra) # 80001552 <sleep>
  while(b->disk == 1) {
    8000568e:	004aa783          	lw	a5,4(s5)
    80005692:	fe9788e3          	beq	a5,s1,80005682 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80005696:	f8042903          	lw	s2,-128(s0)
    8000569a:	00290713          	addi	a4,s2,2
    8000569e:	0712                	slli	a4,a4,0x4
    800056a0:	00014797          	auipc	a5,0x14
    800056a4:	33078793          	addi	a5,a5,816 # 800199d0 <disk>
    800056a8:	97ba                	add	a5,a5,a4
    800056aa:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800056ae:	00014997          	auipc	s3,0x14
    800056b2:	32298993          	addi	s3,s3,802 # 800199d0 <disk>
    800056b6:	00491713          	slli	a4,s2,0x4
    800056ba:	0009b783          	ld	a5,0(s3)
    800056be:	97ba                	add	a5,a5,a4
    800056c0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800056c4:	854a                	mv	a0,s2
    800056c6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800056ca:	00000097          	auipc	ra,0x0
    800056ce:	b9c080e7          	jalr	-1124(ra) # 80005266 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800056d2:	8885                	andi	s1,s1,1
    800056d4:	f0ed                	bnez	s1,800056b6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800056d6:	00014517          	auipc	a0,0x14
    800056da:	42250513          	addi	a0,a0,1058 # 80019af8 <disk+0x128>
    800056de:	00001097          	auipc	ra,0x1
    800056e2:	bea080e7          	jalr	-1046(ra) # 800062c8 <release>
}
    800056e6:	70e6                	ld	ra,120(sp)
    800056e8:	7446                	ld	s0,112(sp)
    800056ea:	74a6                	ld	s1,104(sp)
    800056ec:	7906                	ld	s2,96(sp)
    800056ee:	69e6                	ld	s3,88(sp)
    800056f0:	6a46                	ld	s4,80(sp)
    800056f2:	6aa6                	ld	s5,72(sp)
    800056f4:	6b06                	ld	s6,64(sp)
    800056f6:	7be2                	ld	s7,56(sp)
    800056f8:	7c42                	ld	s8,48(sp)
    800056fa:	7ca2                	ld	s9,40(sp)
    800056fc:	7d02                	ld	s10,32(sp)
    800056fe:	6de2                	ld	s11,24(sp)
    80005700:	6109                	addi	sp,sp,128
    80005702:	8082                	ret

0000000080005704 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005704:	1101                	addi	sp,sp,-32
    80005706:	ec06                	sd	ra,24(sp)
    80005708:	e822                	sd	s0,16(sp)
    8000570a:	e426                	sd	s1,8(sp)
    8000570c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000570e:	00014497          	auipc	s1,0x14
    80005712:	2c248493          	addi	s1,s1,706 # 800199d0 <disk>
    80005716:	00014517          	auipc	a0,0x14
    8000571a:	3e250513          	addi	a0,a0,994 # 80019af8 <disk+0x128>
    8000571e:	00001097          	auipc	ra,0x1
    80005722:	af6080e7          	jalr	-1290(ra) # 80006214 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005726:	10001737          	lui	a4,0x10001
    8000572a:	533c                	lw	a5,96(a4)
    8000572c:	8b8d                	andi	a5,a5,3
    8000572e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005730:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005734:	689c                	ld	a5,16(s1)
    80005736:	0204d703          	lhu	a4,32(s1)
    8000573a:	0027d783          	lhu	a5,2(a5)
    8000573e:	04f70863          	beq	a4,a5,8000578e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005742:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005746:	6898                	ld	a4,16(s1)
    80005748:	0204d783          	lhu	a5,32(s1)
    8000574c:	8b9d                	andi	a5,a5,7
    8000574e:	078e                	slli	a5,a5,0x3
    80005750:	97ba                	add	a5,a5,a4
    80005752:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005754:	00278713          	addi	a4,a5,2
    80005758:	0712                	slli	a4,a4,0x4
    8000575a:	9726                	add	a4,a4,s1
    8000575c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005760:	e721                	bnez	a4,800057a8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005762:	0789                	addi	a5,a5,2
    80005764:	0792                	slli	a5,a5,0x4
    80005766:	97a6                	add	a5,a5,s1
    80005768:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000576a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000576e:	ffffc097          	auipc	ra,0xffffc
    80005772:	e48080e7          	jalr	-440(ra) # 800015b6 <wakeup>

    disk.used_idx += 1;
    80005776:	0204d783          	lhu	a5,32(s1)
    8000577a:	2785                	addiw	a5,a5,1
    8000577c:	17c2                	slli	a5,a5,0x30
    8000577e:	93c1                	srli	a5,a5,0x30
    80005780:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005784:	6898                	ld	a4,16(s1)
    80005786:	00275703          	lhu	a4,2(a4)
    8000578a:	faf71ce3          	bne	a4,a5,80005742 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000578e:	00014517          	auipc	a0,0x14
    80005792:	36a50513          	addi	a0,a0,874 # 80019af8 <disk+0x128>
    80005796:	00001097          	auipc	ra,0x1
    8000579a:	b32080e7          	jalr	-1230(ra) # 800062c8 <release>
}
    8000579e:	60e2                	ld	ra,24(sp)
    800057a0:	6442                	ld	s0,16(sp)
    800057a2:	64a2                	ld	s1,8(sp)
    800057a4:	6105                	addi	sp,sp,32
    800057a6:	8082                	ret
      panic("virtio_disk_intr status");
    800057a8:	00003517          	auipc	a0,0x3
    800057ac:	00050513          	mv	a0,a0
    800057b0:	00000097          	auipc	ra,0x0
    800057b4:	52c080e7          	jalr	1324(ra) # 80005cdc <panic>

00000000800057b8 <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    800057b8:	1141                	addi	sp,sp,-16
    800057ba:	e422                	sd	s0,8(sp)
    800057bc:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800057be:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    800057c2:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    800057c6:	0037979b          	slliw	a5,a5,0x3
    800057ca:	02004737          	lui	a4,0x2004
    800057ce:	97ba                	add	a5,a5,a4
    800057d0:	0200c737          	lui	a4,0x200c
    800057d4:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    800057d8:	000f4637          	lui	a2,0xf4
    800057dc:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    800057e0:	9732                	add	a4,a4,a2
    800057e2:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    800057e4:	00259693          	slli	a3,a1,0x2
    800057e8:	96ae                	add	a3,a3,a1
    800057ea:	068e                	slli	a3,a3,0x3
    800057ec:	00014717          	auipc	a4,0x14
    800057f0:	32470713          	addi	a4,a4,804 # 80019b10 <timer_scratch>
    800057f4:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    800057f6:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    800057f8:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    800057fa:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    800057fe:	00000797          	auipc	a5,0x0
    80005802:	9a278793          	addi	a5,a5,-1630 # 800051a0 <timervec>
    80005806:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000580a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000580e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005812:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005816:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000581a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000581e:	30479073          	csrw	mie,a5
}
    80005822:	6422                	ld	s0,8(sp)
    80005824:	0141                	addi	sp,sp,16
    80005826:	8082                	ret

0000000080005828 <start>:
{
    80005828:	1141                	addi	sp,sp,-16
    8000582a:	e406                	sd	ra,8(sp)
    8000582c:	e022                	sd	s0,0(sp)
    8000582e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005830:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005834:	7779                	lui	a4,0xffffe
    80005836:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdcaaf>
    8000583a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000583c:	6705                	lui	a4,0x1
    8000583e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005842:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005844:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80005848:	ffffb797          	auipc	a5,0xffffb
    8000584c:	ad878793          	addi	a5,a5,-1320 # 80000320 <main>
    80005850:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80005854:	4781                	li	a5,0
    80005856:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    8000585a:	67c1                	lui	a5,0x10
    8000585c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000585e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005862:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80005866:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000586a:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000586e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005872:	57fd                	li	a5,-1
    80005874:	83a9                	srli	a5,a5,0xa
    80005876:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    8000587a:	47bd                	li	a5,15
    8000587c:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005880:	00000097          	auipc	ra,0x0
    80005884:	f38080e7          	jalr	-200(ra) # 800057b8 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005888:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    8000588c:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    8000588e:	823e                	mv	tp,a5
  asm volatile("mret");
    80005890:	30200073          	mret
}
    80005894:	60a2                	ld	ra,8(sp)
    80005896:	6402                	ld	s0,0(sp)
    80005898:	0141                	addi	sp,sp,16
    8000589a:	8082                	ret

000000008000589c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    8000589c:	715d                	addi	sp,sp,-80
    8000589e:	e486                	sd	ra,72(sp)
    800058a0:	e0a2                	sd	s0,64(sp)
    800058a2:	fc26                	sd	s1,56(sp)
    800058a4:	f84a                	sd	s2,48(sp)
    800058a6:	f44e                	sd	s3,40(sp)
    800058a8:	f052                	sd	s4,32(sp)
    800058aa:	ec56                	sd	s5,24(sp)
    800058ac:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800058ae:	04c05763          	blez	a2,800058fc <consolewrite+0x60>
    800058b2:	8a2a                	mv	s4,a0
    800058b4:	84ae                	mv	s1,a1
    800058b6:	89b2                	mv	s3,a2
    800058b8:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800058ba:	5afd                	li	s5,-1
    800058bc:	4685                	li	a3,1
    800058be:	8626                	mv	a2,s1
    800058c0:	85d2                	mv	a1,s4
    800058c2:	fbf40513          	addi	a0,s0,-65
    800058c6:	ffffc097          	auipc	ra,0xffffc
    800058ca:	0ea080e7          	jalr	234(ra) # 800019b0 <either_copyin>
    800058ce:	01550d63          	beq	a0,s5,800058e8 <consolewrite+0x4c>
      break;
    uartputc(c);
    800058d2:	fbf44503          	lbu	a0,-65(s0)
    800058d6:	00000097          	auipc	ra,0x0
    800058da:	784080e7          	jalr	1924(ra) # 8000605a <uartputc>
  for(i = 0; i < n; i++){
    800058de:	2905                	addiw	s2,s2,1
    800058e0:	0485                	addi	s1,s1,1
    800058e2:	fd299de3          	bne	s3,s2,800058bc <consolewrite+0x20>
    800058e6:	894e                	mv	s2,s3
  }

  return i;
}
    800058e8:	854a                	mv	a0,s2
    800058ea:	60a6                	ld	ra,72(sp)
    800058ec:	6406                	ld	s0,64(sp)
    800058ee:	74e2                	ld	s1,56(sp)
    800058f0:	7942                	ld	s2,48(sp)
    800058f2:	79a2                	ld	s3,40(sp)
    800058f4:	7a02                	ld	s4,32(sp)
    800058f6:	6ae2                	ld	s5,24(sp)
    800058f8:	6161                	addi	sp,sp,80
    800058fa:	8082                	ret
  for(i = 0; i < n; i++){
    800058fc:	4901                	li	s2,0
    800058fe:	b7ed                	j	800058e8 <consolewrite+0x4c>

0000000080005900 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005900:	7159                	addi	sp,sp,-112
    80005902:	f486                	sd	ra,104(sp)
    80005904:	f0a2                	sd	s0,96(sp)
    80005906:	eca6                	sd	s1,88(sp)
    80005908:	e8ca                	sd	s2,80(sp)
    8000590a:	e4ce                	sd	s3,72(sp)
    8000590c:	e0d2                	sd	s4,64(sp)
    8000590e:	fc56                	sd	s5,56(sp)
    80005910:	f85a                	sd	s6,48(sp)
    80005912:	f45e                	sd	s7,40(sp)
    80005914:	f062                	sd	s8,32(sp)
    80005916:	ec66                	sd	s9,24(sp)
    80005918:	e86a                	sd	s10,16(sp)
    8000591a:	1880                	addi	s0,sp,112
    8000591c:	8aaa                	mv	s5,a0
    8000591e:	8a2e                	mv	s4,a1
    80005920:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005922:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80005926:	0001c517          	auipc	a0,0x1c
    8000592a:	32a50513          	addi	a0,a0,810 # 80021c50 <cons>
    8000592e:	00001097          	auipc	ra,0x1
    80005932:	8e6080e7          	jalr	-1818(ra) # 80006214 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005936:	0001c497          	auipc	s1,0x1c
    8000593a:	31a48493          	addi	s1,s1,794 # 80021c50 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000593e:	0001c917          	auipc	s2,0x1c
    80005942:	3aa90913          	addi	s2,s2,938 # 80021ce8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80005946:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005948:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000594a:	4ca9                	li	s9,10
  while(n > 0){
    8000594c:	07305b63          	blez	s3,800059c2 <consoleread+0xc2>
    while(cons.r == cons.w){
    80005950:	0984a783          	lw	a5,152(s1)
    80005954:	09c4a703          	lw	a4,156(s1)
    80005958:	02f71763          	bne	a4,a5,80005986 <consoleread+0x86>
      if(killed(myproc())){
    8000595c:	ffffb097          	auipc	ra,0xffffb
    80005960:	54e080e7          	jalr	1358(ra) # 80000eaa <myproc>
    80005964:	ffffc097          	auipc	ra,0xffffc
    80005968:	e96080e7          	jalr	-362(ra) # 800017fa <killed>
    8000596c:	e535                	bnez	a0,800059d8 <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    8000596e:	85a6                	mv	a1,s1
    80005970:	854a                	mv	a0,s2
    80005972:	ffffc097          	auipc	ra,0xffffc
    80005976:	be0080e7          	jalr	-1056(ra) # 80001552 <sleep>
    while(cons.r == cons.w){
    8000597a:	0984a783          	lw	a5,152(s1)
    8000597e:	09c4a703          	lw	a4,156(s1)
    80005982:	fcf70de3          	beq	a4,a5,8000595c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80005986:	0017871b          	addiw	a4,a5,1
    8000598a:	08e4ac23          	sw	a4,152(s1)
    8000598e:	07f7f713          	andi	a4,a5,127
    80005992:	9726                	add	a4,a4,s1
    80005994:	01874703          	lbu	a4,24(a4)
    80005998:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    8000599c:	077d0563          	beq	s10,s7,80005a06 <consoleread+0x106>
    cbuf = c;
    800059a0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800059a4:	4685                	li	a3,1
    800059a6:	f9f40613          	addi	a2,s0,-97
    800059aa:	85d2                	mv	a1,s4
    800059ac:	8556                	mv	a0,s5
    800059ae:	ffffc097          	auipc	ra,0xffffc
    800059b2:	fac080e7          	jalr	-84(ra) # 8000195a <either_copyout>
    800059b6:	01850663          	beq	a0,s8,800059c2 <consoleread+0xc2>
    dst++;
    800059ba:	0a05                	addi	s4,s4,1
    --n;
    800059bc:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800059be:	f99d17e3          	bne	s10,s9,8000594c <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800059c2:	0001c517          	auipc	a0,0x1c
    800059c6:	28e50513          	addi	a0,a0,654 # 80021c50 <cons>
    800059ca:	00001097          	auipc	ra,0x1
    800059ce:	8fe080e7          	jalr	-1794(ra) # 800062c8 <release>

  return target - n;
    800059d2:	413b053b          	subw	a0,s6,s3
    800059d6:	a811                	j	800059ea <consoleread+0xea>
        release(&cons.lock);
    800059d8:	0001c517          	auipc	a0,0x1c
    800059dc:	27850513          	addi	a0,a0,632 # 80021c50 <cons>
    800059e0:	00001097          	auipc	ra,0x1
    800059e4:	8e8080e7          	jalr	-1816(ra) # 800062c8 <release>
        return -1;
    800059e8:	557d                	li	a0,-1
}
    800059ea:	70a6                	ld	ra,104(sp)
    800059ec:	7406                	ld	s0,96(sp)
    800059ee:	64e6                	ld	s1,88(sp)
    800059f0:	6946                	ld	s2,80(sp)
    800059f2:	69a6                	ld	s3,72(sp)
    800059f4:	6a06                	ld	s4,64(sp)
    800059f6:	7ae2                	ld	s5,56(sp)
    800059f8:	7b42                	ld	s6,48(sp)
    800059fa:	7ba2                	ld	s7,40(sp)
    800059fc:	7c02                	ld	s8,32(sp)
    800059fe:	6ce2                	ld	s9,24(sp)
    80005a00:	6d42                	ld	s10,16(sp)
    80005a02:	6165                	addi	sp,sp,112
    80005a04:	8082                	ret
      if(n < target){
    80005a06:	0009871b          	sext.w	a4,s3
    80005a0a:	fb677ce3          	bgeu	a4,s6,800059c2 <consoleread+0xc2>
        cons.r--;
    80005a0e:	0001c717          	auipc	a4,0x1c
    80005a12:	2cf72d23          	sw	a5,730(a4) # 80021ce8 <cons+0x98>
    80005a16:	b775                	j	800059c2 <consoleread+0xc2>

0000000080005a18 <consputc>:
{
    80005a18:	1141                	addi	sp,sp,-16
    80005a1a:	e406                	sd	ra,8(sp)
    80005a1c:	e022                	sd	s0,0(sp)
    80005a1e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005a20:	10000793          	li	a5,256
    80005a24:	00f50a63          	beq	a0,a5,80005a38 <consputc+0x20>
    uartputc_sync(c);
    80005a28:	00000097          	auipc	ra,0x0
    80005a2c:	560080e7          	jalr	1376(ra) # 80005f88 <uartputc_sync>
}
    80005a30:	60a2                	ld	ra,8(sp)
    80005a32:	6402                	ld	s0,0(sp)
    80005a34:	0141                	addi	sp,sp,16
    80005a36:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005a38:	4521                	li	a0,8
    80005a3a:	00000097          	auipc	ra,0x0
    80005a3e:	54e080e7          	jalr	1358(ra) # 80005f88 <uartputc_sync>
    80005a42:	02000513          	li	a0,32
    80005a46:	00000097          	auipc	ra,0x0
    80005a4a:	542080e7          	jalr	1346(ra) # 80005f88 <uartputc_sync>
    80005a4e:	4521                	li	a0,8
    80005a50:	00000097          	auipc	ra,0x0
    80005a54:	538080e7          	jalr	1336(ra) # 80005f88 <uartputc_sync>
    80005a58:	bfe1                	j	80005a30 <consputc+0x18>

0000000080005a5a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005a5a:	1101                	addi	sp,sp,-32
    80005a5c:	ec06                	sd	ra,24(sp)
    80005a5e:	e822                	sd	s0,16(sp)
    80005a60:	e426                	sd	s1,8(sp)
    80005a62:	e04a                	sd	s2,0(sp)
    80005a64:	1000                	addi	s0,sp,32
    80005a66:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005a68:	0001c517          	auipc	a0,0x1c
    80005a6c:	1e850513          	addi	a0,a0,488 # 80021c50 <cons>
    80005a70:	00000097          	auipc	ra,0x0
    80005a74:	7a4080e7          	jalr	1956(ra) # 80006214 <acquire>

  switch(c){
    80005a78:	47d5                	li	a5,21
    80005a7a:	0af48663          	beq	s1,a5,80005b26 <consoleintr+0xcc>
    80005a7e:	0297ca63          	blt	a5,s1,80005ab2 <consoleintr+0x58>
    80005a82:	47a1                	li	a5,8
    80005a84:	0ef48763          	beq	s1,a5,80005b72 <consoleintr+0x118>
    80005a88:	47c1                	li	a5,16
    80005a8a:	10f49a63          	bne	s1,a5,80005b9e <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005a8e:	ffffc097          	auipc	ra,0xffffc
    80005a92:	f78080e7          	jalr	-136(ra) # 80001a06 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005a96:	0001c517          	auipc	a0,0x1c
    80005a9a:	1ba50513          	addi	a0,a0,442 # 80021c50 <cons>
    80005a9e:	00001097          	auipc	ra,0x1
    80005aa2:	82a080e7          	jalr	-2006(ra) # 800062c8 <release>
}
    80005aa6:	60e2                	ld	ra,24(sp)
    80005aa8:	6442                	ld	s0,16(sp)
    80005aaa:	64a2                	ld	s1,8(sp)
    80005aac:	6902                	ld	s2,0(sp)
    80005aae:	6105                	addi	sp,sp,32
    80005ab0:	8082                	ret
  switch(c){
    80005ab2:	07f00793          	li	a5,127
    80005ab6:	0af48e63          	beq	s1,a5,80005b72 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005aba:	0001c717          	auipc	a4,0x1c
    80005abe:	19670713          	addi	a4,a4,406 # 80021c50 <cons>
    80005ac2:	0a072783          	lw	a5,160(a4)
    80005ac6:	09872703          	lw	a4,152(a4)
    80005aca:	9f99                	subw	a5,a5,a4
    80005acc:	07f00713          	li	a4,127
    80005ad0:	fcf763e3          	bltu	a4,a5,80005a96 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005ad4:	47b5                	li	a5,13
    80005ad6:	0cf48763          	beq	s1,a5,80005ba4 <consoleintr+0x14a>
      consputc(c);
    80005ada:	8526                	mv	a0,s1
    80005adc:	00000097          	auipc	ra,0x0
    80005ae0:	f3c080e7          	jalr	-196(ra) # 80005a18 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005ae4:	0001c797          	auipc	a5,0x1c
    80005ae8:	16c78793          	addi	a5,a5,364 # 80021c50 <cons>
    80005aec:	0a07a683          	lw	a3,160(a5)
    80005af0:	0016871b          	addiw	a4,a3,1
    80005af4:	0007061b          	sext.w	a2,a4
    80005af8:	0ae7a023          	sw	a4,160(a5)
    80005afc:	07f6f693          	andi	a3,a3,127
    80005b00:	97b6                	add	a5,a5,a3
    80005b02:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005b06:	47a9                	li	a5,10
    80005b08:	0cf48563          	beq	s1,a5,80005bd2 <consoleintr+0x178>
    80005b0c:	4791                	li	a5,4
    80005b0e:	0cf48263          	beq	s1,a5,80005bd2 <consoleintr+0x178>
    80005b12:	0001c797          	auipc	a5,0x1c
    80005b16:	1d67a783          	lw	a5,470(a5) # 80021ce8 <cons+0x98>
    80005b1a:	9f1d                	subw	a4,a4,a5
    80005b1c:	08000793          	li	a5,128
    80005b20:	f6f71be3          	bne	a4,a5,80005a96 <consoleintr+0x3c>
    80005b24:	a07d                	j	80005bd2 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005b26:	0001c717          	auipc	a4,0x1c
    80005b2a:	12a70713          	addi	a4,a4,298 # 80021c50 <cons>
    80005b2e:	0a072783          	lw	a5,160(a4)
    80005b32:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005b36:	0001c497          	auipc	s1,0x1c
    80005b3a:	11a48493          	addi	s1,s1,282 # 80021c50 <cons>
    while(cons.e != cons.w &&
    80005b3e:	4929                	li	s2,10
    80005b40:	f4f70be3          	beq	a4,a5,80005a96 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005b44:	37fd                	addiw	a5,a5,-1
    80005b46:	07f7f713          	andi	a4,a5,127
    80005b4a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005b4c:	01874703          	lbu	a4,24(a4)
    80005b50:	f52703e3          	beq	a4,s2,80005a96 <consoleintr+0x3c>
      cons.e--;
    80005b54:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005b58:	10000513          	li	a0,256
    80005b5c:	00000097          	auipc	ra,0x0
    80005b60:	ebc080e7          	jalr	-324(ra) # 80005a18 <consputc>
    while(cons.e != cons.w &&
    80005b64:	0a04a783          	lw	a5,160(s1)
    80005b68:	09c4a703          	lw	a4,156(s1)
    80005b6c:	fcf71ce3          	bne	a4,a5,80005b44 <consoleintr+0xea>
    80005b70:	b71d                	j	80005a96 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005b72:	0001c717          	auipc	a4,0x1c
    80005b76:	0de70713          	addi	a4,a4,222 # 80021c50 <cons>
    80005b7a:	0a072783          	lw	a5,160(a4)
    80005b7e:	09c72703          	lw	a4,156(a4)
    80005b82:	f0f70ae3          	beq	a4,a5,80005a96 <consoleintr+0x3c>
      cons.e--;
    80005b86:	37fd                	addiw	a5,a5,-1
    80005b88:	0001c717          	auipc	a4,0x1c
    80005b8c:	16f72423          	sw	a5,360(a4) # 80021cf0 <cons+0xa0>
      consputc(BACKSPACE);
    80005b90:	10000513          	li	a0,256
    80005b94:	00000097          	auipc	ra,0x0
    80005b98:	e84080e7          	jalr	-380(ra) # 80005a18 <consputc>
    80005b9c:	bded                	j	80005a96 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005b9e:	ee048ce3          	beqz	s1,80005a96 <consoleintr+0x3c>
    80005ba2:	bf21                	j	80005aba <consoleintr+0x60>
      consputc(c);
    80005ba4:	4529                	li	a0,10
    80005ba6:	00000097          	auipc	ra,0x0
    80005baa:	e72080e7          	jalr	-398(ra) # 80005a18 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005bae:	0001c797          	auipc	a5,0x1c
    80005bb2:	0a278793          	addi	a5,a5,162 # 80021c50 <cons>
    80005bb6:	0a07a703          	lw	a4,160(a5)
    80005bba:	0017069b          	addiw	a3,a4,1
    80005bbe:	0006861b          	sext.w	a2,a3
    80005bc2:	0ad7a023          	sw	a3,160(a5)
    80005bc6:	07f77713          	andi	a4,a4,127
    80005bca:	97ba                	add	a5,a5,a4
    80005bcc:	4729                	li	a4,10
    80005bce:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005bd2:	0001c797          	auipc	a5,0x1c
    80005bd6:	10c7ad23          	sw	a2,282(a5) # 80021cec <cons+0x9c>
        wakeup(&cons.r);
    80005bda:	0001c517          	auipc	a0,0x1c
    80005bde:	10e50513          	addi	a0,a0,270 # 80021ce8 <cons+0x98>
    80005be2:	ffffc097          	auipc	ra,0xffffc
    80005be6:	9d4080e7          	jalr	-1580(ra) # 800015b6 <wakeup>
    80005bea:	b575                	j	80005a96 <consoleintr+0x3c>

0000000080005bec <consoleinit>:

void
consoleinit(void)
{
    80005bec:	1141                	addi	sp,sp,-16
    80005bee:	e406                	sd	ra,8(sp)
    80005bf0:	e022                	sd	s0,0(sp)
    80005bf2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005bf4:	00003597          	auipc	a1,0x3
    80005bf8:	bcc58593          	addi	a1,a1,-1076 # 800087c0 <syscalls+0x3f0>
    80005bfc:	0001c517          	auipc	a0,0x1c
    80005c00:	05450513          	addi	a0,a0,84 # 80021c50 <cons>
    80005c04:	00000097          	auipc	ra,0x0
    80005c08:	580080e7          	jalr	1408(ra) # 80006184 <initlock>

  uartinit();
    80005c0c:	00000097          	auipc	ra,0x0
    80005c10:	32c080e7          	jalr	812(ra) # 80005f38 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005c14:	00013797          	auipc	a5,0x13
    80005c18:	d6478793          	addi	a5,a5,-668 # 80018978 <devsw>
    80005c1c:	00000717          	auipc	a4,0x0
    80005c20:	ce470713          	addi	a4,a4,-796 # 80005900 <consoleread>
    80005c24:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005c26:	00000717          	auipc	a4,0x0
    80005c2a:	c7670713          	addi	a4,a4,-906 # 8000589c <consolewrite>
    80005c2e:	ef98                	sd	a4,24(a5)
}
    80005c30:	60a2                	ld	ra,8(sp)
    80005c32:	6402                	ld	s0,0(sp)
    80005c34:	0141                	addi	sp,sp,16
    80005c36:	8082                	ret

0000000080005c38 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005c38:	7179                	addi	sp,sp,-48
    80005c3a:	f406                	sd	ra,40(sp)
    80005c3c:	f022                	sd	s0,32(sp)
    80005c3e:	ec26                	sd	s1,24(sp)
    80005c40:	e84a                	sd	s2,16(sp)
    80005c42:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005c44:	c219                	beqz	a2,80005c4a <printint+0x12>
    80005c46:	08054763          	bltz	a0,80005cd4 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    80005c4a:	2501                	sext.w	a0,a0
    80005c4c:	4881                	li	a7,0
    80005c4e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005c52:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005c54:	2581                	sext.w	a1,a1
    80005c56:	00003617          	auipc	a2,0x3
    80005c5a:	b9a60613          	addi	a2,a2,-1126 # 800087f0 <digits>
    80005c5e:	883a                	mv	a6,a4
    80005c60:	2705                	addiw	a4,a4,1
    80005c62:	02b577bb          	remuw	a5,a0,a1
    80005c66:	1782                	slli	a5,a5,0x20
    80005c68:	9381                	srli	a5,a5,0x20
    80005c6a:	97b2                	add	a5,a5,a2
    80005c6c:	0007c783          	lbu	a5,0(a5)
    80005c70:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005c74:	0005079b          	sext.w	a5,a0
    80005c78:	02b5553b          	divuw	a0,a0,a1
    80005c7c:	0685                	addi	a3,a3,1
    80005c7e:	feb7f0e3          	bgeu	a5,a1,80005c5e <printint+0x26>

  if(sign)
    80005c82:	00088c63          	beqz	a7,80005c9a <printint+0x62>
    buf[i++] = '-';
    80005c86:	fe070793          	addi	a5,a4,-32
    80005c8a:	00878733          	add	a4,a5,s0
    80005c8e:	02d00793          	li	a5,45
    80005c92:	fef70823          	sb	a5,-16(a4)
    80005c96:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005c9a:	02e05763          	blez	a4,80005cc8 <printint+0x90>
    80005c9e:	fd040793          	addi	a5,s0,-48
    80005ca2:	00e784b3          	add	s1,a5,a4
    80005ca6:	fff78913          	addi	s2,a5,-1
    80005caa:	993a                	add	s2,s2,a4
    80005cac:	377d                	addiw	a4,a4,-1
    80005cae:	1702                	slli	a4,a4,0x20
    80005cb0:	9301                	srli	a4,a4,0x20
    80005cb2:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005cb6:	fff4c503          	lbu	a0,-1(s1)
    80005cba:	00000097          	auipc	ra,0x0
    80005cbe:	d5e080e7          	jalr	-674(ra) # 80005a18 <consputc>
  while(--i >= 0)
    80005cc2:	14fd                	addi	s1,s1,-1
    80005cc4:	ff2499e3          	bne	s1,s2,80005cb6 <printint+0x7e>
}
    80005cc8:	70a2                	ld	ra,40(sp)
    80005cca:	7402                	ld	s0,32(sp)
    80005ccc:	64e2                	ld	s1,24(sp)
    80005cce:	6942                	ld	s2,16(sp)
    80005cd0:	6145                	addi	sp,sp,48
    80005cd2:	8082                	ret
    x = -xx;
    80005cd4:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005cd8:	4885                	li	a7,1
    x = -xx;
    80005cda:	bf95                	j	80005c4e <printint+0x16>

0000000080005cdc <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005cdc:	1101                	addi	sp,sp,-32
    80005cde:	ec06                	sd	ra,24(sp)
    80005ce0:	e822                	sd	s0,16(sp)
    80005ce2:	e426                	sd	s1,8(sp)
    80005ce4:	1000                	addi	s0,sp,32
    80005ce6:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005ce8:	0001c797          	auipc	a5,0x1c
    80005cec:	0207a423          	sw	zero,40(a5) # 80021d10 <pr+0x18>
  printf("panic: ");
    80005cf0:	00003517          	auipc	a0,0x3
    80005cf4:	ad850513          	addi	a0,a0,-1320 # 800087c8 <syscalls+0x3f8>
    80005cf8:	00000097          	auipc	ra,0x0
    80005cfc:	02e080e7          	jalr	46(ra) # 80005d26 <printf>
  printf(s);
    80005d00:	8526                	mv	a0,s1
    80005d02:	00000097          	auipc	ra,0x0
    80005d06:	024080e7          	jalr	36(ra) # 80005d26 <printf>
  printf("\n");
    80005d0a:	00002517          	auipc	a0,0x2
    80005d0e:	33e50513          	addi	a0,a0,830 # 80008048 <etext+0x48>
    80005d12:	00000097          	auipc	ra,0x0
    80005d16:	014080e7          	jalr	20(ra) # 80005d26 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005d1a:	4785                	li	a5,1
    80005d1c:	00003717          	auipc	a4,0x3
    80005d20:	baf72823          	sw	a5,-1104(a4) # 800088cc <panicked>
  for(;;)
    80005d24:	a001                	j	80005d24 <panic+0x48>

0000000080005d26 <printf>:
{
    80005d26:	7131                	addi	sp,sp,-192
    80005d28:	fc86                	sd	ra,120(sp)
    80005d2a:	f8a2                	sd	s0,112(sp)
    80005d2c:	f4a6                	sd	s1,104(sp)
    80005d2e:	f0ca                	sd	s2,96(sp)
    80005d30:	ecce                	sd	s3,88(sp)
    80005d32:	e8d2                	sd	s4,80(sp)
    80005d34:	e4d6                	sd	s5,72(sp)
    80005d36:	e0da                	sd	s6,64(sp)
    80005d38:	fc5e                	sd	s7,56(sp)
    80005d3a:	f862                	sd	s8,48(sp)
    80005d3c:	f466                	sd	s9,40(sp)
    80005d3e:	f06a                	sd	s10,32(sp)
    80005d40:	ec6e                	sd	s11,24(sp)
    80005d42:	0100                	addi	s0,sp,128
    80005d44:	8a2a                	mv	s4,a0
    80005d46:	e40c                	sd	a1,8(s0)
    80005d48:	e810                	sd	a2,16(s0)
    80005d4a:	ec14                	sd	a3,24(s0)
    80005d4c:	f018                	sd	a4,32(s0)
    80005d4e:	f41c                	sd	a5,40(s0)
    80005d50:	03043823          	sd	a6,48(s0)
    80005d54:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005d58:	0001cd97          	auipc	s11,0x1c
    80005d5c:	fb8dad83          	lw	s11,-72(s11) # 80021d10 <pr+0x18>
  if(locking)
    80005d60:	020d9b63          	bnez	s11,80005d96 <printf+0x70>
  if (fmt == 0)
    80005d64:	040a0263          	beqz	s4,80005da8 <printf+0x82>
  va_start(ap, fmt);
    80005d68:	00840793          	addi	a5,s0,8
    80005d6c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005d70:	000a4503          	lbu	a0,0(s4)
    80005d74:	14050f63          	beqz	a0,80005ed2 <printf+0x1ac>
    80005d78:	4981                	li	s3,0
    if(c != '%'){
    80005d7a:	02500a93          	li	s5,37
    switch(c){
    80005d7e:	07000b93          	li	s7,112
  consputc('x');
    80005d82:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005d84:	00003b17          	auipc	s6,0x3
    80005d88:	a6cb0b13          	addi	s6,s6,-1428 # 800087f0 <digits>
    switch(c){
    80005d8c:	07300c93          	li	s9,115
    80005d90:	06400c13          	li	s8,100
    80005d94:	a82d                	j	80005dce <printf+0xa8>
    acquire(&pr.lock);
    80005d96:	0001c517          	auipc	a0,0x1c
    80005d9a:	f6250513          	addi	a0,a0,-158 # 80021cf8 <pr>
    80005d9e:	00000097          	auipc	ra,0x0
    80005da2:	476080e7          	jalr	1142(ra) # 80006214 <acquire>
    80005da6:	bf7d                	j	80005d64 <printf+0x3e>
    panic("null fmt");
    80005da8:	00003517          	auipc	a0,0x3
    80005dac:	a3050513          	addi	a0,a0,-1488 # 800087d8 <syscalls+0x408>
    80005db0:	00000097          	auipc	ra,0x0
    80005db4:	f2c080e7          	jalr	-212(ra) # 80005cdc <panic>
      consputc(c);
    80005db8:	00000097          	auipc	ra,0x0
    80005dbc:	c60080e7          	jalr	-928(ra) # 80005a18 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005dc0:	2985                	addiw	s3,s3,1
    80005dc2:	013a07b3          	add	a5,s4,s3
    80005dc6:	0007c503          	lbu	a0,0(a5)
    80005dca:	10050463          	beqz	a0,80005ed2 <printf+0x1ac>
    if(c != '%'){
    80005dce:	ff5515e3          	bne	a0,s5,80005db8 <printf+0x92>
    c = fmt[++i] & 0xff;
    80005dd2:	2985                	addiw	s3,s3,1
    80005dd4:	013a07b3          	add	a5,s4,s3
    80005dd8:	0007c783          	lbu	a5,0(a5)
    80005ddc:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80005de0:	cbed                	beqz	a5,80005ed2 <printf+0x1ac>
    switch(c){
    80005de2:	05778a63          	beq	a5,s7,80005e36 <printf+0x110>
    80005de6:	02fbf663          	bgeu	s7,a5,80005e12 <printf+0xec>
    80005dea:	09978863          	beq	a5,s9,80005e7a <printf+0x154>
    80005dee:	07800713          	li	a4,120
    80005df2:	0ce79563          	bne	a5,a4,80005ebc <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80005df6:	f8843783          	ld	a5,-120(s0)
    80005dfa:	00878713          	addi	a4,a5,8
    80005dfe:	f8e43423          	sd	a4,-120(s0)
    80005e02:	4605                	li	a2,1
    80005e04:	85ea                	mv	a1,s10
    80005e06:	4388                	lw	a0,0(a5)
    80005e08:	00000097          	auipc	ra,0x0
    80005e0c:	e30080e7          	jalr	-464(ra) # 80005c38 <printint>
      break;
    80005e10:	bf45                	j	80005dc0 <printf+0x9a>
    switch(c){
    80005e12:	09578f63          	beq	a5,s5,80005eb0 <printf+0x18a>
    80005e16:	0b879363          	bne	a5,s8,80005ebc <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80005e1a:	f8843783          	ld	a5,-120(s0)
    80005e1e:	00878713          	addi	a4,a5,8
    80005e22:	f8e43423          	sd	a4,-120(s0)
    80005e26:	4605                	li	a2,1
    80005e28:	45a9                	li	a1,10
    80005e2a:	4388                	lw	a0,0(a5)
    80005e2c:	00000097          	auipc	ra,0x0
    80005e30:	e0c080e7          	jalr	-500(ra) # 80005c38 <printint>
      break;
    80005e34:	b771                	j	80005dc0 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005e36:	f8843783          	ld	a5,-120(s0)
    80005e3a:	00878713          	addi	a4,a5,8
    80005e3e:	f8e43423          	sd	a4,-120(s0)
    80005e42:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80005e46:	03000513          	li	a0,48
    80005e4a:	00000097          	auipc	ra,0x0
    80005e4e:	bce080e7          	jalr	-1074(ra) # 80005a18 <consputc>
  consputc('x');
    80005e52:	07800513          	li	a0,120
    80005e56:	00000097          	auipc	ra,0x0
    80005e5a:	bc2080e7          	jalr	-1086(ra) # 80005a18 <consputc>
    80005e5e:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005e60:	03c95793          	srli	a5,s2,0x3c
    80005e64:	97da                	add	a5,a5,s6
    80005e66:	0007c503          	lbu	a0,0(a5)
    80005e6a:	00000097          	auipc	ra,0x0
    80005e6e:	bae080e7          	jalr	-1106(ra) # 80005a18 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005e72:	0912                	slli	s2,s2,0x4
    80005e74:	34fd                	addiw	s1,s1,-1
    80005e76:	f4ed                	bnez	s1,80005e60 <printf+0x13a>
    80005e78:	b7a1                	j	80005dc0 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80005e7a:	f8843783          	ld	a5,-120(s0)
    80005e7e:	00878713          	addi	a4,a5,8
    80005e82:	f8e43423          	sd	a4,-120(s0)
    80005e86:	6384                	ld	s1,0(a5)
    80005e88:	cc89                	beqz	s1,80005ea2 <printf+0x17c>
      for(; *s; s++)
    80005e8a:	0004c503          	lbu	a0,0(s1)
    80005e8e:	d90d                	beqz	a0,80005dc0 <printf+0x9a>
        consputc(*s);
    80005e90:	00000097          	auipc	ra,0x0
    80005e94:	b88080e7          	jalr	-1144(ra) # 80005a18 <consputc>
      for(; *s; s++)
    80005e98:	0485                	addi	s1,s1,1
    80005e9a:	0004c503          	lbu	a0,0(s1)
    80005e9e:	f96d                	bnez	a0,80005e90 <printf+0x16a>
    80005ea0:	b705                	j	80005dc0 <printf+0x9a>
        s = "(null)";
    80005ea2:	00003497          	auipc	s1,0x3
    80005ea6:	92e48493          	addi	s1,s1,-1746 # 800087d0 <syscalls+0x400>
      for(; *s; s++)
    80005eaa:	02800513          	li	a0,40
    80005eae:	b7cd                	j	80005e90 <printf+0x16a>
      consputc('%');
    80005eb0:	8556                	mv	a0,s5
    80005eb2:	00000097          	auipc	ra,0x0
    80005eb6:	b66080e7          	jalr	-1178(ra) # 80005a18 <consputc>
      break;
    80005eba:	b719                	j	80005dc0 <printf+0x9a>
      consputc('%');
    80005ebc:	8556                	mv	a0,s5
    80005ebe:	00000097          	auipc	ra,0x0
    80005ec2:	b5a080e7          	jalr	-1190(ra) # 80005a18 <consputc>
      consputc(c);
    80005ec6:	8526                	mv	a0,s1
    80005ec8:	00000097          	auipc	ra,0x0
    80005ecc:	b50080e7          	jalr	-1200(ra) # 80005a18 <consputc>
      break;
    80005ed0:	bdc5                	j	80005dc0 <printf+0x9a>
  if(locking)
    80005ed2:	020d9163          	bnez	s11,80005ef4 <printf+0x1ce>
}
    80005ed6:	70e6                	ld	ra,120(sp)
    80005ed8:	7446                	ld	s0,112(sp)
    80005eda:	74a6                	ld	s1,104(sp)
    80005edc:	7906                	ld	s2,96(sp)
    80005ede:	69e6                	ld	s3,88(sp)
    80005ee0:	6a46                	ld	s4,80(sp)
    80005ee2:	6aa6                	ld	s5,72(sp)
    80005ee4:	6b06                	ld	s6,64(sp)
    80005ee6:	7be2                	ld	s7,56(sp)
    80005ee8:	7c42                	ld	s8,48(sp)
    80005eea:	7ca2                	ld	s9,40(sp)
    80005eec:	7d02                	ld	s10,32(sp)
    80005eee:	6de2                	ld	s11,24(sp)
    80005ef0:	6129                	addi	sp,sp,192
    80005ef2:	8082                	ret
    release(&pr.lock);
    80005ef4:	0001c517          	auipc	a0,0x1c
    80005ef8:	e0450513          	addi	a0,a0,-508 # 80021cf8 <pr>
    80005efc:	00000097          	auipc	ra,0x0
    80005f00:	3cc080e7          	jalr	972(ra) # 800062c8 <release>
}
    80005f04:	bfc9                	j	80005ed6 <printf+0x1b0>

0000000080005f06 <printfinit>:
    ;
}

void
printfinit(void)
{
    80005f06:	1101                	addi	sp,sp,-32
    80005f08:	ec06                	sd	ra,24(sp)
    80005f0a:	e822                	sd	s0,16(sp)
    80005f0c:	e426                	sd	s1,8(sp)
    80005f0e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005f10:	0001c497          	auipc	s1,0x1c
    80005f14:	de848493          	addi	s1,s1,-536 # 80021cf8 <pr>
    80005f18:	00003597          	auipc	a1,0x3
    80005f1c:	8d058593          	addi	a1,a1,-1840 # 800087e8 <syscalls+0x418>
    80005f20:	8526                	mv	a0,s1
    80005f22:	00000097          	auipc	ra,0x0
    80005f26:	262080e7          	jalr	610(ra) # 80006184 <initlock>
  pr.locking = 1;
    80005f2a:	4785                	li	a5,1
    80005f2c:	cc9c                	sw	a5,24(s1)
}
    80005f2e:	60e2                	ld	ra,24(sp)
    80005f30:	6442                	ld	s0,16(sp)
    80005f32:	64a2                	ld	s1,8(sp)
    80005f34:	6105                	addi	sp,sp,32
    80005f36:	8082                	ret

0000000080005f38 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80005f38:	1141                	addi	sp,sp,-16
    80005f3a:	e406                	sd	ra,8(sp)
    80005f3c:	e022                	sd	s0,0(sp)
    80005f3e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005f40:	100007b7          	lui	a5,0x10000
    80005f44:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005f48:	f8000713          	li	a4,-128
    80005f4c:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005f50:	470d                	li	a4,3
    80005f52:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005f56:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005f5a:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005f5e:	469d                	li	a3,7
    80005f60:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005f64:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005f68:	00003597          	auipc	a1,0x3
    80005f6c:	8a058593          	addi	a1,a1,-1888 # 80008808 <digits+0x18>
    80005f70:	0001c517          	auipc	a0,0x1c
    80005f74:	da850513          	addi	a0,a0,-600 # 80021d18 <uart_tx_lock>
    80005f78:	00000097          	auipc	ra,0x0
    80005f7c:	20c080e7          	jalr	524(ra) # 80006184 <initlock>
}
    80005f80:	60a2                	ld	ra,8(sp)
    80005f82:	6402                	ld	s0,0(sp)
    80005f84:	0141                	addi	sp,sp,16
    80005f86:	8082                	ret

0000000080005f88 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005f88:	1101                	addi	sp,sp,-32
    80005f8a:	ec06                	sd	ra,24(sp)
    80005f8c:	e822                	sd	s0,16(sp)
    80005f8e:	e426                	sd	s1,8(sp)
    80005f90:	1000                	addi	s0,sp,32
    80005f92:	84aa                	mv	s1,a0
  push_off();
    80005f94:	00000097          	auipc	ra,0x0
    80005f98:	234080e7          	jalr	564(ra) # 800061c8 <push_off>

  if(panicked){
    80005f9c:	00003797          	auipc	a5,0x3
    80005fa0:	9307a783          	lw	a5,-1744(a5) # 800088cc <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005fa4:	10000737          	lui	a4,0x10000
  if(panicked){
    80005fa8:	c391                	beqz	a5,80005fac <uartputc_sync+0x24>
    for(;;)
    80005faa:	a001                	j	80005faa <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005fac:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80005fb0:	0207f793          	andi	a5,a5,32
    80005fb4:	dfe5                	beqz	a5,80005fac <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80005fb6:	0ff4f513          	zext.b	a0,s1
    80005fba:	100007b7          	lui	a5,0x10000
    80005fbe:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80005fc2:	00000097          	auipc	ra,0x0
    80005fc6:	2a6080e7          	jalr	678(ra) # 80006268 <pop_off>
}
    80005fca:	60e2                	ld	ra,24(sp)
    80005fcc:	6442                	ld	s0,16(sp)
    80005fce:	64a2                	ld	s1,8(sp)
    80005fd0:	6105                	addi	sp,sp,32
    80005fd2:	8082                	ret

0000000080005fd4 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80005fd4:	00003797          	auipc	a5,0x3
    80005fd8:	8fc7b783          	ld	a5,-1796(a5) # 800088d0 <uart_tx_r>
    80005fdc:	00003717          	auipc	a4,0x3
    80005fe0:	8fc73703          	ld	a4,-1796(a4) # 800088d8 <uart_tx_w>
    80005fe4:	06f70a63          	beq	a4,a5,80006058 <uartstart+0x84>
{
    80005fe8:	7139                	addi	sp,sp,-64
    80005fea:	fc06                	sd	ra,56(sp)
    80005fec:	f822                	sd	s0,48(sp)
    80005fee:	f426                	sd	s1,40(sp)
    80005ff0:	f04a                	sd	s2,32(sp)
    80005ff2:	ec4e                	sd	s3,24(sp)
    80005ff4:	e852                	sd	s4,16(sp)
    80005ff6:	e456                	sd	s5,8(sp)
    80005ff8:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005ffa:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005ffe:	0001ca17          	auipc	s4,0x1c
    80006002:	d1aa0a13          	addi	s4,s4,-742 # 80021d18 <uart_tx_lock>
    uart_tx_r += 1;
    80006006:	00003497          	auipc	s1,0x3
    8000600a:	8ca48493          	addi	s1,s1,-1846 # 800088d0 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000600e:	00003997          	auipc	s3,0x3
    80006012:	8ca98993          	addi	s3,s3,-1846 # 800088d8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80006016:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000601a:	02077713          	andi	a4,a4,32
    8000601e:	c705                	beqz	a4,80006046 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80006020:	01f7f713          	andi	a4,a5,31
    80006024:	9752                	add	a4,a4,s4
    80006026:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000602a:	0785                	addi	a5,a5,1
    8000602c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000602e:	8526                	mv	a0,s1
    80006030:	ffffb097          	auipc	ra,0xffffb
    80006034:	586080e7          	jalr	1414(ra) # 800015b6 <wakeup>
    
    WriteReg(THR, c);
    80006038:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000603c:	609c                	ld	a5,0(s1)
    8000603e:	0009b703          	ld	a4,0(s3)
    80006042:	fcf71ae3          	bne	a4,a5,80006016 <uartstart+0x42>
  }
}
    80006046:	70e2                	ld	ra,56(sp)
    80006048:	7442                	ld	s0,48(sp)
    8000604a:	74a2                	ld	s1,40(sp)
    8000604c:	7902                	ld	s2,32(sp)
    8000604e:	69e2                	ld	s3,24(sp)
    80006050:	6a42                	ld	s4,16(sp)
    80006052:	6aa2                	ld	s5,8(sp)
    80006054:	6121                	addi	sp,sp,64
    80006056:	8082                	ret
    80006058:	8082                	ret

000000008000605a <uartputc>:
{
    8000605a:	7179                	addi	sp,sp,-48
    8000605c:	f406                	sd	ra,40(sp)
    8000605e:	f022                	sd	s0,32(sp)
    80006060:	ec26                	sd	s1,24(sp)
    80006062:	e84a                	sd	s2,16(sp)
    80006064:	e44e                	sd	s3,8(sp)
    80006066:	e052                	sd	s4,0(sp)
    80006068:	1800                	addi	s0,sp,48
    8000606a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000606c:	0001c517          	auipc	a0,0x1c
    80006070:	cac50513          	addi	a0,a0,-852 # 80021d18 <uart_tx_lock>
    80006074:	00000097          	auipc	ra,0x0
    80006078:	1a0080e7          	jalr	416(ra) # 80006214 <acquire>
  if(panicked){
    8000607c:	00003797          	auipc	a5,0x3
    80006080:	8507a783          	lw	a5,-1968(a5) # 800088cc <panicked>
    80006084:	e7c9                	bnez	a5,8000610e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006086:	00003717          	auipc	a4,0x3
    8000608a:	85273703          	ld	a4,-1966(a4) # 800088d8 <uart_tx_w>
    8000608e:	00003797          	auipc	a5,0x3
    80006092:	8427b783          	ld	a5,-1982(a5) # 800088d0 <uart_tx_r>
    80006096:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000609a:	0001c997          	auipc	s3,0x1c
    8000609e:	c7e98993          	addi	s3,s3,-898 # 80021d18 <uart_tx_lock>
    800060a2:	00003497          	auipc	s1,0x3
    800060a6:	82e48493          	addi	s1,s1,-2002 # 800088d0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800060aa:	00003917          	auipc	s2,0x3
    800060ae:	82e90913          	addi	s2,s2,-2002 # 800088d8 <uart_tx_w>
    800060b2:	00e79f63          	bne	a5,a4,800060d0 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    800060b6:	85ce                	mv	a1,s3
    800060b8:	8526                	mv	a0,s1
    800060ba:	ffffb097          	auipc	ra,0xffffb
    800060be:	498080e7          	jalr	1176(ra) # 80001552 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800060c2:	00093703          	ld	a4,0(s2)
    800060c6:	609c                	ld	a5,0(s1)
    800060c8:	02078793          	addi	a5,a5,32
    800060cc:	fee785e3          	beq	a5,a4,800060b6 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800060d0:	0001c497          	auipc	s1,0x1c
    800060d4:	c4848493          	addi	s1,s1,-952 # 80021d18 <uart_tx_lock>
    800060d8:	01f77793          	andi	a5,a4,31
    800060dc:	97a6                	add	a5,a5,s1
    800060de:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800060e2:	0705                	addi	a4,a4,1
    800060e4:	00002797          	auipc	a5,0x2
    800060e8:	7ee7ba23          	sd	a4,2036(a5) # 800088d8 <uart_tx_w>
  uartstart();
    800060ec:	00000097          	auipc	ra,0x0
    800060f0:	ee8080e7          	jalr	-280(ra) # 80005fd4 <uartstart>
  release(&uart_tx_lock);
    800060f4:	8526                	mv	a0,s1
    800060f6:	00000097          	auipc	ra,0x0
    800060fa:	1d2080e7          	jalr	466(ra) # 800062c8 <release>
}
    800060fe:	70a2                	ld	ra,40(sp)
    80006100:	7402                	ld	s0,32(sp)
    80006102:	64e2                	ld	s1,24(sp)
    80006104:	6942                	ld	s2,16(sp)
    80006106:	69a2                	ld	s3,8(sp)
    80006108:	6a02                	ld	s4,0(sp)
    8000610a:	6145                	addi	sp,sp,48
    8000610c:	8082                	ret
    for(;;)
    8000610e:	a001                	j	8000610e <uartputc+0xb4>

0000000080006110 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80006110:	1141                	addi	sp,sp,-16
    80006112:	e422                	sd	s0,8(sp)
    80006114:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80006116:	100007b7          	lui	a5,0x10000
    8000611a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000611e:	8b85                	andi	a5,a5,1
    80006120:	cb81                	beqz	a5,80006130 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80006122:	100007b7          	lui	a5,0x10000
    80006126:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000612a:	6422                	ld	s0,8(sp)
    8000612c:	0141                	addi	sp,sp,16
    8000612e:	8082                	ret
    return -1;
    80006130:	557d                	li	a0,-1
    80006132:	bfe5                	j	8000612a <uartgetc+0x1a>

0000000080006134 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80006134:	1101                	addi	sp,sp,-32
    80006136:	ec06                	sd	ra,24(sp)
    80006138:	e822                	sd	s0,16(sp)
    8000613a:	e426                	sd	s1,8(sp)
    8000613c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000613e:	54fd                	li	s1,-1
    80006140:	a029                	j	8000614a <uartintr+0x16>
      break;
    consoleintr(c);
    80006142:	00000097          	auipc	ra,0x0
    80006146:	918080e7          	jalr	-1768(ra) # 80005a5a <consoleintr>
    int c = uartgetc();
    8000614a:	00000097          	auipc	ra,0x0
    8000614e:	fc6080e7          	jalr	-58(ra) # 80006110 <uartgetc>
    if(c == -1)
    80006152:	fe9518e3          	bne	a0,s1,80006142 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80006156:	0001c497          	auipc	s1,0x1c
    8000615a:	bc248493          	addi	s1,s1,-1086 # 80021d18 <uart_tx_lock>
    8000615e:	8526                	mv	a0,s1
    80006160:	00000097          	auipc	ra,0x0
    80006164:	0b4080e7          	jalr	180(ra) # 80006214 <acquire>
  uartstart();
    80006168:	00000097          	auipc	ra,0x0
    8000616c:	e6c080e7          	jalr	-404(ra) # 80005fd4 <uartstart>
  release(&uart_tx_lock);
    80006170:	8526                	mv	a0,s1
    80006172:	00000097          	auipc	ra,0x0
    80006176:	156080e7          	jalr	342(ra) # 800062c8 <release>
}
    8000617a:	60e2                	ld	ra,24(sp)
    8000617c:	6442                	ld	s0,16(sp)
    8000617e:	64a2                	ld	s1,8(sp)
    80006180:	6105                	addi	sp,sp,32
    80006182:	8082                	ret

0000000080006184 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80006184:	1141                	addi	sp,sp,-16
    80006186:	e422                	sd	s0,8(sp)
    80006188:	0800                	addi	s0,sp,16
  lk->name = name;
    8000618a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000618c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80006190:	00053823          	sd	zero,16(a0)
}
    80006194:	6422                	ld	s0,8(sp)
    80006196:	0141                	addi	sp,sp,16
    80006198:	8082                	ret

000000008000619a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    8000619a:	411c                	lw	a5,0(a0)
    8000619c:	e399                	bnez	a5,800061a2 <holding+0x8>
    8000619e:	4501                	li	a0,0
  return r;
}
    800061a0:	8082                	ret
{
    800061a2:	1101                	addi	sp,sp,-32
    800061a4:	ec06                	sd	ra,24(sp)
    800061a6:	e822                	sd	s0,16(sp)
    800061a8:	e426                	sd	s1,8(sp)
    800061aa:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800061ac:	6904                	ld	s1,16(a0)
    800061ae:	ffffb097          	auipc	ra,0xffffb
    800061b2:	ce0080e7          	jalr	-800(ra) # 80000e8e <mycpu>
    800061b6:	40a48533          	sub	a0,s1,a0
    800061ba:	00153513          	seqz	a0,a0
}
    800061be:	60e2                	ld	ra,24(sp)
    800061c0:	6442                	ld	s0,16(sp)
    800061c2:	64a2                	ld	s1,8(sp)
    800061c4:	6105                	addi	sp,sp,32
    800061c6:	8082                	ret

00000000800061c8 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800061c8:	1101                	addi	sp,sp,-32
    800061ca:	ec06                	sd	ra,24(sp)
    800061cc:	e822                	sd	s0,16(sp)
    800061ce:	e426                	sd	s1,8(sp)
    800061d0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800061d2:	100024f3          	csrr	s1,sstatus
    800061d6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800061da:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800061dc:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800061e0:	ffffb097          	auipc	ra,0xffffb
    800061e4:	cae080e7          	jalr	-850(ra) # 80000e8e <mycpu>
    800061e8:	5d3c                	lw	a5,120(a0)
    800061ea:	cf89                	beqz	a5,80006204 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800061ec:	ffffb097          	auipc	ra,0xffffb
    800061f0:	ca2080e7          	jalr	-862(ra) # 80000e8e <mycpu>
    800061f4:	5d3c                	lw	a5,120(a0)
    800061f6:	2785                	addiw	a5,a5,1
    800061f8:	dd3c                	sw	a5,120(a0)
}
    800061fa:	60e2                	ld	ra,24(sp)
    800061fc:	6442                	ld	s0,16(sp)
    800061fe:	64a2                	ld	s1,8(sp)
    80006200:	6105                	addi	sp,sp,32
    80006202:	8082                	ret
    mycpu()->intena = old;
    80006204:	ffffb097          	auipc	ra,0xffffb
    80006208:	c8a080e7          	jalr	-886(ra) # 80000e8e <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000620c:	8085                	srli	s1,s1,0x1
    8000620e:	8885                	andi	s1,s1,1
    80006210:	dd64                	sw	s1,124(a0)
    80006212:	bfe9                	j	800061ec <push_off+0x24>

0000000080006214 <acquire>:
{
    80006214:	1101                	addi	sp,sp,-32
    80006216:	ec06                	sd	ra,24(sp)
    80006218:	e822                	sd	s0,16(sp)
    8000621a:	e426                	sd	s1,8(sp)
    8000621c:	1000                	addi	s0,sp,32
    8000621e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80006220:	00000097          	auipc	ra,0x0
    80006224:	fa8080e7          	jalr	-88(ra) # 800061c8 <push_off>
  if(holding(lk))
    80006228:	8526                	mv	a0,s1
    8000622a:	00000097          	auipc	ra,0x0
    8000622e:	f70080e7          	jalr	-144(ra) # 8000619a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80006232:	4705                	li	a4,1
  if(holding(lk))
    80006234:	e115                	bnez	a0,80006258 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80006236:	87ba                	mv	a5,a4
    80006238:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    8000623c:	2781                	sext.w	a5,a5
    8000623e:	ffe5                	bnez	a5,80006236 <acquire+0x22>
  __sync_synchronize();
    80006240:	0ff0000f          	fence
  lk->cpu = mycpu();
    80006244:	ffffb097          	auipc	ra,0xffffb
    80006248:	c4a080e7          	jalr	-950(ra) # 80000e8e <mycpu>
    8000624c:	e888                	sd	a0,16(s1)
}
    8000624e:	60e2                	ld	ra,24(sp)
    80006250:	6442                	ld	s0,16(sp)
    80006252:	64a2                	ld	s1,8(sp)
    80006254:	6105                	addi	sp,sp,32
    80006256:	8082                	ret
    panic("acquire");
    80006258:	00002517          	auipc	a0,0x2
    8000625c:	5b850513          	addi	a0,a0,1464 # 80008810 <digits+0x20>
    80006260:	00000097          	auipc	ra,0x0
    80006264:	a7c080e7          	jalr	-1412(ra) # 80005cdc <panic>

0000000080006268 <pop_off>:

void
pop_off(void)
{
    80006268:	1141                	addi	sp,sp,-16
    8000626a:	e406                	sd	ra,8(sp)
    8000626c:	e022                	sd	s0,0(sp)
    8000626e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80006270:	ffffb097          	auipc	ra,0xffffb
    80006274:	c1e080e7          	jalr	-994(ra) # 80000e8e <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006278:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000627c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000627e:	e78d                	bnez	a5,800062a8 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80006280:	5d3c                	lw	a5,120(a0)
    80006282:	02f05b63          	blez	a5,800062b8 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80006286:	37fd                	addiw	a5,a5,-1
    80006288:	0007871b          	sext.w	a4,a5
    8000628c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    8000628e:	eb09                	bnez	a4,800062a0 <pop_off+0x38>
    80006290:	5d7c                	lw	a5,124(a0)
    80006292:	c799                	beqz	a5,800062a0 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006294:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80006298:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000629c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800062a0:	60a2                	ld	ra,8(sp)
    800062a2:	6402                	ld	s0,0(sp)
    800062a4:	0141                	addi	sp,sp,16
    800062a6:	8082                	ret
    panic("pop_off - interruptible");
    800062a8:	00002517          	auipc	a0,0x2
    800062ac:	57050513          	addi	a0,a0,1392 # 80008818 <digits+0x28>
    800062b0:	00000097          	auipc	ra,0x0
    800062b4:	a2c080e7          	jalr	-1492(ra) # 80005cdc <panic>
    panic("pop_off");
    800062b8:	00002517          	auipc	a0,0x2
    800062bc:	57850513          	addi	a0,a0,1400 # 80008830 <digits+0x40>
    800062c0:	00000097          	auipc	ra,0x0
    800062c4:	a1c080e7          	jalr	-1508(ra) # 80005cdc <panic>

00000000800062c8 <release>:
{
    800062c8:	1101                	addi	sp,sp,-32
    800062ca:	ec06                	sd	ra,24(sp)
    800062cc:	e822                	sd	s0,16(sp)
    800062ce:	e426                	sd	s1,8(sp)
    800062d0:	1000                	addi	s0,sp,32
    800062d2:	84aa                	mv	s1,a0
  if(!holding(lk))
    800062d4:	00000097          	auipc	ra,0x0
    800062d8:	ec6080e7          	jalr	-314(ra) # 8000619a <holding>
    800062dc:	c115                	beqz	a0,80006300 <release+0x38>
  lk->cpu = 0;
    800062de:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800062e2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800062e6:	0f50000f          	fence	iorw,ow
    800062ea:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800062ee:	00000097          	auipc	ra,0x0
    800062f2:	f7a080e7          	jalr	-134(ra) # 80006268 <pop_off>
}
    800062f6:	60e2                	ld	ra,24(sp)
    800062f8:	6442                	ld	s0,16(sp)
    800062fa:	64a2                	ld	s1,8(sp)
    800062fc:	6105                	addi	sp,sp,32
    800062fe:	8082                	ret
    panic("release");
    80006300:	00002517          	auipc	a0,0x2
    80006304:	53850513          	addi	a0,a0,1336 # 80008838 <digits+0x48>
    80006308:	00000097          	auipc	ra,0x0
    8000630c:	9d4080e7          	jalr	-1580(ra) # 80005cdc <panic>
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
    8000709a:	8282                	jr	t0

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
