data segment
    ;mainmenu
    main1 db "Nhom 6"
    main2 db "Trong tro choi nay ban phai an 4 chu cai theo thu tu"
    main3 db "Dau tien la 'n' sau do 'a' sau do 'k' va cuoi cung la 'e'"
    main4 db "Di chuyen con ran bang cach nhan cac phim W,S,D,A"
    main5 db "W:di len"
    main6 db "S:di xuong"
    main7 db "D:sang phai"
    main8 db "A:sang trai"
    main9 db "Dau ran la chu cai 'S' o giua man hinh"
    main10 db "Nhan bat ky phim nao de bat dau..."
    ;bild
    hlths db "Lives:",3,3,3
    ;ingame
    letadd dw 0378h,0DC4h,0CF8h,066Ch,4 Dup(0) ;dia chi tren man hinh cua nhung ki tu co the thu thap 
    dletadd dw 0378h,0DC4h,0CF8h,066Ch,4 Dup(0) ;dia chi ban dau cua cac ki tu tren man hinh sau khi reset game
    letnum db 4 ;so luong cac ki tu co the thu thap
    fin db 4 ;so luong ki tu con lai co the thu thap
    hlth db 6 ;/2 ;so mang con lai
    ;thong tin con ran           
    sadd dw 07D2h,5 Dup(0) ;dia chi cua ki tu dau tien tren man hinh
    snake db 'S',5 Dup(0) ;Day cac ki tu da thu thap duoc
    snakel db 1 ;so luong cac ki tu da thu thap duoc
    ;end 
    gmwin db "THANG"
    gmov db "THUA"
    endtxt db "Bam esc de thoat"
    
ends


stack segment
    dw   128  dup(0)
ends

code segment
start:
    mov ah,1 
    int 21h
    mov ax, data
    mov ds, ax
    
    mov ax,0b800h
    mov es, ax 
    
    cld ;xoa co chi dan
    
    ;an con tro chuot
    mov ah,1
    mov ch,2bh
    mov cl,0bh
    int 10h  
    
    call main_menu
    
    startag:
    
    call bild ;khoi tao cac chu cai va ve khung
    
    xor cl,cl 
    xor dl,dl ;xoa di cac gia tri cu 
    read: ;kiem tra nhap tu ban phim
    mov ah,1
    int 16H
    jz s1
    mov ah,0
    int 16H
    and al,0dfh ;doi chu thuong thanh chu hoa
    mov dl,al
    jmp s1
    
    s1: ;kiem tra neu esc duoc bam
    cmp dl,1bh
    je ext
    
    left:
    cmp dl,'A'
    jne right
    call ml
    mov cl,dl
    jmp read
    
    right:
    cmp dl,'D'
    jne up
    call mr
    mov cl,dl
    jmp read
    
    up:
    cmp dl,'W'
    jne down
    call mu 
    mov cl,dl
    jmp read
    
    down:
    cmp dl,'S'
    jne read1
    call md
    mov cl,dl
    jmp read
    
    read1:
    mov dl,cl
    jmp read
    
    
    ext:
    xor cx,cx
    mov dh,24
    mov dl,79
    mov bh,7
    mov ax,700h
    int 10h
    mov ax, 4c00h ;thoat ve man hinh chinh
    int 21h    
ends 

;main menu
main_menu proc
    call border
    
    mov di,18Ah     ;nap dia chi dich noi can sao chep du lieu
    lea si,main1    ;nap dia chi nguon chua du lieu van ban
    mov cx,6        ;thiet lap so luong byte can sao chep
    lopem1:
    movsb 
    inc di
    loop lopem1     ;sao chep tung byte tu si sang di 
    
    mov di,33Eh
    lea si,main2
    mov cx,52
    lopem2:
    movsb 
    inc di
    loop lopem2
    
    mov di,3DEh
    lea si,main3
    mov cx,57
    lopem3:
    movsb 
    inc di
    loop lopem3
    
    mov di,47Eh
    lea si,main4
    mov cx,49
    lopem4:
    movsb 
    inc di
    loop lopem4
    
    mov di,5dch
    lea si,main5
    mov cx,8
    lopem5:
    movsb 
    inc di
    loop lopem5
    
    mov di,67ch
    lea si,main6
    mov cx,10
    lopem6:
    movsb 
    inc di
    loop lopem6
    
    mov di,71ch
    lea si,main7
    mov cx,11
    lopem7:
    movsb 
    inc di
    loop lopem7
    
    mov di,7bch
    lea si,main8
    mov cx,11
    lopem8:
    movsb 
    inc di
    loop lopem8
    
    
    mov di,0ABEh
    lea si,main9
    mov cx,38
    lopem9:
    movsb 
    inc di
    loop lopem9
    
    mov di,0b5Eh
    lea si,main10
    mov cx,34
    lopem10:
    movsb 
    inc di
    loop lopem10
       
    mov ah,7
    int 21h         ;cho nhap phim bat ky 
    
    call clearall   ;xoa menu sau khi nhap phim

ret
endp 
;Game screen  
bild proc 	;ve khung va dat vi tri cac chu
    ;start point
    call border 
    
    lea si,hlths
    mov di,0
    mov cx,9
    loph:
    movsb 
    inc di
    loop loph       ;hien thi so mang
    
    lea si,main1
    mov di,94h
    mov cx,6
    loph1:
    movsb 
    inc di          ;hien thi main1 goc phai man hinh
    loop loph1   
    
    xor dx,dx       ;xoa thanh ghi dx
    mov di,sadd     ;dia chi dau ran
    mov dl,snake    ;ky tu dau ran
    es: mov [di],dl ;ghi ky tu dau ran vao vi tri sadd 
    ;dat cac chu cai vao man hinh game
    es: mov [0378h],'n'
    es: mov [0DC4h],'a'
    es: mov [0CF8h],'k'
    es: mov [066Ch],'e'
    ret
endp   

;di chuyen ran
;trai
ml proc ;ran sang trai
    push dx 
    call shift_addrs
    sub sadd,2  ;1 cot = 2
    call check_snake_noose  ;kiem tra ran co tu an minh hay khong
    call eat
    
    call move_snake
    pop dx
ret    
endp
;phai
mr proc ;ran sang phai
    push dx 
    call shift_addrs
    add sadd,2  ;1 cot = 2
    call check_snake_noose  ;kiem tra ran co tu an minh hay khong
    call eat
    
    call move_snake 
    
    pop dx
    
ret    
endp
;len
mu proc ;ran di len
    push dx 
    call shift_addrs
    sub sadd,160 ;1 hang = 80 cot = 80 * 2 = 160
    call check_snake_noose ;kiem tra ran co tu an minh hay khong
    call eat
   
    call move_snake
    pop dx
ret    
endp
;xuong
md proc ;ran di xuong
    push dx 
    call shift_addrs
    add sadd,160 ;1 hang = 80 cot = 80 * 2 = 160   
    call check_snake_noose ;kiem tra ran co tu an minh hay khong
    call eat
    
    call move_snake
    pop dx
ret    
endp

shift_addrs proc
    push ax
    xor ch,ch
    xor bh,bh
    mov cl,snakel
    inc cl
    mov al,2
    mul cl
    mov bl,al
    
    xor dx,dx
    
    shiftsnake:
    mov dx,sadd[bx-2]
    mov sadd[bx],dx
    sub bx,2
    loop shiftsnake:
pop ax
ret
endp

;Tong trung nguoi thi  -1 mau
check_snake_noose proc
    push ax    
    push cx 
    xor si, si
    xor dx, dx 
    mov ax, sadd[0h] 
    mov si, 2h  
    mov cl, snakel     
    
   ;so sanh vi tri hien tai cua dau ran voi cac ki tu tiep theo co trong ran
   check_snake_noose_loop:
      cmp ax, sadd[si]  
      jz  snake_noose_game_over
      add si, 2h   
      loop check_snake_noose_loop
    jmp end_check_snake_noose
  
   snake_noose_game_over:
    xor bh,bh
    mov bl,hlth
    es: mov [bx+10],0
    mov hlths[bx+2],0
    sub hlth,2
    cmp hlth,0
    jnz rest_by_noose
    pop cx
    pop ax
    call game_over 
    rest_by_noose: 
    pop cx
    pop ax
    call restart
   
   end_check_snake_noose:
      pop cx 
      pop ax  
      
   ret
   endp

;

eat proc ;kiem tra xem neu ran cham duoc chu cai hay khong va them no vao cuoi con ran
    push ax 
    push cx 
    
    mov di,sadd 
    es: cmp [di],0 
    jz no
    es: cmp [di],20h ;kiem tra neu cham vao khung
    jz wall 
    xor ch,ch
    mov cl,letnum 
    xor si,si
    lop: ;kiem tra dia chi hien tai cua con ran trung voi dia chi cua ki tu cho san
    cmp di,letadd[si]
    jz addf
    add si,2 ; kiem tra voi ki tu cho san tiep theo
    loop lop
    jmp wall
    addf: ; them vao cuoi ran
    mov letadd[si],0 ;xoa dia chi cua ki tu do khoi mang 
    xor bh,bh
    mov bl,snakel
    es: mov dl,[di]
    mov snake[bx],dl
    es: mov [di],0
    add snakel,1 ; tang chieu dai con ran
    sub fin,1  ; giam so luong tu con lai di 1
    cmp fin,0  ;kiem tra da an duoc het cac tu
    jz chkletters
    jmp no
    wall:
    cmp di,320  ;kiem tra neu con ran o tren 2 hang dau
    jbe wallk
    cmp di,3840 ; kiem tra neu con ran o duoi 2 hang cuoi
    jae wallk    
    
    ;kiem tra neu dang o cot dau tien
    mov ax,di
    mov bl,160
    div bl
    cmp ah,0
    jz wallk
    ;  
    
    ;kiem tra neu dang o cot cuoi cung
    mov ax,di
    add ax,2
    mov bl,160
    div bl
    cmp ah,0
    jz wallk 
    ;      
    
    jmp no
    wallk:  ;con ran dam trung tuong
    xor bh,bh
    mov bl,hlth
    es: mov [bx+10],0  ;xoa hinh trai tim tren man hinh
    mov hlths[bx+2],0  ;xoa ki tu trai tim khoi mang
    sub hlth,2 ;giam so luong trai tim
    cmp hlth,0  ;kiem tra neu het so luot choi
    jnz rest  ;reset lai game 
    pop cx
    pop ax
    call game_over ;ket thuc tro choi
    rest: 
    pop cx
    pop ax
    call restart  ;reset lai game
     
    no:
    pop cx
    pop ax
ret
endp 

move_snake proc ;di chuyen con ran
    xor ch,ch
    xor si,si
    xor dl,dl
    mov cl,snakel
    xor bx,bx
    l1mr:
    mov di,sadd[si]
    mov dl,snake[bx]
    es: mov [di],dl
    add si,2
    inc bx
    loop l1mr
    mov di,sadd[si] 
    es:mov [di],0
ret
endp
;ve khung
border proc     
    ;dat man hinh ve che do van ban 
    mov ah,0    ;chon che do hien thi 
    mov al,3    ;che do van ban 80x25
    int 10h
    ;ve khung bang hieu ung truot cua so
    mov ah,6    ;truot cua so len
    mov al,0    ;khong cuon dong nao
    mov bh,0ffh ;thuoc tinh mau
    ;ve dong ngang tren
    mov ch,1
    mov cl,0
    mov dh,1
    mov dl,80
    int 10h
    ;ve cot trai
    mov ch,3
    mov cl,0
    mov dh,24
    mov dl,0
    int 10h
    ;ve dong duoi cung 
    mov ch,24
    mov cl,0
    mov dh,24
    mov dl,79
    int 10h
    ;ve cot phai
    mov ch,1
    mov cl,79
    mov dh,24
    mov dl,79
    int 10h

ret
endp

restart proc
;xoa ran hien thi
    xor ch,ch  
    xor si,si
    mov cl,snakel
    inc cl
    delt: 
    mov di,sadd[si]
    es:mov [di],0
    add si,2
    loop delt
       
    mov fin,4 ; dat lai so luong chu cai can an
    mov sadd,07D2h ; dat lai dia chi ban dau cua sadd

    mov cl,snakel
    inc cl		
    xor si,si
    inc si		;bo qua dau ran
    xor di,di
    add di,2		; bo qua phan tu dau tien trong sadd
    emptsn:
    mov snake[si],0
    mov sadd[di],0
    add di,2
    inc si
    loop emptsn

    mov snakel,1
   
    xor ch,ch
    mov cl,letnum
    xor si,si
    reslet:
    mov bx,dletadd[si]
    mov letadd[si],bx
    add si,2
    add bx,2
    loop reslet      
    xor si,si
    mov snake[si],'S'

    jmp startag

endp

chkletters proc
    call move_snake
    
    cmp snake[1],'n'
    jnz endtestl
    cmp snake[2],'a'
    jnz endtestl   
    cmp snake[3],'k'
    jnz endtestl   
    cmp snake[4],'e'
    jnz endtestl
    call win
    endtestl:
    xor bh,bh
    mov bl,hlth
    es: mov [bx+10],0
    mov hlths[bx+2],0
    sub hlth,2
    cmp hlth,0
    jnz restc
    call game_over 
    restc: 
    call restart
    endp

win proc 
    call clearall
    call border
     
    mov di,7cah     ; vi tri  hien thi
    lea si,gmwin        
    mov cx,5         ; do dai gmwin
    print_win_message:
    mov al,[si]  
    mov ah,02h       ; ma mau xanh
    es:mov [di],ax
    inc si 
    add di,2
    loop print_win_message
    
    mov di,862h     ;vi tri hien thi
    lea si,endtxt       
    mov cx,16     ; do dai
    print_exit:
    mov al, [si]     
    es:mov [di], al  
    inc si          
    add di,2   
    loop print_exit
    
    wait_for_esc:         
    mov ah,7  ; nhap ky tu
    int 21h    ; doc phim
    cmp al,1bh         
    jz ext
    jmp wait_for_esc
    
    ret
    endp

game_over proc
    call clearall
    call border
    
    mov di,7c8h  ; vi tri hien thi
    lea si,gmov
    mov cx,4
    print_game_over:
    mov al,[si]  
    mov ah,04h   ; ma mau do
    es:mov [di],ax
    inc si 
    add di,2
    loop print_game_over
    
    mov di,862h
    lea si,endtxt
    mov cx,16
    print_exit2:
    mov al, [si]     
    es:mov [di], al  
    inc si          
    add di,2        
    loop print_exit2
    
    wait_for_esc2:         
    mov ah,7
    int 21h
    cmp al,1bh         
    jz ext
    jmp wait_for_esc2
    
endp


clearall proc
    
    xor cx,cx
    mov dh,24
    mov dl,79
    mov bh,7  ; chu trang nen den khi xoa
    mov ax,700h 
    int 10h 
    
ret
endp    

    
end start







