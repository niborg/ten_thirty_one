require 'sinatra'
require_relative 'model'
require_relative 'calculator'

helpers do
  def number_to_currency(num)
    "$#{num.to_i.to_s.gsub(/\d(?=(...)+$)/, '\0,')}"
  end
end

get '/' do
  erb :index
end

post '/' do
  @model = Model.new(params['model'])
  @result = Calculator.new(@model).call
  erb :index
end
