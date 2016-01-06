#!/usr/bin/ruby
# coding: utf-8
require 'cgi'
require 'sqlite3'
require 'kconv'
data = CGI.new
print "Content-type: text/html\n\n"
s_day = data['s_day'].to_s.toutf8.strip
s_time = data['s_time'].to_s.toutf8.strip
e_day = data['e_day'].to_s.toutf8.strip
e_time = data['e_time'].to_s.toutf8.strip
title = data['content'].to_s.toutf8.strip
category = data['category'].to_s.toutf8.strip
id = data['id'].to_s.toutf8.strip
s_time = '00:00' if s_time == ''
e_time = '24:00' if e_time == ''

#規定文を作成する時以下を利用する
search_title = data['s_title'].to_s.toutf8.strip
new_def = data['new_def'].to_s.toutf8.strip
#削除時以下にidが添付される
del = data['del'].to_s.toutf8.strip
#タスクの新規スケジュール作成時
task = data['task'].to_s.toutf8.strip
t_title = data['t_title'].to_s.toutf8.strip
t_st = data['st'].to_s.toutf8.strip
t_et = data['et'].to_s.toutf8.strip
#--タスクスケジュール追加時-
t_id = data['t_id'].to_s.toutf8


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

def return_index
  print '<html>'
  print '<head><META http-equiv="refresh"; content="0; URL=index.rb"></head><body></body></html>'
end

def del_schedule(id)
  db = SQLite3::Database.new('scheduler.db')
  db.results_as_hash = true
  db.execute('delete from schedule where id=?', id)
  db.close
  return_index
end

def picker(sd,ed,st,et)
  print "$('#s_time').datetimepicker({" + "\n"
  print '	datepicker:false,' + "\n"
  print "	format:'H:i'," + "\n"
  print "	value:'"
  print st
      print "',"
  print '	step:5' + "\n"
  print '});' + "\n"
  print "$('#s_day').datetimepicker({" + "\n"
  print "	lang:'jp'," + "\n"
  print '	timepicker:false,' + "\n"
  print "	value:'"
  print sd.to_s.chomp
  print "',"
  print "	format:'Y-m-d'," + "\n"
  print "	formatDate:'Y/m/d'," + "\n"
  print '});' + "\n"
  print "$('#e_time').datetimepicker({" + "\n"
  print '	datepicker:false,' + "\n"
  print "	format:'H:i'," + "\n"
  print "	value:'"
  print et
  print "',"
  print '	step:5' + "\n"
  print '});' + "\n"
  print "$('#e_day').datetimepicker({" + "\n"
  print "	lang:'jp'," + "\n"
  print '	timepicker:false,' + "\n"
  print "	value:'"
  print ed.to_s.chomp
  print "',"
  print "	format:'Y-m-d'," + "\n"
  print "	formatDate:'Y/m/d'," + "\n"
  print '});' + "\n"
end

def input_def(name, sday)
  #新規定形スケジュールの時の表示
  db = SQLite3::Database.new('scheduler.db')
  db.results_as_hash = true
  db.execute('select * from defalt_s where title=?', name) do |row|
  $st=row[4].to_s
  $et=row[5].to_s
  $category=row[6].to_s
  end
  print_t('new_schedule1.txt')
  print "<form action=\"add_schedule.rb\" method=\"post\">"
  if name.to_s=="no_name"
    print "<input type=\"hidden\" name=\"new_def\" value=\""
    print "add"
    print "\">"
  end
  print "<label>件名：</label>"
  print "<input type=\"text\" name=\"content\" style=\"width: 60%; height: 1.5em;\" value=\""
  print name
  print "\">"
  print "<br>"
  print_t('new_schedule3.txt')
  print '<p><label>カテゴリ：</label>'
  print '<select name="category">'
  i=0
  num=0
  db.execute('select * from category where s=?', "1") do |row|
    num += 1
  end
  c_name = Array.new(num)
  db.execute('select * from category where s=?', "1") do |row|
    c_name[i] = row[0]
    print "<option value=\"#{c_name[i].to_s.chomp}\""
    if c_name[i]==$category
      print "selected"
    end
    print ">#{c_name[i].to_s.chomp}</option>"
    i += 1
  end
  print "<option value=\"no_name\">新規作成</option></select></p>"
  print "<p><input type=\"submit\" value=\"送信\"  onclick=\"window.close()\" class=\"btn\"></p>"
  print '</form></div></div></div></body>'
  print_t('new_schedule4.txt')
  picker(sday, sday, $st, $et)
  print_t('new_schedule5.txt')
  db.close
end

def input_taskschedule(name, sday, st, et)
  #新規タスクのスケジュールの場合
  db = SQLite3::Database.new('scheduler.db')
  db.results_as_hash = true
  db.execute('select * from task where title=?', name) do |row|
  $id=row[0].to_s
  $category=row[6].to_s
  end
  db.execute('select * from task where id=?', $id) do |row|
    $per = row[11]
  end
  print_t('calendar_task1.txt')
  printf("value: %s,\n",$per.to_i)
  printf("min: 1,\n")
  printf("max: 100,\n")
  print_t('calendar_task2.txt')
  print "<form action=\"add_schedule.rb\" method=\"post\">"
  print "<input type=\"hidden\" name=\"t_id\" value=\""
  print $id
  print "\">"
  print "<label>件名：</label>"
  print "<input type=\"text\" name=\"content\"  style=\"width: 60%; height: 1.5em;\" value=\""
  print name
  print "\">"
  print "<br>"
  print_t('new_schedule3.txt')
  print ' <p>'
print ' <label for="amount">全体の進捗状況を入力:</label>'
print '   <input type="text" id="amount" style="border: 0; color: #f6931f; font-weight: bold;" />'
print ' </p>'
print ' <div id="slider-range-min"></div>'
print '  <p><label>メモ</label></p>'
print "\n"
print " <textarea rows=\"3\" name=\"memo"
print "\" size=\"20\" value=\""
# print  $about[$t_num]
print "\"></textarea><br>\n"
  print "<p><input type=\"submit\" value=\"送信\"  onclick=\"window.close()\" class=\"btn\"></p>"
  print '</form></div></div></div></body>'
  print_t('new_schedule4.txt')
  picker(sday, sday, st, et)
  print_t('new_schedule5.txt')
  db.close
end

def new_category(id, title, sd, ed, st, et)
  #新規カテゴリ作成が選択された場合
  print_t('new_schedule1.txt')
     print "<form action=\"add_schedule.rb\" method=\"post\">"
     if id!=""
       print "<input type=\"hidden\" name=\"id\" value=\""
       print id
       print "\">"
     end
       print "<label>件名：</label>"
       print "<input type=\"text\" name=\"content\"  style=\"width: 60%; height: 1.5em;\" value=\""
       print title
       print "\">"
       print "<br>"
  print_t('new_schedule3.txt')
  print '<p><label>カテゴリ：</label>'
 print "<input type=\"text\" name=\"category\"  style=\"width: 60%; height: 1.5em;\" value=\"新規カテゴリ名\"><br>"
  print "<p><input type=\"submit\" value=\"送信\"  onclick=\"window.close()\" class=\"btn\"></p>"
  print '</form></div></div></div></body>'
  print_t('new_schedule4.txt')
  picker(sd, ed, st, et)
  print_t('new_schedule5.txt')
end

def search_category(name)
  db = SQLite3::Database.new('scheduler.db')
  db.results_as_hash = true
  found = 0
  # カテゴリが新規に作成されたものなら０、違うなら１
  db.execute('select * from category where name=?', name) do |row|
    found = 1
  end
  if found == 0
    # カテゴリが新規（フラグが立たなかった）時
    db.transaction do
      db.execute('insert into category  (name, s, t, max, min) values(?, ?, ?, ?, ?)', name, "1", "0", "180", "30")
    end
  else
    #カテゴリがあったが、スケジュールで作成されたタスクだった場合
        db.execute('update category set s =?  where name=?', "1", name)
  end
  db.close
end

def edit_db_schedule(id, title, sd, ed, st, et, category)
  #既存スケジュールの変更
  db = SQLite3::Database.new('scheduler.db')
  db.results_as_hash = true
  db.execute('update schedule set title =?  where id=?', title, id)
  db.execute('update schedule set s_day =?  where id=?', sd, id)
  db.execute('update schedule set s_time =?  where id=?', st, id)
  db.execute('update schedule set e_day =?  where id=?', ed, id)
  db.execute('update schedule set e_time =?  where id=?', et, id)
  db.execute('update schedule set category =?  where id=?', category, id)
  db.close
  return_index
end

def edit_db_t_schedule(t_id, title, sd, ed, st, et)
  #手動でタスクを入力した時
    db = SQLite3::Database.new('scheduler.db')
    db.execute('select * from par') do |row|
      $per = row[0]
    end
    db.execute('select * from task where id=?',t_id) do |row|
      $tt = row[4].to_s.toutf8
      $o_ct = row[8].to_s.toutf8
      $o_log = row[10].to_s.toutf8
      $o_per = row[11].to_s.toutf8
    end
    ct=to_h((to_min(et).to_i-to_min(st).to_i)+to_min($o_ct).to_i).to_s
    task_time= to_h((100/$per.to_f)*to_min(ct).to_f)
 #MANUAL(作業時間50,進捗◯%)
    log = "MANUAL("+sd+","+st+"作業時間"+(to_min(et).to_i-to_min(st).to_i).to_s+",進捗"+$o_per.to_s+"→"+$per.to_s+")"

    printf("ct=%s, per=%s, old_tasktime=%s, task_time=%s, log=%s\n", ct, $per, $tt, task_time, log)
  db.results_as_hash = true
        db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, completed) values(?, ?, ?, ?, ?, ?, ?)', title, sd, st, ed, et, t_id, "1")
        db.execute('update task set per =?  where id=?', $per, t_id)
        db.execute('update task set log =?  where id=?', $o_log.to_s+log.to_s, t_id)
        db.execute('update task set t_time =?  where id=?', task_time, t_id)
        db.execute('update task set time =?  where id=?', ct, t_id)
    db.close
    return_index
end

def add_def(title, st, et, category)
  db = SQLite3::Database.new('scheduler.db')
  db.results_as_hash = true
        db.execute('insert into defalt_s  (title, s_time, e_time, category) values(?, ?, ?, ?)', title, st, et, category)
    db.close
end

def add_db_schedule(title, sd, ed, st, et, category)
  #新規スケジュール作成
  db = SQLite3::Database.new('scheduler.db')
  db.results_as_hash = true
        db.execute('insert into schedule  (title, s_day, s_time, e_day, e_time, st, category) values(?, ?, ?, ?, ?, ?, ?)', title, sd, st, ed, et, 's', category)
    db.close
    return_index
end

if del != ''
  # 削除ボタンが選択された時
  del_schedule(del)
elsif t_title!="" && task!=""
    input_taskschedule(t_title, s_day, t_st, t_et)
elsif search_title != ""
  # 定型文から選択された時
  input_def(search_title, s_day)
elsif category == 'no_name'
  # カテゴリ入力フォームを決め直して再度表示
  new_category(id, title, s_day, e_day, s_time, e_time)
else
  # 普通に引き継ぎ、カテゴリ選択済み
  search_category(category)
  if id!=""
    edit_db_schedule(id, title, s_day, e_day, s_time, e_time, category)
  elsif  t_id!=""
        edit_db_t_schedule(t_id, title, s_day, e_day, s_time, e_time)
  else
    if new_def!=""
      add_def(title, s_time, e_time, category)
    end
    add_db_schedule(title, s_day, e_day, s_time, e_time, category)
  end
end
