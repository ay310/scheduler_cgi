#!/usr/bin/ruby
# coding: utf-8
require "cgi"
data = CGI.new
print "Content-type: text/html\n\n"

s_day= data["s_day"].to_s
s_time= data["s_time"].to_s
e_day= data["e_day"].to_s
e_time= data["e_time"].to_s
content= data["content"].to_s

if s_time ==nil && e_time == nil then
   File.open('201509.txt', 'a:utf-8')do |file|
   file.puts(s_day+','+e_day+','+content+',00:00:00,00:00:00')
   end
 else

   File.open('201509.txt',  'a:utf-8')do |file|
   file.puts(s_day+','+e_day+','+content+','+s_time+':00,'+e_time+':00')
   end
end


js1_lines = File.open('js1.txt', "r:utf-8").readlines
js1 = open('js1.txt', "r:utf-8")
js1_count = js1.read.count("\n")

js2_lines = File.open('js2.txt', "r:utf-8").readlines
js2 = open('js2.txt', "r:utf-8")
js2_count = js2.read.count("\n")

sche_lines = File.open('201509.txt', "r:utf-8").readlines
sche = open('201509.txt', "r:utf-8")
sche_count = sche.read.count("\n")

body_lines = File.open('body.txt', "r:utf-8").readlines
body = open('body.txt', "r:utf-8")
body_count = body.read.count("\n")

fh = open('/Library/WebServer/Documents/cal/top.html', 'w')
  fh.printf('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">');
  fh.printf('<html xmlns="http://www.w3.org/1999/xhtml">');
  fh.printf('<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />');
    fh.printf('<head>');
     fh.printf('<title>Scheduler</title>');

     for i in 0..js1_count-1
       fh.printf('%s', js1_lines[i].to_s);
     end

  for i in 0..sche_count-1
      if i!= 0 then
       fh.printf(",");
      end
    hoge = sche_lines[i].to_s.split(',')
      fh.printf('{');
      fh.printf("title: '%s',", hoge[2].to_s);


      if hoge[1].to_s==hoge[0].to_s then
       if hoge[3].chomp=='00:00:00' && hoge[4].chomp=='24:00:00' || (hoge[3]==nil && hoge[4]==nil) then
        #同じ日付内で終日予定
        fh.printf(" start: '%s'",hoge[0].to_s);
        fh.printf("}");
        else
          #同じ日付内で時刻指定
          fh.printf(" start: '%sT%s'", hoge[0].to_s, hoge[3].to_s);
          fh.printf(",");
          fh.printf(" end: '%sT%s'", hoge[1].to_s, hoge[4].to_s.chomp);
          fh.printf("}");
        end
      else
        if ( hoge[3]=='00:00:00' && hoge[4]=='24:00:00' ) || (hoge[3]==nil && hoge[4]==nil) then
         #違う日付で終日予定
         fh.printf(" start: '%s', ", hoge[0].to_s);
         fh.printf(" end: '%s'}", hoge[1].to_s.chomp);
         else
           #違う日付内で時刻指定
           fh.printf(" start: '%sT%s', ", hoge[0].to_s, hoge[3].to_s);
           fh.printf(" end: '%sT%s'}", hoge[1].to_s, hoge[4].to_s.chomp);
         end #if hoge[3].chomp=='00:00:00' && hoge[4].chomp=='24:00:00'
       end #hoge[1].to_s==hoge[0].to_s then
  end #  for i in 0..sche_count-1

     for i in 0..js2_count-1
      fh.printf('%s', js2_lines[i].to_s);
     end

    fh.printf('</head>');
    fh.printf('<body>');
    for j in 0..body_count-1
      fh.printf('%s', body_lines[j].to_s);
    end
    fh.printf('</body></html>');
  fh.close

  print '<html>\n'
  print '<head><META http-equiv="refresh"; content="0; URL=/cal/top.html"></head><body>rb</body></html>'
