# encoding: utf-8
%w(haml digest dm-core dm-validations dm-timestamps dm-migrations rack-flash mail).each {|lib| require lib}
%w(lib/config_file lib/url_for).each {|lib| require_relative lib}

class Schoolmailer < Sinatra::Base

  enable :sessions
  use Rack::Flash
  register Sinatra::ConfigFile
  helpers Sinatra::UrlForHelper

  configure do
    config_file "conf/settings.yml", "conf/#{environment}.settings.yml"
  end

  set :environment, (ENV['RACK_ENV'] || 'development')

  # Naprawdę nie wiem, dlaczego Sinatra nie korzysta z domyślnych ustawień
  set :public, File.dirname(__FILE__) + '/public'

  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/schoolmailer_#{environment}.sqlite3")
  #DataMapper.setup(:default, "postgres://#{database_login}:#{database_pass}@localhost/schoolmailer_#{environment}")

  # Models
  require_relative "models/email"
  require_relative "models/replacement"

  DataMapper.finalize

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

  # Mailer
  
  if %w(development test).include? Schoolmailer.environment
    Mail.defaults do
      delivery_method :test
    end
  else
    Mail.defaults do
      delivery_method :smtp, {
        :address => "smtp.gmail.com",
        :port => 587,
        :domain => 'local.localhost',
        :user_name => ::Schoolmailer.email_user,
        :password => ::Schoolmailer.email_pass,
        :authentication => 'plain',
        :enable_starttls_auto => true
      }
    end
  end

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
Aby aktywować konto, kliknij na poniższy link.\n
#{url_for("/emails/confirm/#{@email.address}/#{@email.confirmation_hash}", :full)}\n
----------------------------------------------\n
Jeśli ten email to pomyłka, po prostu go zignoruj.
EOF
      mail = Mail.new
      mail.to @email.address
      mail.from "ravicious@gmail.com"
      mail.subject "Aktywacja konta"
      mail.body msgbody
      mail.deliver!

    else

      # Nie chce mi się bawić w tłumaczenie error messages
      case @email.errors.on(:address).first
      when /already taken/
        flash[:error] = "Podany email już istnieje w bazie!"
      when /invalid format/
        flash[:error] = "Podany email jest nieprawidłowy!"
      end

    end

    redirect url_for('/')

  end

  get '/emails/confirm/:email/:confirmation_hash' do

    begin
      @email = Email.get!(params[:email])

      if @email.confirm(params[:confirmation_hash])
        flash[:notice] = "Email został aktywowany."
        msgbody = <<EOF
Hej,\n
Twoje konto właśnie zostało aktywowane. Gdybyś jednak w przyszłości chciał/a zrezygnować z subskrypcji, po prostu wejdź pod poniższy adres.\n
#{url_for("/emails/unsubscribe/#{@email.address}/#{@email.confirmation_hash}", :full)}
EOF
        mail = Mail.new
        mail.to @email.address
        mail.from "ravicious@gmail.com"
        mail.subject "Aktywacja konta powiodła się!"
        mail.body msgbody
        mail.deliver!

      else
        flash[:error] = "Klucz aktywujący nie pasuje do Twojego maila. Być może Twoje konto jest już aktywne."
      end

    rescue DataMapper::ObjectNotFoundError
      flash[:error] = "Ups, nie mamy w bazie takiego maila!"

    ensure
      redirect url_for('/')
    end

  end

  get '/emails/unsubscribe/:email/:confirmation_hash' do

    begin
      @email = Email.get!(params[:email])

      if @email.unsubscribe(params[:confirmation_hash])
        flash[:notice] = "Twoja subskrypcja została anulowana."
      else
        flash[:error] = "Klucz aktywujący nie pasuje do Twojego maila."
      end

    rescue DataMapper::ObjectNotFoundError
      flash[:error] = "Ups, nie mamy w bazie takiego maila!"

    ensure
      redirect url_for('/')
    end

  end

end
