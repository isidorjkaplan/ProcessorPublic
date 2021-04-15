.define TIMER_ADDRESS 0x5000
.define LED_ADDRESS 0x1000
VECTOR_TABLE:
b START
b END //We did not implement IRQ handling here


START:
    mvt sp, #0x0800
    b MAIN
MAIN:
    mvt r4, #TIMER_ADDRESS
    add r4, #1 //Now for the initial value
    mvt r0, #0x1300    //1s * 5000 cycles/sec = 0x1388
    add r0, #0x88
    st r0, [r4] //Set the initial value

    mvt r4, #TIMER_ADDRESS
    mv r0, #0b11 //Auto-reload but IRQ=0
    st r0, [r4]

    add r4, #2 //Point r4 to the register we write to in order to clear done
    mvt r3, #LED_ADDRESS
    mv r2, #0
LOOP:
    ld r0, [r4] //Read if it is done yet
    //st r0, [r3]
    cmp r0, #0
    beq LOOP //Branch while it is not done (done==0)
    st r0, [r4] //If it is done, write 1 to it in order to reset the done flag
    
    st r2, [r3] //Put counter on LED
    add r2, #1 //Increment counter

    b LOOP

    
END: b END