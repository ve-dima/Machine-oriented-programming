model  SMALL 
        stack  100h 
 
        dataseg 
AskCont db 0Ah,0Dh 
        db 'Завершить работу ? Esc, продолжить ? Любая клавиша ' 
        db '$' 
Ask     db 0Ah,0Dh,'Введите строку:','$' 
COUNT   db 10 dup( ? ) ; счетчики количества цифр 
CIFR    db '0123456789ABCDEF' ; таблица преобразования 
                            ; шестнадцатеричных цифр для вывода 
INPSTR  db 80, ?, 82 dup( ? ) ; буфер ввода 
OUTSTR  db 0Dh,0Ah, ?, ' ', ?, ?, '$' ; буфер вывода 
 
        codeseg 
        startupcode 
 
BEGIN: 
;Ввод строки 
        lea    DX, Ask 
        mov    AH, 09h 
        int    21h 
        lea    DX, INPSTR 
        mov    AH, 0Ah 
        int    21h 
 
;Обработка 
        xor    AX, AX 
        lea    BX, INPSTR+2  ;адрес начала введенной строки 
        xor    CX, CX 
        mov    CL, INPSTR+1  ;кол-во введенных символов строки 
BB: 
        mov    AL, [BX]      ;очередной символ строки 
        cmp    AL, '0'       ;код символа меньше, чем код нуля ? 
        jb     NC            ;да, т.е. не цифра 
        cmp    AL, '9'       ;код символа больше, чем код девятки ? 
        ja     NC            ;да, т.е. не цифра 
;символ ? десятичная цифра 
        sub    AL, '0'       ;получаем дв. значение цифры, т.е. 
        mov    SI, AX        ; индекс в массиве счетчиков COUNT 
        inc    COUNT[SI]     ;увеличиваем соответств. счетчик 
NC:     inc    BX            ;получить очередной символ строки 
        loop   BB 
 
;Вывод результатов 
        lea    DX, OUTSTR 
        xor    SI, SI        ;Счетчик цифр 
OO:     xor    AX, AX 
        mov    AL, '0' 
        add    AX, SI        ;ASCII-код очередной цифры в SI 
        mov    OUTSTR+2, AL  ; в буфер вывода 
        mov    AL, COUNT[SI] ;AL<-значение счетчика 
                             ; очередной цифры 
        mov    CL, 4         ;получаем 
        shr    AL, CL        ; в DI 
        mov    DI, AX        ; значение старшей шестн. цифры 
        mov    AL, CIFR[DI]  ; счетчика преобразуем в ASCII-код 
        mov    OUTSTR+4, AL  ;пересылаем в буфер вывода 
        mov    AL, COUNT[SI] ;AL<-знач. счетчика очередн. цифры 
        and    AL, 0Fh       ;Получаем в DI значение 
        mov    DI, AX        ; младшей шестн. цифры счетчика 
        mov    AL, CIFR[DI]  ; преобразуем ASCII-код 
        mov    OUTSTR+5, AL  ; пересылаем в буфер вывода 
        mov    AH, 09h       ;Вывод сформированной в буфере 
        int    21h           ; строки 
        inc    SI            ;Счетчик очередной цифры 
        cmp    SI, 10 
        jl     OO 
 
;Запрос на продолжение работы 
        lea    DX, AskCont 
        mov    AH, 09h 
        int    21h 
        mov    AH, 08h 
        int    21h 
        cmp    AL, 27 
        je     QUIT 
        jmp    BEGIN 
 
;Конец работы 
QUIT:   exitcode  0 
end 