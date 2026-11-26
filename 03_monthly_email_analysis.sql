--Analyzing the distribution of emails across accounts for each month, finding each account's share of the total emails and the dates of the first and last email sent.


--Used SUM() OVER (PARTITION BY ...) to calculate each account's share of the total number of emails.
--Used MIN() OVER() and MAX() OVER() to determine the date of the first and last email sent to each account within a given month.
select 
 distinct sent_month,
id_account,
(sum(cnt_message ) over (partition by id_account, sent_month)/
sum(cnt_message ) over (partition by  sent_month))*100 as sent_msg_percent_from_this_month,
min(send_day) over (partition by id_account,sent_month ) as first_sent_date,
max(send_day) over (partition by id_account, sent_month) as last_sent_date

from (
  --finding the actual email sending date using `DATE_ADD` and finding the sending month using `DATE_TRUNC` 
  --calculated the number of unique emails sent per account for each day using `COUNT(DISTINCT)`
select
date_trunc(date_add(s.date, INTERVAL es.sent_date day),month) as sent_month,
date_add(s.date, INTERVAL es.sent_date day) as send_day,
acs.account_id as id_account,
count(distinct es.id_message) as cnt_message

from `DA.email_sent` es
join `DA.account_session` acs
on acs.account_id = es.id_account
join `DA.session` s
on s.ga_session_id = acs.ga_session_id
group by 
date_trunc(date_add(s.date, INTERVAL es.sent_date day),month),
date_add(s.date, INTERVAL es.sent_date day),
acs.account_id
order by 4 desc
) data_1
order by 3,2
