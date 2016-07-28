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

def scrape_team_rankings(team_code, team_name, year)
  url_team_name = team_name.downcase.gsub(/\s/, '-')
  doc = Nokogiri::HTML(open(URI.escape("http://espn.go.com/nfl/team/rankings/_/name/#{team_code}/year/#{year}/#{url_team_name}")))
  
  # Set the output location
  output_dir = "output/#{team_name}/rankings"
  output_file = "#{output_dir}/#{year}.csv"
  FileUtils.mkdir_p output_dir
  
  # Write the specified table to file
  write_table_to_csv(output_file, doc.css('table'))
end

def scrape_all_team_rakings(start_year, end_year)
  teams = YAML.load_file('team_keys.yml')
  current_year = start_year
  
  # For every team, get the game data from start_year to end_year
  teams.each do |team_name, codes|
    puts team_name
    
    while current_year <= end_year
      puts "  #{current_year}"
      scrape_team_rankings(codes['espn'], team_name, current_year)
      current_year += 1
    end
    
    current_year = start_year
  end
end

def write_table_to_csv(file_name, table)
  csv = CSV.open(file_name, 'w',{:col_sep => ","})

  # Loop through every table row
  table.css('tr').each do |row|
    tarray = []

    # Write every column in the row to the csv file
    row.css('td').each do |cell|
      puts cell.text
      tarray << cell.text.strip
    end
    
    csv << tarray
  end

  csv.close
end

scrape_all_team_rakings(START_YEAR, END_YEAR)