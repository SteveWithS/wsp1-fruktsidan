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

     get '/fruits/new' do
      erb(:'fruits/new')
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

    # Visar formuläret för att ändra en frukt
    get '/fruits/:id/edit' do |id|
      @fruit = db.execute('SELECT * FROM products WHERE id=?', id).first
      erb(:"fruits/edit")
    end

# Sparar ändringen i databasen
    post '/fruits/:id/update' do |id|
      f_name = params['fruit_name']
      f_description = params['fruit_description']

      db.execute('UPDATE products SET name=?, description=? WHERE id=?', [f_name, f_description, id])
      redirect('/fruits')
    end

    post '/fruits/:id/delete' do | id |
      db.execute("DELETE FROM products WHERE id =?", id)
      redirect("/fruits")
    end

    post '/fruits' do
      name = params['fruit_name']
      description = params['fruit_description']

      db.execute('INSERT INTO products (name, description) VALUES (?, ?)', [name, description])
      redirect('/fruits')
    end

    get '/fruits/:id' do | id |
      @fruit = db.execute('SELECT * FROM products 
						   WHERE id=?', id).first
      @category = db.execute('SELECT * FROM categories 
							   WHERE id=?',
							   @fruit['category_id']).first
      ap @fruit
      ap @category
      erb(:"fruits/show")
    end

end