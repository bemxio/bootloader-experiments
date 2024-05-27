[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

echo_chamber:
    mov ah, 0x00 ; set "Get Keystroke" mode
    int 0x16 ; call the BIOS interrupt

    mov ah, 0x0e ; set "Teletype Output" mode
    int 0x10 ; call the BIOS interrupt

    jmp echo_chamber ; repeat

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55