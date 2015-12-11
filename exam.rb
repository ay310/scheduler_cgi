#!/usr/bin/ruby
# coding: utf-8
require 'sqlite3'
require 'cgi'
require 'kconv'
print "Content-type: text/html\n\n"
  d = Date.today

class Time
    def initialize(hh, mm, ss)
      @tt =(hh*60+mm)*60+ss
  end

def get_h
p @tt/3600
end
def get_m
  p (@tt%3600)/60
end
def get_s
  p @tt%60
end
  def tostring
    t_string=@tt/3600.to_s+":"+@mm.to_s+":"+@ss.to_s
    puts t_string
  end

end

    exam = Time.new(10, 20, 30)
    p "H:"
    exam.get_h
    p "M:"
        exam.get_m
    p "S:"
        exam.get_s
