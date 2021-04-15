.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000
.define SW_ADDRESS  0x3000
.define VGA_ADDRESS 0x4000

START:
    mvt sp, #0x0100 //Set the stack pointer
LOOP:
    mvt r4, #SW_ADDRESS
    ld r1, [r4] //Get input

    mvt r4, #LED_ADDRESS
    st r1, [r4] //Display number on output

    mv r0, r1
    bl ONES //Get the number of ones in r0
    bl SEG7_CODE //get bitmask in r0
    mvt r4, #HEX_ADDRESS
    st r0, [r4]

    mv r0, r1
    bl ZEROS
    bl SEG7_CODE
    add r4, #2
    st r0, [r4]

    mv r0, r1
    bl ALTERNATE
    bl SEG7_CODE
    add r4, #2
    st r0, [r4]

    b LOOP

ALTERNATE:
    push r6
    push r1
    push r2

    mv r1, #0xaa
    xor r1, r0 //XOR with alternating binary string

    mv r0, r1
    bl ZEROS //r0 has the zeros value
    mv r2, r0 //store it into r2

    mv r0, r1 //put the input back into r0
    bl ONES //r0 has number of ones

    cmp r2, r0 //Check if ZEROS > ONES
    bcc UPDATE_MAX
    b DONE_ALTERNATE
UPDATE_MAX:
    mv r0, r2
DONE_ALTERNATE:
    pop r2
    pop r1
    pop r6
    mv pc, lr


//Takes input in r0, output in r0, only looks at 1 byte though
ZEROS:
    push r6

    mvn r0, r0
    bl ONES
    pop r6
    mv pc, lr


//Receieves in r0 a value and returns number of ones in r0, only looks at 1 byte
ONES:
    push r1
    push r2

    mvt r1, #0x0100
    add r1, #0xFF

    and r1, r0 //Only look at the lower byte of r0

    mv r0, #0          // R0 will hold the result
LOOPONES: 
    cmp r1, #0          // loop until the data contains no more 1's
    beq ENDONES
    mv r2, r1    
    lsr r2, #1      // perform SHIFT, followed by AND
    and r1, r2      
    add r0, #1          // count the string length so far
    b  LOOPONES
ENDONES:
    pop r2
    pop r1
    mv pc, lr

//Input r0, output bitcode in hex for r0
SEG7_CODE:
    push r0
    push r1
    mv r1, #DATA
    add r1, r0 //Offset
    ld r0, [r1] //Load r2 to get the bitmask
    pop r1
    pop r2
    mv pc, lr

    
// subroutine BLANK
//     This subroutine clears all of the HEX displays
//    input: none
//    returns: nothing
// changes: nothing
BLANK:
    push r0
    push r1
    mv     r0, #0               // used for clearing
    mvt    r1, #HEX_ADDRESS     // point to HEX displays
    st     r0, [r1]             // clear HEX0
    add    r1, #1
    st     r0, [r1]             // clear HEX1
    add    r1, #1
    st     r0, [r1]             // clear HEX2
    add    r1, #1
    st     r0, [r1]             // clear HEX3
    add    r1, #1
    st     r0, [r1]             // clear HEX4
    add    r1, #1
    st     r0, [r1]             // clear HEX5
    pop r1
    pop r0
    mv     pc, lr               // return from subroutine

DATA: //Contains the binary bitmasks for the HEX display
    .word 0b00111111 //0 
    .word 0b00000110 //1
    .word 0b01011011  //2
    .word 0b01001111 //3
    .word 0b01100110//4
    .word 0b01101101 //5
    .word 0b01111101 //6
    .word 0b00000111 //7
    .word 0b01111111 //8
    .word 0b01100111 //9
