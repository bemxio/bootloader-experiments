[bits 16] ; 16-bit code
[org 0x7c00] ; bootloader offset

mov bx, VIDEO_MODE_TEXT ; load the string into the `bx` register
call print ; print the string

mov ah, 0x0f ; 'Get Current Video Mode' function
int 0x10 ; call BIOS interrupt

mov dh, al ; move the video mode into the `dh` register
call print_hex ; print the video mode in hex

jmp $ ; infinite loop

; functions for printing stuff
%include "./src/functions/print.asm"
%include "./src/functions/print_hex.asm"

; constants
VIDEO_MODE_TEXT: db "The current video mode is ", 0

; the magic number to let the BIOS know that this is the bootloader
times 510 - ($ - $$) db 0 ; fill the rest of the sector with null bytes
dw 0xaa55 ; insert the magic number