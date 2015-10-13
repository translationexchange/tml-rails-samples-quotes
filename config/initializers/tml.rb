Tml.configure do |config|

  if Rails.env.production?
    config.application = {
      host: 'https://api.translationexchange.com',
      key: 'a7d4a6b119d2016743aa3b9c9336f0c7b717733d3f2a173db5011a43a6a27a28',
      token: '856f9db4ed172e45f7b6d377aa30b4583a358b6ede517e51e514eb176152c28c'
    }

    config.cache = {
      enabled: false,
      adapter: 'memcache',
      host: 'tememcached.yptuob.cfg.usw1.cache.amazonaws.com:11211',
      namespace: '856f9db4ed172e45f7b6d377aa30b4583a358b6ede517e51e514eb176152c28c'
    }
  else
    config.application = {
      host: 'http://localhost:3000',
      key: '4668488ca90498b71b1d98ee6a193eb618e6bd75b0388714254fc6689ac38990',
      token: '971bb4c54c86ffeea987678e1861e5e8499da76f07f9faf4931da45b973ce03a'
    }

    config.cache = {
      enabled:   true,
      adapter:   'memcache',
      host:      'localhost:11211',
      namespace: '4668488ca90498b71b1d98ee6a193eb618e6bd75b0388714254fc6689ac38990'
    }
  end

  config.logger  = {
    :enabled  => true,
    :path     => "#{Rails.root}/log/tml.log",
    :level    => 'debug'
  }

end