[bits 16] ; 16-bit mode
[org 0x7c00] ; global offset

mov ax, ss ; move the stack segment to the first register
mov bx, sp ; move the stack pointer to the second register

mov cl, ah ; move the segment high byte to the primary register
call print_hex ; print the high byte

mov cl, al ; move the segment low byte to the primary register
call print_hex ; print the low byte

mov ah, 0x0e ; 'Teletype Output' function
mov al, ':' ; a colon seperating the segment and the pointer

int 0x10 ; print the colon

mov cl, bh ; move the pointer high byte to the primary register
call print_hex ; print the high byte

mov cl, bl ; move the pointer low byte to the primary register
call print_hex ; print the low byte

jmp $ ; loop forever

; functions
print_hex:
    pusha ; save registers

    mov ch, cl ; copy the value to another register
    shr ch, 0x04 ; shift right by 4 bits
    call print_hex_digit ; print the high nibble

    mov ch, cl ; copy the value to another register
    and ch, 0x0f ; mask the low nibble
    call print_hex_digit ; print the low nibble

    popa ; restore registers
    ret ; return from function

    print_hex_digit:
        add ch, '0' ; convert the value to ASCII

        cmp ch, '9' ; check if the value is less than or equal to 9
        jle print_hex_char ; if so, print the character

        add ch, 0x07 ; adjust the value to a correct ASCII character

    print_hex_char:
        mov al, ch ; move the character to the register
        mov ah, 0x0e ; 'Teletype Output' function

        int 0x10 ; call the BIOS interrupt

        ret ; return from function

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55