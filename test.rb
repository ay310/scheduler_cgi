#!/usr/bin/ruby
# coding: utf-8
require 'cgi'
require 'date'
require 'sqlite3'
require 'kconv'
data = CGI.new
print "Content-type: text/html\n\n"

title="テスト１"
sd="2015-11-16"
st="10:00"
ed="2015-11-16"
et="12:00"
category="未設定"
i=0
db = SQLite3::Database.new('scheduler.db')
db.results_as_hash = true
    #  db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, category) values(?, ?, ?, ?, ?, ?, ?)', title, sd, st, ed, et, 's', category)
      db.execute('select * from category') do |row|
        puts row[0]
        i += 1
      end
  db.close

#print '<html>'
#print '<head><META http-equiv="refresh"; content="0; URL=index.rb"></head><body></body></html>'
