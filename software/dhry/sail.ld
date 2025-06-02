OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)

ENTRY(_start)

SECTIONS
{
	. = 0x00;
	.text . :
	{
		_text = . ;
		*(.text) 
		. = 0x2100;
		*(.strings)
		_etext = . ;
	}

	.data . :
	{
		*(.data)
	}

	.bss . :
	{ 	
		_bss = .;
		*(.bss)
		_ebss = .;
	}
}
