﻿// *****************************************************************
// Модуль формы обработки ЗагрузкаКурсовВалют
// Содержит клиентские процедуры, обеспечивающие получение и сохранение
// курсов валют.
// *****************************************************************

#Область Работа_с_формой

&НаСервере
&После("ЗаполнитьВалюты")
// Дополняет табличную часть списком валют, курс которых загружается с сайта БНБ
//
Процедура БНБ_ЗаполнитьВалюты()	
	СписокВалют = Объект.СписокВалют;	
	ЗагружаемыеВалюты = РаботаСКурсамиВалют.БНБ_ЗагружаемыеВалюты().Результат;
	Для Каждого ЭлементВалюта Из ЗагружаемыеВалюты Цикл
		ДобавитьВалютуВСписок(ЭлементВалюта);
	КонецЦикла;
КонецПроцедуры 


// Восстанавливает состояние списка загружаемых валют
//
Процедура БНБ_ВосстановитьФорму()
	СписокВалют = Объект.СписокВалют; 
	// Запомнить состояние выбора
	ОтмеченныеВалюты = новый массив;
	Для Каждого ВалютаСписка из СписокВалют Цикл
	   Если ВалютаСписка.Загружать Тогда
	       ОтмеченныеВалюты.Добавить(ВалютаСписка.Валюта);	   
	   КонецЕсли;
	КонецЦикла;
	
	// Заполнить список валютами, загружаемыми из интернета
	СписокВалют.Очистить();
	ЗагружаемыеВалюты = РаботаСКурсамиВалют.ЗагружаемыеВалюты();
	
	Для Каждого ЭлементВалюта Из ЗагружаемыеВалюты Цикл
		НоваяСтрока = Объект.СписокВалют.Добавить();	
		ЗаполнитьДанныеСтрокиТаблицыНаОсновеВалюты(НоваяСтрока, ЭлементВалюта);
		// Восстановить состояние загрузки
		Если ОтмеченныеВалюты.Найти(ЭлементВалюта) <> Неопределено Тогда
			НоваяСтрока.Загружать = Истина		
		КонецЕсли;	
	КонецЦикла;
	
КонецПроцедуры	

#КонецОбласти 

#Область ОбработчикКомандФормы

&НаКлиенте
&Перед("НачатьЗагрузкуКурсовВалют")
// Эта процедура вызывается при нажатии кнопки "Загрузить и закрыть" из формы
// Получает управление перед началом загрузки стандартной обработки
// ------------------------------------------------------------------------
// Представление MVC  
// отвечает за отображение данных модели пользователю, реагируя на изменения модели
// ------------------------------------------------------------------------
// Вызывает серверную процедуру получения курсов для котируемых к леву валют
// В начале и конце выполняет запись состояния в журнал
//
Процедура БНБ_НачатьЗагрузкуКурсовВалют()	
	Заголовок = "Получение курсов валют";
	
	УровеньСобытия = "Информация";
	Описание = "Начата загрузка курсов";
	БНБ_ЗаписатьСобытиеВЖурналРегистрации(Заголовок,Описание,УровеньСобытия);	
	
	// Выполнить обновление курсов для всех отмеченных на форме валют, если они котикуются к леву
	Результат = БНБ_ПолучитьКурсы(Объект.СписокВалют, Объект.НачалоПериодаЗагрузки, Объект.ОкончаниеПериодаЗагрузки);
	Если Результат.Статус Тогда	
		Описание = "Загрузка курсов завершена без ошибок";
	Иначе
		Описание = "Загрузка курсов завершена с ошибками";
		УровеньСобытия = "Ошибка";
	КонецЕсли;
	
	БНБ_ВосстановитьФорму();  	
	БНБ_ЗаписатьСобытиеВЖурналРегистрации(Заголовок,Описание,УровеньСобытия);
КонецПроцедуры  

#КонецОбласти

#Область Контроллер

// Выполняет загрузку курсов для указанных валют и интервалов и их запись
// в РегистрСведений КурсыВалют	
// ---------------------------------------------------------------------
//
// В качестве параметров принимает:
// 	СписокВалют: 	Структура с ссылками на загружаемые валюты
// 	ДатаНачала: 	Дата	указанная в форме как НачалоПериодаЗагрузки
// 	ДатаОкончания:	Дата	указанная в форме как ОкончаниеПериодаЗагрузки      
// Возвращаемое значение:
//	Структура:
//	Статус         	Булево
//	Результат       Массив
//	Описание		Строка
// ------------------------------------------------------------------------
// Контроллер MVC - интерпретирует действия пользователя, оповещая модель о необходимости изменений
// ------------------------------------------------------------------------ 
&НаСервере                                
Функция БНБ_ПолучитьКурсы(ЗНАЧ СписокВалют, ЗНАЧ ДатаНачала = Неопределено, ЗНАЧ ДатаОкончания = Неопределено)  
	
	// Проверка входящих данных
	// Если данных недостаточно, вернуть ошибку и ее описание
	Если (СписокВалют.Количество() = 0) ИЛИ (ДатаНачала = Неопределено) ИЛИ (ДатаОкончания = Неопределено) ИЛИ (ДатаНачала > ДатаОкончания) Тогда	
		Описание = "Недостаточно данных";
		Возврат Новый Структура("Статус,Описание", Ложь,Описание );	
	КонецЕсли;
	
	
	
	// Блок получения котировок
	Котировки = Новый Массив;
	Статус = Истина;
	Для Каждого Валюта из СписокВалют Цикл				
		Если Валюта.Валюта.БНБ_КотироватьКБолгарскомуЛеву И Валюта.Загружать Тогда
			
			// Обновление курсов для подходящих валют
			РезультатЗагрузки = РаботаСКурсамиВалют.БНБ_ПолучитьКурсВалюты(Валюта.Валюта, ДатаНачала, ДатаОкончания);					
			Заголовок = "Получение курсов";
			
			// получение этой валюты не удалось
			Если НЕ РезультатЗагрузки.Статус Тогда	
				// Сделать запись в журнале и перейти к следующей валюте
				Описание = НСтр("ru = 'Нет курсов для валюты %1 (%2).'");
				Описание = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Описание, Валюта.Валюта.Наименование, Валюта.Валюта.Код);
				БНБ_ЗаписатьСобытиеВЖурналРегистрации(Заголовок,Описание,"Ошибка");
				Продолжить;	
			КонецЕсли;
			
			// Обработать полученный результат - записать его в массив Котировки
			Для каждого Котировка Из РезультатЗагрузки.Результат Цикл				
				Котировки.Добавить(Котировка);					
			КонецЦикла;
			
			// Сформировать сообщение о успехе выполнения
			;
			Описание = НСтр("ru = 'Загружено " + Котировки.Количество() + " курсов для валюты %1 (%2).'");
			Описание = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(Описание, Валюта.Валюта.Наименование, Валюта.Валюта.Код);
			БНБ_ЗаписатьСобытиеВЖурналРегистрации(Заголовок,Описание,"Информация");
			
		КонецЕсли;
		
	КонецЦикла;
	
	Если Котировки.Количество() > 0 Тогда
		Статус = Истина;
		УровеньСобытия = "Информация";
		//Заголовок = "Завершена процедура получения курсов";
		Описание = "В Регистр сведений КурсыВалют добавлено " + Котировки.Количество() + " записей";   
		
		//Записать данные
		РаботаСКурсамиВалют.БНБ_ВыполнитьЗаписьКурсовВРеестр(Котировки);
		БНБ_ЗаписатьСобытиеВЖурналРегистрации(Заголовок,Описание,УровеньСобытия);
	КонецЕсли;
	
	Возврат Новый Структура("Статус, Описание",  Статус, Описание);
	
КонецФункции


&НаСервере
Процедура БНБ_ЗаписатьСобытиеВЖурналРегистрации(ТекстЗаголовка, ТекстСобытия, ПредставлениеУровня)
	СписокЗаписейЖурнала = Новый СписокЗначений();	
	ЗаписьЖурнала = Новый Структура("ИмяСобытия, ПредставлениеУровня, Комментарий, ДатаСобытия");
	ЗаписьЖурнала.ИмяСобытия = "ВалютыБНБ." + ТекстЗаголовка;
	ЗаписьЖурнала.ПредставлениеУровня = ПредставлениеУровня; //"Ошибка", "Предупреждение", "Примечание". 
	ЗаписьЖурнала.Комментарий = ТекстСобытия;
	ЗаписьЖурнала.ДатаСобытия = ТекущаяДата();
	СписокЗаписейЖурнала.Добавить(ЗаписьЖурнала);
	ЖурналРегистрации.ЗаписатьСобытияВЖурналРегистрации(СписокЗаписейЖурнала);
	
КонецПроцедуры



#КонецОбласти  



