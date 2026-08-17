# ML-Assisted Linux Scheduler Project

## 1. Target architecture

The development environment should look like this:


```text
Windows laptop
│
├── WSL2 / Ubuntu
│   │
│   ├── Linux kernel source
│   ├── GCC / Clang
│   ├── C++ ML controller
│   ├── sched_ext source
│   ├── benchmark source
│   └── build scripts
│
└── QEMU
    │
    └── Custom Linux kernel
        ├── sched_ext
        ├── BPF
        ├── test scheduler
        └── correctness workloads
```

Then eventually:

```text
                 DEVELOPMENT
                     │
               Windows + WSL2
                     │
                     ▼
                   QEMU
             correctness tests
                     │
                     ▼
             Cloud Linux VM
             integration tests
                     │
                     ▼
            Cloud bare metal
          final performance tests
```

WSL2 gives us a proper Linux compilation environment, while QEMU can run an independent kernel. Microsoft supports installing WSL through `wsl --install`, and current QEMU supports Windows Hypervisor Platform (`WHPX`) for hardware-accelerated virtualization on Windows.

---

# 2. Project roadmap

## Phase 0 — Development environment

Goal:

> Boot a kernel we compiled ourselves inside QEMU.

### To-do

- [ ] Enable CPU virtualization in BIOS/UEFI.
- [ ] Install WSL2.
- [ ] Install Ubuntu under WSL2.
- [ ] Install kernel development packages.
- [ ] Install Git.
- [ ] Install QEMU for Windows.
- [ ] Enable Windows Hypervisor Platform.
- [ ] Download Linux source.
- [ ] Compile an unmodified kernel.
- [ ] Build a tiny initramfs.
- [ ] Boot the kernel in QEMU.
- [ ] Confirm serial console output works.

### Milestone

You should reach:

```text
Windows
   ↓
QEMU
   ↓
Your compiled Linux kernel
   ↓
BusyBox shell

/ #
```

Do **not modify the scheduler before reaching this point**.

---

# Phase 1 — Enable `sched_ext`

Rather than immediately modifying `kernel/sched/`, start with Linux's `sched_ext`.

`sched_ext` allows a scheduler to be implemented as BPF programs, can be dynamically enabled/disabled, and Linux automatically returns to the normal fair scheduler if the BPF scheduler fails or stalls.

Enable:

```text
CONFIG_BPF=y
CONFIG_SCHED_CLASS_EXT=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y
CONFIG_DEBUG_INFO_BTF=y
CONFIG_BPF_JIT_ALWAYS_ON=y
CONFIG_BPF_JIT_DEFAULT_ON=y
```

These are the options currently documented by the kernel for `sched_ext`.

### To-do

- [ ] Enable sched_ext kernel configuration.
- [ ] Recompile kernel.
- [ ] Boot it.
- [ ] Verify `/sys/kernel/sched_ext/` exists.
- [ ] Compile the kernel's `scx_simple` example.
- [ ] Load `scx_simple`.
- [ ] Confirm processes are using sched_ext.
- [ ] Stop the scheduler.
- [ ] Confirm Linux returns to the standard scheduler.

The kernel source already includes scheduler examples under:

```text
tools/sched_ext/
```

including `scx_simple`, `scx_qmap`, `scx_central`, and `scx_userland`.

### Milestone

This command:

```bash
cat /sys/kernel/sched_ext/state
```

should return:

```text
enabled
```

while your scheduler is active.

---

# Phase 2 — Build our own non-ML scheduler

Do **not put ML in yet**.

First build something intentionally simple.

For example:

```text
Task arrives
     ↓
choose least-loaded CPU
     ↓
assign task
     ↓
round-robin execution
```

### To-do

- [ ] Fork `scx_simple`.
- [ ] Rename it `scx_ml`.
- [ ] Add per-task statistics.
- [ ] Track task runtime.
- [ ] Track sleep/wake patterns.
- [ ] Track CPU migrations.
- [ ] Track queue length.
- [ ] Implement deterministic CPU selection.
- [ ] Add logging.
- [ ] Write scheduler correctness tests.

The purpose is to build the plumbing that the ML model will eventually control.

---

# Phase 3 — Scheduler correctness suite

Before measuring speed, deliberately try to break it.

## Correctness tests

### Test 1 — One CPU-bound task

```text
CPU0

Task A
████████████████████
```

Check:

- task executes
- task completes
- no scheduler errors

---

### Test 2 — Many CPU-bound tasks

For example:

```bash
stress-ng --cpu 8 --timeout 30
```

Check:

- all tasks make progress
- no starvation
- no crash
- scheduler remains loaded

---

### Test 3 — Fork/exit storm

Create hundreds or thousands of short processes.

Check:

```text
fork
 ↓
schedule
 ↓
exit
 ↓
scheduler cleans task state
```

---

### Test 4 — Sleeping tasks

Test:

```text
wake
 ↓
run
 ↓
sleep
 ↓
wake
```

This is especially important because interactive applications spend a lot of time sleeping.

---

### Test 5 — CPU affinity

Run:

```bash
taskset -c 1 ./workload
```

Your scheduler must respect the CPU mask.

---

### Test 6 — Scheduler termination

Kill your scheduler process.

Expected:

```text
ML scheduler
     ↓
terminated
     ↓
Linux automatically falls back
     ↓
standard scheduler
```

`sched_ext` explicitly provides this fallback behavior.

---

### Test 7 — Scheduler stall

Deliberately introduce a broken scheduler condition.

Confirm the kernel detects it and falls back rather than leaving the system permanently unusable.

---

# Phase 4 — Create scheduler benchmarks

Now establish the baseline.

Use at least four workload classes.

## Benchmark A — CPU throughput

Examples:

```text
Linux kernel compile
C++ compile
compression
hashing
```

The kernel compilation benchmark is particularly useful:

```bash
time make -j4
```

Primary metric:

```text
completion time
```

---

# Benchmark B — Latency-sensitive workload

Build a tiny C++ program that repeatedly:

```text
sleep
 ↓
wake
 ↓
perform tiny calculation
 ↓
record latency
 ↓
sleep
```

Record:

```text
p50 latency
p95 latency
p99 latency
maximum latency
```

---

# Benchmark C — Mixed workload

This is one of the most important tests.

Run:

```text
Background:
    kernel compile
    compression
    CPU stress

Foreground:
    latency test
```

Then measure whether your scheduler keeps the foreground process responsive.

This is where an ML scheduler has a realistic opportunity to outperform a purely throughput-focused policy.

---

# Benchmark D — Search workload

Eventually:

```text
query
  ↓
candidate retrieval
  ↓
index reads
  ↓
ranking
  ↓
result
```

Measure:

```text
queries/second

p50
p95
p99

CPU utilization
context switches
CPU migrations
```

---

# Phase 5 — Instrument tasks

Before ML, collect training data.

Create something similar to:

```cpp
struct TaskFeatures {
    uint64_t avg_runtime_ns;
    uint64_t last_runtime_ns;

    uint64_t sleep_time_ns;
    uint64_t wake_frequency;

    uint64_t migrations;
    uint64_t context_switches;

    uint32_t runnable_tasks;
    uint32_t cpu;

    double cpu_utilization;
};
```

Each scheduler observation becomes:

```text
task features
+
scheduler decision
+
result
```

For example:

```text
task = compiler_worker

runtime = 8.3 ms
sleep time = 0.1 ms
wake frequency = low
CPU usage = 99%

classification:
CPU_BOUND
```

versus:

```text
task = search_request

runtime = 0.4 ms
sleep time = 3.1 ms
wake frequency = high

classification:
LATENCY_SENSITIVE
```

---

# Phase 6 — Heuristic scheduler

Before ML, make a heuristic baseline.

For example:

```text
if CPU usage > 90%
and sleep ratio < 5%:

    CPU_BOUND

else if wake frequency high
and runtime short:

    LATENCY_SENSITIVE

else:

    NORMAL
```

Then schedule:

```text
CPU_BOUND
    ↓
throughput-oriented policy

LATENCY_SENSITIVE
    ↓
short queue / immediate dispatch
```

### To-do

- [ ] Define task classes.
- [ ] Implement classification.
- [ ] Benchmark.
- [ ] Save results.

This baseline is crucial.

Your future experiment must be:

```text
Linux
vs
heuristic scheduler
vs
ML scheduler
```

not merely:

```text
Linux
vs
ML
```

Otherwise you won't know whether ML itself provides value.

---

# Phase 7 — ML scheduler V1

Now introduce ML.

Start with a tiny model.

**Do not start with a neural network.**

Possible models:

```text
decision tree
random forest
XGBoost
small linear classifier
```

Initially predict:

```text
CPU_BOUND
LATENCY_SENSITIVE
BURSTY
BACKGROUND
```

Architecture:

```text
          Linux statistics
                │
                ▼
         C++ ML controller
                │
            prediction
                │
                ▼
        scheduler policy map
                │
                ▼
            sched_ext
                │
                ▼
               CPUs
```

Keep expensive ML inference outside the scheduler's hottest execution path.

---

# Phase 8 — ML scheduler V2

Once classification works, predict an actual scheduling decision.

Possible output:

```text
task 284
preferred CPUs = {2,3}
priority = high
time slice = 1.2 ms
migration preference = avoid
```

Features might include:

```text
recent runtime
previous CPU
cache behavior
sleep/wake frequency
queue depth
system load
task class
historical behavior
```

---

# Phase 9 — Search-engine optimization

Then integrate the other idea: ML prefetching.

Architecture:

```text
                     QUERY
                       │
            ┌──────────┴──────────┐
            │                     │
            ▼                     ▼
      ML scheduler          ML prefetcher
            │                     │
            ▼                     ▼
       CPU placement           readahead()
            │                     │
            ▼                     ▼
           CPUs              page cache
                                  │
                                  ▼
                                 SSD
```

Now you can test whether both techniques complement each other.

Experiments:

```text
A. Linux baseline

B. ML scheduler only

C. ML prefetcher only

D. ML scheduler
   +
   ML prefetcher
```

That becomes a much stronger research project.

---

# Phase 10 — Cloud bare-metal validation

Once everything works in QEMU:

```text
QEMU results
     ↓
correctness established
     ↓
deploy same source
     ↓
bare-metal server
```

Repeat:

```text
Linux baseline
heuristic
ML
```

Run each test many times and compare distributions rather than one timing.

---

# 3. Windows setup guide

## Step 1 — Check virtualization

Open:

```text
Task Manager
→ Performance
→ CPU
```

Look for:

```text
Virtualization: Enabled
```

If it says disabled, enter your BIOS/UEFI and enable:

```text
Intel VT-x / Intel Virtualization Technology
```

or:

```text
AMD-V / SVM
```

depending on the laptop.

---

# Step 2 — Install WSL

Open **PowerShell as Administrator**:

```powershell
wsl --install
```

Restart Windows.

Microsoft's current installation procedure uses this command and installs Ubuntu by default.

After reboot:

```powershell
wsl -l -v
```

You want:

```text
NAME       STATE      VERSION
Ubuntu     Running    2
```

---

# Step 3 — Update Ubuntu

Inside WSL:

```bash
sudo apt update
sudo apt upgrade -y
```

---

# Step 4 — Install development tools

Inside WSL:

```bash
sudo apt install -y \
    build-essential \
    git \
    bc \
    bison \
    flex \
    libssl-dev \
    libelf-dev \
    libncurses-dev \
    dwarves \
    clang \
    llvm \
    lld \
    cpio \
    gzip \
    busybox-static \
    pkg-config \
    libcap-dev \
    libzstd-dev \
    python3
```

Current kernel documentation lists GCC, GNU make, Bison, Flex, OpenSSL, `pahole`, Python and related tools among the requirements used for kernel builds; BTF builds in particular require `pahole`.

Check:

```bash
gcc --version
clang --version
make --version
pahole --version
```

---

# Step 5 — Create project directories

Keep Linux source **inside the WSL filesystem**, not under `/mnt/c`, because kernel compilation involves enormous numbers of filesystem operations.

```bash
mkdir -p ~/ml-scheduler
cd ~/ml-scheduler

mkdir kernel
mkdir rootfs
mkdir output
mkdir scheduler
mkdir benchmarks
mkdir ml
```

Result:

```text
~/ml-scheduler/
├── kernel/
├── scheduler/
├── ml/
├── benchmarks/
├── rootfs/
└── output/
```

---

# Step 6 — Download Linux

```bash
cd ~/ml-scheduler

git clone \
    https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git \
    kernel
```

Then:

```bash
cd kernel

git status
```

Create your project branch:

```bash
git checkout -b ml-scheduler
```

---

# Step 7 — Configure kernel

Start with:

```bash
make defconfig
```

Then:

```bash
make menuconfig
```

Enable sched_ext/BPF support.

The important configuration values are:

```text
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_BPF_JIT=y

CONFIG_SCHED_CLASS_EXT=y

CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_BTF=y

CONFIG_BPF_JIT_ALWAYS_ON=y
CONFIG_BPF_JIT_DEFAULT_ON=y
```

These correspond to the configuration documented for sched_ext.

Save the configuration.

---

# Step 8 — Compile Linux

```bash
make -j$(nproc)
```

On x86-64, the resulting boot image should be:

```text
arch/x86/boot/bzImage
```

The kernel build system produces the x86 boot image through the normal build process.

Verify:

```bash
ls -lh arch/x86/boot/bzImage
```

Also keep:

```text
vmlinux
```

because the uncompressed `vmlinux` contains debugging symbols and is useful later with GDB/kgdb.

---

# Step 9 — Create a minimal initramfs

Go to:

```bash
cd ~/ml-scheduler/rootfs
```

Create directories:

```bash
mkdir -p bin sbin etc proc sys dev tmp
```

Copy BusyBox:

```bash
cp /usr/bin/busybox bin/
```

Create links:

```bash
cd bin

for cmd in sh mount umount ls cat echo dmesg sleep poweroff reboot ps; do
    ln -s busybox "$cmd"
done
```

Return:

```bash
cd ..
```

Create:

```bash
nano init
```

Put:

```bash
#!/bin/sh

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

echo
echo "================================"
echo " ML Scheduler Test Kernel"
echo "================================"
echo

uname -a

echo
echo "sched_ext state:"
cat /sys/kernel/sched_ext/state 2>/dev/null || \
    echo "sched_ext currently disabled"

echo
echo "Entering shell..."
echo

exec /bin/sh
```

Make executable:

```bash
chmod +x init
```

Create archive:

```bash
cd ~/ml-scheduler/rootfs

find . -print0 \
    | cpio --null -ov --format=newc \
    | gzip -9 \
    > ~/ml-scheduler/output/initramfs.cpio.gz
```

---

# Step 10 — Copy QEMU boot files to Windows

Do not compile under `/mnt/c`, but copying the final products there is fine.

Inside WSL:

```bash
mkdir -p /mnt/c/ml-scheduler
```

Copy:

```bash
cp ~/ml-scheduler/kernel/arch/x86/boot/bzImage \
   /mnt/c/ml-scheduler/

cp ~/ml-scheduler/kernel/vmlinux \
   /mnt/c/ml-scheduler/

cp ~/ml-scheduler/output/initramfs.cpio.gz \
   /mnt/c/ml-scheduler/
```

You should now have:

```text
C:\ml-scheduler\
├── bzImage
├── vmlinux
└── initramfs.cpio.gz
```

---

# Step 11 — Install QEMU

Install the 64-bit Windows build.

QEMU's official download page currently points Windows users to prebuilt Windows installers or MSYS2 packages.

After installation, check from PowerShell:

```powershell
qemu-system-x86_64.exe --version
```

---

# Step 12 — Enable WHPX

QEMU supports the Windows Hypervisor Platform accelerator, `WHPX`, for hardware-accelerated x86-64 virtualization. QEMU documents `HypervisorPlatform` as the required Windows feature.

Open **PowerShell as Administrator**:

```powershell
DISM /online /Enable-Feature /FeatureName:HypervisorPlatform /All
```

Restart Windows if requested.

---

# Step 13 — Boot your kernel

PowerShell:

```powershell
qemu-system-x86_64.exe `
    -accel whpx `
    -machine q35 `
    -smp 4 `
    -m 4096 `
    -kernel C:\ml-scheduler\bzImage `
    -initrd C:\ml-scheduler\initramfs.cpio.gz `
    -append "console=ttyS0 rdinit=/init" `
    -nographic `
    -no-reboot
```

QEMU's WHPX documentation confirms that `-accel whpx` uses Windows Hypervisor Platform for hardware acceleration.

You should eventually see:

```text
================================
 ML Scheduler Test Kernel
================================

Linux ...

sched_ext state:
disabled

Entering shell...

/ #
```

At that point:

# STOP.

That is the first major milestone.

Do not add ML.

Do not modify the scheduler.

Commit everything:

```bash
git add .
git commit -m "Boot sched_ext-enabled Linux kernel in QEMU"
```

---

# 4. Next milestone: run Linux's example scheduler

Once the VM boot is solid, the next objective is:

```text
QEMU kernel
     ↓
scx_simple
     ↓
sched_ext becomes enabled
     ↓
stress workload
     ↓
scheduler stays stable
```

The kernel's documented build command for its scheduler examples is:

```bash
make -j$(nproc) -C tools/sched_ext
```

and the simple scheduler is run from the resulting build output.

That will require adding the scheduler binary and its required userspace libraries to the VM or moving to a small persistent Linux root filesystem.

**I recommend making that the second setup step rather than trying to solve it before you can boot your kernel.**

---

# 5. Initial benchmark suite

Keep version 1 small.

| Benchmark | Measures |
|---|---|
| `stress-ng --cpu` | CPU scheduling |
| Linux/C++ compilation | throughput |
| wake/sleep C++ test | scheduling latency |
| compile + latency test simultaneously | mixed workload |
| process fork storm | scheduler robustness |
| search-engine workload | real target workload |

Primary measurements:

```text
execution time

throughput

p50 latency
p95 latency
p99 latency

context switches
CPU migrations

CPU utilization
scheduler failures
```

Linux tracing and `perf` can later expose scheduler tracepoints and related events for analysis.

---

# 6. Repository layout

I would make the actual project:

```text
ml-scheduler/
│
├── kernel/
│
├── scheduler/
│   ├── scx_ml.bpf.c
│   ├── scx_ml.c
│   └── task_stats.h
│
├── controller/
│   ├── controller.cpp
│   ├── feature_store.cpp
│   └── model.cpp
│
├── benchmarks/
│   ├── latency.cpp
│   ├── cpu.cpp
│   ├── mixed.sh
│   └── search/
│
├── ml/
│   ├── train.py
│   ├── dataset/
│   └── model.onnx
│
├── scripts/
│   ├── build-kernel.sh
│   ├── build-initramfs.sh
│   ├── run-qemu.ps1
│   └── run-benchmarks.sh
│
├── results/
│
└── README.md
```

---

# 7. Definition of MVP

The project is **not** MVP when an ML model exists.

MVP is reached when:

- [ ] Custom Linux kernel boots in QEMU.
- [ ] `sched_ext` works.
- [ ] Our own scheduler loads.
- [ ] Our scheduler unloads safely.
- [ ] Stress tests don't crash it.
- [ ] CPU affinity works.
- [ ] No obvious task starvation occurs.
- [ ] Baseline benchmark results are reproducible.
- [ ] Heuristic scheduler benchmark exists.
- [ ] ML scheduler benchmark exists.
- [ ] Results can compare all three.

The core experimental comparison should be:

```text
             ┌──────────────┐
             │ Stock Linux  │
             └──────┬───────┘
                    │
             ┌──────▼───────┐
             │  Heuristic   │
             └──────┬───────┘
                    │
             ┌──────▼───────┐
             │     ML       │
             └──────────────┘
```

Only after that should we move to:

```text
ML scheduler
+
ML page-cache prefetching
+
search-engine workload
```

That prevents the project from becoming too large before we know whether the central scheduler idea works.