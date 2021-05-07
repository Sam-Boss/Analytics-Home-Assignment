/*Temp table holding all dates within data's range (2017-01-01 - 2017-06-01) */
with Dates as
    (
    SELECT '2017-01-01' AS Dates
    UNION ALL
        SELECT cast(Dateadd(day, 0, Date) as Date)
        FROM assignment.public.tasks_used_da
        WHERE Date <= '2017-06-01' and date > '2017-01-01'
        group by date
    order by Dates
    )

/*New Table assignment.sboss.tasks_used_da_normalized.
  Query creates a row for each date within range 2017-01-01 - 2017-06-01 for each account id via a cross join.
  If no tasks were completed by an account id on a given day (row does not exist in assignment.public.tasks_used_da),
  then the row will be given 0 tasks executed.
  The query then sums the tasks completed for each account id and date
  (as there can be multiple rows for each date account id pair.*/

select p.Dates as date, p.account_id, sum(coalesce(a.sum_tasks_used, 0)) as tasks
into assignment.sboss.tasks_used_da_normalized
from
    (
    select account_id, dates
    from
        (
        select account_id, min(Dates) min_date, max(Dates) max_date
        from assignment.public.tasks_used_da, Dates
        group by account_id
        ) q
    cross join Dates b
    where b.dates between q.min_date AND q.max_date
    ) p
left join assignment.public.tasks_used_da a
on p.account_id = a.account_id
and p.Dates = a.date
group by p.Dates, p.account_id
order by p.Dates