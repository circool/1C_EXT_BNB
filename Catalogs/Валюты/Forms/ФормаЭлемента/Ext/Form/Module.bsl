﻿
&НаКлиенте
Процедура БНБ_ВалютаКотируетсяКЛевуПриИзмененииПеред(Элемент)
	БНБ_УстановитьДоступностьЭлементовФормы();
	
	//TODO Проверить возможность получения валюты с сайта
	
КонецПроцедуры

&НаКлиенте
Процедура БНБ_ПриОткрытииПеред(Отказ)
	БНБ_УстановитьДоступностьЭлементовФормы();
КонецПроцедуры

&НаКлиенте
Процедура БНБ_УстановитьДоступностьЭлементовФормы() 	
	ЭтаФорма.Элементы.ГруппаСпособУстановкиКурса.Доступность = НЕ Объект.БНБ_КотироватьКБолгарскомуЛеву;
    ЭтаФорма.Элементы.БНБ_ЗагружатьАвтоматически.Видимость = Объект.БНБ_КотироватьКБолгарскомуЛеву;
КонецПроцедуры

&НаСервере
Процедура БНБ_ПередЗаписьюНаСервереПеред(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	Если ТекущийОбъект.БНБ_КотироватьКБолгарскомуЛеву Тогда
		ТекущийОбъект.СпособУстановкиКурса = Перечисления.СпособыУстановкиКурсаВалюты.РучнойВвод; 
	КонецЕсли;
КонецПроцедуры
