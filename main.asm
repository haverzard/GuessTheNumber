%include        'functions.asm'

section .bss
   dif resb 4
   num resb 4

section	.data
    greeting db	'Welcome to the guessing game!', 0xa, 0x0
    inputDif db	'Please input the difficulty number: ', 0x0
    inputGuess db	0xa,'Please input a guess number: ', 0x0
    badDif db	'Please input a positive difficulty!', 0xa, 0xa, 0x0
    badNumber db	'Please input a number!', 0xa, 0xa, 0x0

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
    cmp     eax, 0
    jle     _bad_dif

    add     eax, 3
    mov     ecx, 0

_guess:
    dec     eax
    push    eax

    ;Print Input message
    mov	    eax, inputGuess
    call    print

    ;Read guess
    mov     eax, num
    call    read

    ;Output the number entered
    mov     eax, ecx
    call    random
    mov     ecx, eax

    pop     eax
    cmp     eax, 0
    jne     _guess

    jmp     _exit

_not_number:
    ;Print Error message
    mov	    eax, badNumber
    call    print
    jmp     _choose_dif

_not_number2:
    ;Print Error message
    mov	    eax, badNumber
    call    print
    jmp     _guess

_bad_dif:
    ;Print Error message
    mov	    eax, badDif
    call    print
    jmp     _start

_exit:
    ;Sys_exit
    mov	    eax, 1
    int	    0x80