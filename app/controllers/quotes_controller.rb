class QuotesController < ApplicationController

  def index
    @quotes = Quote.order('id asc')

    unless params[:author].blank?
      @author = Author.where(:id => params[:author]).first
      @quotes = @quotes.where(:author_id => @author.id) if @author
    end

    unless params[:search].blank?
      @quotes = @quotes.where('quote like ?', "%#{params[:search]}%")
    end

    @quotes = @quotes.page(page).per(per_page)
  end

  def show
    unless params[:id].blank?
      @quote = Quote.find_by_id(params[:id])
    end

    unless @quote
      return redirect_to(action: 'show', id: random_quote.id)
    end

    make_history(@quote.id)
  end

protected

  def reset_history
    session[:history] = []
  end

  def history
    session[:history] ||= []
  end

  def make_history(id)
    return if history.index(id)
    session[:history] << id
    if session[:history].size > 150
      session[:history].shift
    end
  end

  def history_index(id)
    history.index(id)
  end

  def previous_quote(id)
    index = history_index(id)
    return nil unless index
    return nil if index == 0
    @previous_quote_id ||= history[index - 1]
  end
  helper_method :previous_quote

  def next_quote(id)
    index = history_index(id)
    return nil unless index
    return nil if index == history.size - 1
    @next_quote_id ||= history[index + 1]
  end
  helper_method :next_quote

  def random_quote
    random = Quote
    random = random.where('id not in (?)', history) if history.any?
    random.order("RANDOM()").first
  end
  helper_method :random_quote

end
