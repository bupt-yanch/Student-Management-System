data segment
  
enter db 0dh,0ah,'$'
warn db 0dh,0ah,'illegal input',0dh,0ah,'$'    
avgshow db 0dh,0ah,'average grade is :$'
guide1 db 0dh,0ah,'pattern1: grade input.',0dh,0ah,'$'
guide2 db 'pattern2: sort based on id.',0dh,0ah,'$'
guide3 db 'pattern3: sort based on grade',0dh,0ah,'$'
guide4 db 'pattern4: output avgGrade and segmented grade',0dh,0ah,'$'    
guide7 db 'pattern5: output gradedistribution',0dh,0ah,'$'
guide5 db 'pattern6: quit',0dh,0ah,'$'
guide6 db 'please choose a pattern :','$'  

lead1 db 0dh,0ah,'input student name:$'
lead2 db 0dh,0ah,'input student age:$'
lead3 db 0dh,0ah,'input student id:$'                                                                                              
lead4 db 0dh,0ah,'input student grade:$' 

op1 db 0dh,0ah,'student name:$'
op2 db 0dh,0ah,'student age:$'
op3 db 0dh,0ah,'student id:$'                                              
op4 db 0dh,0ah,'student grade:$' 

show1 db 0dh,0ah,0dh,0ah,'fail(under 60):$' 
show2 db 0dh,0ah,'pass(60-70):$' 
show3 db 0dh,0ah,'ok(70-80):$' 
shoW4 db 0dh,0ah,'good(80-90):$' 
show5 db 0dh,0ah,'great(90-100):$'

buffer db 20 
       db ?
       db 20 dup(?)   ;//must define buffer like this, otherwise int 21h(0ch) doesnt work 

studentnum db 0
temp db 0    

fail db 0  
sixtoseven db 0
seventoeight db 0
eighttonine db 0
good db 0

_name db 100 dup(20 dup(?))
age db 100 dup(?)
id dw 100 dup(?)    ;//id range: 0-65535
grade dw 100(?)


data ends   

stack segment stack
    dw 250h dup (?)
stack ends

code segment
    assume ds:data,cs:code    

start:
    mov ax,data
    mov ds,ax   
    
    mov ax,stack
    mov ss,ax
        
rotate:
    call RecCom
    
case1:   
    cmp al,31h
    jne case2  
    
    lea bx,studentnum   
    call insert
    jmp rotate
case2:   
    cmp al,32h  
    jne case3  
    
    call sortID
    jmp rotate
case3:   
    cmp al,33h
    jne case4
    
    call sortGrade
    jmp rotate   
    
case4:  
    cmp al,34h
    jne case5
    
    mov cl,studentnum
    cmp cl,0
    jle rotate 
    xor dl,dl
output:  
    mov temp,dl
    call opname
    call opage
    call opID
    call opGrade
    inc dl
    loop output 
    
    call averageGrade
    jmp rotate   
                  
                 
case5:
    cmp al,35h  
    jne case6
    call countdistribution
    jmp rotate
    
case6:
    cmp al,36h
    jne wrong
    mov ax,4c00h
    int 21h
    
wrong:
    call Warning
    jmp rotate

insert proc near
    push ax 
    push bx
    push cx
    push dx
    push di 


;input name   
    lea dx,lead1
    mov ah,09
    int 21h  
    
    mov ah,0ch
    int 21h
    lea dx,buffer ;     //get string
    mov ah,10 
    int 21h  
   
    ;       // count physics address
    mov al,20       
    mov bl,studentnum 
    mul bl
    lea bx,_name 
    add bx,ax  
    ;       // finish count physics address   bx point to aim address
    
    mov cl,[buffer+1] ; // set counter  buffer+1 stores size of data
    mov di,dx;          //dx stores buffer's address
    add di,2 ;          //di+2 starts data   

;killblank: 
;   mov ch,[di]
;    cmp ch,20h
;    jne gets
;    inc di
;    dec cl
;    jmp killblank
gets:
    mov dh,[di] ;register -> memory can only use bx,bp,si,di
    mov [bx],dh
    inc bx  
    inc di
    loop gets 
    mov ax,'$'
    mov [bx],ax
    mov ax,0dh
    mov [bx+1], ax
    mov ax,0ah
    mov [bx+2], ax

;//input age 
    lea dx,lead2
    mov ah,09
    int 21h
      
    lea dx,buffer
    mov ah,10
    int 21h
    
    xor ax,ax
    mov cl,[buffer+1]
    mov di,dx
    add di,2 
    
getage:
    mov dh,[di] 
    sub dh,30h
    mov ah,0
    mov bl,10
    mul bl 
    add al,dh 
    inc di
    loop getage
    
    lea bx,age  
    mov cl,studentnum   
    mov ch,0
    add bx,cx
    
    mov [bx],al  
    
    
;//input id_number
    lea dx,lead3
    mov ah,09
    int 21h
      
    lea dx,buffer
    mov ah,10
    int 21h 
    
    xor ax,ax
    mov cl,[buffer+1]
    mov di,dx
    add di,2 
    
getIdnum:
    
    mov bx,10
    mul bx
    mov dl,[di] 
    sub dl,30h
    mov dh,0 
    add ax,dx 
    inc di
    loop getIdnum
    
    
    mov cx,ax 
    mov al,studentnum   
    ;mov ah,0
    mov bl,2
    mul bl  
    lea bx,id
    add bx,ax
    
    mov [bx],cx 
    
    ;mov dx,id
    ;mov ah,02
    ;int 21h 


; //    input grade
    lea dx,lead4
    mov ah,09
    int 21h
      
    lea dx,buffer
    mov ah,10
    int 21h 
    
    xor ax,ax  
    xor ch,ch 
    mov cl,[buffer+1]
    mov di,dx
    add di,2 
    
   
    push si; ¼Ä´æÆ÷²»¹»ÓÃ 
    push bp 
    xor bp,bp
getGrade:    
    mov dl,[di]    
    mov dh,0
    mov si,dx 
    cmp dl,2eh 
    je j 
    mov bx,10
    mul bx
    mov dx,si  
    sub dl,30h   
    add ax,dx 
    jmp p 
    
j:  inc bp

p:  inc di
    loop getGrade  
     
    cmp bp,0
    jne go
    mov bx,10
    mul bx
        
go: mov cx,ax 
    mov al,studentnum   
    mov ah,0
    mov bl,2
    mul bl  
    lea bx,grade
    add bx,ax
    
    mov [bx],cx 
    
    mov dl,studentnum
    inc dl
    mov studentnum,dl 
        
    pop bp
    pop si    
    pop di    
    pop dx 
    pop cx 
    pop bx
    pop ax 
    ret
insert endp  


opname proc near
    push ax 
    push bx
    push dx
    push si
    
    mov ah,09   
    lea dx,op1
    int 21h 
    
    lea si,_name
 
    mov al,temp
    mov ah,0
    mov bl,20
    mul bl  
    add si,ax
    mov dx,si
    
    mov ah,09
    int 21h  
    
    pop si
    pop dx
    pop bx
    pop ax  
    ret
opname endp
 
opage proc near 
    
    push ax
    push bx
    push cx
    push dx
    push si
     
    mov ah,09   
    lea dx,op2
    int 21h
    
    lea si,age
    mov al,temp  
    mov ah,0
    add si,ax
       
    mov dl,[si] 
    mov cx,1
    mov bl,10
    age_one:
        mov ah,0
        mov al,dl
        div bl
        push ax
        cmp al,0
        jle age_two
        mov dl,al
        inc cx
        jmp age_one
        
    age_two:
        pop dx
        xchg dh,dl
        add dl,30h
        mov ah,2
        int 21h
        loop age_two 
        
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

opage endp

opID proc near
    push ax
    push bx
    push cx
    push dx
    push si
    
       
    mov ah,09   
    lea dx,op3
    int 21h
     
    lea si,id  
    mov al,temp
    mov ah,0
    mov bl,2
    mul bl
    
    add si,ax 
    mov dx,[si]
    
    mov cx,1
    ;mov bx,10 
    mov ax,dx
    id_one:   
        ;mov ax,dx 
        mov dx,0 
        mov bx,10
        div bx
        push dx 
        ;mov ah,0
        cmp ax,0
        jle id_two
        ;mov dx,ax
        inc cx
        jmp id_one         
    id_two:
        pop dx
        ;xchg dh,dl
        add dl,30h
        mov ah,2
        int 21h
        loop id_two    
            
    pop si
    pop dx
    pop cx
    pop bx
    pop ax  
    ret
opID endp
       
opGrade proc near
    push ax
    push bx
    push cx
    push dx
    push si
       
    mov ah,09   
    lea dx,op4
    int 21h
    
    lea si,grade
    mov al,temp
    mov ah,0
    mov bl,2
    mul bl
    add si,ax
    
    mov dx,[si]
    

    mov cx,1
    mov bx,10 
    mov ax,dx
    grade_one:
        mov dx,0  
        mov bx,10
        div bx
        push dx 
        cmp ax,0
        jle grade_two
        inc cx
        jmp grade_one
        
    grade_two:
        cmp cx,1
        jz grade_three
        pop dx 
        add dl,30h
        mov ah,2
        int 21h
        loop grade_two  
        
    grade_three: 
        mov dx,2eh
        mov ah,2
        int 21h
        pop dx 
        add dl,30h
        int 21h
    
    lea dx,enter
    mov ah,09
    int 21h
       
    pop si
    pop dx
    pop cx 
    pop bx
    pop ax      
    ret
opGrade endp 

Warning proc near
    push ax
    push dx
        
    lea dx,warn
    mov ah,09
    int 21h
    
    pop dx 
    pop ax  
    ret
Warning endp
   
RecCom proc near
    PUSH DX
    
    mov dx,offset guide1
    mov ah,09
    int 21h
    
    mov dx,offset guide2
    int 21h
    
    mov dx,offset guide3
    int 21h
    
    lea dx,guide4
    int 21h    
    
    lea dx,guide7
    int 21h
    
    lea dx,guide5
    int 21h
    
    lea dx,guide6
    int 21h
    
    mov ah,1
    int 21h  
    
    POP DX 
    ret
RecCom endp  


sortID proc near
    push ax
    push bx
    push cx
    push dx
    push si 
    push di
     
    mov cl,studentnum
    
    cmp cl,0
    jle r
    dec cl
lp1:
    mov di,cx
    xor bx,bx
    
lp2:
    mov ax,id[bx]
    cmp ax,id[bx+2]
    jle continue 
    
    xchg ax,id[bx+2]
    mov id[bx],ax
    
    mov ax,grade[bx]
    xchg ax,grade[bx+2]
    mov grade[bx],ax  
    push bx
    
    mov ax,bx
    mov bl,2
    div bl
    mov bx,ax
    mov al,age[bx]
    xchg al,age[bx+1]
    mov age[bx],al 
    
    mov ax,bx
    mov bl,20
    mul bl
    lea bx,_name
    add bx,ax
    lea si,_name
    add si,ax
    add si,20
    
    mov dl,20
cpy:
    mov al,[bx]
    mov ah,[si]
    mov [si],al
    mov [bx],ah
    inc bx
    inc si 
    dec dl
    cmp dl,0
    jne cpy
    
    lea dx,_name
    mov ah,09
    int 21h
     
    pop bx
continue:
    add bx,2
    loop lp2
    mov cx,di
    loop lp1

r:             
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
sortID endp
            
            
sortGrade proc near
    push ax
    push bx
    push cx
    push dx
    push si 
    push di
     
    mov cl,studentnum 
    cmp cl,0
    jle m
    dec cl
lp11:
    mov di,cx
    xor bx,bx
    
lp22:
    mov ax,grade[bx]
    cmp ax,grade[bx+2]
    jle continue1 
    
    xchg ax,grade[bx+2]
    mov grade[bx],ax
    
    mov ax,id[bx]
    xchg ax,id[bx+2]
    mov id[bx],ax  
    push bx
    
    mov ax,bx
    mov bl,2
    div bl
    mov bx,ax
    mov al,age[bx]
    xchg al,age[bx+1]
    mov age[bx],al 
    
    mov ax,bx
    mov bl,20
    mul bl
    lea bx,_name
    add bx,ax
    lea si,_name
    add si,ax
    add si,20
    
    mov dl,20
cpyG:
    mov al,[bx]
    mov ah,[si]
    mov [si],al
    mov [bx],ah
    inc bx
    inc si 
    dec dl
    cmp dl,0
    jne cpyG
    
    lea dx,_name
    mov ah,09
    int 21h
     
    pop bx
continue1:
    add bx,2
    loop lp22
    mov cx,di
    loop lp11
m:             
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
    
sortGrade endp

averageGrade proc near
    push ax
    push bx
    push cx
    push dx
    push si
        
    lea dx,avgshow
    mov ah,09
    int 21h     
    
    mov cl,studentnum 
    xor bx,bx 
    xor ax,ax 
    
lp0:
    mov dx,grade[bx]
    add ax,dx
    add bx,2
    loop lp0    
    
    mov dx,0
    mov bl,studentnum  
    mov bh,0
    div bx     
       
    mov cx,1
    mov bx,10 
    avg_one:
        mov dx,0  
        mov bx,10
        div bx
        push dx 
        cmp ax,0
        jle avg_two
        inc cx
        jmp avg_one
        
    avg_two:
        cmp cx,1
        jz avg_three
        pop dx 
        add dl,30h
        mov ah,2
        int 21h
        loop avg_two  
        
    avg_three: 
        mov dx,2eh
        mov ah,2
        int 21h
        pop dx 
        add dl,30h
        int 21h  
        
    lea dx,enter
    mov ah,09
    int 21h
        
    pop si
    pop dx
    pop cx
    pop bx
    pop ax   
    ret
averageGrade endp   

countdistribution proc near
   push ax
   push dx
   push cx
   push dx  
   push si
   push di
   
     
   mov al,studentnum 
   mov bl,2  
   mul bl
   mov si,ax 
   mov ax,0    
   mov bx,0 
   mov cx,0 
   mov di,0
     
   cmp si,1
   jl e
   
loop1:
    mov dx,grade[bx]
    cmp dx,600
    jl g1
    cmp dx,700
    jl g2
    cmp dx,800
    jl g3
    cmp dx,900
    jl g4
    
    add di,1
    jmp f

g1:
    add ah,1
    jmp f
g2:
    add al,1
    jmp f
g3:
    add ch,1
    jmp f
g4:
    add cl,1
    jmp f
    
f:
    add bx,2
    cmp bx,si
    jne loop1
e:    
   mov fail,ah
   mov sixtoseven,al
   mov seventoeight,ch
   mov eighttonine,cl
   mov ax,di
   mov good,al
   
   call  showdistribution
   pop di  
   pop si
   pop dx
   pop cx
   pop bx
   pop ax 
   ret
countdistribution endp  

showdistribution proc near
    push ax
    push dx
    
    lea dx,show1
    mov ah,09h
    int 21h
    mov dl,fail
    call convertbitodec
    
    lea dx,show2
    mov ah,09h
    int 21h
    mov dl,sixtoseven
    call convertbitodec 
    
    lea dx,show3
    mov ah,09h
    int 21h
    mov dl,seventoeight
    call convertbitodec 
    
    lea dx,show4
    mov ah,09h
    int 21h
    mov dl,eighttonine
    call convertbitodec 
    
    lea dx,show5
    mov ah,09h
    int 21h
    mov dl,good
    call convertbitodec  
    
    lea dx,enter
     mov ah,09h
    int 21h

    pop dx
    pop ax
    ret
showdistribution endp

convertbitodec proc near 
    push ax
    push bx
    push cx
    
    mov dh,0  
    mov bx,10 
    mov ax,dx
    mov cx,1
    p_one:
        mov dx,0  
        mov bx,10
        div bx
        push dx 
        cmp ax,0
        jle p_two
        inc cx
        jmp p_one
    p_two:
        pop dx 
        add dl,30h
        mov ah,2
        int 21h
        loop p_two 
    
    pop cx
    pop bx
    pop ax
    ret     
convertbitodec endp   

terminal:
code ends
    end start
