[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

mov bx, [BUFFER_ADDRESS] ; load the address of the base register
mov bp, [BUFFER_ADDRESS] ; load the address to the base pointer

;mov dl, 0x00 ; load the drive number
mov cl, dl ; load the drive number to print

call print_hex ; print the drive number in hex
call line_break ; add a line break

call read_sector ; read the sector from the disk
call print ; print the contents of the buffer

jmp $ ; loop forever

; disk reading functions
read_sector:
    pusha ; save all of the registers to the stack

    mov ah, 0x02 ; 'Read Sectors Into Memory' function
    mov al, 0x01 ; set the sector amount into the register

    mov cl, 0x02 ; sector (0x02 is the first 'available' sector)
    mov ch, 0x00 ; cylinder (from 0x0 to 0x3FF)
    mov dh, 0x00 ; head number (from 0x0 to 0xF)

    int 0x13 ; call the BIOS interrupt
    jc disk_error ; if the carry flag is set, there was an error

    popa ; restore all of the registers from the stack
    ret ; return to caller

disk_error:
    mov bp, DISK_ERROR ; load the address of the error message
    mov cl, ah ; load the error code into the `cl` register

    call print ; print the error message

    call print_hex ; print the error code in hex
    call line_break ; add a line break

    hlt ; halt the system

BUFFER_ADDRESS: dw 0x7e00 ; the address of the buffer
DISK_ERROR: db "error: disk read failed with code 0x", 0 ; the error message

; printing functions
print:
    pusha ; save registers

    print_loop:
        mov al, [bp] ; move the character at the base address into `al`

        cmp al, 0x00 ; check if the character is a null byte
        je print_end ; if so, jump to `print_end`

        mov ah, 0x0e ; change the interrupt mode to "Teletype Output"
        int 0x10 ; call the BIOS interrupt

        inc bp ; increment the base address
        jmp print_loop ; jump back to the start of the loop
    
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

; pad the rest of the sector with null bytes
times 1024 - ($ - $$) db 0