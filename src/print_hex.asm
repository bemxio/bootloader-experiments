[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

mov al, [HEX_VALUE] ; load the value to convert to hex
call print_hex ; call the print_hex function

jmp $ ; loop forever

print_hex:
    pusha ; save all registers

    mov ah, 0x00 ; set the iteration counter to 0
    mov bx, HEX_BUFFER ; set the address of the buffer

    print_hex_loop:
        mov [bx], al; store the value to convert in the buffer
        shr byte [bx], 4 ; shift the value right by 4 bits

        cmp byte [bx], 9 ; check if the value is greater than 9
        jg print_hex_subtraction ; if it is, subtract 10 from the value

        cmp byte [bx], 9 ; check if the value is less than 9
        jle print_hex_addition ; if it is, add the ASCII value of '0' to the value

        shl al, 4 ; shift the orignal left by 4 bits

        inc bx ; increment the address
        inc ah ; increment the iteration counter

        cmp ah, 2 ; check if the iteration counter is less than 2
        jl print_hex_loop ; if it is, loop back to the beginning

    mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
    
    mov al, [bx] ; load the first character of the hex string
    int 0x10 ; call the BIOS interrupt

    mov al, [bx + 1] ; load the second character of the hex string
    int 0x10 ; call the BIOS interrupt

    popa ; restore registers
    ret ; return from the function

    print_hex_subtraction:
        sub byte [bx], 10 ; subtract 10 from the value
        add byte [bx], 'A' ; add the ASCII value of 'A' to the value

    print_hex_addition:
        add byte [bx], '0' ; add the ASCII value of 'A' to the value

; constants
HEX_VALUE equ 255 ; the value to convert to hex
HEX_BUFFER db "00" ; buffer for the hex string

times 510 - ($ - $$) db 0 ; pad the rest of the sector with null bytes
dw 0xaa55 ; set the magic number