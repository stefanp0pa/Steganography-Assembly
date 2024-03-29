%include "/home/student/Desktop/Prov/Tema2/iocla-tema2-resurse/include/io.inc"

extern atoi
extern printf
extern exit
extern malloc
extern free

; Functions to read/free/print the image.
; The image is passed in argv[1].
extern read_image
extern free_image
; void print_image(int* image, int width, int height);
extern print_image

; Get image's width and height.
; Store them in img_[width, height] variables.
extern get_image_width
extern get_image_height

section .data
	use_str db "Use with ./tema2 <task_num> [opt_arg1] [opt_arg2]", 10, 0

section .bss
    task:       resd 1
    img:        resd 1
    img_width:  resd 1
    img_height: resd 1
    img_backup: resd 1
    img_dim:    resd 1
    blur_sum:   resd 1
    morse_off:  resd 1
    morse_msg:  resd 1
    rand_msg:   resd 1
    brute_line: resd 1
    brute_key:  resd 1
    lsb_msg:    resd 1
    lsb_msg_len:resd 1
    lsb_start:  resd 1
    lsb_end:    resd 1

section .text
global main
main:
    mov ebp, esp; for correct debugging
    ; Prologue
    ; Do not modify!
    push ebp
    mov ebp, esp

    mov eax, [ebp + 8]
    ;PRINT_UDEC 4,eax
    ;NEWLINE
    cmp eax, 1
    jne not_zero_param

    push use_str
    call printf
    add esp, 4

    push -1
    call exit

not_zero_param:
    ; We read the image. You can thank us later! :)
    ; You have it stored at img variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 4]
    call read_image
    add esp, 4
    mov [img], eax

    ; We saved the image's dimensions in the variables below.
    call get_image_width
    mov [img_width], eax

    call get_image_height
    mov [img_height], eax

    ; Let's get the task number. It will be stored at task variable's address.
    mov eax, [ebp + 12]
    push DWORD[eax + 8]
    call atoi
    add esp, 4
   
    mov [task], eax
    
    
    ; There you go! Have fun! :D
    mov eax, [task]
    cmp eax, 1
    je solve_task1
    cmp eax, 2
    je solve_task2
    cmp eax, 3
    je solve_task3
    cmp eax, 4
    je solve_task4
    cmp eax, 5
    je solve_task5
    cmp eax, 6
    je solve_task6
    jmp done


solve_task1:
    ; TODO Task1
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp,4
    
    xor ecx,ecx
    xor edx,edx
    
    ; in eax se afla salvate atat cheia, cat si linia
    ; fiecare se extrage din eax si se pune ori in cate un alt registru
    mov dx,ax
    push edx
    shr eax,16
    mov cx,ax
    push ecx
    
    push dword[img]
    call print_task1
    add esp,12
    jmp done
    
    
solve_task2:
    push dword[img]
    call bruteforce_singlebyte_xor
    add esp,4
    
    xor ecx,ecx
    xor edx,edx
    
    ; se extrage din eax cheia si linia si se pun in cate un registru
    mov dx,ax
    shr eax,16
    mov cx,ax
    
    
    push edx ; linia
    push ecx ; cheia
    push dword[img] ; adresa catre imaginea decriptata
    call encrypt_msg_task2
    add esp,12    
      
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp,12   
    jmp done


solve_task3:
    ; TODO Task3
    mov eax,[ebp+12]
    mov ecx,[eax+12]
    
    mov eax,[ebp+12]
    push ecx ; save ecx on stack
    push dword[eax+16] ; decode the byte-id
    call atoi ; atoi on byte-ide
    add esp,4
    pop ecx ; restore ecx from stack

    push eax ; arg3 - byte-id
    push ecx ; arg2 - the message
    push dword[img] ; arg1 - the image
    call morse_encrypt
    add esp,12  
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp,12
    
    jmp done
    
    
solve_task4:
    mov eax,[ebp+12]
    mov ebx,[eax+12] ; mesajul
    push dword[eax+16] ; byte-id, dar nu in format numeric
    call atoi
    add esp,4
    
    mov ecx,eax ; byte-id, in format numeric
    push ecx
    push ebx
    push dword[img]
    call lsb_encode
    add esp,12  
    
    push dword[img_height]
    push dword[img_width]
    push dword[img]
    call print_image
    add esp,12    
    jmp done
    
    
solve_task5:
    ; TODO Task5
    mov eax,[ebp+12]
    push dword[eax+12]
    call atoi
    add esp,4
    
    push eax
    push dword[img]
    call lsb_decode
    add esp,8   
    jmp done
    
    
solve_task6:
    push dword[img]
    call blur
    add esp,4
    jmp done

    ; Free the memory allocated for the image.
done:
    push DWORD[img]
    call free_image
    add esp, 4

    ; Epilogue
    ; Do not modify!
    xor eax, eax
    leave
    ret


; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
bruteforce_singlebyte_xor:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; adresa catre imaginea originala
    
    ; se calculeaza dimensiunea imaginii
    mov ecx,[img_height]
    mov edx,[img_width]
    imul ecx,edx
    
    xor esi,esi ; se incepe cu cheia de valoare 0
brute:
     ; se aplica XOR cu cheia curenta pe imagine
    push ecx
    push esi
    push dword[img]
    call xor_img_with_key
    add esp,12   
    
    ; se verifica daca prin decriptare, s-a obtinut revient
    ; se intoarce valoarea liniei daca e gasit
    ; altfel se intoarce -1
    push ecx
    push dword[img]
    call check_for_revient
    add esp,8
    
    ; daca s-a gasit o cheie buna, se iese din bruteforce
    cmp eax,-1
    jnz found_right_key
    
    ; daca nu s-a gasit cheia, se inverseaza operatia de XOR
    push ecx
    push esi
    push dword[img]
    call reverse_xor
    add esp,12
    
    add esi,1
    cmp esi,256
    jl brute
 
found_right_key:
    mov [brute_line],eax
    mov [brute_key],esi
     
    ; se salveaza atat linia mesajului, cat si cheia, in eax
    ; cheia e salvata pe 16 biti, in a doua jumatate a lui eax
    ; linia e salvata tot pe 16 biti, in prima jumatate a lui eax
    xor eax,eax
    xor ecx,ecx    
    mov ecx,[brute_key]
    add eax,ecx
    shl eax,16
    xor ecx,ecx
    mov ecx,[brute_line]
    add eax,ecx
       
    leave
    ret

; ............................................................
reverse_xor:
    push ebp
    mov ebp,esp
    push eax
    push ebx
    push ecx
    push edx
    
    mov eax,[ebp+8] ; adresa catre imaginea originala
    mov ebx,[ebp+12] ; cheia cu care s-a decriptat
    mov ecx,[ebp+16] ; dimensiunea imaginii
r_xor:
    sub ecx,1
    cmp ecx,-1
    jz end_r_xor
    mov edx,[eax+4*ecx]
    xor edx,ebx
    mov [eax+4*ecx],edx
    jmp r_xor
end_r_xor:
    pop edx    
    pop ecx
    pop ebx
    pop eax
    leave
    ret    
            
; ............................................................
print_task1:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; adresa catre imaginea decriptata
    mov ebx,[ebp+12] ; cheia cu care s-a decriptat
    mov edx,[ebp+16] ; linia mesajului
      
    ; se salveaza cheia pt reutilizarea registrului ebx
    push ebx
    ; se afiseaza mesajul secret
    mov ecx,[img_width]
    imul ecx,edx    
print_mesg_task1:
    mov ebx,[eax+4*ecx]
    cmp ebx,0
    jz end_print_mesg_task1
    PRINT_CHAR ebx
    add ecx,1
    jmp print_mesg_task1
    
end_print_mesg_task1:
    ; odata printat mesajul, se restaureaza cheia de pe stiva
    pop ebx
    NEWLINE
    PRINT_UDEC 4,ebx
    NEWLINE
    PRINT_UDEC 4,edx
    NEWLINE
    
    leave
    ret

; ...........................................................
check_for_revient:
    push ebp
    mov ebp,esp
    
    push ebx
    push ecx
    push edx
      
    mov eax,[ebp+8] ; adresa catre imaginea originala
    mov edx,[ebp+12] ; dimensiunea imaginii
    
    xor ecx,ecx
    
    ; odata ce e gasit 'r', se verifica si celelalte caractere dupa el
search_rev:
    mov ebx,[eax+4*ecx]
    cmp ebx,'r'
    jnz not_revient
    mov ebx,[eax+4*ecx+4]
    cmp ebx,'e'
    jnz not_revient
    mov ebx,[eax+4*ecx+8]
    cmp ebx,'v'
    jnz not_revient
    mov ebx,[eax+4*ecx+12]
    cmp ebx,'i'
    jnz not_revient
    mov ebx,[eax+4*ecx+16]
    cmp ebx,'e'
    jnz not_revient
    mov ebx,[eax+4*ecx+20]
    cmp ebx,'n'
    jnz not_revient
    mov ebx,[eax+4*ecx+24]
    cmp ebx,'t'
    jnz not_revient
    
    ; daca toate if-urile anterioare trec, s-a gasit revient
    ; in acest caz, se pune in eax valoarea liniei  
    xor edx,edx
    mov eax,ecx
    mov ebx,[img_width]
    div ebx
    jmp end_check_for_revient
not_revient:
    ; daca s-a ajuns aici, inseamna ca nu s-a gasit revient
    ; se intoarce -1 din functie 
    add ecx,1
    cmp ecx,edx
    jnz search_rev
    mov eax,-1
end_check_for_revient:    
    pop edx
    pop ecx
    pop ebx
   
    leave
    ret

; ........................................................
xor_img_with_key:
    push ebp
    mov ebp,esp
    
    ; se salveaza vechii registrii pe stiva
    push eax
    push ebx
    push ecx
    push edx
        
    mov eax,[ebp+8] ; adresa catre imaginea originala
    mov ebx,[ebp+12] ; cheia cu care se decripteaza
    mov edx,[ebp+16] ; dimensiunea imaginii
  
    ; se aplica cheia pe imagine
    xor ecx,ecx
xor_img:
    push edx
    mov edx,[eax+4*ecx]
    xor edx,ebx
   
    mov [eax+4*ecx],edx
        
    add ecx,1
    pop edx
    cmp ecx,edx
    jnz xor_img
    
    ; se restaureaza vechii registrii de pe stiva
    pop edx
    pop ecx
    pop ebx
    pop eax
       
    leave 
    ret

; +++++++++++++++++++++++++++++++++++++++++++++++++++++
encrypt_msg_task2:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; adresa catre imaginea decriptata
    mov ebx,[ebp+12] ; cheia veche 
    mov edx,[ebp+16] ; linia veche
    
    add edx,1 ; raspunsul e criptat pe urmatoarea linie
    push edx ; se salveaza noua linie si mesajul pe stiva
    push eax
    
    ; se obtine in ebx cheia noua de criptare
    imul ebx,2
    add ebx,3
    xor edx,edx
    mov eax,ebx
    mov ecx,5
    div ecx
    sub eax,4
    mov ebx,eax
    
    pop eax ; se restaureaza adresa imaginii
    pop edx ; se restaureaza vechea linie
    
    
    push edx
    push eax
    call encrypt_reply
    add esp,8
    
    push ebx
    push eax
    call encrypt_with_new_key
    add esp,8 
    
    leave
    ret

; ............................................................
encrypt_with_new_key:
    push ebp
    mov ebp,esp
    
    ; se salveaza registrii pe stiva
    push eax
    push ebx
    push ecx
    push edx
    
    mov eax,[ebp+8] ; poza originala decriptata
    mov ebx,[ebp+12] ; cheia noua de criptare
    
    ; se calculeaza dimensiunea imaginii
    mov ecx,[img_height]
    mov edx,[img_width]
    imul edx,ecx
    
    xor ecx,ecx
encrypt:
    mov esi,[eax+4*ecx]
    xor esi,ebx ; se xoreaza fiecare pixel dupa noua cheie
    mov [eax+4*ecx],esi
    add ecx,1
    cmp ecx,edx
    jnz encrypt
       
    ; se restaureaza vechii registrii de pe stiva
    pop edx
    pop ecx
    pop ebx
    pop eax    
    leave
    ret
    
; ...........................................................
encrypt_reply:
    push ebp
    mov ebp,esp
    
    push eax
    push ebx
    push ecx
    push edx
     
    mov eax,[ebp+8] ; imaginea originala decriptata
    mov edx,[ebp+12] ; linia noua
    
    ; se calculeaza in functie de noua linie, pixelul de start
    mov ecx,edx
    mov ebx,[img_width]
    imul ecx,ebx
    
    ; odata gasit pixelul de start, se scrie mesajul de la acel punct
    mov dword[eax+4*ecx],'C'
    mov dword[eax+4*ecx+4],39
    mov dword[eax+4*ecx+8],'e'
    mov dword[eax+4*ecx+12],'s'
    mov dword[eax+4*ecx+16],'t'
    mov dword[eax+4*ecx+20],' '
    mov dword[eax+4*ecx+24],'u'
    mov dword[eax+4*ecx+28],'n'
    mov dword[eax+4*ecx+32],' '
    mov dword[eax+4*ecx+36],'p'
    mov dword[eax+4*ecx+40],'r'
    mov dword[eax+4*ecx+44],'o'
    mov dword[eax+4*ecx+48],'v'
    mov dword[eax+4*ecx+52],'e'
    mov dword[eax+4*ecx+56],'r'
    mov dword[eax+4*ecx+60],'b'
    mov dword[eax+4*ecx+64],'e'
    mov dword[eax+4*ecx+68],' '
    mov dword[eax+4*ecx+72],'f'
    mov dword[eax+4*ecx+76],'r'
    mov dword[eax+4*ecx+80],'a'
    mov dword[eax+4*ecx+84],'n'
    mov dword[eax+4*ecx+88],'c'
    mov dword[eax+4*ecx+92],'a'
    mov dword[eax+4*ecx+96],'i'
    mov dword[eax+4*ecx+100],'s'
    mov dword[eax+4*ecx+104],'.'
    mov dword[eax+4*ecx+108],0    
    
    ; se restaureaza vechii registrii
    pop edx
    pop ecx
    pop ebx
    pop eax    
    leave
    ret



; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
morse_encrypt:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; imaginea originala
    mov ebx,[ebp+12] ; mesajul
    mov edx,[ebp+16] ; byte-id
                     ; edx este un contor care tine evidenta pixelului
                     ; curent din poza. nu se reseteaza
    
    mov edi,eax ; se salveaza imaginea in edi
    
    xor ecx,ecx ; cu ecx se parcurge fiecare caracter din mesaj
morse_char:   
    cmp byte[ebx+ecx],0 ; se verifica daca nu s-a terminat mesajul
    jz end_morse_char
  
    xor eax,eax ; se curata eax, se stocheaza in acesta un caracter
    mov al,byte[ebx+ecx]
    
    push eax ; arg2 - caracterul din mesaj
    push edi ; arg1 - imaginea
    call morse_encode_one_char
    add esp,8
    
    add ecx,1
    jmp morse_char
    
end_morse_char:  
    sub edx,1 ; se suprascrie ultimul space cu valoarea 0
    mov dword[edi+4*edx],0
    
    leave
    ret

; ................................................................
morse_encode_one_char:
    push ebp
    mov ebp,esp
    
    ; edx se incrementeaza constant, dar nu se reseteaza
    
    push ebx
    
    mov ebx,[ebp+8] ; the image
    mov eax,[ebp+12] ; the char to be encoded
    
    ; se identifica, mai intai, ce caracter primeste functia
    cmp al,'A'
    jz a_char
    cmp al,'B'
    jz b_char
    cmp al,'C'
    jz c_char
    cmp al,'D'
    jz d_char
    cmp al,'E'
    jz e_char
    cmp al,'F'
    jz f_char
    cmp al,'G'
    jz g_char
    cmp al,'H'
    jz h_char
    cmp al,'I'
    jz i_char
    cmp al,'J'
    jz j_char
    cmp al,'K'
    jz k_char
    cmp al,'L'
    jz l_char
    cmp al,'M'
    jz m_char
    cmp al,'N'
    jz n_char
    cmp al,'O'
    jz o_char
    cmp al,'P'
    jz p_char
    cmp al,'Q'
    jz q_char
    cmp al,'R'
    jz r_char
    cmp al,'S'
    jz s_char
    cmp al,'T'
    jz t_char
    cmp al,'U'
    jz u_char
    cmp al,'V'
    jz v_char
    cmp al,'X'
    jz x_char
    cmp al,'Y'
    jz y_char
    cmp al,'W'
    jz w_char
    cmp al,'Z'
    jz z_char
    cmp al,','
    jz comma_char
    cmp al,'1'
    jz one_char
    cmp al,'2'
    jz two_char
    cmp al,'3'
    jz three_char
    cmp al,'4'
    jz four_char
    cmp al,'5'
    jz five_char
    cmp al,'6'
    jz six_char
    cmp al,'7'
    jz seven_char
    cmp al,'8'
    jz eight_char
    cmp al,'9'
    jz nine_char
    cmp al,'0'
    jz zero_char
    cmp al,32
    jz space_char
    
    ; se scrie pentru fiecare litera codul corespunzator in . sau -
    ; se concateneaza la final mereu caracterul SPACE
    
a_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],32
    add edx,3
    jmp end_morse_conv
b_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
c_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
d_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
e_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],32
    add edx,2
    jmp end_morse_conv
f_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
g_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
h_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
i_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],32
    add edx,3
    jmp end_morse_conv
j_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
k_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
l_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
m_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],32
    add edx,3
    jmp end_morse_conv
n_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],32
    add edx,3
    jmp end_morse_conv
o_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
p_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
q_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
r_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
s_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
t_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],32
    add edx,2
    jmp end_morse_conv
u_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
v_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
x_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
w_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],32
    add edx,4
    jmp end_morse_conv
y_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv
z_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],32
    add edx,5
    jmp end_morse_conv  
comma_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],45
    mov dword[ebx+4*edx+24],32
    add edx,7
    jmp end_morse_conv
one_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
two_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
three_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
four_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
five_char:
    mov dword[ebx+4*edx],46
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
six_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],46
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
seven_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],46
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
eight_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],46
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
nine_char:
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],46
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
zero_char:  
    mov dword[ebx+4*edx],45
    mov dword[ebx+4*edx+4],45
    mov dword[ebx+4*edx+8],45
    mov dword[ebx+4*edx+12],45
    mov dword[ebx+4*edx+16],45
    mov dword[ebx+4*edx+20],32
    add edx,6
    jmp end_morse_conv
space_char:
    mov dword[ebx+4*edx],124
    mov dword[ebx+4*edx+4],32
    add edx,2
 
end_morse_conv:   
    pop ebx
    leave
    ret

; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
lsb_encode:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; imaginea originala
    mov ebx,[ebp+12] ; mesajul
    mov edx,[ebp+16] ; byte id
    
    sub edx,1 ; se obtine indexul pixelului de start 
    mov ecx,edx
    
    push ecx ; se salveaza indexul de start
    
    ; calculez lunginea mesajul care trebuie criptat
    xor ecx,ecx
strlen_lsb:
    add ecx,1
    cmp byte[ebx+ecx],0
    jnz strlen_lsb
  
    mov esi,ecx ; se obtine in ecx dimensiunea mesajului   
    pop ecx ; se da restore la indexul de start
    
    mov edx,esi
    imul edx,8 ; un caracter e un octet
               ; pentru cate caracter e nevoie de 8 pixeli
    add edx,ecx ; se adauga offsetul dat de indexul de start
    
    mov dword[lsb_msg_len],esi ; dimensiunea mesajului
    mov dword[lsb_start],ecx ; indexul pixelului de start
    mov dword[lsb_end],edx ; indexul pixelului de end
    mov dword[lsb_msg],ebx ; mesajul original
    mov esi,eax ; se salveaza imaginea in esi
    
    mov ecx,[lsb_start]
    xor edx,edx ; edx este iteratorul de caractere din mesaj
    
lsb_chars:
    cmp edx,[lsb_msg_len] ; se parcurge fiecare caracter din mesaj
    jz lsb_chars_end
    
    xor eax,eax
    mov ebx,[lsb_msg]
    mov al,byte[ebx+edx]
    push eax
    call get_mirror_binary
    add esp,4 ; eax are valoarea binara in oglinda
    
    push edx ; se salveaza edx pe stiva
    
    ; se ia numarul rezultat si se pun bitii in ordine pe cate un pixel
    xor edx,edx ; se itereaza cu edx prin bitii octetului rezultat
lsb_bits:
    cmp edx,8 ; se stie ca avem de a face cu un octet
    jz end_bits
    test al,1
    jz lsb_bits_even
    jmp lsb_bits_odd
lsb_bits_even: ; se pune 0
    mov edi,[esi+4*ecx]
    test edi,1
    jz skip_put_0
    sub edi,1
    mov [esi+4*ecx],edi
skip_put_0:    
    add ecx,1
    add edx,1
    shr eax,1
    jmp lsb_bits
lsb_bits_odd: ; se pune 1
    mov edi,[esi+4*ecx]
    test edi,1
    jnz skip_put_1
    add edi,1
    mov [esi+4*ecx],edi   
skip_put_1:
    add ecx,1
    add edx,1
    shr eax,1
    jmp lsb_bits
    
end_bits: 
    pop edx ; se restaureaza vechea functiei a iteratorului edx
    add edx,1
    jmp lsb_chars    
     
lsb_chars_end:
       
    ; se cripteaza si terminatorul de sir pe 8 pixeli
    xor edx,edx 
lsb_terminator:
    cmp edx,8
    jz lsb_terminator_end   
    mov edi,[esi+4*ecx]
    test edi,1
    jz skip_terminator
    sub edi,1
    mov [esi+4*ecx],edi
skip_terminator:    
    add ecx,1
    add edx,1
    jmp lsb_terminator
     
lsb_terminator_end:       
    leave
    ret
  
; ......................................................
get_mirror_binary:
    push ebp
    mov ebp,esp
    
    ; se salveaza registrii pe stiva
    push ebx
    push ecx
    push edx
    
    mov ebx,[ebp+8] ; caracterul ASCII
    
    ; caracterul este pe 8 biti si are o valoare anume binara
    ; bitii caracterului sunt luati unu cate unul incepand de LSB
    ; si prin operatii de shiftari, se construieste un alt numar
    ; care are bitii numarului initial, dar in ordine inversa
    ; ex. daca caracterul original era 0b01010111 acum e 0b11101010
    ; numarul rezultat actioneaza ca o stiva de biti
    xor eax,eax
    xor ecx,ecx
convert_bin:
    test bl,1
    jz conv_even
    jmp conv_odd
conv_even:
    shl eax,1
    shr ebx,1
    add ecx,1
    cmp ecx,8
    jz end_mirror_binary
    jmp convert_bin
conv_odd:
    shl eax,1
    add eax,1
    shr ebx,1
    add ecx,1
    cmp ecx,8
    jz end_mirror_binary
    jmp convert_bin
    
end_mirror_binary:    
    ; se restaureaza vechii registrii
    pop edx
    pop ecx
    pop ebx    
    leave
    ret


; ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
lsb_decode:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8] ; imaginea originala
    mov edx,[ebp+12] ; byte-id
    
    sub edx,1 ; se obtine indexul corect de start
    
    ; in continuare, se construiesc caracterele bit cu bit
    ; in ebx se va construi codul ASCII al fiecarui char
    mov ecx,edx ; se reseteaza iteratorul 
lsb_decode_chars:
    xor ebx,ebx 
    xor edx,edx
build_ascii:
    cmp edx,8 ; se parcurg grupuri de cate 8 pixeli pentru un caracter
    jz end_build_ascii
    shl ebx,1
    mov edi,[eax+4*ecx]
    add ecx,1
    test edi,1 ; se foloseste o masca de biti pentru a vedea ultimul bit
    jnz build_put_1
    jmp build_put_0
build_put_1:
    add ebx,1
build_put_0: 
    add edx,1   
    jmp build_ascii 
end_build_ascii:
    test ebx,ebx
    jz end_lsb_decode_chars
    ; in ebx exista caracterul construit bit cu bit
    PRINT_CHAR ebx ; se afiseaza in stdout
    jmp lsb_decode_chars

end_lsb_decode_chars:
    NEWLINE
    leave
    ret    
            

; +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

blur:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8]
    
    ; se aloca dinamic memorie pentru backup
    mov ecx,[img_height]
    mov edx,[img_width]
    imul ecx,edx
    push eax
    push ecx
    imul ecx,4
    push ecx
    call malloc
    add esp,4
    mov [img_backup],eax
    pop ecx
    pop eax

    ; se copiaza imaginea originala la adresa de backup
    push ecx
    push dword[img_backup]
    push eax
    call backup_img
    add esp,12
    
    push dword[img_backup]
    push eax
    call blur_values
    add esp,8
    
    ; se printeaza imaginea cu functia din cerinta
    push dword[img_height]
    push dword[img_width]
    push eax
    call print_image
    add esp,12
    
    leave 
    ret
 
; .......................................................
backup_img:
    push ebp
    mov ebp,esp
    
    ; se salveaza vechii registrii pe stiva
    push eax
    push ebx
    push ecx
    push edx
   
    mov eax,[ebp+8] ; adresa catre imaginea backup
    mov ebx,[ebp+12] ; adresa catre imaginea destinatie
    mov ecx,[ebp+16] ; dimensiunea vectorul
       
back_proc:
    mov edx,[eax+4*ecx-4]
    mov [ebx+4*ecx-4],edx    
    sub ecx,1   
    cmp ecx,0
    jnz back_proc
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    leave
    ret
    
; ......................................................
blur_values:
    push ebp
    mov ebp,esp
    
    push eax
    push ebx
    push ecx
    
    mov eax,[ebp+8] ; adresa catre imaginea originala
    mov ebx,[ebp+12] ; adresa catre imaginea de backup
    mov ecx,[img_height]
    mov edx,[img_width]
    
    
    sub ecx,1  
iter_height:
    sub ecx,1
    cmp ecx,0
    jz blur_end
    mov edx,[img_width]
    sub edx,2
iter_width:
    ; la fiecare iteratie, se reseteaza suma la 0   
    mov dword[blur_sum],0   
    ; =======================================
    ; se gaseste si se aduna valoarea pixelului curent
    push eax
    
    push edx ; indexul coloanei curent
    push ecx ; indexul liniei curente
    push ebx  ; adresa catre imaginea de backup
    call get_current
    add [blur_sum],eax
    add esp,12
    
    pop eax
    ; =======================================
    ; se gaseste si se aduna valorea pixelului stang
    push eax
    
    push edx
    push ecx
    push ebx
    call get_left
    add [blur_sum],eax
    add esp,12
    
    pop eax
    ; =======================================
    ; se gaseste si se aduna valoarea pixelului drept
    push eax
    
    push edx
    push ecx
    push ebx 
    call get_right
    add [blur_sum],eax
    add esp,12
    
    pop eax
    ; ========================================
    ; se gaseste si se aduna valoarea pixelului top
    push eax
    
    push edx
    push ecx
    push ebx    
    call get_top
    add [blur_sum],eax
    add esp,12
    
    pop eax
    ; ========================================
    ; se gaseste si se aduna valoarea pixelului bottom
    push eax
    
    push edx
    push ecx
    push ebx
    call get_bottom
    add [blur_sum],eax
    add esp,12
    
    pop eax
    ; ========================================   
    ; se imparte la 5 pentru a se obtine valoarea pixelului blurat
    push eax
    push edx
    push ecx
    
    mov eax,[blur_sum]
    mov ecx,5
    xor edx,edx
    div ecx
    mov [blur_sum],eax
      
    pop ecx
    pop edx
    pop eax
    ; ========================================
    ; se updateaza imagine cu valoare obtinuta
    push edx
    push ecx
    push dword[blur_sum]
    push eax
    call blur_current_value
    add esp,16

 
    sub edx,1  
    cmp edx,0
    jz iter_height
    jmp iter_width
    
blur_end:
    ; se elibereaza copia alocata dinamic
    mov eax,[img_backup]
    push eax
    call free
    add esp,4

    pop ecx
    pop ebx
    pop eax
    leave
    ret


; ..........................................................
get_current:
    ; se returneaza valoare pixelului curent
    push ebp
    mov ebp,esp
    
    push ebx
    push ecx
    push edx
    
    mov ebx,[ebp+8] ; adresa imaginii originale
    mov ecx,[ebp+12] ; linia curenta
    mov edx,[ebp+16] ; coloana curenta
    
        
    mov eax,[img_width]
    imul eax,ecx 
    add eax,edx
    mov eax,[ebx+4*eax]
    
    pop edx
    pop ecx
    pop ebx
    
    leave
    ret
  
      
; .......................................................
get_left:
    ; se returneaza valoare pixelului stang
    push ebp
    mov ebp,esp
    
    push ebx ; adresa imaginii originale
    push ecx ; linia curenta
    push edx ; coloana curenta
    
    mov ebx,[ebp+8]
    mov ecx,[ebp+12]
    mov edx,[ebp+16]
    
         
    mov eax,[img_width]
    imul eax,ecx 
    add eax,edx
    mov eax,[ebx+4*eax-4]
     
    pop edx
    pop ecx
    pop ebx
    
    leave
    ret
    
    
; ........................................................
get_right:
    ; se returneaza valoare pixelului drept
    push ebp
    mov ebp,esp
    
    push ebx
    push ecx
    push edx
    
    mov ebx,[ebp+8] ; adresa imaginii originale
    mov ecx,[ebp+12] ; linia curenta
    mov edx,[ebp+16] ; coloana curenta
    
        
    mov eax,[img_width]
    imul eax,ecx 
    add eax,edx
    mov eax,[ebx+4*eax+4]
     
    pop edx
    pop ecx
    pop ebx
    leave
    ret
    
    
; .......................................................
get_top:
    ; se returneaza valoare pixelului top
    push ebp
    mov ebp,esp
    
    push ebx
    push ecx
    push edx
    
    mov ebx,[ebp+8] ; adresa imagini originale
    mov ecx,[ebp+12] ; linia curenta
    mov edx,[ebp+16] ; coloana curenta
    
    mov eax,[img_width]
    sub ecx,1
    imul eax,ecx 
    add eax,edx
    mov eax,[ebx+4*eax]
    
    pop edx
    pop ecx
    pop ebx
    leave
    ret
    
    
; .......................................................
get_bottom:
    ; se returneaza valoare pixelului bottom
    push ebp
    mov ebp,esp
    
    push ebx
    push ecx
    push edx
    
    mov ebx,[ebp+8] ; adresa imaginii originale
    mov ecx,[ebp+12] ; linia curenta
    mov edx,[ebp+16] ; coloana curenta
  
    mov eax,[img_width]
    add ecx,1
    imul eax,ecx 
    add eax,edx
    mov eax,[ebx+4*eax]
    
    pop edx
    pop ecx
    pop ebx
    
    leave
    ret
    
    
; ...........................................................
blur_current_value:
    push ebp
    mov ebp,esp
    
    ; se salveaza vechii registrii pe stiva
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    mov eax,[ebp+8] ; adresa catre imaginea destinatie
    mov ebx,[ebp+12] ; valoarea blurata 
    mov ecx,[ebp+16] ; indexul de linie
    mov edx,[ebp+20] ; indexul de coloana
    
    ; se calculeaza pozitia la care trebuie pusa valoarea noua
    mov esi, [img_width]
    imul esi,ecx
    add esi,edx
    ; se blureaza pixelul din imaginea originala
    mov [eax+4*esi],ebx
    
    ; se restaureaza vechii registrii de pe stiva
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    
    leave
    ret

    