select * from `bigquery-public-data.usa_names.usa_1910_2013`;

select count(*) from `bigquery-public-data.usa_names.usa_1910_2013`;

SELECT
  name, gender,
  SUM(number) AS total
FROM
  `bigquery-public-data.usa_names.usa_1910_2013`
GROUP BY
  name, gender
ORDER BY
  total DESC
LIMIT
  10;

SELECT year, SUM(number) AS count
FROM
  `bigquery-public-data.usa_names.usa_1910_2013`
WHERE 
  name = "James"
GROUP BY
  year
ORDER BY
  year DESC;