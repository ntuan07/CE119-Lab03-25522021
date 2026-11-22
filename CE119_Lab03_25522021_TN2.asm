.data
str1:   .asciiz "kien truc may tinh"
str2:   .asciiz "mips"
str3:   .asciiz ""
str4:   .asciiz "a bc def"
str5:   .asciiz "moi thu tuc co mot khung ngan xep"   # S(d), d = 1
tab:    .word str1, str2, str3, str4, str5
bar:    .asciiz "|"
nl:     .asciiz "\n"

.text
.globl main
main:
    la    $s0, tab             # con tro vao bang chuoi
    li    $s1, 5               # so chuoi con lai
loop:
    beq   $s1, $zero, done
    lw    $a0, 0($s0)          # dia chi chuoi can dao
    jal   reverse_words
    li    $v0, 4               # in "|"
    la    $a0, bar
    syscall
    lw    $a0, 0($s0)          # in chuoi sau khi dao
    li    $v0, 4
    syscall
    li    $v0, 4               # in "|" va xuong dong
    la    $a0, bar
    syscall
    li    $v0, 4
    la    $a0, nl
    syscall
    addi  $s0, $s0, 4
    addi  $s1, $s1, -1
    j     loop
done:
    li    $v0, 10              # ket thuc
    syscall

# strlen: dem so ky tu truoc byte 0
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : $v0 = do dai chuoi
# Thanh ghi: $v0, $t0, $t1 (thu tuc la, khong dung ngan xep)
strlen:
    move  $v0, $zero           # dem = 0
sl_loop:
    addu  $t0, $a0, $v0        # dia chi ky tu thu dem
    lbu   $t1, 0($t0)
    beq   $t1, $zero, sl_done  # gap byte 0 thi dung
    addi  $v0, $v0, 1
    j     sl_loop
sl_done:
    jr    $ra

# rev_range: dao tai cho doan [$a0, $a1], tinh ca hai dau
# Tham so : $a0 = dia chi ky tu dau, $a1 = dia chi ky tu cuoi
# Tra ve  : khong
# Thanh ghi: $a0, $a1 (bi thay doi), $t0, $t1, $t2 (thu tuc la)
rev_range:
rr_loop:
    sltu  $t0, $a0, $a1        # dau < cuoi ? (so sanh khong dau)
    beq   $t0, $zero, rr_done
    lbu   $t1, 0($a0)          # hoan doi hai ky tu
    lbu   $t2, 0($a1)
    sb    $t2, 0($a0)
    sb    $t1, 0($a1)
    addi  $a0, $a0, 1
    addi  $a1, $a1, -1
    j     rr_loop
rr_done:
    jr    $ra

# reverse_words: dao thu tu cac tu tai cho (cac tu cach nhau dau cach)
# Tham so : $a0 = dia chi chuoi .asciiz
# Tra ve  : khong
# Thanh ghi: $s0 = dau tu hien tai, $s1 = dia chi byte 0 cuoi chuoi,
#            $s2 = con tro duyet (deu duoc cat vao khung), $ra (cat vao khung),
#            $a0, $a1, $v0, $t0, $t1 (khong can bao toan)
# Khung ngan xep 16 byte: 12($sp)=$ra, 8($sp)=$s0, 4($sp)=$s1, 0($sp)=$s2
reverse_words:
    addi  $sp, $sp, -16        # mo dau: cap khung 4 word
    sw    $ra, 12($sp)
    sw    $s0, 8($sp)
    sw    $s1, 4($sp)
    sw    $s2, 0($sp)
    move  $s0, $a0             # $s0 = dau chuoi (dau tu hien tai)
    jal   strlen               # $v0 = do dai
    addu  $s1, $s0, $v0        # $s1 = dia chi byte 0 cuoi chuoi
    move  $a0, $s0             # dao toan bo chuoi [dau, cuoi - 1]
    addi  $a1, $s1, -1
    jal   rev_range
    move  $s2, $s0             # $s2 = con tro duyet
rw_scan:
    beq   $s2, $s1, rw_word    # het chuoi: xu ly tu cuoi
    lbu   $t0, 0($s2)
    li    $t1, 32              # ky tu dau cach
    beq   $t0, $t1, rw_word    # gap dau cach: ket thuc mot tu
    addi  $s2, $s2, 1
    j     rw_scan
rw_word:
    sltu  $t0, $s0, $s2        # tu khong rong ? (dau < con tro)
    beq   $t0, $zero, rw_next
    move  $a0, $s0             # dao lai tu [dau tu, con tro - 1]
    addi  $a1, $s2, -1
    jal   rev_range
rw_next:
    beq   $s2, $s1, rw_done    # da het chuoi
    addi  $s2, $s2, 1          # bo qua dau cach
    move  $s0, $s2             # dau tu moi
    j     rw_scan
rw_done:
    lw    $s2, 0($sp)          # ket thuc: nap lai theo dung offset
    lw    $s1, 4($sp)
    lw    $s0, 8($sp)
    lw    $ra, 12($sp)
    addi  $sp, $sp, 16         # thu hoi khung
    jr    $ra