%include        'functions.asm'

section .bss
   dif resb 4
   num resb 128

section	.data
    greeting    db	    'Welcome to the guessing game!', 0xa, 0x0
    inputDif    db	    'Please input the difficulty number: ', 0x0
    inputGuess  db	    0xa, 'Please input [3+difficulty] guess numbers separated with space (0-256): ', 0x0
    badNumber   db	    'Your input is invalid', 0xa, 0xa, 0x0
    greater     db      'Too high!', 0xa, 0x0
    lower       db      'Too low!', 0xa, 0x0
    equal       db      'Correct!', 0xa, 0x0
    count1      db      'You have guessed ', 0x0
    count2      db      ' times to guess ', 0x0
    count3      db      ' numbers', 0xa, 0x0

section	.text
	global _start

_start:
    ;Print Greeting message
    mov	    eax, greeting
    call    print

_choose_dif:
    ;Print Input message
    mov	    eax, inputDif
    call    print

    ;Read difficulty
    mov     eax, dif
    call    read

    ;Check difficulty
    mov     eax, dif
    call    atoi            ;eax will be the integer representative and ecx will be the flag
    cmp     ecx, 1
    je      _not_number     ;conversion failed

    add     eax, 3
    mov     ecx, 0      ;counter
    mov     edx, eax

_init_randoms: ;repeat for dif_level + 3 times
    ;Get a random number (with seed)
    call    random
    push    eax
    call iprint

    inc     ecx
    cmp     ecx, edx
    jne     _init_randoms
    mov     eax, 0

    ;Save stack pointer to random number
    mov     edi, esp
    
    push    edx
    ;Setup space for input array
    sub     esp, edx
    sub     esp, edx
    sub     esp, edx
    sub     esp, edx
    mov     esi, esp ;Store esp to esi
    
_guess:
    ;Store some values
    push    eax

    ;Check if all guesses are done
    cmp     edx, 0
    jz      _exit

    ;Print Input message
    mov	    eax, inputGuess
    call    print

    ;Read guess
    mov     eax, num
    call    read

    ;If input is number
    mov     eax, num
    call    atoi_space
    cmp     ecx, 1
    je      _failed     ;conversion failed

    ;Prepare for checking
    mov     ecx, edx

_check_guess:
    ;Check the guess
    mov     eax, [edi+ecx*4-4] ;Remember edi stores pointer to random numbers
    call iprint
    ;Comparison
    cmp     eax, [esi+ecx*4-4]
    jl      _greater
    cmp     eax, [esi+ecx*4-4]
    jg      _lower

    ;Preparing to squeeze array (in stack)
    push    edx
    push    ebx
    mov     ebx, ecx
    
_squeeze:
    ;Moving lower addr elements to upper (Example: Guessed 2 in [1,2,3] -> [1,3] - from low to high address)
    cmp     ebx, 1
    jl      _success

    ;Update input array
    lea     eax, [esi+ebx*4-8]
    mov     edx, [eax]
    mov     [eax+4], edx
    
    ;Update random numbers array
    lea     eax, [edi+ebx*4-8]
    mov     edx, [eax]
    mov     [eax+4], edx

    dec ebx
    jmp _squeeze

_success:
    ;Restore register values
    pop     ebx
    pop     edx

    ;Print success
    mov     eax, equal
    call    print

    ;Place stack pointer to higher address to align
    add     edi, 4
    add     esi, 4

    ;Decrease counters
    dec     edx

_wrong:
    ;Make sure to iterate all numbers
    dec     ecx
    cmp     ecx, 0
    jnz     _check_guess

_end_guess:
    ;Remember to increase number of guesses
    pop     eax
    inc     eax
    call iprint
    jmp      _guess


_greater:
    ;Print result message
    mov	    eax, greater
    call    print
    jmp     _wrong

_lower:
    ;Print result message
    mov	    eax, lower
    call    print
    jmp     _wrong

_not_number:
    ;Print Error message
    mov	    eax, badNumber
    call    print
    jmp     _choose_dif

_failed:
    ;Print Error message
    mov	    eax, badNumber
    call    print
    jmp     _end_guess

_exit:
    ;Print final result
    mov eax, count1
    call print
    pop eax
    call iprint
    mov eax, count2
    call print
    mov eax, [esi+4]
    call iprint
    mov eax, count3
    call print

    ;Sys_exit
    mov	    eax, 1
    int	    0x80