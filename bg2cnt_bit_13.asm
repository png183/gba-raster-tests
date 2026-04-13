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
	; initialize PPU in mode 1
	mov		r4, 0x04000000
	mov		r5, 0x0400
	add		r5, 0x0001
	strh	r5, [r4]  ; enter mode 1 with BG2 enabled

	; move background offscreen by setting bit 15 of BG2X
	mov		r5, 0x8000
	strh	r5, [r4, 0x28]

	; set up HBLANK IRQ
	adr		r5, irq_routine
	str		r5, [r4, -4]  ; set interrupt address
	mov		r5, 0x00000002
	str		r5, [r4, 0x200]  ; enable HBLANK IRQ in IE
	mov		r5, 0x0010
	strh	r5, [r4, 0x004]  ; enable HBLANK IRQ in PPU
	mov		r5, 0x0001
	str		r5, [r4, 0x208]  ; set IME

	; set up PRAM
	mov		r5, 0x05000000
	add		r5, 0x200
	sub		r5, 2
	mov		r6, 0x8000
	sub		r6, 1
	strh	r6, [r5]

	; fill VRAM used by background with white
	mov		r6, 0x06000000
	add		r7, r6, 0x4000
	mov		r8, 0x10000
	sub		r8, 1
vram_loop:
	strh	r8, [r6], 2
	cmp		r6, r7
	bne		vram_loop

idle:
	swi		0x020000  ; Halt
	b		idle

irq_routine:
	mov		r0, 0x04000000
	; acknowledge HBLANK IRQ
	ldr		r1, [r0, 0x200]  ; IE/IF
	str		r1, [r0, 0x200]  ; clear all pending IRQs (todo: only clear IRQ being handled)
	; clear wraparound bit in BG2CNT
	ldrh	r1, [r0, 0x00c]
	bic		r1, 0x2000
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
	; enable wraparound bit in BG2CNT
	ldrh	r1, [r0, 0x00c]
	orr		r1, 0x2000
	strh	r1, [r0, 0x00c]
	bx		r14

