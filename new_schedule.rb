#!/usr/bin/ruby
# coding: utf-8
require "cgi"
require 'sqlite3'
data = CGI.new
print "Content-type: text/html\n\n"
inputday = data["inputday"].to_s

def count(f_name)
  txt = open('../'+f_name, 'r:utf-8')
  t_count = txt.read.count("\n")
  t_count.to_i
end

def print_t(f_name)
  txt = File.open("../"+f_name, 'r:utf-8').readlines
  for i in 0..count(f_name) - 1
    print txt[i].to_s
  end
end

def to_min(time)
  if time == '00:00'
    return 0
  else
    arytime = time.split(':')
    return arytime[0].to_i * 60 + arytime[1].to_i
  end
end

def to_h(min)
  hour = min.to_i / 60
  min = min.to_i % 60
  hour = '0' + hour.to_s if hour < 10
  min = '0' + min.to_s if min < 10
  hour.to_s + ':' + min.to_s
end

def sepalate_d(day)
dt = day.split("T")
return dt[0]
end
def sepalate_t(day)
dt = day.split('T')
st=dt[1].split(':')
stime=st[0].to_s+":"+st[1].to_s
return stime
end
def decide_et(st)
  et=to_min(st) +120
  return to_h(et).to_s
end
st="10:00"
et="12:00"
if inputday.length>=12
  day=sepalate_d(inputday)
  st=sepalate_t(inputday)
else
day==inputday
end

et=decide_et(st).to_s

db = SQLite3::Database.new('scheduler.db')
db.results_as_hash = true
print_t("new_schedule.txt")
print "<form action=\"add_schedule.rb\" method=\"post\">"
print "<input type=\"hidden\" name=\"s_day\" value=\""
print day
print "\">"
print '<p>定形スケジュール：'
print '<select name="s_title" onChange="this.form.submit()">'
num=0
db.execute('select * from defalt_s') do |row|
  num += 1
end
name = Array.new(num)
i=0
print "<option value=\"\" selected>選択する</option>"
db.execute('select * from defalt_s') do |row|
  name[i] = row[1]
  print "<option value=\"#{name[i].to_s.chomp}\" onClick=\"mySubmit('#{name[i].to_s.chomp}')\">#{name[i].to_s.chomp}</option>"
  i += 1
end
print "<option value=\"no_name\" onClick=\"\">----------</option>"
print "<option value=\"no_name\"onClick=\"mySubmit('no_name')\"><font color=\"red\">新規作成</font></option></select></p>"
print "</form>"
print "<form action=\"add_schedule.rb\" method=\"post\">"
print "<label>件名：</label>"
print "<input type=\"text\" name=\"content\" style=\"width: 60%; height: 1.5em;\" value=\"content\">"
print "<br>"
print "<label>開始：</label>"
print "<input id=\"s_day\" type=\"text\" name=\"s_day\">"
print "<input id=\"s_time\" type=\"text\" name=\"s_time\">"
print "<br><label>終了：</label>"
print "<input id=\"e_day\" type=\"text\" name=\"e_day\">"
print "<input id=\"e_time\" type=\"text\" name=\"e_time\">"
print '<p><label>カテゴリ：</label>'
print '<select name="category">'
num=0
db.execute('select * from category where s=?', "1") do |row|
  num += 1
end
c_name = Array.new(num)
i=0
db.execute('select * from category where s=?', "1") do |row|
  c_name[i] = row[0]
  print "<option value=\"#{c_name[i].to_s.chomp}\">#{c_name[i].to_s.chomp}</option>"
  i += 1
end
print "<option value=\"no_name\">新規作成</option></select></p>"
print "<p><input type=\"submit\" value=\"送信\"  onclick=\"window.close()\" class=\"btn\"></p>"
print "</form><br>"
print "</div></div></div></body>"
print_t("new_schedule4.txt")
print "$('#s_time').datetimepicker({" +"\n"
print "	datepicker:false," +"\n"
print "	format:'H:i'," +"\n"
print "	value:'"
print st
print "',"
print "	step:5" +"\n"
print "});" +"\n"
print "$('#s_day').datetimepicker({" +"\n"
print "	lang:'jp'," +"\n"
print "	timepicker:false," +"\n"
print "	value:'"
print day.to_s.chomp
print "',"
print "	format:'Y-m-d'," +"\n"
print "	formatDate:'Y/m/d'," +"\n"
print "});" +"\n"
print "$('#e_time').datetimepicker({" +"\n"
print "	datepicker:false," +"\n"
print "	format:'H:i'," +"\n"
print "	value:'"
print et
print "',"
print "	step:5" +"\n"
print "});" +"\n"
print "$('#e_day').datetimepicker({" +"\n"
print "	lang:'jp'," +"\n"
print "	timepicker:false," +"\n"
print "	value:'"
print day.to_s.chomp
print "',"
print "	format:'Y-m-d'," +"\n"
print "	formatDate:'Y/m/d'," +"\n"
print "});" +"\n"
print_t("new_schedule5.txt")
db.close
