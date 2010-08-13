%w(haml digest dm-core dm-validations dm-timestamps dm-migrations rack-flash lib/mailer lib/smtp-tls lib/config_file).each {|lib| require lib}

class Schoolmailer < Sinatra::Base

  enable :sessions
  use Rack::Flash
  register Sinatra::ConfigFile

  # Conf
  
  configure do
    config_file "conf/settings.yml", "conf/#{environment}.settings.yml"
  end

  configure :development do
    DataMapper::Logger.new($stdout, :debug)
  end

  # DataMapper
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/schoolmailer_#{environment}.sqlite3")

  # Models
  require "models/email"
  
  DataMapper.finalize
  DataMapper.auto_upgrade!

  # Mailer
  
  Sinatra::Mailer.config = {
    :host => 'smtp.sendgrid.net',
    :port => '587',
    :user => sendgrid_user,
    :pass => sendgrid_pass,
    :auth => :plain
  }

  # Routes

  get '/' do 
    @emails = Email.all(:order => [:address.desc])
    haml :index
  end

  post '/emails' do
    @email =  Email.new(params[:email])

    if @email.save
      flash[:notice] = "Mail dodany do bazy! Instrukcje dotyczące aktywacji właśnie wylądowały w Twojej skrzynce."
    else
      flash[:error] = "Podany email już istnieje w bazie lub jest nieprawidłowy."
    end

    redirect '/'

  end

end
