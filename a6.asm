.data 									//initializing the the data section of storage in low memory	
lim_m:	.double 0r10e-13						//stating the double value of the limit 10e-13
cero_m:	.double 0r0.0							//stating the value 0.0 to be passed as cannot be stated as an immediate
		
.text									//initializing text section of storage in low memory

fp = x29								//equate for the frame pointer
lr = x30								//equare for the link register
define(argc_r, w21)							//macro for command argument
define(argv_r, x22)							//macro to register holding array of strings in command line
define(fd_r, w20)							//register which will hold the file descriptor
define(x_r, d8)								//register which will hold the value of x consistently
define(sum_r, d9)							//register that constantly updates with the value of the sum of terms	
define(i_r, d13)							//register holding the value of the changing counter (exponent and denom)
define(termi_r, d11)							//register holding the value of the term to be tested with the limit
define(one_r, d14)							//register holding double floating point value of 1 for precision
define(div_r, d12)							//register holding the the value of the fraction (1/i)
define(infrac_r, d15)							//register consitently holding the value of ((x-1)/x)
define(top_r, d16)							//register which always holds the value of x-1
define(frac_r, d17)							//register holding value of the multiplying fraction for the exponent effect

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

	mov	argc_r, w0						//number of values of in command string array
	mov	argv_r, x1						//moving array of command line arguments to register

	cmp	argc_r, 2						//checking whether only to strings have been given in command line
	b.ne	printa							//if not 2 args, go to printa (print argument error)
	
	
	mov	w0, AT_FDCWD						//moving -100 to find file to open in current directory
	ldr	x1, [argv_r, 8]						//adding name of file from command line to x1 for service call exception
	mov	w2, 0							//neglegible for now
	mov	w3, 0							//neglegible for now
	mov	x8, 56							//adding open value to x9 for service call exception
	svc 	0							//service call exception to open file
	mov	fd_r, w0						//moving returned value of file descriptir to fd register

	cmp	fd_r, 0							//checking that fd >=0, else the open was unsuccessful
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
	ldr	sum_r, [x19]						//putting value in address of 0 into sum to renew sum value every loop
	
	fmov	one_r, 1.0						//moving double 1 to one
	fmov	i_r, 1.0						//moving 1 to couner i initially
	mov	w0, fd_r						//moving value of file descriptor  to w0 to read it
	add	x1, x29, buf_s						//pointer to buffer
	mov	x2, buf_size						//read number of bytes in file
	mov	x8, 63							//reading service request
	svc 	0 							//system call exception

	cmp	w0, buf_size						//check that n_read >=0
	b.lt	close							//if less than that, close file

	ldr	x_r, [x29, buf_s]					//load value at pointer onto x_r (its a double float)
	fsub	top_r, x_r, one_r					//top = x-1
	fdiv	infrac_r, top_r, x_r					//infrac = ((x-1)/x)
	fmov	termi_r, infrac_r					//moving initial frac to term register as it is the first term
	fmov	frac_r, infrac_r					//moving initial frac onto frac since it will star being exponentiated
	fadd	sum_r, sum_r, termi_r					//adding the term to the sum value
	b	test							//brnaching to test branch

lnloop:	fadd	i_r, i_r, one_r						//adding 1 to i every loop ietration to update divisor and exponent
	fdiv	div_r, one_r, i_r					//div = 1/i
	fmul	frac_r, frac_r, infrac_r				//frac = ((x-1)/x)^i * ((x-1)/x)	
	fmul	termi_r, div_r, frac_r					//term(i) = frac * div
	fadd	sum_r, sum_r, termi_r					//adding the term to the sum value
	b	test							//branching to see if limit for term size has been reached

close: 	mov	w0, fd_r						//moving file descriptor to w0
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
	fmov	d0, x_r							//moving double x value to d0 to be printed
	fmov	d1, sum_r						//moving sum value to be printed
	bl	printf							//calling printf
	b	openg							//brnaching back to open good to continue getting different values from file

test:	adrp	x19, lim_m						//getting limit value address to be used
	add	x19, x19, :lo12: lim_m					//adding the address of limit value to x19
	ldr	d18, [x19]						//loading the limit value to d8
			
	fabs	d18, d18						//absolute value the limit value	
	fabs	d19, termi_r						//absolute value the value of current term(i)
	fcmp	d19, d18						//comparing both absolute values
	b.ge	lnloop							//greater than or equal, then send back to adding loop
	b 	println							//else, print the lnsum 
