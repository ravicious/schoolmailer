%w(haml digest dm-core dm-validations dm-timestamps dm-migrations rack-flash lib/mailer lib/smtp-tls lib/config_file lib/url_for).each {|lib| require lib}

class Schoolmailer < Sinatra::Base

  enable :sessions
  use Rack::Flash
  register Sinatra::ConfigFile
  helpers Sinatra::Mailer
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
  require "models/email"

  DataMapper.finalize

  configure :production, :development do
    DataMapper.auto_upgrade!
  end

  configure :development do
    DataMapper::Logger.new($stdout, :debug)
  end

  configure :development, :test do
    set :sendmail_path, "#{Dir.pwd}/lib/fake-mailer"
  end

  configure :test do
    # Czyść bazę przy każdym uruchomieniu w środowisku testowym
    DataMapper.auto_migrate!
  end

  # Mailer

  Sinatra::Mailer.config = {
    :host => 'smtp.gmail.com',
    :port => '587',
    :user => email_user,
    :pass => email_pass,
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

      msgbody = <<EOF
Cześć,\n
\n
Aby aktywować konto, kliknij na poniższy link.\n
\n
#{url_for("/emails/confirm/#{@email.address}/#{@email.confirmation_hash}", :full)}\n
\n
----------------------------------------------\n
Jeśli ten email to pomyłka, po prostu go zignoruj.
EOF
      email :to => @email.address,
            :from => "ravicious@gmail.com",
            :subject => "Aktywacja konta",
            :text => msgbody

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
\n
Twoje konto właśnie zostało aktywowane. Gdybyś jednak w przyszłości chciał/a zrezygnować z subskrypcji, po prostu wejdź pod poniższy adres.\n
\n
#{url_for("/emails/unsubscribe/#{@email.address}/#{@email.confirmation_hash}", :full)}
EOF
        email :to => @email.address,
              :from => "ravicious@gmail.com",
              :subject => "Aktywacja konta powiodła się!",
              :text => msgbody

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
