[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

; user interaction stuff
mov si, INPUT_PROMPT ; set the base pointer to the input prompt address
call print ; call the print function

mov di, INPUT_BUFFER ; set the base pointer to the buffer
call input ; call the input function

mov si, INPUT_RESPONSE ; set the base pointer to the input response address
call print ; call the print function

mov si, INPUT_BUFFER ; set the base pointer to the buffer
call print ; call the print function

; a little exclamation mark :D
mov ah, 0x0e ; set "Teletype Output" mode
mov al, '!' ; move the exclamation mark to the register

int 0x10 ; call the BIOS interrupt

jmp $ ; loop forever

; functions
print:
    pusha ; save registers

    mov ah, 0x0e ; set "Teletype Output" mode
    xor bh, bh ; set page number to 0

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

input:
    pusha ; save registers

    input_loop:
        mov ah, 0x00 ; set "Get Keystroke" mode
        int 0x16 ; call the BIOS interrupt

        cmp al, 0x0d ; check if the Enter key was pressed
        je input_end ; if so, we're done

        cmp al, 0x08 ; check if the Backspace key was pressed
        je input_backspace ; if so, handle backspace

        mov ah, 0x0e ; set "Teletype Output" mode
        int 0x10 ; call the BIOS interrupt

        mov byte [di], al ; move the character to the base pointer
        inc di ; move to the next character

        jmp input_loop ; repeat

    input_backspace:
        cmp di, INPUT_BUFFER ; check if we're at the beginning of the buffer
        je input_loop ; if so, ignore the backspace

        dec di ; move back one character
        mov byte [di], 0x00 ; null-terminate the string

        mov si, INPUT_BACKSPACE_HANDLER ; set the base pointer to the backspace handler
        call print ; call the print function

        jmp input_loop ; repeat

    input_end:
        mov ah, 0x0e ; set "Teletype Output" mode

        mov al, 0x0d ; move the carriage return character to the register
        int 0x10 ; call the BIOS interrupt

        mov al, 0x0a ; move the newline character to the register
        int 0x10 ; call the BIOS interrupt

        mov byte [di], 0x00 ; null-terminate the string

        popa ; restore registers
        ret ; return from function

; various data
INPUT_BACKSPACE_HANDLER db 0x08, 0x20, 0x08, 0x00

INPUT_PROMPT db "Enter your name: ", 0x00
INPUT_RESPONSE db "Hello, ", 0x00

INPUT_BUFFER times 64 db 0x00

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55