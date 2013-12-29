qmonths = ['Q1','Q1','Q1','Q2','Q2','Q2','Q3','Q3','Q3','Q4','Q4','Q4']


PriceDate.all.each do |pd|
  pd.update(quarter: qmonths[pd.price_date.month-1])

end