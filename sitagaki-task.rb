def task_edit_min(i, task, min)
  db = SQLite3::Database.new('scheduler.db')
  adtime=min.to_i-task.to_i
  new_t_time = to_h(to_min(@t_time[i]).to_i+adtime.to_i)
  db.execute('update task set t_time = ? where id=?', new_t_time, @t_id[i])
    db.close
    return $tasktime=min
end

def task_check_ad_min(i, tasktime, s, c)
 #開始時刻と終了時刻を定める
 if @e_day[s]==@s_day[s+1]
   #次の予定も同日の場合
 else
   $tasktime.to_i<c_max[c].to_i
   #スケジュールが次に無くて、カテゴリmaxより小さい場合
   st = to_h(to_min(@e_time[s]).to_i+10)
   et =to_h(to_min(st).to_i+$tasktime)
   add_db_task(i, s, st, et)
 end
end
def put_task
  decide_s_schedule(@today)
  s=@num_i.to_i
  read_task
  read_category

  until i ==@t_num.to_i-1
    check_tasktime(@t_id[i])
    while $resttime=="0"
      i=i+1
      check_tasktime(@t_id[i])
    end

    endday=@te_day[i]
    day=decide_sday

    for j in 0.. @c_num.to_i-1
      #カテゴリテーブルのカテゴリj
      if @t_category[i]==@c_name[j]
        #現在のタスクiのカテゴリ名がカテゴリとヒットした時
        c=j
        break;
      end
    end

    if $resttime.to_i < @c_min[c].to_i
      task_edit_min(i, $resttime, c_min[c])
    end
    #--カテゴリが一緒のスケジュールを参照--
    until day==endday
      if $resttime==0
        i=i+1
        break
      end
      if @category[s]==@t_category[i]
        #タスクのカテゴリとスケジュールのカテゴリが一緒
        #処理を追加
      else
        s=s+1
        day=@endday[s]
      end
    end
    if $resttime!=0 && @c_location[c]!=""
      #--locationが一緒のスケジュールを参照
      day=decide_sday
      s=@num_i.to_i
      until day==endday
        if $resttime==0
          i=i+1
          break
        end
        if @location[s].to_s==@c_location[c]
          #場所が一緒
          #処理を追加
        else
          s=s+1
          day = @e_day[s]
        end
      end
    end
    if $resttime!=0
      #--カテゴリが未設定のものを参照
      day=decide_sday
      s=@num_i.to_i
      until day==endday
        if $resttime==0
          i=i+1
          break
        end
        if @category[s]=="" || @category[s]=="未設定"
          #処理を追加
        else
          s=s+1
          day=@e_day[s]
        end
      end
    end
  end
end
