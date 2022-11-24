model SMALL
dataseg

str_promt_str   db 0Dh, 0Ah, 'Enter string: $'

str_max_len     db  30
str_len         db  ?
str_str         db  30 dup(?)

num_error_str   db 0Dh, 0Ah, 'Error! $'
num_promt_str   db 0Dh, 0Ah, 'Enter num: $'

num_max_len     db  4
num_len         db  ?
num_str         db  4 dup(?)

num             db  ?
ten             db  10

out_str         db  0Dh, 0Ah, '" " $'

flt             dq  04444h

codeseg
startupcode
mov AX, @DATA
mov ES, AX
mov DS, AX

mov BX, 0
mov DX, 0

str_promt:
lea DX, [str_promt_str]
mov AH, 09h
int 21h
mov AH, 0Ah
lea DX, [str_max_len]
int 21h

cmp [str_len], 0
jz str_promt

jmp get_num
error_num:
lea DX, [num_error_str]
mov AH, 09h
int 21h

get_num:
lea DX, [num_promt_str]
mov AH, 09h
int 21h
mov AH, 0Ah
lea DX, [num_max_len]
int 21h

cmp [num_len], 0
jz error_num

lea SI, [num_str]
mov [num], 0

get_digit:
lodsb
cmp AL, 0Dh
jz end_get_num
sub AL, '0'
cmp AL, 10
jnb error_num

mov CL, AL

mov AL, num
mul ten
cmp AH, 0
jnz error_num

add AL, CL
jo error_num

mov num, AL
jmp get_digit

end_get_num:

cmp num, 0
jz error_num

lea DI, [str_str]
mov DH, 0
mov DL, [str_len]

mov BH, 0
mov CX, 255
count_s:
mov BL, CL 
call my_prnt_func PASCAL
cmp AH, num
jnae skip_print
mov [out_str+3], AL
push DX
lea DX, [out_str]
mov AH, 09h
int 21h
pop DX
skip_print:
loop count_s

exitcode 0

my_prnt_func proc PASCAL
uses DI,CX
mov AH, 255
mov AL, BL
mov CX, DX
inc CX
begin:
inc AH
repnz scasb
jcxz $+4
jmp begin
ret
my_prnt_func endp

end