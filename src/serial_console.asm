[bits 16] ; 16-bit mode
[org 0x7c00] ; global offset

mov cx, BAUD_RATE_DIVISOR ; set the baud rate divisor
mov dx, COM1_SERIAL_PORT ; set the serial port address
mov si, TEST_STRING ; set the source index to the string address

call setup_serial ; setup the serial port
call print ; print the string

jmp $ ; loop forever

; functions
setup_serial:
    pusha ; save registers

    xor al, al ; disable all interrupts
    inc dx ; set the IER address
    out dx, al ; send the command to the IER

    mov al, 0x80 ; set the DLAB bit
    add dx, 0x02 ; set the LCR address
    out dx, al ; send the command to the LCR

    mov al, cl ; get the low byte of the divisor
    sub dx, 0x03 ; reset the port address
    out dx, al ; send the byte to the port

    mov al, ch ; get the high byte of the divisor
    inc dx ; set the IER address
    out dx, al ; send the high byte of the divisor

    mov al, CONNECTION_PARAMETERS ; set the connection parameters
    add dx, 0x02 ; set the LCR address
    out dx, al ; send the command to the LCR

    mov al, 0xc7 ; enable and clear the FIFO with 14-byte threshold
    dec dx ; set the FCR address
    out dx, al ; send the command to the FCR

    mov al, 0x0f ; enable the DTR, RTS, OUT1 and OUT2 pins
    add dx, 0x02 ; set the MCR address
    out dx, al ; send the command to the MCR

    popa ; restore registers
    ret ; return from function

print:
    pusha ; save registers

    print_loop:
        mov al, [si] ; load the character from the string

        test al, al ; check if the character is null
        jz print_end ; if so, print is done

        out dx, al ; send the character to the serial port

        inc si ; move to the next character
        jmp print_loop ; repeat the loop

    print_end:
        popa ; restore registers
        ret ; return from function

; constants
COM1_SERIAL_PORT equ 0x3f8 ; COM1 serial port address
BAUD_RATE_DIVISOR equ 3 ; baud rate divisor (115200 / 3 = 38400 baud)
CONNECTION_PARAMETERS equ 0x03 ; connection parameters (8 bits, no parity, 1 stop bit)

TEST_STRING db "Hello, world!", 0x00 ; test string

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55