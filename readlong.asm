// Define macros for heavily used registers
define(fd_r, w19)
define(nread_r, x20)
define(buf_base_r, x21)

        // Assembler equates
        buf_size = 8
        alloc = -(16 + buf_size) & -16 
        dealloc = -alloc
        buf_s = 16
        AT_FDCWD = -100

        // Format strings
pn:     .string "test.bin"
fmtl:   .string "Error opening file: %s\nAborting.\n"
head:	.string "ID\t\tLong int\n------------------------\n"
fmt2:   .string "%d\t %ld\n"

        .balign 4

        .global main
main:   stp x29, x30, [sp, alloc]!
        mov x29, sp

        // Open existing binary file
        mov   w0, AT_FDCWD                              // 1st arg (cwd)
        adrp  x1, pn                                            // 2nd arg (pathname)
        add   x1, x1, :lo12:pn
        mov   w2, 0                                             // 3rd arg (read-only)
        mov   w3, 0                                             // 4th arg (not used)
        mov   x8, 56                                            // openat I/O request
        svc   0                                                 // call system function
        mov   fd_r, w0                                          // Record file descriptor

        // Do error checking for openat()
        cmp     fd_r, 0                                         // error check: branch over
        b.ge    openok                                          // if file opened successfully

        adrp    x0, fmtl                                        // error handling code
        add     x0, x0, :lo12:fmtl                              // 1st arg
        adrp    x1, pn                                          // 2nd arg
        add     x1, x1, :lo12:pn
        bl      printf                                          // print error message
        mov     w0, -1                                          // return -1
        b       exit                                            // exit program

openok: add     buf_base_r, x29, buf_s                // calculate buf base pointer

	mov	x22, 1						// ID counter

	adrp    x0, head                    			// Print the columns names
        add     x0, x0, :lo12:head
        bl      printf                      			// Call printf() function

        // Read long ints from  binary  file one buffer at a time in a loop
top:    mov     w0, fd_r                   			// 1st arg (fd)
        mov     x1, buf_base_r            		// 2nd arg (buf)
        mov     w2, buf_size              	// 3rd arg (n)
        mov     x8, 63                     		// read I/O request
        svc     0                          			// call system function
        mov     nread_r, x0              // record # of bytes actually read

        // Do error checking for read()
        cmp      nread_r, buf_size          			// if nread != 8, then
								//if not read properly it might be the end of the file 
        b.ne     end                        			// read failed, exit loop

        // Print out the long int
        adrp    x0, fmt2                    			// 1st arg
        add     x0, x0, :lo12:fmt2
        mov	x1, x22
        ldr     x2, [buf_base_r]            		// 2nd arg (the long int)
        bl      printf                      			// Call printf() function

        add 	x22, x22, 1
        b       top                         			// Go to top of loop

        // Close the binary file
end:    mov     w0, fd_r                    			// 1st arg (fd)
        mov     x8, 57                      			// close I/O request
        svc     0                           			// call system function

        mov     w0, 0                       			// return 0
exit:   ldp     x29, x30, [sp], dealloc
        ret

