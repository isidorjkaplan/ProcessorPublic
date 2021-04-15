.define LED_ADDRESS 0x1000
.define HEX_ADDRESS 0x2000
.define SW_ADDRESS  0x3000
.define CHAR_VGA_ADDRESS 0x4100

.define END_STRING 0xFF

START:
    mvt sp, #0x0800
    b MAIN

MAIN:
    mv r0, #ALL_CHARS
    mvt r1, #0x2F00
    add r1, #0xF
    mv r2, #0b010
    bl WRITE_STRING


    mv r0, #HELLO_WORLD
    mvt r1, #0x3F00
    add r1, #0xF
    mv r2, #0b100
    bl WRITE_STRING

    mv r0, #STRING2
    mvt r1, #0x4F00
    add r1, #0xF
    mv r2, #0b101
    bl WRITE_STRING


    mv r0, #0x0F
    bl LED_DISPLAY
END_MAIN: b END_MAIN


LED_DISPLAY:
    push r4
    mvt r4, #LED_ADDRESS
    st r0, [r4]
    pop r4
    mv pc, lr

ALL_CHARS:
    .word 0x0 //A
    .word 0x1 //B
    .word 0x2 //C
    .word 0x3 //D
    .word 0x4 //E
    .word 0x5 //F
    .word 0x6 //G
    .word 0x7 //H
    .word 0x8 //I
    .word 0x9 //J
    .word 0xa //K
    .word 0xb //L
    .word 0xc //M
    .word 0xd //N
    .word 0xe //O
    .word 0xf //P
    .word 16 //Q
    .word 17 //R
    .word 18 //S
    .word 19 //T
    .word 20 //U
    .word 21 //V
    .word 22//W
    .word 23//X
    .word 24//Y
    .word 25//Z
    .word 26//space
    .word 27//!
    .word 28//.
    .word 0xFF //END OF STRING

HELLO_WORLD:
    .word 0x7 //H
    .word 0x4 //E
    .word 0xb //L
    .word 0xb //L
    .word 0xe //O
    .word 28//.
    .word 26//space
    .word 22//W
    .word 0xe //O
    .word 17 //R
    .word 0xb //L
    .word 0x3 //D
    .word 27//!
    .word 0xFF //END OF STRING

STRING2:
    .word 22//W
    .word 0x0 //A
    .word 18 //S
    .word 19 //T
    .word 0x4 //E
    .word 26//space
    .word 0xe //O
    .word 0x5 //F
    .word 26//space
    .word 19 //T
    .word 0x8 //I
    .word 0xc //M
    .word 0x4 //E
    .word 27//!
    .word 27//!
    .word 27//!
    .word 0xFF //END OF STRING





//LIBRARY STARTS HERE

//r0 = pointer to start of string
//r1 = position [y,x] to write the first char
//r2 = colour to draw in
WRITE_STRING:
    push r0
    push r3
    push r4
    push r6

    mv r4, r0 //r4 points to address in the string
    mv r3, #END_STRING
STRING_LOOP:
    ld r0, [r4] //Get the character as an offset

    cmp r0, r3 //#0xFF compare to END
    beq END_STRING_LOOP

    bl WRITE_CHAR //draw the character

    add r4, #1 //Increment to next char in the string
    add r1, #5 //Shift 5 pixels to the right for next char
    b STRING_LOOP
END_STRING_LOOP:
    pop r6
    pop r4
    pop r3
    pop r0
    mv pc, lr

//Takes char (as an offset) in r0, displays it to the VGA
//Takes a position in r1 [y,x]
//Colour in r2
WRITE_CHAR:
    push r0
    push r4
    push r6 //lr

    bl POLL //poll
    mvt r4, #CHAR_VGA_ADDRESS
    st r1, [r4] //Put position as 16,16

    add r4, #1 //Move to the data position    
    bl CHAR_CODE
    st r0, [r4] //write the data, should be alternating bits

    add r4, #1 //increment
    st r2, [r4]

    pop r6 //lr
    pop r4
    pop r0
    mv pc, lr


//Input = r0, output = code for writing r0 in r0
CHAR_CODE:
    push r4
    mv r4, #CHARS
    add r4, r0
    ld r0, [r4]
    pop r4
    mv pc, lr

//Wait for char to finish drawing
POLL:
    push r0
    push r1
    mvt r1, #CHAR_VGA_ADDRESS
POLL_LOOP:
    ld r0, [r1] //Read to check if it is done drawing
    cmp r0, #0
    beq POLL_LOOP //While DONE=0 it is still drawing, once it is done then DONE=1 gets set and we move on 
    
    pop r1
    pop r0
    mv pc, lr

CHARS:
    .word 0b0101011101010010 //'A'
    .word 0b0111010101110001 //'b'
    .word 0b0110000100010110 //'C'
    .word 0b0011010101010011 //'D'
    .word 0b0110000101110110
    .word 0b0001011100010111
    .word 0b0111011100010111
    .word 0b0101011101010000
    .word 0b0111001000100111
    .word 0b0010010101000100
    .word 0b0101001101010001
    .word 0b0111000100010001 //L
    .word 0b1001100111111001
    .word 0b1001101111011001
    .word 0b0110100110010110
    .word 0b0001001101010111
    .word 0b1010010101010010
    .word 0b0101001101010011
    .word 0b0111011000010110
    .word 0b0110011001101111
    .word 0b0110100110011001
    .word 0b0010010101010101
    .word 0b1001111110011001
    .word 0b1001011001101001
    .word 0b0100010001110101
    .word 0b1111001001001111
    .word 0                  //space
    .word 0b0001000000010001
    .word 0b0011001100000000

