Hello! This will act a guide through my responses to the Planoly Analytics Home Assignment. Within this repository, there are two folders:

1) Main Queries - holds .sql queries that are a direct answer for each question asked in the assignment

2) Test Queries - holds .sql files to spot check the new tables created within the assignment

The .sql files should be imported into your sql environment to run, or opened in a text editor to review.

Now, let's talk through each question and my answers.

****************************************

1) Which are the top 10 account ids by number of users?

Simple look up using the assignment.public.tasks_used_da table. I grouped by account_id in order to select the count of user_ids for each account.

ANSWER:
account_id,num_users
-1,3614
2101269,116
2074697,44
2147969,20
2284259,18
1215768,17
1675574,15
2187586,13
2165388,11
2258002,9 

Looks like -1 has the most users. I would assume here that -1 may be used for testing purposes internally and of course does not represent an actual customer account.

****************************************

2) Create a summary table at the account level that signals when an account is new (boolean). An account is new for the first day we see it run a task(s). The table should look similar to the one below in structure.

I created a table called assignment.sboss.tasks_new_account. The logic used to created this table utilizes a case statement within the select statement to populate the 'is_new' attribute. 

For each account_id/date combination in assignment.public.tasks_used_da, if the first date for that account with a completed task is the current date being checked, is_new = true. Else, is_new = false.

****************************************

**NOTE**
For questions 3 - 5, I created an additional transitional table called assignment.sboss.tasks_used_da_normalized. The query to create it is in normalize_data.sql.

I noticed the following with the original assignment.public.tasks_used_da table:
1) There can be 0 rows for an account_id/date combination if no tasks are completed
2) There can also be >1 row for an account_id/date combination representing different users on the same account

I figured that if I normalized the data such that there will be 1 row for every account_id/date combination, the queries for question 3-5 would be significantly easier to write due to better consistency within the data.

The query in normalize_data.sql essentially does the following:
1)Creates a temp table of all dates in data range (2017-01-01 - 2017-06-01)
2)Cross Joins this dates table with each unique account_id in assignment.public.tasks_used_da such that for each account_id, there will be a row for each date
3)Left Joins back on assignment.public.tasks_used_da to get all tasks completed for each account_id/date combination
4)Fills in task value with 0 if no other tasks completed in assignment.public.tasks_used_da for that given account_id/date combination
5)Groups by account_id and date to obtain sum of all tasks completed by one account for a given day 

Thus, through this logic, assignment.sboss.tasks_used_da_normalized is created such that there will always be 1 row for each account_id/date combination in the date range 2017-01-01 - 2017-06-01. It is used in the rest of the questions.

****************************************

3) Create a summary table at the account level. Add a column with the % difference in the number of tasks to the previous day (feel free to reuse the previous)

I created a new table called assignment.sboss.tasks_pct_change which is essentially assignment.sboss.tasks_used_da_normalized with an additional column for daily change.

I calculate % change for a given account_id and date as

((today's tasks - yesterday's tasks) / yesterday's tasks) * 100

In order to avoid divide by zero errors, I utilize a nullif so that the calculation will return NULL if yesterday's tasks = 0.

I obtain "yesterday's tasks" in the equation by left joining assignment.sboss.tasks_used_da_normalized onto itself for it's current and previous day.

****************************************

4)Add another column with the moving average of the tasks run in the last 7 days for each account.

I created a new table called assignment.sboss.tasks_7d_avg which is assignment.sboss.tasks_used_da_normalized plus an additional column for rolling 7 day task average for a given account id.

By sub querying assignment.sboss.tasks_used_da_normalized such that it is ordered by account_id, and date, I am able to take the 7 day average from the last 6 rows' task values and the current rows. I partition this over account_id to ensure that the rolling average process restarts with each new account_id.

****************************************

5)A lost account is an account with no tasks run on a given month. How many accounts did we lose (had no executed tasks) in February 2017?

This is obtained via a look up of the assignment.sboss.tasks_used_da_normalized table. I use a sub query to get the sum of all tasks for each account_id in the month of Feb 2017. I then simply specify the count of all account_ids that have a sum of 0 tasks.

Answer: 157223 accounts lost.

****************************************
6)(OPTIONAL) Create a visualization that represents the growth of new accounts in a way you would communicate to a peer or business stakeholder.

Please note that I simply ran out of time for this one. I am traveling this week (5/7 - 5/14) and did not have time to implement. I would have made a line graph in python using pandas and pyplot with some exported results of theses sql queries.