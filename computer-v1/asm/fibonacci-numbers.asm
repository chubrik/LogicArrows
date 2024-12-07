####################################################################################################
##       Source code for the "Fibonacci Numbers" program for a computer made of logic arrows      ##
##        Исходный код программы "Fibonacci Numbers" для компьютера из логических стрелочек       ##
##                  https://github.com/chubrik/LogicArrows/tree/main/computer-v1                  ##
##                          (с) 2023 Arkadi Chubrik (arkadi@chubrik.org)                          ##
####################################################################################################


        ldi a, 0b10000000
        st a, 0x3F
        inc b
        inc c
        ldi d, 0x3F

loop:   inc d
        inc d
        mov a, b
        add a, c
        mov b, a
        st a, d
        inc d
        inc d
        mov a, c
        add a, b
        mov c, a
        st a, d
        ldi a, 0x53
        xor a, d
        jnz loop

        hlt
