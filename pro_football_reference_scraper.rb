require 'open-uri'
require 'csv'
require 'yaml'

START_YEAR = 2011
END_YEAR = 2015

def require_gem gem_name
  begin
    gem gem_name
  rescue LoadError
    Gem::DependencyInstaller.new.install gem_name
  end
  require gem_name
end

require_gem 'nokogiri'

def scrape_team_games(team_code, team_name, year)
  doc = Nokogiri::HTML(open(URI.escape("http://www.pro-football-reference.com/teams/#{team_code}/#{year}.htm")))
  
  # Set the output location
  output_dir = "output/#{team_name}/games"
  output_file = "#{output_dir}/#{year}.csv"
  FileUtils.mkdir_p output_dir
  
  # Write the specified table to file
  write_table_to_csv(output_file, doc.css('table#games'))
end

def scrape_all_team_games(start_year, end_year)
  teams = YAML.load_file('team_keys.yml')
  current_year = start_year
  
  # For every team, get the game data from start_year to end_year
  teams.each do |team_name, codes|
    puts team_name
    
    while current_year <= end_year
      puts "  #{current_year}"
      scrape_team_games(codes['pfr'], team_name, current_year)
      current_year += 1
    end
    
    current_year = start_year
  end
end

def write_table_to_csv(file_name, table)
  csv = CSV.open(file_name, 'w',{:col_sep => ","})
  
  # Get the header of the table
  header = []
  table.css('thead th').each do |th|
    header << th.text.strip
  end
  csv << header

  # Loop through every table row
  table.css('tbody tr').each do |row|
    tarray = []
    
    # For whatever reason, pro football reference uses a th as their first td. Weird.
    row.css('th').each do |th|
      tarray << th.text.strip
    end
    
    # Write every column in the row to the csv file
    row.css('td').each do |cell|
      tarray << cell.text.strip
    end
    
    csv << tarray
  end

  csv.close
end

scrape_all_team_games(START_YEAR, END_YEAR)