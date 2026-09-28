// Adapted from riscv-tests/benchmarks/vvadd/vvadd_main.c.
// See the upstream riscv-tests LICENSE for license details.
#include "kernel/types.h"
#include "user/user.h"
#include "vvadd_dataset.h"

static void
vvadd(int n, int a[], int b[], int c[])
{
  for (int i = 0; i < n; i++)
    c[i] = a[i] + b[i];
}

int
main(void)
{
  int *results = malloc(DATA_SIZE * sizeof(int));
  if (results == 0) {
    fprintf(2, "vvadd: allocation failed\n");
    exit(1);
  }

  vvadd(DATA_SIZE, input1_data, input2_data, results);

  for (int i = 0; i < DATA_SIZE; i++) {
    if (results[i] != verify_data[i]) {
      fprintf(2, "vvadd: FAIL at element %d\n", i);
      free(results);
      exit(1);
    }
  }

  printf("vvadd: PASS (%d elements)\n", DATA_SIZE);
  free(results);
  exit(0);
}
