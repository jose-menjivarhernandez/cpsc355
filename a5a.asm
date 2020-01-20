
	
	.data 
	.balign 8
	
	.global ap_m			//will be using ap instead of sp
ap_m: 	.word 0

	.global bufp_m
bufp_m	.word 0

	.bss
	MAXVAL = 100
	BUFSIZE = 100
	.global val_m

val_m: 	.skip 	MAXVAL*4
	
	.global buf_m
buf_m: 	.skip 	BUFSIZE*4

	.text
	MAXOP = 20
	NUMBER = 0x30
	TOOBIG = 0x39

/* Future macro space */
fp = x29
lr = x30
define(ap_r, x19)
define(base_r, x20)
define(temp_r, x21)
define(temp2_r, x24)
define(addr1_r, x22)
define(addr2_r, x23)

error1:	.string "error: stack full\n"
error2:	.string "error: stack empty\n"
many: 	.string "ungetch: too many characters\n"
	.balign 4

	.global push
push: 	stp	fp, lr, [sp, -16]!
	mov	fp, sp
	
	adrp	addr1_r, val_m
	add	addr1_r, addr1_r, :lo12: val_m
	ldr	base_r, [addr1_r]
	

	adrp	addr2_r, ap_m
	add	addr2_r, addr2_r, :lo12: ap_m
	ldr	ap_r, [addr2_r]
	
	cmp	ap_r, 100
	b.lt	addval
	b	else 

addval:	
 
	str	w0, [base_r, ap_r, sxtw 2]
	add	ap_r, ap_r, 1
	
	b	end1 

else: 	adrp	x0, error1
	add	x0, x0, :lo12: error1
	bl printf
	bl clear
	mov	x0, 0

end1: 	str	ap_r, [addr1_r]
	ldp fp, lr, [sp], 16
	ret 

	.global pop
pop: 	stp	fp, lr, [sp, -16]!
	mov	fp, sp
	
	adrp	addr1_r, val_m
	add	addr1_r, addr1_r, :lo12: val_m
	ldr	base_r, [addr1_r]
	
	adrp	addr2_r, ap_m
	add	addr2_r, addr2_r, :lo12: ap_m
	ldr	ap_r, [addr2_r]
	
	cmp	ap_r, 0
	b.le	else2 
	
	sub	ap_r, ap_r, 1
	
	str	x0, [base_r, ap_r, sxtw 2]
	b	end2
	
else2:	adrp	x0, error2
	add	x0, x0, :lo12: error2
	bl printf
	bl clear
	mov	x0, 0

end2: 	str	ap_r, [addr1_r]
	ldp fp, lr, [sp], 16
	ret 

	.global clear
clear:	stp	fp, lr, [sp, -16]!
	mov	fp, sp

	adrp	addr2_r, ap_m
	add	addr2_r, addr2_r, :lo12: ap_m
	ldr	ap_r, [addr2_r]
	
	mov	ap_r, 0
	str	ap_r, [addr2_r]
	
	ldp fp, lr, [sp], 16
	ret 

getch: 	stp	fp, lr, [sp, -16]!
	mov	fp, sp

	adrp	addr1_r, bufp_m
	add	addr1_r, addr1_r, :lo12: bufp_m
	ldr	ap_r, [addr1_r]
		
	cmp	ap_r, 0
	b.le	else
	
	adrp	addr2_r, buf_m 
	add	addr2_r, addr2_r, :lo12: buf_m
	ldr	base_r, [addr1_r]
	
	sub	ap_r, ap_r, 1
	str	x0, [base_r, ap_r, sxtw 2]
	
	b end3

else: 	bl getchar

end3: 	str	ap_r, [addr1_r]
	ldp fp, lr, [sp], 16
	ret 

ungetch:stp	fp, lr, [sp, -16]!
	mov	fp, sp
	
	adrp	addr1_r, bufp_m
	add	addr1_r, addr1_r, :lo12: bufp_m
	ldr	ap_r, [addr1_r]
	
	cmp	ap_r, 100
	b.le 	else

	adrp	x0, many
	add	x0, x0, :lo12:many
	bl printf
	
	b end4
	
else:	adrp	addr2_r, buf_m 
	add	addr2_r, addr2_r, :lo12: buf_m
	ldr	base_r, [addr2_r]
	
	add	ap_r, ap_r, 1
	str 	x0, [base_r, ap_r, sxtw 2]

end4: 	str	ap_r, [addr2_r]
	ldp fp, lr, [sp], 16
	ret 

int_size = 4
i_s = 16
c_s = i_s +4
s_s= c_s + 8
alloc = -(16 + int_size*4) & -16

getop:	stp	fp, lr, [sp, alloc]!
	mov	fp, sp

	mov 	temp_r, x0
	mov	temp2_r, w1

label:	bl	getch
	str	w0, [fp, c_s]
	ldr	addr1_r, [fp, c_s]
	
	cmp 	w0, ' '
	b.eq	label

	cmp	w0, '\t'
	b.eq	label

	cmp	w0, '\n'
	b.eq	label

	cmp	addr1_r, '0'
	b.lt	if
	cmp	addr1_r, '9'
	b.gt	if
	b	notif

if:	mov	x0, addr1_r
	b 	end5

notif:	str	addr1_r, [temp_r]
	
	
 
