
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
    80000016:	742050ef          	jal	ra,80005758 <start>

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
    80000034:	12078793          	addi	a5,a5,288 # 80022150 <end>
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
    8000005e:	0ea080e7          	jalr	234(ra) # 80006144 <acquire>
  r->next = kmem.freelist;
    80000062:	01893783          	ld	a5,24(s2)
    80000066:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000068:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006c:	854a                	mv	a0,s2
    8000006e:	00006097          	auipc	ra,0x6
    80000072:	18a080e7          	jalr	394(ra) # 800061f8 <release>
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
    8000008e:	b82080e7          	jalr	-1150(ra) # 80005c0c <panic>

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
    800000fa:	fbe080e7          	jalr	-66(ra) # 800060b4 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000fe:	45c5                	li	a1,17
    80000100:	05ee                	slli	a1,a1,0x1b
    80000102:	00022517          	auipc	a0,0x22
    80000106:	04e50513          	addi	a0,a0,78 # 80022150 <end>
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
    80000132:	016080e7          	jalr	22(ra) # 80006144 <acquire>
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
    8000014a:	0b2080e7          	jalr	178(ra) # 800061f8 <release>

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
    80000174:	088080e7          	jalr	136(ra) # 800061f8 <release>
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
    800001ee:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdceb1>
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
    80000348:	ae4080e7          	jalr	-1308(ra) # 80000e28 <cpuid>
    8000034c:	85aa                	mv	a1,a0
    8000034e:	00008517          	auipc	a0,0x8
    80000352:	cea50513          	addi	a0,a0,-790 # 80008038 <etext+0x38>
    80000356:	00006097          	auipc	ra,0x6
    8000035a:	900080e7          	jalr	-1792(ra) # 80005c56 <printf>
    kvminithart();    // turn on paging
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	0d8080e7          	jalr	216(ra) # 80000436 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000366:	00001097          	auipc	ra,0x1
    8000036a:	798080e7          	jalr	1944(ra) # 80001afe <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000036e:	00005097          	auipc	ra,0x5
    80000372:	da2080e7          	jalr	-606(ra) # 80005110 <plicinithart>
  }

  scheduler();        
    80000376:	00001097          	auipc	ra,0x1
    8000037a:	fe0080e7          	jalr	-32(ra) # 80001356 <scheduler>
    consoleinit();
    8000037e:	00005097          	auipc	ra,0x5
    80000382:	79e080e7          	jalr	1950(ra) # 80005b1c <consoleinit>
    printfinit();
    80000386:	00006097          	auipc	ra,0x6
    8000038a:	ab0080e7          	jalr	-1360(ra) # 80005e36 <printfinit>
    printf("\n");
    8000038e:	00008517          	auipc	a0,0x8
    80000392:	cba50513          	addi	a0,a0,-838 # 80008048 <etext+0x48>
    80000396:	00006097          	auipc	ra,0x6
    8000039a:	8c0080e7          	jalr	-1856(ra) # 80005c56 <printf>
    printf("xv6 kernel is booting\n");
    8000039e:	00008517          	auipc	a0,0x8
    800003a2:	c8250513          	addi	a0,a0,-894 # 80008020 <etext+0x20>
    800003a6:	00006097          	auipc	ra,0x6
    800003aa:	8b0080e7          	jalr	-1872(ra) # 80005c56 <printf>
    printf("\n");
    800003ae:	00008517          	auipc	a0,0x8
    800003b2:	c9a50513          	addi	a0,a0,-870 # 80008048 <etext+0x48>
    800003b6:	00006097          	auipc	ra,0x6
    800003ba:	8a0080e7          	jalr	-1888(ra) # 80005c56 <printf>
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
    800003e2:	6f8080e7          	jalr	1784(ra) # 80001ad6 <trapinit>
    trapinithart();  // install kernel trap vector
    800003e6:	00001097          	auipc	ra,0x1
    800003ea:	718080e7          	jalr	1816(ra) # 80001afe <trapinithart>
    plicinit();      // set up interrupt controller
    800003ee:	00005097          	auipc	ra,0x5
    800003f2:	d0c080e7          	jalr	-756(ra) # 800050fa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800003f6:	00005097          	auipc	ra,0x5
    800003fa:	d1a080e7          	jalr	-742(ra) # 80005110 <plicinithart>
    binit();         // buffer cache
    800003fe:	00002097          	auipc	ra,0x2
    80000402:	eb4080e7          	jalr	-332(ra) # 800022b2 <binit>
    iinit();         // inode table
    80000406:	00002097          	auipc	ra,0x2
    8000040a:	554080e7          	jalr	1364(ra) # 8000295a <iinit>
    fileinit();      // file table
    8000040e:	00003097          	auipc	ra,0x3
    80000412:	4fa080e7          	jalr	1274(ra) # 80003908 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000416:	00005097          	auipc	ra,0x5
    8000041a:	e02080e7          	jalr	-510(ra) # 80005218 <virtio_disk_init>
    userinit();      // first user process
    8000041e:	00001097          	auipc	ra,0x1
    80000422:	d1a080e7          	jalr	-742(ra) # 80001138 <userinit>
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
    8000048c:	00005097          	auipc	ra,0x5
    80000490:	780080e7          	jalr	1920(ra) # 80005c0c <panic>
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
    800004be:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdcea7>
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
    800005b6:	65a080e7          	jalr	1626(ra) # 80005c0c <panic>
      panic("mappages: remap");
    800005ba:	00008517          	auipc	a0,0x8
    800005be:	aae50513          	addi	a0,a0,-1362 # 80008068 <etext+0x68>
    800005c2:	00005097          	auipc	ra,0x5
    800005c6:	64a080e7          	jalr	1610(ra) # 80005c0c <panic>
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
    80000612:	5fe080e7          	jalr	1534(ra) # 80005c0c <panic>

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
    8000075e:	4b2080e7          	jalr	1202(ra) # 80005c0c <panic>
      panic("uvmunmap: walk");
    80000762:	00008517          	auipc	a0,0x8
    80000766:	93650513          	addi	a0,a0,-1738 # 80008098 <etext+0x98>
    8000076a:	00005097          	auipc	ra,0x5
    8000076e:	4a2080e7          	jalr	1186(ra) # 80005c0c <panic>
      panic("uvmunmap: not mapped");
    80000772:	00008517          	auipc	a0,0x8
    80000776:	93650513          	addi	a0,a0,-1738 # 800080a8 <etext+0xa8>
    8000077a:	00005097          	auipc	ra,0x5
    8000077e:	492080e7          	jalr	1170(ra) # 80005c0c <panic>
      panic("uvmunmap: not a leaf");
    80000782:	00008517          	auipc	a0,0x8
    80000786:	93e50513          	addi	a0,a0,-1730 # 800080c0 <etext+0xc0>
    8000078a:	00005097          	auipc	ra,0x5
    8000078e:	482080e7          	jalr	1154(ra) # 80005c0c <panic>
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
    8000086c:	3a4080e7          	jalr	932(ra) # 80005c0c <panic>

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
    800009b8:	258080e7          	jalr	600(ra) # 80005c0c <panic>
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
    80000a96:	17a080e7          	jalr	378(ra) # 80005c0c <panic>
      panic("uvmcopy: page not present");
    80000a9a:	00007517          	auipc	a0,0x7
    80000a9e:	68e50513          	addi	a0,a0,1678 # 80008128 <etext+0x128>
    80000aa2:	00005097          	auipc	ra,0x5
    80000aa6:	16a080e7          	jalr	362(ra) # 80005c0c <panic>
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
    80000b10:	100080e7          	jalr	256(ra) # 80005c0c <panic>

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
    80000cb4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdceb0>
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
    80000cf8:	03c48493          	addi	s1,s1,60 # 80008d30 <proc>
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
    80000d0e:	0000ea17          	auipc	s4,0xe
    80000d12:	e22a0a13          	addi	s4,s4,-478 # 8000eb30 <tickslock>
    char *pa = kalloc();
    80000d16:	fffff097          	auipc	ra,0xfffff
    80000d1a:	404080e7          	jalr	1028(ra) # 8000011a <kalloc>
    80000d1e:	862a                	mv	a2,a0
    if(pa == 0)
    80000d20:	c131                	beqz	a0,80000d64 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000d22:	416485b3          	sub	a1,s1,s6
    80000d26:	858d                	srai	a1,a1,0x3
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
    80000d48:	17848493          	addi	s1,s1,376
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
    80000d70:	ea0080e7          	jalr	-352(ra) # 80005c0c <panic>

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
    80000d94:	b7050513          	addi	a0,a0,-1168 # 80008900 <pid_lock>
    80000d98:	00005097          	auipc	ra,0x5
    80000d9c:	31c080e7          	jalr	796(ra) # 800060b4 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000da0:	00007597          	auipc	a1,0x7
    80000da4:	3c858593          	addi	a1,a1,968 # 80008168 <etext+0x168>
    80000da8:	00008517          	auipc	a0,0x8
    80000dac:	b7050513          	addi	a0,a0,-1168 # 80008918 <wait_lock>
    80000db0:	00005097          	auipc	ra,0x5
    80000db4:	304080e7          	jalr	772(ra) # 800060b4 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000db8:	00008497          	auipc	s1,0x8
    80000dbc:	f7848493          	addi	s1,s1,-136 # 80008d30 <proc>
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
    80000dda:	0000e997          	auipc	s3,0xe
    80000dde:	d5698993          	addi	s3,s3,-682 # 8000eb30 <tickslock>
      initlock(&p->lock, "proc");
    80000de2:	85da                	mv	a1,s6
    80000de4:	8526                	mv	a0,s1
    80000de6:	00005097          	auipc	ra,0x5
    80000dea:	2ce080e7          	jalr	718(ra) # 800060b4 <initlock>
      p->state = UNUSED;
    80000dee:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80000df2:	415487b3          	sub	a5,s1,s5
    80000df6:	878d                	srai	a5,a5,0x3
    80000df8:	000a3703          	ld	a4,0(s4)
    80000dfc:	02e787b3          	mul	a5,a5,a4
    80000e00:	2785                	addiw	a5,a5,1
    80000e02:	00d7979b          	slliw	a5,a5,0xd
    80000e06:	40f907b3          	sub	a5,s2,a5
    80000e0a:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e0c:	17848493          	addi	s1,s1,376
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
    80000e48:	aec50513          	addi	a0,a0,-1300 # 80008930 <cpus>
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
    80000e62:	29a080e7          	jalr	666(ra) # 800060f8 <push_off>
    80000e66:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80000e68:	2781                	sext.w	a5,a5
    80000e6a:	079e                	slli	a5,a5,0x7
    80000e6c:	00008717          	auipc	a4,0x8
    80000e70:	a9470713          	addi	a4,a4,-1388 # 80008900 <pid_lock>
    80000e74:	97ba                	add	a5,a5,a4
    80000e76:	7b84                	ld	s1,48(a5)
  pop_off();
    80000e78:	00005097          	auipc	ra,0x5
    80000e7c:	320080e7          	jalr	800(ra) # 80006198 <pop_off>
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
    80000ea0:	35c080e7          	jalr	860(ra) # 800061f8 <release>

  if (first) {
    80000ea4:	00008797          	auipc	a5,0x8
    80000ea8:	99c7a783          	lw	a5,-1636(a5) # 80008840 <first.1>
    80000eac:	eb89                	bnez	a5,80000ebe <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80000eae:	00001097          	auipc	ra,0x1
    80000eb2:	c68080e7          	jalr	-920(ra) # 80001b16 <usertrapret>
}
    80000eb6:	60a2                	ld	ra,8(sp)
    80000eb8:	6402                	ld	s0,0(sp)
    80000eba:	0141                	addi	sp,sp,16
    80000ebc:	8082                	ret
    first = 0;
    80000ebe:	00008797          	auipc	a5,0x8
    80000ec2:	9807a123          	sw	zero,-1662(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80000ec6:	4505                	li	a0,1
    80000ec8:	00002097          	auipc	ra,0x2
    80000ecc:	a12080e7          	jalr	-1518(ra) # 800028da <fsinit>
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
    80000ee2:	a2290913          	addi	s2,s2,-1502 # 80008900 <pid_lock>
    80000ee6:	854a                	mv	a0,s2
    80000ee8:	00005097          	auipc	ra,0x5
    80000eec:	25c080e7          	jalr	604(ra) # 80006144 <acquire>
  pid = nextpid;
    80000ef0:	00008797          	auipc	a5,0x8
    80000ef4:	95478793          	addi	a5,a5,-1708 # 80008844 <nextpid>
    80000ef8:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000efa:	0014871b          	addiw	a4,s1,1
    80000efe:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000f00:	854a                	mv	a0,s2
    80000f02:	00005097          	auipc	ra,0x5
    80000f06:	2f6080e7          	jalr	758(ra) # 800061f8 <release>
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
    8000106e:	cc648493          	addi	s1,s1,-826 # 80008d30 <proc>
    80001072:	0000e917          	auipc	s2,0xe
    80001076:	abe90913          	addi	s2,s2,-1346 # 8000eb30 <tickslock>
    acquire(&p->lock);
    8000107a:	8526                	mv	a0,s1
    8000107c:	00005097          	auipc	ra,0x5
    80001080:	0c8080e7          	jalr	200(ra) # 80006144 <acquire>
    if(p->state == UNUSED) {
    80001084:	4c9c                	lw	a5,24(s1)
    80001086:	cf81                	beqz	a5,8000109e <allocproc+0x40>
      release(&p->lock);
    80001088:	8526                	mv	a0,s1
    8000108a:	00005097          	auipc	ra,0x5
    8000108e:	16e080e7          	jalr	366(ra) # 800061f8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001092:	17848493          	addi	s1,s1,376
    80001096:	ff2492e3          	bne	s1,s2,8000107a <allocproc+0x1c>
  return 0;
    8000109a:	4481                	li	s1,0
    8000109c:	a8b9                	j	800010fa <allocproc+0x9c>
  p->pid = allocpid();
    8000109e:	00000097          	auipc	ra,0x0
    800010a2:	e34080e7          	jalr	-460(ra) # 80000ed2 <allocpid>
    800010a6:	d888                	sw	a0,48(s1)
  p->state = USED;
    800010a8:	4785                	li	a5,1
    800010aa:	cc9c                	sw	a5,24(s1)
  p->alarm_ticks = 0;
    800010ac:	1604a423          	sw	zero,360(s1)
  p->alarm_handler = 0;
    800010b0:	1604b823          	sd	zero,368(s1)
  p->alarm_left = 0;
    800010b4:	1604a623          	sw	zero,364(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800010b8:	fffff097          	auipc	ra,0xfffff
    800010bc:	062080e7          	jalr	98(ra) # 8000011a <kalloc>
    800010c0:	892a                	mv	s2,a0
    800010c2:	eca8                	sd	a0,88(s1)
    800010c4:	c131                	beqz	a0,80001108 <allocproc+0xaa>
  p->pagetable = proc_pagetable(p);
    800010c6:	8526                	mv	a0,s1
    800010c8:	00000097          	auipc	ra,0x0
    800010cc:	e50080e7          	jalr	-432(ra) # 80000f18 <proc_pagetable>
    800010d0:	892a                	mv	s2,a0
    800010d2:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800010d4:	c531                	beqz	a0,80001120 <allocproc+0xc2>
  memset(&p->context, 0, sizeof(p->context));
    800010d6:	07000613          	li	a2,112
    800010da:	4581                	li	a1,0
    800010dc:	06048513          	addi	a0,s1,96
    800010e0:	fffff097          	auipc	ra,0xfffff
    800010e4:	09a080e7          	jalr	154(ra) # 8000017a <memset>
  p->context.ra = (uint64)forkret;
    800010e8:	00000797          	auipc	a5,0x0
    800010ec:	da478793          	addi	a5,a5,-604 # 80000e8c <forkret>
    800010f0:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800010f2:	60bc                	ld	a5,64(s1)
    800010f4:	6705                	lui	a4,0x1
    800010f6:	97ba                	add	a5,a5,a4
    800010f8:	f4bc                	sd	a5,104(s1)
}
    800010fa:	8526                	mv	a0,s1
    800010fc:	60e2                	ld	ra,24(sp)
    800010fe:	6442                	ld	s0,16(sp)
    80001100:	64a2                	ld	s1,8(sp)
    80001102:	6902                	ld	s2,0(sp)
    80001104:	6105                	addi	sp,sp,32
    80001106:	8082                	ret
    freeproc(p);
    80001108:	8526                	mv	a0,s1
    8000110a:	00000097          	auipc	ra,0x0
    8000110e:	efc080e7          	jalr	-260(ra) # 80001006 <freeproc>
    release(&p->lock);
    80001112:	8526                	mv	a0,s1
    80001114:	00005097          	auipc	ra,0x5
    80001118:	0e4080e7          	jalr	228(ra) # 800061f8 <release>
    return 0;
    8000111c:	84ca                	mv	s1,s2
    8000111e:	bff1                	j	800010fa <allocproc+0x9c>
    freeproc(p);
    80001120:	8526                	mv	a0,s1
    80001122:	00000097          	auipc	ra,0x0
    80001126:	ee4080e7          	jalr	-284(ra) # 80001006 <freeproc>
    release(&p->lock);
    8000112a:	8526                	mv	a0,s1
    8000112c:	00005097          	auipc	ra,0x5
    80001130:	0cc080e7          	jalr	204(ra) # 800061f8 <release>
    return 0;
    80001134:	84ca                	mv	s1,s2
    80001136:	b7d1                	j	800010fa <allocproc+0x9c>

0000000080001138 <userinit>:
{
    80001138:	1101                	addi	sp,sp,-32
    8000113a:	ec06                	sd	ra,24(sp)
    8000113c:	e822                	sd	s0,16(sp)
    8000113e:	e426                	sd	s1,8(sp)
    80001140:	1000                	addi	s0,sp,32
  p = allocproc();
    80001142:	00000097          	auipc	ra,0x0
    80001146:	f1c080e7          	jalr	-228(ra) # 8000105e <allocproc>
    8000114a:	84aa                	mv	s1,a0
  initproc = p;
    8000114c:	00007797          	auipc	a5,0x7
    80001150:	76a7ba23          	sd	a0,1908(a5) # 800088c0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001154:	03400613          	li	a2,52
    80001158:	00007597          	auipc	a1,0x7
    8000115c:	6f858593          	addi	a1,a1,1784 # 80008850 <initcode>
    80001160:	6928                	ld	a0,80(a0)
    80001162:	fffff097          	auipc	ra,0xfffff
    80001166:	69c080e7          	jalr	1692(ra) # 800007fe <uvmfirst>
  p->sz = PGSIZE;
    8000116a:	6785                	lui	a5,0x1
    8000116c:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000116e:	6cb8                	ld	a4,88(s1)
    80001170:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001174:	6cb8                	ld	a4,88(s1)
    80001176:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001178:	4641                	li	a2,16
    8000117a:	00007597          	auipc	a1,0x7
    8000117e:	00658593          	addi	a1,a1,6 # 80008180 <etext+0x180>
    80001182:	15848513          	addi	a0,s1,344
    80001186:	fffff097          	auipc	ra,0xfffff
    8000118a:	13e080e7          	jalr	318(ra) # 800002c4 <safestrcpy>
  p->cwd = namei("/");
    8000118e:	00007517          	auipc	a0,0x7
    80001192:	00250513          	addi	a0,a0,2 # 80008190 <etext+0x190>
    80001196:	00002097          	auipc	ra,0x2
    8000119a:	16e080e7          	jalr	366(ra) # 80003304 <namei>
    8000119e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800011a2:	478d                	li	a5,3
    800011a4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011a6:	8526                	mv	a0,s1
    800011a8:	00005097          	auipc	ra,0x5
    800011ac:	050080e7          	jalr	80(ra) # 800061f8 <release>
}
    800011b0:	60e2                	ld	ra,24(sp)
    800011b2:	6442                	ld	s0,16(sp)
    800011b4:	64a2                	ld	s1,8(sp)
    800011b6:	6105                	addi	sp,sp,32
    800011b8:	8082                	ret

00000000800011ba <growproc>:
{
    800011ba:	1101                	addi	sp,sp,-32
    800011bc:	ec06                	sd	ra,24(sp)
    800011be:	e822                	sd	s0,16(sp)
    800011c0:	e426                	sd	s1,8(sp)
    800011c2:	e04a                	sd	s2,0(sp)
    800011c4:	1000                	addi	s0,sp,32
    800011c6:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800011c8:	00000097          	auipc	ra,0x0
    800011cc:	c8c080e7          	jalr	-884(ra) # 80000e54 <myproc>
    800011d0:	84aa                	mv	s1,a0
  sz = p->sz;
    800011d2:	652c                	ld	a1,72(a0)
  if(n > 0){
    800011d4:	01204c63          	bgtz	s2,800011ec <growproc+0x32>
  } else if(n < 0){
    800011d8:	02094663          	bltz	s2,80001204 <growproc+0x4a>
  p->sz = sz;
    800011dc:	e4ac                	sd	a1,72(s1)
  return 0;
    800011de:	4501                	li	a0,0
}
    800011e0:	60e2                	ld	ra,24(sp)
    800011e2:	6442                	ld	s0,16(sp)
    800011e4:	64a2                	ld	s1,8(sp)
    800011e6:	6902                	ld	s2,0(sp)
    800011e8:	6105                	addi	sp,sp,32
    800011ea:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800011ec:	4691                	li	a3,4
    800011ee:	00b90633          	add	a2,s2,a1
    800011f2:	6928                	ld	a0,80(a0)
    800011f4:	fffff097          	auipc	ra,0xfffff
    800011f8:	6c4080e7          	jalr	1732(ra) # 800008b8 <uvmalloc>
    800011fc:	85aa                	mv	a1,a0
    800011fe:	fd79                	bnez	a0,800011dc <growproc+0x22>
      return -1;
    80001200:	557d                	li	a0,-1
    80001202:	bff9                	j	800011e0 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001204:	00b90633          	add	a2,s2,a1
    80001208:	6928                	ld	a0,80(a0)
    8000120a:	fffff097          	auipc	ra,0xfffff
    8000120e:	666080e7          	jalr	1638(ra) # 80000870 <uvmdealloc>
    80001212:	85aa                	mv	a1,a0
    80001214:	b7e1                	j	800011dc <growproc+0x22>

0000000080001216 <fork>:
{
    80001216:	7139                	addi	sp,sp,-64
    80001218:	fc06                	sd	ra,56(sp)
    8000121a:	f822                	sd	s0,48(sp)
    8000121c:	f426                	sd	s1,40(sp)
    8000121e:	f04a                	sd	s2,32(sp)
    80001220:	ec4e                	sd	s3,24(sp)
    80001222:	e852                	sd	s4,16(sp)
    80001224:	e456                	sd	s5,8(sp)
    80001226:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	c2c080e7          	jalr	-980(ra) # 80000e54 <myproc>
    80001230:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001232:	00000097          	auipc	ra,0x0
    80001236:	e2c080e7          	jalr	-468(ra) # 8000105e <allocproc>
    8000123a:	10050c63          	beqz	a0,80001352 <fork+0x13c>
    8000123e:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001240:	048ab603          	ld	a2,72(s5)
    80001244:	692c                	ld	a1,80(a0)
    80001246:	050ab503          	ld	a0,80(s5)
    8000124a:	fffff097          	auipc	ra,0xfffff
    8000124e:	7c6080e7          	jalr	1990(ra) # 80000a10 <uvmcopy>
    80001252:	04054863          	bltz	a0,800012a2 <fork+0x8c>
  np->sz = p->sz;
    80001256:	048ab783          	ld	a5,72(s5)
    8000125a:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    8000125e:	058ab683          	ld	a3,88(s5)
    80001262:	87b6                	mv	a5,a3
    80001264:	058a3703          	ld	a4,88(s4)
    80001268:	12068693          	addi	a3,a3,288
    8000126c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001270:	6788                	ld	a0,8(a5)
    80001272:	6b8c                	ld	a1,16(a5)
    80001274:	6f90                	ld	a2,24(a5)
    80001276:	01073023          	sd	a6,0(a4)
    8000127a:	e708                	sd	a0,8(a4)
    8000127c:	eb0c                	sd	a1,16(a4)
    8000127e:	ef10                	sd	a2,24(a4)
    80001280:	02078793          	addi	a5,a5,32
    80001284:	02070713          	addi	a4,a4,32
    80001288:	fed792e3          	bne	a5,a3,8000126c <fork+0x56>
  np->trapframe->a0 = 0;
    8000128c:	058a3783          	ld	a5,88(s4)
    80001290:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001294:	0d0a8493          	addi	s1,s5,208
    80001298:	0d0a0913          	addi	s2,s4,208
    8000129c:	150a8993          	addi	s3,s5,336
    800012a0:	a00d                	j	800012c2 <fork+0xac>
    freeproc(np);
    800012a2:	8552                	mv	a0,s4
    800012a4:	00000097          	auipc	ra,0x0
    800012a8:	d62080e7          	jalr	-670(ra) # 80001006 <freeproc>
    release(&np->lock);
    800012ac:	8552                	mv	a0,s4
    800012ae:	00005097          	auipc	ra,0x5
    800012b2:	f4a080e7          	jalr	-182(ra) # 800061f8 <release>
    return -1;
    800012b6:	597d                	li	s2,-1
    800012b8:	a059                	j	8000133e <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    800012ba:	04a1                	addi	s1,s1,8
    800012bc:	0921                	addi	s2,s2,8
    800012be:	01348b63          	beq	s1,s3,800012d4 <fork+0xbe>
    if(p->ofile[i])
    800012c2:	6088                	ld	a0,0(s1)
    800012c4:	d97d                	beqz	a0,800012ba <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    800012c6:	00002097          	auipc	ra,0x2
    800012ca:	6d4080e7          	jalr	1748(ra) # 8000399a <filedup>
    800012ce:	00a93023          	sd	a0,0(s2)
    800012d2:	b7e5                	j	800012ba <fork+0xa4>
  np->cwd = idup(p->cwd);
    800012d4:	150ab503          	ld	a0,336(s5)
    800012d8:	00002097          	auipc	ra,0x2
    800012dc:	842080e7          	jalr	-1982(ra) # 80002b1a <idup>
    800012e0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800012e4:	4641                	li	a2,16
    800012e6:	158a8593          	addi	a1,s5,344
    800012ea:	158a0513          	addi	a0,s4,344
    800012ee:	fffff097          	auipc	ra,0xfffff
    800012f2:	fd6080e7          	jalr	-42(ra) # 800002c4 <safestrcpy>
  pid = np->pid;
    800012f6:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800012fa:	8552                	mv	a0,s4
    800012fc:	00005097          	auipc	ra,0x5
    80001300:	efc080e7          	jalr	-260(ra) # 800061f8 <release>
  acquire(&wait_lock);
    80001304:	00007497          	auipc	s1,0x7
    80001308:	61448493          	addi	s1,s1,1556 # 80008918 <wait_lock>
    8000130c:	8526                	mv	a0,s1
    8000130e:	00005097          	auipc	ra,0x5
    80001312:	e36080e7          	jalr	-458(ra) # 80006144 <acquire>
  np->parent = p;
    80001316:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    8000131a:	8526                	mv	a0,s1
    8000131c:	00005097          	auipc	ra,0x5
    80001320:	edc080e7          	jalr	-292(ra) # 800061f8 <release>
  acquire(&np->lock);
    80001324:	8552                	mv	a0,s4
    80001326:	00005097          	auipc	ra,0x5
    8000132a:	e1e080e7          	jalr	-482(ra) # 80006144 <acquire>
  np->state = RUNNABLE;
    8000132e:	478d                	li	a5,3
    80001330:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001334:	8552                	mv	a0,s4
    80001336:	00005097          	auipc	ra,0x5
    8000133a:	ec2080e7          	jalr	-318(ra) # 800061f8 <release>
}
    8000133e:	854a                	mv	a0,s2
    80001340:	70e2                	ld	ra,56(sp)
    80001342:	7442                	ld	s0,48(sp)
    80001344:	74a2                	ld	s1,40(sp)
    80001346:	7902                	ld	s2,32(sp)
    80001348:	69e2                	ld	s3,24(sp)
    8000134a:	6a42                	ld	s4,16(sp)
    8000134c:	6aa2                	ld	s5,8(sp)
    8000134e:	6121                	addi	sp,sp,64
    80001350:	8082                	ret
    return -1;
    80001352:	597d                	li	s2,-1
    80001354:	b7ed                	j	8000133e <fork+0x128>

0000000080001356 <scheduler>:
{
    80001356:	7139                	addi	sp,sp,-64
    80001358:	fc06                	sd	ra,56(sp)
    8000135a:	f822                	sd	s0,48(sp)
    8000135c:	f426                	sd	s1,40(sp)
    8000135e:	f04a                	sd	s2,32(sp)
    80001360:	ec4e                	sd	s3,24(sp)
    80001362:	e852                	sd	s4,16(sp)
    80001364:	e456                	sd	s5,8(sp)
    80001366:	e05a                	sd	s6,0(sp)
    80001368:	0080                	addi	s0,sp,64
    8000136a:	8792                	mv	a5,tp
  int id = r_tp();
    8000136c:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000136e:	00779a93          	slli	s5,a5,0x7
    80001372:	00007717          	auipc	a4,0x7
    80001376:	58e70713          	addi	a4,a4,1422 # 80008900 <pid_lock>
    8000137a:	9756                	add	a4,a4,s5
    8000137c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001380:	00007717          	auipc	a4,0x7
    80001384:	5b870713          	addi	a4,a4,1464 # 80008938 <cpus+0x8>
    80001388:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    8000138a:	498d                	li	s3,3
        p->state = RUNNING;
    8000138c:	4b11                	li	s6,4
        c->proc = p;
    8000138e:	079e                	slli	a5,a5,0x7
    80001390:	00007a17          	auipc	s4,0x7
    80001394:	570a0a13          	addi	s4,s4,1392 # 80008900 <pid_lock>
    80001398:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000139a:	0000d917          	auipc	s2,0xd
    8000139e:	79690913          	addi	s2,s2,1942 # 8000eb30 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013a2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013a6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013aa:	10079073          	csrw	sstatus,a5
    800013ae:	00008497          	auipc	s1,0x8
    800013b2:	98248493          	addi	s1,s1,-1662 # 80008d30 <proc>
    800013b6:	a811                	j	800013ca <scheduler+0x74>
      release(&p->lock);
    800013b8:	8526                	mv	a0,s1
    800013ba:	00005097          	auipc	ra,0x5
    800013be:	e3e080e7          	jalr	-450(ra) # 800061f8 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800013c2:	17848493          	addi	s1,s1,376
    800013c6:	fd248ee3          	beq	s1,s2,800013a2 <scheduler+0x4c>
      acquire(&p->lock);
    800013ca:	8526                	mv	a0,s1
    800013cc:	00005097          	auipc	ra,0x5
    800013d0:	d78080e7          	jalr	-648(ra) # 80006144 <acquire>
      if(p->state == RUNNABLE) {
    800013d4:	4c9c                	lw	a5,24(s1)
    800013d6:	ff3791e3          	bne	a5,s3,800013b8 <scheduler+0x62>
        p->state = RUNNING;
    800013da:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800013de:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800013e2:	06048593          	addi	a1,s1,96
    800013e6:	8556                	mv	a0,s5
    800013e8:	00000097          	auipc	ra,0x0
    800013ec:	684080e7          	jalr	1668(ra) # 80001a6c <swtch>
        c->proc = 0;
    800013f0:	020a3823          	sd	zero,48(s4)
    800013f4:	b7d1                	j	800013b8 <scheduler+0x62>

00000000800013f6 <sched>:
{
    800013f6:	7179                	addi	sp,sp,-48
    800013f8:	f406                	sd	ra,40(sp)
    800013fa:	f022                	sd	s0,32(sp)
    800013fc:	ec26                	sd	s1,24(sp)
    800013fe:	e84a                	sd	s2,16(sp)
    80001400:	e44e                	sd	s3,8(sp)
    80001402:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001404:	00000097          	auipc	ra,0x0
    80001408:	a50080e7          	jalr	-1456(ra) # 80000e54 <myproc>
    8000140c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000140e:	00005097          	auipc	ra,0x5
    80001412:	cbc080e7          	jalr	-836(ra) # 800060ca <holding>
    80001416:	c93d                	beqz	a0,8000148c <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001418:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000141a:	2781                	sext.w	a5,a5
    8000141c:	079e                	slli	a5,a5,0x7
    8000141e:	00007717          	auipc	a4,0x7
    80001422:	4e270713          	addi	a4,a4,1250 # 80008900 <pid_lock>
    80001426:	97ba                	add	a5,a5,a4
    80001428:	0a87a703          	lw	a4,168(a5)
    8000142c:	4785                	li	a5,1
    8000142e:	06f71763          	bne	a4,a5,8000149c <sched+0xa6>
  if(p->state == RUNNING)
    80001432:	4c98                	lw	a4,24(s1)
    80001434:	4791                	li	a5,4
    80001436:	06f70b63          	beq	a4,a5,800014ac <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000143a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000143e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001440:	efb5                	bnez	a5,800014bc <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001442:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001444:	00007917          	auipc	s2,0x7
    80001448:	4bc90913          	addi	s2,s2,1212 # 80008900 <pid_lock>
    8000144c:	2781                	sext.w	a5,a5
    8000144e:	079e                	slli	a5,a5,0x7
    80001450:	97ca                	add	a5,a5,s2
    80001452:	0ac7a983          	lw	s3,172(a5)
    80001456:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001458:	2781                	sext.w	a5,a5
    8000145a:	079e                	slli	a5,a5,0x7
    8000145c:	00007597          	auipc	a1,0x7
    80001460:	4dc58593          	addi	a1,a1,1244 # 80008938 <cpus+0x8>
    80001464:	95be                	add	a1,a1,a5
    80001466:	06048513          	addi	a0,s1,96
    8000146a:	00000097          	auipc	ra,0x0
    8000146e:	602080e7          	jalr	1538(ra) # 80001a6c <swtch>
    80001472:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001474:	2781                	sext.w	a5,a5
    80001476:	079e                	slli	a5,a5,0x7
    80001478:	993e                	add	s2,s2,a5
    8000147a:	0b392623          	sw	s3,172(s2)
}
    8000147e:	70a2                	ld	ra,40(sp)
    80001480:	7402                	ld	s0,32(sp)
    80001482:	64e2                	ld	s1,24(sp)
    80001484:	6942                	ld	s2,16(sp)
    80001486:	69a2                	ld	s3,8(sp)
    80001488:	6145                	addi	sp,sp,48
    8000148a:	8082                	ret
    panic("sched p->lock");
    8000148c:	00007517          	auipc	a0,0x7
    80001490:	d0c50513          	addi	a0,a0,-756 # 80008198 <etext+0x198>
    80001494:	00004097          	auipc	ra,0x4
    80001498:	778080e7          	jalr	1912(ra) # 80005c0c <panic>
    panic("sched locks");
    8000149c:	00007517          	auipc	a0,0x7
    800014a0:	d0c50513          	addi	a0,a0,-756 # 800081a8 <etext+0x1a8>
    800014a4:	00004097          	auipc	ra,0x4
    800014a8:	768080e7          	jalr	1896(ra) # 80005c0c <panic>
    panic("sched running");
    800014ac:	00007517          	auipc	a0,0x7
    800014b0:	d0c50513          	addi	a0,a0,-756 # 800081b8 <etext+0x1b8>
    800014b4:	00004097          	auipc	ra,0x4
    800014b8:	758080e7          	jalr	1880(ra) # 80005c0c <panic>
    panic("sched interruptible");
    800014bc:	00007517          	auipc	a0,0x7
    800014c0:	d0c50513          	addi	a0,a0,-756 # 800081c8 <etext+0x1c8>
    800014c4:	00004097          	auipc	ra,0x4
    800014c8:	748080e7          	jalr	1864(ra) # 80005c0c <panic>

00000000800014cc <yield>:
{
    800014cc:	1101                	addi	sp,sp,-32
    800014ce:	ec06                	sd	ra,24(sp)
    800014d0:	e822                	sd	s0,16(sp)
    800014d2:	e426                	sd	s1,8(sp)
    800014d4:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800014d6:	00000097          	auipc	ra,0x0
    800014da:	97e080e7          	jalr	-1666(ra) # 80000e54 <myproc>
    800014de:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800014e0:	00005097          	auipc	ra,0x5
    800014e4:	c64080e7          	jalr	-924(ra) # 80006144 <acquire>
  p->state = RUNNABLE;
    800014e8:	478d                	li	a5,3
    800014ea:	cc9c                	sw	a5,24(s1)
  sched();
    800014ec:	00000097          	auipc	ra,0x0
    800014f0:	f0a080e7          	jalr	-246(ra) # 800013f6 <sched>
  release(&p->lock);
    800014f4:	8526                	mv	a0,s1
    800014f6:	00005097          	auipc	ra,0x5
    800014fa:	d02080e7          	jalr	-766(ra) # 800061f8 <release>
}
    800014fe:	60e2                	ld	ra,24(sp)
    80001500:	6442                	ld	s0,16(sp)
    80001502:	64a2                	ld	s1,8(sp)
    80001504:	6105                	addi	sp,sp,32
    80001506:	8082                	ret

0000000080001508 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001508:	7179                	addi	sp,sp,-48
    8000150a:	f406                	sd	ra,40(sp)
    8000150c:	f022                	sd	s0,32(sp)
    8000150e:	ec26                	sd	s1,24(sp)
    80001510:	e84a                	sd	s2,16(sp)
    80001512:	e44e                	sd	s3,8(sp)
    80001514:	1800                	addi	s0,sp,48
    80001516:	89aa                	mv	s3,a0
    80001518:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000151a:	00000097          	auipc	ra,0x0
    8000151e:	93a080e7          	jalr	-1734(ra) # 80000e54 <myproc>
    80001522:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001524:	00005097          	auipc	ra,0x5
    80001528:	c20080e7          	jalr	-992(ra) # 80006144 <acquire>
  release(lk);
    8000152c:	854a                	mv	a0,s2
    8000152e:	00005097          	auipc	ra,0x5
    80001532:	cca080e7          	jalr	-822(ra) # 800061f8 <release>

  // Go to sleep.
  p->chan = chan;
    80001536:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000153a:	4789                	li	a5,2
    8000153c:	cc9c                	sw	a5,24(s1)

  sched();
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	eb8080e7          	jalr	-328(ra) # 800013f6 <sched>

  // Tidy up.
  p->chan = 0;
    80001546:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000154a:	8526                	mv	a0,s1
    8000154c:	00005097          	auipc	ra,0x5
    80001550:	cac080e7          	jalr	-852(ra) # 800061f8 <release>
  acquire(lk);
    80001554:	854a                	mv	a0,s2
    80001556:	00005097          	auipc	ra,0x5
    8000155a:	bee080e7          	jalr	-1042(ra) # 80006144 <acquire>
}
    8000155e:	70a2                	ld	ra,40(sp)
    80001560:	7402                	ld	s0,32(sp)
    80001562:	64e2                	ld	s1,24(sp)
    80001564:	6942                	ld	s2,16(sp)
    80001566:	69a2                	ld	s3,8(sp)
    80001568:	6145                	addi	sp,sp,48
    8000156a:	8082                	ret

000000008000156c <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000156c:	7139                	addi	sp,sp,-64
    8000156e:	fc06                	sd	ra,56(sp)
    80001570:	f822                	sd	s0,48(sp)
    80001572:	f426                	sd	s1,40(sp)
    80001574:	f04a                	sd	s2,32(sp)
    80001576:	ec4e                	sd	s3,24(sp)
    80001578:	e852                	sd	s4,16(sp)
    8000157a:	e456                	sd	s5,8(sp)
    8000157c:	0080                	addi	s0,sp,64
    8000157e:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001580:	00007497          	auipc	s1,0x7
    80001584:	7b048493          	addi	s1,s1,1968 # 80008d30 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001588:	4989                	li	s3,2
        p->state = RUNNABLE;
    8000158a:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000158c:	0000d917          	auipc	s2,0xd
    80001590:	5a490913          	addi	s2,s2,1444 # 8000eb30 <tickslock>
    80001594:	a811                	j	800015a8 <wakeup+0x3c>
      }
      release(&p->lock);
    80001596:	8526                	mv	a0,s1
    80001598:	00005097          	auipc	ra,0x5
    8000159c:	c60080e7          	jalr	-928(ra) # 800061f8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800015a0:	17848493          	addi	s1,s1,376
    800015a4:	03248663          	beq	s1,s2,800015d0 <wakeup+0x64>
    if(p != myproc()){
    800015a8:	00000097          	auipc	ra,0x0
    800015ac:	8ac080e7          	jalr	-1876(ra) # 80000e54 <myproc>
    800015b0:	fea488e3          	beq	s1,a0,800015a0 <wakeup+0x34>
      acquire(&p->lock);
    800015b4:	8526                	mv	a0,s1
    800015b6:	00005097          	auipc	ra,0x5
    800015ba:	b8e080e7          	jalr	-1138(ra) # 80006144 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800015be:	4c9c                	lw	a5,24(s1)
    800015c0:	fd379be3          	bne	a5,s3,80001596 <wakeup+0x2a>
    800015c4:	709c                	ld	a5,32(s1)
    800015c6:	fd4798e3          	bne	a5,s4,80001596 <wakeup+0x2a>
        p->state = RUNNABLE;
    800015ca:	0154ac23          	sw	s5,24(s1)
    800015ce:	b7e1                	j	80001596 <wakeup+0x2a>
    }
  }
}
    800015d0:	70e2                	ld	ra,56(sp)
    800015d2:	7442                	ld	s0,48(sp)
    800015d4:	74a2                	ld	s1,40(sp)
    800015d6:	7902                	ld	s2,32(sp)
    800015d8:	69e2                	ld	s3,24(sp)
    800015da:	6a42                	ld	s4,16(sp)
    800015dc:	6aa2                	ld	s5,8(sp)
    800015de:	6121                	addi	sp,sp,64
    800015e0:	8082                	ret

00000000800015e2 <reparent>:
{
    800015e2:	7179                	addi	sp,sp,-48
    800015e4:	f406                	sd	ra,40(sp)
    800015e6:	f022                	sd	s0,32(sp)
    800015e8:	ec26                	sd	s1,24(sp)
    800015ea:	e84a                	sd	s2,16(sp)
    800015ec:	e44e                	sd	s3,8(sp)
    800015ee:	e052                	sd	s4,0(sp)
    800015f0:	1800                	addi	s0,sp,48
    800015f2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800015f4:	00007497          	auipc	s1,0x7
    800015f8:	73c48493          	addi	s1,s1,1852 # 80008d30 <proc>
      pp->parent = initproc;
    800015fc:	00007a17          	auipc	s4,0x7
    80001600:	2c4a0a13          	addi	s4,s4,708 # 800088c0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001604:	0000d997          	auipc	s3,0xd
    80001608:	52c98993          	addi	s3,s3,1324 # 8000eb30 <tickslock>
    8000160c:	a029                	j	80001616 <reparent+0x34>
    8000160e:	17848493          	addi	s1,s1,376
    80001612:	01348d63          	beq	s1,s3,8000162c <reparent+0x4a>
    if(pp->parent == p){
    80001616:	7c9c                	ld	a5,56(s1)
    80001618:	ff279be3          	bne	a5,s2,8000160e <reparent+0x2c>
      pp->parent = initproc;
    8000161c:	000a3503          	ld	a0,0(s4)
    80001620:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001622:	00000097          	auipc	ra,0x0
    80001626:	f4a080e7          	jalr	-182(ra) # 8000156c <wakeup>
    8000162a:	b7d5                	j	8000160e <reparent+0x2c>
}
    8000162c:	70a2                	ld	ra,40(sp)
    8000162e:	7402                	ld	s0,32(sp)
    80001630:	64e2                	ld	s1,24(sp)
    80001632:	6942                	ld	s2,16(sp)
    80001634:	69a2                	ld	s3,8(sp)
    80001636:	6a02                	ld	s4,0(sp)
    80001638:	6145                	addi	sp,sp,48
    8000163a:	8082                	ret

000000008000163c <exit>:
{
    8000163c:	7179                	addi	sp,sp,-48
    8000163e:	f406                	sd	ra,40(sp)
    80001640:	f022                	sd	s0,32(sp)
    80001642:	ec26                	sd	s1,24(sp)
    80001644:	e84a                	sd	s2,16(sp)
    80001646:	e44e                	sd	s3,8(sp)
    80001648:	e052                	sd	s4,0(sp)
    8000164a:	1800                	addi	s0,sp,48
    8000164c:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000164e:	00000097          	auipc	ra,0x0
    80001652:	806080e7          	jalr	-2042(ra) # 80000e54 <myproc>
    80001656:	89aa                	mv	s3,a0
  if(p == initproc)
    80001658:	00007797          	auipc	a5,0x7
    8000165c:	2687b783          	ld	a5,616(a5) # 800088c0 <initproc>
    80001660:	0d050493          	addi	s1,a0,208
    80001664:	15050913          	addi	s2,a0,336
    80001668:	02a79363          	bne	a5,a0,8000168e <exit+0x52>
    panic("init exiting");
    8000166c:	00007517          	auipc	a0,0x7
    80001670:	b7450513          	addi	a0,a0,-1164 # 800081e0 <etext+0x1e0>
    80001674:	00004097          	auipc	ra,0x4
    80001678:	598080e7          	jalr	1432(ra) # 80005c0c <panic>
      fileclose(f);
    8000167c:	00002097          	auipc	ra,0x2
    80001680:	370080e7          	jalr	880(ra) # 800039ec <fileclose>
      p->ofile[fd] = 0;
    80001684:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001688:	04a1                	addi	s1,s1,8
    8000168a:	01248563          	beq	s1,s2,80001694 <exit+0x58>
    if(p->ofile[fd]){
    8000168e:	6088                	ld	a0,0(s1)
    80001690:	f575                	bnez	a0,8000167c <exit+0x40>
    80001692:	bfdd                	j	80001688 <exit+0x4c>
  begin_op();
    80001694:	00002097          	auipc	ra,0x2
    80001698:	e90080e7          	jalr	-368(ra) # 80003524 <begin_op>
  iput(p->cwd);
    8000169c:	1509b503          	ld	a0,336(s3)
    800016a0:	00001097          	auipc	ra,0x1
    800016a4:	672080e7          	jalr	1650(ra) # 80002d12 <iput>
  end_op();
    800016a8:	00002097          	auipc	ra,0x2
    800016ac:	efa080e7          	jalr	-262(ra) # 800035a2 <end_op>
  p->cwd = 0;
    800016b0:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800016b4:	00007497          	auipc	s1,0x7
    800016b8:	26448493          	addi	s1,s1,612 # 80008918 <wait_lock>
    800016bc:	8526                	mv	a0,s1
    800016be:	00005097          	auipc	ra,0x5
    800016c2:	a86080e7          	jalr	-1402(ra) # 80006144 <acquire>
  reparent(p);
    800016c6:	854e                	mv	a0,s3
    800016c8:	00000097          	auipc	ra,0x0
    800016cc:	f1a080e7          	jalr	-230(ra) # 800015e2 <reparent>
  wakeup(p->parent);
    800016d0:	0389b503          	ld	a0,56(s3)
    800016d4:	00000097          	auipc	ra,0x0
    800016d8:	e98080e7          	jalr	-360(ra) # 8000156c <wakeup>
  acquire(&p->lock);
    800016dc:	854e                	mv	a0,s3
    800016de:	00005097          	auipc	ra,0x5
    800016e2:	a66080e7          	jalr	-1434(ra) # 80006144 <acquire>
  p->xstate = status;
    800016e6:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800016ea:	4795                	li	a5,5
    800016ec:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800016f0:	8526                	mv	a0,s1
    800016f2:	00005097          	auipc	ra,0x5
    800016f6:	b06080e7          	jalr	-1274(ra) # 800061f8 <release>
  sched();
    800016fa:	00000097          	auipc	ra,0x0
    800016fe:	cfc080e7          	jalr	-772(ra) # 800013f6 <sched>
  panic("zombie exit");
    80001702:	00007517          	auipc	a0,0x7
    80001706:	aee50513          	addi	a0,a0,-1298 # 800081f0 <etext+0x1f0>
    8000170a:	00004097          	auipc	ra,0x4
    8000170e:	502080e7          	jalr	1282(ra) # 80005c0c <panic>

0000000080001712 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001712:	7179                	addi	sp,sp,-48
    80001714:	f406                	sd	ra,40(sp)
    80001716:	f022                	sd	s0,32(sp)
    80001718:	ec26                	sd	s1,24(sp)
    8000171a:	e84a                	sd	s2,16(sp)
    8000171c:	e44e                	sd	s3,8(sp)
    8000171e:	1800                	addi	s0,sp,48
    80001720:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001722:	00007497          	auipc	s1,0x7
    80001726:	60e48493          	addi	s1,s1,1550 # 80008d30 <proc>
    8000172a:	0000d997          	auipc	s3,0xd
    8000172e:	40698993          	addi	s3,s3,1030 # 8000eb30 <tickslock>
    acquire(&p->lock);
    80001732:	8526                	mv	a0,s1
    80001734:	00005097          	auipc	ra,0x5
    80001738:	a10080e7          	jalr	-1520(ra) # 80006144 <acquire>
    if(p->pid == pid){
    8000173c:	589c                	lw	a5,48(s1)
    8000173e:	01278d63          	beq	a5,s2,80001758 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001742:	8526                	mv	a0,s1
    80001744:	00005097          	auipc	ra,0x5
    80001748:	ab4080e7          	jalr	-1356(ra) # 800061f8 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000174c:	17848493          	addi	s1,s1,376
    80001750:	ff3491e3          	bne	s1,s3,80001732 <kill+0x20>
  }
  return -1;
    80001754:	557d                	li	a0,-1
    80001756:	a829                	j	80001770 <kill+0x5e>
      p->killed = 1;
    80001758:	4785                	li	a5,1
    8000175a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000175c:	4c98                	lw	a4,24(s1)
    8000175e:	4789                	li	a5,2
    80001760:	00f70f63          	beq	a4,a5,8000177e <kill+0x6c>
      release(&p->lock);
    80001764:	8526                	mv	a0,s1
    80001766:	00005097          	auipc	ra,0x5
    8000176a:	a92080e7          	jalr	-1390(ra) # 800061f8 <release>
      return 0;
    8000176e:	4501                	li	a0,0
}
    80001770:	70a2                	ld	ra,40(sp)
    80001772:	7402                	ld	s0,32(sp)
    80001774:	64e2                	ld	s1,24(sp)
    80001776:	6942                	ld	s2,16(sp)
    80001778:	69a2                	ld	s3,8(sp)
    8000177a:	6145                	addi	sp,sp,48
    8000177c:	8082                	ret
        p->state = RUNNABLE;
    8000177e:	478d                	li	a5,3
    80001780:	cc9c                	sw	a5,24(s1)
    80001782:	b7cd                	j	80001764 <kill+0x52>

0000000080001784 <setkilled>:

void
setkilled(struct proc *p)
{
    80001784:	1101                	addi	sp,sp,-32
    80001786:	ec06                	sd	ra,24(sp)
    80001788:	e822                	sd	s0,16(sp)
    8000178a:	e426                	sd	s1,8(sp)
    8000178c:	1000                	addi	s0,sp,32
    8000178e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001790:	00005097          	auipc	ra,0x5
    80001794:	9b4080e7          	jalr	-1612(ra) # 80006144 <acquire>
  p->killed = 1;
    80001798:	4785                	li	a5,1
    8000179a:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000179c:	8526                	mv	a0,s1
    8000179e:	00005097          	auipc	ra,0x5
    800017a2:	a5a080e7          	jalr	-1446(ra) # 800061f8 <release>
}
    800017a6:	60e2                	ld	ra,24(sp)
    800017a8:	6442                	ld	s0,16(sp)
    800017aa:	64a2                	ld	s1,8(sp)
    800017ac:	6105                	addi	sp,sp,32
    800017ae:	8082                	ret

00000000800017b0 <killed>:

int
killed(struct proc *p)
{
    800017b0:	1101                	addi	sp,sp,-32
    800017b2:	ec06                	sd	ra,24(sp)
    800017b4:	e822                	sd	s0,16(sp)
    800017b6:	e426                	sd	s1,8(sp)
    800017b8:	e04a                	sd	s2,0(sp)
    800017ba:	1000                	addi	s0,sp,32
    800017bc:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800017be:	00005097          	auipc	ra,0x5
    800017c2:	986080e7          	jalr	-1658(ra) # 80006144 <acquire>
  k = p->killed;
    800017c6:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800017ca:	8526                	mv	a0,s1
    800017cc:	00005097          	auipc	ra,0x5
    800017d0:	a2c080e7          	jalr	-1492(ra) # 800061f8 <release>
  return k;
}
    800017d4:	854a                	mv	a0,s2
    800017d6:	60e2                	ld	ra,24(sp)
    800017d8:	6442                	ld	s0,16(sp)
    800017da:	64a2                	ld	s1,8(sp)
    800017dc:	6902                	ld	s2,0(sp)
    800017de:	6105                	addi	sp,sp,32
    800017e0:	8082                	ret

00000000800017e2 <wait>:
{
    800017e2:	715d                	addi	sp,sp,-80
    800017e4:	e486                	sd	ra,72(sp)
    800017e6:	e0a2                	sd	s0,64(sp)
    800017e8:	fc26                	sd	s1,56(sp)
    800017ea:	f84a                	sd	s2,48(sp)
    800017ec:	f44e                	sd	s3,40(sp)
    800017ee:	f052                	sd	s4,32(sp)
    800017f0:	ec56                	sd	s5,24(sp)
    800017f2:	e85a                	sd	s6,16(sp)
    800017f4:	e45e                	sd	s7,8(sp)
    800017f6:	e062                	sd	s8,0(sp)
    800017f8:	0880                	addi	s0,sp,80
    800017fa:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800017fc:	fffff097          	auipc	ra,0xfffff
    80001800:	658080e7          	jalr	1624(ra) # 80000e54 <myproc>
    80001804:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001806:	00007517          	auipc	a0,0x7
    8000180a:	11250513          	addi	a0,a0,274 # 80008918 <wait_lock>
    8000180e:	00005097          	auipc	ra,0x5
    80001812:	936080e7          	jalr	-1738(ra) # 80006144 <acquire>
    havekids = 0;
    80001816:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001818:	4a15                	li	s4,5
        havekids = 1;
    8000181a:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000181c:	0000d997          	auipc	s3,0xd
    80001820:	31498993          	addi	s3,s3,788 # 8000eb30 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001824:	00007c17          	auipc	s8,0x7
    80001828:	0f4c0c13          	addi	s8,s8,244 # 80008918 <wait_lock>
    havekids = 0;
    8000182c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000182e:	00007497          	auipc	s1,0x7
    80001832:	50248493          	addi	s1,s1,1282 # 80008d30 <proc>
    80001836:	a0bd                	j	800018a4 <wait+0xc2>
          pid = pp->pid;
    80001838:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000183c:	000b0e63          	beqz	s6,80001858 <wait+0x76>
    80001840:	4691                	li	a3,4
    80001842:	02c48613          	addi	a2,s1,44
    80001846:	85da                	mv	a1,s6
    80001848:	05093503          	ld	a0,80(s2)
    8000184c:	fffff097          	auipc	ra,0xfffff
    80001850:	2c8080e7          	jalr	712(ra) # 80000b14 <copyout>
    80001854:	02054563          	bltz	a0,8000187e <wait+0x9c>
          freeproc(pp);
    80001858:	8526                	mv	a0,s1
    8000185a:	fffff097          	auipc	ra,0xfffff
    8000185e:	7ac080e7          	jalr	1964(ra) # 80001006 <freeproc>
          release(&pp->lock);
    80001862:	8526                	mv	a0,s1
    80001864:	00005097          	auipc	ra,0x5
    80001868:	994080e7          	jalr	-1644(ra) # 800061f8 <release>
          release(&wait_lock);
    8000186c:	00007517          	auipc	a0,0x7
    80001870:	0ac50513          	addi	a0,a0,172 # 80008918 <wait_lock>
    80001874:	00005097          	auipc	ra,0x5
    80001878:	984080e7          	jalr	-1660(ra) # 800061f8 <release>
          return pid;
    8000187c:	a0b5                	j	800018e8 <wait+0x106>
            release(&pp->lock);
    8000187e:	8526                	mv	a0,s1
    80001880:	00005097          	auipc	ra,0x5
    80001884:	978080e7          	jalr	-1672(ra) # 800061f8 <release>
            release(&wait_lock);
    80001888:	00007517          	auipc	a0,0x7
    8000188c:	09050513          	addi	a0,a0,144 # 80008918 <wait_lock>
    80001890:	00005097          	auipc	ra,0x5
    80001894:	968080e7          	jalr	-1688(ra) # 800061f8 <release>
            return -1;
    80001898:	59fd                	li	s3,-1
    8000189a:	a0b9                	j	800018e8 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000189c:	17848493          	addi	s1,s1,376
    800018a0:	03348463          	beq	s1,s3,800018c8 <wait+0xe6>
      if(pp->parent == p){
    800018a4:	7c9c                	ld	a5,56(s1)
    800018a6:	ff279be3          	bne	a5,s2,8000189c <wait+0xba>
        acquire(&pp->lock);
    800018aa:	8526                	mv	a0,s1
    800018ac:	00005097          	auipc	ra,0x5
    800018b0:	898080e7          	jalr	-1896(ra) # 80006144 <acquire>
        if(pp->state == ZOMBIE){
    800018b4:	4c9c                	lw	a5,24(s1)
    800018b6:	f94781e3          	beq	a5,s4,80001838 <wait+0x56>
        release(&pp->lock);
    800018ba:	8526                	mv	a0,s1
    800018bc:	00005097          	auipc	ra,0x5
    800018c0:	93c080e7          	jalr	-1732(ra) # 800061f8 <release>
        havekids = 1;
    800018c4:	8756                	mv	a4,s5
    800018c6:	bfd9                	j	8000189c <wait+0xba>
    if(!havekids || killed(p)){
    800018c8:	c719                	beqz	a4,800018d6 <wait+0xf4>
    800018ca:	854a                	mv	a0,s2
    800018cc:	00000097          	auipc	ra,0x0
    800018d0:	ee4080e7          	jalr	-284(ra) # 800017b0 <killed>
    800018d4:	c51d                	beqz	a0,80001902 <wait+0x120>
      release(&wait_lock);
    800018d6:	00007517          	auipc	a0,0x7
    800018da:	04250513          	addi	a0,a0,66 # 80008918 <wait_lock>
    800018de:	00005097          	auipc	ra,0x5
    800018e2:	91a080e7          	jalr	-1766(ra) # 800061f8 <release>
      return -1;
    800018e6:	59fd                	li	s3,-1
}
    800018e8:	854e                	mv	a0,s3
    800018ea:	60a6                	ld	ra,72(sp)
    800018ec:	6406                	ld	s0,64(sp)
    800018ee:	74e2                	ld	s1,56(sp)
    800018f0:	7942                	ld	s2,48(sp)
    800018f2:	79a2                	ld	s3,40(sp)
    800018f4:	7a02                	ld	s4,32(sp)
    800018f6:	6ae2                	ld	s5,24(sp)
    800018f8:	6b42                	ld	s6,16(sp)
    800018fa:	6ba2                	ld	s7,8(sp)
    800018fc:	6c02                	ld	s8,0(sp)
    800018fe:	6161                	addi	sp,sp,80
    80001900:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001902:	85e2                	mv	a1,s8
    80001904:	854a                	mv	a0,s2
    80001906:	00000097          	auipc	ra,0x0
    8000190a:	c02080e7          	jalr	-1022(ra) # 80001508 <sleep>
    havekids = 0;
    8000190e:	bf39                	j	8000182c <wait+0x4a>

0000000080001910 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001910:	7179                	addi	sp,sp,-48
    80001912:	f406                	sd	ra,40(sp)
    80001914:	f022                	sd	s0,32(sp)
    80001916:	ec26                	sd	s1,24(sp)
    80001918:	e84a                	sd	s2,16(sp)
    8000191a:	e44e                	sd	s3,8(sp)
    8000191c:	e052                	sd	s4,0(sp)
    8000191e:	1800                	addi	s0,sp,48
    80001920:	84aa                	mv	s1,a0
    80001922:	892e                	mv	s2,a1
    80001924:	89b2                	mv	s3,a2
    80001926:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001928:	fffff097          	auipc	ra,0xfffff
    8000192c:	52c080e7          	jalr	1324(ra) # 80000e54 <myproc>
  if(user_dst){
    80001930:	c08d                	beqz	s1,80001952 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001932:	86d2                	mv	a3,s4
    80001934:	864e                	mv	a2,s3
    80001936:	85ca                	mv	a1,s2
    80001938:	6928                	ld	a0,80(a0)
    8000193a:	fffff097          	auipc	ra,0xfffff
    8000193e:	1da080e7          	jalr	474(ra) # 80000b14 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001942:	70a2                	ld	ra,40(sp)
    80001944:	7402                	ld	s0,32(sp)
    80001946:	64e2                	ld	s1,24(sp)
    80001948:	6942                	ld	s2,16(sp)
    8000194a:	69a2                	ld	s3,8(sp)
    8000194c:	6a02                	ld	s4,0(sp)
    8000194e:	6145                	addi	sp,sp,48
    80001950:	8082                	ret
    memmove((char *)dst, src, len);
    80001952:	000a061b          	sext.w	a2,s4
    80001956:	85ce                	mv	a1,s3
    80001958:	854a                	mv	a0,s2
    8000195a:	fffff097          	auipc	ra,0xfffff
    8000195e:	87c080e7          	jalr	-1924(ra) # 800001d6 <memmove>
    return 0;
    80001962:	8526                	mv	a0,s1
    80001964:	bff9                	j	80001942 <either_copyout+0x32>

0000000080001966 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001966:	7179                	addi	sp,sp,-48
    80001968:	f406                	sd	ra,40(sp)
    8000196a:	f022                	sd	s0,32(sp)
    8000196c:	ec26                	sd	s1,24(sp)
    8000196e:	e84a                	sd	s2,16(sp)
    80001970:	e44e                	sd	s3,8(sp)
    80001972:	e052                	sd	s4,0(sp)
    80001974:	1800                	addi	s0,sp,48
    80001976:	892a                	mv	s2,a0
    80001978:	84ae                	mv	s1,a1
    8000197a:	89b2                	mv	s3,a2
    8000197c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000197e:	fffff097          	auipc	ra,0xfffff
    80001982:	4d6080e7          	jalr	1238(ra) # 80000e54 <myproc>
  if(user_src){
    80001986:	c08d                	beqz	s1,800019a8 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001988:	86d2                	mv	a3,s4
    8000198a:	864e                	mv	a2,s3
    8000198c:	85ca                	mv	a1,s2
    8000198e:	6928                	ld	a0,80(a0)
    80001990:	fffff097          	auipc	ra,0xfffff
    80001994:	210080e7          	jalr	528(ra) # 80000ba0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001998:	70a2                	ld	ra,40(sp)
    8000199a:	7402                	ld	s0,32(sp)
    8000199c:	64e2                	ld	s1,24(sp)
    8000199e:	6942                	ld	s2,16(sp)
    800019a0:	69a2                	ld	s3,8(sp)
    800019a2:	6a02                	ld	s4,0(sp)
    800019a4:	6145                	addi	sp,sp,48
    800019a6:	8082                	ret
    memmove(dst, (char*)src, len);
    800019a8:	000a061b          	sext.w	a2,s4
    800019ac:	85ce                	mv	a1,s3
    800019ae:	854a                	mv	a0,s2
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	826080e7          	jalr	-2010(ra) # 800001d6 <memmove>
    return 0;
    800019b8:	8526                	mv	a0,s1
    800019ba:	bff9                	j	80001998 <either_copyin+0x32>

00000000800019bc <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800019bc:	715d                	addi	sp,sp,-80
    800019be:	e486                	sd	ra,72(sp)
    800019c0:	e0a2                	sd	s0,64(sp)
    800019c2:	fc26                	sd	s1,56(sp)
    800019c4:	f84a                	sd	s2,48(sp)
    800019c6:	f44e                	sd	s3,40(sp)
    800019c8:	f052                	sd	s4,32(sp)
    800019ca:	ec56                	sd	s5,24(sp)
    800019cc:	e85a                	sd	s6,16(sp)
    800019ce:	e45e                	sd	s7,8(sp)
    800019d0:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800019d2:	00006517          	auipc	a0,0x6
    800019d6:	67650513          	addi	a0,a0,1654 # 80008048 <etext+0x48>
    800019da:	00004097          	auipc	ra,0x4
    800019de:	27c080e7          	jalr	636(ra) # 80005c56 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800019e2:	00007497          	auipc	s1,0x7
    800019e6:	4a648493          	addi	s1,s1,1190 # 80008e88 <proc+0x158>
    800019ea:	0000d917          	auipc	s2,0xd
    800019ee:	29e90913          	addi	s2,s2,670 # 8000ec88 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800019f2:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800019f4:	00007997          	auipc	s3,0x7
    800019f8:	80c98993          	addi	s3,s3,-2036 # 80008200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    800019fc:	00007a97          	auipc	s5,0x7
    80001a00:	80ca8a93          	addi	s5,s5,-2036 # 80008208 <etext+0x208>
    printf("\n");
    80001a04:	00006a17          	auipc	s4,0x6
    80001a08:	644a0a13          	addi	s4,s4,1604 # 80008048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a0c:	00007b97          	auipc	s7,0x7
    80001a10:	83cb8b93          	addi	s7,s7,-1988 # 80008248 <states.0>
    80001a14:	a00d                	j	80001a36 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001a16:	ed86a583          	lw	a1,-296(a3)
    80001a1a:	8556                	mv	a0,s5
    80001a1c:	00004097          	auipc	ra,0x4
    80001a20:	23a080e7          	jalr	570(ra) # 80005c56 <printf>
    printf("\n");
    80001a24:	8552                	mv	a0,s4
    80001a26:	00004097          	auipc	ra,0x4
    80001a2a:	230080e7          	jalr	560(ra) # 80005c56 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a2e:	17848493          	addi	s1,s1,376
    80001a32:	03248263          	beq	s1,s2,80001a56 <procdump+0x9a>
    if(p->state == UNUSED)
    80001a36:	86a6                	mv	a3,s1
    80001a38:	ec04a783          	lw	a5,-320(s1)
    80001a3c:	dbed                	beqz	a5,80001a2e <procdump+0x72>
      state = "???";
    80001a3e:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a40:	fcfb6be3          	bltu	s6,a5,80001a16 <procdump+0x5a>
    80001a44:	02079713          	slli	a4,a5,0x20
    80001a48:	01d75793          	srli	a5,a4,0x1d
    80001a4c:	97de                	add	a5,a5,s7
    80001a4e:	6390                	ld	a2,0(a5)
    80001a50:	f279                	bnez	a2,80001a16 <procdump+0x5a>
      state = "???";
    80001a52:	864e                	mv	a2,s3
    80001a54:	b7c9                	j	80001a16 <procdump+0x5a>
  }
}
    80001a56:	60a6                	ld	ra,72(sp)
    80001a58:	6406                	ld	s0,64(sp)
    80001a5a:	74e2                	ld	s1,56(sp)
    80001a5c:	7942                	ld	s2,48(sp)
    80001a5e:	79a2                	ld	s3,40(sp)
    80001a60:	7a02                	ld	s4,32(sp)
    80001a62:	6ae2                	ld	s5,24(sp)
    80001a64:	6b42                	ld	s6,16(sp)
    80001a66:	6ba2                	ld	s7,8(sp)
    80001a68:	6161                	addi	sp,sp,80
    80001a6a:	8082                	ret

0000000080001a6c <swtch>:
    80001a6c:	00153023          	sd	ra,0(a0)
    80001a70:	00253423          	sd	sp,8(a0)
    80001a74:	e900                	sd	s0,16(a0)
    80001a76:	ed04                	sd	s1,24(a0)
    80001a78:	03253023          	sd	s2,32(a0)
    80001a7c:	03353423          	sd	s3,40(a0)
    80001a80:	03453823          	sd	s4,48(a0)
    80001a84:	03553c23          	sd	s5,56(a0)
    80001a88:	05653023          	sd	s6,64(a0)
    80001a8c:	05753423          	sd	s7,72(a0)
    80001a90:	05853823          	sd	s8,80(a0)
    80001a94:	05953c23          	sd	s9,88(a0)
    80001a98:	07a53023          	sd	s10,96(a0)
    80001a9c:	07b53423          	sd	s11,104(a0)
    80001aa0:	0005b083          	ld	ra,0(a1)
    80001aa4:	0085b103          	ld	sp,8(a1)
    80001aa8:	6980                	ld	s0,16(a1)
    80001aaa:	6d84                	ld	s1,24(a1)
    80001aac:	0205b903          	ld	s2,32(a1)
    80001ab0:	0285b983          	ld	s3,40(a1)
    80001ab4:	0305ba03          	ld	s4,48(a1)
    80001ab8:	0385ba83          	ld	s5,56(a1)
    80001abc:	0405bb03          	ld	s6,64(a1)
    80001ac0:	0485bb83          	ld	s7,72(a1)
    80001ac4:	0505bc03          	ld	s8,80(a1)
    80001ac8:	0585bc83          	ld	s9,88(a1)
    80001acc:	0605bd03          	ld	s10,96(a1)
    80001ad0:	0685bd83          	ld	s11,104(a1)
    80001ad4:	8082                	ret

0000000080001ad6 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001ad6:	1141                	addi	sp,sp,-16
    80001ad8:	e406                	sd	ra,8(sp)
    80001ada:	e022                	sd	s0,0(sp)
    80001adc:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001ade:	00006597          	auipc	a1,0x6
    80001ae2:	79a58593          	addi	a1,a1,1946 # 80008278 <states.0+0x30>
    80001ae6:	0000d517          	auipc	a0,0xd
    80001aea:	04a50513          	addi	a0,a0,74 # 8000eb30 <tickslock>
    80001aee:	00004097          	auipc	ra,0x4
    80001af2:	5c6080e7          	jalr	1478(ra) # 800060b4 <initlock>
}
    80001af6:	60a2                	ld	ra,8(sp)
    80001af8:	6402                	ld	s0,0(sp)
    80001afa:	0141                	addi	sp,sp,16
    80001afc:	8082                	ret

0000000080001afe <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001afe:	1141                	addi	sp,sp,-16
    80001b00:	e422                	sd	s0,8(sp)
    80001b02:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b04:	00003797          	auipc	a5,0x3
    80001b08:	53c78793          	addi	a5,a5,1340 # 80005040 <kernelvec>
    80001b0c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001b10:	6422                	ld	s0,8(sp)
    80001b12:	0141                	addi	sp,sp,16
    80001b14:	8082                	ret

0000000080001b16 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001b16:	1101                	addi	sp,sp,-32
    80001b18:	ec06                	sd	ra,24(sp)
    80001b1a:	e822                	sd	s0,16(sp)
    80001b1c:	e426                	sd	s1,8(sp)
    80001b1e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001b20:	fffff097          	auipc	ra,0xfffff
    80001b24:	334080e7          	jalr	820(ra) # 80000e54 <myproc>
    80001b28:	84aa                	mv	s1,a0

  if(p->trapframe ->a0 != 0)
    80001b2a:	6d3c                	ld	a5,88(a0)
    80001b2c:	7bbc                	ld	a5,112(a5)
    80001b2e:	c391                	beqz	a5,80001b32 <usertrapret+0x1c>
  {
    void (*handler)() = (void (*)())p->trapframe->a0;
    handler();
    80001b30:	9782                	jalr	a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b32:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001b36:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b38:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001b3c:	00005697          	auipc	a3,0x5
    80001b40:	4c468693          	addi	a3,a3,1220 # 80007000 <_trampoline>
    80001b44:	00005717          	auipc	a4,0x5
    80001b48:	4bc70713          	addi	a4,a4,1212 # 80007000 <_trampoline>
    80001b4c:	8f15                	sub	a4,a4,a3
    80001b4e:	040007b7          	lui	a5,0x4000
    80001b52:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001b54:	07b2                	slli	a5,a5,0xc
    80001b56:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b58:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001b5c:	6cb8                	ld	a4,88(s1)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001b5e:	18002673          	csrr	a2,satp
    80001b62:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001b64:	6cb0                	ld	a2,88(s1)
    80001b66:	60b8                	ld	a4,64(s1)
    80001b68:	6585                	lui	a1,0x1
    80001b6a:	972e                	add	a4,a4,a1
    80001b6c:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001b6e:	6cb8                	ld	a4,88(s1)
    80001b70:	00000617          	auipc	a2,0x0
    80001b74:	13260613          	addi	a2,a2,306 # 80001ca2 <usertrap>
    80001b78:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001b7a:	6cb8                	ld	a4,88(s1)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b7c:	8612                	mv	a2,tp
    80001b7e:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b80:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001b84:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001b88:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b8c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001b90:	6cb8                	ld	a4,88(s1)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b92:	6f18                	ld	a4,24(a4)
    80001b94:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b98:	68a8                	ld	a0,80(s1)
    80001b9a:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b9c:	00005717          	auipc	a4,0x5
    80001ba0:	50070713          	addi	a4,a4,1280 # 8000709c <userret>
    80001ba4:	8f15                	sub	a4,a4,a3
    80001ba6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001ba8:	577d                	li	a4,-1
    80001baa:	177e                	slli	a4,a4,0x3f
    80001bac:	8d59                	or	a0,a0,a4
    80001bae:	9782                	jalr	a5
}
    80001bb0:	60e2                	ld	ra,24(sp)
    80001bb2:	6442                	ld	s0,16(sp)
    80001bb4:	64a2                	ld	s1,8(sp)
    80001bb6:	6105                	addi	sp,sp,32
    80001bb8:	8082                	ret

0000000080001bba <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001bba:	1101                	addi	sp,sp,-32
    80001bbc:	ec06                	sd	ra,24(sp)
    80001bbe:	e822                	sd	s0,16(sp)
    80001bc0:	e426                	sd	s1,8(sp)
    80001bc2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001bc4:	0000d497          	auipc	s1,0xd
    80001bc8:	f6c48493          	addi	s1,s1,-148 # 8000eb30 <tickslock>
    80001bcc:	8526                	mv	a0,s1
    80001bce:	00004097          	auipc	ra,0x4
    80001bd2:	576080e7          	jalr	1398(ra) # 80006144 <acquire>
  ticks++;
    80001bd6:	00007517          	auipc	a0,0x7
    80001bda:	cf250513          	addi	a0,a0,-782 # 800088c8 <ticks>
    80001bde:	411c                	lw	a5,0(a0)
    80001be0:	2785                	addiw	a5,a5,1
    80001be2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001be4:	00000097          	auipc	ra,0x0
    80001be8:	988080e7          	jalr	-1656(ra) # 8000156c <wakeup>
  release(&tickslock);
    80001bec:	8526                	mv	a0,s1
    80001bee:	00004097          	auipc	ra,0x4
    80001bf2:	60a080e7          	jalr	1546(ra) # 800061f8 <release>
}
    80001bf6:	60e2                	ld	ra,24(sp)
    80001bf8:	6442                	ld	s0,16(sp)
    80001bfa:	64a2                	ld	s1,8(sp)
    80001bfc:	6105                	addi	sp,sp,32
    80001bfe:	8082                	ret

0000000080001c00 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001c00:	1101                	addi	sp,sp,-32
    80001c02:	ec06                	sd	ra,24(sp)
    80001c04:	e822                	sd	s0,16(sp)
    80001c06:	e426                	sd	s1,8(sp)
    80001c08:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c0a:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001c0e:	00074d63          	bltz	a4,80001c28 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001c12:	57fd                	li	a5,-1
    80001c14:	17fe                	slli	a5,a5,0x3f
    80001c16:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001c18:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001c1a:	06f70363          	beq	a4,a5,80001c80 <devintr+0x80>
  }
}
    80001c1e:	60e2                	ld	ra,24(sp)
    80001c20:	6442                	ld	s0,16(sp)
    80001c22:	64a2                	ld	s1,8(sp)
    80001c24:	6105                	addi	sp,sp,32
    80001c26:	8082                	ret
     (scause & 0xff) == 9){
    80001c28:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80001c2c:	46a5                	li	a3,9
    80001c2e:	fed792e3          	bne	a5,a3,80001c12 <devintr+0x12>
    int irq = plic_claim();
    80001c32:	00003097          	auipc	ra,0x3
    80001c36:	516080e7          	jalr	1302(ra) # 80005148 <plic_claim>
    80001c3a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001c3c:	47a9                	li	a5,10
    80001c3e:	02f50763          	beq	a0,a5,80001c6c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001c42:	4785                	li	a5,1
    80001c44:	02f50963          	beq	a0,a5,80001c76 <devintr+0x76>
    return 1;
    80001c48:	4505                	li	a0,1
    } else if(irq){
    80001c4a:	d8f1                	beqz	s1,80001c1e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001c4c:	85a6                	mv	a1,s1
    80001c4e:	00006517          	auipc	a0,0x6
    80001c52:	63250513          	addi	a0,a0,1586 # 80008280 <states.0+0x38>
    80001c56:	00004097          	auipc	ra,0x4
    80001c5a:	000080e7          	jalr	ra # 80005c56 <printf>
      plic_complete(irq);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	00003097          	auipc	ra,0x3
    80001c64:	50c080e7          	jalr	1292(ra) # 8000516c <plic_complete>
    return 1;
    80001c68:	4505                	li	a0,1
    80001c6a:	bf55                	j	80001c1e <devintr+0x1e>
      uartintr();
    80001c6c:	00004097          	auipc	ra,0x4
    80001c70:	3f8080e7          	jalr	1016(ra) # 80006064 <uartintr>
    80001c74:	b7ed                	j	80001c5e <devintr+0x5e>
      virtio_disk_intr();
    80001c76:	00004097          	auipc	ra,0x4
    80001c7a:	9be080e7          	jalr	-1602(ra) # 80005634 <virtio_disk_intr>
    80001c7e:	b7c5                	j	80001c5e <devintr+0x5e>
    if(cpuid() == 0){
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	1a8080e7          	jalr	424(ra) # 80000e28 <cpuid>
    80001c88:	c901                	beqz	a0,80001c98 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001c8a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001c8e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001c90:	14479073          	csrw	sip,a5
    return 2;
    80001c94:	4509                	li	a0,2
    80001c96:	b761                	j	80001c1e <devintr+0x1e>
      clockintr();
    80001c98:	00000097          	auipc	ra,0x0
    80001c9c:	f22080e7          	jalr	-222(ra) # 80001bba <clockintr>
    80001ca0:	b7ed                	j	80001c8a <devintr+0x8a>

0000000080001ca2 <usertrap>:
{
    80001ca2:	1101                	addi	sp,sp,-32
    80001ca4:	ec06                	sd	ra,24(sp)
    80001ca6:	e822                	sd	s0,16(sp)
    80001ca8:	e426                	sd	s1,8(sp)
    80001caa:	e04a                	sd	s2,0(sp)
    80001cac:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001cae:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001cb2:	1007f793          	andi	a5,a5,256
    80001cb6:	e3b1                	bnez	a5,80001cfa <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001cb8:	00003797          	auipc	a5,0x3
    80001cbc:	38878793          	addi	a5,a5,904 # 80005040 <kernelvec>
    80001cc0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	190080e7          	jalr	400(ra) # 80000e54 <myproc>
    80001ccc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001cce:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001cd0:	14102773          	csrr	a4,sepc
    80001cd4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001cd6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001cda:	47a1                	li	a5,8
    80001cdc:	02f70763          	beq	a4,a5,80001d0a <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80001ce0:	00000097          	auipc	ra,0x0
    80001ce4:	f20080e7          	jalr	-224(ra) # 80001c00 <devintr>
    80001ce8:	892a                	mv	s2,a0
    80001cea:	c92d                	beqz	a0,80001d5c <usertrap+0xba>
  if(killed(p))
    80001cec:	8526                	mv	a0,s1
    80001cee:	00000097          	auipc	ra,0x0
    80001cf2:	ac2080e7          	jalr	-1342(ra) # 800017b0 <killed>
    80001cf6:	c555                	beqz	a0,80001da2 <usertrap+0x100>
    80001cf8:	a045                	j	80001d98 <usertrap+0xf6>
    panic("usertrap: not from user mode");
    80001cfa:	00006517          	auipc	a0,0x6
    80001cfe:	5a650513          	addi	a0,a0,1446 # 800082a0 <states.0+0x58>
    80001d02:	00004097          	auipc	ra,0x4
    80001d06:	f0a080e7          	jalr	-246(ra) # 80005c0c <panic>
    if(killed(p))
    80001d0a:	00000097          	auipc	ra,0x0
    80001d0e:	aa6080e7          	jalr	-1370(ra) # 800017b0 <killed>
    80001d12:	ed1d                	bnez	a0,80001d50 <usertrap+0xae>
    p->trapframe->epc += 4;
    80001d14:	6cb8                	ld	a4,88(s1)
    80001d16:	6f1c                	ld	a5,24(a4)
    80001d18:	0791                	addi	a5,a5,4
    80001d1a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d1c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d20:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d24:	10079073          	csrw	sstatus,a5
    syscall();
    80001d28:	00000097          	auipc	ra,0x0
    80001d2c:	2f6080e7          	jalr	758(ra) # 8000201e <syscall>
  if(killed(p))
    80001d30:	8526                	mv	a0,s1
    80001d32:	00000097          	auipc	ra,0x0
    80001d36:	a7e080e7          	jalr	-1410(ra) # 800017b0 <killed>
    80001d3a:	ed31                	bnez	a0,80001d96 <usertrap+0xf4>
  usertrapret();
    80001d3c:	00000097          	auipc	ra,0x0
    80001d40:	dda080e7          	jalr	-550(ra) # 80001b16 <usertrapret>
}
    80001d44:	60e2                	ld	ra,24(sp)
    80001d46:	6442                	ld	s0,16(sp)
    80001d48:	64a2                	ld	s1,8(sp)
    80001d4a:	6902                	ld	s2,0(sp)
    80001d4c:	6105                	addi	sp,sp,32
    80001d4e:	8082                	ret
      exit(-1);
    80001d50:	557d                	li	a0,-1
    80001d52:	00000097          	auipc	ra,0x0
    80001d56:	8ea080e7          	jalr	-1814(ra) # 8000163c <exit>
    80001d5a:	bf6d                	j	80001d14 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d5c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001d60:	5890                	lw	a2,48(s1)
    80001d62:	00006517          	auipc	a0,0x6
    80001d66:	55e50513          	addi	a0,a0,1374 # 800082c0 <states.0+0x78>
    80001d6a:	00004097          	auipc	ra,0x4
    80001d6e:	eec080e7          	jalr	-276(ra) # 80005c56 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d72:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001d76:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001d7a:	00006517          	auipc	a0,0x6
    80001d7e:	57650513          	addi	a0,a0,1398 # 800082f0 <states.0+0xa8>
    80001d82:	00004097          	auipc	ra,0x4
    80001d86:	ed4080e7          	jalr	-300(ra) # 80005c56 <printf>
    setkilled(p);
    80001d8a:	8526                	mv	a0,s1
    80001d8c:	00000097          	auipc	ra,0x0
    80001d90:	9f8080e7          	jalr	-1544(ra) # 80001784 <setkilled>
    80001d94:	bf71                	j	80001d30 <usertrap+0x8e>
  if(killed(p))
    80001d96:	4901                	li	s2,0
    exit(-1);
    80001d98:	557d                	li	a0,-1
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	8a2080e7          	jalr	-1886(ra) # 8000163c <exit>
  if(which_dev == 2)
    80001da2:	4789                	li	a5,2
    80001da4:	f8f91ce3          	bne	s2,a5,80001d3c <usertrap+0x9a>
    if(p->alarm_ticks > 0)
    80001da8:	1684a783          	lw	a5,360(s1)
    80001dac:	f8f058e3          	blez	a5,80001d3c <usertrap+0x9a>
      p->alarm_ticks--;
    80001db0:	37fd                	addiw	a5,a5,-1
    80001db2:	0007871b          	sext.w	a4,a5
    80001db6:	16f4a423          	sw	a5,360(s1)
      if(p->alarm_ticks == 0)
    80001dba:	f349                	bnez	a4,80001d3c <usertrap+0x9a>
        handler = p->alarm_handler;
    80001dbc:	1704b783          	ld	a5,368(s1)
        if(handler != 0)
    80001dc0:	dfb5                	beqz	a5,80001d3c <usertrap+0x9a>
          p->alarm_handler = 0;
    80001dc2:	1604b823          	sd	zero,368(s1)
          p->trapframe->a0 = (uint64)handler;
    80001dc6:	6cb8                	ld	a4,88(s1)
    80001dc8:	fb3c                	sd	a5,112(a4)
          p->trapframe->epc += 4;
    80001dca:	6cb8                	ld	a4,88(s1)
    80001dcc:	6f1c                	ld	a5,24(a4)
    80001dce:	0791                	addi	a5,a5,4
    80001dd0:	ef1c                	sd	a5,24(a4)
    80001dd2:	b7ad                	j	80001d3c <usertrap+0x9a>

0000000080001dd4 <kerneltrap>:
{
    80001dd4:	7179                	addi	sp,sp,-48
    80001dd6:	f406                	sd	ra,40(sp)
    80001dd8:	f022                	sd	s0,32(sp)
    80001dda:	ec26                	sd	s1,24(sp)
    80001ddc:	e84a                	sd	s2,16(sp)
    80001dde:	e44e                	sd	s3,8(sp)
    80001de0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001de2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001de6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dea:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001dee:	1004f793          	andi	a5,s1,256
    80001df2:	cb85                	beqz	a5,80001e22 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001df4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001df8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001dfa:	ef85                	bnez	a5,80001e32 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001dfc:	00000097          	auipc	ra,0x0
    80001e00:	e04080e7          	jalr	-508(ra) # 80001c00 <devintr>
    80001e04:	cd1d                	beqz	a0,80001e42 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e06:	4789                	li	a5,2
    80001e08:	06f50a63          	beq	a0,a5,80001e7c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e0c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e10:	10049073          	csrw	sstatus,s1
}
    80001e14:	70a2                	ld	ra,40(sp)
    80001e16:	7402                	ld	s0,32(sp)
    80001e18:	64e2                	ld	s1,24(sp)
    80001e1a:	6942                	ld	s2,16(sp)
    80001e1c:	69a2                	ld	s3,8(sp)
    80001e1e:	6145                	addi	sp,sp,48
    80001e20:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e22:	00006517          	auipc	a0,0x6
    80001e26:	4ee50513          	addi	a0,a0,1262 # 80008310 <states.0+0xc8>
    80001e2a:	00004097          	auipc	ra,0x4
    80001e2e:	de2080e7          	jalr	-542(ra) # 80005c0c <panic>
    panic("kerneltrap: interrupts enabled");
    80001e32:	00006517          	auipc	a0,0x6
    80001e36:	50650513          	addi	a0,a0,1286 # 80008338 <states.0+0xf0>
    80001e3a:	00004097          	auipc	ra,0x4
    80001e3e:	dd2080e7          	jalr	-558(ra) # 80005c0c <panic>
    printf("scause %p\n", scause);
    80001e42:	85ce                	mv	a1,s3
    80001e44:	00006517          	auipc	a0,0x6
    80001e48:	51450513          	addi	a0,a0,1300 # 80008358 <states.0+0x110>
    80001e4c:	00004097          	auipc	ra,0x4
    80001e50:	e0a080e7          	jalr	-502(ra) # 80005c56 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e54:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e58:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e5c:	00006517          	auipc	a0,0x6
    80001e60:	50c50513          	addi	a0,a0,1292 # 80008368 <states.0+0x120>
    80001e64:	00004097          	auipc	ra,0x4
    80001e68:	df2080e7          	jalr	-526(ra) # 80005c56 <printf>
    panic("kerneltrap");
    80001e6c:	00006517          	auipc	a0,0x6
    80001e70:	51450513          	addi	a0,a0,1300 # 80008380 <states.0+0x138>
    80001e74:	00004097          	auipc	ra,0x4
    80001e78:	d98080e7          	jalr	-616(ra) # 80005c0c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	fd8080e7          	jalr	-40(ra) # 80000e54 <myproc>
    80001e84:	d541                	beqz	a0,80001e0c <kerneltrap+0x38>
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	fce080e7          	jalr	-50(ra) # 80000e54 <myproc>
    80001e8e:	4d18                	lw	a4,24(a0)
    80001e90:	4791                	li	a5,4
    80001e92:	f6f71de3          	bne	a4,a5,80001e0c <kerneltrap+0x38>
    yield();
    80001e96:	fffff097          	auipc	ra,0xfffff
    80001e9a:	636080e7          	jalr	1590(ra) # 800014cc <yield>
    80001e9e:	b7bd                	j	80001e0c <kerneltrap+0x38>

0000000080001ea0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001ea0:	1101                	addi	sp,sp,-32
    80001ea2:	ec06                	sd	ra,24(sp)
    80001ea4:	e822                	sd	s0,16(sp)
    80001ea6:	e426                	sd	s1,8(sp)
    80001ea8:	1000                	addi	s0,sp,32
    80001eaa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	fa8080e7          	jalr	-88(ra) # 80000e54 <myproc>
  switch (n) {
    80001eb4:	4795                	li	a5,5
    80001eb6:	0497e163          	bltu	a5,s1,80001ef8 <argraw+0x58>
    80001eba:	048a                	slli	s1,s1,0x2
    80001ebc:	00006717          	auipc	a4,0x6
    80001ec0:	4fc70713          	addi	a4,a4,1276 # 800083b8 <states.0+0x170>
    80001ec4:	94ba                	add	s1,s1,a4
    80001ec6:	409c                	lw	a5,0(s1)
    80001ec8:	97ba                	add	a5,a5,a4
    80001eca:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001ecc:	6d3c                	ld	a5,88(a0)
    80001ece:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001ed0:	60e2                	ld	ra,24(sp)
    80001ed2:	6442                	ld	s0,16(sp)
    80001ed4:	64a2                	ld	s1,8(sp)
    80001ed6:	6105                	addi	sp,sp,32
    80001ed8:	8082                	ret
    return p->trapframe->a1;
    80001eda:	6d3c                	ld	a5,88(a0)
    80001edc:	7fa8                	ld	a0,120(a5)
    80001ede:	bfcd                	j	80001ed0 <argraw+0x30>
    return p->trapframe->a2;
    80001ee0:	6d3c                	ld	a5,88(a0)
    80001ee2:	63c8                	ld	a0,128(a5)
    80001ee4:	b7f5                	j	80001ed0 <argraw+0x30>
    return p->trapframe->a3;
    80001ee6:	6d3c                	ld	a5,88(a0)
    80001ee8:	67c8                	ld	a0,136(a5)
    80001eea:	b7dd                	j	80001ed0 <argraw+0x30>
    return p->trapframe->a4;
    80001eec:	6d3c                	ld	a5,88(a0)
    80001eee:	6bc8                	ld	a0,144(a5)
    80001ef0:	b7c5                	j	80001ed0 <argraw+0x30>
    return p->trapframe->a5;
    80001ef2:	6d3c                	ld	a5,88(a0)
    80001ef4:	6fc8                	ld	a0,152(a5)
    80001ef6:	bfe9                	j	80001ed0 <argraw+0x30>
  panic("argraw");
    80001ef8:	00006517          	auipc	a0,0x6
    80001efc:	49850513          	addi	a0,a0,1176 # 80008390 <states.0+0x148>
    80001f00:	00004097          	auipc	ra,0x4
    80001f04:	d0c080e7          	jalr	-756(ra) # 80005c0c <panic>

0000000080001f08 <fetchaddr>:
{
    80001f08:	1101                	addi	sp,sp,-32
    80001f0a:	ec06                	sd	ra,24(sp)
    80001f0c:	e822                	sd	s0,16(sp)
    80001f0e:	e426                	sd	s1,8(sp)
    80001f10:	e04a                	sd	s2,0(sp)
    80001f12:	1000                	addi	s0,sp,32
    80001f14:	84aa                	mv	s1,a0
    80001f16:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f18:	fffff097          	auipc	ra,0xfffff
    80001f1c:	f3c080e7          	jalr	-196(ra) # 80000e54 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001f20:	653c                	ld	a5,72(a0)
    80001f22:	02f4f863          	bgeu	s1,a5,80001f52 <fetchaddr+0x4a>
    80001f26:	00848713          	addi	a4,s1,8
    80001f2a:	02e7e663          	bltu	a5,a4,80001f56 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001f2e:	46a1                	li	a3,8
    80001f30:	8626                	mv	a2,s1
    80001f32:	85ca                	mv	a1,s2
    80001f34:	6928                	ld	a0,80(a0)
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	c6a080e7          	jalr	-918(ra) # 80000ba0 <copyin>
    80001f3e:	00a03533          	snez	a0,a0
    80001f42:	40a00533          	neg	a0,a0
}
    80001f46:	60e2                	ld	ra,24(sp)
    80001f48:	6442                	ld	s0,16(sp)
    80001f4a:	64a2                	ld	s1,8(sp)
    80001f4c:	6902                	ld	s2,0(sp)
    80001f4e:	6105                	addi	sp,sp,32
    80001f50:	8082                	ret
    return -1;
    80001f52:	557d                	li	a0,-1
    80001f54:	bfcd                	j	80001f46 <fetchaddr+0x3e>
    80001f56:	557d                	li	a0,-1
    80001f58:	b7fd                	j	80001f46 <fetchaddr+0x3e>

0000000080001f5a <fetchstr>:
{
    80001f5a:	7179                	addi	sp,sp,-48
    80001f5c:	f406                	sd	ra,40(sp)
    80001f5e:	f022                	sd	s0,32(sp)
    80001f60:	ec26                	sd	s1,24(sp)
    80001f62:	e84a                	sd	s2,16(sp)
    80001f64:	e44e                	sd	s3,8(sp)
    80001f66:	1800                	addi	s0,sp,48
    80001f68:	892a                	mv	s2,a0
    80001f6a:	84ae                	mv	s1,a1
    80001f6c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001f6e:	fffff097          	auipc	ra,0xfffff
    80001f72:	ee6080e7          	jalr	-282(ra) # 80000e54 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001f76:	86ce                	mv	a3,s3
    80001f78:	864a                	mv	a2,s2
    80001f7a:	85a6                	mv	a1,s1
    80001f7c:	6928                	ld	a0,80(a0)
    80001f7e:	fffff097          	auipc	ra,0xfffff
    80001f82:	cb0080e7          	jalr	-848(ra) # 80000c2e <copyinstr>
    80001f86:	00054e63          	bltz	a0,80001fa2 <fetchstr+0x48>
  return strlen(buf);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	ffffe097          	auipc	ra,0xffffe
    80001f90:	36a080e7          	jalr	874(ra) # 800002f6 <strlen>
}
    80001f94:	70a2                	ld	ra,40(sp)
    80001f96:	7402                	ld	s0,32(sp)
    80001f98:	64e2                	ld	s1,24(sp)
    80001f9a:	6942                	ld	s2,16(sp)
    80001f9c:	69a2                	ld	s3,8(sp)
    80001f9e:	6145                	addi	sp,sp,48
    80001fa0:	8082                	ret
    return -1;
    80001fa2:	557d                	li	a0,-1
    80001fa4:	bfc5                	j	80001f94 <fetchstr+0x3a>

0000000080001fa6 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001fa6:	1101                	addi	sp,sp,-32
    80001fa8:	ec06                	sd	ra,24(sp)
    80001faa:	e822                	sd	s0,16(sp)
    80001fac:	e426                	sd	s1,8(sp)
    80001fae:	1000                	addi	s0,sp,32
    80001fb0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fb2:	00000097          	auipc	ra,0x0
    80001fb6:	eee080e7          	jalr	-274(ra) # 80001ea0 <argraw>
    80001fba:	c088                	sw	a0,0(s1)
}
    80001fbc:	60e2                	ld	ra,24(sp)
    80001fbe:	6442                	ld	s0,16(sp)
    80001fc0:	64a2                	ld	s1,8(sp)
    80001fc2:	6105                	addi	sp,sp,32
    80001fc4:	8082                	ret

0000000080001fc6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001fc6:	1101                	addi	sp,sp,-32
    80001fc8:	ec06                	sd	ra,24(sp)
    80001fca:	e822                	sd	s0,16(sp)
    80001fcc:	e426                	sd	s1,8(sp)
    80001fce:	1000                	addi	s0,sp,32
    80001fd0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fd2:	00000097          	auipc	ra,0x0
    80001fd6:	ece080e7          	jalr	-306(ra) # 80001ea0 <argraw>
    80001fda:	e088                	sd	a0,0(s1)
}
    80001fdc:	60e2                	ld	ra,24(sp)
    80001fde:	6442                	ld	s0,16(sp)
    80001fe0:	64a2                	ld	s1,8(sp)
    80001fe2:	6105                	addi	sp,sp,32
    80001fe4:	8082                	ret

0000000080001fe6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80001fe6:	7179                	addi	sp,sp,-48
    80001fe8:	f406                	sd	ra,40(sp)
    80001fea:	f022                	sd	s0,32(sp)
    80001fec:	ec26                	sd	s1,24(sp)
    80001fee:	e84a                	sd	s2,16(sp)
    80001ff0:	1800                	addi	s0,sp,48
    80001ff2:	84ae                	mv	s1,a1
    80001ff4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80001ff6:	fd840593          	addi	a1,s0,-40
    80001ffa:	00000097          	auipc	ra,0x0
    80001ffe:	fcc080e7          	jalr	-52(ra) # 80001fc6 <argaddr>
  return fetchstr(addr, buf, max);
    80002002:	864a                	mv	a2,s2
    80002004:	85a6                	mv	a1,s1
    80002006:	fd843503          	ld	a0,-40(s0)
    8000200a:	00000097          	auipc	ra,0x0
    8000200e:	f50080e7          	jalr	-176(ra) # 80001f5a <fetchstr>
}
    80002012:	70a2                	ld	ra,40(sp)
    80002014:	7402                	ld	s0,32(sp)
    80002016:	64e2                	ld	s1,24(sp)
    80002018:	6942                	ld	s2,16(sp)
    8000201a:	6145                	addi	sp,sp,48
    8000201c:	8082                	ret

000000008000201e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    8000201e:	7179                	addi	sp,sp,-48
    80002020:	f406                	sd	ra,40(sp)
    80002022:	f022                	sd	s0,32(sp)
    80002024:	ec26                	sd	s1,24(sp)
    80002026:	e84a                	sd	s2,16(sp)
    80002028:	1800                	addi	s0,sp,48
  int num;
  struct proc *p = myproc();
    8000202a:	fffff097          	auipc	ra,0xfffff
    8000202e:	e2a080e7          	jalr	-470(ra) # 80000e54 <myproc>
    80002032:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002034:	05853903          	ld	s2,88(a0)
    80002038:	0a893783          	ld	a5,168(s2)
    8000203c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002040:	37fd                	addiw	a5,a5,-1
    80002042:	4751                	li	a4,20
    80002044:	00f76f63          	bltu	a4,a5,80002062 <syscall+0x44>
    80002048:	00369713          	slli	a4,a3,0x3
    8000204c:	00006797          	auipc	a5,0x6
    80002050:	38478793          	addi	a5,a5,900 # 800083d0 <syscalls>
    80002054:	97ba                	add	a5,a5,a4
    80002056:	639c                	ld	a5,0(a5)
    80002058:	c789                	beqz	a5,80002062 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000205a:	9782                	jalr	a5
    8000205c:	06a93823          	sd	a0,112(s2)
    80002060:	a015                	j	80002084 <syscall+0x66>
  } 
  else if (num == SYS_sigalarm)
    80002062:	47dd                	li	a5,23
    80002064:	02f68663          	beq	a3,a5,80002090 <syscall+0x72>
      return;
    p->alarm_ticks = ticks;
    p->alarm_handler = handler;
  }
  else {
    printf("%d %s: unknown sys call %d\n",
    80002068:	15848613          	addi	a2,s1,344
    8000206c:	588c                	lw	a1,48(s1)
    8000206e:	00006517          	auipc	a0,0x6
    80002072:	32a50513          	addi	a0,a0,810 # 80008398 <states.0+0x150>
    80002076:	00004097          	auipc	ra,0x4
    8000207a:	be0080e7          	jalr	-1056(ra) # 80005c56 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000207e:	6cbc                	ld	a5,88(s1)
    80002080:	577d                	li	a4,-1
    80002082:	fbb8                	sd	a4,112(a5)
  }
}
    80002084:	70a2                	ld	ra,40(sp)
    80002086:	7402                	ld	s0,32(sp)
    80002088:	64e2                	ld	s1,24(sp)
    8000208a:	6942                	ld	s2,16(sp)
    8000208c:	6145                	addi	sp,sp,48
    8000208e:	8082                	ret
    argint(0, &ticks);
    80002090:	fd440593          	addi	a1,s0,-44
    80002094:	4501                	li	a0,0
    80002096:	00000097          	auipc	ra,0x0
    8000209a:	f10080e7          	jalr	-240(ra) # 80001fa6 <argint>
    argstr(1, (void*)&handler, sizeof(handler));
    8000209e:	4621                	li	a2,8
    800020a0:	fd840593          	addi	a1,s0,-40
    800020a4:	4505                	li	a0,1
    800020a6:	00000097          	auipc	ra,0x0
    800020aa:	f40080e7          	jalr	-192(ra) # 80001fe6 <argstr>
    if(ticks < 0 ||  handler < 0)
    800020ae:	fd442783          	lw	a5,-44(s0)
    800020b2:	fc07c9e3          	bltz	a5,80002084 <syscall+0x66>
    p->alarm_ticks = ticks;
    800020b6:	16f4a423          	sw	a5,360(s1)
    p->alarm_handler = handler;
    800020ba:	fd843783          	ld	a5,-40(s0)
    800020be:	16f4b823          	sd	a5,368(s1)
    800020c2:	b7c9                	j	80002084 <syscall+0x66>

00000000800020c4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800020c4:	1101                	addi	sp,sp,-32
    800020c6:	ec06                	sd	ra,24(sp)
    800020c8:	e822                	sd	s0,16(sp)
    800020ca:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800020cc:	fec40593          	addi	a1,s0,-20
    800020d0:	4501                	li	a0,0
    800020d2:	00000097          	auipc	ra,0x0
    800020d6:	ed4080e7          	jalr	-300(ra) # 80001fa6 <argint>
  exit(n);
    800020da:	fec42503          	lw	a0,-20(s0)
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	55e080e7          	jalr	1374(ra) # 8000163c <exit>
  return 0;  // not reached
}
    800020e6:	4501                	li	a0,0
    800020e8:	60e2                	ld	ra,24(sp)
    800020ea:	6442                	ld	s0,16(sp)
    800020ec:	6105                	addi	sp,sp,32
    800020ee:	8082                	ret

00000000800020f0 <sys_getpid>:

uint64
sys_getpid(void)
{
    800020f0:	1141                	addi	sp,sp,-16
    800020f2:	e406                	sd	ra,8(sp)
    800020f4:	e022                	sd	s0,0(sp)
    800020f6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800020f8:	fffff097          	auipc	ra,0xfffff
    800020fc:	d5c080e7          	jalr	-676(ra) # 80000e54 <myproc>
}
    80002100:	5908                	lw	a0,48(a0)
    80002102:	60a2                	ld	ra,8(sp)
    80002104:	6402                	ld	s0,0(sp)
    80002106:	0141                	addi	sp,sp,16
    80002108:	8082                	ret

000000008000210a <sys_fork>:

uint64
sys_fork(void)
{
    8000210a:	1141                	addi	sp,sp,-16
    8000210c:	e406                	sd	ra,8(sp)
    8000210e:	e022                	sd	s0,0(sp)
    80002110:	0800                	addi	s0,sp,16
  return fork();
    80002112:	fffff097          	auipc	ra,0xfffff
    80002116:	104080e7          	jalr	260(ra) # 80001216 <fork>
}
    8000211a:	60a2                	ld	ra,8(sp)
    8000211c:	6402                	ld	s0,0(sp)
    8000211e:	0141                	addi	sp,sp,16
    80002120:	8082                	ret

0000000080002122 <sys_wait>:

uint64
sys_wait(void)
{
    80002122:	1101                	addi	sp,sp,-32
    80002124:	ec06                	sd	ra,24(sp)
    80002126:	e822                	sd	s0,16(sp)
    80002128:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    8000212a:	fe840593          	addi	a1,s0,-24
    8000212e:	4501                	li	a0,0
    80002130:	00000097          	auipc	ra,0x0
    80002134:	e96080e7          	jalr	-362(ra) # 80001fc6 <argaddr>
  return wait(p);
    80002138:	fe843503          	ld	a0,-24(s0)
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	6a6080e7          	jalr	1702(ra) # 800017e2 <wait>
}
    80002144:	60e2                	ld	ra,24(sp)
    80002146:	6442                	ld	s0,16(sp)
    80002148:	6105                	addi	sp,sp,32
    8000214a:	8082                	ret

000000008000214c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000214c:	7179                	addi	sp,sp,-48
    8000214e:	f406                	sd	ra,40(sp)
    80002150:	f022                	sd	s0,32(sp)
    80002152:	ec26                	sd	s1,24(sp)
    80002154:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002156:	fdc40593          	addi	a1,s0,-36
    8000215a:	4501                	li	a0,0
    8000215c:	00000097          	auipc	ra,0x0
    80002160:	e4a080e7          	jalr	-438(ra) # 80001fa6 <argint>
  addr = myproc()->sz;
    80002164:	fffff097          	auipc	ra,0xfffff
    80002168:	cf0080e7          	jalr	-784(ra) # 80000e54 <myproc>
    8000216c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    8000216e:	fdc42503          	lw	a0,-36(s0)
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	048080e7          	jalr	72(ra) # 800011ba <growproc>
    8000217a:	00054863          	bltz	a0,8000218a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    8000217e:	8526                	mv	a0,s1
    80002180:	70a2                	ld	ra,40(sp)
    80002182:	7402                	ld	s0,32(sp)
    80002184:	64e2                	ld	s1,24(sp)
    80002186:	6145                	addi	sp,sp,48
    80002188:	8082                	ret
    return -1;
    8000218a:	54fd                	li	s1,-1
    8000218c:	bfcd                	j	8000217e <sys_sbrk+0x32>

000000008000218e <sys_sleep>:

uint64
sys_sleep(void)
{
    8000218e:	7139                	addi	sp,sp,-64
    80002190:	fc06                	sd	ra,56(sp)
    80002192:	f822                	sd	s0,48(sp)
    80002194:	f426                	sd	s1,40(sp)
    80002196:	f04a                	sd	s2,32(sp)
    80002198:	ec4e                	sd	s3,24(sp)
    8000219a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000219c:	fcc40593          	addi	a1,s0,-52
    800021a0:	4501                	li	a0,0
    800021a2:	00000097          	auipc	ra,0x0
    800021a6:	e04080e7          	jalr	-508(ra) # 80001fa6 <argint>
  if(n < 0)
    800021aa:	fcc42783          	lw	a5,-52(s0)
    800021ae:	0607cf63          	bltz	a5,8000222c <sys_sleep+0x9e>
    n = 0;
  acquire(&tickslock);
    800021b2:	0000d517          	auipc	a0,0xd
    800021b6:	97e50513          	addi	a0,a0,-1666 # 8000eb30 <tickslock>
    800021ba:	00004097          	auipc	ra,0x4
    800021be:	f8a080e7          	jalr	-118(ra) # 80006144 <acquire>
  ticks0 = ticks;
    800021c2:	00006917          	auipc	s2,0x6
    800021c6:	70692903          	lw	s2,1798(s2) # 800088c8 <ticks>
  while(ticks - ticks0 < n){
    800021ca:	fcc42783          	lw	a5,-52(s0)
    800021ce:	cf9d                	beqz	a5,8000220c <sys_sleep+0x7e>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800021d0:	0000d997          	auipc	s3,0xd
    800021d4:	96098993          	addi	s3,s3,-1696 # 8000eb30 <tickslock>
    800021d8:	00006497          	auipc	s1,0x6
    800021dc:	6f048493          	addi	s1,s1,1776 # 800088c8 <ticks>
    if(killed(myproc())){
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	c74080e7          	jalr	-908(ra) # 80000e54 <myproc>
    800021e8:	fffff097          	auipc	ra,0xfffff
    800021ec:	5c8080e7          	jalr	1480(ra) # 800017b0 <killed>
    800021f0:	e129                	bnez	a0,80002232 <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    800021f2:	85ce                	mv	a1,s3
    800021f4:	8526                	mv	a0,s1
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	312080e7          	jalr	786(ra) # 80001508 <sleep>
  while(ticks - ticks0 < n){
    800021fe:	409c                	lw	a5,0(s1)
    80002200:	412787bb          	subw	a5,a5,s2
    80002204:	fcc42703          	lw	a4,-52(s0)
    80002208:	fce7ece3          	bltu	a5,a4,800021e0 <sys_sleep+0x52>
  }
  release(&tickslock);
    8000220c:	0000d517          	auipc	a0,0xd
    80002210:	92450513          	addi	a0,a0,-1756 # 8000eb30 <tickslock>
    80002214:	00004097          	auipc	ra,0x4
    80002218:	fe4080e7          	jalr	-28(ra) # 800061f8 <release>
  return 0;
    8000221c:	4501                	li	a0,0
}
    8000221e:	70e2                	ld	ra,56(sp)
    80002220:	7442                	ld	s0,48(sp)
    80002222:	74a2                	ld	s1,40(sp)
    80002224:	7902                	ld	s2,32(sp)
    80002226:	69e2                	ld	s3,24(sp)
    80002228:	6121                	addi	sp,sp,64
    8000222a:	8082                	ret
    n = 0;
    8000222c:	fc042623          	sw	zero,-52(s0)
    80002230:	b749                	j	800021b2 <sys_sleep+0x24>
      release(&tickslock);
    80002232:	0000d517          	auipc	a0,0xd
    80002236:	8fe50513          	addi	a0,a0,-1794 # 8000eb30 <tickslock>
    8000223a:	00004097          	auipc	ra,0x4
    8000223e:	fbe080e7          	jalr	-66(ra) # 800061f8 <release>
      return -1;
    80002242:	557d                	li	a0,-1
    80002244:	bfe9                	j	8000221e <sys_sleep+0x90>

0000000080002246 <sys_kill>:

uint64
sys_kill(void)
{
    80002246:	1101                	addi	sp,sp,-32
    80002248:	ec06                	sd	ra,24(sp)
    8000224a:	e822                	sd	s0,16(sp)
    8000224c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    8000224e:	fec40593          	addi	a1,s0,-20
    80002252:	4501                	li	a0,0
    80002254:	00000097          	auipc	ra,0x0
    80002258:	d52080e7          	jalr	-686(ra) # 80001fa6 <argint>
  return kill(pid);
    8000225c:	fec42503          	lw	a0,-20(s0)
    80002260:	fffff097          	auipc	ra,0xfffff
    80002264:	4b2080e7          	jalr	1202(ra) # 80001712 <kill>
}
    80002268:	60e2                	ld	ra,24(sp)
    8000226a:	6442                	ld	s0,16(sp)
    8000226c:	6105                	addi	sp,sp,32
    8000226e:	8082                	ret

0000000080002270 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002270:	1101                	addi	sp,sp,-32
    80002272:	ec06                	sd	ra,24(sp)
    80002274:	e822                	sd	s0,16(sp)
    80002276:	e426                	sd	s1,8(sp)
    80002278:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    8000227a:	0000d517          	auipc	a0,0xd
    8000227e:	8b650513          	addi	a0,a0,-1866 # 8000eb30 <tickslock>
    80002282:	00004097          	auipc	ra,0x4
    80002286:	ec2080e7          	jalr	-318(ra) # 80006144 <acquire>
  xticks = ticks;
    8000228a:	00006497          	auipc	s1,0x6
    8000228e:	63e4a483          	lw	s1,1598(s1) # 800088c8 <ticks>
  release(&tickslock);
    80002292:	0000d517          	auipc	a0,0xd
    80002296:	89e50513          	addi	a0,a0,-1890 # 8000eb30 <tickslock>
    8000229a:	00004097          	auipc	ra,0x4
    8000229e:	f5e080e7          	jalr	-162(ra) # 800061f8 <release>
  return xticks;
}
    800022a2:	02049513          	slli	a0,s1,0x20
    800022a6:	9101                	srli	a0,a0,0x20
    800022a8:	60e2                	ld	ra,24(sp)
    800022aa:	6442                	ld	s0,16(sp)
    800022ac:	64a2                	ld	s1,8(sp)
    800022ae:	6105                	addi	sp,sp,32
    800022b0:	8082                	ret

00000000800022b2 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800022b2:	7179                	addi	sp,sp,-48
    800022b4:	f406                	sd	ra,40(sp)
    800022b6:	f022                	sd	s0,32(sp)
    800022b8:	ec26                	sd	s1,24(sp)
    800022ba:	e84a                	sd	s2,16(sp)
    800022bc:	e44e                	sd	s3,8(sp)
    800022be:	e052                	sd	s4,0(sp)
    800022c0:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800022c2:	00006597          	auipc	a1,0x6
    800022c6:	1be58593          	addi	a1,a1,446 # 80008480 <syscalls+0xb0>
    800022ca:	0000d517          	auipc	a0,0xd
    800022ce:	87e50513          	addi	a0,a0,-1922 # 8000eb48 <bcache>
    800022d2:	00004097          	auipc	ra,0x4
    800022d6:	de2080e7          	jalr	-542(ra) # 800060b4 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800022da:	00015797          	auipc	a5,0x15
    800022de:	86e78793          	addi	a5,a5,-1938 # 80016b48 <bcache+0x8000>
    800022e2:	00015717          	auipc	a4,0x15
    800022e6:	ace70713          	addi	a4,a4,-1330 # 80016db0 <bcache+0x8268>
    800022ea:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800022ee:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800022f2:	0000d497          	auipc	s1,0xd
    800022f6:	86e48493          	addi	s1,s1,-1938 # 8000eb60 <bcache+0x18>
    b->next = bcache.head.next;
    800022fa:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800022fc:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800022fe:	00006a17          	auipc	s4,0x6
    80002302:	18aa0a13          	addi	s4,s4,394 # 80008488 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002306:	2b893783          	ld	a5,696(s2)
    8000230a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000230c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002310:	85d2                	mv	a1,s4
    80002312:	01048513          	addi	a0,s1,16
    80002316:	00001097          	auipc	ra,0x1
    8000231a:	4c8080e7          	jalr	1224(ra) # 800037de <initsleeplock>
    bcache.head.next->prev = b;
    8000231e:	2b893783          	ld	a5,696(s2)
    80002322:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002324:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002328:	45848493          	addi	s1,s1,1112
    8000232c:	fd349de3          	bne	s1,s3,80002306 <binit+0x54>
  }
}
    80002330:	70a2                	ld	ra,40(sp)
    80002332:	7402                	ld	s0,32(sp)
    80002334:	64e2                	ld	s1,24(sp)
    80002336:	6942                	ld	s2,16(sp)
    80002338:	69a2                	ld	s3,8(sp)
    8000233a:	6a02                	ld	s4,0(sp)
    8000233c:	6145                	addi	sp,sp,48
    8000233e:	8082                	ret

0000000080002340 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002340:	7179                	addi	sp,sp,-48
    80002342:	f406                	sd	ra,40(sp)
    80002344:	f022                	sd	s0,32(sp)
    80002346:	ec26                	sd	s1,24(sp)
    80002348:	e84a                	sd	s2,16(sp)
    8000234a:	e44e                	sd	s3,8(sp)
    8000234c:	1800                	addi	s0,sp,48
    8000234e:	892a                	mv	s2,a0
    80002350:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002352:	0000c517          	auipc	a0,0xc
    80002356:	7f650513          	addi	a0,a0,2038 # 8000eb48 <bcache>
    8000235a:	00004097          	auipc	ra,0x4
    8000235e:	dea080e7          	jalr	-534(ra) # 80006144 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002362:	00015497          	auipc	s1,0x15
    80002366:	a9e4b483          	ld	s1,-1378(s1) # 80016e00 <bcache+0x82b8>
    8000236a:	00015797          	auipc	a5,0x15
    8000236e:	a4678793          	addi	a5,a5,-1466 # 80016db0 <bcache+0x8268>
    80002372:	02f48f63          	beq	s1,a5,800023b0 <bread+0x70>
    80002376:	873e                	mv	a4,a5
    80002378:	a021                	j	80002380 <bread+0x40>
    8000237a:	68a4                	ld	s1,80(s1)
    8000237c:	02e48a63          	beq	s1,a4,800023b0 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002380:	449c                	lw	a5,8(s1)
    80002382:	ff279ce3          	bne	a5,s2,8000237a <bread+0x3a>
    80002386:	44dc                	lw	a5,12(s1)
    80002388:	ff3799e3          	bne	a5,s3,8000237a <bread+0x3a>
      b->refcnt++;
    8000238c:	40bc                	lw	a5,64(s1)
    8000238e:	2785                	addiw	a5,a5,1
    80002390:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002392:	0000c517          	auipc	a0,0xc
    80002396:	7b650513          	addi	a0,a0,1974 # 8000eb48 <bcache>
    8000239a:	00004097          	auipc	ra,0x4
    8000239e:	e5e080e7          	jalr	-418(ra) # 800061f8 <release>
      acquiresleep(&b->lock);
    800023a2:	01048513          	addi	a0,s1,16
    800023a6:	00001097          	auipc	ra,0x1
    800023aa:	472080e7          	jalr	1138(ra) # 80003818 <acquiresleep>
      return b;
    800023ae:	a8b9                	j	8000240c <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800023b0:	00015497          	auipc	s1,0x15
    800023b4:	a484b483          	ld	s1,-1464(s1) # 80016df8 <bcache+0x82b0>
    800023b8:	00015797          	auipc	a5,0x15
    800023bc:	9f878793          	addi	a5,a5,-1544 # 80016db0 <bcache+0x8268>
    800023c0:	00f48863          	beq	s1,a5,800023d0 <bread+0x90>
    800023c4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800023c6:	40bc                	lw	a5,64(s1)
    800023c8:	cf81                	beqz	a5,800023e0 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800023ca:	64a4                	ld	s1,72(s1)
    800023cc:	fee49de3          	bne	s1,a4,800023c6 <bread+0x86>
  panic("bget: no buffers");
    800023d0:	00006517          	auipc	a0,0x6
    800023d4:	0c050513          	addi	a0,a0,192 # 80008490 <syscalls+0xc0>
    800023d8:	00004097          	auipc	ra,0x4
    800023dc:	834080e7          	jalr	-1996(ra) # 80005c0c <panic>
      b->dev = dev;
    800023e0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800023e4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800023e8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800023ec:	4785                	li	a5,1
    800023ee:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800023f0:	0000c517          	auipc	a0,0xc
    800023f4:	75850513          	addi	a0,a0,1880 # 8000eb48 <bcache>
    800023f8:	00004097          	auipc	ra,0x4
    800023fc:	e00080e7          	jalr	-512(ra) # 800061f8 <release>
      acquiresleep(&b->lock);
    80002400:	01048513          	addi	a0,s1,16
    80002404:	00001097          	auipc	ra,0x1
    80002408:	414080e7          	jalr	1044(ra) # 80003818 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000240c:	409c                	lw	a5,0(s1)
    8000240e:	cb89                	beqz	a5,80002420 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002410:	8526                	mv	a0,s1
    80002412:	70a2                	ld	ra,40(sp)
    80002414:	7402                	ld	s0,32(sp)
    80002416:	64e2                	ld	s1,24(sp)
    80002418:	6942                	ld	s2,16(sp)
    8000241a:	69a2                	ld	s3,8(sp)
    8000241c:	6145                	addi	sp,sp,48
    8000241e:	8082                	ret
    virtio_disk_rw(b, 0);
    80002420:	4581                	li	a1,0
    80002422:	8526                	mv	a0,s1
    80002424:	00003097          	auipc	ra,0x3
    80002428:	fde080e7          	jalr	-34(ra) # 80005402 <virtio_disk_rw>
    b->valid = 1;
    8000242c:	4785                	li	a5,1
    8000242e:	c09c                	sw	a5,0(s1)
  return b;
    80002430:	b7c5                	j	80002410 <bread+0xd0>

0000000080002432 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002432:	1101                	addi	sp,sp,-32
    80002434:	ec06                	sd	ra,24(sp)
    80002436:	e822                	sd	s0,16(sp)
    80002438:	e426                	sd	s1,8(sp)
    8000243a:	1000                	addi	s0,sp,32
    8000243c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000243e:	0541                	addi	a0,a0,16
    80002440:	00001097          	auipc	ra,0x1
    80002444:	472080e7          	jalr	1138(ra) # 800038b2 <holdingsleep>
    80002448:	cd01                	beqz	a0,80002460 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000244a:	4585                	li	a1,1
    8000244c:	8526                	mv	a0,s1
    8000244e:	00003097          	auipc	ra,0x3
    80002452:	fb4080e7          	jalr	-76(ra) # 80005402 <virtio_disk_rw>
}
    80002456:	60e2                	ld	ra,24(sp)
    80002458:	6442                	ld	s0,16(sp)
    8000245a:	64a2                	ld	s1,8(sp)
    8000245c:	6105                	addi	sp,sp,32
    8000245e:	8082                	ret
    panic("bwrite");
    80002460:	00006517          	auipc	a0,0x6
    80002464:	04850513          	addi	a0,a0,72 # 800084a8 <syscalls+0xd8>
    80002468:	00003097          	auipc	ra,0x3
    8000246c:	7a4080e7          	jalr	1956(ra) # 80005c0c <panic>

0000000080002470 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002470:	1101                	addi	sp,sp,-32
    80002472:	ec06                	sd	ra,24(sp)
    80002474:	e822                	sd	s0,16(sp)
    80002476:	e426                	sd	s1,8(sp)
    80002478:	e04a                	sd	s2,0(sp)
    8000247a:	1000                	addi	s0,sp,32
    8000247c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000247e:	01050913          	addi	s2,a0,16
    80002482:	854a                	mv	a0,s2
    80002484:	00001097          	auipc	ra,0x1
    80002488:	42e080e7          	jalr	1070(ra) # 800038b2 <holdingsleep>
    8000248c:	c92d                	beqz	a0,800024fe <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000248e:	854a                	mv	a0,s2
    80002490:	00001097          	auipc	ra,0x1
    80002494:	3de080e7          	jalr	990(ra) # 8000386e <releasesleep>

  acquire(&bcache.lock);
    80002498:	0000c517          	auipc	a0,0xc
    8000249c:	6b050513          	addi	a0,a0,1712 # 8000eb48 <bcache>
    800024a0:	00004097          	auipc	ra,0x4
    800024a4:	ca4080e7          	jalr	-860(ra) # 80006144 <acquire>
  b->refcnt--;
    800024a8:	40bc                	lw	a5,64(s1)
    800024aa:	37fd                	addiw	a5,a5,-1
    800024ac:	0007871b          	sext.w	a4,a5
    800024b0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800024b2:	eb05                	bnez	a4,800024e2 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800024b4:	68bc                	ld	a5,80(s1)
    800024b6:	64b8                	ld	a4,72(s1)
    800024b8:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800024ba:	64bc                	ld	a5,72(s1)
    800024bc:	68b8                	ld	a4,80(s1)
    800024be:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800024c0:	00014797          	auipc	a5,0x14
    800024c4:	68878793          	addi	a5,a5,1672 # 80016b48 <bcache+0x8000>
    800024c8:	2b87b703          	ld	a4,696(a5)
    800024cc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800024ce:	00015717          	auipc	a4,0x15
    800024d2:	8e270713          	addi	a4,a4,-1822 # 80016db0 <bcache+0x8268>
    800024d6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800024d8:	2b87b703          	ld	a4,696(a5)
    800024dc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800024de:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800024e2:	0000c517          	auipc	a0,0xc
    800024e6:	66650513          	addi	a0,a0,1638 # 8000eb48 <bcache>
    800024ea:	00004097          	auipc	ra,0x4
    800024ee:	d0e080e7          	jalr	-754(ra) # 800061f8 <release>
}
    800024f2:	60e2                	ld	ra,24(sp)
    800024f4:	6442                	ld	s0,16(sp)
    800024f6:	64a2                	ld	s1,8(sp)
    800024f8:	6902                	ld	s2,0(sp)
    800024fa:	6105                	addi	sp,sp,32
    800024fc:	8082                	ret
    panic("brelse");
    800024fe:	00006517          	auipc	a0,0x6
    80002502:	fb250513          	addi	a0,a0,-78 # 800084b0 <syscalls+0xe0>
    80002506:	00003097          	auipc	ra,0x3
    8000250a:	706080e7          	jalr	1798(ra) # 80005c0c <panic>

000000008000250e <bpin>:

void
bpin(struct buf *b) {
    8000250e:	1101                	addi	sp,sp,-32
    80002510:	ec06                	sd	ra,24(sp)
    80002512:	e822                	sd	s0,16(sp)
    80002514:	e426                	sd	s1,8(sp)
    80002516:	1000                	addi	s0,sp,32
    80002518:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000251a:	0000c517          	auipc	a0,0xc
    8000251e:	62e50513          	addi	a0,a0,1582 # 8000eb48 <bcache>
    80002522:	00004097          	auipc	ra,0x4
    80002526:	c22080e7          	jalr	-990(ra) # 80006144 <acquire>
  b->refcnt++;
    8000252a:	40bc                	lw	a5,64(s1)
    8000252c:	2785                	addiw	a5,a5,1
    8000252e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002530:	0000c517          	auipc	a0,0xc
    80002534:	61850513          	addi	a0,a0,1560 # 8000eb48 <bcache>
    80002538:	00004097          	auipc	ra,0x4
    8000253c:	cc0080e7          	jalr	-832(ra) # 800061f8 <release>
}
    80002540:	60e2                	ld	ra,24(sp)
    80002542:	6442                	ld	s0,16(sp)
    80002544:	64a2                	ld	s1,8(sp)
    80002546:	6105                	addi	sp,sp,32
    80002548:	8082                	ret

000000008000254a <bunpin>:

void
bunpin(struct buf *b) {
    8000254a:	1101                	addi	sp,sp,-32
    8000254c:	ec06                	sd	ra,24(sp)
    8000254e:	e822                	sd	s0,16(sp)
    80002550:	e426                	sd	s1,8(sp)
    80002552:	1000                	addi	s0,sp,32
    80002554:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002556:	0000c517          	auipc	a0,0xc
    8000255a:	5f250513          	addi	a0,a0,1522 # 8000eb48 <bcache>
    8000255e:	00004097          	auipc	ra,0x4
    80002562:	be6080e7          	jalr	-1050(ra) # 80006144 <acquire>
  b->refcnt--;
    80002566:	40bc                	lw	a5,64(s1)
    80002568:	37fd                	addiw	a5,a5,-1
    8000256a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000256c:	0000c517          	auipc	a0,0xc
    80002570:	5dc50513          	addi	a0,a0,1500 # 8000eb48 <bcache>
    80002574:	00004097          	auipc	ra,0x4
    80002578:	c84080e7          	jalr	-892(ra) # 800061f8 <release>
}
    8000257c:	60e2                	ld	ra,24(sp)
    8000257e:	6442                	ld	s0,16(sp)
    80002580:	64a2                	ld	s1,8(sp)
    80002582:	6105                	addi	sp,sp,32
    80002584:	8082                	ret

0000000080002586 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002586:	1101                	addi	sp,sp,-32
    80002588:	ec06                	sd	ra,24(sp)
    8000258a:	e822                	sd	s0,16(sp)
    8000258c:	e426                	sd	s1,8(sp)
    8000258e:	e04a                	sd	s2,0(sp)
    80002590:	1000                	addi	s0,sp,32
    80002592:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002594:	00d5d59b          	srliw	a1,a1,0xd
    80002598:	00015797          	auipc	a5,0x15
    8000259c:	c8c7a783          	lw	a5,-884(a5) # 80017224 <sb+0x1c>
    800025a0:	9dbd                	addw	a1,a1,a5
    800025a2:	00000097          	auipc	ra,0x0
    800025a6:	d9e080e7          	jalr	-610(ra) # 80002340 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800025aa:	0074f713          	andi	a4,s1,7
    800025ae:	4785                	li	a5,1
    800025b0:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800025b4:	14ce                	slli	s1,s1,0x33
    800025b6:	90d9                	srli	s1,s1,0x36
    800025b8:	00950733          	add	a4,a0,s1
    800025bc:	05874703          	lbu	a4,88(a4)
    800025c0:	00e7f6b3          	and	a3,a5,a4
    800025c4:	c69d                	beqz	a3,800025f2 <bfree+0x6c>
    800025c6:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800025c8:	94aa                	add	s1,s1,a0
    800025ca:	fff7c793          	not	a5,a5
    800025ce:	8f7d                	and	a4,a4,a5
    800025d0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800025d4:	00001097          	auipc	ra,0x1
    800025d8:	126080e7          	jalr	294(ra) # 800036fa <log_write>
  brelse(bp);
    800025dc:	854a                	mv	a0,s2
    800025de:	00000097          	auipc	ra,0x0
    800025e2:	e92080e7          	jalr	-366(ra) # 80002470 <brelse>
}
    800025e6:	60e2                	ld	ra,24(sp)
    800025e8:	6442                	ld	s0,16(sp)
    800025ea:	64a2                	ld	s1,8(sp)
    800025ec:	6902                	ld	s2,0(sp)
    800025ee:	6105                	addi	sp,sp,32
    800025f0:	8082                	ret
    panic("freeing free block");
    800025f2:	00006517          	auipc	a0,0x6
    800025f6:	ec650513          	addi	a0,a0,-314 # 800084b8 <syscalls+0xe8>
    800025fa:	00003097          	auipc	ra,0x3
    800025fe:	612080e7          	jalr	1554(ra) # 80005c0c <panic>

0000000080002602 <balloc>:
{
    80002602:	711d                	addi	sp,sp,-96
    80002604:	ec86                	sd	ra,88(sp)
    80002606:	e8a2                	sd	s0,80(sp)
    80002608:	e4a6                	sd	s1,72(sp)
    8000260a:	e0ca                	sd	s2,64(sp)
    8000260c:	fc4e                	sd	s3,56(sp)
    8000260e:	f852                	sd	s4,48(sp)
    80002610:	f456                	sd	s5,40(sp)
    80002612:	f05a                	sd	s6,32(sp)
    80002614:	ec5e                	sd	s7,24(sp)
    80002616:	e862                	sd	s8,16(sp)
    80002618:	e466                	sd	s9,8(sp)
    8000261a:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000261c:	00015797          	auipc	a5,0x15
    80002620:	bf07a783          	lw	a5,-1040(a5) # 8001720c <sb+0x4>
    80002624:	cff5                	beqz	a5,80002720 <balloc+0x11e>
    80002626:	8baa                	mv	s7,a0
    80002628:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000262a:	00015b17          	auipc	s6,0x15
    8000262e:	bdeb0b13          	addi	s6,s6,-1058 # 80017208 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002632:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002634:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002636:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002638:	6c89                	lui	s9,0x2
    8000263a:	a061                	j	800026c2 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000263c:	97ca                	add	a5,a5,s2
    8000263e:	8e55                	or	a2,a2,a3
    80002640:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002644:	854a                	mv	a0,s2
    80002646:	00001097          	auipc	ra,0x1
    8000264a:	0b4080e7          	jalr	180(ra) # 800036fa <log_write>
        brelse(bp);
    8000264e:	854a                	mv	a0,s2
    80002650:	00000097          	auipc	ra,0x0
    80002654:	e20080e7          	jalr	-480(ra) # 80002470 <brelse>
  bp = bread(dev, bno);
    80002658:	85a6                	mv	a1,s1
    8000265a:	855e                	mv	a0,s7
    8000265c:	00000097          	auipc	ra,0x0
    80002660:	ce4080e7          	jalr	-796(ra) # 80002340 <bread>
    80002664:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002666:	40000613          	li	a2,1024
    8000266a:	4581                	li	a1,0
    8000266c:	05850513          	addi	a0,a0,88
    80002670:	ffffe097          	auipc	ra,0xffffe
    80002674:	b0a080e7          	jalr	-1270(ra) # 8000017a <memset>
  log_write(bp);
    80002678:	854a                	mv	a0,s2
    8000267a:	00001097          	auipc	ra,0x1
    8000267e:	080080e7          	jalr	128(ra) # 800036fa <log_write>
  brelse(bp);
    80002682:	854a                	mv	a0,s2
    80002684:	00000097          	auipc	ra,0x0
    80002688:	dec080e7          	jalr	-532(ra) # 80002470 <brelse>
}
    8000268c:	8526                	mv	a0,s1
    8000268e:	60e6                	ld	ra,88(sp)
    80002690:	6446                	ld	s0,80(sp)
    80002692:	64a6                	ld	s1,72(sp)
    80002694:	6906                	ld	s2,64(sp)
    80002696:	79e2                	ld	s3,56(sp)
    80002698:	7a42                	ld	s4,48(sp)
    8000269a:	7aa2                	ld	s5,40(sp)
    8000269c:	7b02                	ld	s6,32(sp)
    8000269e:	6be2                	ld	s7,24(sp)
    800026a0:	6c42                	ld	s8,16(sp)
    800026a2:	6ca2                	ld	s9,8(sp)
    800026a4:	6125                	addi	sp,sp,96
    800026a6:	8082                	ret
    brelse(bp);
    800026a8:	854a                	mv	a0,s2
    800026aa:	00000097          	auipc	ra,0x0
    800026ae:	dc6080e7          	jalr	-570(ra) # 80002470 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800026b2:	015c87bb          	addw	a5,s9,s5
    800026b6:	00078a9b          	sext.w	s5,a5
    800026ba:	004b2703          	lw	a4,4(s6)
    800026be:	06eaf163          	bgeu	s5,a4,80002720 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800026c2:	41fad79b          	sraiw	a5,s5,0x1f
    800026c6:	0137d79b          	srliw	a5,a5,0x13
    800026ca:	015787bb          	addw	a5,a5,s5
    800026ce:	40d7d79b          	sraiw	a5,a5,0xd
    800026d2:	01cb2583          	lw	a1,28(s6)
    800026d6:	9dbd                	addw	a1,a1,a5
    800026d8:	855e                	mv	a0,s7
    800026da:	00000097          	auipc	ra,0x0
    800026de:	c66080e7          	jalr	-922(ra) # 80002340 <bread>
    800026e2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800026e4:	004b2503          	lw	a0,4(s6)
    800026e8:	000a849b          	sext.w	s1,s5
    800026ec:	8762                	mv	a4,s8
    800026ee:	faa4fde3          	bgeu	s1,a0,800026a8 <balloc+0xa6>
      m = 1 << (bi % 8);
    800026f2:	00777693          	andi	a3,a4,7
    800026f6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800026fa:	41f7579b          	sraiw	a5,a4,0x1f
    800026fe:	01d7d79b          	srliw	a5,a5,0x1d
    80002702:	9fb9                	addw	a5,a5,a4
    80002704:	4037d79b          	sraiw	a5,a5,0x3
    80002708:	00f90633          	add	a2,s2,a5
    8000270c:	05864603          	lbu	a2,88(a2)
    80002710:	00c6f5b3          	and	a1,a3,a2
    80002714:	d585                	beqz	a1,8000263c <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002716:	2705                	addiw	a4,a4,1
    80002718:	2485                	addiw	s1,s1,1
    8000271a:	fd471ae3          	bne	a4,s4,800026ee <balloc+0xec>
    8000271e:	b769                	j	800026a8 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80002720:	00006517          	auipc	a0,0x6
    80002724:	db050513          	addi	a0,a0,-592 # 800084d0 <syscalls+0x100>
    80002728:	00003097          	auipc	ra,0x3
    8000272c:	52e080e7          	jalr	1326(ra) # 80005c56 <printf>
  return 0;
    80002730:	4481                	li	s1,0
    80002732:	bfa9                	j	8000268c <balloc+0x8a>

0000000080002734 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002734:	7179                	addi	sp,sp,-48
    80002736:	f406                	sd	ra,40(sp)
    80002738:	f022                	sd	s0,32(sp)
    8000273a:	ec26                	sd	s1,24(sp)
    8000273c:	e84a                	sd	s2,16(sp)
    8000273e:	e44e                	sd	s3,8(sp)
    80002740:	e052                	sd	s4,0(sp)
    80002742:	1800                	addi	s0,sp,48
    80002744:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002746:	47ad                	li	a5,11
    80002748:	02b7e863          	bltu	a5,a1,80002778 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    8000274c:	02059793          	slli	a5,a1,0x20
    80002750:	01e7d593          	srli	a1,a5,0x1e
    80002754:	00b504b3          	add	s1,a0,a1
    80002758:	0504a903          	lw	s2,80(s1)
    8000275c:	06091e63          	bnez	s2,800027d8 <bmap+0xa4>
      addr = balloc(ip->dev);
    80002760:	4108                	lw	a0,0(a0)
    80002762:	00000097          	auipc	ra,0x0
    80002766:	ea0080e7          	jalr	-352(ra) # 80002602 <balloc>
    8000276a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000276e:	06090563          	beqz	s2,800027d8 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80002772:	0524a823          	sw	s2,80(s1)
    80002776:	a08d                	j	800027d8 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002778:	ff45849b          	addiw	s1,a1,-12
    8000277c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002780:	0ff00793          	li	a5,255
    80002784:	08e7e563          	bltu	a5,a4,8000280e <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002788:	08052903          	lw	s2,128(a0)
    8000278c:	00091d63          	bnez	s2,800027a6 <bmap+0x72>
      addr = balloc(ip->dev);
    80002790:	4108                	lw	a0,0(a0)
    80002792:	00000097          	auipc	ra,0x0
    80002796:	e70080e7          	jalr	-400(ra) # 80002602 <balloc>
    8000279a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000279e:	02090d63          	beqz	s2,800027d8 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800027a2:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800027a6:	85ca                	mv	a1,s2
    800027a8:	0009a503          	lw	a0,0(s3)
    800027ac:	00000097          	auipc	ra,0x0
    800027b0:	b94080e7          	jalr	-1132(ra) # 80002340 <bread>
    800027b4:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800027b6:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800027ba:	02049713          	slli	a4,s1,0x20
    800027be:	01e75593          	srli	a1,a4,0x1e
    800027c2:	00b784b3          	add	s1,a5,a1
    800027c6:	0004a903          	lw	s2,0(s1)
    800027ca:	02090063          	beqz	s2,800027ea <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800027ce:	8552                	mv	a0,s4
    800027d0:	00000097          	auipc	ra,0x0
    800027d4:	ca0080e7          	jalr	-864(ra) # 80002470 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800027d8:	854a                	mv	a0,s2
    800027da:	70a2                	ld	ra,40(sp)
    800027dc:	7402                	ld	s0,32(sp)
    800027de:	64e2                	ld	s1,24(sp)
    800027e0:	6942                	ld	s2,16(sp)
    800027e2:	69a2                	ld	s3,8(sp)
    800027e4:	6a02                	ld	s4,0(sp)
    800027e6:	6145                	addi	sp,sp,48
    800027e8:	8082                	ret
      addr = balloc(ip->dev);
    800027ea:	0009a503          	lw	a0,0(s3)
    800027ee:	00000097          	auipc	ra,0x0
    800027f2:	e14080e7          	jalr	-492(ra) # 80002602 <balloc>
    800027f6:	0005091b          	sext.w	s2,a0
      if(addr){
    800027fa:	fc090ae3          	beqz	s2,800027ce <bmap+0x9a>
        a[bn] = addr;
    800027fe:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002802:	8552                	mv	a0,s4
    80002804:	00001097          	auipc	ra,0x1
    80002808:	ef6080e7          	jalr	-266(ra) # 800036fa <log_write>
    8000280c:	b7c9                	j	800027ce <bmap+0x9a>
  panic("bmap: out of range");
    8000280e:	00006517          	auipc	a0,0x6
    80002812:	cda50513          	addi	a0,a0,-806 # 800084e8 <syscalls+0x118>
    80002816:	00003097          	auipc	ra,0x3
    8000281a:	3f6080e7          	jalr	1014(ra) # 80005c0c <panic>

000000008000281e <iget>:
{
    8000281e:	7179                	addi	sp,sp,-48
    80002820:	f406                	sd	ra,40(sp)
    80002822:	f022                	sd	s0,32(sp)
    80002824:	ec26                	sd	s1,24(sp)
    80002826:	e84a                	sd	s2,16(sp)
    80002828:	e44e                	sd	s3,8(sp)
    8000282a:	e052                	sd	s4,0(sp)
    8000282c:	1800                	addi	s0,sp,48
    8000282e:	89aa                	mv	s3,a0
    80002830:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002832:	00015517          	auipc	a0,0x15
    80002836:	9f650513          	addi	a0,a0,-1546 # 80017228 <itable>
    8000283a:	00004097          	auipc	ra,0x4
    8000283e:	90a080e7          	jalr	-1782(ra) # 80006144 <acquire>
  empty = 0;
    80002842:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002844:	00015497          	auipc	s1,0x15
    80002848:	9fc48493          	addi	s1,s1,-1540 # 80017240 <itable+0x18>
    8000284c:	00016697          	auipc	a3,0x16
    80002850:	48468693          	addi	a3,a3,1156 # 80018cd0 <log>
    80002854:	a039                	j	80002862 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002856:	02090b63          	beqz	s2,8000288c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000285a:	08848493          	addi	s1,s1,136
    8000285e:	02d48a63          	beq	s1,a3,80002892 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002862:	449c                	lw	a5,8(s1)
    80002864:	fef059e3          	blez	a5,80002856 <iget+0x38>
    80002868:	4098                	lw	a4,0(s1)
    8000286a:	ff3716e3          	bne	a4,s3,80002856 <iget+0x38>
    8000286e:	40d8                	lw	a4,4(s1)
    80002870:	ff4713e3          	bne	a4,s4,80002856 <iget+0x38>
      ip->ref++;
    80002874:	2785                	addiw	a5,a5,1
    80002876:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002878:	00015517          	auipc	a0,0x15
    8000287c:	9b050513          	addi	a0,a0,-1616 # 80017228 <itable>
    80002880:	00004097          	auipc	ra,0x4
    80002884:	978080e7          	jalr	-1672(ra) # 800061f8 <release>
      return ip;
    80002888:	8926                	mv	s2,s1
    8000288a:	a03d                	j	800028b8 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000288c:	f7f9                	bnez	a5,8000285a <iget+0x3c>
    8000288e:	8926                	mv	s2,s1
    80002890:	b7e9                	j	8000285a <iget+0x3c>
  if(empty == 0)
    80002892:	02090c63          	beqz	s2,800028ca <iget+0xac>
  ip->dev = dev;
    80002896:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000289a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000289e:	4785                	li	a5,1
    800028a0:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800028a4:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800028a8:	00015517          	auipc	a0,0x15
    800028ac:	98050513          	addi	a0,a0,-1664 # 80017228 <itable>
    800028b0:	00004097          	auipc	ra,0x4
    800028b4:	948080e7          	jalr	-1720(ra) # 800061f8 <release>
}
    800028b8:	854a                	mv	a0,s2
    800028ba:	70a2                	ld	ra,40(sp)
    800028bc:	7402                	ld	s0,32(sp)
    800028be:	64e2                	ld	s1,24(sp)
    800028c0:	6942                	ld	s2,16(sp)
    800028c2:	69a2                	ld	s3,8(sp)
    800028c4:	6a02                	ld	s4,0(sp)
    800028c6:	6145                	addi	sp,sp,48
    800028c8:	8082                	ret
    panic("iget: no inodes");
    800028ca:	00006517          	auipc	a0,0x6
    800028ce:	c3650513          	addi	a0,a0,-970 # 80008500 <syscalls+0x130>
    800028d2:	00003097          	auipc	ra,0x3
    800028d6:	33a080e7          	jalr	826(ra) # 80005c0c <panic>

00000000800028da <fsinit>:
fsinit(int dev) {
    800028da:	7179                	addi	sp,sp,-48
    800028dc:	f406                	sd	ra,40(sp)
    800028de:	f022                	sd	s0,32(sp)
    800028e0:	ec26                	sd	s1,24(sp)
    800028e2:	e84a                	sd	s2,16(sp)
    800028e4:	e44e                	sd	s3,8(sp)
    800028e6:	1800                	addi	s0,sp,48
    800028e8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800028ea:	4585                	li	a1,1
    800028ec:	00000097          	auipc	ra,0x0
    800028f0:	a54080e7          	jalr	-1452(ra) # 80002340 <bread>
    800028f4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800028f6:	00015997          	auipc	s3,0x15
    800028fa:	91298993          	addi	s3,s3,-1774 # 80017208 <sb>
    800028fe:	02000613          	li	a2,32
    80002902:	05850593          	addi	a1,a0,88
    80002906:	854e                	mv	a0,s3
    80002908:	ffffe097          	auipc	ra,0xffffe
    8000290c:	8ce080e7          	jalr	-1842(ra) # 800001d6 <memmove>
  brelse(bp);
    80002910:	8526                	mv	a0,s1
    80002912:	00000097          	auipc	ra,0x0
    80002916:	b5e080e7          	jalr	-1186(ra) # 80002470 <brelse>
  if(sb.magic != FSMAGIC)
    8000291a:	0009a703          	lw	a4,0(s3)
    8000291e:	102037b7          	lui	a5,0x10203
    80002922:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002926:	02f71263          	bne	a4,a5,8000294a <fsinit+0x70>
  initlog(dev, &sb);
    8000292a:	00015597          	auipc	a1,0x15
    8000292e:	8de58593          	addi	a1,a1,-1826 # 80017208 <sb>
    80002932:	854a                	mv	a0,s2
    80002934:	00001097          	auipc	ra,0x1
    80002938:	b4a080e7          	jalr	-1206(ra) # 8000347e <initlog>
}
    8000293c:	70a2                	ld	ra,40(sp)
    8000293e:	7402                	ld	s0,32(sp)
    80002940:	64e2                	ld	s1,24(sp)
    80002942:	6942                	ld	s2,16(sp)
    80002944:	69a2                	ld	s3,8(sp)
    80002946:	6145                	addi	sp,sp,48
    80002948:	8082                	ret
    panic("invalid file system");
    8000294a:	00006517          	auipc	a0,0x6
    8000294e:	bc650513          	addi	a0,a0,-1082 # 80008510 <syscalls+0x140>
    80002952:	00003097          	auipc	ra,0x3
    80002956:	2ba080e7          	jalr	698(ra) # 80005c0c <panic>

000000008000295a <iinit>:
{
    8000295a:	7179                	addi	sp,sp,-48
    8000295c:	f406                	sd	ra,40(sp)
    8000295e:	f022                	sd	s0,32(sp)
    80002960:	ec26                	sd	s1,24(sp)
    80002962:	e84a                	sd	s2,16(sp)
    80002964:	e44e                	sd	s3,8(sp)
    80002966:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002968:	00006597          	auipc	a1,0x6
    8000296c:	bc058593          	addi	a1,a1,-1088 # 80008528 <syscalls+0x158>
    80002970:	00015517          	auipc	a0,0x15
    80002974:	8b850513          	addi	a0,a0,-1864 # 80017228 <itable>
    80002978:	00003097          	auipc	ra,0x3
    8000297c:	73c080e7          	jalr	1852(ra) # 800060b4 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002980:	00015497          	auipc	s1,0x15
    80002984:	8d048493          	addi	s1,s1,-1840 # 80017250 <itable+0x28>
    80002988:	00016997          	auipc	s3,0x16
    8000298c:	35898993          	addi	s3,s3,856 # 80018ce0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002990:	00006917          	auipc	s2,0x6
    80002994:	ba090913          	addi	s2,s2,-1120 # 80008530 <syscalls+0x160>
    80002998:	85ca                	mv	a1,s2
    8000299a:	8526                	mv	a0,s1
    8000299c:	00001097          	auipc	ra,0x1
    800029a0:	e42080e7          	jalr	-446(ra) # 800037de <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800029a4:	08848493          	addi	s1,s1,136
    800029a8:	ff3498e3          	bne	s1,s3,80002998 <iinit+0x3e>
}
    800029ac:	70a2                	ld	ra,40(sp)
    800029ae:	7402                	ld	s0,32(sp)
    800029b0:	64e2                	ld	s1,24(sp)
    800029b2:	6942                	ld	s2,16(sp)
    800029b4:	69a2                	ld	s3,8(sp)
    800029b6:	6145                	addi	sp,sp,48
    800029b8:	8082                	ret

00000000800029ba <ialloc>:
{
    800029ba:	715d                	addi	sp,sp,-80
    800029bc:	e486                	sd	ra,72(sp)
    800029be:	e0a2                	sd	s0,64(sp)
    800029c0:	fc26                	sd	s1,56(sp)
    800029c2:	f84a                	sd	s2,48(sp)
    800029c4:	f44e                	sd	s3,40(sp)
    800029c6:	f052                	sd	s4,32(sp)
    800029c8:	ec56                	sd	s5,24(sp)
    800029ca:	e85a                	sd	s6,16(sp)
    800029cc:	e45e                	sd	s7,8(sp)
    800029ce:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800029d0:	00015717          	auipc	a4,0x15
    800029d4:	84472703          	lw	a4,-1980(a4) # 80017214 <sb+0xc>
    800029d8:	4785                	li	a5,1
    800029da:	04e7fa63          	bgeu	a5,a4,80002a2e <ialloc+0x74>
    800029de:	8aaa                	mv	s5,a0
    800029e0:	8bae                	mv	s7,a1
    800029e2:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800029e4:	00015a17          	auipc	s4,0x15
    800029e8:	824a0a13          	addi	s4,s4,-2012 # 80017208 <sb>
    800029ec:	00048b1b          	sext.w	s6,s1
    800029f0:	0044d593          	srli	a1,s1,0x4
    800029f4:	018a2783          	lw	a5,24(s4)
    800029f8:	9dbd                	addw	a1,a1,a5
    800029fa:	8556                	mv	a0,s5
    800029fc:	00000097          	auipc	ra,0x0
    80002a00:	944080e7          	jalr	-1724(ra) # 80002340 <bread>
    80002a04:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002a06:	05850993          	addi	s3,a0,88
    80002a0a:	00f4f793          	andi	a5,s1,15
    80002a0e:	079a                	slli	a5,a5,0x6
    80002a10:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002a12:	00099783          	lh	a5,0(s3)
    80002a16:	c3a1                	beqz	a5,80002a56 <ialloc+0x9c>
    brelse(bp);
    80002a18:	00000097          	auipc	ra,0x0
    80002a1c:	a58080e7          	jalr	-1448(ra) # 80002470 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a20:	0485                	addi	s1,s1,1
    80002a22:	00ca2703          	lw	a4,12(s4)
    80002a26:	0004879b          	sext.w	a5,s1
    80002a2a:	fce7e1e3          	bltu	a5,a4,800029ec <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002a2e:	00006517          	auipc	a0,0x6
    80002a32:	b0a50513          	addi	a0,a0,-1270 # 80008538 <syscalls+0x168>
    80002a36:	00003097          	auipc	ra,0x3
    80002a3a:	220080e7          	jalr	544(ra) # 80005c56 <printf>
  return 0;
    80002a3e:	4501                	li	a0,0
}
    80002a40:	60a6                	ld	ra,72(sp)
    80002a42:	6406                	ld	s0,64(sp)
    80002a44:	74e2                	ld	s1,56(sp)
    80002a46:	7942                	ld	s2,48(sp)
    80002a48:	79a2                	ld	s3,40(sp)
    80002a4a:	7a02                	ld	s4,32(sp)
    80002a4c:	6ae2                	ld	s5,24(sp)
    80002a4e:	6b42                	ld	s6,16(sp)
    80002a50:	6ba2                	ld	s7,8(sp)
    80002a52:	6161                	addi	sp,sp,80
    80002a54:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002a56:	04000613          	li	a2,64
    80002a5a:	4581                	li	a1,0
    80002a5c:	854e                	mv	a0,s3
    80002a5e:	ffffd097          	auipc	ra,0xffffd
    80002a62:	71c080e7          	jalr	1820(ra) # 8000017a <memset>
      dip->type = type;
    80002a66:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002a6a:	854a                	mv	a0,s2
    80002a6c:	00001097          	auipc	ra,0x1
    80002a70:	c8e080e7          	jalr	-882(ra) # 800036fa <log_write>
      brelse(bp);
    80002a74:	854a                	mv	a0,s2
    80002a76:	00000097          	auipc	ra,0x0
    80002a7a:	9fa080e7          	jalr	-1542(ra) # 80002470 <brelse>
      return iget(dev, inum);
    80002a7e:	85da                	mv	a1,s6
    80002a80:	8556                	mv	a0,s5
    80002a82:	00000097          	auipc	ra,0x0
    80002a86:	d9c080e7          	jalr	-612(ra) # 8000281e <iget>
    80002a8a:	bf5d                	j	80002a40 <ialloc+0x86>

0000000080002a8c <iupdate>:
{
    80002a8c:	1101                	addi	sp,sp,-32
    80002a8e:	ec06                	sd	ra,24(sp)
    80002a90:	e822                	sd	s0,16(sp)
    80002a92:	e426                	sd	s1,8(sp)
    80002a94:	e04a                	sd	s2,0(sp)
    80002a96:	1000                	addi	s0,sp,32
    80002a98:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002a9a:	415c                	lw	a5,4(a0)
    80002a9c:	0047d79b          	srliw	a5,a5,0x4
    80002aa0:	00014597          	auipc	a1,0x14
    80002aa4:	7805a583          	lw	a1,1920(a1) # 80017220 <sb+0x18>
    80002aa8:	9dbd                	addw	a1,a1,a5
    80002aaa:	4108                	lw	a0,0(a0)
    80002aac:	00000097          	auipc	ra,0x0
    80002ab0:	894080e7          	jalr	-1900(ra) # 80002340 <bread>
    80002ab4:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002ab6:	05850793          	addi	a5,a0,88
    80002aba:	40d8                	lw	a4,4(s1)
    80002abc:	8b3d                	andi	a4,a4,15
    80002abe:	071a                	slli	a4,a4,0x6
    80002ac0:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002ac2:	04449703          	lh	a4,68(s1)
    80002ac6:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002aca:	04649703          	lh	a4,70(s1)
    80002ace:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002ad2:	04849703          	lh	a4,72(s1)
    80002ad6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002ada:	04a49703          	lh	a4,74(s1)
    80002ade:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002ae2:	44f8                	lw	a4,76(s1)
    80002ae4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002ae6:	03400613          	li	a2,52
    80002aea:	05048593          	addi	a1,s1,80
    80002aee:	00c78513          	addi	a0,a5,12
    80002af2:	ffffd097          	auipc	ra,0xffffd
    80002af6:	6e4080e7          	jalr	1764(ra) # 800001d6 <memmove>
  log_write(bp);
    80002afa:	854a                	mv	a0,s2
    80002afc:	00001097          	auipc	ra,0x1
    80002b00:	bfe080e7          	jalr	-1026(ra) # 800036fa <log_write>
  brelse(bp);
    80002b04:	854a                	mv	a0,s2
    80002b06:	00000097          	auipc	ra,0x0
    80002b0a:	96a080e7          	jalr	-1686(ra) # 80002470 <brelse>
}
    80002b0e:	60e2                	ld	ra,24(sp)
    80002b10:	6442                	ld	s0,16(sp)
    80002b12:	64a2                	ld	s1,8(sp)
    80002b14:	6902                	ld	s2,0(sp)
    80002b16:	6105                	addi	sp,sp,32
    80002b18:	8082                	ret

0000000080002b1a <idup>:
{
    80002b1a:	1101                	addi	sp,sp,-32
    80002b1c:	ec06                	sd	ra,24(sp)
    80002b1e:	e822                	sd	s0,16(sp)
    80002b20:	e426                	sd	s1,8(sp)
    80002b22:	1000                	addi	s0,sp,32
    80002b24:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002b26:	00014517          	auipc	a0,0x14
    80002b2a:	70250513          	addi	a0,a0,1794 # 80017228 <itable>
    80002b2e:	00003097          	auipc	ra,0x3
    80002b32:	616080e7          	jalr	1558(ra) # 80006144 <acquire>
  ip->ref++;
    80002b36:	449c                	lw	a5,8(s1)
    80002b38:	2785                	addiw	a5,a5,1
    80002b3a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002b3c:	00014517          	auipc	a0,0x14
    80002b40:	6ec50513          	addi	a0,a0,1772 # 80017228 <itable>
    80002b44:	00003097          	auipc	ra,0x3
    80002b48:	6b4080e7          	jalr	1716(ra) # 800061f8 <release>
}
    80002b4c:	8526                	mv	a0,s1
    80002b4e:	60e2                	ld	ra,24(sp)
    80002b50:	6442                	ld	s0,16(sp)
    80002b52:	64a2                	ld	s1,8(sp)
    80002b54:	6105                	addi	sp,sp,32
    80002b56:	8082                	ret

0000000080002b58 <ilock>:
{
    80002b58:	1101                	addi	sp,sp,-32
    80002b5a:	ec06                	sd	ra,24(sp)
    80002b5c:	e822                	sd	s0,16(sp)
    80002b5e:	e426                	sd	s1,8(sp)
    80002b60:	e04a                	sd	s2,0(sp)
    80002b62:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002b64:	c115                	beqz	a0,80002b88 <ilock+0x30>
    80002b66:	84aa                	mv	s1,a0
    80002b68:	451c                	lw	a5,8(a0)
    80002b6a:	00f05f63          	blez	a5,80002b88 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002b6e:	0541                	addi	a0,a0,16
    80002b70:	00001097          	auipc	ra,0x1
    80002b74:	ca8080e7          	jalr	-856(ra) # 80003818 <acquiresleep>
  if(ip->valid == 0){
    80002b78:	40bc                	lw	a5,64(s1)
    80002b7a:	cf99                	beqz	a5,80002b98 <ilock+0x40>
}
    80002b7c:	60e2                	ld	ra,24(sp)
    80002b7e:	6442                	ld	s0,16(sp)
    80002b80:	64a2                	ld	s1,8(sp)
    80002b82:	6902                	ld	s2,0(sp)
    80002b84:	6105                	addi	sp,sp,32
    80002b86:	8082                	ret
    panic("ilock");
    80002b88:	00006517          	auipc	a0,0x6
    80002b8c:	9c850513          	addi	a0,a0,-1592 # 80008550 <syscalls+0x180>
    80002b90:	00003097          	auipc	ra,0x3
    80002b94:	07c080e7          	jalr	124(ra) # 80005c0c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002b98:	40dc                	lw	a5,4(s1)
    80002b9a:	0047d79b          	srliw	a5,a5,0x4
    80002b9e:	00014597          	auipc	a1,0x14
    80002ba2:	6825a583          	lw	a1,1666(a1) # 80017220 <sb+0x18>
    80002ba6:	9dbd                	addw	a1,a1,a5
    80002ba8:	4088                	lw	a0,0(s1)
    80002baa:	fffff097          	auipc	ra,0xfffff
    80002bae:	796080e7          	jalr	1942(ra) # 80002340 <bread>
    80002bb2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002bb4:	05850593          	addi	a1,a0,88
    80002bb8:	40dc                	lw	a5,4(s1)
    80002bba:	8bbd                	andi	a5,a5,15
    80002bbc:	079a                	slli	a5,a5,0x6
    80002bbe:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002bc0:	00059783          	lh	a5,0(a1)
    80002bc4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002bc8:	00259783          	lh	a5,2(a1)
    80002bcc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002bd0:	00459783          	lh	a5,4(a1)
    80002bd4:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002bd8:	00659783          	lh	a5,6(a1)
    80002bdc:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002be0:	459c                	lw	a5,8(a1)
    80002be2:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002be4:	03400613          	li	a2,52
    80002be8:	05b1                	addi	a1,a1,12
    80002bea:	05048513          	addi	a0,s1,80
    80002bee:	ffffd097          	auipc	ra,0xffffd
    80002bf2:	5e8080e7          	jalr	1512(ra) # 800001d6 <memmove>
    brelse(bp);
    80002bf6:	854a                	mv	a0,s2
    80002bf8:	00000097          	auipc	ra,0x0
    80002bfc:	878080e7          	jalr	-1928(ra) # 80002470 <brelse>
    ip->valid = 1;
    80002c00:	4785                	li	a5,1
    80002c02:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002c04:	04449783          	lh	a5,68(s1)
    80002c08:	fbb5                	bnez	a5,80002b7c <ilock+0x24>
      panic("ilock: no type");
    80002c0a:	00006517          	auipc	a0,0x6
    80002c0e:	94e50513          	addi	a0,a0,-1714 # 80008558 <syscalls+0x188>
    80002c12:	00003097          	auipc	ra,0x3
    80002c16:	ffa080e7          	jalr	-6(ra) # 80005c0c <panic>

0000000080002c1a <iunlock>:
{
    80002c1a:	1101                	addi	sp,sp,-32
    80002c1c:	ec06                	sd	ra,24(sp)
    80002c1e:	e822                	sd	s0,16(sp)
    80002c20:	e426                	sd	s1,8(sp)
    80002c22:	e04a                	sd	s2,0(sp)
    80002c24:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002c26:	c905                	beqz	a0,80002c56 <iunlock+0x3c>
    80002c28:	84aa                	mv	s1,a0
    80002c2a:	01050913          	addi	s2,a0,16
    80002c2e:	854a                	mv	a0,s2
    80002c30:	00001097          	auipc	ra,0x1
    80002c34:	c82080e7          	jalr	-894(ra) # 800038b2 <holdingsleep>
    80002c38:	cd19                	beqz	a0,80002c56 <iunlock+0x3c>
    80002c3a:	449c                	lw	a5,8(s1)
    80002c3c:	00f05d63          	blez	a5,80002c56 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002c40:	854a                	mv	a0,s2
    80002c42:	00001097          	auipc	ra,0x1
    80002c46:	c2c080e7          	jalr	-980(ra) # 8000386e <releasesleep>
}
    80002c4a:	60e2                	ld	ra,24(sp)
    80002c4c:	6442                	ld	s0,16(sp)
    80002c4e:	64a2                	ld	s1,8(sp)
    80002c50:	6902                	ld	s2,0(sp)
    80002c52:	6105                	addi	sp,sp,32
    80002c54:	8082                	ret
    panic("iunlock");
    80002c56:	00006517          	auipc	a0,0x6
    80002c5a:	91250513          	addi	a0,a0,-1774 # 80008568 <syscalls+0x198>
    80002c5e:	00003097          	auipc	ra,0x3
    80002c62:	fae080e7          	jalr	-82(ra) # 80005c0c <panic>

0000000080002c66 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002c66:	7179                	addi	sp,sp,-48
    80002c68:	f406                	sd	ra,40(sp)
    80002c6a:	f022                	sd	s0,32(sp)
    80002c6c:	ec26                	sd	s1,24(sp)
    80002c6e:	e84a                	sd	s2,16(sp)
    80002c70:	e44e                	sd	s3,8(sp)
    80002c72:	e052                	sd	s4,0(sp)
    80002c74:	1800                	addi	s0,sp,48
    80002c76:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002c78:	05050493          	addi	s1,a0,80
    80002c7c:	08050913          	addi	s2,a0,128
    80002c80:	a021                	j	80002c88 <itrunc+0x22>
    80002c82:	0491                	addi	s1,s1,4
    80002c84:	01248d63          	beq	s1,s2,80002c9e <itrunc+0x38>
    if(ip->addrs[i]){
    80002c88:	408c                	lw	a1,0(s1)
    80002c8a:	dde5                	beqz	a1,80002c82 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002c8c:	0009a503          	lw	a0,0(s3)
    80002c90:	00000097          	auipc	ra,0x0
    80002c94:	8f6080e7          	jalr	-1802(ra) # 80002586 <bfree>
      ip->addrs[i] = 0;
    80002c98:	0004a023          	sw	zero,0(s1)
    80002c9c:	b7dd                	j	80002c82 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002c9e:	0809a583          	lw	a1,128(s3)
    80002ca2:	e185                	bnez	a1,80002cc2 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002ca4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002ca8:	854e                	mv	a0,s3
    80002caa:	00000097          	auipc	ra,0x0
    80002cae:	de2080e7          	jalr	-542(ra) # 80002a8c <iupdate>
}
    80002cb2:	70a2                	ld	ra,40(sp)
    80002cb4:	7402                	ld	s0,32(sp)
    80002cb6:	64e2                	ld	s1,24(sp)
    80002cb8:	6942                	ld	s2,16(sp)
    80002cba:	69a2                	ld	s3,8(sp)
    80002cbc:	6a02                	ld	s4,0(sp)
    80002cbe:	6145                	addi	sp,sp,48
    80002cc0:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002cc2:	0009a503          	lw	a0,0(s3)
    80002cc6:	fffff097          	auipc	ra,0xfffff
    80002cca:	67a080e7          	jalr	1658(ra) # 80002340 <bread>
    80002cce:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002cd0:	05850493          	addi	s1,a0,88
    80002cd4:	45850913          	addi	s2,a0,1112
    80002cd8:	a021                	j	80002ce0 <itrunc+0x7a>
    80002cda:	0491                	addi	s1,s1,4
    80002cdc:	01248b63          	beq	s1,s2,80002cf2 <itrunc+0x8c>
      if(a[j])
    80002ce0:	408c                	lw	a1,0(s1)
    80002ce2:	dde5                	beqz	a1,80002cda <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80002ce4:	0009a503          	lw	a0,0(s3)
    80002ce8:	00000097          	auipc	ra,0x0
    80002cec:	89e080e7          	jalr	-1890(ra) # 80002586 <bfree>
    80002cf0:	b7ed                	j	80002cda <itrunc+0x74>
    brelse(bp);
    80002cf2:	8552                	mv	a0,s4
    80002cf4:	fffff097          	auipc	ra,0xfffff
    80002cf8:	77c080e7          	jalr	1916(ra) # 80002470 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002cfc:	0809a583          	lw	a1,128(s3)
    80002d00:	0009a503          	lw	a0,0(s3)
    80002d04:	00000097          	auipc	ra,0x0
    80002d08:	882080e7          	jalr	-1918(ra) # 80002586 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002d0c:	0809a023          	sw	zero,128(s3)
    80002d10:	bf51                	j	80002ca4 <itrunc+0x3e>

0000000080002d12 <iput>:
{
    80002d12:	1101                	addi	sp,sp,-32
    80002d14:	ec06                	sd	ra,24(sp)
    80002d16:	e822                	sd	s0,16(sp)
    80002d18:	e426                	sd	s1,8(sp)
    80002d1a:	e04a                	sd	s2,0(sp)
    80002d1c:	1000                	addi	s0,sp,32
    80002d1e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002d20:	00014517          	auipc	a0,0x14
    80002d24:	50850513          	addi	a0,a0,1288 # 80017228 <itable>
    80002d28:	00003097          	auipc	ra,0x3
    80002d2c:	41c080e7          	jalr	1052(ra) # 80006144 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d30:	4498                	lw	a4,8(s1)
    80002d32:	4785                	li	a5,1
    80002d34:	02f70363          	beq	a4,a5,80002d5a <iput+0x48>
  ip->ref--;
    80002d38:	449c                	lw	a5,8(s1)
    80002d3a:	37fd                	addiw	a5,a5,-1
    80002d3c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002d3e:	00014517          	auipc	a0,0x14
    80002d42:	4ea50513          	addi	a0,a0,1258 # 80017228 <itable>
    80002d46:	00003097          	auipc	ra,0x3
    80002d4a:	4b2080e7          	jalr	1202(ra) # 800061f8 <release>
}
    80002d4e:	60e2                	ld	ra,24(sp)
    80002d50:	6442                	ld	s0,16(sp)
    80002d52:	64a2                	ld	s1,8(sp)
    80002d54:	6902                	ld	s2,0(sp)
    80002d56:	6105                	addi	sp,sp,32
    80002d58:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d5a:	40bc                	lw	a5,64(s1)
    80002d5c:	dff1                	beqz	a5,80002d38 <iput+0x26>
    80002d5e:	04a49783          	lh	a5,74(s1)
    80002d62:	fbf9                	bnez	a5,80002d38 <iput+0x26>
    acquiresleep(&ip->lock);
    80002d64:	01048913          	addi	s2,s1,16
    80002d68:	854a                	mv	a0,s2
    80002d6a:	00001097          	auipc	ra,0x1
    80002d6e:	aae080e7          	jalr	-1362(ra) # 80003818 <acquiresleep>
    release(&itable.lock);
    80002d72:	00014517          	auipc	a0,0x14
    80002d76:	4b650513          	addi	a0,a0,1206 # 80017228 <itable>
    80002d7a:	00003097          	auipc	ra,0x3
    80002d7e:	47e080e7          	jalr	1150(ra) # 800061f8 <release>
    itrunc(ip);
    80002d82:	8526                	mv	a0,s1
    80002d84:	00000097          	auipc	ra,0x0
    80002d88:	ee2080e7          	jalr	-286(ra) # 80002c66 <itrunc>
    ip->type = 0;
    80002d8c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002d90:	8526                	mv	a0,s1
    80002d92:	00000097          	auipc	ra,0x0
    80002d96:	cfa080e7          	jalr	-774(ra) # 80002a8c <iupdate>
    ip->valid = 0;
    80002d9a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002d9e:	854a                	mv	a0,s2
    80002da0:	00001097          	auipc	ra,0x1
    80002da4:	ace080e7          	jalr	-1330(ra) # 8000386e <releasesleep>
    acquire(&itable.lock);
    80002da8:	00014517          	auipc	a0,0x14
    80002dac:	48050513          	addi	a0,a0,1152 # 80017228 <itable>
    80002db0:	00003097          	auipc	ra,0x3
    80002db4:	394080e7          	jalr	916(ra) # 80006144 <acquire>
    80002db8:	b741                	j	80002d38 <iput+0x26>

0000000080002dba <iunlockput>:
{
    80002dba:	1101                	addi	sp,sp,-32
    80002dbc:	ec06                	sd	ra,24(sp)
    80002dbe:	e822                	sd	s0,16(sp)
    80002dc0:	e426                	sd	s1,8(sp)
    80002dc2:	1000                	addi	s0,sp,32
    80002dc4:	84aa                	mv	s1,a0
  iunlock(ip);
    80002dc6:	00000097          	auipc	ra,0x0
    80002dca:	e54080e7          	jalr	-428(ra) # 80002c1a <iunlock>
  iput(ip);
    80002dce:	8526                	mv	a0,s1
    80002dd0:	00000097          	auipc	ra,0x0
    80002dd4:	f42080e7          	jalr	-190(ra) # 80002d12 <iput>
}
    80002dd8:	60e2                	ld	ra,24(sp)
    80002dda:	6442                	ld	s0,16(sp)
    80002ddc:	64a2                	ld	s1,8(sp)
    80002dde:	6105                	addi	sp,sp,32
    80002de0:	8082                	ret

0000000080002de2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002de2:	1141                	addi	sp,sp,-16
    80002de4:	e422                	sd	s0,8(sp)
    80002de6:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002de8:	411c                	lw	a5,0(a0)
    80002dea:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002dec:	415c                	lw	a5,4(a0)
    80002dee:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002df0:	04451783          	lh	a5,68(a0)
    80002df4:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002df8:	04a51783          	lh	a5,74(a0)
    80002dfc:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002e00:	04c56783          	lwu	a5,76(a0)
    80002e04:	e99c                	sd	a5,16(a1)
}
    80002e06:	6422                	ld	s0,8(sp)
    80002e08:	0141                	addi	sp,sp,16
    80002e0a:	8082                	ret

0000000080002e0c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002e0c:	457c                	lw	a5,76(a0)
    80002e0e:	0ed7e963          	bltu	a5,a3,80002f00 <readi+0xf4>
{
    80002e12:	7159                	addi	sp,sp,-112
    80002e14:	f486                	sd	ra,104(sp)
    80002e16:	f0a2                	sd	s0,96(sp)
    80002e18:	eca6                	sd	s1,88(sp)
    80002e1a:	e8ca                	sd	s2,80(sp)
    80002e1c:	e4ce                	sd	s3,72(sp)
    80002e1e:	e0d2                	sd	s4,64(sp)
    80002e20:	fc56                	sd	s5,56(sp)
    80002e22:	f85a                	sd	s6,48(sp)
    80002e24:	f45e                	sd	s7,40(sp)
    80002e26:	f062                	sd	s8,32(sp)
    80002e28:	ec66                	sd	s9,24(sp)
    80002e2a:	e86a                	sd	s10,16(sp)
    80002e2c:	e46e                	sd	s11,8(sp)
    80002e2e:	1880                	addi	s0,sp,112
    80002e30:	8b2a                	mv	s6,a0
    80002e32:	8bae                	mv	s7,a1
    80002e34:	8a32                	mv	s4,a2
    80002e36:	84b6                	mv	s1,a3
    80002e38:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002e3a:	9f35                	addw	a4,a4,a3
    return 0;
    80002e3c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002e3e:	0ad76063          	bltu	a4,a3,80002ede <readi+0xd2>
  if(off + n > ip->size)
    80002e42:	00e7f463          	bgeu	a5,a4,80002e4a <readi+0x3e>
    n = ip->size - off;
    80002e46:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002e4a:	0a0a8963          	beqz	s5,80002efc <readi+0xf0>
    80002e4e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002e50:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002e54:	5c7d                	li	s8,-1
    80002e56:	a82d                	j	80002e90 <readi+0x84>
    80002e58:	020d1d93          	slli	s11,s10,0x20
    80002e5c:	020ddd93          	srli	s11,s11,0x20
    80002e60:	05890613          	addi	a2,s2,88
    80002e64:	86ee                	mv	a3,s11
    80002e66:	963a                	add	a2,a2,a4
    80002e68:	85d2                	mv	a1,s4
    80002e6a:	855e                	mv	a0,s7
    80002e6c:	fffff097          	auipc	ra,0xfffff
    80002e70:	aa4080e7          	jalr	-1372(ra) # 80001910 <either_copyout>
    80002e74:	05850d63          	beq	a0,s8,80002ece <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002e78:	854a                	mv	a0,s2
    80002e7a:	fffff097          	auipc	ra,0xfffff
    80002e7e:	5f6080e7          	jalr	1526(ra) # 80002470 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002e82:	013d09bb          	addw	s3,s10,s3
    80002e86:	009d04bb          	addw	s1,s10,s1
    80002e8a:	9a6e                	add	s4,s4,s11
    80002e8c:	0559f763          	bgeu	s3,s5,80002eda <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80002e90:	00a4d59b          	srliw	a1,s1,0xa
    80002e94:	855a                	mv	a0,s6
    80002e96:	00000097          	auipc	ra,0x0
    80002e9a:	89e080e7          	jalr	-1890(ra) # 80002734 <bmap>
    80002e9e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002ea2:	cd85                	beqz	a1,80002eda <readi+0xce>
    bp = bread(ip->dev, addr);
    80002ea4:	000b2503          	lw	a0,0(s6)
    80002ea8:	fffff097          	auipc	ra,0xfffff
    80002eac:	498080e7          	jalr	1176(ra) # 80002340 <bread>
    80002eb0:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002eb2:	3ff4f713          	andi	a4,s1,1023
    80002eb6:	40ec87bb          	subw	a5,s9,a4
    80002eba:	413a86bb          	subw	a3,s5,s3
    80002ebe:	8d3e                	mv	s10,a5
    80002ec0:	2781                	sext.w	a5,a5
    80002ec2:	0006861b          	sext.w	a2,a3
    80002ec6:	f8f679e3          	bgeu	a2,a5,80002e58 <readi+0x4c>
    80002eca:	8d36                	mv	s10,a3
    80002ecc:	b771                	j	80002e58 <readi+0x4c>
      brelse(bp);
    80002ece:	854a                	mv	a0,s2
    80002ed0:	fffff097          	auipc	ra,0xfffff
    80002ed4:	5a0080e7          	jalr	1440(ra) # 80002470 <brelse>
      tot = -1;
    80002ed8:	59fd                	li	s3,-1
  }
  return tot;
    80002eda:	0009851b          	sext.w	a0,s3
}
    80002ede:	70a6                	ld	ra,104(sp)
    80002ee0:	7406                	ld	s0,96(sp)
    80002ee2:	64e6                	ld	s1,88(sp)
    80002ee4:	6946                	ld	s2,80(sp)
    80002ee6:	69a6                	ld	s3,72(sp)
    80002ee8:	6a06                	ld	s4,64(sp)
    80002eea:	7ae2                	ld	s5,56(sp)
    80002eec:	7b42                	ld	s6,48(sp)
    80002eee:	7ba2                	ld	s7,40(sp)
    80002ef0:	7c02                	ld	s8,32(sp)
    80002ef2:	6ce2                	ld	s9,24(sp)
    80002ef4:	6d42                	ld	s10,16(sp)
    80002ef6:	6da2                	ld	s11,8(sp)
    80002ef8:	6165                	addi	sp,sp,112
    80002efa:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002efc:	89d6                	mv	s3,s5
    80002efe:	bff1                	j	80002eda <readi+0xce>
    return 0;
    80002f00:	4501                	li	a0,0
}
    80002f02:	8082                	ret

0000000080002f04 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002f04:	457c                	lw	a5,76(a0)
    80002f06:	10d7e863          	bltu	a5,a3,80003016 <writei+0x112>
{
    80002f0a:	7159                	addi	sp,sp,-112
    80002f0c:	f486                	sd	ra,104(sp)
    80002f0e:	f0a2                	sd	s0,96(sp)
    80002f10:	eca6                	sd	s1,88(sp)
    80002f12:	e8ca                	sd	s2,80(sp)
    80002f14:	e4ce                	sd	s3,72(sp)
    80002f16:	e0d2                	sd	s4,64(sp)
    80002f18:	fc56                	sd	s5,56(sp)
    80002f1a:	f85a                	sd	s6,48(sp)
    80002f1c:	f45e                	sd	s7,40(sp)
    80002f1e:	f062                	sd	s8,32(sp)
    80002f20:	ec66                	sd	s9,24(sp)
    80002f22:	e86a                	sd	s10,16(sp)
    80002f24:	e46e                	sd	s11,8(sp)
    80002f26:	1880                	addi	s0,sp,112
    80002f28:	8aaa                	mv	s5,a0
    80002f2a:	8bae                	mv	s7,a1
    80002f2c:	8a32                	mv	s4,a2
    80002f2e:	8936                	mv	s2,a3
    80002f30:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002f32:	00e687bb          	addw	a5,a3,a4
    80002f36:	0ed7e263          	bltu	a5,a3,8000301a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002f3a:	00043737          	lui	a4,0x43
    80002f3e:	0ef76063          	bltu	a4,a5,8000301e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002f42:	0c0b0863          	beqz	s6,80003012 <writei+0x10e>
    80002f46:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f48:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002f4c:	5c7d                	li	s8,-1
    80002f4e:	a091                	j	80002f92 <writei+0x8e>
    80002f50:	020d1d93          	slli	s11,s10,0x20
    80002f54:	020ddd93          	srli	s11,s11,0x20
    80002f58:	05848513          	addi	a0,s1,88
    80002f5c:	86ee                	mv	a3,s11
    80002f5e:	8652                	mv	a2,s4
    80002f60:	85de                	mv	a1,s7
    80002f62:	953a                	add	a0,a0,a4
    80002f64:	fffff097          	auipc	ra,0xfffff
    80002f68:	a02080e7          	jalr	-1534(ra) # 80001966 <either_copyin>
    80002f6c:	07850263          	beq	a0,s8,80002fd0 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002f70:	8526                	mv	a0,s1
    80002f72:	00000097          	auipc	ra,0x0
    80002f76:	788080e7          	jalr	1928(ra) # 800036fa <log_write>
    brelse(bp);
    80002f7a:	8526                	mv	a0,s1
    80002f7c:	fffff097          	auipc	ra,0xfffff
    80002f80:	4f4080e7          	jalr	1268(ra) # 80002470 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002f84:	013d09bb          	addw	s3,s10,s3
    80002f88:	012d093b          	addw	s2,s10,s2
    80002f8c:	9a6e                	add	s4,s4,s11
    80002f8e:	0569f663          	bgeu	s3,s6,80002fda <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80002f92:	00a9559b          	srliw	a1,s2,0xa
    80002f96:	8556                	mv	a0,s5
    80002f98:	fffff097          	auipc	ra,0xfffff
    80002f9c:	79c080e7          	jalr	1948(ra) # 80002734 <bmap>
    80002fa0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002fa4:	c99d                	beqz	a1,80002fda <writei+0xd6>
    bp = bread(ip->dev, addr);
    80002fa6:	000aa503          	lw	a0,0(s5)
    80002faa:	fffff097          	auipc	ra,0xfffff
    80002fae:	396080e7          	jalr	918(ra) # 80002340 <bread>
    80002fb2:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002fb4:	3ff97713          	andi	a4,s2,1023
    80002fb8:	40ec87bb          	subw	a5,s9,a4
    80002fbc:	413b06bb          	subw	a3,s6,s3
    80002fc0:	8d3e                	mv	s10,a5
    80002fc2:	2781                	sext.w	a5,a5
    80002fc4:	0006861b          	sext.w	a2,a3
    80002fc8:	f8f674e3          	bgeu	a2,a5,80002f50 <writei+0x4c>
    80002fcc:	8d36                	mv	s10,a3
    80002fce:	b749                	j	80002f50 <writei+0x4c>
      brelse(bp);
    80002fd0:	8526                	mv	a0,s1
    80002fd2:	fffff097          	auipc	ra,0xfffff
    80002fd6:	49e080e7          	jalr	1182(ra) # 80002470 <brelse>
  }

  if(off > ip->size)
    80002fda:	04caa783          	lw	a5,76(s5)
    80002fde:	0127f463          	bgeu	a5,s2,80002fe6 <writei+0xe2>
    ip->size = off;
    80002fe2:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80002fe6:	8556                	mv	a0,s5
    80002fe8:	00000097          	auipc	ra,0x0
    80002fec:	aa4080e7          	jalr	-1372(ra) # 80002a8c <iupdate>

  return tot;
    80002ff0:	0009851b          	sext.w	a0,s3
}
    80002ff4:	70a6                	ld	ra,104(sp)
    80002ff6:	7406                	ld	s0,96(sp)
    80002ff8:	64e6                	ld	s1,88(sp)
    80002ffa:	6946                	ld	s2,80(sp)
    80002ffc:	69a6                	ld	s3,72(sp)
    80002ffe:	6a06                	ld	s4,64(sp)
    80003000:	7ae2                	ld	s5,56(sp)
    80003002:	7b42                	ld	s6,48(sp)
    80003004:	7ba2                	ld	s7,40(sp)
    80003006:	7c02                	ld	s8,32(sp)
    80003008:	6ce2                	ld	s9,24(sp)
    8000300a:	6d42                	ld	s10,16(sp)
    8000300c:	6da2                	ld	s11,8(sp)
    8000300e:	6165                	addi	sp,sp,112
    80003010:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003012:	89da                	mv	s3,s6
    80003014:	bfc9                	j	80002fe6 <writei+0xe2>
    return -1;
    80003016:	557d                	li	a0,-1
}
    80003018:	8082                	ret
    return -1;
    8000301a:	557d                	li	a0,-1
    8000301c:	bfe1                	j	80002ff4 <writei+0xf0>
    return -1;
    8000301e:	557d                	li	a0,-1
    80003020:	bfd1                	j	80002ff4 <writei+0xf0>

0000000080003022 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003022:	1141                	addi	sp,sp,-16
    80003024:	e406                	sd	ra,8(sp)
    80003026:	e022                	sd	s0,0(sp)
    80003028:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000302a:	4639                	li	a2,14
    8000302c:	ffffd097          	auipc	ra,0xffffd
    80003030:	21e080e7          	jalr	542(ra) # 8000024a <strncmp>
}
    80003034:	60a2                	ld	ra,8(sp)
    80003036:	6402                	ld	s0,0(sp)
    80003038:	0141                	addi	sp,sp,16
    8000303a:	8082                	ret

000000008000303c <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000303c:	7139                	addi	sp,sp,-64
    8000303e:	fc06                	sd	ra,56(sp)
    80003040:	f822                	sd	s0,48(sp)
    80003042:	f426                	sd	s1,40(sp)
    80003044:	f04a                	sd	s2,32(sp)
    80003046:	ec4e                	sd	s3,24(sp)
    80003048:	e852                	sd	s4,16(sp)
    8000304a:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000304c:	04451703          	lh	a4,68(a0)
    80003050:	4785                	li	a5,1
    80003052:	00f71a63          	bne	a4,a5,80003066 <dirlookup+0x2a>
    80003056:	892a                	mv	s2,a0
    80003058:	89ae                	mv	s3,a1
    8000305a:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000305c:	457c                	lw	a5,76(a0)
    8000305e:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003060:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003062:	e79d                	bnez	a5,80003090 <dirlookup+0x54>
    80003064:	a8a5                	j	800030dc <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003066:	00005517          	auipc	a0,0x5
    8000306a:	50a50513          	addi	a0,a0,1290 # 80008570 <syscalls+0x1a0>
    8000306e:	00003097          	auipc	ra,0x3
    80003072:	b9e080e7          	jalr	-1122(ra) # 80005c0c <panic>
      panic("dirlookup read");
    80003076:	00005517          	auipc	a0,0x5
    8000307a:	51250513          	addi	a0,a0,1298 # 80008588 <syscalls+0x1b8>
    8000307e:	00003097          	auipc	ra,0x3
    80003082:	b8e080e7          	jalr	-1138(ra) # 80005c0c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003086:	24c1                	addiw	s1,s1,16
    80003088:	04c92783          	lw	a5,76(s2)
    8000308c:	04f4f763          	bgeu	s1,a5,800030da <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003090:	4741                	li	a4,16
    80003092:	86a6                	mv	a3,s1
    80003094:	fc040613          	addi	a2,s0,-64
    80003098:	4581                	li	a1,0
    8000309a:	854a                	mv	a0,s2
    8000309c:	00000097          	auipc	ra,0x0
    800030a0:	d70080e7          	jalr	-656(ra) # 80002e0c <readi>
    800030a4:	47c1                	li	a5,16
    800030a6:	fcf518e3          	bne	a0,a5,80003076 <dirlookup+0x3a>
    if(de.inum == 0)
    800030aa:	fc045783          	lhu	a5,-64(s0)
    800030ae:	dfe1                	beqz	a5,80003086 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800030b0:	fc240593          	addi	a1,s0,-62
    800030b4:	854e                	mv	a0,s3
    800030b6:	00000097          	auipc	ra,0x0
    800030ba:	f6c080e7          	jalr	-148(ra) # 80003022 <namecmp>
    800030be:	f561                	bnez	a0,80003086 <dirlookup+0x4a>
      if(poff)
    800030c0:	000a0463          	beqz	s4,800030c8 <dirlookup+0x8c>
        *poff = off;
    800030c4:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800030c8:	fc045583          	lhu	a1,-64(s0)
    800030cc:	00092503          	lw	a0,0(s2)
    800030d0:	fffff097          	auipc	ra,0xfffff
    800030d4:	74e080e7          	jalr	1870(ra) # 8000281e <iget>
    800030d8:	a011                	j	800030dc <dirlookup+0xa0>
  return 0;
    800030da:	4501                	li	a0,0
}
    800030dc:	70e2                	ld	ra,56(sp)
    800030de:	7442                	ld	s0,48(sp)
    800030e0:	74a2                	ld	s1,40(sp)
    800030e2:	7902                	ld	s2,32(sp)
    800030e4:	69e2                	ld	s3,24(sp)
    800030e6:	6a42                	ld	s4,16(sp)
    800030e8:	6121                	addi	sp,sp,64
    800030ea:	8082                	ret

00000000800030ec <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800030ec:	711d                	addi	sp,sp,-96
    800030ee:	ec86                	sd	ra,88(sp)
    800030f0:	e8a2                	sd	s0,80(sp)
    800030f2:	e4a6                	sd	s1,72(sp)
    800030f4:	e0ca                	sd	s2,64(sp)
    800030f6:	fc4e                	sd	s3,56(sp)
    800030f8:	f852                	sd	s4,48(sp)
    800030fa:	f456                	sd	s5,40(sp)
    800030fc:	f05a                	sd	s6,32(sp)
    800030fe:	ec5e                	sd	s7,24(sp)
    80003100:	e862                	sd	s8,16(sp)
    80003102:	e466                	sd	s9,8(sp)
    80003104:	e06a                	sd	s10,0(sp)
    80003106:	1080                	addi	s0,sp,96
    80003108:	84aa                	mv	s1,a0
    8000310a:	8b2e                	mv	s6,a1
    8000310c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    8000310e:	00054703          	lbu	a4,0(a0)
    80003112:	02f00793          	li	a5,47
    80003116:	02f70363          	beq	a4,a5,8000313c <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000311a:	ffffe097          	auipc	ra,0xffffe
    8000311e:	d3a080e7          	jalr	-710(ra) # 80000e54 <myproc>
    80003122:	15053503          	ld	a0,336(a0)
    80003126:	00000097          	auipc	ra,0x0
    8000312a:	9f4080e7          	jalr	-1548(ra) # 80002b1a <idup>
    8000312e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003130:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003134:	4cb5                	li	s9,13
  len = path - s;
    80003136:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003138:	4c05                	li	s8,1
    8000313a:	a87d                	j	800031f8 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000313c:	4585                	li	a1,1
    8000313e:	4505                	li	a0,1
    80003140:	fffff097          	auipc	ra,0xfffff
    80003144:	6de080e7          	jalr	1758(ra) # 8000281e <iget>
    80003148:	8a2a                	mv	s4,a0
    8000314a:	b7dd                	j	80003130 <namex+0x44>
      iunlockput(ip);
    8000314c:	8552                	mv	a0,s4
    8000314e:	00000097          	auipc	ra,0x0
    80003152:	c6c080e7          	jalr	-916(ra) # 80002dba <iunlockput>
      return 0;
    80003156:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003158:	8552                	mv	a0,s4
    8000315a:	60e6                	ld	ra,88(sp)
    8000315c:	6446                	ld	s0,80(sp)
    8000315e:	64a6                	ld	s1,72(sp)
    80003160:	6906                	ld	s2,64(sp)
    80003162:	79e2                	ld	s3,56(sp)
    80003164:	7a42                	ld	s4,48(sp)
    80003166:	7aa2                	ld	s5,40(sp)
    80003168:	7b02                	ld	s6,32(sp)
    8000316a:	6be2                	ld	s7,24(sp)
    8000316c:	6c42                	ld	s8,16(sp)
    8000316e:	6ca2                	ld	s9,8(sp)
    80003170:	6d02                	ld	s10,0(sp)
    80003172:	6125                	addi	sp,sp,96
    80003174:	8082                	ret
      iunlock(ip);
    80003176:	8552                	mv	a0,s4
    80003178:	00000097          	auipc	ra,0x0
    8000317c:	aa2080e7          	jalr	-1374(ra) # 80002c1a <iunlock>
      return ip;
    80003180:	bfe1                	j	80003158 <namex+0x6c>
      iunlockput(ip);
    80003182:	8552                	mv	a0,s4
    80003184:	00000097          	auipc	ra,0x0
    80003188:	c36080e7          	jalr	-970(ra) # 80002dba <iunlockput>
      return 0;
    8000318c:	8a4e                	mv	s4,s3
    8000318e:	b7e9                	j	80003158 <namex+0x6c>
  len = path - s;
    80003190:	40998633          	sub	a2,s3,s1
    80003194:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003198:	09acd863          	bge	s9,s10,80003228 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    8000319c:	4639                	li	a2,14
    8000319e:	85a6                	mv	a1,s1
    800031a0:	8556                	mv	a0,s5
    800031a2:	ffffd097          	auipc	ra,0xffffd
    800031a6:	034080e7          	jalr	52(ra) # 800001d6 <memmove>
    800031aa:	84ce                	mv	s1,s3
  while(*path == '/')
    800031ac:	0004c783          	lbu	a5,0(s1)
    800031b0:	01279763          	bne	a5,s2,800031be <namex+0xd2>
    path++;
    800031b4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800031b6:	0004c783          	lbu	a5,0(s1)
    800031ba:	ff278de3          	beq	a5,s2,800031b4 <namex+0xc8>
    ilock(ip);
    800031be:	8552                	mv	a0,s4
    800031c0:	00000097          	auipc	ra,0x0
    800031c4:	998080e7          	jalr	-1640(ra) # 80002b58 <ilock>
    if(ip->type != T_DIR){
    800031c8:	044a1783          	lh	a5,68(s4)
    800031cc:	f98790e3          	bne	a5,s8,8000314c <namex+0x60>
    if(nameiparent && *path == '\0'){
    800031d0:	000b0563          	beqz	s6,800031da <namex+0xee>
    800031d4:	0004c783          	lbu	a5,0(s1)
    800031d8:	dfd9                	beqz	a5,80003176 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800031da:	865e                	mv	a2,s7
    800031dc:	85d6                	mv	a1,s5
    800031de:	8552                	mv	a0,s4
    800031e0:	00000097          	auipc	ra,0x0
    800031e4:	e5c080e7          	jalr	-420(ra) # 8000303c <dirlookup>
    800031e8:	89aa                	mv	s3,a0
    800031ea:	dd41                	beqz	a0,80003182 <namex+0x96>
    iunlockput(ip);
    800031ec:	8552                	mv	a0,s4
    800031ee:	00000097          	auipc	ra,0x0
    800031f2:	bcc080e7          	jalr	-1076(ra) # 80002dba <iunlockput>
    ip = next;
    800031f6:	8a4e                	mv	s4,s3
  while(*path == '/')
    800031f8:	0004c783          	lbu	a5,0(s1)
    800031fc:	01279763          	bne	a5,s2,8000320a <namex+0x11e>
    path++;
    80003200:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003202:	0004c783          	lbu	a5,0(s1)
    80003206:	ff278de3          	beq	a5,s2,80003200 <namex+0x114>
  if(*path == 0)
    8000320a:	cb9d                	beqz	a5,80003240 <namex+0x154>
  while(*path != '/' && *path != 0)
    8000320c:	0004c783          	lbu	a5,0(s1)
    80003210:	89a6                	mv	s3,s1
  len = path - s;
    80003212:	8d5e                	mv	s10,s7
    80003214:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003216:	01278963          	beq	a5,s2,80003228 <namex+0x13c>
    8000321a:	dbbd                	beqz	a5,80003190 <namex+0xa4>
    path++;
    8000321c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000321e:	0009c783          	lbu	a5,0(s3)
    80003222:	ff279ce3          	bne	a5,s2,8000321a <namex+0x12e>
    80003226:	b7ad                	j	80003190 <namex+0xa4>
    memmove(name, s, len);
    80003228:	2601                	sext.w	a2,a2
    8000322a:	85a6                	mv	a1,s1
    8000322c:	8556                	mv	a0,s5
    8000322e:	ffffd097          	auipc	ra,0xffffd
    80003232:	fa8080e7          	jalr	-88(ra) # 800001d6 <memmove>
    name[len] = 0;
    80003236:	9d56                	add	s10,s10,s5
    80003238:	000d0023          	sb	zero,0(s10)
    8000323c:	84ce                	mv	s1,s3
    8000323e:	b7bd                	j	800031ac <namex+0xc0>
  if(nameiparent){
    80003240:	f00b0ce3          	beqz	s6,80003158 <namex+0x6c>
    iput(ip);
    80003244:	8552                	mv	a0,s4
    80003246:	00000097          	auipc	ra,0x0
    8000324a:	acc080e7          	jalr	-1332(ra) # 80002d12 <iput>
    return 0;
    8000324e:	4a01                	li	s4,0
    80003250:	b721                	j	80003158 <namex+0x6c>

0000000080003252 <dirlink>:
{
    80003252:	7139                	addi	sp,sp,-64
    80003254:	fc06                	sd	ra,56(sp)
    80003256:	f822                	sd	s0,48(sp)
    80003258:	f426                	sd	s1,40(sp)
    8000325a:	f04a                	sd	s2,32(sp)
    8000325c:	ec4e                	sd	s3,24(sp)
    8000325e:	e852                	sd	s4,16(sp)
    80003260:	0080                	addi	s0,sp,64
    80003262:	892a                	mv	s2,a0
    80003264:	8a2e                	mv	s4,a1
    80003266:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003268:	4601                	li	a2,0
    8000326a:	00000097          	auipc	ra,0x0
    8000326e:	dd2080e7          	jalr	-558(ra) # 8000303c <dirlookup>
    80003272:	e93d                	bnez	a0,800032e8 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003274:	04c92483          	lw	s1,76(s2)
    80003278:	c49d                	beqz	s1,800032a6 <dirlink+0x54>
    8000327a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000327c:	4741                	li	a4,16
    8000327e:	86a6                	mv	a3,s1
    80003280:	fc040613          	addi	a2,s0,-64
    80003284:	4581                	li	a1,0
    80003286:	854a                	mv	a0,s2
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	b84080e7          	jalr	-1148(ra) # 80002e0c <readi>
    80003290:	47c1                	li	a5,16
    80003292:	06f51163          	bne	a0,a5,800032f4 <dirlink+0xa2>
    if(de.inum == 0)
    80003296:	fc045783          	lhu	a5,-64(s0)
    8000329a:	c791                	beqz	a5,800032a6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000329c:	24c1                	addiw	s1,s1,16
    8000329e:	04c92783          	lw	a5,76(s2)
    800032a2:	fcf4ede3          	bltu	s1,a5,8000327c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800032a6:	4639                	li	a2,14
    800032a8:	85d2                	mv	a1,s4
    800032aa:	fc240513          	addi	a0,s0,-62
    800032ae:	ffffd097          	auipc	ra,0xffffd
    800032b2:	fd8080e7          	jalr	-40(ra) # 80000286 <strncpy>
  de.inum = inum;
    800032b6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800032ba:	4741                	li	a4,16
    800032bc:	86a6                	mv	a3,s1
    800032be:	fc040613          	addi	a2,s0,-64
    800032c2:	4581                	li	a1,0
    800032c4:	854a                	mv	a0,s2
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	c3e080e7          	jalr	-962(ra) # 80002f04 <writei>
    800032ce:	1541                	addi	a0,a0,-16
    800032d0:	00a03533          	snez	a0,a0
    800032d4:	40a00533          	neg	a0,a0
}
    800032d8:	70e2                	ld	ra,56(sp)
    800032da:	7442                	ld	s0,48(sp)
    800032dc:	74a2                	ld	s1,40(sp)
    800032de:	7902                	ld	s2,32(sp)
    800032e0:	69e2                	ld	s3,24(sp)
    800032e2:	6a42                	ld	s4,16(sp)
    800032e4:	6121                	addi	sp,sp,64
    800032e6:	8082                	ret
    iput(ip);
    800032e8:	00000097          	auipc	ra,0x0
    800032ec:	a2a080e7          	jalr	-1494(ra) # 80002d12 <iput>
    return -1;
    800032f0:	557d                	li	a0,-1
    800032f2:	b7dd                	j	800032d8 <dirlink+0x86>
      panic("dirlink read");
    800032f4:	00005517          	auipc	a0,0x5
    800032f8:	2a450513          	addi	a0,a0,676 # 80008598 <syscalls+0x1c8>
    800032fc:	00003097          	auipc	ra,0x3
    80003300:	910080e7          	jalr	-1776(ra) # 80005c0c <panic>

0000000080003304 <namei>:

struct inode*
namei(char *path)
{
    80003304:	1101                	addi	sp,sp,-32
    80003306:	ec06                	sd	ra,24(sp)
    80003308:	e822                	sd	s0,16(sp)
    8000330a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000330c:	fe040613          	addi	a2,s0,-32
    80003310:	4581                	li	a1,0
    80003312:	00000097          	auipc	ra,0x0
    80003316:	dda080e7          	jalr	-550(ra) # 800030ec <namex>
}
    8000331a:	60e2                	ld	ra,24(sp)
    8000331c:	6442                	ld	s0,16(sp)
    8000331e:	6105                	addi	sp,sp,32
    80003320:	8082                	ret

0000000080003322 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003322:	1141                	addi	sp,sp,-16
    80003324:	e406                	sd	ra,8(sp)
    80003326:	e022                	sd	s0,0(sp)
    80003328:	0800                	addi	s0,sp,16
    8000332a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000332c:	4585                	li	a1,1
    8000332e:	00000097          	auipc	ra,0x0
    80003332:	dbe080e7          	jalr	-578(ra) # 800030ec <namex>
}
    80003336:	60a2                	ld	ra,8(sp)
    80003338:	6402                	ld	s0,0(sp)
    8000333a:	0141                	addi	sp,sp,16
    8000333c:	8082                	ret

000000008000333e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000333e:	1101                	addi	sp,sp,-32
    80003340:	ec06                	sd	ra,24(sp)
    80003342:	e822                	sd	s0,16(sp)
    80003344:	e426                	sd	s1,8(sp)
    80003346:	e04a                	sd	s2,0(sp)
    80003348:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000334a:	00016917          	auipc	s2,0x16
    8000334e:	98690913          	addi	s2,s2,-1658 # 80018cd0 <log>
    80003352:	01892583          	lw	a1,24(s2)
    80003356:	02892503          	lw	a0,40(s2)
    8000335a:	fffff097          	auipc	ra,0xfffff
    8000335e:	fe6080e7          	jalr	-26(ra) # 80002340 <bread>
    80003362:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003364:	02c92683          	lw	a3,44(s2)
    80003368:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000336a:	02d05863          	blez	a3,8000339a <write_head+0x5c>
    8000336e:	00016797          	auipc	a5,0x16
    80003372:	99278793          	addi	a5,a5,-1646 # 80018d00 <log+0x30>
    80003376:	05c50713          	addi	a4,a0,92
    8000337a:	36fd                	addiw	a3,a3,-1
    8000337c:	02069613          	slli	a2,a3,0x20
    80003380:	01e65693          	srli	a3,a2,0x1e
    80003384:	00016617          	auipc	a2,0x16
    80003388:	98060613          	addi	a2,a2,-1664 # 80018d04 <log+0x34>
    8000338c:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000338e:	4390                	lw	a2,0(a5)
    80003390:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003392:	0791                	addi	a5,a5,4
    80003394:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003396:	fed79ce3          	bne	a5,a3,8000338e <write_head+0x50>
  }
  bwrite(buf);
    8000339a:	8526                	mv	a0,s1
    8000339c:	fffff097          	auipc	ra,0xfffff
    800033a0:	096080e7          	jalr	150(ra) # 80002432 <bwrite>
  brelse(buf);
    800033a4:	8526                	mv	a0,s1
    800033a6:	fffff097          	auipc	ra,0xfffff
    800033aa:	0ca080e7          	jalr	202(ra) # 80002470 <brelse>
}
    800033ae:	60e2                	ld	ra,24(sp)
    800033b0:	6442                	ld	s0,16(sp)
    800033b2:	64a2                	ld	s1,8(sp)
    800033b4:	6902                	ld	s2,0(sp)
    800033b6:	6105                	addi	sp,sp,32
    800033b8:	8082                	ret

00000000800033ba <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800033ba:	00016797          	auipc	a5,0x16
    800033be:	9427a783          	lw	a5,-1726(a5) # 80018cfc <log+0x2c>
    800033c2:	0af05d63          	blez	a5,8000347c <install_trans+0xc2>
{
    800033c6:	7139                	addi	sp,sp,-64
    800033c8:	fc06                	sd	ra,56(sp)
    800033ca:	f822                	sd	s0,48(sp)
    800033cc:	f426                	sd	s1,40(sp)
    800033ce:	f04a                	sd	s2,32(sp)
    800033d0:	ec4e                	sd	s3,24(sp)
    800033d2:	e852                	sd	s4,16(sp)
    800033d4:	e456                	sd	s5,8(sp)
    800033d6:	e05a                	sd	s6,0(sp)
    800033d8:	0080                	addi	s0,sp,64
    800033da:	8b2a                	mv	s6,a0
    800033dc:	00016a97          	auipc	s5,0x16
    800033e0:	924a8a93          	addi	s5,s5,-1756 # 80018d00 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800033e4:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800033e6:	00016997          	auipc	s3,0x16
    800033ea:	8ea98993          	addi	s3,s3,-1814 # 80018cd0 <log>
    800033ee:	a00d                	j	80003410 <install_trans+0x56>
    brelse(lbuf);
    800033f0:	854a                	mv	a0,s2
    800033f2:	fffff097          	auipc	ra,0xfffff
    800033f6:	07e080e7          	jalr	126(ra) # 80002470 <brelse>
    brelse(dbuf);
    800033fa:	8526                	mv	a0,s1
    800033fc:	fffff097          	auipc	ra,0xfffff
    80003400:	074080e7          	jalr	116(ra) # 80002470 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003404:	2a05                	addiw	s4,s4,1
    80003406:	0a91                	addi	s5,s5,4
    80003408:	02c9a783          	lw	a5,44(s3)
    8000340c:	04fa5e63          	bge	s4,a5,80003468 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003410:	0189a583          	lw	a1,24(s3)
    80003414:	014585bb          	addw	a1,a1,s4
    80003418:	2585                	addiw	a1,a1,1
    8000341a:	0289a503          	lw	a0,40(s3)
    8000341e:	fffff097          	auipc	ra,0xfffff
    80003422:	f22080e7          	jalr	-222(ra) # 80002340 <bread>
    80003426:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003428:	000aa583          	lw	a1,0(s5)
    8000342c:	0289a503          	lw	a0,40(s3)
    80003430:	fffff097          	auipc	ra,0xfffff
    80003434:	f10080e7          	jalr	-240(ra) # 80002340 <bread>
    80003438:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000343a:	40000613          	li	a2,1024
    8000343e:	05890593          	addi	a1,s2,88
    80003442:	05850513          	addi	a0,a0,88
    80003446:	ffffd097          	auipc	ra,0xffffd
    8000344a:	d90080e7          	jalr	-624(ra) # 800001d6 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000344e:	8526                	mv	a0,s1
    80003450:	fffff097          	auipc	ra,0xfffff
    80003454:	fe2080e7          	jalr	-30(ra) # 80002432 <bwrite>
    if(recovering == 0)
    80003458:	f80b1ce3          	bnez	s6,800033f0 <install_trans+0x36>
      bunpin(dbuf);
    8000345c:	8526                	mv	a0,s1
    8000345e:	fffff097          	auipc	ra,0xfffff
    80003462:	0ec080e7          	jalr	236(ra) # 8000254a <bunpin>
    80003466:	b769                	j	800033f0 <install_trans+0x36>
}
    80003468:	70e2                	ld	ra,56(sp)
    8000346a:	7442                	ld	s0,48(sp)
    8000346c:	74a2                	ld	s1,40(sp)
    8000346e:	7902                	ld	s2,32(sp)
    80003470:	69e2                	ld	s3,24(sp)
    80003472:	6a42                	ld	s4,16(sp)
    80003474:	6aa2                	ld	s5,8(sp)
    80003476:	6b02                	ld	s6,0(sp)
    80003478:	6121                	addi	sp,sp,64
    8000347a:	8082                	ret
    8000347c:	8082                	ret

000000008000347e <initlog>:
{
    8000347e:	7179                	addi	sp,sp,-48
    80003480:	f406                	sd	ra,40(sp)
    80003482:	f022                	sd	s0,32(sp)
    80003484:	ec26                	sd	s1,24(sp)
    80003486:	e84a                	sd	s2,16(sp)
    80003488:	e44e                	sd	s3,8(sp)
    8000348a:	1800                	addi	s0,sp,48
    8000348c:	892a                	mv	s2,a0
    8000348e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003490:	00016497          	auipc	s1,0x16
    80003494:	84048493          	addi	s1,s1,-1984 # 80018cd0 <log>
    80003498:	00005597          	auipc	a1,0x5
    8000349c:	11058593          	addi	a1,a1,272 # 800085a8 <syscalls+0x1d8>
    800034a0:	8526                	mv	a0,s1
    800034a2:	00003097          	auipc	ra,0x3
    800034a6:	c12080e7          	jalr	-1006(ra) # 800060b4 <initlock>
  log.start = sb->logstart;
    800034aa:	0149a583          	lw	a1,20(s3)
    800034ae:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800034b0:	0109a783          	lw	a5,16(s3)
    800034b4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800034b6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800034ba:	854a                	mv	a0,s2
    800034bc:	fffff097          	auipc	ra,0xfffff
    800034c0:	e84080e7          	jalr	-380(ra) # 80002340 <bread>
  log.lh.n = lh->n;
    800034c4:	4d34                	lw	a3,88(a0)
    800034c6:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800034c8:	02d05663          	blez	a3,800034f4 <initlog+0x76>
    800034cc:	05c50793          	addi	a5,a0,92
    800034d0:	00016717          	auipc	a4,0x16
    800034d4:	83070713          	addi	a4,a4,-2000 # 80018d00 <log+0x30>
    800034d8:	36fd                	addiw	a3,a3,-1
    800034da:	02069613          	slli	a2,a3,0x20
    800034de:	01e65693          	srli	a3,a2,0x1e
    800034e2:	06050613          	addi	a2,a0,96
    800034e6:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800034e8:	4390                	lw	a2,0(a5)
    800034ea:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800034ec:	0791                	addi	a5,a5,4
    800034ee:	0711                	addi	a4,a4,4
    800034f0:	fed79ce3          	bne	a5,a3,800034e8 <initlog+0x6a>
  brelse(buf);
    800034f4:	fffff097          	auipc	ra,0xfffff
    800034f8:	f7c080e7          	jalr	-132(ra) # 80002470 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800034fc:	4505                	li	a0,1
    800034fe:	00000097          	auipc	ra,0x0
    80003502:	ebc080e7          	jalr	-324(ra) # 800033ba <install_trans>
  log.lh.n = 0;
    80003506:	00015797          	auipc	a5,0x15
    8000350a:	7e07ab23          	sw	zero,2038(a5) # 80018cfc <log+0x2c>
  write_head(); // clear the log
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	e30080e7          	jalr	-464(ra) # 8000333e <write_head>
}
    80003516:	70a2                	ld	ra,40(sp)
    80003518:	7402                	ld	s0,32(sp)
    8000351a:	64e2                	ld	s1,24(sp)
    8000351c:	6942                	ld	s2,16(sp)
    8000351e:	69a2                	ld	s3,8(sp)
    80003520:	6145                	addi	sp,sp,48
    80003522:	8082                	ret

0000000080003524 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003524:	1101                	addi	sp,sp,-32
    80003526:	ec06                	sd	ra,24(sp)
    80003528:	e822                	sd	s0,16(sp)
    8000352a:	e426                	sd	s1,8(sp)
    8000352c:	e04a                	sd	s2,0(sp)
    8000352e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003530:	00015517          	auipc	a0,0x15
    80003534:	7a050513          	addi	a0,a0,1952 # 80018cd0 <log>
    80003538:	00003097          	auipc	ra,0x3
    8000353c:	c0c080e7          	jalr	-1012(ra) # 80006144 <acquire>
  while(1){
    if(log.committing){
    80003540:	00015497          	auipc	s1,0x15
    80003544:	79048493          	addi	s1,s1,1936 # 80018cd0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003548:	4979                	li	s2,30
    8000354a:	a039                	j	80003558 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000354c:	85a6                	mv	a1,s1
    8000354e:	8526                	mv	a0,s1
    80003550:	ffffe097          	auipc	ra,0xffffe
    80003554:	fb8080e7          	jalr	-72(ra) # 80001508 <sleep>
    if(log.committing){
    80003558:	50dc                	lw	a5,36(s1)
    8000355a:	fbed                	bnez	a5,8000354c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000355c:	5098                	lw	a4,32(s1)
    8000355e:	2705                	addiw	a4,a4,1
    80003560:	0007069b          	sext.w	a3,a4
    80003564:	0027179b          	slliw	a5,a4,0x2
    80003568:	9fb9                	addw	a5,a5,a4
    8000356a:	0017979b          	slliw	a5,a5,0x1
    8000356e:	54d8                	lw	a4,44(s1)
    80003570:	9fb9                	addw	a5,a5,a4
    80003572:	00f95963          	bge	s2,a5,80003584 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003576:	85a6                	mv	a1,s1
    80003578:	8526                	mv	a0,s1
    8000357a:	ffffe097          	auipc	ra,0xffffe
    8000357e:	f8e080e7          	jalr	-114(ra) # 80001508 <sleep>
    80003582:	bfd9                	j	80003558 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80003584:	00015517          	auipc	a0,0x15
    80003588:	74c50513          	addi	a0,a0,1868 # 80018cd0 <log>
    8000358c:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000358e:	00003097          	auipc	ra,0x3
    80003592:	c6a080e7          	jalr	-918(ra) # 800061f8 <release>
      break;
    }
  }
}
    80003596:	60e2                	ld	ra,24(sp)
    80003598:	6442                	ld	s0,16(sp)
    8000359a:	64a2                	ld	s1,8(sp)
    8000359c:	6902                	ld	s2,0(sp)
    8000359e:	6105                	addi	sp,sp,32
    800035a0:	8082                	ret

00000000800035a2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800035a2:	7139                	addi	sp,sp,-64
    800035a4:	fc06                	sd	ra,56(sp)
    800035a6:	f822                	sd	s0,48(sp)
    800035a8:	f426                	sd	s1,40(sp)
    800035aa:	f04a                	sd	s2,32(sp)
    800035ac:	ec4e                	sd	s3,24(sp)
    800035ae:	e852                	sd	s4,16(sp)
    800035b0:	e456                	sd	s5,8(sp)
    800035b2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800035b4:	00015497          	auipc	s1,0x15
    800035b8:	71c48493          	addi	s1,s1,1820 # 80018cd0 <log>
    800035bc:	8526                	mv	a0,s1
    800035be:	00003097          	auipc	ra,0x3
    800035c2:	b86080e7          	jalr	-1146(ra) # 80006144 <acquire>
  log.outstanding -= 1;
    800035c6:	509c                	lw	a5,32(s1)
    800035c8:	37fd                	addiw	a5,a5,-1
    800035ca:	0007891b          	sext.w	s2,a5
    800035ce:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800035d0:	50dc                	lw	a5,36(s1)
    800035d2:	e7b9                	bnez	a5,80003620 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800035d4:	04091e63          	bnez	s2,80003630 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800035d8:	00015497          	auipc	s1,0x15
    800035dc:	6f848493          	addi	s1,s1,1784 # 80018cd0 <log>
    800035e0:	4785                	li	a5,1
    800035e2:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800035e4:	8526                	mv	a0,s1
    800035e6:	00003097          	auipc	ra,0x3
    800035ea:	c12080e7          	jalr	-1006(ra) # 800061f8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800035ee:	54dc                	lw	a5,44(s1)
    800035f0:	06f04763          	bgtz	a5,8000365e <end_op+0xbc>
    acquire(&log.lock);
    800035f4:	00015497          	auipc	s1,0x15
    800035f8:	6dc48493          	addi	s1,s1,1756 # 80018cd0 <log>
    800035fc:	8526                	mv	a0,s1
    800035fe:	00003097          	auipc	ra,0x3
    80003602:	b46080e7          	jalr	-1210(ra) # 80006144 <acquire>
    log.committing = 0;
    80003606:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000360a:	8526                	mv	a0,s1
    8000360c:	ffffe097          	auipc	ra,0xffffe
    80003610:	f60080e7          	jalr	-160(ra) # 8000156c <wakeup>
    release(&log.lock);
    80003614:	8526                	mv	a0,s1
    80003616:	00003097          	auipc	ra,0x3
    8000361a:	be2080e7          	jalr	-1054(ra) # 800061f8 <release>
}
    8000361e:	a03d                	j	8000364c <end_op+0xaa>
    panic("log.committing");
    80003620:	00005517          	auipc	a0,0x5
    80003624:	f9050513          	addi	a0,a0,-112 # 800085b0 <syscalls+0x1e0>
    80003628:	00002097          	auipc	ra,0x2
    8000362c:	5e4080e7          	jalr	1508(ra) # 80005c0c <panic>
    wakeup(&log);
    80003630:	00015497          	auipc	s1,0x15
    80003634:	6a048493          	addi	s1,s1,1696 # 80018cd0 <log>
    80003638:	8526                	mv	a0,s1
    8000363a:	ffffe097          	auipc	ra,0xffffe
    8000363e:	f32080e7          	jalr	-206(ra) # 8000156c <wakeup>
  release(&log.lock);
    80003642:	8526                	mv	a0,s1
    80003644:	00003097          	auipc	ra,0x3
    80003648:	bb4080e7          	jalr	-1100(ra) # 800061f8 <release>
}
    8000364c:	70e2                	ld	ra,56(sp)
    8000364e:	7442                	ld	s0,48(sp)
    80003650:	74a2                	ld	s1,40(sp)
    80003652:	7902                	ld	s2,32(sp)
    80003654:	69e2                	ld	s3,24(sp)
    80003656:	6a42                	ld	s4,16(sp)
    80003658:	6aa2                	ld	s5,8(sp)
    8000365a:	6121                	addi	sp,sp,64
    8000365c:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000365e:	00015a97          	auipc	s5,0x15
    80003662:	6a2a8a93          	addi	s5,s5,1698 # 80018d00 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003666:	00015a17          	auipc	s4,0x15
    8000366a:	66aa0a13          	addi	s4,s4,1642 # 80018cd0 <log>
    8000366e:	018a2583          	lw	a1,24(s4)
    80003672:	012585bb          	addw	a1,a1,s2
    80003676:	2585                	addiw	a1,a1,1
    80003678:	028a2503          	lw	a0,40(s4)
    8000367c:	fffff097          	auipc	ra,0xfffff
    80003680:	cc4080e7          	jalr	-828(ra) # 80002340 <bread>
    80003684:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003686:	000aa583          	lw	a1,0(s5)
    8000368a:	028a2503          	lw	a0,40(s4)
    8000368e:	fffff097          	auipc	ra,0xfffff
    80003692:	cb2080e7          	jalr	-846(ra) # 80002340 <bread>
    80003696:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003698:	40000613          	li	a2,1024
    8000369c:	05850593          	addi	a1,a0,88
    800036a0:	05848513          	addi	a0,s1,88
    800036a4:	ffffd097          	auipc	ra,0xffffd
    800036a8:	b32080e7          	jalr	-1230(ra) # 800001d6 <memmove>
    bwrite(to);  // write the log
    800036ac:	8526                	mv	a0,s1
    800036ae:	fffff097          	auipc	ra,0xfffff
    800036b2:	d84080e7          	jalr	-636(ra) # 80002432 <bwrite>
    brelse(from);
    800036b6:	854e                	mv	a0,s3
    800036b8:	fffff097          	auipc	ra,0xfffff
    800036bc:	db8080e7          	jalr	-584(ra) # 80002470 <brelse>
    brelse(to);
    800036c0:	8526                	mv	a0,s1
    800036c2:	fffff097          	auipc	ra,0xfffff
    800036c6:	dae080e7          	jalr	-594(ra) # 80002470 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800036ca:	2905                	addiw	s2,s2,1
    800036cc:	0a91                	addi	s5,s5,4
    800036ce:	02ca2783          	lw	a5,44(s4)
    800036d2:	f8f94ee3          	blt	s2,a5,8000366e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800036d6:	00000097          	auipc	ra,0x0
    800036da:	c68080e7          	jalr	-920(ra) # 8000333e <write_head>
    install_trans(0); // Now install writes to home locations
    800036de:	4501                	li	a0,0
    800036e0:	00000097          	auipc	ra,0x0
    800036e4:	cda080e7          	jalr	-806(ra) # 800033ba <install_trans>
    log.lh.n = 0;
    800036e8:	00015797          	auipc	a5,0x15
    800036ec:	6007aa23          	sw	zero,1556(a5) # 80018cfc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800036f0:	00000097          	auipc	ra,0x0
    800036f4:	c4e080e7          	jalr	-946(ra) # 8000333e <write_head>
    800036f8:	bdf5                	j	800035f4 <end_op+0x52>

00000000800036fa <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800036fa:	1101                	addi	sp,sp,-32
    800036fc:	ec06                	sd	ra,24(sp)
    800036fe:	e822                	sd	s0,16(sp)
    80003700:	e426                	sd	s1,8(sp)
    80003702:	e04a                	sd	s2,0(sp)
    80003704:	1000                	addi	s0,sp,32
    80003706:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003708:	00015917          	auipc	s2,0x15
    8000370c:	5c890913          	addi	s2,s2,1480 # 80018cd0 <log>
    80003710:	854a                	mv	a0,s2
    80003712:	00003097          	auipc	ra,0x3
    80003716:	a32080e7          	jalr	-1486(ra) # 80006144 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000371a:	02c92603          	lw	a2,44(s2)
    8000371e:	47f5                	li	a5,29
    80003720:	06c7c563          	blt	a5,a2,8000378a <log_write+0x90>
    80003724:	00015797          	auipc	a5,0x15
    80003728:	5c87a783          	lw	a5,1480(a5) # 80018cec <log+0x1c>
    8000372c:	37fd                	addiw	a5,a5,-1
    8000372e:	04f65e63          	bge	a2,a5,8000378a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003732:	00015797          	auipc	a5,0x15
    80003736:	5be7a783          	lw	a5,1470(a5) # 80018cf0 <log+0x20>
    8000373a:	06f05063          	blez	a5,8000379a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000373e:	4781                	li	a5,0
    80003740:	06c05563          	blez	a2,800037aa <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003744:	44cc                	lw	a1,12(s1)
    80003746:	00015717          	auipc	a4,0x15
    8000374a:	5ba70713          	addi	a4,a4,1466 # 80018d00 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000374e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003750:	4314                	lw	a3,0(a4)
    80003752:	04b68c63          	beq	a3,a1,800037aa <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80003756:	2785                	addiw	a5,a5,1
    80003758:	0711                	addi	a4,a4,4
    8000375a:	fef61be3          	bne	a2,a5,80003750 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000375e:	0621                	addi	a2,a2,8
    80003760:	060a                	slli	a2,a2,0x2
    80003762:	00015797          	auipc	a5,0x15
    80003766:	56e78793          	addi	a5,a5,1390 # 80018cd0 <log>
    8000376a:	97b2                	add	a5,a5,a2
    8000376c:	44d8                	lw	a4,12(s1)
    8000376e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003770:	8526                	mv	a0,s1
    80003772:	fffff097          	auipc	ra,0xfffff
    80003776:	d9c080e7          	jalr	-612(ra) # 8000250e <bpin>
    log.lh.n++;
    8000377a:	00015717          	auipc	a4,0x15
    8000377e:	55670713          	addi	a4,a4,1366 # 80018cd0 <log>
    80003782:	575c                	lw	a5,44(a4)
    80003784:	2785                	addiw	a5,a5,1
    80003786:	d75c                	sw	a5,44(a4)
    80003788:	a82d                	j	800037c2 <log_write+0xc8>
    panic("too big a transaction");
    8000378a:	00005517          	auipc	a0,0x5
    8000378e:	e3650513          	addi	a0,a0,-458 # 800085c0 <syscalls+0x1f0>
    80003792:	00002097          	auipc	ra,0x2
    80003796:	47a080e7          	jalr	1146(ra) # 80005c0c <panic>
    panic("log_write outside of trans");
    8000379a:	00005517          	auipc	a0,0x5
    8000379e:	e3e50513          	addi	a0,a0,-450 # 800085d8 <syscalls+0x208>
    800037a2:	00002097          	auipc	ra,0x2
    800037a6:	46a080e7          	jalr	1130(ra) # 80005c0c <panic>
  log.lh.block[i] = b->blockno;
    800037aa:	00878693          	addi	a3,a5,8
    800037ae:	068a                	slli	a3,a3,0x2
    800037b0:	00015717          	auipc	a4,0x15
    800037b4:	52070713          	addi	a4,a4,1312 # 80018cd0 <log>
    800037b8:	9736                	add	a4,a4,a3
    800037ba:	44d4                	lw	a3,12(s1)
    800037bc:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800037be:	faf609e3          	beq	a2,a5,80003770 <log_write+0x76>
  }
  release(&log.lock);
    800037c2:	00015517          	auipc	a0,0x15
    800037c6:	50e50513          	addi	a0,a0,1294 # 80018cd0 <log>
    800037ca:	00003097          	auipc	ra,0x3
    800037ce:	a2e080e7          	jalr	-1490(ra) # 800061f8 <release>
}
    800037d2:	60e2                	ld	ra,24(sp)
    800037d4:	6442                	ld	s0,16(sp)
    800037d6:	64a2                	ld	s1,8(sp)
    800037d8:	6902                	ld	s2,0(sp)
    800037da:	6105                	addi	sp,sp,32
    800037dc:	8082                	ret

00000000800037de <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800037de:	1101                	addi	sp,sp,-32
    800037e0:	ec06                	sd	ra,24(sp)
    800037e2:	e822                	sd	s0,16(sp)
    800037e4:	e426                	sd	s1,8(sp)
    800037e6:	e04a                	sd	s2,0(sp)
    800037e8:	1000                	addi	s0,sp,32
    800037ea:	84aa                	mv	s1,a0
    800037ec:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800037ee:	00005597          	auipc	a1,0x5
    800037f2:	e0a58593          	addi	a1,a1,-502 # 800085f8 <syscalls+0x228>
    800037f6:	0521                	addi	a0,a0,8
    800037f8:	00003097          	auipc	ra,0x3
    800037fc:	8bc080e7          	jalr	-1860(ra) # 800060b4 <initlock>
  lk->name = name;
    80003800:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003804:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003808:	0204a423          	sw	zero,40(s1)
}
    8000380c:	60e2                	ld	ra,24(sp)
    8000380e:	6442                	ld	s0,16(sp)
    80003810:	64a2                	ld	s1,8(sp)
    80003812:	6902                	ld	s2,0(sp)
    80003814:	6105                	addi	sp,sp,32
    80003816:	8082                	ret

0000000080003818 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003818:	1101                	addi	sp,sp,-32
    8000381a:	ec06                	sd	ra,24(sp)
    8000381c:	e822                	sd	s0,16(sp)
    8000381e:	e426                	sd	s1,8(sp)
    80003820:	e04a                	sd	s2,0(sp)
    80003822:	1000                	addi	s0,sp,32
    80003824:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003826:	00850913          	addi	s2,a0,8
    8000382a:	854a                	mv	a0,s2
    8000382c:	00003097          	auipc	ra,0x3
    80003830:	918080e7          	jalr	-1768(ra) # 80006144 <acquire>
  while (lk->locked) {
    80003834:	409c                	lw	a5,0(s1)
    80003836:	cb89                	beqz	a5,80003848 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003838:	85ca                	mv	a1,s2
    8000383a:	8526                	mv	a0,s1
    8000383c:	ffffe097          	auipc	ra,0xffffe
    80003840:	ccc080e7          	jalr	-820(ra) # 80001508 <sleep>
  while (lk->locked) {
    80003844:	409c                	lw	a5,0(s1)
    80003846:	fbed                	bnez	a5,80003838 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003848:	4785                	li	a5,1
    8000384a:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	608080e7          	jalr	1544(ra) # 80000e54 <myproc>
    80003854:	591c                	lw	a5,48(a0)
    80003856:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003858:	854a                	mv	a0,s2
    8000385a:	00003097          	auipc	ra,0x3
    8000385e:	99e080e7          	jalr	-1634(ra) # 800061f8 <release>
}
    80003862:	60e2                	ld	ra,24(sp)
    80003864:	6442                	ld	s0,16(sp)
    80003866:	64a2                	ld	s1,8(sp)
    80003868:	6902                	ld	s2,0(sp)
    8000386a:	6105                	addi	sp,sp,32
    8000386c:	8082                	ret

000000008000386e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000386e:	1101                	addi	sp,sp,-32
    80003870:	ec06                	sd	ra,24(sp)
    80003872:	e822                	sd	s0,16(sp)
    80003874:	e426                	sd	s1,8(sp)
    80003876:	e04a                	sd	s2,0(sp)
    80003878:	1000                	addi	s0,sp,32
    8000387a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000387c:	00850913          	addi	s2,a0,8
    80003880:	854a                	mv	a0,s2
    80003882:	00003097          	auipc	ra,0x3
    80003886:	8c2080e7          	jalr	-1854(ra) # 80006144 <acquire>
  lk->locked = 0;
    8000388a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000388e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003892:	8526                	mv	a0,s1
    80003894:	ffffe097          	auipc	ra,0xffffe
    80003898:	cd8080e7          	jalr	-808(ra) # 8000156c <wakeup>
  release(&lk->lk);
    8000389c:	854a                	mv	a0,s2
    8000389e:	00003097          	auipc	ra,0x3
    800038a2:	95a080e7          	jalr	-1702(ra) # 800061f8 <release>
}
    800038a6:	60e2                	ld	ra,24(sp)
    800038a8:	6442                	ld	s0,16(sp)
    800038aa:	64a2                	ld	s1,8(sp)
    800038ac:	6902                	ld	s2,0(sp)
    800038ae:	6105                	addi	sp,sp,32
    800038b0:	8082                	ret

00000000800038b2 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800038b2:	7179                	addi	sp,sp,-48
    800038b4:	f406                	sd	ra,40(sp)
    800038b6:	f022                	sd	s0,32(sp)
    800038b8:	ec26                	sd	s1,24(sp)
    800038ba:	e84a                	sd	s2,16(sp)
    800038bc:	e44e                	sd	s3,8(sp)
    800038be:	1800                	addi	s0,sp,48
    800038c0:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800038c2:	00850913          	addi	s2,a0,8
    800038c6:	854a                	mv	a0,s2
    800038c8:	00003097          	auipc	ra,0x3
    800038cc:	87c080e7          	jalr	-1924(ra) # 80006144 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800038d0:	409c                	lw	a5,0(s1)
    800038d2:	ef99                	bnez	a5,800038f0 <holdingsleep+0x3e>
    800038d4:	4481                	li	s1,0
  release(&lk->lk);
    800038d6:	854a                	mv	a0,s2
    800038d8:	00003097          	auipc	ra,0x3
    800038dc:	920080e7          	jalr	-1760(ra) # 800061f8 <release>
  return r;
}
    800038e0:	8526                	mv	a0,s1
    800038e2:	70a2                	ld	ra,40(sp)
    800038e4:	7402                	ld	s0,32(sp)
    800038e6:	64e2                	ld	s1,24(sp)
    800038e8:	6942                	ld	s2,16(sp)
    800038ea:	69a2                	ld	s3,8(sp)
    800038ec:	6145                	addi	sp,sp,48
    800038ee:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800038f0:	0284a983          	lw	s3,40(s1)
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	560080e7          	jalr	1376(ra) # 80000e54 <myproc>
    800038fc:	5904                	lw	s1,48(a0)
    800038fe:	413484b3          	sub	s1,s1,s3
    80003902:	0014b493          	seqz	s1,s1
    80003906:	bfc1                	j	800038d6 <holdingsleep+0x24>

0000000080003908 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003908:	1141                	addi	sp,sp,-16
    8000390a:	e406                	sd	ra,8(sp)
    8000390c:	e022                	sd	s0,0(sp)
    8000390e:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003910:	00005597          	auipc	a1,0x5
    80003914:	cf858593          	addi	a1,a1,-776 # 80008608 <syscalls+0x238>
    80003918:	00015517          	auipc	a0,0x15
    8000391c:	50050513          	addi	a0,a0,1280 # 80018e18 <ftable>
    80003920:	00002097          	auipc	ra,0x2
    80003924:	794080e7          	jalr	1940(ra) # 800060b4 <initlock>
}
    80003928:	60a2                	ld	ra,8(sp)
    8000392a:	6402                	ld	s0,0(sp)
    8000392c:	0141                	addi	sp,sp,16
    8000392e:	8082                	ret

0000000080003930 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003930:	1101                	addi	sp,sp,-32
    80003932:	ec06                	sd	ra,24(sp)
    80003934:	e822                	sd	s0,16(sp)
    80003936:	e426                	sd	s1,8(sp)
    80003938:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000393a:	00015517          	auipc	a0,0x15
    8000393e:	4de50513          	addi	a0,a0,1246 # 80018e18 <ftable>
    80003942:	00003097          	auipc	ra,0x3
    80003946:	802080e7          	jalr	-2046(ra) # 80006144 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000394a:	00015497          	auipc	s1,0x15
    8000394e:	4e648493          	addi	s1,s1,1254 # 80018e30 <ftable+0x18>
    80003952:	00016717          	auipc	a4,0x16
    80003956:	47e70713          	addi	a4,a4,1150 # 80019dd0 <disk>
    if(f->ref == 0){
    8000395a:	40dc                	lw	a5,4(s1)
    8000395c:	cf99                	beqz	a5,8000397a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000395e:	02848493          	addi	s1,s1,40
    80003962:	fee49ce3          	bne	s1,a4,8000395a <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003966:	00015517          	auipc	a0,0x15
    8000396a:	4b250513          	addi	a0,a0,1202 # 80018e18 <ftable>
    8000396e:	00003097          	auipc	ra,0x3
    80003972:	88a080e7          	jalr	-1910(ra) # 800061f8 <release>
  return 0;
    80003976:	4481                	li	s1,0
    80003978:	a819                	j	8000398e <filealloc+0x5e>
      f->ref = 1;
    8000397a:	4785                	li	a5,1
    8000397c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000397e:	00015517          	auipc	a0,0x15
    80003982:	49a50513          	addi	a0,a0,1178 # 80018e18 <ftable>
    80003986:	00003097          	auipc	ra,0x3
    8000398a:	872080e7          	jalr	-1934(ra) # 800061f8 <release>
}
    8000398e:	8526                	mv	a0,s1
    80003990:	60e2                	ld	ra,24(sp)
    80003992:	6442                	ld	s0,16(sp)
    80003994:	64a2                	ld	s1,8(sp)
    80003996:	6105                	addi	sp,sp,32
    80003998:	8082                	ret

000000008000399a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000399a:	1101                	addi	sp,sp,-32
    8000399c:	ec06                	sd	ra,24(sp)
    8000399e:	e822                	sd	s0,16(sp)
    800039a0:	e426                	sd	s1,8(sp)
    800039a2:	1000                	addi	s0,sp,32
    800039a4:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800039a6:	00015517          	auipc	a0,0x15
    800039aa:	47250513          	addi	a0,a0,1138 # 80018e18 <ftable>
    800039ae:	00002097          	auipc	ra,0x2
    800039b2:	796080e7          	jalr	1942(ra) # 80006144 <acquire>
  if(f->ref < 1)
    800039b6:	40dc                	lw	a5,4(s1)
    800039b8:	02f05263          	blez	a5,800039dc <filedup+0x42>
    panic("filedup");
  f->ref++;
    800039bc:	2785                	addiw	a5,a5,1
    800039be:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800039c0:	00015517          	auipc	a0,0x15
    800039c4:	45850513          	addi	a0,a0,1112 # 80018e18 <ftable>
    800039c8:	00003097          	auipc	ra,0x3
    800039cc:	830080e7          	jalr	-2000(ra) # 800061f8 <release>
  return f;
}
    800039d0:	8526                	mv	a0,s1
    800039d2:	60e2                	ld	ra,24(sp)
    800039d4:	6442                	ld	s0,16(sp)
    800039d6:	64a2                	ld	s1,8(sp)
    800039d8:	6105                	addi	sp,sp,32
    800039da:	8082                	ret
    panic("filedup");
    800039dc:	00005517          	auipc	a0,0x5
    800039e0:	c3450513          	addi	a0,a0,-972 # 80008610 <syscalls+0x240>
    800039e4:	00002097          	auipc	ra,0x2
    800039e8:	228080e7          	jalr	552(ra) # 80005c0c <panic>

00000000800039ec <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800039ec:	7139                	addi	sp,sp,-64
    800039ee:	fc06                	sd	ra,56(sp)
    800039f0:	f822                	sd	s0,48(sp)
    800039f2:	f426                	sd	s1,40(sp)
    800039f4:	f04a                	sd	s2,32(sp)
    800039f6:	ec4e                	sd	s3,24(sp)
    800039f8:	e852                	sd	s4,16(sp)
    800039fa:	e456                	sd	s5,8(sp)
    800039fc:	0080                	addi	s0,sp,64
    800039fe:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003a00:	00015517          	auipc	a0,0x15
    80003a04:	41850513          	addi	a0,a0,1048 # 80018e18 <ftable>
    80003a08:	00002097          	auipc	ra,0x2
    80003a0c:	73c080e7          	jalr	1852(ra) # 80006144 <acquire>
  if(f->ref < 1)
    80003a10:	40dc                	lw	a5,4(s1)
    80003a12:	06f05163          	blez	a5,80003a74 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003a16:	37fd                	addiw	a5,a5,-1
    80003a18:	0007871b          	sext.w	a4,a5
    80003a1c:	c0dc                	sw	a5,4(s1)
    80003a1e:	06e04363          	bgtz	a4,80003a84 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003a22:	0004a903          	lw	s2,0(s1)
    80003a26:	0094ca83          	lbu	s5,9(s1)
    80003a2a:	0104ba03          	ld	s4,16(s1)
    80003a2e:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003a32:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003a36:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003a3a:	00015517          	auipc	a0,0x15
    80003a3e:	3de50513          	addi	a0,a0,990 # 80018e18 <ftable>
    80003a42:	00002097          	auipc	ra,0x2
    80003a46:	7b6080e7          	jalr	1974(ra) # 800061f8 <release>

  if(ff.type == FD_PIPE){
    80003a4a:	4785                	li	a5,1
    80003a4c:	04f90d63          	beq	s2,a5,80003aa6 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003a50:	3979                	addiw	s2,s2,-2
    80003a52:	4785                	li	a5,1
    80003a54:	0527e063          	bltu	a5,s2,80003a94 <fileclose+0xa8>
    begin_op();
    80003a58:	00000097          	auipc	ra,0x0
    80003a5c:	acc080e7          	jalr	-1332(ra) # 80003524 <begin_op>
    iput(ff.ip);
    80003a60:	854e                	mv	a0,s3
    80003a62:	fffff097          	auipc	ra,0xfffff
    80003a66:	2b0080e7          	jalr	688(ra) # 80002d12 <iput>
    end_op();
    80003a6a:	00000097          	auipc	ra,0x0
    80003a6e:	b38080e7          	jalr	-1224(ra) # 800035a2 <end_op>
    80003a72:	a00d                	j	80003a94 <fileclose+0xa8>
    panic("fileclose");
    80003a74:	00005517          	auipc	a0,0x5
    80003a78:	ba450513          	addi	a0,a0,-1116 # 80008618 <syscalls+0x248>
    80003a7c:	00002097          	auipc	ra,0x2
    80003a80:	190080e7          	jalr	400(ra) # 80005c0c <panic>
    release(&ftable.lock);
    80003a84:	00015517          	auipc	a0,0x15
    80003a88:	39450513          	addi	a0,a0,916 # 80018e18 <ftable>
    80003a8c:	00002097          	auipc	ra,0x2
    80003a90:	76c080e7          	jalr	1900(ra) # 800061f8 <release>
  }
}
    80003a94:	70e2                	ld	ra,56(sp)
    80003a96:	7442                	ld	s0,48(sp)
    80003a98:	74a2                	ld	s1,40(sp)
    80003a9a:	7902                	ld	s2,32(sp)
    80003a9c:	69e2                	ld	s3,24(sp)
    80003a9e:	6a42                	ld	s4,16(sp)
    80003aa0:	6aa2                	ld	s5,8(sp)
    80003aa2:	6121                	addi	sp,sp,64
    80003aa4:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003aa6:	85d6                	mv	a1,s5
    80003aa8:	8552                	mv	a0,s4
    80003aaa:	00000097          	auipc	ra,0x0
    80003aae:	34c080e7          	jalr	844(ra) # 80003df6 <pipeclose>
    80003ab2:	b7cd                	j	80003a94 <fileclose+0xa8>

0000000080003ab4 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003ab4:	715d                	addi	sp,sp,-80
    80003ab6:	e486                	sd	ra,72(sp)
    80003ab8:	e0a2                	sd	s0,64(sp)
    80003aba:	fc26                	sd	s1,56(sp)
    80003abc:	f84a                	sd	s2,48(sp)
    80003abe:	f44e                	sd	s3,40(sp)
    80003ac0:	0880                	addi	s0,sp,80
    80003ac2:	84aa                	mv	s1,a0
    80003ac4:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003ac6:	ffffd097          	auipc	ra,0xffffd
    80003aca:	38e080e7          	jalr	910(ra) # 80000e54 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003ace:	409c                	lw	a5,0(s1)
    80003ad0:	37f9                	addiw	a5,a5,-2
    80003ad2:	4705                	li	a4,1
    80003ad4:	04f76763          	bltu	a4,a5,80003b22 <filestat+0x6e>
    80003ad8:	892a                	mv	s2,a0
    ilock(f->ip);
    80003ada:	6c88                	ld	a0,24(s1)
    80003adc:	fffff097          	auipc	ra,0xfffff
    80003ae0:	07c080e7          	jalr	124(ra) # 80002b58 <ilock>
    stati(f->ip, &st);
    80003ae4:	fb840593          	addi	a1,s0,-72
    80003ae8:	6c88                	ld	a0,24(s1)
    80003aea:	fffff097          	auipc	ra,0xfffff
    80003aee:	2f8080e7          	jalr	760(ra) # 80002de2 <stati>
    iunlock(f->ip);
    80003af2:	6c88                	ld	a0,24(s1)
    80003af4:	fffff097          	auipc	ra,0xfffff
    80003af8:	126080e7          	jalr	294(ra) # 80002c1a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003afc:	46e1                	li	a3,24
    80003afe:	fb840613          	addi	a2,s0,-72
    80003b02:	85ce                	mv	a1,s3
    80003b04:	05093503          	ld	a0,80(s2)
    80003b08:	ffffd097          	auipc	ra,0xffffd
    80003b0c:	00c080e7          	jalr	12(ra) # 80000b14 <copyout>
    80003b10:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003b14:	60a6                	ld	ra,72(sp)
    80003b16:	6406                	ld	s0,64(sp)
    80003b18:	74e2                	ld	s1,56(sp)
    80003b1a:	7942                	ld	s2,48(sp)
    80003b1c:	79a2                	ld	s3,40(sp)
    80003b1e:	6161                	addi	sp,sp,80
    80003b20:	8082                	ret
  return -1;
    80003b22:	557d                	li	a0,-1
    80003b24:	bfc5                	j	80003b14 <filestat+0x60>

0000000080003b26 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003b26:	7179                	addi	sp,sp,-48
    80003b28:	f406                	sd	ra,40(sp)
    80003b2a:	f022                	sd	s0,32(sp)
    80003b2c:	ec26                	sd	s1,24(sp)
    80003b2e:	e84a                	sd	s2,16(sp)
    80003b30:	e44e                	sd	s3,8(sp)
    80003b32:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003b34:	00854783          	lbu	a5,8(a0)
    80003b38:	c3d5                	beqz	a5,80003bdc <fileread+0xb6>
    80003b3a:	84aa                	mv	s1,a0
    80003b3c:	89ae                	mv	s3,a1
    80003b3e:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003b40:	411c                	lw	a5,0(a0)
    80003b42:	4705                	li	a4,1
    80003b44:	04e78963          	beq	a5,a4,80003b96 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003b48:	470d                	li	a4,3
    80003b4a:	04e78d63          	beq	a5,a4,80003ba4 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003b4e:	4709                	li	a4,2
    80003b50:	06e79e63          	bne	a5,a4,80003bcc <fileread+0xa6>
    ilock(f->ip);
    80003b54:	6d08                	ld	a0,24(a0)
    80003b56:	fffff097          	auipc	ra,0xfffff
    80003b5a:	002080e7          	jalr	2(ra) # 80002b58 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003b5e:	874a                	mv	a4,s2
    80003b60:	5094                	lw	a3,32(s1)
    80003b62:	864e                	mv	a2,s3
    80003b64:	4585                	li	a1,1
    80003b66:	6c88                	ld	a0,24(s1)
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	2a4080e7          	jalr	676(ra) # 80002e0c <readi>
    80003b70:	892a                	mv	s2,a0
    80003b72:	00a05563          	blez	a0,80003b7c <fileread+0x56>
      f->off += r;
    80003b76:	509c                	lw	a5,32(s1)
    80003b78:	9fa9                	addw	a5,a5,a0
    80003b7a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003b7c:	6c88                	ld	a0,24(s1)
    80003b7e:	fffff097          	auipc	ra,0xfffff
    80003b82:	09c080e7          	jalr	156(ra) # 80002c1a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003b86:	854a                	mv	a0,s2
    80003b88:	70a2                	ld	ra,40(sp)
    80003b8a:	7402                	ld	s0,32(sp)
    80003b8c:	64e2                	ld	s1,24(sp)
    80003b8e:	6942                	ld	s2,16(sp)
    80003b90:	69a2                	ld	s3,8(sp)
    80003b92:	6145                	addi	sp,sp,48
    80003b94:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003b96:	6908                	ld	a0,16(a0)
    80003b98:	00000097          	auipc	ra,0x0
    80003b9c:	3c6080e7          	jalr	966(ra) # 80003f5e <piperead>
    80003ba0:	892a                	mv	s2,a0
    80003ba2:	b7d5                	j	80003b86 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003ba4:	02451783          	lh	a5,36(a0)
    80003ba8:	03079693          	slli	a3,a5,0x30
    80003bac:	92c1                	srli	a3,a3,0x30
    80003bae:	4725                	li	a4,9
    80003bb0:	02d76863          	bltu	a4,a3,80003be0 <fileread+0xba>
    80003bb4:	0792                	slli	a5,a5,0x4
    80003bb6:	00015717          	auipc	a4,0x15
    80003bba:	1c270713          	addi	a4,a4,450 # 80018d78 <devsw>
    80003bbe:	97ba                	add	a5,a5,a4
    80003bc0:	639c                	ld	a5,0(a5)
    80003bc2:	c38d                	beqz	a5,80003be4 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003bc4:	4505                	li	a0,1
    80003bc6:	9782                	jalr	a5
    80003bc8:	892a                	mv	s2,a0
    80003bca:	bf75                	j	80003b86 <fileread+0x60>
    panic("fileread");
    80003bcc:	00005517          	auipc	a0,0x5
    80003bd0:	a5c50513          	addi	a0,a0,-1444 # 80008628 <syscalls+0x258>
    80003bd4:	00002097          	auipc	ra,0x2
    80003bd8:	038080e7          	jalr	56(ra) # 80005c0c <panic>
    return -1;
    80003bdc:	597d                	li	s2,-1
    80003bde:	b765                	j	80003b86 <fileread+0x60>
      return -1;
    80003be0:	597d                	li	s2,-1
    80003be2:	b755                	j	80003b86 <fileread+0x60>
    80003be4:	597d                	li	s2,-1
    80003be6:	b745                	j	80003b86 <fileread+0x60>

0000000080003be8 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003be8:	715d                	addi	sp,sp,-80
    80003bea:	e486                	sd	ra,72(sp)
    80003bec:	e0a2                	sd	s0,64(sp)
    80003bee:	fc26                	sd	s1,56(sp)
    80003bf0:	f84a                	sd	s2,48(sp)
    80003bf2:	f44e                	sd	s3,40(sp)
    80003bf4:	f052                	sd	s4,32(sp)
    80003bf6:	ec56                	sd	s5,24(sp)
    80003bf8:	e85a                	sd	s6,16(sp)
    80003bfa:	e45e                	sd	s7,8(sp)
    80003bfc:	e062                	sd	s8,0(sp)
    80003bfe:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003c00:	00954783          	lbu	a5,9(a0)
    80003c04:	10078663          	beqz	a5,80003d10 <filewrite+0x128>
    80003c08:	892a                	mv	s2,a0
    80003c0a:	8b2e                	mv	s6,a1
    80003c0c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003c0e:	411c                	lw	a5,0(a0)
    80003c10:	4705                	li	a4,1
    80003c12:	02e78263          	beq	a5,a4,80003c36 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003c16:	470d                	li	a4,3
    80003c18:	02e78663          	beq	a5,a4,80003c44 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003c1c:	4709                	li	a4,2
    80003c1e:	0ee79163          	bne	a5,a4,80003d00 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003c22:	0ac05d63          	blez	a2,80003cdc <filewrite+0xf4>
    int i = 0;
    80003c26:	4981                	li	s3,0
    80003c28:	6b85                	lui	s7,0x1
    80003c2a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003c2e:	6c05                	lui	s8,0x1
    80003c30:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003c34:	a861                	j	80003ccc <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003c36:	6908                	ld	a0,16(a0)
    80003c38:	00000097          	auipc	ra,0x0
    80003c3c:	22e080e7          	jalr	558(ra) # 80003e66 <pipewrite>
    80003c40:	8a2a                	mv	s4,a0
    80003c42:	a045                	j	80003ce2 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003c44:	02451783          	lh	a5,36(a0)
    80003c48:	03079693          	slli	a3,a5,0x30
    80003c4c:	92c1                	srli	a3,a3,0x30
    80003c4e:	4725                	li	a4,9
    80003c50:	0cd76263          	bltu	a4,a3,80003d14 <filewrite+0x12c>
    80003c54:	0792                	slli	a5,a5,0x4
    80003c56:	00015717          	auipc	a4,0x15
    80003c5a:	12270713          	addi	a4,a4,290 # 80018d78 <devsw>
    80003c5e:	97ba                	add	a5,a5,a4
    80003c60:	679c                	ld	a5,8(a5)
    80003c62:	cbdd                	beqz	a5,80003d18 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003c64:	4505                	li	a0,1
    80003c66:	9782                	jalr	a5
    80003c68:	8a2a                	mv	s4,a0
    80003c6a:	a8a5                	j	80003ce2 <filewrite+0xfa>
    80003c6c:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003c70:	00000097          	auipc	ra,0x0
    80003c74:	8b4080e7          	jalr	-1868(ra) # 80003524 <begin_op>
      ilock(f->ip);
    80003c78:	01893503          	ld	a0,24(s2)
    80003c7c:	fffff097          	auipc	ra,0xfffff
    80003c80:	edc080e7          	jalr	-292(ra) # 80002b58 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003c84:	8756                	mv	a4,s5
    80003c86:	02092683          	lw	a3,32(s2)
    80003c8a:	01698633          	add	a2,s3,s6
    80003c8e:	4585                	li	a1,1
    80003c90:	01893503          	ld	a0,24(s2)
    80003c94:	fffff097          	auipc	ra,0xfffff
    80003c98:	270080e7          	jalr	624(ra) # 80002f04 <writei>
    80003c9c:	84aa                	mv	s1,a0
    80003c9e:	00a05763          	blez	a0,80003cac <filewrite+0xc4>
        f->off += r;
    80003ca2:	02092783          	lw	a5,32(s2)
    80003ca6:	9fa9                	addw	a5,a5,a0
    80003ca8:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003cac:	01893503          	ld	a0,24(s2)
    80003cb0:	fffff097          	auipc	ra,0xfffff
    80003cb4:	f6a080e7          	jalr	-150(ra) # 80002c1a <iunlock>
      end_op();
    80003cb8:	00000097          	auipc	ra,0x0
    80003cbc:	8ea080e7          	jalr	-1814(ra) # 800035a2 <end_op>

      if(r != n1){
    80003cc0:	009a9f63          	bne	s5,s1,80003cde <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003cc4:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003cc8:	0149db63          	bge	s3,s4,80003cde <filewrite+0xf6>
      int n1 = n - i;
    80003ccc:	413a04bb          	subw	s1,s4,s3
    80003cd0:	0004879b          	sext.w	a5,s1
    80003cd4:	f8fbdce3          	bge	s7,a5,80003c6c <filewrite+0x84>
    80003cd8:	84e2                	mv	s1,s8
    80003cda:	bf49                	j	80003c6c <filewrite+0x84>
    int i = 0;
    80003cdc:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003cde:	013a1f63          	bne	s4,s3,80003cfc <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003ce2:	8552                	mv	a0,s4
    80003ce4:	60a6                	ld	ra,72(sp)
    80003ce6:	6406                	ld	s0,64(sp)
    80003ce8:	74e2                	ld	s1,56(sp)
    80003cea:	7942                	ld	s2,48(sp)
    80003cec:	79a2                	ld	s3,40(sp)
    80003cee:	7a02                	ld	s4,32(sp)
    80003cf0:	6ae2                	ld	s5,24(sp)
    80003cf2:	6b42                	ld	s6,16(sp)
    80003cf4:	6ba2                	ld	s7,8(sp)
    80003cf6:	6c02                	ld	s8,0(sp)
    80003cf8:	6161                	addi	sp,sp,80
    80003cfa:	8082                	ret
    ret = (i == n ? n : -1);
    80003cfc:	5a7d                	li	s4,-1
    80003cfe:	b7d5                	j	80003ce2 <filewrite+0xfa>
    panic("filewrite");
    80003d00:	00005517          	auipc	a0,0x5
    80003d04:	93850513          	addi	a0,a0,-1736 # 80008638 <syscalls+0x268>
    80003d08:	00002097          	auipc	ra,0x2
    80003d0c:	f04080e7          	jalr	-252(ra) # 80005c0c <panic>
    return -1;
    80003d10:	5a7d                	li	s4,-1
    80003d12:	bfc1                	j	80003ce2 <filewrite+0xfa>
      return -1;
    80003d14:	5a7d                	li	s4,-1
    80003d16:	b7f1                	j	80003ce2 <filewrite+0xfa>
    80003d18:	5a7d                	li	s4,-1
    80003d1a:	b7e1                	j	80003ce2 <filewrite+0xfa>

0000000080003d1c <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003d1c:	7179                	addi	sp,sp,-48
    80003d1e:	f406                	sd	ra,40(sp)
    80003d20:	f022                	sd	s0,32(sp)
    80003d22:	ec26                	sd	s1,24(sp)
    80003d24:	e84a                	sd	s2,16(sp)
    80003d26:	e44e                	sd	s3,8(sp)
    80003d28:	e052                	sd	s4,0(sp)
    80003d2a:	1800                	addi	s0,sp,48
    80003d2c:	84aa                	mv	s1,a0
    80003d2e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003d30:	0005b023          	sd	zero,0(a1)
    80003d34:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003d38:	00000097          	auipc	ra,0x0
    80003d3c:	bf8080e7          	jalr	-1032(ra) # 80003930 <filealloc>
    80003d40:	e088                	sd	a0,0(s1)
    80003d42:	c551                	beqz	a0,80003dce <pipealloc+0xb2>
    80003d44:	00000097          	auipc	ra,0x0
    80003d48:	bec080e7          	jalr	-1044(ra) # 80003930 <filealloc>
    80003d4c:	00aa3023          	sd	a0,0(s4)
    80003d50:	c92d                	beqz	a0,80003dc2 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003d52:	ffffc097          	auipc	ra,0xffffc
    80003d56:	3c8080e7          	jalr	968(ra) # 8000011a <kalloc>
    80003d5a:	892a                	mv	s2,a0
    80003d5c:	c125                	beqz	a0,80003dbc <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003d5e:	4985                	li	s3,1
    80003d60:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003d64:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003d68:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003d6c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003d70:	00005597          	auipc	a1,0x5
    80003d74:	8d858593          	addi	a1,a1,-1832 # 80008648 <syscalls+0x278>
    80003d78:	00002097          	auipc	ra,0x2
    80003d7c:	33c080e7          	jalr	828(ra) # 800060b4 <initlock>
  (*f0)->type = FD_PIPE;
    80003d80:	609c                	ld	a5,0(s1)
    80003d82:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003d86:	609c                	ld	a5,0(s1)
    80003d88:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003d8c:	609c                	ld	a5,0(s1)
    80003d8e:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003d92:	609c                	ld	a5,0(s1)
    80003d94:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003d98:	000a3783          	ld	a5,0(s4)
    80003d9c:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003da0:	000a3783          	ld	a5,0(s4)
    80003da4:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003da8:	000a3783          	ld	a5,0(s4)
    80003dac:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003db0:	000a3783          	ld	a5,0(s4)
    80003db4:	0127b823          	sd	s2,16(a5)
  return 0;
    80003db8:	4501                	li	a0,0
    80003dba:	a025                	j	80003de2 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003dbc:	6088                	ld	a0,0(s1)
    80003dbe:	e501                	bnez	a0,80003dc6 <pipealloc+0xaa>
    80003dc0:	a039                	j	80003dce <pipealloc+0xb2>
    80003dc2:	6088                	ld	a0,0(s1)
    80003dc4:	c51d                	beqz	a0,80003df2 <pipealloc+0xd6>
    fileclose(*f0);
    80003dc6:	00000097          	auipc	ra,0x0
    80003dca:	c26080e7          	jalr	-986(ra) # 800039ec <fileclose>
  if(*f1)
    80003dce:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003dd2:	557d                	li	a0,-1
  if(*f1)
    80003dd4:	c799                	beqz	a5,80003de2 <pipealloc+0xc6>
    fileclose(*f1);
    80003dd6:	853e                	mv	a0,a5
    80003dd8:	00000097          	auipc	ra,0x0
    80003ddc:	c14080e7          	jalr	-1004(ra) # 800039ec <fileclose>
  return -1;
    80003de0:	557d                	li	a0,-1
}
    80003de2:	70a2                	ld	ra,40(sp)
    80003de4:	7402                	ld	s0,32(sp)
    80003de6:	64e2                	ld	s1,24(sp)
    80003de8:	6942                	ld	s2,16(sp)
    80003dea:	69a2                	ld	s3,8(sp)
    80003dec:	6a02                	ld	s4,0(sp)
    80003dee:	6145                	addi	sp,sp,48
    80003df0:	8082                	ret
  return -1;
    80003df2:	557d                	li	a0,-1
    80003df4:	b7fd                	j	80003de2 <pipealloc+0xc6>

0000000080003df6 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003df6:	1101                	addi	sp,sp,-32
    80003df8:	ec06                	sd	ra,24(sp)
    80003dfa:	e822                	sd	s0,16(sp)
    80003dfc:	e426                	sd	s1,8(sp)
    80003dfe:	e04a                	sd	s2,0(sp)
    80003e00:	1000                	addi	s0,sp,32
    80003e02:	84aa                	mv	s1,a0
    80003e04:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003e06:	00002097          	auipc	ra,0x2
    80003e0a:	33e080e7          	jalr	830(ra) # 80006144 <acquire>
  if(writable){
    80003e0e:	02090d63          	beqz	s2,80003e48 <pipeclose+0x52>
    pi->writeopen = 0;
    80003e12:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003e16:	21848513          	addi	a0,s1,536
    80003e1a:	ffffd097          	auipc	ra,0xffffd
    80003e1e:	752080e7          	jalr	1874(ra) # 8000156c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003e22:	2204b783          	ld	a5,544(s1)
    80003e26:	eb95                	bnez	a5,80003e5a <pipeclose+0x64>
    release(&pi->lock);
    80003e28:	8526                	mv	a0,s1
    80003e2a:	00002097          	auipc	ra,0x2
    80003e2e:	3ce080e7          	jalr	974(ra) # 800061f8 <release>
    kfree((char*)pi);
    80003e32:	8526                	mv	a0,s1
    80003e34:	ffffc097          	auipc	ra,0xffffc
    80003e38:	1e8080e7          	jalr	488(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003e3c:	60e2                	ld	ra,24(sp)
    80003e3e:	6442                	ld	s0,16(sp)
    80003e40:	64a2                	ld	s1,8(sp)
    80003e42:	6902                	ld	s2,0(sp)
    80003e44:	6105                	addi	sp,sp,32
    80003e46:	8082                	ret
    pi->readopen = 0;
    80003e48:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003e4c:	21c48513          	addi	a0,s1,540
    80003e50:	ffffd097          	auipc	ra,0xffffd
    80003e54:	71c080e7          	jalr	1820(ra) # 8000156c <wakeup>
    80003e58:	b7e9                	j	80003e22 <pipeclose+0x2c>
    release(&pi->lock);
    80003e5a:	8526                	mv	a0,s1
    80003e5c:	00002097          	auipc	ra,0x2
    80003e60:	39c080e7          	jalr	924(ra) # 800061f8 <release>
}
    80003e64:	bfe1                	j	80003e3c <pipeclose+0x46>

0000000080003e66 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003e66:	711d                	addi	sp,sp,-96
    80003e68:	ec86                	sd	ra,88(sp)
    80003e6a:	e8a2                	sd	s0,80(sp)
    80003e6c:	e4a6                	sd	s1,72(sp)
    80003e6e:	e0ca                	sd	s2,64(sp)
    80003e70:	fc4e                	sd	s3,56(sp)
    80003e72:	f852                	sd	s4,48(sp)
    80003e74:	f456                	sd	s5,40(sp)
    80003e76:	f05a                	sd	s6,32(sp)
    80003e78:	ec5e                	sd	s7,24(sp)
    80003e7a:	e862                	sd	s8,16(sp)
    80003e7c:	1080                	addi	s0,sp,96
    80003e7e:	84aa                	mv	s1,a0
    80003e80:	8aae                	mv	s5,a1
    80003e82:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003e84:	ffffd097          	auipc	ra,0xffffd
    80003e88:	fd0080e7          	jalr	-48(ra) # 80000e54 <myproc>
    80003e8c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003e8e:	8526                	mv	a0,s1
    80003e90:	00002097          	auipc	ra,0x2
    80003e94:	2b4080e7          	jalr	692(ra) # 80006144 <acquire>
  while(i < n){
    80003e98:	0b405663          	blez	s4,80003f44 <pipewrite+0xde>
  int i = 0;
    80003e9c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003e9e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003ea0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003ea4:	21c48b93          	addi	s7,s1,540
    80003ea8:	a089                	j	80003eea <pipewrite+0x84>
      release(&pi->lock);
    80003eaa:	8526                	mv	a0,s1
    80003eac:	00002097          	auipc	ra,0x2
    80003eb0:	34c080e7          	jalr	844(ra) # 800061f8 <release>
      return -1;
    80003eb4:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003eb6:	854a                	mv	a0,s2
    80003eb8:	60e6                	ld	ra,88(sp)
    80003eba:	6446                	ld	s0,80(sp)
    80003ebc:	64a6                	ld	s1,72(sp)
    80003ebe:	6906                	ld	s2,64(sp)
    80003ec0:	79e2                	ld	s3,56(sp)
    80003ec2:	7a42                	ld	s4,48(sp)
    80003ec4:	7aa2                	ld	s5,40(sp)
    80003ec6:	7b02                	ld	s6,32(sp)
    80003ec8:	6be2                	ld	s7,24(sp)
    80003eca:	6c42                	ld	s8,16(sp)
    80003ecc:	6125                	addi	sp,sp,96
    80003ece:	8082                	ret
      wakeup(&pi->nread);
    80003ed0:	8562                	mv	a0,s8
    80003ed2:	ffffd097          	auipc	ra,0xffffd
    80003ed6:	69a080e7          	jalr	1690(ra) # 8000156c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003eda:	85a6                	mv	a1,s1
    80003edc:	855e                	mv	a0,s7
    80003ede:	ffffd097          	auipc	ra,0xffffd
    80003ee2:	62a080e7          	jalr	1578(ra) # 80001508 <sleep>
  while(i < n){
    80003ee6:	07495063          	bge	s2,s4,80003f46 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80003eea:	2204a783          	lw	a5,544(s1)
    80003eee:	dfd5                	beqz	a5,80003eaa <pipewrite+0x44>
    80003ef0:	854e                	mv	a0,s3
    80003ef2:	ffffe097          	auipc	ra,0xffffe
    80003ef6:	8be080e7          	jalr	-1858(ra) # 800017b0 <killed>
    80003efa:	f945                	bnez	a0,80003eaa <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003efc:	2184a783          	lw	a5,536(s1)
    80003f00:	21c4a703          	lw	a4,540(s1)
    80003f04:	2007879b          	addiw	a5,a5,512
    80003f08:	fcf704e3          	beq	a4,a5,80003ed0 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f0c:	4685                	li	a3,1
    80003f0e:	01590633          	add	a2,s2,s5
    80003f12:	faf40593          	addi	a1,s0,-81
    80003f16:	0509b503          	ld	a0,80(s3)
    80003f1a:	ffffd097          	auipc	ra,0xffffd
    80003f1e:	c86080e7          	jalr	-890(ra) # 80000ba0 <copyin>
    80003f22:	03650263          	beq	a0,s6,80003f46 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003f26:	21c4a783          	lw	a5,540(s1)
    80003f2a:	0017871b          	addiw	a4,a5,1
    80003f2e:	20e4ae23          	sw	a4,540(s1)
    80003f32:	1ff7f793          	andi	a5,a5,511
    80003f36:	97a6                	add	a5,a5,s1
    80003f38:	faf44703          	lbu	a4,-81(s0)
    80003f3c:	00e78c23          	sb	a4,24(a5)
      i++;
    80003f40:	2905                	addiw	s2,s2,1
    80003f42:	b755                	j	80003ee6 <pipewrite+0x80>
  int i = 0;
    80003f44:	4901                	li	s2,0
  wakeup(&pi->nread);
    80003f46:	21848513          	addi	a0,s1,536
    80003f4a:	ffffd097          	auipc	ra,0xffffd
    80003f4e:	622080e7          	jalr	1570(ra) # 8000156c <wakeup>
  release(&pi->lock);
    80003f52:	8526                	mv	a0,s1
    80003f54:	00002097          	auipc	ra,0x2
    80003f58:	2a4080e7          	jalr	676(ra) # 800061f8 <release>
  return i;
    80003f5c:	bfa9                	j	80003eb6 <pipewrite+0x50>

0000000080003f5e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80003f5e:	715d                	addi	sp,sp,-80
    80003f60:	e486                	sd	ra,72(sp)
    80003f62:	e0a2                	sd	s0,64(sp)
    80003f64:	fc26                	sd	s1,56(sp)
    80003f66:	f84a                	sd	s2,48(sp)
    80003f68:	f44e                	sd	s3,40(sp)
    80003f6a:	f052                	sd	s4,32(sp)
    80003f6c:	ec56                	sd	s5,24(sp)
    80003f6e:	e85a                	sd	s6,16(sp)
    80003f70:	0880                	addi	s0,sp,80
    80003f72:	84aa                	mv	s1,a0
    80003f74:	892e                	mv	s2,a1
    80003f76:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80003f78:	ffffd097          	auipc	ra,0xffffd
    80003f7c:	edc080e7          	jalr	-292(ra) # 80000e54 <myproc>
    80003f80:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80003f82:	8526                	mv	a0,s1
    80003f84:	00002097          	auipc	ra,0x2
    80003f88:	1c0080e7          	jalr	448(ra) # 80006144 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003f8c:	2184a703          	lw	a4,536(s1)
    80003f90:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003f94:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003f98:	02f71763          	bne	a4,a5,80003fc6 <piperead+0x68>
    80003f9c:	2244a783          	lw	a5,548(s1)
    80003fa0:	c39d                	beqz	a5,80003fc6 <piperead+0x68>
    if(killed(pr)){
    80003fa2:	8552                	mv	a0,s4
    80003fa4:	ffffe097          	auipc	ra,0xffffe
    80003fa8:	80c080e7          	jalr	-2036(ra) # 800017b0 <killed>
    80003fac:	e949                	bnez	a0,8000403e <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80003fae:	85a6                	mv	a1,s1
    80003fb0:	854e                	mv	a0,s3
    80003fb2:	ffffd097          	auipc	ra,0xffffd
    80003fb6:	556080e7          	jalr	1366(ra) # 80001508 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80003fba:	2184a703          	lw	a4,536(s1)
    80003fbe:	21c4a783          	lw	a5,540(s1)
    80003fc2:	fcf70de3          	beq	a4,a5,80003f9c <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003fc6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003fc8:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80003fca:	05505463          	blez	s5,80004012 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80003fce:	2184a783          	lw	a5,536(s1)
    80003fd2:	21c4a703          	lw	a4,540(s1)
    80003fd6:	02f70e63          	beq	a4,a5,80004012 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80003fda:	0017871b          	addiw	a4,a5,1
    80003fde:	20e4ac23          	sw	a4,536(s1)
    80003fe2:	1ff7f793          	andi	a5,a5,511
    80003fe6:	97a6                	add	a5,a5,s1
    80003fe8:	0187c783          	lbu	a5,24(a5)
    80003fec:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80003ff0:	4685                	li	a3,1
    80003ff2:	fbf40613          	addi	a2,s0,-65
    80003ff6:	85ca                	mv	a1,s2
    80003ff8:	050a3503          	ld	a0,80(s4)
    80003ffc:	ffffd097          	auipc	ra,0xffffd
    80004000:	b18080e7          	jalr	-1256(ra) # 80000b14 <copyout>
    80004004:	01650763          	beq	a0,s6,80004012 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004008:	2985                	addiw	s3,s3,1
    8000400a:	0905                	addi	s2,s2,1
    8000400c:	fd3a91e3          	bne	s5,s3,80003fce <piperead+0x70>
    80004010:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004012:	21c48513          	addi	a0,s1,540
    80004016:	ffffd097          	auipc	ra,0xffffd
    8000401a:	556080e7          	jalr	1366(ra) # 8000156c <wakeup>
  release(&pi->lock);
    8000401e:	8526                	mv	a0,s1
    80004020:	00002097          	auipc	ra,0x2
    80004024:	1d8080e7          	jalr	472(ra) # 800061f8 <release>
  return i;
}
    80004028:	854e                	mv	a0,s3
    8000402a:	60a6                	ld	ra,72(sp)
    8000402c:	6406                	ld	s0,64(sp)
    8000402e:	74e2                	ld	s1,56(sp)
    80004030:	7942                	ld	s2,48(sp)
    80004032:	79a2                	ld	s3,40(sp)
    80004034:	7a02                	ld	s4,32(sp)
    80004036:	6ae2                	ld	s5,24(sp)
    80004038:	6b42                	ld	s6,16(sp)
    8000403a:	6161                	addi	sp,sp,80
    8000403c:	8082                	ret
      release(&pi->lock);
    8000403e:	8526                	mv	a0,s1
    80004040:	00002097          	auipc	ra,0x2
    80004044:	1b8080e7          	jalr	440(ra) # 800061f8 <release>
      return -1;
    80004048:	59fd                	li	s3,-1
    8000404a:	bff9                	j	80004028 <piperead+0xca>

000000008000404c <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000404c:	1141                	addi	sp,sp,-16
    8000404e:	e422                	sd	s0,8(sp)
    80004050:	0800                	addi	s0,sp,16
    80004052:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004054:	8905                	andi	a0,a0,1
    80004056:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004058:	8b89                	andi	a5,a5,2
    8000405a:	c399                	beqz	a5,80004060 <flags2perm+0x14>
      perm |= PTE_W;
    8000405c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004060:	6422                	ld	s0,8(sp)
    80004062:	0141                	addi	sp,sp,16
    80004064:	8082                	ret

0000000080004066 <exec>:

int
exec(char *path, char **argv)
{
    80004066:	de010113          	addi	sp,sp,-544
    8000406a:	20113c23          	sd	ra,536(sp)
    8000406e:	20813823          	sd	s0,528(sp)
    80004072:	20913423          	sd	s1,520(sp)
    80004076:	21213023          	sd	s2,512(sp)
    8000407a:	ffce                	sd	s3,504(sp)
    8000407c:	fbd2                	sd	s4,496(sp)
    8000407e:	f7d6                	sd	s5,488(sp)
    80004080:	f3da                	sd	s6,480(sp)
    80004082:	efde                	sd	s7,472(sp)
    80004084:	ebe2                	sd	s8,464(sp)
    80004086:	e7e6                	sd	s9,456(sp)
    80004088:	e3ea                	sd	s10,448(sp)
    8000408a:	ff6e                	sd	s11,440(sp)
    8000408c:	1400                	addi	s0,sp,544
    8000408e:	892a                	mv	s2,a0
    80004090:	dea43423          	sd	a0,-536(s0)
    80004094:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004098:	ffffd097          	auipc	ra,0xffffd
    8000409c:	dbc080e7          	jalr	-580(ra) # 80000e54 <myproc>
    800040a0:	84aa                	mv	s1,a0

  begin_op();
    800040a2:	fffff097          	auipc	ra,0xfffff
    800040a6:	482080e7          	jalr	1154(ra) # 80003524 <begin_op>

  if((ip = namei(path)) == 0){
    800040aa:	854a                	mv	a0,s2
    800040ac:	fffff097          	auipc	ra,0xfffff
    800040b0:	258080e7          	jalr	600(ra) # 80003304 <namei>
    800040b4:	c93d                	beqz	a0,8000412a <exec+0xc4>
    800040b6:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800040b8:	fffff097          	auipc	ra,0xfffff
    800040bc:	aa0080e7          	jalr	-1376(ra) # 80002b58 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800040c0:	04000713          	li	a4,64
    800040c4:	4681                	li	a3,0
    800040c6:	e5040613          	addi	a2,s0,-432
    800040ca:	4581                	li	a1,0
    800040cc:	8556                	mv	a0,s5
    800040ce:	fffff097          	auipc	ra,0xfffff
    800040d2:	d3e080e7          	jalr	-706(ra) # 80002e0c <readi>
    800040d6:	04000793          	li	a5,64
    800040da:	00f51a63          	bne	a0,a5,800040ee <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800040de:	e5042703          	lw	a4,-432(s0)
    800040e2:	464c47b7          	lui	a5,0x464c4
    800040e6:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800040ea:	04f70663          	beq	a4,a5,80004136 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800040ee:	8556                	mv	a0,s5
    800040f0:	fffff097          	auipc	ra,0xfffff
    800040f4:	cca080e7          	jalr	-822(ra) # 80002dba <iunlockput>
    end_op();
    800040f8:	fffff097          	auipc	ra,0xfffff
    800040fc:	4aa080e7          	jalr	1194(ra) # 800035a2 <end_op>
  }
  return -1;
    80004100:	557d                	li	a0,-1
}
    80004102:	21813083          	ld	ra,536(sp)
    80004106:	21013403          	ld	s0,528(sp)
    8000410a:	20813483          	ld	s1,520(sp)
    8000410e:	20013903          	ld	s2,512(sp)
    80004112:	79fe                	ld	s3,504(sp)
    80004114:	7a5e                	ld	s4,496(sp)
    80004116:	7abe                	ld	s5,488(sp)
    80004118:	7b1e                	ld	s6,480(sp)
    8000411a:	6bfe                	ld	s7,472(sp)
    8000411c:	6c5e                	ld	s8,464(sp)
    8000411e:	6cbe                	ld	s9,456(sp)
    80004120:	6d1e                	ld	s10,448(sp)
    80004122:	7dfa                	ld	s11,440(sp)
    80004124:	22010113          	addi	sp,sp,544
    80004128:	8082                	ret
    end_op();
    8000412a:	fffff097          	auipc	ra,0xfffff
    8000412e:	478080e7          	jalr	1144(ra) # 800035a2 <end_op>
    return -1;
    80004132:	557d                	li	a0,-1
    80004134:	b7f9                	j	80004102 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004136:	8526                	mv	a0,s1
    80004138:	ffffd097          	auipc	ra,0xffffd
    8000413c:	de0080e7          	jalr	-544(ra) # 80000f18 <proc_pagetable>
    80004140:	8b2a                	mv	s6,a0
    80004142:	d555                	beqz	a0,800040ee <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004144:	e7042783          	lw	a5,-400(s0)
    80004148:	e8845703          	lhu	a4,-376(s0)
    8000414c:	c735                	beqz	a4,800041b8 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000414e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004150:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004154:	6a05                	lui	s4,0x1
    80004156:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000415a:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000415e:	6d85                	lui	s11,0x1
    80004160:	7d7d                	lui	s10,0xfffff
    80004162:	ac3d                	j	800043a0 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004164:	00004517          	auipc	a0,0x4
    80004168:	4ec50513          	addi	a0,a0,1260 # 80008650 <syscalls+0x280>
    8000416c:	00002097          	auipc	ra,0x2
    80004170:	aa0080e7          	jalr	-1376(ra) # 80005c0c <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004174:	874a                	mv	a4,s2
    80004176:	009c86bb          	addw	a3,s9,s1
    8000417a:	4581                	li	a1,0
    8000417c:	8556                	mv	a0,s5
    8000417e:	fffff097          	auipc	ra,0xfffff
    80004182:	c8e080e7          	jalr	-882(ra) # 80002e0c <readi>
    80004186:	2501                	sext.w	a0,a0
    80004188:	1aa91963          	bne	s2,a0,8000433a <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    8000418c:	009d84bb          	addw	s1,s11,s1
    80004190:	013d09bb          	addw	s3,s10,s3
    80004194:	1f74f663          	bgeu	s1,s7,80004380 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004198:	02049593          	slli	a1,s1,0x20
    8000419c:	9181                	srli	a1,a1,0x20
    8000419e:	95e2                	add	a1,a1,s8
    800041a0:	855a                	mv	a0,s6
    800041a2:	ffffc097          	auipc	ra,0xffffc
    800041a6:	362080e7          	jalr	866(ra) # 80000504 <walkaddr>
    800041aa:	862a                	mv	a2,a0
    if(pa == 0)
    800041ac:	dd45                	beqz	a0,80004164 <exec+0xfe>
      n = PGSIZE;
    800041ae:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800041b0:	fd49f2e3          	bgeu	s3,s4,80004174 <exec+0x10e>
      n = sz - i;
    800041b4:	894e                	mv	s2,s3
    800041b6:	bf7d                	j	80004174 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800041b8:	4901                	li	s2,0
  iunlockput(ip);
    800041ba:	8556                	mv	a0,s5
    800041bc:	fffff097          	auipc	ra,0xfffff
    800041c0:	bfe080e7          	jalr	-1026(ra) # 80002dba <iunlockput>
  end_op();
    800041c4:	fffff097          	auipc	ra,0xfffff
    800041c8:	3de080e7          	jalr	990(ra) # 800035a2 <end_op>
  p = myproc();
    800041cc:	ffffd097          	auipc	ra,0xffffd
    800041d0:	c88080e7          	jalr	-888(ra) # 80000e54 <myproc>
    800041d4:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800041d6:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800041da:	6785                	lui	a5,0x1
    800041dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800041de:	97ca                	add	a5,a5,s2
    800041e0:	777d                	lui	a4,0xfffff
    800041e2:	8ff9                	and	a5,a5,a4
    800041e4:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800041e8:	4691                	li	a3,4
    800041ea:	6609                	lui	a2,0x2
    800041ec:	963e                	add	a2,a2,a5
    800041ee:	85be                	mv	a1,a5
    800041f0:	855a                	mv	a0,s6
    800041f2:	ffffc097          	auipc	ra,0xffffc
    800041f6:	6c6080e7          	jalr	1734(ra) # 800008b8 <uvmalloc>
    800041fa:	8c2a                	mv	s8,a0
  ip = 0;
    800041fc:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800041fe:	12050e63          	beqz	a0,8000433a <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004202:	75f9                	lui	a1,0xffffe
    80004204:	95aa                	add	a1,a1,a0
    80004206:	855a                	mv	a0,s6
    80004208:	ffffd097          	auipc	ra,0xffffd
    8000420c:	8da080e7          	jalr	-1830(ra) # 80000ae2 <uvmclear>
  stackbase = sp - PGSIZE;
    80004210:	7afd                	lui	s5,0xfffff
    80004212:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004214:	df043783          	ld	a5,-528(s0)
    80004218:	6388                	ld	a0,0(a5)
    8000421a:	c925                	beqz	a0,8000428a <exec+0x224>
    8000421c:	e9040993          	addi	s3,s0,-368
    80004220:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004224:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004226:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004228:	ffffc097          	auipc	ra,0xffffc
    8000422c:	0ce080e7          	jalr	206(ra) # 800002f6 <strlen>
    80004230:	0015079b          	addiw	a5,a0,1
    80004234:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004238:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000423c:	13596663          	bltu	s2,s5,80004368 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004240:	df043d83          	ld	s11,-528(s0)
    80004244:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004248:	8552                	mv	a0,s4
    8000424a:	ffffc097          	auipc	ra,0xffffc
    8000424e:	0ac080e7          	jalr	172(ra) # 800002f6 <strlen>
    80004252:	0015069b          	addiw	a3,a0,1
    80004256:	8652                	mv	a2,s4
    80004258:	85ca                	mv	a1,s2
    8000425a:	855a                	mv	a0,s6
    8000425c:	ffffd097          	auipc	ra,0xffffd
    80004260:	8b8080e7          	jalr	-1864(ra) # 80000b14 <copyout>
    80004264:	10054663          	bltz	a0,80004370 <exec+0x30a>
    ustack[argc] = sp;
    80004268:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000426c:	0485                	addi	s1,s1,1
    8000426e:	008d8793          	addi	a5,s11,8
    80004272:	def43823          	sd	a5,-528(s0)
    80004276:	008db503          	ld	a0,8(s11)
    8000427a:	c911                	beqz	a0,8000428e <exec+0x228>
    if(argc >= MAXARG)
    8000427c:	09a1                	addi	s3,s3,8
    8000427e:	fb3c95e3          	bne	s9,s3,80004228 <exec+0x1c2>
  sz = sz1;
    80004282:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004286:	4a81                	li	s5,0
    80004288:	a84d                	j	8000433a <exec+0x2d4>
  sp = sz;
    8000428a:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000428c:	4481                	li	s1,0
  ustack[argc] = 0;
    8000428e:	00349793          	slli	a5,s1,0x3
    80004292:	f9078793          	addi	a5,a5,-112
    80004296:	97a2                	add	a5,a5,s0
    80004298:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000429c:	00148693          	addi	a3,s1,1
    800042a0:	068e                	slli	a3,a3,0x3
    800042a2:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800042a6:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800042aa:	01597663          	bgeu	s2,s5,800042b6 <exec+0x250>
  sz = sz1;
    800042ae:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800042b2:	4a81                	li	s5,0
    800042b4:	a059                	j	8000433a <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800042b6:	e9040613          	addi	a2,s0,-368
    800042ba:	85ca                	mv	a1,s2
    800042bc:	855a                	mv	a0,s6
    800042be:	ffffd097          	auipc	ra,0xffffd
    800042c2:	856080e7          	jalr	-1962(ra) # 80000b14 <copyout>
    800042c6:	0a054963          	bltz	a0,80004378 <exec+0x312>
  p->trapframe->a1 = sp;
    800042ca:	058bb783          	ld	a5,88(s7)
    800042ce:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800042d2:	de843783          	ld	a5,-536(s0)
    800042d6:	0007c703          	lbu	a4,0(a5)
    800042da:	cf11                	beqz	a4,800042f6 <exec+0x290>
    800042dc:	0785                	addi	a5,a5,1
    if(*s == '/')
    800042de:	02f00693          	li	a3,47
    800042e2:	a039                	j	800042f0 <exec+0x28a>
      last = s+1;
    800042e4:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800042e8:	0785                	addi	a5,a5,1
    800042ea:	fff7c703          	lbu	a4,-1(a5)
    800042ee:	c701                	beqz	a4,800042f6 <exec+0x290>
    if(*s == '/')
    800042f0:	fed71ce3          	bne	a4,a3,800042e8 <exec+0x282>
    800042f4:	bfc5                	j	800042e4 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800042f6:	4641                	li	a2,16
    800042f8:	de843583          	ld	a1,-536(s0)
    800042fc:	158b8513          	addi	a0,s7,344
    80004300:	ffffc097          	auipc	ra,0xffffc
    80004304:	fc4080e7          	jalr	-60(ra) # 800002c4 <safestrcpy>
  oldpagetable = p->pagetable;
    80004308:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    8000430c:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004310:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004314:	058bb783          	ld	a5,88(s7)
    80004318:	e6843703          	ld	a4,-408(s0)
    8000431c:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000431e:	058bb783          	ld	a5,88(s7)
    80004322:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004326:	85ea                	mv	a1,s10
    80004328:	ffffd097          	auipc	ra,0xffffd
    8000432c:	c8c080e7          	jalr	-884(ra) # 80000fb4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004330:	0004851b          	sext.w	a0,s1
    80004334:	b3f9                	j	80004102 <exec+0x9c>
    80004336:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000433a:	df843583          	ld	a1,-520(s0)
    8000433e:	855a                	mv	a0,s6
    80004340:	ffffd097          	auipc	ra,0xffffd
    80004344:	c74080e7          	jalr	-908(ra) # 80000fb4 <proc_freepagetable>
  if(ip){
    80004348:	da0a93e3          	bnez	s5,800040ee <exec+0x88>
  return -1;
    8000434c:	557d                	li	a0,-1
    8000434e:	bb55                	j	80004102 <exec+0x9c>
    80004350:	df243c23          	sd	s2,-520(s0)
    80004354:	b7dd                	j	8000433a <exec+0x2d4>
    80004356:	df243c23          	sd	s2,-520(s0)
    8000435a:	b7c5                	j	8000433a <exec+0x2d4>
    8000435c:	df243c23          	sd	s2,-520(s0)
    80004360:	bfe9                	j	8000433a <exec+0x2d4>
    80004362:	df243c23          	sd	s2,-520(s0)
    80004366:	bfd1                	j	8000433a <exec+0x2d4>
  sz = sz1;
    80004368:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000436c:	4a81                	li	s5,0
    8000436e:	b7f1                	j	8000433a <exec+0x2d4>
  sz = sz1;
    80004370:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004374:	4a81                	li	s5,0
    80004376:	b7d1                	j	8000433a <exec+0x2d4>
  sz = sz1;
    80004378:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000437c:	4a81                	li	s5,0
    8000437e:	bf75                	j	8000433a <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004380:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004384:	e0843783          	ld	a5,-504(s0)
    80004388:	0017869b          	addiw	a3,a5,1
    8000438c:	e0d43423          	sd	a3,-504(s0)
    80004390:	e0043783          	ld	a5,-512(s0)
    80004394:	0387879b          	addiw	a5,a5,56
    80004398:	e8845703          	lhu	a4,-376(s0)
    8000439c:	e0e6dfe3          	bge	a3,a4,800041ba <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800043a0:	2781                	sext.w	a5,a5
    800043a2:	e0f43023          	sd	a5,-512(s0)
    800043a6:	03800713          	li	a4,56
    800043aa:	86be                	mv	a3,a5
    800043ac:	e1840613          	addi	a2,s0,-488
    800043b0:	4581                	li	a1,0
    800043b2:	8556                	mv	a0,s5
    800043b4:	fffff097          	auipc	ra,0xfffff
    800043b8:	a58080e7          	jalr	-1448(ra) # 80002e0c <readi>
    800043bc:	03800793          	li	a5,56
    800043c0:	f6f51be3          	bne	a0,a5,80004336 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    800043c4:	e1842783          	lw	a5,-488(s0)
    800043c8:	4705                	li	a4,1
    800043ca:	fae79de3          	bne	a5,a4,80004384 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    800043ce:	e4043483          	ld	s1,-448(s0)
    800043d2:	e3843783          	ld	a5,-456(s0)
    800043d6:	f6f4ede3          	bltu	s1,a5,80004350 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800043da:	e2843783          	ld	a5,-472(s0)
    800043de:	94be                	add	s1,s1,a5
    800043e0:	f6f4ebe3          	bltu	s1,a5,80004356 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    800043e4:	de043703          	ld	a4,-544(s0)
    800043e8:	8ff9                	and	a5,a5,a4
    800043ea:	fbad                	bnez	a5,8000435c <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800043ec:	e1c42503          	lw	a0,-484(s0)
    800043f0:	00000097          	auipc	ra,0x0
    800043f4:	c5c080e7          	jalr	-932(ra) # 8000404c <flags2perm>
    800043f8:	86aa                	mv	a3,a0
    800043fa:	8626                	mv	a2,s1
    800043fc:	85ca                	mv	a1,s2
    800043fe:	855a                	mv	a0,s6
    80004400:	ffffc097          	auipc	ra,0xffffc
    80004404:	4b8080e7          	jalr	1208(ra) # 800008b8 <uvmalloc>
    80004408:	dea43c23          	sd	a0,-520(s0)
    8000440c:	d939                	beqz	a0,80004362 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000440e:	e2843c03          	ld	s8,-472(s0)
    80004412:	e2042c83          	lw	s9,-480(s0)
    80004416:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000441a:	f60b83e3          	beqz	s7,80004380 <exec+0x31a>
    8000441e:	89de                	mv	s3,s7
    80004420:	4481                	li	s1,0
    80004422:	bb9d                	j	80004198 <exec+0x132>

0000000080004424 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004424:	7179                	addi	sp,sp,-48
    80004426:	f406                	sd	ra,40(sp)
    80004428:	f022                	sd	s0,32(sp)
    8000442a:	ec26                	sd	s1,24(sp)
    8000442c:	e84a                	sd	s2,16(sp)
    8000442e:	1800                	addi	s0,sp,48
    80004430:	892e                	mv	s2,a1
    80004432:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004434:	fdc40593          	addi	a1,s0,-36
    80004438:	ffffe097          	auipc	ra,0xffffe
    8000443c:	b6e080e7          	jalr	-1170(ra) # 80001fa6 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004440:	fdc42703          	lw	a4,-36(s0)
    80004444:	47bd                	li	a5,15
    80004446:	02e7eb63          	bltu	a5,a4,8000447c <argfd+0x58>
    8000444a:	ffffd097          	auipc	ra,0xffffd
    8000444e:	a0a080e7          	jalr	-1526(ra) # 80000e54 <myproc>
    80004452:	fdc42703          	lw	a4,-36(s0)
    80004456:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdceca>
    8000445a:	078e                	slli	a5,a5,0x3
    8000445c:	953e                	add	a0,a0,a5
    8000445e:	611c                	ld	a5,0(a0)
    80004460:	c385                	beqz	a5,80004480 <argfd+0x5c>
    return -1;
  if(pfd)
    80004462:	00090463          	beqz	s2,8000446a <argfd+0x46>
    *pfd = fd;
    80004466:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000446a:	4501                	li	a0,0
  if(pf)
    8000446c:	c091                	beqz	s1,80004470 <argfd+0x4c>
    *pf = f;
    8000446e:	e09c                	sd	a5,0(s1)
}
    80004470:	70a2                	ld	ra,40(sp)
    80004472:	7402                	ld	s0,32(sp)
    80004474:	64e2                	ld	s1,24(sp)
    80004476:	6942                	ld	s2,16(sp)
    80004478:	6145                	addi	sp,sp,48
    8000447a:	8082                	ret
    return -1;
    8000447c:	557d                	li	a0,-1
    8000447e:	bfcd                	j	80004470 <argfd+0x4c>
    80004480:	557d                	li	a0,-1
    80004482:	b7fd                	j	80004470 <argfd+0x4c>

0000000080004484 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004484:	1101                	addi	sp,sp,-32
    80004486:	ec06                	sd	ra,24(sp)
    80004488:	e822                	sd	s0,16(sp)
    8000448a:	e426                	sd	s1,8(sp)
    8000448c:	1000                	addi	s0,sp,32
    8000448e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004490:	ffffd097          	auipc	ra,0xffffd
    80004494:	9c4080e7          	jalr	-1596(ra) # 80000e54 <myproc>
    80004498:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000449a:	0d050793          	addi	a5,a0,208
    8000449e:	4501                	li	a0,0
    800044a0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800044a2:	6398                	ld	a4,0(a5)
    800044a4:	cb19                	beqz	a4,800044ba <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800044a6:	2505                	addiw	a0,a0,1
    800044a8:	07a1                	addi	a5,a5,8
    800044aa:	fed51ce3          	bne	a0,a3,800044a2 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800044ae:	557d                	li	a0,-1
}
    800044b0:	60e2                	ld	ra,24(sp)
    800044b2:	6442                	ld	s0,16(sp)
    800044b4:	64a2                	ld	s1,8(sp)
    800044b6:	6105                	addi	sp,sp,32
    800044b8:	8082                	ret
      p->ofile[fd] = f;
    800044ba:	01a50793          	addi	a5,a0,26
    800044be:	078e                	slli	a5,a5,0x3
    800044c0:	963e                	add	a2,a2,a5
    800044c2:	e204                	sd	s1,0(a2)
      return fd;
    800044c4:	b7f5                	j	800044b0 <fdalloc+0x2c>

00000000800044c6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800044c6:	715d                	addi	sp,sp,-80
    800044c8:	e486                	sd	ra,72(sp)
    800044ca:	e0a2                	sd	s0,64(sp)
    800044cc:	fc26                	sd	s1,56(sp)
    800044ce:	f84a                	sd	s2,48(sp)
    800044d0:	f44e                	sd	s3,40(sp)
    800044d2:	f052                	sd	s4,32(sp)
    800044d4:	ec56                	sd	s5,24(sp)
    800044d6:	e85a                	sd	s6,16(sp)
    800044d8:	0880                	addi	s0,sp,80
    800044da:	8b2e                	mv	s6,a1
    800044dc:	89b2                	mv	s3,a2
    800044de:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800044e0:	fb040593          	addi	a1,s0,-80
    800044e4:	fffff097          	auipc	ra,0xfffff
    800044e8:	e3e080e7          	jalr	-450(ra) # 80003322 <nameiparent>
    800044ec:	84aa                	mv	s1,a0
    800044ee:	14050f63          	beqz	a0,8000464c <create+0x186>
    return 0;

  ilock(dp);
    800044f2:	ffffe097          	auipc	ra,0xffffe
    800044f6:	666080e7          	jalr	1638(ra) # 80002b58 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800044fa:	4601                	li	a2,0
    800044fc:	fb040593          	addi	a1,s0,-80
    80004500:	8526                	mv	a0,s1
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	b3a080e7          	jalr	-1222(ra) # 8000303c <dirlookup>
    8000450a:	8aaa                	mv	s5,a0
    8000450c:	c931                	beqz	a0,80004560 <create+0x9a>
    iunlockput(dp);
    8000450e:	8526                	mv	a0,s1
    80004510:	fffff097          	auipc	ra,0xfffff
    80004514:	8aa080e7          	jalr	-1878(ra) # 80002dba <iunlockput>
    ilock(ip);
    80004518:	8556                	mv	a0,s5
    8000451a:	ffffe097          	auipc	ra,0xffffe
    8000451e:	63e080e7          	jalr	1598(ra) # 80002b58 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004522:	000b059b          	sext.w	a1,s6
    80004526:	4789                	li	a5,2
    80004528:	02f59563          	bne	a1,a5,80004552 <create+0x8c>
    8000452c:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcef4>
    80004530:	37f9                	addiw	a5,a5,-2
    80004532:	17c2                	slli	a5,a5,0x30
    80004534:	93c1                	srli	a5,a5,0x30
    80004536:	4705                	li	a4,1
    80004538:	00f76d63          	bltu	a4,a5,80004552 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000453c:	8556                	mv	a0,s5
    8000453e:	60a6                	ld	ra,72(sp)
    80004540:	6406                	ld	s0,64(sp)
    80004542:	74e2                	ld	s1,56(sp)
    80004544:	7942                	ld	s2,48(sp)
    80004546:	79a2                	ld	s3,40(sp)
    80004548:	7a02                	ld	s4,32(sp)
    8000454a:	6ae2                	ld	s5,24(sp)
    8000454c:	6b42                	ld	s6,16(sp)
    8000454e:	6161                	addi	sp,sp,80
    80004550:	8082                	ret
    iunlockput(ip);
    80004552:	8556                	mv	a0,s5
    80004554:	fffff097          	auipc	ra,0xfffff
    80004558:	866080e7          	jalr	-1946(ra) # 80002dba <iunlockput>
    return 0;
    8000455c:	4a81                	li	s5,0
    8000455e:	bff9                	j	8000453c <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004560:	85da                	mv	a1,s6
    80004562:	4088                	lw	a0,0(s1)
    80004564:	ffffe097          	auipc	ra,0xffffe
    80004568:	456080e7          	jalr	1110(ra) # 800029ba <ialloc>
    8000456c:	8a2a                	mv	s4,a0
    8000456e:	c539                	beqz	a0,800045bc <create+0xf6>
  ilock(ip);
    80004570:	ffffe097          	auipc	ra,0xffffe
    80004574:	5e8080e7          	jalr	1512(ra) # 80002b58 <ilock>
  ip->major = major;
    80004578:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000457c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004580:	4905                	li	s2,1
    80004582:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004586:	8552                	mv	a0,s4
    80004588:	ffffe097          	auipc	ra,0xffffe
    8000458c:	504080e7          	jalr	1284(ra) # 80002a8c <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004590:	000b059b          	sext.w	a1,s6
    80004594:	03258b63          	beq	a1,s2,800045ca <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80004598:	004a2603          	lw	a2,4(s4)
    8000459c:	fb040593          	addi	a1,s0,-80
    800045a0:	8526                	mv	a0,s1
    800045a2:	fffff097          	auipc	ra,0xfffff
    800045a6:	cb0080e7          	jalr	-848(ra) # 80003252 <dirlink>
    800045aa:	06054f63          	bltz	a0,80004628 <create+0x162>
  iunlockput(dp);
    800045ae:	8526                	mv	a0,s1
    800045b0:	fffff097          	auipc	ra,0xfffff
    800045b4:	80a080e7          	jalr	-2038(ra) # 80002dba <iunlockput>
  return ip;
    800045b8:	8ad2                	mv	s5,s4
    800045ba:	b749                	j	8000453c <create+0x76>
    iunlockput(dp);
    800045bc:	8526                	mv	a0,s1
    800045be:	ffffe097          	auipc	ra,0xffffe
    800045c2:	7fc080e7          	jalr	2044(ra) # 80002dba <iunlockput>
    return 0;
    800045c6:	8ad2                	mv	s5,s4
    800045c8:	bf95                	j	8000453c <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800045ca:	004a2603          	lw	a2,4(s4)
    800045ce:	00004597          	auipc	a1,0x4
    800045d2:	0a258593          	addi	a1,a1,162 # 80008670 <syscalls+0x2a0>
    800045d6:	8552                	mv	a0,s4
    800045d8:	fffff097          	auipc	ra,0xfffff
    800045dc:	c7a080e7          	jalr	-902(ra) # 80003252 <dirlink>
    800045e0:	04054463          	bltz	a0,80004628 <create+0x162>
    800045e4:	40d0                	lw	a2,4(s1)
    800045e6:	00004597          	auipc	a1,0x4
    800045ea:	09258593          	addi	a1,a1,146 # 80008678 <syscalls+0x2a8>
    800045ee:	8552                	mv	a0,s4
    800045f0:	fffff097          	auipc	ra,0xfffff
    800045f4:	c62080e7          	jalr	-926(ra) # 80003252 <dirlink>
    800045f8:	02054863          	bltz	a0,80004628 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800045fc:	004a2603          	lw	a2,4(s4)
    80004600:	fb040593          	addi	a1,s0,-80
    80004604:	8526                	mv	a0,s1
    80004606:	fffff097          	auipc	ra,0xfffff
    8000460a:	c4c080e7          	jalr	-948(ra) # 80003252 <dirlink>
    8000460e:	00054d63          	bltz	a0,80004628 <create+0x162>
    dp->nlink++;  // for ".."
    80004612:	04a4d783          	lhu	a5,74(s1)
    80004616:	2785                	addiw	a5,a5,1
    80004618:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000461c:	8526                	mv	a0,s1
    8000461e:	ffffe097          	auipc	ra,0xffffe
    80004622:	46e080e7          	jalr	1134(ra) # 80002a8c <iupdate>
    80004626:	b761                	j	800045ae <create+0xe8>
  ip->nlink = 0;
    80004628:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000462c:	8552                	mv	a0,s4
    8000462e:	ffffe097          	auipc	ra,0xffffe
    80004632:	45e080e7          	jalr	1118(ra) # 80002a8c <iupdate>
  iunlockput(ip);
    80004636:	8552                	mv	a0,s4
    80004638:	ffffe097          	auipc	ra,0xffffe
    8000463c:	782080e7          	jalr	1922(ra) # 80002dba <iunlockput>
  iunlockput(dp);
    80004640:	8526                	mv	a0,s1
    80004642:	ffffe097          	auipc	ra,0xffffe
    80004646:	778080e7          	jalr	1912(ra) # 80002dba <iunlockput>
  return 0;
    8000464a:	bdcd                	j	8000453c <create+0x76>
    return 0;
    8000464c:	8aaa                	mv	s5,a0
    8000464e:	b5fd                	j	8000453c <create+0x76>

0000000080004650 <sys_dup>:
{
    80004650:	7179                	addi	sp,sp,-48
    80004652:	f406                	sd	ra,40(sp)
    80004654:	f022                	sd	s0,32(sp)
    80004656:	ec26                	sd	s1,24(sp)
    80004658:	e84a                	sd	s2,16(sp)
    8000465a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000465c:	fd840613          	addi	a2,s0,-40
    80004660:	4581                	li	a1,0
    80004662:	4501                	li	a0,0
    80004664:	00000097          	auipc	ra,0x0
    80004668:	dc0080e7          	jalr	-576(ra) # 80004424 <argfd>
    return -1;
    8000466c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000466e:	02054363          	bltz	a0,80004694 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80004672:	fd843903          	ld	s2,-40(s0)
    80004676:	854a                	mv	a0,s2
    80004678:	00000097          	auipc	ra,0x0
    8000467c:	e0c080e7          	jalr	-500(ra) # 80004484 <fdalloc>
    80004680:	84aa                	mv	s1,a0
    return -1;
    80004682:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004684:	00054863          	bltz	a0,80004694 <sys_dup+0x44>
  filedup(f);
    80004688:	854a                	mv	a0,s2
    8000468a:	fffff097          	auipc	ra,0xfffff
    8000468e:	310080e7          	jalr	784(ra) # 8000399a <filedup>
  return fd;
    80004692:	87a6                	mv	a5,s1
}
    80004694:	853e                	mv	a0,a5
    80004696:	70a2                	ld	ra,40(sp)
    80004698:	7402                	ld	s0,32(sp)
    8000469a:	64e2                	ld	s1,24(sp)
    8000469c:	6942                	ld	s2,16(sp)
    8000469e:	6145                	addi	sp,sp,48
    800046a0:	8082                	ret

00000000800046a2 <sys_read>:
{
    800046a2:	7179                	addi	sp,sp,-48
    800046a4:	f406                	sd	ra,40(sp)
    800046a6:	f022                	sd	s0,32(sp)
    800046a8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800046aa:	fd840593          	addi	a1,s0,-40
    800046ae:	4505                	li	a0,1
    800046b0:	ffffe097          	auipc	ra,0xffffe
    800046b4:	916080e7          	jalr	-1770(ra) # 80001fc6 <argaddr>
  argint(2, &n);
    800046b8:	fe440593          	addi	a1,s0,-28
    800046bc:	4509                	li	a0,2
    800046be:	ffffe097          	auipc	ra,0xffffe
    800046c2:	8e8080e7          	jalr	-1816(ra) # 80001fa6 <argint>
  if(argfd(0, 0, &f) < 0)
    800046c6:	fe840613          	addi	a2,s0,-24
    800046ca:	4581                	li	a1,0
    800046cc:	4501                	li	a0,0
    800046ce:	00000097          	auipc	ra,0x0
    800046d2:	d56080e7          	jalr	-682(ra) # 80004424 <argfd>
    800046d6:	87aa                	mv	a5,a0
    return -1;
    800046d8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800046da:	0007cc63          	bltz	a5,800046f2 <sys_read+0x50>
  return fileread(f, p, n);
    800046de:	fe442603          	lw	a2,-28(s0)
    800046e2:	fd843583          	ld	a1,-40(s0)
    800046e6:	fe843503          	ld	a0,-24(s0)
    800046ea:	fffff097          	auipc	ra,0xfffff
    800046ee:	43c080e7          	jalr	1084(ra) # 80003b26 <fileread>
}
    800046f2:	70a2                	ld	ra,40(sp)
    800046f4:	7402                	ld	s0,32(sp)
    800046f6:	6145                	addi	sp,sp,48
    800046f8:	8082                	ret

00000000800046fa <sys_write>:
{
    800046fa:	7179                	addi	sp,sp,-48
    800046fc:	f406                	sd	ra,40(sp)
    800046fe:	f022                	sd	s0,32(sp)
    80004700:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004702:	fd840593          	addi	a1,s0,-40
    80004706:	4505                	li	a0,1
    80004708:	ffffe097          	auipc	ra,0xffffe
    8000470c:	8be080e7          	jalr	-1858(ra) # 80001fc6 <argaddr>
  argint(2, &n);
    80004710:	fe440593          	addi	a1,s0,-28
    80004714:	4509                	li	a0,2
    80004716:	ffffe097          	auipc	ra,0xffffe
    8000471a:	890080e7          	jalr	-1904(ra) # 80001fa6 <argint>
  if(argfd(0, 0, &f) < 0)
    8000471e:	fe840613          	addi	a2,s0,-24
    80004722:	4581                	li	a1,0
    80004724:	4501                	li	a0,0
    80004726:	00000097          	auipc	ra,0x0
    8000472a:	cfe080e7          	jalr	-770(ra) # 80004424 <argfd>
    8000472e:	87aa                	mv	a5,a0
    return -1;
    80004730:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004732:	0007cc63          	bltz	a5,8000474a <sys_write+0x50>
  return filewrite(f, p, n);
    80004736:	fe442603          	lw	a2,-28(s0)
    8000473a:	fd843583          	ld	a1,-40(s0)
    8000473e:	fe843503          	ld	a0,-24(s0)
    80004742:	fffff097          	auipc	ra,0xfffff
    80004746:	4a6080e7          	jalr	1190(ra) # 80003be8 <filewrite>
}
    8000474a:	70a2                	ld	ra,40(sp)
    8000474c:	7402                	ld	s0,32(sp)
    8000474e:	6145                	addi	sp,sp,48
    80004750:	8082                	ret

0000000080004752 <sys_close>:
{
    80004752:	1101                	addi	sp,sp,-32
    80004754:	ec06                	sd	ra,24(sp)
    80004756:	e822                	sd	s0,16(sp)
    80004758:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000475a:	fe040613          	addi	a2,s0,-32
    8000475e:	fec40593          	addi	a1,s0,-20
    80004762:	4501                	li	a0,0
    80004764:	00000097          	auipc	ra,0x0
    80004768:	cc0080e7          	jalr	-832(ra) # 80004424 <argfd>
    return -1;
    8000476c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000476e:	02054463          	bltz	a0,80004796 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80004772:	ffffc097          	auipc	ra,0xffffc
    80004776:	6e2080e7          	jalr	1762(ra) # 80000e54 <myproc>
    8000477a:	fec42783          	lw	a5,-20(s0)
    8000477e:	07e9                	addi	a5,a5,26
    80004780:	078e                	slli	a5,a5,0x3
    80004782:	953e                	add	a0,a0,a5
    80004784:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004788:	fe043503          	ld	a0,-32(s0)
    8000478c:	fffff097          	auipc	ra,0xfffff
    80004790:	260080e7          	jalr	608(ra) # 800039ec <fileclose>
  return 0;
    80004794:	4781                	li	a5,0
}
    80004796:	853e                	mv	a0,a5
    80004798:	60e2                	ld	ra,24(sp)
    8000479a:	6442                	ld	s0,16(sp)
    8000479c:	6105                	addi	sp,sp,32
    8000479e:	8082                	ret

00000000800047a0 <sys_fstat>:
{
    800047a0:	1101                	addi	sp,sp,-32
    800047a2:	ec06                	sd	ra,24(sp)
    800047a4:	e822                	sd	s0,16(sp)
    800047a6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800047a8:	fe040593          	addi	a1,s0,-32
    800047ac:	4505                	li	a0,1
    800047ae:	ffffe097          	auipc	ra,0xffffe
    800047b2:	818080e7          	jalr	-2024(ra) # 80001fc6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800047b6:	fe840613          	addi	a2,s0,-24
    800047ba:	4581                	li	a1,0
    800047bc:	4501                	li	a0,0
    800047be:	00000097          	auipc	ra,0x0
    800047c2:	c66080e7          	jalr	-922(ra) # 80004424 <argfd>
    800047c6:	87aa                	mv	a5,a0
    return -1;
    800047c8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800047ca:	0007ca63          	bltz	a5,800047de <sys_fstat+0x3e>
  return filestat(f, st);
    800047ce:	fe043583          	ld	a1,-32(s0)
    800047d2:	fe843503          	ld	a0,-24(s0)
    800047d6:	fffff097          	auipc	ra,0xfffff
    800047da:	2de080e7          	jalr	734(ra) # 80003ab4 <filestat>
}
    800047de:	60e2                	ld	ra,24(sp)
    800047e0:	6442                	ld	s0,16(sp)
    800047e2:	6105                	addi	sp,sp,32
    800047e4:	8082                	ret

00000000800047e6 <sys_link>:
{
    800047e6:	7169                	addi	sp,sp,-304
    800047e8:	f606                	sd	ra,296(sp)
    800047ea:	f222                	sd	s0,288(sp)
    800047ec:	ee26                	sd	s1,280(sp)
    800047ee:	ea4a                	sd	s2,272(sp)
    800047f0:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800047f2:	08000613          	li	a2,128
    800047f6:	ed040593          	addi	a1,s0,-304
    800047fa:	4501                	li	a0,0
    800047fc:	ffffd097          	auipc	ra,0xffffd
    80004800:	7ea080e7          	jalr	2026(ra) # 80001fe6 <argstr>
    return -1;
    80004804:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004806:	10054e63          	bltz	a0,80004922 <sys_link+0x13c>
    8000480a:	08000613          	li	a2,128
    8000480e:	f5040593          	addi	a1,s0,-176
    80004812:	4505                	li	a0,1
    80004814:	ffffd097          	auipc	ra,0xffffd
    80004818:	7d2080e7          	jalr	2002(ra) # 80001fe6 <argstr>
    return -1;
    8000481c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000481e:	10054263          	bltz	a0,80004922 <sys_link+0x13c>
  begin_op();
    80004822:	fffff097          	auipc	ra,0xfffff
    80004826:	d02080e7          	jalr	-766(ra) # 80003524 <begin_op>
  if((ip = namei(old)) == 0){
    8000482a:	ed040513          	addi	a0,s0,-304
    8000482e:	fffff097          	auipc	ra,0xfffff
    80004832:	ad6080e7          	jalr	-1322(ra) # 80003304 <namei>
    80004836:	84aa                	mv	s1,a0
    80004838:	c551                	beqz	a0,800048c4 <sys_link+0xde>
  ilock(ip);
    8000483a:	ffffe097          	auipc	ra,0xffffe
    8000483e:	31e080e7          	jalr	798(ra) # 80002b58 <ilock>
  if(ip->type == T_DIR){
    80004842:	04449703          	lh	a4,68(s1)
    80004846:	4785                	li	a5,1
    80004848:	08f70463          	beq	a4,a5,800048d0 <sys_link+0xea>
  ip->nlink++;
    8000484c:	04a4d783          	lhu	a5,74(s1)
    80004850:	2785                	addiw	a5,a5,1
    80004852:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004856:	8526                	mv	a0,s1
    80004858:	ffffe097          	auipc	ra,0xffffe
    8000485c:	234080e7          	jalr	564(ra) # 80002a8c <iupdate>
  iunlock(ip);
    80004860:	8526                	mv	a0,s1
    80004862:	ffffe097          	auipc	ra,0xffffe
    80004866:	3b8080e7          	jalr	952(ra) # 80002c1a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000486a:	fd040593          	addi	a1,s0,-48
    8000486e:	f5040513          	addi	a0,s0,-176
    80004872:	fffff097          	auipc	ra,0xfffff
    80004876:	ab0080e7          	jalr	-1360(ra) # 80003322 <nameiparent>
    8000487a:	892a                	mv	s2,a0
    8000487c:	c935                	beqz	a0,800048f0 <sys_link+0x10a>
  ilock(dp);
    8000487e:	ffffe097          	auipc	ra,0xffffe
    80004882:	2da080e7          	jalr	730(ra) # 80002b58 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004886:	00092703          	lw	a4,0(s2)
    8000488a:	409c                	lw	a5,0(s1)
    8000488c:	04f71d63          	bne	a4,a5,800048e6 <sys_link+0x100>
    80004890:	40d0                	lw	a2,4(s1)
    80004892:	fd040593          	addi	a1,s0,-48
    80004896:	854a                	mv	a0,s2
    80004898:	fffff097          	auipc	ra,0xfffff
    8000489c:	9ba080e7          	jalr	-1606(ra) # 80003252 <dirlink>
    800048a0:	04054363          	bltz	a0,800048e6 <sys_link+0x100>
  iunlockput(dp);
    800048a4:	854a                	mv	a0,s2
    800048a6:	ffffe097          	auipc	ra,0xffffe
    800048aa:	514080e7          	jalr	1300(ra) # 80002dba <iunlockput>
  iput(ip);
    800048ae:	8526                	mv	a0,s1
    800048b0:	ffffe097          	auipc	ra,0xffffe
    800048b4:	462080e7          	jalr	1122(ra) # 80002d12 <iput>
  end_op();
    800048b8:	fffff097          	auipc	ra,0xfffff
    800048bc:	cea080e7          	jalr	-790(ra) # 800035a2 <end_op>
  return 0;
    800048c0:	4781                	li	a5,0
    800048c2:	a085                	j	80004922 <sys_link+0x13c>
    end_op();
    800048c4:	fffff097          	auipc	ra,0xfffff
    800048c8:	cde080e7          	jalr	-802(ra) # 800035a2 <end_op>
    return -1;
    800048cc:	57fd                	li	a5,-1
    800048ce:	a891                	j	80004922 <sys_link+0x13c>
    iunlockput(ip);
    800048d0:	8526                	mv	a0,s1
    800048d2:	ffffe097          	auipc	ra,0xffffe
    800048d6:	4e8080e7          	jalr	1256(ra) # 80002dba <iunlockput>
    end_op();
    800048da:	fffff097          	auipc	ra,0xfffff
    800048de:	cc8080e7          	jalr	-824(ra) # 800035a2 <end_op>
    return -1;
    800048e2:	57fd                	li	a5,-1
    800048e4:	a83d                	j	80004922 <sys_link+0x13c>
    iunlockput(dp);
    800048e6:	854a                	mv	a0,s2
    800048e8:	ffffe097          	auipc	ra,0xffffe
    800048ec:	4d2080e7          	jalr	1234(ra) # 80002dba <iunlockput>
  ilock(ip);
    800048f0:	8526                	mv	a0,s1
    800048f2:	ffffe097          	auipc	ra,0xffffe
    800048f6:	266080e7          	jalr	614(ra) # 80002b58 <ilock>
  ip->nlink--;
    800048fa:	04a4d783          	lhu	a5,74(s1)
    800048fe:	37fd                	addiw	a5,a5,-1
    80004900:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004904:	8526                	mv	a0,s1
    80004906:	ffffe097          	auipc	ra,0xffffe
    8000490a:	186080e7          	jalr	390(ra) # 80002a8c <iupdate>
  iunlockput(ip);
    8000490e:	8526                	mv	a0,s1
    80004910:	ffffe097          	auipc	ra,0xffffe
    80004914:	4aa080e7          	jalr	1194(ra) # 80002dba <iunlockput>
  end_op();
    80004918:	fffff097          	auipc	ra,0xfffff
    8000491c:	c8a080e7          	jalr	-886(ra) # 800035a2 <end_op>
  return -1;
    80004920:	57fd                	li	a5,-1
}
    80004922:	853e                	mv	a0,a5
    80004924:	70b2                	ld	ra,296(sp)
    80004926:	7412                	ld	s0,288(sp)
    80004928:	64f2                	ld	s1,280(sp)
    8000492a:	6952                	ld	s2,272(sp)
    8000492c:	6155                	addi	sp,sp,304
    8000492e:	8082                	ret

0000000080004930 <sys_unlink>:
{
    80004930:	7151                	addi	sp,sp,-240
    80004932:	f586                	sd	ra,232(sp)
    80004934:	f1a2                	sd	s0,224(sp)
    80004936:	eda6                	sd	s1,216(sp)
    80004938:	e9ca                	sd	s2,208(sp)
    8000493a:	e5ce                	sd	s3,200(sp)
    8000493c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000493e:	08000613          	li	a2,128
    80004942:	f3040593          	addi	a1,s0,-208
    80004946:	4501                	li	a0,0
    80004948:	ffffd097          	auipc	ra,0xffffd
    8000494c:	69e080e7          	jalr	1694(ra) # 80001fe6 <argstr>
    80004950:	18054163          	bltz	a0,80004ad2 <sys_unlink+0x1a2>
  begin_op();
    80004954:	fffff097          	auipc	ra,0xfffff
    80004958:	bd0080e7          	jalr	-1072(ra) # 80003524 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000495c:	fb040593          	addi	a1,s0,-80
    80004960:	f3040513          	addi	a0,s0,-208
    80004964:	fffff097          	auipc	ra,0xfffff
    80004968:	9be080e7          	jalr	-1602(ra) # 80003322 <nameiparent>
    8000496c:	84aa                	mv	s1,a0
    8000496e:	c979                	beqz	a0,80004a44 <sys_unlink+0x114>
  ilock(dp);
    80004970:	ffffe097          	auipc	ra,0xffffe
    80004974:	1e8080e7          	jalr	488(ra) # 80002b58 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004978:	00004597          	auipc	a1,0x4
    8000497c:	cf858593          	addi	a1,a1,-776 # 80008670 <syscalls+0x2a0>
    80004980:	fb040513          	addi	a0,s0,-80
    80004984:	ffffe097          	auipc	ra,0xffffe
    80004988:	69e080e7          	jalr	1694(ra) # 80003022 <namecmp>
    8000498c:	14050a63          	beqz	a0,80004ae0 <sys_unlink+0x1b0>
    80004990:	00004597          	auipc	a1,0x4
    80004994:	ce858593          	addi	a1,a1,-792 # 80008678 <syscalls+0x2a8>
    80004998:	fb040513          	addi	a0,s0,-80
    8000499c:	ffffe097          	auipc	ra,0xffffe
    800049a0:	686080e7          	jalr	1670(ra) # 80003022 <namecmp>
    800049a4:	12050e63          	beqz	a0,80004ae0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800049a8:	f2c40613          	addi	a2,s0,-212
    800049ac:	fb040593          	addi	a1,s0,-80
    800049b0:	8526                	mv	a0,s1
    800049b2:	ffffe097          	auipc	ra,0xffffe
    800049b6:	68a080e7          	jalr	1674(ra) # 8000303c <dirlookup>
    800049ba:	892a                	mv	s2,a0
    800049bc:	12050263          	beqz	a0,80004ae0 <sys_unlink+0x1b0>
  ilock(ip);
    800049c0:	ffffe097          	auipc	ra,0xffffe
    800049c4:	198080e7          	jalr	408(ra) # 80002b58 <ilock>
  if(ip->nlink < 1)
    800049c8:	04a91783          	lh	a5,74(s2)
    800049cc:	08f05263          	blez	a5,80004a50 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800049d0:	04491703          	lh	a4,68(s2)
    800049d4:	4785                	li	a5,1
    800049d6:	08f70563          	beq	a4,a5,80004a60 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800049da:	4641                	li	a2,16
    800049dc:	4581                	li	a1,0
    800049de:	fc040513          	addi	a0,s0,-64
    800049e2:	ffffb097          	auipc	ra,0xffffb
    800049e6:	798080e7          	jalr	1944(ra) # 8000017a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800049ea:	4741                	li	a4,16
    800049ec:	f2c42683          	lw	a3,-212(s0)
    800049f0:	fc040613          	addi	a2,s0,-64
    800049f4:	4581                	li	a1,0
    800049f6:	8526                	mv	a0,s1
    800049f8:	ffffe097          	auipc	ra,0xffffe
    800049fc:	50c080e7          	jalr	1292(ra) # 80002f04 <writei>
    80004a00:	47c1                	li	a5,16
    80004a02:	0af51563          	bne	a0,a5,80004aac <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004a06:	04491703          	lh	a4,68(s2)
    80004a0a:	4785                	li	a5,1
    80004a0c:	0af70863          	beq	a4,a5,80004abc <sys_unlink+0x18c>
  iunlockput(dp);
    80004a10:	8526                	mv	a0,s1
    80004a12:	ffffe097          	auipc	ra,0xffffe
    80004a16:	3a8080e7          	jalr	936(ra) # 80002dba <iunlockput>
  ip->nlink--;
    80004a1a:	04a95783          	lhu	a5,74(s2)
    80004a1e:	37fd                	addiw	a5,a5,-1
    80004a20:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004a24:	854a                	mv	a0,s2
    80004a26:	ffffe097          	auipc	ra,0xffffe
    80004a2a:	066080e7          	jalr	102(ra) # 80002a8c <iupdate>
  iunlockput(ip);
    80004a2e:	854a                	mv	a0,s2
    80004a30:	ffffe097          	auipc	ra,0xffffe
    80004a34:	38a080e7          	jalr	906(ra) # 80002dba <iunlockput>
  end_op();
    80004a38:	fffff097          	auipc	ra,0xfffff
    80004a3c:	b6a080e7          	jalr	-1174(ra) # 800035a2 <end_op>
  return 0;
    80004a40:	4501                	li	a0,0
    80004a42:	a84d                	j	80004af4 <sys_unlink+0x1c4>
    end_op();
    80004a44:	fffff097          	auipc	ra,0xfffff
    80004a48:	b5e080e7          	jalr	-1186(ra) # 800035a2 <end_op>
    return -1;
    80004a4c:	557d                	li	a0,-1
    80004a4e:	a05d                	j	80004af4 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004a50:	00004517          	auipc	a0,0x4
    80004a54:	c3050513          	addi	a0,a0,-976 # 80008680 <syscalls+0x2b0>
    80004a58:	00001097          	auipc	ra,0x1
    80004a5c:	1b4080e7          	jalr	436(ra) # 80005c0c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004a60:	04c92703          	lw	a4,76(s2)
    80004a64:	02000793          	li	a5,32
    80004a68:	f6e7f9e3          	bgeu	a5,a4,800049da <sys_unlink+0xaa>
    80004a6c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004a70:	4741                	li	a4,16
    80004a72:	86ce                	mv	a3,s3
    80004a74:	f1840613          	addi	a2,s0,-232
    80004a78:	4581                	li	a1,0
    80004a7a:	854a                	mv	a0,s2
    80004a7c:	ffffe097          	auipc	ra,0xffffe
    80004a80:	390080e7          	jalr	912(ra) # 80002e0c <readi>
    80004a84:	47c1                	li	a5,16
    80004a86:	00f51b63          	bne	a0,a5,80004a9c <sys_unlink+0x16c>
    if(de.inum != 0)
    80004a8a:	f1845783          	lhu	a5,-232(s0)
    80004a8e:	e7a1                	bnez	a5,80004ad6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004a90:	29c1                	addiw	s3,s3,16
    80004a92:	04c92783          	lw	a5,76(s2)
    80004a96:	fcf9ede3          	bltu	s3,a5,80004a70 <sys_unlink+0x140>
    80004a9a:	b781                	j	800049da <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004a9c:	00004517          	auipc	a0,0x4
    80004aa0:	bfc50513          	addi	a0,a0,-1028 # 80008698 <syscalls+0x2c8>
    80004aa4:	00001097          	auipc	ra,0x1
    80004aa8:	168080e7          	jalr	360(ra) # 80005c0c <panic>
    panic("unlink: writei");
    80004aac:	00004517          	auipc	a0,0x4
    80004ab0:	c0450513          	addi	a0,a0,-1020 # 800086b0 <syscalls+0x2e0>
    80004ab4:	00001097          	auipc	ra,0x1
    80004ab8:	158080e7          	jalr	344(ra) # 80005c0c <panic>
    dp->nlink--;
    80004abc:	04a4d783          	lhu	a5,74(s1)
    80004ac0:	37fd                	addiw	a5,a5,-1
    80004ac2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004ac6:	8526                	mv	a0,s1
    80004ac8:	ffffe097          	auipc	ra,0xffffe
    80004acc:	fc4080e7          	jalr	-60(ra) # 80002a8c <iupdate>
    80004ad0:	b781                	j	80004a10 <sys_unlink+0xe0>
    return -1;
    80004ad2:	557d                	li	a0,-1
    80004ad4:	a005                	j	80004af4 <sys_unlink+0x1c4>
    iunlockput(ip);
    80004ad6:	854a                	mv	a0,s2
    80004ad8:	ffffe097          	auipc	ra,0xffffe
    80004adc:	2e2080e7          	jalr	738(ra) # 80002dba <iunlockput>
  iunlockput(dp);
    80004ae0:	8526                	mv	a0,s1
    80004ae2:	ffffe097          	auipc	ra,0xffffe
    80004ae6:	2d8080e7          	jalr	728(ra) # 80002dba <iunlockput>
  end_op();
    80004aea:	fffff097          	auipc	ra,0xfffff
    80004aee:	ab8080e7          	jalr	-1352(ra) # 800035a2 <end_op>
  return -1;
    80004af2:	557d                	li	a0,-1
}
    80004af4:	70ae                	ld	ra,232(sp)
    80004af6:	740e                	ld	s0,224(sp)
    80004af8:	64ee                	ld	s1,216(sp)
    80004afa:	694e                	ld	s2,208(sp)
    80004afc:	69ae                	ld	s3,200(sp)
    80004afe:	616d                	addi	sp,sp,240
    80004b00:	8082                	ret

0000000080004b02 <sys_open>:

uint64
sys_open(void)
{
    80004b02:	7131                	addi	sp,sp,-192
    80004b04:	fd06                	sd	ra,184(sp)
    80004b06:	f922                	sd	s0,176(sp)
    80004b08:	f526                	sd	s1,168(sp)
    80004b0a:	f14a                	sd	s2,160(sp)
    80004b0c:	ed4e                	sd	s3,152(sp)
    80004b0e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004b10:	f4c40593          	addi	a1,s0,-180
    80004b14:	4505                	li	a0,1
    80004b16:	ffffd097          	auipc	ra,0xffffd
    80004b1a:	490080e7          	jalr	1168(ra) # 80001fa6 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004b1e:	08000613          	li	a2,128
    80004b22:	f5040593          	addi	a1,s0,-176
    80004b26:	4501                	li	a0,0
    80004b28:	ffffd097          	auipc	ra,0xffffd
    80004b2c:	4be080e7          	jalr	1214(ra) # 80001fe6 <argstr>
    80004b30:	87aa                	mv	a5,a0
    return -1;
    80004b32:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004b34:	0a07c963          	bltz	a5,80004be6 <sys_open+0xe4>

  begin_op();
    80004b38:	fffff097          	auipc	ra,0xfffff
    80004b3c:	9ec080e7          	jalr	-1556(ra) # 80003524 <begin_op>

  if(omode & O_CREATE){
    80004b40:	f4c42783          	lw	a5,-180(s0)
    80004b44:	2007f793          	andi	a5,a5,512
    80004b48:	cfc5                	beqz	a5,80004c00 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004b4a:	4681                	li	a3,0
    80004b4c:	4601                	li	a2,0
    80004b4e:	4589                	li	a1,2
    80004b50:	f5040513          	addi	a0,s0,-176
    80004b54:	00000097          	auipc	ra,0x0
    80004b58:	972080e7          	jalr	-1678(ra) # 800044c6 <create>
    80004b5c:	84aa                	mv	s1,a0
    if(ip == 0){
    80004b5e:	c959                	beqz	a0,80004bf4 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004b60:	04449703          	lh	a4,68(s1)
    80004b64:	478d                	li	a5,3
    80004b66:	00f71763          	bne	a4,a5,80004b74 <sys_open+0x72>
    80004b6a:	0464d703          	lhu	a4,70(s1)
    80004b6e:	47a5                	li	a5,9
    80004b70:	0ce7ed63          	bltu	a5,a4,80004c4a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004b74:	fffff097          	auipc	ra,0xfffff
    80004b78:	dbc080e7          	jalr	-580(ra) # 80003930 <filealloc>
    80004b7c:	89aa                	mv	s3,a0
    80004b7e:	10050363          	beqz	a0,80004c84 <sys_open+0x182>
    80004b82:	00000097          	auipc	ra,0x0
    80004b86:	902080e7          	jalr	-1790(ra) # 80004484 <fdalloc>
    80004b8a:	892a                	mv	s2,a0
    80004b8c:	0e054763          	bltz	a0,80004c7a <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004b90:	04449703          	lh	a4,68(s1)
    80004b94:	478d                	li	a5,3
    80004b96:	0cf70563          	beq	a4,a5,80004c60 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004b9a:	4789                	li	a5,2
    80004b9c:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004ba0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004ba4:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004ba8:	f4c42783          	lw	a5,-180(s0)
    80004bac:	0017c713          	xori	a4,a5,1
    80004bb0:	8b05                	andi	a4,a4,1
    80004bb2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004bb6:	0037f713          	andi	a4,a5,3
    80004bba:	00e03733          	snez	a4,a4
    80004bbe:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004bc2:	4007f793          	andi	a5,a5,1024
    80004bc6:	c791                	beqz	a5,80004bd2 <sys_open+0xd0>
    80004bc8:	04449703          	lh	a4,68(s1)
    80004bcc:	4789                	li	a5,2
    80004bce:	0af70063          	beq	a4,a5,80004c6e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004bd2:	8526                	mv	a0,s1
    80004bd4:	ffffe097          	auipc	ra,0xffffe
    80004bd8:	046080e7          	jalr	70(ra) # 80002c1a <iunlock>
  end_op();
    80004bdc:	fffff097          	auipc	ra,0xfffff
    80004be0:	9c6080e7          	jalr	-1594(ra) # 800035a2 <end_op>

  return fd;
    80004be4:	854a                	mv	a0,s2
}
    80004be6:	70ea                	ld	ra,184(sp)
    80004be8:	744a                	ld	s0,176(sp)
    80004bea:	74aa                	ld	s1,168(sp)
    80004bec:	790a                	ld	s2,160(sp)
    80004bee:	69ea                	ld	s3,152(sp)
    80004bf0:	6129                	addi	sp,sp,192
    80004bf2:	8082                	ret
      end_op();
    80004bf4:	fffff097          	auipc	ra,0xfffff
    80004bf8:	9ae080e7          	jalr	-1618(ra) # 800035a2 <end_op>
      return -1;
    80004bfc:	557d                	li	a0,-1
    80004bfe:	b7e5                	j	80004be6 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004c00:	f5040513          	addi	a0,s0,-176
    80004c04:	ffffe097          	auipc	ra,0xffffe
    80004c08:	700080e7          	jalr	1792(ra) # 80003304 <namei>
    80004c0c:	84aa                	mv	s1,a0
    80004c0e:	c905                	beqz	a0,80004c3e <sys_open+0x13c>
    ilock(ip);
    80004c10:	ffffe097          	auipc	ra,0xffffe
    80004c14:	f48080e7          	jalr	-184(ra) # 80002b58 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004c18:	04449703          	lh	a4,68(s1)
    80004c1c:	4785                	li	a5,1
    80004c1e:	f4f711e3          	bne	a4,a5,80004b60 <sys_open+0x5e>
    80004c22:	f4c42783          	lw	a5,-180(s0)
    80004c26:	d7b9                	beqz	a5,80004b74 <sys_open+0x72>
      iunlockput(ip);
    80004c28:	8526                	mv	a0,s1
    80004c2a:	ffffe097          	auipc	ra,0xffffe
    80004c2e:	190080e7          	jalr	400(ra) # 80002dba <iunlockput>
      end_op();
    80004c32:	fffff097          	auipc	ra,0xfffff
    80004c36:	970080e7          	jalr	-1680(ra) # 800035a2 <end_op>
      return -1;
    80004c3a:	557d                	li	a0,-1
    80004c3c:	b76d                	j	80004be6 <sys_open+0xe4>
      end_op();
    80004c3e:	fffff097          	auipc	ra,0xfffff
    80004c42:	964080e7          	jalr	-1692(ra) # 800035a2 <end_op>
      return -1;
    80004c46:	557d                	li	a0,-1
    80004c48:	bf79                	j	80004be6 <sys_open+0xe4>
    iunlockput(ip);
    80004c4a:	8526                	mv	a0,s1
    80004c4c:	ffffe097          	auipc	ra,0xffffe
    80004c50:	16e080e7          	jalr	366(ra) # 80002dba <iunlockput>
    end_op();
    80004c54:	fffff097          	auipc	ra,0xfffff
    80004c58:	94e080e7          	jalr	-1714(ra) # 800035a2 <end_op>
    return -1;
    80004c5c:	557d                	li	a0,-1
    80004c5e:	b761                	j	80004be6 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004c60:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004c64:	04649783          	lh	a5,70(s1)
    80004c68:	02f99223          	sh	a5,36(s3)
    80004c6c:	bf25                	j	80004ba4 <sys_open+0xa2>
    itrunc(ip);
    80004c6e:	8526                	mv	a0,s1
    80004c70:	ffffe097          	auipc	ra,0xffffe
    80004c74:	ff6080e7          	jalr	-10(ra) # 80002c66 <itrunc>
    80004c78:	bfa9                	j	80004bd2 <sys_open+0xd0>
      fileclose(f);
    80004c7a:	854e                	mv	a0,s3
    80004c7c:	fffff097          	auipc	ra,0xfffff
    80004c80:	d70080e7          	jalr	-656(ra) # 800039ec <fileclose>
    iunlockput(ip);
    80004c84:	8526                	mv	a0,s1
    80004c86:	ffffe097          	auipc	ra,0xffffe
    80004c8a:	134080e7          	jalr	308(ra) # 80002dba <iunlockput>
    end_op();
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	914080e7          	jalr	-1772(ra) # 800035a2 <end_op>
    return -1;
    80004c96:	557d                	li	a0,-1
    80004c98:	b7b9                	j	80004be6 <sys_open+0xe4>

0000000080004c9a <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004c9a:	7175                	addi	sp,sp,-144
    80004c9c:	e506                	sd	ra,136(sp)
    80004c9e:	e122                	sd	s0,128(sp)
    80004ca0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004ca2:	fffff097          	auipc	ra,0xfffff
    80004ca6:	882080e7          	jalr	-1918(ra) # 80003524 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004caa:	08000613          	li	a2,128
    80004cae:	f7040593          	addi	a1,s0,-144
    80004cb2:	4501                	li	a0,0
    80004cb4:	ffffd097          	auipc	ra,0xffffd
    80004cb8:	332080e7          	jalr	818(ra) # 80001fe6 <argstr>
    80004cbc:	02054963          	bltz	a0,80004cee <sys_mkdir+0x54>
    80004cc0:	4681                	li	a3,0
    80004cc2:	4601                	li	a2,0
    80004cc4:	4585                	li	a1,1
    80004cc6:	f7040513          	addi	a0,s0,-144
    80004cca:	fffff097          	auipc	ra,0xfffff
    80004cce:	7fc080e7          	jalr	2044(ra) # 800044c6 <create>
    80004cd2:	cd11                	beqz	a0,80004cee <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004cd4:	ffffe097          	auipc	ra,0xffffe
    80004cd8:	0e6080e7          	jalr	230(ra) # 80002dba <iunlockput>
  end_op();
    80004cdc:	fffff097          	auipc	ra,0xfffff
    80004ce0:	8c6080e7          	jalr	-1850(ra) # 800035a2 <end_op>
  return 0;
    80004ce4:	4501                	li	a0,0
}
    80004ce6:	60aa                	ld	ra,136(sp)
    80004ce8:	640a                	ld	s0,128(sp)
    80004cea:	6149                	addi	sp,sp,144
    80004cec:	8082                	ret
    end_op();
    80004cee:	fffff097          	auipc	ra,0xfffff
    80004cf2:	8b4080e7          	jalr	-1868(ra) # 800035a2 <end_op>
    return -1;
    80004cf6:	557d                	li	a0,-1
    80004cf8:	b7fd                	j	80004ce6 <sys_mkdir+0x4c>

0000000080004cfa <sys_mknod>:

uint64
sys_mknod(void)
{
    80004cfa:	7135                	addi	sp,sp,-160
    80004cfc:	ed06                	sd	ra,152(sp)
    80004cfe:	e922                	sd	s0,144(sp)
    80004d00:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004d02:	fffff097          	auipc	ra,0xfffff
    80004d06:	822080e7          	jalr	-2014(ra) # 80003524 <begin_op>
  argint(1, &major);
    80004d0a:	f6c40593          	addi	a1,s0,-148
    80004d0e:	4505                	li	a0,1
    80004d10:	ffffd097          	auipc	ra,0xffffd
    80004d14:	296080e7          	jalr	662(ra) # 80001fa6 <argint>
  argint(2, &minor);
    80004d18:	f6840593          	addi	a1,s0,-152
    80004d1c:	4509                	li	a0,2
    80004d1e:	ffffd097          	auipc	ra,0xffffd
    80004d22:	288080e7          	jalr	648(ra) # 80001fa6 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004d26:	08000613          	li	a2,128
    80004d2a:	f7040593          	addi	a1,s0,-144
    80004d2e:	4501                	li	a0,0
    80004d30:	ffffd097          	auipc	ra,0xffffd
    80004d34:	2b6080e7          	jalr	694(ra) # 80001fe6 <argstr>
    80004d38:	02054b63          	bltz	a0,80004d6e <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004d3c:	f6841683          	lh	a3,-152(s0)
    80004d40:	f6c41603          	lh	a2,-148(s0)
    80004d44:	458d                	li	a1,3
    80004d46:	f7040513          	addi	a0,s0,-144
    80004d4a:	fffff097          	auipc	ra,0xfffff
    80004d4e:	77c080e7          	jalr	1916(ra) # 800044c6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004d52:	cd11                	beqz	a0,80004d6e <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004d54:	ffffe097          	auipc	ra,0xffffe
    80004d58:	066080e7          	jalr	102(ra) # 80002dba <iunlockput>
  end_op();
    80004d5c:	fffff097          	auipc	ra,0xfffff
    80004d60:	846080e7          	jalr	-1978(ra) # 800035a2 <end_op>
  return 0;
    80004d64:	4501                	li	a0,0
}
    80004d66:	60ea                	ld	ra,152(sp)
    80004d68:	644a                	ld	s0,144(sp)
    80004d6a:	610d                	addi	sp,sp,160
    80004d6c:	8082                	ret
    end_op();
    80004d6e:	fffff097          	auipc	ra,0xfffff
    80004d72:	834080e7          	jalr	-1996(ra) # 800035a2 <end_op>
    return -1;
    80004d76:	557d                	li	a0,-1
    80004d78:	b7fd                	j	80004d66 <sys_mknod+0x6c>

0000000080004d7a <sys_chdir>:

uint64
sys_chdir(void)
{
    80004d7a:	7135                	addi	sp,sp,-160
    80004d7c:	ed06                	sd	ra,152(sp)
    80004d7e:	e922                	sd	s0,144(sp)
    80004d80:	e526                	sd	s1,136(sp)
    80004d82:	e14a                	sd	s2,128(sp)
    80004d84:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004d86:	ffffc097          	auipc	ra,0xffffc
    80004d8a:	0ce080e7          	jalr	206(ra) # 80000e54 <myproc>
    80004d8e:	892a                	mv	s2,a0
  
  begin_op();
    80004d90:	ffffe097          	auipc	ra,0xffffe
    80004d94:	794080e7          	jalr	1940(ra) # 80003524 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004d98:	08000613          	li	a2,128
    80004d9c:	f6040593          	addi	a1,s0,-160
    80004da0:	4501                	li	a0,0
    80004da2:	ffffd097          	auipc	ra,0xffffd
    80004da6:	244080e7          	jalr	580(ra) # 80001fe6 <argstr>
    80004daa:	04054b63          	bltz	a0,80004e00 <sys_chdir+0x86>
    80004dae:	f6040513          	addi	a0,s0,-160
    80004db2:	ffffe097          	auipc	ra,0xffffe
    80004db6:	552080e7          	jalr	1362(ra) # 80003304 <namei>
    80004dba:	84aa                	mv	s1,a0
    80004dbc:	c131                	beqz	a0,80004e00 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004dbe:	ffffe097          	auipc	ra,0xffffe
    80004dc2:	d9a080e7          	jalr	-614(ra) # 80002b58 <ilock>
  if(ip->type != T_DIR){
    80004dc6:	04449703          	lh	a4,68(s1)
    80004dca:	4785                	li	a5,1
    80004dcc:	04f71063          	bne	a4,a5,80004e0c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	ffffe097          	auipc	ra,0xffffe
    80004dd6:	e48080e7          	jalr	-440(ra) # 80002c1a <iunlock>
  iput(p->cwd);
    80004dda:	15093503          	ld	a0,336(s2)
    80004dde:	ffffe097          	auipc	ra,0xffffe
    80004de2:	f34080e7          	jalr	-204(ra) # 80002d12 <iput>
  end_op();
    80004de6:	ffffe097          	auipc	ra,0xffffe
    80004dea:	7bc080e7          	jalr	1980(ra) # 800035a2 <end_op>
  p->cwd = ip;
    80004dee:	14993823          	sd	s1,336(s2)
  return 0;
    80004df2:	4501                	li	a0,0
}
    80004df4:	60ea                	ld	ra,152(sp)
    80004df6:	644a                	ld	s0,144(sp)
    80004df8:	64aa                	ld	s1,136(sp)
    80004dfa:	690a                	ld	s2,128(sp)
    80004dfc:	610d                	addi	sp,sp,160
    80004dfe:	8082                	ret
    end_op();
    80004e00:	ffffe097          	auipc	ra,0xffffe
    80004e04:	7a2080e7          	jalr	1954(ra) # 800035a2 <end_op>
    return -1;
    80004e08:	557d                	li	a0,-1
    80004e0a:	b7ed                	j	80004df4 <sys_chdir+0x7a>
    iunlockput(ip);
    80004e0c:	8526                	mv	a0,s1
    80004e0e:	ffffe097          	auipc	ra,0xffffe
    80004e12:	fac080e7          	jalr	-84(ra) # 80002dba <iunlockput>
    end_op();
    80004e16:	ffffe097          	auipc	ra,0xffffe
    80004e1a:	78c080e7          	jalr	1932(ra) # 800035a2 <end_op>
    return -1;
    80004e1e:	557d                	li	a0,-1
    80004e20:	bfd1                	j	80004df4 <sys_chdir+0x7a>

0000000080004e22 <sys_exec>:

uint64
sys_exec(void)
{
    80004e22:	7145                	addi	sp,sp,-464
    80004e24:	e786                	sd	ra,456(sp)
    80004e26:	e3a2                	sd	s0,448(sp)
    80004e28:	ff26                	sd	s1,440(sp)
    80004e2a:	fb4a                	sd	s2,432(sp)
    80004e2c:	f74e                	sd	s3,424(sp)
    80004e2e:	f352                	sd	s4,416(sp)
    80004e30:	ef56                	sd	s5,408(sp)
    80004e32:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004e34:	e3840593          	addi	a1,s0,-456
    80004e38:	4505                	li	a0,1
    80004e3a:	ffffd097          	auipc	ra,0xffffd
    80004e3e:	18c080e7          	jalr	396(ra) # 80001fc6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004e42:	08000613          	li	a2,128
    80004e46:	f4040593          	addi	a1,s0,-192
    80004e4a:	4501                	li	a0,0
    80004e4c:	ffffd097          	auipc	ra,0xffffd
    80004e50:	19a080e7          	jalr	410(ra) # 80001fe6 <argstr>
    80004e54:	87aa                	mv	a5,a0
    return -1;
    80004e56:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004e58:	0c07c363          	bltz	a5,80004f1e <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80004e5c:	10000613          	li	a2,256
    80004e60:	4581                	li	a1,0
    80004e62:	e4040513          	addi	a0,s0,-448
    80004e66:	ffffb097          	auipc	ra,0xffffb
    80004e6a:	314080e7          	jalr	788(ra) # 8000017a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004e6e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004e72:	89a6                	mv	s3,s1
    80004e74:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004e76:	02000a13          	li	s4,32
    80004e7a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004e7e:	00391513          	slli	a0,s2,0x3
    80004e82:	e3040593          	addi	a1,s0,-464
    80004e86:	e3843783          	ld	a5,-456(s0)
    80004e8a:	953e                	add	a0,a0,a5
    80004e8c:	ffffd097          	auipc	ra,0xffffd
    80004e90:	07c080e7          	jalr	124(ra) # 80001f08 <fetchaddr>
    80004e94:	02054a63          	bltz	a0,80004ec8 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80004e98:	e3043783          	ld	a5,-464(s0)
    80004e9c:	c3b9                	beqz	a5,80004ee2 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004e9e:	ffffb097          	auipc	ra,0xffffb
    80004ea2:	27c080e7          	jalr	636(ra) # 8000011a <kalloc>
    80004ea6:	85aa                	mv	a1,a0
    80004ea8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004eac:	cd11                	beqz	a0,80004ec8 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004eae:	6605                	lui	a2,0x1
    80004eb0:	e3043503          	ld	a0,-464(s0)
    80004eb4:	ffffd097          	auipc	ra,0xffffd
    80004eb8:	0a6080e7          	jalr	166(ra) # 80001f5a <fetchstr>
    80004ebc:	00054663          	bltz	a0,80004ec8 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80004ec0:	0905                	addi	s2,s2,1
    80004ec2:	09a1                	addi	s3,s3,8
    80004ec4:	fb491be3          	bne	s2,s4,80004e7a <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ec8:	f4040913          	addi	s2,s0,-192
    80004ecc:	6088                	ld	a0,0(s1)
    80004ece:	c539                	beqz	a0,80004f1c <sys_exec+0xfa>
    kfree(argv[i]);
    80004ed0:	ffffb097          	auipc	ra,0xffffb
    80004ed4:	14c080e7          	jalr	332(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ed8:	04a1                	addi	s1,s1,8
    80004eda:	ff2499e3          	bne	s1,s2,80004ecc <sys_exec+0xaa>
  return -1;
    80004ede:	557d                	li	a0,-1
    80004ee0:	a83d                	j	80004f1e <sys_exec+0xfc>
      argv[i] = 0;
    80004ee2:	0a8e                	slli	s5,s5,0x3
    80004ee4:	fc0a8793          	addi	a5,s5,-64
    80004ee8:	00878ab3          	add	s5,a5,s0
    80004eec:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004ef0:	e4040593          	addi	a1,s0,-448
    80004ef4:	f4040513          	addi	a0,s0,-192
    80004ef8:	fffff097          	auipc	ra,0xfffff
    80004efc:	16e080e7          	jalr	366(ra) # 80004066 <exec>
    80004f00:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f02:	f4040993          	addi	s3,s0,-192
    80004f06:	6088                	ld	a0,0(s1)
    80004f08:	c901                	beqz	a0,80004f18 <sys_exec+0xf6>
    kfree(argv[i]);
    80004f0a:	ffffb097          	auipc	ra,0xffffb
    80004f0e:	112080e7          	jalr	274(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004f12:	04a1                	addi	s1,s1,8
    80004f14:	ff3499e3          	bne	s1,s3,80004f06 <sys_exec+0xe4>
  return ret;
    80004f18:	854a                	mv	a0,s2
    80004f1a:	a011                	j	80004f1e <sys_exec+0xfc>
  return -1;
    80004f1c:	557d                	li	a0,-1
}
    80004f1e:	60be                	ld	ra,456(sp)
    80004f20:	641e                	ld	s0,448(sp)
    80004f22:	74fa                	ld	s1,440(sp)
    80004f24:	795a                	ld	s2,432(sp)
    80004f26:	79ba                	ld	s3,424(sp)
    80004f28:	7a1a                	ld	s4,416(sp)
    80004f2a:	6afa                	ld	s5,408(sp)
    80004f2c:	6179                	addi	sp,sp,464
    80004f2e:	8082                	ret

0000000080004f30 <sys_pipe>:

uint64
sys_pipe(void)
{
    80004f30:	7139                	addi	sp,sp,-64
    80004f32:	fc06                	sd	ra,56(sp)
    80004f34:	f822                	sd	s0,48(sp)
    80004f36:	f426                	sd	s1,40(sp)
    80004f38:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80004f3a:	ffffc097          	auipc	ra,0xffffc
    80004f3e:	f1a080e7          	jalr	-230(ra) # 80000e54 <myproc>
    80004f42:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80004f44:	fd840593          	addi	a1,s0,-40
    80004f48:	4501                	li	a0,0
    80004f4a:	ffffd097          	auipc	ra,0xffffd
    80004f4e:	07c080e7          	jalr	124(ra) # 80001fc6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80004f52:	fc840593          	addi	a1,s0,-56
    80004f56:	fd040513          	addi	a0,s0,-48
    80004f5a:	fffff097          	auipc	ra,0xfffff
    80004f5e:	dc2080e7          	jalr	-574(ra) # 80003d1c <pipealloc>
    return -1;
    80004f62:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80004f64:	0c054463          	bltz	a0,8000502c <sys_pipe+0xfc>
  fd0 = -1;
    80004f68:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80004f6c:	fd043503          	ld	a0,-48(s0)
    80004f70:	fffff097          	auipc	ra,0xfffff
    80004f74:	514080e7          	jalr	1300(ra) # 80004484 <fdalloc>
    80004f78:	fca42223          	sw	a0,-60(s0)
    80004f7c:	08054b63          	bltz	a0,80005012 <sys_pipe+0xe2>
    80004f80:	fc843503          	ld	a0,-56(s0)
    80004f84:	fffff097          	auipc	ra,0xfffff
    80004f88:	500080e7          	jalr	1280(ra) # 80004484 <fdalloc>
    80004f8c:	fca42023          	sw	a0,-64(s0)
    80004f90:	06054863          	bltz	a0,80005000 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004f94:	4691                	li	a3,4
    80004f96:	fc440613          	addi	a2,s0,-60
    80004f9a:	fd843583          	ld	a1,-40(s0)
    80004f9e:	68a8                	ld	a0,80(s1)
    80004fa0:	ffffc097          	auipc	ra,0xffffc
    80004fa4:	b74080e7          	jalr	-1164(ra) # 80000b14 <copyout>
    80004fa8:	02054063          	bltz	a0,80004fc8 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80004fac:	4691                	li	a3,4
    80004fae:	fc040613          	addi	a2,s0,-64
    80004fb2:	fd843583          	ld	a1,-40(s0)
    80004fb6:	0591                	addi	a1,a1,4
    80004fb8:	68a8                	ld	a0,80(s1)
    80004fba:	ffffc097          	auipc	ra,0xffffc
    80004fbe:	b5a080e7          	jalr	-1190(ra) # 80000b14 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80004fc2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80004fc4:	06055463          	bgez	a0,8000502c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80004fc8:	fc442783          	lw	a5,-60(s0)
    80004fcc:	07e9                	addi	a5,a5,26
    80004fce:	078e                	slli	a5,a5,0x3
    80004fd0:	97a6                	add	a5,a5,s1
    80004fd2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80004fd6:	fc042783          	lw	a5,-64(s0)
    80004fda:	07e9                	addi	a5,a5,26
    80004fdc:	078e                	slli	a5,a5,0x3
    80004fde:	94be                	add	s1,s1,a5
    80004fe0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80004fe4:	fd043503          	ld	a0,-48(s0)
    80004fe8:	fffff097          	auipc	ra,0xfffff
    80004fec:	a04080e7          	jalr	-1532(ra) # 800039ec <fileclose>
    fileclose(wf);
    80004ff0:	fc843503          	ld	a0,-56(s0)
    80004ff4:	fffff097          	auipc	ra,0xfffff
    80004ff8:	9f8080e7          	jalr	-1544(ra) # 800039ec <fileclose>
    return -1;
    80004ffc:	57fd                	li	a5,-1
    80004ffe:	a03d                	j	8000502c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005000:	fc442783          	lw	a5,-60(s0)
    80005004:	0007c763          	bltz	a5,80005012 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005008:	07e9                	addi	a5,a5,26
    8000500a:	078e                	slli	a5,a5,0x3
    8000500c:	97a6                	add	a5,a5,s1
    8000500e:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005012:	fd043503          	ld	a0,-48(s0)
    80005016:	fffff097          	auipc	ra,0xfffff
    8000501a:	9d6080e7          	jalr	-1578(ra) # 800039ec <fileclose>
    fileclose(wf);
    8000501e:	fc843503          	ld	a0,-56(s0)
    80005022:	fffff097          	auipc	ra,0xfffff
    80005026:	9ca080e7          	jalr	-1590(ra) # 800039ec <fileclose>
    return -1;
    8000502a:	57fd                	li	a5,-1
}
    8000502c:	853e                	mv	a0,a5
    8000502e:	70e2                	ld	ra,56(sp)
    80005030:	7442                	ld	s0,48(sp)
    80005032:	74a2                	ld	s1,40(sp)
    80005034:	6121                	addi	sp,sp,64
    80005036:	8082                	ret
	...

0000000080005040 <kernelvec>:
    80005040:	7111                	addi	sp,sp,-256
    80005042:	e006                	sd	ra,0(sp)
    80005044:	e40a                	sd	sp,8(sp)
    80005046:	e80e                	sd	gp,16(sp)
    80005048:	ec12                	sd	tp,24(sp)
    8000504a:	f016                	sd	t0,32(sp)
    8000504c:	f41a                	sd	t1,40(sp)
    8000504e:	f81e                	sd	t2,48(sp)
    80005050:	fc22                	sd	s0,56(sp)
    80005052:	e0a6                	sd	s1,64(sp)
    80005054:	e4aa                	sd	a0,72(sp)
    80005056:	e8ae                	sd	a1,80(sp)
    80005058:	ecb2                	sd	a2,88(sp)
    8000505a:	f0b6                	sd	a3,96(sp)
    8000505c:	f4ba                	sd	a4,104(sp)
    8000505e:	f8be                	sd	a5,112(sp)
    80005060:	fcc2                	sd	a6,120(sp)
    80005062:	e146                	sd	a7,128(sp)
    80005064:	e54a                	sd	s2,136(sp)
    80005066:	e94e                	sd	s3,144(sp)
    80005068:	ed52                	sd	s4,152(sp)
    8000506a:	f156                	sd	s5,160(sp)
    8000506c:	f55a                	sd	s6,168(sp)
    8000506e:	f95e                	sd	s7,176(sp)
    80005070:	fd62                	sd	s8,184(sp)
    80005072:	e1e6                	sd	s9,192(sp)
    80005074:	e5ea                	sd	s10,200(sp)
    80005076:	e9ee                	sd	s11,208(sp)
    80005078:	edf2                	sd	t3,216(sp)
    8000507a:	f1f6                	sd	t4,224(sp)
    8000507c:	f5fa                	sd	t5,232(sp)
    8000507e:	f9fe                	sd	t6,240(sp)
    80005080:	d55fc0ef          	jal	ra,80001dd4 <kerneltrap>
    80005084:	6082                	ld	ra,0(sp)
    80005086:	6122                	ld	sp,8(sp)
    80005088:	61c2                	ld	gp,16(sp)
    8000508a:	7282                	ld	t0,32(sp)
    8000508c:	7322                	ld	t1,40(sp)
    8000508e:	73c2                	ld	t2,48(sp)
    80005090:	7462                	ld	s0,56(sp)
    80005092:	6486                	ld	s1,64(sp)
    80005094:	6526                	ld	a0,72(sp)
    80005096:	65c6                	ld	a1,80(sp)
    80005098:	6666                	ld	a2,88(sp)
    8000509a:	7686                	ld	a3,96(sp)
    8000509c:	7726                	ld	a4,104(sp)
    8000509e:	77c6                	ld	a5,112(sp)
    800050a0:	7866                	ld	a6,120(sp)
    800050a2:	688a                	ld	a7,128(sp)
    800050a4:	692a                	ld	s2,136(sp)
    800050a6:	69ca                	ld	s3,144(sp)
    800050a8:	6a6a                	ld	s4,152(sp)
    800050aa:	7a8a                	ld	s5,160(sp)
    800050ac:	7b2a                	ld	s6,168(sp)
    800050ae:	7bca                	ld	s7,176(sp)
    800050b0:	7c6a                	ld	s8,184(sp)
    800050b2:	6c8e                	ld	s9,192(sp)
    800050b4:	6d2e                	ld	s10,200(sp)
    800050b6:	6dce                	ld	s11,208(sp)
    800050b8:	6e6e                	ld	t3,216(sp)
    800050ba:	7e8e                	ld	t4,224(sp)
    800050bc:	7f2e                	ld	t5,232(sp)
    800050be:	7fce                	ld	t6,240(sp)
    800050c0:	6111                	addi	sp,sp,256
    800050c2:	10200073          	sret
    800050c6:	00000013          	nop
    800050ca:	00000013          	nop
    800050ce:	0001                	nop

00000000800050d0 <timervec>:
    800050d0:	34051573          	csrrw	a0,mscratch,a0
    800050d4:	e10c                	sd	a1,0(a0)
    800050d6:	e510                	sd	a2,8(a0)
    800050d8:	e914                	sd	a3,16(a0)
    800050da:	6d0c                	ld	a1,24(a0)
    800050dc:	7110                	ld	a2,32(a0)
    800050de:	6194                	ld	a3,0(a1)
    800050e0:	96b2                	add	a3,a3,a2
    800050e2:	e194                	sd	a3,0(a1)
    800050e4:	4589                	li	a1,2
    800050e6:	14459073          	csrw	sip,a1
    800050ea:	6914                	ld	a3,16(a0)
    800050ec:	6510                	ld	a2,8(a0)
    800050ee:	610c                	ld	a1,0(a0)
    800050f0:	34051573          	csrrw	a0,mscratch,a0
    800050f4:	30200073          	mret
	...

00000000800050fa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800050fa:	1141                	addi	sp,sp,-16
    800050fc:	e422                	sd	s0,8(sp)
    800050fe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005100:	0c0007b7          	lui	a5,0xc000
    80005104:	4705                	li	a4,1
    80005106:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005108:	c3d8                	sw	a4,4(a5)
}
    8000510a:	6422                	ld	s0,8(sp)
    8000510c:	0141                	addi	sp,sp,16
    8000510e:	8082                	ret

0000000080005110 <plicinithart>:

void
plicinithart(void)
{
    80005110:	1141                	addi	sp,sp,-16
    80005112:	e406                	sd	ra,8(sp)
    80005114:	e022                	sd	s0,0(sp)
    80005116:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005118:	ffffc097          	auipc	ra,0xffffc
    8000511c:	d10080e7          	jalr	-752(ra) # 80000e28 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005120:	0085171b          	slliw	a4,a0,0x8
    80005124:	0c0027b7          	lui	a5,0xc002
    80005128:	97ba                	add	a5,a5,a4
    8000512a:	40200713          	li	a4,1026
    8000512e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005132:	00d5151b          	slliw	a0,a0,0xd
    80005136:	0c2017b7          	lui	a5,0xc201
    8000513a:	97aa                	add	a5,a5,a0
    8000513c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005140:	60a2                	ld	ra,8(sp)
    80005142:	6402                	ld	s0,0(sp)
    80005144:	0141                	addi	sp,sp,16
    80005146:	8082                	ret

0000000080005148 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005148:	1141                	addi	sp,sp,-16
    8000514a:	e406                	sd	ra,8(sp)
    8000514c:	e022                	sd	s0,0(sp)
    8000514e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005150:	ffffc097          	auipc	ra,0xffffc
    80005154:	cd8080e7          	jalr	-808(ra) # 80000e28 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005158:	00d5151b          	slliw	a0,a0,0xd
    8000515c:	0c2017b7          	lui	a5,0xc201
    80005160:	97aa                	add	a5,a5,a0
  return irq;
}
    80005162:	43c8                	lw	a0,4(a5)
    80005164:	60a2                	ld	ra,8(sp)
    80005166:	6402                	ld	s0,0(sp)
    80005168:	0141                	addi	sp,sp,16
    8000516a:	8082                	ret

000000008000516c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000516c:	1101                	addi	sp,sp,-32
    8000516e:	ec06                	sd	ra,24(sp)
    80005170:	e822                	sd	s0,16(sp)
    80005172:	e426                	sd	s1,8(sp)
    80005174:	1000                	addi	s0,sp,32
    80005176:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005178:	ffffc097          	auipc	ra,0xffffc
    8000517c:	cb0080e7          	jalr	-848(ra) # 80000e28 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005180:	00d5151b          	slliw	a0,a0,0xd
    80005184:	0c2017b7          	lui	a5,0xc201
    80005188:	97aa                	add	a5,a5,a0
    8000518a:	c3c4                	sw	s1,4(a5)
}
    8000518c:	60e2                	ld	ra,24(sp)
    8000518e:	6442                	ld	s0,16(sp)
    80005190:	64a2                	ld	s1,8(sp)
    80005192:	6105                	addi	sp,sp,32
    80005194:	8082                	ret

0000000080005196 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005196:	1141                	addi	sp,sp,-16
    80005198:	e406                	sd	ra,8(sp)
    8000519a:	e022                	sd	s0,0(sp)
    8000519c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000519e:	479d                	li	a5,7
    800051a0:	04a7cc63          	blt	a5,a0,800051f8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800051a4:	00015797          	auipc	a5,0x15
    800051a8:	c2c78793          	addi	a5,a5,-980 # 80019dd0 <disk>
    800051ac:	97aa                	add	a5,a5,a0
    800051ae:	0187c783          	lbu	a5,24(a5)
    800051b2:	ebb9                	bnez	a5,80005208 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800051b4:	00451693          	slli	a3,a0,0x4
    800051b8:	00015797          	auipc	a5,0x15
    800051bc:	c1878793          	addi	a5,a5,-1000 # 80019dd0 <disk>
    800051c0:	6398                	ld	a4,0(a5)
    800051c2:	9736                	add	a4,a4,a3
    800051c4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800051c8:	6398                	ld	a4,0(a5)
    800051ca:	9736                	add	a4,a4,a3
    800051cc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800051d0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800051d4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800051d8:	97aa                	add	a5,a5,a0
    800051da:	4705                	li	a4,1
    800051dc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800051e0:	00015517          	auipc	a0,0x15
    800051e4:	c0850513          	addi	a0,a0,-1016 # 80019de8 <disk+0x18>
    800051e8:	ffffc097          	auipc	ra,0xffffc
    800051ec:	384080e7          	jalr	900(ra) # 8000156c <wakeup>
}
    800051f0:	60a2                	ld	ra,8(sp)
    800051f2:	6402                	ld	s0,0(sp)
    800051f4:	0141                	addi	sp,sp,16
    800051f6:	8082                	ret
    panic("free_desc 1");
    800051f8:	00003517          	auipc	a0,0x3
    800051fc:	4c850513          	addi	a0,a0,1224 # 800086c0 <syscalls+0x2f0>
    80005200:	00001097          	auipc	ra,0x1
    80005204:	a0c080e7          	jalr	-1524(ra) # 80005c0c <panic>
    panic("free_desc 2");
    80005208:	00003517          	auipc	a0,0x3
    8000520c:	4c850513          	addi	a0,a0,1224 # 800086d0 <syscalls+0x300>
    80005210:	00001097          	auipc	ra,0x1
    80005214:	9fc080e7          	jalr	-1540(ra) # 80005c0c <panic>

0000000080005218 <virtio_disk_init>:
{
    80005218:	1101                	addi	sp,sp,-32
    8000521a:	ec06                	sd	ra,24(sp)
    8000521c:	e822                	sd	s0,16(sp)
    8000521e:	e426                	sd	s1,8(sp)
    80005220:	e04a                	sd	s2,0(sp)
    80005222:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005224:	00003597          	auipc	a1,0x3
    80005228:	4bc58593          	addi	a1,a1,1212 # 800086e0 <syscalls+0x310>
    8000522c:	00015517          	auipc	a0,0x15
    80005230:	ccc50513          	addi	a0,a0,-820 # 80019ef8 <disk+0x128>
    80005234:	00001097          	auipc	ra,0x1
    80005238:	e80080e7          	jalr	-384(ra) # 800060b4 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000523c:	100017b7          	lui	a5,0x10001
    80005240:	4398                	lw	a4,0(a5)
    80005242:	2701                	sext.w	a4,a4
    80005244:	747277b7          	lui	a5,0x74727
    80005248:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000524c:	14f71b63          	bne	a4,a5,800053a2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005250:	100017b7          	lui	a5,0x10001
    80005254:	43dc                	lw	a5,4(a5)
    80005256:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005258:	4709                	li	a4,2
    8000525a:	14e79463          	bne	a5,a4,800053a2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000525e:	100017b7          	lui	a5,0x10001
    80005262:	479c                	lw	a5,8(a5)
    80005264:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005266:	12e79e63          	bne	a5,a4,800053a2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000526a:	100017b7          	lui	a5,0x10001
    8000526e:	47d8                	lw	a4,12(a5)
    80005270:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005272:	554d47b7          	lui	a5,0x554d4
    80005276:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000527a:	12f71463          	bne	a4,a5,800053a2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000527e:	100017b7          	lui	a5,0x10001
    80005282:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005286:	4705                	li	a4,1
    80005288:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000528a:	470d                	li	a4,3
    8000528c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000528e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005290:	c7ffe6b7          	lui	a3,0xc7ffe
    80005294:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc60f>
    80005298:	8f75                	and	a4,a4,a3
    8000529a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000529c:	472d                	li	a4,11
    8000529e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800052a0:	5bbc                	lw	a5,112(a5)
    800052a2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800052a6:	8ba1                	andi	a5,a5,8
    800052a8:	10078563          	beqz	a5,800053b2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800052ac:	100017b7          	lui	a5,0x10001
    800052b0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800052b4:	43fc                	lw	a5,68(a5)
    800052b6:	2781                	sext.w	a5,a5
    800052b8:	10079563          	bnez	a5,800053c2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800052bc:	100017b7          	lui	a5,0x10001
    800052c0:	5bdc                	lw	a5,52(a5)
    800052c2:	2781                	sext.w	a5,a5
  if(max == 0)
    800052c4:	10078763          	beqz	a5,800053d2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800052c8:	471d                	li	a4,7
    800052ca:	10f77c63          	bgeu	a4,a5,800053e2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800052ce:	ffffb097          	auipc	ra,0xffffb
    800052d2:	e4c080e7          	jalr	-436(ra) # 8000011a <kalloc>
    800052d6:	00015497          	auipc	s1,0x15
    800052da:	afa48493          	addi	s1,s1,-1286 # 80019dd0 <disk>
    800052de:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800052e0:	ffffb097          	auipc	ra,0xffffb
    800052e4:	e3a080e7          	jalr	-454(ra) # 8000011a <kalloc>
    800052e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800052ea:	ffffb097          	auipc	ra,0xffffb
    800052ee:	e30080e7          	jalr	-464(ra) # 8000011a <kalloc>
    800052f2:	87aa                	mv	a5,a0
    800052f4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800052f6:	6088                	ld	a0,0(s1)
    800052f8:	cd6d                	beqz	a0,800053f2 <virtio_disk_init+0x1da>
    800052fa:	00015717          	auipc	a4,0x15
    800052fe:	ade73703          	ld	a4,-1314(a4) # 80019dd8 <disk+0x8>
    80005302:	cb65                	beqz	a4,800053f2 <virtio_disk_init+0x1da>
    80005304:	c7fd                	beqz	a5,800053f2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005306:	6605                	lui	a2,0x1
    80005308:	4581                	li	a1,0
    8000530a:	ffffb097          	auipc	ra,0xffffb
    8000530e:	e70080e7          	jalr	-400(ra) # 8000017a <memset>
  memset(disk.avail, 0, PGSIZE);
    80005312:	00015497          	auipc	s1,0x15
    80005316:	abe48493          	addi	s1,s1,-1346 # 80019dd0 <disk>
    8000531a:	6605                	lui	a2,0x1
    8000531c:	4581                	li	a1,0
    8000531e:	6488                	ld	a0,8(s1)
    80005320:	ffffb097          	auipc	ra,0xffffb
    80005324:	e5a080e7          	jalr	-422(ra) # 8000017a <memset>
  memset(disk.used, 0, PGSIZE);
    80005328:	6605                	lui	a2,0x1
    8000532a:	4581                	li	a1,0
    8000532c:	6888                	ld	a0,16(s1)
    8000532e:	ffffb097          	auipc	ra,0xffffb
    80005332:	e4c080e7          	jalr	-436(ra) # 8000017a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005336:	100017b7          	lui	a5,0x10001
    8000533a:	4721                	li	a4,8
    8000533c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000533e:	4098                	lw	a4,0(s1)
    80005340:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005344:	40d8                	lw	a4,4(s1)
    80005346:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000534a:	6498                	ld	a4,8(s1)
    8000534c:	0007069b          	sext.w	a3,a4
    80005350:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005354:	9701                	srai	a4,a4,0x20
    80005356:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000535a:	6898                	ld	a4,16(s1)
    8000535c:	0007069b          	sext.w	a3,a4
    80005360:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005364:	9701                	srai	a4,a4,0x20
    80005366:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000536a:	4705                	li	a4,1
    8000536c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000536e:	00e48c23          	sb	a4,24(s1)
    80005372:	00e48ca3          	sb	a4,25(s1)
    80005376:	00e48d23          	sb	a4,26(s1)
    8000537a:	00e48da3          	sb	a4,27(s1)
    8000537e:	00e48e23          	sb	a4,28(s1)
    80005382:	00e48ea3          	sb	a4,29(s1)
    80005386:	00e48f23          	sb	a4,30(s1)
    8000538a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000538e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005392:	0727a823          	sw	s2,112(a5)
}
    80005396:	60e2                	ld	ra,24(sp)
    80005398:	6442                	ld	s0,16(sp)
    8000539a:	64a2                	ld	s1,8(sp)
    8000539c:	6902                	ld	s2,0(sp)
    8000539e:	6105                	addi	sp,sp,32
    800053a0:	8082                	ret
    panic("could not find virtio disk");
    800053a2:	00003517          	auipc	a0,0x3
    800053a6:	34e50513          	addi	a0,a0,846 # 800086f0 <syscalls+0x320>
    800053aa:	00001097          	auipc	ra,0x1
    800053ae:	862080e7          	jalr	-1950(ra) # 80005c0c <panic>
    panic("virtio disk FEATURES_OK unset");
    800053b2:	00003517          	auipc	a0,0x3
    800053b6:	35e50513          	addi	a0,a0,862 # 80008710 <syscalls+0x340>
    800053ba:	00001097          	auipc	ra,0x1
    800053be:	852080e7          	jalr	-1966(ra) # 80005c0c <panic>
    panic("virtio disk should not be ready");
    800053c2:	00003517          	auipc	a0,0x3
    800053c6:	36e50513          	addi	a0,a0,878 # 80008730 <syscalls+0x360>
    800053ca:	00001097          	auipc	ra,0x1
    800053ce:	842080e7          	jalr	-1982(ra) # 80005c0c <panic>
    panic("virtio disk has no queue 0");
    800053d2:	00003517          	auipc	a0,0x3
    800053d6:	37e50513          	addi	a0,a0,894 # 80008750 <syscalls+0x380>
    800053da:	00001097          	auipc	ra,0x1
    800053de:	832080e7          	jalr	-1998(ra) # 80005c0c <panic>
    panic("virtio disk max queue too short");
    800053e2:	00003517          	auipc	a0,0x3
    800053e6:	38e50513          	addi	a0,a0,910 # 80008770 <syscalls+0x3a0>
    800053ea:	00001097          	auipc	ra,0x1
    800053ee:	822080e7          	jalr	-2014(ra) # 80005c0c <panic>
    panic("virtio disk kalloc");
    800053f2:	00003517          	auipc	a0,0x3
    800053f6:	39e50513          	addi	a0,a0,926 # 80008790 <syscalls+0x3c0>
    800053fa:	00001097          	auipc	ra,0x1
    800053fe:	812080e7          	jalr	-2030(ra) # 80005c0c <panic>

0000000080005402 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005402:	7119                	addi	sp,sp,-128
    80005404:	fc86                	sd	ra,120(sp)
    80005406:	f8a2                	sd	s0,112(sp)
    80005408:	f4a6                	sd	s1,104(sp)
    8000540a:	f0ca                	sd	s2,96(sp)
    8000540c:	ecce                	sd	s3,88(sp)
    8000540e:	e8d2                	sd	s4,80(sp)
    80005410:	e4d6                	sd	s5,72(sp)
    80005412:	e0da                	sd	s6,64(sp)
    80005414:	fc5e                	sd	s7,56(sp)
    80005416:	f862                	sd	s8,48(sp)
    80005418:	f466                	sd	s9,40(sp)
    8000541a:	f06a                	sd	s10,32(sp)
    8000541c:	ec6e                	sd	s11,24(sp)
    8000541e:	0100                	addi	s0,sp,128
    80005420:	8aaa                	mv	s5,a0
    80005422:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005424:	00c52d03          	lw	s10,12(a0)
    80005428:	001d1d1b          	slliw	s10,s10,0x1
    8000542c:	1d02                	slli	s10,s10,0x20
    8000542e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005432:	00015517          	auipc	a0,0x15
    80005436:	ac650513          	addi	a0,a0,-1338 # 80019ef8 <disk+0x128>
    8000543a:	00001097          	auipc	ra,0x1
    8000543e:	d0a080e7          	jalr	-758(ra) # 80006144 <acquire>
  for(int i = 0; i < 3; i++){
    80005442:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005444:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005446:	00015b97          	auipc	s7,0x15
    8000544a:	98ab8b93          	addi	s7,s7,-1654 # 80019dd0 <disk>
  for(int i = 0; i < 3; i++){
    8000544e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005450:	00015c97          	auipc	s9,0x15
    80005454:	aa8c8c93          	addi	s9,s9,-1368 # 80019ef8 <disk+0x128>
    80005458:	a08d                	j	800054ba <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000545a:	00fb8733          	add	a4,s7,a5
    8000545e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005462:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005464:	0207c563          	bltz	a5,8000548e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005468:	2905                	addiw	s2,s2,1
    8000546a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000546c:	05690c63          	beq	s2,s6,800054c4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005470:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005472:	00015717          	auipc	a4,0x15
    80005476:	95e70713          	addi	a4,a4,-1698 # 80019dd0 <disk>
    8000547a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000547c:	01874683          	lbu	a3,24(a4)
    80005480:	fee9                	bnez	a3,8000545a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005482:	2785                	addiw	a5,a5,1
    80005484:	0705                	addi	a4,a4,1
    80005486:	fe979be3          	bne	a5,s1,8000547c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000548a:	57fd                	li	a5,-1
    8000548c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000548e:	01205d63          	blez	s2,800054a8 <virtio_disk_rw+0xa6>
    80005492:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005494:	000a2503          	lw	a0,0(s4)
    80005498:	00000097          	auipc	ra,0x0
    8000549c:	cfe080e7          	jalr	-770(ra) # 80005196 <free_desc>
      for(int j = 0; j < i; j++)
    800054a0:	2d85                	addiw	s11,s11,1
    800054a2:	0a11                	addi	s4,s4,4
    800054a4:	ff2d98e3          	bne	s11,s2,80005494 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800054a8:	85e6                	mv	a1,s9
    800054aa:	00015517          	auipc	a0,0x15
    800054ae:	93e50513          	addi	a0,a0,-1730 # 80019de8 <disk+0x18>
    800054b2:	ffffc097          	auipc	ra,0xffffc
    800054b6:	056080e7          	jalr	86(ra) # 80001508 <sleep>
  for(int i = 0; i < 3; i++){
    800054ba:	f8040a13          	addi	s4,s0,-128
{
    800054be:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800054c0:	894e                	mv	s2,s3
    800054c2:	b77d                	j	80005470 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800054c4:	f8042503          	lw	a0,-128(s0)
    800054c8:	00a50713          	addi	a4,a0,10
    800054cc:	0712                	slli	a4,a4,0x4

  if(write)
    800054ce:	00015797          	auipc	a5,0x15
    800054d2:	90278793          	addi	a5,a5,-1790 # 80019dd0 <disk>
    800054d6:	00e786b3          	add	a3,a5,a4
    800054da:	01803633          	snez	a2,s8
    800054de:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800054e0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800054e4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800054e8:	f6070613          	addi	a2,a4,-160
    800054ec:	6394                	ld	a3,0(a5)
    800054ee:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800054f0:	00870593          	addi	a1,a4,8
    800054f4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800054f6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800054f8:	0007b803          	ld	a6,0(a5)
    800054fc:	9642                	add	a2,a2,a6
    800054fe:	46c1                	li	a3,16
    80005500:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005502:	4585                	li	a1,1
    80005504:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005508:	f8442683          	lw	a3,-124(s0)
    8000550c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005510:	0692                	slli	a3,a3,0x4
    80005512:	9836                	add	a6,a6,a3
    80005514:	058a8613          	addi	a2,s5,88
    80005518:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000551c:	0007b803          	ld	a6,0(a5)
    80005520:	96c2                	add	a3,a3,a6
    80005522:	40000613          	li	a2,1024
    80005526:	c690                	sw	a2,8(a3)
  if(write)
    80005528:	001c3613          	seqz	a2,s8
    8000552c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005530:	00166613          	ori	a2,a2,1
    80005534:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005538:	f8842603          	lw	a2,-120(s0)
    8000553c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005540:	00250693          	addi	a3,a0,2
    80005544:	0692                	slli	a3,a3,0x4
    80005546:	96be                	add	a3,a3,a5
    80005548:	58fd                	li	a7,-1
    8000554a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000554e:	0612                	slli	a2,a2,0x4
    80005550:	9832                	add	a6,a6,a2
    80005552:	f9070713          	addi	a4,a4,-112
    80005556:	973e                	add	a4,a4,a5
    80005558:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000555c:	6398                	ld	a4,0(a5)
    8000555e:	9732                	add	a4,a4,a2
    80005560:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005562:	4609                	li	a2,2
    80005564:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005568:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000556c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005570:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005574:	6794                	ld	a3,8(a5)
    80005576:	0026d703          	lhu	a4,2(a3)
    8000557a:	8b1d                	andi	a4,a4,7
    8000557c:	0706                	slli	a4,a4,0x1
    8000557e:	96ba                	add	a3,a3,a4
    80005580:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005584:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005588:	6798                	ld	a4,8(a5)
    8000558a:	00275783          	lhu	a5,2(a4)
    8000558e:	2785                	addiw	a5,a5,1
    80005590:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005594:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005598:	100017b7          	lui	a5,0x10001
    8000559c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800055a0:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800055a4:	00015917          	auipc	s2,0x15
    800055a8:	95490913          	addi	s2,s2,-1708 # 80019ef8 <disk+0x128>
  while(b->disk == 1) {
    800055ac:	4485                	li	s1,1
    800055ae:	00b79c63          	bne	a5,a1,800055c6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800055b2:	85ca                	mv	a1,s2
    800055b4:	8556                	mv	a0,s5
    800055b6:	ffffc097          	auipc	ra,0xffffc
    800055ba:	f52080e7          	jalr	-174(ra) # 80001508 <sleep>
  while(b->disk == 1) {
    800055be:	004aa783          	lw	a5,4(s5)
    800055c2:	fe9788e3          	beq	a5,s1,800055b2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800055c6:	f8042903          	lw	s2,-128(s0)
    800055ca:	00290713          	addi	a4,s2,2
    800055ce:	0712                	slli	a4,a4,0x4
    800055d0:	00015797          	auipc	a5,0x15
    800055d4:	80078793          	addi	a5,a5,-2048 # 80019dd0 <disk>
    800055d8:	97ba                	add	a5,a5,a4
    800055da:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800055de:	00014997          	auipc	s3,0x14
    800055e2:	7f298993          	addi	s3,s3,2034 # 80019dd0 <disk>
    800055e6:	00491713          	slli	a4,s2,0x4
    800055ea:	0009b783          	ld	a5,0(s3)
    800055ee:	97ba                	add	a5,a5,a4
    800055f0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800055f4:	854a                	mv	a0,s2
    800055f6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800055fa:	00000097          	auipc	ra,0x0
    800055fe:	b9c080e7          	jalr	-1124(ra) # 80005196 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005602:	8885                	andi	s1,s1,1
    80005604:	f0ed                	bnez	s1,800055e6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005606:	00015517          	auipc	a0,0x15
    8000560a:	8f250513          	addi	a0,a0,-1806 # 80019ef8 <disk+0x128>
    8000560e:	00001097          	auipc	ra,0x1
    80005612:	bea080e7          	jalr	-1046(ra) # 800061f8 <release>
}
    80005616:	70e6                	ld	ra,120(sp)
    80005618:	7446                	ld	s0,112(sp)
    8000561a:	74a6                	ld	s1,104(sp)
    8000561c:	7906                	ld	s2,96(sp)
    8000561e:	69e6                	ld	s3,88(sp)
    80005620:	6a46                	ld	s4,80(sp)
    80005622:	6aa6                	ld	s5,72(sp)
    80005624:	6b06                	ld	s6,64(sp)
    80005626:	7be2                	ld	s7,56(sp)
    80005628:	7c42                	ld	s8,48(sp)
    8000562a:	7ca2                	ld	s9,40(sp)
    8000562c:	7d02                	ld	s10,32(sp)
    8000562e:	6de2                	ld	s11,24(sp)
    80005630:	6109                	addi	sp,sp,128
    80005632:	8082                	ret

0000000080005634 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005634:	1101                	addi	sp,sp,-32
    80005636:	ec06                	sd	ra,24(sp)
    80005638:	e822                	sd	s0,16(sp)
    8000563a:	e426                	sd	s1,8(sp)
    8000563c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000563e:	00014497          	auipc	s1,0x14
    80005642:	79248493          	addi	s1,s1,1938 # 80019dd0 <disk>
    80005646:	00015517          	auipc	a0,0x15
    8000564a:	8b250513          	addi	a0,a0,-1870 # 80019ef8 <disk+0x128>
    8000564e:	00001097          	auipc	ra,0x1
    80005652:	af6080e7          	jalr	-1290(ra) # 80006144 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005656:	10001737          	lui	a4,0x10001
    8000565a:	533c                	lw	a5,96(a4)
    8000565c:	8b8d                	andi	a5,a5,3
    8000565e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005660:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005664:	689c                	ld	a5,16(s1)
    80005666:	0204d703          	lhu	a4,32(s1)
    8000566a:	0027d783          	lhu	a5,2(a5)
    8000566e:	04f70863          	beq	a4,a5,800056be <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005672:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005676:	6898                	ld	a4,16(s1)
    80005678:	0204d783          	lhu	a5,32(s1)
    8000567c:	8b9d                	andi	a5,a5,7
    8000567e:	078e                	slli	a5,a5,0x3
    80005680:	97ba                	add	a5,a5,a4
    80005682:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005684:	00278713          	addi	a4,a5,2
    80005688:	0712                	slli	a4,a4,0x4
    8000568a:	9726                	add	a4,a4,s1
    8000568c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005690:	e721                	bnez	a4,800056d8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005692:	0789                	addi	a5,a5,2
    80005694:	0792                	slli	a5,a5,0x4
    80005696:	97a6                	add	a5,a5,s1
    80005698:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000569a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000569e:	ffffc097          	auipc	ra,0xffffc
    800056a2:	ece080e7          	jalr	-306(ra) # 8000156c <wakeup>

    disk.used_idx += 1;
    800056a6:	0204d783          	lhu	a5,32(s1)
    800056aa:	2785                	addiw	a5,a5,1
    800056ac:	17c2                	slli	a5,a5,0x30
    800056ae:	93c1                	srli	a5,a5,0x30
    800056b0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800056b4:	6898                	ld	a4,16(s1)
    800056b6:	00275703          	lhu	a4,2(a4)
    800056ba:	faf71ce3          	bne	a4,a5,80005672 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800056be:	00015517          	auipc	a0,0x15
    800056c2:	83a50513          	addi	a0,a0,-1990 # 80019ef8 <disk+0x128>
    800056c6:	00001097          	auipc	ra,0x1
    800056ca:	b32080e7          	jalr	-1230(ra) # 800061f8 <release>
}
    800056ce:	60e2                	ld	ra,24(sp)
    800056d0:	6442                	ld	s0,16(sp)
    800056d2:	64a2                	ld	s1,8(sp)
    800056d4:	6105                	addi	sp,sp,32
    800056d6:	8082                	ret
      panic("virtio_disk_intr status");
    800056d8:	00003517          	auipc	a0,0x3
    800056dc:	0d050513          	addi	a0,a0,208 # 800087a8 <syscalls+0x3d8>
    800056e0:	00000097          	auipc	ra,0x0
    800056e4:	52c080e7          	jalr	1324(ra) # 80005c0c <panic>

00000000800056e8 <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    800056e8:	1141                	addi	sp,sp,-16
    800056ea:	e422                	sd	s0,8(sp)
    800056ec:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800056ee:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    800056f2:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    800056f6:	0037979b          	slliw	a5,a5,0x3
    800056fa:	02004737          	lui	a4,0x2004
    800056fe:	97ba                	add	a5,a5,a4
    80005700:	0200c737          	lui	a4,0x200c
    80005704:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80005708:	000f4637          	lui	a2,0xf4
    8000570c:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80005710:	9732                	add	a4,a4,a2
    80005712:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005714:	00259693          	slli	a3,a1,0x2
    80005718:	96ae                	add	a3,a3,a1
    8000571a:	068e                	slli	a3,a3,0x3
    8000571c:	00014717          	auipc	a4,0x14
    80005720:	7f470713          	addi	a4,a4,2036 # 80019f10 <timer_scratch>
    80005724:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80005726:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80005728:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000572a:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000572e:	00000797          	auipc	a5,0x0
    80005732:	9a278793          	addi	a5,a5,-1630 # 800050d0 <timervec>
    80005736:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000573a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000573e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005742:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005746:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000574a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000574e:	30479073          	csrw	mie,a5
}
    80005752:	6422                	ld	s0,8(sp)
    80005754:	0141                	addi	sp,sp,16
    80005756:	8082                	ret

0000000080005758 <start>:
{
    80005758:	1141                	addi	sp,sp,-16
    8000575a:	e406                	sd	ra,8(sp)
    8000575c:	e022                	sd	s0,0(sp)
    8000575e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005760:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005764:	7779                	lui	a4,0xffffe
    80005766:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc6af>
    8000576a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000576c:	6705                	lui	a4,0x1
    8000576e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005772:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005774:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80005778:	ffffb797          	auipc	a5,0xffffb
    8000577c:	ba878793          	addi	a5,a5,-1112 # 80000320 <main>
    80005780:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80005784:	4781                	li	a5,0
    80005786:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    8000578a:	67c1                	lui	a5,0x10
    8000578c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000578e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005792:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80005796:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000579a:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000579e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800057a2:	57fd                	li	a5,-1
    800057a4:	83a9                	srli	a5,a5,0xa
    800057a6:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800057aa:	47bd                	li	a5,15
    800057ac:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800057b0:	00000097          	auipc	ra,0x0
    800057b4:	f38080e7          	jalr	-200(ra) # 800056e8 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800057b8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800057bc:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    800057be:	823e                	mv	tp,a5
  asm volatile("mret");
    800057c0:	30200073          	mret
}
    800057c4:	60a2                	ld	ra,8(sp)
    800057c6:	6402                	ld	s0,0(sp)
    800057c8:	0141                	addi	sp,sp,16
    800057ca:	8082                	ret

00000000800057cc <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800057cc:	715d                	addi	sp,sp,-80
    800057ce:	e486                	sd	ra,72(sp)
    800057d0:	e0a2                	sd	s0,64(sp)
    800057d2:	fc26                	sd	s1,56(sp)
    800057d4:	f84a                	sd	s2,48(sp)
    800057d6:	f44e                	sd	s3,40(sp)
    800057d8:	f052                	sd	s4,32(sp)
    800057da:	ec56                	sd	s5,24(sp)
    800057dc:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800057de:	04c05763          	blez	a2,8000582c <consolewrite+0x60>
    800057e2:	8a2a                	mv	s4,a0
    800057e4:	84ae                	mv	s1,a1
    800057e6:	89b2                	mv	s3,a2
    800057e8:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800057ea:	5afd                	li	s5,-1
    800057ec:	4685                	li	a3,1
    800057ee:	8626                	mv	a2,s1
    800057f0:	85d2                	mv	a1,s4
    800057f2:	fbf40513          	addi	a0,s0,-65
    800057f6:	ffffc097          	auipc	ra,0xffffc
    800057fa:	170080e7          	jalr	368(ra) # 80001966 <either_copyin>
    800057fe:	01550d63          	beq	a0,s5,80005818 <consolewrite+0x4c>
      break;
    uartputc(c);
    80005802:	fbf44503          	lbu	a0,-65(s0)
    80005806:	00000097          	auipc	ra,0x0
    8000580a:	784080e7          	jalr	1924(ra) # 80005f8a <uartputc>
  for(i = 0; i < n; i++){
    8000580e:	2905                	addiw	s2,s2,1
    80005810:	0485                	addi	s1,s1,1
    80005812:	fd299de3          	bne	s3,s2,800057ec <consolewrite+0x20>
    80005816:	894e                	mv	s2,s3
  }

  return i;
}
    80005818:	854a                	mv	a0,s2
    8000581a:	60a6                	ld	ra,72(sp)
    8000581c:	6406                	ld	s0,64(sp)
    8000581e:	74e2                	ld	s1,56(sp)
    80005820:	7942                	ld	s2,48(sp)
    80005822:	79a2                	ld	s3,40(sp)
    80005824:	7a02                	ld	s4,32(sp)
    80005826:	6ae2                	ld	s5,24(sp)
    80005828:	6161                	addi	sp,sp,80
    8000582a:	8082                	ret
  for(i = 0; i < n; i++){
    8000582c:	4901                	li	s2,0
    8000582e:	b7ed                	j	80005818 <consolewrite+0x4c>

0000000080005830 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005830:	7159                	addi	sp,sp,-112
    80005832:	f486                	sd	ra,104(sp)
    80005834:	f0a2                	sd	s0,96(sp)
    80005836:	eca6                	sd	s1,88(sp)
    80005838:	e8ca                	sd	s2,80(sp)
    8000583a:	e4ce                	sd	s3,72(sp)
    8000583c:	e0d2                	sd	s4,64(sp)
    8000583e:	fc56                	sd	s5,56(sp)
    80005840:	f85a                	sd	s6,48(sp)
    80005842:	f45e                	sd	s7,40(sp)
    80005844:	f062                	sd	s8,32(sp)
    80005846:	ec66                	sd	s9,24(sp)
    80005848:	e86a                	sd	s10,16(sp)
    8000584a:	1880                	addi	s0,sp,112
    8000584c:	8aaa                	mv	s5,a0
    8000584e:	8a2e                	mv	s4,a1
    80005850:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005852:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80005856:	0001c517          	auipc	a0,0x1c
    8000585a:	7fa50513          	addi	a0,a0,2042 # 80022050 <cons>
    8000585e:	00001097          	auipc	ra,0x1
    80005862:	8e6080e7          	jalr	-1818(ra) # 80006144 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005866:	0001c497          	auipc	s1,0x1c
    8000586a:	7ea48493          	addi	s1,s1,2026 # 80022050 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000586e:	0001d917          	auipc	s2,0x1d
    80005872:	87a90913          	addi	s2,s2,-1926 # 800220e8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80005876:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005878:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000587a:	4ca9                	li	s9,10
  while(n > 0){
    8000587c:	07305b63          	blez	s3,800058f2 <consoleread+0xc2>
    while(cons.r == cons.w){
    80005880:	0984a783          	lw	a5,152(s1)
    80005884:	09c4a703          	lw	a4,156(s1)
    80005888:	02f71763          	bne	a4,a5,800058b6 <consoleread+0x86>
      if(killed(myproc())){
    8000588c:	ffffb097          	auipc	ra,0xffffb
    80005890:	5c8080e7          	jalr	1480(ra) # 80000e54 <myproc>
    80005894:	ffffc097          	auipc	ra,0xffffc
    80005898:	f1c080e7          	jalr	-228(ra) # 800017b0 <killed>
    8000589c:	e535                	bnez	a0,80005908 <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    8000589e:	85a6                	mv	a1,s1
    800058a0:	854a                	mv	a0,s2
    800058a2:	ffffc097          	auipc	ra,0xffffc
    800058a6:	c66080e7          	jalr	-922(ra) # 80001508 <sleep>
    while(cons.r == cons.w){
    800058aa:	0984a783          	lw	a5,152(s1)
    800058ae:	09c4a703          	lw	a4,156(s1)
    800058b2:	fcf70de3          	beq	a4,a5,8000588c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800058b6:	0017871b          	addiw	a4,a5,1
    800058ba:	08e4ac23          	sw	a4,152(s1)
    800058be:	07f7f713          	andi	a4,a5,127
    800058c2:	9726                	add	a4,a4,s1
    800058c4:	01874703          	lbu	a4,24(a4)
    800058c8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800058cc:	077d0563          	beq	s10,s7,80005936 <consoleread+0x106>
    cbuf = c;
    800058d0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800058d4:	4685                	li	a3,1
    800058d6:	f9f40613          	addi	a2,s0,-97
    800058da:	85d2                	mv	a1,s4
    800058dc:	8556                	mv	a0,s5
    800058de:	ffffc097          	auipc	ra,0xffffc
    800058e2:	032080e7          	jalr	50(ra) # 80001910 <either_copyout>
    800058e6:	01850663          	beq	a0,s8,800058f2 <consoleread+0xc2>
    dst++;
    800058ea:	0a05                	addi	s4,s4,1
    --n;
    800058ec:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800058ee:	f99d17e3          	bne	s10,s9,8000587c <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800058f2:	0001c517          	auipc	a0,0x1c
    800058f6:	75e50513          	addi	a0,a0,1886 # 80022050 <cons>
    800058fa:	00001097          	auipc	ra,0x1
    800058fe:	8fe080e7          	jalr	-1794(ra) # 800061f8 <release>

  return target - n;
    80005902:	413b053b          	subw	a0,s6,s3
    80005906:	a811                	j	8000591a <consoleread+0xea>
        release(&cons.lock);
    80005908:	0001c517          	auipc	a0,0x1c
    8000590c:	74850513          	addi	a0,a0,1864 # 80022050 <cons>
    80005910:	00001097          	auipc	ra,0x1
    80005914:	8e8080e7          	jalr	-1816(ra) # 800061f8 <release>
        return -1;
    80005918:	557d                	li	a0,-1
}
    8000591a:	70a6                	ld	ra,104(sp)
    8000591c:	7406                	ld	s0,96(sp)
    8000591e:	64e6                	ld	s1,88(sp)
    80005920:	6946                	ld	s2,80(sp)
    80005922:	69a6                	ld	s3,72(sp)
    80005924:	6a06                	ld	s4,64(sp)
    80005926:	7ae2                	ld	s5,56(sp)
    80005928:	7b42                	ld	s6,48(sp)
    8000592a:	7ba2                	ld	s7,40(sp)
    8000592c:	7c02                	ld	s8,32(sp)
    8000592e:	6ce2                	ld	s9,24(sp)
    80005930:	6d42                	ld	s10,16(sp)
    80005932:	6165                	addi	sp,sp,112
    80005934:	8082                	ret
      if(n < target){
    80005936:	0009871b          	sext.w	a4,s3
    8000593a:	fb677ce3          	bgeu	a4,s6,800058f2 <consoleread+0xc2>
        cons.r--;
    8000593e:	0001c717          	auipc	a4,0x1c
    80005942:	7af72523          	sw	a5,1962(a4) # 800220e8 <cons+0x98>
    80005946:	b775                	j	800058f2 <consoleread+0xc2>

0000000080005948 <consputc>:
{
    80005948:	1141                	addi	sp,sp,-16
    8000594a:	e406                	sd	ra,8(sp)
    8000594c:	e022                	sd	s0,0(sp)
    8000594e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005950:	10000793          	li	a5,256
    80005954:	00f50a63          	beq	a0,a5,80005968 <consputc+0x20>
    uartputc_sync(c);
    80005958:	00000097          	auipc	ra,0x0
    8000595c:	560080e7          	jalr	1376(ra) # 80005eb8 <uartputc_sync>
}
    80005960:	60a2                	ld	ra,8(sp)
    80005962:	6402                	ld	s0,0(sp)
    80005964:	0141                	addi	sp,sp,16
    80005966:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005968:	4521                	li	a0,8
    8000596a:	00000097          	auipc	ra,0x0
    8000596e:	54e080e7          	jalr	1358(ra) # 80005eb8 <uartputc_sync>
    80005972:	02000513          	li	a0,32
    80005976:	00000097          	auipc	ra,0x0
    8000597a:	542080e7          	jalr	1346(ra) # 80005eb8 <uartputc_sync>
    8000597e:	4521                	li	a0,8
    80005980:	00000097          	auipc	ra,0x0
    80005984:	538080e7          	jalr	1336(ra) # 80005eb8 <uartputc_sync>
    80005988:	bfe1                	j	80005960 <consputc+0x18>

000000008000598a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    8000598a:	1101                	addi	sp,sp,-32
    8000598c:	ec06                	sd	ra,24(sp)
    8000598e:	e822                	sd	s0,16(sp)
    80005990:	e426                	sd	s1,8(sp)
    80005992:	e04a                	sd	s2,0(sp)
    80005994:	1000                	addi	s0,sp,32
    80005996:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005998:	0001c517          	auipc	a0,0x1c
    8000599c:	6b850513          	addi	a0,a0,1720 # 80022050 <cons>
    800059a0:	00000097          	auipc	ra,0x0
    800059a4:	7a4080e7          	jalr	1956(ra) # 80006144 <acquire>

  switch(c){
    800059a8:	47d5                	li	a5,21
    800059aa:	0af48663          	beq	s1,a5,80005a56 <consoleintr+0xcc>
    800059ae:	0297ca63          	blt	a5,s1,800059e2 <consoleintr+0x58>
    800059b2:	47a1                	li	a5,8
    800059b4:	0ef48763          	beq	s1,a5,80005aa2 <consoleintr+0x118>
    800059b8:	47c1                	li	a5,16
    800059ba:	10f49a63          	bne	s1,a5,80005ace <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800059be:	ffffc097          	auipc	ra,0xffffc
    800059c2:	ffe080e7          	jalr	-2(ra) # 800019bc <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800059c6:	0001c517          	auipc	a0,0x1c
    800059ca:	68a50513          	addi	a0,a0,1674 # 80022050 <cons>
    800059ce:	00001097          	auipc	ra,0x1
    800059d2:	82a080e7          	jalr	-2006(ra) # 800061f8 <release>
}
    800059d6:	60e2                	ld	ra,24(sp)
    800059d8:	6442                	ld	s0,16(sp)
    800059da:	64a2                	ld	s1,8(sp)
    800059dc:	6902                	ld	s2,0(sp)
    800059de:	6105                	addi	sp,sp,32
    800059e0:	8082                	ret
  switch(c){
    800059e2:	07f00793          	li	a5,127
    800059e6:	0af48e63          	beq	s1,a5,80005aa2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800059ea:	0001c717          	auipc	a4,0x1c
    800059ee:	66670713          	addi	a4,a4,1638 # 80022050 <cons>
    800059f2:	0a072783          	lw	a5,160(a4)
    800059f6:	09872703          	lw	a4,152(a4)
    800059fa:	9f99                	subw	a5,a5,a4
    800059fc:	07f00713          	li	a4,127
    80005a00:	fcf763e3          	bltu	a4,a5,800059c6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005a04:	47b5                	li	a5,13
    80005a06:	0cf48763          	beq	s1,a5,80005ad4 <consoleintr+0x14a>
      consputc(c);
    80005a0a:	8526                	mv	a0,s1
    80005a0c:	00000097          	auipc	ra,0x0
    80005a10:	f3c080e7          	jalr	-196(ra) # 80005948 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005a14:	0001c797          	auipc	a5,0x1c
    80005a18:	63c78793          	addi	a5,a5,1596 # 80022050 <cons>
    80005a1c:	0a07a683          	lw	a3,160(a5)
    80005a20:	0016871b          	addiw	a4,a3,1
    80005a24:	0007061b          	sext.w	a2,a4
    80005a28:	0ae7a023          	sw	a4,160(a5)
    80005a2c:	07f6f693          	andi	a3,a3,127
    80005a30:	97b6                	add	a5,a5,a3
    80005a32:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005a36:	47a9                	li	a5,10
    80005a38:	0cf48563          	beq	s1,a5,80005b02 <consoleintr+0x178>
    80005a3c:	4791                	li	a5,4
    80005a3e:	0cf48263          	beq	s1,a5,80005b02 <consoleintr+0x178>
    80005a42:	0001c797          	auipc	a5,0x1c
    80005a46:	6a67a783          	lw	a5,1702(a5) # 800220e8 <cons+0x98>
    80005a4a:	9f1d                	subw	a4,a4,a5
    80005a4c:	08000793          	li	a5,128
    80005a50:	f6f71be3          	bne	a4,a5,800059c6 <consoleintr+0x3c>
    80005a54:	a07d                	j	80005b02 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005a56:	0001c717          	auipc	a4,0x1c
    80005a5a:	5fa70713          	addi	a4,a4,1530 # 80022050 <cons>
    80005a5e:	0a072783          	lw	a5,160(a4)
    80005a62:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005a66:	0001c497          	auipc	s1,0x1c
    80005a6a:	5ea48493          	addi	s1,s1,1514 # 80022050 <cons>
    while(cons.e != cons.w &&
    80005a6e:	4929                	li	s2,10
    80005a70:	f4f70be3          	beq	a4,a5,800059c6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005a74:	37fd                	addiw	a5,a5,-1
    80005a76:	07f7f713          	andi	a4,a5,127
    80005a7a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005a7c:	01874703          	lbu	a4,24(a4)
    80005a80:	f52703e3          	beq	a4,s2,800059c6 <consoleintr+0x3c>
      cons.e--;
    80005a84:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005a88:	10000513          	li	a0,256
    80005a8c:	00000097          	auipc	ra,0x0
    80005a90:	ebc080e7          	jalr	-324(ra) # 80005948 <consputc>
    while(cons.e != cons.w &&
    80005a94:	0a04a783          	lw	a5,160(s1)
    80005a98:	09c4a703          	lw	a4,156(s1)
    80005a9c:	fcf71ce3          	bne	a4,a5,80005a74 <consoleintr+0xea>
    80005aa0:	b71d                	j	800059c6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005aa2:	0001c717          	auipc	a4,0x1c
    80005aa6:	5ae70713          	addi	a4,a4,1454 # 80022050 <cons>
    80005aaa:	0a072783          	lw	a5,160(a4)
    80005aae:	09c72703          	lw	a4,156(a4)
    80005ab2:	f0f70ae3          	beq	a4,a5,800059c6 <consoleintr+0x3c>
      cons.e--;
    80005ab6:	37fd                	addiw	a5,a5,-1
    80005ab8:	0001c717          	auipc	a4,0x1c
    80005abc:	62f72c23          	sw	a5,1592(a4) # 800220f0 <cons+0xa0>
      consputc(BACKSPACE);
    80005ac0:	10000513          	li	a0,256
    80005ac4:	00000097          	auipc	ra,0x0
    80005ac8:	e84080e7          	jalr	-380(ra) # 80005948 <consputc>
    80005acc:	bded                	j	800059c6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005ace:	ee048ce3          	beqz	s1,800059c6 <consoleintr+0x3c>
    80005ad2:	bf21                	j	800059ea <consoleintr+0x60>
      consputc(c);
    80005ad4:	4529                	li	a0,10
    80005ad6:	00000097          	auipc	ra,0x0
    80005ada:	e72080e7          	jalr	-398(ra) # 80005948 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005ade:	0001c797          	auipc	a5,0x1c
    80005ae2:	57278793          	addi	a5,a5,1394 # 80022050 <cons>
    80005ae6:	0a07a703          	lw	a4,160(a5)
    80005aea:	0017069b          	addiw	a3,a4,1
    80005aee:	0006861b          	sext.w	a2,a3
    80005af2:	0ad7a023          	sw	a3,160(a5)
    80005af6:	07f77713          	andi	a4,a4,127
    80005afa:	97ba                	add	a5,a5,a4
    80005afc:	4729                	li	a4,10
    80005afe:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005b02:	0001c797          	auipc	a5,0x1c
    80005b06:	5ec7a523          	sw	a2,1514(a5) # 800220ec <cons+0x9c>
        wakeup(&cons.r);
    80005b0a:	0001c517          	auipc	a0,0x1c
    80005b0e:	5de50513          	addi	a0,a0,1502 # 800220e8 <cons+0x98>
    80005b12:	ffffc097          	auipc	ra,0xffffc
    80005b16:	a5a080e7          	jalr	-1446(ra) # 8000156c <wakeup>
    80005b1a:	b575                	j	800059c6 <consoleintr+0x3c>

0000000080005b1c <consoleinit>:

void
consoleinit(void)
{
    80005b1c:	1141                	addi	sp,sp,-16
    80005b1e:	e406                	sd	ra,8(sp)
    80005b20:	e022                	sd	s0,0(sp)
    80005b22:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005b24:	00003597          	auipc	a1,0x3
    80005b28:	c9c58593          	addi	a1,a1,-868 # 800087c0 <syscalls+0x3f0>
    80005b2c:	0001c517          	auipc	a0,0x1c
    80005b30:	52450513          	addi	a0,a0,1316 # 80022050 <cons>
    80005b34:	00000097          	auipc	ra,0x0
    80005b38:	580080e7          	jalr	1408(ra) # 800060b4 <initlock>

  uartinit();
    80005b3c:	00000097          	auipc	ra,0x0
    80005b40:	32c080e7          	jalr	812(ra) # 80005e68 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005b44:	00013797          	auipc	a5,0x13
    80005b48:	23478793          	addi	a5,a5,564 # 80018d78 <devsw>
    80005b4c:	00000717          	auipc	a4,0x0
    80005b50:	ce470713          	addi	a4,a4,-796 # 80005830 <consoleread>
    80005b54:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005b56:	00000717          	auipc	a4,0x0
    80005b5a:	c7670713          	addi	a4,a4,-906 # 800057cc <consolewrite>
    80005b5e:	ef98                	sd	a4,24(a5)
}
    80005b60:	60a2                	ld	ra,8(sp)
    80005b62:	6402                	ld	s0,0(sp)
    80005b64:	0141                	addi	sp,sp,16
    80005b66:	8082                	ret

0000000080005b68 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005b68:	7179                	addi	sp,sp,-48
    80005b6a:	f406                	sd	ra,40(sp)
    80005b6c:	f022                	sd	s0,32(sp)
    80005b6e:	ec26                	sd	s1,24(sp)
    80005b70:	e84a                	sd	s2,16(sp)
    80005b72:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005b74:	c219                	beqz	a2,80005b7a <printint+0x12>
    80005b76:	08054763          	bltz	a0,80005c04 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    80005b7a:	2501                	sext.w	a0,a0
    80005b7c:	4881                	li	a7,0
    80005b7e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005b82:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005b84:	2581                	sext.w	a1,a1
    80005b86:	00003617          	auipc	a2,0x3
    80005b8a:	c6a60613          	addi	a2,a2,-918 # 800087f0 <digits>
    80005b8e:	883a                	mv	a6,a4
    80005b90:	2705                	addiw	a4,a4,1
    80005b92:	02b577bb          	remuw	a5,a0,a1
    80005b96:	1782                	slli	a5,a5,0x20
    80005b98:	9381                	srli	a5,a5,0x20
    80005b9a:	97b2                	add	a5,a5,a2
    80005b9c:	0007c783          	lbu	a5,0(a5)
    80005ba0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005ba4:	0005079b          	sext.w	a5,a0
    80005ba8:	02b5553b          	divuw	a0,a0,a1
    80005bac:	0685                	addi	a3,a3,1
    80005bae:	feb7f0e3          	bgeu	a5,a1,80005b8e <printint+0x26>

  if(sign)
    80005bb2:	00088c63          	beqz	a7,80005bca <printint+0x62>
    buf[i++] = '-';
    80005bb6:	fe070793          	addi	a5,a4,-32
    80005bba:	00878733          	add	a4,a5,s0
    80005bbe:	02d00793          	li	a5,45
    80005bc2:	fef70823          	sb	a5,-16(a4)
    80005bc6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005bca:	02e05763          	blez	a4,80005bf8 <printint+0x90>
    80005bce:	fd040793          	addi	a5,s0,-48
    80005bd2:	00e784b3          	add	s1,a5,a4
    80005bd6:	fff78913          	addi	s2,a5,-1
    80005bda:	993a                	add	s2,s2,a4
    80005bdc:	377d                	addiw	a4,a4,-1
    80005bde:	1702                	slli	a4,a4,0x20
    80005be0:	9301                	srli	a4,a4,0x20
    80005be2:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005be6:	fff4c503          	lbu	a0,-1(s1)
    80005bea:	00000097          	auipc	ra,0x0
    80005bee:	d5e080e7          	jalr	-674(ra) # 80005948 <consputc>
  while(--i >= 0)
    80005bf2:	14fd                	addi	s1,s1,-1
    80005bf4:	ff2499e3          	bne	s1,s2,80005be6 <printint+0x7e>
}
    80005bf8:	70a2                	ld	ra,40(sp)
    80005bfa:	7402                	ld	s0,32(sp)
    80005bfc:	64e2                	ld	s1,24(sp)
    80005bfe:	6942                	ld	s2,16(sp)
    80005c00:	6145                	addi	sp,sp,48
    80005c02:	8082                	ret
    x = -xx;
    80005c04:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005c08:	4885                	li	a7,1
    x = -xx;
    80005c0a:	bf95                	j	80005b7e <printint+0x16>

0000000080005c0c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005c0c:	1101                	addi	sp,sp,-32
    80005c0e:	ec06                	sd	ra,24(sp)
    80005c10:	e822                	sd	s0,16(sp)
    80005c12:	e426                	sd	s1,8(sp)
    80005c14:	1000                	addi	s0,sp,32
    80005c16:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005c18:	0001c797          	auipc	a5,0x1c
    80005c1c:	4e07ac23          	sw	zero,1272(a5) # 80022110 <pr+0x18>
  printf("panic: ");
    80005c20:	00003517          	auipc	a0,0x3
    80005c24:	ba850513          	addi	a0,a0,-1112 # 800087c8 <syscalls+0x3f8>
    80005c28:	00000097          	auipc	ra,0x0
    80005c2c:	02e080e7          	jalr	46(ra) # 80005c56 <printf>
  printf(s);
    80005c30:	8526                	mv	a0,s1
    80005c32:	00000097          	auipc	ra,0x0
    80005c36:	024080e7          	jalr	36(ra) # 80005c56 <printf>
  printf("\n");
    80005c3a:	00002517          	auipc	a0,0x2
    80005c3e:	40e50513          	addi	a0,a0,1038 # 80008048 <etext+0x48>
    80005c42:	00000097          	auipc	ra,0x0
    80005c46:	014080e7          	jalr	20(ra) # 80005c56 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005c4a:	4785                	li	a5,1
    80005c4c:	00003717          	auipc	a4,0x3
    80005c50:	c8f72023          	sw	a5,-896(a4) # 800088cc <panicked>
  for(;;)
    80005c54:	a001                	j	80005c54 <panic+0x48>

0000000080005c56 <printf>:
{
    80005c56:	7131                	addi	sp,sp,-192
    80005c58:	fc86                	sd	ra,120(sp)
    80005c5a:	f8a2                	sd	s0,112(sp)
    80005c5c:	f4a6                	sd	s1,104(sp)
    80005c5e:	f0ca                	sd	s2,96(sp)
    80005c60:	ecce                	sd	s3,88(sp)
    80005c62:	e8d2                	sd	s4,80(sp)
    80005c64:	e4d6                	sd	s5,72(sp)
    80005c66:	e0da                	sd	s6,64(sp)
    80005c68:	fc5e                	sd	s7,56(sp)
    80005c6a:	f862                	sd	s8,48(sp)
    80005c6c:	f466                	sd	s9,40(sp)
    80005c6e:	f06a                	sd	s10,32(sp)
    80005c70:	ec6e                	sd	s11,24(sp)
    80005c72:	0100                	addi	s0,sp,128
    80005c74:	8a2a                	mv	s4,a0
    80005c76:	e40c                	sd	a1,8(s0)
    80005c78:	e810                	sd	a2,16(s0)
    80005c7a:	ec14                	sd	a3,24(s0)
    80005c7c:	f018                	sd	a4,32(s0)
    80005c7e:	f41c                	sd	a5,40(s0)
    80005c80:	03043823          	sd	a6,48(s0)
    80005c84:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005c88:	0001cd97          	auipc	s11,0x1c
    80005c8c:	488dad83          	lw	s11,1160(s11) # 80022110 <pr+0x18>
  if(locking)
    80005c90:	020d9b63          	bnez	s11,80005cc6 <printf+0x70>
  if (fmt == 0)
    80005c94:	040a0263          	beqz	s4,80005cd8 <printf+0x82>
  va_start(ap, fmt);
    80005c98:	00840793          	addi	a5,s0,8
    80005c9c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005ca0:	000a4503          	lbu	a0,0(s4)
    80005ca4:	14050f63          	beqz	a0,80005e02 <printf+0x1ac>
    80005ca8:	4981                	li	s3,0
    if(c != '%'){
    80005caa:	02500a93          	li	s5,37
    switch(c){
    80005cae:	07000b93          	li	s7,112
  consputc('x');
    80005cb2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005cb4:	00003b17          	auipc	s6,0x3
    80005cb8:	b3cb0b13          	addi	s6,s6,-1220 # 800087f0 <digits>
    switch(c){
    80005cbc:	07300c93          	li	s9,115
    80005cc0:	06400c13          	li	s8,100
    80005cc4:	a82d                	j	80005cfe <printf+0xa8>
    acquire(&pr.lock);
    80005cc6:	0001c517          	auipc	a0,0x1c
    80005cca:	43250513          	addi	a0,a0,1074 # 800220f8 <pr>
    80005cce:	00000097          	auipc	ra,0x0
    80005cd2:	476080e7          	jalr	1142(ra) # 80006144 <acquire>
    80005cd6:	bf7d                	j	80005c94 <printf+0x3e>
    panic("null fmt");
    80005cd8:	00003517          	auipc	a0,0x3
    80005cdc:	b0050513          	addi	a0,a0,-1280 # 800087d8 <syscalls+0x408>
    80005ce0:	00000097          	auipc	ra,0x0
    80005ce4:	f2c080e7          	jalr	-212(ra) # 80005c0c <panic>
      consputc(c);
    80005ce8:	00000097          	auipc	ra,0x0
    80005cec:	c60080e7          	jalr	-928(ra) # 80005948 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005cf0:	2985                	addiw	s3,s3,1
    80005cf2:	013a07b3          	add	a5,s4,s3
    80005cf6:	0007c503          	lbu	a0,0(a5)
    80005cfa:	10050463          	beqz	a0,80005e02 <printf+0x1ac>
    if(c != '%'){
    80005cfe:	ff5515e3          	bne	a0,s5,80005ce8 <printf+0x92>
    c = fmt[++i] & 0xff;
    80005d02:	2985                	addiw	s3,s3,1
    80005d04:	013a07b3          	add	a5,s4,s3
    80005d08:	0007c783          	lbu	a5,0(a5)
    80005d0c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80005d10:	cbed                	beqz	a5,80005e02 <printf+0x1ac>
    switch(c){
    80005d12:	05778a63          	beq	a5,s7,80005d66 <printf+0x110>
    80005d16:	02fbf663          	bgeu	s7,a5,80005d42 <printf+0xec>
    80005d1a:	09978863          	beq	a5,s9,80005daa <printf+0x154>
    80005d1e:	07800713          	li	a4,120
    80005d22:	0ce79563          	bne	a5,a4,80005dec <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80005d26:	f8843783          	ld	a5,-120(s0)
    80005d2a:	00878713          	addi	a4,a5,8
    80005d2e:	f8e43423          	sd	a4,-120(s0)
    80005d32:	4605                	li	a2,1
    80005d34:	85ea                	mv	a1,s10
    80005d36:	4388                	lw	a0,0(a5)
    80005d38:	00000097          	auipc	ra,0x0
    80005d3c:	e30080e7          	jalr	-464(ra) # 80005b68 <printint>
      break;
    80005d40:	bf45                	j	80005cf0 <printf+0x9a>
    switch(c){
    80005d42:	09578f63          	beq	a5,s5,80005de0 <printf+0x18a>
    80005d46:	0b879363          	bne	a5,s8,80005dec <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80005d4a:	f8843783          	ld	a5,-120(s0)
    80005d4e:	00878713          	addi	a4,a5,8
    80005d52:	f8e43423          	sd	a4,-120(s0)
    80005d56:	4605                	li	a2,1
    80005d58:	45a9                	li	a1,10
    80005d5a:	4388                	lw	a0,0(a5)
    80005d5c:	00000097          	auipc	ra,0x0
    80005d60:	e0c080e7          	jalr	-500(ra) # 80005b68 <printint>
      break;
    80005d64:	b771                	j	80005cf0 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005d66:	f8843783          	ld	a5,-120(s0)
    80005d6a:	00878713          	addi	a4,a5,8
    80005d6e:	f8e43423          	sd	a4,-120(s0)
    80005d72:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80005d76:	03000513          	li	a0,48
    80005d7a:	00000097          	auipc	ra,0x0
    80005d7e:	bce080e7          	jalr	-1074(ra) # 80005948 <consputc>
  consputc('x');
    80005d82:	07800513          	li	a0,120
    80005d86:	00000097          	auipc	ra,0x0
    80005d8a:	bc2080e7          	jalr	-1086(ra) # 80005948 <consputc>
    80005d8e:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005d90:	03c95793          	srli	a5,s2,0x3c
    80005d94:	97da                	add	a5,a5,s6
    80005d96:	0007c503          	lbu	a0,0(a5)
    80005d9a:	00000097          	auipc	ra,0x0
    80005d9e:	bae080e7          	jalr	-1106(ra) # 80005948 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005da2:	0912                	slli	s2,s2,0x4
    80005da4:	34fd                	addiw	s1,s1,-1
    80005da6:	f4ed                	bnez	s1,80005d90 <printf+0x13a>
    80005da8:	b7a1                	j	80005cf0 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80005daa:	f8843783          	ld	a5,-120(s0)
    80005dae:	00878713          	addi	a4,a5,8
    80005db2:	f8e43423          	sd	a4,-120(s0)
    80005db6:	6384                	ld	s1,0(a5)
    80005db8:	cc89                	beqz	s1,80005dd2 <printf+0x17c>
      for(; *s; s++)
    80005dba:	0004c503          	lbu	a0,0(s1)
    80005dbe:	d90d                	beqz	a0,80005cf0 <printf+0x9a>
        consputc(*s);
    80005dc0:	00000097          	auipc	ra,0x0
    80005dc4:	b88080e7          	jalr	-1144(ra) # 80005948 <consputc>
      for(; *s; s++)
    80005dc8:	0485                	addi	s1,s1,1
    80005dca:	0004c503          	lbu	a0,0(s1)
    80005dce:	f96d                	bnez	a0,80005dc0 <printf+0x16a>
    80005dd0:	b705                	j	80005cf0 <printf+0x9a>
        s = "(null)";
    80005dd2:	00003497          	auipc	s1,0x3
    80005dd6:	9fe48493          	addi	s1,s1,-1538 # 800087d0 <syscalls+0x400>
      for(; *s; s++)
    80005dda:	02800513          	li	a0,40
    80005dde:	b7cd                	j	80005dc0 <printf+0x16a>
      consputc('%');
    80005de0:	8556                	mv	a0,s5
    80005de2:	00000097          	auipc	ra,0x0
    80005de6:	b66080e7          	jalr	-1178(ra) # 80005948 <consputc>
      break;
    80005dea:	b719                	j	80005cf0 <printf+0x9a>
      consputc('%');
    80005dec:	8556                	mv	a0,s5
    80005dee:	00000097          	auipc	ra,0x0
    80005df2:	b5a080e7          	jalr	-1190(ra) # 80005948 <consputc>
      consputc(c);
    80005df6:	8526                	mv	a0,s1
    80005df8:	00000097          	auipc	ra,0x0
    80005dfc:	b50080e7          	jalr	-1200(ra) # 80005948 <consputc>
      break;
    80005e00:	bdc5                	j	80005cf0 <printf+0x9a>
  if(locking)
    80005e02:	020d9163          	bnez	s11,80005e24 <printf+0x1ce>
}
    80005e06:	70e6                	ld	ra,120(sp)
    80005e08:	7446                	ld	s0,112(sp)
    80005e0a:	74a6                	ld	s1,104(sp)
    80005e0c:	7906                	ld	s2,96(sp)
    80005e0e:	69e6                	ld	s3,88(sp)
    80005e10:	6a46                	ld	s4,80(sp)
    80005e12:	6aa6                	ld	s5,72(sp)
    80005e14:	6b06                	ld	s6,64(sp)
    80005e16:	7be2                	ld	s7,56(sp)
    80005e18:	7c42                	ld	s8,48(sp)
    80005e1a:	7ca2                	ld	s9,40(sp)
    80005e1c:	7d02                	ld	s10,32(sp)
    80005e1e:	6de2                	ld	s11,24(sp)
    80005e20:	6129                	addi	sp,sp,192
    80005e22:	8082                	ret
    release(&pr.lock);
    80005e24:	0001c517          	auipc	a0,0x1c
    80005e28:	2d450513          	addi	a0,a0,724 # 800220f8 <pr>
    80005e2c:	00000097          	auipc	ra,0x0
    80005e30:	3cc080e7          	jalr	972(ra) # 800061f8 <release>
}
    80005e34:	bfc9                	j	80005e06 <printf+0x1b0>

0000000080005e36 <printfinit>:
    ;
}

void
printfinit(void)
{
    80005e36:	1101                	addi	sp,sp,-32
    80005e38:	ec06                	sd	ra,24(sp)
    80005e3a:	e822                	sd	s0,16(sp)
    80005e3c:	e426                	sd	s1,8(sp)
    80005e3e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005e40:	0001c497          	auipc	s1,0x1c
    80005e44:	2b848493          	addi	s1,s1,696 # 800220f8 <pr>
    80005e48:	00003597          	auipc	a1,0x3
    80005e4c:	9a058593          	addi	a1,a1,-1632 # 800087e8 <syscalls+0x418>
    80005e50:	8526                	mv	a0,s1
    80005e52:	00000097          	auipc	ra,0x0
    80005e56:	262080e7          	jalr	610(ra) # 800060b4 <initlock>
  pr.locking = 1;
    80005e5a:	4785                	li	a5,1
    80005e5c:	cc9c                	sw	a5,24(s1)
}
    80005e5e:	60e2                	ld	ra,24(sp)
    80005e60:	6442                	ld	s0,16(sp)
    80005e62:	64a2                	ld	s1,8(sp)
    80005e64:	6105                	addi	sp,sp,32
    80005e66:	8082                	ret

0000000080005e68 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80005e68:	1141                	addi	sp,sp,-16
    80005e6a:	e406                	sd	ra,8(sp)
    80005e6c:	e022                	sd	s0,0(sp)
    80005e6e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005e70:	100007b7          	lui	a5,0x10000
    80005e74:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005e78:	f8000713          	li	a4,-128
    80005e7c:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005e80:	470d                	li	a4,3
    80005e82:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005e86:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005e8a:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005e8e:	469d                	li	a3,7
    80005e90:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005e94:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005e98:	00003597          	auipc	a1,0x3
    80005e9c:	97058593          	addi	a1,a1,-1680 # 80008808 <digits+0x18>
    80005ea0:	0001c517          	auipc	a0,0x1c
    80005ea4:	27850513          	addi	a0,a0,632 # 80022118 <uart_tx_lock>
    80005ea8:	00000097          	auipc	ra,0x0
    80005eac:	20c080e7          	jalr	524(ra) # 800060b4 <initlock>
}
    80005eb0:	60a2                	ld	ra,8(sp)
    80005eb2:	6402                	ld	s0,0(sp)
    80005eb4:	0141                	addi	sp,sp,16
    80005eb6:	8082                	ret

0000000080005eb8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005eb8:	1101                	addi	sp,sp,-32
    80005eba:	ec06                	sd	ra,24(sp)
    80005ebc:	e822                	sd	s0,16(sp)
    80005ebe:	e426                	sd	s1,8(sp)
    80005ec0:	1000                	addi	s0,sp,32
    80005ec2:	84aa                	mv	s1,a0
  push_off();
    80005ec4:	00000097          	auipc	ra,0x0
    80005ec8:	234080e7          	jalr	564(ra) # 800060f8 <push_off>

  if(panicked){
    80005ecc:	00003797          	auipc	a5,0x3
    80005ed0:	a007a783          	lw	a5,-1536(a5) # 800088cc <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005ed4:	10000737          	lui	a4,0x10000
  if(panicked){
    80005ed8:	c391                	beqz	a5,80005edc <uartputc_sync+0x24>
    for(;;)
    80005eda:	a001                	j	80005eda <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005edc:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80005ee0:	0207f793          	andi	a5,a5,32
    80005ee4:	dfe5                	beqz	a5,80005edc <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80005ee6:	0ff4f513          	zext.b	a0,s1
    80005eea:	100007b7          	lui	a5,0x10000
    80005eee:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80005ef2:	00000097          	auipc	ra,0x0
    80005ef6:	2a6080e7          	jalr	678(ra) # 80006198 <pop_off>
}
    80005efa:	60e2                	ld	ra,24(sp)
    80005efc:	6442                	ld	s0,16(sp)
    80005efe:	64a2                	ld	s1,8(sp)
    80005f00:	6105                	addi	sp,sp,32
    80005f02:	8082                	ret

0000000080005f04 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80005f04:	00003797          	auipc	a5,0x3
    80005f08:	9cc7b783          	ld	a5,-1588(a5) # 800088d0 <uart_tx_r>
    80005f0c:	00003717          	auipc	a4,0x3
    80005f10:	9cc73703          	ld	a4,-1588(a4) # 800088d8 <uart_tx_w>
    80005f14:	06f70a63          	beq	a4,a5,80005f88 <uartstart+0x84>
{
    80005f18:	7139                	addi	sp,sp,-64
    80005f1a:	fc06                	sd	ra,56(sp)
    80005f1c:	f822                	sd	s0,48(sp)
    80005f1e:	f426                	sd	s1,40(sp)
    80005f20:	f04a                	sd	s2,32(sp)
    80005f22:	ec4e                	sd	s3,24(sp)
    80005f24:	e852                	sd	s4,16(sp)
    80005f26:	e456                	sd	s5,8(sp)
    80005f28:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005f2a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005f2e:	0001ca17          	auipc	s4,0x1c
    80005f32:	1eaa0a13          	addi	s4,s4,490 # 80022118 <uart_tx_lock>
    uart_tx_r += 1;
    80005f36:	00003497          	auipc	s1,0x3
    80005f3a:	99a48493          	addi	s1,s1,-1638 # 800088d0 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80005f3e:	00003997          	auipc	s3,0x3
    80005f42:	99a98993          	addi	s3,s3,-1638 # 800088d8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80005f46:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80005f4a:	02077713          	andi	a4,a4,32
    80005f4e:	c705                	beqz	a4,80005f76 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80005f50:	01f7f713          	andi	a4,a5,31
    80005f54:	9752                	add	a4,a4,s4
    80005f56:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    80005f5a:	0785                	addi	a5,a5,1
    80005f5c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80005f5e:	8526                	mv	a0,s1
    80005f60:	ffffb097          	auipc	ra,0xffffb
    80005f64:	60c080e7          	jalr	1548(ra) # 8000156c <wakeup>
    
    WriteReg(THR, c);
    80005f68:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    80005f6c:	609c                	ld	a5,0(s1)
    80005f6e:	0009b703          	ld	a4,0(s3)
    80005f72:	fcf71ae3          	bne	a4,a5,80005f46 <uartstart+0x42>
  }
}
    80005f76:	70e2                	ld	ra,56(sp)
    80005f78:	7442                	ld	s0,48(sp)
    80005f7a:	74a2                	ld	s1,40(sp)
    80005f7c:	7902                	ld	s2,32(sp)
    80005f7e:	69e2                	ld	s3,24(sp)
    80005f80:	6a42                	ld	s4,16(sp)
    80005f82:	6aa2                	ld	s5,8(sp)
    80005f84:	6121                	addi	sp,sp,64
    80005f86:	8082                	ret
    80005f88:	8082                	ret

0000000080005f8a <uartputc>:
{
    80005f8a:	7179                	addi	sp,sp,-48
    80005f8c:	f406                	sd	ra,40(sp)
    80005f8e:	f022                	sd	s0,32(sp)
    80005f90:	ec26                	sd	s1,24(sp)
    80005f92:	e84a                	sd	s2,16(sp)
    80005f94:	e44e                	sd	s3,8(sp)
    80005f96:	e052                	sd	s4,0(sp)
    80005f98:	1800                	addi	s0,sp,48
    80005f9a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    80005f9c:	0001c517          	auipc	a0,0x1c
    80005fa0:	17c50513          	addi	a0,a0,380 # 80022118 <uart_tx_lock>
    80005fa4:	00000097          	auipc	ra,0x0
    80005fa8:	1a0080e7          	jalr	416(ra) # 80006144 <acquire>
  if(panicked){
    80005fac:	00003797          	auipc	a5,0x3
    80005fb0:	9207a783          	lw	a5,-1760(a5) # 800088cc <panicked>
    80005fb4:	e7c9                	bnez	a5,8000603e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005fb6:	00003717          	auipc	a4,0x3
    80005fba:	92273703          	ld	a4,-1758(a4) # 800088d8 <uart_tx_w>
    80005fbe:	00003797          	auipc	a5,0x3
    80005fc2:	9127b783          	ld	a5,-1774(a5) # 800088d0 <uart_tx_r>
    80005fc6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80005fca:	0001c997          	auipc	s3,0x1c
    80005fce:	14e98993          	addi	s3,s3,334 # 80022118 <uart_tx_lock>
    80005fd2:	00003497          	auipc	s1,0x3
    80005fd6:	8fe48493          	addi	s1,s1,-1794 # 800088d0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005fda:	00003917          	auipc	s2,0x3
    80005fde:	8fe90913          	addi	s2,s2,-1794 # 800088d8 <uart_tx_w>
    80005fe2:	00e79f63          	bne	a5,a4,80006000 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80005fe6:	85ce                	mv	a1,s3
    80005fe8:	8526                	mv	a0,s1
    80005fea:	ffffb097          	auipc	ra,0xffffb
    80005fee:	51e080e7          	jalr	1310(ra) # 80001508 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80005ff2:	00093703          	ld	a4,0(s2)
    80005ff6:	609c                	ld	a5,0(s1)
    80005ff8:	02078793          	addi	a5,a5,32
    80005ffc:	fee785e3          	beq	a5,a4,80005fe6 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80006000:	0001c497          	auipc	s1,0x1c
    80006004:	11848493          	addi	s1,s1,280 # 80022118 <uart_tx_lock>
    80006008:	01f77793          	andi	a5,a4,31
    8000600c:	97a6                	add	a5,a5,s1
    8000600e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80006012:	0705                	addi	a4,a4,1
    80006014:	00003797          	auipc	a5,0x3
    80006018:	8ce7b223          	sd	a4,-1852(a5) # 800088d8 <uart_tx_w>
  uartstart();
    8000601c:	00000097          	auipc	ra,0x0
    80006020:	ee8080e7          	jalr	-280(ra) # 80005f04 <uartstart>
  release(&uart_tx_lock);
    80006024:	8526                	mv	a0,s1
    80006026:	00000097          	auipc	ra,0x0
    8000602a:	1d2080e7          	jalr	466(ra) # 800061f8 <release>
}
    8000602e:	70a2                	ld	ra,40(sp)
    80006030:	7402                	ld	s0,32(sp)
    80006032:	64e2                	ld	s1,24(sp)
    80006034:	6942                	ld	s2,16(sp)
    80006036:	69a2                	ld	s3,8(sp)
    80006038:	6a02                	ld	s4,0(sp)
    8000603a:	6145                	addi	sp,sp,48
    8000603c:	8082                	ret
    for(;;)
    8000603e:	a001                	j	8000603e <uartputc+0xb4>

0000000080006040 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80006040:	1141                	addi	sp,sp,-16
    80006042:	e422                	sd	s0,8(sp)
    80006044:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80006046:	100007b7          	lui	a5,0x10000
    8000604a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000604e:	8b85                	andi	a5,a5,1
    80006050:	cb81                	beqz	a5,80006060 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80006052:	100007b7          	lui	a5,0x10000
    80006056:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000605a:	6422                	ld	s0,8(sp)
    8000605c:	0141                	addi	sp,sp,16
    8000605e:	8082                	ret
    return -1;
    80006060:	557d                	li	a0,-1
    80006062:	bfe5                	j	8000605a <uartgetc+0x1a>

0000000080006064 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80006064:	1101                	addi	sp,sp,-32
    80006066:	ec06                	sd	ra,24(sp)
    80006068:	e822                	sd	s0,16(sp)
    8000606a:	e426                	sd	s1,8(sp)
    8000606c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000606e:	54fd                	li	s1,-1
    80006070:	a029                	j	8000607a <uartintr+0x16>
      break;
    consoleintr(c);
    80006072:	00000097          	auipc	ra,0x0
    80006076:	918080e7          	jalr	-1768(ra) # 8000598a <consoleintr>
    int c = uartgetc();
    8000607a:	00000097          	auipc	ra,0x0
    8000607e:	fc6080e7          	jalr	-58(ra) # 80006040 <uartgetc>
    if(c == -1)
    80006082:	fe9518e3          	bne	a0,s1,80006072 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80006086:	0001c497          	auipc	s1,0x1c
    8000608a:	09248493          	addi	s1,s1,146 # 80022118 <uart_tx_lock>
    8000608e:	8526                	mv	a0,s1
    80006090:	00000097          	auipc	ra,0x0
    80006094:	0b4080e7          	jalr	180(ra) # 80006144 <acquire>
  uartstart();
    80006098:	00000097          	auipc	ra,0x0
    8000609c:	e6c080e7          	jalr	-404(ra) # 80005f04 <uartstart>
  release(&uart_tx_lock);
    800060a0:	8526                	mv	a0,s1
    800060a2:	00000097          	auipc	ra,0x0
    800060a6:	156080e7          	jalr	342(ra) # 800061f8 <release>
}
    800060aa:	60e2                	ld	ra,24(sp)
    800060ac:	6442                	ld	s0,16(sp)
    800060ae:	64a2                	ld	s1,8(sp)
    800060b0:	6105                	addi	sp,sp,32
    800060b2:	8082                	ret

00000000800060b4 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800060b4:	1141                	addi	sp,sp,-16
    800060b6:	e422                	sd	s0,8(sp)
    800060b8:	0800                	addi	s0,sp,16
  lk->name = name;
    800060ba:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800060bc:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800060c0:	00053823          	sd	zero,16(a0)
}
    800060c4:	6422                	ld	s0,8(sp)
    800060c6:	0141                	addi	sp,sp,16
    800060c8:	8082                	ret

00000000800060ca <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800060ca:	411c                	lw	a5,0(a0)
    800060cc:	e399                	bnez	a5,800060d2 <holding+0x8>
    800060ce:	4501                	li	a0,0
  return r;
}
    800060d0:	8082                	ret
{
    800060d2:	1101                	addi	sp,sp,-32
    800060d4:	ec06                	sd	ra,24(sp)
    800060d6:	e822                	sd	s0,16(sp)
    800060d8:	e426                	sd	s1,8(sp)
    800060da:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800060dc:	6904                	ld	s1,16(a0)
    800060de:	ffffb097          	auipc	ra,0xffffb
    800060e2:	d5a080e7          	jalr	-678(ra) # 80000e38 <mycpu>
    800060e6:	40a48533          	sub	a0,s1,a0
    800060ea:	00153513          	seqz	a0,a0
}
    800060ee:	60e2                	ld	ra,24(sp)
    800060f0:	6442                	ld	s0,16(sp)
    800060f2:	64a2                	ld	s1,8(sp)
    800060f4:	6105                	addi	sp,sp,32
    800060f6:	8082                	ret

00000000800060f8 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800060f8:	1101                	addi	sp,sp,-32
    800060fa:	ec06                	sd	ra,24(sp)
    800060fc:	e822                	sd	s0,16(sp)
    800060fe:	e426                	sd	s1,8(sp)
    80006100:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006102:	100024f3          	csrr	s1,sstatus
    80006106:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000610a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000610c:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80006110:	ffffb097          	auipc	ra,0xffffb
    80006114:	d28080e7          	jalr	-728(ra) # 80000e38 <mycpu>
    80006118:	5d3c                	lw	a5,120(a0)
    8000611a:	cf89                	beqz	a5,80006134 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000611c:	ffffb097          	auipc	ra,0xffffb
    80006120:	d1c080e7          	jalr	-740(ra) # 80000e38 <mycpu>
    80006124:	5d3c                	lw	a5,120(a0)
    80006126:	2785                	addiw	a5,a5,1
    80006128:	dd3c                	sw	a5,120(a0)
}
    8000612a:	60e2                	ld	ra,24(sp)
    8000612c:	6442                	ld	s0,16(sp)
    8000612e:	64a2                	ld	s1,8(sp)
    80006130:	6105                	addi	sp,sp,32
    80006132:	8082                	ret
    mycpu()->intena = old;
    80006134:	ffffb097          	auipc	ra,0xffffb
    80006138:	d04080e7          	jalr	-764(ra) # 80000e38 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000613c:	8085                	srli	s1,s1,0x1
    8000613e:	8885                	andi	s1,s1,1
    80006140:	dd64                	sw	s1,124(a0)
    80006142:	bfe9                	j	8000611c <push_off+0x24>

0000000080006144 <acquire>:
{
    80006144:	1101                	addi	sp,sp,-32
    80006146:	ec06                	sd	ra,24(sp)
    80006148:	e822                	sd	s0,16(sp)
    8000614a:	e426                	sd	s1,8(sp)
    8000614c:	1000                	addi	s0,sp,32
    8000614e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80006150:	00000097          	auipc	ra,0x0
    80006154:	fa8080e7          	jalr	-88(ra) # 800060f8 <push_off>
  if(holding(lk))
    80006158:	8526                	mv	a0,s1
    8000615a:	00000097          	auipc	ra,0x0
    8000615e:	f70080e7          	jalr	-144(ra) # 800060ca <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80006162:	4705                	li	a4,1
  if(holding(lk))
    80006164:	e115                	bnez	a0,80006188 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80006166:	87ba                	mv	a5,a4
    80006168:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    8000616c:	2781                	sext.w	a5,a5
    8000616e:	ffe5                	bnez	a5,80006166 <acquire+0x22>
  __sync_synchronize();
    80006170:	0ff0000f          	fence
  lk->cpu = mycpu();
    80006174:	ffffb097          	auipc	ra,0xffffb
    80006178:	cc4080e7          	jalr	-828(ra) # 80000e38 <mycpu>
    8000617c:	e888                	sd	a0,16(s1)
}
    8000617e:	60e2                	ld	ra,24(sp)
    80006180:	6442                	ld	s0,16(sp)
    80006182:	64a2                	ld	s1,8(sp)
    80006184:	6105                	addi	sp,sp,32
    80006186:	8082                	ret
    panic("acquire");
    80006188:	00002517          	auipc	a0,0x2
    8000618c:	68850513          	addi	a0,a0,1672 # 80008810 <digits+0x20>
    80006190:	00000097          	auipc	ra,0x0
    80006194:	a7c080e7          	jalr	-1412(ra) # 80005c0c <panic>

0000000080006198 <pop_off>:

void
pop_off(void)
{
    80006198:	1141                	addi	sp,sp,-16
    8000619a:	e406                	sd	ra,8(sp)
    8000619c:	e022                	sd	s0,0(sp)
    8000619e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    800061a0:	ffffb097          	auipc	ra,0xffffb
    800061a4:	c98080e7          	jalr	-872(ra) # 80000e38 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800061a8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800061ac:	8b89                	andi	a5,a5,2
  if(intr_get())
    800061ae:	e78d                	bnez	a5,800061d8 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800061b0:	5d3c                	lw	a5,120(a0)
    800061b2:	02f05b63          	blez	a5,800061e8 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    800061b6:	37fd                	addiw	a5,a5,-1
    800061b8:	0007871b          	sext.w	a4,a5
    800061bc:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800061be:	eb09                	bnez	a4,800061d0 <pop_off+0x38>
    800061c0:	5d7c                	lw	a5,124(a0)
    800061c2:	c799                	beqz	a5,800061d0 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800061c4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800061c8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800061cc:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800061d0:	60a2                	ld	ra,8(sp)
    800061d2:	6402                	ld	s0,0(sp)
    800061d4:	0141                	addi	sp,sp,16
    800061d6:	8082                	ret
    panic("pop_off - interruptible");
    800061d8:	00002517          	auipc	a0,0x2
    800061dc:	64050513          	addi	a0,a0,1600 # 80008818 <digits+0x28>
    800061e0:	00000097          	auipc	ra,0x0
    800061e4:	a2c080e7          	jalr	-1492(ra) # 80005c0c <panic>
    panic("pop_off");
    800061e8:	00002517          	auipc	a0,0x2
    800061ec:	64850513          	addi	a0,a0,1608 # 80008830 <digits+0x40>
    800061f0:	00000097          	auipc	ra,0x0
    800061f4:	a1c080e7          	jalr	-1508(ra) # 80005c0c <panic>

00000000800061f8 <release>:
{
    800061f8:	1101                	addi	sp,sp,-32
    800061fa:	ec06                	sd	ra,24(sp)
    800061fc:	e822                	sd	s0,16(sp)
    800061fe:	e426                	sd	s1,8(sp)
    80006200:	1000                	addi	s0,sp,32
    80006202:	84aa                	mv	s1,a0
  if(!holding(lk))
    80006204:	00000097          	auipc	ra,0x0
    80006208:	ec6080e7          	jalr	-314(ra) # 800060ca <holding>
    8000620c:	c115                	beqz	a0,80006230 <release+0x38>
  lk->cpu = 0;
    8000620e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80006212:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80006216:	0f50000f          	fence	iorw,ow
    8000621a:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000621e:	00000097          	auipc	ra,0x0
    80006222:	f7a080e7          	jalr	-134(ra) # 80006198 <pop_off>
}
    80006226:	60e2                	ld	ra,24(sp)
    80006228:	6442                	ld	s0,16(sp)
    8000622a:	64a2                	ld	s1,8(sp)
    8000622c:	6105                	addi	sp,sp,32
    8000622e:	8082                	ret
    panic("release");
    80006230:	00002517          	auipc	a0,0x2
    80006234:	60850513          	addi	a0,a0,1544 # 80008838 <digits+0x48>
    80006238:	00000097          	auipc	ra,0x0
    8000623c:	9d4080e7          	jalr	-1580(ra) # 80005c0c <panic>
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
