.data 									//initializing the the data section of storage in low memory	
lim_m:	.double 0r10e-13						//stating the double value of the limit 10e-13
cero_m:	.double 0r0.0							//stating the value 0.0 to be passed as cannot be stated as an immediate
		
.text									//initializing text section of storage in low memory

fp = x29								//equate for the frame pointer
lr = x30								//equare for the link register
							//macro for command argument
							//macro to register holding array of strings in command line
							//register which will hold the file descriptor
								//register which will hold the value of x consistently
							//register that constantly updates with the value of the sum of terms	
							//register holding the value of the changing counter (exponent and denom)
							//register holding the value of the term to be tested with the limit
							//register holding double floating point value of 1 for precision
							//register holding the the value of the fraction (1/i)
							//register consitently holding the value of ((x-1)/x)
							//register which always holds the value of x-1
							//register holding value of the multiplying fraction for the exponent effect

error:	.string "Error opening file. Aborting\n"			//string holding error messege
lnsum:	.string "%.3f\t|  %.10f\n"					//lnsum string to print values of x and ln(x)	
argerr:	.string "Please input the name of the file to be read only\n"	//Error string in case the wrong input in command line is given 
head:	.string "x value\t      Ln(x)\n------------------------\n"	//String for headers	

	AT_FDCWD = -100							//initializing value -100 to read from some file in current directory
	buf_size = 8							//size of buffer to be read in bytes
	alloc= -(16 + buf_size) & -16					//allocating necessary space to stack
	dealloc = -alloc						//-alloc to correctly save stack later
	buf_s = 16							//location of buffer in stack
					
	.balign 4							//aligning everything
	.global main							//making main a globally available

main:	stp	fp, lr, [sp, alloc]!					//initializing stack memory
	mov	fp, sp							//moving stack pointer address to stable frame pointer

	mov	w21, w0						//number of values of in command string array
	mov	x22, x1						//moving array of command line arguments to register

	cmp	w21, 2						//checking whether only to strings have been given in command line
	b.ne	printa							//if not 2 args, go to printa (print argument error)
	
	
	mov	w0, AT_FDCWD						//moving -100 to find file to open in current directory
	ldr	x1, [x22, 8]						//adding name of file from command line to x1 for service call exception
	mov	w2, 0							//neglegible for now
	mov	w3, 0							//neglegible for now
	mov	x8, 56							//adding open value to x9 for service call exception
	svc 	0							//service call exception to open file
	mov	w20, w0						//moving returned value of file descriptir to fd register

	cmp	w20, 0							//checking that fd >=0, else the open was unsuccessful
	b.ge	init							//branching to init if text is succesful
	
	adrp	x0, error						//else, start printing error
	add	x0, x0, :lo12:error					//setting up to print error
	bl	printf 							//calling printf
	mov	w0, -1							//mov -1 to show closing of file
	b	end							//branch to end program

init:	adrp	x0, head						//set up to print headers 	
	add	x0, x0, :lo12:head					//set up to print headers
	bl 	printf							//calling printf function

openg:	adrp	x19, cero_m						//fetching double cero value from data
	add	x19, x19, :lo12: cero_m					//adding address of cero from data to x19
	ldr	d9, [x19]						//putting value in address of 0 into sum to renew sum value every loop
	
	fmov	d14, 1.0						//moving double 1 to one
	fmov	d13, 1.0						//moving 1 to couner i initially
	mov	w0, w20						//moving value of file descriptor  to w0 to read it
	add	x1, x29, buf_s						//pointer to buffer
	mov	x2, buf_size						//read number of bytes in file
	mov	x8, 63							//reading service request
	svc 	0 							//system call exception

	cmp	w0, buf_size						//check that n_read >=0
	b.lt	close							//if less than that, close file

	ldr	d8, [x29, buf_s]					//load value at pointer onto d8 (its a double float)
	fsub	d16, d8, d14					//top = x-1
	fdiv	d15, d16, d8					//infrac = ((x-1)/x)
	fmov	d11, d15					//moving initial frac to term register as it is the first term
	fmov	d17, d15					//moving initial frac onto frac since it will star being exponentiated
	fadd	d9, d9, d11					//adding the term to the sum value
	b	test							//brnaching to test branch

lnloop:	fadd	d13, d13, d14						//adding 1 to i every loop ietration to update divisor and exponent
	fdiv	d12, d14, d13					//div = 1/i
	fmul	d17, d17, d15				//frac = ((x-1)/x)^i * ((x-1)/x)	
	fmul	d11, d12, d17					//term(i) = frac * div
	fadd	d9, d9, d11					//adding the term to the sum value
	b	test							//branching to see if limit for term size has been reached

close: 	mov	w0, w20						//moving file descriptor to w0
	mov	x8, 57							//closing command to x8
	svc 	0							//service call exception
	
end:	ldp	fp, lr, [sp], dealloc					//deallocating stack memory
	ret								//returning to OS

printa:	adrp	x0, argerr						//moving argerr string to be printed
	add	x0, x0, :lo12:argerr					//moving arger string to be printed
	bl	printf							//calling printf
	b	end							//brnaching to end after printing error string

println:
	adrp	x0, lnsum						//moving lnsum string to be printed
	add	x0, x0, :lo12:lnsum					//moving lnsum string to be printed
	fmov	d0, d8							//moving double x value to d0 to be printed
	fmov	d1, d9						//moving sum value to be printed
	bl	printf							//calling printf
	b	openg							//brnaching back to open good to continue getting different values from file

test:	adrp	x19, lim_m						//getting limit value address to be used
	add	x19, x19, :lo12: lim_m					//adding the address of limit value to x19
	ldr	d18, [x19]						//loading the limit value to d8
			
	fabs	d18, d18						//absolute value the limit value	
	fabs	d19, d11						//absolute value the value of current term(i)
	fcmp	d19, d18						//comparing both absolute values
	b.ge	lnloop							//greater than or equal, then send back to adding loop
	b 	println							//else, print the lnsum 
