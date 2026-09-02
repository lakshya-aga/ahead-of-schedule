# Premature Loader

Experimental OS scheduling project focused on predictive memory behavior.

Current direction: use `xv6-riscv` as the first implementation target. The
initial goal is to build a memory-aware scheduler that uses lightweight process
statistics before adding any learned predictor.

Start here:

- [Windows xv6 setup](docs/windows-xv6-setup.md)
- [xv6 ML scheduler plan](docs/xv6-ml-scheduler-plan.md)

Recommended next milestone:

1. Add an `xv6-riscv/` checkout.
2. Boot unmodified xv6 in QEMU.
3. Add scheduler instrumentation without changing scheduling behavior.
4. Add benchmark user programs.
5. Replace round-robin with a memory-aware scoring policy.
