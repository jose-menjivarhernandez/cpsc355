fmt:	.string	"array[1] is: %d\n array[2] is %d\n"
	.balign 4
	.global main

block = 8
size = block*2
alloc= -(16 + size) & -16
dealloc= alloc
arr1 = 16
arr2 = 24

main: 	stp x29, x30, [sp, alloc]!
	mov x29, sp

	mov x19, 10
	mov x20, 15

	
	ldp x29, x30, [sp], dealloc
	ret 

fucn1:	stp x29, x30, [sp, -16]
	mov x29, sp
	
	add x21, x19, x20
	mov x22, 2
	sdiv x23, x21, x22
	
