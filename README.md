# MDBoot (boot-file) 💾
## Запуск эмулятора ⚡
Репозиторий уже включает все необходимые файлы. Чтобы запустить загрузчик:
- Запустите файл "bochs.exe"
- В открышемся окне нажмите кнопку "Load"
- Выберите в качестве файла конфигураций файл "bochsrc"
- Нажмите кнопку "Start"

## Файлы эмулятора 📑
- bochs.exe - эмулятор
- bochsdbg.exe - эмулятор с дебаггером
- bochsrc - стандартная конфигурация
- bochsrc_dbg - конфигурация для дебаггера
- boot.ASM - нескомпилированный код загрузчика
- boot.BIN - скомпилированный код загрузчика
- disk.img - загрузочный образ
- FASMW.exe - редактор кода
- writeDisk.bat - оперирует утилитами dd и fsutil с целью создания загрузочного образа

## Модификация программного кода 🔧
Для модификации программного кода:
- Запустите FASMW (или любую другую программу, которая может скомпилировать файл)
- Откройте файл boot.ASM
- Внесите изменения в код
- Скомпилируйте его (в FASMW "Run" -> "Compile")
- Запустите writeDisk.bat
- Дождитесь окончания процесса (файл disk.img сам перезапишется)
- Запустите эмулятор и проверьте вашу разработку

## Дебаггинг программного кода 🔎
Для проведения процедуры дебаггинга кода:
- Запустите FASMW (или любую другую программу, которая может скомпилировать файл)
- Откройте файл boot.ASM
- В необходимое место установите брейкпоинт (впишите 'xchg bx, bx')
- Скомпилируйте его (в FASMW "Run" -> "Compile")
- Запустите writeDisk.bat
- Дождитесь окончания процесса (файл disk.img сам перезапишется)
- Запустите эмулятор (!bochsdbg), в качестве файле конфигурации выберите borchs_dbg и проводите процедуру отладки (для перехода к точке остановки нажмите кнопку 'Continue', для единичного шага нажмите кнопку 'Step')

## Описание блоков (последовательно от начала программы к завершению) 📚
- boot__code16 - обязательная часть загрузчика
- boot__continuation - продолжение выполнения загрузочного кода после выполнения обязательной части
- timer__int - код прерывания таймера
- convert__timer__value - выполнение прерывания: конвертирование значения таймера в строку цифр
- timer__value__out - выполнение прерывания: вывод сконвертированной строки таймера
- keyboard__int - код прервывания клавиатуры
- reboot - выполнение прерывания: перезагрузки эмулятора (Ctrl+Break)
- no__reboot - выполнение прерывания: без перезагрузки эмулятора
- ints__install - установка прерываний
- clear__display - очистка дисплея
- welcome - вывод приветственного сообщения
- check__floppy - проверка на наличие floppy-привода
- have__floppy - если floppy-привод подключён
- have__floppy__out - вывод сообщения о подключённом floppy-приводе
- no__floppy - если floppy-привод не подключён
- no__floppy__out -  вывод сообщения об отсутствии floppy-приводе
- check__coprocessor - проверка на наличие сопроцессора
- have__coprocessor - если сопроцессор установлен
- have__coprocessor__out - вывод сообщения о установленном сопроцессоре
- no__coprocessor - если сопроцессор не установлен
- no__coprocessor__out - вывод сообщения о не установленном сопроцессоре
- check__ram__size - проверка количества оперативной памяти
- ram__size__out - вывод префикса
- ram__size__value__out - вывод значения
- check__video__mode - проверка видеорежима
- video__mode__out - вывод префикса
- check__mode__40x25__color - проверка на режимы (в названии блока допущена ошибка, эта проверка обрабатывает все видеорежимы, а не только "40x25 Color")
- mode__40x25__color__out - вывод сообщения о видеорежиме "40x25 Color"
- mode__80x25__color__out - вывод сообщения о видеорежиме "80x25 Color"
- mode__80x25__mono__out - вывод сообщения о видеорежиме "80x25 Mono"
- check__number__of__floppy - проверка количества floppy-приводов
- number__of__floppy__out - вывод префикса
- number__of__floppy__value__out - вывод значения
- check__dma - проверка DMA
- dma__enable - если DMA включён
- dma__enable__out - вывод сообщения о включённом DMA
- dma__disable - если DMA выключен
- dma__disable__out - вывод сообщения о выключенном DMA
- number__of__rs232__cards - проверка количества RS-232 карт
- number__of__rs232__cards__out - вывод префикса
- number__of__rs232__cards__value__out - вывод значения
- check__game__port - проверка "Game port"
- game__port__enable - если "Game port" включен
- game__port__enable__out - вывод сообщения о включённом "Game port"
- game__port__disable - если "Game port" выключен
- game__port__disable__out - вывод сообщения о выключенном "Game port"
- check__internal__modem - проверка наличия встроенного модема
- internal__modem__installed - если модем установлен
- internal__modem__installed__out - вывод сообщения об установленном модеме
- internal__modem__not__installed - если модем не установлен
- internal__modem__not__installed__out - вывод сообщения об отсутствии модема
- number__of__printers__attached - проверка количества подклчючённых принтеров
- number__of__printers__attached__out - вывод префикса
- number__of__printers__attached__value__out - вывод значения
- card__map__header - вывод заголовка для таблицы секторов карты памяти
- card__map__read__start - подготовка к получению информации о секторах
- card__map__reading - получение информации о секторах при помощи int 0x15 ax = 0E820h
- base__addr__high__out - вывод BaseAddrHigh
- base__addr__low__out - вывод BaseAddrLow
- length__high__out - вывод LengthHigh
- length__low__out - вывод LengthLow
- type__is__arm - проверка типа на "ARM"
- type__is__arr - проверка типа на "ARR"
- type__is__udf - проверка типа на "UDF" (undefined)
- type__out - вывод типа и проверка на завешение процесса чтения
- terminate - завершение выполнения (прерывания таймера и клавиатуры всё ещё работают)

## Переменные 📋
Большая  часть переменных представляет собой строку и её длинну. В данном загрузчике это необходимо с целью вывода на экран. Поэтому описаны будут только выделяющиеся среди них переменные:
- buffer db 20 dup(?) - буфер для хранения данных о секторах карты памяти (применяется при чтении секторов карты)
- smap__signature - SMAP сигнатура (применяется при чтении секторов карты)
- xlat__table db '0123456789ABCDEF' - таблица для преобразования значения регистра в ASCII-код (применяется при чтении секторов карты и выводе скан кодов клавиш)
- table__pointer dw 820h - курсор таблицы, помогающий позиционировать строки (применяется при чтении секторов карты)
- timer__value dw 0 - значение таймера
- timer__value__string db '' - строка, в которую конвертируется значение таймера для вывода на экран
- off__08h equ 08hx4 (где 'x' - умножение, т.к. .md принимает символ звёздочки за указатель на курсив) - константа сдвига (херня для вектора прерываний, удалять не рекомендуется, ибо нехуй)
- off__09h equ 09hx4 (где 'x' - умножение, т.к. .md принимает символ звёздочки за указатель на курсив) - константа сдвига (херня для вектора прерываний, удалять не рекомендуется, ибо нехуй)

Переменные old__offset и old__segment предназначены для хранения данных о прерываниях 08h и 09h, которые были заменены в начале выполнения загрузчика.

# MDBoot (boot-file) 💾 [en - Google Translater]
## Launch the emulator ⚡
The repository already includes all the required files. To start the bootloader:
- Run the file "bochs.exe"
- In the window that opens, click the "Load" button
- Select the "bochsrc" file as the configuration file
- Click the "Start" button

## Emulator files 📑
- bochs.exe - emulator
- bochsdbg.exe - emulator with debugger
- bochsrc - standard configuration
- bochsrc_dbg - configuration for debugger
- boot.ASM - uncompiled bootloader code
- boot.BIN - compiled bootloader code
- disk.img - boot image
- FASMW.exe - code editor
- writeDisk.bat - operates with dd and fsutil utilities to create a bootable image

## Modification of the program code 🔧
To modify the program code:
- Run FASMW (or any other program that can compile the file)
- Open the boot.ASM file
- Make changes to the code
- Compile it (in FASMW "Run" -> "Compile")
- Run writeDisk.bat
- Wait until the end of the process (the disk.img file will overwrite itself)
- Start the emulator and check your development

## Debugging program code 🔎
To perform the code debugging procedure:
- Run FASMW (or any other program that can compile the file)
- Open the boot.ASM file
- Set the breakpoint in the required place (enter 'xchg bx, bx')
- Compile it (in FASMW "Run" -> "Compile")
- Run writeDisk.bat
- Wait until the end of the process (the disk.img file will overwrite itself)
- Start the emulator (! Bochsdbg), select borchs_dbg as the configuration file and carry out the debugging procedure (to go to the breakpoint, press the 'Continue' button, for a single step, press the 'Step' button)

## Description of blocks (sequentially from the beginning of the program to the end) 📚
- boot__code16 - required part of the bootloader
- boot__continuation - continuation of the boot code execution after the required part has been completed
- timer__int - timer interrupt code
- convert__timer__value - interrupt execution: converting the timer value to a string of numbers
- timer__value__out - interrupt execution: output of the converted timer string
- keyboard__int - keyboard interrupt code
- reboot - interrupt execution: reboot the emulator (Ctrl + Break)
- no__reboot - interrupt execution: without rebooting the emulator
- ints__install - install interrupts
- clear__display - clear the display
- welcome - display a welcome message
- check__floppy - check for a floppy drive
- have__floppy - if a floppy drive is connected
- have__floppy__out - display a message about a connected floppy drive
- no__floppy - if no floppy drive is connected
- no__floppy__out - display a message about the absence of a floppy drive
- check__coprocessor - check for the presence of a coprocessor
- have__coprocessor - if coprocessor is installed
- have__coprocessor__out - display a message about the installed coprocessor
- no__coprocessor - if coprocessor is not installed
- no__coprocessor__out - display a message about not installed coprocessor
- check__ram__size - check the amount of RAM
- ram__size__out - prefix output
- ram__size__value__out - value output
- check__video__mode - check the video mode
- video__mode__out - prefix output
- check__mode__40x25__color - check for modes (there was a mistake in the block name, this check processes all video modes, not just "40x25 Color")
- mode__40x25__color__out - displays a message about the video mode "40x25 Color"
- mode__80x25__color__out - displays a message about the video mode "80x25 Color"
- mode__80x25__mono__out - displays a message about the video mode "80x25 Mono"
- check__number__of__floppy - check the number of floppy drives
- number__of__floppy__out - prefix output
- number__of__floppy__value__out - display value
- check__dma - check DMA
- dma__enable - if DMA is enabled
- dma__enable__out - display a message about enabled DMA
- dma__disable - if DMA is disabled
- dma__disable__out - display a message about disabled DMA
- number__of__rs232__cards - check the number of RS-232 cards
- number__of__rs232__cards__out - prefix output
- number__of__rs232__cards__value__out - value output
- check__game__port - check "Game port"
- game__port__enable - if "Game port" is enabled
- game__port__enable__out - displays a message about the enabled "Game port"
- game__port__disable - if "Game port" is disabled
- game__port__disable__out - displays a message about disabled "Game port"
- check__internal__modem - check for a built-in modem
- internal__modem__installed - if the modem is installed
- internal__modem__installed__out - displays a message about the installed modem
- internal__modem__not__installed - if the modem is not installed
- internal__modem__not__installed__out - displays a message about the absence of a modem
- number__of__printers__attached - check the number of connected printers
- number__of__printers__attached__out - prefix output
- number__of__printers__attached__value__out - value output
- card__map__header - display the header for the table of sectors of the memory card
- card__map__read__start - preparation for getting information about sectors
- card__map__reading - getting information about sectors using int 0x15 ax = 0E820h
- base__addr__high__out - BaseAddrHigh output
- base__addr__low__out - BaseAddrLow output
- length__high__out - output LengthHigh
- length__low__out - Output of LengthLow
- type__is__arm - checking the type for "ARM"
- type__is__arr - checking the type for "ARR"
- type__is__udf - type check for "UDF" (undefined)
- type__out - type inference and check for termination of the reading process
- terminate - termination of execution (timer and keyboard interrupts are still working)

## Variables 📋
Most of the variables represent a string and its length. In this loader, this is necessary for the purpose of displaying. Therefore, only the variables that stand out among them will be described:
- buffer db 20 dup (?) - buffer for storing data about the sectors of the memory card (used when reading the sectors of the card)
- smap__signature - SMAP signature (used when reading map sectors)
- xlat__table db '0123456789ABCDEF' - a table for converting the register value to ASCII code (used when reading card sectors and outputting scanned key codes)
- table__pointer dw 820h - table cursor that helps position rows (used when reading map sectors)
- timer__value dw 0 - timer value
- timer__value__string db '' - a string into which the timer value is converted to be displayed on the screen
- off__08h equ 08hx4 (where 'x' is multiplication, since .md takes an asterisk as a pointer to italics) - shift constant (bullshit for the interrupt vector, it is not recommended to delete it, because fuck it)
- off__09h equ 09hx4 (where 'x' is multiplication, since .md takes an asterisk as a pointer to italics) - shift constant (bullshit for the interrupt vector, it is not recommended to delete, because fuck it)
