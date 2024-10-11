CREATE OR REPLACE TABLE lab.52 (balance NUMERIC) AS
WITH double_entry_book AS (
   -- debits
   SELECT
    array_to_string(inputs.addresses, ",") AS address
   , inputs.type
   , -inputs.value AS value
   FROM `bigquery-public-data.crypto_bitcoin.inputs` AS inputs
   UNION ALL
   -- credits
   SELECT
    array_to_string(outputs.addresses, ",") AS address
   , outputs.type
   , outputs.value AS value
   FROM `bigquery-public-data.crypto_bitcoin.outputs` AS outputs
)
SELECT
   SUM(value) AS balance
FROM
   double_entry_book
WHERE
   address = '1XPTgDRhN8RFnzniWCddobD9iKZatrvH4'  -- Purchaser's address
GROUP BY
   address
