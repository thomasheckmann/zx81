; Beepstrap paradox
; game 150 for the ZX81
; (c) 2026 Johan "Dr Beep" Koelman

lines	equ	14
rsize	equ	23
bg	equ	128

field	equ	#4000
scrpos	equ	field+4

lastkok	equ	lastkc-fieldc-(lastk-field)
frameok	equ	framesc-fieldc-(frames-field)
rnd	equ	rndc-fieldc+#4000
up	equ	upc-fieldc+#4000
left	equ	leftc-fieldc+#4000
right	equ	rightc-fieldc+#4000
down	equ	downc-fieldc+#4000
shwdir	equ	shwdirc-fieldc+#4000
getidea	equ	getidc-fieldc+#4000

t1	equ	#4280			; hardcoded locations due to packed screen
t2	equ	#4389


	org 	#4009

; in LOWRES more sysvar are used, but in this way the shortest code
; over sysvar to start machinecode. This saves 11 bytes of BASIC

; DO NOT CHANGE AFTER BASIC+3 (=DFILE)
basic   ld	h,fieldc / 256		; high byte of screen
        jr 	init1			; next part of init

free	db 	236			; BASIC over DFILE data
	db 	212,37			
	db 	126,143,0,18

eline	dw 	last

chadd	dw 	last-1
	
keys	db 	0,0,0,0,0,0		; x
berg	db 	0			; x

mem	db 	0,0			; x OVERWRITTEN ON LOAD

init1	xor	a		
	ld	d,b
	jr	init2			; next part of init
		
lastk	db 	0,0,0
margin  db 	55

nxtlin  dw 	basic			; BASIC-line over sysvar	

init2	ld	sp,dfile+1024
	
	ld 	l,fieldc mod 256
	db 	0,0			; x used by ZX81, not effective code after loading
	
	ld	e,a			; DE now #4000
	db	#da			; skip frames so USB loader will work too with JP C never true from XOR A

frames  db	255,255			; frames can be used by USB-loader 
	ld	c,erout-fieldc		; BC now #40size
	jp 	init4			; now final part coded after packed screen	

cdflag  db 	64
; DO NOT CHANGE SYSVAR ABOVE!

	db	place mod 256		; 4 place idea elsewhere
	db	rotr mod 256		; 3
	db	rotl mod 256		; 2
	db	fward mod 256		; 1

dirtab	db	%11111110		; 4 place action will record as NOP
	db	2
	db	%11011111		; 3
	db	1
	db	%11011111		; 2
	db	2
	db	%11111011		; 1
	db	1

dirp	db	down mod 256
	db	right mod 256
	db	up mod 256
	db	left mod 256	

rotr	dec	c
	db	62
rotl	inc	c
bnd	ld	a,c
	and	3
	ld	c,a
	ret
		
fward	ld	a,c
	add	a,dirp mod 256
	ld	l,a
	ld	l,(hl)
	call	#7d
	db	#18,jrcalc		; jr scrpos
jrcalc	equ	256-($-#4004) mod 256

place	ld	hl,getidea
	ld	a,(hl)
	add	a,(hl)
	ret	p			; not taken so don't place idea
	
	ld	(hl),l			; no longer carrying idea reset bit6

	call	scrpos
	cp	27+128			; is it on destination?	
	jp	nz,desterr		; destination error is a paradox

	ld	(hl),23+128		; replace as "*"

	ld	b,9
addp	inc	b			; 1 bonuspoint so B<>0
addst	ld	hl,score+5
	db	#3a			; skip resetting to "0"
ten	ld	(hl),28
	dec	hl
	inc	(hl)
	ld	a,(hl)
	cp	38			; test > "9"
	jr	z,ten
	djnz	addst
	ret
	
eog	ld	l,score mod 256 -1
	ld	de,hiscore-1
	ld	bc,6
fihi	dec	bc
	inc	hl
	inc	de
	ld	a,(de)
	cp	(hl)
	jr	z,fihi
	call	c,#a6e

start	ld	a,(lastk)
	sub	191
	jr	nz,start

	ld	hl,score
ersc	ld	(hl),28
	inc	hl
	cp	(hl)
	jr	nz,ersc

	ld	a,32
	ld	(lives),a

pardead	ld	hl,lives
	dec	(hl)
	ld	a,(hl)
	cp	28
	jr	z,eog

	ld	d,h			; Y recorded Dr Beep starts out of screen

	ld	l,screen mod 256
cllp	ld	(hl),128
lnfd	inc	hl
	ld	a,(hl)
	cp	#76
	jr	z,lnfd
	cp	#e9	
	jr	nz,cllp			; clearscreen
	
	exx

	ld	de,1			; first startposition
	ld	c,d			; first direction

	ld	hl,#4400-70		; erase old recordings other games

clrrec	ld	(hl),a
	inc	l
	jr	nz,clrrec
	
	ld	(getidea),hl		; this will set ghostidea taken but that will reset again

levloop jr	nz,pardead
	exx
	push	de			; save current recorded xy

	ld	hl,frames
	ld	a,(hl)
	sub	h			; >1 sec del before next level
wfr2	cp	(hl)
	jr	nz,wfr2

	xor	a
	ld	(getidea+1),a		; reset ideas taken

rndseed	ld	hl,#0400		; randomseed 
	call	rnd			; get randomized number in A
frndy	sub	lines/2
	jr	nc,frndy	
	add	a,lines/2+4
	ld	d,a
	call	rnd			; get randomized number in A
frndx	ld	e,a
	sub	rsize/2
	jr	nc,frndx
	adc	a,rsize/2+4
	ld	e,a
	ld	(rndseed+1),hl		; save new seed
	call	scrpos
	add	a,a			; field free?
	jr	nz,rndseed
	ld	(hl),15+128		; show "?" as ideamarker
	pop	de
	
notlv1	ld	hl,#4400-70		; start of recording/playback
	ld	b,4			; 4 recordings in a field
	exx

	push	de			; start player XY is in level next XY computer
	push	bc			; save start watchdirection
ploop	call	scrpos
	push	hl
; 27 .
; 23 *
; 15 ?
	cp	27+128			; is it destination
	jr	z,erasall		; keep it
	cp	23+128			; is it ghostidea?
	jr	z,erasall		; keep it
	cp	15+128			; is it "?"
	ld	a,128
	jr	nz,erasall		; erase whatever was here
	ld	a,(hl)
	ld	hl,getidea
	bit	6,(hl)			; test earlier taken, if so then placed here
	jr	nz,erasall		; if so, don't take again	
	ld	(hl),h			; signal player has idea
	ld	a,27+128		; destination next idea
erasall	ld	b,a
	ld	a,c
	ld	l,a
	ld	h,64
	ld	a,(hl)
	pop	hl
	ld	(hl),a			; show player Dr Beep
	push	bc
	push	hl

	exx
	push	hl			; save recording pointer

	push	de			; save ghost xy
	push	bc 
	ld	b,a			; save player display
	call	scrpos
vwtlp	cp	b
	jp	z,desterr+1
	ld	h,64
	call	fward			; move forward	
	jr	nc,vwtlp		; not yet at end
	pop	bc
	pop	de

	call	scrpos			; get current screen recorded Dr Beep

	jr	nc,dodisp		; no display out of screen (first play)

	ld	hl,0			; point to ROM ( 0 for SP-2-ZX emulator ROM unprotected but 0 not used by emulator)	

dodisp

	cp	23+128			
	push	hl			; save screenlocation
	jr	nz,noidea
	ld	hl,getidea+1
	ld	(hl),h			; signal idea taken

	exx
	push	hl
	xor	a			; end of recording
	sub	l			; subtract recorderpointer
	ld	b,a			; save score in B
	call	addp			; add B+1 points
	pop	hl
	exx

noidea

	ld	l,c			; get direction
	ld	h,64
	ld	a,(hl)			; get directiondisplay

	pop	hl			; get screenlocation
	res	7,a			; show recorded as inverted character
	ld	(hl),a			; show recorded Dr Beep
	ex	(sp),hl			; save for restorebackground
	exx

	ld	hl,frames
	ld	a,(hl)
	sub	10			; 5 recordings / second on 50 mhz
wfr	cp	(hl)
	jr	nz,wfr

	pop	hl
	ld	(hl),128		; repair recorded background

	pop	hl
	pop	af
	ld	(hl),a			; repair played background

	ld	hl,t1-2
	ld	(hl),"T"+101		; place timemachines on screen
	ld	hl,t2+1
	ld	(hl),"T"+101		; place timemachines on screen

	ld	b,4
	ld	hl,dirtab-1
dirlp	inc	hl
	ld	a,(hl)
	in	a,(254)
	inc	hl
	and	(hl)
	jr	z,dodir
	djnz	dirlp
	
dodir	call	z,dodir2

; here we have placed action in B which we need to record but also do the recorded move in (HL') 

	ld	a,b			; get player action
	exx
	push	bc			; save loopcounter and direction recorded
	ld 	b,(hl)			; get recorded data
	rra				; shift bit0 from player into C
	rr	(hl)			; shift C into bit7
	rra				; shift bit1 from player into C
	rr	(hl)			; shift C into bit7, player action now in b7b6

	xor	a
	sub	l			; remaining time, 71 ...... 1
	rrca				
	rrca
	rrca				; divide by 8
	and	15			; display 9....1 only
	add	a,29			; make it a number
	ld	(timer),a		; show timer

	ld	a,b			; get recorded data
	and	3			; keep bit1 and bit0 only
	pop	bc			; get loopcounter and direction

	djnz	recinhl+1		; stlll recording in current field
	ld	b,4			; set counter for next 4 recordings
	inc	l			; go to next recordfield, also test end reached
	jr	z,levend		; level end, test valid next level

	push	af

	ld	a,%11111101
	in	a,(254)
	and	2			; S=STOP REC
	jr	nz,recinhl		

errec1	ld	(hl),a			; erase any old recording
	inc	l
	jr	nz,errec1		; erase recording to end

	exx
desterr	exx				; we need a test with ghost first
	ld	sp,dfile-4+1024		; 3 entries with different regs on stack, 1 solution
levend	ld	a,d

	pop	bc			; past Dr Beep gets start direction future Dr Beep
	pop	de			; past Dr Beep gets start future Dr Beep

	cp	lines
	ld	hl,getidea+1
	jr	nc,p2test		; test 1st screenloop

	xor	a
	cp	(hl)
	jr	z,pardjp		; ghost did not get idea

p2test	dec	hl			; now playertest
	bit	6,(hl)			; test idea taken
pardjp	jp	z,pardead		; player did not carry idea		

	exx
	call	scrpos
	sub	"T"+101			; player on timemachine?
	jp	levloop			; do next loop when on timemachine



recinhl	pop	af
	push	hl
	push	bc			; save loopcounter!
	ld	b,a			; recorded direction to B
	call	dodir2			; do the move held in B
	pop	hl			; NOT POP BC, C can alter in dodir2
	ld	b,h			; set back loopcounter
	pop	hl			; get recording back
	exx
	jp	ploop

	

dodir2	xor	a
	sub	b			; -b
	ret	z			; never true with player
	add	a,dirtab mod 256
	ld	l,a
	ld	h,dirtab / 256		; make H point OK
	push	de			; save XY
	ld	l,(hl)			; get move
	call	#7d			; JP (HL) in the ROM
	pop	hl
	ret	nc			; legal move
	ld	d,h			; undo move
	ld	e,l
	ret

norm1	inc	b			; a single unpack, B becomes 1
unpack	ld 	a,(hl)			; get copy byte
	ld 	(de),a			; write to unpacklocation
	dec 	de			; next destination
	ex	af,af'			; delay display until after unpacking
	djnz 	unpack			; copy loop
	dec 	hl			; go to next compressed location
	ld 	a,(hl)			; get data
	sub 	192			; test packed
	jr 	c,norm1			; not packed, 1 byte
	ld 	b,a			; repeater to B
	dec 	hl			; point to byte
	sub 	#e9-192			; test end reached
	jr 	nz,unpack		; unpack the screen
	jp	start			; start the game


	block	#421f+10-$,0


dfile 	db 	118

score	db	"N"-27,"L"-27,118,#e9,28,0
lives	db	0,0
	db	"B"+101,"E"+101,"E"+101,"P"+101,"S"+101,"T"+101,"R"+101,"A"+101,"P"+101,0
hiscore	db	22,28+1,28+5,28+0,22,118

timer	db	28

	db	0
	ld	d,(hl) 			
	ld	d,(hl)	
	ld	d,(hl)
	ld	d,(hl)

	db	"P"+101,"A"+101,"R"+101,"A"+101,"D"+101,"O"+101,"X"+101,118,118

screen	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
	db	bg,192+rsize
	db 	118
endscr	db	#e9



; one time routine routines placed on recording area
init4	ld	b,e
	ldir				; copy routines over sysvar
	ld	hl,endscr
	ld	de,#4400-71
	jp	norm1

fieldc

shwdirc	db	"D"+101
	db	"R"+101
	db	"U"+101
	db	"L"+101

	ld	a,lines
	cp	d
	ret	c			; out of screen vertically
	push	de
	xor	a	
	ld	h,a
	db	#da			; JP C never true to skip DFILE
dfilec	dw 	dfile			; DFILE, not codeable in lowres
	ld	a,d
	add	a,a			;  2B
	add	a,d			;  3B
	add	a,a			;  6B
	add	a,a			; 12B
	ld	l,a
	ld	d,h
	add	hl,hl			; 24B
	add	hl,de			; 16B+C	
	ld	de,screen-1
	add	hl,de			; startposition maze added
	pop	de
	ld	a,(hl)			; get field value
	cp	#7f			; out of screen horizontally
	ret	

upc	dec	d
	ret

leftc	dec	e
	ret

	db	0

lastkc	db	255,255,255
marginc	db	55

rightc	inc	e
	ret

downc	inc	d
	ret

getidc	db	0,0			; datafields if player or recorded has taken an idea

rndc	ld	a,r			; random part1: R-register
	add	a,(hl)			; random part2: add seed
	push	de
	db	17
framesc	dw	65535
	add	a,e			; random part3: add framescount 
	pop	de
	inc	l			; point to next recording
	ret

erout


vars    db 128			
last	equ $   	

end