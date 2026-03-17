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
	add		r5, 0x2400
	strh	r5, [r4]  ; enter mode 3 with BG2 and WIN0 enabled

	; initialize window
	mov		r5, 240
	strh	r5, [r4, 0x040]  ; window enabled for x in [0,240)
	mov		r5, 0x0004
	strh	r5, [r4, 0x04a]  ; enable BG2 outside of window

	; set up HBLANK IRQ
	adr		r5, irq_routine
	str		r5, [r4, -4]  ; set interrupt address
	mov		r5, 0x00000002
	str		r5, [r4, 0x200]  ; enable HBLANK IRQ in IE
	mov		r5, 0x0010
	strh	r5, [r4, 0x004]  ; enable HBLANK IRQ in PPU
	mov		r5, 0x0001
	str		r5, [r4, 0x208]  ; set IME

	; set up VRAM (use striped pattern)
	mov		r4, 0x06000000
	mov		r6, 0
	mov		r7, 0x8000
	sub		r7, 1
	sub		r8, r7, 0x1f
vram_fill_loop_y:
	mov		r5, 0  ; x-counter
vram_fill_loop:
	strh	r7, [r4], 2
	add		r5, 1
	cmp		r5, 240
	bne		vram_fill_loop
	eor		r7, r8  ; swap colour pattern on next scanline
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
	; set initial window range of [0, 160)
	mov		r2, 160
	add		r2, 0x4000
	strh	r2, [r0, 0x044]
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
	; set window end position to match VCOUNT + 1
	add		r1, 1
	strh	r1, [r0, 0x044]
	bx		r14

