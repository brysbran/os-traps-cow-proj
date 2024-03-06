// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  struct run *freelist;
} kmem;

//struct for page references
struct{
  struct spinlock lock;
  int count[PGROUNDUP(PHYSTOP)>>12]; //2^12 == 4096, aka 4k bytes aka size of page.
}page_ref;

//function to initialize page reference tracking for COW
void 
init_page_ref(){
  //initialize lock for the page ref sys
  initlock(&page_ref.lock, "page_ref");
  //free the lock before modifying
  acquire(&page_ref.lock);

//loop through every page (4K), set the reference count to 0
  for(int i = 0; i < (PGROUNDUP(PHYSTOP) >> 12); i++){
    page_ref.count[i] = 0;
  }
  //release the lock
  release(&page_ref.lock);
}


//when fork is called, instead of all pages being copied,
//the original processes pages are shared by Proc A and B, and 
//we use this reference incrementer to keep track of how many
//procs are pointing to a given page.
void 
inc_page_ref(void *pa){
  //free the lock before modifying
  acquire(&page_ref.lock);
 //if count is zero, memory mismanaged.
 //indexing the array of references by dividing the 
 //physical address by 12 (2^12==4096bytes aka size of a page)
  if(page_ref.count[(uint64)pa >> 12] <= 0){
    panic("inc_page_ref");
  }
  //increment ref count by 1
  page_ref.count[(uint64)pa >> 12] += 1;
  //release lock
   release(&page_ref.lock);
}

//when COW copies a page for a process, need to update 
// the reference count from the original page that was being pointed to from
//both processes.
void 
dec_page_ref(void *pa){
 acquire(&page_ref.lock);
 //if count is zero, memory mismanaged.
 //indexing the array of references by dividing the 
 //physical address by 12 (2^12==4096bytes aka size of a page)
 if(page_ref.count[(uint64) pa >> 12] <= 0){
  panic("dec_page_ref");
 }
//decrement reference count
 page_ref.count[(uint64)pa >> 12] -= 1;
 release(&page_ref.lock);
}

//return the reference count of a page,
//includes error checking if memory was mismanaged
//
int 
get_page_ref(void *pa){
  //acquire lock
  acquire(&page_ref.lock);
  int res = page_ref.count[(uint64)pa>>12]; //storing ref count
  if(page_ref.count[(uint64)pa>>12]<0){
    panic("get_page_ref");
  }
  release(&page_ref.lock); //release lock
  return res; //page ref count
}


void
kinit()
{
  //set reference counts of pages to zero initially
  init_page_ref();
  initlock(&kmem.lock, "kmem");
  freerange(end, (void*)PHYSTOP);
}

void
freerange(void *pa_start, void *pa_end)
{
  char *p;
  p = (char*)PGROUNDUP((uint64)pa_start);
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE){
    inc_page_ref(p);
    kfree(p);
  }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    panic("kfree");

  acquire(&page_ref.lock);
  //check if ref count is already zero
  if(page_ref.count[(uint64)pa>>12]<=0){
    panic("dec_page_ref");
  }
  //decrement ref count
  page_ref.count[(uint64)pa>>12]-=1;
  if(page_ref.count[(uint64)pa>>12]>0){
    release(&page_ref.lock);
    return;
  }
  release(&page_ref.lock);
  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);

  r = (struct run*)pa;

  acquire(&kmem.lock);
  r->next = kmem.freelist;
  kmem.freelist = r;
  release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r){
        memset((char*)r, 5, PGSIZE); // fill with junk
  }
  return (void*)r;
}
