module MomoStocks
  module Common
    def institutional_ownership_date
      InstitutionalOwnershipSnapshot.maximum(:scrape_date)
    end

    def short_interest_date
      ShortInterestHistory.maximum(:short_interest_date)
    end
  end
end