model SMALL
.486
stack 100h 
dataseg
        diff_sign_txt   db    0Ah, 0Dh, 'Sign not different!$' 
        enter_txt       db    0Ah, 0Dh, 'Enter X: $' 
        eps_enter_txt   db    0Ah, 0Dh, 'Enter eps: $' 
        result_txt      db    0Ah, 0Dh, 'Result: $' 
        err_txt         db    0Ah, 0Dh, 'Err! $' 

        str_max_len     db  40 
        str_len         db  ? 
        str_buf         db  40 dup(?)
        
        s3coef  dw 1
        s2coef  dw -7
        s1coef  dw -9
        s0coef  dw 49
        two     dw 2

        number1 dq      ?
        number2 dq      ?

        number1R dq     ?
        number2R dq     ?

        eps     dq      ?
        result  dq      ?
        haveRes db      ?
codeseg
startupcode 
        finit
        jmp enter_nums
not_diff:
        lea    DX, [diff_sign_txt] 
        mov    AH, 09h 
        int    21h 

enter_nums:
        mov [enter_txt + 8], 'a'
        lea    DX, [enter_txt] 
        mov    AH, 09h 
        int    21h 
        lea    DX, [str_max_len] 
        mov    AH, 0AH 
        int    21h 
        push   offset number1 
        push   offset str_buf
        call   StrToDouble 
        add    SP, 2
        
        mov [enter_txt + 8], 'b'
        lea    DX, [enter_txt] 
        mov    AH, 09h 
        int    21h 
        lea    DX, [str_max_len] 
        mov    AH, 0AH 
        int    21h 
        push   offset number2 
        push   offset str_buf
        call   StrToDouble 
        add    SP, 2
        
        lea    DX, [eps_enter_txt] 
        mov    AH, 09h 
        int    21h 
        lea    DX, [str_max_len] 
        mov    AH, 0AH 
        int    21h 
        push   offset eps
        push   offset str_buf
        call   StrToDouble 
        add    SP, 2
        
        lea BX, [number1r]
        call CalculateFunction PASCAL, number1
        lea BX, [number2r]
        call CalculateFunction PASCAL, number2
        call DoubleSign PASCAL, number1r, number2r
        jz not_diff
        
        call FindRoot PASCAL, number1, number2, eps
        
        cmp [haveRes], 0
        jnz ok
        lea    DX, [err_txt]
        mov    AH, 09h 
        int    21h 
exitcode 0
        ok:
        push   offset str_buf 
        push   offset result 
        call   DoubleToStr 
        add    sp, 2
        lea    DX, [result_txt]
        mov    AH, 09h 
        int    21h 
        lea    DX, [str_buf]
        mov    AH, 09h 
        int    21h 
exitcode 0

;ZF = sigh difference
DoubleSign proc PASCAL @@number1:qword, @@number2:qword
        uses AX
        mov AL, byte ptr [@@number1+7]
        xor AL, byte ptr [@@number2+7]
        test AL, 080h
        ret
DoubleSign endp

FindRoot proc PASCAL
arg @@left:qword, @@right:qword, @@eps:qword
local @@deltaX:qword, @@middle:qword, @@temp1:qword, @@temp2:qword
uses AX, BX

        lea BX, @@temp1
        call CalculateFunction PASCAL, @@left
        lea BX, @@temp2
        call CalculateFunction PASCAL, @@right
        
        call DoubleSign PASCAL, @@temp1, @@temp2
        
@@L0:
        fld     @@right
        fsub    @@left
        fstp    @@deltaX
        jmp     @@L2

@@L4:
        ;deltaX /= 2;
        fld     @@deltaX
        fild     [two]
        fdivp   st(1), st
        fstp    @@deltaX


        ;middle = left + deltaX;
        fld     @@left
        fadd    @@deltaX
        fstp    @@middle


        lea BX, @@temp1
        call CalculateFunction PASCAL, @@left
        lea BX, @@temp2
        call CalculateFunction PASCAL, @@middle

        call DoubleSign PASCAL, @@temp1, @@temp2
        fld     @@middle

        jz     @@L3
        fstp    @@right
        jmp     @@L2    ;to condition
@@L3:
        fstp    @@left
        
        ; if right - left > eps
@@L2:
        fld     @@right
        fsub    @@left
        fld     @@eps
        fcompp
        fwait
        fstsw AX
        sahf
        jb      @@L4
        

@@L1:
        fld @@middle
        fstp result
        mov [haveRes], 1
        ret
@@err:
        mov [haveRes], 0
        ret
FindRoot endp

;return result on BX address
CalculateFunction proc PASCAL
ARG @@x:qword
        fld     @@x
        fild     s3coef
        fmulp   st(1), st
        fmul    @@x
        fmul    @@x
        fld     @@x
        fild     s2coef
        fmulp   st(1), st
        fmul    @@x
        faddp   st(1), st
        fld     @@x
        fild     s1coef
        fmulp   st(1), st
        faddp   st(1), st
        fild     s0coef
        faddp   st(1), st
        fstp qword ptr [BX]
        ret
CalculateFunction endp

DoubleToStr proc  near
        push   BP 
        mov    BP, SP 
        sub    SP, 4               ; выделяем 4 байта в стеке 
        push   ax bx DX cx di 
        pushf 
 
        fnstcw [BP-4]            ; сохраним значение регистра управления 
 
        fnstcw [BP-2] 
 
        and    word ptr [BP - 2], 1111001111111111b; биты 11?10 управление округлением, 11 ? к нулю   
        or     word ptr [BP - 2], 0000110000000000b 
 
        fldcw  [BP - 2]          ; Запись нового значения регистра управления 
 
        mov    bx, [BP + 4] 
 
        fld    qword ptr[bx]     ; заталкиваем в стек сопроцессора число 
 
ftst 
        fstsw  ax 
        and    AH, 1 
        cmp    AH, 1 
        jne    @@NBE 
        mov    bx, [BP + 6] 
        mov    byte ptr[bx], '-' 
        inc    word ptr[BP + 6] 
 
@@NBE:  fabs 
        fst    st(1) 
        fst    st(2) 
        frndint 
        fsub   st(2), st(0) 
 
        mov    word ptr[BP - 2], 10 
        fild   word ptr[BP - 2]    
 
        fxch   st(1) 
        xor    cx, cx 
 
@@BG:   fprem 
        fist   word ptr [BP - 2] 
        push   word ptr [BP - 2] 
 
        fxch   st(2) 
        fdiv   st(0), st(1) 
        frndint 
        fst    st(2) 
 
        inc    cx 
 
        ftst ; сравнить st(0) c 0 
        fstsw  ax                  ; SR -> AX 
        sAHf ; AH вфлаги 
 
        jnz    @@BG    ; если 14 бит SR == 0 (6 бит AH) (если zf == 0 прыжок) 
 
        mov    ax, cx 
        mov    bx, [BP + 6] 
 
@@BFG:  pop    DX 
        add    DX, '0' 
        mov    byte ptr[bx], dl 
        inc    bx 
        loop   @@BFG 
 
        fxch   st(3) 
        fst    st(2) 
 
        ftst 
        fstsw  ax 
        sAHf 
        jz     @@CNE 
 
        mov    byte ptr[bx], '.' 
 
        mov    cx, 16 
 
@@BFR:  fmul   st(0), st(1) 
        fst    st(2) 
        frndint 
        fsub   st(2), st(0) 
        fist   word ptr [BP - 2] 
        fxch   st(2) 
        mov    ax, [BP - 2] 
        add    ax, '0' 
        inc    bx 
        mov    byte ptr[bx], al 
 
        loop   @@BFR         
 
@@NIL:  cmp    byte ptr[bx], '0' 
        jne    @@CNR 
        dec    bx 
        jmp    @@NIL 
@@CNR:  inc    bx 
@@CNE:  mov    byte ptr[bx], '$' 
 
        fstp   st(0) 
        fstp   st(0)
 
        fstp   st(0) 
        fstp   st(0) 
 
        fldcw  [BP - 4]          ; восстановим настройки сопроцессора 
 
popf 
        pop    di cx DX bx ax 
        add    SP, 4 
        pop    BP 
        ret 
DoubleToStr  endp 
 
 
StrToDouble proc  near 
        push   BP 
        mov    BP, SP 
sub    SP, 2                    ; выделяем 2 байта в стеке 
push   ax bx DX cx di 
pushf 
        mov    word ptr[BP - 2], 10      ; помещаем в выделенные 2 байта 10 
        fild   word ptr[BP - 2]          ; заталкиваем в стек сопроцессора 10 
        fldz                             ; заталкиваем в стек сопроцессора 0 
        mov    di, 0  
        mov    bx, [BP + 4]              ; помещаем в bx адрес из стека 
cmp    byte ptr[bx], '-' 
        jne    @@BPN 
        inc    bx 
        mov    di, 1 
@@BPN:  movsx  ax, byte ptr [bx] 
        cmp    ax, '.' 
        je     @@PNT1 
        cmp    ax, 0dh 
        jne    @@CNT 
        fxch   st(1) 
        fstp   st(0) 
        jmp    @@REN 
@@CNT:  sub    ax, '0' 
mov    word ptr[BP - 2], ax 
        fmul   st(0), st(1)             ; умножаем число на вершине стека на 10 
        fiadd  word ptr[BP - 2]    ; добавляем к числу на вершине стека то что было в ax 
inc    bx 
        jmp    @@BPN  
@@PNT1:  
        xor    cx, cx 
@@BEG:  inc    bx 
        movsx  ax, byte ptr [bx] 
        cmp    ax, 0dh 
        je     @@END 
        loop   @@BEG 
@@END:  dec    bx    
        fxch   st(1) 
        fldz 
@@APN:  movsx  ax, [bx]      
        cmp    ax, '.' 
        je     @@PNT2 
        sub    ax, '0' 
        mov    word ptr[BP - 2], ax 
        fiadd  word ptr[BP - 2] 
        fdiv   st(0), st(1) 
        dec    bx 
        jmp    @@APN 
@@PNT2: 
; 
        fxch   st(1)                   ; меняем число 10 и остаток местами 
        fstp   st(0)                   ; выталкиваем 10 
        faddp  st(1)         ; складываем целую и дробную части 
@@REN:   
        cmp    di, 1 
        jne    @@CYK 
        fchs 
@@CYK:  mov    bx, [BP + 6]            ; помещаем в bx адрес из стека 
        fstp   qword ptr [bx]          ; помещаем по адресу из стека число 
popf 
        pop    di cx DX bx ax 
        add    SP, 2 
        pop    BP 
        ret 
StrToDouble  endp

end