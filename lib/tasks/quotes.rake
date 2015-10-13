namespace :quotes do

  desc 'Exports quotes to the system'
  task :export => :environment do
    buffer = []
    buffer_size = 50

    Tml.session.init

    options = {
      realtime: true
    }

    index = 0
    Quote.find_each do |quote|
      index += 1

      buffer << {
        source: {
          name: "Quote #{quote.id}",
          id: "/quotes/#{quote.id}"
        },
        keys: [{
          label:  quote.author,
          locale: 'en',
          id:     "/quotes/#{quote.id}/author"
        }, {
          label:  quote.quote,
          locale: 'en',
          id:     "/quotes/#{quote.id}/quote"
        }]
      }

      if index % buffer_size == 0
        pp "Submitting #{index-0}-#{index} sources..."
        pp register_keys(buffer, options)
        buffer = []
      end
    end

    if buffer.size > 0
      register_keys(buffer, options)
    end
  end

  desc 'Imports quotes into the system'
  task :import => :environment do
    Tml.session.init

    data = Tml.session.application.api_client.get('sources/sync_translations', {:since => Time.now - 10.days, :locales => ['ru']})
    pp data
  end

private


  # Response:
  # {
  #   :source => {
  #     :id => "/quotes/#{quote.id}",
  #     :key => "dsklfsadfjaslkdjfalksjdflaksjdf"
  #   },
  #   :keys => [{
  #     :id     => "/quotes/#{quote.id}/author",
  #     :key    => "sadlfkjasdljfkalskdjflaksjdflkajdfl"
  #   }, {
  #     :id     => "/quotes/#{quote.id}/quote",
  #     :key    => "sadlfkjasdljfkalskdjflaksjdflkajdfl"
  #   }]
  # }
  def register_keys(buffer, options)
    Tml.session.application.api_client.post(
      'sources/register_keys', {
        :source_keys => buffer.to_json,
        :options => options.to_json
      }
    )
  end

end
