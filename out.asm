
	.section    __TEXT,__cstring,cstring_literals
format:
	.string "%d\n\0"
	.section __TEXT,__text,regular,pure_instructions
	.globl _main
_main:
	push    $0
	push $800
	push $2

	pop %rdi
	pop %rsi
	idivq %rsi, %rdi, %rsi
	push %rsi

	lea format(%rip), %rdi
	pop %rsi
	call _printf
	mov $0, %rdi
	call _exit  