--CREATE OR REPLACE FUNCTION _final_median(numeric[])
--   RETURNS numeric AS
--$$
--   SELECT AVG(val)
--   FROM (
--     SELECT val
--     FROM unnest($1) val
--     ORDER BY 1
--     LIMIT  2 - MOD(array_upper($1, 1), 2)
--     OFFSET CEIL(array_upper($1, 1) / 2.0) - 1
--   ) sub;
--$$
--LANGUAGE 'sql' IMMUTABLE;
 
--CREATE AGGREGATE median(numeric) (
--  SFUNC=array_append,
--  STYPE=numeric[],
--  FINALFUNC=_final_median,
--  INITCOND='{}'
--);
select * from
((
select
	extract(month from trade_date) as month, 
	extract(year from trade_date) as year, 
	round(avg(close_value), 3) average, 
	round(median(close_value), 3) median, 
	round(max(close_value), 3) max, 
	round(min(close_value), 3) as min, 
	count(close_value) as count,
	'down_trades' as up_down 
from
	(
	select * from trade_positions
	where position='BUY' and close_value<=1
	) as all_up_trades
	group by extract(month from trade_date), extract(year from trade_date)
	order by year, month
) UNION (
select 
	extract(month from trade_date) as month, 
	extract(year from trade_date) as year, 
	round(avg(close_value), 3) average, 
	round(median(close_value), 3) median, 
	round(max(close_value), 3) max, 
	round(min(close_value), 3) as min, 
	count(close_value) as count,
	'up_trades' as up_down 
from 
	(
	select * from trade_positions 
	where position='BUY' and close_value>1
	) as all_down_trades
	group by extract(month from trade_date), extract(year from trade_date)
	order by year, month
)
) as monthlystats
order by year, month
