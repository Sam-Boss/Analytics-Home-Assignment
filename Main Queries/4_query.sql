Create Table assignment.sboss.tasks_7d_avg as
   (
   select t.*,
       avg(cast(tasks as float)) over
           (
           partition by t.account_id
           order by date
           rows between 6 preceding and current row
           ) as avg_7d
   from
       (
       select *
       from assignment.sboss.tasks_used_da_normalized
       order by account_id, date
       ) t
    )