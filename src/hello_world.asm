[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

mov si, MESSAGE ; move the base address of the string into the index register
call print ; call the `print` function

jmp $ ; loop forever

print:
    pusha ; save registers

    mov ah, 0x0e ; set "Teletype Output" mode
    xor bx, bx ; set page number and foreground color to 0

    print_loop:
        mov al, [si] ; move the character from the base pointer to the register

        test al, al ; check if the character is null
        jz print_end ; if so, we're done

        int 0x10 ; call the BIOS interrupt

        inc si ; move to the next character
        jmp print_loop ; repeat

    print_end:
        popa ; restore registers
        ret ; return from function

; data section
MESSAGE: db "Hello, world!", 0x00

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55