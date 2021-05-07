select top 10 account_id, count(distinct user_id) as num_users
from assignment.public.tasks_used_da
group by account_id having count(distinct user_id) > 1
order By num_users desc