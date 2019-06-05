/*
The perpose of this code is to put the fbPointer variable (frame buffer pointer) at the start of iwram.
The reason for this is to speed up the frequent fbPointer access by replacing "ldr r0, =fbPointer" with "mov r0, 0x03000000".
This code will generate the warning "redeclaration of memory region `iwram'". This is initentional but I'm unsure how to resolve this warning without modifing the default linker scripts.
*/
MEMORY {
	reserved_iwram : ORIGIN = 0x03000000, LENGTH = 0x4
	iwram : ORIGIN = 0x03000004, LENGTH = 32K - 0x4
}
SECTIONS
{
	__fbPointer_start = 0x03000000;
	. = __fbPointer_start;
	.fbPointer __fbPointer_start :
    {
		. = ALIGN(4);
        fbPointer = 0x0;
		. = ALIGN(4);
    } > reserved_iwram
}

