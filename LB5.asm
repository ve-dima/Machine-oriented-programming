model SMALL
dataseg

NUM1_MAX_LEN    db 11
NUM1_LEN        db 0
NUM1_STR        db 11 dup(?)
NUM1_BCD        db 5 dup(33)

NUM2_MAX_LEN    db 11
NUM2_LEN        db 0
NUM2_STR        db 11 dup(?)
NUM2_BCD        db 5 dup(33)

ENTER_STR_1     db 0Dh, 0Ah, 'Введите число 1 (не более 10 цифр): $'
ENTER_STR_2     db 0Dh, 0Ah, 'Введите число 2 (не более 10 цифр): $'

ST_OUT_STR      db  0Dh,0Ah, 'Результат: '
ST_OUT_SIGN     db '+'
OUT_STR         db 10 dup(0), 0Dh, 0Ah, '$'


codeseg
startupcode
mov AX, @DATA
mov ES, AX
mov DS, AX
mov CX, 0
std

E1:
mov CX, 5
lea DI, [NUM1_BCD + 4]
mov AL, 0
rep stosb

lea DX, ENTER_STR_1
mov AH, 09h
int 21h
lea DX, NUM1_MAX_LEN
mov AH, 0Ah
int 21h

mov CL, [NUM1_LEN]
lea DI, [NUM1_STR]

add DI, CX
dec DI
mov AL, ' '
repz scasb
inc DI

mov CX, DI
sub CX, offset [NUM1_STR]
inc CX

mov SI, DI
lea DI, [NUM1_BCD + 4]

mov DX, 0
toBCD1_1:
lodsb
sub AL, '0'
cmp AL, 10
jae E1
test DX, 1
jnz toBCD1_high
mov [DI], AL
jmp toBCD1_check
toBCD1_high:
shl AL, 4
or [DI], AL
dec DI
toBCD1_check:
inc DX
cmp byte ptr [SI], ' '
loopnz toBCD1_1

inc CX
mov DI, SI
mov AL, ' '
repz scasb
jcxz $+4
jmp E1




E2:
mov CX, 5
lea DI, [NUM2_BCD + 4]
mov AL, 0
rep stosb

lea DX, ENTER_STR_2
mov AH, 09h
int 21h
lea DX, NUM2_MAX_LEN
mov AH, 0Ah
int 21h

mov CL, [NUM2_LEN]
lea DI, [NUM2_STR]

add DI, CX
dec DI
mov AL, ' '
repz scasb
inc DI

mov CX, DI
sub CX, offset [NUM2_STR]
inc CX

mov SI, DI
lea DI, [NUM2_BCD + 4]

mov DX, 0
toBCD_2:
lodsb
sub AL, '0'
cmp AL, 10
jae E2
test DX, 1
jnz toBCD2_high
mov [DI], AL
jmp toBCD2_check
toBCD2_high:
shl AL, 4
or [DI], AL
dec DI
toBCD2_check:
inc DX
cmp byte ptr [SI], ' '
loopnz toBCD_2

inc CX
mov DI, SI
mov AL, ' '
repz scasb
jcxz $+4
jmp E2

mov CX, 5
lea SI, NUM1_BCD + 4
lea BX, NUM2_BCD + 4
lea DI, OUT_STR + 9
clc
SSTR:
lodsb
mov AH, [BX]
sbb AL, AH
das
stosb
dec bx
loop SSTR

jnc print
mov ST_OUT_SIGN, '-'
lea SI, OUT_STR + 9
lea DI, OUT_STR + 9
mov CX, 5
toNeg:
lodsb
mov AH, AL
mov AL, 099h
adc AL, 0
sub AL, AH
daa
stosb
loop toNeg

print:
cld
lea SI, OUT_STR + 5
lea DI, OUT_STR
mov CX, 5
toASCII:
lodsb
mov AH, AL
shr AH, 4
and AL, 0Fh
or  AX, 03030h
mov [DI], AH
inc DI
stosb
loop toASCII

lea DX, ST_OUT_STR 
mov AH, 09h 
int 21h

exitcode 0
end