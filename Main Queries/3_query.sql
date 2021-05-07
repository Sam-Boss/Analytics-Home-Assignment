/*Using assignment.sboss.tasks_used_da_normalized, left join on itself to obtain
  previous day's # tasks for each account.

  Calculate daily % change in tasks for each account as:
  (today's tasks - yesterday's tasks) / yesterday's tasks

  Note that pct_change will be NULL if yesterday's # tasks = 0 (divide by 0 error)
  */
Create Table assignment.sboss.tasks_pct_change as
    (
    select distinct temp.*,
    ((temp.tasks - temp2.tasks) / CAST(nullif(temp2.tasks, 0) as decimal(8,2))) * 100 as pct_change
    from assignment.sboss.tasks_used_da_normalized temp
    left join assignment.sboss.tasks_used_da_normalized temp2
    on temp.account_id = temp2.account_id
    and temp2.date = temp.date - 1
    order by temp.date
    )