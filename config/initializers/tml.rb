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
      key: '6cd9e826957f6aafb920fc7394dbeab5d9e4833cc8e3f3dfc2ab66ce36ce6652',
      token: '2ae0094a9844e5f2757cb7f1617831051651b36a8029d41f7c477d4d917a2063'
    }

    config.cache = {
      enabled:   false,
      adapter:   'memcache',
      host:      'localhost:11211',
      namespace: '6cd9e826957f6aafb920fc7394dbeab5d9e4833cc8e3f3dfc2ab66ce36ce6652'
    }
  end

  config.agent = {
      enabled:  true,
      type:     'agent',
      host:     'http://localhost:8282/dist/agent.js'
  }

  config.logger  = {
    :enabled  => true,
    :path     => "#{Rails.root}/log/tml.log",
    :level    => 'debug'
  }

end