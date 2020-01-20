










intsize = 4
size =  50
size2= size-1
arraysize = intsize*size
alloc = -(16 + arraysize + 32) & -16
dealloc= -alloc 

i_s = 16
j_base_s= i_s + intsize
min_base_s = j_base_s + intsize
temp_base_s = j_base_s + intsize
v_base_s = temp_base_s + intsize

fp	.req x29
lr	.req x30

string1:.string	"v[%d]:	%d\n"
	.balign 4

sorted: .string "v[%d]: %d\n"
	.balign 4
	.global main
	
main: 	stp	fp, lr, [sp, alloc]!
	mov	fp, sp

	mov	w19, 0
	str	w19, [fp, i_s]
	b test1

loop1:	bl rand
	and 	w23, w0, 0xFF
	ldr	w19, [fp, i_s]
	add	x24, fp, v_base_s
	str	w23, [x24, w19, sxtw 2]
		
	adrp	x0, string1
	add	x0, x0, :lo12: string1
	ldr	w1, [fp, i_s]
	ldr	w2, [x24, w19, sxtw 2]
	bl printf
	
	add	w19, w19, 1
	str	w19, [fp, i_s]

test1:	ldr	w19, [fp, i_s]
	cmp   	w19, size
	b.lt	loop1

	mov	w19, 0
	str	w19, [fp, i_s]
	b	testout

oloop:	mov	w21, w19
	str	w21, [fp, min_base_s]
	add 	w20, w19, 1
	str	w20, [fp, j_base_s]
	b	testin

inloop:	ldr	w21, [fp, min_base_s]
	ldr	w26, [x24, w20, sxtw 2]
	ldr 	w25, [x24, w21, sxtw 2]
	
	cmp 	w26, w25
	b.lt	switch
	str	w21, [fp, min_base_s]
	add	w20, w20, 1
	str 	w20, [fp, j_base_s]
	b	testin	
	
switch: mov	w21, w20
	str 	w21, [fp, min_base_s]
	add	w20, w20, 1
	str	w20, [fp, j_base_s]
	
testin:	cmp w20, size
	b.lt	inloop
	
	ldr	w19, [fp,i_s]
	ldr	w21, [fp, min_base_s]
 	ldr 	w22, [x24, w21, sxtw 2]
	ldr 	w25,[x24, w19, sxtw 2]
	str	w25,[x24, w21,sxtw 2]
	str 	w22, [x24, w19, sxtw 2]
	
	add	w19, w19, 1
	str	w19, [fp, i_s]			

testout:ldr	w19, [fp, i_s]
	cmp	w19, size2
	b.lt	oloop

	mov	w19, 0
	str	w19, [fp, i_s]
	b	ptest 

print2:	adrp	x0, sorted
	add	x0, x0, :lo12: sorted
	ldr	w1, [fp, i_s]
	ldr	w2, [x24, w19, sxtw 2]
	bl	printf
	
	add	w19, w19, 1
	str	w19, [fp, i_s]

ptest:	cmp	w19, size
	b.lt 	print2

	ldp	fp, lr, [sp], dealloc
	ret


