# xv6 Predictive Scheduler Plan

## Goal

Build an experimental xv6 scheduler that uses process memory behavior to reduce
stalls and page-fault-like delays. The first version should be deterministic and
easy to measure. ML comes after the scheduler has reliable instrumentation.

The project question is:

> Can the scheduler improve turnaround time and latency by choosing runnable
> processes whose near-future memory accesses are likely to be cheap?

## Why xv6

xv6 is small enough that scheduler, process, trap, and virtual-memory behavior
can be understood end to end. That makes it a better first target than Linux CFS.
The final project can still discuss how the idea would map to Linux.

## Baseline Target

Use xv6-riscv.

Initial kernel files of interest:

- `kernel/proc.c`: scheduler loop, process lifecycle, sleep/wakeup.
- `kernel/proc.h`: `struct proc`, per-process statistics.
- `kernel/trap.c`: trap handling and timer interrupts.
- `kernel/vm.c`: page-table operations.
- `kernel/sysproc.c`: optional syscalls to expose scheduler stats.
- `user/`: synthetic workloads for evaluation.

## Milestone 1: Boot Unmodified xv6

Before changing scheduling behavior:

1. Build xv6.
2. Boot it in QEMU.
3. Run basic user programs.
4. Confirm tests pass with the default scheduler.

Expected command in WSL/Linux:

```sh
make qemu
```

## Milestone 2: Add Scheduler Statistics

Add fields to `struct proc`:

```c
uint64 sched_count;
uint64 run_ticks;
uint64 sleep_ticks;
uint64 runnable_ticks;
uint64 last_scheduled_tick;
uint64 recent_faults;
uint64 predicted_stall;
```

Track:

- how often a process is scheduled
- how long it runs
- how long it waits while runnable
- how often it sleeps
- trap/page-fault-like events if implemented

At this stage, do not change the scheduler decision. Only measure.

## Milestone 3: Memory-Aware Heuristic Scheduler

Replace simple round-robin selection with a score:

```text
score =
    fairness_bonus
  - runnable_wait_penalty
  - predicted_stall_penalty
  + starvation_bonus
```

Start without real ML:

- processes with fewer recent memory stalls get a lower penalty
- processes that have waited too long get a starvation bonus
- processes that ran recently get a fairness penalty

The scheduler should still guarantee progress for every runnable process.

## Milestone 4: Synthetic Workloads

Add user programs that create predictable process classes:

- `cpubound`: tight CPU loop
- `memburst`: repeatedly touches a fixed memory region
- `memscan`: sequentially scans memory
- `memrandom`: pseudo-random memory access
- `mixedload`: forks several process types together

Measure:

- total completion time
- per-process turnaround time
- wait time
- scheduler count
- fairness spread
- memory-stall counter

## Milestone 5: Lightweight Predictor

Keep the predictor kernel-friendly. Good first options:

- exponential moving average of recent stall rate
- last-N page bucket reuse score
- Markov transition table over coarse memory regions

Avoid neural networks inside xv6. If we want an ML model, train it offline and
embed only a tiny generated policy/table in the kernel.

## Milestone 6: Evaluation

Compare:

1. xv6 default round-robin
2. memory-aware heuristic scheduler
3. learned or table-driven predictor scheduler

Report:

- where prediction helps
- where it hurts
- scheduler overhead
- starvation/fairness behavior
- incorrect prediction cost

## Suggested Implementation Order

1. Import xv6-riscv as a separate directory or submodule.
2. Boot unmodified xv6.
3. Add stats fields to `struct proc`.
4. Add a `getpinfo`-style syscall or console dump for stats.
5. Add user benchmarks.
6. Modify the scheduler policy.
7. Add predictor state.
8. Run controlled comparisons.

## Stretch Goals

- Use page-access bits to estimate working-set hotness.
- Add a simulated slow-memory/page-fault penalty for experiments.
- Add a user-space training script that produces kernel constants.
- Port the high-level policy to Linux `sched_ext` after the xv6 version works.
