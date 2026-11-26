--Analyzed monthly sales revenue and paid advertising expenses.


--cumulative revenue and cumulative advertising expenses using window functions
SELECT
  new_date,
  revenue,
  sum(revenue) OVER (ORDER BY new_date) AS cumulative_revenue,
  cost,
  sum(cost) OVER (ORDER BY new_date) AS cumulative_cost
FROM
  (
    --combined data from various tables

  --aggregated financial metrics by month.
  SELECT new_date, sum(revenue) AS revenue, sum(cost) AS cost
    FROM
      (
      --сalculated monthly sales revenue.  
  
        SELECT
          date(
            EXTRACT(year FROM s.date),
            EXTRACT(month FROM s.date),
            1) AS new_date,
          sum(p.price) AS revenue,
          0 AS cost
        FROM `DA.order` o
        JOIN `DA.product` p
          ON p.item_id = o.item_id
        JOIN `DA.session` s
          ON s.ga_session_id = o.ga_session_id
        GROUP BY 1

        UNION ALL
         -calculated monthly sales advertising costs.
  
        SELECT
          date(
            EXTRACT(year FROM psc.date),
            EXTRACT(month FROM psc.date),
            1) AS new_date,
          0 AS revenue,
          sum(psc.cost) AS cost
        FROM `DA.paid_search_cost` psc
        GROUP BY 1
      )

    GROUP BY 1
  )
ORDER BY 1
