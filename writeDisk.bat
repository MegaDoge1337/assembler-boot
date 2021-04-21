fasm.exe boot.asm boot.bin
del disk.img
fsutil file createnew disk.img 1474560
dd if=boot.bin of=disk.img
pause