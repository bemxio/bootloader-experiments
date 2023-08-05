[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)\

; constants
IVT_IRQ0_OFFSET equ 0x0020 ; the offset of the first IRQ in the IVT
PIT_RELOAD_VALUE equ 0x9b5c ; the reload value for the PIT (0x9b5c, 39722, results in 30 hz/FPS)

cli ; disable interrupts for the setup

initialize_pit:
    mov al, 0x34 ; set the command byte (channel 0, lobyte/hibyte, rate generator)
    out 0x43, al ; send the command byte to the PIT

    mov ax, PIT_RELOAD_VALUE ; set the reload value (0x9b5c, 39722, results in 30 hz/FPS)

    out 0x40, al ; send the low byte to the PIT

    mov al, ah ; set the high byte to the low byte
    out 0x40, al ; send the high byte to the PIT

setup_ivt:
    mov word [IVT_IRQ0_OFFSET], pit_handler ; set the PIT handler offset in the IVT
    mov word [IVT_IRQ0_OFFSET + 2], 0x00 ; set the PIT handler segment in the IVT

sti ; re-enable interrupts

loop_forever:
    jmp $ ; jump to the current address (thus, making an infinite loop)

pit_handler:
    pusha ; push all registers to the stack

    mov ah, 0x0e ; change the interrupt mode to "Teletype Output"

    mov al, '.' ; set the character to print
    mov bh, 0x00 ; set the page number

    int 0x10 ; call the BIOS interrupt

    mov al, 0x20 ; set the EOI (End Of Interrupt) signal
    out 0x20, al ; send it to the PIC

    popa ; pop all registers from the stack
    iret ; return from the interrupt

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0 

; set the magic number
dw 0xaa55