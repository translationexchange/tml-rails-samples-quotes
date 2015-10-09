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
#++

namespace :code do
  desc 'Annotates models'
  task :annotate_models => :environment do
    root = "#{Rails.root}/app/models"
    files = Dir[File.expand_path("#{root}/**/**/**/*.rb")]

    files.sort.each do |file|
      class_name = file.to_s.gsub(root, '').gsub('.rb', '').camelcase
      klass = class_name.constantize

      next unless klass < ActiveRecord::Base

      lines = []
      copyright(lines)
      lines << "#-- #{class_name} Schema Information"
      lines << "#"
      lines << "# Table name: #{klass.table_name}"
      lines << "#"

      name_width = 0
      type_width = 0
      sql_type_width = 0

      klass.columns.each do |column|
        name_width = [column.name.to_s.length, name_width].max
        type_width = [column.type.to_s.length, type_width].max
        sql_type_width = [column.sql_type.to_s.length, sql_type_width].max
      end

      klass.columns.each do |column|
        line = ["#  "]
        line << column.name
        line << (" " * (name_width - column.name.length + 4))
        line << column.sql_type
        line << (" " * (sql_type_width - column.sql_type.to_s.length + 4))

        meta = []
        meta << "not null" if !column.null
        # meta << "primary key" if column.primary
        meta << "default = #{column.default.to_s}" if column.default
        line << meta.join(', ')

        lines << line.join('')
      end

      lines << "#"
      lines << "# Indexes"
      lines << "#"

      indexes = ActiveRecord::Base.connection.indexes(klass.table_name)

      name_width = 0

      indexes.each do |index|
        name_width = [index.name.to_s.length, name_width].max
      end

      indexes.each do |index|
        line = ["#  "]
        line << index.name
        line << (" " * (name_width - index.name.length + 4))
        line << "(#{index.columns.join(', ')})"
        line << " "
        line << "UNIQUE" if index.unique
        lines << line.join('')
      end

      lines << "#"
      lines << "#++"
      lines << ""

      pp "Updating #{file}..."

      model_file = File.open(file, "r+")
      old_lines = model_file.readlines
      model_file.close
      
      model_file = File.new(file, "w")
      lines.each do |line|
        model_file.write(line + "\r\n")
      end

      passed_comments = false
      passed_blanks = false

      old_lines.each do |line|
        passed_comments = true unless line.match(/^[\s#]/)
        next unless passed_comments

        passed_blanks = true if line.length > 0
        next unless passed_blanks

        model_file.write(line)
      end
      model_file.close      

    end
  end

  desc 'Annotates controllers'
  task :annotate_controllers => :environment do
    root = "#{Rails.root}/app/controllers"
    files = Dir[File.expand_path("#{root}/**/**/**/*.rb")]

    routes = {}
    path_length = 0
    verb_length = 0
    dest_length = 0

    Rails.application.routes.routes.each do |route|
      routes[route.defaults[:controller]] ||= []
      path = route.path.spec.to_s.gsub("(.:format)", '')
      verb = %W{ GET POST PUT PATCH DELETE }.grep(route.verb).first.downcase
      dest = "#{route.defaults[:action]}"

      path_length = path.length if path.length > path_length
      verb_length = verb.length if verb.length > verb_length
      dest_length = dest.length if dest.length > dest_length

      routes[route.defaults[:controller]] << {
          alias:        route.name,
          path:         path,
          controller:   route.defaults[:controller],
          action:       route.defaults[:action],
          destination:  dest,
          verb:         verb
      }
    end

    # pp routes.keys

    files.sort.each do |file|
      class_name = file.to_s.gsub(root, '').gsub('.rb', '').camelcase
      klass = class_name.constantize

      next unless klass < ::ApplicationController

      lines = []
      copyright(lines)
      lines << "#-- #{class_name} Routing Information"
      lines << "#"

      controller_name = class_name.underscore.gsub('_controller', '').gsub(/^\//, '')
      controller_routes = (routes[controller_name] || []).uniq

      controller_routes.each do |route|
        line = ['#  ']
        line << route[:verb]
        line << ' ' * (verb_length + 4 - route[:verb].to_s.length)
        line << route[:path]
        line << ' ' * (path_length + 4 - route[:path].to_s.length)
        line << ' => '
        line << route[:destination]
        lines << line.join('')
      end

      lines << "#"
      lines << "#++"
      lines << ''

      pp "Updating #{file}..."

      model_file = File.open(file, 'r+')
      old_lines = model_file.readlines
      model_file.close

      model_file = File.new(file, 'w')
      lines.each do |line|
        model_file.write(line + "\r\n")
      end

      passed_comments = false
      passed_blanks = false

      old_lines.each do |line|
        passed_comments = true unless line.match(/^[\s#]/)
        next unless passed_comments

        passed_blanks = true if line.length > 0
        next unless passed_blanks

        model_file.write(line)
      end
      model_file.close
    end
  end

private

  def copyright(lines)
    lines << "#--"
    lines << "# Copyright (c) 2015 Translation Exchange, Inc."
    lines << "#"
    lines << "#"
    lines << "#  _______                  _       _   _             ______          _"
    lines << "# |__   __|                | |     | | (_)           |  ____|        | |"
    lines << "#    | |_ __ __ _ _ __  ___| | __ _| |_ _  ___  _ __ | |__  __  _____| |__   __ _ _ __   __ _  ___"
    lines << "#    | | '__/ _` | '_ \\/ __| |/ _` | __| |/ _ \\| '_ \\|  __| \\ \\/ / __| '_ \\ / _` | '_ \\ / _` |/ _ \\"
    lines << "#    | | | | (_| | | | \\__ \\ | (_| | |_| | (_) | | | | |____ >  < (__| | | | (_| | | | | (_| |  __/"
    lines << "#    |_|_|  \\__,_|_| |_|___/_|\\__,_|\\__|_|\\___/|_| |_|______/_/\\_\\___|_| |_|\\__,_|_| |_|\\__, |\\___|"
    lines << "#                                                                                        __/ |"
    lines << "#                                                                                       |___/"
    lines << "#"
    lines << "# Permission is hereby granted, free of charge, to any person obtaining"
    lines << "# a copy of this software and associated documentation files (the"
    lines << "# \"Software\"), to deal in the Software without restriction, including"
    lines << "# without limitation the rights to use, copy, modify, merge, publish,"
    lines << "# distribute, sublicense, and/or sell copies of the Software, and to"
    lines << "# permit persons to whom the Software is furnished to do so, subject to"
    lines << "# the following conditions:"
    lines << "#"
    lines << "# The above copyright notice and this permission notice shall be"
    lines << "# included in all copies or substantial portions of the Software."
    lines << "#"
    lines << "# THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,"
    lines << "# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF"
    lines << "# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND"
    lines << "# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE"
    lines << "# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION"
    lines << "# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION"
    lines << "# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    lines << "#"
  end

end