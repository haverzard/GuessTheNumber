%include        'functions.asm'

section .bss
   dif resb 4
   num resb 4

section	.data
    greeting db	'Welcome to the guessing game!',0xa
    lenGreeting equ	$ - greeting
    inputDif db	'Please input the difficulty number: '
    lenInputDif equ	$ - inputDif
    inputGuess db	0xa,'Please input a guess number: '
    lenInputGuess equ	$ - inputGuess
    badDif db	'Please input a positive difficulty!',0xa,0xa
    lenBadDif equ	$ - badDif
    badNumber db	'Please input a number!',0xa,0xa
    lenBadNumber equ	$ - badNumber

section	.text
	global _start

_start:
    ;Print Greeting message
    mov	    edx, lenGreeting
    mov	    ecx, greeting
    mov	    ebx, 1
    mov	    eax, 4
    int	    0x80

_choose_dif:
    ;Print Input message
    mov	    edx, lenInputDif
    mov	    ecx, inputDif
    mov	    ebx, 1
    mov	    eax, 4
    int	    0x80

    ;Read difficulty
    mov	    eax, 3
    mov     ebx, 2
    mov     ecx, dif 
    mov     edx, 5
    int	    0x80

    ;Check difficulty
    mov     eax, dif
    call    atoi            ;eax will be the integer representative and ecx will be the flag
    cmp     ecx, 1
    je      _not_number     ;conversion failed
    cmp     eax, 0
    jle     _bad_dif

    add     eax, 3

_guess:
    dec     eax
    push    eax

    ;Print Input message
    mov	    edx, lenInputGuess
    mov	    ecx, inputGuess
    mov	    ebx, 1
    mov	    eax, 4
    int	    0x80

    ;Read guess
    mov	    eax, 3
    mov     ebx, 2
    mov     ecx, num
    mov     edx, 5
    int	    0x80

    ;Check guess
    mov     eax, num
    call    atoi
    cmp     ecx, 1
    je      _not_number2    ;conversion failed

    ;Output the number entered
    mov     ebx, 1
    call    random
    mov     ecx, eax
    mov     eax, 4
    mov     edx, 5
    int     80h

    pop     eax
    cmp     eax, 0
    jne     _guess

    jmp     _exit

_not_number:
    ;Print Error message
    mov	    edx, lenBadNumber
    mov	    ecx, badNumber
    mov	    ebx, 1
    mov	    eax, 4
    int	    0x80
    jmp     _choose_dif

_not_number2:
    ;Print Error message
    mov	    edx, lenBadNumber
    mov	    ecx, badNumber
    mov	    ebx, 1
    mov	    eax, 4
    int	    0x80
    jmp     _guess

_bad_dif:
    ;Print Error message
    mov	    edx, lenBadDif
    mov	    ecx, badDif
    mov	    ebx, 1
    mov	    eax, 4
    int	    0x80
    jmp     _start

_exit:
    ;Sys_exit
    mov	    eax, 1
    int	    0x80