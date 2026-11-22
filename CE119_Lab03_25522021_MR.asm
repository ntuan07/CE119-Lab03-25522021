.data
n:      .word 12               # gia tri n can tinh
msgA:   .asciiz "F("
msgB:   .asciiz ") = "
msgNl:  .asciiz "\n"

.text
.globl main
main:
    la    $t0, n
    lw    $a0, 0($t0)          # $a0 = n
    move  $s0, $a0             # giu n de in
    jal   fib_opt              # $v0 = F(n)
    move  $s1, $v0             # giu ket qua
    li    $v0, 4               # in "F("
    la    $a0, msgA
    syscall
    move  $a0, $s0             # in n
    li    $v0, 1
    syscall
    li    $v0, 4               # in ") = "
    la    $a0, msgB
    syscall
    move  $a0, $s1             # in F(n)
    li    $v0, 1
    syscall
    li    $v0, 4
    la    $a0, msgNl
    syscall
    li    $v0, 10              # ket thuc
    syscall

# fib_opt: nhu fib_rec nhung kiem tra truong hop co so TRUOC khi cap khung
# Tham so : $a0 = n (n >= 0)
# Tra ve  : $v0 = F(n)
# Thanh ghi: $s0 (giu n), $s1 (giu F(n-1)), $ra, chi duoc cat khi n >= 2;
#            $a0, $v0, $t0 khong can bao toan
# Khung ngan xep 12 byte (chi cap khi n >= 2): 8($sp)=$ra, 4($sp)=$s0, 0($sp)=$s1
fib_opt:
    slti  $t0, $a0, 2          # co so: n < 2 ?
    beq   $t0, $zero, fo_rec
    move  $v0, $a0             # F(n) = n, tra ve ngay, khong cap khung
    jr    $ra
fo_rec:
    addi  $sp, $sp, -12        # chi cap khung khi can de quy
    sw    $ra, 8($sp)
    sw    $s0, 4($sp)
    sw    $s1, 0($sp)
    move  $s0, $a0             # $s0 = n
    addi  $a0, $s0, -1
    jal   fib_opt              # $v0 = F(n-1)
    move  $s1, $v0             # giu F(n-1)
    addi  $a0, $s0, -2
    jal   fib_opt              # $v0 = F(n-2)
    add   $v0, $s1, $v0        # F(n) = F(n-1) + F(n-2)
    lw    $s1, 0($sp)          # ket thuc: nap lai dung offset
    lw    $s0, 4($sp)
    lw    $ra, 8($sp)
    addi  $sp, $sp, 12         # thu hoi khung
    jr    $ra

# fib_iter: tinh F(n) bang vong lap
# Tham so : $a0 = n
# Tra ve  : $v0 = F(n)
# Thanh ghi: $t0-$t3 (thu tuc la)
fib_iter:
    move  $v0, $zero           # a = F(0)
    li    $t0, 1               # b = F(1)
    move  $t1, $zero           # i = 0
fi_loop:
    slt   $t2, $t1, $a0
    beq   $t2, $zero, fi_done
    addu  $t3, $v0, $t0        # a + b
    move  $v0, $t0
    move  $t0, $t3
    addiu $t1, $t1, 1
    j     fi_loop
fi_done:
    jr    $ra