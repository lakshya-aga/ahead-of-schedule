# Page Management and Read-Pattern TODO

## Phase 0: Baseline xv6 Setup

- [x] Install WSL2/Ubuntu.
- [x] Install xv6 dependencies.
- [x] Clone `xv6-riscv`.
- [x] Build xv6.
- [x] Boot xv6 in QEMU.
- [ ] Boot xv6 with one CPU using `make CPUS=1 qemu`.
- [ ] Run `usertests` once on unmodified xv6.
- [ ] Save the unmodified xv6 commit hash.

## Phase 1: Understand the Read Path

- [ ] Read `kernel/sysfile.c`.
- [ ] Read `kernel/file.c`.
- [ ] Read `kernel/fs.c`.
- [ ] Read `kernel/bio.c`.
- [ ] Read `kernel/virtio_disk.c`.
- [ ] Write a short note tracing this path:

```text
user read()
  -> sys_read()
  -> fileread()
  -> readi()
  -> bread()
  -> virtio_disk_rw()
```

Goal: know where logical reads, block-cache hits/misses, and physical disk reads
happen.

## Phase 2: Add Kernel Counters

- [ ] Add per-process read counters to `kernel/proc.h`.
- [ ] Initialize counters in `allocproc()` in `kernel/proc.c`.
- [ ] Increment `read_syscalls` in `sys_read()` in `kernel/sysfile.c`.
- [ ] Increment `bytes_read` after successful reads.
- [ ] Add global buffer-cache counters in `kernel/bio.c`.
- [ ] Count cache hits in `bread()` / buffer lookup path.
- [ ] Count cache misses when a block must be loaded from disk.
- [ ] Count disk reads in or near `virtio_disk_rw()`.

Suggested counters:

```c
uint64 read_syscalls;
uint64 bytes_read;
uint64 cache_hits;
uint64 cache_misses;
uint64 disk_reads;
uint64 page_faults;
```

## Phase 3: Export Stats

- [ ] Add a temporary kernel debug print path.
- [ ] Extend `procdump()` to print read/page counters.
- [ ] Boot xv6 and press `Ctrl-p` to confirm stats print.
- [ ] Later, replace debug printing with a syscall.
- [ ] Add `SYS_getstats` to `kernel/syscall.h`.
- [ ] Add syscall dispatch in `kernel/syscall.c`.
- [ ] Implement `sys_getstats()` in `kernel/sysproc.c`.
- [ ] Add user declaration in `user/user.h`.
- [ ] Add syscall stub in `user/usys.pl`.
- [ ] Create a `user/stats.c` command to print stats.

## Phase 4: Build Read Workloads

- [ ] Add `user/readseq.c`.
- [ ] Add `user/readrepeat.c`.
- [ ] Add `user/readstride.c`.
- [ ] Add `user/readrandom.c`.
- [ ] Add `user/mixedread.c`.
- [ ] Add each workload to `UPROGS` in the xv6 `Makefile`.
- [ ] Build xv6 after each workload is added.

Workload goals:

- `readseq`: read a file sequentially.
- `readrepeat`: read the same file multiple times.
- `readstride`: read predictable non-contiguous chunks.
- `readrandom`: read blocks in pseudo-random order using a fixed seed.
- `mixedread`: fork multiple readers with different patterns.

## Phase 5: Baseline Experiments

- [ ] Define test input files.
- [ ] Run `readseq` on a cold cache.
- [ ] Run `readseq` again on a warm cache.
- [ ] Run `readrepeat`.
- [ ] Run `readstride`.
- [ ] Run `readrandom`.
- [ ] Run `mixedread`.
- [ ] Record completion time using `uptime()` ticks.
- [ ] Record read syscall count.
- [ ] Record bytes read.
- [ ] Record cache hits.
- [ ] Record cache misses.
- [ ] Record disk reads.
- [ ] Save outputs under `results/baseline/`.

Baseline table:

```text
workload    ticks   reads   bytes   hits   misses   disk_reads
readseq
readrepeat
readstride
readrandom
mixedread
```

## Phase 6: Page/Fault Instrumentation

- [ ] Read `kernel/trap.c`.
- [ ] Read `kernel/vm.c`.
- [ ] Identify where page faults are handled.
- [ ] Count user page faults per process.
- [ ] Log faulting virtual address.
- [ ] Group virtual addresses by page number.
- [ ] Add per-process page-touch/fault summary.
- [ ] Export page stats through debug print or `getstats`.

Note: xv6 is simpler than Linux and does not have full production-style demand
paging. Treat this phase as controlled instrumentation.

## Phase 7: First Prefetch/Prediction Policy

- [ ] Implement a non-ML sequential block prefetch baseline.
- [ ] In `readseq`, prefetch block `N+1` after reading block `N`.
- [ ] Add counters for useful prefetches.
- [ ] Add counters for wasted prefetches.
- [ ] Compare against baseline.
- [ ] Implement repeated-pattern prediction.
- [ ] Track last few blocks read by each process.
- [ ] Predict next block from prior sequence.
- [ ] Prefetch predicted block when confidence is high.

Do not start with neural networks inside the kernel.

## Phase 8: ML-Oriented Predictor

- [ ] Export traces to a plain text or CSV-like format.
- [ ] Create `ml/` script to train from baseline traces.
- [ ] Start with a Markov/n-gram predictor.
- [ ] Generate a small prediction table.
- [ ] Embed the table into the xv6 kernel.
- [ ] Run the same experiments as Phase 5.
- [ ] Compare hit/miss/disk-read changes.

## Phase 9: Scheduler Integration

- [ ] Add process memory-readiness score.
- [ ] Track each process's recent cache hit rate.
- [ ] Track each process's recent miss rate.
- [ ] Modify `scheduler()` in `kernel/proc.c`.
- [ ] Prefer runnable processes with lower predicted stall cost.
- [ ] Add starvation protection.
- [ ] Compare against normal round-robin.

Scheduler score sketch:

```text
score =
    wait_time_bonus
  + cache_readiness_bonus
  - predicted_miss_penalty
  - recent_runtime_penalty
```

## Phase 10: Final Evaluation

- [ ] Re-run every baseline workload.
- [ ] Re-run every predictor workload.
- [ ] Re-run scheduler-integrated workloads.
- [ ] Create result tables.
- [ ] Plot cache misses vs workload.
- [ ] Plot disk reads vs workload.
- [ ] Plot completion ticks vs workload.
- [ ] Write findings.
- [ ] List cases where prediction helped.
- [ ] List cases where prediction hurt.
- [ ] Explain overhead and limitations.

## Definition of Done

The project is complete when:

- [ ] xv6 boots reliably.
- [ ] read/page stats are observable.
- [ ] baseline results are recorded.
- [ ] at least three workloads run automatically.
- [ ] one prediction or prefetch policy is implemented.
- [ ] predictor results are compared against baseline.
- [ ] scheduler integration is attempted or clearly scoped as future work.
- [ ] final report explains tradeoffs, failures, and next steps.
