#Использовать logos
#Использовать "../../core"

Перем Лог;

// Основной метод класса
// Параметры:
//   ИмяЗадачи - Строка - Имя задачи для выполнения
//   ПараметрыЗадачи - Массив - параметров передаваемый в скрипт задачи
//
Процедура ВыполнитьЗадачу(Знач ИмяЗадачи, Знач ПараметрыЗадачи) Экспорт
	
	Если НЕ ЗначениеЗаполнено(ИмяЗадачи) Тогда
		ТекстСообщения = СтрШаблон("Укажите задачу для выполнения");
		Лог.Ошибка(ТекстСообщения);
		Возврат;
	КонецЕсли;

	Если ПараметрыЗадачи = Неопределено Тогда
		ПараметрыЗадачи = Новый Массив;
	КонецЕсли;

	ПутьККаталогуЗадач = "";
	
	Попытка
		ОписаниеПакета = РаботаСОписаниемПакета.ПрочитатьОписаниеПакета();
		Свойства = ОписаниеПакета.Свойства();
		Если Свойства.Свойство("Задачи") Тогда
			ПутьККаталогуЗадач = Свойства.Задачи;
		КонецЕсли;
	Исключение
		Лог.Отладка("Ошибка чтения описания пакета:
					|"+ ОписаниеОшибки());
	КонецПопытки;

	Если НЕ ЗначениеЗаполнено(ПутьККаталогуЗадач) Тогда
		ПутьККаталогуЗадач = ОбъединитьПути(ТекущийКаталог(), "tasks");
	КонецЕсли;

	// КаталогЗадач = Новый Файл(ПутьККаталогуЗадач);
	// Если НЕ КаталогЗадач.Существует() Тогда
	// 	ТекстСообщения = СтрШаблон("Не найден каталог задач: %1", КаталогЗадач.ПолноеИмя);
	// 	Лог.Ошибка(ТекстСообщения);
	// 	Возврат;
	// КонецЕсли;

	ПутьКЗадаче = ОбъединитьПути(ПутьККаталогуЗадач, Строка(ИмяЗадачи) + ".os");
	
	ФайлЗадачи = Новый Файл(ПутьКЗадаче);

	Если НЕ ФайлЗадачи.Существует() Тогда
		ФайлЗадачиВБиблиотеке = НайтиЗадачуВБиблиотеке(ИмяЗадачи);
		Если ФайлЗадачиВБиблиотеке.Существует() Тогда
			ФайлЗадачи = ФайлЗадачиВБиблиотеке;
		КонецЕсли;
	КонецЕсли;	

	Если НЕ ФайлЗадачи.Существует() Тогда
		ТекстСообщения = СтрШаблон("Файл задачи не существует: %1", ФайлЗадачи.ПолноеИмя);
		Лог.Ошибка(ТекстСообщения);
		Возврат;
	КонецЕсли;

	ПараметрыСценария = Новый Структура("АргументыКоманднойСтроки", ПараметрыЗадачи);
	ЗагрузитьСценарий(ФайлЗадачи.ПолноеИмя, ПараметрыСценария);

КонецПроцедуры

Функция НайтиЗадачуВБиблиотеке(ИмяЗадачи)

	ИмяБиблиотеки = "opm-tasks";

	ПутьККаталогуЗадачНачало = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "..", "..");
	ПутьККаталогуЗадач = ОбъединитьПути(ПутьККаталогуЗадачНачало, "..", ИмяБиблиотеки, "src");
	ПутьКЗадаче = ОбъединитьПути(ПутьККаталогуЗадач, ИмяЗадачи + ".os");
	ФайлЗадачи = Новый Файл(ПутьКЗадаче);

	Возврат ФайлЗадачи;

КонецФункции

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог("oscript.app.opm");

КонецПроцедуры

Инициализация();
