[bits 16] ; set the code to 16-bit mode
[org 0x7c00] ; set the global offset (0x7c00 is where the BIOS loads the bootloader)

; set the PIT to the desired frequency
mov al, 0xb6 ; set the command byte
out 0x43, al

mov al, 0xa9 ; lower byte (frequency)
out 0x42, al

mov al, 0x04 ; upper byte (frequency)
out 0x42, al

; play the sound using the PC speaker
in al, 0x61 ; read the port

mov ah, al ; save the value
or ah, 3 ; set bits 0 and 1

cmp al, ah ; check if the value has changed
je $ ; if not, jump to the current address

mov al, ah ; save the new value
out 0x61, al ; write the new value to the port

; pad the rest of the sector with null bytes
times 510 - ($ - $$) db 0

; set the magic number
dw 0xaa55