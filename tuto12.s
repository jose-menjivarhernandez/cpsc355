fmt: 	.string "The sum of %d, %d, %d, %d, %d, %d, and %d is: "
	.balign 4

fmt2:	.string "%d"
	.balign 4
	.global main
	
main:	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	mov	w1, 10
	mov	w2, 20
	mov 	w3, 30
	mov 	w4, 40
	mov	w5, 50
	mov	w6, 60
	mov	w7, 70
	
	bl sum
	mov	w1, w0
	adrp 	x0, fmt2
	add	x0, x0, :lo12:fmt2 
	bl printf

	mov w0, 0
	ldp	x29, x30, [sp], 16
	ret

sum:	stp	x29, x30, [sp, -16]!
	mov	x29, sp

	mov	w19, 0
	add	w19, w19, w1
	add	w19, w19, w2
	add	w19, w19, w3
	add	w19, w19, w4
	add	w19, w19, w5
	add	w19, w19, w6
	add	w19, w19, w7
	
	adrp	x0, fmt
	add	x0, x0, :lo12:fmt
	bl	printf
	
	mov	w0, w19
	
	ldp	x29, x30, [sp], 16
	ret
	
	

	
