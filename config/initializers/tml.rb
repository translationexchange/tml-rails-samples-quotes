Tml.configure do |config|

  if Rails.env.production?
    config.application = {
        :token => '856f9db4ed172e45f7b6d377aa30b4583a358b6ede517e51e514eb176152c28c'
    }

    config.cache = {
        :enabled      => false,
        :adapter      => 'memcache',
        :host         => 'tememcached.yptuob.cfg.usw1.cache.amazonaws.com:11211',
        :namespace    => '856f9db4ed172e45f7b6d377aa30b4583a358b6ede517e51e514eb176152c28c'
    }
  else
    config.application = {
        :host => 'http://localhost:3000',
        :token => '46a15acfc4987368a097e12cc883d8e76bd35fa97c5ebe8bcba7739927e0da37'
    }

    config.cache = {
        :enabled      => false,
        :adapter      => 'memcache',
        :host         => 'localhost:11211',
        :namespace    => '46a15acfc4987368a097e12cc883d8e76bd35fa97c5ebe8bcba7739927e0da37'
    }
  end

  config.logger  = {
      :enabled  => false,
      :path     => "#{Rails.root}/log/tml.log",
      :level    => 'debug'
  }

end