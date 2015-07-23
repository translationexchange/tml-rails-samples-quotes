Tml.configure do |config|
  config.application = {
      :host => 'http://localhost:3000',
      :token => '46a15acfc4987368a097e12cc883d8e76bd35fa97c5ebe8bcba7739927e0da37'
  }

  config.cache = {
      :enabled      => false,
      :adapter      => 'memcache',
      :host         => 'localhost:11211',
      :namespace    => 'quotes'
  }

  config.logger  = {
      :enabled  => true,
      :path     => "#{Rails.root}/log/tml.log",
      :level    => 'debug'
  }
end