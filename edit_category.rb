#!/usr/bin/ruby
# coding: utf-8
require 'cgi'
require 'sqlite3'
require 'kconv'
data = CGI.new
print "Content-type: text/html\n\n"
c_name = data['c_name'].to_s.toutf8
edit_taskid = data['taskid'].to_s.toutf8

#カテゴリ編集数値入力後、受け取る変数
edit_id = data['c_id'].to_s.toutf8
edit_min = data['min_time'].to_s.toutf8
edit_max = data['max_time'].to_s.toutf8

#新規カテゴリ作成の場合
new_categoryname= data['new_category'].to_s.toutf8

def to_min(time)
  if time == "00:00"
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

def return_index
  print '<html>'
  print '<head><META http-equiv="refresh"; content="0; URL=index.rb"></head><body></body></html>'
end

def new_category(name)
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
        db.execute('update category set t =?  where name=?', "1", name)
  end
  db.close
  return_index
end

print_t('edit_category1.txt')
db = SQLite3::Database.new('scheduler.db')
num = 0
db.execute('select * from category') do |_row|
  num += 1
end

name = Array.new(num)
s = Array.new(num)
t = Array.new(num)
location = Array.new(num)
another = Array.new(num)
pc = Array.new(num)
min = Array.new(num)
max = Array.new(num)
i = 0
print "<div id=\"layout\"><div id=\"content\">\n"
printf("<h1 id=\"h01\">カテゴリ編集</h1><hr>\n")
db.execute('select * from category') do |row|
  name[i] = row[0]
  location[i] = row[1]
  another[i] = row[2]
  pc[i] = row[3]
  s[i] = row[4]
  t[i] = row[5]
  max[i] = row[7]
  min[i] = row[8]
  i += 1
end
if edit_taskid.to_s=="" && edit_id.to_s=="" && new_categoryname==""
    #表示画面
    print "<FORM name=\"form1\" action=\"edit_category.rb\" onSubmit=\"return false\">\n"
    print"<p><input type=\"hidden\" name=\"taskid\" value=\"\">\n"
    for i in 1..num-1
      print "<input type=\"radio\" onClick=\"mySubmit('"
      print  i
      print "')\"><u>"
      print name[i]
      printf("</u></p>\n<p>　連続作業可能時間：%s 〜%s</p>\n", to_h(min[i].to_i), to_h(max[i].to_i))
      if location[i].to_s!=""
        printf("<p>　位置情報：%s </p>\n", location[i].to_s)
      end
    end
    print'</form><form action="edit_category.rb" method="post">'
    print'<input type="text" name="new_category"  style="width: 60%; height: 1.5em;" value="新規カテゴリ名">'
    print' <p><input type="submit" value="送信" onclick="window.close()"  class="btn"></p></form>'

    print "<div id = \"buttom\" align=\"right\" style=\"clear:both;\"></div></form></div>"
    print 'カテゴリの削除：'
    print "\n "
    print "<form action=\"edit_task.rb\" method=\"post\"> \n "
    print "  <select name=\"del_category\">\n  "
    $c_name = Array.new(num)
    $c = 0
    sql = 'select * from category'
    db.execute(sql) do |row|
      $c_name[$c] = row[0]
      print "<option value=\""
      print $c_name[$c]
      print "\">"
      print $c_name[$c]
      print "</option>\n "
      $c += 1
    end
    print '  </select> '
    print "\n "
    print "<input type=\"submit\" value=\"削除\"  onclick=\"window.close()\" class=\"btn\"></p>\n  "
    print '  </form>'
    print "<div id = \"buttom\" align=\"right\" style=\"clear:both;\">"
  print "<form><INPUT type=\"button\" onClick='history.back();' value=\"戻る\" class=\"btn\">"
  print "</form></div></div></div></body>\n"
  print_t('edit_category5.txt')
elsif edit_taskid.to_s!=""
  #もしedit_tasknameが空白じゃなかったら、編集画面を出力する
  id=edit_taskid.to_i
  print "<form action=\"edit_category.rb\" method=\"post\">"
  print "<input type=\"hidden\" name=\"c_id\" value=\""
  print id
  print "\">\n"
  printf("<label>カテゴリ名：<u>")
  print name[id.to_i]
  printf("</u></label><br>\n")
  printf("作業可能最小時刻\n")
  print "  <input id=\"min_time\" type=\"text\" name=\"min_time\" value=\""
  print to_h(min[id.to_i])
  print "\"><br>"
  printf("作業可能最大時刻\n")
  print "  <input id=\"max_time\" type=\"text\" name=\"max_time\" value=\""
  print to_h(max[id.to_i])
  print "\"><br>\n"
  printf("ロケーション指定\n")
  print "<p><input type=\"submit\" value=\"変更\"  onclick=\"window.close()\" class=\"btn\"></p>"
  print '</form>'
  print_t("edit_category3.txt")

  print "  $('#min_time').datetimepicker({\n"
  print "datepicker:false,\n"
  print"	format:'H:i',\n"
  print"	value:'"
  print to_h(min[id])
  print "',\n step:5\n});\n"
  print "$('#max_time').datetimepicker({\n"
  print " datepicker:false,\n"
  print " format:'H:i',\n"
  print "value:'"
  print to_h(max[id])
  print "',\n step:5\n});\n"
  print "</script>\n"
elsif edit_id.to_s!=""
  #dbに編集後の時間を書き換える
  db = SQLite3::Database.new('scheduler.db')
  e_min=to_min(edit_min)
  e_max=to_min(edit_max)
    db.execute('update category set min =?  where name=?', e_min, name[edit_id.to_i])
    db.execute('update category set max =?  where name=?', e_max, name[edit_id.to_i])
  db.close
  printf("<label>カテゴリ名：<u>")
  print name[edit_id.to_i]
  print "</u><br>"
  printf("作業可能最小時刻\n")
  printf edit_min
  print "<br>"
  printf("\n作業可能最大時刻\n")
  printf edit_max
    print "<br>"
    printf("\nに変更しました！\n")
        print "<br>"
        print "<div id = \"buttom\" align=\"right\" style=\"clear:both;\">"
      print "<form><INPUT type=\"button\" onClick='history.back();' value=\"戻る\" class=\"btn\">"
      print "</form></div></div></div></body>\n"
    elsif new_categoryname!=nil
      #カテゴリ新規作成の場合
      new_category(new_categoryname)
end
print_t('edit_category5.txt')
db.close
