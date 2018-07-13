﻿#Использовать fluent
#Использовать fs
#Использовать logos
#Использовать tempfiles

Перем Лог;
Перем мВременныйКаталогУстановки;
Перем мЗависимостиВРаботе;
Перем ЭтоWindows;
Перем мРежимУстановкиПакетов;

Перем мЦелевойКаталог;
Перем Метаданные;

Процедура УстановитьПакетИзАрхива(Знач ФайлАрхива) Экспорт
	
	Лог.Отладка("Устанавливаю пакет из архива: " + ФайлАрхива);
	Если мЗависимостиВРаботе = Неопределено Тогда
		мЗависимостиВРаботе = Новый Соответствие;
	КонецЕсли;
	
	мВременныйКаталогУстановки = ВременныеФайлы.СоздатьКаталог();
	Лог.Отладка("Временный каталог установки: " + мВременныйКаталогУстановки);
	
	Попытка
		
		Лог.Отладка("Открываем архив пакета");
		ЧтениеПакета = Новый ЧтениеZipФайла;
		ЧтениеПакета.Открыть(ФайлАрхива);
		
		ФайлСодержимого = ИзвлечьОбязательныйФайл(ЧтениеПакета, КонстантыOpm.ИмяФайлаСодержимогоПакета);
		ФайлМетаданных  = ИзвлечьОбязательныйФайл(ЧтениеПакета, КонстантыOpm.ИмяФайлаМетаданныхПакета);
		
		Метаданные = ПрочитатьМетаданныеПакета(ФайлМетаданных);
		ИмяПакета = Метаданные.Свойства().Имя;
		
		ПутьУстановки = НайтиСоздатьКаталогУстановки(ИмяПакета);
		
		Лог.Информация("Устанавливаю пакет " +  ИмяПакета);
		ПроверитьВерсиюСреды(Метаданные);
		Если мЗависимостиВРаботе[ИмяПакета] = "ВРаботе" Тогда
			ВызватьИсключение "Циклическая зависимость по пакету " + ИмяПакета;
		КонецЕсли;
		
		мЗависимостиВРаботе.Вставить(ИмяПакета, "ВРаботе");
				
		СтандартнаяОбработка = Истина;
		УстановитьФайлыПакета(ПутьУстановки, ФайлСодержимого, СтандартнаяОбработка);
		Если СтандартнаяОбработка Тогда
			СгенерироватьСкриптыЗапускаПриложенийПриНеобходимости(ПутьУстановки.ПолноеИмя, Метаданные);
			РаботаСПакетами.СоздатьКонфигурационныеФайлыОСкрипт(ПутьУстановки.ПолноеИмя, Метаданные, мРежимУстановкиПакетов);
		КонецЕсли;
		СохранитьФайлМетаданныхПакета(ПутьУстановки.ПолноеИмя, ФайлМетаданных);
		
		ЧтениеПакета.Закрыть();
		
		ВременныеФайлы.УдалитьФайл(мВременныйКаталогУстановки);
		
		мЗависимостиВРаботе.Вставить(ИмяПакета, "Установлен");
		
	Исключение
		УдалитьКаталогУстановкиПриОшибке(ПутьУстановки);
		ЧтениеПакета.Закрыть();
		ВременныеФайлы.УдалитьФайл(мВременныйКаталогУстановки);
		ВызватьИсключение;
	КонецПопытки;
	
	Лог.Информация("Установка завершена");
	
КонецПроцедуры

Процедура УстановитьКешПакетов(КэшПакетовВУстановке) Экспорт
	мЗависимостиВРаботе = КэшПакетовВУстановке;
КонецПроцедуры

Функция ПолучитьМанифестПакета() Экспорт
	Возврат Метаданные;
КонецФункции

Процедура УстановитьРежимУстановкиПакета(Знач ЗначениеРежимУстановкиПакетов) Экспорт
	мРежимУстановкиПакетов = ЗначениеРежимУстановкиПакетов;
КонецПроцедуры

Процедура ПроверитьВерсиюСреды(Манифест)
	
	Свойства = Манифест.Свойства();
	Если НЕ Свойства.Свойство("ВерсияСреды") Тогда
		Возврат;
	КонецЕсли;
	
	ИмяПакета = Свойства.Имя;
	ТребуемаяВерсияСреды = Свойства.ВерсияСреды;
	СистемнаяИнформация = Новый СистемнаяИнформация;
	ВерсияСреды = СистемнаяИнформация.Версия;
	Лог.Отладка("ПроверитьВерсиюСреды: Перед вызовом СравнитьВерсии(ЭтаВерсия = <%1>, БольшеЧемВерсия = <%2>)", ТребуемаяВерсияСреды, ВерсияСреды);
	Если РаботаСВерсиями.СравнитьВерсии(ТребуемаяВерсияСреды, ВерсияСреды) > 0 Тогда
			ТекстСообщения = СтрШаблон(
			"Ошибка установки пакета <%1>: Обнаружена устаревшая версия движка OneScript.
			|Требуемая версия: %2
			|Текущая версия: %3
			|Обновите OneScript перед установкой пакета", 
			ИмяПакета,
			ТребуемаяВерсияСреды,
			ВерсияСреды
		);
		
		ВызватьИсключение ТекстСообщения;
	КонецЕсли;

КонецПроцедуры

Процедура УстановитьЦелевойКаталог(Знач ЦелевойКаталогУстановки) Экспорт
	Лог.Отладка("Каталог установки пакета '%1'", ЦелевойКаталогУстановки);
	ФС.ОбеспечитьКаталог(ЦелевойКаталогУстановки);
	мЦелевойКаталог = ЦелевойКаталогУстановки;
КонецПроцедуры

Функция НайтиСоздатьКаталогУстановки(Знач ИдентификаторПакета)
	
	ПутьУстановки = Новый Файл(ОбъединитьПути(мЦелевойКаталог, ИдентификаторПакета));
	Лог.Отладка("Путь установки пакета: " + ПутьУстановки.ПолноеИмя);
	
	Если Не ПутьУстановки.Существует() Тогда
		СоздатьКаталог(ПутьУстановки.ПолноеИмя);
	ИначеЕсли ПутьУстановки.ЭтоФайл() Тогда
		ВызватьИсключение "Не удалось создать каталог " + ПутьУстановки.ПолноеИмя;
	КонецЕсли;
	
	Возврат ПутьУстановки;
	
КонецФункции

Процедура УстановитьФайлыПакета(Знач ПутьУстановки, Знач ФайлСодержимого, СтандартнаяОбработка)
	
	ЧтениеСодержимого = Новый ЧтениеZipФайла(ФайлСодержимого);
	Попытка	
		
		Лог.Отладка("Устанавливаю файлы пакета из архива");
		УдалитьУстаревшиеФайлы(ПутьУстановки);
		ЧтениеСодержимого.ИзвлечьВсе(ПутьУстановки.ПолноеИмя);
		
		ОбработчикСобытий = ПолучитьОбработчикСобытий(ПутьУстановки.ПолноеИмя);
		ВызватьСобытиеПриУстановке(ОбработчикСобытий, ПутьУстановки.ПолноеИмя, СтандартнаяОбработка);
	
	Исключение
		ЧтениеСодержимого.Закрыть();
		ВызватьИсключение;
	КонецПопытки;
	
	ЧтениеСодержимого.Закрыть();
	
КонецПроцедуры

Процедура УдалитьУстаревшиеФайлы(Знач ПутьУстановки)
	УдалитьФайлыВКаталоге(ПутьУстановки.ПолноеИмя, "*.os", Истина);
	УдалитьФайлыВКаталоге(ПутьУстановки.ПолноеИмя, "*.dll", Истина);
	УдалитьФайлыВКаталоге(ПутьУстановки.ПолноеИмя, "packagedef", Ложь);
КонецПроцедуры

Процедура УдалитьФайлыВКаталоге(Знач ПутьКаталога, Знач МаскаФайлов, Знач ИскатьВПодкаталогах = Истина)
	ФайлыДляУдаления = НайтиФайлы(ПутьКаталога, МаскаФайлов, ИскатьВПодкаталогах);
	Для Каждого Файл из ФайлыДляУдаления Цикл
		УдалитьФайлы(Файл.ПолноеИмя);
	КонецЦикла;
КонецПроцедуры

Функция ПолучитьОбработчикСобытий(Знач ПутьУстановки)
	ОбработчикСобытий = Неопределено;
	ИмяФайлаСпецификацииПакета = КонстантыOpm.ИмяФайлаСпецификацииПакета;
	ПутьКФайлуСпецификации = ОбъединитьПути(ПутьУстановки, ИмяФайлаСпецификацииПакета);
	Если ФС.ФайлСуществует(ПутьКФайлуСпецификации) Тогда
		Лог.Отладка("Найден файл спецификации пакета");
		Лог.Отладка("Компиляция файла спецификации пакета");
		
		ОписаниеПакета = Новый ОписаниеПакета();
		ВнешнийКонтекст = Новый Структура("Описание", ОписаниеПакета);
		ОбработчикСобытий = ЗагрузитьСценарий(ПутьКФайлуСпецификации, ВнешнийКонтекст);
	КонецЕсли;

	Возврат ОбработчикСобытий;
КонецФункции

Процедура ВызватьСобытиеПриУстановке(Знач ОбработчикСобытий, Знач Каталог, СтандартнаяОбработка)

	Если ОбработчикСобытий = Неопределено Тогда
		Возврат;
	КонецЕсли;

	Рефлектор = Новый Рефлектор;
	Если Рефлектор.МетодСуществует(ОбработчикСобытий, "ПриУстановке") Тогда
		Лог.Отладка("Вызываю событие ПриУстановке");
		ОбработчикСобытий.ПриУстановке(Каталог, СтандартнаяОбработка);
	КонецЕсли;

КонецПроцедуры

Процедура СгенерироватьСкриптыЗапускаПриложенийПриНеобходимости(Знач КаталогУстановки, Знач ОписаниеПакета)
	
	ИмяПакета = ОписаниеПакета.Свойства().Имя;
	
	Для Каждого ФайлПриложения Из ОписаниеПакета.ИсполняемыеФайлы() Цикл
		
		ИмяСкриптаЗапуска = ?(ПустаяСтрока(ФайлПриложения.ИмяПриложения), ИмяПакета, ФайлПриложения.ИмяПриложения);
		Лог.Информация("Регистрация приложения: " + ИмяСкриптаЗапуска);
		
		ОбъектФайл = Новый Файл(ОбъединитьПути(КаталогУстановки, ФайлПриложения.Путь));
		
		Если Не ОбъектФайл.Существует() Тогда
			Лог.Ошибка("Файл приложения " + ОбъектФайл.ПолноеИмя + " не существует");
			ВызватьИсключение "Некорректные данные в метаданных пакета";
		КонецЕсли;
		
		Если мРежимУстановкиПакетов = РежимУстановкиПакетов.Локально Тогда
			КаталогУстановкиСкриптовЗапускаПриложений = ОбъединитьПути(КонстантыOpm.ЛокальныйКаталогУстановкиПакетов, "bin");
			ФС.ОбеспечитьКаталог(КаталогУстановкиСкриптовЗапускаПриложений);
			КаталогУстановкиСкриптовЗапускаПриложений = Новый Файл(КаталогУстановкиСкриптовЗапускаПриложений).ПолноеИмя;
		ИначеЕсли мРежимУстановкиПакетов = РежимУстановкиПакетов.Глобально Тогда
			КаталогУстановкиСкриптовЗапускаПриложений = ?(ЭтоWindows, КаталогПрограммы(), "/usr/bin");
			Если НЕ ПустаяСтрока(ПолучитьПеременнуюСреды("OSCRIPTBIN")) Тогда
				КаталогУстановкиСкриптовЗапускаПриложений = ПолучитьПеременнуюСреды("OSCRIPTBIN");
			КонецЕсли;
		Иначе
			ВызватьИсключение "Неизвестный режим установки пакетов <" + мРежимУстановкиПакетов + ">";
		КонецЕсли;
		
		СоздатьСкриптЗапуска(ИмяСкриптаЗапуска, ОбъектФайл.ПолноеИмя, КаталогУстановкиСкриптовЗапускаПриложений);
	
	КонецЦикла;
	
КонецПроцедуры

Процедура СоздатьСкриптЗапуска(Знач ИмяСкриптаЗапуска, Знач ПутьФайлаПриложения, Знач Каталог) Экспорт

	Если ЭтоWindows Тогда
		ФайлЗапуска = Новый ЗаписьТекста(ОбъединитьПути(Каталог, ИмяСкриптаЗапуска + ".bat"), "cp866");
		ФайлЗапуска.ЗаписатьСтроку("@oscript.exe """ + ПутьФайлаПриложения + """ %*");
		ФайлЗапуска.ЗаписатьСтроку("@exit /b %ERRORLEVEL%");
		ФайлЗапуска.Закрыть();
	КонецЕсли;

	Если (ЭтоWindows И НастройкиOpm.ПолучитьНастройки().СоздаватьShСкриптЗапуска) ИЛИ НЕ ЭтоWindows Тогда
		ПолныйПутьКСкриптуЗапуска = ОбъединитьПути(Каталог, ИмяСкриптаЗапуска);
		ФайлЗапуска = Новый ЗаписьТекста(ПолныйПутьКСкриптуЗапуска, КодировкаТекста.UTF8NoBOM,,, Символы.ПС);
		ФайлЗапуска.ЗаписатьСтроку("#!/bin/bash");
		СтрокаЗапуска = "oscript";
		Если ЭтоWindows Тогда
			СтрокаЗапуска = СтрокаЗапуска + " -encoding=utf-8";
		КонецЕсли;
		СтрокаЗапуска = СтрокаЗапуска + " """ + ПутьФайлаПриложения + """ ""$@""";
		ФайлЗапуска.ЗаписатьСтроку(СтрокаЗапуска);
		ФайлЗапуска.Закрыть();

		Если НЕ ЭтоWindows Тогда
			ЗапуститьПриложение("chmod +x """ + ПолныйПутьКСкриптуЗапуска + """");
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Функция ПрочитатьМетаданныеПакета(Знач ФайлМетаданных)
	
	Перем Метаданные;
	Лог.Отладка("Чтение метаданных пакета");
	Попытка
		Чтение = Новый ЧтениеXML;
		Чтение.ОткрытьФайл(ФайлМетаданных);
		Лог.Отладка("XML загружен");
		Сериализатор = Новый СериализацияМетаданныхПакета;
		Метаданные = Сериализатор.ПрочитатьXML(Чтение);
		
		Чтение.Закрыть();
	Исключение
		Чтение.Закрыть();
		ВызватьИсключение;
	КонецПопытки;
	Лог.Отладка("Метаданные прочитаны");
	
	Возврат Метаданные;
	
КонецФункции

Процедура СохранитьФайлМетаданныхПакета(Знач КаталогУстановки, Знач ПутьКФайлуМетаданных)
	
	ПутьСохранения = ОбъединитьПути(КаталогУстановки, КонстантыOpm.ИмяФайлаМетаданныхПакета);
	ДанныеФайла = Новый ДвоичныеДанные(ПутьКФайлуМетаданных);
	ДанныеФайла.Записать(ПутьСохранения);
	
КонецПроцедуры

Процедура УдалитьКаталогУстановкиПриОшибке(Знач Каталог)
	Лог.Отладка("Удаляю каталог " + Каталог);
	Попытка
		УдалитьФайлы(Каталог);
	Исключение
		Лог.Отладка("Не удалось удалить каталог " + Каталог + "
		|	- " + ОписаниеОшибки());
	КонецПопытки
КонецПроцедуры

//////////////////////////////////////////////////////////////////////////////////
//

Функция ИзвлечьОбязательныйФайл(Знач Чтение, Знач ИмяФайла)
	Лог.Отладка("Извлечение: " + ИмяФайла);
	Элемент = Чтение.Элементы.Найти(ИмяФайла);
	Если Элемент = Неопределено Тогда
		ВызватьИсключение "Неверная структура пакета. Не найден файл " + ИмяФайла;
	КонецЕсли;
	
	Чтение.Извлечь(Элемент, мВременныйКаталогУстановки);
	
	Возврат ОбъединитьПути(мВременныйКаталогУстановки, ИмяФайла);
	
КонецФункции

Лог = Логирование.ПолучитьЛог("oscript.app.opm");
СИ = Новый СистемнаяИнформация();
ЭтоWindows = Найти(СИ.ВерсияОС, "Windows") > 0;
мРежимУстановкиПакетов = РежимУстановкиПакетов.Глобально;
