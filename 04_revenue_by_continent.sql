--The task was to create an analytical table broken down by continent to evaluate revenue, revenue sources by device type, account count, number of verified users, and session count, using the following structure: 
--| Continent | Revenue | Revenue from Mobile | Revenue from Desktop | % Revenue from Total | Account Count | Verified Account | Session Count |

--сreate the first CTE, `revenue_info`, to analyze revenue.
--сalculate total revenue, as well as revenue broken down by device type (Mobile and Desktop). 
--group the results by continent.

WITH
  revenue_info AS (
    SELECT
      sp.continent,
      sum(p.price) AS revenue,
      SUM(CASE WHEN device = 'mobile' THEN p.price END) AS revenue_from_mobile,
      SUM(CASE WHEN device = 'desktop' THEN p.price END) AS revenue_from_desktop
    FROM `DA.session` s
    JOIN `DA.session_params` sp
      ON sp.ga_session_id = s.ga_session_id
    JOIN `DA.order` o
      ON s.ga_session_id = o.ga_session_id
    JOIN `DA.product` p
      ON o.item_id = p.item_id
    GROUP BY sp.continent
  ),
 
  --сreate a second CTE, `account_info`, to analyze accounts.
  account_info AS (
    SELECT
      sp.continent,
      COUNT(acs.account_id) AS account_cnt,
      COUNT(CASE WHEN a.is_verified = 1 THEN account_id END) AS verified_account
    FROM `DA.session` s
    JOIN `DA.session_params` sp
      ON sp.ga_session_id = s.ga_session_id
    JOIN `DA.account_session` acs
      ON acs.ga_session_id = s.ga_session_id
    JOIN `DA.account` a
      ON a.id = acs.account_id
    GROUP BY sp.continent
  ),
  
  --third CTE, `session_info`, to analyze user activity. Count the number of sessions and group the results by continent.
  session_info AS (
    SELECT sp.continent, COUNT(s.ga_session_id) AS session_cnt
    FROM `DA.session` s
    JOIN `DA.session_params` sp
      ON s.ga_session_id = sp.ga_session_id
    GROUP BY sp.continent
  )

  --in the final `SELECT` statement, join CTE and calculate each continent's share of the total revenue
  SELECT
  session_info.continent,
  revenue_info.revenue,
  revenue_info.revenue_from_mobile,
  revenue_info.revenue_from_desktop,
  revenue_info.revenue / (sum(revenue_info.revenue) OVER ())
    AS revenue_from_total,
  account_info.account_cnt,
  account_info.verified_account,
  session_info.session_cnt
FROM session_info
LEFT JOIN account_info
  ON session_info.continent = account_info.continent
LEFT JOIN revenue_info
  ON revenue_info.continent = session_info.continent
