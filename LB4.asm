model SMALL
DATASEG
MIN     dw -10
MAX     dw 5

COUNT   db ?

ENTER_NUM_TEXT  db 0Dh, 0Ah, "Enter new numbers: $"
ERROR_NUM_TEXT  db 0Dh, 0Ah, "Error!$"
COUNT_OUT_TEXT  db 0Dh, 0Ah, "Entered "
COUNT_CNT_TEXT  db ?,?, " nums", 0Dh, 0Ah, '$'
HEX_ALPHABET    db "0123456789ABCDEF"

BUFFER  db  60
ENTERED db  (?)
STRING  db  60 dup (?)

SIGN    db  0
TEN     dw  10
codeseg
startupcode

mov AX, @DATA
mov ES, AX
jmp promt

error:
lea DX, ERROR_NUM_TEXT
mov AH, 09h
int 21h

promt:
lea DX, ENTER_NUM_TEXT
mov AH, 09h
int 21h

lea DX, BUFFER
mov AH, 0Ah
int 21h

lea SI, STRING
mov COUNT, 0

newNumber:
mov BX, 0
mov CX, 0FFh
mov SIGN, 0

skipSpace:
lodsb
cmp AL, ' '
jz skipSpace
cmp AL, 0Dh
jz end_of_laba
dec SI

newDigit:
lodsb

cmp AL, 0Dh
jz compare
cmp AL, ' '
jz compare

cmp AL, '-'
jnz notNeg
inc SIGN
cmp SIGN, 1
ja error
cmp BX, 0
jnz error
jmp newDigit

notNeg:
sub AL, '0'
cmp AL, 10
jnb error

mov CL, AL

mov AX, BX
mul TEN
cmp DX, 0
jnz error

add AX, CX
jo error

mov BX, AX
jmp newDigit

compare:
cmp CL, 0FFh
jz error
cmp SIGN, 1
jnz skipneg
neg BX
skipneg:
cmp BX, MIN
jl skipAdd
cmp BX, MAX
jg skipAdd

add COUNT, 1
skipAdd:
cmp AL, 0Dh
jz end_of_laba
jmp newNumber

end_of_laba:
mov BH, 0

mov BL, COUNT
and BL, 0Fh
mov AL, [HEX_ALPHABET + BX]
mov [COUNT_CNT_TEXT + 1], AL

mov BL, COUNT
shr BL, 4
mov AL, [HEX_ALPHABET + BX]
mov [COUNT_CNT_TEXT + 0], AL

lea DX, COUNT_OUT_TEXT
mov AH, 09h
int 21h

exitcode  0 
end