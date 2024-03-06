
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	8d013103          	ld	sp,-1840(sp) # 800088d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	2b7050ef          	jal	ra,80005acc <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <init_page_ref>:
  int count[PGROUNDUP(PHYSTOP)>>12]; //2^12 == 4096, aka 4k bytes aka size of page.
}page_ref;

//function to initialize page reference tracking for COW
void 
init_page_ref(){
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
  //initialize lock for the page ref sys
  initlock(&page_ref.lock, "page_ref");
    80000024:	00008597          	auipc	a1,0x8
    80000028:	fec58593          	addi	a1,a1,-20 # 80008010 <etext+0x10>
    8000002c:	00009517          	auipc	a0,0x9
    80000030:	91450513          	addi	a0,a0,-1772 # 80008940 <page_ref>
    80000034:	00006097          	auipc	ra,0x6
    80000038:	408080e7          	jalr	1032(ra) # 8000643c <initlock>
  //free the lock before modifying
  acquire(&page_ref.lock);
    8000003c:	00009517          	auipc	a0,0x9
    80000040:	90450513          	addi	a0,a0,-1788 # 80008940 <page_ref>
    80000044:	00006097          	auipc	ra,0x6
    80000048:	488080e7          	jalr	1160(ra) # 800064cc <acquire>

//loop through every page (4K), set the reference count to 0
  for(int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); i++){
    8000004c:	00009797          	auipc	a5,0x9
    80000050:	90c78793          	addi	a5,a5,-1780 # 80008958 <page_ref+0x18>
    80000054:	00229717          	auipc	a4,0x229
    80000058:	90470713          	addi	a4,a4,-1788 # 80228958 <pid_lock>
    page_ref.count[i] = 0;
    8000005c:	0007a023          	sw	zero,0(a5)
  for(int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); i++){
    80000060:	0791                	addi	a5,a5,4
    80000062:	fee79de3          	bne	a5,a4,8000005c <init_page_ref+0x40>
  }
  //release the lock
  release(&page_ref.lock);
    80000066:	00009517          	auipc	a0,0x9
    8000006a:	8da50513          	addi	a0,a0,-1830 # 80008940 <page_ref>
    8000006e:	00006097          	auipc	ra,0x6
    80000072:	512080e7          	jalr	1298(ra) # 80006580 <release>
}
    80000076:	60a2                	ld	ra,8(sp)
    80000078:	6402                	ld	s0,0(sp)
    8000007a:	0141                	addi	sp,sp,16
    8000007c:	8082                	ret

000000008000007e <inc_page_ref>:
//when fork is called, instead of all pages being copied,
//the original processes pages are shared by Proc A and B, and 
//we use this reference incrementer to keep track of how many
//procs are pointing to a given page.
void 
inc_page_ref(void *pa){
    8000007e:	1101                	addi	sp,sp,-32
    80000080:	ec06                	sd	ra,24(sp)
    80000082:	e822                	sd	s0,16(sp)
    80000084:	e426                	sd	s1,8(sp)
    80000086:	1000                	addi	s0,sp,32
    80000088:	84aa                	mv	s1,a0
  //free the lock before modifying
  acquire(&page_ref.lock);
    8000008a:	00009517          	auipc	a0,0x9
    8000008e:	8b650513          	addi	a0,a0,-1866 # 80008940 <page_ref>
    80000092:	00006097          	auipc	ra,0x6
    80000096:	43a080e7          	jalr	1082(ra) # 800064cc <acquire>
 //if count is zero, memory mismanaged.
 //indexing the array of references by dividing the 
 //physical address by 12 (2^12==4096bytes aka size of a page)
  if(page_ref.count[(uint64)pa >> 12] <= 0){
    8000009a:	00c4d793          	srli	a5,s1,0xc
    8000009e:	00478713          	addi	a4,a5,4
    800000a2:	00271693          	slli	a3,a4,0x2
    800000a6:	00009717          	auipc	a4,0x9
    800000aa:	89a70713          	addi	a4,a4,-1894 # 80008940 <page_ref>
    800000ae:	9736                	add	a4,a4,a3
    800000b0:	4718                	lw	a4,8(a4)
    800000b2:	02e05463          	blez	a4,800000da <inc_page_ref+0x5c>
    panic("inc_page_ref");
  }
  //increment ref count by 1
  page_ref.count[(uint64)pa >> 12] += 1;
    800000b6:	00009517          	auipc	a0,0x9
    800000ba:	88a50513          	addi	a0,a0,-1910 # 80008940 <page_ref>
    800000be:	0791                	addi	a5,a5,4
    800000c0:	078a                	slli	a5,a5,0x2
    800000c2:	97aa                	add	a5,a5,a0
    800000c4:	2705                	addiw	a4,a4,1
    800000c6:	c798                	sw	a4,8(a5)
  //release lock
   release(&page_ref.lock);
    800000c8:	00006097          	auipc	ra,0x6
    800000cc:	4b8080e7          	jalr	1208(ra) # 80006580 <release>
}
    800000d0:	60e2                	ld	ra,24(sp)
    800000d2:	6442                	ld	s0,16(sp)
    800000d4:	64a2                	ld	s1,8(sp)
    800000d6:	6105                	addi	sp,sp,32
    800000d8:	8082                	ret
    panic("inc_page_ref");
    800000da:	00008517          	auipc	a0,0x8
    800000de:	f4650513          	addi	a0,a0,-186 # 80008020 <etext+0x20>
    800000e2:	00006097          	auipc	ra,0x6
    800000e6:	ea0080e7          	jalr	-352(ra) # 80005f82 <panic>

00000000800000ea <dec_page_ref>:

//when COW copies a page for a process, need to update 
// the reference count from the original page that was being pointed to from
//both processes.
void 
dec_page_ref(void *pa){
    800000ea:	1101                	addi	sp,sp,-32
    800000ec:	ec06                	sd	ra,24(sp)
    800000ee:	e822                	sd	s0,16(sp)
    800000f0:	e426                	sd	s1,8(sp)
    800000f2:	1000                	addi	s0,sp,32
    800000f4:	84aa                	mv	s1,a0
 acquire(&page_ref.lock);
    800000f6:	00009517          	auipc	a0,0x9
    800000fa:	84a50513          	addi	a0,a0,-1974 # 80008940 <page_ref>
    800000fe:	00006097          	auipc	ra,0x6
    80000102:	3ce080e7          	jalr	974(ra) # 800064cc <acquire>
 //if count is zero, memory mismanaged.
 //indexing the array of references by dividing the 
 //physical address by 12 (2^12==4096bytes aka size of a page)
 if(page_ref.count[(uint64) pa >> 12] <= 0){
    80000106:	00c4d793          	srli	a5,s1,0xc
    8000010a:	00478713          	addi	a4,a5,4
    8000010e:	00271693          	slli	a3,a4,0x2
    80000112:	00009717          	auipc	a4,0x9
    80000116:	82e70713          	addi	a4,a4,-2002 # 80008940 <page_ref>
    8000011a:	9736                	add	a4,a4,a3
    8000011c:	4718                	lw	a4,8(a4)
    8000011e:	02e05463          	blez	a4,80000146 <dec_page_ref+0x5c>
  panic("dec_page_ref");
 }
//decrement reference count
 page_ref.count[(uint64)pa >> 12] -= 1;
    80000122:	00009517          	auipc	a0,0x9
    80000126:	81e50513          	addi	a0,a0,-2018 # 80008940 <page_ref>
    8000012a:	0791                	addi	a5,a5,4
    8000012c:	078a                	slli	a5,a5,0x2
    8000012e:	97aa                	add	a5,a5,a0
    80000130:	377d                	addiw	a4,a4,-1
    80000132:	c798                	sw	a4,8(a5)
 release(&page_ref.lock);
    80000134:	00006097          	auipc	ra,0x6
    80000138:	44c080e7          	jalr	1100(ra) # 80006580 <release>
}
    8000013c:	60e2                	ld	ra,24(sp)
    8000013e:	6442                	ld	s0,16(sp)
    80000140:	64a2                	ld	s1,8(sp)
    80000142:	6105                	addi	sp,sp,32
    80000144:	8082                	ret
  panic("dec_page_ref");
    80000146:	00008517          	auipc	a0,0x8
    8000014a:	eea50513          	addi	a0,a0,-278 # 80008030 <etext+0x30>
    8000014e:	00006097          	auipc	ra,0x6
    80000152:	e34080e7          	jalr	-460(ra) # 80005f82 <panic>

0000000080000156 <get_page_ref>:

//return the reference count of a page,
//includes error checking if memory was mismanaged
//
int 
get_page_ref(void *pa){
    80000156:	1101                	addi	sp,sp,-32
    80000158:	ec06                	sd	ra,24(sp)
    8000015a:	e822                	sd	s0,16(sp)
    8000015c:	e426                	sd	s1,8(sp)
    8000015e:	1000                	addi	s0,sp,32
    80000160:	84aa                	mv	s1,a0
  //acquire lock
  acquire(&page_ref.lock);
    80000162:	00008517          	auipc	a0,0x8
    80000166:	7de50513          	addi	a0,a0,2014 # 80008940 <page_ref>
    8000016a:	00006097          	auipc	ra,0x6
    8000016e:	362080e7          	jalr	866(ra) # 800064cc <acquire>
  int res = page_ref.count[(uint64)pa>>12]; //storing ref count
    80000172:	80b1                	srli	s1,s1,0xc
    80000174:	0491                	addi	s1,s1,4
    80000176:	048a                	slli	s1,s1,0x2
    80000178:	00008797          	auipc	a5,0x8
    8000017c:	7c878793          	addi	a5,a5,1992 # 80008940 <page_ref>
    80000180:	94be                	add	s1,s1,a5
    80000182:	4484                	lw	s1,8(s1)
  if(page_ref.count[(uint64)pa>>12]<0){
    80000184:	0204c063          	bltz	s1,800001a4 <get_page_ref+0x4e>
    panic("get_page_ref");
  }
  release(&page_ref.lock); //release lock
    80000188:	00008517          	auipc	a0,0x8
    8000018c:	7b850513          	addi	a0,a0,1976 # 80008940 <page_ref>
    80000190:	00006097          	auipc	ra,0x6
    80000194:	3f0080e7          	jalr	1008(ra) # 80006580 <release>
  return res; //page ref count
}
    80000198:	8526                	mv	a0,s1
    8000019a:	60e2                	ld	ra,24(sp)
    8000019c:	6442                	ld	s0,16(sp)
    8000019e:	64a2                	ld	s1,8(sp)
    800001a0:	6105                	addi	sp,sp,32
    800001a2:	8082                	ret
    panic("get_page_ref");
    800001a4:	00008517          	auipc	a0,0x8
    800001a8:	e9c50513          	addi	a0,a0,-356 # 80008040 <etext+0x40>
    800001ac:	00006097          	auipc	ra,0x6
    800001b0:	dd6080e7          	jalr	-554(ra) # 80005f82 <panic>

00000000800001b4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800001b4:	1101                	addi	sp,sp,-32
    800001b6:	ec06                	sd	ra,24(sp)
    800001b8:	e822                	sd	s0,16(sp)
    800001ba:	e426                	sd	s1,8(sp)
    800001bc:	e04a                	sd	s2,0(sp)
    800001be:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800001c0:	03451793          	slli	a5,a0,0x34
    800001c4:	e7dd                	bnez	a5,80000272 <kfree+0xbe>
    800001c6:	84aa                	mv	s1,a0
    800001c8:	00242797          	auipc	a5,0x242
    800001cc:	be878793          	addi	a5,a5,-1048 # 80241db0 <end>
    800001d0:	0af56163          	bltu	a0,a5,80000272 <kfree+0xbe>
    800001d4:	47c5                	li	a5,17
    800001d6:	07ee                	slli	a5,a5,0x1b
    800001d8:	08f57d63          	bgeu	a0,a5,80000272 <kfree+0xbe>
    panic("kfree");

  acquire(&page_ref.lock);
    800001dc:	00008517          	auipc	a0,0x8
    800001e0:	76450513          	addi	a0,a0,1892 # 80008940 <page_ref>
    800001e4:	00006097          	auipc	ra,0x6
    800001e8:	2e8080e7          	jalr	744(ra) # 800064cc <acquire>
  //check if ref count is already zero
  if(page_ref.count[(uint64)pa>>12]<=0){
    800001ec:	00c4d793          	srli	a5,s1,0xc
    800001f0:	00478713          	addi	a4,a5,4
    800001f4:	00271693          	slli	a3,a4,0x2
    800001f8:	00008717          	auipc	a4,0x8
    800001fc:	74870713          	addi	a4,a4,1864 # 80008940 <page_ref>
    80000200:	9736                	add	a4,a4,a3
    80000202:	4718                	lw	a4,8(a4)
    80000204:	06e05f63          	blez	a4,80000282 <kfree+0xce>
    panic("dec_page_ref");
  }
  //decrement ref count
  page_ref.count[(uint64)pa>>12]-=1;
    80000208:	377d                	addiw	a4,a4,-1
    8000020a:	0007061b          	sext.w	a2,a4
    8000020e:	0791                	addi	a5,a5,4
    80000210:	078a                	slli	a5,a5,0x2
    80000212:	00008697          	auipc	a3,0x8
    80000216:	72e68693          	addi	a3,a3,1838 # 80008940 <page_ref>
    8000021a:	97b6                	add	a5,a5,a3
    8000021c:	c798                	sw	a4,8(a5)
  if(page_ref.count[(uint64)pa>>12]>0){
    8000021e:	06c04a63          	bgtz	a2,80000292 <kfree+0xde>
    release(&page_ref.lock);
    return;
  }
  release(&page_ref.lock);
    80000222:	00008517          	auipc	a0,0x8
    80000226:	71e50513          	addi	a0,a0,1822 # 80008940 <page_ref>
    8000022a:	00006097          	auipc	ra,0x6
    8000022e:	356080e7          	jalr	854(ra) # 80006580 <release>
  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000232:	6605                	lui	a2,0x1
    80000234:	4585                	li	a1,1
    80000236:	8526                	mv	a0,s1
    80000238:	00000097          	auipc	ra,0x0
    8000023c:	164080e7          	jalr	356(ra) # 8000039c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000240:	00008917          	auipc	s2,0x8
    80000244:	6e090913          	addi	s2,s2,1760 # 80008920 <kmem>
    80000248:	854a                	mv	a0,s2
    8000024a:	00006097          	auipc	ra,0x6
    8000024e:	282080e7          	jalr	642(ra) # 800064cc <acquire>
  r->next = kmem.freelist;
    80000252:	01893783          	ld	a5,24(s2)
    80000256:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000258:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000025c:	854a                	mv	a0,s2
    8000025e:	00006097          	auipc	ra,0x6
    80000262:	322080e7          	jalr	802(ra) # 80006580 <release>
}
    80000266:	60e2                	ld	ra,24(sp)
    80000268:	6442                	ld	s0,16(sp)
    8000026a:	64a2                	ld	s1,8(sp)
    8000026c:	6902                	ld	s2,0(sp)
    8000026e:	6105                	addi	sp,sp,32
    80000270:	8082                	ret
    panic("kfree");
    80000272:	00008517          	auipc	a0,0x8
    80000276:	dde50513          	addi	a0,a0,-546 # 80008050 <etext+0x50>
    8000027a:	00006097          	auipc	ra,0x6
    8000027e:	d08080e7          	jalr	-760(ra) # 80005f82 <panic>
    panic("dec_page_ref");
    80000282:	00008517          	auipc	a0,0x8
    80000286:	dae50513          	addi	a0,a0,-594 # 80008030 <etext+0x30>
    8000028a:	00006097          	auipc	ra,0x6
    8000028e:	cf8080e7          	jalr	-776(ra) # 80005f82 <panic>
    release(&page_ref.lock);
    80000292:	8536                	mv	a0,a3
    80000294:	00006097          	auipc	ra,0x6
    80000298:	2ec080e7          	jalr	748(ra) # 80006580 <release>
    return;
    8000029c:	b7e9                	j	80000266 <kfree+0xb2>

000000008000029e <freerange>:
{
    8000029e:	7139                	addi	sp,sp,-64
    800002a0:	fc06                	sd	ra,56(sp)
    800002a2:	f822                	sd	s0,48(sp)
    800002a4:	f426                	sd	s1,40(sp)
    800002a6:	f04a                	sd	s2,32(sp)
    800002a8:	ec4e                	sd	s3,24(sp)
    800002aa:	e852                	sd	s4,16(sp)
    800002ac:	e456                	sd	s5,8(sp)
    800002ae:	0080                	addi	s0,sp,64
  p = (char*)PGROUNDUP((uint64)pa_start);
    800002b0:	6785                	lui	a5,0x1
    800002b2:	fff78493          	addi	s1,a5,-1 # fff <_entry-0x7ffff001>
    800002b6:	94aa                	add	s1,s1,a0
    800002b8:	757d                	lui	a0,0xfffff
    800002ba:	8ce9                	and	s1,s1,a0
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    800002bc:	94be                	add	s1,s1,a5
    800002be:	0295e463          	bltu	a1,s1,800002e6 <freerange+0x48>
    800002c2:	89ae                	mv	s3,a1
    800002c4:	7afd                	lui	s5,0xfffff
    800002c6:	6a05                	lui	s4,0x1
    800002c8:	01548933          	add	s2,s1,s5
    inc_page_ref(p);
    800002cc:	854a                	mv	a0,s2
    800002ce:	00000097          	auipc	ra,0x0
    800002d2:	db0080e7          	jalr	-592(ra) # 8000007e <inc_page_ref>
    kfree(p);
    800002d6:	854a                	mv	a0,s2
    800002d8:	00000097          	auipc	ra,0x0
    800002dc:	edc080e7          	jalr	-292(ra) # 800001b4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    800002e0:	94d2                	add	s1,s1,s4
    800002e2:	fe99f3e3          	bgeu	s3,s1,800002c8 <freerange+0x2a>
}
    800002e6:	70e2                	ld	ra,56(sp)
    800002e8:	7442                	ld	s0,48(sp)
    800002ea:	74a2                	ld	s1,40(sp)
    800002ec:	7902                	ld	s2,32(sp)
    800002ee:	69e2                	ld	s3,24(sp)
    800002f0:	6a42                	ld	s4,16(sp)
    800002f2:	6aa2                	ld	s5,8(sp)
    800002f4:	6121                	addi	sp,sp,64
    800002f6:	8082                	ret

00000000800002f8 <kinit>:
{
    800002f8:	1141                	addi	sp,sp,-16
    800002fa:	e406                	sd	ra,8(sp)
    800002fc:	e022                	sd	s0,0(sp)
    800002fe:	0800                	addi	s0,sp,16
  init_page_ref();
    80000300:	00000097          	auipc	ra,0x0
    80000304:	d1c080e7          	jalr	-740(ra) # 8000001c <init_page_ref>
  initlock(&kmem.lock, "kmem");
    80000308:	00008597          	auipc	a1,0x8
    8000030c:	d5058593          	addi	a1,a1,-688 # 80008058 <etext+0x58>
    80000310:	00008517          	auipc	a0,0x8
    80000314:	61050513          	addi	a0,a0,1552 # 80008920 <kmem>
    80000318:	00006097          	auipc	ra,0x6
    8000031c:	124080e7          	jalr	292(ra) # 8000643c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000320:	45c5                	li	a1,17
    80000322:	05ee                	slli	a1,a1,0x1b
    80000324:	00242517          	auipc	a0,0x242
    80000328:	a8c50513          	addi	a0,a0,-1396 # 80241db0 <end>
    8000032c:	00000097          	auipc	ra,0x0
    80000330:	f72080e7          	jalr	-142(ra) # 8000029e <freerange>
}
    80000334:	60a2                	ld	ra,8(sp)
    80000336:	6402                	ld	s0,0(sp)
    80000338:	0141                	addi	sp,sp,16
    8000033a:	8082                	ret

000000008000033c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    8000033c:	1101                	addi	sp,sp,-32
    8000033e:	ec06                	sd	ra,24(sp)
    80000340:	e822                	sd	s0,16(sp)
    80000342:	e426                	sd	s1,8(sp)
    80000344:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000346:	00008497          	auipc	s1,0x8
    8000034a:	5da48493          	addi	s1,s1,1498 # 80008920 <kmem>
    8000034e:	8526                	mv	a0,s1
    80000350:	00006097          	auipc	ra,0x6
    80000354:	17c080e7          	jalr	380(ra) # 800064cc <acquire>
  r = kmem.freelist;
    80000358:	6c84                	ld	s1,24(s1)
  if(r)
    8000035a:	c885                	beqz	s1,8000038a <kalloc+0x4e>
    kmem.freelist = r->next;
    8000035c:	609c                	ld	a5,0(s1)
    8000035e:	00008517          	auipc	a0,0x8
    80000362:	5c250513          	addi	a0,a0,1474 # 80008920 <kmem>
    80000366:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000368:	00006097          	auipc	ra,0x6
    8000036c:	218080e7          	jalr	536(ra) # 80006580 <release>

  if(r){
        memset((char*)r, 5, PGSIZE); // fill with junk
    80000370:	6605                	lui	a2,0x1
    80000372:	4595                	li	a1,5
    80000374:	8526                	mv	a0,s1
    80000376:	00000097          	auipc	ra,0x0
    8000037a:	026080e7          	jalr	38(ra) # 8000039c <memset>
  }
  return (void*)r;
}
    8000037e:	8526                	mv	a0,s1
    80000380:	60e2                	ld	ra,24(sp)
    80000382:	6442                	ld	s0,16(sp)
    80000384:	64a2                	ld	s1,8(sp)
    80000386:	6105                	addi	sp,sp,32
    80000388:	8082                	ret
  release(&kmem.lock);
    8000038a:	00008517          	auipc	a0,0x8
    8000038e:	59650513          	addi	a0,a0,1430 # 80008920 <kmem>
    80000392:	00006097          	auipc	ra,0x6
    80000396:	1ee080e7          	jalr	494(ra) # 80006580 <release>
  if(r){
    8000039a:	b7d5                	j	8000037e <kalloc+0x42>

000000008000039c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000039c:	1141                	addi	sp,sp,-16
    8000039e:	e422                	sd	s0,8(sp)
    800003a0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    800003a2:	ce09                	beqz	a2,800003bc <memset+0x20>
    800003a4:	87aa                	mv	a5,a0
    800003a6:	fff6071b          	addiw	a4,a2,-1
    800003aa:	1702                	slli	a4,a4,0x20
    800003ac:	9301                	srli	a4,a4,0x20
    800003ae:	0705                	addi	a4,a4,1
    800003b0:	972a                	add	a4,a4,a0
    cdst[i] = c;
    800003b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    800003b6:	0785                	addi	a5,a5,1
    800003b8:	fee79de3          	bne	a5,a4,800003b2 <memset+0x16>
  }
  return dst;
}
    800003bc:	6422                	ld	s0,8(sp)
    800003be:	0141                	addi	sp,sp,16
    800003c0:	8082                	ret

00000000800003c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800003c2:	1141                	addi	sp,sp,-16
    800003c4:	e422                	sd	s0,8(sp)
    800003c6:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800003c8:	ca05                	beqz	a2,800003f8 <memcmp+0x36>
    800003ca:	fff6069b          	addiw	a3,a2,-1
    800003ce:	1682                	slli	a3,a3,0x20
    800003d0:	9281                	srli	a3,a3,0x20
    800003d2:	0685                	addi	a3,a3,1
    800003d4:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    800003d6:	00054783          	lbu	a5,0(a0)
    800003da:	0005c703          	lbu	a4,0(a1)
    800003de:	00e79863          	bne	a5,a4,800003ee <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    800003e2:	0505                	addi	a0,a0,1
    800003e4:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800003e6:	fed518e3          	bne	a0,a3,800003d6 <memcmp+0x14>
  }

  return 0;
    800003ea:	4501                	li	a0,0
    800003ec:	a019                	j	800003f2 <memcmp+0x30>
      return *s1 - *s2;
    800003ee:	40e7853b          	subw	a0,a5,a4
}
    800003f2:	6422                	ld	s0,8(sp)
    800003f4:	0141                	addi	sp,sp,16
    800003f6:	8082                	ret
  return 0;
    800003f8:	4501                	li	a0,0
    800003fa:	bfe5                	j	800003f2 <memcmp+0x30>

00000000800003fc <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800003fc:	1141                	addi	sp,sp,-16
    800003fe:	e422                	sd	s0,8(sp)
    80000400:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000402:	ca0d                	beqz	a2,80000434 <memmove+0x38>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000404:	00a5f963          	bgeu	a1,a0,80000416 <memmove+0x1a>
    80000408:	02061693          	slli	a3,a2,0x20
    8000040c:	9281                	srli	a3,a3,0x20
    8000040e:	00d58733          	add	a4,a1,a3
    80000412:	02e56463          	bltu	a0,a4,8000043a <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000416:	fff6079b          	addiw	a5,a2,-1
    8000041a:	1782                	slli	a5,a5,0x20
    8000041c:	9381                	srli	a5,a5,0x20
    8000041e:	0785                	addi	a5,a5,1
    80000420:	97ae                	add	a5,a5,a1
    80000422:	872a                	mv	a4,a0
      *d++ = *s++;
    80000424:	0585                	addi	a1,a1,1
    80000426:	0705                	addi	a4,a4,1
    80000428:	fff5c683          	lbu	a3,-1(a1)
    8000042c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000430:	fef59ae3          	bne	a1,a5,80000424 <memmove+0x28>

  return dst;
}
    80000434:	6422                	ld	s0,8(sp)
    80000436:	0141                	addi	sp,sp,16
    80000438:	8082                	ret
    d += n;
    8000043a:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    8000043c:	fff6079b          	addiw	a5,a2,-1
    80000440:	1782                	slli	a5,a5,0x20
    80000442:	9381                	srli	a5,a5,0x20
    80000444:	fff7c793          	not	a5,a5
    80000448:	97ba                	add	a5,a5,a4
      *--d = *--s;
    8000044a:	177d                	addi	a4,a4,-1
    8000044c:	16fd                	addi	a3,a3,-1
    8000044e:	00074603          	lbu	a2,0(a4)
    80000452:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000456:	fef71ae3          	bne	a4,a5,8000044a <memmove+0x4e>
    8000045a:	bfe9                	j	80000434 <memmove+0x38>

000000008000045c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000045c:	1141                	addi	sp,sp,-16
    8000045e:	e406                	sd	ra,8(sp)
    80000460:	e022                	sd	s0,0(sp)
    80000462:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000464:	00000097          	auipc	ra,0x0
    80000468:	f98080e7          	jalr	-104(ra) # 800003fc <memmove>
}
    8000046c:	60a2                	ld	ra,8(sp)
    8000046e:	6402                	ld	s0,0(sp)
    80000470:	0141                	addi	sp,sp,16
    80000472:	8082                	ret

0000000080000474 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000474:	1141                	addi	sp,sp,-16
    80000476:	e422                	sd	s0,8(sp)
    80000478:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    8000047a:	ce11                	beqz	a2,80000496 <strncmp+0x22>
    8000047c:	00054783          	lbu	a5,0(a0)
    80000480:	cf89                	beqz	a5,8000049a <strncmp+0x26>
    80000482:	0005c703          	lbu	a4,0(a1)
    80000486:	00f71a63          	bne	a4,a5,8000049a <strncmp+0x26>
    n--, p++, q++;
    8000048a:	367d                	addiw	a2,a2,-1
    8000048c:	0505                	addi	a0,a0,1
    8000048e:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000490:	f675                	bnez	a2,8000047c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000492:	4501                	li	a0,0
    80000494:	a809                	j	800004a6 <strncmp+0x32>
    80000496:	4501                	li	a0,0
    80000498:	a039                	j	800004a6 <strncmp+0x32>
  if(n == 0)
    8000049a:	ca09                	beqz	a2,800004ac <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    8000049c:	00054503          	lbu	a0,0(a0)
    800004a0:	0005c783          	lbu	a5,0(a1)
    800004a4:	9d1d                	subw	a0,a0,a5
}
    800004a6:	6422                	ld	s0,8(sp)
    800004a8:	0141                	addi	sp,sp,16
    800004aa:	8082                	ret
    return 0;
    800004ac:	4501                	li	a0,0
    800004ae:	bfe5                	j	800004a6 <strncmp+0x32>

00000000800004b0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800004b0:	1141                	addi	sp,sp,-16
    800004b2:	e422                	sd	s0,8(sp)
    800004b4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800004b6:	872a                	mv	a4,a0
    800004b8:	8832                	mv	a6,a2
    800004ba:	367d                	addiw	a2,a2,-1
    800004bc:	01005963          	blez	a6,800004ce <strncpy+0x1e>
    800004c0:	0705                	addi	a4,a4,1
    800004c2:	0005c783          	lbu	a5,0(a1)
    800004c6:	fef70fa3          	sb	a5,-1(a4)
    800004ca:	0585                	addi	a1,a1,1
    800004cc:	f7f5                	bnez	a5,800004b8 <strncpy+0x8>
    ;
  while(n-- > 0)
    800004ce:	00c05d63          	blez	a2,800004e8 <strncpy+0x38>
    800004d2:	86ba                	mv	a3,a4
    *s++ = 0;
    800004d4:	0685                	addi	a3,a3,1
    800004d6:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800004da:	fff6c793          	not	a5,a3
    800004de:	9fb9                	addw	a5,a5,a4
    800004e0:	010787bb          	addw	a5,a5,a6
    800004e4:	fef048e3          	bgtz	a5,800004d4 <strncpy+0x24>
  return os;
}
    800004e8:	6422                	ld	s0,8(sp)
    800004ea:	0141                	addi	sp,sp,16
    800004ec:	8082                	ret

00000000800004ee <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800004ee:	1141                	addi	sp,sp,-16
    800004f0:	e422                	sd	s0,8(sp)
    800004f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800004f4:	02c05363          	blez	a2,8000051a <safestrcpy+0x2c>
    800004f8:	fff6069b          	addiw	a3,a2,-1
    800004fc:	1682                	slli	a3,a3,0x20
    800004fe:	9281                	srli	a3,a3,0x20
    80000500:	96ae                	add	a3,a3,a1
    80000502:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000504:	00d58963          	beq	a1,a3,80000516 <safestrcpy+0x28>
    80000508:	0585                	addi	a1,a1,1
    8000050a:	0785                	addi	a5,a5,1
    8000050c:	fff5c703          	lbu	a4,-1(a1)
    80000510:	fee78fa3          	sb	a4,-1(a5)
    80000514:	fb65                	bnez	a4,80000504 <safestrcpy+0x16>
    ;
  *s = 0;
    80000516:	00078023          	sb	zero,0(a5)
  return os;
}
    8000051a:	6422                	ld	s0,8(sp)
    8000051c:	0141                	addi	sp,sp,16
    8000051e:	8082                	ret

0000000080000520 <strlen>:

int
strlen(const char *s)
{
    80000520:	1141                	addi	sp,sp,-16
    80000522:	e422                	sd	s0,8(sp)
    80000524:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000526:	00054783          	lbu	a5,0(a0)
    8000052a:	cf91                	beqz	a5,80000546 <strlen+0x26>
    8000052c:	0505                	addi	a0,a0,1
    8000052e:	87aa                	mv	a5,a0
    80000530:	4685                	li	a3,1
    80000532:	9e89                	subw	a3,a3,a0
    80000534:	00f6853b          	addw	a0,a3,a5
    80000538:	0785                	addi	a5,a5,1
    8000053a:	fff7c703          	lbu	a4,-1(a5)
    8000053e:	fb7d                	bnez	a4,80000534 <strlen+0x14>
    ;
  return n;
}
    80000540:	6422                	ld	s0,8(sp)
    80000542:	0141                	addi	sp,sp,16
    80000544:	8082                	ret
  for(n = 0; s[n]; n++)
    80000546:	4501                	li	a0,0
    80000548:	bfe5                	j	80000540 <strlen+0x20>

000000008000054a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    8000054a:	1141                	addi	sp,sp,-16
    8000054c:	e406                	sd	ra,8(sp)
    8000054e:	e022                	sd	s0,0(sp)
    80000550:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000552:	00001097          	auipc	ra,0x1
    80000556:	b8c080e7          	jalr	-1140(ra) # 800010de <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    8000055a:	00008717          	auipc	a4,0x8
    8000055e:	39670713          	addi	a4,a4,918 # 800088f0 <started>
  if(cpuid() == 0){
    80000562:	c139                	beqz	a0,800005a8 <main+0x5e>
    while(started == 0)
    80000564:	431c                	lw	a5,0(a4)
    80000566:	2781                	sext.w	a5,a5
    80000568:	dff5                	beqz	a5,80000564 <main+0x1a>
      ;
    __sync_synchronize();
    8000056a:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000056e:	00001097          	auipc	ra,0x1
    80000572:	b70080e7          	jalr	-1168(ra) # 800010de <cpuid>
    80000576:	85aa                	mv	a1,a0
    80000578:	00008517          	auipc	a0,0x8
    8000057c:	b0050513          	addi	a0,a0,-1280 # 80008078 <etext+0x78>
    80000580:	00006097          	auipc	ra,0x6
    80000584:	a4c080e7          	jalr	-1460(ra) # 80005fcc <printf>
    kvminithart();    // turn on paging
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	0d8080e7          	jalr	216(ra) # 80000660 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000590:	00002097          	auipc	ra,0x2
    80000594:	8d0080e7          	jalr	-1840(ra) # 80001e60 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000598:	00005097          	auipc	ra,0x5
    8000059c:	e88080e7          	jalr	-376(ra) # 80005420 <plicinithart>
  }

  scheduler();        
    800005a0:	00001097          	auipc	ra,0x1
    800005a4:	05c080e7          	jalr	92(ra) # 800015fc <scheduler>
    consoleinit();
    800005a8:	00006097          	auipc	ra,0x6
    800005ac:	8ec080e7          	jalr	-1812(ra) # 80005e94 <consoleinit>
    printfinit();
    800005b0:	00006097          	auipc	ra,0x6
    800005b4:	c02080e7          	jalr	-1022(ra) # 800061b2 <printfinit>
    printf("\n");
    800005b8:	00008517          	auipc	a0,0x8
    800005bc:	ad050513          	addi	a0,a0,-1328 # 80008088 <etext+0x88>
    800005c0:	00006097          	auipc	ra,0x6
    800005c4:	a0c080e7          	jalr	-1524(ra) # 80005fcc <printf>
    printf("xv6 kernel is booting\n");
    800005c8:	00008517          	auipc	a0,0x8
    800005cc:	a9850513          	addi	a0,a0,-1384 # 80008060 <etext+0x60>
    800005d0:	00006097          	auipc	ra,0x6
    800005d4:	9fc080e7          	jalr	-1540(ra) # 80005fcc <printf>
    printf("\n");
    800005d8:	00008517          	auipc	a0,0x8
    800005dc:	ab050513          	addi	a0,a0,-1360 # 80008088 <etext+0x88>
    800005e0:	00006097          	auipc	ra,0x6
    800005e4:	9ec080e7          	jalr	-1556(ra) # 80005fcc <printf>
    kinit();         // physical page allocator
    800005e8:	00000097          	auipc	ra,0x0
    800005ec:	d10080e7          	jalr	-752(ra) # 800002f8 <kinit>
    kvminit();       // create kernel page table
    800005f0:	00000097          	auipc	ra,0x0
    800005f4:	326080e7          	jalr	806(ra) # 80000916 <kvminit>
    kvminithart();   // turn on paging
    800005f8:	00000097          	auipc	ra,0x0
    800005fc:	068080e7          	jalr	104(ra) # 80000660 <kvminithart>
    procinit();      // process table
    80000600:	00001097          	auipc	ra,0x1
    80000604:	a2a080e7          	jalr	-1494(ra) # 8000102a <procinit>
    trapinit();      // trap vectors
    80000608:	00002097          	auipc	ra,0x2
    8000060c:	830080e7          	jalr	-2000(ra) # 80001e38 <trapinit>
    trapinithart();  // install kernel trap vector
    80000610:	00002097          	auipc	ra,0x2
    80000614:	850080e7          	jalr	-1968(ra) # 80001e60 <trapinithart>
    plicinit();      // set up interrupt controller
    80000618:	00005097          	auipc	ra,0x5
    8000061c:	df2080e7          	jalr	-526(ra) # 8000540a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000620:	00005097          	auipc	ra,0x5
    80000624:	e00080e7          	jalr	-512(ra) # 80005420 <plicinithart>
    binit();         // buffer cache
    80000628:	00002097          	auipc	ra,0x2
    8000062c:	fb0080e7          	jalr	-80(ra) # 800025d8 <binit>
    iinit();         // inode table
    80000630:	00002097          	auipc	ra,0x2
    80000634:	654080e7          	jalr	1620(ra) # 80002c84 <iinit>
    fileinit();      // file table
    80000638:	00003097          	auipc	ra,0x3
    8000063c:	5f2080e7          	jalr	1522(ra) # 80003c2a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000640:	00005097          	auipc	ra,0x5
    80000644:	ee8080e7          	jalr	-280(ra) # 80005528 <virtio_disk_init>
    userinit();      // first user process
    80000648:	00001097          	auipc	ra,0x1
    8000064c:	d9a080e7          	jalr	-614(ra) # 800013e2 <userinit>
    __sync_synchronize();
    80000650:	0ff0000f          	fence
    started = 1;
    80000654:	4785                	li	a5,1
    80000656:	00008717          	auipc	a4,0x8
    8000065a:	28f72d23          	sw	a5,666(a4) # 800088f0 <started>
    8000065e:	b789                	j	800005a0 <main+0x56>

0000000080000660 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000660:	1141                	addi	sp,sp,-16
    80000662:	e422                	sd	s0,8(sp)
    80000664:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000666:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000066a:	00008797          	auipc	a5,0x8
    8000066e:	28e7b783          	ld	a5,654(a5) # 800088f8 <kernel_pagetable>
    80000672:	83b1                	srli	a5,a5,0xc
    80000674:	577d                	li	a4,-1
    80000676:	177e                	slli	a4,a4,0x3f
    80000678:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000067a:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000067e:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000682:	6422                	ld	s0,8(sp)
    80000684:	0141                	addi	sp,sp,16
    80000686:	8082                	ret

0000000080000688 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000688:	7139                	addi	sp,sp,-64
    8000068a:	fc06                	sd	ra,56(sp)
    8000068c:	f822                	sd	s0,48(sp)
    8000068e:	f426                	sd	s1,40(sp)
    80000690:	f04a                	sd	s2,32(sp)
    80000692:	ec4e                	sd	s3,24(sp)
    80000694:	e852                	sd	s4,16(sp)
    80000696:	e456                	sd	s5,8(sp)
    80000698:	e05a                	sd	s6,0(sp)
    8000069a:	0080                	addi	s0,sp,64
    8000069c:	84aa                	mv	s1,a0
    8000069e:	89ae                	mv	s3,a1
    800006a0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    800006a2:	57fd                	li	a5,-1
    800006a4:	83e9                	srli	a5,a5,0x1a
    800006a6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800006a8:	4b31                	li	s6,12
  if(va >= MAXVA)
    800006aa:	04b7f263          	bgeu	a5,a1,800006ee <walk+0x66>
    panic("walk");
    800006ae:	00008517          	auipc	a0,0x8
    800006b2:	9e250513          	addi	a0,a0,-1566 # 80008090 <etext+0x90>
    800006b6:	00006097          	auipc	ra,0x6
    800006ba:	8cc080e7          	jalr	-1844(ra) # 80005f82 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800006be:	060a8663          	beqz	s5,8000072a <walk+0xa2>
    800006c2:	00000097          	auipc	ra,0x0
    800006c6:	c7a080e7          	jalr	-902(ra) # 8000033c <kalloc>
    800006ca:	84aa                	mv	s1,a0
    800006cc:	c529                	beqz	a0,80000716 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800006ce:	6605                	lui	a2,0x1
    800006d0:	4581                	li	a1,0
    800006d2:	00000097          	auipc	ra,0x0
    800006d6:	cca080e7          	jalr	-822(ra) # 8000039c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800006da:	00c4d793          	srli	a5,s1,0xc
    800006de:	07aa                	slli	a5,a5,0xa
    800006e0:	0017e793          	ori	a5,a5,1
    800006e4:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800006e8:	3a5d                	addiw	s4,s4,-9
    800006ea:	036a0063          	beq	s4,s6,8000070a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800006ee:	0149d933          	srl	s2,s3,s4
    800006f2:	1ff97913          	andi	s2,s2,511
    800006f6:	090e                	slli	s2,s2,0x3
    800006f8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800006fa:	00093483          	ld	s1,0(s2)
    800006fe:	0014f793          	andi	a5,s1,1
    80000702:	dfd5                	beqz	a5,800006be <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000704:	80a9                	srli	s1,s1,0xa
    80000706:	04b2                	slli	s1,s1,0xc
    80000708:	b7c5                	j	800006e8 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000070a:	00c9d513          	srli	a0,s3,0xc
    8000070e:	1ff57513          	andi	a0,a0,511
    80000712:	050e                	slli	a0,a0,0x3
    80000714:	9526                	add	a0,a0,s1
}
    80000716:	70e2                	ld	ra,56(sp)
    80000718:	7442                	ld	s0,48(sp)
    8000071a:	74a2                	ld	s1,40(sp)
    8000071c:	7902                	ld	s2,32(sp)
    8000071e:	69e2                	ld	s3,24(sp)
    80000720:	6a42                	ld	s4,16(sp)
    80000722:	6aa2                	ld	s5,8(sp)
    80000724:	6b02                	ld	s6,0(sp)
    80000726:	6121                	addi	sp,sp,64
    80000728:	8082                	ret
        return 0;
    8000072a:	4501                	li	a0,0
    8000072c:	b7ed                	j	80000716 <walk+0x8e>

000000008000072e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000072e:	57fd                	li	a5,-1
    80000730:	83e9                	srli	a5,a5,0x1a
    80000732:	00b7f463          	bgeu	a5,a1,8000073a <walkaddr+0xc>
    return 0;
    80000736:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000738:	8082                	ret
{
    8000073a:	1141                	addi	sp,sp,-16
    8000073c:	e406                	sd	ra,8(sp)
    8000073e:	e022                	sd	s0,0(sp)
    80000740:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000742:	4601                	li	a2,0
    80000744:	00000097          	auipc	ra,0x0
    80000748:	f44080e7          	jalr	-188(ra) # 80000688 <walk>
  if(pte == 0)
    8000074c:	c105                	beqz	a0,8000076c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000074e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000750:	0117f693          	andi	a3,a5,17
    80000754:	4745                	li	a4,17
    return 0;
    80000756:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000758:	00e68663          	beq	a3,a4,80000764 <walkaddr+0x36>
}
    8000075c:	60a2                	ld	ra,8(sp)
    8000075e:	6402                	ld	s0,0(sp)
    80000760:	0141                	addi	sp,sp,16
    80000762:	8082                	ret
  pa = PTE2PA(*pte);
    80000764:	00a7d513          	srli	a0,a5,0xa
    80000768:	0532                	slli	a0,a0,0xc
  return pa;
    8000076a:	bfcd                	j	8000075c <walkaddr+0x2e>
    return 0;
    8000076c:	4501                	li	a0,0
    8000076e:	b7fd                	j	8000075c <walkaddr+0x2e>

0000000080000770 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80000770:	715d                	addi	sp,sp,-80
    80000772:	e486                	sd	ra,72(sp)
    80000774:	e0a2                	sd	s0,64(sp)
    80000776:	fc26                	sd	s1,56(sp)
    80000778:	f84a                	sd	s2,48(sp)
    8000077a:	f44e                	sd	s3,40(sp)
    8000077c:	f052                	sd	s4,32(sp)
    8000077e:	ec56                	sd	s5,24(sp)
    80000780:	e85a                	sd	s6,16(sp)
    80000782:	e45e                	sd	s7,8(sp)
    80000784:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    80000786:	c205                	beqz	a2,800007a6 <mappages+0x36>
    80000788:	8aaa                	mv	s5,a0
    8000078a:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    8000078c:	77fd                	lui	a5,0xfffff
    8000078e:	00f5fa33          	and	s4,a1,a5
  last = PGROUNDDOWN(va + size - 1);
    80000792:	15fd                	addi	a1,a1,-1
    80000794:	00c589b3          	add	s3,a1,a2
    80000798:	00f9f9b3          	and	s3,s3,a5
  a = PGROUNDDOWN(va);
    8000079c:	8952                	mv	s2,s4
    8000079e:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800007a2:	6b85                	lui	s7,0x1
    800007a4:	a015                	j	800007c8 <mappages+0x58>
    panic("mappages: size");
    800007a6:	00008517          	auipc	a0,0x8
    800007aa:	8f250513          	addi	a0,a0,-1806 # 80008098 <etext+0x98>
    800007ae:	00005097          	auipc	ra,0x5
    800007b2:	7d4080e7          	jalr	2004(ra) # 80005f82 <panic>
      panic("mappages: remap");
    800007b6:	00008517          	auipc	a0,0x8
    800007ba:	8f250513          	addi	a0,a0,-1806 # 800080a8 <etext+0xa8>
    800007be:	00005097          	auipc	ra,0x5
    800007c2:	7c4080e7          	jalr	1988(ra) # 80005f82 <panic>
    a += PGSIZE;
    800007c6:	995e                	add	s2,s2,s7
  for(;;){
    800007c8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800007cc:	4605                	li	a2,1
    800007ce:	85ca                	mv	a1,s2
    800007d0:	8556                	mv	a0,s5
    800007d2:	00000097          	auipc	ra,0x0
    800007d6:	eb6080e7          	jalr	-330(ra) # 80000688 <walk>
    800007da:	cd19                	beqz	a0,800007f8 <mappages+0x88>
    if(*pte & PTE_V)
    800007dc:	611c                	ld	a5,0(a0)
    800007de:	8b85                	andi	a5,a5,1
    800007e0:	fbf9                	bnez	a5,800007b6 <mappages+0x46>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800007e2:	80b1                	srli	s1,s1,0xc
    800007e4:	04aa                	slli	s1,s1,0xa
    800007e6:	0164e4b3          	or	s1,s1,s6
    800007ea:	0014e493          	ori	s1,s1,1
    800007ee:	e104                	sd	s1,0(a0)
    if(a == last)
    800007f0:	fd391be3          	bne	s2,s3,800007c6 <mappages+0x56>
    pa += PGSIZE;
  }
  return 0;
    800007f4:	4501                	li	a0,0
    800007f6:	a011                	j	800007fa <mappages+0x8a>
      return -1;
    800007f8:	557d                	li	a0,-1
}
    800007fa:	60a6                	ld	ra,72(sp)
    800007fc:	6406                	ld	s0,64(sp)
    800007fe:	74e2                	ld	s1,56(sp)
    80000800:	7942                	ld	s2,48(sp)
    80000802:	79a2                	ld	s3,40(sp)
    80000804:	7a02                	ld	s4,32(sp)
    80000806:	6ae2                	ld	s5,24(sp)
    80000808:	6b42                	ld	s6,16(sp)
    8000080a:	6ba2                	ld	s7,8(sp)
    8000080c:	6161                	addi	sp,sp,80
    8000080e:	8082                	ret

0000000080000810 <kvmmap>:
{
    80000810:	1141                	addi	sp,sp,-16
    80000812:	e406                	sd	ra,8(sp)
    80000814:	e022                	sd	s0,0(sp)
    80000816:	0800                	addi	s0,sp,16
    80000818:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000081a:	86b2                	mv	a3,a2
    8000081c:	863e                	mv	a2,a5
    8000081e:	00000097          	auipc	ra,0x0
    80000822:	f52080e7          	jalr	-174(ra) # 80000770 <mappages>
    80000826:	e509                	bnez	a0,80000830 <kvmmap+0x20>
}
    80000828:	60a2                	ld	ra,8(sp)
    8000082a:	6402                	ld	s0,0(sp)
    8000082c:	0141                	addi	sp,sp,16
    8000082e:	8082                	ret
    panic("kvmmap");
    80000830:	00008517          	auipc	a0,0x8
    80000834:	88850513          	addi	a0,a0,-1912 # 800080b8 <etext+0xb8>
    80000838:	00005097          	auipc	ra,0x5
    8000083c:	74a080e7          	jalr	1866(ra) # 80005f82 <panic>

0000000080000840 <kvmmake>:
{
    80000840:	1101                	addi	sp,sp,-32
    80000842:	ec06                	sd	ra,24(sp)
    80000844:	e822                	sd	s0,16(sp)
    80000846:	e426                	sd	s1,8(sp)
    80000848:	e04a                	sd	s2,0(sp)
    8000084a:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000084c:	00000097          	auipc	ra,0x0
    80000850:	af0080e7          	jalr	-1296(ra) # 8000033c <kalloc>
    80000854:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80000856:	6605                	lui	a2,0x1
    80000858:	4581                	li	a1,0
    8000085a:	00000097          	auipc	ra,0x0
    8000085e:	b42080e7          	jalr	-1214(ra) # 8000039c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80000862:	4719                	li	a4,6
    80000864:	6685                	lui	a3,0x1
    80000866:	10000637          	lui	a2,0x10000
    8000086a:	100005b7          	lui	a1,0x10000
    8000086e:	8526                	mv	a0,s1
    80000870:	00000097          	auipc	ra,0x0
    80000874:	fa0080e7          	jalr	-96(ra) # 80000810 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000878:	4719                	li	a4,6
    8000087a:	6685                	lui	a3,0x1
    8000087c:	10001637          	lui	a2,0x10001
    80000880:	100015b7          	lui	a1,0x10001
    80000884:	8526                	mv	a0,s1
    80000886:	00000097          	auipc	ra,0x0
    8000088a:	f8a080e7          	jalr	-118(ra) # 80000810 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    8000088e:	4719                	li	a4,6
    80000890:	004006b7          	lui	a3,0x400
    80000894:	0c000637          	lui	a2,0xc000
    80000898:	0c0005b7          	lui	a1,0xc000
    8000089c:	8526                	mv	a0,s1
    8000089e:	00000097          	auipc	ra,0x0
    800008a2:	f72080e7          	jalr	-142(ra) # 80000810 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800008a6:	00007917          	auipc	s2,0x7
    800008aa:	75a90913          	addi	s2,s2,1882 # 80008000 <etext>
    800008ae:	4729                	li	a4,10
    800008b0:	80007697          	auipc	a3,0x80007
    800008b4:	75068693          	addi	a3,a3,1872 # 8000 <_entry-0x7fff8000>
    800008b8:	4605                	li	a2,1
    800008ba:	067e                	slli	a2,a2,0x1f
    800008bc:	85b2                	mv	a1,a2
    800008be:	8526                	mv	a0,s1
    800008c0:	00000097          	auipc	ra,0x0
    800008c4:	f50080e7          	jalr	-176(ra) # 80000810 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800008c8:	4719                	li	a4,6
    800008ca:	46c5                	li	a3,17
    800008cc:	06ee                	slli	a3,a3,0x1b
    800008ce:	412686b3          	sub	a3,a3,s2
    800008d2:	864a                	mv	a2,s2
    800008d4:	85ca                	mv	a1,s2
    800008d6:	8526                	mv	a0,s1
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	f38080e7          	jalr	-200(ra) # 80000810 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800008e0:	4729                	li	a4,10
    800008e2:	6685                	lui	a3,0x1
    800008e4:	00006617          	auipc	a2,0x6
    800008e8:	71c60613          	addi	a2,a2,1820 # 80007000 <_trampoline>
    800008ec:	040005b7          	lui	a1,0x4000
    800008f0:	15fd                	addi	a1,a1,-1
    800008f2:	05b2                	slli	a1,a1,0xc
    800008f4:	8526                	mv	a0,s1
    800008f6:	00000097          	auipc	ra,0x0
    800008fa:	f1a080e7          	jalr	-230(ra) # 80000810 <kvmmap>
  proc_mapstacks(kpgtbl);
    800008fe:	8526                	mv	a0,s1
    80000900:	00000097          	auipc	ra,0x0
    80000904:	694080e7          	jalr	1684(ra) # 80000f94 <proc_mapstacks>
}
    80000908:	8526                	mv	a0,s1
    8000090a:	60e2                	ld	ra,24(sp)
    8000090c:	6442                	ld	s0,16(sp)
    8000090e:	64a2                	ld	s1,8(sp)
    80000910:	6902                	ld	s2,0(sp)
    80000912:	6105                	addi	sp,sp,32
    80000914:	8082                	ret

0000000080000916 <kvminit>:
{
    80000916:	1141                	addi	sp,sp,-16
    80000918:	e406                	sd	ra,8(sp)
    8000091a:	e022                	sd	s0,0(sp)
    8000091c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000091e:	00000097          	auipc	ra,0x0
    80000922:	f22080e7          	jalr	-222(ra) # 80000840 <kvmmake>
    80000926:	00008797          	auipc	a5,0x8
    8000092a:	fca7b923          	sd	a0,-46(a5) # 800088f8 <kernel_pagetable>
}
    8000092e:	60a2                	ld	ra,8(sp)
    80000930:	6402                	ld	s0,0(sp)
    80000932:	0141                	addi	sp,sp,16
    80000934:	8082                	ret

0000000080000936 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80000936:	715d                	addi	sp,sp,-80
    80000938:	e486                	sd	ra,72(sp)
    8000093a:	e0a2                	sd	s0,64(sp)
    8000093c:	fc26                	sd	s1,56(sp)
    8000093e:	f84a                	sd	s2,48(sp)
    80000940:	f44e                	sd	s3,40(sp)
    80000942:	f052                	sd	s4,32(sp)
    80000944:	ec56                	sd	s5,24(sp)
    80000946:	e85a                	sd	s6,16(sp)
    80000948:	e45e                	sd	s7,8(sp)
    8000094a:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000094c:	03459793          	slli	a5,a1,0x34
    80000950:	e795                	bnez	a5,8000097c <uvmunmap+0x46>
    80000952:	8a2a                	mv	s4,a0
    80000954:	892e                	mv	s2,a1
    80000956:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000958:	0632                	slli	a2,a2,0xc
    8000095a:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000095e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000960:	6b05                	lui	s6,0x1
    80000962:	0735e863          	bltu	a1,s3,800009d2 <uvmunmap+0x9c>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80000966:	60a6                	ld	ra,72(sp)
    80000968:	6406                	ld	s0,64(sp)
    8000096a:	74e2                	ld	s1,56(sp)
    8000096c:	7942                	ld	s2,48(sp)
    8000096e:	79a2                	ld	s3,40(sp)
    80000970:	7a02                	ld	s4,32(sp)
    80000972:	6ae2                	ld	s5,24(sp)
    80000974:	6b42                	ld	s6,16(sp)
    80000976:	6ba2                	ld	s7,8(sp)
    80000978:	6161                	addi	sp,sp,80
    8000097a:	8082                	ret
    panic("uvmunmap: not aligned");
    8000097c:	00007517          	auipc	a0,0x7
    80000980:	74450513          	addi	a0,a0,1860 # 800080c0 <etext+0xc0>
    80000984:	00005097          	auipc	ra,0x5
    80000988:	5fe080e7          	jalr	1534(ra) # 80005f82 <panic>
      panic("uvmunmap: walk");
    8000098c:	00007517          	auipc	a0,0x7
    80000990:	74c50513          	addi	a0,a0,1868 # 800080d8 <etext+0xd8>
    80000994:	00005097          	auipc	ra,0x5
    80000998:	5ee080e7          	jalr	1518(ra) # 80005f82 <panic>
      panic("uvmunmap: not mapped");
    8000099c:	00007517          	auipc	a0,0x7
    800009a0:	74c50513          	addi	a0,a0,1868 # 800080e8 <etext+0xe8>
    800009a4:	00005097          	auipc	ra,0x5
    800009a8:	5de080e7          	jalr	1502(ra) # 80005f82 <panic>
      panic("uvmunmap: not a leaf");
    800009ac:	00007517          	auipc	a0,0x7
    800009b0:	75450513          	addi	a0,a0,1876 # 80008100 <etext+0x100>
    800009b4:	00005097          	auipc	ra,0x5
    800009b8:	5ce080e7          	jalr	1486(ra) # 80005f82 <panic>
      uint64 pa = PTE2PA(*pte);
    800009bc:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800009be:	0532                	slli	a0,a0,0xc
    800009c0:	fffff097          	auipc	ra,0xfffff
    800009c4:	7f4080e7          	jalr	2036(ra) # 800001b4 <kfree>
    *pte = 0;
    800009c8:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800009cc:	995a                	add	s2,s2,s6
    800009ce:	f9397ce3          	bgeu	s2,s3,80000966 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800009d2:	4601                	li	a2,0
    800009d4:	85ca                	mv	a1,s2
    800009d6:	8552                	mv	a0,s4
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	cb0080e7          	jalr	-848(ra) # 80000688 <walk>
    800009e0:	84aa                	mv	s1,a0
    800009e2:	d54d                	beqz	a0,8000098c <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800009e4:	6108                	ld	a0,0(a0)
    800009e6:	00157793          	andi	a5,a0,1
    800009ea:	dbcd                	beqz	a5,8000099c <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800009ec:	3ff57793          	andi	a5,a0,1023
    800009f0:	fb778ee3          	beq	a5,s7,800009ac <uvmunmap+0x76>
    if(do_free){
    800009f4:	fc0a8ae3          	beqz	s5,800009c8 <uvmunmap+0x92>
    800009f8:	b7d1                	j	800009bc <uvmunmap+0x86>

00000000800009fa <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000a04:	00000097          	auipc	ra,0x0
    80000a08:	938080e7          	jalr	-1736(ra) # 8000033c <kalloc>
    80000a0c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000a0e:	c519                	beqz	a0,80000a1c <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4581                	li	a1,0
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	988080e7          	jalr	-1656(ra) # 8000039c <memset>
  return pagetable;
}
    80000a1c:	8526                	mv	a0,s1
    80000a1e:	60e2                	ld	ra,24(sp)
    80000a20:	6442                	ld	s0,16(sp)
    80000a22:	64a2                	ld	s1,8(sp)
    80000a24:	6105                	addi	sp,sp,32
    80000a26:	8082                	ret

0000000080000a28 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80000a28:	7179                	addi	sp,sp,-48
    80000a2a:	f406                	sd	ra,40(sp)
    80000a2c:	f022                	sd	s0,32(sp)
    80000a2e:	ec26                	sd	s1,24(sp)
    80000a30:	e84a                	sd	s2,16(sp)
    80000a32:	e44e                	sd	s3,8(sp)
    80000a34:	e052                	sd	s4,0(sp)
    80000a36:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000a38:	6785                	lui	a5,0x1
    80000a3a:	04f67863          	bgeu	a2,a5,80000a8a <uvmfirst+0x62>
    80000a3e:	8a2a                	mv	s4,a0
    80000a40:	89ae                	mv	s3,a1
    80000a42:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80000a44:	00000097          	auipc	ra,0x0
    80000a48:	8f8080e7          	jalr	-1800(ra) # 8000033c <kalloc>
    80000a4c:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80000a4e:	6605                	lui	a2,0x1
    80000a50:	4581                	li	a1,0
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	94a080e7          	jalr	-1718(ra) # 8000039c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80000a5a:	4779                	li	a4,30
    80000a5c:	86ca                	mv	a3,s2
    80000a5e:	6605                	lui	a2,0x1
    80000a60:	4581                	li	a1,0
    80000a62:	8552                	mv	a0,s4
    80000a64:	00000097          	auipc	ra,0x0
    80000a68:	d0c080e7          	jalr	-756(ra) # 80000770 <mappages>
  memmove(mem, src, sz);
    80000a6c:	8626                	mv	a2,s1
    80000a6e:	85ce                	mv	a1,s3
    80000a70:	854a                	mv	a0,s2
    80000a72:	00000097          	auipc	ra,0x0
    80000a76:	98a080e7          	jalr	-1654(ra) # 800003fc <memmove>
}
    80000a7a:	70a2                	ld	ra,40(sp)
    80000a7c:	7402                	ld	s0,32(sp)
    80000a7e:	64e2                	ld	s1,24(sp)
    80000a80:	6942                	ld	s2,16(sp)
    80000a82:	69a2                	ld	s3,8(sp)
    80000a84:	6a02                	ld	s4,0(sp)
    80000a86:	6145                	addi	sp,sp,48
    80000a88:	8082                	ret
    panic("uvmfirst: more than a page");
    80000a8a:	00007517          	auipc	a0,0x7
    80000a8e:	68e50513          	addi	a0,a0,1678 # 80008118 <etext+0x118>
    80000a92:	00005097          	auipc	ra,0x5
    80000a96:	4f0080e7          	jalr	1264(ra) # 80005f82 <panic>

0000000080000a9a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80000a9a:	1101                	addi	sp,sp,-32
    80000a9c:	ec06                	sd	ra,24(sp)
    80000a9e:	e822                	sd	s0,16(sp)
    80000aa0:	e426                	sd	s1,8(sp)
    80000aa2:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80000aa4:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80000aa6:	00b67d63          	bgeu	a2,a1,80000ac0 <uvmdealloc+0x26>
    80000aaa:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80000aac:	6785                	lui	a5,0x1
    80000aae:	17fd                	addi	a5,a5,-1
    80000ab0:	00f60733          	add	a4,a2,a5
    80000ab4:	767d                	lui	a2,0xfffff
    80000ab6:	8f71                	and	a4,a4,a2
    80000ab8:	97ae                	add	a5,a5,a1
    80000aba:	8ff1                	and	a5,a5,a2
    80000abc:	00f76863          	bltu	a4,a5,80000acc <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80000ac0:	8526                	mv	a0,s1
    80000ac2:	60e2                	ld	ra,24(sp)
    80000ac4:	6442                	ld	s0,16(sp)
    80000ac6:	64a2                	ld	s1,8(sp)
    80000ac8:	6105                	addi	sp,sp,32
    80000aca:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80000acc:	8f99                	sub	a5,a5,a4
    80000ace:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80000ad0:	4685                	li	a3,1
    80000ad2:	0007861b          	sext.w	a2,a5
    80000ad6:	85ba                	mv	a1,a4
    80000ad8:	00000097          	auipc	ra,0x0
    80000adc:	e5e080e7          	jalr	-418(ra) # 80000936 <uvmunmap>
    80000ae0:	b7c5                	j	80000ac0 <uvmdealloc+0x26>

0000000080000ae2 <uvmalloc>:
  if(newsz < oldsz)
    80000ae2:	0ab66563          	bltu	a2,a1,80000b8c <uvmalloc+0xaa>
{
    80000ae6:	7139                	addi	sp,sp,-64
    80000ae8:	fc06                	sd	ra,56(sp)
    80000aea:	f822                	sd	s0,48(sp)
    80000aec:	f426                	sd	s1,40(sp)
    80000aee:	f04a                	sd	s2,32(sp)
    80000af0:	ec4e                	sd	s3,24(sp)
    80000af2:	e852                	sd	s4,16(sp)
    80000af4:	e456                	sd	s5,8(sp)
    80000af6:	e05a                	sd	s6,0(sp)
    80000af8:	0080                	addi	s0,sp,64
    80000afa:	8aaa                	mv	s5,a0
    80000afc:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80000afe:	6985                	lui	s3,0x1
    80000b00:	19fd                	addi	s3,s3,-1
    80000b02:	95ce                	add	a1,a1,s3
    80000b04:	79fd                	lui	s3,0xfffff
    80000b06:	0135f9b3          	and	s3,a1,s3
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000b0a:	08c9f363          	bgeu	s3,a2,80000b90 <uvmalloc+0xae>
    80000b0e:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000b10:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80000b14:	00000097          	auipc	ra,0x0
    80000b18:	828080e7          	jalr	-2008(ra) # 8000033c <kalloc>
    80000b1c:	84aa                	mv	s1,a0
    if(mem == 0){
    80000b1e:	c51d                	beqz	a0,80000b4c <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80000b20:	6605                	lui	a2,0x1
    80000b22:	4581                	li	a1,0
    80000b24:	00000097          	auipc	ra,0x0
    80000b28:	878080e7          	jalr	-1928(ra) # 8000039c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80000b2c:	875a                	mv	a4,s6
    80000b2e:	86a6                	mv	a3,s1
    80000b30:	6605                	lui	a2,0x1
    80000b32:	85ca                	mv	a1,s2
    80000b34:	8556                	mv	a0,s5
    80000b36:	00000097          	auipc	ra,0x0
    80000b3a:	c3a080e7          	jalr	-966(ra) # 80000770 <mappages>
    80000b3e:	e90d                	bnez	a0,80000b70 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000b40:	6785                	lui	a5,0x1
    80000b42:	993e                	add	s2,s2,a5
    80000b44:	fd4968e3          	bltu	s2,s4,80000b14 <uvmalloc+0x32>
  return newsz;
    80000b48:	8552                	mv	a0,s4
    80000b4a:	a809                	j	80000b5c <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80000b4c:	864e                	mv	a2,s3
    80000b4e:	85ca                	mv	a1,s2
    80000b50:	8556                	mv	a0,s5
    80000b52:	00000097          	auipc	ra,0x0
    80000b56:	f48080e7          	jalr	-184(ra) # 80000a9a <uvmdealloc>
      return 0;
    80000b5a:	4501                	li	a0,0
}
    80000b5c:	70e2                	ld	ra,56(sp)
    80000b5e:	7442                	ld	s0,48(sp)
    80000b60:	74a2                	ld	s1,40(sp)
    80000b62:	7902                	ld	s2,32(sp)
    80000b64:	69e2                	ld	s3,24(sp)
    80000b66:	6a42                	ld	s4,16(sp)
    80000b68:	6aa2                	ld	s5,8(sp)
    80000b6a:	6b02                	ld	s6,0(sp)
    80000b6c:	6121                	addi	sp,sp,64
    80000b6e:	8082                	ret
      kfree(mem);
    80000b70:	8526                	mv	a0,s1
    80000b72:	fffff097          	auipc	ra,0xfffff
    80000b76:	642080e7          	jalr	1602(ra) # 800001b4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80000b7a:	864e                	mv	a2,s3
    80000b7c:	85ca                	mv	a1,s2
    80000b7e:	8556                	mv	a0,s5
    80000b80:	00000097          	auipc	ra,0x0
    80000b84:	f1a080e7          	jalr	-230(ra) # 80000a9a <uvmdealloc>
      return 0;
    80000b88:	4501                	li	a0,0
    80000b8a:	bfc9                	j	80000b5c <uvmalloc+0x7a>
    return oldsz;
    80000b8c:	852e                	mv	a0,a1
}
    80000b8e:	8082                	ret
  return newsz;
    80000b90:	8532                	mv	a0,a2
    80000b92:	b7e9                	j	80000b5c <uvmalloc+0x7a>

0000000080000b94 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80000b94:	7179                	addi	sp,sp,-48
    80000b96:	f406                	sd	ra,40(sp)
    80000b98:	f022                	sd	s0,32(sp)
    80000b9a:	ec26                	sd	s1,24(sp)
    80000b9c:	e84a                	sd	s2,16(sp)
    80000b9e:	e44e                	sd	s3,8(sp)
    80000ba0:	e052                	sd	s4,0(sp)
    80000ba2:	1800                	addi	s0,sp,48
    80000ba4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80000ba6:	84aa                	mv	s1,a0
    80000ba8:	6905                	lui	s2,0x1
    80000baa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000bac:	4985                	li	s3,1
    80000bae:	a821                	j	80000bc6 <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80000bb0:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    80000bb2:	0532                	slli	a0,a0,0xc
    80000bb4:	00000097          	auipc	ra,0x0
    80000bb8:	fe0080e7          	jalr	-32(ra) # 80000b94 <freewalk>
      pagetable[i] = 0;
    80000bbc:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000bc0:	04a1                	addi	s1,s1,8
    80000bc2:	03248163          	beq	s1,s2,80000be4 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000bc6:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000bc8:	00f57793          	andi	a5,a0,15
    80000bcc:	ff3782e3          	beq	a5,s3,80000bb0 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000bd0:	8905                	andi	a0,a0,1
    80000bd2:	d57d                	beqz	a0,80000bc0 <freewalk+0x2c>
      panic("freewalk: leaf");
    80000bd4:	00007517          	auipc	a0,0x7
    80000bd8:	56450513          	addi	a0,a0,1380 # 80008138 <etext+0x138>
    80000bdc:	00005097          	auipc	ra,0x5
    80000be0:	3a6080e7          	jalr	934(ra) # 80005f82 <panic>
    }
  }
  kfree((void*)pagetable);
    80000be4:	8552                	mv	a0,s4
    80000be6:	fffff097          	auipc	ra,0xfffff
    80000bea:	5ce080e7          	jalr	1486(ra) # 800001b4 <kfree>
}
    80000bee:	70a2                	ld	ra,40(sp)
    80000bf0:	7402                	ld	s0,32(sp)
    80000bf2:	64e2                	ld	s1,24(sp)
    80000bf4:	6942                	ld	s2,16(sp)
    80000bf6:	69a2                	ld	s3,8(sp)
    80000bf8:	6a02                	ld	s4,0(sp)
    80000bfa:	6145                	addi	sp,sp,48
    80000bfc:	8082                	ret

0000000080000bfe <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000bfe:	1101                	addi	sp,sp,-32
    80000c00:	ec06                	sd	ra,24(sp)
    80000c02:	e822                	sd	s0,16(sp)
    80000c04:	e426                	sd	s1,8(sp)
    80000c06:	1000                	addi	s0,sp,32
    80000c08:	84aa                	mv	s1,a0
  if(sz > 0)
    80000c0a:	e999                	bnez	a1,80000c20 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000c0c:	8526                	mv	a0,s1
    80000c0e:	00000097          	auipc	ra,0x0
    80000c12:	f86080e7          	jalr	-122(ra) # 80000b94 <freewalk>
}
    80000c16:	60e2                	ld	ra,24(sp)
    80000c18:	6442                	ld	s0,16(sp)
    80000c1a:	64a2                	ld	s1,8(sp)
    80000c1c:	6105                	addi	sp,sp,32
    80000c1e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000c20:	6605                	lui	a2,0x1
    80000c22:	167d                	addi	a2,a2,-1
    80000c24:	962e                	add	a2,a2,a1
    80000c26:	4685                	li	a3,1
    80000c28:	8231                	srli	a2,a2,0xc
    80000c2a:	4581                	li	a1,0
    80000c2c:	00000097          	auipc	ra,0x0
    80000c30:	d0a080e7          	jalr	-758(ra) # 80000936 <uvmunmap>
    80000c34:	bfe1                	j	80000c0c <uvmfree+0xe>

0000000080000c36 <uvmcopy>:
  uint64 pa, i;
  uint flags;
  char *mem;

  // iterate through each page in the old page table.
  for(i = 0; i < sz; i += PGSIZE){
    80000c36:	12060263          	beqz	a2,80000d5a <uvmcopy+0x124>
int uvmcopy(pagetable_t old, pagetable_t new, uint64 sz) {
    80000c3a:	7119                	addi	sp,sp,-128
    80000c3c:	fc86                	sd	ra,120(sp)
    80000c3e:	f8a2                	sd	s0,112(sp)
    80000c40:	f4a6                	sd	s1,104(sp)
    80000c42:	f0ca                	sd	s2,96(sp)
    80000c44:	ecce                	sd	s3,88(sp)
    80000c46:	e8d2                	sd	s4,80(sp)
    80000c48:	e4d6                	sd	s5,72(sp)
    80000c4a:	e0da                	sd	s6,64(sp)
    80000c4c:	fc5e                	sd	s7,56(sp)
    80000c4e:	f862                	sd	s8,48(sp)
    80000c50:	f466                	sd	s9,40(sp)
    80000c52:	f06a                	sd	s10,32(sp)
    80000c54:	ec6e                	sd	s11,24(sp)
    80000c56:	0100                	addi	s0,sp,128
    80000c58:	8daa                	mv	s11,a0
    80000c5a:	8cae                	mv	s9,a1
    80000c5c:	8d32                	mv	s10,a2
  for(i = 0; i < sz; i += PGSIZE){
    80000c5e:	4981                	li	s3,0
    }

    // if the page is writable, adjust the flags for Copy-On-Write.
    if(flags & PTE_W){
      flags = (flags & (~PTE_W)) | PTE_COW; // clear write permission, set COW flag.
      *pte = PA2PTE(pa) | flags; // update the old page table entry with new flags.
    80000c60:	77fd                	lui	a5,0xfffff
    80000c62:	8389                	srli	a5,a5,0x2
    80000c64:	f8f43423          	sd	a5,-120(s0)
    80000c68:	a8ad                	j	80000ce2 <uvmcopy+0xac>
      panic("uvmcopy: pte should exist"); // panic if the PTE doesn't exist.
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	4de50513          	addi	a0,a0,1246 # 80008148 <etext+0x148>
    80000c72:	00005097          	auipc	ra,0x5
    80000c76:	310080e7          	jalr	784(ra) # 80005f82 <panic>
      panic("uvmcopy: page not present"); // panic if the page is not present.
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	4ee50513          	addi	a0,a0,1262 # 80008168 <etext+0x168>
    80000c82:	00005097          	auipc	ra,0x5
    80000c86:	300080e7          	jalr	768(ra) # 80005f82 <panic>
      kfree(mem); // free the newly allocated memory if mapping fails.
    80000c8a:	854a                	mv	a0,s2
    80000c8c:	fffff097          	auipc	ra,0xfffff
    80000c90:	528080e7          	jalr	1320(ra) # 800001b4 <kfree>
  }

  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000c94:	4685                	li	a3,1
    80000c96:	00c9d613          	srli	a2,s3,0xc
    80000c9a:	4581                	li	a1,0
    80000c9c:	8566                	mv	a0,s9
    80000c9e:	00000097          	auipc	ra,0x0
    80000ca2:	c98080e7          	jalr	-872(ra) # 80000936 <uvmunmap>
  return -1;
    80000ca6:	557d                	li	a0,-1
}
    80000ca8:	70e6                	ld	ra,120(sp)
    80000caa:	7446                	ld	s0,112(sp)
    80000cac:	74a6                	ld	s1,104(sp)
    80000cae:	7906                	ld	s2,96(sp)
    80000cb0:	69e6                	ld	s3,88(sp)
    80000cb2:	6a46                	ld	s4,80(sp)
    80000cb4:	6aa6                	ld	s5,72(sp)
    80000cb6:	6b06                	ld	s6,64(sp)
    80000cb8:	7be2                	ld	s7,56(sp)
    80000cba:	7c42                	ld	s8,48(sp)
    80000cbc:	7ca2                	ld	s9,40(sp)
    80000cbe:	7d02                	ld	s10,32(sp)
    80000cc0:	6de2                	ld	s11,24(sp)
    80000cc2:	6109                	addi	sp,sp,128
    80000cc4:	8082                	ret
    if(mappages(new, i, PGSIZE, pa, flags) != 0){
    80000cc6:	8762                	mv	a4,s8
    80000cc8:	86d6                	mv	a3,s5
    80000cca:	6605                	lui	a2,0x1
    80000ccc:	85ce                	mv	a1,s3
    80000cce:	8566                	mv	a0,s9
    80000cd0:	00000097          	auipc	ra,0x0
    80000cd4:	aa0080e7          	jalr	-1376(ra) # 80000770 <mappages>
    80000cd8:	fd55                	bnez	a0,80000c94 <uvmcopy+0x5e>
  for(i = 0; i < sz; i += PGSIZE){
    80000cda:	6785                	lui	a5,0x1
    80000cdc:	99be                	add	s3,s3,a5
    80000cde:	fda9f5e3          	bgeu	s3,s10,80000ca8 <uvmcopy+0x72>
    if((pte = walk(old, i, 0)) == 0)
    80000ce2:	4601                	li	a2,0
    80000ce4:	85ce                	mv	a1,s3
    80000ce6:	856e                	mv	a0,s11
    80000ce8:	00000097          	auipc	ra,0x0
    80000cec:	9a0080e7          	jalr	-1632(ra) # 80000688 <walk>
    80000cf0:	8a2a                	mv	s4,a0
    80000cf2:	dd25                	beqz	a0,80000c6a <uvmcopy+0x34>
    if((*pte & PTE_V) == 0)
    80000cf4:	6104                	ld	s1,0(a0)
    80000cf6:	0014f793          	andi	a5,s1,1
    80000cfa:	d3c1                	beqz	a5,80000c7a <uvmcopy+0x44>
    pa = PTE2PA(*pte); // extract the physical address from the PTE.
    80000cfc:	00a4da93          	srli	s5,s1,0xa
    80000d00:	0ab2                	slli	s5,s5,0xc
    flags = PTE_FLAGS(*pte); // extract the flags from the PTE.
    80000d02:	00048b9b          	sext.w	s7,s1
    80000d06:	3ff4fc13          	andi	s8,s1,1023
    if((mem = kalloc()) == 0)
    80000d0a:	fffff097          	auipc	ra,0xfffff
    80000d0e:	632080e7          	jalr	1586(ra) # 8000033c <kalloc>
    80000d12:	892a                	mv	s2,a0
    80000d14:	d141                	beqz	a0,80000c94 <uvmcopy+0x5e>
    memmove(mem, (char*)pa, PGSIZE); // copy the contents of the page.
    80000d16:	6605                	lui	a2,0x1
    80000d18:	85d6                	mv	a1,s5
    80000d1a:	fffff097          	auipc	ra,0xfffff
    80000d1e:	6e2080e7          	jalr	1762(ra) # 800003fc <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000d22:	000c0b1b          	sext.w	s6,s8
    80000d26:	875a                	mv	a4,s6
    80000d28:	86ca                	mv	a3,s2
    80000d2a:	6605                	lui	a2,0x1
    80000d2c:	85ce                	mv	a1,s3
    80000d2e:	8566                	mv	a0,s9
    80000d30:	00000097          	auipc	ra,0x0
    80000d34:	a40080e7          	jalr	-1472(ra) # 80000770 <mappages>
    80000d38:	f929                	bnez	a0,80000c8a <uvmcopy+0x54>
    if(flags & PTE_W){
    80000d3a:	004bfb93          	andi	s7,s7,4
    80000d3e:	f80b84e3          	beqz	s7,80000cc6 <uvmcopy+0x90>
      flags = (flags & (~PTE_W)) | PTE_COW; // clear write permission, set COW flag.
    80000d42:	efbb7b13          	andi	s6,s6,-261
    80000d46:	100b6c13          	ori	s8,s6,256
      *pte = PA2PTE(pa) | flags; // update the old page table entry with new flags.
    80000d4a:	f8843783          	ld	a5,-120(s0)
    80000d4e:	8cfd                	and	s1,s1,a5
    80000d50:	0184e4b3          	or	s1,s1,s8
    80000d54:	009a3023          	sd	s1,0(s4) # 1000 <_entry-0x7ffff000>
    80000d58:	b7bd                	j	80000cc6 <uvmcopy+0x90>
  return 0;
    80000d5a:	4501                	li	a0,0
}
    80000d5c:	8082                	ret

0000000080000d5e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000d5e:	1141                	addi	sp,sp,-16
    80000d60:	e406                	sd	ra,8(sp)
    80000d62:	e022                	sd	s0,0(sp)
    80000d64:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000d66:	4601                	li	a2,0
    80000d68:	00000097          	auipc	ra,0x0
    80000d6c:	920080e7          	jalr	-1760(ra) # 80000688 <walk>
  if(pte == 0)
    80000d70:	c901                	beqz	a0,80000d80 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000d72:	611c                	ld	a5,0(a0)
    80000d74:	9bbd                	andi	a5,a5,-17
    80000d76:	e11c                	sd	a5,0(a0)
}
    80000d78:	60a2                	ld	ra,8(sp)
    80000d7a:	6402                	ld	s0,0(sp)
    80000d7c:	0141                	addi	sp,sp,16
    80000d7e:	8082                	ret
    panic("uvmclear");
    80000d80:	00007517          	auipc	a0,0x7
    80000d84:	40850513          	addi	a0,a0,1032 # 80008188 <etext+0x188>
    80000d88:	00005097          	auipc	ra,0x5
    80000d8c:	1fa080e7          	jalr	506(ra) # 80005f82 <panic>

0000000080000d90 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0, flags;
  pte_t *pte;

  while(len > 0){
    80000d90:	c2d5                	beqz	a3,80000e34 <copyout+0xa4>
{
    80000d92:	711d                	addi	sp,sp,-96
    80000d94:	ec86                	sd	ra,88(sp)
    80000d96:	e8a2                	sd	s0,80(sp)
    80000d98:	e4a6                	sd	s1,72(sp)
    80000d9a:	e0ca                	sd	s2,64(sp)
    80000d9c:	fc4e                	sd	s3,56(sp)
    80000d9e:	f852                	sd	s4,48(sp)
    80000da0:	f456                	sd	s5,40(sp)
    80000da2:	f05a                	sd	s6,32(sp)
    80000da4:	ec5e                	sd	s7,24(sp)
    80000da6:	e862                	sd	s8,16(sp)
    80000da8:	e466                	sd	s9,8(sp)
    80000daa:	1080                	addi	s0,sp,96
    80000dac:	8baa                	mv	s7,a0
    80000dae:	89ae                	mv	s3,a1
    80000db0:	8b32                	mv	s6,a2
    80000db2:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80000db4:	7cfd                	lui	s9,0xfffff
    pte = walk(pagetable, va0, 0);
    //extract the flags from the page table entry
    flags = PTE_FLAGS(*pte);

    //calculate the number of bytes to copy in this iteration
    n = PGSIZE - (dstva - va0);
    80000db6:	6c05                	lui	s8,0x1
    80000db8:	a081                	j	80000df8 <copyout+0x68>
    
    //check if the page is marked cow
    if(flags & PTE_COW) {
      //handle the page fault
      page_fault_handling((void*)va0, pagetable);
    80000dba:	85de                	mv	a1,s7
    80000dbc:	854a                	mv	a0,s2
    80000dbe:	00001097          	auipc	ra,0x1
    80000dc2:	fbc080e7          	jalr	-68(ra) # 80001d7a <page_fault_handling>
      //update the physical address after handling the page fault
      pa0 = walkaddr(pagetable, va0);
    80000dc6:	85ca                	mv	a1,s2
    80000dc8:	855e                	mv	a0,s7
    80000dca:	00000097          	auipc	ra,0x0
    80000dce:	964080e7          	jalr	-1692(ra) # 8000072e <walkaddr>
    80000dd2:	8a2a                	mv	s4,a0
    80000dd4:	a891                	j	80000e28 <copyout+0x98>
    }
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000dd6:	41298533          	sub	a0,s3,s2
    80000dda:	0004861b          	sext.w	a2,s1
    80000dde:	85da                	mv	a1,s6
    80000de0:	9552                	add	a0,a0,s4
    80000de2:	fffff097          	auipc	ra,0xfffff
    80000de6:	61a080e7          	jalr	1562(ra) # 800003fc <memmove>

    len -= n;
    80000dea:	409a8ab3          	sub	s5,s5,s1
    src += n;
    80000dee:	9b26                	add	s6,s6,s1
    dstva = va0 + PGSIZE;
    80000df0:	018909b3          	add	s3,s2,s8
  while(len > 0){
    80000df4:	020a8e63          	beqz	s5,80000e30 <copyout+0xa0>
    va0 = PGROUNDDOWN(dstva);
    80000df8:	0199f933          	and	s2,s3,s9
    pa0 = walkaddr(pagetable, va0);
    80000dfc:	85ca                	mv	a1,s2
    80000dfe:	855e                	mv	a0,s7
    80000e00:	00000097          	auipc	ra,0x0
    80000e04:	92e080e7          	jalr	-1746(ra) # 8000072e <walkaddr>
    80000e08:	8a2a                	mv	s4,a0
    if(pa0 == 0)
    80000e0a:	c51d                	beqz	a0,80000e38 <copyout+0xa8>
    pte = walk(pagetable, va0, 0);
    80000e0c:	4601                	li	a2,0
    80000e0e:	85ca                	mv	a1,s2
    80000e10:	855e                	mv	a0,s7
    80000e12:	00000097          	auipc	ra,0x0
    80000e16:	876080e7          	jalr	-1930(ra) # 80000688 <walk>
    n = PGSIZE - (dstva - va0);
    80000e1a:	413904b3          	sub	s1,s2,s3
    80000e1e:	94e2                	add	s1,s1,s8
    if(flags & PTE_COW) {
    80000e20:	611c                	ld	a5,0(a0)
    80000e22:	1007f793          	andi	a5,a5,256
    80000e26:	fbd1                	bnez	a5,80000dba <copyout+0x2a>
    if(n > len)
    80000e28:	fa9af7e3          	bgeu	s5,s1,80000dd6 <copyout+0x46>
    80000e2c:	84d6                	mv	s1,s5
    80000e2e:	b765                	j	80000dd6 <copyout+0x46>
  }
  return 0;
    80000e30:	4501                	li	a0,0
    80000e32:	a021                	j	80000e3a <copyout+0xaa>
    80000e34:	4501                	li	a0,0
}
    80000e36:	8082                	ret
      return -1;
    80000e38:	557d                	li	a0,-1
}
    80000e3a:	60e6                	ld	ra,88(sp)
    80000e3c:	6446                	ld	s0,80(sp)
    80000e3e:	64a6                	ld	s1,72(sp)
    80000e40:	6906                	ld	s2,64(sp)
    80000e42:	79e2                	ld	s3,56(sp)
    80000e44:	7a42                	ld	s4,48(sp)
    80000e46:	7aa2                	ld	s5,40(sp)
    80000e48:	7b02                	ld	s6,32(sp)
    80000e4a:	6be2                	ld	s7,24(sp)
    80000e4c:	6c42                	ld	s8,16(sp)
    80000e4e:	6ca2                	ld	s9,8(sp)
    80000e50:	6125                	addi	sp,sp,96
    80000e52:	8082                	ret

0000000080000e54 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000e54:	c6bd                	beqz	a3,80000ec2 <copyin+0x6e>
{
    80000e56:	715d                	addi	sp,sp,-80
    80000e58:	e486                	sd	ra,72(sp)
    80000e5a:	e0a2                	sd	s0,64(sp)
    80000e5c:	fc26                	sd	s1,56(sp)
    80000e5e:	f84a                	sd	s2,48(sp)
    80000e60:	f44e                	sd	s3,40(sp)
    80000e62:	f052                	sd	s4,32(sp)
    80000e64:	ec56                	sd	s5,24(sp)
    80000e66:	e85a                	sd	s6,16(sp)
    80000e68:	e45e                	sd	s7,8(sp)
    80000e6a:	e062                	sd	s8,0(sp)
    80000e6c:	0880                	addi	s0,sp,80
    80000e6e:	8b2a                	mv	s6,a0
    80000e70:	8a2e                	mv	s4,a1
    80000e72:	8c32                	mv	s8,a2
    80000e74:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000e76:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000e78:	6a85                	lui	s5,0x1
    80000e7a:	a015                	j	80000e9e <copyin+0x4a>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000e7c:	9562                	add	a0,a0,s8
    80000e7e:	0004861b          	sext.w	a2,s1
    80000e82:	412505b3          	sub	a1,a0,s2
    80000e86:	8552                	mv	a0,s4
    80000e88:	fffff097          	auipc	ra,0xfffff
    80000e8c:	574080e7          	jalr	1396(ra) # 800003fc <memmove>

    len -= n;
    80000e90:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000e94:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80000e96:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80000e9a:	02098263          	beqz	s3,80000ebe <copyin+0x6a>
    va0 = PGROUNDDOWN(srcva);
    80000e9e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80000ea2:	85ca                	mv	a1,s2
    80000ea4:	855a                	mv	a0,s6
    80000ea6:	00000097          	auipc	ra,0x0
    80000eaa:	888080e7          	jalr	-1912(ra) # 8000072e <walkaddr>
    if(pa0 == 0)
    80000eae:	cd01                	beqz	a0,80000ec6 <copyin+0x72>
    n = PGSIZE - (srcva - va0);
    80000eb0:	418904b3          	sub	s1,s2,s8
    80000eb4:	94d6                	add	s1,s1,s5
    if(n > len)
    80000eb6:	fc99f3e3          	bgeu	s3,s1,80000e7c <copyin+0x28>
    80000eba:	84ce                	mv	s1,s3
    80000ebc:	b7c1                	j	80000e7c <copyin+0x28>
  }
  return 0;
    80000ebe:	4501                	li	a0,0
    80000ec0:	a021                	j	80000ec8 <copyin+0x74>
    80000ec2:	4501                	li	a0,0
}
    80000ec4:	8082                	ret
      return -1;
    80000ec6:	557d                	li	a0,-1
}
    80000ec8:	60a6                	ld	ra,72(sp)
    80000eca:	6406                	ld	s0,64(sp)
    80000ecc:	74e2                	ld	s1,56(sp)
    80000ece:	7942                	ld	s2,48(sp)
    80000ed0:	79a2                	ld	s3,40(sp)
    80000ed2:	7a02                	ld	s4,32(sp)
    80000ed4:	6ae2                	ld	s5,24(sp)
    80000ed6:	6b42                	ld	s6,16(sp)
    80000ed8:	6ba2                	ld	s7,8(sp)
    80000eda:	6c02                	ld	s8,0(sp)
    80000edc:	6161                	addi	sp,sp,80
    80000ede:	8082                	ret

0000000080000ee0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000ee0:	c6c5                	beqz	a3,80000f88 <copyinstr+0xa8>
{
    80000ee2:	715d                	addi	sp,sp,-80
    80000ee4:	e486                	sd	ra,72(sp)
    80000ee6:	e0a2                	sd	s0,64(sp)
    80000ee8:	fc26                	sd	s1,56(sp)
    80000eea:	f84a                	sd	s2,48(sp)
    80000eec:	f44e                	sd	s3,40(sp)
    80000eee:	f052                	sd	s4,32(sp)
    80000ef0:	ec56                	sd	s5,24(sp)
    80000ef2:	e85a                	sd	s6,16(sp)
    80000ef4:	e45e                	sd	s7,8(sp)
    80000ef6:	0880                	addi	s0,sp,80
    80000ef8:	8a2a                	mv	s4,a0
    80000efa:	8b2e                	mv	s6,a1
    80000efc:	8bb2                	mv	s7,a2
    80000efe:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80000f00:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000f02:	6985                	lui	s3,0x1
    80000f04:	a035                	j	80000f30 <copyinstr+0x50>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80000f06:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80000f0a:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80000f0c:	0017b793          	seqz	a5,a5
    80000f10:	40f00533          	neg	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80000f14:	60a6                	ld	ra,72(sp)
    80000f16:	6406                	ld	s0,64(sp)
    80000f18:	74e2                	ld	s1,56(sp)
    80000f1a:	7942                	ld	s2,48(sp)
    80000f1c:	79a2                	ld	s3,40(sp)
    80000f1e:	7a02                	ld	s4,32(sp)
    80000f20:	6ae2                	ld	s5,24(sp)
    80000f22:	6b42                	ld	s6,16(sp)
    80000f24:	6ba2                	ld	s7,8(sp)
    80000f26:	6161                	addi	sp,sp,80
    80000f28:	8082                	ret
    srcva = va0 + PGSIZE;
    80000f2a:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80000f2e:	c8a9                	beqz	s1,80000f80 <copyinstr+0xa0>
    va0 = PGROUNDDOWN(srcva);
    80000f30:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80000f34:	85ca                	mv	a1,s2
    80000f36:	8552                	mv	a0,s4
    80000f38:	fffff097          	auipc	ra,0xfffff
    80000f3c:	7f6080e7          	jalr	2038(ra) # 8000072e <walkaddr>
    if(pa0 == 0)
    80000f40:	c131                	beqz	a0,80000f84 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80000f42:	41790833          	sub	a6,s2,s7
    80000f46:	984e                	add	a6,a6,s3
    if(n > max)
    80000f48:	0104f363          	bgeu	s1,a6,80000f4e <copyinstr+0x6e>
    80000f4c:	8826                	mv	a6,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80000f4e:	955e                	add	a0,a0,s7
    80000f50:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000f54:	fc080be3          	beqz	a6,80000f2a <copyinstr+0x4a>
    80000f58:	985a                	add	a6,a6,s6
    80000f5a:	87da                	mv	a5,s6
      if(*p == '\0'){
    80000f5c:	41650633          	sub	a2,a0,s6
    80000f60:	14fd                	addi	s1,s1,-1
    80000f62:	9b26                	add	s6,s6,s1
    80000f64:	00f60733          	add	a4,a2,a5
    80000f68:	00074703          	lbu	a4,0(a4)
    80000f6c:	df49                	beqz	a4,80000f06 <copyinstr+0x26>
        *dst = *p;
    80000f6e:	00e78023          	sb	a4,0(a5)
      --max;
    80000f72:	40fb04b3          	sub	s1,s6,a5
      dst++;
    80000f76:	0785                	addi	a5,a5,1
    while(n > 0){
    80000f78:	ff0796e3          	bne	a5,a6,80000f64 <copyinstr+0x84>
      dst++;
    80000f7c:	8b42                	mv	s6,a6
    80000f7e:	b775                	j	80000f2a <copyinstr+0x4a>
    80000f80:	4781                	li	a5,0
    80000f82:	b769                	j	80000f0c <copyinstr+0x2c>
      return -1;
    80000f84:	557d                	li	a0,-1
    80000f86:	b779                	j	80000f14 <copyinstr+0x34>
  int got_null = 0;
    80000f88:	4781                	li	a5,0
  if(got_null){
    80000f8a:	0017b793          	seqz	a5,a5
    80000f8e:	40f00533          	neg	a0,a5
}
    80000f92:	8082                	ret

0000000080000f94 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80000f94:	7139                	addi	sp,sp,-64
    80000f96:	fc06                	sd	ra,56(sp)
    80000f98:	f822                	sd	s0,48(sp)
    80000f9a:	f426                	sd	s1,40(sp)
    80000f9c:	f04a                	sd	s2,32(sp)
    80000f9e:	ec4e                	sd	s3,24(sp)
    80000fa0:	e852                	sd	s4,16(sp)
    80000fa2:	e456                	sd	s5,8(sp)
    80000fa4:	e05a                	sd	s6,0(sp)
    80000fa6:	0080                	addi	s0,sp,64
    80000fa8:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80000faa:	00228497          	auipc	s1,0x228
    80000fae:	dde48493          	addi	s1,s1,-546 # 80228d88 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80000fb2:	8b26                	mv	s6,s1
    80000fb4:	00007a97          	auipc	s5,0x7
    80000fb8:	04ca8a93          	addi	s5,s5,76 # 80008000 <etext>
    80000fbc:	04000937          	lui	s2,0x4000
    80000fc0:	197d                	addi	s2,s2,-1
    80000fc2:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000fc4:	0022da17          	auipc	s4,0x22d
    80000fc8:	7c4a0a13          	addi	s4,s4,1988 # 8022e788 <tickslock>
    char *pa = kalloc();
    80000fcc:	fffff097          	auipc	ra,0xfffff
    80000fd0:	370080e7          	jalr	880(ra) # 8000033c <kalloc>
    80000fd4:	862a                	mv	a2,a0
    if(pa == 0)
    80000fd6:	c131                	beqz	a0,8000101a <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000fd8:	416485b3          	sub	a1,s1,s6
    80000fdc:	858d                	srai	a1,a1,0x3
    80000fde:	000ab783          	ld	a5,0(s5)
    80000fe2:	02f585b3          	mul	a1,a1,a5
    80000fe6:	2585                	addiw	a1,a1,1
    80000fe8:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000fec:	4719                	li	a4,6
    80000fee:	6685                	lui	a3,0x1
    80000ff0:	40b905b3          	sub	a1,s2,a1
    80000ff4:	854e                	mv	a0,s3
    80000ff6:	00000097          	auipc	ra,0x0
    80000ffa:	81a080e7          	jalr	-2022(ra) # 80000810 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000ffe:	16848493          	addi	s1,s1,360
    80001002:	fd4495e3          	bne	s1,s4,80000fcc <proc_mapstacks+0x38>
  }
}
    80001006:	70e2                	ld	ra,56(sp)
    80001008:	7442                	ld	s0,48(sp)
    8000100a:	74a2                	ld	s1,40(sp)
    8000100c:	7902                	ld	s2,32(sp)
    8000100e:	69e2                	ld	s3,24(sp)
    80001010:	6a42                	ld	s4,16(sp)
    80001012:	6aa2                	ld	s5,8(sp)
    80001014:	6b02                	ld	s6,0(sp)
    80001016:	6121                	addi	sp,sp,64
    80001018:	8082                	ret
      panic("kalloc");
    8000101a:	00007517          	auipc	a0,0x7
    8000101e:	17e50513          	addi	a0,a0,382 # 80008198 <etext+0x198>
    80001022:	00005097          	auipc	ra,0x5
    80001026:	f60080e7          	jalr	-160(ra) # 80005f82 <panic>

000000008000102a <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000102a:	7139                	addi	sp,sp,-64
    8000102c:	fc06                	sd	ra,56(sp)
    8000102e:	f822                	sd	s0,48(sp)
    80001030:	f426                	sd	s1,40(sp)
    80001032:	f04a                	sd	s2,32(sp)
    80001034:	ec4e                	sd	s3,24(sp)
    80001036:	e852                	sd	s4,16(sp)
    80001038:	e456                	sd	s5,8(sp)
    8000103a:	e05a                	sd	s6,0(sp)
    8000103c:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    8000103e:	00007597          	auipc	a1,0x7
    80001042:	16258593          	addi	a1,a1,354 # 800081a0 <etext+0x1a0>
    80001046:	00228517          	auipc	a0,0x228
    8000104a:	91250513          	addi	a0,a0,-1774 # 80228958 <pid_lock>
    8000104e:	00005097          	auipc	ra,0x5
    80001052:	3ee080e7          	jalr	1006(ra) # 8000643c <initlock>
  initlock(&wait_lock, "wait_lock");
    80001056:	00007597          	auipc	a1,0x7
    8000105a:	15258593          	addi	a1,a1,338 # 800081a8 <etext+0x1a8>
    8000105e:	00228517          	auipc	a0,0x228
    80001062:	91250513          	addi	a0,a0,-1774 # 80228970 <wait_lock>
    80001066:	00005097          	auipc	ra,0x5
    8000106a:	3d6080e7          	jalr	982(ra) # 8000643c <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000106e:	00228497          	auipc	s1,0x228
    80001072:	d1a48493          	addi	s1,s1,-742 # 80228d88 <proc>
      initlock(&p->lock, "proc");
    80001076:	00007b17          	auipc	s6,0x7
    8000107a:	142b0b13          	addi	s6,s6,322 # 800081b8 <etext+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000107e:	8aa6                	mv	s5,s1
    80001080:	00007a17          	auipc	s4,0x7
    80001084:	f80a0a13          	addi	s4,s4,-128 # 80008000 <etext>
    80001088:	04000937          	lui	s2,0x4000
    8000108c:	197d                	addi	s2,s2,-1
    8000108e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001090:	0022d997          	auipc	s3,0x22d
    80001094:	6f898993          	addi	s3,s3,1784 # 8022e788 <tickslock>
      initlock(&p->lock, "proc");
    80001098:	85da                	mv	a1,s6
    8000109a:	8526                	mv	a0,s1
    8000109c:	00005097          	auipc	ra,0x5
    800010a0:	3a0080e7          	jalr	928(ra) # 8000643c <initlock>
      p->state = UNUSED;
    800010a4:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    800010a8:	415487b3          	sub	a5,s1,s5
    800010ac:	878d                	srai	a5,a5,0x3
    800010ae:	000a3703          	ld	a4,0(s4)
    800010b2:	02e787b3          	mul	a5,a5,a4
    800010b6:	2785                	addiw	a5,a5,1
    800010b8:	00d7979b          	slliw	a5,a5,0xd
    800010bc:	40f907b3          	sub	a5,s2,a5
    800010c0:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800010c2:	16848493          	addi	s1,s1,360
    800010c6:	fd3499e3          	bne	s1,s3,80001098 <procinit+0x6e>
  }
}
    800010ca:	70e2                	ld	ra,56(sp)
    800010cc:	7442                	ld	s0,48(sp)
    800010ce:	74a2                	ld	s1,40(sp)
    800010d0:	7902                	ld	s2,32(sp)
    800010d2:	69e2                	ld	s3,24(sp)
    800010d4:	6a42                	ld	s4,16(sp)
    800010d6:	6aa2                	ld	s5,8(sp)
    800010d8:	6b02                	ld	s6,0(sp)
    800010da:	6121                	addi	sp,sp,64
    800010dc:	8082                	ret

00000000800010de <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800010de:	1141                	addi	sp,sp,-16
    800010e0:	e422                	sd	s0,8(sp)
    800010e2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800010e4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800010e6:	2501                	sext.w	a0,a0
    800010e8:	6422                	ld	s0,8(sp)
    800010ea:	0141                	addi	sp,sp,16
    800010ec:	8082                	ret

00000000800010ee <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800010ee:	1141                	addi	sp,sp,-16
    800010f0:	e422                	sd	s0,8(sp)
    800010f2:	0800                	addi	s0,sp,16
    800010f4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800010f6:	2781                	sext.w	a5,a5
    800010f8:	079e                	slli	a5,a5,0x7
  return c;
}
    800010fa:	00228517          	auipc	a0,0x228
    800010fe:	88e50513          	addi	a0,a0,-1906 # 80228988 <cpus>
    80001102:	953e                	add	a0,a0,a5
    80001104:	6422                	ld	s0,8(sp)
    80001106:	0141                	addi	sp,sp,16
    80001108:	8082                	ret

000000008000110a <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    8000110a:	1101                	addi	sp,sp,-32
    8000110c:	ec06                	sd	ra,24(sp)
    8000110e:	e822                	sd	s0,16(sp)
    80001110:	e426                	sd	s1,8(sp)
    80001112:	1000                	addi	s0,sp,32
  push_off();
    80001114:	00005097          	auipc	ra,0x5
    80001118:	36c080e7          	jalr	876(ra) # 80006480 <push_off>
    8000111c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000111e:	2781                	sext.w	a5,a5
    80001120:	079e                	slli	a5,a5,0x7
    80001122:	00228717          	auipc	a4,0x228
    80001126:	83670713          	addi	a4,a4,-1994 # 80228958 <pid_lock>
    8000112a:	97ba                	add	a5,a5,a4
    8000112c:	7b84                	ld	s1,48(a5)
  pop_off();
    8000112e:	00005097          	auipc	ra,0x5
    80001132:	3f2080e7          	jalr	1010(ra) # 80006520 <pop_off>
  return p;
}
    80001136:	8526                	mv	a0,s1
    80001138:	60e2                	ld	ra,24(sp)
    8000113a:	6442                	ld	s0,16(sp)
    8000113c:	64a2                	ld	s1,8(sp)
    8000113e:	6105                	addi	sp,sp,32
    80001140:	8082                	ret

0000000080001142 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001142:	1141                	addi	sp,sp,-16
    80001144:	e406                	sd	ra,8(sp)
    80001146:	e022                	sd	s0,0(sp)
    80001148:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    8000114a:	00000097          	auipc	ra,0x0
    8000114e:	fc0080e7          	jalr	-64(ra) # 8000110a <myproc>
    80001152:	00005097          	auipc	ra,0x5
    80001156:	42e080e7          	jalr	1070(ra) # 80006580 <release>

  if (first) {
    8000115a:	00007797          	auipc	a5,0x7
    8000115e:	7267a783          	lw	a5,1830(a5) # 80008880 <first.1681>
    80001162:	eb89                	bnez	a5,80001174 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001164:	00001097          	auipc	ra,0x1
    80001168:	d14080e7          	jalr	-748(ra) # 80001e78 <usertrapret>
}
    8000116c:	60a2                	ld	ra,8(sp)
    8000116e:	6402                	ld	s0,0(sp)
    80001170:	0141                	addi	sp,sp,16
    80001172:	8082                	ret
    first = 0;
    80001174:	00007797          	auipc	a5,0x7
    80001178:	7007a623          	sw	zero,1804(a5) # 80008880 <first.1681>
    fsinit(ROOTDEV);
    8000117c:	4505                	li	a0,1
    8000117e:	00002097          	auipc	ra,0x2
    80001182:	a86080e7          	jalr	-1402(ra) # 80002c04 <fsinit>
    80001186:	bff9                	j	80001164 <forkret+0x22>

0000000080001188 <allocpid>:
{
    80001188:	1101                	addi	sp,sp,-32
    8000118a:	ec06                	sd	ra,24(sp)
    8000118c:	e822                	sd	s0,16(sp)
    8000118e:	e426                	sd	s1,8(sp)
    80001190:	e04a                	sd	s2,0(sp)
    80001192:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001194:	00227917          	auipc	s2,0x227
    80001198:	7c490913          	addi	s2,s2,1988 # 80228958 <pid_lock>
    8000119c:	854a                	mv	a0,s2
    8000119e:	00005097          	auipc	ra,0x5
    800011a2:	32e080e7          	jalr	814(ra) # 800064cc <acquire>
  pid = nextpid;
    800011a6:	00007797          	auipc	a5,0x7
    800011aa:	6de78793          	addi	a5,a5,1758 # 80008884 <nextpid>
    800011ae:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    800011b0:	0014871b          	addiw	a4,s1,1
    800011b4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    800011b6:	854a                	mv	a0,s2
    800011b8:	00005097          	auipc	ra,0x5
    800011bc:	3c8080e7          	jalr	968(ra) # 80006580 <release>
}
    800011c0:	8526                	mv	a0,s1
    800011c2:	60e2                	ld	ra,24(sp)
    800011c4:	6442                	ld	s0,16(sp)
    800011c6:	64a2                	ld	s1,8(sp)
    800011c8:	6902                	ld	s2,0(sp)
    800011ca:	6105                	addi	sp,sp,32
    800011cc:	8082                	ret

00000000800011ce <proc_pagetable>:
{
    800011ce:	1101                	addi	sp,sp,-32
    800011d0:	ec06                	sd	ra,24(sp)
    800011d2:	e822                	sd	s0,16(sp)
    800011d4:	e426                	sd	s1,8(sp)
    800011d6:	e04a                	sd	s2,0(sp)
    800011d8:	1000                	addi	s0,sp,32
    800011da:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    800011dc:	00000097          	auipc	ra,0x0
    800011e0:	81e080e7          	jalr	-2018(ra) # 800009fa <uvmcreate>
    800011e4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800011e6:	c121                	beqz	a0,80001226 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    800011e8:	4729                	li	a4,10
    800011ea:	00006697          	auipc	a3,0x6
    800011ee:	e1668693          	addi	a3,a3,-490 # 80007000 <_trampoline>
    800011f2:	6605                	lui	a2,0x1
    800011f4:	040005b7          	lui	a1,0x4000
    800011f8:	15fd                	addi	a1,a1,-1
    800011fa:	05b2                	slli	a1,a1,0xc
    800011fc:	fffff097          	auipc	ra,0xfffff
    80001200:	574080e7          	jalr	1396(ra) # 80000770 <mappages>
    80001204:	02054863          	bltz	a0,80001234 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001208:	4719                	li	a4,6
    8000120a:	05893683          	ld	a3,88(s2)
    8000120e:	6605                	lui	a2,0x1
    80001210:	020005b7          	lui	a1,0x2000
    80001214:	15fd                	addi	a1,a1,-1
    80001216:	05b6                	slli	a1,a1,0xd
    80001218:	8526                	mv	a0,s1
    8000121a:	fffff097          	auipc	ra,0xfffff
    8000121e:	556080e7          	jalr	1366(ra) # 80000770 <mappages>
    80001222:	02054163          	bltz	a0,80001244 <proc_pagetable+0x76>
}
    80001226:	8526                	mv	a0,s1
    80001228:	60e2                	ld	ra,24(sp)
    8000122a:	6442                	ld	s0,16(sp)
    8000122c:	64a2                	ld	s1,8(sp)
    8000122e:	6902                	ld	s2,0(sp)
    80001230:	6105                	addi	sp,sp,32
    80001232:	8082                	ret
    uvmfree(pagetable, 0);
    80001234:	4581                	li	a1,0
    80001236:	8526                	mv	a0,s1
    80001238:	00000097          	auipc	ra,0x0
    8000123c:	9c6080e7          	jalr	-1594(ra) # 80000bfe <uvmfree>
    return 0;
    80001240:	4481                	li	s1,0
    80001242:	b7d5                	j	80001226 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001244:	4681                	li	a3,0
    80001246:	4605                	li	a2,1
    80001248:	040005b7          	lui	a1,0x4000
    8000124c:	15fd                	addi	a1,a1,-1
    8000124e:	05b2                	slli	a1,a1,0xc
    80001250:	8526                	mv	a0,s1
    80001252:	fffff097          	auipc	ra,0xfffff
    80001256:	6e4080e7          	jalr	1764(ra) # 80000936 <uvmunmap>
    uvmfree(pagetable, 0);
    8000125a:	4581                	li	a1,0
    8000125c:	8526                	mv	a0,s1
    8000125e:	00000097          	auipc	ra,0x0
    80001262:	9a0080e7          	jalr	-1632(ra) # 80000bfe <uvmfree>
    return 0;
    80001266:	4481                	li	s1,0
    80001268:	bf7d                	j	80001226 <proc_pagetable+0x58>

000000008000126a <proc_freepagetable>:
{
    8000126a:	1101                	addi	sp,sp,-32
    8000126c:	ec06                	sd	ra,24(sp)
    8000126e:	e822                	sd	s0,16(sp)
    80001270:	e426                	sd	s1,8(sp)
    80001272:	e04a                	sd	s2,0(sp)
    80001274:	1000                	addi	s0,sp,32
    80001276:	84aa                	mv	s1,a0
    80001278:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000127a:	4681                	li	a3,0
    8000127c:	4605                	li	a2,1
    8000127e:	040005b7          	lui	a1,0x4000
    80001282:	15fd                	addi	a1,a1,-1
    80001284:	05b2                	slli	a1,a1,0xc
    80001286:	fffff097          	auipc	ra,0xfffff
    8000128a:	6b0080e7          	jalr	1712(ra) # 80000936 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    8000128e:	4681                	li	a3,0
    80001290:	4605                	li	a2,1
    80001292:	020005b7          	lui	a1,0x2000
    80001296:	15fd                	addi	a1,a1,-1
    80001298:	05b6                	slli	a1,a1,0xd
    8000129a:	8526                	mv	a0,s1
    8000129c:	fffff097          	auipc	ra,0xfffff
    800012a0:	69a080e7          	jalr	1690(ra) # 80000936 <uvmunmap>
  uvmfree(pagetable, sz);
    800012a4:	85ca                	mv	a1,s2
    800012a6:	8526                	mv	a0,s1
    800012a8:	00000097          	auipc	ra,0x0
    800012ac:	956080e7          	jalr	-1706(ra) # 80000bfe <uvmfree>
}
    800012b0:	60e2                	ld	ra,24(sp)
    800012b2:	6442                	ld	s0,16(sp)
    800012b4:	64a2                	ld	s1,8(sp)
    800012b6:	6902                	ld	s2,0(sp)
    800012b8:	6105                	addi	sp,sp,32
    800012ba:	8082                	ret

00000000800012bc <freeproc>:
{
    800012bc:	1101                	addi	sp,sp,-32
    800012be:	ec06                	sd	ra,24(sp)
    800012c0:	e822                	sd	s0,16(sp)
    800012c2:	e426                	sd	s1,8(sp)
    800012c4:	1000                	addi	s0,sp,32
    800012c6:	84aa                	mv	s1,a0
  if(p->trapframe)
    800012c8:	6d28                	ld	a0,88(a0)
    800012ca:	c509                	beqz	a0,800012d4 <freeproc+0x18>
    kfree((void*)p->trapframe);
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	ee8080e7          	jalr	-280(ra) # 800001b4 <kfree>
  p->trapframe = 0;
    800012d4:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800012d8:	68a8                	ld	a0,80(s1)
    800012da:	c511                	beqz	a0,800012e6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    800012dc:	64ac                	ld	a1,72(s1)
    800012de:	00000097          	auipc	ra,0x0
    800012e2:	f8c080e7          	jalr	-116(ra) # 8000126a <proc_freepagetable>
  p->pagetable = 0;
    800012e6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800012ea:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800012ee:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    800012f2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    800012f6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800012fa:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    800012fe:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001302:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001306:	0004ac23          	sw	zero,24(s1)
}
    8000130a:	60e2                	ld	ra,24(sp)
    8000130c:	6442                	ld	s0,16(sp)
    8000130e:	64a2                	ld	s1,8(sp)
    80001310:	6105                	addi	sp,sp,32
    80001312:	8082                	ret

0000000080001314 <allocproc>:
{
    80001314:	1101                	addi	sp,sp,-32
    80001316:	ec06                	sd	ra,24(sp)
    80001318:	e822                	sd	s0,16(sp)
    8000131a:	e426                	sd	s1,8(sp)
    8000131c:	e04a                	sd	s2,0(sp)
    8000131e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001320:	00228497          	auipc	s1,0x228
    80001324:	a6848493          	addi	s1,s1,-1432 # 80228d88 <proc>
    80001328:	0022d917          	auipc	s2,0x22d
    8000132c:	46090913          	addi	s2,s2,1120 # 8022e788 <tickslock>
    acquire(&p->lock);
    80001330:	8526                	mv	a0,s1
    80001332:	00005097          	auipc	ra,0x5
    80001336:	19a080e7          	jalr	410(ra) # 800064cc <acquire>
    if(p->state == UNUSED) {
    8000133a:	4c9c                	lw	a5,24(s1)
    8000133c:	cf81                	beqz	a5,80001354 <allocproc+0x40>
      release(&p->lock);
    8000133e:	8526                	mv	a0,s1
    80001340:	00005097          	auipc	ra,0x5
    80001344:	240080e7          	jalr	576(ra) # 80006580 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001348:	16848493          	addi	s1,s1,360
    8000134c:	ff2492e3          	bne	s1,s2,80001330 <allocproc+0x1c>
  return 0;
    80001350:	4481                	li	s1,0
    80001352:	a889                	j	800013a4 <allocproc+0x90>
  p->pid = allocpid();
    80001354:	00000097          	auipc	ra,0x0
    80001358:	e34080e7          	jalr	-460(ra) # 80001188 <allocpid>
    8000135c:	d888                	sw	a0,48(s1)
  p->state = USED;
    8000135e:	4785                	li	a5,1
    80001360:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001362:	fffff097          	auipc	ra,0xfffff
    80001366:	fda080e7          	jalr	-38(ra) # 8000033c <kalloc>
    8000136a:	892a                	mv	s2,a0
    8000136c:	eca8                	sd	a0,88(s1)
    8000136e:	c131                	beqz	a0,800013b2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001370:	8526                	mv	a0,s1
    80001372:	00000097          	auipc	ra,0x0
    80001376:	e5c080e7          	jalr	-420(ra) # 800011ce <proc_pagetable>
    8000137a:	892a                	mv	s2,a0
    8000137c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    8000137e:	c531                	beqz	a0,800013ca <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001380:	07000613          	li	a2,112
    80001384:	4581                	li	a1,0
    80001386:	06048513          	addi	a0,s1,96
    8000138a:	fffff097          	auipc	ra,0xfffff
    8000138e:	012080e7          	jalr	18(ra) # 8000039c <memset>
  p->context.ra = (uint64)forkret;
    80001392:	00000797          	auipc	a5,0x0
    80001396:	db078793          	addi	a5,a5,-592 # 80001142 <forkret>
    8000139a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    8000139c:	60bc                	ld	a5,64(s1)
    8000139e:	6705                	lui	a4,0x1
    800013a0:	97ba                	add	a5,a5,a4
    800013a2:	f4bc                	sd	a5,104(s1)
}
    800013a4:	8526                	mv	a0,s1
    800013a6:	60e2                	ld	ra,24(sp)
    800013a8:	6442                	ld	s0,16(sp)
    800013aa:	64a2                	ld	s1,8(sp)
    800013ac:	6902                	ld	s2,0(sp)
    800013ae:	6105                	addi	sp,sp,32
    800013b0:	8082                	ret
    freeproc(p);
    800013b2:	8526                	mv	a0,s1
    800013b4:	00000097          	auipc	ra,0x0
    800013b8:	f08080e7          	jalr	-248(ra) # 800012bc <freeproc>
    release(&p->lock);
    800013bc:	8526                	mv	a0,s1
    800013be:	00005097          	auipc	ra,0x5
    800013c2:	1c2080e7          	jalr	450(ra) # 80006580 <release>
    return 0;
    800013c6:	84ca                	mv	s1,s2
    800013c8:	bff1                	j	800013a4 <allocproc+0x90>
    freeproc(p);
    800013ca:	8526                	mv	a0,s1
    800013cc:	00000097          	auipc	ra,0x0
    800013d0:	ef0080e7          	jalr	-272(ra) # 800012bc <freeproc>
    release(&p->lock);
    800013d4:	8526                	mv	a0,s1
    800013d6:	00005097          	auipc	ra,0x5
    800013da:	1aa080e7          	jalr	426(ra) # 80006580 <release>
    return 0;
    800013de:	84ca                	mv	s1,s2
    800013e0:	b7d1                	j	800013a4 <allocproc+0x90>

00000000800013e2 <userinit>:
{
    800013e2:	1101                	addi	sp,sp,-32
    800013e4:	ec06                	sd	ra,24(sp)
    800013e6:	e822                	sd	s0,16(sp)
    800013e8:	e426                	sd	s1,8(sp)
    800013ea:	1000                	addi	s0,sp,32
  p = allocproc();
    800013ec:	00000097          	auipc	ra,0x0
    800013f0:	f28080e7          	jalr	-216(ra) # 80001314 <allocproc>
    800013f4:	84aa                	mv	s1,a0
  initproc = p;
    800013f6:	00007797          	auipc	a5,0x7
    800013fa:	50a7b523          	sd	a0,1290(a5) # 80008900 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    800013fe:	03400613          	li	a2,52
    80001402:	00007597          	auipc	a1,0x7
    80001406:	48e58593          	addi	a1,a1,1166 # 80008890 <initcode>
    8000140a:	6928                	ld	a0,80(a0)
    8000140c:	fffff097          	auipc	ra,0xfffff
    80001410:	61c080e7          	jalr	1564(ra) # 80000a28 <uvmfirst>
  p->sz = PGSIZE;
    80001414:	6785                	lui	a5,0x1
    80001416:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001418:	6cb8                	ld	a4,88(s1)
    8000141a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    8000141e:	6cb8                	ld	a4,88(s1)
    80001420:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001422:	4641                	li	a2,16
    80001424:	00007597          	auipc	a1,0x7
    80001428:	d9c58593          	addi	a1,a1,-612 # 800081c0 <etext+0x1c0>
    8000142c:	15848513          	addi	a0,s1,344
    80001430:	fffff097          	auipc	ra,0xfffff
    80001434:	0be080e7          	jalr	190(ra) # 800004ee <safestrcpy>
  p->cwd = namei("/");
    80001438:	00007517          	auipc	a0,0x7
    8000143c:	d9850513          	addi	a0,a0,-616 # 800081d0 <etext+0x1d0>
    80001440:	00002097          	auipc	ra,0x2
    80001444:	1e6080e7          	jalr	486(ra) # 80003626 <namei>
    80001448:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    8000144c:	478d                	li	a5,3
    8000144e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001450:	8526                	mv	a0,s1
    80001452:	00005097          	auipc	ra,0x5
    80001456:	12e080e7          	jalr	302(ra) # 80006580 <release>
}
    8000145a:	60e2                	ld	ra,24(sp)
    8000145c:	6442                	ld	s0,16(sp)
    8000145e:	64a2                	ld	s1,8(sp)
    80001460:	6105                	addi	sp,sp,32
    80001462:	8082                	ret

0000000080001464 <growproc>:
{
    80001464:	1101                	addi	sp,sp,-32
    80001466:	ec06                	sd	ra,24(sp)
    80001468:	e822                	sd	s0,16(sp)
    8000146a:	e426                	sd	s1,8(sp)
    8000146c:	e04a                	sd	s2,0(sp)
    8000146e:	1000                	addi	s0,sp,32
    80001470:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001472:	00000097          	auipc	ra,0x0
    80001476:	c98080e7          	jalr	-872(ra) # 8000110a <myproc>
    8000147a:	84aa                	mv	s1,a0
  sz = p->sz;
    8000147c:	652c                	ld	a1,72(a0)
  if(n > 0){
    8000147e:	01204c63          	bgtz	s2,80001496 <growproc+0x32>
  } else if(n < 0){
    80001482:	02094663          	bltz	s2,800014ae <growproc+0x4a>
  p->sz = sz;
    80001486:	e4ac                	sd	a1,72(s1)
  return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	60e2                	ld	ra,24(sp)
    8000148c:	6442                	ld	s0,16(sp)
    8000148e:	64a2                	ld	s1,8(sp)
    80001490:	6902                	ld	s2,0(sp)
    80001492:	6105                	addi	sp,sp,32
    80001494:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001496:	4691                	li	a3,4
    80001498:	00b90633          	add	a2,s2,a1
    8000149c:	6928                	ld	a0,80(a0)
    8000149e:	fffff097          	auipc	ra,0xfffff
    800014a2:	644080e7          	jalr	1604(ra) # 80000ae2 <uvmalloc>
    800014a6:	85aa                	mv	a1,a0
    800014a8:	fd79                	bnez	a0,80001486 <growproc+0x22>
      return -1;
    800014aa:	557d                	li	a0,-1
    800014ac:	bff9                	j	8000148a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800014ae:	00b90633          	add	a2,s2,a1
    800014b2:	6928                	ld	a0,80(a0)
    800014b4:	fffff097          	auipc	ra,0xfffff
    800014b8:	5e6080e7          	jalr	1510(ra) # 80000a9a <uvmdealloc>
    800014bc:	85aa                	mv	a1,a0
    800014be:	b7e1                	j	80001486 <growproc+0x22>

00000000800014c0 <fork>:
{
    800014c0:	7179                	addi	sp,sp,-48
    800014c2:	f406                	sd	ra,40(sp)
    800014c4:	f022                	sd	s0,32(sp)
    800014c6:	ec26                	sd	s1,24(sp)
    800014c8:	e84a                	sd	s2,16(sp)
    800014ca:	e44e                	sd	s3,8(sp)
    800014cc:	e052                	sd	s4,0(sp)
    800014ce:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800014d0:	00000097          	auipc	ra,0x0
    800014d4:	c3a080e7          	jalr	-966(ra) # 8000110a <myproc>
    800014d8:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800014da:	00000097          	auipc	ra,0x0
    800014de:	e3a080e7          	jalr	-454(ra) # 80001314 <allocproc>
    800014e2:	10050b63          	beqz	a0,800015f8 <fork+0x138>
    800014e6:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800014e8:	04893603          	ld	a2,72(s2)
    800014ec:	692c                	ld	a1,80(a0)
    800014ee:	05093503          	ld	a0,80(s2)
    800014f2:	fffff097          	auipc	ra,0xfffff
    800014f6:	744080e7          	jalr	1860(ra) # 80000c36 <uvmcopy>
    800014fa:	04054663          	bltz	a0,80001546 <fork+0x86>
  np->sz = p->sz;
    800014fe:	04893783          	ld	a5,72(s2)
    80001502:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001506:	05893683          	ld	a3,88(s2)
    8000150a:	87b6                	mv	a5,a3
    8000150c:	0589b703          	ld	a4,88(s3)
    80001510:	12068693          	addi	a3,a3,288
    80001514:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001518:	6788                	ld	a0,8(a5)
    8000151a:	6b8c                	ld	a1,16(a5)
    8000151c:	6f90                	ld	a2,24(a5)
    8000151e:	01073023          	sd	a6,0(a4)
    80001522:	e708                	sd	a0,8(a4)
    80001524:	eb0c                	sd	a1,16(a4)
    80001526:	ef10                	sd	a2,24(a4)
    80001528:	02078793          	addi	a5,a5,32
    8000152c:	02070713          	addi	a4,a4,32
    80001530:	fed792e3          	bne	a5,a3,80001514 <fork+0x54>
  np->trapframe->a0 = 0;
    80001534:	0589b783          	ld	a5,88(s3)
    80001538:	0607b823          	sd	zero,112(a5)
    8000153c:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001540:	15000a13          	li	s4,336
    80001544:	a03d                	j	80001572 <fork+0xb2>
    freeproc(np);
    80001546:	854e                	mv	a0,s3
    80001548:	00000097          	auipc	ra,0x0
    8000154c:	d74080e7          	jalr	-652(ra) # 800012bc <freeproc>
    release(&np->lock);
    80001550:	854e                	mv	a0,s3
    80001552:	00005097          	auipc	ra,0x5
    80001556:	02e080e7          	jalr	46(ra) # 80006580 <release>
    return -1;
    8000155a:	5a7d                	li	s4,-1
    8000155c:	a069                	j	800015e6 <fork+0x126>
      np->ofile[i] = filedup(p->ofile[i]);
    8000155e:	00002097          	auipc	ra,0x2
    80001562:	75e080e7          	jalr	1886(ra) # 80003cbc <filedup>
    80001566:	009987b3          	add	a5,s3,s1
    8000156a:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    8000156c:	04a1                	addi	s1,s1,8
    8000156e:	01448763          	beq	s1,s4,8000157c <fork+0xbc>
    if(p->ofile[i])
    80001572:	009907b3          	add	a5,s2,s1
    80001576:	6388                	ld	a0,0(a5)
    80001578:	f17d                	bnez	a0,8000155e <fork+0x9e>
    8000157a:	bfcd                	j	8000156c <fork+0xac>
  np->cwd = idup(p->cwd);
    8000157c:	15093503          	ld	a0,336(s2)
    80001580:	00002097          	auipc	ra,0x2
    80001584:	8c2080e7          	jalr	-1854(ra) # 80002e42 <idup>
    80001588:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000158c:	4641                	li	a2,16
    8000158e:	15890593          	addi	a1,s2,344
    80001592:	15898513          	addi	a0,s3,344
    80001596:	fffff097          	auipc	ra,0xfffff
    8000159a:	f58080e7          	jalr	-168(ra) # 800004ee <safestrcpy>
  pid = np->pid;
    8000159e:	0309aa03          	lw	s4,48(s3)
  release(&np->lock);
    800015a2:	854e                	mv	a0,s3
    800015a4:	00005097          	auipc	ra,0x5
    800015a8:	fdc080e7          	jalr	-36(ra) # 80006580 <release>
  acquire(&wait_lock);
    800015ac:	00227497          	auipc	s1,0x227
    800015b0:	3c448493          	addi	s1,s1,964 # 80228970 <wait_lock>
    800015b4:	8526                	mv	a0,s1
    800015b6:	00005097          	auipc	ra,0x5
    800015ba:	f16080e7          	jalr	-234(ra) # 800064cc <acquire>
  np->parent = p;
    800015be:	0329bc23          	sd	s2,56(s3)
  release(&wait_lock);
    800015c2:	8526                	mv	a0,s1
    800015c4:	00005097          	auipc	ra,0x5
    800015c8:	fbc080e7          	jalr	-68(ra) # 80006580 <release>
  acquire(&np->lock);
    800015cc:	854e                	mv	a0,s3
    800015ce:	00005097          	auipc	ra,0x5
    800015d2:	efe080e7          	jalr	-258(ra) # 800064cc <acquire>
  np->state = RUNNABLE;
    800015d6:	478d                	li	a5,3
    800015d8:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800015dc:	854e                	mv	a0,s3
    800015de:	00005097          	auipc	ra,0x5
    800015e2:	fa2080e7          	jalr	-94(ra) # 80006580 <release>
}
    800015e6:	8552                	mv	a0,s4
    800015e8:	70a2                	ld	ra,40(sp)
    800015ea:	7402                	ld	s0,32(sp)
    800015ec:	64e2                	ld	s1,24(sp)
    800015ee:	6942                	ld	s2,16(sp)
    800015f0:	69a2                	ld	s3,8(sp)
    800015f2:	6a02                	ld	s4,0(sp)
    800015f4:	6145                	addi	sp,sp,48
    800015f6:	8082                	ret
    return -1;
    800015f8:	5a7d                	li	s4,-1
    800015fa:	b7f5                	j	800015e6 <fork+0x126>

00000000800015fc <scheduler>:
{
    800015fc:	7139                	addi	sp,sp,-64
    800015fe:	fc06                	sd	ra,56(sp)
    80001600:	f822                	sd	s0,48(sp)
    80001602:	f426                	sd	s1,40(sp)
    80001604:	f04a                	sd	s2,32(sp)
    80001606:	ec4e                	sd	s3,24(sp)
    80001608:	e852                	sd	s4,16(sp)
    8000160a:	e456                	sd	s5,8(sp)
    8000160c:	e05a                	sd	s6,0(sp)
    8000160e:	0080                	addi	s0,sp,64
    80001610:	8792                	mv	a5,tp
  int id = r_tp();
    80001612:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001614:	00779a93          	slli	s5,a5,0x7
    80001618:	00227717          	auipc	a4,0x227
    8000161c:	34070713          	addi	a4,a4,832 # 80228958 <pid_lock>
    80001620:	9756                	add	a4,a4,s5
    80001622:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001626:	00227717          	auipc	a4,0x227
    8000162a:	36a70713          	addi	a4,a4,874 # 80228990 <cpus+0x8>
    8000162e:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001630:	498d                	li	s3,3
        p->state = RUNNING;
    80001632:	4b11                	li	s6,4
        c->proc = p;
    80001634:	079e                	slli	a5,a5,0x7
    80001636:	00227a17          	auipc	s4,0x227
    8000163a:	322a0a13          	addi	s4,s4,802 # 80228958 <pid_lock>
    8000163e:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001640:	0022d917          	auipc	s2,0x22d
    80001644:	14890913          	addi	s2,s2,328 # 8022e788 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001648:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000164c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001650:	10079073          	csrw	sstatus,a5
    80001654:	00227497          	auipc	s1,0x227
    80001658:	73448493          	addi	s1,s1,1844 # 80228d88 <proc>
    8000165c:	a03d                	j	8000168a <scheduler+0x8e>
        p->state = RUNNING;
    8000165e:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001662:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001666:	06048593          	addi	a1,s1,96
    8000166a:	8556                	mv	a0,s5
    8000166c:	00000097          	auipc	ra,0x0
    80001670:	6a4080e7          	jalr	1700(ra) # 80001d10 <swtch>
        c->proc = 0;
    80001674:	020a3823          	sd	zero,48(s4)
      release(&p->lock);
    80001678:	8526                	mv	a0,s1
    8000167a:	00005097          	auipc	ra,0x5
    8000167e:	f06080e7          	jalr	-250(ra) # 80006580 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001682:	16848493          	addi	s1,s1,360
    80001686:	fd2481e3          	beq	s1,s2,80001648 <scheduler+0x4c>
      acquire(&p->lock);
    8000168a:	8526                	mv	a0,s1
    8000168c:	00005097          	auipc	ra,0x5
    80001690:	e40080e7          	jalr	-448(ra) # 800064cc <acquire>
      if(p->state == RUNNABLE) {
    80001694:	4c9c                	lw	a5,24(s1)
    80001696:	ff3791e3          	bne	a5,s3,80001678 <scheduler+0x7c>
    8000169a:	b7d1                	j	8000165e <scheduler+0x62>

000000008000169c <sched>:
{
    8000169c:	7179                	addi	sp,sp,-48
    8000169e:	f406                	sd	ra,40(sp)
    800016a0:	f022                	sd	s0,32(sp)
    800016a2:	ec26                	sd	s1,24(sp)
    800016a4:	e84a                	sd	s2,16(sp)
    800016a6:	e44e                	sd	s3,8(sp)
    800016a8:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800016aa:	00000097          	auipc	ra,0x0
    800016ae:	a60080e7          	jalr	-1440(ra) # 8000110a <myproc>
    800016b2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800016b4:	00005097          	auipc	ra,0x5
    800016b8:	d9e080e7          	jalr	-610(ra) # 80006452 <holding>
    800016bc:	c93d                	beqz	a0,80001732 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800016be:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800016c0:	2781                	sext.w	a5,a5
    800016c2:	079e                	slli	a5,a5,0x7
    800016c4:	00227717          	auipc	a4,0x227
    800016c8:	29470713          	addi	a4,a4,660 # 80228958 <pid_lock>
    800016cc:	97ba                	add	a5,a5,a4
    800016ce:	0a87a703          	lw	a4,168(a5)
    800016d2:	4785                	li	a5,1
    800016d4:	06f71763          	bne	a4,a5,80001742 <sched+0xa6>
  if(p->state == RUNNING)
    800016d8:	4c98                	lw	a4,24(s1)
    800016da:	4791                	li	a5,4
    800016dc:	06f70b63          	beq	a4,a5,80001752 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800016e0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800016e4:	8b89                	andi	a5,a5,2
  if(intr_get())
    800016e6:	efb5                	bnez	a5,80001762 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800016e8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800016ea:	00227917          	auipc	s2,0x227
    800016ee:	26e90913          	addi	s2,s2,622 # 80228958 <pid_lock>
    800016f2:	2781                	sext.w	a5,a5
    800016f4:	079e                	slli	a5,a5,0x7
    800016f6:	97ca                	add	a5,a5,s2
    800016f8:	0ac7a983          	lw	s3,172(a5)
    800016fc:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800016fe:	2781                	sext.w	a5,a5
    80001700:	079e                	slli	a5,a5,0x7
    80001702:	00227597          	auipc	a1,0x227
    80001706:	28e58593          	addi	a1,a1,654 # 80228990 <cpus+0x8>
    8000170a:	95be                	add	a1,a1,a5
    8000170c:	06048513          	addi	a0,s1,96
    80001710:	00000097          	auipc	ra,0x0
    80001714:	600080e7          	jalr	1536(ra) # 80001d10 <swtch>
    80001718:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000171a:	2781                	sext.w	a5,a5
    8000171c:	079e                	slli	a5,a5,0x7
    8000171e:	97ca                	add	a5,a5,s2
    80001720:	0b37a623          	sw	s3,172(a5)
}
    80001724:	70a2                	ld	ra,40(sp)
    80001726:	7402                	ld	s0,32(sp)
    80001728:	64e2                	ld	s1,24(sp)
    8000172a:	6942                	ld	s2,16(sp)
    8000172c:	69a2                	ld	s3,8(sp)
    8000172e:	6145                	addi	sp,sp,48
    80001730:	8082                	ret
    panic("sched p->lock");
    80001732:	00007517          	auipc	a0,0x7
    80001736:	aa650513          	addi	a0,a0,-1370 # 800081d8 <etext+0x1d8>
    8000173a:	00005097          	auipc	ra,0x5
    8000173e:	848080e7          	jalr	-1976(ra) # 80005f82 <panic>
    panic("sched locks");
    80001742:	00007517          	auipc	a0,0x7
    80001746:	aa650513          	addi	a0,a0,-1370 # 800081e8 <etext+0x1e8>
    8000174a:	00005097          	auipc	ra,0x5
    8000174e:	838080e7          	jalr	-1992(ra) # 80005f82 <panic>
    panic("sched running");
    80001752:	00007517          	auipc	a0,0x7
    80001756:	aa650513          	addi	a0,a0,-1370 # 800081f8 <etext+0x1f8>
    8000175a:	00005097          	auipc	ra,0x5
    8000175e:	828080e7          	jalr	-2008(ra) # 80005f82 <panic>
    panic("sched interruptible");
    80001762:	00007517          	auipc	a0,0x7
    80001766:	aa650513          	addi	a0,a0,-1370 # 80008208 <etext+0x208>
    8000176a:	00005097          	auipc	ra,0x5
    8000176e:	818080e7          	jalr	-2024(ra) # 80005f82 <panic>

0000000080001772 <yield>:
{
    80001772:	1101                	addi	sp,sp,-32
    80001774:	ec06                	sd	ra,24(sp)
    80001776:	e822                	sd	s0,16(sp)
    80001778:	e426                	sd	s1,8(sp)
    8000177a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000177c:	00000097          	auipc	ra,0x0
    80001780:	98e080e7          	jalr	-1650(ra) # 8000110a <myproc>
    80001784:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001786:	00005097          	auipc	ra,0x5
    8000178a:	d46080e7          	jalr	-698(ra) # 800064cc <acquire>
  p->state = RUNNABLE;
    8000178e:	478d                	li	a5,3
    80001790:	cc9c                	sw	a5,24(s1)
  sched();
    80001792:	00000097          	auipc	ra,0x0
    80001796:	f0a080e7          	jalr	-246(ra) # 8000169c <sched>
  release(&p->lock);
    8000179a:	8526                	mv	a0,s1
    8000179c:	00005097          	auipc	ra,0x5
    800017a0:	de4080e7          	jalr	-540(ra) # 80006580 <release>
}
    800017a4:	60e2                	ld	ra,24(sp)
    800017a6:	6442                	ld	s0,16(sp)
    800017a8:	64a2                	ld	s1,8(sp)
    800017aa:	6105                	addi	sp,sp,32
    800017ac:	8082                	ret

00000000800017ae <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800017ae:	7179                	addi	sp,sp,-48
    800017b0:	f406                	sd	ra,40(sp)
    800017b2:	f022                	sd	s0,32(sp)
    800017b4:	ec26                	sd	s1,24(sp)
    800017b6:	e84a                	sd	s2,16(sp)
    800017b8:	e44e                	sd	s3,8(sp)
    800017ba:	1800                	addi	s0,sp,48
    800017bc:	89aa                	mv	s3,a0
    800017be:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800017c0:	00000097          	auipc	ra,0x0
    800017c4:	94a080e7          	jalr	-1718(ra) # 8000110a <myproc>
    800017c8:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800017ca:	00005097          	auipc	ra,0x5
    800017ce:	d02080e7          	jalr	-766(ra) # 800064cc <acquire>
  release(lk);
    800017d2:	854a                	mv	a0,s2
    800017d4:	00005097          	auipc	ra,0x5
    800017d8:	dac080e7          	jalr	-596(ra) # 80006580 <release>

  // Go to sleep.
  p->chan = chan;
    800017dc:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800017e0:	4789                	li	a5,2
    800017e2:	cc9c                	sw	a5,24(s1)

  sched();
    800017e4:	00000097          	auipc	ra,0x0
    800017e8:	eb8080e7          	jalr	-328(ra) # 8000169c <sched>

  // Tidy up.
  p->chan = 0;
    800017ec:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800017f0:	8526                	mv	a0,s1
    800017f2:	00005097          	auipc	ra,0x5
    800017f6:	d8e080e7          	jalr	-626(ra) # 80006580 <release>
  acquire(lk);
    800017fa:	854a                	mv	a0,s2
    800017fc:	00005097          	auipc	ra,0x5
    80001800:	cd0080e7          	jalr	-816(ra) # 800064cc <acquire>
}
    80001804:	70a2                	ld	ra,40(sp)
    80001806:	7402                	ld	s0,32(sp)
    80001808:	64e2                	ld	s1,24(sp)
    8000180a:	6942                	ld	s2,16(sp)
    8000180c:	69a2                	ld	s3,8(sp)
    8000180e:	6145                	addi	sp,sp,48
    80001810:	8082                	ret

0000000080001812 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001812:	7139                	addi	sp,sp,-64
    80001814:	fc06                	sd	ra,56(sp)
    80001816:	f822                	sd	s0,48(sp)
    80001818:	f426                	sd	s1,40(sp)
    8000181a:	f04a                	sd	s2,32(sp)
    8000181c:	ec4e                	sd	s3,24(sp)
    8000181e:	e852                	sd	s4,16(sp)
    80001820:	e456                	sd	s5,8(sp)
    80001822:	0080                	addi	s0,sp,64
    80001824:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001826:	00227497          	auipc	s1,0x227
    8000182a:	56248493          	addi	s1,s1,1378 # 80228d88 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000182e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001830:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001832:	0022d917          	auipc	s2,0x22d
    80001836:	f5690913          	addi	s2,s2,-170 # 8022e788 <tickslock>
    8000183a:	a821                	j	80001852 <wakeup+0x40>
        p->state = RUNNABLE;
    8000183c:	0154ac23          	sw	s5,24(s1)
      }
      release(&p->lock);
    80001840:	8526                	mv	a0,s1
    80001842:	00005097          	auipc	ra,0x5
    80001846:	d3e080e7          	jalr	-706(ra) # 80006580 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184a:	16848493          	addi	s1,s1,360
    8000184e:	03248463          	beq	s1,s2,80001876 <wakeup+0x64>
    if(p != myproc()){
    80001852:	00000097          	auipc	ra,0x0
    80001856:	8b8080e7          	jalr	-1864(ra) # 8000110a <myproc>
    8000185a:	fea488e3          	beq	s1,a0,8000184a <wakeup+0x38>
      acquire(&p->lock);
    8000185e:	8526                	mv	a0,s1
    80001860:	00005097          	auipc	ra,0x5
    80001864:	c6c080e7          	jalr	-916(ra) # 800064cc <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001868:	4c9c                	lw	a5,24(s1)
    8000186a:	fd379be3          	bne	a5,s3,80001840 <wakeup+0x2e>
    8000186e:	709c                	ld	a5,32(s1)
    80001870:	fd4798e3          	bne	a5,s4,80001840 <wakeup+0x2e>
    80001874:	b7e1                	j	8000183c <wakeup+0x2a>
    }
  }
}
    80001876:	70e2                	ld	ra,56(sp)
    80001878:	7442                	ld	s0,48(sp)
    8000187a:	74a2                	ld	s1,40(sp)
    8000187c:	7902                	ld	s2,32(sp)
    8000187e:	69e2                	ld	s3,24(sp)
    80001880:	6a42                	ld	s4,16(sp)
    80001882:	6aa2                	ld	s5,8(sp)
    80001884:	6121                	addi	sp,sp,64
    80001886:	8082                	ret

0000000080001888 <reparent>:
{
    80001888:	7179                	addi	sp,sp,-48
    8000188a:	f406                	sd	ra,40(sp)
    8000188c:	f022                	sd	s0,32(sp)
    8000188e:	ec26                	sd	s1,24(sp)
    80001890:	e84a                	sd	s2,16(sp)
    80001892:	e44e                	sd	s3,8(sp)
    80001894:	e052                	sd	s4,0(sp)
    80001896:	1800                	addi	s0,sp,48
    80001898:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000189a:	00227497          	auipc	s1,0x227
    8000189e:	4ee48493          	addi	s1,s1,1262 # 80228d88 <proc>
      pp->parent = initproc;
    800018a2:	00007a17          	auipc	s4,0x7
    800018a6:	05ea0a13          	addi	s4,s4,94 # 80008900 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800018aa:	0022d997          	auipc	s3,0x22d
    800018ae:	ede98993          	addi	s3,s3,-290 # 8022e788 <tickslock>
    800018b2:	a029                	j	800018bc <reparent+0x34>
    800018b4:	16848493          	addi	s1,s1,360
    800018b8:	01348d63          	beq	s1,s3,800018d2 <reparent+0x4a>
    if(pp->parent == p){
    800018bc:	7c9c                	ld	a5,56(s1)
    800018be:	ff279be3          	bne	a5,s2,800018b4 <reparent+0x2c>
      pp->parent = initproc;
    800018c2:	000a3503          	ld	a0,0(s4)
    800018c6:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800018c8:	00000097          	auipc	ra,0x0
    800018cc:	f4a080e7          	jalr	-182(ra) # 80001812 <wakeup>
    800018d0:	b7d5                	j	800018b4 <reparent+0x2c>
}
    800018d2:	70a2                	ld	ra,40(sp)
    800018d4:	7402                	ld	s0,32(sp)
    800018d6:	64e2                	ld	s1,24(sp)
    800018d8:	6942                	ld	s2,16(sp)
    800018da:	69a2                	ld	s3,8(sp)
    800018dc:	6a02                	ld	s4,0(sp)
    800018de:	6145                	addi	sp,sp,48
    800018e0:	8082                	ret

00000000800018e2 <exit>:
{
    800018e2:	7179                	addi	sp,sp,-48
    800018e4:	f406                	sd	ra,40(sp)
    800018e6:	f022                	sd	s0,32(sp)
    800018e8:	ec26                	sd	s1,24(sp)
    800018ea:	e84a                	sd	s2,16(sp)
    800018ec:	e44e                	sd	s3,8(sp)
    800018ee:	e052                	sd	s4,0(sp)
    800018f0:	1800                	addi	s0,sp,48
    800018f2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800018f4:	00000097          	auipc	ra,0x0
    800018f8:	816080e7          	jalr	-2026(ra) # 8000110a <myproc>
    800018fc:	89aa                	mv	s3,a0
  if(p == initproc)
    800018fe:	00007797          	auipc	a5,0x7
    80001902:	0027b783          	ld	a5,2(a5) # 80008900 <initproc>
    80001906:	0d050493          	addi	s1,a0,208
    8000190a:	15050913          	addi	s2,a0,336
    8000190e:	02a79363          	bne	a5,a0,80001934 <exit+0x52>
    panic("init exiting");
    80001912:	00007517          	auipc	a0,0x7
    80001916:	90e50513          	addi	a0,a0,-1778 # 80008220 <etext+0x220>
    8000191a:	00004097          	auipc	ra,0x4
    8000191e:	668080e7          	jalr	1640(ra) # 80005f82 <panic>
      fileclose(f);
    80001922:	00002097          	auipc	ra,0x2
    80001926:	3ec080e7          	jalr	1004(ra) # 80003d0e <fileclose>
      p->ofile[fd] = 0;
    8000192a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000192e:	04a1                	addi	s1,s1,8
    80001930:	01248563          	beq	s1,s2,8000193a <exit+0x58>
    if(p->ofile[fd]){
    80001934:	6088                	ld	a0,0(s1)
    80001936:	f575                	bnez	a0,80001922 <exit+0x40>
    80001938:	bfdd                	j	8000192e <exit+0x4c>
  begin_op();
    8000193a:	00002097          	auipc	ra,0x2
    8000193e:	f08080e7          	jalr	-248(ra) # 80003842 <begin_op>
  iput(p->cwd);
    80001942:	1509b503          	ld	a0,336(s3)
    80001946:	00001097          	auipc	ra,0x1
    8000194a:	6f4080e7          	jalr	1780(ra) # 8000303a <iput>
  end_op();
    8000194e:	00002097          	auipc	ra,0x2
    80001952:	f74080e7          	jalr	-140(ra) # 800038c2 <end_op>
  p->cwd = 0;
    80001956:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000195a:	00227497          	auipc	s1,0x227
    8000195e:	01648493          	addi	s1,s1,22 # 80228970 <wait_lock>
    80001962:	8526                	mv	a0,s1
    80001964:	00005097          	auipc	ra,0x5
    80001968:	b68080e7          	jalr	-1176(ra) # 800064cc <acquire>
  reparent(p);
    8000196c:	854e                	mv	a0,s3
    8000196e:	00000097          	auipc	ra,0x0
    80001972:	f1a080e7          	jalr	-230(ra) # 80001888 <reparent>
  wakeup(p->parent);
    80001976:	0389b503          	ld	a0,56(s3)
    8000197a:	00000097          	auipc	ra,0x0
    8000197e:	e98080e7          	jalr	-360(ra) # 80001812 <wakeup>
  acquire(&p->lock);
    80001982:	854e                	mv	a0,s3
    80001984:	00005097          	auipc	ra,0x5
    80001988:	b48080e7          	jalr	-1208(ra) # 800064cc <acquire>
  p->xstate = status;
    8000198c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80001990:	4795                	li	a5,5
    80001992:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80001996:	8526                	mv	a0,s1
    80001998:	00005097          	auipc	ra,0x5
    8000199c:	be8080e7          	jalr	-1048(ra) # 80006580 <release>
  sched();
    800019a0:	00000097          	auipc	ra,0x0
    800019a4:	cfc080e7          	jalr	-772(ra) # 8000169c <sched>
  panic("zombie exit");
    800019a8:	00007517          	auipc	a0,0x7
    800019ac:	88850513          	addi	a0,a0,-1912 # 80008230 <etext+0x230>
    800019b0:	00004097          	auipc	ra,0x4
    800019b4:	5d2080e7          	jalr	1490(ra) # 80005f82 <panic>

00000000800019b8 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800019b8:	7179                	addi	sp,sp,-48
    800019ba:	f406                	sd	ra,40(sp)
    800019bc:	f022                	sd	s0,32(sp)
    800019be:	ec26                	sd	s1,24(sp)
    800019c0:	e84a                	sd	s2,16(sp)
    800019c2:	e44e                	sd	s3,8(sp)
    800019c4:	1800                	addi	s0,sp,48
    800019c6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800019c8:	00227497          	auipc	s1,0x227
    800019cc:	3c048493          	addi	s1,s1,960 # 80228d88 <proc>
    800019d0:	0022d997          	auipc	s3,0x22d
    800019d4:	db898993          	addi	s3,s3,-584 # 8022e788 <tickslock>
    acquire(&p->lock);
    800019d8:	8526                	mv	a0,s1
    800019da:	00005097          	auipc	ra,0x5
    800019de:	af2080e7          	jalr	-1294(ra) # 800064cc <acquire>
    if(p->pid == pid){
    800019e2:	589c                	lw	a5,48(s1)
    800019e4:	01278d63          	beq	a5,s2,800019fe <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800019e8:	8526                	mv	a0,s1
    800019ea:	00005097          	auipc	ra,0x5
    800019ee:	b96080e7          	jalr	-1130(ra) # 80006580 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800019f2:	16848493          	addi	s1,s1,360
    800019f6:	ff3491e3          	bne	s1,s3,800019d8 <kill+0x20>
  }
  return -1;
    800019fa:	557d                	li	a0,-1
    800019fc:	a829                	j	80001a16 <kill+0x5e>
      p->killed = 1;
    800019fe:	4785                	li	a5,1
    80001a00:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80001a02:	4c98                	lw	a4,24(s1)
    80001a04:	4789                	li	a5,2
    80001a06:	00f70f63          	beq	a4,a5,80001a24 <kill+0x6c>
      release(&p->lock);
    80001a0a:	8526                	mv	a0,s1
    80001a0c:	00005097          	auipc	ra,0x5
    80001a10:	b74080e7          	jalr	-1164(ra) # 80006580 <release>
      return 0;
    80001a14:	4501                	li	a0,0
}
    80001a16:	70a2                	ld	ra,40(sp)
    80001a18:	7402                	ld	s0,32(sp)
    80001a1a:	64e2                	ld	s1,24(sp)
    80001a1c:	6942                	ld	s2,16(sp)
    80001a1e:	69a2                	ld	s3,8(sp)
    80001a20:	6145                	addi	sp,sp,48
    80001a22:	8082                	ret
        p->state = RUNNABLE;
    80001a24:	478d                	li	a5,3
    80001a26:	cc9c                	sw	a5,24(s1)
    80001a28:	b7cd                	j	80001a0a <kill+0x52>

0000000080001a2a <setkilled>:

void
setkilled(struct proc *p)
{
    80001a2a:	1101                	addi	sp,sp,-32
    80001a2c:	ec06                	sd	ra,24(sp)
    80001a2e:	e822                	sd	s0,16(sp)
    80001a30:	e426                	sd	s1,8(sp)
    80001a32:	1000                	addi	s0,sp,32
    80001a34:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001a36:	00005097          	auipc	ra,0x5
    80001a3a:	a96080e7          	jalr	-1386(ra) # 800064cc <acquire>
  p->killed = 1;
    80001a3e:	4785                	li	a5,1
    80001a40:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80001a42:	8526                	mv	a0,s1
    80001a44:	00005097          	auipc	ra,0x5
    80001a48:	b3c080e7          	jalr	-1220(ra) # 80006580 <release>
}
    80001a4c:	60e2                	ld	ra,24(sp)
    80001a4e:	6442                	ld	s0,16(sp)
    80001a50:	64a2                	ld	s1,8(sp)
    80001a52:	6105                	addi	sp,sp,32
    80001a54:	8082                	ret

0000000080001a56 <killed>:

int
killed(struct proc *p)
{
    80001a56:	1101                	addi	sp,sp,-32
    80001a58:	ec06                	sd	ra,24(sp)
    80001a5a:	e822                	sd	s0,16(sp)
    80001a5c:	e426                	sd	s1,8(sp)
    80001a5e:	e04a                	sd	s2,0(sp)
    80001a60:	1000                	addi	s0,sp,32
    80001a62:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80001a64:	00005097          	auipc	ra,0x5
    80001a68:	a68080e7          	jalr	-1432(ra) # 800064cc <acquire>
  k = p->killed;
    80001a6c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80001a70:	8526                	mv	a0,s1
    80001a72:	00005097          	auipc	ra,0x5
    80001a76:	b0e080e7          	jalr	-1266(ra) # 80006580 <release>
  return k;
}
    80001a7a:	854a                	mv	a0,s2
    80001a7c:	60e2                	ld	ra,24(sp)
    80001a7e:	6442                	ld	s0,16(sp)
    80001a80:	64a2                	ld	s1,8(sp)
    80001a82:	6902                	ld	s2,0(sp)
    80001a84:	6105                	addi	sp,sp,32
    80001a86:	8082                	ret

0000000080001a88 <wait>:
{
    80001a88:	715d                	addi	sp,sp,-80
    80001a8a:	e486                	sd	ra,72(sp)
    80001a8c:	e0a2                	sd	s0,64(sp)
    80001a8e:	fc26                	sd	s1,56(sp)
    80001a90:	f84a                	sd	s2,48(sp)
    80001a92:	f44e                	sd	s3,40(sp)
    80001a94:	f052                	sd	s4,32(sp)
    80001a96:	ec56                	sd	s5,24(sp)
    80001a98:	e85a                	sd	s6,16(sp)
    80001a9a:	e45e                	sd	s7,8(sp)
    80001a9c:	e062                	sd	s8,0(sp)
    80001a9e:	0880                	addi	s0,sp,80
    80001aa0:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80001aa2:	fffff097          	auipc	ra,0xfffff
    80001aa6:	668080e7          	jalr	1640(ra) # 8000110a <myproc>
    80001aaa:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80001aac:	00227517          	auipc	a0,0x227
    80001ab0:	ec450513          	addi	a0,a0,-316 # 80228970 <wait_lock>
    80001ab4:	00005097          	auipc	ra,0x5
    80001ab8:	a18080e7          	jalr	-1512(ra) # 800064cc <acquire>
    havekids = 0;
    80001abc:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    80001abe:	4a15                	li	s4,5
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ac0:	0022d997          	auipc	s3,0x22d
    80001ac4:	cc898993          	addi	s3,s3,-824 # 8022e788 <tickslock>
        havekids = 1;
    80001ac8:	4a85                	li	s5,1
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001aca:	00227c17          	auipc	s8,0x227
    80001ace:	ea6c0c13          	addi	s8,s8,-346 # 80228970 <wait_lock>
    havekids = 0;
    80001ad2:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ad4:	00227497          	auipc	s1,0x227
    80001ad8:	2b448493          	addi	s1,s1,692 # 80228d88 <proc>
    80001adc:	a0bd                	j	80001b4a <wait+0xc2>
          pid = pp->pid;
    80001ade:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80001ae2:	000b0e63          	beqz	s6,80001afe <wait+0x76>
    80001ae6:	4691                	li	a3,4
    80001ae8:	02c48613          	addi	a2,s1,44
    80001aec:	85da                	mv	a1,s6
    80001aee:	05093503          	ld	a0,80(s2)
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	29e080e7          	jalr	670(ra) # 80000d90 <copyout>
    80001afa:	02054563          	bltz	a0,80001b24 <wait+0x9c>
          freeproc(pp);
    80001afe:	8526                	mv	a0,s1
    80001b00:	fffff097          	auipc	ra,0xfffff
    80001b04:	7bc080e7          	jalr	1980(ra) # 800012bc <freeproc>
          release(&pp->lock);
    80001b08:	8526                	mv	a0,s1
    80001b0a:	00005097          	auipc	ra,0x5
    80001b0e:	a76080e7          	jalr	-1418(ra) # 80006580 <release>
          release(&wait_lock);
    80001b12:	00227517          	auipc	a0,0x227
    80001b16:	e5e50513          	addi	a0,a0,-418 # 80228970 <wait_lock>
    80001b1a:	00005097          	auipc	ra,0x5
    80001b1e:	a66080e7          	jalr	-1434(ra) # 80006580 <release>
          return pid;
    80001b22:	a0b5                	j	80001b8e <wait+0x106>
            release(&pp->lock);
    80001b24:	8526                	mv	a0,s1
    80001b26:	00005097          	auipc	ra,0x5
    80001b2a:	a5a080e7          	jalr	-1446(ra) # 80006580 <release>
            release(&wait_lock);
    80001b2e:	00227517          	auipc	a0,0x227
    80001b32:	e4250513          	addi	a0,a0,-446 # 80228970 <wait_lock>
    80001b36:	00005097          	auipc	ra,0x5
    80001b3a:	a4a080e7          	jalr	-1462(ra) # 80006580 <release>
            return -1;
    80001b3e:	59fd                	li	s3,-1
    80001b40:	a0b9                	j	80001b8e <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80001b42:	16848493          	addi	s1,s1,360
    80001b46:	03348463          	beq	s1,s3,80001b6e <wait+0xe6>
      if(pp->parent == p){
    80001b4a:	7c9c                	ld	a5,56(s1)
    80001b4c:	ff279be3          	bne	a5,s2,80001b42 <wait+0xba>
        acquire(&pp->lock);
    80001b50:	8526                	mv	a0,s1
    80001b52:	00005097          	auipc	ra,0x5
    80001b56:	97a080e7          	jalr	-1670(ra) # 800064cc <acquire>
        if(pp->state == ZOMBIE){
    80001b5a:	4c9c                	lw	a5,24(s1)
    80001b5c:	f94781e3          	beq	a5,s4,80001ade <wait+0x56>
        release(&pp->lock);
    80001b60:	8526                	mv	a0,s1
    80001b62:	00005097          	auipc	ra,0x5
    80001b66:	a1e080e7          	jalr	-1506(ra) # 80006580 <release>
        havekids = 1;
    80001b6a:	8756                	mv	a4,s5
    80001b6c:	bfd9                	j	80001b42 <wait+0xba>
    if(!havekids || killed(p)){
    80001b6e:	c719                	beqz	a4,80001b7c <wait+0xf4>
    80001b70:	854a                	mv	a0,s2
    80001b72:	00000097          	auipc	ra,0x0
    80001b76:	ee4080e7          	jalr	-284(ra) # 80001a56 <killed>
    80001b7a:	c51d                	beqz	a0,80001ba8 <wait+0x120>
      release(&wait_lock);
    80001b7c:	00227517          	auipc	a0,0x227
    80001b80:	df450513          	addi	a0,a0,-524 # 80228970 <wait_lock>
    80001b84:	00005097          	auipc	ra,0x5
    80001b88:	9fc080e7          	jalr	-1540(ra) # 80006580 <release>
      return -1;
    80001b8c:	59fd                	li	s3,-1
}
    80001b8e:	854e                	mv	a0,s3
    80001b90:	60a6                	ld	ra,72(sp)
    80001b92:	6406                	ld	s0,64(sp)
    80001b94:	74e2                	ld	s1,56(sp)
    80001b96:	7942                	ld	s2,48(sp)
    80001b98:	79a2                	ld	s3,40(sp)
    80001b9a:	7a02                	ld	s4,32(sp)
    80001b9c:	6ae2                	ld	s5,24(sp)
    80001b9e:	6b42                	ld	s6,16(sp)
    80001ba0:	6ba2                	ld	s7,8(sp)
    80001ba2:	6c02                	ld	s8,0(sp)
    80001ba4:	6161                	addi	sp,sp,80
    80001ba6:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80001ba8:	85e2                	mv	a1,s8
    80001baa:	854a                	mv	a0,s2
    80001bac:	00000097          	auipc	ra,0x0
    80001bb0:	c02080e7          	jalr	-1022(ra) # 800017ae <sleep>
    havekids = 0;
    80001bb4:	bf39                	j	80001ad2 <wait+0x4a>

0000000080001bb6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80001bb6:	7179                	addi	sp,sp,-48
    80001bb8:	f406                	sd	ra,40(sp)
    80001bba:	f022                	sd	s0,32(sp)
    80001bbc:	ec26                	sd	s1,24(sp)
    80001bbe:	e84a                	sd	s2,16(sp)
    80001bc0:	e44e                	sd	s3,8(sp)
    80001bc2:	e052                	sd	s4,0(sp)
    80001bc4:	1800                	addi	s0,sp,48
    80001bc6:	84aa                	mv	s1,a0
    80001bc8:	892e                	mv	s2,a1
    80001bca:	89b2                	mv	s3,a2
    80001bcc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	53c080e7          	jalr	1340(ra) # 8000110a <myproc>
  if(user_dst){
    80001bd6:	c08d                	beqz	s1,80001bf8 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80001bd8:	86d2                	mv	a3,s4
    80001bda:	864e                	mv	a2,s3
    80001bdc:	85ca                	mv	a1,s2
    80001bde:	6928                	ld	a0,80(a0)
    80001be0:	fffff097          	auipc	ra,0xfffff
    80001be4:	1b0080e7          	jalr	432(ra) # 80000d90 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80001be8:	70a2                	ld	ra,40(sp)
    80001bea:	7402                	ld	s0,32(sp)
    80001bec:	64e2                	ld	s1,24(sp)
    80001bee:	6942                	ld	s2,16(sp)
    80001bf0:	69a2                	ld	s3,8(sp)
    80001bf2:	6a02                	ld	s4,0(sp)
    80001bf4:	6145                	addi	sp,sp,48
    80001bf6:	8082                	ret
    memmove((char *)dst, src, len);
    80001bf8:	000a061b          	sext.w	a2,s4
    80001bfc:	85ce                	mv	a1,s3
    80001bfe:	854a                	mv	a0,s2
    80001c00:	ffffe097          	auipc	ra,0xffffe
    80001c04:	7fc080e7          	jalr	2044(ra) # 800003fc <memmove>
    return 0;
    80001c08:	8526                	mv	a0,s1
    80001c0a:	bff9                	j	80001be8 <either_copyout+0x32>

0000000080001c0c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80001c0c:	7179                	addi	sp,sp,-48
    80001c0e:	f406                	sd	ra,40(sp)
    80001c10:	f022                	sd	s0,32(sp)
    80001c12:	ec26                	sd	s1,24(sp)
    80001c14:	e84a                	sd	s2,16(sp)
    80001c16:	e44e                	sd	s3,8(sp)
    80001c18:	e052                	sd	s4,0(sp)
    80001c1a:	1800                	addi	s0,sp,48
    80001c1c:	892a                	mv	s2,a0
    80001c1e:	84ae                	mv	s1,a1
    80001c20:	89b2                	mv	s3,a2
    80001c22:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001c24:	fffff097          	auipc	ra,0xfffff
    80001c28:	4e6080e7          	jalr	1254(ra) # 8000110a <myproc>
  if(user_src){
    80001c2c:	c08d                	beqz	s1,80001c4e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80001c2e:	86d2                	mv	a3,s4
    80001c30:	864e                	mv	a2,s3
    80001c32:	85ca                	mv	a1,s2
    80001c34:	6928                	ld	a0,80(a0)
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	21e080e7          	jalr	542(ra) # 80000e54 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001c3e:	70a2                	ld	ra,40(sp)
    80001c40:	7402                	ld	s0,32(sp)
    80001c42:	64e2                	ld	s1,24(sp)
    80001c44:	6942                	ld	s2,16(sp)
    80001c46:	69a2                	ld	s3,8(sp)
    80001c48:	6a02                	ld	s4,0(sp)
    80001c4a:	6145                	addi	sp,sp,48
    80001c4c:	8082                	ret
    memmove(dst, (char*)src, len);
    80001c4e:	000a061b          	sext.w	a2,s4
    80001c52:	85ce                	mv	a1,s3
    80001c54:	854a                	mv	a0,s2
    80001c56:	ffffe097          	auipc	ra,0xffffe
    80001c5a:	7a6080e7          	jalr	1958(ra) # 800003fc <memmove>
    return 0;
    80001c5e:	8526                	mv	a0,s1
    80001c60:	bff9                	j	80001c3e <either_copyin+0x32>

0000000080001c62 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001c62:	715d                	addi	sp,sp,-80
    80001c64:	e486                	sd	ra,72(sp)
    80001c66:	e0a2                	sd	s0,64(sp)
    80001c68:	fc26                	sd	s1,56(sp)
    80001c6a:	f84a                	sd	s2,48(sp)
    80001c6c:	f44e                	sd	s3,40(sp)
    80001c6e:	f052                	sd	s4,32(sp)
    80001c70:	ec56                	sd	s5,24(sp)
    80001c72:	e85a                	sd	s6,16(sp)
    80001c74:	e45e                	sd	s7,8(sp)
    80001c76:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001c78:	00006517          	auipc	a0,0x6
    80001c7c:	41050513          	addi	a0,a0,1040 # 80008088 <etext+0x88>
    80001c80:	00004097          	auipc	ra,0x4
    80001c84:	34c080e7          	jalr	844(ra) # 80005fcc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001c88:	00227497          	auipc	s1,0x227
    80001c8c:	25848493          	addi	s1,s1,600 # 80228ee0 <proc+0x158>
    80001c90:	0022d917          	auipc	s2,0x22d
    80001c94:	c5090913          	addi	s2,s2,-944 # 8022e8e0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001c98:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80001c9a:	00006997          	auipc	s3,0x6
    80001c9e:	5a698993          	addi	s3,s3,1446 # 80008240 <etext+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80001ca2:	00006a97          	auipc	s5,0x6
    80001ca6:	5a6a8a93          	addi	s5,s5,1446 # 80008248 <etext+0x248>
    printf("\n");
    80001caa:	00006a17          	auipc	s4,0x6
    80001cae:	3dea0a13          	addi	s4,s4,990 # 80008088 <etext+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001cb2:	00006b97          	auipc	s7,0x6
    80001cb6:	5d6b8b93          	addi	s7,s7,1494 # 80008288 <states.1725>
    80001cba:	a00d                	j	80001cdc <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    80001cbc:	ed86a583          	lw	a1,-296(a3)
    80001cc0:	8556                	mv	a0,s5
    80001cc2:	00004097          	auipc	ra,0x4
    80001cc6:	30a080e7          	jalr	778(ra) # 80005fcc <printf>
    printf("\n");
    80001cca:	8552                	mv	a0,s4
    80001ccc:	00004097          	auipc	ra,0x4
    80001cd0:	300080e7          	jalr	768(ra) # 80005fcc <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001cd4:	16848493          	addi	s1,s1,360
    80001cd8:	03248163          	beq	s1,s2,80001cfa <procdump+0x98>
    if(p->state == UNUSED)
    80001cdc:	86a6                	mv	a3,s1
    80001cde:	ec04a783          	lw	a5,-320(s1)
    80001ce2:	dbed                	beqz	a5,80001cd4 <procdump+0x72>
      state = "???";
    80001ce4:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001ce6:	fcfb6be3          	bltu	s6,a5,80001cbc <procdump+0x5a>
    80001cea:	1782                	slli	a5,a5,0x20
    80001cec:	9381                	srli	a5,a5,0x20
    80001cee:	078e                	slli	a5,a5,0x3
    80001cf0:	97de                	add	a5,a5,s7
    80001cf2:	6390                	ld	a2,0(a5)
    80001cf4:	f661                	bnez	a2,80001cbc <procdump+0x5a>
      state = "???";
    80001cf6:	864e                	mv	a2,s3
    80001cf8:	b7d1                	j	80001cbc <procdump+0x5a>
  }
}
    80001cfa:	60a6                	ld	ra,72(sp)
    80001cfc:	6406                	ld	s0,64(sp)
    80001cfe:	74e2                	ld	s1,56(sp)
    80001d00:	7942                	ld	s2,48(sp)
    80001d02:	79a2                	ld	s3,40(sp)
    80001d04:	7a02                	ld	s4,32(sp)
    80001d06:	6ae2                	ld	s5,24(sp)
    80001d08:	6b42                	ld	s6,16(sp)
    80001d0a:	6ba2                	ld	s7,8(sp)
    80001d0c:	6161                	addi	sp,sp,80
    80001d0e:	8082                	ret

0000000080001d10 <swtch>:
    80001d10:	00153023          	sd	ra,0(a0)
    80001d14:	00253423          	sd	sp,8(a0)
    80001d18:	e900                	sd	s0,16(a0)
    80001d1a:	ed04                	sd	s1,24(a0)
    80001d1c:	03253023          	sd	s2,32(a0)
    80001d20:	03353423          	sd	s3,40(a0)
    80001d24:	03453823          	sd	s4,48(a0)
    80001d28:	03553c23          	sd	s5,56(a0)
    80001d2c:	05653023          	sd	s6,64(a0)
    80001d30:	05753423          	sd	s7,72(a0)
    80001d34:	05853823          	sd	s8,80(a0)
    80001d38:	05953c23          	sd	s9,88(a0)
    80001d3c:	07a53023          	sd	s10,96(a0)
    80001d40:	07b53423          	sd	s11,104(a0)
    80001d44:	0005b083          	ld	ra,0(a1)
    80001d48:	0085b103          	ld	sp,8(a1)
    80001d4c:	6980                	ld	s0,16(a1)
    80001d4e:	6d84                	ld	s1,24(a1)
    80001d50:	0205b903          	ld	s2,32(a1)
    80001d54:	0285b983          	ld	s3,40(a1)
    80001d58:	0305ba03          	ld	s4,48(a1)
    80001d5c:	0385ba83          	ld	s5,56(a1)
    80001d60:	0405bb03          	ld	s6,64(a1)
    80001d64:	0485bb83          	ld	s7,72(a1)
    80001d68:	0505bc03          	ld	s8,80(a1)
    80001d6c:	0585bc83          	ld	s9,88(a1)
    80001d70:	0605bd03          	ld	s10,96(a1)
    80001d74:	0685bd83          	ld	s11,104(a1)
    80001d78:	8082                	ret

0000000080001d7a <page_fault_handling>:

extern int devintr();

// function to handle page faults, takes in a virtual address and a page table.
// 
int page_fault_handling(void* va, pagetable_t pagetable){
    80001d7a:	7179                	addi	sp,sp,-48
    80001d7c:	f406                	sd	ra,40(sp)
    80001d7e:	f022                	sd	s0,32(sp)
    80001d80:	ec26                	sd	s1,24(sp)
    80001d82:	e84a                	sd	s2,16(sp)
    80001d84:	e44e                	sd	s3,8(sp)
    80001d86:	e052                	sd	s4,0(sp)
    80001d88:	1800                	addi	s0,sp,48
    80001d8a:	84aa                	mv	s1,a0
    80001d8c:	892e                	mv	s2,a1
  struct proc* p = myproc();
    80001d8e:	fffff097          	auipc	ra,0xfffff
    80001d92:	37c080e7          	jalr	892(ra) # 8000110a <myproc>
  pte_t *pte;
  uint64 pa;
  uint flags;
  // check if the virtual address is beyond the maximum or within the guard page range
  if ((uint64)va >= MAXVA || ((uint64)va >= PGROUNDDOWN(p->trapframe->sp) - PGSIZE &&
    80001d96:	57fd                	li	a5,-1
    80001d98:	83e9                	srli	a5,a5,0x1a
    80001d9a:	0897e563          	bltu	a5,s1,80001e24 <page_fault_handling+0xaa>
    80001d9e:	6d38                	ld	a4,88(a0)
    80001da0:	77fd                	lui	a5,0xfffff
    80001da2:	7b18                	ld	a4,48(a4)
    80001da4:	8f7d                	and	a4,a4,a5
    80001da6:	97ba                	add	a5,a5,a4
    80001da8:	00f4e463          	bltu	s1,a5,80001db0 <page_fault_handling+0x36>
    80001dac:	06977e63          	bgeu	a4,s1,80001e28 <page_fault_handling+0xae>
     (uint64)va <= PGROUNDDOWN(p->trapframe->sp))) {
    return -2; //invalid
  }
  va = (void*)PGROUNDDOWN((uint64)va); // align the address to page boundary
  pte = walk(pagetable, (uint64)va, 0); // find the page table entry for the address
    80001db0:	4601                	li	a2,0
    80001db2:	75fd                	lui	a1,0xfffff
    80001db4:	8de5                	and	a1,a1,s1
    80001db6:	854a                	mv	a0,s2
    80001db8:	fffff097          	auipc	ra,0xfffff
    80001dbc:	8d0080e7          	jalr	-1840(ra) # 80000688 <walk>
    80001dc0:	892a                	mv	s2,a0
  if (pte == 0) {
    80001dc2:	c52d                	beqz	a0,80001e2c <page_fault_handling+0xb2>
    return -1; //not found
  }
  pa = PTE2PA(*pte); // get physical address from the PTE
    80001dc4:	611c                	ld	a5,0(a0)
    80001dc6:	00a7d993          	srli	s3,a5,0xa
    80001dca:	09b2                	slli	s3,s3,0xc
  if (pa == 0) {
    80001dcc:	06098263          	beqz	s3,80001e30 <page_fault_handling+0xb6>
    return -1; //invalid
  }
  flags = PTE_FLAGS(*pte); // extract flags from the PTE
    80001dd0:	2781                	sext.w	a5,a5
  
  // check if the page is marked as COW
  if (flags & PTE_COW) {
    80001dd2:	1007f713          	andi	a4,a5,256
    memmove(mem, (void*)pa, PGSIZE); // copy the content of the old page to the new page
    *pte = PA2PTE((uint64)mem) | flags; // update the PTE to point to the new page
    kfree((void*)pa); // free the old page
    return 0;
  }
  return 0;
    80001dd6:	4501                	li	a0,0
  if (flags & PTE_COW) {
    80001dd8:	eb09                	bnez	a4,80001dea <page_fault_handling+0x70>
}
    80001dda:	70a2                	ld	ra,40(sp)
    80001ddc:	7402                	ld	s0,32(sp)
    80001dde:	64e2                	ld	s1,24(sp)
    80001de0:	6942                	ld	s2,16(sp)
    80001de2:	69a2                	ld	s3,8(sp)
    80001de4:	6a02                	ld	s4,0(sp)
    80001de6:	6145                	addi	sp,sp,48
    80001de8:	8082                	ret
    flags = (flags | PTE_W) & (~PTE_COW); // change the page to writable and clear the COW flag
    80001dea:	2ff7f793          	andi	a5,a5,767
    80001dee:	0047e493          	ori	s1,a5,4
    char *mem = kalloc(); // allocate a new page
    80001df2:	ffffe097          	auipc	ra,0xffffe
    80001df6:	54a080e7          	jalr	1354(ra) # 8000033c <kalloc>
    80001dfa:	8a2a                	mv	s4,a0
    if (mem == 0) {
    80001dfc:	cd05                	beqz	a0,80001e34 <page_fault_handling+0xba>
    memmove(mem, (void*)pa, PGSIZE); // copy the content of the old page to the new page
    80001dfe:	6605                	lui	a2,0x1
    80001e00:	85ce                	mv	a1,s3
    80001e02:	ffffe097          	auipc	ra,0xffffe
    80001e06:	5fa080e7          	jalr	1530(ra) # 800003fc <memmove>
    *pte = PA2PTE((uint64)mem) | flags; // update the PTE to point to the new page
    80001e0a:	00ca5793          	srli	a5,s4,0xc
    80001e0e:	07aa                	slli	a5,a5,0xa
    80001e10:	8fc5                	or	a5,a5,s1
    80001e12:	00f93023          	sd	a5,0(s2)
    kfree((void*)pa); // free the old page
    80001e16:	854e                	mv	a0,s3
    80001e18:	ffffe097          	auipc	ra,0xffffe
    80001e1c:	39c080e7          	jalr	924(ra) # 800001b4 <kfree>
    return 0;
    80001e20:	4501                	li	a0,0
    80001e22:	bf65                	j	80001dda <page_fault_handling+0x60>
    return -2; //invalid
    80001e24:	5579                	li	a0,-2
    80001e26:	bf55                	j	80001dda <page_fault_handling+0x60>
    80001e28:	5579                	li	a0,-2
    80001e2a:	bf45                	j	80001dda <page_fault_handling+0x60>
    return -1; //not found
    80001e2c:	557d                	li	a0,-1
    80001e2e:	b775                	j	80001dda <page_fault_handling+0x60>
    return -1; //invalid
    80001e30:	557d                	li	a0,-1
    80001e32:	b765                	j	80001dda <page_fault_handling+0x60>
      return -1; // memory allocation failed
    80001e34:	557d                	li	a0,-1
    80001e36:	b755                	j	80001dda <page_fault_handling+0x60>

0000000080001e38 <trapinit>:

void
trapinit(void)
{
    80001e38:	1141                	addi	sp,sp,-16
    80001e3a:	e406                	sd	ra,8(sp)
    80001e3c:	e022                	sd	s0,0(sp)
    80001e3e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001e40:	00006597          	auipc	a1,0x6
    80001e44:	47858593          	addi	a1,a1,1144 # 800082b8 <states.1725+0x30>
    80001e48:	0022d517          	auipc	a0,0x22d
    80001e4c:	94050513          	addi	a0,a0,-1728 # 8022e788 <tickslock>
    80001e50:	00004097          	auipc	ra,0x4
    80001e54:	5ec080e7          	jalr	1516(ra) # 8000643c <initlock>
}
    80001e58:	60a2                	ld	ra,8(sp)
    80001e5a:	6402                	ld	s0,0(sp)
    80001e5c:	0141                	addi	sp,sp,16
    80001e5e:	8082                	ret

0000000080001e60 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001e60:	1141                	addi	sp,sp,-16
    80001e62:	e422                	sd	s0,8(sp)
    80001e64:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001e66:	00003797          	auipc	a5,0x3
    80001e6a:	4ea78793          	addi	a5,a5,1258 # 80005350 <kernelvec>
    80001e6e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001e72:	6422                	ld	s0,8(sp)
    80001e74:	0141                	addi	sp,sp,16
    80001e76:	8082                	ret

0000000080001e78 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001e78:	1141                	addi	sp,sp,-16
    80001e7a:	e406                	sd	ra,8(sp)
    80001e7c:	e022                	sd	s0,0(sp)
    80001e7e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	28a080e7          	jalr	650(ra) # 8000110a <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e88:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e8c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e8e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80001e92:	00005617          	auipc	a2,0x5
    80001e96:	16e60613          	addi	a2,a2,366 # 80007000 <_trampoline>
    80001e9a:	00005697          	auipc	a3,0x5
    80001e9e:	16668693          	addi	a3,a3,358 # 80007000 <_trampoline>
    80001ea2:	8e91                	sub	a3,a3,a2
    80001ea4:	040007b7          	lui	a5,0x4000
    80001ea8:	17fd                	addi	a5,a5,-1
    80001eaa:	07b2                	slli	a5,a5,0xc
    80001eac:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001eae:	10569073          	csrw	stvec,a3
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001eb2:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001eb4:	180026f3          	csrr	a3,satp
    80001eb8:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001eba:	6d38                	ld	a4,88(a0)
    80001ebc:	6134                	ld	a3,64(a0)
    80001ebe:	6585                	lui	a1,0x1
    80001ec0:	96ae                	add	a3,a3,a1
    80001ec2:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001ec4:	6d38                	ld	a4,88(a0)
    80001ec6:	00000697          	auipc	a3,0x0
    80001eca:	13068693          	addi	a3,a3,304 # 80001ff6 <usertrap>
    80001ece:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001ed0:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ed2:	8692                	mv	a3,tp
    80001ed4:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ed6:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001eda:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001ede:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ee2:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001ee6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001ee8:	6f18                	ld	a4,24(a4)
    80001eea:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001eee:	6928                	ld	a0,80(a0)
    80001ef0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001ef2:	00005717          	auipc	a4,0x5
    80001ef6:	1aa70713          	addi	a4,a4,426 # 8000709c <userret>
    80001efa:	8f11                	sub	a4,a4,a2
    80001efc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001efe:	577d                	li	a4,-1
    80001f00:	177e                	slli	a4,a4,0x3f
    80001f02:	8d59                	or	a0,a0,a4
    80001f04:	9782                	jalr	a5
}
    80001f06:	60a2                	ld	ra,8(sp)
    80001f08:	6402                	ld	s0,0(sp)
    80001f0a:	0141                	addi	sp,sp,16
    80001f0c:	8082                	ret

0000000080001f0e <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001f0e:	1101                	addi	sp,sp,-32
    80001f10:	ec06                	sd	ra,24(sp)
    80001f12:	e822                	sd	s0,16(sp)
    80001f14:	e426                	sd	s1,8(sp)
    80001f16:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001f18:	0022d497          	auipc	s1,0x22d
    80001f1c:	87048493          	addi	s1,s1,-1936 # 8022e788 <tickslock>
    80001f20:	8526                	mv	a0,s1
    80001f22:	00004097          	auipc	ra,0x4
    80001f26:	5aa080e7          	jalr	1450(ra) # 800064cc <acquire>
  ticks++;
    80001f2a:	00007517          	auipc	a0,0x7
    80001f2e:	9de50513          	addi	a0,a0,-1570 # 80008908 <ticks>
    80001f32:	411c                	lw	a5,0(a0)
    80001f34:	2785                	addiw	a5,a5,1
    80001f36:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001f38:	00000097          	auipc	ra,0x0
    80001f3c:	8da080e7          	jalr	-1830(ra) # 80001812 <wakeup>
  release(&tickslock);
    80001f40:	8526                	mv	a0,s1
    80001f42:	00004097          	auipc	ra,0x4
    80001f46:	63e080e7          	jalr	1598(ra) # 80006580 <release>
}
    80001f4a:	60e2                	ld	ra,24(sp)
    80001f4c:	6442                	ld	s0,16(sp)
    80001f4e:	64a2                	ld	s1,8(sp)
    80001f50:	6105                	addi	sp,sp,32
    80001f52:	8082                	ret

0000000080001f54 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001f54:	1101                	addi	sp,sp,-32
    80001f56:	ec06                	sd	ra,24(sp)
    80001f58:	e822                	sd	s0,16(sp)
    80001f5a:	e426                	sd	s1,8(sp)
    80001f5c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001f5e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001f62:	00074d63          	bltz	a4,80001f7c <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001f66:	57fd                	li	a5,-1
    80001f68:	17fe                	slli	a5,a5,0x3f
    80001f6a:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001f6c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001f6e:	06f70363          	beq	a4,a5,80001fd4 <devintr+0x80>
  }
}
    80001f72:	60e2                	ld	ra,24(sp)
    80001f74:	6442                	ld	s0,16(sp)
    80001f76:	64a2                	ld	s1,8(sp)
    80001f78:	6105                	addi	sp,sp,32
    80001f7a:	8082                	ret
     (scause & 0xff) == 9){
    80001f7c:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001f80:	46a5                	li	a3,9
    80001f82:	fed792e3          	bne	a5,a3,80001f66 <devintr+0x12>
    int irq = plic_claim();
    80001f86:	00003097          	auipc	ra,0x3
    80001f8a:	4d2080e7          	jalr	1234(ra) # 80005458 <plic_claim>
    80001f8e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001f90:	47a9                	li	a5,10
    80001f92:	02f50763          	beq	a0,a5,80001fc0 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80001f96:	4785                	li	a5,1
    80001f98:	02f50963          	beq	a0,a5,80001fca <devintr+0x76>
    return 1;
    80001f9c:	4505                	li	a0,1
    } else if(irq){
    80001f9e:	d8f1                	beqz	s1,80001f72 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001fa0:	85a6                	mv	a1,s1
    80001fa2:	00006517          	auipc	a0,0x6
    80001fa6:	31e50513          	addi	a0,a0,798 # 800082c0 <states.1725+0x38>
    80001faa:	00004097          	auipc	ra,0x4
    80001fae:	022080e7          	jalr	34(ra) # 80005fcc <printf>
      plic_complete(irq);
    80001fb2:	8526                	mv	a0,s1
    80001fb4:	00003097          	auipc	ra,0x3
    80001fb8:	4c8080e7          	jalr	1224(ra) # 8000547c <plic_complete>
    return 1;
    80001fbc:	4505                	li	a0,1
    80001fbe:	bf55                	j	80001f72 <devintr+0x1e>
      uartintr();
    80001fc0:	00004097          	auipc	ra,0x4
    80001fc4:	42c080e7          	jalr	1068(ra) # 800063ec <uartintr>
    80001fc8:	b7ed                	j	80001fb2 <devintr+0x5e>
      virtio_disk_intr();
    80001fca:	00004097          	auipc	ra,0x4
    80001fce:	9dc080e7          	jalr	-1572(ra) # 800059a6 <virtio_disk_intr>
    80001fd2:	b7c5                	j	80001fb2 <devintr+0x5e>
    if(cpuid() == 0){
    80001fd4:	fffff097          	auipc	ra,0xfffff
    80001fd8:	10a080e7          	jalr	266(ra) # 800010de <cpuid>
    80001fdc:	c901                	beqz	a0,80001fec <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001fde:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001fe2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001fe4:	14479073          	csrw	sip,a5
    return 2;
    80001fe8:	4509                	li	a0,2
    80001fea:	b761                	j	80001f72 <devintr+0x1e>
      clockintr();
    80001fec:	00000097          	auipc	ra,0x0
    80001ff0:	f22080e7          	jalr	-222(ra) # 80001f0e <clockintr>
    80001ff4:	b7ed                	j	80001fde <devintr+0x8a>

0000000080001ff6 <usertrap>:
usertrap(void) {
    80001ff6:	1101                	addi	sp,sp,-32
    80001ff8:	ec06                	sd	ra,24(sp)
    80001ffa:	e822                	sd	s0,16(sp)
    80001ffc:	e426                	sd	s1,8(sp)
    80001ffe:	e04a                	sd	s2,0(sp)
    80002000:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002002:	100027f3          	csrr	a5,sstatus
    if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002006:	1007f793          	andi	a5,a5,256
    8000200a:	e3b5                	bnez	a5,8000206e <usertrap+0x78>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000200c:	00003797          	auipc	a5,0x3
    80002010:	34478793          	addi	a5,a5,836 # 80005350 <kernelvec>
    80002014:	10579073          	csrw	stvec,a5
    struct proc *p = myproc();
    80002018:	fffff097          	auipc	ra,0xfffff
    8000201c:	0f2080e7          	jalr	242(ra) # 8000110a <myproc>
    80002020:	84aa                	mv	s1,a0
    p->trapframe->epc = r_sepc();
    80002022:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002024:	14102773          	csrr	a4,sepc
    80002028:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000202a:	14202773          	csrr	a4,scause
    if (r_scause() == 8) {
    8000202e:	47a1                	li	a5,8
    80002030:	04f70763          	beq	a4,a5,8000207e <usertrap+0x88>
    } else if ((which_dev = devintr()) != 0) {
    80002034:	00000097          	auipc	ra,0x0
    80002038:	f20080e7          	jalr	-224(ra) # 80001f54 <devintr>
    8000203c:	892a                	mv	s2,a0
    8000203e:	e571                	bnez	a0,8000210a <usertrap+0x114>
    80002040:	14202773          	csrr	a4,scause
    } else if (r_scause() == 15 || r_scause() == 13) { // check if the cause is a page fault (load or store)
    80002044:	47bd                	li	a5,15
    80002046:	00f70763          	beq	a4,a5,80002054 <usertrap+0x5e>
    8000204a:	14202773          	csrr	a4,scause
    8000204e:	47b5                	li	a5,13
    80002050:	08f71063          	bne	a4,a5,800020d0 <usertrap+0xda>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002054:	14302573          	csrr	a0,stval
        int res = page_fault_handling((void*)r_stval(), p->pagetable); // handle the page fault
    80002058:	68ac                	ld	a1,80(s1)
    8000205a:	00000097          	auipc	ra,0x0
    8000205e:	d20080e7          	jalr	-736(ra) # 80001d7a <page_fault_handling>
        if (res == -1 || res == -2) {
    80002062:	2509                	addiw	a0,a0,2
    80002064:	4785                	li	a5,1
    80002066:	02a7ef63          	bltu	a5,a0,800020a4 <usertrap+0xae>
            p->killed = 1; // kill the process if the page fault was invalid or couldn't be handled
    8000206a:	d49c                	sw	a5,40(s1)
    8000206c:	a825                	j	800020a4 <usertrap+0xae>
        panic("usertrap: not from user mode");
    8000206e:	00006517          	auipc	a0,0x6
    80002072:	27250513          	addi	a0,a0,626 # 800082e0 <states.1725+0x58>
    80002076:	00004097          	auipc	ra,0x4
    8000207a:	f0c080e7          	jalr	-244(ra) # 80005f82 <panic>
        if (killed(p))
    8000207e:	00000097          	auipc	ra,0x0
    80002082:	9d8080e7          	jalr	-1576(ra) # 80001a56 <killed>
    80002086:	ed1d                	bnez	a0,800020c4 <usertrap+0xce>
        p->trapframe->epc += 4;
    80002088:	6cb8                	ld	a4,88(s1)
    8000208a:	6f1c                	ld	a5,24(a4)
    8000208c:	0791                	addi	a5,a5,4
    8000208e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002090:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002094:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002098:	10079073          	csrw	sstatus,a5
        syscall();
    8000209c:	00000097          	auipc	ra,0x0
    800020a0:	2e2080e7          	jalr	738(ra) # 8000237e <syscall>
    if (killed(p))
    800020a4:	8526                	mv	a0,s1
    800020a6:	00000097          	auipc	ra,0x0
    800020aa:	9b0080e7          	jalr	-1616(ra) # 80001a56 <killed>
    800020ae:	e52d                	bnez	a0,80002118 <usertrap+0x122>
    usertrapret();
    800020b0:	00000097          	auipc	ra,0x0
    800020b4:	dc8080e7          	jalr	-568(ra) # 80001e78 <usertrapret>
}
    800020b8:	60e2                	ld	ra,24(sp)
    800020ba:	6442                	ld	s0,16(sp)
    800020bc:	64a2                	ld	s1,8(sp)
    800020be:	6902                	ld	s2,0(sp)
    800020c0:	6105                	addi	sp,sp,32
    800020c2:	8082                	ret
            exit(-1);
    800020c4:	557d                	li	a0,-1
    800020c6:	00000097          	auipc	ra,0x0
    800020ca:	81c080e7          	jalr	-2020(ra) # 800018e2 <exit>
    800020ce:	bf6d                	j	80002088 <usertrap+0x92>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800020d0:	142025f3          	csrr	a1,scause
        printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800020d4:	5890                	lw	a2,48(s1)
    800020d6:	00006517          	auipc	a0,0x6
    800020da:	22a50513          	addi	a0,a0,554 # 80008300 <states.1725+0x78>
    800020de:	00004097          	auipc	ra,0x4
    800020e2:	eee080e7          	jalr	-274(ra) # 80005fcc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800020e6:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800020ea:	14302673          	csrr	a2,stval
        printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800020ee:	00006517          	auipc	a0,0x6
    800020f2:	24250513          	addi	a0,a0,578 # 80008330 <states.1725+0xa8>
    800020f6:	00004097          	auipc	ra,0x4
    800020fa:	ed6080e7          	jalr	-298(ra) # 80005fcc <printf>
        setkilled(p);
    800020fe:	8526                	mv	a0,s1
    80002100:	00000097          	auipc	ra,0x0
    80002104:	92a080e7          	jalr	-1750(ra) # 80001a2a <setkilled>
    80002108:	bf71                	j	800020a4 <usertrap+0xae>
    if (killed(p))
    8000210a:	8526                	mv	a0,s1
    8000210c:	00000097          	auipc	ra,0x0
    80002110:	94a080e7          	jalr	-1718(ra) # 80001a56 <killed>
    80002114:	c901                	beqz	a0,80002124 <usertrap+0x12e>
    80002116:	a011                	j	8000211a <usertrap+0x124>
    80002118:	4901                	li	s2,0
        exit(-1);
    8000211a:	557d                	li	a0,-1
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	7c6080e7          	jalr	1990(ra) # 800018e2 <exit>
    if (which_dev == 2)
    80002124:	4789                	li	a5,2
    80002126:	f8f915e3          	bne	s2,a5,800020b0 <usertrap+0xba>
        yield();
    8000212a:	fffff097          	auipc	ra,0xfffff
    8000212e:	648080e7          	jalr	1608(ra) # 80001772 <yield>
    80002132:	bfbd                	j	800020b0 <usertrap+0xba>

0000000080002134 <kerneltrap>:
{
    80002134:	7179                	addi	sp,sp,-48
    80002136:	f406                	sd	ra,40(sp)
    80002138:	f022                	sd	s0,32(sp)
    8000213a:	ec26                	sd	s1,24(sp)
    8000213c:	e84a                	sd	s2,16(sp)
    8000213e:	e44e                	sd	s3,8(sp)
    80002140:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002142:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002146:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000214a:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    8000214e:	1004f793          	andi	a5,s1,256
    80002152:	cb85                	beqz	a5,80002182 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002154:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002158:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    8000215a:	ef85                	bnez	a5,80002192 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    8000215c:	00000097          	auipc	ra,0x0
    80002160:	df8080e7          	jalr	-520(ra) # 80001f54 <devintr>
    80002164:	cd1d                	beqz	a0,800021a2 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002166:	4789                	li	a5,2
    80002168:	06f50a63          	beq	a0,a5,800021dc <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000216c:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002170:	10049073          	csrw	sstatus,s1
}
    80002174:	70a2                	ld	ra,40(sp)
    80002176:	7402                	ld	s0,32(sp)
    80002178:	64e2                	ld	s1,24(sp)
    8000217a:	6942                	ld	s2,16(sp)
    8000217c:	69a2                	ld	s3,8(sp)
    8000217e:	6145                	addi	sp,sp,48
    80002180:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002182:	00006517          	auipc	a0,0x6
    80002186:	1ce50513          	addi	a0,a0,462 # 80008350 <states.1725+0xc8>
    8000218a:	00004097          	auipc	ra,0x4
    8000218e:	df8080e7          	jalr	-520(ra) # 80005f82 <panic>
    panic("kerneltrap: interrupts enabled");
    80002192:	00006517          	auipc	a0,0x6
    80002196:	1e650513          	addi	a0,a0,486 # 80008378 <states.1725+0xf0>
    8000219a:	00004097          	auipc	ra,0x4
    8000219e:	de8080e7          	jalr	-536(ra) # 80005f82 <panic>
    printf("scause %p\n", scause);
    800021a2:	85ce                	mv	a1,s3
    800021a4:	00006517          	auipc	a0,0x6
    800021a8:	1f450513          	addi	a0,a0,500 # 80008398 <states.1725+0x110>
    800021ac:	00004097          	auipc	ra,0x4
    800021b0:	e20080e7          	jalr	-480(ra) # 80005fcc <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800021b4:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800021b8:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    800021bc:	00006517          	auipc	a0,0x6
    800021c0:	1ec50513          	addi	a0,a0,492 # 800083a8 <states.1725+0x120>
    800021c4:	00004097          	auipc	ra,0x4
    800021c8:	e08080e7          	jalr	-504(ra) # 80005fcc <printf>
    panic("kerneltrap");
    800021cc:	00006517          	auipc	a0,0x6
    800021d0:	1f450513          	addi	a0,a0,500 # 800083c0 <states.1725+0x138>
    800021d4:	00004097          	auipc	ra,0x4
    800021d8:	dae080e7          	jalr	-594(ra) # 80005f82 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	f2e080e7          	jalr	-210(ra) # 8000110a <myproc>
    800021e4:	d541                	beqz	a0,8000216c <kerneltrap+0x38>
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	f24080e7          	jalr	-220(ra) # 8000110a <myproc>
    800021ee:	4d18                	lw	a4,24(a0)
    800021f0:	4791                	li	a5,4
    800021f2:	f6f71de3          	bne	a4,a5,8000216c <kerneltrap+0x38>
    yield();
    800021f6:	fffff097          	auipc	ra,0xfffff
    800021fa:	57c080e7          	jalr	1404(ra) # 80001772 <yield>
    800021fe:	b7bd                	j	8000216c <kerneltrap+0x38>

0000000080002200 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002200:	1101                	addi	sp,sp,-32
    80002202:	ec06                	sd	ra,24(sp)
    80002204:	e822                	sd	s0,16(sp)
    80002206:	e426                	sd	s1,8(sp)
    80002208:	1000                	addi	s0,sp,32
    8000220a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000220c:	fffff097          	auipc	ra,0xfffff
    80002210:	efe080e7          	jalr	-258(ra) # 8000110a <myproc>
  switch (n) {
    80002214:	4795                	li	a5,5
    80002216:	0497e163          	bltu	a5,s1,80002258 <argraw+0x58>
    8000221a:	048a                	slli	s1,s1,0x2
    8000221c:	00006717          	auipc	a4,0x6
    80002220:	1dc70713          	addi	a4,a4,476 # 800083f8 <states.1725+0x170>
    80002224:	94ba                	add	s1,s1,a4
    80002226:	409c                	lw	a5,0(s1)
    80002228:	97ba                	add	a5,a5,a4
    8000222a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    8000222c:	6d3c                	ld	a5,88(a0)
    8000222e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002230:	60e2                	ld	ra,24(sp)
    80002232:	6442                	ld	s0,16(sp)
    80002234:	64a2                	ld	s1,8(sp)
    80002236:	6105                	addi	sp,sp,32
    80002238:	8082                	ret
    return p->trapframe->a1;
    8000223a:	6d3c                	ld	a5,88(a0)
    8000223c:	7fa8                	ld	a0,120(a5)
    8000223e:	bfcd                	j	80002230 <argraw+0x30>
    return p->trapframe->a2;
    80002240:	6d3c                	ld	a5,88(a0)
    80002242:	63c8                	ld	a0,128(a5)
    80002244:	b7f5                	j	80002230 <argraw+0x30>
    return p->trapframe->a3;
    80002246:	6d3c                	ld	a5,88(a0)
    80002248:	67c8                	ld	a0,136(a5)
    8000224a:	b7dd                	j	80002230 <argraw+0x30>
    return p->trapframe->a4;
    8000224c:	6d3c                	ld	a5,88(a0)
    8000224e:	6bc8                	ld	a0,144(a5)
    80002250:	b7c5                	j	80002230 <argraw+0x30>
    return p->trapframe->a5;
    80002252:	6d3c                	ld	a5,88(a0)
    80002254:	6fc8                	ld	a0,152(a5)
    80002256:	bfe9                	j	80002230 <argraw+0x30>
  panic("argraw");
    80002258:	00006517          	auipc	a0,0x6
    8000225c:	17850513          	addi	a0,a0,376 # 800083d0 <states.1725+0x148>
    80002260:	00004097          	auipc	ra,0x4
    80002264:	d22080e7          	jalr	-734(ra) # 80005f82 <panic>

0000000080002268 <fetchaddr>:
{
    80002268:	1101                	addi	sp,sp,-32
    8000226a:	ec06                	sd	ra,24(sp)
    8000226c:	e822                	sd	s0,16(sp)
    8000226e:	e426                	sd	s1,8(sp)
    80002270:	e04a                	sd	s2,0(sp)
    80002272:	1000                	addi	s0,sp,32
    80002274:	84aa                	mv	s1,a0
    80002276:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002278:	fffff097          	auipc	ra,0xfffff
    8000227c:	e92080e7          	jalr	-366(ra) # 8000110a <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002280:	653c                	ld	a5,72(a0)
    80002282:	02f4f863          	bgeu	s1,a5,800022b2 <fetchaddr+0x4a>
    80002286:	00848713          	addi	a4,s1,8
    8000228a:	02e7e663          	bltu	a5,a4,800022b6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000228e:	46a1                	li	a3,8
    80002290:	8626                	mv	a2,s1
    80002292:	85ca                	mv	a1,s2
    80002294:	6928                	ld	a0,80(a0)
    80002296:	fffff097          	auipc	ra,0xfffff
    8000229a:	bbe080e7          	jalr	-1090(ra) # 80000e54 <copyin>
    8000229e:	00a03533          	snez	a0,a0
    800022a2:	40a00533          	neg	a0,a0
}
    800022a6:	60e2                	ld	ra,24(sp)
    800022a8:	6442                	ld	s0,16(sp)
    800022aa:	64a2                	ld	s1,8(sp)
    800022ac:	6902                	ld	s2,0(sp)
    800022ae:	6105                	addi	sp,sp,32
    800022b0:	8082                	ret
    return -1;
    800022b2:	557d                	li	a0,-1
    800022b4:	bfcd                	j	800022a6 <fetchaddr+0x3e>
    800022b6:	557d                	li	a0,-1
    800022b8:	b7fd                	j	800022a6 <fetchaddr+0x3e>

00000000800022ba <fetchstr>:
{
    800022ba:	7179                	addi	sp,sp,-48
    800022bc:	f406                	sd	ra,40(sp)
    800022be:	f022                	sd	s0,32(sp)
    800022c0:	ec26                	sd	s1,24(sp)
    800022c2:	e84a                	sd	s2,16(sp)
    800022c4:	e44e                	sd	s3,8(sp)
    800022c6:	1800                	addi	s0,sp,48
    800022c8:	892a                	mv	s2,a0
    800022ca:	84ae                	mv	s1,a1
    800022cc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	e3c080e7          	jalr	-452(ra) # 8000110a <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800022d6:	86ce                	mv	a3,s3
    800022d8:	864a                	mv	a2,s2
    800022da:	85a6                	mv	a1,s1
    800022dc:	6928                	ld	a0,80(a0)
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	c02080e7          	jalr	-1022(ra) # 80000ee0 <copyinstr>
    800022e6:	00054e63          	bltz	a0,80002302 <fetchstr+0x48>
  return strlen(buf);
    800022ea:	8526                	mv	a0,s1
    800022ec:	ffffe097          	auipc	ra,0xffffe
    800022f0:	234080e7          	jalr	564(ra) # 80000520 <strlen>
}
    800022f4:	70a2                	ld	ra,40(sp)
    800022f6:	7402                	ld	s0,32(sp)
    800022f8:	64e2                	ld	s1,24(sp)
    800022fa:	6942                	ld	s2,16(sp)
    800022fc:	69a2                	ld	s3,8(sp)
    800022fe:	6145                	addi	sp,sp,48
    80002300:	8082                	ret
    return -1;
    80002302:	557d                	li	a0,-1
    80002304:	bfc5                	j	800022f4 <fetchstr+0x3a>

0000000080002306 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002306:	1101                	addi	sp,sp,-32
    80002308:	ec06                	sd	ra,24(sp)
    8000230a:	e822                	sd	s0,16(sp)
    8000230c:	e426                	sd	s1,8(sp)
    8000230e:	1000                	addi	s0,sp,32
    80002310:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002312:	00000097          	auipc	ra,0x0
    80002316:	eee080e7          	jalr	-274(ra) # 80002200 <argraw>
    8000231a:	c088                	sw	a0,0(s1)
}
    8000231c:	60e2                	ld	ra,24(sp)
    8000231e:	6442                	ld	s0,16(sp)
    80002320:	64a2                	ld	s1,8(sp)
    80002322:	6105                	addi	sp,sp,32
    80002324:	8082                	ret

0000000080002326 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002326:	1101                	addi	sp,sp,-32
    80002328:	ec06                	sd	ra,24(sp)
    8000232a:	e822                	sd	s0,16(sp)
    8000232c:	e426                	sd	s1,8(sp)
    8000232e:	1000                	addi	s0,sp,32
    80002330:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002332:	00000097          	auipc	ra,0x0
    80002336:	ece080e7          	jalr	-306(ra) # 80002200 <argraw>
    8000233a:	e088                	sd	a0,0(s1)
}
    8000233c:	60e2                	ld	ra,24(sp)
    8000233e:	6442                	ld	s0,16(sp)
    80002340:	64a2                	ld	s1,8(sp)
    80002342:	6105                	addi	sp,sp,32
    80002344:	8082                	ret

0000000080002346 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002346:	7179                	addi	sp,sp,-48
    80002348:	f406                	sd	ra,40(sp)
    8000234a:	f022                	sd	s0,32(sp)
    8000234c:	ec26                	sd	s1,24(sp)
    8000234e:	e84a                	sd	s2,16(sp)
    80002350:	1800                	addi	s0,sp,48
    80002352:	84ae                	mv	s1,a1
    80002354:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002356:	fd840593          	addi	a1,s0,-40
    8000235a:	00000097          	auipc	ra,0x0
    8000235e:	fcc080e7          	jalr	-52(ra) # 80002326 <argaddr>
  return fetchstr(addr, buf, max);
    80002362:	864a                	mv	a2,s2
    80002364:	85a6                	mv	a1,s1
    80002366:	fd843503          	ld	a0,-40(s0)
    8000236a:	00000097          	auipc	ra,0x0
    8000236e:	f50080e7          	jalr	-176(ra) # 800022ba <fetchstr>
}
    80002372:	70a2                	ld	ra,40(sp)
    80002374:	7402                	ld	s0,32(sp)
    80002376:	64e2                	ld	s1,24(sp)
    80002378:	6942                	ld	s2,16(sp)
    8000237a:	6145                	addi	sp,sp,48
    8000237c:	8082                	ret

000000008000237e <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    8000237e:	1101                	addi	sp,sp,-32
    80002380:	ec06                	sd	ra,24(sp)
    80002382:	e822                	sd	s0,16(sp)
    80002384:	e426                	sd	s1,8(sp)
    80002386:	e04a                	sd	s2,0(sp)
    80002388:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	d80080e7          	jalr	-640(ra) # 8000110a <myproc>
    80002392:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002394:	05853903          	ld	s2,88(a0)
    80002398:	0a893783          	ld	a5,168(s2)
    8000239c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    800023a0:	37fd                	addiw	a5,a5,-1
    800023a2:	4751                	li	a4,20
    800023a4:	00f76f63          	bltu	a4,a5,800023c2 <syscall+0x44>
    800023a8:	00369713          	slli	a4,a3,0x3
    800023ac:	00006797          	auipc	a5,0x6
    800023b0:	06478793          	addi	a5,a5,100 # 80008410 <syscalls>
    800023b4:	97ba                	add	a5,a5,a4
    800023b6:	639c                	ld	a5,0(a5)
    800023b8:	c789                	beqz	a5,800023c2 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800023ba:	9782                	jalr	a5
    800023bc:	06a93823          	sd	a0,112(s2)
    800023c0:	a839                	j	800023de <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800023c2:	15848613          	addi	a2,s1,344
    800023c6:	588c                	lw	a1,48(s1)
    800023c8:	00006517          	auipc	a0,0x6
    800023cc:	01050513          	addi	a0,a0,16 # 800083d8 <states.1725+0x150>
    800023d0:	00004097          	auipc	ra,0x4
    800023d4:	bfc080e7          	jalr	-1028(ra) # 80005fcc <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800023d8:	6cbc                	ld	a5,88(s1)
    800023da:	577d                	li	a4,-1
    800023dc:	fbb8                	sd	a4,112(a5)
  }
}
    800023de:	60e2                	ld	ra,24(sp)
    800023e0:	6442                	ld	s0,16(sp)
    800023e2:	64a2                	ld	s1,8(sp)
    800023e4:	6902                	ld	s2,0(sp)
    800023e6:	6105                	addi	sp,sp,32
    800023e8:	8082                	ret

00000000800023ea <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800023ea:	1101                	addi	sp,sp,-32
    800023ec:	ec06                	sd	ra,24(sp)
    800023ee:	e822                	sd	s0,16(sp)
    800023f0:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800023f2:	fec40593          	addi	a1,s0,-20
    800023f6:	4501                	li	a0,0
    800023f8:	00000097          	auipc	ra,0x0
    800023fc:	f0e080e7          	jalr	-242(ra) # 80002306 <argint>
  exit(n);
    80002400:	fec42503          	lw	a0,-20(s0)
    80002404:	fffff097          	auipc	ra,0xfffff
    80002408:	4de080e7          	jalr	1246(ra) # 800018e2 <exit>
  return 0;  // not reached
}
    8000240c:	4501                	li	a0,0
    8000240e:	60e2                	ld	ra,24(sp)
    80002410:	6442                	ld	s0,16(sp)
    80002412:	6105                	addi	sp,sp,32
    80002414:	8082                	ret

0000000080002416 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002416:	1141                	addi	sp,sp,-16
    80002418:	e406                	sd	ra,8(sp)
    8000241a:	e022                	sd	s0,0(sp)
    8000241c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000241e:	fffff097          	auipc	ra,0xfffff
    80002422:	cec080e7          	jalr	-788(ra) # 8000110a <myproc>
}
    80002426:	5908                	lw	a0,48(a0)
    80002428:	60a2                	ld	ra,8(sp)
    8000242a:	6402                	ld	s0,0(sp)
    8000242c:	0141                	addi	sp,sp,16
    8000242e:	8082                	ret

0000000080002430 <sys_fork>:

uint64
sys_fork(void)
{
    80002430:	1141                	addi	sp,sp,-16
    80002432:	e406                	sd	ra,8(sp)
    80002434:	e022                	sd	s0,0(sp)
    80002436:	0800                	addi	s0,sp,16
  return fork();
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	088080e7          	jalr	136(ra) # 800014c0 <fork>
}
    80002440:	60a2                	ld	ra,8(sp)
    80002442:	6402                	ld	s0,0(sp)
    80002444:	0141                	addi	sp,sp,16
    80002446:	8082                	ret

0000000080002448 <sys_wait>:

uint64
sys_wait(void)
{
    80002448:	1101                	addi	sp,sp,-32
    8000244a:	ec06                	sd	ra,24(sp)
    8000244c:	e822                	sd	s0,16(sp)
    8000244e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002450:	fe840593          	addi	a1,s0,-24
    80002454:	4501                	li	a0,0
    80002456:	00000097          	auipc	ra,0x0
    8000245a:	ed0080e7          	jalr	-304(ra) # 80002326 <argaddr>
  return wait(p);
    8000245e:	fe843503          	ld	a0,-24(s0)
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	626080e7          	jalr	1574(ra) # 80001a88 <wait>
}
    8000246a:	60e2                	ld	ra,24(sp)
    8000246c:	6442                	ld	s0,16(sp)
    8000246e:	6105                	addi	sp,sp,32
    80002470:	8082                	ret

0000000080002472 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002472:	7179                	addi	sp,sp,-48
    80002474:	f406                	sd	ra,40(sp)
    80002476:	f022                	sd	s0,32(sp)
    80002478:	ec26                	sd	s1,24(sp)
    8000247a:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    8000247c:	fdc40593          	addi	a1,s0,-36
    80002480:	4501                	li	a0,0
    80002482:	00000097          	auipc	ra,0x0
    80002486:	e84080e7          	jalr	-380(ra) # 80002306 <argint>
  addr = myproc()->sz;
    8000248a:	fffff097          	auipc	ra,0xfffff
    8000248e:	c80080e7          	jalr	-896(ra) # 8000110a <myproc>
    80002492:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002494:	fdc42503          	lw	a0,-36(s0)
    80002498:	fffff097          	auipc	ra,0xfffff
    8000249c:	fcc080e7          	jalr	-52(ra) # 80001464 <growproc>
    800024a0:	00054863          	bltz	a0,800024b0 <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    800024a4:	8526                	mv	a0,s1
    800024a6:	70a2                	ld	ra,40(sp)
    800024a8:	7402                	ld	s0,32(sp)
    800024aa:	64e2                	ld	s1,24(sp)
    800024ac:	6145                	addi	sp,sp,48
    800024ae:	8082                	ret
    return -1;
    800024b0:	54fd                	li	s1,-1
    800024b2:	bfcd                	j	800024a4 <sys_sbrk+0x32>

00000000800024b4 <sys_sleep>:

uint64
sys_sleep(void)
{
    800024b4:	7139                	addi	sp,sp,-64
    800024b6:	fc06                	sd	ra,56(sp)
    800024b8:	f822                	sd	s0,48(sp)
    800024ba:	f426                	sd	s1,40(sp)
    800024bc:	f04a                	sd	s2,32(sp)
    800024be:	ec4e                	sd	s3,24(sp)
    800024c0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    800024c2:	fcc40593          	addi	a1,s0,-52
    800024c6:	4501                	li	a0,0
    800024c8:	00000097          	auipc	ra,0x0
    800024cc:	e3e080e7          	jalr	-450(ra) # 80002306 <argint>
  if(n < 0)
    800024d0:	fcc42783          	lw	a5,-52(s0)
    800024d4:	0607cf63          	bltz	a5,80002552 <sys_sleep+0x9e>
    n = 0;
  acquire(&tickslock);
    800024d8:	0022c517          	auipc	a0,0x22c
    800024dc:	2b050513          	addi	a0,a0,688 # 8022e788 <tickslock>
    800024e0:	00004097          	auipc	ra,0x4
    800024e4:	fec080e7          	jalr	-20(ra) # 800064cc <acquire>
  ticks0 = ticks;
    800024e8:	00006917          	auipc	s2,0x6
    800024ec:	42092903          	lw	s2,1056(s2) # 80008908 <ticks>
  while(ticks - ticks0 < n){
    800024f0:	fcc42783          	lw	a5,-52(s0)
    800024f4:	cf9d                	beqz	a5,80002532 <sys_sleep+0x7e>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800024f6:	0022c997          	auipc	s3,0x22c
    800024fa:	29298993          	addi	s3,s3,658 # 8022e788 <tickslock>
    800024fe:	00006497          	auipc	s1,0x6
    80002502:	40a48493          	addi	s1,s1,1034 # 80008908 <ticks>
    if(killed(myproc())){
    80002506:	fffff097          	auipc	ra,0xfffff
    8000250a:	c04080e7          	jalr	-1020(ra) # 8000110a <myproc>
    8000250e:	fffff097          	auipc	ra,0xfffff
    80002512:	548080e7          	jalr	1352(ra) # 80001a56 <killed>
    80002516:	e129                	bnez	a0,80002558 <sys_sleep+0xa4>
    sleep(&ticks, &tickslock);
    80002518:	85ce                	mv	a1,s3
    8000251a:	8526                	mv	a0,s1
    8000251c:	fffff097          	auipc	ra,0xfffff
    80002520:	292080e7          	jalr	658(ra) # 800017ae <sleep>
  while(ticks - ticks0 < n){
    80002524:	409c                	lw	a5,0(s1)
    80002526:	412787bb          	subw	a5,a5,s2
    8000252a:	fcc42703          	lw	a4,-52(s0)
    8000252e:	fce7ece3          	bltu	a5,a4,80002506 <sys_sleep+0x52>
  }
  release(&tickslock);
    80002532:	0022c517          	auipc	a0,0x22c
    80002536:	25650513          	addi	a0,a0,598 # 8022e788 <tickslock>
    8000253a:	00004097          	auipc	ra,0x4
    8000253e:	046080e7          	jalr	70(ra) # 80006580 <release>
  return 0;
    80002542:	4501                	li	a0,0
}
    80002544:	70e2                	ld	ra,56(sp)
    80002546:	7442                	ld	s0,48(sp)
    80002548:	74a2                	ld	s1,40(sp)
    8000254a:	7902                	ld	s2,32(sp)
    8000254c:	69e2                	ld	s3,24(sp)
    8000254e:	6121                	addi	sp,sp,64
    80002550:	8082                	ret
    n = 0;
    80002552:	fc042623          	sw	zero,-52(s0)
    80002556:	b749                	j	800024d8 <sys_sleep+0x24>
      release(&tickslock);
    80002558:	0022c517          	auipc	a0,0x22c
    8000255c:	23050513          	addi	a0,a0,560 # 8022e788 <tickslock>
    80002560:	00004097          	auipc	ra,0x4
    80002564:	020080e7          	jalr	32(ra) # 80006580 <release>
      return -1;
    80002568:	557d                	li	a0,-1
    8000256a:	bfe9                	j	80002544 <sys_sleep+0x90>

000000008000256c <sys_kill>:

uint64
sys_kill(void)
{
    8000256c:	1101                	addi	sp,sp,-32
    8000256e:	ec06                	sd	ra,24(sp)
    80002570:	e822                	sd	s0,16(sp)
    80002572:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002574:	fec40593          	addi	a1,s0,-20
    80002578:	4501                	li	a0,0
    8000257a:	00000097          	auipc	ra,0x0
    8000257e:	d8c080e7          	jalr	-628(ra) # 80002306 <argint>
  return kill(pid);
    80002582:	fec42503          	lw	a0,-20(s0)
    80002586:	fffff097          	auipc	ra,0xfffff
    8000258a:	432080e7          	jalr	1074(ra) # 800019b8 <kill>
}
    8000258e:	60e2                	ld	ra,24(sp)
    80002590:	6442                	ld	s0,16(sp)
    80002592:	6105                	addi	sp,sp,32
    80002594:	8082                	ret

0000000080002596 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002596:	1101                	addi	sp,sp,-32
    80002598:	ec06                	sd	ra,24(sp)
    8000259a:	e822                	sd	s0,16(sp)
    8000259c:	e426                	sd	s1,8(sp)
    8000259e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800025a0:	0022c517          	auipc	a0,0x22c
    800025a4:	1e850513          	addi	a0,a0,488 # 8022e788 <tickslock>
    800025a8:	00004097          	auipc	ra,0x4
    800025ac:	f24080e7          	jalr	-220(ra) # 800064cc <acquire>
  xticks = ticks;
    800025b0:	00006497          	auipc	s1,0x6
    800025b4:	3584a483          	lw	s1,856(s1) # 80008908 <ticks>
  release(&tickslock);
    800025b8:	0022c517          	auipc	a0,0x22c
    800025bc:	1d050513          	addi	a0,a0,464 # 8022e788 <tickslock>
    800025c0:	00004097          	auipc	ra,0x4
    800025c4:	fc0080e7          	jalr	-64(ra) # 80006580 <release>
  return xticks;
}
    800025c8:	02049513          	slli	a0,s1,0x20
    800025cc:	9101                	srli	a0,a0,0x20
    800025ce:	60e2                	ld	ra,24(sp)
    800025d0:	6442                	ld	s0,16(sp)
    800025d2:	64a2                	ld	s1,8(sp)
    800025d4:	6105                	addi	sp,sp,32
    800025d6:	8082                	ret

00000000800025d8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800025d8:	7179                	addi	sp,sp,-48
    800025da:	f406                	sd	ra,40(sp)
    800025dc:	f022                	sd	s0,32(sp)
    800025de:	ec26                	sd	s1,24(sp)
    800025e0:	e84a                	sd	s2,16(sp)
    800025e2:	e44e                	sd	s3,8(sp)
    800025e4:	e052                	sd	s4,0(sp)
    800025e6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800025e8:	00006597          	auipc	a1,0x6
    800025ec:	ed858593          	addi	a1,a1,-296 # 800084c0 <syscalls+0xb0>
    800025f0:	0022c517          	auipc	a0,0x22c
    800025f4:	1b050513          	addi	a0,a0,432 # 8022e7a0 <bcache>
    800025f8:	00004097          	auipc	ra,0x4
    800025fc:	e44080e7          	jalr	-444(ra) # 8000643c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002600:	00234797          	auipc	a5,0x234
    80002604:	1a078793          	addi	a5,a5,416 # 802367a0 <bcache+0x8000>
    80002608:	00234717          	auipc	a4,0x234
    8000260c:	40070713          	addi	a4,a4,1024 # 80236a08 <bcache+0x8268>
    80002610:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002614:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002618:	0022c497          	auipc	s1,0x22c
    8000261c:	1a048493          	addi	s1,s1,416 # 8022e7b8 <bcache+0x18>
    b->next = bcache.head.next;
    80002620:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002622:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002624:	00006a17          	auipc	s4,0x6
    80002628:	ea4a0a13          	addi	s4,s4,-348 # 800084c8 <syscalls+0xb8>
    b->next = bcache.head.next;
    8000262c:	2b893783          	ld	a5,696(s2)
    80002630:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002632:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002636:	85d2                	mv	a1,s4
    80002638:	01048513          	addi	a0,s1,16
    8000263c:	00001097          	auipc	ra,0x1
    80002640:	4c4080e7          	jalr	1220(ra) # 80003b00 <initsleeplock>
    bcache.head.next->prev = b;
    80002644:	2b893783          	ld	a5,696(s2)
    80002648:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000264a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000264e:	45848493          	addi	s1,s1,1112
    80002652:	fd349de3          	bne	s1,s3,8000262c <binit+0x54>
  }
}
    80002656:	70a2                	ld	ra,40(sp)
    80002658:	7402                	ld	s0,32(sp)
    8000265a:	64e2                	ld	s1,24(sp)
    8000265c:	6942                	ld	s2,16(sp)
    8000265e:	69a2                	ld	s3,8(sp)
    80002660:	6a02                	ld	s4,0(sp)
    80002662:	6145                	addi	sp,sp,48
    80002664:	8082                	ret

0000000080002666 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002666:	7179                	addi	sp,sp,-48
    80002668:	f406                	sd	ra,40(sp)
    8000266a:	f022                	sd	s0,32(sp)
    8000266c:	ec26                	sd	s1,24(sp)
    8000266e:	e84a                	sd	s2,16(sp)
    80002670:	e44e                	sd	s3,8(sp)
    80002672:	1800                	addi	s0,sp,48
    80002674:	89aa                	mv	s3,a0
    80002676:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    80002678:	0022c517          	auipc	a0,0x22c
    8000267c:	12850513          	addi	a0,a0,296 # 8022e7a0 <bcache>
    80002680:	00004097          	auipc	ra,0x4
    80002684:	e4c080e7          	jalr	-436(ra) # 800064cc <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002688:	00234497          	auipc	s1,0x234
    8000268c:	3d04b483          	ld	s1,976(s1) # 80236a58 <bcache+0x82b8>
    80002690:	00234797          	auipc	a5,0x234
    80002694:	37878793          	addi	a5,a5,888 # 80236a08 <bcache+0x8268>
    80002698:	02f48f63          	beq	s1,a5,800026d6 <bread+0x70>
    8000269c:	873e                	mv	a4,a5
    8000269e:	a021                	j	800026a6 <bread+0x40>
    800026a0:	68a4                	ld	s1,80(s1)
    800026a2:	02e48a63          	beq	s1,a4,800026d6 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800026a6:	449c                	lw	a5,8(s1)
    800026a8:	ff379ce3          	bne	a5,s3,800026a0 <bread+0x3a>
    800026ac:	44dc                	lw	a5,12(s1)
    800026ae:	ff2799e3          	bne	a5,s2,800026a0 <bread+0x3a>
      b->refcnt++;
    800026b2:	40bc                	lw	a5,64(s1)
    800026b4:	2785                	addiw	a5,a5,1
    800026b6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800026b8:	0022c517          	auipc	a0,0x22c
    800026bc:	0e850513          	addi	a0,a0,232 # 8022e7a0 <bcache>
    800026c0:	00004097          	auipc	ra,0x4
    800026c4:	ec0080e7          	jalr	-320(ra) # 80006580 <release>
      acquiresleep(&b->lock);
    800026c8:	01048513          	addi	a0,s1,16
    800026cc:	00001097          	auipc	ra,0x1
    800026d0:	46e080e7          	jalr	1134(ra) # 80003b3a <acquiresleep>
      return b;
    800026d4:	a8b9                	j	80002732 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800026d6:	00234497          	auipc	s1,0x234
    800026da:	37a4b483          	ld	s1,890(s1) # 80236a50 <bcache+0x82b0>
    800026de:	00234797          	auipc	a5,0x234
    800026e2:	32a78793          	addi	a5,a5,810 # 80236a08 <bcache+0x8268>
    800026e6:	00f48863          	beq	s1,a5,800026f6 <bread+0x90>
    800026ea:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800026ec:	40bc                	lw	a5,64(s1)
    800026ee:	cf81                	beqz	a5,80002706 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800026f0:	64a4                	ld	s1,72(s1)
    800026f2:	fee49de3          	bne	s1,a4,800026ec <bread+0x86>
  panic("bget: no buffers");
    800026f6:	00006517          	auipc	a0,0x6
    800026fa:	dda50513          	addi	a0,a0,-550 # 800084d0 <syscalls+0xc0>
    800026fe:	00004097          	auipc	ra,0x4
    80002702:	884080e7          	jalr	-1916(ra) # 80005f82 <panic>
      b->dev = dev;
    80002706:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000270a:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    8000270e:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002712:	4785                	li	a5,1
    80002714:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002716:	0022c517          	auipc	a0,0x22c
    8000271a:	08a50513          	addi	a0,a0,138 # 8022e7a0 <bcache>
    8000271e:	00004097          	auipc	ra,0x4
    80002722:	e62080e7          	jalr	-414(ra) # 80006580 <release>
      acquiresleep(&b->lock);
    80002726:	01048513          	addi	a0,s1,16
    8000272a:	00001097          	auipc	ra,0x1
    8000272e:	410080e7          	jalr	1040(ra) # 80003b3a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002732:	409c                	lw	a5,0(s1)
    80002734:	cb89                	beqz	a5,80002746 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002736:	8526                	mv	a0,s1
    80002738:	70a2                	ld	ra,40(sp)
    8000273a:	7402                	ld	s0,32(sp)
    8000273c:	64e2                	ld	s1,24(sp)
    8000273e:	6942                	ld	s2,16(sp)
    80002740:	69a2                	ld	s3,8(sp)
    80002742:	6145                	addi	sp,sp,48
    80002744:	8082                	ret
    virtio_disk_rw(b, 0);
    80002746:	4581                	li	a1,0
    80002748:	8526                	mv	a0,s1
    8000274a:	00003097          	auipc	ra,0x3
    8000274e:	fce080e7          	jalr	-50(ra) # 80005718 <virtio_disk_rw>
    b->valid = 1;
    80002752:	4785                	li	a5,1
    80002754:	c09c                	sw	a5,0(s1)
  return b;
    80002756:	b7c5                	j	80002736 <bread+0xd0>

0000000080002758 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002758:	1101                	addi	sp,sp,-32
    8000275a:	ec06                	sd	ra,24(sp)
    8000275c:	e822                	sd	s0,16(sp)
    8000275e:	e426                	sd	s1,8(sp)
    80002760:	1000                	addi	s0,sp,32
    80002762:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002764:	0541                	addi	a0,a0,16
    80002766:	00001097          	auipc	ra,0x1
    8000276a:	46e080e7          	jalr	1134(ra) # 80003bd4 <holdingsleep>
    8000276e:	cd01                	beqz	a0,80002786 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002770:	4585                	li	a1,1
    80002772:	8526                	mv	a0,s1
    80002774:	00003097          	auipc	ra,0x3
    80002778:	fa4080e7          	jalr	-92(ra) # 80005718 <virtio_disk_rw>
}
    8000277c:	60e2                	ld	ra,24(sp)
    8000277e:	6442                	ld	s0,16(sp)
    80002780:	64a2                	ld	s1,8(sp)
    80002782:	6105                	addi	sp,sp,32
    80002784:	8082                	ret
    panic("bwrite");
    80002786:	00006517          	auipc	a0,0x6
    8000278a:	d6250513          	addi	a0,a0,-670 # 800084e8 <syscalls+0xd8>
    8000278e:	00003097          	auipc	ra,0x3
    80002792:	7f4080e7          	jalr	2036(ra) # 80005f82 <panic>

0000000080002796 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002796:	1101                	addi	sp,sp,-32
    80002798:	ec06                	sd	ra,24(sp)
    8000279a:	e822                	sd	s0,16(sp)
    8000279c:	e426                	sd	s1,8(sp)
    8000279e:	e04a                	sd	s2,0(sp)
    800027a0:	1000                	addi	s0,sp,32
    800027a2:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800027a4:	01050913          	addi	s2,a0,16
    800027a8:	854a                	mv	a0,s2
    800027aa:	00001097          	auipc	ra,0x1
    800027ae:	42a080e7          	jalr	1066(ra) # 80003bd4 <holdingsleep>
    800027b2:	c92d                	beqz	a0,80002824 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800027b4:	854a                	mv	a0,s2
    800027b6:	00001097          	auipc	ra,0x1
    800027ba:	3da080e7          	jalr	986(ra) # 80003b90 <releasesleep>

  acquire(&bcache.lock);
    800027be:	0022c517          	auipc	a0,0x22c
    800027c2:	fe250513          	addi	a0,a0,-30 # 8022e7a0 <bcache>
    800027c6:	00004097          	auipc	ra,0x4
    800027ca:	d06080e7          	jalr	-762(ra) # 800064cc <acquire>
  b->refcnt--;
    800027ce:	40bc                	lw	a5,64(s1)
    800027d0:	37fd                	addiw	a5,a5,-1
    800027d2:	0007871b          	sext.w	a4,a5
    800027d6:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800027d8:	eb05                	bnez	a4,80002808 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800027da:	68bc                	ld	a5,80(s1)
    800027dc:	64b8                	ld	a4,72(s1)
    800027de:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800027e0:	64bc                	ld	a5,72(s1)
    800027e2:	68b8                	ld	a4,80(s1)
    800027e4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800027e6:	00234797          	auipc	a5,0x234
    800027ea:	fba78793          	addi	a5,a5,-70 # 802367a0 <bcache+0x8000>
    800027ee:	2b87b703          	ld	a4,696(a5)
    800027f2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800027f4:	00234717          	auipc	a4,0x234
    800027f8:	21470713          	addi	a4,a4,532 # 80236a08 <bcache+0x8268>
    800027fc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800027fe:	2b87b703          	ld	a4,696(a5)
    80002802:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002804:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002808:	0022c517          	auipc	a0,0x22c
    8000280c:	f9850513          	addi	a0,a0,-104 # 8022e7a0 <bcache>
    80002810:	00004097          	auipc	ra,0x4
    80002814:	d70080e7          	jalr	-656(ra) # 80006580 <release>
}
    80002818:	60e2                	ld	ra,24(sp)
    8000281a:	6442                	ld	s0,16(sp)
    8000281c:	64a2                	ld	s1,8(sp)
    8000281e:	6902                	ld	s2,0(sp)
    80002820:	6105                	addi	sp,sp,32
    80002822:	8082                	ret
    panic("brelse");
    80002824:	00006517          	auipc	a0,0x6
    80002828:	ccc50513          	addi	a0,a0,-820 # 800084f0 <syscalls+0xe0>
    8000282c:	00003097          	auipc	ra,0x3
    80002830:	756080e7          	jalr	1878(ra) # 80005f82 <panic>

0000000080002834 <bpin>:

void
bpin(struct buf *b) {
    80002834:	1101                	addi	sp,sp,-32
    80002836:	ec06                	sd	ra,24(sp)
    80002838:	e822                	sd	s0,16(sp)
    8000283a:	e426                	sd	s1,8(sp)
    8000283c:	1000                	addi	s0,sp,32
    8000283e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002840:	0022c517          	auipc	a0,0x22c
    80002844:	f6050513          	addi	a0,a0,-160 # 8022e7a0 <bcache>
    80002848:	00004097          	auipc	ra,0x4
    8000284c:	c84080e7          	jalr	-892(ra) # 800064cc <acquire>
  b->refcnt++;
    80002850:	40bc                	lw	a5,64(s1)
    80002852:	2785                	addiw	a5,a5,1
    80002854:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002856:	0022c517          	auipc	a0,0x22c
    8000285a:	f4a50513          	addi	a0,a0,-182 # 8022e7a0 <bcache>
    8000285e:	00004097          	auipc	ra,0x4
    80002862:	d22080e7          	jalr	-734(ra) # 80006580 <release>
}
    80002866:	60e2                	ld	ra,24(sp)
    80002868:	6442                	ld	s0,16(sp)
    8000286a:	64a2                	ld	s1,8(sp)
    8000286c:	6105                	addi	sp,sp,32
    8000286e:	8082                	ret

0000000080002870 <bunpin>:

void
bunpin(struct buf *b) {
    80002870:	1101                	addi	sp,sp,-32
    80002872:	ec06                	sd	ra,24(sp)
    80002874:	e822                	sd	s0,16(sp)
    80002876:	e426                	sd	s1,8(sp)
    80002878:	1000                	addi	s0,sp,32
    8000287a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000287c:	0022c517          	auipc	a0,0x22c
    80002880:	f2450513          	addi	a0,a0,-220 # 8022e7a0 <bcache>
    80002884:	00004097          	auipc	ra,0x4
    80002888:	c48080e7          	jalr	-952(ra) # 800064cc <acquire>
  b->refcnt--;
    8000288c:	40bc                	lw	a5,64(s1)
    8000288e:	37fd                	addiw	a5,a5,-1
    80002890:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002892:	0022c517          	auipc	a0,0x22c
    80002896:	f0e50513          	addi	a0,a0,-242 # 8022e7a0 <bcache>
    8000289a:	00004097          	auipc	ra,0x4
    8000289e:	ce6080e7          	jalr	-794(ra) # 80006580 <release>
}
    800028a2:	60e2                	ld	ra,24(sp)
    800028a4:	6442                	ld	s0,16(sp)
    800028a6:	64a2                	ld	s1,8(sp)
    800028a8:	6105                	addi	sp,sp,32
    800028aa:	8082                	ret

00000000800028ac <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800028ac:	1101                	addi	sp,sp,-32
    800028ae:	ec06                	sd	ra,24(sp)
    800028b0:	e822                	sd	s0,16(sp)
    800028b2:	e426                	sd	s1,8(sp)
    800028b4:	e04a                	sd	s2,0(sp)
    800028b6:	1000                	addi	s0,sp,32
    800028b8:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800028ba:	00d5d59b          	srliw	a1,a1,0xd
    800028be:	00234797          	auipc	a5,0x234
    800028c2:	5be7a783          	lw	a5,1470(a5) # 80236e7c <sb+0x1c>
    800028c6:	9dbd                	addw	a1,a1,a5
    800028c8:	00000097          	auipc	ra,0x0
    800028cc:	d9e080e7          	jalr	-610(ra) # 80002666 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800028d0:	0074f713          	andi	a4,s1,7
    800028d4:	4785                	li	a5,1
    800028d6:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800028da:	14ce                	slli	s1,s1,0x33
    800028dc:	90d9                	srli	s1,s1,0x36
    800028de:	00950733          	add	a4,a0,s1
    800028e2:	05874703          	lbu	a4,88(a4)
    800028e6:	00e7f6b3          	and	a3,a5,a4
    800028ea:	c69d                	beqz	a3,80002918 <bfree+0x6c>
    800028ec:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800028ee:	94aa                	add	s1,s1,a0
    800028f0:	fff7c793          	not	a5,a5
    800028f4:	8ff9                	and	a5,a5,a4
    800028f6:	04f48c23          	sb	a5,88(s1)
  log_write(bp);
    800028fa:	00001097          	auipc	ra,0x1
    800028fe:	120080e7          	jalr	288(ra) # 80003a1a <log_write>
  brelse(bp);
    80002902:	854a                	mv	a0,s2
    80002904:	00000097          	auipc	ra,0x0
    80002908:	e92080e7          	jalr	-366(ra) # 80002796 <brelse>
}
    8000290c:	60e2                	ld	ra,24(sp)
    8000290e:	6442                	ld	s0,16(sp)
    80002910:	64a2                	ld	s1,8(sp)
    80002912:	6902                	ld	s2,0(sp)
    80002914:	6105                	addi	sp,sp,32
    80002916:	8082                	ret
    panic("freeing free block");
    80002918:	00006517          	auipc	a0,0x6
    8000291c:	be050513          	addi	a0,a0,-1056 # 800084f8 <syscalls+0xe8>
    80002920:	00003097          	auipc	ra,0x3
    80002924:	662080e7          	jalr	1634(ra) # 80005f82 <panic>

0000000080002928 <balloc>:
{
    80002928:	711d                	addi	sp,sp,-96
    8000292a:	ec86                	sd	ra,88(sp)
    8000292c:	e8a2                	sd	s0,80(sp)
    8000292e:	e4a6                	sd	s1,72(sp)
    80002930:	e0ca                	sd	s2,64(sp)
    80002932:	fc4e                	sd	s3,56(sp)
    80002934:	f852                	sd	s4,48(sp)
    80002936:	f456                	sd	s5,40(sp)
    80002938:	f05a                	sd	s6,32(sp)
    8000293a:	ec5e                	sd	s7,24(sp)
    8000293c:	e862                	sd	s8,16(sp)
    8000293e:	e466                	sd	s9,8(sp)
    80002940:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002942:	00234797          	auipc	a5,0x234
    80002946:	5227a783          	lw	a5,1314(a5) # 80236e64 <sb+0x4>
    8000294a:	10078163          	beqz	a5,80002a4c <balloc+0x124>
    8000294e:	8baa                	mv	s7,a0
    80002950:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002952:	00234b17          	auipc	s6,0x234
    80002956:	50eb0b13          	addi	s6,s6,1294 # 80236e60 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000295a:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000295c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000295e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002960:	6c89                	lui	s9,0x2
    80002962:	a061                	j	800029ea <balloc+0xc2>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002964:	974a                	add	a4,a4,s2
    80002966:	8fd5                	or	a5,a5,a3
    80002968:	04f70c23          	sb	a5,88(a4)
        log_write(bp);
    8000296c:	854a                	mv	a0,s2
    8000296e:	00001097          	auipc	ra,0x1
    80002972:	0ac080e7          	jalr	172(ra) # 80003a1a <log_write>
        brelse(bp);
    80002976:	854a                	mv	a0,s2
    80002978:	00000097          	auipc	ra,0x0
    8000297c:	e1e080e7          	jalr	-482(ra) # 80002796 <brelse>
  bp = bread(dev, bno);
    80002980:	85a6                	mv	a1,s1
    80002982:	855e                	mv	a0,s7
    80002984:	00000097          	auipc	ra,0x0
    80002988:	ce2080e7          	jalr	-798(ra) # 80002666 <bread>
    8000298c:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000298e:	40000613          	li	a2,1024
    80002992:	4581                	li	a1,0
    80002994:	05850513          	addi	a0,a0,88
    80002998:	ffffe097          	auipc	ra,0xffffe
    8000299c:	a04080e7          	jalr	-1532(ra) # 8000039c <memset>
  log_write(bp);
    800029a0:	854a                	mv	a0,s2
    800029a2:	00001097          	auipc	ra,0x1
    800029a6:	078080e7          	jalr	120(ra) # 80003a1a <log_write>
  brelse(bp);
    800029aa:	854a                	mv	a0,s2
    800029ac:	00000097          	auipc	ra,0x0
    800029b0:	dea080e7          	jalr	-534(ra) # 80002796 <brelse>
}
    800029b4:	8526                	mv	a0,s1
    800029b6:	60e6                	ld	ra,88(sp)
    800029b8:	6446                	ld	s0,80(sp)
    800029ba:	64a6                	ld	s1,72(sp)
    800029bc:	6906                	ld	s2,64(sp)
    800029be:	79e2                	ld	s3,56(sp)
    800029c0:	7a42                	ld	s4,48(sp)
    800029c2:	7aa2                	ld	s5,40(sp)
    800029c4:	7b02                	ld	s6,32(sp)
    800029c6:	6be2                	ld	s7,24(sp)
    800029c8:	6c42                	ld	s8,16(sp)
    800029ca:	6ca2                	ld	s9,8(sp)
    800029cc:	6125                	addi	sp,sp,96
    800029ce:	8082                	ret
    brelse(bp);
    800029d0:	854a                	mv	a0,s2
    800029d2:	00000097          	auipc	ra,0x0
    800029d6:	dc4080e7          	jalr	-572(ra) # 80002796 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800029da:	015c87bb          	addw	a5,s9,s5
    800029de:	00078a9b          	sext.w	s5,a5
    800029e2:	004b2703          	lw	a4,4(s6)
    800029e6:	06eaf363          	bgeu	s5,a4,80002a4c <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
    800029ea:	41fad79b          	sraiw	a5,s5,0x1f
    800029ee:	0137d79b          	srliw	a5,a5,0x13
    800029f2:	015787bb          	addw	a5,a5,s5
    800029f6:	40d7d79b          	sraiw	a5,a5,0xd
    800029fa:	01cb2583          	lw	a1,28(s6)
    800029fe:	9dbd                	addw	a1,a1,a5
    80002a00:	855e                	mv	a0,s7
    80002a02:	00000097          	auipc	ra,0x0
    80002a06:	c64080e7          	jalr	-924(ra) # 80002666 <bread>
    80002a0a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002a0c:	004b2503          	lw	a0,4(s6)
    80002a10:	000a849b          	sext.w	s1,s5
    80002a14:	8662                	mv	a2,s8
    80002a16:	faa4fde3          	bgeu	s1,a0,800029d0 <balloc+0xa8>
      m = 1 << (bi % 8);
    80002a1a:	41f6579b          	sraiw	a5,a2,0x1f
    80002a1e:	01d7d69b          	srliw	a3,a5,0x1d
    80002a22:	00c6873b          	addw	a4,a3,a2
    80002a26:	00777793          	andi	a5,a4,7
    80002a2a:	9f95                	subw	a5,a5,a3
    80002a2c:	00f997bb          	sllw	a5,s3,a5
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002a30:	4037571b          	sraiw	a4,a4,0x3
    80002a34:	00e906b3          	add	a3,s2,a4
    80002a38:	0586c683          	lbu	a3,88(a3)
    80002a3c:	00d7f5b3          	and	a1,a5,a3
    80002a40:	d195                	beqz	a1,80002964 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002a42:	2605                	addiw	a2,a2,1
    80002a44:	2485                	addiw	s1,s1,1
    80002a46:	fd4618e3          	bne	a2,s4,80002a16 <balloc+0xee>
    80002a4a:	b759                	j	800029d0 <balloc+0xa8>
  printf("balloc: out of blocks\n");
    80002a4c:	00006517          	auipc	a0,0x6
    80002a50:	ac450513          	addi	a0,a0,-1340 # 80008510 <syscalls+0x100>
    80002a54:	00003097          	auipc	ra,0x3
    80002a58:	578080e7          	jalr	1400(ra) # 80005fcc <printf>
  return 0;
    80002a5c:	4481                	li	s1,0
    80002a5e:	bf99                	j	800029b4 <balloc+0x8c>

0000000080002a60 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002a60:	7179                	addi	sp,sp,-48
    80002a62:	f406                	sd	ra,40(sp)
    80002a64:	f022                	sd	s0,32(sp)
    80002a66:	ec26                	sd	s1,24(sp)
    80002a68:	e84a                	sd	s2,16(sp)
    80002a6a:	e44e                	sd	s3,8(sp)
    80002a6c:	e052                	sd	s4,0(sp)
    80002a6e:	1800                	addi	s0,sp,48
    80002a70:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002a72:	47ad                	li	a5,11
    80002a74:	02b7e763          	bltu	a5,a1,80002aa2 <bmap+0x42>
    if((addr = ip->addrs[bn]) == 0){
    80002a78:	02059493          	slli	s1,a1,0x20
    80002a7c:	9081                	srli	s1,s1,0x20
    80002a7e:	048a                	slli	s1,s1,0x2
    80002a80:	94aa                	add	s1,s1,a0
    80002a82:	0504a903          	lw	s2,80(s1)
    80002a86:	06091e63          	bnez	s2,80002b02 <bmap+0xa2>
      addr = balloc(ip->dev);
    80002a8a:	4108                	lw	a0,0(a0)
    80002a8c:	00000097          	auipc	ra,0x0
    80002a90:	e9c080e7          	jalr	-356(ra) # 80002928 <balloc>
    80002a94:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002a98:	06090563          	beqz	s2,80002b02 <bmap+0xa2>
        return 0;
      ip->addrs[bn] = addr;
    80002a9c:	0524a823          	sw	s2,80(s1)
    80002aa0:	a08d                	j	80002b02 <bmap+0xa2>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002aa2:	ff45849b          	addiw	s1,a1,-12
    80002aa6:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002aaa:	0ff00793          	li	a5,255
    80002aae:	08e7e563          	bltu	a5,a4,80002b38 <bmap+0xd8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002ab2:	08052903          	lw	s2,128(a0)
    80002ab6:	00091d63          	bnez	s2,80002ad0 <bmap+0x70>
      addr = balloc(ip->dev);
    80002aba:	4108                	lw	a0,0(a0)
    80002abc:	00000097          	auipc	ra,0x0
    80002ac0:	e6c080e7          	jalr	-404(ra) # 80002928 <balloc>
    80002ac4:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002ac8:	02090d63          	beqz	s2,80002b02 <bmap+0xa2>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002acc:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80002ad0:	85ca                	mv	a1,s2
    80002ad2:	0009a503          	lw	a0,0(s3)
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	b90080e7          	jalr	-1136(ra) # 80002666 <bread>
    80002ade:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002ae0:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002ae4:	02049593          	slli	a1,s1,0x20
    80002ae8:	9181                	srli	a1,a1,0x20
    80002aea:	058a                	slli	a1,a1,0x2
    80002aec:	00b784b3          	add	s1,a5,a1
    80002af0:	0004a903          	lw	s2,0(s1)
    80002af4:	02090063          	beqz	s2,80002b14 <bmap+0xb4>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002af8:	8552                	mv	a0,s4
    80002afa:	00000097          	auipc	ra,0x0
    80002afe:	c9c080e7          	jalr	-868(ra) # 80002796 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80002b02:	854a                	mv	a0,s2
    80002b04:	70a2                	ld	ra,40(sp)
    80002b06:	7402                	ld	s0,32(sp)
    80002b08:	64e2                	ld	s1,24(sp)
    80002b0a:	6942                	ld	s2,16(sp)
    80002b0c:	69a2                	ld	s3,8(sp)
    80002b0e:	6a02                	ld	s4,0(sp)
    80002b10:	6145                	addi	sp,sp,48
    80002b12:	8082                	ret
      addr = balloc(ip->dev);
    80002b14:	0009a503          	lw	a0,0(s3)
    80002b18:	00000097          	auipc	ra,0x0
    80002b1c:	e10080e7          	jalr	-496(ra) # 80002928 <balloc>
    80002b20:	0005091b          	sext.w	s2,a0
      if(addr){
    80002b24:	fc090ae3          	beqz	s2,80002af8 <bmap+0x98>
        a[bn] = addr;
    80002b28:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002b2c:	8552                	mv	a0,s4
    80002b2e:	00001097          	auipc	ra,0x1
    80002b32:	eec080e7          	jalr	-276(ra) # 80003a1a <log_write>
    80002b36:	b7c9                	j	80002af8 <bmap+0x98>
  panic("bmap: out of range");
    80002b38:	00006517          	auipc	a0,0x6
    80002b3c:	9f050513          	addi	a0,a0,-1552 # 80008528 <syscalls+0x118>
    80002b40:	00003097          	auipc	ra,0x3
    80002b44:	442080e7          	jalr	1090(ra) # 80005f82 <panic>

0000000080002b48 <iget>:
{
    80002b48:	7179                	addi	sp,sp,-48
    80002b4a:	f406                	sd	ra,40(sp)
    80002b4c:	f022                	sd	s0,32(sp)
    80002b4e:	ec26                	sd	s1,24(sp)
    80002b50:	e84a                	sd	s2,16(sp)
    80002b52:	e44e                	sd	s3,8(sp)
    80002b54:	e052                	sd	s4,0(sp)
    80002b56:	1800                	addi	s0,sp,48
    80002b58:	89aa                	mv	s3,a0
    80002b5a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002b5c:	00234517          	auipc	a0,0x234
    80002b60:	32450513          	addi	a0,a0,804 # 80236e80 <itable>
    80002b64:	00004097          	auipc	ra,0x4
    80002b68:	968080e7          	jalr	-1688(ra) # 800064cc <acquire>
  empty = 0;
    80002b6c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002b6e:	00234497          	auipc	s1,0x234
    80002b72:	32a48493          	addi	s1,s1,810 # 80236e98 <itable+0x18>
    80002b76:	00236697          	auipc	a3,0x236
    80002b7a:	db268693          	addi	a3,a3,-590 # 80238928 <log>
    80002b7e:	a039                	j	80002b8c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002b80:	02090b63          	beqz	s2,80002bb6 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002b84:	08848493          	addi	s1,s1,136
    80002b88:	02d48a63          	beq	s1,a3,80002bbc <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002b8c:	449c                	lw	a5,8(s1)
    80002b8e:	fef059e3          	blez	a5,80002b80 <iget+0x38>
    80002b92:	4098                	lw	a4,0(s1)
    80002b94:	ff3716e3          	bne	a4,s3,80002b80 <iget+0x38>
    80002b98:	40d8                	lw	a4,4(s1)
    80002b9a:	ff4713e3          	bne	a4,s4,80002b80 <iget+0x38>
      ip->ref++;
    80002b9e:	2785                	addiw	a5,a5,1
    80002ba0:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80002ba2:	00234517          	auipc	a0,0x234
    80002ba6:	2de50513          	addi	a0,a0,734 # 80236e80 <itable>
    80002baa:	00004097          	auipc	ra,0x4
    80002bae:	9d6080e7          	jalr	-1578(ra) # 80006580 <release>
      return ip;
    80002bb2:	8926                	mv	s2,s1
    80002bb4:	a03d                	j	80002be2 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002bb6:	f7f9                	bnez	a5,80002b84 <iget+0x3c>
    80002bb8:	8926                	mv	s2,s1
    80002bba:	b7e9                	j	80002b84 <iget+0x3c>
  if(empty == 0)
    80002bbc:	02090c63          	beqz	s2,80002bf4 <iget+0xac>
  ip->dev = dev;
    80002bc0:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002bc4:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80002bc8:	4785                	li	a5,1
    80002bca:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002bce:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80002bd2:	00234517          	auipc	a0,0x234
    80002bd6:	2ae50513          	addi	a0,a0,686 # 80236e80 <itable>
    80002bda:	00004097          	auipc	ra,0x4
    80002bde:	9a6080e7          	jalr	-1626(ra) # 80006580 <release>
}
    80002be2:	854a                	mv	a0,s2
    80002be4:	70a2                	ld	ra,40(sp)
    80002be6:	7402                	ld	s0,32(sp)
    80002be8:	64e2                	ld	s1,24(sp)
    80002bea:	6942                	ld	s2,16(sp)
    80002bec:	69a2                	ld	s3,8(sp)
    80002bee:	6a02                	ld	s4,0(sp)
    80002bf0:	6145                	addi	sp,sp,48
    80002bf2:	8082                	ret
    panic("iget: no inodes");
    80002bf4:	00006517          	auipc	a0,0x6
    80002bf8:	94c50513          	addi	a0,a0,-1716 # 80008540 <syscalls+0x130>
    80002bfc:	00003097          	auipc	ra,0x3
    80002c00:	386080e7          	jalr	902(ra) # 80005f82 <panic>

0000000080002c04 <fsinit>:
fsinit(int dev) {
    80002c04:	7179                	addi	sp,sp,-48
    80002c06:	f406                	sd	ra,40(sp)
    80002c08:	f022                	sd	s0,32(sp)
    80002c0a:	ec26                	sd	s1,24(sp)
    80002c0c:	e84a                	sd	s2,16(sp)
    80002c0e:	e44e                	sd	s3,8(sp)
    80002c10:	1800                	addi	s0,sp,48
    80002c12:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80002c14:	4585                	li	a1,1
    80002c16:	00000097          	auipc	ra,0x0
    80002c1a:	a50080e7          	jalr	-1456(ra) # 80002666 <bread>
    80002c1e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002c20:	00234997          	auipc	s3,0x234
    80002c24:	24098993          	addi	s3,s3,576 # 80236e60 <sb>
    80002c28:	02000613          	li	a2,32
    80002c2c:	05850593          	addi	a1,a0,88
    80002c30:	854e                	mv	a0,s3
    80002c32:	ffffd097          	auipc	ra,0xffffd
    80002c36:	7ca080e7          	jalr	1994(ra) # 800003fc <memmove>
  brelse(bp);
    80002c3a:	8526                	mv	a0,s1
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	b5a080e7          	jalr	-1190(ra) # 80002796 <brelse>
  if(sb.magic != FSMAGIC)
    80002c44:	0009a703          	lw	a4,0(s3)
    80002c48:	102037b7          	lui	a5,0x10203
    80002c4c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002c50:	02f71263          	bne	a4,a5,80002c74 <fsinit+0x70>
  initlog(dev, &sb);
    80002c54:	00234597          	auipc	a1,0x234
    80002c58:	20c58593          	addi	a1,a1,524 # 80236e60 <sb>
    80002c5c:	854a                	mv	a0,s2
    80002c5e:	00001097          	auipc	ra,0x1
    80002c62:	b40080e7          	jalr	-1216(ra) # 8000379e <initlog>
}
    80002c66:	70a2                	ld	ra,40(sp)
    80002c68:	7402                	ld	s0,32(sp)
    80002c6a:	64e2                	ld	s1,24(sp)
    80002c6c:	6942                	ld	s2,16(sp)
    80002c6e:	69a2                	ld	s3,8(sp)
    80002c70:	6145                	addi	sp,sp,48
    80002c72:	8082                	ret
    panic("invalid file system");
    80002c74:	00006517          	auipc	a0,0x6
    80002c78:	8dc50513          	addi	a0,a0,-1828 # 80008550 <syscalls+0x140>
    80002c7c:	00003097          	auipc	ra,0x3
    80002c80:	306080e7          	jalr	774(ra) # 80005f82 <panic>

0000000080002c84 <iinit>:
{
    80002c84:	7179                	addi	sp,sp,-48
    80002c86:	f406                	sd	ra,40(sp)
    80002c88:	f022                	sd	s0,32(sp)
    80002c8a:	ec26                	sd	s1,24(sp)
    80002c8c:	e84a                	sd	s2,16(sp)
    80002c8e:	e44e                	sd	s3,8(sp)
    80002c90:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80002c92:	00006597          	auipc	a1,0x6
    80002c96:	8d658593          	addi	a1,a1,-1834 # 80008568 <syscalls+0x158>
    80002c9a:	00234517          	auipc	a0,0x234
    80002c9e:	1e650513          	addi	a0,a0,486 # 80236e80 <itable>
    80002ca2:	00003097          	auipc	ra,0x3
    80002ca6:	79a080e7          	jalr	1946(ra) # 8000643c <initlock>
  for(i = 0; i < NINODE; i++) {
    80002caa:	00234497          	auipc	s1,0x234
    80002cae:	1fe48493          	addi	s1,s1,510 # 80236ea8 <itable+0x28>
    80002cb2:	00236997          	auipc	s3,0x236
    80002cb6:	c8698993          	addi	s3,s3,-890 # 80238938 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80002cba:	00006917          	auipc	s2,0x6
    80002cbe:	8b690913          	addi	s2,s2,-1866 # 80008570 <syscalls+0x160>
    80002cc2:	85ca                	mv	a1,s2
    80002cc4:	8526                	mv	a0,s1
    80002cc6:	00001097          	auipc	ra,0x1
    80002cca:	e3a080e7          	jalr	-454(ra) # 80003b00 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002cce:	08848493          	addi	s1,s1,136
    80002cd2:	ff3498e3          	bne	s1,s3,80002cc2 <iinit+0x3e>
}
    80002cd6:	70a2                	ld	ra,40(sp)
    80002cd8:	7402                	ld	s0,32(sp)
    80002cda:	64e2                	ld	s1,24(sp)
    80002cdc:	6942                	ld	s2,16(sp)
    80002cde:	69a2                	ld	s3,8(sp)
    80002ce0:	6145                	addi	sp,sp,48
    80002ce2:	8082                	ret

0000000080002ce4 <ialloc>:
{
    80002ce4:	715d                	addi	sp,sp,-80
    80002ce6:	e486                	sd	ra,72(sp)
    80002ce8:	e0a2                	sd	s0,64(sp)
    80002cea:	fc26                	sd	s1,56(sp)
    80002cec:	f84a                	sd	s2,48(sp)
    80002cee:	f44e                	sd	s3,40(sp)
    80002cf0:	f052                	sd	s4,32(sp)
    80002cf2:	ec56                	sd	s5,24(sp)
    80002cf4:	e85a                	sd	s6,16(sp)
    80002cf6:	e45e                	sd	s7,8(sp)
    80002cf8:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002cfa:	00234717          	auipc	a4,0x234
    80002cfe:	17272703          	lw	a4,370(a4) # 80236e6c <sb+0xc>
    80002d02:	4785                	li	a5,1
    80002d04:	04e7fa63          	bgeu	a5,a4,80002d58 <ialloc+0x74>
    80002d08:	8aaa                	mv	s5,a0
    80002d0a:	8bae                	mv	s7,a1
    80002d0c:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002d0e:	00234a17          	auipc	s4,0x234
    80002d12:	152a0a13          	addi	s4,s4,338 # 80236e60 <sb>
    80002d16:	00048b1b          	sext.w	s6,s1
    80002d1a:	0044d593          	srli	a1,s1,0x4
    80002d1e:	018a2783          	lw	a5,24(s4)
    80002d22:	9dbd                	addw	a1,a1,a5
    80002d24:	8556                	mv	a0,s5
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	940080e7          	jalr	-1728(ra) # 80002666 <bread>
    80002d2e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002d30:	05850993          	addi	s3,a0,88
    80002d34:	00f4f793          	andi	a5,s1,15
    80002d38:	079a                	slli	a5,a5,0x6
    80002d3a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80002d3c:	00099783          	lh	a5,0(s3)
    80002d40:	c3a1                	beqz	a5,80002d80 <ialloc+0x9c>
    brelse(bp);
    80002d42:	00000097          	auipc	ra,0x0
    80002d46:	a54080e7          	jalr	-1452(ra) # 80002796 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002d4a:	0485                	addi	s1,s1,1
    80002d4c:	00ca2703          	lw	a4,12(s4)
    80002d50:	0004879b          	sext.w	a5,s1
    80002d54:	fce7e1e3          	bltu	a5,a4,80002d16 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80002d58:	00006517          	auipc	a0,0x6
    80002d5c:	82050513          	addi	a0,a0,-2016 # 80008578 <syscalls+0x168>
    80002d60:	00003097          	auipc	ra,0x3
    80002d64:	26c080e7          	jalr	620(ra) # 80005fcc <printf>
  return 0;
    80002d68:	4501                	li	a0,0
}
    80002d6a:	60a6                	ld	ra,72(sp)
    80002d6c:	6406                	ld	s0,64(sp)
    80002d6e:	74e2                	ld	s1,56(sp)
    80002d70:	7942                	ld	s2,48(sp)
    80002d72:	79a2                	ld	s3,40(sp)
    80002d74:	7a02                	ld	s4,32(sp)
    80002d76:	6ae2                	ld	s5,24(sp)
    80002d78:	6b42                	ld	s6,16(sp)
    80002d7a:	6ba2                	ld	s7,8(sp)
    80002d7c:	6161                	addi	sp,sp,80
    80002d7e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80002d80:	04000613          	li	a2,64
    80002d84:	4581                	li	a1,0
    80002d86:	854e                	mv	a0,s3
    80002d88:	ffffd097          	auipc	ra,0xffffd
    80002d8c:	614080e7          	jalr	1556(ra) # 8000039c <memset>
      dip->type = type;
    80002d90:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80002d94:	854a                	mv	a0,s2
    80002d96:	00001097          	auipc	ra,0x1
    80002d9a:	c84080e7          	jalr	-892(ra) # 80003a1a <log_write>
      brelse(bp);
    80002d9e:	854a                	mv	a0,s2
    80002da0:	00000097          	auipc	ra,0x0
    80002da4:	9f6080e7          	jalr	-1546(ra) # 80002796 <brelse>
      return iget(dev, inum);
    80002da8:	85da                	mv	a1,s6
    80002daa:	8556                	mv	a0,s5
    80002dac:	00000097          	auipc	ra,0x0
    80002db0:	d9c080e7          	jalr	-612(ra) # 80002b48 <iget>
    80002db4:	bf5d                	j	80002d6a <ialloc+0x86>

0000000080002db6 <iupdate>:
{
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	e426                	sd	s1,8(sp)
    80002dbe:	e04a                	sd	s2,0(sp)
    80002dc0:	1000                	addi	s0,sp,32
    80002dc2:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002dc4:	415c                	lw	a5,4(a0)
    80002dc6:	0047d79b          	srliw	a5,a5,0x4
    80002dca:	00234597          	auipc	a1,0x234
    80002dce:	0ae5a583          	lw	a1,174(a1) # 80236e78 <sb+0x18>
    80002dd2:	9dbd                	addw	a1,a1,a5
    80002dd4:	4108                	lw	a0,0(a0)
    80002dd6:	00000097          	auipc	ra,0x0
    80002dda:	890080e7          	jalr	-1904(ra) # 80002666 <bread>
    80002dde:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002de0:	05850793          	addi	a5,a0,88
    80002de4:	40c8                	lw	a0,4(s1)
    80002de6:	893d                	andi	a0,a0,15
    80002de8:	051a                	slli	a0,a0,0x6
    80002dea:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002dec:	04449703          	lh	a4,68(s1)
    80002df0:	00e51023          	sh	a4,0(a0)
  dip->major = ip->major;
    80002df4:	04649703          	lh	a4,70(s1)
    80002df8:	00e51123          	sh	a4,2(a0)
  dip->minor = ip->minor;
    80002dfc:	04849703          	lh	a4,72(s1)
    80002e00:	00e51223          	sh	a4,4(a0)
  dip->nlink = ip->nlink;
    80002e04:	04a49703          	lh	a4,74(s1)
    80002e08:	00e51323          	sh	a4,6(a0)
  dip->size = ip->size;
    80002e0c:	44f8                	lw	a4,76(s1)
    80002e0e:	c518                	sw	a4,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002e10:	03400613          	li	a2,52
    80002e14:	05048593          	addi	a1,s1,80
    80002e18:	0531                	addi	a0,a0,12
    80002e1a:	ffffd097          	auipc	ra,0xffffd
    80002e1e:	5e2080e7          	jalr	1506(ra) # 800003fc <memmove>
  log_write(bp);
    80002e22:	854a                	mv	a0,s2
    80002e24:	00001097          	auipc	ra,0x1
    80002e28:	bf6080e7          	jalr	-1034(ra) # 80003a1a <log_write>
  brelse(bp);
    80002e2c:	854a                	mv	a0,s2
    80002e2e:	00000097          	auipc	ra,0x0
    80002e32:	968080e7          	jalr	-1688(ra) # 80002796 <brelse>
}
    80002e36:	60e2                	ld	ra,24(sp)
    80002e38:	6442                	ld	s0,16(sp)
    80002e3a:	64a2                	ld	s1,8(sp)
    80002e3c:	6902                	ld	s2,0(sp)
    80002e3e:	6105                	addi	sp,sp,32
    80002e40:	8082                	ret

0000000080002e42 <idup>:
{
    80002e42:	1101                	addi	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	e426                	sd	s1,8(sp)
    80002e4a:	1000                	addi	s0,sp,32
    80002e4c:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80002e4e:	00234517          	auipc	a0,0x234
    80002e52:	03250513          	addi	a0,a0,50 # 80236e80 <itable>
    80002e56:	00003097          	auipc	ra,0x3
    80002e5a:	676080e7          	jalr	1654(ra) # 800064cc <acquire>
  ip->ref++;
    80002e5e:	449c                	lw	a5,8(s1)
    80002e60:	2785                	addiw	a5,a5,1
    80002e62:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80002e64:	00234517          	auipc	a0,0x234
    80002e68:	01c50513          	addi	a0,a0,28 # 80236e80 <itable>
    80002e6c:	00003097          	auipc	ra,0x3
    80002e70:	714080e7          	jalr	1812(ra) # 80006580 <release>
}
    80002e74:	8526                	mv	a0,s1
    80002e76:	60e2                	ld	ra,24(sp)
    80002e78:	6442                	ld	s0,16(sp)
    80002e7a:	64a2                	ld	s1,8(sp)
    80002e7c:	6105                	addi	sp,sp,32
    80002e7e:	8082                	ret

0000000080002e80 <ilock>:
{
    80002e80:	1101                	addi	sp,sp,-32
    80002e82:	ec06                	sd	ra,24(sp)
    80002e84:	e822                	sd	s0,16(sp)
    80002e86:	e426                	sd	s1,8(sp)
    80002e88:	e04a                	sd	s2,0(sp)
    80002e8a:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002e8c:	c115                	beqz	a0,80002eb0 <ilock+0x30>
    80002e8e:	84aa                	mv	s1,a0
    80002e90:	451c                	lw	a5,8(a0)
    80002e92:	00f05f63          	blez	a5,80002eb0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002e96:	0541                	addi	a0,a0,16
    80002e98:	00001097          	auipc	ra,0x1
    80002e9c:	ca2080e7          	jalr	-862(ra) # 80003b3a <acquiresleep>
  if(ip->valid == 0){
    80002ea0:	40bc                	lw	a5,64(s1)
    80002ea2:	cf99                	beqz	a5,80002ec0 <ilock+0x40>
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	64a2                	ld	s1,8(sp)
    80002eaa:	6902                	ld	s2,0(sp)
    80002eac:	6105                	addi	sp,sp,32
    80002eae:	8082                	ret
    panic("ilock");
    80002eb0:	00005517          	auipc	a0,0x5
    80002eb4:	6e050513          	addi	a0,a0,1760 # 80008590 <syscalls+0x180>
    80002eb8:	00003097          	auipc	ra,0x3
    80002ebc:	0ca080e7          	jalr	202(ra) # 80005f82 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002ec0:	40dc                	lw	a5,4(s1)
    80002ec2:	0047d79b          	srliw	a5,a5,0x4
    80002ec6:	00234597          	auipc	a1,0x234
    80002eca:	fb25a583          	lw	a1,-78(a1) # 80236e78 <sb+0x18>
    80002ece:	9dbd                	addw	a1,a1,a5
    80002ed0:	4088                	lw	a0,0(s1)
    80002ed2:	fffff097          	auipc	ra,0xfffff
    80002ed6:	794080e7          	jalr	1940(ra) # 80002666 <bread>
    80002eda:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002edc:	05850593          	addi	a1,a0,88
    80002ee0:	40dc                	lw	a5,4(s1)
    80002ee2:	8bbd                	andi	a5,a5,15
    80002ee4:	079a                	slli	a5,a5,0x6
    80002ee6:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002ee8:	00059783          	lh	a5,0(a1)
    80002eec:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002ef0:	00259783          	lh	a5,2(a1)
    80002ef4:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002ef8:	00459783          	lh	a5,4(a1)
    80002efc:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002f00:	00659783          	lh	a5,6(a1)
    80002f04:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002f08:	459c                	lw	a5,8(a1)
    80002f0a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002f0c:	03400613          	li	a2,52
    80002f10:	05b1                	addi	a1,a1,12
    80002f12:	05048513          	addi	a0,s1,80
    80002f16:	ffffd097          	auipc	ra,0xffffd
    80002f1a:	4e6080e7          	jalr	1254(ra) # 800003fc <memmove>
    brelse(bp);
    80002f1e:	854a                	mv	a0,s2
    80002f20:	00000097          	auipc	ra,0x0
    80002f24:	876080e7          	jalr	-1930(ra) # 80002796 <brelse>
    ip->valid = 1;
    80002f28:	4785                	li	a5,1
    80002f2a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002f2c:	04449783          	lh	a5,68(s1)
    80002f30:	fbb5                	bnez	a5,80002ea4 <ilock+0x24>
      panic("ilock: no type");
    80002f32:	00005517          	auipc	a0,0x5
    80002f36:	66650513          	addi	a0,a0,1638 # 80008598 <syscalls+0x188>
    80002f3a:	00003097          	auipc	ra,0x3
    80002f3e:	048080e7          	jalr	72(ra) # 80005f82 <panic>

0000000080002f42 <iunlock>:
{
    80002f42:	1101                	addi	sp,sp,-32
    80002f44:	ec06                	sd	ra,24(sp)
    80002f46:	e822                	sd	s0,16(sp)
    80002f48:	e426                	sd	s1,8(sp)
    80002f4a:	e04a                	sd	s2,0(sp)
    80002f4c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002f4e:	c905                	beqz	a0,80002f7e <iunlock+0x3c>
    80002f50:	84aa                	mv	s1,a0
    80002f52:	01050913          	addi	s2,a0,16
    80002f56:	854a                	mv	a0,s2
    80002f58:	00001097          	auipc	ra,0x1
    80002f5c:	c7c080e7          	jalr	-900(ra) # 80003bd4 <holdingsleep>
    80002f60:	cd19                	beqz	a0,80002f7e <iunlock+0x3c>
    80002f62:	449c                	lw	a5,8(s1)
    80002f64:	00f05d63          	blez	a5,80002f7e <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002f68:	854a                	mv	a0,s2
    80002f6a:	00001097          	auipc	ra,0x1
    80002f6e:	c26080e7          	jalr	-986(ra) # 80003b90 <releasesleep>
}
    80002f72:	60e2                	ld	ra,24(sp)
    80002f74:	6442                	ld	s0,16(sp)
    80002f76:	64a2                	ld	s1,8(sp)
    80002f78:	6902                	ld	s2,0(sp)
    80002f7a:	6105                	addi	sp,sp,32
    80002f7c:	8082                	ret
    panic("iunlock");
    80002f7e:	00005517          	auipc	a0,0x5
    80002f82:	62a50513          	addi	a0,a0,1578 # 800085a8 <syscalls+0x198>
    80002f86:	00003097          	auipc	ra,0x3
    80002f8a:	ffc080e7          	jalr	-4(ra) # 80005f82 <panic>

0000000080002f8e <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002f8e:	7179                	addi	sp,sp,-48
    80002f90:	f406                	sd	ra,40(sp)
    80002f92:	f022                	sd	s0,32(sp)
    80002f94:	ec26                	sd	s1,24(sp)
    80002f96:	e84a                	sd	s2,16(sp)
    80002f98:	e44e                	sd	s3,8(sp)
    80002f9a:	e052                	sd	s4,0(sp)
    80002f9c:	1800                	addi	s0,sp,48
    80002f9e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002fa0:	05050493          	addi	s1,a0,80
    80002fa4:	08050913          	addi	s2,a0,128
    80002fa8:	a021                	j	80002fb0 <itrunc+0x22>
    80002faa:	0491                	addi	s1,s1,4
    80002fac:	01248d63          	beq	s1,s2,80002fc6 <itrunc+0x38>
    if(ip->addrs[i]){
    80002fb0:	408c                	lw	a1,0(s1)
    80002fb2:	dde5                	beqz	a1,80002faa <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80002fb4:	0009a503          	lw	a0,0(s3)
    80002fb8:	00000097          	auipc	ra,0x0
    80002fbc:	8f4080e7          	jalr	-1804(ra) # 800028ac <bfree>
      ip->addrs[i] = 0;
    80002fc0:	0004a023          	sw	zero,0(s1)
    80002fc4:	b7dd                	j	80002faa <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002fc6:	0809a583          	lw	a1,128(s3)
    80002fca:	e185                	bnez	a1,80002fea <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002fcc:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002fd0:	854e                	mv	a0,s3
    80002fd2:	00000097          	auipc	ra,0x0
    80002fd6:	de4080e7          	jalr	-540(ra) # 80002db6 <iupdate>
}
    80002fda:	70a2                	ld	ra,40(sp)
    80002fdc:	7402                	ld	s0,32(sp)
    80002fde:	64e2                	ld	s1,24(sp)
    80002fe0:	6942                	ld	s2,16(sp)
    80002fe2:	69a2                	ld	s3,8(sp)
    80002fe4:	6a02                	ld	s4,0(sp)
    80002fe6:	6145                	addi	sp,sp,48
    80002fe8:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002fea:	0009a503          	lw	a0,0(s3)
    80002fee:	fffff097          	auipc	ra,0xfffff
    80002ff2:	678080e7          	jalr	1656(ra) # 80002666 <bread>
    80002ff6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002ff8:	05850493          	addi	s1,a0,88
    80002ffc:	45850913          	addi	s2,a0,1112
    80003000:	a811                	j	80003014 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80003002:	0009a503          	lw	a0,0(s3)
    80003006:	00000097          	auipc	ra,0x0
    8000300a:	8a6080e7          	jalr	-1882(ra) # 800028ac <bfree>
    for(j = 0; j < NINDIRECT; j++){
    8000300e:	0491                	addi	s1,s1,4
    80003010:	01248563          	beq	s1,s2,8000301a <itrunc+0x8c>
      if(a[j])
    80003014:	408c                	lw	a1,0(s1)
    80003016:	dde5                	beqz	a1,8000300e <itrunc+0x80>
    80003018:	b7ed                	j	80003002 <itrunc+0x74>
    brelse(bp);
    8000301a:	8552                	mv	a0,s4
    8000301c:	fffff097          	auipc	ra,0xfffff
    80003020:	77a080e7          	jalr	1914(ra) # 80002796 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003024:	0809a583          	lw	a1,128(s3)
    80003028:	0009a503          	lw	a0,0(s3)
    8000302c:	00000097          	auipc	ra,0x0
    80003030:	880080e7          	jalr	-1920(ra) # 800028ac <bfree>
    ip->addrs[NDIRECT] = 0;
    80003034:	0809a023          	sw	zero,128(s3)
    80003038:	bf51                	j	80002fcc <itrunc+0x3e>

000000008000303a <iput>:
{
    8000303a:	1101                	addi	sp,sp,-32
    8000303c:	ec06                	sd	ra,24(sp)
    8000303e:	e822                	sd	s0,16(sp)
    80003040:	e426                	sd	s1,8(sp)
    80003042:	e04a                	sd	s2,0(sp)
    80003044:	1000                	addi	s0,sp,32
    80003046:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003048:	00234517          	auipc	a0,0x234
    8000304c:	e3850513          	addi	a0,a0,-456 # 80236e80 <itable>
    80003050:	00003097          	auipc	ra,0x3
    80003054:	47c080e7          	jalr	1148(ra) # 800064cc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003058:	4498                	lw	a4,8(s1)
    8000305a:	4785                	li	a5,1
    8000305c:	02f70363          	beq	a4,a5,80003082 <iput+0x48>
  ip->ref--;
    80003060:	449c                	lw	a5,8(s1)
    80003062:	37fd                	addiw	a5,a5,-1
    80003064:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003066:	00234517          	auipc	a0,0x234
    8000306a:	e1a50513          	addi	a0,a0,-486 # 80236e80 <itable>
    8000306e:	00003097          	auipc	ra,0x3
    80003072:	512080e7          	jalr	1298(ra) # 80006580 <release>
}
    80003076:	60e2                	ld	ra,24(sp)
    80003078:	6442                	ld	s0,16(sp)
    8000307a:	64a2                	ld	s1,8(sp)
    8000307c:	6902                	ld	s2,0(sp)
    8000307e:	6105                	addi	sp,sp,32
    80003080:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003082:	40bc                	lw	a5,64(s1)
    80003084:	dff1                	beqz	a5,80003060 <iput+0x26>
    80003086:	04a49783          	lh	a5,74(s1)
    8000308a:	fbf9                	bnez	a5,80003060 <iput+0x26>
    acquiresleep(&ip->lock);
    8000308c:	01048913          	addi	s2,s1,16
    80003090:	854a                	mv	a0,s2
    80003092:	00001097          	auipc	ra,0x1
    80003096:	aa8080e7          	jalr	-1368(ra) # 80003b3a <acquiresleep>
    release(&itable.lock);
    8000309a:	00234517          	auipc	a0,0x234
    8000309e:	de650513          	addi	a0,a0,-538 # 80236e80 <itable>
    800030a2:	00003097          	auipc	ra,0x3
    800030a6:	4de080e7          	jalr	1246(ra) # 80006580 <release>
    itrunc(ip);
    800030aa:	8526                	mv	a0,s1
    800030ac:	00000097          	auipc	ra,0x0
    800030b0:	ee2080e7          	jalr	-286(ra) # 80002f8e <itrunc>
    ip->type = 0;
    800030b4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800030b8:	8526                	mv	a0,s1
    800030ba:	00000097          	auipc	ra,0x0
    800030be:	cfc080e7          	jalr	-772(ra) # 80002db6 <iupdate>
    ip->valid = 0;
    800030c2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800030c6:	854a                	mv	a0,s2
    800030c8:	00001097          	auipc	ra,0x1
    800030cc:	ac8080e7          	jalr	-1336(ra) # 80003b90 <releasesleep>
    acquire(&itable.lock);
    800030d0:	00234517          	auipc	a0,0x234
    800030d4:	db050513          	addi	a0,a0,-592 # 80236e80 <itable>
    800030d8:	00003097          	auipc	ra,0x3
    800030dc:	3f4080e7          	jalr	1012(ra) # 800064cc <acquire>
    800030e0:	b741                	j	80003060 <iput+0x26>

00000000800030e2 <iunlockput>:
{
    800030e2:	1101                	addi	sp,sp,-32
    800030e4:	ec06                	sd	ra,24(sp)
    800030e6:	e822                	sd	s0,16(sp)
    800030e8:	e426                	sd	s1,8(sp)
    800030ea:	1000                	addi	s0,sp,32
    800030ec:	84aa                	mv	s1,a0
  iunlock(ip);
    800030ee:	00000097          	auipc	ra,0x0
    800030f2:	e54080e7          	jalr	-428(ra) # 80002f42 <iunlock>
  iput(ip);
    800030f6:	8526                	mv	a0,s1
    800030f8:	00000097          	auipc	ra,0x0
    800030fc:	f42080e7          	jalr	-190(ra) # 8000303a <iput>
}
    80003100:	60e2                	ld	ra,24(sp)
    80003102:	6442                	ld	s0,16(sp)
    80003104:	64a2                	ld	s1,8(sp)
    80003106:	6105                	addi	sp,sp,32
    80003108:	8082                	ret

000000008000310a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000310a:	1141                	addi	sp,sp,-16
    8000310c:	e422                	sd	s0,8(sp)
    8000310e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003110:	411c                	lw	a5,0(a0)
    80003112:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003114:	415c                	lw	a5,4(a0)
    80003116:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003118:	04451783          	lh	a5,68(a0)
    8000311c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003120:	04a51783          	lh	a5,74(a0)
    80003124:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003128:	04c56783          	lwu	a5,76(a0)
    8000312c:	e99c                	sd	a5,16(a1)
}
    8000312e:	6422                	ld	s0,8(sp)
    80003130:	0141                	addi	sp,sp,16
    80003132:	8082                	ret

0000000080003134 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003134:	457c                	lw	a5,76(a0)
    80003136:	0ed7e963          	bltu	a5,a3,80003228 <readi+0xf4>
{
    8000313a:	7159                	addi	sp,sp,-112
    8000313c:	f486                	sd	ra,104(sp)
    8000313e:	f0a2                	sd	s0,96(sp)
    80003140:	eca6                	sd	s1,88(sp)
    80003142:	e8ca                	sd	s2,80(sp)
    80003144:	e4ce                	sd	s3,72(sp)
    80003146:	e0d2                	sd	s4,64(sp)
    80003148:	fc56                	sd	s5,56(sp)
    8000314a:	f85a                	sd	s6,48(sp)
    8000314c:	f45e                	sd	s7,40(sp)
    8000314e:	f062                	sd	s8,32(sp)
    80003150:	ec66                	sd	s9,24(sp)
    80003152:	e86a                	sd	s10,16(sp)
    80003154:	e46e                	sd	s11,8(sp)
    80003156:	1880                	addi	s0,sp,112
    80003158:	8b2a                	mv	s6,a0
    8000315a:	8bae                	mv	s7,a1
    8000315c:	8a32                	mv	s4,a2
    8000315e:	84b6                	mv	s1,a3
    80003160:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003162:	9f35                	addw	a4,a4,a3
    return 0;
    80003164:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003166:	0ad76063          	bltu	a4,a3,80003206 <readi+0xd2>
  if(off + n > ip->size)
    8000316a:	00e7f463          	bgeu	a5,a4,80003172 <readi+0x3e>
    n = ip->size - off;
    8000316e:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003172:	0a0a8963          	beqz	s5,80003224 <readi+0xf0>
    80003176:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003178:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000317c:	5c7d                	li	s8,-1
    8000317e:	a82d                	j	800031b8 <readi+0x84>
    80003180:	020d1d93          	slli	s11,s10,0x20
    80003184:	020ddd93          	srli	s11,s11,0x20
    80003188:	05890613          	addi	a2,s2,88
    8000318c:	86ee                	mv	a3,s11
    8000318e:	963a                	add	a2,a2,a4
    80003190:	85d2                	mv	a1,s4
    80003192:	855e                	mv	a0,s7
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	a22080e7          	jalr	-1502(ra) # 80001bb6 <either_copyout>
    8000319c:	05850d63          	beq	a0,s8,800031f6 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800031a0:	854a                	mv	a0,s2
    800031a2:	fffff097          	auipc	ra,0xfffff
    800031a6:	5f4080e7          	jalr	1524(ra) # 80002796 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800031aa:	013d09bb          	addw	s3,s10,s3
    800031ae:	009d04bb          	addw	s1,s10,s1
    800031b2:	9a6e                	add	s4,s4,s11
    800031b4:	0559f763          	bgeu	s3,s5,80003202 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    800031b8:	00a4d59b          	srliw	a1,s1,0xa
    800031bc:	855a                	mv	a0,s6
    800031be:	00000097          	auipc	ra,0x0
    800031c2:	8a2080e7          	jalr	-1886(ra) # 80002a60 <bmap>
    800031c6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800031ca:	cd85                	beqz	a1,80003202 <readi+0xce>
    bp = bread(ip->dev, addr);
    800031cc:	000b2503          	lw	a0,0(s6)
    800031d0:	fffff097          	auipc	ra,0xfffff
    800031d4:	496080e7          	jalr	1174(ra) # 80002666 <bread>
    800031d8:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800031da:	3ff4f713          	andi	a4,s1,1023
    800031de:	40ec87bb          	subw	a5,s9,a4
    800031e2:	413a86bb          	subw	a3,s5,s3
    800031e6:	8d3e                	mv	s10,a5
    800031e8:	2781                	sext.w	a5,a5
    800031ea:	0006861b          	sext.w	a2,a3
    800031ee:	f8f679e3          	bgeu	a2,a5,80003180 <readi+0x4c>
    800031f2:	8d36                	mv	s10,a3
    800031f4:	b771                	j	80003180 <readi+0x4c>
      brelse(bp);
    800031f6:	854a                	mv	a0,s2
    800031f8:	fffff097          	auipc	ra,0xfffff
    800031fc:	59e080e7          	jalr	1438(ra) # 80002796 <brelse>
      tot = -1;
    80003200:	59fd                	li	s3,-1
  }
  return tot;
    80003202:	0009851b          	sext.w	a0,s3
}
    80003206:	70a6                	ld	ra,104(sp)
    80003208:	7406                	ld	s0,96(sp)
    8000320a:	64e6                	ld	s1,88(sp)
    8000320c:	6946                	ld	s2,80(sp)
    8000320e:	69a6                	ld	s3,72(sp)
    80003210:	6a06                	ld	s4,64(sp)
    80003212:	7ae2                	ld	s5,56(sp)
    80003214:	7b42                	ld	s6,48(sp)
    80003216:	7ba2                	ld	s7,40(sp)
    80003218:	7c02                	ld	s8,32(sp)
    8000321a:	6ce2                	ld	s9,24(sp)
    8000321c:	6d42                	ld	s10,16(sp)
    8000321e:	6da2                	ld	s11,8(sp)
    80003220:	6165                	addi	sp,sp,112
    80003222:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003224:	89d6                	mv	s3,s5
    80003226:	bff1                	j	80003202 <readi+0xce>
    return 0;
    80003228:	4501                	li	a0,0
}
    8000322a:	8082                	ret

000000008000322c <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    8000322c:	457c                	lw	a5,76(a0)
    8000322e:	10d7e863          	bltu	a5,a3,8000333e <writei+0x112>
{
    80003232:	7159                	addi	sp,sp,-112
    80003234:	f486                	sd	ra,104(sp)
    80003236:	f0a2                	sd	s0,96(sp)
    80003238:	eca6                	sd	s1,88(sp)
    8000323a:	e8ca                	sd	s2,80(sp)
    8000323c:	e4ce                	sd	s3,72(sp)
    8000323e:	e0d2                	sd	s4,64(sp)
    80003240:	fc56                	sd	s5,56(sp)
    80003242:	f85a                	sd	s6,48(sp)
    80003244:	f45e                	sd	s7,40(sp)
    80003246:	f062                	sd	s8,32(sp)
    80003248:	ec66                	sd	s9,24(sp)
    8000324a:	e86a                	sd	s10,16(sp)
    8000324c:	e46e                	sd	s11,8(sp)
    8000324e:	1880                	addi	s0,sp,112
    80003250:	8aaa                	mv	s5,a0
    80003252:	8bae                	mv	s7,a1
    80003254:	8a32                	mv	s4,a2
    80003256:	8936                	mv	s2,a3
    80003258:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000325a:	00e687bb          	addw	a5,a3,a4
    8000325e:	0ed7e263          	bltu	a5,a3,80003342 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003262:	00043737          	lui	a4,0x43
    80003266:	0ef76063          	bltu	a4,a5,80003346 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000326a:	0c0b0863          	beqz	s6,8000333a <writei+0x10e>
    8000326e:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003270:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003274:	5c7d                	li	s8,-1
    80003276:	a091                	j	800032ba <writei+0x8e>
    80003278:	020d1d93          	slli	s11,s10,0x20
    8000327c:	020ddd93          	srli	s11,s11,0x20
    80003280:	05848513          	addi	a0,s1,88
    80003284:	86ee                	mv	a3,s11
    80003286:	8652                	mv	a2,s4
    80003288:	85de                	mv	a1,s7
    8000328a:	953a                	add	a0,a0,a4
    8000328c:	fffff097          	auipc	ra,0xfffff
    80003290:	980080e7          	jalr	-1664(ra) # 80001c0c <either_copyin>
    80003294:	07850263          	beq	a0,s8,800032f8 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003298:	8526                	mv	a0,s1
    8000329a:	00000097          	auipc	ra,0x0
    8000329e:	780080e7          	jalr	1920(ra) # 80003a1a <log_write>
    brelse(bp);
    800032a2:	8526                	mv	a0,s1
    800032a4:	fffff097          	auipc	ra,0xfffff
    800032a8:	4f2080e7          	jalr	1266(ra) # 80002796 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800032ac:	013d09bb          	addw	s3,s10,s3
    800032b0:	012d093b          	addw	s2,s10,s2
    800032b4:	9a6e                	add	s4,s4,s11
    800032b6:	0569f663          	bgeu	s3,s6,80003302 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    800032ba:	00a9559b          	srliw	a1,s2,0xa
    800032be:	8556                	mv	a0,s5
    800032c0:	fffff097          	auipc	ra,0xfffff
    800032c4:	7a0080e7          	jalr	1952(ra) # 80002a60 <bmap>
    800032c8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    800032cc:	c99d                	beqz	a1,80003302 <writei+0xd6>
    bp = bread(ip->dev, addr);
    800032ce:	000aa503          	lw	a0,0(s5)
    800032d2:	fffff097          	auipc	ra,0xfffff
    800032d6:	394080e7          	jalr	916(ra) # 80002666 <bread>
    800032da:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800032dc:	3ff97713          	andi	a4,s2,1023
    800032e0:	40ec87bb          	subw	a5,s9,a4
    800032e4:	413b06bb          	subw	a3,s6,s3
    800032e8:	8d3e                	mv	s10,a5
    800032ea:	2781                	sext.w	a5,a5
    800032ec:	0006861b          	sext.w	a2,a3
    800032f0:	f8f674e3          	bgeu	a2,a5,80003278 <writei+0x4c>
    800032f4:	8d36                	mv	s10,a3
    800032f6:	b749                	j	80003278 <writei+0x4c>
      brelse(bp);
    800032f8:	8526                	mv	a0,s1
    800032fa:	fffff097          	auipc	ra,0xfffff
    800032fe:	49c080e7          	jalr	1180(ra) # 80002796 <brelse>
  }

  if(off > ip->size)
    80003302:	04caa783          	lw	a5,76(s5)
    80003306:	0127f463          	bgeu	a5,s2,8000330e <writei+0xe2>
    ip->size = off;
    8000330a:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000330e:	8556                	mv	a0,s5
    80003310:	00000097          	auipc	ra,0x0
    80003314:	aa6080e7          	jalr	-1370(ra) # 80002db6 <iupdate>

  return tot;
    80003318:	0009851b          	sext.w	a0,s3
}
    8000331c:	70a6                	ld	ra,104(sp)
    8000331e:	7406                	ld	s0,96(sp)
    80003320:	64e6                	ld	s1,88(sp)
    80003322:	6946                	ld	s2,80(sp)
    80003324:	69a6                	ld	s3,72(sp)
    80003326:	6a06                	ld	s4,64(sp)
    80003328:	7ae2                	ld	s5,56(sp)
    8000332a:	7b42                	ld	s6,48(sp)
    8000332c:	7ba2                	ld	s7,40(sp)
    8000332e:	7c02                	ld	s8,32(sp)
    80003330:	6ce2                	ld	s9,24(sp)
    80003332:	6d42                	ld	s10,16(sp)
    80003334:	6da2                	ld	s11,8(sp)
    80003336:	6165                	addi	sp,sp,112
    80003338:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000333a:	89da                	mv	s3,s6
    8000333c:	bfc9                	j	8000330e <writei+0xe2>
    return -1;
    8000333e:	557d                	li	a0,-1
}
    80003340:	8082                	ret
    return -1;
    80003342:	557d                	li	a0,-1
    80003344:	bfe1                	j	8000331c <writei+0xf0>
    return -1;
    80003346:	557d                	li	a0,-1
    80003348:	bfd1                	j	8000331c <writei+0xf0>

000000008000334a <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000334a:	1141                	addi	sp,sp,-16
    8000334c:	e406                	sd	ra,8(sp)
    8000334e:	e022                	sd	s0,0(sp)
    80003350:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003352:	4639                	li	a2,14
    80003354:	ffffd097          	auipc	ra,0xffffd
    80003358:	120080e7          	jalr	288(ra) # 80000474 <strncmp>
}
    8000335c:	60a2                	ld	ra,8(sp)
    8000335e:	6402                	ld	s0,0(sp)
    80003360:	0141                	addi	sp,sp,16
    80003362:	8082                	ret

0000000080003364 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003364:	7139                	addi	sp,sp,-64
    80003366:	fc06                	sd	ra,56(sp)
    80003368:	f822                	sd	s0,48(sp)
    8000336a:	f426                	sd	s1,40(sp)
    8000336c:	f04a                	sd	s2,32(sp)
    8000336e:	ec4e                	sd	s3,24(sp)
    80003370:	e852                	sd	s4,16(sp)
    80003372:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003374:	04451703          	lh	a4,68(a0)
    80003378:	4785                	li	a5,1
    8000337a:	00f71a63          	bne	a4,a5,8000338e <dirlookup+0x2a>
    8000337e:	892a                	mv	s2,a0
    80003380:	89ae                	mv	s3,a1
    80003382:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003384:	457c                	lw	a5,76(a0)
    80003386:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003388:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000338a:	e79d                	bnez	a5,800033b8 <dirlookup+0x54>
    8000338c:	a8a5                	j	80003404 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000338e:	00005517          	auipc	a0,0x5
    80003392:	22250513          	addi	a0,a0,546 # 800085b0 <syscalls+0x1a0>
    80003396:	00003097          	auipc	ra,0x3
    8000339a:	bec080e7          	jalr	-1044(ra) # 80005f82 <panic>
      panic("dirlookup read");
    8000339e:	00005517          	auipc	a0,0x5
    800033a2:	22a50513          	addi	a0,a0,554 # 800085c8 <syscalls+0x1b8>
    800033a6:	00003097          	auipc	ra,0x3
    800033aa:	bdc080e7          	jalr	-1060(ra) # 80005f82 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800033ae:	24c1                	addiw	s1,s1,16
    800033b0:	04c92783          	lw	a5,76(s2)
    800033b4:	04f4f763          	bgeu	s1,a5,80003402 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800033b8:	4741                	li	a4,16
    800033ba:	86a6                	mv	a3,s1
    800033bc:	fc040613          	addi	a2,s0,-64
    800033c0:	4581                	li	a1,0
    800033c2:	854a                	mv	a0,s2
    800033c4:	00000097          	auipc	ra,0x0
    800033c8:	d70080e7          	jalr	-656(ra) # 80003134 <readi>
    800033cc:	47c1                	li	a5,16
    800033ce:	fcf518e3          	bne	a0,a5,8000339e <dirlookup+0x3a>
    if(de.inum == 0)
    800033d2:	fc045783          	lhu	a5,-64(s0)
    800033d6:	dfe1                	beqz	a5,800033ae <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800033d8:	fc240593          	addi	a1,s0,-62
    800033dc:	854e                	mv	a0,s3
    800033de:	00000097          	auipc	ra,0x0
    800033e2:	f6c080e7          	jalr	-148(ra) # 8000334a <namecmp>
    800033e6:	f561                	bnez	a0,800033ae <dirlookup+0x4a>
      if(poff)
    800033e8:	000a0463          	beqz	s4,800033f0 <dirlookup+0x8c>
        *poff = off;
    800033ec:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800033f0:	fc045583          	lhu	a1,-64(s0)
    800033f4:	00092503          	lw	a0,0(s2)
    800033f8:	fffff097          	auipc	ra,0xfffff
    800033fc:	750080e7          	jalr	1872(ra) # 80002b48 <iget>
    80003400:	a011                	j	80003404 <dirlookup+0xa0>
  return 0;
    80003402:	4501                	li	a0,0
}
    80003404:	70e2                	ld	ra,56(sp)
    80003406:	7442                	ld	s0,48(sp)
    80003408:	74a2                	ld	s1,40(sp)
    8000340a:	7902                	ld	s2,32(sp)
    8000340c:	69e2                	ld	s3,24(sp)
    8000340e:	6a42                	ld	s4,16(sp)
    80003410:	6121                	addi	sp,sp,64
    80003412:	8082                	ret

0000000080003414 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003414:	711d                	addi	sp,sp,-96
    80003416:	ec86                	sd	ra,88(sp)
    80003418:	e8a2                	sd	s0,80(sp)
    8000341a:	e4a6                	sd	s1,72(sp)
    8000341c:	e0ca                	sd	s2,64(sp)
    8000341e:	fc4e                	sd	s3,56(sp)
    80003420:	f852                	sd	s4,48(sp)
    80003422:	f456                	sd	s5,40(sp)
    80003424:	f05a                	sd	s6,32(sp)
    80003426:	ec5e                	sd	s7,24(sp)
    80003428:	e862                	sd	s8,16(sp)
    8000342a:	e466                	sd	s9,8(sp)
    8000342c:	1080                	addi	s0,sp,96
    8000342e:	84aa                	mv	s1,a0
    80003430:	8b2e                	mv	s6,a1
    80003432:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003434:	00054703          	lbu	a4,0(a0)
    80003438:	02f00793          	li	a5,47
    8000343c:	02f70363          	beq	a4,a5,80003462 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003440:	ffffe097          	auipc	ra,0xffffe
    80003444:	cca080e7          	jalr	-822(ra) # 8000110a <myproc>
    80003448:	15053503          	ld	a0,336(a0)
    8000344c:	00000097          	auipc	ra,0x0
    80003450:	9f6080e7          	jalr	-1546(ra) # 80002e42 <idup>
    80003454:	89aa                	mv	s3,a0
  while(*path == '/')
    80003456:	02f00913          	li	s2,47
  len = path - s;
    8000345a:	4b81                	li	s7,0
  if(len >= DIRSIZ)
    8000345c:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000345e:	4c05                	li	s8,1
    80003460:	a865                	j	80003518 <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    80003462:	4585                	li	a1,1
    80003464:	4505                	li	a0,1
    80003466:	fffff097          	auipc	ra,0xfffff
    8000346a:	6e2080e7          	jalr	1762(ra) # 80002b48 <iget>
    8000346e:	89aa                	mv	s3,a0
    80003470:	b7dd                	j	80003456 <namex+0x42>
      iunlockput(ip);
    80003472:	854e                	mv	a0,s3
    80003474:	00000097          	auipc	ra,0x0
    80003478:	c6e080e7          	jalr	-914(ra) # 800030e2 <iunlockput>
      return 0;
    8000347c:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000347e:	854e                	mv	a0,s3
    80003480:	60e6                	ld	ra,88(sp)
    80003482:	6446                	ld	s0,80(sp)
    80003484:	64a6                	ld	s1,72(sp)
    80003486:	6906                	ld	s2,64(sp)
    80003488:	79e2                	ld	s3,56(sp)
    8000348a:	7a42                	ld	s4,48(sp)
    8000348c:	7aa2                	ld	s5,40(sp)
    8000348e:	7b02                	ld	s6,32(sp)
    80003490:	6be2                	ld	s7,24(sp)
    80003492:	6c42                	ld	s8,16(sp)
    80003494:	6ca2                	ld	s9,8(sp)
    80003496:	6125                	addi	sp,sp,96
    80003498:	8082                	ret
      iunlock(ip);
    8000349a:	854e                	mv	a0,s3
    8000349c:	00000097          	auipc	ra,0x0
    800034a0:	aa6080e7          	jalr	-1370(ra) # 80002f42 <iunlock>
      return ip;
    800034a4:	bfe9                	j	8000347e <namex+0x6a>
      iunlockput(ip);
    800034a6:	854e                	mv	a0,s3
    800034a8:	00000097          	auipc	ra,0x0
    800034ac:	c3a080e7          	jalr	-966(ra) # 800030e2 <iunlockput>
      return 0;
    800034b0:	89d2                	mv	s3,s4
    800034b2:	b7f1                	j	8000347e <namex+0x6a>
  len = path - s;
    800034b4:	40b48633          	sub	a2,s1,a1
    800034b8:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800034bc:	094cd463          	bge	s9,s4,80003544 <namex+0x130>
    memmove(name, s, DIRSIZ);
    800034c0:	4639                	li	a2,14
    800034c2:	8556                	mv	a0,s5
    800034c4:	ffffd097          	auipc	ra,0xffffd
    800034c8:	f38080e7          	jalr	-200(ra) # 800003fc <memmove>
  while(*path == '/')
    800034cc:	0004c783          	lbu	a5,0(s1)
    800034d0:	01279763          	bne	a5,s2,800034de <namex+0xca>
    path++;
    800034d4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800034d6:	0004c783          	lbu	a5,0(s1)
    800034da:	ff278de3          	beq	a5,s2,800034d4 <namex+0xc0>
    ilock(ip);
    800034de:	854e                	mv	a0,s3
    800034e0:	00000097          	auipc	ra,0x0
    800034e4:	9a0080e7          	jalr	-1632(ra) # 80002e80 <ilock>
    if(ip->type != T_DIR){
    800034e8:	04499783          	lh	a5,68(s3)
    800034ec:	f98793e3          	bne	a5,s8,80003472 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    800034f0:	000b0563          	beqz	s6,800034fa <namex+0xe6>
    800034f4:	0004c783          	lbu	a5,0(s1)
    800034f8:	d3cd                	beqz	a5,8000349a <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    800034fa:	865e                	mv	a2,s7
    800034fc:	85d6                	mv	a1,s5
    800034fe:	854e                	mv	a0,s3
    80003500:	00000097          	auipc	ra,0x0
    80003504:	e64080e7          	jalr	-412(ra) # 80003364 <dirlookup>
    80003508:	8a2a                	mv	s4,a0
    8000350a:	dd51                	beqz	a0,800034a6 <namex+0x92>
    iunlockput(ip);
    8000350c:	854e                	mv	a0,s3
    8000350e:	00000097          	auipc	ra,0x0
    80003512:	bd4080e7          	jalr	-1068(ra) # 800030e2 <iunlockput>
    ip = next;
    80003516:	89d2                	mv	s3,s4
  while(*path == '/')
    80003518:	0004c783          	lbu	a5,0(s1)
    8000351c:	05279763          	bne	a5,s2,8000356a <namex+0x156>
    path++;
    80003520:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003522:	0004c783          	lbu	a5,0(s1)
    80003526:	ff278de3          	beq	a5,s2,80003520 <namex+0x10c>
  if(*path == 0)
    8000352a:	c79d                	beqz	a5,80003558 <namex+0x144>
    path++;
    8000352c:	85a6                	mv	a1,s1
  len = path - s;
    8000352e:	8a5e                	mv	s4,s7
    80003530:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003532:	01278963          	beq	a5,s2,80003544 <namex+0x130>
    80003536:	dfbd                	beqz	a5,800034b4 <namex+0xa0>
    path++;
    80003538:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    8000353a:	0004c783          	lbu	a5,0(s1)
    8000353e:	ff279ce3          	bne	a5,s2,80003536 <namex+0x122>
    80003542:	bf8d                	j	800034b4 <namex+0xa0>
    memmove(name, s, len);
    80003544:	2601                	sext.w	a2,a2
    80003546:	8556                	mv	a0,s5
    80003548:	ffffd097          	auipc	ra,0xffffd
    8000354c:	eb4080e7          	jalr	-332(ra) # 800003fc <memmove>
    name[len] = 0;
    80003550:	9a56                	add	s4,s4,s5
    80003552:	000a0023          	sb	zero,0(s4)
    80003556:	bf9d                	j	800034cc <namex+0xb8>
  if(nameiparent){
    80003558:	f20b03e3          	beqz	s6,8000347e <namex+0x6a>
    iput(ip);
    8000355c:	854e                	mv	a0,s3
    8000355e:	00000097          	auipc	ra,0x0
    80003562:	adc080e7          	jalr	-1316(ra) # 8000303a <iput>
    return 0;
    80003566:	4981                	li	s3,0
    80003568:	bf19                	j	8000347e <namex+0x6a>
  if(*path == 0)
    8000356a:	d7fd                	beqz	a5,80003558 <namex+0x144>
  while(*path != '/' && *path != 0)
    8000356c:	0004c783          	lbu	a5,0(s1)
    80003570:	85a6                	mv	a1,s1
    80003572:	b7d1                	j	80003536 <namex+0x122>

0000000080003574 <dirlink>:
{
    80003574:	7139                	addi	sp,sp,-64
    80003576:	fc06                	sd	ra,56(sp)
    80003578:	f822                	sd	s0,48(sp)
    8000357a:	f426                	sd	s1,40(sp)
    8000357c:	f04a                	sd	s2,32(sp)
    8000357e:	ec4e                	sd	s3,24(sp)
    80003580:	e852                	sd	s4,16(sp)
    80003582:	0080                	addi	s0,sp,64
    80003584:	892a                	mv	s2,a0
    80003586:	8a2e                	mv	s4,a1
    80003588:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000358a:	4601                	li	a2,0
    8000358c:	00000097          	auipc	ra,0x0
    80003590:	dd8080e7          	jalr	-552(ra) # 80003364 <dirlookup>
    80003594:	e93d                	bnez	a0,8000360a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003596:	04c92483          	lw	s1,76(s2)
    8000359a:	c49d                	beqz	s1,800035c8 <dirlink+0x54>
    8000359c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000359e:	4741                	li	a4,16
    800035a0:	86a6                	mv	a3,s1
    800035a2:	fc040613          	addi	a2,s0,-64
    800035a6:	4581                	li	a1,0
    800035a8:	854a                	mv	a0,s2
    800035aa:	00000097          	auipc	ra,0x0
    800035ae:	b8a080e7          	jalr	-1142(ra) # 80003134 <readi>
    800035b2:	47c1                	li	a5,16
    800035b4:	06f51163          	bne	a0,a5,80003616 <dirlink+0xa2>
    if(de.inum == 0)
    800035b8:	fc045783          	lhu	a5,-64(s0)
    800035bc:	c791                	beqz	a5,800035c8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800035be:	24c1                	addiw	s1,s1,16
    800035c0:	04c92783          	lw	a5,76(s2)
    800035c4:	fcf4ede3          	bltu	s1,a5,8000359e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800035c8:	4639                	li	a2,14
    800035ca:	85d2                	mv	a1,s4
    800035cc:	fc240513          	addi	a0,s0,-62
    800035d0:	ffffd097          	auipc	ra,0xffffd
    800035d4:	ee0080e7          	jalr	-288(ra) # 800004b0 <strncpy>
  de.inum = inum;
    800035d8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800035dc:	4741                	li	a4,16
    800035de:	86a6                	mv	a3,s1
    800035e0:	fc040613          	addi	a2,s0,-64
    800035e4:	4581                	li	a1,0
    800035e6:	854a                	mv	a0,s2
    800035e8:	00000097          	auipc	ra,0x0
    800035ec:	c44080e7          	jalr	-956(ra) # 8000322c <writei>
    800035f0:	1541                	addi	a0,a0,-16
    800035f2:	00a03533          	snez	a0,a0
    800035f6:	40a00533          	neg	a0,a0
}
    800035fa:	70e2                	ld	ra,56(sp)
    800035fc:	7442                	ld	s0,48(sp)
    800035fe:	74a2                	ld	s1,40(sp)
    80003600:	7902                	ld	s2,32(sp)
    80003602:	69e2                	ld	s3,24(sp)
    80003604:	6a42                	ld	s4,16(sp)
    80003606:	6121                	addi	sp,sp,64
    80003608:	8082                	ret
    iput(ip);
    8000360a:	00000097          	auipc	ra,0x0
    8000360e:	a30080e7          	jalr	-1488(ra) # 8000303a <iput>
    return -1;
    80003612:	557d                	li	a0,-1
    80003614:	b7dd                	j	800035fa <dirlink+0x86>
      panic("dirlink read");
    80003616:	00005517          	auipc	a0,0x5
    8000361a:	fc250513          	addi	a0,a0,-62 # 800085d8 <syscalls+0x1c8>
    8000361e:	00003097          	auipc	ra,0x3
    80003622:	964080e7          	jalr	-1692(ra) # 80005f82 <panic>

0000000080003626 <namei>:

struct inode*
namei(char *path)
{
    80003626:	1101                	addi	sp,sp,-32
    80003628:	ec06                	sd	ra,24(sp)
    8000362a:	e822                	sd	s0,16(sp)
    8000362c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000362e:	fe040613          	addi	a2,s0,-32
    80003632:	4581                	li	a1,0
    80003634:	00000097          	auipc	ra,0x0
    80003638:	de0080e7          	jalr	-544(ra) # 80003414 <namex>
}
    8000363c:	60e2                	ld	ra,24(sp)
    8000363e:	6442                	ld	s0,16(sp)
    80003640:	6105                	addi	sp,sp,32
    80003642:	8082                	ret

0000000080003644 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003644:	1141                	addi	sp,sp,-16
    80003646:	e406                	sd	ra,8(sp)
    80003648:	e022                	sd	s0,0(sp)
    8000364a:	0800                	addi	s0,sp,16
    8000364c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000364e:	4585                	li	a1,1
    80003650:	00000097          	auipc	ra,0x0
    80003654:	dc4080e7          	jalr	-572(ra) # 80003414 <namex>
}
    80003658:	60a2                	ld	ra,8(sp)
    8000365a:	6402                	ld	s0,0(sp)
    8000365c:	0141                	addi	sp,sp,16
    8000365e:	8082                	ret

0000000080003660 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003660:	1101                	addi	sp,sp,-32
    80003662:	ec06                	sd	ra,24(sp)
    80003664:	e822                	sd	s0,16(sp)
    80003666:	e426                	sd	s1,8(sp)
    80003668:	e04a                	sd	s2,0(sp)
    8000366a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000366c:	00235917          	auipc	s2,0x235
    80003670:	2bc90913          	addi	s2,s2,700 # 80238928 <log>
    80003674:	01892583          	lw	a1,24(s2)
    80003678:	02892503          	lw	a0,40(s2)
    8000367c:	fffff097          	auipc	ra,0xfffff
    80003680:	fea080e7          	jalr	-22(ra) # 80002666 <bread>
    80003684:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003686:	02c92683          	lw	a3,44(s2)
    8000368a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000368c:	02d05763          	blez	a3,800036ba <write_head+0x5a>
    80003690:	00235797          	auipc	a5,0x235
    80003694:	2c878793          	addi	a5,a5,712 # 80238958 <log+0x30>
    80003698:	05c50713          	addi	a4,a0,92
    8000369c:	36fd                	addiw	a3,a3,-1
    8000369e:	1682                	slli	a3,a3,0x20
    800036a0:	9281                	srli	a3,a3,0x20
    800036a2:	068a                	slli	a3,a3,0x2
    800036a4:	00235617          	auipc	a2,0x235
    800036a8:	2b860613          	addi	a2,a2,696 # 8023895c <log+0x34>
    800036ac:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800036ae:	4390                	lw	a2,0(a5)
    800036b0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800036b2:	0791                	addi	a5,a5,4
    800036b4:	0711                	addi	a4,a4,4
    800036b6:	fed79ce3          	bne	a5,a3,800036ae <write_head+0x4e>
  }
  bwrite(buf);
    800036ba:	8526                	mv	a0,s1
    800036bc:	fffff097          	auipc	ra,0xfffff
    800036c0:	09c080e7          	jalr	156(ra) # 80002758 <bwrite>
  brelse(buf);
    800036c4:	8526                	mv	a0,s1
    800036c6:	fffff097          	auipc	ra,0xfffff
    800036ca:	0d0080e7          	jalr	208(ra) # 80002796 <brelse>
}
    800036ce:	60e2                	ld	ra,24(sp)
    800036d0:	6442                	ld	s0,16(sp)
    800036d2:	64a2                	ld	s1,8(sp)
    800036d4:	6902                	ld	s2,0(sp)
    800036d6:	6105                	addi	sp,sp,32
    800036d8:	8082                	ret

00000000800036da <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800036da:	00235797          	auipc	a5,0x235
    800036de:	27a7a783          	lw	a5,634(a5) # 80238954 <log+0x2c>
    800036e2:	0af05d63          	blez	a5,8000379c <install_trans+0xc2>
{
    800036e6:	7139                	addi	sp,sp,-64
    800036e8:	fc06                	sd	ra,56(sp)
    800036ea:	f822                	sd	s0,48(sp)
    800036ec:	f426                	sd	s1,40(sp)
    800036ee:	f04a                	sd	s2,32(sp)
    800036f0:	ec4e                	sd	s3,24(sp)
    800036f2:	e852                	sd	s4,16(sp)
    800036f4:	e456                	sd	s5,8(sp)
    800036f6:	e05a                	sd	s6,0(sp)
    800036f8:	0080                	addi	s0,sp,64
    800036fa:	8b2a                	mv	s6,a0
    800036fc:	00235a97          	auipc	s5,0x235
    80003700:	25ca8a93          	addi	s5,s5,604 # 80238958 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003704:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003706:	00235997          	auipc	s3,0x235
    8000370a:	22298993          	addi	s3,s3,546 # 80238928 <log>
    8000370e:	a035                	j	8000373a <install_trans+0x60>
      bunpin(dbuf);
    80003710:	8526                	mv	a0,s1
    80003712:	fffff097          	auipc	ra,0xfffff
    80003716:	15e080e7          	jalr	350(ra) # 80002870 <bunpin>
    brelse(lbuf);
    8000371a:	854a                	mv	a0,s2
    8000371c:	fffff097          	auipc	ra,0xfffff
    80003720:	07a080e7          	jalr	122(ra) # 80002796 <brelse>
    brelse(dbuf);
    80003724:	8526                	mv	a0,s1
    80003726:	fffff097          	auipc	ra,0xfffff
    8000372a:	070080e7          	jalr	112(ra) # 80002796 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000372e:	2a05                	addiw	s4,s4,1
    80003730:	0a91                	addi	s5,s5,4
    80003732:	02c9a783          	lw	a5,44(s3)
    80003736:	04fa5963          	bge	s4,a5,80003788 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000373a:	0189a583          	lw	a1,24(s3)
    8000373e:	014585bb          	addw	a1,a1,s4
    80003742:	2585                	addiw	a1,a1,1
    80003744:	0289a503          	lw	a0,40(s3)
    80003748:	fffff097          	auipc	ra,0xfffff
    8000374c:	f1e080e7          	jalr	-226(ra) # 80002666 <bread>
    80003750:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003752:	000aa583          	lw	a1,0(s5)
    80003756:	0289a503          	lw	a0,40(s3)
    8000375a:	fffff097          	auipc	ra,0xfffff
    8000375e:	f0c080e7          	jalr	-244(ra) # 80002666 <bread>
    80003762:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003764:	40000613          	li	a2,1024
    80003768:	05890593          	addi	a1,s2,88
    8000376c:	05850513          	addi	a0,a0,88
    80003770:	ffffd097          	auipc	ra,0xffffd
    80003774:	c8c080e7          	jalr	-884(ra) # 800003fc <memmove>
    bwrite(dbuf);  // write dst to disk
    80003778:	8526                	mv	a0,s1
    8000377a:	fffff097          	auipc	ra,0xfffff
    8000377e:	fde080e7          	jalr	-34(ra) # 80002758 <bwrite>
    if(recovering == 0)
    80003782:	f80b1ce3          	bnez	s6,8000371a <install_trans+0x40>
    80003786:	b769                	j	80003710 <install_trans+0x36>
}
    80003788:	70e2                	ld	ra,56(sp)
    8000378a:	7442                	ld	s0,48(sp)
    8000378c:	74a2                	ld	s1,40(sp)
    8000378e:	7902                	ld	s2,32(sp)
    80003790:	69e2                	ld	s3,24(sp)
    80003792:	6a42                	ld	s4,16(sp)
    80003794:	6aa2                	ld	s5,8(sp)
    80003796:	6b02                	ld	s6,0(sp)
    80003798:	6121                	addi	sp,sp,64
    8000379a:	8082                	ret
    8000379c:	8082                	ret

000000008000379e <initlog>:
{
    8000379e:	7179                	addi	sp,sp,-48
    800037a0:	f406                	sd	ra,40(sp)
    800037a2:	f022                	sd	s0,32(sp)
    800037a4:	ec26                	sd	s1,24(sp)
    800037a6:	e84a                	sd	s2,16(sp)
    800037a8:	e44e                	sd	s3,8(sp)
    800037aa:	1800                	addi	s0,sp,48
    800037ac:	892a                	mv	s2,a0
    800037ae:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800037b0:	00235497          	auipc	s1,0x235
    800037b4:	17848493          	addi	s1,s1,376 # 80238928 <log>
    800037b8:	00005597          	auipc	a1,0x5
    800037bc:	e3058593          	addi	a1,a1,-464 # 800085e8 <syscalls+0x1d8>
    800037c0:	8526                	mv	a0,s1
    800037c2:	00003097          	auipc	ra,0x3
    800037c6:	c7a080e7          	jalr	-902(ra) # 8000643c <initlock>
  log.start = sb->logstart;
    800037ca:	0149a583          	lw	a1,20(s3)
    800037ce:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800037d0:	0109a783          	lw	a5,16(s3)
    800037d4:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800037d6:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800037da:	854a                	mv	a0,s2
    800037dc:	fffff097          	auipc	ra,0xfffff
    800037e0:	e8a080e7          	jalr	-374(ra) # 80002666 <bread>
  log.lh.n = lh->n;
    800037e4:	4d3c                	lw	a5,88(a0)
    800037e6:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800037e8:	02f05563          	blez	a5,80003812 <initlog+0x74>
    800037ec:	05c50713          	addi	a4,a0,92
    800037f0:	00235697          	auipc	a3,0x235
    800037f4:	16868693          	addi	a3,a3,360 # 80238958 <log+0x30>
    800037f8:	37fd                	addiw	a5,a5,-1
    800037fa:	1782                	slli	a5,a5,0x20
    800037fc:	9381                	srli	a5,a5,0x20
    800037fe:	078a                	slli	a5,a5,0x2
    80003800:	06050613          	addi	a2,a0,96
    80003804:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003806:	4310                	lw	a2,0(a4)
    80003808:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    8000380a:	0711                	addi	a4,a4,4
    8000380c:	0691                	addi	a3,a3,4
    8000380e:	fef71ce3          	bne	a4,a5,80003806 <initlog+0x68>
  brelse(buf);
    80003812:	fffff097          	auipc	ra,0xfffff
    80003816:	f84080e7          	jalr	-124(ra) # 80002796 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000381a:	4505                	li	a0,1
    8000381c:	00000097          	auipc	ra,0x0
    80003820:	ebe080e7          	jalr	-322(ra) # 800036da <install_trans>
  log.lh.n = 0;
    80003824:	00235797          	auipc	a5,0x235
    80003828:	1207a823          	sw	zero,304(a5) # 80238954 <log+0x2c>
  write_head(); // clear the log
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	e34080e7          	jalr	-460(ra) # 80003660 <write_head>
}
    80003834:	70a2                	ld	ra,40(sp)
    80003836:	7402                	ld	s0,32(sp)
    80003838:	64e2                	ld	s1,24(sp)
    8000383a:	6942                	ld	s2,16(sp)
    8000383c:	69a2                	ld	s3,8(sp)
    8000383e:	6145                	addi	sp,sp,48
    80003840:	8082                	ret

0000000080003842 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003842:	1101                	addi	sp,sp,-32
    80003844:	ec06                	sd	ra,24(sp)
    80003846:	e822                	sd	s0,16(sp)
    80003848:	e426                	sd	s1,8(sp)
    8000384a:	e04a                	sd	s2,0(sp)
    8000384c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000384e:	00235517          	auipc	a0,0x235
    80003852:	0da50513          	addi	a0,a0,218 # 80238928 <log>
    80003856:	00003097          	auipc	ra,0x3
    8000385a:	c76080e7          	jalr	-906(ra) # 800064cc <acquire>
  while(1){
    if(log.committing){
    8000385e:	00235497          	auipc	s1,0x235
    80003862:	0ca48493          	addi	s1,s1,202 # 80238928 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003866:	4979                	li	s2,30
    80003868:	a039                	j	80003876 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000386a:	85a6                	mv	a1,s1
    8000386c:	8526                	mv	a0,s1
    8000386e:	ffffe097          	auipc	ra,0xffffe
    80003872:	f40080e7          	jalr	-192(ra) # 800017ae <sleep>
    if(log.committing){
    80003876:	50dc                	lw	a5,36(s1)
    80003878:	fbed                	bnez	a5,8000386a <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000387a:	509c                	lw	a5,32(s1)
    8000387c:	0017871b          	addiw	a4,a5,1
    80003880:	0007069b          	sext.w	a3,a4
    80003884:	0027179b          	slliw	a5,a4,0x2
    80003888:	9fb9                	addw	a5,a5,a4
    8000388a:	0017979b          	slliw	a5,a5,0x1
    8000388e:	54d8                	lw	a4,44(s1)
    80003890:	9fb9                	addw	a5,a5,a4
    80003892:	00f95963          	bge	s2,a5,800038a4 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003896:	85a6                	mv	a1,s1
    80003898:	8526                	mv	a0,s1
    8000389a:	ffffe097          	auipc	ra,0xffffe
    8000389e:	f14080e7          	jalr	-236(ra) # 800017ae <sleep>
    800038a2:	bfd1                	j	80003876 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800038a4:	00235517          	auipc	a0,0x235
    800038a8:	08450513          	addi	a0,a0,132 # 80238928 <log>
    800038ac:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800038ae:	00003097          	auipc	ra,0x3
    800038b2:	cd2080e7          	jalr	-814(ra) # 80006580 <release>
      break;
    }
  }
}
    800038b6:	60e2                	ld	ra,24(sp)
    800038b8:	6442                	ld	s0,16(sp)
    800038ba:	64a2                	ld	s1,8(sp)
    800038bc:	6902                	ld	s2,0(sp)
    800038be:	6105                	addi	sp,sp,32
    800038c0:	8082                	ret

00000000800038c2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800038c2:	7139                	addi	sp,sp,-64
    800038c4:	fc06                	sd	ra,56(sp)
    800038c6:	f822                	sd	s0,48(sp)
    800038c8:	f426                	sd	s1,40(sp)
    800038ca:	f04a                	sd	s2,32(sp)
    800038cc:	ec4e                	sd	s3,24(sp)
    800038ce:	e852                	sd	s4,16(sp)
    800038d0:	e456                	sd	s5,8(sp)
    800038d2:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800038d4:	00235497          	auipc	s1,0x235
    800038d8:	05448493          	addi	s1,s1,84 # 80238928 <log>
    800038dc:	8526                	mv	a0,s1
    800038de:	00003097          	auipc	ra,0x3
    800038e2:	bee080e7          	jalr	-1042(ra) # 800064cc <acquire>
  log.outstanding -= 1;
    800038e6:	509c                	lw	a5,32(s1)
    800038e8:	37fd                	addiw	a5,a5,-1
    800038ea:	0007891b          	sext.w	s2,a5
    800038ee:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800038f0:	50dc                	lw	a5,36(s1)
    800038f2:	efb9                	bnez	a5,80003950 <end_op+0x8e>
    panic("log.committing");
  if(log.outstanding == 0){
    800038f4:	06091663          	bnez	s2,80003960 <end_op+0x9e>
    do_commit = 1;
    log.committing = 1;
    800038f8:	00235497          	auipc	s1,0x235
    800038fc:	03048493          	addi	s1,s1,48 # 80238928 <log>
    80003900:	4785                	li	a5,1
    80003902:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003904:	8526                	mv	a0,s1
    80003906:	00003097          	auipc	ra,0x3
    8000390a:	c7a080e7          	jalr	-902(ra) # 80006580 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000390e:	54dc                	lw	a5,44(s1)
    80003910:	06f04763          	bgtz	a5,8000397e <end_op+0xbc>
    acquire(&log.lock);
    80003914:	00235497          	auipc	s1,0x235
    80003918:	01448493          	addi	s1,s1,20 # 80238928 <log>
    8000391c:	8526                	mv	a0,s1
    8000391e:	00003097          	auipc	ra,0x3
    80003922:	bae080e7          	jalr	-1106(ra) # 800064cc <acquire>
    log.committing = 0;
    80003926:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000392a:	8526                	mv	a0,s1
    8000392c:	ffffe097          	auipc	ra,0xffffe
    80003930:	ee6080e7          	jalr	-282(ra) # 80001812 <wakeup>
    release(&log.lock);
    80003934:	8526                	mv	a0,s1
    80003936:	00003097          	auipc	ra,0x3
    8000393a:	c4a080e7          	jalr	-950(ra) # 80006580 <release>
}
    8000393e:	70e2                	ld	ra,56(sp)
    80003940:	7442                	ld	s0,48(sp)
    80003942:	74a2                	ld	s1,40(sp)
    80003944:	7902                	ld	s2,32(sp)
    80003946:	69e2                	ld	s3,24(sp)
    80003948:	6a42                	ld	s4,16(sp)
    8000394a:	6aa2                	ld	s5,8(sp)
    8000394c:	6121                	addi	sp,sp,64
    8000394e:	8082                	ret
    panic("log.committing");
    80003950:	00005517          	auipc	a0,0x5
    80003954:	ca050513          	addi	a0,a0,-864 # 800085f0 <syscalls+0x1e0>
    80003958:	00002097          	auipc	ra,0x2
    8000395c:	62a080e7          	jalr	1578(ra) # 80005f82 <panic>
    wakeup(&log);
    80003960:	00235497          	auipc	s1,0x235
    80003964:	fc848493          	addi	s1,s1,-56 # 80238928 <log>
    80003968:	8526                	mv	a0,s1
    8000396a:	ffffe097          	auipc	ra,0xffffe
    8000396e:	ea8080e7          	jalr	-344(ra) # 80001812 <wakeup>
  release(&log.lock);
    80003972:	8526                	mv	a0,s1
    80003974:	00003097          	auipc	ra,0x3
    80003978:	c0c080e7          	jalr	-1012(ra) # 80006580 <release>
  if(do_commit){
    8000397c:	b7c9                	j	8000393e <end_op+0x7c>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000397e:	00235a97          	auipc	s5,0x235
    80003982:	fdaa8a93          	addi	s5,s5,-38 # 80238958 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003986:	00235a17          	auipc	s4,0x235
    8000398a:	fa2a0a13          	addi	s4,s4,-94 # 80238928 <log>
    8000398e:	018a2583          	lw	a1,24(s4)
    80003992:	012585bb          	addw	a1,a1,s2
    80003996:	2585                	addiw	a1,a1,1
    80003998:	028a2503          	lw	a0,40(s4)
    8000399c:	fffff097          	auipc	ra,0xfffff
    800039a0:	cca080e7          	jalr	-822(ra) # 80002666 <bread>
    800039a4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800039a6:	000aa583          	lw	a1,0(s5)
    800039aa:	028a2503          	lw	a0,40(s4)
    800039ae:	fffff097          	auipc	ra,0xfffff
    800039b2:	cb8080e7          	jalr	-840(ra) # 80002666 <bread>
    800039b6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800039b8:	40000613          	li	a2,1024
    800039bc:	05850593          	addi	a1,a0,88
    800039c0:	05848513          	addi	a0,s1,88
    800039c4:	ffffd097          	auipc	ra,0xffffd
    800039c8:	a38080e7          	jalr	-1480(ra) # 800003fc <memmove>
    bwrite(to);  // write the log
    800039cc:	8526                	mv	a0,s1
    800039ce:	fffff097          	auipc	ra,0xfffff
    800039d2:	d8a080e7          	jalr	-630(ra) # 80002758 <bwrite>
    brelse(from);
    800039d6:	854e                	mv	a0,s3
    800039d8:	fffff097          	auipc	ra,0xfffff
    800039dc:	dbe080e7          	jalr	-578(ra) # 80002796 <brelse>
    brelse(to);
    800039e0:	8526                	mv	a0,s1
    800039e2:	fffff097          	auipc	ra,0xfffff
    800039e6:	db4080e7          	jalr	-588(ra) # 80002796 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800039ea:	2905                	addiw	s2,s2,1
    800039ec:	0a91                	addi	s5,s5,4
    800039ee:	02ca2783          	lw	a5,44(s4)
    800039f2:	f8f94ee3          	blt	s2,a5,8000398e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800039f6:	00000097          	auipc	ra,0x0
    800039fa:	c6a080e7          	jalr	-918(ra) # 80003660 <write_head>
    install_trans(0); // Now install writes to home locations
    800039fe:	4501                	li	a0,0
    80003a00:	00000097          	auipc	ra,0x0
    80003a04:	cda080e7          	jalr	-806(ra) # 800036da <install_trans>
    log.lh.n = 0;
    80003a08:	00235797          	auipc	a5,0x235
    80003a0c:	f407a623          	sw	zero,-180(a5) # 80238954 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003a10:	00000097          	auipc	ra,0x0
    80003a14:	c50080e7          	jalr	-944(ra) # 80003660 <write_head>
    80003a18:	bdf5                	j	80003914 <end_op+0x52>

0000000080003a1a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003a1a:	1101                	addi	sp,sp,-32
    80003a1c:	ec06                	sd	ra,24(sp)
    80003a1e:	e822                	sd	s0,16(sp)
    80003a20:	e426                	sd	s1,8(sp)
    80003a22:	e04a                	sd	s2,0(sp)
    80003a24:	1000                	addi	s0,sp,32
    80003a26:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003a28:	00235917          	auipc	s2,0x235
    80003a2c:	f0090913          	addi	s2,s2,-256 # 80238928 <log>
    80003a30:	854a                	mv	a0,s2
    80003a32:	00003097          	auipc	ra,0x3
    80003a36:	a9a080e7          	jalr	-1382(ra) # 800064cc <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003a3a:	02c92603          	lw	a2,44(s2)
    80003a3e:	47f5                	li	a5,29
    80003a40:	06c7c563          	blt	a5,a2,80003aaa <log_write+0x90>
    80003a44:	00235797          	auipc	a5,0x235
    80003a48:	f007a783          	lw	a5,-256(a5) # 80238944 <log+0x1c>
    80003a4c:	37fd                	addiw	a5,a5,-1
    80003a4e:	04f65e63          	bge	a2,a5,80003aaa <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003a52:	00235797          	auipc	a5,0x235
    80003a56:	ef67a783          	lw	a5,-266(a5) # 80238948 <log+0x20>
    80003a5a:	06f05063          	blez	a5,80003aba <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003a5e:	4781                	li	a5,0
    80003a60:	06c05563          	blez	a2,80003aca <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003a64:	44cc                	lw	a1,12(s1)
    80003a66:	00235717          	auipc	a4,0x235
    80003a6a:	ef270713          	addi	a4,a4,-270 # 80238958 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003a6e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003a70:	4314                	lw	a3,0(a4)
    80003a72:	04b68c63          	beq	a3,a1,80003aca <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80003a76:	2785                	addiw	a5,a5,1
    80003a78:	0711                	addi	a4,a4,4
    80003a7a:	fef61be3          	bne	a2,a5,80003a70 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003a7e:	0621                	addi	a2,a2,8
    80003a80:	060a                	slli	a2,a2,0x2
    80003a82:	00235797          	auipc	a5,0x235
    80003a86:	ea678793          	addi	a5,a5,-346 # 80238928 <log>
    80003a8a:	963e                	add	a2,a2,a5
    80003a8c:	44dc                	lw	a5,12(s1)
    80003a8e:	ca1c                	sw	a5,16(a2)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003a90:	8526                	mv	a0,s1
    80003a92:	fffff097          	auipc	ra,0xfffff
    80003a96:	da2080e7          	jalr	-606(ra) # 80002834 <bpin>
    log.lh.n++;
    80003a9a:	00235717          	auipc	a4,0x235
    80003a9e:	e8e70713          	addi	a4,a4,-370 # 80238928 <log>
    80003aa2:	575c                	lw	a5,44(a4)
    80003aa4:	2785                	addiw	a5,a5,1
    80003aa6:	d75c                	sw	a5,44(a4)
    80003aa8:	a835                	j	80003ae4 <log_write+0xca>
    panic("too big a transaction");
    80003aaa:	00005517          	auipc	a0,0x5
    80003aae:	b5650513          	addi	a0,a0,-1194 # 80008600 <syscalls+0x1f0>
    80003ab2:	00002097          	auipc	ra,0x2
    80003ab6:	4d0080e7          	jalr	1232(ra) # 80005f82 <panic>
    panic("log_write outside of trans");
    80003aba:	00005517          	auipc	a0,0x5
    80003abe:	b5e50513          	addi	a0,a0,-1186 # 80008618 <syscalls+0x208>
    80003ac2:	00002097          	auipc	ra,0x2
    80003ac6:	4c0080e7          	jalr	1216(ra) # 80005f82 <panic>
  log.lh.block[i] = b->blockno;
    80003aca:	00878713          	addi	a4,a5,8
    80003ace:	00271693          	slli	a3,a4,0x2
    80003ad2:	00235717          	auipc	a4,0x235
    80003ad6:	e5670713          	addi	a4,a4,-426 # 80238928 <log>
    80003ada:	9736                	add	a4,a4,a3
    80003adc:	44d4                	lw	a3,12(s1)
    80003ade:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ae0:	faf608e3          	beq	a2,a5,80003a90 <log_write+0x76>
  }
  release(&log.lock);
    80003ae4:	00235517          	auipc	a0,0x235
    80003ae8:	e4450513          	addi	a0,a0,-444 # 80238928 <log>
    80003aec:	00003097          	auipc	ra,0x3
    80003af0:	a94080e7          	jalr	-1388(ra) # 80006580 <release>
}
    80003af4:	60e2                	ld	ra,24(sp)
    80003af6:	6442                	ld	s0,16(sp)
    80003af8:	64a2                	ld	s1,8(sp)
    80003afa:	6902                	ld	s2,0(sp)
    80003afc:	6105                	addi	sp,sp,32
    80003afe:	8082                	ret

0000000080003b00 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003b00:	1101                	addi	sp,sp,-32
    80003b02:	ec06                	sd	ra,24(sp)
    80003b04:	e822                	sd	s0,16(sp)
    80003b06:	e426                	sd	s1,8(sp)
    80003b08:	e04a                	sd	s2,0(sp)
    80003b0a:	1000                	addi	s0,sp,32
    80003b0c:	84aa                	mv	s1,a0
    80003b0e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003b10:	00005597          	auipc	a1,0x5
    80003b14:	b2858593          	addi	a1,a1,-1240 # 80008638 <syscalls+0x228>
    80003b18:	0521                	addi	a0,a0,8
    80003b1a:	00003097          	auipc	ra,0x3
    80003b1e:	922080e7          	jalr	-1758(ra) # 8000643c <initlock>
  lk->name = name;
    80003b22:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003b26:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003b2a:	0204a423          	sw	zero,40(s1)
}
    80003b2e:	60e2                	ld	ra,24(sp)
    80003b30:	6442                	ld	s0,16(sp)
    80003b32:	64a2                	ld	s1,8(sp)
    80003b34:	6902                	ld	s2,0(sp)
    80003b36:	6105                	addi	sp,sp,32
    80003b38:	8082                	ret

0000000080003b3a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003b3a:	1101                	addi	sp,sp,-32
    80003b3c:	ec06                	sd	ra,24(sp)
    80003b3e:	e822                	sd	s0,16(sp)
    80003b40:	e426                	sd	s1,8(sp)
    80003b42:	e04a                	sd	s2,0(sp)
    80003b44:	1000                	addi	s0,sp,32
    80003b46:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003b48:	00850913          	addi	s2,a0,8
    80003b4c:	854a                	mv	a0,s2
    80003b4e:	00003097          	auipc	ra,0x3
    80003b52:	97e080e7          	jalr	-1666(ra) # 800064cc <acquire>
  while (lk->locked) {
    80003b56:	409c                	lw	a5,0(s1)
    80003b58:	cb89                	beqz	a5,80003b6a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80003b5a:	85ca                	mv	a1,s2
    80003b5c:	8526                	mv	a0,s1
    80003b5e:	ffffe097          	auipc	ra,0xffffe
    80003b62:	c50080e7          	jalr	-944(ra) # 800017ae <sleep>
  while (lk->locked) {
    80003b66:	409c                	lw	a5,0(s1)
    80003b68:	fbed                	bnez	a5,80003b5a <acquiresleep+0x20>
  }
  lk->locked = 1;
    80003b6a:	4785                	li	a5,1
    80003b6c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003b6e:	ffffd097          	auipc	ra,0xffffd
    80003b72:	59c080e7          	jalr	1436(ra) # 8000110a <myproc>
    80003b76:	591c                	lw	a5,48(a0)
    80003b78:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003b7a:	854a                	mv	a0,s2
    80003b7c:	00003097          	auipc	ra,0x3
    80003b80:	a04080e7          	jalr	-1532(ra) # 80006580 <release>
}
    80003b84:	60e2                	ld	ra,24(sp)
    80003b86:	6442                	ld	s0,16(sp)
    80003b88:	64a2                	ld	s1,8(sp)
    80003b8a:	6902                	ld	s2,0(sp)
    80003b8c:	6105                	addi	sp,sp,32
    80003b8e:	8082                	ret

0000000080003b90 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003b90:	1101                	addi	sp,sp,-32
    80003b92:	ec06                	sd	ra,24(sp)
    80003b94:	e822                	sd	s0,16(sp)
    80003b96:	e426                	sd	s1,8(sp)
    80003b98:	e04a                	sd	s2,0(sp)
    80003b9a:	1000                	addi	s0,sp,32
    80003b9c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003b9e:	00850913          	addi	s2,a0,8
    80003ba2:	854a                	mv	a0,s2
    80003ba4:	00003097          	auipc	ra,0x3
    80003ba8:	928080e7          	jalr	-1752(ra) # 800064cc <acquire>
  lk->locked = 0;
    80003bac:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003bb0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003bb4:	8526                	mv	a0,s1
    80003bb6:	ffffe097          	auipc	ra,0xffffe
    80003bba:	c5c080e7          	jalr	-932(ra) # 80001812 <wakeup>
  release(&lk->lk);
    80003bbe:	854a                	mv	a0,s2
    80003bc0:	00003097          	auipc	ra,0x3
    80003bc4:	9c0080e7          	jalr	-1600(ra) # 80006580 <release>
}
    80003bc8:	60e2                	ld	ra,24(sp)
    80003bca:	6442                	ld	s0,16(sp)
    80003bcc:	64a2                	ld	s1,8(sp)
    80003bce:	6902                	ld	s2,0(sp)
    80003bd0:	6105                	addi	sp,sp,32
    80003bd2:	8082                	ret

0000000080003bd4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003bd4:	7179                	addi	sp,sp,-48
    80003bd6:	f406                	sd	ra,40(sp)
    80003bd8:	f022                	sd	s0,32(sp)
    80003bda:	ec26                	sd	s1,24(sp)
    80003bdc:	e84a                	sd	s2,16(sp)
    80003bde:	e44e                	sd	s3,8(sp)
    80003be0:	1800                	addi	s0,sp,48
    80003be2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003be4:	00850913          	addi	s2,a0,8
    80003be8:	854a                	mv	a0,s2
    80003bea:	00003097          	auipc	ra,0x3
    80003bee:	8e2080e7          	jalr	-1822(ra) # 800064cc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003bf2:	409c                	lw	a5,0(s1)
    80003bf4:	ef99                	bnez	a5,80003c12 <holdingsleep+0x3e>
    80003bf6:	4481                	li	s1,0
  release(&lk->lk);
    80003bf8:	854a                	mv	a0,s2
    80003bfa:	00003097          	auipc	ra,0x3
    80003bfe:	986080e7          	jalr	-1658(ra) # 80006580 <release>
  return r;
}
    80003c02:	8526                	mv	a0,s1
    80003c04:	70a2                	ld	ra,40(sp)
    80003c06:	7402                	ld	s0,32(sp)
    80003c08:	64e2                	ld	s1,24(sp)
    80003c0a:	6942                	ld	s2,16(sp)
    80003c0c:	69a2                	ld	s3,8(sp)
    80003c0e:	6145                	addi	sp,sp,48
    80003c10:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003c12:	0284a983          	lw	s3,40(s1)
    80003c16:	ffffd097          	auipc	ra,0xffffd
    80003c1a:	4f4080e7          	jalr	1268(ra) # 8000110a <myproc>
    80003c1e:	5904                	lw	s1,48(a0)
    80003c20:	413484b3          	sub	s1,s1,s3
    80003c24:	0014b493          	seqz	s1,s1
    80003c28:	bfc1                	j	80003bf8 <holdingsleep+0x24>

0000000080003c2a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003c2a:	1141                	addi	sp,sp,-16
    80003c2c:	e406                	sd	ra,8(sp)
    80003c2e:	e022                	sd	s0,0(sp)
    80003c30:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003c32:	00005597          	auipc	a1,0x5
    80003c36:	a1658593          	addi	a1,a1,-1514 # 80008648 <syscalls+0x238>
    80003c3a:	00235517          	auipc	a0,0x235
    80003c3e:	e3650513          	addi	a0,a0,-458 # 80238a70 <ftable>
    80003c42:	00002097          	auipc	ra,0x2
    80003c46:	7fa080e7          	jalr	2042(ra) # 8000643c <initlock>
}
    80003c4a:	60a2                	ld	ra,8(sp)
    80003c4c:	6402                	ld	s0,0(sp)
    80003c4e:	0141                	addi	sp,sp,16
    80003c50:	8082                	ret

0000000080003c52 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003c52:	1101                	addi	sp,sp,-32
    80003c54:	ec06                	sd	ra,24(sp)
    80003c56:	e822                	sd	s0,16(sp)
    80003c58:	e426                	sd	s1,8(sp)
    80003c5a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003c5c:	00235517          	auipc	a0,0x235
    80003c60:	e1450513          	addi	a0,a0,-492 # 80238a70 <ftable>
    80003c64:	00003097          	auipc	ra,0x3
    80003c68:	868080e7          	jalr	-1944(ra) # 800064cc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003c6c:	00235497          	auipc	s1,0x235
    80003c70:	e1c48493          	addi	s1,s1,-484 # 80238a88 <ftable+0x18>
    80003c74:	00236717          	auipc	a4,0x236
    80003c78:	db470713          	addi	a4,a4,-588 # 80239a28 <disk>
    if(f->ref == 0){
    80003c7c:	40dc                	lw	a5,4(s1)
    80003c7e:	cf99                	beqz	a5,80003c9c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003c80:	02848493          	addi	s1,s1,40
    80003c84:	fee49ce3          	bne	s1,a4,80003c7c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003c88:	00235517          	auipc	a0,0x235
    80003c8c:	de850513          	addi	a0,a0,-536 # 80238a70 <ftable>
    80003c90:	00003097          	auipc	ra,0x3
    80003c94:	8f0080e7          	jalr	-1808(ra) # 80006580 <release>
  return 0;
    80003c98:	4481                	li	s1,0
    80003c9a:	a819                	j	80003cb0 <filealloc+0x5e>
      f->ref = 1;
    80003c9c:	4785                	li	a5,1
    80003c9e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003ca0:	00235517          	auipc	a0,0x235
    80003ca4:	dd050513          	addi	a0,a0,-560 # 80238a70 <ftable>
    80003ca8:	00003097          	auipc	ra,0x3
    80003cac:	8d8080e7          	jalr	-1832(ra) # 80006580 <release>
}
    80003cb0:	8526                	mv	a0,s1
    80003cb2:	60e2                	ld	ra,24(sp)
    80003cb4:	6442                	ld	s0,16(sp)
    80003cb6:	64a2                	ld	s1,8(sp)
    80003cb8:	6105                	addi	sp,sp,32
    80003cba:	8082                	ret

0000000080003cbc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003cbc:	1101                	addi	sp,sp,-32
    80003cbe:	ec06                	sd	ra,24(sp)
    80003cc0:	e822                	sd	s0,16(sp)
    80003cc2:	e426                	sd	s1,8(sp)
    80003cc4:	1000                	addi	s0,sp,32
    80003cc6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003cc8:	00235517          	auipc	a0,0x235
    80003ccc:	da850513          	addi	a0,a0,-600 # 80238a70 <ftable>
    80003cd0:	00002097          	auipc	ra,0x2
    80003cd4:	7fc080e7          	jalr	2044(ra) # 800064cc <acquire>
  if(f->ref < 1)
    80003cd8:	40dc                	lw	a5,4(s1)
    80003cda:	02f05263          	blez	a5,80003cfe <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003cde:	2785                	addiw	a5,a5,1
    80003ce0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003ce2:	00235517          	auipc	a0,0x235
    80003ce6:	d8e50513          	addi	a0,a0,-626 # 80238a70 <ftable>
    80003cea:	00003097          	auipc	ra,0x3
    80003cee:	896080e7          	jalr	-1898(ra) # 80006580 <release>
  return f;
}
    80003cf2:	8526                	mv	a0,s1
    80003cf4:	60e2                	ld	ra,24(sp)
    80003cf6:	6442                	ld	s0,16(sp)
    80003cf8:	64a2                	ld	s1,8(sp)
    80003cfa:	6105                	addi	sp,sp,32
    80003cfc:	8082                	ret
    panic("filedup");
    80003cfe:	00005517          	auipc	a0,0x5
    80003d02:	95250513          	addi	a0,a0,-1710 # 80008650 <syscalls+0x240>
    80003d06:	00002097          	auipc	ra,0x2
    80003d0a:	27c080e7          	jalr	636(ra) # 80005f82 <panic>

0000000080003d0e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003d0e:	7139                	addi	sp,sp,-64
    80003d10:	fc06                	sd	ra,56(sp)
    80003d12:	f822                	sd	s0,48(sp)
    80003d14:	f426                	sd	s1,40(sp)
    80003d16:	f04a                	sd	s2,32(sp)
    80003d18:	ec4e                	sd	s3,24(sp)
    80003d1a:	e852                	sd	s4,16(sp)
    80003d1c:	e456                	sd	s5,8(sp)
    80003d1e:	0080                	addi	s0,sp,64
    80003d20:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003d22:	00235517          	auipc	a0,0x235
    80003d26:	d4e50513          	addi	a0,a0,-690 # 80238a70 <ftable>
    80003d2a:	00002097          	auipc	ra,0x2
    80003d2e:	7a2080e7          	jalr	1954(ra) # 800064cc <acquire>
  if(f->ref < 1)
    80003d32:	40dc                	lw	a5,4(s1)
    80003d34:	06f05163          	blez	a5,80003d96 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80003d38:	37fd                	addiw	a5,a5,-1
    80003d3a:	0007871b          	sext.w	a4,a5
    80003d3e:	c0dc                	sw	a5,4(s1)
    80003d40:	06e04363          	bgtz	a4,80003da6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003d44:	0004a903          	lw	s2,0(s1)
    80003d48:	0094ca83          	lbu	s5,9(s1)
    80003d4c:	0104ba03          	ld	s4,16(s1)
    80003d50:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003d54:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003d58:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003d5c:	00235517          	auipc	a0,0x235
    80003d60:	d1450513          	addi	a0,a0,-748 # 80238a70 <ftable>
    80003d64:	00003097          	auipc	ra,0x3
    80003d68:	81c080e7          	jalr	-2020(ra) # 80006580 <release>

  if(ff.type == FD_PIPE){
    80003d6c:	4785                	li	a5,1
    80003d6e:	04f90d63          	beq	s2,a5,80003dc8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003d72:	3979                	addiw	s2,s2,-2
    80003d74:	4785                	li	a5,1
    80003d76:	0527e063          	bltu	a5,s2,80003db6 <fileclose+0xa8>
    begin_op();
    80003d7a:	00000097          	auipc	ra,0x0
    80003d7e:	ac8080e7          	jalr	-1336(ra) # 80003842 <begin_op>
    iput(ff.ip);
    80003d82:	854e                	mv	a0,s3
    80003d84:	fffff097          	auipc	ra,0xfffff
    80003d88:	2b6080e7          	jalr	694(ra) # 8000303a <iput>
    end_op();
    80003d8c:	00000097          	auipc	ra,0x0
    80003d90:	b36080e7          	jalr	-1226(ra) # 800038c2 <end_op>
    80003d94:	a00d                	j	80003db6 <fileclose+0xa8>
    panic("fileclose");
    80003d96:	00005517          	auipc	a0,0x5
    80003d9a:	8c250513          	addi	a0,a0,-1854 # 80008658 <syscalls+0x248>
    80003d9e:	00002097          	auipc	ra,0x2
    80003da2:	1e4080e7          	jalr	484(ra) # 80005f82 <panic>
    release(&ftable.lock);
    80003da6:	00235517          	auipc	a0,0x235
    80003daa:	cca50513          	addi	a0,a0,-822 # 80238a70 <ftable>
    80003dae:	00002097          	auipc	ra,0x2
    80003db2:	7d2080e7          	jalr	2002(ra) # 80006580 <release>
  }
}
    80003db6:	70e2                	ld	ra,56(sp)
    80003db8:	7442                	ld	s0,48(sp)
    80003dba:	74a2                	ld	s1,40(sp)
    80003dbc:	7902                	ld	s2,32(sp)
    80003dbe:	69e2                	ld	s3,24(sp)
    80003dc0:	6a42                	ld	s4,16(sp)
    80003dc2:	6aa2                	ld	s5,8(sp)
    80003dc4:	6121                	addi	sp,sp,64
    80003dc6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003dc8:	85d6                	mv	a1,s5
    80003dca:	8552                	mv	a0,s4
    80003dcc:	00000097          	auipc	ra,0x0
    80003dd0:	34c080e7          	jalr	844(ra) # 80004118 <pipeclose>
    80003dd4:	b7cd                	j	80003db6 <fileclose+0xa8>

0000000080003dd6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003dd6:	715d                	addi	sp,sp,-80
    80003dd8:	e486                	sd	ra,72(sp)
    80003dda:	e0a2                	sd	s0,64(sp)
    80003ddc:	fc26                	sd	s1,56(sp)
    80003dde:	f84a                	sd	s2,48(sp)
    80003de0:	f44e                	sd	s3,40(sp)
    80003de2:	0880                	addi	s0,sp,80
    80003de4:	84aa                	mv	s1,a0
    80003de6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003de8:	ffffd097          	auipc	ra,0xffffd
    80003dec:	322080e7          	jalr	802(ra) # 8000110a <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003df0:	409c                	lw	a5,0(s1)
    80003df2:	37f9                	addiw	a5,a5,-2
    80003df4:	4705                	li	a4,1
    80003df6:	04f76763          	bltu	a4,a5,80003e44 <filestat+0x6e>
    80003dfa:	892a                	mv	s2,a0
    ilock(f->ip);
    80003dfc:	6c88                	ld	a0,24(s1)
    80003dfe:	fffff097          	auipc	ra,0xfffff
    80003e02:	082080e7          	jalr	130(ra) # 80002e80 <ilock>
    stati(f->ip, &st);
    80003e06:	fb840593          	addi	a1,s0,-72
    80003e0a:	6c88                	ld	a0,24(s1)
    80003e0c:	fffff097          	auipc	ra,0xfffff
    80003e10:	2fe080e7          	jalr	766(ra) # 8000310a <stati>
    iunlock(f->ip);
    80003e14:	6c88                	ld	a0,24(s1)
    80003e16:	fffff097          	auipc	ra,0xfffff
    80003e1a:	12c080e7          	jalr	300(ra) # 80002f42 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003e1e:	46e1                	li	a3,24
    80003e20:	fb840613          	addi	a2,s0,-72
    80003e24:	85ce                	mv	a1,s3
    80003e26:	05093503          	ld	a0,80(s2)
    80003e2a:	ffffd097          	auipc	ra,0xffffd
    80003e2e:	f66080e7          	jalr	-154(ra) # 80000d90 <copyout>
    80003e32:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003e36:	60a6                	ld	ra,72(sp)
    80003e38:	6406                	ld	s0,64(sp)
    80003e3a:	74e2                	ld	s1,56(sp)
    80003e3c:	7942                	ld	s2,48(sp)
    80003e3e:	79a2                	ld	s3,40(sp)
    80003e40:	6161                	addi	sp,sp,80
    80003e42:	8082                	ret
  return -1;
    80003e44:	557d                	li	a0,-1
    80003e46:	bfc5                	j	80003e36 <filestat+0x60>

0000000080003e48 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003e48:	7179                	addi	sp,sp,-48
    80003e4a:	f406                	sd	ra,40(sp)
    80003e4c:	f022                	sd	s0,32(sp)
    80003e4e:	ec26                	sd	s1,24(sp)
    80003e50:	e84a                	sd	s2,16(sp)
    80003e52:	e44e                	sd	s3,8(sp)
    80003e54:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003e56:	00854783          	lbu	a5,8(a0)
    80003e5a:	c3d5                	beqz	a5,80003efe <fileread+0xb6>
    80003e5c:	84aa                	mv	s1,a0
    80003e5e:	89ae                	mv	s3,a1
    80003e60:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80003e62:	411c                	lw	a5,0(a0)
    80003e64:	4705                	li	a4,1
    80003e66:	04e78963          	beq	a5,a4,80003eb8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003e6a:	470d                	li	a4,3
    80003e6c:	04e78d63          	beq	a5,a4,80003ec6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003e70:	4709                	li	a4,2
    80003e72:	06e79e63          	bne	a5,a4,80003eee <fileread+0xa6>
    ilock(f->ip);
    80003e76:	6d08                	ld	a0,24(a0)
    80003e78:	fffff097          	auipc	ra,0xfffff
    80003e7c:	008080e7          	jalr	8(ra) # 80002e80 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003e80:	874a                	mv	a4,s2
    80003e82:	5094                	lw	a3,32(s1)
    80003e84:	864e                	mv	a2,s3
    80003e86:	4585                	li	a1,1
    80003e88:	6c88                	ld	a0,24(s1)
    80003e8a:	fffff097          	auipc	ra,0xfffff
    80003e8e:	2aa080e7          	jalr	682(ra) # 80003134 <readi>
    80003e92:	892a                	mv	s2,a0
    80003e94:	00a05563          	blez	a0,80003e9e <fileread+0x56>
      f->off += r;
    80003e98:	509c                	lw	a5,32(s1)
    80003e9a:	9fa9                	addw	a5,a5,a0
    80003e9c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80003e9e:	6c88                	ld	a0,24(s1)
    80003ea0:	fffff097          	auipc	ra,0xfffff
    80003ea4:	0a2080e7          	jalr	162(ra) # 80002f42 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80003ea8:	854a                	mv	a0,s2
    80003eaa:	70a2                	ld	ra,40(sp)
    80003eac:	7402                	ld	s0,32(sp)
    80003eae:	64e2                	ld	s1,24(sp)
    80003eb0:	6942                	ld	s2,16(sp)
    80003eb2:	69a2                	ld	s3,8(sp)
    80003eb4:	6145                	addi	sp,sp,48
    80003eb6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003eb8:	6908                	ld	a0,16(a0)
    80003eba:	00000097          	auipc	ra,0x0
    80003ebe:	3ce080e7          	jalr	974(ra) # 80004288 <piperead>
    80003ec2:	892a                	mv	s2,a0
    80003ec4:	b7d5                	j	80003ea8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003ec6:	02451783          	lh	a5,36(a0)
    80003eca:	03079693          	slli	a3,a5,0x30
    80003ece:	92c1                	srli	a3,a3,0x30
    80003ed0:	4725                	li	a4,9
    80003ed2:	02d76863          	bltu	a4,a3,80003f02 <fileread+0xba>
    80003ed6:	0792                	slli	a5,a5,0x4
    80003ed8:	00235717          	auipc	a4,0x235
    80003edc:	af870713          	addi	a4,a4,-1288 # 802389d0 <devsw>
    80003ee0:	97ba                	add	a5,a5,a4
    80003ee2:	639c                	ld	a5,0(a5)
    80003ee4:	c38d                	beqz	a5,80003f06 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80003ee6:	4505                	li	a0,1
    80003ee8:	9782                	jalr	a5
    80003eea:	892a                	mv	s2,a0
    80003eec:	bf75                	j	80003ea8 <fileread+0x60>
    panic("fileread");
    80003eee:	00004517          	auipc	a0,0x4
    80003ef2:	77a50513          	addi	a0,a0,1914 # 80008668 <syscalls+0x258>
    80003ef6:	00002097          	auipc	ra,0x2
    80003efa:	08c080e7          	jalr	140(ra) # 80005f82 <panic>
    return -1;
    80003efe:	597d                	li	s2,-1
    80003f00:	b765                	j	80003ea8 <fileread+0x60>
      return -1;
    80003f02:	597d                	li	s2,-1
    80003f04:	b755                	j	80003ea8 <fileread+0x60>
    80003f06:	597d                	li	s2,-1
    80003f08:	b745                	j	80003ea8 <fileread+0x60>

0000000080003f0a <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80003f0a:	715d                	addi	sp,sp,-80
    80003f0c:	e486                	sd	ra,72(sp)
    80003f0e:	e0a2                	sd	s0,64(sp)
    80003f10:	fc26                	sd	s1,56(sp)
    80003f12:	f84a                	sd	s2,48(sp)
    80003f14:	f44e                	sd	s3,40(sp)
    80003f16:	f052                	sd	s4,32(sp)
    80003f18:	ec56                	sd	s5,24(sp)
    80003f1a:	e85a                	sd	s6,16(sp)
    80003f1c:	e45e                	sd	s7,8(sp)
    80003f1e:	e062                	sd	s8,0(sp)
    80003f20:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80003f22:	00954783          	lbu	a5,9(a0)
    80003f26:	10078663          	beqz	a5,80004032 <filewrite+0x128>
    80003f2a:	892a                	mv	s2,a0
    80003f2c:	8aae                	mv	s5,a1
    80003f2e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80003f30:	411c                	lw	a5,0(a0)
    80003f32:	4705                	li	a4,1
    80003f34:	02e78263          	beq	a5,a4,80003f58 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003f38:	470d                	li	a4,3
    80003f3a:	02e78663          	beq	a5,a4,80003f66 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003f3e:	4709                	li	a4,2
    80003f40:	0ee79163          	bne	a5,a4,80004022 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80003f44:	0ac05d63          	blez	a2,80003ffe <filewrite+0xf4>
    int i = 0;
    80003f48:	4981                	li	s3,0
    80003f4a:	6b05                	lui	s6,0x1
    80003f4c:	c00b0b13          	addi	s6,s6,-1024 # c00 <_entry-0x7ffff400>
    80003f50:	6b85                	lui	s7,0x1
    80003f52:	c00b8b9b          	addiw	s7,s7,-1024
    80003f56:	a861                	j	80003fee <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80003f58:	6908                	ld	a0,16(a0)
    80003f5a:	00000097          	auipc	ra,0x0
    80003f5e:	22e080e7          	jalr	558(ra) # 80004188 <pipewrite>
    80003f62:	8a2a                	mv	s4,a0
    80003f64:	a045                	j	80004004 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003f66:	02451783          	lh	a5,36(a0)
    80003f6a:	03079693          	slli	a3,a5,0x30
    80003f6e:	92c1                	srli	a3,a3,0x30
    80003f70:	4725                	li	a4,9
    80003f72:	0cd76263          	bltu	a4,a3,80004036 <filewrite+0x12c>
    80003f76:	0792                	slli	a5,a5,0x4
    80003f78:	00235717          	auipc	a4,0x235
    80003f7c:	a5870713          	addi	a4,a4,-1448 # 802389d0 <devsw>
    80003f80:	97ba                	add	a5,a5,a4
    80003f82:	679c                	ld	a5,8(a5)
    80003f84:	cbdd                	beqz	a5,8000403a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003f86:	4505                	li	a0,1
    80003f88:	9782                	jalr	a5
    80003f8a:	8a2a                	mv	s4,a0
    80003f8c:	a8a5                	j	80004004 <filewrite+0xfa>
    80003f8e:	00048c1b          	sext.w	s8,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80003f92:	00000097          	auipc	ra,0x0
    80003f96:	8b0080e7          	jalr	-1872(ra) # 80003842 <begin_op>
      ilock(f->ip);
    80003f9a:	01893503          	ld	a0,24(s2)
    80003f9e:	fffff097          	auipc	ra,0xfffff
    80003fa2:	ee2080e7          	jalr	-286(ra) # 80002e80 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003fa6:	8762                	mv	a4,s8
    80003fa8:	02092683          	lw	a3,32(s2)
    80003fac:	01598633          	add	a2,s3,s5
    80003fb0:	4585                	li	a1,1
    80003fb2:	01893503          	ld	a0,24(s2)
    80003fb6:	fffff097          	auipc	ra,0xfffff
    80003fba:	276080e7          	jalr	630(ra) # 8000322c <writei>
    80003fbe:	84aa                	mv	s1,a0
    80003fc0:	00a05763          	blez	a0,80003fce <filewrite+0xc4>
        f->off += r;
    80003fc4:	02092783          	lw	a5,32(s2)
    80003fc8:	9fa9                	addw	a5,a5,a0
    80003fca:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80003fce:	01893503          	ld	a0,24(s2)
    80003fd2:	fffff097          	auipc	ra,0xfffff
    80003fd6:	f70080e7          	jalr	-144(ra) # 80002f42 <iunlock>
      end_op();
    80003fda:	00000097          	auipc	ra,0x0
    80003fde:	8e8080e7          	jalr	-1816(ra) # 800038c2 <end_op>

      if(r != n1){
    80003fe2:	009c1f63          	bne	s8,s1,80004000 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80003fe6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80003fea:	0149db63          	bge	s3,s4,80004000 <filewrite+0xf6>
      int n1 = n - i;
    80003fee:	413a07bb          	subw	a5,s4,s3
      if(n1 > max)
    80003ff2:	84be                	mv	s1,a5
    80003ff4:	2781                	sext.w	a5,a5
    80003ff6:	f8fb5ce3          	bge	s6,a5,80003f8e <filewrite+0x84>
    80003ffa:	84de                	mv	s1,s7
    80003ffc:	bf49                	j	80003f8e <filewrite+0x84>
    int i = 0;
    80003ffe:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004000:	013a1f63          	bne	s4,s3,8000401e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004004:	8552                	mv	a0,s4
    80004006:	60a6                	ld	ra,72(sp)
    80004008:	6406                	ld	s0,64(sp)
    8000400a:	74e2                	ld	s1,56(sp)
    8000400c:	7942                	ld	s2,48(sp)
    8000400e:	79a2                	ld	s3,40(sp)
    80004010:	7a02                	ld	s4,32(sp)
    80004012:	6ae2                	ld	s5,24(sp)
    80004014:	6b42                	ld	s6,16(sp)
    80004016:	6ba2                	ld	s7,8(sp)
    80004018:	6c02                	ld	s8,0(sp)
    8000401a:	6161                	addi	sp,sp,80
    8000401c:	8082                	ret
    ret = (i == n ? n : -1);
    8000401e:	5a7d                	li	s4,-1
    80004020:	b7d5                	j	80004004 <filewrite+0xfa>
    panic("filewrite");
    80004022:	00004517          	auipc	a0,0x4
    80004026:	65650513          	addi	a0,a0,1622 # 80008678 <syscalls+0x268>
    8000402a:	00002097          	auipc	ra,0x2
    8000402e:	f58080e7          	jalr	-168(ra) # 80005f82 <panic>
    return -1;
    80004032:	5a7d                	li	s4,-1
    80004034:	bfc1                	j	80004004 <filewrite+0xfa>
      return -1;
    80004036:	5a7d                	li	s4,-1
    80004038:	b7f1                	j	80004004 <filewrite+0xfa>
    8000403a:	5a7d                	li	s4,-1
    8000403c:	b7e1                	j	80004004 <filewrite+0xfa>

000000008000403e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000403e:	7179                	addi	sp,sp,-48
    80004040:	f406                	sd	ra,40(sp)
    80004042:	f022                	sd	s0,32(sp)
    80004044:	ec26                	sd	s1,24(sp)
    80004046:	e84a                	sd	s2,16(sp)
    80004048:	e44e                	sd	s3,8(sp)
    8000404a:	e052                	sd	s4,0(sp)
    8000404c:	1800                	addi	s0,sp,48
    8000404e:	84aa                	mv	s1,a0
    80004050:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004052:	0005b023          	sd	zero,0(a1)
    80004056:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000405a:	00000097          	auipc	ra,0x0
    8000405e:	bf8080e7          	jalr	-1032(ra) # 80003c52 <filealloc>
    80004062:	e088                	sd	a0,0(s1)
    80004064:	c551                	beqz	a0,800040f0 <pipealloc+0xb2>
    80004066:	00000097          	auipc	ra,0x0
    8000406a:	bec080e7          	jalr	-1044(ra) # 80003c52 <filealloc>
    8000406e:	00aa3023          	sd	a0,0(s4)
    80004072:	c92d                	beqz	a0,800040e4 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004074:	ffffc097          	auipc	ra,0xffffc
    80004078:	2c8080e7          	jalr	712(ra) # 8000033c <kalloc>
    8000407c:	892a                	mv	s2,a0
    8000407e:	c125                	beqz	a0,800040de <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004080:	4985                	li	s3,1
    80004082:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004086:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000408a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000408e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004092:	00004597          	auipc	a1,0x4
    80004096:	5f658593          	addi	a1,a1,1526 # 80008688 <syscalls+0x278>
    8000409a:	00002097          	auipc	ra,0x2
    8000409e:	3a2080e7          	jalr	930(ra) # 8000643c <initlock>
  (*f0)->type = FD_PIPE;
    800040a2:	609c                	ld	a5,0(s1)
    800040a4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800040a8:	609c                	ld	a5,0(s1)
    800040aa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800040ae:	609c                	ld	a5,0(s1)
    800040b0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800040b4:	609c                	ld	a5,0(s1)
    800040b6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800040ba:	000a3783          	ld	a5,0(s4)
    800040be:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800040c2:	000a3783          	ld	a5,0(s4)
    800040c6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800040ca:	000a3783          	ld	a5,0(s4)
    800040ce:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800040d2:	000a3783          	ld	a5,0(s4)
    800040d6:	0127b823          	sd	s2,16(a5)
  return 0;
    800040da:	4501                	li	a0,0
    800040dc:	a025                	j	80004104 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800040de:	6088                	ld	a0,0(s1)
    800040e0:	e501                	bnez	a0,800040e8 <pipealloc+0xaa>
    800040e2:	a039                	j	800040f0 <pipealloc+0xb2>
    800040e4:	6088                	ld	a0,0(s1)
    800040e6:	c51d                	beqz	a0,80004114 <pipealloc+0xd6>
    fileclose(*f0);
    800040e8:	00000097          	auipc	ra,0x0
    800040ec:	c26080e7          	jalr	-986(ra) # 80003d0e <fileclose>
  if(*f1)
    800040f0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800040f4:	557d                	li	a0,-1
  if(*f1)
    800040f6:	c799                	beqz	a5,80004104 <pipealloc+0xc6>
    fileclose(*f1);
    800040f8:	853e                	mv	a0,a5
    800040fa:	00000097          	auipc	ra,0x0
    800040fe:	c14080e7          	jalr	-1004(ra) # 80003d0e <fileclose>
  return -1;
    80004102:	557d                	li	a0,-1
}
    80004104:	70a2                	ld	ra,40(sp)
    80004106:	7402                	ld	s0,32(sp)
    80004108:	64e2                	ld	s1,24(sp)
    8000410a:	6942                	ld	s2,16(sp)
    8000410c:	69a2                	ld	s3,8(sp)
    8000410e:	6a02                	ld	s4,0(sp)
    80004110:	6145                	addi	sp,sp,48
    80004112:	8082                	ret
  return -1;
    80004114:	557d                	li	a0,-1
    80004116:	b7fd                	j	80004104 <pipealloc+0xc6>

0000000080004118 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004118:	1101                	addi	sp,sp,-32
    8000411a:	ec06                	sd	ra,24(sp)
    8000411c:	e822                	sd	s0,16(sp)
    8000411e:	e426                	sd	s1,8(sp)
    80004120:	e04a                	sd	s2,0(sp)
    80004122:	1000                	addi	s0,sp,32
    80004124:	84aa                	mv	s1,a0
    80004126:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004128:	00002097          	auipc	ra,0x2
    8000412c:	3a4080e7          	jalr	932(ra) # 800064cc <acquire>
  if(writable){
    80004130:	02090d63          	beqz	s2,8000416a <pipeclose+0x52>
    pi->writeopen = 0;
    80004134:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004138:	21848513          	addi	a0,s1,536
    8000413c:	ffffd097          	auipc	ra,0xffffd
    80004140:	6d6080e7          	jalr	1750(ra) # 80001812 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004144:	2204b783          	ld	a5,544(s1)
    80004148:	eb95                	bnez	a5,8000417c <pipeclose+0x64>
    release(&pi->lock);
    8000414a:	8526                	mv	a0,s1
    8000414c:	00002097          	auipc	ra,0x2
    80004150:	434080e7          	jalr	1076(ra) # 80006580 <release>
    kfree((char*)pi);
    80004154:	8526                	mv	a0,s1
    80004156:	ffffc097          	auipc	ra,0xffffc
    8000415a:	05e080e7          	jalr	94(ra) # 800001b4 <kfree>
  } else
    release(&pi->lock);
}
    8000415e:	60e2                	ld	ra,24(sp)
    80004160:	6442                	ld	s0,16(sp)
    80004162:	64a2                	ld	s1,8(sp)
    80004164:	6902                	ld	s2,0(sp)
    80004166:	6105                	addi	sp,sp,32
    80004168:	8082                	ret
    pi->readopen = 0;
    8000416a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000416e:	21c48513          	addi	a0,s1,540
    80004172:	ffffd097          	auipc	ra,0xffffd
    80004176:	6a0080e7          	jalr	1696(ra) # 80001812 <wakeup>
    8000417a:	b7e9                	j	80004144 <pipeclose+0x2c>
    release(&pi->lock);
    8000417c:	8526                	mv	a0,s1
    8000417e:	00002097          	auipc	ra,0x2
    80004182:	402080e7          	jalr	1026(ra) # 80006580 <release>
}
    80004186:	bfe1                	j	8000415e <pipeclose+0x46>

0000000080004188 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004188:	7159                	addi	sp,sp,-112
    8000418a:	f486                	sd	ra,104(sp)
    8000418c:	f0a2                	sd	s0,96(sp)
    8000418e:	eca6                	sd	s1,88(sp)
    80004190:	e8ca                	sd	s2,80(sp)
    80004192:	e4ce                	sd	s3,72(sp)
    80004194:	e0d2                	sd	s4,64(sp)
    80004196:	fc56                	sd	s5,56(sp)
    80004198:	f85a                	sd	s6,48(sp)
    8000419a:	f45e                	sd	s7,40(sp)
    8000419c:	f062                	sd	s8,32(sp)
    8000419e:	ec66                	sd	s9,24(sp)
    800041a0:	1880                	addi	s0,sp,112
    800041a2:	84aa                	mv	s1,a0
    800041a4:	8aae                	mv	s5,a1
    800041a6:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800041a8:	ffffd097          	auipc	ra,0xffffd
    800041ac:	f62080e7          	jalr	-158(ra) # 8000110a <myproc>
    800041b0:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800041b2:	8526                	mv	a0,s1
    800041b4:	00002097          	auipc	ra,0x2
    800041b8:	318080e7          	jalr	792(ra) # 800064cc <acquire>
  while(i < n){
    800041bc:	0d405463          	blez	s4,80004284 <pipewrite+0xfc>
    800041c0:	8ba6                	mv	s7,s1
  int i = 0;
    800041c2:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800041c4:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800041c6:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800041ca:	21c48c13          	addi	s8,s1,540
    800041ce:	a08d                	j	80004230 <pipewrite+0xa8>
      release(&pi->lock);
    800041d0:	8526                	mv	a0,s1
    800041d2:	00002097          	auipc	ra,0x2
    800041d6:	3ae080e7          	jalr	942(ra) # 80006580 <release>
      return -1;
    800041da:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800041dc:	854a                	mv	a0,s2
    800041de:	70a6                	ld	ra,104(sp)
    800041e0:	7406                	ld	s0,96(sp)
    800041e2:	64e6                	ld	s1,88(sp)
    800041e4:	6946                	ld	s2,80(sp)
    800041e6:	69a6                	ld	s3,72(sp)
    800041e8:	6a06                	ld	s4,64(sp)
    800041ea:	7ae2                	ld	s5,56(sp)
    800041ec:	7b42                	ld	s6,48(sp)
    800041ee:	7ba2                	ld	s7,40(sp)
    800041f0:	7c02                	ld	s8,32(sp)
    800041f2:	6ce2                	ld	s9,24(sp)
    800041f4:	6165                	addi	sp,sp,112
    800041f6:	8082                	ret
      wakeup(&pi->nread);
    800041f8:	8566                	mv	a0,s9
    800041fa:	ffffd097          	auipc	ra,0xffffd
    800041fe:	618080e7          	jalr	1560(ra) # 80001812 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004202:	85de                	mv	a1,s7
    80004204:	8562                	mv	a0,s8
    80004206:	ffffd097          	auipc	ra,0xffffd
    8000420a:	5a8080e7          	jalr	1448(ra) # 800017ae <sleep>
    8000420e:	a839                	j	8000422c <pipewrite+0xa4>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004210:	21c4a783          	lw	a5,540(s1)
    80004214:	0017871b          	addiw	a4,a5,1
    80004218:	20e4ae23          	sw	a4,540(s1)
    8000421c:	1ff7f793          	andi	a5,a5,511
    80004220:	97a6                	add	a5,a5,s1
    80004222:	f9f44703          	lbu	a4,-97(s0)
    80004226:	00e78c23          	sb	a4,24(a5)
      i++;
    8000422a:	2905                	addiw	s2,s2,1
  while(i < n){
    8000422c:	05495063          	bge	s2,s4,8000426c <pipewrite+0xe4>
    if(pi->readopen == 0 || killed(pr)){
    80004230:	2204a783          	lw	a5,544(s1)
    80004234:	dfd1                	beqz	a5,800041d0 <pipewrite+0x48>
    80004236:	854e                	mv	a0,s3
    80004238:	ffffe097          	auipc	ra,0xffffe
    8000423c:	81e080e7          	jalr	-2018(ra) # 80001a56 <killed>
    80004240:	f941                	bnez	a0,800041d0 <pipewrite+0x48>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004242:	2184a783          	lw	a5,536(s1)
    80004246:	21c4a703          	lw	a4,540(s1)
    8000424a:	2007879b          	addiw	a5,a5,512
    8000424e:	faf705e3          	beq	a4,a5,800041f8 <pipewrite+0x70>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004252:	4685                	li	a3,1
    80004254:	01590633          	add	a2,s2,s5
    80004258:	f9f40593          	addi	a1,s0,-97
    8000425c:	0509b503          	ld	a0,80(s3)
    80004260:	ffffd097          	auipc	ra,0xffffd
    80004264:	bf4080e7          	jalr	-1036(ra) # 80000e54 <copyin>
    80004268:	fb6514e3          	bne	a0,s6,80004210 <pipewrite+0x88>
  wakeup(&pi->nread);
    8000426c:	21848513          	addi	a0,s1,536
    80004270:	ffffd097          	auipc	ra,0xffffd
    80004274:	5a2080e7          	jalr	1442(ra) # 80001812 <wakeup>
  release(&pi->lock);
    80004278:	8526                	mv	a0,s1
    8000427a:	00002097          	auipc	ra,0x2
    8000427e:	306080e7          	jalr	774(ra) # 80006580 <release>
  return i;
    80004282:	bfa9                	j	800041dc <pipewrite+0x54>
  int i = 0;
    80004284:	4901                	li	s2,0
    80004286:	b7dd                	j	8000426c <pipewrite+0xe4>

0000000080004288 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004288:	715d                	addi	sp,sp,-80
    8000428a:	e486                	sd	ra,72(sp)
    8000428c:	e0a2                	sd	s0,64(sp)
    8000428e:	fc26                	sd	s1,56(sp)
    80004290:	f84a                	sd	s2,48(sp)
    80004292:	f44e                	sd	s3,40(sp)
    80004294:	f052                	sd	s4,32(sp)
    80004296:	ec56                	sd	s5,24(sp)
    80004298:	e85a                	sd	s6,16(sp)
    8000429a:	0880                	addi	s0,sp,80
    8000429c:	84aa                	mv	s1,a0
    8000429e:	892e                	mv	s2,a1
    800042a0:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800042a2:	ffffd097          	auipc	ra,0xffffd
    800042a6:	e68080e7          	jalr	-408(ra) # 8000110a <myproc>
    800042aa:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800042ac:	8b26                	mv	s6,s1
    800042ae:	8526                	mv	a0,s1
    800042b0:	00002097          	auipc	ra,0x2
    800042b4:	21c080e7          	jalr	540(ra) # 800064cc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800042b8:	2184a703          	lw	a4,536(s1)
    800042bc:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800042c0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800042c4:	02f71763          	bne	a4,a5,800042f2 <piperead+0x6a>
    800042c8:	2244a783          	lw	a5,548(s1)
    800042cc:	c39d                	beqz	a5,800042f2 <piperead+0x6a>
    if(killed(pr)){
    800042ce:	8552                	mv	a0,s4
    800042d0:	ffffd097          	auipc	ra,0xffffd
    800042d4:	786080e7          	jalr	1926(ra) # 80001a56 <killed>
    800042d8:	e941                	bnez	a0,80004368 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    800042da:	85da                	mv	a1,s6
    800042dc:	854e                	mv	a0,s3
    800042de:	ffffd097          	auipc	ra,0xffffd
    800042e2:	4d0080e7          	jalr	1232(ra) # 800017ae <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800042e6:	2184a703          	lw	a4,536(s1)
    800042ea:	21c4a783          	lw	a5,540(s1)
    800042ee:	fcf70de3          	beq	a4,a5,800042c8 <piperead+0x40>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800042f2:	09505263          	blez	s5,80004376 <piperead+0xee>
    800042f6:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800042f8:	5b7d                	li	s6,-1
    if(pi->nread == pi->nwrite)
    800042fa:	2184a783          	lw	a5,536(s1)
    800042fe:	21c4a703          	lw	a4,540(s1)
    80004302:	02f70d63          	beq	a4,a5,8000433c <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004306:	0017871b          	addiw	a4,a5,1
    8000430a:	20e4ac23          	sw	a4,536(s1)
    8000430e:	1ff7f793          	andi	a5,a5,511
    80004312:	97a6                	add	a5,a5,s1
    80004314:	0187c783          	lbu	a5,24(a5)
    80004318:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000431c:	4685                	li	a3,1
    8000431e:	fbf40613          	addi	a2,s0,-65
    80004322:	85ca                	mv	a1,s2
    80004324:	050a3503          	ld	a0,80(s4)
    80004328:	ffffd097          	auipc	ra,0xffffd
    8000432c:	a68080e7          	jalr	-1432(ra) # 80000d90 <copyout>
    80004330:	01650663          	beq	a0,s6,8000433c <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004334:	2985                	addiw	s3,s3,1
    80004336:	0905                	addi	s2,s2,1
    80004338:	fd3a91e3          	bne	s5,s3,800042fa <piperead+0x72>
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000433c:	21c48513          	addi	a0,s1,540
    80004340:	ffffd097          	auipc	ra,0xffffd
    80004344:	4d2080e7          	jalr	1234(ra) # 80001812 <wakeup>
  release(&pi->lock);
    80004348:	8526                	mv	a0,s1
    8000434a:	00002097          	auipc	ra,0x2
    8000434e:	236080e7          	jalr	566(ra) # 80006580 <release>
  return i;
}
    80004352:	854e                	mv	a0,s3
    80004354:	60a6                	ld	ra,72(sp)
    80004356:	6406                	ld	s0,64(sp)
    80004358:	74e2                	ld	s1,56(sp)
    8000435a:	7942                	ld	s2,48(sp)
    8000435c:	79a2                	ld	s3,40(sp)
    8000435e:	7a02                	ld	s4,32(sp)
    80004360:	6ae2                	ld	s5,24(sp)
    80004362:	6b42                	ld	s6,16(sp)
    80004364:	6161                	addi	sp,sp,80
    80004366:	8082                	ret
      release(&pi->lock);
    80004368:	8526                	mv	a0,s1
    8000436a:	00002097          	auipc	ra,0x2
    8000436e:	216080e7          	jalr	534(ra) # 80006580 <release>
      return -1;
    80004372:	59fd                	li	s3,-1
    80004374:	bff9                	j	80004352 <piperead+0xca>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004376:	4981                	li	s3,0
    80004378:	b7d1                	j	8000433c <piperead+0xb4>

000000008000437a <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000437a:	1141                	addi	sp,sp,-16
    8000437c:	e422                	sd	s0,8(sp)
    8000437e:	0800                	addi	s0,sp,16
    80004380:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004382:	8905                	andi	a0,a0,1
    80004384:	c111                	beqz	a0,80004388 <flags2perm+0xe>
      perm = PTE_X;
    80004386:	4521                	li	a0,8
    if(flags & 0x2)
    80004388:	8b89                	andi	a5,a5,2
    8000438a:	c399                	beqz	a5,80004390 <flags2perm+0x16>
      perm |= PTE_W;
    8000438c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004390:	6422                	ld	s0,8(sp)
    80004392:	0141                	addi	sp,sp,16
    80004394:	8082                	ret

0000000080004396 <exec>:

int
exec(char *path, char **argv)
{
    80004396:	df010113          	addi	sp,sp,-528
    8000439a:	20113423          	sd	ra,520(sp)
    8000439e:	20813023          	sd	s0,512(sp)
    800043a2:	ffa6                	sd	s1,504(sp)
    800043a4:	fbca                	sd	s2,496(sp)
    800043a6:	f7ce                	sd	s3,488(sp)
    800043a8:	f3d2                	sd	s4,480(sp)
    800043aa:	efd6                	sd	s5,472(sp)
    800043ac:	ebda                	sd	s6,464(sp)
    800043ae:	e7de                	sd	s7,456(sp)
    800043b0:	e3e2                	sd	s8,448(sp)
    800043b2:	ff66                	sd	s9,440(sp)
    800043b4:	fb6a                	sd	s10,432(sp)
    800043b6:	f76e                	sd	s11,424(sp)
    800043b8:	0c00                	addi	s0,sp,528
    800043ba:	84aa                	mv	s1,a0
    800043bc:	dea43c23          	sd	a0,-520(s0)
    800043c0:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	d46080e7          	jalr	-698(ra) # 8000110a <myproc>
    800043cc:	892a                	mv	s2,a0

  begin_op();
    800043ce:	fffff097          	auipc	ra,0xfffff
    800043d2:	474080e7          	jalr	1140(ra) # 80003842 <begin_op>

  if((ip = namei(path)) == 0){
    800043d6:	8526                	mv	a0,s1
    800043d8:	fffff097          	auipc	ra,0xfffff
    800043dc:	24e080e7          	jalr	590(ra) # 80003626 <namei>
    800043e0:	c92d                	beqz	a0,80004452 <exec+0xbc>
    800043e2:	84aa                	mv	s1,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800043e4:	fffff097          	auipc	ra,0xfffff
    800043e8:	a9c080e7          	jalr	-1380(ra) # 80002e80 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800043ec:	04000713          	li	a4,64
    800043f0:	4681                	li	a3,0
    800043f2:	e5040613          	addi	a2,s0,-432
    800043f6:	4581                	li	a1,0
    800043f8:	8526                	mv	a0,s1
    800043fa:	fffff097          	auipc	ra,0xfffff
    800043fe:	d3a080e7          	jalr	-710(ra) # 80003134 <readi>
    80004402:	04000793          	li	a5,64
    80004406:	00f51a63          	bne	a0,a5,8000441a <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    8000440a:	e5042703          	lw	a4,-432(s0)
    8000440e:	464c47b7          	lui	a5,0x464c4
    80004412:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004416:	04f70463          	beq	a4,a5,8000445e <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000441a:	8526                	mv	a0,s1
    8000441c:	fffff097          	auipc	ra,0xfffff
    80004420:	cc6080e7          	jalr	-826(ra) # 800030e2 <iunlockput>
    end_op();
    80004424:	fffff097          	auipc	ra,0xfffff
    80004428:	49e080e7          	jalr	1182(ra) # 800038c2 <end_op>
  }
  return -1;
    8000442c:	557d                	li	a0,-1
}
    8000442e:	20813083          	ld	ra,520(sp)
    80004432:	20013403          	ld	s0,512(sp)
    80004436:	74fe                	ld	s1,504(sp)
    80004438:	795e                	ld	s2,496(sp)
    8000443a:	79be                	ld	s3,488(sp)
    8000443c:	7a1e                	ld	s4,480(sp)
    8000443e:	6afe                	ld	s5,472(sp)
    80004440:	6b5e                	ld	s6,464(sp)
    80004442:	6bbe                	ld	s7,456(sp)
    80004444:	6c1e                	ld	s8,448(sp)
    80004446:	7cfa                	ld	s9,440(sp)
    80004448:	7d5a                	ld	s10,432(sp)
    8000444a:	7dba                	ld	s11,424(sp)
    8000444c:	21010113          	addi	sp,sp,528
    80004450:	8082                	ret
    end_op();
    80004452:	fffff097          	auipc	ra,0xfffff
    80004456:	470080e7          	jalr	1136(ra) # 800038c2 <end_op>
    return -1;
    8000445a:	557d                	li	a0,-1
    8000445c:	bfc9                	j	8000442e <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    8000445e:	854a                	mv	a0,s2
    80004460:	ffffd097          	auipc	ra,0xffffd
    80004464:	d6e080e7          	jalr	-658(ra) # 800011ce <proc_pagetable>
    80004468:	8baa                	mv	s7,a0
    8000446a:	d945                	beqz	a0,8000441a <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000446c:	e7042983          	lw	s3,-400(s0)
    80004470:	e8845783          	lhu	a5,-376(s0)
    80004474:	c7ad                	beqz	a5,800044de <exec+0x148>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004476:	4a01                	li	s4,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004478:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000447a:	6c85                	lui	s9,0x1
    8000447c:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004480:	def43823          	sd	a5,-528(s0)
    80004484:	ac0d                	j	800046b6 <exec+0x320>
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004486:	00004517          	auipc	a0,0x4
    8000448a:	20a50513          	addi	a0,a0,522 # 80008690 <syscalls+0x280>
    8000448e:	00002097          	auipc	ra,0x2
    80004492:	af4080e7          	jalr	-1292(ra) # 80005f82 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004496:	8756                	mv	a4,s5
    80004498:	012d86bb          	addw	a3,s11,s2
    8000449c:	4581                	li	a1,0
    8000449e:	8526                	mv	a0,s1
    800044a0:	fffff097          	auipc	ra,0xfffff
    800044a4:	c94080e7          	jalr	-876(ra) # 80003134 <readi>
    800044a8:	2501                	sext.w	a0,a0
    800044aa:	1aaa9a63          	bne	s5,a0,8000465e <exec+0x2c8>
  for(i = 0; i < sz; i += PGSIZE){
    800044ae:	6785                	lui	a5,0x1
    800044b0:	0127893b          	addw	s2,a5,s2
    800044b4:	77fd                	lui	a5,0xfffff
    800044b6:	01478a3b          	addw	s4,a5,s4
    800044ba:	1f897563          	bgeu	s2,s8,800046a4 <exec+0x30e>
    pa = walkaddr(pagetable, va + i);
    800044be:	02091593          	slli	a1,s2,0x20
    800044c2:	9181                	srli	a1,a1,0x20
    800044c4:	95ea                	add	a1,a1,s10
    800044c6:	855e                	mv	a0,s7
    800044c8:	ffffc097          	auipc	ra,0xffffc
    800044cc:	266080e7          	jalr	614(ra) # 8000072e <walkaddr>
    800044d0:	862a                	mv	a2,a0
    if(pa == 0)
    800044d2:	d955                	beqz	a0,80004486 <exec+0xf0>
      n = PGSIZE;
    800044d4:	8ae6                	mv	s5,s9
    if(sz - i < PGSIZE)
    800044d6:	fd9a70e3          	bgeu	s4,s9,80004496 <exec+0x100>
      n = sz - i;
    800044da:	8ad2                	mv	s5,s4
    800044dc:	bf6d                	j	80004496 <exec+0x100>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800044de:	4a01                	li	s4,0
  iunlockput(ip);
    800044e0:	8526                	mv	a0,s1
    800044e2:	fffff097          	auipc	ra,0xfffff
    800044e6:	c00080e7          	jalr	-1024(ra) # 800030e2 <iunlockput>
  end_op();
    800044ea:	fffff097          	auipc	ra,0xfffff
    800044ee:	3d8080e7          	jalr	984(ra) # 800038c2 <end_op>
  p = myproc();
    800044f2:	ffffd097          	auipc	ra,0xffffd
    800044f6:	c18080e7          	jalr	-1000(ra) # 8000110a <myproc>
    800044fa:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800044fc:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004500:	6785                	lui	a5,0x1
    80004502:	17fd                	addi	a5,a5,-1
    80004504:	9a3e                	add	s4,s4,a5
    80004506:	757d                	lui	a0,0xfffff
    80004508:	00aa77b3          	and	a5,s4,a0
    8000450c:	e0f43423          	sd	a5,-504(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004510:	4691                	li	a3,4
    80004512:	6609                	lui	a2,0x2
    80004514:	963e                	add	a2,a2,a5
    80004516:	85be                	mv	a1,a5
    80004518:	855e                	mv	a0,s7
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	5c8080e7          	jalr	1480(ra) # 80000ae2 <uvmalloc>
    80004522:	8b2a                	mv	s6,a0
  ip = 0;
    80004524:	4481                	li	s1,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004526:	12050c63          	beqz	a0,8000465e <exec+0x2c8>
  uvmclear(pagetable, sz-2*PGSIZE);
    8000452a:	75f9                	lui	a1,0xffffe
    8000452c:	95aa                	add	a1,a1,a0
    8000452e:	855e                	mv	a0,s7
    80004530:	ffffd097          	auipc	ra,0xffffd
    80004534:	82e080e7          	jalr	-2002(ra) # 80000d5e <uvmclear>
  stackbase = sp - PGSIZE;
    80004538:	7c7d                	lui	s8,0xfffff
    8000453a:	9c5a                	add	s8,s8,s6
  for(argc = 0; argv[argc]; argc++) {
    8000453c:	e0043783          	ld	a5,-512(s0)
    80004540:	6388                	ld	a0,0(a5)
    80004542:	c535                	beqz	a0,800045ae <exec+0x218>
    80004544:	e9040993          	addi	s3,s0,-368
    80004548:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    8000454c:	895a                	mv	s2,s6
    sp -= strlen(argv[argc]) + 1;
    8000454e:	ffffc097          	auipc	ra,0xffffc
    80004552:	fd2080e7          	jalr	-46(ra) # 80000520 <strlen>
    80004556:	2505                	addiw	a0,a0,1
    80004558:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000455c:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004560:	13896663          	bltu	s2,s8,8000468c <exec+0x2f6>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004564:	e0043d83          	ld	s11,-512(s0)
    80004568:	000dba03          	ld	s4,0(s11)
    8000456c:	8552                	mv	a0,s4
    8000456e:	ffffc097          	auipc	ra,0xffffc
    80004572:	fb2080e7          	jalr	-78(ra) # 80000520 <strlen>
    80004576:	0015069b          	addiw	a3,a0,1
    8000457a:	8652                	mv	a2,s4
    8000457c:	85ca                	mv	a1,s2
    8000457e:	855e                	mv	a0,s7
    80004580:	ffffd097          	auipc	ra,0xffffd
    80004584:	810080e7          	jalr	-2032(ra) # 80000d90 <copyout>
    80004588:	10054663          	bltz	a0,80004694 <exec+0x2fe>
    ustack[argc] = sp;
    8000458c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004590:	0485                	addi	s1,s1,1
    80004592:	008d8793          	addi	a5,s11,8
    80004596:	e0f43023          	sd	a5,-512(s0)
    8000459a:	008db503          	ld	a0,8(s11)
    8000459e:	c911                	beqz	a0,800045b2 <exec+0x21c>
    if(argc >= MAXARG)
    800045a0:	09a1                	addi	s3,s3,8
    800045a2:	fb3c96e3          	bne	s9,s3,8000454e <exec+0x1b8>
  sz = sz1;
    800045a6:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800045aa:	4481                	li	s1,0
    800045ac:	a84d                	j	8000465e <exec+0x2c8>
  sp = sz;
    800045ae:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    800045b0:	4481                	li	s1,0
  ustack[argc] = 0;
    800045b2:	00349793          	slli	a5,s1,0x3
    800045b6:	f9040713          	addi	a4,s0,-112
    800045ba:	97ba                	add	a5,a5,a4
    800045bc:	f007b023          	sd	zero,-256(a5) # f00 <_entry-0x7ffff100>
  sp -= (argc+1) * sizeof(uint64);
    800045c0:	00148693          	addi	a3,s1,1
    800045c4:	068e                	slli	a3,a3,0x3
    800045c6:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800045ca:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800045ce:	01897663          	bgeu	s2,s8,800045da <exec+0x244>
  sz = sz1;
    800045d2:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800045d6:	4481                	li	s1,0
    800045d8:	a059                	j	8000465e <exec+0x2c8>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800045da:	e9040613          	addi	a2,s0,-368
    800045de:	85ca                	mv	a1,s2
    800045e0:	855e                	mv	a0,s7
    800045e2:	ffffc097          	auipc	ra,0xffffc
    800045e6:	7ae080e7          	jalr	1966(ra) # 80000d90 <copyout>
    800045ea:	0a054963          	bltz	a0,8000469c <exec+0x306>
  p->trapframe->a1 = sp;
    800045ee:	058ab783          	ld	a5,88(s5)
    800045f2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800045f6:	df843783          	ld	a5,-520(s0)
    800045fa:	0007c703          	lbu	a4,0(a5)
    800045fe:	cf11                	beqz	a4,8000461a <exec+0x284>
    80004600:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004602:	02f00693          	li	a3,47
    80004606:	a039                	j	80004614 <exec+0x27e>
      last = s+1;
    80004608:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    8000460c:	0785                	addi	a5,a5,1
    8000460e:	fff7c703          	lbu	a4,-1(a5)
    80004612:	c701                	beqz	a4,8000461a <exec+0x284>
    if(*s == '/')
    80004614:	fed71ce3          	bne	a4,a3,8000460c <exec+0x276>
    80004618:	bfc5                	j	80004608 <exec+0x272>
  safestrcpy(p->name, last, sizeof(p->name));
    8000461a:	4641                	li	a2,16
    8000461c:	df843583          	ld	a1,-520(s0)
    80004620:	158a8513          	addi	a0,s5,344
    80004624:	ffffc097          	auipc	ra,0xffffc
    80004628:	eca080e7          	jalr	-310(ra) # 800004ee <safestrcpy>
  oldpagetable = p->pagetable;
    8000462c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004630:	057ab823          	sd	s7,80(s5)
  p->sz = sz;
    80004634:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004638:	058ab783          	ld	a5,88(s5)
    8000463c:	e6843703          	ld	a4,-408(s0)
    80004640:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004642:	058ab783          	ld	a5,88(s5)
    80004646:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000464a:	85ea                	mv	a1,s10
    8000464c:	ffffd097          	auipc	ra,0xffffd
    80004650:	c1e080e7          	jalr	-994(ra) # 8000126a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004654:	0004851b          	sext.w	a0,s1
    80004658:	bbd9                	j	8000442e <exec+0x98>
    8000465a:	e1443423          	sd	s4,-504(s0)
    proc_freepagetable(pagetable, sz);
    8000465e:	e0843583          	ld	a1,-504(s0)
    80004662:	855e                	mv	a0,s7
    80004664:	ffffd097          	auipc	ra,0xffffd
    80004668:	c06080e7          	jalr	-1018(ra) # 8000126a <proc_freepagetable>
  if(ip){
    8000466c:	da0497e3          	bnez	s1,8000441a <exec+0x84>
  return -1;
    80004670:	557d                	li	a0,-1
    80004672:	bb75                	j	8000442e <exec+0x98>
    80004674:	e1443423          	sd	s4,-504(s0)
    80004678:	b7dd                	j	8000465e <exec+0x2c8>
    8000467a:	e1443423          	sd	s4,-504(s0)
    8000467e:	b7c5                	j	8000465e <exec+0x2c8>
    80004680:	e1443423          	sd	s4,-504(s0)
    80004684:	bfe9                	j	8000465e <exec+0x2c8>
    80004686:	e1443423          	sd	s4,-504(s0)
    8000468a:	bfd1                	j	8000465e <exec+0x2c8>
  sz = sz1;
    8000468c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004690:	4481                	li	s1,0
    80004692:	b7f1                	j	8000465e <exec+0x2c8>
  sz = sz1;
    80004694:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    80004698:	4481                	li	s1,0
    8000469a:	b7d1                	j	8000465e <exec+0x2c8>
  sz = sz1;
    8000469c:	e1643423          	sd	s6,-504(s0)
  ip = 0;
    800046a0:	4481                	li	s1,0
    800046a2:	bf75                	j	8000465e <exec+0x2c8>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800046a4:	e0843a03          	ld	s4,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800046a8:	2b05                	addiw	s6,s6,1
    800046aa:	0389899b          	addiw	s3,s3,56
    800046ae:	e8845783          	lhu	a5,-376(s0)
    800046b2:	e2fb57e3          	bge	s6,a5,800044e0 <exec+0x14a>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800046b6:	2981                	sext.w	s3,s3
    800046b8:	03800713          	li	a4,56
    800046bc:	86ce                	mv	a3,s3
    800046be:	e1840613          	addi	a2,s0,-488
    800046c2:	4581                	li	a1,0
    800046c4:	8526                	mv	a0,s1
    800046c6:	fffff097          	auipc	ra,0xfffff
    800046ca:	a6e080e7          	jalr	-1426(ra) # 80003134 <readi>
    800046ce:	03800793          	li	a5,56
    800046d2:	f8f514e3          	bne	a0,a5,8000465a <exec+0x2c4>
    if(ph.type != ELF_PROG_LOAD)
    800046d6:	e1842783          	lw	a5,-488(s0)
    800046da:	4705                	li	a4,1
    800046dc:	fce796e3          	bne	a5,a4,800046a8 <exec+0x312>
    if(ph.memsz < ph.filesz)
    800046e0:	e4043903          	ld	s2,-448(s0)
    800046e4:	e3843783          	ld	a5,-456(s0)
    800046e8:	f8f966e3          	bltu	s2,a5,80004674 <exec+0x2de>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800046ec:	e2843783          	ld	a5,-472(s0)
    800046f0:	993e                	add	s2,s2,a5
    800046f2:	f8f964e3          	bltu	s2,a5,8000467a <exec+0x2e4>
    if(ph.vaddr % PGSIZE != 0)
    800046f6:	df043703          	ld	a4,-528(s0)
    800046fa:	8ff9                	and	a5,a5,a4
    800046fc:	f3d1                	bnez	a5,80004680 <exec+0x2ea>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800046fe:	e1c42503          	lw	a0,-484(s0)
    80004702:	00000097          	auipc	ra,0x0
    80004706:	c78080e7          	jalr	-904(ra) # 8000437a <flags2perm>
    8000470a:	86aa                	mv	a3,a0
    8000470c:	864a                	mv	a2,s2
    8000470e:	85d2                	mv	a1,s4
    80004710:	855e                	mv	a0,s7
    80004712:	ffffc097          	auipc	ra,0xffffc
    80004716:	3d0080e7          	jalr	976(ra) # 80000ae2 <uvmalloc>
    8000471a:	e0a43423          	sd	a0,-504(s0)
    8000471e:	d525                	beqz	a0,80004686 <exec+0x2f0>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004720:	e2843d03          	ld	s10,-472(s0)
    80004724:	e2042d83          	lw	s11,-480(s0)
    80004728:	e3842c03          	lw	s8,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000472c:	f60c0ce3          	beqz	s8,800046a4 <exec+0x30e>
    80004730:	8a62                	mv	s4,s8
    80004732:	4901                	li	s2,0
    80004734:	b369                	j	800044be <exec+0x128>

0000000080004736 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004736:	7179                	addi	sp,sp,-48
    80004738:	f406                	sd	ra,40(sp)
    8000473a:	f022                	sd	s0,32(sp)
    8000473c:	ec26                	sd	s1,24(sp)
    8000473e:	e84a                	sd	s2,16(sp)
    80004740:	1800                	addi	s0,sp,48
    80004742:	892e                	mv	s2,a1
    80004744:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004746:	fdc40593          	addi	a1,s0,-36
    8000474a:	ffffe097          	auipc	ra,0xffffe
    8000474e:	bbc080e7          	jalr	-1092(ra) # 80002306 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004752:	fdc42703          	lw	a4,-36(s0)
    80004756:	47bd                	li	a5,15
    80004758:	02e7eb63          	bltu	a5,a4,8000478e <argfd+0x58>
    8000475c:	ffffd097          	auipc	ra,0xffffd
    80004760:	9ae080e7          	jalr	-1618(ra) # 8000110a <myproc>
    80004764:	fdc42703          	lw	a4,-36(s0)
    80004768:	01a70793          	addi	a5,a4,26
    8000476c:	078e                	slli	a5,a5,0x3
    8000476e:	953e                	add	a0,a0,a5
    80004770:	611c                	ld	a5,0(a0)
    80004772:	c385                	beqz	a5,80004792 <argfd+0x5c>
    return -1;
  if(pfd)
    80004774:	00090463          	beqz	s2,8000477c <argfd+0x46>
    *pfd = fd;
    80004778:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000477c:	4501                	li	a0,0
  if(pf)
    8000477e:	c091                	beqz	s1,80004782 <argfd+0x4c>
    *pf = f;
    80004780:	e09c                	sd	a5,0(s1)
}
    80004782:	70a2                	ld	ra,40(sp)
    80004784:	7402                	ld	s0,32(sp)
    80004786:	64e2                	ld	s1,24(sp)
    80004788:	6942                	ld	s2,16(sp)
    8000478a:	6145                	addi	sp,sp,48
    8000478c:	8082                	ret
    return -1;
    8000478e:	557d                	li	a0,-1
    80004790:	bfcd                	j	80004782 <argfd+0x4c>
    80004792:	557d                	li	a0,-1
    80004794:	b7fd                	j	80004782 <argfd+0x4c>

0000000080004796 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004796:	1101                	addi	sp,sp,-32
    80004798:	ec06                	sd	ra,24(sp)
    8000479a:	e822                	sd	s0,16(sp)
    8000479c:	e426                	sd	s1,8(sp)
    8000479e:	1000                	addi	s0,sp,32
    800047a0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800047a2:	ffffd097          	auipc	ra,0xffffd
    800047a6:	968080e7          	jalr	-1688(ra) # 8000110a <myproc>
    800047aa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800047ac:	0d050793          	addi	a5,a0,208 # fffffffffffff0d0 <end+0xffffffff7fdbd320>
    800047b0:	4501                	li	a0,0
    800047b2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800047b4:	6398                	ld	a4,0(a5)
    800047b6:	cb19                	beqz	a4,800047cc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800047b8:	2505                	addiw	a0,a0,1
    800047ba:	07a1                	addi	a5,a5,8
    800047bc:	fed51ce3          	bne	a0,a3,800047b4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800047c0:	557d                	li	a0,-1
}
    800047c2:	60e2                	ld	ra,24(sp)
    800047c4:	6442                	ld	s0,16(sp)
    800047c6:	64a2                	ld	s1,8(sp)
    800047c8:	6105                	addi	sp,sp,32
    800047ca:	8082                	ret
      p->ofile[fd] = f;
    800047cc:	01a50793          	addi	a5,a0,26
    800047d0:	078e                	slli	a5,a5,0x3
    800047d2:	963e                	add	a2,a2,a5
    800047d4:	e204                	sd	s1,0(a2)
      return fd;
    800047d6:	b7f5                	j	800047c2 <fdalloc+0x2c>

00000000800047d8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800047d8:	715d                	addi	sp,sp,-80
    800047da:	e486                	sd	ra,72(sp)
    800047dc:	e0a2                	sd	s0,64(sp)
    800047de:	fc26                	sd	s1,56(sp)
    800047e0:	f84a                	sd	s2,48(sp)
    800047e2:	f44e                	sd	s3,40(sp)
    800047e4:	f052                	sd	s4,32(sp)
    800047e6:	ec56                	sd	s5,24(sp)
    800047e8:	e85a                	sd	s6,16(sp)
    800047ea:	0880                	addi	s0,sp,80
    800047ec:	8b2e                	mv	s6,a1
    800047ee:	89b2                	mv	s3,a2
    800047f0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800047f2:	fb040593          	addi	a1,s0,-80
    800047f6:	fffff097          	auipc	ra,0xfffff
    800047fa:	e4e080e7          	jalr	-434(ra) # 80003644 <nameiparent>
    800047fe:	84aa                	mv	s1,a0
    80004800:	16050063          	beqz	a0,80004960 <create+0x188>
    return 0;

  ilock(dp);
    80004804:	ffffe097          	auipc	ra,0xffffe
    80004808:	67c080e7          	jalr	1660(ra) # 80002e80 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000480c:	4601                	li	a2,0
    8000480e:	fb040593          	addi	a1,s0,-80
    80004812:	8526                	mv	a0,s1
    80004814:	fffff097          	auipc	ra,0xfffff
    80004818:	b50080e7          	jalr	-1200(ra) # 80003364 <dirlookup>
    8000481c:	8aaa                	mv	s5,a0
    8000481e:	c931                	beqz	a0,80004872 <create+0x9a>
    iunlockput(dp);
    80004820:	8526                	mv	a0,s1
    80004822:	fffff097          	auipc	ra,0xfffff
    80004826:	8c0080e7          	jalr	-1856(ra) # 800030e2 <iunlockput>
    ilock(ip);
    8000482a:	8556                	mv	a0,s5
    8000482c:	ffffe097          	auipc	ra,0xffffe
    80004830:	654080e7          	jalr	1620(ra) # 80002e80 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004834:	000b059b          	sext.w	a1,s6
    80004838:	4789                	li	a5,2
    8000483a:	02f59563          	bne	a1,a5,80004864 <create+0x8c>
    8000483e:	044ad783          	lhu	a5,68(s5)
    80004842:	37f9                	addiw	a5,a5,-2
    80004844:	17c2                	slli	a5,a5,0x30
    80004846:	93c1                	srli	a5,a5,0x30
    80004848:	4705                	li	a4,1
    8000484a:	00f76d63          	bltu	a4,a5,80004864 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000484e:	8556                	mv	a0,s5
    80004850:	60a6                	ld	ra,72(sp)
    80004852:	6406                	ld	s0,64(sp)
    80004854:	74e2                	ld	s1,56(sp)
    80004856:	7942                	ld	s2,48(sp)
    80004858:	79a2                	ld	s3,40(sp)
    8000485a:	7a02                	ld	s4,32(sp)
    8000485c:	6ae2                	ld	s5,24(sp)
    8000485e:	6b42                	ld	s6,16(sp)
    80004860:	6161                	addi	sp,sp,80
    80004862:	8082                	ret
    iunlockput(ip);
    80004864:	8556                	mv	a0,s5
    80004866:	fffff097          	auipc	ra,0xfffff
    8000486a:	87c080e7          	jalr	-1924(ra) # 800030e2 <iunlockput>
    return 0;
    8000486e:	4a81                	li	s5,0
    80004870:	bff9                	j	8000484e <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004872:	85da                	mv	a1,s6
    80004874:	4088                	lw	a0,0(s1)
    80004876:	ffffe097          	auipc	ra,0xffffe
    8000487a:	46e080e7          	jalr	1134(ra) # 80002ce4 <ialloc>
    8000487e:	8a2a                	mv	s4,a0
    80004880:	c921                	beqz	a0,800048d0 <create+0xf8>
  ilock(ip);
    80004882:	ffffe097          	auipc	ra,0xffffe
    80004886:	5fe080e7          	jalr	1534(ra) # 80002e80 <ilock>
  ip->major = major;
    8000488a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000488e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80004892:	4785                	li	a5,1
    80004894:	04fa1523          	sh	a5,74(s4)
  iupdate(ip);
    80004898:	8552                	mv	a0,s4
    8000489a:	ffffe097          	auipc	ra,0xffffe
    8000489e:	51c080e7          	jalr	1308(ra) # 80002db6 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800048a2:	000b059b          	sext.w	a1,s6
    800048a6:	4785                	li	a5,1
    800048a8:	02f58b63          	beq	a1,a5,800048de <create+0x106>
  if(dirlink(dp, name, ip->inum) < 0)
    800048ac:	004a2603          	lw	a2,4(s4)
    800048b0:	fb040593          	addi	a1,s0,-80
    800048b4:	8526                	mv	a0,s1
    800048b6:	fffff097          	auipc	ra,0xfffff
    800048ba:	cbe080e7          	jalr	-834(ra) # 80003574 <dirlink>
    800048be:	06054f63          	bltz	a0,8000493c <create+0x164>
  iunlockput(dp);
    800048c2:	8526                	mv	a0,s1
    800048c4:	fffff097          	auipc	ra,0xfffff
    800048c8:	81e080e7          	jalr	-2018(ra) # 800030e2 <iunlockput>
  return ip;
    800048cc:	8ad2                	mv	s5,s4
    800048ce:	b741                	j	8000484e <create+0x76>
    iunlockput(dp);
    800048d0:	8526                	mv	a0,s1
    800048d2:	fffff097          	auipc	ra,0xfffff
    800048d6:	810080e7          	jalr	-2032(ra) # 800030e2 <iunlockput>
    return 0;
    800048da:	8ad2                	mv	s5,s4
    800048dc:	bf8d                	j	8000484e <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800048de:	004a2603          	lw	a2,4(s4)
    800048e2:	00004597          	auipc	a1,0x4
    800048e6:	dce58593          	addi	a1,a1,-562 # 800086b0 <syscalls+0x2a0>
    800048ea:	8552                	mv	a0,s4
    800048ec:	fffff097          	auipc	ra,0xfffff
    800048f0:	c88080e7          	jalr	-888(ra) # 80003574 <dirlink>
    800048f4:	04054463          	bltz	a0,8000493c <create+0x164>
    800048f8:	40d0                	lw	a2,4(s1)
    800048fa:	00004597          	auipc	a1,0x4
    800048fe:	dbe58593          	addi	a1,a1,-578 # 800086b8 <syscalls+0x2a8>
    80004902:	8552                	mv	a0,s4
    80004904:	fffff097          	auipc	ra,0xfffff
    80004908:	c70080e7          	jalr	-912(ra) # 80003574 <dirlink>
    8000490c:	02054863          	bltz	a0,8000493c <create+0x164>
  if(dirlink(dp, name, ip->inum) < 0)
    80004910:	004a2603          	lw	a2,4(s4)
    80004914:	fb040593          	addi	a1,s0,-80
    80004918:	8526                	mv	a0,s1
    8000491a:	fffff097          	auipc	ra,0xfffff
    8000491e:	c5a080e7          	jalr	-934(ra) # 80003574 <dirlink>
    80004922:	00054d63          	bltz	a0,8000493c <create+0x164>
    dp->nlink++;  // for ".."
    80004926:	04a4d783          	lhu	a5,74(s1)
    8000492a:	2785                	addiw	a5,a5,1
    8000492c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004930:	8526                	mv	a0,s1
    80004932:	ffffe097          	auipc	ra,0xffffe
    80004936:	484080e7          	jalr	1156(ra) # 80002db6 <iupdate>
    8000493a:	b761                	j	800048c2 <create+0xea>
  ip->nlink = 0;
    8000493c:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004940:	8552                	mv	a0,s4
    80004942:	ffffe097          	auipc	ra,0xffffe
    80004946:	474080e7          	jalr	1140(ra) # 80002db6 <iupdate>
  iunlockput(ip);
    8000494a:	8552                	mv	a0,s4
    8000494c:	ffffe097          	auipc	ra,0xffffe
    80004950:	796080e7          	jalr	1942(ra) # 800030e2 <iunlockput>
  iunlockput(dp);
    80004954:	8526                	mv	a0,s1
    80004956:	ffffe097          	auipc	ra,0xffffe
    8000495a:	78c080e7          	jalr	1932(ra) # 800030e2 <iunlockput>
  return 0;
    8000495e:	bdc5                	j	8000484e <create+0x76>
    return 0;
    80004960:	8aaa                	mv	s5,a0
    80004962:	b5f5                	j	8000484e <create+0x76>

0000000080004964 <sys_dup>:
{
    80004964:	7179                	addi	sp,sp,-48
    80004966:	f406                	sd	ra,40(sp)
    80004968:	f022                	sd	s0,32(sp)
    8000496a:	ec26                	sd	s1,24(sp)
    8000496c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000496e:	fd840613          	addi	a2,s0,-40
    80004972:	4581                	li	a1,0
    80004974:	4501                	li	a0,0
    80004976:	00000097          	auipc	ra,0x0
    8000497a:	dc0080e7          	jalr	-576(ra) # 80004736 <argfd>
    return -1;
    8000497e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004980:	02054363          	bltz	a0,800049a6 <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    80004984:	fd843503          	ld	a0,-40(s0)
    80004988:	00000097          	auipc	ra,0x0
    8000498c:	e0e080e7          	jalr	-498(ra) # 80004796 <fdalloc>
    80004990:	84aa                	mv	s1,a0
    return -1;
    80004992:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004994:	00054963          	bltz	a0,800049a6 <sys_dup+0x42>
  filedup(f);
    80004998:	fd843503          	ld	a0,-40(s0)
    8000499c:	fffff097          	auipc	ra,0xfffff
    800049a0:	320080e7          	jalr	800(ra) # 80003cbc <filedup>
  return fd;
    800049a4:	87a6                	mv	a5,s1
}
    800049a6:	853e                	mv	a0,a5
    800049a8:	70a2                	ld	ra,40(sp)
    800049aa:	7402                	ld	s0,32(sp)
    800049ac:	64e2                	ld	s1,24(sp)
    800049ae:	6145                	addi	sp,sp,48
    800049b0:	8082                	ret

00000000800049b2 <sys_read>:
{
    800049b2:	7179                	addi	sp,sp,-48
    800049b4:	f406                	sd	ra,40(sp)
    800049b6:	f022                	sd	s0,32(sp)
    800049b8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800049ba:	fd840593          	addi	a1,s0,-40
    800049be:	4505                	li	a0,1
    800049c0:	ffffe097          	auipc	ra,0xffffe
    800049c4:	966080e7          	jalr	-1690(ra) # 80002326 <argaddr>
  argint(2, &n);
    800049c8:	fe440593          	addi	a1,s0,-28
    800049cc:	4509                	li	a0,2
    800049ce:	ffffe097          	auipc	ra,0xffffe
    800049d2:	938080e7          	jalr	-1736(ra) # 80002306 <argint>
  if(argfd(0, 0, &f) < 0)
    800049d6:	fe840613          	addi	a2,s0,-24
    800049da:	4581                	li	a1,0
    800049dc:	4501                	li	a0,0
    800049de:	00000097          	auipc	ra,0x0
    800049e2:	d58080e7          	jalr	-680(ra) # 80004736 <argfd>
    800049e6:	87aa                	mv	a5,a0
    return -1;
    800049e8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800049ea:	0007cc63          	bltz	a5,80004a02 <sys_read+0x50>
  return fileread(f, p, n);
    800049ee:	fe442603          	lw	a2,-28(s0)
    800049f2:	fd843583          	ld	a1,-40(s0)
    800049f6:	fe843503          	ld	a0,-24(s0)
    800049fa:	fffff097          	auipc	ra,0xfffff
    800049fe:	44e080e7          	jalr	1102(ra) # 80003e48 <fileread>
}
    80004a02:	70a2                	ld	ra,40(sp)
    80004a04:	7402                	ld	s0,32(sp)
    80004a06:	6145                	addi	sp,sp,48
    80004a08:	8082                	ret

0000000080004a0a <sys_write>:
{
    80004a0a:	7179                	addi	sp,sp,-48
    80004a0c:	f406                	sd	ra,40(sp)
    80004a0e:	f022                	sd	s0,32(sp)
    80004a10:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004a12:	fd840593          	addi	a1,s0,-40
    80004a16:	4505                	li	a0,1
    80004a18:	ffffe097          	auipc	ra,0xffffe
    80004a1c:	90e080e7          	jalr	-1778(ra) # 80002326 <argaddr>
  argint(2, &n);
    80004a20:	fe440593          	addi	a1,s0,-28
    80004a24:	4509                	li	a0,2
    80004a26:	ffffe097          	auipc	ra,0xffffe
    80004a2a:	8e0080e7          	jalr	-1824(ra) # 80002306 <argint>
  if(argfd(0, 0, &f) < 0)
    80004a2e:	fe840613          	addi	a2,s0,-24
    80004a32:	4581                	li	a1,0
    80004a34:	4501                	li	a0,0
    80004a36:	00000097          	auipc	ra,0x0
    80004a3a:	d00080e7          	jalr	-768(ra) # 80004736 <argfd>
    80004a3e:	87aa                	mv	a5,a0
    return -1;
    80004a40:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004a42:	0007cc63          	bltz	a5,80004a5a <sys_write+0x50>
  return filewrite(f, p, n);
    80004a46:	fe442603          	lw	a2,-28(s0)
    80004a4a:	fd843583          	ld	a1,-40(s0)
    80004a4e:	fe843503          	ld	a0,-24(s0)
    80004a52:	fffff097          	auipc	ra,0xfffff
    80004a56:	4b8080e7          	jalr	1208(ra) # 80003f0a <filewrite>
}
    80004a5a:	70a2                	ld	ra,40(sp)
    80004a5c:	7402                	ld	s0,32(sp)
    80004a5e:	6145                	addi	sp,sp,48
    80004a60:	8082                	ret

0000000080004a62 <sys_close>:
{
    80004a62:	1101                	addi	sp,sp,-32
    80004a64:	ec06                	sd	ra,24(sp)
    80004a66:	e822                	sd	s0,16(sp)
    80004a68:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004a6a:	fe040613          	addi	a2,s0,-32
    80004a6e:	fec40593          	addi	a1,s0,-20
    80004a72:	4501                	li	a0,0
    80004a74:	00000097          	auipc	ra,0x0
    80004a78:	cc2080e7          	jalr	-830(ra) # 80004736 <argfd>
    return -1;
    80004a7c:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004a7e:	02054463          	bltz	a0,80004aa6 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80004a82:	ffffc097          	auipc	ra,0xffffc
    80004a86:	688080e7          	jalr	1672(ra) # 8000110a <myproc>
    80004a8a:	fec42783          	lw	a5,-20(s0)
    80004a8e:	07e9                	addi	a5,a5,26
    80004a90:	078e                	slli	a5,a5,0x3
    80004a92:	97aa                	add	a5,a5,a0
    80004a94:	0007b023          	sd	zero,0(a5)
  fileclose(f);
    80004a98:	fe043503          	ld	a0,-32(s0)
    80004a9c:	fffff097          	auipc	ra,0xfffff
    80004aa0:	272080e7          	jalr	626(ra) # 80003d0e <fileclose>
  return 0;
    80004aa4:	4781                	li	a5,0
}
    80004aa6:	853e                	mv	a0,a5
    80004aa8:	60e2                	ld	ra,24(sp)
    80004aaa:	6442                	ld	s0,16(sp)
    80004aac:	6105                	addi	sp,sp,32
    80004aae:	8082                	ret

0000000080004ab0 <sys_fstat>:
{
    80004ab0:	1101                	addi	sp,sp,-32
    80004ab2:	ec06                	sd	ra,24(sp)
    80004ab4:	e822                	sd	s0,16(sp)
    80004ab6:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004ab8:	fe040593          	addi	a1,s0,-32
    80004abc:	4505                	li	a0,1
    80004abe:	ffffe097          	auipc	ra,0xffffe
    80004ac2:	868080e7          	jalr	-1944(ra) # 80002326 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004ac6:	fe840613          	addi	a2,s0,-24
    80004aca:	4581                	li	a1,0
    80004acc:	4501                	li	a0,0
    80004ace:	00000097          	auipc	ra,0x0
    80004ad2:	c68080e7          	jalr	-920(ra) # 80004736 <argfd>
    80004ad6:	87aa                	mv	a5,a0
    return -1;
    80004ad8:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004ada:	0007ca63          	bltz	a5,80004aee <sys_fstat+0x3e>
  return filestat(f, st);
    80004ade:	fe043583          	ld	a1,-32(s0)
    80004ae2:	fe843503          	ld	a0,-24(s0)
    80004ae6:	fffff097          	auipc	ra,0xfffff
    80004aea:	2f0080e7          	jalr	752(ra) # 80003dd6 <filestat>
}
    80004aee:	60e2                	ld	ra,24(sp)
    80004af0:	6442                	ld	s0,16(sp)
    80004af2:	6105                	addi	sp,sp,32
    80004af4:	8082                	ret

0000000080004af6 <sys_link>:
{
    80004af6:	7169                	addi	sp,sp,-304
    80004af8:	f606                	sd	ra,296(sp)
    80004afa:	f222                	sd	s0,288(sp)
    80004afc:	ee26                	sd	s1,280(sp)
    80004afe:	ea4a                	sd	s2,272(sp)
    80004b00:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b02:	08000613          	li	a2,128
    80004b06:	ed040593          	addi	a1,s0,-304
    80004b0a:	4501                	li	a0,0
    80004b0c:	ffffe097          	auipc	ra,0xffffe
    80004b10:	83a080e7          	jalr	-1990(ra) # 80002346 <argstr>
    return -1;
    80004b14:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b16:	10054e63          	bltz	a0,80004c32 <sys_link+0x13c>
    80004b1a:	08000613          	li	a2,128
    80004b1e:	f5040593          	addi	a1,s0,-176
    80004b22:	4505                	li	a0,1
    80004b24:	ffffe097          	auipc	ra,0xffffe
    80004b28:	822080e7          	jalr	-2014(ra) # 80002346 <argstr>
    return -1;
    80004b2c:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004b2e:	10054263          	bltz	a0,80004c32 <sys_link+0x13c>
  begin_op();
    80004b32:	fffff097          	auipc	ra,0xfffff
    80004b36:	d10080e7          	jalr	-752(ra) # 80003842 <begin_op>
  if((ip = namei(old)) == 0){
    80004b3a:	ed040513          	addi	a0,s0,-304
    80004b3e:	fffff097          	auipc	ra,0xfffff
    80004b42:	ae8080e7          	jalr	-1304(ra) # 80003626 <namei>
    80004b46:	84aa                	mv	s1,a0
    80004b48:	c551                	beqz	a0,80004bd4 <sys_link+0xde>
  ilock(ip);
    80004b4a:	ffffe097          	auipc	ra,0xffffe
    80004b4e:	336080e7          	jalr	822(ra) # 80002e80 <ilock>
  if(ip->type == T_DIR){
    80004b52:	04449703          	lh	a4,68(s1)
    80004b56:	4785                	li	a5,1
    80004b58:	08f70463          	beq	a4,a5,80004be0 <sys_link+0xea>
  ip->nlink++;
    80004b5c:	04a4d783          	lhu	a5,74(s1)
    80004b60:	2785                	addiw	a5,a5,1
    80004b62:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b66:	8526                	mv	a0,s1
    80004b68:	ffffe097          	auipc	ra,0xffffe
    80004b6c:	24e080e7          	jalr	590(ra) # 80002db6 <iupdate>
  iunlock(ip);
    80004b70:	8526                	mv	a0,s1
    80004b72:	ffffe097          	auipc	ra,0xffffe
    80004b76:	3d0080e7          	jalr	976(ra) # 80002f42 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004b7a:	fd040593          	addi	a1,s0,-48
    80004b7e:	f5040513          	addi	a0,s0,-176
    80004b82:	fffff097          	auipc	ra,0xfffff
    80004b86:	ac2080e7          	jalr	-1342(ra) # 80003644 <nameiparent>
    80004b8a:	892a                	mv	s2,a0
    80004b8c:	c935                	beqz	a0,80004c00 <sys_link+0x10a>
  ilock(dp);
    80004b8e:	ffffe097          	auipc	ra,0xffffe
    80004b92:	2f2080e7          	jalr	754(ra) # 80002e80 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004b96:	00092703          	lw	a4,0(s2)
    80004b9a:	409c                	lw	a5,0(s1)
    80004b9c:	04f71d63          	bne	a4,a5,80004bf6 <sys_link+0x100>
    80004ba0:	40d0                	lw	a2,4(s1)
    80004ba2:	fd040593          	addi	a1,s0,-48
    80004ba6:	854a                	mv	a0,s2
    80004ba8:	fffff097          	auipc	ra,0xfffff
    80004bac:	9cc080e7          	jalr	-1588(ra) # 80003574 <dirlink>
    80004bb0:	04054363          	bltz	a0,80004bf6 <sys_link+0x100>
  iunlockput(dp);
    80004bb4:	854a                	mv	a0,s2
    80004bb6:	ffffe097          	auipc	ra,0xffffe
    80004bba:	52c080e7          	jalr	1324(ra) # 800030e2 <iunlockput>
  iput(ip);
    80004bbe:	8526                	mv	a0,s1
    80004bc0:	ffffe097          	auipc	ra,0xffffe
    80004bc4:	47a080e7          	jalr	1146(ra) # 8000303a <iput>
  end_op();
    80004bc8:	fffff097          	auipc	ra,0xfffff
    80004bcc:	cfa080e7          	jalr	-774(ra) # 800038c2 <end_op>
  return 0;
    80004bd0:	4781                	li	a5,0
    80004bd2:	a085                	j	80004c32 <sys_link+0x13c>
    end_op();
    80004bd4:	fffff097          	auipc	ra,0xfffff
    80004bd8:	cee080e7          	jalr	-786(ra) # 800038c2 <end_op>
    return -1;
    80004bdc:	57fd                	li	a5,-1
    80004bde:	a891                	j	80004c32 <sys_link+0x13c>
    iunlockput(ip);
    80004be0:	8526                	mv	a0,s1
    80004be2:	ffffe097          	auipc	ra,0xffffe
    80004be6:	500080e7          	jalr	1280(ra) # 800030e2 <iunlockput>
    end_op();
    80004bea:	fffff097          	auipc	ra,0xfffff
    80004bee:	cd8080e7          	jalr	-808(ra) # 800038c2 <end_op>
    return -1;
    80004bf2:	57fd                	li	a5,-1
    80004bf4:	a83d                	j	80004c32 <sys_link+0x13c>
    iunlockput(dp);
    80004bf6:	854a                	mv	a0,s2
    80004bf8:	ffffe097          	auipc	ra,0xffffe
    80004bfc:	4ea080e7          	jalr	1258(ra) # 800030e2 <iunlockput>
  ilock(ip);
    80004c00:	8526                	mv	a0,s1
    80004c02:	ffffe097          	auipc	ra,0xffffe
    80004c06:	27e080e7          	jalr	638(ra) # 80002e80 <ilock>
  ip->nlink--;
    80004c0a:	04a4d783          	lhu	a5,74(s1)
    80004c0e:	37fd                	addiw	a5,a5,-1
    80004c10:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c14:	8526                	mv	a0,s1
    80004c16:	ffffe097          	auipc	ra,0xffffe
    80004c1a:	1a0080e7          	jalr	416(ra) # 80002db6 <iupdate>
  iunlockput(ip);
    80004c1e:	8526                	mv	a0,s1
    80004c20:	ffffe097          	auipc	ra,0xffffe
    80004c24:	4c2080e7          	jalr	1218(ra) # 800030e2 <iunlockput>
  end_op();
    80004c28:	fffff097          	auipc	ra,0xfffff
    80004c2c:	c9a080e7          	jalr	-870(ra) # 800038c2 <end_op>
  return -1;
    80004c30:	57fd                	li	a5,-1
}
    80004c32:	853e                	mv	a0,a5
    80004c34:	70b2                	ld	ra,296(sp)
    80004c36:	7412                	ld	s0,288(sp)
    80004c38:	64f2                	ld	s1,280(sp)
    80004c3a:	6952                	ld	s2,272(sp)
    80004c3c:	6155                	addi	sp,sp,304
    80004c3e:	8082                	ret

0000000080004c40 <sys_unlink>:
{
    80004c40:	7151                	addi	sp,sp,-240
    80004c42:	f586                	sd	ra,232(sp)
    80004c44:	f1a2                	sd	s0,224(sp)
    80004c46:	eda6                	sd	s1,216(sp)
    80004c48:	e9ca                	sd	s2,208(sp)
    80004c4a:	e5ce                	sd	s3,200(sp)
    80004c4c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004c4e:	08000613          	li	a2,128
    80004c52:	f3040593          	addi	a1,s0,-208
    80004c56:	4501                	li	a0,0
    80004c58:	ffffd097          	auipc	ra,0xffffd
    80004c5c:	6ee080e7          	jalr	1774(ra) # 80002346 <argstr>
    80004c60:	18054163          	bltz	a0,80004de2 <sys_unlink+0x1a2>
  begin_op();
    80004c64:	fffff097          	auipc	ra,0xfffff
    80004c68:	bde080e7          	jalr	-1058(ra) # 80003842 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004c6c:	fb040593          	addi	a1,s0,-80
    80004c70:	f3040513          	addi	a0,s0,-208
    80004c74:	fffff097          	auipc	ra,0xfffff
    80004c78:	9d0080e7          	jalr	-1584(ra) # 80003644 <nameiparent>
    80004c7c:	84aa                	mv	s1,a0
    80004c7e:	c979                	beqz	a0,80004d54 <sys_unlink+0x114>
  ilock(dp);
    80004c80:	ffffe097          	auipc	ra,0xffffe
    80004c84:	200080e7          	jalr	512(ra) # 80002e80 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004c88:	00004597          	auipc	a1,0x4
    80004c8c:	a2858593          	addi	a1,a1,-1496 # 800086b0 <syscalls+0x2a0>
    80004c90:	fb040513          	addi	a0,s0,-80
    80004c94:	ffffe097          	auipc	ra,0xffffe
    80004c98:	6b6080e7          	jalr	1718(ra) # 8000334a <namecmp>
    80004c9c:	14050a63          	beqz	a0,80004df0 <sys_unlink+0x1b0>
    80004ca0:	00004597          	auipc	a1,0x4
    80004ca4:	a1858593          	addi	a1,a1,-1512 # 800086b8 <syscalls+0x2a8>
    80004ca8:	fb040513          	addi	a0,s0,-80
    80004cac:	ffffe097          	auipc	ra,0xffffe
    80004cb0:	69e080e7          	jalr	1694(ra) # 8000334a <namecmp>
    80004cb4:	12050e63          	beqz	a0,80004df0 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004cb8:	f2c40613          	addi	a2,s0,-212
    80004cbc:	fb040593          	addi	a1,s0,-80
    80004cc0:	8526                	mv	a0,s1
    80004cc2:	ffffe097          	auipc	ra,0xffffe
    80004cc6:	6a2080e7          	jalr	1698(ra) # 80003364 <dirlookup>
    80004cca:	892a                	mv	s2,a0
    80004ccc:	12050263          	beqz	a0,80004df0 <sys_unlink+0x1b0>
  ilock(ip);
    80004cd0:	ffffe097          	auipc	ra,0xffffe
    80004cd4:	1b0080e7          	jalr	432(ra) # 80002e80 <ilock>
  if(ip->nlink < 1)
    80004cd8:	04a91783          	lh	a5,74(s2)
    80004cdc:	08f05263          	blez	a5,80004d60 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004ce0:	04491703          	lh	a4,68(s2)
    80004ce4:	4785                	li	a5,1
    80004ce6:	08f70563          	beq	a4,a5,80004d70 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004cea:	4641                	li	a2,16
    80004cec:	4581                	li	a1,0
    80004cee:	fc040513          	addi	a0,s0,-64
    80004cf2:	ffffb097          	auipc	ra,0xffffb
    80004cf6:	6aa080e7          	jalr	1706(ra) # 8000039c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004cfa:	4741                	li	a4,16
    80004cfc:	f2c42683          	lw	a3,-212(s0)
    80004d00:	fc040613          	addi	a2,s0,-64
    80004d04:	4581                	li	a1,0
    80004d06:	8526                	mv	a0,s1
    80004d08:	ffffe097          	auipc	ra,0xffffe
    80004d0c:	524080e7          	jalr	1316(ra) # 8000322c <writei>
    80004d10:	47c1                	li	a5,16
    80004d12:	0af51563          	bne	a0,a5,80004dbc <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80004d16:	04491703          	lh	a4,68(s2)
    80004d1a:	4785                	li	a5,1
    80004d1c:	0af70863          	beq	a4,a5,80004dcc <sys_unlink+0x18c>
  iunlockput(dp);
    80004d20:	8526                	mv	a0,s1
    80004d22:	ffffe097          	auipc	ra,0xffffe
    80004d26:	3c0080e7          	jalr	960(ra) # 800030e2 <iunlockput>
  ip->nlink--;
    80004d2a:	04a95783          	lhu	a5,74(s2)
    80004d2e:	37fd                	addiw	a5,a5,-1
    80004d30:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004d34:	854a                	mv	a0,s2
    80004d36:	ffffe097          	auipc	ra,0xffffe
    80004d3a:	080080e7          	jalr	128(ra) # 80002db6 <iupdate>
  iunlockput(ip);
    80004d3e:	854a                	mv	a0,s2
    80004d40:	ffffe097          	auipc	ra,0xffffe
    80004d44:	3a2080e7          	jalr	930(ra) # 800030e2 <iunlockput>
  end_op();
    80004d48:	fffff097          	auipc	ra,0xfffff
    80004d4c:	b7a080e7          	jalr	-1158(ra) # 800038c2 <end_op>
  return 0;
    80004d50:	4501                	li	a0,0
    80004d52:	a84d                	j	80004e04 <sys_unlink+0x1c4>
    end_op();
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	b6e080e7          	jalr	-1170(ra) # 800038c2 <end_op>
    return -1;
    80004d5c:	557d                	li	a0,-1
    80004d5e:	a05d                	j	80004e04 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80004d60:	00004517          	auipc	a0,0x4
    80004d64:	96050513          	addi	a0,a0,-1696 # 800086c0 <syscalls+0x2b0>
    80004d68:	00001097          	auipc	ra,0x1
    80004d6c:	21a080e7          	jalr	538(ra) # 80005f82 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004d70:	04c92703          	lw	a4,76(s2)
    80004d74:	02000793          	li	a5,32
    80004d78:	f6e7f9e3          	bgeu	a5,a4,80004cea <sys_unlink+0xaa>
    80004d7c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d80:	4741                	li	a4,16
    80004d82:	86ce                	mv	a3,s3
    80004d84:	f1840613          	addi	a2,s0,-232
    80004d88:	4581                	li	a1,0
    80004d8a:	854a                	mv	a0,s2
    80004d8c:	ffffe097          	auipc	ra,0xffffe
    80004d90:	3a8080e7          	jalr	936(ra) # 80003134 <readi>
    80004d94:	47c1                	li	a5,16
    80004d96:	00f51b63          	bne	a0,a5,80004dac <sys_unlink+0x16c>
    if(de.inum != 0)
    80004d9a:	f1845783          	lhu	a5,-232(s0)
    80004d9e:	e7a1                	bnez	a5,80004de6 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004da0:	29c1                	addiw	s3,s3,16
    80004da2:	04c92783          	lw	a5,76(s2)
    80004da6:	fcf9ede3          	bltu	s3,a5,80004d80 <sys_unlink+0x140>
    80004daa:	b781                	j	80004cea <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004dac:	00004517          	auipc	a0,0x4
    80004db0:	92c50513          	addi	a0,a0,-1748 # 800086d8 <syscalls+0x2c8>
    80004db4:	00001097          	auipc	ra,0x1
    80004db8:	1ce080e7          	jalr	462(ra) # 80005f82 <panic>
    panic("unlink: writei");
    80004dbc:	00004517          	auipc	a0,0x4
    80004dc0:	93450513          	addi	a0,a0,-1740 # 800086f0 <syscalls+0x2e0>
    80004dc4:	00001097          	auipc	ra,0x1
    80004dc8:	1be080e7          	jalr	446(ra) # 80005f82 <panic>
    dp->nlink--;
    80004dcc:	04a4d783          	lhu	a5,74(s1)
    80004dd0:	37fd                	addiw	a5,a5,-1
    80004dd2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004dd6:	8526                	mv	a0,s1
    80004dd8:	ffffe097          	auipc	ra,0xffffe
    80004ddc:	fde080e7          	jalr	-34(ra) # 80002db6 <iupdate>
    80004de0:	b781                	j	80004d20 <sys_unlink+0xe0>
    return -1;
    80004de2:	557d                	li	a0,-1
    80004de4:	a005                	j	80004e04 <sys_unlink+0x1c4>
    iunlockput(ip);
    80004de6:	854a                	mv	a0,s2
    80004de8:	ffffe097          	auipc	ra,0xffffe
    80004dec:	2fa080e7          	jalr	762(ra) # 800030e2 <iunlockput>
  iunlockput(dp);
    80004df0:	8526                	mv	a0,s1
    80004df2:	ffffe097          	auipc	ra,0xffffe
    80004df6:	2f0080e7          	jalr	752(ra) # 800030e2 <iunlockput>
  end_op();
    80004dfa:	fffff097          	auipc	ra,0xfffff
    80004dfe:	ac8080e7          	jalr	-1336(ra) # 800038c2 <end_op>
  return -1;
    80004e02:	557d                	li	a0,-1
}
    80004e04:	70ae                	ld	ra,232(sp)
    80004e06:	740e                	ld	s0,224(sp)
    80004e08:	64ee                	ld	s1,216(sp)
    80004e0a:	694e                	ld	s2,208(sp)
    80004e0c:	69ae                	ld	s3,200(sp)
    80004e0e:	616d                	addi	sp,sp,240
    80004e10:	8082                	ret

0000000080004e12 <sys_open>:

uint64
sys_open(void)
{
    80004e12:	7131                	addi	sp,sp,-192
    80004e14:	fd06                	sd	ra,184(sp)
    80004e16:	f922                	sd	s0,176(sp)
    80004e18:	f526                	sd	s1,168(sp)
    80004e1a:	f14a                	sd	s2,160(sp)
    80004e1c:	ed4e                	sd	s3,152(sp)
    80004e1e:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004e20:	f4c40593          	addi	a1,s0,-180
    80004e24:	4505                	li	a0,1
    80004e26:	ffffd097          	auipc	ra,0xffffd
    80004e2a:	4e0080e7          	jalr	1248(ra) # 80002306 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e2e:	08000613          	li	a2,128
    80004e32:	f5040593          	addi	a1,s0,-176
    80004e36:	4501                	li	a0,0
    80004e38:	ffffd097          	auipc	ra,0xffffd
    80004e3c:	50e080e7          	jalr	1294(ra) # 80002346 <argstr>
    80004e40:	87aa                	mv	a5,a0
    return -1;
    80004e42:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e44:	0a07c963          	bltz	a5,80004ef6 <sys_open+0xe4>

  begin_op();
    80004e48:	fffff097          	auipc	ra,0xfffff
    80004e4c:	9fa080e7          	jalr	-1542(ra) # 80003842 <begin_op>

  if(omode & O_CREATE){
    80004e50:	f4c42783          	lw	a5,-180(s0)
    80004e54:	2007f793          	andi	a5,a5,512
    80004e58:	cfc5                	beqz	a5,80004f10 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004e5a:	4681                	li	a3,0
    80004e5c:	4601                	li	a2,0
    80004e5e:	4589                	li	a1,2
    80004e60:	f5040513          	addi	a0,s0,-176
    80004e64:	00000097          	auipc	ra,0x0
    80004e68:	974080e7          	jalr	-1676(ra) # 800047d8 <create>
    80004e6c:	84aa                	mv	s1,a0
    if(ip == 0){
    80004e6e:	c959                	beqz	a0,80004f04 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004e70:	04449703          	lh	a4,68(s1)
    80004e74:	478d                	li	a5,3
    80004e76:	00f71763          	bne	a4,a5,80004e84 <sys_open+0x72>
    80004e7a:	0464d703          	lhu	a4,70(s1)
    80004e7e:	47a5                	li	a5,9
    80004e80:	0ce7ed63          	bltu	a5,a4,80004f5a <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004e84:	fffff097          	auipc	ra,0xfffff
    80004e88:	dce080e7          	jalr	-562(ra) # 80003c52 <filealloc>
    80004e8c:	89aa                	mv	s3,a0
    80004e8e:	10050363          	beqz	a0,80004f94 <sys_open+0x182>
    80004e92:	00000097          	auipc	ra,0x0
    80004e96:	904080e7          	jalr	-1788(ra) # 80004796 <fdalloc>
    80004e9a:	892a                	mv	s2,a0
    80004e9c:	0e054763          	bltz	a0,80004f8a <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004ea0:	04449703          	lh	a4,68(s1)
    80004ea4:	478d                	li	a5,3
    80004ea6:	0cf70563          	beq	a4,a5,80004f70 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004eaa:	4789                	li	a5,2
    80004eac:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004eb0:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80004eb4:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004eb8:	f4c42783          	lw	a5,-180(s0)
    80004ebc:	0017c713          	xori	a4,a5,1
    80004ec0:	8b05                	andi	a4,a4,1
    80004ec2:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004ec6:	0037f713          	andi	a4,a5,3
    80004eca:	00e03733          	snez	a4,a4
    80004ece:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004ed2:	4007f793          	andi	a5,a5,1024
    80004ed6:	c791                	beqz	a5,80004ee2 <sys_open+0xd0>
    80004ed8:	04449703          	lh	a4,68(s1)
    80004edc:	4789                	li	a5,2
    80004ede:	0af70063          	beq	a4,a5,80004f7e <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004ee2:	8526                	mv	a0,s1
    80004ee4:	ffffe097          	auipc	ra,0xffffe
    80004ee8:	05e080e7          	jalr	94(ra) # 80002f42 <iunlock>
  end_op();
    80004eec:	fffff097          	auipc	ra,0xfffff
    80004ef0:	9d6080e7          	jalr	-1578(ra) # 800038c2 <end_op>

  return fd;
    80004ef4:	854a                	mv	a0,s2
}
    80004ef6:	70ea                	ld	ra,184(sp)
    80004ef8:	744a                	ld	s0,176(sp)
    80004efa:	74aa                	ld	s1,168(sp)
    80004efc:	790a                	ld	s2,160(sp)
    80004efe:	69ea                	ld	s3,152(sp)
    80004f00:	6129                	addi	sp,sp,192
    80004f02:	8082                	ret
      end_op();
    80004f04:	fffff097          	auipc	ra,0xfffff
    80004f08:	9be080e7          	jalr	-1602(ra) # 800038c2 <end_op>
      return -1;
    80004f0c:	557d                	li	a0,-1
    80004f0e:	b7e5                	j	80004ef6 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004f10:	f5040513          	addi	a0,s0,-176
    80004f14:	ffffe097          	auipc	ra,0xffffe
    80004f18:	712080e7          	jalr	1810(ra) # 80003626 <namei>
    80004f1c:	84aa                	mv	s1,a0
    80004f1e:	c905                	beqz	a0,80004f4e <sys_open+0x13c>
    ilock(ip);
    80004f20:	ffffe097          	auipc	ra,0xffffe
    80004f24:	f60080e7          	jalr	-160(ra) # 80002e80 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f28:	04449703          	lh	a4,68(s1)
    80004f2c:	4785                	li	a5,1
    80004f2e:	f4f711e3          	bne	a4,a5,80004e70 <sys_open+0x5e>
    80004f32:	f4c42783          	lw	a5,-180(s0)
    80004f36:	d7b9                	beqz	a5,80004e84 <sys_open+0x72>
      iunlockput(ip);
    80004f38:	8526                	mv	a0,s1
    80004f3a:	ffffe097          	auipc	ra,0xffffe
    80004f3e:	1a8080e7          	jalr	424(ra) # 800030e2 <iunlockput>
      end_op();
    80004f42:	fffff097          	auipc	ra,0xfffff
    80004f46:	980080e7          	jalr	-1664(ra) # 800038c2 <end_op>
      return -1;
    80004f4a:	557d                	li	a0,-1
    80004f4c:	b76d                	j	80004ef6 <sys_open+0xe4>
      end_op();
    80004f4e:	fffff097          	auipc	ra,0xfffff
    80004f52:	974080e7          	jalr	-1676(ra) # 800038c2 <end_op>
      return -1;
    80004f56:	557d                	li	a0,-1
    80004f58:	bf79                	j	80004ef6 <sys_open+0xe4>
    iunlockput(ip);
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	ffffe097          	auipc	ra,0xffffe
    80004f60:	186080e7          	jalr	390(ra) # 800030e2 <iunlockput>
    end_op();
    80004f64:	fffff097          	auipc	ra,0xfffff
    80004f68:	95e080e7          	jalr	-1698(ra) # 800038c2 <end_op>
    return -1;
    80004f6c:	557d                	li	a0,-1
    80004f6e:	b761                	j	80004ef6 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004f70:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004f74:	04649783          	lh	a5,70(s1)
    80004f78:	02f99223          	sh	a5,36(s3)
    80004f7c:	bf25                	j	80004eb4 <sys_open+0xa2>
    itrunc(ip);
    80004f7e:	8526                	mv	a0,s1
    80004f80:	ffffe097          	auipc	ra,0xffffe
    80004f84:	00e080e7          	jalr	14(ra) # 80002f8e <itrunc>
    80004f88:	bfa9                	j	80004ee2 <sys_open+0xd0>
      fileclose(f);
    80004f8a:	854e                	mv	a0,s3
    80004f8c:	fffff097          	auipc	ra,0xfffff
    80004f90:	d82080e7          	jalr	-638(ra) # 80003d0e <fileclose>
    iunlockput(ip);
    80004f94:	8526                	mv	a0,s1
    80004f96:	ffffe097          	auipc	ra,0xffffe
    80004f9a:	14c080e7          	jalr	332(ra) # 800030e2 <iunlockput>
    end_op();
    80004f9e:	fffff097          	auipc	ra,0xfffff
    80004fa2:	924080e7          	jalr	-1756(ra) # 800038c2 <end_op>
    return -1;
    80004fa6:	557d                	li	a0,-1
    80004fa8:	b7b9                	j	80004ef6 <sys_open+0xe4>

0000000080004faa <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004faa:	7175                	addi	sp,sp,-144
    80004fac:	e506                	sd	ra,136(sp)
    80004fae:	e122                	sd	s0,128(sp)
    80004fb0:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004fb2:	fffff097          	auipc	ra,0xfffff
    80004fb6:	890080e7          	jalr	-1904(ra) # 80003842 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004fba:	08000613          	li	a2,128
    80004fbe:	f7040593          	addi	a1,s0,-144
    80004fc2:	4501                	li	a0,0
    80004fc4:	ffffd097          	auipc	ra,0xffffd
    80004fc8:	382080e7          	jalr	898(ra) # 80002346 <argstr>
    80004fcc:	02054963          	bltz	a0,80004ffe <sys_mkdir+0x54>
    80004fd0:	4681                	li	a3,0
    80004fd2:	4601                	li	a2,0
    80004fd4:	4585                	li	a1,1
    80004fd6:	f7040513          	addi	a0,s0,-144
    80004fda:	fffff097          	auipc	ra,0xfffff
    80004fde:	7fe080e7          	jalr	2046(ra) # 800047d8 <create>
    80004fe2:	cd11                	beqz	a0,80004ffe <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004fe4:	ffffe097          	auipc	ra,0xffffe
    80004fe8:	0fe080e7          	jalr	254(ra) # 800030e2 <iunlockput>
  end_op();
    80004fec:	fffff097          	auipc	ra,0xfffff
    80004ff0:	8d6080e7          	jalr	-1834(ra) # 800038c2 <end_op>
  return 0;
    80004ff4:	4501                	li	a0,0
}
    80004ff6:	60aa                	ld	ra,136(sp)
    80004ff8:	640a                	ld	s0,128(sp)
    80004ffa:	6149                	addi	sp,sp,144
    80004ffc:	8082                	ret
    end_op();
    80004ffe:	fffff097          	auipc	ra,0xfffff
    80005002:	8c4080e7          	jalr	-1852(ra) # 800038c2 <end_op>
    return -1;
    80005006:	557d                	li	a0,-1
    80005008:	b7fd                	j	80004ff6 <sys_mkdir+0x4c>

000000008000500a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000500a:	7135                	addi	sp,sp,-160
    8000500c:	ed06                	sd	ra,152(sp)
    8000500e:	e922                	sd	s0,144(sp)
    80005010:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005012:	fffff097          	auipc	ra,0xfffff
    80005016:	830080e7          	jalr	-2000(ra) # 80003842 <begin_op>
  argint(1, &major);
    8000501a:	f6c40593          	addi	a1,s0,-148
    8000501e:	4505                	li	a0,1
    80005020:	ffffd097          	auipc	ra,0xffffd
    80005024:	2e6080e7          	jalr	742(ra) # 80002306 <argint>
  argint(2, &minor);
    80005028:	f6840593          	addi	a1,s0,-152
    8000502c:	4509                	li	a0,2
    8000502e:	ffffd097          	auipc	ra,0xffffd
    80005032:	2d8080e7          	jalr	728(ra) # 80002306 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005036:	08000613          	li	a2,128
    8000503a:	f7040593          	addi	a1,s0,-144
    8000503e:	4501                	li	a0,0
    80005040:	ffffd097          	auipc	ra,0xffffd
    80005044:	306080e7          	jalr	774(ra) # 80002346 <argstr>
    80005048:	02054b63          	bltz	a0,8000507e <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000504c:	f6841683          	lh	a3,-152(s0)
    80005050:	f6c41603          	lh	a2,-148(s0)
    80005054:	458d                	li	a1,3
    80005056:	f7040513          	addi	a0,s0,-144
    8000505a:	fffff097          	auipc	ra,0xfffff
    8000505e:	77e080e7          	jalr	1918(ra) # 800047d8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005062:	cd11                	beqz	a0,8000507e <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005064:	ffffe097          	auipc	ra,0xffffe
    80005068:	07e080e7          	jalr	126(ra) # 800030e2 <iunlockput>
  end_op();
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	856080e7          	jalr	-1962(ra) # 800038c2 <end_op>
  return 0;
    80005074:	4501                	li	a0,0
}
    80005076:	60ea                	ld	ra,152(sp)
    80005078:	644a                	ld	s0,144(sp)
    8000507a:	610d                	addi	sp,sp,160
    8000507c:	8082                	ret
    end_op();
    8000507e:	fffff097          	auipc	ra,0xfffff
    80005082:	844080e7          	jalr	-1980(ra) # 800038c2 <end_op>
    return -1;
    80005086:	557d                	li	a0,-1
    80005088:	b7fd                	j	80005076 <sys_mknod+0x6c>

000000008000508a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000508a:	7135                	addi	sp,sp,-160
    8000508c:	ed06                	sd	ra,152(sp)
    8000508e:	e922                	sd	s0,144(sp)
    80005090:	e526                	sd	s1,136(sp)
    80005092:	e14a                	sd	s2,128(sp)
    80005094:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005096:	ffffc097          	auipc	ra,0xffffc
    8000509a:	074080e7          	jalr	116(ra) # 8000110a <myproc>
    8000509e:	892a                	mv	s2,a0
  
  begin_op();
    800050a0:	ffffe097          	auipc	ra,0xffffe
    800050a4:	7a2080e7          	jalr	1954(ra) # 80003842 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800050a8:	08000613          	li	a2,128
    800050ac:	f6040593          	addi	a1,s0,-160
    800050b0:	4501                	li	a0,0
    800050b2:	ffffd097          	auipc	ra,0xffffd
    800050b6:	294080e7          	jalr	660(ra) # 80002346 <argstr>
    800050ba:	04054b63          	bltz	a0,80005110 <sys_chdir+0x86>
    800050be:	f6040513          	addi	a0,s0,-160
    800050c2:	ffffe097          	auipc	ra,0xffffe
    800050c6:	564080e7          	jalr	1380(ra) # 80003626 <namei>
    800050ca:	84aa                	mv	s1,a0
    800050cc:	c131                	beqz	a0,80005110 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800050ce:	ffffe097          	auipc	ra,0xffffe
    800050d2:	db2080e7          	jalr	-590(ra) # 80002e80 <ilock>
  if(ip->type != T_DIR){
    800050d6:	04449703          	lh	a4,68(s1)
    800050da:	4785                	li	a5,1
    800050dc:	04f71063          	bne	a4,a5,8000511c <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800050e0:	8526                	mv	a0,s1
    800050e2:	ffffe097          	auipc	ra,0xffffe
    800050e6:	e60080e7          	jalr	-416(ra) # 80002f42 <iunlock>
  iput(p->cwd);
    800050ea:	15093503          	ld	a0,336(s2)
    800050ee:	ffffe097          	auipc	ra,0xffffe
    800050f2:	f4c080e7          	jalr	-180(ra) # 8000303a <iput>
  end_op();
    800050f6:	ffffe097          	auipc	ra,0xffffe
    800050fa:	7cc080e7          	jalr	1996(ra) # 800038c2 <end_op>
  p->cwd = ip;
    800050fe:	14993823          	sd	s1,336(s2)
  return 0;
    80005102:	4501                	li	a0,0
}
    80005104:	60ea                	ld	ra,152(sp)
    80005106:	644a                	ld	s0,144(sp)
    80005108:	64aa                	ld	s1,136(sp)
    8000510a:	690a                	ld	s2,128(sp)
    8000510c:	610d                	addi	sp,sp,160
    8000510e:	8082                	ret
    end_op();
    80005110:	ffffe097          	auipc	ra,0xffffe
    80005114:	7b2080e7          	jalr	1970(ra) # 800038c2 <end_op>
    return -1;
    80005118:	557d                	li	a0,-1
    8000511a:	b7ed                	j	80005104 <sys_chdir+0x7a>
    iunlockput(ip);
    8000511c:	8526                	mv	a0,s1
    8000511e:	ffffe097          	auipc	ra,0xffffe
    80005122:	fc4080e7          	jalr	-60(ra) # 800030e2 <iunlockput>
    end_op();
    80005126:	ffffe097          	auipc	ra,0xffffe
    8000512a:	79c080e7          	jalr	1948(ra) # 800038c2 <end_op>
    return -1;
    8000512e:	557d                	li	a0,-1
    80005130:	bfd1                	j	80005104 <sys_chdir+0x7a>

0000000080005132 <sys_exec>:

uint64
sys_exec(void)
{
    80005132:	7145                	addi	sp,sp,-464
    80005134:	e786                	sd	ra,456(sp)
    80005136:	e3a2                	sd	s0,448(sp)
    80005138:	ff26                	sd	s1,440(sp)
    8000513a:	fb4a                	sd	s2,432(sp)
    8000513c:	f74e                	sd	s3,424(sp)
    8000513e:	f352                	sd	s4,416(sp)
    80005140:	ef56                	sd	s5,408(sp)
    80005142:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005144:	e3840593          	addi	a1,s0,-456
    80005148:	4505                	li	a0,1
    8000514a:	ffffd097          	auipc	ra,0xffffd
    8000514e:	1dc080e7          	jalr	476(ra) # 80002326 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005152:	08000613          	li	a2,128
    80005156:	f4040593          	addi	a1,s0,-192
    8000515a:	4501                	li	a0,0
    8000515c:	ffffd097          	auipc	ra,0xffffd
    80005160:	1ea080e7          	jalr	490(ra) # 80002346 <argstr>
    80005164:	87aa                	mv	a5,a0
    return -1;
    80005166:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005168:	0c07c263          	bltz	a5,8000522c <sys_exec+0xfa>
  }
  memset(argv, 0, sizeof(argv));
    8000516c:	10000613          	li	a2,256
    80005170:	4581                	li	a1,0
    80005172:	e4040513          	addi	a0,s0,-448
    80005176:	ffffb097          	auipc	ra,0xffffb
    8000517a:	226080e7          	jalr	550(ra) # 8000039c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000517e:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005182:	89a6                	mv	s3,s1
    80005184:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005186:	02000a13          	li	s4,32
    8000518a:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000518e:	00391513          	slli	a0,s2,0x3
    80005192:	e3040593          	addi	a1,s0,-464
    80005196:	e3843783          	ld	a5,-456(s0)
    8000519a:	953e                	add	a0,a0,a5
    8000519c:	ffffd097          	auipc	ra,0xffffd
    800051a0:	0cc080e7          	jalr	204(ra) # 80002268 <fetchaddr>
    800051a4:	02054a63          	bltz	a0,800051d8 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    800051a8:	e3043783          	ld	a5,-464(s0)
    800051ac:	c3b9                	beqz	a5,800051f2 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800051ae:	ffffb097          	auipc	ra,0xffffb
    800051b2:	18e080e7          	jalr	398(ra) # 8000033c <kalloc>
    800051b6:	85aa                	mv	a1,a0
    800051b8:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800051bc:	cd11                	beqz	a0,800051d8 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800051be:	6605                	lui	a2,0x1
    800051c0:	e3043503          	ld	a0,-464(s0)
    800051c4:	ffffd097          	auipc	ra,0xffffd
    800051c8:	0f6080e7          	jalr	246(ra) # 800022ba <fetchstr>
    800051cc:	00054663          	bltz	a0,800051d8 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    800051d0:	0905                	addi	s2,s2,1
    800051d2:	09a1                	addi	s3,s3,8
    800051d4:	fb491be3          	bne	s2,s4,8000518a <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051d8:	10048913          	addi	s2,s1,256
    800051dc:	6088                	ld	a0,0(s1)
    800051de:	c531                	beqz	a0,8000522a <sys_exec+0xf8>
    kfree(argv[i]);
    800051e0:	ffffb097          	auipc	ra,0xffffb
    800051e4:	fd4080e7          	jalr	-44(ra) # 800001b4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051e8:	04a1                	addi	s1,s1,8
    800051ea:	ff2499e3          	bne	s1,s2,800051dc <sys_exec+0xaa>
  return -1;
    800051ee:	557d                	li	a0,-1
    800051f0:	a835                	j	8000522c <sys_exec+0xfa>
      argv[i] = 0;
    800051f2:	0a8e                	slli	s5,s5,0x3
    800051f4:	fc040793          	addi	a5,s0,-64
    800051f8:	9abe                	add	s5,s5,a5
    800051fa:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800051fe:	e4040593          	addi	a1,s0,-448
    80005202:	f4040513          	addi	a0,s0,-192
    80005206:	fffff097          	auipc	ra,0xfffff
    8000520a:	190080e7          	jalr	400(ra) # 80004396 <exec>
    8000520e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005210:	10048993          	addi	s3,s1,256
    80005214:	6088                	ld	a0,0(s1)
    80005216:	c901                	beqz	a0,80005226 <sys_exec+0xf4>
    kfree(argv[i]);
    80005218:	ffffb097          	auipc	ra,0xffffb
    8000521c:	f9c080e7          	jalr	-100(ra) # 800001b4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005220:	04a1                	addi	s1,s1,8
    80005222:	ff3499e3          	bne	s1,s3,80005214 <sys_exec+0xe2>
  return ret;
    80005226:	854a                	mv	a0,s2
    80005228:	a011                	j	8000522c <sys_exec+0xfa>
  return -1;
    8000522a:	557d                	li	a0,-1
}
    8000522c:	60be                	ld	ra,456(sp)
    8000522e:	641e                	ld	s0,448(sp)
    80005230:	74fa                	ld	s1,440(sp)
    80005232:	795a                	ld	s2,432(sp)
    80005234:	79ba                	ld	s3,424(sp)
    80005236:	7a1a                	ld	s4,416(sp)
    80005238:	6afa                	ld	s5,408(sp)
    8000523a:	6179                	addi	sp,sp,464
    8000523c:	8082                	ret

000000008000523e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000523e:	7139                	addi	sp,sp,-64
    80005240:	fc06                	sd	ra,56(sp)
    80005242:	f822                	sd	s0,48(sp)
    80005244:	f426                	sd	s1,40(sp)
    80005246:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005248:	ffffc097          	auipc	ra,0xffffc
    8000524c:	ec2080e7          	jalr	-318(ra) # 8000110a <myproc>
    80005250:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005252:	fd840593          	addi	a1,s0,-40
    80005256:	4501                	li	a0,0
    80005258:	ffffd097          	auipc	ra,0xffffd
    8000525c:	0ce080e7          	jalr	206(ra) # 80002326 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005260:	fc840593          	addi	a1,s0,-56
    80005264:	fd040513          	addi	a0,s0,-48
    80005268:	fffff097          	auipc	ra,0xfffff
    8000526c:	dd6080e7          	jalr	-554(ra) # 8000403e <pipealloc>
    return -1;
    80005270:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005272:	0c054463          	bltz	a0,8000533a <sys_pipe+0xfc>
  fd0 = -1;
    80005276:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000527a:	fd043503          	ld	a0,-48(s0)
    8000527e:	fffff097          	auipc	ra,0xfffff
    80005282:	518080e7          	jalr	1304(ra) # 80004796 <fdalloc>
    80005286:	fca42223          	sw	a0,-60(s0)
    8000528a:	08054b63          	bltz	a0,80005320 <sys_pipe+0xe2>
    8000528e:	fc843503          	ld	a0,-56(s0)
    80005292:	fffff097          	auipc	ra,0xfffff
    80005296:	504080e7          	jalr	1284(ra) # 80004796 <fdalloc>
    8000529a:	fca42023          	sw	a0,-64(s0)
    8000529e:	06054863          	bltz	a0,8000530e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052a2:	4691                	li	a3,4
    800052a4:	fc440613          	addi	a2,s0,-60
    800052a8:	fd843583          	ld	a1,-40(s0)
    800052ac:	68a8                	ld	a0,80(s1)
    800052ae:	ffffc097          	auipc	ra,0xffffc
    800052b2:	ae2080e7          	jalr	-1310(ra) # 80000d90 <copyout>
    800052b6:	02054063          	bltz	a0,800052d6 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800052ba:	4691                	li	a3,4
    800052bc:	fc040613          	addi	a2,s0,-64
    800052c0:	fd843583          	ld	a1,-40(s0)
    800052c4:	0591                	addi	a1,a1,4
    800052c6:	68a8                	ld	a0,80(s1)
    800052c8:	ffffc097          	auipc	ra,0xffffc
    800052cc:	ac8080e7          	jalr	-1336(ra) # 80000d90 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800052d0:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800052d2:	06055463          	bgez	a0,8000533a <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800052d6:	fc442783          	lw	a5,-60(s0)
    800052da:	07e9                	addi	a5,a5,26
    800052dc:	078e                	slli	a5,a5,0x3
    800052de:	97a6                	add	a5,a5,s1
    800052e0:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800052e4:	fc042503          	lw	a0,-64(s0)
    800052e8:	0569                	addi	a0,a0,26
    800052ea:	050e                	slli	a0,a0,0x3
    800052ec:	94aa                	add	s1,s1,a0
    800052ee:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800052f2:	fd043503          	ld	a0,-48(s0)
    800052f6:	fffff097          	auipc	ra,0xfffff
    800052fa:	a18080e7          	jalr	-1512(ra) # 80003d0e <fileclose>
    fileclose(wf);
    800052fe:	fc843503          	ld	a0,-56(s0)
    80005302:	fffff097          	auipc	ra,0xfffff
    80005306:	a0c080e7          	jalr	-1524(ra) # 80003d0e <fileclose>
    return -1;
    8000530a:	57fd                	li	a5,-1
    8000530c:	a03d                	j	8000533a <sys_pipe+0xfc>
    if(fd0 >= 0)
    8000530e:	fc442783          	lw	a5,-60(s0)
    80005312:	0007c763          	bltz	a5,80005320 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005316:	07e9                	addi	a5,a5,26
    80005318:	078e                	slli	a5,a5,0x3
    8000531a:	94be                	add	s1,s1,a5
    8000531c:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005320:	fd043503          	ld	a0,-48(s0)
    80005324:	fffff097          	auipc	ra,0xfffff
    80005328:	9ea080e7          	jalr	-1558(ra) # 80003d0e <fileclose>
    fileclose(wf);
    8000532c:	fc843503          	ld	a0,-56(s0)
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	9de080e7          	jalr	-1570(ra) # 80003d0e <fileclose>
    return -1;
    80005338:	57fd                	li	a5,-1
}
    8000533a:	853e                	mv	a0,a5
    8000533c:	70e2                	ld	ra,56(sp)
    8000533e:	7442                	ld	s0,48(sp)
    80005340:	74a2                	ld	s1,40(sp)
    80005342:	6121                	addi	sp,sp,64
    80005344:	8082                	ret
	...

0000000080005350 <kernelvec>:
    80005350:	7111                	addi	sp,sp,-256
    80005352:	e006                	sd	ra,0(sp)
    80005354:	e40a                	sd	sp,8(sp)
    80005356:	e80e                	sd	gp,16(sp)
    80005358:	ec12                	sd	tp,24(sp)
    8000535a:	f016                	sd	t0,32(sp)
    8000535c:	f41a                	sd	t1,40(sp)
    8000535e:	f81e                	sd	t2,48(sp)
    80005360:	fc22                	sd	s0,56(sp)
    80005362:	e0a6                	sd	s1,64(sp)
    80005364:	e4aa                	sd	a0,72(sp)
    80005366:	e8ae                	sd	a1,80(sp)
    80005368:	ecb2                	sd	a2,88(sp)
    8000536a:	f0b6                	sd	a3,96(sp)
    8000536c:	f4ba                	sd	a4,104(sp)
    8000536e:	f8be                	sd	a5,112(sp)
    80005370:	fcc2                	sd	a6,120(sp)
    80005372:	e146                	sd	a7,128(sp)
    80005374:	e54a                	sd	s2,136(sp)
    80005376:	e94e                	sd	s3,144(sp)
    80005378:	ed52                	sd	s4,152(sp)
    8000537a:	f156                	sd	s5,160(sp)
    8000537c:	f55a                	sd	s6,168(sp)
    8000537e:	f95e                	sd	s7,176(sp)
    80005380:	fd62                	sd	s8,184(sp)
    80005382:	e1e6                	sd	s9,192(sp)
    80005384:	e5ea                	sd	s10,200(sp)
    80005386:	e9ee                	sd	s11,208(sp)
    80005388:	edf2                	sd	t3,216(sp)
    8000538a:	f1f6                	sd	t4,224(sp)
    8000538c:	f5fa                	sd	t5,232(sp)
    8000538e:	f9fe                	sd	t6,240(sp)
    80005390:	da5fc0ef          	jal	ra,80002134 <kerneltrap>
    80005394:	6082                	ld	ra,0(sp)
    80005396:	6122                	ld	sp,8(sp)
    80005398:	61c2                	ld	gp,16(sp)
    8000539a:	7282                	ld	t0,32(sp)
    8000539c:	7322                	ld	t1,40(sp)
    8000539e:	73c2                	ld	t2,48(sp)
    800053a0:	7462                	ld	s0,56(sp)
    800053a2:	6486                	ld	s1,64(sp)
    800053a4:	6526                	ld	a0,72(sp)
    800053a6:	65c6                	ld	a1,80(sp)
    800053a8:	6666                	ld	a2,88(sp)
    800053aa:	7686                	ld	a3,96(sp)
    800053ac:	7726                	ld	a4,104(sp)
    800053ae:	77c6                	ld	a5,112(sp)
    800053b0:	7866                	ld	a6,120(sp)
    800053b2:	688a                	ld	a7,128(sp)
    800053b4:	692a                	ld	s2,136(sp)
    800053b6:	69ca                	ld	s3,144(sp)
    800053b8:	6a6a                	ld	s4,152(sp)
    800053ba:	7a8a                	ld	s5,160(sp)
    800053bc:	7b2a                	ld	s6,168(sp)
    800053be:	7bca                	ld	s7,176(sp)
    800053c0:	7c6a                	ld	s8,184(sp)
    800053c2:	6c8e                	ld	s9,192(sp)
    800053c4:	6d2e                	ld	s10,200(sp)
    800053c6:	6dce                	ld	s11,208(sp)
    800053c8:	6e6e                	ld	t3,216(sp)
    800053ca:	7e8e                	ld	t4,224(sp)
    800053cc:	7f2e                	ld	t5,232(sp)
    800053ce:	7fce                	ld	t6,240(sp)
    800053d0:	6111                	addi	sp,sp,256
    800053d2:	10200073          	sret
    800053d6:	00000013          	nop
    800053da:	00000013          	nop
    800053de:	0001                	nop

00000000800053e0 <timervec>:
    800053e0:	34051573          	csrrw	a0,mscratch,a0
    800053e4:	e10c                	sd	a1,0(a0)
    800053e6:	e510                	sd	a2,8(a0)
    800053e8:	e914                	sd	a3,16(a0)
    800053ea:	6d0c                	ld	a1,24(a0)
    800053ec:	7110                	ld	a2,32(a0)
    800053ee:	6194                	ld	a3,0(a1)
    800053f0:	96b2                	add	a3,a3,a2
    800053f2:	e194                	sd	a3,0(a1)
    800053f4:	4589                	li	a1,2
    800053f6:	14459073          	csrw	sip,a1
    800053fa:	6914                	ld	a3,16(a0)
    800053fc:	6510                	ld	a2,8(a0)
    800053fe:	610c                	ld	a1,0(a0)
    80005400:	34051573          	csrrw	a0,mscratch,a0
    80005404:	30200073          	mret
	...

000000008000540a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000540a:	1141                	addi	sp,sp,-16
    8000540c:	e422                	sd	s0,8(sp)
    8000540e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005410:	0c0007b7          	lui	a5,0xc000
    80005414:	4705                	li	a4,1
    80005416:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005418:	c3d8                	sw	a4,4(a5)
}
    8000541a:	6422                	ld	s0,8(sp)
    8000541c:	0141                	addi	sp,sp,16
    8000541e:	8082                	ret

0000000080005420 <plicinithart>:

void
plicinithart(void)
{
    80005420:	1141                	addi	sp,sp,-16
    80005422:	e406                	sd	ra,8(sp)
    80005424:	e022                	sd	s0,0(sp)
    80005426:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005428:	ffffc097          	auipc	ra,0xffffc
    8000542c:	cb6080e7          	jalr	-842(ra) # 800010de <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005430:	0085171b          	slliw	a4,a0,0x8
    80005434:	0c0027b7          	lui	a5,0xc002
    80005438:	97ba                	add	a5,a5,a4
    8000543a:	40200713          	li	a4,1026
    8000543e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005442:	00d5151b          	slliw	a0,a0,0xd
    80005446:	0c2017b7          	lui	a5,0xc201
    8000544a:	953e                	add	a0,a0,a5
    8000544c:	00052023          	sw	zero,0(a0)
}
    80005450:	60a2                	ld	ra,8(sp)
    80005452:	6402                	ld	s0,0(sp)
    80005454:	0141                	addi	sp,sp,16
    80005456:	8082                	ret

0000000080005458 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005458:	1141                	addi	sp,sp,-16
    8000545a:	e406                	sd	ra,8(sp)
    8000545c:	e022                	sd	s0,0(sp)
    8000545e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005460:	ffffc097          	auipc	ra,0xffffc
    80005464:	c7e080e7          	jalr	-898(ra) # 800010de <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005468:	00d5179b          	slliw	a5,a0,0xd
    8000546c:	0c201537          	lui	a0,0xc201
    80005470:	953e                	add	a0,a0,a5
  return irq;
}
    80005472:	4148                	lw	a0,4(a0)
    80005474:	60a2                	ld	ra,8(sp)
    80005476:	6402                	ld	s0,0(sp)
    80005478:	0141                	addi	sp,sp,16
    8000547a:	8082                	ret

000000008000547c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000547c:	1101                	addi	sp,sp,-32
    8000547e:	ec06                	sd	ra,24(sp)
    80005480:	e822                	sd	s0,16(sp)
    80005482:	e426                	sd	s1,8(sp)
    80005484:	1000                	addi	s0,sp,32
    80005486:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005488:	ffffc097          	auipc	ra,0xffffc
    8000548c:	c56080e7          	jalr	-938(ra) # 800010de <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005490:	00d5151b          	slliw	a0,a0,0xd
    80005494:	0c2017b7          	lui	a5,0xc201
    80005498:	97aa                	add	a5,a5,a0
    8000549a:	c3c4                	sw	s1,4(a5)
}
    8000549c:	60e2                	ld	ra,24(sp)
    8000549e:	6442                	ld	s0,16(sp)
    800054a0:	64a2                	ld	s1,8(sp)
    800054a2:	6105                	addi	sp,sp,32
    800054a4:	8082                	ret

00000000800054a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800054a6:	1141                	addi	sp,sp,-16
    800054a8:	e406                	sd	ra,8(sp)
    800054aa:	e022                	sd	s0,0(sp)
    800054ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800054ae:	479d                	li	a5,7
    800054b0:	04a7cc63          	blt	a5,a0,80005508 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800054b4:	00234797          	auipc	a5,0x234
    800054b8:	57478793          	addi	a5,a5,1396 # 80239a28 <disk>
    800054bc:	97aa                	add	a5,a5,a0
    800054be:	0187c783          	lbu	a5,24(a5)
    800054c2:	ebb9                	bnez	a5,80005518 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800054c4:	00451613          	slli	a2,a0,0x4
    800054c8:	00234797          	auipc	a5,0x234
    800054cc:	56078793          	addi	a5,a5,1376 # 80239a28 <disk>
    800054d0:	6394                	ld	a3,0(a5)
    800054d2:	96b2                	add	a3,a3,a2
    800054d4:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    800054d8:	6398                	ld	a4,0(a5)
    800054da:	9732                	add	a4,a4,a2
    800054dc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800054e0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800054e4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800054e8:	953e                	add	a0,a0,a5
    800054ea:	4785                	li	a5,1
    800054ec:	00f50c23          	sb	a5,24(a0) # c201018 <_entry-0x73dfefe8>
  wakeup(&disk.free[0]);
    800054f0:	00234517          	auipc	a0,0x234
    800054f4:	55050513          	addi	a0,a0,1360 # 80239a40 <disk+0x18>
    800054f8:	ffffc097          	auipc	ra,0xffffc
    800054fc:	31a080e7          	jalr	794(ra) # 80001812 <wakeup>
}
    80005500:	60a2                	ld	ra,8(sp)
    80005502:	6402                	ld	s0,0(sp)
    80005504:	0141                	addi	sp,sp,16
    80005506:	8082                	ret
    panic("free_desc 1");
    80005508:	00003517          	auipc	a0,0x3
    8000550c:	1f850513          	addi	a0,a0,504 # 80008700 <syscalls+0x2f0>
    80005510:	00001097          	auipc	ra,0x1
    80005514:	a72080e7          	jalr	-1422(ra) # 80005f82 <panic>
    panic("free_desc 2");
    80005518:	00003517          	auipc	a0,0x3
    8000551c:	1f850513          	addi	a0,a0,504 # 80008710 <syscalls+0x300>
    80005520:	00001097          	auipc	ra,0x1
    80005524:	a62080e7          	jalr	-1438(ra) # 80005f82 <panic>

0000000080005528 <virtio_disk_init>:
{
    80005528:	1101                	addi	sp,sp,-32
    8000552a:	ec06                	sd	ra,24(sp)
    8000552c:	e822                	sd	s0,16(sp)
    8000552e:	e426                	sd	s1,8(sp)
    80005530:	e04a                	sd	s2,0(sp)
    80005532:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005534:	00003597          	auipc	a1,0x3
    80005538:	1ec58593          	addi	a1,a1,492 # 80008720 <syscalls+0x310>
    8000553c:	00234517          	auipc	a0,0x234
    80005540:	61450513          	addi	a0,a0,1556 # 80239b50 <disk+0x128>
    80005544:	00001097          	auipc	ra,0x1
    80005548:	ef8080e7          	jalr	-264(ra) # 8000643c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000554c:	100017b7          	lui	a5,0x10001
    80005550:	4398                	lw	a4,0(a5)
    80005552:	2701                	sext.w	a4,a4
    80005554:	747277b7          	lui	a5,0x74727
    80005558:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000555c:	14f71e63          	bne	a4,a5,800056b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005560:	100017b7          	lui	a5,0x10001
    80005564:	43dc                	lw	a5,4(a5)
    80005566:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005568:	4709                	li	a4,2
    8000556a:	14e79763          	bne	a5,a4,800056b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000556e:	100017b7          	lui	a5,0x10001
    80005572:	479c                	lw	a5,8(a5)
    80005574:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005576:	14e79163          	bne	a5,a4,800056b8 <virtio_disk_init+0x190>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000557a:	100017b7          	lui	a5,0x10001
    8000557e:	47d8                	lw	a4,12(a5)
    80005580:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005582:	554d47b7          	lui	a5,0x554d4
    80005586:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000558a:	12f71763          	bne	a4,a5,800056b8 <virtio_disk_init+0x190>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000558e:	100017b7          	lui	a5,0x10001
    80005592:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005596:	4705                	li	a4,1
    80005598:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000559a:	470d                	li	a4,3
    8000559c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000559e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800055a0:	c7ffe737          	lui	a4,0xc7ffe
    800055a4:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47dbc9af>
    800055a8:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800055aa:	2701                	sext.w	a4,a4
    800055ac:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800055ae:	472d                	li	a4,11
    800055b0:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800055b2:	0707a903          	lw	s2,112(a5)
    800055b6:	2901                	sext.w	s2,s2
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800055b8:	00897793          	andi	a5,s2,8
    800055bc:	10078663          	beqz	a5,800056c8 <virtio_disk_init+0x1a0>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800055c0:	100017b7          	lui	a5,0x10001
    800055c4:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800055c8:	43fc                	lw	a5,68(a5)
    800055ca:	2781                	sext.w	a5,a5
    800055cc:	10079663          	bnez	a5,800056d8 <virtio_disk_init+0x1b0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800055d0:	100017b7          	lui	a5,0x10001
    800055d4:	5bdc                	lw	a5,52(a5)
    800055d6:	2781                	sext.w	a5,a5
  if(max == 0)
    800055d8:	10078863          	beqz	a5,800056e8 <virtio_disk_init+0x1c0>
  if(max < NUM)
    800055dc:	471d                	li	a4,7
    800055de:	10f77d63          	bgeu	a4,a5,800056f8 <virtio_disk_init+0x1d0>
  disk.desc = kalloc();
    800055e2:	ffffb097          	auipc	ra,0xffffb
    800055e6:	d5a080e7          	jalr	-678(ra) # 8000033c <kalloc>
    800055ea:	00234497          	auipc	s1,0x234
    800055ee:	43e48493          	addi	s1,s1,1086 # 80239a28 <disk>
    800055f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800055f4:	ffffb097          	auipc	ra,0xffffb
    800055f8:	d48080e7          	jalr	-696(ra) # 8000033c <kalloc>
    800055fc:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800055fe:	ffffb097          	auipc	ra,0xffffb
    80005602:	d3e080e7          	jalr	-706(ra) # 8000033c <kalloc>
    80005606:	87aa                	mv	a5,a0
    80005608:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    8000560a:	6088                	ld	a0,0(s1)
    8000560c:	cd75                	beqz	a0,80005708 <virtio_disk_init+0x1e0>
    8000560e:	00234717          	auipc	a4,0x234
    80005612:	42273703          	ld	a4,1058(a4) # 80239a30 <disk+0x8>
    80005616:	cb6d                	beqz	a4,80005708 <virtio_disk_init+0x1e0>
    80005618:	cbe5                	beqz	a5,80005708 <virtio_disk_init+0x1e0>
  memset(disk.desc, 0, PGSIZE);
    8000561a:	6605                	lui	a2,0x1
    8000561c:	4581                	li	a1,0
    8000561e:	ffffb097          	auipc	ra,0xffffb
    80005622:	d7e080e7          	jalr	-642(ra) # 8000039c <memset>
  memset(disk.avail, 0, PGSIZE);
    80005626:	00234497          	auipc	s1,0x234
    8000562a:	40248493          	addi	s1,s1,1026 # 80239a28 <disk>
    8000562e:	6605                	lui	a2,0x1
    80005630:	4581                	li	a1,0
    80005632:	6488                	ld	a0,8(s1)
    80005634:	ffffb097          	auipc	ra,0xffffb
    80005638:	d68080e7          	jalr	-664(ra) # 8000039c <memset>
  memset(disk.used, 0, PGSIZE);
    8000563c:	6605                	lui	a2,0x1
    8000563e:	4581                	li	a1,0
    80005640:	6888                	ld	a0,16(s1)
    80005642:	ffffb097          	auipc	ra,0xffffb
    80005646:	d5a080e7          	jalr	-678(ra) # 8000039c <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000564a:	100017b7          	lui	a5,0x10001
    8000564e:	4721                	li	a4,8
    80005650:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005652:	4098                	lw	a4,0(s1)
    80005654:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005658:	40d8                	lw	a4,4(s1)
    8000565a:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000565e:	6498                	ld	a4,8(s1)
    80005660:	0007069b          	sext.w	a3,a4
    80005664:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005668:	9701                	srai	a4,a4,0x20
    8000566a:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000566e:	6898                	ld	a4,16(s1)
    80005670:	0007069b          	sext.w	a3,a4
    80005674:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005678:	9701                	srai	a4,a4,0x20
    8000567a:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000567e:	4685                	li	a3,1
    80005680:	c3f4                	sw	a3,68(a5)
    disk.free[i] = 1;
    80005682:	4705                	li	a4,1
    80005684:	00d48c23          	sb	a3,24(s1)
    80005688:	00e48ca3          	sb	a4,25(s1)
    8000568c:	00e48d23          	sb	a4,26(s1)
    80005690:	00e48da3          	sb	a4,27(s1)
    80005694:	00e48e23          	sb	a4,28(s1)
    80005698:	00e48ea3          	sb	a4,29(s1)
    8000569c:	00e48f23          	sb	a4,30(s1)
    800056a0:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800056a4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800056a8:	0727a823          	sw	s2,112(a5)
}
    800056ac:	60e2                	ld	ra,24(sp)
    800056ae:	6442                	ld	s0,16(sp)
    800056b0:	64a2                	ld	s1,8(sp)
    800056b2:	6902                	ld	s2,0(sp)
    800056b4:	6105                	addi	sp,sp,32
    800056b6:	8082                	ret
    panic("could not find virtio disk");
    800056b8:	00003517          	auipc	a0,0x3
    800056bc:	07850513          	addi	a0,a0,120 # 80008730 <syscalls+0x320>
    800056c0:	00001097          	auipc	ra,0x1
    800056c4:	8c2080e7          	jalr	-1854(ra) # 80005f82 <panic>
    panic("virtio disk FEATURES_OK unset");
    800056c8:	00003517          	auipc	a0,0x3
    800056cc:	08850513          	addi	a0,a0,136 # 80008750 <syscalls+0x340>
    800056d0:	00001097          	auipc	ra,0x1
    800056d4:	8b2080e7          	jalr	-1870(ra) # 80005f82 <panic>
    panic("virtio disk should not be ready");
    800056d8:	00003517          	auipc	a0,0x3
    800056dc:	09850513          	addi	a0,a0,152 # 80008770 <syscalls+0x360>
    800056e0:	00001097          	auipc	ra,0x1
    800056e4:	8a2080e7          	jalr	-1886(ra) # 80005f82 <panic>
    panic("virtio disk has no queue 0");
    800056e8:	00003517          	auipc	a0,0x3
    800056ec:	0a850513          	addi	a0,a0,168 # 80008790 <syscalls+0x380>
    800056f0:	00001097          	auipc	ra,0x1
    800056f4:	892080e7          	jalr	-1902(ra) # 80005f82 <panic>
    panic("virtio disk max queue too short");
    800056f8:	00003517          	auipc	a0,0x3
    800056fc:	0b850513          	addi	a0,a0,184 # 800087b0 <syscalls+0x3a0>
    80005700:	00001097          	auipc	ra,0x1
    80005704:	882080e7          	jalr	-1918(ra) # 80005f82 <panic>
    panic("virtio disk kalloc");
    80005708:	00003517          	auipc	a0,0x3
    8000570c:	0c850513          	addi	a0,a0,200 # 800087d0 <syscalls+0x3c0>
    80005710:	00001097          	auipc	ra,0x1
    80005714:	872080e7          	jalr	-1934(ra) # 80005f82 <panic>

0000000080005718 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005718:	7159                	addi	sp,sp,-112
    8000571a:	f486                	sd	ra,104(sp)
    8000571c:	f0a2                	sd	s0,96(sp)
    8000571e:	eca6                	sd	s1,88(sp)
    80005720:	e8ca                	sd	s2,80(sp)
    80005722:	e4ce                	sd	s3,72(sp)
    80005724:	e0d2                	sd	s4,64(sp)
    80005726:	fc56                	sd	s5,56(sp)
    80005728:	f85a                	sd	s6,48(sp)
    8000572a:	f45e                	sd	s7,40(sp)
    8000572c:	f062                	sd	s8,32(sp)
    8000572e:	ec66                	sd	s9,24(sp)
    80005730:	e86a                	sd	s10,16(sp)
    80005732:	1880                	addi	s0,sp,112
    80005734:	892a                	mv	s2,a0
    80005736:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005738:	00c52c83          	lw	s9,12(a0)
    8000573c:	001c9c9b          	slliw	s9,s9,0x1
    80005740:	1c82                	slli	s9,s9,0x20
    80005742:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005746:	00234517          	auipc	a0,0x234
    8000574a:	40a50513          	addi	a0,a0,1034 # 80239b50 <disk+0x128>
    8000574e:	00001097          	auipc	ra,0x1
    80005752:	d7e080e7          	jalr	-642(ra) # 800064cc <acquire>
  for(int i = 0; i < 3; i++){
    80005756:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005758:	4ba1                	li	s7,8
      disk.free[i] = 0;
    8000575a:	00234b17          	auipc	s6,0x234
    8000575e:	2ceb0b13          	addi	s6,s6,718 # 80239a28 <disk>
  for(int i = 0; i < 3; i++){
    80005762:	4a8d                	li	s5,3
  for(int i = 0; i < NUM; i++){
    80005764:	8a4e                	mv	s4,s3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005766:	00234c17          	auipc	s8,0x234
    8000576a:	3eac0c13          	addi	s8,s8,1002 # 80239b50 <disk+0x128>
    8000576e:	a8b5                	j	800057ea <virtio_disk_rw+0xd2>
      disk.free[i] = 0;
    80005770:	00fb06b3          	add	a3,s6,a5
    80005774:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    80005778:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000577a:	0207c563          	bltz	a5,800057a4 <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    8000577e:	2485                	addiw	s1,s1,1
    80005780:	0711                	addi	a4,a4,4
    80005782:	1f548a63          	beq	s1,s5,80005976 <virtio_disk_rw+0x25e>
    idx[i] = alloc_desc();
    80005786:	863a                	mv	a2,a4
  for(int i = 0; i < NUM; i++){
    80005788:	00234697          	auipc	a3,0x234
    8000578c:	2a068693          	addi	a3,a3,672 # 80239a28 <disk>
    80005790:	87d2                	mv	a5,s4
    if(disk.free[i]){
    80005792:	0186c583          	lbu	a1,24(a3)
    80005796:	fde9                	bnez	a1,80005770 <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80005798:	2785                	addiw	a5,a5,1
    8000579a:	0685                	addi	a3,a3,1
    8000579c:	ff779be3          	bne	a5,s7,80005792 <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    800057a0:	57fd                	li	a5,-1
    800057a2:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800057a4:	02905a63          	blez	s1,800057d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800057a8:	f9042503          	lw	a0,-112(s0)
    800057ac:	00000097          	auipc	ra,0x0
    800057b0:	cfa080e7          	jalr	-774(ra) # 800054a6 <free_desc>
      for(int j = 0; j < i; j++)
    800057b4:	4785                	li	a5,1
    800057b6:	0297d163          	bge	a5,s1,800057d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800057ba:	f9442503          	lw	a0,-108(s0)
    800057be:	00000097          	auipc	ra,0x0
    800057c2:	ce8080e7          	jalr	-792(ra) # 800054a6 <free_desc>
      for(int j = 0; j < i; j++)
    800057c6:	4789                	li	a5,2
    800057c8:	0097d863          	bge	a5,s1,800057d8 <virtio_disk_rw+0xc0>
        free_desc(idx[j]);
    800057cc:	f9842503          	lw	a0,-104(s0)
    800057d0:	00000097          	auipc	ra,0x0
    800057d4:	cd6080e7          	jalr	-810(ra) # 800054a6 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800057d8:	85e2                	mv	a1,s8
    800057da:	00234517          	auipc	a0,0x234
    800057de:	26650513          	addi	a0,a0,614 # 80239a40 <disk+0x18>
    800057e2:	ffffc097          	auipc	ra,0xffffc
    800057e6:	fcc080e7          	jalr	-52(ra) # 800017ae <sleep>
  for(int i = 0; i < 3; i++){
    800057ea:	f9040713          	addi	a4,s0,-112
    800057ee:	84ce                	mv	s1,s3
    800057f0:	bf59                	j	80005786 <virtio_disk_rw+0x6e>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    800057f2:	00a60793          	addi	a5,a2,10 # 100a <_entry-0x7fffeff6>
    800057f6:	00479693          	slli	a3,a5,0x4
    800057fa:	00234797          	auipc	a5,0x234
    800057fe:	22e78793          	addi	a5,a5,558 # 80239a28 <disk>
    80005802:	97b6                	add	a5,a5,a3
    80005804:	4685                	li	a3,1
    80005806:	c794                	sw	a3,8(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005808:	00234597          	auipc	a1,0x234
    8000580c:	22058593          	addi	a1,a1,544 # 80239a28 <disk>
    80005810:	00a60793          	addi	a5,a2,10
    80005814:	0792                	slli	a5,a5,0x4
    80005816:	97ae                	add	a5,a5,a1
    80005818:	0007a623          	sw	zero,12(a5)
  buf0->sector = sector;
    8000581c:	0197b823          	sd	s9,16(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005820:	f6070693          	addi	a3,a4,-160
    80005824:	619c                	ld	a5,0(a1)
    80005826:	97b6                	add	a5,a5,a3
    80005828:	e388                	sd	a0,0(a5)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000582a:	6188                	ld	a0,0(a1)
    8000582c:	96aa                	add	a3,a3,a0
    8000582e:	47c1                	li	a5,16
    80005830:	c69c                	sw	a5,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005832:	4785                	li	a5,1
    80005834:	00f69623          	sh	a5,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005838:	f9442783          	lw	a5,-108(s0)
    8000583c:	00f69723          	sh	a5,14(a3)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005840:	0792                	slli	a5,a5,0x4
    80005842:	953e                	add	a0,a0,a5
    80005844:	05890693          	addi	a3,s2,88
    80005848:	e114                	sd	a3,0(a0)
  disk.desc[idx[1]].len = BSIZE;
    8000584a:	6188                	ld	a0,0(a1)
    8000584c:	97aa                	add	a5,a5,a0
    8000584e:	40000693          	li	a3,1024
    80005852:	c794                	sw	a3,8(a5)
  if(write)
    80005854:	100d0d63          	beqz	s10,8000596e <virtio_disk_rw+0x256>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005858:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000585c:	00c7d683          	lhu	a3,12(a5)
    80005860:	0016e693          	ori	a3,a3,1
    80005864:	00d79623          	sh	a3,12(a5)
  disk.desc[idx[1]].next = idx[2];
    80005868:	f9842583          	lw	a1,-104(s0)
    8000586c:	00b79723          	sh	a1,14(a5)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005870:	00234697          	auipc	a3,0x234
    80005874:	1b868693          	addi	a3,a3,440 # 80239a28 <disk>
    80005878:	00260793          	addi	a5,a2,2
    8000587c:	0792                	slli	a5,a5,0x4
    8000587e:	97b6                	add	a5,a5,a3
    80005880:	587d                	li	a6,-1
    80005882:	01078823          	sb	a6,16(a5)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005886:	0592                	slli	a1,a1,0x4
    80005888:	952e                	add	a0,a0,a1
    8000588a:	f9070713          	addi	a4,a4,-112
    8000588e:	9736                	add	a4,a4,a3
    80005890:	e118                	sd	a4,0(a0)
  disk.desc[idx[2]].len = 1;
    80005892:	6298                	ld	a4,0(a3)
    80005894:	972e                	add	a4,a4,a1
    80005896:	4585                	li	a1,1
    80005898:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000589a:	4509                	li	a0,2
    8000589c:	00a71623          	sh	a0,12(a4)
  disk.desc[idx[2]].next = 0;
    800058a0:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800058a4:	00b92223          	sw	a1,4(s2)
  disk.info[idx[0]].b = b;
    800058a8:	0127b423          	sd	s2,8(a5)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800058ac:	6698                	ld	a4,8(a3)
    800058ae:	00275783          	lhu	a5,2(a4)
    800058b2:	8b9d                	andi	a5,a5,7
    800058b4:	0786                	slli	a5,a5,0x1
    800058b6:	97ba                	add	a5,a5,a4
    800058b8:	00c79223          	sh	a2,4(a5)

  __sync_synchronize();
    800058bc:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800058c0:	6698                	ld	a4,8(a3)
    800058c2:	00275783          	lhu	a5,2(a4)
    800058c6:	2785                	addiw	a5,a5,1
    800058c8:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800058cc:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800058d0:	100017b7          	lui	a5,0x10001
    800058d4:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800058d8:	00492703          	lw	a4,4(s2)
    800058dc:	4785                	li	a5,1
    800058de:	02f71163          	bne	a4,a5,80005900 <virtio_disk_rw+0x1e8>
    sleep(b, &disk.vdisk_lock);
    800058e2:	00234997          	auipc	s3,0x234
    800058e6:	26e98993          	addi	s3,s3,622 # 80239b50 <disk+0x128>
  while(b->disk == 1) {
    800058ea:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    800058ec:	85ce                	mv	a1,s3
    800058ee:	854a                	mv	a0,s2
    800058f0:	ffffc097          	auipc	ra,0xffffc
    800058f4:	ebe080e7          	jalr	-322(ra) # 800017ae <sleep>
  while(b->disk == 1) {
    800058f8:	00492783          	lw	a5,4(s2)
    800058fc:	fe9788e3          	beq	a5,s1,800058ec <virtio_disk_rw+0x1d4>
  }

  disk.info[idx[0]].b = 0;
    80005900:	f9042903          	lw	s2,-112(s0)
    80005904:	00290793          	addi	a5,s2,2
    80005908:	00479713          	slli	a4,a5,0x4
    8000590c:	00234797          	auipc	a5,0x234
    80005910:	11c78793          	addi	a5,a5,284 # 80239a28 <disk>
    80005914:	97ba                	add	a5,a5,a4
    80005916:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000591a:	00234997          	auipc	s3,0x234
    8000591e:	10e98993          	addi	s3,s3,270 # 80239a28 <disk>
    80005922:	00491713          	slli	a4,s2,0x4
    80005926:	0009b783          	ld	a5,0(s3)
    8000592a:	97ba                	add	a5,a5,a4
    8000592c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005930:	854a                	mv	a0,s2
    80005932:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005936:	00000097          	auipc	ra,0x0
    8000593a:	b70080e7          	jalr	-1168(ra) # 800054a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    8000593e:	8885                	andi	s1,s1,1
    80005940:	f0ed                	bnez	s1,80005922 <virtio_disk_rw+0x20a>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005942:	00234517          	auipc	a0,0x234
    80005946:	20e50513          	addi	a0,a0,526 # 80239b50 <disk+0x128>
    8000594a:	00001097          	auipc	ra,0x1
    8000594e:	c36080e7          	jalr	-970(ra) # 80006580 <release>
}
    80005952:	70a6                	ld	ra,104(sp)
    80005954:	7406                	ld	s0,96(sp)
    80005956:	64e6                	ld	s1,88(sp)
    80005958:	6946                	ld	s2,80(sp)
    8000595a:	69a6                	ld	s3,72(sp)
    8000595c:	6a06                	ld	s4,64(sp)
    8000595e:	7ae2                	ld	s5,56(sp)
    80005960:	7b42                	ld	s6,48(sp)
    80005962:	7ba2                	ld	s7,40(sp)
    80005964:	7c02                	ld	s8,32(sp)
    80005966:	6ce2                	ld	s9,24(sp)
    80005968:	6d42                	ld	s10,16(sp)
    8000596a:	6165                	addi	sp,sp,112
    8000596c:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000596e:	4689                	li	a3,2
    80005970:	00d79623          	sh	a3,12(a5)
    80005974:	b5e5                	j	8000585c <virtio_disk_rw+0x144>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005976:	f9042603          	lw	a2,-112(s0)
    8000597a:	00a60713          	addi	a4,a2,10
    8000597e:	0712                	slli	a4,a4,0x4
    80005980:	00234517          	auipc	a0,0x234
    80005984:	0b050513          	addi	a0,a0,176 # 80239a30 <disk+0x8>
    80005988:	953a                	add	a0,a0,a4
  if(write)
    8000598a:	e60d14e3          	bnez	s10,800057f2 <virtio_disk_rw+0xda>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    8000598e:	00a60793          	addi	a5,a2,10
    80005992:	00479693          	slli	a3,a5,0x4
    80005996:	00234797          	auipc	a5,0x234
    8000599a:	09278793          	addi	a5,a5,146 # 80239a28 <disk>
    8000599e:	97b6                	add	a5,a5,a3
    800059a0:	0007a423          	sw	zero,8(a5)
    800059a4:	b595                	j	80005808 <virtio_disk_rw+0xf0>

00000000800059a6 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059a6:	1101                	addi	sp,sp,-32
    800059a8:	ec06                	sd	ra,24(sp)
    800059aa:	e822                	sd	s0,16(sp)
    800059ac:	e426                	sd	s1,8(sp)
    800059ae:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059b0:	00234497          	auipc	s1,0x234
    800059b4:	07848493          	addi	s1,s1,120 # 80239a28 <disk>
    800059b8:	00234517          	auipc	a0,0x234
    800059bc:	19850513          	addi	a0,a0,408 # 80239b50 <disk+0x128>
    800059c0:	00001097          	auipc	ra,0x1
    800059c4:	b0c080e7          	jalr	-1268(ra) # 800064cc <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800059c8:	10001737          	lui	a4,0x10001
    800059cc:	533c                	lw	a5,96(a4)
    800059ce:	8b8d                	andi	a5,a5,3
    800059d0:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800059d2:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800059d6:	689c                	ld	a5,16(s1)
    800059d8:	0204d703          	lhu	a4,32(s1)
    800059dc:	0027d783          	lhu	a5,2(a5)
    800059e0:	04f70863          	beq	a4,a5,80005a30 <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800059e4:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800059e8:	6898                	ld	a4,16(s1)
    800059ea:	0204d783          	lhu	a5,32(s1)
    800059ee:	8b9d                	andi	a5,a5,7
    800059f0:	078e                	slli	a5,a5,0x3
    800059f2:	97ba                	add	a5,a5,a4
    800059f4:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800059f6:	00278713          	addi	a4,a5,2
    800059fa:	0712                	slli	a4,a4,0x4
    800059fc:	9726                	add	a4,a4,s1
    800059fe:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80005a02:	e721                	bnez	a4,80005a4a <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a04:	0789                	addi	a5,a5,2
    80005a06:	0792                	slli	a5,a5,0x4
    80005a08:	97a6                	add	a5,a5,s1
    80005a0a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a0c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a10:	ffffc097          	auipc	ra,0xffffc
    80005a14:	e02080e7          	jalr	-510(ra) # 80001812 <wakeup>

    disk.used_idx += 1;
    80005a18:	0204d783          	lhu	a5,32(s1)
    80005a1c:	2785                	addiw	a5,a5,1
    80005a1e:	17c2                	slli	a5,a5,0x30
    80005a20:	93c1                	srli	a5,a5,0x30
    80005a22:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a26:	6898                	ld	a4,16(s1)
    80005a28:	00275703          	lhu	a4,2(a4)
    80005a2c:	faf71ce3          	bne	a4,a5,800059e4 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a30:	00234517          	auipc	a0,0x234
    80005a34:	12050513          	addi	a0,a0,288 # 80239b50 <disk+0x128>
    80005a38:	00001097          	auipc	ra,0x1
    80005a3c:	b48080e7          	jalr	-1208(ra) # 80006580 <release>
}
    80005a40:	60e2                	ld	ra,24(sp)
    80005a42:	6442                	ld	s0,16(sp)
    80005a44:	64a2                	ld	s1,8(sp)
    80005a46:	6105                	addi	sp,sp,32
    80005a48:	8082                	ret
      panic("virtio_disk_intr status");
    80005a4a:	00003517          	auipc	a0,0x3
    80005a4e:	d9e50513          	addi	a0,a0,-610 # 800087e8 <syscalls+0x3d8>
    80005a52:	00000097          	auipc	ra,0x0
    80005a56:	530080e7          	jalr	1328(ra) # 80005f82 <panic>

0000000080005a5a <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    80005a5a:	1141                	addi	sp,sp,-16
    80005a5c:	e422                	sd	s0,8(sp)
    80005a5e:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005a60:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80005a64:	0007869b          	sext.w	a3,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80005a68:	0037979b          	slliw	a5,a5,0x3
    80005a6c:	02004737          	lui	a4,0x2004
    80005a70:	97ba                	add	a5,a5,a4
    80005a72:	0200c737          	lui	a4,0x200c
    80005a76:	ff873583          	ld	a1,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80005a7a:	000f4637          	lui	a2,0xf4
    80005a7e:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80005a82:	95b2                	add	a1,a1,a2
    80005a84:	e38c                	sd	a1,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80005a86:	00269713          	slli	a4,a3,0x2
    80005a8a:	9736                	add	a4,a4,a3
    80005a8c:	00371693          	slli	a3,a4,0x3
    80005a90:	00234717          	auipc	a4,0x234
    80005a94:	0e070713          	addi	a4,a4,224 # 80239b70 <timer_scratch>
    80005a98:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    80005a9a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    80005a9c:	f310                	sd	a2,32(a4)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80005a9e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80005aa2:	00000797          	auipc	a5,0x0
    80005aa6:	93e78793          	addi	a5,a5,-1730 # 800053e0 <timervec>
    80005aaa:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005aae:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80005ab2:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005ab6:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80005aba:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80005abe:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80005ac2:	30479073          	csrw	mie,a5
}
    80005ac6:	6422                	ld	s0,8(sp)
    80005ac8:	0141                	addi	sp,sp,16
    80005aca:	8082                	ret

0000000080005acc <start>:
{
    80005acc:	1141                	addi	sp,sp,-16
    80005ace:	e406                	sd	ra,8(sp)
    80005ad0:	e022                	sd	s0,0(sp)
    80005ad2:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80005ad4:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80005ad8:	7779                	lui	a4,0xffffe
    80005ada:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fdbca4f>
    80005ade:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80005ae0:	6705                	lui	a4,0x1
    80005ae2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    80005ae6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80005ae8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80005aec:	ffffb797          	auipc	a5,0xffffb
    80005af0:	a5e78793          	addi	a5,a5,-1442 # 8000054a <main>
    80005af4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80005af8:	4781                	li	a5,0
    80005afa:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80005afe:	67c1                	lui	a5,0x10
    80005b00:	17fd                	addi	a5,a5,-1
    80005b02:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    80005b06:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    80005b0a:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80005b0e:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80005b12:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    80005b16:	57fd                	li	a5,-1
    80005b18:	83a9                	srli	a5,a5,0xa
    80005b1a:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80005b1e:	47bd                	li	a5,15
    80005b20:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    80005b24:	00000097          	auipc	ra,0x0
    80005b28:	f36080e7          	jalr	-202(ra) # 80005a5a <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80005b2c:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80005b30:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80005b32:	823e                	mv	tp,a5
  asm volatile("mret");
    80005b34:	30200073          	mret
}
    80005b38:	60a2                	ld	ra,8(sp)
    80005b3a:	6402                	ld	s0,0(sp)
    80005b3c:	0141                	addi	sp,sp,16
    80005b3e:	8082                	ret

0000000080005b40 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80005b40:	715d                	addi	sp,sp,-80
    80005b42:	e486                	sd	ra,72(sp)
    80005b44:	e0a2                	sd	s0,64(sp)
    80005b46:	fc26                	sd	s1,56(sp)
    80005b48:	f84a                	sd	s2,48(sp)
    80005b4a:	f44e                	sd	s3,40(sp)
    80005b4c:	f052                	sd	s4,32(sp)
    80005b4e:	ec56                	sd	s5,24(sp)
    80005b50:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80005b52:	04c05663          	blez	a2,80005b9e <consolewrite+0x5e>
    80005b56:	8a2a                	mv	s4,a0
    80005b58:	84ae                	mv	s1,a1
    80005b5a:	89b2                	mv	s3,a2
    80005b5c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80005b5e:	5afd                	li	s5,-1
    80005b60:	4685                	li	a3,1
    80005b62:	8626                	mv	a2,s1
    80005b64:	85d2                	mv	a1,s4
    80005b66:	fbf40513          	addi	a0,s0,-65
    80005b6a:	ffffc097          	auipc	ra,0xffffc
    80005b6e:	0a2080e7          	jalr	162(ra) # 80001c0c <either_copyin>
    80005b72:	01550c63          	beq	a0,s5,80005b8a <consolewrite+0x4a>
      break;
    uartputc(c);
    80005b76:	fbf44503          	lbu	a0,-65(s0)
    80005b7a:	00000097          	auipc	ra,0x0
    80005b7e:	794080e7          	jalr	1940(ra) # 8000630e <uartputc>
  for(i = 0; i < n; i++){
    80005b82:	2905                	addiw	s2,s2,1
    80005b84:	0485                	addi	s1,s1,1
    80005b86:	fd299de3          	bne	s3,s2,80005b60 <consolewrite+0x20>
  }

  return i;
}
    80005b8a:	854a                	mv	a0,s2
    80005b8c:	60a6                	ld	ra,72(sp)
    80005b8e:	6406                	ld	s0,64(sp)
    80005b90:	74e2                	ld	s1,56(sp)
    80005b92:	7942                	ld	s2,48(sp)
    80005b94:	79a2                	ld	s3,40(sp)
    80005b96:	7a02                	ld	s4,32(sp)
    80005b98:	6ae2                	ld	s5,24(sp)
    80005b9a:	6161                	addi	sp,sp,80
    80005b9c:	8082                	ret
  for(i = 0; i < n; i++){
    80005b9e:	4901                	li	s2,0
    80005ba0:	b7ed                	j	80005b8a <consolewrite+0x4a>

0000000080005ba2 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80005ba2:	7119                	addi	sp,sp,-128
    80005ba4:	fc86                	sd	ra,120(sp)
    80005ba6:	f8a2                	sd	s0,112(sp)
    80005ba8:	f4a6                	sd	s1,104(sp)
    80005baa:	f0ca                	sd	s2,96(sp)
    80005bac:	ecce                	sd	s3,88(sp)
    80005bae:	e8d2                	sd	s4,80(sp)
    80005bb0:	e4d6                	sd	s5,72(sp)
    80005bb2:	e0da                	sd	s6,64(sp)
    80005bb4:	fc5e                	sd	s7,56(sp)
    80005bb6:	f862                	sd	s8,48(sp)
    80005bb8:	f466                	sd	s9,40(sp)
    80005bba:	f06a                	sd	s10,32(sp)
    80005bbc:	ec6e                	sd	s11,24(sp)
    80005bbe:	0100                	addi	s0,sp,128
    80005bc0:	8b2a                	mv	s6,a0
    80005bc2:	8aae                	mv	s5,a1
    80005bc4:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80005bc6:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    80005bca:	0023c517          	auipc	a0,0x23c
    80005bce:	0e650513          	addi	a0,a0,230 # 80241cb0 <cons>
    80005bd2:	00001097          	auipc	ra,0x1
    80005bd6:	8fa080e7          	jalr	-1798(ra) # 800064cc <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80005bda:	0023c497          	auipc	s1,0x23c
    80005bde:	0d648493          	addi	s1,s1,214 # 80241cb0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80005be2:	89a6                	mv	s3,s1
    80005be4:	0023c917          	auipc	s2,0x23c
    80005be8:	16490913          	addi	s2,s2,356 # 80241d48 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    80005bec:	4c91                	li	s9,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005bee:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    80005bf0:	4da9                	li	s11,10
  while(n > 0){
    80005bf2:	07405b63          	blez	s4,80005c68 <consoleread+0xc6>
    while(cons.r == cons.w){
    80005bf6:	0984a783          	lw	a5,152(s1)
    80005bfa:	09c4a703          	lw	a4,156(s1)
    80005bfe:	02f71763          	bne	a4,a5,80005c2c <consoleread+0x8a>
      if(killed(myproc())){
    80005c02:	ffffb097          	auipc	ra,0xffffb
    80005c06:	508080e7          	jalr	1288(ra) # 8000110a <myproc>
    80005c0a:	ffffc097          	auipc	ra,0xffffc
    80005c0e:	e4c080e7          	jalr	-436(ra) # 80001a56 <killed>
    80005c12:	e535                	bnez	a0,80005c7e <consoleread+0xdc>
      sleep(&cons.r, &cons.lock);
    80005c14:	85ce                	mv	a1,s3
    80005c16:	854a                	mv	a0,s2
    80005c18:	ffffc097          	auipc	ra,0xffffc
    80005c1c:	b96080e7          	jalr	-1130(ra) # 800017ae <sleep>
    while(cons.r == cons.w){
    80005c20:	0984a783          	lw	a5,152(s1)
    80005c24:	09c4a703          	lw	a4,156(s1)
    80005c28:	fcf70de3          	beq	a4,a5,80005c02 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    80005c2c:	0017871b          	addiw	a4,a5,1
    80005c30:	08e4ac23          	sw	a4,152(s1)
    80005c34:	07f7f713          	andi	a4,a5,127
    80005c38:	9726                	add	a4,a4,s1
    80005c3a:	01874703          	lbu	a4,24(a4)
    80005c3e:	00070c1b          	sext.w	s8,a4
    if(c == C('D')){  // end-of-file
    80005c42:	079c0663          	beq	s8,s9,80005cae <consoleread+0x10c>
    cbuf = c;
    80005c46:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80005c4a:	4685                	li	a3,1
    80005c4c:	f8f40613          	addi	a2,s0,-113
    80005c50:	85d6                	mv	a1,s5
    80005c52:	855a                	mv	a0,s6
    80005c54:	ffffc097          	auipc	ra,0xffffc
    80005c58:	f62080e7          	jalr	-158(ra) # 80001bb6 <either_copyout>
    80005c5c:	01a50663          	beq	a0,s10,80005c68 <consoleread+0xc6>
    dst++;
    80005c60:	0a85                	addi	s5,s5,1
    --n;
    80005c62:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80005c64:	f9bc17e3          	bne	s8,s11,80005bf2 <consoleread+0x50>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80005c68:	0023c517          	auipc	a0,0x23c
    80005c6c:	04850513          	addi	a0,a0,72 # 80241cb0 <cons>
    80005c70:	00001097          	auipc	ra,0x1
    80005c74:	910080e7          	jalr	-1776(ra) # 80006580 <release>

  return target - n;
    80005c78:	414b853b          	subw	a0,s7,s4
    80005c7c:	a811                	j	80005c90 <consoleread+0xee>
        release(&cons.lock);
    80005c7e:	0023c517          	auipc	a0,0x23c
    80005c82:	03250513          	addi	a0,a0,50 # 80241cb0 <cons>
    80005c86:	00001097          	auipc	ra,0x1
    80005c8a:	8fa080e7          	jalr	-1798(ra) # 80006580 <release>
        return -1;
    80005c8e:	557d                	li	a0,-1
}
    80005c90:	70e6                	ld	ra,120(sp)
    80005c92:	7446                	ld	s0,112(sp)
    80005c94:	74a6                	ld	s1,104(sp)
    80005c96:	7906                	ld	s2,96(sp)
    80005c98:	69e6                	ld	s3,88(sp)
    80005c9a:	6a46                	ld	s4,80(sp)
    80005c9c:	6aa6                	ld	s5,72(sp)
    80005c9e:	6b06                	ld	s6,64(sp)
    80005ca0:	7be2                	ld	s7,56(sp)
    80005ca2:	7c42                	ld	s8,48(sp)
    80005ca4:	7ca2                	ld	s9,40(sp)
    80005ca6:	7d02                	ld	s10,32(sp)
    80005ca8:	6de2                	ld	s11,24(sp)
    80005caa:	6109                	addi	sp,sp,128
    80005cac:	8082                	ret
      if(n < target){
    80005cae:	000a071b          	sext.w	a4,s4
    80005cb2:	fb777be3          	bgeu	a4,s7,80005c68 <consoleread+0xc6>
        cons.r--;
    80005cb6:	0023c717          	auipc	a4,0x23c
    80005cba:	08f72923          	sw	a5,146(a4) # 80241d48 <cons+0x98>
    80005cbe:	b76d                	j	80005c68 <consoleread+0xc6>

0000000080005cc0 <consputc>:
{
    80005cc0:	1141                	addi	sp,sp,-16
    80005cc2:	e406                	sd	ra,8(sp)
    80005cc4:	e022                	sd	s0,0(sp)
    80005cc6:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80005cc8:	10000793          	li	a5,256
    80005ccc:	00f50a63          	beq	a0,a5,80005ce0 <consputc+0x20>
    uartputc_sync(c);
    80005cd0:	00000097          	auipc	ra,0x0
    80005cd4:	564080e7          	jalr	1380(ra) # 80006234 <uartputc_sync>
}
    80005cd8:	60a2                	ld	ra,8(sp)
    80005cda:	6402                	ld	s0,0(sp)
    80005cdc:	0141                	addi	sp,sp,16
    80005cde:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80005ce0:	4521                	li	a0,8
    80005ce2:	00000097          	auipc	ra,0x0
    80005ce6:	552080e7          	jalr	1362(ra) # 80006234 <uartputc_sync>
    80005cea:	02000513          	li	a0,32
    80005cee:	00000097          	auipc	ra,0x0
    80005cf2:	546080e7          	jalr	1350(ra) # 80006234 <uartputc_sync>
    80005cf6:	4521                	li	a0,8
    80005cf8:	00000097          	auipc	ra,0x0
    80005cfc:	53c080e7          	jalr	1340(ra) # 80006234 <uartputc_sync>
    80005d00:	bfe1                	j	80005cd8 <consputc+0x18>

0000000080005d02 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80005d02:	1101                	addi	sp,sp,-32
    80005d04:	ec06                	sd	ra,24(sp)
    80005d06:	e822                	sd	s0,16(sp)
    80005d08:	e426                	sd	s1,8(sp)
    80005d0a:	e04a                	sd	s2,0(sp)
    80005d0c:	1000                	addi	s0,sp,32
    80005d0e:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80005d10:	0023c517          	auipc	a0,0x23c
    80005d14:	fa050513          	addi	a0,a0,-96 # 80241cb0 <cons>
    80005d18:	00000097          	auipc	ra,0x0
    80005d1c:	7b4080e7          	jalr	1972(ra) # 800064cc <acquire>

  switch(c){
    80005d20:	47d5                	li	a5,21
    80005d22:	0af48663          	beq	s1,a5,80005dce <consoleintr+0xcc>
    80005d26:	0297ca63          	blt	a5,s1,80005d5a <consoleintr+0x58>
    80005d2a:	47a1                	li	a5,8
    80005d2c:	0ef48763          	beq	s1,a5,80005e1a <consoleintr+0x118>
    80005d30:	47c1                	li	a5,16
    80005d32:	10f49a63          	bne	s1,a5,80005e46 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    80005d36:	ffffc097          	auipc	ra,0xffffc
    80005d3a:	f2c080e7          	jalr	-212(ra) # 80001c62 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80005d3e:	0023c517          	auipc	a0,0x23c
    80005d42:	f7250513          	addi	a0,a0,-142 # 80241cb0 <cons>
    80005d46:	00001097          	auipc	ra,0x1
    80005d4a:	83a080e7          	jalr	-1990(ra) # 80006580 <release>
}
    80005d4e:	60e2                	ld	ra,24(sp)
    80005d50:	6442                	ld	s0,16(sp)
    80005d52:	64a2                	ld	s1,8(sp)
    80005d54:	6902                	ld	s2,0(sp)
    80005d56:	6105                	addi	sp,sp,32
    80005d58:	8082                	ret
  switch(c){
    80005d5a:	07f00793          	li	a5,127
    80005d5e:	0af48e63          	beq	s1,a5,80005e1a <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005d62:	0023c717          	auipc	a4,0x23c
    80005d66:	f4e70713          	addi	a4,a4,-178 # 80241cb0 <cons>
    80005d6a:	0a072783          	lw	a5,160(a4)
    80005d6e:	09872703          	lw	a4,152(a4)
    80005d72:	9f99                	subw	a5,a5,a4
    80005d74:	07f00713          	li	a4,127
    80005d78:	fcf763e3          	bltu	a4,a5,80005d3e <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80005d7c:	47b5                	li	a5,13
    80005d7e:	0cf48763          	beq	s1,a5,80005e4c <consoleintr+0x14a>
      consputc(c);
    80005d82:	8526                	mv	a0,s1
    80005d84:	00000097          	auipc	ra,0x0
    80005d88:	f3c080e7          	jalr	-196(ra) # 80005cc0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005d8c:	0023c797          	auipc	a5,0x23c
    80005d90:	f2478793          	addi	a5,a5,-220 # 80241cb0 <cons>
    80005d94:	0a07a683          	lw	a3,160(a5)
    80005d98:	0016871b          	addiw	a4,a3,1
    80005d9c:	0007061b          	sext.w	a2,a4
    80005da0:	0ae7a023          	sw	a4,160(a5)
    80005da4:	07f6f693          	andi	a3,a3,127
    80005da8:	97b6                	add	a5,a5,a3
    80005daa:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80005dae:	47a9                	li	a5,10
    80005db0:	0cf48563          	beq	s1,a5,80005e7a <consoleintr+0x178>
    80005db4:	4791                	li	a5,4
    80005db6:	0cf48263          	beq	s1,a5,80005e7a <consoleintr+0x178>
    80005dba:	0023c797          	auipc	a5,0x23c
    80005dbe:	f8e7a783          	lw	a5,-114(a5) # 80241d48 <cons+0x98>
    80005dc2:	9f1d                	subw	a4,a4,a5
    80005dc4:	08000793          	li	a5,128
    80005dc8:	f6f71be3          	bne	a4,a5,80005d3e <consoleintr+0x3c>
    80005dcc:	a07d                	j	80005e7a <consoleintr+0x178>
    while(cons.e != cons.w &&
    80005dce:	0023c717          	auipc	a4,0x23c
    80005dd2:	ee270713          	addi	a4,a4,-286 # 80241cb0 <cons>
    80005dd6:	0a072783          	lw	a5,160(a4)
    80005dda:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005dde:	0023c497          	auipc	s1,0x23c
    80005de2:	ed248493          	addi	s1,s1,-302 # 80241cb0 <cons>
    while(cons.e != cons.w &&
    80005de6:	4929                	li	s2,10
    80005de8:	f4f70be3          	beq	a4,a5,80005d3e <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80005dec:	37fd                	addiw	a5,a5,-1
    80005dee:	07f7f713          	andi	a4,a5,127
    80005df2:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80005df4:	01874703          	lbu	a4,24(a4)
    80005df8:	f52703e3          	beq	a4,s2,80005d3e <consoleintr+0x3c>
      cons.e--;
    80005dfc:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    80005e00:	10000513          	li	a0,256
    80005e04:	00000097          	auipc	ra,0x0
    80005e08:	ebc080e7          	jalr	-324(ra) # 80005cc0 <consputc>
    while(cons.e != cons.w &&
    80005e0c:	0a04a783          	lw	a5,160(s1)
    80005e10:	09c4a703          	lw	a4,156(s1)
    80005e14:	fcf71ce3          	bne	a4,a5,80005dec <consoleintr+0xea>
    80005e18:	b71d                	j	80005d3e <consoleintr+0x3c>
    if(cons.e != cons.w){
    80005e1a:	0023c717          	auipc	a4,0x23c
    80005e1e:	e9670713          	addi	a4,a4,-362 # 80241cb0 <cons>
    80005e22:	0a072783          	lw	a5,160(a4)
    80005e26:	09c72703          	lw	a4,156(a4)
    80005e2a:	f0f70ae3          	beq	a4,a5,80005d3e <consoleintr+0x3c>
      cons.e--;
    80005e2e:	37fd                	addiw	a5,a5,-1
    80005e30:	0023c717          	auipc	a4,0x23c
    80005e34:	f2f72023          	sw	a5,-224(a4) # 80241d50 <cons+0xa0>
      consputc(BACKSPACE);
    80005e38:	10000513          	li	a0,256
    80005e3c:	00000097          	auipc	ra,0x0
    80005e40:	e84080e7          	jalr	-380(ra) # 80005cc0 <consputc>
    80005e44:	bded                	j	80005d3e <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80005e46:	ee048ce3          	beqz	s1,80005d3e <consoleintr+0x3c>
    80005e4a:	bf21                	j	80005d62 <consoleintr+0x60>
      consputc(c);
    80005e4c:	4529                	li	a0,10
    80005e4e:	00000097          	auipc	ra,0x0
    80005e52:	e72080e7          	jalr	-398(ra) # 80005cc0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80005e56:	0023c797          	auipc	a5,0x23c
    80005e5a:	e5a78793          	addi	a5,a5,-422 # 80241cb0 <cons>
    80005e5e:	0a07a703          	lw	a4,160(a5)
    80005e62:	0017069b          	addiw	a3,a4,1
    80005e66:	0006861b          	sext.w	a2,a3
    80005e6a:	0ad7a023          	sw	a3,160(a5)
    80005e6e:	07f77713          	andi	a4,a4,127
    80005e72:	97ba                	add	a5,a5,a4
    80005e74:	4729                	li	a4,10
    80005e76:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80005e7a:	0023c797          	auipc	a5,0x23c
    80005e7e:	ecc7a923          	sw	a2,-302(a5) # 80241d4c <cons+0x9c>
        wakeup(&cons.r);
    80005e82:	0023c517          	auipc	a0,0x23c
    80005e86:	ec650513          	addi	a0,a0,-314 # 80241d48 <cons+0x98>
    80005e8a:	ffffc097          	auipc	ra,0xffffc
    80005e8e:	988080e7          	jalr	-1656(ra) # 80001812 <wakeup>
    80005e92:	b575                	j	80005d3e <consoleintr+0x3c>

0000000080005e94 <consoleinit>:

void
consoleinit(void)
{
    80005e94:	1141                	addi	sp,sp,-16
    80005e96:	e406                	sd	ra,8(sp)
    80005e98:	e022                	sd	s0,0(sp)
    80005e9a:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80005e9c:	00003597          	auipc	a1,0x3
    80005ea0:	96458593          	addi	a1,a1,-1692 # 80008800 <syscalls+0x3f0>
    80005ea4:	0023c517          	auipc	a0,0x23c
    80005ea8:	e0c50513          	addi	a0,a0,-500 # 80241cb0 <cons>
    80005eac:	00000097          	auipc	ra,0x0
    80005eb0:	590080e7          	jalr	1424(ra) # 8000643c <initlock>

  uartinit();
    80005eb4:	00000097          	auipc	ra,0x0
    80005eb8:	330080e7          	jalr	816(ra) # 800061e4 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80005ebc:	00233797          	auipc	a5,0x233
    80005ec0:	b1478793          	addi	a5,a5,-1260 # 802389d0 <devsw>
    80005ec4:	00000717          	auipc	a4,0x0
    80005ec8:	cde70713          	addi	a4,a4,-802 # 80005ba2 <consoleread>
    80005ecc:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80005ece:	00000717          	auipc	a4,0x0
    80005ed2:	c7270713          	addi	a4,a4,-910 # 80005b40 <consolewrite>
    80005ed6:	ef98                	sd	a4,24(a5)
}
    80005ed8:	60a2                	ld	ra,8(sp)
    80005eda:	6402                	ld	s0,0(sp)
    80005edc:	0141                	addi	sp,sp,16
    80005ede:	8082                	ret

0000000080005ee0 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80005ee0:	7179                	addi	sp,sp,-48
    80005ee2:	f406                	sd	ra,40(sp)
    80005ee4:	f022                	sd	s0,32(sp)
    80005ee6:	ec26                	sd	s1,24(sp)
    80005ee8:	e84a                	sd	s2,16(sp)
    80005eea:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80005eec:	c219                	beqz	a2,80005ef2 <printint+0x12>
    80005eee:	08054663          	bltz	a0,80005f7a <printint+0x9a>
    x = -xx;
  else
    x = xx;
    80005ef2:	2501                	sext.w	a0,a0
    80005ef4:	4881                	li	a7,0
    80005ef6:	fd040693          	addi	a3,s0,-48

  i = 0;
    80005efa:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    80005efc:	2581                	sext.w	a1,a1
    80005efe:	00003617          	auipc	a2,0x3
    80005f02:	93260613          	addi	a2,a2,-1742 # 80008830 <digits>
    80005f06:	883a                	mv	a6,a4
    80005f08:	2705                	addiw	a4,a4,1
    80005f0a:	02b577bb          	remuw	a5,a0,a1
    80005f0e:	1782                	slli	a5,a5,0x20
    80005f10:	9381                	srli	a5,a5,0x20
    80005f12:	97b2                	add	a5,a5,a2
    80005f14:	0007c783          	lbu	a5,0(a5)
    80005f18:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    80005f1c:	0005079b          	sext.w	a5,a0
    80005f20:	02b5553b          	divuw	a0,a0,a1
    80005f24:	0685                	addi	a3,a3,1
    80005f26:	feb7f0e3          	bgeu	a5,a1,80005f06 <printint+0x26>

  if(sign)
    80005f2a:	00088b63          	beqz	a7,80005f40 <printint+0x60>
    buf[i++] = '-';
    80005f2e:	fe040793          	addi	a5,s0,-32
    80005f32:	973e                	add	a4,a4,a5
    80005f34:	02d00793          	li	a5,45
    80005f38:	fef70823          	sb	a5,-16(a4)
    80005f3c:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80005f40:	02e05763          	blez	a4,80005f6e <printint+0x8e>
    80005f44:	fd040793          	addi	a5,s0,-48
    80005f48:	00e784b3          	add	s1,a5,a4
    80005f4c:	fff78913          	addi	s2,a5,-1
    80005f50:	993a                	add	s2,s2,a4
    80005f52:	377d                	addiw	a4,a4,-1
    80005f54:	1702                	slli	a4,a4,0x20
    80005f56:	9301                	srli	a4,a4,0x20
    80005f58:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80005f5c:	fff4c503          	lbu	a0,-1(s1)
    80005f60:	00000097          	auipc	ra,0x0
    80005f64:	d60080e7          	jalr	-672(ra) # 80005cc0 <consputc>
  while(--i >= 0)
    80005f68:	14fd                	addi	s1,s1,-1
    80005f6a:	ff2499e3          	bne	s1,s2,80005f5c <printint+0x7c>
}
    80005f6e:	70a2                	ld	ra,40(sp)
    80005f70:	7402                	ld	s0,32(sp)
    80005f72:	64e2                	ld	s1,24(sp)
    80005f74:	6942                	ld	s2,16(sp)
    80005f76:	6145                	addi	sp,sp,48
    80005f78:	8082                	ret
    x = -xx;
    80005f7a:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80005f7e:	4885                	li	a7,1
    x = -xx;
    80005f80:	bf9d                	j	80005ef6 <printint+0x16>

0000000080005f82 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80005f82:	1101                	addi	sp,sp,-32
    80005f84:	ec06                	sd	ra,24(sp)
    80005f86:	e822                	sd	s0,16(sp)
    80005f88:	e426                	sd	s1,8(sp)
    80005f8a:	1000                	addi	s0,sp,32
    80005f8c:	84aa                	mv	s1,a0
  pr.locking = 0;
    80005f8e:	0023c797          	auipc	a5,0x23c
    80005f92:	de07a123          	sw	zero,-542(a5) # 80241d70 <pr+0x18>
  printf("panic: ");
    80005f96:	00003517          	auipc	a0,0x3
    80005f9a:	87250513          	addi	a0,a0,-1934 # 80008808 <syscalls+0x3f8>
    80005f9e:	00000097          	auipc	ra,0x0
    80005fa2:	02e080e7          	jalr	46(ra) # 80005fcc <printf>
  printf(s);
    80005fa6:	8526                	mv	a0,s1
    80005fa8:	00000097          	auipc	ra,0x0
    80005fac:	024080e7          	jalr	36(ra) # 80005fcc <printf>
  printf("\n");
    80005fb0:	00002517          	auipc	a0,0x2
    80005fb4:	0d850513          	addi	a0,a0,216 # 80008088 <etext+0x88>
    80005fb8:	00000097          	auipc	ra,0x0
    80005fbc:	014080e7          	jalr	20(ra) # 80005fcc <printf>
  panicked = 1; // freeze uart output from other CPUs
    80005fc0:	4785                	li	a5,1
    80005fc2:	00003717          	auipc	a4,0x3
    80005fc6:	94f72523          	sw	a5,-1718(a4) # 8000890c <panicked>
  for(;;)
    80005fca:	a001                	j	80005fca <panic+0x48>

0000000080005fcc <printf>:
{
    80005fcc:	7131                	addi	sp,sp,-192
    80005fce:	fc86                	sd	ra,120(sp)
    80005fd0:	f8a2                	sd	s0,112(sp)
    80005fd2:	f4a6                	sd	s1,104(sp)
    80005fd4:	f0ca                	sd	s2,96(sp)
    80005fd6:	ecce                	sd	s3,88(sp)
    80005fd8:	e8d2                	sd	s4,80(sp)
    80005fda:	e4d6                	sd	s5,72(sp)
    80005fdc:	e0da                	sd	s6,64(sp)
    80005fde:	fc5e                	sd	s7,56(sp)
    80005fe0:	f862                	sd	s8,48(sp)
    80005fe2:	f466                	sd	s9,40(sp)
    80005fe4:	f06a                	sd	s10,32(sp)
    80005fe6:	ec6e                	sd	s11,24(sp)
    80005fe8:	0100                	addi	s0,sp,128
    80005fea:	8a2a                	mv	s4,a0
    80005fec:	e40c                	sd	a1,8(s0)
    80005fee:	e810                	sd	a2,16(s0)
    80005ff0:	ec14                	sd	a3,24(s0)
    80005ff2:	f018                	sd	a4,32(s0)
    80005ff4:	f41c                	sd	a5,40(s0)
    80005ff6:	03043823          	sd	a6,48(s0)
    80005ffa:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80005ffe:	0023cd97          	auipc	s11,0x23c
    80006002:	d72dad83          	lw	s11,-654(s11) # 80241d70 <pr+0x18>
  if(locking)
    80006006:	020d9b63          	bnez	s11,8000603c <printf+0x70>
  if (fmt == 0)
    8000600a:	040a0263          	beqz	s4,8000604e <printf+0x82>
  va_start(ap, fmt);
    8000600e:	00840793          	addi	a5,s0,8
    80006012:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80006016:	000a4503          	lbu	a0,0(s4)
    8000601a:	16050263          	beqz	a0,8000617e <printf+0x1b2>
    8000601e:	4481                	li	s1,0
    if(c != '%'){
    80006020:	02500a93          	li	s5,37
    switch(c){
    80006024:	07000b13          	li	s6,112
  consputc('x');
    80006028:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000602a:	00003b97          	auipc	s7,0x3
    8000602e:	806b8b93          	addi	s7,s7,-2042 # 80008830 <digits>
    switch(c){
    80006032:	07300c93          	li	s9,115
    80006036:	06400c13          	li	s8,100
    8000603a:	a82d                	j	80006074 <printf+0xa8>
    acquire(&pr.lock);
    8000603c:	0023c517          	auipc	a0,0x23c
    80006040:	d1c50513          	addi	a0,a0,-740 # 80241d58 <pr>
    80006044:	00000097          	auipc	ra,0x0
    80006048:	488080e7          	jalr	1160(ra) # 800064cc <acquire>
    8000604c:	bf7d                	j	8000600a <printf+0x3e>
    panic("null fmt");
    8000604e:	00002517          	auipc	a0,0x2
    80006052:	7ca50513          	addi	a0,a0,1994 # 80008818 <syscalls+0x408>
    80006056:	00000097          	auipc	ra,0x0
    8000605a:	f2c080e7          	jalr	-212(ra) # 80005f82 <panic>
      consputc(c);
    8000605e:	00000097          	auipc	ra,0x0
    80006062:	c62080e7          	jalr	-926(ra) # 80005cc0 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80006066:	2485                	addiw	s1,s1,1
    80006068:	009a07b3          	add	a5,s4,s1
    8000606c:	0007c503          	lbu	a0,0(a5)
    80006070:	10050763          	beqz	a0,8000617e <printf+0x1b2>
    if(c != '%'){
    80006074:	ff5515e3          	bne	a0,s5,8000605e <printf+0x92>
    c = fmt[++i] & 0xff;
    80006078:	2485                	addiw	s1,s1,1
    8000607a:	009a07b3          	add	a5,s4,s1
    8000607e:	0007c783          	lbu	a5,0(a5)
    80006082:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80006086:	cfe5                	beqz	a5,8000617e <printf+0x1b2>
    switch(c){
    80006088:	05678a63          	beq	a5,s6,800060dc <printf+0x110>
    8000608c:	02fb7663          	bgeu	s6,a5,800060b8 <printf+0xec>
    80006090:	09978963          	beq	a5,s9,80006122 <printf+0x156>
    80006094:	07800713          	li	a4,120
    80006098:	0ce79863          	bne	a5,a4,80006168 <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    8000609c:	f8843783          	ld	a5,-120(s0)
    800060a0:	00878713          	addi	a4,a5,8
    800060a4:	f8e43423          	sd	a4,-120(s0)
    800060a8:	4605                	li	a2,1
    800060aa:	85ea                	mv	a1,s10
    800060ac:	4388                	lw	a0,0(a5)
    800060ae:	00000097          	auipc	ra,0x0
    800060b2:	e32080e7          	jalr	-462(ra) # 80005ee0 <printint>
      break;
    800060b6:	bf45                	j	80006066 <printf+0x9a>
    switch(c){
    800060b8:	0b578263          	beq	a5,s5,8000615c <printf+0x190>
    800060bc:	0b879663          	bne	a5,s8,80006168 <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    800060c0:	f8843783          	ld	a5,-120(s0)
    800060c4:	00878713          	addi	a4,a5,8
    800060c8:	f8e43423          	sd	a4,-120(s0)
    800060cc:	4605                	li	a2,1
    800060ce:	45a9                	li	a1,10
    800060d0:	4388                	lw	a0,0(a5)
    800060d2:	00000097          	auipc	ra,0x0
    800060d6:	e0e080e7          	jalr	-498(ra) # 80005ee0 <printint>
      break;
    800060da:	b771                	j	80006066 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800060dc:	f8843783          	ld	a5,-120(s0)
    800060e0:	00878713          	addi	a4,a5,8
    800060e4:	f8e43423          	sd	a4,-120(s0)
    800060e8:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800060ec:	03000513          	li	a0,48
    800060f0:	00000097          	auipc	ra,0x0
    800060f4:	bd0080e7          	jalr	-1072(ra) # 80005cc0 <consputc>
  consputc('x');
    800060f8:	07800513          	li	a0,120
    800060fc:	00000097          	auipc	ra,0x0
    80006100:	bc4080e7          	jalr	-1084(ra) # 80005cc0 <consputc>
    80006104:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006106:	03c9d793          	srli	a5,s3,0x3c
    8000610a:	97de                	add	a5,a5,s7
    8000610c:	0007c503          	lbu	a0,0(a5)
    80006110:	00000097          	auipc	ra,0x0
    80006114:	bb0080e7          	jalr	-1104(ra) # 80005cc0 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80006118:	0992                	slli	s3,s3,0x4
    8000611a:	397d                	addiw	s2,s2,-1
    8000611c:	fe0915e3          	bnez	s2,80006106 <printf+0x13a>
    80006120:	b799                	j	80006066 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    80006122:	f8843783          	ld	a5,-120(s0)
    80006126:	00878713          	addi	a4,a5,8
    8000612a:	f8e43423          	sd	a4,-120(s0)
    8000612e:	0007b903          	ld	s2,0(a5)
    80006132:	00090e63          	beqz	s2,8000614e <printf+0x182>
      for(; *s; s++)
    80006136:	00094503          	lbu	a0,0(s2)
    8000613a:	d515                	beqz	a0,80006066 <printf+0x9a>
        consputc(*s);
    8000613c:	00000097          	auipc	ra,0x0
    80006140:	b84080e7          	jalr	-1148(ra) # 80005cc0 <consputc>
      for(; *s; s++)
    80006144:	0905                	addi	s2,s2,1
    80006146:	00094503          	lbu	a0,0(s2)
    8000614a:	f96d                	bnez	a0,8000613c <printf+0x170>
    8000614c:	bf29                	j	80006066 <printf+0x9a>
        s = "(null)";
    8000614e:	00002917          	auipc	s2,0x2
    80006152:	6c290913          	addi	s2,s2,1730 # 80008810 <syscalls+0x400>
      for(; *s; s++)
    80006156:	02800513          	li	a0,40
    8000615a:	b7cd                	j	8000613c <printf+0x170>
      consputc('%');
    8000615c:	8556                	mv	a0,s5
    8000615e:	00000097          	auipc	ra,0x0
    80006162:	b62080e7          	jalr	-1182(ra) # 80005cc0 <consputc>
      break;
    80006166:	b701                	j	80006066 <printf+0x9a>
      consputc('%');
    80006168:	8556                	mv	a0,s5
    8000616a:	00000097          	auipc	ra,0x0
    8000616e:	b56080e7          	jalr	-1194(ra) # 80005cc0 <consputc>
      consputc(c);
    80006172:	854a                	mv	a0,s2
    80006174:	00000097          	auipc	ra,0x0
    80006178:	b4c080e7          	jalr	-1204(ra) # 80005cc0 <consputc>
      break;
    8000617c:	b5ed                	j	80006066 <printf+0x9a>
  if(locking)
    8000617e:	020d9163          	bnez	s11,800061a0 <printf+0x1d4>
}
    80006182:	70e6                	ld	ra,120(sp)
    80006184:	7446                	ld	s0,112(sp)
    80006186:	74a6                	ld	s1,104(sp)
    80006188:	7906                	ld	s2,96(sp)
    8000618a:	69e6                	ld	s3,88(sp)
    8000618c:	6a46                	ld	s4,80(sp)
    8000618e:	6aa6                	ld	s5,72(sp)
    80006190:	6b06                	ld	s6,64(sp)
    80006192:	7be2                	ld	s7,56(sp)
    80006194:	7c42                	ld	s8,48(sp)
    80006196:	7ca2                	ld	s9,40(sp)
    80006198:	7d02                	ld	s10,32(sp)
    8000619a:	6de2                	ld	s11,24(sp)
    8000619c:	6129                	addi	sp,sp,192
    8000619e:	8082                	ret
    release(&pr.lock);
    800061a0:	0023c517          	auipc	a0,0x23c
    800061a4:	bb850513          	addi	a0,a0,-1096 # 80241d58 <pr>
    800061a8:	00000097          	auipc	ra,0x0
    800061ac:	3d8080e7          	jalr	984(ra) # 80006580 <release>
}
    800061b0:	bfc9                	j	80006182 <printf+0x1b6>

00000000800061b2 <printfinit>:
    ;
}

void
printfinit(void)
{
    800061b2:	1101                	addi	sp,sp,-32
    800061b4:	ec06                	sd	ra,24(sp)
    800061b6:	e822                	sd	s0,16(sp)
    800061b8:	e426                	sd	s1,8(sp)
    800061ba:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800061bc:	0023c497          	auipc	s1,0x23c
    800061c0:	b9c48493          	addi	s1,s1,-1124 # 80241d58 <pr>
    800061c4:	00002597          	auipc	a1,0x2
    800061c8:	66458593          	addi	a1,a1,1636 # 80008828 <syscalls+0x418>
    800061cc:	8526                	mv	a0,s1
    800061ce:	00000097          	auipc	ra,0x0
    800061d2:	26e080e7          	jalr	622(ra) # 8000643c <initlock>
  pr.locking = 1;
    800061d6:	4785                	li	a5,1
    800061d8:	cc9c                	sw	a5,24(s1)
}
    800061da:	60e2                	ld	ra,24(sp)
    800061dc:	6442                	ld	s0,16(sp)
    800061de:	64a2                	ld	s1,8(sp)
    800061e0:	6105                	addi	sp,sp,32
    800061e2:	8082                	ret

00000000800061e4 <uartinit>:

void uartstart();

void
uartinit(void)
{
    800061e4:	1141                	addi	sp,sp,-16
    800061e6:	e406                	sd	ra,8(sp)
    800061e8:	e022                	sd	s0,0(sp)
    800061ea:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800061ec:	100007b7          	lui	a5,0x10000
    800061f0:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800061f4:	f8000713          	li	a4,-128
    800061f8:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800061fc:	470d                	li	a4,3
    800061fe:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80006202:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80006206:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000620a:	469d                	li	a3,7
    8000620c:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80006210:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    80006214:	00002597          	auipc	a1,0x2
    80006218:	63458593          	addi	a1,a1,1588 # 80008848 <digits+0x18>
    8000621c:	0023c517          	auipc	a0,0x23c
    80006220:	b5c50513          	addi	a0,a0,-1188 # 80241d78 <uart_tx_lock>
    80006224:	00000097          	auipc	ra,0x0
    80006228:	218080e7          	jalr	536(ra) # 8000643c <initlock>
}
    8000622c:	60a2                	ld	ra,8(sp)
    8000622e:	6402                	ld	s0,0(sp)
    80006230:	0141                	addi	sp,sp,16
    80006232:	8082                	ret

0000000080006234 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80006234:	1101                	addi	sp,sp,-32
    80006236:	ec06                	sd	ra,24(sp)
    80006238:	e822                	sd	s0,16(sp)
    8000623a:	e426                	sd	s1,8(sp)
    8000623c:	1000                	addi	s0,sp,32
    8000623e:	84aa                	mv	s1,a0
  push_off();
    80006240:	00000097          	auipc	ra,0x0
    80006244:	240080e7          	jalr	576(ra) # 80006480 <push_off>

  if(panicked){
    80006248:	00002797          	auipc	a5,0x2
    8000624c:	6c47a783          	lw	a5,1732(a5) # 8000890c <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006250:	10000737          	lui	a4,0x10000
  if(panicked){
    80006254:	c391                	beqz	a5,80006258 <uartputc_sync+0x24>
    for(;;)
    80006256:	a001                	j	80006256 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80006258:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    8000625c:	0ff7f793          	andi	a5,a5,255
    80006260:	0207f793          	andi	a5,a5,32
    80006264:	dbf5                	beqz	a5,80006258 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80006266:	0ff4f793          	andi	a5,s1,255
    8000626a:	10000737          	lui	a4,0x10000
    8000626e:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    80006272:	00000097          	auipc	ra,0x0
    80006276:	2ae080e7          	jalr	686(ra) # 80006520 <pop_off>
}
    8000627a:	60e2                	ld	ra,24(sp)
    8000627c:	6442                	ld	s0,16(sp)
    8000627e:	64a2                	ld	s1,8(sp)
    80006280:	6105                	addi	sp,sp,32
    80006282:	8082                	ret

0000000080006284 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80006284:	00002717          	auipc	a4,0x2
    80006288:	68c73703          	ld	a4,1676(a4) # 80008910 <uart_tx_r>
    8000628c:	00002797          	auipc	a5,0x2
    80006290:	68c7b783          	ld	a5,1676(a5) # 80008918 <uart_tx_w>
    80006294:	06e78c63          	beq	a5,a4,8000630c <uartstart+0x88>
{
    80006298:	7139                	addi	sp,sp,-64
    8000629a:	fc06                	sd	ra,56(sp)
    8000629c:	f822                	sd	s0,48(sp)
    8000629e:	f426                	sd	s1,40(sp)
    800062a0:	f04a                	sd	s2,32(sp)
    800062a2:	ec4e                	sd	s3,24(sp)
    800062a4:	e852                	sd	s4,16(sp)
    800062a6:	e456                	sd	s5,8(sp)
    800062a8:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800062aa:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800062ae:	0023ca17          	auipc	s4,0x23c
    800062b2:	acaa0a13          	addi	s4,s4,-1334 # 80241d78 <uart_tx_lock>
    uart_tx_r += 1;
    800062b6:	00002497          	auipc	s1,0x2
    800062ba:	65a48493          	addi	s1,s1,1626 # 80008910 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800062be:	00002997          	auipc	s3,0x2
    800062c2:	65a98993          	addi	s3,s3,1626 # 80008918 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800062c6:	00594783          	lbu	a5,5(s2) # 10000005 <_entry-0x6ffffffb>
    800062ca:	0ff7f793          	andi	a5,a5,255
    800062ce:	0207f793          	andi	a5,a5,32
    800062d2:	c785                	beqz	a5,800062fa <uartstart+0x76>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800062d4:	01f77793          	andi	a5,a4,31
    800062d8:	97d2                	add	a5,a5,s4
    800062da:	0187ca83          	lbu	s5,24(a5)
    uart_tx_r += 1;
    800062de:	0705                	addi	a4,a4,1
    800062e0:	e098                	sd	a4,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800062e2:	8526                	mv	a0,s1
    800062e4:	ffffb097          	auipc	ra,0xffffb
    800062e8:	52e080e7          	jalr	1326(ra) # 80001812 <wakeup>
    
    WriteReg(THR, c);
    800062ec:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800062f0:	6098                	ld	a4,0(s1)
    800062f2:	0009b783          	ld	a5,0(s3)
    800062f6:	fce798e3          	bne	a5,a4,800062c6 <uartstart+0x42>
  }
}
    800062fa:	70e2                	ld	ra,56(sp)
    800062fc:	7442                	ld	s0,48(sp)
    800062fe:	74a2                	ld	s1,40(sp)
    80006300:	7902                	ld	s2,32(sp)
    80006302:	69e2                	ld	s3,24(sp)
    80006304:	6a42                	ld	s4,16(sp)
    80006306:	6aa2                	ld	s5,8(sp)
    80006308:	6121                	addi	sp,sp,64
    8000630a:	8082                	ret
    8000630c:	8082                	ret

000000008000630e <uartputc>:
{
    8000630e:	7179                	addi	sp,sp,-48
    80006310:	f406                	sd	ra,40(sp)
    80006312:	f022                	sd	s0,32(sp)
    80006314:	ec26                	sd	s1,24(sp)
    80006316:	e84a                	sd	s2,16(sp)
    80006318:	e44e                	sd	s3,8(sp)
    8000631a:	e052                	sd	s4,0(sp)
    8000631c:	1800                	addi	s0,sp,48
    8000631e:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80006320:	0023c517          	auipc	a0,0x23c
    80006324:	a5850513          	addi	a0,a0,-1448 # 80241d78 <uart_tx_lock>
    80006328:	00000097          	auipc	ra,0x0
    8000632c:	1a4080e7          	jalr	420(ra) # 800064cc <acquire>
  if(panicked){
    80006330:	00002797          	auipc	a5,0x2
    80006334:	5dc7a783          	lw	a5,1500(a5) # 8000890c <panicked>
    80006338:	e7c9                	bnez	a5,800063c2 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000633a:	00002797          	auipc	a5,0x2
    8000633e:	5de7b783          	ld	a5,1502(a5) # 80008918 <uart_tx_w>
    80006342:	00002717          	auipc	a4,0x2
    80006346:	5ce73703          	ld	a4,1486(a4) # 80008910 <uart_tx_r>
    8000634a:	02070713          	addi	a4,a4,32
    sleep(&uart_tx_r, &uart_tx_lock);
    8000634e:	0023ca17          	auipc	s4,0x23c
    80006352:	a2aa0a13          	addi	s4,s4,-1494 # 80241d78 <uart_tx_lock>
    80006356:	00002497          	auipc	s1,0x2
    8000635a:	5ba48493          	addi	s1,s1,1466 # 80008910 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000635e:	00002917          	auipc	s2,0x2
    80006362:	5ba90913          	addi	s2,s2,1466 # 80008918 <uart_tx_w>
    80006366:	00f71f63          	bne	a4,a5,80006384 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000636a:	85d2                	mv	a1,s4
    8000636c:	8526                	mv	a0,s1
    8000636e:	ffffb097          	auipc	ra,0xffffb
    80006372:	440080e7          	jalr	1088(ra) # 800017ae <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80006376:	00093783          	ld	a5,0(s2)
    8000637a:	6098                	ld	a4,0(s1)
    8000637c:	02070713          	addi	a4,a4,32
    80006380:	fef705e3          	beq	a4,a5,8000636a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80006384:	0023c497          	auipc	s1,0x23c
    80006388:	9f448493          	addi	s1,s1,-1548 # 80241d78 <uart_tx_lock>
    8000638c:	01f7f713          	andi	a4,a5,31
    80006390:	9726                	add	a4,a4,s1
    80006392:	01370c23          	sb	s3,24(a4)
  uart_tx_w += 1;
    80006396:	0785                	addi	a5,a5,1
    80006398:	00002717          	auipc	a4,0x2
    8000639c:	58f73023          	sd	a5,1408(a4) # 80008918 <uart_tx_w>
  uartstart();
    800063a0:	00000097          	auipc	ra,0x0
    800063a4:	ee4080e7          	jalr	-284(ra) # 80006284 <uartstart>
  release(&uart_tx_lock);
    800063a8:	8526                	mv	a0,s1
    800063aa:	00000097          	auipc	ra,0x0
    800063ae:	1d6080e7          	jalr	470(ra) # 80006580 <release>
}
    800063b2:	70a2                	ld	ra,40(sp)
    800063b4:	7402                	ld	s0,32(sp)
    800063b6:	64e2                	ld	s1,24(sp)
    800063b8:	6942                	ld	s2,16(sp)
    800063ba:	69a2                	ld	s3,8(sp)
    800063bc:	6a02                	ld	s4,0(sp)
    800063be:	6145                	addi	sp,sp,48
    800063c0:	8082                	ret
    for(;;)
    800063c2:	a001                	j	800063c2 <uartputc+0xb4>

00000000800063c4 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800063c4:	1141                	addi	sp,sp,-16
    800063c6:	e422                	sd	s0,8(sp)
    800063c8:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800063ca:	100007b7          	lui	a5,0x10000
    800063ce:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800063d2:	8b85                	andi	a5,a5,1
    800063d4:	cb91                	beqz	a5,800063e8 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800063d6:	100007b7          	lui	a5,0x10000
    800063da:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    800063de:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    800063e2:	6422                	ld	s0,8(sp)
    800063e4:	0141                	addi	sp,sp,16
    800063e6:	8082                	ret
    return -1;
    800063e8:	557d                	li	a0,-1
    800063ea:	bfe5                	j	800063e2 <uartgetc+0x1e>

00000000800063ec <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800063ec:	1101                	addi	sp,sp,-32
    800063ee:	ec06                	sd	ra,24(sp)
    800063f0:	e822                	sd	s0,16(sp)
    800063f2:	e426                	sd	s1,8(sp)
    800063f4:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800063f6:	54fd                	li	s1,-1
    int c = uartgetc();
    800063f8:	00000097          	auipc	ra,0x0
    800063fc:	fcc080e7          	jalr	-52(ra) # 800063c4 <uartgetc>
    if(c == -1)
    80006400:	00950763          	beq	a0,s1,8000640e <uartintr+0x22>
      break;
    consoleintr(c);
    80006404:	00000097          	auipc	ra,0x0
    80006408:	8fe080e7          	jalr	-1794(ra) # 80005d02 <consoleintr>
  while(1){
    8000640c:	b7f5                	j	800063f8 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    8000640e:	0023c497          	auipc	s1,0x23c
    80006412:	96a48493          	addi	s1,s1,-1686 # 80241d78 <uart_tx_lock>
    80006416:	8526                	mv	a0,s1
    80006418:	00000097          	auipc	ra,0x0
    8000641c:	0b4080e7          	jalr	180(ra) # 800064cc <acquire>
  uartstart();
    80006420:	00000097          	auipc	ra,0x0
    80006424:	e64080e7          	jalr	-412(ra) # 80006284 <uartstart>
  release(&uart_tx_lock);
    80006428:	8526                	mv	a0,s1
    8000642a:	00000097          	auipc	ra,0x0
    8000642e:	156080e7          	jalr	342(ra) # 80006580 <release>
}
    80006432:	60e2                	ld	ra,24(sp)
    80006434:	6442                	ld	s0,16(sp)
    80006436:	64a2                	ld	s1,8(sp)
    80006438:	6105                	addi	sp,sp,32
    8000643a:	8082                	ret

000000008000643c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    8000643c:	1141                	addi	sp,sp,-16
    8000643e:	e422                	sd	s0,8(sp)
    80006440:	0800                	addi	s0,sp,16
  lk->name = name;
    80006442:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80006444:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80006448:	00053823          	sd	zero,16(a0)
}
    8000644c:	6422                	ld	s0,8(sp)
    8000644e:	0141                	addi	sp,sp,16
    80006450:	8082                	ret

0000000080006452 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80006452:	411c                	lw	a5,0(a0)
    80006454:	e399                	bnez	a5,8000645a <holding+0x8>
    80006456:	4501                	li	a0,0
  return r;
}
    80006458:	8082                	ret
{
    8000645a:	1101                	addi	sp,sp,-32
    8000645c:	ec06                	sd	ra,24(sp)
    8000645e:	e822                	sd	s0,16(sp)
    80006460:	e426                	sd	s1,8(sp)
    80006462:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80006464:	6904                	ld	s1,16(a0)
    80006466:	ffffb097          	auipc	ra,0xffffb
    8000646a:	c88080e7          	jalr	-888(ra) # 800010ee <mycpu>
    8000646e:	40a48533          	sub	a0,s1,a0
    80006472:	00153513          	seqz	a0,a0
}
    80006476:	60e2                	ld	ra,24(sp)
    80006478:	6442                	ld	s0,16(sp)
    8000647a:	64a2                	ld	s1,8(sp)
    8000647c:	6105                	addi	sp,sp,32
    8000647e:	8082                	ret

0000000080006480 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80006480:	1101                	addi	sp,sp,-32
    80006482:	ec06                	sd	ra,24(sp)
    80006484:	e822                	sd	s0,16(sp)
    80006486:	e426                	sd	s1,8(sp)
    80006488:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000648a:	100024f3          	csrr	s1,sstatus
    8000648e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80006492:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006494:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80006498:	ffffb097          	auipc	ra,0xffffb
    8000649c:	c56080e7          	jalr	-938(ra) # 800010ee <mycpu>
    800064a0:	5d3c                	lw	a5,120(a0)
    800064a2:	cf89                	beqz	a5,800064bc <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800064a4:	ffffb097          	auipc	ra,0xffffb
    800064a8:	c4a080e7          	jalr	-950(ra) # 800010ee <mycpu>
    800064ac:	5d3c                	lw	a5,120(a0)
    800064ae:	2785                	addiw	a5,a5,1
    800064b0:	dd3c                	sw	a5,120(a0)
}
    800064b2:	60e2                	ld	ra,24(sp)
    800064b4:	6442                	ld	s0,16(sp)
    800064b6:	64a2                	ld	s1,8(sp)
    800064b8:	6105                	addi	sp,sp,32
    800064ba:	8082                	ret
    mycpu()->intena = old;
    800064bc:	ffffb097          	auipc	ra,0xffffb
    800064c0:	c32080e7          	jalr	-974(ra) # 800010ee <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800064c4:	8085                	srli	s1,s1,0x1
    800064c6:	8885                	andi	s1,s1,1
    800064c8:	dd64                	sw	s1,124(a0)
    800064ca:	bfe9                	j	800064a4 <push_off+0x24>

00000000800064cc <acquire>:
{
    800064cc:	1101                	addi	sp,sp,-32
    800064ce:	ec06                	sd	ra,24(sp)
    800064d0:	e822                	sd	s0,16(sp)
    800064d2:	e426                	sd	s1,8(sp)
    800064d4:	1000                	addi	s0,sp,32
    800064d6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    800064d8:	00000097          	auipc	ra,0x0
    800064dc:	fa8080e7          	jalr	-88(ra) # 80006480 <push_off>
  if(holding(lk))
    800064e0:	8526                	mv	a0,s1
    800064e2:	00000097          	auipc	ra,0x0
    800064e6:	f70080e7          	jalr	-144(ra) # 80006452 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800064ea:	4705                	li	a4,1
  if(holding(lk))
    800064ec:	e115                	bnez	a0,80006510 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    800064ee:	87ba                	mv	a5,a4
    800064f0:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    800064f4:	2781                	sext.w	a5,a5
    800064f6:	ffe5                	bnez	a5,800064ee <acquire+0x22>
  __sync_synchronize();
    800064f8:	0ff0000f          	fence
  lk->cpu = mycpu();
    800064fc:	ffffb097          	auipc	ra,0xffffb
    80006500:	bf2080e7          	jalr	-1038(ra) # 800010ee <mycpu>
    80006504:	e888                	sd	a0,16(s1)
}
    80006506:	60e2                	ld	ra,24(sp)
    80006508:	6442                	ld	s0,16(sp)
    8000650a:	64a2                	ld	s1,8(sp)
    8000650c:	6105                	addi	sp,sp,32
    8000650e:	8082                	ret
    panic("acquire");
    80006510:	00002517          	auipc	a0,0x2
    80006514:	34050513          	addi	a0,a0,832 # 80008850 <digits+0x20>
    80006518:	00000097          	auipc	ra,0x0
    8000651c:	a6a080e7          	jalr	-1430(ra) # 80005f82 <panic>

0000000080006520 <pop_off>:

void
pop_off(void)
{
    80006520:	1141                	addi	sp,sp,-16
    80006522:	e406                	sd	ra,8(sp)
    80006524:	e022                	sd	s0,0(sp)
    80006526:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80006528:	ffffb097          	auipc	ra,0xffffb
    8000652c:	bc6080e7          	jalr	-1082(ra) # 800010ee <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80006530:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80006534:	8b89                	andi	a5,a5,2
  if(intr_get())
    80006536:	e78d                	bnez	a5,80006560 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80006538:	5d3c                	lw	a5,120(a0)
    8000653a:	02f05b63          	blez	a5,80006570 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    8000653e:	37fd                	addiw	a5,a5,-1
    80006540:	0007871b          	sext.w	a4,a5
    80006544:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80006546:	eb09                	bnez	a4,80006558 <pop_off+0x38>
    80006548:	5d7c                	lw	a5,124(a0)
    8000654a:	c799                	beqz	a5,80006558 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000654c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80006550:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80006554:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80006558:	60a2                	ld	ra,8(sp)
    8000655a:	6402                	ld	s0,0(sp)
    8000655c:	0141                	addi	sp,sp,16
    8000655e:	8082                	ret
    panic("pop_off - interruptible");
    80006560:	00002517          	auipc	a0,0x2
    80006564:	2f850513          	addi	a0,a0,760 # 80008858 <digits+0x28>
    80006568:	00000097          	auipc	ra,0x0
    8000656c:	a1a080e7          	jalr	-1510(ra) # 80005f82 <panic>
    panic("pop_off");
    80006570:	00002517          	auipc	a0,0x2
    80006574:	30050513          	addi	a0,a0,768 # 80008870 <digits+0x40>
    80006578:	00000097          	auipc	ra,0x0
    8000657c:	a0a080e7          	jalr	-1526(ra) # 80005f82 <panic>

0000000080006580 <release>:
{
    80006580:	1101                	addi	sp,sp,-32
    80006582:	ec06                	sd	ra,24(sp)
    80006584:	e822                	sd	s0,16(sp)
    80006586:	e426                	sd	s1,8(sp)
    80006588:	1000                	addi	s0,sp,32
    8000658a:	84aa                	mv	s1,a0
  if(!holding(lk))
    8000658c:	00000097          	auipc	ra,0x0
    80006590:	ec6080e7          	jalr	-314(ra) # 80006452 <holding>
    80006594:	c115                	beqz	a0,800065b8 <release+0x38>
  lk->cpu = 0;
    80006596:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    8000659a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    8000659e:	0f50000f          	fence	iorw,ow
    800065a2:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800065a6:	00000097          	auipc	ra,0x0
    800065aa:	f7a080e7          	jalr	-134(ra) # 80006520 <pop_off>
}
    800065ae:	60e2                	ld	ra,24(sp)
    800065b0:	6442                	ld	s0,16(sp)
    800065b2:	64a2                	ld	s1,8(sp)
    800065b4:	6105                	addi	sp,sp,32
    800065b6:	8082                	ret
    panic("release");
    800065b8:	00002517          	auipc	a0,0x2
    800065bc:	2c050513          	addi	a0,a0,704 # 80008878 <digits+0x48>
    800065c0:	00000097          	auipc	ra,0x0
    800065c4:	9c2080e7          	jalr	-1598(ra) # 80005f82 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
    800070ac:	357d                	addiw	a0,a0,-1
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0) # 2000028 <_entry-0x7dffffd8>
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
