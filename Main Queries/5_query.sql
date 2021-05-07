select count(t.account_id)
    from (select distinct account_id, sum(tasks) as sumtask
    from assignment.sboss.tasks_used_da_normalized
    where date between '2017-02-01' and '2017-02-28'
    group by account_id) as t
    where t.sumtask = 0