// Jose Alejandro Menjivar, 30022744, CPSC 355
define(i_r, w19)				//defining the register that will momentarily hold the value of i
define(j_r, w20)				//defining the register that will momentarily hold the value of j
define(min_r, w21)				//defining the register that will momentarily hold the value of min
define(temp_r, w22)				//defining the register that will momentarily hold the value of temp
define(v_i, w23)				//defining the register that will hold the value of array v[i], momentarily 
define(v_base_r, x24)				//register which will hold the value of where the base of array v[] is in the stack, all throughout
define(v_min, w25)				//defining the register that will momentarily hold the value of v[min], momentarily
define(v_j, w26)				//defininf the register that will hodl the value of array v[j], momentarily


intsize = 4					//all integers will be composed of 4 bytes
size =  50					//array will contain 50 elements
size2= size-1					//holding the size for which inner loop is constrained
arraysize = intsize*size			//Determining the size of the array, in bytes
alloc = -(16 + arraysize + 16) & -16		//allocating the arraysize amount plus space for additional variables such as j and min
dealloc= -alloc 				//negative alloc to easily disallocate memory at end of program 

i_s = 16					//address of i in stack
j_base_s= i_s + intsize				//address of j in stack
min_base_s = j_base_s + intsize			//address of min in stack
v_base_s = min_base_s + intsize			//address of the first element of the array v[]0 in stack

fp	.req x29				//equate to set the frame pointer as fp
lr	.req x30				//equate to set the link reguster as lr

string1:.string	"v[%d]:	%d\n"			//Output that will hold index and index value of array v[]
	.balign 4				//Aligning the string

title:	.string	"\nSorted Array: \n"		//Output to be printed as title before printing sorted array

sorted: .string "v[%d]: %d\n"			//Output that will hold index and index value of array v[]
	.balign 4				//Aligning the string
	.global main				//Making main global
	
main: 	stp	fp, lr, [sp, alloc]!		//allocating memory and storing fp and lr 
	mov	fp, sp				//frame pointer initialized as address to the frame record

	mov	i_r, 0				//i = 0, initialized
	str	i_r, [fp, i_s]			//storing i to stack
	b test1					//branching to test1

loop1:	bl rand					//generating an alleged random number and storing it in w0
	and 	v_i, w0, 0xFF			//bitwise and between random number and 0xFF
	ldr	i_r, [fp, i_s]			//loading i into register i_r from stack memory
	add	v_base_r, fp, v_base_s		//adding value of v's base address to the v base register to be used
	str	v_i, [v_base_r, i_r, sxtw 2]	//storing the value of v[i] to stack memory (v_base + 4)
		
	adrp	x0, string1			//setting x0 to print string1
	add	x0, x0, :lo12: string1		//adding string1 to x0 to be printed 
	ldr	w1, [fp, i_s]			//loading value of i to w1 from memory
	ldr	w2, [v_base_r, i_r, sxtw 2]	//loading v[i] to w2 from stack memory
	bl printf				//printing
	
	add	i_r, i_r, 1			//adding i= i+1, in order to have a bound function for the loop 
	str	i_r, [fp, i_s]			//storing the value of i to memory

test1:	ldr	i_r, [fp, i_s]			//loading the value of i to register for operational use
	cmp   	i_r, size			//comparing the value of i to the size of the arrya to determine continuation of loop
	b.lt	loop1				//if less than, branching back to loop1

	mov	i_r, 0				//setting i to be 0 for use in next loops to come, after 1st loop
	str	i_r, [fp, i_s]			//storing the value of i onto memory
	b	testout				//branching to testout branch as test for the outer for loop

oloop:	mov	min_r, i_r			//moving the value of i into min, as required
	str	min_r, [fp, min_base_s]		//storing the value of min onto memory, where should be
	add 	j_r, i_r, 1			//initializing j as j= i+1
	str	j_r, [fp, j_base_s]		//storing the value of j onto memory
	b	testin				//branching to the inner test in the inner for loop
	
inloop:	ldr	min_r, [fp, min_base_s]		//loading the value of min onto the register to be used operationally
	ldr	v_j, [v_base_r, j_r, sxtw 2]	//loading v[j] onto reguster in order to be used at if statement test
	ldr 	v_min, [v_base_r, min_r, sxtw 2] //loading v[min] onto register to be used at if statement test
	
	cmp 	v_j, v_min			//comparing v[j] and v[min]
	b.lt	switch				//if v[j] is less than min, then branch to switch
	str	min_r, [fp, min_base_s]		//storing the value of min onto memory
	add	j_r, j_r, 1			//j =j+1, in order for the inner loop to have a bound function
	str 	j_r, [fp, j_base_s]		//storing the value of j onto memory
	b	testin				//branching out to testin, the inner loop test
	
switch: mov	min_r, j_r			//moving value of j into min, min=j
	str 	min_r, [fp, min_base_s]		//storing the value of min onto memory
	add	j_r, j_r, 1			//j = j+1 in order for the inner loop to have a bound function
	str	j_r, [fp, j_base_s]		//storing the value of j onto memory
	
testin:	cmp j_r, size				//comparing the value of j and size
	b.lt	inloop				//if j is less than the size, branch to inloop
	
swap:	ldr	i_r, [fp,i_s]			//loading i into register from memory
	ldr	min_r, [fp, min_base_s]		//loading min into register from memory for operations
 	ldr 	temp_r, [v_base_r, min_r, sxtw 2] //loading v[min] in memory onto temp register
	ldr 	v_min,[v_base_r, i_r, sxtw 2]	//loading v[min] in memory onto vmin register to be used
	str	v_min,[v_base_r, min_r,sxtw 2]	//storing the value of vmin register onto v[min] onto memoty
	str 	temp_r, [v_base_r, i_r, sxtw 2]	//storig the value of temp, which is in a register, to v[min] onto memory
	
	add	i_r, i_r, 1			//adding i = i+1 to have a bound function on the outer loop
	str	i_r, [fp, i_s]			//storing the value of i onto memory

testout:ldr	i_r, [fp, i_s]			//loading the value of i into a register from memory
	cmp	i_r, size2			//comparing the size of r to value of size2 (size -1) for outer test loop
	b.lt	oloop				//if i was less than size2. branching to oloop
	
	mov	i_r, 0				//moving 0 into i register for i to be looped through later on again
	str	i_r, [fp, i_s]			//storing the value of i onto memory
	 
	adrp	x0, title 			//storing the value of title onto x0 to be printed
	add	x0, x0, :lo12: title		//adding title onto x0 to be printed
	bl	printf				//printing items stored for title
	b	ptest				//branching to ptest, which stands for print test

print3:	adrp	x0, sorted			//adding sorted aspects to x0 for later print
	add	x0, x0, :lo12: sorted		//adding sorted onto x0 to be prinet		
	ldr	w1, [fp, i_s]			//loading the value of i onto w1 to be printed as index of array
	ldr	w2, [v_base_r, i_r, sxtw 2]	//loading element in index to printed at sorted
	bl	printf				//printing items stored for sorted
	
	add	i_r, i_r, 1			//adding i = i + 1 to have a bound function on the loop
	str	i_r, [fp, i_s]			//storing the new value of i onto memory

ptest:	cmp	i_r, size			//comparing the value of i to size for the for loop test to print
	b.lt 	print3				//if i is less than size, then branch to print3

	ldp	fp, lr, [sp], dealloc		//deallocating all allocated memory from stack 
	ret					//completing deallocation


