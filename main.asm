data		SEGMENT PARA 'data'
n			DB ?				                                ;****	Number of elements of array		****
CR          EQU 13
LF          EQU 10
dizi		DW 100 DUP(?)		                                ;****	Array						    ****
edge1		DW 1001		                                		;****	1st edge of creatable traingle	****
edge2		DW 1001				                                ;****   2nd edge of creatable traingle	****
edge3		DW 1001			                                	;****	3rd edge of creatable traingle  ****                
error_msg   DB CR, LF,'Invalid input. Please enter a valid input.',CR, LF,0 
input_n     DB 'Please enter the number of inputs you are going to enter (Max. 100):',CR, LF,0
input_array DB CR, LF,'Please enter edge lengths (Max. 1000):',CR,LF,0
nextline    DB 0Dh,CR, LF,0
triangle_msg DB  CR, LF,'Smallest triangle with given edge lengths:',CR,LF,0
not_triangle DB  CR, LF,'It is not possible to create a triangle with given edge lengths.',CR,LF,0
comma		DB ' , ',0
par_open	DB '( ',0
par_close	DB ' )',0
data		ENDS                            

stack		SEGMENT PARA 'stack'
			DW 12 DUP(?)
stack		ENDS

code		SEGMENT PARA 'code'
			ASSUME CS:code, DS:data, SS:stack
			
GETC        PROC NEAR               ;	Saves user given char in AL.       
            MOV AH, 1h
            INT 21h
            RET
GETC        ENDP

PUTC        PROC NEAR               ;	Prints the character in AL.             
            PUSH AX
            PUSH DX
            MOV DL, AL
            MOV AH, 2
            INT 21h
            POP DX
            POP AX
            RET
PUTC        ENDP

			
PUT_STR     PROC NEAR               ;	Prints the string which has starting index stored in AX.
            PUSH BX
            MOV BX, AX              
            MOV AL, BYTE PTR [BX]   
            
        PUT_LOOP:
            CMP AL,0
            JE PUT_FIN              
            CALL PUTC               
			INC BX                  
			MOV AL, BYTE PTR [BX]
			JMP PUT_LOOP
		
		PUT_FIN:
		    POP BX
		    RET
PUT_STR     ENDP		    	
		
			
GETN		PROC NEAR               ;	Saves user given number in AL. 
    
            PUSH BX
            PUSH CX
            PUSH DX
            
        GETN_START:
            MOV DX, 1           
            XOR BX, BX          
            XOR CX, CX           
            
        NEW:
            CALL GETC           
            CMP AL, CR          
            JE FIN_READ            
            CMP AL, '-'
            JNE CTRL_NUM
       
        NEGATIVE:
            MOV DX, -1
            JMP NEW     
        
        CTRL_NUM:
            CMP AL, '0'         
            JB ERROR
		    CMP AL, '9'
		    JA ERROR
		    SUB AL, '0'
		    MOV BL, AL          
		    MOV AX, 10          
		    PUSH DX
		    MUL CX              
		    POP DX
		    MOV CX, AX          
		    ADD CX, BX          
		    JMP NEW
	
	    ERROR:
	        LEA AX, error_msg
	        CALL PUT_STR
	        JMP GETN_START      
	                
		FIN_READ:
		    MOV AX,CX
		    CMP DX, 1
		    JE FIN_GETN
		    NEG AX
	    
	    FIN_GETN:
	        POP DX
	        POP CX
	        POP BX
	        RET
GETN        ENDP

PUTN        PROC NEAR           ;	Prints the number stored in AX.
            PUSH CX
            PUSH DX
            XOR DX, DX
            PUSH DX
            MOV CX, 10
            CMP AX, 0
            JGE CALC_DIGITS
            NEG AX
            PUSH AX
            MOV AL, '-'
            CALL PUTC
            POP AX  
            
        CALC_DIGITS:        
            DIV CX
            ADD DX, '0'
            PUSH DX
            XOR DX, DX
            CMP AX, 0
            JNE CALC_DIGITS
       
        DISP_LOOP:
            POP AX
            CMP AX, 0
            JE END_DISP_LOOP
            CALL PUTC
            JMP DISP_LOOP
        END_DISP_LOOP:
            POP DX
            POP CX
            RET
PUTN        ENDP

			   
MAIN		PROC FAR
            PUSH DS
            XOR AX, AX
            PUSH AX
            MOV AX, data  
            MOV DS, AX 					;	Standard initializations...
				
			MOV AX, 02
			MOV BX, 03
			INT 10h						;	Clear screen.
			
            LEA AX, input_n     		;	Print "Please enter the number of inputs you are going to enter (Max. 100):".
            CALL PUT_STR				
            JMP USER_IN_N				;	Jump to label which takes input from user.
										;	(Skip error_msg message)
        ERROR_MSG_N:						;	Restart from here for every invalid input.
            LEA AX, error_msg				;	Print 'Invalid input. Please enter a valid input.'.
            CALL PUT_STR
                           
        USER_IN_N:   					
            CALL GETN    				;	Print the number which user entered.
            CMP AX, 3					;	If n is less than 3, show error_msg message and take input from user again.
            JB ERROR_MSG_N
            CMP AX, 100					;	If n is greater than 100, show error_msg message and take input from user again.
            JA ERROR_MSG_N  
       
        START:                        
            MOV CX, AX					;	Save input in CX (CX is looping counter)
            MOV n, AL					;	Save input in n.
            XOR SI, SI
            LEA AX, input_array			;	Print "Please enter edge lengths (Max. 1000):".
            CALL PUT_STR                                                                      
            JMP CREATE_ARRAY			;	Skip error_msg message and take inputs (edge lengths).
                     
        ERROR_MSG_ARRAY:					;	Restart from here for every invalid input.
            LEA AX, error_msg
            CALL PUT_STR 
                                      
        CREATE_ARRAY:
            CALL GETN					;	Take inputs (edge lengths).
            CMP AX, 0					;	If given input is less than 0, show error_msg message and take input again. 
            JB ERROR_MSG_ARRAY
            CMP AX, 1000				;	If given input is greater than 1000, show error_msg message and take input again.
            JA ERROR_MSG_ARRAY           
            MOV dizi[SI], AX            ;	Store given input in array.
            ADD SI,2					;	Increment index twice (word type array => next element is +2) 
            LOOP CREATE_ARRAY			;	Loop n times. (Take input and store it in array n times)
            
            XOR CH, CH					
            MOV CL, n 					;	Assign n to CX again.
            DEC CL                      ;	CX = n-1 -> Bubble sort's outer loop, loops (n-1) times.
      
        BUBBLE_SORT:
            XOR SI, SI					
            MOV DX, CX                  ; 	DX = Inner loops counter (would be checked manually).
            
        IN_LOOP:						;	Inner loop, loops CX times.
											
            MOV AX, dizi[SI]			;	AX = (n-DX-1) indexed element of array.
            MOV BX, dizi[SI+2]			;	BX = (n-DX) indexed element of array.
            CMP AX, BX					;	If (n-DX-1) indexed element is not greater than (n-DX) indexed element, skip next step.
            JNA L1							
            MOV dizi[SI], BX			;	Else, swap this two elements.
            MOV dizi[SI+2], AX			
        L1: ADD SI, 2					;	Increment index twice (word type array => next element is +2) 
            DEC DX						;	Decrement inner loop's counter.
            JNZ IN_LOOP					;	Inner loop, loops until DX be 0, when DX is 0, return to outer loop.
            LOOP BUBBLE_SORT			;	Outer loop, loops until CX be 0 (n-1 times).
            
            XOR SI, SI					;	Reset index SI for next loop.
            XOR CH, CH					
            MOV CL, n					;	Assign n to CX again.
            SUB CL, 2 					;	CX = n-2 => Outer loop of triangle check loops (n-2) times.
			
        CHECK_TRI:					
			MOV AX, dizi[SI]			;	AX = a
			MOV BX, dizi[SI+2]			;	BX = b
			MOV DX, dizi[SI+4]			;	DX = c
			CMP CX, 0					;	** When CX = 0, DI is going to be 0, it's a problem for inner loop	**
			JE L3						;	**     			to solve it, skip inner loop if CX = 0.    			**
			MOV DI, CX					;	DI = Inner loop's counter
		IN_LOOP_2:						;	Inner loop, loops CX times.
			ADD AX, BX					;	AX = a+b
			CMP AX, DX					;	c < a+b : triangle can be created. Skip to "CREATABLE" label.
			JA CREATABLE
			JMP L3						;	If not creatable, skip to L3 label.
		CREATABLE:
			SUB AX, BX					;	AX = a
			PUSH AX						
			ADD AX, BX					;	AX = a+b
			ADD AX, DX					;	AX = a+b+c
			PUSH BX						
			MOV BX, edge1				;	** Initial valoe of edge1, edge2 and edge3 was 1001 **
			ADD BX, edge2				;	** 		First values found will be overwrited 		**
			ADD BX, edge3				;	BX = edge1+edge2+edge3 (last found smallest triangle) 
			CMP AX, BX					
			JAE L2						;	If triangle is not smaller than last found smallest triangle, skip next step.
			POP BX
			POP AX
			MOV edge1, AX				
			MOV edge2, BX
			MOV edge3, DX				;	Checked triangle's edges assigned to edge1, edge2 and edge3 as current smallest triangle.
			JMP L3						;	Skip next step to balance stack.
		L2:	POP BX						;	Balance stack...
			POP AX
		L3:	SUB AX, BX					;	a <- a-b.
			CMP DI, 0					;	If DI = 0, inner loop ends, return to outer loop.
			JE L4
		    DEC DI						;	Decrement inner loop's counter.
			JMP IN_LOOP_2				;	Inner loop, loops while DI is not 0. 
		L4:	ADD SI,2					;	Increment index twice (word type array => next element is +2) 
		    LOOP CHECK_TRI				;	Outer loop, loops until CX be 0. (n-2 times)
	
        PRINT:    
			MOV AX, edge1				
			ADD AX, edge2
            ADD AX, edge3 		        ;   AX = edge1+edge2+edge3
            CMP AX, 3003				;	If edge1, edge2 and edge3 are still equal to 1001 (initial value), it means no triangle found.
            JE NOT_EXIST				;	If exist, continue, else skip NOT_EXIST label.
										;	** If values are different than 1001, it means a triangle found **
        EXIST:                      	;   ** 						Print this triangle					   	**
            LEA AX, triangle_msg			
            CALL PUT_STR				;	Print "Smallest triangle with given edge lengths:".
			LEA AX, par_open			
			CALL PUT_STR				;	Print "( "
            MOV AX, edge1
            CALL PUTN					;	Print length of 1st edge.
            LEA AX, comma
            CALL PUT_STR				;	Print " , ".
            MOV AX, edge2
            CALL PUTN					;	Print length of 2nd edge.
            LEA AX, comma
            CALL PUT_STR				;	Print " , ".
            MOV AX, edge3
			CALL PUTN					;	Print length of 3rd edge.
			LEA AX, par_close	
			CALL PUT_STR				;	Print " )".
            JMP FINISH					;	Triangle found, skip NOT_EXIST label and end program.

        NOT_EXIST:     
            LEA AX, not_triangle		
            CALL PUT_STR				;	Print "It is not possible to create a triangle with given edge lengths.".

		FINISH:							;	End of the program.
            RETF
MAIN		ENDP   
code		ENDS
			END MAIN