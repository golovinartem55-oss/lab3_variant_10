# ЛР-3. Аналитический дашборд для бизнес-кейса — вариант 10

**Студент:** Головин А. А. · **группа:** БД-251м
**Бизнес-кейс:** Структура способов оплаты

## Цель работы
Какими способами платят клиенты, как меняется структура и какой средний платёж у каждого способа?

## Исследуемые метрики
- **Средний платёж** = `AVG([payment_value])`
- **Платежей** = `COUNT([order_id])`

## Архитектура решения
Kaggle (Olist, 9 CSV) → Python (`urllib`, `pandas`) → SQLite: RAW → STAGING → CORE → витрина `dm_v10_payment_mix` → CSV → Yandex DataLens.

## Технологический стек
Python 3.13.7, pandas 3.0.6, SQLite 3.50.4, Google Colab / Jupyter, Yandex DataLens.

## Схема данных
Слои: `raw_*` (9 таблиц) → `stg_*` (типизация, очистка) → `core_order`, `core_item`, `dim_state` → `dm_v10_payment_mix` (VIEW).
<!-- вставьте скриншот или ER-диаграмму: img/er.png -->

## SQL витрины
```sql
CREATE VIEW dm_v10_payment_mix AS
SELECT
  p.order_id,
  p.payment_sequential,
  o.purchase_month              AS month,
  o.customer_state              AS region,
  p.payment_type,
  p.installments,
  ROUND(p.payment_value, 2)     AS payment_value
FROM stg_payments p
JOIN core_order o USING (order_id)
WHERE o.order_status = 'delivered'
  AND o.purchase_month BETWEEN '2017-01-01' AND '2018-08-01'
```

## Контрольные значения
| Вопрос | Ответ |
|---|---|
| Доля кредитных карт в сумме платежей, % | 78.5 |
| Средний платёж ваучером, BRL | 62.54 |

## Дашборд DataLens
Ссылка: https://datalens.ru/embeds/dash#dl_embed_token=eyJhbGciOiJQUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Imt4NXEycXl3dGZ2NjMifQ.eyJlbWJlZElkIjoicDJhdjd3anFibTRzOCIsInNoYXJpbmdJZCI6Iml2M28wcGRpMjBydTEiLCJkbEVtYmVkU2VydmljZSI6IllDX0RBVEFMRU5TX0VNQkVERElOR19TRVJWSUNFX01BUksiLCJpYXQiOjE3OTQ2MDA3MzAsImV4cCI6MTc5NDY4NzEzMCwicGFyYW1zIjp7fX0.QOKkNBftbsq3bGlFxUHfbZS5d4VxiKYvFpRoVuiLcyC7X0DSouGrZLL6L2JnFXgoWk3ANTJRlc6qPi3vgro3D5Z7qcO2UYP2I-oyi9ngAfozY_x44Xcns_55o8RTvo4U8N1d6C4YuXI4eVnix5dAPmERdMAcNVK6QuLrKqIGtfApGq7N2eiLrQvDmAA2b7t2-R6F93_gw6EQl5jE_U8JYtBEicclMWS0wjVw262BJVow5lnNI5ut3M2mTU-PdwhHRh6rlclaltJ67oSOk3Y0nVi5udSd6MKCQv3w5JbJ1qtOX6w9R8PtNK8tHNccJSGoSwjVTCCeJKGSoNbLWVhV9w

| № | Тип | Название |
|---|---|---|
| 1 | Индикатор | Сумма платежей |
| 2 | Круговая диаграмма | Доля способов оплаты |
| 3 | Столбчатая диаграмма | Средний платёж по способам |
| 4 | Линейная диаграмма | Платежи по месяцам |
| 5 | Комбинированная диаграмма | Число платежей и средний платёж |

![Дашборд](img/dashboard.PNG)

## Выводы и бизнес-рекомендации
1. **Кредитная карта — абсолютный лидер.** На нее приходится 78.5% всей суммы платежей (около 12 млн BRL из 15.3 млн). Остальные способы (boleto, voucher, debit_card) делят оставшиеся 21.5%. Это означает, что платёжная инфраструктура маркетплейса критически зависит от эквайринга карт.

2. **Средний платёж зависит от способа оплаты.** Самые крупные чеки проходят по кредитным картам (~160 BRL) и банковским переводам boleto (~144 BRL). Самая маленькая сумма — у ваучеров voucher (~62.5 BRL), так как это, как правило, подарочные сертификаты на небольшие суммы.

3. **Структура оплаты стабильна во времени.** Линейный график показывает, что доля credit_card и boleto держится примерно на одном уровне на протяжении 2017–2018 гг. Однако средний чек по всем способам оплаты вырос с ~135 BRL в начале 2017 года до ~170 BRL к середине 2018 года.

**Рекомендация:** для снижения расходов на комиссию эквайринга (которая для кредитных карт самая высокая) стоит стимулировать клиентов платить через boleto или ваучеры. Например, давать скидку 1–2% при оплате банковским переводом. Снижение доли кредиток с 78.5% до 70% при текущем обороте даст существенную экономию для маркетплейса.
