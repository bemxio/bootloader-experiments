# bootloader-experiments
This repository contains a collection of bootloaders written by me in Assembly, for learning more about BIOS, bootloaders, and the Assembly language itself.

## Building
For building stuff, you will need an assembler, such as NASM. Optionally, you can also install `make` and `qemu` for easier building and running.

### The `Makefile` way
If you just want to quickly check out a bootloader, you can use `make` to build and run it. For example, to build the `hello_world.asm` code, simply run:

```bash
make hello_world.asm
```

That will build the bootloader with NASM and run it in QEMU.

If you want to build all of the files in the `src` directory, you can run `make` or `make all`.

### The manual way
If you want to build a bootloader manually, do it the way your assembler does it. With NASM, you can build the `hello_world.asm` file by executing:

```bash
nasm -f bin -o bootloader.bin src/hello_world.asm
```

Then, you can run it in QEMU by putting the command below in your terminal:

```bash
qemu-system-x86_64 -drive format=raw,file=bootloader.bin
```

## License
All pieces of code on this repo is released into the public domain. Do what you want with it, as long as you don't hold me responsible for anything that happens!

In case you really want to dive into the details, the license is available in the [`LICENSE`](LICENSE) file.

## Contributions
If you see any errors within the code or in the README itself, feel free to open an issue. Since this is a repository for my personal learning, I'm not looking for any pull requests adding new code, but I'm always open to suggestions and corrections.