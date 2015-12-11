#!/usr/bin/ruby
# coding: utf-8
require 'sqlite3'
require 'cgi'
require 'kconv'
print "Content-type: text/html\n\n"
d = Time.now

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

class Locate_events
  def initialize(today, inputdays)
    @today = today
    @inputdays = inputdays
  end

  def read_task
    db = SQLite3::Database.new('scheduler.db')
    db.results_as_hash = true
    # データベースから
    # タスクの読み込み
    @t_num = 0
    db.execute('select * from task') do |_row|
      @t_num += 1
    end
    @t_id = Array.new(@t_num)
    @t_title = Array.new(@t_num)
    @te_day = Array.new(@t_num)
    @te_time = Array.new(@t_num)
    @tasktime = Array.new(@t_num)
    @c_tasktime = Array.new(@t_num)
    @t_imp = Array.new(@t_num)
    @t_about = Array.new(@t_num)
    @l_tasktime = Array.new(@t_num)
    j = 0
    db.execute('select * from task order by e_day asc, e_time  asc, importance asc') do |row|
      @t_id[j] = row['id'].to_s.toutf8
      @t_title[j] = row['title'].to_s.toutf8
      @te_day[j] = row['e_day'].to_s.toutf8
      @tasktime[j] = row['t_time'].to_s.toutf8
      @te_time[j] = row['e_time'].to_s.toutf8
      @t_about[j] = row['about'].to_s.toutf8
      @t_imp[j] = row['importance'].to_s.toutf8
      @c_tasktime[j] = row['time'].to_s.toutf8
      @l_tasktime[j] = row['located'].to_s.toutf8
      j += 1
    end
    db.close
  end

  def read_schedule
    db = SQLite3::Database.new('scheduler.db')
    db.results_as_hash = true
    # データベースから
    # スケジュールの読み込み
    @num = 0
    db.execute('select * from schedule order by s_day asc, s_time asc') do |_row|
      @num += 1
    end
    @title = Array.new(@num)
    @id = Array.new(@num)
    @s_day = Array.new(@num)
    @e_day = Array.new(@num)
    @s_time = Array.new(@num)
    @e_time = Array.new(@num)
    @st = Array.new(@num)
    @category = Array.new(@num)
    @com = Array.new(@num)
    i = 0
    db.execute('select * from schedule order by s_day asc, s_time asc') do |row|
      @id[i] = row['id'].to_s.toutf8
      @title[i] = row['title'].to_s.toutf8
      @s_day[i] = row['s_day'].to_s.toutf8
      @e_day[i] = row['e_day'].to_s.toutf8
      @s_time[i] = row['s_time'].to_s.toutf8
      @e_time[i] = row['e_time'].to_s.toutf8
      @st[i] = row['st'].to_s.toutf8
      @com[i] = row['completed']
      i += 1
    end
    db.close
  end

  def decide_sday(day)
    read_schedule
    i = 0
    while i < @num.to_i - 1
      if chint(@s_day[i].to_s).to_i - chint(day.to_s).to_i >= 0
        @num_i = i
        break
      else
        i += 1
      end
    end
    # p @num_i
  end

  def search_same(name, sd, st, ed, et)
    decide_sday(@today)
    overlap = 0
    for i in@num_i.to_i..@num.to_i - 1
      if @title[i] == name && @s_day[i] == sd && @s_time[i] == st && @e_day[i] == ed && @e_time[i] == et
        overlap = 1
        break
      end
    end
    overlap
  end

  def overlap_event(sd, ed, st, et)
    read_schedule
    decide_sday(sd)
    overlap = 0
    min = Array.new(1339, '0')
    if sd == ed
      for i in to_min(st).to_i..to_min(et).to_i
        min[i] = '1'
      end
    end
    for i in @num_i..@num - 1
      if @s_day[i] == sd
        for i in to_min(@s_time[i]).to_i..to_min(@e_time[i]).to_i
          overlap = 1 if min[i] == '1'
          end
      end
    end
    p overlap
  end

  def sleep_t(st, et)
    day = @today
    db = SQLite3::Database.new('scheduler.db')
    for i in 0..@inputdays.to_i - 1
      s_day = day
      e_day = nextday(day)
      if search_same('sleep', s_day, st, e_day, et) == 0
        db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, completed) values(?, ?, ?, ?, ?, ?, ?)', 'sleep', s_day, st, e_day, et, 's', '0')
      end
      day = nextday(day)
    end
    db.close
  end

  def eating_t(st, et)
    day = @today
    db = SQLite3::Database.new('scheduler.db')
    for i in 0..@inputdays.to_i - 1
      if search_same('ごはん', day, st, day, et) == 0
        db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, completed) values(?, ?, ?, ?, ?, ?, ?)', 'ごはん', day, st, day, et, 's', '0')
      end
      day = nextday(day)
    end
    db.close
  end

  def view_event
    read_schedule
    for i in 0..@num - 1
      if i != 0
        print ','
        print "\n"
      end
      print "{\n"
      print "title: '" + @title[i].to_s + "',\n"
      print "id: '" + @id[i].to_s + "',\n"
      if @s_time[i] == '00:00' && @e_time[i] == '24:00'
        print " start: '" + @s_day[i].to_s + "'"
        print ",\n"
        print " end: \'" + @e_day[i].to_s + "\'\n"
        print '}'
      else
        print " start: '" + @s_day[i].to_s + 'T' + @s_time[i].to_s + ":00'"
        print ",\n"
        print " end: '" + @e_day[i].to_s + 'T' + @e_time[i].to_s + ":00'"

        if @st[i].to_s == 's' && @com[i].to_s == ''
          print "\n"
        elsif @st[i].to_s == 's' && @com[i].to_s == '0'
          print ",\n"
          print "color: 'grey'\n"
        elsif @st[i].to_s != 's' && @com[i].to_s == '1'
          print ",\n"
          print "color: 'grey'\n"
        else @st[i].to_s != 's' && @com[i].to_s == ''
             print ",\n"
             print "color: '#cd5c5c'\n"
         end
        print '}'
     end
      i += 1
    end
  end

  def view_taskmenu
    read_task
    print_t('body1.txt')
    print "<a href=\"/cgi-bin/cal/in_task.rb\" alt=\"タスクの入力\">タスクの新規作成</a></div>\n"
    print "<b>||| Task</b><div class='box-lid-menulist'>\n"
    print "<FORM name=\"form1\" action=\"edit_task.rb\" onSubmit=\"return false\">\n"
    print "<INPUT type=\"hidden\" name=\"taskid\" value=\""
    print "\">"
    for i in 0..@t_num - 1.to_i
      print "<INPUT type=\"radio\" onClick=\"mySubmit('"
      print @t_id[i]
      print "')\"> "
      print '<b>' if @t_imp[i] == '3'
      print @t_title[i]
      print '</b>' if @t_imp[i] == '3'
      print ' ('
      print to_h(to_min(@tasktime[i]).to_i - to_min(@c_tasktime[i]).to_i)
      print ')'
      print "</br>\n"
      print '<div class=\'box-lid-menu-postscript\'>〆 '
      print @te_day[i]
      print ', '
      print @te_time[i]
      print '<br>'
      print @t_about[i]
      print "</div>\n"
    end
    print "<div id = \"buttom\" align=\"right\" style=\"clear:both;\"></div>\n"
    print ' </form></div> '
    print_t('body2.txt')
  end
end

print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">'
print '<html xmlns="http://www.w3.org/1999/xhtml" lang="ja">'
print '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />'
print '<head><title>Scheduler</title>'
print_t('new_js1.txt')
#
# 以下、イベント追加の記述
# ユーザ設定に必要な変数
sleep_st = '22:30'
sleep_et = '08:00'
inputdays = '14'
eat_st = ['08:00', '12:00', '19:30']
eat_et = ['08:30', '13:00', '20:10']

# 翌日から２週間をタスク配置範囲とする
endday = today
today = nextday(today)
for n in 0..13
  # 14日間
  endday = nextday(endday)
end

event = Locate_events.new(today, inputdays)
event.sleep_t(sleep_st, sleep_et)
for i in 0..2
  event.eating_t(eat_st[i], eat_et[i])
end
event.decide_sday(today)
# event.overlap_event("2015-11-04", "2015-11-04", "15:00", "17:00")
event.view_event
print_t('js2.txt')
print '</head>'
print '<body>'
event.view_taskmenu
print '</body></html>'
