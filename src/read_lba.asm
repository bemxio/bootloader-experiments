[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

mov cl, dl ; load the drive number to print

call print_hex ; print the drive number in hex
call line_break ; add a line break

call read_sector ; read the sector from the disk

mov bx, 0x1000 ; load the address of the buffer
call print ; print the contents of the buffer

jmp $ ; loop forever

; disk reading functions
DISK_ADDRESS_PACKET:
    db 0x10     ; size of the packet, 16 bytes by default
    db 0x00     ; unused, should always be 0

    dw 0x01     ; number of sectors to read
    dw 0x1000   ; pointer to the buffer
    dw 0x00     ; page number, 0 by default

    dd 0x01     ; offset of the sector to read (lower 32-bits)
    dd 0x00     ; unused here (upper 32-bits)

read_sector:
    mov ah, 0x42 ; 'Extended Read Sectors From Drive' function
    mov si, DISK_ADDRESS_PACKET ; load the address of the packet

    int 0x13 ; BIOS interrupt
    jc disk_error ; if carry flag is set, an error occurred

    ret ; return to caller

disk_error:
    mov bx, DISK_ERROR ; load the address of the error message
    mov cl, ah ; load the error code into the `cl` register

    call print ; print the error message

    call print_hex ; print the error code in hex
    call line_break ; add a line break

    hlt ; halt the system

DISK_ERROR: db "error: disk read failed with code 0x", 0

; printing functions
print:
    pusha ; save registers

    print_start:
        mov al, [bx] ; move the character at the base address into `al`

        cmp al, 0 ; check if the character is a null byte
        je print_end ; if so, jump to `print_end`

        mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
        int 0x10 ; call the BIOS interrupt

        inc bx ; increment the base address
        jmp print_start ; jump back to the start of the loop
    
    print_end:
        popa ; restore registers
        ret ; return from the function

print_hex:  
    pusha ; save all of the registers to the stack

    ; convert the high nibble to ASCII character
    mov ch, cl ; copy the value to convert
    shr ch, 4 ; shift the value 4 bits to the right

    call print_hex_conversion ; convert and print the high nibble

    ; convert the low nibble to ASCII character
    mov ch, cl ; copy the value to convert
    and ch, 0x0f ; mask out the low nibble

    call print_hex_conversion ; convert and print the low nibble

    popa ; restore registers
    ret ; return from the function

    print_hex_conversion:
        add ch, '0' ; convert value to ASCII character

        cmp ch, '9' ; check if the value is less or equal to '9'
        jle print_hex_digit ; if it is, jump to print_hex_digit

        add ch, 7 ; adjust the value to convert to the correct ASCII character

    print_hex_digit:
        mov al, ch ; move the value to convert to the right register

        mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
        int 0x10 ; call the BIOS interrupt

        ret ; return from the function

line_break:
    pusha ; save registers
    mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
    
    mov al, 0x0a ; move the line feed character into `al`
    int 0x10 ; call the BIOS interrupt
    
    mov al, 0x0d ; move the carriage return character into `al`
    int 0x10 ; call the BIOS interrupt
    
    popa ; restore registers
    ret ; return from the function

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0 

; set the magic number
dw 0xaa55

; the test data
db "Hello, world! If all characters are shown correctly, that means disk reading works. If not, something is messed up.", 0x00