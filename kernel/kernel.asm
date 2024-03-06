
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8b013103          	ld	sp,-1872(sp) # 800088b0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	183050ef          	jal	ra,80005998 <start>

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
    80000030:	00026797          	auipc	a5,0x26
    80000034:	34078793          	addi	a5,a5,832 # 80026370 <end>
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
    80000054:	8b090913          	addi	s2,s2,-1872 # 80008900 <kmem>
    80000058:	854a                	mv	a0,s2
    8000005a:	00006097          	auipc	ra,0x6
    8000005e:	32a080e7          	jalr	810(ra) # 80006384 <acquire>
  r->next = kmem.freelist;
    80000062:	01893783          	ld	a5,24(s2)
    80000066:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000068:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006c:	854a                	mv	a0,s2
    8000006e:	00006097          	auipc	ra,0x6
    80000072:	3ca080e7          	jalr	970(ra) # 80006438 <release>
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
    8000008e:	dc2080e7          	jalr	-574(ra) # 80005e4c <panic>

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
    800000ee:	00009517          	auipc	a0,0x9
    800000f2:	81250513          	addi	a0,a0,-2030 # 80008900 <kmem>
    800000f6:	00006097          	auipc	ra,0x6
    800000fa:	1fe080e7          	jalr	510(ra) # 800062f4 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000fe:	45c5                	li	a1,17
    80000100:	05ee                	slli	a1,a1,0x1b
    80000102:	00026517          	auipc	a0,0x26
    80000106:	26e50513          	addi	a0,a0,622 # 80026370 <end>
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
    80000128:	7dc48493          	addi	s1,s1,2012 # 80008900 <kmem>
    8000012c:	8526                	mv	a0,s1
    8000012e:	00006097          	auipc	ra,0x6
    80000132:	256080e7          	jalr	598(ra) # 80006384 <acquire>
  r = kmem.freelist;
    80000136:	6c84                	ld	s1,24(s1)
  if(r)
    80000138:	c885                	beqz	s1,80000168 <kalloc+0x4e>
    kmem.freelist = r->next;
    8000013a:	609c                	ld	a5,0(s1)
    8000013c:	00008517          	auipc	a0,0x8
    80000140:	7c450513          	addi	a0,a0,1988 # 80008900 <kmem>
    80000144:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000146:	00006097          	auipc	ra,0x6
    8000014a:	2f2080e7          	jalr	754(ra) # 80006438 <release>

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
    8000016c:	79850513          	addi	a0,a0,1944 # 80008900 <kmem>
    80000170:	00006097          	auipc	ra,0x6
    80000174:	2c8080e7          	jalr	712(ra) # 80006438 <release>
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
    800001ee:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffd8c91>
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
    8000032c:	b00080e7          	jalr	-1280(ra) # 80000e28 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000330:	00008717          	auipc	a4,0x8
    80000334:	5a070713          	addi	a4,a4,1440 # 800088d0 <started>
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
    80000348:	ae4080e7          	jalr	-1308(ra) # 80000e28 <cpuid>
    8000034c:	85aa                	mv	a1,a0
    8000034e:	00008517          	auipc	a0,0x8
    80000352:	cea50513          	addi	a0,a0,-790 # 80008038 <etext+0x38>
    80000356:	00006097          	auipc	ra,0x6
    8000035a:	b40080e7          	jalr	-1216(ra) # 80005e96 <printf>
    kvminithart();    // turn on paging
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	0d8080e7          	jalr	216(ra) # 80000436 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000366:	00001097          	auipc	ra,0x1
    8000036a:	794080e7          	jalr	1940(ra) # 80001afa <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000036e:	00005097          	auipc	ra,0x5
    80000372:	fe2080e7          	jalr	-30(ra) # 80005350 <plicinithart>
  }

  scheduler();        
    80000376:	00001097          	auipc	ra,0x1
    8000037a:	fdc080e7          	jalr	-36(ra) # 80001352 <scheduler>
    consoleinit();
    8000037e:	00006097          	auipc	ra,0x6
    80000382:	9de080e7          	jalr	-1570(ra) # 80005d5c <consoleinit>
    printfinit();
    80000386:	00006097          	auipc	ra,0x6
    8000038a:	cf0080e7          	jalr	-784(ra) # 80006076 <printfinit>
    printf("\n");
    8000038e:	00008517          	auipc	a0,0x8
    80000392:	cba50513          	addi	a0,a0,-838 # 80008048 <etext+0x48>
    80000396:	00006097          	auipc	ra,0x6
    8000039a:	b00080e7          	jalr	-1280(ra) # 80005e96 <printf>
    printf("xv6 kernel is booting\n");
    8000039e:	00008517          	auipc	a0,0x8
    800003a2:	c8250513          	addi	a0,a0,-894 # 80008020 <etext+0x20>
    800003a6:	00006097          	auipc	ra,0x6
    800003aa:	af0080e7          	jalr	-1296(ra) # 80005e96 <printf>
    printf("\n");
    800003ae:	00008517          	auipc	a0,0x8
    800003b2:	c9a50513          	addi	a0,a0,-870 # 80008048 <etext+0x48>
    800003b6:	00006097          	auipc	ra,0x6
    800003ba:	ae0080e7          	jalr	-1312(ra) # 80005e96 <printf>
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
    800003da:	99e080e7          	jalr	-1634(ra) # 80000d74 <procinit>
    trapinit();      // trap vectors
    800003de:	00001097          	auipc	ra,0x1
    800003e2:	6f4080e7          	jalr	1780(ra) # 80001ad2 <trapinit>
    trapinithart();  // install kernel trap vector
    800003e6:	00001097          	auipc	ra,0x1
    800003ea:	714080e7          	jalr	1812(ra) # 80001afa <trapinithart>
    plicinit();      // set up interrupt controller
    800003ee:	00005097          	auipc	ra,0x5
    800003f2:	f4c080e7          	jalr	-180(ra) # 8000533a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800003f6:	00005097          	auipc	ra,0x5
    800003fa:	f5a080e7          	jalr	-166(ra) # 80005350 <plicinithart>
    binit();         // buffer cache
    800003fe:	00002097          	auipc	ra,0x2
    80000402:	0fc080e7          	jalr	252(ra) # 800024fa <binit>
    iinit();         // inode table
    80000406:	00002097          	auipc	ra,0x2
    8000040a:	79c080e7          	jalr	1948(ra) # 80002ba2 <iinit>
    fileinit();      // file table
    8000040e:	00003097          	auipc	ra,0x3
    80000412:	742080e7          	jalr	1858(ra) # 80003b50 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000416:	00005097          	auipc	ra,0x5
    8000041a:	042080e7          	jalr	66(ra) # 80005458 <virtio_disk_init>
    userinit();      // first user process
    8000041e:	00001097          	auipc	ra,0x1
    80000422:	d16080e7          	jalr	-746(ra) # 80001134 <userinit>
    __sync_synchronize();
    80000426:	0ff0000f          	fence
    started = 1;
    8000042a:	4785                	li	a5,1
    8000042c:	00008717          	auipc	a4,0x8
    80000430:	4af72223          	sw	a5,1188(a4) # 800088d0 <started>
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
    80000444:	4987b783          	ld	a5,1176(a5) # 800088d8 <kernel_pagetable>
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
    80000490:	9c0080e7          	jalr	-1600(ra) # 80005e4c <panic>
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
    800004be:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd8c87>
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
    800005b2:	00006097          	auipc	ra,0x6
    800005b6:	89a080e7          	jalr	-1894(ra) # 80005e4c <panic>
      panic("mappages: remap");
    800005ba:	00008517          	auipc	a0,0x8
    800005be:	aae50513          	addi	a0,a0,-1362 # 80008068 <etext+0x68>
    800005c2:	00006097          	auipc	ra,0x6
    800005c6:	88a080e7          	jalr	-1910(ra) # 80005e4c <panic>
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
    8000060e:	00006097          	auipc	ra,0x6
    80000612:	83e080e7          	jalr	-1986(ra) # 80005e4c <panic>

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
    800006da:	608080e7          	jalr	1544(ra) # 80000cde <proc_mapstacks>
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
    80000700:	1ca7be23          	sd	a0,476(a5) # 800088d8 <kernel_pagetable>
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
    8000075e:	6f2080e7          	jalr	1778(ra) # 80005e4c <panic>
      panic("uvmunmap: walk");
    80000762:	00008517          	auipc	a0,0x8
    80000766:	93650513          	addi	a0,a0,-1738 # 80008098 <etext+0x98>
    8000076a:	00005097          	auipc	ra,0x5
    8000076e:	6e2080e7          	jalr	1762(ra) # 80005e4c <panic>
      panic("uvmunmap: not mapped");
    80000772:	00008517          	auipc	a0,0x8
    80000776:	93650513          	addi	a0,a0,-1738 # 800080a8 <etext+0xa8>
    8000077a:	00005097          	auipc	ra,0x5
    8000077e:	6d2080e7          	jalr	1746(ra) # 80005e4c <panic>
      panic("uvmunmap: not a leaf");
    80000782:	00008517          	auipc	a0,0x8
    80000786:	93e50513          	addi	a0,a0,-1730 # 800080c0 <etext+0xc0>
    8000078a:	00005097          	auipc	ra,0x5
    8000078e:	6c2080e7          	jalr	1730(ra) # 80005e4c <panic>
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
    8000086c:	5e4080e7          	jalr	1508(ra) # 80005e4c <panic>

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
    800009b8:	498080e7          	jalr	1176(ra) # 80005e4c <panic>
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
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80000a10:	c679                	beqz	a2,80000ade <uvmcopy+0xce>
{
    80000a12:	715d                	addi	sp,sp,-80
    80000a14:	e486                	sd	ra,72(sp)
    80000a16:	e0a2                	sd	s0,64(sp)
    80000a18:	fc26                	sd	s1,56(sp)
    80000a1a:	f84a                	sd	s2,48(sp)
    80000a1c:	f44e                	sd	s3,40(sp)
    80000a1e:	f052                	sd	s4,32(sp)
    80000a20:	ec56                	sd	s5,24(sp)
    80000a22:	e85a                	sd	s6,16(sp)
    80000a24:	e45e                	sd	s7,8(sp)
    80000a26:	0880                	addi	s0,sp,80
    80000a28:	8b2a                	mv	s6,a0
    80000a2a:	8aae                	mv	s5,a1
    80000a2c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000a2e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80000a30:	4601                	li	a2,0
    80000a32:	85ce                	mv	a1,s3
    80000a34:	855a                	mv	a0,s6
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	a28080e7          	jalr	-1496(ra) # 8000045e <walk>
    80000a3e:	c531                	beqz	a0,80000a8a <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000a40:	6118                	ld	a4,0(a0)
    80000a42:	00177793          	andi	a5,a4,1
    80000a46:	cbb1                	beqz	a5,80000a9a <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000a48:	00a75593          	srli	a1,a4,0xa
    80000a4c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000a50:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80000a54:	fffff097          	auipc	ra,0xfffff
    80000a58:	6c6080e7          	jalr	1734(ra) # 8000011a <kalloc>
    80000a5c:	892a                	mv	s2,a0
    80000a5e:	c939                	beqz	a0,80000ab4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000a60:	6605                	lui	a2,0x1
    80000a62:	85de                	mv	a1,s7
    80000a64:	fffff097          	auipc	ra,0xfffff
    80000a68:	772080e7          	jalr	1906(ra) # 800001d6 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000a6c:	8726                	mv	a4,s1
    80000a6e:	86ca                	mv	a3,s2
    80000a70:	6605                	lui	a2,0x1
    80000a72:	85ce                	mv	a1,s3
    80000a74:	8556                	mv	a0,s5
    80000a76:	00000097          	auipc	ra,0x0
    80000a7a:	ad0080e7          	jalr	-1328(ra) # 80000546 <mappages>
    80000a7e:	e515                	bnez	a0,80000aaa <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80000a80:	6785                	lui	a5,0x1
    80000a82:	99be                	add	s3,s3,a5
    80000a84:	fb49e6e3          	bltu	s3,s4,80000a30 <uvmcopy+0x20>
    80000a88:	a081                	j	80000ac8 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	67e50513          	addi	a0,a0,1662 # 80008108 <etext+0x108>
    80000a92:	00005097          	auipc	ra,0x5
    80000a96:	3ba080e7          	jalr	954(ra) # 80005e4c <panic>
      panic("uvmcopy: page not present");
    80000a9a:	00007517          	auipc	a0,0x7
    80000a9e:	68e50513          	addi	a0,a0,1678 # 80008128 <etext+0x128>
    80000aa2:	00005097          	auipc	ra,0x5
    80000aa6:	3aa080e7          	jalr	938(ra) # 80005e4c <panic>
      kfree(mem);
    80000aaa:	854a                	mv	a0,s2
    80000aac:	fffff097          	auipc	ra,0xfffff
    80000ab0:	570080e7          	jalr	1392(ra) # 8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000ab4:	4685                	li	a3,1
    80000ab6:	00c9d613          	srli	a2,s3,0xc
    80000aba:	4581                	li	a1,0
    80000abc:	8556                	mv	a0,s5
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	c4e080e7          	jalr	-946(ra) # 8000070c <uvmunmap>
  return -1;
    80000ac6:	557d                	li	a0,-1
}
    80000ac8:	60a6                	ld	ra,72(sp)
    80000aca:	6406                	ld	s0,64(sp)
    80000acc:	74e2                	ld	s1,56(sp)
    80000ace:	7942                	ld	s2,48(sp)
    80000ad0:	79a2                	ld	s3,40(sp)
    80000ad2:	7a02                	ld	s4,32(sp)
    80000ad4:	6ae2                	ld	s5,24(sp)
    80000ad6:	6b42                	ld	s6,16(sp)
    80000ad8:	6ba2                	ld	s7,8(sp)
    80000ada:	6161                	addi	sp,sp,80
    80000adc:	8082                	ret
  return 0;
    80000ade:	4501                	li	a0,0
}
    80000ae0:	8082                	ret

0000000080000ae2 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000ae2:	1141                	addi	sp,sp,-16
    80000ae4:	e406                	sd	ra,8(sp)
    80000ae6:	e022                	sd	s0,0(sp)
    80000ae8:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000aea:	4601                	li	a2,0
    80000aec:	00000097          	auipc	ra,0x0
    80000af0:	972080e7          	jalr	-1678(ra) # 8000045e <walk>
  if(pte == 0)
    80000af4:	c901                	beqz	a0,80000b04 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000af6:	611c                	ld	a5,0(a0)
    80000af8:	9bbd                	andi	a5,a5,-17
    80000afa:	e11c                	sd	a5,0(a0)
}
    80000afc:	60a2                	ld	ra,8(sp)
    80000afe:	6402                	ld	s0,0(sp)
    80000b00:	0141                	addi	sp,sp,16
    80000b02:	8082                	ret
    panic("uvmclear");
    80000b04:	00007517          	auipc	a0,0x7
    80000b08:	64450513          	addi	a0,a0,1604 # 80008148 <etext+0x148>
    80000b0c:	00005097          	auipc	ra,0x5
    80000b10:	340080e7          	jalr	832(ra) # 80005e4c <panic>

0000000080000b14 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000b14:	c6bd                	beqz	a3,80000b82 <copyout+0x6e>
{
    80000b16:	715d                	addi	sp,sp,-80
    80000b18:	e486                	sd	ra,72(sp)
    80000b1a:	e0a2                	sd	s0,64(sp)
    80000b1c:	fc26                	sd	s1,56(sp)
    80000b1e:	f84a                	sd	s2,48(sp)
    80000b20:	f44e                	sd	s3,40(sp)
    80000b22:	f052                	sd	s4,32(sp)
    80000b24:	ec56                	sd	s5,24(sp)
    80000b26:	e85a                	sd	s6,16(sp)
    80000b28:	e45e                	sd	s7,8(sp)
    80000b2a:	e062                	sd	s8,0(sp)
    80000b2c:	0880                	addi	s0,sp,80
    80000b2e:	8b2a                	mv	s6,a0
    80000b30:	8c2e                	mv	s8,a1
    80000b32:	8a32                	mv	s4,a2
    80000b34:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000b36:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80000b38:	6a85                	lui	s5,0x1
    80000b3a:	a015                	j	80000b5e <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000b3c:	9562                	add	a0,a0,s8
    80000b3e:	0004861b          	sext.w	a2,s1
    80000b42:	85d2                	mv	a1,s4
    80000b44:	41250533          	sub	a0,a0,s2
    80000b48:	fffff097          	auipc	ra,0xfffff
    80000b4c:	68e080e7          	jalr	1678(ra) # 800001d6 <memmove>

    len -= n;
    80000b50:	409989b3          	sub	s3,s3,s1
    src += n;
    80000b54:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80000b56:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000b5a:	02098263          	beqz	s3,80000b7e <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000b5e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000b62:	85ca                	mv	a1,s2
    80000b64:	855a                	mv	a0,s6
    80000b66:	00000097          	auipc	ra,0x0
    80000b6a:	99e080e7          	jalr	-1634(ra) # 80000504 <walkaddr>
    if(pa0 == 0)
    80000b6e:	cd01                	beqz	a0,80000b86 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80000b70:	418904b3          	sub	s1,s2,s8
    80000b74:	94d6                	add	s1,s1,s5
    80000b76:	fc99f3e3          	bgeu	s3,s1,80000b3c <copyout+0x28>
    80000b7a:	84ce                	mv	s1,s3
    80000b7c:	b7c1                	j	80000b3c <copyout+0x28>
  }
  return 0;
    80000b7e:	4501                	li	a0,0
    80000b80:	a021                	j	80000b88 <copyout+0x74>
    80000b82:	4501                	li	a0,0
}
    80000b84:	8082                	ret
      return -1;
    80000b86:	557d                	li	a0,-1
}
    80000b88:	60a6                	ld	ra,72(sp)
    80000b8a:	6406                	ld	s0,64(sp)
    80000b8c:	74e2                	ld	s1,56(sp)
    80000b8e:	7942                	ld	s2,48(sp)
    80000b90:	79a2                	ld	s3,40(sp)
    80000b92:	7a02                	ld	s4,32(sp)
    80000b94:	6ae2                	ld	s5,24(sp)
    80000b96:	6b42                	ld	s6,16(sp)
    80000b98:	6ba2                	ld	s7,8(sp)
    80000b9a:	6c02                	ld	s8,0(sp)
    80000b9c:	6161                	addi	sp,sp,80
    80000b9e:	8082                	ret

0000000080000ba0 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000ba0:	caa5                	beqz	a3,80000c10 <copyin+0x70>
{
    80000ba2:	715d                	addi	sp,sp,-80
    80000ba4:	e486                	sd	ra,72(sp)
    80000ba6:	e0a2                	sd	s0,64(sp)
    80000ba8:	fc26                	sd	s1,56(sp)
    80000baa:	f84a                	sd	s2,48(sp)
    80000bac:	f44e                	sd	s3,40(sp)
    80000bae:	f052                	sd	s4,32(sp)
    80000bb0:	ec56                	sd	s5,24(sp)
    80000bb2:	e85a                	sd	s6,16(sp)
    80000bb4:	e45e                	sd	s7,8(sp)
    80000bb6:	e062                	sd	s8,0(sp)
    80000bb8:	0880                	addi	s0,sp,80
    80000bba:	8b2a                	mv	s6,a0
    80000bbc:	8a2e                	mv	s4,a1
    80000bbe:	8c32                	mv	s8,a2
    80000bc0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000bc2:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000bc4:	6a85                	lui	s5,0x1
    80000bc6:	a01d                	j	80000bec <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000bc8:	018505b3          	add	a1,a0,s8
    80000bcc:	0004861b          	sext.w	a2,s1
    80000bd0:	412585b3          	sub	a1,a1,s2
    80000bd4:	8552                	mv	a0,s4
    80000bd6:	fffff097          	auipc	ra,0xfffff
    80000bda:	600080e7          	jalr	1536(ra) # 800001d6 <memmove>

    len -= n;
    80000bde:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000be2:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000be4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000be8:	02098263          	beqz	s3,80000c0c <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80000bec:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000bf0:	85ca                	mv	a1,s2
    80000bf2:	855a                	mv	a0,s6
    80000bf4:	00000097          	auipc	ra,0x0
    80000bf8:	910080e7          	jalr	-1776(ra) # 80000504 <walkaddr>
    if(pa0 == 0)
    80000bfc:	cd01                	beqz	a0,80000c14 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80000bfe:	418904b3          	sub	s1,s2,s8
    80000c02:	94d6                	add	s1,s1,s5
    80000c04:	fc99f2e3          	bgeu	s3,s1,80000bc8 <copyin+0x28>
    80000c08:	84ce                	mv	s1,s3
    80000c0a:	bf7d                	j	80000bc8 <copyin+0x28>
  }
  return 0;
    80000c0c:	4501                	li	a0,0
    80000c0e:	a021                	j	80000c16 <copyin+0x76>
    80000c10:	4501                	li	a0,0
}
    80000c12:	8082                	ret
      return -1;
    80000c14:	557d                	li	a0,-1
}
    80000c16:	60a6                	ld	ra,72(sp)
    80000c18:	6406                	ld	s0,64(sp)
    80000c1a:	74e2                	ld	s1,56(sp)
    80000c1c:	7942                	ld	s2,48(sp)
    80000c1e:	79a2                	ld	s3,40(sp)
    80000c20:	7a02                	ld	s4,32(sp)
    80000c22:	6ae2                	ld	s5,24(sp)
    80000c24:	6b42                	ld	s6,16(sp)
    80000c26:	6ba2                	ld	s7,8(sp)
    80000c28:	6c02                	ld	s8,0(sp)
    80000c2a:	6161                	addi	sp,sp,80
    80000c2c:	8082                	ret

0000000080000c2e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000c2e:	c2dd                	beqz	a3,80000cd4 <copyinstr+0xa6>
{
    80000c30:	715d                	addi	sp,sp,-80
    80000c32:	e486                	sd	ra,72(sp)
    80000c34:	e0a2                	sd	s0,64(sp)
    80000c36:	fc26                	sd	s1,56(sp)
    80000c38:	f84a                	sd	s2,48(sp)
    80000c3a:	f44e                	sd	s3,40(sp)
    80000c3c:	f052                	sd	s4,32(sp)
    80000c3e:	ec56                	sd	s5,24(sp)
    80000c40:	e85a                	sd	s6,16(sp)
    80000c42:	e45e                	sd	s7,8(sp)
    80000c44:	0880                	addi	s0,sp,80
    80000c46:	8a2a                	mv	s4,a0
    80000c48:	8b2e                	mv	s6,a1
    80000c4a:	8bb2                	mv	s7,a2
    80000c4c:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000c4e:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c50:	6985                	lui	s3,0x1
    80000c52:	a02d                	j	80000c7c <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000c54:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000c58:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000c5a:	37fd                	addiw	a5,a5,-1
    80000c5c:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000c60:	60a6                	ld	ra,72(sp)
    80000c62:	6406                	ld	s0,64(sp)
    80000c64:	74e2                	ld	s1,56(sp)
    80000c66:	7942                	ld	s2,48(sp)
    80000c68:	79a2                	ld	s3,40(sp)
    80000c6a:	7a02                	ld	s4,32(sp)
    80000c6c:	6ae2                	ld	s5,24(sp)
    80000c6e:	6b42                	ld	s6,16(sp)
    80000c70:	6ba2                	ld	s7,8(sp)
    80000c72:	6161                	addi	sp,sp,80
    80000c74:	8082                	ret
    srcva = va0 + PGSIZE;
    80000c76:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000c7a:	c8a9                	beqz	s1,80000ccc <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80000c7c:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000c80:	85ca                	mv	a1,s2
    80000c82:	8552                	mv	a0,s4
    80000c84:	00000097          	auipc	ra,0x0
    80000c88:	880080e7          	jalr	-1920(ra) # 80000504 <walkaddr>
    if(pa0 == 0)
    80000c8c:	c131                	beqz	a0,80000cd0 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80000c8e:	417906b3          	sub	a3,s2,s7
    80000c92:	96ce                	add	a3,a3,s3
    80000c94:	00d4f363          	bgeu	s1,a3,80000c9a <copyinstr+0x6c>
    80000c98:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000c9a:	955e                	add	a0,a0,s7
    80000c9c:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000ca0:	daf9                	beqz	a3,80000c76 <copyinstr+0x48>
    80000ca2:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000ca4:	41650633          	sub	a2,a0,s6
    80000ca8:	fff48593          	addi	a1,s1,-1
    80000cac:	95da                	add	a1,a1,s6
    while(n > 0){
    80000cae:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80000cb0:	00f60733          	add	a4,a2,a5
    80000cb4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd8c90>
    80000cb8:	df51                	beqz	a4,80000c54 <copyinstr+0x26>
        *dst = *p;
    80000cba:	00e78023          	sb	a4,0(a5)
      --max;
    80000cbe:	40f584b3          	sub	s1,a1,a5
      dst++;
    80000cc2:	0785                	addi	a5,a5,1
    while(n > 0){
    80000cc4:	fed796e3          	bne	a5,a3,80000cb0 <copyinstr+0x82>
      dst++;
    80000cc8:	8b3e                	mv	s6,a5
    80000cca:	b775                	j	80000c76 <copyinstr+0x48>
    80000ccc:	4781                	li	a5,0
    80000cce:	b771                	j	80000c5a <copyinstr+0x2c>
      return -1;
    80000cd0:	557d                	li	a0,-1
    80000cd2:	b779                	j	80000c60 <copyinstr+0x32>
  int got_null = 0;
    80000cd4:	4781                	li	a5,0
  if(got_null){
    80000cd6:	37fd                	addiw	a5,a5,-1
    80000cd8:	0007851b          	sext.w	a0,a5
}
    80000cdc:	8082                	ret

0000000080000cde <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000cde:	7139                	addi	sp,sp,-64
    80000ce0:	fc06                	sd	ra,56(sp)
    80000ce2:	f822                	sd	s0,48(sp)
    80000ce4:	f426                	sd	s1,40(sp)
    80000ce6:	f04a                	sd	s2,32(sp)
    80000ce8:	ec4e                	sd	s3,24(sp)
    80000cea:	e852                	sd	s4,16(sp)
    80000cec:	e456                	sd	s5,8(sp)
    80000cee:	e05a                	sd	s6,0(sp)
    80000cf0:	0080                	addi	s0,sp,64
    80000cf2:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000cf4:	00008497          	auipc	s1,0x8
    80000cf8:	05c48493          	addi	s1,s1,92 # 80008d50 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000cfc:	8b26                	mv	s6,s1
    80000cfe:	00007a97          	auipc	s5,0x7
    80000d02:	302a8a93          	addi	s5,s5,770 # 80008000 <etext>
    80000d06:	04000937          	lui	s2,0x4000
    80000d0a:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000d0c:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d0e:	00012a17          	auipc	s4,0x12
    80000d12:	042a0a13          	addi	s4,s4,66 # 80012d50 <tickslock>
    char *pa = kalloc();
    80000d16:	fffff097          	auipc	ra,0xfffff
    80000d1a:	404080e7          	jalr	1028(ra) # 8000011a <kalloc>
    80000d1e:	862a                	mv	a2,a0
    if(pa == 0)
    80000d20:	c131                	beqz	a0,80000d64 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000d22:	416485b3          	sub	a1,s1,s6
    80000d26:	859d                	srai	a1,a1,0x7
    80000d28:	000ab783          	ld	a5,0(s5)
    80000d2c:	02f585b3          	mul	a1,a1,a5
    80000d30:	2585                	addiw	a1,a1,1
    80000d32:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000d36:	4719                	li	a4,6
    80000d38:	6685                	lui	a3,0x1
    80000d3a:	40b905b3          	sub	a1,s2,a1
    80000d3e:	854e                	mv	a0,s3
    80000d40:	00000097          	auipc	ra,0x0
    80000d44:	8a6080e7          	jalr	-1882(ra) # 800005e6 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000d48:	28048493          	addi	s1,s1,640
    80000d4c:	fd4495e3          	bne	s1,s4,80000d16 <proc_mapstacks+0x38>
  }
}
    80000d50:	70e2                	ld	ra,56(sp)
    80000d52:	7442                	ld	s0,48(sp)
    80000d54:	74a2                	ld	s1,40(sp)
    80000d56:	7902                	ld	s2,32(sp)
    80000d58:	69e2                	ld	s3,24(sp)
    80000d5a:	6a42                	ld	s4,16(sp)
    80000d5c:	6aa2                	ld	s5,8(sp)
    80000d5e:	6b02                	ld	s6,0(sp)
    80000d60:	6121                	addi	sp,sp,64
    80000d62:	8082                	ret
      panic("kalloc");
    80000d64:	00007517          	auipc	a0,0x7
    80000d68:	3f450513          	addi	a0,a0,1012 # 80008158 <etext+0x158>
    80000d6c:	00005097          	auipc	ra,0x5
    80000d70:	0e0080e7          	jalr	224(ra) # 80005e4c <panic>

0000000080000d74 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    80000d74:	7139                	addi	sp,sp,-64
    80000d76:	fc06                	sd	ra,56(sp)
    80000d78:	f822                	sd	s0,48(sp)
    80000d7a:	f426                	sd	s1,40(sp)
    80000d7c:	f04a                	sd	s2,32(sp)
    80000d7e:	ec4e                	sd	s3,24(sp)
    80000d80:	e852                	sd	s4,16(sp)
    80000d82:	e456                	sd	s5,8(sp)
    80000d84:	e05a                	sd	s6,0(sp)
    80000d86:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80000d88:	00007597          	auipc	a1,0x7
    80000d8c:	3d858593          	addi	a1,a1,984 # 80008160 <etext+0x160>
    80000d90:	00008517          	auipc	a0,0x8
    80000d94:	b9050513          	addi	a0,a0,-1136 # 80008920 <pid_lock>
    80000d98:	00005097          	auipc	ra,0x5
    80000d9c:	55c080e7          	jalr	1372(ra) # 800062f4 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000da0:	00007597          	auipc	a1,0x7
    80000da4:	3c858593          	addi	a1,a1,968 # 80008168 <etext+0x168>
    80000da8:	00008517          	auipc	a0,0x8
    80000dac:	b9050513          	addi	a0,a0,-1136 # 80008938 <wait_lock>
    80000db0:	00005097          	auipc	ra,0x5
    80000db4:	544080e7          	jalr	1348(ra) # 800062f4 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000db8:	00008497          	auipc	s1,0x8
    80000dbc:	f9848493          	addi	s1,s1,-104 # 80008d50 <proc>
      initlock(&p->lock, "proc");
    80000dc0:	00007b17          	auipc	s6,0x7
    80000dc4:	3b8b0b13          	addi	s6,s6,952 # 80008178 <etext+0x178>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80000dc8:	8aa6                	mv	s5,s1
    80000dca:	00007a17          	auipc	s4,0x7
    80000dce:	236a0a13          	addi	s4,s4,566 # 80008000 <etext>
    80000dd2:	04000937          	lui	s2,0x4000
    80000dd6:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80000dd8:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dda:	00012997          	auipc	s3,0x12
    80000dde:	f7698993          	addi	s3,s3,-138 # 80012d50 <tickslock>
      initlock(&p->lock, "proc");
    80000de2:	85da                	mv	a1,s6
    80000de4:	8526                	mv	a0,s1
    80000de6:	00005097          	auipc	ra,0x5
    80000dea:	50e080e7          	jalr	1294(ra) # 800062f4 <initlock>
      p->state = UNUSED;
    80000dee:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000df2:	415487b3          	sub	a5,s1,s5
    80000df6:	879d                	srai	a5,a5,0x7
    80000df8:	000a3703          	ld	a4,0(s4)
    80000dfc:	02e787b3          	mul	a5,a5,a4
    80000e00:	2785                	addiw	a5,a5,1
    80000e02:	00d7979b          	slliw	a5,a5,0xd
    80000e06:	40f907b3          	sub	a5,s2,a5
    80000e0a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e0c:	28048493          	addi	s1,s1,640
    80000e10:	fd3499e3          	bne	s1,s3,80000de2 <procinit+0x6e>
  }
}
    80000e14:	70e2                	ld	ra,56(sp)
    80000e16:	7442                	ld	s0,48(sp)
    80000e18:	74a2                	ld	s1,40(sp)
    80000e1a:	7902                	ld	s2,32(sp)
    80000e1c:	69e2                	ld	s3,24(sp)
    80000e1e:	6a42                	ld	s4,16(sp)
    80000e20:	6aa2                	ld	s5,8(sp)
    80000e22:	6b02                	ld	s6,0(sp)
    80000e24:	6121                	addi	sp,sp,64
    80000e26:	8082                	ret

0000000080000e28 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80000e28:	1141                	addi	sp,sp,-16
    80000e2a:	e422                	sd	s0,8(sp)
    80000e2c:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000e2e:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80000e30:	2501                	sext.w	a0,a0
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
    80000e3e:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80000e40:	2781                	sext.w	a5,a5
    80000e42:	079e                	slli	a5,a5,0x7
  return c;
}
    80000e44:	00008517          	auipc	a0,0x8
    80000e48:	b0c50513          	addi	a0,a0,-1268 # 80008950 <cpus>
    80000e4c:	953e                	add	a0,a0,a5
    80000e4e:	6422                	ld	s0,8(sp)
    80000e50:	0141                	addi	sp,sp,16
    80000e52:	8082                	ret

0000000080000e54 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80000e54:	1101                	addi	sp,sp,-32
    80000e56:	ec06                	sd	ra,24(sp)
    80000e58:	e822                	sd	s0,16(sp)
    80000e5a:	e426                	sd	s1,8(sp)
    80000e5c:	1000                	addi	s0,sp,32
  push_off();
    80000e5e:	00005097          	auipc	ra,0x5
    80000e62:	4da080e7          	jalr	1242(ra) # 80006338 <push_off>
    80000e66:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000e68:	2781                	sext.w	a5,a5
    80000e6a:	079e                	slli	a5,a5,0x7
    80000e6c:	00008717          	auipc	a4,0x8
    80000e70:	ab470713          	addi	a4,a4,-1356 # 80008920 <pid_lock>
    80000e74:	97ba                	add	a5,a5,a4
    80000e76:	7b84                	ld	s1,48(a5)
  pop_off();
    80000e78:	00005097          	auipc	ra,0x5
    80000e7c:	560080e7          	jalr	1376(ra) # 800063d8 <pop_off>
  return p;
}
    80000e80:	8526                	mv	a0,s1
    80000e82:	60e2                	ld	ra,24(sp)
    80000e84:	6442                	ld	s0,16(sp)
    80000e86:	64a2                	ld	s1,8(sp)
    80000e88:	6105                	addi	sp,sp,32
    80000e8a:	8082                	ret

0000000080000e8c <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80000e8c:	1141                	addi	sp,sp,-16
    80000e8e:	e406                	sd	ra,8(sp)
    80000e90:	e022                	sd	s0,0(sp)
    80000e92:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80000e94:	00000097          	auipc	ra,0x0
    80000e98:	fc0080e7          	jalr	-64(ra) # 80000e54 <myproc>
    80000e9c:	00005097          	auipc	ra,0x5
    80000ea0:	59c080e7          	jalr	1436(ra) # 80006438 <release>

  if (first) {
    80000ea4:	00008797          	auipc	a5,0x8
    80000ea8:	9bc7a783          	lw	a5,-1604(a5) # 80008860 <first.1>
    80000eac:	eb89                	bnez	a5,80000ebe <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80000eae:	00001097          	auipc	ra,0x1
    80000eb2:	d40080e7          	jalr	-704(ra) # 80001bee <usertrapret>
}
    80000eb6:	60a2                	ld	ra,8(sp)
    80000eb8:	6402                	ld	s0,0(sp)
    80000eba:	0141                	addi	sp,sp,16
    80000ebc:	8082                	ret
    first = 0;
    80000ebe:	00008797          	auipc	a5,0x8
    80000ec2:	9a07a123          	sw	zero,-1630(a5) # 80008860 <first.1>
    fsinit(ROOTDEV);
    80000ec6:	4505                	li	a0,1
    80000ec8:	00002097          	auipc	ra,0x2
    80000ecc:	c5a080e7          	jalr	-934(ra) # 80002b22 <fsinit>
    80000ed0:	bff9                	j	80000eae <forkret+0x22>

0000000080000ed2 <allocpid>:
{
    80000ed2:	1101                	addi	sp,sp,-32
    80000ed4:	ec06                	sd	ra,24(sp)
    80000ed6:	e822                	sd	s0,16(sp)
    80000ed8:	e426                	sd	s1,8(sp)
    80000eda:	e04a                	sd	s2,0(sp)
    80000edc:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000ede:	00008917          	auipc	s2,0x8
    80000ee2:	a4290913          	addi	s2,s2,-1470 # 80008920 <pid_lock>
    80000ee6:	854a                	mv	a0,s2
    80000ee8:	00005097          	auipc	ra,0x5
    80000eec:	49c080e7          	jalr	1180(ra) # 80006384 <acquire>
  pid = nextpid;
    80000ef0:	00008797          	auipc	a5,0x8
    80000ef4:	97478793          	addi	a5,a5,-1676 # 80008864 <nextpid>
    80000ef8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000efa:	0014871b          	addiw	a4,s1,1
    80000efe:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000f00:	854a                	mv	a0,s2
    80000f02:	00005097          	auipc	ra,0x5
    80000f06:	536080e7          	jalr	1334(ra) # 80006438 <release>
}
    80000f0a:	8526                	mv	a0,s1
    80000f0c:	60e2                	ld	ra,24(sp)
    80000f0e:	6442                	ld	s0,16(sp)
    80000f10:	64a2                	ld	s1,8(sp)
    80000f12:	6902                	ld	s2,0(sp)
    80000f14:	6105                	addi	sp,sp,32
    80000f16:	8082                	ret

0000000080000f18 <proc_pagetable>:
{
    80000f18:	1101                	addi	sp,sp,-32
    80000f1a:	ec06                	sd	ra,24(sp)
    80000f1c:	e822                	sd	s0,16(sp)
    80000f1e:	e426                	sd	s1,8(sp)
    80000f20:	e04a                	sd	s2,0(sp)
    80000f22:	1000                	addi	s0,sp,32
    80000f24:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	8aa080e7          	jalr	-1878(ra) # 800007d0 <uvmcreate>
    80000f2e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000f30:	c121                	beqz	a0,80000f70 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000f32:	4729                	li	a4,10
    80000f34:	00006697          	auipc	a3,0x6
    80000f38:	0cc68693          	addi	a3,a3,204 # 80007000 <_trampoline>
    80000f3c:	6605                	lui	a2,0x1
    80000f3e:	040005b7          	lui	a1,0x4000
    80000f42:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f44:	05b2                	slli	a1,a1,0xc
    80000f46:	fffff097          	auipc	ra,0xfffff
    80000f4a:	600080e7          	jalr	1536(ra) # 80000546 <mappages>
    80000f4e:	02054863          	bltz	a0,80000f7e <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80000f52:	4719                	li	a4,6
    80000f54:	05893683          	ld	a3,88(s2)
    80000f58:	6605                	lui	a2,0x1
    80000f5a:	020005b7          	lui	a1,0x2000
    80000f5e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000f60:	05b6                	slli	a1,a1,0xd
    80000f62:	8526                	mv	a0,s1
    80000f64:	fffff097          	auipc	ra,0xfffff
    80000f68:	5e2080e7          	jalr	1506(ra) # 80000546 <mappages>
    80000f6c:	02054163          	bltz	a0,80000f8e <proc_pagetable+0x76>
}
    80000f70:	8526                	mv	a0,s1
    80000f72:	60e2                	ld	ra,24(sp)
    80000f74:	6442                	ld	s0,16(sp)
    80000f76:	64a2                	ld	s1,8(sp)
    80000f78:	6902                	ld	s2,0(sp)
    80000f7a:	6105                	addi	sp,sp,32
    80000f7c:	8082                	ret
    uvmfree(pagetable, 0);
    80000f7e:	4581                	li	a1,0
    80000f80:	8526                	mv	a0,s1
    80000f82:	00000097          	auipc	ra,0x0
    80000f86:	a54080e7          	jalr	-1452(ra) # 800009d6 <uvmfree>
    return 0;
    80000f8a:	4481                	li	s1,0
    80000f8c:	b7d5                	j	80000f70 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000f8e:	4681                	li	a3,0
    80000f90:	4605                	li	a2,1
    80000f92:	040005b7          	lui	a1,0x4000
    80000f96:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000f98:	05b2                	slli	a1,a1,0xc
    80000f9a:	8526                	mv	a0,s1
    80000f9c:	fffff097          	auipc	ra,0xfffff
    80000fa0:	770080e7          	jalr	1904(ra) # 8000070c <uvmunmap>
    uvmfree(pagetable, 0);
    80000fa4:	4581                	li	a1,0
    80000fa6:	8526                	mv	a0,s1
    80000fa8:	00000097          	auipc	ra,0x0
    80000fac:	a2e080e7          	jalr	-1490(ra) # 800009d6 <uvmfree>
    return 0;
    80000fb0:	4481                	li	s1,0
    80000fb2:	bf7d                	j	80000f70 <proc_pagetable+0x58>

0000000080000fb4 <proc_freepagetable>:
{
    80000fb4:	1101                	addi	sp,sp,-32
    80000fb6:	ec06                	sd	ra,24(sp)
    80000fb8:	e822                	sd	s0,16(sp)
    80000fba:	e426                	sd	s1,8(sp)
    80000fbc:	e04a                	sd	s2,0(sp)
    80000fbe:	1000                	addi	s0,sp,32
    80000fc0:	84aa                	mv	s1,a0
    80000fc2:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80000fc4:	4681                	li	a3,0
    80000fc6:	4605                	li	a2,1
    80000fc8:	040005b7          	lui	a1,0x4000
    80000fcc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80000fce:	05b2                	slli	a1,a1,0xc
    80000fd0:	fffff097          	auipc	ra,0xfffff
    80000fd4:	73c080e7          	jalr	1852(ra) # 8000070c <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80000fd8:	4681                	li	a3,0
    80000fda:	4605                	li	a2,1
    80000fdc:	020005b7          	lui	a1,0x2000
    80000fe0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80000fe2:	05b6                	slli	a1,a1,0xd
    80000fe4:	8526                	mv	a0,s1
    80000fe6:	fffff097          	auipc	ra,0xfffff
    80000fea:	726080e7          	jalr	1830(ra) # 8000070c <uvmunmap>
  uvmfree(pagetable, sz);
    80000fee:	85ca                	mv	a1,s2
    80000ff0:	8526                	mv	a0,s1
    80000ff2:	00000097          	auipc	ra,0x0
    80000ff6:	9e4080e7          	jalr	-1564(ra) # 800009d6 <uvmfree>
}
    80000ffa:	60e2                	ld	ra,24(sp)
    80000ffc:	6442                	ld	s0,16(sp)
    80000ffe:	64a2                	ld	s1,8(sp)
    80001000:	6902                	ld	s2,0(sp)
    80001002:	6105                	addi	sp,sp,32
    80001004:	8082                	ret

0000000080001006 <freeproc>:
{
    80001006:	1101                	addi	sp,sp,-32
    80001008:	ec06                	sd	ra,24(sp)
    8000100a:	e822                	sd	s0,16(sp)
    8000100c:	e426                	sd	s1,8(sp)
    8000100e:	1000                	addi	s0,sp,32
    80001010:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001012:	6d28                	ld	a0,88(a0)
    80001014:	c509                	beqz	a0,8000101e <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001016:	fffff097          	auipc	ra,0xfffff
    8000101a:	006080e7          	jalr	6(ra) # 8000001c <kfree>
  p->trapframe = 0;
    8000101e:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001022:	68a8                	ld	a0,80(s1)
    80001024:	c511                	beqz	a0,80001030 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001026:	64ac                	ld	a1,72(s1)
    80001028:	00000097          	auipc	ra,0x0
    8000102c:	f8c080e7          	jalr	-116(ra) # 80000fb4 <proc_freepagetable>
  p->pagetable = 0;
    80001030:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001034:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001038:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    8000103c:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001040:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001044:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001048:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    8000104c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001050:	0004ac23          	sw	zero,24(s1)
}
    80001054:	60e2                	ld	ra,24(sp)
    80001056:	6442                	ld	s0,16(sp)
    80001058:	64a2                	ld	s1,8(sp)
    8000105a:	6105                	addi	sp,sp,32
    8000105c:	8082                	ret

000000008000105e <allocproc>:
{
    8000105e:	1101                	addi	sp,sp,-32
    80001060:	ec06                	sd	ra,24(sp)
    80001062:	e822                	sd	s0,16(sp)
    80001064:	e426                	sd	s1,8(sp)
    80001066:	e04a                	sd	s2,0(sp)
    80001068:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000106a:	00008497          	auipc	s1,0x8
    8000106e:	ce648493          	addi	s1,s1,-794 # 80008d50 <proc>
    80001072:	00012917          	auipc	s2,0x12
    80001076:	cde90913          	addi	s2,s2,-802 # 80012d50 <tickslock>
    acquire(&p->lock);
    8000107a:	8526                	mv	a0,s1
    8000107c:	00005097          	auipc	ra,0x5
    80001080:	308080e7          	jalr	776(ra) # 80006384 <acquire>
    if(p->state == UNUSED) {
    80001084:	4c9c                	lw	a5,24(s1)
    80001086:	cf81                	beqz	a5,8000109e <allocproc+0x40>
      release(&p->lock);
    80001088:	8526                	mv	a0,s1
    8000108a:	00005097          	auipc	ra,0x5
    8000108e:	3ae080e7          	jalr	942(ra) # 80006438 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001092:	28048493          	addi	s1,s1,640
    80001096:	ff2492e3          	bne	s1,s2,8000107a <allocproc+0x1c>
  return 0;
    8000109a:	4481                	li	s1,0
    8000109c:	a8a9                	j	800010f6 <allocproc+0x98>
  p->pid = allocpid();
    8000109e:	00000097          	auipc	ra,0x0
    800010a2:	e34080e7          	jalr	-460(ra) # 80000ed2 <allocpid>
    800010a6:	d888                	sw	a0,48(s1)
  p->state = USED;
    800010a8:	4785                	li	a5,1
    800010aa:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800010ac:	fffff097          	auipc	ra,0xfffff
    800010b0:	06e080e7          	jalr	110(ra) # 8000011a <kalloc>
    800010b4:	892a                	mv	s2,a0
    800010b6:	eca8                	sd	a0,88(s1)
    800010b8:	c531                	beqz	a0,80001104 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    800010ba:	8526                	mv	a0,s1
    800010bc:	00000097          	auipc	ra,0x0
    800010c0:	e5c080e7          	jalr	-420(ra) # 80000f18 <proc_pagetable>
    800010c4:	892a                	mv	s2,a0
    800010c6:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800010c8:	c931                	beqz	a0,8000111c <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    800010ca:	07000613          	li	a2,112
    800010ce:	4581                	li	a1,0
    800010d0:	06048513          	addi	a0,s1,96
    800010d4:	fffff097          	auipc	ra,0xfffff
    800010d8:	0a6080e7          	jalr	166(ra) # 8000017a <memset>
  p->context.ra = (uint64)forkret;
    800010dc:	00000797          	auipc	a5,0x0
    800010e0:	db078793          	addi	a5,a5,-592 # 80000e8c <forkret>
    800010e4:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800010e6:	60bc                	ld	a5,64(s1)
    800010e8:	6705                	lui	a4,0x1
    800010ea:	97ba                	add	a5,a5,a4
    800010ec:	f4bc                	sd	a5,104(s1)
  p->alarm_ticks = 0;
    800010ee:	1604a423          	sw	zero,360(s1)
  p->handler_executing = 0;
    800010f2:	1804a023          	sw	zero,384(s1)
}
    800010f6:	8526                	mv	a0,s1
    800010f8:	60e2                	ld	ra,24(sp)
    800010fa:	6442                	ld	s0,16(sp)
    800010fc:	64a2                	ld	s1,8(sp)
    800010fe:	6902                	ld	s2,0(sp)
    80001100:	6105                	addi	sp,sp,32
    80001102:	8082                	ret
    freeproc(p);
    80001104:	8526                	mv	a0,s1
    80001106:	00000097          	auipc	ra,0x0
    8000110a:	f00080e7          	jalr	-256(ra) # 80001006 <freeproc>
    release(&p->lock);
    8000110e:	8526                	mv	a0,s1
    80001110:	00005097          	auipc	ra,0x5
    80001114:	328080e7          	jalr	808(ra) # 80006438 <release>
    return 0;
    80001118:	84ca                	mv	s1,s2
    8000111a:	bff1                	j	800010f6 <allocproc+0x98>
    freeproc(p);
    8000111c:	8526                	mv	a0,s1
    8000111e:	00000097          	auipc	ra,0x0
    80001122:	ee8080e7          	jalr	-280(ra) # 80001006 <freeproc>
    release(&p->lock);
    80001126:	8526                	mv	a0,s1
    80001128:	00005097          	auipc	ra,0x5
    8000112c:	310080e7          	jalr	784(ra) # 80006438 <release>
    return 0;
    80001130:	84ca                	mv	s1,s2
    80001132:	b7d1                	j	800010f6 <allocproc+0x98>

0000000080001134 <userinit>:
{
    80001134:	1101                	addi	sp,sp,-32
    80001136:	ec06                	sd	ra,24(sp)
    80001138:	e822                	sd	s0,16(sp)
    8000113a:	e426                	sd	s1,8(sp)
    8000113c:	1000                	addi	s0,sp,32
  p = allocproc();
    8000113e:	00000097          	auipc	ra,0x0
    80001142:	f20080e7          	jalr	-224(ra) # 8000105e <allocproc>
    80001146:	84aa                	mv	s1,a0
  initproc = p;
    80001148:	00007797          	auipc	a5,0x7
    8000114c:	78a7bc23          	sd	a0,1944(a5) # 800088e0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001150:	03400613          	li	a2,52
    80001154:	00007597          	auipc	a1,0x7
    80001158:	71c58593          	addi	a1,a1,1820 # 80008870 <initcode>
    8000115c:	6928                	ld	a0,80(a0)
    8000115e:	fffff097          	auipc	ra,0xfffff
    80001162:	6a0080e7          	jalr	1696(ra) # 800007fe <uvmfirst>
  p->sz = PGSIZE;
    80001166:	6785                	lui	a5,0x1
    80001168:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000116a:	6cb8                	ld	a4,88(s1)
    8000116c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001170:	6cb8                	ld	a4,88(s1)
    80001172:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001174:	4641                	li	a2,16
    80001176:	00007597          	auipc	a1,0x7
    8000117a:	00a58593          	addi	a1,a1,10 # 80008180 <etext+0x180>
    8000117e:	15848513          	addi	a0,s1,344
    80001182:	fffff097          	auipc	ra,0xfffff
    80001186:	142080e7          	jalr	322(ra) # 800002c4 <safestrcpy>
  p->cwd = namei("/");
    8000118a:	00007517          	auipc	a0,0x7
    8000118e:	00650513          	addi	a0,a0,6 # 80008190 <etext+0x190>
    80001192:	00002097          	auipc	ra,0x2
    80001196:	3ba080e7          	jalr	954(ra) # 8000354c <namei>
    8000119a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000119e:	478d                	li	a5,3
    800011a0:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011a2:	8526                	mv	a0,s1
    800011a4:	00005097          	auipc	ra,0x5
    800011a8:	294080e7          	jalr	660(ra) # 80006438 <release>
}
    800011ac:	60e2                	ld	ra,24(sp)
    800011ae:	6442                	ld	s0,16(sp)
    800011b0:	64a2                	ld	s1,8(sp)
    800011b2:	6105                	addi	sp,sp,32
    800011b4:	8082                	ret

00000000800011b6 <growproc>:
{
    800011b6:	1101                	addi	sp,sp,-32
    800011b8:	ec06                	sd	ra,24(sp)
    800011ba:	e822                	sd	s0,16(sp)
    800011bc:	e426                	sd	s1,8(sp)
    800011be:	e04a                	sd	s2,0(sp)
    800011c0:	1000                	addi	s0,sp,32
    800011c2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	c90080e7          	jalr	-880(ra) # 80000e54 <myproc>
    800011cc:	84aa                	mv	s1,a0
  sz = p->sz;
    800011ce:	652c                	ld	a1,72(a0)
  if(n > 0){
    800011d0:	01204c63          	bgtz	s2,800011e8 <growproc+0x32>
  } else if(n < 0){
    800011d4:	02094663          	bltz	s2,80001200 <growproc+0x4a>
  p->sz = sz;
    800011d8:	e4ac                	sd	a1,72(s1)
  return 0;
    800011da:	4501                	li	a0,0
}
    800011dc:	60e2                	ld	ra,24(sp)
    800011de:	6442                	ld	s0,16(sp)
    800011e0:	64a2                	ld	s1,8(sp)
    800011e2:	6902                	ld	s2,0(sp)
    800011e4:	6105                	addi	sp,sp,32
    800011e6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800011e8:	4691                	li	a3,4
    800011ea:	00b90633          	add	a2,s2,a1
    800011ee:	6928                	ld	a0,80(a0)
    800011f0:	fffff097          	auipc	ra,0xfffff
    800011f4:	6c8080e7          	jalr	1736(ra) # 800008b8 <uvmalloc>
    800011f8:	85aa                	mv	a1,a0
    800011fa:	fd79                	bnez	a0,800011d8 <growproc+0x22>
      return -1;
    800011fc:	557d                	li	a0,-1
    800011fe:	bff9                	j	800011dc <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001200:	00b90633          	add	a2,s2,a1
    80001204:	6928                	ld	a0,80(a0)
    80001206:	fffff097          	auipc	ra,0xfffff
    8000120a:	66a080e7          	jalr	1642(ra) # 80000870 <uvmdealloc>
    8000120e:	85aa                	mv	a1,a0
    80001210:	b7e1                	j	800011d8 <growproc+0x22>

0000000080001212 <fork>:
{
    80001212:	7139                	addi	sp,sp,-64
    80001214:	fc06                	sd	ra,56(sp)
    80001216:	f822                	sd	s0,48(sp)
    80001218:	f426                	sd	s1,40(sp)
    8000121a:	f04a                	sd	s2,32(sp)
    8000121c:	ec4e                	sd	s3,24(sp)
    8000121e:	e852                	sd	s4,16(sp)
    80001220:	e456                	sd	s5,8(sp)
    80001222:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001224:	00000097          	auipc	ra,0x0
    80001228:	c30080e7          	jalr	-976(ra) # 80000e54 <myproc>
    8000122c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	e30080e7          	jalr	-464(ra) # 8000105e <allocproc>
    80001236:	10050c63          	beqz	a0,8000134e <fork+0x13c>
    8000123a:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000123c:	048ab603          	ld	a2,72(s5)
    80001240:	692c                	ld	a1,80(a0)
    80001242:	050ab503          	ld	a0,80(s5)
    80001246:	fffff097          	auipc	ra,0xfffff
    8000124a:	7ca080e7          	jalr	1994(ra) # 80000a10 <uvmcopy>
    8000124e:	04054863          	bltz	a0,8000129e <fork+0x8c>
  np->sz = p->sz;
    80001252:	048ab783          	ld	a5,72(s5)
    80001256:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    8000125a:	058ab683          	ld	a3,88(s5)
    8000125e:	87b6                	mv	a5,a3
    80001260:	058a3703          	ld	a4,88(s4)
    80001264:	12068693          	addi	a3,a3,288
    80001268:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000126c:	6788                	ld	a0,8(a5)
    8000126e:	6b8c                	ld	a1,16(a5)
    80001270:	6f90                	ld	a2,24(a5)
    80001272:	01073023          	sd	a6,0(a4)
    80001276:	e708                	sd	a0,8(a4)
    80001278:	eb0c                	sd	a1,16(a4)
    8000127a:	ef10                	sd	a2,24(a4)
    8000127c:	02078793          	addi	a5,a5,32
    80001280:	02070713          	addi	a4,a4,32
    80001284:	fed792e3          	bne	a5,a3,80001268 <fork+0x56>
  np->trapframe->a0 = 0;
    80001288:	058a3783          	ld	a5,88(s4)
    8000128c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001290:	0d0a8493          	addi	s1,s5,208
    80001294:	0d0a0913          	addi	s2,s4,208
    80001298:	150a8993          	addi	s3,s5,336
    8000129c:	a00d                	j	800012be <fork+0xac>
    freeproc(np);
    8000129e:	8552                	mv	a0,s4
    800012a0:	00000097          	auipc	ra,0x0
    800012a4:	d66080e7          	jalr	-666(ra) # 80001006 <freeproc>
    release(&np->lock);
    800012a8:	8552                	mv	a0,s4
    800012aa:	00005097          	auipc	ra,0x5
    800012ae:	18e080e7          	jalr	398(ra) # 80006438 <release>
    return -1;
    800012b2:	597d                	li	s2,-1
    800012b4:	a059                	j	8000133a <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    800012b6:	04a1                	addi	s1,s1,8
    800012b8:	0921                	addi	s2,s2,8
    800012ba:	01348b63          	beq	s1,s3,800012d0 <fork+0xbe>
    if(p->ofile[i])
    800012be:	6088                	ld	a0,0(s1)
    800012c0:	d97d                	beqz	a0,800012b6 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    800012c2:	00003097          	auipc	ra,0x3
    800012c6:	920080e7          	jalr	-1760(ra) # 80003be2 <filedup>
    800012ca:	00a93023          	sd	a0,0(s2)
    800012ce:	b7e5                	j	800012b6 <fork+0xa4>
  np->cwd = idup(p->cwd);
    800012d0:	150ab503          	ld	a0,336(s5)
    800012d4:	00002097          	auipc	ra,0x2
    800012d8:	a8e080e7          	jalr	-1394(ra) # 80002d62 <idup>
    800012dc:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800012e0:	4641                	li	a2,16
    800012e2:	158a8593          	addi	a1,s5,344
    800012e6:	158a0513          	addi	a0,s4,344
    800012ea:	fffff097          	auipc	ra,0xfffff
    800012ee:	fda080e7          	jalr	-38(ra) # 800002c4 <safestrcpy>
  pid = np->pid;
    800012f2:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800012f6:	8552                	mv	a0,s4
    800012f8:	00005097          	auipc	ra,0x5
    800012fc:	140080e7          	jalr	320(ra) # 80006438 <release>
  acquire(&wait_lock);
    80001300:	00007497          	auipc	s1,0x7
    80001304:	63848493          	addi	s1,s1,1592 # 80008938 <wait_lock>
    80001308:	8526                	mv	a0,s1
    8000130a:	00005097          	auipc	ra,0x5
    8000130e:	07a080e7          	jalr	122(ra) # 80006384 <acquire>
  np->parent = p;
    80001312:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001316:	8526                	mv	a0,s1
    80001318:	00005097          	auipc	ra,0x5
    8000131c:	120080e7          	jalr	288(ra) # 80006438 <release>
  acquire(&np->lock);
    80001320:	8552                	mv	a0,s4
    80001322:	00005097          	auipc	ra,0x5
    80001326:	062080e7          	jalr	98(ra) # 80006384 <acquire>
  np->state = RUNNABLE;
    8000132a:	478d                	li	a5,3
    8000132c:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001330:	8552                	mv	a0,s4
    80001332:	00005097          	auipc	ra,0x5
    80001336:	106080e7          	jalr	262(ra) # 80006438 <release>
}
    8000133a:	854a                	mv	a0,s2
    8000133c:	70e2                	ld	ra,56(sp)
    8000133e:	7442                	ld	s0,48(sp)
    80001340:	74a2                	ld	s1,40(sp)
    80001342:	7902                	ld	s2,32(sp)
    80001344:	69e2                	ld	s3,24(sp)
    80001346:	6a42                	ld	s4,16(sp)
    80001348:	6aa2                	ld	s5,8(sp)
    8000134a:	6121                	addi	sp,sp,64
    8000134c:	8082                	ret
    return -1;
    8000134e:	597d                	li	s2,-1
    80001350:	b7ed                	j	8000133a <fork+0x128>

0000000080001352 <scheduler>:
{
    80001352:	7139                	addi	sp,sp,-64
    80001354:	fc06                	sd	ra,56(sp)
    80001356:	f822                	sd	s0,48(sp)
    80001358:	f426                	sd	s1,40(sp)
    8000135a:	f04a                	sd	s2,32(sp)
    8000135c:	ec4e                	sd	s3,24(sp)
    8000135e:	e852                	sd	s4,16(sp)
    80001360:	e456                	sd	s5,8(sp)
    80001362:	e05a                	sd	s6,0(sp)
    80001364:	0080                	addi	s0,sp,64
    80001366:	8792                	mv	a5,tp
  int id = r_tp();
    80001368:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000136a:	00779a93          	slli	s5,a5,0x7
    8000136e:	00007717          	auipc	a4,0x7
    80001372:	5b270713          	addi	a4,a4,1458 # 80008920 <pid_lock>
    80001376:	9756                	add	a4,a4,s5
    80001378:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000137c:	00007717          	auipc	a4,0x7
    80001380:	5dc70713          	addi	a4,a4,1500 # 80008958 <cpus+0x8>
    80001384:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001386:	498d                	li	s3,3
        p->state = RUNNING;
    80001388:	4b11                	li	s6,4
        c->proc = p;
    8000138a:	079e                	slli	a5,a5,0x7
    8000138c:	00007a17          	auipc	s4,0x7
    80001390:	594a0a13          	addi	s4,s4,1428 # 80008920 <pid_lock>
    80001394:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001396:	00012917          	auipc	s2,0x12
    8000139a:	9ba90913          	addi	s2,s2,-1606 # 80012d50 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000139e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013a6:	10079073          	csrw	sstatus,a5
    800013aa:	00008497          	auipc	s1,0x8
    800013ae:	9a648493          	addi	s1,s1,-1626 # 80008d50 <proc>
    800013b2:	a811                	j	800013c6 <scheduler+0x74>
      release(&p->lock);
    800013b4:	8526                	mv	a0,s1
    800013b6:	00005097          	auipc	ra,0x5
    800013ba:	082080e7          	jalr	130(ra) # 80006438 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800013be:	28048493          	addi	s1,s1,640
    800013c2:	fd248ee3          	beq	s1,s2,8000139e <scheduler+0x4c>
      acquire(&p->lock);
    800013c6:	8526                	mv	a0,s1
    800013c8:	00005097          	auipc	ra,0x5
    800013cc:	fbc080e7          	jalr	-68(ra) # 80006384 <acquire>
      if(p->state == RUNNABLE) {
    800013d0:	4c9c                	lw	a5,24(s1)
    800013d2:	ff3791e3          	bne	a5,s3,800013b4 <scheduler+0x62>
        p->state = RUNNING;
    800013d6:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800013da:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800013de:	06048593          	addi	a1,s1,96
    800013e2:	8556                	mv	a0,s5
    800013e4:	00000097          	auipc	ra,0x0
    800013e8:	684080e7          	jalr	1668(ra) # 80001a68 <swtch>
        c->proc = 0;
    800013ec:	020a3823          	sd	zero,48(s4)
    800013f0:	b7d1                	j	800013b4 <scheduler+0x62>

00000000800013f2 <sched>:
{
    800013f2:	7179                	addi	sp,sp,-48
    800013f4:	f406                	sd	ra,40(sp)
    800013f6:	f022                	sd	s0,32(sp)
    800013f8:	ec26                	sd	s1,24(sp)
    800013fa:	e84a                	sd	s2,16(sp)
    800013fc:	e44e                	sd	s3,8(sp)
    800013fe:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001400:	00000097          	auipc	ra,0x0
    80001404:	a54080e7          	jalr	-1452(ra) # 80000e54 <myproc>
    80001408:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000140a:	00005097          	auipc	ra,0x5
    8000140e:	f00080e7          	jalr	-256(ra) # 8000630a <holding>
    80001412:	c93d                	beqz	a0,80001488 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001414:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001416:	2781                	sext.w	a5,a5
    80001418:	079e                	slli	a5,a5,0x7
    8000141a:	00007717          	auipc	a4,0x7
    8000141e:	50670713          	addi	a4,a4,1286 # 80008920 <pid_lock>
    80001422:	97ba                	add	a5,a5,a4
    80001424:	0a87a703          	lw	a4,168(a5)
    80001428:	4785                	li	a5,1
    8000142a:	06f71763          	bne	a4,a5,80001498 <sched+0xa6>
  if(p->state == RUNNING)
    8000142e:	4c98                	lw	a4,24(s1)
    80001430:	4791                	li	a5,4
    80001432:	06f70b63          	beq	a4,a5,800014a8 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001436:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000143a:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000143c:	efb5                	bnez	a5,800014b8 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000143e:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001440:	00007917          	auipc	s2,0x7
    80001444:	4e090913          	addi	s2,s2,1248 # 80008920 <pid_lock>
    80001448:	2781                	sext.w	a5,a5
    8000144a:	079e                	slli	a5,a5,0x7
    8000144c:	97ca                	add	a5,a5,s2
    8000144e:	0ac7a983          	lw	s3,172(a5)
    80001452:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001454:	2781                	sext.w	a5,a5
    80001456:	079e                	slli	a5,a5,0x7
    80001458:	00007597          	auipc	a1,0x7
    8000145c:	50058593          	addi	a1,a1,1280 # 80008958 <cpus+0x8>
    80001460:	95be                	add	a1,a1,a5
    80001462:	06048513          	addi	a0,s1,96
    80001466:	00000097          	auipc	ra,0x0
    8000146a:	602080e7          	jalr	1538(ra) # 80001a68 <swtch>
    8000146e:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001470:	2781                	sext.w	a5,a5
    80001472:	079e                	slli	a5,a5,0x7
    80001474:	993e                	add	s2,s2,a5
    80001476:	0b392623          	sw	s3,172(s2)
}
    8000147a:	70a2                	ld	ra,40(sp)
    8000147c:	7402                	ld	s0,32(sp)
    8000147e:	64e2                	ld	s1,24(sp)
    80001480:	6942                	ld	s2,16(sp)
    80001482:	69a2                	ld	s3,8(sp)
    80001484:	6145                	addi	sp,sp,48
    80001486:	8082                	ret
    panic("sched p->lock");
    80001488:	00007517          	auipc	a0,0x7
    8000148c:	d1050513          	addi	a0,a0,-752 # 80008198 <etext+0x198>
    80001490:	00005097          	auipc	ra,0x5
    80001494:	9bc080e7          	jalr	-1604(ra) # 80005e4c <panic>
    panic("sched locks");
    80001498:	00007517          	auipc	a0,0x7
    8000149c:	d1050513          	addi	a0,a0,-752 # 800081a8 <etext+0x1a8>
    800014a0:	00005097          	auipc	ra,0x5
    800014a4:	9ac080e7          	jalr	-1620(ra) # 80005e4c <panic>
    panic("sched running");
    800014a8:	00007517          	auipc	a0,0x7
    800014ac:	d1050513          	addi	a0,a0,-752 # 800081b8 <etext+0x1b8>
    800014b0:	00005097          	auipc	ra,0x5
    800014b4:	99c080e7          	jalr	-1636(ra) # 80005e4c <panic>
    panic("sched interruptible");
    800014b8:	00007517          	auipc	a0,0x7
    800014bc:	d1050513          	addi	a0,a0,-752 # 800081c8 <etext+0x1c8>
    800014c0:	00005097          	auipc	ra,0x5
    800014c4:	98c080e7          	jalr	-1652(ra) # 80005e4c <panic>

00000000800014c8 <yield>:
{
    800014c8:	1101                	addi	sp,sp,-32
    800014ca:	ec06                	sd	ra,24(sp)
    800014cc:	e822                	sd	s0,16(sp)
    800014ce:	e426                	sd	s1,8(sp)
    800014d0:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800014d2:	00000097          	auipc	ra,0x0
    800014d6:	982080e7          	jalr	-1662(ra) # 80000e54 <myproc>
    800014da:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800014dc:	00005097          	auipc	ra,0x5
    800014e0:	ea8080e7          	jalr	-344(ra) # 80006384 <acquire>
  p->state = RUNNABLE;
    800014e4:	478d                	li	a5,3
    800014e6:	cc9c                	sw	a5,24(s1)
  sched();
    800014e8:	00000097          	auipc	ra,0x0
    800014ec:	f0a080e7          	jalr	-246(ra) # 800013f2 <sched>
  release(&p->lock);
    800014f0:	8526                	mv	a0,s1
    800014f2:	00005097          	auipc	ra,0x5
    800014f6:	f46080e7          	jalr	-186(ra) # 80006438 <release>
}
    800014fa:	60e2                	ld	ra,24(sp)
    800014fc:	6442                	ld	s0,16(sp)
    800014fe:	64a2                	ld	s1,8(sp)
    80001500:	6105                	addi	sp,sp,32
    80001502:	8082                	ret

0000000080001504 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001504:	7179                	addi	sp,sp,-48
    80001506:	f406                	sd	ra,40(sp)
    80001508:	f022                	sd	s0,32(sp)
    8000150a:	ec26                	sd	s1,24(sp)
    8000150c:	e84a                	sd	s2,16(sp)
    8000150e:	e44e                	sd	s3,8(sp)
    80001510:	1800                	addi	s0,sp,48
    80001512:	89aa                	mv	s3,a0
    80001514:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001516:	00000097          	auipc	ra,0x0
    8000151a:	93e080e7          	jalr	-1730(ra) # 80000e54 <myproc>
    8000151e:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001520:	00005097          	auipc	ra,0x5
    80001524:	e64080e7          	jalr	-412(ra) # 80006384 <acquire>
  release(lk);
    80001528:	854a                	mv	a0,s2
    8000152a:	00005097          	auipc	ra,0x5
    8000152e:	f0e080e7          	jalr	-242(ra) # 80006438 <release>

  // Go to sleep.
  p->chan = chan;
    80001532:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001536:	4789                	li	a5,2
    80001538:	cc9c                	sw	a5,24(s1)

  sched();
    8000153a:	00000097          	auipc	ra,0x0
    8000153e:	eb8080e7          	jalr	-328(ra) # 800013f2 <sched>

  // Tidy up.
  p->chan = 0;
    80001542:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001546:	8526                	mv	a0,s1
    80001548:	00005097          	auipc	ra,0x5
    8000154c:	ef0080e7          	jalr	-272(ra) # 80006438 <release>
  acquire(lk);
    80001550:	854a                	mv	a0,s2
    80001552:	00005097          	auipc	ra,0x5
    80001556:	e32080e7          	jalr	-462(ra) # 80006384 <acquire>
}
    8000155a:	70a2                	ld	ra,40(sp)
    8000155c:	7402                	ld	s0,32(sp)
    8000155e:	64e2                	ld	s1,24(sp)
    80001560:	6942                	ld	s2,16(sp)
    80001562:	69a2                	ld	s3,8(sp)
    80001564:	6145                	addi	sp,sp,48
    80001566:	8082                	ret

0000000080001568 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001568:	7139                	addi	sp,sp,-64
    8000156a:	fc06                	sd	ra,56(sp)
    8000156c:	f822                	sd	s0,48(sp)
    8000156e:	f426                	sd	s1,40(sp)
    80001570:	f04a                	sd	s2,32(sp)
    80001572:	ec4e                	sd	s3,24(sp)
    80001574:	e852                	sd	s4,16(sp)
    80001576:	e456                	sd	s5,8(sp)
    80001578:	0080                	addi	s0,sp,64
    8000157a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000157c:	00007497          	auipc	s1,0x7
    80001580:	7d448493          	addi	s1,s1,2004 # 80008d50 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001584:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001586:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001588:	00011917          	auipc	s2,0x11
    8000158c:	7c890913          	addi	s2,s2,1992 # 80012d50 <tickslock>
    80001590:	a811                	j	800015a4 <wakeup+0x3c>
      }
      release(&p->lock);
    80001592:	8526                	mv	a0,s1
    80001594:	00005097          	auipc	ra,0x5
    80001598:	ea4080e7          	jalr	-348(ra) # 80006438 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000159c:	28048493          	addi	s1,s1,640
    800015a0:	03248663          	beq	s1,s2,800015cc <wakeup+0x64>
    if(p != myproc()){
    800015a4:	00000097          	auipc	ra,0x0
    800015a8:	8b0080e7          	jalr	-1872(ra) # 80000e54 <myproc>
    800015ac:	fea488e3          	beq	s1,a0,8000159c <wakeup+0x34>
      acquire(&p->lock);
    800015b0:	8526                	mv	a0,s1
    800015b2:	00005097          	auipc	ra,0x5
    800015b6:	dd2080e7          	jalr	-558(ra) # 80006384 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800015ba:	4c9c                	lw	a5,24(s1)
    800015bc:	fd379be3          	bne	a5,s3,80001592 <wakeup+0x2a>
    800015c0:	709c                	ld	a5,32(s1)
    800015c2:	fd4798e3          	bne	a5,s4,80001592 <wakeup+0x2a>
        p->state = RUNNABLE;
    800015c6:	0154ac23          	sw	s5,24(s1)
    800015ca:	b7e1                	j	80001592 <wakeup+0x2a>
    }
  }
}
    800015cc:	70e2                	ld	ra,56(sp)
    800015ce:	7442                	ld	s0,48(sp)
    800015d0:	74a2                	ld	s1,40(sp)
    800015d2:	7902                	ld	s2,32(sp)
    800015d4:	69e2                	ld	s3,24(sp)
    800015d6:	6a42                	ld	s4,16(sp)
    800015d8:	6aa2                	ld	s5,8(sp)
    800015da:	6121                	addi	sp,sp,64
    800015dc:	8082                	ret

00000000800015de <reparent>:
{
    800015de:	7179                	addi	sp,sp,-48
    800015e0:	f406                	sd	ra,40(sp)
    800015e2:	f022                	sd	s0,32(sp)
    800015e4:	ec26                	sd	s1,24(sp)
    800015e6:	e84a                	sd	s2,16(sp)
    800015e8:	e44e                	sd	s3,8(sp)
    800015ea:	e052                	sd	s4,0(sp)
    800015ec:	1800                	addi	s0,sp,48
    800015ee:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800015f0:	00007497          	auipc	s1,0x7
    800015f4:	76048493          	addi	s1,s1,1888 # 80008d50 <proc>
      pp->parent = initproc;
    800015f8:	00007a17          	auipc	s4,0x7
    800015fc:	2e8a0a13          	addi	s4,s4,744 # 800088e0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001600:	00011997          	auipc	s3,0x11
    80001604:	75098993          	addi	s3,s3,1872 # 80012d50 <tickslock>
    80001608:	a029                	j	80001612 <reparent+0x34>
    8000160a:	28048493          	addi	s1,s1,640
    8000160e:	01348d63          	beq	s1,s3,80001628 <reparent+0x4a>
    if(pp->parent == p){
    80001612:	7c9c                	ld	a5,56(s1)
    80001614:	ff279be3          	bne	a5,s2,8000160a <reparent+0x2c>
      pp->parent = initproc;
    80001618:	000a3503          	ld	a0,0(s4)
    8000161c:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	f4a080e7          	jalr	-182(ra) # 80001568 <wakeup>
    80001626:	b7d5                	j	8000160a <reparent+0x2c>
}
    80001628:	70a2                	ld	ra,40(sp)
    8000162a:	7402                	ld	s0,32(sp)
    8000162c:	64e2                	ld	s1,24(sp)
    8000162e:	6942                	ld	s2,16(sp)
    80001630:	69a2                	ld	s3,8(sp)
    80001632:	6a02                	ld	s4,0(sp)
    80001634:	6145                	addi	sp,sp,48
    80001636:	8082                	ret

0000000080001638 <exit>:
{
    80001638:	7179                	addi	sp,sp,-48
    8000163a:	f406                	sd	ra,40(sp)
    8000163c:	f022                	sd	s0,32(sp)
    8000163e:	ec26                	sd	s1,24(sp)
    80001640:	e84a                	sd	s2,16(sp)
    80001642:	e44e                	sd	s3,8(sp)
    80001644:	e052                	sd	s4,0(sp)
    80001646:	1800                	addi	s0,sp,48
    80001648:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000164a:	00000097          	auipc	ra,0x0
    8000164e:	80a080e7          	jalr	-2038(ra) # 80000e54 <myproc>
    80001652:	89aa                	mv	s3,a0
  if(p == initproc)
    80001654:	00007797          	auipc	a5,0x7
    80001658:	28c7b783          	ld	a5,652(a5) # 800088e0 <initproc>
    8000165c:	0d050493          	addi	s1,a0,208
    80001660:	15050913          	addi	s2,a0,336
    80001664:	02a79363          	bne	a5,a0,8000168a <exit+0x52>
    panic("init exiting");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	b7850513          	addi	a0,a0,-1160 # 800081e0 <etext+0x1e0>
    80001670:	00004097          	auipc	ra,0x4
    80001674:	7dc080e7          	jalr	2012(ra) # 80005e4c <panic>
      fileclose(f);
    80001678:	00002097          	auipc	ra,0x2
    8000167c:	5bc080e7          	jalr	1468(ra) # 80003c34 <fileclose>
      p->ofile[fd] = 0;
    80001680:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001684:	04a1                	addi	s1,s1,8
    80001686:	01248563          	beq	s1,s2,80001690 <exit+0x58>
    if(p->ofile[fd]){
    8000168a:	6088                	ld	a0,0(s1)
    8000168c:	f575                	bnez	a0,80001678 <exit+0x40>
    8000168e:	bfdd                	j	80001684 <exit+0x4c>
  begin_op();
    80001690:	00002097          	auipc	ra,0x2
    80001694:	0dc080e7          	jalr	220(ra) # 8000376c <begin_op>
  iput(p->cwd);
    80001698:	1509b503          	ld	a0,336(s3)
    8000169c:	00002097          	auipc	ra,0x2
    800016a0:	8be080e7          	jalr	-1858(ra) # 80002f5a <iput>
  end_op();
    800016a4:	00002097          	auipc	ra,0x2
    800016a8:	146080e7          	jalr	326(ra) # 800037ea <end_op>
  p->cwd = 0;
    800016ac:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800016b0:	00007497          	auipc	s1,0x7
    800016b4:	28848493          	addi	s1,s1,648 # 80008938 <wait_lock>
    800016b8:	8526                	mv	a0,s1
    800016ba:	00005097          	auipc	ra,0x5
    800016be:	cca080e7          	jalr	-822(ra) # 80006384 <acquire>
  reparent(p);
    800016c2:	854e                	mv	a0,s3
    800016c4:	00000097          	auipc	ra,0x0
    800016c8:	f1a080e7          	jalr	-230(ra) # 800015de <reparent>
  wakeup(p->parent);
    800016cc:	0389b503          	ld	a0,56(s3)
    800016d0:	00000097          	auipc	ra,0x0
    800016d4:	e98080e7          	jalr	-360(ra) # 80001568 <wakeup>
  acquire(&p->lock);
    800016d8:	854e                	mv	a0,s3
    800016da:	00005097          	auipc	ra,0x5
    800016de:	caa080e7          	jalr	-854(ra) # 80006384 <acquire>
  p->xstate = status;
    800016e2:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800016e6:	4795                	li	a5,5
    800016e8:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800016ec:	8526                	mv	a0,s1
    800016ee:	00005097          	auipc	ra,0x5
    800016f2:	d4a080e7          	jalr	-694(ra) # 80006438 <release>
  sched();
    800016f6:	00000097          	auipc	ra,0x0
    800016fa:	cfc080e7          	jalr	-772(ra) # 800013f2 <sched>
  panic("zombie exit");
    800016fe:	00007517          	auipc	a0,0x7
    80001702:	af250513          	addi	a0,a0,-1294 # 800081f0 <etext+0x1f0>
    80001706:	00004097          	auipc	ra,0x4
    8000170a:	746080e7          	jalr	1862(ra) # 80005e4c <panic>

000000008000170e <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000170e:	7179                	addi	sp,sp,-48
    80001710:	f406                	sd	ra,40(sp)
    80001712:	f022                	sd	s0,32(sp)
    80001714:	ec26                	sd	s1,24(sp)
    80001716:	e84a                	sd	s2,16(sp)
    80001718:	e44e                	sd	s3,8(sp)
    8000171a:	1800                	addi	s0,sp,48
    8000171c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000171e:	00007497          	auipc	s1,0x7
    80001722:	63248493          	addi	s1,s1,1586 # 80008d50 <proc>
    80001726:	00011997          	auipc	s3,0x11
    8000172a:	62a98993          	addi	s3,s3,1578 # 80012d50 <tickslock>
    acquire(&p->lock);
    8000172e:	8526                	mv	a0,s1
    80001730:	00005097          	auipc	ra,0x5
    80001734:	c54080e7          	jalr	-940(ra) # 80006384 <acquire>
    if(p->pid == pid){
    80001738:	589c                	lw	a5,48(s1)
    8000173a:	01278d63          	beq	a5,s2,80001754 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000173e:	8526                	mv	a0,s1
    80001740:	00005097          	auipc	ra,0x5
    80001744:	cf8080e7          	jalr	-776(ra) # 80006438 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001748:	28048493          	addi	s1,s1,640
    8000174c:	ff3491e3          	bne	s1,s3,8000172e <kill+0x20>
  }
  return -1;
    80001750:	557d                	li	a0,-1
    80001752:	a829                	j	8000176c <kill+0x5e>
      p->killed = 1;
    80001754:	4785                	li	a5,1
    80001756:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001758:	4c98                	lw	a4,24(s1)
    8000175a:	4789                	li	a5,2
    8000175c:	00f70f63          	beq	a4,a5,8000177a <kill+0x6c>
      release(&p->lock);
    80001760:	8526                	mv	a0,s1
    80001762:	00005097          	auipc	ra,0x5
    80001766:	cd6080e7          	jalr	-810(ra) # 80006438 <release>
      return 0;
    8000176a:	4501                	li	a0,0
}
    8000176c:	70a2                	ld	ra,40(sp)
    8000176e:	7402                	ld	s0,32(sp)
    80001770:	64e2                	ld	s1,24(sp)
    80001772:	6942                	ld	s2,16(sp)
    80001774:	69a2                	ld	s3,8(sp)
    80001776:	6145                	addi	sp,sp,48
    80001778:	8082                	ret
        p->state = RUNNABLE;
    8000177a:	478d                	li	a5,3
    8000177c:	cc9c                	sw	a5,24(s1)
    8000177e:	b7cd                	j	80001760 <kill+0x52>

0000000080001780 <setkilled>:

void
setkilled(struct proc *p)
{
    80001780:	1101                	addi	sp,sp,-32
    80001782:	ec06                	sd	ra,24(sp)
    80001784:	e822                	sd	s0,16(sp)
    80001786:	e426                	sd	s1,8(sp)
    80001788:	1000                	addi	s0,sp,32
    8000178a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000178c:	00005097          	auipc	ra,0x5
    80001790:	bf8080e7          	jalr	-1032(ra) # 80006384 <acquire>
  p->killed = 1;
    80001794:	4785                	li	a5,1
    80001796:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001798:	8526                	mv	a0,s1
    8000179a:	00005097          	auipc	ra,0x5
    8000179e:	c9e080e7          	jalr	-866(ra) # 80006438 <release>
}
    800017a2:	60e2                	ld	ra,24(sp)
    800017a4:	6442                	ld	s0,16(sp)
    800017a6:	64a2                	ld	s1,8(sp)
    800017a8:	6105                	addi	sp,sp,32
    800017aa:	8082                	ret

00000000800017ac <killed>:

int
killed(struct proc *p)
{
    800017ac:	1101                	addi	sp,sp,-32
    800017ae:	ec06                	sd	ra,24(sp)
    800017b0:	e822                	sd	s0,16(sp)
    800017b2:	e426                	sd	s1,8(sp)
    800017b4:	e04a                	sd	s2,0(sp)
    800017b6:	1000                	addi	s0,sp,32
    800017b8:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800017ba:	00005097          	auipc	ra,0x5
    800017be:	bca080e7          	jalr	-1078(ra) # 80006384 <acquire>
  k = p->killed;
    800017c2:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800017c6:	8526                	mv	a0,s1
    800017c8:	00005097          	auipc	ra,0x5
    800017cc:	c70080e7          	jalr	-912(ra) # 80006438 <release>
  return k;
}
    800017d0:	854a                	mv	a0,s2
    800017d2:	60e2                	ld	ra,24(sp)
    800017d4:	6442                	ld	s0,16(sp)
    800017d6:	64a2                	ld	s1,8(sp)
    800017d8:	6902                	ld	s2,0(sp)
    800017da:	6105                	addi	sp,sp,32
    800017dc:	8082                	ret

00000000800017de <wait>:
{
    800017de:	715d                	addi	sp,sp,-80
    800017e0:	e486                	sd	ra,72(sp)
    800017e2:	e0a2                	sd	s0,64(sp)
    800017e4:	fc26                	sd	s1,56(sp)
    800017e6:	f84a                	sd	s2,48(sp)
    800017e8:	f44e                	sd	s3,40(sp)
    800017ea:	f052                	sd	s4,32(sp)
    800017ec:	ec56                	sd	s5,24(sp)
    800017ee:	e85a                	sd	s6,16(sp)
    800017f0:	e45e                	sd	s7,8(sp)
    800017f2:	e062                	sd	s8,0(sp)
    800017f4:	0880                	addi	s0,sp,80
    800017f6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800017f8:	fffff097          	auipc	ra,0xfffff
    800017fc:	65c080e7          	jalr	1628(ra) # 80000e54 <myproc>
    80001800:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001802:	00007517          	auipc	a0,0x7
    80001806:	13650513          	addi	a0,a0,310 # 80008938 <wait_lock>
    8000180a:	00005097          	auipc	ra,0x5
    8000180e:	b7a080e7          	jalr	-1158(ra) # 80006384 <acquire>
    havekids = 0;
    80001812:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001814:	4a15                	li	s4,5
        havekids = 1;
    80001816:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001818:	00011997          	auipc	s3,0x11
    8000181c:	53898993          	addi	s3,s3,1336 # 80012d50 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001820:	00007c17          	auipc	s8,0x7
    80001824:	118c0c13          	addi	s8,s8,280 # 80008938 <wait_lock>
    havekids = 0;
    80001828:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000182a:	00007497          	auipc	s1,0x7
    8000182e:	52648493          	addi	s1,s1,1318 # 80008d50 <proc>
    80001832:	a0bd                	j	800018a0 <wait+0xc2>
          pid = pp->pid;
    80001834:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001838:	000b0e63          	beqz	s6,80001854 <wait+0x76>
    8000183c:	4691                	li	a3,4
    8000183e:	02c48613          	addi	a2,s1,44
    80001842:	85da                	mv	a1,s6
    80001844:	05093503          	ld	a0,80(s2)
    80001848:	fffff097          	auipc	ra,0xfffff
    8000184c:	2cc080e7          	jalr	716(ra) # 80000b14 <copyout>
    80001850:	02054563          	bltz	a0,8000187a <wait+0x9c>
          freeproc(pp);
    80001854:	8526                	mv	a0,s1
    80001856:	fffff097          	auipc	ra,0xfffff
    8000185a:	7b0080e7          	jalr	1968(ra) # 80001006 <freeproc>
          release(&pp->lock);
    8000185e:	8526                	mv	a0,s1
    80001860:	00005097          	auipc	ra,0x5
    80001864:	bd8080e7          	jalr	-1064(ra) # 80006438 <release>
          release(&wait_lock);
    80001868:	00007517          	auipc	a0,0x7
    8000186c:	0d050513          	addi	a0,a0,208 # 80008938 <wait_lock>
    80001870:	00005097          	auipc	ra,0x5
    80001874:	bc8080e7          	jalr	-1080(ra) # 80006438 <release>
          return pid;
    80001878:	a0b5                	j	800018e4 <wait+0x106>
            release(&pp->lock);
    8000187a:	8526                	mv	a0,s1
    8000187c:	00005097          	auipc	ra,0x5
    80001880:	bbc080e7          	jalr	-1092(ra) # 80006438 <release>
            release(&wait_lock);
    80001884:	00007517          	auipc	a0,0x7
    80001888:	0b450513          	addi	a0,a0,180 # 80008938 <wait_lock>
    8000188c:	00005097          	auipc	ra,0x5
    80001890:	bac080e7          	jalr	-1108(ra) # 80006438 <release>
            return -1;
    80001894:	59fd                	li	s3,-1
    80001896:	a0b9                	j	800018e4 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001898:	28048493          	addi	s1,s1,640
    8000189c:	03348463          	beq	s1,s3,800018c4 <wait+0xe6>
      if(pp->parent == p){
    800018a0:	7c9c                	ld	a5,56(s1)
    800018a2:	ff279be3          	bne	a5,s2,80001898 <wait+0xba>
        acquire(&pp->lock);
    800018a6:	8526                	mv	a0,s1
    800018a8:	00005097          	auipc	ra,0x5
    800018ac:	adc080e7          	jalr	-1316(ra) # 80006384 <acquire>
        if(pp->state == ZOMBIE){
    800018b0:	4c9c                	lw	a5,24(s1)
    800018b2:	f94781e3          	beq	a5,s4,80001834 <wait+0x56>
        release(&pp->lock);
    800018b6:	8526                	mv	a0,s1
    800018b8:	00005097          	auipc	ra,0x5
    800018bc:	b80080e7          	jalr	-1152(ra) # 80006438 <release>
        havekids = 1;
    800018c0:	8756                	mv	a4,s5
    800018c2:	bfd9                	j	80001898 <wait+0xba>
    if(!havekids || killed(p)){
    800018c4:	c719                	beqz	a4,800018d2 <wait+0xf4>
    800018c6:	854a                	mv	a0,s2
    800018c8:	00000097          	auipc	ra,0x0
    800018cc:	ee4080e7          	jalr	-284(ra) # 800017ac <killed>
    800018d0:	c51d                	beqz	a0,800018fe <wait+0x120>
      release(&wait_lock);
    800018d2:	00007517          	auipc	a0,0x7
    800018d6:	06650513          	addi	a0,a0,102 # 80008938 <wait_lock>
    800018da:	00005097          	auipc	ra,0x5
    800018de:	b5e080e7          	jalr	-1186(ra) # 80006438 <release>
      return -1;
    800018e2:	59fd                	li	s3,-1
}
    800018e4:	854e                	mv	a0,s3
    800018e6:	60a6                	ld	ra,72(sp)
    800018e8:	6406                	ld	s0,64(sp)
    800018ea:	74e2                	ld	s1,56(sp)
    800018ec:	7942                	ld	s2,48(sp)
    800018ee:	79a2                	ld	s3,40(sp)
    800018f0:	7a02                	ld	s4,32(sp)
    800018f2:	6ae2                	ld	s5,24(sp)
    800018f4:	6b42                	ld	s6,16(sp)
    800018f6:	6ba2                	ld	s7,8(sp)
    800018f8:	6c02                	ld	s8,0(sp)
    800018fa:	6161                	addi	sp,sp,80
    800018fc:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800018fe:	85e2                	mv	a1,s8
    80001900:	854a                	mv	a0,s2
    80001902:	00000097          	auipc	ra,0x0
    80001906:	c02080e7          	jalr	-1022(ra) # 80001504 <sleep>
    havekids = 0;
    8000190a:	bf39                	j	80001828 <wait+0x4a>

000000008000190c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000190c:	7179                	addi	sp,sp,-48
    8000190e:	f406                	sd	ra,40(sp)
    80001910:	f022                	sd	s0,32(sp)
    80001912:	ec26                	sd	s1,24(sp)
    80001914:	e84a                	sd	s2,16(sp)
    80001916:	e44e                	sd	s3,8(sp)
    80001918:	e052                	sd	s4,0(sp)
    8000191a:	1800                	addi	s0,sp,48
    8000191c:	84aa                	mv	s1,a0
    8000191e:	892e                	mv	s2,a1
    80001920:	89b2                	mv	s3,a2
    80001922:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001924:	fffff097          	auipc	ra,0xfffff
    80001928:	530080e7          	jalr	1328(ra) # 80000e54 <myproc>
  if(user_dst){
    8000192c:	c08d                	beqz	s1,8000194e <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000192e:	86d2                	mv	a3,s4
    80001930:	864e                	mv	a2,s3
    80001932:	85ca                	mv	a1,s2
    80001934:	6928                	ld	a0,80(a0)
    80001936:	fffff097          	auipc	ra,0xfffff
    8000193a:	1de080e7          	jalr	478(ra) # 80000b14 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000193e:	70a2                	ld	ra,40(sp)
    80001940:	7402                	ld	s0,32(sp)
    80001942:	64e2                	ld	s1,24(sp)
    80001944:	6942                	ld	s2,16(sp)
    80001946:	69a2                	ld	s3,8(sp)
    80001948:	6a02                	ld	s4,0(sp)
    8000194a:	6145                	addi	sp,sp,48
    8000194c:	8082                	ret
    memmove((char *)dst, src, len);
    8000194e:	000a061b          	sext.w	a2,s4
    80001952:	85ce                	mv	a1,s3
    80001954:	854a                	mv	a0,s2
    80001956:	fffff097          	auipc	ra,0xfffff
    8000195a:	880080e7          	jalr	-1920(ra) # 800001d6 <memmove>
    return 0;
    8000195e:	8526                	mv	a0,s1
    80001960:	bff9                	j	8000193e <either_copyout+0x32>

0000000080001962 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001962:	7179                	addi	sp,sp,-48
    80001964:	f406                	sd	ra,40(sp)
    80001966:	f022                	sd	s0,32(sp)
    80001968:	ec26                	sd	s1,24(sp)
    8000196a:	e84a                	sd	s2,16(sp)
    8000196c:	e44e                	sd	s3,8(sp)
    8000196e:	e052                	sd	s4,0(sp)
    80001970:	1800                	addi	s0,sp,48
    80001972:	892a                	mv	s2,a0
    80001974:	84ae                	mv	s1,a1
    80001976:	89b2                	mv	s3,a2
    80001978:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000197a:	fffff097          	auipc	ra,0xfffff
    8000197e:	4da080e7          	jalr	1242(ra) # 80000e54 <myproc>
  if(user_src){
    80001982:	c08d                	beqz	s1,800019a4 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001984:	86d2                	mv	a3,s4
    80001986:	864e                	mv	a2,s3
    80001988:	85ca                	mv	a1,s2
    8000198a:	6928                	ld	a0,80(a0)
    8000198c:	fffff097          	auipc	ra,0xfffff
    80001990:	214080e7          	jalr	532(ra) # 80000ba0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001994:	70a2                	ld	ra,40(sp)
    80001996:	7402                	ld	s0,32(sp)
    80001998:	64e2                	ld	s1,24(sp)
    8000199a:	6942                	ld	s2,16(sp)
    8000199c:	69a2                	ld	s3,8(sp)
    8000199e:	6a02                	ld	s4,0(sp)
    800019a0:	6145                	addi	sp,sp,48
    800019a2:	8082                	ret
    memmove(dst, (char*)src, len);
    800019a4:	000a061b          	sext.w	a2,s4
    800019a8:	85ce                	mv	a1,s3
    800019aa:	854a                	mv	a0,s2
    800019ac:	fffff097          	auipc	ra,0xfffff
    800019b0:	82a080e7          	jalr	-2006(ra) # 800001d6 <memmove>
    return 0;
    800019b4:	8526                	mv	a0,s1
    800019b6:	bff9                	j	80001994 <either_copyin+0x32>

00000000800019b8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800019b8:	715d                	addi	sp,sp,-80
    800019ba:	e486                	sd	ra,72(sp)
    800019bc:	e0a2                	sd	s0,64(sp)
    800019be:	fc26                	sd	s1,56(sp)
    800019c0:	f84a                	sd	s2,48(sp)
    800019c2:	f44e                	sd	s3,40(sp)
    800019c4:	f052                	sd	s4,32(sp)
    800019c6:	ec56                	sd	s5,24(sp)
    800019c8:	e85a                	sd	s6,16(sp)
    800019ca:	e45e                	sd	s7,8(sp)
    800019cc:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800019ce:	00006517          	auipc	a0,0x6
    800019d2:	67a50513          	addi	a0,a0,1658 # 80008048 <etext+0x48>
    800019d6:	00004097          	auipc	ra,0x4
    800019da:	4c0080e7          	jalr	1216(ra) # 80005e96 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800019de:	00007497          	auipc	s1,0x7
    800019e2:	4ca48493          	addi	s1,s1,1226 # 80008ea8 <proc+0x158>
    800019e6:	00011917          	auipc	s2,0x11
    800019ea:	4c290913          	addi	s2,s2,1218 # 80012ea8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800019ee:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800019f0:	00007997          	auipc	s3,0x7
    800019f4:	81098993          	addi	s3,s3,-2032 # 80008200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    800019f8:	00007a97          	auipc	s5,0x7
    800019fc:	810a8a93          	addi	s5,s5,-2032 # 80008208 <etext+0x208>
    printf("\n");
    80001a00:	00006a17          	auipc	s4,0x6
    80001a04:	648a0a13          	addi	s4,s4,1608 # 80008048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a08:	00007b97          	auipc	s7,0x7
    80001a0c:	840b8b93          	addi	s7,s7,-1984 # 80008248 <states.0>
    80001a10:	a00d                	j	80001a32 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001a12:	ed86a583          	lw	a1,-296(a3)
    80001a16:	8556                	mv	a0,s5
    80001a18:	00004097          	auipc	ra,0x4
    80001a1c:	47e080e7          	jalr	1150(ra) # 80005e96 <printf>
    printf("\n");
    80001a20:	8552                	mv	a0,s4
    80001a22:	00004097          	auipc	ra,0x4
    80001a26:	474080e7          	jalr	1140(ra) # 80005e96 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a2a:	28048493          	addi	s1,s1,640
    80001a2e:	03248263          	beq	s1,s2,80001a52 <procdump+0x9a>
    if(p->state == UNUSED)
    80001a32:	86a6                	mv	a3,s1
    80001a34:	ec04a783          	lw	a5,-320(s1)
    80001a38:	dbed                	beqz	a5,80001a2a <procdump+0x72>
      state = "???";
    80001a3a:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a3c:	fcfb6be3          	bltu	s6,a5,80001a12 <procdump+0x5a>
    80001a40:	02079713          	slli	a4,a5,0x20
    80001a44:	01d75793          	srli	a5,a4,0x1d
    80001a48:	97de                	add	a5,a5,s7
    80001a4a:	6390                	ld	a2,0(a5)
    80001a4c:	f279                	bnez	a2,80001a12 <procdump+0x5a>
      state = "???";
    80001a4e:	864e                	mv	a2,s3
    80001a50:	b7c9                	j	80001a12 <procdump+0x5a>
  }
}
    80001a52:	60a6                	ld	ra,72(sp)
    80001a54:	6406                	ld	s0,64(sp)
    80001a56:	74e2                	ld	s1,56(sp)
    80001a58:	7942                	ld	s2,48(sp)
    80001a5a:	79a2                	ld	s3,40(sp)
    80001a5c:	7a02                	ld	s4,32(sp)
    80001a5e:	6ae2                	ld	s5,24(sp)
    80001a60:	6b42                	ld	s6,16(sp)
    80001a62:	6ba2                	ld	s7,8(sp)
    80001a64:	6161                	addi	sp,sp,80
    80001a66:	8082                	ret

0000000080001a68 <swtch>:
    80001a68:	00153023          	sd	ra,0(a0)
    80001a6c:	00253423          	sd	sp,8(a0)
    80001a70:	e900                	sd	s0,16(a0)
    80001a72:	ed04                	sd	s1,24(a0)
    80001a74:	03253023          	sd	s2,32(a0)
    80001a78:	03353423          	sd	s3,40(a0)
    80001a7c:	03453823          	sd	s4,48(a0)
    80001a80:	03553c23          	sd	s5,56(a0)
    80001a84:	05653023          	sd	s6,64(a0)
    80001a88:	05753423          	sd	s7,72(a0)
    80001a8c:	05853823          	sd	s8,80(a0)
    80001a90:	05953c23          	sd	s9,88(a0)
    80001a94:	07a53023          	sd	s10,96(a0)
    80001a98:	07b53423          	sd	s11,104(a0)
    80001a9c:	0005b083          	ld	ra,0(a1)
    80001aa0:	0085b103          	ld	sp,8(a1)
    80001aa4:	6980                	ld	s0,16(a1)
    80001aa6:	6d84                	ld	s1,24(a1)
    80001aa8:	0205b903          	ld	s2,32(a1)
    80001aac:	0285b983          	ld	s3,40(a1)
    80001ab0:	0305ba03          	ld	s4,48(a1)
    80001ab4:	0385ba83          	ld	s5,56(a1)
    80001ab8:	0405bb03          	ld	s6,64(a1)
    80001abc:	0485bb83          	ld	s7,72(a1)
    80001ac0:	0505bc03          	ld	s8,80(a1)
    80001ac4:	0585bc83          	ld	s9,88(a1)
    80001ac8:	0605bd03          	ld	s10,96(a1)
    80001acc:	0685bd83          	ld	s11,104(a1)
    80001ad0:	8082                	ret

0000000080001ad2 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001ad2:	1141                	addi	sp,sp,-16
    80001ad4:	e406                	sd	ra,8(sp)
    80001ad6:	e022                	sd	s0,0(sp)
    80001ad8:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001ada:	00006597          	auipc	a1,0x6
    80001ade:	79e58593          	addi	a1,a1,1950 # 80008278 <states.0+0x30>
    80001ae2:	00011517          	auipc	a0,0x11
    80001ae6:	26e50513          	addi	a0,a0,622 # 80012d50 <tickslock>
    80001aea:	00005097          	auipc	ra,0x5
    80001aee:	80a080e7          	jalr	-2038(ra) # 800062f4 <initlock>
}
    80001af2:	60a2                	ld	ra,8(sp)
    80001af4:	6402                	ld	s0,0(sp)
    80001af6:	0141                	addi	sp,sp,16
    80001af8:	8082                	ret

0000000080001afa <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001afa:	1141                	addi	sp,sp,-16
    80001afc:	e422                	sd	s0,8(sp)
    80001afe:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b00:	00003797          	auipc	a5,0x3
    80001b04:	78078793          	addi	a5,a5,1920 # 80005280 <kernelvec>
    80001b08:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001b0c:	6422                	ld	s0,8(sp)
    80001b0e:	0141                	addi	sp,sp,16
    80001b10:	8082                	ret

0000000080001b12 <store>:

void
store(void)
{
    80001b12:	1141                	addi	sp,sp,-16
    80001b14:	e406                	sd	ra,8(sp)
    80001b16:	e022                	sd	s0,0(sp)
    80001b18:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	33a080e7          	jalr	826(ra) # 80000e54 <myproc>

  p->tick_ra = p->trapframe->ra;
    80001b22:	6d3c                	ld	a5,88(a0)
    80001b24:	7798                	ld	a4,40(a5)
    80001b26:	18e53423          	sd	a4,392(a0)
  p->tick_sp = p->trapframe->sp;
    80001b2a:	7b98                	ld	a4,48(a5)
    80001b2c:	18e53823          	sd	a4,400(a0)
  p->tick_gp = p->trapframe->gp;
    80001b30:	7f98                	ld	a4,56(a5)
    80001b32:	18e53c23          	sd	a4,408(a0)
  p->tick_tp = p->trapframe->tp;
    80001b36:	63b8                	ld	a4,64(a5)
    80001b38:	1ae53023          	sd	a4,416(a0)
  p->tick_t0 = p->trapframe->t0;
    80001b3c:	67b8                	ld	a4,72(a5)
    80001b3e:	1ae53423          	sd	a4,424(a0)
  p->tick_t1 = p->trapframe->t1;
    80001b42:	6bb8                	ld	a4,80(a5)
    80001b44:	1ae53823          	sd	a4,432(a0)
  p->tick_t2 = p->trapframe->t2;
    80001b48:	6fb8                	ld	a4,88(a5)
    80001b4a:	1ae53c23          	sd	a4,440(a0)
  p->tick_s0 = p->trapframe->s0;
    80001b4e:	73b8                	ld	a4,96(a5)
    80001b50:	1ce53023          	sd	a4,448(a0)
  p->tick_s1 = p->trapframe->s1;
    80001b54:	77b8                	ld	a4,104(a5)
    80001b56:	1ce53423          	sd	a4,456(a0)
  p->tick_a0 = p->trapframe->a0;
    80001b5a:	7bb8                	ld	a4,112(a5)
    80001b5c:	1ce53823          	sd	a4,464(a0)
  p->tick_a1 = p->trapframe->a1;
    80001b60:	7fb8                	ld	a4,120(a5)
    80001b62:	1ce53c23          	sd	a4,472(a0)
  p->tick_a2 = p->trapframe->a2;
    80001b66:	63d8                	ld	a4,128(a5)
    80001b68:	1ee53023          	sd	a4,480(a0)
  p->tick_a3 = p->trapframe->a3;
    80001b6c:	67d8                	ld	a4,136(a5)
    80001b6e:	1ee53423          	sd	a4,488(a0)
  p->tick_a4 = p->trapframe->a4;
    80001b72:	6bd8                	ld	a4,144(a5)
    80001b74:	1ee53823          	sd	a4,496(a0)
  p->tick_a5 = p->trapframe->a5;
    80001b78:	6fd8                	ld	a4,152(a5)
    80001b7a:	1ee53c23          	sd	a4,504(a0)
  p->tick_a6 = p->trapframe->a6;
    80001b7e:	73d8                	ld	a4,160(a5)
    80001b80:	20e53023          	sd	a4,512(a0)
  p->tick_a7 = p->trapframe->a7;
    80001b84:	77d8                	ld	a4,168(a5)
    80001b86:	20e53423          	sd	a4,520(a0)
  p->tick_s2 = p->trapframe->s2;
    80001b8a:	7bd8                	ld	a4,176(a5)
    80001b8c:	20e53823          	sd	a4,528(a0)
  p->tick_s3 = p->trapframe->s3;
    80001b90:	7fd8                	ld	a4,184(a5)
    80001b92:	20e53c23          	sd	a4,536(a0)
  p->tick_s4 = p->trapframe->s4;
    80001b96:	63f8                	ld	a4,192(a5)
    80001b98:	22e53023          	sd	a4,544(a0)
  p->tick_s5 = p->trapframe->s5;
    80001b9c:	67f8                	ld	a4,200(a5)
    80001b9e:	22e53423          	sd	a4,552(a0)
  p->tick_s6 = p->trapframe->s6;
    80001ba2:	6bf8                	ld	a4,208(a5)
    80001ba4:	22e53823          	sd	a4,560(a0)
  p->tick_s7 = p->trapframe->s7;
    80001ba8:	6ff8                	ld	a4,216(a5)
    80001baa:	22e53c23          	sd	a4,568(a0)
  p->tick_s8 = p->trapframe->s8;
    80001bae:	73f8                	ld	a4,224(a5)
    80001bb0:	24e53023          	sd	a4,576(a0)
  p->tick_s9 = p->trapframe->s9;
    80001bb4:	77f8                	ld	a4,232(a5)
    80001bb6:	24e53423          	sd	a4,584(a0)
  p->tick_s10 = p->trapframe->s10;
    80001bba:	7bf8                	ld	a4,240(a5)
    80001bbc:	24e53823          	sd	a4,592(a0)
  p->tick_s11 = p->trapframe->s11;
    80001bc0:	7ff8                	ld	a4,248(a5)
    80001bc2:	24e53c23          	sd	a4,600(a0)
  p->tick_t3 = p->trapframe->t3;
    80001bc6:	1007b703          	ld	a4,256(a5)
    80001bca:	26e53023          	sd	a4,608(a0)
  p->tick_t4 = p->trapframe->t4;
    80001bce:	1087b703          	ld	a4,264(a5)
    80001bd2:	26e53423          	sd	a4,616(a0)
  p->tick_t5 = p->trapframe->t5;
    80001bd6:	1107b703          	ld	a4,272(a5)
    80001bda:	26e53823          	sd	a4,624(a0)
  p->tick_t6 = p->trapframe->t6;
    80001bde:	1187b783          	ld	a5,280(a5)
    80001be2:	26f53c23          	sd	a5,632(a0)

}
    80001be6:	60a2                	ld	ra,8(sp)
    80001be8:	6402                	ld	s0,0(sp)
    80001bea:	0141                	addi	sp,sp,16
    80001bec:	8082                	ret

0000000080001bee <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001bee:	1141                	addi	sp,sp,-16
    80001bf0:	e406                	sd	ra,8(sp)
    80001bf2:	e022                	sd	s0,0(sp)
    80001bf4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001bf6:	fffff097          	auipc	ra,0xfffff
    80001bfa:	25e080e7          	jalr	606(ra) # 80000e54 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001bfe:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001c02:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c04:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001c08:	00005697          	auipc	a3,0x5
    80001c0c:	3f868693          	addi	a3,a3,1016 # 80007000 <_trampoline>
    80001c10:	00005717          	auipc	a4,0x5
    80001c14:	3f070713          	addi	a4,a4,1008 # 80007000 <_trampoline>
    80001c18:	8f15                	sub	a4,a4,a3
    80001c1a:	040007b7          	lui	a5,0x4000
    80001c1e:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001c20:	07b2                	slli	a5,a5,0xc
    80001c22:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001c24:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001c28:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001c2a:	18002673          	csrr	a2,satp
    80001c2e:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001c30:	6d30                	ld	a2,88(a0)
    80001c32:	6138                	ld	a4,64(a0)
    80001c34:	6585                	lui	a1,0x1
    80001c36:	972e                	add	a4,a4,a1
    80001c38:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001c3a:	6d38                	ld	a4,88(a0)
    80001c3c:	00000617          	auipc	a2,0x0
    80001c40:	13060613          	addi	a2,a2,304 # 80001d6c <usertrap>
    80001c44:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001c46:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c48:	8612                	mv	a2,tp
    80001c4a:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c4c:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001c50:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001c54:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001c58:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001c5c:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001c5e:	6f18                	ld	a4,24(a4)
    80001c60:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c64:	6928                	ld	a0,80(a0)
    80001c66:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c68:	00005717          	auipc	a4,0x5
    80001c6c:	43470713          	addi	a4,a4,1076 # 8000709c <userret>
    80001c70:	8f15                	sub	a4,a4,a3
    80001c72:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c74:	577d                	li	a4,-1
    80001c76:	177e                	slli	a4,a4,0x3f
    80001c78:	8d59                	or	a0,a0,a4
    80001c7a:	9782                	jalr	a5
}
    80001c7c:	60a2                	ld	ra,8(sp)
    80001c7e:	6402                	ld	s0,0(sp)
    80001c80:	0141                	addi	sp,sp,16
    80001c82:	8082                	ret

0000000080001c84 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001c84:	1101                	addi	sp,sp,-32
    80001c86:	ec06                	sd	ra,24(sp)
    80001c88:	e822                	sd	s0,16(sp)
    80001c8a:	e426                	sd	s1,8(sp)
    80001c8c:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001c8e:	00011497          	auipc	s1,0x11
    80001c92:	0c248493          	addi	s1,s1,194 # 80012d50 <tickslock>
    80001c96:	8526                	mv	a0,s1
    80001c98:	00004097          	auipc	ra,0x4
    80001c9c:	6ec080e7          	jalr	1772(ra) # 80006384 <acquire>
  ticks++;
    80001ca0:	00007517          	auipc	a0,0x7
    80001ca4:	c4850513          	addi	a0,a0,-952 # 800088e8 <ticks>
    80001ca8:	411c                	lw	a5,0(a0)
    80001caa:	2785                	addiw	a5,a5,1
    80001cac:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001cae:	00000097          	auipc	ra,0x0
    80001cb2:	8ba080e7          	jalr	-1862(ra) # 80001568 <wakeup>
  release(&tickslock);
    80001cb6:	8526                	mv	a0,s1
    80001cb8:	00004097          	auipc	ra,0x4
    80001cbc:	780080e7          	jalr	1920(ra) # 80006438 <release>
}
    80001cc0:	60e2                	ld	ra,24(sp)
    80001cc2:	6442                	ld	s0,16(sp)
    80001cc4:	64a2                	ld	s1,8(sp)
    80001cc6:	6105                	addi	sp,sp,32
    80001cc8:	8082                	ret

0000000080001cca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001cca:	1101                	addi	sp,sp,-32
    80001ccc:	ec06                	sd	ra,24(sp)
    80001cce:	e822                	sd	s0,16(sp)
    80001cd0:	e426                	sd	s1,8(sp)
    80001cd2:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001cd4:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001cd8:	00074d63          	bltz	a4,80001cf2 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001cdc:	57fd                	li	a5,-1
    80001cde:	17fe                	slli	a5,a5,0x3f
    80001ce0:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001ce2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001ce4:	06f70363          	beq	a4,a5,80001d4a <devintr+0x80>
  }
}
    80001ce8:	60e2                	ld	ra,24(sp)
    80001cea:	6442                	ld	s0,16(sp)
    80001cec:	64a2                	ld	s1,8(sp)
    80001cee:	6105                	addi	sp,sp,32
    80001cf0:	8082                	ret
     (scause & 0xff) == 9){
    80001cf2:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80001cf6:	46a5                	li	a3,9
    80001cf8:	fed792e3          	bne	a5,a3,80001cdc <devintr+0x12>
    int irq = plic_claim();
    80001cfc:	00003097          	auipc	ra,0x3
    80001d00:	68c080e7          	jalr	1676(ra) # 80005388 <plic_claim>
    80001d04:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001d06:	47a9                	li	a5,10
    80001d08:	02f50763          	beq	a0,a5,80001d36 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001d0c:	4785                	li	a5,1
    80001d0e:	02f50963          	beq	a0,a5,80001d40 <devintr+0x76>
    return 1;
    80001d12:	4505                	li	a0,1
    } else if(irq){
    80001d14:	d8f1                	beqz	s1,80001ce8 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001d16:	85a6                	mv	a1,s1
    80001d18:	00006517          	auipc	a0,0x6
    80001d1c:	56850513          	addi	a0,a0,1384 # 80008280 <states.0+0x38>
    80001d20:	00004097          	auipc	ra,0x4
    80001d24:	176080e7          	jalr	374(ra) # 80005e96 <printf>
      plic_complete(irq);
    80001d28:	8526                	mv	a0,s1
    80001d2a:	00003097          	auipc	ra,0x3
    80001d2e:	682080e7          	jalr	1666(ra) # 800053ac <plic_complete>
    return 1;
    80001d32:	4505                	li	a0,1
    80001d34:	bf55                	j	80001ce8 <devintr+0x1e>
      uartintr();
    80001d36:	00004097          	auipc	ra,0x4
    80001d3a:	56e080e7          	jalr	1390(ra) # 800062a4 <uartintr>
    80001d3e:	b7ed                	j	80001d28 <devintr+0x5e>
      virtio_disk_intr();
    80001d40:	00004097          	auipc	ra,0x4
    80001d44:	b34080e7          	jalr	-1228(ra) # 80005874 <virtio_disk_intr>
    80001d48:	b7c5                	j	80001d28 <devintr+0x5e>
    if(cpuid() == 0){
    80001d4a:	fffff097          	auipc	ra,0xfffff
    80001d4e:	0de080e7          	jalr	222(ra) # 80000e28 <cpuid>
    80001d52:	c901                	beqz	a0,80001d62 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001d54:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001d58:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001d5a:	14479073          	csrw	sip,a5
    return 2;
    80001d5e:	4509                	li	a0,2
    80001d60:	b761                	j	80001ce8 <devintr+0x1e>
      clockintr();
    80001d62:	00000097          	auipc	ra,0x0
    80001d66:	f22080e7          	jalr	-222(ra) # 80001c84 <clockintr>
    80001d6a:	b7ed                	j	80001d54 <devintr+0x8a>

0000000080001d6c <usertrap>:
{
    80001d6c:	1101                	addi	sp,sp,-32
    80001d6e:	ec06                	sd	ra,24(sp)
    80001d70:	e822                	sd	s0,16(sp)
    80001d72:	e426                	sd	s1,8(sp)
    80001d74:	e04a                	sd	s2,0(sp)
    80001d76:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d78:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001d7c:	1007f793          	andi	a5,a5,256
    80001d80:	e3b1                	bnez	a5,80001dc4 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d82:	00003797          	auipc	a5,0x3
    80001d86:	4fe78793          	addi	a5,a5,1278 # 80005280 <kernelvec>
    80001d8a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001d8e:	fffff097          	auipc	ra,0xfffff
    80001d92:	0c6080e7          	jalr	198(ra) # 80000e54 <myproc>
    80001d96:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001d98:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d9a:	14102773          	csrr	a4,sepc
    80001d9e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001da0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001da4:	47a1                	li	a5,8
    80001da6:	02f70763          	beq	a4,a5,80001dd4 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80001daa:	00000097          	auipc	ra,0x0
    80001dae:	f20080e7          	jalr	-224(ra) # 80001cca <devintr>
    80001db2:	892a                	mv	s2,a0
    80001db4:	c92d                	beqz	a0,80001e26 <usertrap+0xba>
  if(killed(p))
    80001db6:	8526                	mv	a0,s1
    80001db8:	00000097          	auipc	ra,0x0
    80001dbc:	9f4080e7          	jalr	-1548(ra) # 800017ac <killed>
    80001dc0:	c555                	beqz	a0,80001e6c <usertrap+0x100>
    80001dc2:	a045                	j	80001e62 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80001dc4:	00006517          	auipc	a0,0x6
    80001dc8:	4dc50513          	addi	a0,a0,1244 # 800082a0 <states.0+0x58>
    80001dcc:	00004097          	auipc	ra,0x4
    80001dd0:	080080e7          	jalr	128(ra) # 80005e4c <panic>
    if(killed(p))
    80001dd4:	00000097          	auipc	ra,0x0
    80001dd8:	9d8080e7          	jalr	-1576(ra) # 800017ac <killed>
    80001ddc:	ed1d                	bnez	a0,80001e1a <usertrap+0xae>
    p->trapframe->epc += 4;
    80001dde:	6cb8                	ld	a4,88(s1)
    80001de0:	6f1c                	ld	a5,24(a4)
    80001de2:	0791                	addi	a5,a5,4
    80001de4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001de6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001dea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dee:	10079073          	csrw	sstatus,a5
    syscall();
    80001df2:	00000097          	auipc	ra,0x0
    80001df6:	318080e7          	jalr	792(ra) # 8000210a <syscall>
  if(killed(p))
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	00000097          	auipc	ra,0x0
    80001e00:	9b0080e7          	jalr	-1616(ra) # 800017ac <killed>
    80001e04:	ed31                	bnez	a0,80001e60 <usertrap+0xf4>
  usertrapret();
    80001e06:	00000097          	auipc	ra,0x0
    80001e0a:	de8080e7          	jalr	-536(ra) # 80001bee <usertrapret>
}
    80001e0e:	60e2                	ld	ra,24(sp)
    80001e10:	6442                	ld	s0,16(sp)
    80001e12:	64a2                	ld	s1,8(sp)
    80001e14:	6902                	ld	s2,0(sp)
    80001e16:	6105                	addi	sp,sp,32
    80001e18:	8082                	ret
      exit(-1);
    80001e1a:	557d                	li	a0,-1
    80001e1c:	00000097          	auipc	ra,0x0
    80001e20:	81c080e7          	jalr	-2020(ra) # 80001638 <exit>
    80001e24:	bf6d                	j	80001dde <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e26:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001e2a:	5890                	lw	a2,48(s1)
    80001e2c:	00006517          	auipc	a0,0x6
    80001e30:	49450513          	addi	a0,a0,1172 # 800082c0 <states.0+0x78>
    80001e34:	00004097          	auipc	ra,0x4
    80001e38:	062080e7          	jalr	98(ra) # 80005e96 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e3c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e40:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e44:	00006517          	auipc	a0,0x6
    80001e48:	4ac50513          	addi	a0,a0,1196 # 800082f0 <states.0+0xa8>
    80001e4c:	00004097          	auipc	ra,0x4
    80001e50:	04a080e7          	jalr	74(ra) # 80005e96 <printf>
    setkilled(p);
    80001e54:	8526                	mv	a0,s1
    80001e56:	00000097          	auipc	ra,0x0
    80001e5a:	92a080e7          	jalr	-1750(ra) # 80001780 <setkilled>
    80001e5e:	bf71                	j	80001dfa <usertrap+0x8e>
  if(killed(p))
    80001e60:	4901                	li	s2,0
    exit(-1);
    80001e62:	557d                	li	a0,-1
    80001e64:	fffff097          	auipc	ra,0xfffff
    80001e68:	7d4080e7          	jalr	2004(ra) # 80001638 <exit>
  if(which_dev == 2)
    80001e6c:	4789                	li	a5,2
    80001e6e:	f8f91ce3          	bne	s2,a5,80001e06 <usertrap+0x9a>
    if(p->alarm_ticks >0){
    80001e72:	1684a703          	lw	a4,360(s1)
    80001e76:	00e05e63          	blez	a4,80001e92 <usertrap+0x126>
    p->now_ticks++;
    80001e7a:	16c4a783          	lw	a5,364(s1)
    80001e7e:	2785                	addiw	a5,a5,1
    80001e80:	0007869b          	sext.w	a3,a5
    80001e84:	16f4a623          	sw	a5,364(s1)
    if(p->handler_executing==0 && p->now_ticks > p->alarm_ticks){
    80001e88:	1804a783          	lw	a5,384(s1)
    80001e8c:	e399                	bnez	a5,80001e92 <usertrap+0x126>
    80001e8e:	00d74763          	blt	a4,a3,80001e9c <usertrap+0x130>
      yield();
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	636080e7          	jalr	1590(ra) # 800014c8 <yield>
    80001e9a:	b7b5                	j	80001e06 <usertrap+0x9a>
      p->now_ticks = 0;
    80001e9c:	1604a623          	sw	zero,364(s1)
      p->tick_epc = p->trapframe->epc;
    80001ea0:	6cbc                	ld	a5,88(s1)
    80001ea2:	6f9c                	ld	a5,24(a5)
    80001ea4:	16f4b823          	sd	a5,368(s1)
      store();
    80001ea8:	00000097          	auipc	ra,0x0
    80001eac:	c6a080e7          	jalr	-918(ra) # 80001b12 <store>
      p->handler_executing = 1;
    80001eb0:	4785                	li	a5,1
    80001eb2:	18f4a023          	sw	a5,384(s1)
      p->trapframe->epc = p->alarm_handler;
    80001eb6:	6cbc                	ld	a5,88(s1)
    80001eb8:	1784b703          	ld	a4,376(s1)
    80001ebc:	ef98                	sd	a4,24(a5)
    80001ebe:	bfd1                	j	80001e92 <usertrap+0x126>

0000000080001ec0 <kerneltrap>:
{
    80001ec0:	7179                	addi	sp,sp,-48
    80001ec2:	f406                	sd	ra,40(sp)
    80001ec4:	f022                	sd	s0,32(sp)
    80001ec6:	ec26                	sd	s1,24(sp)
    80001ec8:	e84a                	sd	s2,16(sp)
    80001eca:	e44e                	sd	s3,8(sp)
    80001ecc:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001ece:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ed2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001ed6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001eda:	1004f793          	andi	a5,s1,256
    80001ede:	cb85                	beqz	a5,80001f0e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ee0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ee4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001ee6:	ef85                	bnez	a5,80001f1e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001ee8:	00000097          	auipc	ra,0x0
    80001eec:	de2080e7          	jalr	-542(ra) # 80001cca <devintr>
    80001ef0:	cd1d                	beqz	a0,80001f2e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001ef2:	4789                	li	a5,2
    80001ef4:	06f50a63          	beq	a0,a5,80001f68 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001ef8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001efc:	10049073          	csrw	sstatus,s1
}
    80001f00:	70a2                	ld	ra,40(sp)
    80001f02:	7402                	ld	s0,32(sp)
    80001f04:	64e2                	ld	s1,24(sp)
    80001f06:	6942                	ld	s2,16(sp)
    80001f08:	69a2                	ld	s3,8(sp)
    80001f0a:	6145                	addi	sp,sp,48
    80001f0c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001f0e:	00006517          	auipc	a0,0x6
    80001f12:	40250513          	addi	a0,a0,1026 # 80008310 <states.0+0xc8>
    80001f16:	00004097          	auipc	ra,0x4
    80001f1a:	f36080e7          	jalr	-202(ra) # 80005e4c <panic>
    panic("kerneltrap: interrupts enabled");
    80001f1e:	00006517          	auipc	a0,0x6
    80001f22:	41a50513          	addi	a0,a0,1050 # 80008338 <states.0+0xf0>
    80001f26:	00004097          	auipc	ra,0x4
    80001f2a:	f26080e7          	jalr	-218(ra) # 80005e4c <panic>
    printf("scause %p\n", scause);
    80001f2e:	85ce                	mv	a1,s3
    80001f30:	00006517          	auipc	a0,0x6
    80001f34:	42850513          	addi	a0,a0,1064 # 80008358 <states.0+0x110>
    80001f38:	00004097          	auipc	ra,0x4
    80001f3c:	f5e080e7          	jalr	-162(ra) # 80005e96 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001f40:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001f44:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001f48:	00006517          	auipc	a0,0x6
    80001f4c:	42050513          	addi	a0,a0,1056 # 80008368 <states.0+0x120>
    80001f50:	00004097          	auipc	ra,0x4
    80001f54:	f46080e7          	jalr	-186(ra) # 80005e96 <printf>
    panic("kerneltrap");
    80001f58:	00006517          	auipc	a0,0x6
    80001f5c:	42850513          	addi	a0,a0,1064 # 80008380 <states.0+0x138>
    80001f60:	00004097          	auipc	ra,0x4
    80001f64:	eec080e7          	jalr	-276(ra) # 80005e4c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001f68:	fffff097          	auipc	ra,0xfffff
    80001f6c:	eec080e7          	jalr	-276(ra) # 80000e54 <myproc>
    80001f70:	d541                	beqz	a0,80001ef8 <kerneltrap+0x38>
    80001f72:	fffff097          	auipc	ra,0xfffff
    80001f76:	ee2080e7          	jalr	-286(ra) # 80000e54 <myproc>
    80001f7a:	4d18                	lw	a4,24(a0)
    80001f7c:	4791                	li	a5,4
    80001f7e:	f6f71de3          	bne	a4,a5,80001ef8 <kerneltrap+0x38>
    yield();
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	546080e7          	jalr	1350(ra) # 800014c8 <yield>
    80001f8a:	b7bd                	j	80001ef8 <kerneltrap+0x38>

0000000080001f8c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001f8c:	1101                	addi	sp,sp,-32
    80001f8e:	ec06                	sd	ra,24(sp)
    80001f90:	e822                	sd	s0,16(sp)
    80001f92:	e426                	sd	s1,8(sp)
    80001f94:	1000                	addi	s0,sp,32
    80001f96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	ebc080e7          	jalr	-324(ra) # 80000e54 <myproc>
  switch (n) {
    80001fa0:	4795                	li	a5,5
    80001fa2:	0497e163          	bltu	a5,s1,80001fe4 <argraw+0x58>
    80001fa6:	048a                	slli	s1,s1,0x2
    80001fa8:	00006717          	auipc	a4,0x6
    80001fac:	41070713          	addi	a4,a4,1040 # 800083b8 <states.0+0x170>
    80001fb0:	94ba                	add	s1,s1,a4
    80001fb2:	409c                	lw	a5,0(s1)
    80001fb4:	97ba                	add	a5,a5,a4
    80001fb6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001fb8:	6d3c                	ld	a5,88(a0)
    80001fba:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001fbc:	60e2                	ld	ra,24(sp)
    80001fbe:	6442                	ld	s0,16(sp)
    80001fc0:	64a2                	ld	s1,8(sp)
    80001fc2:	6105                	addi	sp,sp,32
    80001fc4:	8082                	ret
    return p->trapframe->a1;
    80001fc6:	6d3c                	ld	a5,88(a0)
    80001fc8:	7fa8                	ld	a0,120(a5)
    80001fca:	bfcd                	j	80001fbc <argraw+0x30>
    return p->trapframe->a2;
    80001fcc:	6d3c                	ld	a5,88(a0)
    80001fce:	63c8                	ld	a0,128(a5)
    80001fd0:	b7f5                	j	80001fbc <argraw+0x30>
    return p->trapframe->a3;
    80001fd2:	6d3c                	ld	a5,88(a0)
    80001fd4:	67c8                	ld	a0,136(a5)
    80001fd6:	b7dd                	j	80001fbc <argraw+0x30>
    return p->trapframe->a4;
    80001fd8:	6d3c                	ld	a5,88(a0)
    80001fda:	6bc8                	ld	a0,144(a5)
    80001fdc:	b7c5                	j	80001fbc <argraw+0x30>
    return p->trapframe->a5;
    80001fde:	6d3c                	ld	a5,88(a0)
    80001fe0:	6fc8                	ld	a0,152(a5)
    80001fe2:	bfe9                	j	80001fbc <argraw+0x30>
  panic("argraw");
    80001fe4:	00006517          	auipc	a0,0x6
    80001fe8:	3ac50513          	addi	a0,a0,940 # 80008390 <states.0+0x148>
    80001fec:	00004097          	auipc	ra,0x4
    80001ff0:	e60080e7          	jalr	-416(ra) # 80005e4c <panic>

0000000080001ff4 <fetchaddr>:
{
    80001ff4:	1101                	addi	sp,sp,-32
    80001ff6:	ec06                	sd	ra,24(sp)
    80001ff8:	e822                	sd	s0,16(sp)
    80001ffa:	e426                	sd	s1,8(sp)
    80001ffc:	e04a                	sd	s2,0(sp)
    80001ffe:	1000                	addi	s0,sp,32
    80002000:	84aa                	mv	s1,a0
    80002002:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	e50080e7          	jalr	-432(ra) # 80000e54 <myproc>
  if(addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000200c:	653c                	ld	a5,72(a0)
    8000200e:	02f4f863          	bgeu	s1,a5,8000203e <fetchaddr+0x4a>
    80002012:	00848713          	addi	a4,s1,8
    80002016:	02e7e663          	bltu	a5,a4,80002042 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000201a:	46a1                	li	a3,8
    8000201c:	8626                	mv	a2,s1
    8000201e:	85ca                	mv	a1,s2
    80002020:	6928                	ld	a0,80(a0)
    80002022:	fffff097          	auipc	ra,0xfffff
    80002026:	b7e080e7          	jalr	-1154(ra) # 80000ba0 <copyin>
    8000202a:	00a03533          	snez	a0,a0
    8000202e:	40a00533          	neg	a0,a0
}
    80002032:	60e2                	ld	ra,24(sp)
    80002034:	6442                	ld	s0,16(sp)
    80002036:	64a2                	ld	s1,8(sp)
    80002038:	6902                	ld	s2,0(sp)
    8000203a:	6105                	addi	sp,sp,32
    8000203c:	8082                	ret
    return -1;
    8000203e:	557d                	li	a0,-1
    80002040:	bfcd                	j	80002032 <fetchaddr+0x3e>
    80002042:	557d                	li	a0,-1
    80002044:	b7fd                	j	80002032 <fetchaddr+0x3e>

0000000080002046 <fetchstr>:
{
    80002046:	7179                	addi	sp,sp,-48
    80002048:	f406                	sd	ra,40(sp)
    8000204a:	f022                	sd	s0,32(sp)
    8000204c:	ec26                	sd	s1,24(sp)
    8000204e:	e84a                	sd	s2,16(sp)
    80002050:	e44e                	sd	s3,8(sp)
    80002052:	1800                	addi	s0,sp,48
    80002054:	892a                	mv	s2,a0
    80002056:	84ae                	mv	s1,a1
    80002058:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    8000205a:	fffff097          	auipc	ra,0xfffff
    8000205e:	dfa080e7          	jalr	-518(ra) # 80000e54 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002062:	86ce                	mv	a3,s3
    80002064:	864a                	mv	a2,s2
    80002066:	85a6                	mv	a1,s1
    80002068:	6928                	ld	a0,80(a0)
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	bc4080e7          	jalr	-1084(ra) # 80000c2e <copyinstr>
    80002072:	00054e63          	bltz	a0,8000208e <fetchstr+0x48>
  return strlen(buf);
    80002076:	8526                	mv	a0,s1
    80002078:	ffffe097          	auipc	ra,0xffffe
    8000207c:	27e080e7          	jalr	638(ra) # 800002f6 <strlen>
}
    80002080:	70a2                	ld	ra,40(sp)
    80002082:	7402                	ld	s0,32(sp)
    80002084:	64e2                	ld	s1,24(sp)
    80002086:	6942                	ld	s2,16(sp)
    80002088:	69a2                	ld	s3,8(sp)
    8000208a:	6145                	addi	sp,sp,48
    8000208c:	8082                	ret
    return -1;
    8000208e:	557d                	li	a0,-1
    80002090:	bfc5                	j	80002080 <fetchstr+0x3a>

0000000080002092 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002092:	1101                	addi	sp,sp,-32
    80002094:	ec06                	sd	ra,24(sp)
    80002096:	e822                	sd	s0,16(sp)
    80002098:	e426                	sd	s1,8(sp)
    8000209a:	1000                	addi	s0,sp,32
    8000209c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000209e:	00000097          	auipc	ra,0x0
    800020a2:	eee080e7          	jalr	-274(ra) # 80001f8c <argraw>
    800020a6:	c088                	sw	a0,0(s1)
}
    800020a8:	60e2                	ld	ra,24(sp)
    800020aa:	6442                	ld	s0,16(sp)
    800020ac:	64a2                	ld	s1,8(sp)
    800020ae:	6105                	addi	sp,sp,32
    800020b0:	8082                	ret

00000000800020b2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800020b2:	1101                	addi	sp,sp,-32
    800020b4:	ec06                	sd	ra,24(sp)
    800020b6:	e822                	sd	s0,16(sp)
    800020b8:	e426                	sd	s1,8(sp)
    800020ba:	1000                	addi	s0,sp,32
    800020bc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800020be:	00000097          	auipc	ra,0x0
    800020c2:	ece080e7          	jalr	-306(ra) # 80001f8c <argraw>
    800020c6:	e088                	sd	a0,0(s1)
}
    800020c8:	60e2                	ld	ra,24(sp)
    800020ca:	6442                	ld	s0,16(sp)
    800020cc:	64a2                	ld	s1,8(sp)
    800020ce:	6105                	addi	sp,sp,32
    800020d0:	8082                	ret

00000000800020d2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800020d2:	7179                	addi	sp,sp,-48
    800020d4:	f406                	sd	ra,40(sp)
    800020d6:	f022                	sd	s0,32(sp)
    800020d8:	ec26                	sd	s1,24(sp)
    800020da:	e84a                	sd	s2,16(sp)
    800020dc:	1800                	addi	s0,sp,48
    800020de:	84ae                	mv	s1,a1
    800020e0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    800020e2:	fd840593          	addi	a1,s0,-40
    800020e6:	00000097          	auipc	ra,0x0
    800020ea:	fcc080e7          	jalr	-52(ra) # 800020b2 <argaddr>
  return fetchstr(addr, buf, max);
    800020ee:	864a                	mv	a2,s2
    800020f0:	85a6                	mv	a1,s1
    800020f2:	fd843503          	ld	a0,-40(s0)
    800020f6:	00000097          	auipc	ra,0x0
    800020fa:	f50080e7          	jalr	-176(ra) # 80002046 <fetchstr>
}
    800020fe:	70a2                	ld	ra,40(sp)
    80002100:	7402                	ld	s0,32(sp)
    80002102:	64e2                	ld	s1,24(sp)
    80002104:	6942                	ld	s2,16(sp)
    80002106:	6145                	addi	sp,sp,48
    80002108:	8082                	ret

000000008000210a <syscall>:

};

void
syscall(void)
{
    8000210a:	1101                	addi	sp,sp,-32
    8000210c:	ec06                	sd	ra,24(sp)
    8000210e:	e822                	sd	s0,16(sp)
    80002110:	e426                	sd	s1,8(sp)
    80002112:	e04a                	sd	s2,0(sp)
    80002114:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	d3e080e7          	jalr	-706(ra) # 80000e54 <myproc>
    8000211e:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002120:	05853903          	ld	s2,88(a0)
    80002124:	0a893783          	ld	a5,168(s2)
    80002128:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    8000212c:	37fd                	addiw	a5,a5,-1
    8000212e:	475d                	li	a4,23
    80002130:	00f76f63          	bltu	a4,a5,8000214e <syscall+0x44>
    80002134:	00369713          	slli	a4,a3,0x3
    80002138:	00006797          	auipc	a5,0x6
    8000213c:	29878793          	addi	a5,a5,664 # 800083d0 <syscalls>
    80002140:	97ba                	add	a5,a5,a4
    80002142:	639c                	ld	a5,0(a5)
    80002144:	c789                	beqz	a5,8000214e <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002146:	9782                	jalr	a5
    80002148:	06a93823          	sd	a0,112(s2)
    8000214c:	a839                	j	8000216a <syscall+0x60>
  } 
  else {
    printf("%d %s: unknown sys call %d\n",
    8000214e:	15848613          	addi	a2,s1,344
    80002152:	588c                	lw	a1,48(s1)
    80002154:	00006517          	auipc	a0,0x6
    80002158:	24450513          	addi	a0,a0,580 # 80008398 <states.0+0x150>
    8000215c:	00004097          	auipc	ra,0x4
    80002160:	d3a080e7          	jalr	-710(ra) # 80005e96 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002164:	6cbc                	ld	a5,88(s1)
    80002166:	577d                	li	a4,-1
    80002168:	fbb8                	sd	a4,112(a5)
  }
}
    8000216a:	60e2                	ld	ra,24(sp)
    8000216c:	6442                	ld	s0,16(sp)
    8000216e:	64a2                	ld	s1,8(sp)
    80002170:	6902                	ld	s2,0(sp)
    80002172:	6105                	addi	sp,sp,32
    80002174:	8082                	ret

0000000080002176 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002176:	1101                	addi	sp,sp,-32
    80002178:	ec06                	sd	ra,24(sp)
    8000217a:	e822                	sd	s0,16(sp)
    8000217c:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    8000217e:	fec40593          	addi	a1,s0,-20
    80002182:	4501                	li	a0,0
    80002184:	00000097          	auipc	ra,0x0
    80002188:	f0e080e7          	jalr	-242(ra) # 80002092 <argint>
  exit(n);
    8000218c:	fec42503          	lw	a0,-20(s0)
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	4a8080e7          	jalr	1192(ra) # 80001638 <exit>
  return 0;  // not reached
}
    80002198:	4501                	li	a0,0
    8000219a:	60e2                	ld	ra,24(sp)
    8000219c:	6442                	ld	s0,16(sp)
    8000219e:	6105                	addi	sp,sp,32
    800021a0:	8082                	ret

00000000800021a2 <sys_getpid>:

uint64
sys_getpid(void)
{
    800021a2:	1141                	addi	sp,sp,-16
    800021a4:	e406                	sd	ra,8(sp)
    800021a6:	e022                	sd	s0,0(sp)
    800021a8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800021aa:	fffff097          	auipc	ra,0xfffff
    800021ae:	caa080e7          	jalr	-854(ra) # 80000e54 <myproc>
}
    800021b2:	5908                	lw	a0,48(a0)
    800021b4:	60a2                	ld	ra,8(sp)
    800021b6:	6402                	ld	s0,0(sp)
    800021b8:	0141                	addi	sp,sp,16
    800021ba:	8082                	ret

00000000800021bc <sys_fork>:

uint64
sys_fork(void)
{
    800021bc:	1141                	addi	sp,sp,-16
    800021be:	e406                	sd	ra,8(sp)
    800021c0:	e022                	sd	s0,0(sp)
    800021c2:	0800                	addi	s0,sp,16
  return fork();
    800021c4:	fffff097          	auipc	ra,0xfffff
    800021c8:	04e080e7          	jalr	78(ra) # 80001212 <fork>
}
    800021cc:	60a2                	ld	ra,8(sp)
    800021ce:	6402                	ld	s0,0(sp)
    800021d0:	0141                	addi	sp,sp,16
    800021d2:	8082                	ret

00000000800021d4 <sys_wait>:

uint64
sys_wait(void)
{
    800021d4:	1101                	addi	sp,sp,-32
    800021d6:	ec06                	sd	ra,24(sp)
    800021d8:	e822                	sd	s0,16(sp)
    800021da:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800021dc:	fe840593          	addi	a1,s0,-24
    800021e0:	4501                	li	a0,0
    800021e2:	00000097          	auipc	ra,0x0
    800021e6:	ed0080e7          	jalr	-304(ra) # 800020b2 <argaddr>
  return wait(p);
    800021ea:	fe843503          	ld	a0,-24(s0)
    800021ee:	fffff097          	auipc	ra,0xfffff
    800021f2:	5f0080e7          	jalr	1520(ra) # 800017de <wait>
}
    800021f6:	60e2                	ld	ra,24(sp)
    800021f8:	6442                	ld	s0,16(sp)
    800021fa:	6105                	addi	sp,sp,32
    800021fc:	8082                	ret

00000000800021fe <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800021fe:	7179                	addi	sp,sp,-48
    80002200:	f406                	sd	ra,40(sp)
    80002202:	f022                	sd	s0,32(sp)
    80002204:	ec26                	sd	s1,24(sp)
    80002206:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002208:	fdc40593          	addi	a1,s0,-36
    8000220c:	4501                	li	a0,0
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	e84080e7          	jalr	-380(ra) # 80002092 <argint>
  addr = myproc()->sz;
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	c3e080e7          	jalr	-962(ra) # 80000e54 <myproc>
    8000221e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002220:	fdc42503          	lw	a0,-36(s0)
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	f92080e7          	jalr	-110(ra) # 800011b6 <growproc>
    8000222c:	00054863          	bltz	a0,8000223c <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002230:	8526                	mv	a0,s1
    80002232:	70a2                	ld	ra,40(sp)
    80002234:	7402                	ld	s0,32(sp)
    80002236:	64e2                	ld	s1,24(sp)
    80002238:	6145                	addi	sp,sp,48
    8000223a:	8082                	ret
    return -1;
    8000223c:	54fd                	li	s1,-1
    8000223e:	bfcd                	j	80002230 <sys_sbrk+0x32>

0000000080002240 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002240:	7139                	addi	sp,sp,-64
    80002242:	fc06                	sd	ra,56(sp)
    80002244:	f822                	sd	s0,48(sp)
    80002246:	f426                	sd	s1,40(sp)
    80002248:	f04a                	sd	s2,32(sp)
    8000224a:	ec4e                	sd	s3,24(sp)
    8000224c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000224e:	fcc40593          	addi	a1,s0,-52
    80002252:	4501                	li	a0,0
    80002254:	00000097          	auipc	ra,0x0
    80002258:	e3e080e7          	jalr	-450(ra) # 80002092 <argint>
  if(n < 0)
    8000225c:	fcc42783          	lw	a5,-52(s0)
    80002260:	0607cf63          	bltz	a5,800022de <sys_sleep+0x9e>
    n = 0;
  acquire(&tickslock);
    80002264:	00011517          	auipc	a0,0x11
    80002268:	aec50513          	addi	a0,a0,-1300 # 80012d50 <tickslock>
    8000226c:	00004097          	auipc	ra,0x4
    80002270:	118080e7          	jalr	280(ra) # 80006384 <acquire>
  ticks0 = ticks;
    80002274:	00006917          	auipc	s2,0x6
    80002278:	67492903          	lw	s2,1652(s2) # 800088e8 <ticks>
  while(ticks - ticks0 < n){
    8000227c:	fcc42783          	lw	a5,-52(s0)
    80002280:	cf9d                	beqz	a5,800022be <sys_sleep+0x7e>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002282:	00011997          	auipc	s3,0x11
    80002286:	ace98993          	addi	s3,s3,-1330 # 80012d50 <tickslock>
    8000228a:	00006497          	auipc	s1,0x6
    8000228e:	65e48493          	addi	s1,s1,1630 # 800088e8 <ticks>
    if(killed(myproc())){
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	bc2080e7          	jalr	-1086(ra) # 80000e54 <myproc>
    8000229a:	fffff097          	auipc	ra,0xfffff
    8000229e:	512080e7          	jalr	1298(ra) # 800017ac <killed>
    800022a2:	e129                	bnez	a0,800022e4 <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    800022a4:	85ce                	mv	a1,s3
    800022a6:	8526                	mv	a0,s1
    800022a8:	fffff097          	auipc	ra,0xfffff
    800022ac:	25c080e7          	jalr	604(ra) # 80001504 <sleep>
  while(ticks - ticks0 < n){
    800022b0:	409c                	lw	a5,0(s1)
    800022b2:	412787bb          	subw	a5,a5,s2
    800022b6:	fcc42703          	lw	a4,-52(s0)
    800022ba:	fce7ece3          	bltu	a5,a4,80002292 <sys_sleep+0x52>
  }
  release(&tickslock);
    800022be:	00011517          	auipc	a0,0x11
    800022c2:	a9250513          	addi	a0,a0,-1390 # 80012d50 <tickslock>
    800022c6:	00004097          	auipc	ra,0x4
    800022ca:	172080e7          	jalr	370(ra) # 80006438 <release>
  return 0;
    800022ce:	4501                	li	a0,0
}
    800022d0:	70e2                	ld	ra,56(sp)
    800022d2:	7442                	ld	s0,48(sp)
    800022d4:	74a2                	ld	s1,40(sp)
    800022d6:	7902                	ld	s2,32(sp)
    800022d8:	69e2                	ld	s3,24(sp)
    800022da:	6121                	addi	sp,sp,64
    800022dc:	8082                	ret
    n = 0;
    800022de:	fc042623          	sw	zero,-52(s0)
    800022e2:	b749                	j	80002264 <sys_sleep+0x24>
      release(&tickslock);
    800022e4:	00011517          	auipc	a0,0x11
    800022e8:	a6c50513          	addi	a0,a0,-1428 # 80012d50 <tickslock>
    800022ec:	00004097          	auipc	ra,0x4
    800022f0:	14c080e7          	jalr	332(ra) # 80006438 <release>
      return -1;
    800022f4:	557d                	li	a0,-1
    800022f6:	bfe9                	j	800022d0 <sys_sleep+0x90>

00000000800022f8 <sys_kill>:

uint64
sys_kill(void)
{
    800022f8:	1101                	addi	sp,sp,-32
    800022fa:	ec06                	sd	ra,24(sp)
    800022fc:	e822                	sd	s0,16(sp)
    800022fe:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002300:	fec40593          	addi	a1,s0,-20
    80002304:	4501                	li	a0,0
    80002306:	00000097          	auipc	ra,0x0
    8000230a:	d8c080e7          	jalr	-628(ra) # 80002092 <argint>
  return kill(pid);
    8000230e:	fec42503          	lw	a0,-20(s0)
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	3fc080e7          	jalr	1020(ra) # 8000170e <kill>
}
    8000231a:	60e2                	ld	ra,24(sp)
    8000231c:	6442                	ld	s0,16(sp)
    8000231e:	6105                	addi	sp,sp,32
    80002320:	8082                	ret

0000000080002322 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002322:	1101                	addi	sp,sp,-32
    80002324:	ec06                	sd	ra,24(sp)
    80002326:	e822                	sd	s0,16(sp)
    80002328:	e426                	sd	s1,8(sp)
    8000232a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000232c:	00011517          	auipc	a0,0x11
    80002330:	a2450513          	addi	a0,a0,-1500 # 80012d50 <tickslock>
    80002334:	00004097          	auipc	ra,0x4
    80002338:	050080e7          	jalr	80(ra) # 80006384 <acquire>
  xticks = ticks;
    8000233c:	00006497          	auipc	s1,0x6
    80002340:	5ac4a483          	lw	s1,1452(s1) # 800088e8 <ticks>
  release(&tickslock);
    80002344:	00011517          	auipc	a0,0x11
    80002348:	a0c50513          	addi	a0,a0,-1524 # 80012d50 <tickslock>
    8000234c:	00004097          	auipc	ra,0x4
    80002350:	0ec080e7          	jalr	236(ra) # 80006438 <release>
  return xticks;
}
    80002354:	02049513          	slli	a0,s1,0x20
    80002358:	9101                	srli	a0,a0,0x20
    8000235a:	60e2                	ld	ra,24(sp)
    8000235c:	6442                	ld	s0,16(sp)
    8000235e:	64a2                	ld	s1,8(sp)
    80002360:	6105                	addi	sp,sp,32
    80002362:	8082                	ret

0000000080002364 <sys_sigalarm>:


uint64 sys_sigalarm(void){
    80002364:	1101                	addi	sp,sp,-32
    80002366:	ec06                	sd	ra,24(sp)
    80002368:	e822                	sd	s0,16(sp)
    8000236a:	1000                	addi	s0,sp,32
    int ticks;
    uint64 handler;

    argint(0, &ticks);
    8000236c:	fec40593          	addi	a1,s0,-20
    80002370:	4501                	li	a0,0
    80002372:	00000097          	auipc	ra,0x0
    80002376:	d20080e7          	jalr	-736(ra) # 80002092 <argint>

    
    argaddr(1, &handler);
    8000237a:	fe040593          	addi	a1,s0,-32
    8000237e:	4505                	li	a0,1
    80002380:	00000097          	auipc	ra,0x0
    80002384:	d32080e7          	jalr	-718(ra) # 800020b2 <argaddr>


    struct proc *p = myproc();
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	acc080e7          	jalr	-1332(ra) # 80000e54 <myproc>
    p->alarm_ticks = ticks;
    80002390:	fec42783          	lw	a5,-20(s0)
    80002394:	16f52423          	sw	a5,360(a0)
    p->alarm_handler = handler;
    80002398:	fe043783          	ld	a5,-32(s0)
    8000239c:	16f53c23          	sd	a5,376(a0)
    p->now_ticks = 0;
    800023a0:	16052623          	sw	zero,364(a0)

    return 0;
}
    800023a4:	4501                	li	a0,0
    800023a6:	60e2                	ld	ra,24(sp)
    800023a8:	6442                	ld	s0,16(sp)
    800023aa:	6105                	addi	sp,sp,32
    800023ac:	8082                	ret

00000000800023ae <restore>:

void restore()
{
    800023ae:	1141                	addi	sp,sp,-16
    800023b0:	e406                	sd	ra,8(sp)
    800023b2:	e022                	sd	s0,0(sp)
    800023b4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	a9e080e7          	jalr	-1378(ra) # 80000e54 <myproc>
  p->trapframe->ra = p->tick_ra;
    800023be:	6d3c                	ld	a5,88(a0)
    800023c0:	18853703          	ld	a4,392(a0)
    800023c4:	f798                	sd	a4,40(a5)
  p->trapframe->sp = p->tick_sp;
    800023c6:	6d3c                	ld	a5,88(a0)
    800023c8:	19053703          	ld	a4,400(a0)
    800023cc:	fb98                	sd	a4,48(a5)
  p->trapframe->gp = p->tick_gp;
    800023ce:	6d3c                	ld	a5,88(a0)
    800023d0:	19853703          	ld	a4,408(a0)
    800023d4:	ff98                	sd	a4,56(a5)
  p->trapframe->tp = p->tick_tp;
    800023d6:	6d3c                	ld	a5,88(a0)
    800023d8:	1a053703          	ld	a4,416(a0)
    800023dc:	e3b8                	sd	a4,64(a5)
  p->trapframe->t0 = p->tick_t0;
    800023de:	6d3c                	ld	a5,88(a0)
    800023e0:	1a853703          	ld	a4,424(a0)
    800023e4:	e7b8                	sd	a4,72(a5)
  p->trapframe->t1 = p->tick_t1;
    800023e6:	6d3c                	ld	a5,88(a0)
    800023e8:	1b053703          	ld	a4,432(a0)
    800023ec:	ebb8                	sd	a4,80(a5)
  p->trapframe->t2 = p->tick_t2;
    800023ee:	6d3c                	ld	a5,88(a0)
    800023f0:	1b853703          	ld	a4,440(a0)
    800023f4:	efb8                	sd	a4,88(a5)
  p->trapframe->s0 = p->tick_s0;
    800023f6:	6d3c                	ld	a5,88(a0)
    800023f8:	1c053703          	ld	a4,448(a0)
    800023fc:	f3b8                	sd	a4,96(a5)
  p->trapframe->s1 = p->tick_s1;
    800023fe:	6d3c                	ld	a5,88(a0)
    80002400:	1c853703          	ld	a4,456(a0)
    80002404:	f7b8                	sd	a4,104(a5)
  p->trapframe->a0 = p->tick_a0;
    80002406:	6d3c                	ld	a5,88(a0)
    80002408:	1d053703          	ld	a4,464(a0)
    8000240c:	fbb8                	sd	a4,112(a5)
  p->trapframe->a1 = p->tick_a1;
    8000240e:	6d3c                	ld	a5,88(a0)
    80002410:	1d853703          	ld	a4,472(a0)
    80002414:	ffb8                	sd	a4,120(a5)
  p->trapframe->a2 = p->tick_a2;
    80002416:	6d3c                	ld	a5,88(a0)
    80002418:	1e053703          	ld	a4,480(a0)
    8000241c:	e3d8                	sd	a4,128(a5)
  p->trapframe->a3 = p->tick_a3;
    8000241e:	6d3c                	ld	a5,88(a0)
    80002420:	1e853703          	ld	a4,488(a0)
    80002424:	e7d8                	sd	a4,136(a5)
  p->trapframe->a4 = p->tick_a4;
    80002426:	6d3c                	ld	a5,88(a0)
    80002428:	1f053703          	ld	a4,496(a0)
    8000242c:	ebd8                	sd	a4,144(a5)
  p->trapframe->a5 = p->tick_a5;
    8000242e:	6d3c                	ld	a5,88(a0)
    80002430:	1f853703          	ld	a4,504(a0)
    80002434:	efd8                	sd	a4,152(a5)
  p->trapframe->a6 = p->tick_a6;
    80002436:	6d3c                	ld	a5,88(a0)
    80002438:	20053703          	ld	a4,512(a0)
    8000243c:	f3d8                	sd	a4,160(a5)
  p->trapframe->a7 = p->tick_a7;
    8000243e:	6d3c                	ld	a5,88(a0)
    80002440:	20853703          	ld	a4,520(a0)
    80002444:	f7d8                	sd	a4,168(a5)
  p->trapframe->s2 = p->tick_s2;
    80002446:	6d3c                	ld	a5,88(a0)
    80002448:	21053703          	ld	a4,528(a0)
    8000244c:	fbd8                	sd	a4,176(a5)
  p->trapframe->s3 = p->tick_s3;
    8000244e:	6d3c                	ld	a5,88(a0)
    80002450:	21853703          	ld	a4,536(a0)
    80002454:	ffd8                	sd	a4,184(a5)
  p->trapframe->s4 = p->tick_s4;
    80002456:	6d3c                	ld	a5,88(a0)
    80002458:	22053703          	ld	a4,544(a0)
    8000245c:	e3f8                	sd	a4,192(a5)
  p->trapframe->s5 = p->tick_s5;
    8000245e:	6d3c                	ld	a5,88(a0)
    80002460:	22853703          	ld	a4,552(a0)
    80002464:	e7f8                	sd	a4,200(a5)
  p->trapframe->s6 = p->tick_s6;
    80002466:	6d3c                	ld	a5,88(a0)
    80002468:	23053703          	ld	a4,560(a0)
    8000246c:	ebf8                	sd	a4,208(a5)
  p->trapframe->s7 = p->tick_s7;
    8000246e:	6d3c                	ld	a5,88(a0)
    80002470:	23853703          	ld	a4,568(a0)
    80002474:	eff8                	sd	a4,216(a5)
  p->trapframe->s8 = p->tick_s8;
    80002476:	6d3c                	ld	a5,88(a0)
    80002478:	24053703          	ld	a4,576(a0)
    8000247c:	f3f8                	sd	a4,224(a5)
  p->trapframe->s9 = p->tick_s9;
    8000247e:	6d3c                	ld	a5,88(a0)
    80002480:	24853703          	ld	a4,584(a0)
    80002484:	f7f8                	sd	a4,232(a5)
  p->trapframe->s10 = p->tick_s10;
    80002486:	6d3c                	ld	a5,88(a0)
    80002488:	25053703          	ld	a4,592(a0)
    8000248c:	fbf8                	sd	a4,240(a5)
  p->trapframe->s11 = p->tick_s11;
    8000248e:	6d3c                	ld	a5,88(a0)
    80002490:	25853703          	ld	a4,600(a0)
    80002494:	fff8                	sd	a4,248(a5)
  p->trapframe->t3 = p->tick_t3;
    80002496:	6d3c                	ld	a5,88(a0)
    80002498:	26053703          	ld	a4,608(a0)
    8000249c:	10e7b023          	sd	a4,256(a5)
  p->trapframe->t4 = p->tick_t4;
    800024a0:	6d3c                	ld	a5,88(a0)
    800024a2:	26853703          	ld	a4,616(a0)
    800024a6:	10e7b423          	sd	a4,264(a5)
  p->trapframe->t5 = p->tick_t5;
    800024aa:	6d3c                	ld	a5,88(a0)
    800024ac:	27053703          	ld	a4,624(a0)
    800024b0:	10e7b823          	sd	a4,272(a5)
  p->trapframe->t6 = p->tick_t6;
    800024b4:	6d3c                	ld	a5,88(a0)
    800024b6:	27853703          	ld	a4,632(a0)
    800024ba:	10e7bc23          	sd	a4,280(a5)
}
    800024be:	60a2                	ld	ra,8(sp)
    800024c0:	6402                	ld	s0,0(sp)
    800024c2:	0141                	addi	sp,sp,16
    800024c4:	8082                	ret

00000000800024c6 <sys_sigreturn>:

uint64 sys_sigreturn(void){
    800024c6:	1101                	addi	sp,sp,-32
    800024c8:	ec06                	sd	ra,24(sp)
    800024ca:	e822                	sd	s0,16(sp)
    800024cc:	e426                	sd	s1,8(sp)
    800024ce:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800024d0:	fffff097          	auipc	ra,0xfffff
    800024d4:	984080e7          	jalr	-1660(ra) # 80000e54 <myproc>
    800024d8:	84aa                	mv	s1,a0
  p->trapframe->epc = p->tick_epc;
    800024da:	6d3c                	ld	a5,88(a0)
    800024dc:	17053703          	ld	a4,368(a0)
    800024e0:	ef98                	sd	a4,24(a5)
  restore();
    800024e2:	00000097          	auipc	ra,0x0
    800024e6:	ecc080e7          	jalr	-308(ra) # 800023ae <restore>
  p->handler_executing = 0;
    800024ea:	1804a023          	sw	zero,384(s1)
  return 0;
    800024ee:	4501                	li	a0,0
    800024f0:	60e2                	ld	ra,24(sp)
    800024f2:	6442                	ld	s0,16(sp)
    800024f4:	64a2                	ld	s1,8(sp)
    800024f6:	6105                	addi	sp,sp,32
    800024f8:	8082                	ret

00000000800024fa <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800024fa:	7179                	addi	sp,sp,-48
    800024fc:	f406                	sd	ra,40(sp)
    800024fe:	f022                	sd	s0,32(sp)
    80002500:	ec26                	sd	s1,24(sp)
    80002502:	e84a                	sd	s2,16(sp)
    80002504:	e44e                	sd	s3,8(sp)
    80002506:	e052                	sd	s4,0(sp)
    80002508:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000250a:	00006597          	auipc	a1,0x6
    8000250e:	f8e58593          	addi	a1,a1,-114 # 80008498 <syscalls+0xc8>
    80002512:	00011517          	auipc	a0,0x11
    80002516:	85650513          	addi	a0,a0,-1962 # 80012d68 <bcache>
    8000251a:	00004097          	auipc	ra,0x4
    8000251e:	dda080e7          	jalr	-550(ra) # 800062f4 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002522:	00019797          	auipc	a5,0x19
    80002526:	84678793          	addi	a5,a5,-1978 # 8001ad68 <bcache+0x8000>
    8000252a:	00019717          	auipc	a4,0x19
    8000252e:	aa670713          	addi	a4,a4,-1370 # 8001afd0 <bcache+0x8268>
    80002532:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002536:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000253a:	00011497          	auipc	s1,0x11
    8000253e:	84648493          	addi	s1,s1,-1978 # 80012d80 <bcache+0x18>
    b->next = bcache.head.next;
    80002542:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002544:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002546:	00006a17          	auipc	s4,0x6
    8000254a:	f5aa0a13          	addi	s4,s4,-166 # 800084a0 <syscalls+0xd0>
    b->next = bcache.head.next;
    8000254e:	2b893783          	ld	a5,696(s2)
    80002552:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002554:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002558:	85d2                	mv	a1,s4
    8000255a:	01048513          	addi	a0,s1,16
    8000255e:	00001097          	auipc	ra,0x1
    80002562:	4c8080e7          	jalr	1224(ra) # 80003a26 <initsleeplock>
    bcache.head.next->prev = b;
    80002566:	2b893783          	ld	a5,696(s2)
    8000256a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000256c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002570:	45848493          	addi	s1,s1,1112
    80002574:	fd349de3          	bne	s1,s3,8000254e <binit+0x54>
  }
}
    80002578:	70a2                	ld	ra,40(sp)
    8000257a:	7402                	ld	s0,32(sp)
    8000257c:	64e2                	ld	s1,24(sp)
    8000257e:	6942                	ld	s2,16(sp)
    80002580:	69a2                	ld	s3,8(sp)
    80002582:	6a02                	ld	s4,0(sp)
    80002584:	6145                	addi	sp,sp,48
    80002586:	8082                	ret

0000000080002588 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002588:	7179                	addi	sp,sp,-48
    8000258a:	f406                	sd	ra,40(sp)
    8000258c:	f022                	sd	s0,32(sp)
    8000258e:	ec26                	sd	s1,24(sp)
    80002590:	e84a                	sd	s2,16(sp)
    80002592:	e44e                	sd	s3,8(sp)
    80002594:	1800                	addi	s0,sp,48
    80002596:	892a                	mv	s2,a0
    80002598:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000259a:	00010517          	auipc	a0,0x10
    8000259e:	7ce50513          	addi	a0,a0,1998 # 80012d68 <bcache>
    800025a2:	00004097          	auipc	ra,0x4
    800025a6:	de2080e7          	jalr	-542(ra) # 80006384 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800025aa:	00019497          	auipc	s1,0x19
    800025ae:	a764b483          	ld	s1,-1418(s1) # 8001b020 <bcache+0x82b8>
    800025b2:	00019797          	auipc	a5,0x19
    800025b6:	a1e78793          	addi	a5,a5,-1506 # 8001afd0 <bcache+0x8268>
    800025ba:	02f48f63          	beq	s1,a5,800025f8 <bread+0x70>
    800025be:	873e                	mv	a4,a5
    800025c0:	a021                	j	800025c8 <bread+0x40>
    800025c2:	68a4                	ld	s1,80(s1)
    800025c4:	02e48a63          	beq	s1,a4,800025f8 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800025c8:	449c                	lw	a5,8(s1)
    800025ca:	ff279ce3          	bne	a5,s2,800025c2 <bread+0x3a>
    800025ce:	44dc                	lw	a5,12(s1)
    800025d0:	ff3799e3          	bne	a5,s3,800025c2 <bread+0x3a>
      b->refcnt++;
    800025d4:	40bc                	lw	a5,64(s1)
    800025d6:	2785                	addiw	a5,a5,1
    800025d8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800025da:	00010517          	auipc	a0,0x10
    800025de:	78e50513          	addi	a0,a0,1934 # 80012d68 <bcache>
    800025e2:	00004097          	auipc	ra,0x4
    800025e6:	e56080e7          	jalr	-426(ra) # 80006438 <release>
      acquiresleep(&b->lock);
    800025ea:	01048513          	addi	a0,s1,16
    800025ee:	00001097          	auipc	ra,0x1
    800025f2:	472080e7          	jalr	1138(ra) # 80003a60 <acquiresleep>
      return b;
    800025f6:	a8b9                	j	80002654 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800025f8:	00019497          	auipc	s1,0x19
    800025fc:	a204b483          	ld	s1,-1504(s1) # 8001b018 <bcache+0x82b0>
    80002600:	00019797          	auipc	a5,0x19
    80002604:	9d078793          	addi	a5,a5,-1584 # 8001afd0 <bcache+0x8268>
    80002608:	00f48863          	beq	s1,a5,80002618 <bread+0x90>
    8000260c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000260e:	40bc                	lw	a5,64(s1)
    80002610:	cf81                	beqz	a5,80002628 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002612:	64a4                	ld	s1,72(s1)
    80002614:	fee49de3          	bne	s1,a4,8000260e <bread+0x86>
  panic("bget: no buffers");
    80002618:	00006517          	auipc	a0,0x6
    8000261c:	e9050513          	addi	a0,a0,-368 # 800084a8 <syscalls+0xd8>
    80002620:	00004097          	auipc	ra,0x4
    80002624:	82c080e7          	jalr	-2004(ra) # 80005e4c <panic>
      b->dev = dev;
    80002628:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000262c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002630:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002634:	4785                	li	a5,1
    80002636:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002638:	00010517          	auipc	a0,0x10
    8000263c:	73050513          	addi	a0,a0,1840 # 80012d68 <bcache>
    80002640:	00004097          	auipc	ra,0x4
    80002644:	df8080e7          	jalr	-520(ra) # 80006438 <release>
      acquiresleep(&b->lock);
    80002648:	01048513          	addi	a0,s1,16
    8000264c:	00001097          	auipc	ra,0x1
    80002650:	414080e7          	jalr	1044(ra) # 80003a60 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002654:	409c                	lw	a5,0(s1)
    80002656:	cb89                	beqz	a5,80002668 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002658:	8526                	mv	a0,s1
    8000265a:	70a2                	ld	ra,40(sp)
    8000265c:	7402                	ld	s0,32(sp)
    8000265e:	64e2                	ld	s1,24(sp)
    80002660:	6942                	ld	s2,16(sp)
    80002662:	69a2                	ld	s3,8(sp)
    80002664:	6145                	addi	sp,sp,48
    80002666:	8082                	ret
    virtio_disk_rw(b, 0);
    80002668:	4581                	li	a1,0
    8000266a:	8526                	mv	a0,s1
    8000266c:	00003097          	auipc	ra,0x3
    80002670:	fd6080e7          	jalr	-42(ra) # 80005642 <virtio_disk_rw>
    b->valid = 1;
    80002674:	4785                	li	a5,1
    80002676:	c09c                	sw	a5,0(s1)
  return b;
    80002678:	b7c5                	j	80002658 <bread+0xd0>

000000008000267a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000267a:	1101                	addi	sp,sp,-32
    8000267c:	ec06                	sd	ra,24(sp)
    8000267e:	e822                	sd	s0,16(sp)
    80002680:	e426                	sd	s1,8(sp)
    80002682:	1000                	addi	s0,sp,32
    80002684:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002686:	0541                	addi	a0,a0,16
    80002688:	00001097          	auipc	ra,0x1
    8000268c:	472080e7          	jalr	1138(ra) # 80003afa <holdingsleep>
    80002690:	cd01                	beqz	a0,800026a8 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002692:	4585                	li	a1,1
    80002694:	8526                	mv	a0,s1
    80002696:	00003097          	auipc	ra,0x3
    8000269a:	fac080e7          	jalr	-84(ra) # 80005642 <virtio_disk_rw>
}
    8000269e:	60e2                	ld	ra,24(sp)
    800026a0:	6442                	ld	s0,16(sp)
    800026a2:	64a2                	ld	s1,8(sp)
    800026a4:	6105                	addi	sp,sp,32
    800026a6:	8082                	ret
    panic("bwrite");
    800026a8:	00006517          	auipc	a0,0x6
    800026ac:	e1850513          	addi	a0,a0,-488 # 800084c0 <syscalls+0xf0>
    800026b0:	00003097          	auipc	ra,0x3
    800026b4:	79c080e7          	jalr	1948(ra) # 80005e4c <panic>

00000000800026b8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800026b8:	1101                	addi	sp,sp,-32
    800026ba:	ec06                	sd	ra,24(sp)
    800026bc:	e822                	sd	s0,16(sp)
    800026be:	e426                	sd	s1,8(sp)
    800026c0:	e04a                	sd	s2,0(sp)
    800026c2:	1000                	addi	s0,sp,32
    800026c4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800026c6:	01050913          	addi	s2,a0,16
    800026ca:	854a                	mv	a0,s2
    800026cc:	00001097          	auipc	ra,0x1
    800026d0:	42e080e7          	jalr	1070(ra) # 80003afa <holdingsleep>
    800026d4:	c92d                	beqz	a0,80002746 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800026d6:	854a                	mv	a0,s2
    800026d8:	00001097          	auipc	ra,0x1
    800026dc:	3de080e7          	jalr	990(ra) # 80003ab6 <releasesleep>

  acquire(&bcache.lock);
    800026e0:	00010517          	auipc	a0,0x10
    800026e4:	68850513          	addi	a0,a0,1672 # 80012d68 <bcache>
    800026e8:	00004097          	auipc	ra,0x4
    800026ec:	c9c080e7          	jalr	-868(ra) # 80006384 <acquire>
  b->refcnt--;
    800026f0:	40bc                	lw	a5,64(s1)
    800026f2:	37fd                	addiw	a5,a5,-1
    800026f4:	0007871b          	sext.w	a4,a5
    800026f8:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800026fa:	eb05                	bnez	a4,8000272a <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800026fc:	68bc                	ld	a5,80(s1)
    800026fe:	64b8                	ld	a4,72(s1)
    80002700:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002702:	64bc                	ld	a5,72(s1)
    80002704:	68b8                	ld	a4,80(s1)
    80002706:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002708:	00018797          	auipc	a5,0x18
    8000270c:	66078793          	addi	a5,a5,1632 # 8001ad68 <bcache+0x8000>
    80002710:	2b87b703          	ld	a4,696(a5)
    80002714:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002716:	00019717          	auipc	a4,0x19
    8000271a:	8ba70713          	addi	a4,a4,-1862 # 8001afd0 <bcache+0x8268>
    8000271e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002720:	2b87b703          	ld	a4,696(a5)
    80002724:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002726:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000272a:	00010517          	auipc	a0,0x10
    8000272e:	63e50513          	addi	a0,a0,1598 # 80012d68 <bcache>
    80002732:	00004097          	auipc	ra,0x4
    80002736:	d06080e7          	jalr	-762(ra) # 80006438 <release>
}
    8000273a:	60e2                	ld	ra,24(sp)
    8000273c:	6442                	ld	s0,16(sp)
    8000273e:	64a2                	ld	s1,8(sp)
    80002740:	6902                	ld	s2,0(sp)
    80002742:	6105                	addi	sp,sp,32
    80002744:	8082                	ret
    panic("brelse");
    80002746:	00006517          	auipc	a0,0x6
    8000274a:	d8250513          	addi	a0,a0,-638 # 800084c8 <syscalls+0xf8>
    8000274e:	00003097          	auipc	ra,0x3
    80002752:	6fe080e7          	jalr	1790(ra) # 80005e4c <panic>

0000000080002756 <bpin>:

void
bpin(struct buf *b) {
    80002756:	1101                	addi	sp,sp,-32
    80002758:	ec06                	sd	ra,24(sp)
    8000275a:	e822                	sd	s0,16(sp)
    8000275c:	e426                	sd	s1,8(sp)
    8000275e:	1000                	addi	s0,sp,32
    80002760:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002762:	00010517          	auipc	a0,0x10
    80002766:	60650513          	addi	a0,a0,1542 # 80012d68 <bcache>
    8000276a:	00004097          	auipc	ra,0x4
    8000276e:	c1a080e7          	jalr	-998(ra) # 80006384 <acquire>
  b->refcnt++;
    80002772:	40bc                	lw	a5,64(s1)
    80002774:	2785                	addiw	a5,a5,1
    80002776:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002778:	00010517          	auipc	a0,0x10
    8000277c:	5f050513          	addi	a0,a0,1520 # 80012d68 <bcache>
    80002780:	00004097          	auipc	ra,0x4
    80002784:	cb8080e7          	jalr	-840(ra) # 80006438 <release>
}
    80002788:	60e2                	ld	ra,24(sp)
    8000278a:	6442                	ld	s0,16(sp)
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	6105                	addi	sp,sp,32
    80002790:	8082                	ret

0000000080002792 <bunpin>:

void
bunpin(struct buf *b) {
    80002792:	1101                	addi	sp,sp,-32
    80002794:	ec06                	sd	ra,24(sp)
    80002796:	e822                	sd	s0,16(sp)
    80002798:	e426                	sd	s1,8(sp)
    8000279a:	1000                	addi	s0,sp,32
    8000279c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000279e:	00010517          	auipc	a0,0x10
    800027a2:	5ca50513          	addi	a0,a0,1482 # 80012d68 <bcache>
    800027a6:	00004097          	auipc	ra,0x4
    800027aa:	bde080e7          	jalr	-1058(ra) # 80006384 <acquire>
  b->refcnt--;
    800027ae:	40bc                	lw	a5,64(s1)
    800027b0:	37fd                	addiw	a5,a5,-1
    800027b2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800027b4:	00010517          	auipc	a0,0x10
    800027b8:	5b450513          	addi	a0,a0,1460 # 80012d68 <bcache>
    800027bc:	00004097          	auipc	ra,0x4
    800027c0:	c7c080e7          	jalr	-900(ra) # 80006438 <release>
}
    800027c4:	60e2                	ld	ra,24(sp)
    800027c6:	6442                	ld	s0,16(sp)
    800027c8:	64a2                	ld	s1,8(sp)
    800027ca:	6105                	addi	sp,sp,32
    800027cc:	8082                	ret

00000000800027ce <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800027ce:	1101                	addi	sp,sp,-32
    800027d0:	ec06                	sd	ra,24(sp)
    800027d2:	e822                	sd	s0,16(sp)
    800027d4:	e426                	sd	s1,8(sp)
    800027d6:	e04a                	sd	s2,0(sp)
    800027d8:	1000                	addi	s0,sp,32
    800027da:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800027dc:	00d5d59b          	srliw	a1,a1,0xd
    800027e0:	00019797          	auipc	a5,0x19
    800027e4:	c647a783          	lw	a5,-924(a5) # 8001b444 <sb+0x1c>
    800027e8:	9dbd                	addw	a1,a1,a5
    800027ea:	00000097          	auipc	ra,0x0
    800027ee:	d9e080e7          	jalr	-610(ra) # 80002588 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800027f2:	0074f713          	andi	a4,s1,7
    800027f6:	4785                	li	a5,1
    800027f8:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800027fc:	14ce                	slli	s1,s1,0x33
    800027fe:	90d9                	srli	s1,s1,0x36
    80002800:	00950733          	add	a4,a0,s1
    80002804:	05874703          	lbu	a4,88(a4)
    80002808:	00e7f6b3          	and	a3,a5,a4
    8000280c:	c69d                	beqz	a3,8000283a <bfree+0x6c>
    8000280e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002810:	94aa                	add	s1,s1,a0
    80002812:	fff7c793          	not	a5,a5
    80002816:	8f7d                	and	a4,a4,a5
    80002818:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000281c:	00001097          	auipc	ra,0x1
    80002820:	126080e7          	jalr	294(ra) # 80003942 <log_write>
  brelse(bp);
    80002824:	854a                	mv	a0,s2
    80002826:	00000097          	auipc	ra,0x0
    8000282a:	e92080e7          	jalr	-366(ra) # 800026b8 <brelse>
}
    8000282e:	60e2                	ld	ra,24(sp)
    80002830:	6442                	ld	s0,16(sp)
    80002832:	64a2                	ld	s1,8(sp)
    80002834:	6902                	ld	s2,0(sp)
    80002836:	6105                	addi	sp,sp,32
    80002838:	8082                	ret
    panic("freeing free block");
    8000283a:	00006517          	auipc	a0,0x6
    8000283e:	c9650513          	addi	a0,a0,-874 # 800084d0 <syscalls+0x100>
    80002842:	00003097          	auipc	ra,0x3
    80002846:	60a080e7          	jalr	1546(ra) # 80005e4c <panic>

000000008000284a <balloc>:
{
    8000284a:	711d                	addi	sp,sp,-96
    8000284c:	ec86                	sd	ra,88(sp)
    8000284e:	e8a2                	sd	s0,80(sp)
    80002850:	e4a6                	sd	s1,72(sp)
    80002852:	e0ca                	sd	s2,64(sp)
    80002854:	fc4e                	sd	s3,56(sp)
    80002856:	f852                	sd	s4,48(sp)
    80002858:	f456                	sd	s5,40(sp)
    8000285a:	f05a                	sd	s6,32(sp)
    8000285c:	ec5e                	sd	s7,24(sp)
    8000285e:	e862                	sd	s8,16(sp)
    80002860:	e466                	sd	s9,8(sp)
    80002862:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002864:	00019797          	auipc	a5,0x19
    80002868:	bc87a783          	lw	a5,-1080(a5) # 8001b42c <sb+0x4>
    8000286c:	cff5                	beqz	a5,80002968 <balloc+0x11e>
    8000286e:	8baa                	mv	s7,a0
    80002870:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002872:	00019b17          	auipc	s6,0x19
    80002876:	bb6b0b13          	addi	s6,s6,-1098 # 8001b428 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000287a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000287c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000287e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002880:	6c89                	lui	s9,0x2
    80002882:	a061                	j	8000290a <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002884:	97ca                	add	a5,a5,s2
    80002886:	8e55                	or	a2,a2,a3
    80002888:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000288c:	854a                	mv	a0,s2
    8000288e:	00001097          	auipc	ra,0x1
    80002892:	0b4080e7          	jalr	180(ra) # 80003942 <log_write>
        brelse(bp);
    80002896:	854a                	mv	a0,s2
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	e20080e7          	jalr	-480(ra) # 800026b8 <brelse>
  bp = bread(dev, bno);
    800028a0:	85a6                	mv	a1,s1
    800028a2:	855e                	mv	a0,s7
    800028a4:	00000097          	auipc	ra,0x0
    800028a8:	ce4080e7          	jalr	-796(ra) # 80002588 <bread>
    800028ac:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800028ae:	40000613          	li	a2,1024
    800028b2:	4581                	li	a1,0
    800028b4:	05850513          	addi	a0,a0,88
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	8c2080e7          	jalr	-1854(ra) # 8000017a <memset>
  log_write(bp);
    800028c0:	854a                	mv	a0,s2
    800028c2:	00001097          	auipc	ra,0x1
    800028c6:	080080e7          	jalr	128(ra) # 80003942 <log_write>
  brelse(bp);
    800028ca:	854a                	mv	a0,s2
    800028cc:	00000097          	auipc	ra,0x0
    800028d0:	dec080e7          	jalr	-532(ra) # 800026b8 <brelse>
}
    800028d4:	8526                	mv	a0,s1
    800028d6:	60e6                	ld	ra,88(sp)
    800028d8:	6446                	ld	s0,80(sp)
    800028da:	64a6                	ld	s1,72(sp)
    800028dc:	6906                	ld	s2,64(sp)
    800028de:	79e2                	ld	s3,56(sp)
    800028e0:	7a42                	ld	s4,48(sp)
    800028e2:	7aa2                	ld	s5,40(sp)
    800028e4:	7b02                	ld	s6,32(sp)
    800028e6:	6be2                	ld	s7,24(sp)
    800028e8:	6c42                	ld	s8,16(sp)
    800028ea:	6ca2                	ld	s9,8(sp)
    800028ec:	6125                	addi	sp,sp,96
    800028ee:	8082                	ret
    brelse(bp);
    800028f0:	854a                	mv	a0,s2
    800028f2:	00000097          	auipc	ra,0x0
    800028f6:	dc6080e7          	jalr	-570(ra) # 800026b8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800028fa:	015c87bb          	addw	a5,s9,s5
    800028fe:	00078a9b          	sext.w	s5,a5
    80002902:	004b2703          	lw	a4,4(s6)
    80002906:	06eaf163          	bgeu	s5,a4,80002968 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000290a:	41fad79b          	sraiw	a5,s5,0x1f
    8000290e:	0137d79b          	srliw	a5,a5,0x13
    80002912:	015787bb          	addw	a5,a5,s5
    80002916:	40d7d79b          	sraiw	a5,a5,0xd
    8000291a:	01cb2583          	lw	a1,28(s6)
    8000291e:	9dbd                	addw	a1,a1,a5
    80002920:	855e                	mv	a0,s7
    80002922:	00000097          	auipc	ra,0x0
    80002926:	c66080e7          	jalr	-922(ra) # 80002588 <bread>
    8000292a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000292c:	004b2503          	lw	a0,4(s6)
    80002930:	000a849b          	sext.w	s1,s5
    80002934:	8762                	mv	a4,s8
    80002936:	faa4fde3          	bgeu	s1,a0,800028f0 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000293a:	00777693          	andi	a3,a4,7
    8000293e:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002942:	41f7579b          	sraiw	a5,a4,0x1f
    80002946:	01d7d79b          	srliw	a5,a5,0x1d
    8000294a:	9fb9                	addw	a5,a5,a4
    8000294c:	4037d79b          	sraiw	a5,a5,0x3
    80002950:	00f90633          	add	a2,s2,a5
    80002954:	05864603          	lbu	a2,88(a2)
    80002958:	00c6f5b3          	and	a1,a3,a2
    8000295c:	d585                	beqz	a1,80002884 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000295e:	2705                	addiw	a4,a4,1
    80002960:	2485                	addiw	s1,s1,1
    80002962:	fd471ae3          	bne	a4,s4,80002936 <balloc+0xec>
    80002966:	b769                	j	800028f0 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80002968:	00006517          	auipc	a0,0x6
    8000296c:	b8050513          	addi	a0,a0,-1152 # 800084e8 <syscalls+0x118>
    80002970:	00003097          	auipc	ra,0x3
    80002974:	526080e7          	jalr	1318(ra) # 80005e96 <printf>
  return 0;
    80002978:	4481                	li	s1,0
    8000297a:	bfa9                	j	800028d4 <balloc+0x8a>

000000008000297c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000297c:	7179                	addi	sp,sp,-48
    8000297e:	f406                	sd	ra,40(sp)
    80002980:	f022                	sd	s0,32(sp)
    80002982:	ec26                	sd	s1,24(sp)
    80002984:	e84a                	sd	s2,16(sp)
    80002986:	e44e                	sd	s3,8(sp)
    80002988:	e052                	sd	s4,0(sp)
    8000298a:	1800                	addi	s0,sp,48
    8000298c:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000298e:	47ad                	li	a5,11
    80002990:	02b7e863          	bltu	a5,a1,800029c0 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80002994:	02059793          	slli	a5,a1,0x20
    80002998:	01e7d593          	srli	a1,a5,0x1e
    8000299c:	00b504b3          	add	s1,a0,a1
    800029a0:	0504a903          	lw	s2,80(s1)
    800029a4:	06091e63          	bnez	s2,80002a20 <bmap+0xa4>
      addr = balloc(ip->dev);
    800029a8:	4108                	lw	a0,0(a0)
    800029aa:	00000097          	auipc	ra,0x0
    800029ae:	ea0080e7          	jalr	-352(ra) # 8000284a <balloc>
    800029b2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800029b6:	06090563          	beqz	s2,80002a20 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800029ba:	0524a823          	sw	s2,80(s1)
    800029be:	a08d                	j	80002a20 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800029c0:	ff45849b          	addiw	s1,a1,-12
    800029c4:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800029c8:	0ff00793          	li	a5,255
    800029cc:	08e7e563          	bltu	a5,a4,80002a56 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800029d0:	08052903          	lw	s2,128(a0)
    800029d4:	00091d63          	bnez	s2,800029ee <bmap+0x72>
      addr = balloc(ip->dev);
    800029d8:	4108                	lw	a0,0(a0)
    800029da:	00000097          	auipc	ra,0x0
    800029de:	e70080e7          	jalr	-400(ra) # 8000284a <balloc>
    800029e2:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800029e6:	02090d63          	beqz	s2,80002a20 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800029ea:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800029ee:	85ca                	mv	a1,s2
    800029f0:	0009a503          	lw	a0,0(s3)
    800029f4:	00000097          	auipc	ra,0x0
    800029f8:	b94080e7          	jalr	-1132(ra) # 80002588 <bread>
    800029fc:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800029fe:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002a02:	02049713          	slli	a4,s1,0x20
    80002a06:	01e75593          	srli	a1,a4,0x1e
    80002a0a:	00b784b3          	add	s1,a5,a1
    80002a0e:	0004a903          	lw	s2,0(s1)
    80002a12:	02090063          	beqz	s2,80002a32 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002a16:	8552                	mv	a0,s4
    80002a18:	00000097          	auipc	ra,0x0
    80002a1c:	ca0080e7          	jalr	-864(ra) # 800026b8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002a20:	854a                	mv	a0,s2
    80002a22:	70a2                	ld	ra,40(sp)
    80002a24:	7402                	ld	s0,32(sp)
    80002a26:	64e2                	ld	s1,24(sp)
    80002a28:	6942                	ld	s2,16(sp)
    80002a2a:	69a2                	ld	s3,8(sp)
    80002a2c:	6a02                	ld	s4,0(sp)
    80002a2e:	6145                	addi	sp,sp,48
    80002a30:	8082                	ret
      addr = balloc(ip->dev);
    80002a32:	0009a503          	lw	a0,0(s3)
    80002a36:	00000097          	auipc	ra,0x0
    80002a3a:	e14080e7          	jalr	-492(ra) # 8000284a <balloc>
    80002a3e:	0005091b          	sext.w	s2,a0
      if(addr){
    80002a42:	fc090ae3          	beqz	s2,80002a16 <bmap+0x9a>
        a[bn] = addr;
    80002a46:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002a4a:	8552                	mv	a0,s4
    80002a4c:	00001097          	auipc	ra,0x1
    80002a50:	ef6080e7          	jalr	-266(ra) # 80003942 <log_write>
    80002a54:	b7c9                	j	80002a16 <bmap+0x9a>
  panic("bmap: out of range");
    80002a56:	00006517          	auipc	a0,0x6
    80002a5a:	aaa50513          	addi	a0,a0,-1366 # 80008500 <syscalls+0x130>
    80002a5e:	00003097          	auipc	ra,0x3
    80002a62:	3ee080e7          	jalr	1006(ra) # 80005e4c <panic>

0000000080002a66 <iget>:
{
    80002a66:	7179                	addi	sp,sp,-48
    80002a68:	f406                	sd	ra,40(sp)
    80002a6a:	f022                	sd	s0,32(sp)
    80002a6c:	ec26                	sd	s1,24(sp)
    80002a6e:	e84a                	sd	s2,16(sp)
    80002a70:	e44e                	sd	s3,8(sp)
    80002a72:	e052                	sd	s4,0(sp)
    80002a74:	1800                	addi	s0,sp,48
    80002a76:	89aa                	mv	s3,a0
    80002a78:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002a7a:	00019517          	auipc	a0,0x19
    80002a7e:	9ce50513          	addi	a0,a0,-1586 # 8001b448 <itable>
    80002a82:	00004097          	auipc	ra,0x4
    80002a86:	902080e7          	jalr	-1790(ra) # 80006384 <acquire>
  empty = 0;
    80002a8a:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002a8c:	00019497          	auipc	s1,0x19
    80002a90:	9d448493          	addi	s1,s1,-1580 # 8001b460 <itable+0x18>
    80002a94:	0001a697          	auipc	a3,0x1a
    80002a98:	45c68693          	addi	a3,a3,1116 # 8001cef0 <log>
    80002a9c:	a039                	j	80002aaa <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002a9e:	02090b63          	beqz	s2,80002ad4 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002aa2:	08848493          	addi	s1,s1,136
    80002aa6:	02d48a63          	beq	s1,a3,80002ada <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002aaa:	449c                	lw	a5,8(s1)
    80002aac:	fef059e3          	blez	a5,80002a9e <iget+0x38>
    80002ab0:	4098                	lw	a4,0(s1)
    80002ab2:	ff3716e3          	bne	a4,s3,80002a9e <iget+0x38>
    80002ab6:	40d8                	lw	a4,4(s1)
    80002ab8:	ff4713e3          	bne	a4,s4,80002a9e <iget+0x38>
      ip->ref++;
    80002abc:	2785                	addiw	a5,a5,1
    80002abe:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002ac0:	00019517          	auipc	a0,0x19
    80002ac4:	98850513          	addi	a0,a0,-1656 # 8001b448 <itable>
    80002ac8:	00004097          	auipc	ra,0x4
    80002acc:	970080e7          	jalr	-1680(ra) # 80006438 <release>
      return ip;
    80002ad0:	8926                	mv	s2,s1
    80002ad2:	a03d                	j	80002b00 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002ad4:	f7f9                	bnez	a5,80002aa2 <iget+0x3c>
    80002ad6:	8926                	mv	s2,s1
    80002ad8:	b7e9                	j	80002aa2 <iget+0x3c>
  if(empty == 0)
    80002ada:	02090c63          	beqz	s2,80002b12 <iget+0xac>
  ip->dev = dev;
    80002ade:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002ae2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002ae6:	4785                	li	a5,1
    80002ae8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002aec:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002af0:	00019517          	auipc	a0,0x19
    80002af4:	95850513          	addi	a0,a0,-1704 # 8001b448 <itable>
    80002af8:	00004097          	auipc	ra,0x4
    80002afc:	940080e7          	jalr	-1728(ra) # 80006438 <release>
}
    80002b00:	854a                	mv	a0,s2
    80002b02:	70a2                	ld	ra,40(sp)
    80002b04:	7402                	ld	s0,32(sp)
    80002b06:	64e2                	ld	s1,24(sp)
    80002b08:	6942                	ld	s2,16(sp)
    80002b0a:	69a2                	ld	s3,8(sp)
    80002b0c:	6a02                	ld	s4,0(sp)
    80002b0e:	6145                	addi	sp,sp,48
    80002b10:	8082                	ret
    panic("iget: no inodes");
    80002b12:	00006517          	auipc	a0,0x6
    80002b16:	a0650513          	addi	a0,a0,-1530 # 80008518 <syscalls+0x148>
    80002b1a:	00003097          	auipc	ra,0x3
    80002b1e:	332080e7          	jalr	818(ra) # 80005e4c <panic>

0000000080002b22 <fsinit>:
fsinit(int dev) {
    80002b22:	7179                	addi	sp,sp,-48
    80002b24:	f406                	sd	ra,40(sp)
    80002b26:	f022                	sd	s0,32(sp)
    80002b28:	ec26                	sd	s1,24(sp)
    80002b2a:	e84a                	sd	s2,16(sp)
    80002b2c:	e44e                	sd	s3,8(sp)
    80002b2e:	1800                	addi	s0,sp,48
    80002b30:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002b32:	4585                	li	a1,1
    80002b34:	00000097          	auipc	ra,0x0
    80002b38:	a54080e7          	jalr	-1452(ra) # 80002588 <bread>
    80002b3c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002b3e:	00019997          	auipc	s3,0x19
    80002b42:	8ea98993          	addi	s3,s3,-1814 # 8001b428 <sb>
    80002b46:	02000613          	li	a2,32
    80002b4a:	05850593          	addi	a1,a0,88
    80002b4e:	854e                	mv	a0,s3
    80002b50:	ffffd097          	auipc	ra,0xffffd
    80002b54:	686080e7          	jalr	1670(ra) # 800001d6 <memmove>
  brelse(bp);
    80002b58:	8526                	mv	a0,s1
    80002b5a:	00000097          	auipc	ra,0x0
    80002b5e:	b5e080e7          	jalr	-1186(ra) # 800026b8 <brelse>
  if(sb.magic != FSMAGIC)
    80002b62:	0009a703          	lw	a4,0(s3)
    80002b66:	102037b7          	lui	a5,0x10203
    80002b6a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002b6e:	02f71263          	bne	a4,a5,80002b92 <fsinit+0x70>
  initlog(dev, &sb);
    80002b72:	00019597          	auipc	a1,0x19
    80002b76:	8b658593          	addi	a1,a1,-1866 # 8001b428 <sb>
    80002b7a:	854a                	mv	a0,s2
    80002b7c:	00001097          	auipc	ra,0x1
    80002b80:	b4a080e7          	jalr	-1206(ra) # 800036c6 <initlog>
}
    80002b84:	70a2                	ld	ra,40(sp)
    80002b86:	7402                	ld	s0,32(sp)
    80002b88:	64e2                	ld	s1,24(sp)
    80002b8a:	6942                	ld	s2,16(sp)
    80002b8c:	69a2                	ld	s3,8(sp)
    80002b8e:	6145                	addi	sp,sp,48
    80002b90:	8082                	ret
    panic("invalid file system");
    80002b92:	00006517          	auipc	a0,0x6
    80002b96:	99650513          	addi	a0,a0,-1642 # 80008528 <syscalls+0x158>
    80002b9a:	00003097          	auipc	ra,0x3
    80002b9e:	2b2080e7          	jalr	690(ra) # 80005e4c <panic>

0000000080002ba2 <iinit>:
{
    80002ba2:	7179                	addi	sp,sp,-48
    80002ba4:	f406                	sd	ra,40(sp)
    80002ba6:	f022                	sd	s0,32(sp)
    80002ba8:	ec26                	sd	s1,24(sp)
    80002baa:	e84a                	sd	s2,16(sp)
    80002bac:	e44e                	sd	s3,8(sp)
    80002bae:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002bb0:	00006597          	auipc	a1,0x6
    80002bb4:	99058593          	addi	a1,a1,-1648 # 80008540 <syscalls+0x170>
    80002bb8:	00019517          	auipc	a0,0x19
    80002bbc:	89050513          	addi	a0,a0,-1904 # 8001b448 <itable>
    80002bc0:	00003097          	auipc	ra,0x3
    80002bc4:	734080e7          	jalr	1844(ra) # 800062f4 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002bc8:	00019497          	auipc	s1,0x19
    80002bcc:	8a848493          	addi	s1,s1,-1880 # 8001b470 <itable+0x28>
    80002bd0:	0001a997          	auipc	s3,0x1a
    80002bd4:	33098993          	addi	s3,s3,816 # 8001cf00 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002bd8:	00006917          	auipc	s2,0x6
    80002bdc:	97090913          	addi	s2,s2,-1680 # 80008548 <syscalls+0x178>
    80002be0:	85ca                	mv	a1,s2
    80002be2:	8526                	mv	a0,s1
    80002be4:	00001097          	auipc	ra,0x1
    80002be8:	e42080e7          	jalr	-446(ra) # 80003a26 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002bec:	08848493          	addi	s1,s1,136
    80002bf0:	ff3498e3          	bne	s1,s3,80002be0 <iinit+0x3e>
}
    80002bf4:	70a2                	ld	ra,40(sp)
    80002bf6:	7402                	ld	s0,32(sp)
    80002bf8:	64e2                	ld	s1,24(sp)
    80002bfa:	6942                	ld	s2,16(sp)
    80002bfc:	69a2                	ld	s3,8(sp)
    80002bfe:	6145                	addi	sp,sp,48
    80002c00:	8082                	ret

0000000080002c02 <ialloc>:
{
    80002c02:	715d                	addi	sp,sp,-80
    80002c04:	e486                	sd	ra,72(sp)
    80002c06:	e0a2                	sd	s0,64(sp)
    80002c08:	fc26                	sd	s1,56(sp)
    80002c0a:	f84a                	sd	s2,48(sp)
    80002c0c:	f44e                	sd	s3,40(sp)
    80002c0e:	f052                	sd	s4,32(sp)
    80002c10:	ec56                	sd	s5,24(sp)
    80002c12:	e85a                	sd	s6,16(sp)
    80002c14:	e45e                	sd	s7,8(sp)
    80002c16:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002c18:	00019717          	auipc	a4,0x19
    80002c1c:	81c72703          	lw	a4,-2020(a4) # 8001b434 <sb+0xc>
    80002c20:	4785                	li	a5,1
    80002c22:	04e7fa63          	bgeu	a5,a4,80002c76 <ialloc+0x74>
    80002c26:	8aaa                	mv	s5,a0
    80002c28:	8bae                	mv	s7,a1
    80002c2a:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002c2c:	00018a17          	auipc	s4,0x18
    80002c30:	7fca0a13          	addi	s4,s4,2044 # 8001b428 <sb>
    80002c34:	00048b1b          	sext.w	s6,s1
    80002c38:	0044d593          	srli	a1,s1,0x4
    80002c3c:	018a2783          	lw	a5,24(s4)
    80002c40:	9dbd                	addw	a1,a1,a5
    80002c42:	8556                	mv	a0,s5
    80002c44:	00000097          	auipc	ra,0x0
    80002c48:	944080e7          	jalr	-1724(ra) # 80002588 <bread>
    80002c4c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002c4e:	05850993          	addi	s3,a0,88
    80002c52:	00f4f793          	andi	a5,s1,15
    80002c56:	079a                	slli	a5,a5,0x6
    80002c58:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002c5a:	00099783          	lh	a5,0(s3)
    80002c5e:	c3a1                	beqz	a5,80002c9e <ialloc+0x9c>
    brelse(bp);
    80002c60:	00000097          	auipc	ra,0x0
    80002c64:	a58080e7          	jalr	-1448(ra) # 800026b8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002c68:	0485                	addi	s1,s1,1
    80002c6a:	00ca2703          	lw	a4,12(s4)
    80002c6e:	0004879b          	sext.w	a5,s1
    80002c72:	fce7e1e3          	bltu	a5,a4,80002c34 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002c76:	00006517          	auipc	a0,0x6
    80002c7a:	8da50513          	addi	a0,a0,-1830 # 80008550 <syscalls+0x180>
    80002c7e:	00003097          	auipc	ra,0x3
    80002c82:	218080e7          	jalr	536(ra) # 80005e96 <printf>
  return 0;
    80002c86:	4501                	li	a0,0
}
    80002c88:	60a6                	ld	ra,72(sp)
    80002c8a:	6406                	ld	s0,64(sp)
    80002c8c:	74e2                	ld	s1,56(sp)
    80002c8e:	7942                	ld	s2,48(sp)
    80002c90:	79a2                	ld	s3,40(sp)
    80002c92:	7a02                	ld	s4,32(sp)
    80002c94:	6ae2                	ld	s5,24(sp)
    80002c96:	6b42                	ld	s6,16(sp)
    80002c98:	6ba2                	ld	s7,8(sp)
    80002c9a:	6161                	addi	sp,sp,80
    80002c9c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002c9e:	04000613          	li	a2,64
    80002ca2:	4581                	li	a1,0
    80002ca4:	854e                	mv	a0,s3
    80002ca6:	ffffd097          	auipc	ra,0xffffd
    80002caa:	4d4080e7          	jalr	1236(ra) # 8000017a <memset>
      dip->type = type;
    80002cae:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002cb2:	854a                	mv	a0,s2
    80002cb4:	00001097          	auipc	ra,0x1
    80002cb8:	c8e080e7          	jalr	-882(ra) # 80003942 <log_write>
      brelse(bp);
    80002cbc:	854a                	mv	a0,s2
    80002cbe:	00000097          	auipc	ra,0x0
    80002cc2:	9fa080e7          	jalr	-1542(ra) # 800026b8 <brelse>
      return iget(dev, inum);
    80002cc6:	85da                	mv	a1,s6
    80002cc8:	8556                	mv	a0,s5
    80002cca:	00000097          	auipc	ra,0x0
    80002cce:	d9c080e7          	jalr	-612(ra) # 80002a66 <iget>
    80002cd2:	bf5d                	j	80002c88 <ialloc+0x86>

0000000080002cd4 <iupdate>:
{
    80002cd4:	1101                	addi	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	e426                	sd	s1,8(sp)
    80002cdc:	e04a                	sd	s2,0(sp)
    80002cde:	1000                	addi	s0,sp,32
    80002ce0:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002ce2:	415c                	lw	a5,4(a0)
    80002ce4:	0047d79b          	srliw	a5,a5,0x4
    80002ce8:	00018597          	auipc	a1,0x18
    80002cec:	7585a583          	lw	a1,1880(a1) # 8001b440 <sb+0x18>
    80002cf0:	9dbd                	addw	a1,a1,a5
    80002cf2:	4108                	lw	a0,0(a0)
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	894080e7          	jalr	-1900(ra) # 80002588 <bread>
    80002cfc:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002cfe:	05850793          	addi	a5,a0,88
    80002d02:	40d8                	lw	a4,4(s1)
    80002d04:	8b3d                	andi	a4,a4,15
    80002d06:	071a                	slli	a4,a4,0x6
    80002d08:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002d0a:	04449703          	lh	a4,68(s1)
    80002d0e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002d12:	04649703          	lh	a4,70(s1)
    80002d16:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002d1a:	04849703          	lh	a4,72(s1)
    80002d1e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002d22:	04a49703          	lh	a4,74(s1)
    80002d26:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002d2a:	44f8                	lw	a4,76(s1)
    80002d2c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002d2e:	03400613          	li	a2,52
    80002d32:	05048593          	addi	a1,s1,80
    80002d36:	00c78513          	addi	a0,a5,12
    80002d3a:	ffffd097          	auipc	ra,0xffffd
    80002d3e:	49c080e7          	jalr	1180(ra) # 800001d6 <memmove>
  log_write(bp);
    80002d42:	854a                	mv	a0,s2
    80002d44:	00001097          	auipc	ra,0x1
    80002d48:	bfe080e7          	jalr	-1026(ra) # 80003942 <log_write>
  brelse(bp);
    80002d4c:	854a                	mv	a0,s2
    80002d4e:	00000097          	auipc	ra,0x0
    80002d52:	96a080e7          	jalr	-1686(ra) # 800026b8 <brelse>
}
    80002d56:	60e2                	ld	ra,24(sp)
    80002d58:	6442                	ld	s0,16(sp)
    80002d5a:	64a2                	ld	s1,8(sp)
    80002d5c:	6902                	ld	s2,0(sp)
    80002d5e:	6105                	addi	sp,sp,32
    80002d60:	8082                	ret

0000000080002d62 <idup>:
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	1000                	addi	s0,sp,32
    80002d6c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002d6e:	00018517          	auipc	a0,0x18
    80002d72:	6da50513          	addi	a0,a0,1754 # 8001b448 <itable>
    80002d76:	00003097          	auipc	ra,0x3
    80002d7a:	60e080e7          	jalr	1550(ra) # 80006384 <acquire>
  ip->ref++;
    80002d7e:	449c                	lw	a5,8(s1)
    80002d80:	2785                	addiw	a5,a5,1
    80002d82:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002d84:	00018517          	auipc	a0,0x18
    80002d88:	6c450513          	addi	a0,a0,1732 # 8001b448 <itable>
    80002d8c:	00003097          	auipc	ra,0x3
    80002d90:	6ac080e7          	jalr	1708(ra) # 80006438 <release>
}
    80002d94:	8526                	mv	a0,s1
    80002d96:	60e2                	ld	ra,24(sp)
    80002d98:	6442                	ld	s0,16(sp)
    80002d9a:	64a2                	ld	s1,8(sp)
    80002d9c:	6105                	addi	sp,sp,32
    80002d9e:	8082                	ret

0000000080002da0 <ilock>:
{
    80002da0:	1101                	addi	sp,sp,-32
    80002da2:	ec06                	sd	ra,24(sp)
    80002da4:	e822                	sd	s0,16(sp)
    80002da6:	e426                	sd	s1,8(sp)
    80002da8:	e04a                	sd	s2,0(sp)
    80002daa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002dac:	c115                	beqz	a0,80002dd0 <ilock+0x30>
    80002dae:	84aa                	mv	s1,a0
    80002db0:	451c                	lw	a5,8(a0)
    80002db2:	00f05f63          	blez	a5,80002dd0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002db6:	0541                	addi	a0,a0,16
    80002db8:	00001097          	auipc	ra,0x1
    80002dbc:	ca8080e7          	jalr	-856(ra) # 80003a60 <acquiresleep>
  if(ip->valid == 0){
    80002dc0:	40bc                	lw	a5,64(s1)
    80002dc2:	cf99                	beqz	a5,80002de0 <ilock+0x40>
}
    80002dc4:	60e2                	ld	ra,24(sp)
    80002dc6:	6442                	ld	s0,16(sp)
    80002dc8:	64a2                	ld	s1,8(sp)
    80002dca:	6902                	ld	s2,0(sp)
    80002dcc:	6105                	addi	sp,sp,32
    80002dce:	8082                	ret
    panic("ilock");
    80002dd0:	00005517          	auipc	a0,0x5
    80002dd4:	79850513          	addi	a0,a0,1944 # 80008568 <syscalls+0x198>
    80002dd8:	00003097          	auipc	ra,0x3
    80002ddc:	074080e7          	jalr	116(ra) # 80005e4c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002de0:	40dc                	lw	a5,4(s1)
    80002de2:	0047d79b          	srliw	a5,a5,0x4
    80002de6:	00018597          	auipc	a1,0x18
    80002dea:	65a5a583          	lw	a1,1626(a1) # 8001b440 <sb+0x18>
    80002dee:	9dbd                	addw	a1,a1,a5
    80002df0:	4088                	lw	a0,0(s1)
    80002df2:	fffff097          	auipc	ra,0xfffff
    80002df6:	796080e7          	jalr	1942(ra) # 80002588 <bread>
    80002dfa:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002dfc:	05850593          	addi	a1,a0,88
    80002e00:	40dc                	lw	a5,4(s1)
    80002e02:	8bbd                	andi	a5,a5,15
    80002e04:	079a                	slli	a5,a5,0x6
    80002e06:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002e08:	00059783          	lh	a5,0(a1)
    80002e0c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002e10:	00259783          	lh	a5,2(a1)
    80002e14:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002e18:	00459783          	lh	a5,4(a1)
    80002e1c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002e20:	00659783          	lh	a5,6(a1)
    80002e24:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002e28:	459c                	lw	a5,8(a1)
    80002e2a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002e2c:	03400613          	li	a2,52
    80002e30:	05b1                	addi	a1,a1,12
    80002e32:	05048513          	addi	a0,s1,80
    80002e36:	ffffd097          	auipc	ra,0xffffd
    80002e3a:	3a0080e7          	jalr	928(ra) # 800001d6 <memmove>
    brelse(bp);
    80002e3e:	854a                	mv	a0,s2
    80002e40:	00000097          	auipc	ra,0x0
    80002e44:	878080e7          	jalr	-1928(ra) # 800026b8 <brelse>
    ip->valid = 1;
    80002e48:	4785                	li	a5,1
    80002e4a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002e4c:	04449783          	lh	a5,68(s1)
    80002e50:	fbb5                	bnez	a5,80002dc4 <ilock+0x24>
      panic("ilock: no type");
    80002e52:	00005517          	auipc	a0,0x5
    80002e56:	71e50513          	addi	a0,a0,1822 # 80008570 <syscalls+0x1a0>
    80002e5a:	00003097          	auipc	ra,0x3
    80002e5e:	ff2080e7          	jalr	-14(ra) # 80005e4c <panic>

0000000080002e62 <iunlock>:
{
    80002e62:	1101                	addi	sp,sp,-32
    80002e64:	ec06                	sd	ra,24(sp)
    80002e66:	e822                	sd	s0,16(sp)
    80002e68:	e426                	sd	s1,8(sp)
    80002e6a:	e04a                	sd	s2,0(sp)
    80002e6c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002e6e:	c905                	beqz	a0,80002e9e <iunlock+0x3c>
    80002e70:	84aa                	mv	s1,a0
    80002e72:	01050913          	addi	s2,a0,16
    80002e76:	854a                	mv	a0,s2
    80002e78:	00001097          	auipc	ra,0x1
    80002e7c:	c82080e7          	jalr	-894(ra) # 80003afa <holdingsleep>
    80002e80:	cd19                	beqz	a0,80002e9e <iunlock+0x3c>
    80002e82:	449c                	lw	a5,8(s1)
    80002e84:	00f05d63          	blez	a5,80002e9e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002e88:	854a                	mv	a0,s2
    80002e8a:	00001097          	auipc	ra,0x1
    80002e8e:	c2c080e7          	jalr	-980(ra) # 80003ab6 <releasesleep>
}
    80002e92:	60e2                	ld	ra,24(sp)
    80002e94:	6442                	ld	s0,16(sp)
    80002e96:	64a2                	ld	s1,8(sp)
    80002e98:	6902                	ld	s2,0(sp)
    80002e9a:	6105                	addi	sp,sp,32
    80002e9c:	8082                	ret
    panic("iunlock");
    80002e9e:	00005517          	auipc	a0,0x5
    80002ea2:	6e250513          	addi	a0,a0,1762 # 80008580 <syscalls+0x1b0>
    80002ea6:	00003097          	auipc	ra,0x3
    80002eaa:	fa6080e7          	jalr	-90(ra) # 80005e4c <panic>

0000000080002eae <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002eae:	7179                	addi	sp,sp,-48
    80002eb0:	f406                	sd	ra,40(sp)
    80002eb2:	f022                	sd	s0,32(sp)
    80002eb4:	ec26                	sd	s1,24(sp)
    80002eb6:	e84a                	sd	s2,16(sp)
    80002eb8:	e44e                	sd	s3,8(sp)
    80002eba:	e052                	sd	s4,0(sp)
    80002ebc:	1800                	addi	s0,sp,48
    80002ebe:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002ec0:	05050493          	addi	s1,a0,80
    80002ec4:	08050913          	addi	s2,a0,128
    80002ec8:	a021                	j	80002ed0 <itrunc+0x22>
    80002eca:	0491                	addi	s1,s1,4
    80002ecc:	01248d63          	beq	s1,s2,80002ee6 <itrunc+0x38>
    if(ip->addrs[i]){
    80002ed0:	408c                	lw	a1,0(s1)
    80002ed2:	dde5                	beqz	a1,80002eca <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002ed4:	0009a503          	lw	a0,0(s3)
    80002ed8:	00000097          	auipc	ra,0x0
    80002edc:	8f6080e7          	jalr	-1802(ra) # 800027ce <bfree>
      ip->addrs[i] = 0;
    80002ee0:	0004a023          	sw	zero,0(s1)
    80002ee4:	b7dd                	j	80002eca <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002ee6:	0809a583          	lw	a1,128(s3)
    80002eea:	e185                	bnez	a1,80002f0a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002eec:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002ef0:	854e                	mv	a0,s3
    80002ef2:	00000097          	auipc	ra,0x0
    80002ef6:	de2080e7          	jalr	-542(ra) # 80002cd4 <iupdate>
}
    80002efa:	70a2                	ld	ra,40(sp)
    80002efc:	7402                	ld	s0,32(sp)
    80002efe:	64e2                	ld	s1,24(sp)
    80002f00:	6942                	ld	s2,16(sp)
    80002f02:	69a2                	ld	s3,8(sp)
    80002f04:	6a02                	ld	s4,0(sp)
    80002f06:	6145                	addi	sp,sp,48
    80002f08:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002f0a:	0009a503          	lw	a0,0(s3)
    80002f0e:	fffff097          	auipc	ra,0xfffff
    80002f12:	67a080e7          	jalr	1658(ra) # 80002588 <bread>
    80002f16:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002f18:	05850493          	addi	s1,a0,88
    80002f1c:	45850913          	addi	s2,a0,1112
    80002f20:	a021                	j	80002f28 <itrunc+0x7a>
    80002f22:	0491                	addi	s1,s1,4
    80002f24:	01248b63          	beq	s1,s2,80002f3a <itrunc+0x8c>
      if(a[j])
    80002f28:	408c                	lw	a1,0(s1)
    80002f2a:	dde5                	beqz	a1,80002f22 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80002f2c:	0009a503          	lw	a0,0(s3)
    80002f30:	00000097          	auipc	ra,0x0
    80002f34:	89e080e7          	jalr	-1890(ra) # 800027ce <bfree>
    80002f38:	b7ed                	j	80002f22 <itrunc+0x74>
    brelse(bp);
    80002f3a:	8552                	mv	a0,s4
    80002f3c:	fffff097          	auipc	ra,0xfffff
    80002f40:	77c080e7          	jalr	1916(ra) # 800026b8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002f44:	0809a583          	lw	a1,128(s3)
    80002f48:	0009a503          	lw	a0,0(s3)
    80002f4c:	00000097          	auipc	ra,0x0
    80002f50:	882080e7          	jalr	-1918(ra) # 800027ce <bfree>
    ip->addrs[NDIRECT] = 0;
    80002f54:	0809a023          	sw	zero,128(s3)
    80002f58:	bf51                	j	80002eec <itrunc+0x3e>

0000000080002f5a <iput>:
{
    80002f5a:	1101                	addi	sp,sp,-32
    80002f5c:	ec06                	sd	ra,24(sp)
    80002f5e:	e822                	sd	s0,16(sp)
    80002f60:	e426                	sd	s1,8(sp)
    80002f62:	e04a                	sd	s2,0(sp)
    80002f64:	1000                	addi	s0,sp,32
    80002f66:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002f68:	00018517          	auipc	a0,0x18
    80002f6c:	4e050513          	addi	a0,a0,1248 # 8001b448 <itable>
    80002f70:	00003097          	auipc	ra,0x3
    80002f74:	414080e7          	jalr	1044(ra) # 80006384 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002f78:	4498                	lw	a4,8(s1)
    80002f7a:	4785                	li	a5,1
    80002f7c:	02f70363          	beq	a4,a5,80002fa2 <iput+0x48>
  ip->ref--;
    80002f80:	449c                	lw	a5,8(s1)
    80002f82:	37fd                	addiw	a5,a5,-1
    80002f84:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002f86:	00018517          	auipc	a0,0x18
    80002f8a:	4c250513          	addi	a0,a0,1218 # 8001b448 <itable>
    80002f8e:	00003097          	auipc	ra,0x3
    80002f92:	4aa080e7          	jalr	1194(ra) # 80006438 <release>
}
    80002f96:	60e2                	ld	ra,24(sp)
    80002f98:	6442                	ld	s0,16(sp)
    80002f9a:	64a2                	ld	s1,8(sp)
    80002f9c:	6902                	ld	s2,0(sp)
    80002f9e:	6105                	addi	sp,sp,32
    80002fa0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002fa2:	40bc                	lw	a5,64(s1)
    80002fa4:	dff1                	beqz	a5,80002f80 <iput+0x26>
    80002fa6:	04a49783          	lh	a5,74(s1)
    80002faa:	fbf9                	bnez	a5,80002f80 <iput+0x26>
    acquiresleep(&ip->lock);
    80002fac:	01048913          	addi	s2,s1,16
    80002fb0:	854a                	mv	a0,s2
    80002fb2:	00001097          	auipc	ra,0x1
    80002fb6:	aae080e7          	jalr	-1362(ra) # 80003a60 <acquiresleep>
    release(&itable.lock);
    80002fba:	00018517          	auipc	a0,0x18
    80002fbe:	48e50513          	addi	a0,a0,1166 # 8001b448 <itable>
    80002fc2:	00003097          	auipc	ra,0x3
    80002fc6:	476080e7          	jalr	1142(ra) # 80006438 <release>
    itrunc(ip);
    80002fca:	8526                	mv	a0,s1
    80002fcc:	00000097          	auipc	ra,0x0
    80002fd0:	ee2080e7          	jalr	-286(ra) # 80002eae <itrunc>
    ip->type = 0;
    80002fd4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002fd8:	8526                	mv	a0,s1
    80002fda:	00000097          	auipc	ra,0x0
    80002fde:	cfa080e7          	jalr	-774(ra) # 80002cd4 <iupdate>
    ip->valid = 0;
    80002fe2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002fe6:	854a                	mv	a0,s2
    80002fe8:	00001097          	auipc	ra,0x1
    80002fec:	ace080e7          	jalr	-1330(ra) # 80003ab6 <releasesleep>
    acquire(&itable.lock);
    80002ff0:	00018517          	auipc	a0,0x18
    80002ff4:	45850513          	addi	a0,a0,1112 # 8001b448 <itable>
    80002ff8:	00003097          	auipc	ra,0x3
    80002ffc:	38c080e7          	jalr	908(ra) # 80006384 <acquire>
    80003000:	b741                	j	80002f80 <iput+0x26>

0000000080003002 <iunlockput>:
{
    80003002:	1101                	addi	sp,sp,-32
    80003004:	ec06                	sd	ra,24(sp)
    80003006:	e822                	sd	s0,16(sp)
    80003008:	e426                	sd	s1,8(sp)
    8000300a:	1000                	addi	s0,sp,32
    8000300c:	84aa                	mv	s1,a0
  iunlock(ip);
    8000300e:	00000097          	auipc	ra,0x0
    80003012:	e54080e7          	jalr	-428(ra) # 80002e62 <iunlock>
  iput(ip);
    80003016:	8526                	mv	a0,s1
    80003018:	00000097          	auipc	ra,0x0
    8000301c:	f42080e7          	jalr	-190(ra) # 80002f5a <iput>
}
    80003020:	60e2                	ld	ra,24(sp)
    80003022:	6442                	ld	s0,16(sp)
    80003024:	64a2                	ld	s1,8(sp)
    80003026:	6105                	addi	sp,sp,32
    80003028:	8082                	ret

000000008000302a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000302a:	1141                	addi	sp,sp,-16
    8000302c:	e422                	sd	s0,8(sp)
    8000302e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003030:	411c                	lw	a5,0(a0)
    80003032:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003034:	415c                	lw	a5,4(a0)
    80003036:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003038:	04451783          	lh	a5,68(a0)
    8000303c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003040:	04a51783          	lh	a5,74(a0)
    80003044:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003048:	04c56783          	lwu	a5,76(a0)
    8000304c:	e99c                	sd	a5,16(a1)
}
    8000304e:	6422                	ld	s0,8(sp)
    80003050:	0141                	addi	sp,sp,16
    80003052:	8082                	ret

0000000080003054 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003054:	457c                	lw	a5,76(a0)
    80003056:	0ed7e963          	bltu	a5,a3,80003148 <readi+0xf4>
{
    8000305a:	7159                	addi	sp,sp,-112
    8000305c:	f486                	sd	ra,104(sp)
    8000305e:	f0a2                	sd	s0,96(sp)
    80003060:	eca6                	sd	s1,88(sp)
    80003062:	e8ca                	sd	s2,80(sp)
    80003064:	e4ce                	sd	s3,72(sp)
    80003066:	e0d2                	sd	s4,64(sp)
    80003068:	fc56                	sd	s5,56(sp)
    8000306a:	f85a                	sd	s6,48(sp)
    8000306c:	f45e                	sd	s7,40(sp)
    8000306e:	f062                	sd	s8,32(sp)
    80003070:	ec66                	sd	s9,24(sp)
    80003072:	e86a                	sd	s10,16(sp)
    80003074:	e46e                	sd	s11,8(sp)
    80003076:	1880                	addi	s0,sp,112
    80003078:	8b2a                	mv	s6,a0
    8000307a:	8bae                	mv	s7,a1
    8000307c:	8a32                	mv	s4,a2
    8000307e:	84b6                	mv	s1,a3
    80003080:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003082:	9f35                	addw	a4,a4,a3
    return 0;
    80003084:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003086:	0ad76063          	bltu	a4,a3,80003126 <readi+0xd2>
  if(off + n > ip->size)
    8000308a:	00e7f463          	bgeu	a5,a4,80003092 <readi+0x3e>
    n = ip->size - off;
    8000308e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003092:	0a0a8963          	beqz	s5,80003144 <readi+0xf0>
    80003096:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003098:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000309c:	5c7d                	li	s8,-1
    8000309e:	a82d                	j	800030d8 <readi+0x84>
    800030a0:	020d1d93          	slli	s11,s10,0x20
    800030a4:	020ddd93          	srli	s11,s11,0x20
    800030a8:	05890613          	addi	a2,s2,88
    800030ac:	86ee                	mv	a3,s11
    800030ae:	963a                	add	a2,a2,a4
    800030b0:	85d2                	mv	a1,s4
    800030b2:	855e                	mv	a0,s7
    800030b4:	fffff097          	auipc	ra,0xfffff
    800030b8:	858080e7          	jalr	-1960(ra) # 8000190c <either_copyout>
    800030bc:	05850d63          	beq	a0,s8,80003116 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800030c0:	854a                	mv	a0,s2
    800030c2:	fffff097          	auipc	ra,0xfffff
    800030c6:	5f6080e7          	jalr	1526(ra) # 800026b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800030ca:	013d09bb          	addw	s3,s10,s3
    800030ce:	009d04bb          	addw	s1,s10,s1
    800030d2:	9a6e                	add	s4,s4,s11
    800030d4:	0559f763          	bgeu	s3,s5,80003122 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800030d8:	00a4d59b          	srliw	a1,s1,0xa
    800030dc:	855a                	mv	a0,s6
    800030de:	00000097          	auipc	ra,0x0
    800030e2:	89e080e7          	jalr	-1890(ra) # 8000297c <bmap>
    800030e6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800030ea:	cd85                	beqz	a1,80003122 <readi+0xce>
    bp = bread(ip->dev, addr);
    800030ec:	000b2503          	lw	a0,0(s6)
    800030f0:	fffff097          	auipc	ra,0xfffff
    800030f4:	498080e7          	jalr	1176(ra) # 80002588 <bread>
    800030f8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800030fa:	3ff4f713          	andi	a4,s1,1023
    800030fe:	40ec87bb          	subw	a5,s9,a4
    80003102:	413a86bb          	subw	a3,s5,s3
    80003106:	8d3e                	mv	s10,a5
    80003108:	2781                	sext.w	a5,a5
    8000310a:	0006861b          	sext.w	a2,a3
    8000310e:	f8f679e3          	bgeu	a2,a5,800030a0 <readi+0x4c>
    80003112:	8d36                	mv	s10,a3
    80003114:	b771                	j	800030a0 <readi+0x4c>
      brelse(bp);
    80003116:	854a                	mv	a0,s2
    80003118:	fffff097          	auipc	ra,0xfffff
    8000311c:	5a0080e7          	jalr	1440(ra) # 800026b8 <brelse>
      tot = -1;
    80003120:	59fd                	li	s3,-1
  }
  return tot;
    80003122:	0009851b          	sext.w	a0,s3
}
    80003126:	70a6                	ld	ra,104(sp)
    80003128:	7406                	ld	s0,96(sp)
    8000312a:	64e6                	ld	s1,88(sp)
    8000312c:	6946                	ld	s2,80(sp)
    8000312e:	69a6                	ld	s3,72(sp)
    80003130:	6a06                	ld	s4,64(sp)
    80003132:	7ae2                	ld	s5,56(sp)
    80003134:	7b42                	ld	s6,48(sp)
    80003136:	7ba2                	ld	s7,40(sp)
    80003138:	7c02                	ld	s8,32(sp)
    8000313a:	6ce2                	ld	s9,24(sp)
    8000313c:	6d42                	ld	s10,16(sp)
    8000313e:	6da2                	ld	s11,8(sp)
    80003140:	6165                	addi	sp,sp,112
    80003142:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003144:	89d6                	mv	s3,s5
    80003146:	bff1                	j	80003122 <readi+0xce>
    return 0;
    80003148:	4501                	li	a0,0
}
    8000314a:	8082                	ret

000000008000314c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000314c:	457c                	lw	a5,76(a0)
    8000314e:	10d7e863          	bltu	a5,a3,8000325e <writei+0x112>
{
    80003152:	7159                	addi	sp,sp,-112
    80003154:	f486                	sd	ra,104(sp)
    80003156:	f0a2                	sd	s0,96(sp)
    80003158:	eca6                	sd	s1,88(sp)
    8000315a:	e8ca                	sd	s2,80(sp)
    8000315c:	e4ce                	sd	s3,72(sp)
    8000315e:	e0d2                	sd	s4,64(sp)
    80003160:	fc56                	sd	s5,56(sp)
    80003162:	f85a                	sd	s6,48(sp)
    80003164:	f45e                	sd	s7,40(sp)
    80003166:	f062                	sd	s8,32(sp)
    80003168:	ec66                	sd	s9,24(sp)
    8000316a:	e86a                	sd	s10,16(sp)
    8000316c:	e46e                	sd	s11,8(sp)
    8000316e:	1880                	addi	s0,sp,112
    80003170:	8aaa                	mv	s5,a0
    80003172:	8bae                	mv	s7,a1
    80003174:	8a32                	mv	s4,a2
    80003176:	8936                	mv	s2,a3
    80003178:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000317a:	00e687bb          	addw	a5,a3,a4
    8000317e:	0ed7e263          	bltu	a5,a3,80003262 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003182:	00043737          	lui	a4,0x43
    80003186:	0ef76063          	bltu	a4,a5,80003266 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000318a:	0c0b0863          	beqz	s6,8000325a <writei+0x10e>
    8000318e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003190:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003194:	5c7d                	li	s8,-1
    80003196:	a091                	j	800031da <writei+0x8e>
    80003198:	020d1d93          	slli	s11,s10,0x20
    8000319c:	020ddd93          	srli	s11,s11,0x20
    800031a0:	05848513          	addi	a0,s1,88
    800031a4:	86ee                	mv	a3,s11
    800031a6:	8652                	mv	a2,s4
    800031a8:	85de                	mv	a1,s7
    800031aa:	953a                	add	a0,a0,a4
    800031ac:	ffffe097          	auipc	ra,0xffffe
    800031b0:	7b6080e7          	jalr	1974(ra) # 80001962 <either_copyin>
    800031b4:	07850263          	beq	a0,s8,80003218 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    800031b8:	8526                	mv	a0,s1
    800031ba:	00000097          	auipc	ra,0x0
    800031be:	788080e7          	jalr	1928(ra) # 80003942 <log_write>
    brelse(bp);
    800031c2:	8526                	mv	a0,s1
    800031c4:	fffff097          	auipc	ra,0xfffff
    800031c8:	4f4080e7          	jalr	1268(ra) # 800026b8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800031cc:	013d09bb          	addw	s3,s10,s3
    800031d0:	012d093b          	addw	s2,s10,s2
    800031d4:	9a6e                	add	s4,s4,s11
    800031d6:	0569f663          	bgeu	s3,s6,80003222 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800031da:	00a9559b          	srliw	a1,s2,0xa
    800031de:	8556                	mv	a0,s5
    800031e0:	fffff097          	auipc	ra,0xfffff
    800031e4:	79c080e7          	jalr	1948(ra) # 8000297c <bmap>
    800031e8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800031ec:	c99d                	beqz	a1,80003222 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800031ee:	000aa503          	lw	a0,0(s5)
    800031f2:	fffff097          	auipc	ra,0xfffff
    800031f6:	396080e7          	jalr	918(ra) # 80002588 <bread>
    800031fa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800031fc:	3ff97713          	andi	a4,s2,1023
    80003200:	40ec87bb          	subw	a5,s9,a4
    80003204:	413b06bb          	subw	a3,s6,s3
    80003208:	8d3e                	mv	s10,a5
    8000320a:	2781                	sext.w	a5,a5
    8000320c:	0006861b          	sext.w	a2,a3
    80003210:	f8f674e3          	bgeu	a2,a5,80003198 <writei+0x4c>
    80003214:	8d36                	mv	s10,a3
    80003216:	b749                	j	80003198 <writei+0x4c>
      brelse(bp);
    80003218:	8526                	mv	a0,s1
    8000321a:	fffff097          	auipc	ra,0xfffff
    8000321e:	49e080e7          	jalr	1182(ra) # 800026b8 <brelse>
  }

  if(off > ip->size)
    80003222:	04caa783          	lw	a5,76(s5)
    80003226:	0127f463          	bgeu	a5,s2,8000322e <writei+0xe2>
    ip->size = off;
    8000322a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000322e:	8556                	mv	a0,s5
    80003230:	00000097          	auipc	ra,0x0
    80003234:	aa4080e7          	jalr	-1372(ra) # 80002cd4 <iupdate>

  return tot;
    80003238:	0009851b          	sext.w	a0,s3
}
    8000323c:	70a6                	ld	ra,104(sp)
    8000323e:	7406                	ld	s0,96(sp)
    80003240:	64e6                	ld	s1,88(sp)
    80003242:	6946                	ld	s2,80(sp)
    80003244:	69a6                	ld	s3,72(sp)
    80003246:	6a06                	ld	s4,64(sp)
    80003248:	7ae2                	ld	s5,56(sp)
    8000324a:	7b42                	ld	s6,48(sp)
    8000324c:	7ba2                	ld	s7,40(sp)
    8000324e:	7c02                	ld	s8,32(sp)
    80003250:	6ce2                	ld	s9,24(sp)
    80003252:	6d42                	ld	s10,16(sp)
    80003254:	6da2                	ld	s11,8(sp)
    80003256:	6165                	addi	sp,sp,112
    80003258:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000325a:	89da                	mv	s3,s6
    8000325c:	bfc9                	j	8000322e <writei+0xe2>
    return -1;
    8000325e:	557d                	li	a0,-1
}
    80003260:	8082                	ret
    return -1;
    80003262:	557d                	li	a0,-1
    80003264:	bfe1                	j	8000323c <writei+0xf0>
    return -1;
    80003266:	557d                	li	a0,-1
    80003268:	bfd1                	j	8000323c <writei+0xf0>

000000008000326a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000326a:	1141                	addi	sp,sp,-16
    8000326c:	e406                	sd	ra,8(sp)
    8000326e:	e022                	sd	s0,0(sp)
    80003270:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003272:	4639                	li	a2,14
    80003274:	ffffd097          	auipc	ra,0xffffd
    80003278:	fd6080e7          	jalr	-42(ra) # 8000024a <strncmp>
}
    8000327c:	60a2                	ld	ra,8(sp)
    8000327e:	6402                	ld	s0,0(sp)
    80003280:	0141                	addi	sp,sp,16
    80003282:	8082                	ret

0000000080003284 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003284:	7139                	addi	sp,sp,-64
    80003286:	fc06                	sd	ra,56(sp)
    80003288:	f822                	sd	s0,48(sp)
    8000328a:	f426                	sd	s1,40(sp)
    8000328c:	f04a                	sd	s2,32(sp)
    8000328e:	ec4e                	sd	s3,24(sp)
    80003290:	e852                	sd	s4,16(sp)
    80003292:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003294:	04451703          	lh	a4,68(a0)
    80003298:	4785                	li	a5,1
    8000329a:	00f71a63          	bne	a4,a5,800032ae <dirlookup+0x2a>
    8000329e:	892a                	mv	s2,a0
    800032a0:	89ae                	mv	s3,a1
    800032a2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800032a4:	457c                	lw	a5,76(a0)
    800032a6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800032a8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032aa:	e79d                	bnez	a5,800032d8 <dirlookup+0x54>
    800032ac:	a8a5                	j	80003324 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800032ae:	00005517          	auipc	a0,0x5
    800032b2:	2da50513          	addi	a0,a0,730 # 80008588 <syscalls+0x1b8>
    800032b6:	00003097          	auipc	ra,0x3
    800032ba:	b96080e7          	jalr	-1130(ra) # 80005e4c <panic>
      panic("dirlookup read");
    800032be:	00005517          	auipc	a0,0x5
    800032c2:	2e250513          	addi	a0,a0,738 # 800085a0 <syscalls+0x1d0>
    800032c6:	00003097          	auipc	ra,0x3
    800032ca:	b86080e7          	jalr	-1146(ra) # 80005e4c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032ce:	24c1                	addiw	s1,s1,16
    800032d0:	04c92783          	lw	a5,76(s2)
    800032d4:	04f4f763          	bgeu	s1,a5,80003322 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800032d8:	4741                	li	a4,16
    800032da:	86a6                	mv	a3,s1
    800032dc:	fc040613          	addi	a2,s0,-64
    800032e0:	4581                	li	a1,0
    800032e2:	854a                	mv	a0,s2
    800032e4:	00000097          	auipc	ra,0x0
    800032e8:	d70080e7          	jalr	-656(ra) # 80003054 <readi>
    800032ec:	47c1                	li	a5,16
    800032ee:	fcf518e3          	bne	a0,a5,800032be <dirlookup+0x3a>
    if(de.inum == 0)
    800032f2:	fc045783          	lhu	a5,-64(s0)
    800032f6:	dfe1                	beqz	a5,800032ce <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800032f8:	fc240593          	addi	a1,s0,-62
    800032fc:	854e                	mv	a0,s3
    800032fe:	00000097          	auipc	ra,0x0
    80003302:	f6c080e7          	jalr	-148(ra) # 8000326a <namecmp>
    80003306:	f561                	bnez	a0,800032ce <dirlookup+0x4a>
      if(poff)
    80003308:	000a0463          	beqz	s4,80003310 <dirlookup+0x8c>
        *poff = off;
    8000330c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003310:	fc045583          	lhu	a1,-64(s0)
    80003314:	00092503          	lw	a0,0(s2)
    80003318:	fffff097          	auipc	ra,0xfffff
    8000331c:	74e080e7          	jalr	1870(ra) # 80002a66 <iget>
    80003320:	a011                	j	80003324 <dirlookup+0xa0>
  return 0;
    80003322:	4501                	li	a0,0
}
    80003324:	70e2                	ld	ra,56(sp)
    80003326:	7442                	ld	s0,48(sp)
    80003328:	74a2                	ld	s1,40(sp)
    8000332a:	7902                	ld	s2,32(sp)
    8000332c:	69e2                	ld	s3,24(sp)
    8000332e:	6a42                	ld	s4,16(sp)
    80003330:	6121                	addi	sp,sp,64
    80003332:	8082                	ret

0000000080003334 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003334:	711d                	addi	sp,sp,-96
    80003336:	ec86                	sd	ra,88(sp)
    80003338:	e8a2                	sd	s0,80(sp)
    8000333a:	e4a6                	sd	s1,72(sp)
    8000333c:	e0ca                	sd	s2,64(sp)
    8000333e:	fc4e                	sd	s3,56(sp)
    80003340:	f852                	sd	s4,48(sp)
    80003342:	f456                	sd	s5,40(sp)
    80003344:	f05a                	sd	s6,32(sp)
    80003346:	ec5e                	sd	s7,24(sp)
    80003348:	e862                	sd	s8,16(sp)
    8000334a:	e466                	sd	s9,8(sp)
    8000334c:	e06a                	sd	s10,0(sp)
    8000334e:	1080                	addi	s0,sp,96
    80003350:	84aa                	mv	s1,a0
    80003352:	8b2e                	mv	s6,a1
    80003354:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003356:	00054703          	lbu	a4,0(a0)
    8000335a:	02f00793          	li	a5,47
    8000335e:	02f70363          	beq	a4,a5,80003384 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003362:	ffffe097          	auipc	ra,0xffffe
    80003366:	af2080e7          	jalr	-1294(ra) # 80000e54 <myproc>
    8000336a:	15053503          	ld	a0,336(a0)
    8000336e:	00000097          	auipc	ra,0x0
    80003372:	9f4080e7          	jalr	-1548(ra) # 80002d62 <idup>
    80003376:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003378:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000337c:	4cb5                	li	s9,13
  len = path - s;
    8000337e:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003380:	4c05                	li	s8,1
    80003382:	a87d                	j	80003440 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003384:	4585                	li	a1,1
    80003386:	4505                	li	a0,1
    80003388:	fffff097          	auipc	ra,0xfffff
    8000338c:	6de080e7          	jalr	1758(ra) # 80002a66 <iget>
    80003390:	8a2a                	mv	s4,a0
    80003392:	b7dd                	j	80003378 <namex+0x44>
      iunlockput(ip);
    80003394:	8552                	mv	a0,s4
    80003396:	00000097          	auipc	ra,0x0
    8000339a:	c6c080e7          	jalr	-916(ra) # 80003002 <iunlockput>
      return 0;
    8000339e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800033a0:	8552                	mv	a0,s4
    800033a2:	60e6                	ld	ra,88(sp)
    800033a4:	6446                	ld	s0,80(sp)
    800033a6:	64a6                	ld	s1,72(sp)
    800033a8:	6906                	ld	s2,64(sp)
    800033aa:	79e2                	ld	s3,56(sp)
    800033ac:	7a42                	ld	s4,48(sp)
    800033ae:	7aa2                	ld	s5,40(sp)
    800033b0:	7b02                	ld	s6,32(sp)
    800033b2:	6be2                	ld	s7,24(sp)
    800033b4:	6c42                	ld	s8,16(sp)
    800033b6:	6ca2                	ld	s9,8(sp)
    800033b8:	6d02                	ld	s10,0(sp)
    800033ba:	6125                	addi	sp,sp,96
    800033bc:	8082                	ret
      iunlock(ip);
    800033be:	8552                	mv	a0,s4
    800033c0:	00000097          	auipc	ra,0x0
    800033c4:	aa2080e7          	jalr	-1374(ra) # 80002e62 <iunlock>
      return ip;
    800033c8:	bfe1                	j	800033a0 <namex+0x6c>
      iunlockput(ip);
    800033ca:	8552                	mv	a0,s4
    800033cc:	00000097          	auipc	ra,0x0
    800033d0:	c36080e7          	jalr	-970(ra) # 80003002 <iunlockput>
      return 0;
    800033d4:	8a4e                	mv	s4,s3
    800033d6:	b7e9                	j	800033a0 <namex+0x6c>
  len = path - s;
    800033d8:	40998633          	sub	a2,s3,s1
    800033dc:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800033e0:	09acd863          	bge	s9,s10,80003470 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800033e4:	4639                	li	a2,14
    800033e6:	85a6                	mv	a1,s1
    800033e8:	8556                	mv	a0,s5
    800033ea:	ffffd097          	auipc	ra,0xffffd
    800033ee:	dec080e7          	jalr	-532(ra) # 800001d6 <memmove>
    800033f2:	84ce                	mv	s1,s3
  while(*path == '/')
    800033f4:	0004c783          	lbu	a5,0(s1)
    800033f8:	01279763          	bne	a5,s2,80003406 <namex+0xd2>
    path++;
    800033fc:	0485                	addi	s1,s1,1
  while(*path == '/')
    800033fe:	0004c783          	lbu	a5,0(s1)
    80003402:	ff278de3          	beq	a5,s2,800033fc <namex+0xc8>
    ilock(ip);
    80003406:	8552                	mv	a0,s4
    80003408:	00000097          	auipc	ra,0x0
    8000340c:	998080e7          	jalr	-1640(ra) # 80002da0 <ilock>
    if(ip->type != T_DIR){
    80003410:	044a1783          	lh	a5,68(s4)
    80003414:	f98790e3          	bne	a5,s8,80003394 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003418:	000b0563          	beqz	s6,80003422 <namex+0xee>
    8000341c:	0004c783          	lbu	a5,0(s1)
    80003420:	dfd9                	beqz	a5,800033be <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003422:	865e                	mv	a2,s7
    80003424:	85d6                	mv	a1,s5
    80003426:	8552                	mv	a0,s4
    80003428:	00000097          	auipc	ra,0x0
    8000342c:	e5c080e7          	jalr	-420(ra) # 80003284 <dirlookup>
    80003430:	89aa                	mv	s3,a0
    80003432:	dd41                	beqz	a0,800033ca <namex+0x96>
    iunlockput(ip);
    80003434:	8552                	mv	a0,s4
    80003436:	00000097          	auipc	ra,0x0
    8000343a:	bcc080e7          	jalr	-1076(ra) # 80003002 <iunlockput>
    ip = next;
    8000343e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003440:	0004c783          	lbu	a5,0(s1)
    80003444:	01279763          	bne	a5,s2,80003452 <namex+0x11e>
    path++;
    80003448:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000344a:	0004c783          	lbu	a5,0(s1)
    8000344e:	ff278de3          	beq	a5,s2,80003448 <namex+0x114>
  if(*path == 0)
    80003452:	cb9d                	beqz	a5,80003488 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003454:	0004c783          	lbu	a5,0(s1)
    80003458:	89a6                	mv	s3,s1
  len = path - s;
    8000345a:	8d5e                	mv	s10,s7
    8000345c:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    8000345e:	01278963          	beq	a5,s2,80003470 <namex+0x13c>
    80003462:	dbbd                	beqz	a5,800033d8 <namex+0xa4>
    path++;
    80003464:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003466:	0009c783          	lbu	a5,0(s3)
    8000346a:	ff279ce3          	bne	a5,s2,80003462 <namex+0x12e>
    8000346e:	b7ad                	j	800033d8 <namex+0xa4>
    memmove(name, s, len);
    80003470:	2601                	sext.w	a2,a2
    80003472:	85a6                	mv	a1,s1
    80003474:	8556                	mv	a0,s5
    80003476:	ffffd097          	auipc	ra,0xffffd
    8000347a:	d60080e7          	jalr	-672(ra) # 800001d6 <memmove>
    name[len] = 0;
    8000347e:	9d56                	add	s10,s10,s5
    80003480:	000d0023          	sb	zero,0(s10)
    80003484:	84ce                	mv	s1,s3
    80003486:	b7bd                	j	800033f4 <namex+0xc0>
  if(nameiparent){
    80003488:	f00b0ce3          	beqz	s6,800033a0 <namex+0x6c>
    iput(ip);
    8000348c:	8552                	mv	a0,s4
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	acc080e7          	jalr	-1332(ra) # 80002f5a <iput>
    return 0;
    80003496:	4a01                	li	s4,0
    80003498:	b721                	j	800033a0 <namex+0x6c>

000000008000349a <dirlink>:
{
    8000349a:	7139                	addi	sp,sp,-64
    8000349c:	fc06                	sd	ra,56(sp)
    8000349e:	f822                	sd	s0,48(sp)
    800034a0:	f426                	sd	s1,40(sp)
    800034a2:	f04a                	sd	s2,32(sp)
    800034a4:	ec4e                	sd	s3,24(sp)
    800034a6:	e852                	sd	s4,16(sp)
    800034a8:	0080                	addi	s0,sp,64
    800034aa:	892a                	mv	s2,a0
    800034ac:	8a2e                	mv	s4,a1
    800034ae:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800034b0:	4601                	li	a2,0
    800034b2:	00000097          	auipc	ra,0x0
    800034b6:	dd2080e7          	jalr	-558(ra) # 80003284 <dirlookup>
    800034ba:	e93d                	bnez	a0,80003530 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800034bc:	04c92483          	lw	s1,76(s2)
    800034c0:	c49d                	beqz	s1,800034ee <dirlink+0x54>
    800034c2:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800034c4:	4741                	li	a4,16
    800034c6:	86a6                	mv	a3,s1
    800034c8:	fc040613          	addi	a2,s0,-64
    800034cc:	4581                	li	a1,0
    800034ce:	854a                	mv	a0,s2
    800034d0:	00000097          	auipc	ra,0x0
    800034d4:	b84080e7          	jalr	-1148(ra) # 80003054 <readi>
    800034d8:	47c1                	li	a5,16
    800034da:	06f51163          	bne	a0,a5,8000353c <dirlink+0xa2>
    if(de.inum == 0)
    800034de:	fc045783          	lhu	a5,-64(s0)
    800034e2:	c791                	beqz	a5,800034ee <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800034e4:	24c1                	addiw	s1,s1,16
    800034e6:	04c92783          	lw	a5,76(s2)
    800034ea:	fcf4ede3          	bltu	s1,a5,800034c4 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800034ee:	4639                	li	a2,14
    800034f0:	85d2                	mv	a1,s4
    800034f2:	fc240513          	addi	a0,s0,-62
    800034f6:	ffffd097          	auipc	ra,0xffffd
    800034fa:	d90080e7          	jalr	-624(ra) # 80000286 <strncpy>
  de.inum = inum;
    800034fe:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003502:	4741                	li	a4,16
    80003504:	86a6                	mv	a3,s1
    80003506:	fc040613          	addi	a2,s0,-64
    8000350a:	4581                	li	a1,0
    8000350c:	854a                	mv	a0,s2
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	c3e080e7          	jalr	-962(ra) # 8000314c <writei>
    80003516:	1541                	addi	a0,a0,-16
    80003518:	00a03533          	snez	a0,a0
    8000351c:	40a00533          	neg	a0,a0
}
    80003520:	70e2                	ld	ra,56(sp)
    80003522:	7442                	ld	s0,48(sp)
    80003524:	74a2                	ld	s1,40(sp)
    80003526:	7902                	ld	s2,32(sp)
    80003528:	69e2                	ld	s3,24(sp)
    8000352a:	6a42                	ld	s4,16(sp)
    8000352c:	6121                	addi	sp,sp,64
    8000352e:	8082                	ret
    iput(ip);
    80003530:	00000097          	auipc	ra,0x0
    80003534:	a2a080e7          	jalr	-1494(ra) # 80002f5a <iput>
    return -1;
    80003538:	557d                	li	a0,-1
    8000353a:	b7dd                	j	80003520 <dirlink+0x86>
      panic("dirlink read");
    8000353c:	00005517          	auipc	a0,0x5
    80003540:	07450513          	addi	a0,a0,116 # 800085b0 <syscalls+0x1e0>
    80003544:	00003097          	auipc	ra,0x3
    80003548:	908080e7          	jalr	-1784(ra) # 80005e4c <panic>

000000008000354c <namei>:

struct inode*
namei(char *path)
{
    8000354c:	1101                	addi	sp,sp,-32
    8000354e:	ec06                	sd	ra,24(sp)
    80003550:	e822                	sd	s0,16(sp)
    80003552:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003554:	fe040613          	addi	a2,s0,-32
    80003558:	4581                	li	a1,0
    8000355a:	00000097          	auipc	ra,0x0
    8000355e:	dda080e7          	jalr	-550(ra) # 80003334 <namex>
}
    80003562:	60e2                	ld	ra,24(sp)
    80003564:	6442                	ld	s0,16(sp)
    80003566:	6105                	addi	sp,sp,32
    80003568:	8082                	ret

000000008000356a <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000356a:	1141                	addi	sp,sp,-16
    8000356c:	e406                	sd	ra,8(sp)
    8000356e:	e022                	sd	s0,0(sp)
    80003570:	0800                	addi	s0,sp,16
    80003572:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003574:	4585                	li	a1,1
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	dbe080e7          	jalr	-578(ra) # 80003334 <namex>
}
    8000357e:	60a2                	ld	ra,8(sp)
    80003580:	6402                	ld	s0,0(sp)
    80003582:	0141                	addi	sp,sp,16
    80003584:	8082                	ret

0000000080003586 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003586:	1101                	addi	sp,sp,-32
    80003588:	ec06                	sd	ra,24(sp)
    8000358a:	e822                	sd	s0,16(sp)
    8000358c:	e426                	sd	s1,8(sp)
    8000358e:	e04a                	sd	s2,0(sp)
    80003590:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003592:	0001a917          	auipc	s2,0x1a
    80003596:	95e90913          	addi	s2,s2,-1698 # 8001cef0 <log>
    8000359a:	01892583          	lw	a1,24(s2)
    8000359e:	02892503          	lw	a0,40(s2)
    800035a2:	fffff097          	auipc	ra,0xfffff
    800035a6:	fe6080e7          	jalr	-26(ra) # 80002588 <bread>
    800035aa:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800035ac:	02c92683          	lw	a3,44(s2)
    800035b0:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800035b2:	02d05863          	blez	a3,800035e2 <write_head+0x5c>
    800035b6:	0001a797          	auipc	a5,0x1a
    800035ba:	96a78793          	addi	a5,a5,-1686 # 8001cf20 <log+0x30>
    800035be:	05c50713          	addi	a4,a0,92
    800035c2:	36fd                	addiw	a3,a3,-1
    800035c4:	02069613          	slli	a2,a3,0x20
    800035c8:	01e65693          	srli	a3,a2,0x1e
    800035cc:	0001a617          	auipc	a2,0x1a
    800035d0:	95860613          	addi	a2,a2,-1704 # 8001cf24 <log+0x34>
    800035d4:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800035d6:	4390                	lw	a2,0(a5)
    800035d8:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800035da:	0791                	addi	a5,a5,4
    800035dc:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800035de:	fed79ce3          	bne	a5,a3,800035d6 <write_head+0x50>
  }
  bwrite(buf);
    800035e2:	8526                	mv	a0,s1
    800035e4:	fffff097          	auipc	ra,0xfffff
    800035e8:	096080e7          	jalr	150(ra) # 8000267a <bwrite>
  brelse(buf);
    800035ec:	8526                	mv	a0,s1
    800035ee:	fffff097          	auipc	ra,0xfffff
    800035f2:	0ca080e7          	jalr	202(ra) # 800026b8 <brelse>
}
    800035f6:	60e2                	ld	ra,24(sp)
    800035f8:	6442                	ld	s0,16(sp)
    800035fa:	64a2                	ld	s1,8(sp)
    800035fc:	6902                	ld	s2,0(sp)
    800035fe:	6105                	addi	sp,sp,32
    80003600:	8082                	ret

0000000080003602 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003602:	0001a797          	auipc	a5,0x1a
    80003606:	91a7a783          	lw	a5,-1766(a5) # 8001cf1c <log+0x2c>
    8000360a:	0af05d63          	blez	a5,800036c4 <install_trans+0xc2>
{
    8000360e:	7139                	addi	sp,sp,-64
    80003610:	fc06                	sd	ra,56(sp)
    80003612:	f822                	sd	s0,48(sp)
    80003614:	f426                	sd	s1,40(sp)
    80003616:	f04a                	sd	s2,32(sp)
    80003618:	ec4e                	sd	s3,24(sp)
    8000361a:	e852                	sd	s4,16(sp)
    8000361c:	e456                	sd	s5,8(sp)
    8000361e:	e05a                	sd	s6,0(sp)
    80003620:	0080                	addi	s0,sp,64
    80003622:	8b2a                	mv	s6,a0
    80003624:	0001aa97          	auipc	s5,0x1a
    80003628:	8fca8a93          	addi	s5,s5,-1796 # 8001cf20 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000362c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000362e:	0001a997          	auipc	s3,0x1a
    80003632:	8c298993          	addi	s3,s3,-1854 # 8001cef0 <log>
    80003636:	a00d                	j	80003658 <install_trans+0x56>
    brelse(lbuf);
    80003638:	854a                	mv	a0,s2
    8000363a:	fffff097          	auipc	ra,0xfffff
    8000363e:	07e080e7          	jalr	126(ra) # 800026b8 <brelse>
    brelse(dbuf);
    80003642:	8526                	mv	a0,s1
    80003644:	fffff097          	auipc	ra,0xfffff
    80003648:	074080e7          	jalr	116(ra) # 800026b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000364c:	2a05                	addiw	s4,s4,1
    8000364e:	0a91                	addi	s5,s5,4
    80003650:	02c9a783          	lw	a5,44(s3)
    80003654:	04fa5e63          	bge	s4,a5,800036b0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003658:	0189a583          	lw	a1,24(s3)
    8000365c:	014585bb          	addw	a1,a1,s4
    80003660:	2585                	addiw	a1,a1,1
    80003662:	0289a503          	lw	a0,40(s3)
    80003666:	fffff097          	auipc	ra,0xfffff
    8000366a:	f22080e7          	jalr	-222(ra) # 80002588 <bread>
    8000366e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003670:	000aa583          	lw	a1,0(s5)
    80003674:	0289a503          	lw	a0,40(s3)
    80003678:	fffff097          	auipc	ra,0xfffff
    8000367c:	f10080e7          	jalr	-240(ra) # 80002588 <bread>
    80003680:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003682:	40000613          	li	a2,1024
    80003686:	05890593          	addi	a1,s2,88
    8000368a:	05850513          	addi	a0,a0,88
    8000368e:	ffffd097          	auipc	ra,0xffffd
    80003692:	b48080e7          	jalr	-1208(ra) # 800001d6 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003696:	8526                	mv	a0,s1
    80003698:	fffff097          	auipc	ra,0xfffff
    8000369c:	fe2080e7          	jalr	-30(ra) # 8000267a <bwrite>
    if(recovering == 0)
    800036a0:	f80b1ce3          	bnez	s6,80003638 <install_trans+0x36>
      bunpin(dbuf);
    800036a4:	8526                	mv	a0,s1
    800036a6:	fffff097          	auipc	ra,0xfffff
    800036aa:	0ec080e7          	jalr	236(ra) # 80002792 <bunpin>
    800036ae:	b769                	j	80003638 <install_trans+0x36>
}
    800036b0:	70e2                	ld	ra,56(sp)
    800036b2:	7442                	ld	s0,48(sp)
    800036b4:	74a2                	ld	s1,40(sp)
    800036b6:	7902                	ld	s2,32(sp)
    800036b8:	69e2                	ld	s3,24(sp)
    800036ba:	6a42                	ld	s4,16(sp)
    800036bc:	6aa2                	ld	s5,8(sp)
    800036be:	6b02                	ld	s6,0(sp)
    800036c0:	6121                	addi	sp,sp,64
    800036c2:	8082                	ret
    800036c4:	8082                	ret

00000000800036c6 <initlog>:
{
    800036c6:	7179                	addi	sp,sp,-48
    800036c8:	f406                	sd	ra,40(sp)
    800036ca:	f022                	sd	s0,32(sp)
    800036cc:	ec26                	sd	s1,24(sp)
    800036ce:	e84a                	sd	s2,16(sp)
    800036d0:	e44e                	sd	s3,8(sp)
    800036d2:	1800                	addi	s0,sp,48
    800036d4:	892a                	mv	s2,a0
    800036d6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800036d8:	0001a497          	auipc	s1,0x1a
    800036dc:	81848493          	addi	s1,s1,-2024 # 8001cef0 <log>
    800036e0:	00005597          	auipc	a1,0x5
    800036e4:	ee058593          	addi	a1,a1,-288 # 800085c0 <syscalls+0x1f0>
    800036e8:	8526                	mv	a0,s1
    800036ea:	00003097          	auipc	ra,0x3
    800036ee:	c0a080e7          	jalr	-1014(ra) # 800062f4 <initlock>
  log.start = sb->logstart;
    800036f2:	0149a583          	lw	a1,20(s3)
    800036f6:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800036f8:	0109a783          	lw	a5,16(s3)
    800036fc:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800036fe:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003702:	854a                	mv	a0,s2
    80003704:	fffff097          	auipc	ra,0xfffff
    80003708:	e84080e7          	jalr	-380(ra) # 80002588 <bread>
  log.lh.n = lh->n;
    8000370c:	4d34                	lw	a3,88(a0)
    8000370e:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003710:	02d05663          	blez	a3,8000373c <initlog+0x76>
    80003714:	05c50793          	addi	a5,a0,92
    80003718:	0001a717          	auipc	a4,0x1a
    8000371c:	80870713          	addi	a4,a4,-2040 # 8001cf20 <log+0x30>
    80003720:	36fd                	addiw	a3,a3,-1
    80003722:	02069613          	slli	a2,a3,0x20
    80003726:	01e65693          	srli	a3,a2,0x1e
    8000372a:	06050613          	addi	a2,a0,96
    8000372e:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    80003730:	4390                	lw	a2,0(a5)
    80003732:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003734:	0791                	addi	a5,a5,4
    80003736:	0711                	addi	a4,a4,4
    80003738:	fed79ce3          	bne	a5,a3,80003730 <initlog+0x6a>
  brelse(buf);
    8000373c:	fffff097          	auipc	ra,0xfffff
    80003740:	f7c080e7          	jalr	-132(ra) # 800026b8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003744:	4505                	li	a0,1
    80003746:	00000097          	auipc	ra,0x0
    8000374a:	ebc080e7          	jalr	-324(ra) # 80003602 <install_trans>
  log.lh.n = 0;
    8000374e:	00019797          	auipc	a5,0x19
    80003752:	7c07a723          	sw	zero,1998(a5) # 8001cf1c <log+0x2c>
  write_head(); // clear the log
    80003756:	00000097          	auipc	ra,0x0
    8000375a:	e30080e7          	jalr	-464(ra) # 80003586 <write_head>
}
    8000375e:	70a2                	ld	ra,40(sp)
    80003760:	7402                	ld	s0,32(sp)
    80003762:	64e2                	ld	s1,24(sp)
    80003764:	6942                	ld	s2,16(sp)
    80003766:	69a2                	ld	s3,8(sp)
    80003768:	6145                	addi	sp,sp,48
    8000376a:	8082                	ret

000000008000376c <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000376c:	1101                	addi	sp,sp,-32
    8000376e:	ec06                	sd	ra,24(sp)
    80003770:	e822                	sd	s0,16(sp)
    80003772:	e426                	sd	s1,8(sp)
    80003774:	e04a                	sd	s2,0(sp)
    80003776:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003778:	00019517          	auipc	a0,0x19
    8000377c:	77850513          	addi	a0,a0,1912 # 8001cef0 <log>
    80003780:	00003097          	auipc	ra,0x3
    80003784:	c04080e7          	jalr	-1020(ra) # 80006384 <acquire>
  while(1){
    if(log.committing){
    80003788:	00019497          	auipc	s1,0x19
    8000378c:	76848493          	addi	s1,s1,1896 # 8001cef0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003790:	4979                	li	s2,30
    80003792:	a039                	j	800037a0 <begin_op+0x34>
      sleep(&log, &log.lock);
    80003794:	85a6                	mv	a1,s1
    80003796:	8526                	mv	a0,s1
    80003798:	ffffe097          	auipc	ra,0xffffe
    8000379c:	d6c080e7          	jalr	-660(ra) # 80001504 <sleep>
    if(log.committing){
    800037a0:	50dc                	lw	a5,36(s1)
    800037a2:	fbed                	bnez	a5,80003794 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800037a4:	5098                	lw	a4,32(s1)
    800037a6:	2705                	addiw	a4,a4,1
    800037a8:	0007069b          	sext.w	a3,a4
    800037ac:	0027179b          	slliw	a5,a4,0x2
    800037b0:	9fb9                	addw	a5,a5,a4
    800037b2:	0017979b          	slliw	a5,a5,0x1
    800037b6:	54d8                	lw	a4,44(s1)
    800037b8:	9fb9                	addw	a5,a5,a4
    800037ba:	00f95963          	bge	s2,a5,800037cc <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800037be:	85a6                	mv	a1,s1
    800037c0:	8526                	mv	a0,s1
    800037c2:	ffffe097          	auipc	ra,0xffffe
    800037c6:	d42080e7          	jalr	-702(ra) # 80001504 <sleep>
    800037ca:	bfd9                	j	800037a0 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800037cc:	00019517          	auipc	a0,0x19
    800037d0:	72450513          	addi	a0,a0,1828 # 8001cef0 <log>
    800037d4:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800037d6:	00003097          	auipc	ra,0x3
    800037da:	c62080e7          	jalr	-926(ra) # 80006438 <release>
      break;
    }
  }
}
    800037de:	60e2                	ld	ra,24(sp)
    800037e0:	6442                	ld	s0,16(sp)
    800037e2:	64a2                	ld	s1,8(sp)
    800037e4:	6902                	ld	s2,0(sp)
    800037e6:	6105                	addi	sp,sp,32
    800037e8:	8082                	ret

00000000800037ea <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800037ea:	7139                	addi	sp,sp,-64
    800037ec:	fc06                	sd	ra,56(sp)
    800037ee:	f822                	sd	s0,48(sp)
    800037f0:	f426                	sd	s1,40(sp)
    800037f2:	f04a                	sd	s2,32(sp)
    800037f4:	ec4e                	sd	s3,24(sp)
    800037f6:	e852                	sd	s4,16(sp)
    800037f8:	e456                	sd	s5,8(sp)
    800037fa:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800037fc:	00019497          	auipc	s1,0x19
    80003800:	6f448493          	addi	s1,s1,1780 # 8001cef0 <log>
    80003804:	8526                	mv	a0,s1
    80003806:	00003097          	auipc	ra,0x3
    8000380a:	b7e080e7          	jalr	-1154(ra) # 80006384 <acquire>
  log.outstanding -= 1;
    8000380e:	509c                	lw	a5,32(s1)
    80003810:	37fd                	addiw	a5,a5,-1
    80003812:	0007891b          	sext.w	s2,a5
    80003816:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003818:	50dc                	lw	a5,36(s1)
    8000381a:	e7b9                	bnez	a5,80003868 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000381c:	04091e63          	bnez	s2,80003878 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80003820:	00019497          	auipc	s1,0x19
    80003824:	6d048493          	addi	s1,s1,1744 # 8001cef0 <log>
    80003828:	4785                	li	a5,1
    8000382a:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000382c:	8526                	mv	a0,s1
    8000382e:	00003097          	auipc	ra,0x3
    80003832:	c0a080e7          	jalr	-1014(ra) # 80006438 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003836:	54dc                	lw	a5,44(s1)
    80003838:	06f04763          	bgtz	a5,800038a6 <end_op+0xbc>
    acquire(&log.lock);
    8000383c:	00019497          	auipc	s1,0x19
    80003840:	6b448493          	addi	s1,s1,1716 # 8001cef0 <log>
    80003844:	8526                	mv	a0,s1
    80003846:	00003097          	auipc	ra,0x3
    8000384a:	b3e080e7          	jalr	-1218(ra) # 80006384 <acquire>
    log.committing = 0;
    8000384e:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003852:	8526                	mv	a0,s1
    80003854:	ffffe097          	auipc	ra,0xffffe
    80003858:	d14080e7          	jalr	-748(ra) # 80001568 <wakeup>
    release(&log.lock);
    8000385c:	8526                	mv	a0,s1
    8000385e:	00003097          	auipc	ra,0x3
    80003862:	bda080e7          	jalr	-1062(ra) # 80006438 <release>
}
    80003866:	a03d                	j	80003894 <end_op+0xaa>
    panic("log.committing");
    80003868:	00005517          	auipc	a0,0x5
    8000386c:	d6050513          	addi	a0,a0,-672 # 800085c8 <syscalls+0x1f8>
    80003870:	00002097          	auipc	ra,0x2
    80003874:	5dc080e7          	jalr	1500(ra) # 80005e4c <panic>
    wakeup(&log);
    80003878:	00019497          	auipc	s1,0x19
    8000387c:	67848493          	addi	s1,s1,1656 # 8001cef0 <log>
    80003880:	8526                	mv	a0,s1
    80003882:	ffffe097          	auipc	ra,0xffffe
    80003886:	ce6080e7          	jalr	-794(ra) # 80001568 <wakeup>
  release(&log.lock);
    8000388a:	8526                	mv	a0,s1
    8000388c:	00003097          	auipc	ra,0x3
    80003890:	bac080e7          	jalr	-1108(ra) # 80006438 <release>
}
    80003894:	70e2                	ld	ra,56(sp)
    80003896:	7442                	ld	s0,48(sp)
    80003898:	74a2                	ld	s1,40(sp)
    8000389a:	7902                	ld	s2,32(sp)
    8000389c:	69e2                	ld	s3,24(sp)
    8000389e:	6a42                	ld	s4,16(sp)
    800038a0:	6aa2                	ld	s5,8(sp)
    800038a2:	6121                	addi	sp,sp,64
    800038a4:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800038a6:	00019a97          	auipc	s5,0x19
    800038aa:	67aa8a93          	addi	s5,s5,1658 # 8001cf20 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800038ae:	00019a17          	auipc	s4,0x19
    800038b2:	642a0a13          	addi	s4,s4,1602 # 8001cef0 <log>
    800038b6:	018a2583          	lw	a1,24(s4)
    800038ba:	012585bb          	addw	a1,a1,s2
    800038be:	2585                	addiw	a1,a1,1
    800038c0:	028a2503          	lw	a0,40(s4)
    800038c4:	fffff097          	auipc	ra,0xfffff
    800038c8:	cc4080e7          	jalr	-828(ra) # 80002588 <bread>
    800038cc:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800038ce:	000aa583          	lw	a1,0(s5)
    800038d2:	028a2503          	lw	a0,40(s4)
    800038d6:	fffff097          	auipc	ra,0xfffff
    800038da:	cb2080e7          	jalr	-846(ra) # 80002588 <bread>
    800038de:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800038e0:	40000613          	li	a2,1024
    800038e4:	05850593          	addi	a1,a0,88
    800038e8:	05848513          	addi	a0,s1,88
    800038ec:	ffffd097          	auipc	ra,0xffffd
    800038f0:	8ea080e7          	jalr	-1814(ra) # 800001d6 <memmove>
    bwrite(to);  // write the log
    800038f4:	8526                	mv	a0,s1
    800038f6:	fffff097          	auipc	ra,0xfffff
    800038fa:	d84080e7          	jalr	-636(ra) # 8000267a <bwrite>
    brelse(from);
    800038fe:	854e                	mv	a0,s3
    80003900:	fffff097          	auipc	ra,0xfffff
    80003904:	db8080e7          	jalr	-584(ra) # 800026b8 <brelse>
    brelse(to);
    80003908:	8526                	mv	a0,s1
    8000390a:	fffff097          	auipc	ra,0xfffff
    8000390e:	dae080e7          	jalr	-594(ra) # 800026b8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003912:	2905                	addiw	s2,s2,1
    80003914:	0a91                	addi	s5,s5,4
    80003916:	02ca2783          	lw	a5,44(s4)
    8000391a:	f8f94ee3          	blt	s2,a5,800038b6 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000391e:	00000097          	auipc	ra,0x0
    80003922:	c68080e7          	jalr	-920(ra) # 80003586 <write_head>
    install_trans(0); // Now install writes to home locations
    80003926:	4501                	li	a0,0
    80003928:	00000097          	auipc	ra,0x0
    8000392c:	cda080e7          	jalr	-806(ra) # 80003602 <install_trans>
    log.lh.n = 0;
    80003930:	00019797          	auipc	a5,0x19
    80003934:	5e07a623          	sw	zero,1516(a5) # 8001cf1c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003938:	00000097          	auipc	ra,0x0
    8000393c:	c4e080e7          	jalr	-946(ra) # 80003586 <write_head>
    80003940:	bdf5                	j	8000383c <end_op+0x52>

0000000080003942 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003942:	1101                	addi	sp,sp,-32
    80003944:	ec06                	sd	ra,24(sp)
    80003946:	e822                	sd	s0,16(sp)
    80003948:	e426                	sd	s1,8(sp)
    8000394a:	e04a                	sd	s2,0(sp)
    8000394c:	1000                	addi	s0,sp,32
    8000394e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003950:	00019917          	auipc	s2,0x19
    80003954:	5a090913          	addi	s2,s2,1440 # 8001cef0 <log>
    80003958:	854a                	mv	a0,s2
    8000395a:	00003097          	auipc	ra,0x3
    8000395e:	a2a080e7          	jalr	-1494(ra) # 80006384 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003962:	02c92603          	lw	a2,44(s2)
    80003966:	47f5                	li	a5,29
    80003968:	06c7c563          	blt	a5,a2,800039d2 <log_write+0x90>
    8000396c:	00019797          	auipc	a5,0x19
    80003970:	5a07a783          	lw	a5,1440(a5) # 8001cf0c <log+0x1c>
    80003974:	37fd                	addiw	a5,a5,-1
    80003976:	04f65e63          	bge	a2,a5,800039d2 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000397a:	00019797          	auipc	a5,0x19
    8000397e:	5967a783          	lw	a5,1430(a5) # 8001cf10 <log+0x20>
    80003982:	06f05063          	blez	a5,800039e2 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003986:	4781                	li	a5,0
    80003988:	06c05563          	blez	a2,800039f2 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000398c:	44cc                	lw	a1,12(s1)
    8000398e:	00019717          	auipc	a4,0x19
    80003992:	59270713          	addi	a4,a4,1426 # 8001cf20 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003996:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003998:	4314                	lw	a3,0(a4)
    8000399a:	04b68c63          	beq	a3,a1,800039f2 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000399e:	2785                	addiw	a5,a5,1
    800039a0:	0711                	addi	a4,a4,4
    800039a2:	fef61be3          	bne	a2,a5,80003998 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800039a6:	0621                	addi	a2,a2,8
    800039a8:	060a                	slli	a2,a2,0x2
    800039aa:	00019797          	auipc	a5,0x19
    800039ae:	54678793          	addi	a5,a5,1350 # 8001cef0 <log>
    800039b2:	97b2                	add	a5,a5,a2
    800039b4:	44d8                	lw	a4,12(s1)
    800039b6:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800039b8:	8526                	mv	a0,s1
    800039ba:	fffff097          	auipc	ra,0xfffff
    800039be:	d9c080e7          	jalr	-612(ra) # 80002756 <bpin>
    log.lh.n++;
    800039c2:	00019717          	auipc	a4,0x19
    800039c6:	52e70713          	addi	a4,a4,1326 # 8001cef0 <log>
    800039ca:	575c                	lw	a5,44(a4)
    800039cc:	2785                	addiw	a5,a5,1
    800039ce:	d75c                	sw	a5,44(a4)
    800039d0:	a82d                	j	80003a0a <log_write+0xc8>
    panic("too big a transaction");
    800039d2:	00005517          	auipc	a0,0x5
    800039d6:	c0650513          	addi	a0,a0,-1018 # 800085d8 <syscalls+0x208>
    800039da:	00002097          	auipc	ra,0x2
    800039de:	472080e7          	jalr	1138(ra) # 80005e4c <panic>
    panic("log_write outside of trans");
    800039e2:	00005517          	auipc	a0,0x5
    800039e6:	c0e50513          	addi	a0,a0,-1010 # 800085f0 <syscalls+0x220>
    800039ea:	00002097          	auipc	ra,0x2
    800039ee:	462080e7          	jalr	1122(ra) # 80005e4c <panic>
  log.lh.block[i] = b->blockno;
    800039f2:	00878693          	addi	a3,a5,8
    800039f6:	068a                	slli	a3,a3,0x2
    800039f8:	00019717          	auipc	a4,0x19
    800039fc:	4f870713          	addi	a4,a4,1272 # 8001cef0 <log>
    80003a00:	9736                	add	a4,a4,a3
    80003a02:	44d4                	lw	a3,12(s1)
    80003a04:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003a06:	faf609e3          	beq	a2,a5,800039b8 <log_write+0x76>
  }
  release(&log.lock);
    80003a0a:	00019517          	auipc	a0,0x19
    80003a0e:	4e650513          	addi	a0,a0,1254 # 8001cef0 <log>
    80003a12:	00003097          	auipc	ra,0x3
    80003a16:	a26080e7          	jalr	-1498(ra) # 80006438 <release>
}
    80003a1a:	60e2                	ld	ra,24(sp)
    80003a1c:	6442                	ld	s0,16(sp)
    80003a1e:	64a2                	ld	s1,8(sp)
    80003a20:	6902                	ld	s2,0(sp)
    80003a22:	6105                	addi	sp,sp,32
    80003a24:	8082                	ret

0000000080003a26 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003a26:	1101                	addi	sp,sp,-32
    80003a28:	ec06                	sd	ra,24(sp)
    80003a2a:	e822                	sd	s0,16(sp)
    80003a2c:	e426                	sd	s1,8(sp)
    80003a2e:	e04a                	sd	s2,0(sp)
    80003a30:	1000                	addi	s0,sp,32
    80003a32:	84aa                	mv	s1,a0
    80003a34:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003a36:	00005597          	auipc	a1,0x5
    80003a3a:	bda58593          	addi	a1,a1,-1062 # 80008610 <syscalls+0x240>
    80003a3e:	0521                	addi	a0,a0,8
    80003a40:	00003097          	auipc	ra,0x3
    80003a44:	8b4080e7          	jalr	-1868(ra) # 800062f4 <initlock>
  lk->name = name;
    80003a48:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003a4c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003a50:	0204a423          	sw	zero,40(s1)
}
    80003a54:	60e2                	ld	ra,24(sp)
    80003a56:	6442                	ld	s0,16(sp)
    80003a58:	64a2                	ld	s1,8(sp)
    80003a5a:	6902                	ld	s2,0(sp)
    80003a5c:	6105                	addi	sp,sp,32
    80003a5e:	8082                	ret

0000000080003a60 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003a60:	1101                	addi	sp,sp,-32
    80003a62:	ec06                	sd	ra,24(sp)
    80003a64:	e822                	sd	s0,16(sp)
    80003a66:	e426                	sd	s1,8(sp)
    80003a68:	e04a                	sd	s2,0(sp)
    80003a6a:	1000                	addi	s0,sp,32
    80003a6c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003a6e:	00850913          	addi	s2,a0,8
    80003a72:	854a                	mv	a0,s2
    80003a74:	00003097          	auipc	ra,0x3
    80003a78:	910080e7          	jalr	-1776(ra) # 80006384 <acquire>
  while (lk->locked) {
    80003a7c:	409c                	lw	a5,0(s1)
    80003a7e:	cb89                	beqz	a5,80003a90 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003a80:	85ca                	mv	a1,s2
    80003a82:	8526                	mv	a0,s1
    80003a84:	ffffe097          	auipc	ra,0xffffe
    80003a88:	a80080e7          	jalr	-1408(ra) # 80001504 <sleep>
  while (lk->locked) {
    80003a8c:	409c                	lw	a5,0(s1)
    80003a8e:	fbed                	bnez	a5,80003a80 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003a90:	4785                	li	a5,1
    80003a92:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003a94:	ffffd097          	auipc	ra,0xffffd
    80003a98:	3c0080e7          	jalr	960(ra) # 80000e54 <myproc>
    80003a9c:	591c                	lw	a5,48(a0)
    80003a9e:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003aa0:	854a                	mv	a0,s2
    80003aa2:	00003097          	auipc	ra,0x3
    80003aa6:	996080e7          	jalr	-1642(ra) # 80006438 <release>
}
    80003aaa:	60e2                	ld	ra,24(sp)
    80003aac:	6442                	ld	s0,16(sp)
    80003aae:	64a2                	ld	s1,8(sp)
    80003ab0:	6902                	ld	s2,0(sp)
    80003ab2:	6105                	addi	sp,sp,32
    80003ab4:	8082                	ret

0000000080003ab6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003ab6:	1101                	addi	sp,sp,-32
    80003ab8:	ec06                	sd	ra,24(sp)
    80003aba:	e822                	sd	s0,16(sp)
    80003abc:	e426                	sd	s1,8(sp)
    80003abe:	e04a                	sd	s2,0(sp)
    80003ac0:	1000                	addi	s0,sp,32
    80003ac2:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003ac4:	00850913          	addi	s2,a0,8
    80003ac8:	854a                	mv	a0,s2
    80003aca:	00003097          	auipc	ra,0x3
    80003ace:	8ba080e7          	jalr	-1862(ra) # 80006384 <acquire>
  lk->locked = 0;
    80003ad2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003ad6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003ada:	8526                	mv	a0,s1
    80003adc:	ffffe097          	auipc	ra,0xffffe
    80003ae0:	a8c080e7          	jalr	-1396(ra) # 80001568 <wakeup>
  release(&lk->lk);
    80003ae4:	854a                	mv	a0,s2
    80003ae6:	00003097          	auipc	ra,0x3
    80003aea:	952080e7          	jalr	-1710(ra) # 80006438 <release>
}
    80003aee:	60e2                	ld	ra,24(sp)
    80003af0:	6442                	ld	s0,16(sp)
    80003af2:	64a2                	ld	s1,8(sp)
    80003af4:	6902                	ld	s2,0(sp)
    80003af6:	6105                	addi	sp,sp,32
    80003af8:	8082                	ret

0000000080003afa <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003afa:	7179                	addi	sp,sp,-48
    80003afc:	f406                	sd	ra,40(sp)
    80003afe:	f022                	sd	s0,32(sp)
    80003b00:	ec26                	sd	s1,24(sp)
    80003b02:	e84a                	sd	s2,16(sp)
    80003b04:	e44e                	sd	s3,8(sp)
    80003b06:	1800                	addi	s0,sp,48
    80003b08:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003b0a:	00850913          	addi	s2,a0,8
    80003b0e:	854a                	mv	a0,s2
    80003b10:	00003097          	auipc	ra,0x3
    80003b14:	874080e7          	jalr	-1932(ra) # 80006384 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003b18:	409c                	lw	a5,0(s1)
    80003b1a:	ef99                	bnez	a5,80003b38 <holdingsleep+0x3e>
    80003b1c:	4481                	li	s1,0
  release(&lk->lk);
    80003b1e:	854a                	mv	a0,s2
    80003b20:	00003097          	auipc	ra,0x3
    80003b24:	918080e7          	jalr	-1768(ra) # 80006438 <release>
  return r;
}
    80003b28:	8526                	mv	a0,s1
    80003b2a:	70a2                	ld	ra,40(sp)
    80003b2c:	7402                	ld	s0,32(sp)
    80003b2e:	64e2                	ld	s1,24(sp)
    80003b30:	6942                	ld	s2,16(sp)
    80003b32:	69a2                	ld	s3,8(sp)
    80003b34:	6145                	addi	sp,sp,48
    80003b36:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003b38:	0284a983          	lw	s3,40(s1)
    80003b3c:	ffffd097          	auipc	ra,0xffffd
    80003b40:	318080e7          	jalr	792(ra) # 80000e54 <myproc>
    80003b44:	5904                	lw	s1,48(a0)
    80003b46:	413484b3          	sub	s1,s1,s3
    80003b4a:	0014b493          	seqz	s1,s1
    80003b4e:	bfc1                	j	80003b1e <holdingsleep+0x24>

0000000080003b50 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003b50:	1141                	addi	sp,sp,-16
    80003b52:	e406                	sd	ra,8(sp)
    80003b54:	e022                	sd	s0,0(sp)
    80003b56:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003b58:	00005597          	auipc	a1,0x5
    80003b5c:	ac858593          	addi	a1,a1,-1336 # 80008620 <syscalls+0x250>
    80003b60:	00019517          	auipc	a0,0x19
    80003b64:	4d850513          	addi	a0,a0,1240 # 8001d038 <ftable>
    80003b68:	00002097          	auipc	ra,0x2
    80003b6c:	78c080e7          	jalr	1932(ra) # 800062f4 <initlock>
}
    80003b70:	60a2                	ld	ra,8(sp)
    80003b72:	6402                	ld	s0,0(sp)
    80003b74:	0141                	addi	sp,sp,16
    80003b76:	8082                	ret

0000000080003b78 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003b78:	1101                	addi	sp,sp,-32
    80003b7a:	ec06                	sd	ra,24(sp)
    80003b7c:	e822                	sd	s0,16(sp)
    80003b7e:	e426                	sd	s1,8(sp)
    80003b80:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003b82:	00019517          	auipc	a0,0x19
    80003b86:	4b650513          	addi	a0,a0,1206 # 8001d038 <ftable>
    80003b8a:	00002097          	auipc	ra,0x2
    80003b8e:	7fa080e7          	jalr	2042(ra) # 80006384 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003b92:	00019497          	auipc	s1,0x19
    80003b96:	4be48493          	addi	s1,s1,1214 # 8001d050 <ftable+0x18>
    80003b9a:	0001a717          	auipc	a4,0x1a
    80003b9e:	45670713          	addi	a4,a4,1110 # 8001dff0 <disk>
    if(f->ref == 0){
    80003ba2:	40dc                	lw	a5,4(s1)
    80003ba4:	cf99                	beqz	a5,80003bc2 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003ba6:	02848493          	addi	s1,s1,40
    80003baa:	fee49ce3          	bne	s1,a4,80003ba2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003bae:	00019517          	auipc	a0,0x19
    80003bb2:	48a50513          	addi	a0,a0,1162 # 8001d038 <ftable>
    80003bb6:	00003097          	auipc	ra,0x3
    80003bba:	882080e7          	jalr	-1918(ra) # 80006438 <release>
  return 0;
    80003bbe:	4481                	li	s1,0
    80003bc0:	a819                	j	80003bd6 <filealloc+0x5e>
      f->ref = 1;
    80003bc2:	4785                	li	a5,1
    80003bc4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003bc6:	00019517          	auipc	a0,0x19
    80003bca:	47250513          	addi	a0,a0,1138 # 8001d038 <ftable>
    80003bce:	00003097          	auipc	ra,0x3
    80003bd2:	86a080e7          	jalr	-1942(ra) # 80006438 <release>
}
    80003bd6:	8526                	mv	a0,s1
    80003bd8:	60e2                	ld	ra,24(sp)
    80003bda:	6442                	ld	s0,16(sp)
    80003bdc:	64a2                	ld	s1,8(sp)
    80003bde:	6105                	addi	sp,sp,32
    80003be0:	8082                	ret

0000000080003be2 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003be2:	1101                	addi	sp,sp,-32
    80003be4:	ec06                	sd	ra,24(sp)
    80003be6:	e822                	sd	s0,16(sp)
    80003be8:	e426                	sd	s1,8(sp)
    80003bea:	1000                	addi	s0,sp,32
    80003bec:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003bee:	00019517          	auipc	a0,0x19
    80003bf2:	44a50513          	addi	a0,a0,1098 # 8001d038 <ftable>
    80003bf6:	00002097          	auipc	ra,0x2
    80003bfa:	78e080e7          	jalr	1934(ra) # 80006384 <acquire>
  if(f->ref < 1)
    80003bfe:	40dc                	lw	a5,4(s1)
    80003c00:	02f05263          	blez	a5,80003c24 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003c04:	2785                	addiw	a5,a5,1
    80003c06:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003c08:	00019517          	auipc	a0,0x19
    80003c0c:	43050513          	addi	a0,a0,1072 # 8001d038 <ftable>
    80003c10:	00003097          	auipc	ra,0x3
    80003c14:	828080e7          	jalr	-2008(ra) # 80006438 <release>
  return f;
}
    80003c18:	8526                	mv	a0,s1
    80003c1a:	60e2                	ld	ra,24(sp)
    80003c1c:	6442                	ld	s0,16(sp)
    80003c1e:	64a2                	ld	s1,8(sp)
    80003c20:	6105                	addi	sp,sp,32
    80003c22:	8082                	ret
    panic("filedup");
    80003c24:	00005517          	auipc	a0,0x5
    80003c28:	a0450513          	addi	a0,a0,-1532 # 80008628 <syscalls+0x258>
    80003c2c:	00002097          	auipc	ra,0x2
    80003c30:	220080e7          	jalr	544(ra) # 80005e4c <panic>

0000000080003c34 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003c34:	7139                	addi	sp,sp,-64
    80003c36:	fc06                	sd	ra,56(sp)
    80003c38:	f822                	sd	s0,48(sp)
    80003c3a:	f426                	sd	s1,40(sp)
    80003c3c:	f04a                	sd	s2,32(sp)
    80003c3e:	ec4e                	sd	s3,24(sp)
    80003c40:	e852                	sd	s4,16(sp)
    80003c42:	e456                	sd	s5,8(sp)
    80003c44:	0080                	addi	s0,sp,64
    80003c46:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003c48:	00019517          	auipc	a0,0x19
    80003c4c:	3f050513          	addi	a0,a0,1008 # 8001d038 <ftable>
    80003c50:	00002097          	auipc	ra,0x2
    80003c54:	734080e7          	jalr	1844(ra) # 80006384 <acquire>
  if(f->ref < 1)
    80003c58:	40dc                	lw	a5,4(s1)
    80003c5a:	06f05163          	blez	a5,80003cbc <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003c5e:	37fd                	addiw	a5,a5,-1
    80003c60:	0007871b          	sext.w	a4,a5
    80003c64:	c0dc                	sw	a5,4(s1)
    80003c66:	06e04363          	bgtz	a4,80003ccc <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003c6a:	0004a903          	lw	s2,0(s1)
    80003c6e:	0094ca83          	lbu	s5,9(s1)
    80003c72:	0104ba03          	ld	s4,16(s1)
    80003c76:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003c7a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003c7e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003c82:	00019517          	auipc	a0,0x19
    80003c86:	3b650513          	addi	a0,a0,950 # 8001d038 <ftable>
    80003c8a:	00002097          	auipc	ra,0x2
    80003c8e:	7ae080e7          	jalr	1966(ra) # 80006438 <release>

  if(ff.type == FD_PIPE){
    80003c92:	4785                	li	a5,1
    80003c94:	04f90d63          	beq	s2,a5,80003cee <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003c98:	3979                	addiw	s2,s2,-2
    80003c9a:	4785                	li	a5,1
    80003c9c:	0527e063          	bltu	a5,s2,80003cdc <fileclose+0xa8>
    begin_op();
    80003ca0:	00000097          	auipc	ra,0x0
    80003ca4:	acc080e7          	jalr	-1332(ra) # 8000376c <begin_op>
    iput(ff.ip);
    80003ca8:	854e                	mv	a0,s3
    80003caa:	fffff097          	auipc	ra,0xfffff
    80003cae:	2b0080e7          	jalr	688(ra) # 80002f5a <iput>
    end_op();
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	b38080e7          	jalr	-1224(ra) # 800037ea <end_op>
    80003cba:	a00d                	j	80003cdc <fileclose+0xa8>
    panic("fileclose");
    80003cbc:	00005517          	auipc	a0,0x5
    80003cc0:	97450513          	addi	a0,a0,-1676 # 80008630 <syscalls+0x260>
    80003cc4:	00002097          	auipc	ra,0x2
    80003cc8:	188080e7          	jalr	392(ra) # 80005e4c <panic>
    release(&ftable.lock);
    80003ccc:	00019517          	auipc	a0,0x19
    80003cd0:	36c50513          	addi	a0,a0,876 # 8001d038 <ftable>
    80003cd4:	00002097          	auipc	ra,0x2
    80003cd8:	764080e7          	jalr	1892(ra) # 80006438 <release>
  }
}
    80003cdc:	70e2                	ld	ra,56(sp)
    80003cde:	7442                	ld	s0,48(sp)
    80003ce0:	74a2                	ld	s1,40(sp)
    80003ce2:	7902                	ld	s2,32(sp)
    80003ce4:	69e2                	ld	s3,24(sp)
    80003ce6:	6a42                	ld	s4,16(sp)
    80003ce8:	6aa2                	ld	s5,8(sp)
    80003cea:	6121                	addi	sp,sp,64
    80003cec:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003cee:	85d6                	mv	a1,s5
    80003cf0:	8552                	mv	a0,s4
    80003cf2:	00000097          	auipc	ra,0x0
    80003cf6:	34c080e7          	jalr	844(ra) # 8000403e <pipeclose>
    80003cfa:	b7cd                	j	80003cdc <fileclose+0xa8>

0000000080003cfc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003cfc:	715d                	addi	sp,sp,-80
    80003cfe:	e486                	sd	ra,72(sp)
    80003d00:	e0a2                	sd	s0,64(sp)
    80003d02:	fc26                	sd	s1,56(sp)
    80003d04:	f84a                	sd	s2,48(sp)
    80003d06:	f44e                	sd	s3,40(sp)
    80003d08:	0880                	addi	s0,sp,80
    80003d0a:	84aa                	mv	s1,a0
    80003d0c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003d0e:	ffffd097          	auipc	ra,0xffffd
    80003d12:	146080e7          	jalr	326(ra) # 80000e54 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003d16:	409c                	lw	a5,0(s1)
    80003d18:	37f9                	addiw	a5,a5,-2
    80003d1a:	4705                	li	a4,1
    80003d1c:	04f76763          	bltu	a4,a5,80003d6a <filestat+0x6e>
    80003d20:	892a                	mv	s2,a0
    ilock(f->ip);
    80003d22:	6c88                	ld	a0,24(s1)
    80003d24:	fffff097          	auipc	ra,0xfffff
    80003d28:	07c080e7          	jalr	124(ra) # 80002da0 <ilock>
    stati(f->ip, &st);
    80003d2c:	fb840593          	addi	a1,s0,-72
    80003d30:	6c88                	ld	a0,24(s1)
    80003d32:	fffff097          	auipc	ra,0xfffff
    80003d36:	2f8080e7          	jalr	760(ra) # 8000302a <stati>
    iunlock(f->ip);
    80003d3a:	6c88                	ld	a0,24(s1)
    80003d3c:	fffff097          	auipc	ra,0xfffff
    80003d40:	126080e7          	jalr	294(ra) # 80002e62 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003d44:	46e1                	li	a3,24
    80003d46:	fb840613          	addi	a2,s0,-72
    80003d4a:	85ce                	mv	a1,s3
    80003d4c:	05093503          	ld	a0,80(s2)
    80003d50:	ffffd097          	auipc	ra,0xffffd
    80003d54:	dc4080e7          	jalr	-572(ra) # 80000b14 <copyout>
    80003d58:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003d5c:	60a6                	ld	ra,72(sp)
    80003d5e:	6406                	ld	s0,64(sp)
    80003d60:	74e2                	ld	s1,56(sp)
    80003d62:	7942                	ld	s2,48(sp)
    80003d64:	79a2                	ld	s3,40(sp)
    80003d66:	6161                	addi	sp,sp,80
    80003d68:	8082                	ret
  return -1;
    80003d6a:	557d                	li	a0,-1
    80003d6c:	bfc5                	j	80003d5c <filestat+0x60>

0000000080003d6e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003d6e:	7179                	addi	sp,sp,-48
    80003d70:	f406                	sd	ra,40(sp)
    80003d72:	f022                	sd	s0,32(sp)
    80003d74:	ec26                	sd	s1,24(sp)
    80003d76:	e84a                	sd	s2,16(sp)
    80003d78:	e44e                	sd	s3,8(sp)
    80003d7a:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003d7c:	00854783          	lbu	a5,8(a0)
    80003d80:	c3d5                	beqz	a5,80003e24 <fileread+0xb6>
    80003d82:	84aa                	mv	s1,a0
    80003d84:	89ae                	mv	s3,a1
    80003d86:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003d88:	411c                	lw	a5,0(a0)
    80003d8a:	4705                	li	a4,1
    80003d8c:	04e78963          	beq	a5,a4,80003dde <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003d90:	470d                	li	a4,3
    80003d92:	04e78d63          	beq	a5,a4,80003dec <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003d96:	4709                	li	a4,2
    80003d98:	06e79e63          	bne	a5,a4,80003e14 <fileread+0xa6>
    ilock(f->ip);
    80003d9c:	6d08                	ld	a0,24(a0)
    80003d9e:	fffff097          	auipc	ra,0xfffff
    80003da2:	002080e7          	jalr	2(ra) # 80002da0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003da6:	874a                	mv	a4,s2
    80003da8:	5094                	lw	a3,32(s1)
    80003daa:	864e                	mv	a2,s3
    80003dac:	4585                	li	a1,1
    80003dae:	6c88                	ld	a0,24(s1)
    80003db0:	fffff097          	auipc	ra,0xfffff
    80003db4:	2a4080e7          	jalr	676(ra) # 80003054 <readi>
    80003db8:	892a                	mv	s2,a0
    80003dba:	00a05563          	blez	a0,80003dc4 <fileread+0x56>
      f->off += r;
    80003dbe:	509c                	lw	a5,32(s1)
    80003dc0:	9fa9                	addw	a5,a5,a0
    80003dc2:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003dc4:	6c88                	ld	a0,24(s1)
    80003dc6:	fffff097          	auipc	ra,0xfffff
    80003dca:	09c080e7          	jalr	156(ra) # 80002e62 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003dce:	854a                	mv	a0,s2
    80003dd0:	70a2                	ld	ra,40(sp)
    80003dd2:	7402                	ld	s0,32(sp)
    80003dd4:	64e2                	ld	s1,24(sp)
    80003dd6:	6942                	ld	s2,16(sp)
    80003dd8:	69a2                	ld	s3,8(sp)
    80003dda:	6145                	addi	sp,sp,48
    80003ddc:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003dde:	6908                	ld	a0,16(a0)
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	3c6080e7          	jalr	966(ra) # 800041a6 <piperead>
    80003de8:	892a                	mv	s2,a0
    80003dea:	b7d5                	j	80003dce <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003dec:	02451783          	lh	a5,36(a0)
    80003df0:	03079693          	slli	a3,a5,0x30
    80003df4:	92c1                	srli	a3,a3,0x30
    80003df6:	4725                	li	a4,9
    80003df8:	02d76863          	bltu	a4,a3,80003e28 <fileread+0xba>
    80003dfc:	0792                	slli	a5,a5,0x4
    80003dfe:	00019717          	auipc	a4,0x19
    80003e02:	19a70713          	addi	a4,a4,410 # 8001cf98 <devsw>
    80003e06:	97ba                	add	a5,a5,a4
    80003e08:	639c                	ld	a5,0(a5)
    80003e0a:	c38d                	beqz	a5,80003e2c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003e0c:	4505                	li	a0,1
    80003e0e:	9782                	jalr	a5
    80003e10:	892a                	mv	s2,a0
    80003e12:	bf75                	j	80003dce <fileread+0x60>
    panic("fileread");
    80003e14:	00005517          	auipc	a0,0x5
    80003e18:	82c50513          	addi	a0,a0,-2004 # 80008640 <syscalls+0x270>
    80003e1c:	00002097          	auipc	ra,0x2
    80003e20:	030080e7          	jalr	48(ra) # 80005e4c <panic>
    return -1;
    80003e24:	597d                	li	s2,-1
    80003e26:	b765                	j	80003dce <fileread+0x60>
      return -1;
    80003e28:	597d                	li	s2,-1
    80003e2a:	b755                	j	80003dce <fileread+0x60>
    80003e2c:	597d                	li	s2,-1
    80003e2e:	b745                	j	80003dce <fileread+0x60>

0000000080003e30 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003e30:	715d                	addi	sp,sp,-80
    80003e32:	e486                	sd	ra,72(sp)
    80003e34:	e0a2                	sd	s0,64(sp)
    80003e36:	fc26                	sd	s1,56(sp)
    80003e38:	f84a                	sd	s2,48(sp)
    80003e3a:	f44e                	sd	s3,40(sp)
    80003e3c:	f052                	sd	s4,32(sp)
    80003e3e:	ec56                	sd	s5,24(sp)
    80003e40:	e85a                	sd	s6,16(sp)
    80003e42:	e45e                	sd	s7,8(sp)
    80003e44:	e062                	sd	s8,0(sp)
    80003e46:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003e48:	00954783          	lbu	a5,9(a0)
    80003e4c:	10078663          	beqz	a5,80003f58 <filewrite+0x128>
    80003e50:	892a                	mv	s2,a0
    80003e52:	8b2e                	mv	s6,a1
    80003e54:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003e56:	411c                	lw	a5,0(a0)
    80003e58:	4705                	li	a4,1
    80003e5a:	02e78263          	beq	a5,a4,80003e7e <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003e5e:	470d                	li	a4,3
    80003e60:	02e78663          	beq	a5,a4,80003e8c <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003e64:	4709                	li	a4,2
    80003e66:	0ee79163          	bne	a5,a4,80003f48 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003e6a:	0ac05d63          	blez	a2,80003f24 <filewrite+0xf4>
    int i = 0;
    80003e6e:	4981                	li	s3,0
    80003e70:	6b85                	lui	s7,0x1
    80003e72:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003e76:	6c05                	lui	s8,0x1
    80003e78:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003e7c:	a861                	j	80003f14 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003e7e:	6908                	ld	a0,16(a0)
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	22e080e7          	jalr	558(ra) # 800040ae <pipewrite>
    80003e88:	8a2a                	mv	s4,a0
    80003e8a:	a045                	j	80003f2a <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003e8c:	02451783          	lh	a5,36(a0)
    80003e90:	03079693          	slli	a3,a5,0x30
    80003e94:	92c1                	srli	a3,a3,0x30
    80003e96:	4725                	li	a4,9
    80003e98:	0cd76263          	bltu	a4,a3,80003f5c <filewrite+0x12c>
    80003e9c:	0792                	slli	a5,a5,0x4
    80003e9e:	00019717          	auipc	a4,0x19
    80003ea2:	0fa70713          	addi	a4,a4,250 # 8001cf98 <devsw>
    80003ea6:	97ba                	add	a5,a5,a4
    80003ea8:	679c                	ld	a5,8(a5)
    80003eaa:	cbdd                	beqz	a5,80003f60 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003eac:	4505                	li	a0,1
    80003eae:	9782                	jalr	a5
    80003eb0:	8a2a                	mv	s4,a0
    80003eb2:	a8a5                	j	80003f2a <filewrite+0xfa>
    80003eb4:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003eb8:	00000097          	auipc	ra,0x0
    80003ebc:	8b4080e7          	jalr	-1868(ra) # 8000376c <begin_op>
      ilock(f->ip);
    80003ec0:	01893503          	ld	a0,24(s2)
    80003ec4:	fffff097          	auipc	ra,0xfffff
    80003ec8:	edc080e7          	jalr	-292(ra) # 80002da0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003ecc:	8756                	mv	a4,s5
    80003ece:	02092683          	lw	a3,32(s2)
    80003ed2:	01698633          	add	a2,s3,s6
    80003ed6:	4585                	li	a1,1
    80003ed8:	01893503          	ld	a0,24(s2)
    80003edc:	fffff097          	auipc	ra,0xfffff
    80003ee0:	270080e7          	jalr	624(ra) # 8000314c <writei>
    80003ee4:	84aa                	mv	s1,a0
    80003ee6:	00a05763          	blez	a0,80003ef4 <filewrite+0xc4>
        f->off += r;
    80003eea:	02092783          	lw	a5,32(s2)
    80003eee:	9fa9                	addw	a5,a5,a0
    80003ef0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003ef4:	01893503          	ld	a0,24(s2)
    80003ef8:	fffff097          	auipc	ra,0xfffff
    80003efc:	f6a080e7          	jalr	-150(ra) # 80002e62 <iunlock>
      end_op();
    80003f00:	00000097          	auipc	ra,0x0
    80003f04:	8ea080e7          	jalr	-1814(ra) # 800037ea <end_op>

      if(r != n1){
    80003f08:	009a9f63          	bne	s5,s1,80003f26 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003f0c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003f10:	0149db63          	bge	s3,s4,80003f26 <filewrite+0xf6>
      int n1 = n - i;
    80003f14:	413a04bb          	subw	s1,s4,s3
    80003f18:	0004879b          	sext.w	a5,s1
    80003f1c:	f8fbdce3          	bge	s7,a5,80003eb4 <filewrite+0x84>
    80003f20:	84e2                	mv	s1,s8
    80003f22:	bf49                	j	80003eb4 <filewrite+0x84>
    int i = 0;
    80003f24:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003f26:	013a1f63          	bne	s4,s3,80003f44 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003f2a:	8552                	mv	a0,s4
    80003f2c:	60a6                	ld	ra,72(sp)
    80003f2e:	6406                	ld	s0,64(sp)
    80003f30:	74e2                	ld	s1,56(sp)
    80003f32:	7942                	ld	s2,48(sp)
    80003f34:	79a2                	ld	s3,40(sp)
    80003f36:	7a02                	ld	s4,32(sp)
    80003f38:	6ae2                	ld	s5,24(sp)
    80003f3a:	6b42                	ld	s6,16(sp)
    80003f3c:	6ba2                	ld	s7,8(sp)
    80003f3e:	6c02                	ld	s8,0(sp)
    80003f40:	6161                	addi	sp,sp,80
    80003f42:	8082                	ret
    ret = (i == n ? n : -1);
    80003f44:	5a7d                	li	s4,-1
    80003f46:	b7d5                	j	80003f2a <filewrite+0xfa>
    panic("filewrite");
    80003f48:	00004517          	auipc	a0,0x4
    80003f4c:	70850513          	addi	a0,a0,1800 # 80008650 <syscalls+0x280>
    80003f50:	00002097          	auipc	ra,0x2
    80003f54:	efc080e7          	jalr	-260(ra) # 80005e4c <panic>
    return -1;
    80003f58:	5a7d                	li	s4,-1
    80003f5a:	bfc1                	j	80003f2a <filewrite+0xfa>
      return -1;
    80003f5c:	5a7d                	li	s4,-1
    80003f5e:	b7f1                	j	80003f2a <filewrite+0xfa>
    80003f60:	5a7d                	li	s4,-1
    80003f62:	b7e1                	j	80003f2a <filewrite+0xfa>

0000000080003f64 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003f64:	7179                	addi	sp,sp,-48
    80003f66:	f406                	sd	ra,40(sp)
    80003f68:	f022                	sd	s0,32(sp)
    80003f6a:	ec26                	sd	s1,24(sp)
    80003f6c:	e84a                	sd	s2,16(sp)
    80003f6e:	e44e                	sd	s3,8(sp)
    80003f70:	e052                	sd	s4,0(sp)
    80003f72:	1800                	addi	s0,sp,48
    80003f74:	84aa                	mv	s1,a0
    80003f76:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003f78:	0005b023          	sd	zero,0(a1)
    80003f7c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003f80:	00000097          	auipc	ra,0x0
    80003f84:	bf8080e7          	jalr	-1032(ra) # 80003b78 <filealloc>
    80003f88:	e088                	sd	a0,0(s1)
    80003f8a:	c551                	beqz	a0,80004016 <pipealloc+0xb2>
    80003f8c:	00000097          	auipc	ra,0x0
    80003f90:	bec080e7          	jalr	-1044(ra) # 80003b78 <filealloc>
    80003f94:	00aa3023          	sd	a0,0(s4)
    80003f98:	c92d                	beqz	a0,8000400a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003f9a:	ffffc097          	auipc	ra,0xffffc
    80003f9e:	180080e7          	jalr	384(ra) # 8000011a <kalloc>
    80003fa2:	892a                	mv	s2,a0
    80003fa4:	c125                	beqz	a0,80004004 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003fa6:	4985                	li	s3,1
    80003fa8:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003fac:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003fb0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003fb4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003fb8:	00004597          	auipc	a1,0x4
    80003fbc:	6a858593          	addi	a1,a1,1704 # 80008660 <syscalls+0x290>
    80003fc0:	00002097          	auipc	ra,0x2
    80003fc4:	334080e7          	jalr	820(ra) # 800062f4 <initlock>
  (*f0)->type = FD_PIPE;
    80003fc8:	609c                	ld	a5,0(s1)
    80003fca:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003fce:	609c                	ld	a5,0(s1)
    80003fd0:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003fd4:	609c                	ld	a5,0(s1)
    80003fd6:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003fda:	609c                	ld	a5,0(s1)
    80003fdc:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003fe0:	000a3783          	ld	a5,0(s4)
    80003fe4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003fe8:	000a3783          	ld	a5,0(s4)
    80003fec:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003ff0:	000a3783          	ld	a5,0(s4)
    80003ff4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003ff8:	000a3783          	ld	a5,0(s4)
    80003ffc:	0127b823          	sd	s2,16(a5)
  return 0;
    80004000:	4501                	li	a0,0
    80004002:	a025                	j	8000402a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004004:	6088                	ld	a0,0(s1)
    80004006:	e501                	bnez	a0,8000400e <pipealloc+0xaa>
    80004008:	a039                	j	80004016 <pipealloc+0xb2>
    8000400a:	6088                	ld	a0,0(s1)
    8000400c:	c51d                	beqz	a0,8000403a <pipealloc+0xd6>
    fileclose(*f0);
    8000400e:	00000097          	auipc	ra,0x0
    80004012:	c26080e7          	jalr	-986(ra) # 80003c34 <fileclose>
  if(*f1)
    80004016:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000401a:	557d                	li	a0,-1
  if(*f1)
    8000401c:	c799                	beqz	a5,8000402a <pipealloc+0xc6>
    fileclose(*f1);
    8000401e:	853e                	mv	a0,a5
    80004020:	00000097          	auipc	ra,0x0
    80004024:	c14080e7          	jalr	-1004(ra) # 80003c34 <fileclose>
  return -1;
    80004028:	557d                	li	a0,-1
}
    8000402a:	70a2                	ld	ra,40(sp)
    8000402c:	7402                	ld	s0,32(sp)
    8000402e:	64e2                	ld	s1,24(sp)
    80004030:	6942                	ld	s2,16(sp)
    80004032:	69a2                	ld	s3,8(sp)
    80004034:	6a02                	ld	s4,0(sp)
    80004036:	6145                	addi	sp,sp,48
    80004038:	8082                	ret
  return -1;
    8000403a:	557d                	li	a0,-1
    8000403c:	b7fd                	j	8000402a <pipealloc+0xc6>

000000008000403e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000403e:	1101                	addi	sp,sp,-32
    80004040:	ec06                	sd	ra,24(sp)
    80004042:	e822                	sd	s0,16(sp)
    80004044:	e426                	sd	s1,8(sp)
    80004046:	e04a                	sd	s2,0(sp)
    80004048:	1000                	addi	s0,sp,32
    8000404a:	84aa                	mv	s1,a0
    8000404c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000404e:	00002097          	auipc	ra,0x2
    80004052:	336080e7          	jalr	822(ra) # 80006384 <acquire>
  if(writable){
    80004056:	02090d63          	beqz	s2,80004090 <pipeclose+0x52>
    pi->writeopen = 0;
    8000405a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    8000405e:	21848513          	addi	a0,s1,536
    80004062:	ffffd097          	auipc	ra,0xffffd
    80004066:	506080e7          	jalr	1286(ra) # 80001568 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000406a:	2204b783          	ld	a5,544(s1)
    8000406e:	eb95                	bnez	a5,800040a2 <pipeclose+0x64>
    release(&pi->lock);
    80004070:	8526                	mv	a0,s1
    80004072:	00002097          	auipc	ra,0x2
    80004076:	3c6080e7          	jalr	966(ra) # 80006438 <release>
    kfree((char*)pi);
    8000407a:	8526                	mv	a0,s1
    8000407c:	ffffc097          	auipc	ra,0xffffc
    80004080:	fa0080e7          	jalr	-96(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80004084:	60e2                	ld	ra,24(sp)
    80004086:	6442                	ld	s0,16(sp)
    80004088:	64a2                	ld	s1,8(sp)
    8000408a:	6902                	ld	s2,0(sp)
    8000408c:	6105                	addi	sp,sp,32
    8000408e:	8082                	ret
    pi->readopen = 0;
    80004090:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004094:	21c48513          	addi	a0,s1,540
    80004098:	ffffd097          	auipc	ra,0xffffd
    8000409c:	4d0080e7          	jalr	1232(ra) # 80001568 <wakeup>
    800040a0:	b7e9                	j	8000406a <pipeclose+0x2c>
    release(&pi->lock);
    800040a2:	8526                	mv	a0,s1
    800040a4:	00002097          	auipc	ra,0x2
    800040a8:	394080e7          	jalr	916(ra) # 80006438 <release>
}
    800040ac:	bfe1                	j	80004084 <pipeclose+0x46>

00000000800040ae <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800040ae:	711d                	addi	sp,sp,-96
    800040b0:	ec86                	sd	ra,88(sp)
    800040b2:	e8a2                	sd	s0,80(sp)
    800040b4:	e4a6                	sd	s1,72(sp)
    800040b6:	e0ca                	sd	s2,64(sp)
    800040b8:	fc4e                	sd	s3,56(sp)
    800040ba:	f852                	sd	s4,48(sp)
    800040bc:	f456                	sd	s5,40(sp)
    800040be:	f05a                	sd	s6,32(sp)
    800040c0:	ec5e                	sd	s7,24(sp)
    800040c2:	e862                	sd	s8,16(sp)
    800040c4:	1080                	addi	s0,sp,96
    800040c6:	84aa                	mv	s1,a0
    800040c8:	8aae                	mv	s5,a1
    800040ca:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800040cc:	ffffd097          	auipc	ra,0xffffd
    800040d0:	d88080e7          	jalr	-632(ra) # 80000e54 <myproc>
    800040d4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800040d6:	8526                	mv	a0,s1
    800040d8:	00002097          	auipc	ra,0x2
    800040dc:	2ac080e7          	jalr	684(ra) # 80006384 <acquire>
  while(i < n){
    800040e0:	0b405663          	blez	s4,8000418c <pipewrite+0xde>
  int i = 0;
    800040e4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800040e6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800040e8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800040ec:	21c48b93          	addi	s7,s1,540
    800040f0:	a089                	j	80004132 <pipewrite+0x84>
      release(&pi->lock);
    800040f2:	8526                	mv	a0,s1
    800040f4:	00002097          	auipc	ra,0x2
    800040f8:	344080e7          	jalr	836(ra) # 80006438 <release>
      return -1;
    800040fc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800040fe:	854a                	mv	a0,s2
    80004100:	60e6                	ld	ra,88(sp)
    80004102:	6446                	ld	s0,80(sp)
    80004104:	64a6                	ld	s1,72(sp)
    80004106:	6906                	ld	s2,64(sp)
    80004108:	79e2                	ld	s3,56(sp)
    8000410a:	7a42                	ld	s4,48(sp)
    8000410c:	7aa2                	ld	s5,40(sp)
    8000410e:	7b02                	ld	s6,32(sp)
    80004110:	6be2                	ld	s7,24(sp)
    80004112:	6c42                	ld	s8,16(sp)
    80004114:	6125                	addi	sp,sp,96
    80004116:	8082                	ret
      wakeup(&pi->nread);
    80004118:	8562                	mv	a0,s8
    8000411a:	ffffd097          	auipc	ra,0xffffd
    8000411e:	44e080e7          	jalr	1102(ra) # 80001568 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004122:	85a6                	mv	a1,s1
    80004124:	855e                	mv	a0,s7
    80004126:	ffffd097          	auipc	ra,0xffffd
    8000412a:	3de080e7          	jalr	990(ra) # 80001504 <sleep>
  while(i < n){
    8000412e:	07495063          	bge	s2,s4,8000418e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004132:	2204a783          	lw	a5,544(s1)
    80004136:	dfd5                	beqz	a5,800040f2 <pipewrite+0x44>
    80004138:	854e                	mv	a0,s3
    8000413a:	ffffd097          	auipc	ra,0xffffd
    8000413e:	672080e7          	jalr	1650(ra) # 800017ac <killed>
    80004142:	f945                	bnez	a0,800040f2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004144:	2184a783          	lw	a5,536(s1)
    80004148:	21c4a703          	lw	a4,540(s1)
    8000414c:	2007879b          	addiw	a5,a5,512
    80004150:	fcf704e3          	beq	a4,a5,80004118 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004154:	4685                	li	a3,1
    80004156:	01590633          	add	a2,s2,s5
    8000415a:	faf40593          	addi	a1,s0,-81
    8000415e:	0509b503          	ld	a0,80(s3)
    80004162:	ffffd097          	auipc	ra,0xffffd
    80004166:	a3e080e7          	jalr	-1474(ra) # 80000ba0 <copyin>
    8000416a:	03650263          	beq	a0,s6,8000418e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    8000416e:	21c4a783          	lw	a5,540(s1)
    80004172:	0017871b          	addiw	a4,a5,1
    80004176:	20e4ae23          	sw	a4,540(s1)
    8000417a:	1ff7f793          	andi	a5,a5,511
    8000417e:	97a6                	add	a5,a5,s1
    80004180:	faf44703          	lbu	a4,-81(s0)
    80004184:	00e78c23          	sb	a4,24(a5)
      i++;
    80004188:	2905                	addiw	s2,s2,1
    8000418a:	b755                	j	8000412e <pipewrite+0x80>
  int i = 0;
    8000418c:	4901                	li	s2,0
  wakeup(&pi->nread);
    8000418e:	21848513          	addi	a0,s1,536
    80004192:	ffffd097          	auipc	ra,0xffffd
    80004196:	3d6080e7          	jalr	982(ra) # 80001568 <wakeup>
  release(&pi->lock);
    8000419a:	8526                	mv	a0,s1
    8000419c:	00002097          	auipc	ra,0x2
    800041a0:	29c080e7          	jalr	668(ra) # 80006438 <release>
  return i;
    800041a4:	bfa9                	j	800040fe <pipewrite+0x50>

00000000800041a6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800041a6:	715d                	addi	sp,sp,-80
    800041a8:	e486                	sd	ra,72(sp)
    800041aa:	e0a2                	sd	s0,64(sp)
    800041ac:	fc26                	sd	s1,56(sp)
    800041ae:	f84a                	sd	s2,48(sp)
    800041b0:	f44e                	sd	s3,40(sp)
    800041b2:	f052                	sd	s4,32(sp)
    800041b4:	ec56                	sd	s5,24(sp)
    800041b6:	e85a                	sd	s6,16(sp)
    800041b8:	0880                	addi	s0,sp,80
    800041ba:	84aa                	mv	s1,a0
    800041bc:	892e                	mv	s2,a1
    800041be:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800041c0:	ffffd097          	auipc	ra,0xffffd
    800041c4:	c94080e7          	jalr	-876(ra) # 80000e54 <myproc>
    800041c8:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800041ca:	8526                	mv	a0,s1
    800041cc:	00002097          	auipc	ra,0x2
    800041d0:	1b8080e7          	jalr	440(ra) # 80006384 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800041d4:	2184a703          	lw	a4,536(s1)
    800041d8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800041dc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800041e0:	02f71763          	bne	a4,a5,8000420e <piperead+0x68>
    800041e4:	2244a783          	lw	a5,548(s1)
    800041e8:	c39d                	beqz	a5,8000420e <piperead+0x68>
    if(killed(pr)){
    800041ea:	8552                	mv	a0,s4
    800041ec:	ffffd097          	auipc	ra,0xffffd
    800041f0:	5c0080e7          	jalr	1472(ra) # 800017ac <killed>
    800041f4:	e949                	bnez	a0,80004286 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800041f6:	85a6                	mv	a1,s1
    800041f8:	854e                	mv	a0,s3
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	30a080e7          	jalr	778(ra) # 80001504 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004202:	2184a703          	lw	a4,536(s1)
    80004206:	21c4a783          	lw	a5,540(s1)
    8000420a:	fcf70de3          	beq	a4,a5,800041e4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000420e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004210:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004212:	05505463          	blez	s5,8000425a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004216:	2184a783          	lw	a5,536(s1)
    8000421a:	21c4a703          	lw	a4,540(s1)
    8000421e:	02f70e63          	beq	a4,a5,8000425a <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004222:	0017871b          	addiw	a4,a5,1
    80004226:	20e4ac23          	sw	a4,536(s1)
    8000422a:	1ff7f793          	andi	a5,a5,511
    8000422e:	97a6                	add	a5,a5,s1
    80004230:	0187c783          	lbu	a5,24(a5)
    80004234:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004238:	4685                	li	a3,1
    8000423a:	fbf40613          	addi	a2,s0,-65
    8000423e:	85ca                	mv	a1,s2
    80004240:	050a3503          	ld	a0,80(s4)
    80004244:	ffffd097          	auipc	ra,0xffffd
    80004248:	8d0080e7          	jalr	-1840(ra) # 80000b14 <copyout>
    8000424c:	01650763          	beq	a0,s6,8000425a <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004250:	2985                	addiw	s3,s3,1
    80004252:	0905                	addi	s2,s2,1
    80004254:	fd3a91e3          	bne	s5,s3,80004216 <piperead+0x70>
    80004258:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000425a:	21c48513          	addi	a0,s1,540
    8000425e:	ffffd097          	auipc	ra,0xffffd
    80004262:	30a080e7          	jalr	778(ra) # 80001568 <wakeup>
  release(&pi->lock);
    80004266:	8526                	mv	a0,s1
    80004268:	00002097          	auipc	ra,0x2
    8000426c:	1d0080e7          	jalr	464(ra) # 80006438 <release>
  return i;
}
    80004270:	854e                	mv	a0,s3
    80004272:	60a6                	ld	ra,72(sp)
    80004274:	6406                	ld	s0,64(sp)
    80004276:	74e2                	ld	s1,56(sp)
    80004278:	7942                	ld	s2,48(sp)
    8000427a:	79a2                	ld	s3,40(sp)
    8000427c:	7a02                	ld	s4,32(sp)
    8000427e:	6ae2                	ld	s5,24(sp)
    80004280:	6b42                	ld	s6,16(sp)
    80004282:	6161                	addi	sp,sp,80
    80004284:	8082                	ret
      release(&pi->lock);
    80004286:	8526                	mv	a0,s1
    80004288:	00002097          	auipc	ra,0x2
    8000428c:	1b0080e7          	jalr	432(ra) # 80006438 <release>
      return -1;
    80004290:	59fd                	li	s3,-1
    80004292:	bff9                	j	80004270 <piperead+0xca>

0000000080004294 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004294:	1141                	addi	sp,sp,-16
    80004296:	e422                	sd	s0,8(sp)
    80004298:	0800                	addi	s0,sp,16
    8000429a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000429c:	8905                	andi	a0,a0,1
    8000429e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    800042a0:	8b89                	andi	a5,a5,2
    800042a2:	c399                	beqz	a5,800042a8 <flags2perm+0x14>
      perm |= PTE_W;
    800042a4:	00456513          	ori	a0,a0,4
    return perm;
}
    800042a8:	6422                	ld	s0,8(sp)
    800042aa:	0141                	addi	sp,sp,16
    800042ac:	8082                	ret

00000000800042ae <exec>:

int
exec(char *path, char **argv)
{
    800042ae:	de010113          	addi	sp,sp,-544
    800042b2:	20113c23          	sd	ra,536(sp)
    800042b6:	20813823          	sd	s0,528(sp)
    800042ba:	20913423          	sd	s1,520(sp)
    800042be:	21213023          	sd	s2,512(sp)
    800042c2:	ffce                	sd	s3,504(sp)
    800042c4:	fbd2                	sd	s4,496(sp)
    800042c6:	f7d6                	sd	s5,488(sp)
    800042c8:	f3da                	sd	s6,480(sp)
    800042ca:	efde                	sd	s7,472(sp)
    800042cc:	ebe2                	sd	s8,464(sp)
    800042ce:	e7e6                	sd	s9,456(sp)
    800042d0:	e3ea                	sd	s10,448(sp)
    800042d2:	ff6e                	sd	s11,440(sp)
    800042d4:	1400                	addi	s0,sp,544
    800042d6:	892a                	mv	s2,a0
    800042d8:	dea43423          	sd	a0,-536(s0)
    800042dc:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800042e0:	ffffd097          	auipc	ra,0xffffd
    800042e4:	b74080e7          	jalr	-1164(ra) # 80000e54 <myproc>
    800042e8:	84aa                	mv	s1,a0

  begin_op();
    800042ea:	fffff097          	auipc	ra,0xfffff
    800042ee:	482080e7          	jalr	1154(ra) # 8000376c <begin_op>

  if((ip = namei(path)) == 0){
    800042f2:	854a                	mv	a0,s2
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	258080e7          	jalr	600(ra) # 8000354c <namei>
    800042fc:	c93d                	beqz	a0,80004372 <exec+0xc4>
    800042fe:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004300:	fffff097          	auipc	ra,0xfffff
    80004304:	aa0080e7          	jalr	-1376(ra) # 80002da0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004308:	04000713          	li	a4,64
    8000430c:	4681                	li	a3,0
    8000430e:	e5040613          	addi	a2,s0,-432
    80004312:	4581                	li	a1,0
    80004314:	8556                	mv	a0,s5
    80004316:	fffff097          	auipc	ra,0xfffff
    8000431a:	d3e080e7          	jalr	-706(ra) # 80003054 <readi>
    8000431e:	04000793          	li	a5,64
    80004322:	00f51a63          	bne	a0,a5,80004336 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004326:	e5042703          	lw	a4,-432(s0)
    8000432a:	464c47b7          	lui	a5,0x464c4
    8000432e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004332:	04f70663          	beq	a4,a5,8000437e <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004336:	8556                	mv	a0,s5
    80004338:	fffff097          	auipc	ra,0xfffff
    8000433c:	cca080e7          	jalr	-822(ra) # 80003002 <iunlockput>
    end_op();
    80004340:	fffff097          	auipc	ra,0xfffff
    80004344:	4aa080e7          	jalr	1194(ra) # 800037ea <end_op>
  }
  return -1;
    80004348:	557d                	li	a0,-1
}
    8000434a:	21813083          	ld	ra,536(sp)
    8000434e:	21013403          	ld	s0,528(sp)
    80004352:	20813483          	ld	s1,520(sp)
    80004356:	20013903          	ld	s2,512(sp)
    8000435a:	79fe                	ld	s3,504(sp)
    8000435c:	7a5e                	ld	s4,496(sp)
    8000435e:	7abe                	ld	s5,488(sp)
    80004360:	7b1e                	ld	s6,480(sp)
    80004362:	6bfe                	ld	s7,472(sp)
    80004364:	6c5e                	ld	s8,464(sp)
    80004366:	6cbe                	ld	s9,456(sp)
    80004368:	6d1e                	ld	s10,448(sp)
    8000436a:	7dfa                	ld	s11,440(sp)
    8000436c:	22010113          	addi	sp,sp,544
    80004370:	8082                	ret
    end_op();
    80004372:	fffff097          	auipc	ra,0xfffff
    80004376:	478080e7          	jalr	1144(ra) # 800037ea <end_op>
    return -1;
    8000437a:	557d                	li	a0,-1
    8000437c:	b7f9                	j	8000434a <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    8000437e:	8526                	mv	a0,s1
    80004380:	ffffd097          	auipc	ra,0xffffd
    80004384:	b98080e7          	jalr	-1128(ra) # 80000f18 <proc_pagetable>
    80004388:	8b2a                	mv	s6,a0
    8000438a:	d555                	beqz	a0,80004336 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000438c:	e7042783          	lw	a5,-400(s0)
    80004390:	e8845703          	lhu	a4,-376(s0)
    80004394:	c735                	beqz	a4,80004400 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004396:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004398:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000439c:	6a05                	lui	s4,0x1
    8000439e:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    800043a2:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    800043a6:	6d85                	lui	s11,0x1
    800043a8:	7d7d                	lui	s10,0xfffff
    800043aa:	ac3d                	j	800045e8 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    800043ac:	00004517          	auipc	a0,0x4
    800043b0:	2bc50513          	addi	a0,a0,700 # 80008668 <syscalls+0x298>
    800043b4:	00002097          	auipc	ra,0x2
    800043b8:	a98080e7          	jalr	-1384(ra) # 80005e4c <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800043bc:	874a                	mv	a4,s2
    800043be:	009c86bb          	addw	a3,s9,s1
    800043c2:	4581                	li	a1,0
    800043c4:	8556                	mv	a0,s5
    800043c6:	fffff097          	auipc	ra,0xfffff
    800043ca:	c8e080e7          	jalr	-882(ra) # 80003054 <readi>
    800043ce:	2501                	sext.w	a0,a0
    800043d0:	1aa91963          	bne	s2,a0,80004582 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    800043d4:	009d84bb          	addw	s1,s11,s1
    800043d8:	013d09bb          	addw	s3,s10,s3
    800043dc:	1f74f663          	bgeu	s1,s7,800045c8 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    800043e0:	02049593          	slli	a1,s1,0x20
    800043e4:	9181                	srli	a1,a1,0x20
    800043e6:	95e2                	add	a1,a1,s8
    800043e8:	855a                	mv	a0,s6
    800043ea:	ffffc097          	auipc	ra,0xffffc
    800043ee:	11a080e7          	jalr	282(ra) # 80000504 <walkaddr>
    800043f2:	862a                	mv	a2,a0
    if(pa == 0)
    800043f4:	dd45                	beqz	a0,800043ac <exec+0xfe>
      n = PGSIZE;
    800043f6:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800043f8:	fd49f2e3          	bgeu	s3,s4,800043bc <exec+0x10e>
      n = sz - i;
    800043fc:	894e                	mv	s2,s3
    800043fe:	bf7d                	j	800043bc <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004400:	4901                	li	s2,0
  iunlockput(ip);
    80004402:	8556                	mv	a0,s5
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	bfe080e7          	jalr	-1026(ra) # 80003002 <iunlockput>
  end_op();
    8000440c:	fffff097          	auipc	ra,0xfffff
    80004410:	3de080e7          	jalr	990(ra) # 800037ea <end_op>
  p = myproc();
    80004414:	ffffd097          	auipc	ra,0xffffd
    80004418:	a40080e7          	jalr	-1472(ra) # 80000e54 <myproc>
    8000441c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    8000441e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004422:	6785                	lui	a5,0x1
    80004424:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004426:	97ca                	add	a5,a5,s2
    80004428:	777d                	lui	a4,0xfffff
    8000442a:	8ff9                	and	a5,a5,a4
    8000442c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004430:	4691                	li	a3,4
    80004432:	6609                	lui	a2,0x2
    80004434:	963e                	add	a2,a2,a5
    80004436:	85be                	mv	a1,a5
    80004438:	855a                	mv	a0,s6
    8000443a:	ffffc097          	auipc	ra,0xffffc
    8000443e:	47e080e7          	jalr	1150(ra) # 800008b8 <uvmalloc>
    80004442:	8c2a                	mv	s8,a0
  ip = 0;
    80004444:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004446:	12050e63          	beqz	a0,80004582 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000444a:	75f9                	lui	a1,0xffffe
    8000444c:	95aa                	add	a1,a1,a0
    8000444e:	855a                	mv	a0,s6
    80004450:	ffffc097          	auipc	ra,0xffffc
    80004454:	692080e7          	jalr	1682(ra) # 80000ae2 <uvmclear>
  stackbase = sp - PGSIZE;
    80004458:	7afd                	lui	s5,0xfffff
    8000445a:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    8000445c:	df043783          	ld	a5,-528(s0)
    80004460:	6388                	ld	a0,0(a5)
    80004462:	c925                	beqz	a0,800044d2 <exec+0x224>
    80004464:	e9040993          	addi	s3,s0,-368
    80004468:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000446c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000446e:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004470:	ffffc097          	auipc	ra,0xffffc
    80004474:	e86080e7          	jalr	-378(ra) # 800002f6 <strlen>
    80004478:	0015079b          	addiw	a5,a0,1
    8000447c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004480:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004484:	13596663          	bltu	s2,s5,800045b0 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004488:	df043d83          	ld	s11,-528(s0)
    8000448c:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004490:	8552                	mv	a0,s4
    80004492:	ffffc097          	auipc	ra,0xffffc
    80004496:	e64080e7          	jalr	-412(ra) # 800002f6 <strlen>
    8000449a:	0015069b          	addiw	a3,a0,1
    8000449e:	8652                	mv	a2,s4
    800044a0:	85ca                	mv	a1,s2
    800044a2:	855a                	mv	a0,s6
    800044a4:	ffffc097          	auipc	ra,0xffffc
    800044a8:	670080e7          	jalr	1648(ra) # 80000b14 <copyout>
    800044ac:	10054663          	bltz	a0,800045b8 <exec+0x30a>
    ustack[argc] = sp;
    800044b0:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    800044b4:	0485                	addi	s1,s1,1
    800044b6:	008d8793          	addi	a5,s11,8
    800044ba:	def43823          	sd	a5,-528(s0)
    800044be:	008db503          	ld	a0,8(s11)
    800044c2:	c911                	beqz	a0,800044d6 <exec+0x228>
    if(argc >= MAXARG)
    800044c4:	09a1                	addi	s3,s3,8
    800044c6:	fb3c95e3          	bne	s9,s3,80004470 <exec+0x1c2>
  sz = sz1;
    800044ca:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800044ce:	4a81                	li	s5,0
    800044d0:	a84d                	j	80004582 <exec+0x2d4>
  sp = sz;
    800044d2:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    800044d4:	4481                	li	s1,0
  ustack[argc] = 0;
    800044d6:	00349793          	slli	a5,s1,0x3
    800044da:	f9078793          	addi	a5,a5,-112
    800044de:	97a2                	add	a5,a5,s0
    800044e0:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800044e4:	00148693          	addi	a3,s1,1
    800044e8:	068e                	slli	a3,a3,0x3
    800044ea:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800044ee:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800044f2:	01597663          	bgeu	s2,s5,800044fe <exec+0x250>
  sz = sz1;
    800044f6:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800044fa:	4a81                	li	s5,0
    800044fc:	a059                	j	80004582 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800044fe:	e9040613          	addi	a2,s0,-368
    80004502:	85ca                	mv	a1,s2
    80004504:	855a                	mv	a0,s6
    80004506:	ffffc097          	auipc	ra,0xffffc
    8000450a:	60e080e7          	jalr	1550(ra) # 80000b14 <copyout>
    8000450e:	0a054963          	bltz	a0,800045c0 <exec+0x312>
  p->trapframe->a1 = sp;
    80004512:	058bb783          	ld	a5,88(s7)
    80004516:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000451a:	de843783          	ld	a5,-536(s0)
    8000451e:	0007c703          	lbu	a4,0(a5)
    80004522:	cf11                	beqz	a4,8000453e <exec+0x290>
    80004524:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004526:	02f00693          	li	a3,47
    8000452a:	a039                	j	80004538 <exec+0x28a>
      last = s+1;
    8000452c:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004530:	0785                	addi	a5,a5,1
    80004532:	fff7c703          	lbu	a4,-1(a5)
    80004536:	c701                	beqz	a4,8000453e <exec+0x290>
    if(*s == '/')
    80004538:	fed71ce3          	bne	a4,a3,80004530 <exec+0x282>
    8000453c:	bfc5                	j	8000452c <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    8000453e:	4641                	li	a2,16
    80004540:	de843583          	ld	a1,-536(s0)
    80004544:	158b8513          	addi	a0,s7,344
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	d7c080e7          	jalr	-644(ra) # 800002c4 <safestrcpy>
  oldpagetable = p->pagetable;
    80004550:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004554:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004558:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000455c:	058bb783          	ld	a5,88(s7)
    80004560:	e6843703          	ld	a4,-408(s0)
    80004564:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004566:	058bb783          	ld	a5,88(s7)
    8000456a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000456e:	85ea                	mv	a1,s10
    80004570:	ffffd097          	auipc	ra,0xffffd
    80004574:	a44080e7          	jalr	-1468(ra) # 80000fb4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004578:	0004851b          	sext.w	a0,s1
    8000457c:	b3f9                	j	8000434a <exec+0x9c>
    8000457e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004582:	df843583          	ld	a1,-520(s0)
    80004586:	855a                	mv	a0,s6
    80004588:	ffffd097          	auipc	ra,0xffffd
    8000458c:	a2c080e7          	jalr	-1492(ra) # 80000fb4 <proc_freepagetable>
  if(ip){
    80004590:	da0a93e3          	bnez	s5,80004336 <exec+0x88>
  return -1;
    80004594:	557d                	li	a0,-1
    80004596:	bb55                	j	8000434a <exec+0x9c>
    80004598:	df243c23          	sd	s2,-520(s0)
    8000459c:	b7dd                	j	80004582 <exec+0x2d4>
    8000459e:	df243c23          	sd	s2,-520(s0)
    800045a2:	b7c5                	j	80004582 <exec+0x2d4>
    800045a4:	df243c23          	sd	s2,-520(s0)
    800045a8:	bfe9                	j	80004582 <exec+0x2d4>
    800045aa:	df243c23          	sd	s2,-520(s0)
    800045ae:	bfd1                	j	80004582 <exec+0x2d4>
  sz = sz1;
    800045b0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045b4:	4a81                	li	s5,0
    800045b6:	b7f1                	j	80004582 <exec+0x2d4>
  sz = sz1;
    800045b8:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045bc:	4a81                	li	s5,0
    800045be:	b7d1                	j	80004582 <exec+0x2d4>
  sz = sz1;
    800045c0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800045c4:	4a81                	li	s5,0
    800045c6:	bf75                	j	80004582 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800045c8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045cc:	e0843783          	ld	a5,-504(s0)
    800045d0:	0017869b          	addiw	a3,a5,1
    800045d4:	e0d43423          	sd	a3,-504(s0)
    800045d8:	e0043783          	ld	a5,-512(s0)
    800045dc:	0387879b          	addiw	a5,a5,56
    800045e0:	e8845703          	lhu	a4,-376(s0)
    800045e4:	e0e6dfe3          	bge	a3,a4,80004402 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800045e8:	2781                	sext.w	a5,a5
    800045ea:	e0f43023          	sd	a5,-512(s0)
    800045ee:	03800713          	li	a4,56
    800045f2:	86be                	mv	a3,a5
    800045f4:	e1840613          	addi	a2,s0,-488
    800045f8:	4581                	li	a1,0
    800045fa:	8556                	mv	a0,s5
    800045fc:	fffff097          	auipc	ra,0xfffff
    80004600:	a58080e7          	jalr	-1448(ra) # 80003054 <readi>
    80004604:	03800793          	li	a5,56
    80004608:	f6f51be3          	bne	a0,a5,8000457e <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000460c:	e1842783          	lw	a5,-488(s0)
    80004610:	4705                	li	a4,1
    80004612:	fae79de3          	bne	a5,a4,800045cc <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80004616:	e4043483          	ld	s1,-448(s0)
    8000461a:	e3843783          	ld	a5,-456(s0)
    8000461e:	f6f4ede3          	bltu	s1,a5,80004598 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004622:	e2843783          	ld	a5,-472(s0)
    80004626:	94be                	add	s1,s1,a5
    80004628:	f6f4ebe3          	bltu	s1,a5,8000459e <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    8000462c:	de043703          	ld	a4,-544(s0)
    80004630:	8ff9                	and	a5,a5,a4
    80004632:	fbad                	bnez	a5,800045a4 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004634:	e1c42503          	lw	a0,-484(s0)
    80004638:	00000097          	auipc	ra,0x0
    8000463c:	c5c080e7          	jalr	-932(ra) # 80004294 <flags2perm>
    80004640:	86aa                	mv	a3,a0
    80004642:	8626                	mv	a2,s1
    80004644:	85ca                	mv	a1,s2
    80004646:	855a                	mv	a0,s6
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	270080e7          	jalr	624(ra) # 800008b8 <uvmalloc>
    80004650:	dea43c23          	sd	a0,-520(s0)
    80004654:	d939                	beqz	a0,800045aa <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004656:	e2843c03          	ld	s8,-472(s0)
    8000465a:	e2042c83          	lw	s9,-480(s0)
    8000465e:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004662:	f60b83e3          	beqz	s7,800045c8 <exec+0x31a>
    80004666:	89de                	mv	s3,s7
    80004668:	4481                	li	s1,0
    8000466a:	bb9d                	j	800043e0 <exec+0x132>

000000008000466c <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000466c:	7179                	addi	sp,sp,-48
    8000466e:	f406                	sd	ra,40(sp)
    80004670:	f022                	sd	s0,32(sp)
    80004672:	ec26                	sd	s1,24(sp)
    80004674:	e84a                	sd	s2,16(sp)
    80004676:	1800                	addi	s0,sp,48
    80004678:	892e                	mv	s2,a1
    8000467a:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000467c:	fdc40593          	addi	a1,s0,-36
    80004680:	ffffe097          	auipc	ra,0xffffe
    80004684:	a12080e7          	jalr	-1518(ra) # 80002092 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004688:	fdc42703          	lw	a4,-36(s0)
    8000468c:	47bd                	li	a5,15
    8000468e:	02e7eb63          	bltu	a5,a4,800046c4 <argfd+0x58>
    80004692:	ffffc097          	auipc	ra,0xffffc
    80004696:	7c2080e7          	jalr	1986(ra) # 80000e54 <myproc>
    8000469a:	fdc42703          	lw	a4,-36(s0)
    8000469e:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd8caa>
    800046a2:	078e                	slli	a5,a5,0x3
    800046a4:	953e                	add	a0,a0,a5
    800046a6:	611c                	ld	a5,0(a0)
    800046a8:	c385                	beqz	a5,800046c8 <argfd+0x5c>
    return -1;
  if(pfd)
    800046aa:	00090463          	beqz	s2,800046b2 <argfd+0x46>
    *pfd = fd;
    800046ae:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800046b2:	4501                	li	a0,0
  if(pf)
    800046b4:	c091                	beqz	s1,800046b8 <argfd+0x4c>
    *pf = f;
    800046b6:	e09c                	sd	a5,0(s1)
}
    800046b8:	70a2                	ld	ra,40(sp)
    800046ba:	7402                	ld	s0,32(sp)
    800046bc:	64e2                	ld	s1,24(sp)
    800046be:	6942                	ld	s2,16(sp)
    800046c0:	6145                	addi	sp,sp,48
    800046c2:	8082                	ret
    return -1;
    800046c4:	557d                	li	a0,-1
    800046c6:	bfcd                	j	800046b8 <argfd+0x4c>
    800046c8:	557d                	li	a0,-1
    800046ca:	b7fd                	j	800046b8 <argfd+0x4c>

00000000800046cc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800046cc:	1101                	addi	sp,sp,-32
    800046ce:	ec06                	sd	ra,24(sp)
    800046d0:	e822                	sd	s0,16(sp)
    800046d2:	e426                	sd	s1,8(sp)
    800046d4:	1000                	addi	s0,sp,32
    800046d6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800046d8:	ffffc097          	auipc	ra,0xffffc
    800046dc:	77c080e7          	jalr	1916(ra) # 80000e54 <myproc>
    800046e0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800046e2:	0d050793          	addi	a5,a0,208
    800046e6:	4501                	li	a0,0
    800046e8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800046ea:	6398                	ld	a4,0(a5)
    800046ec:	cb19                	beqz	a4,80004702 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800046ee:	2505                	addiw	a0,a0,1
    800046f0:	07a1                	addi	a5,a5,8
    800046f2:	fed51ce3          	bne	a0,a3,800046ea <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800046f6:	557d                	li	a0,-1
}
    800046f8:	60e2                	ld	ra,24(sp)
    800046fa:	6442                	ld	s0,16(sp)
    800046fc:	64a2                	ld	s1,8(sp)
    800046fe:	6105                	addi	sp,sp,32
    80004700:	8082                	ret
      p->ofile[fd] = f;
    80004702:	01a50793          	addi	a5,a0,26
    80004706:	078e                	slli	a5,a5,0x3
    80004708:	963e                	add	a2,a2,a5
    8000470a:	e204                	sd	s1,0(a2)
      return fd;
    8000470c:	b7f5                	j	800046f8 <fdalloc+0x2c>

000000008000470e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000470e:	715d                	addi	sp,sp,-80
    80004710:	e486                	sd	ra,72(sp)
    80004712:	e0a2                	sd	s0,64(sp)
    80004714:	fc26                	sd	s1,56(sp)
    80004716:	f84a                	sd	s2,48(sp)
    80004718:	f44e                	sd	s3,40(sp)
    8000471a:	f052                	sd	s4,32(sp)
    8000471c:	ec56                	sd	s5,24(sp)
    8000471e:	e85a                	sd	s6,16(sp)
    80004720:	0880                	addi	s0,sp,80
    80004722:	8b2e                	mv	s6,a1
    80004724:	89b2                	mv	s3,a2
    80004726:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004728:	fb040593          	addi	a1,s0,-80
    8000472c:	fffff097          	auipc	ra,0xfffff
    80004730:	e3e080e7          	jalr	-450(ra) # 8000356a <nameiparent>
    80004734:	84aa                	mv	s1,a0
    80004736:	14050f63          	beqz	a0,80004894 <create+0x186>
    return 0;

  ilock(dp);
    8000473a:	ffffe097          	auipc	ra,0xffffe
    8000473e:	666080e7          	jalr	1638(ra) # 80002da0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004742:	4601                	li	a2,0
    80004744:	fb040593          	addi	a1,s0,-80
    80004748:	8526                	mv	a0,s1
    8000474a:	fffff097          	auipc	ra,0xfffff
    8000474e:	b3a080e7          	jalr	-1222(ra) # 80003284 <dirlookup>
    80004752:	8aaa                	mv	s5,a0
    80004754:	c931                	beqz	a0,800047a8 <create+0x9a>
    iunlockput(dp);
    80004756:	8526                	mv	a0,s1
    80004758:	fffff097          	auipc	ra,0xfffff
    8000475c:	8aa080e7          	jalr	-1878(ra) # 80003002 <iunlockput>
    ilock(ip);
    80004760:	8556                	mv	a0,s5
    80004762:	ffffe097          	auipc	ra,0xffffe
    80004766:	63e080e7          	jalr	1598(ra) # 80002da0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000476a:	000b059b          	sext.w	a1,s6
    8000476e:	4789                	li	a5,2
    80004770:	02f59563          	bne	a1,a5,8000479a <create+0x8c>
    80004774:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffd8cd4>
    80004778:	37f9                	addiw	a5,a5,-2
    8000477a:	17c2                	slli	a5,a5,0x30
    8000477c:	93c1                	srli	a5,a5,0x30
    8000477e:	4705                	li	a4,1
    80004780:	00f76d63          	bltu	a4,a5,8000479a <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004784:	8556                	mv	a0,s5
    80004786:	60a6                	ld	ra,72(sp)
    80004788:	6406                	ld	s0,64(sp)
    8000478a:	74e2                	ld	s1,56(sp)
    8000478c:	7942                	ld	s2,48(sp)
    8000478e:	79a2                	ld	s3,40(sp)
    80004790:	7a02                	ld	s4,32(sp)
    80004792:	6ae2                	ld	s5,24(sp)
    80004794:	6b42                	ld	s6,16(sp)
    80004796:	6161                	addi	sp,sp,80
    80004798:	8082                	ret
    iunlockput(ip);
    8000479a:	8556                	mv	a0,s5
    8000479c:	fffff097          	auipc	ra,0xfffff
    800047a0:	866080e7          	jalr	-1946(ra) # 80003002 <iunlockput>
    return 0;
    800047a4:	4a81                	li	s5,0
    800047a6:	bff9                	j	80004784 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    800047a8:	85da                	mv	a1,s6
    800047aa:	4088                	lw	a0,0(s1)
    800047ac:	ffffe097          	auipc	ra,0xffffe
    800047b0:	456080e7          	jalr	1110(ra) # 80002c02 <ialloc>
    800047b4:	8a2a                	mv	s4,a0
    800047b6:	c539                	beqz	a0,80004804 <create+0xf6>
  ilock(ip);
    800047b8:	ffffe097          	auipc	ra,0xffffe
    800047bc:	5e8080e7          	jalr	1512(ra) # 80002da0 <ilock>
  ip->major = major;
    800047c0:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800047c4:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800047c8:	4905                	li	s2,1
    800047ca:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800047ce:	8552                	mv	a0,s4
    800047d0:	ffffe097          	auipc	ra,0xffffe
    800047d4:	504080e7          	jalr	1284(ra) # 80002cd4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800047d8:	000b059b          	sext.w	a1,s6
    800047dc:	03258b63          	beq	a1,s2,80004812 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800047e0:	004a2603          	lw	a2,4(s4)
    800047e4:	fb040593          	addi	a1,s0,-80
    800047e8:	8526                	mv	a0,s1
    800047ea:	fffff097          	auipc	ra,0xfffff
    800047ee:	cb0080e7          	jalr	-848(ra) # 8000349a <dirlink>
    800047f2:	06054f63          	bltz	a0,80004870 <create+0x162>
  iunlockput(dp);
    800047f6:	8526                	mv	a0,s1
    800047f8:	fffff097          	auipc	ra,0xfffff
    800047fc:	80a080e7          	jalr	-2038(ra) # 80003002 <iunlockput>
  return ip;
    80004800:	8ad2                	mv	s5,s4
    80004802:	b749                	j	80004784 <create+0x76>
    iunlockput(dp);
    80004804:	8526                	mv	a0,s1
    80004806:	ffffe097          	auipc	ra,0xffffe
    8000480a:	7fc080e7          	jalr	2044(ra) # 80003002 <iunlockput>
    return 0;
    8000480e:	8ad2                	mv	s5,s4
    80004810:	bf95                	j	80004784 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004812:	004a2603          	lw	a2,4(s4)
    80004816:	00004597          	auipc	a1,0x4
    8000481a:	e7258593          	addi	a1,a1,-398 # 80008688 <syscalls+0x2b8>
    8000481e:	8552                	mv	a0,s4
    80004820:	fffff097          	auipc	ra,0xfffff
    80004824:	c7a080e7          	jalr	-902(ra) # 8000349a <dirlink>
    80004828:	04054463          	bltz	a0,80004870 <create+0x162>
    8000482c:	40d0                	lw	a2,4(s1)
    8000482e:	00004597          	auipc	a1,0x4
    80004832:	e6258593          	addi	a1,a1,-414 # 80008690 <syscalls+0x2c0>
    80004836:	8552                	mv	a0,s4
    80004838:	fffff097          	auipc	ra,0xfffff
    8000483c:	c62080e7          	jalr	-926(ra) # 8000349a <dirlink>
    80004840:	02054863          	bltz	a0,80004870 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    80004844:	004a2603          	lw	a2,4(s4)
    80004848:	fb040593          	addi	a1,s0,-80
    8000484c:	8526                	mv	a0,s1
    8000484e:	fffff097          	auipc	ra,0xfffff
    80004852:	c4c080e7          	jalr	-948(ra) # 8000349a <dirlink>
    80004856:	00054d63          	bltz	a0,80004870 <create+0x162>
    dp->nlink++;  // for ".."
    8000485a:	04a4d783          	lhu	a5,74(s1)
    8000485e:	2785                	addiw	a5,a5,1
    80004860:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004864:	8526                	mv	a0,s1
    80004866:	ffffe097          	auipc	ra,0xffffe
    8000486a:	46e080e7          	jalr	1134(ra) # 80002cd4 <iupdate>
    8000486e:	b761                	j	800047f6 <create+0xe8>
  ip->nlink = 0;
    80004870:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004874:	8552                	mv	a0,s4
    80004876:	ffffe097          	auipc	ra,0xffffe
    8000487a:	45e080e7          	jalr	1118(ra) # 80002cd4 <iupdate>
  iunlockput(ip);
    8000487e:	8552                	mv	a0,s4
    80004880:	ffffe097          	auipc	ra,0xffffe
    80004884:	782080e7          	jalr	1922(ra) # 80003002 <iunlockput>
  iunlockput(dp);
    80004888:	8526                	mv	a0,s1
    8000488a:	ffffe097          	auipc	ra,0xffffe
    8000488e:	778080e7          	jalr	1912(ra) # 80003002 <iunlockput>
  return 0;
    80004892:	bdcd                	j	80004784 <create+0x76>
    return 0;
    80004894:	8aaa                	mv	s5,a0
    80004896:	b5fd                	j	80004784 <create+0x76>

0000000080004898 <sys_dup>:
{
    80004898:	7179                	addi	sp,sp,-48
    8000489a:	f406                	sd	ra,40(sp)
    8000489c:	f022                	sd	s0,32(sp)
    8000489e:	ec26                	sd	s1,24(sp)
    800048a0:	e84a                	sd	s2,16(sp)
    800048a2:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800048a4:	fd840613          	addi	a2,s0,-40
    800048a8:	4581                	li	a1,0
    800048aa:	4501                	li	a0,0
    800048ac:	00000097          	auipc	ra,0x0
    800048b0:	dc0080e7          	jalr	-576(ra) # 8000466c <argfd>
    return -1;
    800048b4:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800048b6:	02054363          	bltz	a0,800048dc <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800048ba:	fd843903          	ld	s2,-40(s0)
    800048be:	854a                	mv	a0,s2
    800048c0:	00000097          	auipc	ra,0x0
    800048c4:	e0c080e7          	jalr	-500(ra) # 800046cc <fdalloc>
    800048c8:	84aa                	mv	s1,a0
    return -1;
    800048ca:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800048cc:	00054863          	bltz	a0,800048dc <sys_dup+0x44>
  filedup(f);
    800048d0:	854a                	mv	a0,s2
    800048d2:	fffff097          	auipc	ra,0xfffff
    800048d6:	310080e7          	jalr	784(ra) # 80003be2 <filedup>
  return fd;
    800048da:	87a6                	mv	a5,s1
}
    800048dc:	853e                	mv	a0,a5
    800048de:	70a2                	ld	ra,40(sp)
    800048e0:	7402                	ld	s0,32(sp)
    800048e2:	64e2                	ld	s1,24(sp)
    800048e4:	6942                	ld	s2,16(sp)
    800048e6:	6145                	addi	sp,sp,48
    800048e8:	8082                	ret

00000000800048ea <sys_read>:
{
    800048ea:	7179                	addi	sp,sp,-48
    800048ec:	f406                	sd	ra,40(sp)
    800048ee:	f022                	sd	s0,32(sp)
    800048f0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800048f2:	fd840593          	addi	a1,s0,-40
    800048f6:	4505                	li	a0,1
    800048f8:	ffffd097          	auipc	ra,0xffffd
    800048fc:	7ba080e7          	jalr	1978(ra) # 800020b2 <argaddr>
  argint(2, &n);
    80004900:	fe440593          	addi	a1,s0,-28
    80004904:	4509                	li	a0,2
    80004906:	ffffd097          	auipc	ra,0xffffd
    8000490a:	78c080e7          	jalr	1932(ra) # 80002092 <argint>
  if(argfd(0, 0, &f) < 0)
    8000490e:	fe840613          	addi	a2,s0,-24
    80004912:	4581                	li	a1,0
    80004914:	4501                	li	a0,0
    80004916:	00000097          	auipc	ra,0x0
    8000491a:	d56080e7          	jalr	-682(ra) # 8000466c <argfd>
    8000491e:	87aa                	mv	a5,a0
    return -1;
    80004920:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004922:	0007cc63          	bltz	a5,8000493a <sys_read+0x50>
  return fileread(f, p, n);
    80004926:	fe442603          	lw	a2,-28(s0)
    8000492a:	fd843583          	ld	a1,-40(s0)
    8000492e:	fe843503          	ld	a0,-24(s0)
    80004932:	fffff097          	auipc	ra,0xfffff
    80004936:	43c080e7          	jalr	1084(ra) # 80003d6e <fileread>
}
    8000493a:	70a2                	ld	ra,40(sp)
    8000493c:	7402                	ld	s0,32(sp)
    8000493e:	6145                	addi	sp,sp,48
    80004940:	8082                	ret

0000000080004942 <sys_write>:
{
    80004942:	7179                	addi	sp,sp,-48
    80004944:	f406                	sd	ra,40(sp)
    80004946:	f022                	sd	s0,32(sp)
    80004948:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000494a:	fd840593          	addi	a1,s0,-40
    8000494e:	4505                	li	a0,1
    80004950:	ffffd097          	auipc	ra,0xffffd
    80004954:	762080e7          	jalr	1890(ra) # 800020b2 <argaddr>
  argint(2, &n);
    80004958:	fe440593          	addi	a1,s0,-28
    8000495c:	4509                	li	a0,2
    8000495e:	ffffd097          	auipc	ra,0xffffd
    80004962:	734080e7          	jalr	1844(ra) # 80002092 <argint>
  if(argfd(0, 0, &f) < 0)
    80004966:	fe840613          	addi	a2,s0,-24
    8000496a:	4581                	li	a1,0
    8000496c:	4501                	li	a0,0
    8000496e:	00000097          	auipc	ra,0x0
    80004972:	cfe080e7          	jalr	-770(ra) # 8000466c <argfd>
    80004976:	87aa                	mv	a5,a0
    return -1;
    80004978:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000497a:	0007cc63          	bltz	a5,80004992 <sys_write+0x50>
  return filewrite(f, p, n);
    8000497e:	fe442603          	lw	a2,-28(s0)
    80004982:	fd843583          	ld	a1,-40(s0)
    80004986:	fe843503          	ld	a0,-24(s0)
    8000498a:	fffff097          	auipc	ra,0xfffff
    8000498e:	4a6080e7          	jalr	1190(ra) # 80003e30 <filewrite>
}
    80004992:	70a2                	ld	ra,40(sp)
    80004994:	7402                	ld	s0,32(sp)
    80004996:	6145                	addi	sp,sp,48
    80004998:	8082                	ret

000000008000499a <sys_close>:
{
    8000499a:	1101                	addi	sp,sp,-32
    8000499c:	ec06                	sd	ra,24(sp)
    8000499e:	e822                	sd	s0,16(sp)
    800049a0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800049a2:	fe040613          	addi	a2,s0,-32
    800049a6:	fec40593          	addi	a1,s0,-20
    800049aa:	4501                	li	a0,0
    800049ac:	00000097          	auipc	ra,0x0
    800049b0:	cc0080e7          	jalr	-832(ra) # 8000466c <argfd>
    return -1;
    800049b4:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800049b6:	02054463          	bltz	a0,800049de <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	49a080e7          	jalr	1178(ra) # 80000e54 <myproc>
    800049c2:	fec42783          	lw	a5,-20(s0)
    800049c6:	07e9                	addi	a5,a5,26
    800049c8:	078e                	slli	a5,a5,0x3
    800049ca:	953e                	add	a0,a0,a5
    800049cc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800049d0:	fe043503          	ld	a0,-32(s0)
    800049d4:	fffff097          	auipc	ra,0xfffff
    800049d8:	260080e7          	jalr	608(ra) # 80003c34 <fileclose>
  return 0;
    800049dc:	4781                	li	a5,0
}
    800049de:	853e                	mv	a0,a5
    800049e0:	60e2                	ld	ra,24(sp)
    800049e2:	6442                	ld	s0,16(sp)
    800049e4:	6105                	addi	sp,sp,32
    800049e6:	8082                	ret

00000000800049e8 <sys_fstat>:
{
    800049e8:	1101                	addi	sp,sp,-32
    800049ea:	ec06                	sd	ra,24(sp)
    800049ec:	e822                	sd	s0,16(sp)
    800049ee:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800049f0:	fe040593          	addi	a1,s0,-32
    800049f4:	4505                	li	a0,1
    800049f6:	ffffd097          	auipc	ra,0xffffd
    800049fa:	6bc080e7          	jalr	1724(ra) # 800020b2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800049fe:	fe840613          	addi	a2,s0,-24
    80004a02:	4581                	li	a1,0
    80004a04:	4501                	li	a0,0
    80004a06:	00000097          	auipc	ra,0x0
    80004a0a:	c66080e7          	jalr	-922(ra) # 8000466c <argfd>
    80004a0e:	87aa                	mv	a5,a0
    return -1;
    80004a10:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a12:	0007ca63          	bltz	a5,80004a26 <sys_fstat+0x3e>
  return filestat(f, st);
    80004a16:	fe043583          	ld	a1,-32(s0)
    80004a1a:	fe843503          	ld	a0,-24(s0)
    80004a1e:	fffff097          	auipc	ra,0xfffff
    80004a22:	2de080e7          	jalr	734(ra) # 80003cfc <filestat>
}
    80004a26:	60e2                	ld	ra,24(sp)
    80004a28:	6442                	ld	s0,16(sp)
    80004a2a:	6105                	addi	sp,sp,32
    80004a2c:	8082                	ret

0000000080004a2e <sys_link>:
{
    80004a2e:	7169                	addi	sp,sp,-304
    80004a30:	f606                	sd	ra,296(sp)
    80004a32:	f222                	sd	s0,288(sp)
    80004a34:	ee26                	sd	s1,280(sp)
    80004a36:	ea4a                	sd	s2,272(sp)
    80004a38:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a3a:	08000613          	li	a2,128
    80004a3e:	ed040593          	addi	a1,s0,-304
    80004a42:	4501                	li	a0,0
    80004a44:	ffffd097          	auipc	ra,0xffffd
    80004a48:	68e080e7          	jalr	1678(ra) # 800020d2 <argstr>
    return -1;
    80004a4c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a4e:	10054e63          	bltz	a0,80004b6a <sys_link+0x13c>
    80004a52:	08000613          	li	a2,128
    80004a56:	f5040593          	addi	a1,s0,-176
    80004a5a:	4505                	li	a0,1
    80004a5c:	ffffd097          	auipc	ra,0xffffd
    80004a60:	676080e7          	jalr	1654(ra) # 800020d2 <argstr>
    return -1;
    80004a64:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004a66:	10054263          	bltz	a0,80004b6a <sys_link+0x13c>
  begin_op();
    80004a6a:	fffff097          	auipc	ra,0xfffff
    80004a6e:	d02080e7          	jalr	-766(ra) # 8000376c <begin_op>
  if((ip = namei(old)) == 0){
    80004a72:	ed040513          	addi	a0,s0,-304
    80004a76:	fffff097          	auipc	ra,0xfffff
    80004a7a:	ad6080e7          	jalr	-1322(ra) # 8000354c <namei>
    80004a7e:	84aa                	mv	s1,a0
    80004a80:	c551                	beqz	a0,80004b0c <sys_link+0xde>
  ilock(ip);
    80004a82:	ffffe097          	auipc	ra,0xffffe
    80004a86:	31e080e7          	jalr	798(ra) # 80002da0 <ilock>
  if(ip->type == T_DIR){
    80004a8a:	04449703          	lh	a4,68(s1)
    80004a8e:	4785                	li	a5,1
    80004a90:	08f70463          	beq	a4,a5,80004b18 <sys_link+0xea>
  ip->nlink++;
    80004a94:	04a4d783          	lhu	a5,74(s1)
    80004a98:	2785                	addiw	a5,a5,1
    80004a9a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004a9e:	8526                	mv	a0,s1
    80004aa0:	ffffe097          	auipc	ra,0xffffe
    80004aa4:	234080e7          	jalr	564(ra) # 80002cd4 <iupdate>
  iunlock(ip);
    80004aa8:	8526                	mv	a0,s1
    80004aaa:	ffffe097          	auipc	ra,0xffffe
    80004aae:	3b8080e7          	jalr	952(ra) # 80002e62 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004ab2:	fd040593          	addi	a1,s0,-48
    80004ab6:	f5040513          	addi	a0,s0,-176
    80004aba:	fffff097          	auipc	ra,0xfffff
    80004abe:	ab0080e7          	jalr	-1360(ra) # 8000356a <nameiparent>
    80004ac2:	892a                	mv	s2,a0
    80004ac4:	c935                	beqz	a0,80004b38 <sys_link+0x10a>
  ilock(dp);
    80004ac6:	ffffe097          	auipc	ra,0xffffe
    80004aca:	2da080e7          	jalr	730(ra) # 80002da0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004ace:	00092703          	lw	a4,0(s2)
    80004ad2:	409c                	lw	a5,0(s1)
    80004ad4:	04f71d63          	bne	a4,a5,80004b2e <sys_link+0x100>
    80004ad8:	40d0                	lw	a2,4(s1)
    80004ada:	fd040593          	addi	a1,s0,-48
    80004ade:	854a                	mv	a0,s2
    80004ae0:	fffff097          	auipc	ra,0xfffff
    80004ae4:	9ba080e7          	jalr	-1606(ra) # 8000349a <dirlink>
    80004ae8:	04054363          	bltz	a0,80004b2e <sys_link+0x100>
  iunlockput(dp);
    80004aec:	854a                	mv	a0,s2
    80004aee:	ffffe097          	auipc	ra,0xffffe
    80004af2:	514080e7          	jalr	1300(ra) # 80003002 <iunlockput>
  iput(ip);
    80004af6:	8526                	mv	a0,s1
    80004af8:	ffffe097          	auipc	ra,0xffffe
    80004afc:	462080e7          	jalr	1122(ra) # 80002f5a <iput>
  end_op();
    80004b00:	fffff097          	auipc	ra,0xfffff
    80004b04:	cea080e7          	jalr	-790(ra) # 800037ea <end_op>
  return 0;
    80004b08:	4781                	li	a5,0
    80004b0a:	a085                	j	80004b6a <sys_link+0x13c>
    end_op();
    80004b0c:	fffff097          	auipc	ra,0xfffff
    80004b10:	cde080e7          	jalr	-802(ra) # 800037ea <end_op>
    return -1;
    80004b14:	57fd                	li	a5,-1
    80004b16:	a891                	j	80004b6a <sys_link+0x13c>
    iunlockput(ip);
    80004b18:	8526                	mv	a0,s1
    80004b1a:	ffffe097          	auipc	ra,0xffffe
    80004b1e:	4e8080e7          	jalr	1256(ra) # 80003002 <iunlockput>
    end_op();
    80004b22:	fffff097          	auipc	ra,0xfffff
    80004b26:	cc8080e7          	jalr	-824(ra) # 800037ea <end_op>
    return -1;
    80004b2a:	57fd                	li	a5,-1
    80004b2c:	a83d                	j	80004b6a <sys_link+0x13c>
    iunlockput(dp);
    80004b2e:	854a                	mv	a0,s2
    80004b30:	ffffe097          	auipc	ra,0xffffe
    80004b34:	4d2080e7          	jalr	1234(ra) # 80003002 <iunlockput>
  ilock(ip);
    80004b38:	8526                	mv	a0,s1
    80004b3a:	ffffe097          	auipc	ra,0xffffe
    80004b3e:	266080e7          	jalr	614(ra) # 80002da0 <ilock>
  ip->nlink--;
    80004b42:	04a4d783          	lhu	a5,74(s1)
    80004b46:	37fd                	addiw	a5,a5,-1
    80004b48:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b4c:	8526                	mv	a0,s1
    80004b4e:	ffffe097          	auipc	ra,0xffffe
    80004b52:	186080e7          	jalr	390(ra) # 80002cd4 <iupdate>
  iunlockput(ip);
    80004b56:	8526                	mv	a0,s1
    80004b58:	ffffe097          	auipc	ra,0xffffe
    80004b5c:	4aa080e7          	jalr	1194(ra) # 80003002 <iunlockput>
  end_op();
    80004b60:	fffff097          	auipc	ra,0xfffff
    80004b64:	c8a080e7          	jalr	-886(ra) # 800037ea <end_op>
  return -1;
    80004b68:	57fd                	li	a5,-1
}
    80004b6a:	853e                	mv	a0,a5
    80004b6c:	70b2                	ld	ra,296(sp)
    80004b6e:	7412                	ld	s0,288(sp)
    80004b70:	64f2                	ld	s1,280(sp)
    80004b72:	6952                	ld	s2,272(sp)
    80004b74:	6155                	addi	sp,sp,304
    80004b76:	8082                	ret

0000000080004b78 <sys_unlink>:
{
    80004b78:	7151                	addi	sp,sp,-240
    80004b7a:	f586                	sd	ra,232(sp)
    80004b7c:	f1a2                	sd	s0,224(sp)
    80004b7e:	eda6                	sd	s1,216(sp)
    80004b80:	e9ca                	sd	s2,208(sp)
    80004b82:	e5ce                	sd	s3,200(sp)
    80004b84:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004b86:	08000613          	li	a2,128
    80004b8a:	f3040593          	addi	a1,s0,-208
    80004b8e:	4501                	li	a0,0
    80004b90:	ffffd097          	auipc	ra,0xffffd
    80004b94:	542080e7          	jalr	1346(ra) # 800020d2 <argstr>
    80004b98:	18054163          	bltz	a0,80004d1a <sys_unlink+0x1a2>
  begin_op();
    80004b9c:	fffff097          	auipc	ra,0xfffff
    80004ba0:	bd0080e7          	jalr	-1072(ra) # 8000376c <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004ba4:	fb040593          	addi	a1,s0,-80
    80004ba8:	f3040513          	addi	a0,s0,-208
    80004bac:	fffff097          	auipc	ra,0xfffff
    80004bb0:	9be080e7          	jalr	-1602(ra) # 8000356a <nameiparent>
    80004bb4:	84aa                	mv	s1,a0
    80004bb6:	c979                	beqz	a0,80004c8c <sys_unlink+0x114>
  ilock(dp);
    80004bb8:	ffffe097          	auipc	ra,0xffffe
    80004bbc:	1e8080e7          	jalr	488(ra) # 80002da0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004bc0:	00004597          	auipc	a1,0x4
    80004bc4:	ac858593          	addi	a1,a1,-1336 # 80008688 <syscalls+0x2b8>
    80004bc8:	fb040513          	addi	a0,s0,-80
    80004bcc:	ffffe097          	auipc	ra,0xffffe
    80004bd0:	69e080e7          	jalr	1694(ra) # 8000326a <namecmp>
    80004bd4:	14050a63          	beqz	a0,80004d28 <sys_unlink+0x1b0>
    80004bd8:	00004597          	auipc	a1,0x4
    80004bdc:	ab858593          	addi	a1,a1,-1352 # 80008690 <syscalls+0x2c0>
    80004be0:	fb040513          	addi	a0,s0,-80
    80004be4:	ffffe097          	auipc	ra,0xffffe
    80004be8:	686080e7          	jalr	1670(ra) # 8000326a <namecmp>
    80004bec:	12050e63          	beqz	a0,80004d28 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004bf0:	f2c40613          	addi	a2,s0,-212
    80004bf4:	fb040593          	addi	a1,s0,-80
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	ffffe097          	auipc	ra,0xffffe
    80004bfe:	68a080e7          	jalr	1674(ra) # 80003284 <dirlookup>
    80004c02:	892a                	mv	s2,a0
    80004c04:	12050263          	beqz	a0,80004d28 <sys_unlink+0x1b0>
  ilock(ip);
    80004c08:	ffffe097          	auipc	ra,0xffffe
    80004c0c:	198080e7          	jalr	408(ra) # 80002da0 <ilock>
  if(ip->nlink < 1)
    80004c10:	04a91783          	lh	a5,74(s2)
    80004c14:	08f05263          	blez	a5,80004c98 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004c18:	04491703          	lh	a4,68(s2)
    80004c1c:	4785                	li	a5,1
    80004c1e:	08f70563          	beq	a4,a5,80004ca8 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004c22:	4641                	li	a2,16
    80004c24:	4581                	li	a1,0
    80004c26:	fc040513          	addi	a0,s0,-64
    80004c2a:	ffffb097          	auipc	ra,0xffffb
    80004c2e:	550080e7          	jalr	1360(ra) # 8000017a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004c32:	4741                	li	a4,16
    80004c34:	f2c42683          	lw	a3,-212(s0)
    80004c38:	fc040613          	addi	a2,s0,-64
    80004c3c:	4581                	li	a1,0
    80004c3e:	8526                	mv	a0,s1
    80004c40:	ffffe097          	auipc	ra,0xffffe
    80004c44:	50c080e7          	jalr	1292(ra) # 8000314c <writei>
    80004c48:	47c1                	li	a5,16
    80004c4a:	0af51563          	bne	a0,a5,80004cf4 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004c4e:	04491703          	lh	a4,68(s2)
    80004c52:	4785                	li	a5,1
    80004c54:	0af70863          	beq	a4,a5,80004d04 <sys_unlink+0x18c>
  iunlockput(dp);
    80004c58:	8526                	mv	a0,s1
    80004c5a:	ffffe097          	auipc	ra,0xffffe
    80004c5e:	3a8080e7          	jalr	936(ra) # 80003002 <iunlockput>
  ip->nlink--;
    80004c62:	04a95783          	lhu	a5,74(s2)
    80004c66:	37fd                	addiw	a5,a5,-1
    80004c68:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004c6c:	854a                	mv	a0,s2
    80004c6e:	ffffe097          	auipc	ra,0xffffe
    80004c72:	066080e7          	jalr	102(ra) # 80002cd4 <iupdate>
  iunlockput(ip);
    80004c76:	854a                	mv	a0,s2
    80004c78:	ffffe097          	auipc	ra,0xffffe
    80004c7c:	38a080e7          	jalr	906(ra) # 80003002 <iunlockput>
  end_op();
    80004c80:	fffff097          	auipc	ra,0xfffff
    80004c84:	b6a080e7          	jalr	-1174(ra) # 800037ea <end_op>
  return 0;
    80004c88:	4501                	li	a0,0
    80004c8a:	a84d                	j	80004d3c <sys_unlink+0x1c4>
    end_op();
    80004c8c:	fffff097          	auipc	ra,0xfffff
    80004c90:	b5e080e7          	jalr	-1186(ra) # 800037ea <end_op>
    return -1;
    80004c94:	557d                	li	a0,-1
    80004c96:	a05d                	j	80004d3c <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004c98:	00004517          	auipc	a0,0x4
    80004c9c:	a0050513          	addi	a0,a0,-1536 # 80008698 <syscalls+0x2c8>
    80004ca0:	00001097          	auipc	ra,0x1
    80004ca4:	1ac080e7          	jalr	428(ra) # 80005e4c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004ca8:	04c92703          	lw	a4,76(s2)
    80004cac:	02000793          	li	a5,32
    80004cb0:	f6e7f9e3          	bgeu	a5,a4,80004c22 <sys_unlink+0xaa>
    80004cb4:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cb8:	4741                	li	a4,16
    80004cba:	86ce                	mv	a3,s3
    80004cbc:	f1840613          	addi	a2,s0,-232
    80004cc0:	4581                	li	a1,0
    80004cc2:	854a                	mv	a0,s2
    80004cc4:	ffffe097          	auipc	ra,0xffffe
    80004cc8:	390080e7          	jalr	912(ra) # 80003054 <readi>
    80004ccc:	47c1                	li	a5,16
    80004cce:	00f51b63          	bne	a0,a5,80004ce4 <sys_unlink+0x16c>
    if(de.inum != 0)
    80004cd2:	f1845783          	lhu	a5,-232(s0)
    80004cd6:	e7a1                	bnez	a5,80004d1e <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004cd8:	29c1                	addiw	s3,s3,16
    80004cda:	04c92783          	lw	a5,76(s2)
    80004cde:	fcf9ede3          	bltu	s3,a5,80004cb8 <sys_unlink+0x140>
    80004ce2:	b781                	j	80004c22 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004ce4:	00004517          	auipc	a0,0x4
    80004ce8:	9cc50513          	addi	a0,a0,-1588 # 800086b0 <syscalls+0x2e0>
    80004cec:	00001097          	auipc	ra,0x1
    80004cf0:	160080e7          	jalr	352(ra) # 80005e4c <panic>
    panic("unlink: writei");
    80004cf4:	00004517          	auipc	a0,0x4
    80004cf8:	9d450513          	addi	a0,a0,-1580 # 800086c8 <syscalls+0x2f8>
    80004cfc:	00001097          	auipc	ra,0x1
    80004d00:	150080e7          	jalr	336(ra) # 80005e4c <panic>
    dp->nlink--;
    80004d04:	04a4d783          	lhu	a5,74(s1)
    80004d08:	37fd                	addiw	a5,a5,-1
    80004d0a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004d0e:	8526                	mv	a0,s1
    80004d10:	ffffe097          	auipc	ra,0xffffe
    80004d14:	fc4080e7          	jalr	-60(ra) # 80002cd4 <iupdate>
    80004d18:	b781                	j	80004c58 <sys_unlink+0xe0>
    return -1;
    80004d1a:	557d                	li	a0,-1
    80004d1c:	a005                	j	80004d3c <sys_unlink+0x1c4>
    iunlockput(ip);
    80004d1e:	854a                	mv	a0,s2
    80004d20:	ffffe097          	auipc	ra,0xffffe
    80004d24:	2e2080e7          	jalr	738(ra) # 80003002 <iunlockput>
  iunlockput(dp);
    80004d28:	8526                	mv	a0,s1
    80004d2a:	ffffe097          	auipc	ra,0xffffe
    80004d2e:	2d8080e7          	jalr	728(ra) # 80003002 <iunlockput>
  end_op();
    80004d32:	fffff097          	auipc	ra,0xfffff
    80004d36:	ab8080e7          	jalr	-1352(ra) # 800037ea <end_op>
  return -1;
    80004d3a:	557d                	li	a0,-1
}
    80004d3c:	70ae                	ld	ra,232(sp)
    80004d3e:	740e                	ld	s0,224(sp)
    80004d40:	64ee                	ld	s1,216(sp)
    80004d42:	694e                	ld	s2,208(sp)
    80004d44:	69ae                	ld	s3,200(sp)
    80004d46:	616d                	addi	sp,sp,240
    80004d48:	8082                	ret

0000000080004d4a <sys_open>:

uint64
sys_open(void)
{
    80004d4a:	7131                	addi	sp,sp,-192
    80004d4c:	fd06                	sd	ra,184(sp)
    80004d4e:	f922                	sd	s0,176(sp)
    80004d50:	f526                	sd	s1,168(sp)
    80004d52:	f14a                	sd	s2,160(sp)
    80004d54:	ed4e                	sd	s3,152(sp)
    80004d56:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004d58:	f4c40593          	addi	a1,s0,-180
    80004d5c:	4505                	li	a0,1
    80004d5e:	ffffd097          	auipc	ra,0xffffd
    80004d62:	334080e7          	jalr	820(ra) # 80002092 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d66:	08000613          	li	a2,128
    80004d6a:	f5040593          	addi	a1,s0,-176
    80004d6e:	4501                	li	a0,0
    80004d70:	ffffd097          	auipc	ra,0xffffd
    80004d74:	362080e7          	jalr	866(ra) # 800020d2 <argstr>
    80004d78:	87aa                	mv	a5,a0
    return -1;
    80004d7a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004d7c:	0a07c963          	bltz	a5,80004e2e <sys_open+0xe4>

  begin_op();
    80004d80:	fffff097          	auipc	ra,0xfffff
    80004d84:	9ec080e7          	jalr	-1556(ra) # 8000376c <begin_op>

  if(omode & O_CREATE){
    80004d88:	f4c42783          	lw	a5,-180(s0)
    80004d8c:	2007f793          	andi	a5,a5,512
    80004d90:	cfc5                	beqz	a5,80004e48 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004d92:	4681                	li	a3,0
    80004d94:	4601                	li	a2,0
    80004d96:	4589                	li	a1,2
    80004d98:	f5040513          	addi	a0,s0,-176
    80004d9c:	00000097          	auipc	ra,0x0
    80004da0:	972080e7          	jalr	-1678(ra) # 8000470e <create>
    80004da4:	84aa                	mv	s1,a0
    if(ip == 0){
    80004da6:	c959                	beqz	a0,80004e3c <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004da8:	04449703          	lh	a4,68(s1)
    80004dac:	478d                	li	a5,3
    80004dae:	00f71763          	bne	a4,a5,80004dbc <sys_open+0x72>
    80004db2:	0464d703          	lhu	a4,70(s1)
    80004db6:	47a5                	li	a5,9
    80004db8:	0ce7ed63          	bltu	a5,a4,80004e92 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004dbc:	fffff097          	auipc	ra,0xfffff
    80004dc0:	dbc080e7          	jalr	-580(ra) # 80003b78 <filealloc>
    80004dc4:	89aa                	mv	s3,a0
    80004dc6:	10050363          	beqz	a0,80004ecc <sys_open+0x182>
    80004dca:	00000097          	auipc	ra,0x0
    80004dce:	902080e7          	jalr	-1790(ra) # 800046cc <fdalloc>
    80004dd2:	892a                	mv	s2,a0
    80004dd4:	0e054763          	bltz	a0,80004ec2 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004dd8:	04449703          	lh	a4,68(s1)
    80004ddc:	478d                	li	a5,3
    80004dde:	0cf70563          	beq	a4,a5,80004ea8 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004de2:	4789                	li	a5,2
    80004de4:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004de8:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004dec:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004df0:	f4c42783          	lw	a5,-180(s0)
    80004df4:	0017c713          	xori	a4,a5,1
    80004df8:	8b05                	andi	a4,a4,1
    80004dfa:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004dfe:	0037f713          	andi	a4,a5,3
    80004e02:	00e03733          	snez	a4,a4
    80004e06:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004e0a:	4007f793          	andi	a5,a5,1024
    80004e0e:	c791                	beqz	a5,80004e1a <sys_open+0xd0>
    80004e10:	04449703          	lh	a4,68(s1)
    80004e14:	4789                	li	a5,2
    80004e16:	0af70063          	beq	a4,a5,80004eb6 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004e1a:	8526                	mv	a0,s1
    80004e1c:	ffffe097          	auipc	ra,0xffffe
    80004e20:	046080e7          	jalr	70(ra) # 80002e62 <iunlock>
  end_op();
    80004e24:	fffff097          	auipc	ra,0xfffff
    80004e28:	9c6080e7          	jalr	-1594(ra) # 800037ea <end_op>

  return fd;
    80004e2c:	854a                	mv	a0,s2
}
    80004e2e:	70ea                	ld	ra,184(sp)
    80004e30:	744a                	ld	s0,176(sp)
    80004e32:	74aa                	ld	s1,168(sp)
    80004e34:	790a                	ld	s2,160(sp)
    80004e36:	69ea                	ld	s3,152(sp)
    80004e38:	6129                	addi	sp,sp,192
    80004e3a:	8082                	ret
      end_op();
    80004e3c:	fffff097          	auipc	ra,0xfffff
    80004e40:	9ae080e7          	jalr	-1618(ra) # 800037ea <end_op>
      return -1;
    80004e44:	557d                	li	a0,-1
    80004e46:	b7e5                	j	80004e2e <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004e48:	f5040513          	addi	a0,s0,-176
    80004e4c:	ffffe097          	auipc	ra,0xffffe
    80004e50:	700080e7          	jalr	1792(ra) # 8000354c <namei>
    80004e54:	84aa                	mv	s1,a0
    80004e56:	c905                	beqz	a0,80004e86 <sys_open+0x13c>
    ilock(ip);
    80004e58:	ffffe097          	auipc	ra,0xffffe
    80004e5c:	f48080e7          	jalr	-184(ra) # 80002da0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004e60:	04449703          	lh	a4,68(s1)
    80004e64:	4785                	li	a5,1
    80004e66:	f4f711e3          	bne	a4,a5,80004da8 <sys_open+0x5e>
    80004e6a:	f4c42783          	lw	a5,-180(s0)
    80004e6e:	d7b9                	beqz	a5,80004dbc <sys_open+0x72>
      iunlockput(ip);
    80004e70:	8526                	mv	a0,s1
    80004e72:	ffffe097          	auipc	ra,0xffffe
    80004e76:	190080e7          	jalr	400(ra) # 80003002 <iunlockput>
      end_op();
    80004e7a:	fffff097          	auipc	ra,0xfffff
    80004e7e:	970080e7          	jalr	-1680(ra) # 800037ea <end_op>
      return -1;
    80004e82:	557d                	li	a0,-1
    80004e84:	b76d                	j	80004e2e <sys_open+0xe4>
      end_op();
    80004e86:	fffff097          	auipc	ra,0xfffff
    80004e8a:	964080e7          	jalr	-1692(ra) # 800037ea <end_op>
      return -1;
    80004e8e:	557d                	li	a0,-1
    80004e90:	bf79                	j	80004e2e <sys_open+0xe4>
    iunlockput(ip);
    80004e92:	8526                	mv	a0,s1
    80004e94:	ffffe097          	auipc	ra,0xffffe
    80004e98:	16e080e7          	jalr	366(ra) # 80003002 <iunlockput>
    end_op();
    80004e9c:	fffff097          	auipc	ra,0xfffff
    80004ea0:	94e080e7          	jalr	-1714(ra) # 800037ea <end_op>
    return -1;
    80004ea4:	557d                	li	a0,-1
    80004ea6:	b761                	j	80004e2e <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004ea8:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004eac:	04649783          	lh	a5,70(s1)
    80004eb0:	02f99223          	sh	a5,36(s3)
    80004eb4:	bf25                	j	80004dec <sys_open+0xa2>
    itrunc(ip);
    80004eb6:	8526                	mv	a0,s1
    80004eb8:	ffffe097          	auipc	ra,0xffffe
    80004ebc:	ff6080e7          	jalr	-10(ra) # 80002eae <itrunc>
    80004ec0:	bfa9                	j	80004e1a <sys_open+0xd0>
      fileclose(f);
    80004ec2:	854e                	mv	a0,s3
    80004ec4:	fffff097          	auipc	ra,0xfffff
    80004ec8:	d70080e7          	jalr	-656(ra) # 80003c34 <fileclose>
    iunlockput(ip);
    80004ecc:	8526                	mv	a0,s1
    80004ece:	ffffe097          	auipc	ra,0xffffe
    80004ed2:	134080e7          	jalr	308(ra) # 80003002 <iunlockput>
    end_op();
    80004ed6:	fffff097          	auipc	ra,0xfffff
    80004eda:	914080e7          	jalr	-1772(ra) # 800037ea <end_op>
    return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	b7b9                	j	80004e2e <sys_open+0xe4>

0000000080004ee2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004ee2:	7175                	addi	sp,sp,-144
    80004ee4:	e506                	sd	ra,136(sp)
    80004ee6:	e122                	sd	s0,128(sp)
    80004ee8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004eea:	fffff097          	auipc	ra,0xfffff
    80004eee:	882080e7          	jalr	-1918(ra) # 8000376c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004ef2:	08000613          	li	a2,128
    80004ef6:	f7040593          	addi	a1,s0,-144
    80004efa:	4501                	li	a0,0
    80004efc:	ffffd097          	auipc	ra,0xffffd
    80004f00:	1d6080e7          	jalr	470(ra) # 800020d2 <argstr>
    80004f04:	02054963          	bltz	a0,80004f36 <sys_mkdir+0x54>
    80004f08:	4681                	li	a3,0
    80004f0a:	4601                	li	a2,0
    80004f0c:	4585                	li	a1,1
    80004f0e:	f7040513          	addi	a0,s0,-144
    80004f12:	fffff097          	auipc	ra,0xfffff
    80004f16:	7fc080e7          	jalr	2044(ra) # 8000470e <create>
    80004f1a:	cd11                	beqz	a0,80004f36 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f1c:	ffffe097          	auipc	ra,0xffffe
    80004f20:	0e6080e7          	jalr	230(ra) # 80003002 <iunlockput>
  end_op();
    80004f24:	fffff097          	auipc	ra,0xfffff
    80004f28:	8c6080e7          	jalr	-1850(ra) # 800037ea <end_op>
  return 0;
    80004f2c:	4501                	li	a0,0
}
    80004f2e:	60aa                	ld	ra,136(sp)
    80004f30:	640a                	ld	s0,128(sp)
    80004f32:	6149                	addi	sp,sp,144
    80004f34:	8082                	ret
    end_op();
    80004f36:	fffff097          	auipc	ra,0xfffff
    80004f3a:	8b4080e7          	jalr	-1868(ra) # 800037ea <end_op>
    return -1;
    80004f3e:	557d                	li	a0,-1
    80004f40:	b7fd                	j	80004f2e <sys_mkdir+0x4c>

0000000080004f42 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004f42:	7135                	addi	sp,sp,-160
    80004f44:	ed06                	sd	ra,152(sp)
    80004f46:	e922                	sd	s0,144(sp)
    80004f48:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004f4a:	fffff097          	auipc	ra,0xfffff
    80004f4e:	822080e7          	jalr	-2014(ra) # 8000376c <begin_op>
  argint(1, &major);
    80004f52:	f6c40593          	addi	a1,s0,-148
    80004f56:	4505                	li	a0,1
    80004f58:	ffffd097          	auipc	ra,0xffffd
    80004f5c:	13a080e7          	jalr	314(ra) # 80002092 <argint>
  argint(2, &minor);
    80004f60:	f6840593          	addi	a1,s0,-152
    80004f64:	4509                	li	a0,2
    80004f66:	ffffd097          	auipc	ra,0xffffd
    80004f6a:	12c080e7          	jalr	300(ra) # 80002092 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f6e:	08000613          	li	a2,128
    80004f72:	f7040593          	addi	a1,s0,-144
    80004f76:	4501                	li	a0,0
    80004f78:	ffffd097          	auipc	ra,0xffffd
    80004f7c:	15a080e7          	jalr	346(ra) # 800020d2 <argstr>
    80004f80:	02054b63          	bltz	a0,80004fb6 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004f84:	f6841683          	lh	a3,-152(s0)
    80004f88:	f6c41603          	lh	a2,-148(s0)
    80004f8c:	458d                	li	a1,3
    80004f8e:	f7040513          	addi	a0,s0,-144
    80004f92:	fffff097          	auipc	ra,0xfffff
    80004f96:	77c080e7          	jalr	1916(ra) # 8000470e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004f9a:	cd11                	beqz	a0,80004fb6 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004f9c:	ffffe097          	auipc	ra,0xffffe
    80004fa0:	066080e7          	jalr	102(ra) # 80003002 <iunlockput>
  end_op();
    80004fa4:	fffff097          	auipc	ra,0xfffff
    80004fa8:	846080e7          	jalr	-1978(ra) # 800037ea <end_op>
  return 0;
    80004fac:	4501                	li	a0,0
}
    80004fae:	60ea                	ld	ra,152(sp)
    80004fb0:	644a                	ld	s0,144(sp)
    80004fb2:	610d                	addi	sp,sp,160
    80004fb4:	8082                	ret
    end_op();
    80004fb6:	fffff097          	auipc	ra,0xfffff
    80004fba:	834080e7          	jalr	-1996(ra) # 800037ea <end_op>
    return -1;
    80004fbe:	557d                	li	a0,-1
    80004fc0:	b7fd                	j	80004fae <sys_mknod+0x6c>

0000000080004fc2 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004fc2:	7135                	addi	sp,sp,-160
    80004fc4:	ed06                	sd	ra,152(sp)
    80004fc6:	e922                	sd	s0,144(sp)
    80004fc8:	e526                	sd	s1,136(sp)
    80004fca:	e14a                	sd	s2,128(sp)
    80004fcc:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004fce:	ffffc097          	auipc	ra,0xffffc
    80004fd2:	e86080e7          	jalr	-378(ra) # 80000e54 <myproc>
    80004fd6:	892a                	mv	s2,a0
  
  begin_op();
    80004fd8:	ffffe097          	auipc	ra,0xffffe
    80004fdc:	794080e7          	jalr	1940(ra) # 8000376c <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004fe0:	08000613          	li	a2,128
    80004fe4:	f6040593          	addi	a1,s0,-160
    80004fe8:	4501                	li	a0,0
    80004fea:	ffffd097          	auipc	ra,0xffffd
    80004fee:	0e8080e7          	jalr	232(ra) # 800020d2 <argstr>
    80004ff2:	04054b63          	bltz	a0,80005048 <sys_chdir+0x86>
    80004ff6:	f6040513          	addi	a0,s0,-160
    80004ffa:	ffffe097          	auipc	ra,0xffffe
    80004ffe:	552080e7          	jalr	1362(ra) # 8000354c <namei>
    80005002:	84aa                	mv	s1,a0
    80005004:	c131                	beqz	a0,80005048 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005006:	ffffe097          	auipc	ra,0xffffe
    8000500a:	d9a080e7          	jalr	-614(ra) # 80002da0 <ilock>
  if(ip->type != T_DIR){
    8000500e:	04449703          	lh	a4,68(s1)
    80005012:	4785                	li	a5,1
    80005014:	04f71063          	bne	a4,a5,80005054 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005018:	8526                	mv	a0,s1
    8000501a:	ffffe097          	auipc	ra,0xffffe
    8000501e:	e48080e7          	jalr	-440(ra) # 80002e62 <iunlock>
  iput(p->cwd);
    80005022:	15093503          	ld	a0,336(s2)
    80005026:	ffffe097          	auipc	ra,0xffffe
    8000502a:	f34080e7          	jalr	-204(ra) # 80002f5a <iput>
  end_op();
    8000502e:	ffffe097          	auipc	ra,0xffffe
    80005032:	7bc080e7          	jalr	1980(ra) # 800037ea <end_op>
  p->cwd = ip;
    80005036:	14993823          	sd	s1,336(s2)
  return 0;
    8000503a:	4501                	li	a0,0
}
    8000503c:	60ea                	ld	ra,152(sp)
    8000503e:	644a                	ld	s0,144(sp)
    80005040:	64aa                	ld	s1,136(sp)
    80005042:	690a                	ld	s2,128(sp)
    80005044:	610d                	addi	sp,sp,160
    80005046:	8082                	ret
    end_op();
    80005048:	ffffe097          	auipc	ra,0xffffe
    8000504c:	7a2080e7          	jalr	1954(ra) # 800037ea <end_op>
    return -1;
    80005050:	557d                	li	a0,-1
    80005052:	b7ed                	j	8000503c <sys_chdir+0x7a>
    iunlockput(ip);
    80005054:	8526                	mv	a0,s1
    80005056:	ffffe097          	auipc	ra,0xffffe
    8000505a:	fac080e7          	jalr	-84(ra) # 80003002 <iunlockput>
    end_op();
    8000505e:	ffffe097          	auipc	ra,0xffffe
    80005062:	78c080e7          	jalr	1932(ra) # 800037ea <end_op>
    return -1;
    80005066:	557d                	li	a0,-1
    80005068:	bfd1                	j	8000503c <sys_chdir+0x7a>

000000008000506a <sys_exec>:

uint64
sys_exec(void)
{
    8000506a:	7145                	addi	sp,sp,-464
    8000506c:	e786                	sd	ra,456(sp)
    8000506e:	e3a2                	sd	s0,448(sp)
    80005070:	ff26                	sd	s1,440(sp)
    80005072:	fb4a                	sd	s2,432(sp)
    80005074:	f74e                	sd	s3,424(sp)
    80005076:	f352                	sd	s4,416(sp)
    80005078:	ef56                	sd	s5,408(sp)
    8000507a:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000507c:	e3840593          	addi	a1,s0,-456
    80005080:	4505                	li	a0,1
    80005082:	ffffd097          	auipc	ra,0xffffd
    80005086:	030080e7          	jalr	48(ra) # 800020b2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000508a:	08000613          	li	a2,128
    8000508e:	f4040593          	addi	a1,s0,-192
    80005092:	4501                	li	a0,0
    80005094:	ffffd097          	auipc	ra,0xffffd
    80005098:	03e080e7          	jalr	62(ra) # 800020d2 <argstr>
    8000509c:	87aa                	mv	a5,a0
    return -1;
    8000509e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800050a0:	0c07c363          	bltz	a5,80005166 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    800050a4:	10000613          	li	a2,256
    800050a8:	4581                	li	a1,0
    800050aa:	e4040513          	addi	a0,s0,-448
    800050ae:	ffffb097          	auipc	ra,0xffffb
    800050b2:	0cc080e7          	jalr	204(ra) # 8000017a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800050b6:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    800050ba:	89a6                	mv	s3,s1
    800050bc:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800050be:	02000a13          	li	s4,32
    800050c2:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800050c6:	00391513          	slli	a0,s2,0x3
    800050ca:	e3040593          	addi	a1,s0,-464
    800050ce:	e3843783          	ld	a5,-456(s0)
    800050d2:	953e                	add	a0,a0,a5
    800050d4:	ffffd097          	auipc	ra,0xffffd
    800050d8:	f20080e7          	jalr	-224(ra) # 80001ff4 <fetchaddr>
    800050dc:	02054a63          	bltz	a0,80005110 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800050e0:	e3043783          	ld	a5,-464(s0)
    800050e4:	c3b9                	beqz	a5,8000512a <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800050e6:	ffffb097          	auipc	ra,0xffffb
    800050ea:	034080e7          	jalr	52(ra) # 8000011a <kalloc>
    800050ee:	85aa                	mv	a1,a0
    800050f0:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800050f4:	cd11                	beqz	a0,80005110 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800050f6:	6605                	lui	a2,0x1
    800050f8:	e3043503          	ld	a0,-464(s0)
    800050fc:	ffffd097          	auipc	ra,0xffffd
    80005100:	f4a080e7          	jalr	-182(ra) # 80002046 <fetchstr>
    80005104:	00054663          	bltz	a0,80005110 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005108:	0905                	addi	s2,s2,1
    8000510a:	09a1                	addi	s3,s3,8
    8000510c:	fb491be3          	bne	s2,s4,800050c2 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005110:	f4040913          	addi	s2,s0,-192
    80005114:	6088                	ld	a0,0(s1)
    80005116:	c539                	beqz	a0,80005164 <sys_exec+0xfa>
    kfree(argv[i]);
    80005118:	ffffb097          	auipc	ra,0xffffb
    8000511c:	f04080e7          	jalr	-252(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005120:	04a1                	addi	s1,s1,8
    80005122:	ff2499e3          	bne	s1,s2,80005114 <sys_exec+0xaa>
  return -1;
    80005126:	557d                	li	a0,-1
    80005128:	a83d                	j	80005166 <sys_exec+0xfc>
      argv[i] = 0;
    8000512a:	0a8e                	slli	s5,s5,0x3
    8000512c:	fc0a8793          	addi	a5,s5,-64
    80005130:	00878ab3          	add	s5,a5,s0
    80005134:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005138:	e4040593          	addi	a1,s0,-448
    8000513c:	f4040513          	addi	a0,s0,-192
    80005140:	fffff097          	auipc	ra,0xfffff
    80005144:	16e080e7          	jalr	366(ra) # 800042ae <exec>
    80005148:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000514a:	f4040993          	addi	s3,s0,-192
    8000514e:	6088                	ld	a0,0(s1)
    80005150:	c901                	beqz	a0,80005160 <sys_exec+0xf6>
    kfree(argv[i]);
    80005152:	ffffb097          	auipc	ra,0xffffb
    80005156:	eca080e7          	jalr	-310(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000515a:	04a1                	addi	s1,s1,8
    8000515c:	ff3499e3          	bne	s1,s3,8000514e <sys_exec+0xe4>
  return ret;
    80005160:	854a                	mv	a0,s2
    80005162:	a011                	j	80005166 <sys_exec+0xfc>
  return -1;
    80005164:	557d                	li	a0,-1
}
    80005166:	60be                	ld	ra,456(sp)
    80005168:	641e                	ld	s0,448(sp)
    8000516a:	74fa                	ld	s1,440(sp)
    8000516c:	795a                	ld	s2,432(sp)
    8000516e:	79ba                	ld	s3,424(sp)
    80005170:	7a1a                	ld	s4,416(sp)
    80005172:	6afa                	ld	s5,408(sp)
    80005174:	6179                	addi	sp,sp,464
    80005176:	8082                	ret

0000000080005178 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005178:	7139                	addi	sp,sp,-64
    8000517a:	fc06                	sd	ra,56(sp)
    8000517c:	f822                	sd	s0,48(sp)
    8000517e:	f426                	sd	s1,40(sp)
    80005180:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005182:	ffffc097          	auipc	ra,0xffffc
    80005186:	cd2080e7          	jalr	-814(ra) # 80000e54 <myproc>
    8000518a:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000518c:	fd840593          	addi	a1,s0,-40
    80005190:	4501                	li	a0,0
    80005192:	ffffd097          	auipc	ra,0xffffd
    80005196:	f20080e7          	jalr	-224(ra) # 800020b2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000519a:	fc840593          	addi	a1,s0,-56
    8000519e:	fd040513          	addi	a0,s0,-48
    800051a2:	fffff097          	auipc	ra,0xfffff
    800051a6:	dc2080e7          	jalr	-574(ra) # 80003f64 <pipealloc>
    return -1;
    800051aa:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800051ac:	0c054463          	bltz	a0,80005274 <sys_pipe+0xfc>
  fd0 = -1;
    800051b0:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800051b4:	fd043503          	ld	a0,-48(s0)
    800051b8:	fffff097          	auipc	ra,0xfffff
    800051bc:	514080e7          	jalr	1300(ra) # 800046cc <fdalloc>
    800051c0:	fca42223          	sw	a0,-60(s0)
    800051c4:	08054b63          	bltz	a0,8000525a <sys_pipe+0xe2>
    800051c8:	fc843503          	ld	a0,-56(s0)
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	500080e7          	jalr	1280(ra) # 800046cc <fdalloc>
    800051d4:	fca42023          	sw	a0,-64(s0)
    800051d8:	06054863          	bltz	a0,80005248 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800051dc:	4691                	li	a3,4
    800051de:	fc440613          	addi	a2,s0,-60
    800051e2:	fd843583          	ld	a1,-40(s0)
    800051e6:	68a8                	ld	a0,80(s1)
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	92c080e7          	jalr	-1748(ra) # 80000b14 <copyout>
    800051f0:	02054063          	bltz	a0,80005210 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800051f4:	4691                	li	a3,4
    800051f6:	fc040613          	addi	a2,s0,-64
    800051fa:	fd843583          	ld	a1,-40(s0)
    800051fe:	0591                	addi	a1,a1,4
    80005200:	68a8                	ld	a0,80(s1)
    80005202:	ffffc097          	auipc	ra,0xffffc
    80005206:	912080e7          	jalr	-1774(ra) # 80000b14 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000520a:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000520c:	06055463          	bgez	a0,80005274 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005210:	fc442783          	lw	a5,-60(s0)
    80005214:	07e9                	addi	a5,a5,26
    80005216:	078e                	slli	a5,a5,0x3
    80005218:	97a6                	add	a5,a5,s1
    8000521a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000521e:	fc042783          	lw	a5,-64(s0)
    80005222:	07e9                	addi	a5,a5,26
    80005224:	078e                	slli	a5,a5,0x3
    80005226:	94be                	add	s1,s1,a5
    80005228:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000522c:	fd043503          	ld	a0,-48(s0)
    80005230:	fffff097          	auipc	ra,0xfffff
    80005234:	a04080e7          	jalr	-1532(ra) # 80003c34 <fileclose>
    fileclose(wf);
    80005238:	fc843503          	ld	a0,-56(s0)
    8000523c:	fffff097          	auipc	ra,0xfffff
    80005240:	9f8080e7          	jalr	-1544(ra) # 80003c34 <fileclose>
    return -1;
    80005244:	57fd                	li	a5,-1
    80005246:	a03d                	j	80005274 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005248:	fc442783          	lw	a5,-60(s0)
    8000524c:	0007c763          	bltz	a5,8000525a <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005250:	07e9                	addi	a5,a5,26
    80005252:	078e                	slli	a5,a5,0x3
    80005254:	97a6                	add	a5,a5,s1
    80005256:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000525a:	fd043503          	ld	a0,-48(s0)
    8000525e:	fffff097          	auipc	ra,0xfffff
    80005262:	9d6080e7          	jalr	-1578(ra) # 80003c34 <fileclose>
    fileclose(wf);
    80005266:	fc843503          	ld	a0,-56(s0)
    8000526a:	fffff097          	auipc	ra,0xfffff
    8000526e:	9ca080e7          	jalr	-1590(ra) # 80003c34 <fileclose>
    return -1;
    80005272:	57fd                	li	a5,-1
}
    80005274:	853e                	mv	a0,a5
    80005276:	70e2                	ld	ra,56(sp)
    80005278:	7442                	ld	s0,48(sp)
    8000527a:	74a2                	ld	s1,40(sp)
    8000527c:	6121                	addi	sp,sp,64
    8000527e:	8082                	ret

0000000080005280 <kernelvec>:
    80005280:	7111                	addi	sp,sp,-256
    80005282:	e006                	sd	ra,0(sp)
    80005284:	e40a                	sd	sp,8(sp)
    80005286:	e80e                	sd	gp,16(sp)
    80005288:	ec12                	sd	tp,24(sp)
    8000528a:	f016                	sd	t0,32(sp)
    8000528c:	f41a                	sd	t1,40(sp)
    8000528e:	f81e                	sd	t2,48(sp)
    80005290:	fc22                	sd	s0,56(sp)
    80005292:	e0a6                	sd	s1,64(sp)
    80005294:	e4aa                	sd	a0,72(sp)
    80005296:	e8ae                	sd	a1,80(sp)
    80005298:	ecb2                	sd	a2,88(sp)
    8000529a:	f0b6                	sd	a3,96(sp)
    8000529c:	f4ba                	sd	a4,104(sp)
    8000529e:	f8be                	sd	a5,112(sp)
    800052a0:	fcc2                	sd	a6,120(sp)
    800052a2:	e146                	sd	a7,128(sp)
    800052a4:	e54a                	sd	s2,136(sp)
    800052a6:	e94e                	sd	s3,144(sp)
    800052a8:	ed52                	sd	s4,152(sp)
    800052aa:	f156                	sd	s5,160(sp)
    800052ac:	f55a                	sd	s6,168(sp)
    800052ae:	f95e                	sd	s7,176(sp)
    800052b0:	fd62                	sd	s8,184(sp)
    800052b2:	e1e6                	sd	s9,192(sp)
    800052b4:	e5ea                	sd	s10,200(sp)
    800052b6:	e9ee                	sd	s11,208(sp)
    800052b8:	edf2                	sd	t3,216(sp)
    800052ba:	f1f6                	sd	t4,224(sp)
    800052bc:	f5fa                	sd	t5,232(sp)
    800052be:	f9fe                	sd	t6,240(sp)
    800052c0:	c01fc0ef          	jal	ra,80001ec0 <kerneltrap>
    800052c4:	6082                	ld	ra,0(sp)
    800052c6:	6122                	ld	sp,8(sp)
    800052c8:	61c2                	ld	gp,16(sp)
    800052ca:	7282                	ld	t0,32(sp)
    800052cc:	7322                	ld	t1,40(sp)
    800052ce:	73c2                	ld	t2,48(sp)
    800052d0:	7462                	ld	s0,56(sp)
    800052d2:	6486                	ld	s1,64(sp)
    800052d4:	6526                	ld	a0,72(sp)
    800052d6:	65c6                	ld	a1,80(sp)
    800052d8:	6666                	ld	a2,88(sp)
    800052da:	7686                	ld	a3,96(sp)
    800052dc:	7726                	ld	a4,104(sp)
    800052de:	77c6                	ld	a5,112(sp)
    800052e0:	7866                	ld	a6,120(sp)
    800052e2:	688a                	ld	a7,128(sp)
    800052e4:	692a                	ld	s2,136(sp)
    800052e6:	69ca                	ld	s3,144(sp)
    800052e8:	6a6a                	ld	s4,152(sp)
    800052ea:	7a8a                	ld	s5,160(sp)
    800052ec:	7b2a                	ld	s6,168(sp)
    800052ee:	7bca                	ld	s7,176(sp)
    800052f0:	7c6a                	ld	s8,184(sp)
    800052f2:	6c8e                	ld	s9,192(sp)
    800052f4:	6d2e                	ld	s10,200(sp)
    800052f6:	6dce                	ld	s11,208(sp)
    800052f8:	6e6e                	ld	t3,216(sp)
    800052fa:	7e8e                	ld	t4,224(sp)
    800052fc:	7f2e                	ld	t5,232(sp)
    800052fe:	7fce                	ld	t6,240(sp)
    80005300:	6111                	addi	sp,sp,256
    80005302:	10200073          	sret
    80005306:	00000013          	nop
    8000530a:	00000013          	nop
    8000530e:	0001                	nop

0000000080005310 <timervec>:
    80005310:	34051573          	csrrw	a0,mscratch,a0
    80005314:	e10c                	sd	a1,0(a0)
    80005316:	e510                	sd	a2,8(a0)
    80005318:	e914                	sd	a3,16(a0)
    8000531a:	6d0c                	ld	a1,24(a0)
    8000531c:	7110                	ld	a2,32(a0)
    8000531e:	6194                	ld	a3,0(a1)
    80005320:	96b2                	add	a3,a3,a2
    80005322:	e194                	sd	a3,0(a1)
    80005324:	4589                	li	a1,2
    80005326:	14459073          	csrw	sip,a1
    8000532a:	6914                	ld	a3,16(a0)
    8000532c:	6510                	ld	a2,8(a0)
    8000532e:	610c                	ld	a1,0(a0)
    80005330:	34051573          	csrrw	a0,mscratch,a0
    80005334:	30200073          	mret
	...

000000008000533a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000533a:	1141                	addi	sp,sp,-16
    8000533c:	e422                	sd	s0,8(sp)
    8000533e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005340:	0c0007b7          	lui	a5,0xc000
    80005344:	4705                	li	a4,1
    80005346:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005348:	c3d8                	sw	a4,4(a5)
}
    8000534a:	6422                	ld	s0,8(sp)
    8000534c:	0141                	addi	sp,sp,16
    8000534e:	8082                	ret

0000000080005350 <plicinithart>:

void
plicinithart(void)
{
    80005350:	1141                	addi	sp,sp,-16
    80005352:	e406                	sd	ra,8(sp)
    80005354:	e022                	sd	s0,0(sp)
    80005356:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005358:	ffffc097          	auipc	ra,0xffffc
    8000535c:	ad0080e7          	jalr	-1328(ra) # 80000e28 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005360:	0085171b          	slliw	a4,a0,0x8
    80005364:	0c0027b7          	lui	a5,0xc002
    80005368:	97ba                	add	a5,a5,a4
    8000536a:	40200713          	li	a4,1026
    8000536e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005372:	00d5151b          	slliw	a0,a0,0xd
    80005376:	0c2017b7          	lui	a5,0xc201
    8000537a:	97aa                	add	a5,a5,a0
    8000537c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005380:	60a2                	ld	ra,8(sp)
    80005382:	6402                	ld	s0,0(sp)
    80005384:	0141                	addi	sp,sp,16
    80005386:	8082                	ret

0000000080005388 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005388:	1141                	addi	sp,sp,-16
    8000538a:	e406                	sd	ra,8(sp)
    8000538c:	e022                	sd	s0,0(sp)
    8000538e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005390:	ffffc097          	auipc	ra,0xffffc
    80005394:	a98080e7          	jalr	-1384(ra) # 80000e28 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005398:	00d5151b          	slliw	a0,a0,0xd
    8000539c:	0c2017b7          	lui	a5,0xc201
    800053a0:	97aa                	add	a5,a5,a0
  return irq;
}
    800053a2:	43c8                	lw	a0,4(a5)
    800053a4:	60a2                	ld	ra,8(sp)
    800053a6:	6402                	ld	s0,0(sp)
    800053a8:	0141                	addi	sp,sp,16
    800053aa:	8082                	ret

00000000800053ac <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800053ac:	1101                	addi	sp,sp,-32
    800053ae:	ec06                	sd	ra,24(sp)
    800053b0:	e822                	sd	s0,16(sp)
    800053b2:	e426                	sd	s1,8(sp)
    800053b4:	1000                	addi	s0,sp,32
    800053b6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800053b8:	ffffc097          	auipc	ra,0xffffc
    800053bc:	a70080e7          	jalr	-1424(ra) # 80000e28 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800053c0:	00d5151b          	slliw	a0,a0,0xd
    800053c4:	0c2017b7          	lui	a5,0xc201
    800053c8:	97aa                	add	a5,a5,a0
    800053ca:	c3c4                	sw	s1,4(a5)
}
    800053cc:	60e2                	ld	ra,24(sp)
    800053ce:	6442                	ld	s0,16(sp)
    800053d0:	64a2                	ld	s1,8(sp)
    800053d2:	6105                	addi	sp,sp,32
    800053d4:	8082                	ret

00000000800053d6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800053d6:	1141                	addi	sp,sp,-16
    800053d8:	e406                	sd	ra,8(sp)
    800053da:	e022                	sd	s0,0(sp)
    800053dc:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800053de:	479d                	li	a5,7
    800053e0:	04a7cc63          	blt	a5,a0,80005438 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800053e4:	00019797          	auipc	a5,0x19
    800053e8:	c0c78793          	addi	a5,a5,-1012 # 8001dff0 <disk>
    800053ec:	97aa                	add	a5,a5,a0
    800053ee:	0187c783          	lbu	a5,24(a5)
    800053f2:	ebb9                	bnez	a5,80005448 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800053f4:	00451693          	slli	a3,a0,0x4
    800053f8:	00019797          	auipc	a5,0x19
    800053fc:	bf878793          	addi	a5,a5,-1032 # 8001dff0 <disk>
    80005400:	6398                	ld	a4,0(a5)
    80005402:	9736                	add	a4,a4,a3
    80005404:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005408:	6398                	ld	a4,0(a5)
    8000540a:	9736                	add	a4,a4,a3
    8000540c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005410:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005414:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005418:	97aa                	add	a5,a5,a0
    8000541a:	4705                	li	a4,1
    8000541c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005420:	00019517          	auipc	a0,0x19
    80005424:	be850513          	addi	a0,a0,-1048 # 8001e008 <disk+0x18>
    80005428:	ffffc097          	auipc	ra,0xffffc
    8000542c:	140080e7          	jalr	320(ra) # 80001568 <wakeup>
}
    80005430:	60a2                	ld	ra,8(sp)
    80005432:	6402                	ld	s0,0(sp)
    80005434:	0141                	addi	sp,sp,16
    80005436:	8082                	ret
    panic("free_desc 1");
    80005438:	00003517          	auipc	a0,0x3
    8000543c:	2a050513          	addi	a0,a0,672 # 800086d8 <syscalls+0x308>
    80005440:	00001097          	auipc	ra,0x1
    80005444:	a0c080e7          	jalr	-1524(ra) # 80005e4c <panic>
    panic("free_desc 2");
    80005448:	00003517          	auipc	a0,0x3
    8000544c:	2a050513          	addi	a0,a0,672 # 800086e8 <syscalls+0x318>
    80005450:	00001097          	auipc	ra,0x1
    80005454:	9fc080e7          	jalr	-1540(ra) # 80005e4c <panic>

0000000080005458 <virtio_disk_init>:
{
    80005458:	1101                	addi	sp,sp,-32
    8000545a:	ec06                	sd	ra,24(sp)
    8000545c:	e822                	sd	s0,16(sp)
    8000545e:	e426                	sd	s1,8(sp)
    80005460:	e04a                	sd	s2,0(sp)
    80005462:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005464:	00003597          	auipc	a1,0x3
    80005468:	29458593          	addi	a1,a1,660 # 800086f8 <syscalls+0x328>
    8000546c:	00019517          	auipc	a0,0x19
    80005470:	cac50513          	addi	a0,a0,-852 # 8001e118 <disk+0x128>
    80005474:	00001097          	auipc	ra,0x1
    80005478:	e80080e7          	jalr	-384(ra) # 800062f4 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000547c:	100017b7          	lui	a5,0x10001
    80005480:	4398                	lw	a4,0(a5)
    80005482:	2701                	sext.w	a4,a4
    80005484:	747277b7          	lui	a5,0x74727
    80005488:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000548c:	14f71b63          	bne	a4,a5,800055e2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005490:	100017b7          	lui	a5,0x10001
    80005494:	43dc                	lw	a5,4(a5)
    80005496:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005498:	4709                	li	a4,2
    8000549a:	14e79463          	bne	a5,a4,800055e2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000549e:	100017b7          	lui	a5,0x10001
    800054a2:	479c                	lw	a5,8(a5)
    800054a4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800054a6:	12e79e63          	bne	a5,a4,800055e2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800054aa:	100017b7          	lui	a5,0x10001
    800054ae:	47d8                	lw	a4,12(a5)
    800054b0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800054b2:	554d47b7          	lui	a5,0x554d4
    800054b6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800054ba:	12f71463          	bne	a4,a5,800055e2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054be:	100017b7          	lui	a5,0x10001
    800054c2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800054c6:	4705                	li	a4,1
    800054c8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054ca:	470d                	li	a4,3
    800054cc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800054ce:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800054d0:	c7ffe6b7          	lui	a3,0xc7ffe
    800054d4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd83ef>
    800054d8:	8f75                	and	a4,a4,a3
    800054da:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054dc:	472d                	li	a4,11
    800054de:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800054e0:	5bbc                	lw	a5,112(a5)
    800054e2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800054e6:	8ba1                	andi	a5,a5,8
    800054e8:	10078563          	beqz	a5,800055f2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800054ec:	100017b7          	lui	a5,0x10001
    800054f0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800054f4:	43fc                	lw	a5,68(a5)
    800054f6:	2781                	sext.w	a5,a5
    800054f8:	10079563          	bnez	a5,80005602 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800054fc:	100017b7          	lui	a5,0x10001
    80005500:	5bdc                	lw	a5,52(a5)
    80005502:	2781                	sext.w	a5,a5
  if(max == 0)
    80005504:	10078763          	beqz	a5,80005612 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005508:	471d                	li	a4,7
    8000550a:	10f77c63          	bgeu	a4,a5,80005622 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000550e:	ffffb097          	auipc	ra,0xffffb
    80005512:	c0c080e7          	jalr	-1012(ra) # 8000011a <kalloc>
    80005516:	00019497          	auipc	s1,0x19
    8000551a:	ada48493          	addi	s1,s1,-1318 # 8001dff0 <disk>
    8000551e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005520:	ffffb097          	auipc	ra,0xffffb
    80005524:	bfa080e7          	jalr	-1030(ra) # 8000011a <kalloc>
    80005528:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000552a:	ffffb097          	auipc	ra,0xffffb
    8000552e:	bf0080e7          	jalr	-1040(ra) # 8000011a <kalloc>
    80005532:	87aa                	mv	a5,a0
    80005534:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005536:	6088                	ld	a0,0(s1)
    80005538:	cd6d                	beqz	a0,80005632 <virtio_disk_init+0x1da>
    8000553a:	00019717          	auipc	a4,0x19
    8000553e:	abe73703          	ld	a4,-1346(a4) # 8001dff8 <disk+0x8>
    80005542:	cb65                	beqz	a4,80005632 <virtio_disk_init+0x1da>
    80005544:	c7fd                	beqz	a5,80005632 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005546:	6605                	lui	a2,0x1
    80005548:	4581                	li	a1,0
    8000554a:	ffffb097          	auipc	ra,0xffffb
    8000554e:	c30080e7          	jalr	-976(ra) # 8000017a <memset>
  memset(disk.avail, 0, PGSIZE);
    80005552:	00019497          	auipc	s1,0x19
    80005556:	a9e48493          	addi	s1,s1,-1378 # 8001dff0 <disk>
    8000555a:	6605                	lui	a2,0x1
    8000555c:	4581                	li	a1,0
    8000555e:	6488                	ld	a0,8(s1)
    80005560:	ffffb097          	auipc	ra,0xffffb
    80005564:	c1a080e7          	jalr	-998(ra) # 8000017a <memset>
  memset(disk.used, 0, PGSIZE);
    80005568:	6605                	lui	a2,0x1
    8000556a:	4581                	li	a1,0
    8000556c:	6888                	ld	a0,16(s1)
    8000556e:	ffffb097          	auipc	ra,0xffffb
    80005572:	c0c080e7          	jalr	-1012(ra) # 8000017a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005576:	100017b7          	lui	a5,0x10001
    8000557a:	4721                	li	a4,8
    8000557c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000557e:	4098                	lw	a4,0(s1)
    80005580:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005584:	40d8                	lw	a4,4(s1)
    80005586:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000558a:	6498                	ld	a4,8(s1)
    8000558c:	0007069b          	sext.w	a3,a4
    80005590:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005594:	9701                	srai	a4,a4,0x20
    80005596:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000559a:	6898                	ld	a4,16(s1)
    8000559c:	0007069b          	sext.w	a3,a4
    800055a0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800055a4:	9701                	srai	a4,a4,0x20
    800055a6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800055aa:	4705                	li	a4,1
    800055ac:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    800055ae:	00e48c23          	sb	a4,24(s1)
    800055b2:	00e48ca3          	sb	a4,25(s1)
    800055b6:	00e48d23          	sb	a4,26(s1)
    800055ba:	00e48da3          	sb	a4,27(s1)
    800055be:	00e48e23          	sb	a4,28(s1)
    800055c2:	00e48ea3          	sb	a4,29(s1)
    800055c6:	00e48f23          	sb	a4,30(s1)
    800055ca:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800055ce:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800055d2:	0727a823          	sw	s2,112(a5)
}
    800055d6:	60e2                	ld	ra,24(sp)
    800055d8:	6442                	ld	s0,16(sp)
    800055da:	64a2                	ld	s1,8(sp)
    800055dc:	6902                	ld	s2,0(sp)
    800055de:	6105                	addi	sp,sp,32
    800055e0:	8082                	ret
    panic("could not find virtio disk");
    800055e2:	00003517          	auipc	a0,0x3
    800055e6:	12650513          	addi	a0,a0,294 # 80008708 <syscalls+0x338>
    800055ea:	00001097          	auipc	ra,0x1
    800055ee:	862080e7          	jalr	-1950(ra) # 80005e4c <panic>
    panic("virtio disk FEATURES_OK unset");
    800055f2:	00003517          	auipc	a0,0x3
    800055f6:	13650513          	addi	a0,a0,310 # 80008728 <syscalls+0x358>
    800055fa:	00001097          	auipc	ra,0x1
    800055fe:	852080e7          	jalr	-1966(ra) # 80005e4c <panic>
    panic("virtio disk should not be ready");
    80005602:	00003517          	auipc	a0,0x3
    80005606:	14650513          	addi	a0,a0,326 # 80008748 <syscalls+0x378>
    8000560a:	00001097          	auipc	ra,0x1
    8000560e:	842080e7          	jalr	-1982(ra) # 80005e4c <panic>
    panic("virtio disk has no queue 0");
    80005612:	00003517          	auipc	a0,0x3
    80005616:	15650513          	addi	a0,a0,342 # 80008768 <syscalls+0x398>
    8000561a:	00001097          	auipc	ra,0x1
    8000561e:	832080e7          	jalr	-1998(ra) # 80005e4c <panic>
    panic("virtio disk max queue too short");
    80005622:	00003517          	auipc	a0,0x3
    80005626:	16650513          	addi	a0,a0,358 # 80008788 <syscalls+0x3b8>
    8000562a:	00001097          	auipc	ra,0x1
    8000562e:	822080e7          	jalr	-2014(ra) # 80005e4c <panic>
    panic("virtio disk kalloc");
    80005632:	00003517          	auipc	a0,0x3
    80005636:	17650513          	addi	a0,a0,374 # 800087a8 <syscalls+0x3d8>
    8000563a:	00001097          	auipc	ra,0x1
    8000563e:	812080e7          	jalr	-2030(ra) # 80005e4c <panic>

0000000080005642 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005642:	7119                	addi	sp,sp,-128
    80005644:	fc86                	sd	ra,120(sp)
    80005646:	f8a2                	sd	s0,112(sp)
    80005648:	f4a6                	sd	s1,104(sp)
    8000564a:	f0ca                	sd	s2,96(sp)
    8000564c:	ecce                	sd	s3,88(sp)
    8000564e:	e8d2                	sd	s4,80(sp)
    80005650:	e4d6                	sd	s5,72(sp)
    80005652:	e0da                	sd	s6,64(sp)
    80005654:	fc5e                	sd	s7,56(sp)
    80005656:	f862                	sd	s8,48(sp)
    80005658:	f466                	sd	s9,40(sp)
    8000565a:	f06a                	sd	s10,32(sp)
    8000565c:	ec6e                	sd	s11,24(sp)
    8000565e:	0100                	addi	s0,sp,128
    80005660:	8aaa                	mv	s5,a0
    80005662:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005664:	00c52d03          	lw	s10,12(a0)
    80005668:	001d1d1b          	slliw	s10,s10,0x1
    8000566c:	1d02                	slli	s10,s10,0x20
    8000566e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005672:	00019517          	auipc	a0,0x19
    80005676:	aa650513          	addi	a0,a0,-1370 # 8001e118 <disk+0x128>
    8000567a:	00001097          	auipc	ra,0x1
    8000567e:	d0a080e7          	jalr	-758(ra) # 80006384 <acquire>
  for(int i = 0; i < 3; i++){
    80005682:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005684:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005686:	00019b97          	auipc	s7,0x19
    8000568a:	96ab8b93          	addi	s7,s7,-1686 # 8001dff0 <disk>
  for(int i = 0; i < 3; i++){
    8000568e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005690:	00019c97          	auipc	s9,0x19
    80005694:	a88c8c93          	addi	s9,s9,-1400 # 8001e118 <disk+0x128>
    80005698:	a08d                	j	800056fa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000569a:	00fb8733          	add	a4,s7,a5
    8000569e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800056a2:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800056a4:	0207c563          	bltz	a5,800056ce <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    800056a8:	2905                	addiw	s2,s2,1
    800056aa:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800056ac:	05690c63          	beq	s2,s6,80005704 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    800056b0:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800056b2:	00019717          	auipc	a4,0x19
    800056b6:	93e70713          	addi	a4,a4,-1730 # 8001dff0 <disk>
    800056ba:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800056bc:	01874683          	lbu	a3,24(a4)
    800056c0:	fee9                	bnez	a3,8000569a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    800056c2:	2785                	addiw	a5,a5,1
    800056c4:	0705                	addi	a4,a4,1
    800056c6:	fe979be3          	bne	a5,s1,800056bc <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800056ca:	57fd                	li	a5,-1
    800056cc:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800056ce:	01205d63          	blez	s2,800056e8 <virtio_disk_rw+0xa6>
    800056d2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800056d4:	000a2503          	lw	a0,0(s4)
    800056d8:	00000097          	auipc	ra,0x0
    800056dc:	cfe080e7          	jalr	-770(ra) # 800053d6 <free_desc>
      for(int j = 0; j < i; j++)
    800056e0:	2d85                	addiw	s11,s11,1
    800056e2:	0a11                	addi	s4,s4,4
    800056e4:	ff2d98e3          	bne	s11,s2,800056d4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056e8:	85e6                	mv	a1,s9
    800056ea:	00019517          	auipc	a0,0x19
    800056ee:	91e50513          	addi	a0,a0,-1762 # 8001e008 <disk+0x18>
    800056f2:	ffffc097          	auipc	ra,0xffffc
    800056f6:	e12080e7          	jalr	-494(ra) # 80001504 <sleep>
  for(int i = 0; i < 3; i++){
    800056fa:	f8040a13          	addi	s4,s0,-128
{
    800056fe:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80005700:	894e                	mv	s2,s3
    80005702:	b77d                	j	800056b0 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005704:	f8042503          	lw	a0,-128(s0)
    80005708:	00a50713          	addi	a4,a0,10
    8000570c:	0712                	slli	a4,a4,0x4

  if(write)
    8000570e:	00019797          	auipc	a5,0x19
    80005712:	8e278793          	addi	a5,a5,-1822 # 8001dff0 <disk>
    80005716:	00e786b3          	add	a3,a5,a4
    8000571a:	01803633          	snez	a2,s8
    8000571e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005720:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005724:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005728:	f6070613          	addi	a2,a4,-160
    8000572c:	6394                	ld	a3,0(a5)
    8000572e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005730:	00870593          	addi	a1,a4,8
    80005734:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005736:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005738:	0007b803          	ld	a6,0(a5)
    8000573c:	9642                	add	a2,a2,a6
    8000573e:	46c1                	li	a3,16
    80005740:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005742:	4585                	li	a1,1
    80005744:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005748:	f8442683          	lw	a3,-124(s0)
    8000574c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005750:	0692                	slli	a3,a3,0x4
    80005752:	9836                	add	a6,a6,a3
    80005754:	058a8613          	addi	a2,s5,88
    80005758:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000575c:	0007b803          	ld	a6,0(a5)
    80005760:	96c2                	add	a3,a3,a6
    80005762:	40000613          	li	a2,1024
    80005766:	c690                	sw	a2,8(a3)
  if(write)
    80005768:	001c3613          	seqz	a2,s8
    8000576c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005770:	00166613          	ori	a2,a2,1
    80005774:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005778:	f8842603          	lw	a2,-120(s0)
    8000577c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005780:	00250693          	addi	a3,a0,2
    80005784:	0692                	slli	a3,a3,0x4
    80005786:	96be                	add	a3,a3,a5
    80005788:	58fd                	li	a7,-1
    8000578a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000578e:	0612                	slli	a2,a2,0x4
    80005790:	9832                	add	a6,a6,a2
    80005792:	f9070713          	addi	a4,a4,-112
    80005796:	973e                	add	a4,a4,a5
    80005798:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000579c:	6398                	ld	a4,0(a5)
    8000579e:	9732                	add	a4,a4,a2
    800057a0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800057a2:	4609                	li	a2,2
    800057a4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    800057a8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800057ac:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    800057b0:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800057b4:	6794                	ld	a3,8(a5)
    800057b6:	0026d703          	lhu	a4,2(a3)
    800057ba:	8b1d                	andi	a4,a4,7
    800057bc:	0706                	slli	a4,a4,0x1
    800057be:	96ba                	add	a3,a3,a4
    800057c0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800057c4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800057c8:	6798                	ld	a4,8(a5)
    800057ca:	00275783          	lhu	a5,2(a4)
    800057ce:	2785                	addiw	a5,a5,1
    800057d0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800057d4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800057d8:	100017b7          	lui	a5,0x10001
    800057dc:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800057e0:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800057e4:	00019917          	auipc	s2,0x19
    800057e8:	93490913          	addi	s2,s2,-1740 # 8001e118 <disk+0x128>
  while(b->disk == 1) {
    800057ec:	4485                	li	s1,1
    800057ee:	00b79c63          	bne	a5,a1,80005806 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800057f2:	85ca                	mv	a1,s2
    800057f4:	8556                	mv	a0,s5
    800057f6:	ffffc097          	auipc	ra,0xffffc
    800057fa:	d0e080e7          	jalr	-754(ra) # 80001504 <sleep>
  while(b->disk == 1) {
    800057fe:	004aa783          	lw	a5,4(s5)
    80005802:	fe9788e3          	beq	a5,s1,800057f2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80005806:	f8042903          	lw	s2,-128(s0)
    8000580a:	00290713          	addi	a4,s2,2
    8000580e:	0712                	slli	a4,a4,0x4
    80005810:	00018797          	auipc	a5,0x18
    80005814:	7e078793          	addi	a5,a5,2016 # 8001dff0 <disk>
    80005818:	97ba                	add	a5,a5,a4
    8000581a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000581e:	00018997          	auipc	s3,0x18
    80005822:	7d298993          	addi	s3,s3,2002 # 8001dff0 <disk>
    80005826:	00491713          	slli	a4,s2,0x4
    8000582a:	0009b783          	ld	a5,0(s3)
    8000582e:	97ba                	add	a5,a5,a4
    80005830:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005834:	854a                	mv	a0,s2
    80005836:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000583a:	00000097          	auipc	ra,0x0
    8000583e:	b9c080e7          	jalr	-1124(ra) # 800053d6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005842:	8885                	andi	s1,s1,1
    80005844:	f0ed                	bnez	s1,80005826 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005846:	00019517          	auipc	a0,0x19
    8000584a:	8d250513          	addi	a0,a0,-1838 # 8001e118 <disk+0x128>
    8000584e:	00001097          	auipc	ra,0x1
    80005852:	bea080e7          	jalr	-1046(ra) # 80006438 <release>
}
    80005856:	70e6                	ld	ra,120(sp)
    80005858:	7446                	ld	s0,112(sp)
    8000585a:	74a6                	ld	s1,104(sp)
    8000585c:	7906                	ld	s2,96(sp)
    8000585e:	69e6                	ld	s3,88(sp)
    80005860:	6a46                	ld	s4,80(sp)
    80005862:	6aa6                	ld	s5,72(sp)
    80005864:	6b06                	ld	s6,64(sp)
    80005866:	7be2                	ld	s7,56(sp)
    80005868:	7c42                	ld	s8,48(sp)
    8000586a:	7ca2                	ld	s9,40(sp)
    8000586c:	7d02                	ld	s10,32(sp)
    8000586e:	6de2                	ld	s11,24(sp)
    80005870:	6109                	addi	sp,sp,128
    80005872:	8082                	ret

0000000080005874 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005874:	1101                	addi	sp,sp,-32
    80005876:	ec06                	sd	ra,24(sp)
    80005878:	e822                	sd	s0,16(sp)
    8000587a:	e426                	sd	s1,8(sp)
    8000587c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000587e:	00018497          	auipc	s1,0x18
    80005882:	77248493          	addi	s1,s1,1906 # 8001dff0 <disk>
    80005886:	00019517          	auipc	a0,0x19
    8000588a:	89250513          	addi	a0,a0,-1902 # 8001e118 <disk+0x128>
    8000588e:	00001097          	auipc	ra,0x1
    80005892:	af6080e7          	jalr	-1290(ra) # 80006384 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005896:	10001737          	lui	a4,0x10001
    8000589a:	533c                	lw	a5,96(a4)
    8000589c:	8b8d                	andi	a5,a5,3
    8000589e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800058a0:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800058a4:	689c                	ld	a5,16(s1)
    800058a6:	0204d703          	lhu	a4,32(s1)
    800058aa:	0027d783          	lhu	a5,2(a5)
    800058ae:	04f70863          	beq	a4,a5,800058fe <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800058b2:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800058b6:	6898                	ld	a4,16(s1)
    800058b8:	0204d783          	lhu	a5,32(s1)
    800058bc:	8b9d                	andi	a5,a5,7
    800058be:	078e                	slli	a5,a5,0x3
    800058c0:	97ba                	add	a5,a5,a4
    800058c2:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800058c4:	00278713          	addi	a4,a5,2
    800058c8:	0712                	slli	a4,a4,0x4
    800058ca:	9726                	add	a4,a4,s1
    800058cc:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800058d0:	e721                	bnez	a4,80005918 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800058d2:	0789                	addi	a5,a5,2
    800058d4:	0792                	slli	a5,a5,0x4
    800058d6:	97a6                	add	a5,a5,s1
    800058d8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800058da:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800058de:	ffffc097          	auipc	ra,0xffffc
    800058e2:	c8a080e7          	jalr	-886(ra) # 80001568 <wakeup>

    disk.used_idx += 1;
    800058e6:	0204d783          	lhu	a5,32(s1)
    800058ea:	2785                	addiw	a5,a5,1
    800058ec:	17c2                	slli	a5,a5,0x30
    800058ee:	93c1                	srli	a5,a5,0x30
    800058f0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800058f4:	6898                	ld	a4,16(s1)
    800058f6:	00275703          	lhu	a4,2(a4)
    800058fa:	faf71ce3          	bne	a4,a5,800058b2 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800058fe:	00019517          	auipc	a0,0x19
    80005902:	81a50513          	addi	a0,a0,-2022 # 8001e118 <disk+0x128>
    80005906:	00001097          	auipc	ra,0x1
    8000590a:	b32080e7          	jalr	-1230(ra) # 80006438 <release>
}
    8000590e:	60e2                	ld	ra,24(sp)
    80005910:	6442                	ld	s0,16(sp)
    80005912:	64a2                	ld	s1,8(sp)
    80005914:	6105                	addi	sp,sp,32
    80005916:	8082                	ret
      panic("virtio_disk_intr status");
    80005918:	00003517          	auipc	a0,0x3
    8000591c:	ea850513          	addi	a0,a0,-344 # 800087c0 <syscalls+0x3f0>
    80005920:	00000097          	auipc	ra,0x0
    80005924:	52c080e7          	jalr	1324(ra) # 80005e4c <panic>

0000000080005928 <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80005928:	1141                	addi	sp,sp,-16
    8000592a:	e422                	sd	s0,8(sp)
    8000592c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    8000592e:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80005932:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80005936:	0037979b          	slliw	a5,a5,0x3
    8000593a:	02004737          	lui	a4,0x2004
    8000593e:	97ba                	add	a5,a5,a4
    80005940:	0200c737          	lui	a4,0x200c
    80005944:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80005948:	000f4637          	lui	a2,0xf4
    8000594c:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80005950:	9732                	add	a4,a4,a2
    80005952:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005954:	00259693          	slli	a3,a1,0x2
    80005958:	96ae                	add	a3,a3,a1
    8000595a:	068e                	slli	a3,a3,0x3
    8000595c:	00018717          	auipc	a4,0x18
    80005960:	7d470713          	addi	a4,a4,2004 # 8001e130 <timer_scratch>
    80005964:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80005966:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80005968:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000596a:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000596e:	00000797          	auipc	a5,0x0
    80005972:	9a278793          	addi	a5,a5,-1630 # 80005310 <timervec>
    80005976:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000597a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000597e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005982:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005986:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000598a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000598e:	30479073          	csrw	mie,a5
}
    80005992:	6422                	ld	s0,8(sp)
    80005994:	0141                	addi	sp,sp,16
    80005996:	8082                	ret

0000000080005998 <start>:
{
    80005998:	1141                	addi	sp,sp,-16
    8000599a:	e406                	sd	ra,8(sp)
    8000599c:	e022                	sd	s0,0(sp)
    8000599e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800059a0:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800059a4:	7779                	lui	a4,0xffffe
    800059a6:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd848f>
    800059aa:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800059ac:	6705                	lui	a4,0x1
    800059ae:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800059b2:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800059b4:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800059b8:	ffffb797          	auipc	a5,0xffffb
    800059bc:	96878793          	addi	a5,a5,-1688 # 80000320 <main>
    800059c0:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800059c4:	4781                	li	a5,0
    800059c6:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800059ca:	67c1                	lui	a5,0x10
    800059cc:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800059ce:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800059d2:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800059d6:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800059da:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800059de:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800059e2:	57fd                	li	a5,-1
    800059e4:	83a9                	srli	a5,a5,0xa
    800059e6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800059ea:	47bd                	li	a5,15
    800059ec:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800059f0:	00000097          	auipc	ra,0x0
    800059f4:	f38080e7          	jalr	-200(ra) # 80005928 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800059f8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800059fc:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    800059fe:	823e                	mv	tp,a5
  asm volatile("mret");
    80005a00:	30200073          	mret
}
    80005a04:	60a2                	ld	ra,8(sp)
    80005a06:	6402                	ld	s0,0(sp)
    80005a08:	0141                	addi	sp,sp,16
    80005a0a:	8082                	ret

0000000080005a0c <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80005a0c:	715d                	addi	sp,sp,-80
    80005a0e:	e486                	sd	ra,72(sp)
    80005a10:	e0a2                	sd	s0,64(sp)
    80005a12:	fc26                	sd	s1,56(sp)
    80005a14:	f84a                	sd	s2,48(sp)
    80005a16:	f44e                	sd	s3,40(sp)
    80005a18:	f052                	sd	s4,32(sp)
    80005a1a:	ec56                	sd	s5,24(sp)
    80005a1c:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80005a1e:	04c05763          	blez	a2,80005a6c <consolewrite+0x60>
    80005a22:	8a2a                	mv	s4,a0
    80005a24:	84ae                	mv	s1,a1
    80005a26:	89b2                	mv	s3,a2
    80005a28:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80005a2a:	5afd                	li	s5,-1
    80005a2c:	4685                	li	a3,1
    80005a2e:	8626                	mv	a2,s1
    80005a30:	85d2                	mv	a1,s4
    80005a32:	fbf40513          	addi	a0,s0,-65
    80005a36:	ffffc097          	auipc	ra,0xffffc
    80005a3a:	f2c080e7          	jalr	-212(ra) # 80001962 <either_copyin>
    80005a3e:	01550d63          	beq	a0,s5,80005a58 <consolewrite+0x4c>
      break;
    uartputc(c);
    80005a42:	fbf44503          	lbu	a0,-65(s0)
    80005a46:	00000097          	auipc	ra,0x0
    80005a4a:	784080e7          	jalr	1924(ra) # 800061ca <uartputc>
  for(i = 0; i < n; i++){
    80005a4e:	2905                	addiw	s2,s2,1
    80005a50:	0485                	addi	s1,s1,1
    80005a52:	fd299de3          	bne	s3,s2,80005a2c <consolewrite+0x20>
    80005a56:	894e                	mv	s2,s3
  }

  return i;
}
    80005a58:	854a                	mv	a0,s2
    80005a5a:	60a6                	ld	ra,72(sp)
    80005a5c:	6406                	ld	s0,64(sp)
    80005a5e:	74e2                	ld	s1,56(sp)
    80005a60:	7942                	ld	s2,48(sp)
    80005a62:	79a2                	ld	s3,40(sp)
    80005a64:	7a02                	ld	s4,32(sp)
    80005a66:	6ae2                	ld	s5,24(sp)
    80005a68:	6161                	addi	sp,sp,80
    80005a6a:	8082                	ret
  for(i = 0; i < n; i++){
    80005a6c:	4901                	li	s2,0
    80005a6e:	b7ed                	j	80005a58 <consolewrite+0x4c>

0000000080005a70 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005a70:	7159                	addi	sp,sp,-112
    80005a72:	f486                	sd	ra,104(sp)
    80005a74:	f0a2                	sd	s0,96(sp)
    80005a76:	eca6                	sd	s1,88(sp)
    80005a78:	e8ca                	sd	s2,80(sp)
    80005a7a:	e4ce                	sd	s3,72(sp)
    80005a7c:	e0d2                	sd	s4,64(sp)
    80005a7e:	fc56                	sd	s5,56(sp)
    80005a80:	f85a                	sd	s6,48(sp)
    80005a82:	f45e                	sd	s7,40(sp)
    80005a84:	f062                	sd	s8,32(sp)
    80005a86:	ec66                	sd	s9,24(sp)
    80005a88:	e86a                	sd	s10,16(sp)
    80005a8a:	1880                	addi	s0,sp,112
    80005a8c:	8aaa                	mv	s5,a0
    80005a8e:	8a2e                	mv	s4,a1
    80005a90:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005a92:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80005a96:	00020517          	auipc	a0,0x20
    80005a9a:	7da50513          	addi	a0,a0,2010 # 80026270 <cons>
    80005a9e:	00001097          	auipc	ra,0x1
    80005aa2:	8e6080e7          	jalr	-1818(ra) # 80006384 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005aa6:	00020497          	auipc	s1,0x20
    80005aaa:	7ca48493          	addi	s1,s1,1994 # 80026270 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005aae:	00021917          	auipc	s2,0x21
    80005ab2:	85a90913          	addi	s2,s2,-1958 # 80026308 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80005ab6:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005ab8:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80005aba:	4ca9                	li	s9,10
  while(n > 0){
    80005abc:	07305b63          	blez	s3,80005b32 <consoleread+0xc2>
    while(cons.r == cons.w){
    80005ac0:	0984a783          	lw	a5,152(s1)
    80005ac4:	09c4a703          	lw	a4,156(s1)
    80005ac8:	02f71763          	bne	a4,a5,80005af6 <consoleread+0x86>
      if(killed(myproc())){
    80005acc:	ffffb097          	auipc	ra,0xffffb
    80005ad0:	388080e7          	jalr	904(ra) # 80000e54 <myproc>
    80005ad4:	ffffc097          	auipc	ra,0xffffc
    80005ad8:	cd8080e7          	jalr	-808(ra) # 800017ac <killed>
    80005adc:	e535                	bnez	a0,80005b48 <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    80005ade:	85a6                	mv	a1,s1
    80005ae0:	854a                	mv	a0,s2
    80005ae2:	ffffc097          	auipc	ra,0xffffc
    80005ae6:	a22080e7          	jalr	-1502(ra) # 80001504 <sleep>
    while(cons.r == cons.w){
    80005aea:	0984a783          	lw	a5,152(s1)
    80005aee:	09c4a703          	lw	a4,156(s1)
    80005af2:	fcf70de3          	beq	a4,a5,80005acc <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80005af6:	0017871b          	addiw	a4,a5,1
    80005afa:	08e4ac23          	sw	a4,152(s1)
    80005afe:	07f7f713          	andi	a4,a5,127
    80005b02:	9726                	add	a4,a4,s1
    80005b04:	01874703          	lbu	a4,24(a4)
    80005b08:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80005b0c:	077d0563          	beq	s10,s7,80005b76 <consoleread+0x106>
    cbuf = c;
    80005b10:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005b14:	4685                	li	a3,1
    80005b16:	f9f40613          	addi	a2,s0,-97
    80005b1a:	85d2                	mv	a1,s4
    80005b1c:	8556                	mv	a0,s5
    80005b1e:	ffffc097          	auipc	ra,0xffffc
    80005b22:	dee080e7          	jalr	-530(ra) # 8000190c <either_copyout>
    80005b26:	01850663          	beq	a0,s8,80005b32 <consoleread+0xc2>
    dst++;
    80005b2a:	0a05                	addi	s4,s4,1
    --n;
    80005b2c:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80005b2e:	f99d17e3          	bne	s10,s9,80005abc <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80005b32:	00020517          	auipc	a0,0x20
    80005b36:	73e50513          	addi	a0,a0,1854 # 80026270 <cons>
    80005b3a:	00001097          	auipc	ra,0x1
    80005b3e:	8fe080e7          	jalr	-1794(ra) # 80006438 <release>

  return target - n;
    80005b42:	413b053b          	subw	a0,s6,s3
    80005b46:	a811                	j	80005b5a <consoleread+0xea>
        release(&cons.lock);
    80005b48:	00020517          	auipc	a0,0x20
    80005b4c:	72850513          	addi	a0,a0,1832 # 80026270 <cons>
    80005b50:	00001097          	auipc	ra,0x1
    80005b54:	8e8080e7          	jalr	-1816(ra) # 80006438 <release>
        return -1;
    80005b58:	557d                	li	a0,-1
}
    80005b5a:	70a6                	ld	ra,104(sp)
    80005b5c:	7406                	ld	s0,96(sp)
    80005b5e:	64e6                	ld	s1,88(sp)
    80005b60:	6946                	ld	s2,80(sp)
    80005b62:	69a6                	ld	s3,72(sp)
    80005b64:	6a06                	ld	s4,64(sp)
    80005b66:	7ae2                	ld	s5,56(sp)
    80005b68:	7b42                	ld	s6,48(sp)
    80005b6a:	7ba2                	ld	s7,40(sp)
    80005b6c:	7c02                	ld	s8,32(sp)
    80005b6e:	6ce2                	ld	s9,24(sp)
    80005b70:	6d42                	ld	s10,16(sp)
    80005b72:	6165                	addi	sp,sp,112
    80005b74:	8082                	ret
      if(n < target){
    80005b76:	0009871b          	sext.w	a4,s3
    80005b7a:	fb677ce3          	bgeu	a4,s6,80005b32 <consoleread+0xc2>
        cons.r--;
    80005b7e:	00020717          	auipc	a4,0x20
    80005b82:	78f72523          	sw	a5,1930(a4) # 80026308 <cons+0x98>
    80005b86:	b775                	j	80005b32 <consoleread+0xc2>

0000000080005b88 <consputc>:
{
    80005b88:	1141                	addi	sp,sp,-16
    80005b8a:	e406                	sd	ra,8(sp)
    80005b8c:	e022                	sd	s0,0(sp)
    80005b8e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005b90:	10000793          	li	a5,256
    80005b94:	00f50a63          	beq	a0,a5,80005ba8 <consputc+0x20>
    uartputc_sync(c);
    80005b98:	00000097          	auipc	ra,0x0
    80005b9c:	560080e7          	jalr	1376(ra) # 800060f8 <uartputc_sync>
}
    80005ba0:	60a2                	ld	ra,8(sp)
    80005ba2:	6402                	ld	s0,0(sp)
    80005ba4:	0141                	addi	sp,sp,16
    80005ba6:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005ba8:	4521                	li	a0,8
    80005baa:	00000097          	auipc	ra,0x0
    80005bae:	54e080e7          	jalr	1358(ra) # 800060f8 <uartputc_sync>
    80005bb2:	02000513          	li	a0,32
    80005bb6:	00000097          	auipc	ra,0x0
    80005bba:	542080e7          	jalr	1346(ra) # 800060f8 <uartputc_sync>
    80005bbe:	4521                	li	a0,8
    80005bc0:	00000097          	auipc	ra,0x0
    80005bc4:	538080e7          	jalr	1336(ra) # 800060f8 <uartputc_sync>
    80005bc8:	bfe1                	j	80005ba0 <consputc+0x18>

0000000080005bca <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005bca:	1101                	addi	sp,sp,-32
    80005bcc:	ec06                	sd	ra,24(sp)
    80005bce:	e822                	sd	s0,16(sp)
    80005bd0:	e426                	sd	s1,8(sp)
    80005bd2:	e04a                	sd	s2,0(sp)
    80005bd4:	1000                	addi	s0,sp,32
    80005bd6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005bd8:	00020517          	auipc	a0,0x20
    80005bdc:	69850513          	addi	a0,a0,1688 # 80026270 <cons>
    80005be0:	00000097          	auipc	ra,0x0
    80005be4:	7a4080e7          	jalr	1956(ra) # 80006384 <acquire>

  switch(c){
    80005be8:	47d5                	li	a5,21
    80005bea:	0af48663          	beq	s1,a5,80005c96 <consoleintr+0xcc>
    80005bee:	0297ca63          	blt	a5,s1,80005c22 <consoleintr+0x58>
    80005bf2:	47a1                	li	a5,8
    80005bf4:	0ef48763          	beq	s1,a5,80005ce2 <consoleintr+0x118>
    80005bf8:	47c1                	li	a5,16
    80005bfa:	10f49a63          	bne	s1,a5,80005d0e <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005bfe:	ffffc097          	auipc	ra,0xffffc
    80005c02:	dba080e7          	jalr	-582(ra) # 800019b8 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005c06:	00020517          	auipc	a0,0x20
    80005c0a:	66a50513          	addi	a0,a0,1642 # 80026270 <cons>
    80005c0e:	00001097          	auipc	ra,0x1
    80005c12:	82a080e7          	jalr	-2006(ra) # 80006438 <release>
}
    80005c16:	60e2                	ld	ra,24(sp)
    80005c18:	6442                	ld	s0,16(sp)
    80005c1a:	64a2                	ld	s1,8(sp)
    80005c1c:	6902                	ld	s2,0(sp)
    80005c1e:	6105                	addi	sp,sp,32
    80005c20:	8082                	ret
  switch(c){
    80005c22:	07f00793          	li	a5,127
    80005c26:	0af48e63          	beq	s1,a5,80005ce2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005c2a:	00020717          	auipc	a4,0x20
    80005c2e:	64670713          	addi	a4,a4,1606 # 80026270 <cons>
    80005c32:	0a072783          	lw	a5,160(a4)
    80005c36:	09872703          	lw	a4,152(a4)
    80005c3a:	9f99                	subw	a5,a5,a4
    80005c3c:	07f00713          	li	a4,127
    80005c40:	fcf763e3          	bltu	a4,a5,80005c06 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005c44:	47b5                	li	a5,13
    80005c46:	0cf48763          	beq	s1,a5,80005d14 <consoleintr+0x14a>
      consputc(c);
    80005c4a:	8526                	mv	a0,s1
    80005c4c:	00000097          	auipc	ra,0x0
    80005c50:	f3c080e7          	jalr	-196(ra) # 80005b88 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005c54:	00020797          	auipc	a5,0x20
    80005c58:	61c78793          	addi	a5,a5,1564 # 80026270 <cons>
    80005c5c:	0a07a683          	lw	a3,160(a5)
    80005c60:	0016871b          	addiw	a4,a3,1
    80005c64:	0007061b          	sext.w	a2,a4
    80005c68:	0ae7a023          	sw	a4,160(a5)
    80005c6c:	07f6f693          	andi	a3,a3,127
    80005c70:	97b6                	add	a5,a5,a3
    80005c72:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005c76:	47a9                	li	a5,10
    80005c78:	0cf48563          	beq	s1,a5,80005d42 <consoleintr+0x178>
    80005c7c:	4791                	li	a5,4
    80005c7e:	0cf48263          	beq	s1,a5,80005d42 <consoleintr+0x178>
    80005c82:	00020797          	auipc	a5,0x20
    80005c86:	6867a783          	lw	a5,1670(a5) # 80026308 <cons+0x98>
    80005c8a:	9f1d                	subw	a4,a4,a5
    80005c8c:	08000793          	li	a5,128
    80005c90:	f6f71be3          	bne	a4,a5,80005c06 <consoleintr+0x3c>
    80005c94:	a07d                	j	80005d42 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005c96:	00020717          	auipc	a4,0x20
    80005c9a:	5da70713          	addi	a4,a4,1498 # 80026270 <cons>
    80005c9e:	0a072783          	lw	a5,160(a4)
    80005ca2:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005ca6:	00020497          	auipc	s1,0x20
    80005caa:	5ca48493          	addi	s1,s1,1482 # 80026270 <cons>
    while(cons.e != cons.w &&
    80005cae:	4929                	li	s2,10
    80005cb0:	f4f70be3          	beq	a4,a5,80005c06 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005cb4:	37fd                	addiw	a5,a5,-1
    80005cb6:	07f7f713          	andi	a4,a5,127
    80005cba:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005cbc:	01874703          	lbu	a4,24(a4)
    80005cc0:	f52703e3          	beq	a4,s2,80005c06 <consoleintr+0x3c>
      cons.e--;
    80005cc4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005cc8:	10000513          	li	a0,256
    80005ccc:	00000097          	auipc	ra,0x0
    80005cd0:	ebc080e7          	jalr	-324(ra) # 80005b88 <consputc>
    while(cons.e != cons.w &&
    80005cd4:	0a04a783          	lw	a5,160(s1)
    80005cd8:	09c4a703          	lw	a4,156(s1)
    80005cdc:	fcf71ce3          	bne	a4,a5,80005cb4 <consoleintr+0xea>
    80005ce0:	b71d                	j	80005c06 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005ce2:	00020717          	auipc	a4,0x20
    80005ce6:	58e70713          	addi	a4,a4,1422 # 80026270 <cons>
    80005cea:	0a072783          	lw	a5,160(a4)
    80005cee:	09c72703          	lw	a4,156(a4)
    80005cf2:	f0f70ae3          	beq	a4,a5,80005c06 <consoleintr+0x3c>
      cons.e--;
    80005cf6:	37fd                	addiw	a5,a5,-1
    80005cf8:	00020717          	auipc	a4,0x20
    80005cfc:	60f72c23          	sw	a5,1560(a4) # 80026310 <cons+0xa0>
      consputc(BACKSPACE);
    80005d00:	10000513          	li	a0,256
    80005d04:	00000097          	auipc	ra,0x0
    80005d08:	e84080e7          	jalr	-380(ra) # 80005b88 <consputc>
    80005d0c:	bded                	j	80005c06 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005d0e:	ee048ce3          	beqz	s1,80005c06 <consoleintr+0x3c>
    80005d12:	bf21                	j	80005c2a <consoleintr+0x60>
      consputc(c);
    80005d14:	4529                	li	a0,10
    80005d16:	00000097          	auipc	ra,0x0
    80005d1a:	e72080e7          	jalr	-398(ra) # 80005b88 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005d1e:	00020797          	auipc	a5,0x20
    80005d22:	55278793          	addi	a5,a5,1362 # 80026270 <cons>
    80005d26:	0a07a703          	lw	a4,160(a5)
    80005d2a:	0017069b          	addiw	a3,a4,1
    80005d2e:	0006861b          	sext.w	a2,a3
    80005d32:	0ad7a023          	sw	a3,160(a5)
    80005d36:	07f77713          	andi	a4,a4,127
    80005d3a:	97ba                	add	a5,a5,a4
    80005d3c:	4729                	li	a4,10
    80005d3e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005d42:	00020797          	auipc	a5,0x20
    80005d46:	5cc7a523          	sw	a2,1482(a5) # 8002630c <cons+0x9c>
        wakeup(&cons.r);
    80005d4a:	00020517          	auipc	a0,0x20
    80005d4e:	5be50513          	addi	a0,a0,1470 # 80026308 <cons+0x98>
    80005d52:	ffffc097          	auipc	ra,0xffffc
    80005d56:	816080e7          	jalr	-2026(ra) # 80001568 <wakeup>
    80005d5a:	b575                	j	80005c06 <consoleintr+0x3c>

0000000080005d5c <consoleinit>:

void
consoleinit(void)
{
    80005d5c:	1141                	addi	sp,sp,-16
    80005d5e:	e406                	sd	ra,8(sp)
    80005d60:	e022                	sd	s0,0(sp)
    80005d62:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005d64:	00003597          	auipc	a1,0x3
    80005d68:	a7458593          	addi	a1,a1,-1420 # 800087d8 <syscalls+0x408>
    80005d6c:	00020517          	auipc	a0,0x20
    80005d70:	50450513          	addi	a0,a0,1284 # 80026270 <cons>
    80005d74:	00000097          	auipc	ra,0x0
    80005d78:	580080e7          	jalr	1408(ra) # 800062f4 <initlock>

  uartinit();
    80005d7c:	00000097          	auipc	ra,0x0
    80005d80:	32c080e7          	jalr	812(ra) # 800060a8 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005d84:	00017797          	auipc	a5,0x17
    80005d88:	21478793          	addi	a5,a5,532 # 8001cf98 <devsw>
    80005d8c:	00000717          	auipc	a4,0x0
    80005d90:	ce470713          	addi	a4,a4,-796 # 80005a70 <consoleread>
    80005d94:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005d96:	00000717          	auipc	a4,0x0
    80005d9a:	c7670713          	addi	a4,a4,-906 # 80005a0c <consolewrite>
    80005d9e:	ef98                	sd	a4,24(a5)
}
    80005da0:	60a2                	ld	ra,8(sp)
    80005da2:	6402                	ld	s0,0(sp)
    80005da4:	0141                	addi	sp,sp,16
    80005da6:	8082                	ret

0000000080005da8 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005da8:	7179                	addi	sp,sp,-48
    80005daa:	f406                	sd	ra,40(sp)
    80005dac:	f022                	sd	s0,32(sp)
    80005dae:	ec26                	sd	s1,24(sp)
    80005db0:	e84a                	sd	s2,16(sp)
    80005db2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005db4:	c219                	beqz	a2,80005dba <printint+0x12>
    80005db6:	08054763          	bltz	a0,80005e44 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    80005dba:	2501                	sext.w	a0,a0
    80005dbc:	4881                	li	a7,0
    80005dbe:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005dc2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005dc4:	2581                	sext.w	a1,a1
    80005dc6:	00003617          	auipc	a2,0x3
    80005dca:	a4260613          	addi	a2,a2,-1470 # 80008808 <digits>
    80005dce:	883a                	mv	a6,a4
    80005dd0:	2705                	addiw	a4,a4,1
    80005dd2:	02b577bb          	remuw	a5,a0,a1
    80005dd6:	1782                	slli	a5,a5,0x20
    80005dd8:	9381                	srli	a5,a5,0x20
    80005dda:	97b2                	add	a5,a5,a2
    80005ddc:	0007c783          	lbu	a5,0(a5)
    80005de0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005de4:	0005079b          	sext.w	a5,a0
    80005de8:	02b5553b          	divuw	a0,a0,a1
    80005dec:	0685                	addi	a3,a3,1
    80005dee:	feb7f0e3          	bgeu	a5,a1,80005dce <printint+0x26>

  if(sign)
    80005df2:	00088c63          	beqz	a7,80005e0a <printint+0x62>
    buf[i++] = '-';
    80005df6:	fe070793          	addi	a5,a4,-32
    80005dfa:	00878733          	add	a4,a5,s0
    80005dfe:	02d00793          	li	a5,45
    80005e02:	fef70823          	sb	a5,-16(a4)
    80005e06:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005e0a:	02e05763          	blez	a4,80005e38 <printint+0x90>
    80005e0e:	fd040793          	addi	a5,s0,-48
    80005e12:	00e784b3          	add	s1,a5,a4
    80005e16:	fff78913          	addi	s2,a5,-1
    80005e1a:	993a                	add	s2,s2,a4
    80005e1c:	377d                	addiw	a4,a4,-1
    80005e1e:	1702                	slli	a4,a4,0x20
    80005e20:	9301                	srli	a4,a4,0x20
    80005e22:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005e26:	fff4c503          	lbu	a0,-1(s1)
    80005e2a:	00000097          	auipc	ra,0x0
    80005e2e:	d5e080e7          	jalr	-674(ra) # 80005b88 <consputc>
  while(--i >= 0)
    80005e32:	14fd                	addi	s1,s1,-1
    80005e34:	ff2499e3          	bne	s1,s2,80005e26 <printint+0x7e>
}
    80005e38:	70a2                	ld	ra,40(sp)
    80005e3a:	7402                	ld	s0,32(sp)
    80005e3c:	64e2                	ld	s1,24(sp)
    80005e3e:	6942                	ld	s2,16(sp)
    80005e40:	6145                	addi	sp,sp,48
    80005e42:	8082                	ret
    x = -xx;
    80005e44:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005e48:	4885                	li	a7,1
    x = -xx;
    80005e4a:	bf95                	j	80005dbe <printint+0x16>

0000000080005e4c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005e4c:	1101                	addi	sp,sp,-32
    80005e4e:	ec06                	sd	ra,24(sp)
    80005e50:	e822                	sd	s0,16(sp)
    80005e52:	e426                	sd	s1,8(sp)
    80005e54:	1000                	addi	s0,sp,32
    80005e56:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005e58:	00020797          	auipc	a5,0x20
    80005e5c:	4c07ac23          	sw	zero,1240(a5) # 80026330 <pr+0x18>
  printf("panic: ");
    80005e60:	00003517          	auipc	a0,0x3
    80005e64:	98050513          	addi	a0,a0,-1664 # 800087e0 <syscalls+0x410>
    80005e68:	00000097          	auipc	ra,0x0
    80005e6c:	02e080e7          	jalr	46(ra) # 80005e96 <printf>
  printf(s);
    80005e70:	8526                	mv	a0,s1
    80005e72:	00000097          	auipc	ra,0x0
    80005e76:	024080e7          	jalr	36(ra) # 80005e96 <printf>
  printf("\n");
    80005e7a:	00002517          	auipc	a0,0x2
    80005e7e:	1ce50513          	addi	a0,a0,462 # 80008048 <etext+0x48>
    80005e82:	00000097          	auipc	ra,0x0
    80005e86:	014080e7          	jalr	20(ra) # 80005e96 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005e8a:	4785                	li	a5,1
    80005e8c:	00003717          	auipc	a4,0x3
    80005e90:	a6f72023          	sw	a5,-1440(a4) # 800088ec <panicked>
  for(;;)
    80005e94:	a001                	j	80005e94 <panic+0x48>

0000000080005e96 <printf>:
{
    80005e96:	7131                	addi	sp,sp,-192
    80005e98:	fc86                	sd	ra,120(sp)
    80005e9a:	f8a2                	sd	s0,112(sp)
    80005e9c:	f4a6                	sd	s1,104(sp)
    80005e9e:	f0ca                	sd	s2,96(sp)
    80005ea0:	ecce                	sd	s3,88(sp)
    80005ea2:	e8d2                	sd	s4,80(sp)
    80005ea4:	e4d6                	sd	s5,72(sp)
    80005ea6:	e0da                	sd	s6,64(sp)
    80005ea8:	fc5e                	sd	s7,56(sp)
    80005eaa:	f862                	sd	s8,48(sp)
    80005eac:	f466                	sd	s9,40(sp)
    80005eae:	f06a                	sd	s10,32(sp)
    80005eb0:	ec6e                	sd	s11,24(sp)
    80005eb2:	0100                	addi	s0,sp,128
    80005eb4:	8a2a                	mv	s4,a0
    80005eb6:	e40c                	sd	a1,8(s0)
    80005eb8:	e810                	sd	a2,16(s0)
    80005eba:	ec14                	sd	a3,24(s0)
    80005ebc:	f018                	sd	a4,32(s0)
    80005ebe:	f41c                	sd	a5,40(s0)
    80005ec0:	03043823          	sd	a6,48(s0)
    80005ec4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005ec8:	00020d97          	auipc	s11,0x20
    80005ecc:	468dad83          	lw	s11,1128(s11) # 80026330 <pr+0x18>
  if(locking)
    80005ed0:	020d9b63          	bnez	s11,80005f06 <printf+0x70>
  if (fmt == 0)
    80005ed4:	040a0263          	beqz	s4,80005f18 <printf+0x82>
  va_start(ap, fmt);
    80005ed8:	00840793          	addi	a5,s0,8
    80005edc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005ee0:	000a4503          	lbu	a0,0(s4)
    80005ee4:	14050f63          	beqz	a0,80006042 <printf+0x1ac>
    80005ee8:	4981                	li	s3,0
    if(c != '%'){
    80005eea:	02500a93          	li	s5,37
    switch(c){
    80005eee:	07000b93          	li	s7,112
  consputc('x');
    80005ef2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005ef4:	00003b17          	auipc	s6,0x3
    80005ef8:	914b0b13          	addi	s6,s6,-1772 # 80008808 <digits>
    switch(c){
    80005efc:	07300c93          	li	s9,115
    80005f00:	06400c13          	li	s8,100
    80005f04:	a82d                	j	80005f3e <printf+0xa8>
    acquire(&pr.lock);
    80005f06:	00020517          	auipc	a0,0x20
    80005f0a:	41250513          	addi	a0,a0,1042 # 80026318 <pr>
    80005f0e:	00000097          	auipc	ra,0x0
    80005f12:	476080e7          	jalr	1142(ra) # 80006384 <acquire>
    80005f16:	bf7d                	j	80005ed4 <printf+0x3e>
    panic("null fmt");
    80005f18:	00003517          	auipc	a0,0x3
    80005f1c:	8d850513          	addi	a0,a0,-1832 # 800087f0 <syscalls+0x420>
    80005f20:	00000097          	auipc	ra,0x0
    80005f24:	f2c080e7          	jalr	-212(ra) # 80005e4c <panic>
      consputc(c);
    80005f28:	00000097          	auipc	ra,0x0
    80005f2c:	c60080e7          	jalr	-928(ra) # 80005b88 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005f30:	2985                	addiw	s3,s3,1
    80005f32:	013a07b3          	add	a5,s4,s3
    80005f36:	0007c503          	lbu	a0,0(a5)
    80005f3a:	10050463          	beqz	a0,80006042 <printf+0x1ac>
    if(c != '%'){
    80005f3e:	ff5515e3          	bne	a0,s5,80005f28 <printf+0x92>
    c = fmt[++i] & 0xff;
    80005f42:	2985                	addiw	s3,s3,1
    80005f44:	013a07b3          	add	a5,s4,s3
    80005f48:	0007c783          	lbu	a5,0(a5)
    80005f4c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80005f50:	cbed                	beqz	a5,80006042 <printf+0x1ac>
    switch(c){
    80005f52:	05778a63          	beq	a5,s7,80005fa6 <printf+0x110>
    80005f56:	02fbf663          	bgeu	s7,a5,80005f82 <printf+0xec>
    80005f5a:	09978863          	beq	a5,s9,80005fea <printf+0x154>
    80005f5e:	07800713          	li	a4,120
    80005f62:	0ce79563          	bne	a5,a4,8000602c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80005f66:	f8843783          	ld	a5,-120(s0)
    80005f6a:	00878713          	addi	a4,a5,8
    80005f6e:	f8e43423          	sd	a4,-120(s0)
    80005f72:	4605                	li	a2,1
    80005f74:	85ea                	mv	a1,s10
    80005f76:	4388                	lw	a0,0(a5)
    80005f78:	00000097          	auipc	ra,0x0
    80005f7c:	e30080e7          	jalr	-464(ra) # 80005da8 <printint>
      break;
    80005f80:	bf45                	j	80005f30 <printf+0x9a>
    switch(c){
    80005f82:	09578f63          	beq	a5,s5,80006020 <printf+0x18a>
    80005f86:	0b879363          	bne	a5,s8,8000602c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80005f8a:	f8843783          	ld	a5,-120(s0)
    80005f8e:	00878713          	addi	a4,a5,8
    80005f92:	f8e43423          	sd	a4,-120(s0)
    80005f96:	4605                	li	a2,1
    80005f98:	45a9                	li	a1,10
    80005f9a:	4388                	lw	a0,0(a5)
    80005f9c:	00000097          	auipc	ra,0x0
    80005fa0:	e0c080e7          	jalr	-500(ra) # 80005da8 <printint>
      break;
    80005fa4:	b771                	j	80005f30 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005fa6:	f8843783          	ld	a5,-120(s0)
    80005faa:	00878713          	addi	a4,a5,8
    80005fae:	f8e43423          	sd	a4,-120(s0)
    80005fb2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80005fb6:	03000513          	li	a0,48
    80005fba:	00000097          	auipc	ra,0x0
    80005fbe:	bce080e7          	jalr	-1074(ra) # 80005b88 <consputc>
  consputc('x');
    80005fc2:	07800513          	li	a0,120
    80005fc6:	00000097          	auipc	ra,0x0
    80005fca:	bc2080e7          	jalr	-1086(ra) # 80005b88 <consputc>
    80005fce:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005fd0:	03c95793          	srli	a5,s2,0x3c
    80005fd4:	97da                	add	a5,a5,s6
    80005fd6:	0007c503          	lbu	a0,0(a5)
    80005fda:	00000097          	auipc	ra,0x0
    80005fde:	bae080e7          	jalr	-1106(ra) # 80005b88 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005fe2:	0912                	slli	s2,s2,0x4
    80005fe4:	34fd                	addiw	s1,s1,-1
    80005fe6:	f4ed                	bnez	s1,80005fd0 <printf+0x13a>
    80005fe8:	b7a1                	j	80005f30 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80005fea:	f8843783          	ld	a5,-120(s0)
    80005fee:	00878713          	addi	a4,a5,8
    80005ff2:	f8e43423          	sd	a4,-120(s0)
    80005ff6:	6384                	ld	s1,0(a5)
    80005ff8:	cc89                	beqz	s1,80006012 <printf+0x17c>
      for(; *s; s++)
    80005ffa:	0004c503          	lbu	a0,0(s1)
    80005ffe:	d90d                	beqz	a0,80005f30 <printf+0x9a>
        consputc(*s);
    80006000:	00000097          	auipc	ra,0x0
    80006004:	b88080e7          	jalr	-1144(ra) # 80005b88 <consputc>
      for(; *s; s++)
    80006008:	0485                	addi	s1,s1,1
    8000600a:	0004c503          	lbu	a0,0(s1)
    8000600e:	f96d                	bnez	a0,80006000 <printf+0x16a>
    80006010:	b705                	j	80005f30 <printf+0x9a>
        s = "(null)";
    80006012:	00002497          	auipc	s1,0x2
    80006016:	7d648493          	addi	s1,s1,2006 # 800087e8 <syscalls+0x418>
      for(; *s; s++)
    8000601a:	02800513          	li	a0,40
    8000601e:	b7cd                	j	80006000 <printf+0x16a>
      consputc('%');
    80006020:	8556                	mv	a0,s5
    80006022:	00000097          	auipc	ra,0x0
    80006026:	b66080e7          	jalr	-1178(ra) # 80005b88 <consputc>
      break;
    8000602a:	b719                	j	80005f30 <printf+0x9a>
      consputc('%');
    8000602c:	8556                	mv	a0,s5
    8000602e:	00000097          	auipc	ra,0x0
    80006032:	b5a080e7          	jalr	-1190(ra) # 80005b88 <consputc>
      consputc(c);
    80006036:	8526                	mv	a0,s1
    80006038:	00000097          	auipc	ra,0x0
    8000603c:	b50080e7          	jalr	-1200(ra) # 80005b88 <consputc>
      break;
    80006040:	bdc5                	j	80005f30 <printf+0x9a>
  if(locking)
    80006042:	020d9163          	bnez	s11,80006064 <printf+0x1ce>
}
    80006046:	70e6                	ld	ra,120(sp)
    80006048:	7446                	ld	s0,112(sp)
    8000604a:	74a6                	ld	s1,104(sp)
    8000604c:	7906                	ld	s2,96(sp)
    8000604e:	69e6                	ld	s3,88(sp)
    80006050:	6a46                	ld	s4,80(sp)
    80006052:	6aa6                	ld	s5,72(sp)
    80006054:	6b06                	ld	s6,64(sp)
    80006056:	7be2                	ld	s7,56(sp)
    80006058:	7c42                	ld	s8,48(sp)
    8000605a:	7ca2                	ld	s9,40(sp)
    8000605c:	7d02                	ld	s10,32(sp)
    8000605e:	6de2                	ld	s11,24(sp)
    80006060:	6129                	addi	sp,sp,192
    80006062:	8082                	ret
    release(&pr.lock);
    80006064:	00020517          	auipc	a0,0x20
    80006068:	2b450513          	addi	a0,a0,692 # 80026318 <pr>
    8000606c:	00000097          	auipc	ra,0x0
    80006070:	3cc080e7          	jalr	972(ra) # 80006438 <release>
}
    80006074:	bfc9                	j	80006046 <printf+0x1b0>

0000000080006076 <printfinit>:
    ;
}

void
printfinit(void)
{
    80006076:	1101                	addi	sp,sp,-32
    80006078:	ec06                	sd	ra,24(sp)
    8000607a:	e822                	sd	s0,16(sp)
    8000607c:	e426                	sd	s1,8(sp)
    8000607e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80006080:	00020497          	auipc	s1,0x20
    80006084:	29848493          	addi	s1,s1,664 # 80026318 <pr>
    80006088:	00002597          	auipc	a1,0x2
    8000608c:	77858593          	addi	a1,a1,1912 # 80008800 <syscalls+0x430>
    80006090:	8526                	mv	a0,s1
    80006092:	00000097          	auipc	ra,0x0
    80006096:	262080e7          	jalr	610(ra) # 800062f4 <initlock>
  pr.locking = 1;
    8000609a:	4785                	li	a5,1
    8000609c:	cc9c                	sw	a5,24(s1)
}
    8000609e:	60e2                	ld	ra,24(sp)
    800060a0:	6442                	ld	s0,16(sp)
    800060a2:	64a2                	ld	s1,8(sp)
    800060a4:	6105                	addi	sp,sp,32
    800060a6:	8082                	ret

00000000800060a8 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800060a8:	1141                	addi	sp,sp,-16
    800060aa:	e406                	sd	ra,8(sp)
    800060ac:	e022                	sd	s0,0(sp)
    800060ae:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800060b0:	100007b7          	lui	a5,0x10000
    800060b4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800060b8:	f8000713          	li	a4,-128
    800060bc:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800060c0:	470d                	li	a4,3
    800060c2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800060c6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800060ca:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800060ce:	469d                	li	a3,7
    800060d0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800060d4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800060d8:	00002597          	auipc	a1,0x2
    800060dc:	74858593          	addi	a1,a1,1864 # 80008820 <digits+0x18>
    800060e0:	00020517          	auipc	a0,0x20
    800060e4:	25850513          	addi	a0,a0,600 # 80026338 <uart_tx_lock>
    800060e8:	00000097          	auipc	ra,0x0
    800060ec:	20c080e7          	jalr	524(ra) # 800062f4 <initlock>
}
    800060f0:	60a2                	ld	ra,8(sp)
    800060f2:	6402                	ld	s0,0(sp)
    800060f4:	0141                	addi	sp,sp,16
    800060f6:	8082                	ret

00000000800060f8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800060f8:	1101                	addi	sp,sp,-32
    800060fa:	ec06                	sd	ra,24(sp)
    800060fc:	e822                	sd	s0,16(sp)
    800060fe:	e426                	sd	s1,8(sp)
    80006100:	1000                	addi	s0,sp,32
    80006102:	84aa                	mv	s1,a0
  push_off();
    80006104:	00000097          	auipc	ra,0x0
    80006108:	234080e7          	jalr	564(ra) # 80006338 <push_off>

  if(panicked){
    8000610c:	00002797          	auipc	a5,0x2
    80006110:	7e07a783          	lw	a5,2016(a5) # 800088ec <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006114:	10000737          	lui	a4,0x10000
  if(panicked){
    80006118:	c391                	beqz	a5,8000611c <uartputc_sync+0x24>
    for(;;)
    8000611a:	a001                	j	8000611a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000611c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80006120:	0207f793          	andi	a5,a5,32
    80006124:	dfe5                	beqz	a5,8000611c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80006126:	0ff4f513          	zext.b	a0,s1
    8000612a:	100007b7          	lui	a5,0x10000
    8000612e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80006132:	00000097          	auipc	ra,0x0
    80006136:	2a6080e7          	jalr	678(ra) # 800063d8 <pop_off>
}
    8000613a:	60e2                	ld	ra,24(sp)
    8000613c:	6442                	ld	s0,16(sp)
    8000613e:	64a2                	ld	s1,8(sp)
    80006140:	6105                	addi	sp,sp,32
    80006142:	8082                	ret

0000000080006144 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80006144:	00002797          	auipc	a5,0x2
    80006148:	7ac7b783          	ld	a5,1964(a5) # 800088f0 <uart_tx_r>
    8000614c:	00002717          	auipc	a4,0x2
    80006150:	7ac73703          	ld	a4,1964(a4) # 800088f8 <uart_tx_w>
    80006154:	06f70a63          	beq	a4,a5,800061c8 <uartstart+0x84>
{
    80006158:	7139                	addi	sp,sp,-64
    8000615a:	fc06                	sd	ra,56(sp)
    8000615c:	f822                	sd	s0,48(sp)
    8000615e:	f426                	sd	s1,40(sp)
    80006160:	f04a                	sd	s2,32(sp)
    80006162:	ec4e                	sd	s3,24(sp)
    80006164:	e852                	sd	s4,16(sp)
    80006166:	e456                	sd	s5,8(sp)
    80006168:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000616a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000616e:	00020a17          	auipc	s4,0x20
    80006172:	1caa0a13          	addi	s4,s4,458 # 80026338 <uart_tx_lock>
    uart_tx_r += 1;
    80006176:	00002497          	auipc	s1,0x2
    8000617a:	77a48493          	addi	s1,s1,1914 # 800088f0 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000617e:	00002997          	auipc	s3,0x2
    80006182:	77a98993          	addi	s3,s3,1914 # 800088f8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80006186:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000618a:	02077713          	andi	a4,a4,32
    8000618e:	c705                	beqz	a4,800061b6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80006190:	01f7f713          	andi	a4,a5,31
    80006194:	9752                	add	a4,a4,s4
    80006196:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000619a:	0785                	addi	a5,a5,1
    8000619c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000619e:	8526                	mv	a0,s1
    800061a0:	ffffb097          	auipc	ra,0xffffb
    800061a4:	3c8080e7          	jalr	968(ra) # 80001568 <wakeup>
    
    WriteReg(THR, c);
    800061a8:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800061ac:	609c                	ld	a5,0(s1)
    800061ae:	0009b703          	ld	a4,0(s3)
    800061b2:	fcf71ae3          	bne	a4,a5,80006186 <uartstart+0x42>
  }
}
    800061b6:	70e2                	ld	ra,56(sp)
    800061b8:	7442                	ld	s0,48(sp)
    800061ba:	74a2                	ld	s1,40(sp)
    800061bc:	7902                	ld	s2,32(sp)
    800061be:	69e2                	ld	s3,24(sp)
    800061c0:	6a42                	ld	s4,16(sp)
    800061c2:	6aa2                	ld	s5,8(sp)
    800061c4:	6121                	addi	sp,sp,64
    800061c6:	8082                	ret
    800061c8:	8082                	ret

00000000800061ca <uartputc>:
{
    800061ca:	7179                	addi	sp,sp,-48
    800061cc:	f406                	sd	ra,40(sp)
    800061ce:	f022                	sd	s0,32(sp)
    800061d0:	ec26                	sd	s1,24(sp)
    800061d2:	e84a                	sd	s2,16(sp)
    800061d4:	e44e                	sd	s3,8(sp)
    800061d6:	e052                	sd	s4,0(sp)
    800061d8:	1800                	addi	s0,sp,48
    800061da:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800061dc:	00020517          	auipc	a0,0x20
    800061e0:	15c50513          	addi	a0,a0,348 # 80026338 <uart_tx_lock>
    800061e4:	00000097          	auipc	ra,0x0
    800061e8:	1a0080e7          	jalr	416(ra) # 80006384 <acquire>
  if(panicked){
    800061ec:	00002797          	auipc	a5,0x2
    800061f0:	7007a783          	lw	a5,1792(a5) # 800088ec <panicked>
    800061f4:	e7c9                	bnez	a5,8000627e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800061f6:	00002717          	auipc	a4,0x2
    800061fa:	70273703          	ld	a4,1794(a4) # 800088f8 <uart_tx_w>
    800061fe:	00002797          	auipc	a5,0x2
    80006202:	6f27b783          	ld	a5,1778(a5) # 800088f0 <uart_tx_r>
    80006206:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000620a:	00020997          	auipc	s3,0x20
    8000620e:	12e98993          	addi	s3,s3,302 # 80026338 <uart_tx_lock>
    80006212:	00002497          	auipc	s1,0x2
    80006216:	6de48493          	addi	s1,s1,1758 # 800088f0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000621a:	00002917          	auipc	s2,0x2
    8000621e:	6de90913          	addi	s2,s2,1758 # 800088f8 <uart_tx_w>
    80006222:	00e79f63          	bne	a5,a4,80006240 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80006226:	85ce                	mv	a1,s3
    80006228:	8526                	mv	a0,s1
    8000622a:	ffffb097          	auipc	ra,0xffffb
    8000622e:	2da080e7          	jalr	730(ra) # 80001504 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006232:	00093703          	ld	a4,0(s2)
    80006236:	609c                	ld	a5,0(s1)
    80006238:	02078793          	addi	a5,a5,32
    8000623c:	fee785e3          	beq	a5,a4,80006226 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80006240:	00020497          	auipc	s1,0x20
    80006244:	0f848493          	addi	s1,s1,248 # 80026338 <uart_tx_lock>
    80006248:	01f77793          	andi	a5,a4,31
    8000624c:	97a6                	add	a5,a5,s1
    8000624e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80006252:	0705                	addi	a4,a4,1
    80006254:	00002797          	auipc	a5,0x2
    80006258:	6ae7b223          	sd	a4,1700(a5) # 800088f8 <uart_tx_w>
  uartstart();
    8000625c:	00000097          	auipc	ra,0x0
    80006260:	ee8080e7          	jalr	-280(ra) # 80006144 <uartstart>
  release(&uart_tx_lock);
    80006264:	8526                	mv	a0,s1
    80006266:	00000097          	auipc	ra,0x0
    8000626a:	1d2080e7          	jalr	466(ra) # 80006438 <release>
}
    8000626e:	70a2                	ld	ra,40(sp)
    80006270:	7402                	ld	s0,32(sp)
    80006272:	64e2                	ld	s1,24(sp)
    80006274:	6942                	ld	s2,16(sp)
    80006276:	69a2                	ld	s3,8(sp)
    80006278:	6a02                	ld	s4,0(sp)
    8000627a:	6145                	addi	sp,sp,48
    8000627c:	8082                	ret
    for(;;)
    8000627e:	a001                	j	8000627e <uartputc+0xb4>

0000000080006280 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80006280:	1141                	addi	sp,sp,-16
    80006282:	e422                	sd	s0,8(sp)
    80006284:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80006286:	100007b7          	lui	a5,0x10000
    8000628a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000628e:	8b85                	andi	a5,a5,1
    80006290:	cb81                	beqz	a5,800062a0 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80006292:	100007b7          	lui	a5,0x10000
    80006296:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000629a:	6422                	ld	s0,8(sp)
    8000629c:	0141                	addi	sp,sp,16
    8000629e:	8082                	ret
    return -1;
    800062a0:	557d                	li	a0,-1
    800062a2:	bfe5                	j	8000629a <uartgetc+0x1a>

00000000800062a4 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800062a4:	1101                	addi	sp,sp,-32
    800062a6:	ec06                	sd	ra,24(sp)
    800062a8:	e822                	sd	s0,16(sp)
    800062aa:	e426                	sd	s1,8(sp)
    800062ac:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800062ae:	54fd                	li	s1,-1
    800062b0:	a029                	j	800062ba <uartintr+0x16>
      break;
    consoleintr(c);
    800062b2:	00000097          	auipc	ra,0x0
    800062b6:	918080e7          	jalr	-1768(ra) # 80005bca <consoleintr>
    int c = uartgetc();
    800062ba:	00000097          	auipc	ra,0x0
    800062be:	fc6080e7          	jalr	-58(ra) # 80006280 <uartgetc>
    if(c == -1)
    800062c2:	fe9518e3          	bne	a0,s1,800062b2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800062c6:	00020497          	auipc	s1,0x20
    800062ca:	07248493          	addi	s1,s1,114 # 80026338 <uart_tx_lock>
    800062ce:	8526                	mv	a0,s1
    800062d0:	00000097          	auipc	ra,0x0
    800062d4:	0b4080e7          	jalr	180(ra) # 80006384 <acquire>
  uartstart();
    800062d8:	00000097          	auipc	ra,0x0
    800062dc:	e6c080e7          	jalr	-404(ra) # 80006144 <uartstart>
  release(&uart_tx_lock);
    800062e0:	8526                	mv	a0,s1
    800062e2:	00000097          	auipc	ra,0x0
    800062e6:	156080e7          	jalr	342(ra) # 80006438 <release>
}
    800062ea:	60e2                	ld	ra,24(sp)
    800062ec:	6442                	ld	s0,16(sp)
    800062ee:	64a2                	ld	s1,8(sp)
    800062f0:	6105                	addi	sp,sp,32
    800062f2:	8082                	ret

00000000800062f4 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800062f4:	1141                	addi	sp,sp,-16
    800062f6:	e422                	sd	s0,8(sp)
    800062f8:	0800                	addi	s0,sp,16
  lk->name = name;
    800062fa:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800062fc:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80006300:	00053823          	sd	zero,16(a0)
}
    80006304:	6422                	ld	s0,8(sp)
    80006306:	0141                	addi	sp,sp,16
    80006308:	8082                	ret

000000008000630a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    8000630a:	411c                	lw	a5,0(a0)
    8000630c:	e399                	bnez	a5,80006312 <holding+0x8>
    8000630e:	4501                	li	a0,0
  return r;
}
    80006310:	8082                	ret
{
    80006312:	1101                	addi	sp,sp,-32
    80006314:	ec06                	sd	ra,24(sp)
    80006316:	e822                	sd	s0,16(sp)
    80006318:	e426                	sd	s1,8(sp)
    8000631a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    8000631c:	6904                	ld	s1,16(a0)
    8000631e:	ffffb097          	auipc	ra,0xffffb
    80006322:	b1a080e7          	jalr	-1254(ra) # 80000e38 <mycpu>
    80006326:	40a48533          	sub	a0,s1,a0
    8000632a:	00153513          	seqz	a0,a0
}
    8000632e:	60e2                	ld	ra,24(sp)
    80006330:	6442                	ld	s0,16(sp)
    80006332:	64a2                	ld	s1,8(sp)
    80006334:	6105                	addi	sp,sp,32
    80006336:	8082                	ret

0000000080006338 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80006338:	1101                	addi	sp,sp,-32
    8000633a:	ec06                	sd	ra,24(sp)
    8000633c:	e822                	sd	s0,16(sp)
    8000633e:	e426                	sd	s1,8(sp)
    80006340:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006342:	100024f3          	csrr	s1,sstatus
    80006346:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000634a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000634c:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80006350:	ffffb097          	auipc	ra,0xffffb
    80006354:	ae8080e7          	jalr	-1304(ra) # 80000e38 <mycpu>
    80006358:	5d3c                	lw	a5,120(a0)
    8000635a:	cf89                	beqz	a5,80006374 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000635c:	ffffb097          	auipc	ra,0xffffb
    80006360:	adc080e7          	jalr	-1316(ra) # 80000e38 <mycpu>
    80006364:	5d3c                	lw	a5,120(a0)
    80006366:	2785                	addiw	a5,a5,1
    80006368:	dd3c                	sw	a5,120(a0)
}
    8000636a:	60e2                	ld	ra,24(sp)
    8000636c:	6442                	ld	s0,16(sp)
    8000636e:	64a2                	ld	s1,8(sp)
    80006370:	6105                	addi	sp,sp,32
    80006372:	8082                	ret
    mycpu()->intena = old;
    80006374:	ffffb097          	auipc	ra,0xffffb
    80006378:	ac4080e7          	jalr	-1340(ra) # 80000e38 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000637c:	8085                	srli	s1,s1,0x1
    8000637e:	8885                	andi	s1,s1,1
    80006380:	dd64                	sw	s1,124(a0)
    80006382:	bfe9                	j	8000635c <push_off+0x24>

0000000080006384 <acquire>:
{
    80006384:	1101                	addi	sp,sp,-32
    80006386:	ec06                	sd	ra,24(sp)
    80006388:	e822                	sd	s0,16(sp)
    8000638a:	e426                	sd	s1,8(sp)
    8000638c:	1000                	addi	s0,sp,32
    8000638e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80006390:	00000097          	auipc	ra,0x0
    80006394:	fa8080e7          	jalr	-88(ra) # 80006338 <push_off>
  if(holding(lk))
    80006398:	8526                	mv	a0,s1
    8000639a:	00000097          	auipc	ra,0x0
    8000639e:	f70080e7          	jalr	-144(ra) # 8000630a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800063a2:	4705                	li	a4,1
  if(holding(lk))
    800063a4:	e115                	bnez	a0,800063c8 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800063a6:	87ba                	mv	a5,a4
    800063a8:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800063ac:	2781                	sext.w	a5,a5
    800063ae:	ffe5                	bnez	a5,800063a6 <acquire+0x22>
  __sync_synchronize();
    800063b0:	0ff0000f          	fence
  lk->cpu = mycpu();
    800063b4:	ffffb097          	auipc	ra,0xffffb
    800063b8:	a84080e7          	jalr	-1404(ra) # 80000e38 <mycpu>
    800063bc:	e888                	sd	a0,16(s1)
}
    800063be:	60e2                	ld	ra,24(sp)
    800063c0:	6442                	ld	s0,16(sp)
    800063c2:	64a2                	ld	s1,8(sp)
    800063c4:	6105                	addi	sp,sp,32
    800063c6:	8082                	ret
    panic("acquire");
    800063c8:	00002517          	auipc	a0,0x2
    800063cc:	46050513          	addi	a0,a0,1120 # 80008828 <digits+0x20>
    800063d0:	00000097          	auipc	ra,0x0
    800063d4:	a7c080e7          	jalr	-1412(ra) # 80005e4c <panic>

00000000800063d8 <pop_off>:

void
pop_off(void)
{
    800063d8:	1141                	addi	sp,sp,-16
    800063da:	e406                	sd	ra,8(sp)
    800063dc:	e022                	sd	s0,0(sp)
    800063de:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800063e0:	ffffb097          	auipc	ra,0xffffb
    800063e4:	a58080e7          	jalr	-1448(ra) # 80000e38 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800063e8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800063ec:	8b89                	andi	a5,a5,2
  if(intr_get())
    800063ee:	e78d                	bnez	a5,80006418 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800063f0:	5d3c                	lw	a5,120(a0)
    800063f2:	02f05b63          	blez	a5,80006428 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    800063f6:	37fd                	addiw	a5,a5,-1
    800063f8:	0007871b          	sext.w	a4,a5
    800063fc:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800063fe:	eb09                	bnez	a4,80006410 <pop_off+0x38>
    80006400:	5d7c                	lw	a5,124(a0)
    80006402:	c799                	beqz	a5,80006410 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006404:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80006408:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000640c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80006410:	60a2                	ld	ra,8(sp)
    80006412:	6402                	ld	s0,0(sp)
    80006414:	0141                	addi	sp,sp,16
    80006416:	8082                	ret
    panic("pop_off - interruptible");
    80006418:	00002517          	auipc	a0,0x2
    8000641c:	41850513          	addi	a0,a0,1048 # 80008830 <digits+0x28>
    80006420:	00000097          	auipc	ra,0x0
    80006424:	a2c080e7          	jalr	-1492(ra) # 80005e4c <panic>
    panic("pop_off");
    80006428:	00002517          	auipc	a0,0x2
    8000642c:	42050513          	addi	a0,a0,1056 # 80008848 <digits+0x40>
    80006430:	00000097          	auipc	ra,0x0
    80006434:	a1c080e7          	jalr	-1508(ra) # 80005e4c <panic>

0000000080006438 <release>:
{
    80006438:	1101                	addi	sp,sp,-32
    8000643a:	ec06                	sd	ra,24(sp)
    8000643c:	e822                	sd	s0,16(sp)
    8000643e:	e426                	sd	s1,8(sp)
    80006440:	1000                	addi	s0,sp,32
    80006442:	84aa                	mv	s1,a0
  if(!holding(lk))
    80006444:	00000097          	auipc	ra,0x0
    80006448:	ec6080e7          	jalr	-314(ra) # 8000630a <holding>
    8000644c:	c115                	beqz	a0,80006470 <release+0x38>
  lk->cpu = 0;
    8000644e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80006452:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80006456:	0f50000f          	fence	iorw,ow
    8000645a:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000645e:	00000097          	auipc	ra,0x0
    80006462:	f7a080e7          	jalr	-134(ra) # 800063d8 <pop_off>
}
    80006466:	60e2                	ld	ra,24(sp)
    80006468:	6442                	ld	s0,16(sp)
    8000646a:	64a2                	ld	s1,8(sp)
    8000646c:	6105                	addi	sp,sp,32
    8000646e:	8082                	ret
    panic("release");
    80006470:	00002517          	auipc	a0,0x2
    80006474:	3e050513          	addi	a0,a0,992 # 80008850 <digits+0x48>
    80006478:	00000097          	auipc	ra,0x0
    8000647c:	9d4080e7          	jalr	-1580(ra) # 80005e4c <panic>
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
