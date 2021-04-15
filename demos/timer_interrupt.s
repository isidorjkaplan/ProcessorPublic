VECTOR_TABLE:
b START
b IRQ //We did not implement IRQ handling here

.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000
.define TIMER_ADDRESS 0x5000
.define IRQ_ADDRESS 0x6000

START:
    mvt sp, #0x0100
    b MAIN
MAIN:
    bl SETUP_TIMER
    bl SETUP_IRQ
    
    
    mv r3, #COUNTER
LOOP:
    ld r0, [r3] //Get current counter value

    mvt r4, #LED_ADDRESS
    st r0, [r4] //Store current counter on the LED's

    bl REG  
    b LOOP
END: b END

COUNTER:.word 0x1

SETUP_TIMER:
    push r0
    push r4

    mvt r4, #TIMER_ADDRESS
    add r4, #1 //Now for the initial value
    mvt r0, #0x1300    //1s * 5000 cycles/sec = 0x1388
    add r0, #0x88
    st r0, [r4] //Set the initial value

    mvt r4, #TIMER_ADDRESS
    mv r0, #0b11 //Auto-reload and run
    st r0, [r4]

    pop r4
    pop r0
    mv pc, lr

SETUP_IRQ:
    push r0
    push r4

    mvt r4, #IRQ_ADDRESS
    mvt r0, #0xFF00 //Turn on IRQ from all switches
    add r0, #0xFF
    st r0, [r4] //Setup the interrupt handler.

    pop r4
    pop r0
    mv pc, lr

//Note only timer can trigger the IRQ in this setup
IRQ:
    push r0
    push r4

    mvt r4, #TIMER_ADDRESS
    add r4, #2 //Point r4 to the register we write to in order to clear done
    st r4, [r4] //Write anything to the clear register in order to clear the IRQ from the timer

    mvt r4, #IRQ_ADDRESS
    ld r0, [r4] //Get the current exceptions
    add r4, #1 //To clear we write to second register in IRQ
    st r0, [r4] //By writing a 1 to all bits that had an exception we clear the exception from memory.

    mv r4, #COUNTER
    ld r0, [r4] //get counter value
    add r0, #1 //increment counter
    st r0, [r4] //store incremented counter

    //mvt r4, #HEX_ADDRESS
    //st r0, [r4]


    pop r4
    pop r0
    pop r7 //Return from exception


// subroutine that displays register r0 (in hex) on HEX3-0 
REG:   push r1
       push r2
       push r3

       mvt  r2, #HEX_ADDRESS  // point to HEX0

       mv   r3, #0            // used to shift digits
DIGIT: mv   r1, r0            // the register to be displayed
       lsr  r1, r3            // isolate digit
       and  r1, #0xF           // "    "  "  "
       add  r1, #SEG7         // point to the codes
       ld   r1, [r1]          // get the digit code
       st   r1, [r2]
       add  r2, #1            // point to next HEX display
       add  r3, #4            // for shifting to the next digit
       cmp  r3, #16           // done all digits?
       bne  DIGIT
       
       pop  r3
       pop  r2
       pop  r1
       mv   pc, lr

SEG7:  .word 0b00111111       // '0'
       .word 0b00000110       // '1'
       .word 0b01011011       // '2'
       .word 0b01001111       // '3'
       .word 0b01100110       // '4'
       .word 0b01101101       // '5'
       .word 0b01111101       // '6'
       .word 0b00000111       // '7'
       .word 0b01111111       // '8'
       .word 0b01100111       // '9'
       .word 0b01110111       // 'A' 1110111
       .word 0b01111100       // 'b' 1111100
       .word 0b00111001       // 'C' 0111001
       .word 0b01011110       // 'd' 1011110
       .word 0b01111001       // 'E' 1111001
       .word 0b01110001       // 'F' 1110001


