# NFL Data Scrapers

There are currently two scrapers, one for the Pro Football Reference and another for the ESPN Team Rankings.

## Setup

Data is stored in CSV files by year. To set the year range, open each script and adjust the START_YEAR and END_YEAR variables as needed.

The configuration is stored in team_keys.yml. This is where team codes can be found for each site.

## Running

To run the scripts simply do the following:

`ruby pro_football_reference_scraper.rb`

and

`ruby espn_team_rankings_scraper.rb`