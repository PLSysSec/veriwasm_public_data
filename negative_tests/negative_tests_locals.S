CPU X64
bits 64

SECTION .text

; Local state encapsulation: write outside the stack frame
; func1 :: int -> ()
func1:
    push rbp;
    mov rbp, rsp;
    mov dword [rsp+0x20], 2;
    pop rbp;
    ret;

; Well-bracketed control flow: write to return address based off of rbp
; func2 :: int -> ()
func2:
    push rbp;
    mov rbp, rsp;
    mov dword [rbp + 0x10], 4;
    pop rbp;
    ret;

; Well-bracketed control flow: rsp is restored to its original value
; func3 :: int -> int -> ()
func3:
    push rbp;
    mov rbp, rsp;
    push rsi;
    pop rbp;
    ret;


; Confidentiality: write unit data (rax) to linear memory
; func4 :: int -> ()
func4:
    push rbp;
    mov rbp, rsp;
    mov ecx, 1;
    mov [rdi + rcx], rax;
    pop rbp;
    ret;

; Confidentiality: Use uninit value as call argument
; func5 :: int -> ()
func5:
    push rbp;
    mov rbp, rsp;
    call subfunc5;
    pop rbp;
    ret;

; subfunc5 :: int -> int -> ()
subfunc5:
    ret;
    
; Confidentiality: branch on uninit data
; func6 :: int -> ()
func6:
    push rbp;
    mov rbp, rsp;
    cmp rax, rbx;
    jb func6_br_target;
    pop rbx;
    ret;

func6_br_target:
    pop rbp;
    ret;

; Confidentiality: returns an uninit value in rax
; func7 :: i32 -> i32
func7:
    push rbp;
    mov rbp, rsp;
    pop rbp;
    ret;

; Confidentiality: Callee-saved register restoration
; func8 :: int -> ()
func8: 
    push rbp;
    mov rbp, rsp;
    mov r12, 1337;
    pop rbp;
    ret;

; Type-directed CFI: Makes an indirect call without checking the type
; func9 :: int -> ()
func9:
    push rbp;
    mov rbp, rsp;
    push r11;
    push r12;
    mov rax, 0;
    mov r11, lucet_tables;
    mov r11, qword [r11 + 0x8];
    cmp rax, r11;
    jb func9_success1;
    ud2;

func9_success1:
    mov r11, guest_table_0;
    shl rax, 0x4;
    mov r12,[r11+ rax];
    cmp r12, 0x0;
    je func9_success2;
    ud2;

func9_success2:
    mov rax, qword [r11 + rax + 0x8];
    call [rax];
    pop r12;
    pop r11;
    pop rbp;
    ret;

; subfunc9 :: int -> ()
subfunc9:
    ret;






lucet_probestack:

SECTION .rodata
global lucet_tables
lucet_tables: dq guest_table_0; # just how it has to be set up
    dq 1; # Number of table entries

SECTION .data
global guest_table_0
guest_table_0: dq 1; # index number
    dq subfunc9; # pointer 


