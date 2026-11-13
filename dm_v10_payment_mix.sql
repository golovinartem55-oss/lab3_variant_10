DROP VIEW IF EXISTS dm_v10_payment_mix;
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
  AND o.purchase_month BETWEEN '2017-01-01' AND '2018-08-01';
