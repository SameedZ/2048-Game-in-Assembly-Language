; Author 1: Sameed Zahoor (19F-0385)
; Author 2: M.Ahmad       (19F-0280)

;------------------------=
; Descrition:
; COAL PROJECT "2048 Game"
; Date: (19/12/2020)

INCLUDE Irvine32.inc 
.data

;=------ Game Board Data/Variables------------=
  GB_Arr DD 0,0,0,0 ; GB_Arr = GameBoard_Arr
  rowsize_GBArr = ($-GB_Arr);
         DD 0,0,0,0
         DD 0,0,0,0
         DD 0,0,0,0
 columnsize_GBArr DD 4

 rowIndex DD 0
 colIndex DD 0
 
 All_Zeros DD 0
 EcxR DD 0
 GAME2048PROMPT byte "2048 GAME",0
;=---------------------------------------------=
rand_x DD ?
rand_y DD ?
counter DD ?
;=-------------------Score Board-------------=
   UserScorePrompt byte "Score : ",0
   UserScore DD 0 
;=------------------Movement Prompt--------------=
movInstruction1 byte " (W for Upward) , (S for Downward)",0
movInstruction2 byte "(A for Leftward), (D FOR Rightward)",0
movInstruction3 byte "   Enter your Direction :=  ",0



invalid byte "Invalid Input! ENTER AGAIN: ",0
 ;=---------------Struct Search Keys----------=
 key1 DD ?
 key2 DD ?
 key1_x DD ?
 key1_y DD ?
 key2_x DD ?
 key2_y DD ?
 ;=-------------------------------------------=
 GAMEOVER BYTE 0
 GAMEWON BYTE 0
 GAMEOVER_PROMPT BYTE "<< GAME OVER >>",0
 GAMEWON_PROMPT BYTE "<< YOU WON >>",0

.code
main PROC 

    ;---Placing at Random position---=
     call findRandom
     call PlaceRandom
    ;---------------------------------=


 .while GAMEOVER != 1 ||  GAMEWON != 1
    mov eax, white + (black*16)
    call SetTextColor
    call CLRSCR ; clears the screen

  
    CALL GameOverChecker ; check if game over  

    .if GAMEOVER != 1 && GAMEWON != 1

    ;---Placing at Random position---=
     call findRandom
     call PlaceRandom
    ;---------------------------------=
     .ENDIF

    ;=-----------------------------=
    call DisplayScoreBoard
    mov ecx,rowsize_GBArr
    mov ebx,columnsize_GBArr
    call DrawGameBoard
    ;=-----------------------------=

    .if GAMEOVER != 1 && GAMEWON != 1
    ;-------- Movements--------
    call holdMoveKeys
    ;=-----------------------------=
    .ELSEIF GAMEOVER == 1 && GAMEWON != 1
    call DisplayGameOver
    JMP EXITGAME
    .ELSEIF GAMEOVER != 1 && GAMEWON == 1
    call DisplayGameWon 
    JMP EXITGAME
    ;MOV GAMEWON,1
    .ENDIF

    .ENDW

    EXITGAME:
    call Crlf    
    call Crlf
    call waitmsg

    exit
main ENDP

;-----------------------=
GetArrayValue_At PROC uses ebx ecx edx esi
; Func: Gives Value of 2D array at [row][col]
; Paras: 
; ESI = offset to 2D-Array
; EDI = rowIndex
; EDX = colIndex 
; RET = eax = value at GB_Arr[row][column]

 push edx ; coIndex parameter...(placed on stack)
 ;          (since we gonna use it to multiple down)
 ;          i just needed the register so...

 mov esi,esi ;(offset to 2D array)
 mov eax,edi
 mov edx,rowsize_GBArr
 mul edx

 add esi,eax; [esi points to specified row now]

 pop edx ; pop the original parameter back to edx
         ; now edx = columnIndex of parameter 

 mov ecx,edx ; ecx= column specified
 mov eax,0

 mov eax,[esi+ ecx * TYPE GB_Arr ]

 

RET
GetArrayValue_At ENDP
;-----------------------=

printArrayValue proc uses eax ebx ecx
; Func: Prints out the value being passed to it in eax
; Paras: eax [vlaue] 
; ret : NONE

    mov ebx,eax ; value to be printed

    
    .if ebx == 0
    ;mov eax, white + (lightGray * 16) ; white on red
    call SetTextColor
    mov eax, white + (yellow * 16) ; white on cyan
    call SetTextColor
    .elseif ebx == 2
    mov eax, white + (brown * 16) ; white on cyan
    call SetTextColor
    .elseif ebx == 4
    mov eax, white + (magenta * 16) ; white on cyan
    call SetTextColor
    .elseif ebx == 8 
    mov eax, white + (cyan * 16) ; white on cyan
    call SetTextColor
    .elseif ebx == 16 
    mov eax, white + (green * 16) ; white on cyan
    call SetTextColor
    .elseif ebx == 32 
    mov eax, white + (lightGreen * 16) ; white on cyan
    call SetTextColor
    .elseif ebx == 64 
    mov eax, white + (lightMagenta * 16) ; white on cyan
    call SetTextColor
    .else
    mov eax, white + ( red * 16) ; white on red
    call SetTextColor

    .endif

    mov eax , ebx

    .if  eax == 0
    mov eax, ' '
    call writechar
    mov eax,0
    .elseif eax > 0 
    call writedec
    .endif   

    .if eax < 9 
    mov ecx,3
    .elseif eax < 99 
    mov ecx,2
    .elseif eax < 999
    mov ecx,1
    .else 
    mov ecx,0
    .endif
     


    .if eax < 999 
    mov eax, ' '    
    letsloop:
    call writechar 
    loop letsloop
    .endif

    ret
printArrayValue endp

;------------------------=
printSpaces proc uses eax ebx ecx
; Func: Displays black spaces 
; No paras : void
; RET = VOID 

    mov eax, white + (black * 16) ; white on red
    call SetTextColor
    
    mov eax, ' '
    call writechar 

    ret
printSpaces endp
;----------------------=

;------------------------------=
BorderOutline PROC uses ecx edi
; Func : Adds a borderline when called
; Paras: al , ah and ecx prints white color upto the ecx valued loop 
; ret : none

   mov ecx,edi
    border1:

    mov dh,al ; al controls the x horizon
    mov dl,ah
    call Gotoxy ; locate cursor
    push eax
    mov eax, white + ( white * 16) ; white on red
    call SetTextColor
    
    mov eax, ' '
    call writechar
    pop eax

    inc ah
    loop border1
    dec ah

ret 
BorderOutline ENDP 

;------------------------=
DrawGameBoard PROC 
; Description:
; The func simply displays the
; gameboard on console using the
; 2D-Array,its Rowsize and its 
; Columnsize
;-----------------=
; Parameters
; None
;-----------------=
; RET = Void 

PUSHAD ; place all registers on stack
    
    mov edx,0
    mov eax,0
    mov rowIndex,EAX
    mov colIndex,EAX

    mov al,8
    mov ah,26
    mov edi,23
    call BorderOutline

    mov dh,8 ; al controls the x horizon
    mov dl,33
    call Gotoxy
    mov eax, white + (magenta * 16) ; white on cyan
    call SetTextColor
    mov edx,offset GAME2048PROMPT
    call writeString

    mov al,9
    mov ah,26
    mov edi,23
    call BorderOutline

    mov ah,28
    mov al,10
    mov ecx,4
    mov EcxR,4
   .while EcxR != 0 
    mov ebx,columnsize_GBArr
    mov edx,0
    mov dh,al ; al controls the x horizon
   ; mov dl,28
;   call Gotoxy ; locate cursor

     mov edi,2
     mov ah,26
     call BorderOutline
    
   .while ebx != 0 && rowIndex <= 3

    mov esi,offset GB_Arr
    mov edi,rowIndex
    
    push ebx
    push edx
    mov edx,colIndex

    mov ebx,eax ; ebx needs to return value to eax in order for correct movemnt of gotoxy
    mov eax,0
    call GetArrayValue_At ;ret:: eax = GB_Arr[rowIndex][colIndex]

    pop edx

    call printArrayValue

    
    .if colIndex != 3
    call printSpaces
    .endif
    
    mov eax,ebx

    pop ebx

   inc colIndex
   dec ebx
   .endw

   push eax
   mov edi,2
   mov ah,47
   call BorderOutline
   pop eax
   mov colIndex,0
   inc rowIndex
   inc al; for moving cursor every time to new row
   dec EcxR
   .endw

    mov ah,26
    mov edi,23
    call BorderOutline

POPAD ; return values to all registers (org)

RET
DrawGameBoard ENDP
;-----------------------=

;------------------------=
DisplayScoreBoard PROC uses eax edx
; Description:
; The func simply displays the
; score of the user on console 
;-----------------=
; Parameters
; None
;-----------------=
; RET = Void 

 mov edx,0
 mov dh,6
 mov dl,30
 call Gotoxy ; locate cursor
 mov eax,black + (yellow*16)
 call SetTextColor

 mov edx,offset UserScorePrompt
 call writeString
 mov eax,' ' 
 call writeChar

 mov eax, white + (magenta * 16) ; white on cyan
 call SetTextColor

 call writeChar
 mov eax,' ' 
 call writeChar
 mov eax,UserScore
 call writeDec
 mov eax,' ' 
 call writeChar
 call writeChar
 call writeChar
 call writeChar

RET 
DisplayScoreBoard ENDP
;-----------------------=

;------------------------=
PlaceArrayValue_At PROC uses ecx ebx
; Func: Places value in the array at specified parameters(r,c)
; Paras:
; ESI = offset to 2D-Array
; EDI = rowIndex
; EDX = colIndex  
; EAX = value to be placed
; RET = VOID

 PUSH eax; consists of value to be placed
 push edx ; coIndex parameter...(placed on stack)

 mov esi,esi ;(offset to 2D array)
 mov eax,edi
 mov edx,rowsize_GBArr
 mul edx

 add esi,eax; [esi points to specified row now]

 pop edx ; pop the original parameter back to edx
         ; now edx = columnIndex of parameter 
 mov ecx,edx ; ecx= column specified
 mov eax,0
 pop eax ; now eax== new value to be placed
 mov [esi+ ecx * TYPE GB_Arr ],eax

RET
PlaceArrayValue_At ENDP
;------------------------=
;--------------------------=
findRandom PROC
;This Function generates Random x,y coordinates of the array 
; EAX =  To store the random number
; rand_x to store the xCoordinate of array and rand_y to store the Y cooRdinate of the the array
mov eax,4 ;to get random value between 0 and 4
call Randomize ; to reSeed the Generator
call RandomRange
mov rand_x,eax
mov eax,4 ; to get random value between 0 and 4
call Randomize
call RandomRange
mov rand_y,eax
ret
findRandom ENDP
;-----------------------------=
PlaceRandom PROC 
; The functions goes to the specified array index and check if there's a 0 or other value there.
; row Index = 0
; colIndex  = 0 
; searchKey = searchKey Value
; counter ,0 
; ecx = number of rows
; RET ==> eax,ebx(roxIndex,colIndex)
gotoTop:
 mov ecx,4
 mov eax,rand_x
 mov rowIndex,eax
 mov eax,rand_y
 mov colIndex,eax
    mov ecx,rowSize_GBArr
            mov ebx,offset GB_Arr 
            mov eax,rowIndex 
            mov edx,rowSize_GBArr 
            mul edx  
            add ebx,eax 
            mov esi,colIndex  
            mov eax, 0 
            mov eax, [ebx + esi * TYPE GB_Arr] 
            .if eax == 0
             .if rowIndex == 0 || rowIndex == 2
              mov dl,2
              mov [ebx + esi * TYPE GB_Arr],dl
              .ELSE
              mov dl,4
              mov [ebx + esi * TYPE GB_Arr],dl
              .ENDIF
              .ELSE
              call findRandom
              jmp gotoTop
              .ENDIF
              
RET
PlaceRandom ENDP
;-----------------------=
;-----------------------=
;-------------holdMoveKeys--------*---
holdMoveKeys PROC
;This fucntion record the movement keys of the game
;EDX = Offset of the strings.
;hold_key variable to store the movement key
;EAX = Hold the Input entered by user
;IF Condition Structure
;gotoTop:
call crlf
call crlf

 mov edx,0
 mov dh,15
 mov dl,25
 call Gotoxy ; locate cursor

mov eax,black + (magenta*16)
call SetTextColor

mov edx,offset movInstruction1
call WriteString
 mov edx,0
 mov dh,16
 mov dl,25
 call Gotoxy ; locate cursor
mov edx,offset movInstruction2
call WriteString
 mov edx,0
 mov dh,17
 mov dl,25
 call Gotoxy ; locate cursor
mov edx,offset movInstruction3
call WriteString

call readChar
call writeChar
;mov hold_key,AL
.IF AL == 'w' || AL == 'W'
call upWardMovement 
.ELSEIF AL ==  's' || AL == 'S'
call downwardMovement
.ELSEIF AL  == 'A' || AL == 'a'
call leftwardMovement
.ELSEIF AL  == 'd' || AL == 'D'
call rightwardMovement
.ELSE
mov edx,offset invalid
call WriteString
;jmp gotoTop
.ENDIF
ret
holdMoveKeys ENDP

;---------------UpWardMovement---------=
upWardMovement PROC
; The func is provoked when movement called
; is upWard Movement & uses uphelper to perfrom upward movement to each column
; Parameters = NONE
; RET = VOID 
mov ecx,4
mov eax,0
 L1:

  call ColumChecker
  .IF(ebx == 1)
  call upHelper
  .ENDIF
  add eax,1
  loop L1
ret
upWardMovement ENDP
;--------------------------------------=

;--------------------------------=
upHelper PROC uses eax ecx
; THIS FUNC IMPLEMENTS THE Down MOVEMENT
; ON THE 2D ARRAY WHEN PROVOKED Column WISE
; PARAS = col number in eax
; RET = NONE

 mov ecx,0
 mov rowIndex,0
 mov colIndex,eax

 
  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  .if eax != 0 && edi <= 3  
    JMP M2
  .else 
  M1:
  call GetArrayValue_At
  .if eax == 0 && edi <= 3  
    add edi,1
    jmp M1
  .ENDIF
  PUSH edi
  ; eax= desrired 
  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex
  call PlaceArrayValue_At
  pop edi 
  mov edx,colIndex
  mov eax,0
  mov esi,offset GB_Arr ;offset 
  call PlaceArrayValue_At
  .endif

  M2:
  mov rowIndex,0

.WHILE(ecx != 4)

  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  mov key1,eax
  mov eax,rowIndex
  mov key1_x,eax
  mov eax,colIndex
  mov key1_y,eax

  Continue2:
   add rowIndex,1
  .IF (rowIndex < 4)
  mov esi,offset GB_Arr
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  mov key2,eax
  .IF (eax == 0 )
  jmp Continue2
  .ENDIF

  mov eax,rowIndex
  mov key2_x,eax
  mov eax,colIndex
  mov key2_y,eax

  .ENDIF

  mov eax,key1
  mov ebx,key2

  MOV EDX,key2_x
  sub EDX,key1_x

.IF (rowIndex <= 3)

.IF (eax == ebx && eax != 0) || ( eax < ebx && eax == 0) || ( eax > ebx && ebx == 0)
    push eax
    push ebx
    .IF EAX == EBX
     ;-----Score Addition
     MOV ebx,UserScore
     add ebx,eax
     mov UserScore,ebx
     ;-----------------=
     .ENDIF
    pop ebx
    pop eax

    add eax,ebx
    mov esi,offset GB_Arr
    mov edi,key1_x
    mov edx,key1_y
    call PlaceArrayValue_At

    mov eax,0
    mov esi,offset GB_Arr
    mov edi,key2_x
    mov edx,key2_y
    call PlaceArrayValue_At
        
    mov ebx,0
    mov ebx,key1_x ; check point
    add ebx,1
    mov counter,ebx
    mov edx,key2_x

    .if rowIndex > 3 
         sub rowIndex,1
    .elseif ebx == edx
         mov rowIndex,edx
    .elseif ebx != edx
     mov ebx,key1_x
     add ebx,1
     mov rowIndex,ebx
    .else
     jmp exitL1
    .endif
  
.ELSEIF ( eax != ebx && eax != 0 && ebx != 0 && edx > 1 )
   mov esi,offset GB_Arr
   mov edi,key1_x
   add edi,1
   mov edx,key1_y              
   mov eax,ebx
   call PlaceArrayValue_At
   mov eax,0
   mov esi,offset GB_Arr
   mov edi,key2_x
   mov edx,key2_y
   call PlaceArrayValue_At
   
   .if edx > 1
     mov ebx,key1_x
     add ebx,1
     mov rowIndex,ebx
     .endif

  .if rowIndex < 3 
     sub rowIndex,1
   .else 
     jmp exitL1
   .endif  

  .ENDIF  

.ELSE 
  jmp exitL1
.ENDIF
 add ecx,1
  .ENDW
  exitL1:
ret
upHelper ENDP
;--------------------------------=

;----------DownWard Movement Function----------
downwardMovement PROC
; The func is provoked when movement called
; is Downward Movement and uses downhelper to perform down movement
; Parameters = NONE
; RET = VOID 
mov ecx,4
mov eax,0 ;Controlling Columns
 L1:

  call ColumChecker
  .IF(ebx == 1)
  call downHelper
  .ENDIF
   add eax,1
  loop L1
ret
downwardMovement ENDP
;----------------------------------
downHelper PROC uses eax ecx
; THIS FUNC IMPLEMENTS THE Down MOVEMENT
; ON THE 2D ARRAY WHEN PROVOKED Column WISE
; PARAS = col number in eax
; RET = NONE
 mov ecx,0
 mov rowIndex,3
 mov colIndex,eax

 
  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  .if eax != 0 && edi >= 0  
    JMP M2
  .else 
  M1:
  call GetArrayValue_At
  .if eax == 0 && edi >= 0  
    sub edi,1
    jmp M1
  .ENDIF
  push eax
  ; eax= desrired
  mov edi,edi
  mov edx,colIndex
  mov eax,0
  mov esi,offset GB_Arr ;offset 
  call PlaceArrayValue_At 
  mov edi,3
  mov edx,colIndex
  pop eax
  mov esi,offset GB_Arr ;offset 
  call PlaceArrayValue_At

  .endif
   
  M2:
  mov rowIndex,3

.WHILE(ecx != 4)

  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  mov key1,eax
  mov eax,rowIndex
  mov key1_x,eax
  mov eax,colIndex
  mov key1_y,eax

  Continue2:
   sub rowIndex,1
  .IF ( rowIndex >= 0 )
  mov esi,offset GB_Arr
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  mov key2,eax
  mov eax,rowIndex
  mov key2_x,eax
  mov eax,colIndex
  mov key2_y,eax
  .IF (key1 > 0 && key2_x == 0 && key2 == 0)
  jmp exitL1
  .ELSEIF (key2 == 0 && key2_x == 0)
   jmp exitL1
   .ELSEIF (key2 == 0 && key2_x > 0 )
  jmp Continue2 
  
  .ENDIF 

  .ENDIF




  mov eax,key1
  mov ebx,key2

  MOV EDX,key1_x
  sub EDX,key2_x
 
.IF (rowIndex >= 0)

.IF (eax == ebx && eax != 0) || ( eax < ebx && eax == 0) || ( eax > ebx && ebx == 0)
    push eax
    push ebx
    .IF EAX == EBX
     ;-----Score Addition
     MOV ebx,UserScore
     add ebx,eax
     mov UserScore,ebx
     ;-----------------=
     .ENDIF
    pop ebx
    pop eax

    add eax,ebx
    mov esi,offset GB_Arr
    mov edi,key1_x
    mov edx,key1_y
    call PlaceArrayValue_At

    mov eax,0
    mov esi,offset GB_Arr
    mov edi,key2_x
    mov edx,key2_y
    call PlaceArrayValue_At

    .if rowIndex > 0 
         add rowIndex,1
    .else 
     jmp exitL1
    .endif
  
.ELSEIF ( eax != ebx && eax != 0 && ebx != 0 && edx > 1 )
   mov esi,offset GB_Arr
   mov edi,key1_x
   sub edi,1
   mov edx,key1_y              
   mov eax,ebx
   call PlaceArrayValue_At
   mov eax,0
   mov esi,offset GB_Arr
   mov edi,key2_x
   mov edx,key2_y
   call PlaceArrayValue_At   



  .if rowIndex > 0  
    add rowIndex,1
   .else 
     jmp exitL1
   .endif  

  .ENDIF  

.ELSE 
  jmp exitL1
.ENDIF
 add ecx,1
  .ENDW
  exitL1:
ret
downHelper ENDP

ColumChecker PROC uses eax ecx 
; Func: This fun checks if any column is non zero
;       or zero / it can be moved or not 
; Paras:
; ESI = offset to 2D-Array
; EDI = rowIndex
; EDX = colIndex 
; RET = ebx = 1 or 0
mov ecx,3
mov ebx,0
mov counter,eax
mov All_Zeros,0
L1:
mov esi,offset GB_Arr
mov edi,ecx ;Row
mov edx,counter ;Column
call GetArrayValue_At
.if eax != 0 
mov All_Zeros,eax
.endif
mov key1,eax
mov key1_x,edi
mov key1_y,edx

dec edi
mov esi,offset GB_Arr
mov edi,edi
mov edx,counter ;Column
call GetArrayValue_At
.if eax != 0 
mov All_Zeros,eax
.endif
mov key2,eax
mov key2_x,edi
mov key2_y,edx
mov eax,key1
mov edx,key2
.if(eax == edx || eax == 0 || edx == 0)
mov ebx,1
.ENDIF
loop L1
.if All_Zeros == 0
  mov ebx,0
.endif

ret
ColumChecker ENDP

RowChecker PROC uses eax ecx 
; Func: This fun checks if any row is non zero
;       or zero / it can be moved or not 
; Paras:
; Eax= rowNumber to be checked
; ESI = offset to 2D-Array
; EDI = rowIndex
; EDX = colIndex 
; RET = ebx = true or false 1 or 0

; eax = row Number
PUSH eax
mov ecx,3
mov ebx,0
mov counter,eax
mov All_Zeros,0
L1:
mov esi,offset GB_Arr
mov edi,counter ;Row
mov edx,ecx ;Column
call GetArrayValue_At
.if eax != 0 
mov All_Zeros,eax
.endif
mov key1,eax
mov key1_x,edi
mov key1_y,edx

dec edx
mov esi,offset GB_Arr
mov edi,counter
mov edx,edx ;Column number
call GetArrayValue_At
.if eax != 0 
mov All_Zeros,eax
.endif
mov key2,eax
mov key2_x,edi
mov key2_y,edx
mov eax,key1
mov edi,key2
.if(eax == edi || eax == 0 || edi == 0)
mov ebx,1
.ENDIF
loop L1
.if All_Zeros == 0
  mov ebx,0
.endif
pop eax
ret
RowChecker ENDP

;---------------leftwardMovement---------=
leftwardMovement PROC
; The func is provoked when movement called
; is left Movement and uses leftHelpher to 
; perform right operation of movement to every row
; Parameters = NONE
; RET = VOID 
mov ecx,4
mov eax,0 ; defines the rows
 L1:

  call RowChecker
  .IF(ebx == 1)
  call leftHelper
  .ENDIF
  add eax,1
  loop L1
ret
leftwardMovement ENDP
;--------------------------------------=
;--------------------------------=
leftHelper PROC uses eax ecx
; THIS FUNC IMPLEMENTS THE LEFT MOVEMENT
; ON THE 2D ARRAY WHEN PROVOKED ROW WISE
; PARAS = row number in eax
; RET = NONE

 mov ecx,0
 mov rowIndex,eax ; leftward movement
 mov colIndex,0
 
  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  .if eax != 0 && edx <= 3  
    JMP M2
  .else 
  M1:
  call GetArrayValue_At
  .if eax == 0 && edx <= 3  
    add edx,1
    jmp M1
  .ENDIF
  PUSH edx
  ; eax= desrired 
  mov edi,rowIndex
  mov edx,colIndex
  mov esi,offset GB_Arr ;offset 
  call PlaceArrayValue_At
  pop edx
  mov edi,rowIndex
  mov eax,0
  mov esi,offset GB_Arr ;offset 
  call PlaceArrayValue_At
  .endif

  M2:
  mov colIndex,0

.WHILE(ecx != 4)

  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  mov key1,eax
  mov eax,rowIndex
  mov key1_x,eax
  mov eax,colIndex
  mov key1_y,eax

  Continue2:
   add colIndex,1
  .IF (colIndex < 4)
  mov esi,offset GB_Arr
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  mov key2,eax
  .IF (eax == 0 )
  jmp Continue2
  .ENDIF

  mov eax,rowIndex
  mov key2_x,eax
  mov eax,colIndex
  mov key2_y,eax

  .ENDIF

  mov eax,key1
  mov ebx,key2

  MOV EDX,key2_y
  sub EDX,key1_y

.IF (colIndex <= 3)

.IF (eax == ebx && eax != 0) || ( eax < ebx && eax == 0) || ( eax > ebx && ebx == 0)
    push eax
    push ebx
    .IF EAX == EBX
     ;-----Score Addition
     MOV ebx,UserScore
     add ebx,eax
     mov UserScore,ebx
     ;-----------------=
     .ENDIF
    pop ebx
    pop eax

    add eax,ebx
    mov esi,offset GB_Arr
    mov edi,key1_x
    mov edx,key1_y
    call PlaceArrayValue_At

    mov eax,0
    mov esi,offset GB_Arr
    mov edi,key2_x
    mov edx,key2_y
    call PlaceArrayValue_At

    mov ebx,0
    mov ebx,key1_y
    add ebx,1
    mov counter,ebx
    mov edx,key2_y

    .if colIndex > 3 
         sub colIndex,1
    .elseif ebx == edx
         mov colIndex,edx
    .elseif ebx != edx
     mov ebx,key1_y
     add ebx,1
     mov colIndex,ebx
    .else
     jmp exitL1
    .endif

.ELSEIF ( eax != ebx && eax != 0 && ebx != 0 && edx > 1 )
   mov esi,offset GB_Arr
   mov edi,key1_x
   mov edx,key1_y
   add edx,1
   mov eax,ebx
   call PlaceArrayValue_At
   mov eax,0
   mov esi,offset GB_Arr
   mov edi,key2_x
   mov edx,key2_y
   call PlaceArrayValue_At   

      .if edx > 1
     mov ebx,key1_y
     add ebx,1
     mov colIndex,ebx
     .endif

  .if colIndex < 3 
     sub colIndex,1
   .else 
     jmp exitL1
   .endif  

  .ENDIF  

.ELSE 
  jmp exitL1
.ENDIF
 add ecx,1
  .ENDW
  exitL1:
ret
leftHelper ENDP
;--------------------------------=

;----------DownWard Movement Function----------
rightwardMovement PROC
; The func is provoked when movement called
; is right Movement and uses rightHelpher to 
; perform right operation of movement to every row
; Parameters = NONE
; RET = VOID 
mov ecx,4       ; defines the rows
 mov eax,0
 L1:

  call RowChecker
  .IF(ebx == 1)
  call rightHelper
  .ENDIF
  inc eax
  
  loop L1
ret
rightwardMovement ENDP

rightHelper PROC uses eax ecx
; THIS FUNC IMPLEMENTS THE RIGHT MOVEMENT
; ON THE 2D ARRAY WHEN PROVOKED ROW WISE
; PARAS = row number in eax
; RET = NONE

mov ecx,0
 mov rowIndex,eax
 mov colIndex,3

 
  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex 
  call GetArrayValue_At
  .if eax != 0 && edi >= 0  
    JMP M2
  .else 
  M1:
  call GetArrayValue_At
  .if eax == 0 && edi >= 0  
    sub edx,1
    jmp M1
  .ENDIF
  push eax
  ; eax= desrired
  mov edx,edx
  mov edi,rowIndex
  mov eax,0
  mov esi,offset GB_Arr ;offset 
  call PlaceArrayValue_At 
  mov edi,rowIndex
  mov edx,3
  pop eax
  mov esi,offset GB_Arr ;offset 
  call PlaceArrayValue_At

  .endif
   
  M2:
  mov colIndex,3

.WHILE(ecx != 4)

  mov esi,offset GB_Arr ;offset 
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  mov key1,eax
  mov eax,rowIndex
  mov key1_x,eax
  mov eax,colIndex
  mov key1_y,eax

  Continue2:
   sub colIndex,1
  .IF ( colIndex >= 0 )
  mov esi,offset GB_Arr
  mov edi,rowIndex
  mov edx,colIndex
  call GetArrayValue_At
  mov key2,eax
  mov eax,rowIndex
  mov key2_x,eax
  mov eax,colIndex
  mov key2_y,eax
  .IF (key1 > 0 && key2_y == 0 && key2 == 0)
  jmp exitL1
  .ELSEIF (key2 == 0 && key2_y == 0)
   jmp exitL1
   .ELSEIF (key2 == 0 && key2_y > 0 )
  jmp Continue2 
  
  .ENDIF 

  .ENDIF




  mov eax,key1
  mov ebx,key2

  MOV EDX,key1_y
  sub EDX,key2_y
 
.IF (rowIndex >= 0)

.IF (eax == ebx && eax != 0) || ( eax < ebx && eax == 0) || ( eax > ebx && ebx == 0)
    push eax
    push ebx
    .IF EAX == EBX
     ;-----Score Addition
     MOV ebx,UserScore
     add ebx,eax
     mov UserScore,ebx
     ;-----------------=
     .ENDIF
    pop ebx
    pop eax

    add eax,ebx
    mov esi,offset GB_Arr
    mov edi,key1_x
    mov edx,key1_y
    call PlaceArrayValue_At

    mov eax,0
    mov esi,offset GB_Arr
    mov edi,key2_x
    mov edx,key2_y
    call PlaceArrayValue_At

    .if colIndex > 0 
         add colIndex,1
    .else 
     jmp exitL1
    .endif
  
.ELSEIF ( eax != ebx && eax != 0 && ebx != 0 && edx > 1 )
   mov esi,offset GB_Arr
   mov edi,key1_x
   sub edx,1
   mov edx,key1_y    
   sub edx,1
   mov eax,ebx
   call PlaceArrayValue_At
   mov eax,0
   mov esi,offset GB_Arr
   mov edi,key2_x
   mov edx,key2_y
   call PlaceArrayValue_At   



  .if colIndex > 0  
    add colIndex,1
   .else 
     jmp exitL1
   .endif  

  .ENDIF  

.ELSE 
  jmp exitL1
.ENDIF
 add ecx,1
  .ENDW
  exitL1:
ret
rightHelper ENDP

;------------Game Over Checker-------------=

GameOverChecker PROC 
; The func is used to check if the game over conditions are meet
; Conditions 1 : If no tiles can be moved row wise
; Condition 2: If no tiles can be moved column wise
; Condition 3: If one of the tile = 2048
; Ret =  { GAMEOVER = 1 when conditions meet else GAMEOVER=0}

  
  call GameOverCond3 ; check if any tile = 2048

  mov al, GAMEOVER

  .if al == 1
   RET 
  .endif

  call GameOverCond1 ; check any row can be moved
  .if ebx == 1
  RET 
  .endif
  call GameOverCond2 ; check any col can be moved
  .if ebx == 1
  RET 
  .endif
  ; Ret = ebx = 1 means yes tiles can be moved still
  ; Ret = ebx = 0 means no titles can be moved

  .if ( ebx == 0  ) 
  MOV GAMEOVER,1 ; 
  .endif


ret  
GameOverChecker ENDP
;-----------------------------------------=

GameOverCond1 PROC 
; Checks if any row can be moved
; Paras = None
; Ret = ebx = 1 means yes tiles can be moved still
; Ret = ebx = 0 means no titles can be moved

 mov ecx,4  ; defines the rows
 mov eax,0

 Letsloop:

  call RowChecker

  .IF ebx == 1
    ret 
  .ENDIF

  inc eax

 loop Letsloop 

RET 

GameOverCond1 ENDP 

GameOverCond2 PROC 
; Checks if any col can be moved
; Paras = None
; Ret = ebx = 1 means yes tiles can be moved still
; Ret = ebx = 0 means no titles can be moved

 mov ecx,4  ; defines the rows
 mov eax,0

 Letsloop:

  call ColumChecker

  .IF(ebx == 1)
    ret 
  .ENDIF

  inc eax

  loop Letsloop

RET 

GameOverCond2 ENDP 

GameOverCond3 PROC 
; The func checks if any tile is equal to 2048
; then sets GAMEOVER = 1 else leaves it unchanged
; RET = GAMEOVER =1 WHEN Condition met 

mov eax,0
mov rowIndex,eax
mov colIndex,eax

mov ecx,4
letsloop:

 mov ebx,4 
 .while ebx != 0 && rowIndex <= 3

 MOV ESI,OFFSET GB_Arr
 MOV EDI,rowIndex
 MOV EDX,colIndex
 call GetArrayValue_At ;ret:: eax = GB_Arr[rowIndex][colIndex]


  .if eax == 2048 
    mov GAMEWON,1 ; gameover time 
    ret 
  .endif

 dec ebx
 .endw
 inc rowIndex
 mov colIndex,0
loop letsloop 


RET 
GameOverCond3 ENDP 

;------------------------=
DisplayGameOver PROC 
; Description:
; The func simply displays 
; Game Over  on console 
;-----------------=
; Parameters
; None
;-----------------=
; RET = Void 

mov ecx,50000

letsloop:
 mov edx,0
 mov dh,14
 mov dl,30
 call Gotoxy ; locate cursor

 .if ecx < 10000
 mov eax,black + (red*16)
 .elseif ecx < 20000
 mov eax,black + (yellow*16)
 .elseif ecx < 30000
 mov eax,black + (magenta*16)
 .elseif ecx > 40000
 mov eax,black + (cyan*16)
 .endif

 call SetTextColor
 mov edx,offset GAMEOVER_PROMPT
 call writeString

 loop letsloop

RET 
DisplayGameOver ENDP
;-----------------------=

;------------------------=
DisplayGameWon PROC 
; Description:
; The func simply displays 
; Game Won  on console 
;-----------------=
; Parameters
; None
;-----------------=
; RET = Void 

mov ecx,50000

letsloop:
 mov edx,0
 mov dh,14
 mov dl,30
 call Gotoxy ; locate cursor

 .if ecx < 10000
 mov eax,black + (red*16)
 .elseif ecx < 20000
 mov eax,black + (yellow*16)
 .elseif ecx < 30000
 mov eax,black + (magenta*16)
 .elseif ecx > 40000
 mov eax,black + (cyan*16)
 .endif

 call SetTextColor
 mov edx,offset GAMEWON_PROMPT
 call writeString

 loop letsloop

RET 
DisplayGameWon  ENDP
;-----------------------=

END MAIN
