namespace :quotes do


  # bundle exec rake tml:export quotes quote author  ---- filtering params
  # bundle exec rake tml:import quotes quote author  ---- last sync date, locales


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
                     label: quote.author,
                     locale: 'en',
                     id: "/quotes/#{quote.id}/author"
                 }, {
                     label: quote.quote,
                     locale: 'en',
                     id: "/quotes/#{quote.id}/quote"
                 }]
      }

      # if author data is present submit it as well
      unless quote.authordata.blank?
        quote_attributes[:keys] << {
            label: quote.authordata,
            locale: 'en',
            id: "/quotes/#{quote.id}/authordata"
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

    interval_start = Date.today - 100.days
    interval_end = Date.today - 20.days

    # paginate through results
    params = {since: interval_start, locales: ['ru'], source: 'quotes', machine: true}
    # params = {
      # since: interval_start, until: interval_end, locales: ['zh-CN'], source: 'tags', translators: '1,2,3,4',
      # machine: true
      # purchase: true,
    # }

    # paginate through results
    data = fetch_translations(params)

    pp data

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

      data = fetch_translations(params, data['pagination']['current_page'] + 1)
    end

    pp "Total imported #{imported} translations..."
  end

  private

  # Initializes TML library
  def init_tml
    # Tml.session.init(
    #     key: '6cd9e826957f6aafb920fc7394dbeab5d9e4833cc8e3f3dfc2ab66ce36ce6652',
    #     token: '2ae0094a9844e5f2757cb7f1617831051651b36a8029d41f7c477d4d917a2063'
    # )
    Tml.session.init(
        key: 'b8afb48f57d37187479ed2c07f780378b32221e011d851c7ed1b2ec9cbc0d095',
        token: '38e8dca6d96f79d27afc58568d50b8bb7f03eff7a8ed7a9f3b87d6755d8e6aa3',
        host: 'http://localhost:3000'
    )
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
    Tml.session.with_block_options(:live => true) do
      Tml.session.application.api_client.post(
          'sources/register_keys', {
                                     :source_keys => buffer.to_json,
                                     :options => options.to_json
                                 }
      )
    end
  end

  # Fetches translations from Translation Exchange
  def fetch_translations(params, page = 1)
    JSON.parse(
        Tml.session.application.api_client.get(
            'sources/sync_translations', params.merge(page: page), {raw: true}
        )
    )
  end

end
