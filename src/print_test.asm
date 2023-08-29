[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

mov bp, PRINT_MESSAGE ; move the base address of the string into `bx`
call print ; call the `print` function

jmp $ ; loop forever

print:
    pusha ; save registers

    mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
    mov bx, 0x00 ; set the page number and foreground color to 0

    print_loop:
        mov al, [bp] ; move the character at the base pointer into `al`

        cmp al, 0x00 ; check if the character is a null byte
        je print_end ; if so, jump to `print_end`

        int 0x10 ; call the BIOS interrupt

        inc bp ; increment the base pointer
        jmp print_loop ; jump back to the start of the loop
    
    print_end:
        popa ; restore registers
        ret ; return from the function

PRINT_MESSAGE: db "Hello, world!", 0x00 ; define a string

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55