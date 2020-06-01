atoi: ;ascii to integer (input from eax)
    ;Preserve all registers
    push    ebx
    push    ecx
    push    edx
    push    esi

    mov     esi, eax
    mov     eax, 0      ; our integer representative
    mov     ebx, 0      ; our pointer

_convert: ;convert bytes per bytes
    xor     ecx, ecx
    mov     cl, [esi+ebx]

    ;Checking if ascii is a number (value 48-57)
    cmp     cl, 48
    jl      _stop
    cmp     cl, 57
    jg      _stop

    ;Converting ascii byte to int
    sub     cl, 48      ; Ascii value 48 is 0 so 48-48 = 0
    add     eax, ecx    ; Add to the sum
    mov     ecx, 10
    mul     ecx         ; Multiply by 10 (X -> X0) so it's ready for next addition

    ;Increase Pointer
    inc     ebx
    jmp     _convert

_stop:
    cmp     cl, 10
    jne     _bad_end

_end:
    mov     ecx, 10
    div     ecx          ; Divide by 10 because it was multiplied by 10 before jump

    ;Restore all registers
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    
    ;Set flag
    mov     ecx, 0
    ret

_bad_end:
    ;Restore all registers
    pop     esi
    pop     edx
    pop     ecx
    pop     ebx
    
    ;Set flag
    mov     ecx, 1
    ret

random:
    ;Preserve all registers
    push    ebx
    push    edx
    push    ecx
    push    esi

    ;Interrupts to get system time
    mov     eax, 13
    int     80h
    mov     eax, 3

    ;Restore all registers
    pop     esi
    pop     ecx
    pop     edx
    pop     ebx
    ret