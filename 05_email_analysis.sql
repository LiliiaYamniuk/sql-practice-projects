--Analyze email campaign performance by date, country,
-- email sending interval, account verification status,
-- and unsubscribe status.
-- Key metrics:
-- - Number of unique accounts
-- - Sent, opened, and clicked emails
-- - Total accounts and sent emails by country
-- - Country rankings by number of accounts and sent emails


-- email_info – collects email statistics.
with email_info as (
select
  date_add (s.date, INTERVAL es.sent_date DAY) as email_date,
  sp.country,
  a.send_interval,
  a.is_verified,
  a.is_unsubscribed,
  count(distinct es.id_message) as sent_message,
  count(distinct eo.id_message) as open_message,
  count(distinct ev.id_message) as visit_message
    
from  `DA.email_sent` es
left join `DA.email_open`eo on eo.id_message = es.id_message
left join `DA.email_visit`ev on ev.id_message = es.id_message
join `DA.account` a on a.id = es.id_account
join `DA.account_session` acs on acs.account_id = a.id
join `DA.session` s on s.ga_session_id = acs.ga_session_id
join `DA.session_params` sp on sp.ga_session_id = s.ga_session_id
group by 1,2,3,4,5
),

  --account_info – collects account information.
account_info AS (
  select
    s.date,
    sp.country,
    a.send_interval,
    a.is_verified,
    a.is_unsubscribed,
    a.id AS account_id,
   
  from `DA.account` a
  join `DA.account_session` acs
  on acs.account_id = a.id
  join `DA.session` s
  on s.ga_session_id = acs.ga_session_id
  join `DA.session_params` sp
  on sp.ga_session_id = s.ga_session_id
  
),

  --united_data – combines email and account data using UNION ALL.
united_data AS (
  select
    email_date as date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    0 as account_id,
    coalesce(ei.sent_message, 0) as sent_message,
    coalesce(ei.open_message, 0) as open_message,
    coalesce(ei.visit_message, 0) as visit_message
  from email_info ei
union all
 select
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_id,
    0 as sent_message,
    0 as open_message,
    0 as  visit_message
  from account_info
  ),

  --final – aggregates metrics by the selected dimensions
  final as (
 select
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    count(distinct account_id) AS account_cnt,
    sum(sent_message) AS cnt_sent_message,
    sum(open_message) AS cnt_open_message,
    sum(visit_message) AS cnt_visit_message

  from united_data
  group by 1,2,3,4,5
  ),

-- country_sum – calculates country-level totals using window functions.
country_sum as (
  select
    date,
    country,
    send_interval,
    is_verified,
    is_unsubscribed,
    account_cnt,
    cnt_sent_message,
    cnt_open_message,
    cnt_visit_message,
    sum(account_cnt) OVER (PARTITION BY country) AS total_country_account_cnt,
    sum(cnt_sent_message) OVER (PARTITION BY country) AS total_country_sent_cnt
from final
)
--final SELECT – ranks countries using DENSE_RANK().
  SELECT
    *,
    DENSE_RANK() OVER (ORDER BY total_country_sent_cnt DESC) AS rank_total_country_sent_cnt,
    DENSE_RANK() OVER (ORDER BY total_country_account_cnt DESC) AS rank_total_country_account_cnt
  FROM country_sum
