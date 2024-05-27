[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

mov bp, INPUT_PROMPT ; set the base pointer to the input prompt address
call print ; call the print function

mov bp, BUFFER ; set the base pointer to the buffer
call input ; call the input function

mov bp, INPUT_RESPONSE ; set the base pointer to the input response address
call print ; call the print function

mov bp, BUFFER ; set the base pointer to the buffer
call print ; call the print function

jmp $ ; infinite loop

; functions
print:
    pusha ; save registers

    mov ah, 0x0e ; set "Teletype Output" mode
    xor bx, bx ; set page number and foreground color to 0

    print_loop:
        mov al, [bp] ; move the character from the base pointer to the register

        test al, al ; check if the character is null
        jz print_end ; if so, we're done

        int 0x10 ; call the BIOS interrupt

        inc bp ; move to the next character
        jmp print_loop ; repeat
    
    print_end:
        popa ; restore registers
        ret ; return from function

input:
    pusha ; save registers

    input_loop:
        mov ah, 0x00 ; set "Get Keystroke" mode
        int 0x16 ; call the BIOS interrupt

        cmp al, 0x0d ; check if the Enter key was pressed
        je input_end ; if so, we're done

        mov ah, 0x0e ; set "Teletype Output" mode
        int 0x10 ; call the BIOS interrupt

        mov byte [bp], al ; move the character to the base pointer
        inc bp ; move to the next character

        jmp input_loop ; repeat

    input_end:
        mov ah, 0x0e ; set "Teletype Output" mode

        mov al, 0x0d ; move the carriage return character to the register
        int 0x10 ; call the BIOS interrupt

        mov al, 0x0a ; move the newline character to the register
        int 0x10 ; call the BIOS interrupt

        mov byte [bp], 0x00 ; null-terminate the string

        popa ; restore registers
        ret ; return from function

; data
INPUT_PROMPT db "Enter your name: ", 0x00
INPUT_RESPONSE db "Hello, ", 0x00

BUFFER times 64 db 0x00

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55