namespace :quotes do

  desc 'Exports quotes to Translation Exchange'
  task :export => :environment do
    init_tml

    buffer = []
    buffer_size = 50

    # if you don't need to get the response data to store for reference
    # then this can be set to false
    options = {
      realtime: false
    }

    index = 0
    Quote.find_each do |quote|
      index += 1

      # Quotes consist of 3 parts that need translations: quote, author, authordata
      quote_attributes = {
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

      # if author data is present submit it as well
      unless quote.authordata.blank?
        quote_attributes[:keys] << {
          label:  quote.authordata,
          locale: 'en',
          id:     "/quotes/#{quote.id}/authordata"
        }
      end

      buffer << quote_attributes

      if index % buffer_size == 0
        pp "Submitting #{index-0}-#{index} sources..."
        register_keys(buffer, options)
        buffer = []
      end
    end

    if buffer.size > 0
      register_keys(buffer, options)
    end
  end

  desc 'Imports quotes translations from Translation Exchange'
  task :import => :environment do
    init_tml

    # paginate through results
    data = fetch_translations(Time.now - 1.day, ['ru'])

    imported = 0
    while data['pagination']['current_page'] <= data['pagination']['total_pages']
      data['results'].each do |element|
        # the translation key may belong to more than one source
        element['sources'].each do |source|
          next unless source.match(/\/quotes\/\d*/)
          parts = source.split('/')
          quote = Quote.find_by_id(parts[2])
          next unless quote

          Globalize.with_locale(element['translation']['locale']) do
            pp "Importing quote(#{quote.id}) #{parts.last} translation..."
            quote.update_attributes(parts.last => element['translation']['label'])
            imported += 1
          end
        end
      end

      data = fetch_translations(Time.now - 1.day, ['ru'], data['pagination']['current_page'] + 1)
    end

    pp "Total imported #{imported} translations..."
  end

private

  # Initializes TML library
  def init_tml
    Tml.session.init({
      key: 'f7d329c5a48db5f4f2e80b5ca02d7bda3a8b8cceb909c8a053fa7353e159b97f',
      token: '11bd807945dc6d0bfc678ef5b86025118485dfc8c60f92605b998a5657a0343e'
    })
  end

  # Registers keys on Translation Exchange
  # Response data can be stored for reference:
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

  # Fetches translations from Translation Exchange
  def fetch_translations(since, locales, page = 1)
    JSON.parse(Tml.session.application.api_client.get(
        'sources/sync_translations', {
          :since => since,
          :locales => locales,
          :page => page
        }, {raw: true}
      )
    )
  end
end
