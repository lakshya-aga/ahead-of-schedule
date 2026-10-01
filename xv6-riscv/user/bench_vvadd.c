// Adapted from riscv-tests/benchmarks/vvadd/vvadd_main.c.
// See the upstream riscv-tests LICENSE for license details.
#include "kernel/types.h"
#include "kernel/benchstats.h"
#include "user/user.h"
#include "vvadd_dataset.h"

static void
vvadd(int n, int a[], int b[], int c[])
{
  for (int i = 0; i < n; i++)
    c[i] = a[i] + b[i];
}

static void
snapshot(struct benchstats *s)
{
  if (getstats(s) < 0) {
    fprintf(2, "vvadd: getstats failed\n");
    exit(1);
  }
}

static void
report(char *phase, struct benchstats *a, struct benchstats *b)
{
  // Cast small benchmark deltas for compatibility with xv6's %d printer.
  printf("%s: faults(i/l/s)=%d/%d/%d mapped=%d freed=%d ticks=%d\n",
         phase,
         (int)(b->instruction_faults - a->instruction_faults),
         (int)(b->load_faults - a->load_faults),
         (int)(b->store_faults - a->store_faults),
         (int)(b->pages_mapped - a->pages_mapped),
         (int)(b->pages_freed - a->pages_freed),
         (int)(b->ticks - a->ticks));
  printf("  resident pages: %d -> %d; virtual bytes: %d -> %d\n",
         (int)a->resident_pages, (int)b->resident_pages,
         (int)a->virtual_bytes, (int)b->virtual_bytes);
}

int
main(void)
{
  struct benchstats s[5];
  // Touch all snapshot buffers before the measurement begins.
  memset(s, 0, sizeof(s));

  snapshot(&s[0]);
  int *results = malloc(DATA_SIZE * sizeof(int));
  if (results == 0) {
    fprintf(2, "vvadd: allocation failed\n");
    exit(1);
  }
  snapshot(&s[1]);

  vvadd(DATA_SIZE, input1_data, input2_data, results);
  snapshot(&s[2]);

  int bad = -1;
  for (int i = 0; i < DATA_SIZE; i++) {
    if (results[i] != verify_data[i]) {
      bad = i;
      break;
    }
  }
  snapshot(&s[3]);

  free(results);
  snapshot(&s[4]);

  // Print only after all measured phases.
  report("allocation", &s[0], &s[1]);
  report("compute", &s[1], &s[2]);
  report("verification", &s[2], &s[3]);
  report("free", &s[3], &s[4]);

  if (bad >= 0) {
    fprintf(2, "vvadd: FAIL at element %d\n", bad);
    exit(1);
  }
  printf("vvadd: PASS (%d elements)\n", DATA_SIZE);
  exit(0);
}
