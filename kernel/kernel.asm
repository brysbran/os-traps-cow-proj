
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
    80000016:	033050ef          	jal	ra,80005848 <start>

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
    80000034:	54078793          	addi	a5,a5,1344 # 80022570 <end>
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
    8000005e:	1da080e7          	jalr	474(ra) # 80006234 <acquire>
  r->next = kmem.freelist;
    80000062:	01893783          	ld	a5,24(s2)
    80000066:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000068:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006c:	854a                	mv	a0,s2
    8000006e:	00006097          	auipc	ra,0x6
    80000072:	27a080e7          	jalr	634(ra) # 800062e8 <release>
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
    8000008e:	c72080e7          	jalr	-910(ra) # 80005cfc <panic>

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
    800000fa:	0ae080e7          	jalr	174(ra) # 800061a4 <initlock>
  freerange(end, (void*)PHYSTOP);
    800000fe:	45c5                	li	a1,17
    80000100:	05ee                	slli	a1,a1,0x1b
    80000102:	00022517          	auipc	a0,0x22
    80000106:	46e50513          	addi	a0,a0,1134 # 80022570 <end>
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
    80000132:	106080e7          	jalr	262(ra) # 80006234 <acquire>
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
    8000014a:	1a2080e7          	jalr	418(ra) # 800062e8 <release>

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
    80000174:	178080e7          	jalr	376(ra) # 800062e8 <release>
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
    800001ee:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdca91>
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
    8000035a:	9f0080e7          	jalr	-1552(ra) # 80005d46 <printf>
    kvminithart();    // turn on paging
    8000035e:	00000097          	auipc	ra,0x0
    80000362:	0d8080e7          	jalr	216(ra) # 80000436 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000366:	00001097          	auipc	ra,0x1
    8000036a:	796080e7          	jalr	1942(ra) # 80001afc <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    8000036e:	00005097          	auipc	ra,0x5
    80000372:	e92080e7          	jalr	-366(ra) # 80005200 <plicinithart>
  }

  scheduler();        
    80000376:	00001097          	auipc	ra,0x1
    8000037a:	fde080e7          	jalr	-34(ra) # 80001354 <scheduler>
    consoleinit();
    8000037e:	00006097          	auipc	ra,0x6
    80000382:	88e080e7          	jalr	-1906(ra) # 80005c0c <consoleinit>
    printfinit();
    80000386:	00006097          	auipc	ra,0x6
    8000038a:	ba0080e7          	jalr	-1120(ra) # 80005f26 <printfinit>
    printf("\n");
    8000038e:	00008517          	auipc	a0,0x8
    80000392:	cba50513          	addi	a0,a0,-838 # 80008048 <etext+0x48>
    80000396:	00006097          	auipc	ra,0x6
    8000039a:	9b0080e7          	jalr	-1616(ra) # 80005d46 <printf>
    printf("xv6 kernel is booting\n");
    8000039e:	00008517          	auipc	a0,0x8
    800003a2:	c8250513          	addi	a0,a0,-894 # 80008020 <etext+0x20>
    800003a6:	00006097          	auipc	ra,0x6
    800003aa:	9a0080e7          	jalr	-1632(ra) # 80005d46 <printf>
    printf("\n");
    800003ae:	00008517          	auipc	a0,0x8
    800003b2:	c9a50513          	addi	a0,a0,-870 # 80008048 <etext+0x48>
    800003b6:	00006097          	auipc	ra,0x6
    800003ba:	990080e7          	jalr	-1648(ra) # 80005d46 <printf>
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
    800003e2:	6f6080e7          	jalr	1782(ra) # 80001ad4 <trapinit>
    trapinithart();  // install kernel trap vector
    800003e6:	00001097          	auipc	ra,0x1
    800003ea:	716080e7          	jalr	1814(ra) # 80001afc <trapinithart>
    plicinit();      // set up interrupt controller
    800003ee:	00005097          	auipc	ra,0x5
    800003f2:	dfc080e7          	jalr	-516(ra) # 800051ea <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    800003f6:	00005097          	auipc	ra,0x5
    800003fa:	e0a080e7          	jalr	-502(ra) # 80005200 <plicinithart>
    binit();         // buffer cache
    800003fe:	00002097          	auipc	ra,0x2
    80000402:	fa0080e7          	jalr	-96(ra) # 8000239e <binit>
    iinit();         // inode table
    80000406:	00002097          	auipc	ra,0x2
    8000040a:	640080e7          	jalr	1600(ra) # 80002a46 <iinit>
    fileinit();      // file table
    8000040e:	00003097          	auipc	ra,0x3
    80000412:	5e6080e7          	jalr	1510(ra) # 800039f4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000416:	00005097          	auipc	ra,0x5
    8000041a:	ef2080e7          	jalr	-270(ra) # 80005308 <virtio_disk_init>
    userinit();      // first user process
    8000041e:	00001097          	auipc	ra,0x1
    80000422:	d18080e7          	jalr	-744(ra) # 80001136 <userinit>
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
    80000490:	870080e7          	jalr	-1936(ra) # 80005cfc <panic>
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
    800004be:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdca87>
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
    800005b6:	74a080e7          	jalr	1866(ra) # 80005cfc <panic>
      panic("mappages: remap");
    800005ba:	00008517          	auipc	a0,0x8
    800005be:	aae50513          	addi	a0,a0,-1362 # 80008068 <etext+0x68>
    800005c2:	00005097          	auipc	ra,0x5
    800005c6:	73a080e7          	jalr	1850(ra) # 80005cfc <panic>
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
    80000612:	6ee080e7          	jalr	1774(ra) # 80005cfc <panic>

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
    8000075e:	5a2080e7          	jalr	1442(ra) # 80005cfc <panic>
      panic("uvmunmap: walk");
    80000762:	00008517          	auipc	a0,0x8
    80000766:	93650513          	addi	a0,a0,-1738 # 80008098 <etext+0x98>
    8000076a:	00005097          	auipc	ra,0x5
    8000076e:	592080e7          	jalr	1426(ra) # 80005cfc <panic>
      panic("uvmunmap: not mapped");
    80000772:	00008517          	auipc	a0,0x8
    80000776:	93650513          	addi	a0,a0,-1738 # 800080a8 <etext+0xa8>
    8000077a:	00005097          	auipc	ra,0x5
    8000077e:	582080e7          	jalr	1410(ra) # 80005cfc <panic>
      panic("uvmunmap: not a leaf");
    80000782:	00008517          	auipc	a0,0x8
    80000786:	93e50513          	addi	a0,a0,-1730 # 800080c0 <etext+0xc0>
    8000078a:	00005097          	auipc	ra,0x5
    8000078e:	572080e7          	jalr	1394(ra) # 80005cfc <panic>
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
    8000086c:	494080e7          	jalr	1172(ra) # 80005cfc <panic>

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
    800009b8:	348080e7          	jalr	840(ra) # 80005cfc <panic>
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
    80000a96:	26a080e7          	jalr	618(ra) # 80005cfc <panic>
      panic("uvmcopy: page not present");
    80000a9a:	00007517          	auipc	a0,0x7
    80000a9e:	68e50513          	addi	a0,a0,1678 # 80008128 <etext+0x128>
    80000aa2:	00005097          	auipc	ra,0x5
    80000aa6:	25a080e7          	jalr	602(ra) # 80005cfc <panic>
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
    80000b10:	1f0080e7          	jalr	496(ra) # 80005cfc <panic>

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
    80000cb4:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdca90>
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
    80000d0e:	0000ea17          	auipc	s4,0xe
    80000d12:	242a0a13          	addi	s4,s4,578 # 8000ef50 <tickslock>
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
    80000d48:	18848493          	addi	s1,s1,392
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
    80000d70:	f90080e7          	jalr	-112(ra) # 80005cfc <panic>

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
    80000d9c:	40c080e7          	jalr	1036(ra) # 800061a4 <initlock>
  initlock(&wait_lock, "wait_lock");
    80000da0:	00007597          	auipc	a1,0x7
    80000da4:	3c858593          	addi	a1,a1,968 # 80008168 <etext+0x168>
    80000da8:	00008517          	auipc	a0,0x8
    80000dac:	b9050513          	addi	a0,a0,-1136 # 80008938 <wait_lock>
    80000db0:	00005097          	auipc	ra,0x5
    80000db4:	3f4080e7          	jalr	1012(ra) # 800061a4 <initlock>
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
    80000dda:	0000e997          	auipc	s3,0xe
    80000dde:	17698993          	addi	s3,s3,374 # 8000ef50 <tickslock>
      initlock(&p->lock, "proc");
    80000de2:	85da                	mv	a1,s6
    80000de4:	8526                	mv	a0,s1
    80000de6:	00005097          	auipc	ra,0x5
    80000dea:	3be080e7          	jalr	958(ra) # 800061a4 <initlock>
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
    80000e0c:	18848493          	addi	s1,s1,392
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
    80000e62:	38a080e7          	jalr	906(ra) # 800061e8 <push_off>
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
    80000e7c:	410080e7          	jalr	1040(ra) # 80006288 <pop_off>
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
    80000ea0:	44c080e7          	jalr	1100(ra) # 800062e8 <release>

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
    80000eb2:	c66080e7          	jalr	-922(ra) # 80001b14 <usertrapret>
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
    80000ecc:	afe080e7          	jalr	-1282(ra) # 800029c6 <fsinit>
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
    80000eec:	34c080e7          	jalr	844(ra) # 80006234 <acquire>
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
    80000f06:	3e6080e7          	jalr	998(ra) # 800062e8 <release>
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
    80001012:	6d3c                	ld	a5,88(a0)
    80001014:	c799                	beqz	a5,80001022 <freeproc+0x1c>
    kfree((void*)p->trapframe_copy);
    80001016:	18053503          	ld	a0,384(a0)
    8000101a:	fffff097          	auipc	ra,0xfffff
    8000101e:	002080e7          	jalr	2(ra) # 8000001c <kfree>
  p->trapframe = 0;
    80001022:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001026:	68a8                	ld	a0,80(s1)
    80001028:	c511                	beqz	a0,80001034 <freeproc+0x2e>
    proc_freepagetable(p->pagetable, p->sz);
    8000102a:	64ac                	ld	a1,72(s1)
    8000102c:	00000097          	auipc	ra,0x0
    80001030:	f88080e7          	jalr	-120(ra) # 80000fb4 <proc_freepagetable>
  p->pagetable = 0;
    80001034:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001038:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    8000103c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001040:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001044:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001048:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    8000104c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001050:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001054:	0004ac23          	sw	zero,24(s1)
}
    80001058:	60e2                	ld	ra,24(sp)
    8000105a:	6442                	ld	s0,16(sp)
    8000105c:	64a2                	ld	s1,8(sp)
    8000105e:	6105                	addi	sp,sp,32
    80001060:	8082                	ret

0000000080001062 <allocproc>:
{
    80001062:	1101                	addi	sp,sp,-32
    80001064:	ec06                	sd	ra,24(sp)
    80001066:	e822                	sd	s0,16(sp)
    80001068:	e426                	sd	s1,8(sp)
    8000106a:	e04a                	sd	s2,0(sp)
    8000106c:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    8000106e:	00008497          	auipc	s1,0x8
    80001072:	ce248493          	addi	s1,s1,-798 # 80008d50 <proc>
    80001076:	0000e917          	auipc	s2,0xe
    8000107a:	eda90913          	addi	s2,s2,-294 # 8000ef50 <tickslock>
    acquire(&p->lock);
    8000107e:	8526                	mv	a0,s1
    80001080:	00005097          	auipc	ra,0x5
    80001084:	1b4080e7          	jalr	436(ra) # 80006234 <acquire>
    if(p->state == UNUSED) {
    80001088:	4c9c                	lw	a5,24(s1)
    8000108a:	cf81                	beqz	a5,800010a2 <allocproc+0x40>
      release(&p->lock);
    8000108c:	8526                	mv	a0,s1
    8000108e:	00005097          	auipc	ra,0x5
    80001092:	25a080e7          	jalr	602(ra) # 800062e8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001096:	18848493          	addi	s1,s1,392
    8000109a:	ff2492e3          	bne	s1,s2,8000107e <allocproc+0x1c>
  return 0;
    8000109e:	4481                	li	s1,0
    800010a0:	a08d                	j	80001102 <allocproc+0xa0>
  p->pid = allocpid();
    800010a2:	00000097          	auipc	ra,0x0
    800010a6:	e30080e7          	jalr	-464(ra) # 80000ed2 <allocpid>
    800010aa:	d888                	sw	a0,48(s1)
  p->state = USED;
    800010ac:	4785                	li	a5,1
    800010ae:	cc9c                	sw	a5,24(s1)
  p->is_sigalarm=0;
    800010b0:	1604a823          	sw	zero,368(s1)
  p->alarm_ticks = 0;
    800010b4:	1604a423          	sw	zero,360(s1)
  p->alarm_handler = 0;
    800010b8:	1604bc23          	sd	zero,376(s1)
  p->now_ticks = 0;
    800010bc:	1604a623          	sw	zero,364(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    800010c0:	fffff097          	auipc	ra,0xfffff
    800010c4:	05a080e7          	jalr	90(ra) # 8000011a <kalloc>
    800010c8:	892a                	mv	s2,a0
    800010ca:	eca8                	sd	a0,88(s1)
    800010cc:	c131                	beqz	a0,80001110 <allocproc+0xae>
  p->pagetable = proc_pagetable(p);
    800010ce:	8526                	mv	a0,s1
    800010d0:	00000097          	auipc	ra,0x0
    800010d4:	e48080e7          	jalr	-440(ra) # 80000f18 <proc_pagetable>
    800010d8:	892a                	mv	s2,a0
    800010da:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    800010dc:	c129                	beqz	a0,8000111e <allocproc+0xbc>
  memset(&p->context, 0, sizeof(p->context));
    800010de:	07000613          	li	a2,112
    800010e2:	4581                	li	a1,0
    800010e4:	06048513          	addi	a0,s1,96
    800010e8:	fffff097          	auipc	ra,0xfffff
    800010ec:	092080e7          	jalr	146(ra) # 8000017a <memset>
  p->context.ra = (uint64)forkret;
    800010f0:	00000797          	auipc	a5,0x0
    800010f4:	d9c78793          	addi	a5,a5,-612 # 80000e8c <forkret>
    800010f8:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    800010fa:	60bc                	ld	a5,64(s1)
    800010fc:	6705                	lui	a4,0x1
    800010fe:	97ba                	add	a5,a5,a4
    80001100:	f4bc                	sd	a5,104(s1)
}
    80001102:	8526                	mv	a0,s1
    80001104:	60e2                	ld	ra,24(sp)
    80001106:	6442                	ld	s0,16(sp)
    80001108:	64a2                	ld	s1,8(sp)
    8000110a:	6902                	ld	s2,0(sp)
    8000110c:	6105                	addi	sp,sp,32
    8000110e:	8082                	ret
    release(&p->lock);
    80001110:	8526                	mv	a0,s1
    80001112:	00005097          	auipc	ra,0x5
    80001116:	1d6080e7          	jalr	470(ra) # 800062e8 <release>
    return 0;
    8000111a:	84ca                	mv	s1,s2
    8000111c:	b7dd                	j	80001102 <allocproc+0xa0>
    freeproc(p);
    8000111e:	8526                	mv	a0,s1
    80001120:	00000097          	auipc	ra,0x0
    80001124:	ee6080e7          	jalr	-282(ra) # 80001006 <freeproc>
    release(&p->lock);
    80001128:	8526                	mv	a0,s1
    8000112a:	00005097          	auipc	ra,0x5
    8000112e:	1be080e7          	jalr	446(ra) # 800062e8 <release>
    return 0;
    80001132:	84ca                	mv	s1,s2
    80001134:	b7f9                	j	80001102 <allocproc+0xa0>

0000000080001136 <userinit>:
{
    80001136:	1101                	addi	sp,sp,-32
    80001138:	ec06                	sd	ra,24(sp)
    8000113a:	e822                	sd	s0,16(sp)
    8000113c:	e426                	sd	s1,8(sp)
    8000113e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001140:	00000097          	auipc	ra,0x0
    80001144:	f22080e7          	jalr	-222(ra) # 80001062 <allocproc>
    80001148:	84aa                	mv	s1,a0
  initproc = p;
    8000114a:	00007797          	auipc	a5,0x7
    8000114e:	78a7bb23          	sd	a0,1942(a5) # 800088e0 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001152:	03400613          	li	a2,52
    80001156:	00007597          	auipc	a1,0x7
    8000115a:	71a58593          	addi	a1,a1,1818 # 80008870 <initcode>
    8000115e:	6928                	ld	a0,80(a0)
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	69e080e7          	jalr	1694(ra) # 800007fe <uvmfirst>
  p->sz = PGSIZE;
    80001168:	6785                	lui	a5,0x1
    8000116a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    8000116c:	6cb8                	ld	a4,88(s1)
    8000116e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001172:	6cb8                	ld	a4,88(s1)
    80001174:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001176:	4641                	li	a2,16
    80001178:	00007597          	auipc	a1,0x7
    8000117c:	00858593          	addi	a1,a1,8 # 80008180 <etext+0x180>
    80001180:	15848513          	addi	a0,s1,344
    80001184:	fffff097          	auipc	ra,0xfffff
    80001188:	140080e7          	jalr	320(ra) # 800002c4 <safestrcpy>
  p->cwd = namei("/");
    8000118c:	00007517          	auipc	a0,0x7
    80001190:	00450513          	addi	a0,a0,4 # 80008190 <etext+0x190>
    80001194:	00002097          	auipc	ra,0x2
    80001198:	25c080e7          	jalr	604(ra) # 800033f0 <namei>
    8000119c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    800011a0:	478d                	li	a5,3
    800011a2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    800011a4:	8526                	mv	a0,s1
    800011a6:	00005097          	auipc	ra,0x5
    800011aa:	142080e7          	jalr	322(ra) # 800062e8 <release>
}
    800011ae:	60e2                	ld	ra,24(sp)
    800011b0:	6442                	ld	s0,16(sp)
    800011b2:	64a2                	ld	s1,8(sp)
    800011b4:	6105                	addi	sp,sp,32
    800011b6:	8082                	ret

00000000800011b8 <growproc>:
{
    800011b8:	1101                	addi	sp,sp,-32
    800011ba:	ec06                	sd	ra,24(sp)
    800011bc:	e822                	sd	s0,16(sp)
    800011be:	e426                	sd	s1,8(sp)
    800011c0:	e04a                	sd	s2,0(sp)
    800011c2:	1000                	addi	s0,sp,32
    800011c4:	892a                	mv	s2,a0
  struct proc *p = myproc();
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	c8e080e7          	jalr	-882(ra) # 80000e54 <myproc>
    800011ce:	84aa                	mv	s1,a0
  sz = p->sz;
    800011d0:	652c                	ld	a1,72(a0)
  if(n > 0){
    800011d2:	01204c63          	bgtz	s2,800011ea <growproc+0x32>
  } else if(n < 0){
    800011d6:	02094663          	bltz	s2,80001202 <growproc+0x4a>
  p->sz = sz;
    800011da:	e4ac                	sd	a1,72(s1)
  return 0;
    800011dc:	4501                	li	a0,0
}
    800011de:	60e2                	ld	ra,24(sp)
    800011e0:	6442                	ld	s0,16(sp)
    800011e2:	64a2                	ld	s1,8(sp)
    800011e4:	6902                	ld	s2,0(sp)
    800011e6:	6105                	addi	sp,sp,32
    800011e8:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    800011ea:	4691                	li	a3,4
    800011ec:	00b90633          	add	a2,s2,a1
    800011f0:	6928                	ld	a0,80(a0)
    800011f2:	fffff097          	auipc	ra,0xfffff
    800011f6:	6c6080e7          	jalr	1734(ra) # 800008b8 <uvmalloc>
    800011fa:	85aa                	mv	a1,a0
    800011fc:	fd79                	bnez	a0,800011da <growproc+0x22>
      return -1;
    800011fe:	557d                	li	a0,-1
    80001200:	bff9                	j	800011de <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001202:	00b90633          	add	a2,s2,a1
    80001206:	6928                	ld	a0,80(a0)
    80001208:	fffff097          	auipc	ra,0xfffff
    8000120c:	668080e7          	jalr	1640(ra) # 80000870 <uvmdealloc>
    80001210:	85aa                	mv	a1,a0
    80001212:	b7e1                	j	800011da <growproc+0x22>

0000000080001214 <fork>:
{
    80001214:	7139                	addi	sp,sp,-64
    80001216:	fc06                	sd	ra,56(sp)
    80001218:	f822                	sd	s0,48(sp)
    8000121a:	f426                	sd	s1,40(sp)
    8000121c:	f04a                	sd	s2,32(sp)
    8000121e:	ec4e                	sd	s3,24(sp)
    80001220:	e852                	sd	s4,16(sp)
    80001222:	e456                	sd	s5,8(sp)
    80001224:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	c2e080e7          	jalr	-978(ra) # 80000e54 <myproc>
    8000122e:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001230:	00000097          	auipc	ra,0x0
    80001234:	e32080e7          	jalr	-462(ra) # 80001062 <allocproc>
    80001238:	10050c63          	beqz	a0,80001350 <fork+0x13c>
    8000123c:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    8000123e:	048ab603          	ld	a2,72(s5)
    80001242:	692c                	ld	a1,80(a0)
    80001244:	050ab503          	ld	a0,80(s5)
    80001248:	fffff097          	auipc	ra,0xfffff
    8000124c:	7c8080e7          	jalr	1992(ra) # 80000a10 <uvmcopy>
    80001250:	04054863          	bltz	a0,800012a0 <fork+0x8c>
  np->sz = p->sz;
    80001254:	048ab783          	ld	a5,72(s5)
    80001258:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    8000125c:	058ab683          	ld	a3,88(s5)
    80001260:	87b6                	mv	a5,a3
    80001262:	058a3703          	ld	a4,88(s4)
    80001266:	12068693          	addi	a3,a3,288
    8000126a:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    8000126e:	6788                	ld	a0,8(a5)
    80001270:	6b8c                	ld	a1,16(a5)
    80001272:	6f90                	ld	a2,24(a5)
    80001274:	01073023          	sd	a6,0(a4)
    80001278:	e708                	sd	a0,8(a4)
    8000127a:	eb0c                	sd	a1,16(a4)
    8000127c:	ef10                	sd	a2,24(a4)
    8000127e:	02078793          	addi	a5,a5,32
    80001282:	02070713          	addi	a4,a4,32
    80001286:	fed792e3          	bne	a5,a3,8000126a <fork+0x56>
  np->trapframe->a0 = 0;
    8000128a:	058a3783          	ld	a5,88(s4)
    8000128e:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001292:	0d0a8493          	addi	s1,s5,208
    80001296:	0d0a0913          	addi	s2,s4,208
    8000129a:	150a8993          	addi	s3,s5,336
    8000129e:	a00d                	j	800012c0 <fork+0xac>
    freeproc(np);
    800012a0:	8552                	mv	a0,s4
    800012a2:	00000097          	auipc	ra,0x0
    800012a6:	d64080e7          	jalr	-668(ra) # 80001006 <freeproc>
    release(&np->lock);
    800012aa:	8552                	mv	a0,s4
    800012ac:	00005097          	auipc	ra,0x5
    800012b0:	03c080e7          	jalr	60(ra) # 800062e8 <release>
    return -1;
    800012b4:	597d                	li	s2,-1
    800012b6:	a059                	j	8000133c <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    800012b8:	04a1                	addi	s1,s1,8
    800012ba:	0921                	addi	s2,s2,8
    800012bc:	01348b63          	beq	s1,s3,800012d2 <fork+0xbe>
    if(p->ofile[i])
    800012c0:	6088                	ld	a0,0(s1)
    800012c2:	d97d                	beqz	a0,800012b8 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    800012c4:	00002097          	auipc	ra,0x2
    800012c8:	7c2080e7          	jalr	1986(ra) # 80003a86 <filedup>
    800012cc:	00a93023          	sd	a0,0(s2)
    800012d0:	b7e5                	j	800012b8 <fork+0xa4>
  np->cwd = idup(p->cwd);
    800012d2:	150ab503          	ld	a0,336(s5)
    800012d6:	00002097          	auipc	ra,0x2
    800012da:	930080e7          	jalr	-1744(ra) # 80002c06 <idup>
    800012de:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800012e2:	4641                	li	a2,16
    800012e4:	158a8593          	addi	a1,s5,344
    800012e8:	158a0513          	addi	a0,s4,344
    800012ec:	fffff097          	auipc	ra,0xfffff
    800012f0:	fd8080e7          	jalr	-40(ra) # 800002c4 <safestrcpy>
  pid = np->pid;
    800012f4:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    800012f8:	8552                	mv	a0,s4
    800012fa:	00005097          	auipc	ra,0x5
    800012fe:	fee080e7          	jalr	-18(ra) # 800062e8 <release>
  acquire(&wait_lock);
    80001302:	00007497          	auipc	s1,0x7
    80001306:	63648493          	addi	s1,s1,1590 # 80008938 <wait_lock>
    8000130a:	8526                	mv	a0,s1
    8000130c:	00005097          	auipc	ra,0x5
    80001310:	f28080e7          	jalr	-216(ra) # 80006234 <acquire>
  np->parent = p;
    80001314:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001318:	8526                	mv	a0,s1
    8000131a:	00005097          	auipc	ra,0x5
    8000131e:	fce080e7          	jalr	-50(ra) # 800062e8 <release>
  acquire(&np->lock);
    80001322:	8552                	mv	a0,s4
    80001324:	00005097          	auipc	ra,0x5
    80001328:	f10080e7          	jalr	-240(ra) # 80006234 <acquire>
  np->state = RUNNABLE;
    8000132c:	478d                	li	a5,3
    8000132e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001332:	8552                	mv	a0,s4
    80001334:	00005097          	auipc	ra,0x5
    80001338:	fb4080e7          	jalr	-76(ra) # 800062e8 <release>
}
    8000133c:	854a                	mv	a0,s2
    8000133e:	70e2                	ld	ra,56(sp)
    80001340:	7442                	ld	s0,48(sp)
    80001342:	74a2                	ld	s1,40(sp)
    80001344:	7902                	ld	s2,32(sp)
    80001346:	69e2                	ld	s3,24(sp)
    80001348:	6a42                	ld	s4,16(sp)
    8000134a:	6aa2                	ld	s5,8(sp)
    8000134c:	6121                	addi	sp,sp,64
    8000134e:	8082                	ret
    return -1;
    80001350:	597d                	li	s2,-1
    80001352:	b7ed                	j	8000133c <fork+0x128>

0000000080001354 <scheduler>:
{
    80001354:	7139                	addi	sp,sp,-64
    80001356:	fc06                	sd	ra,56(sp)
    80001358:	f822                	sd	s0,48(sp)
    8000135a:	f426                	sd	s1,40(sp)
    8000135c:	f04a                	sd	s2,32(sp)
    8000135e:	ec4e                	sd	s3,24(sp)
    80001360:	e852                	sd	s4,16(sp)
    80001362:	e456                	sd	s5,8(sp)
    80001364:	e05a                	sd	s6,0(sp)
    80001366:	0080                	addi	s0,sp,64
    80001368:	8792                	mv	a5,tp
  int id = r_tp();
    8000136a:	2781                	sext.w	a5,a5
  c->proc = 0;
    8000136c:	00779a93          	slli	s5,a5,0x7
    80001370:	00007717          	auipc	a4,0x7
    80001374:	5b070713          	addi	a4,a4,1456 # 80008920 <pid_lock>
    80001378:	9756                	add	a4,a4,s5
    8000137a:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000137e:	00007717          	auipc	a4,0x7
    80001382:	5da70713          	addi	a4,a4,1498 # 80008958 <cpus+0x8>
    80001386:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001388:	498d                	li	s3,3
        p->state = RUNNING;
    8000138a:	4b11                	li	s6,4
        c->proc = p;
    8000138c:	079e                	slli	a5,a5,0x7
    8000138e:	00007a17          	auipc	s4,0x7
    80001392:	592a0a13          	addi	s4,s4,1426 # 80008920 <pid_lock>
    80001396:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001398:	0000e917          	auipc	s2,0xe
    8000139c:	bb890913          	addi	s2,s2,-1096 # 8000ef50 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800013a0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800013a4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800013a8:	10079073          	csrw	sstatus,a5
    800013ac:	00008497          	auipc	s1,0x8
    800013b0:	9a448493          	addi	s1,s1,-1628 # 80008d50 <proc>
    800013b4:	a811                	j	800013c8 <scheduler+0x74>
      release(&p->lock);
    800013b6:	8526                	mv	a0,s1
    800013b8:	00005097          	auipc	ra,0x5
    800013bc:	f30080e7          	jalr	-208(ra) # 800062e8 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800013c0:	18848493          	addi	s1,s1,392
    800013c4:	fd248ee3          	beq	s1,s2,800013a0 <scheduler+0x4c>
      acquire(&p->lock);
    800013c8:	8526                	mv	a0,s1
    800013ca:	00005097          	auipc	ra,0x5
    800013ce:	e6a080e7          	jalr	-406(ra) # 80006234 <acquire>
      if(p->state == RUNNABLE) {
    800013d2:	4c9c                	lw	a5,24(s1)
    800013d4:	ff3791e3          	bne	a5,s3,800013b6 <scheduler+0x62>
        p->state = RUNNING;
    800013d8:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    800013dc:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    800013e0:	06048593          	addi	a1,s1,96
    800013e4:	8556                	mv	a0,s5
    800013e6:	00000097          	auipc	ra,0x0
    800013ea:	684080e7          	jalr	1668(ra) # 80001a6a <swtch>
        c->proc = 0;
    800013ee:	020a3823          	sd	zero,48(s4)
    800013f2:	b7d1                	j	800013b6 <scheduler+0x62>

00000000800013f4 <sched>:
{
    800013f4:	7179                	addi	sp,sp,-48
    800013f6:	f406                	sd	ra,40(sp)
    800013f8:	f022                	sd	s0,32(sp)
    800013fa:	ec26                	sd	s1,24(sp)
    800013fc:	e84a                	sd	s2,16(sp)
    800013fe:	e44e                	sd	s3,8(sp)
    80001400:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001402:	00000097          	auipc	ra,0x0
    80001406:	a52080e7          	jalr	-1454(ra) # 80000e54 <myproc>
    8000140a:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000140c:	00005097          	auipc	ra,0x5
    80001410:	dae080e7          	jalr	-594(ra) # 800061ba <holding>
    80001414:	c93d                	beqz	a0,8000148a <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001416:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001418:	2781                	sext.w	a5,a5
    8000141a:	079e                	slli	a5,a5,0x7
    8000141c:	00007717          	auipc	a4,0x7
    80001420:	50470713          	addi	a4,a4,1284 # 80008920 <pid_lock>
    80001424:	97ba                	add	a5,a5,a4
    80001426:	0a87a703          	lw	a4,168(a5)
    8000142a:	4785                	li	a5,1
    8000142c:	06f71763          	bne	a4,a5,8000149a <sched+0xa6>
  if(p->state == RUNNING)
    80001430:	4c98                	lw	a4,24(s1)
    80001432:	4791                	li	a5,4
    80001434:	06f70b63          	beq	a4,a5,800014aa <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001438:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000143c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000143e:	efb5                	bnez	a5,800014ba <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001440:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001442:	00007917          	auipc	s2,0x7
    80001446:	4de90913          	addi	s2,s2,1246 # 80008920 <pid_lock>
    8000144a:	2781                	sext.w	a5,a5
    8000144c:	079e                	slli	a5,a5,0x7
    8000144e:	97ca                	add	a5,a5,s2
    80001450:	0ac7a983          	lw	s3,172(a5)
    80001454:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001456:	2781                	sext.w	a5,a5
    80001458:	079e                	slli	a5,a5,0x7
    8000145a:	00007597          	auipc	a1,0x7
    8000145e:	4fe58593          	addi	a1,a1,1278 # 80008958 <cpus+0x8>
    80001462:	95be                	add	a1,a1,a5
    80001464:	06048513          	addi	a0,s1,96
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	602080e7          	jalr	1538(ra) # 80001a6a <swtch>
    80001470:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001472:	2781                	sext.w	a5,a5
    80001474:	079e                	slli	a5,a5,0x7
    80001476:	993e                	add	s2,s2,a5
    80001478:	0b392623          	sw	s3,172(s2)
}
    8000147c:	70a2                	ld	ra,40(sp)
    8000147e:	7402                	ld	s0,32(sp)
    80001480:	64e2                	ld	s1,24(sp)
    80001482:	6942                	ld	s2,16(sp)
    80001484:	69a2                	ld	s3,8(sp)
    80001486:	6145                	addi	sp,sp,48
    80001488:	8082                	ret
    panic("sched p->lock");
    8000148a:	00007517          	auipc	a0,0x7
    8000148e:	d0e50513          	addi	a0,a0,-754 # 80008198 <etext+0x198>
    80001492:	00005097          	auipc	ra,0x5
    80001496:	86a080e7          	jalr	-1942(ra) # 80005cfc <panic>
    panic("sched locks");
    8000149a:	00007517          	auipc	a0,0x7
    8000149e:	d0e50513          	addi	a0,a0,-754 # 800081a8 <etext+0x1a8>
    800014a2:	00005097          	auipc	ra,0x5
    800014a6:	85a080e7          	jalr	-1958(ra) # 80005cfc <panic>
    panic("sched running");
    800014aa:	00007517          	auipc	a0,0x7
    800014ae:	d0e50513          	addi	a0,a0,-754 # 800081b8 <etext+0x1b8>
    800014b2:	00005097          	auipc	ra,0x5
    800014b6:	84a080e7          	jalr	-1974(ra) # 80005cfc <panic>
    panic("sched interruptible");
    800014ba:	00007517          	auipc	a0,0x7
    800014be:	d0e50513          	addi	a0,a0,-754 # 800081c8 <etext+0x1c8>
    800014c2:	00005097          	auipc	ra,0x5
    800014c6:	83a080e7          	jalr	-1990(ra) # 80005cfc <panic>

00000000800014ca <yield>:
{
    800014ca:	1101                	addi	sp,sp,-32
    800014cc:	ec06                	sd	ra,24(sp)
    800014ce:	e822                	sd	s0,16(sp)
    800014d0:	e426                	sd	s1,8(sp)
    800014d2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800014d4:	00000097          	auipc	ra,0x0
    800014d8:	980080e7          	jalr	-1664(ra) # 80000e54 <myproc>
    800014dc:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800014de:	00005097          	auipc	ra,0x5
    800014e2:	d56080e7          	jalr	-682(ra) # 80006234 <acquire>
  p->state = RUNNABLE;
    800014e6:	478d                	li	a5,3
    800014e8:	cc9c                	sw	a5,24(s1)
  sched();
    800014ea:	00000097          	auipc	ra,0x0
    800014ee:	f0a080e7          	jalr	-246(ra) # 800013f4 <sched>
  release(&p->lock);
    800014f2:	8526                	mv	a0,s1
    800014f4:	00005097          	auipc	ra,0x5
    800014f8:	df4080e7          	jalr	-524(ra) # 800062e8 <release>
}
    800014fc:	60e2                	ld	ra,24(sp)
    800014fe:	6442                	ld	s0,16(sp)
    80001500:	64a2                	ld	s1,8(sp)
    80001502:	6105                	addi	sp,sp,32
    80001504:	8082                	ret

0000000080001506 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001506:	7179                	addi	sp,sp,-48
    80001508:	f406                	sd	ra,40(sp)
    8000150a:	f022                	sd	s0,32(sp)
    8000150c:	ec26                	sd	s1,24(sp)
    8000150e:	e84a                	sd	s2,16(sp)
    80001510:	e44e                	sd	s3,8(sp)
    80001512:	1800                	addi	s0,sp,48
    80001514:	89aa                	mv	s3,a0
    80001516:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001518:	00000097          	auipc	ra,0x0
    8000151c:	93c080e7          	jalr	-1732(ra) # 80000e54 <myproc>
    80001520:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001522:	00005097          	auipc	ra,0x5
    80001526:	d12080e7          	jalr	-750(ra) # 80006234 <acquire>
  release(lk);
    8000152a:	854a                	mv	a0,s2
    8000152c:	00005097          	auipc	ra,0x5
    80001530:	dbc080e7          	jalr	-580(ra) # 800062e8 <release>

  // Go to sleep.
  p->chan = chan;
    80001534:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001538:	4789                	li	a5,2
    8000153a:	cc9c                	sw	a5,24(s1)

  sched();
    8000153c:	00000097          	auipc	ra,0x0
    80001540:	eb8080e7          	jalr	-328(ra) # 800013f4 <sched>

  // Tidy up.
  p->chan = 0;
    80001544:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001548:	8526                	mv	a0,s1
    8000154a:	00005097          	auipc	ra,0x5
    8000154e:	d9e080e7          	jalr	-610(ra) # 800062e8 <release>
  acquire(lk);
    80001552:	854a                	mv	a0,s2
    80001554:	00005097          	auipc	ra,0x5
    80001558:	ce0080e7          	jalr	-800(ra) # 80006234 <acquire>
}
    8000155c:	70a2                	ld	ra,40(sp)
    8000155e:	7402                	ld	s0,32(sp)
    80001560:	64e2                	ld	s1,24(sp)
    80001562:	6942                	ld	s2,16(sp)
    80001564:	69a2                	ld	s3,8(sp)
    80001566:	6145                	addi	sp,sp,48
    80001568:	8082                	ret

000000008000156a <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    8000156a:	7139                	addi	sp,sp,-64
    8000156c:	fc06                	sd	ra,56(sp)
    8000156e:	f822                	sd	s0,48(sp)
    80001570:	f426                	sd	s1,40(sp)
    80001572:	f04a                	sd	s2,32(sp)
    80001574:	ec4e                	sd	s3,24(sp)
    80001576:	e852                	sd	s4,16(sp)
    80001578:	e456                	sd	s5,8(sp)
    8000157a:	0080                	addi	s0,sp,64
    8000157c:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000157e:	00007497          	auipc	s1,0x7
    80001582:	7d248493          	addi	s1,s1,2002 # 80008d50 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001586:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001588:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    8000158a:	0000e917          	auipc	s2,0xe
    8000158e:	9c690913          	addi	s2,s2,-1594 # 8000ef50 <tickslock>
    80001592:	a811                	j	800015a6 <wakeup+0x3c>
      }
      release(&p->lock);
    80001594:	8526                	mv	a0,s1
    80001596:	00005097          	auipc	ra,0x5
    8000159a:	d52080e7          	jalr	-686(ra) # 800062e8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000159e:	18848493          	addi	s1,s1,392
    800015a2:	03248663          	beq	s1,s2,800015ce <wakeup+0x64>
    if(p != myproc()){
    800015a6:	00000097          	auipc	ra,0x0
    800015aa:	8ae080e7          	jalr	-1874(ra) # 80000e54 <myproc>
    800015ae:	fea488e3          	beq	s1,a0,8000159e <wakeup+0x34>
      acquire(&p->lock);
    800015b2:	8526                	mv	a0,s1
    800015b4:	00005097          	auipc	ra,0x5
    800015b8:	c80080e7          	jalr	-896(ra) # 80006234 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800015bc:	4c9c                	lw	a5,24(s1)
    800015be:	fd379be3          	bne	a5,s3,80001594 <wakeup+0x2a>
    800015c2:	709c                	ld	a5,32(s1)
    800015c4:	fd4798e3          	bne	a5,s4,80001594 <wakeup+0x2a>
        p->state = RUNNABLE;
    800015c8:	0154ac23          	sw	s5,24(s1)
    800015cc:	b7e1                	j	80001594 <wakeup+0x2a>
    }
  }
}
    800015ce:	70e2                	ld	ra,56(sp)
    800015d0:	7442                	ld	s0,48(sp)
    800015d2:	74a2                	ld	s1,40(sp)
    800015d4:	7902                	ld	s2,32(sp)
    800015d6:	69e2                	ld	s3,24(sp)
    800015d8:	6a42                	ld	s4,16(sp)
    800015da:	6aa2                	ld	s5,8(sp)
    800015dc:	6121                	addi	sp,sp,64
    800015de:	8082                	ret

00000000800015e0 <reparent>:
{
    800015e0:	7179                	addi	sp,sp,-48
    800015e2:	f406                	sd	ra,40(sp)
    800015e4:	f022                	sd	s0,32(sp)
    800015e6:	ec26                	sd	s1,24(sp)
    800015e8:	e84a                	sd	s2,16(sp)
    800015ea:	e44e                	sd	s3,8(sp)
    800015ec:	e052                	sd	s4,0(sp)
    800015ee:	1800                	addi	s0,sp,48
    800015f0:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800015f2:	00007497          	auipc	s1,0x7
    800015f6:	75e48493          	addi	s1,s1,1886 # 80008d50 <proc>
      pp->parent = initproc;
    800015fa:	00007a17          	auipc	s4,0x7
    800015fe:	2e6a0a13          	addi	s4,s4,742 # 800088e0 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001602:	0000e997          	auipc	s3,0xe
    80001606:	94e98993          	addi	s3,s3,-1714 # 8000ef50 <tickslock>
    8000160a:	a029                	j	80001614 <reparent+0x34>
    8000160c:	18848493          	addi	s1,s1,392
    80001610:	01348d63          	beq	s1,s3,8000162a <reparent+0x4a>
    if(pp->parent == p){
    80001614:	7c9c                	ld	a5,56(s1)
    80001616:	ff279be3          	bne	a5,s2,8000160c <reparent+0x2c>
      pp->parent = initproc;
    8000161a:	000a3503          	ld	a0,0(s4)
    8000161e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80001620:	00000097          	auipc	ra,0x0
    80001624:	f4a080e7          	jalr	-182(ra) # 8000156a <wakeup>
    80001628:	b7d5                	j	8000160c <reparent+0x2c>
}
    8000162a:	70a2                	ld	ra,40(sp)
    8000162c:	7402                	ld	s0,32(sp)
    8000162e:	64e2                	ld	s1,24(sp)
    80001630:	6942                	ld	s2,16(sp)
    80001632:	69a2                	ld	s3,8(sp)
    80001634:	6a02                	ld	s4,0(sp)
    80001636:	6145                	addi	sp,sp,48
    80001638:	8082                	ret

000000008000163a <exit>:
{
    8000163a:	7179                	addi	sp,sp,-48
    8000163c:	f406                	sd	ra,40(sp)
    8000163e:	f022                	sd	s0,32(sp)
    80001640:	ec26                	sd	s1,24(sp)
    80001642:	e84a                	sd	s2,16(sp)
    80001644:	e44e                	sd	s3,8(sp)
    80001646:	e052                	sd	s4,0(sp)
    80001648:	1800                	addi	s0,sp,48
    8000164a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000164c:	00000097          	auipc	ra,0x0
    80001650:	808080e7          	jalr	-2040(ra) # 80000e54 <myproc>
    80001654:	89aa                	mv	s3,a0
  if(p == initproc)
    80001656:	00007797          	auipc	a5,0x7
    8000165a:	28a7b783          	ld	a5,650(a5) # 800088e0 <initproc>
    8000165e:	0d050493          	addi	s1,a0,208
    80001662:	15050913          	addi	s2,a0,336
    80001666:	02a79363          	bne	a5,a0,8000168c <exit+0x52>
    panic("init exiting");
    8000166a:	00007517          	auipc	a0,0x7
    8000166e:	b7650513          	addi	a0,a0,-1162 # 800081e0 <etext+0x1e0>
    80001672:	00004097          	auipc	ra,0x4
    80001676:	68a080e7          	jalr	1674(ra) # 80005cfc <panic>
      fileclose(f);
    8000167a:	00002097          	auipc	ra,0x2
    8000167e:	45e080e7          	jalr	1118(ra) # 80003ad8 <fileclose>
      p->ofile[fd] = 0;
    80001682:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001686:	04a1                	addi	s1,s1,8
    80001688:	01248563          	beq	s1,s2,80001692 <exit+0x58>
    if(p->ofile[fd]){
    8000168c:	6088                	ld	a0,0(s1)
    8000168e:	f575                	bnez	a0,8000167a <exit+0x40>
    80001690:	bfdd                	j	80001686 <exit+0x4c>
  begin_op();
    80001692:	00002097          	auipc	ra,0x2
    80001696:	f7e080e7          	jalr	-130(ra) # 80003610 <begin_op>
  iput(p->cwd);
    8000169a:	1509b503          	ld	a0,336(s3)
    8000169e:	00001097          	auipc	ra,0x1
    800016a2:	760080e7          	jalr	1888(ra) # 80002dfe <iput>
  end_op();
    800016a6:	00002097          	auipc	ra,0x2
    800016aa:	fe8080e7          	jalr	-24(ra) # 8000368e <end_op>
  p->cwd = 0;
    800016ae:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800016b2:	00007497          	auipc	s1,0x7
    800016b6:	28648493          	addi	s1,s1,646 # 80008938 <wait_lock>
    800016ba:	8526                	mv	a0,s1
    800016bc:	00005097          	auipc	ra,0x5
    800016c0:	b78080e7          	jalr	-1160(ra) # 80006234 <acquire>
  reparent(p);
    800016c4:	854e                	mv	a0,s3
    800016c6:	00000097          	auipc	ra,0x0
    800016ca:	f1a080e7          	jalr	-230(ra) # 800015e0 <reparent>
  wakeup(p->parent);
    800016ce:	0389b503          	ld	a0,56(s3)
    800016d2:	00000097          	auipc	ra,0x0
    800016d6:	e98080e7          	jalr	-360(ra) # 8000156a <wakeup>
  acquire(&p->lock);
    800016da:	854e                	mv	a0,s3
    800016dc:	00005097          	auipc	ra,0x5
    800016e0:	b58080e7          	jalr	-1192(ra) # 80006234 <acquire>
  p->xstate = status;
    800016e4:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800016e8:	4795                	li	a5,5
    800016ea:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800016ee:	8526                	mv	a0,s1
    800016f0:	00005097          	auipc	ra,0x5
    800016f4:	bf8080e7          	jalr	-1032(ra) # 800062e8 <release>
  sched();
    800016f8:	00000097          	auipc	ra,0x0
    800016fc:	cfc080e7          	jalr	-772(ra) # 800013f4 <sched>
  panic("zombie exit");
    80001700:	00007517          	auipc	a0,0x7
    80001704:	af050513          	addi	a0,a0,-1296 # 800081f0 <etext+0x1f0>
    80001708:	00004097          	auipc	ra,0x4
    8000170c:	5f4080e7          	jalr	1524(ra) # 80005cfc <panic>

0000000080001710 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80001710:	7179                	addi	sp,sp,-48
    80001712:	f406                	sd	ra,40(sp)
    80001714:	f022                	sd	s0,32(sp)
    80001716:	ec26                	sd	s1,24(sp)
    80001718:	e84a                	sd	s2,16(sp)
    8000171a:	e44e                	sd	s3,8(sp)
    8000171c:	1800                	addi	s0,sp,48
    8000171e:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80001720:	00007497          	auipc	s1,0x7
    80001724:	63048493          	addi	s1,s1,1584 # 80008d50 <proc>
    80001728:	0000e997          	auipc	s3,0xe
    8000172c:	82898993          	addi	s3,s3,-2008 # 8000ef50 <tickslock>
    acquire(&p->lock);
    80001730:	8526                	mv	a0,s1
    80001732:	00005097          	auipc	ra,0x5
    80001736:	b02080e7          	jalr	-1278(ra) # 80006234 <acquire>
    if(p->pid == pid){
    8000173a:	589c                	lw	a5,48(s1)
    8000173c:	01278d63          	beq	a5,s2,80001756 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80001740:	8526                	mv	a0,s1
    80001742:	00005097          	auipc	ra,0x5
    80001746:	ba6080e7          	jalr	-1114(ra) # 800062e8 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000174a:	18848493          	addi	s1,s1,392
    8000174e:	ff3491e3          	bne	s1,s3,80001730 <kill+0x20>
  }
  return -1;
    80001752:	557d                	li	a0,-1
    80001754:	a829                	j	8000176e <kill+0x5e>
      p->killed = 1;
    80001756:	4785                	li	a5,1
    80001758:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000175a:	4c98                	lw	a4,24(s1)
    8000175c:	4789                	li	a5,2
    8000175e:	00f70f63          	beq	a4,a5,8000177c <kill+0x6c>
      release(&p->lock);
    80001762:	8526                	mv	a0,s1
    80001764:	00005097          	auipc	ra,0x5
    80001768:	b84080e7          	jalr	-1148(ra) # 800062e8 <release>
      return 0;
    8000176c:	4501                	li	a0,0
}
    8000176e:	70a2                	ld	ra,40(sp)
    80001770:	7402                	ld	s0,32(sp)
    80001772:	64e2                	ld	s1,24(sp)
    80001774:	6942                	ld	s2,16(sp)
    80001776:	69a2                	ld	s3,8(sp)
    80001778:	6145                	addi	sp,sp,48
    8000177a:	8082                	ret
        p->state = RUNNABLE;
    8000177c:	478d                	li	a5,3
    8000177e:	cc9c                	sw	a5,24(s1)
    80001780:	b7cd                	j	80001762 <kill+0x52>

0000000080001782 <setkilled>:

void
setkilled(struct proc *p)
{
    80001782:	1101                	addi	sp,sp,-32
    80001784:	ec06                	sd	ra,24(sp)
    80001786:	e822                	sd	s0,16(sp)
    80001788:	e426                	sd	s1,8(sp)
    8000178a:	1000                	addi	s0,sp,32
    8000178c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000178e:	00005097          	auipc	ra,0x5
    80001792:	aa6080e7          	jalr	-1370(ra) # 80006234 <acquire>
  p->killed = 1;
    80001796:	4785                	li	a5,1
    80001798:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000179a:	8526                	mv	a0,s1
    8000179c:	00005097          	auipc	ra,0x5
    800017a0:	b4c080e7          	jalr	-1204(ra) # 800062e8 <release>
}
    800017a4:	60e2                	ld	ra,24(sp)
    800017a6:	6442                	ld	s0,16(sp)
    800017a8:	64a2                	ld	s1,8(sp)
    800017aa:	6105                	addi	sp,sp,32
    800017ac:	8082                	ret

00000000800017ae <killed>:

int
killed(struct proc *p)
{
    800017ae:	1101                	addi	sp,sp,-32
    800017b0:	ec06                	sd	ra,24(sp)
    800017b2:	e822                	sd	s0,16(sp)
    800017b4:	e426                	sd	s1,8(sp)
    800017b6:	e04a                	sd	s2,0(sp)
    800017b8:	1000                	addi	s0,sp,32
    800017ba:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800017bc:	00005097          	auipc	ra,0x5
    800017c0:	a78080e7          	jalr	-1416(ra) # 80006234 <acquire>
  k = p->killed;
    800017c4:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800017c8:	8526                	mv	a0,s1
    800017ca:	00005097          	auipc	ra,0x5
    800017ce:	b1e080e7          	jalr	-1250(ra) # 800062e8 <release>
  return k;
}
    800017d2:	854a                	mv	a0,s2
    800017d4:	60e2                	ld	ra,24(sp)
    800017d6:	6442                	ld	s0,16(sp)
    800017d8:	64a2                	ld	s1,8(sp)
    800017da:	6902                	ld	s2,0(sp)
    800017dc:	6105                	addi	sp,sp,32
    800017de:	8082                	ret

00000000800017e0 <wait>:
{
    800017e0:	715d                	addi	sp,sp,-80
    800017e2:	e486                	sd	ra,72(sp)
    800017e4:	e0a2                	sd	s0,64(sp)
    800017e6:	fc26                	sd	s1,56(sp)
    800017e8:	f84a                	sd	s2,48(sp)
    800017ea:	f44e                	sd	s3,40(sp)
    800017ec:	f052                	sd	s4,32(sp)
    800017ee:	ec56                	sd	s5,24(sp)
    800017f0:	e85a                	sd	s6,16(sp)
    800017f2:	e45e                	sd	s7,8(sp)
    800017f4:	e062                	sd	s8,0(sp)
    800017f6:	0880                	addi	s0,sp,80
    800017f8:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800017fa:	fffff097          	auipc	ra,0xfffff
    800017fe:	65a080e7          	jalr	1626(ra) # 80000e54 <myproc>
    80001802:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001804:	00007517          	auipc	a0,0x7
    80001808:	13450513          	addi	a0,a0,308 # 80008938 <wait_lock>
    8000180c:	00005097          	auipc	ra,0x5
    80001810:	a28080e7          	jalr	-1496(ra) # 80006234 <acquire>
    havekids = 0;
    80001814:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001816:	4a15                	li	s4,5
        havekids = 1;
    80001818:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000181a:	0000d997          	auipc	s3,0xd
    8000181e:	73698993          	addi	s3,s3,1846 # 8000ef50 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001822:	00007c17          	auipc	s8,0x7
    80001826:	116c0c13          	addi	s8,s8,278 # 80008938 <wait_lock>
    havekids = 0;
    8000182a:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000182c:	00007497          	auipc	s1,0x7
    80001830:	52448493          	addi	s1,s1,1316 # 80008d50 <proc>
    80001834:	a0bd                	j	800018a2 <wait+0xc2>
          pid = pp->pid;
    80001836:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000183a:	000b0e63          	beqz	s6,80001856 <wait+0x76>
    8000183e:	4691                	li	a3,4
    80001840:	02c48613          	addi	a2,s1,44
    80001844:	85da                	mv	a1,s6
    80001846:	05093503          	ld	a0,80(s2)
    8000184a:	fffff097          	auipc	ra,0xfffff
    8000184e:	2ca080e7          	jalr	714(ra) # 80000b14 <copyout>
    80001852:	02054563          	bltz	a0,8000187c <wait+0x9c>
          freeproc(pp);
    80001856:	8526                	mv	a0,s1
    80001858:	fffff097          	auipc	ra,0xfffff
    8000185c:	7ae080e7          	jalr	1966(ra) # 80001006 <freeproc>
          release(&pp->lock);
    80001860:	8526                	mv	a0,s1
    80001862:	00005097          	auipc	ra,0x5
    80001866:	a86080e7          	jalr	-1402(ra) # 800062e8 <release>
          release(&wait_lock);
    8000186a:	00007517          	auipc	a0,0x7
    8000186e:	0ce50513          	addi	a0,a0,206 # 80008938 <wait_lock>
    80001872:	00005097          	auipc	ra,0x5
    80001876:	a76080e7          	jalr	-1418(ra) # 800062e8 <release>
          return pid;
    8000187a:	a0b5                	j	800018e6 <wait+0x106>
            release(&pp->lock);
    8000187c:	8526                	mv	a0,s1
    8000187e:	00005097          	auipc	ra,0x5
    80001882:	a6a080e7          	jalr	-1430(ra) # 800062e8 <release>
            release(&wait_lock);
    80001886:	00007517          	auipc	a0,0x7
    8000188a:	0b250513          	addi	a0,a0,178 # 80008938 <wait_lock>
    8000188e:	00005097          	auipc	ra,0x5
    80001892:	a5a080e7          	jalr	-1446(ra) # 800062e8 <release>
            return -1;
    80001896:	59fd                	li	s3,-1
    80001898:	a0b9                	j	800018e6 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000189a:	18848493          	addi	s1,s1,392
    8000189e:	03348463          	beq	s1,s3,800018c6 <wait+0xe6>
      if(pp->parent == p){
    800018a2:	7c9c                	ld	a5,56(s1)
    800018a4:	ff279be3          	bne	a5,s2,8000189a <wait+0xba>
        acquire(&pp->lock);
    800018a8:	8526                	mv	a0,s1
    800018aa:	00005097          	auipc	ra,0x5
    800018ae:	98a080e7          	jalr	-1654(ra) # 80006234 <acquire>
        if(pp->state == ZOMBIE){
    800018b2:	4c9c                	lw	a5,24(s1)
    800018b4:	f94781e3          	beq	a5,s4,80001836 <wait+0x56>
        release(&pp->lock);
    800018b8:	8526                	mv	a0,s1
    800018ba:	00005097          	auipc	ra,0x5
    800018be:	a2e080e7          	jalr	-1490(ra) # 800062e8 <release>
        havekids = 1;
    800018c2:	8756                	mv	a4,s5
    800018c4:	bfd9                	j	8000189a <wait+0xba>
    if(!havekids || killed(p)){
    800018c6:	c719                	beqz	a4,800018d4 <wait+0xf4>
    800018c8:	854a                	mv	a0,s2
    800018ca:	00000097          	auipc	ra,0x0
    800018ce:	ee4080e7          	jalr	-284(ra) # 800017ae <killed>
    800018d2:	c51d                	beqz	a0,80001900 <wait+0x120>
      release(&wait_lock);
    800018d4:	00007517          	auipc	a0,0x7
    800018d8:	06450513          	addi	a0,a0,100 # 80008938 <wait_lock>
    800018dc:	00005097          	auipc	ra,0x5
    800018e0:	a0c080e7          	jalr	-1524(ra) # 800062e8 <release>
      return -1;
    800018e4:	59fd                	li	s3,-1
}
    800018e6:	854e                	mv	a0,s3
    800018e8:	60a6                	ld	ra,72(sp)
    800018ea:	6406                	ld	s0,64(sp)
    800018ec:	74e2                	ld	s1,56(sp)
    800018ee:	7942                	ld	s2,48(sp)
    800018f0:	79a2                	ld	s3,40(sp)
    800018f2:	7a02                	ld	s4,32(sp)
    800018f4:	6ae2                	ld	s5,24(sp)
    800018f6:	6b42                	ld	s6,16(sp)
    800018f8:	6ba2                	ld	s7,8(sp)
    800018fa:	6c02                	ld	s8,0(sp)
    800018fc:	6161                	addi	sp,sp,80
    800018fe:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001900:	85e2                	mv	a1,s8
    80001902:	854a                	mv	a0,s2
    80001904:	00000097          	auipc	ra,0x0
    80001908:	c02080e7          	jalr	-1022(ra) # 80001506 <sleep>
    havekids = 0;
    8000190c:	bf39                	j	8000182a <wait+0x4a>

000000008000190e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000190e:	7179                	addi	sp,sp,-48
    80001910:	f406                	sd	ra,40(sp)
    80001912:	f022                	sd	s0,32(sp)
    80001914:	ec26                	sd	s1,24(sp)
    80001916:	e84a                	sd	s2,16(sp)
    80001918:	e44e                	sd	s3,8(sp)
    8000191a:	e052                	sd	s4,0(sp)
    8000191c:	1800                	addi	s0,sp,48
    8000191e:	84aa                	mv	s1,a0
    80001920:	892e                	mv	s2,a1
    80001922:	89b2                	mv	s3,a2
    80001924:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001926:	fffff097          	auipc	ra,0xfffff
    8000192a:	52e080e7          	jalr	1326(ra) # 80000e54 <myproc>
  if(user_dst){
    8000192e:	c08d                	beqz	s1,80001950 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001930:	86d2                	mv	a3,s4
    80001932:	864e                	mv	a2,s3
    80001934:	85ca                	mv	a1,s2
    80001936:	6928                	ld	a0,80(a0)
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	1dc080e7          	jalr	476(ra) # 80000b14 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001940:	70a2                	ld	ra,40(sp)
    80001942:	7402                	ld	s0,32(sp)
    80001944:	64e2                	ld	s1,24(sp)
    80001946:	6942                	ld	s2,16(sp)
    80001948:	69a2                	ld	s3,8(sp)
    8000194a:	6a02                	ld	s4,0(sp)
    8000194c:	6145                	addi	sp,sp,48
    8000194e:	8082                	ret
    memmove((char *)dst, src, len);
    80001950:	000a061b          	sext.w	a2,s4
    80001954:	85ce                	mv	a1,s3
    80001956:	854a                	mv	a0,s2
    80001958:	fffff097          	auipc	ra,0xfffff
    8000195c:	87e080e7          	jalr	-1922(ra) # 800001d6 <memmove>
    return 0;
    80001960:	8526                	mv	a0,s1
    80001962:	bff9                	j	80001940 <either_copyout+0x32>

0000000080001964 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001964:	7179                	addi	sp,sp,-48
    80001966:	f406                	sd	ra,40(sp)
    80001968:	f022                	sd	s0,32(sp)
    8000196a:	ec26                	sd	s1,24(sp)
    8000196c:	e84a                	sd	s2,16(sp)
    8000196e:	e44e                	sd	s3,8(sp)
    80001970:	e052                	sd	s4,0(sp)
    80001972:	1800                	addi	s0,sp,48
    80001974:	892a                	mv	s2,a0
    80001976:	84ae                	mv	s1,a1
    80001978:	89b2                	mv	s3,a2
    8000197a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000197c:	fffff097          	auipc	ra,0xfffff
    80001980:	4d8080e7          	jalr	1240(ra) # 80000e54 <myproc>
  if(user_src){
    80001984:	c08d                	beqz	s1,800019a6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001986:	86d2                	mv	a3,s4
    80001988:	864e                	mv	a2,s3
    8000198a:	85ca                	mv	a1,s2
    8000198c:	6928                	ld	a0,80(a0)
    8000198e:	fffff097          	auipc	ra,0xfffff
    80001992:	212080e7          	jalr	530(ra) # 80000ba0 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001996:	70a2                	ld	ra,40(sp)
    80001998:	7402                	ld	s0,32(sp)
    8000199a:	64e2                	ld	s1,24(sp)
    8000199c:	6942                	ld	s2,16(sp)
    8000199e:	69a2                	ld	s3,8(sp)
    800019a0:	6a02                	ld	s4,0(sp)
    800019a2:	6145                	addi	sp,sp,48
    800019a4:	8082                	ret
    memmove(dst, (char*)src, len);
    800019a6:	000a061b          	sext.w	a2,s4
    800019aa:	85ce                	mv	a1,s3
    800019ac:	854a                	mv	a0,s2
    800019ae:	fffff097          	auipc	ra,0xfffff
    800019b2:	828080e7          	jalr	-2008(ra) # 800001d6 <memmove>
    return 0;
    800019b6:	8526                	mv	a0,s1
    800019b8:	bff9                	j	80001996 <either_copyin+0x32>

00000000800019ba <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800019ba:	715d                	addi	sp,sp,-80
    800019bc:	e486                	sd	ra,72(sp)
    800019be:	e0a2                	sd	s0,64(sp)
    800019c0:	fc26                	sd	s1,56(sp)
    800019c2:	f84a                	sd	s2,48(sp)
    800019c4:	f44e                	sd	s3,40(sp)
    800019c6:	f052                	sd	s4,32(sp)
    800019c8:	ec56                	sd	s5,24(sp)
    800019ca:	e85a                	sd	s6,16(sp)
    800019cc:	e45e                	sd	s7,8(sp)
    800019ce:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800019d0:	00006517          	auipc	a0,0x6
    800019d4:	67850513          	addi	a0,a0,1656 # 80008048 <etext+0x48>
    800019d8:	00004097          	auipc	ra,0x4
    800019dc:	36e080e7          	jalr	878(ra) # 80005d46 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800019e0:	00007497          	auipc	s1,0x7
    800019e4:	4c848493          	addi	s1,s1,1224 # 80008ea8 <proc+0x158>
    800019e8:	0000d917          	auipc	s2,0xd
    800019ec:	6c090913          	addi	s2,s2,1728 # 8000f0a8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800019f0:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800019f2:	00007997          	auipc	s3,0x7
    800019f6:	80e98993          	addi	s3,s3,-2034 # 80008200 <etext+0x200>
    printf("%d %s %s", p->pid, state, p->name);
    800019fa:	00007a97          	auipc	s5,0x7
    800019fe:	80ea8a93          	addi	s5,s5,-2034 # 80008208 <etext+0x208>
    printf("\n");
    80001a02:	00006a17          	auipc	s4,0x6
    80001a06:	646a0a13          	addi	s4,s4,1606 # 80008048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a0a:	00007b97          	auipc	s7,0x7
    80001a0e:	83eb8b93          	addi	s7,s7,-1986 # 80008248 <states.0>
    80001a12:	a00d                	j	80001a34 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001a14:	ed86a583          	lw	a1,-296(a3)
    80001a18:	8556                	mv	a0,s5
    80001a1a:	00004097          	auipc	ra,0x4
    80001a1e:	32c080e7          	jalr	812(ra) # 80005d46 <printf>
    printf("\n");
    80001a22:	8552                	mv	a0,s4
    80001a24:	00004097          	auipc	ra,0x4
    80001a28:	322080e7          	jalr	802(ra) # 80005d46 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a2c:	18848493          	addi	s1,s1,392
    80001a30:	03248263          	beq	s1,s2,80001a54 <procdump+0x9a>
    if(p->state == UNUSED)
    80001a34:	86a6                	mv	a3,s1
    80001a36:	ec04a783          	lw	a5,-320(s1)
    80001a3a:	dbed                	beqz	a5,80001a2c <procdump+0x72>
      state = "???";
    80001a3c:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a3e:	fcfb6be3          	bltu	s6,a5,80001a14 <procdump+0x5a>
    80001a42:	02079713          	slli	a4,a5,0x20
    80001a46:	01d75793          	srli	a5,a4,0x1d
    80001a4a:	97de                	add	a5,a5,s7
    80001a4c:	6390                	ld	a2,0(a5)
    80001a4e:	f279                	bnez	a2,80001a14 <procdump+0x5a>
      state = "???";
    80001a50:	864e                	mv	a2,s3
    80001a52:	b7c9                	j	80001a14 <procdump+0x5a>
  }
}
    80001a54:	60a6                	ld	ra,72(sp)
    80001a56:	6406                	ld	s0,64(sp)
    80001a58:	74e2                	ld	s1,56(sp)
    80001a5a:	7942                	ld	s2,48(sp)
    80001a5c:	79a2                	ld	s3,40(sp)
    80001a5e:	7a02                	ld	s4,32(sp)
    80001a60:	6ae2                	ld	s5,24(sp)
    80001a62:	6b42                	ld	s6,16(sp)
    80001a64:	6ba2                	ld	s7,8(sp)
    80001a66:	6161                	addi	sp,sp,80
    80001a68:	8082                	ret

0000000080001a6a <swtch>:
    80001a6a:	00153023          	sd	ra,0(a0)
    80001a6e:	00253423          	sd	sp,8(a0)
    80001a72:	e900                	sd	s0,16(a0)
    80001a74:	ed04                	sd	s1,24(a0)
    80001a76:	03253023          	sd	s2,32(a0)
    80001a7a:	03353423          	sd	s3,40(a0)
    80001a7e:	03453823          	sd	s4,48(a0)
    80001a82:	03553c23          	sd	s5,56(a0)
    80001a86:	05653023          	sd	s6,64(a0)
    80001a8a:	05753423          	sd	s7,72(a0)
    80001a8e:	05853823          	sd	s8,80(a0)
    80001a92:	05953c23          	sd	s9,88(a0)
    80001a96:	07a53023          	sd	s10,96(a0)
    80001a9a:	07b53423          	sd	s11,104(a0)
    80001a9e:	0005b083          	ld	ra,0(a1)
    80001aa2:	0085b103          	ld	sp,8(a1)
    80001aa6:	6980                	ld	s0,16(a1)
    80001aa8:	6d84                	ld	s1,24(a1)
    80001aaa:	0205b903          	ld	s2,32(a1)
    80001aae:	0285b983          	ld	s3,40(a1)
    80001ab2:	0305ba03          	ld	s4,48(a1)
    80001ab6:	0385ba83          	ld	s5,56(a1)
    80001aba:	0405bb03          	ld	s6,64(a1)
    80001abe:	0485bb83          	ld	s7,72(a1)
    80001ac2:	0505bc03          	ld	s8,80(a1)
    80001ac6:	0585bc83          	ld	s9,88(a1)
    80001aca:	0605bd03          	ld	s10,96(a1)
    80001ace:	0685bd83          	ld	s11,104(a1)
    80001ad2:	8082                	ret

0000000080001ad4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001ad4:	1141                	addi	sp,sp,-16
    80001ad6:	e406                	sd	ra,8(sp)
    80001ad8:	e022                	sd	s0,0(sp)
    80001ada:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001adc:	00006597          	auipc	a1,0x6
    80001ae0:	79c58593          	addi	a1,a1,1948 # 80008278 <states.0+0x30>
    80001ae4:	0000d517          	auipc	a0,0xd
    80001ae8:	46c50513          	addi	a0,a0,1132 # 8000ef50 <tickslock>
    80001aec:	00004097          	auipc	ra,0x4
    80001af0:	6b8080e7          	jalr	1720(ra) # 800061a4 <initlock>
}
    80001af4:	60a2                	ld	ra,8(sp)
    80001af6:	6402                	ld	s0,0(sp)
    80001af8:	0141                	addi	sp,sp,16
    80001afa:	8082                	ret

0000000080001afc <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001afc:	1141                	addi	sp,sp,-16
    80001afe:	e422                	sd	s0,8(sp)
    80001b00:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b02:	00003797          	auipc	a5,0x3
    80001b06:	62e78793          	addi	a5,a5,1582 # 80005130 <kernelvec>
    80001b0a:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001b0e:	6422                	ld	s0,8(sp)
    80001b10:	0141                	addi	sp,sp,16
    80001b12:	8082                	ret

0000000080001b14 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001b14:	1141                	addi	sp,sp,-16
    80001b16:	e406                	sd	ra,8(sp)
    80001b18:	e022                	sd	s0,0(sp)
    80001b1a:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	338080e7          	jalr	824(ra) # 80000e54 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b24:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001b28:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b2a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001b2e:	00005697          	auipc	a3,0x5
    80001b32:	4d268693          	addi	a3,a3,1234 # 80007000 <_trampoline>
    80001b36:	00005717          	auipc	a4,0x5
    80001b3a:	4ca70713          	addi	a4,a4,1226 # 80007000 <_trampoline>
    80001b3e:	8f15                	sub	a4,a4,a3
    80001b40:	040007b7          	lui	a5,0x4000
    80001b44:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80001b46:	07b2                	slli	a5,a5,0xc
    80001b48:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b4a:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001b4e:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001b50:	18002673          	csrr	a2,satp
    80001b54:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001b56:	6d30                	ld	a2,88(a0)
    80001b58:	6138                	ld	a4,64(a0)
    80001b5a:	6585                	lui	a1,0x1
    80001b5c:	972e                	add	a4,a4,a1
    80001b5e:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001b60:	6d38                	ld	a4,88(a0)
    80001b62:	00000617          	auipc	a2,0x0
    80001b66:	13060613          	addi	a2,a2,304 # 80001c92 <usertrap>
    80001b6a:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001b6c:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001b6e:	8612                	mv	a2,tp
    80001b70:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b72:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001b76:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001b7a:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b7e:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001b82:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001b84:	6f18                	ld	a4,24(a4)
    80001b86:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001b8a:	6928                	ld	a0,80(a0)
    80001b8c:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001b8e:	00005717          	auipc	a4,0x5
    80001b92:	50e70713          	addi	a4,a4,1294 # 8000709c <userret>
    80001b96:	8f15                	sub	a4,a4,a3
    80001b98:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001b9a:	577d                	li	a4,-1
    80001b9c:	177e                	slli	a4,a4,0x3f
    80001b9e:	8d59                	or	a0,a0,a4
    80001ba0:	9782                	jalr	a5
}
    80001ba2:	60a2                	ld	ra,8(sp)
    80001ba4:	6402                	ld	s0,0(sp)
    80001ba6:	0141                	addi	sp,sp,16
    80001ba8:	8082                	ret

0000000080001baa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001baa:	1101                	addi	sp,sp,-32
    80001bac:	ec06                	sd	ra,24(sp)
    80001bae:	e822                	sd	s0,16(sp)
    80001bb0:	e426                	sd	s1,8(sp)
    80001bb2:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001bb4:	0000d497          	auipc	s1,0xd
    80001bb8:	39c48493          	addi	s1,s1,924 # 8000ef50 <tickslock>
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	00004097          	auipc	ra,0x4
    80001bc2:	676080e7          	jalr	1654(ra) # 80006234 <acquire>
  ticks++;
    80001bc6:	00007517          	auipc	a0,0x7
    80001bca:	d2250513          	addi	a0,a0,-734 # 800088e8 <ticks>
    80001bce:	411c                	lw	a5,0(a0)
    80001bd0:	2785                	addiw	a5,a5,1
    80001bd2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001bd4:	00000097          	auipc	ra,0x0
    80001bd8:	996080e7          	jalr	-1642(ra) # 8000156a <wakeup>
  release(&tickslock);
    80001bdc:	8526                	mv	a0,s1
    80001bde:	00004097          	auipc	ra,0x4
    80001be2:	70a080e7          	jalr	1802(ra) # 800062e8 <release>
}
    80001be6:	60e2                	ld	ra,24(sp)
    80001be8:	6442                	ld	s0,16(sp)
    80001bea:	64a2                	ld	s1,8(sp)
    80001bec:	6105                	addi	sp,sp,32
    80001bee:	8082                	ret

0000000080001bf0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001bf0:	1101                	addi	sp,sp,-32
    80001bf2:	ec06                	sd	ra,24(sp)
    80001bf4:	e822                	sd	s0,16(sp)
    80001bf6:	e426                	sd	s1,8(sp)
    80001bf8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001bfa:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001bfe:	00074d63          	bltz	a4,80001c18 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001c02:	57fd                	li	a5,-1
    80001c04:	17fe                	slli	a5,a5,0x3f
    80001c06:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001c08:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001c0a:	06f70363          	beq	a4,a5,80001c70 <devintr+0x80>
  }
}
    80001c0e:	60e2                	ld	ra,24(sp)
    80001c10:	6442                	ld	s0,16(sp)
    80001c12:	64a2                	ld	s1,8(sp)
    80001c14:	6105                	addi	sp,sp,32
    80001c16:	8082                	ret
     (scause & 0xff) == 9){
    80001c18:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    80001c1c:	46a5                	li	a3,9
    80001c1e:	fed792e3          	bne	a5,a3,80001c02 <devintr+0x12>
    int irq = plic_claim();
    80001c22:	00003097          	auipc	ra,0x3
    80001c26:	616080e7          	jalr	1558(ra) # 80005238 <plic_claim>
    80001c2a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001c2c:	47a9                	li	a5,10
    80001c2e:	02f50763          	beq	a0,a5,80001c5c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001c32:	4785                	li	a5,1
    80001c34:	02f50963          	beq	a0,a5,80001c66 <devintr+0x76>
    return 1;
    80001c38:	4505                	li	a0,1
    } else if(irq){
    80001c3a:	d8f1                	beqz	s1,80001c0e <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001c3c:	85a6                	mv	a1,s1
    80001c3e:	00006517          	auipc	a0,0x6
    80001c42:	64250513          	addi	a0,a0,1602 # 80008280 <states.0+0x38>
    80001c46:	00004097          	auipc	ra,0x4
    80001c4a:	100080e7          	jalr	256(ra) # 80005d46 <printf>
      plic_complete(irq);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	00003097          	auipc	ra,0x3
    80001c54:	60c080e7          	jalr	1548(ra) # 8000525c <plic_complete>
    return 1;
    80001c58:	4505                	li	a0,1
    80001c5a:	bf55                	j	80001c0e <devintr+0x1e>
      uartintr();
    80001c5c:	00004097          	auipc	ra,0x4
    80001c60:	4f8080e7          	jalr	1272(ra) # 80006154 <uartintr>
    80001c64:	b7ed                	j	80001c4e <devintr+0x5e>
      virtio_disk_intr();
    80001c66:	00004097          	auipc	ra,0x4
    80001c6a:	abe080e7          	jalr	-1346(ra) # 80005724 <virtio_disk_intr>
    80001c6e:	b7c5                	j	80001c4e <devintr+0x5e>
    if(cpuid() == 0){
    80001c70:	fffff097          	auipc	ra,0xfffff
    80001c74:	1b8080e7          	jalr	440(ra) # 80000e28 <cpuid>
    80001c78:	c901                	beqz	a0,80001c88 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001c7a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001c7e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001c80:	14479073          	csrw	sip,a5
    return 2;
    80001c84:	4509                	li	a0,2
    80001c86:	b761                	j	80001c0e <devintr+0x1e>
      clockintr();
    80001c88:	00000097          	auipc	ra,0x0
    80001c8c:	f22080e7          	jalr	-222(ra) # 80001baa <clockintr>
    80001c90:	b7ed                	j	80001c7a <devintr+0x8a>

0000000080001c92 <usertrap>:
{
    80001c92:	1101                	addi	sp,sp,-32
    80001c94:	ec06                	sd	ra,24(sp)
    80001c96:	e822                	sd	s0,16(sp)
    80001c98:	e426                	sd	s1,8(sp)
    80001c9a:	e04a                	sd	s2,0(sp)
    80001c9c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001c9e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001ca2:	1007f793          	andi	a5,a5,256
    80001ca6:	e3b1                	bnez	a5,80001cea <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001ca8:	00003797          	auipc	a5,0x3
    80001cac:	48878793          	addi	a5,a5,1160 # 80005130 <kernelvec>
    80001cb0:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001cb4:	fffff097          	auipc	ra,0xfffff
    80001cb8:	1a0080e7          	jalr	416(ra) # 80000e54 <myproc>
    80001cbc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001cbe:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001cc0:	14102773          	csrr	a4,sepc
    80001cc4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001cc6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001cca:	47a1                	li	a5,8
    80001ccc:	02f70763          	beq	a4,a5,80001cfa <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80001cd0:	00000097          	auipc	ra,0x0
    80001cd4:	f20080e7          	jalr	-224(ra) # 80001bf0 <devintr>
    80001cd8:	892a                	mv	s2,a0
    80001cda:	c52d                	beqz	a0,80001d44 <usertrap+0xb2>
  if(killed(p))
    80001cdc:	8526                	mv	a0,s1
    80001cde:	00000097          	auipc	ra,0x0
    80001ce2:	ad0080e7          	jalr	-1328(ra) # 800017ae <killed>
    80001ce6:	c155                	beqz	a0,80001d8a <usertrap+0xf8>
    80001ce8:	a861                	j	80001d80 <usertrap+0xee>
    panic("usertrap: not from user mode");
    80001cea:	00006517          	auipc	a0,0x6
    80001cee:	5b650513          	addi	a0,a0,1462 # 800082a0 <states.0+0x58>
    80001cf2:	00004097          	auipc	ra,0x4
    80001cf6:	00a080e7          	jalr	10(ra) # 80005cfc <panic>
    if(killed(p))
    80001cfa:	00000097          	auipc	ra,0x0
    80001cfe:	ab4080e7          	jalr	-1356(ra) # 800017ae <killed>
    80001d02:	e91d                	bnez	a0,80001d38 <usertrap+0xa6>
    p->trapframe->epc += 4;
    80001d04:	6cb8                	ld	a4,88(s1)
    80001d06:	6f1c                	ld	a5,24(a4)
    80001d08:	0791                	addi	a5,a5,4
    80001d0a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d0c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d10:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001d14:	10079073          	csrw	sstatus,a5
    syscall();
    80001d18:	00000097          	auipc	ra,0x0
    80001d1c:	32a080e7          	jalr	810(ra) # 80002042 <syscall>
  if(killed(p))
    80001d20:	8526                	mv	a0,s1
    80001d22:	00000097          	auipc	ra,0x0
    80001d26:	a8c080e7          	jalr	-1396(ra) # 800017ae <killed>
    80001d2a:	e931                	bnez	a0,80001d7e <usertrap+0xec>
}
    80001d2c:	60e2                	ld	ra,24(sp)
    80001d2e:	6442                	ld	s0,16(sp)
    80001d30:	64a2                	ld	s1,8(sp)
    80001d32:	6902                	ld	s2,0(sp)
    80001d34:	6105                	addi	sp,sp,32
    80001d36:	8082                	ret
      exit(-1);
    80001d38:	557d                	li	a0,-1
    80001d3a:	00000097          	auipc	ra,0x0
    80001d3e:	900080e7          	jalr	-1792(ra) # 8000163a <exit>
    80001d42:	b7c9                	j	80001d04 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d44:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001d48:	5890                	lw	a2,48(s1)
    80001d4a:	00006517          	auipc	a0,0x6
    80001d4e:	57650513          	addi	a0,a0,1398 # 800082c0 <states.0+0x78>
    80001d52:	00004097          	auipc	ra,0x4
    80001d56:	ff4080e7          	jalr	-12(ra) # 80005d46 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d5a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001d5e:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001d62:	00006517          	auipc	a0,0x6
    80001d66:	58e50513          	addi	a0,a0,1422 # 800082f0 <states.0+0xa8>
    80001d6a:	00004097          	auipc	ra,0x4
    80001d6e:	fdc080e7          	jalr	-36(ra) # 80005d46 <printf>
    setkilled(p);
    80001d72:	8526                	mv	a0,s1
    80001d74:	00000097          	auipc	ra,0x0
    80001d78:	a0e080e7          	jalr	-1522(ra) # 80001782 <setkilled>
    80001d7c:	b755                	j	80001d20 <usertrap+0x8e>
  if(killed(p))
    80001d7e:	4901                	li	s2,0
    exit(-1);
    80001d80:	557d                	li	a0,-1
    80001d82:	00000097          	auipc	ra,0x0
    80001d86:	8b8080e7          	jalr	-1864(ra) # 8000163a <exit>
  if(which_dev == 2)
    80001d8a:	4789                	li	a5,2
    80001d8c:	faf910e3          	bne	s2,a5,80001d2c <usertrap+0x9a>
    p->now_ticks+=1;
    80001d90:	16c4a783          	lw	a5,364(s1)
    80001d94:	2785                	addiw	a5,a5,1
    80001d96:	0007871b          	sext.w	a4,a5
    80001d9a:	16f4a623          	sw	a5,364(s1)
    if(p->alarm_ticks>0&&p->now_ticks>=p->alarm_ticks&&!p->is_sigalarm){
    80001d9e:	1684a783          	lw	a5,360(s1)
    80001da2:	04f05663          	blez	a5,80001dee <usertrap+0x15c>
    80001da6:	04f74463          	blt	a4,a5,80001dee <usertrap+0x15c>
    80001daa:	1704a783          	lw	a5,368(s1)
    80001dae:	e3a1                	bnez	a5,80001dee <usertrap+0x15c>
      p->now_ticks = 0;
    80001db0:	1604a623          	sw	zero,364(s1)
      p->is_sigalarm = 1;
    80001db4:	4785                	li	a5,1
    80001db6:	16f4a823          	sw	a5,368(s1)
      *(p->trapframe_copy)=*(p->trapframe);
    80001dba:	6cb4                	ld	a3,88(s1)
    80001dbc:	87b6                	mv	a5,a3
    80001dbe:	1804b703          	ld	a4,384(s1)
    80001dc2:	12068693          	addi	a3,a3,288
    80001dc6:	0007b803          	ld	a6,0(a5)
    80001dca:	6788                	ld	a0,8(a5)
    80001dcc:	6b8c                	ld	a1,16(a5)
    80001dce:	6f90                	ld	a2,24(a5)
    80001dd0:	01073023          	sd	a6,0(a4)
    80001dd4:	e708                	sd	a0,8(a4)
    80001dd6:	eb0c                	sd	a1,16(a4)
    80001dd8:	ef10                	sd	a2,24(a4)
    80001dda:	02078793          	addi	a5,a5,32
    80001dde:	02070713          	addi	a4,a4,32
    80001de2:	fed792e3          	bne	a5,a3,80001dc6 <usertrap+0x134>
      p->trapframe->epc=p->alarm_handler;
    80001de6:	6cbc                	ld	a5,88(s1)
    80001de8:	1784b703          	ld	a4,376(s1)
    80001dec:	ef98                	sd	a4,24(a5)
  yield();
    80001dee:	fffff097          	auipc	ra,0xfffff
    80001df2:	6dc080e7          	jalr	1756(ra) # 800014ca <yield>
}
    80001df6:	bf1d                	j	80001d2c <usertrap+0x9a>

0000000080001df8 <kerneltrap>:
{
    80001df8:	7179                	addi	sp,sp,-48
    80001dfa:	f406                	sd	ra,40(sp)
    80001dfc:	f022                	sd	s0,32(sp)
    80001dfe:	ec26                	sd	s1,24(sp)
    80001e00:	e84a                	sd	s2,16(sp)
    80001e02:	e44e                	sd	s3,8(sp)
    80001e04:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e06:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e0a:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e0e:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001e12:	1004f793          	andi	a5,s1,256
    80001e16:	cb85                	beqz	a5,80001e46 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e18:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e1c:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001e1e:	ef85                	bnez	a5,80001e56 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001e20:	00000097          	auipc	ra,0x0
    80001e24:	dd0080e7          	jalr	-560(ra) # 80001bf0 <devintr>
    80001e28:	cd1d                	beqz	a0,80001e66 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e2a:	4789                	li	a5,2
    80001e2c:	06f50a63          	beq	a0,a5,80001ea0 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e30:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e34:	10049073          	csrw	sstatus,s1
}
    80001e38:	70a2                	ld	ra,40(sp)
    80001e3a:	7402                	ld	s0,32(sp)
    80001e3c:	64e2                	ld	s1,24(sp)
    80001e3e:	6942                	ld	s2,16(sp)
    80001e40:	69a2                	ld	s3,8(sp)
    80001e42:	6145                	addi	sp,sp,48
    80001e44:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e46:	00006517          	auipc	a0,0x6
    80001e4a:	4ca50513          	addi	a0,a0,1226 # 80008310 <states.0+0xc8>
    80001e4e:	00004097          	auipc	ra,0x4
    80001e52:	eae080e7          	jalr	-338(ra) # 80005cfc <panic>
    panic("kerneltrap: interrupts enabled");
    80001e56:	00006517          	auipc	a0,0x6
    80001e5a:	4e250513          	addi	a0,a0,1250 # 80008338 <states.0+0xf0>
    80001e5e:	00004097          	auipc	ra,0x4
    80001e62:	e9e080e7          	jalr	-354(ra) # 80005cfc <panic>
    printf("scause %p\n", scause);
    80001e66:	85ce                	mv	a1,s3
    80001e68:	00006517          	auipc	a0,0x6
    80001e6c:	4f050513          	addi	a0,a0,1264 # 80008358 <states.0+0x110>
    80001e70:	00004097          	auipc	ra,0x4
    80001e74:	ed6080e7          	jalr	-298(ra) # 80005d46 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e78:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e7c:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e80:	00006517          	auipc	a0,0x6
    80001e84:	4e850513          	addi	a0,a0,1256 # 80008368 <states.0+0x120>
    80001e88:	00004097          	auipc	ra,0x4
    80001e8c:	ebe080e7          	jalr	-322(ra) # 80005d46 <printf>
    panic("kerneltrap");
    80001e90:	00006517          	auipc	a0,0x6
    80001e94:	4f050513          	addi	a0,a0,1264 # 80008380 <states.0+0x138>
    80001e98:	00004097          	auipc	ra,0x4
    80001e9c:	e64080e7          	jalr	-412(ra) # 80005cfc <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001ea0:	fffff097          	auipc	ra,0xfffff
    80001ea4:	fb4080e7          	jalr	-76(ra) # 80000e54 <myproc>
    80001ea8:	d541                	beqz	a0,80001e30 <kerneltrap+0x38>
    80001eaa:	fffff097          	auipc	ra,0xfffff
    80001eae:	faa080e7          	jalr	-86(ra) # 80000e54 <myproc>
    80001eb2:	4d18                	lw	a4,24(a0)
    80001eb4:	4791                	li	a5,4
    80001eb6:	f6f71de3          	bne	a4,a5,80001e30 <kerneltrap+0x38>
    yield();
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	610080e7          	jalr	1552(ra) # 800014ca <yield>
    80001ec2:	b7bd                	j	80001e30 <kerneltrap+0x38>

0000000080001ec4 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001ec4:	1101                	addi	sp,sp,-32
    80001ec6:	ec06                	sd	ra,24(sp)
    80001ec8:	e822                	sd	s0,16(sp)
    80001eca:	e426                	sd	s1,8(sp)
    80001ecc:	1000                	addi	s0,sp,32
    80001ece:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ed0:	fffff097          	auipc	ra,0xfffff
    80001ed4:	f84080e7          	jalr	-124(ra) # 80000e54 <myproc>
  switch (n) {
    80001ed8:	4795                	li	a5,5
    80001eda:	0497e163          	bltu	a5,s1,80001f1c <argraw+0x58>
    80001ede:	048a                	slli	s1,s1,0x2
    80001ee0:	00006717          	auipc	a4,0x6
    80001ee4:	4d870713          	addi	a4,a4,1240 # 800083b8 <states.0+0x170>
    80001ee8:	94ba                	add	s1,s1,a4
    80001eea:	409c                	lw	a5,0(s1)
    80001eec:	97ba                	add	a5,a5,a4
    80001eee:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001ef0:	6d3c                	ld	a5,88(a0)
    80001ef2:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001ef4:	60e2                	ld	ra,24(sp)
    80001ef6:	6442                	ld	s0,16(sp)
    80001ef8:	64a2                	ld	s1,8(sp)
    80001efa:	6105                	addi	sp,sp,32
    80001efc:	8082                	ret
    return p->trapframe->a1;
    80001efe:	6d3c                	ld	a5,88(a0)
    80001f00:	7fa8                	ld	a0,120(a5)
    80001f02:	bfcd                	j	80001ef4 <argraw+0x30>
    return p->trapframe->a2;
    80001f04:	6d3c                	ld	a5,88(a0)
    80001f06:	63c8                	ld	a0,128(a5)
    80001f08:	b7f5                	j	80001ef4 <argraw+0x30>
    return p->trapframe->a3;
    80001f0a:	6d3c                	ld	a5,88(a0)
    80001f0c:	67c8                	ld	a0,136(a5)
    80001f0e:	b7dd                	j	80001ef4 <argraw+0x30>
    return p->trapframe->a4;
    80001f10:	6d3c                	ld	a5,88(a0)
    80001f12:	6bc8                	ld	a0,144(a5)
    80001f14:	b7c5                	j	80001ef4 <argraw+0x30>
    return p->trapframe->a5;
    80001f16:	6d3c                	ld	a5,88(a0)
    80001f18:	6fc8                	ld	a0,152(a5)
    80001f1a:	bfe9                	j	80001ef4 <argraw+0x30>
  panic("argraw");
    80001f1c:	00006517          	auipc	a0,0x6
    80001f20:	47450513          	addi	a0,a0,1140 # 80008390 <states.0+0x148>
    80001f24:	00004097          	auipc	ra,0x4
    80001f28:	dd8080e7          	jalr	-552(ra) # 80005cfc <panic>

0000000080001f2c <fetchaddr>:
{
    80001f2c:	1101                	addi	sp,sp,-32
    80001f2e:	ec06                	sd	ra,24(sp)
    80001f30:	e822                	sd	s0,16(sp)
    80001f32:	e426                	sd	s1,8(sp)
    80001f34:	e04a                	sd	s2,0(sp)
    80001f36:	1000                	addi	s0,sp,32
    80001f38:	84aa                	mv	s1,a0
    80001f3a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f3c:	fffff097          	auipc	ra,0xfffff
    80001f40:	f18080e7          	jalr	-232(ra) # 80000e54 <myproc>
  if(addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80001f44:	653c                	ld	a5,72(a0)
    80001f46:	02f4f863          	bgeu	s1,a5,80001f76 <fetchaddr+0x4a>
    80001f4a:	00848713          	addi	a4,s1,8
    80001f4e:	02e7e663          	bltu	a5,a4,80001f7a <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001f52:	46a1                	li	a3,8
    80001f54:	8626                	mv	a2,s1
    80001f56:	85ca                	mv	a1,s2
    80001f58:	6928                	ld	a0,80(a0)
    80001f5a:	fffff097          	auipc	ra,0xfffff
    80001f5e:	c46080e7          	jalr	-954(ra) # 80000ba0 <copyin>
    80001f62:	00a03533          	snez	a0,a0
    80001f66:	40a00533          	neg	a0,a0
}
    80001f6a:	60e2                	ld	ra,24(sp)
    80001f6c:	6442                	ld	s0,16(sp)
    80001f6e:	64a2                	ld	s1,8(sp)
    80001f70:	6902                	ld	s2,0(sp)
    80001f72:	6105                	addi	sp,sp,32
    80001f74:	8082                	ret
    return -1;
    80001f76:	557d                	li	a0,-1
    80001f78:	bfcd                	j	80001f6a <fetchaddr+0x3e>
    80001f7a:	557d                	li	a0,-1
    80001f7c:	b7fd                	j	80001f6a <fetchaddr+0x3e>

0000000080001f7e <fetchstr>:
{
    80001f7e:	7179                	addi	sp,sp,-48
    80001f80:	f406                	sd	ra,40(sp)
    80001f82:	f022                	sd	s0,32(sp)
    80001f84:	ec26                	sd	s1,24(sp)
    80001f86:	e84a                	sd	s2,16(sp)
    80001f88:	e44e                	sd	s3,8(sp)
    80001f8a:	1800                	addi	s0,sp,48
    80001f8c:	892a                	mv	s2,a0
    80001f8e:	84ae                	mv	s1,a1
    80001f90:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	ec2080e7          	jalr	-318(ra) # 80000e54 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80001f9a:	86ce                	mv	a3,s3
    80001f9c:	864a                	mv	a2,s2
    80001f9e:	85a6                	mv	a1,s1
    80001fa0:	6928                	ld	a0,80(a0)
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	c8c080e7          	jalr	-884(ra) # 80000c2e <copyinstr>
    80001faa:	00054e63          	bltz	a0,80001fc6 <fetchstr+0x48>
  return strlen(buf);
    80001fae:	8526                	mv	a0,s1
    80001fb0:	ffffe097          	auipc	ra,0xffffe
    80001fb4:	346080e7          	jalr	838(ra) # 800002f6 <strlen>
}
    80001fb8:	70a2                	ld	ra,40(sp)
    80001fba:	7402                	ld	s0,32(sp)
    80001fbc:	64e2                	ld	s1,24(sp)
    80001fbe:	6942                	ld	s2,16(sp)
    80001fc0:	69a2                	ld	s3,8(sp)
    80001fc2:	6145                	addi	sp,sp,48
    80001fc4:	8082                	ret
    return -1;
    80001fc6:	557d                	li	a0,-1
    80001fc8:	bfc5                	j	80001fb8 <fetchstr+0x3a>

0000000080001fca <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80001fca:	1101                	addi	sp,sp,-32
    80001fcc:	ec06                	sd	ra,24(sp)
    80001fce:	e822                	sd	s0,16(sp)
    80001fd0:	e426                	sd	s1,8(sp)
    80001fd2:	1000                	addi	s0,sp,32
    80001fd4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001fd6:	00000097          	auipc	ra,0x0
    80001fda:	eee080e7          	jalr	-274(ra) # 80001ec4 <argraw>
    80001fde:	c088                	sw	a0,0(s1)
}
    80001fe0:	60e2                	ld	ra,24(sp)
    80001fe2:	6442                	ld	s0,16(sp)
    80001fe4:	64a2                	ld	s1,8(sp)
    80001fe6:	6105                	addi	sp,sp,32
    80001fe8:	8082                	ret

0000000080001fea <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80001fea:	1101                	addi	sp,sp,-32
    80001fec:	ec06                	sd	ra,24(sp)
    80001fee:	e822                	sd	s0,16(sp)
    80001ff0:	e426                	sd	s1,8(sp)
    80001ff2:	1000                	addi	s0,sp,32
    80001ff4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80001ff6:	00000097          	auipc	ra,0x0
    80001ffa:	ece080e7          	jalr	-306(ra) # 80001ec4 <argraw>
    80001ffe:	e088                	sd	a0,0(s1)
}
    80002000:	60e2                	ld	ra,24(sp)
    80002002:	6442                	ld	s0,16(sp)
    80002004:	64a2                	ld	s1,8(sp)
    80002006:	6105                	addi	sp,sp,32
    80002008:	8082                	ret

000000008000200a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000200a:	7179                	addi	sp,sp,-48
    8000200c:	f406                	sd	ra,40(sp)
    8000200e:	f022                	sd	s0,32(sp)
    80002010:	ec26                	sd	s1,24(sp)
    80002012:	e84a                	sd	s2,16(sp)
    80002014:	1800                	addi	s0,sp,48
    80002016:	84ae                	mv	s1,a1
    80002018:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000201a:	fd840593          	addi	a1,s0,-40
    8000201e:	00000097          	auipc	ra,0x0
    80002022:	fcc080e7          	jalr	-52(ra) # 80001fea <argaddr>
  return fetchstr(addr, buf, max);
    80002026:	864a                	mv	a2,s2
    80002028:	85a6                	mv	a1,s1
    8000202a:	fd843503          	ld	a0,-40(s0)
    8000202e:	00000097          	auipc	ra,0x0
    80002032:	f50080e7          	jalr	-176(ra) # 80001f7e <fetchstr>
}
    80002036:	70a2                	ld	ra,40(sp)
    80002038:	7402                	ld	s0,32(sp)
    8000203a:	64e2                	ld	s1,24(sp)
    8000203c:	6942                	ld	s2,16(sp)
    8000203e:	6145                	addi	sp,sp,48
    80002040:	8082                	ret

0000000080002042 <syscall>:

};

void
syscall(void)
{
    80002042:	1101                	addi	sp,sp,-32
    80002044:	ec06                	sd	ra,24(sp)
    80002046:	e822                	sd	s0,16(sp)
    80002048:	e426                	sd	s1,8(sp)
    8000204a:	e04a                	sd	s2,0(sp)
    8000204c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000204e:	fffff097          	auipc	ra,0xfffff
    80002052:	e06080e7          	jalr	-506(ra) # 80000e54 <myproc>
    80002056:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002058:	05853903          	ld	s2,88(a0)
    8000205c:	0a893783          	ld	a5,168(s2)
    80002060:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002064:	37fd                	addiw	a5,a5,-1
    80002066:	475d                	li	a4,23
    80002068:	00f76f63          	bltu	a4,a5,80002086 <syscall+0x44>
    8000206c:	00369713          	slli	a4,a3,0x3
    80002070:	00006797          	auipc	a5,0x6
    80002074:	36078793          	addi	a5,a5,864 # 800083d0 <syscalls>
    80002078:	97ba                	add	a5,a5,a4
    8000207a:	639c                	ld	a5,0(a5)
    8000207c:	c789                	beqz	a5,80002086 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000207e:	9782                	jalr	a5
    80002080:	06a93823          	sd	a0,112(s2)
    80002084:	a839                	j	800020a2 <syscall+0x60>
      return;
    p->alarm_ticks = ticks;
    p->alarm_handler = handler;
  }*/
  else {
    printf("%d %s: unknown sys call %d\n",
    80002086:	15848613          	addi	a2,s1,344
    8000208a:	588c                	lw	a1,48(s1)
    8000208c:	00006517          	auipc	a0,0x6
    80002090:	30c50513          	addi	a0,a0,780 # 80008398 <states.0+0x150>
    80002094:	00004097          	auipc	ra,0x4
    80002098:	cb2080e7          	jalr	-846(ra) # 80005d46 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000209c:	6cbc                	ld	a5,88(s1)
    8000209e:	577d                	li	a4,-1
    800020a0:	fbb8                	sd	a4,112(a5)
  }
}
    800020a2:	60e2                	ld	ra,24(sp)
    800020a4:	6442                	ld	s0,16(sp)
    800020a6:	64a2                	ld	s1,8(sp)
    800020a8:	6902                	ld	s2,0(sp)
    800020aa:	6105                	addi	sp,sp,32
    800020ac:	8082                	ret

00000000800020ae <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800020ae:	1101                	addi	sp,sp,-32
    800020b0:	ec06                	sd	ra,24(sp)
    800020b2:	e822                	sd	s0,16(sp)
    800020b4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800020b6:	fec40593          	addi	a1,s0,-20
    800020ba:	4501                	li	a0,0
    800020bc:	00000097          	auipc	ra,0x0
    800020c0:	f0e080e7          	jalr	-242(ra) # 80001fca <argint>
  exit(n);
    800020c4:	fec42503          	lw	a0,-20(s0)
    800020c8:	fffff097          	auipc	ra,0xfffff
    800020cc:	572080e7          	jalr	1394(ra) # 8000163a <exit>
  return 0;  // not reached
}
    800020d0:	4501                	li	a0,0
    800020d2:	60e2                	ld	ra,24(sp)
    800020d4:	6442                	ld	s0,16(sp)
    800020d6:	6105                	addi	sp,sp,32
    800020d8:	8082                	ret

00000000800020da <sys_getpid>:

uint64
sys_getpid(void)
{
    800020da:	1141                	addi	sp,sp,-16
    800020dc:	e406                	sd	ra,8(sp)
    800020de:	e022                	sd	s0,0(sp)
    800020e0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    800020e2:	fffff097          	auipc	ra,0xfffff
    800020e6:	d72080e7          	jalr	-654(ra) # 80000e54 <myproc>
}
    800020ea:	5908                	lw	a0,48(a0)
    800020ec:	60a2                	ld	ra,8(sp)
    800020ee:	6402                	ld	s0,0(sp)
    800020f0:	0141                	addi	sp,sp,16
    800020f2:	8082                	ret

00000000800020f4 <sys_fork>:

uint64
sys_fork(void)
{
    800020f4:	1141                	addi	sp,sp,-16
    800020f6:	e406                	sd	ra,8(sp)
    800020f8:	e022                	sd	s0,0(sp)
    800020fa:	0800                	addi	s0,sp,16
  return fork();
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	118080e7          	jalr	280(ra) # 80001214 <fork>
}
    80002104:	60a2                	ld	ra,8(sp)
    80002106:	6402                	ld	s0,0(sp)
    80002108:	0141                	addi	sp,sp,16
    8000210a:	8082                	ret

000000008000210c <sys_wait>:

uint64
sys_wait(void)
{
    8000210c:	1101                	addi	sp,sp,-32
    8000210e:	ec06                	sd	ra,24(sp)
    80002110:	e822                	sd	s0,16(sp)
    80002112:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002114:	fe840593          	addi	a1,s0,-24
    80002118:	4501                	li	a0,0
    8000211a:	00000097          	auipc	ra,0x0
    8000211e:	ed0080e7          	jalr	-304(ra) # 80001fea <argaddr>
  return wait(p);
    80002122:	fe843503          	ld	a0,-24(s0)
    80002126:	fffff097          	auipc	ra,0xfffff
    8000212a:	6ba080e7          	jalr	1722(ra) # 800017e0 <wait>
}
    8000212e:	60e2                	ld	ra,24(sp)
    80002130:	6442                	ld	s0,16(sp)
    80002132:	6105                	addi	sp,sp,32
    80002134:	8082                	ret

0000000080002136 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002136:	7179                	addi	sp,sp,-48
    80002138:	f406                	sd	ra,40(sp)
    8000213a:	f022                	sd	s0,32(sp)
    8000213c:	ec26                	sd	s1,24(sp)
    8000213e:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002140:	fdc40593          	addi	a1,s0,-36
    80002144:	4501                	li	a0,0
    80002146:	00000097          	auipc	ra,0x0
    8000214a:	e84080e7          	jalr	-380(ra) # 80001fca <argint>
  addr = myproc()->sz;
    8000214e:	fffff097          	auipc	ra,0xfffff
    80002152:	d06080e7          	jalr	-762(ra) # 80000e54 <myproc>
    80002156:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002158:	fdc42503          	lw	a0,-36(s0)
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	05c080e7          	jalr	92(ra) # 800011b8 <growproc>
    80002164:	00054863          	bltz	a0,80002174 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002168:	8526                	mv	a0,s1
    8000216a:	70a2                	ld	ra,40(sp)
    8000216c:	7402                	ld	s0,32(sp)
    8000216e:	64e2                	ld	s1,24(sp)
    80002170:	6145                	addi	sp,sp,48
    80002172:	8082                	ret
    return -1;
    80002174:	54fd                	li	s1,-1
    80002176:	bfcd                	j	80002168 <sys_sbrk+0x32>

0000000080002178 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002178:	7139                	addi	sp,sp,-64
    8000217a:	fc06                	sd	ra,56(sp)
    8000217c:	f822                	sd	s0,48(sp)
    8000217e:	f426                	sd	s1,40(sp)
    80002180:	f04a                	sd	s2,32(sp)
    80002182:	ec4e                	sd	s3,24(sp)
    80002184:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002186:	fcc40593          	addi	a1,s0,-52
    8000218a:	4501                	li	a0,0
    8000218c:	00000097          	auipc	ra,0x0
    80002190:	e3e080e7          	jalr	-450(ra) # 80001fca <argint>
  if(n < 0)
    80002194:	fcc42783          	lw	a5,-52(s0)
    80002198:	0607cf63          	bltz	a5,80002216 <sys_sleep+0x9e>
    n = 0;
  acquire(&tickslock);
    8000219c:	0000d517          	auipc	a0,0xd
    800021a0:	db450513          	addi	a0,a0,-588 # 8000ef50 <tickslock>
    800021a4:	00004097          	auipc	ra,0x4
    800021a8:	090080e7          	jalr	144(ra) # 80006234 <acquire>
  ticks0 = ticks;
    800021ac:	00006917          	auipc	s2,0x6
    800021b0:	73c92903          	lw	s2,1852(s2) # 800088e8 <ticks>
  while(ticks - ticks0 < n){
    800021b4:	fcc42783          	lw	a5,-52(s0)
    800021b8:	cf9d                	beqz	a5,800021f6 <sys_sleep+0x7e>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800021ba:	0000d997          	auipc	s3,0xd
    800021be:	d9698993          	addi	s3,s3,-618 # 8000ef50 <tickslock>
    800021c2:	00006497          	auipc	s1,0x6
    800021c6:	72648493          	addi	s1,s1,1830 # 800088e8 <ticks>
    if(killed(myproc())){
    800021ca:	fffff097          	auipc	ra,0xfffff
    800021ce:	c8a080e7          	jalr	-886(ra) # 80000e54 <myproc>
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	5dc080e7          	jalr	1500(ra) # 800017ae <killed>
    800021da:	e129                	bnez	a0,8000221c <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    800021dc:	85ce                	mv	a1,s3
    800021de:	8526                	mv	a0,s1
    800021e0:	fffff097          	auipc	ra,0xfffff
    800021e4:	326080e7          	jalr	806(ra) # 80001506 <sleep>
  while(ticks - ticks0 < n){
    800021e8:	409c                	lw	a5,0(s1)
    800021ea:	412787bb          	subw	a5,a5,s2
    800021ee:	fcc42703          	lw	a4,-52(s0)
    800021f2:	fce7ece3          	bltu	a5,a4,800021ca <sys_sleep+0x52>
  }
  release(&tickslock);
    800021f6:	0000d517          	auipc	a0,0xd
    800021fa:	d5a50513          	addi	a0,a0,-678 # 8000ef50 <tickslock>
    800021fe:	00004097          	auipc	ra,0x4
    80002202:	0ea080e7          	jalr	234(ra) # 800062e8 <release>
  return 0;
    80002206:	4501                	li	a0,0
}
    80002208:	70e2                	ld	ra,56(sp)
    8000220a:	7442                	ld	s0,48(sp)
    8000220c:	74a2                	ld	s1,40(sp)
    8000220e:	7902                	ld	s2,32(sp)
    80002210:	69e2                	ld	s3,24(sp)
    80002212:	6121                	addi	sp,sp,64
    80002214:	8082                	ret
    n = 0;
    80002216:	fc042623          	sw	zero,-52(s0)
    8000221a:	b749                	j	8000219c <sys_sleep+0x24>
      release(&tickslock);
    8000221c:	0000d517          	auipc	a0,0xd
    80002220:	d3450513          	addi	a0,a0,-716 # 8000ef50 <tickslock>
    80002224:	00004097          	auipc	ra,0x4
    80002228:	0c4080e7          	jalr	196(ra) # 800062e8 <release>
      return -1;
    8000222c:	557d                	li	a0,-1
    8000222e:	bfe9                	j	80002208 <sys_sleep+0x90>

0000000080002230 <sys_kill>:

uint64
sys_kill(void)
{
    80002230:	1101                	addi	sp,sp,-32
    80002232:	ec06                	sd	ra,24(sp)
    80002234:	e822                	sd	s0,16(sp)
    80002236:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002238:	fec40593          	addi	a1,s0,-20
    8000223c:	4501                	li	a0,0
    8000223e:	00000097          	auipc	ra,0x0
    80002242:	d8c080e7          	jalr	-628(ra) # 80001fca <argint>
  return kill(pid);
    80002246:	fec42503          	lw	a0,-20(s0)
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	4c6080e7          	jalr	1222(ra) # 80001710 <kill>
}
    80002252:	60e2                	ld	ra,24(sp)
    80002254:	6442                	ld	s0,16(sp)
    80002256:	6105                	addi	sp,sp,32
    80002258:	8082                	ret

000000008000225a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000225a:	1101                	addi	sp,sp,-32
    8000225c:	ec06                	sd	ra,24(sp)
    8000225e:	e822                	sd	s0,16(sp)
    80002260:	e426                	sd	s1,8(sp)
    80002262:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002264:	0000d517          	auipc	a0,0xd
    80002268:	cec50513          	addi	a0,a0,-788 # 8000ef50 <tickslock>
    8000226c:	00004097          	auipc	ra,0x4
    80002270:	fc8080e7          	jalr	-56(ra) # 80006234 <acquire>
  xticks = ticks;
    80002274:	00006497          	auipc	s1,0x6
    80002278:	6744a483          	lw	s1,1652(s1) # 800088e8 <ticks>
  release(&tickslock);
    8000227c:	0000d517          	auipc	a0,0xd
    80002280:	cd450513          	addi	a0,a0,-812 # 8000ef50 <tickslock>
    80002284:	00004097          	auipc	ra,0x4
    80002288:	064080e7          	jalr	100(ra) # 800062e8 <release>
  return xticks;
}
    8000228c:	02049513          	slli	a0,s1,0x20
    80002290:	9101                	srli	a0,a0,0x20
    80002292:	60e2                	ld	ra,24(sp)
    80002294:	6442                	ld	s0,16(sp)
    80002296:	64a2                	ld	s1,8(sp)
    80002298:	6105                	addi	sp,sp,32
    8000229a:	8082                	ret

000000008000229c <restore>:

void restore(){
    8000229c:	1141                	addi	sp,sp,-16
    8000229e:	e406                	sd	ra,8(sp)
    800022a0:	e022                	sd	s0,0(sp)
    800022a2:	0800                	addi	s0,sp,16
  struct proc*p=myproc();
    800022a4:	fffff097          	auipc	ra,0xfffff
    800022a8:	bb0080e7          	jalr	-1104(ra) # 80000e54 <myproc>

  p->trapframe_copy->kernel_satp = p->trapframe->kernel_satp;
    800022ac:	18053783          	ld	a5,384(a0)
    800022b0:	6d38                	ld	a4,88(a0)
    800022b2:	6318                	ld	a4,0(a4)
    800022b4:	e398                	sd	a4,0(a5)
  p->trapframe_copy->kernel_sp = p->trapframe->kernel_sp;
    800022b6:	18053783          	ld	a5,384(a0)
    800022ba:	6d38                	ld	a4,88(a0)
    800022bc:	6718                	ld	a4,8(a4)
    800022be:	e798                	sd	a4,8(a5)
  p->trapframe_copy->kernel_trap = p->trapframe->kernel_trap;
    800022c0:	18053783          	ld	a5,384(a0)
    800022c4:	6d38                	ld	a4,88(a0)
    800022c6:	6b18                	ld	a4,16(a4)
    800022c8:	eb98                	sd	a4,16(a5)
  p->trapframe_copy->kernel_hartid = p->trapframe->kernel_hartid;
    800022ca:	18053783          	ld	a5,384(a0)
    800022ce:	6d38                	ld	a4,88(a0)
    800022d0:	7318                	ld	a4,32(a4)
    800022d2:	f398                	sd	a4,32(a5)
  *(p->trapframe) = *(p->trapframe_copy);
    800022d4:	18053683          	ld	a3,384(a0)
    800022d8:	87b6                	mv	a5,a3
    800022da:	6d38                	ld	a4,88(a0)
    800022dc:	12068693          	addi	a3,a3,288
    800022e0:	0007b803          	ld	a6,0(a5)
    800022e4:	6788                	ld	a0,8(a5)
    800022e6:	6b8c                	ld	a1,16(a5)
    800022e8:	6f90                	ld	a2,24(a5)
    800022ea:	01073023          	sd	a6,0(a4)
    800022ee:	e708                	sd	a0,8(a4)
    800022f0:	eb0c                	sd	a1,16(a4)
    800022f2:	ef10                	sd	a2,24(a4)
    800022f4:	02078793          	addi	a5,a5,32
    800022f8:	02070713          	addi	a4,a4,32
    800022fc:	fed792e3          	bne	a5,a3,800022e0 <restore+0x44>
}
    80002300:	60a2                	ld	ra,8(sp)
    80002302:	6402                	ld	s0,0(sp)
    80002304:	0141                	addi	sp,sp,16
    80002306:	8082                	ret

0000000080002308 <sys_sigalarm>:

uint64 sys_sigalarm(void){
    80002308:	1101                	addi	sp,sp,-32
    8000230a:	ec06                	sd	ra,24(sp)
    8000230c:	e822                	sd	s0,16(sp)
    8000230e:	1000                	addi	s0,sp,32
    int ticks;
    argint(0, &ticks);
    80002310:	fec40593          	addi	a1,s0,-20
    80002314:	4501                	li	a0,0
    80002316:	00000097          	auipc	ra,0x0
    8000231a:	cb4080e7          	jalr	-844(ra) # 80001fca <argint>
    if(ticks < 0)
    8000231e:	fec42783          	lw	a5,-20(s0)
      return -1;
    80002322:	557d                	li	a0,-1
    if(ticks < 0)
    80002324:	0407c663          	bltz	a5,80002370 <sys_sigalarm+0x68>
    uint64 handler;
    argaddr(1, &handler);
    80002328:	fe040593          	addi	a1,s0,-32
    8000232c:	4505                	li	a0,1
    8000232e:	00000097          	auipc	ra,0x0
    80002332:	cbc080e7          	jalr	-836(ra) # 80001fea <argaddr>
    if(handler < 0)
      return -1;
    myproc()->is_sigalarm = 0;
    80002336:	fffff097          	auipc	ra,0xfffff
    8000233a:	b1e080e7          	jalr	-1250(ra) # 80000e54 <myproc>
    8000233e:	16052823          	sw	zero,368(a0)
    myproc()->alarm_ticks = ticks;
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	b12080e7          	jalr	-1262(ra) # 80000e54 <myproc>
    8000234a:	fec42783          	lw	a5,-20(s0)
    8000234e:	16f52423          	sw	a5,360(a0)
    myproc()->now_ticks = 0;
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	b02080e7          	jalr	-1278(ra) # 80000e54 <myproc>
    8000235a:	16052623          	sw	zero,364(a0)
    myproc()->alarm_handler = handler;
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	af6080e7          	jalr	-1290(ra) # 80000e54 <myproc>
    80002366:	fe043783          	ld	a5,-32(s0)
    8000236a:	16f53c23          	sd	a5,376(a0)
    return 0;
    8000236e:	4501                	li	a0,0
}
    80002370:	60e2                	ld	ra,24(sp)
    80002372:	6442                	ld	s0,16(sp)
    80002374:	6105                	addi	sp,sp,32
    80002376:	8082                	ret

0000000080002378 <sys_sigreturn>:

uint64 sys_sigreturn(void){
    80002378:	1141                	addi	sp,sp,-16
    8000237a:	e406                	sd	ra,8(sp)
    8000237c:	e022                	sd	s0,0(sp)
    8000237e:	0800                	addi	s0,sp,16
  restore();
    80002380:	00000097          	auipc	ra,0x0
    80002384:	f1c080e7          	jalr	-228(ra) # 8000229c <restore>
  myproc()->is_sigalarm = 0;
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	acc080e7          	jalr	-1332(ra) # 80000e54 <myproc>
    80002390:	16052823          	sw	zero,368(a0)
  return 0;
    80002394:	4501                	li	a0,0
    80002396:	60a2                	ld	ra,8(sp)
    80002398:	6402                	ld	s0,0(sp)
    8000239a:	0141                	addi	sp,sp,16
    8000239c:	8082                	ret

000000008000239e <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000239e:	7179                	addi	sp,sp,-48
    800023a0:	f406                	sd	ra,40(sp)
    800023a2:	f022                	sd	s0,32(sp)
    800023a4:	ec26                	sd	s1,24(sp)
    800023a6:	e84a                	sd	s2,16(sp)
    800023a8:	e44e                	sd	s3,8(sp)
    800023aa:	e052                	sd	s4,0(sp)
    800023ac:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800023ae:	00006597          	auipc	a1,0x6
    800023b2:	0ea58593          	addi	a1,a1,234 # 80008498 <syscalls+0xc8>
    800023b6:	0000d517          	auipc	a0,0xd
    800023ba:	bb250513          	addi	a0,a0,-1102 # 8000ef68 <bcache>
    800023be:	00004097          	auipc	ra,0x4
    800023c2:	de6080e7          	jalr	-538(ra) # 800061a4 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800023c6:	00015797          	auipc	a5,0x15
    800023ca:	ba278793          	addi	a5,a5,-1118 # 80016f68 <bcache+0x8000>
    800023ce:	00015717          	auipc	a4,0x15
    800023d2:	e0270713          	addi	a4,a4,-510 # 800171d0 <bcache+0x8268>
    800023d6:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800023da:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800023de:	0000d497          	auipc	s1,0xd
    800023e2:	ba248493          	addi	s1,s1,-1118 # 8000ef80 <bcache+0x18>
    b->next = bcache.head.next;
    800023e6:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800023e8:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800023ea:	00006a17          	auipc	s4,0x6
    800023ee:	0b6a0a13          	addi	s4,s4,182 # 800084a0 <syscalls+0xd0>
    b->next = bcache.head.next;
    800023f2:	2b893783          	ld	a5,696(s2)
    800023f6:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800023f8:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800023fc:	85d2                	mv	a1,s4
    800023fe:	01048513          	addi	a0,s1,16
    80002402:	00001097          	auipc	ra,0x1
    80002406:	4c8080e7          	jalr	1224(ra) # 800038ca <initsleeplock>
    bcache.head.next->prev = b;
    8000240a:	2b893783          	ld	a5,696(s2)
    8000240e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002410:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002414:	45848493          	addi	s1,s1,1112
    80002418:	fd349de3          	bne	s1,s3,800023f2 <binit+0x54>
  }
}
    8000241c:	70a2                	ld	ra,40(sp)
    8000241e:	7402                	ld	s0,32(sp)
    80002420:	64e2                	ld	s1,24(sp)
    80002422:	6942                	ld	s2,16(sp)
    80002424:	69a2                	ld	s3,8(sp)
    80002426:	6a02                	ld	s4,0(sp)
    80002428:	6145                	addi	sp,sp,48
    8000242a:	8082                	ret

000000008000242c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000242c:	7179                	addi	sp,sp,-48
    8000242e:	f406                	sd	ra,40(sp)
    80002430:	f022                	sd	s0,32(sp)
    80002432:	ec26                	sd	s1,24(sp)
    80002434:	e84a                	sd	s2,16(sp)
    80002436:	e44e                	sd	s3,8(sp)
    80002438:	1800                	addi	s0,sp,48
    8000243a:	892a                	mv	s2,a0
    8000243c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000243e:	0000d517          	auipc	a0,0xd
    80002442:	b2a50513          	addi	a0,a0,-1238 # 8000ef68 <bcache>
    80002446:	00004097          	auipc	ra,0x4
    8000244a:	dee080e7          	jalr	-530(ra) # 80006234 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000244e:	00015497          	auipc	s1,0x15
    80002452:	dd24b483          	ld	s1,-558(s1) # 80017220 <bcache+0x82b8>
    80002456:	00015797          	auipc	a5,0x15
    8000245a:	d7a78793          	addi	a5,a5,-646 # 800171d0 <bcache+0x8268>
    8000245e:	02f48f63          	beq	s1,a5,8000249c <bread+0x70>
    80002462:	873e                	mv	a4,a5
    80002464:	a021                	j	8000246c <bread+0x40>
    80002466:	68a4                	ld	s1,80(s1)
    80002468:	02e48a63          	beq	s1,a4,8000249c <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000246c:	449c                	lw	a5,8(s1)
    8000246e:	ff279ce3          	bne	a5,s2,80002466 <bread+0x3a>
    80002472:	44dc                	lw	a5,12(s1)
    80002474:	ff3799e3          	bne	a5,s3,80002466 <bread+0x3a>
      b->refcnt++;
    80002478:	40bc                	lw	a5,64(s1)
    8000247a:	2785                	addiw	a5,a5,1
    8000247c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000247e:	0000d517          	auipc	a0,0xd
    80002482:	aea50513          	addi	a0,a0,-1302 # 8000ef68 <bcache>
    80002486:	00004097          	auipc	ra,0x4
    8000248a:	e62080e7          	jalr	-414(ra) # 800062e8 <release>
      acquiresleep(&b->lock);
    8000248e:	01048513          	addi	a0,s1,16
    80002492:	00001097          	auipc	ra,0x1
    80002496:	472080e7          	jalr	1138(ra) # 80003904 <acquiresleep>
      return b;
    8000249a:	a8b9                	j	800024f8 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000249c:	00015497          	auipc	s1,0x15
    800024a0:	d7c4b483          	ld	s1,-644(s1) # 80017218 <bcache+0x82b0>
    800024a4:	00015797          	auipc	a5,0x15
    800024a8:	d2c78793          	addi	a5,a5,-724 # 800171d0 <bcache+0x8268>
    800024ac:	00f48863          	beq	s1,a5,800024bc <bread+0x90>
    800024b0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800024b2:	40bc                	lw	a5,64(s1)
    800024b4:	cf81                	beqz	a5,800024cc <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800024b6:	64a4                	ld	s1,72(s1)
    800024b8:	fee49de3          	bne	s1,a4,800024b2 <bread+0x86>
  panic("bget: no buffers");
    800024bc:	00006517          	auipc	a0,0x6
    800024c0:	fec50513          	addi	a0,a0,-20 # 800084a8 <syscalls+0xd8>
    800024c4:	00004097          	auipc	ra,0x4
    800024c8:	838080e7          	jalr	-1992(ra) # 80005cfc <panic>
      b->dev = dev;
    800024cc:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800024d0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800024d4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800024d8:	4785                	li	a5,1
    800024da:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800024dc:	0000d517          	auipc	a0,0xd
    800024e0:	a8c50513          	addi	a0,a0,-1396 # 8000ef68 <bcache>
    800024e4:	00004097          	auipc	ra,0x4
    800024e8:	e04080e7          	jalr	-508(ra) # 800062e8 <release>
      acquiresleep(&b->lock);
    800024ec:	01048513          	addi	a0,s1,16
    800024f0:	00001097          	auipc	ra,0x1
    800024f4:	414080e7          	jalr	1044(ra) # 80003904 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800024f8:	409c                	lw	a5,0(s1)
    800024fa:	cb89                	beqz	a5,8000250c <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800024fc:	8526                	mv	a0,s1
    800024fe:	70a2                	ld	ra,40(sp)
    80002500:	7402                	ld	s0,32(sp)
    80002502:	64e2                	ld	s1,24(sp)
    80002504:	6942                	ld	s2,16(sp)
    80002506:	69a2                	ld	s3,8(sp)
    80002508:	6145                	addi	sp,sp,48
    8000250a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000250c:	4581                	li	a1,0
    8000250e:	8526                	mv	a0,s1
    80002510:	00003097          	auipc	ra,0x3
    80002514:	fe2080e7          	jalr	-30(ra) # 800054f2 <virtio_disk_rw>
    b->valid = 1;
    80002518:	4785                	li	a5,1
    8000251a:	c09c                	sw	a5,0(s1)
  return b;
    8000251c:	b7c5                	j	800024fc <bread+0xd0>

000000008000251e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000251e:	1101                	addi	sp,sp,-32
    80002520:	ec06                	sd	ra,24(sp)
    80002522:	e822                	sd	s0,16(sp)
    80002524:	e426                	sd	s1,8(sp)
    80002526:	1000                	addi	s0,sp,32
    80002528:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000252a:	0541                	addi	a0,a0,16
    8000252c:	00001097          	auipc	ra,0x1
    80002530:	472080e7          	jalr	1138(ra) # 8000399e <holdingsleep>
    80002534:	cd01                	beqz	a0,8000254c <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002536:	4585                	li	a1,1
    80002538:	8526                	mv	a0,s1
    8000253a:	00003097          	auipc	ra,0x3
    8000253e:	fb8080e7          	jalr	-72(ra) # 800054f2 <virtio_disk_rw>
}
    80002542:	60e2                	ld	ra,24(sp)
    80002544:	6442                	ld	s0,16(sp)
    80002546:	64a2                	ld	s1,8(sp)
    80002548:	6105                	addi	sp,sp,32
    8000254a:	8082                	ret
    panic("bwrite");
    8000254c:	00006517          	auipc	a0,0x6
    80002550:	f7450513          	addi	a0,a0,-140 # 800084c0 <syscalls+0xf0>
    80002554:	00003097          	auipc	ra,0x3
    80002558:	7a8080e7          	jalr	1960(ra) # 80005cfc <panic>

000000008000255c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000255c:	1101                	addi	sp,sp,-32
    8000255e:	ec06                	sd	ra,24(sp)
    80002560:	e822                	sd	s0,16(sp)
    80002562:	e426                	sd	s1,8(sp)
    80002564:	e04a                	sd	s2,0(sp)
    80002566:	1000                	addi	s0,sp,32
    80002568:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000256a:	01050913          	addi	s2,a0,16
    8000256e:	854a                	mv	a0,s2
    80002570:	00001097          	auipc	ra,0x1
    80002574:	42e080e7          	jalr	1070(ra) # 8000399e <holdingsleep>
    80002578:	c92d                	beqz	a0,800025ea <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000257a:	854a                	mv	a0,s2
    8000257c:	00001097          	auipc	ra,0x1
    80002580:	3de080e7          	jalr	990(ra) # 8000395a <releasesleep>

  acquire(&bcache.lock);
    80002584:	0000d517          	auipc	a0,0xd
    80002588:	9e450513          	addi	a0,a0,-1564 # 8000ef68 <bcache>
    8000258c:	00004097          	auipc	ra,0x4
    80002590:	ca8080e7          	jalr	-856(ra) # 80006234 <acquire>
  b->refcnt--;
    80002594:	40bc                	lw	a5,64(s1)
    80002596:	37fd                	addiw	a5,a5,-1
    80002598:	0007871b          	sext.w	a4,a5
    8000259c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000259e:	eb05                	bnez	a4,800025ce <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800025a0:	68bc                	ld	a5,80(s1)
    800025a2:	64b8                	ld	a4,72(s1)
    800025a4:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800025a6:	64bc                	ld	a5,72(s1)
    800025a8:	68b8                	ld	a4,80(s1)
    800025aa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800025ac:	00015797          	auipc	a5,0x15
    800025b0:	9bc78793          	addi	a5,a5,-1604 # 80016f68 <bcache+0x8000>
    800025b4:	2b87b703          	ld	a4,696(a5)
    800025b8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800025ba:	00015717          	auipc	a4,0x15
    800025be:	c1670713          	addi	a4,a4,-1002 # 800171d0 <bcache+0x8268>
    800025c2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800025c4:	2b87b703          	ld	a4,696(a5)
    800025c8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800025ca:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800025ce:	0000d517          	auipc	a0,0xd
    800025d2:	99a50513          	addi	a0,a0,-1638 # 8000ef68 <bcache>
    800025d6:	00004097          	auipc	ra,0x4
    800025da:	d12080e7          	jalr	-750(ra) # 800062e8 <release>
}
    800025de:	60e2                	ld	ra,24(sp)
    800025e0:	6442                	ld	s0,16(sp)
    800025e2:	64a2                	ld	s1,8(sp)
    800025e4:	6902                	ld	s2,0(sp)
    800025e6:	6105                	addi	sp,sp,32
    800025e8:	8082                	ret
    panic("brelse");
    800025ea:	00006517          	auipc	a0,0x6
    800025ee:	ede50513          	addi	a0,a0,-290 # 800084c8 <syscalls+0xf8>
    800025f2:	00003097          	auipc	ra,0x3
    800025f6:	70a080e7          	jalr	1802(ra) # 80005cfc <panic>

00000000800025fa <bpin>:

void
bpin(struct buf *b) {
    800025fa:	1101                	addi	sp,sp,-32
    800025fc:	ec06                	sd	ra,24(sp)
    800025fe:	e822                	sd	s0,16(sp)
    80002600:	e426                	sd	s1,8(sp)
    80002602:	1000                	addi	s0,sp,32
    80002604:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002606:	0000d517          	auipc	a0,0xd
    8000260a:	96250513          	addi	a0,a0,-1694 # 8000ef68 <bcache>
    8000260e:	00004097          	auipc	ra,0x4
    80002612:	c26080e7          	jalr	-986(ra) # 80006234 <acquire>
  b->refcnt++;
    80002616:	40bc                	lw	a5,64(s1)
    80002618:	2785                	addiw	a5,a5,1
    8000261a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000261c:	0000d517          	auipc	a0,0xd
    80002620:	94c50513          	addi	a0,a0,-1716 # 8000ef68 <bcache>
    80002624:	00004097          	auipc	ra,0x4
    80002628:	cc4080e7          	jalr	-828(ra) # 800062e8 <release>
}
    8000262c:	60e2                	ld	ra,24(sp)
    8000262e:	6442                	ld	s0,16(sp)
    80002630:	64a2                	ld	s1,8(sp)
    80002632:	6105                	addi	sp,sp,32
    80002634:	8082                	ret

0000000080002636 <bunpin>:

void
bunpin(struct buf *b) {
    80002636:	1101                	addi	sp,sp,-32
    80002638:	ec06                	sd	ra,24(sp)
    8000263a:	e822                	sd	s0,16(sp)
    8000263c:	e426                	sd	s1,8(sp)
    8000263e:	1000                	addi	s0,sp,32
    80002640:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002642:	0000d517          	auipc	a0,0xd
    80002646:	92650513          	addi	a0,a0,-1754 # 8000ef68 <bcache>
    8000264a:	00004097          	auipc	ra,0x4
    8000264e:	bea080e7          	jalr	-1046(ra) # 80006234 <acquire>
  b->refcnt--;
    80002652:	40bc                	lw	a5,64(s1)
    80002654:	37fd                	addiw	a5,a5,-1
    80002656:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002658:	0000d517          	auipc	a0,0xd
    8000265c:	91050513          	addi	a0,a0,-1776 # 8000ef68 <bcache>
    80002660:	00004097          	auipc	ra,0x4
    80002664:	c88080e7          	jalr	-888(ra) # 800062e8 <release>
}
    80002668:	60e2                	ld	ra,24(sp)
    8000266a:	6442                	ld	s0,16(sp)
    8000266c:	64a2                	ld	s1,8(sp)
    8000266e:	6105                	addi	sp,sp,32
    80002670:	8082                	ret

0000000080002672 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002672:	1101                	addi	sp,sp,-32
    80002674:	ec06                	sd	ra,24(sp)
    80002676:	e822                	sd	s0,16(sp)
    80002678:	e426                	sd	s1,8(sp)
    8000267a:	e04a                	sd	s2,0(sp)
    8000267c:	1000                	addi	s0,sp,32
    8000267e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002680:	00d5d59b          	srliw	a1,a1,0xd
    80002684:	00015797          	auipc	a5,0x15
    80002688:	fc07a783          	lw	a5,-64(a5) # 80017644 <sb+0x1c>
    8000268c:	9dbd                	addw	a1,a1,a5
    8000268e:	00000097          	auipc	ra,0x0
    80002692:	d9e080e7          	jalr	-610(ra) # 8000242c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002696:	0074f713          	andi	a4,s1,7
    8000269a:	4785                	li	a5,1
    8000269c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800026a0:	14ce                	slli	s1,s1,0x33
    800026a2:	90d9                	srli	s1,s1,0x36
    800026a4:	00950733          	add	a4,a0,s1
    800026a8:	05874703          	lbu	a4,88(a4)
    800026ac:	00e7f6b3          	and	a3,a5,a4
    800026b0:	c69d                	beqz	a3,800026de <bfree+0x6c>
    800026b2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800026b4:	94aa                	add	s1,s1,a0
    800026b6:	fff7c793          	not	a5,a5
    800026ba:	8f7d                	and	a4,a4,a5
    800026bc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800026c0:	00001097          	auipc	ra,0x1
    800026c4:	126080e7          	jalr	294(ra) # 800037e6 <log_write>
  brelse(bp);
    800026c8:	854a                	mv	a0,s2
    800026ca:	00000097          	auipc	ra,0x0
    800026ce:	e92080e7          	jalr	-366(ra) # 8000255c <brelse>
}
    800026d2:	60e2                	ld	ra,24(sp)
    800026d4:	6442                	ld	s0,16(sp)
    800026d6:	64a2                	ld	s1,8(sp)
    800026d8:	6902                	ld	s2,0(sp)
    800026da:	6105                	addi	sp,sp,32
    800026dc:	8082                	ret
    panic("freeing free block");
    800026de:	00006517          	auipc	a0,0x6
    800026e2:	df250513          	addi	a0,a0,-526 # 800084d0 <syscalls+0x100>
    800026e6:	00003097          	auipc	ra,0x3
    800026ea:	616080e7          	jalr	1558(ra) # 80005cfc <panic>

00000000800026ee <balloc>:
{
    800026ee:	711d                	addi	sp,sp,-96
    800026f0:	ec86                	sd	ra,88(sp)
    800026f2:	e8a2                	sd	s0,80(sp)
    800026f4:	e4a6                	sd	s1,72(sp)
    800026f6:	e0ca                	sd	s2,64(sp)
    800026f8:	fc4e                	sd	s3,56(sp)
    800026fa:	f852                	sd	s4,48(sp)
    800026fc:	f456                	sd	s5,40(sp)
    800026fe:	f05a                	sd	s6,32(sp)
    80002700:	ec5e                	sd	s7,24(sp)
    80002702:	e862                	sd	s8,16(sp)
    80002704:	e466                	sd	s9,8(sp)
    80002706:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002708:	00015797          	auipc	a5,0x15
    8000270c:	f247a783          	lw	a5,-220(a5) # 8001762c <sb+0x4>
    80002710:	cff5                	beqz	a5,8000280c <balloc+0x11e>
    80002712:	8baa                	mv	s7,a0
    80002714:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002716:	00015b17          	auipc	s6,0x15
    8000271a:	f12b0b13          	addi	s6,s6,-238 # 80017628 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000271e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002720:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002722:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002724:	6c89                	lui	s9,0x2
    80002726:	a061                	j	800027ae <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002728:	97ca                	add	a5,a5,s2
    8000272a:	8e55                	or	a2,a2,a3
    8000272c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002730:	854a                	mv	a0,s2
    80002732:	00001097          	auipc	ra,0x1
    80002736:	0b4080e7          	jalr	180(ra) # 800037e6 <log_write>
        brelse(bp);
    8000273a:	854a                	mv	a0,s2
    8000273c:	00000097          	auipc	ra,0x0
    80002740:	e20080e7          	jalr	-480(ra) # 8000255c <brelse>
  bp = bread(dev, bno);
    80002744:	85a6                	mv	a1,s1
    80002746:	855e                	mv	a0,s7
    80002748:	00000097          	auipc	ra,0x0
    8000274c:	ce4080e7          	jalr	-796(ra) # 8000242c <bread>
    80002750:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002752:	40000613          	li	a2,1024
    80002756:	4581                	li	a1,0
    80002758:	05850513          	addi	a0,a0,88
    8000275c:	ffffe097          	auipc	ra,0xffffe
    80002760:	a1e080e7          	jalr	-1506(ra) # 8000017a <memset>
  log_write(bp);
    80002764:	854a                	mv	a0,s2
    80002766:	00001097          	auipc	ra,0x1
    8000276a:	080080e7          	jalr	128(ra) # 800037e6 <log_write>
  brelse(bp);
    8000276e:	854a                	mv	a0,s2
    80002770:	00000097          	auipc	ra,0x0
    80002774:	dec080e7          	jalr	-532(ra) # 8000255c <brelse>
}
    80002778:	8526                	mv	a0,s1
    8000277a:	60e6                	ld	ra,88(sp)
    8000277c:	6446                	ld	s0,80(sp)
    8000277e:	64a6                	ld	s1,72(sp)
    80002780:	6906                	ld	s2,64(sp)
    80002782:	79e2                	ld	s3,56(sp)
    80002784:	7a42                	ld	s4,48(sp)
    80002786:	7aa2                	ld	s5,40(sp)
    80002788:	7b02                	ld	s6,32(sp)
    8000278a:	6be2                	ld	s7,24(sp)
    8000278c:	6c42                	ld	s8,16(sp)
    8000278e:	6ca2                	ld	s9,8(sp)
    80002790:	6125                	addi	sp,sp,96
    80002792:	8082                	ret
    brelse(bp);
    80002794:	854a                	mv	a0,s2
    80002796:	00000097          	auipc	ra,0x0
    8000279a:	dc6080e7          	jalr	-570(ra) # 8000255c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000279e:	015c87bb          	addw	a5,s9,s5
    800027a2:	00078a9b          	sext.w	s5,a5
    800027a6:	004b2703          	lw	a4,4(s6)
    800027aa:	06eaf163          	bgeu	s5,a4,8000280c <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800027ae:	41fad79b          	sraiw	a5,s5,0x1f
    800027b2:	0137d79b          	srliw	a5,a5,0x13
    800027b6:	015787bb          	addw	a5,a5,s5
    800027ba:	40d7d79b          	sraiw	a5,a5,0xd
    800027be:	01cb2583          	lw	a1,28(s6)
    800027c2:	9dbd                	addw	a1,a1,a5
    800027c4:	855e                	mv	a0,s7
    800027c6:	00000097          	auipc	ra,0x0
    800027ca:	c66080e7          	jalr	-922(ra) # 8000242c <bread>
    800027ce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800027d0:	004b2503          	lw	a0,4(s6)
    800027d4:	000a849b          	sext.w	s1,s5
    800027d8:	8762                	mv	a4,s8
    800027da:	faa4fde3          	bgeu	s1,a0,80002794 <balloc+0xa6>
      m = 1 << (bi % 8);
    800027de:	00777693          	andi	a3,a4,7
    800027e2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800027e6:	41f7579b          	sraiw	a5,a4,0x1f
    800027ea:	01d7d79b          	srliw	a5,a5,0x1d
    800027ee:	9fb9                	addw	a5,a5,a4
    800027f0:	4037d79b          	sraiw	a5,a5,0x3
    800027f4:	00f90633          	add	a2,s2,a5
    800027f8:	05864603          	lbu	a2,88(a2)
    800027fc:	00c6f5b3          	and	a1,a3,a2
    80002800:	d585                	beqz	a1,80002728 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002802:	2705                	addiw	a4,a4,1
    80002804:	2485                	addiw	s1,s1,1
    80002806:	fd471ae3          	bne	a4,s4,800027da <balloc+0xec>
    8000280a:	b769                	j	80002794 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000280c:	00006517          	auipc	a0,0x6
    80002810:	cdc50513          	addi	a0,a0,-804 # 800084e8 <syscalls+0x118>
    80002814:	00003097          	auipc	ra,0x3
    80002818:	532080e7          	jalr	1330(ra) # 80005d46 <printf>
  return 0;
    8000281c:	4481                	li	s1,0
    8000281e:	bfa9                	j	80002778 <balloc+0x8a>

0000000080002820 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002820:	7179                	addi	sp,sp,-48
    80002822:	f406                	sd	ra,40(sp)
    80002824:	f022                	sd	s0,32(sp)
    80002826:	ec26                	sd	s1,24(sp)
    80002828:	e84a                	sd	s2,16(sp)
    8000282a:	e44e                	sd	s3,8(sp)
    8000282c:	e052                	sd	s4,0(sp)
    8000282e:	1800                	addi	s0,sp,48
    80002830:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002832:	47ad                	li	a5,11
    80002834:	02b7e863          	bltu	a5,a1,80002864 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80002838:	02059793          	slli	a5,a1,0x20
    8000283c:	01e7d593          	srli	a1,a5,0x1e
    80002840:	00b504b3          	add	s1,a0,a1
    80002844:	0504a903          	lw	s2,80(s1)
    80002848:	06091e63          	bnez	s2,800028c4 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000284c:	4108                	lw	a0,0(a0)
    8000284e:	00000097          	auipc	ra,0x0
    80002852:	ea0080e7          	jalr	-352(ra) # 800026ee <balloc>
    80002856:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000285a:	06090563          	beqz	s2,800028c4 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000285e:	0524a823          	sw	s2,80(s1)
    80002862:	a08d                	j	800028c4 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002864:	ff45849b          	addiw	s1,a1,-12
    80002868:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000286c:	0ff00793          	li	a5,255
    80002870:	08e7e563          	bltu	a5,a4,800028fa <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002874:	08052903          	lw	s2,128(a0)
    80002878:	00091d63          	bnez	s2,80002892 <bmap+0x72>
      addr = balloc(ip->dev);
    8000287c:	4108                	lw	a0,0(a0)
    8000287e:	00000097          	auipc	ra,0x0
    80002882:	e70080e7          	jalr	-400(ra) # 800026ee <balloc>
    80002886:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000288a:	02090d63          	beqz	s2,800028c4 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000288e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002892:	85ca                	mv	a1,s2
    80002894:	0009a503          	lw	a0,0(s3)
    80002898:	00000097          	auipc	ra,0x0
    8000289c:	b94080e7          	jalr	-1132(ra) # 8000242c <bread>
    800028a0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800028a2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800028a6:	02049713          	slli	a4,s1,0x20
    800028aa:	01e75593          	srli	a1,a4,0x1e
    800028ae:	00b784b3          	add	s1,a5,a1
    800028b2:	0004a903          	lw	s2,0(s1)
    800028b6:	02090063          	beqz	s2,800028d6 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800028ba:	8552                	mv	a0,s4
    800028bc:	00000097          	auipc	ra,0x0
    800028c0:	ca0080e7          	jalr	-864(ra) # 8000255c <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800028c4:	854a                	mv	a0,s2
    800028c6:	70a2                	ld	ra,40(sp)
    800028c8:	7402                	ld	s0,32(sp)
    800028ca:	64e2                	ld	s1,24(sp)
    800028cc:	6942                	ld	s2,16(sp)
    800028ce:	69a2                	ld	s3,8(sp)
    800028d0:	6a02                	ld	s4,0(sp)
    800028d2:	6145                	addi	sp,sp,48
    800028d4:	8082                	ret
      addr = balloc(ip->dev);
    800028d6:	0009a503          	lw	a0,0(s3)
    800028da:	00000097          	auipc	ra,0x0
    800028de:	e14080e7          	jalr	-492(ra) # 800026ee <balloc>
    800028e2:	0005091b          	sext.w	s2,a0
      if(addr){
    800028e6:	fc090ae3          	beqz	s2,800028ba <bmap+0x9a>
        a[bn] = addr;
    800028ea:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800028ee:	8552                	mv	a0,s4
    800028f0:	00001097          	auipc	ra,0x1
    800028f4:	ef6080e7          	jalr	-266(ra) # 800037e6 <log_write>
    800028f8:	b7c9                	j	800028ba <bmap+0x9a>
  panic("bmap: out of range");
    800028fa:	00006517          	auipc	a0,0x6
    800028fe:	c0650513          	addi	a0,a0,-1018 # 80008500 <syscalls+0x130>
    80002902:	00003097          	auipc	ra,0x3
    80002906:	3fa080e7          	jalr	1018(ra) # 80005cfc <panic>

000000008000290a <iget>:
{
    8000290a:	7179                	addi	sp,sp,-48
    8000290c:	f406                	sd	ra,40(sp)
    8000290e:	f022                	sd	s0,32(sp)
    80002910:	ec26                	sd	s1,24(sp)
    80002912:	e84a                	sd	s2,16(sp)
    80002914:	e44e                	sd	s3,8(sp)
    80002916:	e052                	sd	s4,0(sp)
    80002918:	1800                	addi	s0,sp,48
    8000291a:	89aa                	mv	s3,a0
    8000291c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000291e:	00015517          	auipc	a0,0x15
    80002922:	d2a50513          	addi	a0,a0,-726 # 80017648 <itable>
    80002926:	00004097          	auipc	ra,0x4
    8000292a:	90e080e7          	jalr	-1778(ra) # 80006234 <acquire>
  empty = 0;
    8000292e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002930:	00015497          	auipc	s1,0x15
    80002934:	d3048493          	addi	s1,s1,-720 # 80017660 <itable+0x18>
    80002938:	00016697          	auipc	a3,0x16
    8000293c:	7b868693          	addi	a3,a3,1976 # 800190f0 <log>
    80002940:	a039                	j	8000294e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002942:	02090b63          	beqz	s2,80002978 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002946:	08848493          	addi	s1,s1,136
    8000294a:	02d48a63          	beq	s1,a3,8000297e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000294e:	449c                	lw	a5,8(s1)
    80002950:	fef059e3          	blez	a5,80002942 <iget+0x38>
    80002954:	4098                	lw	a4,0(s1)
    80002956:	ff3716e3          	bne	a4,s3,80002942 <iget+0x38>
    8000295a:	40d8                	lw	a4,4(s1)
    8000295c:	ff4713e3          	bne	a4,s4,80002942 <iget+0x38>
      ip->ref++;
    80002960:	2785                	addiw	a5,a5,1
    80002962:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002964:	00015517          	auipc	a0,0x15
    80002968:	ce450513          	addi	a0,a0,-796 # 80017648 <itable>
    8000296c:	00004097          	auipc	ra,0x4
    80002970:	97c080e7          	jalr	-1668(ra) # 800062e8 <release>
      return ip;
    80002974:	8926                	mv	s2,s1
    80002976:	a03d                	j	800029a4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002978:	f7f9                	bnez	a5,80002946 <iget+0x3c>
    8000297a:	8926                	mv	s2,s1
    8000297c:	b7e9                	j	80002946 <iget+0x3c>
  if(empty == 0)
    8000297e:	02090c63          	beqz	s2,800029b6 <iget+0xac>
  ip->dev = dev;
    80002982:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002986:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000298a:	4785                	li	a5,1
    8000298c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002990:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002994:	00015517          	auipc	a0,0x15
    80002998:	cb450513          	addi	a0,a0,-844 # 80017648 <itable>
    8000299c:	00004097          	auipc	ra,0x4
    800029a0:	94c080e7          	jalr	-1716(ra) # 800062e8 <release>
}
    800029a4:	854a                	mv	a0,s2
    800029a6:	70a2                	ld	ra,40(sp)
    800029a8:	7402                	ld	s0,32(sp)
    800029aa:	64e2                	ld	s1,24(sp)
    800029ac:	6942                	ld	s2,16(sp)
    800029ae:	69a2                	ld	s3,8(sp)
    800029b0:	6a02                	ld	s4,0(sp)
    800029b2:	6145                	addi	sp,sp,48
    800029b4:	8082                	ret
    panic("iget: no inodes");
    800029b6:	00006517          	auipc	a0,0x6
    800029ba:	b6250513          	addi	a0,a0,-1182 # 80008518 <syscalls+0x148>
    800029be:	00003097          	auipc	ra,0x3
    800029c2:	33e080e7          	jalr	830(ra) # 80005cfc <panic>

00000000800029c6 <fsinit>:
fsinit(int dev) {
    800029c6:	7179                	addi	sp,sp,-48
    800029c8:	f406                	sd	ra,40(sp)
    800029ca:	f022                	sd	s0,32(sp)
    800029cc:	ec26                	sd	s1,24(sp)
    800029ce:	e84a                	sd	s2,16(sp)
    800029d0:	e44e                	sd	s3,8(sp)
    800029d2:	1800                	addi	s0,sp,48
    800029d4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800029d6:	4585                	li	a1,1
    800029d8:	00000097          	auipc	ra,0x0
    800029dc:	a54080e7          	jalr	-1452(ra) # 8000242c <bread>
    800029e0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800029e2:	00015997          	auipc	s3,0x15
    800029e6:	c4698993          	addi	s3,s3,-954 # 80017628 <sb>
    800029ea:	02000613          	li	a2,32
    800029ee:	05850593          	addi	a1,a0,88
    800029f2:	854e                	mv	a0,s3
    800029f4:	ffffd097          	auipc	ra,0xffffd
    800029f8:	7e2080e7          	jalr	2018(ra) # 800001d6 <memmove>
  brelse(bp);
    800029fc:	8526                	mv	a0,s1
    800029fe:	00000097          	auipc	ra,0x0
    80002a02:	b5e080e7          	jalr	-1186(ra) # 8000255c <brelse>
  if(sb.magic != FSMAGIC)
    80002a06:	0009a703          	lw	a4,0(s3)
    80002a0a:	102037b7          	lui	a5,0x10203
    80002a0e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002a12:	02f71263          	bne	a4,a5,80002a36 <fsinit+0x70>
  initlog(dev, &sb);
    80002a16:	00015597          	auipc	a1,0x15
    80002a1a:	c1258593          	addi	a1,a1,-1006 # 80017628 <sb>
    80002a1e:	854a                	mv	a0,s2
    80002a20:	00001097          	auipc	ra,0x1
    80002a24:	b4a080e7          	jalr	-1206(ra) # 8000356a <initlog>
}
    80002a28:	70a2                	ld	ra,40(sp)
    80002a2a:	7402                	ld	s0,32(sp)
    80002a2c:	64e2                	ld	s1,24(sp)
    80002a2e:	6942                	ld	s2,16(sp)
    80002a30:	69a2                	ld	s3,8(sp)
    80002a32:	6145                	addi	sp,sp,48
    80002a34:	8082                	ret
    panic("invalid file system");
    80002a36:	00006517          	auipc	a0,0x6
    80002a3a:	af250513          	addi	a0,a0,-1294 # 80008528 <syscalls+0x158>
    80002a3e:	00003097          	auipc	ra,0x3
    80002a42:	2be080e7          	jalr	702(ra) # 80005cfc <panic>

0000000080002a46 <iinit>:
{
    80002a46:	7179                	addi	sp,sp,-48
    80002a48:	f406                	sd	ra,40(sp)
    80002a4a:	f022                	sd	s0,32(sp)
    80002a4c:	ec26                	sd	s1,24(sp)
    80002a4e:	e84a                	sd	s2,16(sp)
    80002a50:	e44e                	sd	s3,8(sp)
    80002a52:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002a54:	00006597          	auipc	a1,0x6
    80002a58:	aec58593          	addi	a1,a1,-1300 # 80008540 <syscalls+0x170>
    80002a5c:	00015517          	auipc	a0,0x15
    80002a60:	bec50513          	addi	a0,a0,-1044 # 80017648 <itable>
    80002a64:	00003097          	auipc	ra,0x3
    80002a68:	740080e7          	jalr	1856(ra) # 800061a4 <initlock>
  for(i = 0; i < NINODE; i++) {
    80002a6c:	00015497          	auipc	s1,0x15
    80002a70:	c0448493          	addi	s1,s1,-1020 # 80017670 <itable+0x28>
    80002a74:	00016997          	auipc	s3,0x16
    80002a78:	68c98993          	addi	s3,s3,1676 # 80019100 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002a7c:	00006917          	auipc	s2,0x6
    80002a80:	acc90913          	addi	s2,s2,-1332 # 80008548 <syscalls+0x178>
    80002a84:	85ca                	mv	a1,s2
    80002a86:	8526                	mv	a0,s1
    80002a88:	00001097          	auipc	ra,0x1
    80002a8c:	e42080e7          	jalr	-446(ra) # 800038ca <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002a90:	08848493          	addi	s1,s1,136
    80002a94:	ff3498e3          	bne	s1,s3,80002a84 <iinit+0x3e>
}
    80002a98:	70a2                	ld	ra,40(sp)
    80002a9a:	7402                	ld	s0,32(sp)
    80002a9c:	64e2                	ld	s1,24(sp)
    80002a9e:	6942                	ld	s2,16(sp)
    80002aa0:	69a2                	ld	s3,8(sp)
    80002aa2:	6145                	addi	sp,sp,48
    80002aa4:	8082                	ret

0000000080002aa6 <ialloc>:
{
    80002aa6:	715d                	addi	sp,sp,-80
    80002aa8:	e486                	sd	ra,72(sp)
    80002aaa:	e0a2                	sd	s0,64(sp)
    80002aac:	fc26                	sd	s1,56(sp)
    80002aae:	f84a                	sd	s2,48(sp)
    80002ab0:	f44e                	sd	s3,40(sp)
    80002ab2:	f052                	sd	s4,32(sp)
    80002ab4:	ec56                	sd	s5,24(sp)
    80002ab6:	e85a                	sd	s6,16(sp)
    80002ab8:	e45e                	sd	s7,8(sp)
    80002aba:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002abc:	00015717          	auipc	a4,0x15
    80002ac0:	b7872703          	lw	a4,-1160(a4) # 80017634 <sb+0xc>
    80002ac4:	4785                	li	a5,1
    80002ac6:	04e7fa63          	bgeu	a5,a4,80002b1a <ialloc+0x74>
    80002aca:	8aaa                	mv	s5,a0
    80002acc:	8bae                	mv	s7,a1
    80002ace:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002ad0:	00015a17          	auipc	s4,0x15
    80002ad4:	b58a0a13          	addi	s4,s4,-1192 # 80017628 <sb>
    80002ad8:	00048b1b          	sext.w	s6,s1
    80002adc:	0044d593          	srli	a1,s1,0x4
    80002ae0:	018a2783          	lw	a5,24(s4)
    80002ae4:	9dbd                	addw	a1,a1,a5
    80002ae6:	8556                	mv	a0,s5
    80002ae8:	00000097          	auipc	ra,0x0
    80002aec:	944080e7          	jalr	-1724(ra) # 8000242c <bread>
    80002af0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002af2:	05850993          	addi	s3,a0,88
    80002af6:	00f4f793          	andi	a5,s1,15
    80002afa:	079a                	slli	a5,a5,0x6
    80002afc:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002afe:	00099783          	lh	a5,0(s3)
    80002b02:	c3a1                	beqz	a5,80002b42 <ialloc+0x9c>
    brelse(bp);
    80002b04:	00000097          	auipc	ra,0x0
    80002b08:	a58080e7          	jalr	-1448(ra) # 8000255c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002b0c:	0485                	addi	s1,s1,1
    80002b0e:	00ca2703          	lw	a4,12(s4)
    80002b12:	0004879b          	sext.w	a5,s1
    80002b16:	fce7e1e3          	bltu	a5,a4,80002ad8 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002b1a:	00006517          	auipc	a0,0x6
    80002b1e:	a3650513          	addi	a0,a0,-1482 # 80008550 <syscalls+0x180>
    80002b22:	00003097          	auipc	ra,0x3
    80002b26:	224080e7          	jalr	548(ra) # 80005d46 <printf>
  return 0;
    80002b2a:	4501                	li	a0,0
}
    80002b2c:	60a6                	ld	ra,72(sp)
    80002b2e:	6406                	ld	s0,64(sp)
    80002b30:	74e2                	ld	s1,56(sp)
    80002b32:	7942                	ld	s2,48(sp)
    80002b34:	79a2                	ld	s3,40(sp)
    80002b36:	7a02                	ld	s4,32(sp)
    80002b38:	6ae2                	ld	s5,24(sp)
    80002b3a:	6b42                	ld	s6,16(sp)
    80002b3c:	6ba2                	ld	s7,8(sp)
    80002b3e:	6161                	addi	sp,sp,80
    80002b40:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002b42:	04000613          	li	a2,64
    80002b46:	4581                	li	a1,0
    80002b48:	854e                	mv	a0,s3
    80002b4a:	ffffd097          	auipc	ra,0xffffd
    80002b4e:	630080e7          	jalr	1584(ra) # 8000017a <memset>
      dip->type = type;
    80002b52:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002b56:	854a                	mv	a0,s2
    80002b58:	00001097          	auipc	ra,0x1
    80002b5c:	c8e080e7          	jalr	-882(ra) # 800037e6 <log_write>
      brelse(bp);
    80002b60:	854a                	mv	a0,s2
    80002b62:	00000097          	auipc	ra,0x0
    80002b66:	9fa080e7          	jalr	-1542(ra) # 8000255c <brelse>
      return iget(dev, inum);
    80002b6a:	85da                	mv	a1,s6
    80002b6c:	8556                	mv	a0,s5
    80002b6e:	00000097          	auipc	ra,0x0
    80002b72:	d9c080e7          	jalr	-612(ra) # 8000290a <iget>
    80002b76:	bf5d                	j	80002b2c <ialloc+0x86>

0000000080002b78 <iupdate>:
{
    80002b78:	1101                	addi	sp,sp,-32
    80002b7a:	ec06                	sd	ra,24(sp)
    80002b7c:	e822                	sd	s0,16(sp)
    80002b7e:	e426                	sd	s1,8(sp)
    80002b80:	e04a                	sd	s2,0(sp)
    80002b82:	1000                	addi	s0,sp,32
    80002b84:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002b86:	415c                	lw	a5,4(a0)
    80002b88:	0047d79b          	srliw	a5,a5,0x4
    80002b8c:	00015597          	auipc	a1,0x15
    80002b90:	ab45a583          	lw	a1,-1356(a1) # 80017640 <sb+0x18>
    80002b94:	9dbd                	addw	a1,a1,a5
    80002b96:	4108                	lw	a0,0(a0)
    80002b98:	00000097          	auipc	ra,0x0
    80002b9c:	894080e7          	jalr	-1900(ra) # 8000242c <bread>
    80002ba0:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002ba2:	05850793          	addi	a5,a0,88
    80002ba6:	40d8                	lw	a4,4(s1)
    80002ba8:	8b3d                	andi	a4,a4,15
    80002baa:	071a                	slli	a4,a4,0x6
    80002bac:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80002bae:	04449703          	lh	a4,68(s1)
    80002bb2:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80002bb6:	04649703          	lh	a4,70(s1)
    80002bba:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80002bbe:	04849703          	lh	a4,72(s1)
    80002bc2:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80002bc6:	04a49703          	lh	a4,74(s1)
    80002bca:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80002bce:	44f8                	lw	a4,76(s1)
    80002bd0:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002bd2:	03400613          	li	a2,52
    80002bd6:	05048593          	addi	a1,s1,80
    80002bda:	00c78513          	addi	a0,a5,12
    80002bde:	ffffd097          	auipc	ra,0xffffd
    80002be2:	5f8080e7          	jalr	1528(ra) # 800001d6 <memmove>
  log_write(bp);
    80002be6:	854a                	mv	a0,s2
    80002be8:	00001097          	auipc	ra,0x1
    80002bec:	bfe080e7          	jalr	-1026(ra) # 800037e6 <log_write>
  brelse(bp);
    80002bf0:	854a                	mv	a0,s2
    80002bf2:	00000097          	auipc	ra,0x0
    80002bf6:	96a080e7          	jalr	-1686(ra) # 8000255c <brelse>
}
    80002bfa:	60e2                	ld	ra,24(sp)
    80002bfc:	6442                	ld	s0,16(sp)
    80002bfe:	64a2                	ld	s1,8(sp)
    80002c00:	6902                	ld	s2,0(sp)
    80002c02:	6105                	addi	sp,sp,32
    80002c04:	8082                	ret

0000000080002c06 <idup>:
{
    80002c06:	1101                	addi	sp,sp,-32
    80002c08:	ec06                	sd	ra,24(sp)
    80002c0a:	e822                	sd	s0,16(sp)
    80002c0c:	e426                	sd	s1,8(sp)
    80002c0e:	1000                	addi	s0,sp,32
    80002c10:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002c12:	00015517          	auipc	a0,0x15
    80002c16:	a3650513          	addi	a0,a0,-1482 # 80017648 <itable>
    80002c1a:	00003097          	auipc	ra,0x3
    80002c1e:	61a080e7          	jalr	1562(ra) # 80006234 <acquire>
  ip->ref++;
    80002c22:	449c                	lw	a5,8(s1)
    80002c24:	2785                	addiw	a5,a5,1
    80002c26:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002c28:	00015517          	auipc	a0,0x15
    80002c2c:	a2050513          	addi	a0,a0,-1504 # 80017648 <itable>
    80002c30:	00003097          	auipc	ra,0x3
    80002c34:	6b8080e7          	jalr	1720(ra) # 800062e8 <release>
}
    80002c38:	8526                	mv	a0,s1
    80002c3a:	60e2                	ld	ra,24(sp)
    80002c3c:	6442                	ld	s0,16(sp)
    80002c3e:	64a2                	ld	s1,8(sp)
    80002c40:	6105                	addi	sp,sp,32
    80002c42:	8082                	ret

0000000080002c44 <ilock>:
{
    80002c44:	1101                	addi	sp,sp,-32
    80002c46:	ec06                	sd	ra,24(sp)
    80002c48:	e822                	sd	s0,16(sp)
    80002c4a:	e426                	sd	s1,8(sp)
    80002c4c:	e04a                	sd	s2,0(sp)
    80002c4e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002c50:	c115                	beqz	a0,80002c74 <ilock+0x30>
    80002c52:	84aa                	mv	s1,a0
    80002c54:	451c                	lw	a5,8(a0)
    80002c56:	00f05f63          	blez	a5,80002c74 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002c5a:	0541                	addi	a0,a0,16
    80002c5c:	00001097          	auipc	ra,0x1
    80002c60:	ca8080e7          	jalr	-856(ra) # 80003904 <acquiresleep>
  if(ip->valid == 0){
    80002c64:	40bc                	lw	a5,64(s1)
    80002c66:	cf99                	beqz	a5,80002c84 <ilock+0x40>
}
    80002c68:	60e2                	ld	ra,24(sp)
    80002c6a:	6442                	ld	s0,16(sp)
    80002c6c:	64a2                	ld	s1,8(sp)
    80002c6e:	6902                	ld	s2,0(sp)
    80002c70:	6105                	addi	sp,sp,32
    80002c72:	8082                	ret
    panic("ilock");
    80002c74:	00006517          	auipc	a0,0x6
    80002c78:	8f450513          	addi	a0,a0,-1804 # 80008568 <syscalls+0x198>
    80002c7c:	00003097          	auipc	ra,0x3
    80002c80:	080080e7          	jalr	128(ra) # 80005cfc <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002c84:	40dc                	lw	a5,4(s1)
    80002c86:	0047d79b          	srliw	a5,a5,0x4
    80002c8a:	00015597          	auipc	a1,0x15
    80002c8e:	9b65a583          	lw	a1,-1610(a1) # 80017640 <sb+0x18>
    80002c92:	9dbd                	addw	a1,a1,a5
    80002c94:	4088                	lw	a0,0(s1)
    80002c96:	fffff097          	auipc	ra,0xfffff
    80002c9a:	796080e7          	jalr	1942(ra) # 8000242c <bread>
    80002c9e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002ca0:	05850593          	addi	a1,a0,88
    80002ca4:	40dc                	lw	a5,4(s1)
    80002ca6:	8bbd                	andi	a5,a5,15
    80002ca8:	079a                	slli	a5,a5,0x6
    80002caa:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002cac:	00059783          	lh	a5,0(a1)
    80002cb0:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002cb4:	00259783          	lh	a5,2(a1)
    80002cb8:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002cbc:	00459783          	lh	a5,4(a1)
    80002cc0:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002cc4:	00659783          	lh	a5,6(a1)
    80002cc8:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002ccc:	459c                	lw	a5,8(a1)
    80002cce:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002cd0:	03400613          	li	a2,52
    80002cd4:	05b1                	addi	a1,a1,12
    80002cd6:	05048513          	addi	a0,s1,80
    80002cda:	ffffd097          	auipc	ra,0xffffd
    80002cde:	4fc080e7          	jalr	1276(ra) # 800001d6 <memmove>
    brelse(bp);
    80002ce2:	854a                	mv	a0,s2
    80002ce4:	00000097          	auipc	ra,0x0
    80002ce8:	878080e7          	jalr	-1928(ra) # 8000255c <brelse>
    ip->valid = 1;
    80002cec:	4785                	li	a5,1
    80002cee:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002cf0:	04449783          	lh	a5,68(s1)
    80002cf4:	fbb5                	bnez	a5,80002c68 <ilock+0x24>
      panic("ilock: no type");
    80002cf6:	00006517          	auipc	a0,0x6
    80002cfa:	87a50513          	addi	a0,a0,-1926 # 80008570 <syscalls+0x1a0>
    80002cfe:	00003097          	auipc	ra,0x3
    80002d02:	ffe080e7          	jalr	-2(ra) # 80005cfc <panic>

0000000080002d06 <iunlock>:
{
    80002d06:	1101                	addi	sp,sp,-32
    80002d08:	ec06                	sd	ra,24(sp)
    80002d0a:	e822                	sd	s0,16(sp)
    80002d0c:	e426                	sd	s1,8(sp)
    80002d0e:	e04a                	sd	s2,0(sp)
    80002d10:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002d12:	c905                	beqz	a0,80002d42 <iunlock+0x3c>
    80002d14:	84aa                	mv	s1,a0
    80002d16:	01050913          	addi	s2,a0,16
    80002d1a:	854a                	mv	a0,s2
    80002d1c:	00001097          	auipc	ra,0x1
    80002d20:	c82080e7          	jalr	-894(ra) # 8000399e <holdingsleep>
    80002d24:	cd19                	beqz	a0,80002d42 <iunlock+0x3c>
    80002d26:	449c                	lw	a5,8(s1)
    80002d28:	00f05d63          	blez	a5,80002d42 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002d2c:	854a                	mv	a0,s2
    80002d2e:	00001097          	auipc	ra,0x1
    80002d32:	c2c080e7          	jalr	-980(ra) # 8000395a <releasesleep>
}
    80002d36:	60e2                	ld	ra,24(sp)
    80002d38:	6442                	ld	s0,16(sp)
    80002d3a:	64a2                	ld	s1,8(sp)
    80002d3c:	6902                	ld	s2,0(sp)
    80002d3e:	6105                	addi	sp,sp,32
    80002d40:	8082                	ret
    panic("iunlock");
    80002d42:	00006517          	auipc	a0,0x6
    80002d46:	83e50513          	addi	a0,a0,-1986 # 80008580 <syscalls+0x1b0>
    80002d4a:	00003097          	auipc	ra,0x3
    80002d4e:	fb2080e7          	jalr	-78(ra) # 80005cfc <panic>

0000000080002d52 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002d52:	7179                	addi	sp,sp,-48
    80002d54:	f406                	sd	ra,40(sp)
    80002d56:	f022                	sd	s0,32(sp)
    80002d58:	ec26                	sd	s1,24(sp)
    80002d5a:	e84a                	sd	s2,16(sp)
    80002d5c:	e44e                	sd	s3,8(sp)
    80002d5e:	e052                	sd	s4,0(sp)
    80002d60:	1800                	addi	s0,sp,48
    80002d62:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002d64:	05050493          	addi	s1,a0,80
    80002d68:	08050913          	addi	s2,a0,128
    80002d6c:	a021                	j	80002d74 <itrunc+0x22>
    80002d6e:	0491                	addi	s1,s1,4
    80002d70:	01248d63          	beq	s1,s2,80002d8a <itrunc+0x38>
    if(ip->addrs[i]){
    80002d74:	408c                	lw	a1,0(s1)
    80002d76:	dde5                	beqz	a1,80002d6e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002d78:	0009a503          	lw	a0,0(s3)
    80002d7c:	00000097          	auipc	ra,0x0
    80002d80:	8f6080e7          	jalr	-1802(ra) # 80002672 <bfree>
      ip->addrs[i] = 0;
    80002d84:	0004a023          	sw	zero,0(s1)
    80002d88:	b7dd                	j	80002d6e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002d8a:	0809a583          	lw	a1,128(s3)
    80002d8e:	e185                	bnez	a1,80002dae <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002d90:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002d94:	854e                	mv	a0,s3
    80002d96:	00000097          	auipc	ra,0x0
    80002d9a:	de2080e7          	jalr	-542(ra) # 80002b78 <iupdate>
}
    80002d9e:	70a2                	ld	ra,40(sp)
    80002da0:	7402                	ld	s0,32(sp)
    80002da2:	64e2                	ld	s1,24(sp)
    80002da4:	6942                	ld	s2,16(sp)
    80002da6:	69a2                	ld	s3,8(sp)
    80002da8:	6a02                	ld	s4,0(sp)
    80002daa:	6145                	addi	sp,sp,48
    80002dac:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002dae:	0009a503          	lw	a0,0(s3)
    80002db2:	fffff097          	auipc	ra,0xfffff
    80002db6:	67a080e7          	jalr	1658(ra) # 8000242c <bread>
    80002dba:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002dbc:	05850493          	addi	s1,a0,88
    80002dc0:	45850913          	addi	s2,a0,1112
    80002dc4:	a021                	j	80002dcc <itrunc+0x7a>
    80002dc6:	0491                	addi	s1,s1,4
    80002dc8:	01248b63          	beq	s1,s2,80002dde <itrunc+0x8c>
      if(a[j])
    80002dcc:	408c                	lw	a1,0(s1)
    80002dce:	dde5                	beqz	a1,80002dc6 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80002dd0:	0009a503          	lw	a0,0(s3)
    80002dd4:	00000097          	auipc	ra,0x0
    80002dd8:	89e080e7          	jalr	-1890(ra) # 80002672 <bfree>
    80002ddc:	b7ed                	j	80002dc6 <itrunc+0x74>
    brelse(bp);
    80002dde:	8552                	mv	a0,s4
    80002de0:	fffff097          	auipc	ra,0xfffff
    80002de4:	77c080e7          	jalr	1916(ra) # 8000255c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002de8:	0809a583          	lw	a1,128(s3)
    80002dec:	0009a503          	lw	a0,0(s3)
    80002df0:	00000097          	auipc	ra,0x0
    80002df4:	882080e7          	jalr	-1918(ra) # 80002672 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002df8:	0809a023          	sw	zero,128(s3)
    80002dfc:	bf51                	j	80002d90 <itrunc+0x3e>

0000000080002dfe <iput>:
{
    80002dfe:	1101                	addi	sp,sp,-32
    80002e00:	ec06                	sd	ra,24(sp)
    80002e02:	e822                	sd	s0,16(sp)
    80002e04:	e426                	sd	s1,8(sp)
    80002e06:	e04a                	sd	s2,0(sp)
    80002e08:	1000                	addi	s0,sp,32
    80002e0a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002e0c:	00015517          	auipc	a0,0x15
    80002e10:	83c50513          	addi	a0,a0,-1988 # 80017648 <itable>
    80002e14:	00003097          	auipc	ra,0x3
    80002e18:	420080e7          	jalr	1056(ra) # 80006234 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002e1c:	4498                	lw	a4,8(s1)
    80002e1e:	4785                	li	a5,1
    80002e20:	02f70363          	beq	a4,a5,80002e46 <iput+0x48>
  ip->ref--;
    80002e24:	449c                	lw	a5,8(s1)
    80002e26:	37fd                	addiw	a5,a5,-1
    80002e28:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002e2a:	00015517          	auipc	a0,0x15
    80002e2e:	81e50513          	addi	a0,a0,-2018 # 80017648 <itable>
    80002e32:	00003097          	auipc	ra,0x3
    80002e36:	4b6080e7          	jalr	1206(ra) # 800062e8 <release>
}
    80002e3a:	60e2                	ld	ra,24(sp)
    80002e3c:	6442                	ld	s0,16(sp)
    80002e3e:	64a2                	ld	s1,8(sp)
    80002e40:	6902                	ld	s2,0(sp)
    80002e42:	6105                	addi	sp,sp,32
    80002e44:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002e46:	40bc                	lw	a5,64(s1)
    80002e48:	dff1                	beqz	a5,80002e24 <iput+0x26>
    80002e4a:	04a49783          	lh	a5,74(s1)
    80002e4e:	fbf9                	bnez	a5,80002e24 <iput+0x26>
    acquiresleep(&ip->lock);
    80002e50:	01048913          	addi	s2,s1,16
    80002e54:	854a                	mv	a0,s2
    80002e56:	00001097          	auipc	ra,0x1
    80002e5a:	aae080e7          	jalr	-1362(ra) # 80003904 <acquiresleep>
    release(&itable.lock);
    80002e5e:	00014517          	auipc	a0,0x14
    80002e62:	7ea50513          	addi	a0,a0,2026 # 80017648 <itable>
    80002e66:	00003097          	auipc	ra,0x3
    80002e6a:	482080e7          	jalr	1154(ra) # 800062e8 <release>
    itrunc(ip);
    80002e6e:	8526                	mv	a0,s1
    80002e70:	00000097          	auipc	ra,0x0
    80002e74:	ee2080e7          	jalr	-286(ra) # 80002d52 <itrunc>
    ip->type = 0;
    80002e78:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002e7c:	8526                	mv	a0,s1
    80002e7e:	00000097          	auipc	ra,0x0
    80002e82:	cfa080e7          	jalr	-774(ra) # 80002b78 <iupdate>
    ip->valid = 0;
    80002e86:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002e8a:	854a                	mv	a0,s2
    80002e8c:	00001097          	auipc	ra,0x1
    80002e90:	ace080e7          	jalr	-1330(ra) # 8000395a <releasesleep>
    acquire(&itable.lock);
    80002e94:	00014517          	auipc	a0,0x14
    80002e98:	7b450513          	addi	a0,a0,1972 # 80017648 <itable>
    80002e9c:	00003097          	auipc	ra,0x3
    80002ea0:	398080e7          	jalr	920(ra) # 80006234 <acquire>
    80002ea4:	b741                	j	80002e24 <iput+0x26>

0000000080002ea6 <iunlockput>:
{
    80002ea6:	1101                	addi	sp,sp,-32
    80002ea8:	ec06                	sd	ra,24(sp)
    80002eaa:	e822                	sd	s0,16(sp)
    80002eac:	e426                	sd	s1,8(sp)
    80002eae:	1000                	addi	s0,sp,32
    80002eb0:	84aa                	mv	s1,a0
  iunlock(ip);
    80002eb2:	00000097          	auipc	ra,0x0
    80002eb6:	e54080e7          	jalr	-428(ra) # 80002d06 <iunlock>
  iput(ip);
    80002eba:	8526                	mv	a0,s1
    80002ebc:	00000097          	auipc	ra,0x0
    80002ec0:	f42080e7          	jalr	-190(ra) # 80002dfe <iput>
}
    80002ec4:	60e2                	ld	ra,24(sp)
    80002ec6:	6442                	ld	s0,16(sp)
    80002ec8:	64a2                	ld	s1,8(sp)
    80002eca:	6105                	addi	sp,sp,32
    80002ecc:	8082                	ret

0000000080002ece <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002ece:	1141                	addi	sp,sp,-16
    80002ed0:	e422                	sd	s0,8(sp)
    80002ed2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002ed4:	411c                	lw	a5,0(a0)
    80002ed6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002ed8:	415c                	lw	a5,4(a0)
    80002eda:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002edc:	04451783          	lh	a5,68(a0)
    80002ee0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002ee4:	04a51783          	lh	a5,74(a0)
    80002ee8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002eec:	04c56783          	lwu	a5,76(a0)
    80002ef0:	e99c                	sd	a5,16(a1)
}
    80002ef2:	6422                	ld	s0,8(sp)
    80002ef4:	0141                	addi	sp,sp,16
    80002ef6:	8082                	ret

0000000080002ef8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002ef8:	457c                	lw	a5,76(a0)
    80002efa:	0ed7e963          	bltu	a5,a3,80002fec <readi+0xf4>
{
    80002efe:	7159                	addi	sp,sp,-112
    80002f00:	f486                	sd	ra,104(sp)
    80002f02:	f0a2                	sd	s0,96(sp)
    80002f04:	eca6                	sd	s1,88(sp)
    80002f06:	e8ca                	sd	s2,80(sp)
    80002f08:	e4ce                	sd	s3,72(sp)
    80002f0a:	e0d2                	sd	s4,64(sp)
    80002f0c:	fc56                	sd	s5,56(sp)
    80002f0e:	f85a                	sd	s6,48(sp)
    80002f10:	f45e                	sd	s7,40(sp)
    80002f12:	f062                	sd	s8,32(sp)
    80002f14:	ec66                	sd	s9,24(sp)
    80002f16:	e86a                	sd	s10,16(sp)
    80002f18:	e46e                	sd	s11,8(sp)
    80002f1a:	1880                	addi	s0,sp,112
    80002f1c:	8b2a                	mv	s6,a0
    80002f1e:	8bae                	mv	s7,a1
    80002f20:	8a32                	mv	s4,a2
    80002f22:	84b6                	mv	s1,a3
    80002f24:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80002f26:	9f35                	addw	a4,a4,a3
    return 0;
    80002f28:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002f2a:	0ad76063          	bltu	a4,a3,80002fca <readi+0xd2>
  if(off + n > ip->size)
    80002f2e:	00e7f463          	bgeu	a5,a4,80002f36 <readi+0x3e>
    n = ip->size - off;
    80002f32:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f36:	0a0a8963          	beqz	s5,80002fe8 <readi+0xf0>
    80002f3a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f3c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002f40:	5c7d                	li	s8,-1
    80002f42:	a82d                	j	80002f7c <readi+0x84>
    80002f44:	020d1d93          	slli	s11,s10,0x20
    80002f48:	020ddd93          	srli	s11,s11,0x20
    80002f4c:	05890613          	addi	a2,s2,88
    80002f50:	86ee                	mv	a3,s11
    80002f52:	963a                	add	a2,a2,a4
    80002f54:	85d2                	mv	a1,s4
    80002f56:	855e                	mv	a0,s7
    80002f58:	fffff097          	auipc	ra,0xfffff
    80002f5c:	9b6080e7          	jalr	-1610(ra) # 8000190e <either_copyout>
    80002f60:	05850d63          	beq	a0,s8,80002fba <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002f64:	854a                	mv	a0,s2
    80002f66:	fffff097          	auipc	ra,0xfffff
    80002f6a:	5f6080e7          	jalr	1526(ra) # 8000255c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f6e:	013d09bb          	addw	s3,s10,s3
    80002f72:	009d04bb          	addw	s1,s10,s1
    80002f76:	9a6e                	add	s4,s4,s11
    80002f78:	0559f763          	bgeu	s3,s5,80002fc6 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80002f7c:	00a4d59b          	srliw	a1,s1,0xa
    80002f80:	855a                	mv	a0,s6
    80002f82:	00000097          	auipc	ra,0x0
    80002f86:	89e080e7          	jalr	-1890(ra) # 80002820 <bmap>
    80002f8a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80002f8e:	cd85                	beqz	a1,80002fc6 <readi+0xce>
    bp = bread(ip->dev, addr);
    80002f90:	000b2503          	lw	a0,0(s6)
    80002f94:	fffff097          	auipc	ra,0xfffff
    80002f98:	498080e7          	jalr	1176(ra) # 8000242c <bread>
    80002f9c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f9e:	3ff4f713          	andi	a4,s1,1023
    80002fa2:	40ec87bb          	subw	a5,s9,a4
    80002fa6:	413a86bb          	subw	a3,s5,s3
    80002faa:	8d3e                	mv	s10,a5
    80002fac:	2781                	sext.w	a5,a5
    80002fae:	0006861b          	sext.w	a2,a3
    80002fb2:	f8f679e3          	bgeu	a2,a5,80002f44 <readi+0x4c>
    80002fb6:	8d36                	mv	s10,a3
    80002fb8:	b771                	j	80002f44 <readi+0x4c>
      brelse(bp);
    80002fba:	854a                	mv	a0,s2
    80002fbc:	fffff097          	auipc	ra,0xfffff
    80002fc0:	5a0080e7          	jalr	1440(ra) # 8000255c <brelse>
      tot = -1;
    80002fc4:	59fd                	li	s3,-1
  }
  return tot;
    80002fc6:	0009851b          	sext.w	a0,s3
}
    80002fca:	70a6                	ld	ra,104(sp)
    80002fcc:	7406                	ld	s0,96(sp)
    80002fce:	64e6                	ld	s1,88(sp)
    80002fd0:	6946                	ld	s2,80(sp)
    80002fd2:	69a6                	ld	s3,72(sp)
    80002fd4:	6a06                	ld	s4,64(sp)
    80002fd6:	7ae2                	ld	s5,56(sp)
    80002fd8:	7b42                	ld	s6,48(sp)
    80002fda:	7ba2                	ld	s7,40(sp)
    80002fdc:	7c02                	ld	s8,32(sp)
    80002fde:	6ce2                	ld	s9,24(sp)
    80002fe0:	6d42                	ld	s10,16(sp)
    80002fe2:	6da2                	ld	s11,8(sp)
    80002fe4:	6165                	addi	sp,sp,112
    80002fe6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002fe8:	89d6                	mv	s3,s5
    80002fea:	bff1                	j	80002fc6 <readi+0xce>
    return 0;
    80002fec:	4501                	li	a0,0
}
    80002fee:	8082                	ret

0000000080002ff0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002ff0:	457c                	lw	a5,76(a0)
    80002ff2:	10d7e863          	bltu	a5,a3,80003102 <writei+0x112>
{
    80002ff6:	7159                	addi	sp,sp,-112
    80002ff8:	f486                	sd	ra,104(sp)
    80002ffa:	f0a2                	sd	s0,96(sp)
    80002ffc:	eca6                	sd	s1,88(sp)
    80002ffe:	e8ca                	sd	s2,80(sp)
    80003000:	e4ce                	sd	s3,72(sp)
    80003002:	e0d2                	sd	s4,64(sp)
    80003004:	fc56                	sd	s5,56(sp)
    80003006:	f85a                	sd	s6,48(sp)
    80003008:	f45e                	sd	s7,40(sp)
    8000300a:	f062                	sd	s8,32(sp)
    8000300c:	ec66                	sd	s9,24(sp)
    8000300e:	e86a                	sd	s10,16(sp)
    80003010:	e46e                	sd	s11,8(sp)
    80003012:	1880                	addi	s0,sp,112
    80003014:	8aaa                	mv	s5,a0
    80003016:	8bae                	mv	s7,a1
    80003018:	8a32                	mv	s4,a2
    8000301a:	8936                	mv	s2,a3
    8000301c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000301e:	00e687bb          	addw	a5,a3,a4
    80003022:	0ed7e263          	bltu	a5,a3,80003106 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003026:	00043737          	lui	a4,0x43
    8000302a:	0ef76063          	bltu	a4,a5,8000310a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000302e:	0c0b0863          	beqz	s6,800030fe <writei+0x10e>
    80003032:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003034:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003038:	5c7d                	li	s8,-1
    8000303a:	a091                	j	8000307e <writei+0x8e>
    8000303c:	020d1d93          	slli	s11,s10,0x20
    80003040:	020ddd93          	srli	s11,s11,0x20
    80003044:	05848513          	addi	a0,s1,88
    80003048:	86ee                	mv	a3,s11
    8000304a:	8652                	mv	a2,s4
    8000304c:	85de                	mv	a1,s7
    8000304e:	953a                	add	a0,a0,a4
    80003050:	fffff097          	auipc	ra,0xfffff
    80003054:	914080e7          	jalr	-1772(ra) # 80001964 <either_copyin>
    80003058:	07850263          	beq	a0,s8,800030bc <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000305c:	8526                	mv	a0,s1
    8000305e:	00000097          	auipc	ra,0x0
    80003062:	788080e7          	jalr	1928(ra) # 800037e6 <log_write>
    brelse(bp);
    80003066:	8526                	mv	a0,s1
    80003068:	fffff097          	auipc	ra,0xfffff
    8000306c:	4f4080e7          	jalr	1268(ra) # 8000255c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003070:	013d09bb          	addw	s3,s10,s3
    80003074:	012d093b          	addw	s2,s10,s2
    80003078:	9a6e                	add	s4,s4,s11
    8000307a:	0569f663          	bgeu	s3,s6,800030c6 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000307e:	00a9559b          	srliw	a1,s2,0xa
    80003082:	8556                	mv	a0,s5
    80003084:	fffff097          	auipc	ra,0xfffff
    80003088:	79c080e7          	jalr	1948(ra) # 80002820 <bmap>
    8000308c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003090:	c99d                	beqz	a1,800030c6 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003092:	000aa503          	lw	a0,0(s5)
    80003096:	fffff097          	auipc	ra,0xfffff
    8000309a:	396080e7          	jalr	918(ra) # 8000242c <bread>
    8000309e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800030a0:	3ff97713          	andi	a4,s2,1023
    800030a4:	40ec87bb          	subw	a5,s9,a4
    800030a8:	413b06bb          	subw	a3,s6,s3
    800030ac:	8d3e                	mv	s10,a5
    800030ae:	2781                	sext.w	a5,a5
    800030b0:	0006861b          	sext.w	a2,a3
    800030b4:	f8f674e3          	bgeu	a2,a5,8000303c <writei+0x4c>
    800030b8:	8d36                	mv	s10,a3
    800030ba:	b749                	j	8000303c <writei+0x4c>
      brelse(bp);
    800030bc:	8526                	mv	a0,s1
    800030be:	fffff097          	auipc	ra,0xfffff
    800030c2:	49e080e7          	jalr	1182(ra) # 8000255c <brelse>
  }

  if(off > ip->size)
    800030c6:	04caa783          	lw	a5,76(s5)
    800030ca:	0127f463          	bgeu	a5,s2,800030d2 <writei+0xe2>
    ip->size = off;
    800030ce:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800030d2:	8556                	mv	a0,s5
    800030d4:	00000097          	auipc	ra,0x0
    800030d8:	aa4080e7          	jalr	-1372(ra) # 80002b78 <iupdate>

  return tot;
    800030dc:	0009851b          	sext.w	a0,s3
}
    800030e0:	70a6                	ld	ra,104(sp)
    800030e2:	7406                	ld	s0,96(sp)
    800030e4:	64e6                	ld	s1,88(sp)
    800030e6:	6946                	ld	s2,80(sp)
    800030e8:	69a6                	ld	s3,72(sp)
    800030ea:	6a06                	ld	s4,64(sp)
    800030ec:	7ae2                	ld	s5,56(sp)
    800030ee:	7b42                	ld	s6,48(sp)
    800030f0:	7ba2                	ld	s7,40(sp)
    800030f2:	7c02                	ld	s8,32(sp)
    800030f4:	6ce2                	ld	s9,24(sp)
    800030f6:	6d42                	ld	s10,16(sp)
    800030f8:	6da2                	ld	s11,8(sp)
    800030fa:	6165                	addi	sp,sp,112
    800030fc:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800030fe:	89da                	mv	s3,s6
    80003100:	bfc9                	j	800030d2 <writei+0xe2>
    return -1;
    80003102:	557d                	li	a0,-1
}
    80003104:	8082                	ret
    return -1;
    80003106:	557d                	li	a0,-1
    80003108:	bfe1                	j	800030e0 <writei+0xf0>
    return -1;
    8000310a:	557d                	li	a0,-1
    8000310c:	bfd1                	j	800030e0 <writei+0xf0>

000000008000310e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000310e:	1141                	addi	sp,sp,-16
    80003110:	e406                	sd	ra,8(sp)
    80003112:	e022                	sd	s0,0(sp)
    80003114:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003116:	4639                	li	a2,14
    80003118:	ffffd097          	auipc	ra,0xffffd
    8000311c:	132080e7          	jalr	306(ra) # 8000024a <strncmp>
}
    80003120:	60a2                	ld	ra,8(sp)
    80003122:	6402                	ld	s0,0(sp)
    80003124:	0141                	addi	sp,sp,16
    80003126:	8082                	ret

0000000080003128 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003128:	7139                	addi	sp,sp,-64
    8000312a:	fc06                	sd	ra,56(sp)
    8000312c:	f822                	sd	s0,48(sp)
    8000312e:	f426                	sd	s1,40(sp)
    80003130:	f04a                	sd	s2,32(sp)
    80003132:	ec4e                	sd	s3,24(sp)
    80003134:	e852                	sd	s4,16(sp)
    80003136:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003138:	04451703          	lh	a4,68(a0)
    8000313c:	4785                	li	a5,1
    8000313e:	00f71a63          	bne	a4,a5,80003152 <dirlookup+0x2a>
    80003142:	892a                	mv	s2,a0
    80003144:	89ae                	mv	s3,a1
    80003146:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003148:	457c                	lw	a5,76(a0)
    8000314a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000314c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000314e:	e79d                	bnez	a5,8000317c <dirlookup+0x54>
    80003150:	a8a5                	j	800031c8 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003152:	00005517          	auipc	a0,0x5
    80003156:	43650513          	addi	a0,a0,1078 # 80008588 <syscalls+0x1b8>
    8000315a:	00003097          	auipc	ra,0x3
    8000315e:	ba2080e7          	jalr	-1118(ra) # 80005cfc <panic>
      panic("dirlookup read");
    80003162:	00005517          	auipc	a0,0x5
    80003166:	43e50513          	addi	a0,a0,1086 # 800085a0 <syscalls+0x1d0>
    8000316a:	00003097          	auipc	ra,0x3
    8000316e:	b92080e7          	jalr	-1134(ra) # 80005cfc <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003172:	24c1                	addiw	s1,s1,16
    80003174:	04c92783          	lw	a5,76(s2)
    80003178:	04f4f763          	bgeu	s1,a5,800031c6 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000317c:	4741                	li	a4,16
    8000317e:	86a6                	mv	a3,s1
    80003180:	fc040613          	addi	a2,s0,-64
    80003184:	4581                	li	a1,0
    80003186:	854a                	mv	a0,s2
    80003188:	00000097          	auipc	ra,0x0
    8000318c:	d70080e7          	jalr	-656(ra) # 80002ef8 <readi>
    80003190:	47c1                	li	a5,16
    80003192:	fcf518e3          	bne	a0,a5,80003162 <dirlookup+0x3a>
    if(de.inum == 0)
    80003196:	fc045783          	lhu	a5,-64(s0)
    8000319a:	dfe1                	beqz	a5,80003172 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000319c:	fc240593          	addi	a1,s0,-62
    800031a0:	854e                	mv	a0,s3
    800031a2:	00000097          	auipc	ra,0x0
    800031a6:	f6c080e7          	jalr	-148(ra) # 8000310e <namecmp>
    800031aa:	f561                	bnez	a0,80003172 <dirlookup+0x4a>
      if(poff)
    800031ac:	000a0463          	beqz	s4,800031b4 <dirlookup+0x8c>
        *poff = off;
    800031b0:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800031b4:	fc045583          	lhu	a1,-64(s0)
    800031b8:	00092503          	lw	a0,0(s2)
    800031bc:	fffff097          	auipc	ra,0xfffff
    800031c0:	74e080e7          	jalr	1870(ra) # 8000290a <iget>
    800031c4:	a011                	j	800031c8 <dirlookup+0xa0>
  return 0;
    800031c6:	4501                	li	a0,0
}
    800031c8:	70e2                	ld	ra,56(sp)
    800031ca:	7442                	ld	s0,48(sp)
    800031cc:	74a2                	ld	s1,40(sp)
    800031ce:	7902                	ld	s2,32(sp)
    800031d0:	69e2                	ld	s3,24(sp)
    800031d2:	6a42                	ld	s4,16(sp)
    800031d4:	6121                	addi	sp,sp,64
    800031d6:	8082                	ret

00000000800031d8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800031d8:	711d                	addi	sp,sp,-96
    800031da:	ec86                	sd	ra,88(sp)
    800031dc:	e8a2                	sd	s0,80(sp)
    800031de:	e4a6                	sd	s1,72(sp)
    800031e0:	e0ca                	sd	s2,64(sp)
    800031e2:	fc4e                	sd	s3,56(sp)
    800031e4:	f852                	sd	s4,48(sp)
    800031e6:	f456                	sd	s5,40(sp)
    800031e8:	f05a                	sd	s6,32(sp)
    800031ea:	ec5e                	sd	s7,24(sp)
    800031ec:	e862                	sd	s8,16(sp)
    800031ee:	e466                	sd	s9,8(sp)
    800031f0:	e06a                	sd	s10,0(sp)
    800031f2:	1080                	addi	s0,sp,96
    800031f4:	84aa                	mv	s1,a0
    800031f6:	8b2e                	mv	s6,a1
    800031f8:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800031fa:	00054703          	lbu	a4,0(a0)
    800031fe:	02f00793          	li	a5,47
    80003202:	02f70363          	beq	a4,a5,80003228 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003206:	ffffe097          	auipc	ra,0xffffe
    8000320a:	c4e080e7          	jalr	-946(ra) # 80000e54 <myproc>
    8000320e:	15053503          	ld	a0,336(a0)
    80003212:	00000097          	auipc	ra,0x0
    80003216:	9f4080e7          	jalr	-1548(ra) # 80002c06 <idup>
    8000321a:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000321c:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003220:	4cb5                	li	s9,13
  len = path - s;
    80003222:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003224:	4c05                	li	s8,1
    80003226:	a87d                	j	800032e4 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003228:	4585                	li	a1,1
    8000322a:	4505                	li	a0,1
    8000322c:	fffff097          	auipc	ra,0xfffff
    80003230:	6de080e7          	jalr	1758(ra) # 8000290a <iget>
    80003234:	8a2a                	mv	s4,a0
    80003236:	b7dd                	j	8000321c <namex+0x44>
      iunlockput(ip);
    80003238:	8552                	mv	a0,s4
    8000323a:	00000097          	auipc	ra,0x0
    8000323e:	c6c080e7          	jalr	-916(ra) # 80002ea6 <iunlockput>
      return 0;
    80003242:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003244:	8552                	mv	a0,s4
    80003246:	60e6                	ld	ra,88(sp)
    80003248:	6446                	ld	s0,80(sp)
    8000324a:	64a6                	ld	s1,72(sp)
    8000324c:	6906                	ld	s2,64(sp)
    8000324e:	79e2                	ld	s3,56(sp)
    80003250:	7a42                	ld	s4,48(sp)
    80003252:	7aa2                	ld	s5,40(sp)
    80003254:	7b02                	ld	s6,32(sp)
    80003256:	6be2                	ld	s7,24(sp)
    80003258:	6c42                	ld	s8,16(sp)
    8000325a:	6ca2                	ld	s9,8(sp)
    8000325c:	6d02                	ld	s10,0(sp)
    8000325e:	6125                	addi	sp,sp,96
    80003260:	8082                	ret
      iunlock(ip);
    80003262:	8552                	mv	a0,s4
    80003264:	00000097          	auipc	ra,0x0
    80003268:	aa2080e7          	jalr	-1374(ra) # 80002d06 <iunlock>
      return ip;
    8000326c:	bfe1                	j	80003244 <namex+0x6c>
      iunlockput(ip);
    8000326e:	8552                	mv	a0,s4
    80003270:	00000097          	auipc	ra,0x0
    80003274:	c36080e7          	jalr	-970(ra) # 80002ea6 <iunlockput>
      return 0;
    80003278:	8a4e                	mv	s4,s3
    8000327a:	b7e9                	j	80003244 <namex+0x6c>
  len = path - s;
    8000327c:	40998633          	sub	a2,s3,s1
    80003280:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003284:	09acd863          	bge	s9,s10,80003314 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003288:	4639                	li	a2,14
    8000328a:	85a6                	mv	a1,s1
    8000328c:	8556                	mv	a0,s5
    8000328e:	ffffd097          	auipc	ra,0xffffd
    80003292:	f48080e7          	jalr	-184(ra) # 800001d6 <memmove>
    80003296:	84ce                	mv	s1,s3
  while(*path == '/')
    80003298:	0004c783          	lbu	a5,0(s1)
    8000329c:	01279763          	bne	a5,s2,800032aa <namex+0xd2>
    path++;
    800032a0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800032a2:	0004c783          	lbu	a5,0(s1)
    800032a6:	ff278de3          	beq	a5,s2,800032a0 <namex+0xc8>
    ilock(ip);
    800032aa:	8552                	mv	a0,s4
    800032ac:	00000097          	auipc	ra,0x0
    800032b0:	998080e7          	jalr	-1640(ra) # 80002c44 <ilock>
    if(ip->type != T_DIR){
    800032b4:	044a1783          	lh	a5,68(s4)
    800032b8:	f98790e3          	bne	a5,s8,80003238 <namex+0x60>
    if(nameiparent && *path == '\0'){
    800032bc:	000b0563          	beqz	s6,800032c6 <namex+0xee>
    800032c0:	0004c783          	lbu	a5,0(s1)
    800032c4:	dfd9                	beqz	a5,80003262 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800032c6:	865e                	mv	a2,s7
    800032c8:	85d6                	mv	a1,s5
    800032ca:	8552                	mv	a0,s4
    800032cc:	00000097          	auipc	ra,0x0
    800032d0:	e5c080e7          	jalr	-420(ra) # 80003128 <dirlookup>
    800032d4:	89aa                	mv	s3,a0
    800032d6:	dd41                	beqz	a0,8000326e <namex+0x96>
    iunlockput(ip);
    800032d8:	8552                	mv	a0,s4
    800032da:	00000097          	auipc	ra,0x0
    800032de:	bcc080e7          	jalr	-1076(ra) # 80002ea6 <iunlockput>
    ip = next;
    800032e2:	8a4e                	mv	s4,s3
  while(*path == '/')
    800032e4:	0004c783          	lbu	a5,0(s1)
    800032e8:	01279763          	bne	a5,s2,800032f6 <namex+0x11e>
    path++;
    800032ec:	0485                	addi	s1,s1,1
  while(*path == '/')
    800032ee:	0004c783          	lbu	a5,0(s1)
    800032f2:	ff278de3          	beq	a5,s2,800032ec <namex+0x114>
  if(*path == 0)
    800032f6:	cb9d                	beqz	a5,8000332c <namex+0x154>
  while(*path != '/' && *path != 0)
    800032f8:	0004c783          	lbu	a5,0(s1)
    800032fc:	89a6                	mv	s3,s1
  len = path - s;
    800032fe:	8d5e                	mv	s10,s7
    80003300:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003302:	01278963          	beq	a5,s2,80003314 <namex+0x13c>
    80003306:	dbbd                	beqz	a5,8000327c <namex+0xa4>
    path++;
    80003308:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000330a:	0009c783          	lbu	a5,0(s3)
    8000330e:	ff279ce3          	bne	a5,s2,80003306 <namex+0x12e>
    80003312:	b7ad                	j	8000327c <namex+0xa4>
    memmove(name, s, len);
    80003314:	2601                	sext.w	a2,a2
    80003316:	85a6                	mv	a1,s1
    80003318:	8556                	mv	a0,s5
    8000331a:	ffffd097          	auipc	ra,0xffffd
    8000331e:	ebc080e7          	jalr	-324(ra) # 800001d6 <memmove>
    name[len] = 0;
    80003322:	9d56                	add	s10,s10,s5
    80003324:	000d0023          	sb	zero,0(s10)
    80003328:	84ce                	mv	s1,s3
    8000332a:	b7bd                	j	80003298 <namex+0xc0>
  if(nameiparent){
    8000332c:	f00b0ce3          	beqz	s6,80003244 <namex+0x6c>
    iput(ip);
    80003330:	8552                	mv	a0,s4
    80003332:	00000097          	auipc	ra,0x0
    80003336:	acc080e7          	jalr	-1332(ra) # 80002dfe <iput>
    return 0;
    8000333a:	4a01                	li	s4,0
    8000333c:	b721                	j	80003244 <namex+0x6c>

000000008000333e <dirlink>:
{
    8000333e:	7139                	addi	sp,sp,-64
    80003340:	fc06                	sd	ra,56(sp)
    80003342:	f822                	sd	s0,48(sp)
    80003344:	f426                	sd	s1,40(sp)
    80003346:	f04a                	sd	s2,32(sp)
    80003348:	ec4e                	sd	s3,24(sp)
    8000334a:	e852                	sd	s4,16(sp)
    8000334c:	0080                	addi	s0,sp,64
    8000334e:	892a                	mv	s2,a0
    80003350:	8a2e                	mv	s4,a1
    80003352:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003354:	4601                	li	a2,0
    80003356:	00000097          	auipc	ra,0x0
    8000335a:	dd2080e7          	jalr	-558(ra) # 80003128 <dirlookup>
    8000335e:	e93d                	bnez	a0,800033d4 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003360:	04c92483          	lw	s1,76(s2)
    80003364:	c49d                	beqz	s1,80003392 <dirlink+0x54>
    80003366:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003368:	4741                	li	a4,16
    8000336a:	86a6                	mv	a3,s1
    8000336c:	fc040613          	addi	a2,s0,-64
    80003370:	4581                	li	a1,0
    80003372:	854a                	mv	a0,s2
    80003374:	00000097          	auipc	ra,0x0
    80003378:	b84080e7          	jalr	-1148(ra) # 80002ef8 <readi>
    8000337c:	47c1                	li	a5,16
    8000337e:	06f51163          	bne	a0,a5,800033e0 <dirlink+0xa2>
    if(de.inum == 0)
    80003382:	fc045783          	lhu	a5,-64(s0)
    80003386:	c791                	beqz	a5,80003392 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003388:	24c1                	addiw	s1,s1,16
    8000338a:	04c92783          	lw	a5,76(s2)
    8000338e:	fcf4ede3          	bltu	s1,a5,80003368 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003392:	4639                	li	a2,14
    80003394:	85d2                	mv	a1,s4
    80003396:	fc240513          	addi	a0,s0,-62
    8000339a:	ffffd097          	auipc	ra,0xffffd
    8000339e:	eec080e7          	jalr	-276(ra) # 80000286 <strncpy>
  de.inum = inum;
    800033a2:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800033a6:	4741                	li	a4,16
    800033a8:	86a6                	mv	a3,s1
    800033aa:	fc040613          	addi	a2,s0,-64
    800033ae:	4581                	li	a1,0
    800033b0:	854a                	mv	a0,s2
    800033b2:	00000097          	auipc	ra,0x0
    800033b6:	c3e080e7          	jalr	-962(ra) # 80002ff0 <writei>
    800033ba:	1541                	addi	a0,a0,-16
    800033bc:	00a03533          	snez	a0,a0
    800033c0:	40a00533          	neg	a0,a0
}
    800033c4:	70e2                	ld	ra,56(sp)
    800033c6:	7442                	ld	s0,48(sp)
    800033c8:	74a2                	ld	s1,40(sp)
    800033ca:	7902                	ld	s2,32(sp)
    800033cc:	69e2                	ld	s3,24(sp)
    800033ce:	6a42                	ld	s4,16(sp)
    800033d0:	6121                	addi	sp,sp,64
    800033d2:	8082                	ret
    iput(ip);
    800033d4:	00000097          	auipc	ra,0x0
    800033d8:	a2a080e7          	jalr	-1494(ra) # 80002dfe <iput>
    return -1;
    800033dc:	557d                	li	a0,-1
    800033de:	b7dd                	j	800033c4 <dirlink+0x86>
      panic("dirlink read");
    800033e0:	00005517          	auipc	a0,0x5
    800033e4:	1d050513          	addi	a0,a0,464 # 800085b0 <syscalls+0x1e0>
    800033e8:	00003097          	auipc	ra,0x3
    800033ec:	914080e7          	jalr	-1772(ra) # 80005cfc <panic>

00000000800033f0 <namei>:

struct inode*
namei(char *path)
{
    800033f0:	1101                	addi	sp,sp,-32
    800033f2:	ec06                	sd	ra,24(sp)
    800033f4:	e822                	sd	s0,16(sp)
    800033f6:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800033f8:	fe040613          	addi	a2,s0,-32
    800033fc:	4581                	li	a1,0
    800033fe:	00000097          	auipc	ra,0x0
    80003402:	dda080e7          	jalr	-550(ra) # 800031d8 <namex>
}
    80003406:	60e2                	ld	ra,24(sp)
    80003408:	6442                	ld	s0,16(sp)
    8000340a:	6105                	addi	sp,sp,32
    8000340c:	8082                	ret

000000008000340e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000340e:	1141                	addi	sp,sp,-16
    80003410:	e406                	sd	ra,8(sp)
    80003412:	e022                	sd	s0,0(sp)
    80003414:	0800                	addi	s0,sp,16
    80003416:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003418:	4585                	li	a1,1
    8000341a:	00000097          	auipc	ra,0x0
    8000341e:	dbe080e7          	jalr	-578(ra) # 800031d8 <namex>
}
    80003422:	60a2                	ld	ra,8(sp)
    80003424:	6402                	ld	s0,0(sp)
    80003426:	0141                	addi	sp,sp,16
    80003428:	8082                	ret

000000008000342a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000342a:	1101                	addi	sp,sp,-32
    8000342c:	ec06                	sd	ra,24(sp)
    8000342e:	e822                	sd	s0,16(sp)
    80003430:	e426                	sd	s1,8(sp)
    80003432:	e04a                	sd	s2,0(sp)
    80003434:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003436:	00016917          	auipc	s2,0x16
    8000343a:	cba90913          	addi	s2,s2,-838 # 800190f0 <log>
    8000343e:	01892583          	lw	a1,24(s2)
    80003442:	02892503          	lw	a0,40(s2)
    80003446:	fffff097          	auipc	ra,0xfffff
    8000344a:	fe6080e7          	jalr	-26(ra) # 8000242c <bread>
    8000344e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003450:	02c92683          	lw	a3,44(s2)
    80003454:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003456:	02d05863          	blez	a3,80003486 <write_head+0x5c>
    8000345a:	00016797          	auipc	a5,0x16
    8000345e:	cc678793          	addi	a5,a5,-826 # 80019120 <log+0x30>
    80003462:	05c50713          	addi	a4,a0,92
    80003466:	36fd                	addiw	a3,a3,-1
    80003468:	02069613          	slli	a2,a3,0x20
    8000346c:	01e65693          	srli	a3,a2,0x1e
    80003470:	00016617          	auipc	a2,0x16
    80003474:	cb460613          	addi	a2,a2,-844 # 80019124 <log+0x34>
    80003478:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    8000347a:	4390                	lw	a2,0(a5)
    8000347c:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000347e:	0791                	addi	a5,a5,4
    80003480:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80003482:	fed79ce3          	bne	a5,a3,8000347a <write_head+0x50>
  }
  bwrite(buf);
    80003486:	8526                	mv	a0,s1
    80003488:	fffff097          	auipc	ra,0xfffff
    8000348c:	096080e7          	jalr	150(ra) # 8000251e <bwrite>
  brelse(buf);
    80003490:	8526                	mv	a0,s1
    80003492:	fffff097          	auipc	ra,0xfffff
    80003496:	0ca080e7          	jalr	202(ra) # 8000255c <brelse>
}
    8000349a:	60e2                	ld	ra,24(sp)
    8000349c:	6442                	ld	s0,16(sp)
    8000349e:	64a2                	ld	s1,8(sp)
    800034a0:	6902                	ld	s2,0(sp)
    800034a2:	6105                	addi	sp,sp,32
    800034a4:	8082                	ret

00000000800034a6 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800034a6:	00016797          	auipc	a5,0x16
    800034aa:	c767a783          	lw	a5,-906(a5) # 8001911c <log+0x2c>
    800034ae:	0af05d63          	blez	a5,80003568 <install_trans+0xc2>
{
    800034b2:	7139                	addi	sp,sp,-64
    800034b4:	fc06                	sd	ra,56(sp)
    800034b6:	f822                	sd	s0,48(sp)
    800034b8:	f426                	sd	s1,40(sp)
    800034ba:	f04a                	sd	s2,32(sp)
    800034bc:	ec4e                	sd	s3,24(sp)
    800034be:	e852                	sd	s4,16(sp)
    800034c0:	e456                	sd	s5,8(sp)
    800034c2:	e05a                	sd	s6,0(sp)
    800034c4:	0080                	addi	s0,sp,64
    800034c6:	8b2a                	mv	s6,a0
    800034c8:	00016a97          	auipc	s5,0x16
    800034cc:	c58a8a93          	addi	s5,s5,-936 # 80019120 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800034d0:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800034d2:	00016997          	auipc	s3,0x16
    800034d6:	c1e98993          	addi	s3,s3,-994 # 800190f0 <log>
    800034da:	a00d                	j	800034fc <install_trans+0x56>
    brelse(lbuf);
    800034dc:	854a                	mv	a0,s2
    800034de:	fffff097          	auipc	ra,0xfffff
    800034e2:	07e080e7          	jalr	126(ra) # 8000255c <brelse>
    brelse(dbuf);
    800034e6:	8526                	mv	a0,s1
    800034e8:	fffff097          	auipc	ra,0xfffff
    800034ec:	074080e7          	jalr	116(ra) # 8000255c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800034f0:	2a05                	addiw	s4,s4,1
    800034f2:	0a91                	addi	s5,s5,4
    800034f4:	02c9a783          	lw	a5,44(s3)
    800034f8:	04fa5e63          	bge	s4,a5,80003554 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800034fc:	0189a583          	lw	a1,24(s3)
    80003500:	014585bb          	addw	a1,a1,s4
    80003504:	2585                	addiw	a1,a1,1
    80003506:	0289a503          	lw	a0,40(s3)
    8000350a:	fffff097          	auipc	ra,0xfffff
    8000350e:	f22080e7          	jalr	-222(ra) # 8000242c <bread>
    80003512:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003514:	000aa583          	lw	a1,0(s5)
    80003518:	0289a503          	lw	a0,40(s3)
    8000351c:	fffff097          	auipc	ra,0xfffff
    80003520:	f10080e7          	jalr	-240(ra) # 8000242c <bread>
    80003524:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003526:	40000613          	li	a2,1024
    8000352a:	05890593          	addi	a1,s2,88
    8000352e:	05850513          	addi	a0,a0,88
    80003532:	ffffd097          	auipc	ra,0xffffd
    80003536:	ca4080e7          	jalr	-860(ra) # 800001d6 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000353a:	8526                	mv	a0,s1
    8000353c:	fffff097          	auipc	ra,0xfffff
    80003540:	fe2080e7          	jalr	-30(ra) # 8000251e <bwrite>
    if(recovering == 0)
    80003544:	f80b1ce3          	bnez	s6,800034dc <install_trans+0x36>
      bunpin(dbuf);
    80003548:	8526                	mv	a0,s1
    8000354a:	fffff097          	auipc	ra,0xfffff
    8000354e:	0ec080e7          	jalr	236(ra) # 80002636 <bunpin>
    80003552:	b769                	j	800034dc <install_trans+0x36>
}
    80003554:	70e2                	ld	ra,56(sp)
    80003556:	7442                	ld	s0,48(sp)
    80003558:	74a2                	ld	s1,40(sp)
    8000355a:	7902                	ld	s2,32(sp)
    8000355c:	69e2                	ld	s3,24(sp)
    8000355e:	6a42                	ld	s4,16(sp)
    80003560:	6aa2                	ld	s5,8(sp)
    80003562:	6b02                	ld	s6,0(sp)
    80003564:	6121                	addi	sp,sp,64
    80003566:	8082                	ret
    80003568:	8082                	ret

000000008000356a <initlog>:
{
    8000356a:	7179                	addi	sp,sp,-48
    8000356c:	f406                	sd	ra,40(sp)
    8000356e:	f022                	sd	s0,32(sp)
    80003570:	ec26                	sd	s1,24(sp)
    80003572:	e84a                	sd	s2,16(sp)
    80003574:	e44e                	sd	s3,8(sp)
    80003576:	1800                	addi	s0,sp,48
    80003578:	892a                	mv	s2,a0
    8000357a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000357c:	00016497          	auipc	s1,0x16
    80003580:	b7448493          	addi	s1,s1,-1164 # 800190f0 <log>
    80003584:	00005597          	auipc	a1,0x5
    80003588:	03c58593          	addi	a1,a1,60 # 800085c0 <syscalls+0x1f0>
    8000358c:	8526                	mv	a0,s1
    8000358e:	00003097          	auipc	ra,0x3
    80003592:	c16080e7          	jalr	-1002(ra) # 800061a4 <initlock>
  log.start = sb->logstart;
    80003596:	0149a583          	lw	a1,20(s3)
    8000359a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000359c:	0109a783          	lw	a5,16(s3)
    800035a0:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800035a2:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800035a6:	854a                	mv	a0,s2
    800035a8:	fffff097          	auipc	ra,0xfffff
    800035ac:	e84080e7          	jalr	-380(ra) # 8000242c <bread>
  log.lh.n = lh->n;
    800035b0:	4d34                	lw	a3,88(a0)
    800035b2:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800035b4:	02d05663          	blez	a3,800035e0 <initlog+0x76>
    800035b8:	05c50793          	addi	a5,a0,92
    800035bc:	00016717          	auipc	a4,0x16
    800035c0:	b6470713          	addi	a4,a4,-1180 # 80019120 <log+0x30>
    800035c4:	36fd                	addiw	a3,a3,-1
    800035c6:	02069613          	slli	a2,a3,0x20
    800035ca:	01e65693          	srli	a3,a2,0x1e
    800035ce:	06050613          	addi	a2,a0,96
    800035d2:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800035d4:	4390                	lw	a2,0(a5)
    800035d6:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800035d8:	0791                	addi	a5,a5,4
    800035da:	0711                	addi	a4,a4,4
    800035dc:	fed79ce3          	bne	a5,a3,800035d4 <initlog+0x6a>
  brelse(buf);
    800035e0:	fffff097          	auipc	ra,0xfffff
    800035e4:	f7c080e7          	jalr	-132(ra) # 8000255c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800035e8:	4505                	li	a0,1
    800035ea:	00000097          	auipc	ra,0x0
    800035ee:	ebc080e7          	jalr	-324(ra) # 800034a6 <install_trans>
  log.lh.n = 0;
    800035f2:	00016797          	auipc	a5,0x16
    800035f6:	b207a523          	sw	zero,-1238(a5) # 8001911c <log+0x2c>
  write_head(); // clear the log
    800035fa:	00000097          	auipc	ra,0x0
    800035fe:	e30080e7          	jalr	-464(ra) # 8000342a <write_head>
}
    80003602:	70a2                	ld	ra,40(sp)
    80003604:	7402                	ld	s0,32(sp)
    80003606:	64e2                	ld	s1,24(sp)
    80003608:	6942                	ld	s2,16(sp)
    8000360a:	69a2                	ld	s3,8(sp)
    8000360c:	6145                	addi	sp,sp,48
    8000360e:	8082                	ret

0000000080003610 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003610:	1101                	addi	sp,sp,-32
    80003612:	ec06                	sd	ra,24(sp)
    80003614:	e822                	sd	s0,16(sp)
    80003616:	e426                	sd	s1,8(sp)
    80003618:	e04a                	sd	s2,0(sp)
    8000361a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000361c:	00016517          	auipc	a0,0x16
    80003620:	ad450513          	addi	a0,a0,-1324 # 800190f0 <log>
    80003624:	00003097          	auipc	ra,0x3
    80003628:	c10080e7          	jalr	-1008(ra) # 80006234 <acquire>
  while(1){
    if(log.committing){
    8000362c:	00016497          	auipc	s1,0x16
    80003630:	ac448493          	addi	s1,s1,-1340 # 800190f0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003634:	4979                	li	s2,30
    80003636:	a039                	j	80003644 <begin_op+0x34>
      sleep(&log, &log.lock);
    80003638:	85a6                	mv	a1,s1
    8000363a:	8526                	mv	a0,s1
    8000363c:	ffffe097          	auipc	ra,0xffffe
    80003640:	eca080e7          	jalr	-310(ra) # 80001506 <sleep>
    if(log.committing){
    80003644:	50dc                	lw	a5,36(s1)
    80003646:	fbed                	bnez	a5,80003638 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003648:	5098                	lw	a4,32(s1)
    8000364a:	2705                	addiw	a4,a4,1
    8000364c:	0007069b          	sext.w	a3,a4
    80003650:	0027179b          	slliw	a5,a4,0x2
    80003654:	9fb9                	addw	a5,a5,a4
    80003656:	0017979b          	slliw	a5,a5,0x1
    8000365a:	54d8                	lw	a4,44(s1)
    8000365c:	9fb9                	addw	a5,a5,a4
    8000365e:	00f95963          	bge	s2,a5,80003670 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003662:	85a6                	mv	a1,s1
    80003664:	8526                	mv	a0,s1
    80003666:	ffffe097          	auipc	ra,0xffffe
    8000366a:	ea0080e7          	jalr	-352(ra) # 80001506 <sleep>
    8000366e:	bfd9                	j	80003644 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80003670:	00016517          	auipc	a0,0x16
    80003674:	a8050513          	addi	a0,a0,-1408 # 800190f0 <log>
    80003678:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000367a:	00003097          	auipc	ra,0x3
    8000367e:	c6e080e7          	jalr	-914(ra) # 800062e8 <release>
      break;
    }
  }
}
    80003682:	60e2                	ld	ra,24(sp)
    80003684:	6442                	ld	s0,16(sp)
    80003686:	64a2                	ld	s1,8(sp)
    80003688:	6902                	ld	s2,0(sp)
    8000368a:	6105                	addi	sp,sp,32
    8000368c:	8082                	ret

000000008000368e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000368e:	7139                	addi	sp,sp,-64
    80003690:	fc06                	sd	ra,56(sp)
    80003692:	f822                	sd	s0,48(sp)
    80003694:	f426                	sd	s1,40(sp)
    80003696:	f04a                	sd	s2,32(sp)
    80003698:	ec4e                	sd	s3,24(sp)
    8000369a:	e852                	sd	s4,16(sp)
    8000369c:	e456                	sd	s5,8(sp)
    8000369e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800036a0:	00016497          	auipc	s1,0x16
    800036a4:	a5048493          	addi	s1,s1,-1456 # 800190f0 <log>
    800036a8:	8526                	mv	a0,s1
    800036aa:	00003097          	auipc	ra,0x3
    800036ae:	b8a080e7          	jalr	-1142(ra) # 80006234 <acquire>
  log.outstanding -= 1;
    800036b2:	509c                	lw	a5,32(s1)
    800036b4:	37fd                	addiw	a5,a5,-1
    800036b6:	0007891b          	sext.w	s2,a5
    800036ba:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800036bc:	50dc                	lw	a5,36(s1)
    800036be:	e7b9                	bnez	a5,8000370c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800036c0:	04091e63          	bnez	s2,8000371c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800036c4:	00016497          	auipc	s1,0x16
    800036c8:	a2c48493          	addi	s1,s1,-1492 # 800190f0 <log>
    800036cc:	4785                	li	a5,1
    800036ce:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800036d0:	8526                	mv	a0,s1
    800036d2:	00003097          	auipc	ra,0x3
    800036d6:	c16080e7          	jalr	-1002(ra) # 800062e8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800036da:	54dc                	lw	a5,44(s1)
    800036dc:	06f04763          	bgtz	a5,8000374a <end_op+0xbc>
    acquire(&log.lock);
    800036e0:	00016497          	auipc	s1,0x16
    800036e4:	a1048493          	addi	s1,s1,-1520 # 800190f0 <log>
    800036e8:	8526                	mv	a0,s1
    800036ea:	00003097          	auipc	ra,0x3
    800036ee:	b4a080e7          	jalr	-1206(ra) # 80006234 <acquire>
    log.committing = 0;
    800036f2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800036f6:	8526                	mv	a0,s1
    800036f8:	ffffe097          	auipc	ra,0xffffe
    800036fc:	e72080e7          	jalr	-398(ra) # 8000156a <wakeup>
    release(&log.lock);
    80003700:	8526                	mv	a0,s1
    80003702:	00003097          	auipc	ra,0x3
    80003706:	be6080e7          	jalr	-1050(ra) # 800062e8 <release>
}
    8000370a:	a03d                	j	80003738 <end_op+0xaa>
    panic("log.committing");
    8000370c:	00005517          	auipc	a0,0x5
    80003710:	ebc50513          	addi	a0,a0,-324 # 800085c8 <syscalls+0x1f8>
    80003714:	00002097          	auipc	ra,0x2
    80003718:	5e8080e7          	jalr	1512(ra) # 80005cfc <panic>
    wakeup(&log);
    8000371c:	00016497          	auipc	s1,0x16
    80003720:	9d448493          	addi	s1,s1,-1580 # 800190f0 <log>
    80003724:	8526                	mv	a0,s1
    80003726:	ffffe097          	auipc	ra,0xffffe
    8000372a:	e44080e7          	jalr	-444(ra) # 8000156a <wakeup>
  release(&log.lock);
    8000372e:	8526                	mv	a0,s1
    80003730:	00003097          	auipc	ra,0x3
    80003734:	bb8080e7          	jalr	-1096(ra) # 800062e8 <release>
}
    80003738:	70e2                	ld	ra,56(sp)
    8000373a:	7442                	ld	s0,48(sp)
    8000373c:	74a2                	ld	s1,40(sp)
    8000373e:	7902                	ld	s2,32(sp)
    80003740:	69e2                	ld	s3,24(sp)
    80003742:	6a42                	ld	s4,16(sp)
    80003744:	6aa2                	ld	s5,8(sp)
    80003746:	6121                	addi	sp,sp,64
    80003748:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000374a:	00016a97          	auipc	s5,0x16
    8000374e:	9d6a8a93          	addi	s5,s5,-1578 # 80019120 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003752:	00016a17          	auipc	s4,0x16
    80003756:	99ea0a13          	addi	s4,s4,-1634 # 800190f0 <log>
    8000375a:	018a2583          	lw	a1,24(s4)
    8000375e:	012585bb          	addw	a1,a1,s2
    80003762:	2585                	addiw	a1,a1,1
    80003764:	028a2503          	lw	a0,40(s4)
    80003768:	fffff097          	auipc	ra,0xfffff
    8000376c:	cc4080e7          	jalr	-828(ra) # 8000242c <bread>
    80003770:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003772:	000aa583          	lw	a1,0(s5)
    80003776:	028a2503          	lw	a0,40(s4)
    8000377a:	fffff097          	auipc	ra,0xfffff
    8000377e:	cb2080e7          	jalr	-846(ra) # 8000242c <bread>
    80003782:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003784:	40000613          	li	a2,1024
    80003788:	05850593          	addi	a1,a0,88
    8000378c:	05848513          	addi	a0,s1,88
    80003790:	ffffd097          	auipc	ra,0xffffd
    80003794:	a46080e7          	jalr	-1466(ra) # 800001d6 <memmove>
    bwrite(to);  // write the log
    80003798:	8526                	mv	a0,s1
    8000379a:	fffff097          	auipc	ra,0xfffff
    8000379e:	d84080e7          	jalr	-636(ra) # 8000251e <bwrite>
    brelse(from);
    800037a2:	854e                	mv	a0,s3
    800037a4:	fffff097          	auipc	ra,0xfffff
    800037a8:	db8080e7          	jalr	-584(ra) # 8000255c <brelse>
    brelse(to);
    800037ac:	8526                	mv	a0,s1
    800037ae:	fffff097          	auipc	ra,0xfffff
    800037b2:	dae080e7          	jalr	-594(ra) # 8000255c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800037b6:	2905                	addiw	s2,s2,1
    800037b8:	0a91                	addi	s5,s5,4
    800037ba:	02ca2783          	lw	a5,44(s4)
    800037be:	f8f94ee3          	blt	s2,a5,8000375a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	c68080e7          	jalr	-920(ra) # 8000342a <write_head>
    install_trans(0); // Now install writes to home locations
    800037ca:	4501                	li	a0,0
    800037cc:	00000097          	auipc	ra,0x0
    800037d0:	cda080e7          	jalr	-806(ra) # 800034a6 <install_trans>
    log.lh.n = 0;
    800037d4:	00016797          	auipc	a5,0x16
    800037d8:	9407a423          	sw	zero,-1720(a5) # 8001911c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800037dc:	00000097          	auipc	ra,0x0
    800037e0:	c4e080e7          	jalr	-946(ra) # 8000342a <write_head>
    800037e4:	bdf5                	j	800036e0 <end_op+0x52>

00000000800037e6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800037e6:	1101                	addi	sp,sp,-32
    800037e8:	ec06                	sd	ra,24(sp)
    800037ea:	e822                	sd	s0,16(sp)
    800037ec:	e426                	sd	s1,8(sp)
    800037ee:	e04a                	sd	s2,0(sp)
    800037f0:	1000                	addi	s0,sp,32
    800037f2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800037f4:	00016917          	auipc	s2,0x16
    800037f8:	8fc90913          	addi	s2,s2,-1796 # 800190f0 <log>
    800037fc:	854a                	mv	a0,s2
    800037fe:	00003097          	auipc	ra,0x3
    80003802:	a36080e7          	jalr	-1482(ra) # 80006234 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003806:	02c92603          	lw	a2,44(s2)
    8000380a:	47f5                	li	a5,29
    8000380c:	06c7c563          	blt	a5,a2,80003876 <log_write+0x90>
    80003810:	00016797          	auipc	a5,0x16
    80003814:	8fc7a783          	lw	a5,-1796(a5) # 8001910c <log+0x1c>
    80003818:	37fd                	addiw	a5,a5,-1
    8000381a:	04f65e63          	bge	a2,a5,80003876 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000381e:	00016797          	auipc	a5,0x16
    80003822:	8f27a783          	lw	a5,-1806(a5) # 80019110 <log+0x20>
    80003826:	06f05063          	blez	a5,80003886 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000382a:	4781                	li	a5,0
    8000382c:	06c05563          	blez	a2,80003896 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003830:	44cc                	lw	a1,12(s1)
    80003832:	00016717          	auipc	a4,0x16
    80003836:	8ee70713          	addi	a4,a4,-1810 # 80019120 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000383a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000383c:	4314                	lw	a3,0(a4)
    8000383e:	04b68c63          	beq	a3,a1,80003896 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80003842:	2785                	addiw	a5,a5,1
    80003844:	0711                	addi	a4,a4,4
    80003846:	fef61be3          	bne	a2,a5,8000383c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000384a:	0621                	addi	a2,a2,8
    8000384c:	060a                	slli	a2,a2,0x2
    8000384e:	00016797          	auipc	a5,0x16
    80003852:	8a278793          	addi	a5,a5,-1886 # 800190f0 <log>
    80003856:	97b2                	add	a5,a5,a2
    80003858:	44d8                	lw	a4,12(s1)
    8000385a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000385c:	8526                	mv	a0,s1
    8000385e:	fffff097          	auipc	ra,0xfffff
    80003862:	d9c080e7          	jalr	-612(ra) # 800025fa <bpin>
    log.lh.n++;
    80003866:	00016717          	auipc	a4,0x16
    8000386a:	88a70713          	addi	a4,a4,-1910 # 800190f0 <log>
    8000386e:	575c                	lw	a5,44(a4)
    80003870:	2785                	addiw	a5,a5,1
    80003872:	d75c                	sw	a5,44(a4)
    80003874:	a82d                	j	800038ae <log_write+0xc8>
    panic("too big a transaction");
    80003876:	00005517          	auipc	a0,0x5
    8000387a:	d6250513          	addi	a0,a0,-670 # 800085d8 <syscalls+0x208>
    8000387e:	00002097          	auipc	ra,0x2
    80003882:	47e080e7          	jalr	1150(ra) # 80005cfc <panic>
    panic("log_write outside of trans");
    80003886:	00005517          	auipc	a0,0x5
    8000388a:	d6a50513          	addi	a0,a0,-662 # 800085f0 <syscalls+0x220>
    8000388e:	00002097          	auipc	ra,0x2
    80003892:	46e080e7          	jalr	1134(ra) # 80005cfc <panic>
  log.lh.block[i] = b->blockno;
    80003896:	00878693          	addi	a3,a5,8
    8000389a:	068a                	slli	a3,a3,0x2
    8000389c:	00016717          	auipc	a4,0x16
    800038a0:	85470713          	addi	a4,a4,-1964 # 800190f0 <log>
    800038a4:	9736                	add	a4,a4,a3
    800038a6:	44d4                	lw	a3,12(s1)
    800038a8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800038aa:	faf609e3          	beq	a2,a5,8000385c <log_write+0x76>
  }
  release(&log.lock);
    800038ae:	00016517          	auipc	a0,0x16
    800038b2:	84250513          	addi	a0,a0,-1982 # 800190f0 <log>
    800038b6:	00003097          	auipc	ra,0x3
    800038ba:	a32080e7          	jalr	-1486(ra) # 800062e8 <release>
}
    800038be:	60e2                	ld	ra,24(sp)
    800038c0:	6442                	ld	s0,16(sp)
    800038c2:	64a2                	ld	s1,8(sp)
    800038c4:	6902                	ld	s2,0(sp)
    800038c6:	6105                	addi	sp,sp,32
    800038c8:	8082                	ret

00000000800038ca <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800038ca:	1101                	addi	sp,sp,-32
    800038cc:	ec06                	sd	ra,24(sp)
    800038ce:	e822                	sd	s0,16(sp)
    800038d0:	e426                	sd	s1,8(sp)
    800038d2:	e04a                	sd	s2,0(sp)
    800038d4:	1000                	addi	s0,sp,32
    800038d6:	84aa                	mv	s1,a0
    800038d8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800038da:	00005597          	auipc	a1,0x5
    800038de:	d3658593          	addi	a1,a1,-714 # 80008610 <syscalls+0x240>
    800038e2:	0521                	addi	a0,a0,8
    800038e4:	00003097          	auipc	ra,0x3
    800038e8:	8c0080e7          	jalr	-1856(ra) # 800061a4 <initlock>
  lk->name = name;
    800038ec:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800038f0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800038f4:	0204a423          	sw	zero,40(s1)
}
    800038f8:	60e2                	ld	ra,24(sp)
    800038fa:	6442                	ld	s0,16(sp)
    800038fc:	64a2                	ld	s1,8(sp)
    800038fe:	6902                	ld	s2,0(sp)
    80003900:	6105                	addi	sp,sp,32
    80003902:	8082                	ret

0000000080003904 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003904:	1101                	addi	sp,sp,-32
    80003906:	ec06                	sd	ra,24(sp)
    80003908:	e822                	sd	s0,16(sp)
    8000390a:	e426                	sd	s1,8(sp)
    8000390c:	e04a                	sd	s2,0(sp)
    8000390e:	1000                	addi	s0,sp,32
    80003910:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003912:	00850913          	addi	s2,a0,8
    80003916:	854a                	mv	a0,s2
    80003918:	00003097          	auipc	ra,0x3
    8000391c:	91c080e7          	jalr	-1764(ra) # 80006234 <acquire>
  while (lk->locked) {
    80003920:	409c                	lw	a5,0(s1)
    80003922:	cb89                	beqz	a5,80003934 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003924:	85ca                	mv	a1,s2
    80003926:	8526                	mv	a0,s1
    80003928:	ffffe097          	auipc	ra,0xffffe
    8000392c:	bde080e7          	jalr	-1058(ra) # 80001506 <sleep>
  while (lk->locked) {
    80003930:	409c                	lw	a5,0(s1)
    80003932:	fbed                	bnez	a5,80003924 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003934:	4785                	li	a5,1
    80003936:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003938:	ffffd097          	auipc	ra,0xffffd
    8000393c:	51c080e7          	jalr	1308(ra) # 80000e54 <myproc>
    80003940:	591c                	lw	a5,48(a0)
    80003942:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003944:	854a                	mv	a0,s2
    80003946:	00003097          	auipc	ra,0x3
    8000394a:	9a2080e7          	jalr	-1630(ra) # 800062e8 <release>
}
    8000394e:	60e2                	ld	ra,24(sp)
    80003950:	6442                	ld	s0,16(sp)
    80003952:	64a2                	ld	s1,8(sp)
    80003954:	6902                	ld	s2,0(sp)
    80003956:	6105                	addi	sp,sp,32
    80003958:	8082                	ret

000000008000395a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000395a:	1101                	addi	sp,sp,-32
    8000395c:	ec06                	sd	ra,24(sp)
    8000395e:	e822                	sd	s0,16(sp)
    80003960:	e426                	sd	s1,8(sp)
    80003962:	e04a                	sd	s2,0(sp)
    80003964:	1000                	addi	s0,sp,32
    80003966:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003968:	00850913          	addi	s2,a0,8
    8000396c:	854a                	mv	a0,s2
    8000396e:	00003097          	auipc	ra,0x3
    80003972:	8c6080e7          	jalr	-1850(ra) # 80006234 <acquire>
  lk->locked = 0;
    80003976:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000397a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000397e:	8526                	mv	a0,s1
    80003980:	ffffe097          	auipc	ra,0xffffe
    80003984:	bea080e7          	jalr	-1046(ra) # 8000156a <wakeup>
  release(&lk->lk);
    80003988:	854a                	mv	a0,s2
    8000398a:	00003097          	auipc	ra,0x3
    8000398e:	95e080e7          	jalr	-1698(ra) # 800062e8 <release>
}
    80003992:	60e2                	ld	ra,24(sp)
    80003994:	6442                	ld	s0,16(sp)
    80003996:	64a2                	ld	s1,8(sp)
    80003998:	6902                	ld	s2,0(sp)
    8000399a:	6105                	addi	sp,sp,32
    8000399c:	8082                	ret

000000008000399e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000399e:	7179                	addi	sp,sp,-48
    800039a0:	f406                	sd	ra,40(sp)
    800039a2:	f022                	sd	s0,32(sp)
    800039a4:	ec26                	sd	s1,24(sp)
    800039a6:	e84a                	sd	s2,16(sp)
    800039a8:	e44e                	sd	s3,8(sp)
    800039aa:	1800                	addi	s0,sp,48
    800039ac:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800039ae:	00850913          	addi	s2,a0,8
    800039b2:	854a                	mv	a0,s2
    800039b4:	00003097          	auipc	ra,0x3
    800039b8:	880080e7          	jalr	-1920(ra) # 80006234 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800039bc:	409c                	lw	a5,0(s1)
    800039be:	ef99                	bnez	a5,800039dc <holdingsleep+0x3e>
    800039c0:	4481                	li	s1,0
  release(&lk->lk);
    800039c2:	854a                	mv	a0,s2
    800039c4:	00003097          	auipc	ra,0x3
    800039c8:	924080e7          	jalr	-1756(ra) # 800062e8 <release>
  return r;
}
    800039cc:	8526                	mv	a0,s1
    800039ce:	70a2                	ld	ra,40(sp)
    800039d0:	7402                	ld	s0,32(sp)
    800039d2:	64e2                	ld	s1,24(sp)
    800039d4:	6942                	ld	s2,16(sp)
    800039d6:	69a2                	ld	s3,8(sp)
    800039d8:	6145                	addi	sp,sp,48
    800039da:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800039dc:	0284a983          	lw	s3,40(s1)
    800039e0:	ffffd097          	auipc	ra,0xffffd
    800039e4:	474080e7          	jalr	1140(ra) # 80000e54 <myproc>
    800039e8:	5904                	lw	s1,48(a0)
    800039ea:	413484b3          	sub	s1,s1,s3
    800039ee:	0014b493          	seqz	s1,s1
    800039f2:	bfc1                	j	800039c2 <holdingsleep+0x24>

00000000800039f4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800039f4:	1141                	addi	sp,sp,-16
    800039f6:	e406                	sd	ra,8(sp)
    800039f8:	e022                	sd	s0,0(sp)
    800039fa:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800039fc:	00005597          	auipc	a1,0x5
    80003a00:	c2458593          	addi	a1,a1,-988 # 80008620 <syscalls+0x250>
    80003a04:	00016517          	auipc	a0,0x16
    80003a08:	83450513          	addi	a0,a0,-1996 # 80019238 <ftable>
    80003a0c:	00002097          	auipc	ra,0x2
    80003a10:	798080e7          	jalr	1944(ra) # 800061a4 <initlock>
}
    80003a14:	60a2                	ld	ra,8(sp)
    80003a16:	6402                	ld	s0,0(sp)
    80003a18:	0141                	addi	sp,sp,16
    80003a1a:	8082                	ret

0000000080003a1c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003a1c:	1101                	addi	sp,sp,-32
    80003a1e:	ec06                	sd	ra,24(sp)
    80003a20:	e822                	sd	s0,16(sp)
    80003a22:	e426                	sd	s1,8(sp)
    80003a24:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003a26:	00016517          	auipc	a0,0x16
    80003a2a:	81250513          	addi	a0,a0,-2030 # 80019238 <ftable>
    80003a2e:	00003097          	auipc	ra,0x3
    80003a32:	806080e7          	jalr	-2042(ra) # 80006234 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003a36:	00016497          	auipc	s1,0x16
    80003a3a:	81a48493          	addi	s1,s1,-2022 # 80019250 <ftable+0x18>
    80003a3e:	00016717          	auipc	a4,0x16
    80003a42:	7b270713          	addi	a4,a4,1970 # 8001a1f0 <disk>
    if(f->ref == 0){
    80003a46:	40dc                	lw	a5,4(s1)
    80003a48:	cf99                	beqz	a5,80003a66 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003a4a:	02848493          	addi	s1,s1,40
    80003a4e:	fee49ce3          	bne	s1,a4,80003a46 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003a52:	00015517          	auipc	a0,0x15
    80003a56:	7e650513          	addi	a0,a0,2022 # 80019238 <ftable>
    80003a5a:	00003097          	auipc	ra,0x3
    80003a5e:	88e080e7          	jalr	-1906(ra) # 800062e8 <release>
  return 0;
    80003a62:	4481                	li	s1,0
    80003a64:	a819                	j	80003a7a <filealloc+0x5e>
      f->ref = 1;
    80003a66:	4785                	li	a5,1
    80003a68:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003a6a:	00015517          	auipc	a0,0x15
    80003a6e:	7ce50513          	addi	a0,a0,1998 # 80019238 <ftable>
    80003a72:	00003097          	auipc	ra,0x3
    80003a76:	876080e7          	jalr	-1930(ra) # 800062e8 <release>
}
    80003a7a:	8526                	mv	a0,s1
    80003a7c:	60e2                	ld	ra,24(sp)
    80003a7e:	6442                	ld	s0,16(sp)
    80003a80:	64a2                	ld	s1,8(sp)
    80003a82:	6105                	addi	sp,sp,32
    80003a84:	8082                	ret

0000000080003a86 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003a86:	1101                	addi	sp,sp,-32
    80003a88:	ec06                	sd	ra,24(sp)
    80003a8a:	e822                	sd	s0,16(sp)
    80003a8c:	e426                	sd	s1,8(sp)
    80003a8e:	1000                	addi	s0,sp,32
    80003a90:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003a92:	00015517          	auipc	a0,0x15
    80003a96:	7a650513          	addi	a0,a0,1958 # 80019238 <ftable>
    80003a9a:	00002097          	auipc	ra,0x2
    80003a9e:	79a080e7          	jalr	1946(ra) # 80006234 <acquire>
  if(f->ref < 1)
    80003aa2:	40dc                	lw	a5,4(s1)
    80003aa4:	02f05263          	blez	a5,80003ac8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003aa8:	2785                	addiw	a5,a5,1
    80003aaa:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003aac:	00015517          	auipc	a0,0x15
    80003ab0:	78c50513          	addi	a0,a0,1932 # 80019238 <ftable>
    80003ab4:	00003097          	auipc	ra,0x3
    80003ab8:	834080e7          	jalr	-1996(ra) # 800062e8 <release>
  return f;
}
    80003abc:	8526                	mv	a0,s1
    80003abe:	60e2                	ld	ra,24(sp)
    80003ac0:	6442                	ld	s0,16(sp)
    80003ac2:	64a2                	ld	s1,8(sp)
    80003ac4:	6105                	addi	sp,sp,32
    80003ac6:	8082                	ret
    panic("filedup");
    80003ac8:	00005517          	auipc	a0,0x5
    80003acc:	b6050513          	addi	a0,a0,-1184 # 80008628 <syscalls+0x258>
    80003ad0:	00002097          	auipc	ra,0x2
    80003ad4:	22c080e7          	jalr	556(ra) # 80005cfc <panic>

0000000080003ad8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003ad8:	7139                	addi	sp,sp,-64
    80003ada:	fc06                	sd	ra,56(sp)
    80003adc:	f822                	sd	s0,48(sp)
    80003ade:	f426                	sd	s1,40(sp)
    80003ae0:	f04a                	sd	s2,32(sp)
    80003ae2:	ec4e                	sd	s3,24(sp)
    80003ae4:	e852                	sd	s4,16(sp)
    80003ae6:	e456                	sd	s5,8(sp)
    80003ae8:	0080                	addi	s0,sp,64
    80003aea:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003aec:	00015517          	auipc	a0,0x15
    80003af0:	74c50513          	addi	a0,a0,1868 # 80019238 <ftable>
    80003af4:	00002097          	auipc	ra,0x2
    80003af8:	740080e7          	jalr	1856(ra) # 80006234 <acquire>
  if(f->ref < 1)
    80003afc:	40dc                	lw	a5,4(s1)
    80003afe:	06f05163          	blez	a5,80003b60 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003b02:	37fd                	addiw	a5,a5,-1
    80003b04:	0007871b          	sext.w	a4,a5
    80003b08:	c0dc                	sw	a5,4(s1)
    80003b0a:	06e04363          	bgtz	a4,80003b70 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003b0e:	0004a903          	lw	s2,0(s1)
    80003b12:	0094ca83          	lbu	s5,9(s1)
    80003b16:	0104ba03          	ld	s4,16(s1)
    80003b1a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003b1e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003b22:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003b26:	00015517          	auipc	a0,0x15
    80003b2a:	71250513          	addi	a0,a0,1810 # 80019238 <ftable>
    80003b2e:	00002097          	auipc	ra,0x2
    80003b32:	7ba080e7          	jalr	1978(ra) # 800062e8 <release>

  if(ff.type == FD_PIPE){
    80003b36:	4785                	li	a5,1
    80003b38:	04f90d63          	beq	s2,a5,80003b92 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003b3c:	3979                	addiw	s2,s2,-2
    80003b3e:	4785                	li	a5,1
    80003b40:	0527e063          	bltu	a5,s2,80003b80 <fileclose+0xa8>
    begin_op();
    80003b44:	00000097          	auipc	ra,0x0
    80003b48:	acc080e7          	jalr	-1332(ra) # 80003610 <begin_op>
    iput(ff.ip);
    80003b4c:	854e                	mv	a0,s3
    80003b4e:	fffff097          	auipc	ra,0xfffff
    80003b52:	2b0080e7          	jalr	688(ra) # 80002dfe <iput>
    end_op();
    80003b56:	00000097          	auipc	ra,0x0
    80003b5a:	b38080e7          	jalr	-1224(ra) # 8000368e <end_op>
    80003b5e:	a00d                	j	80003b80 <fileclose+0xa8>
    panic("fileclose");
    80003b60:	00005517          	auipc	a0,0x5
    80003b64:	ad050513          	addi	a0,a0,-1328 # 80008630 <syscalls+0x260>
    80003b68:	00002097          	auipc	ra,0x2
    80003b6c:	194080e7          	jalr	404(ra) # 80005cfc <panic>
    release(&ftable.lock);
    80003b70:	00015517          	auipc	a0,0x15
    80003b74:	6c850513          	addi	a0,a0,1736 # 80019238 <ftable>
    80003b78:	00002097          	auipc	ra,0x2
    80003b7c:	770080e7          	jalr	1904(ra) # 800062e8 <release>
  }
}
    80003b80:	70e2                	ld	ra,56(sp)
    80003b82:	7442                	ld	s0,48(sp)
    80003b84:	74a2                	ld	s1,40(sp)
    80003b86:	7902                	ld	s2,32(sp)
    80003b88:	69e2                	ld	s3,24(sp)
    80003b8a:	6a42                	ld	s4,16(sp)
    80003b8c:	6aa2                	ld	s5,8(sp)
    80003b8e:	6121                	addi	sp,sp,64
    80003b90:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003b92:	85d6                	mv	a1,s5
    80003b94:	8552                	mv	a0,s4
    80003b96:	00000097          	auipc	ra,0x0
    80003b9a:	34c080e7          	jalr	844(ra) # 80003ee2 <pipeclose>
    80003b9e:	b7cd                	j	80003b80 <fileclose+0xa8>

0000000080003ba0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003ba0:	715d                	addi	sp,sp,-80
    80003ba2:	e486                	sd	ra,72(sp)
    80003ba4:	e0a2                	sd	s0,64(sp)
    80003ba6:	fc26                	sd	s1,56(sp)
    80003ba8:	f84a                	sd	s2,48(sp)
    80003baa:	f44e                	sd	s3,40(sp)
    80003bac:	0880                	addi	s0,sp,80
    80003bae:	84aa                	mv	s1,a0
    80003bb0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003bb2:	ffffd097          	auipc	ra,0xffffd
    80003bb6:	2a2080e7          	jalr	674(ra) # 80000e54 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003bba:	409c                	lw	a5,0(s1)
    80003bbc:	37f9                	addiw	a5,a5,-2
    80003bbe:	4705                	li	a4,1
    80003bc0:	04f76763          	bltu	a4,a5,80003c0e <filestat+0x6e>
    80003bc4:	892a                	mv	s2,a0
    ilock(f->ip);
    80003bc6:	6c88                	ld	a0,24(s1)
    80003bc8:	fffff097          	auipc	ra,0xfffff
    80003bcc:	07c080e7          	jalr	124(ra) # 80002c44 <ilock>
    stati(f->ip, &st);
    80003bd0:	fb840593          	addi	a1,s0,-72
    80003bd4:	6c88                	ld	a0,24(s1)
    80003bd6:	fffff097          	auipc	ra,0xfffff
    80003bda:	2f8080e7          	jalr	760(ra) # 80002ece <stati>
    iunlock(f->ip);
    80003bde:	6c88                	ld	a0,24(s1)
    80003be0:	fffff097          	auipc	ra,0xfffff
    80003be4:	126080e7          	jalr	294(ra) # 80002d06 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003be8:	46e1                	li	a3,24
    80003bea:	fb840613          	addi	a2,s0,-72
    80003bee:	85ce                	mv	a1,s3
    80003bf0:	05093503          	ld	a0,80(s2)
    80003bf4:	ffffd097          	auipc	ra,0xffffd
    80003bf8:	f20080e7          	jalr	-224(ra) # 80000b14 <copyout>
    80003bfc:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003c00:	60a6                	ld	ra,72(sp)
    80003c02:	6406                	ld	s0,64(sp)
    80003c04:	74e2                	ld	s1,56(sp)
    80003c06:	7942                	ld	s2,48(sp)
    80003c08:	79a2                	ld	s3,40(sp)
    80003c0a:	6161                	addi	sp,sp,80
    80003c0c:	8082                	ret
  return -1;
    80003c0e:	557d                	li	a0,-1
    80003c10:	bfc5                	j	80003c00 <filestat+0x60>

0000000080003c12 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003c12:	7179                	addi	sp,sp,-48
    80003c14:	f406                	sd	ra,40(sp)
    80003c16:	f022                	sd	s0,32(sp)
    80003c18:	ec26                	sd	s1,24(sp)
    80003c1a:	e84a                	sd	s2,16(sp)
    80003c1c:	e44e                	sd	s3,8(sp)
    80003c1e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003c20:	00854783          	lbu	a5,8(a0)
    80003c24:	c3d5                	beqz	a5,80003cc8 <fileread+0xb6>
    80003c26:	84aa                	mv	s1,a0
    80003c28:	89ae                	mv	s3,a1
    80003c2a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003c2c:	411c                	lw	a5,0(a0)
    80003c2e:	4705                	li	a4,1
    80003c30:	04e78963          	beq	a5,a4,80003c82 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003c34:	470d                	li	a4,3
    80003c36:	04e78d63          	beq	a5,a4,80003c90 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003c3a:	4709                	li	a4,2
    80003c3c:	06e79e63          	bne	a5,a4,80003cb8 <fileread+0xa6>
    ilock(f->ip);
    80003c40:	6d08                	ld	a0,24(a0)
    80003c42:	fffff097          	auipc	ra,0xfffff
    80003c46:	002080e7          	jalr	2(ra) # 80002c44 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003c4a:	874a                	mv	a4,s2
    80003c4c:	5094                	lw	a3,32(s1)
    80003c4e:	864e                	mv	a2,s3
    80003c50:	4585                	li	a1,1
    80003c52:	6c88                	ld	a0,24(s1)
    80003c54:	fffff097          	auipc	ra,0xfffff
    80003c58:	2a4080e7          	jalr	676(ra) # 80002ef8 <readi>
    80003c5c:	892a                	mv	s2,a0
    80003c5e:	00a05563          	blez	a0,80003c68 <fileread+0x56>
      f->off += r;
    80003c62:	509c                	lw	a5,32(s1)
    80003c64:	9fa9                	addw	a5,a5,a0
    80003c66:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003c68:	6c88                	ld	a0,24(s1)
    80003c6a:	fffff097          	auipc	ra,0xfffff
    80003c6e:	09c080e7          	jalr	156(ra) # 80002d06 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003c72:	854a                	mv	a0,s2
    80003c74:	70a2                	ld	ra,40(sp)
    80003c76:	7402                	ld	s0,32(sp)
    80003c78:	64e2                	ld	s1,24(sp)
    80003c7a:	6942                	ld	s2,16(sp)
    80003c7c:	69a2                	ld	s3,8(sp)
    80003c7e:	6145                	addi	sp,sp,48
    80003c80:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003c82:	6908                	ld	a0,16(a0)
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	3c6080e7          	jalr	966(ra) # 8000404a <piperead>
    80003c8c:	892a                	mv	s2,a0
    80003c8e:	b7d5                	j	80003c72 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003c90:	02451783          	lh	a5,36(a0)
    80003c94:	03079693          	slli	a3,a5,0x30
    80003c98:	92c1                	srli	a3,a3,0x30
    80003c9a:	4725                	li	a4,9
    80003c9c:	02d76863          	bltu	a4,a3,80003ccc <fileread+0xba>
    80003ca0:	0792                	slli	a5,a5,0x4
    80003ca2:	00015717          	auipc	a4,0x15
    80003ca6:	4f670713          	addi	a4,a4,1270 # 80019198 <devsw>
    80003caa:	97ba                	add	a5,a5,a4
    80003cac:	639c                	ld	a5,0(a5)
    80003cae:	c38d                	beqz	a5,80003cd0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003cb0:	4505                	li	a0,1
    80003cb2:	9782                	jalr	a5
    80003cb4:	892a                	mv	s2,a0
    80003cb6:	bf75                	j	80003c72 <fileread+0x60>
    panic("fileread");
    80003cb8:	00005517          	auipc	a0,0x5
    80003cbc:	98850513          	addi	a0,a0,-1656 # 80008640 <syscalls+0x270>
    80003cc0:	00002097          	auipc	ra,0x2
    80003cc4:	03c080e7          	jalr	60(ra) # 80005cfc <panic>
    return -1;
    80003cc8:	597d                	li	s2,-1
    80003cca:	b765                	j	80003c72 <fileread+0x60>
      return -1;
    80003ccc:	597d                	li	s2,-1
    80003cce:	b755                	j	80003c72 <fileread+0x60>
    80003cd0:	597d                	li	s2,-1
    80003cd2:	b745                	j	80003c72 <fileread+0x60>

0000000080003cd4 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003cd4:	715d                	addi	sp,sp,-80
    80003cd6:	e486                	sd	ra,72(sp)
    80003cd8:	e0a2                	sd	s0,64(sp)
    80003cda:	fc26                	sd	s1,56(sp)
    80003cdc:	f84a                	sd	s2,48(sp)
    80003cde:	f44e                	sd	s3,40(sp)
    80003ce0:	f052                	sd	s4,32(sp)
    80003ce2:	ec56                	sd	s5,24(sp)
    80003ce4:	e85a                	sd	s6,16(sp)
    80003ce6:	e45e                	sd	s7,8(sp)
    80003ce8:	e062                	sd	s8,0(sp)
    80003cea:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003cec:	00954783          	lbu	a5,9(a0)
    80003cf0:	10078663          	beqz	a5,80003dfc <filewrite+0x128>
    80003cf4:	892a                	mv	s2,a0
    80003cf6:	8b2e                	mv	s6,a1
    80003cf8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003cfa:	411c                	lw	a5,0(a0)
    80003cfc:	4705                	li	a4,1
    80003cfe:	02e78263          	beq	a5,a4,80003d22 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003d02:	470d                	li	a4,3
    80003d04:	02e78663          	beq	a5,a4,80003d30 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003d08:	4709                	li	a4,2
    80003d0a:	0ee79163          	bne	a5,a4,80003dec <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003d0e:	0ac05d63          	blez	a2,80003dc8 <filewrite+0xf4>
    int i = 0;
    80003d12:	4981                	li	s3,0
    80003d14:	6b85                	lui	s7,0x1
    80003d16:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003d1a:	6c05                	lui	s8,0x1
    80003d1c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80003d20:	a861                	j	80003db8 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003d22:	6908                	ld	a0,16(a0)
    80003d24:	00000097          	auipc	ra,0x0
    80003d28:	22e080e7          	jalr	558(ra) # 80003f52 <pipewrite>
    80003d2c:	8a2a                	mv	s4,a0
    80003d2e:	a045                	j	80003dce <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003d30:	02451783          	lh	a5,36(a0)
    80003d34:	03079693          	slli	a3,a5,0x30
    80003d38:	92c1                	srli	a3,a3,0x30
    80003d3a:	4725                	li	a4,9
    80003d3c:	0cd76263          	bltu	a4,a3,80003e00 <filewrite+0x12c>
    80003d40:	0792                	slli	a5,a5,0x4
    80003d42:	00015717          	auipc	a4,0x15
    80003d46:	45670713          	addi	a4,a4,1110 # 80019198 <devsw>
    80003d4a:	97ba                	add	a5,a5,a4
    80003d4c:	679c                	ld	a5,8(a5)
    80003d4e:	cbdd                	beqz	a5,80003e04 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003d50:	4505                	li	a0,1
    80003d52:	9782                	jalr	a5
    80003d54:	8a2a                	mv	s4,a0
    80003d56:	a8a5                	j	80003dce <filewrite+0xfa>
    80003d58:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003d5c:	00000097          	auipc	ra,0x0
    80003d60:	8b4080e7          	jalr	-1868(ra) # 80003610 <begin_op>
      ilock(f->ip);
    80003d64:	01893503          	ld	a0,24(s2)
    80003d68:	fffff097          	auipc	ra,0xfffff
    80003d6c:	edc080e7          	jalr	-292(ra) # 80002c44 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003d70:	8756                	mv	a4,s5
    80003d72:	02092683          	lw	a3,32(s2)
    80003d76:	01698633          	add	a2,s3,s6
    80003d7a:	4585                	li	a1,1
    80003d7c:	01893503          	ld	a0,24(s2)
    80003d80:	fffff097          	auipc	ra,0xfffff
    80003d84:	270080e7          	jalr	624(ra) # 80002ff0 <writei>
    80003d88:	84aa                	mv	s1,a0
    80003d8a:	00a05763          	blez	a0,80003d98 <filewrite+0xc4>
        f->off += r;
    80003d8e:	02092783          	lw	a5,32(s2)
    80003d92:	9fa9                	addw	a5,a5,a0
    80003d94:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003d98:	01893503          	ld	a0,24(s2)
    80003d9c:	fffff097          	auipc	ra,0xfffff
    80003da0:	f6a080e7          	jalr	-150(ra) # 80002d06 <iunlock>
      end_op();
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	8ea080e7          	jalr	-1814(ra) # 8000368e <end_op>

      if(r != n1){
    80003dac:	009a9f63          	bne	s5,s1,80003dca <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003db0:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003db4:	0149db63          	bge	s3,s4,80003dca <filewrite+0xf6>
      int n1 = n - i;
    80003db8:	413a04bb          	subw	s1,s4,s3
    80003dbc:	0004879b          	sext.w	a5,s1
    80003dc0:	f8fbdce3          	bge	s7,a5,80003d58 <filewrite+0x84>
    80003dc4:	84e2                	mv	s1,s8
    80003dc6:	bf49                	j	80003d58 <filewrite+0x84>
    int i = 0;
    80003dc8:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80003dca:	013a1f63          	bne	s4,s3,80003de8 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80003dce:	8552                	mv	a0,s4
    80003dd0:	60a6                	ld	ra,72(sp)
    80003dd2:	6406                	ld	s0,64(sp)
    80003dd4:	74e2                	ld	s1,56(sp)
    80003dd6:	7942                	ld	s2,48(sp)
    80003dd8:	79a2                	ld	s3,40(sp)
    80003dda:	7a02                	ld	s4,32(sp)
    80003ddc:	6ae2                	ld	s5,24(sp)
    80003dde:	6b42                	ld	s6,16(sp)
    80003de0:	6ba2                	ld	s7,8(sp)
    80003de2:	6c02                	ld	s8,0(sp)
    80003de4:	6161                	addi	sp,sp,80
    80003de6:	8082                	ret
    ret = (i == n ? n : -1);
    80003de8:	5a7d                	li	s4,-1
    80003dea:	b7d5                	j	80003dce <filewrite+0xfa>
    panic("filewrite");
    80003dec:	00005517          	auipc	a0,0x5
    80003df0:	86450513          	addi	a0,a0,-1948 # 80008650 <syscalls+0x280>
    80003df4:	00002097          	auipc	ra,0x2
    80003df8:	f08080e7          	jalr	-248(ra) # 80005cfc <panic>
    return -1;
    80003dfc:	5a7d                	li	s4,-1
    80003dfe:	bfc1                	j	80003dce <filewrite+0xfa>
      return -1;
    80003e00:	5a7d                	li	s4,-1
    80003e02:	b7f1                	j	80003dce <filewrite+0xfa>
    80003e04:	5a7d                	li	s4,-1
    80003e06:	b7e1                	j	80003dce <filewrite+0xfa>

0000000080003e08 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003e08:	7179                	addi	sp,sp,-48
    80003e0a:	f406                	sd	ra,40(sp)
    80003e0c:	f022                	sd	s0,32(sp)
    80003e0e:	ec26                	sd	s1,24(sp)
    80003e10:	e84a                	sd	s2,16(sp)
    80003e12:	e44e                	sd	s3,8(sp)
    80003e14:	e052                	sd	s4,0(sp)
    80003e16:	1800                	addi	s0,sp,48
    80003e18:	84aa                	mv	s1,a0
    80003e1a:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003e1c:	0005b023          	sd	zero,0(a1)
    80003e20:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003e24:	00000097          	auipc	ra,0x0
    80003e28:	bf8080e7          	jalr	-1032(ra) # 80003a1c <filealloc>
    80003e2c:	e088                	sd	a0,0(s1)
    80003e2e:	c551                	beqz	a0,80003eba <pipealloc+0xb2>
    80003e30:	00000097          	auipc	ra,0x0
    80003e34:	bec080e7          	jalr	-1044(ra) # 80003a1c <filealloc>
    80003e38:	00aa3023          	sd	a0,0(s4)
    80003e3c:	c92d                	beqz	a0,80003eae <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003e3e:	ffffc097          	auipc	ra,0xffffc
    80003e42:	2dc080e7          	jalr	732(ra) # 8000011a <kalloc>
    80003e46:	892a                	mv	s2,a0
    80003e48:	c125                	beqz	a0,80003ea8 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003e4a:	4985                	li	s3,1
    80003e4c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80003e50:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80003e54:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003e58:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003e5c:	00005597          	auipc	a1,0x5
    80003e60:	80458593          	addi	a1,a1,-2044 # 80008660 <syscalls+0x290>
    80003e64:	00002097          	auipc	ra,0x2
    80003e68:	340080e7          	jalr	832(ra) # 800061a4 <initlock>
  (*f0)->type = FD_PIPE;
    80003e6c:	609c                	ld	a5,0(s1)
    80003e6e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80003e72:	609c                	ld	a5,0(s1)
    80003e74:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80003e78:	609c                	ld	a5,0(s1)
    80003e7a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003e7e:	609c                	ld	a5,0(s1)
    80003e80:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80003e84:	000a3783          	ld	a5,0(s4)
    80003e88:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80003e8c:	000a3783          	ld	a5,0(s4)
    80003e90:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003e94:	000a3783          	ld	a5,0(s4)
    80003e98:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80003e9c:	000a3783          	ld	a5,0(s4)
    80003ea0:	0127b823          	sd	s2,16(a5)
  return 0;
    80003ea4:	4501                	li	a0,0
    80003ea6:	a025                	j	80003ece <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003ea8:	6088                	ld	a0,0(s1)
    80003eaa:	e501                	bnez	a0,80003eb2 <pipealloc+0xaa>
    80003eac:	a039                	j	80003eba <pipealloc+0xb2>
    80003eae:	6088                	ld	a0,0(s1)
    80003eb0:	c51d                	beqz	a0,80003ede <pipealloc+0xd6>
    fileclose(*f0);
    80003eb2:	00000097          	auipc	ra,0x0
    80003eb6:	c26080e7          	jalr	-986(ra) # 80003ad8 <fileclose>
  if(*f1)
    80003eba:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80003ebe:	557d                	li	a0,-1
  if(*f1)
    80003ec0:	c799                	beqz	a5,80003ece <pipealloc+0xc6>
    fileclose(*f1);
    80003ec2:	853e                	mv	a0,a5
    80003ec4:	00000097          	auipc	ra,0x0
    80003ec8:	c14080e7          	jalr	-1004(ra) # 80003ad8 <fileclose>
  return -1;
    80003ecc:	557d                	li	a0,-1
}
    80003ece:	70a2                	ld	ra,40(sp)
    80003ed0:	7402                	ld	s0,32(sp)
    80003ed2:	64e2                	ld	s1,24(sp)
    80003ed4:	6942                	ld	s2,16(sp)
    80003ed6:	69a2                	ld	s3,8(sp)
    80003ed8:	6a02                	ld	s4,0(sp)
    80003eda:	6145                	addi	sp,sp,48
    80003edc:	8082                	ret
  return -1;
    80003ede:	557d                	li	a0,-1
    80003ee0:	b7fd                	j	80003ece <pipealloc+0xc6>

0000000080003ee2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003ee2:	1101                	addi	sp,sp,-32
    80003ee4:	ec06                	sd	ra,24(sp)
    80003ee6:	e822                	sd	s0,16(sp)
    80003ee8:	e426                	sd	s1,8(sp)
    80003eea:	e04a                	sd	s2,0(sp)
    80003eec:	1000                	addi	s0,sp,32
    80003eee:	84aa                	mv	s1,a0
    80003ef0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003ef2:	00002097          	auipc	ra,0x2
    80003ef6:	342080e7          	jalr	834(ra) # 80006234 <acquire>
  if(writable){
    80003efa:	02090d63          	beqz	s2,80003f34 <pipeclose+0x52>
    pi->writeopen = 0;
    80003efe:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003f02:	21848513          	addi	a0,s1,536
    80003f06:	ffffd097          	auipc	ra,0xffffd
    80003f0a:	664080e7          	jalr	1636(ra) # 8000156a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003f0e:	2204b783          	ld	a5,544(s1)
    80003f12:	eb95                	bnez	a5,80003f46 <pipeclose+0x64>
    release(&pi->lock);
    80003f14:	8526                	mv	a0,s1
    80003f16:	00002097          	auipc	ra,0x2
    80003f1a:	3d2080e7          	jalr	978(ra) # 800062e8 <release>
    kfree((char*)pi);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	ffffc097          	auipc	ra,0xffffc
    80003f24:	0fc080e7          	jalr	252(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003f28:	60e2                	ld	ra,24(sp)
    80003f2a:	6442                	ld	s0,16(sp)
    80003f2c:	64a2                	ld	s1,8(sp)
    80003f2e:	6902                	ld	s2,0(sp)
    80003f30:	6105                	addi	sp,sp,32
    80003f32:	8082                	ret
    pi->readopen = 0;
    80003f34:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003f38:	21c48513          	addi	a0,s1,540
    80003f3c:	ffffd097          	auipc	ra,0xffffd
    80003f40:	62e080e7          	jalr	1582(ra) # 8000156a <wakeup>
    80003f44:	b7e9                	j	80003f0e <pipeclose+0x2c>
    release(&pi->lock);
    80003f46:	8526                	mv	a0,s1
    80003f48:	00002097          	auipc	ra,0x2
    80003f4c:	3a0080e7          	jalr	928(ra) # 800062e8 <release>
}
    80003f50:	bfe1                	j	80003f28 <pipeclose+0x46>

0000000080003f52 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003f52:	711d                	addi	sp,sp,-96
    80003f54:	ec86                	sd	ra,88(sp)
    80003f56:	e8a2                	sd	s0,80(sp)
    80003f58:	e4a6                	sd	s1,72(sp)
    80003f5a:	e0ca                	sd	s2,64(sp)
    80003f5c:	fc4e                	sd	s3,56(sp)
    80003f5e:	f852                	sd	s4,48(sp)
    80003f60:	f456                	sd	s5,40(sp)
    80003f62:	f05a                	sd	s6,32(sp)
    80003f64:	ec5e                	sd	s7,24(sp)
    80003f66:	e862                	sd	s8,16(sp)
    80003f68:	1080                	addi	s0,sp,96
    80003f6a:	84aa                	mv	s1,a0
    80003f6c:	8aae                	mv	s5,a1
    80003f6e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003f70:	ffffd097          	auipc	ra,0xffffd
    80003f74:	ee4080e7          	jalr	-284(ra) # 80000e54 <myproc>
    80003f78:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	00002097          	auipc	ra,0x2
    80003f80:	2b8080e7          	jalr	696(ra) # 80006234 <acquire>
  while(i < n){
    80003f84:	0b405663          	blez	s4,80004030 <pipewrite+0xde>
  int i = 0;
    80003f88:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f8a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003f8c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003f90:	21c48b93          	addi	s7,s1,540
    80003f94:	a089                	j	80003fd6 <pipewrite+0x84>
      release(&pi->lock);
    80003f96:	8526                	mv	a0,s1
    80003f98:	00002097          	auipc	ra,0x2
    80003f9c:	350080e7          	jalr	848(ra) # 800062e8 <release>
      return -1;
    80003fa0:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003fa2:	854a                	mv	a0,s2
    80003fa4:	60e6                	ld	ra,88(sp)
    80003fa6:	6446                	ld	s0,80(sp)
    80003fa8:	64a6                	ld	s1,72(sp)
    80003faa:	6906                	ld	s2,64(sp)
    80003fac:	79e2                	ld	s3,56(sp)
    80003fae:	7a42                	ld	s4,48(sp)
    80003fb0:	7aa2                	ld	s5,40(sp)
    80003fb2:	7b02                	ld	s6,32(sp)
    80003fb4:	6be2                	ld	s7,24(sp)
    80003fb6:	6c42                	ld	s8,16(sp)
    80003fb8:	6125                	addi	sp,sp,96
    80003fba:	8082                	ret
      wakeup(&pi->nread);
    80003fbc:	8562                	mv	a0,s8
    80003fbe:	ffffd097          	auipc	ra,0xffffd
    80003fc2:	5ac080e7          	jalr	1452(ra) # 8000156a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003fc6:	85a6                	mv	a1,s1
    80003fc8:	855e                	mv	a0,s7
    80003fca:	ffffd097          	auipc	ra,0xffffd
    80003fce:	53c080e7          	jalr	1340(ra) # 80001506 <sleep>
  while(i < n){
    80003fd2:	07495063          	bge	s2,s4,80004032 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80003fd6:	2204a783          	lw	a5,544(s1)
    80003fda:	dfd5                	beqz	a5,80003f96 <pipewrite+0x44>
    80003fdc:	854e                	mv	a0,s3
    80003fde:	ffffd097          	auipc	ra,0xffffd
    80003fe2:	7d0080e7          	jalr	2000(ra) # 800017ae <killed>
    80003fe6:	f945                	bnez	a0,80003f96 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80003fe8:	2184a783          	lw	a5,536(s1)
    80003fec:	21c4a703          	lw	a4,540(s1)
    80003ff0:	2007879b          	addiw	a5,a5,512
    80003ff4:	fcf704e3          	beq	a4,a5,80003fbc <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003ff8:	4685                	li	a3,1
    80003ffa:	01590633          	add	a2,s2,s5
    80003ffe:	faf40593          	addi	a1,s0,-81
    80004002:	0509b503          	ld	a0,80(s3)
    80004006:	ffffd097          	auipc	ra,0xffffd
    8000400a:	b9a080e7          	jalr	-1126(ra) # 80000ba0 <copyin>
    8000400e:	03650263          	beq	a0,s6,80004032 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004012:	21c4a783          	lw	a5,540(s1)
    80004016:	0017871b          	addiw	a4,a5,1
    8000401a:	20e4ae23          	sw	a4,540(s1)
    8000401e:	1ff7f793          	andi	a5,a5,511
    80004022:	97a6                	add	a5,a5,s1
    80004024:	faf44703          	lbu	a4,-81(s0)
    80004028:	00e78c23          	sb	a4,24(a5)
      i++;
    8000402c:	2905                	addiw	s2,s2,1
    8000402e:	b755                	j	80003fd2 <pipewrite+0x80>
  int i = 0;
    80004030:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004032:	21848513          	addi	a0,s1,536
    80004036:	ffffd097          	auipc	ra,0xffffd
    8000403a:	534080e7          	jalr	1332(ra) # 8000156a <wakeup>
  release(&pi->lock);
    8000403e:	8526                	mv	a0,s1
    80004040:	00002097          	auipc	ra,0x2
    80004044:	2a8080e7          	jalr	680(ra) # 800062e8 <release>
  return i;
    80004048:	bfa9                	j	80003fa2 <pipewrite+0x50>

000000008000404a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000404a:	715d                	addi	sp,sp,-80
    8000404c:	e486                	sd	ra,72(sp)
    8000404e:	e0a2                	sd	s0,64(sp)
    80004050:	fc26                	sd	s1,56(sp)
    80004052:	f84a                	sd	s2,48(sp)
    80004054:	f44e                	sd	s3,40(sp)
    80004056:	f052                	sd	s4,32(sp)
    80004058:	ec56                	sd	s5,24(sp)
    8000405a:	e85a                	sd	s6,16(sp)
    8000405c:	0880                	addi	s0,sp,80
    8000405e:	84aa                	mv	s1,a0
    80004060:	892e                	mv	s2,a1
    80004062:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004064:	ffffd097          	auipc	ra,0xffffd
    80004068:	df0080e7          	jalr	-528(ra) # 80000e54 <myproc>
    8000406c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000406e:	8526                	mv	a0,s1
    80004070:	00002097          	auipc	ra,0x2
    80004074:	1c4080e7          	jalr	452(ra) # 80006234 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004078:	2184a703          	lw	a4,536(s1)
    8000407c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004080:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004084:	02f71763          	bne	a4,a5,800040b2 <piperead+0x68>
    80004088:	2244a783          	lw	a5,548(s1)
    8000408c:	c39d                	beqz	a5,800040b2 <piperead+0x68>
    if(killed(pr)){
    8000408e:	8552                	mv	a0,s4
    80004090:	ffffd097          	auipc	ra,0xffffd
    80004094:	71e080e7          	jalr	1822(ra) # 800017ae <killed>
    80004098:	e949                	bnez	a0,8000412a <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000409a:	85a6                	mv	a1,s1
    8000409c:	854e                	mv	a0,s3
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	468080e7          	jalr	1128(ra) # 80001506 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800040a6:	2184a703          	lw	a4,536(s1)
    800040aa:	21c4a783          	lw	a5,540(s1)
    800040ae:	fcf70de3          	beq	a4,a5,80004088 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800040b2:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800040b4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800040b6:	05505463          	blez	s5,800040fe <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800040ba:	2184a783          	lw	a5,536(s1)
    800040be:	21c4a703          	lw	a4,540(s1)
    800040c2:	02f70e63          	beq	a4,a5,800040fe <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800040c6:	0017871b          	addiw	a4,a5,1
    800040ca:	20e4ac23          	sw	a4,536(s1)
    800040ce:	1ff7f793          	andi	a5,a5,511
    800040d2:	97a6                	add	a5,a5,s1
    800040d4:	0187c783          	lbu	a5,24(a5)
    800040d8:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800040dc:	4685                	li	a3,1
    800040de:	fbf40613          	addi	a2,s0,-65
    800040e2:	85ca                	mv	a1,s2
    800040e4:	050a3503          	ld	a0,80(s4)
    800040e8:	ffffd097          	auipc	ra,0xffffd
    800040ec:	a2c080e7          	jalr	-1492(ra) # 80000b14 <copyout>
    800040f0:	01650763          	beq	a0,s6,800040fe <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800040f4:	2985                	addiw	s3,s3,1
    800040f6:	0905                	addi	s2,s2,1
    800040f8:	fd3a91e3          	bne	s5,s3,800040ba <piperead+0x70>
    800040fc:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800040fe:	21c48513          	addi	a0,s1,540
    80004102:	ffffd097          	auipc	ra,0xffffd
    80004106:	468080e7          	jalr	1128(ra) # 8000156a <wakeup>
  release(&pi->lock);
    8000410a:	8526                	mv	a0,s1
    8000410c:	00002097          	auipc	ra,0x2
    80004110:	1dc080e7          	jalr	476(ra) # 800062e8 <release>
  return i;
}
    80004114:	854e                	mv	a0,s3
    80004116:	60a6                	ld	ra,72(sp)
    80004118:	6406                	ld	s0,64(sp)
    8000411a:	74e2                	ld	s1,56(sp)
    8000411c:	7942                	ld	s2,48(sp)
    8000411e:	79a2                	ld	s3,40(sp)
    80004120:	7a02                	ld	s4,32(sp)
    80004122:	6ae2                	ld	s5,24(sp)
    80004124:	6b42                	ld	s6,16(sp)
    80004126:	6161                	addi	sp,sp,80
    80004128:	8082                	ret
      release(&pi->lock);
    8000412a:	8526                	mv	a0,s1
    8000412c:	00002097          	auipc	ra,0x2
    80004130:	1bc080e7          	jalr	444(ra) # 800062e8 <release>
      return -1;
    80004134:	59fd                	li	s3,-1
    80004136:	bff9                	j	80004114 <piperead+0xca>

0000000080004138 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004138:	1141                	addi	sp,sp,-16
    8000413a:	e422                	sd	s0,8(sp)
    8000413c:	0800                	addi	s0,sp,16
    8000413e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004140:	8905                	andi	a0,a0,1
    80004142:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004144:	8b89                	andi	a5,a5,2
    80004146:	c399                	beqz	a5,8000414c <flags2perm+0x14>
      perm |= PTE_W;
    80004148:	00456513          	ori	a0,a0,4
    return perm;
}
    8000414c:	6422                	ld	s0,8(sp)
    8000414e:	0141                	addi	sp,sp,16
    80004150:	8082                	ret

0000000080004152 <exec>:

int
exec(char *path, char **argv)
{
    80004152:	de010113          	addi	sp,sp,-544
    80004156:	20113c23          	sd	ra,536(sp)
    8000415a:	20813823          	sd	s0,528(sp)
    8000415e:	20913423          	sd	s1,520(sp)
    80004162:	21213023          	sd	s2,512(sp)
    80004166:	ffce                	sd	s3,504(sp)
    80004168:	fbd2                	sd	s4,496(sp)
    8000416a:	f7d6                	sd	s5,488(sp)
    8000416c:	f3da                	sd	s6,480(sp)
    8000416e:	efde                	sd	s7,472(sp)
    80004170:	ebe2                	sd	s8,464(sp)
    80004172:	e7e6                	sd	s9,456(sp)
    80004174:	e3ea                	sd	s10,448(sp)
    80004176:	ff6e                	sd	s11,440(sp)
    80004178:	1400                	addi	s0,sp,544
    8000417a:	892a                	mv	s2,a0
    8000417c:	dea43423          	sd	a0,-536(s0)
    80004180:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004184:	ffffd097          	auipc	ra,0xffffd
    80004188:	cd0080e7          	jalr	-816(ra) # 80000e54 <myproc>
    8000418c:	84aa                	mv	s1,a0

  begin_op();
    8000418e:	fffff097          	auipc	ra,0xfffff
    80004192:	482080e7          	jalr	1154(ra) # 80003610 <begin_op>

  if((ip = namei(path)) == 0){
    80004196:	854a                	mv	a0,s2
    80004198:	fffff097          	auipc	ra,0xfffff
    8000419c:	258080e7          	jalr	600(ra) # 800033f0 <namei>
    800041a0:	c93d                	beqz	a0,80004216 <exec+0xc4>
    800041a2:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800041a4:	fffff097          	auipc	ra,0xfffff
    800041a8:	aa0080e7          	jalr	-1376(ra) # 80002c44 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800041ac:	04000713          	li	a4,64
    800041b0:	4681                	li	a3,0
    800041b2:	e5040613          	addi	a2,s0,-432
    800041b6:	4581                	li	a1,0
    800041b8:	8556                	mv	a0,s5
    800041ba:	fffff097          	auipc	ra,0xfffff
    800041be:	d3e080e7          	jalr	-706(ra) # 80002ef8 <readi>
    800041c2:	04000793          	li	a5,64
    800041c6:	00f51a63          	bne	a0,a5,800041da <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800041ca:	e5042703          	lw	a4,-432(s0)
    800041ce:	464c47b7          	lui	a5,0x464c4
    800041d2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800041d6:	04f70663          	beq	a4,a5,80004222 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800041da:	8556                	mv	a0,s5
    800041dc:	fffff097          	auipc	ra,0xfffff
    800041e0:	cca080e7          	jalr	-822(ra) # 80002ea6 <iunlockput>
    end_op();
    800041e4:	fffff097          	auipc	ra,0xfffff
    800041e8:	4aa080e7          	jalr	1194(ra) # 8000368e <end_op>
  }
  return -1;
    800041ec:	557d                	li	a0,-1
}
    800041ee:	21813083          	ld	ra,536(sp)
    800041f2:	21013403          	ld	s0,528(sp)
    800041f6:	20813483          	ld	s1,520(sp)
    800041fa:	20013903          	ld	s2,512(sp)
    800041fe:	79fe                	ld	s3,504(sp)
    80004200:	7a5e                	ld	s4,496(sp)
    80004202:	7abe                	ld	s5,488(sp)
    80004204:	7b1e                	ld	s6,480(sp)
    80004206:	6bfe                	ld	s7,472(sp)
    80004208:	6c5e                	ld	s8,464(sp)
    8000420a:	6cbe                	ld	s9,456(sp)
    8000420c:	6d1e                	ld	s10,448(sp)
    8000420e:	7dfa                	ld	s11,440(sp)
    80004210:	22010113          	addi	sp,sp,544
    80004214:	8082                	ret
    end_op();
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	478080e7          	jalr	1144(ra) # 8000368e <end_op>
    return -1;
    8000421e:	557d                	li	a0,-1
    80004220:	b7f9                	j	800041ee <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004222:	8526                	mv	a0,s1
    80004224:	ffffd097          	auipc	ra,0xffffd
    80004228:	cf4080e7          	jalr	-780(ra) # 80000f18 <proc_pagetable>
    8000422c:	8b2a                	mv	s6,a0
    8000422e:	d555                	beqz	a0,800041da <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004230:	e7042783          	lw	a5,-400(s0)
    80004234:	e8845703          	lhu	a4,-376(s0)
    80004238:	c735                	beqz	a4,800042a4 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000423a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000423c:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004240:	6a05                	lui	s4,0x1
    80004242:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004246:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    8000424a:	6d85                	lui	s11,0x1
    8000424c:	7d7d                	lui	s10,0xfffff
    8000424e:	ac3d                	j	8000448c <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004250:	00004517          	auipc	a0,0x4
    80004254:	41850513          	addi	a0,a0,1048 # 80008668 <syscalls+0x298>
    80004258:	00002097          	auipc	ra,0x2
    8000425c:	aa4080e7          	jalr	-1372(ra) # 80005cfc <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004260:	874a                	mv	a4,s2
    80004262:	009c86bb          	addw	a3,s9,s1
    80004266:	4581                	li	a1,0
    80004268:	8556                	mv	a0,s5
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	c8e080e7          	jalr	-882(ra) # 80002ef8 <readi>
    80004272:	2501                	sext.w	a0,a0
    80004274:	1aa91963          	bne	s2,a0,80004426 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004278:	009d84bb          	addw	s1,s11,s1
    8000427c:	013d09bb          	addw	s3,s10,s3
    80004280:	1f74f663          	bgeu	s1,s7,8000446c <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004284:	02049593          	slli	a1,s1,0x20
    80004288:	9181                	srli	a1,a1,0x20
    8000428a:	95e2                	add	a1,a1,s8
    8000428c:	855a                	mv	a0,s6
    8000428e:	ffffc097          	auipc	ra,0xffffc
    80004292:	276080e7          	jalr	630(ra) # 80000504 <walkaddr>
    80004296:	862a                	mv	a2,a0
    if(pa == 0)
    80004298:	dd45                	beqz	a0,80004250 <exec+0xfe>
      n = PGSIZE;
    8000429a:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000429c:	fd49f2e3          	bgeu	s3,s4,80004260 <exec+0x10e>
      n = sz - i;
    800042a0:	894e                	mv	s2,s3
    800042a2:	bf7d                	j	80004260 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800042a4:	4901                	li	s2,0
  iunlockput(ip);
    800042a6:	8556                	mv	a0,s5
    800042a8:	fffff097          	auipc	ra,0xfffff
    800042ac:	bfe080e7          	jalr	-1026(ra) # 80002ea6 <iunlockput>
  end_op();
    800042b0:	fffff097          	auipc	ra,0xfffff
    800042b4:	3de080e7          	jalr	990(ra) # 8000368e <end_op>
  p = myproc();
    800042b8:	ffffd097          	auipc	ra,0xffffd
    800042bc:	b9c080e7          	jalr	-1124(ra) # 80000e54 <myproc>
    800042c0:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800042c2:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800042c6:	6785                	lui	a5,0x1
    800042c8:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800042ca:	97ca                	add	a5,a5,s2
    800042cc:	777d                	lui	a4,0xfffff
    800042ce:	8ff9                	and	a5,a5,a4
    800042d0:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800042d4:	4691                	li	a3,4
    800042d6:	6609                	lui	a2,0x2
    800042d8:	963e                	add	a2,a2,a5
    800042da:	85be                	mv	a1,a5
    800042dc:	855a                	mv	a0,s6
    800042de:	ffffc097          	auipc	ra,0xffffc
    800042e2:	5da080e7          	jalr	1498(ra) # 800008b8 <uvmalloc>
    800042e6:	8c2a                	mv	s8,a0
  ip = 0;
    800042e8:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800042ea:	12050e63          	beqz	a0,80004426 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800042ee:	75f9                	lui	a1,0xffffe
    800042f0:	95aa                	add	a1,a1,a0
    800042f2:	855a                	mv	a0,s6
    800042f4:	ffffc097          	auipc	ra,0xffffc
    800042f8:	7ee080e7          	jalr	2030(ra) # 80000ae2 <uvmclear>
  stackbase = sp - PGSIZE;
    800042fc:	7afd                	lui	s5,0xfffff
    800042fe:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004300:	df043783          	ld	a5,-528(s0)
    80004304:	6388                	ld	a0,0(a5)
    80004306:	c925                	beqz	a0,80004376 <exec+0x224>
    80004308:	e9040993          	addi	s3,s0,-368
    8000430c:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004310:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004312:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004314:	ffffc097          	auipc	ra,0xffffc
    80004318:	fe2080e7          	jalr	-30(ra) # 800002f6 <strlen>
    8000431c:	0015079b          	addiw	a5,a0,1
    80004320:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004324:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004328:	13596663          	bltu	s2,s5,80004454 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000432c:	df043d83          	ld	s11,-528(s0)
    80004330:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004334:	8552                	mv	a0,s4
    80004336:	ffffc097          	auipc	ra,0xffffc
    8000433a:	fc0080e7          	jalr	-64(ra) # 800002f6 <strlen>
    8000433e:	0015069b          	addiw	a3,a0,1
    80004342:	8652                	mv	a2,s4
    80004344:	85ca                	mv	a1,s2
    80004346:	855a                	mv	a0,s6
    80004348:	ffffc097          	auipc	ra,0xffffc
    8000434c:	7cc080e7          	jalr	1996(ra) # 80000b14 <copyout>
    80004350:	10054663          	bltz	a0,8000445c <exec+0x30a>
    ustack[argc] = sp;
    80004354:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004358:	0485                	addi	s1,s1,1
    8000435a:	008d8793          	addi	a5,s11,8
    8000435e:	def43823          	sd	a5,-528(s0)
    80004362:	008db503          	ld	a0,8(s11)
    80004366:	c911                	beqz	a0,8000437a <exec+0x228>
    if(argc >= MAXARG)
    80004368:	09a1                	addi	s3,s3,8
    8000436a:	fb3c95e3          	bne	s9,s3,80004314 <exec+0x1c2>
  sz = sz1;
    8000436e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004372:	4a81                	li	s5,0
    80004374:	a84d                	j	80004426 <exec+0x2d4>
  sp = sz;
    80004376:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004378:	4481                	li	s1,0
  ustack[argc] = 0;
    8000437a:	00349793          	slli	a5,s1,0x3
    8000437e:	f9078793          	addi	a5,a5,-112
    80004382:	97a2                	add	a5,a5,s0
    80004384:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004388:	00148693          	addi	a3,s1,1
    8000438c:	068e                	slli	a3,a3,0x3
    8000438e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004392:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004396:	01597663          	bgeu	s2,s5,800043a2 <exec+0x250>
  sz = sz1;
    8000439a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000439e:	4a81                	li	s5,0
    800043a0:	a059                	j	80004426 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800043a2:	e9040613          	addi	a2,s0,-368
    800043a6:	85ca                	mv	a1,s2
    800043a8:	855a                	mv	a0,s6
    800043aa:	ffffc097          	auipc	ra,0xffffc
    800043ae:	76a080e7          	jalr	1898(ra) # 80000b14 <copyout>
    800043b2:	0a054963          	bltz	a0,80004464 <exec+0x312>
  p->trapframe->a1 = sp;
    800043b6:	058bb783          	ld	a5,88(s7)
    800043ba:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800043be:	de843783          	ld	a5,-536(s0)
    800043c2:	0007c703          	lbu	a4,0(a5)
    800043c6:	cf11                	beqz	a4,800043e2 <exec+0x290>
    800043c8:	0785                	addi	a5,a5,1
    if(*s == '/')
    800043ca:	02f00693          	li	a3,47
    800043ce:	a039                	j	800043dc <exec+0x28a>
      last = s+1;
    800043d0:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800043d4:	0785                	addi	a5,a5,1
    800043d6:	fff7c703          	lbu	a4,-1(a5)
    800043da:	c701                	beqz	a4,800043e2 <exec+0x290>
    if(*s == '/')
    800043dc:	fed71ce3          	bne	a4,a3,800043d4 <exec+0x282>
    800043e0:	bfc5                	j	800043d0 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800043e2:	4641                	li	a2,16
    800043e4:	de843583          	ld	a1,-536(s0)
    800043e8:	158b8513          	addi	a0,s7,344
    800043ec:	ffffc097          	auipc	ra,0xffffc
    800043f0:	ed8080e7          	jalr	-296(ra) # 800002c4 <safestrcpy>
  oldpagetable = p->pagetable;
    800043f4:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800043f8:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800043fc:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004400:	058bb783          	ld	a5,88(s7)
    80004404:	e6843703          	ld	a4,-408(s0)
    80004408:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    8000440a:	058bb783          	ld	a5,88(s7)
    8000440e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004412:	85ea                	mv	a1,s10
    80004414:	ffffd097          	auipc	ra,0xffffd
    80004418:	ba0080e7          	jalr	-1120(ra) # 80000fb4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000441c:	0004851b          	sext.w	a0,s1
    80004420:	b3f9                	j	800041ee <exec+0x9c>
    80004422:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004426:	df843583          	ld	a1,-520(s0)
    8000442a:	855a                	mv	a0,s6
    8000442c:	ffffd097          	auipc	ra,0xffffd
    80004430:	b88080e7          	jalr	-1144(ra) # 80000fb4 <proc_freepagetable>
  if(ip){
    80004434:	da0a93e3          	bnez	s5,800041da <exec+0x88>
  return -1;
    80004438:	557d                	li	a0,-1
    8000443a:	bb55                	j	800041ee <exec+0x9c>
    8000443c:	df243c23          	sd	s2,-520(s0)
    80004440:	b7dd                	j	80004426 <exec+0x2d4>
    80004442:	df243c23          	sd	s2,-520(s0)
    80004446:	b7c5                	j	80004426 <exec+0x2d4>
    80004448:	df243c23          	sd	s2,-520(s0)
    8000444c:	bfe9                	j	80004426 <exec+0x2d4>
    8000444e:	df243c23          	sd	s2,-520(s0)
    80004452:	bfd1                	j	80004426 <exec+0x2d4>
  sz = sz1;
    80004454:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004458:	4a81                	li	s5,0
    8000445a:	b7f1                	j	80004426 <exec+0x2d4>
  sz = sz1;
    8000445c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004460:	4a81                	li	s5,0
    80004462:	b7d1                	j	80004426 <exec+0x2d4>
  sz = sz1;
    80004464:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004468:	4a81                	li	s5,0
    8000446a:	bf75                	j	80004426 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000446c:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004470:	e0843783          	ld	a5,-504(s0)
    80004474:	0017869b          	addiw	a3,a5,1
    80004478:	e0d43423          	sd	a3,-504(s0)
    8000447c:	e0043783          	ld	a5,-512(s0)
    80004480:	0387879b          	addiw	a5,a5,56
    80004484:	e8845703          	lhu	a4,-376(s0)
    80004488:	e0e6dfe3          	bge	a3,a4,800042a6 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000448c:	2781                	sext.w	a5,a5
    8000448e:	e0f43023          	sd	a5,-512(s0)
    80004492:	03800713          	li	a4,56
    80004496:	86be                	mv	a3,a5
    80004498:	e1840613          	addi	a2,s0,-488
    8000449c:	4581                	li	a1,0
    8000449e:	8556                	mv	a0,s5
    800044a0:	fffff097          	auipc	ra,0xfffff
    800044a4:	a58080e7          	jalr	-1448(ra) # 80002ef8 <readi>
    800044a8:	03800793          	li	a5,56
    800044ac:	f6f51be3          	bne	a0,a5,80004422 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    800044b0:	e1842783          	lw	a5,-488(s0)
    800044b4:	4705                	li	a4,1
    800044b6:	fae79de3          	bne	a5,a4,80004470 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    800044ba:	e4043483          	ld	s1,-448(s0)
    800044be:	e3843783          	ld	a5,-456(s0)
    800044c2:	f6f4ede3          	bltu	s1,a5,8000443c <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800044c6:	e2843783          	ld	a5,-472(s0)
    800044ca:	94be                	add	s1,s1,a5
    800044cc:	f6f4ebe3          	bltu	s1,a5,80004442 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    800044d0:	de043703          	ld	a4,-544(s0)
    800044d4:	8ff9                	and	a5,a5,a4
    800044d6:	fbad                	bnez	a5,80004448 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800044d8:	e1c42503          	lw	a0,-484(s0)
    800044dc:	00000097          	auipc	ra,0x0
    800044e0:	c5c080e7          	jalr	-932(ra) # 80004138 <flags2perm>
    800044e4:	86aa                	mv	a3,a0
    800044e6:	8626                	mv	a2,s1
    800044e8:	85ca                	mv	a1,s2
    800044ea:	855a                	mv	a0,s6
    800044ec:	ffffc097          	auipc	ra,0xffffc
    800044f0:	3cc080e7          	jalr	972(ra) # 800008b8 <uvmalloc>
    800044f4:	dea43c23          	sd	a0,-520(s0)
    800044f8:	d939                	beqz	a0,8000444e <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800044fa:	e2843c03          	ld	s8,-472(s0)
    800044fe:	e2042c83          	lw	s9,-480(s0)
    80004502:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004506:	f60b83e3          	beqz	s7,8000446c <exec+0x31a>
    8000450a:	89de                	mv	s3,s7
    8000450c:	4481                	li	s1,0
    8000450e:	bb9d                	j	80004284 <exec+0x132>

0000000080004510 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004510:	7179                	addi	sp,sp,-48
    80004512:	f406                	sd	ra,40(sp)
    80004514:	f022                	sd	s0,32(sp)
    80004516:	ec26                	sd	s1,24(sp)
    80004518:	e84a                	sd	s2,16(sp)
    8000451a:	1800                	addi	s0,sp,48
    8000451c:	892e                	mv	s2,a1
    8000451e:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004520:	fdc40593          	addi	a1,s0,-36
    80004524:	ffffe097          	auipc	ra,0xffffe
    80004528:	aa6080e7          	jalr	-1370(ra) # 80001fca <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000452c:	fdc42703          	lw	a4,-36(s0)
    80004530:	47bd                	li	a5,15
    80004532:	02e7eb63          	bltu	a5,a4,80004568 <argfd+0x58>
    80004536:	ffffd097          	auipc	ra,0xffffd
    8000453a:	91e080e7          	jalr	-1762(ra) # 80000e54 <myproc>
    8000453e:	fdc42703          	lw	a4,-36(s0)
    80004542:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdcaaa>
    80004546:	078e                	slli	a5,a5,0x3
    80004548:	953e                	add	a0,a0,a5
    8000454a:	611c                	ld	a5,0(a0)
    8000454c:	c385                	beqz	a5,8000456c <argfd+0x5c>
    return -1;
  if(pfd)
    8000454e:	00090463          	beqz	s2,80004556 <argfd+0x46>
    *pfd = fd;
    80004552:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004556:	4501                	li	a0,0
  if(pf)
    80004558:	c091                	beqz	s1,8000455c <argfd+0x4c>
    *pf = f;
    8000455a:	e09c                	sd	a5,0(s1)
}
    8000455c:	70a2                	ld	ra,40(sp)
    8000455e:	7402                	ld	s0,32(sp)
    80004560:	64e2                	ld	s1,24(sp)
    80004562:	6942                	ld	s2,16(sp)
    80004564:	6145                	addi	sp,sp,48
    80004566:	8082                	ret
    return -1;
    80004568:	557d                	li	a0,-1
    8000456a:	bfcd                	j	8000455c <argfd+0x4c>
    8000456c:	557d                	li	a0,-1
    8000456e:	b7fd                	j	8000455c <argfd+0x4c>

0000000080004570 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004570:	1101                	addi	sp,sp,-32
    80004572:	ec06                	sd	ra,24(sp)
    80004574:	e822                	sd	s0,16(sp)
    80004576:	e426                	sd	s1,8(sp)
    80004578:	1000                	addi	s0,sp,32
    8000457a:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000457c:	ffffd097          	auipc	ra,0xffffd
    80004580:	8d8080e7          	jalr	-1832(ra) # 80000e54 <myproc>
    80004584:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004586:	0d050793          	addi	a5,a0,208
    8000458a:	4501                	li	a0,0
    8000458c:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000458e:	6398                	ld	a4,0(a5)
    80004590:	cb19                	beqz	a4,800045a6 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004592:	2505                	addiw	a0,a0,1
    80004594:	07a1                	addi	a5,a5,8
    80004596:	fed51ce3          	bne	a0,a3,8000458e <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000459a:	557d                	li	a0,-1
}
    8000459c:	60e2                	ld	ra,24(sp)
    8000459e:	6442                	ld	s0,16(sp)
    800045a0:	64a2                	ld	s1,8(sp)
    800045a2:	6105                	addi	sp,sp,32
    800045a4:	8082                	ret
      p->ofile[fd] = f;
    800045a6:	01a50793          	addi	a5,a0,26
    800045aa:	078e                	slli	a5,a5,0x3
    800045ac:	963e                	add	a2,a2,a5
    800045ae:	e204                	sd	s1,0(a2)
      return fd;
    800045b0:	b7f5                	j	8000459c <fdalloc+0x2c>

00000000800045b2 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800045b2:	715d                	addi	sp,sp,-80
    800045b4:	e486                	sd	ra,72(sp)
    800045b6:	e0a2                	sd	s0,64(sp)
    800045b8:	fc26                	sd	s1,56(sp)
    800045ba:	f84a                	sd	s2,48(sp)
    800045bc:	f44e                	sd	s3,40(sp)
    800045be:	f052                	sd	s4,32(sp)
    800045c0:	ec56                	sd	s5,24(sp)
    800045c2:	e85a                	sd	s6,16(sp)
    800045c4:	0880                	addi	s0,sp,80
    800045c6:	8b2e                	mv	s6,a1
    800045c8:	89b2                	mv	s3,a2
    800045ca:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800045cc:	fb040593          	addi	a1,s0,-80
    800045d0:	fffff097          	auipc	ra,0xfffff
    800045d4:	e3e080e7          	jalr	-450(ra) # 8000340e <nameiparent>
    800045d8:	84aa                	mv	s1,a0
    800045da:	14050f63          	beqz	a0,80004738 <create+0x186>
    return 0;

  ilock(dp);
    800045de:	ffffe097          	auipc	ra,0xffffe
    800045e2:	666080e7          	jalr	1638(ra) # 80002c44 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800045e6:	4601                	li	a2,0
    800045e8:	fb040593          	addi	a1,s0,-80
    800045ec:	8526                	mv	a0,s1
    800045ee:	fffff097          	auipc	ra,0xfffff
    800045f2:	b3a080e7          	jalr	-1222(ra) # 80003128 <dirlookup>
    800045f6:	8aaa                	mv	s5,a0
    800045f8:	c931                	beqz	a0,8000464c <create+0x9a>
    iunlockput(dp);
    800045fa:	8526                	mv	a0,s1
    800045fc:	fffff097          	auipc	ra,0xfffff
    80004600:	8aa080e7          	jalr	-1878(ra) # 80002ea6 <iunlockput>
    ilock(ip);
    80004604:	8556                	mv	a0,s5
    80004606:	ffffe097          	auipc	ra,0xffffe
    8000460a:	63e080e7          	jalr	1598(ra) # 80002c44 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000460e:	000b059b          	sext.w	a1,s6
    80004612:	4789                	li	a5,2
    80004614:	02f59563          	bne	a1,a5,8000463e <create+0x8c>
    80004618:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcad4>
    8000461c:	37f9                	addiw	a5,a5,-2
    8000461e:	17c2                	slli	a5,a5,0x30
    80004620:	93c1                	srli	a5,a5,0x30
    80004622:	4705                	li	a4,1
    80004624:	00f76d63          	bltu	a4,a5,8000463e <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004628:	8556                	mv	a0,s5
    8000462a:	60a6                	ld	ra,72(sp)
    8000462c:	6406                	ld	s0,64(sp)
    8000462e:	74e2                	ld	s1,56(sp)
    80004630:	7942                	ld	s2,48(sp)
    80004632:	79a2                	ld	s3,40(sp)
    80004634:	7a02                	ld	s4,32(sp)
    80004636:	6ae2                	ld	s5,24(sp)
    80004638:	6b42                	ld	s6,16(sp)
    8000463a:	6161                	addi	sp,sp,80
    8000463c:	8082                	ret
    iunlockput(ip);
    8000463e:	8556                	mv	a0,s5
    80004640:	fffff097          	auipc	ra,0xfffff
    80004644:	866080e7          	jalr	-1946(ra) # 80002ea6 <iunlockput>
    return 0;
    80004648:	4a81                	li	s5,0
    8000464a:	bff9                	j	80004628 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000464c:	85da                	mv	a1,s6
    8000464e:	4088                	lw	a0,0(s1)
    80004650:	ffffe097          	auipc	ra,0xffffe
    80004654:	456080e7          	jalr	1110(ra) # 80002aa6 <ialloc>
    80004658:	8a2a                	mv	s4,a0
    8000465a:	c539                	beqz	a0,800046a8 <create+0xf6>
  ilock(ip);
    8000465c:	ffffe097          	auipc	ra,0xffffe
    80004660:	5e8080e7          	jalr	1512(ra) # 80002c44 <ilock>
  ip->major = major;
    80004664:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004668:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000466c:	4905                	li	s2,1
    8000466e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80004672:	8552                	mv	a0,s4
    80004674:	ffffe097          	auipc	ra,0xffffe
    80004678:	504080e7          	jalr	1284(ra) # 80002b78 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000467c:	000b059b          	sext.w	a1,s6
    80004680:	03258b63          	beq	a1,s2,800046b6 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80004684:	004a2603          	lw	a2,4(s4)
    80004688:	fb040593          	addi	a1,s0,-80
    8000468c:	8526                	mv	a0,s1
    8000468e:	fffff097          	auipc	ra,0xfffff
    80004692:	cb0080e7          	jalr	-848(ra) # 8000333e <dirlink>
    80004696:	06054f63          	bltz	a0,80004714 <create+0x162>
  iunlockput(dp);
    8000469a:	8526                	mv	a0,s1
    8000469c:	fffff097          	auipc	ra,0xfffff
    800046a0:	80a080e7          	jalr	-2038(ra) # 80002ea6 <iunlockput>
  return ip;
    800046a4:	8ad2                	mv	s5,s4
    800046a6:	b749                	j	80004628 <create+0x76>
    iunlockput(dp);
    800046a8:	8526                	mv	a0,s1
    800046aa:	ffffe097          	auipc	ra,0xffffe
    800046ae:	7fc080e7          	jalr	2044(ra) # 80002ea6 <iunlockput>
    return 0;
    800046b2:	8ad2                	mv	s5,s4
    800046b4:	bf95                	j	80004628 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800046b6:	004a2603          	lw	a2,4(s4)
    800046ba:	00004597          	auipc	a1,0x4
    800046be:	fce58593          	addi	a1,a1,-50 # 80008688 <syscalls+0x2b8>
    800046c2:	8552                	mv	a0,s4
    800046c4:	fffff097          	auipc	ra,0xfffff
    800046c8:	c7a080e7          	jalr	-902(ra) # 8000333e <dirlink>
    800046cc:	04054463          	bltz	a0,80004714 <create+0x162>
    800046d0:	40d0                	lw	a2,4(s1)
    800046d2:	00004597          	auipc	a1,0x4
    800046d6:	fbe58593          	addi	a1,a1,-66 # 80008690 <syscalls+0x2c0>
    800046da:	8552                	mv	a0,s4
    800046dc:	fffff097          	auipc	ra,0xfffff
    800046e0:	c62080e7          	jalr	-926(ra) # 8000333e <dirlink>
    800046e4:	02054863          	bltz	a0,80004714 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800046e8:	004a2603          	lw	a2,4(s4)
    800046ec:	fb040593          	addi	a1,s0,-80
    800046f0:	8526                	mv	a0,s1
    800046f2:	fffff097          	auipc	ra,0xfffff
    800046f6:	c4c080e7          	jalr	-948(ra) # 8000333e <dirlink>
    800046fa:	00054d63          	bltz	a0,80004714 <create+0x162>
    dp->nlink++;  // for ".."
    800046fe:	04a4d783          	lhu	a5,74(s1)
    80004702:	2785                	addiw	a5,a5,1
    80004704:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004708:	8526                	mv	a0,s1
    8000470a:	ffffe097          	auipc	ra,0xffffe
    8000470e:	46e080e7          	jalr	1134(ra) # 80002b78 <iupdate>
    80004712:	b761                	j	8000469a <create+0xe8>
  ip->nlink = 0;
    80004714:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004718:	8552                	mv	a0,s4
    8000471a:	ffffe097          	auipc	ra,0xffffe
    8000471e:	45e080e7          	jalr	1118(ra) # 80002b78 <iupdate>
  iunlockput(ip);
    80004722:	8552                	mv	a0,s4
    80004724:	ffffe097          	auipc	ra,0xffffe
    80004728:	782080e7          	jalr	1922(ra) # 80002ea6 <iunlockput>
  iunlockput(dp);
    8000472c:	8526                	mv	a0,s1
    8000472e:	ffffe097          	auipc	ra,0xffffe
    80004732:	778080e7          	jalr	1912(ra) # 80002ea6 <iunlockput>
  return 0;
    80004736:	bdcd                	j	80004628 <create+0x76>
    return 0;
    80004738:	8aaa                	mv	s5,a0
    8000473a:	b5fd                	j	80004628 <create+0x76>

000000008000473c <sys_dup>:
{
    8000473c:	7179                	addi	sp,sp,-48
    8000473e:	f406                	sd	ra,40(sp)
    80004740:	f022                	sd	s0,32(sp)
    80004742:	ec26                	sd	s1,24(sp)
    80004744:	e84a                	sd	s2,16(sp)
    80004746:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004748:	fd840613          	addi	a2,s0,-40
    8000474c:	4581                	li	a1,0
    8000474e:	4501                	li	a0,0
    80004750:	00000097          	auipc	ra,0x0
    80004754:	dc0080e7          	jalr	-576(ra) # 80004510 <argfd>
    return -1;
    80004758:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000475a:	02054363          	bltz	a0,80004780 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000475e:	fd843903          	ld	s2,-40(s0)
    80004762:	854a                	mv	a0,s2
    80004764:	00000097          	auipc	ra,0x0
    80004768:	e0c080e7          	jalr	-500(ra) # 80004570 <fdalloc>
    8000476c:	84aa                	mv	s1,a0
    return -1;
    8000476e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004770:	00054863          	bltz	a0,80004780 <sys_dup+0x44>
  filedup(f);
    80004774:	854a                	mv	a0,s2
    80004776:	fffff097          	auipc	ra,0xfffff
    8000477a:	310080e7          	jalr	784(ra) # 80003a86 <filedup>
  return fd;
    8000477e:	87a6                	mv	a5,s1
}
    80004780:	853e                	mv	a0,a5
    80004782:	70a2                	ld	ra,40(sp)
    80004784:	7402                	ld	s0,32(sp)
    80004786:	64e2                	ld	s1,24(sp)
    80004788:	6942                	ld	s2,16(sp)
    8000478a:	6145                	addi	sp,sp,48
    8000478c:	8082                	ret

000000008000478e <sys_read>:
{
    8000478e:	7179                	addi	sp,sp,-48
    80004790:	f406                	sd	ra,40(sp)
    80004792:	f022                	sd	s0,32(sp)
    80004794:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004796:	fd840593          	addi	a1,s0,-40
    8000479a:	4505                	li	a0,1
    8000479c:	ffffe097          	auipc	ra,0xffffe
    800047a0:	84e080e7          	jalr	-1970(ra) # 80001fea <argaddr>
  argint(2, &n);
    800047a4:	fe440593          	addi	a1,s0,-28
    800047a8:	4509                	li	a0,2
    800047aa:	ffffe097          	auipc	ra,0xffffe
    800047ae:	820080e7          	jalr	-2016(ra) # 80001fca <argint>
  if(argfd(0, 0, &f) < 0)
    800047b2:	fe840613          	addi	a2,s0,-24
    800047b6:	4581                	li	a1,0
    800047b8:	4501                	li	a0,0
    800047ba:	00000097          	auipc	ra,0x0
    800047be:	d56080e7          	jalr	-682(ra) # 80004510 <argfd>
    800047c2:	87aa                	mv	a5,a0
    return -1;
    800047c4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800047c6:	0007cc63          	bltz	a5,800047de <sys_read+0x50>
  return fileread(f, p, n);
    800047ca:	fe442603          	lw	a2,-28(s0)
    800047ce:	fd843583          	ld	a1,-40(s0)
    800047d2:	fe843503          	ld	a0,-24(s0)
    800047d6:	fffff097          	auipc	ra,0xfffff
    800047da:	43c080e7          	jalr	1084(ra) # 80003c12 <fileread>
}
    800047de:	70a2                	ld	ra,40(sp)
    800047e0:	7402                	ld	s0,32(sp)
    800047e2:	6145                	addi	sp,sp,48
    800047e4:	8082                	ret

00000000800047e6 <sys_write>:
{
    800047e6:	7179                	addi	sp,sp,-48
    800047e8:	f406                	sd	ra,40(sp)
    800047ea:	f022                	sd	s0,32(sp)
    800047ec:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800047ee:	fd840593          	addi	a1,s0,-40
    800047f2:	4505                	li	a0,1
    800047f4:	ffffd097          	auipc	ra,0xffffd
    800047f8:	7f6080e7          	jalr	2038(ra) # 80001fea <argaddr>
  argint(2, &n);
    800047fc:	fe440593          	addi	a1,s0,-28
    80004800:	4509                	li	a0,2
    80004802:	ffffd097          	auipc	ra,0xffffd
    80004806:	7c8080e7          	jalr	1992(ra) # 80001fca <argint>
  if(argfd(0, 0, &f) < 0)
    8000480a:	fe840613          	addi	a2,s0,-24
    8000480e:	4581                	li	a1,0
    80004810:	4501                	li	a0,0
    80004812:	00000097          	auipc	ra,0x0
    80004816:	cfe080e7          	jalr	-770(ra) # 80004510 <argfd>
    8000481a:	87aa                	mv	a5,a0
    return -1;
    8000481c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000481e:	0007cc63          	bltz	a5,80004836 <sys_write+0x50>
  return filewrite(f, p, n);
    80004822:	fe442603          	lw	a2,-28(s0)
    80004826:	fd843583          	ld	a1,-40(s0)
    8000482a:	fe843503          	ld	a0,-24(s0)
    8000482e:	fffff097          	auipc	ra,0xfffff
    80004832:	4a6080e7          	jalr	1190(ra) # 80003cd4 <filewrite>
}
    80004836:	70a2                	ld	ra,40(sp)
    80004838:	7402                	ld	s0,32(sp)
    8000483a:	6145                	addi	sp,sp,48
    8000483c:	8082                	ret

000000008000483e <sys_close>:
{
    8000483e:	1101                	addi	sp,sp,-32
    80004840:	ec06                	sd	ra,24(sp)
    80004842:	e822                	sd	s0,16(sp)
    80004844:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004846:	fe040613          	addi	a2,s0,-32
    8000484a:	fec40593          	addi	a1,s0,-20
    8000484e:	4501                	li	a0,0
    80004850:	00000097          	auipc	ra,0x0
    80004854:	cc0080e7          	jalr	-832(ra) # 80004510 <argfd>
    return -1;
    80004858:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000485a:	02054463          	bltz	a0,80004882 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000485e:	ffffc097          	auipc	ra,0xffffc
    80004862:	5f6080e7          	jalr	1526(ra) # 80000e54 <myproc>
    80004866:	fec42783          	lw	a5,-20(s0)
    8000486a:	07e9                	addi	a5,a5,26
    8000486c:	078e                	slli	a5,a5,0x3
    8000486e:	953e                	add	a0,a0,a5
    80004870:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004874:	fe043503          	ld	a0,-32(s0)
    80004878:	fffff097          	auipc	ra,0xfffff
    8000487c:	260080e7          	jalr	608(ra) # 80003ad8 <fileclose>
  return 0;
    80004880:	4781                	li	a5,0
}
    80004882:	853e                	mv	a0,a5
    80004884:	60e2                	ld	ra,24(sp)
    80004886:	6442                	ld	s0,16(sp)
    80004888:	6105                	addi	sp,sp,32
    8000488a:	8082                	ret

000000008000488c <sys_fstat>:
{
    8000488c:	1101                	addi	sp,sp,-32
    8000488e:	ec06                	sd	ra,24(sp)
    80004890:	e822                	sd	s0,16(sp)
    80004892:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004894:	fe040593          	addi	a1,s0,-32
    80004898:	4505                	li	a0,1
    8000489a:	ffffd097          	auipc	ra,0xffffd
    8000489e:	750080e7          	jalr	1872(ra) # 80001fea <argaddr>
  if(argfd(0, 0, &f) < 0)
    800048a2:	fe840613          	addi	a2,s0,-24
    800048a6:	4581                	li	a1,0
    800048a8:	4501                	li	a0,0
    800048aa:	00000097          	auipc	ra,0x0
    800048ae:	c66080e7          	jalr	-922(ra) # 80004510 <argfd>
    800048b2:	87aa                	mv	a5,a0
    return -1;
    800048b4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800048b6:	0007ca63          	bltz	a5,800048ca <sys_fstat+0x3e>
  return filestat(f, st);
    800048ba:	fe043583          	ld	a1,-32(s0)
    800048be:	fe843503          	ld	a0,-24(s0)
    800048c2:	fffff097          	auipc	ra,0xfffff
    800048c6:	2de080e7          	jalr	734(ra) # 80003ba0 <filestat>
}
    800048ca:	60e2                	ld	ra,24(sp)
    800048cc:	6442                	ld	s0,16(sp)
    800048ce:	6105                	addi	sp,sp,32
    800048d0:	8082                	ret

00000000800048d2 <sys_link>:
{
    800048d2:	7169                	addi	sp,sp,-304
    800048d4:	f606                	sd	ra,296(sp)
    800048d6:	f222                	sd	s0,288(sp)
    800048d8:	ee26                	sd	s1,280(sp)
    800048da:	ea4a                	sd	s2,272(sp)
    800048dc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048de:	08000613          	li	a2,128
    800048e2:	ed040593          	addi	a1,s0,-304
    800048e6:	4501                	li	a0,0
    800048e8:	ffffd097          	auipc	ra,0xffffd
    800048ec:	722080e7          	jalr	1826(ra) # 8000200a <argstr>
    return -1;
    800048f0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048f2:	10054e63          	bltz	a0,80004a0e <sys_link+0x13c>
    800048f6:	08000613          	li	a2,128
    800048fa:	f5040593          	addi	a1,s0,-176
    800048fe:	4505                	li	a0,1
    80004900:	ffffd097          	auipc	ra,0xffffd
    80004904:	70a080e7          	jalr	1802(ra) # 8000200a <argstr>
    return -1;
    80004908:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000490a:	10054263          	bltz	a0,80004a0e <sys_link+0x13c>
  begin_op();
    8000490e:	fffff097          	auipc	ra,0xfffff
    80004912:	d02080e7          	jalr	-766(ra) # 80003610 <begin_op>
  if((ip = namei(old)) == 0){
    80004916:	ed040513          	addi	a0,s0,-304
    8000491a:	fffff097          	auipc	ra,0xfffff
    8000491e:	ad6080e7          	jalr	-1322(ra) # 800033f0 <namei>
    80004922:	84aa                	mv	s1,a0
    80004924:	c551                	beqz	a0,800049b0 <sys_link+0xde>
  ilock(ip);
    80004926:	ffffe097          	auipc	ra,0xffffe
    8000492a:	31e080e7          	jalr	798(ra) # 80002c44 <ilock>
  if(ip->type == T_DIR){
    8000492e:	04449703          	lh	a4,68(s1)
    80004932:	4785                	li	a5,1
    80004934:	08f70463          	beq	a4,a5,800049bc <sys_link+0xea>
  ip->nlink++;
    80004938:	04a4d783          	lhu	a5,74(s1)
    8000493c:	2785                	addiw	a5,a5,1
    8000493e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004942:	8526                	mv	a0,s1
    80004944:	ffffe097          	auipc	ra,0xffffe
    80004948:	234080e7          	jalr	564(ra) # 80002b78 <iupdate>
  iunlock(ip);
    8000494c:	8526                	mv	a0,s1
    8000494e:	ffffe097          	auipc	ra,0xffffe
    80004952:	3b8080e7          	jalr	952(ra) # 80002d06 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004956:	fd040593          	addi	a1,s0,-48
    8000495a:	f5040513          	addi	a0,s0,-176
    8000495e:	fffff097          	auipc	ra,0xfffff
    80004962:	ab0080e7          	jalr	-1360(ra) # 8000340e <nameiparent>
    80004966:	892a                	mv	s2,a0
    80004968:	c935                	beqz	a0,800049dc <sys_link+0x10a>
  ilock(dp);
    8000496a:	ffffe097          	auipc	ra,0xffffe
    8000496e:	2da080e7          	jalr	730(ra) # 80002c44 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004972:	00092703          	lw	a4,0(s2)
    80004976:	409c                	lw	a5,0(s1)
    80004978:	04f71d63          	bne	a4,a5,800049d2 <sys_link+0x100>
    8000497c:	40d0                	lw	a2,4(s1)
    8000497e:	fd040593          	addi	a1,s0,-48
    80004982:	854a                	mv	a0,s2
    80004984:	fffff097          	auipc	ra,0xfffff
    80004988:	9ba080e7          	jalr	-1606(ra) # 8000333e <dirlink>
    8000498c:	04054363          	bltz	a0,800049d2 <sys_link+0x100>
  iunlockput(dp);
    80004990:	854a                	mv	a0,s2
    80004992:	ffffe097          	auipc	ra,0xffffe
    80004996:	514080e7          	jalr	1300(ra) # 80002ea6 <iunlockput>
  iput(ip);
    8000499a:	8526                	mv	a0,s1
    8000499c:	ffffe097          	auipc	ra,0xffffe
    800049a0:	462080e7          	jalr	1122(ra) # 80002dfe <iput>
  end_op();
    800049a4:	fffff097          	auipc	ra,0xfffff
    800049a8:	cea080e7          	jalr	-790(ra) # 8000368e <end_op>
  return 0;
    800049ac:	4781                	li	a5,0
    800049ae:	a085                	j	80004a0e <sys_link+0x13c>
    end_op();
    800049b0:	fffff097          	auipc	ra,0xfffff
    800049b4:	cde080e7          	jalr	-802(ra) # 8000368e <end_op>
    return -1;
    800049b8:	57fd                	li	a5,-1
    800049ba:	a891                	j	80004a0e <sys_link+0x13c>
    iunlockput(ip);
    800049bc:	8526                	mv	a0,s1
    800049be:	ffffe097          	auipc	ra,0xffffe
    800049c2:	4e8080e7          	jalr	1256(ra) # 80002ea6 <iunlockput>
    end_op();
    800049c6:	fffff097          	auipc	ra,0xfffff
    800049ca:	cc8080e7          	jalr	-824(ra) # 8000368e <end_op>
    return -1;
    800049ce:	57fd                	li	a5,-1
    800049d0:	a83d                	j	80004a0e <sys_link+0x13c>
    iunlockput(dp);
    800049d2:	854a                	mv	a0,s2
    800049d4:	ffffe097          	auipc	ra,0xffffe
    800049d8:	4d2080e7          	jalr	1234(ra) # 80002ea6 <iunlockput>
  ilock(ip);
    800049dc:	8526                	mv	a0,s1
    800049de:	ffffe097          	auipc	ra,0xffffe
    800049e2:	266080e7          	jalr	614(ra) # 80002c44 <ilock>
  ip->nlink--;
    800049e6:	04a4d783          	lhu	a5,74(s1)
    800049ea:	37fd                	addiw	a5,a5,-1
    800049ec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800049f0:	8526                	mv	a0,s1
    800049f2:	ffffe097          	auipc	ra,0xffffe
    800049f6:	186080e7          	jalr	390(ra) # 80002b78 <iupdate>
  iunlockput(ip);
    800049fa:	8526                	mv	a0,s1
    800049fc:	ffffe097          	auipc	ra,0xffffe
    80004a00:	4aa080e7          	jalr	1194(ra) # 80002ea6 <iunlockput>
  end_op();
    80004a04:	fffff097          	auipc	ra,0xfffff
    80004a08:	c8a080e7          	jalr	-886(ra) # 8000368e <end_op>
  return -1;
    80004a0c:	57fd                	li	a5,-1
}
    80004a0e:	853e                	mv	a0,a5
    80004a10:	70b2                	ld	ra,296(sp)
    80004a12:	7412                	ld	s0,288(sp)
    80004a14:	64f2                	ld	s1,280(sp)
    80004a16:	6952                	ld	s2,272(sp)
    80004a18:	6155                	addi	sp,sp,304
    80004a1a:	8082                	ret

0000000080004a1c <sys_unlink>:
{
    80004a1c:	7151                	addi	sp,sp,-240
    80004a1e:	f586                	sd	ra,232(sp)
    80004a20:	f1a2                	sd	s0,224(sp)
    80004a22:	eda6                	sd	s1,216(sp)
    80004a24:	e9ca                	sd	s2,208(sp)
    80004a26:	e5ce                	sd	s3,200(sp)
    80004a28:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004a2a:	08000613          	li	a2,128
    80004a2e:	f3040593          	addi	a1,s0,-208
    80004a32:	4501                	li	a0,0
    80004a34:	ffffd097          	auipc	ra,0xffffd
    80004a38:	5d6080e7          	jalr	1494(ra) # 8000200a <argstr>
    80004a3c:	18054163          	bltz	a0,80004bbe <sys_unlink+0x1a2>
  begin_op();
    80004a40:	fffff097          	auipc	ra,0xfffff
    80004a44:	bd0080e7          	jalr	-1072(ra) # 80003610 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004a48:	fb040593          	addi	a1,s0,-80
    80004a4c:	f3040513          	addi	a0,s0,-208
    80004a50:	fffff097          	auipc	ra,0xfffff
    80004a54:	9be080e7          	jalr	-1602(ra) # 8000340e <nameiparent>
    80004a58:	84aa                	mv	s1,a0
    80004a5a:	c979                	beqz	a0,80004b30 <sys_unlink+0x114>
  ilock(dp);
    80004a5c:	ffffe097          	auipc	ra,0xffffe
    80004a60:	1e8080e7          	jalr	488(ra) # 80002c44 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004a64:	00004597          	auipc	a1,0x4
    80004a68:	c2458593          	addi	a1,a1,-988 # 80008688 <syscalls+0x2b8>
    80004a6c:	fb040513          	addi	a0,s0,-80
    80004a70:	ffffe097          	auipc	ra,0xffffe
    80004a74:	69e080e7          	jalr	1694(ra) # 8000310e <namecmp>
    80004a78:	14050a63          	beqz	a0,80004bcc <sys_unlink+0x1b0>
    80004a7c:	00004597          	auipc	a1,0x4
    80004a80:	c1458593          	addi	a1,a1,-1004 # 80008690 <syscalls+0x2c0>
    80004a84:	fb040513          	addi	a0,s0,-80
    80004a88:	ffffe097          	auipc	ra,0xffffe
    80004a8c:	686080e7          	jalr	1670(ra) # 8000310e <namecmp>
    80004a90:	12050e63          	beqz	a0,80004bcc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004a94:	f2c40613          	addi	a2,s0,-212
    80004a98:	fb040593          	addi	a1,s0,-80
    80004a9c:	8526                	mv	a0,s1
    80004a9e:	ffffe097          	auipc	ra,0xffffe
    80004aa2:	68a080e7          	jalr	1674(ra) # 80003128 <dirlookup>
    80004aa6:	892a                	mv	s2,a0
    80004aa8:	12050263          	beqz	a0,80004bcc <sys_unlink+0x1b0>
  ilock(ip);
    80004aac:	ffffe097          	auipc	ra,0xffffe
    80004ab0:	198080e7          	jalr	408(ra) # 80002c44 <ilock>
  if(ip->nlink < 1)
    80004ab4:	04a91783          	lh	a5,74(s2)
    80004ab8:	08f05263          	blez	a5,80004b3c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004abc:	04491703          	lh	a4,68(s2)
    80004ac0:	4785                	li	a5,1
    80004ac2:	08f70563          	beq	a4,a5,80004b4c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004ac6:	4641                	li	a2,16
    80004ac8:	4581                	li	a1,0
    80004aca:	fc040513          	addi	a0,s0,-64
    80004ace:	ffffb097          	auipc	ra,0xffffb
    80004ad2:	6ac080e7          	jalr	1708(ra) # 8000017a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ad6:	4741                	li	a4,16
    80004ad8:	f2c42683          	lw	a3,-212(s0)
    80004adc:	fc040613          	addi	a2,s0,-64
    80004ae0:	4581                	li	a1,0
    80004ae2:	8526                	mv	a0,s1
    80004ae4:	ffffe097          	auipc	ra,0xffffe
    80004ae8:	50c080e7          	jalr	1292(ra) # 80002ff0 <writei>
    80004aec:	47c1                	li	a5,16
    80004aee:	0af51563          	bne	a0,a5,80004b98 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004af2:	04491703          	lh	a4,68(s2)
    80004af6:	4785                	li	a5,1
    80004af8:	0af70863          	beq	a4,a5,80004ba8 <sys_unlink+0x18c>
  iunlockput(dp);
    80004afc:	8526                	mv	a0,s1
    80004afe:	ffffe097          	auipc	ra,0xffffe
    80004b02:	3a8080e7          	jalr	936(ra) # 80002ea6 <iunlockput>
  ip->nlink--;
    80004b06:	04a95783          	lhu	a5,74(s2)
    80004b0a:	37fd                	addiw	a5,a5,-1
    80004b0c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004b10:	854a                	mv	a0,s2
    80004b12:	ffffe097          	auipc	ra,0xffffe
    80004b16:	066080e7          	jalr	102(ra) # 80002b78 <iupdate>
  iunlockput(ip);
    80004b1a:	854a                	mv	a0,s2
    80004b1c:	ffffe097          	auipc	ra,0xffffe
    80004b20:	38a080e7          	jalr	906(ra) # 80002ea6 <iunlockput>
  end_op();
    80004b24:	fffff097          	auipc	ra,0xfffff
    80004b28:	b6a080e7          	jalr	-1174(ra) # 8000368e <end_op>
  return 0;
    80004b2c:	4501                	li	a0,0
    80004b2e:	a84d                	j	80004be0 <sys_unlink+0x1c4>
    end_op();
    80004b30:	fffff097          	auipc	ra,0xfffff
    80004b34:	b5e080e7          	jalr	-1186(ra) # 8000368e <end_op>
    return -1;
    80004b38:	557d                	li	a0,-1
    80004b3a:	a05d                	j	80004be0 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004b3c:	00004517          	auipc	a0,0x4
    80004b40:	b5c50513          	addi	a0,a0,-1188 # 80008698 <syscalls+0x2c8>
    80004b44:	00001097          	auipc	ra,0x1
    80004b48:	1b8080e7          	jalr	440(ra) # 80005cfc <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b4c:	04c92703          	lw	a4,76(s2)
    80004b50:	02000793          	li	a5,32
    80004b54:	f6e7f9e3          	bgeu	a5,a4,80004ac6 <sys_unlink+0xaa>
    80004b58:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b5c:	4741                	li	a4,16
    80004b5e:	86ce                	mv	a3,s3
    80004b60:	f1840613          	addi	a2,s0,-232
    80004b64:	4581                	li	a1,0
    80004b66:	854a                	mv	a0,s2
    80004b68:	ffffe097          	auipc	ra,0xffffe
    80004b6c:	390080e7          	jalr	912(ra) # 80002ef8 <readi>
    80004b70:	47c1                	li	a5,16
    80004b72:	00f51b63          	bne	a0,a5,80004b88 <sys_unlink+0x16c>
    if(de.inum != 0)
    80004b76:	f1845783          	lhu	a5,-232(s0)
    80004b7a:	e7a1                	bnez	a5,80004bc2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b7c:	29c1                	addiw	s3,s3,16
    80004b7e:	04c92783          	lw	a5,76(s2)
    80004b82:	fcf9ede3          	bltu	s3,a5,80004b5c <sys_unlink+0x140>
    80004b86:	b781                	j	80004ac6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004b88:	00004517          	auipc	a0,0x4
    80004b8c:	b2850513          	addi	a0,a0,-1240 # 800086b0 <syscalls+0x2e0>
    80004b90:	00001097          	auipc	ra,0x1
    80004b94:	16c080e7          	jalr	364(ra) # 80005cfc <panic>
    panic("unlink: writei");
    80004b98:	00004517          	auipc	a0,0x4
    80004b9c:	b3050513          	addi	a0,a0,-1232 # 800086c8 <syscalls+0x2f8>
    80004ba0:	00001097          	auipc	ra,0x1
    80004ba4:	15c080e7          	jalr	348(ra) # 80005cfc <panic>
    dp->nlink--;
    80004ba8:	04a4d783          	lhu	a5,74(s1)
    80004bac:	37fd                	addiw	a5,a5,-1
    80004bae:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004bb2:	8526                	mv	a0,s1
    80004bb4:	ffffe097          	auipc	ra,0xffffe
    80004bb8:	fc4080e7          	jalr	-60(ra) # 80002b78 <iupdate>
    80004bbc:	b781                	j	80004afc <sys_unlink+0xe0>
    return -1;
    80004bbe:	557d                	li	a0,-1
    80004bc0:	a005                	j	80004be0 <sys_unlink+0x1c4>
    iunlockput(ip);
    80004bc2:	854a                	mv	a0,s2
    80004bc4:	ffffe097          	auipc	ra,0xffffe
    80004bc8:	2e2080e7          	jalr	738(ra) # 80002ea6 <iunlockput>
  iunlockput(dp);
    80004bcc:	8526                	mv	a0,s1
    80004bce:	ffffe097          	auipc	ra,0xffffe
    80004bd2:	2d8080e7          	jalr	728(ra) # 80002ea6 <iunlockput>
  end_op();
    80004bd6:	fffff097          	auipc	ra,0xfffff
    80004bda:	ab8080e7          	jalr	-1352(ra) # 8000368e <end_op>
  return -1;
    80004bde:	557d                	li	a0,-1
}
    80004be0:	70ae                	ld	ra,232(sp)
    80004be2:	740e                	ld	s0,224(sp)
    80004be4:	64ee                	ld	s1,216(sp)
    80004be6:	694e                	ld	s2,208(sp)
    80004be8:	69ae                	ld	s3,200(sp)
    80004bea:	616d                	addi	sp,sp,240
    80004bec:	8082                	ret

0000000080004bee <sys_open>:

uint64
sys_open(void)
{
    80004bee:	7131                	addi	sp,sp,-192
    80004bf0:	fd06                	sd	ra,184(sp)
    80004bf2:	f922                	sd	s0,176(sp)
    80004bf4:	f526                	sd	s1,168(sp)
    80004bf6:	f14a                	sd	s2,160(sp)
    80004bf8:	ed4e                	sd	s3,152(sp)
    80004bfa:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004bfc:	f4c40593          	addi	a1,s0,-180
    80004c00:	4505                	li	a0,1
    80004c02:	ffffd097          	auipc	ra,0xffffd
    80004c06:	3c8080e7          	jalr	968(ra) # 80001fca <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004c0a:	08000613          	li	a2,128
    80004c0e:	f5040593          	addi	a1,s0,-176
    80004c12:	4501                	li	a0,0
    80004c14:	ffffd097          	auipc	ra,0xffffd
    80004c18:	3f6080e7          	jalr	1014(ra) # 8000200a <argstr>
    80004c1c:	87aa                	mv	a5,a0
    return -1;
    80004c1e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004c20:	0a07c963          	bltz	a5,80004cd2 <sys_open+0xe4>

  begin_op();
    80004c24:	fffff097          	auipc	ra,0xfffff
    80004c28:	9ec080e7          	jalr	-1556(ra) # 80003610 <begin_op>

  if(omode & O_CREATE){
    80004c2c:	f4c42783          	lw	a5,-180(s0)
    80004c30:	2007f793          	andi	a5,a5,512
    80004c34:	cfc5                	beqz	a5,80004cec <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004c36:	4681                	li	a3,0
    80004c38:	4601                	li	a2,0
    80004c3a:	4589                	li	a1,2
    80004c3c:	f5040513          	addi	a0,s0,-176
    80004c40:	00000097          	auipc	ra,0x0
    80004c44:	972080e7          	jalr	-1678(ra) # 800045b2 <create>
    80004c48:	84aa                	mv	s1,a0
    if(ip == 0){
    80004c4a:	c959                	beqz	a0,80004ce0 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004c4c:	04449703          	lh	a4,68(s1)
    80004c50:	478d                	li	a5,3
    80004c52:	00f71763          	bne	a4,a5,80004c60 <sys_open+0x72>
    80004c56:	0464d703          	lhu	a4,70(s1)
    80004c5a:	47a5                	li	a5,9
    80004c5c:	0ce7ed63          	bltu	a5,a4,80004d36 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004c60:	fffff097          	auipc	ra,0xfffff
    80004c64:	dbc080e7          	jalr	-580(ra) # 80003a1c <filealloc>
    80004c68:	89aa                	mv	s3,a0
    80004c6a:	10050363          	beqz	a0,80004d70 <sys_open+0x182>
    80004c6e:	00000097          	auipc	ra,0x0
    80004c72:	902080e7          	jalr	-1790(ra) # 80004570 <fdalloc>
    80004c76:	892a                	mv	s2,a0
    80004c78:	0e054763          	bltz	a0,80004d66 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004c7c:	04449703          	lh	a4,68(s1)
    80004c80:	478d                	li	a5,3
    80004c82:	0cf70563          	beq	a4,a5,80004d4c <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004c86:	4789                	li	a5,2
    80004c88:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004c8c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004c90:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004c94:	f4c42783          	lw	a5,-180(s0)
    80004c98:	0017c713          	xori	a4,a5,1
    80004c9c:	8b05                	andi	a4,a4,1
    80004c9e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004ca2:	0037f713          	andi	a4,a5,3
    80004ca6:	00e03733          	snez	a4,a4
    80004caa:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004cae:	4007f793          	andi	a5,a5,1024
    80004cb2:	c791                	beqz	a5,80004cbe <sys_open+0xd0>
    80004cb4:	04449703          	lh	a4,68(s1)
    80004cb8:	4789                	li	a5,2
    80004cba:	0af70063          	beq	a4,a5,80004d5a <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004cbe:	8526                	mv	a0,s1
    80004cc0:	ffffe097          	auipc	ra,0xffffe
    80004cc4:	046080e7          	jalr	70(ra) # 80002d06 <iunlock>
  end_op();
    80004cc8:	fffff097          	auipc	ra,0xfffff
    80004ccc:	9c6080e7          	jalr	-1594(ra) # 8000368e <end_op>

  return fd;
    80004cd0:	854a                	mv	a0,s2
}
    80004cd2:	70ea                	ld	ra,184(sp)
    80004cd4:	744a                	ld	s0,176(sp)
    80004cd6:	74aa                	ld	s1,168(sp)
    80004cd8:	790a                	ld	s2,160(sp)
    80004cda:	69ea                	ld	s3,152(sp)
    80004cdc:	6129                	addi	sp,sp,192
    80004cde:	8082                	ret
      end_op();
    80004ce0:	fffff097          	auipc	ra,0xfffff
    80004ce4:	9ae080e7          	jalr	-1618(ra) # 8000368e <end_op>
      return -1;
    80004ce8:	557d                	li	a0,-1
    80004cea:	b7e5                	j	80004cd2 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004cec:	f5040513          	addi	a0,s0,-176
    80004cf0:	ffffe097          	auipc	ra,0xffffe
    80004cf4:	700080e7          	jalr	1792(ra) # 800033f0 <namei>
    80004cf8:	84aa                	mv	s1,a0
    80004cfa:	c905                	beqz	a0,80004d2a <sys_open+0x13c>
    ilock(ip);
    80004cfc:	ffffe097          	auipc	ra,0xffffe
    80004d00:	f48080e7          	jalr	-184(ra) # 80002c44 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004d04:	04449703          	lh	a4,68(s1)
    80004d08:	4785                	li	a5,1
    80004d0a:	f4f711e3          	bne	a4,a5,80004c4c <sys_open+0x5e>
    80004d0e:	f4c42783          	lw	a5,-180(s0)
    80004d12:	d7b9                	beqz	a5,80004c60 <sys_open+0x72>
      iunlockput(ip);
    80004d14:	8526                	mv	a0,s1
    80004d16:	ffffe097          	auipc	ra,0xffffe
    80004d1a:	190080e7          	jalr	400(ra) # 80002ea6 <iunlockput>
      end_op();
    80004d1e:	fffff097          	auipc	ra,0xfffff
    80004d22:	970080e7          	jalr	-1680(ra) # 8000368e <end_op>
      return -1;
    80004d26:	557d                	li	a0,-1
    80004d28:	b76d                	j	80004cd2 <sys_open+0xe4>
      end_op();
    80004d2a:	fffff097          	auipc	ra,0xfffff
    80004d2e:	964080e7          	jalr	-1692(ra) # 8000368e <end_op>
      return -1;
    80004d32:	557d                	li	a0,-1
    80004d34:	bf79                	j	80004cd2 <sys_open+0xe4>
    iunlockput(ip);
    80004d36:	8526                	mv	a0,s1
    80004d38:	ffffe097          	auipc	ra,0xffffe
    80004d3c:	16e080e7          	jalr	366(ra) # 80002ea6 <iunlockput>
    end_op();
    80004d40:	fffff097          	auipc	ra,0xfffff
    80004d44:	94e080e7          	jalr	-1714(ra) # 8000368e <end_op>
    return -1;
    80004d48:	557d                	li	a0,-1
    80004d4a:	b761                	j	80004cd2 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004d4c:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004d50:	04649783          	lh	a5,70(s1)
    80004d54:	02f99223          	sh	a5,36(s3)
    80004d58:	bf25                	j	80004c90 <sys_open+0xa2>
    itrunc(ip);
    80004d5a:	8526                	mv	a0,s1
    80004d5c:	ffffe097          	auipc	ra,0xffffe
    80004d60:	ff6080e7          	jalr	-10(ra) # 80002d52 <itrunc>
    80004d64:	bfa9                	j	80004cbe <sys_open+0xd0>
      fileclose(f);
    80004d66:	854e                	mv	a0,s3
    80004d68:	fffff097          	auipc	ra,0xfffff
    80004d6c:	d70080e7          	jalr	-656(ra) # 80003ad8 <fileclose>
    iunlockput(ip);
    80004d70:	8526                	mv	a0,s1
    80004d72:	ffffe097          	auipc	ra,0xffffe
    80004d76:	134080e7          	jalr	308(ra) # 80002ea6 <iunlockput>
    end_op();
    80004d7a:	fffff097          	auipc	ra,0xfffff
    80004d7e:	914080e7          	jalr	-1772(ra) # 8000368e <end_op>
    return -1;
    80004d82:	557d                	li	a0,-1
    80004d84:	b7b9                	j	80004cd2 <sys_open+0xe4>

0000000080004d86 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004d86:	7175                	addi	sp,sp,-144
    80004d88:	e506                	sd	ra,136(sp)
    80004d8a:	e122                	sd	s0,128(sp)
    80004d8c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004d8e:	fffff097          	auipc	ra,0xfffff
    80004d92:	882080e7          	jalr	-1918(ra) # 80003610 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004d96:	08000613          	li	a2,128
    80004d9a:	f7040593          	addi	a1,s0,-144
    80004d9e:	4501                	li	a0,0
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	26a080e7          	jalr	618(ra) # 8000200a <argstr>
    80004da8:	02054963          	bltz	a0,80004dda <sys_mkdir+0x54>
    80004dac:	4681                	li	a3,0
    80004dae:	4601                	li	a2,0
    80004db0:	4585                	li	a1,1
    80004db2:	f7040513          	addi	a0,s0,-144
    80004db6:	fffff097          	auipc	ra,0xfffff
    80004dba:	7fc080e7          	jalr	2044(ra) # 800045b2 <create>
    80004dbe:	cd11                	beqz	a0,80004dda <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004dc0:	ffffe097          	auipc	ra,0xffffe
    80004dc4:	0e6080e7          	jalr	230(ra) # 80002ea6 <iunlockput>
  end_op();
    80004dc8:	fffff097          	auipc	ra,0xfffff
    80004dcc:	8c6080e7          	jalr	-1850(ra) # 8000368e <end_op>
  return 0;
    80004dd0:	4501                	li	a0,0
}
    80004dd2:	60aa                	ld	ra,136(sp)
    80004dd4:	640a                	ld	s0,128(sp)
    80004dd6:	6149                	addi	sp,sp,144
    80004dd8:	8082                	ret
    end_op();
    80004dda:	fffff097          	auipc	ra,0xfffff
    80004dde:	8b4080e7          	jalr	-1868(ra) # 8000368e <end_op>
    return -1;
    80004de2:	557d                	li	a0,-1
    80004de4:	b7fd                	j	80004dd2 <sys_mkdir+0x4c>

0000000080004de6 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004de6:	7135                	addi	sp,sp,-160
    80004de8:	ed06                	sd	ra,152(sp)
    80004dea:	e922                	sd	s0,144(sp)
    80004dec:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004dee:	fffff097          	auipc	ra,0xfffff
    80004df2:	822080e7          	jalr	-2014(ra) # 80003610 <begin_op>
  argint(1, &major);
    80004df6:	f6c40593          	addi	a1,s0,-148
    80004dfa:	4505                	li	a0,1
    80004dfc:	ffffd097          	auipc	ra,0xffffd
    80004e00:	1ce080e7          	jalr	462(ra) # 80001fca <argint>
  argint(2, &minor);
    80004e04:	f6840593          	addi	a1,s0,-152
    80004e08:	4509                	li	a0,2
    80004e0a:	ffffd097          	auipc	ra,0xffffd
    80004e0e:	1c0080e7          	jalr	448(ra) # 80001fca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004e12:	08000613          	li	a2,128
    80004e16:	f7040593          	addi	a1,s0,-144
    80004e1a:	4501                	li	a0,0
    80004e1c:	ffffd097          	auipc	ra,0xffffd
    80004e20:	1ee080e7          	jalr	494(ra) # 8000200a <argstr>
    80004e24:	02054b63          	bltz	a0,80004e5a <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004e28:	f6841683          	lh	a3,-152(s0)
    80004e2c:	f6c41603          	lh	a2,-148(s0)
    80004e30:	458d                	li	a1,3
    80004e32:	f7040513          	addi	a0,s0,-144
    80004e36:	fffff097          	auipc	ra,0xfffff
    80004e3a:	77c080e7          	jalr	1916(ra) # 800045b2 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004e3e:	cd11                	beqz	a0,80004e5a <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004e40:	ffffe097          	auipc	ra,0xffffe
    80004e44:	066080e7          	jalr	102(ra) # 80002ea6 <iunlockput>
  end_op();
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	846080e7          	jalr	-1978(ra) # 8000368e <end_op>
  return 0;
    80004e50:	4501                	li	a0,0
}
    80004e52:	60ea                	ld	ra,152(sp)
    80004e54:	644a                	ld	s0,144(sp)
    80004e56:	610d                	addi	sp,sp,160
    80004e58:	8082                	ret
    end_op();
    80004e5a:	fffff097          	auipc	ra,0xfffff
    80004e5e:	834080e7          	jalr	-1996(ra) # 8000368e <end_op>
    return -1;
    80004e62:	557d                	li	a0,-1
    80004e64:	b7fd                	j	80004e52 <sys_mknod+0x6c>

0000000080004e66 <sys_chdir>:

uint64
sys_chdir(void)
{
    80004e66:	7135                	addi	sp,sp,-160
    80004e68:	ed06                	sd	ra,152(sp)
    80004e6a:	e922                	sd	s0,144(sp)
    80004e6c:	e526                	sd	s1,136(sp)
    80004e6e:	e14a                	sd	s2,128(sp)
    80004e70:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004e72:	ffffc097          	auipc	ra,0xffffc
    80004e76:	fe2080e7          	jalr	-30(ra) # 80000e54 <myproc>
    80004e7a:	892a                	mv	s2,a0
  
  begin_op();
    80004e7c:	ffffe097          	auipc	ra,0xffffe
    80004e80:	794080e7          	jalr	1940(ra) # 80003610 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004e84:	08000613          	li	a2,128
    80004e88:	f6040593          	addi	a1,s0,-160
    80004e8c:	4501                	li	a0,0
    80004e8e:	ffffd097          	auipc	ra,0xffffd
    80004e92:	17c080e7          	jalr	380(ra) # 8000200a <argstr>
    80004e96:	04054b63          	bltz	a0,80004eec <sys_chdir+0x86>
    80004e9a:	f6040513          	addi	a0,s0,-160
    80004e9e:	ffffe097          	auipc	ra,0xffffe
    80004ea2:	552080e7          	jalr	1362(ra) # 800033f0 <namei>
    80004ea6:	84aa                	mv	s1,a0
    80004ea8:	c131                	beqz	a0,80004eec <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004eaa:	ffffe097          	auipc	ra,0xffffe
    80004eae:	d9a080e7          	jalr	-614(ra) # 80002c44 <ilock>
  if(ip->type != T_DIR){
    80004eb2:	04449703          	lh	a4,68(s1)
    80004eb6:	4785                	li	a5,1
    80004eb8:	04f71063          	bne	a4,a5,80004ef8 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004ebc:	8526                	mv	a0,s1
    80004ebe:	ffffe097          	auipc	ra,0xffffe
    80004ec2:	e48080e7          	jalr	-440(ra) # 80002d06 <iunlock>
  iput(p->cwd);
    80004ec6:	15093503          	ld	a0,336(s2)
    80004eca:	ffffe097          	auipc	ra,0xffffe
    80004ece:	f34080e7          	jalr	-204(ra) # 80002dfe <iput>
  end_op();
    80004ed2:	ffffe097          	auipc	ra,0xffffe
    80004ed6:	7bc080e7          	jalr	1980(ra) # 8000368e <end_op>
  p->cwd = ip;
    80004eda:	14993823          	sd	s1,336(s2)
  return 0;
    80004ede:	4501                	li	a0,0
}
    80004ee0:	60ea                	ld	ra,152(sp)
    80004ee2:	644a                	ld	s0,144(sp)
    80004ee4:	64aa                	ld	s1,136(sp)
    80004ee6:	690a                	ld	s2,128(sp)
    80004ee8:	610d                	addi	sp,sp,160
    80004eea:	8082                	ret
    end_op();
    80004eec:	ffffe097          	auipc	ra,0xffffe
    80004ef0:	7a2080e7          	jalr	1954(ra) # 8000368e <end_op>
    return -1;
    80004ef4:	557d                	li	a0,-1
    80004ef6:	b7ed                	j	80004ee0 <sys_chdir+0x7a>
    iunlockput(ip);
    80004ef8:	8526                	mv	a0,s1
    80004efa:	ffffe097          	auipc	ra,0xffffe
    80004efe:	fac080e7          	jalr	-84(ra) # 80002ea6 <iunlockput>
    end_op();
    80004f02:	ffffe097          	auipc	ra,0xffffe
    80004f06:	78c080e7          	jalr	1932(ra) # 8000368e <end_op>
    return -1;
    80004f0a:	557d                	li	a0,-1
    80004f0c:	bfd1                	j	80004ee0 <sys_chdir+0x7a>

0000000080004f0e <sys_exec>:

uint64
sys_exec(void)
{
    80004f0e:	7145                	addi	sp,sp,-464
    80004f10:	e786                	sd	ra,456(sp)
    80004f12:	e3a2                	sd	s0,448(sp)
    80004f14:	ff26                	sd	s1,440(sp)
    80004f16:	fb4a                	sd	s2,432(sp)
    80004f18:	f74e                	sd	s3,424(sp)
    80004f1a:	f352                	sd	s4,416(sp)
    80004f1c:	ef56                	sd	s5,408(sp)
    80004f1e:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80004f20:	e3840593          	addi	a1,s0,-456
    80004f24:	4505                	li	a0,1
    80004f26:	ffffd097          	auipc	ra,0xffffd
    80004f2a:	0c4080e7          	jalr	196(ra) # 80001fea <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80004f2e:	08000613          	li	a2,128
    80004f32:	f4040593          	addi	a1,s0,-192
    80004f36:	4501                	li	a0,0
    80004f38:	ffffd097          	auipc	ra,0xffffd
    80004f3c:	0d2080e7          	jalr	210(ra) # 8000200a <argstr>
    80004f40:	87aa                	mv	a5,a0
    return -1;
    80004f42:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80004f44:	0c07c363          	bltz	a5,8000500a <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80004f48:	10000613          	li	a2,256
    80004f4c:	4581                	li	a1,0
    80004f4e:	e4040513          	addi	a0,s0,-448
    80004f52:	ffffb097          	auipc	ra,0xffffb
    80004f56:	228080e7          	jalr	552(ra) # 8000017a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004f5a:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80004f5e:	89a6                	mv	s3,s1
    80004f60:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80004f62:	02000a13          	li	s4,32
    80004f66:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004f6a:	00391513          	slli	a0,s2,0x3
    80004f6e:	e3040593          	addi	a1,s0,-464
    80004f72:	e3843783          	ld	a5,-456(s0)
    80004f76:	953e                	add	a0,a0,a5
    80004f78:	ffffd097          	auipc	ra,0xffffd
    80004f7c:	fb4080e7          	jalr	-76(ra) # 80001f2c <fetchaddr>
    80004f80:	02054a63          	bltz	a0,80004fb4 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80004f84:	e3043783          	ld	a5,-464(s0)
    80004f88:	c3b9                	beqz	a5,80004fce <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004f8a:	ffffb097          	auipc	ra,0xffffb
    80004f8e:	190080e7          	jalr	400(ra) # 8000011a <kalloc>
    80004f92:	85aa                	mv	a1,a0
    80004f94:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80004f98:	cd11                	beqz	a0,80004fb4 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004f9a:	6605                	lui	a2,0x1
    80004f9c:	e3043503          	ld	a0,-464(s0)
    80004fa0:	ffffd097          	auipc	ra,0xffffd
    80004fa4:	fde080e7          	jalr	-34(ra) # 80001f7e <fetchstr>
    80004fa8:	00054663          	bltz	a0,80004fb4 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80004fac:	0905                	addi	s2,s2,1
    80004fae:	09a1                	addi	s3,s3,8
    80004fb0:	fb491be3          	bne	s2,s4,80004f66 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fb4:	f4040913          	addi	s2,s0,-192
    80004fb8:	6088                	ld	a0,0(s1)
    80004fba:	c539                	beqz	a0,80005008 <sys_exec+0xfa>
    kfree(argv[i]);
    80004fbc:	ffffb097          	auipc	ra,0xffffb
    80004fc0:	060080e7          	jalr	96(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fc4:	04a1                	addi	s1,s1,8
    80004fc6:	ff2499e3          	bne	s1,s2,80004fb8 <sys_exec+0xaa>
  return -1;
    80004fca:	557d                	li	a0,-1
    80004fcc:	a83d                	j	8000500a <sys_exec+0xfc>
      argv[i] = 0;
    80004fce:	0a8e                	slli	s5,s5,0x3
    80004fd0:	fc0a8793          	addi	a5,s5,-64
    80004fd4:	00878ab3          	add	s5,a5,s0
    80004fd8:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80004fdc:	e4040593          	addi	a1,s0,-448
    80004fe0:	f4040513          	addi	a0,s0,-192
    80004fe4:	fffff097          	auipc	ra,0xfffff
    80004fe8:	16e080e7          	jalr	366(ra) # 80004152 <exec>
    80004fec:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fee:	f4040993          	addi	s3,s0,-192
    80004ff2:	6088                	ld	a0,0(s1)
    80004ff4:	c901                	beqz	a0,80005004 <sys_exec+0xf6>
    kfree(argv[i]);
    80004ff6:	ffffb097          	auipc	ra,0xffffb
    80004ffa:	026080e7          	jalr	38(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ffe:	04a1                	addi	s1,s1,8
    80005000:	ff3499e3          	bne	s1,s3,80004ff2 <sys_exec+0xe4>
  return ret;
    80005004:	854a                	mv	a0,s2
    80005006:	a011                	j	8000500a <sys_exec+0xfc>
  return -1;
    80005008:	557d                	li	a0,-1
}
    8000500a:	60be                	ld	ra,456(sp)
    8000500c:	641e                	ld	s0,448(sp)
    8000500e:	74fa                	ld	s1,440(sp)
    80005010:	795a                	ld	s2,432(sp)
    80005012:	79ba                	ld	s3,424(sp)
    80005014:	7a1a                	ld	s4,416(sp)
    80005016:	6afa                	ld	s5,408(sp)
    80005018:	6179                	addi	sp,sp,464
    8000501a:	8082                	ret

000000008000501c <sys_pipe>:

uint64
sys_pipe(void)
{
    8000501c:	7139                	addi	sp,sp,-64
    8000501e:	fc06                	sd	ra,56(sp)
    80005020:	f822                	sd	s0,48(sp)
    80005022:	f426                	sd	s1,40(sp)
    80005024:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005026:	ffffc097          	auipc	ra,0xffffc
    8000502a:	e2e080e7          	jalr	-466(ra) # 80000e54 <myproc>
    8000502e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005030:	fd840593          	addi	a1,s0,-40
    80005034:	4501                	li	a0,0
    80005036:	ffffd097          	auipc	ra,0xffffd
    8000503a:	fb4080e7          	jalr	-76(ra) # 80001fea <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000503e:	fc840593          	addi	a1,s0,-56
    80005042:	fd040513          	addi	a0,s0,-48
    80005046:	fffff097          	auipc	ra,0xfffff
    8000504a:	dc2080e7          	jalr	-574(ra) # 80003e08 <pipealloc>
    return -1;
    8000504e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005050:	0c054463          	bltz	a0,80005118 <sys_pipe+0xfc>
  fd0 = -1;
    80005054:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005058:	fd043503          	ld	a0,-48(s0)
    8000505c:	fffff097          	auipc	ra,0xfffff
    80005060:	514080e7          	jalr	1300(ra) # 80004570 <fdalloc>
    80005064:	fca42223          	sw	a0,-60(s0)
    80005068:	08054b63          	bltz	a0,800050fe <sys_pipe+0xe2>
    8000506c:	fc843503          	ld	a0,-56(s0)
    80005070:	fffff097          	auipc	ra,0xfffff
    80005074:	500080e7          	jalr	1280(ra) # 80004570 <fdalloc>
    80005078:	fca42023          	sw	a0,-64(s0)
    8000507c:	06054863          	bltz	a0,800050ec <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005080:	4691                	li	a3,4
    80005082:	fc440613          	addi	a2,s0,-60
    80005086:	fd843583          	ld	a1,-40(s0)
    8000508a:	68a8                	ld	a0,80(s1)
    8000508c:	ffffc097          	auipc	ra,0xffffc
    80005090:	a88080e7          	jalr	-1400(ra) # 80000b14 <copyout>
    80005094:	02054063          	bltz	a0,800050b4 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005098:	4691                	li	a3,4
    8000509a:	fc040613          	addi	a2,s0,-64
    8000509e:	fd843583          	ld	a1,-40(s0)
    800050a2:	0591                	addi	a1,a1,4
    800050a4:	68a8                	ld	a0,80(s1)
    800050a6:	ffffc097          	auipc	ra,0xffffc
    800050aa:	a6e080e7          	jalr	-1426(ra) # 80000b14 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800050ae:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800050b0:	06055463          	bgez	a0,80005118 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800050b4:	fc442783          	lw	a5,-60(s0)
    800050b8:	07e9                	addi	a5,a5,26
    800050ba:	078e                	slli	a5,a5,0x3
    800050bc:	97a6                	add	a5,a5,s1
    800050be:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800050c2:	fc042783          	lw	a5,-64(s0)
    800050c6:	07e9                	addi	a5,a5,26
    800050c8:	078e                	slli	a5,a5,0x3
    800050ca:	94be                	add	s1,s1,a5
    800050cc:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800050d0:	fd043503          	ld	a0,-48(s0)
    800050d4:	fffff097          	auipc	ra,0xfffff
    800050d8:	a04080e7          	jalr	-1532(ra) # 80003ad8 <fileclose>
    fileclose(wf);
    800050dc:	fc843503          	ld	a0,-56(s0)
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	9f8080e7          	jalr	-1544(ra) # 80003ad8 <fileclose>
    return -1;
    800050e8:	57fd                	li	a5,-1
    800050ea:	a03d                	j	80005118 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800050ec:	fc442783          	lw	a5,-60(s0)
    800050f0:	0007c763          	bltz	a5,800050fe <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800050f4:	07e9                	addi	a5,a5,26
    800050f6:	078e                	slli	a5,a5,0x3
    800050f8:	97a6                	add	a5,a5,s1
    800050fa:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800050fe:	fd043503          	ld	a0,-48(s0)
    80005102:	fffff097          	auipc	ra,0xfffff
    80005106:	9d6080e7          	jalr	-1578(ra) # 80003ad8 <fileclose>
    fileclose(wf);
    8000510a:	fc843503          	ld	a0,-56(s0)
    8000510e:	fffff097          	auipc	ra,0xfffff
    80005112:	9ca080e7          	jalr	-1590(ra) # 80003ad8 <fileclose>
    return -1;
    80005116:	57fd                	li	a5,-1
}
    80005118:	853e                	mv	a0,a5
    8000511a:	70e2                	ld	ra,56(sp)
    8000511c:	7442                	ld	s0,48(sp)
    8000511e:	74a2                	ld	s1,40(sp)
    80005120:	6121                	addi	sp,sp,64
    80005122:	8082                	ret
	...

0000000080005130 <kernelvec>:
    80005130:	7111                	addi	sp,sp,-256
    80005132:	e006                	sd	ra,0(sp)
    80005134:	e40a                	sd	sp,8(sp)
    80005136:	e80e                	sd	gp,16(sp)
    80005138:	ec12                	sd	tp,24(sp)
    8000513a:	f016                	sd	t0,32(sp)
    8000513c:	f41a                	sd	t1,40(sp)
    8000513e:	f81e                	sd	t2,48(sp)
    80005140:	fc22                	sd	s0,56(sp)
    80005142:	e0a6                	sd	s1,64(sp)
    80005144:	e4aa                	sd	a0,72(sp)
    80005146:	e8ae                	sd	a1,80(sp)
    80005148:	ecb2                	sd	a2,88(sp)
    8000514a:	f0b6                	sd	a3,96(sp)
    8000514c:	f4ba                	sd	a4,104(sp)
    8000514e:	f8be                	sd	a5,112(sp)
    80005150:	fcc2                	sd	a6,120(sp)
    80005152:	e146                	sd	a7,128(sp)
    80005154:	e54a                	sd	s2,136(sp)
    80005156:	e94e                	sd	s3,144(sp)
    80005158:	ed52                	sd	s4,152(sp)
    8000515a:	f156                	sd	s5,160(sp)
    8000515c:	f55a                	sd	s6,168(sp)
    8000515e:	f95e                	sd	s7,176(sp)
    80005160:	fd62                	sd	s8,184(sp)
    80005162:	e1e6                	sd	s9,192(sp)
    80005164:	e5ea                	sd	s10,200(sp)
    80005166:	e9ee                	sd	s11,208(sp)
    80005168:	edf2                	sd	t3,216(sp)
    8000516a:	f1f6                	sd	t4,224(sp)
    8000516c:	f5fa                	sd	t5,232(sp)
    8000516e:	f9fe                	sd	t6,240(sp)
    80005170:	c89fc0ef          	jal	ra,80001df8 <kerneltrap>
    80005174:	6082                	ld	ra,0(sp)
    80005176:	6122                	ld	sp,8(sp)
    80005178:	61c2                	ld	gp,16(sp)
    8000517a:	7282                	ld	t0,32(sp)
    8000517c:	7322                	ld	t1,40(sp)
    8000517e:	73c2                	ld	t2,48(sp)
    80005180:	7462                	ld	s0,56(sp)
    80005182:	6486                	ld	s1,64(sp)
    80005184:	6526                	ld	a0,72(sp)
    80005186:	65c6                	ld	a1,80(sp)
    80005188:	6666                	ld	a2,88(sp)
    8000518a:	7686                	ld	a3,96(sp)
    8000518c:	7726                	ld	a4,104(sp)
    8000518e:	77c6                	ld	a5,112(sp)
    80005190:	7866                	ld	a6,120(sp)
    80005192:	688a                	ld	a7,128(sp)
    80005194:	692a                	ld	s2,136(sp)
    80005196:	69ca                	ld	s3,144(sp)
    80005198:	6a6a                	ld	s4,152(sp)
    8000519a:	7a8a                	ld	s5,160(sp)
    8000519c:	7b2a                	ld	s6,168(sp)
    8000519e:	7bca                	ld	s7,176(sp)
    800051a0:	7c6a                	ld	s8,184(sp)
    800051a2:	6c8e                	ld	s9,192(sp)
    800051a4:	6d2e                	ld	s10,200(sp)
    800051a6:	6dce                	ld	s11,208(sp)
    800051a8:	6e6e                	ld	t3,216(sp)
    800051aa:	7e8e                	ld	t4,224(sp)
    800051ac:	7f2e                	ld	t5,232(sp)
    800051ae:	7fce                	ld	t6,240(sp)
    800051b0:	6111                	addi	sp,sp,256
    800051b2:	10200073          	sret
    800051b6:	00000013          	nop
    800051ba:	00000013          	nop
    800051be:	0001                	nop

00000000800051c0 <timervec>:
    800051c0:	34051573          	csrrw	a0,mscratch,a0
    800051c4:	e10c                	sd	a1,0(a0)
    800051c6:	e510                	sd	a2,8(a0)
    800051c8:	e914                	sd	a3,16(a0)
    800051ca:	6d0c                	ld	a1,24(a0)
    800051cc:	7110                	ld	a2,32(a0)
    800051ce:	6194                	ld	a3,0(a1)
    800051d0:	96b2                	add	a3,a3,a2
    800051d2:	e194                	sd	a3,0(a1)
    800051d4:	4589                	li	a1,2
    800051d6:	14459073          	csrw	sip,a1
    800051da:	6914                	ld	a3,16(a0)
    800051dc:	6510                	ld	a2,8(a0)
    800051de:	610c                	ld	a1,0(a0)
    800051e0:	34051573          	csrrw	a0,mscratch,a0
    800051e4:	30200073          	mret
	...

00000000800051ea <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800051ea:	1141                	addi	sp,sp,-16
    800051ec:	e422                	sd	s0,8(sp)
    800051ee:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800051f0:	0c0007b7          	lui	a5,0xc000
    800051f4:	4705                	li	a4,1
    800051f6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800051f8:	c3d8                	sw	a4,4(a5)
}
    800051fa:	6422                	ld	s0,8(sp)
    800051fc:	0141                	addi	sp,sp,16
    800051fe:	8082                	ret

0000000080005200 <plicinithart>:

void
plicinithart(void)
{
    80005200:	1141                	addi	sp,sp,-16
    80005202:	e406                	sd	ra,8(sp)
    80005204:	e022                	sd	s0,0(sp)
    80005206:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005208:	ffffc097          	auipc	ra,0xffffc
    8000520c:	c20080e7          	jalr	-992(ra) # 80000e28 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005210:	0085171b          	slliw	a4,a0,0x8
    80005214:	0c0027b7          	lui	a5,0xc002
    80005218:	97ba                	add	a5,a5,a4
    8000521a:	40200713          	li	a4,1026
    8000521e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005222:	00d5151b          	slliw	a0,a0,0xd
    80005226:	0c2017b7          	lui	a5,0xc201
    8000522a:	97aa                	add	a5,a5,a0
    8000522c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005230:	60a2                	ld	ra,8(sp)
    80005232:	6402                	ld	s0,0(sp)
    80005234:	0141                	addi	sp,sp,16
    80005236:	8082                	ret

0000000080005238 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005238:	1141                	addi	sp,sp,-16
    8000523a:	e406                	sd	ra,8(sp)
    8000523c:	e022                	sd	s0,0(sp)
    8000523e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005240:	ffffc097          	auipc	ra,0xffffc
    80005244:	be8080e7          	jalr	-1048(ra) # 80000e28 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005248:	00d5151b          	slliw	a0,a0,0xd
    8000524c:	0c2017b7          	lui	a5,0xc201
    80005250:	97aa                	add	a5,a5,a0
  return irq;
}
    80005252:	43c8                	lw	a0,4(a5)
    80005254:	60a2                	ld	ra,8(sp)
    80005256:	6402                	ld	s0,0(sp)
    80005258:	0141                	addi	sp,sp,16
    8000525a:	8082                	ret

000000008000525c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000525c:	1101                	addi	sp,sp,-32
    8000525e:	ec06                	sd	ra,24(sp)
    80005260:	e822                	sd	s0,16(sp)
    80005262:	e426                	sd	s1,8(sp)
    80005264:	1000                	addi	s0,sp,32
    80005266:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005268:	ffffc097          	auipc	ra,0xffffc
    8000526c:	bc0080e7          	jalr	-1088(ra) # 80000e28 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005270:	00d5151b          	slliw	a0,a0,0xd
    80005274:	0c2017b7          	lui	a5,0xc201
    80005278:	97aa                	add	a5,a5,a0
    8000527a:	c3c4                	sw	s1,4(a5)
}
    8000527c:	60e2                	ld	ra,24(sp)
    8000527e:	6442                	ld	s0,16(sp)
    80005280:	64a2                	ld	s1,8(sp)
    80005282:	6105                	addi	sp,sp,32
    80005284:	8082                	ret

0000000080005286 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005286:	1141                	addi	sp,sp,-16
    80005288:	e406                	sd	ra,8(sp)
    8000528a:	e022                	sd	s0,0(sp)
    8000528c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000528e:	479d                	li	a5,7
    80005290:	04a7cc63          	blt	a5,a0,800052e8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005294:	00015797          	auipc	a5,0x15
    80005298:	f5c78793          	addi	a5,a5,-164 # 8001a1f0 <disk>
    8000529c:	97aa                	add	a5,a5,a0
    8000529e:	0187c783          	lbu	a5,24(a5)
    800052a2:	ebb9                	bnez	a5,800052f8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800052a4:	00451693          	slli	a3,a0,0x4
    800052a8:	00015797          	auipc	a5,0x15
    800052ac:	f4878793          	addi	a5,a5,-184 # 8001a1f0 <disk>
    800052b0:	6398                	ld	a4,0(a5)
    800052b2:	9736                	add	a4,a4,a3
    800052b4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800052b8:	6398                	ld	a4,0(a5)
    800052ba:	9736                	add	a4,a4,a3
    800052bc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800052c0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800052c4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800052c8:	97aa                	add	a5,a5,a0
    800052ca:	4705                	li	a4,1
    800052cc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800052d0:	00015517          	auipc	a0,0x15
    800052d4:	f3850513          	addi	a0,a0,-200 # 8001a208 <disk+0x18>
    800052d8:	ffffc097          	auipc	ra,0xffffc
    800052dc:	292080e7          	jalr	658(ra) # 8000156a <wakeup>
}
    800052e0:	60a2                	ld	ra,8(sp)
    800052e2:	6402                	ld	s0,0(sp)
    800052e4:	0141                	addi	sp,sp,16
    800052e6:	8082                	ret
    panic("free_desc 1");
    800052e8:	00003517          	auipc	a0,0x3
    800052ec:	3f050513          	addi	a0,a0,1008 # 800086d8 <syscalls+0x308>
    800052f0:	00001097          	auipc	ra,0x1
    800052f4:	a0c080e7          	jalr	-1524(ra) # 80005cfc <panic>
    panic("free_desc 2");
    800052f8:	00003517          	auipc	a0,0x3
    800052fc:	3f050513          	addi	a0,a0,1008 # 800086e8 <syscalls+0x318>
    80005300:	00001097          	auipc	ra,0x1
    80005304:	9fc080e7          	jalr	-1540(ra) # 80005cfc <panic>

0000000080005308 <virtio_disk_init>:
{
    80005308:	1101                	addi	sp,sp,-32
    8000530a:	ec06                	sd	ra,24(sp)
    8000530c:	e822                	sd	s0,16(sp)
    8000530e:	e426                	sd	s1,8(sp)
    80005310:	e04a                	sd	s2,0(sp)
    80005312:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005314:	00003597          	auipc	a1,0x3
    80005318:	3e458593          	addi	a1,a1,996 # 800086f8 <syscalls+0x328>
    8000531c:	00015517          	auipc	a0,0x15
    80005320:	ffc50513          	addi	a0,a0,-4 # 8001a318 <disk+0x128>
    80005324:	00001097          	auipc	ra,0x1
    80005328:	e80080e7          	jalr	-384(ra) # 800061a4 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000532c:	100017b7          	lui	a5,0x10001
    80005330:	4398                	lw	a4,0(a5)
    80005332:	2701                	sext.w	a4,a4
    80005334:	747277b7          	lui	a5,0x74727
    80005338:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000533c:	14f71b63          	bne	a4,a5,80005492 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005340:	100017b7          	lui	a5,0x10001
    80005344:	43dc                	lw	a5,4(a5)
    80005346:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005348:	4709                	li	a4,2
    8000534a:	14e79463          	bne	a5,a4,80005492 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000534e:	100017b7          	lui	a5,0x10001
    80005352:	479c                	lw	a5,8(a5)
    80005354:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005356:	12e79e63          	bne	a5,a4,80005492 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000535a:	100017b7          	lui	a5,0x10001
    8000535e:	47d8                	lw	a4,12(a5)
    80005360:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005362:	554d47b7          	lui	a5,0x554d4
    80005366:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000536a:	12f71463          	bne	a4,a5,80005492 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000536e:	100017b7          	lui	a5,0x10001
    80005372:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005376:	4705                	li	a4,1
    80005378:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000537a:	470d                	li	a4,3
    8000537c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000537e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005380:	c7ffe6b7          	lui	a3,0xc7ffe
    80005384:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc1ef>
    80005388:	8f75                	and	a4,a4,a3
    8000538a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000538c:	472d                	li	a4,11
    8000538e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005390:	5bbc                	lw	a5,112(a5)
    80005392:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005396:	8ba1                	andi	a5,a5,8
    80005398:	10078563          	beqz	a5,800054a2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000539c:	100017b7          	lui	a5,0x10001
    800053a0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800053a4:	43fc                	lw	a5,68(a5)
    800053a6:	2781                	sext.w	a5,a5
    800053a8:	10079563          	bnez	a5,800054b2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800053ac:	100017b7          	lui	a5,0x10001
    800053b0:	5bdc                	lw	a5,52(a5)
    800053b2:	2781                	sext.w	a5,a5
  if(max == 0)
    800053b4:	10078763          	beqz	a5,800054c2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800053b8:	471d                	li	a4,7
    800053ba:	10f77c63          	bgeu	a4,a5,800054d2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800053be:	ffffb097          	auipc	ra,0xffffb
    800053c2:	d5c080e7          	jalr	-676(ra) # 8000011a <kalloc>
    800053c6:	00015497          	auipc	s1,0x15
    800053ca:	e2a48493          	addi	s1,s1,-470 # 8001a1f0 <disk>
    800053ce:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800053d0:	ffffb097          	auipc	ra,0xffffb
    800053d4:	d4a080e7          	jalr	-694(ra) # 8000011a <kalloc>
    800053d8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800053da:	ffffb097          	auipc	ra,0xffffb
    800053de:	d40080e7          	jalr	-704(ra) # 8000011a <kalloc>
    800053e2:	87aa                	mv	a5,a0
    800053e4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800053e6:	6088                	ld	a0,0(s1)
    800053e8:	cd6d                	beqz	a0,800054e2 <virtio_disk_init+0x1da>
    800053ea:	00015717          	auipc	a4,0x15
    800053ee:	e0e73703          	ld	a4,-498(a4) # 8001a1f8 <disk+0x8>
    800053f2:	cb65                	beqz	a4,800054e2 <virtio_disk_init+0x1da>
    800053f4:	c7fd                	beqz	a5,800054e2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800053f6:	6605                	lui	a2,0x1
    800053f8:	4581                	li	a1,0
    800053fa:	ffffb097          	auipc	ra,0xffffb
    800053fe:	d80080e7          	jalr	-640(ra) # 8000017a <memset>
  memset(disk.avail, 0, PGSIZE);
    80005402:	00015497          	auipc	s1,0x15
    80005406:	dee48493          	addi	s1,s1,-530 # 8001a1f0 <disk>
    8000540a:	6605                	lui	a2,0x1
    8000540c:	4581                	li	a1,0
    8000540e:	6488                	ld	a0,8(s1)
    80005410:	ffffb097          	auipc	ra,0xffffb
    80005414:	d6a080e7          	jalr	-662(ra) # 8000017a <memset>
  memset(disk.used, 0, PGSIZE);
    80005418:	6605                	lui	a2,0x1
    8000541a:	4581                	li	a1,0
    8000541c:	6888                	ld	a0,16(s1)
    8000541e:	ffffb097          	auipc	ra,0xffffb
    80005422:	d5c080e7          	jalr	-676(ra) # 8000017a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005426:	100017b7          	lui	a5,0x10001
    8000542a:	4721                	li	a4,8
    8000542c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000542e:	4098                	lw	a4,0(s1)
    80005430:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005434:	40d8                	lw	a4,4(s1)
    80005436:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000543a:	6498                	ld	a4,8(s1)
    8000543c:	0007069b          	sext.w	a3,a4
    80005440:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005444:	9701                	srai	a4,a4,0x20
    80005446:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000544a:	6898                	ld	a4,16(s1)
    8000544c:	0007069b          	sext.w	a3,a4
    80005450:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005454:	9701                	srai	a4,a4,0x20
    80005456:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000545a:	4705                	li	a4,1
    8000545c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000545e:	00e48c23          	sb	a4,24(s1)
    80005462:	00e48ca3          	sb	a4,25(s1)
    80005466:	00e48d23          	sb	a4,26(s1)
    8000546a:	00e48da3          	sb	a4,27(s1)
    8000546e:	00e48e23          	sb	a4,28(s1)
    80005472:	00e48ea3          	sb	a4,29(s1)
    80005476:	00e48f23          	sb	a4,30(s1)
    8000547a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000547e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005482:	0727a823          	sw	s2,112(a5)
}
    80005486:	60e2                	ld	ra,24(sp)
    80005488:	6442                	ld	s0,16(sp)
    8000548a:	64a2                	ld	s1,8(sp)
    8000548c:	6902                	ld	s2,0(sp)
    8000548e:	6105                	addi	sp,sp,32
    80005490:	8082                	ret
    panic("could not find virtio disk");
    80005492:	00003517          	auipc	a0,0x3
    80005496:	27650513          	addi	a0,a0,630 # 80008708 <syscalls+0x338>
    8000549a:	00001097          	auipc	ra,0x1
    8000549e:	862080e7          	jalr	-1950(ra) # 80005cfc <panic>
    panic("virtio disk FEATURES_OK unset");
    800054a2:	00003517          	auipc	a0,0x3
    800054a6:	28650513          	addi	a0,a0,646 # 80008728 <syscalls+0x358>
    800054aa:	00001097          	auipc	ra,0x1
    800054ae:	852080e7          	jalr	-1966(ra) # 80005cfc <panic>
    panic("virtio disk should not be ready");
    800054b2:	00003517          	auipc	a0,0x3
    800054b6:	29650513          	addi	a0,a0,662 # 80008748 <syscalls+0x378>
    800054ba:	00001097          	auipc	ra,0x1
    800054be:	842080e7          	jalr	-1982(ra) # 80005cfc <panic>
    panic("virtio disk has no queue 0");
    800054c2:	00003517          	auipc	a0,0x3
    800054c6:	2a650513          	addi	a0,a0,678 # 80008768 <syscalls+0x398>
    800054ca:	00001097          	auipc	ra,0x1
    800054ce:	832080e7          	jalr	-1998(ra) # 80005cfc <panic>
    panic("virtio disk max queue too short");
    800054d2:	00003517          	auipc	a0,0x3
    800054d6:	2b650513          	addi	a0,a0,694 # 80008788 <syscalls+0x3b8>
    800054da:	00001097          	auipc	ra,0x1
    800054de:	822080e7          	jalr	-2014(ra) # 80005cfc <panic>
    panic("virtio disk kalloc");
    800054e2:	00003517          	auipc	a0,0x3
    800054e6:	2c650513          	addi	a0,a0,710 # 800087a8 <syscalls+0x3d8>
    800054ea:	00001097          	auipc	ra,0x1
    800054ee:	812080e7          	jalr	-2030(ra) # 80005cfc <panic>

00000000800054f2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800054f2:	7119                	addi	sp,sp,-128
    800054f4:	fc86                	sd	ra,120(sp)
    800054f6:	f8a2                	sd	s0,112(sp)
    800054f8:	f4a6                	sd	s1,104(sp)
    800054fa:	f0ca                	sd	s2,96(sp)
    800054fc:	ecce                	sd	s3,88(sp)
    800054fe:	e8d2                	sd	s4,80(sp)
    80005500:	e4d6                	sd	s5,72(sp)
    80005502:	e0da                	sd	s6,64(sp)
    80005504:	fc5e                	sd	s7,56(sp)
    80005506:	f862                	sd	s8,48(sp)
    80005508:	f466                	sd	s9,40(sp)
    8000550a:	f06a                	sd	s10,32(sp)
    8000550c:	ec6e                	sd	s11,24(sp)
    8000550e:	0100                	addi	s0,sp,128
    80005510:	8aaa                	mv	s5,a0
    80005512:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005514:	00c52d03          	lw	s10,12(a0)
    80005518:	001d1d1b          	slliw	s10,s10,0x1
    8000551c:	1d02                	slli	s10,s10,0x20
    8000551e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80005522:	00015517          	auipc	a0,0x15
    80005526:	df650513          	addi	a0,a0,-522 # 8001a318 <disk+0x128>
    8000552a:	00001097          	auipc	ra,0x1
    8000552e:	d0a080e7          	jalr	-758(ra) # 80006234 <acquire>
  for(int i = 0; i < 3; i++){
    80005532:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005534:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005536:	00015b97          	auipc	s7,0x15
    8000553a:	cbab8b93          	addi	s7,s7,-838 # 8001a1f0 <disk>
  for(int i = 0; i < 3; i++){
    8000553e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005540:	00015c97          	auipc	s9,0x15
    80005544:	dd8c8c93          	addi	s9,s9,-552 # 8001a318 <disk+0x128>
    80005548:	a08d                	j	800055aa <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000554a:	00fb8733          	add	a4,s7,a5
    8000554e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005552:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005554:	0207c563          	bltz	a5,8000557e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80005558:	2905                	addiw	s2,s2,1
    8000555a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000555c:	05690c63          	beq	s2,s6,800055b4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005560:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005562:	00015717          	auipc	a4,0x15
    80005566:	c8e70713          	addi	a4,a4,-882 # 8001a1f0 <disk>
    8000556a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000556c:	01874683          	lbu	a3,24(a4)
    80005570:	fee9                	bnez	a3,8000554a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005572:	2785                	addiw	a5,a5,1
    80005574:	0705                	addi	a4,a4,1
    80005576:	fe979be3          	bne	a5,s1,8000556c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000557a:	57fd                	li	a5,-1
    8000557c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000557e:	01205d63          	blez	s2,80005598 <virtio_disk_rw+0xa6>
    80005582:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80005584:	000a2503          	lw	a0,0(s4)
    80005588:	00000097          	auipc	ra,0x0
    8000558c:	cfe080e7          	jalr	-770(ra) # 80005286 <free_desc>
      for(int j = 0; j < i; j++)
    80005590:	2d85                	addiw	s11,s11,1
    80005592:	0a11                	addi	s4,s4,4
    80005594:	ff2d98e3          	bne	s11,s2,80005584 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005598:	85e6                	mv	a1,s9
    8000559a:	00015517          	auipc	a0,0x15
    8000559e:	c6e50513          	addi	a0,a0,-914 # 8001a208 <disk+0x18>
    800055a2:	ffffc097          	auipc	ra,0xffffc
    800055a6:	f64080e7          	jalr	-156(ra) # 80001506 <sleep>
  for(int i = 0; i < 3; i++){
    800055aa:	f8040a13          	addi	s4,s0,-128
{
    800055ae:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800055b0:	894e                	mv	s2,s3
    800055b2:	b77d                	j	80005560 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800055b4:	f8042503          	lw	a0,-128(s0)
    800055b8:	00a50713          	addi	a4,a0,10
    800055bc:	0712                	slli	a4,a4,0x4

  if(write)
    800055be:	00015797          	auipc	a5,0x15
    800055c2:	c3278793          	addi	a5,a5,-974 # 8001a1f0 <disk>
    800055c6:	00e786b3          	add	a3,a5,a4
    800055ca:	01803633          	snez	a2,s8
    800055ce:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800055d0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800055d4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800055d8:	f6070613          	addi	a2,a4,-160
    800055dc:	6394                	ld	a3,0(a5)
    800055de:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800055e0:	00870593          	addi	a1,a4,8
    800055e4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800055e6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800055e8:	0007b803          	ld	a6,0(a5)
    800055ec:	9642                	add	a2,a2,a6
    800055ee:	46c1                	li	a3,16
    800055f0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800055f2:	4585                	li	a1,1
    800055f4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800055f8:	f8442683          	lw	a3,-124(s0)
    800055fc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005600:	0692                	slli	a3,a3,0x4
    80005602:	9836                	add	a6,a6,a3
    80005604:	058a8613          	addi	a2,s5,88
    80005608:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000560c:	0007b803          	ld	a6,0(a5)
    80005610:	96c2                	add	a3,a3,a6
    80005612:	40000613          	li	a2,1024
    80005616:	c690                	sw	a2,8(a3)
  if(write)
    80005618:	001c3613          	seqz	a2,s8
    8000561c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005620:	00166613          	ori	a2,a2,1
    80005624:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005628:	f8842603          	lw	a2,-120(s0)
    8000562c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005630:	00250693          	addi	a3,a0,2
    80005634:	0692                	slli	a3,a3,0x4
    80005636:	96be                	add	a3,a3,a5
    80005638:	58fd                	li	a7,-1
    8000563a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000563e:	0612                	slli	a2,a2,0x4
    80005640:	9832                	add	a6,a6,a2
    80005642:	f9070713          	addi	a4,a4,-112
    80005646:	973e                	add	a4,a4,a5
    80005648:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000564c:	6398                	ld	a4,0(a5)
    8000564e:	9732                	add	a4,a4,a2
    80005650:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005652:	4609                	li	a2,2
    80005654:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005658:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000565c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80005660:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005664:	6794                	ld	a3,8(a5)
    80005666:	0026d703          	lhu	a4,2(a3)
    8000566a:	8b1d                	andi	a4,a4,7
    8000566c:	0706                	slli	a4,a4,0x1
    8000566e:	96ba                	add	a3,a3,a4
    80005670:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005674:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005678:	6798                	ld	a4,8(a5)
    8000567a:	00275783          	lhu	a5,2(a4)
    8000567e:	2785                	addiw	a5,a5,1
    80005680:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005684:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005688:	100017b7          	lui	a5,0x10001
    8000568c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005690:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80005694:	00015917          	auipc	s2,0x15
    80005698:	c8490913          	addi	s2,s2,-892 # 8001a318 <disk+0x128>
  while(b->disk == 1) {
    8000569c:	4485                	li	s1,1
    8000569e:	00b79c63          	bne	a5,a1,800056b6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800056a2:	85ca                	mv	a1,s2
    800056a4:	8556                	mv	a0,s5
    800056a6:	ffffc097          	auipc	ra,0xffffc
    800056aa:	e60080e7          	jalr	-416(ra) # 80001506 <sleep>
  while(b->disk == 1) {
    800056ae:	004aa783          	lw	a5,4(s5)
    800056b2:	fe9788e3          	beq	a5,s1,800056a2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800056b6:	f8042903          	lw	s2,-128(s0)
    800056ba:	00290713          	addi	a4,s2,2
    800056be:	0712                	slli	a4,a4,0x4
    800056c0:	00015797          	auipc	a5,0x15
    800056c4:	b3078793          	addi	a5,a5,-1232 # 8001a1f0 <disk>
    800056c8:	97ba                	add	a5,a5,a4
    800056ca:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800056ce:	00015997          	auipc	s3,0x15
    800056d2:	b2298993          	addi	s3,s3,-1246 # 8001a1f0 <disk>
    800056d6:	00491713          	slli	a4,s2,0x4
    800056da:	0009b783          	ld	a5,0(s3)
    800056de:	97ba                	add	a5,a5,a4
    800056e0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800056e4:	854a                	mv	a0,s2
    800056e6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800056ea:	00000097          	auipc	ra,0x0
    800056ee:	b9c080e7          	jalr	-1124(ra) # 80005286 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800056f2:	8885                	andi	s1,s1,1
    800056f4:	f0ed                	bnez	s1,800056d6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800056f6:	00015517          	auipc	a0,0x15
    800056fa:	c2250513          	addi	a0,a0,-990 # 8001a318 <disk+0x128>
    800056fe:	00001097          	auipc	ra,0x1
    80005702:	bea080e7          	jalr	-1046(ra) # 800062e8 <release>
}
    80005706:	70e6                	ld	ra,120(sp)
    80005708:	7446                	ld	s0,112(sp)
    8000570a:	74a6                	ld	s1,104(sp)
    8000570c:	7906                	ld	s2,96(sp)
    8000570e:	69e6                	ld	s3,88(sp)
    80005710:	6a46                	ld	s4,80(sp)
    80005712:	6aa6                	ld	s5,72(sp)
    80005714:	6b06                	ld	s6,64(sp)
    80005716:	7be2                	ld	s7,56(sp)
    80005718:	7c42                	ld	s8,48(sp)
    8000571a:	7ca2                	ld	s9,40(sp)
    8000571c:	7d02                	ld	s10,32(sp)
    8000571e:	6de2                	ld	s11,24(sp)
    80005720:	6109                	addi	sp,sp,128
    80005722:	8082                	ret

0000000080005724 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005724:	1101                	addi	sp,sp,-32
    80005726:	ec06                	sd	ra,24(sp)
    80005728:	e822                	sd	s0,16(sp)
    8000572a:	e426                	sd	s1,8(sp)
    8000572c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000572e:	00015497          	auipc	s1,0x15
    80005732:	ac248493          	addi	s1,s1,-1342 # 8001a1f0 <disk>
    80005736:	00015517          	auipc	a0,0x15
    8000573a:	be250513          	addi	a0,a0,-1054 # 8001a318 <disk+0x128>
    8000573e:	00001097          	auipc	ra,0x1
    80005742:	af6080e7          	jalr	-1290(ra) # 80006234 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005746:	10001737          	lui	a4,0x10001
    8000574a:	533c                	lw	a5,96(a4)
    8000574c:	8b8d                	andi	a5,a5,3
    8000574e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005750:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005754:	689c                	ld	a5,16(s1)
    80005756:	0204d703          	lhu	a4,32(s1)
    8000575a:	0027d783          	lhu	a5,2(a5)
    8000575e:	04f70863          	beq	a4,a5,800057ae <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005762:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005766:	6898                	ld	a4,16(s1)
    80005768:	0204d783          	lhu	a5,32(s1)
    8000576c:	8b9d                	andi	a5,a5,7
    8000576e:	078e                	slli	a5,a5,0x3
    80005770:	97ba                	add	a5,a5,a4
    80005772:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005774:	00278713          	addi	a4,a5,2
    80005778:	0712                	slli	a4,a4,0x4
    8000577a:	9726                	add	a4,a4,s1
    8000577c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005780:	e721                	bnez	a4,800057c8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005782:	0789                	addi	a5,a5,2
    80005784:	0792                	slli	a5,a5,0x4
    80005786:	97a6                	add	a5,a5,s1
    80005788:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000578a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000578e:	ffffc097          	auipc	ra,0xffffc
    80005792:	ddc080e7          	jalr	-548(ra) # 8000156a <wakeup>

    disk.used_idx += 1;
    80005796:	0204d783          	lhu	a5,32(s1)
    8000579a:	2785                	addiw	a5,a5,1
    8000579c:	17c2                	slli	a5,a5,0x30
    8000579e:	93c1                	srli	a5,a5,0x30
    800057a0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800057a4:	6898                	ld	a4,16(s1)
    800057a6:	00275703          	lhu	a4,2(a4)
    800057aa:	faf71ce3          	bne	a4,a5,80005762 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800057ae:	00015517          	auipc	a0,0x15
    800057b2:	b6a50513          	addi	a0,a0,-1174 # 8001a318 <disk+0x128>
    800057b6:	00001097          	auipc	ra,0x1
    800057ba:	b32080e7          	jalr	-1230(ra) # 800062e8 <release>
}
    800057be:	60e2                	ld	ra,24(sp)
    800057c0:	6442                	ld	s0,16(sp)
    800057c2:	64a2                	ld	s1,8(sp)
    800057c4:	6105                	addi	sp,sp,32
    800057c6:	8082                	ret
      panic("virtio_disk_intr status");
    800057c8:	00003517          	auipc	a0,0x3
    800057cc:	ff850513          	addi	a0,a0,-8 # 800087c0 <syscalls+0x3f0>
    800057d0:	00000097          	auipc	ra,0x0
    800057d4:	52c080e7          	jalr	1324(ra) # 80005cfc <panic>

00000000800057d8 <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    800057d8:	1141                	addi	sp,sp,-16
    800057da:	e422                	sd	s0,8(sp)
    800057dc:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800057de:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    800057e2:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    800057e6:	0037979b          	slliw	a5,a5,0x3
    800057ea:	02004737          	lui	a4,0x2004
    800057ee:	97ba                	add	a5,a5,a4
    800057f0:	0200c737          	lui	a4,0x200c
    800057f4:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    800057f8:	000f4637          	lui	a2,0xf4
    800057fc:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80005800:	9732                	add	a4,a4,a2
    80005802:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005804:	00259693          	slli	a3,a1,0x2
    80005808:	96ae                	add	a3,a3,a1
    8000580a:	068e                	slli	a3,a3,0x3
    8000580c:	00015717          	auipc	a4,0x15
    80005810:	b2470713          	addi	a4,a4,-1244 # 8001a330 <timer_scratch>
    80005814:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80005816:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80005818:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000581a:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000581e:	00000797          	auipc	a5,0x0
    80005822:	9a278793          	addi	a5,a5,-1630 # 800051c0 <timervec>
    80005826:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000582a:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000582e:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005832:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005836:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000583a:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000583e:	30479073          	csrw	mie,a5
}
    80005842:	6422                	ld	s0,8(sp)
    80005844:	0141                	addi	sp,sp,16
    80005846:	8082                	ret

0000000080005848 <start>:
{
    80005848:	1141                	addi	sp,sp,-16
    8000584a:	e406                	sd	ra,8(sp)
    8000584c:	e022                	sd	s0,0(sp)
    8000584e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005850:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005854:	7779                	lui	a4,0xffffe
    80005856:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc28f>
    8000585a:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000585c:	6705                	lui	a4,0x1
    8000585e:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005862:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005864:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80005868:	ffffb797          	auipc	a5,0xffffb
    8000586c:	ab878793          	addi	a5,a5,-1352 # 80000320 <main>
    80005870:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80005874:	4781                	li	a5,0
    80005876:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    8000587a:	67c1                	lui	a5,0x10
    8000587c:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000587e:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005882:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80005886:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    8000588a:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    8000588e:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005892:	57fd                	li	a5,-1
    80005894:	83a9                	srli	a5,a5,0xa
    80005896:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    8000589a:	47bd                	li	a5,15
    8000589c:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800058a0:	00000097          	auipc	ra,0x0
    800058a4:	f38080e7          	jalr	-200(ra) # 800057d8 <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800058a8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800058ac:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    800058ae:	823e                	mv	tp,a5
  asm volatile("mret");
    800058b0:	30200073          	mret
}
    800058b4:	60a2                	ld	ra,8(sp)
    800058b6:	6402                	ld	s0,0(sp)
    800058b8:	0141                	addi	sp,sp,16
    800058ba:	8082                	ret

00000000800058bc <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800058bc:	715d                	addi	sp,sp,-80
    800058be:	e486                	sd	ra,72(sp)
    800058c0:	e0a2                	sd	s0,64(sp)
    800058c2:	fc26                	sd	s1,56(sp)
    800058c4:	f84a                	sd	s2,48(sp)
    800058c6:	f44e                	sd	s3,40(sp)
    800058c8:	f052                	sd	s4,32(sp)
    800058ca:	ec56                	sd	s5,24(sp)
    800058cc:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800058ce:	04c05763          	blez	a2,8000591c <consolewrite+0x60>
    800058d2:	8a2a                	mv	s4,a0
    800058d4:	84ae                	mv	s1,a1
    800058d6:	89b2                	mv	s3,a2
    800058d8:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800058da:	5afd                	li	s5,-1
    800058dc:	4685                	li	a3,1
    800058de:	8626                	mv	a2,s1
    800058e0:	85d2                	mv	a1,s4
    800058e2:	fbf40513          	addi	a0,s0,-65
    800058e6:	ffffc097          	auipc	ra,0xffffc
    800058ea:	07e080e7          	jalr	126(ra) # 80001964 <either_copyin>
    800058ee:	01550d63          	beq	a0,s5,80005908 <consolewrite+0x4c>
      break;
    uartputc(c);
    800058f2:	fbf44503          	lbu	a0,-65(s0)
    800058f6:	00000097          	auipc	ra,0x0
    800058fa:	784080e7          	jalr	1924(ra) # 8000607a <uartputc>
  for(i = 0; i < n; i++){
    800058fe:	2905                	addiw	s2,s2,1
    80005900:	0485                	addi	s1,s1,1
    80005902:	fd299de3          	bne	s3,s2,800058dc <consolewrite+0x20>
    80005906:	894e                	mv	s2,s3
  }

  return i;
}
    80005908:	854a                	mv	a0,s2
    8000590a:	60a6                	ld	ra,72(sp)
    8000590c:	6406                	ld	s0,64(sp)
    8000590e:	74e2                	ld	s1,56(sp)
    80005910:	7942                	ld	s2,48(sp)
    80005912:	79a2                	ld	s3,40(sp)
    80005914:	7a02                	ld	s4,32(sp)
    80005916:	6ae2                	ld	s5,24(sp)
    80005918:	6161                	addi	sp,sp,80
    8000591a:	8082                	ret
  for(i = 0; i < n; i++){
    8000591c:	4901                	li	s2,0
    8000591e:	b7ed                	j	80005908 <consolewrite+0x4c>

0000000080005920 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005920:	7159                	addi	sp,sp,-112
    80005922:	f486                	sd	ra,104(sp)
    80005924:	f0a2                	sd	s0,96(sp)
    80005926:	eca6                	sd	s1,88(sp)
    80005928:	e8ca                	sd	s2,80(sp)
    8000592a:	e4ce                	sd	s3,72(sp)
    8000592c:	e0d2                	sd	s4,64(sp)
    8000592e:	fc56                	sd	s5,56(sp)
    80005930:	f85a                	sd	s6,48(sp)
    80005932:	f45e                	sd	s7,40(sp)
    80005934:	f062                	sd	s8,32(sp)
    80005936:	ec66                	sd	s9,24(sp)
    80005938:	e86a                	sd	s10,16(sp)
    8000593a:	1880                	addi	s0,sp,112
    8000593c:	8aaa                	mv	s5,a0
    8000593e:	8a2e                	mv	s4,a1
    80005940:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005942:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80005946:	0001d517          	auipc	a0,0x1d
    8000594a:	b2a50513          	addi	a0,a0,-1238 # 80022470 <cons>
    8000594e:	00001097          	auipc	ra,0x1
    80005952:	8e6080e7          	jalr	-1818(ra) # 80006234 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005956:	0001d497          	auipc	s1,0x1d
    8000595a:	b1a48493          	addi	s1,s1,-1254 # 80022470 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000595e:	0001d917          	auipc	s2,0x1d
    80005962:	baa90913          	addi	s2,s2,-1110 # 80022508 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80005966:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005968:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    8000596a:	4ca9                	li	s9,10
  while(n > 0){
    8000596c:	07305b63          	blez	s3,800059e2 <consoleread+0xc2>
    while(cons.r == cons.w){
    80005970:	0984a783          	lw	a5,152(s1)
    80005974:	09c4a703          	lw	a4,156(s1)
    80005978:	02f71763          	bne	a4,a5,800059a6 <consoleread+0x86>
      if(killed(myproc())){
    8000597c:	ffffb097          	auipc	ra,0xffffb
    80005980:	4d8080e7          	jalr	1240(ra) # 80000e54 <myproc>
    80005984:	ffffc097          	auipc	ra,0xffffc
    80005988:	e2a080e7          	jalr	-470(ra) # 800017ae <killed>
    8000598c:	e535                	bnez	a0,800059f8 <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    8000598e:	85a6                	mv	a1,s1
    80005990:	854a                	mv	a0,s2
    80005992:	ffffc097          	auipc	ra,0xffffc
    80005996:	b74080e7          	jalr	-1164(ra) # 80001506 <sleep>
    while(cons.r == cons.w){
    8000599a:	0984a783          	lw	a5,152(s1)
    8000599e:	09c4a703          	lw	a4,156(s1)
    800059a2:	fcf70de3          	beq	a4,a5,8000597c <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800059a6:	0017871b          	addiw	a4,a5,1
    800059aa:	08e4ac23          	sw	a4,152(s1)
    800059ae:	07f7f713          	andi	a4,a5,127
    800059b2:	9726                	add	a4,a4,s1
    800059b4:	01874703          	lbu	a4,24(a4)
    800059b8:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    800059bc:	077d0563          	beq	s10,s7,80005a26 <consoleread+0x106>
    cbuf = c;
    800059c0:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800059c4:	4685                	li	a3,1
    800059c6:	f9f40613          	addi	a2,s0,-97
    800059ca:	85d2                	mv	a1,s4
    800059cc:	8556                	mv	a0,s5
    800059ce:	ffffc097          	auipc	ra,0xffffc
    800059d2:	f40080e7          	jalr	-192(ra) # 8000190e <either_copyout>
    800059d6:	01850663          	beq	a0,s8,800059e2 <consoleread+0xc2>
    dst++;
    800059da:	0a05                	addi	s4,s4,1
    --n;
    800059dc:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    800059de:	f99d17e3          	bne	s10,s9,8000596c <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    800059e2:	0001d517          	auipc	a0,0x1d
    800059e6:	a8e50513          	addi	a0,a0,-1394 # 80022470 <cons>
    800059ea:	00001097          	auipc	ra,0x1
    800059ee:	8fe080e7          	jalr	-1794(ra) # 800062e8 <release>

  return target - n;
    800059f2:	413b053b          	subw	a0,s6,s3
    800059f6:	a811                	j	80005a0a <consoleread+0xea>
        release(&cons.lock);
    800059f8:	0001d517          	auipc	a0,0x1d
    800059fc:	a7850513          	addi	a0,a0,-1416 # 80022470 <cons>
    80005a00:	00001097          	auipc	ra,0x1
    80005a04:	8e8080e7          	jalr	-1816(ra) # 800062e8 <release>
        return -1;
    80005a08:	557d                	li	a0,-1
}
    80005a0a:	70a6                	ld	ra,104(sp)
    80005a0c:	7406                	ld	s0,96(sp)
    80005a0e:	64e6                	ld	s1,88(sp)
    80005a10:	6946                	ld	s2,80(sp)
    80005a12:	69a6                	ld	s3,72(sp)
    80005a14:	6a06                	ld	s4,64(sp)
    80005a16:	7ae2                	ld	s5,56(sp)
    80005a18:	7b42                	ld	s6,48(sp)
    80005a1a:	7ba2                	ld	s7,40(sp)
    80005a1c:	7c02                	ld	s8,32(sp)
    80005a1e:	6ce2                	ld	s9,24(sp)
    80005a20:	6d42                	ld	s10,16(sp)
    80005a22:	6165                	addi	sp,sp,112
    80005a24:	8082                	ret
      if(n < target){
    80005a26:	0009871b          	sext.w	a4,s3
    80005a2a:	fb677ce3          	bgeu	a4,s6,800059e2 <consoleread+0xc2>
        cons.r--;
    80005a2e:	0001d717          	auipc	a4,0x1d
    80005a32:	acf72d23          	sw	a5,-1318(a4) # 80022508 <cons+0x98>
    80005a36:	b775                	j	800059e2 <consoleread+0xc2>

0000000080005a38 <consputc>:
{
    80005a38:	1141                	addi	sp,sp,-16
    80005a3a:	e406                	sd	ra,8(sp)
    80005a3c:	e022                	sd	s0,0(sp)
    80005a3e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005a40:	10000793          	li	a5,256
    80005a44:	00f50a63          	beq	a0,a5,80005a58 <consputc+0x20>
    uartputc_sync(c);
    80005a48:	00000097          	auipc	ra,0x0
    80005a4c:	560080e7          	jalr	1376(ra) # 80005fa8 <uartputc_sync>
}
    80005a50:	60a2                	ld	ra,8(sp)
    80005a52:	6402                	ld	s0,0(sp)
    80005a54:	0141                	addi	sp,sp,16
    80005a56:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005a58:	4521                	li	a0,8
    80005a5a:	00000097          	auipc	ra,0x0
    80005a5e:	54e080e7          	jalr	1358(ra) # 80005fa8 <uartputc_sync>
    80005a62:	02000513          	li	a0,32
    80005a66:	00000097          	auipc	ra,0x0
    80005a6a:	542080e7          	jalr	1346(ra) # 80005fa8 <uartputc_sync>
    80005a6e:	4521                	li	a0,8
    80005a70:	00000097          	auipc	ra,0x0
    80005a74:	538080e7          	jalr	1336(ra) # 80005fa8 <uartputc_sync>
    80005a78:	bfe1                	j	80005a50 <consputc+0x18>

0000000080005a7a <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005a7a:	1101                	addi	sp,sp,-32
    80005a7c:	ec06                	sd	ra,24(sp)
    80005a7e:	e822                	sd	s0,16(sp)
    80005a80:	e426                	sd	s1,8(sp)
    80005a82:	e04a                	sd	s2,0(sp)
    80005a84:	1000                	addi	s0,sp,32
    80005a86:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005a88:	0001d517          	auipc	a0,0x1d
    80005a8c:	9e850513          	addi	a0,a0,-1560 # 80022470 <cons>
    80005a90:	00000097          	auipc	ra,0x0
    80005a94:	7a4080e7          	jalr	1956(ra) # 80006234 <acquire>

  switch(c){
    80005a98:	47d5                	li	a5,21
    80005a9a:	0af48663          	beq	s1,a5,80005b46 <consoleintr+0xcc>
    80005a9e:	0297ca63          	blt	a5,s1,80005ad2 <consoleintr+0x58>
    80005aa2:	47a1                	li	a5,8
    80005aa4:	0ef48763          	beq	s1,a5,80005b92 <consoleintr+0x118>
    80005aa8:	47c1                	li	a5,16
    80005aaa:	10f49a63          	bne	s1,a5,80005bbe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005aae:	ffffc097          	auipc	ra,0xffffc
    80005ab2:	f0c080e7          	jalr	-244(ra) # 800019ba <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005ab6:	0001d517          	auipc	a0,0x1d
    80005aba:	9ba50513          	addi	a0,a0,-1606 # 80022470 <cons>
    80005abe:	00001097          	auipc	ra,0x1
    80005ac2:	82a080e7          	jalr	-2006(ra) # 800062e8 <release>
}
    80005ac6:	60e2                	ld	ra,24(sp)
    80005ac8:	6442                	ld	s0,16(sp)
    80005aca:	64a2                	ld	s1,8(sp)
    80005acc:	6902                	ld	s2,0(sp)
    80005ace:	6105                	addi	sp,sp,32
    80005ad0:	8082                	ret
  switch(c){
    80005ad2:	07f00793          	li	a5,127
    80005ad6:	0af48e63          	beq	s1,a5,80005b92 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005ada:	0001d717          	auipc	a4,0x1d
    80005ade:	99670713          	addi	a4,a4,-1642 # 80022470 <cons>
    80005ae2:	0a072783          	lw	a5,160(a4)
    80005ae6:	09872703          	lw	a4,152(a4)
    80005aea:	9f99                	subw	a5,a5,a4
    80005aec:	07f00713          	li	a4,127
    80005af0:	fcf763e3          	bltu	a4,a5,80005ab6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005af4:	47b5                	li	a5,13
    80005af6:	0cf48763          	beq	s1,a5,80005bc4 <consoleintr+0x14a>
      consputc(c);
    80005afa:	8526                	mv	a0,s1
    80005afc:	00000097          	auipc	ra,0x0
    80005b00:	f3c080e7          	jalr	-196(ra) # 80005a38 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005b04:	0001d797          	auipc	a5,0x1d
    80005b08:	96c78793          	addi	a5,a5,-1684 # 80022470 <cons>
    80005b0c:	0a07a683          	lw	a3,160(a5)
    80005b10:	0016871b          	addiw	a4,a3,1
    80005b14:	0007061b          	sext.w	a2,a4
    80005b18:	0ae7a023          	sw	a4,160(a5)
    80005b1c:	07f6f693          	andi	a3,a3,127
    80005b20:	97b6                	add	a5,a5,a3
    80005b22:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005b26:	47a9                	li	a5,10
    80005b28:	0cf48563          	beq	s1,a5,80005bf2 <consoleintr+0x178>
    80005b2c:	4791                	li	a5,4
    80005b2e:	0cf48263          	beq	s1,a5,80005bf2 <consoleintr+0x178>
    80005b32:	0001d797          	auipc	a5,0x1d
    80005b36:	9d67a783          	lw	a5,-1578(a5) # 80022508 <cons+0x98>
    80005b3a:	9f1d                	subw	a4,a4,a5
    80005b3c:	08000793          	li	a5,128
    80005b40:	f6f71be3          	bne	a4,a5,80005ab6 <consoleintr+0x3c>
    80005b44:	a07d                	j	80005bf2 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005b46:	0001d717          	auipc	a4,0x1d
    80005b4a:	92a70713          	addi	a4,a4,-1750 # 80022470 <cons>
    80005b4e:	0a072783          	lw	a5,160(a4)
    80005b52:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005b56:	0001d497          	auipc	s1,0x1d
    80005b5a:	91a48493          	addi	s1,s1,-1766 # 80022470 <cons>
    while(cons.e != cons.w &&
    80005b5e:	4929                	li	s2,10
    80005b60:	f4f70be3          	beq	a4,a5,80005ab6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005b64:	37fd                	addiw	a5,a5,-1
    80005b66:	07f7f713          	andi	a4,a5,127
    80005b6a:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005b6c:	01874703          	lbu	a4,24(a4)
    80005b70:	f52703e3          	beq	a4,s2,80005ab6 <consoleintr+0x3c>
      cons.e--;
    80005b74:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005b78:	10000513          	li	a0,256
    80005b7c:	00000097          	auipc	ra,0x0
    80005b80:	ebc080e7          	jalr	-324(ra) # 80005a38 <consputc>
    while(cons.e != cons.w &&
    80005b84:	0a04a783          	lw	a5,160(s1)
    80005b88:	09c4a703          	lw	a4,156(s1)
    80005b8c:	fcf71ce3          	bne	a4,a5,80005b64 <consoleintr+0xea>
    80005b90:	b71d                	j	80005ab6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005b92:	0001d717          	auipc	a4,0x1d
    80005b96:	8de70713          	addi	a4,a4,-1826 # 80022470 <cons>
    80005b9a:	0a072783          	lw	a5,160(a4)
    80005b9e:	09c72703          	lw	a4,156(a4)
    80005ba2:	f0f70ae3          	beq	a4,a5,80005ab6 <consoleintr+0x3c>
      cons.e--;
    80005ba6:	37fd                	addiw	a5,a5,-1
    80005ba8:	0001d717          	auipc	a4,0x1d
    80005bac:	96f72423          	sw	a5,-1688(a4) # 80022510 <cons+0xa0>
      consputc(BACKSPACE);
    80005bb0:	10000513          	li	a0,256
    80005bb4:	00000097          	auipc	ra,0x0
    80005bb8:	e84080e7          	jalr	-380(ra) # 80005a38 <consputc>
    80005bbc:	bded                	j	80005ab6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005bbe:	ee048ce3          	beqz	s1,80005ab6 <consoleintr+0x3c>
    80005bc2:	bf21                	j	80005ada <consoleintr+0x60>
      consputc(c);
    80005bc4:	4529                	li	a0,10
    80005bc6:	00000097          	auipc	ra,0x0
    80005bca:	e72080e7          	jalr	-398(ra) # 80005a38 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005bce:	0001d797          	auipc	a5,0x1d
    80005bd2:	8a278793          	addi	a5,a5,-1886 # 80022470 <cons>
    80005bd6:	0a07a703          	lw	a4,160(a5)
    80005bda:	0017069b          	addiw	a3,a4,1
    80005bde:	0006861b          	sext.w	a2,a3
    80005be2:	0ad7a023          	sw	a3,160(a5)
    80005be6:	07f77713          	andi	a4,a4,127
    80005bea:	97ba                	add	a5,a5,a4
    80005bec:	4729                	li	a4,10
    80005bee:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005bf2:	0001d797          	auipc	a5,0x1d
    80005bf6:	90c7ad23          	sw	a2,-1766(a5) # 8002250c <cons+0x9c>
        wakeup(&cons.r);
    80005bfa:	0001d517          	auipc	a0,0x1d
    80005bfe:	90e50513          	addi	a0,a0,-1778 # 80022508 <cons+0x98>
    80005c02:	ffffc097          	auipc	ra,0xffffc
    80005c06:	968080e7          	jalr	-1688(ra) # 8000156a <wakeup>
    80005c0a:	b575                	j	80005ab6 <consoleintr+0x3c>

0000000080005c0c <consoleinit>:

void
consoleinit(void)
{
    80005c0c:	1141                	addi	sp,sp,-16
    80005c0e:	e406                	sd	ra,8(sp)
    80005c10:	e022                	sd	s0,0(sp)
    80005c12:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005c14:	00003597          	auipc	a1,0x3
    80005c18:	bc458593          	addi	a1,a1,-1084 # 800087d8 <syscalls+0x408>
    80005c1c:	0001d517          	auipc	a0,0x1d
    80005c20:	85450513          	addi	a0,a0,-1964 # 80022470 <cons>
    80005c24:	00000097          	auipc	ra,0x0
    80005c28:	580080e7          	jalr	1408(ra) # 800061a4 <initlock>

  uartinit();
    80005c2c:	00000097          	auipc	ra,0x0
    80005c30:	32c080e7          	jalr	812(ra) # 80005f58 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005c34:	00013797          	auipc	a5,0x13
    80005c38:	56478793          	addi	a5,a5,1380 # 80019198 <devsw>
    80005c3c:	00000717          	auipc	a4,0x0
    80005c40:	ce470713          	addi	a4,a4,-796 # 80005920 <consoleread>
    80005c44:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005c46:	00000717          	auipc	a4,0x0
    80005c4a:	c7670713          	addi	a4,a4,-906 # 800058bc <consolewrite>
    80005c4e:	ef98                	sd	a4,24(a5)
}
    80005c50:	60a2                	ld	ra,8(sp)
    80005c52:	6402                	ld	s0,0(sp)
    80005c54:	0141                	addi	sp,sp,16
    80005c56:	8082                	ret

0000000080005c58 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005c58:	7179                	addi	sp,sp,-48
    80005c5a:	f406                	sd	ra,40(sp)
    80005c5c:	f022                	sd	s0,32(sp)
    80005c5e:	ec26                	sd	s1,24(sp)
    80005c60:	e84a                	sd	s2,16(sp)
    80005c62:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005c64:	c219                	beqz	a2,80005c6a <printint+0x12>
    80005c66:	08054763          	bltz	a0,80005cf4 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    80005c6a:	2501                	sext.w	a0,a0
    80005c6c:	4881                	li	a7,0
    80005c6e:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005c72:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005c74:	2581                	sext.w	a1,a1
    80005c76:	00003617          	auipc	a2,0x3
    80005c7a:	b9260613          	addi	a2,a2,-1134 # 80008808 <digits>
    80005c7e:	883a                	mv	a6,a4
    80005c80:	2705                	addiw	a4,a4,1
    80005c82:	02b577bb          	remuw	a5,a0,a1
    80005c86:	1782                	slli	a5,a5,0x20
    80005c88:	9381                	srli	a5,a5,0x20
    80005c8a:	97b2                	add	a5,a5,a2
    80005c8c:	0007c783          	lbu	a5,0(a5)
    80005c90:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005c94:	0005079b          	sext.w	a5,a0
    80005c98:	02b5553b          	divuw	a0,a0,a1
    80005c9c:	0685                	addi	a3,a3,1
    80005c9e:	feb7f0e3          	bgeu	a5,a1,80005c7e <printint+0x26>

  if(sign)
    80005ca2:	00088c63          	beqz	a7,80005cba <printint+0x62>
    buf[i++] = '-';
    80005ca6:	fe070793          	addi	a5,a4,-32
    80005caa:	00878733          	add	a4,a5,s0
    80005cae:	02d00793          	li	a5,45
    80005cb2:	fef70823          	sb	a5,-16(a4)
    80005cb6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005cba:	02e05763          	blez	a4,80005ce8 <printint+0x90>
    80005cbe:	fd040793          	addi	a5,s0,-48
    80005cc2:	00e784b3          	add	s1,a5,a4
    80005cc6:	fff78913          	addi	s2,a5,-1
    80005cca:	993a                	add	s2,s2,a4
    80005ccc:	377d                	addiw	a4,a4,-1
    80005cce:	1702                	slli	a4,a4,0x20
    80005cd0:	9301                	srli	a4,a4,0x20
    80005cd2:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005cd6:	fff4c503          	lbu	a0,-1(s1)
    80005cda:	00000097          	auipc	ra,0x0
    80005cde:	d5e080e7          	jalr	-674(ra) # 80005a38 <consputc>
  while(--i >= 0)
    80005ce2:	14fd                	addi	s1,s1,-1
    80005ce4:	ff2499e3          	bne	s1,s2,80005cd6 <printint+0x7e>
}
    80005ce8:	70a2                	ld	ra,40(sp)
    80005cea:	7402                	ld	s0,32(sp)
    80005cec:	64e2                	ld	s1,24(sp)
    80005cee:	6942                	ld	s2,16(sp)
    80005cf0:	6145                	addi	sp,sp,48
    80005cf2:	8082                	ret
    x = -xx;
    80005cf4:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005cf8:	4885                	li	a7,1
    x = -xx;
    80005cfa:	bf95                	j	80005c6e <printint+0x16>

0000000080005cfc <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005cfc:	1101                	addi	sp,sp,-32
    80005cfe:	ec06                	sd	ra,24(sp)
    80005d00:	e822                	sd	s0,16(sp)
    80005d02:	e426                	sd	s1,8(sp)
    80005d04:	1000                	addi	s0,sp,32
    80005d06:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005d08:	0001d797          	auipc	a5,0x1d
    80005d0c:	8207a423          	sw	zero,-2008(a5) # 80022530 <pr+0x18>
  printf("panic: ");
    80005d10:	00003517          	auipc	a0,0x3
    80005d14:	ad050513          	addi	a0,a0,-1328 # 800087e0 <syscalls+0x410>
    80005d18:	00000097          	auipc	ra,0x0
    80005d1c:	02e080e7          	jalr	46(ra) # 80005d46 <printf>
  printf(s);
    80005d20:	8526                	mv	a0,s1
    80005d22:	00000097          	auipc	ra,0x0
    80005d26:	024080e7          	jalr	36(ra) # 80005d46 <printf>
  printf("\n");
    80005d2a:	00002517          	auipc	a0,0x2
    80005d2e:	31e50513          	addi	a0,a0,798 # 80008048 <etext+0x48>
    80005d32:	00000097          	auipc	ra,0x0
    80005d36:	014080e7          	jalr	20(ra) # 80005d46 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005d3a:	4785                	li	a5,1
    80005d3c:	00003717          	auipc	a4,0x3
    80005d40:	baf72823          	sw	a5,-1104(a4) # 800088ec <panicked>
  for(;;)
    80005d44:	a001                	j	80005d44 <panic+0x48>

0000000080005d46 <printf>:
{
    80005d46:	7131                	addi	sp,sp,-192
    80005d48:	fc86                	sd	ra,120(sp)
    80005d4a:	f8a2                	sd	s0,112(sp)
    80005d4c:	f4a6                	sd	s1,104(sp)
    80005d4e:	f0ca                	sd	s2,96(sp)
    80005d50:	ecce                	sd	s3,88(sp)
    80005d52:	e8d2                	sd	s4,80(sp)
    80005d54:	e4d6                	sd	s5,72(sp)
    80005d56:	e0da                	sd	s6,64(sp)
    80005d58:	fc5e                	sd	s7,56(sp)
    80005d5a:	f862                	sd	s8,48(sp)
    80005d5c:	f466                	sd	s9,40(sp)
    80005d5e:	f06a                	sd	s10,32(sp)
    80005d60:	ec6e                	sd	s11,24(sp)
    80005d62:	0100                	addi	s0,sp,128
    80005d64:	8a2a                	mv	s4,a0
    80005d66:	e40c                	sd	a1,8(s0)
    80005d68:	e810                	sd	a2,16(s0)
    80005d6a:	ec14                	sd	a3,24(s0)
    80005d6c:	f018                	sd	a4,32(s0)
    80005d6e:	f41c                	sd	a5,40(s0)
    80005d70:	03043823          	sd	a6,48(s0)
    80005d74:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005d78:	0001cd97          	auipc	s11,0x1c
    80005d7c:	7b8dad83          	lw	s11,1976(s11) # 80022530 <pr+0x18>
  if(locking)
    80005d80:	020d9b63          	bnez	s11,80005db6 <printf+0x70>
  if (fmt == 0)
    80005d84:	040a0263          	beqz	s4,80005dc8 <printf+0x82>
  va_start(ap, fmt);
    80005d88:	00840793          	addi	a5,s0,8
    80005d8c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005d90:	000a4503          	lbu	a0,0(s4)
    80005d94:	14050f63          	beqz	a0,80005ef2 <printf+0x1ac>
    80005d98:	4981                	li	s3,0
    if(c != '%'){
    80005d9a:	02500a93          	li	s5,37
    switch(c){
    80005d9e:	07000b93          	li	s7,112
  consputc('x');
    80005da2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005da4:	00003b17          	auipc	s6,0x3
    80005da8:	a64b0b13          	addi	s6,s6,-1436 # 80008808 <digits>
    switch(c){
    80005dac:	07300c93          	li	s9,115
    80005db0:	06400c13          	li	s8,100
    80005db4:	a82d                	j	80005dee <printf+0xa8>
    acquire(&pr.lock);
    80005db6:	0001c517          	auipc	a0,0x1c
    80005dba:	76250513          	addi	a0,a0,1890 # 80022518 <pr>
    80005dbe:	00000097          	auipc	ra,0x0
    80005dc2:	476080e7          	jalr	1142(ra) # 80006234 <acquire>
    80005dc6:	bf7d                	j	80005d84 <printf+0x3e>
    panic("null fmt");
    80005dc8:	00003517          	auipc	a0,0x3
    80005dcc:	a2850513          	addi	a0,a0,-1496 # 800087f0 <syscalls+0x420>
    80005dd0:	00000097          	auipc	ra,0x0
    80005dd4:	f2c080e7          	jalr	-212(ra) # 80005cfc <panic>
      consputc(c);
    80005dd8:	00000097          	auipc	ra,0x0
    80005ddc:	c60080e7          	jalr	-928(ra) # 80005a38 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80005de0:	2985                	addiw	s3,s3,1
    80005de2:	013a07b3          	add	a5,s4,s3
    80005de6:	0007c503          	lbu	a0,0(a5)
    80005dea:	10050463          	beqz	a0,80005ef2 <printf+0x1ac>
    if(c != '%'){
    80005dee:	ff5515e3          	bne	a0,s5,80005dd8 <printf+0x92>
    c = fmt[++i] & 0xff;
    80005df2:	2985                	addiw	s3,s3,1
    80005df4:	013a07b3          	add	a5,s4,s3
    80005df8:	0007c783          	lbu	a5,0(a5)
    80005dfc:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80005e00:	cbed                	beqz	a5,80005ef2 <printf+0x1ac>
    switch(c){
    80005e02:	05778a63          	beq	a5,s7,80005e56 <printf+0x110>
    80005e06:	02fbf663          	bgeu	s7,a5,80005e32 <printf+0xec>
    80005e0a:	09978863          	beq	a5,s9,80005e9a <printf+0x154>
    80005e0e:	07800713          	li	a4,120
    80005e12:	0ce79563          	bne	a5,a4,80005edc <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80005e16:	f8843783          	ld	a5,-120(s0)
    80005e1a:	00878713          	addi	a4,a5,8
    80005e1e:	f8e43423          	sd	a4,-120(s0)
    80005e22:	4605                	li	a2,1
    80005e24:	85ea                	mv	a1,s10
    80005e26:	4388                	lw	a0,0(a5)
    80005e28:	00000097          	auipc	ra,0x0
    80005e2c:	e30080e7          	jalr	-464(ra) # 80005c58 <printint>
      break;
    80005e30:	bf45                	j	80005de0 <printf+0x9a>
    switch(c){
    80005e32:	09578f63          	beq	a5,s5,80005ed0 <printf+0x18a>
    80005e36:	0b879363          	bne	a5,s8,80005edc <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80005e3a:	f8843783          	ld	a5,-120(s0)
    80005e3e:	00878713          	addi	a4,a5,8
    80005e42:	f8e43423          	sd	a4,-120(s0)
    80005e46:	4605                	li	a2,1
    80005e48:	45a9                	li	a1,10
    80005e4a:	4388                	lw	a0,0(a5)
    80005e4c:	00000097          	auipc	ra,0x0
    80005e50:	e0c080e7          	jalr	-500(ra) # 80005c58 <printint>
      break;
    80005e54:	b771                	j	80005de0 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80005e56:	f8843783          	ld	a5,-120(s0)
    80005e5a:	00878713          	addi	a4,a5,8
    80005e5e:	f8e43423          	sd	a4,-120(s0)
    80005e62:	0007b903          	ld	s2,0(a5)
  consputc('0');
    80005e66:	03000513          	li	a0,48
    80005e6a:	00000097          	auipc	ra,0x0
    80005e6e:	bce080e7          	jalr	-1074(ra) # 80005a38 <consputc>
  consputc('x');
    80005e72:	07800513          	li	a0,120
    80005e76:	00000097          	auipc	ra,0x0
    80005e7a:	bc2080e7          	jalr	-1086(ra) # 80005a38 <consputc>
    80005e7e:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80005e80:	03c95793          	srli	a5,s2,0x3c
    80005e84:	97da                	add	a5,a5,s6
    80005e86:	0007c503          	lbu	a0,0(a5)
    80005e8a:	00000097          	auipc	ra,0x0
    80005e8e:	bae080e7          	jalr	-1106(ra) # 80005a38 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80005e92:	0912                	slli	s2,s2,0x4
    80005e94:	34fd                	addiw	s1,s1,-1
    80005e96:	f4ed                	bnez	s1,80005e80 <printf+0x13a>
    80005e98:	b7a1                	j	80005de0 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80005e9a:	f8843783          	ld	a5,-120(s0)
    80005e9e:	00878713          	addi	a4,a5,8
    80005ea2:	f8e43423          	sd	a4,-120(s0)
    80005ea6:	6384                	ld	s1,0(a5)
    80005ea8:	cc89                	beqz	s1,80005ec2 <printf+0x17c>
      for(; *s; s++)
    80005eaa:	0004c503          	lbu	a0,0(s1)
    80005eae:	d90d                	beqz	a0,80005de0 <printf+0x9a>
        consputc(*s);
    80005eb0:	00000097          	auipc	ra,0x0
    80005eb4:	b88080e7          	jalr	-1144(ra) # 80005a38 <consputc>
      for(; *s; s++)
    80005eb8:	0485                	addi	s1,s1,1
    80005eba:	0004c503          	lbu	a0,0(s1)
    80005ebe:	f96d                	bnez	a0,80005eb0 <printf+0x16a>
    80005ec0:	b705                	j	80005de0 <printf+0x9a>
        s = "(null)";
    80005ec2:	00003497          	auipc	s1,0x3
    80005ec6:	92648493          	addi	s1,s1,-1754 # 800087e8 <syscalls+0x418>
      for(; *s; s++)
    80005eca:	02800513          	li	a0,40
    80005ece:	b7cd                	j	80005eb0 <printf+0x16a>
      consputc('%');
    80005ed0:	8556                	mv	a0,s5
    80005ed2:	00000097          	auipc	ra,0x0
    80005ed6:	b66080e7          	jalr	-1178(ra) # 80005a38 <consputc>
      break;
    80005eda:	b719                	j	80005de0 <printf+0x9a>
      consputc('%');
    80005edc:	8556                	mv	a0,s5
    80005ede:	00000097          	auipc	ra,0x0
    80005ee2:	b5a080e7          	jalr	-1190(ra) # 80005a38 <consputc>
      consputc(c);
    80005ee6:	8526                	mv	a0,s1
    80005ee8:	00000097          	auipc	ra,0x0
    80005eec:	b50080e7          	jalr	-1200(ra) # 80005a38 <consputc>
      break;
    80005ef0:	bdc5                	j	80005de0 <printf+0x9a>
  if(locking)
    80005ef2:	020d9163          	bnez	s11,80005f14 <printf+0x1ce>
}
    80005ef6:	70e6                	ld	ra,120(sp)
    80005ef8:	7446                	ld	s0,112(sp)
    80005efa:	74a6                	ld	s1,104(sp)
    80005efc:	7906                	ld	s2,96(sp)
    80005efe:	69e6                	ld	s3,88(sp)
    80005f00:	6a46                	ld	s4,80(sp)
    80005f02:	6aa6                	ld	s5,72(sp)
    80005f04:	6b06                	ld	s6,64(sp)
    80005f06:	7be2                	ld	s7,56(sp)
    80005f08:	7c42                	ld	s8,48(sp)
    80005f0a:	7ca2                	ld	s9,40(sp)
    80005f0c:	7d02                	ld	s10,32(sp)
    80005f0e:	6de2                	ld	s11,24(sp)
    80005f10:	6129                	addi	sp,sp,192
    80005f12:	8082                	ret
    release(&pr.lock);
    80005f14:	0001c517          	auipc	a0,0x1c
    80005f18:	60450513          	addi	a0,a0,1540 # 80022518 <pr>
    80005f1c:	00000097          	auipc	ra,0x0
    80005f20:	3cc080e7          	jalr	972(ra) # 800062e8 <release>
}
    80005f24:	bfc9                	j	80005ef6 <printf+0x1b0>

0000000080005f26 <printfinit>:
    ;
}

void
printfinit(void)
{
    80005f26:	1101                	addi	sp,sp,-32
    80005f28:	ec06                	sd	ra,24(sp)
    80005f2a:	e822                	sd	s0,16(sp)
    80005f2c:	e426                	sd	s1,8(sp)
    80005f2e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80005f30:	0001c497          	auipc	s1,0x1c
    80005f34:	5e848493          	addi	s1,s1,1512 # 80022518 <pr>
    80005f38:	00003597          	auipc	a1,0x3
    80005f3c:	8c858593          	addi	a1,a1,-1848 # 80008800 <syscalls+0x430>
    80005f40:	8526                	mv	a0,s1
    80005f42:	00000097          	auipc	ra,0x0
    80005f46:	262080e7          	jalr	610(ra) # 800061a4 <initlock>
  pr.locking = 1;
    80005f4a:	4785                	li	a5,1
    80005f4c:	cc9c                	sw	a5,24(s1)
}
    80005f4e:	60e2                	ld	ra,24(sp)
    80005f50:	6442                	ld	s0,16(sp)
    80005f52:	64a2                	ld	s1,8(sp)
    80005f54:	6105                	addi	sp,sp,32
    80005f56:	8082                	ret

0000000080005f58 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80005f58:	1141                	addi	sp,sp,-16
    80005f5a:	e406                	sd	ra,8(sp)
    80005f5c:	e022                	sd	s0,0(sp)
    80005f5e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80005f60:	100007b7          	lui	a5,0x10000
    80005f64:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80005f68:	f8000713          	li	a4,-128
    80005f6c:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80005f70:	470d                	li	a4,3
    80005f72:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80005f76:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80005f7a:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80005f7e:	469d                	li	a3,7
    80005f80:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80005f84:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80005f88:	00003597          	auipc	a1,0x3
    80005f8c:	89858593          	addi	a1,a1,-1896 # 80008820 <digits+0x18>
    80005f90:	0001c517          	auipc	a0,0x1c
    80005f94:	5a850513          	addi	a0,a0,1448 # 80022538 <uart_tx_lock>
    80005f98:	00000097          	auipc	ra,0x0
    80005f9c:	20c080e7          	jalr	524(ra) # 800061a4 <initlock>
}
    80005fa0:	60a2                	ld	ra,8(sp)
    80005fa2:	6402                	ld	s0,0(sp)
    80005fa4:	0141                	addi	sp,sp,16
    80005fa6:	8082                	ret

0000000080005fa8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80005fa8:	1101                	addi	sp,sp,-32
    80005faa:	ec06                	sd	ra,24(sp)
    80005fac:	e822                	sd	s0,16(sp)
    80005fae:	e426                	sd	s1,8(sp)
    80005fb0:	1000                	addi	s0,sp,32
    80005fb2:	84aa                	mv	s1,a0
  push_off();
    80005fb4:	00000097          	auipc	ra,0x0
    80005fb8:	234080e7          	jalr	564(ra) # 800061e8 <push_off>

  if(panicked){
    80005fbc:	00003797          	auipc	a5,0x3
    80005fc0:	9307a783          	lw	a5,-1744(a5) # 800088ec <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005fc4:	10000737          	lui	a4,0x10000
  if(panicked){
    80005fc8:	c391                	beqz	a5,80005fcc <uartputc_sync+0x24>
    for(;;)
    80005fca:	a001                	j	80005fca <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80005fcc:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80005fd0:	0207f793          	andi	a5,a5,32
    80005fd4:	dfe5                	beqz	a5,80005fcc <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80005fd6:	0ff4f513          	zext.b	a0,s1
    80005fda:	100007b7          	lui	a5,0x10000
    80005fde:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80005fe2:	00000097          	auipc	ra,0x0
    80005fe6:	2a6080e7          	jalr	678(ra) # 80006288 <pop_off>
}
    80005fea:	60e2                	ld	ra,24(sp)
    80005fec:	6442                	ld	s0,16(sp)
    80005fee:	64a2                	ld	s1,8(sp)
    80005ff0:	6105                	addi	sp,sp,32
    80005ff2:	8082                	ret

0000000080005ff4 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80005ff4:	00003797          	auipc	a5,0x3
    80005ff8:	8fc7b783          	ld	a5,-1796(a5) # 800088f0 <uart_tx_r>
    80005ffc:	00003717          	auipc	a4,0x3
    80006000:	8fc73703          	ld	a4,-1796(a4) # 800088f8 <uart_tx_w>
    80006004:	06f70a63          	beq	a4,a5,80006078 <uartstart+0x84>
{
    80006008:	7139                	addi	sp,sp,-64
    8000600a:	fc06                	sd	ra,56(sp)
    8000600c:	f822                	sd	s0,48(sp)
    8000600e:	f426                	sd	s1,40(sp)
    80006010:	f04a                	sd	s2,32(sp)
    80006012:	ec4e                	sd	s3,24(sp)
    80006014:	e852                	sd	s4,16(sp)
    80006016:	e456                	sd	s5,8(sp)
    80006018:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000601a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000601e:	0001ca17          	auipc	s4,0x1c
    80006022:	51aa0a13          	addi	s4,s4,1306 # 80022538 <uart_tx_lock>
    uart_tx_r += 1;
    80006026:	00003497          	auipc	s1,0x3
    8000602a:	8ca48493          	addi	s1,s1,-1846 # 800088f0 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000602e:	00003997          	auipc	s3,0x3
    80006032:	8ca98993          	addi	s3,s3,-1846 # 800088f8 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80006036:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000603a:	02077713          	andi	a4,a4,32
    8000603e:	c705                	beqz	a4,80006066 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80006040:	01f7f713          	andi	a4,a5,31
    80006044:	9752                	add	a4,a4,s4
    80006046:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000604a:	0785                	addi	a5,a5,1
    8000604c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000604e:	8526                	mv	a0,s1
    80006050:	ffffb097          	auipc	ra,0xffffb
    80006054:	51a080e7          	jalr	1306(ra) # 8000156a <wakeup>
    
    WriteReg(THR, c);
    80006058:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000605c:	609c                	ld	a5,0(s1)
    8000605e:	0009b703          	ld	a4,0(s3)
    80006062:	fcf71ae3          	bne	a4,a5,80006036 <uartstart+0x42>
  }
}
    80006066:	70e2                	ld	ra,56(sp)
    80006068:	7442                	ld	s0,48(sp)
    8000606a:	74a2                	ld	s1,40(sp)
    8000606c:	7902                	ld	s2,32(sp)
    8000606e:	69e2                	ld	s3,24(sp)
    80006070:	6a42                	ld	s4,16(sp)
    80006072:	6aa2                	ld	s5,8(sp)
    80006074:	6121                	addi	sp,sp,64
    80006076:	8082                	ret
    80006078:	8082                	ret

000000008000607a <uartputc>:
{
    8000607a:	7179                	addi	sp,sp,-48
    8000607c:	f406                	sd	ra,40(sp)
    8000607e:	f022                	sd	s0,32(sp)
    80006080:	ec26                	sd	s1,24(sp)
    80006082:	e84a                	sd	s2,16(sp)
    80006084:	e44e                	sd	s3,8(sp)
    80006086:	e052                	sd	s4,0(sp)
    80006088:	1800                	addi	s0,sp,48
    8000608a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000608c:	0001c517          	auipc	a0,0x1c
    80006090:	4ac50513          	addi	a0,a0,1196 # 80022538 <uart_tx_lock>
    80006094:	00000097          	auipc	ra,0x0
    80006098:	1a0080e7          	jalr	416(ra) # 80006234 <acquire>
  if(panicked){
    8000609c:	00003797          	auipc	a5,0x3
    800060a0:	8507a783          	lw	a5,-1968(a5) # 800088ec <panicked>
    800060a4:	e7c9                	bnez	a5,8000612e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800060a6:	00003717          	auipc	a4,0x3
    800060aa:	85273703          	ld	a4,-1966(a4) # 800088f8 <uart_tx_w>
    800060ae:	00003797          	auipc	a5,0x3
    800060b2:	8427b783          	ld	a5,-1982(a5) # 800088f0 <uart_tx_r>
    800060b6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800060ba:	0001c997          	auipc	s3,0x1c
    800060be:	47e98993          	addi	s3,s3,1150 # 80022538 <uart_tx_lock>
    800060c2:	00003497          	auipc	s1,0x3
    800060c6:	82e48493          	addi	s1,s1,-2002 # 800088f0 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800060ca:	00003917          	auipc	s2,0x3
    800060ce:	82e90913          	addi	s2,s2,-2002 # 800088f8 <uart_tx_w>
    800060d2:	00e79f63          	bne	a5,a4,800060f0 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    800060d6:	85ce                	mv	a1,s3
    800060d8:	8526                	mv	a0,s1
    800060da:	ffffb097          	auipc	ra,0xffffb
    800060de:	42c080e7          	jalr	1068(ra) # 80001506 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800060e2:	00093703          	ld	a4,0(s2)
    800060e6:	609c                	ld	a5,0(s1)
    800060e8:	02078793          	addi	a5,a5,32
    800060ec:	fee785e3          	beq	a5,a4,800060d6 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800060f0:	0001c497          	auipc	s1,0x1c
    800060f4:	44848493          	addi	s1,s1,1096 # 80022538 <uart_tx_lock>
    800060f8:	01f77793          	andi	a5,a4,31
    800060fc:	97a6                	add	a5,a5,s1
    800060fe:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80006102:	0705                	addi	a4,a4,1
    80006104:	00002797          	auipc	a5,0x2
    80006108:	7ee7ba23          	sd	a4,2036(a5) # 800088f8 <uart_tx_w>
  uartstart();
    8000610c:	00000097          	auipc	ra,0x0
    80006110:	ee8080e7          	jalr	-280(ra) # 80005ff4 <uartstart>
  release(&uart_tx_lock);
    80006114:	8526                	mv	a0,s1
    80006116:	00000097          	auipc	ra,0x0
    8000611a:	1d2080e7          	jalr	466(ra) # 800062e8 <release>
}
    8000611e:	70a2                	ld	ra,40(sp)
    80006120:	7402                	ld	s0,32(sp)
    80006122:	64e2                	ld	s1,24(sp)
    80006124:	6942                	ld	s2,16(sp)
    80006126:	69a2                	ld	s3,8(sp)
    80006128:	6a02                	ld	s4,0(sp)
    8000612a:	6145                	addi	sp,sp,48
    8000612c:	8082                	ret
    for(;;)
    8000612e:	a001                	j	8000612e <uartputc+0xb4>

0000000080006130 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80006130:	1141                	addi	sp,sp,-16
    80006132:	e422                	sd	s0,8(sp)
    80006134:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80006136:	100007b7          	lui	a5,0x10000
    8000613a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000613e:	8b85                	andi	a5,a5,1
    80006140:	cb81                	beqz	a5,80006150 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80006142:	100007b7          	lui	a5,0x10000
    80006146:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000614a:	6422                	ld	s0,8(sp)
    8000614c:	0141                	addi	sp,sp,16
    8000614e:	8082                	ret
    return -1;
    80006150:	557d                	li	a0,-1
    80006152:	bfe5                	j	8000614a <uartgetc+0x1a>

0000000080006154 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80006154:	1101                	addi	sp,sp,-32
    80006156:	ec06                	sd	ra,24(sp)
    80006158:	e822                	sd	s0,16(sp)
    8000615a:	e426                	sd	s1,8(sp)
    8000615c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000615e:	54fd                	li	s1,-1
    80006160:	a029                	j	8000616a <uartintr+0x16>
      break;
    consoleintr(c);
    80006162:	00000097          	auipc	ra,0x0
    80006166:	918080e7          	jalr	-1768(ra) # 80005a7a <consoleintr>
    int c = uartgetc();
    8000616a:	00000097          	auipc	ra,0x0
    8000616e:	fc6080e7          	jalr	-58(ra) # 80006130 <uartgetc>
    if(c == -1)
    80006172:	fe9518e3          	bne	a0,s1,80006162 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80006176:	0001c497          	auipc	s1,0x1c
    8000617a:	3c248493          	addi	s1,s1,962 # 80022538 <uart_tx_lock>
    8000617e:	8526                	mv	a0,s1
    80006180:	00000097          	auipc	ra,0x0
    80006184:	0b4080e7          	jalr	180(ra) # 80006234 <acquire>
  uartstart();
    80006188:	00000097          	auipc	ra,0x0
    8000618c:	e6c080e7          	jalr	-404(ra) # 80005ff4 <uartstart>
  release(&uart_tx_lock);
    80006190:	8526                	mv	a0,s1
    80006192:	00000097          	auipc	ra,0x0
    80006196:	156080e7          	jalr	342(ra) # 800062e8 <release>
}
    8000619a:	60e2                	ld	ra,24(sp)
    8000619c:	6442                	ld	s0,16(sp)
    8000619e:	64a2                	ld	s1,8(sp)
    800061a0:	6105                	addi	sp,sp,32
    800061a2:	8082                	ret

00000000800061a4 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    800061a4:	1141                	addi	sp,sp,-16
    800061a6:	e422                	sd	s0,8(sp)
    800061a8:	0800                	addi	s0,sp,16
  lk->name = name;
    800061aa:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    800061ac:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    800061b0:	00053823          	sd	zero,16(a0)
}
    800061b4:	6422                	ld	s0,8(sp)
    800061b6:	0141                	addi	sp,sp,16
    800061b8:	8082                	ret

00000000800061ba <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    800061ba:	411c                	lw	a5,0(a0)
    800061bc:	e399                	bnez	a5,800061c2 <holding+0x8>
    800061be:	4501                	li	a0,0
  return r;
}
    800061c0:	8082                	ret
{
    800061c2:	1101                	addi	sp,sp,-32
    800061c4:	ec06                	sd	ra,24(sp)
    800061c6:	e822                	sd	s0,16(sp)
    800061c8:	e426                	sd	s1,8(sp)
    800061ca:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    800061cc:	6904                	ld	s1,16(a0)
    800061ce:	ffffb097          	auipc	ra,0xffffb
    800061d2:	c6a080e7          	jalr	-918(ra) # 80000e38 <mycpu>
    800061d6:	40a48533          	sub	a0,s1,a0
    800061da:	00153513          	seqz	a0,a0
}
    800061de:	60e2                	ld	ra,24(sp)
    800061e0:	6442                	ld	s0,16(sp)
    800061e2:	64a2                	ld	s1,8(sp)
    800061e4:	6105                	addi	sp,sp,32
    800061e6:	8082                	ret

00000000800061e8 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800061e8:	1101                	addi	sp,sp,-32
    800061ea:	ec06                	sd	ra,24(sp)
    800061ec:	e822                	sd	s0,16(sp)
    800061ee:	e426                	sd	s1,8(sp)
    800061f0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800061f2:	100024f3          	csrr	s1,sstatus
    800061f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800061fa:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800061fc:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80006200:	ffffb097          	auipc	ra,0xffffb
    80006204:	c38080e7          	jalr	-968(ra) # 80000e38 <mycpu>
    80006208:	5d3c                	lw	a5,120(a0)
    8000620a:	cf89                	beqz	a5,80006224 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    8000620c:	ffffb097          	auipc	ra,0xffffb
    80006210:	c2c080e7          	jalr	-980(ra) # 80000e38 <mycpu>
    80006214:	5d3c                	lw	a5,120(a0)
    80006216:	2785                	addiw	a5,a5,1
    80006218:	dd3c                	sw	a5,120(a0)
}
    8000621a:	60e2                	ld	ra,24(sp)
    8000621c:	6442                	ld	s0,16(sp)
    8000621e:	64a2                	ld	s1,8(sp)
    80006220:	6105                	addi	sp,sp,32
    80006222:	8082                	ret
    mycpu()->intena = old;
    80006224:	ffffb097          	auipc	ra,0xffffb
    80006228:	c14080e7          	jalr	-1004(ra) # 80000e38 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    8000622c:	8085                	srli	s1,s1,0x1
    8000622e:	8885                	andi	s1,s1,1
    80006230:	dd64                	sw	s1,124(a0)
    80006232:	bfe9                	j	8000620c <push_off+0x24>

0000000080006234 <acquire>:
{
    80006234:	1101                	addi	sp,sp,-32
    80006236:	ec06                	sd	ra,24(sp)
    80006238:	e822                	sd	s0,16(sp)
    8000623a:	e426                	sd	s1,8(sp)
    8000623c:	1000                	addi	s0,sp,32
    8000623e:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80006240:	00000097          	auipc	ra,0x0
    80006244:	fa8080e7          	jalr	-88(ra) # 800061e8 <push_off>
  if(holding(lk))
    80006248:	8526                	mv	a0,s1
    8000624a:	00000097          	auipc	ra,0x0
    8000624e:	f70080e7          	jalr	-144(ra) # 800061ba <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80006252:	4705                	li	a4,1
  if(holding(lk))
    80006254:	e115                	bnez	a0,80006278 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80006256:	87ba                	mv	a5,a4
    80006258:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    8000625c:	2781                	sext.w	a5,a5
    8000625e:	ffe5                	bnez	a5,80006256 <acquire+0x22>
  __sync_synchronize();
    80006260:	0ff0000f          	fence
  lk->cpu = mycpu();
    80006264:	ffffb097          	auipc	ra,0xffffb
    80006268:	bd4080e7          	jalr	-1068(ra) # 80000e38 <mycpu>
    8000626c:	e888                	sd	a0,16(s1)
}
    8000626e:	60e2                	ld	ra,24(sp)
    80006270:	6442                	ld	s0,16(sp)
    80006272:	64a2                	ld	s1,8(sp)
    80006274:	6105                	addi	sp,sp,32
    80006276:	8082                	ret
    panic("acquire");
    80006278:	00002517          	auipc	a0,0x2
    8000627c:	5b050513          	addi	a0,a0,1456 # 80008828 <digits+0x20>
    80006280:	00000097          	auipc	ra,0x0
    80006284:	a7c080e7          	jalr	-1412(ra) # 80005cfc <panic>

0000000080006288 <pop_off>:

void
pop_off(void)
{
    80006288:	1141                	addi	sp,sp,-16
    8000628a:	e406                	sd	ra,8(sp)
    8000628c:	e022                	sd	s0,0(sp)
    8000628e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80006290:	ffffb097          	auipc	ra,0xffffb
    80006294:	ba8080e7          	jalr	-1112(ra) # 80000e38 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006298:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000629c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000629e:	e78d                	bnez	a5,800062c8 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    800062a0:	5d3c                	lw	a5,120(a0)
    800062a2:	02f05b63          	blez	a5,800062d8 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    800062a6:	37fd                	addiw	a5,a5,-1
    800062a8:	0007871b          	sext.w	a4,a5
    800062ac:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    800062ae:	eb09                	bnez	a4,800062c0 <pop_off+0x38>
    800062b0:	5d7c                	lw	a5,124(a0)
    800062b2:	c799                	beqz	a5,800062c0 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800062b4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800062b8:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800062bc:	10079073          	csrw	sstatus,a5
    intr_on();
}
    800062c0:	60a2                	ld	ra,8(sp)
    800062c2:	6402                	ld	s0,0(sp)
    800062c4:	0141                	addi	sp,sp,16
    800062c6:	8082                	ret
    panic("pop_off - interruptible");
    800062c8:	00002517          	auipc	a0,0x2
    800062cc:	56850513          	addi	a0,a0,1384 # 80008830 <digits+0x28>
    800062d0:	00000097          	auipc	ra,0x0
    800062d4:	a2c080e7          	jalr	-1492(ra) # 80005cfc <panic>
    panic("pop_off");
    800062d8:	00002517          	auipc	a0,0x2
    800062dc:	57050513          	addi	a0,a0,1392 # 80008848 <digits+0x40>
    800062e0:	00000097          	auipc	ra,0x0
    800062e4:	a1c080e7          	jalr	-1508(ra) # 80005cfc <panic>

00000000800062e8 <release>:
{
    800062e8:	1101                	addi	sp,sp,-32
    800062ea:	ec06                	sd	ra,24(sp)
    800062ec:	e822                	sd	s0,16(sp)
    800062ee:	e426                	sd	s1,8(sp)
    800062f0:	1000                	addi	s0,sp,32
    800062f2:	84aa                	mv	s1,a0
  if(!holding(lk))
    800062f4:	00000097          	auipc	ra,0x0
    800062f8:	ec6080e7          	jalr	-314(ra) # 800061ba <holding>
    800062fc:	c115                	beqz	a0,80006320 <release+0x38>
  lk->cpu = 0;
    800062fe:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80006302:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80006306:	0f50000f          	fence	iorw,ow
    8000630a:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    8000630e:	00000097          	auipc	ra,0x0
    80006312:	f7a080e7          	jalr	-134(ra) # 80006288 <pop_off>
}
    80006316:	60e2                	ld	ra,24(sp)
    80006318:	6442                	ld	s0,16(sp)
    8000631a:	64a2                	ld	s1,8(sp)
    8000631c:	6105                	addi	sp,sp,32
    8000631e:	8082                	ret
    panic("release");
    80006320:	00002517          	auipc	a0,0x2
    80006324:	53050513          	addi	a0,a0,1328 # 80008850 <digits+0x48>
    80006328:	00000097          	auipc	ra,0x0
    8000632c:	9d4080e7          	jalr	-1580(ra) # 80005cfc <panic>
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
