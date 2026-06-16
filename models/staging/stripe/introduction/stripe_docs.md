{% docs stripe payment %}

| columns        | definition                  |
| -------------- | ----------------------------|
| PAYMENT_ID      | PK payment table           |
| ORDER_ID        | Fk to order table          |
| PAYMENT_METHOD  | payment method             | 
| PAYMENT_STATUS  | payment satus              |
| PAYMENT_AMOUNT  | Net amount on the invoice  |
| PAYMENT_CREATED | payment date               |
| _BATCHED_AT     | date of upload             |

{% enddocs %}
