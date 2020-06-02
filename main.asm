%include        'functions.asm'

section .bss
   dif resb 4
   num resb 128

section	.data
    greeting    db	    'Welcome to the guessing game!', 0xa, 0x0
    inputDif    db	    'Please input the difficulty number: ', 0x0
    inputGuess  db	    0xa, 'Please input a guess number (0-256): ', 0x0
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
    push    edx         ;store number counters for end result

_init_randoms: ;repeat for dif_level + 3 times
    ;Get a random number (with seed)
    call    random
    push    eax

    inc     ecx
    cmp     ecx, edx
    jne     _init_randoms
    mov     eax, 0
    
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
    call    atoi_2             ;eax will be the integer representative and ecx will be the flag
    cmp     ecx, 1
    je      _failed     ;conversion failed

    ;Prepare for checking
    mov     ecx, 0
    mov     edi, eax
    mov     esi, esp

_check_guess:
    ;Check the guess
    lea     eax, [esi+ecx*4+4]
    mov     eax, [eax+edx*4]

    ;Comparison
    cmp     eax, [esi+ecx*4+4]
    jl      _greater
    cmp     eax, [esi+ecx*4+4]
    jg      _lower

    ;Preparing to squeeze array (in stack)
    mov     edi, ecx
    push    edx
    
_squeeze:
    ;Moving lower addr elements to upper (Example: Guessed 2 in [1,2,3] -> [1,3] - from low to high address)
    cmp     edi, 0
    jl      _success
    lea     eax, [esi+edi*4]
    mov     edx, [eax]
    mov     [eax+4], edx

    dec edi
    jmp _squeeze

_success:
    pop     edx

    ;Print success
    mov     eax, equal
    call    print

    ;Place stack pointer to higher address to align
    add     esp, 4
    add     esi, 4

    ;Decrease counters
    dec     edx
    dec     ecx

_wrong:
    ;Make sure to iterate all numbers
    inc     ecx
    cmp     ecx, edx
    jl     _check_guess

_end_guess:
    ;Remember to increase number of guesses    
    pop     eax
    inc     eax
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
    pop eax
    call iprint
    mov eax, count3
    call print

    ;Sys_exit
    mov	    eax, 1
    int	    0x80