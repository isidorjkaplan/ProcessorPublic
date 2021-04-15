VETOR_TABLE:
    b START //Reset exception
    b IRQ //IRQ Handler Exception

.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000
.define SW_ADDRESS  0x3000
.define VGA_ADDRESS 0x4000
.define TIMER_ADDRESS 0x5000
.define IRQ_ADDRESS 0x6000

START:
    mvt sp, #0x0100

    mvt r4, #IRQ_ADDRESS
    mv r0, #0xFF //Turn on IRQ from all switches
    st r0, [r4] //Setup the interrupt handler.

    mv r0, #1    
    
LOOP:
    bl DELAY
    mvt r4, #HEX_ADDRESS
    mv r3, #HEX_ADDR
    ld r3, [r3]
    add r4, r3 //Add the offset

    st r0, [r4]
    lsl r0, #1
    cmp r0, #0b1000000
    bcs DONE_RESET_VAL
    mv r0, #1
DONE_RESET_VAL:
    mvt r3, #IRQ_ADDRESS
    ld r1, [r3] //Get current interrupt values
    mvt r3, #LED_ADDRESS
    st r1, [r3] //Write them to the LEDs
    b LOOP

//A delay subroutine 
DELAY:
    push r0
    mv r0, #0x3F //Putting initial counter value
DELAY_LOOP:
    cmp r0, #0
    beq DONE_DELAY_LOOP
    sub r0, #1 //decrement
    b DELAY_LOOP
DONE_DELAY_LOOP:
    pop r0
    mv pc, lr



HEX_ADDR: .word 0x0//The hex address

IRQ:
    push r0
    push r1
    push r2
    mvt r1, #IRQ_ADDRESS
    ld r0, [r1] //Get the current exceptions
    add r1, #1 //To clear we write to second register in IRQ
    st r0, [r1] //By writing a 1 to all bits that had an exception we clear the exception from memory. 
    
    mv r1, #HEX_ADDR
    ld r0, [r1]

    mvt r2, #HEX_ADDRESS
    add r2, r0 //Get to the current display
    mv r0, #0 //We want to clear the current displau
    st r0, [r2] //clear current display
    ld r0, [r1] //Put back the offset into r0



    add r0, #1
    cmp r0, #4
    bcs DONE_RESET_COUNTER
    mv r0, #0 //Reset the hex display we are drawing on back to zero
DONE_RESET_COUNTER:
    st r0, [r1]//Store the updated value
    pop r2
    pop r1
    pop r0
    pop r7 //Return from exception    