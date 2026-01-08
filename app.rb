require 'sinatra'
require 'sinatra/reloader' if development?
require 'sequel'

# Database connection
DB = Sequel.sqlite(File.join(File.dirname(__FILE__), 'nfsn.db'))

# Pagination helper
PER_PAGE = 50

def paginate(dataset, page)
  page = [1, page.to_i].max
  total = dataset.count
  total_pages = (total.to_f / PER_PAGE).ceil
  total_pages = 1 if total_pages < 1
  records = dataset.limit(PER_PAGE, (page - 1) * PER_PAGE).all
  [records, total, page, total_pages]
end

# Routes
get '/' do
  @title = 'Dashboard'
  @counts = {
    'customers' => DB[:customers].count,
    'stores' => DB[:stores].count,
    'products' => DB[:products].count,
    'orders' => DB[:orders].count,
    'order_rows' => DB[:order_rows].count,
    'dates' => DB[:dates].count,
    'currency' => DB[:currency_exchanges].count
  }
  erb :index
end

get '/customers' do
  @title = 'Customers'
  @records, @total, @page, @total_pages = paginate(DB[:customers], params[:page])
  erb :customers
end

get '/stores' do
  @title = 'Stores'
  @records, @total, @page, @total_pages = paginate(DB[:stores], params[:page])
  erb :stores
end

get '/products' do
  @title = 'Products'
  @records, @total, @page, @total_pages = paginate(DB[:products], params[:page])
  erb :products
end

get '/orders' do
  @title = 'Orders'
  @records, @total, @page, @total_pages = paginate(DB[:orders], params[:page])
  erb :orders
end

get '/order_rows' do
  @title = 'Order Rows'
  @records, @total, @page, @total_pages = paginate(DB[:order_rows], params[:page])
  erb :order_rows
end

get '/dates' do
  @title = 'Dates'
  @records, @total, @page, @total_pages = paginate(DB[:dates], params[:page])
  erb :dates
end

get '/currency' do
  @title = 'Currency Exchange'
  @records, @total, @page, @total_pages = paginate(DB[:currency_exchanges], params[:page])
  erb :currency
end
