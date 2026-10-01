#include "types.h"
#include "riscv.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
  int n;
  argint(0, &n);
  kexit(n);
  return 0; // not reached
}

uint64
sys_getpid(void)
{
  return myproc()->pid;
}

uint64
sys_fork(void)
{
  return kfork();
}

uint64
sys_wait(void)
{
  uint64 p;
  argaddr(0, &p);
  return kwait(p);
}

uint64
sys_sbrk(void)
{
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
  argint(1, &t);
  addr = myproc()->sz;

  if (t == SBRK_EAGER || n < 0) {
    if (growproc(n) < 0) {
      return -1;
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if (addr + n < addr)
      return -1;
    if (addr + n > TRAPFRAME)
      return -1;
    myproc()->sz += n;
  }
  return addr;
}

uint64
sys_pause(void)
{
  int n;
  uint ticks0;

  argint(0, &n);
  if (n < 0)
    n = 0;
  acquire(&tickslock);
  ticks0 = ticks;
  while (ticks - ticks0 < n) {
    if (killed(myproc())) {
      release(&tickslock);
      return -1;
    }
    sleep_prepare(&ticks);
    release(&tickslock);
    sleep();
    acquire(&tickslock);
  }
  release(&tickslock);
  return 0;
}

uint64
sys_kill(void)
{
  int pid;

  argint(0, &pid);
  return kkill(pid);
}

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
  uint xticks;

  acquire(&tickslock);
  xticks = ticks;
  release(&tickslock);
  return xticks;
}

// Read-only snapshot. Require an already-resident output buffer so taking
// a snapshot does not itself lazily allocate a destination page.
uint64
sys_getstats(void)
{
  uint64 dst;
  argaddr(0, &dst);
  struct proc *p = myproc();

  if (dst > p->sz || sizeof(struct benchstats) > p->sz - dst)
    return -1;

  uint64 end = dst + sizeof(struct benchstats);
  for (uint64 va = PGROUNDDOWN(dst); va < end; va += PGSIZE) {
    pte_t *pte = walk(p->pagetable, va, 0);
    if (pte == 0 ||
        (*pte & (PTE_V | PTE_U | PTE_W)) != (PTE_V | PTE_U | PTE_W))
      return -1;
  }

  struct benchstats s = p->bstats;
  s.virtual_bytes = p->sz;
  s.resident_pages = 0;
  for (uint64 va = 0; va < p->sz; va += PGSIZE) {
    pte_t *pte = walk(p->pagetable, va, 0);
    if (pte && (*pte & (PTE_V | PTE_U)) == (PTE_V | PTE_U))
      s.resident_pages++;
  }

  acquire(&tickslock);
  s.ticks = ticks;
  release(&tickslock);

  if (copyout(p->pagetable, p->sz, dst, (char *)&s, sizeof(s)) < 0)
    return -1;
  return 0;
}
