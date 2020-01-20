/*      CPSC 355 Assignment 3
        Cole Thiessen - 30027689
        Leonard Manzara  */

/* Assembly insertion sort on integer array */

            	define(i_r, w19)                     	/* Define i as register w19 */
             	define(j_r, w20)                     	/* Define j as register w20 */
		define(temp_r, w21)                  	/* Define temp as register w21 */
		define(v_base_r, x22) 		     	/* Define array base address as register x22 */			
		define(j_minus1, w28)			/* Define j-1 to access v[j-1] as register w28 */
		define(fp, x29)				/* Define frame pointer as register x29 */
		define(lr, x30)				/* Define link register as register x30 */

sort_str:      	.string "\nSorted Array:\n"		/* String to display sorted array title */

arr_str:     	.string "v[%d]: %d\n"                   /* String to display array index and index element data */

		j_size = 4							// int j is 4 bytes
		i_size = 4							// int i is 4 bytes
		temp_size = 4							// int temp is 4 bytes
		SIZE = 50							// Array has 50 elements
		v_size = SIZE*4							// Array v has 50*4 = 200 bytes		
		alloc = -(16 + i_size + j_size + temp_size + v_size) & -16	// Calculate memory for local variables and array on stack
		dealloc = -alloc 						// Deallocate memory	
		i_s = 16							// i offset is 16 on stack
                j_s = 20							// j offset is  20 on stack 
                temp_s = 24							// temp offset is 24 on stack
		v_s = 28							// array offset is 28 on stack

                .balign 4                                      			// Align Boundaries 

                .global main                                    		// Make main global 
main:           stp     fp, lr, [sp, alloc]!                  			// Allocate memory and store FP and LR
                mov     fp, sp                                 			// FP initialized as address of frame record
		
		mov	i_r, 0							// Initialize i as 0
		str	i_r, [fp, i_s]						// Store i to stack
		add	v_base_r, fp, v_s 					// Calculate array base address
			
		b	init_test						// Branch to loop test

init_v:		bl	rand							// Generate random integer
		and	w2, w0, 0xFF						// Bitwise AND random number and 255, store in x2 to be printed
      		str	w2, [v_base_r, i_r, sxtw 2]				// Store the random number generated to its corresponding index in the array 
		ldr     x0, =arr_str                           			// Address of the string arr 
                ldr     w1, [fp, i_s]	                       			// Move i into the register to be printed 
		bl      printf                                  		// Print i and array element to screen */

		add	i_r, i_r, 1						// Increment i 
		str	i_r, [fp, i_s]						// Store i to stack

init_test:	cmp	i_r, SIZE						// Compare i with array size
		b.lt	init_v							// If i is less than array size, branch to v initialization
		
		mov	i_r, 1							// Move 1 into i register
		str	i_r, [fp, i_s]						// Store i to stack
		b 	outer_test						// Branch to outer loop test

out_loop: 	ldr	temp_r, [v_base_r, i_r, sxtw 2]				// Load temp = v[i]
		str	temp_r, [fp, temp_s]					// Store temp to stack
		mov	j_r, i_r						// Move i into j so j = i to initialize inner loop
		str	j_r, [fp, j_s]						// Store j to stack
		b	in_test							// Branch to inner loop test

in_loop:	ldr	j_minus1, [fp, j_s]					// Load j into j-1 to prepare for decrement
		sub	j_minus1, j_minus1, 1					// Decrement j-1 so it is actually j-1 
		ldr	j_minus1, [v_base_r, j_minus1, sxtw 2]			// Load j-1 = v[j-1] so j-1 is the corresponding array element
		str	j_minus1, [v_base_r, j_r, sxtw 2]			// Store j-1 into j array element so v[j] = v[j-1] in the array
		
		sub	j_r, j_r, 1						// Decrement j
		str	j_r, [fp, j_s]						// Store j to stack

in_test:	cmp	j_r, 0							// Compare j and 0
		b.le	next							// If it is less than or equal, branch to statement following inner loop

		ldr	temp_r, [fp, temp_s] 					// Load temp variable from stack
		ldr	j_minus1, [fp, j_s]  					// Load j into j-1 to prepare for decrement
		sub	j_minus1, j_minus1, 1					// Decrement j-1 so it is actually j-1
		ldr	j_minus1, [v_base_r, j_minus1, sxtw 2]			// Load j-1 = v[j-1] so j-1 is the corresponding array element
		cmp	temp_r, j_minus1 					// Compare temp and v[j-1] 
		b.ge	next							// Branch if temp >= v[j-1] 
		b	in_loop							// Branch to inner loop

next:		str	temp_r, [v_base_r, j_r, sxtw 2] 			// Store v[j] = temp 
		add	i_r, i_r, 1						// Increment i
		str	i_r, [fp, i_s]						// Store i to stack

outer_test:	cmp	i_r, SIZE						// Compare i and size of array
		b.lt	out_loop						// If i is less than size of array, branch to outer loop

print_title:   	ldr     x0, =sort_str                                           // Address of the string to display "Sorted Array:" 
               	bl      printf                                                  // Print "Sorted array:" to screen
		
		mov	i_r, 0							// Move 0 into i register
		str	i_r, [fp, i_s]						// Store i to stack
		b	print_test						// Branch to print test for displaying sorted array

print_sorted:	ldr     x0, =arr_str                           			// Address of the string to display array contents
		ldr	w1, [fp, i_s]						// Move i into register to be printed
		ldr	w2, [v_base_r, i_r, sxtw 2]                            	// Move element data at i into the register to be printed 
		bl      printf                                  		// Print i and element data to screen 

		add	i_r, i_r, 1						// Increment i 	
		str	i_r, [fp, i_s]						// Store i to stack

print_test:	cmp	i_r, SIZE						// Compare i and array size
		b.lt	print_sorted						// Branch to loop to print sorted list
				

		ldp	fp, lr, [sp], dealloc					// Restore LR and FR and deallocate memory from stack 
		ret								// Return from main

