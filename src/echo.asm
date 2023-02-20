[bits 16] ; 16-bit code
[org 0x7c00] ; bootloader offset

loop:
    mov ah, 0x00 ; read character
    int 0x16 ; BIOS interrupt

    mov ah, 0x0e ; print character
    int 0x10 ; BIOS interrupt

    jmp loop

times 510 - ($ - $$) db 0 ; pad to 510 bytes
dw 0xaa55 ; magic signature