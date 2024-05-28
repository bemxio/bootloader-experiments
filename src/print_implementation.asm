[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

; print string
mov si, MESSAGE ; set the source index to the message
mov bl, [ATTRIBUTE] ; set the attribute byte

call print ; call the print function

jmp $ ; loop forever

; functions
print:
    pusha ; save registers

    mov ah, 0x03 ; "Get Cursor Position" mode
    xor bh, bh ; set page number to 0

    int 0x10 ; call the BIOS interrupt

    xor ch, ch ; clear the hi-byte character count
    mov cl, 0x01 ; set the low-byte character count to 1
    
    test bl, bl ; check if attribute is null
    jnz print_loop ; if not, skip setting the attribute

    mov bl, 0x07 ; set attribute to light gray on white

    print_loop:
        mov ah, 0x02 ; "Set Cursor Position" mode
        int 0x10 ; call the BIOS interrupt

        mov al, [si] ; move the character from the source index to the register
        inc si ; move to the next character

        test al, al ; check if the character is null
        jz print_end ; if so, we're done

        cmp al, 0x10 ; check if the character is a newline
        je print_newline ; if so, move to a new line

        mov ah, 0x09 ; "Write Character and Attribute at Cursor Position" mode
        int 0x10 ; call the BIOS interrupt

        inc dl ; increment the column counter

        cmp dl, 0x50 ; check if the column counter is at the end of the line
        je print_newline ; if so, move to a new line

        jmp print_loop ; repeat

    print_newline:
        xor dl, dl ; reset the column counter
        inc dh ; increment the row counter

        jmp print_loop ; repeat

    print_end:
        popa ; restore registers
        ret ; return from function

; data segment
MESSAGE db "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", 0x10, "Do newlines work?", 0x00
ATTRIBUTE db 0xf0

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55