# bootloader-experiments
This repository contains a collection of bootloaders written by me in Assembly, for learning more about BIOS, bootloaders, the x86 architecture, and the Assembly language itself.

## Building
For building stuff, you will need an assembler, such as NASM. Optionally, you can also install `make` and `qemu` for easier building and running.

### The `Makefile` way
If you just want to quickly check out a bootloader, you can use `make` to build and run it. For example, to build the `echo.asm` file, simply run:

```bash
make echo.asm
```

That will build the bootloader with NASM and run it in QEMU.

If you want to build all of the files in the `src` directory, you can run `make` or `make all`.

### The manual way
If you want to build a bootloader manually, just get an assembler. With NASM, you can build the `echo.asm` file by executing:

```bash
nasm -f bin -o bootloader.bin src/echo.asm
```

Then, you can run it in QEMU by running:

```bash
qemu-system-x86_64 -drive format=raw,file=bootloader.bin
```

## License
This project is released into the public domain. Do what you want with it, as long as you don't hold me responsible for anything that happens!

In case you really want to dive into the details, the license is available in the [`LICENSE`](LICENSE) file.

## Contributing
Since this is my personal playground in playing with Assembly, I would prefer if you don't add any bootloader code to this repository. However, if you want to improve this README, or perhaps a `Makefile`, feel free to make a pull request regarding that!

Or if you see a bug somewhere within the code, feel free to open an issue about it.