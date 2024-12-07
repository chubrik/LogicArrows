####################################################################################################
##          Source code for the "Typewriter" program for a computer made of logic arrows          ##
##           Исходный код программы "Typewriter" для компьютера из логических стрелочек           ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v1                  ##
##                          (с) 2024 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################


        ldi c, 0b01000000
        st c, 0x3F
        ldi b, 0x3E
        ldi d, loop

loop:   ld a, b
        st a, c
        st d, b
        jmp d
