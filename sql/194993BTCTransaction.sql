CREATE OR REPLACE TABLE lab.51 (transaction_hash STRING) AS
SELECT
  transactions.hash AS transaction_hash
FROM
  `bigquery-public-data.crypto_bitcoin.transactions` AS transactions
CROSS JOIN
  UNNEST(transactions.outputs) AS outputs
WHERE
  outputs.value = 194993 * 100000000  -- Convert BTC to satoshis
GROUP BY
  transaction_hash
LIMIT 1