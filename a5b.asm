// Jose Menjivar, 30022744, Assignment 5 part B, CPSC 355
fp = x29 						//defining the frame pointer as fp
lr = x30						// defining the link register as lr
define(i_r, w19)					//defining w19 as i_r
define(argc_r, w20)					//defining w20 as argc_r
define(argv_r, x21)					//defining x21 as argv_r
define(base_r, x22)					//defining x22 as base_r
define(temp_r, w23)					//defining w23 as temp_r
define(temp2_r, w24)					//defining w24 as temp2_r

	.data						//initializing the data section where we will save read and write data
	.balign 8					//double word aligning data in the data section for usind doublewords in pointer arrays

month_m:.dword	zero,jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec	//array of pointers to data in text
	
suff_m:	.dword	st, nd, rd, th				//array of pointers to data in text
	
	.text
zero:	.string "array filler"				//array filler since the running of the program counts in the array of strings in argv_r
jan: 	.string "January" 				//String January that will be printed later
feb:	.string "February" 				//String February that will be printed later
mar:	.string "March"					//String March that will be printed later
apr:	.string "April"					//String April that will be printed later
may:	.string "May"					//String May that will be printed later
jun: 	.string "June"					//String June that will be printed later
jul:	.string "July"					//String July that will be prinetd later
aug:	.string "August"				//String August that will be printed later
sep:	.string "September"				//String September that will be printed later
oct:	.string "October"				//String October that will be printed later
nov:	.string "November"				//String November that will be printed later
dec:	.string "December"				//String December that will be printed later 

st: 	.string "st"					//String st that will be printed later
nd:	.string "nd"					//String nd that will be printed later
rd:	.string "rd"					//String rd that will be printed later
th:	.string "th"					//String th that will be printed later

fmt:	.string "%s %d%s, %d\n"				//fmt string that willbe used as the basis of the output to console
error: 	.string "usage a5b mm dd yyyy\n"		//Error string in case not 3 strings are inputted 
merror:	.string "invalid month entry, enter a month between one and twelve\n"	//Error string for invalid month
derror:	.string	"invalid day entry, enter a day between one and thirty one\n"	//Error string for invalid day
	.balign 4					//properly aligning text memory
	.global main					//making main the global

alloc = -(16 + 16) & -16				//allocating 16 extra bytes of storage to stack
month_s = 16						//address on stack of month
day_s = month_s + 4					//address of day on stack
year_s = day_s + 4					//address of year on stack
suffind_s = year_s + 4					//address of suffix index on stack

main:	stp	fp, lr, [sp, alloc]!			//initializing stack memory for main
	mov	fp, sp					//initializing stack memory for main

	mov	argc_r, w0				//moving the value on w0 to argc_r, which is the number of arguments on command line
	mov	argv_r, x1				//moving the valeu of x1 to argv_r, the actual array of strings in the command line
	
	cmp	argc_r, 4				//comparing the number of arguments in the command line to 4
	b.ne	printer					//go to printer if it is anything else than 4 (three plus running instruction)
	
	mov	i_r, 1					//moving 1 into i_r, our i or counter register
	ldr	x0, [argv_r, i_r, sxtw 3]		//loading argv[i] to x0 to be used in atoi function
	bl	atoi					//calling atoi function
	
	cmp 	x0, 12					//comparing x0, the first argument in command line to 12
	b.gt	merr					//if it is greater than twelve, go to merr which is month error
	cmp	x0, 0					//compare x0 to 0
	b.le	merr					//if it is less than or equal to 0, branch to merr
	str	x0, [fp, month_s]			//store the value of first argument into month address in stack
	
	add	i_r, i_r, 1				//add 1 to i_r
	ldr	x0, [argv_r, i_r, sxtw 3]		//loading argv[2] onto x0
	bl 	atoi					//calling atoi function with x0
	
	cmp	x0, 31					//comparing x0 to 31
	b.gt	derr					//if x0 is greater than 31, go to day, which is day error
	cmp	x0, 0					//compare x0 to 0
	b.le	derr					//if x0 is less than or equal to 0, branch to derr
	str	x0, [fp, day_s]				//store the value of second argument into day address in stack
	
	add	i_r, i_r, 1				//add 1 to i_r
	ldr	x0, [argv_r, i_r, sxtw 3]		//loading argv[3] onto x0 to call atoi on it
	bl 	atoi					//calling the atoi C function
	str	x0, [fp, year_s]			//storing the valueo of x0 onto year address in stack

	ldr	temp_r, [fp, day_s]			//loading temp_r with day value for general usage

	cmp	temp_r, 1				//compare day value to one
	b.eq	stl					//branch to stl if it equals one
	
	cmp	temp_r, 2				//compare day value to 2
	b.eq	ndl					//branch to ndl if it equals 2
		
	cmp	temp_r, 3				//compare day value to 3
	b.eq	rdl					//branch to rdl if it equals to 3
		
	cmp	temp_r, 21				//compare day value to 21
	b.eq	stl 					//branch to stl if it equals to 21
	
	cmp	temp_r, 22				//compare day value to 22
	b.eq	ndl					//branch to ndl if it equals to 22
	
	cmp	temp_r, 23				//compare day value to 23
	b.eq	rdl					//branch to rdl if it equals 23
		
	cmp	temp_r, 31				//compare day value to 31
	b.eq	stl					//branch to stl if it equals 31

	b	thl					//all other day values would branch to thl

stl:	mov	temp2_r, 0				//mov 0 to temp2_r
	str	temp2_r, [fp, suffind_s]		//store temp2_r onto suffix index space on stack	
	b 	print					//branch to print

ndl:	mov	temp2_r, 1				//mov 1 to temp2_r
	str	temp2_r, [fp, suffind_s]		//store temp2_r onto suffix index address on stack
	b 	print					//branch to print

rdl:	mov	temp2_r, 2				//mov 2 to temp2_r 
	str	temp2_r, [fp, suffind_s]		//store temp2_r onto suffix index address on stack
	b	print					//branch to print
	
thl:	mov	temp2_r, 3				//store 3 to temp2_r
	str	temp2_r, [fp, suffind_s]		//store temp2_r onto suffix index address on stack


print:	adrp	x0, fmt					//fetch fmt string to be used
	add	x0, x0, :lo12:fmt			//add the string fmt onto x0 to be printed
	
	ldr	temp_r, [fp, month_s]			//load the number value of month onto temp_r
	adrp	base_r, month_m				//fetch the month string from moth array
	add	base_r, base_r, :lo12: month_m		//add the month string onto base_r
	ldr	x1, [base_r, temp_r, sxtw 3]		// load x1 register with month[month number value] to be printed
	
	ldr	x2, [fp, day_s]				//load the value of the day to x2 to be printed
	
	ldr	temp_r, [fp, suffind_s]			//load the index value of the suffix to be printed onto temp_r
	adrp	base_r, suff_m				//fetch the suffix array base value
	add	base_r, base_r, :lo12:suff_m		//add the suffix base address to base_r
	ldr	x3, [base_r, temp_r, sxtw 3]		//load x3 reguster with suffix[suffix index] to be printed
	
	ldr	x4, [fp, year_s]			//load the number of the year from stack to x4
	
	bl 	printf					//print
	
	b 	end					//branch to the end
	
printer:adrp	x0, error				//fetch the error string 
	add	x0, x0, :lo12:error			//add the error string to x0 to be printed
	bl	printf					//print
	b 	end					//branch to end

merr:	adrp	x0, merror				//fetch the merr string
	add	x0, x0,:lo12: merror			//add the merr string to x0 to be printed
	bl	printf					//print
	b 	end					//branch to end

derr:	adrp	x0, derror				//fetch the derr string
	add	x0, x0, :lo12:  derror			//add the derr string to x0 to be printed
	bl	printf 					//print

end:	ldp	fp, lr, [sp], -alloc			//deallocate stack memory 
	ret 						//return to OS
