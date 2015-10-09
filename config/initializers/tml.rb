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
      token: '004df551a2484696b9a7b8612e466db942bc253e6e677fe306a37ae0e951f9e8'
    }

    config.cache = {
      enabled:   true,
      adapter:   'memcache',
      host:      'localhost:11211',
      namespace: '6cd9e826957f6aafb920fc7394dbeab5d9e4833cc8e3f3dfc2ab66ce36ce6652'
    }
  end

  config.logger  = {
    :enabled  => true,
    :path     => "#{Rails.root}/log/tml.log",
    :level    => 'debug'
  }

end