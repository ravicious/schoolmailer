%w(haml digest dm-core dm-validations dm-timestamps dm-migrations rack-flash lib/mailer lib/smtp-tls lib/config_file lib/url_for).each {|lib| require lib}

class Schoolmailer < Sinatra::Base

  enable :sessions
  use Rack::Flash
  register Sinatra::ConfigFile
  helpers Sinatra::Mailer
  helpers Sinatra::UrlForHelper

  set :environment, (ENV['RACK_ENV'] || 'development')

  # Conf
  
  configure do
    config_file "conf/settings.yml", "conf/#{environment}.settings.yml"
  end

  configure :production, :development do
    DataMapper.auto_upgrade!
  end

  configure :development do
    DataMapper::Logger.new($stdout, :debug)
  end

  configure :test do
    # Czyść bazę przy każdym uruchomieniu w środowisku testowym
    DataMapper.auto_migrate!
  end

  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/schoolmailer_#{environment}.sqlite3")

  # Models
  require "models/email"
  
  DataMapper.finalize

  # Mailer
  
  Sinatra::Mailer.config = {:sendmail_path => sendmail_path}
  Sinatra::Mailer.delivery_method = :sendmail

  # Routes

  get '/' do 
    @emails = Email.all(:order => [:address.desc])
    haml :index
  end

  post '/emails' do
    @email =  Email.new(params[:email])

    if @email.save
      flash[:notice] = "Mail dodany do bazy! Instrukcje dotyczące aktywacji właśnie wylądowały w Twojej skrzynce."

      msgbody = <<EOF
Cześć,\n
\n
Aby aktywować konto, kliknij na poniższy link.\n
\n
#{url_for("/emails/activation/#{@email.address}/#{@email.confirmation_hash}", :full)}\n
\n
----------------------------------------------\n
Jeśli ten email to pomyłka, po prostu go zignoruj.
EOF
      email :to => "ravicious@gmail.com",
            :from => "ravicious@gmail.com",
            :subject => "Aktywacja konta",
            #:body => haml(:mail_activation)
            :text => msgbody

    else
      flash[:error] = "Podany email już istnieje w bazie lub jest nieprawidłowy."
    end

    redirect url_for('/')

  end

end
