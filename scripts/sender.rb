# encoding: utf-8
require_relative "script_helper"

%w(activesupport mail).each {|lib| require lib}

Time.zone = 'Warsaw'

if %w(development test).include? ENV['RACK_ENV']

  Mail.defaults do
    delivery_method :test
  end

else 

  Mail.defaults do
    delivery_method :smtp, {
      :address => "smtp.gmail.com",
      :port => 587,
      :domain => 'local.localhost',
      :user_name => $config['email_user'],
      :password => $config['email_pass'],
      :authentication => 'plain',
      :enable_starttls_auto => true
    }
  end

end

recipients = Email.activated
replacement = Replacement.newest_unmailed
drawn_number = DrawnNumber.newest_unmailed

mail_body = <<EOF
Cześć,\n
Oto codzienna porcja danych z dziennika internetowego Twojego LO.\n
______________________________________________\n
EOF

if drawn_number
  mail_body += "Numerek: #{drawn_number.value}\n"
else
  mail_body += "Numerek: nie udało się pobrać numerka na jutrzejszy dzień.\n"
end

mail_body += <<EOF
______________________________________________\n
Zastępstwa:
EOF

# Dodaj zastępstwa do treści maila

if replacement
  mail_body += "#{replacement.body}\n"
else
  mail_body += "Brak zastępstw na jutrzejszy dzień.\n"
end

mail_body += <<EOF
______________________________________________\n
Aby zrezygnować z subskrypcji, użyj linku z maila potwierdzającego aktywację konta.
EOF

Mail.deliver do
  to 'subskrybenci@mailinator.com'
  bcc recipients.map(&:address)
  from "2lo.niejest.be"
  body mail_body
  subject "Zastępstwa (#{Time.zone.now.tomorrow.strftime('%d.%m')})"
end

replacement && replacement.mark_as_sent
drawn_number && drawn_number.mark_as_sent

if %w(development test).include? ENV['RACK_ENV']

  puts "Wysłane maile:"
  require "pp"
  Mail::TestMailer.deliveries.each do |mail|
    puts "=============================================="
    pp mail
    pp mail.body
  end

end
