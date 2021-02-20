CPU X64
bits 64

SECTION .text

; rsp changes over a loop
guest_func_1_testfail:
    push rbp;
    mov  rbp, rsp;
    push rdi;
loop1:
    push rdi;
    sub  rdi, 1;
    test rdi, rdi;
    jnz loop1;

    pop rdi;
    pop rbp;
    ret;

; write outside the stack frame
guest_func_2_testfail:
    push rbp;
    mov rbp, rsp;
    mov dword [rsp+0x20], 2;
    pop rbp;
    ret;

; stack balance
guest_func_3_testfail:
    push rbp;
    mov rbp, rsp;
    push rax;
    pop rbp;
    ret;

; failure to resolve jump
guest_func_4_testfail:
    push rbp;
    mov rbp, rsp;
    mov rax, rbp;
    jmp rax;
    pop rbp;
    ret;

;failure to resolve call
guest_func_5_testfail:
    push rbp;
    mov rbp, rsp;
    mov rax, rbp;
    call rax;
    pop rbp;
    ret;

; invalid heap access using arg not legalized
guest_func_6_testfail:
    push rbp;
    mov rbp, rsp;
    mov rax, [rdi + r9];
    jmp rax;
    pop rbp;
    ret;

; Invalid heap access with 2nd arg not legalized
guest_func_7_testfail:
    push rbp;
    mov rbp, rsp;
    mov rax, [rdi + rsi + 0x10]
    pop rbp;
    ret;

; Invalid heap access with third arg not legalized
guest_func_8_testfail:
    push rbp;
    mov rbp, rsp;
    mov rax, [rdi + 0x10 + r9];
    pop rbp;
    ret;

; Invalid heap access with overwritten rdi
guest_func_9_testfail:
    push rbp;
    mov rbp, rsp;
    mov rsi, 0x10;
    mov r9, 0x10;
    mov rdi, 0x10;
    mov rax, [0x10 + rsi + r9];
    pop rbp;
    ret;

; Invalid memory access to code that is clearly not heap or stack access
guest_func_10_testfail:
    push rbp;
    mov rbp, rsp;
    mov r9, 0x10;
    mov rax, [r9];
    pop rbp;
    ret;

;call with rdi != heap base
guest_func_11_testfail:
    push rbp;
    mov rbp, rsp;
    mov rax, rbp;
    mov rdi, 0x10;
    call guest_func_11_testfail;
    pop rbp;
    ret;

;illegal int instruction
guest_func_12_testfail:
    push rbp;
    mov rbp, rsp;
    int 0xb;
    pop rbp;
    ret;

;illegal syscall instruction
guest_func_13_testfail:
    push rbp;
    mov rbp, rsp;
    syscall;
    pop rbp;
    ret;

;write to return address based off of rbp?
guest_func_14_testfail:
    push rbp;
    mov rbp, rsp;
    mov dword [rbp + 0x10], 4;
    pop rbp;
    ret;


; issue #23 from NaCl security challenge
; does not diffentiate between indirect calls to reg and rereferenced reg
guest_func_nacl_23:
    push rbp;
    mov rbp, rsp;
    mov rax, rbp;
    mov r11, lucet_tables;
    mov r11, qword [r11 + 0x8];
    cmp rax, r11;
    jb nacl_23_success1;
    ud2;

nacl_23_success1:
    mov r11, guest_table_0;
    shl rax, 0x4;
    mov r12,[r11+ rax];
    cmp r12, 0x0;
    je nacl_23_success2;

nacl_23_success2:
    mov rax, qword [r11 + rax + 0x8];
    call [rax];
    pop rbp;
    ret;

;BTR modifies memory access
guest_func_nacl_323_1:
    push rbp;
    mov rbp, rsp;
    btr [0xdeadbeef], rcx;
    pop rbp;
    ret;

;Same as above but with BTS
guest_func_nacl_323_2:
    push rbp;
    mov rbp, rsp;
    bts [0xdeadbeef], rcx;
    pop rbp;
    ret;

;same thing but with BTC
guest_func_nacl_323_3:
    push rbp;
    mov rbp, rsp;
    btc [0xdeadbeef], rcx;
    pop rbp;
    ret;
 
;illegal pop to RSP
guest_func_nacl_323_4:
    push rbp;
    mov rbp, rsp;
    push rax;
    pop rsp;
    pop rbp;
    ret;

;address-size 32-bit rip addressed mem
;nacl_390_1:
;    push rbp;
;    mov rbp, rsp;
;a32 mov rax, [abs $ + 0x10]; $ is rip
;    pop rbp;
;    ret;

guest_func_nacl_390:
    push rbp;
    mov rbp, rsp;
    mov eax, 3
    mov edi, 0x100
    lea edi, [ rbp + rdi ];
    a32 stosd;
    pop rbp;
    ret;

; attempting to overwrite subregister of protected register (rsp)
guest_func_nacl_1585:
    push rbp;
    mov rbp, rsp;
    sub sp, ax;
    pop rbp;
    ret;

; unchecked use of the movsb instruction
guest_func_nacl_2532:
    push rbp;
    mov rbp, rsp;
    lea rdi, [r15 + rdi];
    movsb;
    pop rbp;
    ret;
    
; bug in pittsfield pointed out in bakersfield paper
; pittsfield only 1 definition of safe, so it does not differentiate
; between safe to execute and safe to write to
guest_func_bakersfield_1:
    push rbp;
    mov rbp, rsp;
    mov rbx, bakersfield_label;
    jmp rbx;
    ud2;
bakersfield_label:
    mov dword [rbx], 4;
    pop rbp;
    ret;

guest_func_misfit_1:
    push rbp;
    mov rbx, rsp;
    mov rax, qword [rdi-0x10];
    mov eax, dword [rax];
    mov ecx, eax;
    add ecx, 0xfffffff0;
    add ecx, 0xfffffff4;
    mov ecx, ecx;
    mov dword [rdi + rcx + 0xc], esi;
    mov dword [rdi + rcx + 0x8], edx;
    mov edx, dword [rdi+rcx+0xc];

misfit_label_1:
    mov ebx, dword [rsp];
    test ebx, ebx;
    je misfit_label_exit;

    add rsp, 0xffffffff;
    mov qword [rsp], rsp;
    jmp misfit_label_1;

misfit_label_exit:
    pop rbp;
    retn;

;jump table that dereferences switch table before checking index
guest_func_cranelift_805:
    push rbp;
    mov rbp, rsp;
    mov ecx, ecx;
    mov rdx, cranelift_805_jump_table; 
    movsxd rcx, dword [rdx+rcx*4];
    cmp ecx, 0x7;
    jae cranelift_805_exit;
    add rdx, rcx;
    jmp rdx;

cranelift_805_exit:
    pop rbp;
    ret;

cranelift_805_jump_table:
    dd cranelift_805_offset
    dd cranelift_805_offset
    dd cranelift_805_offset
    dd cranelift_805_offset

cranelift_805_offset: equ cranelift_805_exit - cranelift_805_jump_table

lucet_probestack:

SECTION .rodata
global lucet_tables
lucet_tables: dq guest_table_0; # just how it has to be set up
    dq 1; # Number of table entries

SECTION .data
global guest_table_0
guest_table_0: dq 0xffffffffffffffff; # index number
    dq 0; # pointer 


