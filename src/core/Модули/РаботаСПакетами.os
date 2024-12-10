#Использовать fluent
#Использовать fs
#Использовать logos
#Использовать tempfiles

Перем Лог;
Перем ВнутреннийМенеджерПолученияПакетов;

Процедура ОбновитьУстановленныеПакеты(Знач РежимУстановки, Знач ЦелевойКаталог = Неопределено, Знач НастройкаУстановки = Неопределено) Экспорт
	
	КэшУстановленныхПакетов = ПолучитьУстановленныеПакеты(РежимУстановки);
	УстановленныеПакеты = КэшУстановленныхПакетов.ПолучитьУстановленныеПакеты();
	Для Каждого КлючИЗначение Из УстановленныеПакеты Цикл
		ИмяПакета = КлючИЗначение.Ключ;

		МенеджерПолучения = ПолучитьМенеджерПолученияПакетов();
	
		Если Не МенеджерПолучения.ПакетДоступен(ИмяПакета) Тогда
			Лог.Предупреждение("Ошибка обновления пакета %1: Пакет не найден в хабе", ИмяПакета);
			Продолжить;
		КонецЕсли;

		ОбновитьПакетИзОблака(ИмяПакета, РежимУстановки, ЦелевойКаталог, НастройкаУстановки);
		
	КонецЦикла;

КонецПроцедуры

Функция ПолучитьМенеджерПолученияПакетов() 

	Если ВнутреннийМенеджерПолученияПакетов = Неопределено Тогда
		ВнутреннийМенеджерПолученияПакетов = Новый МенеджерПолученияПакетов;
	КонецЕсли;

	Возврат ВнутреннийМенеджерПолученияПакетов;
	
КонецФункции

Функция ПолучитьУстановленныеПакеты(РежимУстановки)
	
	КаталогУстановкиЗависимостей = ПолучитьКаталогСистемныхБиблиотек();

	Если РежимУстановки = РежимУстановкиПакетов.Локально Тогда
		КаталогУстановкиЗависимостей = ОбъединитьПути(
			ТекущийКаталог(),
			КонстантыOpm.ЛокальныйКаталогУстановкиПакетов
		);
	КонецЕсли;

	КэшУстановленныхПакетов = Новый КэшУстановленныхПакетов(КаталогУстановкиЗависимостей);

	Возврат КэшУстановленныхПакетов;

КонецФункции

Функция ПолучитьНастройкуУстановки() Экспорт

	Настройка = Новый Структура();
	Настройка.Вставить("УстанавливатьЗависимости", Истина);
	Настройка.Вставить("УстанавливатьЗависимостиРазработчика", Ложь);
	Настройка.Вставить("СоздаватьФайлыЗапуска", Истина);
	Настройка.Вставить("ИмяСервера", "");

	Возврат Настройка;
	
КонецФункции

Процедура УстановитьПакетИзОблака(Знач ИмяПакета, Знач РежимУстановки, Знач ЦелевойКаталог, Знач НастройкаУстановки = Неопределено) Экспорт
	
	Лог.Отладка("Устанавливаю пакет <%1> из доступного хаба", ИмяПакета);
	ИмяВерсияПакета = РаботаСВерсиями.РазобратьИмяПакета(ИмяПакета);
	ЭтоЗависимость = Ложь;
	Если РежимУстановки = РежимУстановкиПакетов.Локально Тогда
		ЭтоЗависимость = Истина;
	КонеЦесли;

	Если НастройкаУстановки = Неопределено Тогда
		НастройкаУстановки = ПолучитьНастройкуУстановки();
	КонецЕсли;

	МенеджерУстановки = Новый МенеджерУстановкиПакетов(РежимУстановки, ЦелевойКаталог, , НастройкаУстановки.ИмяСервера);
	МенеджерУстановки.УстанавливатьЗависимости(НастройкаУстановки.УстанавливатьЗависимости);
	МенеджерУстановки.СоздаватьФайлыЗапуска(НастройкаУстановки.СоздаватьФайлыЗапуска);
	МенеджерУстановки.УстанавливатьЗависимостиРазработчика(НастройкаУстановки.УстанавливатьЗависимостиРазработчика);
	МенеджерУстановки.УстановитьПакетПоИмениИВерсии(ИмяВерсияПакета.ИмяПакета, ИмяВерсияПакета.Версия, ЭтоЗависимость);
	
КонецПроцедуры

Процедура УстановитьПакетИзФайла(Знач ИмяФайлаПакета,
								 Знач РежимУстановки, 
								 Знач ЦелевойКаталог = Неопределено, 
								 Знач НастройкаУстановки = Неопределено) Экспорт
	
	Если НастройкаУстановки = Неопределено Тогда
		НастройкаУстановки = ПолучитьНастройкуУстановки();
	КонецЕсли;

	МенеджерУстановки = Новый МенеджерУстановкиПакетов(РежимУстановки, ЦелевойКаталог, , НастройкаУстановки.ИмяСервера);
	МенеджерУстановки.УстанавливатьЗависимости(НастройкаУстановки.УстанавливатьЗависимости);
	МенеджерУстановки.УстанавливатьЗависимостиРазработчика(НастройкаУстановки.УстанавливатьЗависимостиРазработчика);
	МенеджерУстановки.СоздаватьФайлыЗапуска(НастройкаУстановки.СоздаватьФайлыЗапуска);
	МенеджерУстановки.УстановитьПакетИзАрхива(ИмяФайлаПакета);
	
КонецПроцедуры

Процедура УстановитьВсеПакетыИзОблака(Знач РежимУстановки, Знач ЦелевойКаталог = Неопределено, 
										Знач НастройкаУстановки = Неопределено) Экспорт

	МенеджерПолучения = ПолучитьМенеджерПолученияПакетов();
	КешПакетов = МенеджерПолучения.ПолучитьДоступныеПакеты();

	Для Каждого КлючИЗначение Из КешПакетов Цикл
		УстановитьПакетИзОблака(КлючИЗначение.Ключ, РежимУстановки, ЦелевойКаталог, НастройкаУстановки);
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбновитьПакетИзОблака(Знач ИмяПакета, Знач РежимУстановки, Знач ЦелевойКаталог = Неопределено, Знач НастройкаУстановки = Неопределено) Экспорт
	
	УстановитьПакетИзОблака(ИмяПакета, РежимУстановки, ЦелевойКаталог, НастройкаУстановки);

КонецПроцедуры

Процедура УстановитьПакетыПоОписаниюПакета(Знач РежимУстановки, Знач ЦелевойКаталог = Неопределено, Знач НастройкаУстановки = Неопределено) Экспорт
	
	ОписаниеПакета = РаботаСОписаниемПакета.ПрочитатьОписаниеПакета();
	
	РаботаСОписаниемПакета.ПроверитьВерсиюСреды(ОписаниеПакета);
	
	Если НастройкаУстановки = Неопределено Тогда
		НастройкаУстановки = ПолучитьНастройкуУстановки();
	КонецЕсли;

	МенеджерУстановки = Новый МенеджерУстановкиПакетов(РежимУстановки, , , НастройкаУстановки.ИмяСервера);
	МенеджерУстановки.УстанавливатьЗависимостиРазработчика(НастройкаУстановки.УстанавливатьЗависимостиРазработчика);
	МенеджерУстановки.СоздаватьФайлыЗапуска(НастройкаУстановки.СоздаватьФайлыЗапуска);

	МенеджерУстановки.РазрешитьЗависимостиПакета(ОписаниеПакета);

	Если РежимУстановки = РежимУстановкиПакетов.Локально Тогда
		ОбеспечитьФайлыИнфраструктурыЛокальнойУстановки(ОписаниеПакета, РежимУстановки);
	КонецЕсли;
	
КонецПроцедуры

Процедура СоздатьКонфигурационныеФайлыОСкрипт(Знач КаталогУстановки, Знач ОписаниеПакета, Знач РежимУстановки) Экспорт
	
	Если РежимУстановки <> РежимУстановкиПакетов.Локально Тогда
		Возврат;
	КонецЕсли;
	
	КаталогиИсполняемыхФайлов = ПроцессорыКоллекций.ИзКоллекции(ОписаниеПакета.ИсполняемыеФайлы())
		.Обработать("Элемент -> Новый Файл(ОбъединитьПути(КаталогУстановки, Элемент.Путь)).Путь", Новый Структура("КаталогУстановки", КаталогУстановки))
		.Различные()
		.ВМассив();

	ШаблонТекстаКонфигурационногоФайла = "lib.additional=%1";

	Для Каждого КаталогИсполняемогоФайла Из КаталогиИсполняемыхФайлов Цикл
		
		РазделительПути = "/";
		РазницаВКаталогах = ФС.ОтносительныйПуть(КаталогУстановки, КаталогИсполняемогоФайла, РазделительПути);
		Директории = СтрРазделить(РазницаВКаталогах, РазделительПути);

		ПутьКЛокальнымБиблиотекам = ПроцессорыКоллекций.ИзКоллекции(Директории)
			.Обработать("Директория -> ""../""")
			.Сократить("Результат, Элемент -> Результат + Элемент", "");

		ПутьКЛокальнымБиблиотекам = ПутьКЛокальнымБиблиотекам + КонстантыOpm.ЛокальныйКаталогУстановкиПакетов;

		ТекстКонфигурационногоФайла = СтрШаблон(ШаблонТекстаКонфигурационногоФайла, ПутьКЛокальнымБиблиотекам);
		ПутьККонфигурационномуФайлу = ОбъединитьПути(КаталогИсполняемогоФайла, "oscript.cfg");

		ТекстовыйДокумент = Новый ТекстовыйДокумент;
		ТекстовыйДокумент.УстановитьТекст(ТекстКонфигурационногоФайла);
		ТекстовыйДокумент.Записать(ПутьККонфигурационномуФайлу, КодировкаТекста.UTF8NoBOM);

	КонецЦикла;
	
КонецПроцедуры

Процедура ОбеспечитьФайлыИнфраструктурыЛокальнойУстановки(Знач ОписаниеПакета, Знач РежимУстановки)

	КаталогНазначения = КонстантыOpm.ЛокальныйКаталогУстановкиПакетов;
	КаталогЗагрузчика = ПолучитьКаталогСистемныхБиблиотек();

	ФС.ОбеспечитьКаталог(КаталогНазначения);
	СоздатьКонфигурационныеФайлыОСкрипт(ТекущийКаталог(), ОписаниеПакета, РежимУстановки);

	ИмяЗагрузчика = "package-loader.os";
	ФайлЗагрузчика = ОбъединитьПути(КаталогЗагрузчика, ИмяЗагрузчика);
	Если Не ФС.ФайлСуществует(ФайлЗагрузчика) Тогда
		Лог.Предупреждение("Не удалось скопировать системный загрузчик в локальный каталог пакетов");
		Возврат;
	КонецЕсли;
	
	ПутьКНовомуЗагрузчику = ОбъединитьПути(КаталогНазначения, ИмяЗагрузчика);
	Если ФС.ФайлСуществует(ПутьКНовомуЗагрузчику) Тогда
		Лог.Отладка("Файл загрузчика уже существует.");
		Возврат;
	КонецЕсли;

	КопироватьФайл(ФайлЗагрузчика, ОбъединитьПути(КаталогНазначения, ИмяЗагрузчика));

КонецПроцедуры

Функция ПолучитьПакет(Знач ИмяПакета, Знач ВерсияПакета, ПутьКФайлуПакета = "", ИмяСервера = "") Экспорт
	
	МенеджерПолучения = ПолучитьМенеджерПолученияПакетов();
	ПутьКФайлуПакета = МенеджерПолучения.ПолучитьПакет(ИмяПакета, ВерсияПакета, ПутьКФайлуПакета, ИмяСервера);

	Возврат ПутьКФайлуПакета;

КонецФункции

Функция ПолучитьКаталогСистемныхБиблиотек()
	
	СистемныеБиблиотеки = ОбъединитьПути(КаталогПрограммы(), ПолучитьЗначениеСистемнойНастройки("lib.system"));
	Лог.Отладка("СистемныеБиблиотеки " + СистемныеБиблиотеки);
	Если СистемныеБиблиотеки = Неопределено Тогда
		ВызватьИсключение "Не определен каталог системных библиотек";
	КонецЕсли;
	
	Возврат СистемныеБиблиотеки;
	
КонецФункции

Лог = Логирование.ПолучитьЛог("oscript.app.opm");
