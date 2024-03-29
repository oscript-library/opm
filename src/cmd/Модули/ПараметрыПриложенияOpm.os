
Перем Лог;

Функция ИмяЛогаСистемы() Экспорт
	Возврат "oscript.app.opm";
КонецФункции

Процедура НастроитьOpm() Экспорт

	НастройкиOpmИзФайлов = СобратьНастройкиИзФайлов();

	Если НастройкиOpmИзФайлов.Количество() = 0 Тогда
		Лог.Отладка("Настройки opm не найдены");
		Возврат;
	КонецЕсли;

	НастройкиПроксиЕсть = ПолучитьЗначение(НастройкиOpmИзФайлов,"Прокси", Неопределено);
		
	Если Не НастройкиПроксиЕсть = Неопределено  Тогда

		НастройкиПрокси = НастройкиOpmИзФайлов.Прокси;

		Сервер = ПолучитьЗначение(НастройкиПрокси, "Сервер", "");
		Порт = Число(ПолучитьЗначение(НастройкиПрокси, "Порт", 80));
		Пользователь = ПолучитьЗначение(НастройкиПрокси, "Пользователь", "");
		Пароль = ПолучитьЗначение(НастройкиПрокси, "Пароль", "");

		ПроксиПоУмолчанию = ПолучитьЗначение(НастройкиПрокси,"ПроксиПоУмолчанию", Неопределено);
		ИспользованиеПрокси = ПолучитьЗначение(НастройкиПрокси, "ИспользоватьПрокси", Неопределено);

		Если ИспользованиеПрокси = Истина Тогда
			НастройкиOpm.УстановитьИспользованиеПрокси(ИспользованиеПрокси);

			Если Не ПроксиПоУмолчанию = Неопределено Тогда
				НастройкиOpm.УстановитьСистемныеНастройкиПроксиСервера(ПроксиПоУмолчанию);
			КонецЕсли;

			Если ПроксиПоУмолчанию = Неопределено Или ПроксиПоУмолчанию = Ложь Тогда
				НастройкиOpm.УстановитьНастройкиПроксиСервера(Сервер, Порт, Пользователь, Пароль);
			КонецЕсли;

		КонецЕсли;

	КонецЕсли;

	СоздаватьShСкриптЗапуска = ПолучитьЗначение(НастройкиOpmИзФайлов,"СоздаватьShСкриптЗапуска", Неопределено);
		
	Если Не СоздаватьShСкриптЗапуска = Неопределено Тогда

		НастройкиOpm.УстановитьСозданиеShСкриптЗапуска(СоздаватьShСкриптЗапуска);

	КонецЕсли;

	СервераПакетов = ПолучитьЗначение(НастройкиOpmИзФайлов,"СервераПакетов", Неопределено);
	
	Если Не СервераПакетов = Неопределено Тогда
		Индекс = 1;

		Для каждого ТекущийСерверПакетов Из СервераПакетов Цикл
			
			Сервер = ПолучитьЗначение(ТекущийСерверПакетов, "Сервер", "");
			Порт = Число(ПолучитьЗначение(ТекущийСерверПакетов, "Порт", 80));
			ПутьНаСервере = ПолучитьЗначение(ТекущийСерверПакетов, "ПутьНаСервере", "/");
			Имя = ПолучитьЗначение(ТекущийСерверПакетов, "Имя", СтрШаблон("ДопСервер_%1", Индекс));
			РесурсПубликацииПакетов = ПолучитьЗначение(ТекущийСерверПакетов, "РесурсПубликацииПакетов", "/");
			Приоритет = Число(ПолучитьЗначение(ТекущийСерверПакетов, "Приоритет", 0));
		
			Если ПустаяСтрока(Сервер) Тогда
				Лог.Отладка("Для сервера <%1> не задан адрес", Индекс);
				Продолжить;
			КонецЕсли;
		
			НастройкиOpm.ДобавитьСерверПакетов(Имя, Сервер, ПутьНаСервере, РесурсПубликацииПакетов, Порт, Приоритет);
			Индекс = Индекс +1;

		КонецЦикла;

	КонецЕсли;

КонецПроцедуры

Функция ПолучитьЗначение(ВходящаяСтруктура, Ключ, ЗначениеПоУмолчанию)

	Перем ЗначениеКлюча;

	Если Не ВходящаяСтруктура.Свойство(Ключ, ЗначениеКлюча) Тогда
		
		Возврат ЗначениеПоУмолчанию;
	
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(ЗначениеКлюча) Тогда
		Возврат ЗначениеПоУмолчанию;
	КонецЕсли;

	Возврат ЗначениеКлюча;

КонецФункции

Процедура ЗаполнитьНастройкиИзПараметров(Знач ПараметрКоманды) Экспорт

	Если Не ПараметрКоманды["-winCreateBashLauncher"] = Неопределено Тогда

		ЗначениеОпции = Булево(ПараметрКоманды["-winCreateBashLauncher"]);
		НастройкиOpm.УстановитьСозданиеShСкриптЗапуска(ЗначениеОпции);

	КонецЕсли;

	ТекущиеНастройки = НастройкиOpm.ПолучитьНастройки();
	НастройкиПрокси = ТекущиеНастройки.НастройкиПрокси;
	ПроксиСервер            = ?(ПараметрКоманды["-proxyserver"]      = Неопределено,	НастройкиПрокси.Сервер,       ПараметрКоманды["-proxyserver"]);
	ПроксиПорт              = ?(ПараметрКоманды["-proxyport"]        = Неопределено,	НастройкиПрокси.Порт,         ПараметрКоманды["-proxyport"]);
	ПроксиПользователь      = ?(ПараметрКоманды["-proxyuser"]        = Неопределено,	НастройкиПрокси.Пользователь, ПараметрКоманды["-proxyuser"]);
	ПроксиПароль            = ?(ПараметрКоманды["-proxypass"]        = Неопределено,	НастройкиПрокси.Пароль,       ПараметрКоманды["-proxypass"]);

	НастройкиOpm.УстановитьНастройкиПроксиСервера(ПроксиСервер, ПроксиПорт, ПроксиПользователь, ПроксиПароль);

	Если НЕ ПараметрКоманды["-proxyusedefault"] = Неопределено Тогда
		
		Лог.Отладка("Устанавливаю прокси по умолчанию <%1>", ПараметрКоманды["-proxyusedefault"]);
		НастройкиOpm.УстановитьСистемныеНастройкиПроксиСервера(ПараметрКоманды["-proxyusedefault"]);
		
	Иначе
		
		НастройкиOpm.УстановитьИспользованиеПрокси(ЗначениеЗаполнено(ПроксиСервер));
		
	КонецЕсли;

КонецПроцедуры

Процедура СохранитьТекущиеНастройки() Экспорт

	МассивФайлов = СписокФайловНастроек();

	ТекущиеНастройки = НормализоватьНастройкиДляЗаписи();
	СохранитьНастройки(ТекущиеНастройки, МассивФайлов[0]);

КонецПроцедуры


Функция НормализоватьНастройкиДляЗаписи()

	НастройкиДляЗаписи = Новый Структура;

	ТекущиеНастройки = НастройкиOpm.ПолучитьНастройки();

	НастройкиДляЗаписи.Вставить("СоздаватьShСкриптЗапуска", ТекущиеНастройки.СоздаватьShСкриптЗапуска);
	НастройкиДляЗаписи.Вставить("Прокси", ПолучитьНастройкуПроксиДляЗаписи(ТекущиеНастройки));
	НастройкиДляЗаписи.Вставить("СервераПакетов", ПолучитьСписокСерверовПакетовДляЗаписи(ТекущиеНастройки));

	Возврат НастройкиДляЗаписи;

КонецФункции

Функция ПолучитьНастройкуПроксиДляЗаписи(ТекущиеНастройки)

	СтруктураПрокси = Новый Структура();

	НастройкиПрокси = ТекущиеНастройки.НастройкиПрокси;

	Для каждого КлючЗначение Из НастройкиПрокси Цикл
		СтруктураПрокси.Вставить(КлючЗначение.Ключ, КлючЗначение.Значение);
	КонецЦикла;

	СтруктураПрокси.Вставить("ИспользоватьПрокси", ТекущиеНастройки.ИспользоватьПрокси);
	СтруктураПрокси.Вставить("ПроксиПоУмолчанию", ТекущиеНастройки.ИспользоватьСистемныйПрокси);


	Возврат СтруктураПрокси;

КонецФункции

Функция ПолучитьСписокСерверовПакетовДляЗаписи(ТекущиеНастройки)

	МассивСерверовПакетов = Новый Массив;

	Для каждого НастройкаСервера Из ТекущиеНастройки.СервераПакетов Цикл

		МассивСерверовПакетов.Добавить(НастройкаСервера);

	КонецЦикла;

	Возврат МассивСерверовПакетов;

КонецФункции

Функция СобратьНастройкиИзФайлов() Экспорт
	
	НастройкиФайла = Новый Структура;

	МассивПутейНастроек = СписокФайловНастроек();

	Для каждого Элемент из МассивПутейНастроек Цикл
		
		Лог.Отладка("Чтение файла настроек %1", Элемент);

		Если НЕ Новый Файл(Элемент).Существует() Тогда
			Продолжить;
		КонецЕсли;
		
		Попытка
			НастройкиФайла = ПрочитатьФайлНастроек(Элемент);
			Прервать;
		Исключение
			Лог.Отладка("Чтение файла настроек %1. Ошибка: %2", Элемент, ОписаниеОшибки());

		КонецПопытки;

	КонецЦикла;

	Возврат НастройкиФайла;

КонецФункции

Функция ПрочитатьФайлНастроек(Знач ПутьФайлаНастроек)

	Если НЕ Новый Файл(ПутьФайлаНастроек).Существует() Тогда
		ВызватьИсключение "Файл настроек не найдет";
	КонецЕсли;

	Текст = ПрочитатьФайл(ПутьФайлаНастроек);

	ЧтениеJSON = Новый ЧтениеJSON();
	ЧтениеJSON.УстановитьСтроку(Текст);
	Настройки = ПрочитатьJSON(ЧтениеJSON, Ложь);
	ЧтениеJSON.Закрыть();

	Возврат Настройки;

КонецФункции

Функция ПрочитатьФайл(Знач Путь)

	Чтение = Новый ЧтениеТекста(Путь);
	Текст = Чтение.Прочитать();
	Чтение.Закрыть();

	Возврат Текст;

КонецФункции

Процедура СохранитьФайл(Знач Текст,Знач Путь)

 	Запись = Новый ЗаписьТекста(Путь);
 	Запись.ЗаписатьСтроку(Текст);
 	Запись.Закрыть();

КонецПроцедуры

Процедура СохранитьНастройки(Знач Параметры, Знач ПутьФайлаНастроек) Экспорт

	Текст = СформироватьТекстНастроек(Параметры);
	СохранитьФайл(Текст, ПутьФайлаНастроек);

КонецПроцедуры

Функция СформироватьТекстНастроек(Знач Настройки)

	Json          =  Новый ЗаписьJSON();
	Json.УстановитьСтроку();

	ЗаписатьJSON(Json, Настройки);

	Возврат Json.Закрыть();

КонецФункции

// Возвращает массив путей, где может находиться файла настроек opm
// Текущий каталог запуска, домашний каталог пользователя, системная настройка, каталог opm (для совместимости).
Функция СписокФайловНастроек()

	ИмяФайл = КонстантыOpm.ИмяФайлаНастроек;
	МассивФайлов = Новый Массив;
	//Текущий каталог
	МассивФайлов.Добавить(ОбъединитьПути(ТекущийКаталог(), ИмяФайл));
	//Настройки в профиле пользователя.
	ПутьКНастройкам = "";
	СИ = Новый СистемнаяИнформация();
	Если Найти(Нрег(СИ.ВерсияОС), Нрег("Windows")) > 0 Тогда
			ПутьКНастройкам = ОбъединитьПути(ПолучитьПеременнуюСреды(Врег("USERPROFILE")), ИмяФайл);
			ПутьКНастройкамСистемный = ОбъединитьПути(ПолучитьПеременнуюСреды(Врег("ALLUSERSPROFILE")), ИмяФайл);
	Иначе
			ПутьКНастройкам = ОбъединитьПути(ПолучитьПеременнуюСреды(Врег("HOME")), "."+ИмяФайл);
			ПутьКНастройкамСистемный = ОбъединитьПути("/etc", ИмяФайл);
	КонецЕсли;

	МассивФайлов.Добавить(ПутьКНастройкам);
	МассивФайлов.Добавить(ПутьКНастройкамСистемный);

	//Совместимость со старым поведением
	МассивФайлов.Добавить(ОбъединитьПути(СтартовыйСценарий().Каталог, ИмяФайл));

	Возврат МассивФайлов;

КонецФункции

Процедура Инициализация()
	
	НастроитьOpm();

КонецПроцедуры

Лог = Логирование.ПолучитьЛог("oscript.app.opm");

Инициализация();
