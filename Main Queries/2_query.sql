Create Table assignment.sboss.tasks_new_account as
    (
    select date, account_id, sum_tasks_used as tasks,
        case
            when date =
                (
                select min(t2.date)
                from assignment.public.tasks_used_da t2
                where t2.account_id = t1.account_id
                and t2.sum_tasks_used > 0
                )
            then TRUE
            else FALSE
        end as is_new
    from assignment.public.tasks_used_da t1
    order by date
    )