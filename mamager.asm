.code 

AsmCalcw2s proc
mov [rsp+28],rdi
mov [rsp+30],rsi
mov rcx,[rsp+28]
sub rcx,[rsp+30]
mov rdx,rcx
neg rdx
cmovs rdx,rcx
mov rcx,727598E993932A94h
add rcx,r11
add rcx,rdx
mov [rsp+38],rcx
mov [rsp+28],rdi
mov [rsp+30],rsi
mov r11,[rsp+28]
sub r11,[rsp+30]
mov rdx,r11
neg rdx
cmovs rdx,r11
mov r11,5DB842803313273Bh
add r11,rdx
xor r11,rcx
mov [rsp+38],r11
mov [rsp+28],rdi
mov [rsp+30],rsi
mov rcx,[rsp+28]
sub rcx,[rsp+30]
mov rdx,rcx
neg rdx
cmovs rdx,rcx
mov rcx,0EE77FA41C137EABDh
add rcx,rdx
mov rdx,427F7EA46022833Ch
xor rdx,rcx
add rdx,r11
mov [rsp+38],rdx
mov r11,[rsp+00000088]
mov [rsp+28],rdi
mov [rsp+30],rsi
mov r10,[rsp+28]
sub r10,[rsp+30]
mov rcx,r10
neg rcx
cmovs rcx,r10
ret
AsmCalcw2s endp

end