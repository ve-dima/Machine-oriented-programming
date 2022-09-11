model SMALL     ; Модель памяти: small
stack 100h      ; Размер стэка: 256 байт
dataseg         ; Определения начало инициализированного сегмента данных
A dw 15          ; Определение переменной A размером 2 байта
B dw 88         ; Определение переменной B размером 2 байта
C dw 32          ; Определение переменной C размером 2 байта
X dw ?          ; Определение переменной X размером 2 байта
codeseg         ; Определение начала кода
startupcode     ; Обеспечивает код инициализации и отмечает начало программы

mov AX, A       ; AX = A
mov BX, B       ; BX = B

sub AX, BX      ; AX = AX - BX

cwd             ; DX:AX расширенный AX
mov BX, 4       ; BX = 4
idiv BX         ; AX = DX:AX / BX, DX = DX:AX mod BX

mov BX, AX      ; BX = AX
mov AX, C       ; AX = C
mov DX, 2       ; DX = 2
imul DX         ; DX:AX = AX * DX

SUB BX, AX      ; BX = BX - AX
ADD BX, 5       ; BX = BX + 5

mov X, BX       ; X = BX

exitcode 0      ; Генерирует код завершения
end