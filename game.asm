       .model large
       .286

data_seg         segment
;====Character Variable==========
max_hp  db ?
cecil_dmode db 'N'      ;cecil draw mode  'N'ormal or 'S'pacial
cecil   db 2 dup (?)    ;Position   0,1
        db ?            ;HP         2
        db ?            ;level      3
        db ?            ;Where face of cecil N,E,W,S    4
        db 5 dup (0)    ;Map attribute (P N E W S)      5,6,7,8,9
        db ?            ;Player Return Value            10
        dw 0            ;EXP        11
;====Enemy Variable==============
enemy_a db 5 dup (?)    ;Map attribute for enemy (N E W S P)
enemy1  db 'N'          ;Show ('Y' or 'N')              0
        db 1            ;Type of enemy                  1
        db 2 dup (0)    ;position                       2,3
        db ?            ;state                          4
        db ?            ;HP                             5
        db ?            ;walk state                     6
        db ?            ;walk way                       7
        db ?            ;level                          8 
enemy2  db 'N'          ;Show ('Y' or 'N')
        db 1            ;Type of enemy
        db 2 dup (0)    ;position
        db ?            ;state
        db ?            ;HP
        db ?            ;walk state
        db ?            ;walk way                       
        db ?            ;level      
enemy3  db 'N'          ;Show ('Y' or 'N')
        db 1            ;Type of enemy
        db 2 dup (0)    ;position
        db ?            ;state
        db ?            ;HP
        db ?            ;walk state
        db ?            ;walk way                       
        db ?            ;level      
enemy4  db 'N'          ;Show ('Y' or 'N')
        db 1            ;Type of enemy
        db 2 dup (0)    ;position
        db ?            ;state
        db ?            ;HP
        db ?            ;walk state
        db ?            ;walk way                       
        db ?            ;level      
enemy5  db 'N'          ;Show ('Y' or 'N')
        db 1            ;Type of enemy
        db 2 dup (0)    ;position
        db ?            ;state
        db ?            ;HP
        db ?            ;walk state
        db ?            ;walk way                       
        db ?            ;level      
enemy6  db 'N'          ;Show ('Y' or 'N')
        db 1            ;Type of enemy
        db 2 dup (0)    ;position
        db ?            ;state
        db ?            ;HP
        db ?            ;walk state
        db ?            ;walk way                       
        db ?            ;level
;====Boss variable ==============
boss    db 5,5          ;Position of boss  0,1
bhc     dw 3            ;boss hit count    3
        db 1            ;Walk state        4
        db ?            ;walk way          5
        db 15 dup (0)   ;boss attribute
;====Program Variable============
                db      2 dup (?)
map_buff        db      100 dup (100 dup (?))    ; 9 Kbyte of all map buffer
                db      2 dup (?)
sc_buff         db      20 dup (20 dup (?))      ; screen buffer in array mode
cave1_file      db      'cave1.map',0
cave2_file      db      'cave2.map',0
cave3_file      db      'cave3.map',0
cave4_file      db      'cave4.map',0
bosscave_file   db      'bosscave.map',0
forest_file     db      'forest.map',0
file_handle     db      ?    ;file handle use when open file
read_buff       db      500 dup (0)  ;buffer to keep the thing from read a file
xcord           dw      ?    ;pass patameter for draw_pic
ycord           dw      ?    ;pass patameter for draw_pic
xpix            db      ?    ;use in draw_pic
ypix            db      ?    ;use in draw_pic
text_colsave    db      ?
pos_save        db      2 dup (0)
cecil_pos       db      2 dup (0)
first_read      db      'T'  ;Flag to check the file is 1st read
eight_way       db      9 dup (0)
enemy_level     db      1    ;The enemy level in that each screen
game_speed      db      ?
boss_flag       db      'N'
enter_boss      db      'N'
hp_tag          db      'HP.$'
slash_tag       db      '/$'
level_tag       db      'LV.$'
hit_tag         db      'Hit $'
die_tag         db      'DIE!$'
get_level       db      'Gain LEVEL!$'
recover_tag     db      'HP Recover$'
sign_tag        db      'Recovery Spring Inside.$'
game_name       db      'Monster Park!          $'
no_event        db      'Nothing.$'
enemy_gain      db      'enemy level up to LV.6$'
over_tag        db      'GAME OVER$'
num_buff        db      3 dup (0)
                db      '$'
;====Error Message===============
error_flag      db      ?
error_mesg      db      'Map file not found!$'
include   data.asm
data_seg        ends

dummy_seg       segment
du      db      3000 dup (0)
dummy_seg       ends

logo_seg        segment
include         logo.asm
logo_seg        ends


;****************************************************************************
;Begin of the DEMO program
;****************************************************************************

Code_seg        segment  public  'code'
                assume  cs:Code_seg,ds:Data_seg
;=====MACRO SECTION====================
random          macro   number
                push    cx
                push    dx
                mov     ah,02ch
                int     21h
                mov     al,dl
                and     ax,number
                pop     dx
                pop     cx
                endm
readkey         macro
                push    ax
                mov     ah,10h
                int     16h
                pop     ax
                endm
delay           macro   count
                local  delay_ag
                local  in_delay
                push    ax
                push    cx
                mov     cx,0ffffh
   delay_ag:    push    cx
                mov     cx,count
   in_delay:    inc     ax
                loop    in_delay
                pop     cx
                loop    delay_ag
                pop     cx
                pop     ax
                endm
                
;=====ENDM SECTION=====================
main            proc    far
                mov     ax,Data_seg
                mov     ds,ax
                call    go_graphic
                lea     si,old_palate
                call    save_pal
                lea     si,new_palate
                call    set_pal
start_prog:
                call    intro
                mov     ah,10h
                int     16h
                push    ax
                call    fade_out
                call    intro2
                mov     ah,10h
                int     16h
                mov     dl,255
                cmp     al,'f'
                jne     slow_speed
                mov     dl,20
    slow_speed: mov     game_speed,dl
                call    fade_out
                mov     dh,0
                mov     dl,72
                pop     ax
                cmp     ah,04fh
                je      first_view
                cmp     ah,050h
                je      second_view
                cmp     ah,051h
                je      third_view
                jmp     first_load
 first_view:    mov     dh,60
                mov     dl,72
                jmp     first_load
 second_view:   mov     dh,40
                mov     dl,48
                jmp     first_load
 third_view:    mov     dh,0
                mov     dl,12
                jmp     first_load
 first_load:    mov     al,0
                mov     error_flag,al
                push    dx
                mov     dx,offset forest_file
                call    load_map
                pop     dx
                mov     al,error_flag
                cmp     al,1
                jne     no_error
                jmp     end_prog
 no_error:      call    map2vtscr
                call    waitretrace
                call    vtscr2real
                mov     si,offset cecil
                mov     dl,10
                mov     [si],dl         ;Set 1st COL position
                mov     dl,9
                mov     [si+1],dl       ;Set 1st ROW position
                mov     dl,50
                mov     max_hp,dl       ;Set 1st HP 
                mov     [si+2],dl
                mov     dx,0            ;Set 1st EXP
                mov     [si+11],dx
                mov     dl,1
                mov     [si+3],dl       ;Set 1st LEVEL
                mov     dl,'N'
                mov     [si+4],dl       ;Set 1st face of cecil
                mov     dl,'N'
                mov     cecil_dmode,dl
                mov     al,3
                mov     enemy_level,al  ;Set first enemy level
start_loop:     call    enemy_proc
                mov     ch,0
                mov     cl,game_speed
  player:       call    player_proc
                loop    player
                mov     si,offset cecil
                mov     al,[si+10]
                cmp     al,'E'
                jne     next_return
                jmp     end_prog
  next_return:  cmp     al,'D'
                jne     next_return2
                jmp     end_prog
  next_return2: cmp     al,'C'
                je      in_cave
                cmp     al,'B'
                je      boss_cave
                jmp     start_loop
in_cave:        call    load_cave
                call    reset_enemy
cave_loop:      call    player_proc
                mov     si,offset cecil
                mov     al,[si+10]
                cmp     al,'O'
                je      out_cave
                cmp     al,'E'
                jne     cave_loop
                jmp     end_prog
out_cave:       call    load_forest
                jmp     start_loop
boss_cave:      mov     al,10
                mov     enemy_level,al
                call    load_cave
                mov     si,offset cecil
                mov     al,[si+1]
                mov     al,10
                mov     [si+1],al
                mov     si,offset where_way
                readkey
                call    text_on
                mov     ch,4
                mov     cl,19
                mov     bx,15
                call    print_delay
                readkey
                call    text_off
                mov     si,offset enemy_lvup
                call    text_on
                mov     ch,4
                mov     cl,19
                mov     bx,15
                call    print_delay
                readkey
                call    text_off
in_bosscave:    mov     si,offset sc_buff
                mov     ah,[si-2]
                mov     al,[si-1]
                cmp     ah,40
                jne     no_boss
                cmp     al,24
                jne     no_boss
                jmp     boss_loop
    no_boss:    call    enemy_proc
                mov     ch,0
                mov     cl,game_speed
     player2:   call    player_proc
                loop    player2
                mov     si,offset cecil
                mov     al,[si+10]
                cmp     al,'E'
                jne     next_check1
                jmp     end_prog
  next_check1:  cmp     al,'D'
                jne     next_check2
                jmp     game_over
  next_check2:  jmp     in_bosscave
   boss_loop:   mov     si,offset found_boss
                call    text_on
                mov     ch,4
                mov     cl,19
                mov     bx,15
                call    print_delay
                readkey
                call    text_off
                mov     si,offset how_kill
                call    text_on
                mov     ch,4
                mov     cl,19
                mov     bx,15
                call    print_delay
                readkey
                call    text_off
                mov     al,'Y'
                mov     enter_boss,al
                mov     ax,20
                mov     si,offset boss
                mov     [si+2],ax
   b_loop:      call    reset_enemy
                call    boss_proc
                mov     cl,game_speed
                add     cx,100
   p_boss:      call    player_proc
                call    check_bosshit
                loop    p_boss
                mov     si,offset cecil
                mov     al,[si+10]
                cmp     al,'E'
                je      end_prog
                cmp     al,'D'
                je      game_over
                cmp     al,'F'
                je      boss_boom
                jmp     b_loop
                readkey
  boss_boom:    call    clear_bossd
                call    fade_out
                mov     si,offset fin_mesg
                mov     ch,0
                mov     cl,5
                call    print_delay
                readkey
                call    fade_out
game_over:      mov     dx,255
                call    fill_color
                mov     ch,15
                mov     cl,12
                mov     bx,15
                mov     si,offset over_tag
                call    print_delay
                readkey
end_prog:       call    fade_out
                lea     si,old_palate
                call    restore_pal
                call    go_text
                mov     ax,4c00h
                int     21h
main            endp

;****************************************************************************
;Procedure Section
;****************************************************************************
;***Procedure List***
;  waitretrace ==> wait for the verticle retrace
;  go_graphic ==> goto graphic mode 13h (no pass)
;  go_text    ==> goto text mode 3h (no pass)
;  readkey    ==> wait until keypress (return AH=ascii,AL=scancode)
;  fill_color ==> fill color in full screen (DX=color)
;  plot_pixel ==> put color pixel in screen (AX,BX=X,Y DX=Color)
;  draw_pic   ==> Draw picture at (X,Y) (xcord=X ycord=Y SI=picture)
;  draw_array ==> Draw picture in screen array(20x10) (SI=pic dh,dl=col,row)
;  scroll_up  ==> Scroll the screen up 2 pixel (no pass)
;  scroll_down ==> Scroll the screen down 2 pixel
;  scroll_left ==> Scroll the screen left 2 pixel
;  scroll_right ==> Scroll the screen right 2 pixel
;  load_map   ==> Load map file to map buffer (DX=path)
;  map2vtscr  ==> dump map buffer to screen buffer (dh,dl=col,row of bigmap)
;  vtscr2real ==> show the screen buffer to real screen
;  save_pal   ==> Save windows system palate
;  restore_pal ==> Restore windows system palate
;  set_pal    ==> Set use palate
;  Draw_cecil ==> Draw player in all movement (use parameter in var name 'cecil')
;  w_up       ==> Move Cecil Up
;  w_down     ==> Move Cecil Down
;  w_left     ==> Move Cecil Left
;  w_right    ==> Move Cecil Right
;  get_attribute ==> Get map attribute where cecil is stand.
;  player_proc ==> Player Control part
;***Procedure List***

load_cave       proc    near
                push    ax
                push    bx
                push    dx
                push    si
                mov     al,'T'
                mov     first_read,al
                mov     si,offset sc_buff
                mov     bx,offset pos_save
                mov     al,[si-2]
                mov     [bx],al
                mov     al,[si-1]
                mov     [bx+1],al
                mov     si,offset cecil
                mov     bx,offset cecil_pos
                mov     al,[si]
                mov     [bx],al
                mov     al,[si+1]
                mov     [bx+1],al
                mov     si,offset sc_buff
                call    clear_mapbuff
                mov     ah,[si-2]
                mov     al,[si-1]
                cmp     ah,40
                jne     next_cave
                cmp     al,72
                jne     next_cave
                lea     dx,cave1_file
                call    load_map
                jmp     put_cecil
 next_cave:     cmp     ah,40
                jne     next_cave2
                cmp     al,48
                jne     next_cave2
                lea     dx,cave2_file
                call    load_map
                jmp     put_cecil
 next_cave2:    cmp     ah,0
                jne     next_cave3
                cmp     al,36
                jne     next_cave3
                lea     dx,cave3_file
                call    load_map
                jmp     put_cecil
 next_cave3:    cmp     ah,20
                jne     next_cave4
                cmp     al,12
                jne     next_cave4
                lea     dx,cave4_file
                call    load_map
                jmp     put_cecil
 next_cave4:    cmp     ah,0
                jne     next_cave5
                cmp     al,12
                jne     next_cave5
                lea     dx,bosscave_file
                call    load_map
                jmp     put_cecil
 next_cave5:
 put_cecil:     mov     si,offset cecil
                mov     al,[si+10]
                cmp     al,'B'
                je      put_onboss
                mov     al,11
                mov     dx,0
                jmp     put
put_onboss:     mov     dh,0
                mov     dl,24
                mov     al,10
       put:     mov     [si+1],al
                call    map2vtscr
                call    vtscr2real
                call    draw_cecil
                pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
load_cave       endp

load_forest     proc    near
                push    ax
                push    dx
                push    si
                mov     al,'T'
                mov     first_read,al
                mov     si,offset map_buff
                call    clear_mapbuff
                mov     dx,offset forest_file
                call    load_map
                mov     si,offset pos_save
                mov     dh,[si]
                mov     dl,[si+1]
                mov     si,offset cecil_pos
                mov     ah,[si]
                mov     al,[si+1]
                mov     si,offset cecil
                mov     [si],ah
                mov     [si+1],al
                call    map2vtscr
                call    vtscr2real
                pop     si
                pop     dx
                pop     ax
                ret
load_forest     endp

clear_mapbuff   proc    near
                push    ax
                push    cx
                push    si
                mov     cx,10000
                mov     si,offset map_buff
                mov     al,0
 clear_map:     mov     [si],al
                inc     si
                loop    clear_map
                pop     si
                pop     cx
                pop     ax
                ret
clear_mapbuff   endp

clear_kbuff     proc    near
                push    ax
                push    dx
                mov     ax,0c06h
                mov     dl,0ffh
                int     21h
                pop     dx
                pop     ax
                ret
clear_kbuff     endp


waitretrace     proc    near
                push    ax
                push    dx
                mov     dx,3dah
        l1:     in      al,dx
                and     al,08h
                jnz     l1
        l2:     in      al,dx
                and     al,08h
                jz      l2
                pop     dx
                pop     ax
                ret
waitretrace     endp

go_graphic      proc    near       ;go to graphic mode 13h
                push    ax
                mov     ax,13h
                int     10h
                pop     ax
                ret
go_graphic      endp

go_text         proc    near        ;go to text mode 3h
                push    ax
                mov     ax,3
                int     10h
                pop     ax
                ret
go_text         endp

open_file       proc    near       ;pathname in dx
                                   ;attribute in al
                mov     ax,03d00h
                int     21h
                ret
open_file       endp

close_file      proc    near      ;file handle at bx
                push    ax
                mov     ah,03eh
                int     21h
                pop     ax
                ret
close_file      endp

read_file       proc    near
                mov     ax,03f00h
                int     21h
                ret
read_file       endp

set_csr         proc    near
                push    ax
                push    bx
                push    dx
                mov     bx,0
                mov     ah,2
                mov     dh,cl
                mov     dl,ch
                int     10h
                pop     dx
                pop     bx
                pop     ax
                ret
set_csr         endp

save_pal        proc    near       ;SI=offset palate to dump
                push    ax
                push    cx
                push    dx
                push    si
                mov     cx,255
   re_save:     mov     dx,03c7h
                mov     al,cl
                out     dx,al
                mov     dx,03c9h
                in      al,dx
                mov     [si],al
                inc     si
                in      al,dx
                mov     [si],al
                inc     si
                in      al,dx
                mov     [si],al
                inc     si
                loop    re_save
                pop     si
                pop     dx
                pop     cx
                pop     ax
                ret
save_pal        endp

restore_pal     proc    near      ;SI=palate to restore
                push    ax
                push    cx
                push    dx
                push    si
                call    waitretrace
                mov     cx,255
   restore:     mov     dx,03c8h
                mov     al,cl
                out     dx,al
                mov     dx,03c9h
                mov     al,[si]
                out     dx,al
                inc     si
                mov     al,[si]
                out     dx,al
                inc     si
                mov     al,[si]
                out     dx,al
                inc     si
                loop    restore
                pop     si
                pop     dx
                pop     cx
                pop     ax
                ret
restore_pal     endp

set_pal         proc    near         ;SI with palate table
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                call    waitretrace
                xor     ax,ax
                xor     bx,bx
                xor     cx,cx
                mov     bl,4
                mov     cl,[si]
                inc     si
   re_setpal:   mov     dx,03c8h
                mov     al,[si]
                out     dx,al
                inc     si
                mov     dx,03c9h
                mov     al,[si]
                div     bl
                out     dx,al
                inc     si
                mov     al,[si]
                div     bl
                out     dx,al
                inc     si
                mov     al,[si]
                div     bl
                out     dx,al
                inc     si
                loop    re_setpal
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
set_pal         endp

fill_color      proc    near         ;Put color on full screen
                push    cx           ;dx is color index
                push    bx
                mov     ax,0a000h
                mov     es,ax
                mov     cx,64000
                mov     bx,0
    fillagain:  mov     es:[bx],dx                     
                inc     bx
                loop    fillagain
                pop     bx
                pop     cx
                ret
fill_color      endp

fade_out        proc    near
                push    ax
                push    cx
                push    si
                mov     cx,64
  next_palate:  push    cx
                mov     cx,255
                lea     si,temp_palate
                call    save_pal
    next_r:     mov     al,[si]
                cmp     al,0
                je      next_g
                dec     al
                mov     [si],al
    next_g:     inc     si
                mov     al,[si]
                cmp     al,0
                je      next_b
                dec     al
                mov     [si],al
    next_b:     inc     si
                mov     al,[si]
                cmp     al,0
                je      next_color
                dec     al
                mov     [si],al
  next_color:   inc     si
                loop    next_r
                lea     si,temp_palate
                call    restore_pal
                delay   5
                pop     cx
                loop    next_palate
                mov     dx,255
                call    fill_color
                lea     si,old_palate
                call    restore_pal
                lea     si,new_palate
                call    set_pal
                pop     si
                pop     cx
                pop     ax
                ret
fade_out        endp

plot_pixel      proc    near     ;ax,bx = X and Y dx=color(index)
                push    ax
                push    bx
                push    cx
                mov     cx,bx
                shl     bx,8
                shl     cx,6
                add     bx,cx
                add     bx,ax
                mov     es:[bx],dl
                pop     cx
                pop     bx
                pop     ax
                ret
plot_pixel      endp

draw_pic        proc    near        ;xcord,ycord = X and Y
                push    ax          ;SI = pic
                push    bx
                push    cx
                push    dx
                push    si
                mov     ax,0a000h
                mov     es,ax
                mov     dl,[si-2]
                mov     xpix,dl
                mov     dl,[si-1]
                mov     ypix,dl
                xor     cx,cx
                xor     dx,dx
                mov     ax,xcord
                mov     bx,ycord
                mov     cl,ypix
    outloop:    push    cx
                mov     cl,xpix
     inloop:    mov     dl,[si]
                cmp     dl,0
                je      skip_pixel
                call    plot_pixel
skip_pixel:     inc     si
                inc     ax
                loop    inloop
                pop     cx
                inc     bx
                mov     ax,xcord
                loop    outloop
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
draw_pic        endp

text_on         proc    near
                push    ax
                push    dx
                push    si
                push    es
                mov     ax,0a000h
                mov     es,ax
                mov     si,offset text_dump
                mov     cx,15360
                mov     bx,46080
  next_pixel:   mov     dl,es:[bx]
                mov     [si],dl
                inc     si
                inc     bx
                loop    next_pixel
                pop     es
                mov     dh,0
                mov     dl,11
                mov     cx,20
                mov     bl,'x'
     finrow1:   call    draw_block
                inc     dh
                loop    finrow1
                delay   60
                mov     dx,10
                mov     cx,20
     finrow2:   call    draw_block
                inc     dh
                loop    finrow2
                delay   60
                mov     dx,9
                mov     cx,20
     finrow3:   call    draw_block
                inc     dh
                loop    finrow3
                pop     si
                pop     dx
                pop     ax
                ret
text_on         endp

text_on_nd      proc    near
                push    ax
                push    dx
                push    si
                push    es
                mov     ax,0a000h
                mov     es,ax
                mov     si,offset text_dump
                mov     cx,15360
                mov     bx,46080
  next_pixel2:  mov     dl,es:[bx]
                mov     [si],dl
                inc     si
                inc     bx
                loop    next_pixel
                pop     es
                mov     dh,0
                mov     dl,11
                mov     cx,20
                mov     bl,'x'
     finrow4:   call    draw_block
                inc     dh
                loop    finrow4
                mov     dx,10
                mov     cx,20
     finrow5:   call    draw_block
                inc     dh
                loop    finrow5
                mov     dx,9
                mov     cx,20
     finrow6:   call    draw_block
                inc     dh
                loop    finrow6
                pop     si
                pop     dx
                pop     ax
                ret
text_on_nd      endp

text_off        proc    near
                push    ax
                push    bx
                push    cx
                push    dx
                push    es
                mov     ax,0a000h
                mov     es,ax
                mov     si,offset text_dump
                mov     cx,15360
                mov     bx,46080
  next_pixel3:  mov     dl,[si]
                mov     es:[bx],dl
                inc     si
                inc     bx
                loop    next_pixel3
                pop     es
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
text_off        endp

scroll_up       proc    near
                push    es
                push    ds
                push    bx
                push    cx
                push    dx
                push    di
                mov     bx,0a000h
                mov     es,bx
                mov     ds,bx
                cld
                mov     cx,31840
                mov     di,0
                mov     si,320
                rep     movsw
                pop     di
                pop     dx
                pop     cx
                pop     bx
                pop     ds
                pop     es
                ret
scroll_up       endp

scroll_down     proc    near
                push    es
                push    bx
                push    cx
                push    dx
                push    di
                mov     bx,0a000h
                mov     es,bx
                mov     cx,62720
                mov     si,62720
                mov     di,64000
down:           mov     dx,es:[si]
                mov     es:[di],dx
                dec     si
                dec     di
                dec     si
                dec     di
                loop    down
                pop     di
                pop     dx
                pop     cx
                pop     bx
                pop     es
                ret
scroll_down     endp

scroll_left     proc    near
                push    ax
                push    bx
                push    cx
                push    dx
                push    es
                mov     ax,0a000h
                mov     es,ax
                mov     bx,2
                mov     cx,200
row_left:       push    cx
                mov     cx,160
                mov     ax,bx           ;save BX
col_left:       mov     dx,es:[bx]
                mov     es:[bx-2],dx
                inc     bx
                inc     bx
                loop    col_left
                pop     cx
                mov     bx,ax
                add     bx,320
                loop    row_left
                pop     es
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
scroll_left     endp

scroll_right    proc    near
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    es
                mov     ax,0a000h
                mov     es,ax
                mov     bx,2
                mov     cx,200
row_right:      push    cx
                mov     cx,160
                mov     ax,bx           ;save BX
                mov     dx,es:[bx-2]
col_right:      mov     si,es:[bx]
                mov     es:[bx],dx
                mov     dx,si
                inc     bx
                inc     bx
                loop    col_right
                pop     cx
                mov     bx,ax
                add     bx,320
                loop    row_right
                pop     es
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
scroll_right    endp

load_map        proc    near   ;DX=file name
                push    ax
                push    bx
                push    cx
                push    dx
                call    open_file
                jnc     pass_open
                jmp     error_open
    pass_open:  mov     file_handle,al
    ;ready to read file
                mov     bx,ax
                lea     di,map_buff
    read_again: mov     cx,500
                lea     dx,read_buff
                call    read_file
                cmp     ax,0
                je      end_load
                lea     si,read_buff
                cmp     first_read,'T'
                jne     loop_read
     trans1:    mov     al,[si]
                sub     al,48
                mov     dl,10
                mul     dl
                inc     si
                mov     dl,[si]
                sub     dl,48
                add     al,dl
                mov     [di-2],al
                inc     si
                inc     si
     trans2:    mov     al,[si]
                sub     al,48
                mov     dl,10
                mul     dl
                inc     si
                mov     dl,[si]
                sub     dl,48
                add     al,dl
                mov     [di-1],al
                inc     si
                inc     si
                inc     si
                lea     di,map_buff
   loop_read:   mov     al,first_read
                cmp     al,'T'
                jne     go_trans
                sub     cx,7
   go_trans:    mov     al,[si]
                cmp     al,0ah
                je      no_trans
                cmp     al,0dh
                je      no_trans
                cmp     al,'-'
                je      no_trans
                cmp     al,'|'
                je      no_trans
                mov     [di],al
                inc     di
   no_trans:    inc     si
                loop    go_trans
                mov     al,'F'
                mov     first_read,al
                jmp     read_again
   end_load:    xor     bx,bx
                mov     bl,file_handle
                call    close_file
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
   error_open:  cmp     ax,2
                jne     end_load
                mov     ah,59h
                int     21h
                lea     dx,error_mesg
                mov     ah,9
                int     21h
                mov     al,1
                mov     error_flag,al
                readkey
                jmp     end_load
load_map        endp

map2vtscr       proc    near    ;dh,dl = col,row
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                push    es
                mov     ax,ds
                mov     es,ax
                xor     ax,ax
                xor     bx,bx
                lea     si,map_buff
                lea     di,sc_buff
                mov     [di-2],dh
                mov     [di-1],dl
                mov     al,[si-2]
                mov     bl,al      ;bl=map_col
                mul     dl
                add     al,dh
                add     si,ax
                mov     cx,12
    mov_map:    push    cx
                mov     cx,20
                rep     movsb
                pop     cx
                add     si,bx
                sub     si,20
                loop    mov_map
                pop     es
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
map2vtscr       endp

vtscr2real      proc    near
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                lea     di,sc_buff
                mov     dx,0
                mov     cx,12
   next_row_bl: push    cx
                mov     cx,20
    next_block: mov     bl,[di]
                call    draw_block
                inc     dh
                inc     di
                loop    next_block
                mov     dh,0
                inc     dl
                pop     cx
                loop    next_row_bl
   end_dump:    pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                ret
vtscr2real      endp

draw_array      proc    near         ;dh,dl is col,row of screen array
                push    ax
                push    bx
                push    dx
                xor     ax,ax
                xor     bx,bx
                mov     al,dh
                mov     bl,dl
                mov     dx,16
                mul     dx
                mov     xcord,ax
                mov     ax,bx
                mov     bx,16
                mul     bx
                mov     ycord,ax
                call    draw_pic
                pop     dx
                pop     bx
                pop     ax
                ret
draw_array      endp

draw_block      proc    near           ;input is bl = block attribute
                push    si
                cmp     bl,'T'
                je      draw_tree
                cmp     bl,'t'
                je      draw_tor1
                cmp     bl,'G'
                je      draw_grass
                cmp     bl,'s'
                je      draw_shadow1
                cmp     bl,'S'
                je      draw_shadow2
                cmp     bl,'L'
                je      draw_leaf
                cmp     bl,'F'
                je      draw_flower
                cmp     bl,'C'
                je      draw_cliff
                cmp     bl,'Ú'
                je      draw_trcliff
                cmp     bl,'À'
                je      draw_lrcliff
                cmp     bl,'¿'
                je      draw_tlcliff
                cmp     bl,'Ù'
                je      draw_llcliff
                cmp     bl,'^'
                je      draw_tcliff
                cmp     bl,'V'
                je      draw_vain
                cmp     bl,'N'
                je      draw_sign
                cmp     bl,'U'
                je      draw_cave
                jmp     next_symbol
  draw_leaf:    jmp     d_leaf
  draw_flower:  jmp     d_flower
  draw_cliff:   jmp     d_cliff
  draw_trcliff: jmp     d_trcliff
  draw_lrcliff: jmp     d_lrcliff
  draw_tlcliff: jmp     d_tlcliff
  draw_llcliff: jmp     d_llcliff
  draw_tcliff:  jmp     d_tcliff
  draw_cave:    jmp     d_cave
  draw_vain:    jmp     d_vain
  draw_sign:    jmp     d_sign
  draw_tree:    lea     si,tree
                call    draw_array
                jmp     fin_bl
  draw_tor1:    lea     si,tor1
                call    draw_array
                jmp     fin_bl
  draw_grass:   lea     si,grass
                call    draw_array
                jmp     fin_bl
  draw_shadow1: lea     si,shadow1
                call    draw_array
                jmp     fin_bl
  draw_shadow2: lea     si,shadow2
                call    draw_array
                jmp     fin_bl
     d_leaf:    lea     si,leaf
                call    draw_array
                jmp     fin_bl
     d_flower:  lea     si,flower
                call    draw_array
                jmp     fin_bl
     d_cliff:   lea     si,cliff
                call    draw_array
                jmp     fin_bl
     d_trcliff: lea     si,trcliff
                call    draw_array
                jmp     fin_bl
     d_tlcliff: lea     si,tlcliff
                call    draw_array
                jmp     fin_bl
     d_llcliff: lea     si,llcliff
                call    draw_array
                jmp     fin_bl
     d_lrcliff: lea     si,lrcliff
                call    draw_array
                jmp     fin_bl
     d_tcliff:  lea     si,tcliff
                call    draw_array
                jmp     fin_bl
     d_vain:    lea     si,vain
                call    draw_array
                jmp     fin_bl
                jmp     fin_bl
     d_cave:    lea     si,cave
                call    draw_array
                jmp     fin_bl
  draw_gcave:   lea     si,g_cave
                call    draw_array
                jmp     fin_bl
  draw_tcave:   lea     si,t_cave
                call    draw_array
                jmp     fin_bl
  draw_wcave:   lea     si,w_cave
                call    draw_array
                jmp     fin_bl
  draw_bblock:  lea     si,b_block
                call    draw_array
                jmp     fin_bl
  draw_water:   lea     si,water
                call    draw_array
                jmp     fin_bl
  draw_ocave:   lea     si,o_cave
                call    draw_array
                jmp     fin_bl
     d_sign:    lea     si,sign
                call    draw_array
  fin_bl:       pop     si
                ret
   next_symbol: cmp     bl,'P'
                je      draw_gcave
                cmp     bl,'1'
                je      d_sign
                cmp     bl,'A'
                je      draw_tcave
                cmp     bl,'a'
                je      draw_wcave
                cmp     bl,'W'
                je      draw_water
                cmp     bl,'x'
                je      draw_bblock
                cmp     bl,'O'
                je      draw_ocave
                cmp     bl,'w'
                je      draw_water
                jmp     fin_bl
draw_block      endp

map_up          proc    near
                push    dx
                push    si
                mov     si,offset sc_buff
                mov     dh,[si-2]
                mov     dl,[si-1]
                mov     cx,12
map_up_ag:      dec     dl
                call    map2vtscr
                call    vtscr2real
                delay   30
                loop    map_up_ag
                pop     si
                pop     dx
                ret
map_up          endp

map_down        proc    near
                push    dx
                push    si
                mov     si,offset sc_buff
                mov     dh,[si-2]
                mov     dl,[si-1]
                mov     cx,12
map_down_ag:    inc     dl
                call    map2vtscr
                call    vtscr2real
                delay   30
                loop    map_down_ag
                pop     si
                pop     dx
                ret
map_down        endp

map_left        proc    near
                push    dx
                push    si
                mov     si,offset sc_buff
                mov     dh,[si-2]
                mov     dl,[si-1]
                mov     cx,20
map_left_ag:    dec     dh
                call    map2vtscr
                call    vtscr2real
                delay   30
                loop    map_left_ag
                pop     si
                pop     dx
                ret
map_left        endp

map_right       proc    near
                push    dx
                push    si
                mov     si,offset sc_buff
                mov     dh,[si-2]
                mov     dl,[si-1]
                mov     cx,20
map_right_ag:   inc     dh
                call    map2vtscr
                call    vtscr2real
                delay   30
                loop    map_right_ag
                pop     si
                pop     dx
                ret
map_right       endp

eight_way_atbr  proc    near      ;DH,DL=col,row of map
                push    ax
                push    dx
                push    si
                push    di
                mov     si,offset sc_buff
                mov     di,offset eight_way
                mov     ax,20
                mul     dl
                mov     dl,dh
                mov     dh,0
                add     ax,dx
                add     si,ax
                mov     al,[si-21]
                mov     [di],al
                mov     al,[si-20]
                mov     [di+1],al
                mov     al,[si-19]
                mov     [di+2],al
                mov     al,[si-1]
                mov     [di+3],al
                mov     al,[si]
                mov     [di+4],al
                mov     al,[si+1]
                mov     [di+5],al
                mov     al,[si+19]
                mov     [di+6],al
                mov     al,[si+20]
                mov     [di+7],al
                mov     al,[si+21]
                mov     [di+8],al
                pop     di
                pop     si
                pop     dx
                pop     ax
                ret
eight_way_atbr  endp

draw_cecil      proc    near
                push    ax
                push    bx
                push    dx
                push    si
                mov     si,offset cecil
                mov     dh,[si]
                mov     dl,[si+1]
                mov     al,[si-1]
                cmp     al,'S'
                je      draw_smode
   draw_nmode:  mov     al,[si+4]
                cmp     al,'N'
                je      stand_up
                cmp     al,'E'
                je      stand_right
                cmp     al,'S'
                je      stand_down
                cmp     al,'W'
                je      stand_left
                jmp     end_dcecil
   stand_up:    mov     si,offset c_up1
                call    draw_array
                jmp     end_dcecil
   stand_down:  mov     si,offset c_down1
                call    draw_array
                jmp     end_dcecil
   stand_left:  mov     si,offset c_left1
                call    draw_array
                jmp     end_dcecil
   stand_right: mov     si,offset c_right1
                call    draw_array
                jmp     end_dcecil
   draw_smode:  mov     bx,16
                mov     ah,0
                mov     al,dh
                mul     bl
                mov     xcord,ax
                mov     ah,0
                mov     al,dl
                mul     bx
                mov     ycord,ax
                mov     al,[si+4]
                cmp     al,'N'
                je      stand_up2
                cmp     al,'E'
                je      stand_right2
                cmp     al,'S'
                je      stand_down2
                cmp     al,'W'
                je      stand_left2
                jmp     end_dcecil
   stand_up2:   mov     ax,ycord
                sub     ax,8
                mov     ycord,ax
                mov     si,offset c_up2
                call    draw_pic
                jmp     end_dcecil
   stand_down2: mov     ax,ycord
                add     ax,8
                mov     ycord,ax
                mov     si,offset c_down2
                call    draw_pic
                jmp     end_dcecil
   stand_left2: mov     ax,xcord
                sub     ax,8
                mov     xcord,ax
                mov     si,offset c_left2
                call    draw_pic
                jmp     end_dcecil
  stand_right2: mov     ax,xcord
                add     ax,8
                mov     xcord,ax
                mov     si,offset c_right2
                call    draw_pic
  end_dcecil:   pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
draw_cecil      endp

get_attribute   proc    near
                push    ax
                push    dx
                push    si
                push    di
                mov     si,offset cecil
                mov     di,offset sc_buff
                xor     dx,dx
                mov     dl,[si+1]
                mov     ax,20
                mul     dl
                mov     dl,[si]
                add     al,dl
                add     di,ax     ;Put DI point at sc_buff position
                mov     al,[di-20]
                mov     [si+6],al
                mov     al,[di-1]
                mov     [si+8],al
                mov     al,[di]
                mov     [si+5],al
                mov     al,[di+1]
                mov     [si+7],al
                mov     al,[di+20]
                mov     [si+9],al
                pop     di
                pop     si
                pop     dx
                pop     ax
                ret
get_attribute   endp

w_up            proc    near
                push    ax
                push    bx
                push    dx
                mov     dl,[si+1]
                cmp     dl,0
                je      scroll_mapup
                call    get_attribute
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     al,'N'
                mov     [si+4],al
                mov     dl,[si+6]
                cmp     dl,'G'
                je      can_walkup
                cmp     dl,'V'
                je      can_walkup
                cmp     dl,'s'
                je      can_walkup
                cmp     dl,'S'
                je      can_walkup
                cmp     dl,'F'
                je      can_walkup
                cmp     dl,'P'
                je      can_walkup
                cmp     dl,'U'
                je      can_walkup
                cmp     dl,'x'
                je      can_walkup
                jmp     cant_walkup
scroll_mapup:   jmp     mapup
can_walkup:     call    draw_cecil
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     al,'N'
                mov     [si+4],al
                mov     al,'S'
                mov     cecil_dmode,al
                call    draw_cecil
                delay   30
                mov     bl,[si+5]
                call    draw_block
                mov     bl,[si+6]
                dec     dl
                call    draw_block
                mov     al,[si+1]
                dec     al
                mov     [si+1],al
                mov     al,'N'
                mov     cecil_dmode,al
                call    draw_cecil
                call    clear_kbuff
                call    get_attribute
                mov     al,[si+5]
                cmp     al,'U'
                je      event_hap1
                cmp     al,'x'
                je      event_hap2
                jmp     cant_walkup
cant_walkup:    pop     dx
                pop     bx
                pop     ax
                ret
  event_hap1:   mov     si,offset cecil
                mov     dl,'C'
                mov     [si+10],dl
                jmp     cant_walkup
  event_hap2:   mov     si,offset cecil
                mov     dl,'B'
                mov     [si+10],dl
                jmp     cant_walkup
   mapup:       call    get_attribute
                mov     si,offset cecil
                mov     al,[si+5]
                cmp     al,'U'
                je      event_hap1
                call    map_up
                mov     dl,11
                mov     [si+1],dl
                call    draw_cecil
                call    gen_enemy
                pop     dx
                pop     bx
                pop     ax
                ret
w_up            endp

w_down          proc    near
                push    ax
                push    bx
                push    dx
                mov     dl,[si+1]
                cmp     dl,11
                je      scroll_mapdown
                call    get_attribute
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     al,'S'
                mov     [si+4],al
                mov     dl,[si+9]
                cmp     dl,'G'
                je      can_walkdown
                cmp     dl,'V'
                je      can_walkdown
                cmp     dl,'s'
                je      can_walkdown
                cmp     dl,'S'
                je      can_walkdown
                cmp     dl,'F'
                je      can_walkdown
                cmp     dl,'P'
                je      can_walkdown
                cmp     dl,'O'
                je      can_walkdown
                jmp     cant_walkdown
scroll_mapdown: jmp     mapdown
can_walkdown:   call    draw_cecil
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     al,'S'
                mov     [si+4],al
                mov     al,'S'
                mov     cecil_dmode,al
                call    draw_cecil
                delay   30
                mov     bl,[si+5]
                call    draw_block
                mov     bl,[si+9]
                inc     dl
                call    draw_block
                mov     al,[si+1]
                inc     al
                mov     [si+1],al
                mov     al,'N'
                mov     cecil_dmode,al
                call    draw_cecil
                call    clear_kbuff
                call    get_attribute
                mov     al,[si+5]
                cmp     al,'O'
                je      go_outcave
cant_walkdown:  pop     dx
                pop     bx
                pop     ax
                ret
   go_outcave:  mov     si,offset cecil
                mov     al,'O'
                mov     [si+10],al
                jmp     cant_walkdown
   mapdown:     call    get_attribute
                mov     si,offset cecil
                mov     al,[si+5]
                cmp     al,'O'
                je      go_outcave
                call    map_down
                mov     dl,0
                mov     [si+1],dl
                call    draw_cecil
                call    gen_enemy
                pop     dx
                pop     bx
                pop     ax
                ret
w_down          endp

w_left          proc    near
                push    ax
                push    bx
                push    dx
                mov     dl,[si]
                cmp     dl,0
                je      sc_mapleft
                call    get_attribute
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     al,'W'
                mov     [si+4],al
                mov     dl,[si+8]
                cmp     dl,'G'
                je      can_walkleft
                cmp     dl,'s'
                je      can_walkleft
                cmp     dl,'S'
                je      can_walkleft
                cmp     dl,'F'
                je      can_walkleft
                cmp     dl,'P'
                je      can_walkleft
                jmp     cant_walkleft
sc_mapleft:     jmp     mapleft
can_walkleft:   call    draw_cecil
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     al,'W'
                mov     [si+4],al
                mov     al,'S'
                mov     cecil_dmode,al
                call    draw_cecil
                delay   30
                mov     bl,[si+5]
                call    draw_block
                mov     bl,[si+8]
                dec     dh
                call    draw_block
                mov     al,[si]
                dec     al
                mov     [si],al
                mov     al,'N'
                mov     cecil_dmode,al
                call    draw_cecil
                call    clear_kbuff
cant_walkleft:  pop     dx
                pop     bx
                pop     ax
                ret
   mapleft:     call    map_left
                mov     dl,19
                mov     [si],dl
                call    draw_cecil
                call    gen_enemy
                pop     dx
                pop     bx
                pop     ax
                ret
w_left          endp

w_right         proc    near
                push    ax
                push    bx
                push    dx
                mov     dl,[si]
                cmp     dl,19
                je      sc_mapright
                call    get_attribute
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     al,'E'
                mov     [si+4],al
                mov     dl,[si+7]
                cmp     dl,'G'
                je      can_walkright
                cmp     dl,'s'
                je      can_walkright
                cmp     dl,'S'
                je      can_walkright
                cmp     dl,'F'
                je      can_walkright
                cmp     dl,'P'
                je      can_walkright
                jmp     cant_walkright
sc_mapright:    jmp     mapright
can_walkright:  call    draw_cecil
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     al,'E'
                mov     [si+4],al
                mov     al,'S'
                mov     cecil_dmode,al
                call    draw_cecil
                delay   30
                mov     bl,[si+5]
                call    draw_block
                mov     bl,[si+7]
                inc     dh
                call    draw_block
                mov     al,[si]
                inc     al
                mov     [si],al
                mov     al,'N'
                mov     cecil_dmode,al
                call    draw_cecil
                call    clear_kbuff
cant_walkright: pop     dx
                pop     bx
                pop     ax
                ret
   mapright:    call    map_right
                mov     dl,0
                mov     [si],dl
                call    draw_cecil
                call    gen_enemy
                pop     dx
                pop     bx
                pop     ax
                ret
w_right         endp

hit_enemy       proc    near      ;AH,AL=position to check hit
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                mov     di,offset cecil
                mov     si,offset enemy1
                mov     cx,6
   e_hit:       mov     dl,[si]
                cmp     dl,'N'
                je      no_hit
                cmp     dl,0
                je      no_hit
                mov     dh,[si+2]
                mov     dl,[si+3]
                cmp     ah,dh
                jne     no_hit
                cmp     al,dl
                jne     no_hit
                call    redraw_enemy
                mov     dl,[si+5]  ;dl = enemy HP
                mov     dh,[di+3]  ;dh = cecil level
                push    ax
                mov     al,6                         ;\
                mul     dh                           ;|
                mov     bh,al                        ;|
                random  7                            ;> Hit enemy
                add     al,bh                        ;|
                sub     dl,al      ;dl = enemy HP    ;|
                jns     next_ehit                    ;|
                mov     dl,0                         ;/
                call    draw_enemy
   next_ehit:   push    cx
                push    si
                mov     si,offset hit_tag
                mov     ch,14
                mov     cl,24
                mov     bx,15
                call    print_text
                mov     ch,18
                call    write_num
                delay   60
                pop     si
                pop     cx
                pop     ax
                mov     [si+5],dl
   no_hit:      add     si,9
                loop    e_hit
                call    check_e_die
                mov     bl,enter_boss
                cmp     bl,'N'
                je      no_hit_boss
                call    draw_boss
                mov     si,offset boss
                mov     dh,[si]
                mov     dl,[si+1]
                add     dh,2
                cmp     ax,dx
                jne     no_hit_boss
                mov     ax,bhc
                dec     ax
                mov     bhc,ax
                mov     si,offset boss2_pal
                call    set_pal
                delay   50
                mov     si,offset boss1_pal
                call    set_pal
                delay   50
                mov     si,offset boss2_pal
                call    set_pal
                delay   50
                mov     si,offset boss1_pal
                call    set_pal
                call    boss_back
                mov     si,offset cecil
                cmp     ax,0
                jne     no_hit_boss
                mov     al,'F'
                mov     [si+10],al
  no_hit_boss:  pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
hit_enemy       endp

sword           proc    near
                push    ax
                push    si
                mov     si,offset cecil
                mov     al,[si+4]
                cmp     al,'N'
                je      sw_oup
                cmp     al,'E'
                je      sw_right
                cmp     al,'W'
                je      sw_left
                cmp     al,'S'
                je      sw_down
                jmp     no_use_sword
      sw_oup:   call    sword_up
                jmp     no_use_sword
      sw_down:  call    sword_down
                jmp     no_use_sword
      sw_left:  call    sword_left
                jmp     no_use_sword
      sw_right: call    sword_right
                jmp     no_use_sword
  no_use_sword: pop     si
                pop     ax
                ret
sword           endp

sword_up        proc    near
                push    ax
                push    bx
                push    dx
                push    si
                push    di
                call    waitretrace
                mov     di,offset cecil
                mov     dh,[di]
                mov     dl,[di+1]
                mov     ah,[di]
                mov     al,[di+1]
                call    get_attribute
                call    eight_way_atbr
                mov     bl,[di+5]
                call    draw_block
                mov     si,offset sw_u1
                call    draw_array
                inc     ah
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si+4]
                call    draw_block
                inc     dh
                mov     bl,[si+5]
                call    draw_block
                dec     dh
                dec     dl
                mov     si,offset sw_u2
                call    draw_array
                dec     al
                call    hit_enemy
                delay   20
                inc     dh
                mov     si,offset eight_way
                mov     bl,[si+2]
                call    draw_block
                inc     dl
                mov     bl,[si+5]
                call    draw_block
                dec     dh
                mov     bl,[di+5]
                call    draw_block
                dec     dl
                mov     si,offset sw_u3
                call    draw_array
                dec     ah
                call    hit_enemy
                delay   20
                mov     bl,[di+6]
                call    draw_block
                inc     dl
                mov     bl,[di+5]
                call    draw_block
                mov     al,enter_boss
                cmp     al,'N'
                jne     up_onboss 
                jmp     fin_swup
    up_onboss:  call    draw_boss
    fin_swup:   pop     di
                pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
sword_up        endp

sword_down      proc    near
                push    ax
                push    bx
                push    dx
                push    si
                push    di
                call    waitretrace
                mov     di,offset cecil
                mov     dh,[di]
                mov     dl,[di+1]
                mov     ah,[di]
                mov     al,[di+1]
                call    get_attribute
                call    eight_way_atbr
                mov     bl,[di+5]
                call    draw_block
                dec     dh
                mov     si,offset sw_d1
                call    draw_array
                dec     ah
                call    hit_enemy
                delay   20
                inc     dh
                mov     si,offset eight_way
                mov     bl,[si+4]
                call    draw_block
                dec     dh
                mov     bl,[si+3]
                call    draw_block
                mov     si,offset sw_d2
                call    draw_array
                inc     al
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si+3]
                call    draw_block
                inc     dl
                mov     bl,[si+6]
                call    draw_block
                dec     dl
                inc     dh
                mov     bl,[si+4]
                call    draw_block
                mov     si,offset sw_d3
                call    draw_array
                inc     ah
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si+4]
                call    draw_block
                inc     dl
                mov     bl,[si+7]
                call    draw_block
                mov     al,enter_boss
                cmp     al,'N'
                jne     down_onboss 
                jmp     fin_swdown
   down_onboss: call    draw_boss
   fin_swdown:  pop     di
                pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
sword_down      endp

sword_left      proc    near
                push    ax
                push    bx
                push    dx
                push    si
                push    di
                call    waitretrace
                mov     di,offset cecil
                mov     dh,[di]
                mov     dl,[di+1]
                mov     ah,[di]
                mov     al,[di+1]
                call    get_attribute
                call    eight_way_atbr
                mov     bl,[di+5]
                call    draw_block
                dec     dl
                mov     si,offset sw_up
                call    draw_array
                inc     dl
                mov     si,offset c_left2
                call    draw_array
                dec     dl
                dec     al
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si+1]
                call    draw_block
                inc     dl
                mov     bl,[si+4]
                call    draw_block
                dec     dh
                dec     dl
                mov     si,offset sw_l1
                call    draw_array
                dec     ah
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si]
                call    draw_block
                inc     dh
                mov     bl,[si+1]
                call    draw_block
                inc     dl
                mov     bl,[si+4]
                call    draw_block
                dec     dh
                mov     si,offset sw_l2
                call    draw_array
                inc     al
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si+3]
                call    draw_block
                inc     dh
                mov     bl,[si+4]
                call    draw_block
                mov     al,enter_boss
                cmp     al,'N'
                jne     left_onboss 
                jmp     fin_swleft
   left_onboss: call    draw_boss
   fin_swleft:  pop     di
                pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
sword_left      endp

sword_right     proc    near
                push    ax
                push    bx
                push    dx
                push    si
                push    di
                call    waitretrace
                mov     di,offset cecil
                mov     dh,[di]
                mov     dl,[di+1]
                mov     ah,[di]
                mov     al,[di+1]
                call    get_attribute
                call    eight_way_atbr
                mov     bl,[di+5]
                call    draw_block
                dec     dl
                mov     si,offset sw_up
                call    draw_array
                inc     dl
                mov     si,offset c_right2
                call    draw_array
                dec     dl
                dec     al
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si+1]
                call    draw_block
                inc     dl
                mov     bl,[si+4]
                call    draw_block
                dec     dl
                mov     si,offset sw_r1
                call    draw_array
                inc     ah
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si+1]
                call    draw_block
                inc     dh
                mov     bl,[si+2]
                call    draw_block
                inc     dl
                dec     dh
                mov     bl,[si+4]
                call    draw_block
                mov     si,offset sw_r2
                call    draw_array
                inc     al
                call    hit_enemy
                delay   20
                mov     si,offset eight_way
                mov     bl,[si+4]
                call    draw_block
                inc     dh
                mov     bl,[si+5]
                call    draw_block
                mov     al,enter_boss
                cmp     al,'N'
                jne     right_onboss 
                jmp     fin_swright
  right_onboss: call    draw_boss
  fin_swright:  pop     di
                pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
sword_right     endp

print_text      proc    near    ;si=offset text
                push    ax      ;ch,cl=col,row
                push    bx      ;bl=attribute
                push    cx
                push    dx
    print_ag:   call    set_csr
                mov     al,[si]
                cmp     al,'$'
                je      end_print
                push    cx
                mov     cx,1
                mov     ah,9
                int     10h
                pop     cx
                inc     si
                inc     ch
                jmp     print_ag
   end_print:   pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
print_text      endp

print_delay     proc    near    ;si=offset text
                push    ax      ;ch,cl=col,row
                push    bx      ;bl=attribute
                push    cx
                push    dx
                mov     text_colsave,ch
    print_ag2:  call    set_csr
                mov     al,[si]
                delay   30
                cmp     al,'$'
                je      end_print2
                cmp     al,'\'
                jne     next_char
                mov     ch,text_colsave
                inc     cl
                inc     cl
                inc     si
                jmp     print_ag2
   next_char:   push    cx
                mov     cx,1
                mov     ah,9
                int     10h
                pop     cx
                inc     si
                inc     ch
                jmp     print_ag2
   end_print2:  call    clear_kbuff
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
print_delay     endp

print_rb        proc    near    ;si=offset text
                push    ax      ;ch,cl=col,row
                push    bx      ;bl=attribute
                push    dx
                push    si
                mov     bx,206
    printr_ag:  call    set_csr
                mov     al,[si]
                cmp     al,'$'
                je      end_print
                push    cx
                mov     ah,9
                mov     cx,1
                int     10h
                pop     cx
                inc     si
                inc     ch
                dec     bl
                cmp     bx,200
                jne     to_print
                mov     bx,206
    to_print:   jmp     printr_ag
   end_printr:  pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
print_rb        endp

write_status    proc    near
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                xor     ax,ax
                mov     ch,0
                mov     cl,24
                mov     si,offset game_name
                mov     bx,200
                call    print_rb
                mov     ch,23
                mov     cl,24
                mov     si,offset hp_tag
                mov     bx,15
                call    print_text
                mov     di,offset cecil
                mov     al,[di+2]
                mov     ch,26
                call    write_num
                mov     si,offset slash_tag
                mov     ch,29
                call    print_text
                mov     al,max_hp
                mov     ch,30
                call    write_num
                mov     si,offset level_tag
                mov     ch,34
                call    print_text
                mov     al,[di+3]
                mov     ch,37
                call    write_num
                pop     di
                pop     si
                pop     dx
                pop     dx
                pop     cx
                pop     ax
                ret
write_status    endp

write_num       proc    near        ;Ch,cl=col,row al=number
                push    ax
                push    bx
                push    si
                mov     si,offset num_buff
                cmp     al,064h
                jb      less_hund
                mov     bl,10
                mov     ah,0
                div     bl
                add     ah,48
                mov     [si+2],ah
                mov     ah,0
                div     bl
                add     al,48
                mov     [si],al
                add     ah,48
                mov     [si+1],ah
                jmp     to_writenum
   less_hund:   mov     ah,48
                mov     [si],ah
                mov     ah,0
                mov     bl,10
                div     bl
                add     al,48
                mov     [si+1],al
                add     ah,48
                mov     [si+2],ah
   to_writenum: mov     bx,15
                call    print_text
                pop     si
                pop     bx
                pop     ax
                ret
write_num       endp

check_hp        proc    near
                push    ax
                push    si
                mov     si,offset cecil
                mov     al,[si+2]
                cmp     al,0
                jne     nothing_hp
                mov     al,'D'
                mov     [si+10],al
   nothing_hp:  pop     si
                pop     ax
                ret
check_hp        endp

check_lvup      proc    near
                push    ax
                push    bx
                push    si
                push    di
                mov     si,offset cecil
                mov     di,offset exp_table
                mov     bl,[si+3]
   next_level:  mov     ax,[di]
                cmp     al,bl
                je      check_exp
                add     di,2
                jmp     next_level
   check_exp:   mov     ax,[di+2]
                mov     bx,[si+11]
                cmp     bx,ax
                jl      no_lvup           
                mov     al,[si+3]
                inc     al
                mov     [si+3],al
                mov     bl,6
                mul     bl
                mov     al,max_hp
                add     al,bl
                mov     max_hp,al
                mov     [si+2],al
                call    text_on
                mov     ch,14
                mov     cl,20
                mov     si,offset get_level
                mov     bx,15
                call    print_delay
                readkey
                mov     si,offset cecil
                mov     al,[si+3]
                cmp     al,5
                je      c_lv5
   off_text:    call    text_off
   no_lvup:     pop     di
                pop     si
                pop     bx
                pop     ax
                ret
   c_lv5:       mov     si,offset mash2_pal
                call    set_pal
                mov     al,6
                mov     enemy_level,al
                mov     si,offset enemy_gain
                mov     ch,10
                mov     bx,15
                call    print_delay
                readkey
                jmp     off_text
check_lvup      endp

player_proc     proc    near
                pusha
                mov     si,offset cecil
                call    draw_cecil
                mov     ah,11h
                int     16h
                jz      no_input
                mov     ah,10h
                int     16h
                cmp     ah,048h
                je      walk_up
                cmp     ah,04bh
                je      walk_left
                cmp     ah,04dh
                je      walk_right
                cmp     ah,050h
                je      walk_down
                cmp     ah,039h
                je      use_sword
                cmp     ah,017h
                je      event_handler
                cmp     ah,1
                je      to_exit_prog
                cmp     ah,013h
                je      max_pwr
                jmp     end_player
  to_exit_prog: mov     al,'E'
                mov     [si+10],al
                jmp     end_player
   walk_up:     call    w_up
                jmp     no_input
   walk_left:   call    w_left
                jmp     no_input
   walk_right:  call    w_right
                jmp     no_input
   walk_down:   call    w_down
                jmp     no_input
   use_sword:   call    sword
                jmp     no_input
 event_handler: call    event_check
                jmp     no_input
   max_pwr:     mov     al,110
                mov     max_hp,al
                mov     si,offset cecil
                mov     [si+2],al
                mov     al,30
                mov     [si+3],al
   no_input:    call    check_bump
                call    write_status
                call    check_hp
   end_player:  popa
                ret
player_proc     endp

event_check     proc    near
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                mov     si,offset cecil
                mov     dh,[si]
                mov     dl,[si+1]
                call    eight_way_atbr
                mov     al,[si+4]
                call    eight_way_atbr
                mov     si,offset eight_way
                cmp     al,'N'
                je      look_n
                cmp     al,'E'
                je      look_e
                cmp     al,'W'
                je      look_w
                cmp     al,'S'
                je      look_s
                jmp     found_no
   look_n:      mov     al,[si+1]
                cmp     al,'W'
                je      re_hp
                cmp     al,'N'
                je      found_sign
                cmp     al,'1'
                je      first_sign
                jmp     found_no
   look_e:      mov     al,[si+5]
                cmp     al,'W'
                je      re_hp
                jmp     found_no
   look_w:      mov     al,[si+3]
                cmp     al,'W'
                je      re_hp
                jmp     found_no
   look_s:      mov     al,[si+7]
                cmp     al,'W'
                je      re_hp
                jmp     found_no
   found_no:    call    text_on
                mov     si,offset no_event
                mov     ch,15
                mov     cl,20
                mov     bx,15
                call    print_delay
                readkey
                call    text_off
  end_found:    pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
found_sign:     jmp     f_sign
re_hp:          mov     si,offset cecil
                mov     al,max_hp
                mov     [si+2],al
                call    text_on
                mov     ch,13
                mov     cl,20
                mov     bx,52
                mov     si,offset recover_tag
                call    print_delay
                readkey
                call    text_off
                jmp     end_found
first_sign:     mov     si,offset t_forest1
                call    text_on
                mov     ch,2
                mov     cl,20
                mov     bx,15
                call    print_delay
                readkey
                call    text_off
                jmp     end_found
f_sign:         mov     si,offset sign_tag
                call    text_on
                mov     ch,8
                mov     cl,19
                mov     bx,15
                call    print_delay
                readkey
                call    text_off
                jmp     end_found
event_check     endp

check_bump      proc    near
                push    ax
                push    cx
                push    dx
                push    si
                push    di
                mov     cx,6
                mov     di,offset cecil
                mov     si,offset enemy1
   next_bump:   mov     al,[si]
                cmp     al,'N'
                je      no_bump
                cmp     al,0
                je      no_bump
                mov     ah,[di]
                mov     al,[di+1]
                mov     dh,[si+2]
                mov     dl,[si+3]
                cmp     ah,dh
                jne     no_bump
                cmp     al,dl
                jne     no_bump
                call    bump_enemy
   no_bump:     add     si,9
                loop    next_bump
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     ax
                ret
check_bump      endp

bump_enemy      proc    near
                push    ax
                push    bx
                push    dx
                push    si
                mov     bl,[si]
                cmp     bl,'Y'
                je      no_t
                jmp     fin_bump
  no_t:         call    draw_enemy
                call    write_status
                mov     bl,[si+8]            ;\
                mov     al,3                 ; |
                mul     bl                   ; > bump enemy dec HP
                mov     bh,al
                random  7
                add     al,bh
                mov     si,offset cecil      ; |
                mov     bl,[si+2]            ; |
                sub     bl,al                ;/
                jns     dec_hp
                mov     bl,0
   dec_hp:      mov     [si+2],bl
                mov     dh,[si]
                mov     dl,[si+1]
                mov     al,[si+4]
                cmp     al,'N'
                je      back_north
                cmp     al,'E'
                je      back_east
                cmp     al,'W'
                je      back_west
                cmp     al,'S'
                je      back_south
                jmp     fin_bump
  back_north:   inc     dl
                mov     [si+1],dl
                call    draw_cecil
                call    get_attribute
                mov     bl,[si+5]
                call    draw_block
                delay   40
                jmp     fin_bump
  back_east:    dec     dh
                mov     [si],dh
                call    draw_cecil
                call    get_attribute
                mov     bl,[si+5]
                call    draw_block
                delay   40
                jmp     fin_bump
  back_west:    inc     dh
                mov     [si],dh
                call    draw_cecil
                call    get_attribute
                mov     bl,[si+5]
                call    draw_block
                delay   40
                jmp     fin_bump
  back_south:   dec     dl
                mov     [si+1],dl
                call    draw_cecil
                call    get_attribute
                mov     bl,[si+5]
                call    draw_block
                delay   40
                jmp     fin_bump
    fin_bump:   pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
bump_enemy      endp

reset_enemy     proc    near
                push    ax
                push    cx
                push    si
                mov     al,0
                mov     cx,54
                mov     si,offset enemy1
   reset_e:     mov     [si],al
                inc     si
                loop    reset_e
                pop     si
                pop     cx
                pop     ax
                ret
reset_enemy     endp

new_enemy       proc    near
                push    ax
                push    cx
                push    si
                mov     cx,6
                mov     si,offset enemy1
   gen_e:       delay   15
                random  1
                add     al,1
                mov     [si+1],al
                delay   15
                random  1
                cmp     ax,1
                je      no_e
                mov     al,'Y'
                mov     [si],al
                jmp     next_e
   no_e:        mov     al,'N'
                mov     [si],al
   next_e:      add     si,9
                loop    gen_e
   fin_gen:     pop     si
                pop     cx
                pop     ax
                ret
new_enemy       endp

put_enemy       proc    near
                push    ax
                push    cx
                push    dx
                push    si
                push    di
                mov     cx,6
                mov     si,offset enemy1
    put_e:      mov     al,[si]
                cmp     al,'N'
                je      loop_pe
                delay   15
                random  15
                add     ax,3
                mov     [si+2],al
                delay   10
                random  15
                cmp     ax,11
                jl      pe2
                sub     ax,4
    pe2:        add     al,1
                mov     [si+3],al
                mov     al,enemy_level
                mov     [si+8],al
                mov     dh,[si+2]
                mov     dl,[si+3]
                call    enemy_attrb
                mov     di,offset enemy_a
                mov     al,[di+4]
                cmp     al,'G'
                je      loop_pe
                cmp     al,'P'
                je      loop_pe
                jmp     put_e
                mov     al,enemy_level
                mov     [si+8],al
    loop_pe:    add     si,9
                loop    put_e
    fin_put:    pop     di
                pop     si
                pop     dx
                pop     cx
                pop     ax
                ret
put_enemy       endp

enemy_hp        proc    near
                push    ax
                push    bx
                push    cx
                push    si
                mov     si,offset enemy1
                mov     cx,6
    hp_e:       mov     bl,10
                mov     al,[si+8]
                mov     bh,[si+1]
                add     bl,bh
                mul     bl
                mov     [si+5],al
                delay   15
                random  3
                mov     [si+6],al
                mov     [si+7],al
                and     ax,1
                mov     [si+4],al
                add     si,9
                loop    hp_e
                pop     si
                pop     cx
                pop     bx
                pop     ax
                ret
enemy_hp        endp

check_e_die     proc    near
                push    ax
                push    bx
                push    cx
                push    dx
                push    si
                push    di
                mov     cx,6
                mov     si,offset enemy1
 check_around:  mov     al,[si]
                cmp     al,'N'
                je      not_die
                cmp     al,0
                je      not_die
                mov     al,[si+5]
                cmp     al,0
                jg      not_die
                mov     ah,'N'
                mov     [si],ah
                call    enemy_attrb
                mov     di,offset enemy_a
                mov     bl,[di+4]
                mov     dh,[si+2]
                mov     dl,[si+3]
                call    draw_block
                push    si
                mov     si,offset e_die1
                call    draw_array
                delay   50
                call    draw_block
                mov     si,offset e_die2
                call    draw_array
                delay   50
                pop     si
                mov     di,offset cecil     ;\
                mov     bx,[di+11]          ;|
                mov     al,3                ;|
                mov     dl,[si+1]           ;|
                mov     dh,enemy_level      ;>  Add EXP
                mul     dh                  ;|
                mul     dl                  ;|
                add     bx,ax               ;|
                mov     [di+11],bx          ;/
       not_die: add     si,9
                loop    check_around
                call    check_lvup
                pop     di
                pop     si
                pop     dx
                pop     cx
                pop     bx
                pop     ax
                ret
check_e_die     endp

enemy_attrb     proc    near   ;Get enemy attribute SI=offset enemy
                push    ax
                push    dx
                push    si
                push    di
                xor     dx,dx
                mov     di,offset sc_buff
                mov     ax,20
                mov     dl,[si+3]
                mul     dl
                mov     dl,[si+2]
                add     ax,dx
                add     di,ax
                mov     si,offset enemy_a
                mov     al,[di-20]
                mov     [si],al
                mov     al,[di+1]
                mov     [si+1],al
                mov     al,[di-1]
                mov     [si+2],al
                mov     al,[di+20]
                mov     [si+3],al
                mov     al,[di]
                mov     [si+4],al
                pop     di
                pop     si
                pop     dx
                pop     ax
                ret
enemy_attrb     endp

draw_enemy      proc    near            ;SI=offset enemy
                push    ax
                push    bx
                push    dx
                push    si
                push    di
                call    enemy_attrb
  check_draw:   mov     al,[si]
                cmp     al,'N'
                je      fin_denemy
  denemy:       mov     al,[si+1]
                cmp     al,1
                je      draw_mash
                cmp     al,2
                je      draw_tul
 fin_denemy:    pop     di
                pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
 draw_mash:     push    si
                mov     di,offset enemy_a
                mov     al,[si+4]
                mov     dh,[si+2]
                mov     dl,[si+3]
                mov     bl,[di+4]
                call    draw_block
                cmp     al,1
                je      d_mash2
                mov     al,1
                mov     [si+4],al
                mov     si,offset mash1
                call    draw_array
                pop     si
                jmp     fin_denemy
      d_mash2:  mov     al,0
                mov     [si+4],al
                mov     si,offset mash2
                call    draw_array
                pop     si
                jmp     fin_denemy
 draw_tul:      push    si
                mov     di,offset enemy_a
                mov     al,[si+4]
                mov     dh,[si+2]
                mov     dl,[si+3]
                mov     bl,[di+4]
                call    draw_block
                cmp     al,1
                je      d_tul2
                mov     al,1
                mov     [si+4],al
                mov     si,offset tul1
                call    draw_array
                pop     si
                jmp     fin_denemy
      d_tul2:   mov     al,0
                mov     [si+4],al
                mov     si,offset tul2
                call    draw_array
                pop     si
                jmp     fin_denemy
draw_enemy      endp

redraw_enemy    proc    near
                push    ax
                push    dx
                push    si
                mov     al,[si+1]        ;get type of enemy
                cmp     al,1
                je      draw_mash2
                cmp     al,2
                je      draw_tul2
 draw_mash2:    push    si
                mov     al,[si+4]
                mov     dh,[si+2]
                mov     dl,[si+3]
                cmp     al,1
                je      d_mash2_2
                mov     si,offset mash2
                call    draw_array
                pop     si
                jmp     fin_denemy2
    d_mash2_2:  mov     si,offset mash1
                call    draw_array
                pop     si
                jmp     fin_denemy2
 draw_tul2:     push    si
                mov     al,[si+4]
                mov     dh,[si+2]
                mov     dl,[si+3]
                cmp     al,1
                je      d_tul2_2
                mov     si,offset tul2
                call    draw_array
                pop     si
                jmp     fin_denemy2
    d_tul2_2:   mov     si,offset tul1
                call    draw_array
                pop     si
                jmp     fin_denemy2
  fin_denemy2:  pop     si
                pop     dx
                pop     ax
                ret
redraw_enemy    endp


e_up            proc    near
                push    ax
                push    bx
                push    dx
                push    di
                mov     dh,[si+2]
                mov     dl,[si+3]
                cmp     dl,0
                je      e_cant_up
                call    eight_way_atbr
                mov     di,offset eight_way
                mov     al,[di+1]
                cmp     al,'G'
                je      e_can_up
                cmp     al,'V'
                je      e_can_up
                cmp     al,'s'
                je      e_can_up
                cmp     al,'S'
                je      e_can_up
                cmp     al,'F'
                je      e_can_up
                cmp     al,'P'
                je      e_can_up
                jmp     e_cant_up
 e_can_up:      mov     dh,[si+2]
                mov     dl,[si+3]
                mov     bl,[di+4]
                call    draw_block
                dec     dl
                mov     [si+3],dl
                mov     al,[si+4]
                xor     al,1
                mov     [si+4],al
                call    draw_enemy
                call    check_bump
 e_cant_up:     pop     di
                pop     dx
                pop     bx
                pop     ax
                ret
e_up            endp

e_down          proc    near
                push    ax
                push    bx
                push    dx
                push    di
                mov     dh,[si+2]
                mov     dl,[si+3]
                cmp     dl,11
                je      e_cant_down
                call    eight_way_atbr
                mov     di,offset eight_way
                mov     al,[di+7]
                cmp     al,'G'
                je      e_can_down
                cmp     al,'V'
                je      e_can_down
                cmp     al,'s'
                je      e_can_down
                cmp     al,'S'
                je      e_can_down
                cmp     al,'F'
                je      e_can_down
                cmp     al,'P'
                je      e_can_down
                jmp     e_cant_down
 e_can_down:    mov     dh,[si+2]
                mov     dl,[si+3]
                mov     bl,[di+4]
                call    draw_block
                inc     dl
                mov     [si+3],dl
                mov     al,[si+4]
                xor     al,1
                mov     [si+4],al
                call    draw_enemy
                call    check_bump
 e_cant_down:   pop     di
                pop     dx
                pop     bx
                pop     ax
                ret
e_down          endp

e_left          proc    near
                push    ax
                push    bx
                push    dx
                push    di
                mov     dh,[si+2]
                mov     dl,[si+3]
                cmp     dh,0
                je      e_cant_left
                call    eight_way_atbr
                mov     di,offset eight_way
                mov     al,[di+3]
                cmp     al,'G'
                je      e_can_left
                cmp     al,'V'
                je      e_can_left
                cmp     al,'s'
                je      e_can_left
                cmp     al,'S'
                je      e_can_left
                cmp     al,'F'
                je      e_can_left
                cmp     al,'P'
                je      e_can_left
                jmp     e_cant_left
 e_can_left:    mov     dh,[si+2]
                mov     dl,[si+3]
                mov     bl,[di+4]
                call    draw_block
                dec     dh
                mov     [si+2],dh
                mov     al,[si+4]
                xor     al,1
                mov     [si+4],al
                call    draw_enemy
                call    check_bump
 e_cant_left:   pop     di
                pop     dx
                pop     bx
                pop     ax
                ret
e_left          endp

e_right         proc    near
                push    ax
                push    bx
                push    dx
                push    di
                mov     dh,[si+2]
                mov     dl,[si+3]
                cmp     dh,19
                je      e_cant_right
                call    eight_way_atbr
                mov     di,offset eight_way
                mov     al,[di+5]
                cmp     al,'G'
                je      e_can_right
                cmp     al,'V'
                je      e_can_right
                cmp     al,'s'
                je      e_can_right
                cmp     al,'S'
                je      e_can_right
                cmp     al,'F'
                je      e_can_right
                cmp     al,'P'
                je      e_can_right
                jmp     e_cant_right
 e_can_right:   mov     dh,[si+2]
                mov     dl,[si+3]
                mov     bl,[di+4]
                call    draw_block
                inc     dh
                mov     [si+2],dh
                mov     al,[si+4]
                xor     al,1
                mov     [si+4],al
                call    draw_enemy
                call    check_bump
 e_cant_right:  pop     di
                pop     dx
                pop     bx
                pop     ax
                ret
e_right         endp

enemy_way       proc    near
                push    ax
                push    dx
                mov     al,[si+7]
                cmp     al,0
                je      enemy_up
                cmp     al,1
                je      enemy_down
                cmp     al,2
                je      enemy_left
                cmp     al,3
                je      enemy_right
  enemy_up:     call    e_up
                jmp     end_way
  enemy_down:   call    e_down
                jmp     end_way
  enemy_left:   call    e_left
                jmp     end_way
  enemy_right:  call    e_right
  end_way:      pop     dx
                pop     ax
                ret
enemy_way       endp

enemy_walk      proc    near
                push    ax
                push    si
                push    di
                mov     si,offset enemy1
 next_enemyw:   mov     al,[si]
                cmp     al,'N'
                je      loop_nexte
                cmp     al,0
                je      loop_nexte
                mov     al,[si+6]
                cmp     al,0
                je      walk_step
                cmp     al,1
                je      walk_step
                cmp     al,2
                je      walk_step
                cmp     al,3
                je      walk_step3
                jmp     end_walk
   walk_step:   mov     al,[si+6]
                inc     al
                mov     [si+6],al
                call    enemy_way
                jmp     loop_nexte
   walk_step3:  delay   5
                random  3
                mov     [si+7],al
                mov     al,0
                mov     [si+6],al
                call    enemy_way
   loop_nexte:  add     si,9
                loop    next_enemyw
   end_walk:    pop     di
                pop     si
                pop     ax
                ret
enemy_walk      endp

gen_enemy       proc    near
                call    reset_enemy
                call    new_enemy
                call    put_enemy
                call    enemy_hp
                ret
gen_enemy       endp

enemy_proc      proc    near
                pusha
                call    enemy_walk
                mov     cx,6
                mov     si,offset enemy1
    redr_enemy: call    draw_enemy
                add     si,9
                loop    redr_enemy
   end_enemy:   popa
                ret
enemy_proc      endp

intro           proc    near
                push    ax
                push    dx
                push    si
                push    ds
                call    waitretrace
                mov     dx,255
                call    fill_color
                mov     ax,logo_seg
                mov     ds,ax
                mov     si,offset logo
                mov     ax,35
                mov     xcord,ax
                mov     ax,30
                mov     ycord,ax
                call    draw_pic
                mov     si,offset press
                mov     ax,82
                mov     xcord,ax
                mov     ax,150
                mov     ycord,ax
                call    draw_pic
                mov     ax,data_seg
                mov     ds,ax
   bliff:       mov     ah,11h
                int     16h
                jnz     go_intro
                call    text_on_nd
                call    text_off
                delay   150
                jmp     bliff
    go_intro:   pop     ds
                pop     si
                pop     dx
                pop     ax
                ret
intro           endp

intro2          proc    near
                push    ax
                push    dx
                push    si
                mov     si,offset intro_mesg
                mov     ch,0
                mov     cl,2
                mov     bx,15
                call    print_delay
                pop     si
                pop     dx
                pop     ax
                ret
intro2          endp

draw_boss               proc    near
                        push    dx
                        push    si
                        mov     si,offset boss
                        mov     dl,[si+4]
                        cmp     dl,0
                        je      boss_st0
                        jmp     boss_st1
   boss_st0:            mov     dh,[si]
                        mov     dl,[si+1]
                        mov     si,offset boss1
                        call    draw_array
                        jmp     fin_dboss
   boss_st1:            mov     dh,[si]
                        mov     dl,[si+1]
                        mov     si,offset boss2
                        call    draw_array
   fin_dboss:           call    boss_attribute
                        pop     si
                        pop     dx
                        ret
draw_boss               endp

boss_attribute          proc    near
                        push    ax
                        push    dx
                        push    si
                        push    di
                        push    ds
                        pop     ax
                        mov     es,ax
                        mov     di,offset boss
                        mov     dh,[di]
                        mov     dl,[di+1]
                        mov     si,offset sc_buff
                        mov     ax,20
                        mul     dl
                        mov     dl,dh
                        mov     dh,0
                        add     ax,dx
                        add     si,ax
                        mov     cx,5
                        add     di,5
                        rep     movsb
                        add     si,15
                        mov     cx,5
                        rep     movsb
                        add     si,15
                        mov     cx,5
                        rep     movsb
                        pop     di
                        pop     si
                        pop     dx
                        pop     ax
                        ret
boss_attribute          endp

clear_boss              proc    near
                        push    cx
                        push    dx
                        push    si
                        mov     si,offset boss
                        mov     dh,[si]
                        mov     dl,[si+1]
                        add     si,5
                        mov     cx,3
      cb_out:           push    cx
                        mov     cx,5
      cb_in:            mov     bl,[si]
                        call    draw_block
                        inc     si
                        inc     dh
                        loop    cb_in
                        pop     cx
                        sub     dh,5
                        inc     dl
                        loop    cb_out
                        pop     si
                        pop     dx
                        pop     cx
                        ret
clear_boss              endp

clear_bossd             proc    near
                        push    cx
                        push    dx
                        push    si
                        mov     si,offset boss
                        mov     dh,[si]
                        mov     dl,[si+1]
                        add     si,5
                        mov     cx,3
      cb_out2:          push    cx
                        mov     cx,5
      cb_in2:           mov     bl,[si]
                        call    draw_block
                        inc     si
                        inc     dh
                        loop    cb_in2
                        pop     cx
                        sub     dh,5
                        inc     dl
                        delay   400
                        call    draw_cecil
                        loop    cb_out2
                        pop     si
                        pop     dx
                        pop     cx
                        ret
clear_bossd             endp

set_bosspos             proc    near
                        push    ax
                        push    dx
                        push    si
                        push    di
                        mov     si,offset cecil
                        mov     di,offset boss
                        mov     al,[si+1]
                        mov     dl,[di+1]
                        inc     dl
                        cmp     dl,al
                        jg      less_row
                        cmp     dl,al
                        je      equal_row
                        cmp     dl,al
                        jmp     great_row
    great_row:          call    boss_posup
                        jmp     end_set
    equal_row:          call    boss_posmid
                        jmp     end_set
    less_row:           call    boss_posdown
    end_set:            pop     di
                        pop     si
                        pop     dx
                        pop     ax
                        ret
set_bosspos             endp

boss_posup              proc    near
                        push    ax
                        push    dx
                        push    si
                        push    di
                        mov     si,offset cecil
                        mov     di,offset boss
                        mov     al,[si]
                        mov     dl,[di+1]
                        mov     dh,[di]
                        mov     ah,dh
                        add     ah,2
                        cmp     ah,al
                        jg      ug
                        je      ue
                        jmp     ul
     ug:                mov     al,[di+4]
                        cmp     al,0
                        je      ugst0
                        jmp     ugst1
         ugst0:         xor     al,1
                        inc     dl
                        jmp     fin_u
         ugst1:         xor     al,1
                        dec     dh
                        jmp     fin_u
     ue:                mov     al,[di+4]
                        xor     al,1
                        inc     dl
                        jmp     fin_u
     ul:                mov     al,[di+4]
                        cmp     al,0
                        je      ulst0
                        jmp     ulst1
         ulst0:         xor     al,1
                        inc     dl
                        jmp     fin_u
         ulst1:         xor     al,1
                        inc     dh
                        jmp     fin_u
         fin_u:
                        cmp     dl,9
                        jne     u_ok
                        dec     dl
            u_ok:       mov     [di+4],al
                        mov     [di],dh
                        mov     [di+1],dl
                        pop     di
                        pop     si
                        pop     dx
                        pop     ax
                        ret
boss_posup              endp

boss_posmid             proc    near
                        push    ax
                        push    dx
                        push    si
                        push    di
                        mov     si,offset cecil
                        mov     di,offset boss
                        mov     al,[si]
                        mov     dh,[di]
                        mov     ah,dh
                        add     ah,2
                        cmp     ah,al
                        jg      eg
                        jmp     el
        eg:             mov     al,[di+4]
                        mov     dh,[di]
                        xor     al,1
                        cmp     dh,1
                        je      fin_e
                        dec     dh
                        jmp     fin_e
        el:             mov     al,[di+4]
                        mov     dh,[di]
                        xor     al,1
                        cmp     dh,14
                        je      fin_e
                        inc     dh
        fin_e:          cmp     dh,0
                        je      el_ok
                        cmp     dh,14
                        je      er_ok
                        jmp     e_ok
            el_ok:      inc     dh
                        jmp     e_ok
            er_ok:      dec     dh
            e_ok:       mov     [di+4],al
                        mov     [di],dh
                        pop     di
                        pop     si
                        pop     dx
                        pop     ax
                        ret
boss_posmid             endp
    
boss_posdown            proc    near
                        push    ax
                        push    dx
                        push    si
                        push    di
                        mov     si,offset cecil
                        mov     di,offset boss
                        mov     al,[si]
                        mov     dh,[di]
                        mov     dl,[di+1]
                        mov     ah,dh
                        add     ah,2
                        cmp     ah,al
                        jg      dg
                        je      de
                        jmp     dl2
     dg:                mov     al,[di+4]
                        cmp     al,0
                        je      dgst0
                        jmp     dgst1
         dgst0:         xor     al,1
                        dec     dl
                        jmp     fin_d
         dgst1:         xor     al,1
                        dec     dh
                        jmp     fin_d
     de:                mov     al,[di+4]
                        xor     al,1
                        dec     dl
                        jmp     fin_d
     dl2:               mov     al,[di+4]
                        cmp     al,0
                        je      dlst0
                        jmp     dlst1
         dlst0:         xor     al,1
                        dec     dl
                        jmp     fin_d
         dlst1:         xor     al,1
                        inc     dh
                        jmp     fin_d
         fin_d:         cmp     dl,1
                        jne     d_ok
                        inc     dl
         d_ok:          mov     [di+4],al
                        mov     [di],dh
                        mov     [di+1],dl
                        pop     di
                        pop     si
                        pop     dx
                        pop     ax
                        ret
boss_posdown            endp

check_bosshit           proc    near
                        push    ax
                        push    bx
                        push    cx
                        push    dx
                        push    si
                        push    di
                        mov     al,'N'
                        mov     boss_flag,al
                        mov     si,offset cecil
                        mov     di,offset boss
                        mov     ah,[si]
                        mov     al,[si+1]
                        mov     dh,[di]
                        mov     dl,[di+1]
                        mov     cx,2
      out_next_r1:      push    cx
                        mov     cx,5
      next_r1:          cmp     ax,dx
                        jne     no_b_hit
                        mov     bl,'Y'
                        mov     boss_flag,bl
         no_b_hit:      inc     dh
                        loop    next_r1
                        pop     cx
                        inc     dl
                        sub     dh,5
                        loop    out_next_r1
                        mov     bl,boss_flag
                        cmp     bl,'Y'
                        je      boss_hit
                        inc     dh
                        mov     cx,3
       last_r:          cmp     ax,dx
                        je      boss_hit
                        inc     dh
                        loop    last_r
                        jmp     no_boss_hit
       boss_hit:        call    bump_boss
       no_boss_hit:     pop     di
                        pop     si
                        pop     dx
                        pop     cx
                        pop     bx
                        pop     ax
                        ret
check_bosshit           endp

bump_boss       proc    near
                push    ax
                push    bx
                push    dx
                push    si
                call    get_attribute
                mov     si,offset cecil
                call    draw_boss
                mov     dh,[si]
                mov     dl,[si+1]
                mov     bl,[si+5]
                call    draw_block
                mov     bl,[si+2]            ;\
                random  9                    ; |
                add     al,10                ; >  dec HP from boss hit
                sub     bl,al                ; |
                cmp     bl,0
                jg      dec_hp2
                mov     bl,0
   dec_hp2:     mov     [si+2],bl
                mov     al,[si+4]
                cmp     al,'N'
                je      back_north2
                cmp     al,'E'
                je      back_east2
                cmp     al,'W'
                je      back_west2
                cmp     al,'S'
                je      back_south2
                jmp     fin_bump
  back_north2:  call    draw_boss
                inc     dl
                mov     [si+1],dl
                call    draw_cecil
                call    get_attribute
                mov     bl,[si+5]
                call    draw_block
                delay   40
                jmp     fin_bump2
  back_east2:   call    draw_boss
                dec     dh
                mov     [si],dh
                call    draw_cecil
                call    get_attribute
                mov     bl,[si+5]
                call    draw_block
                delay   40
                jmp     fin_bump2
  back_west2:   call    draw_boss
                inc     dh
                mov     [si],dh
                call    draw_cecil
                call    get_attribute
                mov     bl,[si+5]
                call    draw_block
                delay   40
                jmp     fin_bump2
  back_south2:  call    draw_boss
                dec     dl
                mov     [si+1],dl
                call    draw_cecil
                call    get_attribute
                mov     bl,[si+5]
                call    draw_block
                delay   40
                jmp     fin_bump2
    fin_bump2:  call    write_status
                pop     si
                pop     dx
                pop     bx
                pop     ax
                ret
bump_boss       endp

boss_back       proc    near
                push    ax
                push    cx
                push    dx
                push    si
                mov     si,offset boss
                mov     dh,[si]
                mov     al,[si+4]
                cmp     dh,14
                jge     fin_back
                call    clear_boss
                xor     al,1
                mov     [si+4],al
                inc     dh
                mov     [si],dh
                call    draw_boss
                delay   200
   fin_back:    pop     si
                pop     dx
                pop     cx
                pop     ax
                ret
boss_back       endp

boss_proc       proc    near
                pusha
                call    clear_boss
                call    set_bosspos
                call    draw_boss
                popa
                ret
boss_proc       endp

Code_seg        ends
                end     main
