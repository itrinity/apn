module APN
  class Railtie < Rails::Railtie
    initializer "apn.setup" do |app|

      APN.root = Rails.root
      if Rails.env.development?
        #APN.certificate_name =  "apn_development.pem"
        #APN.host =  "gateway.sandbox.push.apple.com"
      end

    end
  end
end