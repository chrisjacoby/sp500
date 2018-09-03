# Run program use: source("R/sp500.R")
library(XML)
library(htmltab)
library(quantmod)
library(Quandl)
library(dplyr)

# Load table from Wikipedia for list of SP500 stock tickers
url <- "https://en.wikipedia.org/wiki/List_of_S%26P_500_companies"
# tickers <- readTable(doc = url)
# Get current list of sp500 stock ticers from Wikipedia
tickers <- htmltab(doc = url, which = 1)

colnames(tickers) <- c("Symbol", "Security", "SEC.Filings", "GICS.Sector", 
                       "GICS.Subindustry", "HQ.Address", "Date.Added", "CIK")

# need to replace . with _ in tickers
# https://stackoverflow.com/questions/35655485/replace-with-space-using-gsub-in-r
tickers$Symbol <- gsub(".", "_", tickers$Symbol, fixed=TRUE)

today = Sys.Date()

Quandl.api_key("vNeLkDk6EyzH3gvAxV6F")
# Get today's stock prices
mydata = Quandl.datatable("WIKI/PRICES", date=today)
# myratios = Quandl.datatable("SHARADAR/SF1")
# write.table(x = myratios, file = "ratios.csv", sep = ",", append = FALSE, col.names = TRUE)


# Combine Quandl list of prices and Wikipedia SP500 stock tickers into one table
sp500 <- left_join(tickers, mydata, by = c("Symbol" = "ticker"))

# Add Price Changes to data frame
# Difference between Open and Close prices for the day
sp500$OC_Diff <- sp500$close - sp500$open
sp500$OC_Chg <- round(log(sp500$close/sp500$open),4)
# Difference between Open and High price for the day
sp500$OH_Diff <- sp500$high - sp500$open
sp500$OH_Chg <- round(log(sp500$high/sp500$open),4)
# Difference between Low and High price for the day
sp500$LH_Diff <- sp500$high - sp500$low
sp500$LH_Chg <- round(log(sp500$high/sp500$low),4)


# add ranking based on largest change from Open price to Close price
# https://stackoverflow.com/questions/24938172/adding-a-ranking-column-to-a-dataframe
sp500$rank_OC <- NA
sp500$rank_OC[order(-sp500$OC_Chg)] <- 1:nrow(sp500)

sp500$rank_vol <- NA
sp500$rank_vol[order(-sp500$volume)] <- 1:nrow(sp500)

# Add finacial ratios, may even start developing valuation epstimates for every company
#ms_url <- "http://financials.morningstar.com/valuation/price-ratio.html?t=FCX&region=usa&culture=en-US"
#getFinancials("AAPL")

# develop pivot table next


# Write date to file
# write.table(x = sp500, file = "sp500.csv", sep = ",")
write.table(x = sp500, file = "sp500.csv", sep = ",", append = TRUE, col.names = FALSE)
