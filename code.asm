include emu8086.inc

org 100h

; Prompt user to enter the secret key
printn 'Enter the secret key then press ENTER: '
mov cx, 256
lea si, t          ; Load address of 't' into SI
mov ah, 1          ; Set function for reading character input

; Read secret key from user
input:
int 21h            ; Read character into AL
mov [si], al       ; Store character at [si]
cmp al, 0dh        ; Check for Enter key
je process_key
add si, 2          ; Move to next position in memory
inc len            ; Increment key length
loop input

process_key:
printn 'Input is stored...'

; Initialize S array with values from 0 to 255
lea si, s
mov cx, 256
mov bx, 0
printn 'KSA processing...'
fill_s:
mov word ptr [si], bx
add si, 2
inc bx
loop fill_s

; Key Scheduling Algorithm (KSA)
mov cx, 256
lea si, s
lea di, s
lea bp, t
mov i, 0           ; Initialize index i to 0
mov j, 0           ; Initialize index j to 0

ksa:
mov al, [i]
mov bl, [len]
div bl              ; i / len
mov al, ah          ; modulus (i % len)
mov ah, 0
mov mod, ax
shl mod, 1

mov dx, [j]
add dx, [si - 2]   ; j = j + s[i]
push bp
add bp, mod
add dx, [bp]       ; j = j + s[i] + t[mod]
pop bp
mov [j], dx
mov ax, dx
mov bx, 256
mov dx, 0
div bx
mov [j], dx

; Swap s[i] and s[j]
mov ax, [si]
push [j]
shl [j], 1
push di
add di, [j]
mov dx, [di - 2]
pop di
mov [si], dx
push di
add di, [j]
mov [di - 2], ax
pop di
pop [j]
add si, 2
inc i
loop ksa

PRINTN 'KSA DONE.'

; Pseudo-Random Generation Algorithm (PRGA)
printn 'Please press ENTER to get the next key or TAB to terminate:'
mov si, 0           ; Initialize index i to 0
mov di, 0           ; Initialize index j to 0
lea bp, s

mov cx, 1
prga:
inc cx
inc si              ; i = i + 1
mov ax, si
mov bx, 256
mov dx, 0
div bx
mov si, dx          ; i = (i + 1) % 256

push si
push bp
shl si, 1
add bp, si
add di, [bp]        ; j = j + s[i]
mov ax, di
mov bx, 256
mov dx, 0
div bx
mov di, dx          ; j = (j + s[i]) % 256
pop bp

; Swap s[i] and s[j]
push di
shl di, 1
mov ax, [bp + si]  ; s(i)
mov bx, [bp + di]  ; s(j)
mov [bp + si], bx
mov [bp + di], ax
pop di
pop si

; Compute and display output
add ax, bx
mov dx, 0
mov bx, 256
div bx              ; Final index in dx
push bp
add bp, dx
mov ax, [bp]        ; Key is ax
cmp ah, al
jb shift
mov al, ah
mov ah, 0
shift:
call PRINT_NUM_UNS
printn '     '
pop bp

mov ah, 1
int 21h
cmp al, 9h
je finish
loop prga

finish:
printn 'Thanks for using our program.'
printn 'TERMINATING...'
ret

DEFINE_PRINT_NUM_UNS

; Data segment
mod dw ?
i db 0
len db 0
t dw 256 dup(0)
j dw 0
s dw 256 dup(0)
