require 'sinatra/base'
require 'sinatra/reloader'
require 'sqlite3'
require 'debug'
require 'awesome_print'

class App < Sinatra::Base
    register Sinatra::Reloader

    def db
      return @db if @db

      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    get '/' do
      redirect '/fruits'
    end

    # Hämta alla frukter
    get '/fruits' do
      @fruits = db.execute('SELECT * FROM products')
      ap @fruits
      erb(:"fruits/index")
    end

    # Hämta en specifik frukt
    get '/fruits/:id' do |id|
      @fruit = db.execute(
        'SELECT * FROM products WHERE id=?',
        id
      ).first

      ap @fruit
      erb(:"fruits/show")
    end

    post '/fruits/:id/delete' do | id |
      db.execute("DELETE FROM products WHERE id =?", id)
      redirect("/fruits")
    end
end