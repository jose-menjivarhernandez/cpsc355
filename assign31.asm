
define(i_r, w19)
define(j_r, w20)
define(min_r, w21)
define(temp_r, w22)
define(v_i, w23)
define(v_base_r, x24)
define(v_min, w25)
define(v_j, w26)


intsize = 4
size =  7
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

	mov	i_r, 0
	str	i_r, [fp, i_s]
	b test1

loop1:	bl rand
	and 	v_i, w0, 0xFF
	ldr	i_r, [fp, i_s]
	add	v_base_r, fp, v_base_s
	str	v_i, [v_base_r, i_r, sxtw 2]
		
	adrp	x0, string1
	add	x0, x0, :lo12: string1
	ldr	w1, [fp, i_s]
	ldr	w2, [v_base_r, i_r, sxtw 2]
	bl printf
	
	add	i_r, i_r, 1
	str	i_r, [fp, i_s]

test1:	ldr	i_r, [fp, i_s]
	cmp   	i_r, size
	b.lt	loop1

	mov	i_r, 0
	str	i_r, [fp, i_s]
	b	testout

oloop:	mov	min_r, i_r
	str	min_r, [fp, min_base_s]
	add 	j_r, i_r, 1
	str	j_r, [fp, j_base_s]
	b	testin

inloop:	ldr	min_r, [fp, min_base_s]
	ldr	v_j, [v_base_r, j_r, sxtw 2]
	ldr 	v_min, [v_base_r, min_r, sxtw 2]
	
	cmp 	v_j, v_min
	b.lt	switch
	str	min_r, [fp, min_base_s]
	add	j_r, j_r, 1
	str 	j_r, [fp, j_base_s]
	b	testin	
	
switch: mov	min_r, j_r
	str 	min_r, [fp, min_base_s]
	add	j_r, j_r, 1
	str	j_r, [fp, j_base_s]
	
testin:	cmp j_r, size
	b.lt	inloop

	ldr	min_r, [fp, min_base_s]
 	ldr 	temp_r, [v_base_r, min_r, sxtw 2]
	str 	v_min,[v_base_r, min_r, sxtw 2]
	mov	v_i, temp_r
	str 	v_i, [v_base_r, i_r, sxtw 2]
	
	add	i_r, i_r, 1
	str	i_r, [fp, i_s]			

testout:cmp	i_r, size2
	b.lt	oloop

	mov	i_r, 0
	str	i_r, [fp, i_s]
	b	ptest 

print2:	adrp	x0, sorted
	add	x0, x0, :lo12: sorted
	ldr	w1, [fp, i_s]
	ldr	w2, [v_base_r, i_r, sxtw 2]
	bl	printf
	
	add	i_r, i_r, 1
	str	i_r, [fp, i_s]

ptest:	cmp	i_r, size
	b.lt 	print2

	ldp	fp, lr, [sp], dealloc
	ret


