#!/usr/bin/env ruby
# Database seeding script - loads CSV data from contoso/ into SQLite

require 'csv'
require 'sequel'
require 'fileutils'

DB_PATH = File.join(File.dirname(__FILE__), '..', 'nfsn.db')
CONTOSO_PATH = File.join(File.dirname(__FILE__), '..', 'contoso')

# Remove existing database
FileUtils.rm_f(DB_PATH)

# Connect to SQLite
DB = Sequel.sqlite(DB_PATH)

puts "Creating database at #{DB_PATH}..."

# Create tables
DB.create_table :customers do
  primary_key :id
  Integer :customer_key, unique: true
  Integer :geo_area_key
  String :start_dt
  String :end_dt
  String :continent
  String :gender
  String :title
  String :given_name
  String :middle_initial
  String :surname
  String :street_address
  String :city
  String :state
  String :state_full
  String :zip_code
  String :country
  String :country_full
  String :birthday
  Integer :age
  String :occupation
  String :company
  String :vehicle
  Float :latitude
  Float :longitude
end

DB.create_table :stores do
  primary_key :id
  Integer :store_key, unique: true
  Integer :store_code
  Integer :geo_area_key
  String :country_code
  String :country_name
  String :state
  String :open_date
  String :close_date
  String :description
  Integer :square_meters
  String :status
end

DB.create_table :products do
  primary_key :id
  Integer :product_key, unique: true
  String :product_code
  String :product_name
  String :manufacturer
  String :brand
  String :color
  String :weight_unit
  Float :weight
  Float :cost
  Float :price
  Integer :category_key
  String :category_name
  Integer :sub_category_key
  String :sub_category_name
end

DB.create_table :orders do
  primary_key :id
  Integer :order_key, unique: true
  Integer :customer_key
  Integer :store_key
  String :order_date
  String :delivery_date
  String :currency_code
end

DB.create_table :order_rows do
  primary_key :id
  Integer :order_key
  Integer :line_number
  Integer :product_key
  Integer :quantity
  Float :unit_price
  Float :net_price
  Float :unit_cost
end

DB.create_table :dates do
  primary_key :id
  String :date, unique: true
  Integer :date_key
  Integer :year
  String :year_quarter
  Integer :year_quarter_number
  String :quarter
  String :year_month
  String :year_month_short
  Integer :year_month_number
  String :month
  String :month_short
  Integer :month_number
  String :day_of_week
  String :day_of_week_short
  Integer :day_of_week_number
  Integer :working_day
  Integer :working_day_number
end

DB.create_table :currency_exchanges do
  primary_key :id
  String :date
  String :from_currency
  String :to_currency
  Float :exchange
end

# Helper to convert CSV headers to snake_case symbols
def snake_case(str)
  str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
     .gsub(/([a-z\d])([A-Z])/, '\1_\2')
     .downcase
     .gsub(/\s+/, '_')
     .to_sym
end

# Load CSV data
def load_csv(filename, table_name, column_map = nil)
  csv_path = File.join(CONTOSO_PATH, filename)
  puts "Loading #{filename}..."
  
  rows = []
  CSV.foreach(csv_path, headers: true) do |row|
    record = {}
    row.each do |header, value|
      key = column_map ? column_map[header] : snake_case(header)
      next unless key
      record[key] = value
    end
    rows << record
    
    # Batch insert every 1000 rows
    if rows.length >= 1000
      DB[table_name].multi_insert(rows)
      rows = []
    end
  end
  
  # Insert remaining rows
  DB[table_name].multi_insert(rows) unless rows.empty?
  
  count = DB[table_name].count
  puts "  -> Loaded #{count} records into #{table_name}"
end

# Column mappings for each CSV
customer_map = {
  'CustomerKey' => :customer_key, 'GeoAreaKey' => :geo_area_key,
  'StartDT' => :start_dt, 'EndDT' => :end_dt, 'Continent' => :continent,
  'Gender' => :gender, 'Title' => :title, 'GivenName' => :given_name,
  'MiddleInitial' => :middle_initial, 'Surname' => :surname,
  'StreetAddress' => :street_address, 'City' => :city, 'State' => :state,
  'StateFull' => :state_full, 'ZipCode' => :zip_code, 'Country' => :country,
  'CountryFull' => :country_full, 'Birthday' => :birthday, 'Age' => :age,
  'Occupation' => :occupation, 'Company' => :company, 'Vehicle' => :vehicle,
  'Latitude' => :latitude, 'Longitude' => :longitude
}

store_map = {
  'StoreKey' => :store_key, 'StoreCode' => :store_code, 'GeoAreaKey' => :geo_area_key,
  'CountryCode' => :country_code, 'CountryName' => :country_name, 'State' => :state,
  'OpenDate' => :open_date, 'CloseDate' => :close_date, 'Description' => :description,
  'SquareMeters' => :square_meters, 'Status' => :status
}

product_map = {
  'ProductKey' => :product_key, 'ProductCode' => :product_code,
  'ProductName' => :product_name, 'Manufacturer' => :manufacturer,
  'Brand' => :brand, 'Color' => :color, 'WeightUnit' => :weight_unit,
  'Weight' => :weight, 'Cost' => :cost, 'Price' => :price,
  'CategoryKey' => :category_key, 'CategoryName' => :category_name,
  'SubCategoryKey' => :sub_category_key, 'SubCategoryName' => :sub_category_name
}

order_map = {
  'OrderKey' => :order_key, 'CustomerKey' => :customer_key, 'StoreKey' => :store_key,
  'OrderDate' => :order_date, 'DeliveryDate' => :delivery_date, 'CurrencyCode' => :currency_code
}

order_row_map = {
  'OrderKey' => :order_key, 'LineNumber' => :line_number, 'ProductKey' => :product_key,
  'Quantity' => :quantity, 'UnitPrice' => :unit_price, 'NetPrice' => :net_price,
  'UnitCost' => :unit_cost
}

date_map = {
  'Date' => :date, 'DateKey' => :date_key, 'Year' => :year,
  'YearQuarter' => :year_quarter, 'YearQuarterNumber' => :year_quarter_number,
  'Quarter' => :quarter, 'YearMonth' => :year_month, 'YearMonthShort' => :year_month_short,
  'YearMonthNumber' => :year_month_number, 'Month' => :month, 'MonthShort' => :month_short,
  'MonthNumber' => :month_number, 'DayofWeek' => :day_of_week,
  'DayofWeekShort' => :day_of_week_short, 'DayofWeekNumber' => :day_of_week_number,
  'WorkingDay' => :working_day, 'WorkingDayNumber' => :working_day_number
}

currency_map = {
  'Date' => :date, 'FromCurrency' => :from_currency,
  'ToCurrency' => :to_currency, 'Exchange' => :exchange
}

# Load all CSV files
load_csv('customer.csv', :customers, customer_map)
load_csv('store.csv', :stores, store_map)
load_csv('product.csv', :products, product_map)
load_csv('orders.csv', :orders, order_map)
load_csv('orderrows.csv', :order_rows, order_row_map)
load_csv('date.csv', :dates, date_map)
load_csv('currencyexchange.csv', :currency_exchanges, currency_map)

puts "\nDatabase seeding complete!"
puts "Database file: #{DB_PATH}"
