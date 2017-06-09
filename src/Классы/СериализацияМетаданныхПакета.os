﻿
Перем ИменаКоллекцийПакета;
Перем Лог;

/////////////////////////////////////////////////////////////////////////////
// Чтение

Процедура ЗаписатьXML(Знач ЗаписьXML, Знач ОписаниеПакета) Экспорт
	
	ЗаписатьXMLВнутр(ЗаписьXML, ОписаниеПакета, Истина);
	
КонецПроцедуры

Процедура ЗаписатьМетаданныеВXML(Знач ЗаписьXML, Знач ОписаниеПакета) Экспорт
	
	ЗаписатьXMLВнутр(ЗаписьXML, ОписаниеПакета, Ложь);
	
КонецПроцедуры

Процедура ЗаписатьXMLВнутр(Знач ЗаписьXML, Знач ОписаниеПакета, Знач Полностью)

	ЗаписьXML.ЗаписатьОбъявлениеXML();
	ЗаписьXML.ЗаписатьНачалоЭлемента("opm-metadata");
	ЗаписьXML.ЗаписатьСоответствиеПространстваИмен("", "http://oscript.io/schemas/opm-metadata/1.0");
	
	ЗаписатьСвойстваПакета(ЗаписьXML, ОписаниеПакета);
	ЗаписатьЗависимостиПакета(ЗаписьXML, ОписаниеПакета);
	ЗаписатьИсполняемыеФайлыПакета(ЗаписьXML, ОписаниеПакета);
	Если Полностью Тогда
		ЗаписатьСодержимоеПакета(ЗаписьXML, ОписаниеПакета);
		ЗаписатьЯвноеОбъявлениеМодулейПакета(ЗаписьXML, ОписаниеПакета);
	КонецЕсли;
	
	ЗаписьXML.ЗаписатьКонецЭлемента();

КонецПроцедуры

Функция СоответствиеИменСвойствДляЗаписи()
	
	СоответствиеИменСвойств = Новый Соответствие;
	СоответствиеИменСвойств.Вставить("Имя"   , "name");
	СоответствиеИменСвойств.Вставить("Версия", "version");
	СоответствиеИменСвойств.Вставить("Автор" , "author");
	СоответствиеИменСвойств.Вставить("Описание"   , "description");
	СоответствиеИменСвойств.Вставить("АдресАвтора", "author-email");
	СоответствиеИменСвойств.Вставить("ВерсияСреды", "engine-version");
	СоответствиеИменСвойств.Вставить("АдресОсновногоХранилища", "git-url");
	СоответствиеИменСвойств.Вставить("ИдентификаторВерсии", "git-commit");
	
	Возврат СоответствиеИменСвойств;
	
КонецФункции

Процедура ЗаписатьСвойстваПакета(Знач Запись, Знач Манифест)
	
	СоответствиеИменСвойств = СоответствиеИменСвойствДляЗаписи();
	
	СвойстваПакета = Манифест.Свойства();
	
	Для Каждого КлючИЗначение Из СвойстваПакета Цикл
		
		Если Не ЗначениеЗаполнено(КлючИЗначение.Значение) Тогда
			Продолжить;
		КонецЕсли;
		
		СинонимСвойства = СоответствиеИменСвойств[КлючИЗначение.Ключ];
		Если СинонимСвойства = Неопределено Тогда
			ИмяЭлемента = КлючИЗначение.Ключ;
		Иначе
			ИмяЭлемента = СинонимСвойства;
		КонецЕсли;
		
		Запись.ЗаписатьНачалоЭлемента(ИмяЭлемента);
		Запись.ЗаписатьТекст(XMLСтрока(КлючИЗначение.Значение));
		Запись.ЗаписатьКонецЭлемента();
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаписатьЗависимостиПакета(Знач Запись, Знач Манифест)
	
	Зависимости = Манифест.Зависимости();
	Если Зависимости.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Зависимость Из Зависимости Цикл
		Запись.ЗаписатьНачалоЭлемента(ИменаКоллекцийПакета().Зависимости);
		Запись.ЗаписатьАтрибут("name", Зависимость.ИмяПакета);
		Если Не ПустаяСтрока(Зависимость.МинимальнаяВерсия) Тогда
			Запись.ЗаписатьАтрибут("version", Зависимость.МинимальнаяВерсия);
		КонецЕсли;
		Если Не ПустаяСтрока(Зависимость.МаксимальнаяВерсия) Тогда
			Запись.ЗаписатьАтрибут("version-max", Зависимость.МаксимальнаяВерсия);
		КонецЕсли;
		Запись.ЗаписатьКонецЭлемента();
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗаписатьИсполняемыеФайлыПакета(Знач Запись, Знач Манифест)
	
	ИсполняемыеФайлы = Манифест.ИсполняемыеФайлы();
	Если ИсполняемыеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Файл Из ИсполняемыеФайлы Цикл
		Запись.ЗаписатьНачалоЭлемента(ИменаКоллекцийПакета().ИсполняемыеФайлы);
		Если Не ПустаяСтрока(Файл.ИмяПриложения) Тогда
			Запись.ЗаписатьАтрибут("name", Файл.ИмяПриложения);
		КонецЕсли;
		Запись.ЗаписатьТекст(Файл.Путь);
		Запись.ЗаписатьКонецЭлемента();
	КонецЦикла
	
КонецПроцедуры

Процедура ЗаписатьЯвноеОбъявлениеМодулейПакета(Знач Запись, Знач Манифест)
	
	Модули = Манифест.ВсеМодулиПакета();
	Запись.ЗаписатьНачалоЭлемента(ИменаКоллекцийПакета().ОбъявлениеМодулей);
	
	Для Каждого ОписаниеМодуля Из Модули Цикл
		Если ОписаниеМодуля.Тип = Манифест.ТипыМодулей.Класс Тогда
			Запись.ЗаписатьНачалоЭлемента("class");
		Иначе
			Запись.ЗаписатьНачалоЭлемента("module");
		КонецЕсли;
		
		Запись.ЗаписатьАтрибут("name", ОписаниеМодуля.Идентификатор);
		Запись.ЗаписатьАтрибут("src" , ОписаниеМодуля.Файл);
		Запись.ЗаписатьКонецЭлемента();
		
	КонецЦикла;
	
	Запись.ЗаписатьКонецЭлемента();
	
КонецПроцедуры

Процедура ЗаписатьСодержимоеПакета(Знач ЗаписьXML, Знач Манифест)

	Файлы = Манифест.ВключаемыеФайлы();
	Если Файлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого Файл Из Файлы Цикл
		ЗаписьXML.ЗаписатьНачалоЭлемента(ИменаКоллекцийПакета().ВключаемыеФайлы);
		ЗаписьXML.ЗаписатьТекст(Файл);
		ЗаписьXML.ЗаписатьКонецЭлемента();
	КонецЦикла;

КонецПроцедуры

/////////////////////////////////////////////////////////////////////////////
// Запись

Функция ПрочитатьXML(Знач ЧтениеXML) Экспорт

	ЧтениеXML.ПерейтиКСодержимому();
	Описание = Новый ОписаниеПакета();
	
	Лог.Отладка("Начинаю чтение манифеста из XML. Корневой узел:" + ЧтениеXML.ЛокальноеИмя);
	
	Если ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		ПрочитатьУзлыПакета(ЧтениеXML, Описание);
	КонецЕсли;
	
	Лог.Отладка("Манифест прочитан");
	
	Возврат Описание;
	
КонецФункции

Функция СоответствиеИменСвойствДляЧтения()
	
	ИсходныеСвойства = СоответствиеИменСвойствДляЗаписи();
	ИнвертированныеСвойства = Новый Соответствие;
	Для Каждого КЗ Из ИсходныеСвойства Цикл
		ИнвертированныеСвойства.Вставить(КЗ.Значение, КЗ.Ключ);
	КонецЦикла;
	
	Возврат ИнвертированныеСвойства;
	
КонецФункции

Процедура ПрочитатьУзлыПакета(Знач ЧтениеXML, Знач ОписаниеПакета)

	Перем АдресОсновногоХранилища;

	СоответствиеИменСвойств = СоответствиеИменСвойствДляЧтения();
	
	Рефлектор = Новый Рефлектор;
	
	Пока ЧтениеXML.Прочитать() и ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Цикл
		
		ИмяУзла = ЧтениеXML.ЛокальноеИмя;
		Лог.Отладка("Выбран узел " + ИмяУзла);
		Если ИмяУзла = ИменаКоллекцийПакета().Зависимости Тогда
			ПрочитатьЗависимости(ЧтениеXML, ОписаниеПакета);
		ИначеЕсли ИмяУзла = ИменаКоллекцийПакета().ИсполняемыеФайлы Тогда
			ПрочитатьИсполняемыеФайлы(ЧтениеXML, ОписаниеПакета);
		ИначеЕсли ИмяУзла = ИменаКоллекцийПакета().ОбъявлениеМодулей Тогда
			ПрочитатьЯвноеОбъявлениеМодулей(ЧтениеXML, ОписаниеПакета);
		ИначеЕсли ИмяУзла = ИменаКоллекцийПакета().ВключаемыеФайлы Тогда
			ПрочитатьВключаемыеФайлы(ЧтениеXML, ОписаниеПакета);

		ИначеЕсли ИмяУзла = "git-url" Тогда

			АдресОсновногоХранилища = ПрочитатьТекст(ЧтениеXML);

		ИначеЕсли ИмяУзла = "git-commit" Тогда

			ИдентификаторВерсии = ПрочитатьТекст(ЧтениеXML);
			ОписаниеПакета.ОтметкаГит(АдресОсновногоХранилища, ИдентификаторВерсии);

		Иначе

			ИмяСвойства = СоответствиеИменСвойств[ИмяУзла];
			Если ИмяСвойства <> Неопределено Тогда
				Лог.Отладка("Читаю свойство " + ИмяСвойства);
				ЗначениеСвойства = ПрочитатьТекст(ЧтениеXML);
				Лог.Отладка("Прочитано значение " + ЗначениеСвойства);
				Аргументы = Новый Массив;
				Аргументы.Добавить(ЗначениеСвойства);
				Рефлектор.ВызватьМетод(ОписаниеПакета, ИмяСвойства, Аргументы);
			
			Иначе

				ЧтениеXML.Пропустить();

			КонецЕсли;

		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ПрочитатьЗависимости(Знач ЧтениеXML, Знач ОписаниеПакета)
	
	Лог.Отладка("Читаю зависимость");
	ИмяЗависимости = ЧтениеXML.ПолучитьАтрибут("name");
	Если ИмяЗависимости = Неопределено Тогда
		ВызватьИсключение "Некорректно заданы зависимости в XML описании пакета";
	КонецЕсли;
	
	МинимальнаяВерсия = ЧтениеXML.ПолучитьАтрибут("version");
	МаксимальнаяВерсия = ЧтениеXML.ПолучитьАтрибут("version-max");
	
	Лог.Отладка("Добавляем зависимость " + ИмяЗависимости + " " + МинимальнаяВерсия + " " + МаксимальнаяВерсия);
	ОписаниеПакета.ЗависитОт(ИмяЗависимости, МинимальнаяВерсия, МаксимальнаяВерсия);
	
	ЧтениеXML.Прочитать();
	
КонецПроцедуры

Процедура ПрочитатьИсполняемыеФайлы(Знач ЧтениеXML, Знач ОписаниеПакета)
	
	Лог.Отладка("Читаю исполняемый модуль");
	
	ИмяПриложения = ЧтениеXML.ПолучитьАтрибут("name");
	Путь = ПрочитатьТекст(ЧтениеXML);
	Лог.Отладка("Прочитан путь " + Путь);
	Если Путь <> Неопределено Тогда
		ОписаниеПакета.ИсполняемыйФайл(Путь, ИмяПриложения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПрочитатьВключаемыеФайлы(Знач ЧтениеXML, Знач ОписаниеПакета)
	
	Лог.Отладка("Читаю элемент содержимого");
	
	Путь = ПрочитатьТекст(ЧтениеXML);
	Лог.Отладка("Прочитан путь " + Путь);
	Если Путь <> Неопределено Тогда
		ОписаниеПакета.ВключитьФайл(Путь);
	КонецЕсли;
	
КонецПроцедуры

Процедура ПрочитатьЯвноеОбъявлениеМодулей(Знач ЧтениеXML, Знач ОписаниеПакета)
	
	Лог.Отладка("Читаю явные объявления модулей");
	
	Пока ЧтениеXML.Прочитать() и ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Цикл
		
		Идентификатор = ЧтениеXML.ПолучитьАтрибут("name");
		Источник      = ЧтениеXML.ПолучитьАтрибут("src");

		Если ЧтениеXML.ЛокальноеИмя = "module" Тогда
			Лог.Отладка("Прочитан модуль: " + Идентификатор + ", источник " + Источник);
			ОписаниеПакета.ОпределяетМодуль(Идентификатор, Источник);
		ИначеЕсли ЧтениеXML.ЛокальноеИмя = "class" Тогда
			Лог.Отладка("Прочитан класс: " + Идентификатор + ", источник " + Источник);
			ОписаниеПакета.ОпределяетКласс(Идентификатор, Источник);
		Иначе
			Лог.Отладка("Неизвестный тип узла модуля: " + ЧтениеXML.ЛокальноеИмя);
		КонецЕсли;
		
		ЧтениеXML.Прочитать(); // конец тек. узла
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПрочитатьТекст(Знач Чтение)
	
	Результат = Неопределено;
	
	Пока Чтение.Прочитать() и Чтение.ТипУзла = ТипУзлаXML.Текст Цикл
		Результат = Чтение.Значение;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

/////////////////////////////////////////////////////////////
// Общие функции

Функция ИменаКоллекцийПакета()
	
	Если ИменаКоллекцийПакета = Неопределено Тогда
		ИменаКоллекцийПакета = Новый Структура;
		ИменаКоллекцийПакета.Вставить("Зависимости", "depends-on");
		ИменаКоллекцийПакета.Вставить("ИсполняемыеФайлы", "executable");
		ИменаКоллекцийПакета.Вставить("ВключаемыеФайлы", "include-content");
		ИменаКоллекцийПакета.Вставить("ОбъявлениеМодулей", "explicit-modules");
	КонецЕсли;
	
	Возврат ИменаКоллекцийПакета;
	
КонецФункции

////////////////////////////////////////////////////////////////////////

Лог = Логирование.ПолучитьЛог("oscript.app.opm");
