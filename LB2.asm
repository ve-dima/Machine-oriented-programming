model SMALL     ; Модель памяти: small
stack 100h      ; Размер стэка: 256 байт

dataseg         ; Определения начало инициализированного сегмента данных

SUM_P   dw      0 
SUM_N   dw      0 
MASS    dw      -10h,10h, -30h,20h, -20h,30h, -30h,30h, -10h,5h
 
codeseg         ; Определение начала кода
startupcode     ; Обеспечивает код инициализации и отмечает начало программы

lea BX, MASS    ; Загрузить адрес MASS в BX
mov CX, 10      ; Установить счетчик 

CCL:
    mov AX, [BX]
    cmp AX, 0

    js NADD
    add SUM_P, AX
    jmp ECCL

    NADD:
    add SUM_N, AX
    
    ECCL:
    add BX, 2   ; Следующий элемент массива
loop CCL        ; Возврат, если счетчик CX не пуст

exitcode  0 
end