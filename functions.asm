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

time:
    ;Preserve all registers
    push    ebx
    push    edx
    push    ecx
    push    esi

    ;Interrupts to get system time
    mov     eax, 13
    int     80h

    ;Restore all registers
    pop     esi
    pop     ecx
    pop     edx
    pop     ebx
    ret

len: ;Get string length
    ;Preserve ebx
    push    ebx
    mov     ebx, eax

_next:
    cmp     byte [eax], 0    ; If EOL
    jz      _finish_len
    inc     eax
    jmp     _next

_finish_len:
    sub eax, ebx

    ;Restore ebx
    pop     ebx
    ret

print: ;Print string
    ;Preserve all registers
    push    ebx
    push    ecx
    push    edx
    ;Save string
    push    eax

    ;Get string length
    call    len
    mov     edx, eax    ; Length
    pop     eax
    
    ;Sys_write
    mov     ecx, eax    ; String
    mov     ebx, 1
    mov     eax, 4
    int     80h
 
    ;Restore all registers
    pop     edx
    pop     ecx
    pop     ebx
    ret

read:
    ;Preserve all registers
    push    ebx
    push    ecx
    push    edx

    ;Sys_read
    mov     ecx, eax
    mov	    eax, 3
    mov     ebx, 2 
    mov     edx, 5
    int	    0x80

 
    ;Restore all registers
    pop     edx
    pop     ecx
    pop     ebx
    ret

random:
    ;Preserve all registers
    push    ebx
    push    ecx
    push    edx

    mov     edx, eax    ;store old seed
    call    time        ;get time
    add     eax, edx

    ;Mod operation with remainder in div
    mov     ebx, 256 ;change 256 if you want to change the guess' interval
    div     ebx
    mov     eax, edx
    
    ;Restore all registers
    pop     edx
    pop     ecx
    pop     ebx
    ret

iprint:
    ;Preserve all registers
    push    eax
    push    ebx
    push    ecx
    push    edx

    mov     ecx, 0      ;char counters

_loop_convert:    
    inc     ecx

    ;Take n % 10 in edx
    mov     edx, 0
    mov     ebx, 10
    div     ebx

    ;Convert to ascii and push to stack
    add     edx, 48
    push    edx

    ;Nothing to convert (n/10 = 0)
    cmp     eax, 0
    jnz     _loop_convert

    ;Just to make sure next address is empty
    push    0
    pop     eax
 
_loop_print:
    dec     ecx

    ;Print ascii byte per byte
    mov     eax, esp    ;We want a pointer here, so we use esp as a temp string
    call    print
    pop     eax

    cmp     ecx, 0
    jnz     _loop_print
 
    ;Restore all registers
    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    ret