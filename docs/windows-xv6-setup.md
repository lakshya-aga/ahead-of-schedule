# Windows Setup for xv6-riscv

This project should be developed from Windows using WSL2 Ubuntu. Build and run
xv6 inside WSL, not directly from PowerShell.

## 1. Install WSL2 and Ubuntu

Open **PowerShell as Administrator** and run:

```powershell
wsl --install
```

Restart Windows if prompted.

After reboot, open **Ubuntu** from the Start menu. Create a Linux username and
password when asked.

Check that Ubuntu is using WSL2:

```powershell
wsl -l -v
```

If Ubuntu shows version `1`, run this from PowerShell:

```powershell
wsl --set-version Ubuntu 2
```

## 2. Update Ubuntu Packages

Open Ubuntu and run:

```sh
sudo apt update
sudo apt upgrade -y
```

## 3. Install xv6 Build Dependencies

Install the RISC-V cross compiler, QEMU, Git, Make, and debugging tools:

```sh
sudo apt install -y \
  git \
  make \
  gcc \
  gdb \
  qemu-system-misc \
  gcc-riscv64-linux-gnu \
  binutils-riscv64-linux-gnu
```

Then check the tools:

```sh
qemu-system-riscv64 --version
riscv64-linux-gnu-gcc --version
```

## 4. Put the Project in the WSL Filesystem

For best performance, keep the source under Linux's filesystem, not
`/mnt/c/...`.

From Ubuntu:

```sh
mkdir -p ~/projects
cd ~/projects
```

If this repo currently lives at:

```text
C:\Users\koo\lakshya_personal\premature_loader
```

copy it into WSL:

```sh
cp -r /mnt/c/Users/koo/lakshya_personal/premature_loader ~/projects/
cd ~/projects/premature_loader
```

## 5. Download xv6-riscv

From inside `~/projects/premature_loader`:

```sh
git clone https://github.com/mit-pdos/xv6-riscv.git
cd xv6-riscv
```

## 6. Build xv6

Run:

```sh
make
```

If this succeeds, boot xv6:

```sh
make qemu
```

You should eventually see an xv6 shell prompt:

```text
$
```

Exit QEMU with:

```text
Ctrl-a x
```

Press `Ctrl-a`, release, then press `x`.

## 7. Run xv6 Tests

The plain MIT `xv6-riscv` repository may not include a `make grade` target.
That is normal. Boot xv6 and run its user tests from the xv6 shell instead:

```sh
make qemu
```

At the xv6 `$` prompt, run:

```sh
usertests
```

This may take a while. The initial goal is not perfection yet; the key milestone
is that unmodified xv6 builds, boots, and can run basic user programs.

For deterministic scheduler experiments later, boot with one CPU:

```sh
make CPUS=1 qemu
```

## 8. Open the Code From Windows VS Code

Install VS Code on Windows, then install the **WSL** extension.

From Ubuntu:

```sh
cd ~/projects/premature_loader
code .
```

VS Code should open in a WSL remote window.

## 9. First Files We Will Modify

Once unmodified xv6 boots, start with:

- `xv6-riscv/kernel/proc.h`
- `xv6-riscv/kernel/proc.c`
- `xv6-riscv/kernel/trap.c`
- `xv6-riscv/user/`

Do not change scheduling behavior first. First add counters and prove that stats
collection works.

## Troubleshooting

If `make qemu` says QEMU is missing:

```sh
sudo apt install -y qemu-system-misc
```

If the RISC-V compiler is missing:

```sh
sudo apt install -y gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu
```

If WSL is slow, confirm the repo is under `~/projects/...` and not under
`/mnt/c/...`.

If `code .` does not work, install VS Code on Windows and the WSL extension,
then restart Ubuntu.
