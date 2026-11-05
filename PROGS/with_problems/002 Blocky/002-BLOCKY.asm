; Blocky                                                        
; Game 2 in 1K hires for the ZX81                               

; Remastered 2026 version 
; sourcecode as .asm for SJASM 
                                                                
; * TORNADO *                                                   
                                                                
           ORG  #4009             ;#4009                        
                                                                
           JP   init                                            
d_file     DEFW dfile                                           
dfcc       DEFW dfile+1                                         
var        DEFW vars                                            
dest       DEFW 0                                               
eline      DEFW last                                            
chadd      DEFW last-1                                          
xptr       DEFW 0                                               
stkbot     DEFW last                                            
stkend     DEFW last                                            
berg       DEFB 0                                               
mem        DEFW 0                 ; not needed without fp       
           DEFB 128                                             
dfsz       DEFB 2                                               
stop       DEFW 1                                               
lastk      DEFB 255,255,255                                     
margin     DEFB 55                                              
nxtlin     DEFW basic                                           
oldppc     DEFW 0                                               
           DEFB 0                                               
           DEFW 0                                               
taddr      DEFW 3213                                            
seed       DEFW 0                                               
frames     DEFW 65535                                           
coords     DEFB 0,0                                             
prcc       DEFB 188                                             
sposn      DEFB 33,24                                           
cdflag     DEFB 64                                              
                                                                
lbuf       LD   R,A                                             
           DEFW 0                                               
reset      LD   A,28                                            
           LD   (BC),A                                          
           INC  BC                                              
           LD   (BC),A                                          
           INC  BC                                              
           LD   (BC),A                                          
           INC  BC                                              
           LD   (BC),A                                          
           INC  BC                                              
           LD   (BC),A                                          
           INC  BC                                              
           LD   (BC),A                                          
           INC  BC                                              
           INC  BC                                              
           LD   A,lives                                         
           LD   (BC),A                                          
           LD   A,0                                             
           LD   (DE),A                                          
           INC  DE                                              
           LD   (DE),A                                          
add5       INC  HL                                              
add4       INC  HL                                              
           INC  HL                                              
           INC  HL                                              
           INC  HL                                              
           DEFB 17                                              
           JP   (IX)                                            
           RET                                                  
                                                                
                                                                
setline    CALL rnd-2                                           
           ADD  A,mindist                                       
                                                                
           LD   C,A                                             
           LD   A,B                                             
           SUB  C                                               
           RET  C                                               
           LD   B,A                                             
set2       LD   (DE),A                                          
           INC  DE                                              
           CALL rnd-2                                           
           LD   (DE),A                                          
           INC  DE                                              
           LD   C,4                                             
           CALL rnd                                             
           ADD  A,C                                             
           LD   (DE),A                                          
           INC  DE                                              
           INC  DE                                              
           XOR  A                                               
           LD   (DE),A                                          
           RET                                                  
                                                                
                                                                
lines      EQU  192                                             
lives      EQU  28+5                                            
mindist    EQU  50                                              
                                                                
begin      LD   BC,score                                        
           LD   DE,rnd+1                                        
           CALL reset                                           
           LD   B,lines                                         
           LD   DE,scrline                                      
s10        CALL setline                                         
           JR   NC,s10                                          
                                                                
nextlife   LD   SP,screen-1                                     
           LD   HL,scrline-4                                    
           PUSH HL                                              
findb      LD   B,(HL)                                          
           INC  HL                                              
           LD   C,(HL)                                          
           INC  HL                                              
           INC  HL                                              
           INC  HL                                              
           LD   A,(HL)                                          
           OR   A                                               
           JR   NZ,findb                                        
           INC  C                                               
           INC  C                                               
           POP  HL                                              
           LD   A,4                                             
stblk      LD   (HL),C                                          
           DEC  HL                                              
           INC  B                                               
           LD   (HL),B                                          
           DEC  HL                                              
           DEC  HL                                              
           DEC  HL                                              
           DEC  A                                               
           JR   NZ,stblk                                        
                                                                
cl2        LD   HL,udgline                                      
           LD   DE,scrline                                      
           LD   BC,screen                                       
                                                                
nline      LD   A,(DE)                                          
           CP   (HL)                                            
           CALL C,setudg                                        
           EX   DE,HL                                           
           CALL NC,setudg                                       
           EX   DE,HL                                           
           JR   NZ,lineset                                      
           INC  HL                                              
           LD   A,(HL)                                          
           PUSH BC                                              
           ADD  A,C                                             
           LD   C,A                                             
           INC  C                                               
           INC  HL                                              
           LD   A,(HL)                                          
           LD   (BC),A                                          
           INC  HL                                              
           INC  C                                               
           LD   A,(BC)                                          
           OR   (HL)                                            
           LD   (BC),A                                          
           INC  HL                                              
           POP  BC                                              
lineset    LD   A,31                                            
           ADD  A,C                                             
           LD   C,A                                             
           INC  BC                                              
nocar      LD   A,(DE)                                          
           OR   (HL)                                            
           JR   NZ,nline                                        
           INC  BC                                              
clr        XOR  A                                               
           LD   (BC),A                                          
           INC  BC                                              
           LD   A,B                                             
           CP   68                                              
           JR   NZ,clr                                          
                                                                
                                                                
readin     LD   A,%11000111                                     
           IN   A,(254)                                         
           CPL                                                  
           LD   H,A                                             
           AND  %00010010                                       
           LD   A,H                                             
           LD   HL,udgline+1                                    
           CALL NZ,left                                         
           AND  %00000101                                       
           CALL NZ,right                                        
                                                                
           CALL blkdrp                                          
           LD   HL,udgline                                      
           LD   A,(HL)                                          
           CP   192                                             
           JP   NC,dead                                         
           CALL nludg                                           
           INC  HL                                              
           LD   A,(HL)                                          
           CP   192                                             
           JR   C,incnorm                                       
           PUSH HL                                              
           PUSH HL                                              
           CALL add4                                            
           POP  DE                                              
upline     LD   BC,13                                           
           LDIR                                                 
           POP  HL                                              
incnorm    CALL nludg                                           
           EX   DE,HL                                           
           CALL rnd-2                                           
           ADD  A,mindist                                       
           SUB  B                                               
           LD   A,1                                             
           CALL C,set2                                          
                                                                
           LD   HL,lifecnt-2                                    
nscore     INC  (HL)                                            
           LD   A,37                                            
           CP   (HL)                                            
           JR   NC,cljp                                         
           LD   (HL),28                                         
           DEC  HL                                              
           LD   A,(HL)                                          
           CP   H                                               
           JR   C,nscore                                        
cljp       LD   BC,6                                            
           LD   DE,hisc-1                                       
           LD   HL,score-1                                      
fhigh      INC  DE                                              
           INC  HL                                              
           LD   A,(DE)                                          
           CP   (HL)                                            
           JR   C,sethi                                         
           JR   NZ,nohigh                                       
           DEC  C                                               
           JR   NZ,fhigh                                        
nohigh     DEFB 33                                              
sethi      LDIR                                                 
           JP   cl2                                             
                                                                
blkdrp     LD   A,(bx)                                          
           CP   2                                               
           JR   Z,dead                                          
           LD   HL,screen-32                                    
           LD   BC,32                                           
fline      ADD  HL,BC                                           
           CP   (HL)                                            
           JR   NZ,fline                                        
           LD   D,H                                             
           LD   E,L                                             
           LD   A,H                                             
           ADD  HL,BC                                           
           CP   H                                               
           JR   NZ,okdown                                       
           LD   A,(DE)                                          
           SUB  (HL)                                            
                                                                
okdown     LD   B,3                                             
okd1       DEC  A                                               
           PUSH AF                                              
           PUSH BC                                              
           PUSH DE                                              
           PUSH HL                                              
           CALL Z,cond                                          
           CALL blx                                             
           POP  HL                                              
           POP  DE                                              
           POP  BC                                              
           POP  AF                                              
           DJNZ okd1                                            
           RET                                                  
                                                                
blx        LD   B,4                                             
           LD   HL,udgline-4                                    
bline      CALL add4                                            
           DEC  (HL)                                            
           DJNZ bline                                           
           RET  NZ                                              
                                                                
dead       LD   HL,lifecnt                                      
           DEC  (HL)                                            
           LD   A,(HL)                                          
           SUB  28                                              
           JP   NZ,nextlife                                     
                                                                
wnl        LD   A,%10111111                                     
           IN   A,(254)                                         
           RRA                                                  
           JR   C,wnl                                           
           JP   begin                                           
                                                                
cond       DEC  C                                               
c1         INC  DE                                              
           INC  HL                                              
           LD   A,(DE)            ; blocky data                 
           OR   A                                               
           JR   Z,c2              ; no blocky=no test           
           LD   A,(HL)            ; linendata                   
           OR   A                                               
           JR   Z,c2              ; no line to hold blocky      
; blocky may NOT drop, blocky on a line                         
           POP  HL                ; drop return                 
           POP  HL                ; drop HL                     
           POP  HL                ; drop DE                     
           POP  HL                ; drop BC                     
           POP  HL                ; drop AF                     
           RET                    ; end check                   
c2         DEC  C                                               
           JR   NZ,c1                                           
; blocky may drop                                               
           RET                                                  
                                                                
nludg      INC  (HL)                                            
           LD   B,(HL)                                          
           CALL add4                                            
           LD   A,(HL)                                          
           OR   A                                               
           JR   NZ,nludg                                        
           RET                                                  
                                                                
right      LD   A,(HL)                                          
           ADD  A,4                                             
           INC  HL                                              
           OR   (HL)                                            
           AND  31                                              
           RET  Z                                               
           LD   B,4                                             
mright     LD   A,(HL)                                          
           OR   A                                               
           JR   NZ,noswr                                        
           DEC  HL                                              
           INC  (HL)                                            
           INC  HL                                              
           INC  HL                                              
           LD   C,(HL)                                          
           LD   (HL),A                                          
           DEC  HL                                              
           LD   (HL),C                                          
noswr      RR   (HL)                                            
           INC  HL                                              
           RR   (HL)                                            
           INC  HL                                              
           INC  HL                                              
           INC  HL                                              
           DJNZ mright                                          
           RET                                                  
                                                                
left       LD   A,(HL)                                          
           INC  HL                                              
           INC  HL                                              
           OR   (HL)                                            
           DEC  A                                               
           RET  Z                                               
           LD   B,4                                             
mleft      LD   A,(HL)                                          
           OR   A                                               
           JR   NZ,noswl                                        
           DEC  HL                                              
           DEC  HL                                              
           DEC  (HL)                                            
           INC  HL                                              
           LD   C,(HL)                                          
           LD   (HL),A                                          
           INC  HL                                              
           LD   (HL),C                                          
noswl      RL   (HL)                                            
           DEC  HL                                              
           RL   (HL)                                            
           CALL add5                                            
           DJNZ mleft                                           
           XOR  A                                               
           RET                                                  
                                                                
setudg     PUSH BC                                              
           PUSH AF                                              
           LD   A,(HL)                                          
           LD   (BC),A                                          
           INC  HL                                              
           LD   A,(HL)                                          
           INC  HL                                              
           PUSH HL                                              
           LD   H,A                                             
           LD   A,0                                             
setlin2    INC  BC                                              
           LD   (BC),A                                          
           DEC  H                                               
           JR   NZ,setlin2                                      
           POP  HL                                              
           INC  BC                                              
           LD   A,(HL)                                          
           INC  HL                                              
           JR   NC,linedata                                     
           LD   (BC),A                                          
           INC  BC                                              
           LD   A,(HL)                                          
           LD   (BC),A                                          
           INC  BC                                              
           JR   lineok                                          
                                                                
linedata   PUSH HL                                              
           LD   L,(HL)                                          
           LD   H,A                                             
           LD   A,L                                             
line2      LD   (BC),A                                          
           INC  BC                                              
           DEC  H                                               
           JR   NZ,line2                                        
           POP  HL                                              
lineok     XOR  A                                               
           LD   (BC),A                                          
           INC  BC                                              
           LD   A,C                                             
           AND  31                                              
           JR   NZ,lineok                                       
noset2     POP  AF                                              
           POP  BC                                              
           INC  HL                                              
           RET                                                  
                                                                
udgline    DEFB 20,11,%11111111,0                               
           DEFB 19,11,%10111101,0                               
           DEFB 18,11,%11100111,0                               
bx         DEFB 17,11,%11111111,0                               
           DEFB 0                                               
scrline    DEFB 0,0,0,255                                       
           DEFB 0,0,0,255                                       
           DEFB 0,0,0,255                                       
           DEFB 0,0,0,255                                       
           DEFB 0                                               
                                                                
           LD   C,20                                            
rnd        LD   HL,0                                            
           INC  HL                                              
           LD   A,H                                             
           AND  #1F                                             
           LD   H,A                                             
           LD   (rnd+1),HL                                      
           LD   A,(HL)                                          
frnd       SUB  C                                               
           JR   NC,frnd                                         
           ADC  A,C                                             
           RET                                                                                                                 
                                                                
                                                                
                                                                
hr	
           LD   A,#1E                                           
           LD   I,A 
           LD   A,#f5                                           
	ld	hl,screent+#8000
           LD   BC,#201                                         
           CALL #2B5                                            

           LD   B,10                                             
hr0        DJNZ hr0                                             
           LD   HL,screen                                       
           LD   DE,31                                           
           LD   IX,hr2                                          
           LD   B,192                                           
hr1        LD   A,H                                             
           LD   I,A                                             
           LD   A,(HL)                                          
           INC  L                                               
           CP   B                                               
           LD   A,L                                             
           JP   Z,lbuf+#8000                                    
           DEC  HL                                              
           LD   C,8                                             
nohi       DEC  C                                               
           JR   NZ,nohi                                         
                                                                
           LD   A,I                                             
           DEFB 62                                              
hr2        ADD  HL,DE                                           
           DJNZ hr1                                             
                                                                
           EX   (SP),HL                                         
           EX   (SP),HL                                         
           NOP                                                  
           NOP                                                  
           DEC  HL                                              
           INC  HL                                              
           LD   HL,(#400C)                                      
           SET  7,H                                             
                                                                
           CALL #292                                            
           CALL #220                                            
           LD   IX,hr                                           
           JP   #2A4                                            
                                                                
x          EQU  101

screent		db	118	                                             
score      DEFB 28,28,28,28,28,28,0                             
dfile      EQU  score                                           
lifecnt    DEFB 28,0                                            
                                                                
           DEFB "B"+x,"L"+x,"O"+x,"C"+x,"K"+x,"Y"+x,0           
hisc       DEFB 28,28,31,28,36,29                               
           DEFB 118,118                                                                                                             
                                                                
basic      DEFB 0,201                                           
           DEFW lenbas-$                                        
           DEFB 249,212,28                                      
           DEFB 126                                             
           DEFB 143,0,18,0,0                                    
lenbas     DEFB 118                                             
                                                                
; the COPY of the program to make it work on 48K ZX81           
init       LD   HL,#4009                                        
           LD   DE,#C009                                        
           LD   BC,#400                                         
           LDIR                                                 
           LD   IX,hr                                           
           JP   begin                                           
                                                                
                                                                
screen     EQU  #4300                                           
                                                                
vars       DEFB 128                                             
last       EQU  $                                               
