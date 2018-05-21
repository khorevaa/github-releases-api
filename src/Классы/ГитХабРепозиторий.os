#Использовать logos

Перем Владелец; // Строка
Перем Репозиторий; // Строка

Перем Лог; // Объект

Перем АдресРепозитория Экспорт; // Строка
Перем АдресВыпусков Экспорт; // Строка
Перем КлиентАПИ Экспорт;

#Область Публичное_API

Функция СоздатьВыпуск(Знач Метка, 
						Знач Наименование = "",
						Знач Описание = "", 
						Знач ВеткаИлиКоммит = "master", 
						Знач Черновик = Ложь, 
						Знач ПредварительныйВыпуск = Ложь) Экспорт

	СтруктураЗапроса = Новый Структура();
	СтруктураЗапроса.Вставить("tag_name", Метка);
	СтруктураЗапроса.Вставить("body", Описание);
	
	Если ЗначениеЗаполнено(ВеткаИлиКоммит) Тогда
		СтруктураЗапроса.Вставить("target_commitish", ВеткаИлиКоммит);
	Иначе
		СтруктураЗапроса.Вставить("target_commitish", "master");
	КонецЕсли;
	СтруктураЗапроса.Вставить("name", Наименование);
	СтруктураЗапроса.Вставить("draft", Черновик);
	СтруктураЗапроса.Вставить("prerelease", ПредварительныйВыпуск);

	ПроверитьКлиентаАПИ();

	HTTPЗапрос = КлиентАПИ.ПолучитьHTTPЗапрос(АдресВыпусков, СтруктураЗапроса);

	КлиентАПИ.УстановитьДопустимыйКодСостояния(201);
	ОписаниеГитХабВыпуска = КлиентАПИ.Отправить(HTTPЗапрос);
	КлиентАПИ.УстановитьДопустимыйКодСостояния(200);

	СозданныйВыпуск = Новый ГитХабВыпуск(ЭтотОбъект);
	
	СозданныйВыпуск.ЗаполнитьПоОписанию(ОписаниеГитХабВыпуска);

	Возврат СозданныйВыпуск;

КонецФункции

Функция ПолучитьСписокВыпусков() Экспорт

	НаборВыпусков = Новый Соответствие;

	ПроверитьКлиентаАПИ();

	HTTPЗапрос = КлиентАПИ.ПолучитьHTTPЗапрос(АдресВыпусков);
	МассивОписанийВыпусков = КлиентАПИ.Получить(HTTPЗапрос);

	Для каждого ЭлементМассива Из МассивОписанийВыпусков Цикл
	
		СозданныйВыпуск = Новый ГитХабВыпуск(ЭтотОбъект);
		СозданныйВыпуск.ЗаполнитьПоОписанию(ЭлементМассива);
		
		НаборВыпусков.Вставить(СозданныйВыпуск.Метка, СозданныйВыпуск);

	КонецЦикла;

	Возврат НаборВыпусков;

КонецФункции

Функция ПолучитьВыпускПоМетке(Знач Метка) Экспорт
	
	ПроверитьКлиентаАПИ();

	АдресЗапроса = СтрШаблон("%1/tags/%2", АдресВыпусков, Метка);

	HTTPЗапрос = КлиентАПИ.ПолучитьHTTPЗапрос(АдресЗапроса);
	ОписаниеГитХабВыпуска = КлиентАПИ.Получить(HTTPЗапрос);

	СозданныйВыпуск = Новый ГитХабВыпуск(ЭтотОбъект);

	Если ОписаниеГитХабВыпуска = Неопределено Тогда
		Возврат СозданныйВыпуск;
	КонецЕсли;

	СозданныйВыпуск.ЗаполнитьПоОписанию(ОписаниеГитХабВыпуска);

	Возврат СозданныйВыпуск;

КонецФункции

Функция ПолучитьПоследнийВыпуск() Экспорт
	
	ПроверитьКлиентаАПИ();

	АдресЗапроса = СтрШаблон("%1/latest", АдресВыпусков);

	HTTPЗапрос = КлиентАПИ.ПолучитьHTTPЗапрос(АдресЗапроса);
	ОписаниеГитХабВыпуска = КлиентАПИ.Получить(HTTPЗапрос);

	СозданныйВыпуск = Новый ГитХабВыпуск(ЭтотОбъект);

	Если ОписаниеГитХабВыпуска = Неопределено Тогда
		Возврат СозданныйВыпуск;
	КонецЕсли;

	СозданныйВыпуск.ЗаполнитьПоОписанию(ОписаниеГитХабВыпуска);

	Возврат СозданныйВыпуск;
	
КонецФункции

Процедура УстановитьКлиентАПИ(НовыйКлиентАПИ) Экспорт

	КлиентАПИ = НовыйКлиентАПИ;

КонецПроцедуры

Функция ПолучитьКлиентаАПИ() Экспорт
	Возврат КлиентАПИ;
КонецФункции

#КонецОбласти

#Область Вспомогательные_процедуры_и_функции

Процедура ПроверитьКлиентаАПИ()
	
	Если Не ЗначениеЗаполнено(КлиентАПИ) Тогда
		ВызватьИсключение "Не установлен клиент Github API";
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриСозданииОбъекта(Знач ВходящийВладелец, Знач ВходящийРепозиторий,
							Знач ЗначениеКлиентАПИ = Неопределено)
	
	Владелец = ВходящийВладелец;
	Репозиторий = ВходящийРепозиторий;
	КлиентАПИ  = ЗначениеКлиентАПИ;
	
	Если КлиентАПИ = Неопределено Тогда
		КлиентАПИ = Новый ГитХабКлиентАПИ;
	КонецЕсли;
	
	Лог = Логирование.ПолучитьЛог("oscript.lib.github-repo");
	// urlGraphql = "https://api.github.com/graphql";

	АдресРепозитория = СтрШаблон("repos/%1/%2", Владелец, Репозиторий);
	АдресВыпусков = СтрШаблон("%1/%2", АдресРепозитория, "releases");

КонецПроцедуры

#КонецОбласти