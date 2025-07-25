#Использовать strings

// Подставляет переменные среды в строку
//
// Параметры:
// 	Значение - Строка - Исходная строка. Подстроки вида ${ИМЯ_ПЕРЕМЕННОЙ} заменяются на значение переменной
//
// Возвращаемое значение:
// 	Строка - Строка с подставленными значениями переменных
Функция ПрименитьПеременныеСреды(Знач Значение) Экспорт
	ПеременныеСреды = КакМассив(ПеременныеСреды());
	Возврат ПрименитьПеременныеСредыШаг(Значение, ПеременныеСреды, 0);
КонецФункции

Процедура СообщениеПользователю(Знач Лог, Знач СтрокаСообщения, Знач ПараметрШаблона1 = Неопределено) Экспорт
	Сообщить(СтрШаблон(СтрокаСообщения, ПараметрШаблона1));
	Лог.Отладка(СтрокаСообщения, ПараметрШаблона1);
КонецПроцедуры


Функция ПрименитьПеременныеСредыШаг(Знач Значение, Знач ПеременныеСреды, Знач Индекс)

	ПеременнаяИмя = СтрШаблон("${%1}", ПеременныеСреды[Индекс].Ключ);
	Части = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(Значение, ПеременнаяИмя);
	Если Индекс < ПеременныеСреды.Количество() - 1 Тогда
		Для Инд = 0 По Части.ВГраница() Цикл
			Части[Инд] = ПрименитьПеременныеСредыШаг(Части[Инд], ПеременныеСреды, Индекс + 1);
		КонецЦикла;
	КонецЕсли;

	Результат = СтрСоединить(Части, ПеременныеСреды[Индекс].Значение);
	Возврат Результат;

КонецФункции

Функция КакМассив(Знач Соответствие)
	
	Массив = Новый Массив;
	Для Каждого мКлючИЗанчение Из Соответствие Цикл
		Массив.Добавить(мКлючИЗанчение);
	КонецЦикла;

	Возврат Массив;

КонецФункции