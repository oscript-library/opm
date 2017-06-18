
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Инициализировать гит");
	Парсер.ДобавитьПозиционныйПараметрКоманды(ОписаниеКоманды, "ИмяНовойВетки", "Имя новой ветки в которую будут производиться изменения.");
	Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

// Выполняет логику команды
// 
// Параметры:
//   ПараметрыКоманды - Соответствие ключей командной строки и их значений
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт

	// Читаем метаданные
	Установщик = Новый УстановкаПакета;

	КаталогПоискаМетаданных = ТекущийКаталог();
	ИмяФайлаМетаданных = ОбъединитьПути(КаталогПоискаМетаданных, "opm-metadata.xml");
	Метаданные = Установщик.ПрочитатьМетаданныеПакета(ИмяФайлаМетаданных);

	мСвойства = Метаданные.Свойства();
	Если Не мСвойства.Свойство("АдресОсновногоХранилища")
		Или Не ЗначениеЗаполнено(мСвойства.АдресОсновногоХранилища) Тогда
		ВызватьИсключение "Нет данных поставщика";
	КонецЕсли;

	Если Не мСвойства.Свойство("ИдентификаторВерсии")
		Или Не ЗначениеЗаполнено(мСвойства.ИдентификаторВерсии) Тогда
		ВызватьИсключение "Нет данных поставщика";
	КонецЕсли;

	ИмяНовойВетки = ПараметрыКоманды["ИмяНовойВетки"];
	Если Не ЗначениеЗаполнено(ИмяНовойВетки) Тогда
		ИмяНовойВетки = СтрШаблон("feature/fix-of-%1", Лев(мСвойства.ИдентификаторВерсии, 6));
	КонецЕсли;

	СкриптЗапуска = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "gitinit.os");
	ВнешнийКонтекст = Новый Структура("КаталогРепозитория, Адрес, Коммит, ИмяНовойВетки",
		КаталогПоискаМетаданных,
		мСвойства.АдресОсновногоХранилища,
		мСвойства.ИдентификаторВерсии,
		ИмяНовойВетки);

	ЗагрузитьСценарий(СкриптЗапуска, ВнешнийКонтекст);

	Возврат 0;

КонецФункции
