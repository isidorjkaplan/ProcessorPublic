.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000
.define SW_ADDRESS  0x3000
.define VGA_ADDRESS 0x4000

.define MAX_X 160
.define MAX_Y 120
.define COLOR 0x3
.define WIDTH 2
.define X0 25
.define Y0 50

START:
    mvt sp, #0x0100 //Set the stack pointer
    bl CLEAR_SCREEN


    mv r1, #0b00 //Stores dx and dy as +- 1
    
    mv r0, #Y0
    lsl r0, #8
    add r0, #X0

LOOP:
    bl UPDATE_BOX

    push r1
    mv r1, #0x0
    mv r3, #WIDTH
    add r3, #1
    bl DRAW_BOX

    mv r1, #COLOR
    mv r3, #WIDTH
    bl DRAW_BOX
    pop r1

    //bl DELAY
    b LOOP

//r0 = [x,y], r1 = colour, r3 = width
DRAW_BOX:
    push r0
    push r2
    push r3
    push r4
    push r6
    //bl POLL 
    mvt r2, #VGA_ADDRESS

    mv r4, r3
    lsl r3, #8 //shift into position
    add r3, r4 //Put x delta

    push r0 //Save a copy of r0 to use
    sub r0, r3 //Move to lower corner
    st r0, [r2] //Store left corner
    pop r0 //Get back to the centre

    add r0, r3 //Move to upper corner
    add r2, #1
    st r0, [r2] //Store top right corner
    
    add r2, #1 //Increment counter
    st r1, [r2] //Write the colour and also start drawing

    pop r6
    pop r4
    pop r3
    pop r2
    pop r0
    mv pc, lr

POLL:
    push r0
    push r1
    mvt r1, #VGA_ADDRESS
POLL_LOOP:
    ld r0, [r1] //Read to check if it is done drawing
    cmp r0, #0
    beq POLL_LOOP //While DONE=0 it is still drawing, once it is done then DONE=1 gets set and we move on 
    
    pop r1
    pop r0
    mv pc, lr

//r0 = [x,y], r1 = [dy, dx]
UPDATE_BOX:
    push r2
    push r3
    push r4
    push r6

    mv r3, r0 //Save position
    mv r4, r1 //Save velocity
UPDATE_X:
    and r0, #0xFF //Fetch only x position
    and r1, #0b01 //Fetch only x velocity
    mv r2, #MAX_X //Put max x into r2
    bl UPDATE_NUM //r0 holds the new value of x and r1 holds new dx

    mvt r2, #0xFF00
    and r3, r2 //Make r3 contain only the y values
    add r3, r0 //Put x value into r3 properly

    and r4, #2 //Turn off the x bit in deltas [dy,dx]
    add r4, r1 //Update the delta in r4 for dx

    //b DONE_UPDATE
UPDATE_Y:
    mv r0, r3 //Put position into r0
    mv r1, r4 //Put velocity into r1

    mvt r2, #0xFF00 
    and r0, r2 //Filter out x component from position
    lsr r0, #8 //Put y value into base of register, now it is just a normal number instead of being shifted

    and r1, #2 //Filter out so that only y component remains
    lsr r1, #1 //Move the bit into the LSB of delta

    mv r2, #MAX_Y

    bl UPDATE_NUM //Places y into r0 and dy into r1

    and r3, #0xFF //Delete the y values from saved position
    lsl r0, #8 //Put y values into proper position
    add r3, r0 //Place y values into saved position

    and r4, #1 //Delete dy from velocity register
    lsl r1, #1 //Shift velocity bit into proper position
    add r4, r1 //Add y component of velocity back to velocity register
DONE_UPDATE:

    mv r0, r3 //Put position into proper return value
    mv r1, r4 //Put velocity into proper return 

    pop r6
    pop r4
    pop r3
    pop r2
    mv pc, lr


//r0 = value, r1 = delta, r2 = max_val
UPDATE_NUM:
    cmp r0, r2 //Check if r0 has hit max
    bpl SET_DECR //If it has hit max set mode to decrement
    cmp r0, #0 //If it has hit min set mode to increment
    beq SET_INCR //Set mode to increment
    b DONE_UPDATE_INCR //If has not set either then just keep going in the current direction
SET_DECR:
    mv r1, #1
    b DONE_UPDATE_INCR
SET_INCR:
    mv r1, #0
    b DONE_UPDATE_INCR
DONE_UPDATE_INCR:
    cmp r1, #0 //Check current mode against 0
    beq INCR //0 means increment
    bne DECR  //1 means decrement
INCR:
    add r0, #1
    b DONE_UPDATE_NUM
DECR:
    sub r0, #1
    b DONE_UPDATE_NUM
DONE_UPDATE_NUM:
    mv pc, lr



//Subroutine to clear the screen, no registers effected
CLEAR_SCREEN:
    push r0 
    push r1

    mvt r1, #VGA_ADDRESS
    //Move R0 zero to specify the bottom corner for the rectangl
    mv r0, #0
    st r0, [r1]

    //Write into R0 the value of all ones, 
    mvt  r0, #0xFF00
    add  r0, #0xFF
    add r1, #1 //Increment r1 to point to upper register
    st r0, [r1] //Write the upper corner of the screen coordinate for drawing a rectangle

    mv r0, #0x0 //Want all colours off, draw 0
    add r1, #1 //Increment to point to colour bits
    st r0, [r1] //Write, tell it to start drawing

    pop r1
    pop r0
    mv pc, lr
