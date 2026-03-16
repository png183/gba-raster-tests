format binary as 'gba'

header:
	; header (to be filled by gbafix)
	b		entrypoint
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	db		0,0,0,0,0,0,0,0,0,0,0,0

entrypoint:
	; copy from ROM to IWRAM, then run from IWRAM
	adr		r0, iwram_entrypoint
	mov		r1, 0x03000000
	mov		r2, 0x1f80  ; 0x7e00 bytes
	swi		0x0c0000  ; CpuFastSet
	mov		r4, 0x03000000
	bx		r4

iwram_entrypoint:
	; initialize PPU in mode 3
	mov		r4, 0x04000000
	mov		r5, 0x03
	add		r5, 0x0400
	strh	r5, [r4]  ; enter mode 3 with BG2 enabled

	; set mosaic size to 7x7
	mov		r5, 0x66
	strh	r5, [r4, 0x4c]

	; flip mosaic bit in BG2CNT
	ldrh	r5, [r4, 0x00c]
	eor		r5, 0x0040
	strh	r5, [r4, 0x00c]

	; set up HBLANK IRQ
	adr		r5, irq_routine
	str		r5, [r4, -4]  ; set interrupt address
	mov		r5, 0x00000002
	str		r5, [r4, 0x200]  ; enable HBLANK IRQ in IE
	mov		r5, 0x0010
	strh	r5, [r4, 0x004]  ; enable HBLANK IRQ in PPU
	mov		r5, 0x0001
	str		r5, [r4, 0x208]  ; set IME

	; set up VRAM (use checkerboard pattern)
	mov		r4, 0x06000000
	mov		r6, 0  ; y-counter
	mov		r7, 0  ; colour data
	mov		r8, 0x8000  ; colour mask (0x7fff)
	sub		r8, 1
vram_fill_loop_y:
	mov		r5, 0  ; x-counter
vram_fill_loop:
	strh	r7, [r4], 2
	eor		r7, r8
	add		r5, 1
	cmp		r5, 240
	bne		vram_fill_loop
	eor		r7, r8  ; invert colour pattern on next scanline
	add		r6, 1
	cmp		r6, 160
	bne		vram_fill_loop_y

idle:
	swi		0x020000  ; Halt
	b		idle

irq_routine:
	mov		r0, 0x04000000
	; acknowledge HBLANK IRQ
	ldr		r1, [r0, 0x200]  ; IE/IF
	str		r1, [r0, 0x200]  ; clear all pending IRQs (todo: only clear IRQ being handled)
	; flip mosaic bit in BG2CNT
	ldrh	r1, [r0, 0x00c]
	eor		r1, 0x0040
	strh	r1, [r0, 0x00c]
	; determine what scanline we're on
	ldrh	r1, [r0, 0x006]  ; VCOUNT
	; 256-cycle max clock slide
	add		r15, r1, lsl 2
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	dw		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1
	; flip mosaic bit in BG2CNT
	ldrh	r1, [r0, 0x00c]
	eor		r1, 0x0040
	strh	r1, [r0, 0x00c]
	bx		r14

