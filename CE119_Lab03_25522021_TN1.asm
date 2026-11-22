.data
msg:    .asciiz "Ket qua: "
.text
.globl main
main:
        li    $a0, 5            # x = 5
        jal   outer             # v0 = outer(5)
        move  $s0, $v0
        li    $v0, 4
        la    $a0, msg
        syscall
        move  $a0, $s0
        li    $v0, 1
        syscall
        li    $v0, 10
        syscall
        
# outer(x) = inner(x) + 1
# Tham so : $a0 = x
# Tra ve  : $v0 = 2x + 1
# Thanh ghi: $ra (cat vao khung 4 byte), $a0, $v0
outer:
    addi  $sp, $sp, -4         # cap khung 1 word
    sw    $ra, 0($sp)          # cat dia chi tro ve main
    jal   inner                
    addi  $v0, $v0, 1         
    lw    $ra, 0($sp)          # nap lai $ra
    addi  $sp, $sp, 4          # thu hoi khung
    jr    $ra
    
# inner(x) = 2 * x
inner:
        add   $v0, $a0, $a0
        jr    $ra
