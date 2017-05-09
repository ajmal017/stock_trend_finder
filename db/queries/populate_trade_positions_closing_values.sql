update trade_positions tp set
close_date=(select trade_date from trade_positions tps1 where tps1.gap_up_id=tp.gap_up_id and tps1.position='SELL'),
close_value=(select value from trade_positions tps1 where tps1.gap_up_id=tp.gap_up_id and tps1.position='SELL'),
close_price=(select price from trade_positions tps1 where tps1.gap_up_id=tp.gap_up_id and tps1.position='SELL')
where tp.position='BUY'


--update trade_positions tp set 
-- close_date=(select trade_date from trade_positions tps1 where tps1.gap_up_id=tp.gap_up_id and tps1.position='SELL'),
-- close_value=(select value from trade_positions tps2 where tps2.gap_up_id=tp.gap_up_id and tps2.position='SELL'),
 
--where tp.position='BUY'