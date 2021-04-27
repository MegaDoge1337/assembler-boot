use16
org 0x7C00
boot__code16:

        cli
        xor ax,ax
        mov ds,ax
        mov es,ax
        mov ss,ax
        mov AX,boot__code16
        mov SP,AX
        sti

        mov AH,0x02
        mov AL,0Ch
        mov CL,2
        mov CH,0
        mov DH,0
        mov DL,0
        mov BX,boot__continuation
        int 0x13

        jmp boot__continuation

        rb 510-($-$$)
        db 0x55,0xAA
;--------------------------------------
boot__continuation:

jmp ints__install

off__08h equ 08h*4

timer__int:
        xchg bx, bx
        xor dx, dx
        xor eax, eax
        mov ax, [timer__value]
        mov bx, 182
        div bx
        xor cx, cx
        mov cx, 6

convert__timer__value:
        mov bx, 10
        xor dx, dx
        div bx
        add dx, 30h
        mov si, cx
        mov [timer__value__string + si], dl
        loop convert__timer__value

        xor si, si
        xor cx, cx
        mov ch, 017h
        mov bx, 092h

timer__value__out:
        mov cl, [timer__value__string + si]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax
        inc si
        add bx, 02h
    
        cmp si, 7
        jne timer__value__out

        add [timer__value], 10
        mov al, 20h
        out 20h, al
        iret

off__09h equ 09h*4

keyboard__int:
        xchg bx, bx

        in al, 060h
        cmp al, 0C5h
        je reboot
        jne no__reboot

reboot:
        jmp 0FFFFh:0000h

no__reboot:

        mov dl, al

        and al, 0F0h
        shr ax, 4
        mov bx, xlat__table
        xlatb

        mov ch, 017h
        mov bx, 13Ch
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov al, dl

        and al, 0Fh
        mov bx, xlat__table
        xlatb

        mov ch, 017h
        mov bx, 13Eh
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        in al, 061h
        mov ah, al
        or al, 80h
        out  061h, al
        xchg  ah, al
        out 061h, al
        mov al, 020h
        out 020h, al
        iret


ints__install:

        cli
        xor ax, ax
        mov es, ax
        mov ax, [es:off__08h]
        mov [old__offset__08h], ax
        mov ax, [es:off__08h + 2]
        mov [old__segment__08h], ax
    
        mov ax, timer__int
        mov [es:off__08h], ax
        push cs
        pop ax
        mov [es:off__08h + 2], ax

        xor ax, ax
        mov es, ax
        mov ax, [es:off__09h]
        mov [old__offset__09h], ax
        mov ax, [es:off__09h + 2]
        mov [old__segment__09h], ax
    
        mov ax, keyboard__int
        mov [es:off__09h], ax
        push cs
        pop ax
        mov [es:off__09h + 2], ax
        sti

clear__display:
        mov ax, 0x03
        int 0x10

        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0h
        mov ch, 017h

welcome:
        mov cl, [welcome__message + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, welcome__message__len
        jne welcome


check__floppy:

        int 0x11

        test ax, 1
        jnz have__floppy
        jz no__floppy


have__floppy:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0A0h
        mov ch, 007h

have__floppy__out:
        mov cl, [floppy__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, floppy__msg__len
        jne have__floppy__out

        jmp check__coprocessor

no__floppy:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0A0h
        mov ch, 007h

no__floppy__out:
        mov cl, [no__floppy__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, no__floppy__msg__len
        jne no__floppy__out

check__coprocessor:

        xor ax, ax
        int 0x11

        test ax, 2
        jnz have__coprocessor
        jz no__coprocessor

have__coprocessor:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0140h
        mov ch, 007h

have__coprocessor__out:
        mov cl, [coprocessor__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, coprocessor__msg__len
        jne have__coprocessor__out

        jmp check__ram__size

no__coprocessor:
        xchg bx, bx
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0140h
        mov ch, 007h

no__coprocessor__out:
        mov cl, [no__coprocessor__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, no__coprocessor__msg__len
        jne no__coprocessor__out

check__ram__size:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 01E0h
        mov ch, 007h

ram__size__out:

        mov cl, [ram__size__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, ram__size__msg__len
        jne ram__size__out

        xor cx, cx
        mov cx, bx

        xor ax, ax
        int 0x11

        shr ax, 2
        and ax, 3

        mov bx, 16
        mul bx

ram__size__value__out:
        mov bx, 10
        div bx

        add ax, 30h
        xor bx, bx
        mov bx, cx
        xor cx, cx
        mov cl, al
        mov ch, 007h
        xor ax, ax
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        xor cx, cx
        mov cx, bx
        xor ax, ax
        mov ax, dx
        
        add ax, 30h
        xor bx, bx
        mov bx, cx
        xor cx, cx
        mov cl, al
        mov ch, 007h
        xor ax, ax
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

check__video__mode:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0280h
        mov ch, 007h

video__mode__out:
        mov cl, [video__mode__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, video__mode__msg__len
        jne video__mode__out

        xor si, si

check__mode__40x25__color:

        int 0x11
        shr ax, 4
        and ax, 3

        cmp ax, 02h
        je mode__80x25__color__out

        cmp ax, 03h
        je mode__80x25__mono__out

        jmp mode__40x25__color__out

mode__40x25__color__out:

        mov cl, [mode__40x25__color__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, mode__40x25__color__msg__len
        jne mode__40x25__color__out

        jmp check__number__of__floppy

mode__80x25__color__out:

        mov cl, [mode__80x25__color__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, mode__80x25__color__msg__len
        jne mode__80x25__color__out

        jmp check__number__of__floppy

mode__80x25__mono__out:

        mov cl, [mode__80x25__mono__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, mode__80x25__mono__msg__len
        jne mode__80x25__mono__out

check__number__of__floppy:

        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0320h
        mov ch, 007h

number__of__floppy__out:
        mov cl, [number__of__floppy__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, number__of__floppy__msg__len
        jne number__of__floppy__out

        xor si, si

number__of__floppy__value__out:
        xor cx, cx
        mov cx, bx

        int 0x11
        shr ax, 6
        and ax, 3

        mov bx, 1
        mul bx

        add ax, 01h

        mov bx, 10
        div bx

        add ax, 30h
        xor bx, bx
        mov bx, cx
        xor cx, cx
        mov cl, al
        mov ch, 007h
        xor ax, ax
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        xor cx, cx
        mov cx, bx
        xor ax, ax
        mov ax, dx
        
        add ax, 30h
        xor bx, bx
        mov bx, cx
        xor cx, cx
        mov cl, al
        mov ch, 007h
        xor ax, ax
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

check__dma:

        test ax, 256
        jnz dma__enable
        jz dma__disable


dma__enable:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 03C0h
        mov ch, 007h

dma__enable__out:
        mov cl, [dma__enable__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, dma__enable__msg__len
        jne dma__enable__out

        jmp number__of__rs232__cards

dma__disable:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 03C0h
        mov ch, 007h

dma__disable__out:
        mov cl, [dma__disable__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, dma__disable__msg__len
        jne dma__disable__out

number__of__rs232__cards:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0460h
        mov ch, 007h

number__of__rs232__cards__out:
        mov cl, [number__of__rs232__cards__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, number__of__rs232__cards__msg__len
        jne number__of__rs232__cards__out

number__of__rs232__cards__value__out:

        xor cx, cx
        mov cx, bx

        int 0x11
        shr ax, 9
        and ax, 3

        mov bx, 1
        mul bx

        add ax, 01h

        mov bx, 10
        div bx

        add ax, 30h
        xor bx, bx
        mov bx, cx
        xor cx, cx
        mov cl, al
        mov ch, 007h
        xor ax, ax
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        xor cx, cx
        mov cx, bx
        xor ax, ax
        mov ax, dx
        
        add ax, 30h
        xor bx, bx
        mov bx, cx
        xor cx, cx
        mov cl, al
        mov ch, 007h
        xor ax, ax
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

check__game__port:

        test ax, 2048
        jnz game__port__enable
        jz game__port__disable


game__port__enable:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0500h
        mov ch, 007h

game__port__enable__out:
        mov cl, [game__port__enable__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, game__port__enable__msg__len
        jne game__port__enable__out

        jmp check__internal__modem

game__port__disable:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0500h
        mov ch, 007h

game__port__disable__out:
        mov cl, [game__port__disable__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, game__port__disable__msg__len
        jne game__port__disable__out

check__internal__modem:

        test ax, 4096
        jnz internal__modem__installed
        jz internal__modem__not__installed


internal__modem__installed:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 05A0h
        mov ch, 007h

internal__modem__installed__out:
        mov cl, [internal__modem__installed__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, internal__modem__installed__msg__len
        jne internal__modem__installed__out

        jmp number__of__printers__attached

internal__modem__not__installed:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 05A0h
        mov ch, 007h

internal__modem__not__installed__out:
        mov cl, [internal__modem__not__installed__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, internal__modem__not__installed__msg__len
        jne internal__modem__not__installed__out

number__of__printers__attached:
        xor ax, ax
        xor cx, cx
        xor si, si
        mov bx, 0640h
        mov ch, 007h

number__of__printers__attached__out:
        mov cl, [number__of__printers__attached__msg + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, number__of__printers__attached__msg__len
        jne number__of__printers__attached__out

number__of__printers__attached__value__out:
        xor cx, cx
        mov cx, bx

        int 0x11
        shr ax, 14
        and ax, 3

        mov bx, 1
        mul bx

        mov bx, 10
        div bx

        add ax, 30h
        xor bx, bx
        mov bx, cx
        xor cx, cx
        mov cl, al
        mov ch, 007h
        xor ax, ax
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        xor cx, cx
        mov cx, bx
        xor ax, ax
        mov ax, dx
        
        add ax, 30h
        xor bx, bx
        mov bx, cx
        xor cx, cx
        mov cl, al
        mov ch, 007h
        xor ax, ax
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        xor si, si
        mov bx, 0780h
        xor cx, cx
        mov ch, 007h

card__map__header:
        mov cl, [table__header + si]
        push ds

        mov ax, 0B800h
        mov ds, ax

        mov [bx], cx

        pop ax
        mov ds, ax

        inc si
        add bx, 02h

        cmp si, table__header__len
        jne card__map__header

        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        xor esi, esi

card__map__read__start:
        mov eax, 0E820h
        mov edx, [smap__signature]
        mov ecx, 20
        mov di, buffer

card__map__reading:
        int 0x15

        mov esi, ebx

        xor eax, eax
        xor ebx, ebx
        xor ecx, ecx
        xor edx, edx

        ;BaseAddrHigh
        xor eax, eax
        mov eax, [di + 4]

base__addr__high__out:

        mov edx, eax
        and eax, 0F0000000h
        shr eax, 28
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0F000000h
        shr eax, 24
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 00F00000h
        shr eax, 20
        mov ebx, xlat__table
        xlatb


        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax


        mov eax, edx
        and eax, 000F0000h
        shr eax, 16
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0000F000h
        shr eax, 12
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 00000F00h
        shr eax, 8
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 000000F0h
        shr eax, 4
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0000000Fh
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        ;BaseAddrLow
        xor eax, eax
        mov eax, [di + 0]


base__addr__low__out:

        mov edx, eax
        and eax, 0F0000000h
        shr eax, 28
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 04h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0F000000h
        shr eax, 24
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 00F00000h
        shr eax, 20
        mov ebx, xlat__table
        xlatb


        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax


        mov eax, edx
        and eax, 000F0000h
        shr eax, 16
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0000F000h
        shr eax, 12
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 00000F00h
        shr eax, 8
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 000000F0h
        shr eax, 4
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0000000Fh
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        ;LengthHigh
        xor eax, eax
        mov eax, [di + 12]

length__high__out:

        mov edx, eax
        and eax, 0F0000000h
        shr eax, 28
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 04h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0F000000h
        shr eax, 24
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 00F00000h
        shr eax, 20
        mov ebx, xlat__table
        xlatb


        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax


        mov eax, edx
        and eax, 000F0000h
        shr eax, 16
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0000F000h
        shr eax, 12
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 00000F00h
        shr eax, 8
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 000000F0h
        shr eax, 4
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0000000Fh
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        ;LengthLow
        xor eax, eax
        mov eax, [di + 8]

length__low__out:

        mov edx, eax
        and eax, 0F0000000h
        shr eax, 28
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 04h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0F000000h
        shr eax, 24
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 00F00000h
        shr eax, 20
        mov ebx, xlat__table
        xlatb


        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax


        mov eax, edx
        and eax, 000F0000h
        shr eax, 16
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0000F000h
        shr eax, 12
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 00000F00h
        shr eax, 8
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 000000F0h
        shr eax, 4
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        mov eax, edx
        and eax, 0000000Fh
        mov ebx, xlat__table
        xlatb

        mov ch, 007h
        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, al
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax


        ;Type
        xor eax, eax
        mov eax, [di + 16]

type__is__arm:
        cmp ax, 1
        jne type__is__arr

        ; ARM
        mov ch, 007h

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__arm + 0]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__arm + 1]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__arm + 2]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__arm + 3]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        jmp type__out

type__is__arr:
        cmp ax, 2
        jne type__is__udf

        ; ARR
        mov ch, 007h

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__arr + 0]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__arr + 1]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__arr + 2]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__arr + 3]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        jmp type__out

type__is__udf:

        ; UDF
        mov ch, 007h

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__udf + 0]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__udf + 1]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__udf + 2]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

        add [table__pointer], 02h
        mov bx, [table__pointer]
        mov cl, [type__udf + 3]
        push ds
        mov ax, 0B800h
        mov ds, ax
        mov [bx], cx
        pop ax
        mov ds, ax

type__out:
        add [table__pointer], 54h
        xor ebx, ebx
        mov ebx, esi
        cmp ebx, 0
        je terminate
        jne card__map__read__start

terminate:
        hlt

welcome__message db 'Welcome to $MDBoot <21.04.2021>'
welcome__message__len=$-welcome__message

floppy__msg db "Floppy Drive: installed"
floppy__msg__len=$-floppy__msg

no__floppy__msg db "Floppy Drive: not installed"
no__floppy__msg__len=$-no__floppy__msg

coprocessor__msg db "Math Coprocessor: installed"
coprocessor__msg__len=$-coprocessor__msg

no__coprocessor__msg db "Math Coprocessor: installed"
no__coprocessor__msg__len=$-no__coprocessor__msg

ram__size__msg db "RAM (KBytes): "
ram__size__msg__len=$-ram__size__msg

video__mode__msg db "Video Mode: "
video__mode__msg__len=$-video__mode__msg

mode__40x25__color__msg db "40x25 Color"
mode__40x25__color__msg__len=$-mode__40x25__color__msg

mode__80x25__color__msg db "80x25 Color"
mode__80x25__color__msg__len=$-mode__80x25__color__msg

mode__80x25__mono__msg db "80x25 Mono"
mode__80x25__mono__msg__len=$-mode__80x25__mono__msg

number__of__floppy__msg db "Number of Floppy Drives: "
number__of__floppy__msg__len=$-number__of__floppy__msg

dma__enable__msg db "DMA: enable"
dma__enable__msg__len=$-dma__enable__msg

dma__disable__msg db "DMA: disable"
dma__disable__msg__len=$-dma__disable__msg

number__of__rs232__cards__msg db "Number os RS-232 Cards: "
number__of__rs232__cards__msg__len=$-number__of__rs232__cards__msg

game__port__enable__msg db "Game Port: enable"
game__port__enable__msg__len=$-game__port__enable__msg

game__port__disable__msg db "Game Port: disable"
game__port__disable__msg__len=$-game__port__disable__msg

internal__modem__installed__msg db "Internal Modem: installed"
internal__modem__installed__msg__len=$-internal__modem__installed__msg

internal__modem__not__installed__msg db "Internal Modem: not installed"
internal__modem__not__installed__msg__len=$-internal__modem__not__installed__msg

number__of__printers__attached__msg db "Number of Printers Attached: "
number__of__printers__attached__msg__len=$-number__of__printers__attached__msg

; MEMORY CARD VARS
buffer db 20 dup(?)
smap__signature dd 0534D4150h
xlat__table db '0123456789ABCDEF'
table__header db "BAH      BAL      LH       LL       Type"
table__header__len=$-table__header
table__pointer dw 820h

type__arm db ' ARM'
type__arm__len=$-type__arm

type__arr db ' ARR'
type__arr__len=$-type__arr

type__udf db ' UDF'
type__udf__len=$-type__udf

; timer
old__offset__08h dw 0
old__segment__08h dw 0
timer__value dw 0
timer__value__string db 6 dup(?)

; keyboard
old__offset__09h dw 0
old__segment__09h dw 0