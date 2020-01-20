/*      CPSC 355 Assignment 3
        Cole Thiessen - 30027689
        Leonard Manzara  */

/* Assembly insertion sort on integer array */

            	                     	/* Define i as register w19 */
             	                     	/* Define j as register w20 */
		                  	/* Define temp as register w21 */
		 		     	/* Define array base address as register x22 */			
					/* Define j-1 to access v[j-1] as register w28 */
						/* Define frame pointer as register x29 */
						/* Define link register as register x30 */

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
main:           stp     x29, x30, [sp, alloc]!                  			// Allocate memory and store FP and LR
                mov     x29, sp                                 			// FP initialized as address of frame record
		
		mov	w19, 0							// Initialize i as 0
		str	w19, [x29, i_s]						// Store i to stack
		add	x22, x29, v_s 					// Calculate array base address
			
		b	init_test						// Branch to loop test

init_v:		bl	rand							// Generate random integer
		and	w2, w0, 0xFF						// Bitwise AND random number and 255, store in x2 to be printed
      		str	w2, [x22, w19, sxtw 2]				// Store the random number generated to its corresponding index in the array 
		ldr     x0, =arr_str                           			// Address of the string arr 
                ldr     w1, [x29, i_s]	                       			// Move i into the register to be printed 
		bl      printf                                  		// Print i and array element to screen */

		add	w19, w19, 1						// Increment i 
		str	w19, [x29, i_s]						// Store i to stack

init_test:	cmp	w19, SIZE						// Compare i with array size
		b.lt	init_v							// If i is less than array size, branch to v initialization
		
		mov	w19, 1							// Move 1 into i register
		str	w19, [x29, i_s]						// Store i to stack
		b 	outer_test						// Branch to outer loop test

out_loop: 	ldr	w21, [x22, w19, sxtw 2]				// Load temp = v[i]
		str	w21, [x29, temp_s]					// Store temp to stack
		mov	w20, w19						// Move i into j so j = i to initialize inner loop
		str	w20, [x29, j_s]						// Store j to stack
		b	in_test							// Branch to inner loop test

in_loop:	ldr	w28, [x29, j_s]					// Load j into j-1 to prepare for decrement
		sub	w28, w28, 1					// Decrement j-1 so it is actually j-1 
		ldr	w28, [x22, w28, sxtw 2]			// Load j-1 = v[j-1] so j-1 is the corresponding array element
		str	w28, [x22, w20, sxtw 2]			// Store j-1 into j array element so v[j] = v[j-1] in the array
		
		sub	w20, w20, 1						// Decrement j
		str	w20, [x29, j_s]						// Store j to stack

in_test:	cmp	w20, 0							// Compare j and 0
		b.le	next							// If it is less than or equal, branch to statement following inner loop

		ldr	w21, [x29, temp_s] 					// Load temp variable from stack
		ldr	w28, [x29, j_s]  					// Load j into j-1 to prepare for decrement
		sub	w28, w28, 1					// Decrement j-1 so it is actually j-1
		ldr	w28, [x22, w28, sxtw 2]			// Load j-1 = v[j-1] so j-1 is the corresponding array element
		cmp	w21, w28 					// Compare temp and v[j-1] 
		b.ge	next							// Branch if temp >= v[j-1] 
		b	in_loop							// Branch to inner loop

next:		str	w21, [x22, w20, sxtw 2] 			// Store v[j] = temp 
		add	w19, w19, 1						// Increment i
		str	w19, [x29, i_s]						// Store i to stack

outer_test:	cmp	w19, SIZE						// Compare i and size of array
		b.lt	out_loop						// If i is less than size of array, branch to outer loop

print_title:   	ldr     x0, =sort_str                                           // Address of the string to display "Sorted Array:" 
               	bl      printf                                                  // Print "Sorted array:" to screen
		
		mov	w19, 0							// Move 0 into i register
		str	w19, [x29, i_s]						// Store i to stack
		b	print_test						// Branch to print test for displaying sorted array

print_sorted:	ldr     x0, =arr_str                           			// Address of the string to display array contents
		ldr	w1, [x29, i_s]						// Move i into register to be printed
		ldr	w2, [x22, w19, sxtw 2]                            	// Move element data at i into the register to be printed 
		bl      printf                                  		// Print i and element data to screen 

		add	w19, w19, 1						// Increment i 	
		str	w19, [x29, i_s]						// Store i to stack

print_test:	cmp	w19, SIZE						// Compare i and array size
		b.lt	print_sorted						// Branch to loop to print sorted list
				

		ldp	x29, x30, [sp], dealloc					// Restore LR and FR and deallocate memory from stack 
		ret								// Return from main

