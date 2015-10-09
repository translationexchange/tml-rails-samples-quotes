namespace :quotes do

  desc 'Exports quotes to the system'
  task :export => :environment do
    buffer = []

    Tml.session.init

    options = {
      batch: true
    }

    index = 0
    Quote.find_each do |quote|
      # pp "#{index}. #{quote.quote}"
      index += 1

      buffer << {
        :source => "/quotes/#{quote.id}",
        :keys => [{
          :label => quote.author,
          :locale => 'en'
        }, {
          :label => quote.quote,
          :locale => 'en'
        }]
      }

      if index % 100 == 0
        pp "Submitting #{index-0}-#{index} sources..."
        Tml.session.application.api_client.post('sources/register_keys', {:source_keys => buffer.to_json, :options => options.to_json})
        buffer = []
      end
    end

    if buffer.size > 0
      Tml.session.application.api_client.post('sources/register_keys', {:source_keys => buffer.to_json, :options => options.to_json})
    end
  end

  desc 'Imports quotes into the system'
  task :import => :environment do
    Tml.session.init

    data = Tml.session.application.api_client.post('sources/sync_translations', {:since => Time.now - 10.days, :locales => ['ru']})
    pp data

  end

end
