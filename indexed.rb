#!/usr/bin/ruby
# coding: utf-8
require 'sqlite3'
require 'cgi'
require 'kconv'
print "Content-type: text/html\n\n"
num = 0
t_num = 0
d = Time.now
# 仮パーソナルデータ
sleep_st = '23:00'
sleep_et = '08:00'

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

def chday(day)
  day = '0' + day.to_s if day.to_s.length == 1
  day
end
today = d.year.to_s + '-' + chday(d.month).to_s + '-' + chday(d.day).to_s
def chint(s_data)
  idata = s_data.split('-')
  idata[0].to_s + idata[1].to_s + idata[2].to_s
end

def count(f_name)
  txt = open(f_name, 'r:utf-8')
  t_count = txt.read.count("\n")
  t_count.to_i
end

def print_t(f_name)
  txt = File.open(f_name, 'r:utf-8').readlines
  for i in 0..count(f_name) - 1
    print txt[i].to_s
  end
end

def nextday(today)
  day = today.split('-')
  if day[0] % 4 == 0 && day[0] % 100 == 0 && day[0] % 400 == 0
    # うるうどし
    month = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  else
    month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  end
  mm = day[1].to_i
  if day[2].to_i < month[mm - 1].to_i
    dd = day[2].to_i + 1
    return day[0].to_s + '-' + chday(day[1]).to_s + '-' + chday(dd).to_s
  else
    mm = day[1].to_i + 1
    return day[0].to_s + '-' + chday(mm).to_s + '-01'
  end
  end

db = SQLite3::Database.new('scheduler.db')
db.results_as_hash = true
t_num = 0
db.execute('select * from task') do |_row|
  t_num += 1
end

sql = 'select * from schedule order by s_day asc, s_time asc'
num = 0
db.execute(sql) do |_row|
  num += 1
end
title = Array.new(num)
id = Array.new(num)
s_day = Array.new(num)
e_day = Array.new(num)
s_time = Array.new(num)
e_time = Array.new(num)
st = Array.new(num)
i = 0
db.execute(sql) do |row|
  id[i] = row['id'].to_s.toutf8
  title[i] = row['title'].to_s.toutf8
  s_day[i] = row['s_day'].to_s.toutf8
  e_day[i] = row['e_day'].to_s.toutf8
  s_time[i] = row['s_time'].to_s.toutf8
  e_time[i] = row['e_time'].to_s.toutf8
  st[i] = row['st'].to_s.toutf8
  i += 1
end
print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
print '<html xmlns="http://www.w3.org/1999/xhtml" lang="ja">'
print '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
print '<head><title>Scheduler</title>'
print_t('js1.txt')
# タスクt_
t_title = Array.new(t_num)
t_id = Array.new(t_num)
te_day = Array.new(t_num)
te_time = Array.new(t_num)
tt_time = Array.new(t_num)
t_time = Array.new(t_num)
ti = Array.new(t_num)
about = Array.new(t_num)
l_time = Array.new(t_num)
j = 0
db.execute('select * from task order by e_day asc, e_time  asc, importance asc') do |row|
  t_id[j] = row['id'].to_s.toutf8
  t_title[j] = row['title'].to_s.toutf8
  te_day[j] = row['e_day'].to_s.toutf8
  tt_time[j] = row['t_time'].to_s.toutf8
  te_time[j] = row['e_time'].to_s.toutf8
  about[j] = row['about'].to_s.toutf8
  ti[j] = row['importance'].to_s.toutf8
  t_time[j] = row['time'].to_s.toutf8
  l_time[j] = row['located'].to_s.toutf8
  j += 1
end
j = 0
i = 0
endday = today
today = nextday(today)
for n in 0..13
  # 14日間
  endday = nextday(endday)
end

while i < num - 1
  if chint(s_day[i].to_s).to_i - chint(today.to_s).to_i >= 0
    break
  else
    i += 1
  end
end
while j < t_num && i < num && endday != today
  if today != s_day[i] && chint(today).to_i - chint(s_day[i]).to_i < 0
    # 指定日に予定が何もない時
    if to_min(tt_time[j]).to_i - (to_min(t_time[j]).to_i + to_min(l_time[j]).to_i).to_i == 0
      # タスクの残り作業時間が０のとき
      db.execute('update task set importance = ? where id=?', '0', t_id[j])
      j += 1
    elsif to_min(tt_time[j].to_s).to_i - (to_min(t_time[j]).to_i + to_min(l_time[j]).to_i).to_i <= to_min('02:00')
      # ２時間以下は作業全部やる
      tasktime = to_h(to_min(tt_time[j]).to_i - (to_min(t_time[j]).to_i + to_min(l_time[j]).to_i))
      endtime = to_h(to_min('10:00').to_i + to_min(tasktime).to_i)
      db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st) values(?, ?, ?, ?, ?, ?)', t_title[j], today, '10:00', today, endtime, t_id[j])
      db.execute('update task set located = ? where id=?', to_h(to_min(l_time[j]).to_i + to_min(tasktime)), t_id[j])
      j += 1
      today = nextday(today)
    else
      # ２時間以上タスクが有る
      db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st) values(?, ?, ?, ?, ?, ?)', t_title[j], today, '10:00', today, '12:00', t_id[j])
      locatedtime = to_h(to_min(l_time[j]).to_i + to_min('02:00').to_i)
      db.execute('update task set located = ? where id=?', locatedtime.to_s, t_id[j])
      l_time[j] = locatedtime
      # j += 1
      today = nextday(today)
    end
  elsif today != s_day[i] && chint(today).to_i - chint(s_day[i]).to_i > 0
    # 同日にタスクが２個以上あった場合、todayが先に行っているのでそれを止める
    i += 1
  else
    #p "bbb"
    # 何か予定がある日
    if st[i] != 's'
      # その予定がタスクの場合
      db.execute('select * from task where id=?', st[i]) do |row|
        $ex_eday = row[3]
        $ex_etime = row[4]
        $ex_star = row[7]
        $ex_time = row[8]
        $ex_located = row[9]
      end
      if chint($ex_eday).to_i - chint(te_day[j]).to_i > 0
        db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st) values(?, ?, ?, ?, ?, ?)', t_title[j], today, s_time[i], today, e_time[i], t_id[j])
        db.execute('delete from schedule where id=?', id[i])
        db.execute('update task set located = ? where id=?', to_h(to_min($ex_located).to_i - (to_min(e_time[i]).to_i - to_min(s_time[i]))), st[i])
      end
    else
      if e_day[i] == s_day[i + 1]
        # 次の予定も同じ日の場合
        if to_min(s_time[i + 1]).to_i - to_min(e_time[i]).to_i > to_min('04:00')
          # 4:00以上空きがある場合
          stime = to_h(to_min(e_time[i]).to_i + to_min('01:00').to_i)
          etime = to_h(to_min(s_time[i + 1]).to_i - to_min('01:00').to_i)
          ttime = to_h(to_min(etime).to_i - to_min(stime).to_i)
          #p ttime
          db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st) values(?, ?, ?, ?, ?, ?)', t_title[j], today, stime, today, etime, t_id[j])
          db.execute('update task set located = ? where id=?', to_h(to_min(l_time[j]).to_i + to_min(ttime).to_i), t_id[j])
          l_time[j]= to_h(to_min(l_time[j]).to_i+to_min(ttime).to_i)
        else
        end
      end
    end
    today = nextday(today)
    i += 1
  end
end

sql = 'select * from schedule order by s_day asc, s_time asc'
num = 0
db.execute(sql) do |_row|
  num += 1
end
title = Array.new(num)
id = Array.new(num)
s_day = Array.new(num)
e_day = Array.new(num)
s_time = Array.new(num)
e_time = Array.new(num)
st = Array.new(num)
com = Array.new(num)
i = 0
db.execute(sql) do |row|
  id[i] = row['id'].to_s.toutf8
  title[i] = row['title'].to_s.toutf8
  s_day[i] = row['s_day'].to_s.toutf8
  e_day[i] = row['e_day'].to_s.toutf8
  s_time[i] = row['s_time'].to_s.toutf8
  e_time[i] = row['e_time'].to_s.toutf8
  st[i] = row['st'].to_s.toutf8
  com[i] = row['completed'].to_s.toutf8
  i += 1
  # p i, id[i], title[i]
end
for i in 0..num - 1
  if i != 0
    print ','
    print "\n"
  end
  print "{\n"
  print "title: '" + title[i].to_s + "',\n"
  print "id: '" + id[i].to_s + "',\n"
  if s_time[i] == '00:00' && e_time == '24:00'
    print " start: '" + s_day[i].to_s + "'"
    print ",\n"
    print " end: \'" + e_day[i].to_s + "\'\n"
    print '}'
  else
    print " start: '" + s_day[i].to_s + 'T' + s_time[i].to_s + ":00'"
    print ",\n"
    print " end: '" + e_day[i].to_s + 'T' + e_time[i].to_s + ":00'"

    if st[i].to_s == 's'
      print "\n"
    elsif st[i].to_s != 's' && com[i].to_s == '1'
      print ",\n"
      print "color: 'grey'\n"
    else st[i].to_s != 's' && com[i].to_s == ''
         print ",\n"
         print "color: '#cd5c5c'\n"
     end
    print '}'
 end
  i += 1
end
print_t('js2.txt')
print '</head>'
print '<body>'
print_t('body1.txt')
print "<a href=\"/cgi-bin/cal/in_task.rb\" alt=\"タスクの入力\">タスクの新規作成</a></div>\n"
print "<b>||| Task</b><div class='box-lid-menulist'>\n"
print "<FORM name=\"form1\" action=\"edit_task.rb\" onSubmit=\"return false\">\n"
print "<INPUT type=\"hidden\" name=\"taskid\" value=\""
print "\">"
for i in 0..t_num - 1.to_i
  print "<INPUT type=\"radio\" onClick=\"mySubmit('"
  print t_id[i]
  print "')\"> "
  print '<b>' if ti[i] == '3'
  print t_title[i]
  print '</b>' if ti[i] == '3'
  print ' ('
  print to_h(to_min(tt_time[i]).to_i - to_min(t_time[i]).to_i)
  print ')'
  print "</br>\n"
  print '<div class=\'box-lid-menu-postscript\'>〆 '
  print te_day[i]
  print ', '
  print te_time[i]
  print '<br>'
  print about[i]
  print "</div>\n"
end
print "<div id = \"buttom\" align=\"right\" style=\"clear:both;\"></div>\n"
print ' </form></div> '
db.close
print_t('body2.txt')
print '</body></html>'
