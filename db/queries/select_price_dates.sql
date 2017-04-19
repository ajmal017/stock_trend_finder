--select extract(year from price_date) as year, count(price_date) as trading_days from price_dates group by year order by year desc;

select price_dates.price_date, extract(year from price_dates.price_date) as year, count(daily_stock_prices.price_date) from price_dates 
inner join daily_stock_prices on price_dates.price_date=daily_stock_prices.price_date
where price_dates.price_date >= '01-01-2012' and price_dates.price_date <= '12-31-2012'
group by price_dates.price_date, year
order by price_dates.price_date; 