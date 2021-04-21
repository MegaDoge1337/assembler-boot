﻿# MDBoot (boot-file)
## Запуск эмулятора
Репозиторий уже включает все необходимые файлы. Чтобы запустить загрузчик:
- Запустите файл "bochs.exe"
- В открышемся окне нажмите кнопку "Load"
- Выберите в качестве файла конфигураций файл "bochsrc"
- Нажмите кнопку "Start"

## Файлы эмулятора
- bochs.exe - эмулятор
- bochsdbg.exe - эмулятор с дебаггером
- bochsrc - стандартная конфигурация
- bochsrc_dbg - конфигурация для дебаггера
- boot.ASM - нескомпилированный код загрузчика
- boot.BIN - скомпилированный код загрузчика
- disk.img - загрузочный образ
- FASMW.exe - редактор кода
- writeDisk.bat - оперирует утилитами dd и fsutil с целью создания загрузочного образа

## Модификация программного кода
Для модификации программного кода:
- Запустите FASMW (или любую другую программу, которая может скомпилировать файл)
- Откройте файл boot.ASM
- Внесите изменения в код
- Скомпилируйте его (в FASMW "Run" -> "Compile")
- Запустите writeDisk.bat
- Дождитесь окончания процесса (файл disk.img сам перезапишется)
- Запустите эмулятор и проверьте вашу разработку

## Описание блоков (последовательно от начала программы к завершению)
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
- card__map__header - вывод заголока для таблицы секторов карты памяти
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

## Переменные
Большая  часть переменных представляет собой строку и её длинну. В данном загрузчике это необходимо с целью вывода на экран. Поэтому описаны будут только выделяющиеся среди них переменные:
- buffer db 20 dup(?) - буфер для хранения данных о секторах карты памяти (применяется при чтении секторов карты)
- smap__signature - SMAP сигнатура (применяется при чтении секторов карты)
- xlat__table db '0123456789ABCDEF' - таблица для преобразования значения регистра в ASCII-код (применяется при чтении секторов карты и выводе скан кодов клавиш)
- table__pointer dw 820h - курсор таблицы, помогающий позиционировать строки (применяется при чтении секторов карты)
- timer__value dw 0 - значение таймера
- timer__value__string db '' - строка, в которую конвертируется значение таймера для вывода на экран

Переменные old__offset и old__segment предназначены для хранения данных о прерываниях 08h и 09h, которые были заменены в начале выполнения загрузчика.