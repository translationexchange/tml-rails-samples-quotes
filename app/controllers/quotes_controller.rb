#--
# Copyright (c) 2015 Translation Exchange, Inc.
#
#
#  _______                  _       _   _             ______          _
# |__   __|                | |     | | (_)           |  ____|        | |
#    | |_ __ __ _ _ __  ___| | __ _| |_ _  ___  _ __ | |__  __  _____| |__   __ _ _ __   __ _  ___
#    | | '__/ _` | '_ \/ __| |/ _` | __| |/ _ \| '_ \|  __| \ \/ / __| '_ \ / _` | '_ \ / _` |/ _ \
#    | | | | (_| | | | \__ \ | (_| | |_| | (_) | | | | |____ >  < (__| | | | (_| | | | | (_| |  __/
#    |_|_|  \__,_|_| |_|___/_|\__,_|\__|_|\___/|_| |_|______/_/\_\___|_| |_|\__,_|_| |_|\__, |\___|
#                                                                                        __/ |
#                                                                                       |___/
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
#-- ::QuotesController Routing Information
#
#  get    /                          => show
#  get    /quotes                    => index
#  get    /quotes/:id                => show
#
#++

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
